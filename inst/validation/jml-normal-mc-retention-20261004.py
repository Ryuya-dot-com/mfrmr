"""Certify retained contrast intervals from existing normal-MC likelihoods.

At fixed slopes, normal marginal log likelihood is concave jointly in the
linear location/step parameters. Thus endpoint likelihoods give a geometric
lower bound along their parameter segment. This bounds each sample weight,
not the log of their sum. No new integration, fits, or response samples.
"""
from fractions import Fraction as Q
from pathlib import Path
import argparse
import hashlib
import json
import runpy

HELPER = Path('inst/validation/jml-normal-mc-slope-cover-20261004.py')


def tail_everywhere(points, observed, left, right):
    own = points[observed]; assert own is not None
    return [j for j, p in enumerate(points)
            if ((left == right == own) if p is None else
                abs(p-left) >= abs(own-left) and abs(p-right) >= abs(own-right))]


def certificate_value(weights, selected, start, end, left, right, base):
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    lo, hi = (left-start)/(end-start), (right-start)/(end-start)
    value = IV.mpf(0)
    for j in selected:
        first, second = weights[0][j], weights[1][j]
        # The geometric lower certificate for one weight is monotone in t.
        t = lo if second >= first else hi
        value += IV.exp(iv(1-t)*IV.ln(iv(first))+iv(t)*IV.ln(iv(second)))
    return ends(value/50)


def run(root, arm, observed, destination, precision):
    helper = runpy.run_path(str(HELPER)); base = runpy.run_path(str(helper['BASE']))
    base['IV'].dps = 50
    points, paths = helper['point_records'](root, arm); own = points[observed-1]
    assert own is not None, 'Completed observed failure is retained on the whole line'
    directory = root/'normal-mc-calibration'
    gate_path = directory/'projection-gate.json'; gate = json.loads(gate_path.read_text())
    helper['verify'](gate['Sources']); helper['verify'](gate['Inputs'])
    old_path = directory/'failure-rule.json'; old = json.loads(old_path.read_text())
    scenarios = [('criterion_minus_one', Q(-1)), ('proposal', Q(-1, 2)), ('criterion_zero', Q(0))]
    weights = {}; anchor_checks = []
    for name, contrast in scenarios:
        scale = next(r for r in gate['AbsoluteWeightScale'] if r['Scenario'] == name)
        rows = sorted((r for r in old['NormalizedWeightEnclosures'] if r['Scenario'] == name),
                      key=lambda r: r['Replicate'])
        assert [r['Replicate'] for r in rows] == list(range(1, 51))
        lo = [Q(r['Lower'])*Q(scale['WeightSumLower']) for r in rows]
        hi = [Q(r['Upper'])*Q(scale['WeightSumUpper']) for r in rows]
        if name == 'proposal':
            assert all(a <= 1 <= b for a, b in zip(lo, hi))
            lo = hi = [Q(1)]*50
        assert min(lo) > 0
        weights[contrast] = lo
        selected = tail_everywhere(points, observed-1, contrast, contrast)
        lower, upper = min(Q(1), sum(lo[j] for j in selected)/50), min(Q(1), sum(hi[j] for j in selected)/50)
        saved = next(r for r in gate['Results'] if r['Scenario'] == name and
                     r['Arm'] == arm and r['Replicate'] == observed)
        assert lower <= Q(saved['PValueUpper']) and upper >= Q(saved['PValueLower'])
        anchor_checks.append(dict(Contrast=str(contrast), Lower=str(lower), Upper=str(upper)))
    retained, unresolved, split_count = [], [], 0
    for (unused, start), (unused, end) in zip(scenarios, scenarios[1:]):
        changes = sorted({start, end} | {own} | {(p+own)/2 for p in points if p is not None})
        changes = [p for p in changes if start <= p <= end]
        pending = list(zip(changes, changes[1:]))
        endpoints = (weights[start], weights[end])
        while pending:
            left, right = pending.pop()
            selected = tail_everywhere(points, observed-1, left, right)
            lower = certificate_value(endpoints, selected, start, end, left, right, base)[0]
            if lower > Q(1, 20):
                retained.append(dict(Interval=[str(left), str(right)], PValueLower=str(min(Q(1), lower))))
                continue
            maximum = max(certificate_value(endpoints, selected, start, end, x, x, base)[1]
                          for x in (left, right))
            if maximum <= Q(1, 20) or right-left <= precision:
                unresolved.append(dict(Interval=[str(left), str(right)], Reason=(
                    'retained_anchor_bound_insufficient' if maximum <= Q(1, 20) else 'retention_boundary_precision')))
            else:
                middle = (left+right)/2
                pending.extend(((left, middle), (middle, right))); split_count += 1
        for point in changes:
            selected = tail_everywhere(points, observed-1, point, point)
            lower = certificate_value(endpoints, selected, start, end, point, point, base)[0]
            if lower > Q(1, 20):
                retained.append(dict(Interval=[str(point), str(point)], PValueLower=str(min(Q(1), lower))))
    components = []
    for left, right in sorted(tuple(map(Q, r['Interval'])) for r in retained):
        if components and left <= components[-1][1]: components[-1][1] = max(right, components[-1][1])
        else: components.append([left, right])
    # The positive-width leaves partition the declared two anchor intervals.
    leaves = sorted(tuple(map(Q, r['Interval'])) for r in retained+unresolved
                    if Q(r['Interval'][0]) < Q(r['Interval'][1]))
    assert leaves[0][0] == -1 and leaves[-1][1] == 0
    assert all(a[1] == b[0] for a, b in zip(leaves, leaves[1:]))
    paths += [Path(__file__), HELPER, helper['BASE'], gate_path, old_path]
    result = dict(Arm=arm, Observed=observed, Denominator=50,
                  RetainedComponents=[[str(p) for p in pair] for pair in components],
                  Certificates=retained, Unresolved=unresolved, AnchorChecks=anchor_checks,
                  RefinementPrecision=str(precision), SplitCount=split_count,
                  Inputs=gate['Inputs'], Sources={str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},
                  NewFits=0, NewIntegrals=0, NewDatasets=0, CompleteConfidenceSet=False,
                  Scope='Retained continuous nuisance witnesses within [-1,0] at unit slopes; unresolved pieces are not exclusions.')
    destination.parent.mkdir(parents=True, exist_ok=True)
    payload = json.dumps(result, indent=2)+'\n'
    assert not destination.exists() or destination.read_text() == payload
    destination.write_text(payload)
    print(json.dumps({k: result[k] for k in ('Arm', 'Observed', 'RetainedComponents', 'SplitCount')}, indent=2))
    print('Unresolved witness pieces:', len(unresolved))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root', type=Path); parser.add_argument('destination', type=Path)
    parser.add_argument('--arm', choices=('GPCM-JML', 'GPCM-JML2', 'GPCM-JML4'), required=True)
    parser.add_argument('--observed', type=int, required=True)
    parser.add_argument('--precision', type=Q, default=Q(1, 10**6))
    args = parser.parse_args(); assert 1 <= args.observed <= 50 and args.precision > 0
    run(args.root, args.arm, args.observed, args.destination, args.precision)
