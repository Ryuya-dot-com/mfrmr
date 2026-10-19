"""Saved-bank JML calibration pilot with enclosed normal likelihood weights.

Harrison (2012) corrected self-normalized importance p-values. No refits or
new simulated responses. Candidate points are nuisance witnesses, NOT a
projection over all nuisance parameters or finished contrast intervals.
"""
from collections import defaultdict
from fractions import Fraction as Q
from itertools import product
from pathlib import Path
import csv
import hashlib
import json
import math
import sys
import mpmath as mp

mp.mp.dps = 80
mp.iv.dps = 45
IV = mp.iv
ORDER = 20
TAIL = 12


def iv(q):
    q = Q(q)
    return IV.mpf(q.numerator) / IV.mpf(q.denominator)


def rational(t):
    sign, man, exponent, bits = t
    assert bits >= 0
    return Q((-1)**sign * man) * Q(2)**exponent


def ends(x):
    return tuple(rational(t) for t in x._mpi_)


def display(x):
    low, high = ends(x)
    scale = 10**12
    return {'Lower': str(Q((low * scale).__floor__(), scale)),
            'Upper': str(Q((high * scale).__ceil__(), scale)),
            'Midpoint': float((low + high) / 2)}


def legendre(n, x):
    a, b = 1, x
    for k in range(2, n + 1):
        a, b = b, ((2*k - 1)*x*b - (k - 1)*a) / k
    return b, a


def rule():
    approximate, unused = mp.gauss_quadrature(ORDER, 'legendre')
    scale = 2**160
    result, previous = [], Q(-1)
    for root in approximate:
        low = Q(int(mp.floor(root * scale)) - 1, scale)
        high = low + Q(3, scale)
        assert previous < low < high < 1
        assert legendre(ORDER, low)[0] * legendre(ORDER, high)[0] < 0
        x = IV.mpf([iv(low).a, iv(high).b])
        pn, pm = legendre(ORDER, x)
        derivative = ORDER * (x * pn - pm) / (x*x - 1)
        weight = 2 / ((1 - x*x) * derivative**2)
        assert ends(weight)[0] > 0
        result.append((x, weight)); previous = high
    # n disjoint sign-changing brackets exhaust the n real Legendre roots.
    total = sum((w for x, w in result), IV.mpf(0))
    assert ends(total)[0] <= 2 <= ends(total)[1]
    return result


