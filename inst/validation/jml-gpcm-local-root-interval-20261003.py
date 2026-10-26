"""Outward interval verification of ordinary-JML local roots at five saved fits.

Uses basic mpmath interval arithmetic and sqrt; exponential enclosures use an
explicit Taylor tail. No fitting, random data, population claims or public API.
Run: python3 THIS.py INPUT_DIRECTORY OUTPUT_JSON
"""
from fractions import Fraction as Q
from hashlib import sha256, md5
from itertools import combinations
from pathlib import Path
import json
import math
import sys
import mpmath
from mpmath import iv

iv.prec = 128
I = iv.mpf


def endpoint(x, side):
    sign, man, exponent, bits = x._mpi_[side]
    assert bits >= 0, 'Nonfinite interval endpoint'
    return Q((-1 if sign else 1) * int(man)) * Q(2) ** exponent


def lo(x):
    return endpoint(x, 0)


def hi(x):
    return endpoint(x, 1)


def interval_q(x):
    return I(x.numerator) / I(x.denominator)


def hx(x):
    value = float.fromhex(x)
    result = I(value)
    assert lo(result) == hi(result) == Q(value)
    return result


def vector(x):
    return [hx(v) for v in x]


def dot(x, y):
    return sum((a*b for a, b in zip(x, y)), I(0))


def norm(x):
    return iv.sqrt(sum((v**2 for v in x), I(0)))


def exp_positive(x):
    """For 0<=x: 32 Taylor terms, geometric remainder, then squaring."""
    assert lo(x) >= 0
    divisions = 0
    while hi(x) > Q(1, 2):
        x = x / 2
        divisions += 1
    term = total = I(1)
    for k in range(1, 33):
        term = term*x/k
        total = total+term
    # First omitted power is x^33/33!; subsequent term ratios <= x/34.
    tail = hi((term*x/33)/(1-x/34))
    result = total + I([0, 1])*interval_q(tail)
    for _ in range(divisions):
        result = result**2
    return result


def exp_bound(x):
    if lo(x) >= 0:
        return exp_positive(x)
    if hi(x) <= 0:
        return 1/exp_positive(-x)
    lower = lo(1/exp_positive(interval_q(-lo(x))))
    upper = hi(exp_positive(interval_q(hi(x))))
    return I([interval_q(lower).a, interval_q(upper).b])


def certify_radius(eta, epsilon, third, radius):
    """All final comparisons are exact rational inequalities."""
    q = epsilon+third*radius
    margin = radius-eta-epsilon*radius-third*radius**2/2
    return q < 1 and margin >= 0, q, margin


def self_check():
    # Exact scalar quadratic root, cubic worst case, and refusal at boundary.
    assert certify_radius(Q(1, 10), Q(0), Q(0), Q(1, 10))[0]
    assert certify_radius(Q(19, 200), Q(0), Q(1), Q(1, 10))[0]
    assert not certify_radius(Q(1, 2), Q(0), Q(1), Q(1))[0]
    assert not certify_radius(Q(1, 10), Q(0), Q(0), Q(1, 20))[0]
    assert not certify_radius(Q(0), Q(1), Q(0), Q(1))[0]
    assert lo(exp_bound(I(0))) == hi(exp_bound(I(0))) == 1
    # Independent rational enclosure for e: sum 1/k! and a geometric tail.
    partial = sum((Q(1, math.factorial(k)) for k in range(81)), Q(0))
    tail = Q(1, math.factorial(81))*Q(82, 81)
    e = exp_bound(I(1))
    assert lo(e) <= partial and hi(e) >= partial+tail
    inverse = exp_bound(I(-1))
    assert lo(inverse) <= 1/(partial+tail) and hi(inverse) >= 1/partial
    root = iv.sqrt(I(2))
    assert lo(root)**2 <= 2 <= hi(root)**2
    return 'Scalar contraction acceptance/refusal, rational exp(+/-1), exact exp(0), sqrt(2), exact binary input conversion'


