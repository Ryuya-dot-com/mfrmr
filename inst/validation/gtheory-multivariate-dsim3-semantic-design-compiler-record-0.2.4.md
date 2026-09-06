# D-SIM-3 v4 shared semantic design-compiler record

Status: first shared-substrate layer qualified for all 21 profiles; covariance and distribution binding subsequently qualified, execution closed
Date: 2026-08-30
Contract: `MFRMR-GTHEORY-MV-DSIM3-SEMANTIC-DESIGN-COMPILER-V1`
Parent qualification-contract hash: `00cf1c34c0d3e70e4b2896b365f5592e04b00ef63bc6dede35d9bfc3bd94f762`
Parent qualification-manifest hash: `05d5bf2bfb0942ddb728aff31dce69de7298065081f3f268e18943074cd96755`
Compiler-contract hash: `67cb6077c0b0fb083362c0b7bae498be6695e61a0f84d1636f992479ef79f666`
Compiler-manifest hash: `dd69c9eb4f7b75641efb9f4b9bbfcee7818b8a645a7c70cdbc8f9b2551d74a3b`

## Result

One shared compiler now maps every frozen D-SIM-3 profile into typed object,
stratum, condition, assignment, observation-event, and missingness identities.
All 21 profiles pass the same compiler and assertion path. The implementation
contains zero scenario-specific branches.

| Quantity | Result |
|---|---:|
| frozen profiles compiled | 21/21 |
| design axes compiled | 9/9 |
| deferred generator axes | 3 |
| semantic rules | 22 |
| planned structural rows | 147,948 |
| scheduled observation rows after masks | 130,694 |
| outcome-blind omitted rows | 17,254 |
| generated responses | 0 |
| opened 855 streams | 0 |
| backend calls / fits | 0 / 0 |

The three deferred axes are `variance_regime`,
`cross_stratum_covariance`, and `response_distribution`. Consequently the
typed design compiler is qualified for 21/21 profiles while complete generator
semantics remain qualified for 0/21. These are different maturity statements.

## Orthogonal semantic roles

The compiler removes ambiguity by assigning each design axis one role:

- `balance` controls stratum-specific exposure from one global registered
  object universe;
- `crossing` controls object-by-condition assignment within a stratum;
- `condition_sharing` controls whether corresponding condition identities are
  shared, local, or explicitly mixed across strata;
- `observation_event` controls whether stratum scores have distinct, linked,
  or explicitly mixed event identities;
- `rater_count` is the number of ratings per object and stratum before repeats
  and missingness, not a claim about the number of globally unique raters; and
- `repeat_count` is replication per scheduled object-condition cell.

This separation permits, for example, a completely crossed condition layout
within each registered stratum exposure while object exposure remains
unbalanced across strata. It also prevents shared condition labels from being
mistaken for linked response events.

## Crossing and identity rules

Fully crossed profiles assign all declared condition slots. Partially crossed
profiles use a cyclic half-pool assignment: each object receives the declared
number of ratings from a pool twice that size, producing a connected incomplete
layout without a profile-specific exception. Nested profiles use condition
identities nested within object. The condition-sharing rule is then applied
orthogonally to those base identities.

Distinct events receive stratum-specific identities. Linked events reuse the
same object-slot-repeat event identity across every stratum in which that
object is registered. Mixed event profiles link the lower half of slots and
keep the remainder distinct. Pair audits verify the declared sharing pattern
directly rather than inferring it from facet count.

## Balance and missingness boundary

Balanced profiles register every object in every stratum. Moderate imbalance
uses exposure fractions from 1.0 to 0.8 over the ordered strata; severe
imbalance uses 1.0 to 0.5. The registered object identities remain global and
the smaller stratum sets remain overlapping.

`none` retains every scheduled observation. The `mcar_10` and `mcar_30`
profiles receive exact-rate, outcome-blind, deterministic rank masks for
compiler qualification. These masks prove row identity, denominator, and
support preservation; they are **not** evidence that stochastic MCAR
generation is implemented. Structural missingness omits the final condition
slot for even-numbered objects and retains at least one scheduled observation
in every registered object-stratum cell.

## Integrity and claim boundary

Each compilation binds the profile signature and scenario hash to registry
hashes for strata, objects, object-stratum exposure, assignments, condition
pair audits, and event pair audits. Exact replay is required. Mutated row
identities fail even if downstream hashes are recomputed. The compiler leaves
the caller RNG state unchanged.

This layer generates neither datasets nor responses. It qualifies no
covariance factor, response kernel, route adapter, terminal receipt, resource
controller, simulation result, or public support claim. The frozen 855
denominator remains unopened and feature maturity remains `specified`.

## Subsequent binding update

The next shared layer subsequently bound covariance regime, cross-stratum
covariance, and response distribution over these exact identities. All 84
component covariance/factor bindings and all 21 kernel contracts qualified
without RNG, response generation, PSD repair, or scenario-specific patches.
The following generic generator subsequently qualified response semantics for
21/21 profiles on one nonreserved shadow fixture each, while restoring caller
RNG state and leaving the reserved 855 band unopened. Route, receipt, and
resource layers remain later dependencies.
