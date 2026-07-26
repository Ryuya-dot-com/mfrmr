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
devtools::test()
devtools::check(args = c("--no-manual"), document = FALSE)
```

## Coding guidelines

- Prefer readable, explicit code over compact but opaque code.
- Keep public API names descriptive.
- For user-facing behavior changes, update docs and examples in the same PR.
- Use base R plotting defaults in this package unless there is a strong reason not to.

## Testing expectations

- Add or update tests for every user-visible change.
- Keep tests deterministic (fixed seeds, no network calls).
- Avoid writing plot files during tests (use `draw = FALSE` unless plotting is under test).

## Documentation expectations

- Update roxygen comments when function arguments/returns change.
- Run `devtools::document()` before committing.
- If workflow changes, update README and/or vignette accordingly.

## Examples and timing policy

CRAN examples are fast executable illustrations, not the full validation suite. Keep Rd
examples short enough to run on slower Windows check hosts, and move realistic
multi-step analyses to README/vignettes or non-CRAN tests.

- Use `example_operational` for applied tutorials, `example_core` for
  idealized fast checks, and `example_bias` only when a planted non-null
  DFF/bias signal is needed.
- Prefer `method = "JML"`, `maxit = 30`, and
  `diagnose_mfrm(..., residual_pca = "none")` in standard Rd examples.
- Wrap multi-fit workflows, MML examples, recovery simulations, design
  simulations, external-Suggests examples, and long reporting pipelines in
  `\donttest{}` unless the function cannot be demonstrated otherwise.
- Reserve `\dontrun{}` for examples that genuinely cannot execute during a
  check, such as workflows that require files produced by external software.
  Reserve `@examplesIf interactive()` for functions that genuinely require an
  interactive session.
- When an MML example must run in standard examples, set a small
  `quad_points` value and explain that it is an exploratory speed setting.
- Use `draw = FALSE` in examples that only need to demonstrate returned plot
  payloads.
- Do not shrink example data below a meaningful many-facet structure just to
  satisfy CRAN timing. Reduce what CRAN executes; keep realistic examples in
  vignettes and in the full `NOT_CRAN=true` test run.
- CRAN-time `testthat` runs the representative MML-to-export workflow test and
  selected contracts from `tests/testthat.R`. Run the complete suite
  locally/CI with `NOT_CRAN=true`; one CI matrix job must always use that
  setting.
- Before release, run an `--as-cran` check with timing enabled and ensure the
  ordinary and `donttest` examples both execute. Treat an estimated component
  check time above 600 seconds as a release concern. Do not apply that CRAN
  threshold to the deliberately exhaustive `NOT_CRAN=true` regression job.

## Pull request checklist

- [ ] Code and docs updated together
- [ ] `devtools::test()` passes
- [ ] `devtools::check(args = c("--no-manual"), document = FALSE)` passes
- [ ] NEWS entry updated when behavior changes materially

## Reporting bugs

Please include:

- minimal reproducible example,
- session info (`sessionInfo()`),
- expected vs observed behavior,
- relevant data schema (without sensitive content).
