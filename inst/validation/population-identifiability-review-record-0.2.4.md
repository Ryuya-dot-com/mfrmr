# Population-model identification review

Date: 2026-09-10. Status: bounded diagnostic review complete. Production code
and inference restrictions are unchanged; ordinary estimated-population
inference and the broader 0.2.4 release remain unapproved.

## Question and why these checks answer it

Why do RSM/PCM models estimating a conditional-normal Person population retain
`design_rank_not_evaluated`, despite the independent information agreement in
the [use-condition audit](mml-use-condition-audit-record-0.2.4.md)? Is local
identification actually missing, or is a broader readiness requirement pending?

Trace the pre-fit additive design, post-fit nonlinear score classification,
and shared readiness record. Reuse both retained 80-Person, six-rating,
three-category latent-regression examples at q31/q61/q121. Independently
differentiate their continuous-normal marginal probabilities to check whether
the fixed-quadrature local rank is a numerical artifact. Then use binary
intercept-only negative/paired controls to separate a real identification
failure from merely incomplete readiness instrumentation. Finally inspect a
small positive variance to distinguish local rank from precision.

This is a numerical/mathematical diagnostic, not a new parameter-recovery,
coverage, or full-model GPCM study. The six stored parameter vectors represent
two datasets, not six replications. Two additional datasets are deterministic
design controls. Two current-source population refits and two control fits
check actual readiness behavior.

## Source finding

`audit_mfrm_estimability()` audits population regression coefficients in the
linear predictor but excludes `log_sigma2`. Its `complete` flag is false
whenever a nonlinear optimizer block is present. The pre-fit additive ranks
are 6/6 (RSM) and 7/7 (PCM); the full models have 7 and 8 free coordinates.
Subsequent observed-pattern score audits already give full local rank in all
six stored fits. Their [existing local classifier](gpcm-nonlinear-local-estimability-p1u-record-0.2.3.md)
deliberately has no readiness effect. The shared fit record therefore retains
`EstimabilityState = not_evaluated` and `InferenceReady = FALSE`.

Exhaustive enumeration would involve 80 distinct covariate/design rows times
729 response patterns, or 58,320 evaluations, exceeding the existing 5,000
limit. This is not an absence of local evidence: full observed-pattern score
span is already a sufficient subset-of-support condition for positive
fixed-quadrature expected information. Raising the enumeration cap alone
would not settle global identification, boundary behavior or precision.

## Independent continuous-integral result

The [runner](population-identifiability-review-0.2.4.R) reuses the independent
RSM/PCM category-probability implementation, not the package's response kernel.
For each Person it integrates over the whole real line with adaptive normal
integration (`rel.tol = 1e-11`, `abs.tol = 1e-13`), then differences the log
marginal in every free coordinate at steps 1e-4 and 5e-5. It aligns Person rows
and optimizer coordinates before comparison. Unscaled score-matrix SVD uses
relative rank tolerances 1e-12, 1e-10 and 1e-8.

| Model | Continuous score rank, all three grids | Smallest singular value | Condition number | Maximum q61/q121 score discrepancy |
| --- | ---: | ---: | ---: | ---: |
| RSM | 7/7 | 3.23574 | 4.49540 | 2.132e-10 |
| PCM | 8/8 | 2.67843 | 6.30603 | 2.786e-10 |

The derivative-step discrepancy is at most 8.305e-10. These results support
local full rank at the retained parameter vectors under independent continuous
integration; they are not a symbolic/global identification proof or a uniform
guarantee over other data and parameter values.

The [numeric summary](population-identifiability-review-summary-0.2.4.csv)
retains one comparison miss: RSM q31 has a maximum Person-score difference of
1.871e-7, exceeding this audit's 1e-7 numerical comparison bound. PCM q31 is
9.561e-8. Their objective differences are only 4.372e-8 and 2.288e-8, both
within the 1e-6 objective bound. The rank conclusions are unchanged and the
q61/q121 differences are much smaller. This small q31 derivative discrepancy
is not evidence of materially incorrect SEs or a new universal grid rule.

The initial runner stopped at that first mismatch. The complete execution
keeps the original bounds and failed comparison, and continues the remaining
grids. Its initial source/log and inspected result are archived separately;
the criterion was not relaxed to obtain a pass.

## An exact variance/difficulty ambiguity and a paired control

