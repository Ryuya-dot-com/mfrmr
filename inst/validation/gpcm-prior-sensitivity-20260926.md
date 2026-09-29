# Fixed-calibration normal-prior sensitivity

## Question and prospective design

For identical ratings and fixed GPCM facet/step/slope parameters, how much do
posterior scores and intervals change when the assumed person population
changes? This informs whether silently retaining the calibration population
is an adequate default for scoring a later cohort. It does not estimate that
cohort's population or establish repeated-sampling interval coverage.

The input is the retained native separate-owner GPCM fixture
`tests/testthat/fixtures/mfrm-conditional-scoring-gpcm.rds`: 120 synthetic
persons, three raters, two criteria, six unit-weight ratings per person.
The same data were used for calibration. Reusing these patterns checks scoring
behavior; they are not an independent validation cohort. Fresh P2 source
checks must pass before the comparison. Calibration parameters and the native
fit remain unchanged, with their file digest and parameter vector retained.

Before execution, five scenarios were specified relative to the fitted normal
population mean `mu` and SD `sigma`:

| Scenario | Scoring mean | Scoring SD |
| --- | --- | --- |
| Retained | mu | sigma |
| Lower mean | mu - 0.5 sigma | sigma |
| Higher mean | mu + 0.5 sigma | sigma |
| Narrower | mu | 0.7 sigma |
| Wider | mu | 1.5 sigma |

These are transparent assumption perturbations, not empirically justified
priors for a particular educational cohort. The scale remains the original
calibration scale; no recentering, rescaling, refitting or score imputation
occurs. Each scenario has its own recorded prior identity, alongside the
calibration population's identity.

All 120 response patterns enter nested one-, three- and six-rating subsets.
Rows are sorted by rater/criterion and rotated by person index before taking
prefixes, without using scores. This spreads the subsets across facet levels.
Rating count and the specific facet mix both change; the comparison does not
isolate the causal effect of adding interchangeable ratings. A subset does
not imply that omitted ratings are missing at random or justify imputing them.

There are 1,800 posterior calculations and 1,440 non-baseline contrasts. Report
absolute EAP changes, changes divided by the matched baseline posterior SD,
and 95% equal-tail interval width changes. There is no universal acceptable
shift threshold: a decision about training, classification or certification
needs its own loss or tolerance. Median and maximum shifts describe these
patterns only; their frequency is not a population estimate.

## Numerical checks and stopping condition

Reuse the existing posterior scorer and independent scalar-integration oracle.
For every pattern/scenario, compare adaptive orders 31 and 61 and compare EAP
and SD with the oracle. The oracle also evaluates the CDF at the production
interval endpoints; they must match 0.025 and 0.975. Extending the independent
integration domain from 32 to 64 posterior-scale units checks that its own
moments/CDF are stable. The oracle uses independently expressed category
logits, without the package probability kernel or quadrature rule.

Predetermined numerical tolerances: EAP/SD error and order movement < 1e-5;
CDF error and oracle refinement movement < 1e-8; oracle mass relative error
< 1e-9 and omitted-mass bound < 1e-12. Failures must be retained and investigated
before interpreting sensitivity. These are approximation criteria, not
statistical acceptance or coverage criteria. Complete the declared comparisons;
an elapsed-time checkpoint does not mark completion. No calibration optimization
or new repeated-sampling simulation is required for this question.

The CDF extension of the existing validation oracle is optional, preserving
its original five-value output when no endpoints are supplied. It is repository
validation code, not a public API. The sensitivity runner does not mutate a
calibration artifact or return a public prediction object under an altered prior.

## Execution

From the development root, after loading the local package:

```r
pkgload::load_all(".", compile = FALSE)
source("inst/validation/gpcm-prior-sensitivity-20260926.R")
run_gpcm_prior_sensitivity("validation-results/gpcm-prior-sensitivity-20260926")
```

## Results

All 1,800 calculations completed in 5.24 minutes, with no refits or repeated
full-package tests. The fitted population had mean 0.2236459 and SD 1.257954.
All prospective numerical checks passed. Maximum errors were 8.91e-8 for EAP,
1.55e-7 for posterior SD, and 1.86e-12 for endpoint CDF probabilities. The
maximum 31/61 movement was 1.55e-7, oracle refinement movement 7.29e-17, and
mass relative integration error 8.98e-12; the largest log omitted-mass bound
was -110.076, well below log(1e-12). No source parameter or prior was changed.

