# Detect anchor drift across multiple calibrations

Compares facet estimates across two or more calibration waves to
identify elements whose difficulty/severity has shifted beyond
acceptable thresholds. Useful for monitoring rater drift over time or
checking the stability of item banks.

## Usage

``` r
detect_anchor_drift(
  fits,
  facets = NULL,
  drift_threshold = 0.5,
  flag_se_ratio = 2,
  reference = 1L,
  include_person = FALSE
)

# S3 method for class 'mfrm_anchor_drift'
print(x, ...)

# S3 method for class 'mfrm_anchor_drift'
summary(object, ...)

# S3 method for class 'summary.mfrm_anchor_drift'
print(x, ...)
```

## Arguments

- fits:

  Named list of `mfrm_fit` objects (e.g.,
  `list(Year1 = fit1, Year2 = fit2)`).

- facets:

  Character vector of facets to compare (default: all non-Person
  facets).

- drift_threshold:

  Absolute drift threshold for flagging (logits, default 0.5).

- flag_se_ratio:

  Drift/SE ratio threshold for flagging (default 2.0).

- reference:

  Index or name of the reference fit (default: first).

- include_person:

  Include person estimates in comparison.

- x:

  An `mfrm_anchor_drift` object.

- ...:

  Ignored.

- object:

  An `mfrm_anchor_drift` object (for `summary`).

## Value

Object of class `mfrm_anchor_drift` with components:

- drift_table:

  Tibble of element-level drift statistics.

- summary:

  Drift summary aggregated by facet and wave.

- common_elements:

  Tibble of pairwise common-element counts.

- common_vs_reference:

  Tibble of common-element counts between each wave and the reference
  wave (i.e., which elements remain comparable across the entire chain).

- n_common_all_waves:

  Integer count of elements that are common across every wave; used by
  [`summary()`](https://rdrr.io/r/base/summary.html) to gauge how robust
  the chain is to chained linking error.

- common_by_facet:

  Tibble of retained common-element counts by facet.

- config:

  List of analysis configuration.

## Details

For each non-reference wave, the function extracts facet-level estimates
using
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md)
and computes the element-by-element difference against the reference
wave. Standard errors are obtained from
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
applied to each fit. Only elements common to both the reference and a
comparison wave are included. Before reporting drift, the function
removes the weighted common-element link offset between the two waves so
that `Drift` represents residual instability rather than the overall
shift between calibrations. The function also records how many common
elements survive the screening step within each linking facet and treats
fewer than 5 retained common elements per facet as thin support.

An element is **flagged** when either condition is met: \$\$\|\Delta_e\|
\> \texttt{drift\\threshold}\$\$ \$\$\|\Delta_e / SE\_{\Delta_e}\| \>
\texttt{flag\\se\\ratio}\$\$ The dual-criterion approach guards against
flagging elements with large but imprecise estimates, and against
missing small but precisely estimated shifts.

When `facets` is `NULL`, all non-Person facets are compared. Providing a
subset (e.g., `facets = "Criterion"`) restricts comparison to those
facets only.

## Which function should I use?

- Use
  [`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md)
  when your starting point is raw new data plus a single baseline fit.

- Use `detect_anchor_drift()` when you already have multiple fitted
  waves and want a reference-versus-wave comparison.

- Use
  [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
  when the waves form a sequence and you need cumulative linking
  offsets.

## Interpreting output

- `$drift_table`: one row per element x wave combination, with columns
  `Facet`, `Level`, `Wave`, `Ref_Est`, `Wave_Est`, `LinkOffset`,
  `Drift`, `SE_Ref`, `SE_Wave`, `SE`, `Drift_SE_Ratio`,
  `LinkSupportAdequate`, and `Flag`. Large drift signals instability
  after alignment to the common-element link.

- `$summary`: aggregated statistics by facet and wave: number of
  elements, mean/max absolute drift, and count of flagged elements.

- `$common_elements`: pairwise common-element counts in tidy table form.
  Small overlap weakens the comparison and results should be interpreted
  cautiously.

- `$common_by_facet`: retained common-element counts by linking facet
  for each reference-vs-wave comparison. `LinkSupportAdequate = FALSE`
  means the link rests on fewer than 5 retained common elements in at
  least one facet.

- `$config`: records the analysis parameters for reproducibility.

- A practical reading order is `summary(drift)` first, then
  `drift$drift_table`, then `drift$common_by_facet` if overlap looks
  thin.

## Typical workflow

1.  Fit separate models for each administration wave.

2.  Combine into a named list:
    `fits <- list(Spring = fit_s, Fall = fit_f)`.

3.  Call `drift <- detect_anchor_drift(fits)`.

4.  Review `summary(drift)` and `plot_anchor_drift(drift)`.

5.  Flagged elements may need to be removed from anchor sets or
    investigated for substantive causes (e.g., rater re-training).

## See also

[`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md),
[`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md),
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md),
[`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)

## Examples

``` r
# \donttest{
# Deliberately linked teaching waves: common labels below represent the
# same rater and criterion identities by construction.
toy <- load_mfrmr_data("example_core")
people <- unique(toy$Person)
# Two balanced 12-Person waves retain every Rater and Criterion.
d1 <- toy[toy$Person %in% people[1:12], , drop = FALSE]
d2 <- toy[toy$Person %in% people[13:24], , drop = FALSE]
fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score",
                 method = "MML", quad_points = 7, maxit = 30)
fit2 <- fit_mfrm(d2, "Person", c("Rater", "Criterion"), "Score",
                 method = "MML", quad_points = 7, maxit = 30)
drift <- detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2))
#> Warning: Thin linking support between 'Wave1' and 'Wave2': fewer than 5 retained common elements in Criterion, Rater.
summary(drift)
#> --- Anchor Drift Screen ---
#> Reference: Wave1 
#> Method: screened_common_element_alignment | Intended use: review_screen 
#> Comparisons: 8 | Flagged: 0 
#> 
#> Drift summary by facet and wave:
#>      Facet  Wave N Mean_Drift Max_Drift N_Flagged
#>  Criterion Wave2 4     0.0717     0.148         0
#>      Rater Wave2 4     0.2635     0.480         0
#> 
#> Common elements:
#>  Wave1 Wave2 N_Common
#>  Wave1 Wave2        8
#> 
#> Retained common elements by facet:
#>  Reference  Wave     Facet N_Common N_Retained GuidelineMinCommon
#>      Wave1 Wave2 Criterion        4          4                  5
#>      Wave1 Wave2     Rater        4          4                  5
#>  LinkSupportAdequate
#>                FALSE
#>                FALSE
head(drift$drift_table[, c("Facet", "Level", "Wave", "Drift", "Flag")])
#> # A tibble: 6 × 5
#>   Facet     Level    Wave    Drift Flag 
#>   <chr>     <chr>    <chr>   <dbl> <lgl>
#> 1 Rater     R01      Wave2 -0.480  FALSE
#> 2 Rater     R03      Wave2  0.470  FALSE
#> 3 Criterion Content  Wave2 -0.148  FALSE
#> 4 Criterion Language Wave2  0.0828 FALSE
#> 5 Rater     R04      Wave2  0.0528 FALSE
#> 6 Rater     R02      Wave2 -0.0518 FALSE
drift$common_elements
#> # A tibble: 1 × 3
#>   Wave1 Wave2 N_Common
#>   <chr> <chr>    <int>
#> 1 Wave1 Wave2        8
# }
```
