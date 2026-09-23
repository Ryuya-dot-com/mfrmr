# Same-definition ordinary and extended RSM predictive comparisons

Local checkpoint: 2026-09-23. Working tree based on `2230003`, branch
`development/0.2.4-expanded-workflows-20260922`. No commit, push, CI,
main merge or release was performed.

## Question and release position

M3 requires an ordinary-model comparison that does not silently compare
unlike residual indices. This checkpoint asks whether ordinary RSM MML can
integrate its latent ability under the same same-data predictive definition
as the two extensions, and whether matched predictions survive plots,
reports and saved replay. It does not ask which model is superior.

`mfrm_response_diagnostics()` now accepts native ordinary RSM MML fits with
unit weights, additive unanchored severity facets, consecutive integer
categories and either known N(0,1) or an estimated intercept-only normal
population. Its posterior uses all observed ratings of each requested Person;
the mean and variance of the estimated population are both retained.
Original scores, omitted-score positions and original identifiers are
reconstructed from saved preprocessing records. Unsupported population
regressions, weights, anchors, interactions and older omission records are
refused. Ordinary plug-in `diagnose_mfrm()` indices are unchanged.

The predictive target and full categorical variance are those documented in
[the earlier numerical record](response-diagnostics-record-0.2.4.md).
Calibration is fixed. Infit/Outfit remain same-data descriptive quantities
with no expectation-one reference, cutoff, ZSTD, p-value or quality flag.
The earlier independent shared-rater zero-variance reference remains a
**no-rater-effect** RSM, not an ordinary fitted fixed-rater model.

`compare_mfrm(..., response_diagnostics = list(reference, comparison))`
accepts already computed diagnostics from matching fits. It checks full source
calibration/rosters, selected-event contents and multiplicity, categories,
probability target and shared grouping identifiers. Sorting selected events
aligns different source row orders. Repeated indistinguishable common events
match in source occurrence order; both input row numbers and event contents
remain available. No original row number is assumed to identify the same
rating in two differently ordered datasets. Missing and failed outputs are
retained, and affected differences are unavailable. Any unavailable observed
row withholds its group index. The two diagnostics continue to condition on
the full observed roster, including nonselected Persons for shared raters.

The added `responses` component contains per-event means/variances,
category probabilities, grouped indices, event identities and settings.
Paired/difference plots select these through `metric`, with optional category
selection, hidden titles/notes, monochrome and text alternatives. Row labels
are hidden by default for large rating tables; group labels remain visible.
Probability panels have a common 0–1 scale. Figure zero/equality lines denote
agreement, not model adequacy. CSV/report tables and saved results preserve
counts, unavailable rows and interpretation. Ordinary results with saved
posterior diagnostics also replay from RDS instead of recomputing the fit.

This closes the bounded **same-definition predictive-comparison** component
of M3. Model-aware Wright/pathway displays, aligned Person-score comparisons
and statistical qualification remain. M2 MI adequacy, shared-rater interval
qualification and the final protocol remain unresolved. M5 local completion
and M6 publication are not reached; no required outcome was deferred merely
to declare this checkpoint complete.

## Evidence and limits

Executable workflow: `predictive-comparison-0.2.4.R`.
Artifacts: `validation-results/predictive-comparison-20260923/` (excluded from
the package), including the prior-to-outcome tolerance record, numerical
summary, exact saved comparison objects, archives, rendered changed tutorial
sections, rendered help, replay scripts and logs.

- **Independent ordinary integration.** Direct logistic probabilities with
  `stats::integrate()` agree with the API under known N(0,1) and a nonzero
  normal mean/nonunit variance. Unit tests also check the positive extra
  variance omitted by averaging conditional variances alone. A direct
  polytomous RSM calculation on the saved educational example agrees to
  `5.56e-17` in category probability (prespecified tolerance `1e-8`).
- **Separately fitted zero-testlet reduction.** The earlier saved ordinary
  and known-zero-local-variance testlet fits reproduce the same posterior
  probabilities, means, variances and group indices within `4.58e-7`
  (prespecified tolerance `1e-5`). This checks identification conventions as
  well as the predictive calculation; the original fits were not rerun.
- **Actual saved workflows.** All 768 rows of the testlet example and the
  shared-rater example's existing selected Person (16 rows, conditioned on
  all 768) compare with separately calculated ordinary posterior predictions.
  The earlier incomplete design retains 320 assigned rows: 306 available
  comparisons and 14 explicit missing scores. Existing testlet/shared-rater
  integrals and all calibrations were reused.
- **Failure and identity checks.** Tests cover shifted category origins,
  duplicated events, missing positions, reversed source order, mismatched
  equal-sized selections, different targets/groups, changed calibration,
  source attachment and unavailable integrals. Reversing model order reverses
  differences. Probability differences sum to zero across categories.
- **Targeted regression checks.** Five affected test files provide 304 passing
  expectations in their final applicable runs: response comparison (76),
  existing response diagnostics (68), extended comparison (61), extended
  results (95) and namespace contract (4). The original ordinary-only
  `compare_mfrm()` and current version return identical results on saved fits;
  both retain their existing readiness warning and suppress ranking.
- **User output.** Five changed Rd topics pass parsing/checking and render.
  Both added tutorial sections execute against saved source fits/diagnostics;
  their comparison tables equal the retained workflow results. Four actual
  comparison figures were visually inspected, including monochrome and
  hidden annotations; panel spacing and ranges were corrected after inspection.
  Both extended-model archives export without plot errors.
- **Fresh-session reuse.** Ordinary, testlet and shared-rater archives replay
  with optional RTMB unavailable and fitting/integration functions replaced
  by errors. Tables match exactly; plotting/reporting/export perform no new
  numerical calculation. The focused replay check is retained as
  `replay-check.R`. No all-package test or Monte Carlo study was repeated.

The first continuous-reference harness used an absolute integration tolerance
of `1e-10` for a likelihood mass near `1.24e-9`; its category integrals were
insufficiently accurate (their normalized sum already failed). It was changed
to `abs.tol = 0` with relative tolerance `1e-10`, without relaxing the
acceptance tolerance or changing the API. Initial/debug logs remain. Initial
tests also found warnings when a tibble lacked optional `ParameterStatus`;
the lookup now checks column names first. A test's old error-text expectation
and a test-summary CSV writer were corrected; their initial logs are retained.

These checks establish bounded numerical correspondence and output integrity.
They do not calibrate a fit test, show better held-out prediction, qualify
shared-rater Laplace accuracy for general sparse designs, or establish interval
coverage. A lower residual index can result from using the same responses in
the latent posterior and is not model-selection evidence.
