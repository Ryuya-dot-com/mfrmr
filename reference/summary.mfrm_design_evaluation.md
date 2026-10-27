# Summarize a design-simulation study

Summarize a design-simulation study

## Usage

``` r
# S3 method for class 'mfrm_design_evaluation'
summary(object, digits = 3, ...)
```

## Arguments

- object:

  Output from
  [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md).

- digits:

  Number of digits used when printing the summary. Returned numeric
  tables retain full precision for plotting and design decisions.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_design_evaluation` with components:

- `overview`: run-level overview

- `design_summary`: aggregated design-by-facet metrics, with
  design-variable alias columns when applicable

- `sparse_review`: compact planned-missingness and rater-link review
  counts when sparse linked designs are active

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
  simulation performance

- `notes`: short interpretation notes

## Details

The summary emphasizes condition-level averages that are useful for
practical design planning, especially:

- convergence rate

- separation and reliability by facet

- severity recovery RMSE

- mean misfit rate

`Reps`, `ConvergenceRate`, and `McseConvergenceRate` use all recorded
replications for each design, including fit and diagnostic failures.
Only a recorded `Converged = TRUE` counts as converged. `AvailableReps`
counts the replications with returned results for that facet;
performance means still use the available metric values. Designs with no
returned facet results have no performance-summary rows and cannot be
recommended. To update an older saved summary, call
[`summary()`](https://rdrr.io/r/base/summary.html) again on the original
evaluation object; no simulation or refitting is needed. Rebuilding also
restores full precision when an older summary stored rounded metrics. It
also withholds legacy PCM/GPCM recovery metrics whose step-location
truth coordinates were not verified; those require a new evaluation for
corrected recovery, while other diagnostic metrics remain.
`RecoveryAvailableReps` reports the number of finite trial RMSEs.
Mean-aligned bias is zero by construction; see
[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md)
for the comparison target.

`MaxRatings` and `MaxRatingsPerRater` are the largest total rating count
and individual rater workload across all recorded replications,
including failed runs. A rating is one generated person-rater-criterion
row; weights do not multiply workload. A maximum is `NA` when any
replication lacks that count, including older evaluations without
per-rater workload records.

`MaxRaterComponents` and `MaxCriterionComponents` give the largest
Person-facet component count across all recorded assignments; a missing
count makes its maximum `NA`. `DisconnectedReps` counts replications
with a recorded disconnection in either graph. Zero known disconnections
does not establish connectedness when records are missing. Sparse-design
summaries also use all run records, including failures.

## See also

[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
[plot.mfrm_design_evaluation](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_design_evaluation.md)

## Examples

``` r
# One saved replication illustrates output structure, not precise rates.
# Regeneration recipe: examples/simulation-results.R in the package.
saved <- readRDS(system.file("examples", "simulation-design.rds",
  package = "mfrmr", mustWork = TRUE))
# Inspect saved$generation_warnings and the result's run/status tables.
sim_eval <- saved$result
s <- summary(sim_eval)
s$overview
#> # A tibble: 1 × 5
#>   Designs Replications SuccessfulRuns ConvergedRuns MeanElapsedSec
#>     <int>        <int>          <int>         <int>          <dbl>
#> 1       2            2              2             1           0.32
head(s$design_summary)
#> # A tibble: 6 × 51
#>   design_id Facet   n_person n_rater n_criterion raters_per_person AvailableReps
#>   <chr>     <chr>      <int>   <int>       <int>             <int>         <int>
#> 1 D01       Criter…        8       2           2                 2             1
#> 2 D02       Criter…       12       2           2                 2             1
#> 3 D01       Person         8       2           2                 2             1
#> 4 D02       Person        12       2           2                 2             1
#> 5 D01       Rater          8       2           2                 2             1
#> 6 D02       Rater         12       2           2                 2             1
#> # ℹ 44 more variables: MeanSeparation <dbl>, SdSeparation <dbl>,
#> #   McseSeparation <dbl>, MeanReliability <dbl>, McseReliability <dbl>,
#> #   MeanInfit <dbl>, McseInfit <dbl>, MeanOutfit <dbl>, McseOutfit <dbl>,
#> #   MeanMisfitRate <dbl>, McseMisfitRate <dbl>, RecoveryAvailableReps <int>,
#> #   MeanSeverityRMSE <dbl>, McseSeverityRMSE <dbl>, MeanSeverityBias <dbl>,
#> #   McseSeverityBias <dbl>, MeanSeverityRMSERaw <dbl>,
#> #   McseSeverityRMSERaw <dbl>, MeanSeverityBiasRaw <dbl>, …
```
