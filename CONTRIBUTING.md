# Contributing to `mfrmr`

Thanks for helping improve `mfrmr`.

## Before you start

- Search existing issues and pull requests first.
- If behavior changes are large, open an issue before implementation.
- Keep changes focused and reviewable.

## Development setup

```r
# from package root
install.packages(c("devtools", "roxygen2", "testthat"))
devtools::document()
devtools::check(args = c("--no-manual"), document = FALSE)
```

## Building from a checkout with retained research results

Stage the package files before building this research-heavy checkout. `R CMD
build` first copies the source tree, following directory links, and only then
applies `.Rbuildignore`. Excluded `validation-results/` links can therefore
break that initial copy. Do not remove retained research results to fix it.

From the package root:

```sh
mfrmr_stage_root=$(mktemp -d "${TMPDIR:-/tmp}/mfrmr-source.XXXXXX")
Rscript --vanilla scripts/stage-package.R "$mfrmr_stage_root/mfrmr"
R CMD build "$mfrmr_stage_root/mfrmr"
```

The helper prunes excluded directories before traversal, using the running R
version's `tools` build-ignore rules, and verifies the copied file bytes. It
requires a new destination outside the checkout and refuses an existing one.
The normal build still applies its remaining exclusions and transformations.
This avoids copying research artifacts; it does not skip required package
checks, examples or vignette execution.

## Coding guidelines

- Prefer readable, explicit code over compact but opaque code.
- Keep public API names descriptive.
- For user-facing behavior changes, update docs and examples in the same PR.
- Use base R plotting defaults in this package unless there is a strong reason not to.

## Testing expectations

- Add or update tests for every user-visible change.
- Keep tests deterministic (fixed seeds, no network calls).
- Avoid writing plot files during tests (use `draw = FALSE` unless plotting is under test).
- Use `on.exit(..., add = TRUE)` or `withr::defer()` for cleanup. Replacing exit
  handlers can discard mock or option restoration and contaminate later tests,
  even when the test that changed the state passes in isolation.

## Documentation expectations

- Update roxygen comments when function arguments/returns change.
- Run `devtools::document()` before committing.
- Do not pass a partial topic set to `roclet_output()` in the package directory:
  its default cleanup deletes other generated help files. Use normal package
  documentation generation or an isolated output directory for a partial set.
  A shared topic also needs every contributing source file: isolated output
  prevents deletion of other topics, but does not preserve omitted method
  aliases or usages within the generated topic.
- If workflow changes, update README and/or vignette accordingly.

Use `fig.alt` for article figures. Reference-example figures receive their
descriptions through pkgdown's documented `pkgdown/post-reference.R` hook,
because pkgdown does not currently offer an example-plot alt-text option.
Review the descriptions against the actual figures when changing examples;
keep axes, uncertainty and diagnostic limitations accurate. Optional plots
must retain the correct description sequence with or without their dependency.
The hook preserves existing descriptions and stops on an unrecognized empty
example-image description instead of guessing. It runs automatically during
`pkgdown::build_reference(examples = TRUE)` and normal site builds, without
changing plot images or adding visible titles or captions.

Run `Rscript --vanilla scripts/check-reference-alt.R` after changing the hook,
then build the affected reference topics with examples enabled. This scoped
HTML check does not replace review of the figures or screen-reader testing.

## Examples and timing policy

