# Build reports from measurement, G-Study/D-Study, or residual results

Render completed analyses into structured R bundles, Markdown, HTML, or
table lists without refitting or upgrading inference. Pass
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
for consolidated measurement reports (`type = NULL`), G-Study/D-Study,
network, bias, anchor, or posterior results directly, or select a
focused component `type` on a native fit, bias, or DFF object.

## Usage

``` r
# S3 method for class 'mfrm_reporting_checklist'
summary(object, top_n = 10, ...)

mfrm_report(
  x,
  style = c("qc", "apa", "validation", "reviewer", "technical", "rater"),
  output = c("object", "markdown", "html", "tables"),
  facet = NULL,
  rater = NULL,
  audience = c("rater", "researcher"),
  label = NULL,
  max_cases = 5,
  interval = NULL,
  intervals = NULL,
  study_context = NULL,
  type = NULL,
  ...
)
```

## Arguments

- object:

  For `summary.mfrm_reporting_checklist()`, an
  `mfrm_reporting_checklist` object and preview row count (`10`
  default).

- top_n:

  For `summary.mfrm_reporting_checklist()`, an
  `mfrm_reporting_checklist` object and preview row count (`10`
  default).

- ...:

  Named component options when `type` is non-`NULL` (extra arguments
  without `type` are rejected).

