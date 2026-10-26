"""Research rank calibration of saved JML algorithms under the declared null law.

The leave-one-out R50 calculation checks ranks/failure accounting at ONE fully
specified truth. It is not an independent coverage experiment, a nuisance-
maximized test, a confidence interval, or a new bootstrap simulation.
"""
from fractions import Fraction as Q
from itertools import product
from pathlib import Path
import csv
import hashlib
import json
import math
import sys


def tail_bounds(observed, inner, observed_failed=False):
    """Inclusive upper-tail MC rank; None denotes an unresolved inner run.

    A completed algorithm failure has statistic +Inf, not None. If the observed
    algorithm fails, the prespecified rule retains the candidate (p=1).
    Unresolved inner ranks stay in the original B+1 denominator.
    """
    if observed_failed:
        return Q(1), Q(1)
    assert observed is not None and observed >= 0
    known = sum(x is not None and x >= observed for x in inner)
    unknown = sum(x is None for x in inner)
    return Q(1 + known, len(inner) + 1), Q(1 + known + unknown, len(inner) + 1)


def checks():
    # Conditional on any multiset, inclusive ranks are superuniform, with ties.
    # +Inf is a known failed-statistic outcome; retaining observed failures
    # must only increase p. These are exhaustive checks, not sampled fixtures.
    multisets = 0
    for values in product((Q(0), Q(1), Q(2), math.inf), repeat=5):
        p = [tail_bounds(x, values[:i] + values[i + 1:], x == math.inf)[1]
             for i, x in enumerate(values)]
        for k in range(6):
            assert sum(v <= Q(k, 5) for v in p) <= k
        multisets += 1
    observed = Q(2)
    incomplete = [Q(0), None, Q(2), None, math.inf]
    lower, upper = tail_bounds(observed, incomplete)
    for a, b in product((Q(0), Q(2), Q(3), math.inf), repeat=2):
        exact = tail_bounds(observed, [Q(0), a, Q(2), b, math.inf])[0]
        assert lower <= exact <= upper
    assert tail_bounds(Q(99), [None] * 49) == (Q(1, 50), Q(1))
    assert tail_bounds(Q(99), [math.inf] * 2 + [Q(0)] * 47)[1] == Q(3, 50)
    assert tail_bounds(math.inf, [Q(0)] * 49, True) == (1, 1)
    return {'ExchangeableVectorsChecked': multisets, 'UnknownCompletionsChecked': 16,
            'TiesFailuresAndFixedDenominatorPassed': True}


def run(directory):
    source = directory / 'accuracy-review/contrasts.csv'
    rows = list(csv.DictReader(source.open()))
    selected = [r for r in rows if 'JML' in r['Arm'] and r['Target'] == 'contrast:Criterion:1-2']
    assert len(selected) == 200
    assert {r['ConditionId'] for r in selected} == {'AB:paired-L1:N30:SD1:S-PCM'}
    assert all(Q(r['Truth']) == Q(-1, 2) for r in selected)
    outputs, summaries = [], []
    for arm in ('PCM-JML', 'GPCM-JML', 'GPCM-JML2', 'GPCM-JML4'):
        group = sorted((r for r in selected if r['Arm'] == arm), key=lambda r: int(r['Replicate']))
        assert [int(r['Replicate']) for r in group] == list(range(1, 51))
        # Algorithm-point rule needs no covariance or stationary-root theorem.
        # Root-screened rule is retained to expose the cost of importing a Wald gate.
        for policy in ('initial_finite_point', 'research_interval_screen'):
            usable = [r['Available'] == 'TRUE' and r['Estimate'] != 'NA' and
                      (policy == 'initial_finite_point' or r['ResearchIntervalAvailable'] == 'TRUE') for r in group]
            values = [abs(Q(r['Estimate']) - Q(r['Truth'])) if ok else math.inf
                      for r, ok in zip(group, usable)]
            records = []
            for i, (r, ok, value) in enumerate(zip(group, usable, values)):
                inner = values[:i] + values[i + 1:]
                lo, hi = tail_bounds(value, inner, not ok)
                assert lo == hi
                records.append({'Arm': arm, 'Policy': policy, 'Replicate': i + 1,
                    'PointAvailableForStatistic': ok, 'ObservedFailed': not ok,
                    'InitialEstimate': r['Estimate'], 'InitialNumericalPass': r['NumericalPass'],
                    'Statistic': str(value), 'B': 49,
                    'InnerFailed': sum(x == math.inf for x in inner),
                    'PValue': str(hi), 'PValueDecimal': float(hi),
                    'RejectFullySpecifiedTruth': hi <= Q(1, 20),
                    'CriterionCIQualified': False})
            outputs += records
            failed = 50 - sum(usable)
            summaries.append({'Arm': arm, 'Policy': policy, 'SavedDatasets': 50,
                'FiniteStatistics': sum(usable), 'FailedStatistics': failed,
                'MinimumPossiblePForFiniteObserved': str(Q(1 + failed, 50)),
                'RejectedReplicates': [r['Replicate'] for r in records if r['RejectFullySpecifiedTruth']],
                'RetainedFullySpecifiedTruth': sum(not r['RejectFullySpecifiedTruth'] for r in records),
                'Interpretation': 'Dependent leave-one-out rank accounting at one known truth; not measured CI coverage or a nuisance projection.'})
    result = {'Method': 'Inclusive Monte Carlo upper-tail rank of absolute JML Criterion error; retain observed failures; inner failures are +Inf',
        'Population': 'N(0,1), independent Persons and conditional ratings; exogenous randomized balanced three-roster assignment as in the frozen generator',
        'Target': 'Criterion 1 - 2', 'FullNullTruth': '-1/2; all other structural parameters fixed at their generating values for this audit only',
        'Summary': summaries, 'Checks': checks(),
        'NuisanceProjection': 'Not performed. The maximum of evaluated p-values is only a lower bound on the null supremum; it cannot justify rejection.',
        'ConfidenceIntervalsProduced': 0, 'NewFits': 0, 'NewDatasets': 0,
        'Sources': {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in (Path(__file__), source)}}
    out = directory / 'normal-mc-calibration'
    out.mkdir(exist_ok=True)
    path = out / 'rank-audit.json'
    payload = json.dumps(result, indent=2, allow_nan=False) + '\n'
    if path.exists():
        assert path.read_text() == payload, 'Existing evidence differs; preserve it'
    else:
        path.write_text(payload)
    with (out / 'rank-audit.csv').open('w', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=list(outputs[0]))
        writer.writeheader(); writer.writerows(outputs)
    print(json.dumps({'Summary': summaries, 'Checks': result['Checks']}, indent=2))


if __name__ == '__main__':
    run(Path(sys.argv[1]))
