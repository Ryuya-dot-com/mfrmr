# D-SIM-4 interval/attempt worker qualification record

Date: 2026-08-31
Status: **worker qualified; static reconciliation 10/10; D-SIM-5 closed**

## Purpose

This record closes the implementation dependency named by the D-SIM-4
confirmation freeze. It qualifies one reusable separate-univariate lme4/REML
worker for the frozen 95% full-refit parametric-bootstrap percentile interval
and reconciles the complete planned attempt identity without opening a 857 or
858 seed.

The implementation reuses the existing D-SIM-3 generator, formula registry,
fit capture, variance extraction, D-study block allocation, and G/Phi
coefficient functions. It adds only the missing unconditional
`simulate(..., re.form = NA)` -> `refit()` -> type-7 percentile path and the
D-SIM-4 request mapping. No scenario-specific patch or new model is present.

## Static request reconciliation

The exact frozen denominator compiles to:

- 15,000 outer requests;
- 5,000 interval-eligible outer blocks;
- 995,000 route-level inner bootstrap attempts;
- 32,500 planned primary lme4 fits;
- 1,990,000 planned inner lme4 refits; and
- 2,022,500 planned backend fit calls in total.

Every outer request binds its parent attempt, scenario, replicate, 857/858
seed identity, stratum count, separate-univariate formula class, backend,
criterion, interval cardinality, and execution-closed flags. The six profiles
map deterministically to the three existing formula classes
`crossed::separate_error`, `crossed::combined_error`, and
`nested::combined_error`.

The 995,000 inner identities are represented by 5,000 nonoverlapping,
gap-free blocks of 199 identities rather than a redundant million-row table.
Each block hashes its outer request, 858 seed, bootstrap indices, global
ordinal range, and ID format. The first ordinal is 1, the last is 995,000, and
adjacent blocks are contiguous. This is an exact identity representation, not
an execution result or a reduced denominator.

All request and block rows retain `ExecutionAuthorized = FALSE`; seed access
is false throughout.

## Nonreserved full-refit qualification

The only executed data are the already qualified D3-S001 full-anchor shadow
fixture under its nonreserved seed `854100001`. Bootstrap mechanics use the
separate nonreserved seed `854900001` and the exact frozen count of 199
route-level bootstrap attempts.

The qualification executes:

- two primary stratum fits;
- 199 bootstrap attempts x two strata = 398 full refits; and
- 199 x two strata x two estimands = 796 nonpooled metric values.

All 199 attempts return a terminal success, all 398 refits preserve response
length and design identity, all 796 targets are finite, and the caller RNG kind
and state are restored. Primary G/Phi values agree with the independent direct
scalar formula with maximum error 0.

The type-7 95% shadow intervals are:

| Stratum | Estimand | Lower | Upper |
|---|---|---:|---:|
| S1 | ABS-PHI | 0.8336840060 | 0.8992670927 |
| S1 | REL-G | 0.8546082628 | 0.9046643236 |
| S2 | ABS-PHI | 0.6434763761 | 0.8466401532 |
| S2 | REL-G | 0.8101218147 | 0.8815274607 |

These values qualify mechanics only. They are not D-SIM-5 recovery or coverage
evidence.

## Failure accounting

A deterministic probe changes one inner receipt to a refit failure without
removing it. All four intervals then become unavailable and retain the frozen
`interval_unavailable_outer_attempt_retained` disposition. No success
replenishment, replacement seed, endpoint substitution, or success-only
denominator is created.

## Gate result

All 10 qualification gates pass:

1. parent freeze identity;
2. outer request identity;
3. inner attempt identity;
4. planned-seed closure;
5. full-refit cardinality;
6. same-design refitting and RNG restoration;
7. complete shadow terminal accounting;
8. interval and independent scalar-reference agreement;
9. failure-denominator preservation; and
10. execution-boundary preservation.

## Exact identities

- worker contract:
  `999e23abd17f017e03f3b2c627d79ddab146dedb9a602feacb08c741350c1999`
- qualification manifest:
  `459abaa38eedfb5ecc8a918d3d1b99cd765867297ab392dd5c896ec276a06f1a`
- complete inner-identity block registry:
  `fe14e64b42fadce5a7f47d0706fc04cb38298adafa8a8b5313fb63e9a5759bd8`
- worker source SHA-256:
  `5d6f1dfcf8959f258f419e03bd38ac560560e2cc72b0c324544b6735b88acd7f`
- runner SHA-256:
  `380eb12f227951dfaed97ae5b2db63c0e36e5802c8137652c5f8d33131b65b57`
- local binary SHA-256:
  `bc26c52e61ec698e1036737fe10b347120329d4a36a833b19aee6b1adfa9307c`

## Nonclaims and next boundary

D-SIM-5 execution authorized: **no**. Planned 857/858 seed access, response
generation, confirmation fitting, simulation validation, reference validation,
and public support remain false. The shadow intervals above do not count as an
outer attempt and do not estimate coverage.

The next bounded task is to form a shardable D-SIM-5 launch input directly from
these exact reconciled requests. That is an execution-packaging step, not a new
scientific scenario, estimator, owner-authorization layer, or opportunity to
revise the frozen denominator from observed outcomes.
