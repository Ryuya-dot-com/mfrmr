# Review fit standardization against FACETS-style ZSTD conventions

Review fit standardization against FACETS-style ZSTD conventions

Review coverage of FACETS-style output fields

Review facet variability with chi-square reference screens

Build native graph and observation-score output files

## Usage

``` r
facets_fit_review(
  fit,
  diagnostics = NULL,
  facets_fit = NULL,
  facet_col = NULL,
  level_col = NULL,
  mnsq_tolerance = 0.01,
  external_zstd_tolerance = 0.05,
  df_tolerance = 0.5,
  df_zstd_tolerance = 0.05,
  df_zstd_large_shift = 0.5,
  df_ratio_tolerance = 0.05
)

facets_output_contract_review(
  fit,
  diagnostics = NULL,
  bias_results = NULL,
  branch = c("facets", "original"),
  contract_file = NULL,
  include_metrics = TRUE,
  top_n_missing = 15L
)

facets_chisq_table(
  fit,
  diagnostics = NULL,
  fixed_p_max = 0.05,
  random_p_max = 0.05,
  top_n = NULL
)

facets_output_file_bundle(
  fit,
  diagnostics = NULL,
  include = c("graph", "score"),
  theta_range = c(-6, 6),
  theta_points = 241,
  digits = 4,
  score_se_method = c("both", "native", "score_side", "none"),
  include_fixed = FALSE,
  fixed_max_rows = 400,
  write_files = FALSE,
  output_dir = NULL,
  file_prefix = "mfrmr_output",
  overwrite = FALSE
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  (used for score file). Must match this fitted analysis; see
  [mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)
  for migration of saved diagnostics. Exported score rows are
  observations, whereas FACETS Scorefile rows are elements. These
  formats are not interchangeable.

- facets_fit:

  Optional external FACETS results from
  [`read_facets_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_facets_results.md),
  a Scorefile/CSV path or `score.N.txt` directory, a data frame, or a
  list of those inputs. Rows are matched by `Facet` and `Level`; a
  person-only table with a `Person` column is also accepted.

- facet_col:

  Optional explicit column names for the external FACETS table when
  automatic detection is not sufficient.

- level_col:

  Optional explicit column names for the external FACETS table when
  automatic detection is not sufficient.

- mnsq_tolerance:

  Numeric tolerances used to classify external FACETS-vs-mfrmr
  differences.

- external_zstd_tolerance:

  Numeric tolerances used to classify external FACETS-vs-mfrmr
  differences.

- df_tolerance:

  Numeric tolerances used to classify external FACETS-vs-mfrmr
  differences.

- df_zstd_tolerance:

  Smallest absolute engine-vs-FACETS-style ZSTD difference treated as
  interpretively visible rather than rounding noise in `df_sensitivity`.
  Default `0.05`.

- df_zstd_large_shift:

  Absolute engine-vs-FACETS-style ZSTD difference labeled
  `large_zstd_shift` when the \|ZSTD\| flag status is unchanged. Default
  `0.5`.

- df_ratio_tolerance:

  Relative df-difference tolerance used to classify the within-mfrmr
  engine-vs-FACETS-style df difference; for example, `0.05` means a 5
  percent df difference.

- bias_results:

  Optional output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).
  If omitted and at least two facets exist, a 2-way bias run is computed
  internally.

- branch:

  Contract branch. `"facets"` checks FACETS-style contract columns.
  `"original"` adapts branch-sensitive contracts to the package's
  compact naming.

- contract_file:

  Optional path to a custom contract CSV.

- include_metrics:

  If `TRUE`, run additional numerical consistency checks.

- top_n_missing:

  Number of lowest-coverage contract rows to keep in `missing_preview`.

- fixed_p_max:

  Cutoff for the fixed-effect reference tail area.

- random_p_max:

  Cutoff for the random-spread reference tail area.

- top_n:

  Optional maximum number of facet rows to keep.

