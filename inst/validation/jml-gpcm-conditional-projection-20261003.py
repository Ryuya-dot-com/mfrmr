"""Research GPCM reference: project conditional products over all positive slopes.

Saved Rater3 x Criterion3 responses, Criterion-owned slopes/steps, disjoint
within-Person/Criterion Rater pairs, geometric-mean-one slopes. This is not
a JML covariance, a public interval API, or inference for Criterion locations.
"""
from fractions import Fraction as Q
from pathlib import Path
import hashlib
import json
import math
import runpy
import sys

BASE = Path(__file__).with_name('jml-pcm-conditional-intervals-20261003.py')
pcm = runpy.run_path(str(BASE))


def tail_root(h, observed, upper, alpha):
    compare = lambda z: pcm['tail_compare'](h, observed, z, upper, alpha)
    lo = hi = Q(1)
    while compare(lo) > 0:
        lo /= 2
    while compare(hi) < 0:
        hi *= 2
    while hi - lo > lo / 2**60:
        mid = (lo + hi) / 2
        if compare(mid) < 0:
            lo = mid
        else:
            hi = mid
    assert compare(lo) <= 0 <= compare(hi)
    return lo, hi


def interval(h, observed, alpha):
    low = None if observed == min(h) else tail_root(h, observed, True, alpha)
    high = None if observed == max(h) else tail_root(h, observed, False, alpha)
    return {
        'Lower': '-Inf' if high is None else pcm['outward'](-pcm['log_bounds'](high[1])[1], True),
        'Upper': 'Inf' if low is None else pcm['outward'](-pcm['log_bounds'](low[0])[0], False),
        'ErrorProbability': str(alpha),
        'NaturalLowerRootBracket': None if low is None else list(map(str, low)),
        'NaturalUpperRootBracket': None if high is None else list(map(str, high)),
    }


def root_bound(q, degree, upper):
    """Outward decimal bound for a nonnegative root; integer comparisons only."""
    if q == math.inf:
        return math.inf
    assert q >= 0 and degree > 0
    scale = 10**6
    target = q.numerator * scale**degree
    lo, hi = 0, 1
    while hi**degree * q.denominator <= target:
        lo, hi = hi, 2 * hi
    while hi - lo > 1:
        mid = (lo + hi) // 2
        if mid**degree * q.denominator <= target:
            lo = mid
        else:
            hi = mid
    return Q(hi if upper and lo**degree * q.denominator != target else lo, scale)


def project(bounds):
    """Closed interval hull of d_c=a_c*psi, a_c>0, product(a_c)=1."""
    lower, upper = zip(*bounds)
    assert all(a <= b for a, b in bounds)
    ends = []
    if all(b > 0 for b in upper):
        lo = math.prod(max(a, Q(0)) for a in lower)
        hi = math.inf if math.inf in upper else math.prod(upper)
        ends += [root_bound(lo, len(bounds), False), root_bound(hi, len(bounds), True)]
    if all(a < 0 for a in lower):
        lo = math.prod(max(-b, Q(0)) for b in upper)
        hi = math.inf if -math.inf in lower else math.prod(-a for a in lower)
        ends += [-root_bound(hi, len(bounds), True), -root_bound(lo, len(bounds), False)]
    if all(a <= 0 <= b for a, b in bounds):
        ends.append(Q(0))
    if not ends:
        return {'Empty': True, 'Lower': None, 'Upper': None}
    def display(x, is_lower):
        if x in (-math.inf, math.inf):
            return '-Inf' if x < 0 else 'Inf'
        return pcm['outward'](x, is_lower)
    return {'Empty': False, 'Lower': display(min(ends), True),
            'Upper': display(max(ends), False)}


