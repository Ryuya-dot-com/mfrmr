# Compute Kish design effects for each facet

Combines per-facet average cluster size with ICC estimates to return the
Kish (1965) design effect `Deff = 1 + (m - 1) * rho`, where `m` is the
average number of observations per facet element and `rho` is the ICC.

## Usage

``` r
compute_facet_design_effect(
  data,
  facets,
  icc_table = NULL,
  score = NULL,
  person = NULL
)
```

## Arguments

- data:

  Data frame in long format.

- facets:

  Character vector of facet column names.

- icc_table:

  Output from
  [`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
  (optional; will be computed on the fly when `NULL`).

- score:

  Score column name; required when `icc_table` is `NULL`.

- person:

  Person column; passed through to compute_facet_icc().

## Value

A data.frame of class `mfrm_facet_design_effect` with columns `Facet`,
`AvgClusterSize`, `ICC`, `DesignEffect`, and `EffectiveN`.

## Interpreting output

- `Deff = 1`: facet behaves like simple random sampling; no
  clustering-induced variance inflation.

- `Deff > 1`: variance of the mean estimate is inflated by a factor of
  `Deff` relative to SRS. `EffectiveN = N / Deff` is the sample size one
  would need under SRS to achieve the same precision. For rater-mediated
  designs, `Deff` well above 1 on the Rater facet means rater-level
  clustering is noticeable; consider whether rater generalisation is
  warranted.

- Reported `ICC` is pulled from `icc_table$ICC` (the variance share);
  interpretation is the same as in
  [`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md).

## Typical workflow

1.  Run
    [`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
    to get the variance-component shares.

2.  Feed the result and the data into
    `compute_facet_design_effect(data, facets, icc_table = icc)`.

3.  Use `Deff` as part of the Methods discussion when generalising over
    raters or sites. Large `Deff` values argue for reporting robust SEs
    or moving to a hierarchical model.

## References

Kish, L. (1965). *Survey Sampling*. New York: Wiley.

Park, I., & Lee, H. (2001). The design effect: Do we know all about it?
In *Proceedings of the American Statistical Association, Survey Research
Methods Section* (pp. 143-148).

## See also

[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
[`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md).

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
if (requireNamespace("lme4", quietly = TRUE)) {
  icc <- compute_facet_icc(toy, facets = c("Rater", "Criterion"),
                           score = "Score", person = "Person")
  deff <- compute_facet_design_effect(toy,
                                      facets = c("Rater", "Criterion"),
                                      icc_table = icc)
  print(deff)
  # Large DesignEffect -> modest EffectiveN relative to raw N.
}
} # }
```