- include:

  Output components to include: `"graph"` and/or `"score"`.

- theta_range:

  Theta/logit range for graph coordinates.

- theta_points:

  Number of points on the theta grid for graph coordinates.

- digits:

  Rounding digits for numeric fields. `ConditionalVariance` in the score
  table and delimited export retains full precision so small positive
  variances remain distinguishable from zero.

- score_se_method:

  For `GPCM` scorefile exports, which observation-level score
  uncertainty columns to compute. `"both"` (default) includes native
  structural expected-score SEs and score-side delta-method SEs;
  `"native"` includes only the structural expected-score route;
  `"score_side"` includes only the score-side delta route; `"none"`
  records explicit `not_requested` status columns.

- include_fixed:

  If `TRUE`, include fixed-width text mirrors of output tables.

- fixed_max_rows:

  Maximum rows shown in fixed-width text blocks.

- write_files:

  If `TRUE`, write selected outputs to files in `output_dir`.

- output_dir:

  Output directory used when `write_files = TRUE`.

- file_prefix:

  Prefix used for output file names.

- overwrite:

  If `FALSE`, existing output files are not overwritten.

## Value

An `mfrm_facets_fit_review` bundle with:

- `summary`: one-row overview of within-mfrmr and external comparison
  counts

- `standardization`: the fit-standardization guide from diagnostics

- `df_sensitivity`: engine-vs-FACETS-style df/ZSTD comparison using the
  same row-level status taxonomy as
  `fit_measures_table()$df_sensitivity`

- `df_sensitive`: subset of `df_sensitivity` whose df convention changes
  the \|ZSTD\| flag or materially changes ZSTD interpretation

- `df_sensitivity_summary`: counts by df-sensitivity status

- `external_table_quality`: completeness and duplicate-key review for
  the supplied FACETS fit table, including reported-token and
  displayed-ZSTD boundary counts

- `external_comparison`: optional external FACETS-vs-mfrmr comparison

- `df_conversion_guide`: formulas, column map, and comparison decisions
  for FACETS-style df/ZSTD review

- `guidance`: interpretation notes

- `settings`: tolerances and review metadata

An object of class `mfrm_facets_contract_review` with:

- `overall`: one-row output-contract review summary

- `column_summary`: coverage summary by table ID

- `column_review`: row-level output-contract review

- `missing_preview`: lowest-coverage rows

- `metric_summary`: one-row metric-check summary

- `metric_by_table`: metric-check summary by table ID

- `metric_checks`: row-level metric checks

- `settings`: branch/contract metadata

A named list with:

- `table`: facet-level chi-square diagnostics

- `summary`: one-row summary

- `thresholds`: applied p-value thresholds

A named list including:

- `graphfile` / `graphfile_syntactic` when `"graph"` is requested

- `scorefile` when `"score"` is requested

- `graphfile_fixed` / `scorefile_fixed` when `include_fixed = TRUE`

- `written_files` when `write_files = TRUE`

- `settings`: applied options

## Details

This helper separates two questions that are often conflated when
comparing mfrmr output with FACETS:

- how much the package-native `engine` ZSTD changes when the same MnSq
  values are standardized with the FACETS/Wright-Masters fourth-moment
  df convention;

- when an external FACETS table is supplied, whether the FACETS-reported
  rows match mfrmr's FACETS-style companion columns closely enough for
  practical reporting.

The review is row-matched by `Facet` and `Level`. It treats MnSq, ZSTD,
and df differences separately because FACETS documentation makes the df
convention and Wilson-Hilferty/WHEXACT handling central to ZSTD
interpretation.

Two prior limitations also apply. For `method = "MML"` fits, residuals
are evaluated at shrunken EAP person measures while FACETS uses JMLE
estimates, so MnSq itself can differ before standardization; refit with
`method = "JML"` for a JMLE-style residual basis. And mfrmr withholds
ZSTD as `NA` when the applicable df falls below 1 (Wilson-Hilferty
instability), while FACETS under `WHEXACT` can report a value on the
same sparse cell; such NA-vs-finite pairs are availability differences,
not fit differences. Both notes are repeated in the returned `guidance`
table.

