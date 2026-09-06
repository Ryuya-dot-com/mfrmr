# D-SIM-3 v4 covariance-regime and response-distribution binding record

Status: second shared-substrate layer qualified for all 21 profiles; generic stochastic response-generation adapter subsequently qualified on shadow streams, reserved execution closed
Date: 2026-08-30
Contract: `MFRMR-GTHEORY-MV-DSIM3-COVARIANCE-DISTRIBUTION-BINDING-V1`
Parent compiler-contract hash: `67cb6077c0b0fb083362c0b7bae498be6695e61a0f84d1636f992479ef79f666`
Parent compiler-manifest hash: `dd69c9eb4f7b75641efb9f4b9bbfcee7818b8a645a7c70cdbc8f9b2551d74a3b`
Binding-contract hash: `293dd2af3e8f13282ae545efa6063306f4cf59d4d7bf1027dca57de9376ae1c4`
Binding-manifest hash: `8fcdc0297a0f09c0525a10f8c1a1ffca4310f7b7509f4df3f793f14f68151625`

## Result

One shared binding now maps the three generator axes deferred by the semantic
design compiler—variance regime, cross-stratum covariance, and response
distribution—onto all 21 exact compiled profiles. The layer contains no
scenario-specific patch and does not open an RNG stream or generate a
response.

| Quantity | Result |
|---|---:|
| frozen profiles bound | 21/21 |
| component covariance bindings | 84/84 |
| PSD audits passed | 84/84 |
| covariance-factor reconstructions passed | 84/84 |
| response-kernel contracts bound | 21/21 |
| Gaussian / heavy-tailed / ordinal-aggregate kernels | 8 / 7 / 6 |
| boundary component blocks | 10/84 |
| maximum factor-reconstruction error | 1.44e-13 |
| scenario-specific patches | 0 |
| generated responses / opened 855 streams | 0 / 0 |
| backend calls / fits | 0 / 0 |

All factors are produced from their audited covariance matrices without a PSD
repair. An indefinite matrix fails before factorization. Exact replay binds
each covariance block and response kernel to the parent compiler identity;
mutating a matrix still fails after downstream hashes are recomputed.

## Cross-stratum identity contract

Cross-stratum covariance is not applied merely because a profile has multiple
facets or strata. Each component uses a declared identity source:

- Object covariance uses the common registered object universe;
- Rater covariance uses compiled condition identity;
- Object-by-Rater covariance uses the exact composite object-by-condition
  identity; and
- Residual covariance uses compiled observation-event identity.

The latter three overlap matrices are normalized Gram matrices and therefore
must be PSD. Identical conditions can carry Rater and Object-by-Rater
covariance, while disjoint conditions cannot. Linked events can carry residual
covariance, while distinct events cannot. Partial or mixed sharing is inherited
from the exact compiled identities instead of being reconstructed from a
scenario label.

This is a multivariate G-theory covariance contract across registered strata;
it is not evidence for multiple latent trait dimensions. Facet count, stratum
count, covariance rank, and latent dimension remain separate concepts.

## Variance and covariance regimes

The four declared variance regimes have explicit component meanings:

- `regular_interior` keeps every component away from the boundary;
- `near_zero_component` places the Rater variance at 1e-6;
- `dominant_component` makes the Object variance at least nine times the next
  largest component; and
- `near_singular_covariance` places the Object block at the PSD boundary,
  either through cross-stratum correlation or, under zero covariance, through
  one 1e-8 marginal variance.

Zero covariance produces diagonal blocks. Positive and negative covariance
use PSD-preserving correlation constructions modulated by the identity-overlap
matrix. The minimum audited eigenvalue is 1e-8; no negative eigenvalue is
clipped or repaired.

## Response-kernel boundary

The Gaussian kernel is the identity transformation of a standard-normal
innovation. The heavy-tailed kernel specifies a standardized Student-t
innovation with five degrees of freedom and unit variance. The
ordinal-aggregate kernel thresholds a standard-normal latent aggregate at
`-1.25`, `-0.35`, `0.35`, and `1.25`, returning scores 0 through 4.

The ordinal kernel is a deterministic distributional stress contract only. It
is not GPCM, GRM, PCM, RSM, or another item-response model; it contains no item
slope, step, threshold-owner, or latent-dimension semantics. Consequently all
21 kernel bindings report `IrtResponseModel = FALSE` and
`StochasticDrawQualified = FALSE`.

## Claim boundary

This layer qualifies covariance/distribution *binding*, not stochastic
generator semantics. It has not drawn component effects or innovations,
applied stochastic MCAR, combined them into observed responses, called a fit
route, emitted a terminal receipt, or enforced a resource scope. Complete
generator semantics therefore remain qualified for 0/21 profiles. The frozen
855 denominator remains unopened and overall feature maturity remains
`specified`.

## Subsequent generator update

The next shared layer subsequently generated one nonpromoting shadow fixture
for each of the 21 profiles on seeds 854100001--854100021. It qualified 84/84
unit-to-effective covariance identities, generated every component identity
once, applied outcome-independent fixed-count randomized MCAR to nine profiles,
and exactly replayed 130,694 retained responses while restoring caller RNG
state. No 855 identity, backend, or fit was opened. Generic route/receipt and
resource-controller adapters were the remaining pre-execution dependencies. A
successor has since qualified 50/50 route admissions and all 13 terminal
semantics without treating admission as terminal. The five-scope resource
controller is now the remaining dependency.
