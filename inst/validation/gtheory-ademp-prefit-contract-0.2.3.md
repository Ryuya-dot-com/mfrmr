# Draft.83d2b0 scalable G-theory ADEMP pre-fit contract

Status: repository-only structural pre-fit contract, 2026-08-09.

Draft.83d2b0 binds every executable Draft.83d2a dataset to the Draft.83a
observed-design audit, an exact scalable covariance-component rank audit, and
the 89-unit Draft.83d1 execution manifest. It determines whether a backend
attempt is structurally admissible. It does not run lme4, glmmTMB, or MoM on
an analysis table; calculate likelihood information; record an atomic fit
result; estimate recovery; or authorize a coefficient or interval.

## Why another rank audit is necessary

The Draft.83a fixed-effect-equivalent rank is a useful diagnostic for saturated
mean structures, residual degrees of freedom, and incidence problems. It is
not the rank of the covariance-parameter design. In a partially crossed random-
effects model, a random component may be identified through repeated
covariance patterns even when its hypothetical fixed-effect contrast block
has zero or partial incremental rank.

Draft.83c1 computes the exact covariance-derivative design but materializes
`vech(K_c)` for every component. For `n` retained rows and `q` components this
requires

```text
q * n * (n + 1) / 2
```

design cells, in addition to the derivative matrices. The N=300 complete
scenario has 19,200 rows and seven components, implying 1,290,307,200 design
cells. Capacity failure in that implementation is not evidence of covariance
confounding, and raising the dense memory limit is not a statistical remedy.

## Exact equality-signature reduction

The current typed family contains independent scalar random-intercept blocks.
For a non-residual component `c` with grouping identity `g_c`, its covariance
derivative is

```text
K_c[u,v] = 1(g_c[u] = g_c[v]).
```

The residual derivative is the identity matrix. Therefore each row of the
complete lower-triangular covariance design depends only on:

- whether the pair is diagonal; and
- the exact subset of effective object/facet identities that are equal for
  the two rows.

Repeated pair signatures do not change column rank or the null space. With
`F` effective factors, at most `2^F` off-diagonal equality masks plus the
diagonal are needed, regardless of `n`.

For every proposed equality subset `S`, the prototype determines whether an
off-diagonal pair exists that is equal on exactly `S` and different on every
factor outside `S`. It uses inclusion-exclusion over per-row same-group counts:

```text
N_exact(S; u) = sum[T subset complement(S)]
                  (-1)^|T| N_same(S union T; u).
```

This is an exhaustive finite-data calculation, not random pair sampling. The
resulting unique binary signature matrix has exactly the same row support and
therefore the same column rank as the dense `vech(K_c)` design. Null directions
are constructed from a complete QR basis using the same SVD rank decision,
avoiding the squared-tolerance mismatch that can arise when small eigenvalues
of `X'X` are square-rooted directly.

Nested Rater identities use the Draft.83a effective conditional identity, so a
raw Rater label reused in two Sites is not treated as one grouping level.

## Scope of the reduction

The proof applies to the currently registered independent scalar random-
intercept component family. It does not establish rank for:

- correlated random slopes or unstructured covariance blocks;
- heterogeneous or correlated residual matrices;
- crossed component kernels that are not equality indicators;
- multivariate stratum covariance; or
- latent GPCM/GT-IRT likelihoods.

Those families require their own derivative signatures or sparse linear-
operator audit. The scalable result also establishes structural covariance
rank only. It does not establish ML/REML expected-information rank, boundary
regularity, optimizer convergence, adequate recovery, or interval validity.

## Incidence issue adjudication

Draft.83d2b0 retains every Draft.83a issue but assigns a pre-fit role:

| Issue family | Pre-fit role |
| --- | --- |
| no retained rows, insufficient factor levels, disconnected object/facet incidence, unreplicated highest-order/residual alias, replication metadata conflict | blocking observed design |
| fixed-effect-equivalent rank deficiency or no fixed-equivalent residual df | diagnostic, not covariance-rank proof |
| Draft.83a dense rank capacity | superseded only for structural covariance rank by the exact scalable audit |
| declared levels with no retained rows | component fitting may proceed, but affected level/rank recovery metrics are unavailable |
| unknown missingness with omissions | sensitivity label; it blocks an ignorability claim, not computation of a point fit |
| any unrecognized issue | fail closed |

This classification does not erase the original issue or change its audit
hash. It prevents two opposite errors: treating a fixed-effect diagnostic as
proof of random-component confounding, and treating structural rank as proof
of likelihood regularity.

## Frozen pre-fit results

The one-replicate registry produces:

| State | Scenarios | Fit units |
| --- | ---: | ---: |
| structurally eligible, likelihood information pending | 19 | 77 |
| blocked | 3 | 12 |
| total executable | 22 | 89 |

The blocked scenarios are:

- `GT-SPARSE-CYCLE-LOW`: rank 6/7 because `Person:Rater` and Residual have the
  same observed covariance signature;
- `GT-NEG-DISCONNECTED`: disconnected Person/Rater incidence and rank 6/7;
  and
- `GT-NEG-ALIASED`: the unreplicated Person:Rater:Criterion component is
  identical to Residual, giving rank 7/8.

The connected mid-density, unequal hub, nested, missingness, bounded-score,
local-dependence, and boundary scenarios have full structural component rank.
Boundary scenarios remain pre-fit eligible because their required test is that
a returned numerical fit fails the later regularity/readiness gate. Pre-fit
eligibility is not false readiness.

## Manifest and readiness boundary

Every manifest row binds its registry, dataset, generator, incidence, scalable
rank, method, backend, and pre-fit identities. Draft.83d2b0 deliberately sets:

```text
FitAttemptAuthorized = FALSE
AtomicResultRecorded = FALSE
FitAttempted          = FALSE
RecoveryEvidenceReady = FALSE
InferenceReady        = FALSE
CoefficientEligible   = FALSE
DecisionReady          = FALSE
```

The 77 eligible rows are labelled `eligible_adapter_pending_execution`, not
successful. The plan does not enter Draft.83d1 fit-return, convergence, or
recovery denominators because no atomic result exists yet.

Draft.83d2b1 must now freeze method-specific adapters and likelihood-
information/regularity rules, then execute one atomic success or typed failure
row for each of the 89 planned units. Ineligible rows must be recorded as
pre-fit failures without calling a backend. Boundary, disconnected, and alias
strata must produce zero false-ready rows. Effect prediction and recovery
metrics remain subsequent parts of Draft.83d2; Draft.84 still owns intervals.
