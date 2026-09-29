# Portable RSM/PCM JML qualification — 2026-09-27

## Question and admitted feature

Can an existing JML calibration score later Persons in another R session,
without transporting training responses or Person estimates, while preserving
its identified scale, reference-prior meaning and numerical/source reviews?

The public extract/validate/freeze/save/load/score API now supports RSM/PCM JML
with file format 3. The admitted source must have current passing scoring
readiness, identified/finite/numerically-ready states, unit observation weights,
no anchors and no interactions. Fresh joint-likelihood evaluation must match
the stored objective within 1e-6, with maximum absolute gradient <= 1e-4.
These are numerical source criteria, not accuracy, bias or interval-coverage
claims. Unevaluated identification/boundary/numerical states are not admitted.
The model's estimator and the post-hoc N(0,1) reference prior are separate
semantic fields. An explicit normal prior may be supplied at scoring without
mutating the artifact. Every new batch checks EAP/SD against adaptive references.

This is fixed-calibration EAP, not new-Person ML/WLE scoring. The reference
prior was not estimated by JML. Posterior intervals condition on the point
calibration and do not include calibration bias or parameter uncertainty.
GPCM JML, anchors, interactions and weighted source calibrations remain outside
this increment. No new exported function or dependency is introduced.

## Evidence and failures retained

Local evidence is under `validation-results/portable-jml-20260927/` (excluded
from the package). Synthetic `example_core` supplies the first 14 Persons for
both current RSM and PCM JML fits. Source objective differences were zero;
maximum absolute gradients were 7.808977e-6 and 6.858838e-5, respectively.
These are working examples, not a representative simulation or stress study.

The new test file covers:

- Original fitted-object versus extracted/saved/loaded scoring, comparing EAP,
  SD and continuous posterior endpoints within 1e-10 under both default and
  explicit normal priors; source objects remain unchanged.
- A separate R process receiving only package path, artifact path and new
  response rows. The worker's environment is set to `baseenv()` to prevent
  accidental serialization of a test closure containing the fit. Fitting and
  fitted-object scoring entry points are mocked to stop if called. Estimates,
  settings and summary review tables match exactly for RSM and PCM.
- Distinct text IDs `001`, `1` and literal `NA`, all-minimum/all-maximum,
  one-response and all-missing Persons. Endpoint/sparse review labels persist;
  all-missing Persons remain unscored.
- Changed optimizer parameters/objective, old source contract, unevaluated
  source states, weights, interactions and unsupported GPCM JML refusals.
  Corrupted estimator/prior/evidence/schema cannot validate even after updating
  the stored semantic copy. Saved score readers reject corrupted source evidence.

The first 61-node test stopped on scoring integration rather than returning
inaccurate scores (`tests-first.log`). A fixed-calibration review isolated the
problem: central response patterns had maximum EAP/SD differences of 1.62e-5
(RSM) and 2.16e-5 (PCM) against adaptive references. At 141 nodes the corresponding
maximum discrepancies were 1.50e-11 and 5.33e-11. The 1e-5 acceptance tolerance
was unchanged. The source was not refitted for this grid comparison. The
61-node PCM refusal remains a regression assertion; 141 is an example setting,
not a universal guarantee or new global default.

Accepted checks: 3 JML tests, 88 expectations; 12 selected existing lifecycle,
public API and prediction tests, 137 expectations; 6 existing portable GPCM
MML tests, 137 expectations. All passed without warnings/skips. The source-
refusal and fresh-process groups were rerun only after their respective test
additions; `accepted-tests.rds` collects the latest result per group without
counting reruns twice. The isolated fresh-process rerun initially used a
test-working-directory-dependent package path; its retained failure was fixed
by resolving the loaded package path explicitly. Source-tree replay was tested;
the installed-package branch awaits the combined archive check. The MML cases cover schema versions 1/2, corruption and
future-version refusal, existing scoring and explicit-prior handling. No full
package suite or unrelated numerical study was repeated.

The public JML tutorial was executed through fitting, extraction, persistence,
scoring and prior sensitivity. Its base plot, saved score/CSV outputs and ggplot
conversion are retained in `tutorial/`. Visual inspection confirmed English
labels and readable intervals. The plot call was then checked with the existing
`main` argument, and the ggplot version with `labs(title = NULL, subtitle = NULL,
caption = NULL)`; unsupported plot argument names are not taught. The five
changed Rd topics parse/check, and `git diff --check` passes.

## Disposition

The RSM/PCM portion of the portable-JML milestone is complete locally within
this scope. Combined-source/archive checking and matching platform evidence
remain release work. Existing rc.6 or MML results do not qualify this changed
source. No tag, push, CRAN submission, new external-program comparison, formal
JML interval qualification or general sparse-design accuracy claim follows
from this record. Shared-owner GPCM JML requires its own source/boundary review
before extending portability; other JML inference milestones remain open.
