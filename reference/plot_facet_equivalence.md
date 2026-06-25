# Plot facet-equivalence results

Plot facet-equivalence results

## Usage

``` r
plot_facet_equivalence(
  x,
  diagnostics = NULL,
  facet = NULL,
  type = c("forest", "rope"),
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  Output from
  [`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_facet_equivalence.md)
  or
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  when `x` is an `mfrm_fit` object.

- facet:

  Facet to analyze when `x` is an `mfrm_fit` object.

- type:

  Plot type: `"forest"` (default) or `"rope"`.

- draw:

  If `TRUE` (default), draw the plot. If `FALSE`, return the prepared
  plotting data.

- ...:

  Additional graphical arguments passed to base plotting functions.

## Value

Invisibly returns the plotting data. If `draw = FALSE`, the plotting
data are returned without drawing.

## Details

`plot_facet_equivalence()` is a visual companion to
[`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_facet_equivalence.md).
It does not recompute the equivalence analysis; it only reshapes and
displays the returned results.

## Plot types

- `"forest"` places each level on the logit scale with its confidence
  interval and shades the practical-equivalence region around the
  weighted grand mean.

- `"rope"` shows the percentage of each level's uncertainty mass that
  falls inside the ROPE.

## Interpreting output

In the **forest plot**, the shaded band marks the ROPE
(\\\pm\\`equivalence_bound` around the weighted grand mean). Levels
whose entire confidence interval lies inside this band are close to the
facet grand mean under this descriptive screen. Levels whose interval
extends outside the band are more displaced from the facet average.
Overlapping intervals between two elements suggest they are not reliably
separable, but overlap alone does not establish formal equivalence—use
the TOST results for that.

In the **ROPE bar chart**, each bar shows the proportion of the
element's normal-approximation distribution that falls inside the
ROPE-style grand-mean proximity. Values \> 95\\ the element's
normal-approximation uncertainty falls near the facet average; 50–95\\
meaningfully displaced from that average.

## Typical workflow

1.  Run
    [`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_facet_equivalence.md).

2.  Start with `type = "forest"` to see the facet on the logit scale.

3.  Switch to `type = "rope"` when you want a ranking of levels by
    grand-mean proximity.

## See also

[`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_facet_equivalence.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
eq <- analyze_facet_equivalence(fit, facet = "Rater")
pdat <- plot_facet_equivalence(eq, type = "forest", draw = FALSE)
c(pdat$facet, pdat$type)
}
```
