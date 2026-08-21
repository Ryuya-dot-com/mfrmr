# Compare two or more fitted MFRM models

Produce a side-by-side comparison of multiple
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
results using AIC, Person-based BIC, Sclove SABIC, log-likelihood, and
free-parameter counts. When exactly two models are supplied and the
current conservative nesting review passes, a likelihood-ratio test is
included.

## Usage

``` r
compare_mfrm(..., labels = NULL, warn_constraints = TRUE, nested = FALSE)
```

## Arguments

- ...:

  Two or more `mfrm_fit` objects to compare.

- labels:

  Optional character vector of labels for each model. If `NULL`, labels
  are generated from model/method combinations.

- warn_constraints:

  Logical. If `TRUE` (the default), emit a warning when models use
  different score coding or constraint settings. Ranking is suppressed
  whenever this basis differs, regardless of whether the warning is
  displayed.

- nested:

  Logical. Set to `TRUE` only when the supplied models are known to be
  nested and fitted with the same likelihood basis on the same
  observations. The default is `FALSE`, in which case no
  likelihood-ratio test is reported. When `TRUE`, the function still
  runs a conservative structural nesting review and computes the LRT
  only for supported nesting patterns.

## Value

An object of class `mfrm_comparison` (named list) with:

- `table`: data.frame of model-level statistics including `LogLik`,
  `Deviance`, `Npar` (and equal compatibility alias `npar`), `AIC`,
  `BIC`, `SABIC`, criterion deltas and candidate-set weights,
  `ResponseRows`, `WeightedResponseTotal`, `Persons`, `ICSampleSize`,
  formula and integration identities, integration tier/selectability,
  stored-value consistency fields, convergence fields, `ICComparable`,
  `SABICComparable`, and `ConstraintComparable`.

- `lrt`: data.frame with likelihood-ratio test result (only when two
  models are supplied and `nested = TRUE`). Contains `ChiSq`, `df`,
  `p_value`.

- `evidence_ratios`: data.frame of pairwise Akaike-weight ratios
  (Model1, Model2, EvidenceRatio). `NULL` when weights cannot be
  computed.

- `preferred`: named list with the preferred model label by each
  criterion.

- `comparison_basis`: list describing whether IC and LRT comparisons
  were considered comparable. Includes a conservative `nesting_review`
  plus `lrt_status` / `lrt_reason` so withheld LRTs are explicit rather
  than silently absent.

## Details

Models should be fit to the **same data** (same rows, same person/facet
columns) for the comparison to be meaningful. The function checks that
observation counts match and warns otherwise.

Information-criterion ranking is reported only when all candidates are
inference-ready fits from the package's current `MML` contract, use the
same prepared observations, score coding, constraints, formula contract,
and integration-evaluation identity, are eligible under the weighting
policy, and have a selectable integration tier. For fixed-facet MML,
`ICSampleSize` is the number of independent Persons and
`ICSampleSizeBasis` is `"person_count"`; response rows and their
weighted total are retained separately. Explicit all-unit weights are
eligible, whereas every non-unit observation-weight fit fails closed in
version 0.2.3.

Canonical `AIC`, `BIC`, and `SABIC` are recomputed from the retained
objective, optimizer-vector dimension, and Person count. A stale stored
value, a legacy object without the current contract identity, a JML fit,
or an ineligible weighted fit cannot enter ranking. Earlier raw values
may be shown only as explicitly labelled `LegacyAIC` and `LegacyBIC`
fields.

**Integration selection guard**: raw canonical criteria are retained at
every valid MML quadrature count, but automatic comparison is
screening-only below 15 points and review-only at 15–30 points.
`ICSelectable` and `ICIntegrationSelectable` become `TRUE` at q\>=31.
q=31 is a starting grid, not a universal guarantee: close or
consequential comparisons should be reevaluated at a denser shared grid
(normally q\>=61). The guard also applies to `nested = TRUE`, so a
coarse-grid LRT cannot bypass it.

**Nesting**: Two models are *nested* when one is a special case of the
other obtained by imposing equality constraints. The most common nesting
in MFRM is RSM (shared thresholds) inside PCM (item-specific
thresholds). Models that differ only in estimation method (MML vs JML)
on the same specification are not nested in the usual sense, and their
information criteria do not share the common MML contract. Do not use
either the LRT or IC ranking as a direct cross-method comparison.

