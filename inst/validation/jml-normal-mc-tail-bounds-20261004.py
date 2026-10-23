"""Certify parameter tails for the saved normal-population absolute MC test.

Research only: data-dependent compact search bounds, not useful CI endpoints.
The proofs in the linked method review are uniform in all structural nuisance
parameters. No numerical fit, new response sample, or local maximum is used.
"""
from collections import Counter, defaultdict
from fractions import Fraction as Q
from itertools import product
from pathlib import Path
import hashlib
import json
import math
import runpy
import sys

import numpy as np
from scipy.integrate import quad
from scipy.special import roots_hermitenorm, softmax


def binary_lower_exponent(value):
    """Return e with 2**(-e) <= value < 2**(1-e), using exact comparisons."""
    assert 0 < value <= 1
    exponent = value.denominator.bit_length() - value.numerator.bit_length()
    while Q(2)**(-exponent) > value:
        exponent += 1
    while Q(2)**(1-exponent) <= value:
        exponent -= 1
    return exponent


def envelope(exponent, counts):
    """Upper likelihood bound for a >= 2**exponent, uniform in other values."""
    assert exponent >= 2
    value = Q(1)
    used = 0
    for positive, negative in counts:
        n, m = positive + negative, min(positive, negative)
        if m:
            # K * sup(phi) < 6/5; log(2) < 7/10. Independent rosters.
            upper = Q(6, 5) * (2 + Q(n, m)*exponent*Q(7, 10)) / 2**exponent
            value *= min(Q(1), upper**n)
            used += 1
    assert used, 'No opposite-orientation roster: this tail certificate is unavailable'
    return value


def proposal_lower_bounds(patterns, module):
    """Concavity gives rectangular lower integrals, no quadrature error claim."""
    IV, iv, ends = (module[k] for k in ('IV', 'iv', 'ends'))
    # Piecewise minima of the normal density and conditional pattern mass.
    # Conditional log mass is concave in theta, so its interval minimum is
    # attained at an endpoint. Omitted normal tails add nonnegative mass.
    grid = [Q(j, 8) for j in range(-64, 65)]
    raters = list(map(Q, ('-3/10', '0', '3/10')))
    criteria = list(map(Q, ('-2/5', '1/10', '3/10')))
    steps = [list(map(Q, row)) for row in
             (('-3/5', '1/5', '2/5'), ('-4/5', '-1/10', '9/10'), ('-2/5', '-1/10', '1/2'))]
    assert ends(1 / IV.sqrt(2*IV.pi))[1] < Q(2, 5)
    assert ends(IV.exp(iv(Q(7, 10))))[0] > 2
    probabilities = []
    for theta in grid:
        cells = []
        for r, c in product(range(3), repeat=2):
            masses = [IV.mpf(1)]
            for step in steps[c]:
                masses.append(masses[-1] * IV.exp(iv(theta-raters[r]-criteria[c]-step)))
            total = sum(masses)
            cells.append([v/total for v in masses])
        probabilities.append(cells)
    density = [IV.exp(-iv(max(abs(a), abs(b)))**2/2)/IV.sqrt(2*IV.pi)
               for a, b in zip(grid, grid[1:])]
    lower = {}
    for roster, ys in patterns.items():
        cells = [(r-1)*3+c for r in roster for c in range(3)]
        for y in ys:
            endpoint = []
            for p in probabilities:
                mass = IV.mpf(1)
                for cell, score in zip(cells, y):
                    mass *= p[cell][score]
                endpoint.append(ends(mass)[0])
            value = sum((iv(min(a,b))*d/8 for a,b,d in
                         zip(endpoint, endpoint[1:], density)), IV.mpf(0))
            lower[roster, y] = ends(value)[0]
            assert lower[roster, y] > 0
        print(f'Certified proposal lower integrals: roster {roster}, {len(ys)} patterns', flush=True)
    # Independent ordinary floating quadrature checks scale/normalization;
    # validity of each lower bound follows from the interval-minimum argument.
    nodes, weights = roots_hermitenorm(241)
    weights /= math.sqrt(2*math.pi)
    cells = []
    for r,c in product(range(3), repeat=2):
        cumulative = np.r_[0., np.cumsum(list(map(float, steps[c])))]
        logits = (nodes[:,None]-float(raters[r]+criteria[c]))*np.arange(4)-cumulative
        cells.append(softmax(logits, axis=1))
    approximate, ratios = {}, []
    for roster, ys in patterns.items():
        selected = [(r-1)*3+c for r in roster for c in range(3)]
        for y in ys:
            value = weights.copy()
            for cell, score in zip(selected, y):
                value *= cells[cell][:,score]
            approximate[roster,y] = float(sum(value))
            ratio = float(lower[roster,y])/approximate[roster,y]
            assert 0 < ratio < 1
            ratios.append(ratio)
    return lower, approximate, {'PatternCount':len(lower), 'MinimumLowerToGH241Ratio':min(ratios),
        'MaximumLowerToGH241Ratio':max(ratios), 'IntegrationInterval':[-8,8], 'SegmentWidth':'1/8'}


