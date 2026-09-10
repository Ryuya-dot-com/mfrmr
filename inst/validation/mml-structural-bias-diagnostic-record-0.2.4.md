# RSM/PCM structural bias: mechanism diagnostic

Date: 2026-09-09. Status: diagnostic completed. The plan below was fixed after
observing the original confirmation summaries, before examining the new score
decomposition. The archive retains that pre-execution plan text.
This is an exploratory explanation of the retained 20,000 datasets, not a
new confirmation or a change to their acceptance criteria.

## Question and diagnostic design

Why did standardized-bias Monte Carlo intervals overlap the practical margin
in cells 1, 5 and 7? Separate implementation/identification error, numerical
optimization error, selection from unavailable intervals, Monte Carlo sample
imbalance, and nonlinear finite-sample estimation. Examine all eight original
cells so the selected review cases have their original design comparisons.
Keep the original estimates, SEs, intervals, seeds and decisions unchanged.

Reuse the original generator, explicit parameter maps, and saved results.
For each model/exposure combination, enumerate all response patterns for a
Person (27 with three ratings, 729 with six). Three-rating designs have two
complementary assignments, each with exactly half of the Persons. Use the
generator's conditional probability function and marginalize over the fixed
standard-normal population. Check the q121 pattern probabilities against
independent whole-line integration at truth, then compute central-difference
log-probability scores. Check normalization, zero expected score, positive
expected information, finite-difference step stability and agreement with the
production likelihood/score on fixed sentinel datasets.

For each original dataset, let U be its log-likelihood score at truth, and
I the expected information for its fixed assignment and Person count. Define
the first-order displacement L = inverse(I) U and remainder R = estimate -
truth - L, in the same free/expanded coordinates. Since E(U)=0 under the
matched generating model, E(L)=0. Thus the sample mean of L measures the
first-order Monte Carlo imbalance; the mean of R is a control-variate estimate
of the same unconditional mean estimation error, with coefficient one fixed
by the score expansion rather than fitted to these results. It includes
higher-order estimation effects and any numerical error left by the solver.
This is a diagnostic decomposition, not a proposed estimator correction.

Use all 2,500 finite estimates per cell for this identity. Conditioning on
interval availability does not preserve E(L)=0 and must not be substituted.
Report all-versus-available differences separately, and retain the sample
correlation, MCSEs, skewness, maximum errors and leave-one-out mean sensitivity.
Original sign/proportional copies are not independent findings.

