"""Research-only exact conditional intervals for two saved PCM contrasts.

Disjoint pairs remove Person ability; further conditioning removes structural
nuisance parameters. Integer counts, rational tail inversion and outward log
bounds avoid asymptotic or floating-point coverage qualifications. This is a
different procedure from JML and is not a public package API.
"""
from collections import Counter, defaultdict
from fractions import Fraction as Q
from itertools import product
from pathlib import Path
import hashlib
import json
import math
import sys


def pair_features(data, target, K):
    groups = defaultdict(list)
    for row in data:
        key = (row['Person'], row['Criterion' if target == 'Rater' else 'Rater'])
        groups[key].append(row)
    pairs, observed = [], None
    for key in sorted(groups):
        rows = groups[key]
        if target == 'Rater':
            assert len(rows) == 2
            rows = sorted(rows, key=lambda r: r['Rater'])
            raters = [r['Rater'] for r in rows]
            assert len(set(raters)) == 2
            feature = lambda a, b: tuple(sum(s for r, s in zip(raters, (a, b)) if r == j)
                                         for j in (1, 3))
        else:
            rows = sorted((r for r in rows if r['Criterion'] in (1, 2)), key=lambda r: r['Criterion'])
            assert [r['Criterion'] for r in rows] == [1, 2]
            feature = lambda a, b: tuple(int(a == k) for k in range(1, K + 1))
        a, b = [r['Score'] for r in rows]
        value = feature(a, b)
        pairs.append(sorted(set((value, feature(b, a)))))
        observed = value if observed is None else tuple(x + y for x, y in zip(observed, value))
    return pairs, observed, (0 if target == 'Rater' else K - 1)


def counts(pairs, observed, target):
    states = Counter({(0,) * len(observed): 1})
    nuisance = [j for j in range(len(observed)) if j != target]
    for pair in pairs:
        new = Counter()
        for x, multiplicity in states.items():
            for y in pair:
                z = tuple(a + b for a, b in zip(x, y))
                # All sufficient-statistic increments are nonnegative.
                if all(z[j] <= observed[j] for j in nuisance):
                    new[z] += multiplicity
        states = new
    answer = Counter({x[target]: n for x, n in states.items()
                      if all(x[j] == observed[j] for j in nuisance)})
    assert answer[observed[target]] > 0
    return answer


def tail_compare(h, observed, z, upper, alpha=Q(1, 20)):
    """Sign of an increasing function, with its zero at tail = alpha/2."""
    first, degree = min(h), max(h) - min(h)
    n, d = z.numerator, z.denominator
    masses = {t: count * n**(t - first) * d**(degree - t + first) for t, count in h.items()}
    denominator = sum(masses.values())
    numerator = sum(v for t, v in masses.items() if (t >= observed if upper else t <= observed))
    difference = 2 * alpha.denominator * numerator - alpha.numerator * denominator
    return difference if upper else -difference


def tail_root(h, observed, upper):
    lo = hi = Q(1)
    while tail_compare(h, observed, lo, upper) > 0:
        lo /= 2
    while tail_compare(h, observed, hi, upper) < 0:
        hi *= 2
    while hi - lo > lo / 2**60:
        mid = (lo + hi) / 2
        if tail_compare(h, observed, mid, upper) < 0:
            lo = mid
        else:
            hi = mid
    assert tail_compare(h, observed, lo, upper) <= 0 <= tail_compare(h, observed, hi, upper)
    return lo, hi


def log_bounds(z):
    # log(r)=2 atanh((r-1)/(r+1)); positive-series remainder after range reduction.
    def series(r):
        w = (r - 1) / (r + 1)
        lower = 2 * sum((w**(2 * j + 1) / (2 * j + 1) for j in range(40)), Q(0))
        error = 2 * w**81 / (81 * (1 - w * w))
        return lower, lower + error
    exponent = 0
    while z < 1:
        z *= 2
        exponent -= 1
    while z >= 2:
        z /= 2
        exponent += 1
    a, b = series(z)
    c, d = series(Q(2))
    return (a + exponent * c, b + exponent * d) if exponent >= 0 else (a + exponent * d, b + exponent * c)


def outward(value, lower):
    scaled = value * 10**6
    n = scaled.numerator // scaled.denominator if lower else -((-scaled.numerator) // scaled.denominator)
    return f"{'-' if n < 0 else ''}{abs(n) // 10**6}.{abs(n) % 10**6:06d}"


