"""Likelihood profiling for MC projection development.

Optimizer values are retention witnesses / LOWER bounds on nuisance suprema.
They are never reported as certified exclusions or confidence endpoints.
The temperature inequality supplies a uniform upper transfer between slopes;
it still needs a certified fixed-slope profile bound as its input.
"""
from pathlib import Path
import json
import hashlib
import math
import runpy
import sys

import numpy as np
from scipy.optimize import minimize, LinearConstraint, Bounds
from scipy.special import roots_hermitenorm, logsumexp


def parameter_arrays(x, psi):
    r = np.array([x[0],x[1],-x[0]-x[1]])
    c = np.array([(-x[2]+psi)/2,(-x[2]-psi)/2,x[2]])
    steps = np.zeros((3,4)); steps[:,1:3] = x[3:9].reshape(3,2)
    a = np.exp(np.array([x[9],x[10],-x[9]-x[10]]))
    return r,c,steps,a


class Likelihood:
    def __init__(self, sample, order):
        self.theta, weights = roots_hermitenorm(order)
        self.logw = np.log(weights)-math.log(2*math.pi)/2
        self.cells=np.array([[(r-1)*3+c for r in roster for c in range(3)] for roster,y in sample])
        self.scores=np.array([y for roster,y in sample])

    def evaluate(self,x,psi,gradient=True):
        r,c,s,a=parameter_arrays(x,psi)
        eta=self.theta[None,:,None]-np.repeat(r,3)[:,None,None]-np.tile(c,3)[:,None,None]
        logits=np.tile(a,3)[:,None,None]*(eta*np.arange(4)-np.tile(s,(3,1))[:,None,:])
        logp=logits-logsumexp(logits,axis=2,keepdims=True)
        chosen=logp[self.cells[:,:,None],np.arange(len(self.theta))[None,None,:],self.scores[:,:,None]]
        person=chosen.sum(axis=1)+self.logw
        marginal=logsumexp(person,axis=1)
        value=float(marginal.sum())
        if not gradient:return value
        probability=np.exp(logp)
        mean=np.einsum('ctk,k->ct',probability,np.arange(4))
        residual=self.scores[:,:,None]-mean[self.cells]
        posterior=np.exp(person-marginal[:,None])
        cell_score=np.zeros((9,len(self.theta)))
        np.add.at(cell_score,self.cells.ravel(),(residual*posterior[:,None,:]).reshape(-1,len(self.theta)))
        location=-np.tile(a,3)*cell_score.sum(axis=1)
        out=np.zeros(11)
        by_r=location.reshape(3,3).sum(axis=1)
        out[:2]=by_r[:2]-by_r[2]
        by_c=location.reshape(3,3).sum(axis=0)
        out[2]=by_c[2]-(by_c[0]+by_c[1])/2
        for owner in range(3):
            owner_mask=self.cells%3==owner
            for k in (1,2):
                dk=(self.scores[:,:,None]==k)-probability[:,:,k][self.cells]
                out[3+owner*2+k-1]=-a[owner]*np.sum(dk*owner_mask[:,:,None]*posterior[:,None,:])
        logit_mean=np.sum(probability*logits,axis=2)
        logit_chosen=logits[self.cells[:,:,None],np.arange(len(self.theta))[None,None,:],self.scores[:,:,None]]
        natural=logit_chosen-logit_mean[self.cells]
        natural=np.sum(natural*posterior[:,None,:],axis=2)
        slope=np.array([natural[self.cells%3==owner].sum() for owner in range(3)])
        out[9:11]=slope[:2]-slope[2]
        return value,out


def transfer_upper(log_profile_upper, reference_slopes, lower_slopes, upper_slopes, ratings_per_owner):
    """Uniform upper on a slope box; fixed locations/steps/contrast unchanged."""
    lo=np.asarray(lower_slopes)/np.asarray(reference_slopes)
    hi=np.asarray(upper_slopes)/np.asarray(reference_slopes)
    power=min(1.,float(min(lo)))
    penalty=math.log(4)*sum(n*max(v-1,0) for n,v in zip(ratings_per_owner,hi))
    return min(0.,penalty+power*log_profile_upper)


def fit(sample,psi,order=121,start=None):
    objective=Likelihood(sample,order)
    x=np.array([-.3,0,.3,-.6,-.4,-.8,-.9,-.4,-.5,0,0.]) if start is None else np.array(start)
    # A bounded search can supply witnesses, never all-nuisance exclusions.
    lower=np.r_[np.full(9,-np.inf),[-math.log(100)]*2]
    upper=np.r_[np.full(9,np.inf),[math.log(100)]*2]
    slope_sum=np.zeros((1,11));slope_sum[0,9:]=1
    result=minimize(lambda z:tuple(-v for v in objective.evaluate(z,psi)),x,jac=True,
        method='SLSQP',bounds=Bounds(lower,upper),
        constraints=[LinearConstraint(slope_sum,-math.log(100),math.log(100))],
        options={'ftol':1e-11,'maxiter':1000})
    return {'Contrast':psi,'Parameters':result.x.tolist(),'LogLikelihoodApproximate':-float(result.fun),
        'OptimizerSuccess':bool(result.success),'OptimizerMessage':result.message,
        'QuadratureOrder':order,'Slopes':parameter_arrays(result.x,psi)[3].tolist(),
        'CertifiedUpperBound':False}


def run(root,out):
    m=runpy.run_path('inst/validation/jml-normal-importance-mc-20261003.py')
    data,patterns,inputs=m['read_inputs'](root)
    out.mkdir(parents=True,exist_ok=True)
    manifest={'Inputs':inputs,'Sources':{str(p):hashlib.sha256(p.read_bytes()).hexdigest()
        for p in (Path(__file__),Path('inst/validation/jml-normal-importance-mc-20261003.py'))},
        'Replicates':[1,12,22,38],'Contrasts':[-10,-3,0,3,10],
        'Purpose':'Exploratory nuisance witnesses, not upper bounds, CI endpoints or independent validation',
        'NewDatasets':0,'JMLRefits':0}
    payload=json.dumps(manifest,indent=2)+'\n';manifest_path=out/'manifest.json'
    if manifest_path.exists():assert manifest_path.read_text()==payload
    else:manifest_path.write_text(payload)
    output=[]
    truth=np.array([-.3,0,.3,-.6,-.4,-.8,-.9,-.4,-.5,0,0.])
    # Directional development check chosen from the tail-design audit, not an
    # independent validation sample or a selection of successful JML estimates.
    for i in (1,12,22,38):
        sample=data[i-1]
        baseline=Likelihood(sample,241).evaluate(truth,-.5,False)
        for psi in (-10.,-3.,0.,3.,10.):
            path=out/f'replicate-{i:02d}-psi-{psi:g}.json'
            if path.exists():
                record=json.loads(path.read_text())
            else:
                initial=fit(sample,psi,61)
                record=fit(sample,psi,241,initial['Parameters'])
                record.update({'Replicate':i,'LogProposalApproximate':baseline,
                    'SelfWeightLogRatioApproximate':record['LogLikelihoodApproximate']-baseline,
                    'FullNuisanceExclusion':False,'IndependentValidation':False})
                path.parent.mkdir(parents=True,exist_ok=True)
                path.write_text(json.dumps(record,indent=2)+'\n')
            output.append(record)
            print(i,psi,record['SelfWeightLogRatioApproximate'],record['Slopes'],record['OptimizerSuccess'],flush=True)
    (out/'summary.json').write_text(json.dumps(output,indent=2)+'\n')


if __name__=='__main__':run(Path(sys.argv[1]),Path(sys.argv[2]))
