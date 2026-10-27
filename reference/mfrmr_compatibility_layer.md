# mfrmr Compatibility Layer Map

Guide to the legacy-compatible wrappers and text/file exports in
`mfrmr`. Use this page when you need continuity with older
compatibility-oriented workflows, fixed-width reports, or graph/score
file style outputs.

This compatibility layer currently applies mainly to diagnostics-based
`RSM` / `PCM` workflows. Supported `GPCM` fits also provide graph and
package-native scorefile exports through
[`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_file_bundle.md),
with explicit score-side limitations. Check each helper's model scope.
Treat this layer as a presentation/contract surface, not as a claim of
FACETS or ConQuest numerical equivalence.

SPSS is treated differently from FACETS and ConQuest: `mfrmr` currently
supports table/data-frame/CSV handoff for SPSS-oriented reporting
workflows, but it does not generate SPSS syntax, write native SPSS
system files, execute SPSS estimators, or claim SPSS numerical
equivalence.

## When to use this layer

- You are reproducing an older workflow that expects one-shot wrappers.

- You need fixed-width text blocks for console, logs, or archival
  handoff.

- You need graphfile or scorefile style outputs for downstream legacy
  tools.

- You are checking column coverage and metric consistency against a
  FACETS-style output contract.

## When not to use this layer

- For standard estimation, use
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  plus
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- For report bundles, use
  [mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md).

- For manuscript text, use
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  and
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md).

- For visual follow-up, use
  [mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md).

## Compatibility map

- [`facets_positioning_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_positioning_guide.md):

  User-facing wording for the package's relationship to FACETS. Use
  before describing compatibility outputs in a report or migration note.

- [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md):

  One-shot legacy-compatible wrapper that fits, diagnoses, and returns
  key tables in one object.

- [`mfrmRFacets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md):

  Alias for
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  kept for continuity.

- [`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md):

  Fixed-width interaction and pairwise text blocks. Best when a
  text-only compatibility artifact is required.

- [`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_file_bundle.md):

  Graphfile/scorefile style CSV and fixed-width exports for legacy
  pipelines.

- [`write_mfrm_residual_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_residual_file.md):

  Package-native observation-level residual CSV/TSV export for reviewer,
  spreadsheet, or external QC handoff.

- [`write_mfrm_subset_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_subset_file.md):

  Package-native connected-subset summary and node-membership CSV/TSV
  export for linking review handoff.

- [`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_contract_review.md):

  Column and metric review against the FACETS-style output-contract
  specification. Use only when an explicit output-contract review is
  part of the task; it checks the package output contract and does not
  imply external FACETS equivalence.

## Preferred replacements

- Instead of
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md),
  prefer:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  -\>
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  -\>
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md).

- Instead of
  [`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md),
  prefer:
  [`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md)
  -\>
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).

- Instead of
  [`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_file_bundle.md),
  prefer:
  [`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md)
  or
  [`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_structure_report.md)
  plus
  [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md).

- For residual or subset handoff, prefer
  [`write_mfrm_residual_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_residual_file.md)
  and
  [`write_mfrm_subset_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_subset_file.md)
  over reusing graph/score compatibility exports.

- Instead of
  [`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_contract_review.md)
  for routine QA, prefer:
  [`reference_case_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/reference_case_review.md)
  for package-native completeness review or
  [`reference_case_benchmark()`](https://ryuya-dot-com.github.io/mfrmr/reference/reference_case_benchmark.md)
  for packaged benchmark cases.

## Multiple-imputation review and intervals in 0.2.4

Re-run
[`pool_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/pool_mfrm_imputed.md)
on saved, valid
[`fit_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_imputed.md)
analyses to obtain `IntervalReason` and saved inference notes, then
recreate plots and exports. No new imputations or fitted analyses are
needed for the interval arithmetic update. Numerically unresolved
intervals keep their estimates and variances with missing bounds. Older
saved tables lack this audit.

[`review_mfrm_imputations()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md)
now rejects numeric IDs that collapse to the same text and detects
changes to observed numeric predictors without text rounding. Numeric
predictors must stay numeric in completed data; integer and double
storage are interchangeable. Pooling rechecks the original roster and
saved assignment/support review. Correct changed inputs from their
original evidence and recreate affected reviews/analyses; do not
overwrite original values to make an invalid completion pass.

