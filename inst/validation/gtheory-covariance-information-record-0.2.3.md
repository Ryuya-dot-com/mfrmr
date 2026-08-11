# Draft.83c1 G-theory covariance-design and expected-information record

Date: 2026-08-09
Scope: repository-only univariate Gaussian random-intercept diagnostics
Result: narrow Draft.83c1 gate passed; public support and coefficient readiness unchanged

## Outcome

Draft.83c1 now supplies the missing bridge between observed-incidence facts and
a backend point fit. The bridge is deliberately decomposed:

1. component covariance derivatives and structural null space;
2. variance-point-specific ML and REML expected information;
3. interior/boundary regularity;
4. exact retained-row binding to lme4; and
5. backend convergence and singularity diagnostics.

All eight focused tests and 103 expectations pass. No test is skipped in the
recorded local environment. The result does not estimate uncertainty, validate
sampling recovery, or make a D-study coefficient eligible.

## Recorded environment

| Dependency | Version |
| --- | --- |
| R | 4.6.1 (2026-06-24) |
| lme4 | 2.0.6 |
| reformulas | 0.4.4 |
| digest | 0.6.39 |

The local `lmer`, `VarCorr`, `isSingular`, and `lmerControl` help pages were
read during this draft. The implementation follows their separation of ML/REML
criterion, semantic variance extraction, boundary singularity, optimizer code,
and gradient/Hessian convergence checks.

## Frozen results

### Balanced p x r x i

The seven typed components have structural covariance rank `7/7`. At the
Draft.82 interior fixture variance point, both expected-information matrices
have rank `7/7`:

| Method | Minimum eigenvalue | Maximum eigenvalue | Positive condition number |
| --- | ---: | ---: | ---: |
| ML | 5.804164 | 512.3351 | 88.27027 |
| REML | 5.711942 | 512.2447 | 89.67961 |

Recorded covariance-design result hash:
`065f1b4478b47a8236fc314652677fa8392317f30a82b1ea8ad40bf03598e457`.

Recorded expected-information result hash:
`22ddf5561f676d98f98921bce5c508a900a6aed2376ee3e735968938d7a1d460`.

### Exact covariance alias

For unreplicated saturated `p x i`, structural rank is `3/4`. The sole null
direction has unit-magnitude opposite loadings on `Person:Item` and `Residual`,
because both derivative matrices are exactly the identity. This agrees with,
but is computationally independent of, the Draft.81 formula-level alias flag
and Draft.83a replication flag.

### ML versus REML information

With one Item level and replicated rows within Person, the three covariance
derivative columns remain structurally independent. ML expected information is
rank `3/3`; REML expected information is rank `2/3`. Its null direction loads
only on Item because the Item derivative is `11'` and the REML residual-forming
operator removes the intercept direction.

This control is important: “full covariance-design rank” is not promoted to
“both likelihood criteria are informative.”

### Connectivity remains a separate gate

The sparse connected cycle and the two-island `p x i` design both have full
structural covariance and ML/REML information rank. Only the connected design
passes Draft.83a incidence. Draft.83c1 therefore cannot launder a disconnected
object scale through a full covariance rank.

### Nested conditional identities

The nested `Site > Rater` fixture has grouping-level counts `Person=4`,
`Site=2`, `Site:Rater=4`, and `Residual=16`. Structural covariance and both
information matrices are rank `4/4`. Reused raw Rater labels remain scoped to
their Site. The typed design still has `DStudyEligible=FALSE`, because this fit
does not by itself define or validate a future nested allocation.

### lme4 interior point fit

The Draft.82 balanced `p x i` interior data produce the same REML component
estimates through Draft.83c1:

| Component | Estimate |
| --- | ---: |
| Person | 1.0000047 |
| Item | 0.2000019 |
| Residual | 0.7999990 |

The optimizer code is zero, `isSingular()` is false, the selected REML
information is full rank, and every component is interior. Its qualification is
`point_estimation_gate_passed`. The recorded `nloptwrap`, edge-restart,
boundary-tolerance, convergence-check, optimizer-control, and backend-function
identities are part of the fit hash. The recorded fit result hash is
`75ee3542a726adf1d14ae8d937f9c958837bc7ae420931e15a8d3c2dfaadbf6e`.

### Finite boundary fit

The Draft.82 negative-component control returns a finite constrained REML fit:

| Component | Estimate |
| --- | ---: |
| Person | 1.096262 |
| Item | 1.783278e-33 |
| Residual | 0.7308411 |

Its optimizer code is zero, but `isSingular()` is true and Item is on the zero
boundary. Draft.83c1 records `boundary_nonregular`; `EstimationGatePassed`,
`InferenceReady`, `CoefficientEligible`, and `DecisionReady` are all false.
The recorded fit hash is
`b2f676241978c44e106064cbdba519574b4d4381a78931a68fb79df3c21c26d8`.

## Failure controls

The tests also establish that Draft.83c1:

- reproduces covariance and result hashes after row-order changes;
- rejects changed retained values against an old incidence audit;
- rejects a changed missingness declaration;
- returns a typed non-evaluation after a covariance-matrix capacity ceiling;
- refuses information calculation after that capacity state;
- requires an exact named component vector; and
- rejects negative or nonfinite variance coordinates.

## Artifact identities

| Artifact | SHA-256 |
| --- | --- |
| `gtheory-covariance-information-audit-0.2.3.R` | `bda584c8c75f6e0bd20f5b1c69f52f753a3bc1e39911b6549c097f2da6c34692` |
| `gtheory-covariance-information-contract-0.2.3.md` | `9701f3951e99fda87cc9d4452ea11897201069896ca69c761496158d577a7d51` |
| `test-gtheory-covariance-information-audit.R` | `c0f57cebc7ccd4a9bf7eb7a27b0a2189b7dcf2a32ac33f22a667eac6c7447cb0` |

The record's own hash is intentionally omitted because adding it would change
the file being hashed.

## Interpretation and next gate

Draft.83c1 closes a necessary mathematical gap, not the unbalanced/nested
validation program. It establishes that a finite lme4 result can be linked to
an explicit covariance map and local likelihood information without confusing
optimizer convergence, structural rank, boundary regularity, or incidence
connectivity.

Draft.83c2 comes next. It must build a separate glmmTMB extraction and
diagnostics contract, freeze exact ML/REML likelihood and variance-structure
matching, and compare estimates only inside that overlap. It must not use a
positive-definite glmmTMB Hessian as a synonym for lme4 non-singularity.
Draft.83d must then establish bias, RMSE, coverage, ranking, facet separation,
and convergence/false-ready behavior across the full frozen design portfolio.
