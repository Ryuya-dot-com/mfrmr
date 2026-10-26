"""Independent fixed-point roundoff diagnosis, never an optimizer or public API.

Compares ordinary float64, 50-digit kernels on rounded float64 nodes, and
50-digit kernels on locally reconstructed nodes. Model coefficients and
Legendre rules are the same retained doubles in every calculation.
"""
import hashlib
import json
from pathlib import Path
import sys
import time

import mpmath as mp
import numpy as np

mp.mp.dps = 50
source = Path(sys.argv[1])
data = json.loads(source.read_text())
model = data["model"]


def calculate(person, rule, method):
    rows = [i - 1 for i in person["rows"]]
    ng, nb = model["ng"], model["nb"]
    p = nb + ng
    convert = mp.mpf if method != "float64" else float
    exp = mp.exp if method != "float64" else np.exp
    log = mp.log if method != "float64" else np.log
    log2pi = log(2 * mp.pi) if method != "float64" else np.log(2 * np.pi)
    peak = convert(person["high"]["log_marginal"])  # any common log scale works
    cuts = person["cuts"]
    mass = convert(0)
    total = [convert(0) for _ in range(p)]
    terms = []
    for row in rows:
        a = convert(model["a"][row])
        off = [convert(v) for v in model["offset"][row]]
        y = model["score"][row]
        delta = [[(j, convert(model["D"][y][row][j] - model["D"][k][row][j]))
                  for j in range(nb) if model["D"][y][row][j] != model["D"][k][row][j]]
                 for k in range(3)]
        z = [(j, convert(v)) for j, v in enumerate(model["Z"][row]) if v]
        terms.append((a, off, y, delta, z))
    for lo, hi in zip(cuts[:-1], cuts[1:]):
        width = convert(hi) - convert(lo)
        for q, qw in zip(rule["nodes"], rule["weights"]):
            theta = (convert(float(lo + (hi - lo) * q)) if method == "rounded_nodes"
                     else convert(lo) + width * convert(q))
            lj = -(theta * theta + log2pi) / 2
            score = [convert(0) for _ in range(p)]
            for a, off, y, delta, z in terms:
                logits = [a * (k * theta - off[k]) for k in range(3)]
                high = max(logits)
                weights = [exp(v - high) for v in logits]
                denominator = sum(weights)
                pr = [v / denominator for v in weights]
                lj += logits[y] - high - log(denominator)
                residual = sum(pr[k] * (y - k) for k in range(3))
                for k in range(3):
                    for j, d in delta[k]:
                        score[j] -= a * pr[k] * d
                log_residual = a * (theta * residual - sum(pr[k] * (off[y] - off[k]) for k in range(3)))
                for j, v in z:
                    score[nb + j] += log_residual * v
            w = width * convert(qw) * exp(lj - peak)
            mass += w
            for j in range(p):
                total[j] += w * score[j]
    return {"log_marginal": float(peak + log(mass)), "score": [float(v / mass) for v in total]}


result = {"input_md5": hashlib.md5(source.read_bytes()).hexdigest(),
          "source_md5": hashlib.md5(Path(__file__).read_bytes()).hexdigest(),
          "mpmath_version": mp.__version__, "digits": mp.mp.dps, "points": []}
destination = source.with_name("roundoff-output.json")
for person_id in data["selected"]:
    person = data["people"][person_id - 1]
    for method in ["float64", "rounded_nodes", "local_nodes"]:
        for rule in data["rules"][:3]:
            started = time.monotonic()
            value = calculate(person, rule, method)
            result["points"].append(dict(person=person_id, method=method, order=len(rule["nodes"]),
                                         seconds=time.monotonic() - started, **value))
            destination.write_text(json.dumps(result, indent=2))
            print(person_id, method, len(rule["nodes"]), flush=True)
