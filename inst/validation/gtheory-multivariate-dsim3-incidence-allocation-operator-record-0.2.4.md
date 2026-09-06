# D-SIM-3 v4 incidence-aware allocation-operator record

Status: separate-univariate D-study operator qualified; truth metric next
Date: 2026-08-31
Scope: per-stratum truth allocation only; no fit or coefficient

## Decision

Use a structural, object-incidence-aware allocation operator for the
`separate_univariate` route. Do not divide by the number of condition or event
identities observed globally in a stratum.

For each object and stratum, equal weights are assigned to that object's
registered structural identities. The operator diagonal is the mean across
objects of the squared weight norm. Because the route reports a named vector
of per-stratum coefficients and does not recover cross-stratum covariance, all
off-diagonal entries are exactly zero.

## Frozen identity

| field | value |
|---|---|
| contract | `MFRMR-GTHEORY-MV-DSIM3-SEPARATE-UNIV-ALLOCATION-V1` |
| contract hash | `89b158391acf18c090ab708d39780499f3fbf3882ec912e04a3e8d775263693a` |
| manifest hash | `526298d0c598e34a92e98b96b7bc59c0714fc053636bc25ea423d4c87c895093` |
| source SHA-256 | `a21d0a73cb706939cec6381fe9c87afb2915a824d70a3bd8bf6dd7ce4032533c` |
| parent truth manifest | `97d98f649cbc49d646a7f9ac37e8292d8eb1a8ceff4f369b609108d0812189e5` |

## Operator definition

For object \(p\), stratum \(s\), and its registered structural identities
\(I_{ps}\), set

\[
w_{psi}=1/|I_{ps}|, \qquad
a_s=\frac{1}{N_s}\sum_{p=1}^{N_s}\sum_{i\in I_{ps}}w_{psi}^2.
\]

The separate-univariate operator is

\[
A=\operatorname{diag}(a_1,\ldots,a_S).
\]

This gives the independent direct formulas:

| target component | diagonal |
|---|---:|
| `Object` | \(1\) |
| `Rater`, `Object:Rater`, `NestedCondition` | \(1/k\) |
| `Residual` | \(1/(kr)\) |

where \(k\) is the registered conditions per object and \(r\) is the
registered repeat count. With one repeat, the fit may combine
Object-by-Condition and event residual variance; both receive the same
\(1/k\) allocation and therefore remain coefficient-identifiable as a sum.

## Qualification result

| check | result |
|---|---:|
| profiles | 21/21 |
| target component operators | 78/78 |
| component-by-stratum diagonals | 173/173 direct-oracle pass |
| PSD operators | 78/78 |
| exact-zero off-diagonal policy | 78/78 |
| row-order invariance | 78/78 |
| identity-label invariance | 78/78 |
| missingness-mask invariance | 78/78 |
| legacy-operator diagnoses | 94/94 |
| readiness gates | 8/10 pass |

The operator uses all registered structural rows. `ResponseScheduled`, observed
scores, fitted values, and post-missingness counts do not enter its value.

## Legacy global-identity diagnosis

The audit independently compares the new diagonal with `1 / global unique
identities`:

- condition identities agree in the 21 fully crossed stratum partitions;
- they are too small by a factor of two in all 11 partially crossed
  partitions;
- they are too small by the stratum's object count in all 15 nested
  partitions; and
- global event identities are too small by the object count in all 47
  partitions, including fully crossed designs.

The final finding is important: replacing only the condition operator would
still leave residual error systematically underallocated. The D-SIM-2 global
`EventId` expression remains useful as historical plumbing evidence, not as a
D-SIM-3 truth formula.

## Scope boundary

This is deliberately not a general multivariate allocation operator. Its
off-diagonal zeros mean "not recovered by this route," not "the scientific
cross-stratum covariance is zero." A future general multivariate route needs
its own object/condition/event sharing operator and must not inherit this
diagonal policy silently.

The operator also does not yet constitute G or Phi. The next bounded task is
to combine the qualified target unit covariances and these operator diagonals,
then verify each per-stratum truth coefficient against an independently coded
scalar formula. Only after that may a superseding unopened execution plan be
issued.

No RNG initialization, response inspection, backend call, fit, coefficient
calculation, exploratory execution, or support promotion occurred.
