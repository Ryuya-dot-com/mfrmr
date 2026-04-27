# Public Release Readiness Audit

Date: 2026-04-12
Package baseline: `mfrmr` 0.1.5

## Current verdict

Current readiness is:

- research / collaborator beta: about 85%
- GitHub public preview: about 85-88%
- CRAN / stable release: about 80-83%

The package is close to a defensible GitHub preview, but it should not be
released as stable or ready for CRAN submission until the release branch is
cleaned and rechecked from a clean clone.

## Evidence already green

- `R CMD check --no-manual` passed from a temporary tarball directory on
  2026-04-12 with `Status: 1 WARNING`.
- `R CMD check --as-cran` passed from a temporary tarball directory on
  2026-04-12 with `Status: 1 WARNING, 1 NOTE`.
- A targeted `R CMD check --as-cran --no-tests --ignore-vignettes --no-manual`
  pass confirmed that CRAN incoming feasibility and normal examples were clean
  after preserving `build/vignette.rds` and trimming heavy examples.
- The warning was the known Apple clang / R header warning:
  `unknown warning group '-Wfixed-enum-extension'`.
- The remaining full `--as-cran` NOTE was local HTML validation being skipped
  because the installed `tidy` was not recent enough.
- No package-specific errors, test failures, Rd mismatches, namespace loading
  failures, or example failures remained in the final check.
- `git diff --check` passed.
- No `.Rcheck` directory or `mfrmr_0.1.5.tar.gz` artifact was left in the
  package source directory after the check.
- The verified source tarball kept only source-side native and vignette inputs
  in the inspected release paths: `src/cpp11.cpp`, `src/mml_backend.cpp`, and
  vignette `.Rmd` files. Generated native artifacts, `src/symbols.rds`, and
  generated vignette `.R`/`.html` files were excluded. `build/vignette.rds`
  must remain available for CRAN incoming vignette-index checks.
- A follow-up source-tarball content check after internal-reference exclusions
  confirmed that `inst/references/` shipped only
  `CODE_READING_GUIDE.md`, `FACETS_manual_mapping.md`, and
  `facets_column_contract.csv`. Internal M1/M2/M3 planning notes,
  maintenance roadmaps, and public-release audits were excluded from the
  source tarball while remaining available in the repository.
- A cpp11 registration check on a temporary source copy confirmed that
  regenerating `R/cpp11.R` and `src/cpp11.cpp` from `src/mml_backend.cpp`
  produced no diff from the current files.
- A temporary source-tarball install into an isolated library loaded `mfrmr`
  0.1.5 and returned `cpp11_backend_available = TRUE`, confirming that the
  native backend source set is sufficient for a clean source install on the
  current macOS toolchain.
- A follow-up targeted `R CMD check --as-cran --no-tests --ignore-vignettes
  --no-manual` run after the cpp11/source-boundary and public-wording updates
  reached `Status: 1 WARNING`; normal examples and `--run-donttest` examples
  were OK, and the only warning was the same Apple clang / R header warning.
- The CRAN-facing `DESCRIPTION` wording was made conservative by using
  `publication-oriented summaries` rather than a stronger publication-completion
  claim.
  A source-tarball inspection confirmed the updated wording and found no
  old FACETS-parity wording in the shipped FACETS mapping reference.
- A source-set tarball inspection confirmed that required new source files
  were included (`R/cpp11.R`, `R/help_gpcm_scope.R`,
  `R/utils-method-labels.R`, `src/cpp11.cpp`, `src/mml_backend.cpp`,
  `man/gpcm_capability_matrix.Rd`, and
  `vignettes/mfrmr-mml-and-marginal-fit.Rmd`) while generated native/vignette
  artifacts and internal reference notes were excluded.
- A dry-run `git add -n` classification confirmed that the planned new source
  files would be staged, while native build products, generated vignette
  outputs, and `.DS_Store` were rejected by `.gitignore`.
