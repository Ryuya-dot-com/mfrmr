## Test environments

The local pre-submission check was run against the v0.2.0 source tarball in:

- local macOS Tahoe 26.4.1 (aarch64-apple-darwin23), R 4.6.0

Cross-platform confirmation is tracked separately through:

- win-builder R-devel on Windows Server x64.
- GitHub Actions matrix: ubuntu-latest (release / devel / oldrel-1),
  macos-latest (release), windows-latest (release), with warnings treated
  as CI failures, check logs uploaded as artifacts, and the non-exported
  release-readiness gate run after check.

## R CMD check results

The current local outcome is:

- 0 errors.
- 0 warnings.
- 0 notes.

Local check command:

```sh
R CMD build .
R CMD check --no-manual --as-cran mfrmr_0.2.0.tar.gz
```

## Downstream dependencies

No reverse dependencies. Verified via `revdepcheck::cran_revdeps("mfrmr")`
returning an empty character vector. The `revdep/` subdirectory carries
the `cran.md` note documenting this.

## Test scope

The CRAN-eligible test suite covers the exported estimation, diagnostic,
reporting, FACETS-comparison, simulation, and plotting APIs. A separate set of
long-running coverage-expansion and stress tests is guarded with
`testthat::skip_on_cran()` because those tests intentionally repeat expensive
fits or broaden branch coverage beyond the normal CRAN timing budget. They are
run locally and in CI outside CRAN timing constraints.

## Submission comment

This is an update to mfrmr. Headline changes for 0.2.0 (sourced from
NEWS.md):

- Bounded GPCM support is now explicitly scoped. Direct fitting,
  summaries, posterior scoring, information, category plots, direct
  simulation, parameter recovery, fair averages, bias screening,
  summary-table bundles, and appendix export are available within
  documented caveats. FACETS-style score-side exports, APA writer,
  fit-based report bundles, QC pass/fail pipelines, linking synthesis,
  planning / forecasting, posterior predictive computation, and MCMC
  remain outside the validated GPCM boundary.

- Mathematical corrections for 0.2.0 include identified
  step/threshold parameterization with the correct `steps - 1`
  degrees of freedom, a joint MML covariance layer for structural
  parameters, GPCM expected-score consistency, geometric-mean-one
  slope-scale consistency, and slope-aware GPCM bias SEs and
  profile-likelihood follow-up columns.

- `fair_average_table(fair_se = TRUE)` now adds opt-in structural
  delta-method SE and CI columns for bounded-GPCM fair averages when
  the MML observed-information covariance is available. The original
  measure-level SE columns remain distinct.

- FACETS-style fit comparison is explicit. `diagnose_mfrm()` accepts
  `fit_df_method = "engine"`, `"facets"`, or `"both"`, and
  `facets_fit_review()` / `read_facets_fit_table()` support scoped
  comparison against existing FACETS outputs without claiming that
  mfrmr estimates are FACETS estimates.

- `evaluate_mfrm_recovery()` and `assess_mfrm_recovery()` provide a
  dedicated ADEMP-style parameter-recovery route. Optional release
  validation helpers in `inst/validation/` generate top-line,
  case-level, domain-level, CSV/RDS, and Markdown outputs for
  release review.

- Public review helpers have been consolidated on `*_review*` names.
  Former public `*_audit*` function spellings, S3 compatibility
  classes, and duplicate top-level fields were removed as an
  intentional breaking cleanup.

- Documentation, citations, README guidance, vignettes, and NEWS have
  been updated to reflect the 0.2.0 support boundary and source-grounded
  release evidence map. `inst/validation/release-readiness.R` provides an
  optional non-exported release-readiness review that parses the local check log,
  checks version/terminology/evidence gates, and records any submission note
  explanation.

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

- Posterior-predictive checks for bounded GPCM.
- GPCM design operating-characteristic evaluation after the direct
  recovery route is stable.
- User-facing GPCM unblock for APA writer, QC pass/fail pipelines,
  linking synthesis, and FACETS-style score-side outputs after their
  score semantics and uncertainty propagation are validated.
- A classical-DIF helper (working title `analyze_dif_classical()`)
  covering Mantel-Haenszel, logistic regression, and SIBTEST.
  Residual-method DIF (`analyze_dff()`, ETS A/B/C refit) remains the
  supported route in 0.2.0.
- Additional Rasch / IRT classic plots where they fit the validated
  reporting boundary.

These are scheduled for a follow-up release.
