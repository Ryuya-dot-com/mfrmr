"""Independent arithmetic and integration checks for the saved-bank MC pilot."""
from fractions import Fraction as Q
from itertools import product
from pathlib import Path
import csv
import hashlib
import json
import math
import runpy
import sys
import numpy as np
from scipy.special import roots_hermitenorm


def check(root):
    script = Path('inst/validation/jml-normal-importance-mc-20261003.py')
    saved_path = root/'normal-mc-calibration/importance-audit.json'
    saved = json.loads(saved_path.read_text())
    for path,h in {**saved['Sources'],**saved['Inputs']}.items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest() == h
    # Exact finite-state importance law, including a deliberately naive control.
    weights = (Q(1,2),Q(1),Q(3,2)); target = [w/3 for w in weights]
    size = {a:Q(0) for a in (Q(1,20),Q(1,5),Q(1,2),Q(1))}
    failure_size = dict(size); naive_size = Q(0)
    for x,y in product(range(3),repeat=2):
        probability = target[x]/3
        p = (weights[x] + weights[y]*(y>=x))/(weights[x]+weights[y])
        naive = Q(y>=x)
        for alpha in size:
            size[alpha] += probability*(p<=alpha)
            failure_size[alpha] += probability*((Q(1) if x==2 else p)<=alpha)
        naive_size += probability*(naive<=Q(1,20))
    assert all(size[a]<=a and failure_size[a]<=a for a in size)
    assert naive_size>Q(1,20)
    module = runpy.run_path(str(script))
    data,patterns,unused = module['read_inputs'](root)
    scenarios = [('proposal',-.5,(1,1,1)),('criterion_minus_one',-1.,(1,1,1)),
                 ('criterion_zero',0.,(1,1,1)),('criterion_zero_unequal_slopes',0.,(1,1.1,1/1.1))]
    steps = np.array([[-.6,.2,.4],[-.8,-.1,.9],[-.4,-.1,.5]])
    def probabilities(n,contrast,slopes):
        theta,weight = roots_hermitenorm(n); weight /= np.sqrt(2*np.pi)
        rater = np.array([-.3,0,.3]); criterion = np.array([(-.3+contrast)/2,(-.3-contrast)/2,.3])
        result = {}
        for roster,ys in patterns.items():
            cells = list(product(roster,range(3)))
            probability = []
            for r,c in cells:
                # Adjacent-odds recurrence, independent of the cumulative-logit implementation.
                odds = np.exp(np.asarray(slopes)[c]*(theta[:,None]-rater[r-1]-criterion[c]-steps[c]))
                mass = np.column_stack((np.ones(n),np.cumprod(odds,axis=1)))
                probability.append(mass/mass.sum(axis=1)[:,None])
            for y in ys:
                integrand = np.ones(n)
                for p,k in zip(probability,y): integrand *= p[:,k]
                result[roster,y] = float(weight@integrand)
        return result
    likelihood, maximum_order_change = {},0.
    for name,contrast,slopes in scenarios:
        a,b = probabilities(121,contrast,slopes),probabilities(241,contrast,slopes)
        l0=np.array([sum(math.log(a[key]) for key in sample) for sample in data])
        l1=np.array([sum(math.log(b[key]) for key in sample) for sample in data])
        maximum_order_change=max(maximum_order_change,float(max(abs(l1-l0))))
        likelihood[name]=l1
    points = list(csv.DictReader((root/'accuracy-review/contrasts.csv').open()))
    points={(r['Arm'],int(r['Replicate'])):r for r in points if 'JML' in r['Arm'] and r['Target']=='contrast:Criterion:1-2'}
    difference = 0.; enclosure_distance = 0.; failed_weight_share = {}
    for name,contrast,slopes in scenarios:
        logweight=likelihood[name]-likelihood['proposal']; weight=np.exp(logweight-max(logweight))
        for arm in sorted({r['Arm'] for r in saved['Results']}):
            estimates = [points[arm,i]['Estimate'] for i in range(1,51)]
            stat=np.array([abs(float(x)-contrast) if x!='NA' else math.inf for x in estimates])
            failed_weight_share[name,arm]=float(sum(weight[~np.isfinite(stat)])/sum(weight))
            for row in (r for r in saved['Results'] if r['Scenario']==name and r['Arm']==arm):
                i=row['Replicate']-1
                p=1. if not math.isfinite(stat[i]) else float(sum(weight[stat>=stat[i]])/sum(weight))
                difference=max(difference,abs(p-row['PValue']['Midpoint']))
                lo,hi=(float(Q(row['PValue'][key])) for key in ('Lower','Upper'))
                enclosure_distance=max(enclosure_distance,lo-p,p-hi,0.)
                assert (p<=.05)==row['FullySpecifiedNullRejected']
    assert maximum_order_change<1e-10 and difference<2e-12
    # High-precision adaptive integration against the interval evaluator, on
    # the least-probable observed pattern from each roster at the unequal case.
    name,contrast,slopes=scenarios[-1]
    p=probabilities(241,contrast,slopes)
    selected={g:[min(ys,key=lambda y:p[g,y])] for g,ys in patterns.items()}
    small=[[(g,ys[0])] for g,ys in selected.items()]
    bounds,review=module['likelihoods'](small,selected,Q(0),[Q(1),Q(11,10),Q(10,11)],module['rule']())
    mp=module['mp']; mm=lambda s:mp.mpf(str(s))
    rater=list(map(mm,('-.3','0','.3'))); criterion=list(map(mm,('-.15','-.15','.3')))
    step=[[mm(s) for s in row] for row in (('-.6','.2','.4'),('-.8','-.1','.9'),('-.4','-.1','.5'))]
    slope=[mp.mpf(1),mp.mpf(11)/10,mp.mpf(10)/11]
    for sample,bound in zip(small,bounds):
        roster,y=sample[0]
        def integrand(theta):
            total=mp.exp(-theta*theta/2)
            for (r,c),k in zip(product(roster,range(3)),y):
                mass=[mp.mpf(1)]
                for t in step[c]: mass.append(mass[-1]*mp.exp(slope[c]*(theta-rater[r-1]-criterion[c]-t)))
                total *= mass[k]/sum(mass)
            return total
        independent=mp.quad(integrand,[-12,-6,-3,0,3,6,12])
        lo,hi=module['ends'](bound)
        assert mp.mpf(lo.numerator)/lo.denominator <= independent <= mp.mpf(hi.numerator)/hi.denominator
    result={'ExactImportanceSizeChecks':{str(a):str(p) for a,p in size.items()},
        'NaiveControlSizeAt005':str(naive_size),'KnownFailureRetentionChecksPassed':True,
        'PValuesCompared':len(saved['Results']),'Maximum121To241LogLikelihoodChange':maximum_order_change,
        'MaximumIndependentPValueDifference':difference,'MaximumDistanceFromDisplayedEnclosure':enclosure_distance,
        'HighPrecisionRarePatternEnclosuresChecked':len(small),
        'FailedWeightShareDiagnostic':[{'Scenario':n,'Arm':a,'Share':v} for (n,a),v in failed_weight_share.items()],
        'AllChecksPassed':True,'FormalContrastIntervalQualified':False,
        'Sources':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in (Path(__file__),script,saved_path)}}
    path=root/'normal-mc-calibration/importance-checks.json'
    payload=json.dumps(result,indent=2,allow_nan=False)+'\n'
    if path.exists(): assert path.read_text()==payload,'Existing evidence differs; preserve it'
    else: path.write_text(payload)
    print(json.dumps(result,indent=2))


if __name__=='__main__': check(Path(sys.argv[1]))
