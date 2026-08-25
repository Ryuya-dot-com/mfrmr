# Draft.85c2 multivariate G-theory generator preflight contract

Date: 2026-08-24
Scope: repository-only, nonreserved fixture generation
Public status: unsupported

## Purpose and boundary

Draft.85c2 implements the response generator specified by Draft.85c1 without
opening any planned pilot, confirmation, or negative-control seed. It is a
generator preflight, not a recovery experiment. It fits no backend, joins no
candidate estimate to truth, computes no recovery metric, and cannot authorize
pilot execution.

The authoritative upstream identity is the unchanged Draft.85c1 plan with
`PlanHash` `51f6d05a596cf05157b7599f48f29c144038e23b89cad045c47d8560d370cac2`.
Draft.85c2 does not rewrite c1 readiness: c1's top-level
`GeneratorImplementationReady` remains false, and every c1 seed-policy
`FixtureRNGStateHashReady` value remains false in the historical c1 object.
The c2 manifest records that a separately bound implementation and fixture
replay now exist.

## Nonreserved fixture registry

The registry contains exactly the 12 recovery-executable c1 scenarios in c1
order. It excludes both derivative-rank structural controls. Fixture seeds are
`854000001:854000012`; these do not occur in the c1 851/852/853 million seed
bands and are never eligible for a recovery denominator.

Each fixture binds:

- scenario, assignment, coordinate-layout, and reference identity;
- the exact deterministic structural-row count and hash;
- one fixture-only seed; and
- explicit `PlanSeedCollision=FALSE` and
  `RecoveryDenominatorEligible=FALSE` states.

Changing a fixture seed, row identity, scenario binding, or eligibility state
invalidates the canonical registry. Supplying a negative-control or unknown
scenario to the generator is rejected.

## Exact generator algorithm

For each fixture, Draft.85c2 performs the following operations:

1. Replays `mfrmr_gtvd_assignment_rows()` and verifies the c1 structural-row
   hash before drawing anything.
2. Loads the registered fixed mean for each stratum.
3. Loads the stored factor for `Object`, `Rater`, and `Object:Rater`. The factor
   grid must be complete, finite, and in registered row/column order. No
   Cholesky recomputation, eigenbasis replacement, jitter, or PSD repair is
   allowed.
4. Sets `RNGkind("L'Ecuyer-CMRG", "Inversion", "Rejection")` and
   `set.seed(FixtureSeed)`. `Object` uses the initial state; `Rater`,
   `Object:Rater`, and `Residual` use three successive
   `parallel::nextRNGSubStream()` states derived from the preceding component
   start state.
5. For each non-residual component, sorts the union group identifiers in radix
   order. For every group it draws `z ~ N_r(0,I_r)` in ascending stored factor-
   column order and computes `b=Lz`. Thus rank-one and rank-two factors consume
   one and two draws per group, while the scaled three-column factor retains
   all three stored columns.
6. On the residual substream, draws one standard normal in canonical `RowId`
   order and multiplies it by the stored residual factor.
7. Forms `Score = fixed mean + Object + Rater + Object:Rater + Residual`.

The generator records 48 component-state rows: 12 fixtures times four
components. Each row binds start state, end state, draw count, latent-draw
hash, and generated-effect hash.

## Caller RNG restoration

The caller's three RNG-kind coordinates and `.Random.seed` presence/value are
saved before generation and restored on exit, including error exits. Fixture
output is identical under different ambient RNG kinds and caller states. The
restoration contract is tested separately from the generated-state hashes.

## Candidate and truth-side data

The candidate-shaped fixture table contains only:

```text
RowId Stratum Object Rater ObjectRater Replicate Score
```

Fixed means, component effects, residual effects, seed, and reference identity
remain in separate truth-side audit structures. This is a column-separation
test, not process-level truth blindness: the same in-memory generation object
contains both tables. A future candidate executor still requires process
isolation and a withheld reference vault.

## Identity and fail-closed states

The content-only manifest core binds the fixture registry, 12 fixture replay
rows, and 48 component-state rows. Implementation identity separately hashes
all 14 c2 functions. Keeping implementation identity outside fixture content
hashes prevents a self-referential hash cycle while the full `ManifestHash`
binds both.

Literal source roots pin the content-only core and three registries. Rehashed
mutation of candidate data, fixture seeds, component state, or readiness does
not create a canonical manifest.

The c2 disposition is:

```text
GeneratorImplementationReady       = TRUE
FixtureRNGStateHashReady            = TRUE
CallerRNGRestorationReady           = TRUE
PlanSeedIsolationReady              = TRUE
PilotExecutionAuthorized            = FALSE
ConfirmationExecutionAuthorized     = FALSE
BackendQualificationReady           = FALSE
RecoveryExecuted                    = FALSE
RecoveryEvidenceReady               = FALSE
EstimationReady                     = FALSE
InferenceReady                      = FALSE
DecisionReady                       = FALSE
PublicSupportReady                  = FALSE
```

No ConQuest, lme4, or glmmTMB process is invoked. The configured local
ConQuest installation at `/Applications/ConQuest` remains reserved for a
future comparison lane whose estimand and execution contract actually include
ConQuest.

The next admissible gate is not pilot generation. It is environment repair,
an externally anchored content receipt, and an authorization-bound adapter
that releases only candidate data while retaining fixture/recovery seed and
truth separation. Accuracy thresholds must still be supplied from independent
grounds before confirmation authorization.