If the remainder indicates a systematic component, compare it with the
order-1/N likelihood-curvature bias obtained from the enumerated pattern
scores, Hessians and third derivatives. Check the sign/contraction calculation
on a transformed pair of independent Bernoulli logits with known delta-method
bias, and repeat finite differences at two step sizes. This is a local
asymptotic explanation; it is not an exact finite-sample formula. General
likelihood bias of this order is discussed by
[Firth (1993)](https://doi.org/10.1093/biomet/80.1.27); this diagnostic does not
implement Firth's bias-reduced estimator.

The marginal likelihood needs only response-pattern counts here. A fast seed
replay may cache the generator's conditional probabilities across Persons,
but must preserve its rnorm/sample sequence and reproduce the original
generator's scores on the first, middle and last seed of every cell. Check
the first original fit of every cell against the saved estimates. Reuse the
original dataset identities; no extra Monte Carlo replications are introduced.

Finally, use the independent pattern-count objective with a different optimizer
on the minimum, median and maximum target-error datasets in each review cell,
plus all six originally unavailable fits. Compare starts at the saved estimate
and truth. Record objective/parameter movement and stationarity; do not replace
the retained estimates or availability states. Use <=1e-6 objective change
and <=0.001 movement in units of the saved SE as numerical diagnostic bounds.
No production formula, inference restriction or release status changes solely
because this post-confirmation explanation looks favorable.

## Result and explanation

The observed review flags are explained well by a small finite-sample
likelihood-curvature bias together with Monte Carlo imbalance in the retained
replications. Their relative contributions differ across the three targets.
The independent numerical checks give no evidence that a wrong parameter map,
integration error or materially different optimum explains these flags.

All values in the following table use all 2,500 finite estimates in a cell,
including the originally unavailable fits. They are in parameter units. The
observed mean error equals the first-order sample mean plus the remainder
mean. The remainder's interval is a Monte Carlo interval for this diagnostic
control-variate estimate of unconditional bias.

| Target | Observed mean error | First-order sample imbalance | Remainder mean [95% MC interval] | Curvature prediction, order 1/N |
| --- | ---: | ---: | ---: | ---: |
| RSM, N=80, 3 ratings: shared Step 2 | 0.011464 | 0.002599 | 0.008865 [0.008492, 0.009239] | 0.008712 |
| PCM, N=80, 3 ratings: C1 Step 2 | 0.012189 | 0.004354 | 0.007834 [0.007346, 0.008323] | 0.007648 |
| PCM, N=320, 3 ratings: Criterion C1 | 0.003963 | 0.002721 | 0.001241 [0.001174, 0.001309] | 0.001188 |

The two threshold results indicate a small outward displacement of the
threshold ladder: Step 1 has the opposite sign because its sum with Step 2
is fixed at zero. A linear constraint map reproduces this sign copy; it does
not introduce a nonlinear recentering bias. Solving the nonlinear likelihood
equations on each finite dataset can have a nonzero mean error even though
the expected score at truth is zero.

For the PCM 320-Person Criterion target, approximately 69% of the observed
all-estimate mean error is the first-order Monte Carlo imbalance in these
replications. This is not a 69% systematic population bias: the first-order
term has expectation zero. A smaller positive finite-sample component remains.
The original available-only bias was 0.003892; retaining the five unavailable
fits gives 0.003963, a difference of 0.000070. Availability selection is not
the principal explanation. Cells 1 and 5 had no unavailable intervals.

The same decomposition also explains comparisons that did not receive review
flags. For example, RSM N=80 with six ratings had observed shared-Step-2 bias
0.001706, comprising first-order mean -0.003082 and remainder +0.004788.
An apparently small raw bias can therefore reflect cancellation in a finite
Monte Carlo experiment. The analysis was carried out for all eight original
cells, not only the selected review rows.

Holding the three-rating assignment fixed gives:

| Target | Remainder at N=80 | Remainder at N=320 | Ratio, 320 / 80 |
| --- | ---: | ---: | ---: |
| RSM shared Step 2 | 0.008865 | 0.002237 | 0.252 |
| PCM C1 Step 2 | 0.007834 | 0.001874 | 0.239 |
| PCM Criterion C1 | 0.004698 | 0.001241 | 0.264 |

These comparisons and the independent curvature predictions support an
order-1/N finite-sample explanation. Additional within-Person responses also
reduce the relevant curvature-bias coefficients in these evaluated designs.
Neither result specifies a universal minimum N or exposure, or applies to
JML incidental-parameter behavior, GPCM, other true parameters, weights or
estimated populations.

## How the mechanism was checked

**Generating model, identification and numerical integration.** All 1,566
assignment-specific response-pattern probabilities were compared with
whole-line adaptive integration. The maximum absolute discrepancy was
1.97e-15 and maximum relative discrepancy 3.76e-14. Probability sums differed
from one by at most 1.14e-14. Central-difference scores changed by at most
9.60e-10 when the step was halved; the maximum expected-score residual was
1.03e-9. The resulting expected control displacement was at most 4.69e-10
in a free coordinate, negligible beside the reported MCSEs. Expected
information was positive definite in every construction, with minimum
per-Person eigenvalues from 0.277 to 0.798.

Fast seed replay reproduced the original generator's scores exactly for
24 fixed seeds (first, middle and last in every cell). The first original
fit in each cell reproduced every saved expanded estimate exactly. On those
eight sentinel datasets, the independent pattern-count objective agreed
with production MML at truth within 2.28e-12, and finite-difference scores
within 3.26e-7. The generator and fitted model therefore share the checked
truth and coordinate basis. This conclusion is scoped to these designs.

**Curvature calculation.** Let u, h and t be the first, second and third
derivatives of one Person's log marginal probability, and I = E(uu').
Average expectations over the fixed assignment proportions. A second-order
expansion of the score equation gives the order-1/N bias approximation

```
bias_N ~= inverse(I) * { E[h * inverse(I) * u] + v/2 } / N
v[a] = sum_{b,c} E[t[a,b,c]] * inverse(I)[b,c]
```

