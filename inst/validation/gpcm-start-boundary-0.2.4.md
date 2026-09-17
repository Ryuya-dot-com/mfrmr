# GPCM initial values, finite boundary paths and convergence reporting

Date: 2026-09-15. C04/C17 follow-up to the
[continuous-integration study](gpcm-continuous-integration-0.2.4.md).
The numerical experiments reuse its four datasets. The production change is
confined to convergence prose; fitting, integration and inference eligibility
are unchanged.

## Questions and design

An accurate integral at a returned solution does not establish that another
initial value or a boundary direction cannot improve the likelihood. This
audit asks whether the four retained adaptive-Q61 solutions are sensitive to
specified starts, whether specified finite paths improve their continuous
likelihoods, and whether reports distinguish numerical convergence from
statistical readiness.

The four cases are complete and weak-bridge/weighted designs, each with
Criterion or Rater owning the slopes and steps. Both facets have four levels,
the score has five categories, and both facet effects are nonzero. There are
60 Persons, 960 complete rows or 486 sparse rows. Sparse weights are 0.25,
1, 3 and 8; they multiply row log likelihoods, not independent Person counts.
The generating slopes are moderate. These are the preceding study's paired
datasets, not four new independent recovery experiments.

The [runner](gpcm-start-boundary-0.2.4.R) reuses the existing optimizer,
independent raw-label/parameter expansion and continuous reference. Each
reference is initially checked at local integration limits 32 and 64. The
preceding criteria are unchanged: maximum changes in Person log marginal,
EAP and posterior SD below 1e-8; refined mass-relative integration error below
1e-9; and the log-concavity bound on omitted mass below 1e-12 relative to mass.
Moment tails are checked by range refinement, not a separate certified bound.

## Initial values: 20 new optimizations and four retained solutions

Each case retains the preceding adaptive-Q61 solution and adds five starts:
all 23 free coordinates zero; population SD 0.15 with slopes one; population
SD 4 with slopes one; and log-slope vectors (-1.5, -0.5, 0.5, 1.5) and its
reverse. Apart from the all-zero start, unmentioned nuisance coordinates stay
at the retained solution. The existing direct optimizer uses adaptive Q61,
`maxit = 400`, `reltol = 1e-10`, and its existing automatic optimizer selection.
This probes specified perturbations, not random-start coverage of parameter
space or a comparison of independent optimizer implementations.

All 24 candidate records returned code zero, had terminal gradient sup-norm
below 1e-4, and qualified continuous references. No errors or warnings were
discarded. The largest absolute adaptive-versus-continuous NLL discrepancy
was approximately 2.6e-9. The table compares candidates within each dataset;
parameter and Person differences are relative to its retained solution.

| Case | Candidates | Continuous NLL range | Maximum free-coordinate change | Maximum slope change | Maximum continuous EAP change |
| --- | ---: | ---: | ---: | ---: | ---: |
| Complete, Criterion owner | 6 | 1.70e-10 | 4.90e-6 | 7.22e-7 | 7.54e-7 |
| Complete, Rater owner | 6 | 2.00e-10 | 7.03e-6 | 3.57e-7 | 1.70e-6 |
| Weighted bridge, Criterion owner | 6 | 3.40e-10 | 4.95e-6 | 1.08e-6 | 1.93e-6 |
| Weighted bridge, Rater owner | 6 | 3.10e-10 | 7.74e-6 | 1.01e-6 | 2.81e-6 |

The maximum within-case population-SD range is 1.72e-6, and the largest
continuous posterior-SD change is 8.75e-7. The finite starts support local
stability for these datasets. They do not prove a unique or global maximum,
consistent estimation, recovery under other generators, or interval coverage.
The continuous-gradient comparison in the preceding record applies to the
four retained solutions; this audit does not count another 24 independent
continuous-gradient verifications.

## Finite paths and reference refinement

For each retained solution, the runner evaluates twelve ordered slope-pair
directions: add distance to one expanded log slope and subtract it from
another, preserving geometric mean one. Two more directions multiply the
population SD by exp(plus or minus distance). Distances are 0.5, 1.5 and 3.
All other coordinates stay fixed. This gives 168 finite points. Four additional
SD-zero endpoints use the exact conditional category likelihood at theta = mu,
with the other coordinates still fixed; they are not tiny-SD substitutes or
nuisance-reoptimized endpoints.

Initially, 153/168 finite points qualified. Fifteen failed the 32-versus-64
range-refinement criterion (3 complete/Rater, 6 weighted/Criterion, and 6
weighted/Rater). Their largest posterior-SD change was 9.30e-6 even though
the integration routine's refined mass-error estimates were below 1e-11.
This illustrates why a small integration routine error estimate alone is
insufficient when truncating an asymmetric posterior around its mode.

