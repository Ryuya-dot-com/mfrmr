# Fixed-calibration amended G4 current-source contract record

Status: `rules_frozen_candidate_unbound_confirmation_unopened`, 2026-08-25.

- Specification: `0.2.4-fixed-calibration-g4-current-source-boundary-evidence-v4`
- Contract: `mfrmr_fixed_calibration_g4_current_source_evidence_v4`
- Rules frozen before current-source execution: `TRUE`
- Current disjoint fixture identities frozen: `TRUE`
- Current execution opened: `FALSE`
- Candidate source identity bound: `FALSE`
- CORE-05 complete for current source: `FALSE`
- CORE-06 complete for current source: `FALSE`
- G4 exit complete for current source: `FALSE`
- G6 authorized: `FALSE`
- Public API authorized: `FALSE`

## Decision boundary

The 2026-08-22 G4 evidence remains an immutable historical result for its
exact nine-node payload and commit. This amended contract does not overwrite,
pool, or reinterpret that result. It prospectively defines the evidence that
the hardened current source must produce before CORE-05, CORE-06, and G4 can
close again.

The v2 and v3 current-source executions at commits `53f5f21` and `7afff78`
are also immutable and retained separately. They returned 44/49 and 48/49
passes, respectively, with complete failure rows. Because worker decision
logic changed after each result was viewed, modular-1009/1013 and modular-
1019/1021 are consumed and cannot authorize a later decision. This v4
contract is a new prospective boundary, not a retry or reinterpretation of an
earlier result.

The contract is frozen before binding a candidate commit or opening any
current execution result. Candidate binding requires a clean 40-character Git
commit, package version, source-tarball and file-registry hashes, production-
boundary registry hash, worker and test hashes, this contract's hash, and the
hosted runner plus both workflow hashes. No current-source result may be
inspected as confirmatory evidence until all twelve fields are bound to one
candidate.

## Scoring basis and disjoint identities

The promoted core basis remains one-scale RSM/PCM MML under an explicit
standard-normal prior and `quadrature_eap_v1`. The operational default is 31
Gauss--Hermite nodes and the minimum permitted scoring order is two.

Four new authoritative identities are frozen: RSM and PCM default-31
confirmations fitted with 13 integration nodes, plus RSM and PCM adversaries
whose source fits use one integration node but whose portable scoring basis
uses 31 nodes. Their modular-1031 and modular-1033 generators, changed Person
counts, new offsets, and new calibration/fixture identifiers are disjoint from
both the consumed v2 identities and the historical modular-997 fixtures.

The two known modular-997 nine-node identities are retained only as explicit
regression controls. They are marked previously used and cannot authorize the
current G4 decision. A passing historical control cannot replace either a new
default-31 or source-one result.

## Frozen denominator

The amended denominator contains 49 required cells and eleven numerical
rules. It covers:

- independent RSM/PCM probabilities, posteriors, and step ranks;
- default-31, explicit-nine control, and source-one/default-31 paths;
- algorithm, quadrature, sign, score-map, namespace, prior, persistence,
  locale, encoding, row/chunk-order, and artifact-weight boundaries;
- JML one-node fitted-object scoring, explicit one-node scoring refusal,
  purpose-specific readiness, and fitted-object weight refusal;
- complete interaction and scoring-setting replay plus the material-argument
  registry; and
- same-layout score, weight, facet-label, anchor, and quadrature checkpoint
  mismatches; hybrid stage behavior; cross-stage refusal; completed and
  continued pure-EM boundaries; corrupt/scalar refusal; and checked atomic
  replacement.

Every current cell is unopened. A failure is retained. If an evaluated
production implementation or decision rule changes, a new disjoint identity
is required; historical and earlier current cells are not pooled into the new
decision.

The hash-bound confirmation worker now declares exactly the same 49 cell IDs
in the same order and supplies one retained-result handler per cell. Candidate
binding checks both registries without executing them. This closes the
denominator-transport gap but does not itself open or pass any confirmation
cell.

## Execution order

After candidate binding, the next step is an isolated source-tarball execution
of all 49 cells, ordinary package tests, examples, vignettes, release-
readiness, and R CMD check against that same installed payload. The bound
hosted runner builds each platform's tarball once, binds it, checks that exact
file, and executes the worker against the package retained by that check.
Hosted macOS R release must pass first. Only then may Windows release and Linux
devel, release, and oldrel-1 run for the exact same commit. A separate
aggregation job must retain five complete receipts with a common commit,
production-boundary registry, and support registry before hosted completion is
recorded.

The 31-node small, medium, and operationally plausible resource ceilings are
regression limits, not public throughput promises. G6 and public API promotion
remain closed until the complete current-source result is recorded.

- `AmendedG4ContractFrozen=TRUE`
- `SupersededV2ExecutionRetained=TRUE`
- `SupersededV2PassedCells=44`
- `SupersededV2FailedCells=5`
- `SupersededV2IdentityReuseAuthorized=FALSE`
- `SupersededV3ExecutionRetained=TRUE`
- `SupersededV3PassedCells=48`
- `SupersededV3FailedCells=1`
- `SupersededV3IdentityReuseAuthorized=FALSE`
- `AmendedG4CurrentExecutionOpened=FALSE`
- `AmendedG4CandidateBound=FALSE`
- `AmendedG4DenominatorCells=49`
- `AmendedG4NumericalRules=11`
- `ConfirmationWorkerExactDenominatorImplemented=TRUE`
- `ConfirmationWorkerDeclaredCells=49`
- `ConfirmationWorkerExecutionOpened=FALSE`
- `CandidateBindingFields=12`
- `HostedExecutionRunnerBound=TRUE`
- `HostedMatrixAggregatorBound=TRUE`
- `HistoricalNineNodeControlAuthorizesCurrentG4=FALSE`
- `CORE05Complete=FALSE`
- `CORE06Complete=FALSE`
- `G4ExitComplete=FALSE`
- `G6Authorized=FALSE`
- `PublicAPIAuthorized=FALSE`
- `NextGate=G4-current-candidate-binding-and-isolated-execution`
