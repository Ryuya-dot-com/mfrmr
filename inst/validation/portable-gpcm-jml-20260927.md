# Conditional portable GPCM JML qualification — 2026-09-27

## Question and admitted feature

Can a shared-owner GPCM JML calibration score later Persons in a separate R
session while preserving relative slopes, its reference prior and incomplete
global audit states, without carrying training responses or Person estimates?

Native conditional scoring and the public extract/validate/freeze/save/load/
score lifecycle now support this scope. File format 4 distinguishes GPCM JML
from GPCM MML (format 2) and RSM/PCM JML (format 3). Sources require shared slope
and step owners, unit weights, no anchors or interactions, and passing input,
category and numerical checks. The source's fresh joint objective must agree
with the stored optimum within 1e-6, maximum absolute gradient must be <= 1e-4,
and the unregularized full joint curvature must be positive definite with
reciprocal condition number > 1e-10. This includes all free Person and
structural parameters. No information-matrix inverse or formal interval is
produced. Dense curvature checking has quadratic memory cost in that dimension;
large-design scalability is not qualified by these small examples.

Known unbounded Person/slope statuses or certified additive/slope boundaries
block qualification, including when aggregate boundary status is incomplete.
Missing audit records also block it. Passing local checks does not complete
the global identification or boundary audit: original `not_evaluated` states
and false inference readiness remain recorded. Stored evidence is checked on
artifact and saved-score reading; a review flag cannot substitute for it.

This is fixed-calibration post-hoc EAP with a labelled N(0,1) reference prior,
not JML Person estimation or ML/WLE scoring. The prior was not estimated by
JML; explicit normal-prior sensitivity is supported. Each score batch checks
EAP/SD integration against adaptive references under the actual prior.
Posterior intervals condition on point calibration and exclude calibration
uncertainty and bias. There is no new exported function or dependency.

## Evidence and adverse result

Evidence is retained under `validation-results/portable-gpcm-jml-20260927/`,
excluded from package builds. Synthetic `example_core` supplies 14 training
Persons with Criterion or Rater as the shared owner. Both fits have 31 free
parameters. Maximum absolute gradients are 5.807965e-5 and 4.281288e-5;
reciprocal condition numbers are .001830209 and .004465361. These are working
examples, not coverage, population validity or stress-test guarantees.

The first implementation failed two assertions in a real all-maximum training
Person negative control. Local curvature could pass despite the retained
primary Person estimate being infinite, while aggregate boundary status was
`not_evaluated`. The fix directly checks retained Person/slope statuses and
boundary certificates before local qualification. The original failure is
preserved in `portable-tests-first.rds` and its log; the negative control now
passes. Positive local curvature is not used to override a known boundary.

The five new tests cover:

- Both shared owners and default/explicit normal priors; native and portable
  EAP, SD and continuous posterior endpoints agree within 1e-10. Fits remain
  unchanged. Text IDs `001`, `1` and literal `NA`, extreme, sparse and missing
  patterns retain their distinct meanings and dispositions.
- An independently assembled adjacent-logit likelihood, off-optimum numerical
  gradients and mixed Person/structural directional curvature. Independent
  posterior integration checks EAP/SD within 1e-6 and interval mass within 1e-7.
- Failed/missing audit evidence, perturbed optimizer parameters, singular
  curvature, unsupported ownership/anchors and corrupted artifact evidence.
  Formal JML slope intervals remain unavailable.
- Separate R processes receiving only package path, artifact path and new
  response rows, with fitting, fitted-object scoring and JML source evaluation
  mocked to stop. Worker closures use `baseenv()` so training fits are not
  serialized implicitly. Both owner types replay identically; saved summaries,
  base plots and ggplot conversion remain available.

Accepted results: **26 tests, 467 expectations**, no failures, errors, warnings
or skips. These comprise five new GPCM JML tests (105 expectations), three
RSM/PCM JML tests (88), twelve selected lifecycle/public API/prediction tests
(137), and six existing portable GPCM MML tests (137). `accepted-tests.rds`
collects the latest result per group without counting reruns twice. No whole-
package suite, unrelated simulation or external program comparison was rerun.

The actual new public tutorial chunk was executed through JML fitting,
extraction, save/load, scoring and CSV/RDS output. Both base and ggplot PNGs
were visually inspected: English labels and intervals are readable, and
removing ggplot titles works. Native plausible values retain conditional
source evidence. Outputs are under `tutorial/`; its calibration artifact is
the final qualified example. The root-level prototype `calibration.rds` and
`extraction.log` predate the boundary-evidence fix and are retained only as
development evidence, not as qualified replay fixtures.

## Disposition

Shared-owner conditional GPCM JML portability is complete locally within the
stated scope. Help, NEWS, capability guidance and the roadmap describe the
same scope. Global audit completion, separate-owner JML, ML/WLE, formal JML
structural intervals and general performance/coverage guarantees remain open.
No free-estimation equivalence to TAM or ConQuest is claimed by fixed-kernel
checks or by this qualification. Combined-source/archive and matching platform
checks remain release work; previous rc.6 results do not qualify this changed
source. No commit, push, tag or CRAN submission is part of this increment.

Subsequent scoped external scoring and literature checks on these actual JML
calibrations are recorded in
[the follow-up record](gpcm-jml-external-scoring-20260927.md). They supplement
the local implementation evidence without qualifying free JML estimation.
