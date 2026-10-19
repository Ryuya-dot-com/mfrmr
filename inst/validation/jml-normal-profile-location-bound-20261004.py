"""Tighten the saved normal-MC contrast domain using centered facet geometry.

If a_i >= a_j >= a_k and their product is one, 1/a_i <= 1 and
1/a_j <= sqrt(a_i). Endpoint cells give |b_r+b_c| <= H+C/(3*a_c).
Exact cell combinations below eliminate raters and the third criterion.
No fitting, quadrature, or new simulation is performed.
"""
from fractions import Fraction as Q
from itertools import permutations
from pathlib import Path
import hashlib
import json
import math
import sys


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def combination(edges, i, j, k):
    target = [1, -1, 0]
    alpha, beta = target[i-1]-target[k-1], target[j-1]-target[k-1]
    if alpha*beta < 0:
        common = [r for r in (1, 2, 3) if (r, i) in edges and (r, j) in edges]
        assert common, 'No common endpoint rater for the selected contrast'
        cells = [(common[0], i, alpha), (common[0], j, beta)]
    else:
        sign = 1 if alpha > 0 else -1
        choices = sorted(set(permutations([i]*abs(alpha)+[j]*abs(beta))))
        valid = [cs for cs in choices if all((r, c) in edges for r, c in enumerate(cs, 1))]
        assert valid, 'Selected endpoint columns do not support the centered contrast'
        cells = [(r, c, sign) for r, c in enumerate(valid[0], 1)]
    # A raw-coordinate check independent of the symbolic construction:
    # only multiples of the two sum-to-zero constraints may remain.
    rater = [0]*3; criterion = [0]*3
    for r, c, weight in cells:
        assert (r, c) in edges
        rater[r-1] += weight; criterion[c-1] += weight
    assert len(set(rater)) == 1
    assert len({criterion[c]-target[c] for c in range(3)}) == 1
    assert sum(abs(w) for r, c, w in cells if c == i) == abs(alpha)
    assert sum(abs(w) for r, c, w in cells if c == j) == abs(beta)
    return cells, abs(alpha), abs(beta)


def run(root):
    folder = root/'normal-mc-calibration/profiles/global-tail'
    old_path = root/'normal-mc-calibration/tail-bounds.json'
    check_path = folder/'checks.json'
    old = json.loads(old_path.read_text()); checked = json.loads(check_path.read_text())
    assert checked['ChecksPassed'] and checked['AllJointEscapesCovered']
    for path, value in (checked['Sources'] | checked['Inputs']).items():
        assert digest(path) == value, path
    summary = json.loads((folder/'summary.json').read_text())
    for path, value in (summary['Certificates'] | summary['Provenance']['Sources']).items():
        assert digest(path) == value, path
    records = []; radius = Q(0)
    for old_record, slope_record in zip(old['Records'], checked['Records'], strict=True):
        rep = old_record['Replicate']; assert rep == slope_record['Replicate']
        raw_path = root/'conditional-reference'/f'input-{rep:02d}.json'
        raw = json.loads(raw_path.read_text())['data']
        edges = {(r, c) for r in (1, 2, 3) for c in (1, 2, 3)
                 if {0, 3} <= {v['Score'] for v in raw if v['Rater'] == r and v['Criterion'] == c}}
        assert edges == set(map(tuple, old_record['EndpointCells']))
        H, C = old_record['NormalTruncationH'], old_record['LogitBudgetUpper']
        bounds = list(map(int, slope_record['SlopesUpper'])); cases = []
        for i, j, k in permutations((1, 2, 3)):
            cells, alpha, beta = combination(edges, i, j, k)
            A = bounds[i-1]; s = math.isqrt(A)
            if s*s < A: s += 1
            assert (s-1)**2 < A <= s*s
            bound = (alpha+beta)*H + Q(C, 3)*(alpha+beta*s)
            cases.append({'SlopeOrderLargestFirst': [i, j, k],
                          'EndpointCombination': cells, 'SqrtSlopeUpper': s,
                          'ContrastAbsoluteUpper': str(bound)})
        maximum = max(Q(c['ContrastAbsoluteUpper']) for c in cases)
        assert maximum < Q(slope_record['CriterionContrastOuterRadius'])
        records.append({'Replicate': rep, 'Cases': cases,
                        'CriterionContrastOuterRadius': str(maximum),
                        'CriterionContrastOuterRadiusApproximate': float(maximum)})
        radius = max(radius, maximum)
    result = {'ChecksPassed': True, 'Datasets': len(records),
              'ExactEndpointCombinationsChecked': sum(len(r['Cases']) for r in records),
              'Records': records, 'CommonCriterionContrastOuterRadius': str(radius),
              'CommonCriterionContrastOuterRadiusApproximate': float(radius),
              'PreviousCommonCriterionContrastOuterRadiusApproximate': checked['CommonCriterionContrastOuterRadiusApproximate'],
              'PValueUpperOutsideContrastRadius': '1/32',
              'ObservedFailureWholeLineOverride': True,
              'UsefulIntervalEndpointsProduced': False, 'CertifiedCIEndpoints': 0,
              'IndependentCoverageDatasets': 0,
              'Sources': {str(p): digest(p) for p in (Path(__file__), old_path, check_path)},
              'Inputs': checked['Inputs']}
    output = folder/'location-checks.json'; text = json.dumps(result, indent=2)+'\n'
    if output.exists(): assert output.read_text() == text
    else: output.write_text(text)
    print(json.dumps({k: v for k, v in result.items() if k not in ('Records', 'Sources', 'Inputs')}, indent=2))


if __name__ == '__main__':
    run(Path(sys.argv[1]))
