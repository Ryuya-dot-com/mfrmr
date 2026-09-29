# Corrected JML: general observed inputs and matching covariance

Date: 2026-09-28. Roadmap milestone: **J1 internal computation implemented;
J2 scoped point/output, response diagnostics and conditional EAP implemented locally**.
The initial sections record internal engineering evidence. The public integration
follow-up below adds the explicit experimental estimator/output route; no new
sampling-coverage study is claimed.

## Question and decision

Can the exact plug-in profile-score adjustment accept observed long data beyond
the two-rater/two-criterion/three-category reference, while preserving sparse
assignments, parameter identification and the corresponding Person covariance?

The answer is yes for the checked structures below. Use the generalized internal
equation and covariance as the basis for J1 integration. The runtime follow-up
below adds explicit-order fitting and native parameter tables. Residual-bias
treatment remained open at that checkpoint; the subsequent public integration
increments are recorded below.
Do not transfer this engineering result into a claim of formal interval coverage.

## Model and equation

`R/core-jml-adjustment.R` accepts named Person/facet/score columns, observed
zero-based categories, additive fixed-facet locations, and one shared slope/step
owner. It uses the existing centered location/step and centered log-slope
coordinates. Column and level names are metadata; integer indices identify
cells. The constructor is parameterized by facet, level and category counts.
Tests cover the structures described here, not every possible design.

Each actual Person retains their observed exposure roster. Unassigned cells
contribute no responses; scores are not imputed. Repeated rows for a cell are
category counts under conditional independence, not correlated replicates.
All-minimum/maximum responses have limiting abilities of minus/plus infinity
and zero structural profile scores, rather than fictitious finite abilities.

