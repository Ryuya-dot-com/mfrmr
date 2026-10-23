"""Check observed-likelihood bounds on 120 retained unresolved slope regions.

Reuses the qualified dual transfer; no response generation, model fitting,
quadrature, forest continuation, or changes to historical queues. Three
nearby saved dual witnesses per box are a fixed feasibility allocation, not
an exhaustive search for the best bound or a complete confidence set.
"""
from fractions import Fraction
from pathlib import Path
from decimal import Decimal, localcontext, ROUND_FLOOR, ROUND_CEILING
import hashlib
import json
import math
import runpy
import sys


ROOT = Path("validation-results/mfrm-wide-map-pcm-r50-portable-20261003/summary-n30")
BASE = ROOT / "normal-mc-calibration"
PROFILES = BASE / "profiles"
SELECTION = PROFILES / "normal-rescale/right-21over4-v13-new-gap-review/selection.json"
MERGE = PROFILES / "normal-rescale/right-v12-third-child-merge-20261007"
ENGINE = PROFILES / "slope-cover-observed-01-right-21over4-v13/source.py"
DESTINATION = Path("validation-results/jml-nuisance-region-review-20261012/region-bounds.json")
ALPHA, BETA, PSI = Fraction(1, 20), Fraction(1, 200), Fraction(21, 4)
NEAREST = 3


def local_path(name):
    # Relocations require the original hash; no numerical source is repaired.
    if name == "/private/tmp/mfrmr-d1-inference-20261004/right-v12-third-child-merge.py":
        return ENGINE.parent / "right-v12-third-child-merge.py"
    if name == "/private/tmp/mfrmr-d1-inference-20261004/prepare-right-21over4.py":
        return PROFILES / "slope-cover-observed-01-right-21over4-v1/prepare-right-21over4.py"
    for prefix in (
        "/Users/ryuya/Library/CloudStorage/Dropbox/MFRM_Application/mfrmr/development/",
        "/Users/tohokusla/Dropbox/MFRM_Application/mfrmr/development/",
    ):
        if name.startswith(prefix):
            return Path(name[len(prefix):])
    return Path(name)


def digest(path):
    with Path(path).open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def decimal_transfer(witness, lower, upper, scalar):
    """Independent directed Decimal enclosure of the retained dual formula."""
    def rational(value, rounding):
        with localcontext() as context:
            context.rounding = rounding
            return Decimal(value.numerator) / Decimal(value.denominator)

    with localcontext() as context:
        context.prec = 80
        totals = []
        for owner in range(3):
            endpoint_bounds = []
            for limit in (lower[owner], upper[owner]):
                factor = scalar * witness["a"][owner] / limit
                lo, hi = Decimal(0), Decimal(0)
                for index in range(owner, len(witness["q"]), 3):
                    original = witness["q"][index]
                    probabilities = [Fraction(k == witness["y"][index]) + factor *
                                     (p - Fraction(k == witness["y"][index]))
                                     for k, p in enumerate(original)]
                    assert min(probabilities) >= 0 and sum(probabilities) == 1
                    for p in probabilities:
                        if not p or p == 1:
                            continue
                        a, b = rational(p, ROUND_FLOOR), rational(p, ROUND_CEILING)
                        # Decimal.ln is correctly rounded; neighboring values
                        # enclose it. Logs are negative, so product endpoints
                        # reverse the probability factors.
                        log_a, log_b = a.ln().next_minus(), b.ln().next_plus()
                        context.rounding = ROUND_FLOOR
                        lo += b * log_a
                        context.rounding = ROUND_CEILING
                        hi += a * log_b
                endpoint_bounds.append((lo, hi))
            totals.append((max(x[0] for x in endpoint_bounds), max(x[1] for x in endpoint_bounds)))
        exact = scalar * scalar * witness["S"] / 2 + scalar * witness["H"] * PSI
        context.rounding = ROUND_FLOOR
        lo = min(Decimal(0), sum(x[0] for x in totals) + rational(exact, ROUND_FLOOR))
        context.rounding = ROUND_CEILING
        hi = min(Decimal(0), sum(x[1] for x in totals) + rational(exact, ROUND_CEILING))
        assert lo <= hi
        return Fraction(lo), Fraction(hi)


