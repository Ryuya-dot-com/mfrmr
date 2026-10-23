"""Enclose fixed-nuisance normal moments without repeating an optimizer.

The geometry, complex-disk remainder and root certificate are the existing
profile-regions calculation. This separate phase accepts exact rational
centers and an explicit quadrature order, retaining moments even when its
root certificate is not admitted. Old validated sources remain immutable.
"""
from collections import Counter
from fractions import Fraction as Q
import math
import runpy
import json
import numpy as np
import mpmath as mp


def gauss_rule(order, base):
    """Exact root brackets and positive weights for the selected order."""
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    legendre = base['legendre']
    approximate, unused = mp.gauss_quadrature(order, 'legendre')
    scale = 2**160
    result, previous = [], Q(-1)
    for root in approximate:
        low = Q(int(mp.floor(root*scale))-1, scale)
        high = low+Q(3, scale)
        assert previous < low < high < 1
        assert legendre(order, low)[0]*legendre(order, high)[0] < 0
        x = IV.mpf([iv(low).a, iv(high).b])
        pn, pm = legendre(order, x)
        derivative = order*(x*pn-pm)/(x*x-1)
        weight = 2/((1-x*x)*derivative**2)
        assert ends(weight)[0] > 0
        result.append((x, weight)); previous = high
    total = sum((w for x, w in result), IV.mpf(0))
    assert ends(total)[0] <= 2 <= ends(total)[1]
    return result


def enclose(sample, psi, slopes, center, transform, moments_path, order=32):
    """Return outward moments and an explicitly admitted or refused root bound."""
    base = runpy.run_path('inst/validation/jml-normal-importance-mc-20261003.py')
    regions = runpy.run_path('inst/validation/jml-normal-profile-regions-20261004.py')
    integration_mesh = regions['integration_mesh']
    base['IV'].dps = 60
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    slopes = list(map(Q, slopes)); x = list(map(Q, center))
    transform = np.asarray(transform, float)
    assert len(slopes) == 3 and min(slopes) > 0 and math.prod(slopes) == 1
    assert len(x) == 9 and transform.shape == (9, 9) and np.isfinite(transform).all()
    assert np.all(np.tril(transform, -1) == 0) and np.all(np.diag(transform) != 0)
    assert type(order) is int and order >= 2
    B=[[iv(Q(float(v))) for v in row] for row in transform]
    center=[iv(v) for v in x]
    psir=Q(psi); psi=iv(psir); zero=IV.mpf(0)
    raters=[center[0],center[1],-center[0]-center[1]]
    criteria=[(-center[2]+psi)/2,(-center[2]-psi)/2,center[2]]
    steps=[[zero,center[3+2*c],center[4+2*c],zero] for c in range(3)]
    xr=list(x)
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
    nodes=gauss_rule(order,base);segments=len(mesh);M=12
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
    error=iv(Q(2*M*128, (2*order+1)*math.comb(2*order,order)**2))
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
    moments={'Contrast':str(psir),'Slopes':list(map(str,slopes)),
        'LocationParameters':list(map(str,x)),'Transform':transform.tolist(),
        'LogLikelihood':list(map(str,ends(loglike))),
        'Gradient':[list(map(str,ends(z))) for z in gradient],
        'Hessian':[[list(map(str,ends(z))) for z in row] for row in hessian],
        'ThirdDerivativeUpper':str(third),
        'IntegrationMesh':[[str(a),str(b)] for a,b in mesh],
        'MeshDiagnostics':mesh_info,
        'QuadratureOrder':order,'IntervalDigits':60,'NormalTailEndpoint':M}
    moments_path.write_text(json.dumps(moments,indent=2)+'\n')
    G=upper(norm(gradient))
    E=upper(IV.sqrt(sum((iv(maxabs(hessian[j][k]+(1 if j==k else 0)))**2 for j in range(9) for k in range(9)),zero)))
    mu=1-E;radius=4*G/mu if mu>0 else None
    admitted=mu>0 and third*radius<=mu/2
    upper_log=ends(loglike)[1]+G*G/mu if admitted else None
    return {'Contrast':str(psir),
        'Slopes':list(map(str,slopes)),'LocationParameters':list(map(str,x)),'Transform':transform.tolist(),
        'LogLikelihoodLower':str(ends(loglike)[0]),'LogLikelihoodUpper':str(ends(loglike)[1]),
        'GradientNormUpper':str(G),'CurvatureErrorUpper':str(E),'ThirdDerivativeUpper':str(third),
        'RootRadius':str(radius) if radius is not None else None,
        'GlobalFixedSlopeProfileCertified':admitted,
        'GlobalFixedSlopeLogLikelihoodUpper':str(upper_log) if upper_log is not None else None,
        'QuadratureOrder':order,
        'IntegrationSegments':segments,'MeshDiagnostics':mesh_info,
        'UniformStripSegments':math.ceil(72*max(slopes)),
        'AllSlopeSupremumCertified':False}
