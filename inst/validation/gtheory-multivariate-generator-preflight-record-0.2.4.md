# Draft.85c2 multivariate G-theory generator preflight record

Date: 2026-08-24
Scope: repository-only fixture generation, RNG-state binding, and seed
isolation
Result: implementation and fixture replay ready; recovery execution remains
unauthorized

## Outcome

Draft.85c2 implements the c1 multivariate Gaussian response generator on 12
nonreserved fixtures. The replay contains 48 component-state rows and covers
all eight regular scenarios plus the four PSD/residual/scaled-rank boundary
scenarios. The two structural negative controls are deliberately not
generated.

Ten focused tests and 106 expectations pass without failure, error, warning, or
skip.

The combined Draft.85a0, b0, b1, c0, c1, and c2 suite passes 55 tests and 847
expectations without failure, error, warning, or skip.

No c1 pilot, confirmation, or negative-control seed was opened. No backend was
called, no candidate estimate was produced, and no recovery summary or
threshold comparison was computed.

The replayed identities are:

```text
ManifestHash                   1bc7f3dd126803ab7d6165a8c81e6fe1a9e8ad7fa0e13ebdd5f7c4993f718308
ManifestCoreHash               eeeb6ca51359909da97fca065233fe44c11ef6b9f324803466a408f0f14b09d2
FixtureRegistryHash            28d8203a4372e908c2a62775c0e246b905cb591f5635f83e4745a0bf452f66dd
FixtureReplayRegistryHash      824e6fc2f052a5801947a9dbde4020d02ebe608ce8665dbf12b7635c1b7b3b0d
ComponentStateRegistryHash     31083ab9ad40cc935e40c6dc8bf26455b1f44bf12c8aa161ba8989c9b92522c6
ImplementationIdentityHash     97c219227fc4f73b2ce05eaa00a07eb42b23e074c8ab7357f5e1f47eff1acb78
```

These are replay identities, not an external timestamp, preregistration, or
execution authorization.

## Coverage and RNG disposition

The fixture registry uses `854000001:854000012`, outside every c1 plan seed.
The exact structural row counts are retained: 720/240/240/576 for the four
two-stratum regular assignments, 1080/360/360/864 for the three-stratum
regular assignments, and the registered balanced row counts for the four
boundary references.

Every fixture records four independent component starts. `Object` owns the
initialized L'Ecuyer-CMRG state, followed by successive substreams for
`Rater`, `Object:Rater`, and `Residual`. Draw counts are derived from sorted
union-group count times stored factor-column count; residual uses one draw per
canonical structural row. All 48 start/end, latent-draw, and effect hashes are
finite and present.

Rank-one and rank-two registered factors remain one- and two-column factors.
The scaled interaction factor remains the exact stored three-column factor,
including its small third column. No PSD repair or factor recomputation occurs.

Ambient `Mersenne-Twister` and `Wichmann-Hill` caller states produce identical
fixture objects. In both cases all RNG-kind coordinates and the exact caller
state are restored after return.

## Information boundary

The candidate-shaped table contains row/group identifiers and `Score` only.
Fixed means and generated component/residual effects are stored separately for
fixture auditing. Because a single in-memory object still holds both sides,
this establishes column separation but not process truth blindness.

The c1 plan remains unchanged: its top-level
`GeneratorImplementationReady=FALSE`, and every seed-policy
`FixtureRNGStateHashReady` value is false. The c2 manifest reports the
corresponding implementation/fixture states as true because it binds a
successor preflight; neither object authorizes a planned response.

## Disposition

Generator implementation, fixture state binding, caller-state restoration,
and plan-seed isolation are ready. Backend qualification, external freeze,
pilot and confirmation authority, denominator accounting, recovery evidence,
estimation, inference, decision, and public support remain false.

Draft.85c2 adds no public export, help topic, vignette, NEWS entry, public
roadmap entry, or support-envelope claim. ConQuest at `/Applications/ConQuest`
was not invoked because this preflight executes no estimator.
