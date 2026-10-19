"""Bounded check of a joint observed/reference likelihood upper.

One median-width residual rectangle per historical status; all 30 MC terms.
Reuse the frozen Fenchel/normal-MGF engine on two independent Person blocks
sharing the nine structural nuisance coordinates. This is an auxiliary bound
calculation, not a JML refit, coverage experiment, or forest continuation.
"""
from fractions import Fraction as Q
from pathlib import Path
import json
import math
import os
import runpy
import sys


HELPER = Path("inst/validation/jml-nuisance-region-bounds-20261012.py")
DIRECTORY = Path("validation-results/jml-shared-nuisance-review-20261012")
REVIEW = Path("validation-results/jml-nuisance-region-review-20261012")


def main():
    helper = runpy.run_path(str(HELPER))
    digest, local_path = helper["digest"], helper["local_path"]
    sources = {}

    def bind(name, expected=None):
        path = local_path(str(name))
        actual = sources.get(str(path)) or digest(path)
        assert expected is None or expected == actual, f"Changed evidence: {name}"
        sources[str(path)] = actual
        return path

    def read(name):
        return json.loads(bind(name).read_text())

    bind(__file__); bind(HELPER)
    first = read(REVIEW / "domain-review.json")
    last = read(REVIEW / "domain-dual.json")
    check = read(REVIEW / "domain-checks.json")
    assert check["ChecksPassed"] and last["CompletePass"]
    for name, expected in last["Binding"]["Sources"].items():
        bind(name, expected)
    engine = runpy.run_path(str(bind(helper["ENGINE"])))
    base = runpy.run_path(str(bind(engine["BASE"])))
    dual = runpy.run_path(str(bind(engine["DUAL"])))
    base["IV"].dps = 60
    samples, unused, inputs = base["read_inputs"](helper["ROOT"])
    for name, expected in inputs.items():
        bind(name, expected)
    seed = read(helper["MERGE"] / "jml-right-21over4.json")
    identity = seed["Identity"]
    assert identity["Inputs"] == inputs
    members = identity["IncludedReplicates"]
    assert len(members) == 30 and 1 in members and identity["Denominator"] == 50
    proposal = read(helper["BASE"] / "proposal-probabilities.json")
    assert proposal["Inputs"] == inputs
    logq = {r["Replicate"]: Q(r["LogLower"]) for r in proposal["Records"]}
    logbeta = base["ends"](base["IV"].ln(base["iv"](helper["BETA"])))[0]

    original_rows_by_box = {tuple(r["Box"]): r for r in first["Rows"]}
    rows = dict(original_rows_by_box)
    rows.update({tuple(r["Box"]): r for r in last["Rows"]})
    selected = []
    for status in ("excluded", "pending", "unresolved"):
        group = [r for r in rows.values()
                 if r["Status"] == "unresolved" and r["OriginalStatus"] == status]

        def width(row):
            lower, upper = engine["bounds"](list(map(Q, row["Box"])))
            return max(math.log(float(b/a)) for a, b in zip(lower, upper))

        ordered = sorted(group, key=lambda r: (width(r), tuple(map(Q, r["Box"]))))
        row = ordered[len(ordered)//2]
        selected.append({"OriginalStatus": status, "Box": row["Box"],
                         "GroupSize": len(group), "SortedIndex": len(group)//2,
                         "MaximumLogSlopeWidth": width(row),
                         "HistoricalPValueUpper": original_rows_by_box[tuple(row["Box"])]["OldPValueUpper"]})

    manifest = read(identity["RetainedDualManifest"])
    assert manifest["Inputs"] == inputs
    inventory = dict(manifest["Certificates"])
    prior = read(REVIEW / "region-bounds.json")
    for name, expected in prior["Sources"].items():
        if Path(name).name.startswith("01-") and name.endswith(".json"):
            inventory[name] = expected
    records = {index: [] for index in members}
    for name, expected in inventory.items():
        record = json.loads(bind(name, expected).read_text())
        index = record.get("Replicate")
        if index not in records or "WitnessUnavailable" in record:
            continue
        assert record["Inputs"] == inputs
        if Q(record["AffineUpperSlope"]) < 0:
            records[index].append((name, record))
    assert all(records.values())
    globals_ = {index: read(helper["PROFILES"] / "global-tail" / f"replicate-{index:02d}.json")
                for index in members}

    # Inventory and selection are frozen before any new auxiliary optimization.
    binding = {"Sources": sources, "Inputs": inputs, "Selected": selected,
               "Python": sys.version,
               "Versions": {n: __import__(n).__version__ for n in ("numpy", "scipy", "mpmath")},
               "Threads": {n: os.environ.get(n) for n in
                           ("OPENBLAS_NUM_THREADS", "OMP_NUM_THREADS", "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")},
               "Recipe": "lambda=1; concatenate independent Person blocks; frozen certificate and transfer routines; no retries or subdivision"}
    DIRECTORY.mkdir(exist_ok=True)
    path = DIRECTORY / "manifest.json"
    payload = json.dumps(binding, indent=2) + "\n"
    if path.exists():
        assert path.read_text() == payload, "Changed review identity"
    else:
        path.write_text(payload)
    cache = {}

    def transfer(sample, record, key, lower, upper):
        if key not in cache:
            cache[key] = engine["witness"](sample, record, dual["design"])
        witness = cache[key]
        unused, scalar = engine["transfer_float"](witness, lower, upper, helper["PSI"])
        value = engine["transfer_upper"](witness, lower, upper, helper["PSI"], scalar, base)
        lo, hi = helper["decimal_transfer"](witness, lower, upper, scalar)
        assert lo <= value
        return max(value, hi), {"Scalar": str(scalar), "DecimalEnclosure": [str(lo), str(hi)]}

    summaries = []
    for region, target in enumerate(selected, 1):
        box = list(map(Q, target["Box"]))
        lower, upper = engine["bounds"](box)
        a1, a2 = [Q(math.sqrt(float(box[j]*box[j+2]))) for j in range(2)]
        slopes = [a1, a2, 1/(a1*a2)]
        assert all(lo <= a <= hi for lo, a, hi in zip(lower, slopes, upper))
        center = list(map(lambda a: math.log(float(a)), slopes))
        terms = []
        for index in members:
            output = DIRECTORY / f"region-{region}-reference-{index:02d}.json"
            if output.exists():
                row = json.loads(output.read_text())
                assert row["ManifestSHA256"] == digest(path)
                terms.append(row)
                continue
            sample = samples[index-1]
            name, record = min(records[index], key=lambda pair:
                               (max(abs(math.log(float(Q(a)))-b) for a,b in zip(pair[1]["Slopes"], center)), pair[0]))
            separate, details = transfer(sample, record, name, lower, upper)
            global_record = globals_[index]
            tail = engine["tail_upper"](Q(global_record["ConditionalLogLikelihoodUpper"]),
                                        global_record["SlopeCertificates"], lower, base)
            baseline = min(separate, tail)-logq[index]
            joint_sample = samples[0] + sample
            original_rows = dual["design"](sample, slopes)
            joint_rows = dual["design"](joint_sample, slopes)
            assert joint_rows[:180] == dual["design"](samples[0], slopes)
            assert [(p-30, y, a, h, D) for p,y,a,h,D in joint_rows[180:]] == original_rows
            row = {"ManifestSHA256": digest(path), "Region": region, "Replicate": index,
                   "SeparateWitness": name, "SeparateTransfer": details,
                   "BaselineLogWeightUpper": str(baseline),
                   "AuxiliaryDualOptimizations": 1, "NewJMLFits": 0}
            try:
                certificate = dual["certificate"](joint_sample, helper["PSI"], slopes, base)
                row["JointCertificate"] = certificate
                if Q(certificate["AffineUpperSlope"]) >= 0:
                    row["Unavailable"] = "Affine slope does not certify the right ray"
                else:
                    joint, detail = transfer(joint_sample, certificate, (region,index), lower, upper)
                    bound = joint-logbeta-logq[1]-logq[index]
                    row.update(JointLogWeightUpper=str(bound), JointTransfer=detail,
                               Improved=bound < baseline)
            except (AssertionError, StopIteration) as error:
                row["Unavailable"] = f"Exact auxiliary certificate unavailable: {type(error).__name__}: {error}"
            row["CombinedLogWeightUpper"] = str(min(baseline, Q(row.get("JointLogWeightUpper", str(baseline)))))
            output.write_text(json.dumps(row, indent=2, allow_nan=False)+"\n")
            terms.append(row)
            print(f"Region {region}, reference {index}: " +
                  (row["Unavailable"] if "Unavailable" in row else f"joint improvement {row['Improved']}"), flush=True)
        def p_upper(key):
            return base["ends"](sum(base["IV"].exp(base["iv"](Q(r[key]))) for r in terms)/50)[1]
        original, combined = p_upper("BaselineLogWeightUpper"), p_upper("CombinedLogWeightUpper")
        summary = {**target, "Region": region, "Terms": len(terms),
                   "ImprovedTerms": sum(r.get("Improved", False) for r in terms),
                   "UnavailableTerms": sum("Unavailable" in r for r in terms),
                   "BaselinePValueUpper": str(original), "CombinedPValueUpper": str(combined),
                   "ExclusionCertified": combined <= Q(9,200)}
        assert combined <= original
        summaries.append(summary)
        print(json.dumps({k:v for k,v in summary.items() if k not in ("Box", "BaselinePValueUpper", "CombinedPValueUpper")}), flush=True)
    result = {"ManifestSHA256": digest(path), "Regions": summaries,
              "AuxiliaryDualOptimizations": 90, "NewJMLFits": 0, "NewDatasets": 0,
              "NewIntegrals": 0, "NewSplits": 0, "CompleteConfidenceSet": False,
              "Scope": "Three fixed residual-region sentinels. Baseline uses qualified tail plus nearest retained dual, not every historical bound. A positive comparison alone cannot establish an improvement over the full historical engine or justify a campaign."}
    payload = json.dumps(result, indent=2, allow_nan=False)+"\n"
    output = DIRECTORY / "summary.json"
    if output.exists():
        assert output.read_text() == payload
    else:
        output.write_text(payload)


if __name__ == "__main__":
    main()
