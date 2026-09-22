# Draft.83d2b2b1g15a Monte Carlo value and precision audit contract

Status: completed repository-only, response-free purpose/precision audit,
2026-08-10. This contract answers whether the planned simulation volume is
proportionate to its stated purpose. It does not authorize execution, change a
seed, generate a response, or convert calibration into broad validation.

## Why the large row counts are misleading

The scientific Monte Carlo unit is one independently generated
`scenario x replicate` dataset. Four methods share that dataset, both model
roles reuse it, and multiple optimizer profiles, candidate rules, and
high-accuracy references are evaluated on it. Those rows are dependent
computational work, not additional simulation replications.

The calibration workload therefore has:

| Quantity | Count | Independent Monte Carlo replications? |
| --- | ---: | --- |
| datasets | 3,000 | yes, but only 100 within each scenario |
| candidate fits | 108,000 | no |
| candidate decisions | 576,000 | no |
| high-accuracy references | 24,000 | no |

There are 36 candidate-fit rows, 192 candidate decisions, and eight reference
problems per independent dataset. Thus the independent-dataset count is only
`1/36` of the candidate-fit count. Calling this a 108,000-replication study
would be mathematically incorrect.

## Why there are 30 scenarios

The 30 cells are a compact `5 design x 6 target-variance region` factorial,
not an unrestricted grid. The designs deliberately separate:

- baseline complete allocation;
- a two-Rater/two-criterion few-level design;
- a 300-Person, eight-Rater high-information design;
- a sparse connected-cycle allocation; and
- a strongly imbalanced connected-hub allocation.

They vary Persons, Raters, criteria, observations per Person, assignment
density/topology, workload balance, and six Rater-variance regions from exact
zero through 0.12. This is appropriate for the narrow observed-score
G-theory stationarity question. It is not a GPCM category-count, missingness,
local-dependence, anchor, DFF, or general sample-size study; those axes belong
to separate estimator-specific designs.

## What 100 replications can establish

Calibration uses 100 planned independent datasets in each scenario. If all
100 high-accuracy references in a primary
`scenario x method x model-role` cell resolve, then:

| Quantity | Complete-denominator value |
| --- | ---: |
| worst-case Bernoulli MCSE | 0.050000 |
| MCSE when the event rate is 0.05 or 0.95 | 0.021794 |
| MCSE when the event rate is 0.80 | 0.040000 |
| one-sided 95% upper bound after 0/100 events | 0.029513 |
| probability of at least one event if the true rate is 0.03 | 0.952447 |
| probability of at least one event if the true rate is 0.02 | 0.867380 |
| probability of at least one event if the true rate is 0.01 | 0.633968 |

This gives the 100-replication phase a defensible but narrow role: reject
candidate numerical-stationarity rules that produce observed safety errors,
rank the prespecified 24 candidates, and allow a completed negative result if
none passes. A true 3% safety-event rate has about a 95.2% chance of appearing
at least once in one complete cell. Zero events still do not mean zero risk.

The 3% event rate, 3% complete-denominator upper-bound benchmark, and 95%
detection-probability benchmark are frozen only for this response-free
*execution-value audit*. They do not enter the b1g11 candidate ranking, change
its zero-observed-safety-event rule, or become a production tolerance.

The 2.95% exact upper bound is a *complete-denominator planning value*, not
achieved evidence. Reference-unresolved rows are retained but excluded from
binary denominators. If a cell has fewer than 100 resolved trials, its actual
upper bound and MCSE must be recomputed from that smaller denominator, and the
calibration may be noninformative. It may not borrow observations from another
scenario, method, or model role.

## What 100 replications cannot establish

At a 95% coverage rate, the complete-denominator MCSE is approximately 2.18
percentage points. Consequently, 100 replications cannot precisely distinguish
95% from nearby coverage values such as 93% or 97%. At 80% power the MCSE is
four percentage points. Bias, RMSE, empirical SE, rank recovery, facet
separation, and continuous D-study stability additionally depend on their
empirical between-replication variances and need metric-specific precision
targets.

For orientation, simple fixed-n binomial planning gives:

| Performance probability | n for MCSE <= 0.01 | n for MCSE <= 0.005 | n for approximate 95% half-width <= 0.01 |
| ---: | ---: | ---: | ---: |
| 0.05 or 0.95 | 475 | 1,900 | 1,825 |
| 0.80 | 1,600 | 6,400 | 6,147 |
| 0.50 | 2,500 | 10,000 | 9,604 |

These are planning illustrations, not universal requirements. A future
operating-characteristic study must choose tolerable MCSE separately for
bias, RMSE, coverage, convergence, ranking, separation, and D-study outputs,
then use pilot variance estimates where the performance measure is continuous.
It cannot inherit `n=100` merely because the numerical calibration used it.

## Why confirmation remains necessary

One of 24 candidate family-zone rules is selected on the calibration data.
The cellwise exact-binomial bounds therefore have no unqualified
post-selection 95% coverage interpretation. The independent confirmation band
contains 200 planned replications per scenario. Under a complete denominator,
0/200 gives a one-sided 95% upper bound of 0.014867, but that value is also only
a plan until the frozen candidate is applied and actual resolved denominators
are known.

Calibration cannot read confirmation, and candidate selection cannot be
changed after confirmation begins. Completing calibration does not itself
authorize confirmation.

## Efficiency already built into the design

The present plan avoids several forms of waste without changing its
denominator:

- all four methods use common generated datasets, enabling paired contrasts;
- 24 candidate rules reuse fitted diagnostics rather than refitting per rule;
- high-accuracy references are computed once per method and model role rather
  than once per candidate;
- exact-resume checkpoints avoid repeating completed work; and
- the 30 scenarios are a targeted five-by-six factorial rather than a broad
  combinatorial grid.

Paired methods can make method contrasts more precise, but the paired MCSE
depends on discordant probabilities

\[
  \operatorname{MCSE}(\hat p_1-\hat p_0)=
  \sqrt{\{p_{10}+p_{01}-(p_{10}-p_{01})^2\}/n}.
\]

It must be estimated and reported; pairing does not turn four methods into
four independent replications.

Outcome-dependent early stopping is not an acceptable saving because the
same data select among candidates. Operational interruption and exact resume
remain allowed, but no scientific result may be viewed to decide whether the
remaining shards should run.

## Decision

The current 30-by-100 calibration is retained because it is proportionate to
the *numerical rule-selection and negative-result* purpose. It is neither
obviously excessive nor sufficient for broad validation. The correct
interpretation is:

`proportionate_for_numerical_calibration_only_not_broad_validation`.

Accordingly:

- `NumericalCalibrationDesignPurposeJustified=TRUE`;
- `CalibrationPrecisionEvidenceReady=FALSE` until actual resolved
  denominators are available;
- broad bias/RMSE/coverage and D-study operating-characteristic claims remain
  false;
- no universal sample-size rule is supported;
- broad claims require a separate precision-designed simulation; and
- b1g15 authorization eligibility is unchanged, but no authorization record
  is issued.

## Next admissible gate

Draft.83d2b2b1g16 may still construct a separately reviewed immutable
activation artifact and authorized single-shard runner. It must retain all 100
planned replications per scenario, complete failure/reference-unresolved
accounting, no cross-cell pooling, no early stopping, and sealed confirmation.

After execution, the aggregate must report the actual resolved denominator and
MCSE/exact bound in every primary cell. Any cell that fails its computability
or reference-class coverage requirements produces a negative or
noninformative calibration; it cannot be rescued by the nominal 100.

## Sources

- Morris, T. P., White, I. R., and Crowther, M. J. (2019). Using simulation
  studies to evaluate statistical methods. *Statistics in Medicine*, 38,
  2074--2102. https://pmc.ncbi.nlm.nih.gov/articles/PMC6492164/
- Koehler, E., Brown, E. R., and Haneuse, S. J.-P. A. (2009). On the
  assessment of Monte Carlo error in simulation-based statistical analyses.
  *The American Statistician*, 63, 155--162.
  https://pmc.ncbi.nlm.nih.gov/articles/PMC3337209/
- White, I. R. (2010). simsum: Analyses of simulation studies including Monte
  Carlo error. *The Stata Journal*, 10, 369--385.
  https://doi.org/10.1177/1536867X1001000305