The first term reflects the dependence of sample information and score; the
second reflects likelihood curvature beyond its quadratic approximation.
Both were evaluated from the response-pattern probabilities at truth, without
using the saved estimation errors to fit a coefficient. At the finer step,
expected Hessians
agreed with minus expected score information within 1.47e-7. Halving the
finite-difference step from 0.002 to 0.001 changed the free-coordinate
order-1/N coefficients by at most 1.47e-6, before division by N.

The contraction/sign check used two nonorthogonally transformed independent
Bernoulli logits: calculated bias coefficients agreed with the known
delta-method coefficients within 1.85e-6. A second check used direct Bernoulli
probability, whose sample-mean MLE is unbiased. Its two nonzero terms cancel;
the remaining finite-difference coefficient was 1.81e-5 at the coarser step
and 4.51e-6 at the finer step. These checks exercise both tensor mapping and
the score-information term, not only a canonical-logit special case.

The three selected predictions lie within their diagnostic remainder MC
intervals. Across all 96 coordinate-by-cell rows, six predictions lie outside
the pointwise intervals; the largest difference is 2.39 MCSEs. These include
redundant coordinates. The approximation is not an exact finite-sample bias
formula, and those discrepancies should not be removed or treated as exact
equality by definition.

**Optimization and unusual datasets.** Fifteen retained datasets were checked
from two starts each using the independent pattern-count objective and
`nlminb()`: the specified error-order examples and all six unavailable fits.
Maximum objective movement was 3.20e-9; maximum parameter movement was
5.98e-5 of a saved SE. Independently calculated terminal Newton displacement
was at most 6.27e-5 SE. Every checked information matrix was positive definite,
with its smallest eigenvalue at least 20.82. These displacements are much
smaller than the bias being investigated.

Thirteen of the 30 refits returned relative convergence; 17 returned
`singular convergence (7)`, including 12 starts at the already fitted point.
These status messages are retained. The numerical conclusion uses the
objective, displacement, score and information checks above rather than
calling every optimizer return a convergence success. This diagnostic does
not replace the original availability classifications.

Removing any one replication changes the selected target's observed mean
error by at most 0.000207, 0.000283 and 0.000090, respectively. A single
outlier does not account for the findings. No replication was dropped.

## Consequence for the next step

There is now a quantitative explanation for the three bias reviews. No
production estimator correction follows automatically. The decomposition
uses known simulation truth and cannot simply be subtracted from a real-data
estimate. The original 5-supported/3-review confirmation decisions remain
unchanged: this is a selected, post-confirmation diagnostic, and its
unconditional control-variate target differs from the original available-only
standardized-bias criterion.

The next targeted confirmation should test the finite-sample/Monte Carlo
explanation on fresh fixed seeds, retaining the original conditional bias,
coverage and availability targets. Choose replication precision for bias as
well as coverage. The original standardized-bias MC half-width was about
0.039: even a systematic standardized bias near 0.06 can therefore remain
review with 2,500 replications. The score decomposition can be prespecified as
an explanatory secondary measure; it must not silently replace a conditional
target or serve as optional stopping until a pass appears. General output
restrictions, full GPCM/TAM equivalence and the other release questions remain
under their existing review.

## Evidence and reproduction

- [Diagnostic runner](mml-structural-bias-diagnostic-0.2.4.R).
- [All 96 diagnostic summaries](mml-structural-bias-diagnostic-summary-0.2.4.csv).
- [Evidence archive](mml-structural-bias-diagnostic-evidence-0.2.4.rds), including
  the original archive fingerprint, response-pattern oracles and counts for
  every original dataset, paired displacements/remainders, curvature controls,
  30 refit diagnostics and parameter vectors, plan/source snapshots and logs.

From package root, run
`Rscript inst/validation/mml-structural-bias-diagnostic-0.2.4.R /tmp/mml-bias.rds`.
It writes the diagnostic RDS and `/tmp/mml-bias-summary.csv`. No fresh
recovery replications or production source changes are required. The original
confirmation archive fingerprint was checked unchanged; the new archive and
CSV were read back and checked for agreement. These files are repository-only.
Final checks also verified all 20,000 paired identities and count totals,
agreement with the original all/available bias summaries, and unchanged
production-source fingerprints. The existing roadmap tests, local document
links and `git diff --check` passed.
