# Shared-rater calibration likelihood: result and disposition

2026-09-23. Local M2/M3. The bounded comparison of calibration-likelihood
changes is complete. This supplies numerical evidence for the approximation
used in fitting; it is separate from the completed conditional Person-scoring
comparison and from interval-coverage qualification.

## Question, design and evidence reuse

Do the production Laplace likelihood's local changes agree with the integrated
joint model near saved calibrations? Incorrect likelihood shape can affect
calibration and observed-information uncertainty even when Person scoring is
accurate. The [original protocol](shared-rater-calibration-reference-0.2.4.md)
was fixed before new likelihood-ratio outcomes. It reused eight full rosters
from the previous scoring reference: 240 Persons, 1,440 responses, six or 24
raters, and rotating or weakly linked assignments. These were first replicates
and previously chosen Person-quadrature challenges, not cases selected for
favorable Laplace error. All saved calibrations have estimated positive normal
ability and rater variances.

Each of six Cholesky-information directions and three named contrast/SD
directions was evaluated at plus/minus one local information unit. The 144
planned comparisons contain **128 distinct parameter points**: the C3-minus-C1
direction equals the first basis direction, so its sixteen duplicated checks
are named-target reporting, not extra independent evidence. Zero-displacement
controls are additional calculation checks. No parameter point was excluded,
clipped, refitted or replaced. All four chains and 32,000 saved joint draws per
roster were reused; no new random draws or completed-study refits occurred.

Preflight inspection caught a reader variable name (`ability` instead of the
saved Stan parameter `theta`) before executing any likelihood comparisons.
The original prepared plan/source remain as `preflight-plan.rds` and
`preflight-source/`; the corrected runner and unchanged protocol were frozen
before execution. This did not alter the statistical design or any outcome.

## Original reference and precision refinement

The original change-of-variables calculation translated abilities and averaged
raw density ratios. It produced 83 bounded agreements, four inconclusive
comparisons and 57 unresolved reference-precision checks. No comparison met
the material-discrepancy rule. Its largest log-mean MCSE was .088302; the
largest raw difference .048941 cannot be read as pure Laplace error. All
original files and decisions are retained.

The [affine follow-through](shared-rater-calibration-transport-0.2.4.md) was
specified after those results and before evaluating its own outcomes. It maps
all abilities and shared severities together using independent joint-density
modes and Hessians at the same fixed calibration points. The exact density
ratio includes the transformation's Jacobian. The Gaussian map reduces Monte
Carlo variance; the target integral remains the actual ordinal/normal joint
model, not a Gaussian or Laplace replacement. All 144 points, all draws and
the original .05-log-likelihood tolerance and precision gates are retained.
These are latent conditional modes, not new fitted calibrations. This is a
reference refinement, not independent replication.

## Completed numerical comparison

All 144 planned comparisons meet the original bounded-agreement rule after
the reference refinement. The maximum absolute difference is **.004992587
log-likelihood units**; the maximum error allowance, including four chain-aware
MCSEs, is **.007034528**, below the frozen .05 limit. This tolerance is one
tenth of the .5-unit quadratic drop at a one-information-unit displacement;
it is neither a logit tolerance nor an assessment threshold. Four MCSEs do not
constitute a simultaneous confidence guarantee across these comparisons.

| Check | Worst result | Frozen limit |
| --- | ---: | ---: |
| Log-mean MCSE | .001070139 | <= .01 |
| Raw importance ESS | minimum 30,821 / 32,000 | >= 1,000 |
| Raw-weight bulk / tail ESS | minimum 18,330 / 22,618 | both >= 400 |
| Raw-weight Rhat | 1.000391 | < 1.01 |
| Importance-tail Pareto k | .171750 | < .5 |
| 123/241-point production likelihood-change difference | 4.303e-8 | < 1e-5 |
| Independent R/compiled transformed log-density difference | 1.024e-11 | < 1e-8 |
| Original Stan / direct baseline log density | 2.274e-12 | < 1e-8 |
| Zero-map log-weight error | 9.095e-13 | < 1e-10 |
| Latent-mode maximum gradient | 9.262e-8 | < 1e-7 |
| Independent gradient / Hessian-vector check | 1.024e-7 / 1.322e-9 | < 1e-6 / 1e-5 |
| Change-of-variables determinant identity | 1.890e-13 | < 1e-8 |

