# D-SIM-3 planned-seed generation-adapter record

Status: shadow-qualified; final static launch-readiness reconciliation required
Date: 2026-08-31
Scope: parameterized seed forwarding and resource rebinding; no 856 execution

## Decision

Separate seed policy from the already qualified stochastic response generator
without changing or copying its data-generating logic. The adapter uses
`mfrmr_gtds3g_generate_profile()` as its sole stochastic core. It constructs a
request-specific core contract whose seed formula resolves to the exact
registered seed, while retaining the same component draws, response kernels,
missingness mechanism, and caller-RNG restoration.

Qualification has two deliberately different parts:

1. all 42 registered 856 generation requests are compiled as dry-run seed
   forwarding contracts, with no RNG initialization; and
2. the parameterized core is actually executed on the 21 nonreserved 854
   fixtures and must reproduce the parent generated-data and missingness-mask
   hashes exactly.

This closes an executable interface gap without using an exploratory outcome
to tune the interface.

## Frozen identity

| field | value |
|---|---|
| contract | `MFRMR-GTHEORY-MV-DSIM3-PLANNED-SEED-ADAPTER-V1` |
| contract hash | `b7f193e567e61b76bc19c2a9d8f559600ba4dd849e3eed57ff0aa08608721ac0` |
| manifest hash | `2e27bdd0f5e8988adf928959607064b5cefd9e80251317837ba4b0fcca09242b` |
| source SHA-256 | `2b06cdf226f0bb09dfd439a5d607474aba48603a607e6e2601a149e76c21bfd6` |
| parent generator contract | `92a6b8b1b0728bc33477e4ec6737c0a3c448f8934708120cbc8aeff51025b2d4` |
| parent generator manifest | `c334578b20b886d158f5fd1aa82c3c1bd9e24f64e7e9d1d4d1c25e7f868da46a` |
| parent generator source | `6a2e5cfbdb837079ec07650b4494af068fa7cbbcafb3fceae985e5d7fa4e2bc0` |
| parent request manifest | `69cf70189e1a72fbdda3af4fcca5d37873ef3e5f23d96c0d2cb4b1b87e8e1cef` |
| parent no-go reconciliation | `b3b5404b2b262941046cfa7a85866a1b7432f3e5a87cb759f3b61a6a345c90b9` |

## Qualification result

| item | result |
|---|---:|
| existing stochastic core reused | 1/1 |
| copied stochastic-core functions | 0 |
| exact planned generation requests | 42/42 |
| exact 856 seed forwarding dry-runs ready | 42/42 |
| planned RNG streams opened during qualification | 0/42 |
| shadow equivalence profiles | 21/21 |
| generated-data hashes identical | 21/21 |
| missingness-mask hashes identical | 21/21 |
| exact 854 seed forwarding observed | 21/21 |
| caller RNG state restored | 21/21 |
| resource request identities rebound | 5/5 |
| integrated workload capacity claims | 0/5 |
| qualification gates | 8/8 |

The five resource operations now distinguish the parameterized planned-seed
generator, the unchanged fit and metric workers, the parameterized dataset
pipeline, and the registered parameterized scheduler. This is operation
identity and enforcement plumbing, not a claim that the full workload will
finish within a particular time or memory budget.

## Execution guard

The planned execution entry point exists but fails closed unless supplied a
future typed 10/10 readiness manifest bound to this exact adapter manifest.
The current 9/10 no-go reconciliation cannot satisfy that interface, and a
boolean or caller assertion cannot self-authorize it. Qualification therefore
opened no 856 stream and created no planned response or terminal receipt.

This guard is package-internal provenance, not an operational-owner decision.
Users remain responsible for interpreting the eventual analysis; the package
is responsible for not silently substituting an unqualified generation path.

## Boundary preserved

- no parent generator source or frozen manifest was mutated;
- no stochastic draw, missingness rule, or response kernel was duplicated;
- all actual qualification draws used 854100001--854100021;
- all 856 requests remained dry-run identities with zero responses;
- no backend, fit, metric, recovery comparison, or terminal receipt occurred;
- integrated workload capacity remains unclaimed and nonblocking; and
- simulation validation and public support remain false.

## Next bounded action

Run one final static reconciliation that adds this exact adapter manifest to
the existing environment, request, fit/metric, terminal, resource, and receipt
identities. If and only if all ten technical gates pass, issue a typed internal
readiness manifest that the adapter can validate. Do not open 856 in the same
step; launch remains a subsequent, separately observable transition.
