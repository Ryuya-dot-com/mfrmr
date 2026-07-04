# Convergence-reporting stress review status (0.2.2)

This curated status artifact connects
`convergence-reporting-stress-0.2.2.R` to the 0.2.2 release evidence gate.
The helper is intentionally outside CRAN-time tests and ordinary
release-readiness review. It is available for local stress review of
`fit_mfrm()` convergence-reporting fields, but the readiness gate reads this
status file and the script text only; it does not source the script or run
fits.

- `ConvergenceReportingStressStatus = "available"`;
- `ReadinessGate = "presence_status"`;
- `CRANTimeSimulation = FALSE`;
- `DefaultOutputDir = validation-results/convergence-reporting-stress-0.2.2`;
- `RequiredContractChecks = listed below`.

## Required contract checks

- `all_runs_completed`
- `direct_iterations_are_function_evaluations`
- `bfgs_iterations_mirror_gradient_evaluations`
- `bfgs_iterations_do_not_exceed_maxit`
- `function_evaluations_can_exceed_maxit_observed`
- `large_gradient_plateau_mapping`
- `large_gradient_status_is_well_formed`
- `pass_direct_rows_have_small_terminal_gradient`
- `iteration_limit_stress_observed`
- `em_basis_rows_remain_distinct`

## Gate boundary

The status gate verifies that the optional stress helper is present, keeps
generated outputs under `validation-results/`, names the convergence-reporting
contract checks, and documents the CRAN-time boundary. It does not treat a
short smoke run as curated Monte Carlo evidence.

## Optional run command

```sh
Rscript inst/validation/convergence-reporting-stress-0.2.2.R [reps] [out_dir]
```

Use an explicit `out_dir` only when preserving generated CSVs for a future
release review. Otherwise the default path keeps ad hoc runs separate from
bundled fixed evidence.

## Output files

- `convergence-reporting-stress-0.2.2-runs.csv`
- `convergence-reporting-stress-0.2.2-checks.csv`
- `convergence-reporting-stress-0.2.2-summary.csv`
- `convergence-reporting-stress-0.2.2.md`
