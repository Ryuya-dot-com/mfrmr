# ConQuest recheck: calibration agreement and stochastic Person scoring

Date: 2026-09-14. mfrmr 0.2.4.9000; ConQuest 5.47.5 Standard Version.

## Question and answer

Does the current mfrmr fitter reproduce the retained ConQuest microcase, and
does close calibration agreement imply equally close exported Person scores?

The four native fits and eight mfrmr fits again produce close calibration
coordinates and deviances. However, native Person EAP differences reach
0.00884. A separate 18-condition scoring experiment shows that these differences
change with ConQuest's posterior simulation settings while the calibration
exports remain byte-identical. Comparing only estimation node counts would
miss this second source of numerical variation.

The [original plan and explicit post-hoc addendum](conquest-adaptive-recheck-0.2.4-plan.md)
separate the retained four-arm comparison from the scoring follow-up. Neither
has a newly inferred equivalence threshold.

## Matched calibration, retained score differences

The existing 96-Person, two-Rater, two-Criterion fixture has 384 integer
responses in four categories and a `~ X` population regression. The original
RSM/PCM by Q31/Q61 input and command files are byte-identical to the August
record. The native A matrices also match exactly. All four native runs finish:
96 iterations for RSM and 95 for PCM, terminating on deviance change.

Both fixed and adaptive mfrmr integration were fitted at Q31/Q61 with the
original constraints, maxit=2000 and reltol=1e-12. The table aggregates over
the two orders; all individual coordinates are retained in the
[coordinate ledger](conquest-adaptive-recheck-0.2.4-coordinates.csv).

| Model / mfrmr integration | Largest coordinate difference | Deviance difference | Largest EAP difference | Largest posterior-SD difference |
| --- | ---: | ---: | ---: | ---: |
| RSM / fixed | 2.734e-6 | 2.221e-7 | 0.008823 | 0.005707 |
| RSM / adaptive | 2.734e-6 | 2.221e-7 | 0.008823 | 0.005707 |
| PCM / fixed | 2.097e-6 | 4.316e-7 | 0.008832 | 0.005710 |
| PCM / adaptive | 2.097e-6 | 4.316e-7 | 0.008832 | 0.005710 |

Independent continuous integration at the four adaptive fits agrees with
mfrmr to 5.69e-14 in total log likelihood, 1.12e-15 in EAP and 4.45e-16 in
posterior SD. The largest relative integration-error estimate is 7.92e-12;
the largest omitted relative mass bound is 3.41e-146. Thus the original
0.00884 EAP discrepancy is not reproduced by the independent integral at
the mfrmr parameters.

ConQuest's positive history field named `LogLikelihood` is interpreted as
deviance, consistently with its console and the historical record. Exported
tokens are retained without assuming a rounding rule. The native
`stderr=quick` setting does not support an SE-equivalence claim, and these
latent-regression mfrmr fits retain their formal-readiness restriction.

## Posterior controls explain an additional numerical component

The official manual describes a separate Monte Carlo calculation of Person
posterior moments, governed by `p_nodes`, and notes stochastic EAP output.
Its default posterior budget is 2,000 and its default seed is 2. These are
separate from `estimate ! ... nodes=...`.
[ACER ConQuest command reference, `set` and `show`](https://conquestmanual.acer.org/s4-00.html).

The post-hoc experiment retains both Q61 calibration commands, then crosses
posterior budgets 2,000 / 20,000 / 200,000 with seeds 2 / 73 / 20260914 for
each model. All 18 settings and all 1,728 Person rows are retained. Every
native parameter, regression, covariance and history export remains
byte-identical to the corresponding original Q61 run. Explicitly setting
`p_nodes=2000` and seed 2 reproduces the original complete case CSV in both
models.

The reference for this follow-up integrates the response likelihood and
normal prior at the **exported native parameters**, including their retained
decimal precision. This avoids attributing differences between fitted
calibrations to the posterior calculation. It does not recover unprinted
native parameter digits.

| Posterior budget | Largest EAP discrepancy over both models and all three seeds | Largest posterior-SD discrepancy |
| --- | ---: | ---: |
| 2,000 | 0.008832 | 0.005709 |
| 20,000 | 0.001037 | 0.001644 |
| 200,000 | 0.0004846 | 0.0006102 |

The [18-row scoring ledger](conquest-adaptive-recheck-0.2.4-posterior.csv)
also reports RMSE for every setting. The observed decrease and seed variation
support posterior Monte Carlo approximation as the main source of the
original score difference in this microcase. Residual variation remains;
200,000 draws is an experimental setting, not a promised accuracy level or a
new recommended default. Three seeds do not characterize the full simulation
error distribution.

## Runtime, verification and reproduction

The same native executable hash is retained:
`61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48`.
The current transcript identifies **Standard Version**, rather than the
historical demonstration edition. The ordinary Rosetta command-line route
works outside the filesystem sandbox. No licence, signature, quarantine flag
or system policy was changed.

The durable raw directory is
`validation-results/adaptive-external-recheck-20260914/`. It includes the
successful four-arm run under `conquest-v3`, the scoring follow-up under
`conquest-posterior`, and two earlier mechanical attempts. One stopped at a
CSV row-name/type comparison; another could not load a bundled native library
inside the sandbox. The corrected input check preserves every value and row
order. A data-free runtime probe established the working native route before
fitting.

The scoring-table writer initially emitted 18 warnings about discarded row
names from recycled one-row settings. Reconstructing all 18 tables from the
saved native outputs reproduced that warning and verified identical values
after dropping unused row names. The writer now specifies `row.names=NULL`;
no fit, score, seed or result was replaced to remove a numerical failure.
The TAM follow-up's initial empty-string CSV parsing failure was similarly
corrected before its selected optimizer trials ran; its unsuccessful log is
also retained.

From the development root in the verified native runtime:

```r
library(mfrmr)
source("inst/validation/conquest-adaptive-recheck-0.2.4.R")
run_conquest_adaptive_recheck("/tmp/cq-recheck")
followup_conquest_posterior("/tmp/cq-recheck", "/tmp/cq-posterior")
```

The [shared source/evidence manifest](adaptive-external-recheck-0.2.4-source.csv)
binds the runners, calculation sources, inputs and raw artifacts. Repository
validation records are excluded from the package archive. The only change to
distributed R/test/Rd/native/vignette sources since the previously checked
adaptive-fitting archive is `vignettes/mfrmr-mml-and-marginal-fit.Rmd`.
The new text explains moving nodes/weights, a runnable adaptive-Q31/Q61
review, inference limits, and separate ConQuest posterior settings.

The final vignette rendered with its R example executed. Example-policy and
terminology checks passed 330 and 54 assertions, without warnings or skips.
The final macOS `R CMD check --no-manual` reports **0 errors, 0 warnings and
0 notes**, including 652 passing light-test assertions and three intentional
CRAN skips. The new archive is
`validation-results/adaptive-external-recheck-20260914/qa/mfrmr_0.2.4.9000.tar.gz`,
SHA-256 `fe117e6328834041f8828334533f99cb8df0491637db75ec04d74cf35a932759`.
All 493 R/test/Rd/native/source-vignette files in it match the current checkout.
Linux numerical comparisons used the previously checked installed package
with identical R/native sources; the documentation-only final archive was
not subjected to another Linux package check.

These results complement the broader [TAM stress recheck](tam-adaptive-recheck-0.2.4.md).
They do not establish ConQuest equivalence for sparse or anchored designs,
SE equivalence, calibrated confidence intervals, or unrestricted adaptive
GPCM inference. The public adaptive-fit ConQuest export guard is unchanged.
