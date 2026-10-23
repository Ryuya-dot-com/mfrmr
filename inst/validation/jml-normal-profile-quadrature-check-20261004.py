"""Independent adaptive integration at the exploratory saved nuisance points."""
from pathlib import Path
import hashlib
import json
import math
import runpy
import sys

import numpy as np
from scipy.integrate import quad_vec
from scipy.special import logsumexp


def run(root):
    directory=root/'normal-mc-calibration/profiles'
    manifest=json.loads((directory/'manifest.json').read_text())
    for p,h in (manifest['Sources']|manifest['Inputs']).items():
        assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==h,p
    module=runpy.run_path('inst/validation/jml-normal-mc-profile-20261004.py')
    base=runpy.run_path('inst/validation/jml-normal-importance-mc-20261003.py')
    data,unused,inputs=base['read_inputs'](root)
    results=[];sources={str(Path(__file__)):hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}
    for p in sorted(directory.glob('replicate-*-psi-*.json')):
        x=json.loads(p.read_text());sample=data[x['Replicate']-1]
        r,c,s,a=module['parameter_arrays'](np.array(x['Parameters']),x['Contrast'])
        cells=np.array([[(rr-1)*3+cc for rr in g for cc in range(3)] for g,y in sample])
        scores=np.array([y for g,y in sample])
        locations=np.repeat(r,3)+np.tile(c,3);cum=np.tile(s,(3,1));slopes=np.tile(a,3)
        # Every pairwise category crossing splits the integration domain.
        points=sorted({float(locations[cell]+(cum[cell,l]-cum[cell,k])/(l-k))
            for cell in range(9) for k in range(4) for l in range(k+1,4)
            if -12<locations[cell]+(cum[cell,l]-cum[cell,k])/(l-k)<12})
        def integrand(theta):
            logits=slopes[:,None]*((theta-locations[:,None])*np.arange(4)-cum)
            logp=logits-logsumexp(logits,axis=1,keepdims=True)
            return np.exp(logp[cells,scores].sum(axis=1)-theta*theta/2)/math.sqrt(2*math.pi)
        value,error,info=quad_vec(integrand,-12,12,points=points,epsabs=1e-24,
            epsrel=1e-11,norm='max',full_output=True)
        assert info.success and min(value)>0
        loglike=float(np.log(value).sum());difference=loglike-x['LogLikelihoodApproximate']
        results.append({'Replicate':x['Replicate'],'Contrast':x['Contrast'],
            'AdaptiveLogLikelihood':loglike,'GH241LogLikelihood':x['LogLikelihoodApproximate'],
            'LogLikelihoodDifference':difference,'EstimatedPersonAbsoluteIntegrationError':float(error),
            'DerivativeOrProbabilityCertificate':False})
        sources[str(p)]=hashlib.sha256(p.read_bytes()).hexdigest()
        print(x['Replicate'],x['Contrast'],'adaptive minus GH241',difference,flush=True)
    result={'Results':results,'Sources':sources,'Inputs':inputs,
        'MaximumAbsoluteLogLikelihoodDifference':max(abs(r['LogLikelihoodDifference']) for r in results),
        'IndependentCoverageDatasets':0,'CertifiedCIEndpoints':0,
        'Interpretation':'Numerical cross-check on development data, not certified weights, exact profiles or independent outer validation.'}
    out=directory/'adaptive-check.json';payload=json.dumps(result,indent=2)+'\n'
    if out.exists():assert out.read_text()==payload
    else:out.write_text(payload)


if __name__=='__main__':run(Path(sys.argv[1]))
