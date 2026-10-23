"""Review a finite-sample nuisance restriction using saved exact enclosures.

Run from the package root. No fitting, simulation, quadrature, or nuisance
optimization. These are four full-parameter witnesses, not confidence sets.
The mathematical contract is in jml-inference-review-20260927.md, October 12.
"""
from collections import Counter
from fractions import Fraction
from pathlib import Path
import hashlib
import json


# Fixed before this diagnostic; neither constant is selected from its results.
ALPHA = Fraction(1, 20)
BETA = Fraction(1, 200)
ROOT = Path("validation-results/mfrm-wide-map-pcm-r50-portable-20261003/summary-n30/normal-mc-calibration")
DESTINATION = Path("validation-results/jml-nuisance-region-review-20261012/review.json")


def sha256(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def classify(lower, upper):
    assert 0 <= lower <= upper
    if upper < BETA:
        return "excluded"
    if lower >= BETA:
        return "inside"
    return "unresolved_included_in_outer_region"


def main():
    assert classify(BETA, BETA) == "inside"
    assert classify(BETA / 2, BETA) == "unresolved_included_in_outer_region"
    assert classify(BETA / 2, BETA * 2) == "unresolved_included_in_outer_region"
    assert classify(BETA / 4, BETA / 2) == "excluded"
    documents = {}
    bindings = {}
    for name in ("importance-audit.json", "failure-rule.json", "projection-gate.json"):
        path = ROOT / name
        data = json.loads(path.read_text())
        documents[name] = data
        bindings[str(path)] = sha256(path)
        for field in ("Sources", "Inputs"):
            for source, expected in data.get(field, {}).items():
                assert sha256(source) == expected, f"Changed historical input: {source}"
                assert source not in bindings or bindings[source] == expected
                bindings[source] = expected

    failure = documents["failure-rule.json"]
    projection = documents["projection-gate.json"]
    scales = {row["Scenario"]: row for row in projection["AbsoluteWeightScale"]}
    expected_scenarios = {"proposal", "criterion_minus_one", "criterion_zero",
                          "criterion_zero_unequal_slopes"}
    assert set(scales) == expected_scenarios
    expected_keys = {(scenario, i) for scenario in scales for i in range(1, 51)}
    weights = {}
    for row in failure["NormalizedWeightEnclosures"]:
        key = row["Scenario"], row["Replicate"]
        assert key not in weights
        scale = scales[row["Scenario"]]
        # Positive interval multiplication preserves the historical bounds.
        lower = Fraction(row["Lower"]) * Fraction(scale["WeightSumLower"])
        upper = Fraction(row["Upper"]) * Fraction(scale["WeightSumUpper"])
        if row["Scenario"] == "proposal":
            assert lower <= 1 <= upper  # P_theta = Q at this exact candidate.
        weights[key] = {"Scenario": key[0], "Replicate": key[1],
                        "WeightLower": str(lower), "WeightUpper": str(upper),
                        "RegionStatus": classify(lower, upper)}
    assert set(weights) == expected_keys

    rows = []
    seen = set()
    for row in projection["Results"]:
        key = row["Scenario"], row["Replicate"]
        arm_key = (*key, row["Arm"])
        assert arm_key not in seen
        seen.add(arm_key)
        lower, upper = Fraction(row["PValueLower"]), Fraction(row["PValueUpper"])
        assert 0 <= lower <= upper <= 1
        if row["ObservedFailed"]:
            assert lower == upper == 1
        # A lower bound at one certified interior point witnesses retention.
        # It cannot reject a contrast: other nuisance points remain untested.
        eligible = weights[key]["RegionStatus"] == "inside"
        witness = eligible and BETA + lower > ALPHA
        rows.append({"Scenario": key[0], "Replicate": key[1], "Arm": row["Arm"],
                     "ObservedFailed": row["ObservedFailed"],
                     "InsideRegionWitnessRetainsContrast": witness,
                     "RetainedByObservedFailurePolicy": row["ObservedFailed"],
                     "CompositeNullRejected": False})
    arms = sorted({row["Arm"] for row in rows})
    assert len(arms) == 4
    assert seen == {(*key, arm) for key in expected_keys for arm in arms}

    summary = []
    for scenario in scales:
        selected = [w for w in weights.values() if w["Scenario"] == scenario]
        counts = Counter(w["RegionStatus"] for w in selected)
        summary.append({"Scenario": scenario, "CandidatePoints": len(selected),
                        "Inside": counts["inside"], "Excluded": counts["excluded"],
                        "UnresolvedIncluded": counts["unresolved_included_in_outer_region"]})
    witnesses = []
    for scenario in scales:
        for arm in arms:
            selected = [r for r in rows if r["Scenario"] == scenario and r["Arm"] == arm]
            witnesses.append({"Scenario": scenario, "Arm": arm,
                              "InsideRegionWitnessRetains": sum(r["InsideRegionWitnessRetainsContrast"] for r in selected),
                              "ObservedFailureRetains": sum(r["RetainedByObservedFailurePolicy"] for r in selected)})

    result = {"Alpha": str(ALPHA), "Beta": str(BETA),
              "Proposal": documents["importance-audit.json"]["Proposal"],
              "FailureRule": failure["Rule"],
              "Summary": summary, "WitnessSummary": witnesses,
              "Weights": list(weights.values()), "Witnesses": rows,
              "Sources": {str(Path(__file__).resolve()): sha256(__file__), **bindings},
              "NewFits": 0, "NewDatasets": 0, "NewIntegrals": 0,
              "OtherNuisanceCoordinatesMaximized": False,
              "ConfidenceSetsProduced": 0, "IndependentCoverageExperiment": False,
              "Interpretation": "Point screening only. Excluding one nuisance point is not excluding a contrast. Saved leave-one-out tests are dependent development diagnostics; neither useful interval width nor faster global projection is established."}
    payload = json.dumps(result, indent=2, allow_nan=False) + "\n"
    DESTINATION.parent.mkdir(parents=True, exist_ok=True)
    if DESTINATION.exists():
        assert DESTINATION.read_text() == payload, "Existing evidence differs; preserve it"
    else:
        DESTINATION.write_text(payload)
    print(json.dumps({"Summary": summary, "WitnessSummary": witnesses,
                      "CheckedBindings": len(bindings), "Output": str(DESTINATION)}, indent=2))


if __name__ == "__main__":
    main()
