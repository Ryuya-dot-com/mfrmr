"""Repair exploratory slope profiling with adaptive normal integration.

These are nuisance witnesses, not global upper bounds or confidence endpoints.
The actual JML estimators and response samples are never refitted/regenerated.
"""
from pathlib import Path
import hashlib
import json
import math
import runpy
import sys

import numpy as np
from scipy.integrate import quad_vec
from scipy.optimize import minimize, LinearConstraint, Bounds, brentq
from scipy.optimize._numdiff import approx_derivative
from scipy.special import logsumexp


class AdaptiveLikelihood:
    def __init__(self,sample,parameter_arrays,tolerance=1e-10):
        self.cells=np.array([[(r-1)*3+c for r in roster for c in range(3)] for roster,y in sample])
        self.scores=np.array([y for roster,y in sample])
        self.parameter_arrays=parameter_arrays
        self.tolerance=tolerance

    def evaluate(self,x,psi):
        r,c,s,a=self.parameter_arrays(x,psi)
        locations=np.repeat(r,3)+np.tile(c,3);cum=np.tile(s,(3,1));slopes=np.tile(a,3)
        design=np.zeros((9,4,11))
        for rr in range(3):
            for cc in range(3):
                cell=rr*3+cc
                design[cell,:,0]=-a[cc]*np.arange(4)*(1,0,-1)[rr]
                design[cell,:,1]=-a[cc]*np.arange(4)*(0,1,-1)[rr]
                design[cell,:,2]=-a[cc]*np.arange(4)*(-.5,-.5,1)[cc]
                for k in (1,2):design[cell,k,3+2*cc+k-1]=-a[cc]
        loglike=0.;gradient=np.zeros(11)
        for cells,y in zip(self.cells,self.scores):
            aa=slopes[cells];location=locations[cells];ss=cum[cells];D=design[cells].copy()
            def density(theta):
                logits=aa[:,None]*((theta-location[:,None])*np.arange(4)-ss)
                logp=logits-logsumexp(logits,axis=1,keepdims=True)
                p=np.exp(logp)
                logf=float(logp[np.arange(6),y].sum()-theta*theta/2)
                slope=float(-theta+sum(aa*(y-p@np.arange(4))))
                return logits,p,logf,slope
            mode=brentq(lambda theta:density(theta)[3],-1-sum(aa*(3-y)),1+sum(aa*y),xtol=1e-12)
            peak=density(mode)[2]
            points=sorted({float(location[cell]+(ss[cell,l]-ss[cell,k])/(l-k)-mode)
                for cell in range(6) for k in range(4) for l in range(k+1,4)
                if -12<location[cell]+(ss[cell,l]-ss[cell,k])/(l-k)-mode<12})
            def integrand(offset):
                logits,p,logf,unused=density(mode+offset)
                value=np.exp(logf-peak)
                D[:,:,9]=logits*np.where(cells%3==0,1,np.where(cells%3==2,-1,0))[:,None]
                D[:,:,10]=logits*np.where(cells%3==1,1,np.where(cells%3==2,-1,0))[:,None]
                score=(D[np.arange(6),y]-np.einsum('ck,ckj->cj',p,D)).sum(axis=0)
                return np.r_[value,value*score]
            integral,error,info=quad_vec(integrand,-12,12,points=points,epsabs=1e-15,
                epsrel=self.tolerance,norm='max',full_output=True)
            if not info.success or integral[0]<=0:
                raise ArithmeticError('Adaptive scaled marginal integral is unresolved')
            loglike+=peak+math.log(integral[0])-math.log(2*math.pi)/2
            gradient+=integral[1:]/integral[0]
        return loglike,gradient


