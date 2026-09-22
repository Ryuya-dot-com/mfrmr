# GPCM JML binary closure-envelope P2i record (0.2.3)

## Decision

P2i completely classifies the response-image closure and likelihood boundary
of the exact binary two-Person, two-slope-owner JML GPCM operator isolated by
P2h. It is the first completed GPCM boundary envelope in the P1v--P2i chain,
although its scope is deliberately the minimal four-cell operator rather than
a general retained design.

The contract is
`mfrmr-jml-gpcm-binary-closure-envelope-0.2.3-v1`. For strictly positive
success and failure mass in all four response cells it:

1. characterizes the finite response image exactly;
2. gives all five strata of its finite closure;
3. identifies every bounded-response parameter-escape limit;
4. proves that unbounded response contrasts have likelihood limit minus
   infinity;
5. maximizes likelihood analytically on both bounded-escape axes; and
6. decides finite JMLE existence or nonexistence for every such four-cell mass
   vector.

An integer expanded-row example has both binary outcomes in every design cell
but a global likelihood supremum only on a missing finite-response boundary.
It therefore proves finite-JMLE nonexistence without ordinary single-cell,
Person-score, or affine additive separation.

The theorem changes no stored production fit, readiness, standard error,
confidence interval, MML, recovery, simulation, FACETS-comparison, or
promotion decision.

## Exact finite response image

For finite positive slopes satisfying the two-owner identification constraint
`alpha_1 alpha_2 = 1`, write the four binary reference-logit contrasts as

```text
z1 = alpha_1 (theta_1 - delta)
z2 = alpha_1 (theta_2 - delta)
z3 = alpha_2 (theta_1 + delta)
z4 = alpha_2 (theta_2 + delta).
```

Let

```text
d1 = z1 - z2
d2 = z3 - z4.
```

Then

```text
d1 = alpha_1 (theta_1 - theta_2)
d2 = alpha_2 (theta_1 - theta_2)
d1 = alpha_1^2 d2.
```

Because `alpha_1^2 > 0`, a finite response point must have strictly same-sign
nonzero differences or two zero differences. The condition is also sufficient.
When `d1 d2 > 0`, set

```text
alpha_1 = sqrt(d1 / d2),
alpha_2 = 1 / alpha_1,
theta_1 = (z1 / alpha_1 + alpha_1 z3) / 2,
theta_2 = (z2 / alpha_1 + alpha_1 z4) / 2,
delta   = (alpha_1 z3 - z1 / alpha_1) / 2.
```

When `d1 = d2 = 0`, the same inverse works with `alpha_1 = alpha_2 = 1`.
Thus the finite response image is exactly

```text
S = {d1 > 0, d2 > 0}
    union {d1 < 0, d2 < 0}
    union {d1 = 0, d2 = 0}.
```

P2i reconstructs the inverse numerically and records its response residual,
but the membership proof itself uses only the exact sign identity.

## Complete finite closure and escape strata

The Euclidean finite closure is

```text
closure(S) = {not (d1 > 0, d2 < 0) and not (d1 < 0, d2 > 0)}.
```

It has five disjoint strata:

| Stratum | Difference condition | Dimension | Finite point | Escape limit |
| --- | --- | ---: | --- | --- |
| positive interior | `d1 > 0, d2 > 0` | 4 | yes | no |
| negative interior | `d1 < 0, d2 < 0` | 4 | yes | no |
| equal-difference intersection | `d1 = d2 = 0` | 2 | yes | yes |
| owner-1-dominant missing axis | `d1 != 0, d2 = 0` | 3 | no | yes |
| owner-2-dominant missing axis | `d1 = 0, d2 != 0` | 3 | no | yes |

This is also the complete bounded-response escape-limit classification. If
`alpha_1 -> infinity` while `z` stays bounded, the exact identity forces
`d2 -> 0`. If `alpha_2 -> infinity`, it forces `d1 -> 0`. If both slopes stay
in a compact positive interval, the displayed inverse makes bounded `z`
imply bounded `theta_1`, `theta_2`, and `delta`; the parameter sequence cannot
escape.

Conversely, every point on `d2 = 0` is approached with
`alpha_1(t) = exp(t)`, `alpha_2(t) = exp(-t)`, the first two contrasts fixed,
and difference `d2(t) = d1 exp(-2t)`. The other axis has the symmetric path.
At the intersection the response contrasts may remain exactly constant while
the slopes escape. Hence no bounded-response escape stratum is missing.

## Complete likelihood envelope

For response cell `r`, let `s_r > 0` and `f_r > 0` be success and failure
mass. Integer masses are ordinary expanded repeated binary rows; no grouped-
binomial or new response family is introduced. The identified conditional
joint log likelihood in response coordinates is

```text
L(z) = sum_r [s_r z_r - (s_r + f_r) log(1 + exp(z_r))].
```

Every coordinate contribution is strictly concave and has independent optimum

```text
q_r = log(s_r / f_r).
```

