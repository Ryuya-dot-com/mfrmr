"""Reuse completed normal-MC ray certificates across all saved JML statistics.

All weights are nonnegative and share the same proposal and denominator. A
target statistic's entire-ray tail union contained in a certified union has
no larger p-value numerator, at every nuisance value. This does not identify
endpoints, fill the interior, or constitute an independent coverage study.
"""
from fractions import Fraction as Q
from pathlib import Path
import csv
import hashlib
import json

root = Path('validation-results/mfrm-wide-map-pcm-r50-portable-20261003/summary-n30')
p = root / 'normal-mc-calibration/profiles'
proof_paths = {
    'right': p / 'slope-cover-observed-01-v50/right-profile-replay-terminal.json',
    'left': p / 'slope-cover-observed-01-v105/terminal-replay.json',
}
arms = ('GPCM-JML', 'GPCM-JML2', 'GPCM-JML4')
sources = {}


def bind(path, expected=None):
    path = Path(str(path).removeprefix('/Users/tohokusla/Dropbox/MFRM_Application/mfrmr/development/'))
    key = str(path.resolve())
    if key not in sources:
        with path.open('rb') as handle:
            sources[key] = hashlib.file_digest(handle, 'sha256').hexdigest()
    if expected is not None:
        assert sources[key] == expected, str(path)
    return sources[key]


def verify(hashes):
    for name, digest in hashes.items():
        bind(Path(name), digest)


def analytic_union(points, own, boundary):
    """Solve each affine squared-distance inequality on the complete ray."""
    members = []
    for i, value in enumerate(points, 1):
        if value is None:
            # The completed-failure reference statistic is zero; it can tie
            # the observed statistic only at the observed finite point.
            included = own >= boundary if boundary > 0 else own <= boundary
        else:
            at_boundary = (value-own)*(value+own-2*boundary)
            outward_slope = -2*(value-own)*(1 if boundary > 0 else -1)
            included = at_boundary >= 0 or outward_slope > 0
        if included:
            members.append(i)
    return members


def breakpoint_union(points, own, boundary):
    """Independent exact absolute-distance evaluation on every constant cell."""
    on_ray = (lambda x: x >= boundary) if boundary > 0 else (lambda x: x <= boundary)
    cuts = {boundary, own} | {(value+own)/2 for value in points if value is not None}
    cuts = sorted(x for x in cuts if on_ray(x))
    probes = cuts + [(a+b)/2 for a, b in zip(cuts, cuts[1:])]
    probes.append(cuts[-1]+1 if boundary > 0 else cuts[0]-1)
    members = set()
    for contrast in probes:
        observed = abs(own-contrast)
        members.update(i for i, value in enumerate(points, 1)
                       if (Q(0) if value is None else abs(value-contrast)) >= observed)
    return sorted(members)


