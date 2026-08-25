# Draft.85c0 independent multivariate G-theory K-oracle contract

Status: repository-only population-map and likelihood-oracle preflight,
2026-08-24.

Draft.85c0 adds an implementation path that does not fit a model and does not
use the Draft.85b1 formula parser or either mixed-model backend. Its purpose is
to detect common parser, grouping, covariance-coordinate, likelihood, and
truth-joining errors before any finite-sample recovery study is designed.

## Three separated layers

The contract has three layers that may not be collapsed.

1. A neutral design contains unique `RowId`, ordered stratum labels and
   integer `StratumCode`, one integer `GroupCode` column per semantic
   component, an exact one-hot fixed design, and a finite response. It contains
   no covariance truth, latent effects, boundary class, scenario truth, seed
   role, formula, or backend object.
2. The independent core consumes only that neutral design and a separately
   supplied covariance point. It constructs K matrices, the covariance-
   coordinate derivative design, Gaussian objectives, scores, and local
   expected information using base matrix operations.
3. A bridge under test translates a point-fit-eligible Draft.85b1
   specification or fit into the neutral identities. The bridge is not part of
   the oracle and must reproduce Draft.85b1 row, fixed-design, random-block,
   component-order, and covariance-design identities exactly.

A static independence audit rejects oracle-core calls to `mfrmr_gtvb_*`,
`model.matrix`, `reformulas`, `lme4`, `glmmTMB`, or `VarCorr`. Nonstatistical
hashing is the only shared primitive.

## Independent K constructions

For row `i` in stratum `s_i`, the marginal covariance is

```text
K[i,j] = sum_c 1(GroupCode[c,i] = GroupCode[c,j])
                   Gamma_c[s_i,s_j]
         + sigma2 * 1(i = j).
```

The same K is formed by two distinct paths:

- a literal pairwise group/stratum predicate; and
- a component design route
  `Z_c (I_group x Gamma_c) Z_c' + sigma2 I`.

Their row-bound matrices and hashes must agree within `1e-12`. The second
route does not reuse the first route's coordinate matrices.

For every lower-triangle component coordinate, the core independently forms

```text
K[c,s,t][i,j] = 1(same component group) *
                1((s_i,s_j) is (s,t) or (t,s)).
```

Together with `Residual[I]`, these form

```text
D = [vech(K_1), ..., vech(K_q)]
vech(V) = D eta.
```

Both singular-value and squared-Gram-scale rank calculations are retained.
`KMatrixConstructible` and `CovarianceDesignIdentified` are different states:
a total K can be positive definite because of the residual even when a
component is not identified or lies on a boundary.

## Population-map round trip

At a separately supplied covariance point, the prototype projects
`vech(V)` through the full-rank D map and compares the resulting coordinates
with the supplied semantic coordinates. This is called a population-map
round-trip, not bias, RMSE, estimator recovery, or sampling evidence. Its
mechanical tolerances are `1e-9` for coordinates and K reconstruction.

Component covariance names, order, and exact stratum dimnames must already
match the neutral design. The oracle never reorders a supplied reference to
fit an estimate. Eigenvalues below `-tolerance` are rejected. Negative modes
within tolerance are retained, never repaired to a nearest PSD matrix, and
classified nonregular.

`RegularInteriorReady` is a covariance-point numerical regularity gate. A
component is operationally boundary-like when its minimum eigenvalue is at or
below the absolute boundary tolerance or when it loses effective rank under
`lambda > tolerance * max(1, lambda_max)`. This is not an exact claim about
membership in the boundary of the PSD cone and is not invariant to arbitrary
changes of measurement units. It says nothing by itself about derivative
identification, optimizer convergence, information rank, or precision. A
rank-deficient component is retained: its K and objective may be available
while `RegularInteriorReady=FALSE`.

## Objective and local-information oracle

With K positive definite and X full rank, the core profiles the stratum means
and computes the complete Gaussian criteria

```text
ML   = -0.5 * [n log(2 pi) + log|K| + r' K^-1 r]
REML = -0.5 * [(n-p) log(2 pi) + log|K| +
               log|X' K^-1 X| + r' K^-1 r].
```

It also computes analytic K-coordinate scores and the local expected-
information matrices

```text
I_ML[j,k]   = 0.5 tr(K^-1 K_j K^-1 K_k)
P           = K^-1 - K^-1 X (X'K^-1X)^-1 X'K^-1
I_REML[j,k] = 0.5 tr(P K_j P K_k).
```