- A final full temporary-tarball `R CMD check --as-cran` run after the
  source-boundary and public-wording updates completed in
  `/tmp/mfrmr-fullcheck-final-pass.LB2r4U` with
  `Status: 1 WARNING, 1 NOTE`. Normal examples, `--run-donttest` examples,
  testthat tests, vignette rebuilding, and the PDF manual were OK. The warning
  remained the known Apple clang / R header warning, and the note remained the
  local HTML Tidy validation skip.
- A follow-up public-wording sweep replaced over-strong table-readiness and
  external-software equivalence wording with conservative
  `manuscript-oriented` / `numerical equivalence` wording in README, roxygen
  source, Rd pages, tests, and NEWS where appropriate. A source search for the
  old strong wording returned no hits in the checked public source set.
- After that wording sweep, targeted reporting tests passed and a temporary
  tarball `R CMD check --as-cran --no-tests --ignore-vignettes --no-manual`
  completed in `/tmp/mfrmr-docwording-check.J83sv4` with
  `Status: 1 WARNING`; examples and `--run-donttest` examples were OK, and the
  only warning was the same Apple clang / R header warning.
- A roxygen synchronization pass moved manually useful Rd additions back into
  roxygen source comments, regenerated package documentation, and was
  idempotent on a second run. A follow-up temporary tarball
  `R CMD check --as-cran --no-tests --ignore-vignettes --no-manual` completed
  in `/tmp/mfrmr-roxy-sync-check.Qg0pJW` with `Status: 1 WARNING`; Rd
  metadata, Rd cross-references, code/documentation mismatches, examples, and
  `--run-donttest` examples were OK. The only warning was the same Apple
  clang / R header warning.
- The same post-roxygen tarball kept the intended installed-package references
  only (`CODE_READING_GUIDE.md`, `FACETS_manual_mapping.md`, and
  `facets_column_contract.csv`), did not include this audit file, and contained
  `build/vignette.rds` without generated vignette `.R`/`.html`, native build
  artifacts, or `src/symbols.rds`.
- A post-roxygen full temporary-tarball `R CMD check --as-cran` completed in
  `/tmp/mfrmr-post-roxy-fullcheck.1mMZHG` with `Status: 1 WARNING, 1 NOTE`.
  Normal examples, `--run-donttest` examples, testthat tests, vignette
  rebuilding, and the PDF manual were OK. The warning remained the known Apple
  clang / R header warning, and the note remained the local HTML Tidy
  validation skip. The checked tarball again contained only the intended
  installed-package reference files and `build/vignette.rds` among the audited
  generated-file paths.
- A release-source-set dry run using explicit pathspecs returned 183 candidate
  staged files: 30 `R/` files, 108 `man/` files, 31 test files, 3 vignette
  `.Rmd` files, 2 `src/*.cpp` files, and 2 changed installed-package reference
  files. A strict forbidden-file scan of that dry-run output found no native
  build artifacts, generated vignette `.R`/`.html` files, `.DS_Store`, `docs/`,
  or internal `inst/references/` planning/audit files.
- A clean-branch simulation was built without touching the Git index by
  exporting `HEAD` to `/tmp/mfrmr-clean-branch-sim.lsxEs2/mfrmr` and overlaying
  only the explicit release-source pathspec. The simulated tree had 269 files,
  no forbidden native/vignette/internal-reference artifacts, and only the
  intended installed-package reference files. A temporary tarball check from
  this simulated tree completed in `/tmp/mfrmr-clean-sim-check.LwvxpQ` with
  `Status: 1 WARNING` under
  `R CMD check --as-cran --no-tests --ignore-vignettes --no-manual`; normal
  examples and `--run-donttest` examples were OK, and the only warning was the
  same Apple clang / R header warning. The simulated tarball again excluded
  this audit file and included only `build/vignette.rds` among the audited
  generated-file paths.
- The 0.1.5 `NEWS.md` section was condensed from a developer-style change log
  into user-facing sections for first-use workflow, estimation/scoring,
  diagnostics/reporting/visualization, and external-software scope. Internal
  validation details, source-package mechanics, and implementation handoff
  details were kept out of NEWS and left to README/help pages or this audit
  file.