def check():
    # One-trial tail probability alpha/2=1/120 has exact root 119.
    h = {0: 1, 1: 1}
    lo, hi = tail_root(h, 0, False, Q(1, 60))
    assert lo <= 119 <= hi
    assert interval({2: 1}, 2, Q(1, 60))['Lower'] == '-Inf'
    assert interval({2: 1}, 2, Q(1, 60))['Upper'] == 'Inf'
    assert project([(Q(1), Q(4)), (Q(4), Q(9))]) == {
        'Empty': False, 'Lower': '2.000000', 'Upper': '6.000000'}
    assert project([(Q(-4), Q(-1)), (Q(-9), Q(-4))]) == {
        'Empty': False, 'Lower': '-6.000000', 'Upper': '-2.000000'}
    assert project([(Q(1), Q(2)), (Q(-2), Q(-1))])['Empty']
    assert project([(Q(0), Q(0)), (-math.inf, math.inf)]) == {
        'Empty': False, 'Lower': '0.000000', 'Upper': '0.000000'}
    assert project([(-math.inf, math.inf)] * 3) == {
        'Empty': False, 'Lower': '-Inf', 'Upper': 'Inf'}
    # A zero endpoint can be only a limit as slopes escape; closure is conservative.
    assert project([(Q(1), math.inf), (Q(-1), Q(2))]) == {
        'Empty': False, 'Lower': '0.000000', 'Upper': 'Inf'}
    for q, degree in ((Q(2), 3), (Q(1, 10**24), 3), (Q(125), 3)):
        lo, hi = root_bound(q, degree, False), root_bound(q, degree, True)
        assert lo**degree <= q <= hi**degree and hi - lo <= Q(1, 10**6)
    # Exact attainable product parameters, including a negative contrast.
    for psi in (Q(-2), Q(1, 3)):
        a = [Q(2), Q(3), Q(1, 6)]
        d = [v * psi for v in a]
        out = project([(v, v) for v in d])
        assert Q(out['Lower']) <= psi <= Q(out['Upper'])


def run(path):
    source = json.loads(path.read_text())
    data, K = source['data'], source['K']
    assert source['step_facet'] == 'Criterion' and K == 3
    assert len(data) == 6 * source['N']
    assert len({(r['Person'], r['Rater'], r['Criterion']) for r in data}) == len(data)
    assert {r['Rater'] for r in data} == {r['Criterion'] for r in data} == {1, 2, 3}
    assert all(isinstance(r['Score'], int) and 0 <= r['Score'] <= K for r in data)
    owners = sorted({r['Criterion'] for r in data})
    alpha = Q(1, 20 * len(owners))
    components = []
    for owner in owners:
        rows = [r for r in data if r['Criterion'] == owner]
        pairs, observed, index = pcm['pair_features'](rows, 'Rater', K)
        h = pcm['counts'](pairs, observed, index)
        components.append({'Owner': owner, 'Pairs': len(pairs),
            'DiscordantPairs': sum(len(p) == 2 for p in pairs),
            'ObservedSufficientStatistics': observed, 'Support': sorted(h),
            'OrientationCounts': dict(sorted(h.items())), **interval(h, observed[index], alpha)})
    number = lambda s: -math.inf if s == '-Inf' else math.inf if s == 'Inf' else Q(s)
    bounds = [(number(c['Lower']), number(c['Upper'])) for c in components]
    projected = project(bounds)
    zero = all(a <= 0 <= b for a, b in bounds)
    return {'Scope': 'Rater3 x Criterion3; six ratings per Person; Criterion-owned positive slopes and steps; geometric-mean-one slopes; no interactions; independent conditional ratings',
        'N': source['N'], 'K': K, 'Contrast': 'Rater 1 - 2',
        'CoverageLowerBound': '0.95',
        'Method': 'Exact conditional owner-specific product intervals; Bonferroni; closed projection over every positive normalized slope vector',
        'Components': components, 'ProjectedInterval': projected,
        'ZeroContrastAccepted': zero,
        'EveryNormalizedSlopeVectorAcceptedAtZeroContrast': zero,
        'CriterionLocationRestriction': 'None from this conditional procedure',
        'InputSHA256': hashlib.sha256(path.read_bytes()).hexdigest(),
        'Sources': {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in (Path(__file__), BASE)}}


if __name__ == '__main__':
    check()
    result = run(Path(sys.argv[1]))
    output = Path(sys.argv[2]); output.parent.mkdir(parents=True, exist_ok=True)
    payload = json.dumps(result, indent=2) + '\n'
    if output.exists():
        assert output.read_text() == payload, 'Existing evidence differs; preserve it'
    else:
        output.write_text(payload)
    print(json.dumps({k: result[k] for k in ('Contrast', 'CoverageLowerBound', 'ProjectedInterval',
        'ZeroContrastAccepted', 'EveryNormalizedSlopeVectorAcceptedAtZeroContrast')}, indent=2))
