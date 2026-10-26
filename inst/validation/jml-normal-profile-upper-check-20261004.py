"""Independent checks and an outward slope-box transfer of the saved bound."""
from fractions import Fraction as Q
from itertools import product
from pathlib import Path
import hashlib
import json
import math
import runpy
import sys

import numpy as np
from scipy.optimize._numdiff import approx_derivative


def run(root):
    directory=root/'normal-mc-calibration'
    path=directory/'profiles/fixed-unit-replicate-01-psi-3.json'
    certificate=json.loads(path.read_text())
    moments_path=Path(next(iter(certificate['MomentArtifact'])))
    moments=json.loads(moments_path.read_text())
    for p,h in (certificate['Sources']|certificate['Input']|certificate['MomentArtifact']).items():
        assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==h,p
    G,E,M,r=[Q(certificate[k]) for k in
             ('GradientNormUpper','CurvatureErrorUpper','ThirdDerivativeUpper','RootRadius')]
    mu=1-E
    assert mu>0 and r==4*G/mu and M*r<=mu/2
    ell=Q(certificate['GlobalFixedSlopeLogLikelihoodUpper'])
    assert ell==Q(certificate['LogLikelihoodUpper'])+G*G/mu
    base_path=Path('inst/validation/jml-normal-importance-mc-20261003.py')
    profile_path=Path('inst/validation/jml-normal-mc-profile-20261004.py')
    base=runpy.run_path(str(base_path));profile=runpy.run_path(str(profile_path))
    IV,iv,ends=(base[k] for k in ('IV','iv','ends'))
    data,unused,inputs=base['read_inputs'](root)
    f=profile['Likelihood'](data[0],241)
    x=np.array(certificate['LocationParameters']);B=np.array(certificate['Transform'])
    H=approx_derivative(lambda z:f.evaluate(np.r_[z,0.,0.],3)[1][:9],x)
    enclosed=np.array([[float((Q(z[0])+Q(z[1]))/2) for z in row] for row in moments['Hessian']])
    difference=float(np.max(abs(B.T@H@B-enclosed)))
    assert difference<1e-7
    # The all-slope objective cannot inherit concavity in these coordinates.
    start=np.array([-.3,0,.3,-.6,-.4,-.8,-.9,-.4,-.5,0.,0.])
    h=approx_derivative(lambda z:f.evaluate(z,3)[1],start)
    curvature=float(np.linalg.eigvalsh((h+h.T)/2)[-1])
    assert curvature>1
    # Check the pointwise temperature inequality on small probability vectors.
    # Its general proof is Jensen plus normalization, documented in the review.
    checked=0;violation=0.
    for counts in product((1,2,3),repeat=4):
        p=np.array(counts,dtype=float)/sum(counts)
        for power in (.1,.5,.9,1.,1.1,2.,10.):
            actual=p**power/sum(p**power)
            upper=4**max(power-1,0)*p**power
            violation=max(violation,float(max(actual-upper)))
            assert np.all(actual<=upper+1e-14)
            checked+=4
    tails_path=directory/'tail-bounds.json'
    tails=json.loads(tails_path.read_text())
    for p,h in tails['Sources'].items():assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==h,p
    exponent=tails['Records'][0]['ProposalProbabilityLowerPowerOfTwo']
    records=[]
    for rho in (Q(1,100),Q(1,40),Q(1,20),Q(1,10),Q(3,20)):
        upper_log=iv(180*rho)*IV.ln(4)+iv(1-rho)*iv(ell)+exponent*IV.ln(2)
        upper_weight=ends(IV.exp(upper_log))[1]
        records.append({'SlopesLower':str(1-rho),'SlopesUpper':str(1+rho),
            'AllLocationAndStepNuisanceCovered':True,
            'SampleOneWeightUpper':str(upper_weight),'SampleOneWeightUpperApproximate':float(upper_weight),
            'CompositePValueUpperAvailable':False})
    result={'Replicate':1,'Contrast':3,'FixedSlopeGlobalProfileUpperVerified':True,
        'LogProfileEnclosureWidth':float(ell-Q(certificate['LogLikelihoodLower'])),
        'IndependentHessianMaximumDifference':difference,
        'FreeLogSlopeHessianPositiveEigenvalueDiagnostic':curvature,
        'TemperatureProbabilityCoordinatesChecked':checked,'TemperatureMaximumFloatingViolation':violation,
        'SlopeBoxUpperBounds':records,'AllSlopeSupremumCertified':False,
        'CertifiedCIEndpoints':0,'IndependentCoverageDatasets':0,
        'Interpretation':'An upper bound for one likelihood-ratio term over a slope box and all location/step nuisance values. It is not an upper bound for the 50-term MC numerator or the full structural nuisance space.',
        'Sources':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in
                   (Path(__file__),path,moments_path,base_path,profile_path,tails_path)},'Inputs':inputs}
    out=directory/'profile-upper-checks.json';payload=json.dumps(result,indent=2)+'\n'
    if out.exists():assert out.read_text()==payload
    else:out.write_text(payload)
    print(json.dumps({k:result[k] for k in ('FixedSlopeGlobalProfileUpperVerified','LogProfileEnclosureWidth',
        'IndependentHessianMaximumDifference','TemperatureProbabilityCoordinatesChecked','CertifiedCIEndpoints')},indent=2))


if __name__=='__main__':run(Path(sys.argv[1]))
