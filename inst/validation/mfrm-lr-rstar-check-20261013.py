"""Independent matrix/coordinate checks of four retained r* evaluations."""
import csv
import hashlib
import json
from pathlib import Path

import numpy as np

out = Path("validation-results/mfrm-lr-rstar-20261013")


def ld(x):
    sign, value = np.linalg.slogdet(x)
    assert sign != 0 and np.isfinite(value)
    return value


def schur_q(I, S, Q, J, H):
    # Eliminate nuisance coordinates instead of forming the augmented determinant.
    A = S.T @ np.linalg.solve(I, J)
    b = Q @ np.linalg.solve(I, J)
    efficient = b[-1] - A[:-1, -1] @ np.linalg.solve(A[:-1, :-1].T, b[:-1])
    profile_information = 1 / np.linalg.solve(J, np.eye(len(J)))[-1, -1]
    u = efficient / np.sqrt(profile_information)
    nuisance = np.exp(ld(A[:-1, :-1]) - (ld(H) + ld(J[:-1, :-1])) / 2)
    return u * nuisance


records = list(csv.DictReader((out / "summary.csv").open()))
files = [Path(__file__), out / "summary.csv", out / "manifest.rds", out / "controls.rds"]
checks = []
for row in records:
    stem = f"case{row['Case']}-{row['Side']}-"
    mats = {}
    for name in ("I", "S", "Q", "J", "H"):
        path = out / f"{stem}{name}.csv"
        mats[name] = np.loadtxt(path, delimiter=",")
        files.append(path)
    I, S, Q, J, H = (mats[x] for x in ("I", "S", "Q", "J", "H"))
    r = float(row["R"])
    q = schur_q(I, S, Q, J, H)
    assert q / r > 0
    rs = r + np.log(q / r) / r
    error = abs(rs - float(row["Rstar"]))
    assert error < 1e-10

    # Two further checks: direct linear solve, and nuisance reparameterization.
    q_solve = np.linalg.solve(S, Q)[-1] * np.exp(ld(S) - ld(I) + (ld(J) - ld(H)) / 2)
    A = np.diag(np.linspace(.8, 1.5, len(H)))
    A += np.diag(np.full(len(H) - 1, .2), 1)
    B = np.eye(len(I)); B[:-1, :-1] = A
    q_basis = schur_q(B.T @ I @ B, B.T @ S @ B, B.T @ Q,
                     B.T @ J @ B, A.T @ H @ A)
    invariance_error = max(abs(q - q_solve), abs(q - q_basis))
    assert invariance_error < 1e-10
    checks.append(dict(case=int(row["Case"]), side=row["Side"], rstar=rs,
                       independent_error=error, coordinate_error=invariance_error,
                       cross_score_condition=float(np.linalg.cond(S))))

result = dict(checks=checks, passed=True, scope="Matrix identities only; no coverage inference",
              inputs={str(p): hashlib.md5(p.read_bytes()).hexdigest() for p in files},
              numpy=np.__version__)
(out / "independent-check.json").write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(dict(passed=True, checks=checks), indent=2))
