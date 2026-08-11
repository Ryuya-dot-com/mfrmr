# Draft.83d2b2b1g13 exact-resume stationarity runner contract

Status: completed repository-only runner-mechanics slice, 2026-08-10. This
contract fixes the accounting and exact-resume behavior needed by a future
stationarity-calibration execution. It neither implements the production
backend adapters nor authorizes, generates, reads, summarizes, or uses reserved
calibration replicates 201--300 or confirmation replicates 501--700.

## Atomic unit and denominators

One atomic unit is one dataset x method, containing every registered optimizer
profile for both full and reduced model roles and both high-accuracy reference
rows. This keeps the independent Monte Carlo unit at dataset level while
making a method checkpoint indivisible. The sealed b1g7 workload resolves to:

| Ledger | Planned count | Counting identity |
| --- | ---: | --- |
| independent datasets / completion markers | 3,000 | 30 scenarios x 100 calibration replicates |
| atomic dataset-method units | 12,000 | 3,000 datasets x 4 method lanes |
| production candidate-fit rows | 108,000 | 72,000 glmmTMB plus 36,000 lme4 full/reduced optimizer-profile fits |
| candidate-decision rows | 576,000 | 12,000 units x 2 model roles x 24 frozen candidates |
| high-accuracy reference rows | 24,000 | 12,000 units x 2 model roles |

Candidate fits, expanded candidate decisions, and reference results are three
separate typed ledgers. The 24-fold decision expansion cannot conceal a
missing optimizer fit or reference problem. A failed or malformed evaluator
is expanded to its complete planned row denominator with a typed failure stage
and message digest; successful-only deletion is prohibited.

## Truth-blind selection and aggregation

For each dataset, method, and model role, the retained optimizer profile is
selected by the frozen b1g7 minimum-finite-objective rule with exact-tie
priority. Generating truth, diagnostic score, candidate state, target variance,
and downstream error metric cannot select a profile. Only after this selection
does the runner apply all 24 b1g11 family-zone candidates. Reference labels are
joined by the unique observation identity after candidate decisions are
complete.

Primary acceptance summaries remain scenario x method x model role x
candidate. Dataset-method rows are not independent replicates, and the runner
does not pool them to manufacture Monte Carlo precision. The acceptance-policy
object, not runner mechanics, owns safety and decisive-coverage criteria.

## Exact-resume identity

Each checkpoint binds:

- the b1g13 runner contract hash and exact run-manifest hash;
- the atomic-unit identity and its hash;
- complete candidate-fit, candidate-decision, and reference ledgers and their
  individual hashes; and
- a bundle hash and enclosing checkpoint hash.

Checkpoints are serialized to a temporary RDS file in the destination
directory and installed with a same-filesystem rename. A missing, unreadable,
stale, malformed, or hash-mismatched checkpoint is recomputed and is never
pooled with its replacement. A dataset completion marker is valid only when
all four registered method checkpoint hashes agree with its content-addressed
identity.

Elapsed, user, and system time and whether a checkpoint was reused are
operational metadata, not scientific inputs. They are excluded from the
checkpoint identity. Ordered complete ledgers, unit checkpoint hashes, and
dataset marker hashes determine the scientific execution hash. Consequently,
an uninterrupted cold run, an interrupted-then-resumed run, and a complete
no-fit reuse must have the same scientific hash.

An interrupted run returns only
`partial_checkpoint_set_not_evidence`. It cannot produce a complete execution
object, an acceptance result, or a readiness claim. Early stopping on observed
calibration results is prohibited.

## Authorization firewall

The implemented executable path accepts only the exact, content-addressed
nonreserved mechanics manifest for replicates 901 and 902 and the exact fixture
evaluator function hashes. It rejects any manifest that contains 201--300,
claims calibration or confirmation use, changes an evaluator, or fails its
manifest hash. The sealed 201--300 rows can be reconstructed and counted, but
every row remains `ExecutionAuthorized=FALSE`.

This distinction is deliberate. The b1g7 sealed workload identity exists, but
a production run manifest that binds final evaluator adapters, runtime
identity, write location, shard allocation, and the one-way authorization
event does not yet exist.

## Mechanics verification

The nonreserved fixture contains two datasets, eight atomic method units, 72
candidate-fit rows, 384 candidate-decision rows, and 16 reference rows. It
includes intentional candidate-fit and unresolved-reference states so that
failure retention is exercised rather than inferred from all-success data.

The audit verifies:

- exact reconstruction of all five sealed workload counts;
- complete typed expansion after evaluator exceptions or malformed output;
- rejection of mutated checkpoints, markers, manifests, and evaluator hashes;
- a three-unit interruption followed by exact resume;
- equality of resumed, cold, and complete-reuse execution hashes; and
- recomputation of one deliberately corrupted checkpoint without changing the
  final scientific hash.

Nine focused tests with 129 expectations pass without failures, errors,
warnings, or skips. No calibration or confirmation response is used by those
tests.

## Readiness boundary and next gate

`ExactResumeRunnerImplemented=TRUE` and `RunnerImplementationReady=TRUE` mean
only that atomic accounting, failure retention, integrity validation, and
exact-resume mechanics are implemented. They coexist with
`ProductionEvaluatorAdaptersFrozen=FALSE`, `ReservedRunManifestFrozen=FALSE`,
`CalibrationAuthorizationReady=FALSE`,
`CalibrationExecutionAuthorized=FALSE`, `StationarityThresholdFrozen=FALSE`,
and `StationarityCriterionReady=FALSE`.

The next admissible gate is a no-response production preflight: freeze the
four backend-likelihood evaluator adapters, bind their function and runtime
identities into a reserved execution manifest, prove one atomic dry-run schema
per lane without using 201--300, and independently audit exact shard and output
destinations. Only a later immutable authorization record may reconsider
opening replicate 201. Calibration results, if eventually authorized, must be
completed and locked before any separately reserved confirmation result is
viewed.

## Sources

- Morris, T. P., White, I. R., and Crowther, M. J. (2019). Using simulation
  studies to evaluate statistical methods. *Statistics in Medicine*, 38,
  2074--2102. https://doi.org/10.1002/sim.8086
- R Core Team. `readRDS` and `saveRDS` documentation:
  https://stat.ethz.ch/R-manual/R-devel/library/base/html/readRDS.html
- R Core Team. File manipulation and `file.rename` documentation:
  https://stat.ethz.ch/R-manual/R-devel/library/base/html/files.html
- lme4 convergence documentation:
  https://lme4.github.io/lme4/reference/convergence.html
- glmmTMB troubleshooting documentation:
  https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html
