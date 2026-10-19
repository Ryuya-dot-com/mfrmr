"""Normal marginal upper bound from exact probability transfers on a forest.

Disjoint response rows can share Persons. Their Person-difference covariance
is the incidence Gram matrix, not a product of independent pair variances.
For a forest its determinant is the product of component vertex counts.
Floating calculations choose witnesses only; upper() checks rational
feasibility and uses outward interval arithmetic for every exclusion value.
"""
from fractions import Fraction as Q
from itertools import combinations, product
import math


def entropy_float(rows):
    return sum(z*math.log(z) for row in rows for p in row if (z := float(p)) > 0)


def shifted(first, second, k, l, amount):
    a, b = list(first), list(second)
    a[k] -= amount; a[l] += amount; b[k] += amount; b[l] -= amount
    assert min(a+b) >= 0 and sum(a) == sum(b) == 1
    assert [a[t]+b[t] for t in range(4)] == [first[t]+second[t] for t in range(4)]
    return a, b


def witness(sample, conditional, base):
    cells = [(p, r, c) for p, (roster, y) in enumerate(sample) for r in roster for c in range(3)]
    observed = [y for roster, scores in sample for y in scores]
    static = []
    for unused, r, c in cells:
        scores = [y[3*roster.index(r)+c] for roster, y in sample if r in roster]
        static.append([Q(scores.count(k), len(scores)) for k in range(4)])
    qs = [conditional, static]; entropies = []; scores = []
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    for q in qs:
        assert len(q) == len(cells) and all(min(row) >= 0 and sum(row) == 1 for row in q)
        residual = [Q(y)-sum(k*p for k, p in enumerate(row)) for y, row in zip(observed, q)]
        for c in range(3):
            # Raw sufficient-statistic balances cover all structural nuisance
            # coordinates for every positive slope, with zero contrast term.
            for r in (1, 2, 3):
                assert sum(residual[i] for i, (_, rr, cc) in enumerate(cells) if (rr, cc) == (r, c)) == 0
            for k in range(4):
                assert sum(Q(observed[i] == k)-q[i][k] for i in range(c, len(q), 3)) == 0
        scores.append([[sum(residual[6*p+t+c] for t in (0, 3)) for p in range(len(sample))] for c in range(3)])
        entropies.append([ends(sum((iv(z)*IV.ln(iv(z)) for i in range(c, len(q), 3)
                                    for z in q[i] if z), IV.mpf(0)))[1] for c in range(3)])
    assert all(g == 0 for owner in scores[0] for g in owner)
    return dict(cells=cells, q=qs, entropy=entropies, scores=scores, banks={}, constants={})


def bank(w, owner, static):
    key = owner, static
    if key in w['banks']: return w['banks'][key]
    q = w['q'][int(static)]; out = []
    for i, j in combinations(range(owner, len(q), 3), 2):
        p, r, c = w['cells'][i]; pp, rr, cc = w['cells'][j]
        if p == pp or r != rr: continue
        baseline = entropy_float((q[i], q[j])); best = None
        for k, l in combinations(range(4), 2):
            plus, minus = min(q[i][k], q[j][l]), min(q[i][l], q[j][k])
            # This affects proposal selection only, never bound validity.
            if min(float(plus), float(minus)) < 1e-20: continue
            for fraction in (Q(1), Q(1, 2), Q(1, 4)):
                dp, dm = plus*fraction, minus*fraction
                pos = shifted(q[i], q[j], k, l, dp)
                neg = shifted(q[i], q[j], k, l, -dm)
                constant = (float(dm/(dp+dm))*entropy_float(pos) +
                            float(dp/(dp+dm))*entropy_float(neg) +
                            math.log(float((1/dp+1/dm)/(l-k))) - math.log(2*math.pi)/2)
                item = (constant-baseline, i, j, k, l, dp, dm)
                if best is None or item[0] < best[0]: best = item
        if best is not None: out.append(best)
    w['banks'][key] = out
    return out


