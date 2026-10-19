"""Independent checks of general-slope bounds and certified contrast rays.

No new response samples, original JML fits, or complete CI claims. The second
integrator uses adjacent odds and scalar scipy quad, not the certificate mesh.
"""
from collections import Counter
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


def arrays(x,psi):
    x=list(map(Q,x));psi=Q(psi)
    return ([x[0],x[1],-x[0]-x[1]],
            [(-x[2]+psi)/2,(-x[2]-psi)/2,x[2]],
            [[Q(0),x[3+2*c],x[4+2*c],Q(0)] for c in range(3)])


def mesh_check(mesh,parameters,psi,slopes):
    r,c,s=arrays(parameters,psi)
    assert mesh[0][0]==-12 and mesh[-1][1]==12
    assert all(a[1]==b[0] for a,b in zip(mesh,mesh[1:]))
    checked=0
    for left,right in mesh:
        h=right-left;mid=(left+right)/2
        assert 0<h<=1
        for rr in range(3):
            for cc,a in enumerate(slopes):
                if a*h<=Q(1,3):continue
                # Independent natural-logit expression and all candidate leaders.
                logits=[a*(k*mid-k*r[rr]-k*c[cc]-s[cc][k]) for k in range(4)]
                assert any(all(logits[k]-logits[j]>=2+Q(3,2)*a*abs(j-k)*h
                               for j in range(4) if j!=k) for k in range(4))
                checked+=1
    return checked


def scalar_likelihood(sample,x,psi,slopes):
    r,c,s=arrays(x,psi);r=np.array(r,float);c=np.array(c,float)
    s=np.array(s,float);slopes=np.array(slopes,float)
    value=0.
    for (roster,y),count in Counter(sample).items():
        cells=[(rr-1,cc) for rr in roster for cc in range(3)]
        points=sorted({float(r[rr]+c[cc]+(s[cc,l]-s[cc,k])/(l-k))
            for rr,cc in cells for k in range(4) for l in range(k+1,4)
            if -12<r[rr]+c[cc]+(s[cc,l]-s[cc,k])/(l-k)<12})
        def integrand(theta):
            logmass=-theta*theta/2-math.log(2*math.pi)/2
            for (rr,cc),score in zip(cells,y):
                adjacent=slopes[cc]*(theta-r[rr]-c[cc]-np.diff(s[cc]))
                logits=np.r_[0.,np.cumsum(adjacent)]
                logmass+=logits[score]-logsumexp(logits)
            return math.exp(logmass)
        z,error=quad(integrand,-12,12,points=points,epsabs=1e-25,epsrel=1e-12,limit=400)
        assert z>0 and error/z<1e-9
        value+=count*math.log(z)
    return value


def lower_log_likelihood(sample,x,psi,slopes,base,mesh):
    """Integrate exp(chord of log kernel): a lower bound by log concavity.

    Taking lower endpoints of interval log kernels only lowers the chord.
    Omitted normal tails have nonnegative mass. This uses no Gauss remainder.
    """
    IV,iv,ends=(base[k] for k in ('IV','iv','ends'))
    r,c,s=arrays(x,psi)
    grid=sorted({left+(right-left)*Q(j,4) for left,right in mesh for j in range(5)})
    endpoint=[]
    for theta in grid:
        cells=[]
        for rr in range(3):
            for cc,a in enumerate(slopes):
                logits=[iv(a*(k*(theta-r[rr]-c[cc])-s[cc][k])) for k in range(4)]
                shift=max(ends(z)[1] for z in logits)
                denominator=IV.ln(sum(IV.exp(z-iv(shift)) for z in logits))+iv(shift)
                cells.append([z-denominator for z in logits])
        endpoint.append(cells)
    result=IV.mpf(0)
    for (roster,y),count in Counter(sample).items():
        cells=[(rr-1)*3+cc for rr in roster for cc in range(3)]
        logf=[]
        for theta,prob in zip(grid,endpoint):
            v=-iv(theta)**2/2-IV.ln(2*IV.pi)/2
            for cell,score in zip(cells,y):v+=prob[cell][score]
            logf.append(ends(v)[0])
        mass=IV.mpf(0)
        for left,right,fl,fr in zip(grid,grid[1:],logf,logf[1:]):
            if fl==fr:part=IV.exp(iv(fl))
            else:part=(IV.exp(iv(fr))-IV.exp(iv(fl)))/iv(fr-fl)
            assert ends(part)[0]>0
            mass+=iv(right-left)*part
        result+=count*IV.ln(iv(ends(mass)[0]))
    return ends(result)[0],len(grid)-1


