# RSM/PCM population-variance profile review

Date: 2026-09-10. Status: bounded review complete; original design retained in
the main archive. Results distinguish finite-grid optimization from continuous-
integral agreement. No production inference restriction is relaxed.

## Question and design

Does the interior population variance in the two retained RSM/PCM latent-
regression examples outperform the zero-variance limiting model after nuisance
refitting? Does that conclusion persist when variance is large and quadrature
becomes more demanding? Can the same procedure preserve the known ambiguity
in the singly rated binary control and the information in its paired control?

Reuse the four fitted objects in the
[identification review](population-identifiability-review-record-0.2.4.md):
two 80-Person, six-rating latent-regression datasets and two deterministic
100-Person binary controls. No new response data or coverage simulation.

For each case fix variance at 0, 1e-6, .01, .1, .3, .5, 1, 2, 4, 16, 64, and
the previously fitted variance, sorted without duplication. At each positive
value run q61 and q121 independently from the retained nuisance vector and
the all-zero nuisance vector. At variance zero use q1 from those two starts.
This is 184 nuisance optimization rows. Starts are not selected using profile
results and no warm-start path is substituted for an independent start.

Reuse `mfrmr_gzb_p1c_optimize_boundary()` as the existing fixed-coordinate
nuisance optimizer, with a wrapper fixing the declared variance in the
objective/gradient. Preserve its L-BFGS-B/polish/BFGS stages, maxit 400,
reltol 1e-12, warnings/errors and native gradient criterion. The wrapper
returns the actual fixed variance, not the boundary helper's dummy coordinate.
Do not edit the historical helper or use its historical GPCM decisions.

At zero, q1 has node zero and weight one and exactly evaluates
`L_p(mu_p; nuisance)` for each Person. For fixed finite nuisance parameters,
bounded continuous response likelihoods justify that zero-variance limit.
Check the value against direct conditional probabilities and verify invariance
to the unused finite log-variance placeholder. This fixed-nuisance limit does
not license interchange of a limit and arbitrary nuisance optimization.

At every returned vector evaluate q241 and an independent whole-line integral
(direct conditional evaluation at zero). Retain objective discrepancies and
q241 nuisance gradients. For the lower finite q121 objective across starts
(q1 at zero), also differentiate the independent objective in nuisance
coordinates at relative steps 1e-4 and 5e-5. Keep the original numerical
comparison bounds: absolute objective difference 1e-6, derivative agreement
1e-7, nuisance gradient 1e-4. These are local diagnostic bounds, not new package
or sampling-precision cutoffs. Disagreements remain recorded and do not stop
the other rows or cause bounds to be loosened.

At the chosen zero-variance nuisance vectors evaluate the one-sided fixed-
nuisance path at variances 1e-6, 1e-5 and 1e-4. Record difference quotients;
do not label them a global derivative of the optimized profile. For the
singly rated control, independently solve the exact `.3/.7` marginal ridge
at each variance and compare its objective with the saturated Bernoulli bound.
The paired control's saturated multinomial bound is an additional comparator,
not an assumed property of every variance point.

Retain all returned vectors, optimizer stages, source/input identities and
original flags. Report a lower finite multistart envelope as a diagnostic
profile; neither two starts nor a finite high-variance endpoint proves global
optimality or a limit at infinite variance. Do not derive chi-square profile
intervals, a variance cutoff, or release approval from these examples.

## Targeted refinement, fixed after the main run

The 184-row run completed before this addition. All native nuisance checks
passed, but independent continuous-integral checks exposed discrepancies at
large variance. Preserve the main run unchanged. For all four cases, refit
variance 16 and 64 using q481 and q961 and the same two independent starts
(32 additional rows). The singly rated variance-16 point is an agreement
control. Evaluate q1921 and the independent integral at every returned vector;
differentiate the independent objective at each selected q961 vector using
the original step ladder and compare with q1921. Keep all original numerical
bounds. Stop this refinement at these grids even if discrepancies remain.
This is a targeted numerical follow-up selected after inspection, not a new
prespecified statistical validation study or a change to production defaults.

## Main results

All 184 rows returned with native nuisance convergence passing, no errors and
no warnings. Nevertheless 34 rows failed the independent objective comparison.
Of the 48 selected q1/q121 vectors, 41 met all continuous-nuisance checks; seven
did not (RSM/PCM/paired at 16 and 64, single at 64). The independent derivative
step comparisons were stable even at the failing points. The q61 envelope rows
have no independent derivative audit: their `FALSE` qualification flags mean
not evaluated, not 44 additional independent-derivative failures.

| Case | Best variance among qualified grid points | Negative log likelihood | Zero-variance excess negative log likelihood |
| --- | ---: | ---: | ---: |
| RSM latent regression | 0.6739621 | 464.08577 | 18.39778 |
| PCM latent regression | 0.5824963 | 479.85605 | 17.18519 |
| Paired binary control | 1.5615326 | 120.22623 | 1.946635 |
| Singly rated binary control | All variances have an exact equivalent ridge | 61.08643 | 0 |

The fitted interior values were explicitly included in the grid. These are
bounded profile comparisons, not a new exhaustive search or boundary-test
p-values. At zero, all eight returned vectors match direct conditional
evaluation and are invariant to the unused log-variance placeholder. The
fixed-nuisance one-sided difference quotients approach about -129.19, -133.10
and -4 for RSM, PCM and paired data, respectively. Thus moving away from zero
improves the likelihood even before nuisance adjustment at these selected
vectors. This does not replace a global boundary proof.

