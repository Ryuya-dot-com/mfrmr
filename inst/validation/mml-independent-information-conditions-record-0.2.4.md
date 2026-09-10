# Independent RSM/PCM information under additional conditions

Date: 2026-09-09. Status: all 13 repaired-source numerical fixtures passed;
the initial anchored-contrast restriction defect was repaired. C05 and
release review remain open. The design and numerical criteria below were
fixed before the initial execution.

## Question and design

Do the RSM/PCM marginal objective, score, observed information and reported
structural SEs agree with a separately written likelihood when thresholds,
population regression, constraints, interactions or row weights change?
This extends the [first RSM pilot](mml-independent-rsm-information-record-0.2.4.md).
It addresses numerical correctness, not repeated-sampling coverage or TAM
equivalence. Publicly suppressed population-parameter SEs are not promoted.

The runner uses 80 Persons, three Raters, two Criteria and six ratings per
Person. Each of RSM and PCM has six fixtures: baseline, population regression,
direct anchor, group-mean anchor, interaction and non-unit row weights. One
additional PCM baseline uses four categories instead of three, exercising
multiple free thresholds per Criterion. There are 13 fixtures, with seeds
20260910 through 20260922 fixed by row order (RSM six, PCM six, PCM four-category).
They are numerical examples, not independent recovery replications.

Unanchored Rater effects are `(0.3, -0.1, -0.2)` and Criterion effects
`(0.4, -0.4)`. The direct-anchor case fixes R1 at 0.25 and centers the remaining
effects `(0.2, -0.2)` separately, matching the documented/source constraint
convention rather than assuming that all three effects sum to zero. The group
case constrains the R1/R2 mean to 0.1, uses `(0.3, -0.1)`, and fixes the single
ungrouped centered R3 at zero. Both leave one free Rater coordinate.
Three-category RSM thresholds are `(-0.6, 0.6)`; PCM thresholds are
`(-0.7, 0.7)` and `(-0.2, 0.2)`. The four-category PCM ladders are
`(-0.8, 0.1, 0.7)` and `(-0.3, -0.2, 0.5)`.

Population regression uses `theta ~ N(0.2 + 0.5*x, 0.7)`, with 80 fixed x values
equally spaced from -1 to 1; other fixtures use standard normal Persons.
The interaction has first-Criterion effects `(0.15, -0.1, -0.05)` and their
negatives for the second Criterion, with zero row and column sums. The weight
fixture cycles `(0.5, 1, 1.5, 2)` over response rows and checks powers of
conditional probabilities *inside* each Person integral. Those powers are
not Person-frequency weights, and this fixture makes no sampling-SE claim.
With this row ordering each Person has the same weight on all six ratings;
within-Person heterogeneous weights are not covered by this example.

The reference constructs category logits and all coordinate maps explicitly.
It integrates observed pattern probabilities against the normal density on
the whole real line with base R `integrate()`, using relative tolerance 1e-11,
absolute tolerance 1e-13 and at most 200 subdivisions. It reuses only the
previous pilot's central-difference helper, with steps 0.001 and 0.0005;
package probability, constraint, quadrature, gradient and covariance routines
are used only on the package side of comparisons. Fits use q61, maxit 200,
reltol 1e-10 and the direct MML engine.

## Checks fixed before results

- Absolute objective difference below 1e-6.
- Hessian step change and package difference below 1e-5 after dividing by
  `max(1, max(abs(reference_H)))`; additionally each entry difference divided
  by `max(1, sqrt(abs(H_ii * H_jj)))` below 1e-5.
- Maximum absolute score difference below 1e-5. Score at the fitted point is
  recorded separately; agreement alone does not prove stationarity.
- Unregularized package covariance and positive-definite reference Hessian;
  each covariance entry difference scaled by `sqrt(V_ii * V_jj)` below 1e-5.
- Relative free-coordinate, expanded facet/step and pair-contrast SE
  differences below 1e-5; zero-variance fixed coordinates checked absolutely
  to 1e-10. Explicit maps must reproduce point estimates to 1e-10.
- Retain fit readiness, public formal-inference status, warnings, failures and
  equivalence availability. Check public contrasts where available, and
  preserve the singular-target refusal for anchored/group-constrained Raters.

These are numerical fixture criteria, not calibrated release thresholds.
Save each fit, data, coordinate map, both Hessians, complete covariance and
comparison results before adjudicating it. A failure is retained and reviewed;
it is not removed by changing seeds, tolerances or grids. Any subsequent
higher-grid investigation is a separately labeled diagnostic.

## Initial failure and correction

The first execution passed 12 fixtures and failed the PCM direct-anchor
fixture's required refusal. Its three Rater levels had one free coordinate:
the explicit Rater Jacobian was `(0, 1, -1)'`. There cannot be two independent
joint contrasts. Nevertheless, floating-point Cholesky decomposition
succeeded for the computed covariance and the previous implementation
returned an equivalence bundle, including a joint Wald p-value of zero.

An exact refit reproduced the failure. The two contrast-covariance
eigenvalues were approximately 0.03817204 and 1.186e-20, and the second
Cholesky diagonal was 2.634e-9. These tiny positive values are roundoff in a
mathematically rank-one matrix, not an additional estimable direction.
The bundle declared all three pairs equivalent at bound 0.5. The defect is
the admission of a singular joint comparison; this observation by itself
does not show that each separate pairwise SE or TOST calculation is wrong.

