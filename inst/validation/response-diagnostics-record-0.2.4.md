# Posterior predictive residuals for the two latent-effect models

Local checkpoint: 2026-09-23. Working tree based on `2230003`, branch
`development/0.2.4-expanded-workflows-20260922`. No commit, push, main merge,
CI run or release is implied by this record.

## Question, decision and release position

M3 requires response probabilities and full predictive variances before
model-aware residual plots can be meaningful. The new
`mfrm_response_diagnostics()` supplies this bounded calculation for both
latent-effect RSMs. The question is whether the implementation integrates the
intended latent uncertainty, preserves incomplete outputs and connects the
same saved quantities to plots/reports. It is not whether a mean square of one
or an ordinary-model threshold calibrates a fit test.

For a replicate sharing the original row's ability and local/shared-rater
effects, calibration is fixed and the latent posterior conditions on **all
observed source ratings**. Category probabilities determine the mean and
mixture variance. Descriptive Infit is the ratio of summed squared residuals
to summed predictive variances; Outfit averages the corresponding row ratios.
Both total-variance terms are included. No reference mean, ZSTD, p-value,
quality flag or cutoff is supplied. Output row selection does not subset the
conditioning data; grouped summaries explicitly count selected rows.

This finishes a bounded numerical implementation checkpoint. M3 remains
incomplete: ordinary-model posterior predictions under the same definition,
aligned predictive/scoring comparisons, Wright/pathway displays and statistical
qualification remain. M2 uncertainty/MI requirements and M5 local integration
are not closed. Do not move required outcomes out of scope to declare completion.

## Method and independent references

Testlets use nested normal quadrature: the Person posterior combines all
blocks; local weights condition on both the Person ability and every observed
rating in the relevant block. The resulting joint weights average the
replicate probabilities. Shared raters use category-specific complete-roster
numerator integrals. Ability is integrated by quadrature, and the joint rater
mode and curvature are recomputed for each category while calibration is held
fixed. The numerator integrals are normalized over categories. The raw sum of
numerator/denominator ratios minus one remains `NormalizationError`. A cached
baseline denominator saves repeated identical work within a call. This does
not substitute a rater mode or independent rater marginals for integration.

