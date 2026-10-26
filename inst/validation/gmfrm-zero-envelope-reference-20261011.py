"""Literal transformed-parameter check, independent of the R logit rearrangement.

Run after gmfrm-zero-envelope-20261011.R run, before its verify action.
Uses existing mpmath; no fitting, quadrature, generation or package loading.
"""
import csv
from pathlib import Path
import mpmath as mp

mp.mp.dps = 100
root = Path("validation-results/gmfrm-zero-envelope-20261011")
counts = {}
with (root / "counts.csv").open() as f:
    for row in csv.DictReader(f):
        counts.setdefault(row["Case"], {})[int(row["Task"][1:]), int(row["Rater"][1:]), int(row["Category"])] = int(row["Count"])
parameters = {}
with (root / "parameters.csv").open() as f:
    for row in csv.DictReader(f):
        parameters.setdefault(row["Start"], {})[int(row["Coordinate"])] = mp.mpf(row["Value"])
rows = []
for case, count in counts.items():
    nll = mp.mpf(0)
    for i in range(1, 4):
        for r in range(1, 7):
            total = sum(count[i, r, k] for k in range(3))
            nll -= sum(n * mp.log(mp.mpf(n) / total) for k in range(3) if (n := count[i, r, k]) > 0)
    rows.append(("bound-" + case, mp.nstr(nll, 40), "0"))
for start, z in parameters.items():
    b = [z[1], z[2], -z[1] - z[2]]
    la = [z[15], z[16], -z[15] - z[16]]
    lr = [z[j] for j in range(17, 22)]
    lr.append(-sum(lr))
    old_h = [[z[3 + r] + z[9 + r], z[3 + r] - z[9 + r]] for r in range(6)]
    for label in ["0", "0.5", "1", "2", "4", "8", "Inf"]:
        # t=40 is a finite model approaching the R analytic limit. At t=20
        # it already agrees to 20 decimals; check both rather than importing
        # the R endpoint formula into this independent parameter calculation.
        values = []
        for t in ([mp.mpf(20), mp.mpf(40)] if label == "Inf" else [mp.mpf(label)]):
            log_a = [la[0] - t, la[1] - t, la[2] + 2*t]
            log_r = [lr[r] + (-5*t if r == 3 else t) for r in range(6)]
            h = [row[:] for row in old_h]
            for r in range(6):
                for k in range(2):
                    if r == 3:
                        h[r][k] = -b[2] + mp.exp(3*t)*(b[2] + old_h[r][k])
                    elif k == 0 or r in [0, 1]:
                        h[r][k] = -b[2] + mp.exp(-3*t)*(b[2] + old_h[r][k])
            severity = [sum(row)/2 for row in h]
            steps = [[v - severity[r] for v in row] for r, row in enumerate(h)]
            error = max(abs(sum(b)), abs(sum(log_a)), abs(sum(log_r)), *(abs(sum(row)) for row in steps))
            assert error < mp.mpf("1e-80")
            count = counts["N20-b09"]
            nll = mp.mpf(0)
            for i in range(3):
                for r in range(6):
                    weight = mp.exp(log_a[i] + log_r[r])
                    logits = [mp.mpf(0)]
                    for k in range(2):
                        logits.append(logits[-1] - weight*(b[i] + severity[r] + steps[r][k]))
                    peak = max(logits)
                    log_norm = peak + mp.log(sum(mp.exp(x - peak) for x in logits))
                    nll -= sum(count[i+1, r+1, k]*(logits[k] - log_norm) for k in range(3))
            values.append(nll)
        if label == "Inf":
            assert abs(values[1] - values[0]) < mp.mpf("1e-20")
        rows.append((start + "-" + label, mp.nstr(values[-1], 40), mp.nstr(error, 10)))
with (root / "reference.csv").open("x") as f:
    writer = csv.writer(f)
    writer.writerow(["Key", "NLL", "MaxConstraintError"])
    writer.writerows(rows)
print(f"{len(rows)} independent 100-digit likelihood references; mpmath {mp.__version__}.")
