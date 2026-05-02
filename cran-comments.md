## Test environments

The exact check log will be regenerated against the v0.2.0 tag. The
planned environments are:

- local macOS Tahoe 26.x (aarch64-apple-darwin20), R 4.5.x
- win-builder R-devel, Windows Server 2022 x64, R 4.6.x
- GitHub Actions matrix: ubuntu-latest (release / devel / oldrel-1),
  macos-latest (release), windows-latest (release).

## R CMD check results

The exact check log will be regenerated against the v0.2.0 tag.
Expected outcomes:

- 0 errors.
- 0 warnings.
- A possible INFO-level installed-size note. The 0.1.6 footprint was
  5.6 MB; 0.2.0 grows by an estimated 200-400 KB from the new R sources,
  vignettes, and tests, putting the total in the 5.8-6.0 MB range.

## Downstream dependencies

No reverse dependencies. Verified via `revdepcheck::cran_revdeps("mfrmr")`
returning an empty character vector. The `revdep/` subdirectory carries
the `cran.md` note documenting this.

## Submission comment

This is an update to mfrmr 0.1.6. Headline changes (sourced from NEWS.md):

- Bounded GPCM scope expansion. The fair-average table, bias detection,
  and APA writer now support GPCM fits under the slope-aware kernel
  (Linacre 1989 / Muraki 1992 generalisation), with the mean-slope
  counterfactual and discrimination-stratified diagnostic exposed via
  `slope_aware = FALSE` and `stratify_facet`. Only the FACETS
  compatibility-contract score-side outputs remain blocked under GPCM.

- Native classical DIF detection. The new `analyze_dif_classical()`
  function adds Mantel-Haenszel (Holland & Thayer 1988), logistic
  regression (Swaminathan & Rogers 1990), and SIBTEST (Shealy & Stout
  1993) differential item functioning detection as native
  implementations. No new package dependencies. Default polytomous
  handling uses Liu & Agresti (1996) cumulative common odds-ratio for
  MH, proportional-odds cumulative-link logistic for the logistic
  family, and Poly-SIBTEST (Chang, Mazzeo & Roussos 1996) for SIBTEST.
  Default matching is the calibrated person measure from the parent
  fit; raw-score matching is exposed via `match = "sumscore"`.

- Five new Rasch / IRT classic plots. `plot_kidmap()` (Mead 1985 KIDMAP),
  `plot_tcc()` (Lord 1980 test characteristic curve),
  `plot_expected_score_curve()` (per-element expected score),
  `plot_cumulative_icc()` (cumulative category response curves), and
  `plot_information_surface()` (test information surface across pairs
  of facets).

- Continuous integration. New GitHub Actions workflows: R-CMD-check
  matrix on Ubuntu / macOS / Windows across R release / devel /
  oldrel-1, plus test-coverage with covr (artifact upload, no external
  service contacted).

- Documentation. Three new vignettes covering the migration from
  Facets, the bounded GPCM scope, and the classical DIF surface.

## Default changes

- `fair_average_table()` for GPCM fits no longer raises an error; the
  slope-aware kernel (Option A in the documented rationale) is the
  default. Code paths that previously caught the error in
  `tryCatch()` will now receive a populated bundle. Pass
  `slope_aware = FALSE, slope_summary = "geomean"` to obtain the
  mean-slope counterfactual instead.
