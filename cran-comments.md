## Test environments

- local macOS Tahoe 26.4 (aarch64-apple-darwin20), R 4.5.2
- win-builder R-devel, Windows Server 2022 x64, R 4.6.0 beta
  (2026-04-10 r89868 ucrt), GCC 14.3.0

No reverse dependency checks were required because the package has no known
reverse dependencies.

## R CMD check results

- local macOS Tahoe 26.4, R 4.5.2, `R CMD check --as-cran` on
  `mfrmr_0.1.6.tar.gz`:
  0 errors | 1 warning | 0 notes

The remaining warning observed locally is from the R installation headers /
Apple clang toolchain, not package source:

- `/Library/Frameworks/R.framework/Resources/include/R_ext/Boolean.h:62:36:
  warning: unknown warning group '-Wfixed-enum-extension', ignored`

CRAN incoming feasibility, examples, `--run-donttest` examples, tests,
vignettes, and PDF manual checks passed in the local run.

- win-builder R-devel, Windows Server 2022 x64, R 4.6.0 beta:
  0 errors | 0 warnings | 0 notes

CRAN incoming feasibility, examples, tests, vignette rebuilding, PDF manual,
and HTML manual checks passed on win-builder.

If a Linux check returns a NOTE about installed package size (the local check
classifies the 5.6 MB installed footprint at INFO level), it reflects the
260+ exported documented API entries (`R/` subdir 3.1 MB of compiled Rd +
bytecode, `help/` 1.0 MB); no large bundled data or pre-built binary is
shipped. The `data/` directory is 44 KB and `inst/` is 1.0 MB.

## Downstream dependencies

No known reverse dependencies.

## Submission comment

This is an update to mfrmr 0.1.5. Headline changes:

- empirical-Bayes facet shrinkage (`apply_empirical_bayes_shrinkage()`,
  `fit_mfrm(facet_shrinkage = "empirical_bayes")`) with the
  classical Efron-Morris (1973) variance estimator clearly documented;
- hierarchical-audit family (`detect_facet_nesting()`,
  `compute_facet_icc()`, `compute_facet_design_effect()`,
  `analyze_hierarchical_structure()`) with profile / parametric-bootstrap
  CIs for ICC;
- APA output adapters (`build_apa_outputs()`, `apa_table()`,
  `as_kable()`, `as_flextable()`) and the `reporting_checklist()`
  manuscript-readiness companion;
- expanded reporting surface: `summary(diagnose_mfrm())` now prints
  the fixed/random chi-square, the inter-rater agreement summary, an
  MnSq-misfit auto-flag block, and a category-usage table;
  `summary(fit_mfrm())` adds a targeting block; `summary(estimate_bias())`
  adds Bonferroni and Holm corrected counts. Thresholds are steered
  package-wide via the new `mfrm_misfit_thresholds()` getter / setter;
- second wave of visualisations (`plot_local_dependence_heatmap()`,
  `plot_reliability_snapshot()`, `plot_residual_matrix()`,
  `plot_shrinkage_funnel()`, plus the screening helpers
  `plot_guttman_scalogram()`, `plot_residual_qq()`,
  `plot_rater_trajectory()`, `plot_rater_agreement_heatmap()`),
  Winsteps-Table-30-style `plot_bubble(view = "infit_outfit")`, and a
  fixed `mfrm_plot_data` payload contract for `plot_dif_heatmap()`;
- bug fixes:
  - bias / interaction NA columns (`estimate_bias()` /
    `estimate_all_bias()` no longer return NA for `S.E.`, `t`, `Prob.`,
    `Obs-Exp Average`, `Infit`, `Outfit`);
  - `estimate_bias()` informative error when `facet_a` / `facet_b` is
    typo'd (was a silent empty-list);
  - score-out-of-range guard in `prepare_mfrm_data()`;
  - graphical helpers now restore the user's `par()` on exit;
  - ZSTD numerical instability for very small df;
  - `compute_facet_icc()` reports `ICC = NA` /
    `Interpretation = "Non-identifiable"` for singular fits;
  - `as_kable(format = "pipe")` consistently returns Markdown;
  - `plot_dif_heatmap(draw = FALSE)` now returns the documented
    `mfrm_plot_data` payload (was the bare matrix);
- new public reference card (`inst/cheatsheet/mfrmr-cheatsheet.pdf`,
  pre-rendered alongside the `.Rmd` source) and a Facets / Winsteps
  cross-reference table inside `?mfrmr_visual_diagnostics`;
- CITATION now tracks `DESCRIPTION` Version automatically.

This release also flips three defaults (each clearly enumerated in NEWS.md
under "Default changes (three breaking flips)" and individually reversible
by passing the previous value):

- `diagnose_mfrm(diagnostic_mode = ...)` default `"legacy"` -> `"both"`,
  so RSM/PCM fits surface the latent-integrated marginal-fit screen
  alongside the residual stack without explicit opt-in;
- `plot(fit)` default returns the Wright map alone as `mfrm_plot_data`;
  the previous three-plot overview is preserved at `plot(fit, type = "bundle")`
  with the same `mfrm_plot_bundle` class and slot names;
- `fit_mfrm(quad_points = ...)` default `15` -> `31` so a default MML fit
  is stable enough for direct manuscript reporting; faster exploratory
  iteration is still available with `quad_points = 7` or `15`.

`analyze_facet_equivalence(conf_level = ...)` is renamed to `ci_level` for
consistency with the rest of the package surface; passing the old name
issues a deprecation warning and continues to work for one release.