`analyze_facet_equivalence()` now checks the rank of the contrast Jacobian
before interpreting the covariance factorization. The shared bundle validator
also requires that rank check to have been recorded, so summary, print and
plot cannot reuse a bundle made without it. The same stored failing fit is
now rejected, and its pre-repair bundle requires recomputation. A packaged
regression checks a directly anchored, centered facet with fewer free
directions than joint contrasts, alongside the existing eligible fixed-anchor
example with sufficient free directions. No likelihood or estimator formula
was changed.

The initial runner raised an assertion on that refusal before returning its
otherwise computed matrices; its first case artifact therefore records the
error rather than those matrices. The separate exact reproducer preserves
the fit, erroneous bundle, Jacobian and covariance. The successor runner
records refusal checks alongside numerical checks before adjudication, so
such failures retain the computed case. The same 13 seeds and tolerances
were replayed after the repair, with original results preserved. The 12
initially completed fixtures reproduced their numerical metrics exactly.

## Results and next decision

All 13 fixtures passed their numerical and refusal checks after repair, with
no warnings or errors. The [metrics CSV](mml-independent-information-conditions-metrics-0.2.4.csv)
preserves the initial and repaired stages; they are repeated checks of the
same 13 fixtures, not 26 independent statistical replications.

| Maximum discrepancy across the repaired fixtures | Magnitude |
| --- | ---: |
| Absolute negative-log-likelihood difference | 4.945e-7 |
| Normalized Hessian step change | 2.218e-6 |
| Normalized package/reference Hessian difference | 1.467e-7 |
| Hessian entry difference scaled by diagonal information | 3.024e-7 |
| Absolute score-vector difference | 7.663e-6 |
| Covariance entry difference scaled by reference marginal SDs | 3.960e-7 |
| Relative SE difference across all free coordinates | 1.980e-7 |
| Relative reported facet/step SE difference | 1.170e-7 |
| Relative pair-contrast SE difference | 1.170e-7 |

Every explicit facet/step point-coordinate map matched exactly, as did the
zero SEs for fixed coordinates. All 52 computed pair SEs agreed with the
independent covariance; 32 also had available public equivalence results
and agreed there. The remaining 20 public pair rows were unavailable: 12
belonged to four singular anchored/group-constrained Rater targets, and
eight to the two population-regression fits. Both population fits retained
`design_rank_not_evaluated` and formal inference was false. Their internal
covariance agreement does not upgrade readiness or expose population SEs.

The weighted fixtures retained formal-inference eligibility in the current
API. This execution validates their powered conditional objective and its
curvature only. Whether that inverse Hessian is a sampling covariance for
a stated weighting design still requires a separate support decision; it
cannot be inferred from these numerical matches. Likewise, the maximum
absolute independent score at the fitted points was 8.270e-5. The fixture
checks compare calculations at those points, not independently optimized
parameter recovery or a universally adequate stationarity threshold.

The case-time totals were 280.747 seconds initially and 279.355 seconds on
replay (about 4 minutes 40 seconds each), excluding R startup and package
loading. The expensive part is whole-line integration at perturbed parameter
vectors; ordinary equivalence recalculation does not repeat this reference
validation. No numerical criterion, seed or quadrature order was changed
after the initial results, and no higher-grid diagnostic was needed here.

These results support numerical information calculations in the stated small
RSM/PCM fixtures. They do not establish empirical SE-versus-SD agreement,
coverage, sparse/long-response behavior, wider interaction/anchor structures,
within-Person heterogeneous weighting, GPCM/JML validity or additional TAM
equivalence. Next prespecify repeated-sampling SE/coverage under the eligible,
correctly specified unit-weight RSM/PCM model and separate the remaining
population/weight support questions. Release remains on hold.

## Reproduction and retained evidence

From the package root:

```sh
Rscript inst/validation/mml-independent-information-conditions-0.2.4.R /tmp/mml-information
```

The [runner](mml-independent-information-conditions-0.2.4.R) writes per-case
RDS files, metrics and source fingerprints. The compact
[evidence archive](mml-independent-information-conditions-evidence-0.2.4.rds)
retains both stages, the exact failing-fit/bundle reproducer, repaired-source
fingerprints and test logs. Each completed case contains its data, fit,
explicit coordinate map, both reference Hessians, full reference/package
covariance, scores and pair/expanded-coordinate results. Read it with
`readRDS()`; top-level entries are `initial`, `repaired`, `rank_reproducer`,
`source_md5` and `checks`. Its metrics and covariance matrices were verified
after serialization. The first failing case's saved error and separate
reproducer remain distinguishable from the repaired result.

Execution used R 4.6.1 on the local aarch64 Mac and working-source mfrmr
0.2.4.9000, base commit `df609a30a2dc8ec226d6acdca2fbf963fe502ee6`, with the
uncommitted facet-equivalence corrections. All repaired-run R-source and
runner fingerprints matched the retained files when the archive was made.

## Documentation and regression checks

The population help incorrectly said that no population-parameter Hessian
was extracted. Its source and generated Rd now distinguish the internal
joint covariance calculation from the public coefficient/variance tables,
which do not expose population SEs or Wald inference. Parsing the estimation
source without comments gives the same expressions as the base commit; this
edit changes documentation only.

The facet-equivalence, CI-alias and S3 tests passed 470 expectations with no
failures, warnings, errors or skips. Documentation terminology and example
policy passed another 234 expectations, and the edited Rd passed `checkRd()`.
The final constrained-facet regression replay passed 71 expectations, and
the roadmap checks passed 54; these reruns are not additional statistical
replications.
The original three-coordinate RSM pilot was rerun after extracting its
central-difference helper and reproduced its original metrics exactly.
The earlier full package check precedes this contrast-rank repair and is not
a check of the latest source. Final release checks remain part of the
roadmap after statistical/support questions close.
