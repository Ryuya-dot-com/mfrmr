"""Reuse the fixed joint certificates on every remaining slope rectangle.

Fixed scalar proposals and convex entropy chords replace repeated auxiliary
fits and repeated entropy evaluations. Floating screening never certifies an
exclusion. Used chord nodes receive directed Decimal enclosures; interpolation,
feasibility and slope transfers use rational arithmetic.
"""
from bisect import bisect_right
from collections import Counter
from decimal import Decimal, localcontext, ROUND_CEILING, ROUND_FLOOR
from fractions import Fraction as Q
from pathlib import Path
import json
import math
import os
import runpy
import sys

import numpy as np
from scipy.special import xlogy, logsumexp


HELPER = Path("inst/validation/jml-nuisance-region-bounds-20261012.py")
PRIOR = Path("validation-results/jml-shared-nuisance-review-20261012")
DOMAIN = Path("validation-results/jml-nuisance-region-review-20261012")
OUT = Path("validation-results/jml-shared-nuisance-reuse-20261012")
GRID = sorted({Q(j, 16) for j in range(17)} |
              {v for k in range(5, 13) for v in (Q(1, 2**k), 1-Q(1, 2**k))})
FRACTIONS = [Q(1, 8), Q(1, 4), Q(1, 2), Q(3, 4), Q(999999, 1000000)]
PSI, BETA, CUTOFF = Q(21, 4), Q(1, 200), Q(9, 200)


def rational_decimal(value, direction):
    with localcontext() as context:
        context.prec = 80
        context.rounding = direction
        return Decimal(value.numerator)/Decimal(value.denominator)


def xlog_interval(value):
    if value in (0, 1):
        return Decimal(0), Decimal(0)
    assert 0 < value < 1
    lo = rational_decimal(value, ROUND_FLOOR)
    hi = rational_decimal(value, ROUND_CEILING)
    with localcontext() as context:
        context.prec = 80
        loglo, loghi = lo.ln().next_minus(), hi.ln().next_plus()
        context.rounding = ROUND_FLOOR
        lower = hi*loglo
        context.rounding = ROUND_CEILING
        upper = (lo if loghi <= 0 else hi)*loghi
    return lower, upper


def entropy_constants(witness, owner):
    maximum = witness["missing"][owner]
    ratios, coefficients = [], []
    for i in range(owner, len(witness["q"]), 3):
        q, y = witness["q"][i], witness["y"][i]
        missing = 1-q[y]
        ratios.append(missing/maximum)
        coefficients.extend((q[k]/maximum, q[k]/missing) for k in range(4) if k != y)
    with localcontext() as context:
        context.prec = 80
        lo = hi = Decimal(0)
        for weight, probability in coefficients:
            a = rational_decimal(probability, ROUND_FLOOR).ln().next_minus()
            b = rational_decimal(probability, ROUND_CEILING).ln().next_plus()
            context.rounding = ROUND_FLOOR
            lo += rational_decimal(weight, ROUND_CEILING)*a
            context.rounding = ROUND_CEILING
            hi += rational_decimal(weight, ROUND_FLOOR if b <= 0 else ROUND_CEILING)*b
    return ratios, (Q(lo), min(Q(0), Q(hi)))


def node_enclosure(ratios, constant, node):
    with localcontext() as context:
        context.prec = 80
        lo = rational_decimal(node*constant[0], ROUND_FLOOR)
        hi = rational_decimal(node*constant[1], ROUND_CEILING)
        for ratio in ratios:
            for probability in (node*ratio, 1-node*ratio):
                a, b = xlog_interval(probability)
                context.rounding = ROUND_FLOOR
                lo += a
                context.rounding = ROUND_CEILING
                hi += b
    return Q(lo), min(Q(0), Q(hi))


def rounded_upper(value):
    scale = 10**30
    return Q(math.ceil(value*scale), scale)


def forbidden(*args, **kwargs):
    raise AssertionError("No auxiliary optimization is allowed in this reuse pass")