def run(root):
    old=Path('inst/validation/jml-normal-mc-profile-20261004.py')
    base=Path('inst/validation/jml-normal-importance-mc-20261003.py')
    profile=runpy.run_path(str(old));read=runpy.run_path(str(base))
    data,unused,inputs=read['read_inputs'](root)
    directory=root/'normal-mc-calibration/profiles'
    before=json.loads((directory/'adaptive-check.json').read_text())
    for p,h in before['Sources'].items():assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==h,p
    out=directory/'adaptive-scaled';out.mkdir(exist_ok=True)
    provenance={'Sources':{str(p):hashlib.sha256(p.read_bytes()).hexdigest()
        for p in (Path(__file__),old,base,directory/'adaptive-check.json')},'Inputs':inputs,
        'Scope':'Numerical integration repair for exploratory nuisance points. Not complete MC inversion or independent coverage.'}
    manifest=json.dumps(provenance,indent=2)+'\n'
    if (out/'manifest.json').exists():assert (out/'manifest.json').read_text()==manifest
    else:(out/'manifest.json').write_text(manifest)
    start=np.array([-.3,0,.3,-.6,-.4,-.8,-.9,-.4,-.5,0.,0.])
    check=AdaptiveLikelihood(data[0],profile['parameter_arrays'])
    g=check.evaluate(start,3)[1]
    numerical=approx_derivative(lambda z:check.evaluate(z,3)[0],start).ravel()
    difference=float(max(abs(g-numerical)));assert difference<1e-7
    print('Adaptive analytic/finite-difference gradient check',difference,flush=True)
    lower=np.r_[np.full(9,-np.inf),[-math.log(100)]*2]
    upper=np.r_[np.full(9,np.inf),[math.log(100)]*2]
    slope_sum=np.zeros((1,11));slope_sum[0,9:]=1
    output=[]
    for old_path in sorted(directory.glob('replicate-*-psi-*.json')):
        saved=json.loads(old_path.read_text());dest=out/old_path.name
        if dest.exists():
            record=json.loads(dest.read_text())
        else:
            sample=data[saved['Replicate']-1]
            objective=AdaptiveLikelihood(sample,profile['parameter_arrays'])
            seed=np.array(saved['Parameters'])
            result=minimize(lambda z:tuple(-v for v in objective.evaluate(z,saved['Contrast'])),
                seed,jac=True,method='SLSQP',bounds=Bounds(lower,upper),
                constraints=[LinearConstraint(slope_sum,-math.log(100),math.log(100))],
                options={'ftol':1e-10,'maxiter':1000})
            refined=AdaptiveLikelihood(sample,profile['parameter_arrays'],1e-12)
            value,score=refined.evaluate(result.x,saved['Contrast'])
            independent=profile['Likelihood'](sample,961).evaluate(result.x,saved['Contrast'],False)
            record={'Replicate':saved['Replicate'],'Contrast':saved['Contrast'],
                'Parameters':result.x.tolist(),'Slopes':profile['parameter_arrays'](result.x,saved['Contrast'])[3].tolist(),
                'AdaptiveLogLikelihood':value,'OptimizerSuccess':bool(result.success),'OptimizerMessage':result.message,
                'RefinedToleranceLogLikelihoodChange':value+float(result.fun),
                'GH961LogLikelihoodDifference':independent-value,
                'PreviousSource':{str(old_path):hashlib.sha256(old_path.read_bytes()).hexdigest()},
                'GlobalOptimumCertified':False,'CertifiedCIEndpoint':False,'IndependentCoverageDataset':False}
            dest.write_text(json.dumps(record,indent=2)+'\n')
        output.append(record)
        print(record['Replicate'],record['Contrast'],record['AdaptiveLogLikelihood'],record['Slopes'],record['OptimizerSuccess'],flush=True)
    summary={'Results':output,'GradientCheckMaximumDifference':difference,
        'NewDatasets':0,'JMLRefits':0,'NuisanceProfileProblems':len(output),
        'CertifiedCIEndpoints':0,'IndependentCoverageDatasets':0,'Provenance':provenance}
    text=json.dumps(summary,indent=2)+'\n';dest=out/'summary.json'
    if dest.exists():assert dest.read_text()==text
    else:dest.write_text(text)


if __name__=='__main__':run(Path(sys.argv[1]))
