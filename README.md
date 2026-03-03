# mfrmr

[![GitHub](https://img.shields.io/badge/GitHub-mfrmr-181717?logo=github)](https://github.com/Ryuya-dot-com/mfrmr)
[![R-CMD-check](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/pkgdown.yaml)
[![test-coverage](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/test-coverage.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Native R package for flexible many-facet Rasch model (MFRM) estimation without TAM/sirt backends.

## Features

- Flexible facet count (`facets = c(...)`)
- Estimation methods: `MML` (default) and `JML` (`JMLE` internally)
- Models: `RSM`, `PCM`
- FACETS-style one-shot wrapper (`run_mfrm_facets()`, alias `mfrmRFacets()`)
- Bias/interaction iterative estimation (FACETS-style)
- Optional fixed-width text reports for console/log audits (FACETS-style)
- APA-style narrative output helpers (`build_apa_outputs()`)
- Visual warning and summary maps (`build_visual_summaries()`)
- Residual PCA for unidimensionality checks (`overall` / `facet` / `both`)
- DIF analysis with ETS classification (`analyze_dif()`, `dif_report()`)
- Model comparison with information criteria (`compare_mfrm()`)
- Test information functions (`compute_information()`, `plot_information()`)
- Unified Wright map across facets (`plot_wright_unified()`)
- Anchoring and equating across administrations (`anchor_to_baseline()`, `detect_anchor_drift()`, `build_equating_chain()`)
- Automated 10-check QC pipeline (`run_qc_pipeline()`, `plot_qc_pipeline()`)
- Data descriptives and anchor audit helpers (`describe_mfrm_data()`, `audit_mfrm_anchors()`)
- Anchor export for linking workflows (`make_anchor_table()`)

## Installation

```r
# GitHub (development version)
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_github("Ryuya-dot-com/mfrmr")

# CRAN (after release)
# install.packages("mfrmr")
```

## Core workflow

```
fit_mfrm() --> diagnose_mfrm() --> reporting / advanced analysis
                    |
                    +--> analyze_residual_pca()
                    +--> estimate_bias()
                    +--> analyze_dif()
                    +--> compare_mfrm()
                    +--> run_qc_pipeline()
                    +--> anchor_to_baseline() / detect_anchor_drift()
```

1. Fit model: `fit_mfrm()`
2. Diagnostics: `diagnose_mfrm()`
3. Optional residual PCA: `analyze_residual_pca()`
4. Optional interaction bias: `estimate_bias()`
5. DIF analysis: `analyze_dif()`, `dif_report()`
6. Model comparison: `compare_mfrm()`
7. Reporting: `apa_table()`, `build_apa_outputs()`, `build_visual_summaries()`
8. Quality control: `run_qc_pipeline()`
9. Anchoring & equating: `anchor_to_baseline()`, `detect_anchor_drift()`, `build_equating_chain()`
10. FACETS-style parity audit: `facets_parity_report()`
11. Reproducible inspection: `summary()` and `plot(..., draw = FALSE)`

## Help-page navigation

All exported help pages include practical sections:

- `Interpreting output`
- `Typical workflow`

Recommended entry points:

- `?mfrmr-package` (package overview)
- `?fit_mfrm`, `?diagnose_mfrm`, `?run_mfrm_facets`
- `?analyze_dif`, `?compare_mfrm`, `?run_qc_pipeline`
- `?anchor_to_baseline`, `?detect_anchor_drift`, `?build_equating_chain`
- `?build_apa_outputs`, `?build_visual_summaries`, `?apa_table`

## Quick start

```r
library(mfrmr)

df <- load_mfrmr_data("study1")

# Fit
fit <- fit_mfrm(
  data = df,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM"
)
summary(fit)

# Diagnostics
diag <- diagnose_mfrm(fit, residual_pca = "both")
summary(diag)

# Bias estimation
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion")
summary(bias)

# APA outputs
apa <- build_apa_outputs(fit, diag)
cat(apa$report_text)

# QC pipeline
qc <- run_qc_pipeline(fit)
summary(qc)
```

## DIF analysis

```r
# Add a grouping variable
df$Group <- ifelse(as.integer(factor(df$Person)) %% 2 == 0, "A", "B")
dif <- analyze_dif(fit, diag, facet = "Rater", group = "Group", data = df)
dif$dif_table
dif$summary

# DIF interaction table for cell-level detail
dit <- dif_interaction_table(fit, diag, facet = "Rater", group = "Group", data = df)

# Visual and narrative report
plot_dif_heatmap(dif)
dr <- dif_report(fit, diag, facet = "Rater", group = "Group", data = df)
```

## Model comparison

```r
fit_rsm <- fit_mfrm(df, "Person", c("Rater", "Criterion"), "Score",
                     method = "MML", model = "RSM")
fit_pcm <- fit_mfrm(df, "Person", c("Rater", "Criterion"), "Score",
                     method = "MML", model = "PCM")
cmp <- compare_mfrm(RSM = fit_rsm, PCM = fit_pcm)
cmp$table

# Test information functions
info <- compute_information(fit)
plot_information(info)
```

## Anchoring and equating

```r
d1 <- load_mfrmr_data("study1")
d2 <- load_mfrmr_data("study2")
fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)
fit2 <- fit_mfrm(d2, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 25)

# Anchored calibration
res <- anchor_to_baseline(d2, fit1, "Person", c("Rater", "Criterion"), "Score")
summary(res)
res$drift

# Drift detection
drift <- detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2))
summary(drift)
plot_anchor_drift(drift, type = "drift")

# Equating chain
chain <- build_equating_chain(list(Form1 = fit1, Form2 = fit2))
summary(chain)
plot_anchor_drift(chain, type = "chain")
```

## QC pipeline

```r
qc <- run_qc_pipeline(fit, threshold_profile = "standard")
qc$overall      # "Pass", "Warn", or "Fail"
qc$verdicts     # per-check verdicts
qc$recommendations

plot_qc_pipeline(qc, type = "traffic_light")
plot_qc_pipeline(qc, type = "detail")

# Threshold profiles: "strict", "standard", "lenient"
qc_strict <- run_qc_pipeline(fit, threshold_profile = "strict")
```

## FACETS-style one-shot wrapper

```r
run <- run_mfrm_facets(
  data = df,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "JML",
  model = "RSM"
)
summary(run)
plot(run, type = "fit", draw = FALSE)
```

## Public API map

Model and diagnostics:

- `fit_mfrm()`, `run_mfrm_facets()`, `mfrmRFacets()`
- `diagnose_mfrm()`, `analyze_residual_pca()`
- `estimate_bias()`, `bias_count_table()`

DIF and model comparison:

- `analyze_dif()`, `dif_interaction_table()`, `dif_report()`
- `compare_mfrm()`
- `compute_information()`, `plot_information()`

Anchoring and equating:

- `anchor_to_baseline()`, `detect_anchor_drift()`, `build_equating_chain()`
- `plot_anchor_drift()`

QC pipeline:

- `run_qc_pipeline()`, `plot_qc_pipeline()`

Table/report outputs:

- `specifications_report()`, `data_quality_report()`, `estimation_iteration_report()`
- `subset_connectivity_report()`, `facet_statistics_report()`
- `measurable_summary_table()`, `rating_scale_table()`
- `category_structure_report()`, `category_curves_report()`
- `unexpected_response_table()`, `unexpected_after_bias_table()`
- `fair_average_table()`, `displacement_table()`
- `interrater_agreement_table()`, `facets_chisq_table()`
- `facets_output_file_bundle()`, `facets_parity_report()`
- `bias_interaction_report()`, `build_fixed_reports()`
- `apa_table()`, `build_apa_outputs()`, `build_visual_summaries()`

Plots and dashboards:

- `plot_unexpected()`, `plot_fair_average()`, `plot_displacement()`
- `plot_interrater_agreement()`, `plot_facets_chisq()`
- `plot_bias_interaction()`, `plot_residual_pca()`, `plot_qc_dashboard()`
- `plot_bubble()` -- Rasch-convention bubble chart (Measure x Fit x SE)
- `plot_dif_heatmap()` -- DIF heatmap across groups
- `plot_wright_unified()` -- unified Wright map across all facets
- `plot(fit, show_ci = TRUE)` -- confidence-interval whiskers on Wright map

Export and data utilities:

- `export_mfrm()` -- batch CSV export of all result tables
- `as.data.frame(fit)` -- tidy data.frame for `write.csv()` export
- `describe_mfrm_data()`, `audit_mfrm_anchors()`, `make_anchor_table()`
- `mfrm_threshold_profiles()`, `list_mfrmr_data()`, `load_mfrmr_data()`

Legacy FACETS-style numbered names are internal and not exported.

## FACETS reference mapping

See:

- `inst/references/FACETS_manual_mapping.md`
- `inst/references/CODE_READING_GUIDE.md` (for developers/readers)

## Packaged synthetic datasets

Installed at `system.file("extdata", package = "mfrmr")`:

- `eckes_jin_2021_study1_sim.csv`
- `eckes_jin_2021_study2_sim.csv`
- `eckes_jin_2021_combined_sim.csv`
- `eckes_jin_2021_study1_itercal_sim.csv`
- `eckes_jin_2021_study2_itercal_sim.csv`
- `eckes_jin_2021_combined_itercal_sim.csv`

The same datasets are also packaged in `data/` and can be loaded with:

```r
data("ej2021_study1", package = "mfrmr")
# or
df <- load_mfrmr_data("study1")
```

## Citation

```r
citation("mfrmr")
```