Finite-difference score agreement and full local-information rank are
mechanical oracle tests. `LocalExpectedInformationComputed=TRUE` means only
that both dense trace formulas were evaluated. The aggregate
`LocalExpectedInformationReady` additionally requires an identified K-
derivative design, a regular covariance point, and full numerical rank for
both the ML and REML matrices. Criterion-specific readiness would require
separate future flags. Condition numbers are diagnostics, not precision,
standard-error, power, or coverage criteria.

The ML matrix is the covariance-coordinate Fisher block of the joint Gaussian
model with fixed effects treated jointly. Mean and covariance scores are
Fisher-orthogonal, so this is a regular first-order efficient-information
diagnostic. It is not observed information or the exact finite-sample expected
Hessian of the profiled ML criterion. The REML matrix is the expected
information of the restricted likelihood.

The b1 bridge compares only semantic covariance matrices, stratum means,
criterion, row/design identity, and full backend-reported log likelihood. It
does not call a backend deviance function or compare raw Cholesky/theta
coordinates. A successful comparison is likelihood-wiring evidence, not an
independent estimator or recovery validation.

## Candidate sealing and reference-join mechanics

The candidate design and response are hashed before any reference covariance
is joined. Candidate receipt and reference join are separate calls. The join
verifies only that the sealed candidate-receipt hash is unchanged; this is
reported as `ReferenceJoinIntegrityReady`. It does not prove that an upstream
caller never used the reference while producing the candidate. Process-level
truth blindness and provenance remain a Draft.85c1 responsibility. Component
swaps and covariance-coordinate swaps remain visible.

Candidate receipts admit only four monotone state tuples:

| fit | estimate | point gate | allowed failure stage |
| ---: | ---: | ---: | --- |
| 0 | 0 | 0 | `backend_fit` |
| 1 | 0 | 0 | `optimizer`, `component_extraction`, `identity` |
| 1 | 1 | 0 | `optimizer`, `regularity`, `identity` |
| 1 | 1 | 1 | `none`, with code `none` |

Every neutral design, covariance point, bridge, derivative object, backend
specification, backend fit, and candidate receipt uses an exact top-level
field/class/attribute schema. Unknown fields and attributes fail closed;
extension requires a contract revision. Nested covariance matrices and
candidate estimates are validated under the same exact schemas.

Every planned coordinate remains in the ledger when a fit is absent or a
point gate fails. `Planned`, `FitReturned`, `PointGatePassed`, and
`MetricAvailable` are separate. The ledger records signed, absolute, squared,
and, only away from zero, relative deterministic errors. These are metric-
schema mechanics; a one-dataset difference is not sampling bias. Multiple
backends on one dataset are paired methods, not independent replications.
`AtomicRegistryMatchReady` proves only an exact match between a supplied
atomic registry and sealed receipts. Because that registry is not yet a
preregistered and frozen ADEMP plan, `DenominatorAccountingReady=FALSE` in
Draft.85c0 even when the atomic match is exact.

Structurally absent rows are handled only as a principal submatrix: rebuilding
K on the retained `RowId` set must equal subsetting the full K. A response
`NA`, imputation, MAR/MNAR likelihood, or complete-case recovery is outside
Draft.85c0.

## Readiness boundary

The following mechanics states may be true:

```text
OracleSpecificationReady
NeutralPayloadSchemaReady
IndependentKOracleReady
CovarianceDesignOracleReady
PopulationRoundTripMechanicsReady
ObjectiveOracleReady
LocalExpectedInformationComputed
LocalExpectedInformationReady
OracleIndependenceReady
CandidateStageTupleReady
ReferenceJoinIntegrityReady
RecoveryMetricSchemaReady
AtomicRegistryMatchReady
IndependentLikelihoodOracleReady
```

They do not promote the following states:

```text
RecoveryDesignFrozen       = FALSE
RecoveryThresholdFrozen    = FALSE
RecoveryExecuted           = FALSE
RecoveryEvidenceReady      = FALSE
DenominatorAccountingReady = FALSE
EstimatorRecoveryReady     = FALSE
EstimationReady            = FALSE
InferenceReady             = FALSE
UncertaintyReady           = FALSE
CoefficientEligible        = FALSE
DecisionReady              = FALSE
PublicSupportReady         = FALSE
```

## Ordered next gate

Draft.85c1 must freeze a truth-blind ADEMP registry, pilot and confirmation
seed bands, denominator rules, component-specific metrics, boundary handling,
and Monte Carlo precision before finite responses are inspected. It must cover
two and three strata, sparse and unequal assignments, structural row absence,
local-diagonal reduction if pursued, and PSD/rank boundaries. Allocation
operators, composite G/Phi, full-refit uncertainty, and any missingness-
mechanism claim remain separate gates. No c0 result belongs in exports, help,
NEWS, or the public support envelope.