def main():
    bindings = {}

    def verify(mapping):
        for name, expected in mapping.items():
            path = local_path(name)
            actual = bindings.get(str(path)) or digest(path)
            assert actual == expected, f"Changed historical evidence: {name}"
            bindings[str(path)] = actual

    def read(path):
        path = local_path(str(path))
        bindings[str(path)] = digest(path)
        return json.loads(path.read_text())

    selection = read(SELECTION)
    identity = selection["Identity"]
    verify(identity["Sources"])
    verify(identity["Inputs"])
    verify({str(MERGE / "jml-right-21over4.json"): selection["CapturedCheckpointSHA256"]})
    merged = read(MERGE / "check.json")
    verify(merged["Sources"])
    assert merged["ChecksPassed"] and merged["PartitionPreserved"]
    assert merged["FinalExclusions"] == 1130 and merged["FinalUnresolved"] == 472
    assert identity["Observed"] == 1 and Fraction(identity["Contrast"]) == PSI
    selected = selection["Selected"]
    assert len(selected) == 120 and len({tuple(r["Parent"]["Box"]) for r in selected}) == 120

    bindings[str(ENGINE)] = digest(ENGINE)
    engine = runpy.run_path(str(ENGINE))
    for path in (engine["BASE"], engine["DUAL"], engine["PROFILE_REGIONS"], engine["NORMAL_RESCALE_PATH"]):
        assert str(path) in bindings, f"Numerical dependency not bound: {path}"
    base = runpy.run_path(str(engine["BASE"]))
    dual = runpy.run_path(str(engine["DUAL"]))
    base["IV"].dps = 60
    samples, unused, inputs = base["read_inputs"](ROOT)
    assert inputs == identity["Inputs"]
    sample = samples[0]
    proposal = read(BASE / "proposal-probabilities.json")
    verify(proposal["Sources"])
    assert proposal["Inputs"] == inputs and proposal["Records"][0]["Replicate"] == 1
    logq = Fraction(proposal["Records"][0]["LogLower"])
    iv, ends, interval = base["iv"], base["ends"], base["IV"]
    log_beta_lower = ends(interval.ln(iv(BETA)))[0]
    log_alpha_lower = ends(interval.ln(iv(ALPHA)))[0]

    manifest = read(identity["RetainedDualManifest"])
    verify(manifest["Sources"])
    assert manifest["Inputs"] == inputs
    candidates = dict(manifest["Certificates"])
    # Include certificates explicitly bound by the stopped historical state.
    for name, expected in identity["Sources"].items():
        if "/adaptive-duals/01-" in name:
            candidates[name] = expected
    # Also inventory the existing observed-data witnesses; bind them to this
    # review without pretending they were all used in the earlier seed.
    adaptive = local_path(identity["AdaptiveDualDirectory"])
    for path in sorted(adaptive.glob("01-*.json")):
        candidates.setdefault(str(path), digest(path))
    records = []
    for name, expected in candidates.items():
        if not Path(name).name.startswith("01-"):
            continue
        verify({name: expected})
        record = read(name)
        verify(record["Sources"])
        assert record["Inputs"] == inputs and record["Replicate"] == 1
        if "WitnessUnavailable" in record or Fraction(record["AffineUpperSlope"]) >= 0:
            continue
        assert record["DualFeasibilityExact"] and record["AllLocationAndStepNuisanceCovered"]
        slopes = list(map(Fraction, record["Slopes"]))
        assert min(slopes) > 0 and math.prod(slopes) == 1
        records.append((name, record, [math.log(float(a)) for a in slopes]))
    assert len(records) >= NEAREST
    reconstructed = {}
    results = []
    for index, row in enumerate(selected):
        box = list(map(Fraction, row["Parent"]["Box"]))
        lower, upper = engine["bounds"](box)
        mid = [(math.log(float(a)) + math.log(float(b))) / 2 for a, b in zip(lower, upper)]
        nearby = sorted(records, key=lambda item: (max(abs(a-b) for a, b in zip(item[2], mid)), item[0]))[:NEAREST]
        best = None
        for name, record, unused in nearby:
            if name not in reconstructed:
                reconstructed[name] = engine["witness"](sample, record, dual["design"])
            witness = reconstructed[name]
            assert witness["H"] < 0  # Extends the bound over the full right ray.
            # Scalar optimization only chooses a feasible dual certificate.
            # Exact feasibility and outward arithmetic, not optimizer success,
            # establish the upper bound over all structural nuisance values.
            unused, scalar = engine["transfer_float"](witness, lower, upper, PSI)
            upper_ll = engine["transfer_upper"](witness, lower, upper, PSI, scalar, base)
            candidate = (upper_ll, name, scalar)
            if best is None or candidate < best:
                best = candidate
        upper_ll, name, scalar = best
        decimal_lower, decimal_upper = decimal_transfer(reconstructed[name], lower, upper, scalar)
        assert decimal_lower <= upper_ll, "Interval engine returned an upper below independent enclosure"
        upper_ll = max(upper_ll, decimal_upper)
        log_weight_upper = upper_ll - logq
        results.append({"ParentIndex": row["ParentIndex"], "Box": list(map(str, box)),
                        "LogLikelihoodUpper": str(upper_ll), "LogWeightUpper": str(log_weight_upper),
                        "Witness": name, "Scalar": str(scalar),
                        "IndependentDecimalEnclosure": [str(decimal_lower), str(decimal_upper)],
                        "ExcludedFromBetaRegion": log_weight_upper < log_beta_lower,
                        "ExcludedFromDirectAlphaRegion": log_weight_upper < log_alpha_lower})
        if (index + 1) % 20 == 0:
            print(f"Observed-only bounds: {index + 1}/{len(selected)} regions", flush=True)

    summary = {"Regions": len(results),
               "ExcludedFromBetaRegion": sum(r["ExcludedFromBetaRegion"] for r in results),
               "ExcludedFromDirectAlphaRegion": sum(r["ExcludedFromDirectAlphaRegion"] for r in results),
               "SavedWitnessCandidates": len(records), "ReconstructedWitnesses": len(reconstructed)}
    assert all(not r["ExcludedFromBetaRegion"] or r["ExcludedFromDirectAlphaRegion"] for r in results)
    result = {"Alpha": str(ALPHA), "Beta": str(BETA), "ContrastRay": "psi >= 21/4",
              "ObservedReplicate": 1, "NearestSavedWitnessesPerRegion": NEAREST,
              "Scope": "All 120 previously selected unresolved regions of a verified historical seed. Product-one positive slopes in each stored box; all location and step nuisance parameters. No claim for the remaining pending/unresolved domain.",
              "Summary": summary, "Results": results,
              "Sources": {str(Path(__file__)): digest(__file__), **bindings},
              "Python": sys.version,
              "NumericalVersions": {name: __import__(name).__version__ for name in ("numpy", "scipy", "mpmath")},
              "IndependentDecimalBoundsChecked": len(results),
              "NewFits": 0, "NewDatasets": 0, "NewIntegrals": 0,
              "GlobalConfidenceSetProduced": False, "IndependentCoverageExperiment": False,
              "HistoricalQueueChanged": False,
              "Interpretation": "Certified region bounds, not point screening. An unresolved upper bound is not a retention witness. Supremum certification over the whole nuisance domain and useful confidence sets remain unestablished."}
    payload = json.dumps(result, indent=2, allow_nan=False) + "\n"
    DESTINATION.parent.mkdir(parents=True, exist_ok=True)
    if DESTINATION.exists():
        assert DESTINATION.read_text() == payload, "Saved review differs; preserve it"
    else:
        DESTINATION.write_text(payload)
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
