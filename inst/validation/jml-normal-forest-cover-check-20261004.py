"""Replay new forest exclusions without selecting witnesses or fitting.

The older partition and exclusions are reused. This verifier recomputes each
new absolute MC numerator using only its recorded forest, the existing
conditional/discordance bounds and endpoint bounds, including recorded
free-row forest endpoint transfers, allocated pairs, retained affine duals and
recorded probability mixtures with their optional pair powers.
By default it omits the optional marginal-profile ray, so its upper value can
be more conservative. --profiles includes checked profile rays and recomputes
their temperature transfer directly from the saved rational coefficients.
Completed verification entries resume against the identical source/inputs.
"""
from fractions import Fraction as Q
from pathlib import Path
import argparse
import hashlib
import json
import runpy


def run(root, state_path, out, include_profiles=False):
    main_path = Path('inst/validation/jml-normal-mc-slope-cover-20261004.py')
    payload = state_path.read_bytes(); state = json.loads(payload)
    identity = state['Identity']; hashes = dict(identity['Sources'])
    main_names = [name for name in hashes if Path(name).resolve() == main_path.resolve()]
    assert main_names and len({hashes[name] for name in main_names}) == 1
    expected_main = hashes[main_names[0]]
    for name in main_names: hashes.pop(name)
    if hashlib.sha256(main_path.read_bytes()).hexdigest() != expected_main:
        main_path = state_path.parent/'source.py'
    assert hashlib.sha256(main_path.read_bytes()).hexdigest() == expected_main
    hashes[str(main_path)] = expected_main
    m = runpy.run_path(str(main_path)); f = runpy.run_path(str(m['FOREST']))
    e = runpy.run_path(str(m['FOREST_ENDPOINT']))
    b = runpy.run_path(str(m['BASE'])); b['IV'].dps = 50
    d = runpy.run_path(str(m['DUAL']))
    m['verify'](hashes)
    m['check_partition'](state)
    samples, unused, inputs = b['read_inputs'](root); assert inputs == identity['Inputs']
    psi = Q(identity['Contrast']); members = identity['IncludedReplicates']
    points, point_paths = m['point_records'](root, identity['Arm'])
    assert [j+1 for j in m['ray_members'](points, identity['Observed']-1, psi)] == members
    proposal_path = Path(identity['ProposalProbabilityEnclosures'])
    proposal = json.loads(proposal_path.read_text()); m['verify'](proposal['Sources'])
    assert proposal['Inputs'] == inputs
    logs = {r['Replicate']: Q(r['LogLower']) for r in proposal['Records']}
    paths = [Path(__file__), main_path, m['FOREST'], m['FOREST_ENDPOINT'], m['BASE'], m['DUAL'], proposal_path]+point_paths
    profiles = {r: [] for r in members}
    if include_profiles:
        for name in identity['SharpProfileChecks']:
            path = Path(name); table = json.loads(path.read_text())
            m['verify'](table['Sources']); assert table['Inputs'] == inputs and table['ChecksPassed']
            paths.append(path)
            for profile in table['Results']:
                boundary, slope = Q(profile['ContrastBoundary']), Q(profile['AffineUpperSlope'])
                valid = ((profile['ContrastRay'] == 'left' and psi <= boundary and slope > 0) or
                         (profile['ContrastRay'] == 'right' and psi >= boundary and slope < 0))
                if profile['Replicate'] not in profiles or not valid: continue
                assert profile['AllLocationAndStepNuisanceCovered'] and profile['FixedSlopeGlobalProfileUpperVerified']
                reference = list(map(Q, profile['ReferenceSlopes']))
                assert len(reference) == 3 and min(reference) > 0 and reference[0]*reference[1]*reference[2] == 1
                profiles[profile['Replicate']].append((reference, Q(profile['AffineUpperIntercept'])+slope*psi))
    sources = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
    binding = dict(Identity=identity, VerifierSources=sources, IncludeProfileBounds=bool(include_profiles))
    if out.exists():
        result = json.loads(out.read_text()); assert result['Binding'] == binding
    else: result = dict(Binding=binding, Checked={}, Complete=False)
    globals_, static, pairs, witnesses, duals, mixtures = {}, {}, {}, {}, {}, {}
    initial_duals = None
    def retained_dual(replicate, path, digest):
        name = str(path)
        if name not in duals:
            m['verify']({name: digest})
            record = json.loads(Path(path).read_text())
            assert record['Replicate'] == replicate
            if 'Inputs' in record: assert record['Inputs'] == inputs
            if 'Sources' in record: m['verify'](record['Sources'])
            duals[name] = m['witness'](samples[replicate-1], record, d['design'])
            assert duals[name]['H']*psi < 0
        return duals[name]
    def initial_dual(replicate):
        nonlocal initial_duals
        if initial_duals is None:
            name = 'dual-unit' if psi > 0 else 'dual-small-small-large'
            path = root/'normal-mc-calibration/profiles'/name/'summary.json'
            m['verify']({str(path): identity['Sources'][str(path)]})
            summary = json.loads(path.read_text())
            assert summary['Provenance']['Inputs'] == inputs
            m['verify'](summary['Provenance']['Sources'])
            initial_duals = {row['Replicate']: row for row in summary['Results']}
        item = initial_duals[replicate]
        assert identity['Sources'][item['Path']] == item['SHA256']
        return retained_dual(replicate, item['Path'], item['SHA256'])
    for replicate in members:
        sample = samples[replicate-1]
        path = root/'normal-mc-calibration/profiles/global-tail'/f'replicate-{replicate:02d}.json'
        old = json.loads(path.read_text())
        globals_[replicate] = m['empirical_conditional'](sample, old, b, d['solve_exact'])
        static[replicate] = m['static_entropies'](sample, b)
        pairs[replicate] = m['endpoint_pairs'](sample, 1 if psi > 0 else -1)
    IV, iv, ends = (b[k] for k in ('IV', 'iv', 'ends'))
    sharp_transfer = identity.get('ProfileTemperatureTransfer')
    assert sharp_transfer in (None, 'sharp-four-category-product-one-rmax-at-most-two-v1',
                              'sharp-four-category-two-largest-owner-factors-v2')
    newly_excluded = state['Excluded'][state['InheritedExclusions']:]
    def save():
        temp = out.with_suffix('.tmp'); temp.write_text(json.dumps(result, indent=2)+'\n'); temp.replace(out)
    out.parent.mkdir(parents=True, exist_ok=True)
    for row in newly_excluded:
        key = hashlib.sha256(json.dumps(row['Box']).encode()).hexdigest()
        if key in result['Checked']:
            assert result['Checked'][key]['Box'] == row['Box']; continue
        for field in ('StaticNormalSelections',):
            assert not row.get(field) or not any(row[field]), 'Additional witness needs explicit replay: '+field
        lower, upper = m['bounds'](list(map(Q, row['Box'])))
        values = []
        def selections(name):
            return row.get(name) or [None]*len(members)
        for replicate, choice, transfers, pair, adaptive, scalar, mixture, powered in zip(
                members, row['NormalForestSelections'], selections('NormalForestEndpointTransfers'),
                selections('PairSelections'), selections('AdaptiveDualSelections'),
                selections('TransferScalars'), selections('MixtureSelections'),
                selections('PoweredMixtureSelections'), strict=True):
            sample = samples[replicate-1]; g = globals_[replicate]
            value = min(m['tail_upper'](Q(g['ConditionalLogLikelihoodUpper']), g['SlopeCertificates'], lower, b),
                        m['endpoint_upper'](sample, g, static[replicate], pairs[replicate], lower, upper, psi, b)[0],
                        Q(g['ConditionalLogLikelihoodUpper']))
            for reference, affine in profiles[replicate]:
                power = min(Q(1), *(lo/a for lo, a in zip(lower, reference)))
                penalty = sum(2*len(sample)*max(Q(0), hi/a-1) for hi, a in zip(upper, reference))
                value = min(value, ends(iv(power)*iv(affine)+iv(penalty)*IV.ln(4))[1])
                r = max(hi/a for hi, a in zip(upper, reference))
                if sharp_transfer and 1 < r <= 2:
                    # Independently bracket the increasing scalar derivative.
                    # This uses no profile/forest optimization or selection.
                    def factor(ratio):
                        if ratio <= 1: return Q(1)
                        low, high = Q(0), Q(3)
                        def derivative(u):
                            return (iv(u)/3)**iv(ratio-1)*(iv(ratio)+iv(ratio-power)*iv(u))-iv(power)
                        for unused in range(70):
                            mid = (low+high)/2; sign = ends(derivative(mid))
                            if sign[1] < 0: low = mid
                            elif sign[0] > 0: high = mid
                            else: break
                        assert ends(derivative(low))[1] < 0 < ends(derivative(high))[0]
                        return ends(iv(1+high)**iv(power)/(1+3*(iv(low)/3)**iv(ratio)))[1]
                    constant = factor(r)
                    assert all(len(roster) == 2 for roster, y in sample)
                    value = min(value, ends(iv(power*affine)+4*len(sample)*IV.ln(iv(constant)))[1])
                    if sharp_transfer == 'sharp-four-category-two-largest-owner-factors-v2':
                        constants = [factor(hi/a) for hi, a in zip(upper, reference)]
                        # A product-one vector has at most two ratios above one.
                        # Maximize over owner pairs rather than using a common factor.
                        penalty = max(ends(2*len(sample)*(IV.ln(iv(constants[i]))+IV.ln(iv(constants[j]))))[1]
                                      for i in range(3) for j in range(i+1, 3))
                        value = min(value, ends(iv(power*affine)+iv(penalty))[1])
            if pair is not None:
                value = min(value, m['allocated_upper'](sample, g, static[replicate], lower, upper, pair, b))
            if scalar is not None:
                value = min(value, m['transfer_upper'](initial_dual(replicate), lower, upper, psi, Q(scalar), b))
            if adaptive is not None:
                name = adaptive['Path']
                w = retained_dual(replicate, name, state['AdaptiveCertificates'][name])
                value = min(value, m['transfer_upper'](w, lower, upper, psi, Q(adaptive['Scalar']), b))
            if mixture is not None:
                if replicate not in mixtures:
                    mixtures[replicate] = m['mixture_witness'](sample, g, pairs[replicate], b)
                entropy, normal = m['mixture_terms'](mixtures[replicate], lower, upper, psi, mixture, b)
                mixture_value = entropy+normal
                if powered is not None:
                    power = Q(powered['Power']); assert 0 < power <= 1 and normal >= 0
                    mixture_value = ((1-power)*entropy+(1-power)**2*normal+
                        m['assigned_pair_upper'](sample, lower, power, powered['Assignments'], b))
                value = min(value, mixture_value)
            else:
                assert powered is None
            if choice is not None:
                if replicate not in witnesses:
                    conditional = m['mixture_witness'](sample, g, pairs[replicate], b)['q']
                    witnesses[replicate] = f['witness'](sample, conditional, b)
                value = min(value, e['upper'](witnesses[replicate], lower, upper, psi,
                                             choice, transfers or [], f, b))
            else:
                assert not transfers
            values.append(IV.exp(iv(value-logs[replicate])))
        bound = ends(sum(values, IV.mpf(0))/50)[1]
        assert bound <= Q(1, 20), 'The complete MC numerator was not independently bounded'
        result['Checked'][key] = dict(Box=row['Box'], PValueUpper=str(bound),
                                     RecordedUpper=row['PValueUpper'])
        if len(result['Checked']) % 25 == 0:
            save(); print('Replayed new forest exclusions:', len(result['Checked']), flush=True)
    snapshot = out.with_suffix('.state.json'); snapshot.write_bytes(payload)
    result.update(Complete=bool(state['Complete']), CheckedNewExclusions=len(newly_excluded),
                  ReusedExclusions=state['InheritedExclusions'], Pending=len(state['Pending']),
                  Unresolved=len(state['Unresolved']), StateSnapshot=str(snapshot),
                  StateSHA256=hashlib.sha256(payload).hexdigest(), NewFits=0, NewDatasets=0,
                  Scope='Replay of newly excluded rectangles; any pending/unresolved set remains open.')
    save()
    print('Verified:', len(newly_excluded), 'new exclusions; full ray complete:', result['Complete'], flush=True)


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('root', type=Path); p.add_argument('state', type=Path); p.add_argument('output', type=Path)
    p.add_argument('--profiles', action='store_true', help='Include certified profile-ray transfers')
    a = p.parse_args(); run(a.root, a.state, a.output, a.profiles)
