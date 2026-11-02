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
  [`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/evaluate_mfrm_signal_detection.md).

- digits:

  Number of digits used when printing numeric summaries.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_signal_detection` with:

- `overview`: run-level overview

- `detection_summary`: full-precision rates by design, with
  design-variable aliases when applicable. `DIF*`, `DIFClass*` and
  `BiasScreen*` columns retain `Planned`, `Available`, `Unavailable`,
  `Positive`, `MCLower`, `MCUpper`, `AllTrialsLower` and
  `AllTrialsUpper` for target outcomes. Monte Carlo bounds are exact 95%
  binomial intervals conditional on availability; all-trial bounds
  describe unresolved outcomes, not confidence intervals.
  `DIFNonTarget*`/`BiasNonTarget*` retain summed `Planned` and
  `Available` cell counts and `AvailableReps`, the number of trials
  contributing a non-target proportion. Those proportions receive equal
  weight across contributing trials, even with unequal cell counts;
  their MCSE is the sample SD of the proportions divided by the square
  root of `AvailableReps`. `TargetContrastAvailable`,
  `TargetContrastAbsAvailable`, `TargetBiasAvailable` and
  `TargetBiasTAvailable` are denominators for the corresponding finite
  point summaries. All-missing means return `NA`.

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

- `planning_schema`: structured planning metadata

- `structural_design_review`: deterministic structural review of the
  named-facet design grid; it reports design bookkeeping rather than
  signal-detection performance

- `gpcm_boundary`: `GPCM` caveat row when present

- `notes`: short interpretation notes, including the bias-side screening
  caveat

## See also

[`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/evaluate_mfrm_signal_detection.md),
[plot.mfrm_signal_detection](https://ryuya-dot-com.github.io/mfrmr/dev/reference/evaluate_mfrm_signal_detection.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("summary.mfrm_signal_detection", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# One saved replication illustrates output structure, not precise rates.
# Regeneration recipe: examples/simulation-results.R in the package.
saved <- readRDS(system.file("examples", "simulation-signal-detection.rds",
  package = "mfrmr", mustWork = TRUE))
# Inspect saved$generation_warnings and the result's run/status tables.
sig_eval <- saved$result
summary(sig_eval)
} # }
```
