# September 20–21 candidate workflow and package checks

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
directory and was inspected only after completion. The pre-existing archive
was restored to its original repository-root location without overwriting a
new file.

| Archive | SHA256 | Role |
| --- | --- | --- |
| Initial | `09b0f07db2ade6e79e7c5656aa1429e1c6e8c8a2c51dd10214118b59b0fc8bdb` | Unmodified September 20 descriptive-review archive |
| Display correction (`final/`) | `a9ba0ae478ecbd789dd854a9aa3b7d04c847a745520101af32f30225aa414ec5` | Quadrature-summary print correction and NEWS |
| Tutorial correction (`docs/`) | `babce34dfb72c825455cf19e1c7a88e9aeddf0854f5613fbf8306d9c35f6db7e` | Availability-aware residual-PCA example and NEWS |
| Test repair (`repaired/`) | `c4be942084a1892d98096519ddba3b7079a8a73002770c4fd4f2a4d343ccf297` | Full local check; 20 existing test files corrected; includes the generated test PDF |
| Clean build (`clean/`) | `643a84202795f380309b1039e671a2eba9b812589f1af3c7f75552867bfa4fbd` | Fully rendered development candidate from `ff5df7c`; no generated test PDF |

Each archive and its source-file comparison are retained. For the first four
archives, all 538 packaged working files match their corresponding candidate
(generated DESCRIPTION metadata is treated separately).
`inst/validation` and `validation-results`
are excluded from all five archives. The second-to-third comparison confirms
that every R source, native source and packaged test is byte-identical; only
NEWS, DESCRIPTION metadata and the visual-diagnostics vignette/source/output
files differ. Full-suite evidence may therefore be reused for that unchanged
runtime/test content, while the corrected archive receives separate package,
example and vignette checks. These are distinct executions, not one invented
full-check result for a different archive. The final test-repair archive differs
from the tutorial candidate only in those 20 test files and generated DESCRIPTION
metadata; all production and documentation content is identical.

The clean archive is built from `git archive` of
`ff5df7cb90cbe09b47da290d4922f04f76ffd042` in an isolated directory with
`NOT_CRAN=false R CMD build --no-manual source`. All 537 reference source,
test and help files are byte-identical to the repaired archive. The vignettes
are built successfully, and neither a generated `Rplots.pdf` nor internal
validation files are present. Its own standard `NOT_CRAN=false R CMD check
--no-manual` exits with status 0 and **0 errors, 0 warnings and 0 notes**,
including examples and vignette rebuild. The test transcript records
**673 passes, 0 failures, 0 warnings and 3 intentional CRAN skips**.
The archive, source identity, build/check logs and test transcript are retained
in `clean/`. The full-suite results below concern their separately identified
archives; they are reused only for the identical executable/test source.

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
original full runs as clean. These were staged repairs; the subsequent clean
complete macOS run below is a separate execution of the repaired archive.

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

The same repaired archive subsequently passes a complete `NOT_CRAN=true
R CMD check --no-manual` on macOS with **0 errors, 0 warnings and 0 notes**.
Its full test transcript records **19,431 passes, 0 failures, 42 warnings and
44 skips**. The warning families/counts are unchanged: 39 category-support,
two FACETS-device-size and one JML information-criterion warning. The examples
and vignette rebuild also complete successfully. The check exits with status 0;
logs, transcript, warning counts and hashes are retained in
`repaired/full-macos/`. This run is bound to `c4be942...ccf297`, including the
local generated PDF identified above; the hosted clean-checkout build excludes
that PDF and must retain its own archive identity and check result.

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

The prior verified hosted run is
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
The consolidated dependency correction is commit
`ff5df7cb90cbe09b47da290d4922f04f76ffd042`, checked by
[35510248066](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/35510248066).
All five jobs complete successfully. The final job finishes at
`2026-09-20T13:55:18Z`; the run JSON confirms the expected source commit and
five successful jobs. All receipts identify that commit and tree
`97a282167eb227ffacbef370e17db33bfc4de56a`, and each receipt's check-log hash
matches the downloaded file. Every package check has **0 errors, 0 warnings
and 0 notes**. Each cell also passes both international-input cases and all
eight moved-folder archive replays.

| Hosted environment | R version | Suite | Pass | Fail | Test warnings | Skips |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| macOS release | 4.6.1 | CRAN-light | 673 | 0 | 0 | 3 |
| Windows release | 4.6.1 | CRAN-light | 673 | 0 | 0 | 3 |
| Ubuntu devel | 2026-09-19 r90572 | CRAN-light | 673 | 0 | 0 | 3 |
| Ubuntu release | 4.6.1 | Complete | 19,431 | 0 | 42 | 44 |
| Ubuntu oldrel-1 | 4.5.3 | CRAN-light | 673 | 0 | 0 | 3 |

