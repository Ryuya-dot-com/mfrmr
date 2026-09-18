# 0.2.4 integrated claim and evidence ledger

Date: 2026-09-14. **All 18 claim groups reconciled; claim closure and release
approval remain open.** This is the successor status assessment to the
[September 9 inventory](public-claim-evidence-review-0.2.4.md), under the
[public roadmap](../../ROADMAP.md). It does not broaden API support or replace
the source identities, protocols, failures or results in earlier records.

Subsequent follow-up: the [fit/diagnostics identity repair](estimator-output-identity-repair-0.2.4.md)
addresses a newly reproduced C03/C04/C05/C17 output defect. MML diagnostics
could incorrectly promote a JML lightweight summary to formal inference.
Shared source checks now reject these mixed pairs. That record contains the
new tests/source checkpoint; the counts and source identity below remain this
ledger's original reconciliation checkpoint, not results of the later repair.

The [paired-owner GPCM kernel audit, 2026-09-15](gpcm-paired-owner-kernel-0.2.4.md)
adds bounded C03/C04 evidence: 48 specified finite points cover both estimators
and slope owners, five categories, sparse observations and unequal weights.
It supports probability/NLL/gradient implementation agreement, retaining the
initial comparison-script and finite-difference failures and their follow-up.
Fixed quadrature remains sensitive to order; recovery, uncertainty and global
optimization claims stay open. The table below retains its original checkpoint.

The subsequent [continuous-integration study](gpcm-continuous-integration-0.2.4.md)
evaluates 120 fixed-point/rule combinations and 24 public GPCM-MML refits.
All four adaptive-Q61 refits meet the stated continuous-reference tolerances,
with small Q31/Q61 parameter changes; fixed Q301 remains materially sensitive
in the weighted sparse datasets. Two earlier wide-slope fixed points still
fail at adaptive Q301. This adds C04 numerical evidence without certifying
an order universally, a global optimum, or free-slope uncertainty.

The [initial-value and finite-path follow-up](gpcm-start-boundary-0.2.4.md)
finds close agreement between five new starts and the retained adaptive-Q61
solution in each of those four datasets. It checks specified finite slope/SD
paths while leaving nuisance coordinates fixed; it does not profile or exclude
all boundaries. A shared reporting repair also separates known numerical
convergence from pending statistical readiness. Its current-source tests and
package check belong to that follow-up; the original checkpoint below is
unchanged, and C04/C17 are not release-closed.

The [current-source FairZ follow-up](fairz-current-review-0.2.4.md) repairs
mixed fit/diagnostic inputs in fair-average tables and plots and reconciles
the fixed-reference candidate with a matching 40-dataset preflight. Saved
outputs, label variants and CSV routes retain the diagnostic restrictions.
This advances C12/C17 preparation. The subsequent
[confirmation](fairz-confirmation-status-0.2.4.md) resumed from 450 saved datasets
after the user's September 17 instruction and source/state verification.
All 20,000 assigned datasets are now complete: the
[frozen adjudication](fairz-confirmation-results-0.2.4.md) supports five primary
cells and leaves three under review. The subsequent
[package-check repair](package-check-repair-0.2.4.md) preserves the original
evidence identity and compares 12 saved cases against the changed source.
Public Fair Score interval eligibility remains false. Earlier checkpoint
tables below retain their original counts; the machine-readable ledger
includes later follow-ups.

