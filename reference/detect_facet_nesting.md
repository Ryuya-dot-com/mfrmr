# Detect nesting structure between facets

Classifies both directions of each pair of facets (optionally including
`Person`) as crossed, partially nested, near-perfectly nested, or fully
nested, based on a conditional-entropy index:
\$\$\text{nesting\\index}(A \to B) = 1 - H(B \mid A) / H(B).\$\$ An
index near 1 means that knowing the level of `A` essentially determines
the level of `B` (A is nested in B).

Renders the directed nesting index \\1 - H(B \mid A)/H(B)\\ as a heatmap
between facet pairs, with larger values indicating less conditional
uncertainty about B given A. Exactly 1 means B is determined by A when
H(B) is positive; near 1 is not exact nesting. Zero means empirical
independence, not necessarily a completely crossed design. Undefined
zero-entropy cases remain unavailable.

## Usage

``` r
detect_facet_nesting(data, facets, person = NULL, weight_col = NULL)

# S3 method for class 'mfrm_facet_nesting'
plot(
  x,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  ...
)
```

## Arguments

- data:

  Data frame in long format (one row per rating).

- facets:

  Character vector of facet column names.

- person:

  Optional name of the person column (adds Person to the nesting matrix
  if supplied).

- weight_col:

  Optional name of a numeric column of finite, nonnegative weights.
  Zero-weight rows are excluded; at least one weight must be positive.
  Weighted frequencies are used directly, without rounding or
  replicating rows.

- x:

  An `mfrm_facet_nesting` object.

- preset:

  Plot preset.

- draw:

  Logical; print the `ggplot` figure when `TRUE`.

- ...:

  Reserved.

## Value

A list of class `mfrm_facet_nesting` with:

- `pairwise_table`: one row per facet pair, reporting both directions
  with `NestingIndex_AinB`, `NestingIndex_BinA`, classification strings,
  `Direction`, `UsedRows` and `ExcludedRows`.

- `summary`: a one-line summary table with facet counts and whether any
  non-crossed structure was detected.

- `facets`: the facet vector that was reviewed.

Invisibly, a `ggplot` object.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
extracts the rendered nesting matrix and pairwise summary table.

## Details

This is a pure descriptive review of the observed design. It does not
affect estimation; fit_mfrm() continues to treat all facets as fixed
effects.

## Classification bands

- `"Fully nested"`: nesting index \>= 0.99.

- `"Near-perfectly nested"`: 0.95 \<= index \< 0.99.

- `"Partially nested"`: 0.50 \<= index \< 0.95.

- `"Crossed"`: index \< 0.50.

These are package screening bands, not tests of exact nesting or full
crossing. `Direction` is `"isomorphic"` when both indices are at least
0.95, names a nesting direction when only that index is at least 0.95,
and is `"crossed"` when both are below 0.95. Thus the direction can say
`"crossed"` even when a classification is `"Partially nested"`.
Zero-entropy cases have `Direction = "insufficient_data"`.

## Missing values and weights

Each pair uses rows observed on both columns and having positive weight.
Both marginal entropies and both conditional entropies use those same
rows. `UsedRows` and `ExcludedRows` report this pair-specific scope;
they count original rows, not the sum of weights. Different pairs may
use different rows. Multiplying all weights by a positive constant
leaves the indices unchanged. Weights are descriptive frequency weights,
not a survey-variance correction. The index is undefined (`NA`) when its
denominator entropy is zero, including pairs with no usable rows.
Missing-value exclusion does not establish that the observed pattern
represents the missing ratings.

## Interpreting output

Exact nesting of Rater within Region confounds unrestricted additive
rater and region effects. A near-nesting label instead signals limited
overlap; inspect the actual cross-tabulation and model design. The index
alone establishes neither rank deficiency nor identification.

A hierarchical model can separate within- and between-group variation
under additional distributional assumptions and adequate replication;
switching software does not supply missing design information. Dropping
a facet also changes the model and interpretation. Report the observed
design and justify the chosen parameterization. A `"crossed"` label does
not establish that every combination was observed or that the full
many-facet design is connected.

## Typical workflow

1.  Call `detect_facet_nesting(data, facets)` before fitting.

2.  If any pair is flagged as nested or partially nested, review the
    numeric index and the `LevelsA`/`LevelsB` counts.

3.  For downstream reporting, use
    [`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md)
    to bundle this output with ICC and design-effect summaries, which
    [mfrm_report_checklist](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
    can record as available report material.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## References

Shannon, C. E. (1948). A mathematical theory of communication. *Bell
System Technical Journal, 27*, 379-423, 623-656.
<https://web.mit.edu/6.976/www/handout/shannon.pdf>

McEwen, M. R. (2018). *The effects of incomplete rating designs on
results from many-facets-Rasch model analyses* (Doctoral thesis, Brigham
Young University). <https://scholarsarchive.byu.edu/etd/6689/>

Linacre, J. M. (1989). *Many-facet Rasch measurement*. MESA Press.

## See also

[`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md),
[`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md),
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
[`compute_facet_design_effect()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
(see "Fixed effects assumption" in its details).

`detect_facet_nesting()`,
[`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md).

## Examples

``` r
toy <- load_mfrmr_data("example_core")
nesting <- detect_facet_nesting(toy, c("Rater", "Criterion"))
summary(nesting)
#> mfrm_facet_nesting
#> 
#> Summary:
#>  NFacets NPairs AnyNested FullyNestedPairs CrossedPairs
#>        2      1     FALSE                0            1
#> 
#> Pairwise nesting:
#>  FacetA    FacetB LevelsA LevelsB NestingIndex_AinB NestingIndex_BinA Direction
#>   Rater Criterion       4       4                 0                 0   crossed

# Synthetic example: raters fully nested within regions.
d <- data.frame(
  Person = rep(paste0("P", formatC(1:20, width = 2, flag = "0")),
               each = 6),
  Rater  = rep(paste0("R", 1:6), 20),
  Region = rep(rep(c("A", "A", "B", "B", "C", "C"), 20)),
  Score  = sample(0:4, 120, replace = TRUE),
  stringsAsFactors = FALSE
)
nest <- detect_facet_nesting(d, c("Rater", "Region"))
nest$pairwise_table[, c("FacetA", "FacetB",
                        "NestingIndex_AinB", "Direction")]
#>   FacetA FacetB NestingIndex_AinB              Direction
#> 1  Rater Region                 1 Rater nested in Region
```
