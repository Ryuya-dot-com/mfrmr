"""Uniform slope-tail bounds from conditional entropy and powered discordance.

Research calculation on saved inputs. Owner-specific free abilities enlarge
the model only for an upper bound; original estimates and data are unchanged.
Every accepted entropy witness has exact rational sufficient-statistic balance.
"""
from fractions import Fraction as Q
from pathlib import Path
import hashlib
import json
import math
import runpy
import sys

import numpy as np
from scipy.optimize import minimize
from scipy.special import logsumexp


def owner_bound(sample,owner,base,solve):
    active=[(g,(y[owner],y[owner+3])) for g,y in sample if 0<y[owner]+y[owner+3]<6]
    n=len(active);D=np.zeros((2*n,4,4+n));observed=[]
    for p,(g,y) in enumerate(active):
        for t,r in enumerate(g):
            D[2*p+t,:,0]=-np.arange(4)*(1,0,-1)[r-1]
            D[2*p+t,:,1]=-np.arange(4)*(0,1,-1)[r-1]
            D[2*p+t,1,2]=-1;D[2*p+t,2,3]=-1
            D[2*p+t,:,4+p]=np.arange(4);observed.append(y[t])
    observed=np.array(observed);target=D[np.arange(2*n),observed].sum(0)
    def terms(x):
        eta=np.einsum('ikj,j->ik',D,x);lp=eta-logsumexp(eta,axis=1,keepdims=True)
        prob=np.exp(lp)
        return -lp[np.arange(2*n),observed].sum(),np.einsum('ik,ikj->j',prob,D)-target,prob
    def hessian(x):
        prob=terms(x)[2];mean=np.einsum('ik,ikj->ij',prob,D)
        return np.einsum('ik,ikj,ikl->jl',prob,D,D)-mean.T@mean
    fit=minimize(lambda z:terms(z)[:2],np.zeros(4+n),jac=True,hess=hessian,
        method='trust-exact',options={'gtol':1e-9,'maxiter':1000})
    prob=terms(fit.x)[2];den=2**60;nums=[];means=[]
    A=[[Q(0) for k in range(4)] for j in range(4)]
    B=[[Q(0) for p in range(n)] for j in range(4)];C=[Q(0)]*n
    rs=[Q(0)]*4;rt=[Q(0)]*n;design=D[:,:,:4].astype(int).tolist()
    for i,(row,p0) in enumerate(zip(design,prob)):
        counts=[max(1,round(float(v)*den)) for v in p0]
        counts[int(np.argmax(p0))]+=den-sum(counts);assert min(counts)>0
        nums.append(counts);q=[Q(v,den) for v in counts]
        mu=[sum(q[k]*row[k][j] for k in range(4)) for j in range(4)]
        theta=sum(q[k]*k for k in range(4));means.append((mu,theta));p=i//2
        C[p]+=sum(q[k]*k*k for k in range(4))-theta*theta
        rt[p]+=int(observed[i])-theta
        for j in range(4):
            rs[j]+=row[int(observed[i])][j]-mu[j]
            B[j][p]+=sum(q[k]*row[k][j]*k for k in range(4))-mu[j]*theta
            for l in range(4):
                A[j][l]+=sum(q[k]*row[k][j]*row[k][l] for k in range(4))-mu[j]*mu[l]
    assert all(v>0 for v in C)
    schur=[[A[j][l]-sum(B[j][p]*B[l][p]/C[p] for p in range(n)) for l in range(4)] for j in range(4)]
    rhs=[rs[j]-sum(B[j][p]*rt[p]/C[p] for p in range(n)) for j in range(4)]
    try:
        v=solve(schur,rhs);u=[(rt[p]-sum(B[j][p]*v[j] for j in range(4)))/C[p] for p in range(n)]
        corrected=[]
        for i,(row,counts,(mu,theta)) in enumerate(zip(design,nums,means)):
            q=[Q(counts[k],den)*(1+sum((row[k][j]-mu[j])*v[j] for j in range(4))+(k-theta)*u[i//2]) for k in range(4)]
            corrected.append(q)
        feasible=all(min(q)>=0 and sum(q)==1 for q in corrected)
    except StopIteration:
        v=u=[];feasible=False
    method='positive_rational_projection';swaps=[]
    if not feasible:
        # A separated auxiliary model need not have an interior entropy optimum.
        # A score-preserving swap mixture is an exact feasible, weaker witness.
        method='opposite_orientation_swap';corrected=[]
        for g,y in active:
            positive=sum(max(0,z[0]-z[1]) for gg,z in active if gg==g)
            negative=sum(max(0,z[1]-z[0]) for gg,z in active if gg==g)
            flip=(Q(negative,positive+negative) if y[0]>y[1] else
                  Q(positive,positive+negative) if y[1]>y[0] else Q(0))
            swaps.append(str(flip))
            for t in (0,1):
                q=[Q(0)]*4;q[y[t]]+=1-flip;q[y[1-t]]+=flip
                corrected.append(q)
    # Independent raw-statistic balance checks, without matrix multiplication.
    raters=[Q(0)]*3;categories=[Q(0)]*4
    for p,(g,y) in enumerate(active):
        expected=Q(0)
        for t,r in enumerate(g):
            q=corrected[2*p+t];mean=sum(k*q[k] for k in range(4))
            expected+=mean;raters[r-1]+=y[t]-mean
            for k in range(4):categories[k]+=(y[t]==k)-q[k]
        assert expected==sum(y)
    assert raters==[0]*3 and categories==[0]*4
    IV,iv,ends=(base[k] for k in ('IV','iv','ends'))
    entropy=sum((iv(q)*IV.ln(iv(q)) for row in corrected for q in row if q),IV.mpf(0))
    upper=ends(entropy)[1];x=list(map(lambda z:Q(float(z)),fit.x));primal=IV.mpf(0)
    for p,(g,y) in enumerate(active):
        for t,r in enumerate(g):
            severity=(x[0],x[1],-x[0]-x[1])[r-1]
            logits=[iv(k*(x[4+p]-severity)-(x[2] if k==1 else x[3] if k==2 else 0)) for k in range(4)]
            shift=max(ends(z)[1] for z in logits)
            primal+=logits[y[t]]-iv(shift)-IV.ln(sum(IV.exp(z-iv(shift)) for z in logits))
    gap=upper-ends(primal)[0];assert gap>=0
    return {'Owner':owner+1,'ConditionalLogLikelihoodUpper':str(upper),
        'ConditionalDualityGapUpper':str(gap),'ActivePairs':n,'ExtremePairs':len(sample)-n,
        'Numerators':nums,'Denominator':str(den),'StructuralProjection':list(map(str,v)),
        'PersonProjection':list(map(str,u)),'CandidateParameters':fit.x.tolist(),
        'OptimizerSuccess':bool(fit.success),'ExactBalanceVerified':True,
        'WitnessMethod':method,'SwapProbabilities':swaps}


def power_tail(a,s,counts,base):
    IV,iv,ends=(base[k] for k in ('IV','iv','ends'))
    result=Q(0)
    for positive,negative in counts:
        n=positive+negative;m=min(positive,negative)
        if not m:continue
        bound=n*IV.ln(iv(Q(2*n,5*m)/(a*s)))-n+2*m
        result+=min(Q(0),ends(bound)[1])
    return result


def run(root,out):
    base_path=Path('inst/validation/jml-normal-importance-mc-20261003.py')
    dual_path=Path('inst/validation/jml-normal-profile-dual-20261004.py')
    tails_path=root/'normal-mc-calibration/tail-bounds.json'
    base=runpy.run_path(str(base_path));base['IV'].dps=60
    solve=runpy.run_path(str(dual_path))['solve_exact']
    data,unused,inputs=base['read_inputs'](root);tails=json.loads(tails_path.read_text())
    assert tails['Inputs']==inputs
    for path,digest in tails['Sources'].items():assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest
    out.mkdir(parents=True,exist_ok=True)
    sources={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in (Path(__file__),base_path,dual_path,tails_path)}
    manifest={'Sources':sources,'Inputs':inputs,'NewResponseDatasets':0,'OriginalJMLRefits':0,
        'Scope':'Uniform slope tails for all structural nuisance values; no CI endpoints or independent coverage.'}
    path=out/'manifest.json';text=json.dumps(manifest,indent=2)+'\n'
    if path.exists():assert path.read_text()==text
    else:path.write_text(text)
    IV,iv,ends=(base[k] for k in ('IV','iv','ends'))
    records=[]
    for index,(sample,old) in enumerate(zip(data,tails['Records']),1):
        path=out/f'replicate-{index:02d}.json'
        if path.exists():record=json.loads(path.read_text())
        else:
            owners=[owner_bound(sample,c,base,solve) for c in range(3)]
            entropy=sum(Q(z['ConditionalLogLikelihoodUpper']) for z in owners)
            epsilon_log=ends(-(old['ProposalProbabilityLowerPowerOfTwo']+5)*IV.ln(2))[0]
            bounds=[]
            for old_bound in old['SlopeCertificates']:
                counts=old_bound['OppositeOrientationCounts']
                n=sum(p+m for p,m in counts if min(p,m)>0)
                s=min(Q(1),Q(n)/(-entropy));assert 0<s<=1
                k=0
                while (1-s)*entropy+power_tail(Q(2)**k,s,counts,base)>epsilon_log:k+=1
                bounds.append({'UpperSlopeExponentBase2':k,'Power':str(s),
                    'LogLikelihoodUpperBeyondCutoff':str((1-s)*entropy+power_tail(Q(2)**k,s,counts,base)),
                    'PreviousUpperSlopeExponentBase2':old_bound['UpperSlopeExponentBase2'],
                    'OppositeOrientationCounts':counts})
            record={'Replicate':index,'Owners':owners,'ConditionalLogLikelihoodUpper':str(entropy),
                'SlopeCertificates':bounds,'LogLikelihoodThresholdLower':str(epsilon_log),
                'AllOtherStructuralParametersCovered':True}
            path.write_text(json.dumps(record,indent=2)+'\n')
        records.append(record)
        print(index,'entropy',round(float(Q(record['ConditionalLogLikelihoodUpper'])),3),
            'slope exponents',[z['UpperSlopeExponentBase2'] for z in record['SlopeCertificates']],flush=True)
    summary={'Records':[{'Replicate':r['Replicate'],'SlopeExponents':[z['UpperSlopeExponentBase2'] for z in r['SlopeCertificates']],
        'PreviousSlopeExponents':[z['PreviousUpperSlopeExponentBase2'] for z in r['SlopeCertificates']]} for r in records],
        'Provenance':manifest,'Certificates':{str(out/f'replicate-{r["Replicate"]:02d}.json'):
            hashlib.sha256((out/f'replicate-{r["Replicate"]:02d}.json').read_bytes()).hexdigest() for r in records},
        'Complete':len(records)==50,'CertifiedCIEndpoints':0,'IndependentCoverageDatasets':0}
    (out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')


if __name__=='__main__':run(Path(sys.argv[1]),Path(sys.argv[2]))