## Public feature boundary

The public wording must stay within this boundary:

- ordered-response `RSM` / `PCM` remain the main manuscript/reporting route;
- latent regression is implemented as a first-version `MML` population-model
  branch, but it is package-native and not a full ConQuest numerical-equivalence
  claim;
- the ConQuest overlap path is currently an internal/package-native dry-run
  and user-supplied-table audit route, not an executed external ConQuest
  validation;
- first-release `GPCM` supports the bounded direct route documented in
  `gpcm_capability_matrix()`;
- GPCM fair-average, score-side export, broad APA writer, broader visual
  summaries, and QC-pipeline claims remain blocked where the current
  score-side semantics are not validated;
- 3D visualization is an exploratory data handoff through
  `plot(fit, type = "ccc_surface", draw = FALSE)`, not a native interactive
  renderer and not a default APA/reporting figure.

## Roadmap

### Phase 0: Release-source hygiene

Goal: make the package reproducible from a clean branch.

- Isolate intended package changes from unrelated workspace files.
- Track required native source files if the cpp11 backend remains enabled:
  `R/cpp11.R`, `src/cpp11.cpp`, and `src/mml_backend.cpp`.
- Keep compiled artifacts out of Git and out of the source tarball:
  `src/*.o`, `src/*.so`, `src/*.dll`, `src/*.dylib`, and `src/symbols.rds`.
- Keep generated site/vignette outputs out of Git:
  `docs/`, `vignettes/*.R`, `vignettes/*.html`, and
  `vignettes/.install_extras`.
- Keep `build/` ignored in Git, but do not add `^build$` to `.Rbuildignore`;
  `R CMD build` must be able to include `build/vignette.rds` in the tarball.

### Phase 1: CRAN submission readiness

Goal: reduce the CRAN-facing residuals to environment-only issues or zero.

- Re-run full `R CMD check --as-cran` from a clean source branch and compare
  against the current local result: `Status: 1 WARNING, 1 NOTE`.
- Verify the warning disappears or remains toolchain-specific on another macOS
  toolchain, Linux, and Windows.
- Install or update HTML Tidy locally if possible, or confirm the HTML note is
  absent on CI/win-builder.
- Add win-builder and cross-platform CI results to `cran-comments.md`.
- Review `NEWS.md`, `README.md`, `DESCRIPTION`, and help pages for conservative
  scope wording: no full FACETS, ConQuest, SPSS, TAM, sirt, or mirt numerical
  equivalence claim unless the specific route is validated.

### Phase 2: User-facing beginner route

Goal: reduce the learning barrier without expanding unsupported claims.

- Continue improving first-use summaries: `summary(fit)`,
  `summary(diagnose_mfrm(...))`, `reporting_checklist()`,
  `build_summary_table_bundle()`, and `visual_reporting_template()`.
- Add short examples that show what to report in a paper, what table to use,
  and which plot should be treated as manuscript core versus appendix or
  diagnostic material.
- Keep heavy examples in vignettes or `\donttest{}` only when they provide
  meaningful tutorial value.

### Phase 3: Validation expansion

Goal: separate package-native evidence from external-software equivalence.

- Add external ConQuest validation when ConQuest is available.
- Continue FACETS/SPSS relationship documentation as conservative comparison
  guidance, not parity language.
- Expand latent-regression benchmarks for categorical covariates, missing
  covariate handling, posterior scoring, and recovery behavior.
- Keep GPCM downstream routes blocked until score-side semantics are validated
  for each route.

### Phase 4: Visualization expansion

Goal: improve interpretability without adding fragile rendering dependencies.

- Keep `plot(fit, type = "ccc_surface", draw = FALSE)` as a data-payload
  handoff for 3D or interactive rendering.
- Add examples that show how to interpret the payload tables before adding any
  native plotly/rgl-style dependency.
- Treat 2D Wright/pathway/category curves and QC plots as the core reporting
  route; keep 3D as appendix, teaching, or exploratory output.

### Phase 5: Post-CRAN stabilization

Goal: prepare a stable long-term API after the 0.1.5 release.

