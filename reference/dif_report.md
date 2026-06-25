# Generate a differential-functioning interpretation report

Produces APA-style narrative text interpreting the results of a
differential- functioning analysis or interaction table. For
`method = "refit"`, the report summarises the number of facet levels
classified as negligible (A), moderate (B), and large (C). For
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

  Currently unused; reserved for future extensions.

## Value

Object of class `mfrm_dif_report` with `narrative`, `counts`,
`large_dif`, `gpcm_boundary`, and `config`.

## Details

When `dif_result` is an `mfrm_dff`/`mfrm_dif` object, the report is
based on the pairwise differential-functioning contrasts in
`$dif_table`. When it is an `mfrm_dif_interaction` object, the report
uses the cell-level statistics and flags from `$table`.

For `method = "refit"`, ETS-style magnitude labels are used only when
subgroup calibrations were successfully linked back to a common baseline
scale; otherwise the report labels those contrasts as unclassified
because the refit difference is descriptive rather than comparable on a
linked logit scale. For `method = "residual"`, the report describes
screening-positive versus screening-negative contrasts instead of
applying ETS labels.

## Interpreting output

- `$narrative`: character scalar with the full narrative text.

- `$counts`: named integer vector of method-appropriate counts.

- `$large_dif`: tibble of large ETS results (`method = "refit"`) or
  screening-positive contrasts/cells (`method = "residual"`).

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
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_bias")

fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", model = "RSM", maxit = 30
)
diag <- diagnose_mfrm(fit, residual_pca = "none")
dif <- analyze_dff(fit, diag, facet = "Rater", group = "Group", data = toy)
rpt <- dif_report(dif)
cat(rpt$narrative)
}
```
