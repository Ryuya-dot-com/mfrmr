"""Exact design arithmetic for the GPCM owner-location identification decision.

Checks the existing 50 inputs and finite score supports; no fits, new samples,
matrix-rank tolerances or numerically solved mixing distributions. The analytic
common-population argument is in jml-inference-review-20260927.md.
"""
from collections import Counter, defaultdict
from fractions import Fraction as Q
from itertools import product
from pathlib import Path
import hashlib
import json
import math
import sys


def support(raters, q):
    # Each Criterion has `raters` ratings, with scores 0,...,3.
    multiplicity = Counter(map(sum, product(range(4), repeat=raters)))
    states = list(product(range(3 * raters + 1), repeat=3))
    powers = (q * (q + 1), (q + 1)**2, q**2)
    totals = sorted(sum(a * s for a, s in zip(powers, state)) for state in states)
    assert q > 3 * raters and len(set(totals)) == len(states)
    assert sum(math.prod(multiplicity[s] for s in state) for state in states) == 4**(3 * raters)
    # Independently enumerate raw patterns for the actual six-rating roster.
    if raters == 2:
        raw = Counter(tuple(sum(y[j:j + 2]) for j in (0, 2, 4))
                      for y in product(range(4), repeat=6))
        assert raw == {s: math.prod(multiplicity[v] for v in s) for s in states}
    return {'RatingsPerPerson': 3 * raters, 'ResponsePatterns': 4**(3 * raters),
            'OwnerTotalStates': len(states), 'DistinctWeightedTotals': len(totals),
            'UnitSlopeDistinctTotals': len({sum(s) for s in states}),
            'MinimumWeightedTotalGap': str(Q(min(b - a for a, b in zip(totals, totals[1:])), q * (q + 1)))}


def run(directory):
    paths = [directory / f'input-{i:02d}.json' for i in range(1, 51)]
    designs = []
    for path in paths:
        x = json.loads(path.read_text())
        assert x['N'] == 30 and x['K'] == 3 and x['step_facet'] == 'Criterion'
        persons = defaultdict(list)
        for row in x['data']:
            assert type(row['Score']) is int and 0 <= row['Score'] <= 3
            persons[row['Person']].append((row['Rater'], row['Criterion']))
        assert len(persons) == 30 and len(x['data']) == 180
        rosters = Counter()
        for cells in persons.values():
            raters = tuple(sorted({r for r, c in cells}))
            assert len(raters) == 2 and set(raters) <= {1, 2, 3}
            assert len(cells) == 6 and set(cells) == set(product(raters, (1, 2, 3)))
            rosters[raters] += 1
        assert rosters == {(1, 2): 10, (1, 3): 10, (2, 3): 10}
        designs.append({'Input': path.name, 'N': 30, 'Rows': 180,
                        'Rosters': {str(k): v for k, v in sorted(rosters.items())}})
    arithmetic = []
    for q in (10, 100, 10000):
        slopes = [Q(1), Q(q + 1, q), Q(q, q + 1)]
        assert math.prod(slopes) == 1
        assert max(abs(a - 1) for a in slopes) == Q(1, q)
        arithmetic.append({'q': q, 'Slopes': list(map(str, slopes)),
                           'MaximumDistanceFromUnitSlope': str(Q(1, q)),
                           'ObservedRoster': support(2, q),
                           'CompletePanel': support(3, q)})
    # At exactly equal slopes, a scalar-total stratum DOES retain owner information.
    left, right = (1, 0, 0), (0, 1, 0)
    assert sum(left) == sum(right) and left[0] - left[1] != right[0] - right[1]
    return {'Scope': 'Saved N30 Rater3 x Criterion3, scores 0:3, six ratings per Person; independent Persons and conditional ratings; fixed or exogenous rosters',
            'Designs': designs, 'ExactSupportChecks': arithmetic,
            'AnalyticDecision': {
                'AbilityEliminatingConditioning': 'At these slopes every deterministic conditional stratum independent of each free Person ability fixes each Criterion total and removes Criterion locations.',
                'CommonPopulationExtension': 'A complete nine-cell response-law equivalence implies equivalence for all three observed six-cell rosters under one common ability distribution.',
                'NormalBaseline': 'The analytic alternative can be a smooth positive compact density perturbation of N(0,1), preserving mean zero and variance one; it is not itself required to be normal.',
                'UniformShrinkingCriterionInterval': 'Impossible over this unrestricted ability-population class at fixed exposure; does not prohibit informative nonshrinking confidence sets.',
                'ExactlyUnitSlopes': 'Excluded from this injective-weighted-total argument; retain the established PCM conditional route.',
                'ExactlyNormalFamily': 'Not disproved by this construction; a separate population assumption and calibration argument are required.',
                'PracticalAmbiguityWidth': 'Not computed. This is a local existence result, not a numerical bound on N30 interval width or an explanation of its extreme-slope failures.'},
            'NewFits': 0, 'NewDatasets': 0, 'NumericallySolvedEquivalentPopulations': 0,
            'InputSHA256': {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},
            'SourceSHA256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}


if __name__ == '__main__':
    directory = Path(sys.argv[1])
    result = run(directory)
    output = directory / 'owner-identification.json'
    payload = json.dumps(result, indent=2) + '\n'
    if output.exists():
        assert output.read_text() == payload, 'Existing evidence differs; preserve it'
    else:
        output.write_text(payload)
    print(json.dumps({'InputsChecked': len(result['Designs']),
                      'ExactSupportChecks': result['ExactSupportChecks'],
                      'NewFits': 0, 'NewDatasets': 0}, indent=2))
