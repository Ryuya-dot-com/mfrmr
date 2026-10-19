"""Audit the entire retained right-ray partition under the fixed error budget.

Reuse saved exclusions and observation bounds, then apply the qualified
observed-data slope-tail bound. No splitting, fitting, simulation, integration,
or changed historical checkpoint. Unsettled leaves remain explicit.
"""
from collections import Counter
from decimal import Decimal, localcontext, ROUND_CEILING
from fractions import Fraction as Q
from pathlib import Path
import json
import runpy


HELPER = Path("inst/validation/jml-nuisance-region-bounds-20261012.py")
helper = runpy.run_path(str(HELPER))
local_path, digest = helper["local_path"], helper["digest"]
BASE, PROFILES, ENGINE = helper["BASE"], helper["PROFILES"], helper["ENGINE"]
SEED = helper["MERGE"] / "jml-right-21over4.json"
OUTPUT = Path("validation-results/jml-nuisance-region-review-20261012/domain-review.json")
ALPHA, BETA = Q(1, 20), Q(1, 200)


def compact(record):
    if "Box" in record and "PValueUpper" in record:
        return {key: record[key] for key in ("Box", "PValueUpper")}
    if "Box" in record and "Reason" in record:
        return {key: record[key] for key in ("Box", "Reason")}
    return record


def decimal_tail(entropy, certificates, lower):
    """Independent upper enclosure of the saved powered-discordance formula."""
    with localcontext() as context:
        context.prec = 80
        context.rounding = ROUND_CEILING

        def number(value):
            return Decimal(value.numerator) / Decimal(value.denominator)

        result = number(entropy)
        for certificate, slope in zip(certificates, lower):
            power = Q(certificate["Power"])
            value = number((1-power)*entropy)
            for positive, negative in certificate["OppositeOrientationCounts"]:
                n, m = positive + negative, min(positive, negative)
                if m:
                    ratio = number(Q(2*n, 5*m) / (slope*power))
                    term = n*ratio.ln().next_plus()-n+2*m
                    value += min(Decimal(0), term)
            result = min(result, value)
        return Q(result)