In the **current `mfrmr` model space**, the automatic nesting review is
intentionally conservative. It currently supports two fixed-effect
restrictions under shared data and shared constraints:

- `RSM` nested inside `PCM` when the `PCM` fit has an explicit
  `step_facet`;

- same-family additive-vs-interaction comparisons when the smaller fit's
  `facet_interactions` set is a subset of the larger fit's set.

Cross-method comparisons, comparisons that change
anchors/dummying/centering, and same-family comparisons that do not add
fixed interaction terms are not automatically promoted to LRT claims.

The **likelihood-ratio test (LRT)** is reported only when exactly two
models are supplied, `nested = TRUE`, the structural nesting review
passes, and the difference in the number of parameters is positive:

\$\$\Lambda = -2 (\ell\_{\mathrm{restricted}} - \ell\_{\mathrm{full}})
\sim \chi^2\_{\Delta p}\$\$

The LRT is asymptotically valid only under its regularity assumptions.
With small samples or boundary/singular conditions, the reference
chi-square p-value can be incorrect. At large Person counts, a very
small practical improvement can also become statistically significant.
Read the p-value as formal nested-fit evidence, not as an automatic
practical model preference or evidence that a subscore is useful.

## Information-criterion diagnostics

In addition to the canonical criteria, the function computes:

- **Delta_AIC / Delta_BIC / Delta_SABIC**: difference from the minimum
  value in the supplied candidate set. A Delta \< 2 is typically
  considered negligible; 4–7 suggests moderate evidence; \> 10 indicates
  strong evidence against the higher-scoring model (Burnham & Anderson,
  2002).

- **AkaikeWeight / BICWeight / SABICWeight**: relative candidate-set
  weights derived from `exp(-0.5 * Delta)` and normalized only across
  the supplied models. They are not posterior probabilities,
  probabilities of model truth, or guarantees that the candidate set is
  adequate.

- **Evidence ratios**: pairwise ratios of Akaike weights, quantifying
  relative support within this candidate set. A ratio of 5 means only
  that one normalized Akaike weight is five times the other; it does not
  mean that one model is five times more likely to be true.

AIC, BIC, and SABIC answer different approximation/penalty questions.
SABIC is a sensitivity criterion, not a universal tie-breaker. At 22 or
fewer Persons its Sclove penalty is non-positive, so `SABICSelectable`
and `SABICComparable` are `FALSE` and no automatic SABIC preference is
returned.

## What this comparison means

`compare_mfrm()` is a same-basis model-comparison helper. Its strongest
claims apply only when the models were fit to the same response data,
under a compatible likelihood basis, and with compatible constraint
structure.

## What this comparison does not justify

- Do not treat AIC/BIC/SABIC differences as primary evidence when
  `table$ICComparable` is `FALSE`.

- Do not infer numerical adequacy merely because all models share the
  same coarse quadrature identity. Below q=31, raw criteria are
  diagnostic only and automatic deltas, weights, preferences, and LRT
  are suppressed.

- Do not interpret the LRT unless `nested = TRUE` and the structural
  nesting review in `comparison_basis$nesting_review` passes.

- Same-family additive-vs-interaction fits are considered nested only
  when all other structural settings match and the smaller model's
  `facet_interactions` set is a subset of the larger model's set.

- Do not assume that `nested = TRUE` overrides the package's
  conservative nesting boundary; unsupported relations remain
  unsupported.

