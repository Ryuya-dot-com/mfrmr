# Contributing to mfrmr

Thanks for helping improve `mfrmr`.

## Before you start

- Search existing issues and pull requests first.
- If behavior changes are large, open an issue before implementation.
- Keep changes focused and reviewable.

## Development setup

``` r

# from package root
install.packages(c("devtools", "roxygen2", "testthat"))
devtools::document()
devtools::check(args = c("--no-manual"), document = FALSE)
```

To try a development checkout, start a fresh R session in its package
root:

``` r

pkgload::load_all(".", export_all = FALSE)
getNamespaceInfo(asNamespace("mfrmr"), "path")
```

The returned path should identify that checkout. Use a complete checkout
or install a complete source archive; copying selected R files can omit
internal helpers even when the public function is present. A version
number alone does not distinguish development copies with the same
package version. If a helper is missing, verify the source files and
loaded namespace path before refitting.

## Source control and retained evidence

Use a separate Git checkout on each computer, outside file-sync folders.
Exchange source changes as commits. A synced `.git` directory can mix a
newer branch reference with an older index or worktree.

Keep maintainer instructions, internal roadmaps and large generated
study outputs out of Git. `.gitignore` does not untrack files already
committed, and `.Rbuildignore` controls the package archive rather than
repository visibility. Removing a file from current tracking does not
erase it from earlier commits.

Research runners and small synthetic regression fixtures remain
versioned. Historical validation records can refer to locally retained
output bundles that are not distributed in a fresh checkout. Restore the
matching private evidence to its recorded relative paths before replay,
preserving source, input and environment identity. Evidence-dependent
checks report a skip when these files are absent; that skip is not
evidence that the numerical validation passed. Ordinary package tests
and hosted checks must not require private roadmaps.

Before publishing source or documentation, run
`Rscript scripts/check-publication-boundary.R` from the repository root.
It checks tracked and new non-ignored files, private references in
user-facing sources and installed text, and version metadata against the
recorded public release. It also checks research text and manifests for
personal-machine paths, and research prose for references to private
plans. Development sources omit release dates from DESCRIPTION and
CITATION.cff. Run this check locally before staging and pushing; the
package-check and website workflows repeat it after the source has
reached GitHub. Research protocols still need editorial review:
numerical conditions, counterexamples and source identities belong in
public evidence, while personal instructions, approval exchanges and
current work queues belong in local records. A dated research protocol
is not a current release checklist.

For external programs such as FACETS, transfer a completed input bundle,
run it in a local directory, and return a completed output bundle.
Record the source commit, program version, settings, stopping status and
input/output checksums. Verify the received bundle before comparing
results; avoid running against files still being synchronized.

## Building from a checkout with retained research results

Stage the package files before building this research-heavy checkout.
`R CMD build` first copies the source tree, following directory links,
and only then applies `.Rbuildignore`. Excluded `validation-results/`
links can therefore break that initial copy. Do not remove retained
research results to fix it.

From the package root:

``` sh
mfrmr_stage_root=$(mktemp -d "${TMPDIR:-/tmp}/mfrmr-source.XXXXXX")
Rscript --vanilla scripts/stage-package.R "$mfrmr_stage_root/mfrmr"
NOT_CRAN=true R_BUILD_TAR=internal R CMD build "$mfrmr_stage_root/mfrmr"
```

The helper prunes excluded directories before traversal, using the
running R version’s `tools` build-ignore rules, and verifies the copied
file bytes. It then removes duplicated roxygen comments from the staged
R files: their generated help remains in `man/`, and the editable
roxygen source remains in the checkout. Parsed R expressions must match
exactly before and after this step. Blank lines preserve line numbers;
ordinary implementation comments and license notices remain. The helper
requires a new destination outside the checkout and refuses an existing
one. The normal build still applies its remaining exclusions and
transformations. This avoids copying research artifacts; it does not
skip required package checks, examples or vignette execution.

