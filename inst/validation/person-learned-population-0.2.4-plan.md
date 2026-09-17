# Learning the scoring population — frozen sampling plan

2026-09-14. Written before new study outcomes. A saved calibration can be used
to score people whose distribution differs from N(0,1). The preceding known-
calibration study isolated that mismatch. Here the question is practical:
does fitting an intercept-only normal population jointly with the calibration
improve independent new-Person scores, and what uncertainty remains?

Sixteen cells cross RSM/PCM, calibration N=80/320 and actual populations
N(0,1), N(.75,1), N(0,1.5^2), and (Gamma(2,1)-2)/sqrt(2). The last condition
has mean zero and variance one but remains non-normal after adjusting these
moments. Reuse the earlier independent categorical likelihood and calibration
truth: three Raters (.3,-.1,-.2), two Criteria (.4,-.4), categories 0--2,
RSM steps (-.6,.6), PCM ladders (-.7,.7)/(-.2,.2). Every calibration Person
has six conditionally independent ratings. No anchors, interactions, weights,
response-dependent deletions or changes of latent scale are introduced.

Each calibration sample supplies TWO paired public fits: ordinary fixed-N(0,1)
MML, and MML with `population_formula=~1` plus its one-row-per-Person table.
Estimate all facet/step parameters in both fits, and mean/variance in the latter.
Thus the practical comparison includes the consequent calibration changes;
it is not a pure prior substitution at identical estimated facet coordinates.
Use fixed Q121, direct MML, maxit=300, reltol=1e-10 and ordinary initialization.
Q121 rather than Q61 is chosen before fitting to accommodate the wider latent
population. No retry, truth-based starting values or best-fit selection.

Generate 512 independent new Persons per sample from the SAME actual
population. Preserve their actual abilities and six response rows; also score
the paired complementary three-rating subsets, equally represented. Calibration
and scoring IDs are disjoint. Score all 27 assignment/total profiles using
`predict_mfrm_units(scoring_quad_points=121)`, then reuse the previously checked
assignment/total lookup. It is valid only for these unit-slope designs. An
independent actual-density/known-calibration oracle is paired on the same new
Persons; it is a research reference, not a package feature.

Estimated-population fits currently have review-only scoring/inference status.
Use the existing explicit `readiness_policy="review"` to inspect both arms,
retaining readiness flags, reasons and warnings. Do not alter production gates.
A primary score result is numerically available when the fit returns finite
parameters and positive variance, native convergence passes, the full covariance
is unregularized, and all public profile estimates/SDs/bounds are finite.
Finite but numerically discordant results remain in the coverage denominator.
Record all failures without replacement. Availability is distinct from formal
eligibility, and no outcome here certifies the population-model boundary or a
new population-parameter confidence-interval API.

For every returned fit, compare Q121/Q241 at the same parameter vector:
objective difference <=1e-6, both full gradients <=1e-4. In the first preflight
replicate of each cell/arm, independently reconstruct Person log probabilities
using direct category probabilities, finite total convolution and whole-support
normal integration. Compare objective <=1e-6 and central gradients, differencing
Person log probabilities before summing, at relative steps 2.5e-5/1.25e-5:
step difference and native/reference difference <=1e-7, full reference gradient
<=1e-4. Also check all profile moments at Q121/Q241 (<=1e-6), independently
integrated posterior moments (<=1e-6) and endpoint CDFs (<=1e-6), and direct
public scoring versus lookup for 48 new Persons at both exposures (<=1e-8).
Any preflight numerical conflict requires investigation before the main run;
do not retrospectively redefine the criteria to make a fit pass.

Preflight: three calibration samples per cell (48), excluded from main summaries.
Main: 128 samples per cell (2,048), each with 512 new Persons (1,048,576 distinct
new Persons). The calibration sample is the Monte Carlo unit; paired arms and
exposures are not additional Persons or independent replications. With a
planning between-sample coverage SD .02, the MCSE is .00177 at B=128; this is an
assumption, not guaranteed precision. Retain uncertainty rather than adding
replications until a criterion passes.

Report own-available and paired-available coverage, width, bias, RMSE (sqrt of
mean MSE), mean posterior SD, extreme-total rate and ability strata. Use
calibration-cluster ratio MCSEs and t(B-1) intervals, reusing `pec_cluster`.
Compute paired differences before their MCSE; RMSE-difference uncertainty uses
the paired delta method. Retain oracle-all/paired results, availability and
all-attempt available-and-covered rates, numerical conflicts, fit/scoring
readiness and estimated population means/SDs. The skewed-condition normal mean/
variance fits need not target its generating moments under misspecification;
do not label their differences as ordinary consistent-estimator bias.

These plug-in intervals condition on estimated calibration AND population
parameters. Repeated samples assess the consequence of omitting their estimation
uncertainty; the intervals do not thereby gain that uncertainty. A descriptive
coverage interval wholly in [.93,.97], paired availability lower bound >=.95,
complete assigned counts and zero numerical conflicts can support only a
bounded in-cell numerical/sampling conclusion, never ordinary scoring approval.
No one expects nominal coverage at each fixed true ability.

Seeds: preflight 124000000+10000*cell+replicate; main
134000000+10000*cell+replicate; each new cohort uses calibration seed+2000.
Check all IDs unique/disjoint. Freeze source/package identity, save every
attempt atomically, resume only the same payload, and allow at most three local
R processes owning disjoint cells. Review preflight timing before main execution.
No production implementation change is prespecified. The earlier 80,000-dataset
population-parameter interval protocol is a separate, unexecuted main study.

## Prospective numerical amendment after the Q121 preflight

The initial 48 samples / 96 fits completed without native convergence or
availability failures. One of 32 independently checked fits (PCM, N=320,
wide population, replicate 1) exceeded the fixed native/reference gradient
agreement limit: 1.212499e-7 versus 1e-7. It is retained as a failed check.
At the same parameters Q241 and Q321 gradients agree within 1.6e-13;
Q241 agrees with the specified 1.25e-5 independent derivative within 5e-9.
Thus the conflict is Q121 approximation of the variance-coordinate gradient.
An attempted Q481 check was correctly rejected because not all GH weights
are representable as positive finite doubles; its error log is retained.
No weight clipping or zero replacement is introduced.

Before any main sample is generated, replace fitting/scoring Q121 by Q241
and its higher-order comparison Q241 by Q321, keeping every error threshold,
condition, replication count, seed and availability rule unchanged. Refit
all 48 preflight samples with the higher order and rerun the checks. These
are numerical re-evaluations of the same samples, not 48 additional independent
samples. The original Q121 runner, protocol, payload and outcomes are archived
separately. Only the amended preflight can qualify the main study.