- x:

  An
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
  bundle, a supported G-Study/D-Study, network, posterior,
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
  [`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md),
  [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
  [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md),
  [`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_model_choice_review.md),
  or
  [`recommend_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/recommend_mfrm_design.md)
  object; or, when `type` is non-`NULL`, the input required by that
  component.

- style:

  Consolidated report emphasis: `"qc"` (default), `"apa"`,
  `"validation"`, `"reviewer"`, `"technical"`, or `"rater"` (standalone
  recipient-safe sheet for additive RSM/PCM or two-family GPCM MML;
  requires `facet` and `rater`).

- output:

  Return format when `type = NULL`: `"object"` (`mfrm_report`, or
  `mfrm_rater_feedback` when `style = "rater"`), `"markdown"`, `"html"`,
  or `"tables"`.

- facet:

  Rater-sheet controls for `style = "rater"`: modeled rater `facet` and
  level `rater`, `audience` (`"rater"` or `"researcher"`),
  recipient-facing `label` (`"Selected rater"` default; source IDs are
  omitted), unexpected-case count (`5` default, `0` omits cases), and
  optional named saved `interval` attachment.

- rater:

  Rater-sheet controls for `style = "rater"`: modeled rater `facet` and
  level `rater`, `audience` (`"rater"` or `"researcher"`),
  recipient-facing `label` (`"Selected rater"` default; source IDs are
  omitted), unexpected-case count (`5` default, `0` omits cases), and
  optional named saved `interval` attachment.

- audience:

  Rater-sheet controls for `style = "rater"`: modeled rater `facet` and
  level `rater`, `audience` (`"rater"` or `"researcher"`),
  recipient-facing `label` (`"Selected rater"` default; source IDs are
  omitted), unexpected-case count (`5` default, `0` omits cases), and
  optional named saved `interval` attachment.

- label:

  Rater-sheet controls for `style = "rater"`: modeled rater `facet` and
  level `rater`, `audience` (`"rater"` or `"researcher"`),
  recipient-facing `label` (`"Selected rater"` default; source IDs are
  omitted), unexpected-case count (`5` default, `0` omits cases), and
  optional named saved `interval` attachment.

- max_cases:

  Rater-sheet controls for `style = "rater"`: modeled rater `facet` and
  level `rater`, `audience` (`"rater"` or `"researcher"`),
  recipient-facing `label` (`"Selected rater"` default; source IDs are
  omitted), unexpected-case count (`5` default, `0` omits cases), and
  optional named saved `interval` attachment.

- interval:

  Rater-sheet controls for `style = "rater"`: modeled rater `facet` and
  level `rater`, `audience` (`"rater"` or `"researcher"`),
  recipient-facing `label` (`"Selected rater"` default; source IDs are
  omitted), unexpected-case count (`5` default, `0` omits cases), and
  optional named saved `interval` attachment.

- intervals:

  Optional saved `confint(x)` result (or list) for G-Study / D-Study
  reports (`NULL` reports points without computing intervals).

- study_context:

  Optional named nonblank character vector of user study declarations
  (`question`, `rating_unit`, `score_direction`, `rubric`, etc.); stored
  verbatim without recoding data or altering eligibility.

- type:

  `NULL` (consolidated report) or one of the 13 component report types
  listed below.

## Value

For [`summary()`](https://rdrr.io/r/base/summary.html): An object of
class `summary.mfrm_reporting_checklist` with:

- `overview`: run-level counts of available and draft-ready items

- `section_summary`: section-level checklist coverage

- `software_scope`: external-software relationship summary

- `facets_positioning`: report-ready FACETS relationship wording

- `visual_scope`: available plots and data for custom rendering,
  including the main `InterpretationCheck` caveat for each type of plot

- `priority_summary`: counts by priority/severity

- `action_items`: highest-priority rows that still need draft work

- `settings`: checklist settings rendered as a compact table

- `notes`: interpretation notes

With non-`NULL` `type`, the component's `mfrm_bundle` or
`mfrm_reporting_checklist` object. With `type = NULL`, an `mfrm_report`
(`mfrm_rater_feedback` for `style = "rater"`), Markdown string,
`mfrm_report_html`, or named list of `data.frame`s.

## Details

[`summary()`](https://rdrr.io/r/base/summary.html) method: Summarize a
reporting-checklist bundle for manuscript work

**Reading order and rater-sheet privacy.** For consolidated reports,
inspect `first_screen`, `report_index`, `claim_readiness`,
`report_gaps`, and `template_index`
(`summary(report, view = "reader")`). Standalone `style = "rater"`
sheets include only recipient-safe summaries and fixed guidance
(`uncertainty` withholds both bounds when unavailable rather than
showing partial or zero-width intervals) and omit source fits, Person
IDs, other rater IDs, and free-form notes.

## Component reports (`type = ...`)

|  |  |  |
|----|----|----|
| `type` (former alias) | Input | Key `...` options and returned tables |
| `"specifications"` (`specifications_report`) | `mfrm_fit` | `title`; model/constraint/control summary bundle |
| `"data_quality"` (`data_quality_report`) | `mfrm_fit` or data | `min_category_count`, `min_facet_count`; `row_review`, category/facet counts |
| `"category_structure"` (`category_structure_report`) | `mfrm_fit` | `diagnostics`; category counts, steps, ordering/collapse flags |
| `"category_curves"` (`category_curves_report`) | `mfrm_fit` | `theta_range`, `theta_points`, `newdata`; conditional probability/expected grids |
| `"facet_statistics"` (`facet_statistics_report`) | `mfrm_fit` | `diagnostics`; per-facet distribution, separation, and fit summaries |
| `"precision"` (`precision_review_report`) | `mfrm_fit` / `mfrm_diagnostics` | `diagnostics`; SE basis, separation tiers, availability reasons |
| `"checklist"` (`reporting_checklist`) | `mfrm_fit` | `diagnostics`, `hierarchical`, `include_references`; `checklist`, `section_summary`, `visual_scope`, `software_scope` |
| `"reference_review"` (`reference_case_review`) | `mfrm_fit` | `diagnostics`, `bias`; schema and numerical consistency review |
| `"iterations"` (`estimation_iteration_report`) | `mfrm_fit` | `max_iter`; replays optimization from initial values (not stored trace) |
| `"bias_interaction"` (`bias_interaction_report`) | `mfrm_bias` or `mfrm_fit` | `facet_a`, `facet_b`, `diagnostics`; ranked conditional interaction cells |
| `"bias_iterations"` (`bias_iteration_report`) | `mfrm_bias` or `mfrm_fit` | Bias recalibration iteration history |
| `"bias_pairwise"` (`bias_pairwise_report`) | `mfrm_bias` or `mfrm_fit` | `target_facet`, `context_facet`; within-target pairwise bias contrasts |
| `"dff"` (`dif_report`) | `mfrm_dif` | Method-specific DFF narrative, cell counts, and link status |

## References

- Brennan, R. L. (2003). CASMA Research Report No. 1, University of
  Iowa.

- Jiang, Z., et al. (2022). *Educ. Psychol. Meas.*, 82, 705–718.
  [doi:10.1177/00131644211033899](https://doi.org/10.1177/00131644211033899)
  .

## See also

mfrm_report_checklist,
[summary.mfrm_apa_outputs](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)

[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("summary.mfrm_reporting_checklist", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", quad_points = 7, maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "both", diagnostic_mode = "both")
chk <- mfrm_report(type = "checklist", fit, diagnostics = diag)
summary(chk)
} # }
# Long-running workflow; run explicitly when needed.
# example("mfrm_report", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
ratings <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(
  data = ratings, person = "Person", facets = c("Rater", "Criterion"),
  score = "Score", rating_min = 1, rating_max = 4,
  category_policy = "preserve", method = "MML", model = "RSM"
)
res <- mfrm_results(fit)
report <- mfrm_report(res)
summary(report, view = "reader")
summary(mfrm_report(fit, type = "data_quality"))
summary(mfrm_report(fit, type = "checklist"))
mfrm_report(fit, type = "specifications")$summary
recipient <- as.character(fit$prep$levels$Rater[1])
sheet <- mfrm_report(res, style = "rater", facet = "Rater",
                     rater = recipient, output = "html", max_cases = 0)
sheet$path
} # }
```