Positive mass on both outcomes also makes a coordinate contribution tend to
minus infinity as its contrast tends to either infinity. Therefore every
unbounded response-contrast sequence has joint likelihood limit minus
infinity. Only the two bounded-response escape axes can compete.

On the owner-1-dominant axis `d2 = 0`, cells 1 and 2 retain `q1` and `q2`,
while cells 3 and 4 share the exact pooled logit

```text
p34 = log((s3 + s4) / (f3 + f4)).
```

The axis maximum is `(q1, q2, p34, p34)`. The owner-2-dominant maximum is

```text
(p12, p12, q3, q4),
p12 = log((s1 + s2) / (f1 + f2)).
```

These are the two branch maxima from the same-sign closure cones. If the
independent optimum `q` belongs to the finite image, it is the finite global
JMLE. Strict same-sign differences put it strictly above the two escape axes;
two zero differences give a finite representative plus a response-equivalent
escaping fibre. If `q` is on a missing axis or has opposite differences, the
larger of the two pooled-axis values is the global supremum, every maximizing
closure point is missing from the finite image, and no finite JMLE exists.

Thus, for positive masses in this fixture, finite existence has the exact
criterion

```text
(q1-q2)(q3-q4) > 0
or
q1=q2 and q3=q4.
```

All remaining configurations have a classified but unattained supremum.

## Nonseparated finite-nonattainment fixture

Use expanded-row success and failure counts

```text
success = (2, 4, 1, 1)
failure = (1, 1, 1, 1).
```

Every one of the four Person-by-owner cells contains both scores 0 and 1. Both
Persons therefore also have mixed total scores. The independent optimum is

```text
q = (log(2), log(4), 0, 0),
d1 = -log(2),
d2 = 0.
```

It lies on the missing owner-1-dominant axis. Its exact log likelihood is

```text
sup L = 6 log(2) - 3 log(3) - 5 log(5)
      = -7.184143344815158.
```

The second-axis candidate pools cells 1 and 2 at `log(3)` and has log
likelihood `-7.271269874...`, so `q` is the unique closure maximizer. The
explicit finite owner-1-dominant path converges to `q`; its likelihood rises
to the displayed supremum and its exact parameter reconstruction remains
finite at every finite path index. Since P2h proves that `q` has no finite
representative, P2i certifies finite-JMLE nonexistence.

This failure is nonlinear. No response cell is separated, every unbounded
response contrast is likelihood-destructive, and the existing production P2f
fixture has zero free extreme-Person recession count and no global additive
recession-cone certificate. The missing limit arises only from reciprocal
slope divergence combined with vanishing additive differences.

## Current-fit reconstruction

`mfrmr_jml_gpcm_fit_binary_closure_envelope()` accepts only a current
GPCM/JML fit whose retained structure has:

- exactly two Persons and two slope levels;
- binary scores;
- one common step and slope facet and no interaction;
- all four Person-by-owner cells;
- an implementation-exact zero affine offset; and
- grouped adjacent-design rows exactly equal to
  `(1,0,-1)`, `(0,1,-1)`, `(1,0,1)`, and `(0,1,1)`.

It then sums retained row weights by cell and outcome before applying the P2i
envelope. On the 12-row expanded fixture, the ordinary optimizer returns code
zero at retained log likelihood `-7.184150830659939`, about
`7.48584478049708e-6` below the exact supremum, with finite slopes about 9.47
and 0.106. The wrapper certifies the boundary supremum and finite nonexistence
without treating that stopping point as a finite estimate.

The stored production P2f state remains
`global_finite_jmle_existence_open_complete_boundary_envelope_unavailable`
because P2i is an internal exact-fixture wrapper, not a new general production
search. This makes the previous false-negative scope explicit without silently
changing readiness or primary parameter fields.

PCM, MML, additional facets, interactions, anchors or other affine offsets,
noncanonical operators, missing cell outcomes, invalid masses, legacy P2h
sources, and workload excesses fail closed.

## Verification

The focused P2i file executes 224 expectations with zero failures, skips, test
warnings, or errors. It covers:

- exact membership of both finite interiors, the finite intersection, both
  missing axes, the outside region, and malformed contrast vectors;
- all five closure strata and their dimensions;
- inverse finite parameter reconstruction on positive, negative, and equal
  strata, plus rejection of a missing-axis inverse;
- the all-positive-mass nonattainment fixture and both analytic axis values;
- finite-path parameter reconstruction, response convergence, and likelihood
  convergence to the exact supremum;
- positive- and negative-interior finite JMLEs with strict boundary gaps;
- a finite equal-difference maximum with an exactly response-equivalent
  escaping fibre;
- opposite-difference data with two tied missing-axis maximizers;
- exact current-fit operator, response-mass, supremum, and retained-gap
  reconstruction, including independent objective reevaluation; and
- invalid fit, PCM, MML, structural mismatch, legacy source, mass, workload,
  axis, index, and contract controls.

All 16 focused `test-jml-gpcm-*` files execute 1,881 expectations with zero
failures, skips, test warnings, or errors. This reproduces the prior 1,657
P1v--P2h expectations and adds the 224 P2i expectations without changing an
earlier result. The separate package-loading warning that `testthat` was built
under R 4.5.3 while verification used R 4.5.1 is environmental and is not a
test warning.

