"""Retain absolute proposal probability enclosures needed for MC inversion.

The original coarse floors remain valid tail bounds. Earlier relative-weight
records do not retain all absolute proposal probabilities; this fills that
missing reusable stage with the existing certified integrator. No JML refits.
"""
from pathlib import Path
from fractions import Fraction as Q
import hashlib
import json
import runpy
import sys
import numpy as np


def run(root, destination):
    assert not destination.exists(), 'Reuse the retained probability enclosures'
    base_path = Path('inst/validation/jml-normal-importance-mc-20261003.py')
    profile_path = Path('inst/validation/jml-normal-mc-profile-20261004.py')
    base = runpy.run_path(str(base_path)); base['IV'].dps = 50
    profile = runpy.run_path(str(profile_path))
    data, patterns, inputs = base['read_inputs'](root)
    IV, iv, ends = (base[k] for k in ('IV', 'iv', 'ends'))
    truth = np.array([-.3, 0, .3, -.6, -.4, -.8, -.9, -.4, -.5, 0, 0])
    # Retain the expensive raw integrals before normalization/cross-checks.
    cache = destination.with_suffix('.integrals.json')
    identity = dict(Inputs=inputs, IntegratorSource=hashlib.sha256(base_path.read_bytes()).hexdigest(),
                    Contrast='-1/2', Slopes=['1', '1', '1'], IntervalDecimalPrecision=50)
    if cache.exists():
        saved = json.loads(cache.read_text()); assert saved['Identity'] == identity
        values = [IV.mpf([iv(Q(lo)).a, iv(Q(hi)).b]) for lo, hi in saved['UnnormalizedLikelihoods']]
        integration = saved['Integration']
    else:
        values, integration = base['likelihoods'](data, patterns, Q(-1, 2), [Q(1)]*3, base['rule']())
        cache.parent.mkdir(parents=True, exist_ok=True)
        cache.write_text(json.dumps(dict(Identity=identity, Integration=integration,
                         UnnormalizedLikelihoods=[list(map(str, ends(v))) for v in values]), indent=2)+'\n')
    rows = []; differences = []
    tails = json.loads((root/'normal-mc-calibration/tail-bounds.json').read_text())
    assert inputs == tails['Inputs']
    for i, (sample, value) in enumerate(zip(data, values, strict=True), 1):
        # The existing integrator omits sqrt(2*pi) for each Person.
        probability = value/(2*IV.pi)**iv(Q(len(sample), 2))
        lower, upper = ends(probability); assert 0 < lower <= upper <= 1
        log_lower, log_upper = ends(IV.ln(probability))
        independent = profile['Likelihood'](sample, 241).evaluate(truth, -.5, False)
        difference = abs(independent-float((log_lower+log_upper)/2))
        assert difference < 1e-10, 'Independent floating quadrature contradicts the normalization'
        old = Q(2)**(-tails['Records'][i-1]['ProposalProbabilityLowerPowerOfTwo'])
        assert old <= lower
        rows.append(dict(Replicate=i, Lower=str(lower), Upper=str(upper),
                         LogLower=str(log_lower), LogUpper=str(log_upper),
                         CoarseFloorLogSlack=float(ends(IV.ln(iv(lower/old)))[0])))
        differences.append(difference)
    result = dict(Inputs=inputs, Records=rows, Integration=integration,
                  MaximumIndependentLogQuadratureDifference=max(differences),
                  NewResponses=0, OriginalJMLRefits=0,
                  Proposal='Stored unit-slope PCM, Criterion contrast -1/2, known N(0,1), conditional on each exogenous roster',
                  Sources={str(p): hashlib.sha256(p.read_bytes()).hexdigest()
                           for p in (Path(__file__), base_path, profile_path, cache, root/'normal-mc-calibration/tail-bounds.json')})
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(json.dumps(result, indent=2)+'\n')
    print('Absolute proposal enclosures retained:', len(rows), flush=True)
    print('Independent log quadrature difference:', max(differences), flush=True)
    print('Coarse-floor log slack range:', min(r['CoarseFloorLogSlack'] for r in rows),
          max(r['CoarseFloorLogSlack'] for r in rows), flush=True)


if __name__ == '__main__':
    run(Path(sys.argv[1]), Path(sys.argv[2]))
