## Resubmission

This is a resubmission. The 0.2.1 submission passed the CRAN incoming
content pre-tests on Windows and Debian (both `Status: OK`) but was
auto-rejected for a single additional-issue check on the Windows incoming
host: `Overall checktime 12 min > 10 min`.

The Windows incoming check log shows that time was dominated by
`checking R code for possible problems` (188s), the standard example run
(175s), the PDF/HTML manuals (149s), and the CRAN-time tests (57s).
0.2.2 reduces the controllable parts of that budget and changes nothing
else:

- Long-running illustration examples previously wrapped in `\donttest`
  are now wrapped in `\dontrun`.
- Example pages whose executed (standard) examples measurably exceeded
  0.25 seconds locally are now gated with `@examplesIf interactive()`.
  The executed example surface keeps 129 lightweight pages plus the core
  `fit_mfrm()` example (about 4 seconds locally, versus the 39 seconds
  that produced the 175-second Windows example phase).

Apart from one internal test-infrastructure fix (a NEWS-section anchor in
a documentation-consistency test), there are no other code,
documentation, or behavior changes relative to 0.2.1. All illustrations
remain in the help pages and remain executable as written; the underlying
routes are exercised by the package's test suite (run in full with
`NOT_CRAN=true` locally and on the CI matrix below).

## Test environments

This is the submission note for the 0.2.2 release candidate. The local
pre-submission check was run against the generated `mfrmr_0.2.2.tar.gz`
source tarball.

The expected local pre-submission environment is:

- local macOS Tahoe 26.5, aarch64-apple-darwin23, R 4.6.0
  (2026-04-24).

Cross-platform confirmation (obtained for 0.2.1, whose checked content is
identical to 0.2.2 apart from the example-execution policy):

- the package's GitHub Actions `R-CMD-check` matrix completed successfully:
  macOS release, Windows release, and Ubuntu devel / release / oldrel-1,
  with warnings treated as failures and the full `NOT_CRAN=true` test
  surface enabled.
- check directories from each matrix job are retained as uploaded artifacts.
- win-builder reported `Status: OK` for R-devel (2026-06-11 r90134 ucrt),
  R 4.6.0 (release), and R 4.5.3 (oldrelease).
- the 0.2.1 CRAN incoming pre-tests reported `Status: OK` on both Windows
  and Debian; only the Windows overall-checktime limit was exceeded.

## R CMD check results

The current local pre-submission outcome is:

- 0 errors.
- 0 warnings.
- 0 notes.

Local check command, run from the package root against the generated
`mfrmr_0.2.1.tar.gz` source tarball:

```sh
R CMD build .
R CMD check --no-manual --as-cran mfrmr_0.2.2.tar.gz
```

No system-clock override was needed in this local run. On machines where
external time verification is unavailable, a local override may be used; the
release-readiness review should still be run against the resulting
`mfrmr.Rcheck/00check.log`, and the log must report package version 0.2.2.

In the current local `--as-cran` check, standard examples completed with a
reported `[48s/49s]` timing, the `--run-donttest` pass had no additional
examples to execute (all long-running illustrations are now `\dontrun`),
and the CRAN-time testthat surface completed with no errors, warnings, or
notes. Relative to the 0.2.1 check on the same machine, this removes about
three minutes of example execution from the check. The release-readiness
review reports all gates as `ok`.

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

This is an update to mfrmr (and a resubmission of the 0.2.1 candidate; see
the Resubmission section above). Headline changes relative to CRAN 0.2.0
are:

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
