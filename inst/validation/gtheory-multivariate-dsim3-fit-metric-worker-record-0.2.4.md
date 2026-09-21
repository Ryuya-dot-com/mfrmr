# D-SIM-3 fit/metric shadow-worker record

Status: shadow-qualified; terminal/resource orchestration and reconciliation remain open
Date: 2026-08-31
Scope: nonreserved template execution only; no exploratory recovery claim

## Decision

Implement one worker for both frozen lme4/REML route families and qualify it
on the existing 854 shadow fixtures. Execute one fit per distinct
scenario-route template rather than refitting the identical shadow dataset for
the second planned replicate. Preserve a one-to-many coverage map from 25
executed templates to all 50 exact backend and 100 exact metric request
identities.

This does not collapse the planned denominator. Later 856 attempts remain 42
distinct generated datasets and 50 distinct candidate route attempts. The
deduplication applies only to implementation qualification, where the two
replicate requests currently have the same design template and shadow dataset.

## Frozen identity

| field | value |
|---|---|
| contract | `MFRMR-GTHEORY-MV-DSIM3-FIT-METRIC-SHADOW-WORKER-V1` |
| contract hash | `9e5055fc47191f4426507c352b45b72a2a40256bd227dcf464d04e7058de44c7` |
| manifest hash | `566faa25b496f32137fc167cc26b37f172e5fe2b2be73b78a22517e9d1213eb1` |
| source SHA-256 | `6acac1c8665685f1b9b700daade2d5c3354516b3e6677c86bd1313bf10e746a6` |
| parent request manifest | `69cf70189e1a72fbdda3af4fcca5d37873ef3e5f23d96c0d2cb4b1b87e8e1cef` |
| parent superseding plan | `58555b19309c20a3fe087065c21319f9567b36162e818fea37044e2461a0cb1a` |
| shadow seed range | `854100001`--`854100021` |
| reserved streams opened | neither 855 nor 856 |

The exact observed environment identity is frozen in the manifest: R 4.6.1,
Matrix 1.7.6, lme4 2.0.6, digest 0.6.39, platform
`aarch64-apple-darwin23`, plus hashes of the lmer and VarCorr methods.

## Executed template classes

| route | model class | formula-level representation |
|---|---|---|
| separate univariate | crossed, repeat > 1 | Object + Condition + ObjectCondition + residual |
| separate univariate | crossed, repeat = 1 | Object + Condition + combined ObjectCondition/event residual |
| separate univariate | nested, repeat > 1 | Object + NestedCondition + residual |
| separate univariate | nested, repeat = 1 | Object + combined NestedCondition/event residual |
| restricted multivariate | crossed, repeat > 1 | stratum fixed effects and correlated stratum slopes for Object, Condition, and ObjectCondition; common diagonal residual |
| restricted multivariate | nested, repeat = 1 | stratum fixed effects and correlated Object slopes; combined diagonal residual |

The worker contains six formula classes and zero scenario-specific patches.
The separate route performs one fit for each registered stratum. The restricted
multivariate route performs one joint fit and takes only marginal component
diagonals into the current coefficients. It retains fitted cross-stratum
covariances but does not silently insert them into G or Phi.

## Qualification result

| item | result |
|---|---:|
| scenario profiles exercised | 21/21 |
| scenario-route templates | 25/25 |
| separate-univariate templates | 21/21 |
| restricted-multivariate templates | 4/4 |
| lme4/REML fit calls returned | 51/51 |
| fitted stratum coefficient rows ready | 57/57 |
| complete template metric vectors | 50/50 |
| exact backend requests covered | 50/50 |
| exact metric requests covered | 100/100 |
| duplicate shadow replicate fits avoided | 25 |
| scalar pooling / package decision weights / voting | 0 |
| diagnostic overrides | 0 |
| singular fits | 12/51 |
| fits with convergence messages | 12/51 |
| fits with warnings | 0/51 |

All returned G/Phi values are finite, lie in [0, 1], preserve the complete
registered stratum names, and satisfy Phi <= G. These checks qualify output
shape and coefficient plumbing only. They are not comparisons to generating
truth and therefore do not establish bias, coverage, robustness, model
adequacy, or recovery.

The 12 singular fits are retained as diagnostics. They are neither silently
repaired nor removed from the qualification denominator. At this stage they do
not invalidate the worker interface: boundary and stressed profiles were
deliberately included, and later simulation evidence must determine whether
their estimates are scientifically adequate. A diagnostic may constrain a
future support claim, but it does not rewrite an observed fit outcome.

## Boundary preserved

- the worker regenerated only deterministic replay of the already qualified
  nonreserved 854 fixtures and restored the caller RNG state;
- each template records its actual 854 seed and generation hash separately
  from the 856 request identity it covers;
- no shadow template counts as a planned exploratory dataset or route attempt;
- no fitted value is labelled recovery evidence;
- no terminal receipt for the 856 plan is issued;
- resource enforcement has not yet been rebound to this real worker; and
- overall feature maturity remains `specified`.

## Next bounded action

Bind this exact worker identity to the terminal and five-scope resource
orchestrator on nonreserved shadow workloads. Exercise success, fit failure,
metric failure, wall-time, peak-RSS, and stop-new-launches outcomes without
fabricating receipts for unlaunched units. Then rerun nonexecuting
launch-readiness reconciliation against the exact environment and all 289
request hashes.

Do not open 856 until that reconciliation passes. Even a later exploratory run
would remain nonpromoting evidence; simulation validation and public support
require the separate confirmation sequence.
