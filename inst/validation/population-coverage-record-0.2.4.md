# Estimated-population coverage: protocol and execution review

Date: 2026-09-10. Repository-only preflight; no coverage conclusion or
production-readiness change. The [protocol](population-coverage-protocol-0.2.4.md)
was written before the new datasets. This record retains outcomes and follow-up
without rewriting its original criteria.

## What this step establishes

The earlier full-information checks concerned numerical derivatives and SEs
at retained fitted vectors. The next question is whether population intervals
cover their targets across new samples. The protocol fixes eight conditions
(RSM/PCM, 80/320 Persons, 3/6 ratings), primary intercept/slope/log-variance
targets, and a secondary natural-variance Wald interval. Complete covariance
includes all structural nuisance parameters. The generator remains unchanged.

Ten thousand repetitions per cell are planned: 80,000 in total, with coverage
MCSE about .00218 at .95 and standardized-bias MCSE about .01 under regular
normal errors. No main-study dataset has been generated or fitted in this step.
Five separate preflight repetitions per cell check implementation and timing;
their coverage percentages cannot support calibration claims.

Production inference/scoring restrictions remain explicit. Diagnostic interval
availability depends on numerical computability, not on a policy flag which
currently excludes every estimated-population fit. Unavailable intervals remain
in attempted/assigned counts; computable numerical conflicts remain in coverage.
The exact-zero boundary and globally unidentified designs require separate
work and are not certified by a positive local information matrix here.

## Execution and retained follow-up

The first execution completed 40 distinct datasets. All 40 returned with native
convergence `pass`, unregularized q61/q121 covariance and computable intervals
for all four targets. None was eligible for production inference or scoring.
There were no fitting errors or warnings and no computable q61/q121 numerical
conflicts. All 32 cell/target summaries retain `preflight_only`; their five-trial
coverage estimates are not calibration evidence.

| Full-coordinate numerical diagnostic | Maximum across 40 fits | Prespecified bound |
| --- | ---: | ---: |
| q61/q121 objective difference | 3.848299e-11 | 1e-6 |
| Relative free-coordinate SE change | 3.464593e-10 | .001 |
| q121 Newton displacement in q61 SE units | 1.660532e-5 | .001 |
| q61 full gradient norm | 9.708140e-5 | 1e-4 |
| q121 full gradient norm | 9.708140e-5 | 1e-4 |

The untruncated natural-variance Wald interval had a negative lower limit in
four datasets: two RSM and two PCM cases, all with 80 Persons and three ratings.
The primary exponentiated log-variance intervals had finite positive endpoints
throughout. This confirms that the two interval constructions must be labelled
and retained separately; four examples do not establish a population frequency
or decide which interval has adequate coverage.

Reviewing the failure path found that a parameter/population consistency check
could run before finite estimates were retained when another coordinate or the
variance was nonfinite. The runner now stores estimates first and reports the
nonfinite/nonpositive-variance condition explicitly. Initial aggregation also
emitted eight row-name warnings; explicit row-name handling removes these
metadata warnings. No production R source, generator, numerical criterion or
statistical design changed.

The corrected runner repeated the SAME 40 datasets. Seeds, complete parameter
vectors, covariance matrices, estimates, SEs, interval bounds, readiness flags,
numerical metrics and original independent-check results were identical in all
40 replays. The new aggregation ran with warnings promoted to errors and emitted
none. These are 40 independent datasets with an execution replay, not 80 new
replications. Both source versions and their results remain archived.

## Independent derivative discrepancies and investigation

The original independent check used aggregate negative log likelihood and
relative central-difference steps 1e-4/5e-5 at replicate 1 of every cell. All
eight objective comparisons, native/reference gradient comparisons and full
stationarity checks met their bounds. The difference between the two reference
steps exceeded 1e-7 in three cells:

| Cell | Model | Persons | Ratings | Original gradient step difference |
| --- | --- | ---: | ---: | ---: |
| 4 | RSM | 320 | 6 | 1.909939e-7 |
| 7 | PCM | 320 | 3 | 1.335820e-7 |
| 8 | PCM | 320 | 6 | 3.035439e-7 |

Those three original failures remain failures under the original check. A
targeted, post-preflight diagnostic retained four steps: 1e-4, 5e-5, 2.5e-5 and
1.25e-5. Differences shrank below 1e-7 at the intermediate refinement, but cell
8 reached 1.045919e-7 at the smallest pair. That failure is retained too; finer
finite differences cannot be assumed to improve indefinitely.

The next diagnostic reused `population_review_logp()` from the identification
review. It integrates on the standardized latent scale and differences each
Person's log probability BEFORE summing, reducing cancellation between two
large aggregate likelihoods. The same three vectors were checked at fixed
relative steps 2.5e-5 and 1.25e-5, without refitting or changing any tolerance.