The public `predict_mfrm_units()` baseline matched the runner for person P1 at
each of the three rating counts within 3.56e-15 and passed its own score checks.
The optional oracle CDF extension was also checked against an analytic normal
posterior with zero likelihood weights; its original five-element output is
unchanged when CDF endpoints are omitted. These are focused checks, not a
new claim of full-suite or external-software equivalence.

For each person, take the largest absolute EAP change over the four alternative
priors, relative to the retained prior with the **same ratings**:

| Ratings per person | Median of those personal maxima | Largest personal maximum |
| --- | ---: | ---: |
| 1 | 0.5926 | 0.7281 |
| 3 | 0.2358 | 0.8132 |
| 6 | 0.1360 | 0.7974 |

Values are in the retained calibration's ability units, not probability units.
Typical sensitivity decreased with more ratings, but the worst sensitivity
did not. Of the 480 person-by-alternative-prior contrasts, 94 had a larger
absolute shift at six ratings than at one. This descriptive count uses this
fixture and the specified subsets; it is not a probability for another cohort.

The largest six-rating change was for three persons with all six scores at
the lowest category. Widening the prior SD by 1.5 moved EAP from -2.1123 to
-2.9097: a change of -0.7974, or 1.053 times the baseline posterior SD. These
extreme patterns still depend on the assumed population tails, despite all
six ratings being present. A rating-count cutoff cannot replace examining
the response patterns and their prior sensitivity.

The median changes in 95% interval width isolate another practical consequence:

| Ratings | Narrower prior (SD x 0.7) | Wider prior (SD x 1.5) |
| --- | ---: | ---: |
| 1 | -0.9594 | +1.3250 |
| 3 | -0.4667 | +0.4969 |
| 6 | -0.2336 | +0.1868 |

For the one-rating patterns, the narrower-prior interval width was a median
0.758 times its retained-prior width. That apparent gain in precision contains
no new rating evidence. The mean-shift scenarios also altered EAP (median
absolute changes about 0.41, 0.22 and 0.12 at one, three and six ratings).
Detailed scenario-specific medians, maxima and width ranges are preserved in
`validation-results/gpcm-prior-sensitivity-20260926/summary.csv`; all unrounded
person-level contrasts, numerical diagnostics, exact subset rows, calibration
parameters, source digests and session information are in `audit.rds`.

## Scope decision and connection to P4

The declared P3 comparison is complete. It supports making the retained-prior
assumption visible and providing explicit sensitivity calculations. It does
not select the right prior for a future cohort, validate a nonnormal population,
or establish frequentist coverage. Do not enlarge this grid merely to obtain
more cases or interpret numerical agreement as resolution of population transport.

The P4 implementation requirement was to preserve two distinct identities: the population
estimated during calibration and the normal prior selected for scoring. Add an
explicit alternative-prior option to the existing fitted-object scoring route,
initially for a single normal prior, with the current retained prior as the
unchanged default. Do not mutate the fit or relax source qualification. The
result, summary, draws and export must record both prior identities and label
the alternative as an analyst assumption. Invalid priors must fail under both
normal and review policies; integration must be checked under the actual prior.

The prospective acceptance sequence was: first test
the baseline identity, an alternative-prior result against this independent
reference, input failures, and propagation through existing result APIs. Then
connect the accepted P2 source states and prior identities to portable storage.
At extraction, source checks can use the native fit; replay must retain their
evidence and parameter identity without pretending to rerun checks that need
the omitted calibration responses. Preserve per-person scoring checks at replay.
An invalid or unresolved calibration must not become operationally eligible
because it can be serialized. The paused prototype's blanket review label is
not an acceptable final eligibility rule.

The limited scope
is conditional posterior scoring, not a global-optimum certificate or a
guarantee that the calibration population transports unchanged. New-cohort
population estimation, nonnormal prior families, covariate-dependent overrides,
calibration-uncertainty propagation and population-specific coverage require
their own designs; none is silently enabled by this sensitivity result.

