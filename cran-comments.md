## Test environments

The full `R CMD check --as-cran` log against the v0.2.0 source tarball
will be attached to the submission. The intended environments are:

- local macOS Tahoe 26.x (aarch64-apple-darwin20), R 4.5.x
- win-builder R-devel, Windows Server 2022 x64, R 4.6.x
- GitHub Actions matrix: ubuntu-latest (release / devel / oldrel-1),
  macos-latest (release), windows-latest (release).

## R CMD check results

The full check log will accompany the submission. Expected outcomes:

- 0 errors.
- 0 warnings on win-builder and the GitHub Actions matrix
  (Ubuntu release / devel / oldrel-1, macos-latest release,
  windows-latest release). Local checks under macOS Tahoe + Apple
  clang 21.x emit one benign `-Wfixed-enum-extension` ignored
  warning that comes from R's own `R_ext/Boolean.h`, not from
  mfrmr; this is a clang/R-headers interaction unrelated to the
  package and does not appear on the CRAN-reference platforms.
- Possibly one INFO-level installed-size NOTE. The local installed
  footprint is in the 5-6 MB range, comparable to 0.1.5 and slightly
  reduced by the tightened `.Rbuildignore` rules.

## Downstream dependencies

No reverse dependencies. Verified via `revdepcheck::cran_revdeps("mfrmr")`
returning an empty character vector. The `revdep/` subdirectory carries
the `cran.md` note documenting this.

## Submission comment

This is an update to mfrmr. The current version on CRAN is 0.1.5
(published 2026-04-12); a 0.1.6 development version was tagged on
GitHub but is not on CRAN, so its NEWS section is included alongside
the 0.2.0 entry for completeness. Headline changes for 0.2.0 (sourced
from NEWS.md):

- Slope-aware GPCM fair-average and bias unblock.
  `fair_average_table()` and `estimate_bias()` now accept GPCM
  fits. The construction is the slope-aware element-conditional
  expected score: each slope-facet element row uses that element's
  own discrimination, while non-slope-facet rows (Person, Rater,
  ...) use the geometric-mean-one slope from the GPCM
  identification convention. The kernel reduces exactly to the PCM
  Linacre fair-average when all slopes equal one (regression-tested
  at machine precision against the existing PCM kernel reduction).
  Both helpers gain a `caveat` field clarifying that the SE columns
  are scaled facet-measure SEs, not delta-method standard errors of
  the fair-average / bias values; a true delta-method SE is
  scheduled for a follow-up release. `build_apa_outputs()`,
  `facets_parity_report()`, and the score-side
  `facets_output_file_bundle()` branch remain blocked under GPCM
  in this release; `gpcm_capability_matrix()` documents the
  current support contract.

- Person-fit `lz` rewritten to the proper polytomous form. The
  helper now reads the model category probability of the observed
  category directly, replacing the Gaussian-residual approximation
  used in earlier releases. The misnamed `ECI4` column has been
  removed because its implementation was the standardized
  Outfit-MnSq chi-square statistic, not the Tatsuoka & Tatsuoka
  (1983) extended-caution index. The `OutfitZSTD` column under
  the linear (Smith) approximation is the equivalent statistic.

- Continuous integration. New GitHub Actions workflows added
  alongside the existing `pkgdown.yaml`: `R-CMD-check.yaml` runs the
  matrix on Ubuntu (release / devel / oldrel-1) plus macos-latest and
  windows-latest (release), and `test-coverage.yaml` runs `covr` with
  artifact upload (no external service contacted).

- Differential-functioning display polish. `plot_dif_heatmap()` and
  `plot_dif_summary()` gain display controls (cell labels, flag
  thresholds, shared symmetric color limits, normal-approximation
  confidence intervals, effect-threshold guides, method-aware axis
  labels, an interpretation-guide payload).

- Defensive input validation. `analyze_dff()` and
  `dif_interaction_table()` now reject invalid `p_adjust`,
  non-integer `min_obs`, invalid `focal` groups, and all-missing
  group columns up front rather than failing inside the contrast
  computation. Missing or empty group rows are dropped with a
  `message()`.

- Plot payload printing. `print.mfrm_plot_data()` is now defined,
  so the `draw = FALSE` return value renders as a compact summary
  (name, title, payload shapes, legend / reference-line counts)
  instead of a raw list dump.

- Documentation honesty pass. `?fair_average_table` and `?fit_mfrm`
  gain explicit caveats clarifying that (a) the existing
  measure-level SE columns reported alongside fair-averages are
  not delta-method SEs of the fair-average value, (b) JML point
  estimates are biased per Neyman-Scott and MML is recommended for
  manuscript reporting, and (c) the latent-regression
  `population_coefficients` table is point-estimates only with no
  SE / vcov / Wald exposure.

- Build hygiene. `.Rbuildignore` tightened so an internal reading
  guide in `inst/references/` no longer ships in the source
  tarball; the runtime data file `facets_column_contract.csv` and
  the user-facing FACETS helper-mapping reference
  `FACETS_manual_mapping.md` are preserved.

## Default changes

No defaults change between 0.1.6 and 0.2.0. The 0.1.6 defaults
(`quad_points = 31`, `diagnostic_mode = "both"`,
`plot.mfrm_fit(type = "wright")`, `keep_original = FALSE`) are
retained.

Because 0.1.6 was not published to CRAN, users upgrading directly
from CRAN 0.1.5 to 0.2.0 will see three default flips that were
introduced in 0.1.6: `diagnose_mfrm(diagnostic_mode)` from `"legacy"`
to `"both"`, `plot(fit)` returning the Wright map alone instead of a
three-plot overview (the overview remains available via `plot(fit,
type = "bundle")`), and `fit_mfrm(quad_points)` from `15` to `31`.
The 0.1.6 NEWS section in `NEWS.md` documents the rationale and
revert paths.

## Deferred to a follow-up release

- User-facing GPCM unblock for `build_apa_outputs()`,
  `facets_parity_report()`, and the score-side
  `facets_output_file_bundle()` branch. These require the same
  delta-method SE infrastructure that is being deferred for
  `fair_average_table()` / `estimate_bias()`; rather than ship
  publication-grade APA or compatibility-contract output without
  those SEs, the helpers continue to raise the documented "not yet
  validated for GPCM fits" error.
- Native `analyze_dif_classical()` covering Mantel-Haenszel,
  logistic regression, and SIBTEST. Residual-method DIF
  (`analyze_dff()`, ETS A/B/C refit) remains the supported route.
- Five additional Rasch / IRT classic plots (KIDMAP, TCC,
  expected-score curve, cumulative ICC, information surface).
- Migration / GPCM-scope / classical-DIF vignettes. The five
  0.1.x vignettes ship unchanged.

These are scheduled for a follow-up release.
