"""Replay dual feasibility independently and bound the complete 50-term sum."""
from fractions import Fraction as Q
from pathlib import Path
import hashlib
import json
import runpy
import sys


def check(sample,record,base):
    IV,iv,ends=(base[k] for k in ('IV','iv','ends'))
    witness=record['Witness'];den=int(witness['ProbabilityDenominator'])
    nums=witness['ProbabilityNumerators'];v=list(map(Q,witness['ProjectionMultiplier']))
    a=list(map(Q,record['Slopes']));psi=Q(record['Contrast'])
    entropy=IV.mpf(0);rater=[Q(0)]*3;owner=[Q(0)]*3
    steps=[[Q(0)]*2 for unused in range(3)];person_scores=[];row=0
    for roster,ys in sample:
        total=Q(0)
        for index,(rr,c) in enumerate((r-1,c) for r in roster for c in range(3)):
            q=[Q(n,den) for n in nums[row]];row+=1
            assert min(q)>0 and sum(q)==1
            location=(v[0],v[1],-v[0]-v[1])[rr]+(-v[2]/2 if c<2 else v[2])
            changes=[-a[c]*k*location-(a[c]*v[3+2*c+k-1] if k in (1,2) else 0)
                     for k in range(4)]
            mean=sum(z*t for z,t in zip(q,changes))
            q=[z*(1+t-mean) for z,t in zip(q,changes)]
            assert min(q)>0 and sum(q)==1
            residual=a[c]*(ys[index]-sum(k*q[k] for k in range(4)))
            total+=residual;rater[rr]+=residual;owner[c]+=residual
            for k in (1,2):steps[c][k-1]+=(ys[index]==k)-q[k]
            entropy+=sum(iv(z)*IV.ln(iv(z)) for z in q)
        person_scores.append(total)
    assert row==len(nums)
    assert rater[0]==rater[1]==rater[2]
    assert owner[2]==(owner[0]+owner[1])/2
    assert steps==[[0,0]]*3
    h=(owner[1]-owner[0])/2
    assert h==Q(record['AffineUpperSlope'])
    intercept=entropy+iv(sum(g*g for g in person_scores)/2)
    saved=Q(record['AffineUpperIntercept'])
    assert ends(intercept)[0]<=saved and saved-ends(intercept)[0]<Q(1,10**35)
    assert saved+psi*h==Q(record['GlobalMarginalLogLikelihoodUpper'])
    # Independent primal lower evaluation, using raw structural equations.
    x=list(map(Q,record['JointMAPParameters']))
    raters=[x[0],x[1],-x[0]-x[1]];criteria=[(-x[2]+psi)/2,(-x[2]-psi)/2,x[2]]
    primal=-iv(sum(z*z for z in x[9:]))/2
    for person,(roster,ys) in enumerate(sample):
        for index,(rr,c) in enumerate((r-1,c) for r in roster for c in range(3)):
            s=[Q(0),x[3+2*c],x[4+2*c],Q(0)]
            logits=[iv(a[c]*(k*(x[9+person]-raters[rr]-criteria[c])-s[k])) for k in range(4)]
            shift=max(ends(z)[1] for z in logits)
            primal+=logits[ys[index]]-iv(shift)-IV.ln(sum(IV.exp(z-iv(shift)) for z in logits))
    gap=saved+psi*h-ends(primal)[0]
    assert 0<=gap<Q(1,10**7)
    return gap


