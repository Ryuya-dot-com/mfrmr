# FairZ confirmation preparation and preflight — 2026-09-10

**Status:** protocol frozen; executable runner and preflight passed on their
recorded source. **Confirmation is paused by user instruction (0/20,000)**
for the documentation audit. Documentation-source changes alter the strict
payload identity; the saved preflight does not match the revised tree. Review
source identity and obtain a matching preflight after execution is authorized
again, without editing old hashes or results. Numerical execution success
does not qualify a public confidence interval. This advances work package 3
of the [active queue](internal-roadmap-0.2.3.md#2026-09-10-integrated-work-queue).

## Question and fixed study

The question is whether a joint-covariance SE describes repeated-calibration
variation of a fixed-reference, non-Person FairZ, and whether its normal 95%
interval covers the true expected score. The
[frozen protocol](fairz-coverage-protocol-0.2.4.md) fixes eight RSM/PCM ×
80/320-Person × 3/6-rating cells, 2,500 fresh datasets per cell, and all five
Rater/Criterion targets. The older RSM R3 coverage concern remains in scope.
The independent generator already obeys the fitted location constraints;
it does not use the uncentered-facet public-generator DRF fixture.

The primary joint-covariance and secondary focal-measure intervals use the
same fitted FairZ/data, same 95% quantile and [0,2] clipping. The
[allocation table](fairz-coverage-0.2.4/preflight-plan.csv) includes both stages;
confirmation rows are **planned**, not attempted. Seeds begin at 76010001
for preflight and 77010001 for confirmation, with cell-specific ranges.
Previous seeds and new preflight seeds do not enter confirmation.

Reuse the existing structural-study generation, MC metrics, exact binomial
intervals, influence-function MCSEs and decision bounds. Report the five
targets separately, with finite estimates, availability, conditional coverage,
actual clipped width and paired method differences. A secondary *performance*
disposition does not decide the primary method's statistical disposition;
the prespecified shared numerical checks still cover both calculations.
The planning coverage MCSE is 0.00436 at 2,500 replications and 95% coverage.
Any unresolved bias/SE-ratio MC interval remains review, without an automatic
extension until it passes.

## Execution and numerical findings

Runner: [fairz-coverage-0.2.4.R](fairz-coverage-0.2.4.R).
The final [run table](fairz-coverage-0.2.4/preflight/runs.csv) contains
40 unique preflight datasets: five per cell. All 40 q61 fits were ready with
unregularized covariance; no errors, warnings, numerical conflicts or
verification failures occurred. All 400 target/method rows had computable
intervals and retained false public FairCI eligibility.

Every q61 fit received a q121 objective/gradient/information evaluation at
the same parameters. The first dataset in each cell also received a fresh
q121 optimization and Person rescoring: **48 complete fits**, not 48 independent
datasets. See [eight full-refit checks](fairz-coverage-0.2.4/preflight-checks.csv).

| Check | Maximum discrepancy | Prespecified bound |
| --- | ---: | ---: |
| Independent FairZ versus public table | 2.22e-16 | <1e-9 |
| Analytic versus numerical gradient | 2.64e-11 | <1e-7 |
| Conditional SE versus public plot data | 2.56e-13 | <1e-8 |
| q121 fixed-parameter objective change | 1.17e-8 | ≤1e-6 |
| q121 fixed-parameter relative SE change | 6.26e-10 | ≤0.001 |
| q121 Newton displacement / q61 parameter SE | 1.11e-5 | ≤0.001 |
| Full-refit score change | 1.48e-10 | ≤1e-5 |
| Full-refit relative SE change | 7.34e-10 | ≤0.001 |
| Full-refit clipped endpoint change | 2.14e-10 | ≤1e-5 |

Full-refit parameter, objective and Person EAP changes were at most 4.66e-10,
4.79e-9 and 1.14e-9 respectively; these are reported diagnostics, not new
post-hoc acceptance cutoffs. The local Newton quantity above is not presented
as the actual refit movement.

The [80 metric rows](fairz-coverage-0.2.4/preflight/summary.csv) all say
`preflight_only`. The [40 paired summaries](fairz-coverage-0.2.4/preflight/paired.csv)
use common-available datasets and paired MCSEs. Five datasets per cell do not
establish coverage, SE calibration, superiority of one method or absence of
bias. Each [raw target row](fairz-coverage-0.2.4/preflight-targets.csv) was checked
against its saved RDS estimate, truth, SE and endpoints to <1e-14.

## Source and resumability checks

The initial preflight passed, but the source-identity review then identified
that the direct MML path uses cpp11 as well as R. The
[protocol addendum](fairz-coverage-protocol-0.2.4.md#source-contract-hardening-after-the-first-preflight)
records this correction before any confirmation execution. Source identity
now includes R and C/C++/header/Makevars sources, DESCRIPTION/NAMESPACE and
repository helper/protocol files, plus the loaded native-library MD5,
cpp11-enabled option, R version and platform. The current backend is R 4.6.1
on aarch64-apple-darwin23; see [backend identity](fairz-coverage-0.2.4/backend.csv)
and [source hashes](fairz-coverage-0.2.4/source-md5.csv). Cell RDS files preserve
the source text and session information.

The initial source contract and outputs are retained under
`fairz-coverage-0.2.4/initial-source-contract/`. The same 40 preflight datasets
were repeated under the corrected contract; data, free parameters, FairZ,
SEs, interval availability/endpoints and full-refit diagnostics match exactly
in all [40 comparisons](fairz-coverage-0.2.4/preflight-repeated.csv). These
reruns do not increase the independent replication count.

The [executable checks](fairz-coverage-check-0.2.4.R) and
[check log](fairz-coverage-0.2.4/checks.log) verify:

* Existing MC summaries discriminate correct, too-small/large SEs, bias,
  missing estimates, numerical conflicts and incomplete samples.
* Clipping preserves inclusion of every tested truth in [0,2], while width
  is computed from clipped endpoints; invalid/zero/nonfinite SEs stay unavailable.
* Confirmation allocates 20,000 distinct seeds, disjoint from preflight.
* Resuming the completed real preflight does not recompute or rewrite its RDS
  files. A synthetic interruption checkpoints after one attempt, resumes
  attempts 2–5 only, and skips the completed cell thereafter.
* Mixed source, native binary, stage, duplicate seed and malformed matrix
  payloads fail validation; old metadata cannot promote fair-score eligibility.
* An incomplete preflight cannot start confirmation. A cell lock prevents a
  second writer. Synthetic checkpoint tests are not simulated-study evidence.

No package API or estimator implementation changed in this increment. Only
repository validation scripts/documents and evidence were added. The package
test suite was not repeated for these repository-only changes; the relevant
new study checks were executed. `inst/validation` remains excluded from the
source package by `.Rbuildignore`.

## Measured time and next execution

The final preflight command took **59.23 seconds wall time**. Per-dataset
timings totaled 55.415 seconds, consisting of 26.632 seconds for the exact
main procedure and 28.783 seconds for extra preflight verification/full refits.
The remaining 3.815 seconds include startup, checkpoint serialization and
other runner overhead; they are not a pure checkpoint-cost measurement.

| Model | Persons | Ratings per Person | Mean main-procedure seconds/dataset | Projected 2,500-dataset minutes |
| --- | ---: | ---: | ---: | ---: |
| RSM | 80 | 3 | 0.444 | 18.5 |
| RSM | 80 | 6 | 0.337 | 14.0 |
| RSM | 320 | 3 | 0.695 | 28.9 |
| RSM | 320 | 6 | 1.065 | 44.4 |
| PCM | 80 | 3 | 0.330 | 13.8 |
| PCM | 80 | 6 | 0.419 | 17.5 |
| PCM | 320 | 3 | 0.778 | 32.4 |
| PCM | 320 | 6 | 1.258 | 52.4 |

Summing these projections gives **about 3.7 serial hours** before main-run
checkpoint/report overhead. Applying each cell's fastest/slowest observed
core time gives 3.4–4.4 hours; this is a small-preflight sensitivity range,
not a confidence interval or a guaranteed deadline. A practical initial
budget is about four serial hours, with the existing four-hour checkpoint
ceiling and resume available. At most three disjoint-cell R processes are
allowed, but parallel speedup and whole-main checkpoint costs are unmeasured.
Detailed components are in [timings](fairz-coverage-0.2.4/preflight-timings.csv).

After the documentation review, renewed execution authorization and a passing
matching-source preflight, the prepared main commands from the package root are:

```sh
Rscript inst/validation/fairz-coverage-0.2.4.R confirmation inst/validation/fairz-coverage-0.2.4
Rscript inst/validation/fairz-coverage-0.2.4.R summarize inst/validation/fairz-coverage-0.2.4/confirmation
```

Repeating the first command resumes identical-source unfinished cells.
Do not share a cell between workers or remove a live cell lock. After an
abrupt process kill, verify that its process ended before clearing its stale
lock. Source/backend drift requires review and a matching new preflight;
do not edit hashes to force a resume.

**Answer:** the fixed study has a measured local budget and tested failure
accounting on its recorded source. Execution remains paused for documentation
review and source reconciliation. Statistical qualification still depends on
the unrun study.
The separate population 80,000-dataset study, DRF location/linking alignment,
FairM/Person targets and complete GPCM comparison remain open.