The recorded follow-up compares limits 64 and 128 only for those fifteen
points, without relaxing any tolerance. All fifteen qualify. Original
references and failures remain separate from the final merged 172-row table.
The four exact SD-zero endpoints do not require quadrature qualification.

| Case | Finite points | Smallest finite-path NLL increase | NLL increase at exact SD zero |
| --- | ---: | ---: | ---: |
| Complete, Criterion owner | 42 | 9.3031 | 404.3191 |
| Complete, Rater owner | 42 | 8.9306 | 482.8503 |
| Weighted bridge, Criterion owner | 42 | 7.9669 | 864.5000 |
| Weighted bridge, Rater owner | 42 | 8.6735 | 1382.3505 |

All changes are relative to the corresponding retained continuous NLL;
lower NLL would improve fit. None of these evaluated points improves it.
The finite points span expanded slopes approximately 0.022–47.25 and positive
population SDs 0.0588–34.18 across cases. They are selected rays at three
distances, not every value in those ranges. No nuisance parameter is refitted
along a path; joint/nuisance-profiled paths or other directions can behave
differently. An improving limiting sequence is not excluded by these results.

The separate existing analytic binary discordant-response control checks
that an actual improving slope-boundary direction decreases NLL, has a
positive marginal-probability derivative, and agrees with its independently
integrated paired identity. Its certificate is not transferred to the four
polytomous datasets. The legacy fixed-quadrature boundary certificates also
do not certify this continuous objective.
For that control, the marginal probability rises from 0.206621 to 0.245057
over distance 0 to 3 toward its known 0.25 limit. The maximum paired/direct
probability discrepancy is 1.67e-16. Thus this control detects improvement
while the specified polytomous points show deterioration.

## Reporting defect and repair

All four retained fits have known numerical convergence (`Converged = TRUE`,
`ConvergenceSeverity = "pass"`) but `InferenceReady = FALSE`. Previously,
the shared `summarize_convergence_metrics()` used inference readiness to
describe convergence, and reported “had unknown convergence status.” The
ordinary summary's inference restriction itself was already correct.

The shared narrative now reads the numerical convergence code and severity,
and says “met the numerical convergence checks.” Gradient-review, warning
and failure branches remain distinct. No convergence flag, readiness flag,
likelihood, parameter, SE or inference rule is changed.

The new regression reproduces the original failure before the fix and passes
after it. Replaying the four saved models through `summary()` and
`build_apa_outputs()` verifies the corrected prose and keeps both public
`FormalInference` decisions at `"No"`. The first replay assertion failed
because the APA text wraps the phrase across lines; the follow-up normalizes
whitespace in the comparison only. Its original failure log and actual report
are retained. This was an audit-script mismatch, not another product defect.

Four existing test files cover reporting method contracts, report helpers,
regression edge paths and estimator/output identity: 206 blocks, 924 passing
expectations, zero failures, errors, warnings or skips. This includes the five
new expectations. Overlapping test selections are not added to package-check
counts as independent evidence.

## Source and reproduction

The retained [bundle](../../validation-results/gpcm-start-boundary-20260915)
contains candidates and their optimizer histories, finite-point references,
range refinements, report replays, the original failed assertions, test tables,
source comparisons, session information and a SHA-256 manifest. Inputs remain
in the linked preceding archive and are identified by hash.

The numerical processes loaded source before the narrative fix. Comparing all
87 R source hashes confirms that only `R/reporting.R` changed afterward.
The build includes 317 R/compiled-source/help files, 171 packaged test/helper
files, `NAMESPACE` and `NEWS.md`; all 490 match the checked current files.
The changed test belongs to the focused selection, not the light CRAN list.

On macOS Tahoe 26.6.2 with R 4.6.1 arm64, `R CMD build` succeeded, including
vignettes. `NOT_CRAN=false R CMD check --no-manual` reports **Status: OK**,
including examples and rebuilding vignette outputs. Its light test selection
has 673 passing expectations, zero failures/warnings and three intended CRAN
skips. This is not a new full-suite or five-platform verification.

Tarball `mfrmr_0.2.4.9000.tar.gz`, SHA-256:
`df14e9859fc07bd20f160393a4f861ef0cf9977ccc077a9407bbcc86c8e6be8e`.
The archive retains the build/check logs and a copy of this source tarball.

Initial stability, numerical integration accuracy and a correct report are
separate evidence from global optimization, boundary exclusion and statistical
uncertainty. Free-slope intervals remain ineligible. Nuisance-profiled or joint
boundary paths, broader recovery/coverage and final release-platform review
remain open. No large FairZ or population-parameter confirmation was launched.
