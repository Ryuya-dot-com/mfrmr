"""Independent continuous-normal PCM score/observed-information reference.

Read the four saved R designs via JSON; no simulation or fitting. Complete-data
derivatives hold theta fixed. A change to standard-normal integration coordinates
does not change that differentiation convention (Louis information identity).
"""
import hashlib
import json
import sys
from pathlib import Path

import numpy as np
import scipy
from scipy.integrate import quad_vec
from scipy.special import logsumexp


def design(data):
    rows = np.asarray(data["rows"], dtype=int)
    x = np.asarray(data["x"], dtype=float)
    assert rows.shape[1] == 4 and np.all(np.isfinite(x))
    assert np.all((rows[:, 1:3] >= 0) & (rows[:, 1:3] < 3))
    assert np.all((rows[:, 3] >= 0) & (rows[:, 3] < 4))
    contrast = np.array([[1., 0.], [0., 1.], [-1., -1.]])
    cumulative = np.array([[0., 0.], [1., 0.], [1., 1.], [0., 0.]])
    d = np.zeros((len(rows), 4, 10))
    for j, (_, rater, criterion, _) in enumerate(rows):
        d[j, :, :2] = -np.outer(np.arange(4), contrast[rater])
        d[j, :, 2:4] = -np.outer(np.arange(4), contrast[criterion])
        d[j, :, 4+2*criterion:6+2*criterion] = -cumulative
    groups = [np.flatnonzero(rows[:, 0] == i) for i in range(len(x))]
    assert all(len(ix) == 6 for ix in groups)
    return {"d": d, "y": rows[:, 3], "x": x, "groups": groups}


def person_integral(problem, par, person):
    ix = problem["groups"][person]
    d, y = problem["d"][ix], problem["y"][ix]
    x = np.array([1., problem["x"][person]])
    mu = x @ par[10:12]
    variance, sd = np.exp(par[12]), np.exp(par[12]/2)
    base = d @ par[:10] + np.arange(4)*mu
    observed = d[np.arange(len(ix)), y].sum(axis=0)
    logp0 = np.sum(base[np.arange(len(ix)), y]-logsumexp(base, axis=1))

    def kernel(z):
        logits = base + np.arange(4)*sd*z
        logp = logits-logsumexp(logits, axis=1)[:, None]
        logweight = np.sum(logp[np.arange(len(ix)), y])-logp0-z*z/2-np.log(2*np.pi)/2
        if logweight < -740:
            return np.zeros(183)
        p = np.exp(logp)
        mean_d = np.einsum("jk,jkp->jp", p, d)
        centered = ((d-mean_d[:, None, :])*np.sqrt(p)[:, :, None]).reshape(-1, 10)
        score = np.zeros(13)
        score[:10] = observed-mean_d.sum(axis=0)
        score[10:12] = x*z/sd
        score[12] = (z*z-1)/2
        info = np.zeros((13, 13))
        info[:10, :10] = centered.T @ centered
        info[10:12, 10:12] = np.outer(x, x)/variance
        info[10:12, 12] = info[12, 10:12] = x*z/sd
        info[12, 12] = z*z/2
        return np.exp(logweight)*np.concatenate(([1.], score, (info-np.outer(score, score)).ravel()))

    moments, error, details = quad_vec(kernel, -np.inf, np.inf,
        epsabs=1e-13, epsrel=1e-12, norm="max", full_output=True)
    assert details.success, (person, details.message, error)
    mass = moments[0]
    assert np.isfinite(mass) and mass > error >= 0
    score = moments[1:14]/mass
    information = moments[14:].reshape(13, 13)/mass+np.outer(score, score)
    assert np.all(np.isfinite(information))
    return {"log_probability": float(logp0+np.log(mass)), "score": score.tolist(),
        "information": information.tolist(), "relative_error_estimate": float(error/mass),
        "evaluations": int(details.neval)}


def derivative_check(problem, par, person, reference):
    records = []
    for step in (1e-4, 5e-5):
        gradient = np.empty(13)
        hessian = np.empty((13, 13))
        for j in range(13):
            plus, minus = par.copy(), par.copy()
            plus[j] += step
            minus[j] -= step
            a = person_integral(problem, plus, person)
            b = person_integral(problem, minus, person)
            gradient[j] = (a["log_probability"]-b["log_probability"])/(2*step)
            hessian[:, j] = -(np.array(a["score"])-np.array(b["score"]))/ (2*step)
        records.append({"step": step,
            "gradient_error": float(np.max(np.abs(gradient-reference["score"]))),
            "information_error": float(np.max(np.abs(hessian-reference["information"])))})
    assert records[-1]["gradient_error"] < 1e-7
    assert records[-1]["information_error"] < 1e-6
    return {"person_index": int(person), "rows": records}


def main(input_path, output_path):
    data = json.loads(input_path.read_text())
    problem = design(data)
    par = np.asarray(data["par"], dtype=float)
    assert par.shape == (13,) and np.all(np.isfinite(par))
    persons = [person_integral(problem, par, i) for i in range(len(problem["x"]))]
    check = None
    if data["check_derivatives"]:
        i = int(np.argmax(np.abs(problem["x"])))
        check = derivative_check(problem, par, i, persons[i])
    score = np.sum([p["score"] for p in persons], axis=0)
    information = np.sum([p["information"] for p in persons], axis=0)
    result = {"value": -sum(p["log_probability"] for p in persons),
        "gradient": (-score).tolist(), "hessian": information.tolist(),
        "persons": persons, "derivative_check": check,
        "runtime": {"python": sys.version, "numpy": np.__version__, "scipy": scipy.__version__},
        "input_sha256": hashlib.sha256(input_path.read_bytes()).hexdigest(),
        "source_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}
    output_path.write_text(json.dumps(result, allow_nan=False))


if __name__ == "__main__":
    main(Path(sys.argv[1]), Path(sys.argv[2]))
