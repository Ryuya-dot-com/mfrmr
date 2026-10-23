"""Global fixed-slope marginal upper bounds from an enclosed supporting plane.

The existing endpoint/category argument bounds every nuisance coordinate on
a likelihood superlevel set. Log concavity then needs only value and gradient
enclosures; no Hessian, stationary-root admission or nuisance optimum is
assumed. The complement of the box retains its explicit likelihood bound.
This is the retained three-owner, two-rater-per-Person normal development law.
"""
from collections import Counter
from fractions import Fraction as Q
import math
import runpy

MOMENTS = 'inst/validation/jml-normal-profile-moments-20261004.py'
REGIONS = 'inst/validation/jml-normal-profile-regions-20261004.py'
TAIL = 'inst/validation/jml-normal-mc-tail-bounds-20261004.py'


def support_upper(sample, slopes, center, loglike, gradient, base):
    """Enclose the tangent over the whole superlevel box and its complement."""
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    slopes = list(map(Q, slopes)); center = list(map(Q, center))
    assert len(center) == len(gradient) == 9 and len(slopes) == 3
    assert min(slopes) > 0 and math.prod(slopes) == 1
    design = runpy.run_path(TAIL)['design_certificate'](sample)
    good, common, complete, interiors, counts = design
    # This choice only sharpens the auxiliary box, never the test/failure rule.
    exponent = max(1, math.ceil((-ends(loglike)[0]+32)*Q(100, 69)))
    h = 2
    while 5*h*h < 7*(exponent+1): h += 1
    budget = math.ceil(Q(7, 10)*(exponent+1))
    epsilon = Q(2)**(-exponent)
    # Mills' inequality and the observed-category logit budget, both outward.
    tail_upper = ends(2*IV.exp(iv(Q(-h*h, 2)))/(iv(h)*IV.sqrt(2*IV.pi)))[1]
    assert tail_upper < epsilon/2 and ends(IV.exp(iv(budget)))[0] > 2/epsilon
    severity = [h+Q(budget, 3)/a for a in slopes]
    rater = Q(4, 3)*min(severity[c-1] for c in complete)
    radii = [rater, rater, severity[2]+rater]+[
        Q(budget)/a+k*(h+s+2*rater)
        for a, s in zip(slopes, severity) for k in (1, 2)]
    tangent = loglike
    for g, x, radius in zip(gradient, center, radii, strict=True):
        tangent += g*IV.mpf([iv(-radius-x).a, iv(radius-x).b])
    outside = ends(-exponent*IV.ln(2))[1]
    upper = max(ends(tangent)[1], outside)
    return dict(GlobalFixedSlopeLogLikelihoodUpper=str(upper),
        TangentUpper=str(ends(tangent)[1]), OutsideBoxLogLikelihoodUpper=str(outside),
        LikelihoodLevelPowerOfTwo=exponent, NormalTruncationH=h, LogitBudgetUpper=budget,
        NormalTailProbabilityUpper=str(tail_upper), CoordinateAbsoluteUppers=list(map(str, radii)),
        EndpointCells=[list(v) for v in sorted(good)], CompleteEndpointCriteria=complete,
        InteriorCategoryCounts=interiors, AllLocationAndStepNuisanceCovered=True,
        Method='concave_superlevel_box_support_plane', StationaryRootRequired=False,
        AllSlopeSupremumCertified=False)


