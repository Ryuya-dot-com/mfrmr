# Conditional posterior quantiles for persons and ability differences

2026-09-17. This plan precedes computation. The saved original, clustered and
boundary solutions in `local-testlet-information-0.2.4-evidence.rds` are treated
as known calibration values. No refitting or repeated-sampling study is run.

## Question

For a person scored from six ordinal ratings, how do equal-tail posterior
intervals compare with posterior mean +/- 1.959964 SD? Does the approximation
behave differently for a difference between two people's abilities? The
purpose is to qualify the conditional interval calculation before studying
estimated-calibration uncertainty. A 95% posterior probability conditional
on these responses and parameters is not a measured frequentist coverage rate.

The model and fixed N(0,1) ability prior are unchanged. For person p write
L_p(t) for the response likelihood after integrating the two independent
person-by-rater local effects. The continuous posterior density is
f_p(t)=phi(t)L_p(t)/Z_p. Evaluate the local integrals by the existing
tail-preserving normal quadrature, then integrate t continuously with base R
`integrate()` and invert the CDF with `uniroot()`. Do not treat the finite
normal quadrature nodes as draws from the posterior.

For two distinct people and known calibration, their abilities are
conditionally independent even though they have the same fixed raters.
For D=theta_p-theta_q, M=(theta_p+theta_q)/2, the independent standard-normal
priors imply D~N(0,2), M~N(0,1/2), independently. Hence

`f_D(d)=phi(d;0,2) E_M[L_p(M+d/2)L_q(M-d/2)]/(Z_p Z_q)`.

The transformation has unit absolute Jacobian. This is an algebraic
convolution identity for this particular model, not a shared-random-rater
likelihood. Integrate M with normal quadrature and D continuously. This
conditional independence is lost when calibration is mixed over, as explored
in the [calibration sensitivity record](local-testlet-person-uncertainty-0.2.4.md).

## Prespecified computation and checks

- Evaluate all six people at each of the three saved points (18 posteriors).
  This includes all-low/all-high rows and a person with one missing rater.
  Add a wholly missing person with known N(0,1) posterior.
- Evaluate four prespecified contrasts: original P1-P2 and P4-P5, clustered
  P4-P5, and boundary P1-P2. Add a contrast of two wholly missing people with
  known N(0,2) posterior. No search for interesting results among all pairs.
- At each setting normalize by the saved per-person log likelihoods, after
  reevaluating the qualified fixed-point kernel once to supply those values.
  Require the continuously integrated posterior mass to equal 1 within 1e-7,
  and its mean and SD to agree with the saved moments within 1e-6. For
  contrasts compare with the difference of means and sum of variances.
- Start with local-effect GH61 and, for contrasts, midpoint GH41. Check
  against GH121/GH81. If unresolved, refine only that posterior to
  GH181/GH121 and then GH241/GH181, retaining every earlier result. Require
  normalizer, mean/SD and selected CDF differences <=1e-7; endpoint/median
  differences <=1e-5. Report unresolved cases, not an unqualified interval.
- Integrate with absolute/relative tolerance 1e-9, subdivisions 200, splitting
  at the known posterior mean. CDF tails use the corresponding half-line;
  no truncated support or tail mass is silently dropped. Locate the .025,
  .5 and .975 quantiles with a bracket of mean +/- 10 SD and root tolerance
  1e-8. Require endpoint CDF errors <=1e-7 and monotonicity over these points
  and the two normal-approximation endpoints. Keep integration error estimates.
- Check missing-person and missing-pair quantiles against the exact normal
  quantiles within 1e-6. For both original contrasts check the reversed-pair
  density against f_D(-d) at the three selected quantiles within 1e-8.
- Independently check both original contrast CDFs at zero using
  `integral f_q(t) F_p(t) dt`, via nested continuous integration at the
  selected local quadrature order (tolerance 1e-6, agreement <=1e-5). This
  verifies the contrast transformation by a different integration route.
- Save equal-tail endpoints/median, normal endpoints, their actual posterior
  mass and both tail probabilities. Numerical 95% mass is a calculation
  check, not empirical coverage. Quantiles are conditional research results;
  estimated-calibration interval eligibility stays false.

Errors/warnings, quadrature attempts, source/input hashes and raw results are
retained. Reuse existing fitted solutions, TAM and package evidence; only the
new density/CDF/quantile and contrast calculations receive new checks. These
settings do not qualify the earlier alpha +/-40 or variance-16 stress cases.

## Results

**All 24 posterior distributions resolved and all 129 checks passed.** These
are 19 individual distributions and five difference distributions, including
the two exact-normal controls. No errors or warnings were captured. All 49
quadrature attempts are retained, including the coarser results.