For fixed structural coordinates beta, let U0 be the negative profiled
log-likelihood gradient and K_beta the conditional response-distribution
operator evaluated at that response's profiled Person MLE. The explicit-order
equation is Uk = (I - K_beta)^k U0. This uses the MLE plug-in construction in
Dhaene and Weidner (2023), *Approximate functional differencing*, SERIEs 14,
379–416, section 8.1, [doi:10.1007/s13209-023-00283-1](https://doi.org/10.1007/s13209-023-00283-1).
It is not a new claim of unbiased estimation for finite order.

The implementation reuses the earlier exact owner-total reformulation:
positive polynomial convolution yields probabilities and conditional cell-count
moments. These moments suffice for the affine-in-counts raw score and the
subsequent total-dependent corrections. No response states are pruned and no
Monte Carlo expectation error is introduced. The default limit is 5,000 joint
owner-total states per roster; exceeding it or underflowing a positive state
is an explicit failure. The observed-count workspace also has a memory guard.
These guards are implementation limits, not general capacity guarantees.

The full, generally nonsymmetric Jacobian A differentiates the complete adjusted
mean equation, including reprofiled abilities and the beta-dependent operator.
For N independent Persons, V = A^-1 B A^-T / N. B uses the **actual** adjusted
Person contributions, centered within roster when roster counts are fixed, or
globally when rosters are sampled. Conditional expected scores do not replace
the actual contributions in B. Jacobians at two numerical step sizes, equation
residual, rank and singular values are checked; no ridge or pseudoinverse is
substituted. This variance describes local variation around the adjusted-equation
root, which can remain displaced from the generating structural parameter.

## Evidence and results

The runner is `inst/validation/jml-general-inputs-20260928.R`; its local results
are in `validation-results/jml-general-inputs-20260928/`. The manifest records
source hashes and R session information. The runner source is unchanged;
`core-before-runtime-diagnostics.R` in that results directory preserves the
original numerical source and its recorded hash. The subsequent source changes
only make covariance-failure reasons specific. Frozen-equation/covariance tests
still use saved fixtures without a solver. The added internal runtime route
uses `nleqslv`, now declared in Suggests; its tests skip when that optional
dependency is absent.

1. **Frozen reference equivalence.** Both Rater and Criterion ownership, two
   structural vectors, sparse exposure (2, 1, 0, 2), and orders 0, 1, 2 and 4
   agree with the existing exact response-count calculation. Maximum absolute
   score discrepancy is **1.651124e-12**.
2. **Independent larger-structure calculation.** Tests enumerate all 64 ordered
   response sequences for three judges, two criteria, four categories and three
   assigned cells. A literal response formula, separate scalar profile roots,
   numerical gradients of the profile criterion and the full response transition
   matrix reproduce orders 0, 1, 2 and 4 for both a two-level and a three-level
   slope owner. Required agreement is 1e-6 for adjusted scores and 1e-9 for the
   profile criterion. Judge-label permutation with the corresponding coordinate
   transformation also agrees.
3. **Observed-data roots and variance.** One independently generated sample has
   400 Persons, three judges, two criteria, four categories, eight structural
   coordinates and 2,400 observed ratings. Two fixed sparse rosters contain
   200 Persons each and six ratings per Person; each roster has 91 total states.
   The columns include spaces and Japanese text. A normal ability distribution
   is used to generate this single engineering sample, not as an input to the
   estimator. Neither true parameters nor population roots initialize the solver.

| Explicit order | Maximum equation residual across two starts | Maximum coordinate difference between starts | Minimum Jacobian singular value | Minimum covariance eigenvalue |
| --- | ---: | ---: | ---: | ---: |
| 2 | 3.926670e-11 | 3.444467e-11 | .1759205 | .0006222404 |
| 4 | 1.078263e-11 | 1.175163e-11 | .1756620 | .0006212357 |

Both neutral and opposing starts converge using the first, Broyden attempt.
The runner specifies Newton fallbacks, but this sample does not exercise or
qualify their performance. All attempted results are retained. The Jacobian
asymmetry is .1158801/.1202332 for orders 2/4, demonstrating why replacing it
with a symmetrized likelihood Hessian would be incorrect.

Targeted tests also check the within/between-roster covariance decomposition,
the expanded Person influence covariance and first-order cancellation under an
empirical Person-weight perturbation. The latter checks the equation locally;
it is not an independent repeated-sample coverage estimate. Reversing data
rows/columns preserves results. Existing native JML parameter expansion and
GPCM probabilities reproduce the raw profile criterion within 1e-10. Additional
binary, three-facet cases check absent owners within rosters and single-Person
roster shapes against exact profile limits; they deliberately do not qualify
an identifiable estimator for a confounded design.

## Internal runtime follow-up

`R/core-jml-adjustment-fit.R` moves the root-solving procedure into the package's
internal code. An explicit positive correction order is required. It supplies
two deterministic starts based on the declared category structure, or accepts
at least two distinct supplied starts. For each start the fixed sequence is
Broyden/cubic line search, Newton/double dogleg, then shorter-step Newton.
Only a failed point-root check triggers a fallback; covariance is calculated
after choosing a compatible root and cannot change the fitting path.

An evaluated root must have a small complete mean equation, full numerical
Jacobian rank and a small remaining Newton displacement. A small unscaled
equation alone is insufficient when its derivative is tiny. Starting vectors,
solver version, controls, terminal results, warnings and errors are retained.
Different roots are returned as an unresolved ambiguity, with neither the raw
likelihood nor a smaller SE used to choose one. A root from only some starts
is retained with an explicit unresolved-start status; it is not described as
agreement across all starts. These checks establish local numerical evidence,
not global uniqueness or a statistical order-selection rule. The solver's
behaviour and termination controls were checked against the
[nleqslv reference manual](https://cran.r-project.org/web/packages/nleqslv/nleqslv.pdf).

The same observed-data fixture reproduces the saved order-2/4 roots within
1e-7 and their covariance within 1e-8 using the new deterministic defaults.
Targeted tests exercise unavailable covariance, conflicting roots, exhausted
iterations, failed starts, singular equations and deceptively small equations.
Synthetic equations isolate failure-handling decisions; they are not additional
GPCM sampling evidence. No samples are regenerated for these checks.

A real-data-path failure check removes one rating from the saved sample,
creating a roster containing a single Person. The fixed-roster covariance
is unavailable with that specific reason, while the point root is retained.
Switching only the covariance policy to random rosters leaves every root-finding
attempt and the point result identical. This tests separation of the two
computations; each covariance policy still requires its stated sampling design.

The internal table adapter reuses the existing location, step and slope table
builders. Their estimates match native parameter expansion; transformed
`RootSE` values agree with an independently differenced native expansion and
the complete covariance matrix, including omitted reference levels. Slope
tables distinguish `LogRootSE` from the delta-method slope-scale `RootSE`.
Person profiles retain extreme infinities and no Person SE is fabricated.
Estimator, order, point status, covariance status/reason and uncertainty target
survive RDS save/read. Binary zero-step coordinates are also checked. These
objects deliberately have no `mfrm_fit` class yet: ordinary likelihood audits,
diagnostics and information cannot be inherited from the raw-JML pipeline.

The public `fit_mfrm()` arguments and existing estimation defaults are unchanged.
This closes J1's internal computational deliverable for the declared scope;
it does not make the corrected workflow publicly callable or qualify structural
confidence intervals. Existing numerical covariance thresholds are unchanged;
failure messages now identify derivative evaluation, sample dimension,
equation residual, derivative instability, conditioning or empirical score rank.

## What remains before public completion

- Decide the supported inferential claim using residual-bias and sampling
  evidence. The earlier 200-dataset one-step study and 400-dataset order study
  remain relevant; orders 2 and 4 reverse MSE preference across settings.
  This single sample selects neither a best order nor an automatic policy.
- Connect corrected coordinates to the existing fit object, reprofiled Person
  scores, predictions, summaries, figures and saved output. The returned `q`
  is the **raw** profile criterion evaluated at the supplied coordinates, not
  a corrected likelihood. Ordinary likelihood IC/LRT must not be inherited.
- Qualify any proposed RSM/PCM reductions separately. Fixed anchors, nonunit
  weights, interactions, separate slope/step owners, multiple slope families,
  dependent/testlet responses and heterogeneous category ranges are outside
  this internal equation's declared scope.

The internal work above did not itself add a public estimator. The subsequent
public follow-up below supersedes that API status; automatic order, formal JML
intervals, external-software equivalence and release qualification remain open.


## Public fit/output follow-up

`fit_mfrm(..., model = "GPCM", method = "JML",
jml_correction_order = k)` now wraps the internal estimator in the existing
`mfrm_fit` class, with explicit shared ownership, declared categories, centered
fixed facets and observed unit-weight ratings. Its defaults do not change
ordinary MML or uncorrected JML. Unsupported supplied options are rejected,
not silently discarded. `jml_correction_sampling` preserves the distinct
fixed/random-roster covariance interpretations.

`summary()`, `as.data.frame()`, slope/location/step plots, their ggplot conversion,
`mfrm_results()`, `mfrm_report()` and `export_mfrm_results()` retain the estimator
and local-root uncertainty. RootSE is not labelled a structural SE with known
coverage. Plot bounds are absent rather than manufactured. HTML starter exports
show available point plots without demanding an unsupported Wright map; RDS
replay reloads the saved result without refitting. Ordinary likelihood expansion,
intervals, fit tests, prediction, model comparison and portable extraction refuse
corrected fits. The report cannot become an individual rater-quality sheet.

The public workflow regression tests reuse the saved general-input sample,
including a 0:3 to 1:4 score-origin shift. They compare roots and covariance
with the saved order-2 calculation, render all three plot routes and ggplot
conversions, export/reload/replay the result, and verify inference guards. A
one-iteration failure retains labelled missing estimates; a controlled covariance
failure retains valid points, missing RootSE and its reason through reporting.
The underlying covariance-failure calculations remain independently covered by
the internal tests above. The two-family public workflow is checked alongside
these targeted tests to protect the shared dispatch and guard changes. All
four affected test files (internal adjustment, public JML, public GMFRM and
extended plot views) passed. Base and ggplot figures were visually inspected;
JML displays omit inapplicable prior-only annotations. Rd parsing/checks,
usage checks, capability-registry consistency and `git diff --check` passed.

At this point/output checkpoint, J2 was **partly complete**: corrected
probabilities/diagnostics and eligible later-Person/portable scoring still needed
integration. The response-diagnostic follow-up below updates the former scope. Formal
structural intervals, residual-bias qualification and automatic order selection
remain separate. No additional large simulation, full package check or release
claim follows from the public output integration.


## Conditional response-diagnostic integration (2026-09-29)

The next J2 increment adds `mfrm_response_diagnostics()` for the observed
ratings of a saved corrected-JML fit. It reuses the native GPCM probability
kernel at the corrected structural tables and reprofiled Person estimates.
There is no posterior integration, calibration covariance propagation, refit
or imputation. The observed roster, original score origin and multiplicities
are retained. Original row selection changes summaries, not Person profiles.

Extreme profiles use their exact limiting point masses. Probabilities, means
and raw residuals remain available at zero variance, while standardized
residuals are explicitly undefined; no 0/0 convention is supplied. A defined
aggregate Infit is retained even when Outfit is unavailable. The paired plot
therefore draws each available index independently; the scatter view needs
both. This avoids unnecessarily erasing Infit without silently discarding any
selected row. An all-zero-variance group has neither index. These are
same-data descriptive quantities without calibrated cutoffs, ZSTD, p-values
or rater-quality classification.

`mfrm_results(fit, response_diagnostics = result)` checks saved slopes, Person
profiles, calibration and the exact source roster. Existing response tables,
plots, ggplot conversion, reports, exports and replay preserve the conditional
meaning without recomputing probabilities. The ordinary posterior routes keep
their probability definition and prior failure behavior.

Tests reuse the general-input fixture and compare probabilities with a literal
GPCM category recursion using the saved corrected coordinates. They check
profile-score cancellation, raw and standardized residual formulas, original
category shifts, selected/duplicate events, table reordering, extreme profiles,
partial group availability, unavailable covariance, source mismatches and saved
export/replay with probability recalculation disabled. Existing posterior
response diagnostics and response comparisons are regression-tested because
the group aggregation and plots are shared. No new sampling study is required
for this deterministic output integration. At that checkpoint, J2's eligible
new-Person/portable scoring remained open; the follow-up below implements
conditional EAP. Structural inference, residual-bias qualification and J3
remain separate.

The new corrected-JML response tests, existing corrected-JML public workflow,
posterior response diagnostics and response comparisons passed. The focused
output-guide regression and reference-index checks also passed. Base/ggplot
figures were visually checked, including the visible zero-variance explanation;
usage checks, generated Rd checks and whitespace checks passed. These are
local integration checks, not a full package/release check or a new coverage study.


## Corrected-calibration EAP integration (2026-09-29)

The remaining J2 scoring question is whether a saved corrected calibration
can supply known-level GPCM response functions to existing new-Person EAP,
without pretending to be an ordinary JML likelihood maximum or transporting
training Persons. `predict_mfrm_units()` and the existing calibration lifecycle
now do this for the explicit shared-owner, additive, unit-weight scope.

Source admission reconstructs the observed adjusted equation, verifies its
parameter layout and saved tables, and freshly checks the mean-equation
residual (<= 1e-7), full-Jacobian numerical rank and remaining Newton step
(<= 1e-5). These match the point-root rule. It does not rerun the solver,
require an ordinary likelihood gradient to vanish, or require the root
covariance to be available. Unresolved points and altered calibration are
refused without a review override. This establishes a locally resolved
numerical input, not a unique global root or bias-free structural estimate.

Portable format 5 reuses expanded facet/step/slope coordinates, score maps,
constraints, semantic identity and the existing lifecycle. Its own source
record retains correction order, sampling assumption, local-root status and
numerical checks. It contains no training rows, Person estimates, optimizer
or executable state. Formats 1–4 retain their existing admission meaning.

The scoring layer is unchanged: EAP with a retained N(0,1) reference or an
explicit normal scoring prior, per-batch adaptive-reference EAP/SD checks,
and continuous posterior-CDF intervals. Prior choice is not a JML-estimated
population. Intervals omit calibration uncertainty and residual calibration
bias; they are not corrected Person ML/WLE or structural confidence limits.
Score tables, summaries, native scoring-table export and portable plots retain
the corrected identity and order. Portable scores are separate saved objects,
not attachments to the corrected fit's `mfrm_results()`.

The targeted test reuses the existing three-judge/two-owner-level/four-category
sample and its saved eight-coordinate corrected solution. Literal response
logits and independent continuous integration provide EAP, SD and equal-tail
endpoint references for ordinary, minimum-only, maximum-only and one-row
Persons under two priors (tolerance 1e-5). Native and artifact scores are also
compared directly. Other checks cover shifted category origin, event IDs,
missing-only Persons, table ordering, unavailable covariance, tampered
root/data/order/coordinates, unsupported weights/levels, inadequate integration,
metadata/export and a fresh R process with source fitting/checking disabled.
No new repeated-sample study or claim of corrected-estimator equivalence with
TAM/ConQuest is made. Existing external checks concern the fixed response and
posterior-scoring layer; they do not qualify this adjusted estimator.


Verification passed: corrected scoring and public-output tests, portable GPCM
MML/JML, portable RSM/PCM JML, and scoring-prior regressions; selected format-1
lifecycle, independent scoring, malformed-artifact and public-method checks;
and the capability-table check. A pre-existing missing-header summary path
now returns the intended incomplete-artifact error. Generated help/usage and
whitespace checks passed. Base and ggplot score figures were visually checked
with corrected order and conditional-uncertainty captions. The final corrected
scoring test also checks posterior-draw identity and refuses changed level maps.
This is scoped local integration evidence, not a full package check, current
hosted CI, population-transport guarantee or new coverage study.
