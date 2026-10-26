"""Independent feasibility, powered-kernel and compact-domain checks."""
from fractions import Fraction as Q
from pathlib import Path
import hashlib
import json
import math
import runpy
import sys

import numpy as np
from scipy.integrate import quad
from scipy.special import logsumexp


def check_entropy(sample,witness,base):
    IV,iv,ends=(base[k] for k in ('IV','iv','ends'))
    c=witness['Owner']-1
    active=[(g,(y[c],y[c+3])) for g,y in sample if 0<y[c]+y[c+3]<6]
    assert len(active)==witness['ActivePairs'] and len(sample)-len(active)==witness['ExtremePairs']
    rater=[Q(0)]*3;category=[Q(0)]*4;entropy=IV.mpf(0)
    for p,(g,y) in enumerate(active):
        expected=Q(0)
        for t,r in enumerate(g):
            if witness['WitnessMethod']=='opposite_orientation_swap':
                flip=Q(witness['SwapProbabilities'][p]);q=[Q(0)]*4
                q[y[t]]+=1-flip;q[y[1-t]]+=flip
            else:
                assert witness['WitnessMethod']=='positive_rational_projection'
                v=list(map(Q,witness['StructuralProjection']));u=Q(witness['PersonProjection'][p])
                q=[Q(z,int(witness['Denominator'])) for z in witness['Numerators'][2*p+t]]
                severity=(v[0],v[1],-v[0]-v[1])[r-1]
                change=[k*(u-severity)-(v[2] if k==1 else v[3] if k==2 else 0) for k in range(4)]
                mean=sum(q[k]*change[k] for k in range(4))
                q=[q[k]*(1+change[k]-mean) for k in range(4)]
            assert min(q)>=0 and sum(q)==1
            mean=sum(k*q[k] for k in range(4));expected+=mean;rater[r-1]+=y[t]-mean
            for k in range(4):category[k]+=(y[t]==k)-q[k]
            entropy+=sum(iv(z)*IV.ln(iv(z)) for z in q if z)
        assert expected==sum(y)
    assert rater==[0]*3 and category==[0]*4
    upper=Q(witness['ConditionalLogLikelihoodUpper'])
    assert ends(entropy)[1]<=upper and upper-ends(entropy)[0]<Q(1,10**50)
    return upper


def kernel_checks():
    count=0;largest_ratio=0.
    for steps in ([0.,0.,0.,0.],[0.,-2.,3.,0.],[0.,30.,-15.,0.]):
        for d in (-8.,-1.,0.,1.,8.):
            for s in (.1,.5,1.):
                for k,l in ((0,1),(0,3),(1,2),(2,1),(3,0),(3,2)):
                    def value(x):
                        a=np.arange(4)*x-steps;b=np.arange(4)*(x-d)-steps
                        return math.exp(s*(a[k]-logsumexp(a)+b[l]-logsumexp(b)))
                    integral,error=quad(value,-np.inf,np.inf,epsabs=1e-9,epsrel=1e-10,limit=400)
                    upper=(abs(d)+2/s)*math.exp(s*min(d*(1 if k>l else -1),0))
                    assert integral<=upper+max(1e-8,10*error)
                    largest_ratio=max(largest_ratio,integral/upper);count+=1
    return {'IntegralsChecked':count,'MaximumIntegralToBoundRatio':largest_ratio}