def design_certificate(sample):
    cells = defaultdict(Counter)
    direction = defaultdict(Counter)
    for roster,y in sample:
        for j,(r,c) in enumerate(product(roster,(1,2,3))):
            cells[r,c][y[j]] += 1
        for c in range(3):
            direction[roster,c+1][(y[c]>y[c+3])-(y[c]<y[c+3])] += 1
    good = {(r,c) for (r,c),v in cells.items() if v[0] and v[3]}
    common = [r for r in (1,2,3) if (r,1) in good and (r,2) in good]
    complete = [c for c in (1,2,3) if all((r,c) in good for r in (1,2,3))]
    interiors = [[sum(v[k] for (r,c0),v in cells.items() if c0==c) for k in (1,2)] for c in (1,2,3)]
    assert common and complete and all(any((r,c) in good for r in (1,2,3)) for c in (1,2,3))
    assert all(min(v)>0 for v in interiors)
    counts = [[(direction[g,c][1],direction[g,c][-1]) for g in ((1,2),(1,3),(2,3))] for c in (1,2,3)]
    assert all(any(p and n for p,n in owner) for owner in counts)
    return good, common, complete, interiors, counts


def analytical_checks():
    """Independent integral checks of the uniform discordance lemma."""
    checks = []
    for cumulative in ([0.,0.,0.,0.], [0.,-2.,3.,0.], [0.,30.,-15.,0.]):
        for d in (0.,.5,-.5,8.,-8.):
            def discordance(x):
                p = softmax(np.arange(4)*x-np.array(cumulative))
                q = softmax(np.arange(4)*(x-d)-np.array(cumulative))
                return float(sum(p[k]*q[l] for k in range(4) for l in range(4) if k!=l))
            value,error = quad(discordance,-np.inf,np.inf,epsabs=1e-9,epsrel=1e-9)
            bound = 3*(2+abs(d))
            assert value+error < bound
            checks.append({'CumulativeSteps':cumulative,'NaturalRaterDifference':d,
                'IntegratedDiscordance':value,'UpperBound':bound})
    # Missing opposite directions must not silently yield a finite slope bound.
    try:
        envelope(10, [(10,0),(0,10),(0,0)])
    except AssertionError:
        pass
    else:
        raise AssertionError('Uncertified design incorrectly admitted')
    return checks


