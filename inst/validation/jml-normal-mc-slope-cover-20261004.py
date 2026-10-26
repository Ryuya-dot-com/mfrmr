"""Cover the positive product-one slope domain for a complete MC-sum ray.

Reuse exact dual witnesses; never refit the JML statistic. Pending boxes are
unresolved computation, not exclusions. A completed ray is an outer bound,
not an exact endpoint or an independent coverage experiment.
"""
from fractions import Fraction as Q
from collections import defaultdict
from pathlib import Path
import argparse
import csv
import hashlib
import json
import math
import runpy
from itertools import product

import numpy as np
from scipy.linalg import qr
from scipy.optimize import minimize_scalar
from scipy.special import xlogy, logsumexp

BASE = Path('inst/validation/jml-normal-importance-mc-20261003.py')
DUAL = Path('inst/validation/jml-normal-profile-dual-20261004.py')
FOREST = Path('inst/validation/jml-normal-profile-forest-20261004.py')
FOREST_ENDPOINT = Path('inst/validation/jml-normal-forest-endpoint-20261004.py')
PROFILE_REGIONS = Path('inst/validation/jml-normal-profile-regions-check-20261004.py')
SHARP_CONSTANT = runpy.run_path(str(PROFILE_REGIONS))['sharp_constant']
OLD_ROOT = '/Users/tohokusla/Dropbox/MFRM_Application/mfrmr/development/'


def verify(hashes):
    for name, digest in hashes.items():
        path = Path(name.removeprefix(OLD_ROOT))
        assert hashlib.sha256(path.read_bytes()).hexdigest() == digest, name


def witness(sample, record, design):
    """Recover the saved rational probabilities and recheck exact balance."""
    a = list(map(Q, record['Slopes']))
    w = record['Witness']; v = list(map(Q, w['ProjectionMultiplier']))
    rows = design(sample, a); probabilities = []; balance = [Q(0)] * 9
    g = [Q(0)] * len(sample); H = Q(0)
    for row, nums in zip(rows, w['ProbabilityNumerators'], strict=True):
        person, y, slope, h, D = row
        q = [Q(n, int(w['ProbabilityDenominator'])) for n in nums]
        mean = [sum(q[k] * D[k][j] for k in range(4)) for j in range(9)]
        q = [q[k] * (1 + sum((D[k][j] - mean[j]) * v[j] for j in range(9)))
             for k in range(4)]
        assert min(q) > 0 and sum(q) == 1
        for j in range(9):
            balance[j] += D[y][j] - sum(q[k] * D[k][j] for k in range(4))
        residual = y - sum(k * q[k] for k in range(4))
        g[person] += slope * residual; H += h * residual
        probabilities.append(q)
    assert balance == [0] * 9 and H == Q(record['AffineUpperSlope'])
    y = [row[1] for row in rows]
    delta = np.eye(4)[y]
    return dict(a=a, q=probabilities, y=y, g=g, H=H,
                S=sum(z*z for z in g), delta=delta,
                direction=np.asarray(probabilities, float) - delta,
                missing=[max(1-probabilities[i][y[i]] for i in range(c, len(y), 3))
                         for c in range(3)])


