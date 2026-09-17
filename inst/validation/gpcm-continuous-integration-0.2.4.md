# GPCM integration accuracy and refitted-parameter stability

Date: 2026-09-15. Follow-up to the
[paired-owner kernel audit](gpcm-paired-owner-kernel-0.2.4.md), for C04.
Repository numerical evidence; no production code, defaults or inference
eligibility rules were changed.

## Questions and answers

The preceding audit found matching implementations but large changes in
fixed-grid likelihoods. Does raising the quadrature order approach an
independent continuous integral? Do actual refitted parameters stabilize?

These require separate answers. At the earlier wide-slope finite points,
**neither fixed nor adaptive Q301 is uniformly accurate**. At the returned
solutions for the four moderate-slope generated datasets studied here,
**adaptive Q61 meets the numerical comparison criteria in all four cases**,
and adaptive Q31→Q61 parameter changes are small. Fixed-grid fitting remains
materially sensitive in the weighted sparse datasets even at Q301.

All 24 public fits have optimizer code zero and terminal gradient below
1e-4. Only six meet all continuous-reference comparison criteria: the four
adaptive-Q61 fits, complete/Criterion adaptive Q31, and complete/Criterion
fixed Q301. Optimizer convergence therefore does not certify integration
accuracy. None of the 24 fits is inference-ready, and none makes free-slope
confidence intervals eligible.

## Reference and scope

The [runnable audit](gpcm-continuous-integration-0.2.4.R) reuses the independent
parameter expansion and raw-label indexing from the paired-owner audit,
and the continuous integrator from
[adaptive quadrature review](adaptive-quadrature-review-0.2.4.R). The reference
expresses weighted category logits and the normal prior separately from the
production probability and quadrature implementations. Owner locations are
included in the transition boundaries, and the other facet contributes its
nonzero severity, for both possible owners.

For each Person, `stats::integrate()` operates around an independently located
posterior mode, with local curvature scaling. Both halves of the interval
are integrated. The reference is repeated at local limits ±32 and ±64;
log marginal, EAP and posterior SD must change by less than 1e-8. The refined
mass-integral error estimate must be below 1e-9 relative to mass, and a
log-concavity tangent bound on omitted mass must be below 1e-12 relative to
mass. All reference checks pass. The integration error estimate is not an
interval-arithmetic proof; posterior moment tails are checked through range
refinement, not certified by a separate moment-tail bound.

Comparisons use the earlier adaptive-audit numerical tolerances: absolute
total NLL error below 1e-7, maximum Person EAP error below 1e-7, and maximum
posterior-SD error below 1e-7, all with a qualified reference. These are
implementation comparison tolerances, not empirical bias/coverage criteria
or a universal recommendation of any quadrature order.

## Fixed-parameter stress: 120 distinct case/rule evaluations

The twelve previous MML points are unchanged: three datasets × two owners ×
two slope vectors. Each has 12 Persons and five categories. The wide vector
has relative slopes about 0.0498–20.085; the moderate vector and nonzero
facet/step effects retain their original values. The original investigation
used fixed Q31/Q61/Q121/Q181/Q301 and adaptive Q31/Q61/Q121. After the adaptive
Q121 discrepancies were observed, a recorded follow-up added adaptive
Q181/Q301. Its repeated fixed-Q301 control is excluded from the distinct
evaluation count. No originally unsuccessful comparisons were discarded.

| Rule | Largest absolute total NLL error across 12 points | Largest Person EAP error | Points meeting all criteria |
| --- | ---: | ---: | ---: |
| Fixed Q31 | 59.269 | 0.3270 | 0/12 |
| Fixed Q121 | 15.323 | 0.1551 | 0/12 |
| Fixed Q301 | 3.714 | 0.08674 | 2/12 |
| Adaptive Q31 | 0.06439 | 0.005764 | 6/12 |
| Adaptive Q61 | 0.01610 | 0.001019 | 6/12 |
| Adaptive Q121 | 0.003247 | 0.0002573 | 8/12 |
| Adaptive Q181 | 0.0007204 | 0.00009819 | 10/12 |
| Adaptive Q301 | 0.0001411 | 0.00001290 | 10/12 |

All six moderate points meet the adaptive criteria from Q31 onward. The
two remaining adaptive-Q301 failures are the Criterion-owned wide-slope cycle
and Rater-owned wide-slope weighted bridge. The latter misses the total-NLL
criterion narrowly (about 1.070e-7); both are retained as failures. The worst
wide-slope discrepancy cannot be described as ordinary rounding error.
These fixed points are not estimated solutions and do not measure recovery.

All current Q31/Q61/Q121/Q181/Q301 rules retain positive weights; the smallest
Q301 weight is 1.242e-249. Thus these discrepancies persist after the earlier
zero-weight repair and cannot be attributed to discarded zero weights here.

## Public refits: four datasets, six paired arms each