The package includes five core tutorials: workflow, model choice, G
theory, visual diagnostics and reporting. Specialized guides and the
interactive gallery live in `vignettes/articles/` and are built by
pkgdown. Keep their published article names stable. When linking from an
installed tutorial to a website-only article, use its full website URL
rather than [`vignette()`](https://rdrr.io/r/utils/vignette.html) or a
local HTML path. All specialized calculations remain part of the
evaluated website build.

Keep each reference page focused on its question, minimal runnable use,
arguments, output and essential interpretation limits. Link detailed
comparisons, derivations and extended tutorials instead of repeating
them. Core assumptions and unavailable states must remain understandable
offline. Use rendered pkgdown pages for learning links; use GitHub links
for source, issues and reproducible evidence. Relative repository paths
in README can fail CRAN’s installed-file URL check, so use a verified
absolute source URL where a source link is intended. The website uses
`development.mode: auto`: released documentation stays at the site root
and development documentation is built under `dev/`. Check version
labels and links before deployment. Prepare development article links
together with their matching `dev/` pages, and verify deployment before
announcing those URLs as available. Until then, use the checkout’s
installed help and local article preview. When preparing a release, move
article links to the release site together with its documentation and
verify content and version labels; HTTP success alone is not a version
match.

`NOT_CRAN=true` evaluates the worked tutorials for distribution,
including the G-theory article. Ordinary CRAN checks leave their long
calculations unevaluated; the distributed HTML retains the evaluated
tables and figures. The website workflow uses the same evaluation
setting. Tutorials use SVG line graphics when the optional `svglite`
package is available, with PNG as a fallback. Install `svglite` for
compact distribution builds; figures, text and analysis settings are
otherwise retained. Review the rendered figures after a graphics-device
change.

Inspect build warnings even when the command exits successfully. Before
using an archive, verify its expected file list and source contents,
then install the archive in a fresh library. Missing-file warnings are a
failed build, not a usable candidate. If using an external tar program
via `R_BUILD_TAR`, follow the [R build
documentation](https://stat.ethz.ch/R-manual/R-devel/library/utils/html/PkgUtils.html)
and verify extraction explicitly with
`utils::untar(..., tar = "internal")`; the standalone
[`untar()`](https://rdrr.io/r/utils/untar.html) default may use an
external unpacker instead. The internal build method avoids macOS
extended-attribute records that the internal installer may reject. An
external tar’s successful build or extraction is not sufficient evidence
of portability.

Before recompressing saved files, inspect their checksum relationships.
Exported posterior summaries refer to the exact `model-data.rds` bytes;
equal R values do not preserve that identity. Keep these model files
unchanged and exercise the public readers for every affected saved-data
family from the built package.

## Coding guidelines

- Prefer readable, explicit code over compact but opaque code.
- Keep public API names descriptive.
- For user-facing behavior changes, update docs and examples in the same
  PR.
- Use the existing `ggplot2` plotting helpers and shared theme. Public
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods
  return `ggplot` objects; expose numerical payloads through
  [`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md).

## Testing expectations

Before a release containing Bayesian export, posterior or scoring
changes, run
`Rscript --vanilla scripts/check-stan-live.R PATH_TO_NEW_EVIDENCE_DIRECTORY`
with CmdStanR, CmdStan and a working C++ toolchain installed. This is a
required release check, separate from the ordinary and full package
suites: it refuses missing dependencies and any skipped test, and
records the Git revision, actual source hashes (including uncommitted
changes), software versions and test counts. Retain its console log
alongside the receipt. The evidence applies only to the recorded
sources; rerun when those Bayesian paths change. Short chains test
execution and data transfer, not posterior calibration or coverage.

Install CmdStanR from the repository declared in `DESCRIPTION`,
following the [official installation
instructions](https://mc-stan.org/cmdstanr/articles/cmdstanr.html).
CmdStan is a separate installation; installing the R package alone does
not enable the live tests. Ordinary tests may skip absent optional
tools, and a successful full suite with such skips does not satisfy the
live release check.

- Add or update tests for every user-visible change.
- Keep tests deterministic (fixed seeds, no network calls).
- Avoid writing plot files during tests (use `draw = FALSE` unless
  plotting is under test).
- Use `on.exit(..., add = TRUE)` or
  [`withr::defer()`](https://withr.r-lib.org/reference/defer.html) for
  cleanup. Replacing exit handlers can discard mock or option
  restoration and contaminate later tests, even when the test that
  changed the state passes in isolation.
- Mock only mfrmr’s own bindings. Import a required dependency function
  or wrap an optional backend locally, then use
  `local_mocked_bindings(.package = "mfrmr")`. Follow [testthat’s
  dependency-mocking
  guidance](https://testthat.r-lib.org/reference/local_mocked_bindings.html)
  and the [CRAN namespace
  policy](https://cran.r-project.org/web/packages/policies.html): do not
  replace another package’s functions or standard S3 methods. Graphics
  observers should check the arguments mfrmr sends to the drawing
  functions; use a positive assertion to ensure the observer actually
  sees the call.

## Documentation expectations

- Update roxygen comments when function arguments/returns change.
- Run `devtools::document()` before committing.
- Do not pass a partial topic set to `roclet_output()` in the package
  directory: its default cleanup deletes other generated help files. Use
  normal package documentation generation or an isolated output
  directory for a partial set. A shared topic also needs every
  contributing source file: isolated output prevents deletion of other
  topics, but does not preserve omitted method aliases or usages within
  the generated topic.
- If workflow changes, update README and/or vignette accordingly.

Use `fig.alt` for article figures. Reference-example figures receive
their descriptions through pkgdown’s documented
`pkgdown/post-reference.R` hook, because pkgdown does not currently
offer an example-plot alt-text option. Review the descriptions against
the actual figures when changing examples; keep axes, uncertainty and
diagnostic limitations accurate. Optional plots must retain the correct
description sequence with or without their dependency. The hook
preserves existing descriptions and stops on an unrecognized empty
example-image description instead of guessing. It runs automatically
during `pkgdown::build_reference(examples = TRUE)` and normal site
builds, without changing plot images or adding visible titles or
captions.

Run `Rscript --vanilla scripts/check-reference-alt.R` after changing the
hook, then build the affected reference topics with examples enabled.
This scoped HTML check does not replace review of the figures or
screen-reader testing.

The interactive gallery is a website-only article in
`vignettes/articles/`; its Plotly dependencies are declared in
`Config/Needs/website`. With the matching package installed, run
`Rscript --vanilla scripts/render-visual-gallery.R` from the package
root to regenerate the README preview from that article’s code. Then use
`pkgdown::build_article("articles/visual-gallery")` to check the page.
Verify labels, interval endpoints and underlying values after
conversion, and retain the static figures and tables. A successful HTML
build does not replace checking browser interactions and the deployed
site’s assets.

## Selecting a regression run

After installing the same source, run from the package checkout with the
desired library in `R_LIBS`:

``` sh
Rscript scripts/run-regression.R . cran ../validation-cran
Rscript scripts/run-regression.R . extended ../validation-extended
Rscript scripts/run-regression.R . reference ../validation-reference
Rscript scripts/run-regression.R . all ../validation-all
```

`cran` uses the representative selection in `tests/testthat.R`.
`extended` executes that selection and the listed detailed files with
`NOT_CRAN=true`, restoring full numerical grids and propagation cases.
`all` runs the complete test directory, including supplementary help
examples and repository-only checks; some repository checks require
retained external evidence. Review skips and warnings separately from
failures. The runner saves per-test results and session information and
returns a nonzero status for failures or errors.
`scripts/cran-test-selection.json` records why cases move to extended
checking. Choose the run from the changed behavior and applicable saved
evidence.

`reference` runs the repository-only numerical reference tests listed in
`reference_tests` in `tests/testthat.R`. Their implementations live in
`inst/validation/reference-code/`, outside the installed runtime
namespace. The unfiltered repository `all` run includes these tests, and
an explicit full CI run executes them against the package installed by
its completed check. They retain the independent reference calculations
and numerical tolerances; they are not part of the ordinary CRAN test
selection. When a file mixes runtime and reference tests, keep the
runtime blocks in the package and share only the fixture definitions
needed by both modes. To inspect or run a reference implementation
directly from a matching checkout:

``` r

source("scripts/load-research-code.R")
reference <- load_mfrmr_research_code(".")
ls(reference)
```

The returned environment resolves runtime helpers from the installed
mfrmr namespace without changing that namespace. Historical research
drivers with frozen source hashes must continue to use their recorded
source/library; moving current reference code does not update or
requalify past results.

## Examples and timing policy

The [CRAN policy](https://cran.r-project.org/web/packages/policies.html)
asks for examples lasting a few seconds each and minimal check CPU time.
Long tests or vignette calculations may be optional, provided the
remaining checks exercise all package features. Keep Rd examples useful
and short on slower Windows check hosts; retain substantial analyses in
tutorials and the complete test suite. The [CRAN
Cookbook](https://contributor.r-project.org/cran-cookbook/docs_issues.html#overall-checktime)
also documents an `Overall checktime` NOTE above ten minutes. This is a
submission-review criterion, not an automatic ten-minute process
timeout.

- Classify the example’s purpose before changing its workload. Keep a
  short executable route where it is useful. Put long estimation,
  simulation and repeated-inference workflows in `\dontrun{}` with an
  explicit reason and retain their original data, precision and complete
  runnable code. For [`summary()`](https://rdrr.io/r/base/summary.html),
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) and other
  consumers of simulation results, read a packaged synthetic result and
  execute the consumer. The simulation consumer examples use
  `inst/examples/simulation-*.rds` (one result per file);
  `simulation-results.R` contains the complete regeneration recipe. Keep
  settings, warnings and failed runs in the saved object, and explain
  that a one-replication example illustrates structure, not simulation
  precision.

- Ordinary table, plot and report examples reuse fitted inputs and
  matching diagnostics from `inst/examples/*-jml.rds` and
  `operational-mml*.rds`. `inst/examples/ordinary-fits.R` gives their
  complete regeneration recipe. Each example loads its own input, so
  [`example()`](https://rdrr.io/r/utils/example.html) works in a fresh
  session without a previously executed example or a hidden package-wide
  fit cache. Label these as saved synthetic analyses; do not load an
  unused ratings table that appears to drive the analysis. Derive any
  needed data or labels from that same saved analysis. Keep complete
  data-to-result code so users can replace the input data; mark lengthy
  workflows for explicit execution rather than shrinking their data or
  weakening estimation settings to meet a timing target. The full
  `NOT_CRAN=true` suite regenerates the ordinary fitted inputs and
  compares estimates and diagnostics; ordinary checks verify reuse
  without refitting. Update the saved inputs when their calculations
  change.

- The ordinary test profile selects the end-to-end public workflow and
  short numerical/contract files; `tests/testthat.R` is the
  authoritative selection. `population-identification` checks the
  conditional RSM/PCM design certificate, mixed singleton rosters,
  unsupported cases and preservation of inference restrictions.
  `cran-smoke` retains live RSM/PCM and adaptive GPCM estimation,
  diagnostics, summaries, plots and exports. Independent
  likelihood/backend checks, CML, corrected JML, two-family GPCM,
  random-rater/testlet fitting, calibration, G/D studies and agreement
  checks remain. The `posterior-summary` reader, report, plot and
  checksum regressions are mandatory, including rejection of a changed
  file whose loaded values are identical. Detailed refitting,
  failure/restart grids and propagation combinations run with
  `NOT_CRAN=true`; the extended selection also includes files moved out
  of the ordinary run. Their original data, assertions and tolerances
  remain. A per-file timing budget helps choose representative checks;
  it is not a timeout and must not silently skip a test on a slower
  platform. Reducing routine test work is not evidence of faster model
  estimation. Argument-routing checks retain live ordinary MML/JML,
  Jeffreys and comparison-only fits, plus invalid-input guards, on CRAN.
  Repeated flat versus structured calls for corrected JML, GPCM MML and
  CML run in full mode; their engine-specific numerical checks still run
  on CRAN. Simulation plot-dispatch tests use bundled results on CRAN
  and regenerate their original simulations in full mode. See
  `scripts/cran-test-selection.json` for the exact cases.

- Use `example_operational` for applied tutorials, `example_core` for
  idealized fast checks, and `example_bias` only when a planted non-null
  DFF/bias signal is needed.

- Begin ordinary user examples by loading suitable packaged data. Prefer
  descriptive object names such as `ratings`, explain what one row
  represents, and show which returned table answers the question. Use
  the packaged G-theory and agreement teaching data for those distinct
  input structures. Keep manual construction when the construction or a
  particular edge case is the lesson; do not make simulation code a
  prerequisite for learning an analysis function.

- Match the estimator and population assumptions to the example’s
  question. Do not substitute JML for MML, truncate optimization, or
  lower integration accuracy solely to shorten a check. Omit diagnostics
  that do not illustrate the documented function, such as optional
  residual PCA.

- Time ordinary examples and any `\donttest{}` examples. As documented
  in [R
  Internals](https://cran.r-project.org/doc/manuals/r-release/R-ints.html#Tools),
  `R CMD check --as-cran` normally runs examples once without `donttest`
  code and again with it. Do not add this wrapper merely to hide
  expensive code: even the ordinary examples can then run twice. Keep
  short complete examples unwrapped; retain long workflows in help as
  explicitly runnable examples and in relevant tutorials. Explain each
  wrapper. Guard optional Suggests with
  [`requireNamespace()`](https://rdrr.io/r/base/ns-load.html) or the
  relevant feature check, rather than relying on `\donttest{}` to avoid
  the dependency.

- Use `\dontrun{}` for measured long workflows, optional heavyweight
  integrations and external-software examples. Give the reason and an
  explicit `example("topic", run.dontrun = TRUE)` command. This keeps
  the complete code visible without altering its analysis settings.
  Writing R Extensions [documents this display-only
  mechanism](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Documenting-functions);
  brms uses it for its estimation examples. It is not limited to
  examples that are impossible to run. Reserve
  `@examplesIf interactive()` for functions that actually require
  interaction. Do not hide an error behind a wrapper.

- Keep complete supplementary examples in their own help topics. Mark
  them with a reason and `example("topic", run.dontrun = TRUE)` when
  their routine execution duplicates representative workflows.
  `inst/examples/execution-policy.csv` records these choices and the
  primary examples that remain automatic. A `mixed` entry runs the short
  primary example normally and retains optional supplementary
  calculations in a reasoned `\dontrun{}` block on the same page.
  Existing non-executed examples keep their original opt-in status;
  relocating them cannot reduce the ordinary numerical workload. Avoid
  separate copies of the same example code in `inst/examples/manual/`.
  The full regression reads and runs the installed help through
  [`utils::example()`](https://rdrr.io/r/utils/example.html), including
  its output.

- For a measured long calculation, a commented recomputation call may
  accompany an executable example that reads and uses its saved
  synthetic result. Include the complete regeneration recipe, preserve
  its data and numerical settings, and check that the saved objects
  match and replay without refitting. A replay check does not replace
  numerical tests of the estimator. Prefer a complete `\dontrun{}` block
  to commenting out every line of a long workflow. Check optional
  examples explicitly when their code or dependencies change, reusing
  matching successful execution logs when only their wrapper changes; do
  not advertise an unexecuted recipe as a fresh validation.

- Check that the retained example’s optimization and integration
  controls support its stated purpose. Show the model’s numerical checks
  where relevant; no quadrature order is a universally sufficient
  accuracy setting.

- Use `draw = FALSE` in examples that only need to demonstrate returned
  plot payloads.

- Do not shrink example data below a meaningful many-facet structure
  just to satisfy CRAN timing. Reduce what CRAN executes; keep realistic
  examples in vignettes and in the full packaged `NOT_CRAN=true` test
  run.

- Choose verification from the changed behavior and its callers. Use
  focused regressions for bounded fixes and reuse unaffected results. Do
  not repeat the complete test suite for each small fix, documentation
  edit, or result record.

- In tests that vary only output transformations, compute an unchanged
  fit’s joint information or likelihood derivatives once per test. Guard
  reuse with exact fit and numerical-setting comparisons, and restore
  bindings afterward. Keep the independent derivative/covariance checks
  and tests of changed fits, information budgets and integration
  settings; avoid a suite-wide cache that could conceal stale results.
  Measure affected files separately from a complete package check. In
  tests comparing flat and structured arguments, the ordinary CRAN run
  may similarly reuse a successful numerical solution only after exact
  prepared input, numerical-control and evaluator comparisons. Both
  public calls must still validate their inputs; `NOT_CRAN=true` must
  retain separate fits.

- Ordinary checks run the selected tests serially in one session, with
  numerical library threads limited to one. This avoids worker startup
  and repeated dependency loading for short files. The complete
  `NOT_CRAN=true` suite keeps its existing scheduling policy. Compare
  timings and results in the intended environment rather than assuming
  parallel execution is always faster.

- CRAN-time `testthat` and ordinary push/PR CI run the representative
  workflow and selected contracts from `tests/testthat.R`. For broad
  changes or a batched release review, explicitly enable `full_suite`
  when manually running `R-CMD-check`; only Ubuntu release then uses
  `NOT_CRAN=true`. Record the reason and source revision for a full run.
  Historical full-suite evidence remains tied to its original source and
  must not be relabelled as a new run. Package checks have no
  repository-defined time limit; GitHub-hosted runner limits still
  apply. If an external limit interrupts a run, preserve completed
  results and rerun only unfinished phases against the same source
  archive. Do not restart successful numerical tests merely to change a
  timeout setting.

- Within selected files, long reference integrations, repeated profile
  fits and optimizer-failure combinations use `skip_on_cran()`. Ordinary
  tests retain live models, numerical kernels, short boundary cases and
  public output paths. `NOT_CRAN=true` restores every retained scenario,
  original sample size, quadrature order and tolerance. Review the
  selection notes in `scripts/cran-test-selection.json` when changing
  either path.

- Source-tree-only historical and research validation tests are excluded
  from the package. Run them only for the affected area, with their
  recorded source version and optional runtime.

- Before release, run an `--as-cran` check with timing enabled and
  ensure the ordinary and any `donttest` examples execute. Follow
  [Writing R Extensions: Check
  timing](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Check-timing):
  set `_R_CHECK_TIMINGS_=0`, use `--timings`, and inspect the per-topic
  `mfrmr-Ex.timings` file. Record the time spent on static analysis,
  examples, tests, vignette rebuilding and other check steps; report
  dependency setup, build and installation separately. Preserve actual
  skips and unfinished steps. A focused check and the exhaustive
  `NOT_CRAN=true` regression job provide different evidence.

- `devtools::check()` defaults to `env_vars = c(NOT_CRAN = "true")`,
  which runs the full **packaged** suite. To time the ordinary CRAN
  selection, set `env_vars = c(NOT_CRAN = "false")`. This alone does not
  reproduce win-builder: devtools also defaults to omitting the PDF
  manual, remote incoming checks and strict Suggests availability. For a
  staged source archive, use:

  ``` r

  devtools::check_built("mfrmr_0.2.4.tar.gz", cran = TRUE,
    env_vars = c(NOT_CRAN = "false"), args = "--timings",
    manual = TRUE, remote = TRUE, force_suggests = TRUE)
  ```

  See the [devtools check
  reference](https://devtools.r-lib.org/reference/check). Record R, OS
  and dependency versions; local timing is not a Windows result.

- When reusing executed articles with `--no-build-vignettes`, retain
  their `build/vignette.rds` index as well as `inst/doc`. Verify that
  its source, output and extracted R filenames match the current
  packaged articles; copying the HTML alone does not produce a complete
  vignette distribution. For byte-identical sources restored by a
  checkout, retain their matching source timestamps: a newer Rmd
  timestamp than its reused output raises a check warning. Do not change
  dates to conceal an actual source change.

- Packaged teaching data use R’s lazy-data database. Access them through
  [`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/load_mfrmr_data.md)
  or `mfrmr::dataset_name` to reuse loaded objects;
  [`data()`](https://rdrr.io/r/utils/data.html) remains available.
  Measure data-loading cost before adding another cache. The [data
  guidance](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Data-in-packages)
  recommends comparing compression choices for large databases; smaller
  files alone do not establish faster loading. Preserve values,
  attributes and independent user edits when changing the access path.

## Pull request checklist

Code and docs updated together

Checks appropriate to the changed behavior pass; any broader rerun has a
stated reason

Relevant source-tree-only validation tests pass when changed

NEWS entry updated when behavior changes materially

## Reporting bugs

Please include:

- minimal reproducible example,
- session info
  ([`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html)),
- expected vs observed behavior,
- relevant data schema (without sensitive content).