def normal_upper(w, flags, lower, upper):
    return max(sum(sum(a[c]*w['scores'][int(flags[c])][c][p] for c in range(3))**2
                   for p in range(len(w['cells'])//6))/2
               for a in product(*zip(lower, upper)))


def choose(w, lower, upper):
    best = 0.; chosen = None; n = len(w['cells'])//6
    for flags in product((False, True), repeat=3):
        baseline = float(sum(w['entropy'][int(flags[c])][c] for c in range(3)))
        normal = float(normal_upper(w, flags, lower, upper))
        candidates = []
        for c in range(3):
            for entry in bank(w, c, flags[c]):
                gain = entry[0]-math.log(float(lower[c]))-math.log(2)/2
                if gain < 0: candidates.append((gain, entry))
        parent = list(range(n)); sizes = [1]*n; used = set(); pairs = []; total = 0.
        def find(p):
            while parent[p] != p: p = parent[p]
            return p
        for gain, item in sorted(candidates):
            unused, i, j, k, l, dp, dm = item
            if i in used or j in used: continue
            a, b = find(w['cells'][i][0]), find(w['cells'][j][0])
            if a == b: continue
            parent[b] = a; sizes[a] += sizes[b]; used.update((i, j))
            total += gain; pairs.append([i, j, k, l, str(dp), str(dm)])
        determinant = math.prod(sizes[i] for i in range(n) if parent[i] == i)
        value = baseline+normal+total+(len(pairs)*math.log(2)-math.log(determinant))/2
        if value < best:
            best = value; chosen = dict(StaticOwners=list(flags), Pairs=pairs,
                                        IncidenceDeterminant=determinant)
    return best, chosen


def upper(w, lower, upper, choice, base):
    if choice is None: return Q(0)
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    flags = choice['StaticOwners']; assert len(flags) == 3 and all(type(f) is bool for f in flags)
    value = iv(sum(w['entropy'][int(flags[c])][c] for c in range(3))+
               normal_upper(w, flags, lower, upper))
    n = len(w['cells'])//6; parent = list(range(n)); size = [1]*n; used = set()
    def find(p):
        while parent[p] != p: p = parent[p]
        return p
    for i, j, k, l, dp, dm in choice['Pairs']:
        dp, dm = Q(dp), Q(dm); assert dp > 0 and dm > 0 and 0 <= k < l < 4
        p, r, c = w['cells'][i]; pp, rr, cc = w['cells'][j]
        assert p != pp and (r, c) == (rr, cc) and i not in used and j not in used
        a, b = find(p), find(pp); assert a != b, 'Dependent cycle cannot use a full-dimensional normal density'
        parent[b] = a; size[a] += size[b]; used.update((i, j))
        key = int(flags[c]), i, j, k, l, dp, dm
        if key not in w['constants']:
            q = w['q'][int(flags[c])]; pos = shifted(q[i], q[j], k, l, dp); neg = shifted(q[i], q[j], k, l, -dm)
            def entropy(rows):
                return sum((iv(z)*IV.ln(iv(z)) for row in rows for z in row if z), IV.mpf(0))
            E0 = ends(entropy((q[i], q[j])))[0]
            Ep, Em = ends(entropy(pos))[1], ends(entropy(neg))[1]
            constant = iv((dm*Ep+dp*Em)/(dp+dm))+IV.ln(iv((1/dp+1/dm)/(l-k)))-IV.ln(2*IV.pi)/2
            w['constants'][key] = ends(constant)[1]-E0
        value += iv(w['constants'][key])-IV.ln(iv(lower[c]))
    determinant = math.prod(size[i] for i in range(n) if parent[i] == i)
    assert determinant == choice['IncidenceDeterminant']
    value -= IV.ln(iv(determinant))/2
    return min(Q(0), ends(value)[1])