def transfer_float(w, lower, upper, psi):
    """Choose a feasible scalar only; floating values cannot exclude a box."""
    a = np.asarray(w['a'], float)
    cap = min(np.asarray(lower, float) / (a * np.asarray(w['missing'], float)))
    S, H = float(w['S']), float(w['H'])
    # Entropy is at least -number_of_ratings*log(4). Beyond this positive
    # quadratic root the bound cannot improve on the always-valid zero bound.
    if S > 0:
        b = H * float(psi)
        radius = math.sqrt(b*b + 2*S*len(w['y'])*math.log(4))
        cap = min(cap, (2*len(w['y'])*math.log(4)/(radius+b)
                        if b >= 0 else (radius-b)/S))
    cap = Q(float(cap))
    exact_cap = min(lo/(aa*m) for lo, aa, m in zip(lower, w['a'], w['missing']))
    cap = min(cap, exact_cap) * Q(999999, 1000000)
    def value(z):
        c = float(cap)*z; entropy = np.zeros(3)
        for limits in (upper, lower):
            ratio = np.tile(c*a/np.asarray(limits, float), len(w['y'])//3)
            p = np.maximum(0, w['delta'] + ratio[:, None]*w['direction'])
            h = xlogy(p, p).sum(axis=1).reshape(-1, 3).sum(axis=0)
            if limits is upper: entropy = h
            else: entropy = np.maximum(entropy, h)
        return float(entropy.sum() + c*c*S/2 + c*H*float(psi))
    opt = minimize_scalar(value, bounds=(0, 1), method='bounded',
                          options={'xatol': 1e-12})
    c = cap*Q(float(opt.x))
    return min(0., value(opt.x)), c


def transfer_upper(w, lower, upper, psi, c, base):
    """Exact feasibility and outward entropy bound for an entire slope box.

    q_new = delta_y + c*a_reference/a_new*(q_reference-delta_y).
    All nuisance balances and Person scores scale by c. Each owner's entropy
    is convex in c*a_reference/a_new, so its maximum is at a box endpoint.
    """
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    assert 0 <= c <= min(lo/(a*m) for lo, a, m in zip(lower, w['a'], w['missing']))
    entropy = Q(0)
    for owner in range(3):
        endpoints = []
        for limit in (lower[owner], upper[owner]):
            ratio = c*w['a'][owner]/limit; h = IV.mpf(0)
            for i in range(owner, len(w['q']), 3):
                p = [Q(k == w['y'][i]) + ratio*(q-Q(k == w['y'][i]))
                     for k, q in enumerate(w['q'][i])]
                assert min(p) >= 0 and sum(p) == 1
                h += sum((iv(z)*IV.ln(iv(z)) for z in p if z), IV.mpf(0))
            endpoints.append(ends(h)[1])
        entropy += max(endpoints)
    return min(Q(0), entropy + c*c*w['S']/2 + c*w['H']*psi)


def tail_upper(entropy, certificates, lower, base):
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    result = entropy
    for cert, a in zip(certificates, lower):
        s = Q(cert['Power']); bound = iv((1-s)*entropy)
        for positive, negative in cert['OppositeOrientationCounts']:
            n = positive+negative; m = min(positive, negative)
            if m:
                term = n*IV.ln(iv(Q(2*n, 5*m)/(a*s)))-n+2*m
                bound += iv(min(Q(0), ends(term)[1]))
        result = min(result, ends(bound)[1])
    return result


def pair_allocations(sample):
    """All disjoint owner choices within each roster; no Person used twice."""
    result = []
    for roster in ((1, 2), (1, 3), (2, 3)):
        indices = [i for i, (g, y) in enumerate(sample) if g == roster]
        states = {(0,)*6: ()}
        for i in indices:
            y = sample[i][1]
            updated = {state: choices+(-1,) for state, choices in states.items()}
            for state, choices in states.items():
                for c in range(3):
                    if y[c] == y[c+3]: continue
                    new = list(state); new[2*c+(y[c] < y[c+3])] += 1
                    updated.setdefault(tuple(new), choices+(c,))
            states = updated
        keys = sorted(states)
        raw = np.asarray(keys).reshape(-1, 3, 2)
        n = raw.sum(2); m = raw.min(2); n = np.where(m > 0, n, 0)
        constant = np.zeros_like(n, dtype=float); ok = n > 0
        constant[ok] = n[ok]*np.log(2*n[ok]/(5*m[ok]))-n[ok]+2*m[ok]
        result.append(dict(indices=indices, counts=keys, choices=[states[k] for k in keys],
                           n=n, constant=constant))
    return result


def static_entropies(sample, base):
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    result = []
    for c in range(3):
        counts = [[0]*4 for r in range(3)]
        for roster, y in sample:
            for t, r in enumerate(roster): counts[r-1][y[c+3*t]] += 1
        h = IV.mpf(0)
        for row in counts:
            total = sum(row)
            h += sum((n*IV.ln(iv(Q(n, total))) for n in row if n), IV.mpf(0))
        result.append(ends(h)[1])
    return result


def conditional_face_rows(sample, owner, record, solve):
    """Project a saved candidate on a probability face; exact checks decide."""
    active = [(g, (y[owner], y[owner+3])) for g, y in sample if 0 < y[owner]+y[owner+3] < 6]
    n = len(active); rows = 2*n; variables = 8*n
    if not n: return None
    A = np.zeros((rows+4+n, variables), int); target = [1]*rows+[0]*(4+n)
    for p, (g, y) in enumerate(active):
        for t, r in enumerate(g):
            i = 2*p+t
            for k in range(4):
                a = 4*i+k; A[i, a] = 1
                A[rows, a] = -k*(1, 0, -1)[r-1]; A[rows+1, a] = -k*(0, 1, -1)[r-1]
                A[rows+2, a] = -int(k == 1); A[rows+3, a] = -int(k == 2); A[rows+4+p, a] = k
            for j in range(rows, len(target)): target[j] += int(A[j, 4*i+y[t]])
    initial = [Q(v, int(record['Denominator'])) for row in record['Numerators'] for v in row]
    probability = np.asarray(initial, float)
    for cutoff in (1e-10, 1e-12, 1e-8, 1e-6):
        support = np.flatnonzero(probability > cutoff); B = A[:, support]
        # Floating QR only proposes a correction basis. Rank, positivity and
        # every balance equation are verified over rationals before use.
        unused, unused, piv = qr(B*probability[support], pivoting=True)
        piv = piv[:np.linalg.matrix_rank(B)]
        unused, unused, selected = qr(B[:, piv].T, pivoting=True); selected = selected[:len(piv)]
        q = [p if float(p) > cutoff else Q(0) for p in initial]
        residual = [Q(target[j])-sum(int(A[j, i])*q[i] for i in range(variables)) for j in range(len(target))]
        try:
            correction = solve([[Q(int(B[j, k])) for k in piv] for j in selected],
                               [residual[j] for j in selected])
        except StopIteration:
            continue
        for k, v in zip(piv, correction): q[support[k]] += v
        if min(q) < 0 or any(sum(int(A[j, i])*q[i] for i in range(variables)) != target[j]
                            for j in range(len(target))): continue
        full = []; p = 0
        for roster, y in sample:
            if 0 < y[owner]+y[owner+3] < 6:
                full.extend((q[8*p:8*p+4], q[8*p+4:8*p+8])); p += 1
            else:
                full.extend([[Q(k == y[owner+3*t]) for k in range(4)] for t in (0, 1)])
        return full
    return None


def empirical_conditional(sample, record, base, solve=None):
    """Improve a separated fallback using exact feasible conditional rows."""
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    owners = list(record['Owners'])
    for c, old in enumerate(owners):
        if old['WitnessMethod'] != 'opposite_orientation_swap': continue
        groups = defaultdict(list)
        for roster, y in sample: groups[roster, y[c]+y[c+3]].append((y[c], y[c+3]))
        rows = []
        for roster, y in sample:
            ys = groups[roster, y[c]+y[c+3]]
            rows.extend([[Q(sum(z[t] == k for z in ys), len(ys)) for k in range(4)] for t in (0, 1)])
        candidates = [('roster_total_empirical', rows)]
        face = conditional_face_rows(sample, c, old, solve) if solve is not None else None
        if face is not None: candidates.append(('conditional_face_projection', face))
        for method, rows in candidates:
            # Independent raw-statistic check: Person pair totals, Rater totals
            # and shared category counts eliminate all conditional nuisances.
            for person, (roster, y) in enumerate(sample):
                assert all(sum(row) == 1 and min(row) >= 0 for row in rows[2*person:2*person+2])
                assert sum(k*rows[2*person+t][k] for t in (0, 1) for k in range(4)) == y[c]+y[c+3]
            for r in (1, 2, 3):
                assert sum(y[c+3*roster.index(r)]-sum(k*rows[2*p+roster.index(r)][k] for k in range(4))
                           for p, (roster, y) in enumerate(sample) if r in roster) == 0
            for k in range(4):
                assert sum(Q(y[c+3*t] == k)-rows[2*p+t][k]
                           for p, (roster, y) in enumerate(sample) for t in (0, 1)) == 0
            entropy = ends(sum((iv(p)*IV.ln(iv(p)) for row in rows for p in row if p), IV.mpf(0)))[1]
            if entropy < Q(owners[c]['ConditionalLogLikelihoodUpper']):
                gap = Q(old['ConditionalDualityGapUpper'])+entropy-Q(old['ConditionalLogLikelihoodUpper'])
                assert gap >= 0
                owners[c] = dict(old, WitnessMethod=method,
                                 PairProbabilities=[list(map(str, row)) for row in rows],
                                 ConditionalDualityGapUpper=str(gap),
                                 ConditionalLogLikelihoodUpper=str(entropy))
    return dict(record, Owners=owners,
                ConditionalLogLikelihoodUpper=str(sum(Q(r['ConditionalLogLikelihoodUpper']) for r in owners)))


def static_normal_scores(sample):
    """Signed Person scores for the saturated Rater/category probabilities."""
    mean = {}
    for r in (1, 2, 3):
        for c in range(3):
            ys = [y[3*roster.index(r)+c] for roster, y in sample if r in roster]
            mean[r, c] = Q(sum(ys), len(ys))
            assert sum(Q(y)-mean[r, c] for y in ys) == 0
    scores = [[sum(y[3*t+c]-mean[r, c] for t, r in enumerate(roster)) for roster, y in sample]
              for c in range(3)]
    assert all(sum(row) == 0 for row in scores)
    return dict(Scores=scores, CrossProducts=[[sum(x*y for x, y in zip(a, b)) for b in scores] for a in scores])


def static_normal_upper(sample, g, static, moments, lower, upper, allocations, base):
    """Exact normal MGF, retaining signed cross-owner Person scores."""
    dynamic = [Q(r['ConditionalLogLikelihoodUpper']) for r in g['Owners']]
    best = sum(dynamic); chosen = None; candidates = []
    for flags in product((False, True), repeat=3):
        E = sum(static[c] if flags[c] else dynamic[c] for c in range(3))
        axes = [(lower[c], upper[c]) if flags[c] else (Q(0),) for c in range(3)]
        normal = max(sum(a[j]*a[k]*moments['CrossProducts'][j][k]
                         for j in range(3) for k in range(3))/2 for a in product(*axes))
        assert normal >= 0
        candidates.append((E+normal, flags, E, normal))
    for unused, flags, E, normal in sorted(candidates):
        value, powered = powered_mixture(sample, lower, E, normal, allocations, base)
        if value < best:
            best = value; chosen = dict(StaticOwners=list(flags), PoweredPairs=powered)
    return best, chosen


def allocated_choice(g, static, allocations, lower, upper):
    """Choose a valid bound, allowing static small-slope owner probabilities.

    E is a conditional log-likelihood bound at theta=0 for static owners;
    their change at other theta is at most t*sum(abs(theta)), t=6*sum(a).
    With k=(1-s)*t, the tilted normal density is at most (2/5)*exp(k^2/2),
    and its total mass is at most exp(k+k^2/2). Selected pairs are disjoint.
    """
    dynamic = [Q(x['ConditionalLogLikelihoodUpper']) for x in g['Owners']]
    best = float(sum(dynamic)); choice = None
    for flags in product((False, True), repeat=3):
        E = sum(static[c] if flags[c] else dynamic[c] for c in range(3))
        if E >= sum(dynamic) and any(flags): continue
        t = 6*sum(upper[c] for c in range(3) if flags[c])
        powers = [min(Q(1), Q(n)/(-E)) for n in range(1, 31)]
        s = np.asarray(powers, float); k = (1-s)*float(t)
        values = (1-s)*float(E)+30*(k+k*k/2)
        selected = []
        for group in allocations:
            term = group['constant'][None, :, :] - group['n'][None, :, :]*(
                np.log(np.asarray(lower, float))[None, None, :] + np.log(s)[:, None, None]
                + k[:, None, None])
            candidate = np.minimum(0, term).sum(2)
            index = candidate.argmin(1); selected.append(index)
            values += candidate[np.arange(len(s)), index]
        index = int(values.argmin())
        if values[index] < best:
            best = float(values[index])
            choice = dict(StaticOwners=list(flags), Power=str(powers[index]),
                          Assignments=[list(group['choices'][int(ids[index])])
                                       for group, ids in zip(allocations, selected)])
    return best, choice


def allocated_upper(sample, g, static, lower, upper, choice, base):
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    if choice is None: return Q(g['ConditionalLogLikelihoodUpper'])
    flags = choice['StaticOwners']; s = Q(choice['Power']); assert 0 < s <= 1
    assert len(flags) == 3 and all(type(flag) is bool for flag in flags)
    E = sum(static[c] if flags[c] else Q(g['Owners'][c]['ConditionalLogLikelihoodUpper'])
            for c in range(3))
    k = (1-s)*6*sum(upper[c] for c in range(3) if flags[c])
    return (1-s)*E+len(sample)*(k+k*k/2)+assigned_pair_upper(sample, lower, s, choice['Assignments'], base, k)


def assigned_pair_upper(sample, lower, s, assignments_by_roster, base, k=Q(0)):
    IV, iv, ends = (base[name] for name in ('IV', 'iv', 'ends'))
    assert 0 < s <= 1 and k >= 0
    value = IV.mpf(0)
    for roster, assignments in zip(((1, 2), (1, 3), (2, 3)), assignments_by_roster, strict=True):
        rows = [y for gg, y in sample if gg == roster]; counts = [[0, 0] for c in range(3)]
        for y, c in zip(rows, assignments, strict=True):
            assert c in (-1, 0, 1, 2)
            if c < 0: continue
            assert y[c] != y[c+3]
            counts[c][y[c] < y[c+3]] += 1
        for a, (positive, negative) in zip(lower, counts):
            n = positive+negative; m = min(positive, negative)
            if m:
                term = n*IV.ln(iv(Q(2*n, 5*m)/(a*s)))-n+2*m-n*iv(k)
                value += iv(min(Q(0), ends(term)[1]))
    return ends(value)[1]


def endpoint_pairs(sample, direction):
    """Disjoint cells at a common Rater; shared Person scores remain dependent."""
    scores = [0]*len(sample); pairs = []
    for r in (1, 2, 3):
        first = [j for j, (g, y) in enumerate(sample) if r in g and
                 y[3*g.index(r)] == (3 if direction > 0 else 0)]
        second = [j for j, (g, y) in enumerate(sample) if r in g and
                  y[3*g.index(r)+1] == (0 if direction > 0 else 3)]
        while first and second:
            j, k = min(product(first, second), key=lambda z: 0 if z[0] == z[1] else
                       2+2*direction*(scores[z[0]]-scores[z[1]]))
            pairs.append((r, j, k)); scores[j] += direction; scores[k] -= direction
            first.remove(j); second.remove(k)
    return dict(Pairs=pairs, Scores=scores, S=sum(x*x for x in scores),
                H=-direction*len(pairs), AbsoluteScore=sum(abs(x) for x in scores))


def endpoint_upper(sample, g, static, pairs, lower, upper, psi, base):
    """Combine a paired endpoint dual with conditional entropy and normal MGF.

    Endpoint flips c/(3*a) cancel all location/step nuisance terms exactly.
    With power s, k=(1-s)*t, the normal integral is bounded by
    exp(s^2*c^2*S/2 + s*c*k*sum(abs(g)) + N*(k+k^2/2)).
    Retain the full Person score sums, including repeated Rater contributions.
    """
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    dynamic = [Q(z['ConditionalLogLikelihoodUpper']) for z in g['Owners']]
    best = sum(dynamic); selected = None; n = len(sample); count = len(pairs['Pairs'])
    if not count: return best, selected
    assert pairs['H']*psi < 0
    for fraction in (Q(1), Q(1, 2), Q(1, 4)):
        c = 3*min(lower[:2])*fraction; entropy = Q(0)
        for owner in (0, 1):
            h = []
            for a in (lower[owner], upper[owner]):
                flip = c/(3*a); assert 0 <= flip <= 1
                value = sum((iv(p)*IV.ln(iv(p)) for p in (flip, 1-flip) if p), IV.mpf(0))
                h.append(ends(value)[1])
            entropy += count*max(h)
        for static_third in (False, True):
            E = sum(dynamic[:2])+(static[2] if static_third else dynamic[2])
            t = 6*upper[2] if static_third else Q(0)
            constant = E+n*(t+t*t/2)
            linear = -E+entropy+c*pairs['H']*psi+c*t*pairs['AbsoluteScore']-n*(t+t*t)
            quadratic = (c*c*pairs['S']-2*c*t*pairs['AbsoluteScore']+n*t*t)/2
            assert quadratic >= 0
            s = max(Q(0), min(Q(1), -linear/(2*quadratic))) if quadratic else Q(linear < 0)
            value = constant+linear*s+quadratic*s*s
            if value < best:
                best = value
                selected = dict(Scalar=str(c), Power=str(s), StaticThird=static_third)
    return best, selected


def check_endpoint(sample, pairs, slopes, c, base, design):
    """Rebuild the binary probabilities and every raw nuisance coefficient."""
    rows = design(sample, slopes); flips = {}; seen = set()
    for r, j, k in pairs['Pairs']:
        for person, owner in ((j, 0), (k, 1)):
            index = 6*person+3*sample[person][0].index(r)+owner
            assert index not in seen; seen.add(index)
            flips[index] = c/(3*slopes[owner])
    scores = [Q(0)]*len(sample); balance = [Q(0)]*9; H = Q(0)
    for i, (person, y, a, h, D) in enumerate(rows):
        q = [Q(k == y) for k in range(4)]
        if i in flips:
            assert y in (0, 3)
            flip = flips[i]; q[y] -= flip; q[3-y] += flip
        assert min(q) >= 0 and sum(q) == 1
        residual = y-sum(k*q[k] for k in range(4)); scores[person] += a*residual; H += h*residual
        for j in range(9): balance[j] += D[y][j]-sum(q[k]*D[k][j] for k in range(4))
    assert balance == [0]*9 and scores == [c*z for z in pairs['Scores']] and H == c*pairs['H']


def mixture_witness(sample, record, pairs, base):
    """Recover balanced conditional probabilities, with a static third owner."""
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    observed = [score for roster, y in sample for score in y]
    q = [[Q(k == y) for k in range(4)] for y in observed]
    for owner, saved in enumerate(record['Owners']):
        assert saved['Owner'] == owner+1
        active = 0; rater = [Q(0)]*3; category = [Q(0)]*4
        for person, (roster, y) in enumerate(sample):
            total = y[owner]+y[owner+3]; expected = Q(0)
            for t, r in enumerate(roster):
                index = 6*person+3*t+owner
                if 0 < total < 6:
                    if saved['WitnessMethod'] in ('roster_total_empirical', 'conditional_face_projection'):
                        probabilities = list(map(Q, saved['PairProbabilities'][2*person+t]))
                    elif saved['WitnessMethod'] == 'opposite_orientation_swap':
                        flip = Q(saved['SwapProbabilities'][active]); probabilities = [Q(0)]*4
                        probabilities[y[owner+3*t]] += 1-flip
                        probabilities[y[owner+3*(1-t)]] += flip
                    else:
                        assert saved['WitnessMethod'] == 'positive_rational_projection'
                        v = list(map(Q, saved['StructuralProjection']))
                        u = Q(saved['PersonProjection'][active])
                        probabilities = [Q(z, int(saved['Denominator']))
                                         for z in saved['Numerators'][2*active+t]]
                        severity = (v[0], v[1], -v[0]-v[1])[r-1]
                        shift = [k*(u-severity)-(v[2] if k == 1 else v[3] if k == 2 else 0)
                                 for k in range(4)]
                        mean = sum(p*z for p, z in zip(probabilities, shift))
                        probabilities = [p*(1+z-mean) for p, z in zip(probabilities, shift)]
                    q[index] = probabilities
                assert min(q[index]) >= 0 and sum(q[index]) == 1
                mean = sum(k*q[index][k] for k in range(4)); expected += mean
                rater[r-1] += observed[index]-mean
                for k in range(4): category[k] += (observed[index] == k)-q[index][k]
            assert expected == total
            active += 0 < total < 6
        assert active == saved['ActivePairs'] and rater == [0]*3 and category == [0]*4
    static = {}
    for r in (1, 2, 3):
        ys = [y[3*roster.index(r)+2] for roster, y in sample if r in roster]
        static[r] = [Q(ys.count(k), len(ys)) for k in range(4)]
    third = [static[r] for roster, y in sample for r in roster]
    third_score = [sum(y[3*t+2]-sum(k*static[r][k] for k in range(4))
                       for t, r in enumerate(roster)) for roster, y in sample]
    # Static probabilities reproduce each Rater's complete category counts.
    for r in (1, 2, 3):
        for k in range(4):
            assert sum((y[3*roster.index(r)+2] == k)-static[r][k]
                       for roster, y in sample if r in roster) == 0
    direction = [[Q(0)]*4 for unused in q]
    for r, j, k in pairs['Pairs']:
        for person, owner in ((j, 0), (k, 1)):
            index = 6*person+3*sample[person][0].index(r)+owner
            assert direction[index] == [0]*4
            direction[index][observed[index]] = -1
            direction[index][3-observed[index]] = 1
    entropy = []
    for rows in ([q[i] for i in range(2, len(q), 3)], third):
        entropy.append(ends(sum((iv(p)*IV.ln(iv(p)) for row in rows for p in row if p), IV.mpf(0)))[1])
    return dict(q=q, delta=np.eye(4)[observed], q_float=np.asarray(q, float),
                direction=direction, direction_float=np.asarray(direction, float),
                third=third, third_score=third_score, third_entropy=entropy, pairs=pairs)


def mixture_float(w, lower, upper, psi):
    """Propose feasible mixtures; only the separate rational check excludes."""
    best = math.inf; choice = None
    own = np.asarray(w['q_float']).reshape(-1, 3, 4)
    delta = w['delta'].reshape(-1, 3, 4)
    direction = w['direction_float'].reshape(-1, 3, 4)
    scores = np.asarray(w['pairs']['Scores'], float)
    third_score = np.asarray(w['third_score'], float)
    for factor in (Q(1), Q(1, 2), Q(1, 4)):
        c = 3*min(lower[:2])*factor
        for static in (False, True):
            maximum = float(c)
            S = w['pairs']['S']
            if S:
                # Only select a useful witness: beyond this quadratic root
                # the entropy floor prevents an upper bound below zero.
                cross = abs(float(sum(Q(g)*d for g, d in zip(w['pairs']['Scores'], w['third_score']))))
                linear = float(w['pairs']['H']*psi)-(float(upper[2])*cross if static else 0)
                radius = math.sqrt(linear*linear+2*S*len(w['q'])*math.log(4))
                maximum = min(maximum, (radius-linear)/S)
            cap = min(c, Q(maximum))
            def value(s):
                entropies = []
                for limits in (lower, upper):
                    ratios = np.asarray([float(c/(3*a)) for a in limits[:2]])
                    p = (1-s)*own[:, :2]+s*delta[:, :2]+s*ratios[None, :, None]*direction[:, :2]
                    entropies.append(xlogy(np.maximum(p, 0), np.maximum(p, 0)).sum(axis=(0, 2)))
                entropy = np.maximum(*entropies).sum()+float(w['third_entropy'][int(static)])
                normal = max(np.square(s*float(c)*scores+(float(a)*third_score if static else 0)).sum()/2
                             for a in (lower[2], upper[2]))
                return float(entropy+normal+s*float(c)*w['pairs']['H']*float(psi))
            opt = minimize_scalar(lambda z: value(float(cap/c)*z), bounds=(0, 1), method='bounded',
                                  options={'xatol': 1e-11})
            power = min((Q(0), cap/c, cap/c*Q(float(opt.x))), key=lambda s: value(float(s)))
            candidate = value(float(power))
            if candidate < best:
                best = candidate; choice = dict(Scalar=str(c), Power=str(power), StaticThird=static)
    return best, choice


def mixture_terms(w, lower, upper, psi, choice, base):
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    c, s = Q(choice['Scalar']), Q(choice['Power']); static = choice['StaticThird']
    assert 0 <= s <= 1 and 0 < c <= 3*min(lower[:2]) and type(static) is bool
    entropy = w['third_entropy'][int(static)]
    for owner in (0, 1):
        endpoints = []
        for a in (lower[owner], upper[owner]):
            flip = c/(3*a); h = IV.mpf(0)
            for i in range(owner, len(w['q']), 3):
                y = int(np.argmax(w['delta'][i]))
                probabilities = [(1-s)*w['q'][i][k]+s*Q(k == y)+s*flip*w['direction'][i][k]
                                 for k in range(4)]
                assert min(probabilities) >= 0 and sum(probabilities) == 1
                h += sum((iv(p)*IV.ln(iv(p)) for p in probabilities if p), IV.mpf(0))
            endpoints.append(ends(h)[1])
        entropy += max(endpoints)
    normal = max(sum((s*c*g+(a*d if static else 0))**2 for g, d in
                     zip(w['pairs']['Scores'], w['third_score']))/2 for a in (lower[2], upper[2]))
    return entropy+s*c*w['pairs']['H']*psi, normal


def mixture_upper(w, lower, upper, psi, choice, base):
    return min(Q(0), sum(mixture_terms(w, lower, upper, psi, choice, base)))


def powered_mixture(sample, lower, E, normal, allocations, base):
    """A normal tilt preserves independence and the density bound for pairs."""
    assert normal >= 0
    best = E+normal; choice = None
    A = 2*float(normal); B = -float(E)-A
    powers = []
    for n in range(1, len(sample)+1):
        if A:
            radius = math.sqrt(B*B+4*A*n)
            power = 2*n/(radius+B) if B >= 0 else (radius-B)/(2*A)
        else: power = n/B if B > 0 else 1
        powers.append(min(Q(1), Q(power)))
    s = np.asarray(powers, float)
    values = (1-s)*float(E)+np.square(1-s)*float(normal)
    selected = []
    for group in allocations:
        terms = group['constant'][None, :, :]-group['n'][None, :, :]*(
            np.log(np.asarray(lower, float))[None, None, :]+np.log(s)[:, None, None])
        candidate = np.minimum(0, terms).sum(2)
        indices = candidate.argmin(1); selected.append(indices)
        values += candidate[np.arange(len(s)), indices]
    index = int(values.argmin())
    if values[index] < float(best):
        power = powers[index]
        assignments = [list(group['choices'][int(ids[index])]) for group, ids in zip(allocations, selected)]
        upper = ((1-power)*E+(1-power)**2*normal+
                 assigned_pair_upper(sample, lower, power, assignments, base))
        if upper < best:
            best = upper; choice = dict(Power=str(power), Assignments=assignments)
    return best, choice


def check_mixture(sample, w, lower, upper, psi, choice, base, design):
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    c, s = Q(choice['Scalar']), Q(choice['Power']); static = choice['StaticThird']
    bound = mixture_upper(w, lower, upper, psi, choice, base)
    for slopes in (lower, upper, [(a+b)/2 for a, b in zip(lower, upper)]):
        balance = [Q(0)]*9; scores = [Q(0)]*len(sample); H = Q(0); entropy = IV.mpf(0)
        for i, (person, y, a, h, D) in enumerate(design(sample, slopes)):
            if i % 3 == 2:
                q = w['third'][i//3] if static else w['q'][i]
            else:
                q = [(1-s)*w['q'][i][k]+s*Q(k == y)+s*c/(3*a)*w['direction'][i][k]
                     for k in range(4)]
            assert min(q) >= 0 and sum(q) == 1
            residual = y-sum(k*q[k] for k in range(4)); scores[person] += a*residual; H += h*residual
            for j in range(9): balance[j] += D[y][j]-sum(q[k]*D[k][j] for k in range(4))
            entropy += sum((iv(p)*IV.ln(iv(p)) for p in q if p), IV.mpf(0))
        assert balance == [0]*9 and H == s*c*w['pairs']['H']
        assert scores == [s*c*g+(slopes[2]*d if static else 0)
                          for g, d in zip(w['pairs']['Scores'], w['third_score'])]
        assert min(Q(0), ends(entropy+iv(sum(g*g for g in scores)/2+H*psi))[0]) <= bound


def check_static_normal(sample, g, conditional, static, moments, lower, upper, base, design):
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    probabilities = {}
    for r, c in product((1, 2, 3), range(3)):
        ys = [y[3*roster.index(r)+c] for roster, y in sample if r in roster]
        probabilities[r, c] = [Q(ys.count(k), len(ys)) for k in range(4)]
    for flags in ((True, False, True), (False, True, True), (True, True, False)):
        E = sum(static[c] if flags[c] else Q(g['Owners'][c]['ConditionalLogLikelihoodUpper']) for c in range(3))
        for slopes in (lower, upper, [(a+b)/2 for a, b in zip(lower, upper)]):
            scores = [Q(0)]*len(sample); balance = [Q(0)]*9; H = Q(0); entropy = IV.mpf(0)
            for i, (person, y, a, h, D) in enumerate(design(sample, slopes)):
                c = i % 3; r = sample[person][0][(i % 6)//3]
                q = probabilities[r, c] if flags[c] else conditional['q'][i]
                assert min(q) >= 0 and sum(q) == 1
                residual = y-sum(k*q[k] for k in range(4)); scores[person] += a*residual; H += h*residual
                for j in range(9): balance[j] += D[y][j]-sum(q[k]*D[k][j] for k in range(4))
                entropy += sum((iv(p)*IV.ln(iv(p)) for p in q if p), IV.mpf(0))
            assert balance == [0]*9 and H == 0 and ends(entropy)[0] <= E
            assert scores == [sum(slopes[c]*moments['Scores'][c][p] for c in range(3) if flags[c])
                              for p in range(len(sample))]
            a = [slopes[c] if flags[c] else Q(0) for c in range(3)]
            assert sum(x*x for x in scores) == sum(a[j]*a[k]*moments['CrossProducts'][j][k]
                                                 for j in range(3) for k in range(3))


def marginal_region_upper(sample, profiles, lower, upper, psi, base):
    """Temperature inequality and Jensen transfer a certified marginal ray."""
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    bound = Q(0)
    for profile in profiles:
        reference = list(map(Q, profile['ReferenceSlopes']))
        t = min(Q(1), *(a/b for a, b in zip(lower, reference)))
        assert t > 0 and math.prod(reference) == 1
        penalty = sum(2*len(sample)*max(Q(0), a/b-1) for a, b in zip(upper, reference))
        U = Q(profile['AffineUpperIntercept'])+Q(profile['AffineUpperSlope'])*psi
        value = iv(t*U)+iv(penalty)*IV.ln(4)
        bound = min(bound, ends(value)[1])
        r = max(a/b for a, b in zip(upper, reference))
        if 1 < r <= 2:
            # Product-one slope ratios allow at most two owners above one.
            # The existing scalar maximum bounds each category probability;
            # Jensen then transfers the whole normal marginal likelihood.
            assert all(len(roster) == 2 for roster, y in sample)
            constant, unused = SHARP_CONSTANT(r, t, base)
            value = iv(t*U)+iv(4*len(sample))*IV.ln(iv(constant))
            bound = min(bound, ends(value)[1])
            constants = [constant if a/b == r else SHARP_CONSTANT(a/b, t, base)[0]
                         if a/b > 1 else Q(1) for a, b in zip(upper, reference)]
            first, second = sorted(constants, reverse=True)[:2]
            value = iv(t*U)+iv(2*len(sample))*(IV.ln(iv(first))+IV.ln(iv(second)))
            bound = min(bound, ends(value)[1])
    return bound


def in_sharp_profile_region(box, profiles):
    """Only these boxes can change under the added temperature inequality."""
    lower, upper = bounds(list(map(Q, box)))
    return any(1 < max(a/Q(b) for a, b in zip(upper, row['ReferenceSlopes'])) <= 2
               for row in profiles)


def bounds(box):
    lo, hi = list(box[:2]), list(box[2:])
    return lo+[1/(hi[0]*hi[1])], hi+[1/(lo[0]*lo[1])]


def split(box):
    lo, hi = bounds(box)
    axis = max(range(2), key=lambda j: math.log(float(hi[j]/lo[j])))
    pivot = Q(math.sqrt(float(lo[axis]*hi[axis])))
    assert lo[axis] < pivot < hi[axis]
    left, right = list(box), list(box)
    left[axis+2] = right[axis] = pivot
    return left, right


def check_transfer(sample, w, lower, upper, psi, c, base, design):
    """Independent raw balance and entropy checks at vertices and midpoints."""
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    bound = transfer_upper(w, lower, upper, psi, c, base)
    checked = 0
    for slopes in product(*[(lo, (lo+hi)/2, hi) for lo, hi in zip(lower, upper)]):
        rows = design(sample, slopes); balance = [Q(0)]*9
        g = [Q(0)]*len(sample); H = Q(0); entropy = IV.mpf(0)
        for i, (person, y, a, h, D) in enumerate(rows):
            ratio = c*w['a'][i % 3]/a
            q = [Q(k == y) + ratio*(z-Q(k == y)) for k, z in enumerate(w['q'][i])]
            assert min(q) >= 0 and sum(q) == 1
            for j in range(9):
                balance[j] += D[y][j] - sum(q[k]*D[k][j] for k in range(4))
            residual = y-sum(k*q[k] for k in range(4))
            g[person] += a*residual; H += h*residual
            entropy += sum((iv(z)*IV.ln(iv(z)) for z in q if z), IV.mpf(0))
        assert balance == [0]*9 and g == [c*z for z in w['g']] and H == c*w['H']
        value = entropy+iv(sum(z*z for z in g)/2+H*psi)
        assert min(Q(0), ends(value)[0]) <= bound
        checked += 1
    return checked


def check_allocated(samples, globals_, exponents, directory, base, psi, design):
    """Recount allocation witnesses; compare with retained feasible likelihoods."""
    from collections import Counter
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    box = [Q(2)**18, Q(2)**48, Q(2)**19, Q(2)**49]
    lower, upper = bounds(box); values = []; endpoint_values = []; static_selected = 0
    for sample, g in zip(samples, globals_, strict=True):
        static = static_entropies(sample, base)
        for owner, value in enumerate(static):
            cells = Counter((r, y[owner+3*t]) for roster, y in sample
                            for t, r in enumerate(roster))
            totals = Counter(r for roster, y in sample for r in roster)
            raw = sum((n*IV.ln(iv(Q(n, totals[r]))) for (r, k), n in cells.items()), IV.mpf(0))
            assert ends(raw)[0] <= value <= 0
        allocations = pair_allocations(sample)
        for group in allocations:
            for counts, assignment in zip(group['counts'], group['choices'], strict=True):
                raw = Counter((c, int(sample[i][1][c] < sample[i][1][c+3]))
                              for i, c in zip(group['indices'], assignment, strict=True) if c >= 0)
                assert counts == tuple(raw[c, sign] for c in range(3) for sign in (0, 1))
        approximate, choice = allocated_choice(g, static, allocations, lower, upper)
        value = allocated_upper(sample, g, static, lower, upper, choice, base)
        assert abs(float(value)-approximate) < 1e-8
        assert choice is not None
        static_selected += any(choice['StaticOwners'])
        values.append(value)
        pairs = endpoint_pairs(sample, 1 if psi > 0 else -1)
        endpoint_value, endpoint_choice = endpoint_upper(sample, g, static, pairs, lower, upper, psi, base)
        assert endpoint_choice is not None
        for slopes in (lower, upper, [(a+b)/2 for a, b in zip(lower, upper)]):
            check_endpoint(sample, pairs, slopes, Q(endpoint_choice['Scalar']), base, design)
        endpoint_values.append(endpoint_value)
    p = sum(IV.exp(iv(v)+e*IV.ln(2)) for v, e in zip(values, exponents, strict=True))/50
    assert ends(p)[1] <= Q(1, 20) and static_selected > 0
    for name in ('rational-remainder/general-replicate-01-psi--10.json', 'fixed-unit-replicate-01-psi-3.json'):
        record = json.loads((directory/'profiles'/name).read_text())
        verify(record['Sources'] | record['Input'] | record['MomentArtifact'])
        slopes = list(map(Q, record['Slopes'])); index = record['Replicate']-1
        sample, g = samples[index], globals_[index]
        static = static_entropies(sample, base)
        unused, choice = allocated_choice(g, static, pair_allocations(sample), slopes, slopes)
        assert Q(record['LogLikelihoodLower']) <= allocated_upper(
            sample, g, static, slopes, slopes, choice, base)
        contrast = Q(record['Contrast']); pairs = endpoint_pairs(sample, 1 if contrast > 0 else -1)
        assert Q(record['LogLikelihoodLower']) <= endpoint_upper(
            sample, g, static, pairs, slopes, slopes, contrast, base)[0]
        mixed = mixture_witness(sample, g, pairs, base)
        unused, mixed_choice = mixture_float(mixed, slopes, slopes, contrast)
        E, normal = mixture_terms(mixed, slopes, slopes, contrast, mixed_choice, base)
        bound, unused = powered_mixture(sample, slopes, E, normal, pair_allocations(sample), base)
        assert Q(record['LogLikelihoodLower']) <= bound
        bound, unused = static_normal_upper(sample, g, static, static_normal_scores(sample), slopes, slopes,
                                            pair_allocations(sample), base)
        assert Q(record['LogLikelihoodLower']) <= bound
    print('Allocation witnesses and static entropy checked; retained feasible likelihoods enclosed;',
          'full-sum log upper in large/large/small box:', float(ends(IV.ln(p))[1]), flush=True)
    endpoint_p = sum(IV.exp(iv(v)+e*IV.ln(2)) for v, e in zip(endpoint_values, exponents, strict=True))/50
    assert ends(endpoint_p)[1] <= Q(1, 20)
    print('Endpoint raw nuisance balance and Person score checks: 150;',
          'full-sum log upper:', float(ends(IV.ln(endpoint_p))[1]), flush=True)


def ray_members(points, observed, psi):
    """Union of inclusive statistic tails on [psi, infinity) or its left ray."""
    own = points[observed]
    assert own is not None, 'Observed completed failure has the whole line'
    members = []
    for j, value in enumerate(points):
        if value is None:
            included = own >= psi if psi > 0 else own <= psi
        else:
            included = (abs(value-psi) >= abs(own-psi) or
                        (value < own if psi > 0 else value > own))
        if included: members.append(j)
    assert observed in members
    return members


def point_records(root, arm):
    path = root/'accuracy-review/contrasts.csv'
    rows = sorted((r for r in csv.DictReader(path.open())
                   if r['Arm'] == arm and r['Target'] == 'contrast:Criterion:1-2'),
                  key=lambda r: int(r['Replicate']))
    assert [int(r['Replicate']) for r in rows] == list(range(1, 51))
    assert all(r['Output'] == 'point' and r['Analysis'] == 'initial_finite_return' for r in rows)
    points = [Q(r['Estimate']) if r['Available'] == 'TRUE' and r['Estimate'] != 'NA'
              else None for r in rows]
    # These completed-failure identities are already admitted by the original audit.
    audit_path = root/'normal-mc-calibration/failure-rule.json'
    audit = json.loads(audit_path.read_text())
    verify(audit['Sources']); assert all(r['ObservedFailed'] == (points[r['Replicate']-1] is None)
                                       for r in audit['Results'] if r['Arm'] == arm)
    return points, [path, audit_path]


def check_partition(state):
    """Exact rectangle sweep verifies all leaves cover the original root once."""
    A = list(map(Q, state['Identity']['CommonUpperSlopes']))
    root = [1/(A[1]*A[2]), 1/(A[0]*A[2]), A[0], A[1]]
    leaves = state['Pending']+[z['Box'] for k in ('Excluded', 'Unresolved') for z in state[k]]
    events = {}
    for i, encoded in enumerate(leaves):
        x0, y0, x1, y1 = map(Q, encoded)
        assert root[0] <= x0 < x1 <= root[2] and root[1] <= y0 < y1 <= root[3]
        events.setdefault(x0, []).append((i, (y0, y1)))
        events.setdefault(x1, []).append((i, None))
    active = {}
    assert min(events) == root[0] and max(events) == root[2]
    for x, changes in sorted(events.items()):
        for i, interval in changes:
            if interval is None: del active[i]
            else: active[i] = interval
        if x == root[2]:
            assert not active
        else:
            vertical = sorted(active.values())
            assert vertical[0][0] == root[1] and vertical[-1][1] == root[3]
            assert all(a[1] == b[0] for a, b in zip(vertical, vertical[1:]))
    assert len(leaves) == state['SplitCount']+1


def check_ray_members(points, observed, psi):
    own = points[observed]; assert own is not None
    changes = sorted({psi, own} | {(v+own)/2 for v in points if v is not None})
    candidates = changes+[(a+b)/2 for a, b in zip(changes, changes[1:])]
    candidates += [changes[0]-1, changes[-1]+1]
    candidates = [p for p in candidates if (p >= psi if psi > 0 else p <= psi)]
    raw = set()
    for p in candidates:
        for i, v in enumerate(points):
            if (Q(0) if v is None else abs(v-p)) >= abs(own-p): raw.add(i)
    assert raw == set(ray_members(points, observed, psi))


def adaptive_dual(sample, replicate, psi, lower, upper, directory, inputs, base, dual):
    """Select an auxiliary witness; its exact feasibility, not fitting, proves the bound."""
    slopes = [Q(format(math.sqrt(float(a*b)), '.3g')) for a, b in zip(lower[:2], upper[:2])]
    slopes.append(1/math.prod(slopes))
    key = json.dumps([replicate, str(psi), list(map(str, slopes))])
    path = directory/f'{replicate:02d}-{hashlib.sha256(key.encode()).hexdigest()[:20]}.json'
    if path.exists():
        record = json.loads(path.read_text())
        verify(record['Sources']); assert record['Inputs'] == inputs
        assert record['Replicate'] == replicate and Q(record['Contrast']) == psi
        assert list(map(Q, record['Slopes'])) == slopes
    else:
        try:
            record = dual['certificate'](sample, psi, slopes, base)
        except AssertionError as error:
            if str(error) != 'Dual projection is not feasible; no upper bound': raise
            record = dict(Contrast=str(psi), Slopes=list(map(str, slopes)),
                          WitnessUnavailable='exact_projection_not_positive',
                          StatisticalFailure=False, ExclusionCertified=False)
        record.update(Replicate=replicate, Inputs=inputs,
                      Sources={str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in (BASE, DUAL)})
        directory.mkdir(parents=True, exist_ok=True)
        temporary = path.with_suffix('.tmp'); temporary.write_text(json.dumps(record, indent=2)+'\n')
        temporary.replace(path)
    return path, None if 'WitnessUnavailable' in record else witness(sample, record, dual['design'])


def run(root, psi, destination, steps, checks=False, arm=None, observed=None, reuse=None, proposal=None, sharp_profiles=(), adaptive_directory=None, pending_only=False, profile_only=False):
    base = runpy.run_path(str(BASE)); base['IV'].dps = 50
    dual = runpy.run_path(str(DUAL))
    forest = runpy.run_path(str(FOREST))
    forest_endpoint = runpy.run_path(str(FOREST_ENDPOINT))
    samples, unused, inputs = base['read_inputs'](root)
    directory = root/'normal-mc-calibration'
    tail_path = directory/'tail-bounds.json'
    tails = json.loads(tail_path.read_text()); verify(tails['Sources'])
    assert inputs == tails['Inputs']
    name = 'dual-unit' if psi > 0 else 'dual-small-small-large'
    summary_path = directory/'profiles'/name/'summary.json'
    summary = json.loads(summary_path.read_text())
    verify(summary['Provenance']['Sources'])
    assert inputs == summary['Provenance']['Inputs']
    checked_path = directory/'profiles/global-tail/checks.json'
    checked = json.loads(checked_path.read_text()); verify(checked['Sources'])
    assert checked['Inputs'] == inputs and checked['ChecksPassed']
    global_path = directory/'profiles/global-tail/summary.json'
    global_summary = json.loads(global_path.read_text())
    verify(global_summary['Provenance']['Sources']); verify(global_summary['Certificates'])
    assert inputs == global_summary['Provenance']['Inputs'] and global_summary['Complete']
    assert [z['Replicate'] for z in summary['Results']] == list(range(1, 51))
    ws, globals_, paths = [], [], [Path(__file__), BASE, DUAL, FOREST, FOREST_ENDPOINT, PROFILE_REGIONS,
                                 tail_path, summary_path, checked_path, global_path]
    for sample, item in zip(samples, summary['Results'], strict=True):
        path = Path(item['Path']); verify({str(path): item['SHA256']}); paths.append(path)
        w = witness(sample, json.loads(path.read_text()), dual['design'])
        assert w['H']*psi < 0
        ws.append(w)
        path = directory/'profiles/global-tail'/f"replicate-{item['Replicate']:02d}.json"
        globals_.append(empirical_conditional(sample, json.loads(path.read_text()), base, dual['solve_exact'])); paths.append(path)
    exponents = [z['ProposalProbabilityLowerPowerOfTwo'] for z in tails['Records']]
    inverse_logs = [e*base['IV'].ln(2) for e in exponents]
    if proposal is not None:
        probabilities = json.loads(proposal.read_text()); verify(probabilities['Sources'])
        assert probabilities['Inputs'] == inputs
        assert [r['Replicate'] for r in probabilities['Records']] == list(range(1, 51))
        for r, e in zip(probabilities['Records'], exponents, strict=True):
            assert Q(2)**(-e) <= Q(r['Lower']) <= Q(r['Upper']) <= 1
        inverse_logs = [base['iv'](-Q(r['LogLower'])) for r in probabilities['Records']]
        paths.append(proposal)
    sharp = {i: [] for i in range(1, 51)}
    for path in sharp_profiles:
        record = json.loads(path.read_text()); verify(record['Sources'])
        assert record['Inputs'] == inputs and record['ChecksPassed']
        for row in record['Results']:
            boundary = Q(row['ContrastBoundary']); slope = Q(row['AffineUpperSlope'])
            valid = (row['ContrastRay'] == 'left' and psi <= boundary and psi < 0 and slope > 0) or (
                row['ContrastRay'] == 'right' and psi >= boundary and psi > 0 and slope < 0)
            if valid:
                assert row['FixedSlopeGlobalProfileUpperVerified'] and row['AllLocationAndStepNuisanceCovered']
                sharp[row['Replicate']].append(row)
        paths.append(path)
    members = list(range(50)); points = None
    if arm is not None:
        points, point_paths = point_records(root, arm); paths.extend(point_paths)
        assert points[observed-1] is not None, 'Completed observed failure returns the whole line; no exclusion run'
        members = ray_members(points, observed-1, psi)
    if checks:
        total = 0
        for index in (0, 21):
            w = ws[index]
            lower = [a*Q(3, 4) for a in w['a']]
            upper = [a*Q(5, 4) for a in w['a']]
            value, c = transfer_float(w, lower, upper, psi)
            total += check_transfer(samples[index], w, lower, upper, psi, c, base, dual['design'])
        print('Exact balance, score scaling and entropy enclosure checks:', total, flush=True)
        check_allocated(samples, globals_, exponents, directory, base, psi, dual['design'])
        lower, upper = bounds([Q(1), Q(2)**30, Q(5, 4), Q(5, 4)*Q(2)**30])
        for index in (0, 5, 31):
            sample = samples[index]; pairs = endpoint_pairs(sample, 1 if psi > 0 else -1)
            mixed = mixture_witness(sample, globals_[index], pairs, base)
            value, choice = mixture_float(mixed, lower, upper, psi)
            check_mixture(sample, mixed, lower, upper, psi, choice, base, dual['design'])
            for static_third in (False, True):
                check_mixture(sample, mixed, lower, upper, psi,
                              dict(Scalar='3/2', Power='1/3', StaticThird=static_third), base, dual['design'])
            check_static_normal(sample, globals_[index], mixed, static_entropies(sample, base),
                                static_normal_scores(sample), lower, upper, base, dual['design'])
        print('Direct mixture entropy, raw nuisance balance and normal-score checks: 27', flush=True)
        print('Static owner combinations and signed normal Gram-matrix checks: 27', flush=True)
        if points is not None:
            check_ray_members(points, observed-1, psi)
            print('Inclusive ray statistic membership checked:', len(members), 'of 50 terms', flush=True)
        return
    allocations = [pair_allocations(sample) for sample in samples]
    static = [static_entropies(sample, base) for sample in samples]
    A = [Q(2)**max(z['SlopeCertificates'][c]['UpperSlopeExponentBase2'] for z in globals_)
         for c in range(3)]
    initial = [1/(A[1]*A[2]), 1/(A[0]*A[2]), A[0], A[1]]
    identity = dict(Sources={str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},
                    Inputs=inputs, Contrast=str(psi), CommonUpperSlopes=list(map(str, A)),
                    Arm=arm, Observed=observed, IncludedReplicates=[j+1 for j in members],
                    ProposalProbabilityEnclosures=None if proposal is None else str(proposal),
                    SharpProfileChecks=list(map(str, sharp_profiles)),
                    AdaptiveDualDirectory=None if adaptive_directory is None else str(adaptive_directory),
                    PreservePreviousUnresolved=bool(pending_only),
                    RevisitOnlySharpProfileRegions=bool(profile_only),
                    ProfileTemperatureTransfer='sharp-four-category-two-largest-owner-factors-v2',
                    Denominator=50, Statistic='Absolute saved initial point minus contrast; completed failure zero')
    previous = None
    if reuse is not None:
        previous = json.loads(reuse.read_text())
        old = previous['Identity']; assert old['Inputs'] == inputs and old['Contrast'] == str(psi)
        assert old.get('Arm') is None or (old['Arm'] == arm and old['Observed'] == observed)
        assert set(identity['IncludedReplicates']) <= set(old.get('IncludedReplicates', range(1, 51)))
        snapshot = reuse.parent/'source.py'
        hashes = dict(old['Sources']); original = hashes.pop(str(Path(__file__)))
        assert hashlib.sha256(snapshot.read_bytes()).hexdigest() == original
        # The endpoint selector's zero-move repair changes proposals only.
        # Its old checked exclusions keep their exact archived helper source.
        endpoint_name = str(FOREST_ENDPOINT)
        if endpoint_name in hashes and hashlib.sha256(FOREST_ENDPOINT.read_bytes()).hexdigest() != hashes[endpoint_name]:
            archived = reuse.parent/FOREST_ENDPOINT.name
            digest = hashes.pop(endpoint_name)
            verify({str(archived): digest})
            hashes[str(archived)] = digest
            identity['Sources'][str(archived)] = digest
        verify(hashes)
        verify(previous.get('AdaptiveCertificates', {}))
        check_partition(previous)
        for p in (reuse, snapshot): identity['Sources'][str(p)] = hashlib.sha256(p.read_bytes()).hexdigest()
    if destination.exists():
        state = json.loads(destination.read_text()); assert state['Identity'] == identity
        verify(state.get('AdaptiveCertificates', {}))
    else:
        state = dict(Identity=identity, Pending=[list(map(str, initial))], Excluded=[], Unresolved=[],
                     SplitCount=0, Complete=False, ExactCIEndpoint=False,
                     ObservedPointFailure='Whole-line override; these exclusions do not apply.',
                     Scope='Inclusive statistic-tail union on an exterior ray; pending boxes remain unresolved.')
        if previous is not None:
            state['Pending'] = list(previous['Pending'])
            if pending_only:
                state['Unresolved'] = list(previous['Unresolved'])
            elif profile_only:
                profiles = [row for j in members for row in sharp[j+1]]
                for row in previous['Unresolved']:
                    if in_sharp_profile_region(row['Box'], profiles): state['Pending'].append(row['Box'])
                    else: state['Unresolved'].append(row)
            else:
                state['Pending'] += [z['Box'] for z in previous['Unresolved']]
            state['Excluded'] = previous['Excluded']; state['SplitCount'] = previous['SplitCount']
            state['InheritedExclusions'] = len(previous['Excluded'])
            state['AdaptiveCertificates'] = dict(previous.get('AdaptiveCertificates', {}))
    samples, ws, globals_, inverse_logs, allocations, static = (
        [values[j] for j in members] for values in (samples, ws, globals_, inverse_logs, allocations, static))
    log_offsets = [float(base['ends'](z)[1]) for z in inverse_logs]
    active_profiles = [sharp[j+1] for j in members]
    replicate_ids = [j+1 for j in members]
    members = range(len(members))
    adaptive = [[] for unused in members]
    if adaptive_directory is not None and adaptive_directory.exists():
        for path in sorted(adaptive_directory.glob('*.json')):
            record = json.loads(path.read_text()); verify(record['Sources'])
            assert record['Inputs'] == inputs and Q(record['Contrast']) == psi
            if record['Replicate'] not in replicate_ids: continue
            if 'WitnessUnavailable' in record: continue
            j = replicate_ids.index(record['Replicate'])
            w = witness(samples[j], record, dual['design'])
            if w['H']*psi < 0: adaptive[j].append((path, w))
    pair_witnesses = [endpoint_pairs(sample, 1 if psi > 0 else -1) for sample in samples]
    mixtures = {}; forest_witnesses = {}
    static_moments = [static_normal_scores(sample) for sample in samples]
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    for unused in range(steps):
        if not state['Pending']: break
        encoded = state['Pending'].pop(); box = list(map(Q, encoded)); lower, upper = bounds(box)
        tail = [tail_upper(Q(g['ConditionalLogLikelihoodUpper']), g['SlopeCertificates'], lower, base)
                for g in globals_]
        profile_bounds = [marginal_region_upper(sample, profiles, lower, upper, psi, base)
                          for sample, profiles in zip(samples, active_profiles)]
        tail = [min(t, p) for t, p in zip(tail, profile_bounds)]
        endpoint = [endpoint_upper(sample, g, st, pairs, lower, upper, psi, base)
                    for sample, g, st, pairs in zip(samples, globals_, static, pair_witnesses)]
        approximate = [float(min(t, value))+offset
                       for t, (value, choice), offset in zip(tail, endpoint, log_offsets)]
        refinement_values = {}; adaptive_selections = [None]*len(samples)
        forest_selections = [None]*len(samples)
        forest_endpoint_transfers = [None]*len(samples)
        if logsumexp(approximate)-math.log(50) >= math.log(.05):
            for j in sorted(members, key=lambda j: approximate[j], reverse=True):
                if j not in mixtures:
                    mixtures[j] = mixture_witness(samples[j], globals_[j], pair_witnesses[j], base)
                if j not in forest_witnesses:
                    forest_witnesses[j] = forest['witness'](samples[j], mixtures[j]['q'], base)
                value, choice = forest['choose'](forest_witnesses[j], lower, upper)
                if choice is None: continue
                bound = forest['upper'](forest_witnesses[j], lower, upper, choice, base)
                transfers = []
                if bound < 0:
                    transfers = forest_endpoint['choose'](forest_witnesses[j], lower, upper, psi, choice, forest)
                    bound = forest_endpoint['upper'](forest_witnesses[j], lower, upper, psi,
                                                     choice, transfers, forest, base)
                if float(bound)+log_offsets[j] < approximate[j]:
                    approximate[j] = float(bound)+log_offsets[j]; refinement_values[j] = bound
                    forest_selections[j] = choice
                    forest_endpoint_transfers[j] = transfers
                if logsumexp(approximate)-math.log(50) < math.log(.05): break
        if adaptive_directory is not None and logsumexp(approximate)-math.log(50) >= math.log(.05):
            for j in sorted(members, key=lambda j: approximate[j], reverse=True):
                for path, w in adaptive[j]:
                    value, c = transfer_float(w, lower, upper, psi)
                    if value+log_offsets[j] >= approximate[j]: continue
                    bound = transfer_upper(w, lower, upper, psi, c, base)
                    if float(bound)+log_offsets[j] < approximate[j]:
                        approximate[j] = float(bound)+log_offsets[j]
                        refinement_values[j] = bound
                        adaptive_selections[j] = dict(Path=str(path), Scalar=str(c))
                        state.setdefault('AdaptiveCertificates', {})[str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
                if logsumexp(approximate)-math.log(50) < math.log(.05): break
        assigned = [(float(Q(g['ConditionalLogLikelihoodUpper'])), None) for g in globals_]
        if logsumexp(approximate)-math.log(50) >= math.log(.05):
            assigned = [allocated_choice(g, st, al, lower, upper)
                        for g, st, al in zip(globals_, static, allocations)]
            approximate = [min(v, value+offset) for v, (value, choice), offset
                           in zip(approximate, assigned, log_offsets)]
        candidates = None
        if logsumexp([approximate[j] for j in members])-math.log(50) >= math.log(.05):
            candidates = [transfer_float(w, lower, upper, psi) for w in ws]
            approximate = [min(v, val+offset) for v, (val, c), offset
                           in zip(approximate, candidates, log_offsets)]
        mixture_choices = [None]*len(samples)
        powered_choices = [None]*len(samples); static_choices = [None]*len(samples)
        if logsumexp(approximate)-math.log(50) >= math.log(.05):
            for j in sorted(members, key=lambda j: approximate[j], reverse=True):
                bound, choice = static_normal_upper(samples[j], globals_[j], static[j], static_moments[j],
                                                     lower, upper, allocations[j], base)
                if float(bound)+log_offsets[j] < approximate[j]:
                    approximate[j] = float(bound)+log_offsets[j]; refinement_values[j] = bound
                    static_choices[j] = choice
                if logsumexp(approximate)-math.log(50) < math.log(.05): break
                if j not in mixtures:
                    mixtures[j] = mixture_witness(samples[j], globals_[j], pair_witnesses[j], base)
                unused, choice = mixture_float(mixtures[j], lower, upper, psi)
                E, normal = mixture_terms(mixtures[j], lower, upper, psi, choice, base)
                bound, powered = powered_mixture(samples[j], lower, E, normal, allocations[j], base)
                value = float(bound)
                if value+log_offsets[j] < approximate[j]:
                    approximate[j] = value+log_offsets[j]; mixture_choices[j] = choice
                    refinement_values[j] = bound; powered_choices[j] = powered
                if logsumexp(approximate)-math.log(50) < math.log(.05): break
        excluded = None
        if adaptive_directory is not None and logsumexp(approximate)-math.log(50) >= math.log(.05):
            narrow = max(hi/lo for lo, hi in zip(lower, upper)) <= Q(3, 2)
            for j in sorted(members, key=lambda j: approximate[j], reverse=True):
                def candidates_here():
                    if narrow and approximate[j] >= math.log(.05*50/len(samples)):
                        path, w = adaptive_dual(samples[j], replicate_ids[j], psi, lower, upper,
                                                adaptive_directory, inputs, base, dual)
                        if w is not None and w['H']*psi < 0 and path not in [p for p, unused in adaptive[j]]:
                            adaptive[j].append((path, w)); yield path, w
                for path, w in candidates_here():
                    value, c = transfer_float(w, lower, upper, psi)
                    if value+log_offsets[j] >= approximate[j]: continue
                    bound = transfer_upper(w, lower, upper, psi, c, base)
                    if float(bound)+log_offsets[j] < approximate[j]:
                        approximate[j] = float(bound)+log_offsets[j]
                        refinement_values[j] = min(refinement_values.get(j, Q(0)), bound)
                        adaptive_selections[j] = dict(Path=str(path), Scalar=str(c))
                        state.setdefault('AdaptiveCertificates', {})[str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
                if logsumexp(approximate)-math.log(50) < math.log(.05): break
        if logsumexp([approximate[j] for j in members])-math.log(50) < math.log(.05):
            values = [min(t, endpoint_value, allocated_upper(sample, g, st, lower, upper, choice, base))
                      for t, (endpoint_value, unused), sample, g, st, (value, choice)
                      in zip(tail, endpoint, samples, globals_, static, assigned)]
            if candidates is not None:
                values = [min(v, transfer_upper(w, lower, upper, psi, c, base))
                          for v, w, (value, c) in zip(values, ws, candidates)]
            for j, value in refinement_values.items():
                values[j] = min(values[j], value)
            p = sum(IV.exp(iv(values[j])+inverse_logs[j]) for j in members)/50
            if ends(p)[1] <= Q(1, 20):
                excluded = dict(Box=encoded, PValueUpper=str(ends(p)[1]),
                                PairSelections=[choice for value, choice in assigned],
                                EndpointSelections=[choice for value, choice in endpoint],
                                MixtureSelections=mixture_choices,
                                PoweredMixtureSelections=powered_choices,
                                StaticNormalSelections=static_choices,
                                NormalForestSelections=forest_selections,
                                NormalForestEndpointTransfers=forest_endpoint_transfers,
                                AdaptiveDualSelections=adaptive_selections,
                                TransferScalars=None if candidates is None else [str(c) for value, c in candidates])
        if excluded is not None: state['Excluded'].append(excluded)
        elif max(hi/lo for lo, hi in zip(lower, upper)) <= Q(3, 2):
            # The stored witnesses cannot settle this box. Keep it explicitly
            # for a sharper marginal/dual bound, rather than splitting forever.
            state['Unresolved'].append(dict(Box=encoded, Reason='sharper_bound_required'))
        else:
            state['Pending'].extend([list(map(str, b)) for b in split(box)])
            state['SplitCount'] += 1
        state['Complete'] = not state['Pending'] and not state['Unresolved']
        destination.parent.mkdir(parents=True, exist_ok=True)
        temporary = destination.with_suffix('.tmp'); temporary.write_text(json.dumps(state, indent=2)+'\n')
        temporary.replace(destination)
        print('psi', psi, 'excluded', len(state['Excluded']), 'pending', len(state['Pending']),
              'unresolved', len(state['Unresolved']), 'splits', state['SplitCount'], flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root', type=Path); parser.add_argument('psi', type=Q)
    parser.add_argument('destination', type=Path)
    parser.add_argument('--steps', type=int, default=100)
    parser.add_argument('--check', action='store_true')
    parser.add_argument('--arm', choices=('GPCM-JML', 'GPCM-JML2', 'GPCM-JML4'))
    parser.add_argument('--observed', type=int)
    parser.add_argument('--reuse', type=Path, help='Retained all-term partition with a source.py snapshot')
    parser.add_argument('--pending-only', action='store_true',
                        help='Preserve prior unresolved decisions for a proposal-only repair; no bound refinement')
    parser.add_argument('--profile-only', action='store_true',
                        help='Revisit prior unresolved boxes only where the sharper profile transfer applies')
    parser.add_argument('--proposal', type=Path, help='Retained absolute proposal probability enclosures')
    parser.add_argument('--sharp-profile', type=Path, action='append', default=[], help='Verified marginal-profile ray checks')
    parser.add_argument('--adaptive-duals', type=Path, help='Persistent exact auxiliary dual witnesses for unresolved regions')
    args = parser.parse_args()
    assert args.psi != 0 and args.steps > 0
    assert not args.pending_only or args.reuse is not None
    assert not args.profile_only or (args.reuse is not None and not args.pending_only and args.sharp_profile)
    assert (args.arm is None) == (args.observed is None)
    assert args.observed is None or 1 <= args.observed <= 50
    run(args.root, args.psi, args.destination, args.steps, args.check, args.arm, args.observed, args.reuse,
        args.proposal, args.sharp_profile, args.adaptive_duals, args.pending_only, args.profile_only)