[Tierney and Kadane (1986)](https://doi.org/10.1080/01621459.1986.10478240),
JASA 81, 82–86, was read page by page, with every printed page inspected as an
image from the [public PDF](https://www.math.mcgill.ca/dstephens/680/Handouts/OldPDFs/TierneyKadane-1986-JASA.pdf).
The source is a method reference, not a validation study of these MFRMs:

- p. 82: positive-function posterior expectations as ratios of integrals.
- p. 83: separate numerator mode/curvature, multivariate expression and limits
  of variance approximations; arbitrary signed functions require care.
- p. 84: predictive distributions and marginal posterior approximations.
- p. 85: application and comparison with numerical integration; its results
  do not transfer to rating designs.
- p. 86: regularity-dependent asymptotics and the need for more accurate
  calculations when the application requires them.

No asymptotic error order from that paper is claimed as a finite-sample bound
for growing rater vectors, sparse assignments or estimated calibration here.

## What was checked

The executable audit is `response-diagnostics-0.2.4.R`; run artifacts are in
`validation-results/response-diagnostics-20260923/` (excluded from the package).
The protocol and every reference case are retained separately.

1. **Independent continuous testlet reference.** A fixed calibration with two
   binary blocks was integrated using `stats::integrate()` and direct logistic
   probabilities. Both the predictive probability and the sum of expected
   conditional variance plus variance of conditional means matched within
   `1e-7`. The latter component was strictly positive; dropping it is detected.
2. **Independent shared-rater numerator reference.** Direct conditional
   likelihoods integrated continuously over ability, `optim()` rater modes
   and `optimHess()` curvature reproduced the RTMB category-specific joint
   Laplace probabilities within `2e-6`. Other Persons' responses changed the
   focal prediction, demonstrating that their shared evidence is retained.
3. **Boundary reductions.** Known zero local variance reduced to a continuous
   one-dimensional Rasch reference. Known zero rater variance reduced to a
   no-rater-effect reference. Zero ability and local variance still permit
   nondegenerate categorical predictions; they do not create individual
   ability-interval certainty.
4. **18 fixed-calibration conditions.** Two raters and three Persons; rater
   SD 0, 0.7 or 2; ability SD 0.7 or 1.2; mixed, extreme or sparse patterns.
   Independent tensor integration used `statmod` normal quadrature at 41 and
   81 points, refined to 121 when required. Every final reference difference
   was below `1e-7` (maximum `2.72e-8`). The API used 121/243 ability points.
   This is a deterministic approximation audit, not a Monte Carlo calibration
   study of fitted models.
5. **Existing fitted examples.** The saved testlet fit returned all 768 observed
   rows. The saved shared-rater fit returned one Person's 16 ratings, while
   all 768 observed ratings conditioned the posterior; its four group summaries
   each contain four selected rows, not the full rater workloads. The earlier
   incomplete testlet fit retained 320 assigned rows: 306 available observed
   rows and 14 missing-score rows. No calibration was re-estimated.
6. **Failure behavior.** Missing-only selections perform no response
   integration and do not return zero fit. Nonfinite/zero variance, partial
   failures and actual 7/15-point disagreement with a larger-variance testlet
   case withhold affected summaries. The latter resolves at 121/243 points.
   Reoriginating categories changes predicted means but not residual variance.
   Changed source rosters or retained observed data are rejected on attachment.
7. **User workflow.** Paired/scatter base and ggplot views, monochrome symbols,
   hidden annotations, alternative text and entirely unavailable views were
   exercised. Matching diagnostics attach to `mfrm_results()` and export as
   tables, figures, report, RDS and replay. Fresh-session exported replay worked
   without RTMB, fitting, scoring or numerical integration. Both new tutorial
   sections rendered using their exact saved calculations; eight affected
   help topics rendered cleanly. Plot images were inspected.

Across the 18 conditions, maximum absolute category-probability error was
`0.000922856`; maximum mean error was `0.00126280` score units and maximum
variance error was `0.000626075`. The largest absolute raw normalization defect
was `0.00452830`. The largest probability error occurred in the sparse case
with rater SD 2 and ability SD 0.7. Agreement of quadrature orders was much
closer than these errors: it does **not** measure the remaining Laplace error.
A small normalization defect is likewise not an error bound.

These results support the tested calculation, not a universal accuracy
promise. They do not quantify calibration uncertainty, frequentist coverage,
sensitivity/specificity of extended-model thresholds, or performance for
arbitrary panel sizes/distributions. The previous ordinary-model 900-fit
threshold stress audit does not validate cutoffs for this new statistic.

## Verification and audit trail

Five relevant test files passed after the final code changes (286 expectations
across their final runs): response diagnostics, extended results, testlet
integration, random-rater fitting and namespace registration. Unchanged tests
were reused; no full-package suite was repeated. `git diff --check` passed.
The final presentation/index metadata checks are separate from numerical
integration and do not rerun the reference grid.

Early harness runs exposed missing S3 registration before roxygen generation,
the new methods missing from the namespace contract, an older saved fit without
`assigned_data`, and a hard-coded Rater plot name in a Block-only reference.
The registration/contract and harnesses were corrected. Failed logs are kept;
final focused tests, workflow, omission/guard and replay logs supersede them.
No unresolved package failure is concealed by those preliminary runs.

Run evidence includes `protocol.rds`, `reference-*.rds`,
`reference-summary.csv`, fitted-workflow/omission results, plot images,
`docs-and-replay.R`, final logs, source hashes and the change snapshot.
Public NEWS/help/articles describe statistical meaning and supported use;
they do not expose this milestone terminology or validation-directory paths.
