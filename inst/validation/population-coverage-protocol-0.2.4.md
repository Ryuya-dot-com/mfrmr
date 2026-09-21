# Estimated-population uncertainty: bounded sampling protocol

Date: 2026-09-10. Fixed before new datasets. Execution results belong in the
separate record; this protocol is not a release or production-readiness rule.

## Question and design

Do model-based intervals for the population mean at x=0, its regression slope,
and residual variance describe repeated sampling when that population is
estimated together with Rater, Criterion and threshold effects? The preceding
[full-information review](population-full-information-record-0.2.4.md) checked
derivatives and covariance algebra at retained solutions. This study asks about
sampling calibration, which numerical agreement alone cannot establish.

Reuse the existing independent generator without changing it. Eight cells cross
RSM/PCM, 80/320 independent Persons and 3/6 ratings per Person. Each cell has
three Raters, two Criteria and categories 0--2. The three-rating assignment
alternates complementary Criterion patterns; six ratings are fully crossed.
The fixed covariate is equally spaced on [-1,1], and each dataset independently
draws theta = 0.2 + 0.5*x + sqrt(0.7)*Z, Z standard normal. Thus the design
separates additional Persons from additional observations within a Person,
conditional on the same covariate design and a correctly specified population.

Retain Rater effects (0.3,-0.1,-0.2), Criterion effects (0.4,-0.4), RSM steps
(-0.6,0.6), and PCM ladders (-0.7,0.7)/(-0.2,0.2). Unit weights, no anchors,
interactions, response-dependent exclusions, or regenerated extreme patterns.
Every structural parameter remains jointly estimated as a nuisance parameter.

Primary targets are beta0=0.2, beta1=0.5, and lambda=log(sigma2)=log(0.7).
Use estimate +/- qnorm(.975)*SE from the complete inverse observed-information
matrix, including covariance with every nuisance parameter. Exponentiating the
lambda endpoints gives the primary residual-variance interval, with exactly the
same coverage event. Report its width on the variance scale separately from
lambda-scale SE calibration and bias. The mean target is the conditional mean
at x=0, not the realized sample mean or any individual Person's ability.

A secondary target is sigma2 itself: delta-method SE = exp(lambda)*SE(lambda),
with an untruncated symmetric normal interval. Preserve negative lower limits
and their frequency. This comparison investigates sensitivity to interval
construction; it cannot replace the prespecified primary interval after seeing
coverage. Finite back-transformed point estimates are retained for variance-scale
bias/RMSE. Overflow/underflow of back-transformed endpoints is recorded, never
silently removed; endpoints 0/Inf do not change the log-scale coverage event.

## Estimation, availability and limitations

Use direct MML, q61, maxit=300, reltol=1e-10 and the ordinary initialization.
Do not silently retry or select a fit using its distance from truth. Retain each
fit's native convergence classification, full gradient, complete parameter
vector, raw minimum information eigenvalue, covariance status, and variance.

For this repository-only study, a diagnostic interval is computable if native
convergence is `pass`, the whole parameter vector and a strictly positive
residual variance are finite, q61 covariance is unregularized (`ok`), and its
target estimate, SE>0 and interval endpoints are finite. A fit error, nonfinite
variance, regularized/singular information or target arithmetic failure makes
the corresponding interval unavailable. Preserve finite estimates regardless.
Record a mutually exclusive primary failure reason plus the underlying flags.

Production `InferenceReady` and scoring readiness remain false and are reported
separately. They must not define numerical availability: doing so would remove
every estimated-population fit by policy before calibration could be studied.
No test result changes that policy or labels diagnostic intervals as approved.

Evaluate q121 at the same fitted vector for every covariance-computable fit.
Require unregularized q121 covariance, absolute objective change <=1e-6,
maximum free-coordinate relative SE change <=.001, and q121 Newton displacement
divided by q61 free-coordinate SE <=.001. Full q61 and q121 gradients must be
<=1e-4. A computable-but-discordant interval remains in primary coverage and is
counted as a numerical conflict; a missing/failed q121 check is also discordant.
Any such conflict prevents a supported primary conclusion. These are local
diagnostics, not certificates for all quadrature orders or all variance values.

