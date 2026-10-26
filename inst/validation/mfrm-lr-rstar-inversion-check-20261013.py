"""Independent Schur-complement evaluation at the retained interval endpoints."""
import hashlib
import json
from pathlib import Path
import numpy as np

root = Path("validation-results/mfrm-lr-rstar-inversion-20261013")
path = root / "independent-input.json"


def ld(x):
    sign, value = np.linalg.slogdet(x)
    assert sign != 0 and np.isfinite(value)
    return value


checks = []
for row in json.loads(path.read_text()):
    I, S, Q, J, H = (np.asarray(row[name]) for name in ("I", "S", "Q", "J", "H"))
    A = S.T @ np.linalg.solve(I, J)
    b = Q @ np.linalg.solve(I, J)
    efficient = b[-1] - A[:-1, -1] @ np.linalg.solve(A[:-1, :-1].T, b[:-1])
    profile_information = 1 / np.linalg.inv(J)[-1, -1]
    q = efficient / np.sqrt(profile_information) * np.exp(
        ld(A[:-1, :-1]) - (ld(H) + ld(J[:-1, :-1])) / 2)
    r = row["r"]
    assert q / r > 0
    rstar = r + np.log(q / r) / r
    error = abs(rstar - row["rstar"])
    assert error < 1e-10
    checks.append(dict(case=row["case"], side=row["side"], rstar=rstar, error=error))

files = [path, Path(__file__), root / "inversion-review.rds"]
result = dict(passed=True, checks=checks, numpy=np.__version__,
              files={str(p): hashlib.md5(p.read_bytes()).hexdigest() for p in files})
(root / "independent-check.json").write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
