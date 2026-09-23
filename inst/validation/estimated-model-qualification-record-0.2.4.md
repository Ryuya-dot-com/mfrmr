# Estimated-population shared-rater qualification and output decision

Date: 2026-09-23. Local expanded 0.2.4, M2/M3/M4. All 800 planned
datasets and 1,600 fits are complete. **No primary rater-interval condition
meets the prespecified combined qualification criterion.** Automatic
individual-rater normal bounds are withdrawn, with explicitly requested
approximations retained. This is an output restriction, not a coverage repair
or completion of model qualification. No publication or integration into main
was performed.

## Question, source and accounting

The [frozen protocol](estimated-model-qualification-0.2.4.md) specifies the
design, targets, practical tolerances and Monte Carlo rules before outcomes.
It asks whether first-order shared-rater prediction intervals with estimated
normal ability SD support their nominal interpretation under few raters or
weak linking. Ordinary estimated-population RSM fits on the same data compare
point accuracy; they do not acquire unsupported ordinary-model intervals.

The source was frozen at 2026-09-23 17:41:08 JST. Runner MD5 is
`10c170ab91c232f250cb755cb0f0c2c9`; protocol text MD5 is
`35d529970c4ddc48985a7ca41cedef8e`. The artifact directory
`validation-results/estimated-model-qualification-20260923/` contains the
complete roster, source hashes, executed-source snapshot, session information,
all 800 original fits/truth/data/warnings/checks, worker logs, and analysis
tables. No trials were replaced, restarted selectively or omitted. The primary
summary verified the unchanged current source before the subsequent output
correction. The reusable summary now verifies the frozen source snapshot so
output-only changes do not prevent reanalysis; its original script is retained.
Replaying that summary after the output correction reproduced every analysis
CSV byte for byte, without rerunning a fit.

Each condition contains 200 independent replicates, 240 Persons and 1,440
observed scores. True ability SD is 1.3 and rater SD .7. Both models estimate
ability variance; Person quadrature uses 61 points and retains the original
higher-order tolerances. Assignment is independent of latent draws. The
weak design has exactly two bridging Persons with unchanged per-rater workload.
Independent checks confirm workload, bridges, public comparison coordinates,
full-covariance criterion contrasts and all-trial denominators.

## Primary interval outcome

Coverage concerns realized **uncentered** rater effects. Average within each
dataset first; datasets, not raters, are the independent Monte Carlo units.
Coverage below is conditional on finite eligible bounds. Its Monte Carlo
interval is a pointwise t interval for that dataset-level mean.

| Raters / assignment | Finite / planned | Conditional coverage | 95% MC interval | MCSE | Joint available-and-covered |
| --- | ---: | ---: | ---: | ---: | ---: |
| 6 / rotating | 198/200 | 91.58% | 88.77–94.39% | 1.43 pp | 90.67% |
| 24 / rotating | 176/200 | 94.06% | 93.18–94.94% | .44 pp | 82.77% |
| 6 / weak | 198/200 | 91.84% | 88.99–94.68% | 1.44 pp | 90.92% |
| 24 / weak | 174/200 | 93.99% | 93.08–94.90% | .46 pp | 81.77% |

All four frozen primary decisions are **inconclusive**. In six-rater cells,
the lower MC bound fails the 92.5% floor; their upper bounds do not fall below
that floor either, so this study does not give a conclusive material-
undercoverage decision. In 24-rater cells the conditional coverage condition
passes, but finite availability fails: lower exact availability bounds are
82.67% and 81.53%, below the required 95%. Six-rater lower availability bounds
are 96.43%. Do not pool cells, label non-significance as equivalence, or
increase n after seeing these results to obtain a favorable decision.

All-trial coverage accounting bounds, allowing every unresolved interval to
cover or fail, are 90.67–91.67%, 82.77–94.77%, 90.92–91.92% and 81.77–94.77%
in table order. These are accounting bounds, not confidence intervals.
Conditional mean widths are 1.124, 1.196, 1.139 and 1.200 logits.

All optimizers converged and information checks passed; neither model raised
a fitting error. Shared-rater higher-order Person quadrature checks failed
in 2, 24, 1 and 26 datasets (53 total). Every one failed the gradient-difference
criterion; 1, 18, 1 and 20 also failed the log-likelihood criterion. One further
six-rater weak-design fit estimated zero rater variance and did not supply
regular intervals. No estimated ability-variance boundary occurred. Ordinary
point-estimation readiness held for all 800 datasets. Its regular interval
inference was not used. This distinguishes numerical availability from
coverage on eligible fits and from the separate rater Laplace approximation.

## Other prespecified targets and ordinary-model comparison

The rater point comparison targets **sample-centered** realized effects.
Only datasets with both point estimates eligible enter paired error contrasts;
their counts remain visible. It is not the uncentered interval target above.

| Raters / assignment | Pairs / planned | Shared rater MSE | Ordinary rater MSE | Shared minus ordinary, 95% MC interval |
| --- | ---: | ---: | ---: | --- |
| 6 / rotating | 198/200 | .01710 | .01711 | −.00001 [−.00079, .00077] |
| 24 / rotating | 176/200 | .07475 | .09421 | −.01946 [−.02321, −.01572] |
| 6 / weak | 199/200 | .01955 | .01922 | .00032 [−.00097, .00161] |
| 24 / weak | 174/200 | .07653 | .09698 | −.02045 [−.02400, −.01690] |

