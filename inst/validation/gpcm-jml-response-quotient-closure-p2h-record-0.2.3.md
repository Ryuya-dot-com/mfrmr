# GPCM JML response-quotient closure P2h record (0.2.3)

## Decision

P2h resolves one of the two alternatives left by P2g. Collapsing finite JML
GPCM parameter points that give the same complete response-contrast vector
does not, in general, yield a closed response image or a proper response map.
An explicit binary GPCM path approaches a finite contrast vector that no
finite GPCM parameter can represent.

The obstruction contract is
`mfrmr-jml-gpcm-response-quotient-closure-0.2.3-v1`. It consumes a classified
P2g bounded-response-image escape plus an implementation-exact affine row
relation. It changes no production fit, readiness, uncertainty, MML, recovery,
simulation, FACETS-comparison, or promotion decision.

The negative result is precise. It rules out a shortcut which merely removes
finite response-equivalent fibres. It does not rule out a completed quotient
which adds the missing boundary points or strata.

## Minimal GPCM construction

Use two Persons and two slope owners in a binary model. Let the centered owner
locations be `delta_1 = delta` and `delta_2 = -delta`. In free additive
coordinates `x = (theta_1, theta_2, delta)`, order the four adjacent-utility
rows as Person 1/owner 1, Person 2/owner 1, Person 1/owner 2, and Person 2/owner
2. The affine offset is zero and the exact design is

```text
A = [ 1  0 -1
      0  1 -1
      1  0  1
      0  1  1 ].
```

Choose the finite-parameter path

```text
theta_1(t) = exp(-t)
theta_2(t) = 2 exp(-t)
delta(t)   = 0
alpha_1(t) = exp(t)
alpha_2(t) = exp(-t).
```

The expanded log slopes remain sum-zero. Every finite `t` gives finite,
strictly positive slopes and finite additive coordinates, while the log-slope
vector escapes every bounded parameter set. Multiplying each binary adjacent
utility by its owner slope gives the exact response-contrast vector

```text
z(t) = (1, 2, exp(-2t), 2 exp(-2t)).
```

Thus

```text
z(t) -> z* = (1, 2, 0, 0).
```

P2g independently groups the two combined exponents `0` and `-2`, classifies
the path as a bounded-response-image parameter escape, and returns `z*` as its
finite P2e base.

## Why the finite target is missing

The design satisfies the implementation-exact affine relation

```text
row_1 - row_2 = row_3 - row_4.
```

Suppose a finite GPCM parameter represented `z*`. A finite GPCM slope is
strictly positive. The zero third and fourth target contrasts would therefore
force their unscaled adjacent utilities to be zero:

```text
theta_1 + delta = 0
theta_2 + delta = 0.
```

Hence `theta_1 = theta_2`. The first and second rows share the same finite
positive owner-1 slope, so their response contrasts would be equal. This
contradicts the first two target coordinates `1` and `2`.

Equivalently, the declared zero rows force the right side of the affine row
relation to zero. The common-owner witness coefficients `(1, -1)` then force
the left response-contrast combination to zero, but its target value is
exactly `1 - 2 = -1`. Therefore `z*` is not in the finite response image.

## Quotient consequence

Let finite parameters be response-equivalent when all cumulative category-
logit contrasts agree. The finite quotient set injects into Euclidean contrast
space, and its response-metric realization is exactly the finite response
image. The sequence of finite equivalence classes above is Cauchy in that
metric and converges in ambient contrast space to `z*`, but no finite class
represents `z*`. Consequently:

- the finite response image is not closed;
- the response-metric quotient is not complete;
- the induced quotient-to-contrast map is not proper; and
- collapsing finite response-equivalent fibres alone cannot prove compactness
  of likelihood upper level sets or finite JMLE attainment.

Any successful quotient route must therefore complete the finite quotient by
adding response-image boundary points or strata and then control likelihood
limsup values on that completion. This is the same substantive work as the
remaining response-image closure and boundary-envelope route, not a way around
it.

