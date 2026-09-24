# Generalizability-theory variance decomposition for an MFRM design

Re-fits the rating data underlying an `mfrm_fit` as a crossed
random-effects model
`Score ~ 1 + (1 | Person) + (1 | Facet1) + ... + Residual` via
[`lme4::lmer`](https://rdrr.io/pkg/lme4/man/lmer.html), and returns the
canonical G-theory variance components plus G / Phi coefficients. Useful
when reviewers ask for a generalizability-theory complement to the
Rasch-style separation / reliability statistics that
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
already emits.

## Usage

``` r
mfrm_generalizability(
  fit,
  data = NULL,
  object_facet = "Person",
  random_facets = NULL,
  reml = TRUE,
  missing = c("error", "omit")
)
```

## Arguments

- fit:

  An `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- data:

  Optional data frame. When `NULL`, the rating data stored on
  `fit$prep$data` is used. Required columns are the selected facets and
  `Score`. Scores must be numeric or numeric character/factor labels;
  nonnumeric labels and infinite values are refused. Use `NA` for
  missing values. Facet labels must be nonblank; `Score` and `Residual`
  are reserved and cannot be facet names.

- object_facet:

  Facet that plays the role of the "object of measurement" – typically
  `"Person"` (default).

- random_facets:

  Character vector of non-person facets to treat as random conditions of
  measurement. Default uses every facet other than `object_facet`.

- reml:

  Logical, passed to
  [`lme4::lmer()`](https://rdrr.io/pkg/lme4/man/lmer.html) (default
  `TRUE`).

- missing:

  Either `"error"` (default) or `"omit"`. Missing scores or selected
  facet values stop the analysis by default. Explicit omission fits only
  complete rows and records the excluded row positions and missing
  columns. Missingness in unselected columns does not exclude a row.

## Value

An object of class `mfrm_generalizability` with:

- `variance_components`:

  One row per random effect plus residual, with columns `Source`,
  `Variance`, and `ProportionVariance`.

- `coefficients`:

  One-row data frame with `G` (generalizability coefficient, relative
  decision) and `Phi` (dependability coefficient, absolute decision),
  coefficient status labels, and the identification status of the fitted
  random-effects model.

- `design`:

  Description of the crossed-random model.

- `data_usage`:

  Input source, omission policy, named `counts` (`InputRows`,
  `UsedRows`, `ExcludedRows`), `excluded_rows`, and `missing_cells`
  (`InputRow`, `Column`). Row positions refer to the supplied data, or
  stored fitted rows when `data = NULL`. They cannot recover rows
  previously removed during MFRM fitting. Counts also accompany the
  coefficient table and D-study projections, including tabular exports;
  `GStudyDataSource` identifies the scope of those counts.

## Details

The decomposition is on the observed numeric `Score` scale. It does not
use the fitted MFRM latent scale or estimate a latent ordinal G/Phi
coefficient.

## Interpretation

- `G` is appropriate for **relative** decisions (rank-ordering persons):
  `G = sigma2(p) / (sigma2(p) + sigma2(Residual))`.

- The reported `Phi` describes dependability for **absolute** decisions:
  `Phi = sigma2(p) / (sigma2(p) + sigma2(facet main effects) + sigma2(Residual))`,
  before D-study scaling. It does not estimate the probability of
  correct classification at a particular cut score.

- Use
  [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
  to project `G` / `Phi` under planned numbers of raters, items,
  criteria, or other random measurement facets.

- Values of 0.70 and 0.80 are displayed as familiar planning references,
  not as universal decision rules. Required dependability depends on the
  decision, consequences, population, and evidence beyond a single
  coefficient.

- For ordered categories, `Score` is treated as a numeric observed
  response in a Gaussian linear mixed model; thresholding is not
  modeled.

## Limitations

This helper formulates the random-effects model with main effects only
(`Score ~ 1 + (1|Person) + (1|Facet1) + ... + Residual`); no explicit
`(1 | Person:Rater)`, `(1 | Person:Criterion)`, or
`(1 | Rater:Criterion)` interaction terms are estimated. All
interactions are omitted. The residual combines unexplained variation;
omitted interactions may also affect the fitted main-effect components.
Their separate variances and correct averaging rates are not recovered.
This function reports the one-observation-per-cell baseline.
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
applies D-study scaling, including residual-scaling sensitivity checks,
to the same simplified variance-component decomposition. Because
person-by-facet interaction terms are not estimated separately, D-study
projections remain practical planning evidence rather than a replacement
for a fully specified G-theory design. Counts held constant in a D-study
do not turn a random facet into a fixed-facet universe. Variance
estimation uncertainty is not propagated to G/Phi. Component values are
stored at full precision; rounding is only for display. Recreate older
G/D results from the existing MFRM fit before reuse. Boundary or
singular `lme4` fits are retained as diagnostic evidence but are not
treated as decision-ready G/D-study evidence.

Omission does not correct missing-data bias or identify why ratings are
absent. Entirely absent assignments are not reconstructed. Review the
rating design and missingness assumptions before interpreting G/D
results. Earlier versions silently omitted incomplete rows and
unparseable scores. To reproduce complete-row selection, clean invalid
labels explicitly and choose `missing = "omit"`. Older saved results
remain usable when their calculation version is current, but unavailable
row counts are not guessed; rerun the G-study with the original data to
obtain row accounting.

## References

- Cronbach, L. J., Gleser, G. C., Nanda, H., & Rajaratnam, N. (1972).
  *The dependability of behavioral measurements: Theory of
  generalizability for scores and profiles*. Wiley.

- Brennan, R. L. (2001). *Generalizability theory*. Springer.

## See also

[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md),
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 300)
if (requireNamespace("lme4", quietly = TRUE)) {
  gt <- mfrm_generalizability(fit)
  gt$variance_components
  # Look for: a Person variance component well above any single
  #   non-person facet's variance share. Large rater or criterion
  #   variance shares mean those conditions add measurement error
  #   relative to person spread.
  gt$coefficients
  # Compare G and Phi with study-specific requirements; 0.70 and 0.80
  #   are reference guides only. Phi < G means absolute decisions are noisier than relative
  #   decisions; review whether facet main effects need anchoring.
  # Always check IdentificationStatus before using the bands:
  gt$coefficients[, c("G", "Phi", "GStatus", "PhiStatus",
                      "IdentificationStatus")]
  gt$design$identification_note
  # If IdentificationStatus is not "identified", treat G/Phi as
  # design-review evidence rather than decision-ready reliability.
}
#> [1] "No lme4 boundary or singular fit was detected."
# }
```