- Freeze user-facing names for summary tables, plot payloads, and export roles.
- Add lifecycle notes for experimental routes such as bounded GPCM and
  exploratory 3D handoff.
- Move any internal-only planning material out of the package tarball if it is
  no longer useful to installed-package users.

## Directory policy

Do not create a new top-level directory yet.

- Use this audit file for the release roadmap until the release branch is
  isolated.
- Use `inst/references/` only for documents that are acceptable to install with
  the package as user-facing or reproducibility references.
- CRAN source tarballs should keep only the installed-package reference files
  that users or package code need, especially `facets_column_contract.csv`,
  `FACETS_manual_mapping.md`, and `CODE_READING_GUIDE.md`.
- Internal M1/M2/M3 planning notes, execution protocols, maintenance roadmaps,
  and public-release audits should remain in the repository if useful, but are
  excluded from the CRAN source tarball through `.Rbuildignore`.
- For private release-management material that should not ship to CRAN, prefer
  a separate ignored directory only if the content grows beyond this audit
  file. If that becomes necessary, create a `release/` or `dev-notes/`
  directory and add it to `.Rbuildignore` before any CRAN tarball check.
- Do not add a new directory solely to organize generated artifacts; generated
  docs, vignette outputs, and native build outputs are already covered by the
  current ignore policy.

## Repeatable release checks

Run these from a clean release branch before labeling the package public-ready:

```sh
git status --short
git diff --check
git ls-files --others --exclude-standard -- R src man inst/references vignettes tests
```

Build from a temporary directory, not from inside the package tree:

```sh
CHECKDIR=$(mktemp -d /tmp/mfrmr-release.XXXXXX)
cd "$CHECKDIR"
VECLIB_MAXIMUM_THREADS=1 OMP_NUM_THREADS=1 R CMD build \
  "/path/to/mfrmr" \
  --no-manual --no-resave-data --compact-vignettes=both --md5
```

Confirm that only the intended installed-package reference files are in the
source tarball:

```sh
tar -tf mfrmr_0.1.5.tar.gz | grep '^mfrmr/inst/references/' | sort
```

Expected `inst/references/` entries:

- `mfrmr/inst/references/`
- `mfrmr/inst/references/CODE_READING_GUIDE.md`
- `mfrmr/inst/references/FACETS_manual_mapping.md`
- `mfrmr/inst/references/facets_column_contract.csv`

Confirm that required vignette metadata remains, but generated vignette/native
artifacts do not:

```sh
tar -tf mfrmr_0.1.5.tar.gz | grep -E \
  '(^mfrmr/build/vignette[.]rds$|^mfrmr/vignettes/.*[.](R|html)$|^mfrmr/src/.*[.](o|so|dll|dylib)$|^mfrmr/src/symbols[.]rds$)' | sort
```

Expected output:

- `mfrmr/build/vignette.rds`

If generated vignette `.R`/`.html` files, compiled native artifacts, or
`src/symbols.rds` appear in that command, stop and fix `.Rbuildignore` before
running `R CMD check`.

Then run:

```sh
VECLIB_MAXIMUM_THREADS=1 OMP_NUM_THREADS=1 R CMD check --as-cran mfrmr_0.1.5.tar.gz
```

If the cpp11 backend remains enabled, also verify a clean source install and
backend registration from an isolated library:

```sh
LIB=$(mktemp -d /tmp/mfrmr-lib.XXXXXX)
VECLIB_MAXIMUM_THREADS=1 OMP_NUM_THREADS=1 R CMD INSTALL -l "$LIB" mfrmr_0.1.5.tar.gz
MFRMR_TMP_LIB="$LIB" VECLIB_MAXIMUM_THREADS=1 OMP_NUM_THREADS=1 Rscript -e \
  '.libPaths(c(Sys.getenv("MFRMR_TMP_LIB"), .libPaths()));
   library(mfrmr);
   cat("loaded_version=", as.character(utils::packageVersion("mfrmr")), "\n", sep = "");
   cat("cpp11_backend_available=", mfrmr:::mfrm_cpp11_backend_available(), "\n", sep = "")'
```

