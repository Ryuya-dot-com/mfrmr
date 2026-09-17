"""Outcome-free Series D target manifest; no response generation or fitting.

Use existing A/B/C/D allocations unchanged. Keep all 120 disjoint candidate
pairs, and mark four per reference stratum for the initial planned pilot.
Run from any directory. The assertions check this one concrete allocation.
"""
import csv
import hashlib
import json
from collections import Counter, defaultdict
from pathlib import Path


def build_targets():
    here = Path(__file__).resolve()
    source = here.parents[3] / 'research-notes/2026-09-17-random-effects-rating-design/design-incidence.csv'
    assignments = {design: defaultdict(set) for design in 'ABCD'}
    with source.open(newline='') as stream:
        for row in csv.DictReader(stream):
            design, person, rater = row['Design'], int(row['Person']), int(row['Rater'])
            assert int(row['CriteriaPerBundle']) == 3
            assert rater not in assignments[design][person]
            assignments[design][person].add(rater)
    for design in assignments.values():
        assert set(design) == set(range(1, 241))
        assert sum(map(len, design.values())) == 480
    groups = {}
    for person, raters in assignments['C'].items():
        assert raters <= set(range(1, 7)) or raters <= set(range(7, 13))
        groups[person] = 'C1' if max(raters) <= 6 else 'C2'
    assert Counter(groups.values()) == {'C1': 120, 'C2': 120}
    order = lambda person: (hashlib.sha256(f'mfrmr-D-targets-v1:{person}'.encode()).hexdigest(), person)
    ordered = {group: sorted((p for p in groups if groups[p] == group), key=order) for group in ('C1', 'C2')}
    memberships = {
        'within_C1': list(zip(ordered['C1'][:80:2], ordered['C1'][1:80:2])),
        'within_C2': list(zip(ordered['C2'][:80:2], ordered['C2'][1:80:2])),
        'between_C1_C2': list(zip(ordered['C1'][80:], ordered['C2'][80:])),
    }
    people = [{'Person': p, 'CGroup': groups[p], 'BRaters': len(assignments['B'][p]),
               'DReassigned': assignments['C'][p] != assignments['D'][p]} for p in sorted(groups)]
    person_rows = {row['Person']: row for row in people}
    pairs = []
    for stratum, members in memberships.items():
        for rank, (p, q) in enumerate(members, 1):
            pairs.append({'Target': f'P{p}_minus_P{q}', 'Stratum': stratum, 'StratumRank': rank,
                          'PilotSelected': rank <= 4, 'P1': p, 'P2': q,
                          'BExposurePair': '_'.join(map(str, sorted((person_rows[p]['BRaters'], person_rows[q]['BRaters'])))),
                          'DAnyReassigned': person_rows[p]['DReassigned'] or person_rows[q]['DReassigned']})
    assert Counter(row['Stratum'] for row in pairs) == {s: 40 for s in memberships}
    assert Counter(p for row in pairs for p in (row['P1'], row['P2'])) == Counter(range(1, 241))
    assert len({row['Target'] for row in pairs}) == 120
    assert sum(row['PilotSelected'] for row in pairs) == 12
    assert all((groups[row['P1']] == groups[row['P2']]) == row['Stratum'].startswith('within') for row in pairs)
    assert Counter(row['BRaters'] for row in people) == {1: 160, 4: 80}
    assert sum(row['DReassigned'] for row in people) == 12
    summary = {
        'scope': 'Series D planning targets only; no responses, fitting, coverage or design ranking',
        'source': str(source.relative_to(here.parents[3])),
        'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
        'script_sha256': hashlib.sha256(here.read_bytes()).hexdigest(),
        'ordering': 'lexicographic SHA256(mfrmr-D-targets-v1:{Person}); Person breaks ties',
        'candidate_pairs': len(pairs), 'planned_pilot_pairs': sum(row['PilotSelected'] for row in pairs),
        'b_exposure_by_reference_group': {group: dict(Counter(row['BRaters'] for row in people if row['CGroup'] == group))
                                           for group in ('C1', 'C2')},
        'candidate_pair_exposure': {stratum: dict(Counter(row['BExposurePair'] for row in pairs if row['Stratum'] == stratum))
                                    for stratum in memberships},
        'pilot_pair_exposure': {stratum: dict(Counter(row['BExposurePair'] for row in pairs if row['Stratum'] == stratum and row['PilotSelected']))
                                for stratum in memberships},
        'checks': 'fixed input membership, counts, disjoint pairs, C partitions, B exposure and D reassignment passed',
    }
    for name, rows in (('persons', people), ('pairs', pairs)):
        with here.with_name(f'rating-design-targets-0.2.4-{name}.csv').open('w', newline='') as stream:
            writer = csv.DictWriter(stream, fieldnames=rows[0].keys(), lineterminator='\n')
            writer.writeheader()
            writer.writerows(rows)
    here.with_suffix('.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary, indent=2))


if __name__ == '__main__':
    build_targets()
