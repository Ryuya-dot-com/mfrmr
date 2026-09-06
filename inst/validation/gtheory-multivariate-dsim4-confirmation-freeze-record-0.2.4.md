# Multivariate G-theory D-SIM-4 confirmation freeze (0.2.4)

Date: 2026-08-31
Scope: repository-internal package-capability validation
Disposition: `dsim4_confirmation_contract_frozen_dsim5_execution_closed`

## Exact identity

- Contract: `676da443b2b692c444ca5e0b944f4794a4f49f4a55ebd5c6927308abf951296a`
- Static manifest: `8e8b4b3d4f28a1ac9c94a42fbbdb193aa4979c57bf8a6f2d1a5ecb24ee4d713e`
- Implementation identity: `5c35399f578fb6b13875d4a0bf7fb41513ae2b58f60c1c317e3e233232980e5e`
- Freeze source SHA-256: `581b3efeaa7df75ed652e8383c3ecf2a28efac1662491e2f550eaadfaa46366c`
- Runner SHA-256: `af955485f2392c42067a3c21e141c07b0e39ae07a26633d8064471529e10e651`
- Local binary SHA-256: `9cea7804ca60ca28662d121f4584349d153358b8c6f95ee5dcfa258fce7df660`

The local binary is outside the package payload at
`validation-results/gtheory-multivariate-dsim4-confirmation-freeze-0.2.4/freeze-manifest.rds`.

## Frozen confirmation design

All 14/14 freeze requirements pass jointly. The selector uses no response,
D-SIM-3 error, failure rank, or fitted metric. It requires the full-anchor,
closure, targeted-structural, and boundary roles, then finds the
minimum-cardinality subset covering all 12 dataset axes and all 37 dataset
levels; ties are resolved by parent scenario ID. The exact six-cell result is:

| D-SIM-4 | Parent | Role |
| --- | --- | --- |
| D4-S001 | D3-S001 | full anchor |
| D4-S002 | D3-S002 | closure |
| D4-S003 | D3-S003 | boundary |
| D4-S004 | D3-S004 | boundary |
| D4-S005 | D3-S005 | boundary |
| D4-S006 | D3-S018 | targeted structural |

The three boundary rows jointly retain the near-zero, dominant, and
near-singular variance regimes. Together the six rows cover every declared
stratum-count, sharing, event, crossing, balance, missingness, object-count,
rater-count, repeat-count, variance, cross-stratum-covariance, and response-
distribution level. They do not claim complete pairwise coverage and receive
equal nonvoting weight.

## Questions and acceptance

Point recovery, interval coverage, and fail-closed behavior are separate
questions. ABS-PHI and REL-G remain separate estimands. The ten v4 acceptance
rules are inherited without relaxation. Regular-interior Monte Carlo bias and
coverage apply to the full-anchor and targeted-structural rows. Closure and
boundary rows use deterministic closure, PSD, structural, failure, and
attempt-accounting criteria rather than regular-interior bias thresholds.

The interval is fixed as a 95% full-refit parametric-bootstrap percentile
interval for the separate-univariate lme4 REML route. It uses unconditional
new random effects and residuals, 199 bootstrap refits, and R quantile type 7.
Every refit must return a finite target; otherwise the interval is unavailable,
the outer attempt remains counted, and worst-case coverage bounds retain the
failure. Marginal component endpoints and Wald-only intervals are prohibited.

Each scenario has 2,500 outer replications, derived as
`ceiling(0.25 / 0.01^2)`, so worst-case binomial coverage MCSE is at most 0.01.
The complete denominator is 15,000 outer attempts. The two interval-eligible
rows contribute 5,000 outer interval attempts and 995,000 inner bootstrap
attempts. Optional stopping, replacement seeds, success replenishment, and
post-outcome exclusions are prohibited.

## Reference and identity boundary

An isolated base-R scalar formula recomputes G and Phi from named universe,
relative-error, and absolute-only variance inputs for every finite primary-
route stratum, with tolerance `1e-10`. This is independent of the fit worker's
coefficient function. Its claim ceiling is coefficient-transformation overlap;
it is not an independent estimation backend and does not establish reference
validation by itself.

Eight implementation sources, 28 freeze functions, R 4.6.1,
`aarch64-apple-darwin23`, Matrix 1.7.6, lme4 2.0.6, digest 0.6.39, and processx
3.9.0 are content-addressed or exactly identified in the local static
manifest. Any estimator, generator, truth, interval, or routing change
invalidates this freeze and requires a new contract version and disjoint seed
namespace. No operational-owner or user-enablement field is required.

## Unopened execution identities

- data seeds: `857010001`--`857062500`;
- interval seeds: `858010001`--`858062500`;
- outer attempts registered: 15,000;
- terminal states issued: 0;
- RNG streams opened: 0;
- responses generated: 0;
- backend calls made: 0; and
- D-SIM-5 attempts authorized: 0.

Runtime and peak RSS must be reported for generation, fit, interval, outer-
pipeline, and complete-run scopes. These observations describe cost; they are
not an enablement or package-use gate.

## Claim boundary

- D-SIM-4 confirmation freeze complete: **yes**
- D-SIM-5 execution authorized: **no**
- planned seed opened: **no**
- response generated: **no**
- simulation validation ready: **no**
- reference validation ready: **no**
- public support ready: **no**
- feature maturity: `specified`

The next bounded task is to qualify and statically reconcile one worker that
implements this exact interval and attempt contract. No D-SIM-5 seed may be
opened before that reconciliation passes.
