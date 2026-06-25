# Plot a design-simulation study

Plot a design-simulation study

## Usage

``` r
# S3 method for class 'mfrm_design_evaluation'
plot(
  x,
  facet = c("Rater", "Criterion", "Person"),
  metric = c("separation", "reliability", "infit", "outfit", "misfitrate",
    "severityrmse", "severitybias", "convergencerate", "elapsedsec", "mincategorycount",
    "designdensity", "plannedmissingrate", "linkpersons", "linkfraction", "linkraters",
    "mincommonpersons", "zerocommonpairs", "pairsshorttarget"),
  x_var = c("n_person", "n_rater", "n_criterion", "raters_per_person"),
  group_var = NULL,
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  Output from
  [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md).

- facet:

  Facet to visualize.

- metric:

  Metric to plot.

- x_var:

  Design variable used on the x-axis. When `x` was generated from a
  `sim_spec` with custom public facet names, the corresponding aliases
  (for example `n_judge`, `n_task`, `judge_per_person`) are also
  accepted. Role keywords (`person`, `rater`, `criterion`, `assignment`)
  are accepted as an abstraction over the current two-facet schema.

- group_var:

  Optional design variable used for separate lines. The same alias rules
  as `x_var` apply.

- draw:

  If `TRUE`, draw with base graphics; otherwise return plotting data.

- ...:

  Reserved for generic compatibility.

## Value

If `draw = TRUE`, invisibly returns a plotting-data list. If
`draw = FALSE`, returns that list directly. The returned list includes
resolved canonical variables (`x_var`, `group_var`) together with public
labels (`x_label`, `group_label`), `design_variable_aliases`, and
`design_descriptor`, plus `planning_scope`, `planning_constraints`, and
`planning_schema`.

## Details

This method is designed for quick design-planning scans rather than
polished publication graphics.

Useful first plots are:

- rater `metric = "separation"` against `x_var = "n_person"`

- criterion `metric = "severityrmse"` against `x_var = "n_person"` when
  you want aligned recovery error rather than raw location shifts

- rater `metric = "convergencerate"` against
  `x_var = "raters_per_person"`

- sparse linked `metric = "plannedmissingrate"`, `"mincommonpersons"`,
  `"zerocommonpairs"`, or `"pairsshorttarget"` to review planned
  missingness and rater-pair linkage separately from recovery metrics

## See also

[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
[summary.mfrm_design_evaluation](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_design_evaluation.md)

## Examples

``` r
if (FALSE) { # \dontrun{
sim_eval <- suppressWarnings(evaluate_mfrm_design(
  n_person = c(8, 12),
  n_rater = 2,
  n_criterion = 2,
  raters_per_person = 1,
  reps = 1,
  maxit = 30,
  seed = 123
))
p <- plot(sim_eval, facet = "Rater", metric = "separation", x_var = "n_person", draw = FALSE)
c(p$facet, p$x_var)
} # }
```
