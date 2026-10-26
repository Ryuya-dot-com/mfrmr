"""Complete the MC statistic with zero on known algorithm failure.

Reuse enclosed weighted ranks to avoid repeating completed normal integrals.
The ordinary PCM statistic is finite and has distinct ranks on this saved bank,
so differences of its inclusive tails enclose each normalized importance weight.
This recovery is an evidence-reuse operation, not a proposed public interface.
"""
from fractions import Fraction as Q
from itertools import product
from pathlib import Path
import csv
import hashlib
import json
import sys


def check_rule():
    # Arbitrary nonnegative weighted ranks obey the pointwise size inequality.
    # Failure=-1 is a status, mapped to statistic 0 without inventing a point.
    count = 0
    for status in product((-1,0,1,2), repeat=4):
        for weights in product((Q(1),Q(2)),repeat=4):
            total=sum(weights)
            p=[Q(1) if s==-1 else sum(w for t,w in zip(status,weights) if max(t,0)>=s)/total for s in status]
            for alpha in (Q(1,20),Q(1,4),Q(1,2),Q(3,4),Q(1)):
                assert sum(w for w,v in zip(weights,p) if v<=alpha)<=alpha*total
            count+=1
    return count


def run(root):
    source=root/'normal-mc-calibration/importance-audit.json'
    old=json.loads(source.read_text())
    for path,h in {**old['Sources'],**old['Inputs']}.items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==h
    path=root/'accuracy-review/contrasts.csv'
    points={(r['Arm'],int(r['Replicate'])):r for r in csv.DictReader(path.open()) if 'JML' in r['Arm'] and r['Target']=='contrast:Criterion:1-2'}
    output=[];summary=[];weights_out=[]
    for scenario in old['Integration']:
        saved=[r for r in old['Results'] if r['Scenario']==scenario]
        contrast=Q(saved[0]['Contrast'])
        pcm=sorted((r for r in saved if r['Arm']=='PCM-JML'),
                   key=lambda r:abs(Q(points['PCM-JML',r['Replicate']]['Estimate'])-contrast),reverse=True)
        statistics=[abs(Q(points['PCM-JML',r['Replicate']]['Estimate'])-contrast) for r in pcm]
        assert len(statistics)==50 and len(set(statistics))==50 and not any(r['ObservedFailed'] for r in pcm)
        bounds={};previous=(Q(0),Q(0))
        for r in pcm:
            current=tuple(Q(r['PValue'][key]) for key in ('Lower','Upper'))
            bounds[r['Replicate']]=(max(Q(0),current[0]-previous[1]),min(Q(1),current[1]-previous[0]))
            previous=current
        assert previous[0]<=1<=previous[1]
        assert sum(v[0] for v in bounds.values())<=1<=sum(v[1] for v in bounds.values())
        weights_out += [{'Scenario':scenario,'Replicate':i,'Lower':str(a),'Upper':str(b)} for i,(a,b) in sorted(bounds.items())]
        for arm in sorted({r['Arm'] for r in saved}):
            rows=sorted((r for r in saved if r['Arm']==arm),key=lambda r:r['Replicate'])
            stat={r['Replicate']: Q(0) if r['ObservedFailed'] else
                  abs(Q(points[arm,r['Replicate']]['Estimate'])-contrast) for r in rows}
            result=[]
            for r in rows:
                i=r['Replicate']
                selected=[j for j,t in stat.items() if t>=stat[i]]
                lo=max(Q(0),sum(bounds[j][0] for j in selected))
                hi=min(Q(1),sum(bounds[j][1] for j in selected))
                if r['ObservedFailed'] or stat[i]==0: lo=hi=Q(1)
                assert lo<=hi
                result.append({'Scenario':scenario,'Contrast':str(contrast),'Arm':arm,'Replicate':i,
                    'ObservedFailed':r['ObservedFailed'],'PValueLower':str(lo),'PValueUpper':str(hi),
                    'WitnessRetainsContrast':lo>Q(1,20),'FullySpecifiedNullRejected':hi<=Q(1,20),
                    'NumericalDecisionUnresolved':lo<=Q(1,20)<hi,'CompositeNullRejected':False})
            output+=result
            failed=[r['Replicate'] for r in rows if r['ObservedFailed']]
            summary.append({'Scenario':scenario,'Contrast':str(contrast),'Arm':arm,
                'WitnessRetains':sum(r['WitnessRetainsContrast'] for r in result),
                'FullySpecifiedNullRejected':sum(r['FullySpecifiedNullRejected'] for r in result),
                'NumericalDecisionUnresolved':sum(r['NumericalDecisionUnresolved'] for r in result),
                'FailedNormalizedWeightLower':str(sum(bounds[j][0] for j in failed)),
                'FailedNormalizedWeightUpper':str(sum(bounds[j][1] for j in failed))})
    result={'Rule':'Statistic is absolute initial algorithm-point minus candidate contrast when finite, zero on known completed algorithm failure; observed failures have p=1; unresolved computations are not known failures.',
        'Summary':summary,'Results':output,'NormalizedWeightEnclosures':weights_out,
        'ExactWeightedRankConfigurationsChecked':check_rule(),
        'OtherNuisanceCoordinatesMaximized':False,'IndependentCoverageExperiment':False,
        'ConfidenceIntervalsProduced':0,'NewFits':0,'NewDatasets':0,'NormalIntegralsRecomputed':0,
        'Sources':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in (Path(__file__),source,path)}}
    destination=root/'normal-mc-calibration/failure-rule.json'
    payload=json.dumps(result,indent=2,allow_nan=False)+'\n'
    if destination.exists(): assert destination.read_text()==payload,'Existing evidence differs; preserve it'
    else: destination.write_text(payload)
    print(json.dumps({'Summary':summary,'ExactWeightedRankConfigurationsChecked':result['ExactWeightedRankConfigurationsChecked']},indent=2))


if __name__=='__main__': run(Path(sys.argv[1]))
