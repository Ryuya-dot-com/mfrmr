# Current-default paired-owner GPCM contract P1r record (0.2.3)

## Purpose

P1q established that the completed Draft.66 owner pilot is valid historical
fixed-standard-normal MML evidence but does not represent the current
`free_population` default. P1r defines the smallest prospective design that
can test the missing current-default identity path. It performs no fit,
generates no data, and adds no recovery, fit, DFF, external, or release
evidence.

## Why the design is paired

An owner comparison is uninterpretable if Criterion-owned and Rater-owned
routes receive unrelated random data. P1r therefore declares two source
datasets:

- one generated with non-unit Criterion-owned slopes; and
- one generated with non-unit Rater-owned slopes.

Each exact dataset is then shared by four fit routes: Criterion/JML,
Criterion/MML, Rater/JML, and Rater/MML. This produces eight planned routes.
Within each source dataset, all four rows have the same `DataScenarioId`,
`DataSeed`, and future retained-data hash. The aligned and alternate-owner
fits can therefore be attributed on common data. The smoke is still only a
software/identity and paired-attribution check; two datasets cannot establish
an owner operating characteristic or a universal preference.

## Frozen model identity

All routes use bounded single-owner GPCM with one dimension,
`SlopeOwner == StepOwner`, geometric-mean-one relative slopes, explicit score
support 1--4, `keep_original = TRUE`, 120 Persons, six Raters, six Criteria,
and complete crossing.

The estimator-scale contracts remain separate:

| Estimator | Recorded identification | Ability-scale contract | Numerical control |
| --- | --- | --- | --- |
| JML | `not_applicable_jml` | fixed Person coordinates jointly estimated | `maxit = 400` |
| MML | `free_population` | intercept-only estimated normal population location/scale | q=31, `maxit = 400` |

The prospective fit call records `gpcm_mml_identification =
"free_population"` explicitly even though it is irrelevant to JML. This
prevents a later package-default change from silently changing an MML route or
making the replay text ambiguous.

## Surface admission contract

Twelve identity fields are mandatory: source slope owner, fitted slope owner,
step owner, slope composition, latent dimension, estimator, ability-scale
contract, GPCM MML identification, rating minimum, rating maximum, declared
category support, and runtime identity.

They must be retained on 13 prospective surfaces: declared manifest,
generated-data ledger, result, checkpoint manifest/result, stratum-expanded
summary/rate/numeric aggregates, stratum-expanded execution identity/policy,
checkpoint ledger, replay call, and any external normalizer that is later
instantiated. Missing identity fails evidence admission. The external row is
conditional because P1r authorizes no external comparison; it prevents a
future normalizer from being admitted without the same fields.

Runtime, execution-runner, contract, and complete-manifest SHA-256 identities
are mandatory before execution. The contract object intentionally uses no
placeholder runtime as evidence. P1r only states that a bounded smoke becomes
admissible after those real identities are bound.

## Fail-closed scope

Routine mutation tests reject:

- a seed change that breaks common-data pairing;
- fixed-standard-normal substitution on a current MML row;
- a changed category minimum;
- malformed or non-scalar SHA identities; and
- any attempt to authorize confirmation or other forbidden claims.

No threshold is frozen and no comparison is classified as inferential. An
alternate-owner fit is explicitly labelled misspecified relative to the source
generator; this is a controlled attribution route, not evidence that an owner
model is generally inferior.

## Machine-readable decision

```text
PairedDatasets = 2
PlannedRoutes = 8
ContractComplete = TRUE
BoundedSmokeAdmissibleAfterRuntimeBinding = TRUE
SmokeExecuted = FALSE
CurrentDefaultOwnerEvidenceComplete = FALSE
RecoveryClaimAuthorized = FALSE
OwnerSuperiorityClaimAuthorized = FALSE
ExternalComparisonAuthorized = FALSE
AdditionalReplicationAuthorized = FALSE
BroadSimulationAuthorized = FALSE
SelectionAuthorized = FALSE
ConfirmationAuthorized = FALSE
```

Thus the next empirical action is at most the eight-route smoke. Expanded
replication is still inadmissible unless the smoke finds a decision-relevant
failure or a later prespecified precision target cannot be answered otherwise.

## Reproduction

- contract runner:
  `inst/validation/gpcm-owner-current-default-contract-p1r-0.2.3.R`;
- test:
  `tests/testthat/test-gpcm-owner-current-default-contract-p1r.R`;
- P1q dependency SHA-256:
  `8216884cb08948ae3be3b4134dacc07bcb88a635a6c96dce7e25f26d793dea73`;
- runner SHA-256:
  `9c2a4be23932826da729c34b0ccf3d7fcf225471ec193eabf49af050f49a8a12`;
- test SHA-256:
  `ba6cd2c8a6286ea3aa3bba22a120c7e7b9def4b5dcd8569fff6b7ff6f411dfb0`.
