"""Check the nuisance-projection gate; evaluate absolute-weight MC correction.

Self-normalized finite-bank projection has a certified escape for exposed
category-count vectors. Absolute likelihood ratios are available here, so
also evaluate Harrison's unnormalized correction, retaining the failure-zero
statistic. Only one sample's likelihoods are needed to recover the weight scale.
"""
from fractions import Fraction as Q
from pathlib import Path
from itertools import product
import csv
import hashlib
import json
import runpy
import sys
import numpy as np
from scipy.optimize import linprog


def run(root):
    previous=root/'normal-mc-calibration/failure-rule.json'
    old=json.loads(previous.read_text())
    for path,h in old['Sources'].items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==h
    script=Path('inst/validation/jml-normal-importance-mc-20261003.py')
    module=runpy.run_path(str(script)); IV=module['IV']; iv=module['iv']; ends=module['ends']
    data,patterns,inputs=module['read_inputs'](root)
    counts=[]
    for sample in data:
        counts.append([sum(y[j]==k for roster,y in sample for j,(r,c0) in enumerate(product(roster,(1,2,3))) if c0==c)
                       for c in (1,2,3) for k in (1,2)])
    counts=np.asarray(counts,dtype=int); certificates=[]; uncertified=[]
    for i in range(50):
        delta=np.delete(counts,i,axis=0)-counts[i]
        proposal=linprog(np.zeros(6),A_ub=-delta,b_ub=-np.ones(49),bounds=[(None,None)]*6,method='highs')
        if not proposal.success:
            uncertified.append(i+1); continue
        direction=[Q(float(v)).limit_denominator(10**6) for v in proposal.x]
        margin=min(sum(int(a)*b for a,b in zip(row,direction)) for row in delta)
        assert margin>0
        certificates.append({'Replicate':i+1,'Direction':list(map(str,direction)),
            'ExactMinimumMargin':str(margin),'CriterionInterval':'Whole real line for the self-normalized nuisance supremum, for every stored statistic containing its own observed weight.'})
    # The relative weights were already enclosed. Recover their common absolute
    # scale from one retained dataset, rather than repeating all 1,172 patterns.
    selected={g:sorted({y for g0,y in data[0] if g0==g}) for g in patterns}
    nodes=module['rule']()
    scenarios=[('proposal',Q(-1,2),[Q(1)]*3),('criterion_minus_one',Q(-1),[Q(1)]*3),
        ('criterion_zero',Q(0),[Q(1)]*3),('criterion_zero_unequal_slopes',Q(0),[Q(1),Q(11,10),Q(10,11)])]
    base=None; output=[];summary=[];scale_records=[]
    source=root/'accuracy-review/contrasts.csv'
    points={(r['Arm'],int(r['Replicate'])):r for r in csv.DictReader(source.open()) if 'JML' in r['Arm'] and r['Target']=='contrast:Criterion:1-2'}
    for name,contrast,slopes in scenarios:
        if name=='proposal':
            values,review=module['likelihoods']([data[0]],selected,contrast,slopes,nodes)
            base=values[0]; scale=IV.mpf(50)
        else:
            values,review=module['likelihoods']([data[0]],selected,contrast,slopes,nodes)
            anchor=next(r for r in old['NormalizedWeightEnclosures'] if r['Scenario']==name and r['Replicate']==1)
            norm=IV.mpf([iv(Q(anchor['Lower'])).a,iv(Q(anchor['Upper'])).b])
            assert ends(norm)[0]>0
            scale=(values[0]/base)/norm
        scale_records.append({'Scenario':name,'WeightSumLower':str(ends(scale)[0]),'WeightSumUpper':str(ends(scale)[1]),
                              'AnchorPatternCount':review['PatternCount']})
        for arm in sorted({r['Arm'] for r in old['Results']}):
            rows=[r for r in old['Results'] if r['Scenario']==name and r['Arm']==arm]
            produced=[]
            for row in rows:
                lo,hi=Q(row['PValueLower']),Q(row['PValueUpper'])
                # The normalized inclusive numerator times total weight / (B+1).
                value=IV.mpf([iv(lo).a,iv(hi).b])*scale/50
                lower,upper=ends(value); lower=min(Q(1),lower); upper=min(Q(1),upper)
                if row['ObservedFailed']: lower=upper=Q(1)
                produced.append({'Scenario':name,'Contrast':str(contrast),'Arm':arm,'Replicate':row['Replicate'],
                    'ObservedFailed':row['ObservedFailed'],'PValueLower':str(lower),'PValueUpper':str(upper),
                    'WitnessRetainsContrast':lower>Q(1,20),'FullySpecifiedNullRejected':upper<=Q(1,20),
                    'NumericalDecisionUnresolved':lower<=Q(1,20)<upper,'CompositeNullRejected':False})
            output+=produced
            summary.append({'Scenario':name,'Arm':arm,'WitnessRetains':sum(r['WitnessRetainsContrast'] for r in produced),
                'FullySpecifiedNullRejected':sum(r['FullySpecifiedNullRejected'] for r in produced),
                'NumericalDecisionUnresolved':sum(r['NumericalDecisionUnresolved'] for r in produced)})
    # Exact weighted-rank inequality for the unnormalized correction; its
    # validity uses exchangeability under Q before multiplying by w(observed).
    checked=0
    for stat in product((0,1,2),repeat=4):
        for weight in product((Q(1,3),Q(2)),repeat=4):
            p=[sum(w for t,w in zip(stat,weight) if t>=s)/4 for s in stat]
            for alpha in (Q(1,20),Q(1,4),Q(1,2),Q(1)):
                assert sum(w for w,v in zip(weight,p) if v<=alpha)<=4*alpha
            checked+=1
    result={'SelectedCandidate':'Absolute-weight corrected MC p-value, with zero on completed algorithm failure; observed failure retained.',
        'SelfNormalizedEscapeCertificates':certificates,'NoSeparationCertificate':uncertified,
        'CategoryCounts':counts.tolist(),'AbsoluteWeightScale':scale_records,'Summary':summary,'Results':output,
        'ExactWeightedRankConfigurationsChecked':checked,'OtherNuisanceCoordinatesMaximized':False,
        'FiniteContrastIntervalsProduced':0,'NewFits':0,'NewDatasets':0,
        'Sources':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in (Path(__file__),script,previous,source)},
        'Inputs':inputs,'Interpretation':'The self-normalized projection is certified uninformative for the exposed samples. Absolute-weight results are full-null tests and retained nuisance witnesses, not composite-null exclusions or an independent coverage study.'}
    destination=root/'normal-mc-calibration/projection-gate.json'
    payload=json.dumps(result,indent=2,allow_nan=False)+'\n'
    if destination.exists(): assert destination.read_text()==payload,'Existing evidence differs; preserve it'
    else: destination.write_text(payload)
    print(json.dumps({'SelfNormalizedWholeLine':len(certificates),'Uncertified':uncertified,'Summary':summary},indent=2),flush=True)


if __name__=='__main__':run(Path(sys.argv[1]))