def compute(case):
    p, nl, K = case['p'], case['nl'], case['K']
    beta = vector(case['beta'])
    B = [vector(row) for row in case['B']]
    assert all(hi(B[i][j]) == lo(B[i][j]) == 0 for i in range(p) for j in range(i))
    assert all(lo(B[j][j]) != 0 for j in range(p))
    columns = list(zip(*B))
    G = [I(0) for _ in range(p)]
    H = [[I(0) for _ in range(p)] for _ in range(p)]
    nuisance_gradient_squares = I(0)
    hessian_error_squares = I(0)
    row_geometry = []
    derivative_difference = 0.0
    for person in case['persons']:
        theta, nu = hx(person['theta']), hx(person['nu'])
        assert lo(nu) > 0
        tau = vector(person['tau'])
        g = [I(0) for _ in range(p+1)]
        h = [[I(0) for _ in range(p+1)] for _ in range(p+1)]
        geometry = []
        for row_number in person['rows']:
            row = row_number-1
            raw_s = case['slope'][row]
            s = vector([raw_s] if isinstance(raw_s, str) else raw_s)
            gamma = [dot(col[nl:], s) for col in columns]
            slope = exp_bound(dot(s, beta[nl:]))
            base, fv, ft, utilities, jac = [], [], [], [], []
            for k in range(K):
                d = vector(case['lin'][k][row])
                b = k*theta+dot(d, beta[:nl])
                v = k*nu
                t = [dot(col[:nl], d)+k*tau[j] for j, col in enumerate(columns)]
                base.append(b); fv.append(v); ft.append(t)
                utilities.append(slope*b)
                jac.append([slope*v]+[slope*(t[j]+b*gamma[j]) for j in range(p)])
            # Common fixed shift leaves the category probabilities unchanged.
            shift = max(hi(u) for u in utilities)
            weights = [exp_bound(u-interval_q(shift)) for u in utilities]
            denominator = sum(weights, I(0))
            prob = [w/denominator for w in weights]
            mean = [dot(prob, [j[a] for j in jac]) for a in range(p+1)]
            observed = case['y'][row]
            for a in range(p+1):
                g[a] += mean[a]-jac[observed][a]
                for b in range(a, p+1):
                    covariance = sum((prob[k]*(jac[k][a]-mean[a])*(jac[k][b]-mean[b])
                                      for k in range(K)), I(0))
                    if a == b == 0:
                        utility_hessian = [I(0)]*K
                    elif a == 0:
                        utility_hessian = [slope*v*gamma[b-1] for v in fv]
                    else:
                        utility_hessian = [slope*(t[a-1]*gamma[b-1]+t[b-1]*gamma[a-1]
                                                   +u*gamma[a-1]*gamma[b-1])
                                           for u, t in zip(base, ft)]
                    h[a][b] += covariance+dot(prob, utility_hessian)-utility_hessian[observed]
                    h[b][a] = h[a][b]
            geometry.append((slope, gamma, base, fv, ft))
        row_geometry.append(geometry)
        nuisance_gradient_squares += g[0]**2
        hessian_error_squares += (h[0][0]-1)**2+2*sum((v**2 for v in h[0][1:]), I(0))
        for a in range(p):
            G[a] += g[a+1]
            for b in range(p):
                H[a][b] += h[a+1][b+1]
        # Independent bridge comparison is a diagnostic, not an interval premise.
        original_g = [float.fromhex(x) for x in person['saved_gradient']]
        original_h = [[float.fromhex(x) for x in row] for row in person['saved_hessian']]
        D = [[float(hi(nu))]+[float(hi(x)) for x in tau]] + [[0.0]+[float(hi(x)) for x in row] for row in B]
        for a in range(p+1):
            expected = sum(D[j][a]*original_g[j] for j in range(p+1))
            derivative_difference = max(derivative_difference, abs(float((lo(g[a])+hi(g[a]))/2)-expected))
            for b in range(p+1):
                expected = sum(D[j][a]*original_h[j][k]*D[k][b] for j in range(p+1) for k in range(p+1))
                derivative_difference = max(derivative_difference, abs(float((lo(h[a][b])+hi(h[a][b]))/2)-expected))
    eta = hi(iv.sqrt(nuisance_gradient_squares+sum((v**2 for v in G), I(0))))
    for a in range(p):
        for b in range(p):
            hessian_error_squares += (H[a][b]-(a == b))**2
    epsilon = hi(iv.sqrt(hessian_error_squares))
    assert epsilon < 1
    radius = 2*eta/(1-epsilon)
    R = interval_q(radius)
    coefficients = []
    for geometry in row_geometry:
        third = [I(0) for _ in range(4)]
        for slope, gamma, base, fv, ft in geometry:
            s = norm(gamma)
            amax = slope*exp_bound(R*s)
            ranges = [Q(0)]*6
            for k, l in combinations(range(K), 2):
                v = abs(fv[l]-fv[k]); t = norm([a-b for a, b in zip(ft[l], ft[k])])
                height = abs(base[l]-base[k])+R*iv.sqrt(v**2+t**2)
                values = [v, t+height*s, v*s, 2*t*s+height*s**2,
                          v*s**2, 3*t*s**2+height*s**3]
                ranges = [max(old, hi(amax*value)) for old, value in zip(ranges, values)]
            av, at, hvt, htt, tvtt, tttt = [interval_q(x) for x in ranges]
            terms = [av**3/4, av**2*at/4+av*hvt/2,
                     av*at**2/4+(av*htt+2*at*hvt)/4+tvtt,
                     at**3/4+3*at*htt/4+tttt]
            third = [a+b for a, b in zip(third, terms)]
        coefficients.append([hi(x) for x in third])
    third = (max(c[0] for c in coefficients)+3*max(c[1] for c in coefficients)
             +3*hi(iv.sqrt(sum((interval_q(c[2])**2 for c in coefficients), I(0))))
             +sum(c[3] for c in coefficients))
    passed, q, margin = certify_radius(eta, epsilon, third, radius)
    result = {'id': case['id'], 'certified': passed, 'eta_upper': str(eta),
              'hessian_identity_error_upper': str(epsilon), 'third_upper': str(third),
              'trial_radius': str(radius), 'trial_q': str(q), 'self_map_margin': str(margin),
              'saved_derivative_difference': derivative_difference,
              'N': case['N'], 'levels': case['levels'], 'model': case['model'],
              'active_persons': len(case['persons'])}
    assert derivative_difference < 1e-10
    if passed:
        # Round the analytic small root upward, then check it in exact arithmetic.
        discriminant = (1-epsilon)**2-2*third*eta
        assert discriminant > 0
        lower_sqrt = lo(iv.sqrt(interval_q(discriminant)))
        refined = 2*eta/(1-epsilon+lower_sqrt)
        ok, q_refined, refined_margin = certify_radius(eta, epsilon, third, refined)
        assert ok and refined <= radius
        coordinate_bounds = [refined*hi(norm(row)) for row in B]
        euclidean = refined*hi(norm([v for row in B for v in row]))
        result.update(radius=str(refined), q=str(q_refined),
                      refined_self_map_margin=str(refined_margin),
                      coordinate_bounds=[str(x) for x in coordinate_bounds],
                      structural_euclidean_upper=str(euclidean),
                      objective_gap_upper=str(eta**2/(2*(1-q_refined))))
    result['display'] = {k: float(Q(result[k])) for k in
                         ('eta_upper', 'hessian_identity_error_upper', 'third_upper', 'trial_q')}
    if passed:
        result['display'].update({k: float(Q(result[k])) for k in
                                 ('radius', 'q', 'structural_euclidean_upper', 'objective_gap_upper')})
        result['display']['max_coordinate_upper'] = float(max(coordinate_bounds))
    return result


def run(inputs, output):
    checks = self_check()
    results, identities = [], {}
    for path in sorted(inputs.glob('*.json')):
        case = json.loads(path.read_text())
        for filename, digest in {**case['inputs'], **case['source']}.items():
            assert md5(Path(filename).read_bytes()).hexdigest() == digest, filename
        identities[str(path)] = sha256(path.read_bytes()).hexdigest()
        result = compute(case)
        results.append(result)
        print(result['id'], result['certified'], result['display'], flush=True)
    assert len(results) == 5
    payload = {'source_sha256': sha256(Path(__file__).read_bytes()).hexdigest(),
               'input_sha256': identities, 'python': sys.version, 'mpmath': mpmath.__version__,
               'interval_bits': iv.prec, 'checks': checks,
               'scope': 'Local roots of saved ordinary extended-profile likelihoods; no global selection or sampling/structural-truth covariance qualification',
               'results': results}
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('x') as stream:
        json.dump(payload, stream, indent=2)
        stream.write('\n')


if __name__ == '__main__':
    assert len(sys.argv) == 3
    run(Path(sys.argv[1]), Path(sys.argv[2]))
