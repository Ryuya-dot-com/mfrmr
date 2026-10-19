"""Deterministic algebra checks for the GMFRM likelihood-bound gate.

No model fits, random responses or nuisance-domain search. The rational
example checks a two-family transfer; the normal example is a counterexample
to assuming a valid likelihood envelope gives contracting intervals.
"""
from fractions import Fraction as F
from itertools import product
from math import exp, isclose, log, sqrt
from pathlib import Path
import hashlib
import json


def entropy(q):
    assert min(q) >= 0 and sum(q) == 1
    return sum(float(v) * log(float(v)) for v in q if v)


# Two Persons, two Tasks and two Raters, with a three-category ladder.
# This is a fixed arithmetic fixture, not simulated or retained study data.
rows = list(product(range(2), repeat=3))  # Person, Task, Rater
y = [2 if p == 0 else 0 for p, t, r in rows]
a0, b0 = (F(2), F(1, 2)), (F(1), F(3))
s0 = [a0[t] * b0[r] for p, t, r in rows]
q0 = []
for (p, t, r), score, s in zip(rows, y, s0):
    q = [F(k == score) for k in range(3)]
    if p == t:  # Opposite transfers at the two Tasks, across Persons.
        q[score] -= F(1, 5) / s
        q[2-score] += F(1, 5) / s
    q0.append(q)


def coefficients(slopes, qs):
    # Locations: Task=(psi/2,-psi/2); both Rater locations are free.
    # Each Rater's steps=(h_r,-h_r). All nuisance coefficients must vanish.
    nuisance = [F(0)] * 4
    person = [F(0)] * 2
    target = F(0)
    for (p, t, r), score, s, q in zip(rows, y, slopes, qs):
        assert min(q) >= 0 and sum(q) == 1
        residual = score - sum(k*q[k] for k in range(3))
        person[p] += s * residual
        target -= s * residual * (F(1, 2) if t == 0 else F(-1, 2))
        nuisance[r] -= s * residual
        nuisance[2+r] -= s * (F(score == 1) - q[1])
    return nuisance, person, target


base_nuisance, base_person, base_target = coefficients(s0, q0)
assert base_nuisance == [0] * 4
assert base_person == [F(4, 5), F(-4, 5)] and base_target == F(-4, 5)

# A box in component slopes encloses each product. Ignoring correlations
# between cell products only enlarges the upper envelope.
lower = [F(1, 8)] * len(rows)
upper = [F(6)] * len(rows)
c = F(1, 10)


def transfer(slopes):
    return [[F(k == score) + c * old / new * (v-F(k == score))
             for k, v in enumerate(q)]
            for score, old, new, q in zip(y, s0, slopes, q0)]


lo_q, hi_q = transfer(lower), transfer(upper)
entropy_upper = sum(max(entropy(lo), entropy(hi)) for lo, hi in zip(lo_q, hi_q))
psi = F(2)
box_upper = entropy_upper + float(c*c*sum(g*g for g in base_person)/2
                                + c*base_target*psi)
assert box_upper < 0
box_checks = 0
for a1, b1, b2 in product((F(1, 2), F(1), F(2)),
                         (F(1, 4), F(1), F(2)),
                         (F(1, 2), F(1), F(3))):
    slopes = [(a1 if t == 0 else 1/a1) * (b1 if r == 0 else b2)
              for p, t, r in rows]
    assert all(lo <= s <= hi for lo, s, hi in zip(lower, slopes, upper))
    qs = transfer(slopes)
    nuisance, person, target = coefficients(slopes, qs)
    assert nuisance == [0]*4
    assert person == [c*g for g in base_person] and target == c*base_target
    point = sum(map(entropy, qs)) + float(sum(g*g for g in person)/2 + target*psi)
    assert point <= box_upper + 1e-12
    box_checks += 1

# Scaling both locations and free abilities by d, and second-family slopes
# by 1/d, leaves every conditional adjacent logit exactly unchanged.
locations = (F(3, 4), F(-3, 4))
raters = (F(1, 3), F(-2, 5))
steps = ((F(2, 7), F(-2, 7)), (F(-1, 4), F(1, 4)))
theta = (F(-3, 5), F(4, 5))
scale_checks = 0
for d in (F(1, 100), F(1), F(100)):
    assert a0[0]*a0[1] == 1
    for (p, t, r), s in zip(rows, s0):
        for k in range(2):
            original = s*(theta[p]-locations[t]-raters[r]-steps[r][k])
            changed = s/d*(d*theta[p]-d*locations[t]-d*raters[r]-d*steps[r][k])
            assert original == changed
            scale_checks += 1

# The same parameter path does NOT preserve the fixed-N(0,1) marginal law:
# keeping z fixed replaces theta by z/d, and tends to the independent law.
path_checks = 0
for d in (F(1, 100), F(1), F(100)):
    for (p, t, r), s in zip(rows, s0):
        for k in range(2):
            at_fixed_z = s/d*(theta[p]-d*locations[t]-d*raters[r]-d*steps[r][k])
            assert at_fixed_z == s*(theta[p]/d-locations[t]-raters[r]-steps[r][k])
            path_checks += 1

# Analytic integration control: Y_i | Z_i ~ N(mu+Z_i,1), Z_i ~ N(0,1).
# Dropping the integral's volume gives U(mu)=2^(m/2)*L(mu).
# For training mean a=0 and test mean b=0, exact single-split radius^2
# is 4*log(20)/m; the envelope adds 2*log(2), independently of m.
normal = []
for n in (20, 60, 240, 480):
    m = n//2
    exact_radius = sqrt(4*log(20)/m)
    upper_radius = sqrt(2*log(2) + 4*log(20)/m)
    for delta in (0., exact_radius, upper_radius):
        # Completing the square: mode z=(y-mu)/2, integrated variance=2.
        log_marginal = -m/2*log(4*3.141592653589793) - m*delta**2/4
        log_peak_bound = -m/2*log(2*3.141592653589793) - m*delta**2/4
        assert isclose(log_peak_bound-log_marginal, m/2*log(2), abs_tol=1e-12)
    boundary_log_e = m*upper_radius**2/4 - m/2*log(2)
    assert isclose(boundary_log_e, log(20), abs_tol=1e-12)
    normal.append(dict(N=n, held_out_persons=m, exact_radius=exact_radius,
                       peak_envelope_radius=upper_radius,
                       log_envelope_gap=m/2*log(2)))

sources = [Path(__file__), Path('inst/model-export/model-gmfrm.stan'),
           Path('R/core-gpcm-product-slopes.R'),
           Path('inst/validation/jml-normal-profile-dual-20261004.py')]
answer = dict(scope='Algebra controls only; no GMFRM coverage or full-domain certificate',
              source_sha256={str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in sources},
              rational_box_balance_checks=box_checks, box_log_upper_approximate=box_upper,
              conditional_scaling_checks=scale_checks, fixed_normal_path_checks=path_checks,
              normal_control=normal, asymptotic_envelope_radius=sqrt(2*log(2)))
path = Path('validation-results/gmfrm-split-likelihood-contract-20261013/bound-gate.json')
path.parent.mkdir(parents=True, exist_ok=True)
if path.exists():
    assert json.loads(path.read_text()) == answer, 'Saved evidence differs; do not overwrite.'
else:
    path.write_text(json.dumps(answer, indent=2)+'\n')
print(json.dumps({k: v for k, v in answer.items() if k != 'source_sha256'}, indent=2))
