# September 20 candidate workflow and package checks

This record binds the portable-workflow replay and package checks to source
archives. It preserves initial failures and distinguishes local environments
from the required hosted CI matrix. It does not change any statistical claim
disposition or authorize publication.

## Source identity

Evidence root: `validation-results/release-candidate-20260920/`.
The archives were built from uncommitted changes on `development/0.2.4`,
based on `ff0675b8d54aa51f4f24ffc6948a460f1d7261a1`. The base commit is not
the identity of the candidate's modified source. The repaired candidate is now
saved in commit `a8a1836fdd2a7edeafb74bfe1aeb8d3febc0cc31` on
`development/0.2.4-prerelease-validation-20260920`. Before committing, all 538
packaged working-file hashes and the repaired archive hash were verified again.
The only subsequent pre-commit change was to the excluded public roadmap:
"valid-time denominators" now states the number of observations with valid
times. The existing 48-expectation public-wording check and source/lifecycle
review pass. Package source and archive contents are unchanged.

The subsequent commit-to-archive comparison distinguishes 537 committed files,
all byte-identical, from one Git-ignored local `tests/testthat/Rplots.pdf`.
That generated plot was included in the local archive but is absent from a
clean checkout. `.Rbuildignore` is corrected to exclude `Rplots.pdf` at any
depth, preventing future local builds from distributing test-device output.
This packaging correction does not alter executable source, tests or help.
An actual `R CMD build --no-manual --no-build-vignettes` confirms the exclusion;
this packaging-only archive is not a replacement for the fully rendered
candidate. Its successful log and archive are under `packaging/`. The first
build failed because a pre-existing output archive was moved while R was
copying the source directory. That old archive/initial inspection and failed
log are retained separately; the successful build ran from an isolated output
directory and was inspected only after completion.

| Archive | SHA256 | Role |
| --- | --- | --- |
| Initial | `09b0f07db2ade6e79e7c5656aa1429e1c6e8c8a2c51dd10214118b59b0fc8bdb` | Unmodified September 20 descriptive-review archive |
| Display correction (`final/`) | `a9ba0ae478ecbd789dd854a9aa3b7d04c847a745520101af32f30225aa414ec5` | Quadrature-summary print correction and NEWS |
| Tutorial correction (`docs/`) | `babce34dfb72c825455cf19e1c7a88e9aeddf0854f5613fbf8306d9c35f6db7e` | Availability-aware residual-PCA example and NEWS |
| Test repair (`repaired/`) | `c4be942084a1892d98096519ddba3b7079a8a73002770c4fd4f2a4d343ccf297` | Current candidate; 20 existing test files corrected |

Each archive and its source-file comparison are retained. All 538 packaged
working files match their corresponding candidate (generated DESCRIPTION
metadata is treated separately). `inst/validation` and `validation-results`
are excluded from all four archives. The second-to-third comparison confirms
that every R source, native source and packaged test is byte-identical; only
NEWS, DESCRIPTION metadata and the visual-diagnostics vignette/source/output
files differ. Full-suite evidence may therefore be reused for that unchanged
runtime/test content, while the corrected archive receives separate package,
example and vignette checks. These are distinct executions, not one invented
full-check result for a different archive. The final test-repair archive differs
from the tutorial candidate only in those 20 test files and generated DESCRIPTION
metadata; all production and documentation content is identical.

## Reproduced defects

The public portable-calibration tutorial calls `summary(quadrature_review)`.
Its print method exposed `not_assigned_continuous_evidence_only` and
`none_diagnostic_only`. The display now omits the two internal status columns
and explains that the comparison applies no automatic stability classification
or readiness change. Structured overview fields and numerical comparisons are
unchanged. The saved-review replay and installed public tutorial verify this
without a new fit-quality or uncertainty claim.

The Linux check then reached the visual-diagnostics vignette and failed at
its unconditional overall residual-PCA scree plot. The operational example
has an incomplete design: 81 residual-column pairs have no shared Persons.
The current calculation correctly retains their unavailable correlations,
leaving overall PCA unavailable; the Criterion-specific matrix still yields
three components. The tutorial now shows `summary(pca)`, checks the overall
result's availability before plotting, and explains why a facet-specific PCA
cannot replace the overall analysis. No zero imputation, matrix smoothing,
new covariance computation or relaxed PCA guard was introduced.