## Expected agreement and accuracy identifiers in 0.2.4

Regenerate
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
from the saved fit, then recreate
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
and derived reports or exports. Calibration refitting is unnecessary.
Observed agreement remains available when primary fitted estimates are
unavailable; model-expected agreement is withheld instead of using
finite optimizer proxies. New `ExpectedReason` fields distinguish these
cases from repeated ratings and unavailable probabilities. Older
diagnostics do not contain this audit; reports identify its absence and
request regeneration before interpreting model expectations. The MML
baseline remains a conditional EAP plug-in quantity, not
posterior-integrated agreement.

[`fit_rater_accuracy()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_rater_accuracy.md)
rejects numeric identifiers whose conversion to text would merge
distinct values. Replace them with unambiguous character IDs from the
original data before fitting; already rounded text cannot recover the
original identities. Previously affected accuracy fits need to be
regenerated from corrected input.

## Halo-network inference in 0.2.4

Recreate
[`rater_halo_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_halo_network_analysis.md)
results from the original fit and matching saved diagnostics before
summary, plotting or export. No model refit is needed. Older results
lack the Person-level availability audit and are rejected by summary and
plot methods. Correlations remain available when Persons repeat across
shared contexts, but ordinary independent-pair p-values are withheld
with counts and reasons. Context definitions omitting `"Person"` also
provide descriptive correlations only. Use `alpha = 1` for an explicitly
descriptive graph without a p-value filter; this does not supply missing
inference. Regenerate derived plots and CSV files.

## Simulation, assignment review and GPCM guidance in 0.2.4

These old public function names have been replaced, rather than retained
as callable aliases. Their help aliases lead to the new topics.

|  |  |  |
|----|----|----|
| Former call | Current call | What it does |
| `evaluate_mfrm_recovery(...)` | `simulate_mfrm_recovery(...)` | Generate data repeatedly, refit, and summarize parameter recovery. |
| `build_peer_review_design_review(x)` | `review_peer_design(x)` | Read existing peer-assessment assignment metadata; no assignment generation or model fitting. |
| `gpcm_score_side_contract(status)` | `gpcm_capability_matrix(status, view = "scores")` | Read score availability, limitations and alternatives. |
| [`gpcm_runtime_guard_coverage()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md) | `gpcm_capability_matrix(view = "unavailable")` | Read blocked/deferred workflows and alternatives. |

`assess_mfrm_recovery(x, ...)` keeps its name: it applies review
thresholds to an existing simulation result without generating data or
refitting. Unused arguments are now rejected, so misspelled options
cannot silently leave a requested threshold unapplied. Review thresholds
are aids to interpretation, not universal validity criteria.

The simulation and peer-design replacements retain their argument lists,
defaults, numerical calculations and result classes. Existing RDS
objects still work with
[`summary()`](https://rdrr.io/r/base/summary.html), supported
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods and
reporting helpers; no re-estimation or class relabelling is needed for
these naming changes. Each GPCM view retains its previous columns and
status meanings. The default workflow view is unchanged apart from
updated route names. Existing scorefile bundles keep the component
`gpcm_score_side_contract` and its CSV filename for saved-output
compatibility; this field name is not a callable function.

## CSV export name in 0.2.4

Replace `export_mfrm(fit, ...)` with
[`export_mfrm_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_tables.md)
using the same arguments. The old function is no longer exported; its
help alias opens the replacement's help. CSV filenames, numeric values
and the returned file table are unchanged by the rename. Enriched facet
CSVs additionally retain diagnostic availability, SE/inference
qualifications and reasons, and follow the source facet-table order.
Existing fits do not need re-estimation; regenerate older CSVs from the
fit and matching diagnostics to include these fields. Do not infer
approval from their absence in an older CSV.