Each dataset has 60 independently generated normal abilities and five-category
responses sampled with the pre-existing independent complete-predictor kernel.
The moderate slope vector, nonzero facet/step values, population mean 0.35
and SD 1.3 are recorded in each input RDS. Seeds are 20260916 for Criterion
ownership and 20260917 for Rater ownership. Within each owner the sparse
dataset is a subset of the complete generated responses, so the designs are
paired, not independent replicates.

The complete design has 960 unit-weight rows. The sparse design has 486 rows:
two 2×2 Rater/Criterion blocks observed for all Persons, plus one bridge edge
observed for six Persons. Weights 0.25, 1, 3 and 8 give total weight 1483.5.
Persons occur in both blocks. The weights enter the response likelihood;
this is a numerical weighted-likelihood stress case, not a survey-weight
validation or a recovery experiment under an asserted weighted sampling model.

Each exact dataset is fitted with fixed Q31/Q61/Q121/Q301 and adaptive Q31/Q61,
using the public direct MML route, default free normal population, default
optimizer/initialization, `maxit = 400` and `reltol = 1e-10`. There are no
hand-picked successful seeds, post-run restarts or added optimizer ceilings.
Public optimizer stages remain in the saved fits. The following errors are
against continuous integration **at each arm's own returned parameters**.

| Refit rule | Maximum absolute total NLL error | Maximum Person EAP error | Maximum posterior-SD error | Passing arms |
| --- | ---: | ---: | ---: | ---: |
| Fixed Q31 | 3.261 | 0.2920 | 0.1798 | 0/4 |
| Fixed Q61 | 2.756 | 0.2322 | 0.1424 | 0/4 |
| Fixed Q121 | 1.621 | 0.1345 | 0.09406 | 0/4 |
| Fixed Q301 | 0.2606 | 0.04500 | 0.05153 | 1/4 |
| Adaptive Q31 | 5.156e-6 | 8.694e-6 | 2.174e-6 | 1/4 |
| Adaptive Q61 | 2.571e-9 | 3.550e-8 | 5.399e-8 | 4/4 |

Parameter comparisons have a different purpose: they assess changes in the
estimated calibration across arms, with the identification held constant.
Across the four adaptive Q31→Q61 pairs, the largest change in a free coordinate
is **1.431e-6**, in an expanded slope **6.969e-7**, and in population SD
**1.218e-6**. The largest native EAP change is 7.152e-6. Scoring both parameter
sets with the common continuous reference reduces the largest EAP change to
1.764e-6, separating scoring integration error from calibration change.

By contrast, fixed Q31→adaptive Q61 changes an expanded slope by as much as
0.5205 and population SD by 0.4923; the maximum common-continuous EAP change
is 0.7038. Even fixed Q301→adaptive Q61 leaves common-continuous EAP changes
of about 0.09139 and 0.1548 in the two sparse datasets. The complete datasets
have much smaller Q301/adaptive-Q61 differences. These paired differences
are observations, not frozen scientific equivalence thresholds. No finite
collection of starts establishes a global optimum.

## Verification and retained evidence

The point/reference qualification and complete-accounting checks pass, and
the existing adaptive-quadrature-review test passes **101 expectations** with
zero failures, errors, warnings or skips. The four adaptive-Q61 solutions also
receive an independent central-difference check of the continuous NLL, using
step 5e-5 and the preceding adaptive-audit absolute gradient tolerance 1e-5.
All **92 coordinates pass**, with maximum analytic/reference gradient
discrepancy **1.076e-6**. The full comparison is retained in
`continuous-gradients.csv`. A fresh verification also checks the saved fits'
input rows, weights, model/owner and integration settings, plus all 24 paired
parameter/score comparisons.

Evidence archive: `validation-results/gpcm-continuous-integration-20260915/`.
It contains all 24 fits, four generated inputs and truths, all per-Person
references at both integration limits, the initial and higher-order point
results, paired parameter/score comparisons, test logs, source snapshots and
a SHA-256 manifest. There is one macOS execution, not a new platform matrix.
No production package source changed; this does not replace the earlier
`R CMD check` checkpoint. All 317 R/src/man files are byte-identical to the
[preceding checked package](estimator-output-identity-repair-0.2.4.md).

Reproduction from the development root:

```r
pkgload::load_all()
source("inst/validation/gpcm-continuous-integration-0.2.4.R")
previous <- "validation-results/gpcm-paired-owner-kernel-20260915"
out <- "/tmp/gpcm-continuous-replay"
run_gpcm_continuous_points(previous, file.path(out, "points"))
run_gpcm_continuous_points(previous, file.path(out, "points-higher"),
                           fixed_orders = 301L, adaptive_orders = c(181L, 301L))
run_gpcm_continuous_refits(file.path(out, "refits"))
summarize_gpcm_continuous_audit(out)
verify_gpcm_continuous_gradients(out)
```

C04 remains open. These results support adaptive Q61 for the four recorded
retained solutions, not every dataset or slope magnitude. Higher-order
integration, finite/global boundary behavior, recovery and uncertainty are
separate checks. GPCM slope SE/CI remain ineligible; no statistical readiness
or release approval follows from these numerical results.
