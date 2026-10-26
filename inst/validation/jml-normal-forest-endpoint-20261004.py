"""Add contrast decay to a checked normal forest bound using its free rows.

Opposite endpoint-category transfers at the same Person and Rater cancel
the ability and all nine structural nuisance coefficients. Their remaining
contrast coefficient has the inward sign. Entropy is convex in reciprocal
slope, so checking its two endpoints bounds each entire slope interval.
"""
from fractions import Fraction as Q
from scipy.optimize import minimize_scalar


def probabilities(w, choice):
    flags = choice['StaticOwners']
    return [w['q'][int(flags[c])][i] for i, (_, _, c) in enumerate(w['cells'])]


def changed(row, removed, amount):
    out = list(row)
    out[removed] -= amount
    out[3-removed] += amount
    assert amount >= 0 and min(out) >= 0 and sum(out) == 1
    return out


def choose(w, lower, upper, psi, choice, forest):
    """Floating optimization proposes rational feasible transfers only."""
    if choice is None: return []
    assert psi != 0
    q = probabilities(w, choice)
    used = {i for row in choice['Pairs'] for i in row[:2]}
    removed = (0, 3) if psi < 0 else (3, 0)
    selected = []
    for i in range(0, len(q), 3):
        j = i+1
        if i in used or j in used: continue
        cap = 3*min(lower[0]*q[i][removed[0]], lower[1]*q[j][removed[1]])
        if not cap: continue
        old = forest['entropy_float']((q[i], q[j]))
        def value(t):
            scalar = cap*Q(float(t))
            entropy = sum(max(forest['entropy_float']([
                changed(q[index], category, scalar/(3*a))])
                for a in (lower[owner], upper[owner]))
                for owner, (index, category) in enumerate(zip((i, j), removed)))
            return entropy-old-float(abs(psi)*scalar)
        opt = minimize_scalar(value, bounds=(0., 1.), method='bounded')
        t = min((0., float(opt.x), 1.), key=value)
        # Summing row entropies in a different order can make value(0)
        # slightly negative. A zero move is not a transfer witness.
        if t > 0 and value(t) < 0: selected.append([i, j, str(cap*Q(t))])
    return selected


def upper(w, lower, upper, psi, choice, transfers, forest, base):
    """Verify rational feasibility and enclose the complete augmented bound."""
    original = forest['upper'](w, lower, upper, choice, base)
    if not transfers: return original
    # forest.upper clips a positive raw expression at zero. A correction to
    # that clipped value need not be valid; only its negative raw bound works.
    assert original < 0 and psi != 0
    assert all(0 < lo <= hi for lo, hi in zip(lower, upper, strict=True))
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    q = probabilities(w, choice)
    used = {i for row in choice['Pairs'] for i in row[:2]}
    removed = (0, 3) if psi < 0 else (3, 0)
    value = original
    def entropy(row):
        return sum((iv(z)*IV.ln(iv(z)) for z in row if z), IV.mpf(0))
    for i, j, scalar in transfers:
        assert type(i) is int and type(j) is int and 0 <= i < len(q) and 0 <= j < len(q)
        p, r, c = w['cells'][i]; pp, rr, cc = w['cells'][j]
        assert (p, r) == (pp, rr) and (c, cc) == (0, 1)
        assert i not in used and j not in used
        used.update((i, j))
        scalar = Q(scalar); assert scalar > 0
        assert scalar <= 3*min(lower[0]*q[i][removed[0]], lower[1]*q[j][removed[1]])
        for owner, (index, category) in enumerate(zip((i, j), removed)):
            before = ends(entropy(q[index]))[0]
            after = max(ends(entropy(changed(q[index], category, scalar/(3*a))))[1]
                        for a in (lower[owner], upper[owner]))
            value += after-before
        value -= abs(psi)*scalar
    return min(original, value)