Consider a binary RSM, centered Rater difficulties `(b, -b)`, population mean
zero, and variance `v > 0`. If every Person receives only one rating, then

```text
p1(v,b) = integral logistic(sqrt(v)*z - b) phi(z) dz
p2(v,b) = 1 - p1(v,b).
```

For any positive `v`, `p1` is continuous and strictly decreasing in `b`, with
limits 1 and 0. Hence a unique `b(v)` gives `p1 = 0.3` and `p2 = 0.7`. Distinct
variance/difficulty pairs have exactly the same observed response distribution.
This is an actual identification ridge, not just an inconclusive first-order
rank deficiency. Increasing the number of independent singly rated Persons
cannot distinguish these points in this intercept-only design. The mean-zero
curve lies inside the fitted model with a free population intercept.

The deterministic negative fixture has 100 Persons, 50 per Rater, and those
two observed rates. Its additive rank is 2/2 while full local rank is 2/3.
The package correctly declines inference. Its separate disconnected-design
and common-population-link warnings are retained; the ridge argument does
not rely solely on those warnings.

For the paired fixture, the same 100 Persons each receive both ratings, with
joint counts `(00, 01, 10, 11) = (25, 45, 5, 25)`. The marginal rates remain
0.3/0.7, but the probability of two positive ratings supplies additional
information. The [control results](population-identifiability-review-controls-0.2.4.csv)
evaluate the same marginal-probability curve:

| Population variance | Rater difficulty b | Both-positive probability with paired ratings | Unpaired rank | Paired rank |
| --- | ---: | ---: | ---: | ---: |
| 0.000001 | 0.847298 | 0.21000004 | 2/3 | 3/3 |
| 0.1 | 0.866898 | 0.21420184 | 2/3 | 3/3 |
| 1 | 1.018401 | 0.23999444 | 2/3 | 3/3 |
| 4 | 1.384226 | 0.27321541 | 2/3 | 3/3 |

This paired control establishes local information at the evaluated points;
it does not prove global identification for every repeated-rating design.
Independent whole-line all-pattern information agrees with the package's
q121 information within 3.319e-9 per entry. Tiny signed eigenvalues near
1e-15 in the unpaired case are roundoff around its zero eigenvalue.

Full column-scaled rank also does not certify precision. For 100 paired
Persons, information for log variance after adjusting for the two nuisance
coordinates decreases from 1.17127 at `v = 1` to 4.410e-12 at `v = 1e-6`,
even though scaled rank remains 3/3. These are information calculations at
specified points, not estimated sampling SEs, coverage results, or a newly
chosen variance cutoff. The small positive point is not the zero-variance
boundary itself.

## Verification, disposition and next work

The complete diagnostic execution took 39.412 seconds. Current-source RSM/PCM
refits retain full local rank but refuse formal inference and equivalence.
There are no execution errors in the complete run. The negative control
retains five warnings: three Matrix transpose notices and the two design/link
warnings described above. Other fresh/control fits have no warnings.
The [focused tests](population-identifiability-review-tests-0.2.4.csv) pass
455 expectations in the estimability, nonlinear-classification and readiness
files, with zero failures, errors, warnings or skips.

The [archive](population-identifiability-review-evidence-0.2.4.rds) retains
independent and package scores/information, singular values, all control
probabilities, current fits, warning text, test results, source snapshots and
source/input identities. The [execution log](population-identifiability-review-execution-0.2.4.log)
includes the initial stopped comparison and complete execution. Reproduce
from the package root with `Rscript inst/validation/population-identifiability-review-0.2.4.R`.
Preserve the dated archive before replaying a later source revision.

The supported answer is narrower than changing the readiness flag: these two
latent-regression examples have strong local numerical identification evidence,
but that does not justify general population-model inference. Keep the
restriction, and next examine residual-variance boundaries and bounded nuisance
profiles for RSM/PCM, including the zero-variance limiting model and high-variance
sensitivity. Reuse existing profiling machinery where applicable, distinguish
local finite-grid minima from global profiles, and retain the negative/paired
controls. Only then select any missing recovery/coverage study and its precise
inference scope. Full GPCM, JML and Person/joint-decision calibration remain
separate work.

No production functions, thresholds, prior statistical archives, or historical
decisions were changed by this review. A full package/OS release check was
not repeated.
