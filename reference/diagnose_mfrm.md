# Compute diagnostics for an `mfrm_fit` object

Compute diagnostics for an `mfrm_fit` object

## Usage

``` r
diagnose_mfrm(
  fit,
  interaction_pairs = NULL,
  top_n_interactions = 20,
  whexact = FALSE,
  fit_df_method = c("engine", "facets", "both"),
  diagnostic_mode = c("both", "legacy", "marginal_fit"),
  residual_pca = c("none", "overall", "facet", "both"),
  pca_max_factors = 10L
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- interaction_pairs:

  Optional list of facet pairs.

- top_n_interactions:

  Number of top interactions.

- whexact:

  Logical controlling the ZSTD standardisation of mean-square fit
  statistics. `FALSE` (default) applies the Wilson-Hilferty cube-root
  transformation \\(\mathrm{MnSq}^{1/3} - (1 -
  2/(9\\\mathit{df})))/\sqrt{2/(9\\\mathit{df})}\\ (recommended; the
  Winsteps/FACETS convention for `WHEXACT=Y`). `TRUE` uses the simpler
  linear-normal standardisation \\(\mathrm{MnSq} -
  1)\sqrt{\mathit{df}/2}\\, which is kept for backward compatibility
  with earlier mfrmr summaries and with FACETS' `WHEXACT=N` mode.

- fit_df_method:

  Degrees-of-freedom convention used for fit ZSTD. `"engine"` (default)
  keeps the package-native convention `DF_Infit = sum(Var * Weight)` and
  `DF_Outfit = sum(Weight)`. `"facets"` uses the FACETS/Wright-Masters
  fourth-moment approximation `df = 2 / q^2` as the primary `InfitZSTD`
  / `OutfitZSTD` basis and caps reported ZSTD values at +/-9. `"both"`
  keeps the engine convention as the primary columns and adds `*_FACETS`
  companion columns for comparison.

- diagnostic_mode:

  Diagnostic basis to compute: `"both"` (the current default) computes
  both the residual/EAP-based stack and the strict latent-integrated
  first-order marginal-fit companion; `"legacy"` keeps the
  residual/EAP-based stack only; `"marginal_fit"` returns only the
  marginal-fit companion. The `"both"` path adds a posterior-integrated
  pass that typically doubles to quintuples wall-clock time relative to
  `"legacy"`; pass `"legacy"` explicitly when iterating on large designs
  and only the residual stack is needed. Use `"both"` for RSM/PCM
  reporting fits because it enables
  [`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md)
  and
  [`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md)
  follow-up.

- residual_pca:

  Residual PCA mode: `"none"`, `"overall"`, `"facet"`, or `"both"`.

- pca_max_factors:

  Maximum number of PCA factors to retain per matrix.

## Value

An object of class `mfrm_diagnostics` including:

- `obs`: observed/expected/residual-level table

- `measures`: facet/person fit table (`Infit`, `Outfit`, `ZSTD`,
  `PTMEA`, `ModelSE`, `RealSE`, `CI_Lower`, `CI_Upper`, `CI_Level`,
  `CI_Method`)

- `overall_fit`: overall fit summary

- `fit`: element-level fit diagnostics

- `reliability`: facet-level model/real separation and reliability

- `precision_profile`: one-row summary of the active precision tier and
  its recommended use

- `precision_review`: package-native checks for SE, CI, and reliability

- `parameter_uncertainty`: MML observed-information uncertainty for
  structural parameters when available (`steps`, and bounded-`GPCM`
  `slopes` on both log and positive scales), plus covariance status
  metadata

- `facet_precision`: facet-level precision summary by distribution basis
  and SE mode

- `facets_chisq`: fixed/random facet variability summary

- `interactions`: top interaction diagnostics

- `interrater`: inter-rater agreement bundle (`summary`, `pairs`)
  including agreement and rater-severity spread indices

- `unexpected`: unexpected-response bundle

- `fair_average`: adjusted-score reference bundle (reported as
  unavailable for bounded `GPCM`)

- `displacement`: displacement diagnostics bundle

- `approximation_notes`: method notes for SE/CI/reliability summaries

- `diagnostic_basis`: guide to the statistical target of each diagnostic
  path

- `fit_standardization`: guide to the df convention behind fit ZSTD
  values

- `marginal_fit`: optional strict marginal-fit companion based on
  posterior-expected first-order category counts

- `residual_pca_overall`: optional overall PCA object

- `residual_pca_by_facet`: optional facet PCA objects

## Details

This function computes a diagnostic bundle used by downstream reporting.
It calculates element-level fit statistics, approximate facet
separation/reliability summaries, residual-based QC diagnostics, and
optionally residual PCA for exploratory residual-structure screening.

`diagnostic_mode` keeps the legacy residual fit path explicit rather
than silently replacing it. The legacy path is a compatibility-oriented
residual/EAP stack, whereas the strict marginal path targets
latent-integrated first-order category counts. When
`diagnostic_mode = "both"`, the output includes a `diagnostic_basis`
guide so downstream tables and summaries can distinguish these targets.

Choosing `diagnostic_mode`:

- `"legacy"`: use when continuity with historical residual-based
  workflows is the priority.

- `"marginal_fit"`: use when you want the strict latent-integrated
  screen without the extra legacy bundle.

- `"both"`: recommended when you want continuity with the legacy
  residual stack while making the strict marginal path explicit for
  `RSM`, `PCM`, and bounded `GPCM` fits.

For bounded `GPCM`, the same generalized partial credit kernel now
drives both the residual/probability tables and the strict marginal
category-fit companion. Residual-based MnSq summaries should still be
read as exploratory screening tools rather than strict Rasch-style
invariance tests because discrimination is free, and the strict marginal
companion should likewise be treated as a slope-aware screen rather than
a finalized inferential test family.

**Key fit statistics computed for each element:**

- **Infit MnSq**: information-weighted mean-square residual; sensitive
  to on-target misfitting patterns. Expected value = 1.0.

- **Outfit MnSq**: unweighted mean-square residual; sensitive to
  off-target outliers. Expected value = 1.0.

- **ZSTD**: Wilson-Hilferty cube-root transformation of MnSq to an
  approximate standard normal deviate.

- **PTMEA**: point-measure correlation (item-rest correlation in MFRM
  context); positive values confirm alignment with the latent trait.

The MnSq values and the ZSTD values should be read separately. `mfrmr`
keeps the package-native engine df convention by default because it is
the basis used by the R/Python/Julia validation engines. FACETS reports
closely related MnSq values but standardizes them with a Wright-Masters
fourth-moment df approximation (`df = 2 / q^2`) and caps reported ZSTD
values. Use `fit_df_method = "both"` to review these two standardization
conventions side by side without changing the primary `InfitZSTD` /
`OutfitZSTD` columns.

**Residual basis under MML.** For `method = "MML"` fits, residuals,
MnSq, and ZSTD are computed at the EAP person measures from the marginal
model. EAP measures are shrunken toward the population mean, so expected
scores – and therefore fit statistics – differ systematically from
JMLE-based engines such as FACETS, especially for persons with extreme
raw scores. The df conventions above do not remove this difference: it
is a residual-basis difference, not a standardization difference. Refit
with `method = "JML"` when an external FACETS fit comparison requires a
JMLE-style residual basis (see
[`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md)).

