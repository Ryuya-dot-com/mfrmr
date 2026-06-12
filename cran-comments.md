## Test environments

This is the submission note for the 0.2.1 release candidate. The local
pre-submission check was run against the generated `mfrmr_0.2.1.tar.gz`
source tarball.

The expected local pre-submission environment is:

- local macOS Tahoe 26.5, aarch64-apple-darwin23, R 4.6.0
  (2026-04-24).

Cross-platform confirmation is configured separately through:

- the package's GitHub Actions `R-CMD-check` matrix: macOS release, Windows
  release, and Ubuntu devel / release / oldrel-1, with warnings treated as
  failures.
- retained uploaded check directories from each matrix job.
- the separate coverage/full-regression route that runs with `NOT_CRAN=true`.

## R CMD check results

The current local pre-submission outcome is:

- 0 errors.
- 0 warnings.
- 0 notes.

Local check command, run from the package root against the generated
`mfrmr_0.2.1.tar.gz` source tarball:

```sh
R CMD build .
R CMD check --no-manual --as-cran mfrmr_0.2.1.tar.gz
```

No system-clock override was needed in this local run. On machines where
external time verification is unavailable, a local override may be used; the
release-readiness review should still be run against the resulting
`mfrmr.Rcheck/00check.log`, and the log must report package version 0.2.1.

In the current local `--as-cran` check, standard examples completed with a
reported `[47s/48s]` timing, `--run-donttest` examples completed with a
reported `[227s/234s]` timing, and the CRAN-time testthat surface completed
with no errors, warnings, or notes. The release-readiness review reports all
gates as `ok`.

## Downstream dependencies

No reverse dependencies are listed in the current CRAN package index for
Depends, Imports, or LinkingTo. Checked on 2026-06-12 against
`https://cloud.r-project.org` with `tools::package_dependencies(...,
reverse = TRUE)`.

## CRAN-time test scope

The CRAN-eligible test suite is intentionally limited to lightweight namespace,
alias, citation/data, and package-contract checks so the package stays within
the CRAN timing budget on slower Windows check hosts. This is a practical CRAN
submission constraint, not the full regression boundary.

Long integration, fit-backed guide, documentation-scan, coverage-expansion,
MML, external-Suggests, plotting, simulation, recovery, and stress tests remain
in the repository and are run outside CRAN timing constraints by setting
`NOT_CRAN=true`.

The package's release-readiness helper checks this distinction explicitly: the
local CRAN-like check log must match the target package version, and separate
non-CRAN regression evidence should be reviewed before submission.

For this candidate, the local full testthat surface was also run with
`NOT_CRAN=true` and completed with no test failures. The reported warnings come
from warning-path regression tests for duplicate-cell guards, intentionally low
iteration limits, and invalid facet/input guards.

## Submission comment

This is an update to mfrmr. Headline changes for 0.2.1 are:

- The main public route is now shorter and clearer:
  `fit_mfrm()` -> `mfrm_results()` -> `mfrm_report()` ->
  `export_mfrm_results()`, with `launch_mfrmr_viewer()` as an optional local
  reader over an existing result object.

- `mfrm_results()` provides a comprehensive first-screen object with status,
  triage, plot routes, table routes, next actions, and replay scaffolds over
  existing fit, diagnostic, report, and review components. It is a navigation
  and evidence-assembly layer, not a new estimator or validation rule.

- `mfrm_report()` turns an existing `mfrm_results` object into report-readiness
  tables, cautious wording routes, evidence-boundary tables, and HTML/Markdown
  output. It keeps fit, ZSTD, separation/reliability, bias screens, local
  misfit, and linking evidence in separate reporting lanes.

- `export_mfrm_results()` writes a lightweight object-first download folder
  with summary CSVs, collected tables, HTML, RDS, replay code, and manifest
  files. With `include = "report"` it also writes `mfrm_report()` artifacts.

- Bounded-GPCM recovery review now separates recovery metrics from unavailable
  SE/coverage evidence, generator-condition notes, sparse score-category
  support, and diagnostic-only fit/separation operating characteristics.

- Bounded-GPCM support now has a public support contract and runtime guard
  traceability route: `gpcm_capability_matrix()`,
  `gpcm_runtime_guard_coverage()`, and `mfrmr_output_guide("gpcm")` show which
  routes are supported, caveated, blocked, or deferred. Blocked/deferred public
  helper calls stop with structured `mfrmr_gpcm_scope_error` conditions rather
  than silently emitting partial score-side, planning, or narrative outputs.

- Sparse linked simulation and peer-review design helpers expose planned
  missingness, rater commonality, reviewer load, self-review exclusion, and
  network-review evidence as design diagnostics rather than recovery or
  validity gates.

- `mfrmr_interval_guide()` maps public 95% CI and uncertainty-display routes
  across fit-measure tables, Wright maps, fair averages, bias screens,
  displacement, DFF/DIF summaries, anchor drift, rater severity profiles,
  rater trajectories, manuscript Figure 1 composites, shrinkage, and ICC
  review, with explicit interval bases and interpretation boundaries.

- The release-readiness protocol now follows the target package version from
  `DESCRIPTION`, selects versioned evidence files when present, and rejects
  stale `R CMD check` logs whose package version does not match the target
  release.

## Default changes

No defaults change between 0.2.0 and 0.2.1.

The 0.1.6 defaults (`quad_points = 31`, `diagnostic_mode = "both"`,
`plot.mfrm_fit(type = "wright")`, `keep_original = FALSE`) are retained.
The current CRAN release, 0.2.0, already carries these defaults, so users
upgrading from CRAN 0.2.0 see no default changes.

## Deferred to a follow-up release

- Posterior-predictive checks for bounded GPCM.
- GPCM design operating-characteristic evaluation after the direct recovery
  route is stable.
- User-facing GPCM unblock for APA writer, QC pass/fail pipelines, linking
  synthesis, and FACETS-style score-side outputs after their score semantics
  and uncertainty propagation are validated.
- A classical-DIF helper covering Mantel-Haenszel, logistic regression, and
  SIBTEST. Residual-method DFF remains the supported route.
- Additional Rasch / IRT classic plots where they fit the validated reporting
  boundary.