def main():
    sources = {str(HELPER): digest(HELPER), str(Path(__file__)): digest(__file__)}

    def verify(mapping):
        for name, expected in mapping.items():
            path = local_path(name)
            actual = sources.get(str(path)) or digest(path)
            assert actual == expected, f"Changed evidence: {name}"
            sources[str(path)] = actual

    def read(path):
        sources[str(path)] = digest(path)
        return json.loads(path.read_text())

    chain = []

    def checkpoint(path, expected, ancestors=()):
        path = local_path(str(path))
        assert path.resolve() not in ancestors, "Cyclic checkpoint reference"
        verify({str(path): expected})
        with path.open() as stream:
            state = json.load(stream, object_hook=compact)
        assert all(set(r) == {"Box", "PValueUpper"} for r in state["Excluded"])
        assert Q(state["Identity"]["Contrast"]) == Q(21, 4)
        assert state["Identity"]["Observed"] == 1 and state["Identity"]["Arm"] == "GPCM-JML"
        chain.append({"Path": str(path), "SHA256": expected, "LocalExclusions": len(state["Excluded"])})
        parent = state.get("ExcludedPrefixSource")
        if parent:
            previous = checkpoint(parent["Path"], parent["SHA256"], ancestors+(path.resolve(),))
            assert len(previous["Excluded"]) == parent["Count"]
            assert previous["Identity"]["CommonUpperSlopes"] == state["Identity"]["CommonUpperSlopes"]
            state["Excluded"] = previous["Excluded"] + state["Excluded"]
        return state

    old = read(helper["DESTINATION"])
    verify(old["Sources"])
    assert old["Alpha"] == str(ALPHA) and old["Beta"] == str(BETA)
    state = checkpoint(SEED, old["Sources"][str(SEED)])
    print("Read preserved partition:", len(state["Excluded"]), "excluded,", len(state["Pending"]),
          "pending,", len(state["Unresolved"]), "unresolved", flush=True)
    assert (len(state["Excluded"]), len(state["Pending"]), len(state["Unresolved"])) == (1130, 3989, 472)
    engine = runpy.run_path(str(ENGINE))
    engine["check_partition"](state)
    # Compare the projection to the unmodified decoder on the real small suffix.
    raw = json.loads(SEED.read_text())
    assert state["Excluded"][-len(raw["Excluded"]):] == [compact(r) for r in raw["Excluded"]]
    assert state["Pending"] == raw["Pending"]
    assert state["Unresolved"] == [compact(r) for r in raw["Unresolved"]]
    del raw

    base = runpy.run_path(str(engine["BASE"]))
    base["IV"].dps = 60
    iv, ends, interval = base["iv"], base["ends"], base["IV"]
    beta_log_lower = ends(interval.ln(iv(BETA)))[0]
    proposal = read(BASE / "proposal-probabilities.json")
    assert proposal["Inputs"] == state["Identity"]["Inputs"]
    logq = Q(proposal["Records"][0]["LogLower"])
    global_checks = read(PROFILES / "global-tail/checks.json")
    verify(global_checks["Sources"])
    assert global_checks["ChecksPassed"] and global_checks["AllJointEscapesCovered"]
    assert global_checks["Inputs"] == state["Identity"]["Inputs"]
    outside_upper = Q(global_checks["PValueUpperOutsideUnionOfBoxes"])
    assert outside_upper <= ALPHA-BETA
    # The common slope rectangle must contain every certified sample box.
    common = list(map(Q, state["Identity"]["CommonUpperSlopes"]))
    assert all(all(Q(bound) <= limit for bound, limit in zip(row["SlopesUpper"], common))
               for row in global_checks["Records"])
    global_summary = read(PROFILES / "global-tail/summary.json")
    verify(global_summary["Certificates"])
    global_record = read(PROFILES / "global-tail/replicate-01.json")
    entropy = Q(global_record["ConditionalLogLikelihoodUpper"])
    certificates = global_record["SlopeCertificates"]
    saved = {tuple(r["Box"]): r for r in old["Results"]}
    leaves = [("excluded", r["Box"], r["PValueUpper"]) for r in state["Excluded"]]
    leaves += [("pending", box, None) for box in state["Pending"]]
    leaves += [("unresolved", r["Box"], None) for r in state["Unresolved"]]
    assert len({tuple(box) for status, box, upper in leaves}) == len(leaves)
    assert set(saved) <= {tuple(box) for status, box, upper in leaves}
    rows = []
    for original, box, p_upper in leaves:
        row = {"OriginalStatus": original, "Box": box, "OldPValueUpper": p_upper}
        if p_upper is not None and Q(p_upper) <= ALPHA-BETA:
            row["Status"] = "reused_mc_bound"
        elif tuple(box) in saved and saved[tuple(box)]["ExcludedFromBetaRegion"]:
            row["Status"] = "reused_observed_bound"
            row["LogWeightUpper"] = saved[tuple(box)]["LogWeightUpper"]
        else:
            lower, unused = engine["bounds"](list(map(Q, box)))
            upper = engine["tail_upper"](entropy, certificates, lower, base)
            independent = decimal_tail(entropy, certificates, lower)
            upper = max(upper, independent)
            row["TailLogWeightUpper"] = str(upper-logq)
            row["Status"] = "observed_tail_bound" if upper-logq < beta_log_lower else "unresolved"
        rows.append(row)
    summary = dict(Counter(row["Status"] for row in rows))
    transitions = {status: dict(Counter(r["Status"] for r in rows if r["OriginalStatus"] == status))
                   for status in ("excluded", "pending", "unresolved")}
    result = {"Alpha": str(ALPHA), "Beta": str(BETA), "AdjustedCutoff": str(ALPHA-BETA),
              "ObservedReplicate": 1, "ContrastRay": "psi >= 21/4", "PartitionVerified": True,
              "OutsideCommonSlopeRectanglePValueUpper": str(outside_upper), "Summary": summary,
              "Transitions": transitions, "Rows": rows, "CheckpointChain": chain, "Sources": sources,
              "CompleteRightRayExclusion": not any(r["Status"] == "unresolved" for r in rows),
              "ConfidenceSetProduced": False, "NewFits": 0, "NewDatasets": 0, "NewIntegrals": 0,
              "NewSplits": 0, "HistoricalCheckpointChanged": False,
              "Scope": "Entire verified historical slope partition and its external slope tail, all location/step nuisance values. Reuses existing MC/observed bounds and adds only observed tail evaluations. Unresolved is a failed upper certificate, not proof of retention."}
    payload = json.dumps(result, indent=2, allow_nan=False) + "\n"
    if OUTPUT.exists():
        assert OUTPUT.read_text() == payload, "Existing domain evidence differs; preserve it"
    else:
        OUTPUT.write_text(payload)
    print(json.dumps({"Summary": summary, "Transitions": transitions,
                      "CompleteRightRayExclusion": result["CompleteRightRayExclusion"]}, indent=2))


if __name__ == "__main__":
    main()
