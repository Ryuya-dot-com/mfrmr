# D-SIM-3 v4 design-dependent truth-projection record

Status: nested truth alias resolved; incidence-aware operator remains next
Date: 2026-08-31
Scope: internal estimand semantics only; no coefficient or execution

## Decision

Retain the qualified four-component response generator, but supersede its
fixed component-role table as the estimand truth for nested designs.

For fully and partially crossed profiles, the source and target components
remain `Object`, `Rater`, `Object:Rater`, and `Residual`. For nested profiles,
the target truth is:

| target component | source generator component(s) | universe role |
|---|---|---|
| `Object` | `Object` | object |
| `NestedCondition` | `Rater + Object:Rater` | relative error |
| `Residual` | `Residual` | relative error |

This closes the incompatible-role alias found by the preceding semantics
audit. It does not yet compute G or Phi because the prospective allocation
operator is the next independent dependency.

## Frozen identity

| field | value |
|---|---|
| contract | `MFRMR-GTHEORY-MV-DSIM3-DESIGN-DEPENDENT-TRUTH-V2` |
| contract hash | `fb66bd15526afa1f18f613dcbc4b0d470350bcf803a642fcde537602d017f327` |
| manifest hash | `97d98f649cbc49d646a7f9ac37e8292d8eb1a8ceff4f369b609108d0812189e5` |
| projection source SHA-256 | `3b940929e1c0758634e4c1f7baad109e1cebf875dbd9d36392c74221b468b782` |
| parent semantics manifest | `815d29f76640f2886b572ffda418582a02135d51cd50dadbab5ff6e4308bbb2f` |
| parent generator manifest | `c334578b20b886d158f5fd1aa82c3c1bd9e24f64e7e9d1d4d1c25e7f868da46a` |

## Qualification result

| check | result |
|---|---:|
| profile projections | 21/21 |
| expanded source-to-target mappings | 84/84 |
| target component bindings | 78/78 PSD |
| nested aliases resolved | 6/6 |
| latent-response covariance preserved | 21/21 |
| unallocated absolute-error covariance preserved | 21/21 |
| identifiable target truth roles | 21/21 |
| generator payload mutations | 0 |
| readiness gates | 8/10 pass |

The largest latent-response and unallocated absolute-error covariance
differences are each `8.21565e-14`. The largest target/source effective-
covariance difference is `1.39333e-13`, and the largest projected unit-factor
reconstruction error is `1.438849e-13`; all are below the frozen `1e-10`
tolerance.

## Why the generator is preserved

For a nested profile, `ConditionId` and `ObjectId × ConditionId` define the
same partition. The generator draws the two source effects independently. If
their unit covariance matrices are \(\Sigma_R\) and \(\Sigma_{OR}\), their
sum is distributed as one Gaussian nested-condition effect with

\[
\Sigma_{NC}=\Sigma_R+\Sigma_{OR}.
\]

Because the source identity-overlap matrices are identical, applying the same
overlap to \(\Sigma_{NC}\) exactly reproduces the sum of the two effective
covariance bindings. The response values, RNG substreams, source component
draws, missingness masks, and generator payload hashes therefore remain
unaltered. Only the downstream estimand projection changes.

The parent generator manifest is referenced as already-qualified provenance;
this projection does not replay it, open the 854 streams again, or relabel any
existing payload as new evidence.

## Consequence for Phi and G

- `ABS-PHI`: unchanged at the component-partition level. Relative components
  also contribute to absolute error, so collapsing the aliased source pair
  retains the same total error covariance.
- `REL-G`: corrected for all six nested profiles. The combined nested-
  condition variance now contributes to relative error instead of excluding
  the former `Rater` portion as if it were a crossed facet main effect.
- Fully and partially crossed profiles retain their previous component roles.

These are unallocated covariance statements, not coefficient values. Applying
an incorrect global-condition allocation could still produce an incorrect G
or Phi, so coefficient computation remains prohibited.

## Remaining dependency order

1. Implement and independently oracle-test the object-incidence-averaged
   prospective allocation operator from registered structural assignments.
2. Issue a new unopened execution plan that binds this truth projection and
   the qualified operator without modifying the existing plan or relabeling
   parent generator payloads.
3. Then implement the fit/metric worker and terminal/resource orchestration on
   nonreserved shadow fixtures.
4. Re-run launch reconciliation before considering the 855 band.

No RNG initialization, response generation, backend call, fit, G/Phi
calculation, exploratory execution, or public-support promotion occurred.
