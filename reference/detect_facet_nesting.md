# Detect nesting structure between facets

Classifies every ordered pair of facets (optionally including `Person`)
as crossed, partially nested, near-perfectly nested, or fully nested,
based on a conditional-entropy index: \$\$\text{nesting\\index}(A \to B)
= 1 - H(B \mid A) / H(B).\$\$ An index near 1 means that knowing the
level of `A` essentially determines the level of `B` (A is nested in B).

## Usage

``` r
detect_facet_nesting(data, facets, person = NULL, weight_col = NULL)
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

  Optional name of a weight column; if supplied, rows are replicated
  proportionally when counting element co-occurrences.

## Value

A list of class `mfrm_facet_nesting` with:

- `pairwise_table`: one row per ordered facet pair with
  `NestingIndex_AinB`, `NestingIndex_BinA`, classification strings, and
  `Direction`.

- `summary`: a one-line summary table with facet counts and whether any
  non-crossed structure was detected.

- `facets`: the facet vector that was reviewed.

## Details

This is a pure descriptive review of the observed design. It does not
affect estimation; fit_mfrm() continues to treat all facets as fixed
effects.

## Classification bands

- `"Fully nested"`: nesting index \>= 0.99.

- `"Near-perfectly nested"`: 0.95 \<= index \< 0.99.

- `"Partially nested"`: 0.50 \<= index \< 0.95.

- `"Crossed"`: index \< 0.50.

The direction column records which facet is nested in which, or
`"crossed"` when neither direction is above 0.95.

## Interpreting output

A `Direction` value of `"Rater nested in Region"` means that every rater
appears in exactly one region (or very close to it). For additive
fixed-effects MFRM, this is a concern: the severity of a rater is
confounded with region-level variance that the model cannot partition.
Consider reporting the nesting direction explicitly and, when relevant,
refitting without the nested facet or moving to a hierarchical
estimation tool (e.g.
[`lme4::lmer`](https://rdrr.io/pkg/lme4/man/lmer.html), `brms`, `TAM`)
to separate the variance components.

`Direction = "crossed"` is the most common reading when both nesting
indices are below 0.5; the two facets largely co-occur at multiple
combinations, which is the setting Linacre (1989) assumed.

## Typical workflow

1.  Call `detect_facet_nesting(data, facets)` before fitting.

2.  If any pair is flagged as nested or partially nested, review the
    numeric index and the `LevelsA`/`LevelsB` counts.

3.  For downstream reporting, use
    [`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md)
    to bundle this output with ICC and design-effect summaries, which
    [`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md)
    then records for reproducibility.

## References

McEwen, M. R. (2018). *The effects of incomplete rating designs on
results from many-facets-Rasch model analyses* (Doctoral thesis, Brigham
Young University). <https://scholarsarchive.byu.edu/etd/6689/>

Linacre, J. M. (1989). *Many-facet Rasch measurement*. MESA Press.

## See also

[`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md),
[`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md),
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
[`compute_facet_design_effect()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_design_effect.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
(see "Fixed effects assumption" in its details).

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