For replicate 1 in each preflight cell, also compare the independent continuous
objective and full central gradients (relative steps 1e-4 and 5e-5). Retain
objective difference <=1e-6, gradient step difference <=1e-7, gradient agreement
with q61 <=1e-7, and independent full gradient <=1e-4 as separate checks. Failure
requires investigation before the main run; it does not retrospectively filter
coverage or tune the bounds. All preflight fits/data are archived.

This positive-variance design does not establish global identification, certify
an interior global optimum, or test variance-zero/infinite-variance limits.
An unregularized local Hessian is only a computability condition. Each returned
fit retains an explicit boundary/global-qualification-pending label; no arbitrary
small-variance cutoff turns it into a certified interior solution. Fits with
nonfinite variance or unusable information remain in the assigned/attempted
counts. The previously demonstrated single-rating ridge remains an excluded
support condition, not a deleted trial from this three/six-rating study. Actual
zero-variance generation, weak-information designs, a boundary-aware estimator
and calibrated boundary intervals require a separate protocol; no finite lambda
truth or Wald coverage is fabricated at sigma2=0.

## Precision, aggregation and decisions

Plan 10,000 new datasets per cell (80,000 total), with no coverage-based early
stopping. At .95 coverage the MCSE is .00218 and approximate 95% half-width .00427
(0.43 percentage points); standardized-bias MCSE is about .01 under regular
normal errors. This improves bias precision over the earlier 2,500-per-cell
study but cannot guarantee resolution near a decision boundary. Retain review
decisions rather than adding repetitions until they pass.

Reuse the structural study's exact binomial intervals, bias/RMSE MCSEs and
influence-function MCSEs for standardized bias and RMS-SE/empirical-SD ratio.
Report all-finite-estimate bias/RMSE, then compare bias, SD and SE on the exact
same computable subset. Coverage is conditional on that subset. Also report
available-and-covered divided by ALL assigned trials, explicitly a joint
usability rate. Availability and conflict rates use all attempted trials;
Assigned and Attempted are both displayed, and incomplete runs cannot pass.
Missing cells cannot be omitted from a whole-study conclusion. Correlated
targets and transformations do not supply additional independent replications.

Retain the earlier study's explicit practical review margins: coverage MC
interval wholly in [.93,.97], SE-ratio MC interval in [.90,1.10], standardized
bias MC interval in [-.10,.10], availability's exact lower bound >=.99, no
computable numerical conflicts and their exact upper rate bound <=.002. An
interval disjoint from its margin is concern, overlap is review, and all criteria
must hold for supported-in-cell. Apply these coordinatewise, without a joint or
simultaneous-inference claim. A primary cell conclusion requires all three
primary targets; preserve the secondary variance-Wald disposition separately.
Supporting log-variance intervals does not establish unbiased natural-variance
point estimates, structural-parameter coverage, Person precision, TOST/Wald
joint decisions, TAM equivalence, or broader population-model eligibility.

Preflight uses five datasets per cell and never contributes to main-run
coverage. Seeds are 71000000 + 100000*cell + replicate for preflight and
81000000 + 100000*cell + replicate for the main run. Check all identities are
unique and disjoint. Store source/protocol hashes and snapshots, R session,
warnings, timing and all attempted outputs. Resume only the identical payload,
cell, stage and planned count, with atomic checkpoints every 50 trials (every
trial for preflight), a four-hour limit per invocation, and at most three local
processes owning disjoint cells. Resource stops remain incomplete, not passes.
Implementation defects pause execution and retain the original evidence; a
substantive redesign requires a new protocol and fresh main-run seeds.

First finish the preflight and review its numerical checks and measured timing.
Do not launch the 80,000-trial main run as part of this protocol-preparation step.