**Misfit flagging guidelines (Bond & Fox, 2015):**

- MnSq \< 0.5: overfit (too predictable; may inflate reliability)

- MnSq 0.5–1.5: productive for measurement

- MnSq \> 1.5: underfit (noise degrades measurement)

- \\\|\mathrm{ZSTD}\| \> 2\\: statistically significant misfit (5\\

When Infit and Outfit disagree, Infit is generally more informative
because it downweights extreme observations. Large Outfit with
acceptable Infit typically indicates a few outlying responses rather
than systematic misfit.

`interaction_pairs` controls which facet interactions are summarized.
Each element can be:

- a length-2 character vector such as `c("Rater", "Criterion")`, or

- omitted (`NULL`) to let the function select top interactions
  automatically.

Residual PCA behavior:

- `"none"`: skip PCA (fastest; recommended for initial exploration)

- `"overall"`: compute overall residual PCA across all facets

- `"facet"`: compute facet-specific residual PCA for each facet

- `"both"`: compute both overall and facet-specific PCA

Overall PCA examines the person \\\times\\ combined-facet residual
matrix; facet-specific PCA examines person \\\times\\ facet-level
matrices. These summaries are exploratory screens for residual
structure, not standalone proofs for or against unidimensionality.
Facet-specific PCA can help localise where a stronger residual signal is
concentrated.

These residual-PCA summaries are not a DIMTEST/UNIDIM implementation.
DIMTEST-style essential-unidimensionality tests work at an item-response
layer and require an explicit decision about how many-facet rating data
are collapsed, conditioned, or adjusted for rater/task/facet effects.
For manuscripts, combine global/element fit, residual PCA, and
local-dependence screens, and use limited wording such as "evidence
consistent with essential unidimensionality under the specified facet
structure" rather than "unidimensionality was established."

## Reading key components

Practical interpretation often starts with:

- `overall_fit`: global infit/outfit and degrees of freedom.

- `reliability`: facet-level model/real separation and reliability.
  `MML` uses model-based `ModelSE` values where available; `JML` keeps
  these quantities as exploratory approximations.

- `fit`: element-level misfit scan (`Infit`, `Outfit`, `ZSTD`).

- `unexpected`, `fair_average`, `displacement`: targeted QC bundles. For
  bounded `GPCM`, `fair_average` is retained with an unavailable status
  because that compatibility calculation has not yet been validated for
  the generalized model.

- `approximation_notes`: method notes for SE/CI/reliability summaries.

## Interpreting output

Start with `overall_fit` and `reliability`, then move to element-level
diagnostics (`fit`) and targeted bundles (`unexpected`, `displacement`,
`interrater`, `facets_chisq`). Treat `fair_average` as available only
for the `RSM` / `PCM` branch.

Consistent signals across multiple components are typically more robust
than a single isolated warning. For example, an element flagged for both
high Outfit and high displacement is more concerning than one flagged on
a single criterion.

`SE` is kept as a compatibility alias for `ModelSE`. `RealSE` is a
fit-adjusted companion defined as `ModelSE * sqrt(max(Infit, 1))`.
Reliability tables report model and fit-adjusted bounds from observed
variance, error variance, and true variance; `JML` entries should still
be treated as exploratory. Separation, strata, and reliability follow
the Wright & Masters (1982) conventions: \\G =
\mathrm{TrueSD}/\mathrm{RMSE}\\, \\R = G^2 / (1 + G^2)\\, and \\H =
(4G + 1) / 3\\.

## Typical workflow

1.  Start with
    `diagnose_mfrm(fit, diagnostic_mode = "both", residual_pca = "none")`.

2.  Inspect `summary(diag)` and use `diagnostic_basis` to separate
    legacy residual evidence from strict marginal evidence.

3.  If needed, rerun with residual PCA (`"overall"` or `"both"`).

## References

- Wright, B. D., & Masters, G. N. (1982). *Rating scale analysis*. MESA
  Press. (G/R/H separation, reliability, and strata formulas summarized
  in `s_diag$reliability` follow this convention.)

- Wright, B. D., & Linacre, J. M. (1994). Reasonable mean-square fit
  values. *Rasch Measurement Transactions, 8*(3), 370. (Source for the
  0.5-1.5 Infit / Outfit acceptance band that `s_diag$key_warnings` and
  `misfit_thresholds` apply.)

- Linacre, J. M. (1989). *Many-Facet Rasch Measurement*. MESA Press.
  (FACETS Tables 6 + 7 correspond to the per-facet element measures,
  fit, and chi-square heterogeneity screen exposed via
  `s_diag$reliability` and `s_diag$facets_chisq`.)

- Bond, T. G., & Fox, C. M. (2015). *Applying the Rasch model:
  Fundamental measurement in the human sciences* (3rd ed.). Routledge.
  (Reference text for the Rasch-family fit conventions exposed by this
  helper.)

- Linacre, J. M. (2002). What do Infit and Outfit, Mean-square and
  Standardized mean? *Rasch Measurement Transactions, 16*(2), 878.

- Linacre, J. M. (2026). *A user's guide to Facets Rasch-model computer
  programs*. Winsteps.com. (WHEXACT / FACETS standardized fit df notes.)

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md),
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md),
[mfrmr_reporting_and_apa](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md)