After checks, verify the package source directory is still free of local check
artifacts:

```sh
find "/path/to/mfrmr" -maxdepth 2 \( -name '*.Rcheck' -o -name '..Rcheck' -o -name 'mfrmr_0.1.5.tar.gz' \) -print
```

## Release-blocking gates

### Source-set classification

Use this classification when preparing the release branch:

- Track as package source if the cpp11 backend remains enabled:
  `R/cpp11.R`, `src/cpp11.cpp`, and `src/mml_backend.cpp`.
- Track as package source for the current public API additions:
  `R/help_gpcm_scope.R` and `R/utils-method-labels.R`.
- Track generated-but-source Rd pages that correspond to exported or documented
  public helpers:
  `man/audit_conquest_overlap.Rd`, `man/build_conquest_overlap_bundle.Rd`,
  `man/build_linking_review.Rd`, `man/build_misfit_casebook.Rd`,
  `man/build_summary_table_bundle.Rd`, `man/build_weighting_audit.Rd`,
  `man/compatibility_alias_table.Rd`,
  `man/evaluate_mfrm_diagnostic_screening.Rd`,
  `man/export_summary_appendix.Rd`, `man/gpcm_capability_matrix.Rd`,
  `man/normalize_conquest_overlap_files.Rd`,
  `man/normalize_conquest_overlap_tables.Rd`,
  `man/plot.mfrm_future_branch_active_branch.Rd`,
  `man/plot.mfrm_summary_table_bundle.Rd`, `man/plot_marginal_fit.Rd`,
  `man/plot_marginal_pairwise.Rd`,
  `man/summary.mfrm_future_branch_active_branch.Rd`,
  `man/summary.mfrm_linking_review.Rd`,
  `man/summary.mfrm_misfit_casebook.Rd`,
  `man/summary.mfrm_reporting_checklist.Rd`,
  `man/summary.mfrm_summary_table_bundle.Rd`,
  `man/summary.mfrm_weighting_audit.Rd`, and
  `man/visual_reporting_template.Rd`.
- Track generated-but-source release metadata and regenerated existing Rd files
  when preparing the release branch: `NAMESPACE`, `man/mfrmr_visual_diagnostics.Rd`,
  `man/plot.mfrm_fit.Rd`, and any other existing Rd file changed by the final
  roxygen synchronization pass.
- Track new regression tests that protect the current public boundary:
  `tests/testthat/test-compatibility-aliases.R`,
  `tests/testthat/test-diagnostic-screening-validation.R`,
  `tests/testthat/test-gpcm-capability-matrix.R`,
  `tests/testthat/test-marginal-fit-diagnostics.R`,
  `tests/testthat/test-marginal-fit-plots.R`,
  `tests/testthat/test-misfit-casebook.R`,
  `tests/testthat/test-mml-cpp11-backend.R`,
  `tests/testthat/test-summary-table-bundle.R`,
  `tests/testthat/test-visual-reporting-template.R`, and
  `tests/testthat/test-weighting-audit.R`.
- Track the new vignette source, not generated outputs:
  `vignettes/mfrmr-mml-and-marginal-fit.Rmd`.
- Do not track generated native build artifacts:
  `src/cpp11.o`, `src/mml_backend.o`, `src/mfrmr.so`, and
  `src/symbols.rds`.
- Preserve `build/vignette.rds` in release source tarballs; excluding the whole
  `build/` directory causes a CRAN incoming note about a missing prebuilt
  vignette index. `R CMD build` regenerated this file from a source copy that
  excluded the local `build/` directory, so Git can continue ignoring `build/`.
- Do not track generated vignette or site outputs in the package release
  branch: `vignettes/*.R`, `vignettes/*.html`, `vignettes/.install_extras`,
  and `docs/`.
- Do not track local system detritus such as `tests/.DS_Store`.
- Decide separately whether to track internal planning files in
  `inst/references/` for repository history. They are excluded from the CRAN
  source tarball by `.Rbuildignore`, so tracking them in Git is acceptable only
  as repository-internal documentation; they should not be presented as
  installed-package user documentation.
