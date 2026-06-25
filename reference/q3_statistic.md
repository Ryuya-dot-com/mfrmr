# Yen-style Q3 local-dependence statistic between facet levels

Computes a Q3-style index inspired by Yen (1984) – the Pearson
correlation of **standardized** residuals between every pair of levels
of a chosen facet – from a
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
bundle. Under the conditional-independence assumption of the MFRM,
\|Q3\| should be small for every pair; large absolute values flag pairs
of facet elements (e.g. two raters or two items) whose residuals co-move
more than the main-effects model expects.

## Usage

``` r
q3_statistic(
  fit,
  diagnostics = NULL,
  facet = "Rater",
  min_pairs = 5L,
  yen_threshold = 0.2,
  marais_threshold = 0.3,
  relative_offset = 0.2
)
```

## Arguments

- fit:

  An `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  output. Computed on demand when omitted.

- facet:

  Facet whose levels are paired (default `"Rater"`).

- min_pairs:

  Minimum number of shared response opportunities required to retain a
  pair. Pairs below the threshold drop out of the table (mirrors
  [`plot_local_dependence_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_local_dependence_heatmap.md)).

- yen_threshold:

  Community-convention flag threshold (default `0.20`). Often attributed
  to Yen (1984), but the 0.20 cutoff is actually from Chen & Thissen
  (1997, p. 284); Yen herself did not propose a fixed cutoff. The cutoff
  was derived for raw-residual Q3 under the 3PL - applying it to
  standardized-residual Q3 under MFRM is approximate.

- marais_threshold:

  Stricter community-convention threshold (default `0.30`). Marais
  (2013, p. 121) reports this as a value "often considered" in the
  literature, not as her own recommendation; her actual recommendation
  is the relative comparison implemented by `relative_offset`.

- relative_offset:

  Screening offset for the relative-flag rule
  `|Q3 - mean(Q3)| > relative_offset` (default `0.20`). This is a
  simplified screening approximation of the relative comparison
  advocated by Marais (2013) and operationalized by Christensen et
  al. (2017) as `Q3_* = Q3_max - mean(Q3)`. Christensen et al. (2017)
  demonstrate empirically that no single critical value is appropriate
  across designs and recommend a parametric bootstrap; the fixed `0.20`
  here is a screening default, not a substitute for that bootstrap.

## Value

An object of class `mfrm_q3` containing:

- `pairs`:

  A data frame with one row per facet-level pair and columns `Level1`,
  `Level2`, `Q3`, `N`, `AbsQ3`, `YenFlag`, `MaraisFlag`, `RelativeFlag`,
  and a textual `Interpretation` summarising which thresholds were
  exceeded.

- `summary`:

  One-row tibble with `MeanQ3`, `MaxAbsQ3`, and the three flagged-pair
  counts.

- `thresholds`:

  The thresholds used, for reproducibility.

- `facet`:

  The facet whose levels were paired.

## Statistic definition (departures from Yen 1984)

This implementation differs from Yen's (1984) original definition in two
respects that together affect threshold interpretation.

**(1) Standardized vs raw residuals.** Yen (1984, eqs. 7-8, p. 127)
defines `Q3 = cor(d_i, d_j)` where `d_{ik} = u_{ik} - P_hat_{ik}` is the
**raw** residual. mfrmr uses **standardized** residuals
`Z = (u - P_hat) / sqrt(Var(u))` because that is what
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
stores. Standardization down-weights high-variance observations and
changes the sampling distribution of the resulting correlation; the
published critical values (Chen & Thissen, 1997; Christensen et al.,
2017) were derived for raw-residual Q3.

**(2) Mean-aggregation.** When the facet being paired (e.g. `Rater`) has
multiple residual rows per (Person, Level) cell because of additional
facets in the design (e.g. multiple `Criterion` rows per Person-Rater
cell), the standardized residuals are first **mean-aggregated to one
value per (Person, Level) cell**, and the Pearson correlation is taken
over those mean-aggregated residuals. Yen's original formulation takes
the correlation directly over per-(Person, Item) residuals, without
aggregation. Mean-aggregation reduces noise but also shrinks the
effective sample size and can pull correlations toward the cell mean.

For both reasons, treat the values returned here as a **screening
summary** rather than a direct substitute for the published Q3
thresholds. For a formal local-dependence test under raw-residual Q3,
use a parametric bootstrap as recommended by Christensen et al. (2017).

## References

- Yen, W. M. (1984). Effects of local item dependence on the fit and
  equating performance of the three-parameter logistic model. *Applied
  Psychological Measurement, 8*(2), 125-145.
  [doi:10.1177/014662168400800201](https://doi.org/10.1177/014662168400800201)

- Chen, W.-H., & Thissen, D. (1997). Local dependence indexes for item
  pairs using item response theory. *Journal of Educational and
  Behavioral Statistics, 22*(3), 265-289. (Origin of the commonly cited
  `|Q3| > 0.20` cutoff.)

- Marais, I. (2013). Local dependence. In K. B. Christensen, S. Kreiner,
  & M. Mesbah (Eds.), *Rasch models in health* (pp. 111-130). London:
  ISTE / Wiley.

- Christensen, K. B., Makransky, G., & Horton, M. (2017). Critical
  values for Yen's Q3: Identification of local dependence in the Rasch
  model using residual correlations. *Applied Psychological Measurement,
  41*(3), 178-194.
  [doi:10.1177/0146621616677520](https://doi.org/10.1177/0146621616677520)

## See also

[`plot_local_dependence_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_local_dependence_heatmap.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
q3 <- q3_statistic(fit)
q3$summary
# Look for: MaxAbsQ3 < 0.20 (Chen & Thissen 1997 community cutoff) is
#   the comfortable regime; values above 0.30 are commonly considered
#   strict-flag worthy (Marais, 2013, summarising literature). For a
#   formal test, use a parametric bootstrap (Christensen et al., 2017).
#   The summary's flag counts give a quick triage; inspect `q3$pairs`
#   for the offending level pairs and follow up with content review.
head(q3$pairs)
}
```
