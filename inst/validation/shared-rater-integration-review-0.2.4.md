# Shared-rater Person-integration review

2026-09-23. M2/M3 follow-through on the completed estimated-population study.
This is numerical diagnosis using existing datasets, not a new coverage study.
The original 800 outcomes and their qualification decisions remain unchanged.

Before running the review:

- Read all 800 saved check rows. Retain all 53 numerical failures. Select the
  largest gradient discrepancy in each of the four design cells for detailed
  reference calculations, plus the passing case nearest the gradient limit
  in each cell and the estimated-zero-rater-variance case as controls.
- At the original fitted calibration, compare the 61-, 123- and 241-point
  Laplace objectives and gradients. This isolates integration from calibration
  reoptimization. Check the original likelihood tolerance 1e-5 and gradient
  tolerance 1e-4 without relaxation. Agreement of two grids alone is not proof.
- For the four worst cases, independently integrate each Person's likelihood
  and score/curvature moments over the whole real line using stats::integrate,
  not the production quadrature or response-probability helpers. At the
  high-order rater mode, check joint stationarity, random-effect Hessian and
  the Laplace determinant. This checks the Person integral, not the accuracy
  of Laplace as an approximation to the full crossed marginal likelihood.
- For the worst discrepancy overall, also check the implicated marginal
  gradient by central differences of that independent Laplace calculation
  at two step sizes. Reoptimize the rater mode at each perturbed calibration;
  check its stationarity with continuous integrals. Aim for objective agreement
  1e-6, joint gradient/Hessian agreement 1e-6, and marginal gradient agreement
  1e-5 with finite-difference stability 1e-5. Report failures, not replacements.
- If reference calculations identify coarse Person quadrature as the cause,
  refit the four worst cases at 121 points (checked at 243) and compare
  calibration, rater modes and information with a 241-point objective. Keep
  this as selected numerical repair evidence, never recomputed coverage.
  Retain the separate variance-boundary and Laplace limitations.

No automatic full-suite or 800-fit repeat, no default-order change inferred
from selected cases, and no adaptive integration method is introduced merely
because a fixed grid is insufficient. Any production correction must follow
the actual defect identified here. Existing failure refusals remain effective.

Reference integration uses explicit infinite bounds and checks error estimates;
see the [official R documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/integrate.html).
Artifacts and source/input identities are stored in
`validation-results/shared-rater-integration-20260923/`.

## Affected-case follow-through, fixed before remaining refits

The fixed-parameter review of all 53 failures and five controls is complete.
All 58 pass the original tolerances when comparing 123 with 241 points.
Independent continuous likelihood/gradient/Hessian references agree in the
four worst cases; all four 121-point refits pass their 243-point checks.
To finish accounting for the affected cases, refit the remaining 49 failures
once at 121 points with the same model, maxit=400, and unchanged criteria.
Two workers split the frozen trial IDs deterministically. Preserve every
outcome; no retry at another order, no replacement, and no ordinary-model
refit. Check information and a 241-point objective/gradient at each result.
This is selected numerical follow-through on the original 53 cases. Do not
combine the corrected subset with the original study to revise its frozen
coverage or qualification conclusions. No default-order or general-validity
claim follows even if all these refits succeed.

## Numerical diagnosis and independent reference

The original failures were real discrepancies between a coarse Person grid
and a finer evaluation, not an optimizer failure or a defect in the recorded
refusal. At the original calibration, all 53 failures and five controls have
123-versus-241-point differences below 1e-5 in negative log likelihood and
1e-4 in its gradient. Their maxima are 2.986303e-8 and 6.286316e-7.
These are evaluations at fixed calibration, not 58 refits.

The four design-cell maxima are trials 141, 340, 455 and 742. Independent
whole-line Person integrals agree with the 241-point joint likelihood,
gradient and random-effect Hessian to within 2.3e-13, 3.6e-14 and 9.3e-14,
respectively. Continuous-integral rater-mode gradients are below 4.1e-11;
Laplace objectives agree within 2.3e-13. These comparisons use the same
Laplace formula but independently calculate its Person integrals and
random-effect curvature. They do not compare Laplace with the exact crossed
integral, nor independently search for another rater mode.

In the worst original discrepancy, trial 340, the implicated coordinate is
ability SD. Its 61-point marginal gradient is 9.597073e-8; the 241-point
gradient is -0.00112335. Central differences of continuous-integral Laplace
values are -0.001123331 and -0.001123608 at steps 1e-4 and 5e-5. The rater
mode is reoptimized for each perturbation and checked with continuous
integrals (gradient below 2e-9). Thus the high-order marginal score is
supported by a reference independent of production Person quadrature.
The small finite-difference variation is reported, not rounded to zero.

The retained estimator, default order and tolerances are unchanged. New fits
expose `checks$PersonQuadratureStable`, reusing the existing two tolerance
conditions. An insufficient grid now produces an actionable warning: refit
with more points, up to the existing maximum 241; unresolved computation at
that maximum is explicitly reported. Help distinguishes evaluating an
existing calibration at a higher order from actually refitting it.
Optimization, information and variance-boundary restrictions remain separate.

`test-random-rater.R` passes, including the insufficient-grid refusal and
higher-order refit. Fresh-session replay with all fitting/objective functions
mocked to error preserves checks and missing automatic rater bounds for both
an original failed fit and a new refined fit. The changed Rd page renders to
HTML; the tutorial code parses. Only that Rd page changed during generation
(the file-inventory helper harmlessly warned when trying to hash the
pre-existing `man/figures` directory). No full suite, old scoring experiment
or original coverage simulation was rerun.

The initial source and input hashes, source snapshot, reference calculations,
separate follow-through source/protocols, refits and checks are preserved in
the artifact directory. Initial and follow-through source identities differ
only as recorded; the original 800-study artifacts remain unchanged.

## Completed affected-case result

All **53/53** original numerical failures pass after refitting the unchanged
model at 121 Person points, with the regular 243-point check. Information is
positive and rater covariance is finite in every case. Independent evaluation
at 241 points also meets the original likelihood/gradient limits; its maximum
absolute gradient is 8.876262e-5. Maximum relative information-matrix movement
from 121 to 241 points is 9.937198e-8. The largest calibration-coordinate
change from the original fit is 2.302354e-5, and the largest observed-rater
mode change is **5.197038e-5 logits**. Total recorded fitting time over the
53 cases is 835.597 seconds, with the remaining 49 split across two workers;
this is not a single-process elapsed-time benchmark.

The result closes the cause/repair review for these 53 saved integration
failures: coarse Person quadrature caused the discrepancy, and higher-order
refitting resolves it in these cases without loosening criteria. It does
not certify 121 points for all designs, prove a global optimum, or qualify
the separate rater Laplace approximation. The numerical method itself was
not replaced. The explicit stability check, warning and help improve the
workflow when a requested order is insufficient.

The separate original estimated-zero-rater-variance case remains a legitimate
boundary restriction. Automatic individual-rater bounds remain missing in
all new refits. The original four primary interval decisions remain
inconclusive; corrected selected fits were not substituted into that study.
The all-case verification checks unchanged inputs, both source snapshots,
independent reference tolerances, exact failed-case accounting and saved
output restrictions. It passes, as do the focused test file, fresh replay,
changed help and `git diff --check`. M2/M3 remain open for Laplace accuracy,
retained scoring/uncertainty, estimated-population testlets and MI adequacy.
No commit, push, main integration or publication occurred.