A vignette-bearing `mfrmr_0.2.3.tar.gz` built from the final source passes
`R CMD check --no-manual --ignore-vignettes` under R 4.5.1 with zero errors,
zero warnings, and one known optional cross-reference NOTE for unavailable
`lme4`, `eRm`, `mirt`, and `TAM`. The tarball build creates the vignettes
successfully; check-time vignette rebuilding is deliberately skipped.

The checksum-bound claim-disposition profile then passes its 30 expectations
with zero failures, skips, test warnings, or errors after the revised release
checklist hash is bound.

## FACETS and response-family consequence

P2i changes no FACETS role. FACETS PCM/JMLE versus mfrmr PCM/JML remains the
only possible future direct common-estimand lane. The reciprocal non-unit
slopes and missing response-image boundary are not a FACETS PCM estimand, and
FACETS Table 7 discrimination remains diagnostic-only.

The success and failure masses are sums of ordinary repeated ordered-binary
row likelihoods. They do not add nominal multinomial, grouped-binomial, or
count-response support. Noninteger row weights retain the package's existing
likelihood-weight meaning and likewise do not change the response family.

## Machine-readable disposition

```text
BinaryClosureEnvelopeContract = mfrmr-jml-gpcm-binary-closure-envelope-0.2.3-v1
EstimatorIdentity = unpenalized_fixed_effects_jml_no_finite_box
ObjectiveIdentity = identified_conditional_joint_log_likelihood
FixtureIdentity = binary_two_person_two_slope_owner_centered_location_gpcm
FiniteResponseImageExactlyCharacterized = TRUE
CompleteFiniteResponseImageClosureStratified = TRUE
CompleteBoundedResponseEscapeLimitSetClassified = TRUE
UnboundedResponseContrastLikelihoodLimitNegativeInfinity = TRUE
CompleteFixtureParameterSequenceLimsupEnvelopeConstructed = TRUE
PositiveSuccessAndFailureMassEveryCell = TRUE
OrdinarySingleCellSeparationAbsent = TRUE
CanonicalIndependentOptimum = log2,log4,0,0
CanonicalGlobalSupremum = -7.184143344815158
CanonicalFiniteJMLEExistence = FALSE
CanonicalFiniteJMLENonexistenceCertified = TRUE
CurrentFitExactOperatorReconstructed = TRUE
OptimizerTracePromotedToFiniteEstimate = FALSE
GeneralGPCMResponseImageClosureClassified = FALSE
MMLGeometryClassified = FALSE
ReadinessEffect = none_theorem_only
ExternalComparisonAuthorized = FALSE
FACETSComparisonRoleChanged = FALSE
RecoveryClaimAuthorized = FALSE
BroadSimulationAuthorized = FALSE
ConfirmationAuthorized = FALSE
NextGate = general_design_response_image_closure_stratification
```

## Identity

| Artifact | SHA-256 |
| --- | --- |
| `R/core-jml-gpcm-binary-closure-envelope.R` | `2e2f79f9f9e32aba334fa4d4dc66b09b369e815b0a50989f122c4580223121d4` |
| `R/core-jml-gpcm-response-quotient-closure.R` | `52dfb49a5e6589a27607c2f52166b31b0b375844ea63ea0be90b178d69054242` |
| `R/api-estimation.R` | `c34f7bac752667d1ca65622d089d4580b9f9c930b85f3ffa690889b1afdbe1a7` |
| `man/fit_mfrm.Rd` | `802c3deddc243aced39b837a8edd831f28cb209fe20a2ba199c89339d0c1f104` |
| `tests/testthat/test-jml-gpcm-binary-closure-envelope.R` | `4ae33ddad3d91f9a3c94df61e0e81516406954931a804a556b41c15e4861a621` |
| `tests/testthat/test-jml-gpcm-response-quotient-closure.R` | `ff5d483be701742bc50ded5ea5278d34aad575a7a2b8fbc0486619b991f1b878` |
| `NEWS.md` | `4e6e0834efa8c0c19580066d4dba992b1fc11d8c5519e5ee9811b40fabad9661` |
| `ROADMAP.md` | `ae0c3f9cf54cf577137b582c7eef3865cdd8d58f19a11626543e7a20268295ba` |
| `inst/validation/README.md` | `a952619f1578c488f9df689d6dc4353e2b28a18eea537433553bf8b0fa99923b` |
| `inst/validation/release-evidence-checklist-0.2.3.csv` | `1c92035d43800c0efbf7283d16742b581d4ee4eaefecf6917ecfb2c1ed91dd4e` |
| `inst/validation/claim-disposition-profile-0.2.3.csv` | `545409821e4674a45cc10e3f03483fdbfa87b4762ad5da4521efcafba0f66eff` |
| `inst/validation/claim-disposition-profile-0.2.3.md` | `a7d24d3f27c6222b4f7167be0d15af3a85387dcbcc9852383e25fa8aed6ae244` |