## Executable certificate

`mfrmr_jml_gpcm_response_quotient_closure_obstruction()` accepts only:

1. a current classified P2g bounded-image parameter escape with no positive
   contrast exponent;
2. exact target rows which are zero;
3. witness rows owned by one common slope;
4. finite nonzero coefficients for both sides of an exact affine row relation;
   and
5. an exactly nonzero witness combination at the finite target.

The affine offset is included as the first augmented design column. Equality,
zero, and nonzero comparisons are implementation-exact; no rank tolerance,
inverse solve, or numerical optimization enters the proof. Duplicate,
overlapping, out-of-range, mixed-owner, dimensionally inconsistent, nonfinite,
or workload-exceeding declarations fail closed.

The canonical helper
`mfrmr_jml_gpcm_response_quotient_binary_counterexample()` builds the P2g
source path and applies the certificate. This is theorem and regression
evidence rather than a production search over fitted designs.

## What P2h does not prove

P2h proves that one boundary contrast target belongs to the closure of the
finite response image but not to the image. It does not prove that this target
maximizes or improves the likelihood for its illustrative score vector. It
does not classify every missing boundary target, enumerate every bounded- or
divergent-image escape, or construct the complete limsup envelope.

Accordingly, both `finite_jmle_existence_certified` and
`finite_jmle_nonexistence_certified` remain false. Global boundary absence,
standard errors, confidence intervals, external comparison, readiness,
recovery, simulation, and promotion also remain false or unchanged. The next
gate is now
`complete_response_image_closure_stratification_and_boundary_limsup_envelope`.

## Verification

The focused P2h file executes 90 expectations with zero failures, skips, test
warnings, or errors. It checks:

- the exact binary GPCM design, sum-zero slope path, and P2g source contract;
- analytic finite contrasts at four path indices and convergence to `z*`;
- finite-index likelihood evaluation along the original parameter path;
- the exact augmented affine row relation and nonzero target contradiction;
- a nonzero affine-offset source whose augmented row relation remains exact;
- quotient-image closure, completeness, and properness dispositions;
- non-promotion of competitiveness, finite existence or nonexistence,
  readiness, uncertainty, and external comparison; and
- malformed source versions, non-escape sources, workload controls, duplicate
  rows, coefficient dimensions, mixed owners, nonzero declared-zero targets,
  false affine relations, and zero target witnesses.

The tests were run from the current source tree with `pkgload::load_all()`
against the retained local validation library. The library's `testthat` build
version emits an environment-level build-version notice under R 4.5.1; the
test results themselves contain zero warnings.

The contiguous P2g/P2h pair executes 311 expectations with zero failures,
skips, test warnings, or errors. All 15 focused `test-jml-gpcm-*` boundary and
terminal-gradient files execute 1,657 expectations with zero failures, skips,
test warnings, or errors when the retained `lpSolve` validation library is on
the library path. This reproduces the prior 1,567 P1v--P2g expectations and
adds the 90 P2h expectations without changing an earlier result.

A vignette-bearing source tarball builds successfully after the available
RStudio Pandoc location is declared to the noninteractive R session. Under R
4.5.1 on Windows, offline `R CMD check --no-manual --ignore-vignettes` with
`_R_CHECK_FORCE_SUGGESTS_=false` passes installation, static code analysis,
Rd validation, examples, and the package's CRAN-light tests with zero errors
or warnings. The single NOTE is unchanged: Rd cross-references name unavailable
optional Suggested packages `lme4`, `eRm`, `mirt`, and `TAM`. Repository-index
access notices and the unavailable-Suggests INFO are consequences of the
offline environment.

## FACETS and response-family consequence