def envelope_ray(records,exponents,rho,sharp,base):
    IV,iv,ends=(base[k] for k in ('IV','iv','ends'))
    t=1-rho;C,root=sharp(1+rho,t,base)
    I=[Q(z['AffineUpperIntercept']) for z in records]
    H=[Q(z['AffineUpperSlope']) for z in records]
    assert all(v>0 for v in H) or all(v<0 for v in H)
    direction=-1 if H[0]>0 else 1
    def envelope(psi):
        return sum(iv(C)**120*IV.exp(iv(t*(intercept+h*psi)))*iv(2)**e
                   for intercept,h,e in zip(I,H,exponents))/len(records)
    outer=Q(records[0]['Contrast']);step=Q(1)
    while ends(envelope(outer))[1]>Q(1,20):
        outer+=direction*step;step*=2
    inner=outer-direction*step
    while ends(envelope(inner))[0]<=Q(1,20):
        step*=2;inner-=direction*step
    while abs(outer-inner)>Q(1,1000):
        mid=(outer+inner)/2;value=ends(envelope(mid))
        if value[1]<=Q(1,20):outer=mid
        elif value[0]>Q(1,20):inner=mid
        else:raise ArithmeticError('Refine interval precision at the envelope threshold')
    upper=ends(envelope(outer))[1]
    assert upper<=Q(1,20)
    return {'RelativeSlopeLower':str(1-rho),'RelativeSlopeUpper':str(1+rho),
        'ContrastRay':'left' if direction<0 else 'right','ExcludedRayBoundary':str(outer),
        'ExcludedRayBoundaryApproximate':float(outer),'EnvelopeCrossingBracket':list(map(str,sorted((outer,inner)))),
        'CompleteNumeratorPValueUpper':str(upper),'CompleteNumeratorPValueUpperApproximate':float(upper),
        'SharpConstantUpper':str(C),'SharpConstantRootBracket':root,'Terms':len(records),
        'InclusiveStatisticIndicatorsUpperBoundedByOne':True,
        'AllLocationAndStepNuisanceCovered':True,'AllSlopesCovered':False,
        'ObservedPointFailureOverride':'Whole-line confidence set; these exclusions do not apply.'}


def run(root):
    directory=root/'normal-mc-calibration/profiles'
    base_path=Path('inst/validation/jml-normal-importance-mc-20261003.py')
    sharp_path=Path('inst/validation/jml-normal-profile-regions-check-20261004.py')
    base=runpy.run_path(str(base_path));base['IV'].dps=60
    sharp=runpy.run_path(str(sharp_path))['sharp_constant']
    data,unused,inputs=base['read_inputs'](root)
    tail_path=root/'normal-mc-calibration/tail-bounds.json';tails=json.loads(tail_path.read_text())
    assert inputs==tails['Inputs']
    for p,h in tails['Sources'].items():assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==h,p
    exponents=[r['ProposalProbabilityLowerPowerOfTwo'] for r in tails['Records']]
    output=[];gaps=[];dependencies=[Path(__file__),base_path,sharp_path,tail_path]
    for name in ('dual-unit','dual-small-small-large'):
        summary_path=directory/name/'summary.json';summary=json.loads(summary_path.read_text())
        assert summary['Provenance']['Inputs']==inputs
        for p,h in summary['Provenance']['Sources'].items():
            assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==h,p
        assert [r['Replicate'] for r in summary['Results']]==list(range(1,51))
        records=[]
        for item in summary['Results']:
            path=Path(item['Path']);assert hashlib.sha256(path.read_bytes()).hexdigest()==item['SHA256']
            record=json.loads(path.read_text());records.append(record)
            gaps.append(check(data[item['Replicate']-1],record,base))
        boxes=[envelope_ray(records,exponents,rho,sharp,base) for rho in (Q(1,10),Q(1,5),Q(1,4))]
        output.append({'ReferenceSlopes':records[0]['Slopes'],'ReferenceContrast':records[0]['Contrast'],
            'CertificatesChecked':len(records),'SlopeRegions':boxes})
        dependencies.append(summary_path)
        print(name,'50 exact dual constraints and primal/dual gaps checked',flush=True)
    result={'ChecksPassed':True,'DualCertificatesChecked':len(gaps),
        'MaximumCertifiedJointMAPDualityGap':str(max(gaps)),
        'MaximumCertifiedJointMAPDualityGapApproximate':float(max(gaps)),
        'Results':output,'Complete50TermUpperBoundsWithinNamedSlopeRegions':True,
        'AllSlopeSupremumCertified':False,'CertifiedCIEndpoints':0,'IndependentCoverageDatasets':0,
        'Sources':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in dependencies},'Inputs':inputs}
    path=directory/'dual-region-checks.json';text=json.dumps(result,indent=2)+'\n'
    if path.exists():assert path.read_text()==text
    else:path.write_text(text)
    print(json.dumps({k:result[k] for k in ('ChecksPassed','DualCertificatesChecked',
        'MaximumCertifiedJointMAPDualityGapApproximate','CertifiedCIEndpoints')},indent=2))


if __name__=='__main__':run(Path(sys.argv[1]))
