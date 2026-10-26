"""General-slope profile certificates with a locally certified integration mesh.

The immutable unit-slope prototype remains an independent numerical reference.
All location/step nuisance values are covered; a slope region is covered only
by an explicit transfer certificate. This is not a completed MC inversion.
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
from scipy.optimize import minimize
from scipy.optimize._numdiff import approx_derivative


def integration_mesh(raters,criteria,steps,slopes,endpoint=12):
    """Exact sufficient disk tests for the Gauss remainder at every real point.

For width h each cell has either a*h <= 1/3, or one category dominates
throughout disks of radius h centered anywhere in the segment. In the latter
case each other exponential/leading exponential is <= exp(-2) < 1/6.
"""
    pending=[(Q(j),Q(j+1)) for j in range(-endpoint,endpoint)]
    accepted=[];strip_only=dominance_used=0
    while pending:
        left,right=pending.pop();h=right-left;mid=(left+right)/2
        used=False;ok=True
        for rr in range(3):
            for cc,a in enumerate(slopes):
                if a*h<=Q(1,3):continue
                logits=[a*(k*(mid-raters[rr]-criteria[cc])-steps[cc][k]) for k in range(4)]
                leader=max(range(4),key=lambda k:logits[k])
                if not all(logits[leader]-logits[k]>=2+Q(3,2)*a*abs(leader-k)*h
                           for k in range(4) if k!=leader):
                    ok=False;break
                used=True
            if not ok:break
        if ok:
            accepted.append((left,right));dominance_used+=used;strip_only+=not used
        else:pending.extend(((left,mid),(mid,right)))
    return sorted(accepted),{'StripOnlySegments':strip_only,'DominanceSegments':dominance_used}


def compute(sample,psi,slopes,moments_path,start=None):
    base=runpy.run_path('inst/validation/jml-normal-importance-mc-20261003.py')
    profile=runpy.run_path('inst/validation/jml-normal-mc-profile-20261004.py')
    IV,iv,ends=(base[k] for k in ('IV','iv','ends'))
    adaptive=runpy.run_path('inst/validation/jml-normal-profile-adaptive-20261004.py')
    assert len(slopes)==3 and all(a>0 for a in slopes) and math.prod(slopes)==1
    f=adaptive['AdaptiveLikelihood'](sample,profile['parameter_arrays'],1e-12)
    logs=np.log(list(map(float,slopes[:2])))
    if start is None:start=np.array([-.3,0,.3,-.6,-.4,-.8,-.9,-.4,-.5])
    def fg(z):
        value,g=f.evaluate(np.r_[z,logs],float(psi))
        return -value,-g[:9]
    fit=minimize(fg,start,jac=True,method='BFGS',options={'gtol':1e-11,'maxiter':1000})
    x=fit.x.copy()
    for unused in range(5):
        g=fg(x)[1];H=approx_derivative(lambda z:fg(z)[1],x)
        H=(H+H.T)/2
        step=np.linalg.solve(H,g)
        if np.linalg.norm(step)<1e-14:break
        x-=step
    H=approx_derivative(lambda z:fg(z)[1],x);H=(H+H.T)/2
    transform=np.linalg.inv(np.linalg.cholesky(H).T)
    # Its exact stored matrix is triangular with nonzero diagonal, hence invertible.
    assert np.all(np.tril(transform,-1)==0) and np.all(np.diag(transform)!=0)
    B=[[iv(Q(float(v))) for v in row] for row in transform]
    center=[iv(Q(float(v))) for v in x]
    psi=iv(Q(psi)); zero=IV.mpf(0)
    raters=[center[0],center[1],-center[0]-center[1]]
    criteria=[(-center[2]+psi)/2,(-center[2]-psi)/2,center[2]]
    steps=[[zero,center[3+2*c],center[4+2*c],zero] for c in range(3)]
    xr=list(map(lambda z:Q(float(z)),x));psir=Q(ends(psi)[0])
    mesh,mesh_info=integration_mesh([xr[0],xr[1],-xr[0]-xr[1]],
        [(-xr[2]+psir)/2,(-xr[2]-psir)/2,xr[2]],
        [[Q(0),xr[3+2*c],xr[4+2*c],Q(0)] for c in range(3)],slopes)
    # Exact-rational design coefficients; B consists of exact stored doubles.
    design=[]
    for r in range(3):
        for c in range(3):
            cell=[]
            for k in range(4):
                v=[Q(0)]*9
                v[0]=-k*Q((1,0,-1)[r]);v[1]=-k*Q((0,1,-1)[r])
                v[2]=-k*(Q(-1,2) if c<2 else Q(1))
                if k in (1,2):v[3+2*c+k-1]=-1
                cell.append([sum((iv(slopes[c]*v[j])*B[j][h] for j in range(9)),zero) for h in range(9)])
            design.append(cell)
    def norm(v):return IV.sqrt(sum((z**2 for z in v),zero))
    def upper(v):return ends(v)[1]
    def maxabs(v):return max(abs(z) for z in ends(v))
    geometry={};third=Q(0)
    for roster in sorted({g for g,y in sample}):
        cells=[(r-1)*3+c for r in roster for c in range(3)]
        diam=[]
        for cell in cells:
            diam.append(max(upper(norm([design[cell][k][j]-design[cell][l][j] for j in range(9)]))
                            for k in range(4) for l in range(k)))
        b=sum(diam);v=sum(d*d for d in diam)/4;w=sum(d**3 for d in diam)
        population=sum(g==roster for g,y in sample)
        third+=population*(w+12*b*v+8*b**3)
        maximum=[[max(maxabs(design[cell][k][j]) for k in range(4)) for j in range(9)] for cell in cells]
        g_bound=[Q(39,7)*sum(row[j] for row in maximum) for j in range(9)]
        h_bound=[[Q(1248,49)*sum(row[j]*row[k] for row in maximum) for k in range(9)] for j in range(9)]
        geometry[roster]=(cells,g_bound,h_bound)
    counts=Counter(sample);keys=list(counts)
    observed={key:[sum((design[cell][score][j] for cell,score in zip(geometry[key[0]][0],key[1])),zero)
                   for j in range(9)] for key in keys}
    integrals={key:[zero,[zero for j in range(9)],[[zero for k in range(9)] for j in range(9)]] for key in keys}
    nodes=base['rule']();segments=len(mesh);M=12
    assert ends(IV.exp(2))[0]>6
    print(f'Fixed slopes {list(map(str,slopes))}: {segments} certified segments',flush=True)
    for segment,(left,right) in enumerate(mesh):
        width=right-left;middle=(left+right)/2
        for node,weight in nodes:
            theta=iv(middle)+iv(width/2)*node
            mass=weight*iv(width/2)*IV.exp(-theta**2/2)
            probabilities=[];means=[];covariances=[]
            for r in range(3):
                for c in range(3):
                    cell=r*3+c
                    logits=[iv(slopes[c])*(k*(theta-raters[r]-criteria[c])-steps[c][k]) for k in range(4)]
                    shift=max(upper(z) for z in logits)
                    raw=[IV.exp(z-iv(shift)) for z in logits];total=sum(raw)
                    p=[z/total for z in raw];probabilities.append(p)
                    mean=[sum((p[k]*design[cell][k][j] for k in range(4)),zero) for j in range(9)]
                    means.append(mean)
                    covariance=[[zero for k in range(9)] for j in range(9)]
                    for j in range(9):
                        for k in range(j,9):
                            value=sum((p[t]*(design[cell][t][j]-mean[j])*(design[cell][t][k]-mean[k]) for t in range(4)),zero)
                            covariance[j][k]=covariance[k][j]=value
                    covariances.append(covariance)
            group={}
            for roster,(cells,unused_g,unused_h) in geometry.items():
                group[roster]=([sum((means[cell][j] for cell in cells),zero) for j in range(9)],
                    [[-sum((covariances[cell][j][k] for cell in cells),zero) for k in range(9)] for j in range(9)])
            for key in keys:
                roster,y=key;cells=geometry[roster][0];value=mass
                for cell,score in zip(cells,y):value*=probabilities[cell][score]
                average,hessian=group[roster]
                score=[observed[key][j]-average[j] for j in range(9)]
                target=integrals[key];target[0]+=value
                for j in range(9):
                    target[1][j]+=value*score[j]
                    for k in range(j,9):
                        target[2][j][k]+=value*(score[j]*score[k]+hessian[j][k])
        if (segment+1)%24==0:print(f'psi {str(psi)}, integration {segment+1}/{segments}',flush=True)
    # Each |p| <= 2 in its verified disk; |normal kernel| < 2 (h <= 1).
    # The sum of absolute category masses is <= 3 in dominance disks and
    # <= 8/7 in strip disks, so the prototype's score/Hessian constants hold.
    error=iv(Q(2*M*128, (2*base['ORDER']+1)*math.comb(2*base['ORDER'],base['ORDER'])**2))
    error+=iv(Q(2,M))*IV.exp(iv(Q(-M*M,2)))
    def expand(value,radius):
        return IV.mpf([iv(ends(value-radius)[0]).a,iv(ends(value+radius)[1]).b])
    loglike=zero;gradient=[zero for j in range(9)];hessian=[[zero for k in range(9)] for j in range(9)]
    for key,(z,g,h) in integrals.items():
        n=counts[key];gb,hb=geometry[key[0]][1:]
        z=expand(z,error);assert ends(z)[0]>0
        g=[expand(g[j],error*iv(gb[j]))/z for j in range(9)]
        loglike+=n*(IV.ln(z)-IV.ln(2*IV.pi)/2)
        for j in range(9):
            gradient[j]+=n*g[j]
            for k in range(j,9):
                moment=expand(h[j][k],error*iv(gb[j]*gb[k]+hb[j][k]))/z
                value=n*(moment-g[j]*g[k]);hessian[j][k]+=value
                if j!=k:hessian[k][j]+=value
    approximate=f.evaluate(np.r_[x,logs],float(ends(psi)[0]))[0]
    moments={'Contrast':float(ends(psi)[0]),'Slopes':list(map(str,slopes)),
        'LocationParameters':x.tolist(),'Transform':transform.tolist(),
        'LogLikelihood':list(map(str,ends(loglike))),
        'Gradient':[list(map(str,ends(z))) for z in gradient],
        'Hessian':[[list(map(str,ends(z))) for z in row] for row in hessian],
        'ThirdDerivativeUpper':str(third),
        'IntegrationMesh':[[str(a),str(b)] for a,b in mesh],
        'MeshDiagnostics':mesh_info,
        'ApproximateQuadratureLogLikelihood':approximate}
    moments_path.write_text(json.dumps(moments,indent=2)+'\n')
    G=upper(norm(gradient))
    E=upper(IV.sqrt(sum((iv(maxabs(hessian[j][k]+(1 if j==k else 0)))**2 for j in range(9) for k in range(9)),zero)))
    mu=1-E;radius=4*G/mu if mu>0 else None
    admitted=mu>0 and third*radius<=mu/2
    upper_log=ends(loglike)[1]+G*G/mu if admitted else None
    return {'Contrast':float(ends(psi)[0]),
        'Slopes':list(map(str,slopes)),'LocationParameters':x.tolist(),'Transform':transform.tolist(),
        'LogLikelihoodLower':str(ends(loglike)[0]),'LogLikelihoodUpper':str(ends(loglike)[1]),
        'GradientNormUpper':str(G),'CurvatureErrorUpper':str(E),'ThirdDerivativeUpper':str(third),
        'RootRadius':str(radius) if radius is not None else None,
        'GlobalFixedSlopeProfileCertified':admitted,
        'GlobalFixedSlopeLogLikelihoodUpper':str(upper_log) if upper_log is not None else None,
        'ApproximateQuadratureLogLikelihood':approximate,
        'IntegrationSegments':segments,'MeshDiagnostics':mesh_info,
        'UniformStripSegments':math.ceil(72*max(slopes)),
        'AllSlopeSupremumCertified':False}


def run(root,replicate,psi,slopes,out,start_path=None):
    script=Path(__file__);source=Path('inst/validation/jml-normal-mc-profile-20261004.py')
    base=Path('inst/validation/jml-normal-importance-mc-20261003.py')
    m=runpy.run_path(str(base));data,unused,inputs=m['read_inputs'](root)
    if out.exists():raise RuntimeError('Preserve existing certificate')
    out.parent.mkdir(parents=True,exist_ok=True)
    moments_path=out.with_suffix('.moments.json')
    start=None if start_path is None else np.array(json.loads(start_path.read_text())['Parameters'][:9])
    result=compute(data[replicate-1],Q(psi),slopes,moments_path,start);result['Replicate']=replicate
    dependencies=[script,source,base,Path('inst/validation/jml-normal-profile-adaptive-20261004.py')]
    if start_path is not None:dependencies.append(start_path)
    result['Sources']={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in dependencies}
    result['Input']={str(root/'conditional-reference'/f'input-{replicate:02d}.json'):
        inputs[str(root/'conditional-reference'/f'input-{replicate:02d}.json')]}
    result['MomentArtifact']={str(moments_path):hashlib.sha256(moments_path.read_bytes()).hexdigest()}
    out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ('Replicate','Contrast','GlobalFixedSlopeProfileCertified','AllSlopeSupremumCertified')},indent=2),flush=True)


if __name__=='__main__':
    a,b=map(Q,sys.argv[4:6])
    run(Path(sys.argv[1]),int(sys.argv[2]),sys.argv[3],[a,b,1/(a*b)],Path(sys.argv[6]),
        Path(sys.argv[7]) if len(sys.argv)>7 else None)
