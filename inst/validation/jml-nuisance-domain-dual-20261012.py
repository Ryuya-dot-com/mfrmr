"""One nonadaptive observation-bound pass over the entire residual domain.

Three nearest saved witnesses propose feasible scalars; certify one proposal
per remaining rectangle. Reuse the 120 already evaluated rectangles. No
splitting, new dual fitting, quadrature, or changes to the historical forest.
"""
from collections import Counter
from fractions import Fraction as Q
from pathlib import Path
import json
import math
import runpy
import sys


HELPER = Path("inst/validation/jml-nuisance-region-bounds-20261012.py")
helper = runpy.run_path(str(HELPER))
digest, local_path = helper["digest"], helper["local_path"]
DIRECTORY = Path("validation-results/jml-nuisance-region-review-20261012")
DOMAIN = DIRECTORY / "domain-review.json"
OUTPUT = DIRECTORY / "domain-dual.json"


def main():
    domain = json.loads(DOMAIN.read_text())
    prior_path = helper["DESTINATION"]
    prior = json.loads(prior_path.read_text())
    sources = {str(DOMAIN): digest(DOMAIN), str(prior_path): digest(prior_path),
               str(HELPER): digest(HELPER), str(Path(__file__)): digest(__file__)}
    for name, expected in domain["Sources"].items():
        path = local_path(name)
        actual = digest(path)
        assert actual == expected, f"Changed evidence: {name}"
        sources[str(path)] = actual
    assert domain["PartitionVerified"] and domain["Beta"] == str(helper["BETA"])
    engine = runpy.run_path(str(helper["ENGINE"]))
    base = runpy.run_path(str(engine["BASE"]))
    dual = runpy.run_path(str(engine["DUAL"]))
    base["IV"].dps = 60
    samples, unused, inputs = base["read_inputs"](helper["ROOT"])
    proposal = json.loads((helper["BASE"] / "proposal-probabilities.json").read_text())
    assert proposal["Inputs"] == inputs
    sample = samples[0]
    logq = Q(proposal["Records"][0]["LogLower"])
    beta_log_lower = base["ends"](base["IV"].ln(base["iv"](helper["BETA"])))[0]
    # The complete candidate inventory is taken from the already bound review,
    # not from an expanding live directory or a new fitting allocation.
    records = []
    for name in prior["Sources"]:
        if not Path(name).name.startswith("01-") or not name.endswith(".json"):
            continue
        record = json.loads(local_path(name).read_text())
        assert record["Inputs"] == inputs and record["Replicate"] == 1
        if "WitnessUnavailable" in record or Q(record["AffineUpperSlope"]) >= 0:
            continue
        assert record["DualFeasibilityExact"] and record["AllLocationAndStepNuisanceCovered"]
        slopes = list(map(Q, record["Slopes"]))
        assert min(slopes) > 0 and math.prod(slopes) == 1
        records.append((name, record, [math.log(float(a)) for a in slopes]))
    assert len(records) == prior["Summary"]["SavedWitnessCandidates"] == 236
    old_bounds = {tuple(r["Box"]): r for r in prior["Results"]}
    targets = [r for r in domain["Rows"] if r["Status"] == "unresolved"]
    assert len(targets) == 3091
    binding = {"Sources": sources, "Python": sys.version,
               "Versions": {name: __import__(name).__version__ for name in ("numpy", "scipy", "mpmath")},
               "Recipe": "Three nearest stored dual witnesses; lowest floating proposal certified once; all prior bounds reused; no subdivision."}
    rows = []
    if OUTPUT.exists():
        previous = json.loads(OUTPUT.read_text())
        assert previous["Binding"] == binding, "Changed continuation identity"
        rows = previous["Rows"]
        assert [r["Box"] for r in rows] == [r["Box"] for r in targets[:len(rows)]]
    cache = {}

    def save():
        summary = dict(Counter(r["Status"] for r in rows))
        complete = len(rows) == len(targets)
        payload = {"Binding": binding, "Alpha": domain["Alpha"], "Beta": domain["Beta"],
                   "ContrastRay": domain["ContrastRay"], "ObservedReplicate": 1,
                   "TargetRegions": len(targets), "CompletePass": complete,
                   "Summary": summary, "Rows": rows,
                   "CompleteRightRayExclusion": complete and not any(r["Status"] == "unresolved" for r in rows),
                   "ConfidenceSetProduced": False, "NewFits": 0, "NewDatasets": 0,
                   "NewIntegrals": 0, "NewSplits": 0, "HistoricalQueueChanged": False,
                   "Scope": "One fixed observation-bound procedure on every residual leaf of the preserved partition. An unsettled upper is not a retained-null witness or evidence that more computation must be allocated."}
        text = json.dumps(payload, indent=2, allow_nan=False) + "\n"
        temporary = OUTPUT.with_suffix(".tmp")
        temporary.write_text(text)
        temporary.replace(OUTPUT)
        print(f"Checked {len(rows)}/{len(targets)} residual regions: {summary}", flush=True)

    for target in targets[len(rows):]:
        row = {"Box": target["Box"], "OriginalStatus": target["OriginalStatus"]}
        previous = old_bounds.get(tuple(row["Box"]))
        if previous:
            assert not previous["ExcludedFromBetaRegion"]
            row.update(Status="unresolved", ReusedPriorEvaluation=True,
                       LogWeightUpper=previous["LogWeightUpper"])
        else:
            lower, upper = engine["bounds"](list(map(Q, row["Box"])))
            center = [(math.log(float(a))+math.log(float(b)))/2 for a, b in zip(lower, upper)]
            nearby = sorted(records, key=lambda item: (max(abs(a-b) for a, b in zip(item[2], center)), item[0]))[:3]
            candidates = []
            for name, record, unused in nearby:
                if name not in cache:
                    cache[name] = engine["witness"](sample, record, dual["design"])
                witness = cache[name]
                assert witness["H"] < 0
                approximate, scalar = engine["transfer_float"](witness, lower, upper, helper["PSI"])
                candidates.append((approximate, name, scalar))
            unused, name, scalar = min(candidates)
            witness = cache[name]
            bound = engine["transfer_upper"](witness, lower, upper, helper["PSI"], scalar, base)
            # Only exclusions need independent numerical certification; a failed
            # upper remains unknown and is never a claim of nonrejection.
            if bound-logq < beta_log_lower:
                lo, hi = helper["decimal_transfer"](witness, lower, upper, scalar)
                assert lo <= bound
                bound = max(bound, hi)
                row["IndependentDecimalEnclosure"] = [str(lo), str(hi)]
            row.update(Status="observed_dual_bound" if bound-logq < beta_log_lower else "unresolved",
                       ReusedPriorEvaluation=False, LogWeightUpper=str(bound-logq),
                       Witness=name, Scalar=str(scalar))
        rows.append(row)
        if len(rows) % 100 == 0:
            save()
    save()


if __name__ == "__main__":
    main()