def interval(h, observed, scale):
    # Natural parameter lambda=-scale*contrast; reverse endpoints on transformation.
    low_z = None if observed == min(h) else tail_root(h, observed, True)
    high_z = None if observed == max(h) else tail_root(h, observed, False)
    lower = '-Inf' if high_z is None else outward(-log_bounds(high_z[1])[1] / scale, True)
    upper = 'Inf' if low_z is None else outward(-log_bounds(low_z[0])[0] / scale, False)
    return {'Lower': lower, 'Upper': upper, 'Level': '0.95',
            'NaturalLowerRootBracket': None if low_z is None else list(map(str, low_z)),
            'NaturalUpperRootBracket': None if high_z is None else list(map(str, high_z))}


def check():
    # Independent exhaustive counting checks the nuisance-conditioning DP.
    pairs = [[(0, 0), (1, 0)], [(0, 2), (2, 0)], [(1, 1)], [(0, 1), (1, 0)]]
    observed = (2, 3)
    brute = Counter()
    for choices in product(*pairs):
        total = tuple(sum(v[j] for v in choices) for j in (0, 1))
        if total[1] == observed[1]:
            brute[total[0]] += 1
    assert counts(pairs, observed, 0) == brute
    # Known one-trial equal-tail limits, plus a wholly uninformative stratum.
    h = {0: 1, 1: 1}
    root = tail_root(h, 0, False)
    assert root[0] <= 39 <= root[1]
    assert interval(h, 0, 1)['Upper'] == 'Inf'
    assert interval(h, 1, 1)['Lower'] == '-Inf'
    assert interval({2: 1}, 2, 1)['Lower'] == '-Inf'
    assert interval({2: 1}, 2, 1)['Upper'] == 'Inf'
    # Interior binomial case: both exact tail comparisons bracket their root.
    h = {t: math.comb(8, t) for t in range(9)}
    answer = interval(h, 3, 1)
    assert answer['Lower'] != '-Inf' and answer['Upper'] != 'Inf'


def run(path):
    source = json.loads(path.read_text())
    data, K = source['data'], source['K']
    assert source['step_facet'] == 'Criterion' and K == 3
    assert len(data) == 6 * source['N'] and len({(r['Person'], r['Rater'], r['Criterion']) for r in data}) == len(data)
    assert set(r['Rater'] for r in data) == set(r['Criterion'] for r in data) == {1, 2, 3}
    assert all(isinstance(r['Score'], int) and 0 <= r['Score'] <= K for r in data)
    results = []
    for target in ('Rater', 'Criterion'):
        pairs, observed, index = pair_features(data, target, K)
        h = counts(pairs, observed, index)
        scale = 1 if target == 'Rater' else K
        # Relabel the target's levels 1 and 2: the count distribution must reflect.
        swapped = [{**r, target: {1: 2, 2: 1, 3: 3}[r[target]]} for r in data]
        reverse_pairs, reverse_observed, reverse_index = pair_features(swapped, target, K)
        reverse_h = counts(reverse_pairs, reverse_observed, reverse_index)
        reflection = observed[index] + reverse_observed[reverse_index]
        assert reverse_h == {reflection - t: n for t, n in h.items()}
        result = {'Contrast': target + ' 1 - 2', 'Pairs': len(pairs),
                  'DiscordantPairs': sum(len(p) == 2 for p in pairs),
                  'ObservedSufficientStatistics': observed, 'TargetIndex': index,
                  'TargetStatistic': observed[index], 'Support': sorted(h),
                  'OrientationCounts': dict(sorted(h.items())), 'NaturalScale': -scale,
                  **interval(h, observed[index], scale)}
        results.append(result)
    return {'N': source['N'], 'K': K, 'InputSHA256': hashlib.sha256(path.read_bytes()).hexdigest(),
            'SourceSHA256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
            'Method': 'Disjoint-pair conditioning, exact nuisance conditioning, equal-tailed pointwise 95% intervals',
            'Scope': 'Research reference for two contrasts; not JML intervals, not all-coordinate PCM inference',
            'Results': results}


if __name__ == '__main__':
    check()
    result = run(Path(sys.argv[1]))
    output = Path(sys.argv[2])
    payload = json.dumps(result, indent=2) + '\n'
    if output.exists():
        assert output.read_text() == payload, 'Existing evidence differs; preserve it'
    else:
        output.write_text(payload)
    print(json.dumps([{k: r[k] for k in ('Contrast', 'Pairs', 'DiscordantPairs', 'TargetStatistic', 'Support', 'Lower', 'Upper')}
                      for r in result['Results']], indent=2))
