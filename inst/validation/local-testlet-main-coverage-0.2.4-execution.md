# Main coverage study: execution record

**Completed and reviewed, 2026-09-18.** All 1,200 datasets were attempted by
04:03:10 JST; final aggregation and its saved audit completed at 04:03:31.
There are 1,192 fit/reference-ready datasets, with eight native optimizer
stops retained as failures and two additional unresolved plug-in scoring
targets. All 201,600 assigned method/target rows remain in the results.
The [final results and development decision](local-testlet-main-coverage-0.2.4.md)
report availability, coverage comparisons and achieved precision. The frozen
source/input identities and final evidence hash were verified at review.
The launch and continuation details below describe the completed run; another
execution is not needed.

Started **2026-09-17 20:54:52 JST**, following explicit user authorization to
proceed to the main study. The [frozen protocol](local-testlet-main-coverage-0.2.4-protocol.md)
and 1,200-seed manifest are unchanged: four cells, 300 datasets per cell,
12 disjoint pairs plus every person, two methods, 201,600 assigned method/
target rows. Estimated serial runtime from the pilot is 7.62 hours; completion
time depends on the new data and numerical paths.

## Launch and observed startup

The R process was detached with standard Python `subprocess.Popen`, a new
session, closed standard input, and stdout/stderr appended to `run.log`.
R PID: **57250**; `caffeinate -i -w 57250` PID: **57251**. Both processes were
confirmed alive with parent PID 1 after the launching command exited. Idle
system sleep is inhibited while R runs; display sleep is unaffected.

All 1,200 generated datasets were checked and frozen by **20:54:55 JST**,
before the first fit. Checks cover exact seed regeneration, probabilities,
adjacent logits and local-effect ownership. A subsequent read-only check
confirmed all data and source hashes. At the startup observation around
20:56 JST, seven datasets were complete, all seven fit/reference gates passed,
and all 504 assigned method/target rows were available. No captured fitting
errors/warnings occurred in those completed records. This is a startup snapshot,
not a final success rate or coverage result. Interim coverage was not inspected.

## What was added and checked

The [runner](local-testlet-main-coverage-0.2.4.R) reuses the unchanged generator,
selected optimizer and explicit-target continuous-CDF scorer. Its new work is
the frozen-plan handoff, twelve-pair target assembly, saved-data generation,
stage checkpoints and final aggregation. The fitting/reference gate matches
the independent pilot. No production API, numerical kernel or protocol was
changed.

The shared aggregator now reads replication and pair counts from the manifest,
with the original pilot defaults preserved. The [main summary](local-testlet-main-coverage-0.2.4-summary.R)
adds the fixed-denominator audits, pointwise Monte Carlo intervals and achieved
precision flags. It runs automatically only after all 1,200 results exist.
Outputs remain in the ignored execution directory until final review; active
computation does not continually modify tracked evidence files.

One [bounded check](local-testlet-main-coverage-0.2.4-check.R), run with warnings
treated as errors, passed before launch. It used saved evidence to check all
40 status/target mappings, retained failure cases, missing/warning/perturbed
reference rejection, atomic checkpoint reuse and identity mismatch rejection.
All seven original aggregate tables were exactly reproduced in a temporary
directory. No fit, numerical scoring call, FairZ run, TAM comparison or full
package suite was repeated. This check is for wrapper changes; it is not
automatically repeated on each unchanged resume.

## Files, continuation and completion

All live files are under
`validation-results/local-testlet-main-coverage-20260917/`:

- `launch.json`, `run.log` and `run-lock/pid`: process identity and progress.
- `source-contract.rds` and `plan.rds`: pinned numerical/reporting sources,
  protocol/input identities, all 1,200 dataset hashes and session information.
- `cell-XX-rep-XXXX-data.rds`: latent values, uniforms, probabilities and scores.
- Separate `-fit.rds`, `-reference.rds`, `-oracle.rds`, `-plugin.rds` checkpoints
  and complete `-result.rds` records, including failed/unavailable cases.
- `execution-complete.rds`: all assigned datasets attempted and retained.
- `summary/`: final CSVs and portable evidence; `summary-complete.rds` appears
  only after the final audits pass.

RDS saves use a same-directory temporary file followed by atomic rename.
Checkpoint identities include the stage, dataset, frozen inputs and source
hashes. An existing completed stage is read even when it records a failure;
it is never retried to obtain a successful replacement. An interrupted,
uncheckpointed stage must run again; checkpoints do not save an optimizer's
in-memory state. A source/identity mismatch stops execution for investigation.

The directory lock prevents concurrent writers. If an external interruption
leaves a lock, inspect its recorded process before removing a stale lock.
Resume from the development repository root with the same command:

```sh
Rscript -e 'options(warn = 2); source("inst/validation/local-testlet-main-coverage-0.2.4.R"); run_testlet_main_coverage()'
```

The runner reuses all saved stages and results, then continues the fixed
manifest. Do not rerun the plan-freezing script or edit pinned sources while
this study is active. If execution is complete but reporting needs attention,
inspect its errors and saved evidence before running the summary separately.
Numerical failures stay in the assigned denominator; they do not trigger new
seeds, alternative controls, retries or extra replications.