The [CRAN policy](https://cran.r-project.org/web/packages/policies.html) asks for
examples lasting a few seconds each and minimal check CPU time. Long tests or
vignette calculations may be optional, provided the remaining checks exercise
all package features. Keep Rd examples useful and short on slower Windows check
hosts; retain substantial analyses in tutorials and the complete test suite.

- Classify the example's purpose before changing its workload. Keep generation,
  estimation and inference examples live. For `summary()`, `plot()` and other
  consumers of simulation results, read a packaged synthetic result and execute
  the consumer. The simulation consumer examples use
  `inst/examples/simulation-results.rds`; the adjacent `.R` file contains the
  complete regeneration recipe. Keep settings, warnings and failed runs in the
  saved object, and explain that a one-replication example illustrates structure,
  not simulation precision. The generator entry-point examples remain live.
- Use `example_operational` for applied tutorials, `example_core` for
  idealized fast checks, and `example_bias` only when a planted non-null
  DFF/bias signal is needed.
- Begin ordinary user examples by loading suitable packaged data. Prefer
  descriptive object names such as `ratings`, explain what one row represents,
  and show which returned table answers the question. Use the packaged G-theory
  and agreement teaching data for those distinct input structures. Keep manual
  construction when the construction or a particular edge case is the lesson;
  do not make simulation code a prerequisite for learning an analysis function.
- Match the estimator and population assumptions to the example's question.
  Do not substitute JML for MML, truncate optimization, or lower integration
  accuracy solely to shorten a check. Omit diagnostics that do not illustrate
  the documented function, such as optional residual PCA.
- Time ordinary examples and any `\donttest{}` examples. As documented in
  [R Internals](https://cran.r-project.org/doc/manuals/r-release/R-ints.html#Tools),
  `R CMD check --as-cran` normally runs examples once without `donttest` code
  and again with it. Do not add this wrapper merely to hide expensive code:
  even the ordinary examples can then run twice. Keep short complete examples
  unwrapped, and place longer
  multi-step analyses in executed vignettes. Explain any remaining wrapper.
  Guard optional Suggests with `requireNamespace()` or the relevant feature
  check, rather than relying on `\donttest{}` to avoid the dependency.
- Reserve `\dontrun{}` for examples that genuinely cannot execute during a
  check, such as workflows that require files produced by external software.
  Reserve `@examplesIf interactive()` for functions that genuinely require an
  interactive session.
- For a measured long calculation, a commented recomputation call may accompany
  an executable example that reads and uses its saved synthetic result. Include
  the complete regeneration recipe, preserve its data and numerical settings,
  and check that the saved objects match and replay without refitting. A replay
  check does not replace numerical tests of the estimator. Do not comment out
  the entire workflow or advertise an unexecuted recipe as a fresh validation.
- Check that the retained example's optimization and integration controls
  support its stated purpose. Show the model's numerical checks where relevant;
  no quadrature order is a universally sufficient accuracy setting.
- Use `draw = FALSE` in examples that only need to demonstrate returned plot
  payloads.
- Do not shrink example data below a meaningful many-facet structure just to
  satisfy CRAN timing. Reduce what CRAN executes; keep realistic examples in
  vignettes and in the full packaged `NOT_CRAN=true` test run.
- Choose verification from the changed behavior and its callers. Use focused
  regressions for bounded fixes and reuse unaffected results. Do not repeat the
  complete test suite for each small fix, documentation edit, or result record.
- In tests that vary only output transformations, compute an unchanged fit's
  joint information or likelihood derivatives once per test. Guard reuse with
  exact fit and numerical-setting comparisons, and restore bindings afterward.
  Keep the independent derivative/covariance checks and tests of changed fits,
  information budgets and integration settings; avoid a suite-wide cache that
  could conceal stale results. Measure affected files separately from a complete
  package check.
- CRAN-time `testthat` and ordinary push/PR CI run the representative workflow
  and selected contracts from `tests/testthat.R`. For broad changes or a batched
  release review, explicitly enable `full_suite` when manually running
  `R-CMD-check`; only Ubuntu release then uses `NOT_CRAN=true`. Record the
  reason and source revision for a full run. Historical full-suite evidence
  remains tied to its original source and must not be relabelled as a new run.
  Package checks have no repository-defined time limit; GitHub-hosted runner
  limits still apply. If an external limit interrupts a run, preserve completed
  results and rerun only unfinished phases against the same source archive.
  Do not restart successful numerical tests merely to change a timeout setting.
- Source-tree-only historical and research validation tests are excluded from
  the package. Run them only for the affected area, with their recorded source
  version and optional runtime.
- Before release, run an `--as-cran` check with timing enabled and ensure the
  ordinary and any `donttest` examples execute. Follow
  [Writing R Extensions: Check timing](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Check-timing):
  set `_R_CHECK_TIMINGS_=0`, use `--timings`, and inspect the per-topic
  `mfrmr-Ex.timings` file. Record the time spent on
  static analysis, examples, tests, vignette rebuilding and other check steps;
  report dependency setup, build and installation separately. Preserve actual
  skips and unfinished steps. A focused check and the exhaustive
  `NOT_CRAN=true` regression job provide different evidence.
- When reusing executed articles with `--no-build-vignettes`, retain their
  `build/vignette.rds` index as well as `inst/doc`. Verify that its source,
  output and extracted R filenames match the current packaged articles;
  copying the HTML alone does not produce a complete vignette distribution.
- Packaged teaching data use R's lazy-data database. Access them through
  `load_mfrmr_data()` or `mfrmr::dataset_name` to reuse loaded objects; `data()`
  remains available. Measure data-loading cost before adding another cache.
  The [data guidance](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Data-in-packages)
  recommends comparing compression choices for large databases; smaller files
  alone do not establish faster loading. Preserve values, attributes and
  independent user edits when changing the access path.

## Pull request checklist

- [ ] Code and docs updated together
- [ ] Checks appropriate to the changed behavior pass; any broader rerun has a stated reason
- [ ] Relevant source-tree-only validation tests pass when changed
- [ ] NEWS entry updated when behavior changes materially

## Reporting bugs

Please include:

- minimal reproducible example,
- session info (`sessionInfo()`),
- expected vs observed behavior,
- relevant data schema (without sensitive content).
