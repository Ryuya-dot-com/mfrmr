# Fixed-facet sandwich intervals: bounded local evaluation

Date: 2026-09-22. Active roadmap row 2a. This is an implementation and
bounded repeated-sampling record, not a general coverage qualification.
The source remains on the local expanded-workflows branch; this record does
not change main, a release tag, CI status or CRAN availability.

## Question and implemented target

Can users compare ordinary and one-way sandwich intervals for observed fixed
facet estimates and prespecified differences, while preserving the sampling
unit and showing failure explicitly? Does the covariance correction recover
generating-parameter coverage when the standard-normal population assumption
is wrong?

`mfrm_facet_intervals()` now implements this comparison for inference-ready,
unit-weight RSM/PCM MML with a fixed standard-normal population and fixed
quadrature. It reuses the fitted estimates, likelihood moments, observed
information and constraint maps. Person likelihood scores aggregate to the
existing objective gradient. An optional explicit mapping aggregates Persons
into larger independent clusters before outer products. The covariance is
H^-1 sum_g(s_g s_g') H^-1, with optional G/(G-1) scaling, off by default.
Intervals use pointwise normal critical values.

Full covariance is retained when transforming facet constraints and contrasts.
Fixed targets have no inferential interval. Rank-deficient cluster scores keep
point estimates and model comparisons but withhold the selected interval;
singular/regularized observed information and ineligible source fits are refused.
Plots, saved objects and tables retain the selected method and unavailable
results. The MI workflow reuses the same contrast validator but continues to
use its existing model-based within-imputation covariance.

## Protocol and execution

The protocol in `internal-roadmap-0.2.3.md` was fixed before obtaining outcomes.
The runner is `facet-sandwich-0.2.4.R`; data and logs are retained under
`validation-results/robust-intervals-20260922/` in the development checkout.

- Eight cells: RSM/PCM; 80/320 independent Persons; normal/complete or
  standardized-lognormal/sparse. There are three fixed raters, two criteria,
  categories 0–2 and no missing assigned scores.
- Normal/complete: six ratings per Person and correctly specified N(0,1)
  ability. Skewed/sparse: three ratings per Person, one of two complementary
  criterion patterns chosen independently of ability and response. The latter
  evaluates that joint condition, not separate causal effects of sparsity and
  nonnormality.
- Rater values (0.3,-0.1,-0.2), criterion values (0.4,-0.4), RSM steps
  (-0.6,0.6); PCM criterion-specific steps (-0.7,0.7), (-0.2,0.2).
- Targets: R1-R2, R1-R3, R2-R3, C1-C2. These four correlated targets do not
  count as four independent simulation replications.
- 200 independent datasets per cell, nominal 95% intervals. Seeds are
  `92230000 + 1000 * Cell + Replicate`; no replacements. Fits use 61-point
  quadrature, `maxit = 400`, `reltol = 1e-10`.
- The continuous generating distributions are integrated independently to
  obtain all finite response-pattern probabilities. Probability normalization
  and 1e-8/1e-10 integration tolerances agree within 1e-8. Minimizing expected
  working-model negative log likelihood yields pseudo-true targets; independent
  61/121-node quadrature solutions agree within 1e-5. The normal targets agree
  with structural truth within 1e-5.
- Fresh latent and categorical draws generate each dataset; simulated data
  are not sampled from the reference probability lookup. Each ordinary and
  uncorrected Person-sandwich interval uses the same fit. No fit is rerun to
  obtain a preferable result.

All 1,600 planned fits completed without recorded warnings/errors and returned
both interval methods. Conditional and joint available-and-covered rates
therefore coincide in this run. `replications.csv` retains every seed, estimate,
both SEs, truth, pseudo-true target, availability, warnings and elapsed time.
`coverage.csv` retains interval widths, bias, empirical SD, mean SE and exact
binomial Monte Carlo bounds; `paired-coverage.csv` retains within-dataset
coverage differences and their Monte Carlo SEs. A zero paired MCSE means no
discordant outcomes were observed in these 200 replications, not certainty
about the population difference.

All eight cell RDS files retain identical start-of-run source MD5s:

| Source | MD5 at execution |
| --- | --- |
| `R/api-facet-intervals.R` | `24af5eb49077f498004ae8c1fe08eb8b` |
| `inst/validation/facet-sandwich-0.2.4.R` | `78f45f438fb3b9cc2b58e95d403d46ac` |
| `inst/validation/internal-roadmap-0.2.3.md` | `e38f6215479914fad599184f121841cf` |
| `R/mfrm_core.R` | `ce062aaab138b77c1dd48f4d02b57743` |

The API's roxygen comments and roadmap were subsequently updated to document
these results. Executable interval code and the simulation runner were not
changed in response to coverage outcomes.

## Results and answer

The following percentages are ranges over the four prespecified contrasts
within each cell. They are not pooled coverage estimates or confidence bounds.
At 200 datasets per cell, MCSE near 95% coverage is about 1.54 percentage points.

| Model | Persons | Scenario | Model: truth | Sandwich: truth | Model: pseudo-true | Sandwich: pseudo-true |
| --- | ---: | --- | ---: | ---: | ---: | ---: |
| RSM | 80 | Normal/complete | 92.0–96.0 | 93.0–95.5 | 92.0–96.0 | 93.0–95.5 |
| PCM | 80 | Normal/complete | 96.0–98.0 | 95.5–97.0 | 96.0–98.0 | 95.5–97.0 |
| RSM | 320 | Normal/complete | 95.0–96.0 | 95.0–96.0 | 95.0–96.0 | 95.0–96.0 |
| PCM | 320 | Normal/complete | 92.5–98.0 | 92.5–98.0 | 92.5–98.0 | 92.5–98.0 |
| RSM | 80 | Skewed/sparse | 93.0–94.5 | 93.0–95.5 | 92.0–94.0 | 93.5–96.0 |
| PCM | 80 | Skewed/sparse | 90.5–93.5 | 91.5–95.5 | 92.5–96.5 | 93.0–96.5 |
| RSM | 320 | Skewed/sparse | 84.5–95.0 | 87.0–95.5 | 93.0–95.5 | 95.0–96.5 |
| PCM | 320 | Skewed/sparse | 88.0–93.0 | 90.0–93.5 | 90.0–97.5 | 93.5–97.5 |

The covariance correction does not remove misspecification bias. Two
counterexamples make the distinction concrete:

- RSM, 320 Persons, skewed/sparse, C1-C2: generating truth is 0.8, while
  the independently computed pseudo-true target is approximately 0.905767.
  Mean fitted bias relative to truth is 0.106481. Model/sandwich mean widths
  are 0.426157/0.448494 logits. Truth coverage is 84.5%/87.0%; sandwich's
  exact 95% Monte Carlo bounds are 81.5–91.3%. Against the pseudo-true target,
  the same intervals cover 95.5%/96.0% (sandwich bounds 92.3–98.3%). The
  paired truth-coverage change is +2.5 percentage points, MCSE 1.11 points.
- PCM, 320 Persons, skewed/sparse, R1-R3: generating truth is 0.5, while
  the pseudo-true target is approximately 0.571257. Mean truth bias is
  0.083646. Widths are 0.486224/0.515684. Truth coverage is 88.0%/90.0%
  (sandwich bounds 85.0–93.8%). Pseudo-true coverage is 90.0%/93.5%.
  Paired changes are +2.0 points (MCSE 0.99) for truth and +3.5 points
  (MCSE 1.30) for the pseudo-true target.

Therefore this API provides an explicit covariance comparison under its
assumptions, not a repair for a wrongly targeted measurement model. Neither
uniform improvement nor general nominal coverage is established. The observed
undercoverage is documented in user help and the tutorial, rather than hidden
behind the word "robust" or the absence of numerical failures.

## Software checks and remaining scope

Fifty focused interval expectations pass, covering independent continuous
integration/central-difference Person scores for RSM/PCM, aggregate gradients,
full-covariance contrasts, larger-cluster aggregation, optional scaling,
constraints/anchors/interactions, unsupported fits/weights, rank failures,
serialization and plots without refitting. The 89 response-MI expectations
and four namespace expectations pass after sharing contrast geometry.
The 67 existing visual/interval-guide expectations also pass after adding the
new interval and MI routes and correcting stale ICC profile guidance.
Prior unchanged numeric-feature and clustering checks are reused. The complete
test suite and the earlier 20,000-dataset ordinary-interval study were not rerun.

The tutorial, reference examples and README contrast example execute locally.
Public plots use English and retain model/selected method distinctions.
Documentation describes original IDs, one-way independence, fixed facets,
pseudo-true targets and the separation from MI pooling.

These checks do not cover school-level repeated-sampling performance, few
independent clusters, multiway crossed random effects, arbitrary informative
assignment, MNAR response imputation, random-rater replacement targets,
G/D-study interval extensions or variance boundaries. Row 2a is partially
implemented and evaluated within this scope, not closed in full. Row 2b rater
diagnostic accuracy and the requested model extensions remain open. Further
work must address those declared targets rather than repeat this eight-cell
run or expand it without a new decision-relevant question.

## M2 target reconciliation, 2026-09-23

The bounded 0.2.4 decision is to retain one-way observed-information/sandwich
covariance comparison for the documented fixed-standard-normal RSM/PCM MML
scope and independent Persons or declared larger independent clusters.
The target is the working model's parameter; under misspecification it need
not be the generating severity. General true-parameter robustness, small-
cluster/multiway inference, and bias removal are not admitted claims. They
are already outside the active bounded release scope, rather than newly
deferred to make this row appear complete.

The current README, NEWS, method help, interval guide and tutorial consistently
state that target, its independence requirement, unavailable-result behavior
and the adverse generating-truth coverage. The prior source hashes still match
the interval/plot implementation, core likelihood file, interval tests, method
help and complete tutorial. The intervening imputation-source change is only
roxygen explanation/references; parsed executable expressions match the
hash-verified earlier file. Reuse checks are recorded in
`validation-results/estimated-model-qualification-20260923/fixed-facet-evidence-reuse.json`.
No new fitting, simulation or repeated test suite was required.

This resolves the M2 estimand/public-interpretation decision for this bounded
route. The recorded implementation, independent checks and finite simulation
evidence can be carried into M4/M5 integration. It does not upgrade the study
to universal coverage qualification, validate small school samples, or close
MI/shared-rater/testlet inference. Final integrated source and package checks
remain required; the full release row is not marked release-closed.
