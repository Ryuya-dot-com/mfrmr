"""Certified location-score mean envelopes on the existing 2x2 GPCM witness.

Exact rational profile brackets, stochastic rounded kernels with explicit
error bounds, and rational Bernstein subdivision cover all real abilities.
This evaluates one structural parameter point; it does not invert a full
GPCM confidence set or qualify a public covariance/interval API.
"""
from fractions import Fraction as Q
from pathlib import Path
import hashlib
import json
import math
import runpy
import sys

HERE = Path(__file__).parent
WITNESS = HERE / 'jml-fixed-exposure-identification-20261003.py'
INTERVALS = HERE / 'jml-pcm-conditional-intervals-20261003.py'
witness = runpy.run_path(str(WITNESS))
log_bounds = runpy.run_path(str(INTERVALS))['log_bounds']
cells, patterns = witness['CELLS'], witness['PATTERNS']
power = [4 if c == 1 else 1 for r, c in cells]
ability_total = [sum(v * y for v, y in zip(power, pattern)) for pattern in patterns]
GRID = 2**60


def marginals(x):
    odds = [(x / (Q(6, 5)**r * Q(11, 10)**c))**v for (r, c), v in zip(cells, power)]
    return [o / (1 + o) for o in odds]


def mass(p):
    return [math.prod(v if y else 1 - v for v, y in zip(p, pattern)) for pattern in patterns]


def profile(total):
    mean = lambda x: sum(v * p for v, p in zip(power, marginals(x)))
    lo = hi = Q(1)
    while mean(lo) > total:
        lo /= 2
    while mean(hi) < total:
        hi *= 2
    while hi - lo > lo / 2**50:
        mid = (lo + hi) / 2
        if mean(mid) < total:
            lo = mid
        else:
            hi = mid
    assert mean(lo) <= total <= mean(hi)
    return lo, hi


def split(coef):
    levels = [coef]
    while len(levels[-1]) > 1:
        old = levels[-1]
        levels.append([(a + b) / 2 for a, b in zip(old, old[1:])])
    return [v[0] for v in levels], [v[-1] for v in reversed(levels)]


def leaf(a, b):
    assert all(isinstance(v, Q) for v in a + b), 'Certificate coefficients must remain rational'
    assert all(v >= 0 for v in b)
    assert all(x == 0 for x, y in zip(a, b) if y == 0)
    ratios = [x / y for x, y in zip(a, b) if y > 0]
    midpoint = split(a)[0][-1] / split(b)[0][-1]
    points = [a[0] / b[0], midpoint, a[-1] / b[-1]]
    return min(ratios), max(ratios), min(points), max(points), a, b


def envelope(a, b, tolerance=Q(1, 10**6)):
    leaves = [leaf(a, b)]
    while True:
        lower = min(v[0] for v in leaves); upper = max(v[1] for v in leaves)
        min_point = min(v[2] for v in leaves); max_point = max(v[3] for v in leaves)
        if max(min_point - lower, upper - max_point) <= tolerance:
            return lower, upper, min_point, max_point, len(leaves)
        index = (min(range(len(leaves)), key=lambda j: leaves[j][0])
                 if min_point - lower >= upper - max_point
                 else max(range(len(leaves)), key=lambda j: leaves[j][1]))
        old = leaves.pop(index)
        a0, a1 = split(old[4]); b0, b1 = split(old[5])
        leaves.extend((leaf(a0, b0), leaf(a1, b1)))