## Examples

``` r
if (FALSE) { # interactive()
# Fast smoke run: legacy-only diagnostic mode is enough to confirm
# the bundle has the expected slots. ~1 s on example_core.
toy <- load_mfrmr_data("example_core")
fit_quick <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                      method = "JML", maxit = 30)
diag_quick <- diagnose_mfrm(fit_quick, diagnostic_mode = "legacy",
                             residual_pca = "none")
summary(diag_quick)$overview[, c("Observations", "Facets", "Categories")]

if (FALSE) { # \dontrun{
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, diagnostic_mode = "both", residual_pca = "none")
s_diag <- summary(diag)
s_diag$overview[, c("Observations", "Facets", "Categories")]
s_diag$diagnostic_basis[, c("DiagnosticPath", "Status", "Basis")]
s_diag$key_warnings
# Look for: "No immediate warnings ..." in `key_warnings` is the
#   "all clear" signal. Lines starting with "MnSq misfit:" name the
#   element + Infit / Outfit values that fell outside the
#   0.5-1.5 acceptance band; review those first.
s_diag$facets_chisq
# Look for: `FixedProb` < 0.05 means that facet's elements differ
#   reliably under the fixed-effect "all elements equal" null. A
#   facet with a non-significant chi-square contributes little
#   spread to the test scale.
s_diag$interrater
# Look for: ExactAgreement >= ExpectedExactAgreement and
#   AgreementMinusExpected >= 0 indicate raters agree at least as
#   often as the model expects. Negative values warrant a closer
#   look at `diag$interrater$pairs`.
p_qc <- plot_qc_dashboard(fit, diagnostics = diag, draw = FALSE)
p_qc$data$plot

# Optional: include residual PCA in the diagnostic bundle
diag_pca <- diagnose_mfrm(fit, residual_pca = "overall")
pca <- analyze_residual_pca(diag_pca, mode = "overall")
head(pca$overall_table)

# Reporting route:
prec <- precision_review_report(fit, diagnostics = diag)
summary(prec)
} # }
}
```
