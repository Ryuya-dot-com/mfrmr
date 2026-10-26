"""Exact identification witness; no generated responses, fits or derivatives.

Two non-Person facets (2 Raters x 2 Criteria), four independent binary ratings.
GPCM slopes (2, 1/2) have geometric mean one. Location levels are
+/- 2 log(r) and +/- 2 log(d); abilities are 2 log(x).
All response probabilities below are rational. This is research evidence,
not a package estimator, a covariance API or numerical coverage validation.
"""
import hashlib
import itertools
import json
import math
from pathlib import Path
import platform
import sys

import sympy as sp

Q = sp.Rational
CELLS = list(itertools.product((1, -1), repeat=2))
PATTERNS = list(itertools.product((0, 1), repeat=4))
XS = list(map(Q, ("1/4", "1/3", "1/2", "2/3", "1", "3/2", "2", "3", "4")))
RATER = Q(6, 5)
D0 = Q(11, 10)
D_CANDIDATES = list(map(Q, ("1101/1000", "111/100", "6/5")))
TOTALS = [(y[0] + y[2], y[1] + y[3]) for y in PATTERNS]
KEYS = sorted(set(TOTALS))


def mass(x, d, unit_slopes=False):
    powers = [2 if unit_slopes else (4 if c == 1 else 1) for _, c in CELLS]
    odds = [(x / (RATER**r * d**c))**power
            for (r, c), power in zip(CELLS, powers)]
    return sp.Matrix([sp.prod((o if v else 1) / (1 + o)
                             for o, v in zip(odds, y)) for y in PATTERNS])


def total_mass(p):
    return sp.Matrix([sum(p[j] for j, s in enumerate(TOTALS) if s == key)
                      for key in KEYS])


def conditional(p, keys):
    return sp.Matrix([p[j] / sum(p[i] for i, key in enumerate(keys) if key == keys[j])
                      for j in range(len(PATTERNS))])


def run():
    w0 = sp.ones(9, 1) / 9
    p0 = sp.Matrix.hstack(*(mass(x, D0) for x in XS)) * w0
    assert sum(p0) == 1 and all(p > 0 for p in p0)
    candidates = []
    for d in D_CANDIDATES:
        columns = sp.Matrix.hstack(*(mass(x, d) for x in XS))
        matrix = sp.Matrix.hstack(*(total_mass(columns[:, j]) for j in range(9)))
        w = matrix.inv() * total_mass(p0)
        p1 = columns * w
        assert matrix * w == total_mass(p0)
        assert sum(w) == 1 and p1 == p0
        assert conditional(mass(Q(1), d), TOTALS) == conditional(mass(Q(1), D0), TOTALS)
        candidates.append({
            "d": str(d), "weights": [str(v) for v in w],
            "minimum_weight": float(min(w)), "maximum_weight": float(max(w)),
            "admissible_probability_distribution": bool(all(v > 0 for v in w)),
            "all_16_pattern_probabilities_equal_exactly": p1 == p0,
            "criterion_contrast": 4 * math.log(float(d)),
            "contrast_difference": 4 * math.log(float(d / D0)),
        })
    # The larger predeclared shifts give signed solutions, not probability laws.
    assert [c["admissible_probability_distribution"] for c in candidates] == [True, False, False]

    # Independent direct factorization check of all 16 rational probabilities.
    for x in XS:
        h = [sp.prod((RATER**(-r) * D0**(-c))**((4 if c == 1 else 1) * yj)
                     for (r, c), yj in zip(CELLS, y)) for y in PATTERNS]
        raw = sp.Matrix([v * x**(4 * s[0] + s[1]) for v, s in zip(h, TOTALS)])
        assert raw / sum(raw) == mass(x, D0)

    # Known-ability joint information is regular: no facet-design alias explains
    # the equivalence. These two structural coordinates are location half-contrasts.
    joint = sp.zeros(3)
    for r, c in CELLS:
        a = Q(2) if c == 1 else Q(1, 2)
        odds = (1 / (RATER**r * D0**c))**(2 * a)
        v = odds / (1 + odds)**2
        feature = sp.Matrix([a, -r * a, -c * a])
        joint += v * feature * feature.T
    schur = joint[1:, 1:] - joint[1:, :1] * joint[:1, 1:] / joint[0, 0]
    assert schur[0, 0] > 0 and schur.det() > 0

    # Positive control: unit-slope PCM conditioning on the scalar Person total
    # removes ability and retains both location contrasts in this full design.
    scalar_totals = [sum(y) for y in PATTERNS]
    unit_columns = sp.Matrix.hstack(*(mass(x, D0, True) for x in XS))
    p = unit_columns * w0
    unit_total_rank = sp.Matrix.hstack(*(total_mass(unit_columns[:, j]) for j in range(9))).rank()
    assert unit_total_rank == 5
    cp = conditional(mass(Q(1), D0, True), scalar_totals)
    for x in XS:
        assert conditional(mass(x, D0, True), scalar_totals) == cp
    features = sp.Matrix([[sum(r * yj for (r, _), yj in zip(CELLS, y)),
                           sum(c * yj for (_, c), yj in zip(CELLS, y))]
                          for y in PATTERNS])
    scores = features.copy()
    for j, total in enumerate(scalar_totals):
        ix = [i for i, s in enumerate(scalar_totals) if s == total]
        mean = sum((cp[i] * features[i, :] for i in ix), sp.zeros(1, 2))
        scores[j, :] = features[j, :] - mean
    for x in XS:
        assert mass(x, D0, True).T * scores == sp.zeros(1, 2)
    information = scores.T * sp.diag(*p) * scores
    assert information[0, 0] > 0 and information.det() > 0
    assert scores[0, :] == scores[15, :] == sp.zeros(1, 2)
    assert conditional(mass(Q(1), D_CANDIDATES[0], True), scalar_totals) != cp
    return {
        "scope": "Rater2 x Criterion2; 4 binary ratings per Person; complete crossing; independent conditional responses",
        "ability_x": [str(x) for x in XS], "ability_theta": [2 * math.log(float(x)) for x in XS],
        "baseline_weights": [str(v) for v in w0], "rater_factor": str(RATER),
        "baseline_criterion_factor": str(D0), "slopes": ["2", "1/2"],
        "baseline_criterion_contrast": 4 * math.log(float(D0)),
        "pattern_order": PATTERNS, "pattern_probabilities": [str(v) for v in p0],
        "candidates": candidates, "gpcm_joint_schur_positive_definite": True,
        "gpcm_joint_schur": [[str(v) for v in row] for row in schur.tolist()],
        "pcm_conditional_information_positive_definite": True,
        "pcm_owner_total_probability_rank": unit_total_rank,
        "pcm_conditional_information": [[str(v) for v in row] for row in information.tolist()],
        "checks": "Exact rational arithmetic; two larger signed-mixture attempts retained as inadmissible; no simulation or CI implementation",
    }


if __name__ == "__main__":
    result = run()
    result["source_sha256"] = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    result["python"] = platform.python_version()
    result["sympy"] = sp.__version__
    output = Path(sys.argv[1])
    output.parent.mkdir(parents=True, exist_ok=True)
    payload = json.dumps(result, ensure_ascii=False, indent=2) + "\n"
    if output.exists():
        assert output.read_text() == payload, "Existing evidence differs; preserve it"
    else:
        output.write_text(payload)
    print(json.dumps({"output": str(output), "candidates": [
        {k: c[k] for k in ("d", "minimum_weight", "admissible_probability_distribution", "contrast_difference")}
        for c in result["candidates"]], "exact_checks_passed": True}, indent=2))