def run():
    bind(Path(__file__))
    proof_records = {}
    identities = {}
    for side, path in proof_paths.items():
        bind(path)
        proof = json.loads(path.read_bytes())
        assert proof['Complete'] and proof['Pending'] == proof['Unresolved'] == 0
        assert proof['CheckedNewExclusions'] == len(proof['Checked'])
        assert all(Q(row['PValueUpper']) <= Q(1, 20) and
                   Q(row['RecordedUpper']) <= Q(1, 20) for row in proof['Checked'].values())
        identity = proof['Binding']['Identity']
        verify(proof['Binding']['VerifierSources'])
        verify(identity['Sources'])
        verify(identity['Inputs'])
        bind(Path(proof['StateSnapshot']), proof['StateSHA256'])
        assert identity['Arm'] == 'GPCM-JML' and identity['Observed'] == 1
        assert identity['Contrast'] == ('10' if side == 'right' else '-10')
        assert identity['Denominator'] == 50
        assert identity['Statistic'] == 'Absolute saved initial point minus contrast; completed failure zero'
        identities[side] = identity
        proof_records[side] = dict(Path=str(path), SHA256=bind(path),
            Snapshot=proof['StateSnapshot'], SnapshotSHA256=proof['StateSHA256'],
            Boundary=identity['Contrast'], IncludedReplicates=identity['IncludedReplicates'],
            CheckedLeafRectangles=proof['CheckedNewExclusions']+proof['ReusedExclusions'],
            EntireSlopeDomainCertified=True)
        print('Verified retained complete', side, 'ray bindings.', flush=True)
    left, right = identities['left'], identities['right']
    assert left['Inputs'] == right['Inputs']
    assert left['ProposalProbabilityEnclosures'] == right['ProposalProbabilityEnclosures']
    proposal_path = Path(left['ProposalProbabilityEnclosures'])
    proposal = json.loads(proposal_path.read_bytes())
    bind(proposal_path); verify(proposal['Sources'])
    assert proposal['Inputs'] == left['Inputs']
    assert [r['Replicate'] for r in proposal['Records']] == list(range(1, 51))
    assert all(0 < Q(r['Lower']) <= Q(r['Upper']) <= 1 for r in proposal['Records'])

    points_path = root / 'accuracy-review/contrasts.csv'
    failure_path = root / 'normal-mc-calibration/failure-rule.json'
    bind(points_path); bind(failure_path)
    failures = json.loads(failure_path.read_bytes()); verify(failures['Sources'])
    table = list(csv.DictReader(points_path.open()))
    results = []
    for arm in arms:
        rows = sorted((r for r in table if r['Arm'] == arm and r['Target'] == 'contrast:Criterion:1-2'),
                      key=lambda row: int(row['Replicate']))
        assert [int(r['Replicate']) for r in rows] == list(range(1, 51))
        assert all(r['Output'] == 'point' and r['Analysis'] == 'initial_finite_return' for r in rows)
        points = [Q(r['Estimate']) if r['Available'] == 'TRUE' and r['Estimate'] != 'NA' else None for r in rows]
        failed = [r for r in failures['Results'] if r['Arm'] == arm]
        assert {r['Replicate'] for r in failed} == set(range(1, 51))
        assert all(r['ObservedFailed'] == (points[r['Replicate']-1] is None) for r in failed)
        for replicate, own in enumerate(points, 1):
            rays = {}
            if own is not None:
                for side, identity in identities.items():
                    boundary = Q(identity['Contrast'])
                    members = analytic_union(points, own, boundary)
                    assert members == breakpoint_union(points, own, boundary)
                    assert replicate in members
                    if arm == 'GPCM-JML' and replicate == 1:
                        assert members == identity['IncludedReplicates']
                    uncovered = sorted(set(members)-set(identity['IncludedReplicates']))
                    rays[side] = dict(Boundary=str(boundary), Members=members,
                        MembersWithoutCertificate=uncovered, CertifiedExcluded=not uncovered)
            results.append(dict(Arm=arm, Replicate=replicate,
                SavedPoint=None if own is None else str(own),
                WholeLineByCompletedFailure=own is None, Rays=rays,
                BothExteriorRaysExcluded=bool(rays) and all(v['CertifiedExcluded'] for v in rays.values()),
                CompleteConfidenceSet=False))
    summary = {}
    for arm in arms:
        rows = [r for r in results if r['Arm'] == arm]
        summary[arm] = dict(Records=len(rows), WholeLineFailures=sum(r['WholeLineByCompletedFailure'] for r in rows),
            RightRay=sum(r['Rays'].get('right', {}).get('CertifiedExcluded', False) for r in rows),
            LeftRay=sum(r['Rays'].get('left', {}).get('CertifiedExcluded', False) for r in rows),
            BothRays=[r['Replicate'] for r in rows if r['BothExteriorRaysExcluded']])
    result = dict(ChecksPassed=True, Inputs=left['Inputs'], Sources=sources,
        CompletedProofs=proof_records, Proposal=str(proposal_path), Denominator=50,
        Summary=summary, Results=results, ExactAnalyticAndBreakpointMembershipAgree=True,
        NewFits=0, NewDatasets=0, NewIntegration=0, NewSlopeSearches=0,
        IndependentCoverageExperiment=False, CompleteConfidenceSetsProduced=0,
        Derivation='For every contrast on the named ray and every structural nuisance value, the target inclusive tail is contained in its ray union. If that union is contained in the completed certificate union, its sum of nonnegative likelihood/proposal weights divided by the same50 is no larger than the certified sum. Completed observed failures retain p=1 and the whole line.',
        Scope='One-sided outer exclusions for the same frozen N30 development bank. Missing subset containment means only that this reuse does not decide the ray. It is not acceptance, an exact endpoint, interior topology, or independent statistical confirmation.')
    out = p / 'complete-ray-subset-reuse-20261006'
    out.mkdir(exist_ok=False)
    (out / 'check.json').write_text(json.dumps(result, indent=2)+'\n')
    (out / Path(__file__).name).write_bytes(Path(__file__).read_bytes())
    print(json.dumps(summary, indent=2), flush=True)


if __name__ == '__main__':
    run()