def read_inputs(root):
    data, patterns, hashes = [], defaultdict(set), {}
    for i in range(1, 51):
        path = root / 'conditional-reference' / f'input-{i:02d}.json'
        x = json.loads(path.read_text()); hashes[str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
        persons = defaultdict(list)
        for row in x['data']:
            persons[row['Person']].append(row)
        assert x['N'] == 30 and x['K'] == 3 and len(persons) == 30
        sample = []
        for rows in persons.values():
            rows.sort(key=lambda r: (r['Rater'], r['Criterion']))
            roster = tuple(sorted({r['Rater'] for r in rows}))
            assert len(roster) == 2 and [(r['Rater'], r['Criterion']) for r in rows] == list(product(roster, (1, 2, 3)))
            y = tuple(r['Score'] for r in rows)
            patterns[roster].add(y); sample.append((roster, y))
        data.append(sample)
    return data, {g: sorted(v) for g, v in patterns.items()}, hashes


def likelihoods(data, patterns, contrast, slopes, nodes):
    raters = list(map(Q, ('-3/10', '0', '3/10')))
    criteria = [(Q(-3, 10) + contrast)/2, (Q(-3, 10) - contrast)/2, Q(3, 10)]
    steps = [list(map(Q, row)) for row in (('-3/5','1/5','2/5'), ('-4/5','-1/10','9/10'), ('-2/5','-1/10','1/2'))]
    assert sum(criteria) == 0 and math.prod(slopes) == 1 and all(sum(v) == 0 for v in steps)
    radius = 1 / (3 * max(slopes))
    segments = math.ceil(2 * TAIL / radius)
    width = Q(2 * TAIL, segments)
    assert width <= radius <= Q(1, 3)
    # Analytic strip/Cauchy + composite Gauss-Legendre remainder; see review.
    strip_bound = 2 * Q(8, 7)**6
    quadrature_error = 2 * TAIL * strip_bound / ((2*ORDER + 1) * math.comb(2*ORDER, ORDER)**2)
    tail_error = iv(Q(2, TAIL)) * IV.exp(iv(Q(-TAIL**2, 2)))
    error = iv(quadrature_error) + tail_error
    cells = list(product(range(3), range(3)))
    indexed = {g: [(r - 1)*3 + c for r in g for c in range(3)] for g in patterns}
    accum = {g: [IV.mpf(0) for y in ys] for g, ys in patterns.items()}
    for segment in range(segments):
        center = Q(-TAIL) + (Q(segment) + Q(1, 2)) * width
        for x, weight in nodes:
            theta = iv(center) + iv(width/2) * x
            base = weight * iv(width/2) * IV.exp(-theta**2/2)
            probabilities = []
            for r, c in cells:
                cumulative = Q(0); mass = [IV.mpf(1)]
                for k in range(1, 4):
                    cumulative += steps[c][k-1]
                    mass.append(IV.exp(iv(slopes[c]) * (k*(theta - iv(raters[r] + criteria[c])) - iv(cumulative))))
                total = sum(mass)
                probabilities.append([v / total for v in mass])
            for g, ys in patterns.items():
                selected = [probabilities[j] for j in indexed[g]]
                for j, y in enumerate(ys):
                    value = base
                    for probabilities_at_cell, score in zip(selected, y):
                        value *= probabilities_at_cell[score]
                    accum[g][j] += value
        if (segment + 1) % 24 == 0:
            print(f'contrast {contrast}, slopes {slopes}: integration segment {segment+1}/{segments}', flush=True)
    enclosed = {}
    maximum_relative_width = 0.
    for g, ys in patterns.items():
        for y, value in zip(ys, accum[g]):
            lower = ends(value - error)[0]; upper = ends(value + error)[1]
            assert lower > 0, 'Increase integration order; zero lower likelihood cannot support a weight ratio'
            enclosed[g, y] = IV.mpf([iv(lower).a, iv(upper).b])
            maximum_relative_width = max(maximum_relative_width, float((upper-lower)/lower))
    values = []
    for sample in data:
        value = IV.mpf(1)
        for key in sample:
            value *= enclosed[key]
        values.append(value)
    return values, {'Segments': segments, 'Order': ORDER, 'PatternCount': len(enclosed),
        'PerPersonQuadratureErrorUpper': str(quadrature_error),
        'PerPersonTailErrorUpper': str(ends(tail_error)[1]),
        'MaximumPersonRelativeWidth': maximum_relative_width,
        'NormalizingConstant': 'sqrt(2*pi) omitted per Person; cancels in same-N likelihood ratios'}


def weighted_p(observed, statistics, weights, observed_failed=False):
    if observed_failed:
        return IV.mpf(1)
    # Includes the observed sample's weight. The other 49 are the proposal bank.
    numerator = sum((w for t, w in zip(statistics, weights) if t >= observed), IV.mpf(0))
    denominator = sum(weights, IV.mpf(0))
    ratio = numerator / denominator
    lower, upper = ends(ratio)
    return IV.mpf([iv(max(Q(0), lower)).a, iv(min(Q(1), upper)).b])


def run(root):
    data, patterns, inputs = read_inputs(root)
    nodes = rule()
    source = root / 'accuracy-review/contrasts.csv'
    records = [r for r in csv.DictReader(source.open()) if 'JML' in r['Arm'] and r['Target'] == 'contrast:Criterion:1-2']
    assert len(records) == 200
    arms = sorted({r['Arm'] for r in records})
    scenarios = [('proposal', Q(-1, 2), [Q(1)]*3),
                 ('criterion_minus_one', Q(-1), [Q(1)]*3),
                 ('criterion_zero', Q(0), [Q(1)]*3),
                 ('criterion_zero_unequal_slopes', Q(0), [Q(1),Q(11,10),Q(10,11)])]
    results, summaries, integration = [], [], {}
    proposal = None
    for name, contrast, slopes in scenarios:
        print(f'Starting {name}; saved-response likelihoods only', flush=True)
        likelihood, review = likelihoods(data, patterns, contrast, slopes, nodes)
        integration[name] = review
        if proposal is None:
            proposal = likelihood
            weights = [IV.mpf(1)]*50
        else:
            weights = [a/b for a,b in zip(likelihood,proposal)]
        midpoint = [float(sum(ends(w))/2) for w in weights]
        ess = sum(midpoint)**2 / sum(v*v for v in midpoint)
        for arm in arms:
            group = sorted((r for r in records if r['Arm']==arm), key=lambda r:int(r['Replicate']))
            assert [int(r['Replicate']) for r in group] == list(range(1,51))
            available = [r['Available']=='TRUE' and r['Estimate']!='NA' for r in group]
            statistics = [abs(Q(r['Estimate'])-contrast) if ok else math.inf for r,ok in zip(group,available)]
            output = []
            for i,(statistic,ok) in enumerate(zip(statistics,available)):
                p = weighted_p(statistic,statistics,weights,not ok)
                lo,hi = ends(p)
                output.append({'Scenario':name,'Contrast':str(contrast),'Arm':arm,'Replicate':i+1,
                    'ObservedFailed':not ok,'PValue':display(p),
                    'FullySpecifiedNullRejected':hi<=Q(1,20),
                    'NuisanceWitnessRetainsContrast':lo>Q(1,20),
                    'NumericalDecisionUnresolved':lo<=Q(1,20)<hi,
                    'CompositeNullRejected':False})
            results += output
            summaries.append({'Scenario':name,'Contrast':str(contrast),'Arm':arm,
                'WitnessRetains':sum(r['NuisanceWitnessRetainsContrast'] for r in output),
                'FullySpecifiedNullRejected':sum(r['FullySpecifiedNullRejected'] for r in output),
                'NumericalDecisionUnresolved':sum(r['NumericalDecisionUnresolved'] for r in output),
                'ImportanceESSDiagnostic':ess})
    result = {'Procedure':'Harrison corrected self-normalized importance MC p-value; B=49 per observed dataset; observed weight included',
        'Summary':summaries,'Results':results,'Integration':integration,
        'Proposal':'Fixed design distribution: centered Rater (-.3,0,.3), Criterion (-.4,.1,.3), stored PCM steps, unit slopes, N(0,1); exogenous balanced random rosters',
        'Assumptions':'Ideal stated normal response law and independent proposal samples. Frozen R pseudo-random generation is a numerical approximation; a uniform ideal-law discrepancy budget is not certified here.',
        'Scope':'Other structural parameters are known only for the fully specified test; a retained nuisance witness also retains the contrast in the supremum test. Rejection of a witness never rejects the composite contrast null.',
        'IndependentCoverageExperiment':False,'ConfidenceIntervalsProduced':0,'NewFits':0,'NewDatasets':0,
        'Sources':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in (Path(__file__),source)},
        'Inputs':inputs,'MpmathVersion':mp.__version__}
    out = root/'normal-mc-calibration'; out.mkdir(exist_ok=True)
    path = out/'importance-audit.json'; payload=json.dumps(result,indent=2,allow_nan=False)+'\n'
    if path.exists():
        assert path.read_text()==payload,'Existing evidence differs; preserve it'
    else:
        path.write_text(payload)
    print(json.dumps(summaries,indent=2),flush=True)


if __name__=='__main__':
    run(Path(sys.argv[1]))