The 24-rater improvement on available pairs does not establish model
superiority, compensate for missing fits or qualify intervals. Six-rater
point differences are inconclusive. For the shared model, the weak-minus-
rotating MSE difference is .00243 [.00030, .00456] with six raters and
.00271 [−.00136, .00678] with 24 on paired ready fits. Coverage differences
are inconclusive. Varying rater count also changes workload; there is no
adequate-rater-count threshold or isolated causal rater-count effect.

Mean ability-SD bias is −.0060, −.0270, .0008 and −.0239 in condition order.
Mean rater-SD bias is −.0777, −.0246, −.0786 and −.0180; six-rater bias MC
intervals are [−.1079, −.0475] and [−.1096, −.0477]. Those cross the −.07
practical-bias threshold, so none meets the prespecified clear-adverse-bias
rule. This is not proof that small bias has been established. Estimated-zero
outcomes remain in ready point summaries. Availability conditions these results.

Named criterion biases and the C3–C1 contrast remain separately recorded;
all bias MC intervals lie within ±.10 logits. C3–C1 conditional coverage is
95.96%, 95.45%, 96.46% and 95.40%. Only C3 and C3–C1 in the six-rater weak
cell meet their bounded interval criterion; other named criterion/contrast
decisions are inconclusive. This does not qualify all fixed-facet intervals,
Person scoring, population-SD profiles, bootstrap intervals or testlets.
See `target-summary.csv`, `population-summary.csv` and paired tables for
each estimate, denominator and MC uncertainty.

## Implemented decision

Earlier known-ability-SD evidence showed poor six-rater coverage; the new
estimated-population study does not establish an adequate automatic nominal
interval contract. The combined evidence motivates withdrawal of automatic
individual-rater normal bounds across the local API, not a post hoc declaration
that a frozen inconclusive result is adverse or that a new formula is accurate.

- New fits keep conditional modes, `ConditionalSD`, `PredictionSE` and full
  covariance; rater `Lower`/`Upper` are missing by default. Calibration and
  rater-SD profile targets remain distinct and unchanged.
- `confint(fit, parm = "raters")` explicitly retrieves the first-order normal
  approximation, with level/method/target/limitation metadata, without RTMB or
  a refit. Numerical/information failures and estimated variance boundaries
  retain missing bounds. Default `confint(fit)` remains the SD profile.
- Default summaries, plots and report tables also strip automatic bounds
  from earlier saved fits, without mutating them. `plot(..., intervals =
  "normal")` explicitly selects the approximation. Interval-width views and
  sorting require that choice. Text/table alternatives retain interpretation
  even when the displayed caption is suppressed.
- Raw older RDS objects and already saved plot payloads retain their historical
  values. New summaries/reports do not silently promote those bounds. The
  legacy plot conversion fallback describes the retained normal approximation.
- Bootstrap intervals remain an explicit candidate, with prior failed-refit
  accounting and finite-sample limitations. They are not promoted as the new
  automatic default or declared a statistical repair.

## Remaining milestone decision

Verification of the changed output contract:

- All five targeted files pass: `test-random-rater-normal-output.R`,
  `test-extended-plot-views.R`, `test-extended-results.R`,
  `test-random-rater-intervals.R` and `test-random-rater.R`. The SD profile,
  explicit approximation, boundaries, bootstrap calculations, rendering and
  saved reports retain their separate semantics. No full suite was repeated.
- Saved-fit replay checks cover all 800 production fits: explicit normal
  limits equal the original frozen limits within 1e-12; default summary
  bounds are missing, with estimates and SEs unchanged. This does not refit
  or rerun the statistical experiment.
- A fresh session without RTMB, with model-computation functions replaced
  by errors, executes the exported replay and explicit interval/plot routes.
  Default report tables contain no automatic rater bounds. Three changed
  Rd pages generate HTML, and default/explicit plots were visually checked.
  The precision display uses the existing label-suppression option where
  nearby points would overlap; table data retain the identities.
- Two assertion issues encountered during checking remain in the logs: a
  legacy-caption regexp did not allow wrapped whitespace, and an existing
  archive test still expected diagnostics to be unavailable after the earlier
  model-map change. The assertions now check the actual first-order caption
  and descriptive-diagnostic/conditional-interval boundaries. Affected tests
  were rerun successfully; production outcomes were unchanged.
- `git diff --check` passes. `frozen-evidence-sha256.json` and
  `output-source-sha256.json` retain evidence and corrected output identities.

This verification establishes output behavior, not nominal coverage.

M2/M3 are **not closed**. Resolve the Person-integration failures from saved
cases against independent higher-order calculations, without relaxing criteria
or replacing production outcomes. Any numerical repair needs its own frozen
contract and proportionate follow-up, not an automatic repeat of all 800 fits.
Qualification of rater Laplace accuracy, retained conditional Person scoring
and population/alternative uncertainty is separate. Estimated-population
testlet qualification and the defensible MI example/inference remain required.
No new distribution, assignment, missingness or joint-model claim follows.

In the parallel evidence reconciliation, the one-way fixed-facet sandwich
working-model target and public interpretation are resolved using unchanged
evidence; that bounded route proceeds to final integration. It does not solve
misspecification bias. M5 local completion and M6 publication remain open.

**Subsequent numerical follow-through:** the
[saved-case integration review](shared-rater-integration-review-0.2.4.md)
identifies insufficient 61-point Person integration and obtains ready
121-point refits for all 53 affected cases, with unchanged checks and
independent continuous references. These selected refits are stored separately;
the original outcomes and interval qualification decisions above are unchanged.
Laplace accuracy, retained scoring/uncertainty, testlet qualification and MI
adequacy remain open.
