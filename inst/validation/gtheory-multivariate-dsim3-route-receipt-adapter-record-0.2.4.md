# D-SIM-3 v4 shared-dataset route and terminal-receipt adapter record

Status: fourth shared-substrate layer qualified; resource controller next, reserved exploration closed
Date: 2026-08-31
Contract: `MFRMR-GTHEORY-MV-DSIM3-ROUTE-RECEIPT-ADAPTER-V1`
Parent generator-contract hash: `92a6b8b1b0728bc33477e4ec6737c0a3c448f8934708120cbc8aeff51025b2d4`
Parent generator-manifest hash: `c334578b20b886d158f5fd1aa82c3c1bd9e24f64e7e9d1d4d1c25e7f868da46a`
Parent execution-plan hash: `b91ab4229203efc15a3ca9421256d81ae7331143e42f845b5c6a879575552de7`
Route/receipt-contract hash: `0b74d833dc9bff44e3eded32261258b8dbd5ca6a2a30805c871d2cc22c9d0129`
Route/receipt-manifest hash: `6a59dc1a7874f731554baff7a134b8b52ad18614e26ee80470d08ffbd8372e9f`

## Result

One generic adapter now transforms each generated shadow fixture into the
exact observed-row schema needed by every frozen qualification-candidate route.
It preserves the generated-data identity when the same fixture is projected to
multiple routes and estimands. It neither treats a projection as another
dataset nor calls an estimator.

| Quantity | Result |
|---|---:|
| shadow fixtures bound | 21/21 |
| candidate route admissions | 50/50 |
| restricted-lme4 route templates | 8/8 |
| separate-univariate route templates | 42/42 |
| route-payload row projections | 291,908 |
| route-payload partitions | 102 |
| terminal-state semantics qualified | 13/13 |
| valid terminal schema probes | 12/12 |
| invalid `unrecorded_invalid` sentinel rejections | 1/1 |
| shadow generation-complete receipts | 21 |
| frozen no-call route receipts | 160 |
| current terminal receipts | 181 |
| correctly open units | 92 |
| accounting units satisfying present-tense cardinality | 273/273 |
| exploratory 855 datasets / responses | 0 / 0 |
| backend calls / fits / metrics | 0 / 0 / 0 |

The 291,908 payload rows are repeated route projections of observed rows. They
are not independent observations or generated datasets. The adapter generates
each profile once per qualification pass and binds all candidate route
templates for that profile to one `ShadowFixtureId` and one shared generated-
data hash.

## Route admission is not terminal completion

The frozen plan has 50 qualification-candidate route units: eight restricted-
lme4 templates and 42 separate-univariate templates. Every one now receives a
typed route payload and the nonexecuting admission state
`adapter_qualified_backend_call_withheld`.

Admission proves interface adequacy only. It does not assert that the working
model is correctly specified for every stress distribution, that a backend
will converge, or that a metric will be available. Heavy-tailed and ordinal-
aggregate fixtures therefore remain in their frozen eligible route
projections; the adapter does not silently narrow the coverage population to
Gaussian outcomes. Those stress fits, when eventually attempted, must receive
their own terminal outcome and diagnostic interpretation.

Most importantly, admission is not encoded as a terminal state. Before a
backend attempt, each of these 50 units has exactly one admission record and
zero terminal receipts. Inventing a `complete`, `failure`, or `not attempted`
terminal here would turn an interface check into fabricated execution evidence.

## Present-tense terminal accounting

The adapter materializes only terminal states already knowable at this stage:

- 21 nonpromoting shadow fixtures have `generation_complete`; these receipts
  do not enter the registered 855 exploratory dataset denominator;
- 40 deliberately invalid negative-control route units have
  `prefit_rejected_as_planned`;
- eight univariate-closure route units have `not_applicable_as_frozen`; and
- 112 route units whose design-specific or custom contract is absent have
  `missing_contract_block_as_frozen`.

The latter 160 receipts are part of the frozen 210-route denominator and cannot
be deleted or replaced. The 50 admitted candidate routes remain open with zero
terminal receipts. All 42 planned 855 dataset attempts likewise remain open
with zero terminal receipts because none has begun. Together with the 21
shadow qualification units, this gives 273 accounting units: 181 currently
terminal units have exactly one receipt and 92 open units have exactly zero.

This is the temporally correct interpretation of the execution contract's
exactly-one rule: one receipt is required when a registered unit becomes
terminal, while a missing receipt for an open, never-attempted unit must not be
imputed as failure. Duplicate receipts, unknown units, invalid sentinels, and
premature candidate terminal receipts fail closed.

## Terminal schema qualification

The generic constructor and validator cover all 12 valid dataset/route
terminal states. Resource-limit states bind the declared resource-scope
metadata, but no timeout or memory enforcement is claimed here. The thirteenth
registry row, `unrecorded_invalid`, is qualified by demonstrating that it
cannot produce a receipt. Schema probes are explicitly nonreceipts and do not
enter any denominator.

## Claim boundary and next dependency

This layer qualifies route payload construction, admission semantics, terminal
schema semantics, and current no-call accounting. It is not a backend-fit,
resource-enforcement, recovery, Monte Carlo, simulation-validation, inference,
decision, or public-support result. The 855 seed band remains unopened and
feature maturity remains `specified`.

The next bounded task is one enforceable controller for the five frozen
resource scopes. It should exercise success, wall-time exceedance, memory
exceedance, and stop-new-launches behavior on nonreserved shadow probes, emit
the same typed terminal receipts, and preserve all registered units. Only then
is it reasonable to reconsider opening the 855 exploratory plan.
