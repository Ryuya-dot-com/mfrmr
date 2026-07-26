# Generate a differential-functioning interpretation report

Produces APA-style narrative text interpreting the results of a
differential- functioning analysis or interaction table. For
`method = "refit"`, the report summarises linked screening contrasts and
whether conditional plug-in uncertainty was available. For
`method = "residual"`, it summarises screening-positive results, lists
the specific levels and their direction, and includes a caveat about the
distinction between construct-relevant variation and measurement bias.

## Usage

``` r
dif_report(dif_result, ...)
```

## Arguments

- dif_result:

  Output from
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  /
  [`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  (class `mfrm_dff` with compatibility class `mfrm_dif`) or
  [`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md)
  (class `mfrm_dif_interaction`).

- ...:

  Reserved for generic compatibility.

## Value

Object of class `mfrm_dif_report` with `narrative`, `counts`,
`large_dif`, `gpcm_boundary`, and `config`.

## Details

When `dif_result` is an `mfrm_dff`/`mfrm_dif` object, the report is
based on the pairwise differential-functioning contrasts in
`$dif_table`. When it is an `mfrm_dif_interaction` object, the report
uses the cell-level statistics and flags from `$table`.

Refit differences are descriptive on a linked logit scale when subgroup
calibrations retain the required anchors. Their separate-subgroup
plug-in standard errors condition on those anchors and omit
baseline-anchor uncertainty and cross-refit covariance, so the report
does not assign ETS labels or present refit rows as formal inference.
The residual method also uses screening-positive versus
screening-negative language.

## Interpreting output

- `$narrative`: character scalar with the full narrative text.

- `$counts`: named integer vector of method-appropriate counts.

- `$large_dif`: an empty compatibility table for current refit output,
  or screening-positive contrasts/cells (`method = "residual"`).

- `$gpcm_boundary`: for bounded `GPCM` inputs, a capability-boundary
  table marking the narrative as caveated DFF screening output.

- `$config`: analysis configuration inherited from the input.

## GPCM boundary

If the input comes from a bounded `GPCM` fit, the narrative includes a
bounded-`GPCM` note and the returned report carries `gpcm_boundary`.
Treat the text as slope-aware screening/reporting support, not as a
standalone fairness, invariance, or operational subgroup decision.

## Typical workflow

1.  Run
    [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
    /
    [`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
    or
    [`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md).

2.  Pass the result to `dif_report()`.

3.  Print the report or extract `$narrative` for inclusion in a
    manuscript.

## References

The narrative caveat about distinguishing construct-relevant variation
from unwanted measurement bias is grounded in:

- Eckes, T. (2011). *Introduction to Many-Facet Rasch Measurement:
  Analyzing and Evaluating Rater-Mediated Assessments*. Frankfurt am
  Main: Peter Lang. ISBN 978-3-631-61350-4.

- McNamara, T., & Knoch, U. (2012). The Rasch wars: The emergence of
  Rasch measurement in language testing. *Language Testing*, 29(4),
  555–576.
  [doi:10.1177/0265532211430367](https://doi.org/10.1177/0265532211430367)

## See also

[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md),
[`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_bias")

fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", model = "RSM", maxit = 30
)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
diag <- diagnose_mfrm(fit, residual_pca = "none")
dif <- analyze_dff(fit, diag, facet = "Rater", group = "Group", data = toy)
rpt <- dif_report(dif)
cat(rpt$narrative)
#> DRF screening was conducted for the Rater facet across levels of Group using the residual method. A total of 4 pairwise facet-level comparisons were evaluated. 0 comparison(s) were screening-positive and 4 were screening-negative based on the residual-contrast test. 
#> No pairwise contrasts were screening-positive under the residual-screening method. This does not by itself establish invariance or consistent functioning across groups. 
#> Note: The presence of differential functioning does not necessarily indicate measurement bias. Differential functioning may reflect construct-relevant variation (e.g., true group differences in the attribute being measured) rather than unwanted measurement bias. Substantive review is recommended to distinguish between these possibilities (cf. Eckes, 2011; McNamara & Knoch, 2012).
# }
```
