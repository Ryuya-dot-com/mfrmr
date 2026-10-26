# Plot a saved facet-equivalence analysis

Plot a saved facet-equivalence analysis

## Usage

``` r
# S3 method for class 'mfrm_facet_equivalence'
plot(x, ...)
```

## Arguments

- x:

  A result from
  [`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_facet_equivalence.md).

- ...:

  Use `type = "forest"` (default) for deviations and intervals or
  `type = "rope"` for normal confidence-distribution mass. Other
  controls are described in
  [`plot_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facet_equivalence.md).

## Value

The existing equivalence plot payload and inference restrictions.
Grand-mean proximity does not establish pairwise equivalence.

## Details

When an interval cannot be represented at the requested numeric
precision, the forest retains its estimate as a grey point without a
whisker. Inspect `data$DeviationCIReason` and `note` in the returned
payload for the reason. This does not change the pairwise TOST decision
stored in the analysis.

## See also

[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_plot_migration.md)