The initial Linux standard check retained 673 passing expectations, no test
failures or warnings, and three intentional CRAN skips. Its package check
failed at that vignette (one ERROR); three NOTEs concerned absent optional
packages, their Rd cross-references and installed size. This failed run remains
in `final/linux/`; the correction must be assessed from later checks.

## Portable workflow

The producer follows the executable public vignette: fit, review integration,
extract, validate, freeze and save. The scoring session receives the artifact
and three new-Person response groups after moving the directory to a Japanese
name containing a space. One Person has all missing responses. It remains
unscored in the disposition review and absent from score coordinates, with no
artificial plotted point. The requested interval level is 0.955.

- A fresh macOS process returns an exactly identical score object.
- The artifact and new rows alone are transferred to a fresh Linux process.
  The maximum absolute EAP/SD/interval difference is
  `6.66133814775094e-16`; settings and row/Person dispositions are identical.
- CSV exports retain numeric values, calibration identity, scoring algorithm,
  requested interval level, and estimate/uncertainty interpretation.
- The optional fixed-versus-adaptive integration review differs by at most
  `2.35367281220533e-14` across the two environments.
- Four previously saved fixed/adaptive v1/v2 artifacts retain their numerical
  scores, settings and dispositions, including legacy-summary metadata recovery.
- The established CI portability runner passes two international-input cases
  and all eight moved-folder export/replay cases against the installed display
  candidate. Its warnings are retained in the scenario CSVs.

`compare-portable-initial.R` initially used `all.equal()`'s relative default
for small *differences* in the integration review. It reported a relative
`6.22e-10` discrepancy in a log-marginal change near `2.86e-6`, despite all
absolute discrepancies being below `1e-12`. The comparison now specifies
absolute scale 1 at the same `1e-12` tolerance and records the actual maximum.
The original assertion/log is retained; no scoring values or thresholds used
by the package were changed.

The small synthetic tutorial grids establish the executed workflow, not a
recommended quadrature order, sampling coverage, prior transportability or
calibration-uncertainty propagation. RSM/PCM and scoring-algorithm scope remain
as documented in the claim ledger; this RSM tutorial does not substitute for
all other model tests.

## Package checks and test repairs

The complete packaged suite was run with `NOT_CRAN=true`; this is broader
than the standard 16-file CRAN-light selection. The initial and display-corrected
macOS archives both returned **19,402 passes, 21 failures, 42 warnings and 44
skips**. Their full package checks returned two errors: those test failures
and the now-corrected vignette. These unsuccessful original runs are retained.
The initial Linux full run returned **17,592 passes, 39 failures, 62 warnings
and 138 skips**, with its capability versions recorded separately.

The 21 shared failures were outdated test expectations, not grounds to restore
the former behavior: old/internal headings, invented self-agreement diagonals,
unavailable JML FairM drawing, and incomplete category-result fixtures. The
threshold test also supplied increasing estimates while asserting disorder from
stale `Spacing`/`Ordered` columns. It now checks a genuinely decreasing pair,
one unavailable comparison, and recomputation from estimates. Drawing tests
request diagnostic FairZ explicitly; existing FairM refusal tests are retained.
Empty/mismatched diagnostics still fail the production identity guard.

Eighteen additional Linux failures came from test preconditions. Boundary
certification tests require the optional `lpSolve` solver. Five test blocks now
declare that dependency, following the existing suite convention. Numerical
comparison and readiness-propagation tests still execute without it and require
an unevaluated/review state instead of a successful certificate. A stale-source
test now flips the actual inference flag, rather than assigning `FALSE` to an
already-false flag. No optimizer, boundary, scoring, or inference acceptance
rule was relaxed, and no new dependency was made mandatory.

After repair, the 11 shared-failure files pass **1,515 expectations with zero
failures, warnings or skips** on macOS against the check-installed production
code. The 20-file Linux follow-up passes **2,886 expectations with zero failures
or warnings and eight solver-dependent skips**. These targeted runs reuse the successful remainder of the complete runs and do not relabel the
original full runs as clean. A clean complete run of the final archive remains
part of the hosted Ubuntu-release check; the local follow-up is deliberately
reported as a staged repair, not a fabricated single-run full-suite success.

The 42 macOS full-test warnings comprise 39 existing category-support warnings,
two FACETS-label device-size warnings and one JML information-criterion warning.
The prior September 17 run had 35/2/1 respectively; no new warning-message
family appeared. Warnings remain visible. Repository-only excluded studies are
not counted as executed tests, and optional-package skips are not successes.