Ubuntu release's 42 test-warning messages and counts match the local complete
macOS run exactly: 39 category-support, two FACETS-device-size and one JML
information-criterion warning. The three CRAN-light skips are intentional;
the complete suite's 44 skips remain recorded, not counted as successes.

| Hosted environment | Checked source-tarball SHA256 from receipt |
| --- | --- |
| macOS release | `c8f8b401cd02c0f7553e63ad0784308afc27451def4c7769deba2c0828fb5108` |
| Windows release | `e18a708c525d921fec13c12fe79fb93e96dffa3753cc55f8d6a59c2a3500b017` |
| Ubuntu devel | `30de2b9f17f8f90109b5209cd876e1c8e2f939f802bdb2a5a8b1c8702be416f7` |
| Ubuntu release | `b106a629c450f7318c7b2fb5cdf0102fdc306c1168a218cde93f6e9ed723bed9` |
| Ubuntu oldrel-1 | `f0be39109232813b2cc1ec7e58e6e25e0cbf84376c6db10ccbc05c753459570b` |

All 537 reference source files are byte-identical in macOS and all three
Ubuntu check sources. Windows has 26 byte-identical files and 511 UTF-8 text
files differing only in CRLF line endings; normalization to LF matches every
reference hash. No checked source contains the generated PDF. These distinctions
are retained in `source-comparison.csv`; the five verified receipts, test counts
and portability results are summarized in `verified-cells.csv` under
`hosted-35510248066/`. Per-environment build metadata and rendered output retain
their separate archive identities above.

The local macOS arm64 R 4.6.1 run and Ubuntu 22.04 arm64 R 4.3.2 container are
separate environment observations. The existing Linux image identity and
installed package versions are retained. It lacks `kableExtra`, `flextable`,
`mirt`, `TAM`, `eRm` and `lpSolve`; unavailable optional paths must remain
explicitly skipped/unassessed. It is not a substitute for the hosted R-version
matrix. `platform-matrix.csv` now records all five completed and verified hosted
cells as passing. The result-record update changes only three excluded
maintainer Markdown files; the tested source identity remains `ff5df7c`.

Next: assess formal 0.2.4 candidate readiness against the existing scoped claim
decisions, reconcile release metadata and the CRAN submission text with these
results, then check the exact versioned submission archive. The checked package
is still `0.2.4.9000`, not the final 0.2.4 submission archive. Do not launch new
research studies or broaden statistical claims merely to finish release work.

## September 21: versioned candidate and additional CRAN checks

The user's instruction to continue candidate preparation follows the verified
September 20 matrix. A local branch,
`development/0.2.4-release-candidate-20260921`, starts at result-record commit
`15e2404637bd16fe80176f838454b688350e3f96`. DESCRIPTION, NEWS, CITATION and the
introductory README/roadmap statements now identify **0.2.4 as an unreleased
candidate**, dated September 21. The public baseline remains 0.2.3.1. This
preparation does not reuse the August transition's approval or the September 6
G6 decision for a different source, close the 18 statistical claim groups,
issue a new G4 receipt, or perform publication/submission. The retained scope
and deferred inferential extensions remain those in the current claim ledger.

The initial versioned archive has SHA256
`ed36ad77156b0892f77fe4172c7dec14b208ca51ce6eeeadafad1ba5a64b0ce1`.
Its `NOT_CRAN=false R CMD check --as-cran` runs additional `donttest` examples
and both PDF/HTML manual checks. It exposes a real D-study display defect:
`mfrm_d_study()` computes a current result, but the documented column selection
loses its calculation/interpretation attributes while retaining its S3 class.
Printing that selection then falsely reports an older saved result. The
initial check ends with one ERROR and one NOTE; the CRAN-light tests still
have 673 passes, no failures/warnings and three skips. The failed archive and
logs are preserved under `validation-results/release-candidate-20260921/initial-as-cran/`.

A D-study subset method now delegates indexing to the standard data-frame
method and retains existing metadata on data-frame results. Vector extraction
keeps the standard dropping behavior. Printing handles a selected table that
omits the residual-scaling column. The stale-result guard is unchanged, and
subsetting a genuinely old result does not manufacture a current version.
The parsed G-study constructor, D-study calculation and stale-result validation
functions are identical to the tested baseline. Their numerical evidence is
reused; no estimator, variance formula, decision threshold or statistical scope
is changed. The focused Q3/person-fit/G-D file passes 115 expectations with no
failures, warnings or skips, including the documented selection and retained
stale-result refusal.

The first repair archive, SHA256
`751e0f5a750555e87fc2842ab93c0ec8b22ca57bd8f875fc7ebd3dbd918085fc`,
passes all additional examples and both manual checks. Its sole ERROR is the
namespace test's expected list missing the deliberately registered subset
method. The explicit list is updated; exact-set checking remains unchanged,
and all four namespace expectations pass. This failed check is retained under
`repaired/`, rather than counted as a clean candidate check.

