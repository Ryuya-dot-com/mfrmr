"""Integral-free, globally valid normal marginal profile upper certificates.

Fenchel's log-sum-exp inequality plus the exact normal moment generating
function give the bound. Exactly feasible rational category probabilities
cancel all nine unrestricted location/step coordinates. Numerical convergence
is not its validity condition. Its slope and contrast scope is explicit.
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


def design(sample,slopes):
    rows=[]
    for person,(roster,y) in enumerate(sample):
        for index,(rr,cc) in enumerate((r-1,c) for r in roster for c in range(3)):
            a=slopes[cc];D=[]
            for k in range(4):
                v=[Q(0)]*9
                v[0]=-a*k*(1,0,-1)[rr];v[1]=-a*k*(0,1,-1)[rr]
                v[2]=-a*k*(Q(-1,2) if cc<2 else Q(1))
                if k in (1,2):v[3+2*cc+k-1]=-a
                D.append(v)
            rows.append((person,y[index],a,(-a/2,a/2,Q(0))[cc],D))
    return rows


def candidate(rows,persons,psi):
    X=np.zeros((len(rows),4,9+persons));offset=np.zeros((len(rows),4))
    observed=[]
    for i,(person,y,a,h,D) in enumerate(rows):
        X[i,:,:9]=np.array(D,float);X[i,:,9+person]=float(a)*np.arange(4)
        offset[i]=float(h*psi)*np.arange(4);observed.append(y)
    observed=np.array(observed);selected=X[np.arange(len(rows)),observed].sum(axis=0)
    def terms(z):
        eta=np.einsum('ikj,j->ik',X,z)+offset
        logp=eta-logsumexp(eta,axis=1,keepdims=True)
        p=np.exp(logp)
        f=-logp[np.arange(len(rows)),observed].sum()+np.dot(z[9:],z[9:])/2
        g=np.einsum('ik,ikj->j',p,X)-selected;g[9:]+=z[9:]
        return f,g,p
    def hessian(z):
        p=terms(z)[2];mean=np.einsum('ik,ikj->ij',p,X)
        h=np.einsum('ik,ikj,ikl->jl',p,X,X)-mean.T@mean
        h[9:,9:]+=np.eye(persons)
        return h
    start=np.r_[[-.3,0,.3,-.6,-.4,-.8,-.9,-.4,-.5],np.zeros(persons)]
    fit=minimize(lambda z:terms(z)[:2],start,jac=True,hess=hessian,
        method='trust-exact',options={'gtol':1e-9,'maxiter':1000})
    f,g,p=terms(fit.x)
    return p,{'JointMAPParameters':fit.x.tolist(),'JointMAPLogLikelihoodApproximate':-float(f),
        'OptimizerSuccess':bool(fit.success),'OptimizerMessage':str(fit.message),
        'CandidateMaximumScore':float(max(abs(g)))}


def solve_exact(matrix,rhs):
    a=[list(row)+[v] for row,v in zip(matrix,rhs)];n=len(a)
    for j in range(n):
        pivot=next(i for i in range(j,n) if a[i][j])
        a[j],a[pivot]=a[pivot],a[j]
        z=a[j][j];a[j]=[v/z for v in a[j]]
        for i in range(n):
            if i!=j and a[i][j]:
                factor=a[i][j];a[i]=[v-factor*w for v,w in zip(a[i],a[j])]
    return [row[-1] for row in a]


def feasible_probabilities(rows,p):
    denominator=2**80;numerators=[];means=[]
    G=[[Q(0) for k in range(9)] for j in range(9)];residual=[Q(0)]*9
    for (_,y,a,h,D),prob in zip(rows,p):
        nums=[max(1,round(float(v)*denominator)) for v in prob]
        nums[int(np.argmax(prob))]+=denominator-sum(nums);assert min(nums)>0
        q=[Q(v,denominator) for v in nums];numerators.append(nums)
        mean=[sum(q[k]*D[k][j] for k in range(4)) for j in range(9)];means.append(mean)
        for j in range(9):
            residual[j]+=D[y][j]-mean[j]
            for l in range(j,9):
                value=sum(q[k]*D[k][j]*D[k][l] for k in range(4))-mean[j]*mean[l]
                G[j][l]+=value
                if l!=j:G[l][j]+=value
    v=solve_exact(G,residual)
    corrected=[];balance=[Q(0)]*9
    for (_,y,a,h,D),nums,mean in zip(rows,numerators,means):
        q=[Q(n,denominator)*(1+sum((D[k][j]-mean[j])*v[j] for j in range(9)))
           for k,n in enumerate(nums)]
        assert min(q)>0 and sum(q)==1,'Dual projection is not feasible; no upper bound'
        for j in range(9):balance[j]+=D[y][j]-sum(q[k]*D[k][j] for k in range(4))
        corrected.append(q)
    assert balance==[0]*9,'Unrestricted location/step terms must cancel exactly'
    return corrected,{'ProbabilityDenominator':str(denominator),'ProbabilityNumerators':numerators,
                      'ProjectionMultiplier':list(map(str,v))}


def certificate(sample,psi,slopes,base):
    assert all(a>0 for a in slopes) and math.prod(slopes)==1
    rows=design(sample,slopes);p,fit=candidate(rows,len(sample),psi)
    probabilities,witness=feasible_probabilities(rows,p)
    IV,iv,ends=(base[k] for k in ('IV','iv','ends'))
    entropy=IV.mpf(0);scores=[Q(0)]*len(sample);contrast=Q(0)
    for (person,y,a,h,D),q in zip(rows,probabilities):
        entropy+=sum(iv(v)*IV.ln(iv(v)) for v in q)
        residual=y-sum(k*q[k] for k in range(4))
        scores[person]+=a*residual;contrast+=h*residual
    base_upper=ends(entropy+iv(sum(g*g for g in scores)/2))[1]
    upper=base_upper+psi*contrast
    assert float(upper)-fit['JointMAPLogLikelihoodApproximate']>-1e-8
    return {'Contrast':str(psi),'Slopes':list(map(str,slopes)),
        'GlobalMarginalLogLikelihoodUpper':str(upper),
        'AffineUpperIntercept':str(base_upper),'AffineUpperSlope':str(contrast),
        'AllLocationAndStepNuisanceCovered':True,'DualFeasibilityExact':True,
        'ApproximateJointMAPDualityGap':float(upper)-fit['JointMAPLogLikelihoodApproximate'],
        'CompleteMCNumeratorBound':False,'AllSlopeSupremumCertified':False,
        'Witness':witness,**fit}


def run(root,indices,psi,slopes,out):
    base_path=Path('inst/validation/jml-normal-importance-mc-20261003.py')
    base=runpy.run_path(str(base_path));data,unused,inputs=base['read_inputs'](root)
    out.mkdir(parents=True,exist_ok=True)
    manifest={'Sources':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in (Path(__file__),base_path)},
        'Inputs':inputs,'Replicates':indices,'Contrast':str(psi),'Slopes':list(map(str,slopes)),
        'NewResponseDatasets':0,'OriginalJMLRefits':0,
        'Scope':'Affine contrast upper envelopes for fixed slopes and all location/step values; not final intervals.'}
    text=json.dumps(manifest,indent=2)+'\n';path=out/'manifest.json'
    if path.exists():assert path.read_text()==text
    else:path.write_text(text)
    summary=[]
    for index in indices:
        path=out/f'replicate-{index:02d}.json'
        if path.exists():record=json.loads(path.read_text())
        else:
            record=certificate(data[index-1],psi,slopes,base);record['Replicate']=index
            path.write_text(json.dumps(record,indent=2)+'\n')
        summary.append({'Path':str(path),'SHA256':hashlib.sha256(path.read_bytes()).hexdigest(),
            'Replicate':index,'UpperApproximate':float(Q(record['GlobalMarginalLogLikelihoodUpper'])),
            'AffineSlopeApproximate':float(Q(record['AffineUpperSlope'])),
            'JointMAPDualityGap':record['ApproximateJointMAPDualityGap']})
        print(summary[-1],flush=True)
    path=out/'summary.json';text=json.dumps({'Results':summary,'Provenance':manifest},indent=2)+'\n'
    if path.exists():assert path.read_text()==text
    else:path.write_text(text)


if __name__=='__main__':
    first,last=map(int,sys.argv[2].split(':'));a,b=map(Q,sys.argv[4:6])
    run(Path(sys.argv[1]),list(range(first,last+1)),Q(sys.argv[3]),[a,b,1/(a*b)],Path(sys.argv[6]))