The tutorial-corrected archive passes `NOT_CRAN=true R CMD check
--no-manual --no-tests` on macOS (0 errors, 0 warnings, 0 notes). The same
command in Linux, with `_R_CHECK_FORCE_SUGGESTS_=false` and networking disabled,
passes with 0 errors, 0 warnings and three environment NOTEs. Linux also runs
all eight extracted vignette scripts successfully, including the previously
failing visual-diagnostics example. Logs are under `docs/` and `docs/linux/`.

The final test-repair archive passes standard `NOT_CRAN=false R CMD check
--no-manual` on macOS with **0 errors, 0 warnings and 0 notes**; its CRAN-light
suite records **673 passes, 0 failures, 0 warnings and 3 intentional skips**.
The exact archive, check log and test transcript are retained in `repaired/`.
This is not the full packaged-suite selector.

The isolated Linux follow-up initially omitted the existing serialized-0.2.2
fixture from its copied test directory. That file is present in the package
archive; after copying it, only `readiness-propagation` was repeated, passing
all 92 expectations. The 20-file aggregate substitutes that complete successful
file result for the earlier fixture-copy failure and preserves both records.
An initial CSV export attempted to write testthat's list-column results;
the saved RDS results were intact, and the CSV now retains scalar columns.
Neither validation-runner correction changes package source or tests.

The initial Linux full check also reported an extra vignette-rebuild NOTE
about unavailable Pandoc. The subsequent documentation check's logged result
is kept separately; successful extracted-script execution is not promoted to
a general Linux rendering qualification.

## Hosted platform matrix

The established matrix is macOS release (prerequisite), Windows release,
Ubuntu devel, Ubuntu release and Ubuntu oldrel-1. Ubuntu release runs the full
`NOT_CRAN=true` tier; the other hosted cells run the CRAN-light selection.

The latest successful hosted run is
[34758410726](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/34758410726),
created September 13 for commit
`805d6ae34dae0026d93259e4e0d62d6c4a97c1c1`. All five jobs succeeded for that
source. Its JSON is retained, but none is represented as current-candidate
coverage. The current candidate was sent to the dedicated validation branch
after the user explicitly authorized this payload and destination, resolving
the initial automatic approval rejection. The new run is
[35509420965](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/35509420965),
created September 20 for commit
`a8a1836fdd2a7edeafb74bfe1aeb8d3febc0cc31`. Its first attempt stopped during
dependency installation: pak could not recognize the downloaded macOS
`flextable_0.10.1.tgz` archive. No package check ran, and the remaining matrix
was skipped after the macOS prerequisite failed. The failed log and job JSON
are retained under `hosted-35509420965/`. A same-commit second attempt failed
at the same dependency, before package checks. Direct retrieval from the logged
CRAN mirror confirms Zstandard bytes in the `.tgz` file; the alternate Mac
mirror returned 404. The same version's source `.tar.gz` uses gzip and lists
successfully. The macOS cell now requests `flextable=?source`, using pak's
[documented downstream source parameter](https://pak.r-lib.org/reference/pak_package_sources.html#parameters).
The workflow's warnings-as-failures and repository-review checks remain active.
The packaging/CI correction is commit
`b7ec0e2cc9d172ef2d6a677fc7dae6b7f7be5cb5`. The user authorized this and further
necessary CI repairs/result records on the same validation branch. Its new run,
[35509977343](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/35509977343),
stopped at the same installation stage on `knitr_1.52.tgz`; the log confirms
that the flextable source override was applied. A range-request inspection of
all 143 binary URLs in the original install plan identifies exactly three
Zstandard archives: flextable, knitr and xfun. All requests succeeded, and
their four-byte signatures are retained in `macos-archive-formats.csv` under
`hosted-35509977343/`. The macOS source override now covers these three packages.
All runtime, packaged test and help files are identical to
`a8a1836`; only the exclusion rule, CI workflow and this internal record differ.

The local macOS arm64 R 4.6.1 run and Ubuntu 22.04 arm64 R 4.3.2 container are
separate environment observations. The existing Linux image identity and
installed package versions are retained. It lacks `kableExtra`, `flextable`,
`mirt`, `TAM`, `eRm` and `lpSolve`; unavailable optional paths must remain
explicitly skipped/unassessed. It is not a substitute for the hosted R-version
matrix. All five current-candidate cells remain pending in
`platform-matrix.csv`.

Next: bind the repaired candidate to the hosted five-environment matrix,
including one clean complete packaged-suite run of that exact candidate. Do not launch new research studies or
broaden statistical claims merely to finish package validation.