[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
and
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
retain their names because they serve different tasks: the former
archives an existing results object and reloads its RDS, while the
latter prepares fit-level artifacts with an optional refitting recipe.
Neither is an alias for the CSV-only exporter. ZIP replacement now
includes only files written by the current call; older members are not
carried forward. If ZIP creation fails, the prior archive is retained
but is not reported as a successful current export. See
[mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md)
for the saving routes.

## Practical migration rules

Recompute older
[`mantel_haenszel_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/mantel_haenszel_table.md)
results from their original input data if large strata produced
integer-overflow warnings or unavailable odds ratios/tests/intervals.
Merely reopening the saved list does not repair it. The corrected
calculation preserves the statistical method, matching and multiplicity
settings; no MFRM fitting is involved. Regenerate CSV exports from the
new result.

- Start FACETS-facing reports with
  [`facets_positioning_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_positioning_guide.md)
  when readers might otherwise assume FACETS numerical reproduction.

- Keep compatibility wrappers only where a downstream consumer truly
  needs the old layout or fixed-width format.

- For new scripts, start from package-native bundles and add
  compatibility outputs only at the export boundary.

- Treat compatibility outputs as presentation contracts, not as the
  primary analysis objects.

- Use
  [`compatibility_alias_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/compatibility_alias_table.md)
  when you need to check which aliases are still retained and which
  package-native names should be used in new code.

- Use `reporting_checklist(fit)$software_scope` to review the current
  FACETS, ConQuest, and SPSS relationship wording for a fitted analysis.

## G/D-study entry points in 0.2.4

Use
[`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md)
for one or several observed score columns and
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
for the resulting assessment plans. The former public names are replaced
as follows:

|  |  |
|----|----|
| Former call | Current call |
| `mfrm_multivariate_gstudy(data, scores, ...)` | `mfrm_g_study(data, scores, ...)` |
| `mfrm_multivariate_d_study(g, plans, weights)` | `mfrm_d_study(g, plans, weights = weights)` |
| `mfrm_d_study(main_effects, plans, residual_scaling = ...)` | Same call; the main-effects approximation is retained. |

The two former long names are no longer exported functions; their help
aliases lead to the replacement pages. Constructor arguments,
ANOVA/MINQUE defaults, result classes and stored estimates are
preserved. Existing G/D RDS files can be reloaded and passed to
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md),
[`summary()`](https://rdrr.io/r/base/summary.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) and the same
supported interval methods without re-estimation. This naming change
alone does not require recreating a saved analysis.

Both D-study routes accept facet labels or `n_<facet>` count columns,
for example `n_Rater` and `n_Task`. Existing task/rater `Raters`/`Tasks`
names remain accepted for results that use them. Supply one count per
facet; duplicate aliases, extra columns and ambiguous matches are
errors. Returned count columns retain the source result's convention so
plot selections and saved interval identities stay unchanged. A nested
child count still means children per parent, not the total number of
children.

`summary(d)` returns the coefficient data frame for either route. For a
main-effects D-study this replaces generic per-column descriptive
summaries; use `summary(as.data.frame(d))` if those summaries were
intended. Unsupported arguments to an already estimated G-study are now
rejected instead of ignored. Composite weights require the
score-component route; `residual_scaling` belongs only to the
main-effects approximation. Supplying a fitted MFRM still estimates a
separate observed-score main-effects G-study first. Dispatch does not
change an estimator or add interval support to that approximation.

## Standard R extraction in 0.2.4

Native fits now have documented [coefficient, covariance, likelihood and
count
methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md).
Previously, `coef(fit)` could fall through to `NULL`, and ordinary MML
fits lacked [`vcov()`](https://rdrr.io/r/stats/vcov.html) and
[`logLik()`](https://rdrr.io/r/stats/logLik.html). Use `coef(fit)` for
free coordinates matched to `vcov(fit)`, or
`coef(fit, type = "locations")` for labelled saved facet locations.
These vectors answer different questions; do not combine a component
vector with the free-coordinate covariance without its constraint map.
Existing `summary(fit)` tables remain the route to estimates with status
and interpretation. CML's existing covariance and likelihood values
retain their meanings; the new
[`coef()`](https://rdrr.io/r/stats/coef.html) uses the same conditional
coordinates.

`confint(fit)` now returns pointwise intervals for those default
coefficients for supported native MML/CML fits. Use names or integer
positions in `parm` to select coefficients. The matrix carries
estimates, SEs, availability reasons and checks in its attributes;
comparison-only CML retains missing rows for unidentified targets. JML
structural-truth intervals remain unsupported. CML uses saved
conditional information; MML applies the same covariance qualification
as [`vcov()`](https://rdrr.io/r/stats/vcov.html).

**Breaking change for GPCM:** replace `confint(fit, ...)` with
`confint(fit, parm = "slopes", ...)` when requesting slope intervals,
ratios/differences, standardization, sandwich or profile inference, or
preparing slope plots/report attachments. The default coefficient matrix
uses free log-slope coordinates and is a different target. Supplying
slope options without `parm = "slopes"` is rejected. Existing saved
slope-interval objects remain reusable; no refit or recomputation is
needed merely to change the call syntax. Bootstrap-result and
extended-model methods retain their own defaults. See
[`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md).

`nobs(fit)` counts Persons for MML/CML and retained ratings for JML. Use
`nobs(fit, type = "ratings")` for a response-row count in every method.
`logLik(fit)` retains the likelihood basis and information-criterion
reason; unqualified ordinary results give `df = NA`, so AIC/BIC remain
unavailable. Multiple-model
[`AIC()`](https://rdrr.io/r/stats/AIC.html)/[`BIC()`](https://rdrr.io/r/stats/AIC.html)
calls now direct users to
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
rather than allowing conditional and marginal likelihoods to be mixed.
Current native saved fits can use these methods after reloading; source
objects are not rewritten. Legacy likelihood metadata,
corrected/penalized objectives and unsupported model classes require
their documented summaries.

Native ordinary fits also support [fitted rating and residual
methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_responses.md).
Previously `fitted(fit)` and `residuals(fit)` could silently return
`NULL`. They now return retained-row vectors;
`fitted(fit, type = "prob")` returns category probabilities.
`predict(fit)` has the same source-rating target.
`predict(fit, newdata = ...)` is explicitly unsupported; retain
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
or
[`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
for ability scoring from supplied responses. These targets must not be
interchanged.

MML probabilities are evaluated at the saved EAP, not averaged over its
posterior distribution. JML uses primary estimates, including limiting
probabilities for extreme Persons. Zero-variance Pearson residuals are
missing with a reason. Legacy
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
helpers retain finite JML optimizer proxies and their small-variance
cutoff, so values can differ at these limits. Diagnostic
observation/score/residual tables now include `PrimaryPersonMeasure`,
`PersonMeasureBasis`, `ConditionalVariance`, `PearsonAvailable` and
row-specific reasons. Overall/element mean squares are unavailable when
any contributing standardized residual, variance or weight is
unavailable; `FitAvailableRows`, `FitUnavailableRows` and `FitReason`
expose that coverage. Older diagnostics could effectively count missing
residuals as zero misfit. Regenerate them and their exports from the
saved fit, without refitting. MML response calculations now match
Persons by identifier even when the saved Person table is reordered.

Read the `diagnostics`, `settings`, `score_map` and `source_readiness`
attributes; values alone do not establish fit or inference readiness.
Outputs align with `fit$prep$data`, not an unfiltered input table.
Existing saved fits can be reused without refitting. When old objects
lack omitted-row identities, their original `InputRow` positions remain
`NA`; retained-row order is still available. CML and comparison-only
results now explicitly refuse this unsupported Person plug-in target
instead of letting
[`fitted()`](https://rdrr.io/r/stats/fitted.values.html)/[`residuals()`](https://rdrr.io/r/stats/residuals.html)
fall through to `NULL`.

## Input normalization corrections in 0.2.4

The shared preparation used by
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
and anchor review now rounds scores within `1e-6` of an integer to that
integer. Earlier preparation accepted that tolerance but then truncated
toward zero: for example, `1.9999999` could become category 1 rather
than category 2. The new `score_roundoff_normalized` preparation note
records affected retained rows. Genuine fractional responses still
require explicit recoding. Corrected JML and two-family GPCM retain
their stricter exact-integer input checks; explicitly normalize roundoff
before using those specialized fits. Numeric observation weights no
longer pass through character formatting; their supplied precision is
retained. Out-of-range integer category codes, nonrepresentable category
spans and overflowing retained-weight totals are refused before
likelihood construction.

Grouped and rowwise tibbles now behave like their ungrouped versions.
Only selected model columns enter preparation; grouping on an unused
column does not add that column to the design or remove rows for its
missing values. This is one combined analysis, not a separate model for
each dplyr group.

Facets named `Person`, `Score`, `Weight`, `score_k`, `theta`, `steps`,
`interactions`, `log_slopes`, `beta` or `log_sigma2` are now refused
before they can collide with internal data or parameter blocks. Rename
the facet and update the `facets` argument and any step/slope-owner or
anchor references to it. This restriction does not prevent using those
names for their intended person, score or observation-weight roles. For
example, rename a facet column `steps` to `Stage` and replace
`facets = c("Rater", "steps")` with `facets = c("Rater", "Stage")`, also
updating any `step_facet`, `slope_facet`, interaction and anchor
references. Similar names such as `log_sigma2_group` remain supported.
Internal parameter lookup now matches names exactly, preventing those
columns from being mistaken for population or slope parameters when
those blocks are absent. Older fits using such prefixes should be
refitted with the same settings if their calculation entered an affected
path, including adaptive MML, where the former partial matching could
alter the gradient.

If an older fit was affected by category truncation or a column
collision, refit from the original corrected data and regenerate its
derived results. Editing `prep$data`, `score_map`, parameter names or
identity metadata in a saved fit cannot repair estimates computed from a
different response coding. Exact integer inputs with ordinary facet
names keep their existing preparation behavior.

## Likelihood and convergence corrections in 0.2.4

JML/MML category and posterior normalization now preserve probabilities
and log likelihoods when finite log weights share a large offset.
Earlier paths could lose the normalizing term through cancellation, even
though no exponential overflow occurred. Fits whose estimates or
numerical checks entered this regime need refitting with the same
data/model and a new numerical review. Saved estimates and derived
outputs do not update when the package is updated; do not edit their
stored likelihood or readiness flags.

Optimizer code zero no longer gives a numerical pass when the terminal
gradient is absent, incomplete or contains NA/NaN/Inf. In that case the
result reports `code_zero_unavailable_gradient` and remains review-only.
Older saved fits with missing or nonfinite gradient diagnostics must not
be treated as qualified merely because their stored convergence code is
zero. Refitting under the current checks is required before relying on
their numerical-readiness claim. A finite recorded norm alone cannot
establish that an older full gradient was valid, because earlier code
discarded nonfinite entries when calculating that norm. These
corrections do not change the response model, estimator, quadrature
order or tolerance.

Optimizer polishing now rejects candidates with a worse likelihood
beyond floating-point rounding error, even if their terminal gradient is
smaller. Earlier acceptance used a relative allowance that grew with the
objective magnitude. If a saved fit selected such a worse polishing
stage, refit with the original data/model/settings and regenerate
dependent inference; editing its saved optimizer history does not repair
the retained estimates. MML solution checks now return an ineligible
result with a reason when likelihood, gradient-norm or information
summaries are missing or invalid.

Two-family GPCM/GMFRM EM also uses the stable Person-posterior
normalization: large common log likelihoods no longer erase quadrature
weights or inflate expected response counts. Its log-slope derivatives
and the ordinary GPCM JML/MML derivatives avoid cancellation at large,
nearly tied category logits. Refit calibrations affected by these
numerical defects with their original data and model settings before
reusing inference.

GPCM profile intervals now require positive nuisance curvature at both
integration orders, in addition to their existing optimizer, gradient
and start-agreement checks. A shared stationary point need not maximize
the constrained likelihood. Recompute saved profile intervals with
`confint(fit, parm = "slopes", method = "profile", slope = ...)` to
apply this additional check; stored intervals do not update
automatically. The source calibration can be reused if it remains
eligible and was unaffected by the fitting corrections above. An
unresolved curvature check leaves missing bounds and a reason; it does
not prove that an interval does not exist. Passing these local checks
does not establish a global optimum or sampling coverage.

## Updating saved ability scores in 0.2.4

New-Person and portable-calibration scoring now remove common
log-likelihood offsets before applying quadrature weights. This prevents
distorted EAPs and posterior SDs when finite likelihood terms are very
large in magnitude. Continuous posterior intervals and cut-score
probabilities likewise center the likelihood before adding the prior
density; otherwise even an ability-independent likelihood could change a
normal-prior interval.

Recompute affected scores with
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
or
[`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md),
preserving the input rows, calibration, scoring prior, weights, interval
level and any cut scores. Regenerate plausible values with the original
seed and settings using
[`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md).
Saved summaries and draws do not update automatically. A scoring-only
correction can reuse an eligible unchanged calibration; if its fitted
likelihood or convergence checks were affected by the corrections above,
refit and review that calibration first. Intervals remain conditional on
the point calibration and supplied prior; this correction does not
establish frequentist coverage or include calibration uncertainty.

The same likelihood-centering correction applies to ordinary
source-Person, testlet and shared-rater continuous scoring. Recompute
source scores with
[`score_mfrm_persons()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_persons.md).
For a supplied roster, use
[`predict.mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict.mfrm_testlet.md)
or
[`score_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_random_rater.md)
with the original complete roster and settings. Recompute affected
response diagnostics with
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md).
Testlet nested integration and the shared-rater likelihood also correct
cancellation at large finite category ties; calibrations affected during
estimation require refitting and renewed numerical checks before reuse.
Testlet derivatives now handle a single latent point without dropping a
matrix dimension. None of these corrections certify the separate
shared-rater Laplace approximation or calibration-adjusted interval
coverage.

## Updating saved diagnostics in 0.2.4

When a report, plot, bias screen or export accepts both `fit` and
`diagnostics`, the diagnostic object must describe that same fitted
analysis. Matching person/facet labels or location estimates alone is
insufficient: thresholds, population specification, integration settings
and retained observations must also agree. A mismatched pair now raises
an error instead of combining results or silently substituting newly
computed diagnostics.

Corrected diagnostic and bias bundles carry `calculation_version = 2`.
Earlier bundles must be recreated from the saved fit, including
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
and derived reports. Corrections affect PTMEA, ZSTD, displacement,
chi-square df, PCM fair scores, bias expectations and summary tests, and
unexpected-response screening. The diagnostic default is now
`fit_df_method = "facets"`. Fit-measure tables and ZSTD fit-pathway
plots use this default too; request the explicit engine option for
historical df. `whexact = TRUE` now means FACETS WHEXACT=NO; use
`"legacy_linear"` for its former calculation. Reproducing the former
engine convention also requires `fit_df_method = "engine"`. The former
unexpected-response rule is explicit `abs_z_min = 2, rule = "either"`.
Pairwise reports now use modified Rasch-Welch df rounded down by
default; `df_method = "classical"` retains the former continuous
reference. Recreate those reports to obtain `CalculationVersion = 3`.
Recompute rather than inserting a version field into an old object.
These are diagnostic changes and do not require a main calibration
refit.

Older native diagnostics that lack a saved calibration identity are also
refused when paired with a fit. For native models supported by
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
regenerate diagnostics from the original saved fit; the model does not
need to be refitted. Reuse the diagnostic options from your original
analysis, such as `diagnostic_mode` and `residual_pca`. For example, if
the original options were `"legacy"` and `"none"`:


    fit <- readRDS("fit.rds")
    diagnostics <- diagnose_mfrm(
      fit, diagnostic_mode = "legacy", residual_pca = "none"
    )
    saveRDS(diagnostics, "diagnostics-0.2.4.rds")
    report <- facet_quality_dashboard(fit, diagnostics = diagnostics)

Function signatures and result-table columns are unchanged by this
identity check. Helpers that explicitly accept diagnostics alone, such
as `fit_measures_table(diagnostics)`, still support that input; it does
not establish a match to another fit. Imported diagnostics must be the
bundle stored in the matching imported fit. These checks do not expand
the model families supported by ordinary diagnostics; for example,
native CML retains its separate interval/reporting workflow in
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md).

## Updating saved shrinkage results in 0.2.4

Reapply
[`apply_empirical_bayes_shrinkage()`](https://ryuya-dot-com.github.io/mfrmr/reference/apply_empirical_bayes_shrinkage.md)
to the saved fit using the original prior settings, then regenerate
plots and exports. No MFRM refit is needed. Updated reports record
`CalculationVersion = 2`; calculations avoid artificial zero SEs and
retained weights caused by subtracting a shrinkage factor rounded to
one.

`shrink_person = TRUE` now requires ordinary JML. For MML or other
estimators, use `shrink_person = FALSE`: this removes any previous extra
Person adjustment and retains the original Person estimates. MML EAP and
posterior SD already describe a posterior distribution; treating them as
an observation and sampling SE for another normal update is unsupported.
Non-Person facet adjustment remains available within its existing scope.

## Updating saved screening results in 0.2.4

Recompute
[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
and
[`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
from saved fitted waves to apply stable offset/SE calculations and
explicit unavailable states. No model refit is required. Singleton or
uncomputable residual spreads now remain missing, and summaries
distinguish unavailable flags from zero flagged elements. The result
records fallback and actual offset contributors; chains also record
unavailable cumulative sums. Earlier saved tables are not repaired by
loading them. Rebuild chains before requesting offset sensitivity if the
saved offsets no longer match the current arithmetic. Regenerate plots
and exports:
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
now uses the selected drift, wave estimate, cumulative offset or
common-element count instead of the first numeric column.

Rerun
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
with `method = "refit"` from the saved baseline fit and original data to
repair earlier subgroup results. This reruns subgroup estimation:
failed/skipped groups no longer borrow baseline estimates, absent target
levels remain visible, and sparsity/precision screens use retained
target-cell counts and shared-Person checks. Current summary, report and
plotting methods reject earlier refit objects; do not add the version
field by hand. Regenerate exported tables and figures.
Location-direction labels now describe parameter differences rather than
asserting that entire subgroup response curves are harder or easier.

Recompute older
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
/
[`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md)
results from the saved fit and matching diagnostics to obtain boundary
and complete-cell information/fit checks. Search-boundary estimates
remain points, with unavailable SEs and screening tail areas. Small
positive response variances contribute to information; missing residuals
no longer produce partial-cell Infit/Outfit. Facet labels containing
`||` now identify distinct cells correctly. The summary reports missing
screening counts and retains unavailable cells in Bonferroni/Holm family
sizes. These changes require re-screening, not refitting the
calibration; an old saved table is not recalculated by plotting or
printing it.

Results from
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md),
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`unexpected_after_bias_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_after_bias_table.md)
and
[`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md)
now carry a `fit_identity` field. When a consumer combines a supplied
result with a fit, it checks that they describe the same analysis. This
includes reports, dashboards, QC, export/replay helpers and
[`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md).
Every retained member and the primary result of a bias collection must
match. Matching facet labels alone is insufficient.

Older results without this metadata, and manually assembled bias tables,
cannot establish that match. Recreate the result from its saved fit and
matching diagnostics; do not add an identity field to an old table by
hand. Use the original facets, estimation limits, filtering rules and
thresholds. For example, if the original bias screen used these options:


    bias <- estimate_bias(fit, diagnostics,
      facet_a = "Rater", facet_b = "Criterion",
      max_abs = 10, omit_extreme = TRUE, max_iter = 2, tol = 1e-3)
    saveRDS(bias, "bias-0.2.4.rds")
    report <- build_apa_outputs(fit, diagnostics, bias_results = bias)

The same calls and table columns remain available; the added metadata is
stored alongside the tables. Recomputing the screen does not refit the
model. Standalone summary/plot methods keep their existing input
requirements and do not establish a relationship to a separately
supplied fit. These identity checks prevent accidental mixing; they do
not validate manually edited numbers or make a screening result eligible
for formal inference.

## Updating saved predictions in 0.2.4

[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
and
[`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
now retain a `fit_identity` field. Fit-level manifests, replay scripts
and archive exports require that identity to match the supplied
calibration, fitted population coding and source scoring status.
Recreate older outputs from the saved fit and original scoring inputs,
retaining the original column mappings, `person_data`, prior,
integration settings, omission policy and seed. This repeats scoring or
drawing plausible values, not estimation of the calibration model.
Standalone summary/plot methods retain their existing input rules; a
standalone table does not establish a match to another fit.

[`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
is a simulation-based design forecast. A result created with `fit = fit`
must match that source fit when attached to an archive. Recreating an
older fit-derived forecast repeats its simulations and replication fits;
the original calibration fit can be reused. A result created with
`sim_spec = spec` remains an explicitly supplied scenario and can
accompany a different fit. Its notes and the manifest's
`population_prediction_source` setting distinguish this from a forecast
derived from the attached fit. Do not change the source label of an old
result to bypass the check.

Generated replay scripts continue to use the saved simulation
specification. They reproduce those forecasting assumptions rather than
deriving new ones from the replayed calibration, which could change the
forecast. The recreated forecast is therefore labelled as a
supplied-specification scenario. Identity checks do not change scoring
uncertainty, eligibility or the interpretation of plausible values and
Monte Carlo forecast uncertainty.

## Updating saved structural reviews in 0.2.4

[`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md)
now saves `data_identity` metadata.
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
checks the reviewed column roles and retained rows, including scores
when ICC was computed. Raw-data reviews and reviews of a subset of
fitted facets remain supported when those data match; the checklist
names their scope. Row order, factor level order, unused columns and
fitted estimates are irrelevant to this descriptive-data match.
Different rating counts, assignments or ICC scores are not
interchangeable.

Recreate an older review from its saved fit or matching retained rows
using the original facets, person/score columns, ICC and connectivity
options, missing-value policy and interval settings (including bootstrap
seed). This repeats the requested structural/ICC review, not MFRM
estimation. Do not add identity metadata to old tables manually.
Standalone summary and plot methods retain their existing requirements.
Reviews of additional raw rows or grouping columns absent from the fit
must be reported separately; they cannot mark this fit's
structural-review checklist item as available. Recalculate nesting
reviews involving fractional/zero weights or missing facet values:
[`detect_facet_nesting()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_facet_nesting.md)
now uses weighted frequencies directly and one common set of observed
rows per pair. Earlier results rounded weights and mixed marginal and
conditional samples. Weight columns must now be numeric, finite and
nonnegative, with some positive weight; missing columns and invalid
values are refused instead of ignored or replaced. New
`UsedRows`/`ExcludedRows` columns record the pair-specific scope.

## Rating-count review corrections in 0.2.4

In
[`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md),
`facet_summary$WorstCategory` now selects the lowest count band,
correcting the previous highest-band aggregation. Recreate the review
from the saved fit to update older review objects. Count thresholds must
now be finite, positive and strictly increasing. The table columns and
default thresholds remain the same; the returned `notes` field explains
that counts are retained rating rows and cannot establish precision or
coverage.

In
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
the item formerly named `"Facet sample-size adequacy"` is now
`"Facet rating-count screening"`. Scripts selecting that item by its
text must use the new label. Its availability indicates that a count
screen is present, including sparse counts, rather than treating a high
count band as proof of sample adequacy.

## Retained table-field names

- `row_review` is the data-quality table field used to document row
  filtering. FACETS-style column and metric contract results are exposed
  as `column_review` and `metric_checks`.

- Prediction outputs expose row-preparation and person-omission
  traceability as `row_review` and `population_review`.

- `hierarchical_review`, `shrinkage_review`, and `nesting_review` are
  manifest or model-comparison traceability fields. They are not
  callable helper names; user-facing helper names use review/check
  terminology.

## Typical workflow

- Legacy handoff:
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  -\>
  [`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md)
  -\>
  [`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_file_bundle.md)
  plus
  [`write_mfrm_residual_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_residual_file.md)
  /
  [`write_mfrm_subset_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_subset_file.md)
  only when those standalone files are needed.

- Mixed workflow: `RSM` / `PCM`:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  -\>
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  -\>
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  -\> compatibility export only if required. `GPCM`:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  -\>
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  -\>
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  -\>
  [`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_file_bundle.md)
  only when a graph/score handoff is needed, retaining its
  package-native GPCM caveats.

- FACETS output-contract review:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  -\>
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  -\>
  [`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_contract_review.md).

## Companion guides

- For FACETS coverage and boundary wording, see
  [`facets_positioning_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_positioning_guide.md)
  and
  [`facets_feature_coverage()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_feature_coverage.md).

- For standard reports/tables, see
  [mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md).

- For manuscript-draft reporting, see
  [mfrmr_reporting_and_apa](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md).

- For visual diagnostics, see
  [mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md).

- For linking and DFF workflows, see
  [mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md).

- For end-to-end routes, see
  [mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md).

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("mfrmr_compatibility_layer", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
toy_small <- toy[toy$Person %in% unique(toy$Person)[1:12], , drop = FALSE]

run <- run_mfrm_facets(
  data = toy_small,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  maxit = 30
)
summary(run)
compatibility_alias_table("functions")

fixed <- build_fixed_reports(
  estimate_bias(
    run$fit,
    run$diagnostics,
    facet_a = "Rater",
    facet_b = "Criterion",
    max_iter = 1
  ),
  branch = "original"
)
names(fixed)

} # }
```
