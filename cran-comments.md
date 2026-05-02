## Test environments

The full `R CMD check --as-cran` log against the v0.2.0 source tarball
will be attached to the submission. The intended environments are:

- local macOS Tahoe 26.x (aarch64-apple-darwin20), R 4.5.x
- win-builder R-devel, Windows Server 2022 x64, R 4.6.x
- GitHub Actions matrix: ubuntu-latest (release / devel / oldrel-1),
  macos-latest (release), windows-latest (release).

## R CMD check results

The full check log will accompany the submission. Expected outcomes
based on the local 0.1.6 baseline plus the incremental 0.2.0 diff:

- 0 errors.
- 0 warnings.
- A possible INFO-level installed-size NOTE. The 0.1.6 footprint was
  5.6 MB; 0.2.0 is expected to be similar (the diff is small) and
  may stay below the 5 MB soft note threshold once the tightened
  `.Rbuildignore` rules take effect.

## Downstream dependencies

No reverse dependencies. Verified via `revdepcheck::cran_revdeps("mfrmr")`
returning an empty character vector. The `revdep/` subdirectory carries
the `cran.md` note documenting this.

## Submission comment

This is an update to mfrmr 0.1.6. 0.2.0 is a small infrastructure +
polish release; no public function gains or removes its previous
support contract. Headline changes (sourced from NEWS.md):

- Continuous integration. New GitHub Actions workflows: R-CMD-check
  matrix on Ubuntu / macOS / Windows across R release / devel /
  oldrel-1, plus `test-coverage.yaml` running `covr` with artifact
  upload (no external service contacted). Replaces the prior
  pkgdown-only workflow.

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

- Documentation honesty pass. `?compute_person_fit_indices` now
  describes the `lz_star` column as a finite-sample-adjusted lz
  (placeholder `cn = 0`, `dn = 1/N`) rather than the full Snijders
  (2001) bias correction. The full Snijders ability-information
  correction is scheduled for a follow-up release.

- Build hygiene. `.Rbuildignore` tightened to exclude three
  internal planning files in `inst/references/` that were
  previously leaking into the tarball.

## Default changes

None. All 0.1.6 default values are retained in 0.2.0 (`quad_points = 31`,
`diagnostic_mode = "both"`, `plot.mfrm_fit(type = "wright")`,
`keep_original = FALSE`).

## Deferred to a follow-up release

Items planned for 0.2.0 but deferred to keep this release tightly
scoped to infrastructure and polish:

- User-facing GPCM unblock for `fair_average_table()`,
  `estimate_bias()`, and `build_apa_outputs()`. The slope-aware
  category-probability and log-likelihood kernels exist internally
  (`mfrmr:::category_prob_gpcm`, `mfrmr:::loglik_gpcm`) and reduce
  exactly to PCM at unit slopes (regression-tested at 1e-12 in
  `tests/testthat/test-estimation-core.R:148-185`); the user-facing
  helpers still raise the documented "not yet validated for GPCM
  fits" error so that the score-side semantics of slope-aware fair
  averages can be reviewed before exposure.
- Native `analyze_dif_classical()` covering Mantel-Haenszel,
  logistic regression, and SIBTEST. Residual-method DIF
  (`analyze_dff()`, ETS A/B/C refit) remains the supported route.
- Five additional Rasch / IRT classic plots (KIDMAP, TCC,
  expected-score curve, cumulative ICC, information surface).
- Migration / GPCM-scope / classical-DIF vignettes. The five
  0.1.x vignettes ship unchanged.

These are scheduled for 0.3.0.