def sharp_constant(r,t,base):
    IV,iv,ends=(base[k] for k in ('IV','iv','ends'))
    def derivative(u):
        return iv(3)**iv(1-r)*((iv(r-t)*iv(u)**iv(r))+
                              iv(r)*iv(u)**iv(r-1))-iv(t)
    low,high=Q(0),Q(3)
    for unused in range(70):
        mid=(low+high)/2;v=ends(derivative(mid))
        if v[1]<0:low=mid
        elif v[0]>0:high=mid
        else:break
    assert ends(derivative(low))[1]<0 and ends(derivative(high))[0]>0
    upper=ends(iv(1+high)**iv(t)/(1+iv(3)**iv(1-r)*iv(low)**iv(r)))[1]
    return upper,[str(low),str(high)]


def verify_certificate(record,moments):
    for path,digest in (record['Sources']|record['Input']|record['MomentArtifact']).items():
        actual=Path(path.removeprefix('/Users/tohokusla/Dropbox/MFRM_Application/mfrmr/development/'))
        assert hashlib.sha256(actual.read_bytes()).hexdigest()==digest,path
    G,E,M,r=map(Q,(record[k] for k in
        ('GradientNormUpper','CurvatureErrorUpper','ThirdDerivativeUpper','RootRadius')))
    maximum=lambda interval:max(abs(Q(v)) for v in interval)
    assert G*G>=sum(maximum(v)**2 for v in moments['Gradient'])
    h=moments['Hessian']
    assert E*E>=sum(max(abs(Q(v)+(j==k)) for v in h[j][k])**2
                    for j in range(9) for k in range(9))
    mu=1-E
    assert mu>0 and r==4*G/mu and M*r<=mu/2
    assert Q(record['GlobalFixedSlopeLogLikelihoodUpper'])==Q(record['LogLikelihoodUpper'])+G*G/mu
    B=np.array(record['Transform']);assert np.all(np.tril(B,-1)==0) and np.all(np.diag(B)!=0)


