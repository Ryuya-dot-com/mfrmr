# D-SIM-3 v4 generic response-generator adapter record

Status: third shared-substrate layer qualified for all 21 profiles on nonreserved shadow streams; route/receipt successor qualified, resource layer next, reserved exploration closed
Date: 2026-08-31
Contract: `MFRMR-GTHEORY-MV-DSIM3-RESPONSE-GENERATOR-ADAPTER-V1`
Parent binding-contract hash: `293dd2af3e8f13282ae545efa6063306f4cf59d4d7bf1027dca57de9376ae1c4`
Parent binding-manifest hash: `8fcdc0297a0f09c0525a10f8c1a1ffca4310f7b7509f4df3f793f14f68151625`
Generator-contract hash: `92a6b8b1b0728bc33477e4ec6737c0a3c448f8934708120cbc8aeff51025b2d4`
Generator-manifest hash: `c334578b20b886d158f5fd1aa82c3c1bd9e24f64e7e9d1d4d1c25e7f868da46a`

## Result

One generic adapter now composes the compiled row/event identities, covariance
bindings, response kernels, and missingness declarations for all 21 frozen
profiles. Qualification uses exactly one nonpromoting shadow fixture per
profile in the nonreserved 854 band. It does not open or replace any seed in
the reserved 855 exploratory denominator.

| Quantity | Result |
|---|---:|
| frozen profiles generated | 21/21 |
| nonreserved shadow seeds | 854100001--854100021 |
| planned structural rows | 147,948 |
| shadow responses retained | 130,694 |
| shadow responses omitted | 17,254 |
| unit covariance audits | 84/84 |
| unit-factor reconstructions | 84/84 |
| unit-to-effective covariance implications | 84/84 |
| randomized fixed-count MCAR profiles | 9/9 |
| maximum unit-factor reconstruction error | 1.44e-13 |
| maximum effective-covariance implication error | 1.40e-13 |
| scenario-specific patches | 0 |
| exploratory 855 datasets / responses | 0 / 0 |
| backend calls / fits | 0 / 0 |

Every profile uses the same generator and assertion path. Exact replay
reproduces the generated-data hash and the caller's RNG kind and state are
restored after both generation and validation.

## Unit and effective covariance

The adapter distinguishes two quantities that must not be conflated:

- **unit covariance** governs the multivariate draw for one shared Object,
  condition, Object-by-condition, or event identity; and
- **effective covariance** is the aggregate cross-stratum covariance after the
  compiled identity overlap is applied.

For every component and profile, the adapter verifies

`EffectiveCovariance = UnitCovariance * IdentityOverlap`

element by element. This prevents partial condition/event sharing from
attenuating cross-stratum covariance twice. It also permits a disjoint identity
set to have a valid latent unit covariance contract while contributing zero
effective covariance to the observed cross-stratum aggregate.

Object effects use `ObjectId`; Rater effects use `ConditionId`;
Object-by-Rater effects use the exact `ObjectId/ConditionId` composite; and the
response innovation uses `EventId`. One multivariate draw vector is generated
per component identity, then reused for every repeated assignment carrying the
same identity and stratum.

## Response construction

Object, Rater, and Object-by-Rater effects are Gaussian. Residual is not drawn
as an additional component and then duplicated by a separate error term; it is
the response innovation itself:

- Gaussian profiles use a Gaussian innovation;
- heavy-tailed profiles use a covariance-standardized multivariate Student-t
  innovation with five degrees of freedom; and
- ordinal-aggregate profiles use a Gaussian latent innovation, standardize the
  total latent aggregate by its declared marginal variance, and apply the
  frozen five-score thresholds.

The ordinal output remains a distributional stress fixture, not GPCM, GRM, or
another IRT model.

## Missingness and RNG contract

Each profile receives independent L'Ecuyer-CMRG substreams in the fixed order
Object, Rater, Object:Rater, Residual, and Missingness. Nine `mcar_10` or
`mcar_30` profiles use a uniform random rank mask conditional on the exact
frozen omission count. The mask never inspects potential or observed response
values and performs no support repair. Thus it is outcome-independent
fixed-count MCAR; it is not a claim about unconstrained Bernoulli missingness.

`none` and structural profiles retain the compiler's deterministic mask. All
rows stay in the typed structural denominator, and omitted rows receive no
observed score. Randomization can therefore be replayed without turning a
scenario row or a missing response into a new dataset.

## Claim boundary

Full generator semantics are qualified for 21/21 profiles only on these 21
shadow fixtures. This is implementation qualification, not an exploratory
multiverse result, recovery study, Monte Carlo estimate, or simulation-
validation claim. The 42 registered exploratory attempts, their 855 identities,
route units, terminal denominator, and confirmation rules remain unopened.
Feature maturity remains `specified` and public support remains false.

## Successor dependency

The generic shared-dataset route-admission and terminal-receipt successor has
now qualified all 50 candidate route templates and all current frozen no-call
dispositions without calling a backend. It corrects an important temporal
distinction in this earlier record: admission itself is not terminal. Admitted
candidate units retain zero terminal receipts until an attempt reaches a real
terminal outcome; already frozen no-call units receive exactly one receipt.
Enforcement and receipting of the five resource scopes remains the next shared
dependency. Reserved 855 execution cannot begin until that layer passes.