def main():
    import scipy.optimize
    scipy.optimize.minimize = scipy.optimize.minimize_scalar = forbidden
    helper = runpy.run_path(str(HELPER))
    digest, local_path = helper["digest"], helper["local_path"]
    sources = {}

    def bind(name, expected=None):
        path = local_path(str(name))
        actual = sources.get(str(path)) or digest(path)
        assert expected is None or actual == expected, f"Changed evidence: {name}"
        sources[str(path)] = actual
        return path

    def read(name):
        return json.loads(bind(name).read_text())

    bind(__file__); bind(HELPER)
    manifest = read(PRIOR/"manifest.json")
    checks = read(PRIOR/"checks.json")
    assert checks["ChecksPassed"] and checks["RawJointCertificatesChecked"] == 90
    for mapping in (manifest["Sources"], checks["Sources"]):
        for name, expected in mapping.items():
            bind(name, expected)
    first, last = read(DOMAIN/"domain-review.json"), read(DOMAIN/"domain-dual.json")
    previous = read(PRIOR/"summary.json")
    leaves = {tuple(r["Box"]): r for r in first["Rows"]}
    leaves.update({tuple(r["Box"]): r for r in last["Rows"]})
    for row in previous["Regions"]:
        if row["ExclusionCertified"]:
            leaves[tuple(row["Box"])] = {**row, "Status": "already_shared_excluded"}
    targets = [r for r in leaves.values() if r["Status"] == "unresolved"]
    assert len(leaves) == 5591 and len(targets) == 2546
    engine = runpy.run_path(str(bind(helper["ENGINE"])))
    base = runpy.run_path(str(bind(engine["BASE"])))
    dual = runpy.run_path(str(bind(engine["DUAL"])))
    domain_engine = runpy.run_path(str(bind("inst/validation/jml-nuisance-domain-review-20261012.py")))
    base["IV"].dps = 60
    samples, unused, inputs = base["read_inputs"](helper["ROOT"])
    assert inputs == manifest["Inputs"]
    proposal = read(helper["BASE"]/"proposal-probabilities.json")
    assert proposal["Inputs"] == inputs
    logq = {r["Replicate"]: Q(r["LogLower"]) for r in proposal["Records"]}
    logbeta = base["ends"](base["IV"].ln(base["iv"](BETA)))[0]
    seed = read(helper["MERGE"]/"jml-right-21over4.json")
    members = seed["Identity"]["IncludedReplicates"]
    assert len(members) == 30 and seed["Identity"]["Denominator"] == 50
    globals_ = {i: read(helper["PROFILES"]/"global-tail"/f"replicate-{i:02d}.json") for i in members}

    witnesses, registry, witness_paths = {}, [], {}
    for region in range(1, 4):
        for index in members:
            term_path = PRIOR/f"region-{region}-reference-{index:02d}.json"
            term = read(term_path)
            for kind, name, record, scalar in (
                ("joint", str(term_path), term["JointCertificate"], term["JointTransfer"]["Scalar"]),
                ("separate", term["SeparateWitness"], read(term["SeparateWitness"]), term["SeparateTransfer"]["Scalar"]),
            ):
                key = kind+":"+name
                if key not in witnesses:
                    sample = samples[0]+samples[index-1] if kind == "joint" else samples[index-1]
                    witnesses[key] = engine["witness"](sample, record, dual["design"])
                    witness_paths[key] = name
                w = witnesses[key]
                assert w["H"] < 0
                S, b = float(w["S"]), float(w["H"]*PSI)
                radius = math.sqrt(b*b+2*S*len(w["y"])*math.log(4))
                cap = Q((radius-b)/S) if S > 0 else Q(10**100)
                registry.append({"Key": key, "Kind": kind, "Replicate": index,
                                 "SavedScalar": scalar, "ProposalCap": str(cap)})
    OUT.mkdir(exist_ok=True)
    binding = {"Sources": sources, "Registry": registry,
               "Targets": [{"Box": r["Box"], "OriginalStatus": r["OriginalStatus"]} for r in targets],
               "Grid": list(map(str, GRID)), "ScalarFractions": list(map(str, FRACTIONS)),
               "Cutoff": str(CUTOFF), "ScreeningThreshold": .05, "Beta": str(BETA),
               "Python": sys.version, "Versions": {n: __import__(n).__version__ for n in ("numpy", "scipy", "mpmath")},
               "Threads": {n: os.environ.get(n) for n in ("OPENBLAS_NUM_THREADS", "OMP_NUM_THREADS", "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")}}
    path = OUT/"manifest.json"
    payload = json.dumps(binding, indent=2)+"\n"
    if path.exists():
        assert path.read_text() == payload, "Changed reuse identity"
    else:
        path.write_text(payload)
    manifest_hash = digest(path)
    boundaries = [engine["bounds"](list(map(Q, r["Box"]))) for r in targets]
    lower, upper = (np.array([pair[j] for pair in boundaries], float) for j in (0, 1))
    n = len(targets)
    best, selections = np.empty((n, 30)), np.full((n, 30, 2), -1, dtype=int)
    for j, index in enumerate(members):
        record = globals_[index]
        entropy = float(Q(record["ConditionalLogLikelihoodUpper"]))
        values = np.full(n, entropy)
        for owner, cert in enumerate(record["SlopeCertificates"]):
            power = float(Q(cert["Power"]))
            candidate = np.full(n, (1-power)*entropy)
            for positive, negative in cert["OppositeOrientationCounts"]:
                total, minimum = positive+negative, min(positive, negative)
                if minimum:
                    candidate += np.minimum(0, total*np.log(2*total/(5*minimum*lower[:, owner]*power))-total+2*minimum)
            values = np.minimum(values, candidate)
        best[:, j] = values-float(logq[index])
    curves = {}
    for number, entry in enumerate(registry):
        key, index = entry["Key"], entry["Replicate"]
        w = witnesses[key]
        if key not in curves:
            curves[key] = []
            for owner in range(3):
                maximum = w["missing"][owner]
                ratios, constant = [], 0.
                for i in range(owner, len(w["q"]), 3):
                    q, y = w["q"][i], w["y"][i]
                    missing = 1-q[y]
                    ratios.append(float(missing/maximum))
                    constant += sum(float(q[k]/maximum)*math.log(float(q[k]/missing)) for k in range(4) if k != y)
                u = np.array(GRID, float)[:, None]*np.array(ratios)[None, :]
                curves[key].append((xlogy(u, u)+xlogy(1-u, 1-u)).sum(axis=1)+np.array(GRID, float)*constant)
        cap = np.minimum(np.min(lower/(np.array(w["a"], float)*np.array(w["missing"], float)), axis=1), float(Q(entry["ProposalCap"])))
        scalars = np.column_stack([cap*float(f) for f in FRACTIONS] +
                                 [np.minimum(cap*float(FRACTIONS[-1]), float(Q(entry["SavedScalar"]))),
                                  np.minimum(cap*float(FRACTIONS[-1]), 1.)])
        entropy = np.zeros_like(scalars)
        for owner in range(3):
            endpoints = []
            for limits in (lower, upper):
                s = scalars*float(w["a"][owner]*w["missing"][owner])/limits[:, owner, None]
                endpoints.append(np.interp(np.clip(s, 0, 1), np.array(GRID, float), curves[key][owner]))
            entropy += np.maximum(*endpoints)
        values = np.minimum(0, entropy+scalars*scalars*float(w["S"])/2+scalars*float(w["H"]*PSI))
        values -= float(logq[index])
        if entry["Kind"] == "joint":
            values -= float(logbeta+logq[1])
        choice = np.argmin(values, axis=1)
        value = values[np.arange(n), choice]
        j = members.index(index)
        improved = value < best[:, j]
        best[improved, j] = value[improved]
        selections[improved, j, 0] = number
        selections[improved, j, 1] = choice[improved]
    approximate = logsumexp(best, axis=1)-math.log(50)
    candidates = np.flatnonzero(approximate <= math.log(.05)).tolist()
    screen = {"ManifestSHA256": manifest_hash, "CandidateIndices": candidates,
              "ApproximateLogPUpper": approximate.tolist(), "Selections": selections.tolist(),
              "Screened": n, "Candidates": len(candidates), "FloatingScreenOnly": True}
    (OUT/"screen.json").write_text(json.dumps(screen, indent=2, allow_nan=False)+"\n")
    print(f"Screened all {n} residual rectangles; {len(candidates)} complete-numerator candidates; {len(witnesses)} distinct saved witnesses", flush=True)
    node_cache, constants = {}, {}
    if (OUT/"nodes.json").exists():
        saved = json.loads((OUT/"nodes.json").read_text())
        assert saved["ManifestSHA256"] == manifest_hash
        node_cache = saved["Nodes"]
    checked = []
    if (OUT/"certified.json").exists():
        saved = json.loads((OUT/"certified.json").read_text())
        assert saved["ManifestSHA256"] == manifest_hash
        checked = saved["Rows"]
        assert [r["TargetIndex"] for r in checked] == candidates[:len(checked)]

    def node(key, owner, grid_index):
        label = f"{key}|{owner}|{grid_index}"
        if label not in node_cache:
            if (key, owner) not in constants:
                constants[key, owner] = entropy_constants(witnesses[key], owner)
            ratios, constant = constants[key, owner]
            node_cache[label] = list(map(str, node_enclosure(ratios, constant, GRID[grid_index])))
        return Q(node_cache[label][1])

    def chord(key, owner, s):
        assert 0 <= s <= 1
        if s == 0:
            return Q(0)
        left = min(bisect_right(GRID, s)-1, len(GRID)-2)
        t = (s-GRID[left])/(GRID[left+1]-GRID[left])
        return (1-t)*node(key, owner, left)+t*node(key, owner, left+1)

    def save(complete=False):
        for name, value in (
            ("nodes.json", {"ManifestSHA256": manifest_hash, "Nodes": node_cache}),
            ("certified.json", {"ManifestSHA256": manifest_hash, "Rows": checked,
                                "CompletePass": complete, "Screened": n, "Candidates": len(candidates),
                                "NewExclusions": sum(r["Excluded"] for r in checked),
                                "RemainingUnresolved": n-sum(r["Excluded"] for r in checked),
                                "TotalSettled": 3045+sum(r["Excluded"] for r in checked),
                                "NewAuxiliaryOptimizations": 0, "NewFits": 0, "NewDatasets": 0,
                                "NewIntegrals": 0, "NewSplits": 0, "ConfidenceSetProduced": False}),
        ):
            temporary = OUT/(name+".tmp")
            temporary.write_text(json.dumps(value, indent=2, allow_nan=False)+"\n")
            temporary.replace(OUT/name)

    for target_index in candidates[len(checked):]:
        lo, hi = boundaries[target_index]
        terms = []
        for j, index in enumerate(members):
            entry_index, scalar_choice = selections[target_index, j]
            if entry_index < 0:
                record = globals_[index]
                entropy = Q(record["ConditionalLogLikelihoodUpper"])
                value = max(engine["tail_upper"](entropy, record["SlopeCertificates"], lo, base),
                            domain_engine["decimal_tail"](entropy, record["SlopeCertificates"], lo))
                weight = value-logq[index]
            else:
                entry = registry[entry_index]
                key, w = entry["Key"], witnesses[entry["Key"]]
                cap = min([Q(entry["ProposalCap"])]+[a/(b*m) for a,b,m in zip(lo,w["a"],w["missing"])])
                scalar = (cap*FRACTIONS[scalar_choice] if scalar_choice < len(FRACTIONS) else
                          min(cap*FRACTIONS[-1], Q(entry["SavedScalar"]) if scalar_choice == len(FRACTIONS) else Q(1)))
                assert 0 <= scalar <= min(a/(b*m) for a,b,m in zip(lo,w["a"],w["missing"]))
                entropy = sum(max(chord(key, owner, scalar*w["a"][owner]*w["missing"][owner]/limit)
                                  for limit in (lo[owner], hi[owner])) for owner in range(3))
                value = min(Q(0), entropy+scalar*scalar*w["S"]/2+scalar*w["H"]*PSI)
                weight = value-logq[index]-(logbeta+logq[1] if entry["Kind"] == "joint" else 0)
            terms.append({"Replicate": index, "Entry": int(entry_index), "ScalarChoice": int(scalar_choice),
                          "LogWeightUpper": str(rounded_upper(weight))})
        with localcontext() as context:
            context.prec = 80
            context.rounding = ROUND_CEILING
            p_upper = sum(rational_decimal(Q(r["LogWeightUpper"]), ROUND_CEILING).exp().next_plus() for r in terms)/50
        checked.append({"TargetIndex": target_index, "Box": targets[target_index]["Box"],
                        "OriginalStatus": targets[target_index]["OriginalStatus"],
                        "Terms": terms, "PValueUpper": str(p_upper), "Excluded": Q(p_upper) <= CUTOFF})
        if len(checked) % 20 == 0:
            save()
            print(f"Certified {len(checked)}/{len(candidates)} candidates; {sum(r['Excluded'] for r in checked)} exclusions; {len(node_cache)} cached entropy nodes", flush=True)
    save(complete=True)
    print(json.dumps({"Screened": n, "Candidates": len(candidates), "NewExclusions": sum(r["Excluded"] for r in checked),
                      "Remaining": n-sum(r["Excluded"] for r in checked), "EntropyNodes": len(node_cache)}), flush=True)


if __name__ == "__main__":
    main()