| Cell | Personwise step difference | Finest reference/native gradient difference | Finest full gradient norm |
| --- | ---: | ---: | ---: |
| 4 | 1.416645e-8 | 3.860624e-9 | 9.707954e-5 |
| 7 | 8.508749e-9 | 2.528203e-9 | 5.108877e-5 |
| 8 | 1.673328e-8 | 5.927959e-9 | 7.121029e-5 |

All six personwise gradient comparisons meet the unchanged agreement bound;
all three step comparisons and full-gradient checks also qualify. Their
objective differences are <=7.958079e-13. These results support reference
finite-difference/integration precision as the explanation for the observed
tiny discrepancies. They do not retroactively pass the original coarse-step
check or provide a general numerical certificate. The main run's q61/q121
diagnostics are unchanged; the personwise refinement is a separately archived
investigation, not a replacement statistical selection rule.

## Timing and the next execution step

The initial three-process execution took 90.9 seconds elapsed; its summed
per-fit time was 208.8 seconds, including the eight independent checks. The
replay took 108.7 seconds using two fit processes alongside the derivative
investigation, with summed per-fit time 203.5 seconds. Main-run timing uses
`CoreSeconds`, which excludes the preflight-only independent integration.

| Cell | Model | Persons | Ratings | Initial core seconds per dataset | Projected hours for 10,000 |
| --- | --- | ---: | ---: | ---: | ---: |
| 1 | RSM | 80 | 3 | 6.046 | 16.80 |
| 2 | RSM | 80 | 6 | 1.216 | 3.38 |
| 3 | RSM | 320 | 3 | 1.562 | 4.34 |
| 4 | RSM | 320 | 6 | 1.659 | 4.61 |
| 5 | PCM | 80 | 3 | 6.245 | 17.35 |
| 6 | PCM | 80 | 6 | .887 | 2.46 |
| 7 | PCM | 320 | 3 | 1.235 | 3.43 |
| 8 | PCM | 320 | 6 | 1.940 | 5.39 |

A three-process assignment of cells `1,2`, `5,6` and `3,4,7,8` projects about
20.2 hours from the initial timings and 21.1 hours from replay timings. Use
roughly 20--22 hours as a planning estimate for all 80,000 datasets, with source
identity preserved across four-hour checkpoint/resume invocations. This is a
linear extrapolation from five datasets per cell under the observed machine
load, not a measured main-run duration or a timing confidence interval.
Convergence tails, checkpoint overhead and sustained load may change it.
In particular, the smaller three-rating datasets are expensive in this pipeline;
Person count alone is an inadequate runtime predictor.

The bounded protocol and preflight are complete. Next execute the prespecified
main study in resumable cell groups, retaining every failure and numerical
conflict. No main-run coverage, global/boundary qualification, Person-score
calibration, ordinary inference/scoring approval or release decision is claimed.

## Verification and artifacts

The embedded self-check exercises calibrated/miscalibrated synthetic errors,
bias, unavailable intervals, computable numerical conflicts, incomplete counts,
policy-independent diagnostic availability, transformed coverage events,
negative variance-Wald limits and nonfinite SEs. Additional replay assertions
verify 40 unique preflight seeds, 80,000 reserved disjoint main seeds, identical
completed-checkpoint resume, changed-payload rejection, and unchanged production
R-source hashes relative to the preceding full-information evidence.
The release-readiness document test file also passed 834 expectations, with
zero failures, errors, warnings or skips. This was a validation/documentation
change; a full package/release check was not rerun and is not claimed.

Artifacts:

- [Runner](population-coverage-0.2.4.R) and immutable [protocol](population-coverage-protocol-0.2.4.md).
- [Evidence archive](population-coverage-preflight-evidence-0.2.4.rds): original/replayed states and source snapshots, both derivative refinements, verification scripts/results, timings and session information.
- [Run counts](population-coverage-preflight-runs-0.2.4.csv) and [target summaries](population-coverage-preflight-summary-0.2.4.csv), all labelled as preflight.
- [Execution log](population-coverage-preflight-execution-0.2.4.log) and [document checks](population-coverage-preflight-tests-0.2.4.csv).

Reproduce the current preflight from the package root with
`Rscript inst/validation/population-coverage-0.2.4.R preflight /tmp/pop-coverage`;
then use `summarize /tmp/pop-coverage`. Sourcing the runner exposes
`population_coverage_self_check()` and `population_coverage_refine()` without
running a simulation. The personwise refinement and replay verification scripts
are retained verbatim in the evidence archive. No package R implementation or
dependency changed in this step.