def run(root,replicate=1):
    assert 1<=replicate<=50
    directory=root/'normal-mc-calibration/profiles'
    base_path=Path('inst/validation/jml-normal-importance-mc-20261003.py')
    base=runpy.run_path(str(base_path));data,unused,inputs=base['read_inputs'](root)
    IV,iv,ends=(base[k] for k in ('IV','iv','ends'))
    paths=[directory/'rational-remainder'/f'general-replicate-{replicate:02d}-psi--10.json']
    if replicate==1:paths.append(directory/'fixed-unit-replicate-01-psi-3.json')
    proposal_path=directory.parent/'proposal-probabilities.json'
    proposal=json.loads(proposal_path.read_text());q=Q(proposal['Records'][replicate-1]['Lower'])
    assert proposal['Records'][replicate-1]['Replicate']==replicate and proposal['Inputs']==inputs
    for p,h in (proposal['Sources']|proposal['Inputs']).items():
        actual=Path(p.removeprefix('/Users/tohokusla/Dropbox/MFRM_Application/mfrmr/development/'))
        assert hashlib.sha256(actual.read_bytes()).hexdigest()==h,p
    output=[];dependencies=[Path(__file__),base_path,proposal_path]
    for path in paths:
        record=json.loads(path.read_text());moment_path=Path(next(iter(record['MomentArtifact'])))
        moments=json.loads(moment_path.read_text());verify_certificate(record,moments)
        x=record['LocationParameters'];psi=Q(record['Contrast']);slopes=list(map(Q,record['Slopes']))
        upper=Q(record['GlobalFixedSlopeLogLikelihoodUpper']);sample=data[record['Replicate']-1]
        if 'IntegrationMesh' in moments:
            mesh=[list(map(Q,p)) for p in moments['IntegrationMesh']]
            mesh_cases=mesh_check(mesh,x,psi,slopes)
            independent=scalar_likelihood(sample,x,psi,slopes)
            assert abs(independent-float(Q(record['LogLikelihoodLower'])))<1e-9
            # Directional Hessian check in three transformed directions.
            B=np.array(record['Transform']);H=np.array([[float((Q(z[0])+Q(z[1]))/2)
                                                       for z in row] for row in moments['Hessian']])
            discrepancy=[];eps=.001
            for v in (np.eye(9)[0],np.eye(9)[8],np.ones(9)/3):
                delta=B@v*eps
                second=(scalar_likelihood(sample,np.array(x)+delta,psi,slopes)-2*independent+
                        scalar_likelihood(sample,np.array(x)-delta,psi,slopes))/eps**2
                discrepancy.append(abs(second-v@H@v))
            assert max(discrepancy)<2e-5
            witness=psi+1
            lower,lower_segments=lower_log_likelihood(sample,x,witness,slopes,base,mesh)
            print('General profile independently checked; ray witness',float(lower),flush=True)
        else:
            # The immutable unit certificate already has independent Hessian checks.
            mesh_cases=None;independent=None;discrepancy=[];lower_segments=None
            witness=Q(-1,2);lower=ends(IV.ln(iv(q)))[0]
        assert lower>upper,'This witness cannot certify the external ray'
        secant=(upper-lower)/(psi-witness)
        boxes=[]
        assert [sum(2 for roster,y in sample) for c in range(3)]==[60]*3
        for rho in (Q(1,10),Q(1,5),Q(1,4)):
            t=1-rho;constant,bracket=sharp_constant(1+rho,t,base)
            log_weight=120*IV.ln(iv(constant))+iv(t*upper)-IV.ln(iv(q))
            bound=ends(IV.exp(log_weight))[1]
            boxes.append({'RelativeSlopeLower':str(1-rho),'RelativeSlopeUpper':str(1+rho),
                'SlopesLower':list(map(str,(a*(1-rho) for a in slopes))),
                'SlopesUpper':list(map(str,(a*(1+rho) for a in slopes))),
                'SharpConstantUpper':str(constant),'MaximizingRootBracket':bracket,
                'WeightUpperOnWholeContrastRay':str(bound),'WeightUpperApproximate':float(bound)})
        output.append({'Replicate':record['Replicate'],'ContrastBoundary':str(psi),
            'ContrastRay':'left' if psi<witness else 'right','ReferenceSlopes':list(map(str,slopes)),
            'AllLocationAndStepNuisanceCovered':True,'FixedSlopeGlobalProfileUpperVerified':True,
            'DominanceCellDisksChecked':mesh_cases,
            'IndependentLogLikelihood':independent,
            'DirectionalHessianMaximumDifference':max(discrepancy) if discrepancy else None,
            'LogProfileEnclosureWidth':float(upper-Q(record['LogLikelihoodLower'])),
            'WitnessContrast':str(witness),'WitnessLogLikelihoodLower':str(lower),
            'WitnessLowerIntegralSegments':lower_segments,'OutwardProfileSecantSlope':str(secant),
            'AffineUpperSlope':str(secant),'AffineUpperIntercept':str(upper-psi*secant),
            'SlopeBoxes':boxes,'CompleteMCNumeratorBound':False,'AllSlopeSupremumCertified':False})
        dependencies.extend((path,moment_path))
    result={'ChecksPassed':True,'Results':output,'CertifiedCIEndpoints':0,'IndependentCoverageDatasets':0,
        'Sources':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in dependencies},
        'Inputs':inputs,'Scope':'Global location/step bounds for two contrast rays within explicit slope regions, for one development sample. Not a complete MC numerator or all-slope inversion.'}
    out=directory/'rational-remainder'/f'general-region-checks-replicate-{replicate:02d}.json';payload=json.dumps(result,indent=2)+'\n'
    if out.exists():assert out.read_text()==payload
    else:out.write_text(payload)
    print(json.dumps({'ChecksPassed':True,'ContrastRays':len(output),'CertifiedCIEndpoints':0},indent=2))


if __name__=='__main__':run(Path(sys.argv[1]),int(sys.argv[2]) if len(sys.argv)>2 else 1)
