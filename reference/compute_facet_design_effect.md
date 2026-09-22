# Compute descriptive design-effect approximations for each facet

Combines per-facet average cluster size with ICC estimates to return the
Kish-style approximation `Deff = 1 + (m - 1) * rho`, where `m` is the
average number of observations per facet element and `rho` is the ICC
variance share. Each facet is evaluated separately.

## Usage

``` r
compute_facet_design_effect(
  data,
  facets,
  icc_table = NULL,
  score = NULL,
  person = NULL,
  missing = c("error", "omit")
)
```

## Arguments

- data:

  Data frame in long format, used to fit the ICC model when `icc_table`
  is `NULL`. With a supplied ICC table, sample sizes come from its
  retained row accounting, not from `data`.

- facets:

  Character vector of facet column names.

- icc_table:

  Output from
  [`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
  (optional; will be computed on the fly when `NULL`). Must retain its
  `data_usage` attribute. Rerun older saved ICC results from their
  original data and settings before calculating design effects; their
  analysis sample cannot be reconstructed from the ICC table alone.

- score:

  Score column name; required when `icc_table` is `NULL`.

- person:

  Person column; passed through to compute_facet_icc().

- missing:

  Missing-value policy passed to
  [`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
  when `icc_table` is `NULL`. A supplied table retains its original
  policy.

## Value

A data.frame of class `mfrm_facet_design_effect` with columns `Facet`,
`AvgClusterSize`, `ICC`, `DesignEffect`, `EffectiveN`, `InputRows`,
`UsedRows`, and `ExcludedRows`. Its `data_usage` attribute is retained
from the ICC result. Cluster sizes and effective sample sizes use only
rows included in that model.

## Interpreting output

The formula describes the variance inflation of an unweighted mean under
a single clustering factor with equal cluster sizes, independent
clusters, and common within-cluster correlation. This helper substitutes
the average cluster size and one fitted facet variance share. It does
not calculate the variance of a specified estimator under the full
sampling design.

- `Deff = 1` means this approximation adds no inflation for that facet;
  it does not establish independence of observations or adequate
  precision.

- `Deff > 1` signals potential clustering influence under this
  approximation. `EffectiveN = UsedRows / Deff` is a descriptive
  equivalent row count, not a count of independent Persons or an
  assurance of matching precision.

- Unequal cluster sizes, crossed or nested dependencies, sampling
  weights, and finite-population corrections are not accounted for.
  Per-facet values must not be added or multiplied to obtain an overall
  design effect.

- Reported `ICC` is pulled from `icc_table$ICC` (the variance share);
  interpretation is the same as in
  [`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md).

## Typical workflow

1.  Run
    [`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
    to get the variance-component shares.

2.  Feed the result and the data into
    `compute_facet_design_effect(data, facets, icc_table = icc)`.

3.  Use these values to flag facets for design review. For standard
    errors, sample-size planning, or comparisons of precision, use an
    estimator and variance calculation that represent the actual design.

## References

Kish, L. (1965). *Survey Sampling*. New York: Wiley.

Park, I., & Lee, H. (2004). Design effects for the weighted mean and
total estimators under complex survey sampling. *Survey Methodology,
30*(2), 183-193.
<https://www150.statcan.gc.ca/n1/pub/12-001-x/2004002/article/7751-eng.pdf>

## See also

[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
[`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md).

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
if (requireNamespace("lme4", quietly = TRUE)) {
  icc <- compute_facet_icc(toy, facets = c("Rater", "Criterion"),
                           score = "Score", person = "Person")
  deff <- compute_facet_design_effect(toy,
                                      facets = c("Rater", "Criterion"),
                                      icc_table = icc)
  print(deff)
  # Review clustering influence; EffectiveN is a descriptive row count.
}
#> mfrm_facet_design_effect (per-facet approximation)
#>   EffectiveN is a descriptive row count, not full-design precision.
#>   ICC rows: 768 input, 768 used, 0 excluded.
#>      Facet AvgClusterSize    ICC DesignEffect EffectiveN InputRows UsedRows
#>      Rater            192 0.0270        6.157      124.7       768      768
#>  Criterion            192 0.0222        5.240      146.6       768      768
#>  ExcludedRows
#>             0
#>             0
# }
```