def run(root):
    source = Path('inst/validation/jml-normal-importance-mc-20261003.py')
    gate_path = root/'normal-mc-calibration/projection-gate.json'
    gate = json.loads(gate_path.read_text())
    for path,digest in gate['Sources'].items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest
    module = runpy.run_path(str(source))
    data, patterns, inputs = module['read_inputs'](root)
    assert inputs==gate['Inputs']
    lower, approximate, integration = proposal_lower_bounds(patterns, module)
    records = []
    for i,sample in enumerate(data,1):
        q_lower = math.prod(lower[key] for key in sample)
        exponent = binary_lower_exponent(q_lower)
        # Each w <= 1/32 outside its own box, hence their average < .05.
        epsilon_exponent = exponent+5
        epsilon = Q(2)**(-epsilon_exponent)
        assert epsilon <= q_lower/32
        good, common, complete, interiors, counts = design_certificate(sample)
        slopes, certificates = [], []
        for owner in counts:
            k = 2
            while envelope(k,owner)>epsilon:
                k += 1
            slopes.append(2**k)
            certificates.append({'UpperSlopeExponentBase2':k,'OppositeOrientationCounts':owner,
                'LikelihoodUpperAtAndAboveSlopeCutoff':str(envelope(k,owner)),
                'PreviousPowerOfTwoFailsThisBound':k==2 or envelope(k-1,owner)>epsilon})
        reciprocal_min = [math.prod(slopes[j] for j in range(3) if j!=c) for c in range(3)]
        h = 2
        while 5*h*h < 7*(epsilon_exponent+1):
            h += 1
        log_budget = math.ceil(Q(7,10)*(epsilon_exponent+1))
        # L >= epsilon implies an admissible theta per Person in [-h,h].
        severity = [Q(h)+Q(log_budget,3)*a for a in reciprocal_min]
        rater_bound = Q(4,3)*min(severity[c-1] for c in complete)
        criterion_bound = [d+rater_bound for d in severity]
        cumulative_bound = [[log_budget*a+k*(h+d+2*rater_bound) for k in (1,2)]
                            for a,d in zip(reciprocal_min,severity)]
        contrast_bound = severity[0]+severity[1]
        records.append({'Replicate':i,'ProposalProbabilityLowerPowerOfTwo':exponent,
            'LikelihoodLevelPowerOfTwo':epsilon_exponent,
            'LogProposalLowerToGH241Ratio':float(module['mp'].log(q_lower))-sum(math.log(approximate[key]) for key in sample),
            'SlopeCertificates':certificates,'ReciprocalSlopeLowerBounds':reciprocal_min,
            'NormalTruncationH':h,'LogitBudgetUpper':log_budget,
            'EndpointCells':[list(v) for v in sorted(good)],'CommonEndpointRatersForTarget':common,
            'CompleteEndpointCriteria':complete,'InteriorCategoryCounts':interiors,
            'RaterAbsoluteUpper':str(rater_bound),'CriterionAbsoluteUppers':list(map(str,criterion_bound)),
            'CumulativeStepAbsoluteUppers':[[str(v) for v in row] for row in cumulative_bound],
            'CriterionContrastAbsoluteUpper':str(contrast_bound)})
    radius = max(Q(r['CriterionContrastAbsoluteUpper']) for r in records)
    arms=[]
    for arm in sorted({r['Arm'] for r in gate['Results']}):
        group = [r for r in gate['Results'] if r['Arm']==arm]
        failed = {r['Replicate'] for r in group if r['ObservedFailed']}
        retained = {r['Replicate'] for r in group if r['WitnessRetainsContrast']}
        arms.append({'Arm':arm,'FinitePointBoundedProjectionSets':50-len(failed),
            'ObservedFailureWholeLine':sorted(failed),
            'FinitePointNonemptyWitnessed':len(retained-failed),
            'NonemptinessUnresolved':sorted(set(range(1,51))-retained)})
    result={'Procedure':'Uniform tails for absolute-weight MC projection under the declared N(0,1) GPCM; completed observed failures still give p=1.',
        'Records':records,'ProposalLowerIntegration':integration,'AnalyticalChecks':analytical_checks(),
        'Summary':{'DatasetCount':len(records),'MissingEndpointCells':sum(9-len(r['EndpointCells']) for r in records),
            'SlopeCertificates':3*len(records),'MaximumSlopeBound':max(2**v['UpperSlopeExponentBase2'] for r in records for v in r['SlopeCertificates']),
            'CriterionContrastOuterRadius':str(radius),'CriterionContrastOuterRadiusApproximate':float(radius),
            'PValueUpperOutsideUnionOfBoxes':'1/32','PerArm':arms},
        'Scope':'All joint structural-parameter escapes are bounded for these data and this known normal/design law. The original projected set is contained in the finite outer box for finite observed points; it may be empty. Unknown interior regions must be retained. This is not a useful-width CI, completed interior supremum, new independent coverage study, or public API.',
        'InteriorSupremumCompleted':False,'UsefulIntervalEndpointsProduced':False,'NewFits':0,'NewDatasets':0,
        'Sources':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in (Path(__file__),source,gate_path)},
        'Inputs':inputs,'MpmathVersion':module['mp'].__version__}
    destination=root/'normal-mc-calibration/tail-bounds.json'
    payload=json.dumps(result,indent=2,allow_nan=False)+'\n'
    if destination.exists():
        assert destination.read_text()==payload,'Existing evidence differs; preserve it'
    else:
        destination.write_text(payload)
    print(json.dumps(result['Summary'],indent=2),flush=True)


if __name__=='__main__':
    run(Path(sys.argv[1]))
