# D-SIM-3 v4 separate-univariate truth-coefficient record

Status: per-stratum truth metric qualified; superseding unopened plan next
Date: 2026-08-31
Scope: deterministic truth G/Phi only; no fitted coefficient or execution

## Decision

Compute one named G/Phi pair per registered stratum for the
`separate_univariate` route. Use the qualified design-dependent unit
covariances and incidence-aware allocation diagonals. Do not pool strata and
do not use cross-stratum covariance, observed responses, fitted components, or
post-missingness counts.

For stratum \(s\) and target component \(c\), define

\[
v_{cs}=\Sigma^{unit}_{c,ss} A_{c,ss}.
\]

The role-specific truth quantities are

\[
\sigma^2_{p,s}=\sum_{c:r_c=object}v_{cs},
\qquad
\sigma^2_{\delta,s}=\sum_{c:r_c=relative}v_{cs},
\]

\[
\sigma^2_{\Delta,s}=\sigma^2_{\delta,s}
  +\sum_{c:r_c=absolute\ only}v_{cs},
\]

and

\[
G_s=\frac{\sigma^2_{p,s}}
{\sigma^2_{p,s}+\sigma^2_{\delta,s}},
\qquad
\Phi_s=\frac{\sigma^2_{p,s}}
{\sigma^2_{p,s}+\sigma^2_{\Delta,s}}.
\]

## Frozen identity

| field | value |
|---|---|
| contract | `MFRMR-GTHEORY-MV-DSIM3-SEPARATE-UNIV-TRUTH-COEFFICIENT-V1` |
| contract hash | `d73dd72c8bc849597dd68342a3608b1f34b315e7f1fd1ad52a87a9e26d963cb8` |
| manifest hash | `969afca1d3fb23a68d58500cd6959152b385b0e9b2e64c25cc75a3cd79feb37c` |
| source SHA-256 | `476dad72321404cf16e81369c06beb3a7450c5825ba8cf728c5d85b1927d93ed` |
| parent truth manifest | `97d98f649cbc49d646a7f9ac37e8292d8eb1a8ceff4f369b609108d0812189e5` |
| parent operator manifest | `526298d0c598e34a92e98b96b7bc59c0714fc053636bc25ea423d4c87c895093` |

## Qualification result

| check | result |
|---|---:|
| profiles | 21/21 |
| stratum truth coefficients | 47/47 |
| crossed stratum coefficients | 32/32 |
| nested stratum coefficients | 15/15 |
| allocated component contributions | 173/173 |
| fit-representation blocks | 160/160 |
| one-repeat combined-error strata | 13/13 |
| independent scalar-oracle comparisons | 235/235 |
| order invariance | 21/21 profiles |
| common positive-scale invariance | 21/21 profiles |
| off-diagonal perturbation invariance | 21/21 profiles |
| fit-representation qualification | 21/21 profiles |
| readiness gates | 8/10 pass |

## Independent oracle

The adapter obtains \(A_{c,ss}\) from the qualified parent operator. The
independent scalar oracle does not call that implementation. It reads the
registered rater count \(k\) and repeat count \(r\) and applies:

| target component | independent allocation |
|---|---:|
| `Object` | \(1\) |
| `Rater`, `Object:Rater`, `NestedCondition` | \(1/k\) |
| `Residual` | \(1/(kr)\) |

It then evaluates universe variance, relative error, absolute error, G, and
Phi separately. All five quantities agree for all 47 strata, giving 235/235
comparisons. The oracle never uses the operator implementation or
post-missingness counts.

## Estimand relationships

- In all 32 crossed strata, positive `Rater` absolute-only variance gives
  \(\Phi<G\).
- In all 15 nested strata, the identifiable `NestedCondition` target has a
  relative-error role and there is no separately identifiable absolute-only
  component. Therefore \(\Phi=G\).
- This equality is a consequence of the frozen nested estimand projection, not
  a general statement that absolute and relative decisions are equivalent.

For the two-stratum anchor `D3-S001`,

\[
\sigma^2_p=1,quad
\sigma^2_\delta=0.35/4+0.50/(4\times2)=0.15,
\]

\[
\sigma^2_\Delta=0.15+0.20/4=0.20,
\quad G=1/1.15,quad \Phi=1/1.20.
\]

## Fit-representation boundary

When \(r=1\), Object-by-Condition and event residual variation cannot be
separately recovered by the frozen univariate fit representation. All 13 such
strata therefore use one
`combined_object_condition_plus_event_residual` block containing exactly two
truth components. The coefficient uses the identifiable block sum. It does
not claim that both components will be individually estimated.

With repeated observations, the components remain separate fit blocks. Across
both cases, block aggregation preserves every allocated contribution entering
G and Phi.

## Scope boundary

These are data-generating truth coefficients, not fitted estimates, recovery
evidence, confidence intervals, or a public API. The off-diagonal perturbation
check confirms that the values do not use cross-stratum covariance, as required
for the separate-univariate route. It must not be generalized to a multivariate
composite coefficient, whose weights and cross-stratum covariance require a
different operator.

The remaining nonexecuting dependency is a new unopened plan that binds the
qualified truth-projection, operator, and truth-metric identities without
mutating the current 855 plan. Only after that plan exists may a common
execution bridge be shadow-qualified and launch-readiness reconciliation be
repeated.

No reserved 855 RNG stream, response inspection, backend call, fit, fitted
coefficient, exploratory execution, simulation-validation claim, or public
support promotion occurred.
