# Draft.83d2b2b1d replacement feasibility execution contract

Status: repository-only runner, checkpoint, and descriptive-summary contract,
2026-08-10.

This contract executes only the 3,000 method routes authorized by
Draft.83d2b2b1c. It does not add replicates, fit an inner bootstrap, select a
cutpoint, test a null hypothesis, estimate size or power, authorize a
confirmation run, or support a D-study decision.

## Frozen execution identity

Execution requires exact agreement among the Draft.83d2b2b1c feasibility
contract, untouched manifest, and separate authorization hashes. It also
binds the R and platform identity, lme4 and glmmTMB versions, default-control
function identities, generator and pre-fit identities, diagnostic-pair and
observable identities, target component, boundary and negative-likelihood
tolerances, and every runner/checkpoint/summary function identity.

The scientific execution hash excludes elapsed time, filesystem location,
progress-message frequency, execution order, and whether a valid route was
computed in the current process or reused. Those quantities describe
execution, not the statistical result. The hash includes all 3,000 atomic
rows, including typed failures, and all 750 dataset-completion identities.

## Atomic checkpoint and resume semantics

One checkpoint is one registered method's complete full/reduced pair. The
checkpoint contains exactly one success row or one typed failure row. A fit
warning, singular fit, boundary estimate, unavailable Hessian, materially
negative likelihood difference, or unavailable common score is retained as
observed; it is not converted to a missing route.

Each route checkpoint binds:

- runner, feasibility-contract, manifest, and authorization hashes;
- the complete frozen manifest row and route ID;
- scenario, replicate, seed, generator, analysis-data, pre-fit, retained-data,
  method, backend, likelihood, target, and tolerance identities;
- the full/reduced diagnostic result and observable hashes when returned;
- the typed stage and message digest when the route fails; and
- a hash of the complete timing-excluded route identity.

The write is made to a temporary file in the checkpoint directory and renamed
only after serialization succeeds. A scenario-by-replicate dataset is marked
complete only when all four expected route files validate and their sorted
route-result hashes match the marker. The marker is also written atomically.

On resume, four valid route files plus a valid dataset marker permit reuse
without regenerating the dataset. A missing marker can be reconstructed only
from four independently valid route checkpoints. A missing, corrupt, stale,
or identity-mismatched route is recomputed from the deterministic registered
seed. It is never silently pooled with a different identity. Partial datasets
remain in the planned denominator, and no successful-only ledger is allowed.

No data-dependent early stopping is permitted. Completion requires exactly
3,000 unique route results, 750 valid dataset markers, four routes per dataset,
25 replicates per scenario-method cell, and the original 6,000 planned
full/reduced backend fits.

## Threshold-free descriptive summaries

Primary availability and diagnostic summaries are reported separately for
every scenario x method cell. Their denominator is always the 25 planned
routes. Pair return, likelihood-identity availability, common-score
availability, materially negative likelihood difference, target boundary,
and nuisance boundary counts are separate quantities.

For each design, method, and common score, monotone truth ordering is
summarized by Spearman's rank correlation between the registered generating
Rater variance and the score among finite common-score rows. The number of
available observations and distinct generating variance levels is retained.
No correlation p-value or confidence interval is assigned.

Only designs with both registered positive and negative controls receive a
matched rank-probability summary. For available positive scores
\(X_1,\ldots,X_{n_+}\) and negative-control scores
\(Y_1,\ldots,Y_{n_-}\), the descriptive estimand is

\[
 \widehat P_{rank}=
 \frac{1}{n_+n_-}\sum_{i=1}^{n_+}\sum_{j=1}^{n_-}
 \left\{I(X_i>Y_j)+\tfrac12 I(X_i=Y_j)\right\}.
\]

Wins, ties, losses, and the exact available-pair denominator are reported.
This is an empirical ordering probability, not a threshold, classifier,
ROC-optimized rule, calibrated test, or claim that its pairwise comparisons
are mutually independent. Designs without a registered positive control and
transition regions with no binary requirement cannot be relabelled after
viewing results.

The three common scores remain target fraction of total fitted variance,
target-to-residual variance ratio, and the raw untruncated nested-likelihood
difference within each separately labelled backend and ML/REML route.
Backend-coordinate standard errors are not common scores.

## Readiness meaning

`FeasibilityEvidenceReady = TRUE` means only that the frozen descriptive run
has exact atomic accounting and replayable identities. It does not require
every score to be available and does not mean that any score separates the
registered regions adequately.

`BootstrapOperatingCharacteristicsReady`, `CalibrationEvidenceReady`,
`ThresholdFrozen`, `ConfirmationAuthorized`, `InferenceReady`,
`CoefficientEligible`, and `DecisionReady` remain false regardless of the
descriptive result. A later contract must use separate data to define and
calibrate any inferential rule.
