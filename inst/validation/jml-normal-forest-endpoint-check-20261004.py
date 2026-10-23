"""Check free-row contrast transfers and the complete retained MC numerator.

Raw category-design checks do not call the transfer helper's transformation.
The existing forest determinant/integration proof is reused unchanged. This
checks one unresolved rectangle, not the whole exterior ray or CI coverage.
"""
from fractions import Fraction as Q
from pathlib import Path
import argparse
import hashlib
import json
import runpy


def raw_checks(sample, w, choice, transfers, lower, upper, psi, forest, base, design):
    flags = choice['StaticOwners']
    baseline = [w['q'][int(flags[c])][i] for i, (_, _, c) in enumerate(w['cells'])]
    signs = (1, -1) if psi < 0 else (-1, 1)
    expected_H = -Q(1 if psi > 0 else -1)*sum(Q(c) for i, j, c in transfers)
    checked = 0
    changes = [None]+[(row, s) for row in choice['Pairs'] for s in (1, -1)]
    for slopes in (lower, upper, [(a+b)/2 for a, b in zip(lower, upper)]):
        for edge in changes:
            q = [list(row) for row in baseline]
            for i, j, scalar in transfers:
                for owner, index in enumerate((i, j)):
                    delta = signs[owner]*Q(scalar)/(3*slopes[owner])
                    q[index][0] -= delta; q[index][3] += delta
            expected = [sum(slopes[c]*w['scores'][int(flags[c])][c][p] for c in range(3))
                        for p in range(len(sample))]
            if edge is not None:
                (i, j, k, l, dp, dm), sign = edge
                delta = Q(dp) if sign > 0 else -Q(dm)
                q[i][k] -= delta; q[i][l] += delta
                q[j][k] += delta; q[j][l] -= delta
                expected[w['cells'][i][0]] -= slopes[i % 3]*delta*(l-k)
                expected[w['cells'][j][0]] += slopes[i % 3]*delta*(l-k)
            balance = [Q(0)]*9; scores = [Q(0)]*len(sample); H = Q(0)
            for (person, y, a, h, D), row in zip(design(sample, slopes), q, strict=True):
                assert min(row) >= 0 and sum(row) == 1
                residual = y-sum(k*z for k, z in enumerate(row))
                scores[person] += a*residual; H += h*residual
                for k in range(9): balance[k] += D[y][k]-sum(row[z]*D[z][k] for z in range(4))
            assert balance == [0]*9 and scores == expected and H == expected_H
            assert H*psi <= 0
            checked += 1
    return checked


def run(root, state_path, candidate_path, destination):
    main_path = Path('inst/validation/jml-normal-mc-slope-cover-20261004.py')
    endpoint_path = Path('inst/validation/jml-normal-forest-endpoint-20261004.py')
    m = runpy.run_path(str(main_path)); f = runpy.run_path(str(m['FOREST']))
    e = runpy.run_path(str(endpoint_path)); d = runpy.run_path(str(m['DUAL']))
    b = runpy.run_path(str(m['BASE'])); b['IV'].dps = 50
    state_bytes = state_path.read_bytes(); state = json.loads(state_bytes)
    m['verify'](state['Identity']['Sources']); m['check_partition'](state)
    samples, unused, inputs = b['read_inputs'](root)
    assert inputs == state['Identity']['Inputs']
    candidate = json.loads(candidate_path.read_text()); assert candidate['Inputs'] == inputs
    box = candidate['Box']; assert box in [row['Box'] for row in state['Unresolved']]
    lo, hi = m['bounds'](list(map(Q, box))); psi = Q(state['Identity']['Contrast'])
    members = state['Identity']['IncludedReplicates']
    points, paths = m['point_records'](root, state['Identity']['Arm'])
    assert [j+1 for j in m['ray_members'](points, state['Identity']['Observed']-1, psi)] == members
    proposal_path = Path(state['Identity']['ProposalProbabilityEnclosures'])
    proposal = json.loads(proposal_path.read_text()); m['verify'](proposal['Sources'])
    assert proposal['Inputs'] == inputs and state['Identity']['Denominator'] == 50
    logs = {row['Replicate']: Q(row['LogLower']) for row in proposal['Records']}
    paths += [Path(__file__), main_path, endpoint_path, m['FOREST'], m['BASE'], m['DUAL'], proposal_path]
    values = {}; records = {}; globals_ = {}; pairs = {}
    for replicate in members:
        sample = samples[replicate-1]
        path = root/'normal-mc-calibration/profiles/global-tail'/f'replicate-{replicate:02d}.json'
        old = json.loads(path.read_text()); paths.append(path)
        globals_[replicate] = g = m['empirical_conditional'](sample, old, b, d['solve_exact'])
        pairs[replicate] = m['endpoint_pairs'](sample, 1 if psi > 0 else -1)
        endpoint = m['endpoint_upper'](sample, g, m['static_entropies'](sample, b),
                                       pairs[replicate], lo, hi, psi, b)[0]
        values[replicate] = min(m['tail_upper'](Q(g['ConditionalLogLikelihoodUpper']),
                                              g['SlopeCertificates'], lo, b), endpoint,
                                Q(g['ConditionalLogLikelihoodUpper']))
    IV, iv, ends = (b[k] for k in ('IV', 'iv', 'ends'))
    def numerator():
        return ends(sum((IV.exp(iv(v-logs[r])) for r, v in values.items()), IV.mpf(0))/50)[1]
    for replicate in sorted(members, key=lambda r: values[r]-logs[r], reverse=True):
        if numerator() <= Q(1, 20): break
        sample = samples[replicate-1]
        conditional = m['mixture_witness'](sample, globals_[replicate], pairs[replicate], b)['q']
        w = f['witness'](sample, conditional, b)
        unused, choice = f['choose'](w, lo, hi)
        original = f['upper'](w, lo, hi, choice, b)
        transfers = e['choose'](w, lo, hi, psi, choice, f) if original < 0 else []
        value = e['upper'](w, lo, hi, psi, choice, transfers, f, b)
        checked = raw_checks(sample, w, choice, transfers, lo, hi, psi, f, b, d['design']) if transfers else 0
        values[replicate] = min(values[replicate], value)
        records[replicate] = dict(Forest=choice, Transfers=transfers, RawChecks=checked,
                                 ForestUpper=str(original), AugmentedUpper=str(value))
        print('replicate', replicate, 'transfers', len(transfers), 'raw checks', checked,
              'log weight upper', float(value-logs[replicate]), 'full p upper', float(numerator()), flush=True)
    result = dict(Box=box, Contrast=str(psi), IncludedReplicates=members, Denominator=50,
                  PValueUpper=str(numerator()), Excluded=numerator() <= Q(1, 20),
                  Records=records, LogLikelihoodUppers={r: str(v) for r, v in values.items()},
                  Sources={str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},
                  Inputs=inputs, StateSHA256=hashlib.sha256(state_bytes).hexdigest(),
                  NewOriginalFits=0, NewDatasets=0, CompleteConfidenceSet=False)
    destination.mkdir(parents=True, exist_ok=True)
    (destination/'check.json').write_text(json.dumps(result, indent=2)+'\n')
    (destination/'state.json').write_bytes(state_bytes)
    for path in (Path(__file__), main_path, endpoint_path, m['FOREST']):
        (destination/path.name).write_bytes(path.read_bytes())
    print('Complete MC numerator checked; rectangle excluded:', result['Excluded'], flush=True)


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    for name in ('root', 'state', 'candidate', 'destination'): p.add_argument(name, type=Path)
    args = p.parse_args(); run(args.root, args.state, args.candidate, args.destination)
