# Draft.83d2b2b1g14 production-adapter and reserved-manifest preflight contract

Status: completed repository-only production-preflight slice, 2026-08-10.
This contract freezes the real candidate/reference evaluator adapters and the
exact reserved-run manifest without authorizing, generating, reading,
summarizing, or using calibration replicates 201--300 or confirmation
replicates 501--700.

## Production adapter identity

The candidate evaluator uses the same deterministic ADEMP generator and
structural pre-fit audit as the high-accuracy reference evaluator. Every
candidate-fit and reference row records both identities. A preflight is
invalid unless both generator and pre-fit hashes agree within and between all
four backend-likelihood lanes.

The candidate path is the executable composition already frozen upstream:

- lme4 ML and REML each fit three registered optimizer profiles for both the
  full and reduced model;
- glmmTMB ML and REML each fit the six-profile cold/restart/cross-algorithm
  directed acyclic graph for both model roles;
- the retained profile is selected within dataset x method x model role by
  minimum finite objective with exact-tie priority; and
- only after objective-only profile selection is the coordinate-specific b1g12
  boundary probe applied to the retained full fit.

Generating truth, diagnostic magnitude, candidate state, and downstream error
cannot select a profile. Candidate fitting uses the production-scale metrics;
reference fitting uses the separately frozen glmmTMB and lme4 high-accuracy
mechanics. Optimizer return, derivative evidence, curvature, boundary state,
and reference state remain separate typed observables.

The contract hashes the two top-level adapters, 15 called adapter dependencies,
23 b1g14 functions, the b1g13 runner, b1g12 boundary probe, b1g6 glmmTMB
reference, b1g10 lme4 reference, runtime, and package versions. A runtime or
dependency change requires a new manifest rather than retrospective reuse of
this identity.

## Nonreserved production dry-run

One untouched-by-this-gate nonreserved dataset,
`GT-WI-baseline_complete-reference_1200/R0902`, is evaluated under all four
lanes. The exact dry-run denominator is:

| Ledger | Count |
| --- | ---: |
| independent datasets | 1 |
| atomic dataset-method units | 4 |
| candidate-fit rows | 36 |
| candidate-decision rows | 192 |
| high-accuracy reference rows | 8 |

The dry-run exercises actual lme4/glmmTMB fitting, upstream objective-only
selection, production boundary profiling, and high-accuracy references. A
typed fit failure remains in the planned denominator; successful-only deletion
is prohibited. Complete reuse must reproduce the scientific execution hash
without a new fit.

Dry-run execution is not calibration. Its manifest explicitly sets
`CalibrationExecutionAuthorized=FALSE`, and no row may use replicates 201--300
or 501--700.

## Reserved run manifest

The reserved manifest binds the current runtime, adapter and dependency hashes,
relative output root, exact atomic-unit assignment, and one shard per
calibration replicate. It independently reconstructs:

| Ledger | Total | Per shard |
| --- | ---: | ---: |
| independent datasets | 3,000 | 30 |
| atomic dataset-method units | 12,000 | 120 |
| candidate-fit rows | 108,000 | 1,080 |
| candidate-decision rows | 576,000 | 5,760 |
| high-accuracy reference rows | 24,000 | 240 |
| shards | 100 | 1 |

Shard IDs `R0201` through `R0300` and every atomic-unit identity hash are fixed
before authorization. Timing, progress frequency, and computed-versus-reused
metadata are excluded from scientific identity. Early stopping is prohibited.

The output root is repository-relative and contains no parent traversal. The
runner's temporary file and final checkpoint are in the same destination
directory; the checked `file.rename()` result remains part of the exact-resume
mechanics. Production execution must separately preflight destination
permissions, free space, and same-filesystem behavior before authorization.

## Authorization firewall

`ReservedRunManifestFrozen=TRUE` does not mean that the manifest is executable.
Every reserved row has `ExecutionAuthorized=FALSE`. The production adapters
reject a direct reserved-unit call unless a future contract carries both a
64-character immutable authorization-record hash and the exact authorized
reserved-manifest hash. b1g14 supplies neither.

This one-way firewall prevents a dry-run, a valid schema, or a frozen shard map
from silently becoming calibration evidence. The following remain false:

- calibration authorization, execution, data generation, and result viewing;
- stationarity threshold and production criterion readiness;
- confirmation authorization;
- inference, coefficient, decision, and D-study readiness; and
- any public or checklist promotion.

## Preflight acceptance

`ProductionAdapterPreflightReady=TRUE` requires all of the following:

- exact contract, runtime, adapter, dependency, and manifest hashes;
- all five reserved workload counts and all 100 per-shard counts;
- complete nonreserved dry-run ledgers of 36, 192, and 8 rows;
- a recomputed dry-run scientific execution hash before any ledger is used;
- unique matching candidate/reference generator and pre-fit identities in all
  four lanes;
- truth-blind candidate decisions; and
- simultaneous absence of reserved execution authorization.

It means only that the executable adapters and their future workload map are
identified and schema-tested. It is not evidence about stationarity cutpoints,
false-ready rates, power, recovery, interval coverage, or D-study stability.

## Next admissible gate

The next gate is an independent, response-free, one-way authorization audit.
It must verify source/contract/manifest hashes, runtime and dependency identity,
destination permissions and capacity, shard accounting, no early stopping,
and the absence of any confirmation access. Only a later immutable artifact
may change the exact reserved manifest from non-executable to executable and
reconsider opening replicate 201. No calibration result may be inspected while
that audit is being constructed.

## Sources

- Morris, T. P., White, I. R., and Crowther, M. J. (2019). Using simulation
  studies to evaluate statistical methods. *Statistics in Medicine*, 38,
  2074--2102. https://doi.org/10.1002/sim.8086
- R Core Team. `sessionInfo` documentation:
  https://stat.ethz.ch/R-manual/R-devel/library/utils/html/sessionInfo.html
- R Core Team. File manipulation and `file.rename` documentation:
  https://stat.ethz.ch/R-manual/R-devel/library/base/html/files.html
- lme4 convergence documentation:
  https://lme4.github.io/lme4/reference/convergence.html
- glmmTMB troubleshooting documentation:
  https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html