The resulting archive, SHA256
`21da85a5270290226a338a5235d5d758b700aa06bc8fa1b76a83b3e58d847e67`,
is retained under `final/`. Of the 537 reference files, 531 are byte-identical.
The six changed files are NAMESPACE, NEWS, README, the G/D adapter and its two
test files; DESCRIPTION separately carries candidate version/date/status.
No generated test PDF or internal validation directory is included. Its
exact-archive `NOT_CRAN=false R CMD check --as-cran` exits with status 0:
**0 errors, 0 warnings and 1 NOTE**. All additional `donttest` examples,
673 CRAN-light expectations (zero failures/warnings, three intended skips),
vignette rebuild and PDF/HTML manual generation pass. The sole NOTE concerns
the submission history below. Logs and source comparisons are retained under
`final/`. The September 20 hosted matrix belongs to `ff5df7c`. The new matrix
below supplies the changed candidate's platform coverage.

The official CRAN source index was retrieved at `2026-09-20T22:39:26Z`
(September 21 JST). It reports public version 0.2.3.1 and zero direct reverse
Depends, Imports, LinkingTo, Suggests and Enhances relationships. The index,
its hash and the five-field result are retained in the September 21 evidence
directory. CRAN incoming feasibility also reports seven updates in the past
six months; that submission-history NOTE is retained in the submission text,
with the concrete correctness/reporting reasons for this update.

The versioned candidate is commit
`9010f660cb0093f3423550324d8543322dc87892`, tree
`33049bc8ca94843e939c95d87a14550febdfbed9`. All 537 reference files in the
final local archive match that committed source. It was pushed to the already
authorized remote branch `development/0.2.4-prerelease-validation-20260920`.
Its hosted run,
[35543743143](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/35543743143),
finishes at `2026-09-21T00:38:15Z` with all five jobs successful. The final run
JSON and all five receipts identify this commit; receipt tree, version and
check-log hashes are also verified. Every hosted package check has
**0 errors, 0 warnings and 0 notes**.

| Hosted environment | R version | Suite | Pass | Fail | Test warnings | Skips |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| macOS release | 4.6.1 | CRAN-light | 673 | 0 | 0 | 3 |
| Windows release | 4.6.1 | CRAN-light | 673 | 0 | 0 | 3 |
| Ubuntu devel | 2026-09-19 r90572 | CRAN-light | 673 | 0 | 0 | 3 |
| Ubuntu release | 4.6.1 | Complete | 19,438 | 0 | 42 | 44 |
| Ubuntu oldrel-1 | 4.5.3 | CRAN-light | 673 | 0 | 0 | 3 |

The complete suite's seven additional passing expectations cover the D-study
selection repair. Its 42 warning messages and counts match the retained
September 20 complete Mac reference exactly: 39 category-support, two
FACETS-device-size and one JML information-criterion warning. All skips remain
recorded; they are not counted as successes. Each hosted cell also passes both
international-input cases and all eight moved-folder archive replays.

| Hosted environment | Checked source-tarball SHA256 from receipt |
| --- | --- |
| macOS release | `3c537bd4e931097ebb121c4d7c3751779e0fddfb830da19c3dd1d0350c34e808` |
| Windows release | `88e8a30c7ed22a2d0d73a8f67a2e7827a5f804ada37987b19f8a5d844825ea11` |
| Ubuntu devel | `9b316757414a8a937700db9f3c8e91cf3abd0fa1081ee55a0739a600d1917e4a` |
| Ubuntu release | `e8fabdd55606d88005a1e0abfa9abe951409cc99755f86bd534998f0f21d450d` |
| Ubuntu oldrel-1 | `d0ef5607b202f4db3a76d2508c1db325a8ef9823c416ff8dc5d321b65dc51cac` |

All 537 reference source files are byte-identical in macOS and all three
Ubuntu checked sources. Windows has 26 byte-identical files and 511 UTF-8 text
files differing only in CRLF line endings; LF normalization matches every
reference hash. No checked source contains generated test PDFs or internal
validation files. Evidence is retained under
`validation-results/release-candidate-20260921/hosted-35543743143/`:
`run-completed.json`, `verified-cells.csv`, `source-comparison.csv`,
`full-test-warnings.csv` and the downloaded artifacts. These platform-specific
archives retain their own identities; the local `--as-cran` archive remains
`21da85a5…47e67`, with its one submission-history NOTE.

The result-record update changes only four build-excluded maintainer files;
the tested source identity remains `9010f66`. No new numerical study or repeat
of the unchanged package checks is needed for these records. Current claim
dispositions and deferred inferential extensions remain unchanged. Review of
those dispositions and the publication/submission decision remain separate;
this work does not publish a release or submit to CRAN.