def enclose(sample, psi, slopes, center, base, order=32):
    """Enclose original-coordinate value/gradient with the existing disk rule."""
    base['IV'].dps = 60
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    slopes = list(map(Q, slopes)); center = list(map(Q, center)); psi = Q(psi)
    assert len(center) == 9 and min(slopes) > 0 and math.prod(slopes) == 1
    assert all(len(roster) == 2 and len(y) == 6 for roster, y in sample)
    rater = [center[0], center[1], -center[0]-center[1]]
    criterion = [(-center[2]+psi)/2, (-center[2]-psi)/2, center[2]]
    step = [[Q(0), center[3+2*c], center[4+2*c], Q(0)] for c in range(3)]
    mesh, info = runpy.run_path(REGIONS)['integration_mesh'](rater, criterion, step, slopes)
    nodes = runpy.run_path(MOMENTS)['gauss_rule'](order, base)
    zero = IV.mpf(0); design = []
    for r in range(3):
        for c, a in enumerate(slopes):
            cell = []
            for k in range(4):
                v = [Q(0)]*9
                v[0] = -a*k*(1, 0, -1)[r]; v[1] = -a*k*(0, 1, -1)[r]
                v[2] = -a*k*(Q(-1, 2) if c < 2 else Q(1))
                if k in (1, 2): v[3+2*c+k-1] = -a
                cell.append(v)
            design.append(cell)
    geometry = {}
    for roster in sorted({g for g, y in sample}):
        cells = [(r-1)*3+c for r in roster for c in range(3)]
        maximum = [[max(abs(design[cell][k][j]) for k in range(4)) for j in range(9)] for cell in cells]
        gradient_bound = [Q(39, 7)*sum(row[j] for row in maximum) for j in range(9)]
        geometry[roster] = cells, gradient_bound
    counts = Counter(sample)
    observed = {key: [sum(design[cell][y][j] for cell, y in zip(geometry[key[0]][0], key[1]))
                     for j in range(9)] for key in counts}
    integrals = {key: [zero, [zero for j in range(9)]] for key in counts}
    print('Value/gradient enclosure:', len(mesh), 'certified segments, order', order, flush=True)
    for segment, (left, right) in enumerate(mesh):
        width = right-left; middle = (left+right)/2
        for node, weight in nodes:
            theta = iv(middle)+iv(width/2)*node
            mass = weight*iv(width/2)*IV.exp(-theta**2/2)
            probabilities, means = [], []
            for r in range(3):
                for c, a in enumerate(slopes):
                    cell = r*3+c
                    logits = [iv(a)*(k*(theta-iv(rater[r]+criterion[c]))-iv(step[c][k])) for k in range(4)]
                    shift = max(ends(v)[1] for v in logits)
                    raw = [IV.exp(v-iv(shift)) for v in logits]; total = sum(raw)
                    prob = [v/total for v in raw]; probabilities.append(prob)
                    means.append([sum((prob[k]*iv(design[cell][k][j]) for k in range(4)), zero) for j in range(9)])
            expected = {roster: [sum((means[cell][j] for cell in cells), zero) for j in range(9)]
                        for roster, (cells, bound) in geometry.items()}
            for key in counts:
                roster, y = key; value = mass
                for cell, score in zip(geometry[roster][0], y): value *= probabilities[cell][score]
                target = integrals[key]; target[0] += value
                for j in range(9): target[1][j] += value*(iv(observed[key][j])-expected[roster][j])
        if (segment+1) % 24 == 0: print('Value/gradient integration', segment+1, '/', len(mesh), flush=True)
    # Unchanged six-cell complex-disk and real normal-tail bounds.
    error = iv(Q(24*128, (2*order+1)*math.comb(2*order, order)**2))
    error += iv(Q(1, 6))*IV.exp(iv(-72))
    def expand(value, radius):
        return IV.mpf([iv(ends(value-radius)[0]).a, iv(ends(value+radius)[1]).b])
    loglike = zero; gradient = [zero for j in range(9)]
    for key, (mass, g) in integrals.items():
        mass = expand(mass, error); assert ends(mass)[0] > 0
        loglike += counts[key]*(IV.ln(mass)-IV.ln(2*IV.pi)/2)
        bound = geometry[key[0]][1]
        for j in range(9): gradient[j] += counts[key]*expand(g[j], error*iv(bound[j]))/mass
    moments = dict(Contrast=str(psi), Slopes=list(map(str, slopes)), LocationParameters=list(map(str, center)),
        LogLikelihood=list(map(str, ends(loglike))), Gradient=[list(map(str, ends(g))) for g in gradient],
        GradientCoordinates='Original nine location/cumulative-step coordinates',
        IntegrationMesh=[[str(a), str(b)] for a, b in mesh], MeshDiagnostics=info,
        QuadratureOrder=order, IntervalDigits=60, NormalTailEndpoint=12, HessianComputed=False)
    return moments, support_upper(sample, slopes, center, loglike, gradient, base)
