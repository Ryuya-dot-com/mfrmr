# Future Draft.85a0 multivariate G-theory algebra preflight

Status: repository-only supplied-matrix algebra contract, 2026-08-09.

This preflight makes the mathematical core of the future multivariate
G-theory route executable without pretending that multivariate covariance
estimation has been implemented or validated. It is developed early in
response to roadmap review, but its promotion remains ordered after the
univariate Draft.83 recovery and Draft.84 uncertainty gates.

The current public `mfrm_generalizability()` and `mfrm_d_study()` functions
remain single-score, univariate, main-effects/collapsed-residual helpers. They
do not accept a `Stratum`, estimate cross-stratum covariance, or form a
multivariate composite. This artifact changes no public function.

## Typed component covariance model

Let `S` be the exact ordered set of observed-score strata. Each semantic
component `c` has:

- one supplied symmetric positive-semidefinite covariance matrix
  `Gamma_c` of dimension `S x S`;
- one universe role: `object`, `relative_error`, or `absolute_only`; and
- one explicit prospective allocation operator `Lambda_c`.

The D-study contribution of a component is the Hadamard product

```text
C_c = Gamma_c o Lambda_c.
```

The universe-score, relative-error, and absolute-error covariance matrices are

```text
Sigma_p     = sum(C_c: role = object)
Sigma_delta = sum(C_c: role = relative_error)
Sigma_Delta = Sigma_delta + sum(C_c: role = absolute_only).
```

This prototype requires exactly one object component and at least one
relative-error component. Standard G-theory treats distinct semantic effects
as mutually independent; cross-stratum covariance is represented within each
effect-specific `Gamma_c`, not by silently pooling different effects.

## Allocation and cross-stratum sharing

For every scaled component, each stratum supplies positive prospective weights
`a_scg` over fully qualified condition identities `g`, summing to one. The
operator is the Gram matrix

```text
Lambda_c[s,t] = sum_g a_scg * a_tcg.
```

Therefore:

- the diagonal is the component-specific allocation concentration;
- common condition samples retain positive off-diagonal overlap;
- partially shared samples retain only their weighted intersection; and
- independent samples have off-diagonal zero.

With two equally weighted conditions in both strata, complete sharing gives
`Lambda_AB=1/2`, one-of-two partial sharing gives `1/4`, and disjoint support
gives zero. With two conditions in A, three in B, and one shared condition,
the exact value is `1/(2*3)=1/6`; it is not `1/sqrt(2*3)`.

The object covariance is unscaled and must use an all-ones operator. This
preserves the covariance of the same object across strata. Residual or
object-by-facet components require their own support/replication identities;
they cannot inherit the main-facet operator by name.

Because both `Gamma_c` and a valid Gram `Lambda_c` are PSD, the Schur product
theorem supplies an independent check that `C_c` is PSD. Nevertheless, every
raw covariance, operator, contribution, and aggregate matrix is audited rather
than assuming this property from labels.

## Composite coefficients

For a named stratum weight vector `w`, the supplied-matrix algebra is

```text
E rho^2(w) = (w' Sigma_p w) /
             (w' (Sigma_p + Sigma_delta) w)

Phi(w)     = (w' Sigma_p w) /
             (w' (Sigma_p + Sigma_Delta) w).
```

The default composite policy requires nonnegative weights summing to one. A
separately labelled nonzero linear-contrast policy permits other finite
weights; coefficients are invariant to multiplication of all weights by the
same nonzero scalar.

Composite G/Phi is not an average of stratum-specific coefficients. The
quadratic form includes cross-stratum universe and error covariance. The
prototype therefore retains every component's `w'C_cw` contribution and the
three aggregate quadratic variances.

## Matrix audit

Before algebra, every matrix must have:

- numeric `S x S` dimensions;
- row and column names exactly matching the declared stratum order;
- finite entries;
- symmetry within a recorded tolerance;
- nonnegative eigenvalues within that tolerance; and
- for allocation operators, nonnegative entries and positive diagonal.

The audit records maximum asymmetry, minimum/maximum eigenvalue, effective
rank, rank-deficiency state, and tolerance. Rank deficiency is retained rather
than repaired or hidden. It does not automatically make a supplied-matrix
quadratic form undefined—for example, the all-ones object operator is rank
one—but no rank-deficient estimated covariance can later be promoted without
an identification and uncertainty policy.

Indefinite covariance, asymmetric matrices, changed stratum order, missing or
extra component identities, an object operator other than all ones, invalid
allocation weights, and malformed composite weights fail before a scalar is
returned. No nearest-PSD repair is performed. A future repair sensitivity, if
added, must retain both raw and repaired matrices and can never overwrite the
raw state.

## Frozen two-stratum oracle

The oracle uses strata A/B and components Person, Person:Rater, Rater, and
Residual. Under weights A=0.6 and B=0.4, complete sharing gives:

```text
w' Sigma_p w     = 0.680
w' Sigma_delta w = 0.332
w' Sigma_Delta w = 0.416
G                 = 0.680 / 1.012 = 0.6719368
Phi               = 0.680 / 1.096 = 0.6204380
```

Changing only Rater support gives:

| Facet sampling | G | Phi |
| --- | ---: | ---: |
| Common | 0.6719368 | 0.6204380 |
| One-of-two shared | 0.6967213 | 0.6488550 |
| Independent | 0.7234043 | 0.6800000 |

Positive cross-stratum error covariance makes the common-facet composite less
reliable in this fixture. This ordering is not universal when component
covariances or weights change; it is a deterministic algebra oracle.

The one-stratum reduction reproduces ordinary G/Phi exactly. A separate
three-stratum fixture verifies order and dimension handling without claiming
three-stratum covariance estimation.

## Estimation and uncertainty still missing

This artifact receives supplied `Gamma_c` matrices. It does not establish how
to estimate them from incomplete, unbalanced long-form data. Future work must
separately validate:

1. explicit `Stratum`/`ScaleId` compatibility and object linking;
2. random-slope or multivariate mixed-model parameterization;
3. component covariance identification and correlation boundaries;
4. common, partial, and independent facet allocation in observed designs;
5. PSD and rank recovery, not merely post-fit matrix inspection;
6. full-refit joint intervals for matrices and composite coefficients;
7. missing-stratum and item/rater non-overlap mechanisms;
8. two- and three-stratum recovery under sparse and unequal workload; and
9. matched external examples without treating archived software as truth.

`lme4` can express correlated stratum random slopes, but formula expressibility
does not prove that every semantic component is identified or correctly
scaled. `glmmTMB` must be compared only on an exactly matched Gaussian
covariance overlap. Neither backend is selected here.

## Readiness boundary

Every specification and composite result retains:

```text
AlgebraReady        = TRUE   # valid supplied matrices only
EstimationReady     = FALSE
InferenceReady      = FALSE
CoefficientEligible = FALSE
DecisionReady       = FALSE
```

Thus this preflight advances the mathematical contract from prose to tested
code but does not advance the multivariate checklist row to validated support.
Draft.83d2 remains the active univariate execution step. After univariate
recovery and interval gates, the future Draft.85 estimator must bind estimated
component matrices to this exact algebra or a separately reviewed successor.
