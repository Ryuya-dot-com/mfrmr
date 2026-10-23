"""Extend the first complete-inversion target's retained inner component.

Reuse a saved nuisance point, not another fit. A single included reference
weight lower-bounds the unchanged absolute MC numerator. Log concavity joins
two certified fixed-slope endpoint likelihoods. This cannot exclude a null.
"""
from fractions import Fraction as Q
from pathlib import Path
import hashlib
import json
import math
import runpy

root = Path('validation-results/mfrm-wide-map-pcm-r50-portable-20261003/summary-n30')
calibration = root / 'normal-mc-calibration'
profiles = calibration / 'profiles'
out = profiles / 'retained-extension-20261006'
out.mkdir(exist_ok=True)
prior_path = profiles / 'slope-cover-observed-01-v2/jml-retention.json'
prior = json.loads(prior_path.read_text())
helper_path = profiles / 'slope-cover-observed-01-v2/source.py'
assert hashlib.sha256(helper_path.read_bytes()).hexdigest() == prior['Sources'][
    'inst/validation/jml-normal-mc-slope-cover-20261004.py']
helper = runpy.run_path(str(helper_path))
prior_sources = dict(prior['Sources'])
del prior_sources['inst/validation/jml-normal-mc-slope-cover-20261004.py']
helper['verify'](prior_sources)
base = runpy.run_path(str(helper['BASE']))
base['IV'].dps = 60
data, unused, inputs = base['read_inputs'](root)
points, point_paths = helper['point_records'](root, 'GPCM-JML')
assert prior['Inputs'] == inputs and prior['RetainedComponents'] == [['-1', '0']]
assert prior['Arm'] == 'GPCM-JML' and prior['Observed'] == 1 and prior['Denominator'] == 50
assert not prior['Unresolved'] and all(Q(r['PValueLower']) > Q(1, 20) for r in prior['Certificates'])

proposal_path = calibration / 'proposal-probabilities.json'
proposal = json.loads(proposal_path.read_text())
helper['verify'](proposal['Sources'])
assert proposal['Inputs'] == inputs
saved_path = profiles / 'adaptive-scaled/replicate-38-psi-0.json'
saved = json.loads(saved_path.read_text())
manifest_path = saved_path.parent / 'manifest.json'
manifest = json.loads(manifest_path.read_text())
helper['verify'](manifest['Sources']); helper['verify'](saved['PreviousSource'])
assert manifest['Inputs'] == inputs and saved['Replicate'] == 38 and saved['Contrast'] == 0
center = list(map(Q, saved['Parameters'][:9]))
slopes = list(map(Q, saved['Slopes'][:2]))
slopes += [1 / math.prod(slopes)]  # Exact product-one normalization.
assert min(slopes) > 0 and math.prod(slopes) == 1
start, end = Q(0), Q(1, 2)
assert all(abs(points[37] - p) >= abs(points[0] - p) for p in (start, end))
# The difference of squared distances is affine in contrast, so endpoint
# checks establish inclusive-tail membership on the whole segment.
proposal_upper = Q(next(r['LogUpper'] for r in proposal['Records'] if r['Replicate'] == 38))
checker_path = Path('inst/validation/jml-normal-profile-regions-check-20261004.py')
mesh_path = Path('inst/validation/jml-normal-profile-regions-20261004.py')
checker = runpy.run_path(str(checker_path)); mesh_helper = runpy.run_path(str(mesh_path))
paths = [Path(__file__), prior_path, helper_path, helper['BASE'], proposal_path,
         saved_path, manifest_path, checker_path, mesh_path] + point_paths
sources = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
binding = dict(Sources=sources, Inputs=inputs, Replicate=38,
               Parameters=list(map(str, center)), Slopes=list(map(str, slopes)))
records = []
for label, psi in (('zero', start), ('half', end)):
    path = out / (label + '.json')
    if path.exists():
        record = json.loads(path.read_text())
        assert record['Binding'] == binding and Q(record['Contrast']) == psi
    else:
        r, c, s = checker['arrays'](center, psi)
        mesh, diagnostic = mesh_helper['integration_mesh'](r, c, s, slopes)
        lower, segments = checker['lower_log_likelihood'](data[37], center, psi, slopes, base, mesh)
        independent = checker['scalar_likelihood'](data[37], center, psi, slopes)
        # The adjacent-odds calculation is a numerical cross-check; the
        # outward chord integral alone supplies the mathematical lower bound.
        assert float(lower) <= independent
        record = dict(Binding=binding, Contrast=str(psi), LogLikelihoodLower=str(lower),
                      IntegrationMesh=[[str(a), str(b)] for a, b in mesh],
                      ChordSegments=segments, IndependentAdjacentOddsLogLikelihood=independent)
        path.write_text(json.dumps(record, indent=2) + '\n')
    records.append(record)
    print(label, 'certified log-weight lower', float(Q(record['LogLikelihoodLower']) - proposal_upper), flush=True)
lower_log_weight = min(Q(r['LogLikelihoodLower']) for r in records) - proposal_upper
lower_p = base['ends'](base['IV'].exp(base['iv'](lower_log_weight)) / 50)[0]
assert lower_p > Q(1, 20)
helper['verify'](sources)
result = dict(Binding=binding, ChecksPassed=True, Arm='GPCM-JML', Observed=1,
              IncludedReference=38, Denominator=50, NewRetainedInterval=['0', '1/2'],
              PValueLower=str(min(Q(1), lower_p)), RetainedComponentWithPrior=['-1', '1/2'],
              EndpointFiles={str(out / (s + '.json')): hashlib.sha256((out / (s + '.json')).read_bytes()).hexdigest()
                             for s in ('zero', 'half')},
              NewFits=0, NewDatasets=0, CompleteConfidenceSet=False,
              Scope='A genuine continuous inner witness for the unchanged projected absolute-weight MC set. Other nuisance witnesses may retain further contrasts. No endpoint, topology or coverage claim.')
path = out / 'check.json'; payload = json.dumps(result, indent=2) + '\n'
assert not path.exists() or path.read_text() == payload
path.write_text(payload)
(out / Path(__file__).name).write_bytes(Path(__file__).read_bytes())
print('Retained inner component extended to [-1, 1/2]; new-segment p lower', float(lower_p), flush=True)