## P4 fitted-object implementation and acceptance

The explicit-prior feature is now implemented locally in the existing
`predict_mfrm_units()` and `sample_mfrm_plausible_values()` entry points, with
`scoring_prior = list(mean = ..., sd = ...)` appended to preserve positional
call compatibility. `NULL` retains the existing numerical scoring basis.
The option is a shared normal prior on the unchanged ability scale; SD is not
variance. Covariate-dependent population overrides and malformed/nonfinite or
nonrepresentable prior specifications are refused, under either readiness policy.

The native fit is not changed. Calibration-source checks run independently of
the override. Every supplied-prior calculation receives adaptive reference-order
checks of its reported EAP/SD under the actual prior, including ordinary source
fits that do not use the P2 conditional route. A source requiring review cannot
be upgraded by selecting another prior. Failed score integration stops by
default; explicit review retains the numerical flag without hiding a source
review requirement. The existing continuous posterior intervals are reused.

`PriorMean`/`PriorSD` describe the scoring prior; `RetainedPriorMean`/
`RetainedPriorSD` describe the original scoring prior. `PriorSource` and readable
`Prior`/`RetainedPrior` labels distinguish a user assumption, an estimated normal
population, and the standard normal reference used by ordinary/post hoc JML
scoring. The original `retained_posterior_basis`, explicit `scoring_prior` and
per-person `prior_comparison` are retained in settings. These values are not
rounded in summaries or draw summaries. Missing or inconsistent prior records
are refused by summary/export validation. Posterior draws, report tables and
CSV exports preserve both prior identities. Plain `saveRDS()` stores a prediction
result, not a new portable calibration API.

### Focused verification

* The dedicated `test-scoring-prior.R` passes 93 expectations. It reuses 18
  previously checked P3 rows (two response patterns, three lengths, three priors)
  and confirms matching EAP/SD/interval results within 1e-10. This is routing
  agreement with saved calculations, not a tighter independent-error guarantee.
* Omitted versus explicit `NULL` returns identical new-format objects; specifying
  the retained prior explicitly preserves numerical scores and seeded draws.
  The source fit remains byte-identical before and after the comparison.
* Summary, draw summary, actual CSV export, and ggplot input retain both priors.
  Missing/changed prior metadata is rejected. Invalid specifications, a failed
  source, and a too-coarse score grid exercise refusal/review paths.
* The existing conditional-scoring test file passes 41 expectations. The ordinary
  prediction tests exercise RSM MML, PCM JML, population scoring, column mappings,
  weights and older outputs. Its initial run exposed an artificial one-person
  draw fixture that still carried two persons' settings. That fixture is now
  aligned, and the old-schema fixture removes fields absent from that schema.
  The affected block was rerun (27 expectations, no warnings); the other blocks
  had passed in the initial run. A missing-column warning in the legacy path was
  fixed by using a non-warning optional-column lookup.
* The updated help example was executed. Its initial `rbind()` could not combine
  the default and supplied-prior tables, because only the latter had automatic
  integration-check columns for an ordinary source. `dplyr::bind_rows()` now
  preserves the different metadata columns. The example then completed, and its
  rendered two-person comparison was visually inspected. Scenarios are labelled
  on the axis, with persons in separate panels; meaning does not rely on colour.
* Both modified help files parse and `git diff --check` passes. No full package
  suite, optimization study or 1,800-case sensitivity rerun was performed.

Logs (including the resolved initial failures), the example image and source
digests are retained in `validation-results/scoring-prior-api-20260926/`.
The small regression reference CSV has its own provenance note under
`tests/testthat/fixtures/`.

This satisfies P4's fitted-object acceptance for the stated scope and permits
resuming portable implementation. Portable GPCM itself remains unavailable.
The next step is to transfer the accepted source states and prior/evidence
identities into extraction and replay, with explicit rejection tests and no
claim that a saved numerical qualification establishes population transport.


## Subsequent portable implementation (2026-09-27)

The accepted conditional source/prior checks were subsequently connected to
portable GPCM extraction and replay. See [the implementation record](portable-gpcm-20260927.md).
This does not change the P3 simulation's targets, results or limitations above.