- Re-run this classification from a clean branch before public release because
  the current working tree contains many unrelated modified and untracked files.

### Public GitHub preview gates

- [ ] Decide the tracked source set on a clean branch.
- [ ] Add source files required for reproducible installation, especially
      `R/cpp11.R`, `R/help_gpcm_scope.R`, `R/utils-method-labels.R`,
      `src/cpp11.cpp`, and `src/mml_backend.cpp` if the cpp11 backend and
      GPCM capability matrix remain part of the package.
- [ ] Add the matching new Rd pages, regression tests, and
      `vignettes/mfrmr-mml-and-marginal-fit.Rmd`; do not add generated
      vignette `.R`/`.html` files.
- [ ] Keep generated native-code artifacts out of the release:
      `src/*.o`, `src/*.so`, `src/*.dll`, `src/*.dylib`, and
      `src/symbols.rds`. Local ignore/build-ignore rules have been added and
      checked, but this should be rechecked on the final release branch.
- [ ] Keep generated pkgdown and vignette artifacts out of the release unless
      deliberately publishing a separate site branch:
      `docs/`, `vignettes/*.html`, `vignettes/*.R`, and
      `vignettes/.install_extras`. Do not exclude `build/vignette.rds` from the
      source tarball. Local ignore/build-ignore rules have been added and
      checked, but this should be rechecked on the final release branch.
- [ ] Re-run `git status --short` and separate package-source changes from
      unrelated workspace files outside the package directory.
- [ ] Re-run `R CMD build` and `R CMD check --no-manual` from a temporary
      directory after the tracked-source set is finalized.
- [ ] Re-run at least one clean install from the Git branch, not only from the
      current working tree.

### CRAN or stable release gates

- [ ] Re-run `R CMD check --as-cran` on a clean source tarball. A local
      temporary-tarball run now reaches `Status: 1 WARNING, 1 NOTE`; repeat
      after the final tracked-source set is isolated.
- [ ] Re-run checks on macOS, Windows, and Linux.
- [ ] Finalize `cran-comments.md` with win-builder and cross-platform CI
      results. The file has been updated from the old 0.1.4 resubmission text
      to the current 0.1.5 local-check status, but external checks still need
      to be added before submission.
- [ ] Confirm `NEWS.md` is release-facing and does not read like an internal
      development log.
- [ ] Confirm `DESCRIPTION` reflects only supported user-facing claims.
- [ ] Confirm README language does not imply full FACETS, ConQuest, SPSS, TAM,
      sirt, or mirt numerical equivalence.
- [ ] Confirm all new public helpers are intentionally exported and covered by
      namespace-contract tests.
- [ ] Confirm generated Rd files are synchronized with roxygen comments.
- [ ] Confirm vignettes build from source and do not depend on local generated
      HTML files.
- [ ] If CRAN is the target, run reverse spell/URL/time checks and update
      CRAN-specific skip policy only after the clean branch check is green.

## Non-blocking but important follow-up

- Add true external ConQuest validation when the software is available.
- Add a longer latent-regression vignette with continuous and categorical
  covariates, omission policy, posterior scoring, and ConQuest non-parity
  wording.
- Add plot-interpretation examples for latent-regression outputs after the
  model contract is benchmarked more broadly.
- Continue refining beginner-facing output paths through `summary(fit)`,
  `summary(diagnose_mfrm(...))`, `reporting_checklist()`,
  `build_summary_table_bundle()`, and safe first plot calls.

## Stop rule

Do not label the current state as ready for CRAN submission or stable until:

1. the tracked source tree is clean except for intended release files;
2. required cpp11 source files are tracked and generated artifacts are ignored;
3. a clean source tarball check passes outside the working Dropbox tree;
4. `cran-comments.md`, README, NEWS, and DESCRIPTION are synchronized with the
   current 0.1.5 scope;
5. the remaining warning, if present, is confirmed to be environment/compiler
   related and not package-specific.