The single-rating control attains its saturated Bernoulli likelihood along
the independently solved variance/difficulty ridge, including exactly zero
variance. The mathematical ridge argument in the preceding identification
review extends beyond the sampled grid. Numerical rounding must not turn a
flat likelihood into an apparently preferred variance. The paired fit reaches
its saturated multinomial bound to numerical precision at the retained
interior variance, but variance zero and the other evaluated variances fit
less well. Pairing supplies information about between-Person variation that
separate marginal proportions do not provide.

Native convergence and agreement between starts are insufficient accuracy
checks. PCM at variance 16 with q61 has two converged nuisance solutions whose
negative log likelihoods differ by 0.74649. At q121 their objectives agree
across starts, but the selected vector still fails continuous-integral checks.
In the q121 large-variance rows, independent nuisance-gradient norms reach
0.12033/0.59367 (RSM, variances 16/64) and 0.06039/3.22680 (PCM). Differences
between the two finite-difference steps remain below 1e-7, identifying
quadrature mismatch rather than an unstable independent derivative calculation.

## Refinement result and interpretation

All 32 additional rows returned with native convergence passing, no errors and
no warnings. At variance 16, all four selected q961 vectors meet the unchanged
continuous-nuisance criteria. At variance 64, the single and paired controls
also qualify, but RSM and PCM do not. Thus six of eight selected vectors
qualify. The q481 rows are value-checked but have no independent derivative
audit; the archive keeps these unassessed fields distinct through `Q` and `NA`.

| Selected q961 vector | Native minus continuous negative log likelihood | Independent nuisance gradient norm | Qualified |
| --- | ---: | ---: | --- |
| RSM, variance 16 | about 3.1e-12 | 7.907e-8 | Yes |
| PCM, variance 16 | about 3.2e-12 | 6.776e-7 | Yes |
| RSM, variance 64 | -4.956e-5 | 4.475e-4 | No |
| PCM, variance 64 | 1.526e-4 | 1.580e-3 | No |

For the two unqualified q961 vectors, q1921 value differences from the
independent integral shrink to approximately -4.166e-9 and 1.569e-8. However,
evaluating a returned vector more accurately does not reoptimize it. Its
continuous nuisance gradient still exceeds 1e-4, and the PCM q1921-versus-
independent derivative difference (5.214e-7) also exceeds the unchanged 1e-7
bound. No further grid increase or tolerance adjustment was made. These are
retained finite-vector comparisons, not accepted high-variance profile optima.

The supported answer is therefore specific: the two latent-regression examples
prefer the included positive interior variance over the exact-zero fits;
the unpaired control is truly unidentified; and large-variance numerical
accuracy requires a separate check even when optimizer convergence and starts
agree. This separates identifiable structure from numerical accuracy, but it
does not establish a global optimum, the infinite-variance limit, general
population-model SE calibration, or a universal safe variance/grid cutoff.

## Evidence, verification and next work

The main execution took 117.842 seconds; the targeted refinement took 194.994
seconds (about 5 minutes 13 seconds combined, excluding tests and reporting).
These 216 optimizations reuse four datasets and are not 216 statistical
replications. All original failures remain in the
[row summary](population-variance-profile-summary-0.2.4.csv),
[main archive](population-variance-profile-evidence-0.2.4.rds) and
[refinement archive](population-variance-profile-refinement-evidence-0.2.4.rds).
The archives retain every returned vector, optimizer stages, warning/error
lists, independent derivatives, plans, source identities/snapshots and timings.
The refinement input hash matches the unchanged main archive byte for byte.

The [replay checker](population-variance-profile-check-0.2.4.R) checks all 216
fixed-variance coordinates, the exact-zero/direct-evaluation agreement, the
analytical ridge, the interior improvements and source/input identity. It
also regenerates the [four-panel profile figure](population-variance-profile-0.2.4.png),
whose hollow points explicitly retain unqualified numerical solutions.
The [test table](population-variance-profile-tests-0.2.4.csv) and
[execution log](population-variance-profile-execution-0.2.4.log) retain focused
helper and documentation checks: 887 passing expectations, zero failures,
errors or warnings, and one intentional skip. The historical four-scenario GPCM boundary
stress test remains opt-in and was not run as part of this RSM/PCM review.

Reproduce from the package root into fresh output directories:

```sh
Rscript inst/validation/population-variance-profile-0.2.4.R /tmp/population-profile-replay
Rscript inst/validation/population-variance-profile-refinement-0.2.4.R /tmp/population-profile-replay/evidence.rds /tmp/population-profile-refinement-replay
Rscript inst/validation/population-variance-profile-check-0.2.4.R
```

The first two commands perform fresh numerical runs without replacing the
dated evidence. The last checks the retained archives and regenerates their
figure. Preserve source identities when comparing a later revision.

Next define how exact nonidentification, local rank, boundary behavior and
independently qualified numerical solutions should constrain population-model
output eligibility. Use these failures as negative controls, and review
structural-SE integration accuracy before selecting missing recovery/coverage
studies. Keep population restrictions, Person-score precision, joint
Wald/equivalence calibration, full GPCM and JML questions separate. No production
code, threshold, default grid or historical evidence was changed by this review;
the broader release review remains open. A full package/OS release check was
not repeated.
