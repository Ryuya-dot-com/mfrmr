"""Replay every proposed exclusion using the original unfactored entropy.

The checker does not evaluate or trust the new chord tables. It reconstructs
the saved witnesses, checks exact transfer feasibility and recomputes all
selected complete-numerator terms with the previous Decimal transfer formula.
"""
from collections import Counter
from fractions import Fraction as Q
from pathlib import Path
import json
import runpy


def main():
    producer_path = Path("inst/validation/jml-shared-nuisance-reuse-20261012.py")
    producer = runpy.run_path(str(producer_path))
    helper = runpy.run_path(str(producer["HELPER"]))
    digest, local_path = helper["digest"], helper["local_path"]
    out = producer["OUT"]
    sources = {str(Path(__file__)): digest(__file__), str(producer_path): digest(producer_path)}

    def read(path):
        path = local_path(str(path))
        sources[str(path)] = digest(path)
        return json.loads(path.read_text())

    manifest = read(out/"manifest.json")
    manifest_hash = digest(out/"manifest.json")
    for name, expected in manifest["Sources"].items():
        assert digest(local_path(name)) == expected, f"Changed source: {name}"
    records = read(out/"certified.json")
    screen = read(out/"screen.json")
    nodes = read(out/"nodes.json")
    formula = read(out/"formula-checks.json")
    assert formula["SourceSHA256"] == digest(producer_path)
    assert len(formula["Cases"]) == 30 and all(r["DirectCategoricalEnclosureContained"] for r in formula["Cases"])
    assert records["CompletePass"] and len(records["Rows"]) == screen["Candidates"]
    assert records["ManifestSHA256"] == screen["ManifestSHA256"] == nodes["ManifestSHA256"] == manifest_hash
    assert [r["TargetIndex"] for r in records["Rows"]] == screen["CandidateIndices"]
    assert len(manifest["Targets"]) == screen["Screened"] == 2546
    assert len({tuple(r["Box"]) for r in manifest["Targets"]}) == 2546
    engine = runpy.run_path(str(helper["ENGINE"]))
    base = runpy.run_path(str(engine["BASE"]))
    dual = runpy.run_path(str(engine["DUAL"]))
    base["IV"].dps = 100
    samples, unused, inputs = base["read_inputs"](helper["ROOT"])
    prior_manifest = read(producer["PRIOR"]/"manifest.json")
    assert inputs == prior_manifest["Inputs"]
    proposal = read(helper["BASE"]/"proposal-probabilities.json")
    assert proposal["Inputs"] == inputs
    logq = {r["Replicate"]: Q(r["LogLower"]) for r in proposal["Records"]}
    logbeta = base["ends"](base["IV"].ln(base["iv"](Q(1, 200))))[0]
    seed = read(helper["MERGE"]/"jml-right-21over4.json")
    members = seed["Identity"]["IncludedReplicates"]
    registry, cache = manifest["Registry"], {}
    transferred = tails = 0
    results = []
    for record in records["Rows"]:
        index = record["TargetIndex"]
        assert record["Box"] == manifest["Targets"][index]["Box"]
        assert record["OriginalStatus"] == manifest["Targets"][index]["OriginalStatus"]
        assert [r["Replicate"] for r in record["Terms"]] == members
        assert len(record["Terms"]) == 30
        lower, upper = engine["bounds"](list(map(Q, record["Box"])))
        for term in record["Terms"]:
            replicate = term["Replicate"]
            if term["Entry"] < 0:
                global_ = read(helper["PROFILES"]/"global-tail"/f"replicate-{replicate:02d}.json")
                direct = engine["tail_upper"](Q(global_["ConditionalLogLikelihoodUpper"]),
                                               global_["SlopeCertificates"], lower, base)-logq[replicate]
                tails += 1
            else:
                entry = registry[term["Entry"]]
                assert entry["Replicate"] == replicate
                key = entry["Key"]
                if key not in cache:
                    kind, path = key.split(":", 1)
                    saved = read(path)
                    if kind == "joint":
                        sample = samples[0]+samples[replicate-1]
                        certificate = saved["JointCertificate"]
                    else:
                        assert kind == "separate"
                        sample, certificate = samples[replicate-1], saved
                    cache[key] = engine["witness"](sample, certificate, dual["design"])
                w = cache[key]
                assert w["H"] < 0
                feasible = min(lo/(a*m) for lo,a,m in zip(lower,w["a"],w["missing"]))
                cap = min(feasible, Q(entry["ProposalCap"]))
                choice = term["ScalarChoice"]
                fractions = list(map(Q, manifest["ScalarFractions"]))
                if choice < len(fractions):
                    scalar = cap*fractions[choice]
                else:
                    assert choice in (len(fractions), len(fractions)+1)
                    saved_scalar = Q(entry["SavedScalar"]) if choice == len(fractions) else Q(1)
                    scalar = min(cap*fractions[-1], saved_scalar)
                assert 0 <= scalar <= feasible
                unused, direct = helper["decimal_transfer"](w, lower, upper, scalar)
                direct -= logq[replicate]
                if entry["Kind"] == "joint":
                    direct -= logbeta+logq[1]
                transferred += 1
            assert direct <= Q(term["LogWeightUpper"]), (index, replicate, "Chord bound below direct enclosure")
        p = base["ends"](sum(base["IV"].exp(base["iv"](Q(t["LogWeightUpper"]))) for t in record["Terms"])/50)[1]
        assert p <= Q(record["PValueUpper"])
        assert record["Excluded"] == (Q(record["PValueUpper"]) <= Q(9, 200))
        results.append({"TargetIndex": index, "Excluded": record["Excluded"],
                        "All30TermsDirectlyReplayed": True, "MCUpperEnclosedIndependently": True})
        print(f"Independently checked complete numerator {len(results)}/{len(records['Rows'])}", flush=True)
    count = sum(r["Excluded"] for r in results)
    assert count == records["NewExclusions"]
    assert records["RemainingUnresolved"] == 2546-count and records["TotalSettled"] == 3045+count
    transitions = {status: sum(r["Excluded"] for r in records["Rows"] if r["OriginalStatus"] == status)
                   for status in ("excluded", "pending", "unresolved")}
    result = {"ChecksPassed": True, "Sources": sources, "ManifestSourcesVerified": len(manifest["Sources"]),
              "WholeNumeratorsChecked": len(results), "DirectTransferTerms": transferred, "DirectTailTerms": tails,
              "NewExclusions": count, "ExclusionsByHistoricalStatus": transitions,
              "RemainingUnresolved": 2546-count, "TotalSettled": 3045+count,
              "DistinctSavedWitnessesReconstructed": len(cache), "Results": results,
              "CompleteConfidenceSet": False, "NoNewOptimizationDuringChecks": True,
              "Scope": "Every candidate numerator replayed with original unfactored transfers and an independent MC-sum enclosure. Unscreened leaves remain uncertified; they are not retained-null witnesses."}
    payload = json.dumps(result, indent=2)+"\n"
    path = out/"checks.json"
    if path.exists():
        assert path.read_text() == payload
    else:
        path.write_text(payload)
    print(json.dumps({k:v for k,v in result.items() if k not in ("Sources", "Results")}, indent=2))


if __name__ == "__main__":
    main()