P2h changes no FACETS role. FACETS PCM/JMLE versus mfrmr PCM/JML remains the
only possible future direct common-estimand lane. The non-unit-slope GPCM/JML
construction is internal truth-first evidence for mfrmr's response geometry;
FACETS PCM is still a deliberately misspecified control and FACETS Table 7
discrimination remains a post-fit diagnostic rather than a fitted GPCM slope.

The construction also does not broaden the response family. Its four binary
responses remain ordered categorical observations. Multinomial-nominal and
count likelihoods remain unsupported, and row likelihood weights do not alter
the family.

## Machine-readable disposition

```text
ResponseQuotientContract = mfrmr-jml-gpcm-response-quotient-closure-0.2.3-v1
EstimatorIdentity = unpenalized_fixed_effects_jml_no_finite_box
ObjectiveIdentity = identified_conditional_joint_log_likelihood
BinaryTwoPersonTwoSlopeOwnerCounterexample = TRUE
FiniteContrastTargetInResponseImageClosure = TRUE
FiniteContrastTargetRepresentableByFiniteParameter = FALSE
FiniteParameterResponseImageClosed = FALSE
ResponseMetricQuotientComplete = FALSE
InducedQuotientToContrastMapProper = FALSE
FiniteResponseEquivalenceFibreCollapseSufficient = FALSE
QuotientCompletionOrBoundaryStrataRequired = TRUE
ExactAffineRowRelationCertified = TRUE
BoundaryTargetCompetitive = FALSE
CompleteResponseImageClosureStratified = FALSE
CompleteEscapingSequenceBoundaryEnvelopeConstructed = FALSE
FiniteJMLEExistenceCertified = FALSE
FiniteJMLENonexistenceCertified = FALSE
MMLGeometryClassified = FALSE
ReadinessEffect = none_theorem_only
ExternalComparisonAuthorized = FALSE
FACETSComparisonRoleChanged = FALSE
RecoveryClaimAuthorized = FALSE
BroadSimulationAuthorized = FALSE
ConfirmationAuthorized = FALSE
NextGate = complete_response_image_closure_stratification_and_boundary_limsup_envelope
```

## Identity

| Artifact | SHA-256 |
| --- | --- |
| `R/core-jml-gpcm-response-quotient-closure.R` | `52dfb49a5e6589a27607c2f52166b31b0b375844ea63ea0be90b178d69054242` |
| `R/core-jml-gpcm-exponential-balance.R` | `4826a63e81982a39e9ee47b802c44fb78d9cd29013c231715f5f465688b52bb5` |
| `R/api-estimation.R` | `b73a8d8f9f95db1bf0f26317a58e9bc617a0f6fa719bc3e52b6c8f5ad79d6214` |
| `man/fit_mfrm.Rd` | `ab51481e227af25c2f3d4001a6f2e5fbd555f2a2a26fe4ebdff9900f99b69a9a` |
| `tests/testthat/test-jml-gpcm-response-quotient-closure.R` | `ff5d483be701742bc50ded5ea5278d34aad575a7a2b8fbc0486619b991f1b878` |
| `tests/testthat/test-jml-gpcm-exponential-balance.R` | `f0509d0a01988da22a3332cf9c0a0eeeb1d2b55c6d3811c9f0d8e030533cead9` |
| `NEWS.md` | `9782d4ff5e2f529b9c58d71b8a607e0d49a62e97d5d3fec5104c8d88eb08d652` |
| `ROADMAP.md` | `2a5c245e83944666cc62228064ad0385056195b2bdb83b00cf0475d3b05283e1` |
| `inst/validation/README.md` | `e81f2a89ff6cefcf4fe4e30114abbc353cd1015eebccba1620e13ddb2ce79b38` |
| `inst/validation/release-evidence-checklist-0.2.3.csv` | `e0560ff674e11504db57970921f502ac5213b9b6b9245a5ac5ea16c976a8f40f` |
| `inst/validation/claim-disposition-profile-0.2.3.md` | `b3ea7062f74f2835d6ae2b13ce2b2d84b36c0bc338af031af23d88f9e5578b5e` |
