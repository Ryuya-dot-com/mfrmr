# Owner-specific GPCM pilot execution and precision contract

Status: `0.2.3-draft.66` corrected pre-pilot execution contract; confirmation is not
authorized

Date: 2026-08-08

This contract governs the authorization-guarded owner-specific pilot defined
by `gpcm-owner-specific-pilot-0.2.3.R`. It does not change the fitted
likelihood, establish a numerical acceptance threshold, or permit a
substantive rater-consistency claim.

## Frozen structural rules for pilot execution

1. The pilot contains 24 owner/estimator/design cells and five prespecified
   replicates per cell, for 120 manifest rows.
2. All 120 rows have distinct seeds and scenario identifiers. Pilot seeds do
   not overlap smoke or future confirmation ranges.
3. Criterion-owned and rater-owned rows retain separate gate identifiers.
4. `SlopeOwner == StepOwner`, `SlopeComposition` is
   `single_owner_relative_gm1`, and `LatentDimensionCount` is one in every
   executable row.
5. The declared 1--4 score support is preserved with `keep_original = TRUE`.
   In particular, an internal-zero row fitted on observed scores 1/3/4 must
   remain a four-category model with category 2 absent; automatic recoding to
   1/2/3 invalidates that design cell.
6. The loaded package content, runner, model-identity contract, execution
   contract, full manifest, optimizer ceiling, and quadrature setting enter
   one global execution identity.
7. The primary pilot uses `maxit = 400` and 31-point Gaussian--Hermite
   quadrature, matching the package defaults. Lower-node smoke settings are
   software controls only. A later MML integration-sensitivity lane must use a
   separately registered execution identity and cannot be pooled into the
   primary q=31 recovery result.
8. Shards are a deterministic partition of the prespecified manifest order.
   Sharding changes workload only; it cannot change seeds, cells, thresholds,
   or the global execution identity.
9. There is no outcome-adaptive early stopping. Every selected row is
   attempted unless the process is interrupted or an execution-integrity
   invariant fails.
10. Fit, convergence, support, or recovery failure is a retained result, not a
   reason to drop the replicate or abort later statistical rows.
11. Confirmation remains unauthorized regardless of a favorable pilot result.

## Denominators and missingness

For every owner/estimator/design cell, the primary Bernoulli denominator is
the five planned manifest rows. `NA`, fit failure, or missing metric values do
not reduce that denominator.

The following counts and rates are reported against all planned rows:

- executed;
- fit succeeded;
- raw inference ready;
- evidence inference ready;
- raw false-ready;
- upstream-ready blocked by an evidence support guard; and
- final false-ready.

Recovery summaries use only finite eligible metric values for their mean,
standard deviation, and Monte Carlo standard error. They must also report the
planned denominator, finite count, missing/ineligible count, fit-failure
count, and evidence-ready count. A small finite subset cannot be presented as
the cell result without these counts.

## Monte Carlo uncertainty

For a Bernoulli outcome with `x` events in `n = 5` planned replicates, report:

- `x`, `n`, and `x / n`;
- the plug-in Bernoulli Monte Carlo standard error; and
- the two-sided 95% Wilson interval.

For a finite numeric metric, report count, mean, standard deviation, minimum,
maximum, and `SD / sqrt(count)` when at least two values exist. With fewer than
two finite values, numeric MCSE is unavailable. No threshold may be frozen
from five replicates merely because its observed MCSE is small.

## Stopping and continuation

Statistical outcomes never stop the pilot early. Only the following conditions
stop execution:

- malformed or changed manifest identity;
- loaded-runtime, runner, contract, optimizer-control, or quadrature mismatch;
- unsafe or unexpected checkpoint filename;
- unreadable, incomplete, adulterated, or identity-mismatched checkpoint;
- failure to verify an atomically written checkpoint; or
- an explicitly injected interruption used to test resume behavior.

Resource exhaustion or external interruption leaves completed checkpoints in
place. It is not a completed pilot and produces no completion marker.

## Shard contract

For `ShardCount = S`, manifest row `j` belongs to
`1 + ((j - 1) mod S)`. `ShardIndex` is one through `S`. The union of all
shards must equal the selected manifest exactly once and every pair of shards
must be disjoint. `ShardCount` cannot exceed the declared row count; empty
shards are not executable evidence units.

Supplying ad hoc scenario identifiers together with more than one shard is
prohibited. This prevents a caller from redefining the shard population after
seeing results.

## Checkpoint contract

Checkpoint schema `mfrmr-gpcm-owner-checkpoint-v1` stores exactly one scenario
result and binds it to:

- global execution SHA-256;
- scenario and design-cell identifiers;
- the exact one-row manifest SHA-256; and
- the result SHA-256.

A one-row manifest is canonicalized by content before hashing; incidental R
`row.names` created by full-manifest versus shard subsetting are not evidence
identity. A checkpoint may be reused only after all fields and hashes validate.
`resume = FALSE` refuses an existing checkpoint set. `resume = TRUE` refuses
orphan filenames and validates every present checkpoint, including files from
other shards, before running the selected shard. Any identity or payload
mismatch fails immediately. Checkpoints from different shards are composable
because they share one global execution identity.

## Completion contract

Schema `mfrmr-gpcm-owner-completion-v1` may be written only after every row in
the declared manifest has one valid checkpoint and the aggregate row set
matches the manifest exactly. The completion marker records the global
execution identity and a relative-path/SHA-256 inventory of every retained
aggregate and checkpoint artifact.

Missing, extra, unsafe, or hash-mismatched artifacts invalidate completion.
An existing valid completion marker is immutable; a new run must use a new
output directory.

## Pilot interpretation

The pilot may estimate variance, failure rates, support problems, runtime, and
candidate margins for a later specification draft. It cannot by itself:

- pass an owner-specific recovery or coverage gate;
- establish a universal sample-size or category-count rule;
- convert optimizer slopes into primary inferential estimates;
- validate nonuniform DFF, centrality, multidimensionality, or local
  dependence; or
- authorize confirmation.

After the pilot, any proposed numeric rule must be documented with its
denominator, Monte Carlo uncertainty, margin rationale, failure policy, and
affected evidence rows. Changing the manifest, estimator contract, identity
fields, or stopping rule requires a new numbered specification and invalidates
the affected pilot evidence.