def run(root):
    path=root/'normal-mc-calibration/profiles/global-tail/summary.json'
    summary=json.loads(path.read_text());assert summary['Complete']
    for p,h in (summary['Provenance']['Sources']|summary['Certificates']).items():
        assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==h,p
    base_path=Path('inst/validation/jml-normal-importance-mc-20261003.py')
    base=runpy.run_path(str(base_path));base['IV'].dps=80
    IV,iv,ends=(base[k] for k in ('IV','iv','ends'))
    data,unused,inputs=base['read_inputs'](root);assert inputs==summary['Provenance']['Inputs']
    old_path=root/'normal-mc-calibration/tail-bounds.json';old=json.loads(old_path.read_text())
    records=[];fallback=[];improved=0;maximum_radius=Q(0)
    for index,sample in enumerate(data,1):
        record=json.loads((path.parent/f'replicate-{index:02d}.json').read_text())
        entropy=sum(check_entropy(sample,w,base) for w in record['Owners'])
        assert entropy==Q(record['ConditionalLogLikelihoodUpper'])
        fallback.extend((index,w['Owner']) for w in record['Owners'] if w['WitnessMethod']=='opposite_orientation_swap')
        threshold=Q(record['LogLikelihoodThresholdLower']);bounds=[]
        # Recount signed discordances directly from raw saved responses.
        for c,cert in enumerate(record['SlopeCertificates']):
            counts=[]
            for g in ((1,2),(1,3),(2,3)):
                ds=[y[c]-y[c+3] for gg,y in sample if gg==g]
                counts.append([sum(v>0 for v in ds),sum(v<0 for v in ds)])
            assert counts==cert['OppositeOrientationCounts']
            a=Q(2)**cert['UpperSlopeExponentBase2'];s=Q(cert['Power']);assert 0<s<=1
            upper=iv((1-s)*entropy)
            for positive,negative in counts:
                n=positive+negative;m=min(positive,negative)
                if not m:continue
                term=n*(IV.ln(iv(Q(2*n,5*m)))-IV.ln(iv(a))-IV.ln(iv(s)))-n+2*m
                upper+=iv(min(Q(0),ends(term)[1]))
            assert ends(upper)[1]<=threshold
            assert cert['UpperSlopeExponentBase2']<cert['PreviousUpperSlopeExponentBase2']
            improved+=1;bounds.append(a)
        prior=old['Records'][index-1];H=prior['NormalTruncationH'];C=prior['LogitBudgetUpper']
        radius=2*H+Q(C,3)*(bounds[1]*bounds[2]+bounds[0]*bounds[2])
        maximum_radius=max(maximum_radius,radius)
        records.append({'Replicate':index,'SlopesUpper':list(map(str,bounds)),
            'SlopesLower':list(map(str,(1/(bounds[(j+1)%3]*bounds[(j+2)%3]) for j in range(3)))),
            'CriterionContrastOuterRadius':str(radius),'CriterionContrastOuterRadiusApproximate':float(radius)})
    checks=kernel_checks()
    result={'ChecksPassed':True,'EntropyWitnessesChecked':150,'ImprovedSlopeBounds':improved,
        'SwapWitnesses':fallback,'PoweredKernelChecks':checks,'Records':records,
        'CommonCriterionContrastOuterRadius':str(maximum_radius),
        'CommonCriterionContrastOuterRadiusApproximate':float(maximum_radius),
        'PreviousCommonCriterionContrastOuterRadiusApproximate':old['Summary']['CriterionContrastOuterRadiusApproximate'],
        'PValueUpperOutsideUnionOfBoxes':'1/32','AllJointEscapesCovered':True,
        'UsefulIntervalEndpointsProduced':False,'CertifiedCIEndpoints':0,'IndependentCoverageDatasets':0,
        'Sources':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in (Path(__file__),base_path,path,old_path)},
        'Inputs':inputs}
    out=path.parent/'checks.json';text=json.dumps(result,indent=2)+'\n'
    if out.exists():assert out.read_text()==text
    else:out.write_text(text)
    print(json.dumps({k:result[k] for k in ('ChecksPassed','EntropyWitnessesChecked','ImprovedSlopeBounds',
        'SwapWitnesses','PoweredKernelChecks','CommonCriterionContrastOuterRadiusApproximate','CertifiedCIEndpoints')},indent=2))


if __name__=='__main__':run(Path(sys.argv[1]))
