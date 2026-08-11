# Draft.83c2 matched glmmTMB/lme4 G-theory parity record

Date: 2026-08-09
Scope: repository-only matched Gaussian ML/REML point-estimation overlap
Result: narrow parity gate passed for interior fixtures; boundary disagreement retained

## Outcome

Draft.83c2 implements the second backend half of the Draft.83c program. It fits
the same Draft.83a retained rows and Draft.83c1 covariance map with glmmTMB,
retains its distinct optimizer/Hessian/boundary diagnostics, and compares it
with lme4 only after exact model-identity checks.

All eight focused tests and 93 expectations pass without skips in the recorded
environment. Interior deterministic fixtures pass the matched overlap. The
boundary negative control deliberately fails numerical parity and remains
ineligible. No estimator is selected.

## Recorded environment

| Dependency | Version |
| --- | --- |
| R | 4.6.1 (2026-06-24) |
| lme4 | 2.0.6 |
| glmmTMB | 1.1.14 |
| TMB | 1.9.23 |
| reformulas | 0.4.4 |
| digest | 0.6.39 |

The local `glmmTMB`, `VarCorr.glmmTMB`, `sigma.glmmTMB`, `diagnose`, and
`glmmTMBControl` help was reviewed. The recorded comparison uses only its
documented identity-link Gaussian, no-zero-inflation, homogeneous-dispersion,
ML/REML random-intercept overlap.

## Interior matched results

The default smoke tolerances are absolute `5e-5`, relative `5e-5`, logLik
`1e-6`, and fixed intercept `1e-5`. They are deterministic regression
tolerances, not recovery or equivalence criteria.

| Design | Method | Maximum component absolute difference | Full logLik absolute difference | Intercept absolute difference | Matched overlap |
| --- | --- | ---: | ---: | ---: | --- |
| p x i | REML | 4.553974e-06 | 1.742535e-10 | 4.964879e-17 | passed |
| p x i | ML | 2.687814e-07 | 4.916956e-12 | 7.982931e-07 | passed |
| p x r x i | REML | 1.168721e-05 | 2.190973e-09 | 2.690895e-15 | passed |
| p x r x i | ML | 6.212183e-06 | 2.531635e-09 | 1.531387e-06 | passed |

Every p x r x i semantic component is compared in Draft.81 order. Both backend
point-estimation gates pass, both likelihood degrees of freedom and observation
counts match, and all inference/coefficient/decision states remain false.

The frozen REML result identities are:

| Design | glmmTMB fit hash | Parity hash |
| --- | --- | --- |
| p x i | `e729528df94c44a3cff2928cd965b3f40de5485f85c3801a7fc7383ffca8813d` | `a0171d7a6a9a1658f95ccf86cfab2960b5775a2b2a9dd7d016df0e724caafba4` |
| p x r x i | `c8510a55d786b308a597ae7448c81f8084ef4115ce3d525f3b4034a2eef2e831` | `25998eba8f26ff968e2cc83b3d43cd6481bac18420768b53529fd801d8cbab19` |

## Nested grouping-label control

The `Site > Rater` fixture contains 24 Persons, 4 Sites, 3 raw Rater labels per
Site, and 288 observations. A backend `Rater:Site` label is mapped back to typed
`Site:Rater`; the semantic grouping counts are 24, 4, 12, and 288 for Person,
Site, Site:Rater, and Residual. Both backend point gates and numerical parity
pass.

The typed design remains `DStudyEligible=FALSE` because estimator overlap does
not validate future nested allocation or coefficient recovery.

## Boundary disagreement retained

The Draft.82 negative-component fixture produces:

| Component | lme4 REML | glmmTMB REML | Absolute difference |
| --- | ---: | ---: | ---: |
| Person | 1.096262 | 0.8740741 | 0.2221876 |
| Item | 1.783278e-33 | 1.994898e-10 | 1.994898e-10 |
| Residual | 0.7308411 | 0.7555556 | 0.02471443 |

glmmTMB returns optimizer code zero, message `relative convergence (4)`,
`pdHess=TRUE`, maximum fixed gradient `2.376889e-08`, and one component below
the declared `1e-8` boundary tolerance. It is therefore
`boundary_tolerance_reached` and `boundary_nonregular`, not interior.

The two backend REML log-likelihoods differ by `0.1801897`. Numerical parity,
both-point-gates parity, and matched overlap are false. Draft.83c2 does not hide
the disagreement by averaging estimates or treating positive-definite Hessian
status as non-singularity.

Recorded boundary glmmTMB fit hash:
`d5753f24ba7aa58ac4fd5f0cc04ca7e51130952f70aada325d40096ec5c2cd7a`.

Recorded boundary parity hash:
`efaa532e9dc0cd6647dc65388b9a0cde5df092f876029e9475fc67a5a6e5dc01`.

## Reproducibility and failure controls

The tests establish that Draft.83c2:

- records glmmTMB/TMB versions, actual default-control identities, and six
  backend function hashes;
- reproduces component, diagnostics, and fit hashes after row-order reversal;
- fails numerical parity when all smoke tolerances are explicitly zero;
- refuses ML-versus-REML comparison;
- refuses changed retained rows or audit identity;
- refuses a covariance-design capacity failure;
- rejects negative boundary or parity tolerances; and
- rejects incorrectly typed fit objects.

## Artifact identities

| Artifact | SHA-256 |
| --- | --- |
| `gtheory-glmmtmb-parity-prototype-0.2.3.R` | `37f13e0a340c3f5a8550a0c44e2978daa9b276971790293c4d96418d9e279e87` |
| `gtheory-glmmtmb-parity-contract-0.2.3.md` | `997da18849848560e026bee63dab8cc6e8388f67e63827c2e8aa04c11b347d99` |
| `test-gtheory-glmmtmb-parity-prototype.R` | `7ac857962e3c0c9cafe68cd5403919f5926fcdb779e3e3a632b2f88739ec7d9c` |

The record's own hash is intentionally omitted because adding it would change
the file being hashed.

## Interpretation and next gate

Draft.83c2 closes the deterministic matched-backend point-estimation gate. It
also shows why that gate must precede, but cannot replace, sampling validation:
interior fixtures agree closely, whereas a boundary fixture can have finite
fits and a positive glmmTMB Hessian while backend estimates and likelihoods
materially disagree.

Draft.83d must now convert the user's full design portfolio into registered
simulation lanes and evaluate component/coefficient bias, RMSE, coverage,
ranking, facet separation, convergence, and exact false-ready rates. Boundary
and sparse lanes must retain backend-specific denominators rather than pooling
only successful fits.