This function checks produced report components against a FACETS-style
output-contract specification (available through
`system.file("references", "facets_column_contract.csv", package = "mfrmr")`)
and returns:

- column-level coverage per contract row

- table-level coverage summaries

- optional metric-level consistency checks

It is intended to show users which FACETS-style output fields have a
package-native counterpart and which remain unavailable. It does not
establish external validity or software equivalence beyond the specific
schema/metric contract encoded in the contract file.

This helper summarizes facet-level variability with fixed and random
chi-square indices for spread and heterogeneity checks.

Legacy-compatible output files often include:

- graph coordinates for Table 8 curves (`GRAPH=` / `Graphfile=`), and

- observation-level modeled score lines (`SCORE=`-style inspection).

This helper returns both as data frames and can optionally write
CSV/fixed-width text files to disk.

`summary(out)` is supported through
[`summary()`](https://rdrr.io/r/base/summary.html). `plot(out)` is
dispatched through
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for class
`mfrm_output_bundle` (`type = "graph_expected"`, `"score_residuals"`,
`"obs_probability"`, `"score_se"`).

## GPCM boundary

This helper is unavailable for `GPCM` fits because the FACETS output
contract includes score-side rows whose measure-to-score and uncertainty
semantics are supported for the Rasch-family route, not for
free-discrimination `GPCM`. Use
`mfrmr_output_guide("gpcm_capabilities")` before routing a `GPCM` fit
into score-side compatibility-output helpers.

Coverage interpretation in `overall`:

- `MeanColumnCoverage` and `MinColumnCoverage` are computed across all
  contract rows (unavailable rows count as 0 coverage).

- `MeanColumnCoverageAvailable` and `MinColumnCoverageAvailable`
  summarize only rows whose source component is available.

`summary(out)` is supported through
[`summary()`](https://rdrr.io/r/base/summary.html). `plot(out)` is
dispatched through
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for class
`mfrm_facets_contract_review` (`type = "column_coverage"`,
`"table_coverage"`, `"metric_status"`, `"metric_by_table"`).

For `GPCM`, graph output and package-native scorefile output are
available with caveats. `include = "score"` returns observation-level
fitted expected score, residual, standardized residual,
observed-category probability, GPCM slope fields, and native structural
delta-method expected-score uncertainty and/or score-side delta-method
SEs when the required MML diagnostics are available. Use
`score_se_method` to choose `"both"` (default), `"native"`,
`"score_side"`, or `"none"`. The score-side route transforms a
logit-side standard error with the GPCM expected-score derivative
\\dE\[X\]/d\eta = \alpha Var(X)\\, where `ScoreSlope` is \\\alpha\\.
`ScoreSideLogitSE` remains on the logit side; `ScoreSideSE` and its
interval columns are on the expected-score scale. The scorefile also
carries explicit score-side caveat columns. It is not a FACETS
score-side equivalence file, does not export FACETS-equivalent
score-side standard errors, and does not establish an operational
score-scale decision. Use
`mfrmr_output_guide("gpcm_capabilities", view = "scores")` and
`mfrmr_output_guide("gpcm_capabilities")`
([mfrmr_gpcm_scope](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_gpcm_scope.md))
for the current scope.

## Interpreting output

- `overall`: high-level output-contract coverage and metric-check pass
  rates.

- `column_summary` / `column_review`: where output-schema mismatches
  occur.

- `metric_summary` / `metric_checks`: numerical consistency checks tied
  to the current contract.

- `missing_preview`: direct path to unresolved output-contract gaps.

&nbsp;

- `table`: facet-level fixed/random chi-square and p-value flags.

- `summary`: full-family available/unavailable counts and
  screen-positive counts, before `top_n` limits displayed rows.

- `thresholds`: p-value criteria used for flagging.

Use this table together with inter-rater and displacement diagnostics to
distinguish global facet effects from local anomalies.

- `graphfile`: legacy-compatible wide curve coordinates (human-readable
  labels).

- `graphfile_syntactic`: same curves with syntactic column names for
  programmatic use.

- `scorefile`: observation-level observed/expected/residual diagnostics.

- `written_files`: traceability record of files produced when
  `write_files = TRUE`.

For reproducible pipelines, prefer `graphfile_syntactic` and keep
`written_files` in run logs.

## Typical workflow

1.  Run `facets_output_contract_review(fit, branch = "facets")`.

2.  Inspect `summary(contract_review)` and `missing_preview`.

3.  For unresolved rows, use the documented package-native alternative
    or retain the scope limitation in the report.

&nbsp;

1.  Run `facets_chisq_table(fit, ...)`.

2.  Inspect `summary(chi)` then facet rows in `chi$table`.

3.  Visualize with [plot(x, type =
    "facets_chisq")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md).

&nbsp;

1.  Fit and diagnose model.

2.  Generate bundle with `include = c("graph", "score")`.

3.  Validate with `summary(out)` / `plot(out)`.

4.  Export with `write_files = TRUE` for reporting handoff.

## Saved-result reuse

Supplied screening results must describe this fitted analysis. Results
from another fit or older results without identity metadata are refused.
See
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)
to recreate them from the saved fit and matching diagnostics without
refitting the model.

## Output columns

The `table` data.frame contains:

- Facet:

  Facet name.

- Levels:

  Number of estimated levels in this facet.

- MeanMeasure, SD:

  Mean and standard deviation of level measures.

- FixedChiSq, FixedDF, FixedProb:

  Sum of squared deviations from the inverse-SE-squared weighted mean,
  weighted by inverse SE squared, with a chi-square reference using
  eligible-level count minus one. Cross-level covariance is omitted;
  this is a heterogeneity screen, not a generally calibrated joint test
  of equal facet locations.

- RandomChiSq, RandomDF, RandomProb, RandomVar:

  FACETS-form random spread index and reference tail area. It does not
  establish normality or random sampling: with equal SEs and positive
  adjusted variance the statistic is identically eligible-level count
  minus one, regardless of distributional shape. Full covariance is not
  propagated.

- FixedFlag, RandomFlag:

  Logical flags for the requested reference-tail cutoffs.

## Preferred route for new analyses

For new scripts, prefer
[mfrm_report_category_curves](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
or
[mfrm_report_category_structure](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
for scale outputs, then use
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
for file handoff. Use `facets_output_file_bundle()` for its native
graph/observation-row contract. Its score file is not the element-level
FACETS Scorefile format; use
[`read_facets_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_facets_results.md)
to import actual FACETS element output.

## See also

[`read_facets_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_facets_results.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
`facets_output_contract_review()`,
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md),
[plot(x, type =
"facets_chisq")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

[mfrm_report_category_curves](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md),
[mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("facets_fit_review", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
review <- facets_fit_review(fit)
summary(review)
} # }
# Long-running workflow; run explicitly when needed.
# example("facets_output_contract_review", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
contract_review <- facets_output_contract_review(fit, diagnostics = diag, branch = "facets")
summary(contract_review)
p <- plot(contract_review, draw = FALSE)
} # }
# Optional workflow; run the example explicitly as shown below.
# example("facets_chisq_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
chi <- facets_chisq_table(fit)
summary(chi)
p_chi <- plot(chi, draw = FALSE)
plot_data(p_chi, "plot")
} # }
# Long-running workflow; run explicitly when needed.
# example("facets_output_file_bundle", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
out <- facets_output_file_bundle(fit, diagnostics = diagnose_mfrm(fit, residual_pca = "none"))
summary(out)
p_out <- plot(out, draw = FALSE)
plot_data(p_out, "plot")
} # }
```