def sqrt_upper(q):
    n = math.isqrt(q.numerator * GRID**2 // q.denominator)
    return Q(n + 1, GRID)


def run():
    # Pattern/transition row order is shared with the exact equivalence witness.
    brackets = {t: profile(t) for t in sorted(set(ability_total)) if t not in (0, 10)}
    P, U = [], []
    profile_error = kernel_error = Q(0)
    for i, (y, t) in enumerate(zip(patterns, ability_total)):
        if t in (0, 10):
            P.append([GRID if j == i else 0 for j in range(16)]); U.append([0, 0])
            continue
        lo, hi = brackets[t]; mid = (lo + hi) / 2
        p = marginals(mid); lower, upper = marginals(lo), marginals(hi)
        pm = mass(p)
        independent = witness['mass'](witness['Q'](mid.numerator, mid.denominator), witness['D0'])
        assert pm == [Q(int(v.p), int(v.q)) for v in independent] and sum(pm) == 1
        row = [v.numerator * GRID // v.denominator for v in pm]
        row[max(range(16), key=lambda j: pm[j])] += GRID - sum(row)
        assert sum(row) == GRID and min(row) >= 0
        P.append(row)
        raw = [sum(Q(v, 2) * sign * (yj - pj)
                   for v, (r, c), yj, pj, sign in zip(power, cells, y, p, [rc[j] for rc in cells]))
               for j in (0, 1)]
        U.append([v.numerator * GRID // v.denominator for v in raw])
        profile_error = max(profile_error, sum(Q(v, 2) * (b - a) for v, a, b in zip(power, lower, upper)) + Q(1, GRID))
        # L1 distance of product Bernoulli laws <= 2 sum marginal distances.
        kernel_error = max(kernel_error, 2 * sum(b - a for a, b in zip(lower, upper)) + Q(30, GRID))
    U0_norm = [max(abs(Q(row[j], GRID)) for row in U) for j in (0, 1)]
    base_h = [math.prod((Q(6, 5)**(-r) * Q(11, 10)**(-c))**(v * yj)
                        for (r, c), v, yj in zip(cells, power, y)) for y in patterns]
    denominator = [sum((h for h, t in zip(base_h, ability_total) if t == j), Q(0)) / math.comb(10, j) for j in range(11)]
    results = []
    for k in range(5):
        if k in (0, 2, 4):
            for j, name in enumerate(('Rater location', 'Criterion location')):
                score = [Q(row[j], GRID**(k + 1)) for row in U]
                error = 2**k * profile_error + (k * 2**(k - 1) * kernel_error * U0_norm[j] if k else 0)
                numerator = [sum((h * u for h, u, t in zip(base_h, score, ability_total) if t == index), Q(0)) / math.comb(10, index)
                             for index in range(11)]
                lower, upper, min_point, max_point, leaves = envelope(numerator, denominator)
                mean_lower, mean_upper = lower - error, upper + error
                raw_lower, raw_upper = min(score) - error, max(score) + error
                assert mean_lower <= 0 <= mean_upper
                by_n = []
                for n in (20, 30, 40, 60, 120, 240, 480):
                    # Two prespecified location components, alpha=.05, hence log(80).
                    epsilon = (raw_upper - raw_lower) * sqrt_upper(log_bounds(Q(80))[1] / (2 * n))
                    always = mean_lower - epsilon <= raw_lower and mean_upper + epsilon >= raw_upper
                    excluded = min(score) + error < mean_lower - epsilon or max(score) - error > mean_upper + epsilon
                    by_n.append({'N': n, 'EpsilonUpper': float(epsilon),
                                 'EveryResponseDatasetAccepted': always,
                                 'ConstantPatternExclusionCertified': excluded})
                results.append({'Order': k, 'Coordinate': name,
                    'RawLower': float(raw_lower), 'RawUpper': float(raw_upper),
                    'MeanLower': float(mean_lower), 'MeanUpper': float(mean_upper),
                    'MeanRangeToRawRange': float((mean_upper - mean_lower) / (raw_upper - raw_lower)),
                    'UniformScoreError': float(error), 'BernsteinLeaves': leaves,
                    'ExtremumEnclosureWidth': float(max(min_point - lower, upper - max_point) + 2 * error),
                    'ExactMeanBounds': [str(mean_lower), str(mean_upper)], 'ByN': by_n})
        if k < 4:
            U = [[GRID * U[i][j] - sum(P[i][ell] * U[ell][j] for ell in range(16)) for j in (0, 1)] for i in range(16)]
            assert U[0] == U[15] == [0, 0]
    return {'Scope': 'Existing complete Rater2 x Criterion2 binary GPCM witness; one beta; slopes 2 and 1/2; location components only',
            'ProfileBrackets': {str(t): list(map(str, b)) for t, b in brackets.items()},
            'RawProfileErrorUpper': float(profile_error), 'KernelL1ErrorUpper': float(kernel_error),
            'Method': 'Certified exact-rational bounds over x=exp(theta/2) in [0,infinity], including endpoint limits',
            'Sources': {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in (Path(__file__), WITNESS, INTERVALS)},
            'Results': results}


if __name__ == '__main__':
    # Known rational curve and whole-line transformation check the bound engine.
    assert envelope([Q(0), Q(1)], [Q(1), Q(1)])[:2] == (0, 1)
    assert envelope([Q(2), Q(2)], [Q(1), Q(1)])[:2] == (2, 2)
    result = run()
    output = Path(sys.argv[1]); output.parent.mkdir(parents=True, exist_ok=True)
    payload = json.dumps(result, indent=2) + '\n'
    if output.exists():
        assert output.read_text() == payload, 'Existing evidence differs; preserve it'
    else:
        output.write_text(payload)
    print(json.dumps([{k: r[k] for k in ('Order', 'Coordinate', 'RawLower', 'RawUpper', 'MeanLower', 'MeanUpper',
                                       'MeanRangeToRawRange', 'UniformScoreError', 'BernsteinLeaves', 'ExtremumEnclosureWidth')}
                      for r in result['Results']], indent=2))