The [September 17 maintainer sequence](internal-roadmap-0.2.3.md#2026-09-17-committed-baseline-and-next-decisions)
uses committed baseline `fe8220ce` and supersedes stale execution instructions
below. Completing a numerical repair or resuming a study does not close the
corresponding statistical claim.

The main workflow, documentation and many numerical/output repairs are well
advanced. The remaining work is to resolve the evidence and restrictions for
the exact retained claims, then verify one final release source. Counting
features, test expectations or mapped declarations does not measure that
completion; no overall completion percentage is assigned.

## What this reconciliation established

### September 18 follow-up: portable score summary tables (C07/C17)

On source baseline `d1c363d`, `summary(scores)$estimates` dropped the existing
`EstimateBasis`, `UncertaintyBasis`, `CalibrationId`, `SchemaVersion` and
`ScoringBasis` columns. The complete summary already retained interpretation
notes, but extracting its table lost these row-level fields. The summary now
preserves the available columns, including in empty score tables; console
previews and scoring calculations are unchanged.

The saved RSM and PCM objects in
`validation-results/person-estimated-calibration-20260914/linux-artifact-replay/cell-01.rds`
and `cell-05.rds` reproduced the loss. Replaying their summaries locally after
the repair preserved all prior columns and other summary components exactly;
both 27-Person tables retained the five fields through CSV round trips. The
saved objects were unchanged. The affected `test-calibration-public-api.R`
file passed 149 expectations with no failures or warnings and one expected
skip requiring a check-installed package. New regression checks cover the
summary/CSV fields, score rounding and the empty-table schema.

This closes the identified table-output defect. Intervals remain conditional
on the frozen point calibration and exclude calibration-parameter uncertainty.
It adds no statistical coverage evidence and does not close C07/C17 as a whole
or replace the final-source package/platform checks. No new calibration study,
full-suite rerun or development visualization was needed.

An installed-source follow-up at `6459a95` built and installed mfrmr in an
isolated temporary library using the available dependencies. The previously
skipped fresh-process artifact-scoring test passed all eight expectations,
without warnings or skips. A first whole-file installed run had 141 passes
but failed its vignette lookup because the build intentionally used
`--no-build-vignettes`; it is not recorded as a whole-file pass. An initial
attempt to isolate the test also failed in reporter initialization before
the test body ran. The final run used the unchanged fixture and target test
through `testthat::test_file()`. Build/install logs and both unsuccessful
attempts are retained with the successful log under
`validation-results/portable-installed-20260918/`. This completes that specific
installed-process check, not a new full package check.

### September 18 follow-up: DRF interpretation (C10/C15)

The [location and scope decision](interval-drf-preflight-record-0.2.4.md#september-18-drf-scope-and-location-decision)
resolves the algebraic treatment of facet centering using all 22 saved cases.
It separates a future matched fixed-population null from population
misspecification and preserves the original executions. Public DFF help now
keeps group ability differences distinct from differential functioning and
removes unsupported small-subset and multiple-comparison error-control claims.
The current scope remains screening; a matched null/power study and formal
inferential qualification are not completed by this documentation repair.

The subsequent [null-statistic audit](interval-drf-preflight-record-0.2.4.md#september-18-follow-up-which-null-does-the-statistic-test)
finds a distinct obstacle: even with known, correctly specified calibration
and group populations, EAP-based mean residuals can differ when DRF is zero.
The 64-pattern enumeration separates this centering problem from variance
approximation; an SE correction alone cannot repair the target. Eight fits using
the existing joint-MML API on four saved datasets reproduce continuous-integral likelihoods
within 3.56e-8, but all four public LRTs remain unavailable under the current
estimability contract. No finite-sample error-rate or power claim is added.

The [joint-null follow-up](interval-drf-preflight-record-0.2.4.md#september-18-follow-up-regularity-at-the-joint-null-and-comparison-reasons)
also finds full continuous-integral information rank at all four embedded
zero-interaction points and positive nuisance-adjusted interaction information.
Only inference readiness fails among the implemented comparison requirements;
this is not a finding of nonidentification or optimizer failure. Comparison
warnings now identify the fits and their actual readiness reasons. This left
a scoped population-model acceptance decision pending.

The subsequent [qualification decision](interval-drf-preflight-record-0.2.4.md#september-18-scope-decision-qualify-the-omnibus-comparison-separately)
specifies the first omnibus target and separates its size/availability evidence
from population-coordinate and Person-interval coverage. It also repairs an
automatic nesting gap: population designs must match by Person, while nuisance
estimates may differ. Existing legitimate comparisons and their readiness
restrictions are preserved. This closes that structural-classification defect,
not the omnibus test's inferential qualification (C02/C10/C15 remain open).

### Original reconciliation checkpoint

- The current `NAMESPACE` has **182 exports and 191 S3 registrations (373
  declarations)**. The old inventory has 372. The missing declaration was
  `plot_compare_mfrm()`, now mapped to C02/C03/C04/C05/C17. All current function
  source locations were resolved again. These are entry points, not 373
  independently validated analyses.
- C09's omitted contrast covariance and unsupported equivalence decisions are
  **repaired implementation defects**, not current outstanding defects. The
  six-fit current-source probe and analytic regression checks pass. This does
  not close finite-sample equivalence-test calibration.
- The Gauss–Hermite zero-weight defect is repaired, with later adaptive
  integration and external comparisons. A universal accurate quadrature order
  has not been established; small retained weights and adequate integration
  are separate requirements.
- Recent Person studies now distinguish a known calibration, an estimated
  calibration, a learned normal population and population transport. None
  substitutes for population-parameter interval validation or unconditional
  propagation of calibration/linking uncertainty.
- Public G/D-study, shrinkage, external imports and descriptive network/time
  routes have explicit dispositions below. Broader repository research models
  cannot supply evidence for a different public calculation.

## Claim-by-claim disposition

The [machine-readable ledger](claim-reconciliation-0.2.4.csv) records supported
scope, evidence, restrictions, source applicability and the next check for
each group. “Bounded evidence” below means support for the stated conditions,
not group-wide acceptance. Every row retains follow-up; none issues release
approval.

For example, `coverage_complete` in a precision table describes completeness
of the table's combinations; it is not a simulation-based interval coverage
result. Such output labels must be interpreted within their actual contract.

| Group and user question | Evidence and support to retain within its recorded scope | Remaining check / restriction |
| --- | --- | --- |
| **C01 Inputs and design:** can these ratings be analysed, and what is missing? | [User/data stress](user-data-stress-0.2.4.md): category support, missingness, ID preservation, sparse/disconnected designs, weights, replay and output paths. | Complete the per-route acceptance/refusal trace, especially combinations of anchors, interactions, categories and weights. Connectivity does not establish adequate information. |
| **C02 RSM/PCM MML:** does fitting evaluate and optimize the stated model? | [Weight repair](gauss-hermite-weight-repair-0.2.4.md), [adaptive fitting](adaptive-fitting-0.2.4.md), [TAM](tam-adaptive-recheck-0.2.4.md) and [ConQuest](conquest-adaptive-recheck-0.2.4.md) rechecks support their matched numerical targets. | Keep fitting and scoring integration separate. Close exact anchor/interaction/weight/population subclaims; numerical parity does not confer inference readiness. |
| **C03 JML:** which estimate and extreme-score convention is being reported? | [Matched estimator modes](tam-immer-jml-mode-comparison-record-0.2.3.md) and [extreme-profile pilot](jml-extreme-profile-recovery-pilot-record-0.2.3.md); current six-fit audit preserves exploratory precision. | Reconcile current raw/adjusted/corrected targets and non-extreme numerical overlap before mode-specific recovery. Ordinary SE/CI validity is not established by optimizer success. |
| **C04 Full GPCM:** does the complete selected-slope-owner model work? | [Non-unit score oracle](gpcm-nonunit-score-oracle-record-0.2.3.md), [owner identity checks](gpcm-owner-current-default-smoke-p1s-record-0.2.3.md) and bounded item-only external overlap. | Check both slope owners/estimators with nonzero other-facet effects, information and boundaries. Free-slope SE/CI remain ineligible. Item-only TAM agreement cannot close the complete model. |
| **C05 Precision and decisions:** what uncertainty does this SE, interval or reliability represent? | [20,000 structural datasets](mml-structural-coverage-record-0.2.4.md), then [30,000 fresh targeted datasets](mml-structural-bias-confirmation-record-0.2.4.md); [joint-information](mml-independent-information-conditions-record-0.2.4.md) and [weight restrictions](observation-weight-readiness-repair-record-0.2.4.md). | Reconcile old q61 fixed-population, unit-weight structural results to changed numerical source. Person posterior intervals, population parameters, reliability/separation and decision calibration need separate targets. These studies are not 50,000 replicates per condition. |
| **C06 Fitted-object scoring and draws:** what prior and calibration determine this Person result? | [Interval construction](person-interval-calibration-0.2.4.md), [prior robustness](person-prior-robustness-0.2.4.md), [estimated calibration](person-estimated-calibration-0.2.4.md), [learned population](person-learned-population-0.2.4.md) and [transport](person-population-transport-0.2.4.md). | Preserve the stated conditional uncertainty and source readiness. Learned-population scoring remains review-only. Do not extend these studies to every GPCM prediction, future outcome or plausible-value analysis. |
| **C07 Portable calibration:** can another user reproduce compatible new-Person scoring? | [Lifecycle and integration review](mml-quadrature-remedy-record-0.2.4.md), [data/replay stress](user-data-stress-0.2.4.md) and recent fixed-population Person evidence. | Retain fixed-normal RSM/PCM MML, documented direct/group anchors and the highest reviewed fitting grid. Recheck identity/refusal and fitting versus scoring settings on the final source. Calibration estimation uncertainty is excluded. |
| **C08 Anchors/linking:** are changes on a common scale, and what was held fixed? | [Sparse-design refinement](rater-anchor-incomplete-design-refinement-record-0.2.4.md), [topology](equating-topology-record-0.2.4.md), [conditional offset sensitivity](offset-sensitivity-record-0.2.4.md) and recent sparse execution/replay stress. | Fixed-anchor and fixed-source-estimate results do not establish estimated-anchor uncertainty. Paired full refits must repeat selection/linking and retain between-fit covariance; weak bridges need explicit information checks. |
| **C09 Equivalence:** is a small facet difference supported by its joint uncertainty? | [Shared repair](facet-equivalence-repair-record-0.2.4.md), [anchored rank restriction](mml-independent-information-conditions-record-0.2.4.md), current six fits and seven analytic/output test blocks. | Implementation repair verified. Finite-sample TOST, multiple-comparison operating characteristics and broader eligible anchor conditions remain open; preserve all ineligible-source refusals. |
| **C10 Bias/DFF/DIF/interactions:** is this a screen or a calibrated decision? | [22 execution cases and subsequent null-statistic audit](interval-drf-preflight-record-0.2.4.md): EAP residual centering can fail under no DRF; eight joint-MML fits reproduce independently integrated likelihoods. | Residual screens have a different null; refit screens omit shared-anchor estimation terms. Existing joint-model LRTs remain withheld by the estimability contract. Error rates and power remain unqualified. |
| **C11 Fit/PCA/Q3/person fit/QC:** what does a flagged response or residual pattern mean? | Existing formula/convention tests, [reporting audit](reporting-completeness-audit-0.2.4.md), and current Q3/person-fit/report tests. Unrequested PCA is not silently added by a report. | Verify thresholds, missingness, degrees of freedom and restrictions in all outputs. Numerical residual summaries do not validate a dimensionality or automatic fit decision. |
| **C12 Fair Scores and curves:** which reference produces this expected score and interval? | [Full-refit pilot](fair-score-refit-record-0.2.4.md), [interval repairs](interval-drf-preflight-record-0.2.4.md), [FairZ protocol/preflight](fairz-coverage-record-0.2.4.md). | FairZ is a zero-reference expected score. Public fair-score CI remain diagnostic-only/ineligible for ordinary inference. The 20,000-dataset joint-SE main study is unrun; reestimated-reference FairM, Person and gap uncertainty are distinct questions. |
| **C13 G/D-study:** what changes when only rater count changes? | Public observed-score Gaussian main-effect model; existing singularity/projection tests and the current hand-calculated fixed-Criterion example below. | Retain explicit collapsed-residual scaling assumptions. Full person-by-facet interactions, fixed-facet universe designs, multivariate decomposition and latent ordinal coefficients are not established by these helpers. Public formula/scope review remains necessary. |
| **C14 Hierarchy and shrinkage:** is this descriptive adjustment or a new fitted model? | Existing hand-calculation, full-pooling, prior-SD, hierarchy/ICC, manifest and plotting tests, rerun here. | Shrinkage is post-hoc, with a naive SE conditional on prior variance; full pooling can yield zero `ShrunkSE`. Trace downstream interval/ranking uses and heuristic thresholds. No joint hierarchical MFRM fit or calibrated shrinkage interval is established. |
| **C15 Simulation/design/resampling:** does the validation experiment answer its stated question? | Recent Person studies record calibration reuse, Monte Carlo precision and failures; the DRF follow-up separates exact-pattern null centering from four saved-data likelihood checks. | Verify truth/identification, attempted versus eligible replicates, resampling unit and Monte Carlo error. Group ability shifts are legitimate no-DRF controls. Enumeration and eight fits do not establish procedure-level error rates or power. |
| **C16 External imports:** which quantities were actually estimated elsewhere? | Current FACETS import and metric/precision tests, plus [bounded ConQuest overlap](conquest-adaptive-recheck-0.2.4.md). | Import/normalization is not re-estimation or SE equivalence. Trace all importers, absent covariance/raw data, categories/constraints, and downstream refusals; FACETS tests do not validate every importer. |
| **C17 Reports/plots/APA/exports/replay:** does the result keep its meaning when reported? | [Beginner/data/replay stress](user-data-stress-0.2.4.md), [reporting completeness](reporting-completeness-audit-0.2.4.md), current output tests, all 373 declarations mapped. | Finish the decision-bearing route sweep, including legacy/imported/supplied objects and hidden annotations. Re-run complete workflows and platform checks on the eventual final source. A usable report does not establish the validity of its estimates. |
| **C18 Network/agreement/time:** what descriptive relationship is being summarized? | Current network/report, agreement-metric and response-time checks; the time review does not modify the measurement likelihood. | Check graph/overlap definitions and automatic labels across missing and degenerate data. Do not interpret descriptive centrality/agreement/time summaries as causal or latent-model inference. |

## Numerical agreement and quadrature: the current answer

The [Gauss–Hermite repair](gauss-hermite-weight-repair-0.2.4.md) addresses
eigenvector components becoming zero before squaring, which had removed
representable small weights. The replacement uses a scaled orthonormal
Hermite recurrence, not an epsilon floor. Its high-precision and platform
checks cover the recorded orders; very high orders still meet floating-point
limits and are refused when positive finite weights cannot be represented.
For example, the later learned-population study refused Q481. This is not a
promise that arbitrarily high orders are usable.

The [TAM adaptive recheck](tam-adaptive-recheck-0.2.4.md) retains 36 cases
(21 RSM, 15 PCM). Adaptive Q31/Q61 versus dense TAM Q301 satisfies numerical
criteria in 72/72 macOS comparisons and 20/20 comparisons from 10 selected
Linux cases. macOS maximum cumulative difficulty-surface discrepancy is
1.075e-5 and EAP discrepancy 1.942e-6. **Only 48/72 macOS and 16/20 Linux fits
are inference-ready.** The record retains the original restart failures and
their separate follow-ups. Fixed Q31/Q61 still shows material movement in
some patterns; repairing weights alone did not solve integration accuracy.

The [ConQuest recheck](conquest-adaptive-recheck-0.2.4.md) is a matched
96-Person, two-rater, two-criterion microcase, with four native and eight
mfrmr fits. Native calibration agreement and stochastic native Person-scoring
agreement are separate results. Changing native Person integration settings
left calibration exports identical; raising the scoring budget reduced the
observed maximum EAP difference to about 0.000485. This neither establishes
cross-software SE equivalence nor validates all multifacet models.

## G/D-study: counts held constant are not fixed-facet inference

The documented public call supports the requested planning pattern:

```r
gt <- mfrm_generalizability(fit)
ds <- mfrm_d_study(
  gt,
  data.frame(Rater = c(2, 3, 4), Criterion = 4),
  residual_scaling = "sensitivity"
)
```

Criterion count remains four while rater count changes. This does **not**
change Criterion from a random measurement facet to a statistically fixed
facet, nor fit person-by-rater and person-by-criterion interactions separately.
Removing a facet from `random_facets` does not demonstrate a valid fixed-facet
universe design. The public helper uses Gaussian observed numeric scores,
random main effects and a collapsed residual, with three explicit residual
scaling assumptions.

The current arithmetic check supplies variances Person=1, Rater=0.4,
Criterion=0.2, residual=0.8. All nine count/scaling rows match hand-calculated
error variances within 1e-12 and G/Phi at the public output's four-decimal
precision. The initial probe incorrectly demanded unrounded precision from
these rounded columns and failed; the corrected check separately verifies raw
error variances and rounded coefficients. No production calculation or
statistical acceptance criterion was changed. This checks the projection, not estimation of
those components or the adequacy of the decomposition for actual data.
The [multivariate research disposition](gtheory-multivariate-dsim6-maturity-disposition-record-0.2.4.md)
concerns a different model and does not promote this public helper.

## What must happen next

| Priority | Concrete next result | Completion condition / release consequence |
| --- | --- | --- |
| 1. Resolve retained uncertainty/output claims | Trace exact estimates, references, covariance sources and readiness through the remaining C03–C06/C08–C14/C16–C18 routes. Give each subclaim an evidence basis, verified restriction, or explicit unresolved disposition. | A repaired implementation is not left listed as broken; an unvalidated ordinary interval/decision is not declared supported. Already public GPCM/JML and secondary routes remain part of release review. |
| 2. Settle the small numerical/design questions | Reconcile the fixed-reference joint FairZ candidate to current source; align DRF generator location and group means; specify paired refit/linking targets; finish exact full-model GPCM/JML comparisons. | Define the procedure being evaluated, independent target calculation and failure accounting before spending on large confirmations. Preserve adverse results. |
| 3. Run only necessary claim-specific confirmations | FairZ planned main: **0/20,000**; population-parameter interval main: **0/80,000**. Each has 40 preliminary datasets on its recorded source. DRF null/power confirmation still requires the aligned pilot. | These are unrun studies, not failed studies. Recent Person experiments do not fill these denominators. Reconcile source and frozen criteria before execution; a narrower release scope requires an explicit restriction decision, not silently waiving missing evidence. No large study was launched by this reconciliation. |
| 4. Verify one final release candidate | Complete user workflows, packaged full tests, five-platform matrix, examples/vignettes and checks after required statistical/output changes. | Bind all results to the final source. Earlier cross-platform checks and the latest lighter package check are checkpoints, not final release approval. |

The historical FairZ record's documentation pause is not a new request for
permission. Help/reporting work has since advanced. The remaining prerequisite
is a current-source and target review; this ledger leaves the main study
pending and does not alter its frozen protocol.

## Current-source verification and provenance

The [reproduction script](claim-reconciliation-0.2.4.R) reuses the existing
six-fit audit with an explicit current inventory and nine existing test files.
The original inventory and old results are unchanged. No production R/C++ or
help implementation was changed by this reconciliation.

The retained [audit bundle](../../validation-results/claim-reconciliation-20260914)
contains the current inventory, runtime/covariance tables, per-test results,
fixed-count D-study table, source hashes, warnings, session information,
invocations and SHA-256 manifest.

- Six fits: RSM/PCM/GPCM × MML/JML on one example dataset, q31, two equivalence
  bounds. **0 unsupported positive-decision rows**, with ineligible routes
  refused. For 12 RSM/PCM pair contrasts the maximum absolute relative SE
  discrepancy is **0**. This is not six independent recovery experiments.
- Nine existing test files: **140 test blocks, 983 passing expectations,
  0 failures, 0 errors, 0 warnings and 0 skips**. Scope includes equivalence,
  Q3/person fit/G/D-study, shrinkage, hierarchy, response times, reports/network,
  FACETS metrics/imports and multifacet precision contracts.
- An additional nine-row fixed-Criterion D-study arithmetic check passes.
- Current `R/` (87), compiled-source files (2), `man/` (228), `NAMESPACE`,
  and all 170 packaged test files are byte-identical to the latest checked
  package. `DESCRIPTION` differs through build-time normalization/generated
  fields; its authored fields are semantically checked separately. Another
  284 repository test/helper files are not in that tarball and are not counted
  as packaged test coverage.

Latest checked tarball: `mfrmr_0.2.4.9000.tar.gz`, SHA-256
`1ad565ec34687a9ca1e6d57dc585547322fad47a9ed1b4c096249bbed9aeded5`.
Its macOS light `R CMD check --no-manual` checkpoint reports Status OK,
673 passing expectations and three intended skips. The older
[five-platform/full-workflow verification](prerelease-verification-0.2.4.md)
belongs to an earlier candidate. This reconciliation does not claim a new full
suite, five-platform run, coverage experiment or release approval.
