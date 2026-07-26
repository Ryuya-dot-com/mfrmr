# mfrmr validation artifacts

This directory contains repository-only release-review helpers and evidence
artifacts. `.Rbuildignore` excludes it from the CRAN source tarball so optional
stress protocols cannot add package size or check time. Release decisions can
still be reconstructed from the public source repository, check logs, and
documented validation criteria.

Most package users can ignore this directory. Start with `README.md`,
`?fit_mfrm`, `?mfrm_results`, `?mfrm_report`, and `mfrmr_output_guide()` for
analysis guidance. The files here support package release checks and
maintenance review; public release notes stay in `NEWS.md`.

The repository-root `ROADMAP.md` is the single source of truth for active
development sequencing. Files in this directory may add evidence or preserve
history, but they do not redefine release order or current API scope.

## Evidence types

| Type | What it is for |
| --- | --- |
| Gate helper | A script that checks whether version labels, terminology, evidence files, and check logs still agree. |
| Fixed/status artifact | A compact Markdown or CSV record of evidence from a seeded or previously reviewed workflow. |
| Optional stress helper | A script for slower validation runs that should not run during ordinary CRAN checks. |
| Scope excerpt | A bounded roadmap or capability note used to keep unsupported claims out of public helpers. |

## Primary files

- `release-readiness.R`: release-readiness review. Source this file and run
  `mfrmr_release_readiness_review(pkg_dir = ".")` from the package root. The
  review checks version labels, the local check log, the CI check workflow,
  public terminology, and the release evidence files.
- `release-evidence-map-0.2.0.md`: narrative review map linking release
  claims to mathematical, statistical, UX, documentation, and engineering
  evidence.
- `release-evidence-map-0.2.2.md`: source-grounded evidence map for the
  0.2.2 bounded-`GPCM` recovery-review refinements, including the boundary
  between cited model literature and package-specific validation labels.
- `release-evidence-checklist-0.2.2.csv`: structured checklist used by the
  readiness helper and by manual release review for the current release. Older
  checklists are retained as historical release evidence.
- `mfrmr-development-roadmap.md`: historical validation record retained for
  links from older 0.2.2 evidence. It is not an active roadmap.
- `gpcm-post-0.2.2-roadmap.md`: technical evidence supplement for bounded-
  `GPCM` surfaces that remain caveated, `blocked`, or `deferred`. It is
  subordinate to the root roadmap and the executable capability registry.
- `external-parameter-recovery-simulation-0.2.0.md`: compact review of the
  separate common-data parameter-recovery simulation workflow. The large
  generated datasets and engine outputs are not bundled with the package; this
  file records the release-relevant evidence and its limits.
- `conquest-mml-overlap-0.2.2.md`: aggregate evidence from a matched 31-node
  external ConQuest 5.47.5 run in the documented binary, item-only,
  one-covariate MML overlap scope. It records comparison results and limits but
  does not include identifier-bearing response or case-level files.
- `external-recovery-audit.R`: optional audit helper that reads a local
  `Parameter_Recovery_Simulation/` output directory, checks expected CSV
  schemas, records file fingerprints, and regenerates the compact evidence
  summary tables used for release review.
- `generate-vignette-artifacts.R`: regenerates the small CSV files under
  `inst/extdata/vignette-artifacts/` that let CRAN-style vignette builds show
  representative workflow output without rerunning fitting and simulation
  chunks.
- `first-use-workflow-stress.R`: deterministic first-use workflow stress
  protocol for the complete data -> describe -> fit -> diagnostics ->
  FACETS-organized summary -> Wright-map route. It separates scenario-contract
  agreement from reporting triage and covers linked, sparse, disconnected,
  shared-link, PCM, bounded-GPCM, extreme-score, separation, sentinel-code,
  and weighted cases.
- `first-use-workflow-stress-0.2.2.md`: compact record of the 30-fit core
  matrix and the 300 cross-surface checks run for 0.2.2, with explicit limits
  on what that evidence establishes.

## Recommended local sequence

Run these commands from the package root after any source, roxygen, vignette, or
compiled-code change:

```sh
R CMD build .
R CMD check --no-manual --as-cran mfrmr_0.2.2.tar.gz
```

Then run:

```r
source("inst/validation/release-readiness.R")
readiness <- mfrmr_release_readiness_review(pkg_dir = ".")
summary(readiness)
```

The release candidate should have `Status: OK` in the local check log,
`ReleaseReadinessStatus = "ok"`, and only `ok` rows in
`readiness$gate_summary`. A missing `Status:` line, a check-log package version
that differs from `DESCRIPTION`, release inputs newer than the matching source
tarball or check log, or a check log older than that tarball is a release
blocker reported as a `concern`. If the local environment cannot verify
external clock time, record that environment-only NOTE in `cran-comments.md`
and rerun the package check with the clock check disabled to confirm that
package checks are otherwise clean.

When public workflow output changes, refresh the vignette artifacts before
building:

```r
source("inst/validation/generate-vignette-artifacts.R")
mfrmr_generate_vignette_artifacts(".")
```

CRAN-time tests are intentionally lightweight because CRAN check hosts have
strict timing constraints. Run the full non-CRAN regression surface separately
when release evidence is needed:

```sh
NOT_CRAN=true Rscript -e 'testthat::test_local(".")'
```

Run the first-use workflow protocol after loading the development tree. The
quick tier is for iteration; the core tier uses every scenario and three
deterministic seeds by default:

```r
pkgload::load_all(".")
source("inst/validation/first-use-workflow-stress.R")

quick <- mfrmr_run_first_use_stress("quick")
summary(quick)

core <- mfrmr_run_first_use_stress(
  "core",
  output_dir = "validation-results/first-use-workflow"
)
summary(core)
```

`ContractPassed` means that software behavior matched the scenario's explicit
Numerical/Data/Design/Stability/Reporting/Plot expectations. It does not mean
the run is manuscript-ready; inspect `UpstreamReportingHold`,
`DiagnosticReviewRequired`, `DiagnosticFollowUpPending`, and the recorded
readiness states separately. Large-data diagnostics, real graphics devices,
and cross-platform UTF-8 rendering remain full/nightly checks rather than CRAN
examples.

If the external common-data simulation workflow has been refreshed, audit it
from the package side before updating the evidence summary:

```r
source("inst/validation/external-recovery-audit.R")
external_review <- mfrmr_review_external_recovery_simulation(
  "../Parameter_Recovery_Simulation"
)
summary(external_review)

source("inst/validation/release-readiness.R")
readiness <- mfrmr_release_readiness_review(
  pkg_dir = ".",
  external_recovery_dir = "../Parameter_Recovery_Simulation"
)
summary(readiness)$external_recovery_status
```

## Cross-platform evidence

GitHub Actions runs the package on macOS, Windows, and Linux across release,
oldrel, and devel R. Warnings are treated as check failures. The workflow also
uploads the check directory as an artifact for each matrix job so that release
review can compare local and CI evidence instead of relying only on the final
job status.

The readiness helper checks the workflow contract from source. It does not
replace reading the uploaded CI artifacts before release. The
external parameter-recovery summary is an additional source-grounded review
artifact, not a substitute for rerunning the package tests or the optional
long-running validation scripts.
