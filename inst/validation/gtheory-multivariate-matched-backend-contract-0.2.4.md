# Draft.85b1 multivariate G-theory matched-backend contract

Status: repository-only Gaussian point-estimation adapter, 2026-08-24.

This contract advances the Draft.85b0 incidence audit to an exactly bound
`lme4`/`glmmTMB` overlap. It is an implementation and numerical-wiring gate,
not a public multivariate G-theory feature, an estimator validation, or an
independent scientific replication.

## Matched statistical model

For retained row `i` in declared stratum `s`, the common model is

```text
y_i = mu_s + sum_c b[c, g_c(i), s] + e_i
b[c, g, ] ~ N(0, Gamma_c)
e_i ~ N(0, sigma^2)
```

Every admitted non-residual component is global and has one unrestricted
stratum covariance matrix `Gamma_c`. The fixed part is one mean per declared
stratum with no intercept. The only matched residual is homoskedastic,
independent `sigma^2 I`; neither a general residual covariance nor an
observation-pair random covariance is silently substituted for it.

The generated formula is therefore of the form

```r
Score ~ 0 + Stratum +
  us(0 + Stratum | ObjectGroup) +
  us(0 + Stratum | ConditionGroup) +
  us(0 + Stratum | ObjectConditionGroup)
```

The component map is strict rather than alias-tolerant:

- the object main effect has role `object`;
- condition-only components have role `absolute_only`;
- object-containing interactions and `Residual` have role `relative_error`;
- member and component names follow the declared semantic column order; and
- `Residual` has no members and structure
  `homoskedastic_independent`.

A stratum-local component could in principle be represented by a carefully
matched diagonal adapter. Draft.85b1 deliberately does not claim that route:
all non-residual components here are `unstructured`, and any component
containing a `stratum_local` member blocks point fitting. Local diagonal
parser equivalence and reduction tests remain a later gate.

## Direct support and identification

Cross-stratum covariance support is component-specific. For every component
and stratum pair the adapter constructs the exact joint group key and records
shared groups and cross-stratum row pairs. Marginal sharing of `Object` and
`Rater` does not establish sharing of an `Object:Rater` component; a connected
A--B--C graph does not manufacture direct A--C covariance information.

The adapter also constructs the lower-triangle covariance-derivative design
for every free element of every `Gamma_c` plus `sigma^2`. Its full structural
rank is required. The eigenvalue cutoff is the squared singular-value
tolerance expressed on the design Gram scale. This rank check, the direct
overlap count, and the requirement that the random-coefficient count be below
the retained-row count are structural guards, not validated sample-size or
precision rules.

`observation_link_cols` define an explicit object/condition row identity.
That identity must be unique within a stratum and is used for row binding and
audit only. Rows are never paired by score, sort order, or nearest value, and
the link is not converted into a residual random effect. An omitted score is
outside this point-estimation overlap. Structurally absent rows can reach the
adapter only through the separate Draft.85b0 direct-support audit and do not
create a missing-at-random or recovery claim.

## Exact binding and comparison

Before fitting, Draft.85b1 replays the complete Draft.85b0 audit and requires
its audit and data/omission hashes to match. The downstream specification
retains the sealed audit hash rather than an unhashed duplicate audit object.
It then records:

- canonical row and observation-link identity;
- fixed-design columns and matrix hash;
- semantic component map, group keys, and random-design block hashes;
- covariance-derivative rank and hash;
- formula, ML/REML criterion, family, residual, zero-inflation, and dispersion
  identities; and
- backend, backend-function, and `glmmTMB`/TMB build-runtime identities.

Specification, backend data, and normalized fit artifacts have exact
top-level field/class/attribute schemas. Backend columns must have the exact
declared order, unordered-factor classes, levels, contrasts, and column
attributes. Unknown columns, fields, or attributes fail closed. Fixed and
random designs and the covariance-derivative audit are recomputed at fit entry
and must match their stored identities. The stored semantic formula is a
hashed canonical string; each backend call regenerates its formula from the
sealed component map, so no unhashed formula environment enters evaluation.
The raw backend fit object is not retained in the normalized artifact.

Backend coefficient and covariance names are validated and reindexed before
semantic stratum labels are applied. Names are never overwritten first.
Backend-native `theta` vectors are retained for diagnosis but are not compared
because their parameterizations and ordering differ. Parity is evaluated on
semantic component covariance matrices, fixed stratum means, observation
count, likelihood degrees of freedom, and backend-reported Gaussian log
likelihood under the same ML or REML criterion.

The smoke tolerances are absolute/relative covariance `1e-4`, fixed mean
`1e-4`, and log likelihood `1e-5`. They are wiring tolerances calibrated on a
single deterministic fixture, not frozen recovery or public equivalence
criteria. A zero-tolerance negative control must fail.

## Dependency, boundary, and readiness gates

A `glmmTMB` build-time TMB version different from the runtime TMB version
blocks fitting by default. An explicit
`allow_dependency_mismatch_diagnostic = TRUE` override may run a diagnostic
comparison, but its fit status is
`backend_dependency_version_mismatch` and its point-estimation gate remains
false. Such output cannot serve as matched-backend readiness evidence.

Optimizer/convergence status, Hessian status, maximum gradient, lme4
singularity, near-zero variance, covariance eigenvalue/rank, and correlations
near plus or minus one remain separate diagnostics. A positive Hessian cannot
override a covariance boundary. If an optimizer warning and boundary coexist,
both are preserved in the typed fit status.

The readiness vocabulary is intentionally narrow:

```text
SpecReady                     = structural point-fit eligibility only
PointEstimateAvailable        = a backend returned an extractable point
PointEstimationGatePassed     = row, dependency, optimizer, and boundary gate
NumericalParityPassed         = smoke-tolerance agreement only
MatchedBackendPointReady      = parity and both point gates
EstimationReady               = FALSE
RecoveryReady                 = FALSE
InferenceReady                = FALSE
CoefficientEligible           = FALSE
DecisionReady                 = FALSE
PublicSupportReady            = FALSE
```

`lme4` and `glmmTMB` share much of the R mixed-model parsing ecosystem and fit
the same likelihood here. Their agreement is useful for catching adapter,
ordering, extraction, and optimizer discrepancies, but it is not independent
evidence that the G-theory estimand is correct.

## Ordered next gate

Draft.85c must use an independently constructed covariance (`K`-matrix)
oracle and prespecified ADEMP cells to establish recovery under two and three
strata, sparse and unequal assignments, structural missing rows, PSD/rank
boundaries, shared-facet allocation operators, composite G/Phi recovery, and
full-refit uncertainty. The local-diagonal route requires its own matched
parser and reduction gate. None of these results may enter exports, help,
NEWS, or a public readiness envelope merely because this prototype is
callable.
