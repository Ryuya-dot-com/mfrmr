"""Exact identification checks for the ordinary-JML bootstrap applicability review.

Rater 3 x Criterion 3, categories 0..3; Criterion owns steps and GPCM slopes.
Checks model algebra, not fitted data, coverage or the public implementation.
Run: python3 inst/validation/jml-bootstrap-identification-20261003.py
"""
import hashlib
import json
from pathlib import Path

import sympy as sp


def centered(values):
    return [*values, -sum(values)]


theta = sp.Symbol("theta")
b_free = sp.symbols("b1:3")
d_free = sp.symbols("d1:3")
t_free = sp.symbols("t11 t12 t21 t22 t31 t32")
g_free = sp.symbols("g1:3")
b, d, g = map(centered, (b_free, d_free, g_free))
tau = [centered(t_free[2 * c:2 * c + 2]) for c in range(3)]
linear = [theta, *b_free, *d_free, *t_free]
coordinates = [*linear, *g_free]


def logits(ability, raters, with_slopes):
    return sp.Matrix([
        (sp.exp(g[c]) if with_slopes else 1) *
        (ability - b[r] - d[c] - tau[c][k])
        for r in raters for c in range(3) for k in range(3)
    ])


def run():
    point = dict(zip(coordinates, map(sp.Rational, [
        "1/3", "-1", "0", "-1/2", "0",
        "-1", "0", "-1/2", "1/4", "-3/4", "1/4", "0", "0"
    ])))
    flat = {**point, b_free[0]: 0, b_free[1]: 0}
    cases = [
        ("PCM_complete", range(3), False, point, 11),
        ("PCM_paired", range(2), False, point, 10),
        ("GPCM_complete_nonflat_raters", range(3), True, point, 13),
        ("GPCM_paired_nonflat_raters", range(2), True, point, 12),
        ("GPCM_complete_flat_raters", range(3), True, flat, 11),
    ]
    ranks = []
    for name, raters, slopes, values, expected in cases:
        columns = coordinates if slopes else linear
        matrix = logits(theta, raters, slopes).jacobian(columns).subs(values)
        rank = matrix.rank()
        assert rank == expected, (name, rank, expected)
        ranks.append({"case": name, "rows": matrix.rows,
                      "coordinates_including_ability": matrix.cols,
                      "rank": rank})

    # The same flat-Rater structure can be identified across different Persons.
    theta2 = sp.Symbol("theta2")
    joint = logits(theta, range(3), True).col_join(logits(theta2, range(3), True))
    matrix = joint.jacobian([*coordinates, theta2]).subs({**flat, theta2: sp.Rational(4, 3)})
    assert matrix.rank() == 14
    ranks.append({"case": "GPCM_complete_flat_raters_two_distinct_abilities",
                  "rows": matrix.rows, "coordinates_including_ability": matrix.cols,
                  "rank": matrix.rank()})

    # Symbolic equivalence, with two freely varying positive scale multipliers.
    # No equal-slope restriction: a is arbitrary positive, subject to prod(a)=1.
    a1, a2, q1, q2 = sp.symbols("a1 a2 q1 q2", positive=True)
    a = [a1, a2, 1 / (a1 * a2)]
    q = [q1, q2, 1 / (q1 * q2)]
    transformed_theta = sum((theta - d[c]) / q[c] for c in range(3)) / 3
    transformed_d = [transformed_theta - (theta - d[c]) / q[c] for c in range(3)]
    assert sp.simplify(sum(transformed_d)) == 0
    assert sp.prod(a[c] * q[c] for c in range(3)) == 1
    for c in range(3):
        transformed_tau = [t / q[c] for t in tau[c]]
        assert sp.simplify(sum(transformed_tau)) == 0
        for k in range(3):
            old = a[c] * (theta - d[c] - tau[c][k])
            new = a[c] * q[c] * (transformed_theta - transformed_d[c] - transformed_tau[k])
            assert sp.simplify(new - old) == 0

    # The paired roster has a separate, exact missing-Rater location invariance.
    h = sp.Symbol("h")
    shifted = logits(theta, range(2), True).subs(
        {theta: theta + h, b_free[0]: b_free[0] + h, b_free[1]: b_free[1] + h},
        simultaneous=True)
    assert all(sp.simplify(v) == 0 for v in shifted - logits(theta, range(2), True))
    return {"model": "Rater3 x Criterion3; four categories; centered locations/steps/log-slopes",
            "exact_ranks": ranks, "symbolic_invariances_passed": True,
            "scope": "Identification algebra only; no generated responses, fitting or numerical differentiation"}


if __name__ == "__main__":
    result = run()
    result["source_sha256"] = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    result["sympy"] = sp.__version__
    print(json.dumps(result, indent=2))