The original posterior sampler checks remain those of the completed reference;
no diagnostic threshold or original coverage outcome changed. Raw weights,
not Pareto-smoothed weights, determine the likelihood-ratio estimates.
Per-point results, maps, checks, original/refined decisions, source identities
and timings are retained under
`validation-results/shared-rater-calibration-reference-20260923/`.
The read-only summary verifies frozen sources and input hashes before combining
results. Planned checks count repeated uses of the same eight datasets, not
144 independent assessment replications.

Recorded original calculation phases total **105.709 seconds** and the affine
refinement **207.226 seconds**. Both finish inside their separate frozen
20-minute execution budgets. New artifacts occupy about 64.4 MiB before
help/output integration, below the 512-MiB limit. These times exclude final
document rendering and are local workload measurements, not capacity or RAM
limits. Validation-only compiled helpers add no package dependency or API.

## Output interpretation and remaining release decisions

The bounded local calibration-likelihood comparison is complete. Together
with the earlier Person-scoring comparison, it removes those two specified
numerical-reference gaps. It does not establish an exact alternative MLE,
absolute likelihood normalization, every information-matrix entry, a fully
reoptimized SD profile, variance-boundary inference or generic sparse-design
accuracy. No new numerical study follows simply to make these limits disappear.
A new reproduced defect or a retained output that needs additional evidence
must justify further work.

This result does not change any statistical-coverage decision. Fixed-facet
and step intervals currently remain observed-information normal approximations
for numerically ready interior fits; the existing secondary coverage evidence
is inconclusive for general use. Testlet summaries, plotted annotations and
common saved-result reports now identify that approximation explicitly.
Rater individual bounds remain withheld automatically; explicit normal and
bootstrap requests retain their existing limits. Rater-SD profiles use an
asymptotic chi-square cutoff and are a separate target, not a replacement-rater
prediction interval. No regular testlet-variance or ability-SD interval is added.

The next M2/M3 decision is the retained interval contract: reconcile which
normal/profile outputs are admitted as approximations, what is available by
default versus explicit request, and what claims the existing evidence
supports. Clearer labels alone do not close that decision or convert
inconclusive coverage into qualification. Then complete M4/M5 source/help/
output integration. M3 and M5 remain incomplete; no commit, push, main merge,
release tag or publication occurred.

## Integration verification

The fit/scoring estimators and objective expressions are unchanged. The
shared-rater fitting source differs from its frozen reference only in roxygen
comments. Testlet changes are confined to summary/print interpretation and a
plot annotation; common reports name the observed-information normal
approximation. All **180 focused expectations** in the existing extended-result
and extended-view tests pass, with no failures, errors, warnings or skips.
No new fitting or coverage experiment was run for those presentation changes.

Three changed Rd topics were regenerated in an isolated staging package and
only those topics copied back. Rd checks and HTML rendering pass. The new
calibration tutorial section renders; all code chunks in both affected
vignettes parse. The full numerical tutorials were not executed again.
A fresh-process check replays the first shared-rater fit and the first
positive-dependence testlet-condition fit, with fitting/scoring entry points
replaced by errors: table values stay identical, reports carry the interval
method, and the testlet plot retains the same estimates and endpoints.
Source identities, parsed-expression checks, saved-summary decisions and the
rendered public text are retained with the results. No whole-package test
suite or previous simulation was repeated.

The first replay-check attempt used the wrong report-table key
`uncertainty_basis`; the public table is `interval_basis`. Correcting that
checker lookup made the unchanged report pass. The failed check log is
retained, and no package calculation was changed for it. The actual testlet
PNG was visually inspected: its English normal-approximation annotation and
axis/level labels are readable and unclipped. Rendered help/tutorial text
contains the stated scope and no local filesystem paths or milestone labels.