Twenty-three distributions agreed between the first two rules. The boundary
P1-P2 contrast required the third rule: its mass changed by 3.91e-7 between
midpoint GH41 and GH81, exceeding the 1e-7 rule-comparison criterion. GH81 and
GH121 then agreed within 4.30e-12 in mass/moments. Only this contrast was
refined; none of the completed fits or earlier experiment suites were rerun.

At the selected rules, the maximum normalizer error was 1.63e-14 and the
maximum difference from known means/SDs was 2.95e-15. Quantile CDF error was
at most 2.87e-10. Exact-normal quantiles matched within 2.34e-9. For the two
original contrasts, the independently nested CDF at zero agreed with the
rotated-density route within 2.48e-13; reversing the people gave identical
reflected densities at the checked points. The nested integrator's own error
estimates (up to 8.61e-7) are retained separately from observed agreement.

## What the normal approximation does in these examples

The normal-approximation intervals contain **94.8886%--95.0000%** posterior
probability across the selected distributions. Their largest endpoint
difference from an equal-tail interval is .037614 ability units. Thus these
examples show generally close conditional approximations, not a large general
failure of normal intervals. This finding is restricted to the tested data
and known calibration values.

| Target | Equal-tail lower | Equal-tail upper | Normal lower | Normal upper | Normal posterior probability |
|---|---:|---:|---:|---:|---:|
| Original P4: all minimum scores | -2.954599 | .028138 | -2.917942 | .062713 | 94.9939% |
| Original P5: all maximum scores | -.100946 | 2.901181 | -.136541 | 2.863568 | 94.9949% |
| Original P4-P5 | -4.942475 | -.712082 | -4.905658 | -.676598 | 94.9979% |
| Clustered P4-P5 | -3.688908 | .805412 | -3.683767 | .810287 | 94.9987% |
| Boundary P1, with v fixed at zero | -.925867 | .925867 | -.921210 | .921210 | 94.8886% |

Near-95% total probability does not make the tails equal. For original P4,
the normal interval leaves 2.7746% in the lower tail and 2.2315% in the upper
tail; for P5, these are 2.2252% and 2.7799%. The equal-tail intervals leave
2.5% in each tail by construction, verified numerically. The original P4-P5
contrast has normal tail probabilities 2.6961% and 2.3060%.

The boundary example illustrates a different point: its individual posterior
is symmetric but is not exactly normal. Its equal-tail interval is slightly
wider. This interval assumes v=0 is **known**; it does not account for having
estimated a variance at the boundary. Likewise, the observed-rater differences
here condition on the fitted rater effects being exact, so the calibration
covariance from the previous experiment is not included.

## Consequence for the research sequence

The conditional density and quantile calculations now provide a checked
reference for the next stage. In these small examples, the remaining priority
is to examine estimation of the calibration parameters, with the same data
used for calibration and scoring. That study should compare known-calibration
and estimated-calibration results on the same generated data and keep failure,
boundary, and unavailable-interval counts. Individuals and paired differences
remain separate targets.

No repeated-sampling coverage rate was estimated here, and no calibration-aware
interval has been declared available. The results also do not qualify more
raters, shared random-rater effects, adaptive stopping, or rating-design
recommendations. They establish the conditional reference needed to investigate
those scoring questions without conflating quadrature error, normal
approximation, and calibration uncertainty.

## Artifacts and reproduction

- [Runner and numerical functions](local-testlet-posterior-quantiles-0.2.4.R),
  [129 checks](local-testlet-posterior-quantiles-0.2.4-checks.csv), and
  [24 interval comparisons](local-testlet-posterior-quantiles-0.2.4-intervals.csv).
- [Portable evidence](local-testlet-posterior-quantiles-0.2.4-evidence.rds)
  includes targets, frozen calibration values, sources, the original plan,
  every quadrature attempt, integration error estimates, independent CDF
  checks, and final summaries. No functions/environments are serialized.
- Raw checkpoints and console output remain in
  `validation-results/local-testlet-posterior-quantiles-20260917/`.
- Run from `development/` with
  `Rscript inst/validation/local-testlet-posterior-quantiles-0.2.4.R`.
  The input is tracked; a new TAM run is not required. The 49 attempts took
  52.236 seconds in total, with another 2.047 seconds for the independent
  contrast checks in this run. These are single-run timings, not a benchmark.
- Parent commit `bbfb830`; R 4.6.1. Runner MD5
  `75fe9d28ea7c38b283fdf93bacb13d9f`. The estimation, stress, and original
  reference hashes remain `e599de0ca8fed081da0b3f519505d690`,
  `812999e7da7ecbbdbb654974529058aa`, and `6bacb70c9d4c0fba27bef70a508f0f88`.
  Source/input identities remained unchanged during execution.

Changes are repository-only research code and records. Existing production
APIs, dependencies, full-package checks, FairZ evidence and interval eligibility
are unchanged.