- PCM is the unit-slope response-kernel reduction of the bounded GPCM
  when both use the same explicit step owner. Nevertheless, the current
  automatic nesting review does not authorize a PCM-versus-GPCM
  chi-square LRT. Use same-basis MML information criteria plus
  [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
  and inspect the recorded `PCM_in_GPCM_ic_only` relation instead.

- Do not compare models fit to different datasets, different score
  codings, or materially different constraint systems as if they were
  commensurate.

- At large Person counts, a small systematic likelihood gain can
  dominate an IC difference; boundary or singular fits can also
  invalidate routine asymptotics. Evaluate effect size, stability,
  interpretability, and score consequences separately.

## Interpreting output

- Lower AIC/BIC values indicate relative support only when
  `table$ICComparable` is `TRUE`; use SABIC ranking only when
  `table$SABICComparable` is also `TRUE`.

- A significant LRT p-value is formal evidence against the restricted
  model under the stated assumptions; practical gain, score utility, and
  dimensional interpretation require separate checks.

- `preferred` identifies the minimum criterion within the supplied
  candidate set; it is not an unconditional model verdict.

- `evidence_ratios` gives pairwise Akaike-weight ratios (returned only
  when Akaike weights can be computed for at least two models).

- When comparing more than two models, interpret evidence ratios
  cautiously—they do not adjust for multiple comparisons.

## How to read the main outputs

- `table`: first-pass comparison table; start with `ICComparable`,
  `ICSelectable`, `ICIntegrationTier`, `Model`, `Method`, `ICStatus`,
  `AIC`, `BIC`, and `SABIC`.

- `comparison_basis`: records whether IC and LRT claims are defensible
  for the supplied models. Inspect
  `comparison_basis$nesting_review$relation` and `reason` before reading
  any LRT output.

- `lrt`: nested-model test summary, present only when the requested and
  reviewed conditions are met.

- `preferred`: candidate preferred by each criterion when those
  summaries are available.

## Recommended next step

Inspect `comparison_basis` before writing conclusions. If comparability
is weak, treat the result as descriptive and revise the model setup (for
example, explicit `step_facet`, common data, or common constraints)
before using IC or LRT results in reporting.

## Typical workflow

1.  Fit two models with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    (e.g., PCM and bounded GPCM) on the same prepared rows, explicit
    step owner, constraints, and MML quadrature setting. Use at least 31
    common quadrature points for selectable ICs.

2.  Compare with `compare_mfrm(fit_pcm, fit_gpcm)` and start by checking
    `comparison$table$ICComparable`.

3.  Inspect `summary(comparison)` for AIC/BIC/SABIC diagnostics and,
    when appropriate, an LRT. PCM-versus-GPCM LRT is currently withheld.

4.  Use `build_weighting_review(fit_pcm, fit_gpcm)` to inspect which
    selected facet levels and information shares were reweighted by the
    slopes.

## References

- Burnham, K. P., & Anderson, D. R. (2002). *Model selection and
  multimodel inference: A practical information-theoretic approach* (2nd
  ed.). Springer.

- Akaike, H. (1974). A new look at the statistical model identification.
  *IEEE Transactions on Automatic Control, 19*(6), 716-723.

- Schwarz, G. (1978). Estimating the dimension of a model. *Annals of
  Statistics, 6*(2), 461-464.

- Sclove, S. L. (1987). Application of model-selection criteria to some
  problems in multivariate analysis. *Psychometrika, 52*(3), 333-343.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")

fit_rsm <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                     method = "MML", model = "RSM", quad_points = 31, maxit = 30)
fit_pcm <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                     method = "MML", model = "PCM",
                     step_facet = "Criterion", quad_points = 31, maxit = 30)
comp <- compare_mfrm(fit_rsm, fit_pcm, labels = c("RSM", "PCM"))
comp$table
#> # A tibble: 2 × 50
#>   Label Converged InferenceReady ConvergenceSeverity Model Method  nobs
#>   <chr> <lgl>     <lgl>          <chr>               <chr> <chr>  <int>
#> 1 RSM   TRUE      TRUE           pass                RSM   MML      768
#> 2 PCM   TRUE      TRUE           pass                PCM   MML      768
#> # ℹ 43 more variables: ResponseRows <int>, WeightedN <dbl>,
#> #   WeightedResponseTotal <dbl>, Persons <int>, ICSampleSize <dbl>,
#> #   ICSampleSizeBasis <chr>, Npar <int>, npar <int>, LogLik <dbl>,
#> #   Deviance <dbl>, AIC <dbl>, BIC <dbl>, SABIC <dbl>, SABICSelectable <lgl>,
#> #   WeightPolicy <chr>, ICEligible <lgl>, ICSelectable <lgl>, ICStatus <chr>,
#> #   ICContractVersion <chr>, AICFormula <chr>, BICFormula <chr>,
#> #   SABICFormula <chr>, IntegrationEvaluationId <chr>, …
comp$evidence_ratios
#> # A tibble: 1 × 3
#>   Model1 Model2 EvidenceRatio
#>   <chr>  <chr>          <dbl>
#> 1 RSM    PCM            0.466
# }
```
