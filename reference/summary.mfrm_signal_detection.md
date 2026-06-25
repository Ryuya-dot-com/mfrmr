# Summarize a DIF/bias screening simulation

Summarize a DIF/bias screening simulation

## Usage

``` r
# S3 method for class 'mfrm_signal_detection'
summary(object, digits = 3, ...)
```

## Arguments

- object:

  Output from
  [`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_signal_detection.md).

- digits:

  Number of digits used in numeric summaries.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_signal_detection` with:

- `overview`: run-level overview

- `detection_summary`: aggregated detection rates by design, with
  design-variable alias columns when applicable

- `ademp`: simulation-study metadata carried forward from the original
  object

- `facet_names`: public facet labels carried from the simulation
  specification

- `design_variable_aliases`: accepted public aliases for design
  variables

- `design_descriptor`: role-based design-variable metadata

- `planning_scope`: explicit record of the current planning contract

- `planning_constraints`: explicit record of mutable/locked design
  variables

- `planning_schema`: combined planner-schema contract

- `future_branch_active_summary`: compact deterministic summary of the
  schema-only future arbitrary-facet planning branch embedded in the
  current planning schema

- `gpcm_boundary`: bounded-`GPCM` caveat row when present

- `notes`: short interpretation notes, including the bias-side screening
  caveat

## See also

[`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_signal_detection.md),
[plot.mfrm_signal_detection](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_signal_detection.md)

## Examples

``` r
if (FALSE) { # \dontrun{
sig_eval <- suppressWarnings(evaluate_mfrm_signal_detection(
  n_person = 8,
  n_rater = 2,
  n_criterion = 2,
  raters_per_person = 1,
  reps = 1,
  maxit = 30,
  bias_max_iter = 1,
  seed = 123
))
summary(sig_eval)
} # }
```
