# GPCM JML global finite-attainment P2f record (0.2.3)

## Decision

P2f gives exact global consequences to three positive boundary certificates
and states the still-missing condition for a positive finite-attainment result.

For the identified, unpenalized, fixed-effects GPCM/JML objective with no
finite parameter box:

1. a parameter-reachable divergent path with analytic joint log-likelihood
   limit exactly zero proves that the global supremum is zero and that no
   finite JMLE exists;
2. an otherwise free extreme-Person ray or a certified strict global additive
   recession cone proves that no finite JMLE exists, although it need not
   identify the value of the supremum; and
3. a finite point strictly above a verified upper bound on the limsup of every
   parameter sequence escaping every bounded set would prove finite
   attainment by compactness and continuity.

P2e supplies further-subsequence limit classification, not the complete upper
envelope required in item 3. The executable finite-attainment implication
therefore labels caller-declared envelope completeness as conditional and
never promotes it to a production certificate. In fits without a positive
strict recession certificate, finite-JMLE existence remains open and a finite
optimizer trace remains a numerical trace.

The contract is `mfrmr-jml-gpcm-global-existence-0.2.3-v1`. It changes no
readiness, uncertainty, MML, recovery, simulation, confirmation, or external-
comparison decision.

## Universal upper bound and exact-zero boundary path

For effective retained row `i`, finite GPCM parameters give finite logits for
at least two categories. Every category probability is then strictly between
zero and one. Hence

```text
log p_i(y_i | x) < 0
```

and, because at least one fixed likelihood weight is positive,

```text
ell(x) = sum_i w_i log p_i(y_i | x) < 0
```

at every finite parameter vector. Thus zero is a universal strict upper bound
on the finite-parameter objective.

Let a completed P2c path contain at least one nonzero positive-power additive
or sum-zero log-slope stage. P2c's forward construction makes each additive
stage reachable in the retained constrained free coordinates; nonzero
identified log-slope rates are already parameter coordinates. Its norm
therefore escapes every bounded parameter set. If P2b gives

```text
lim_t ell(x(t)) = 0,
```

then the path reaches the universal upper bound. Consequently

```text
sup_x ell(x) = 0,
```

but no finite `x` attains it. This is a global nonexistence proof, not merely a
comparison with the retained optimizer point.

`mfrmr_jml_gpcm_reachable_supremum_zero()` checks the current P2c contract,
forward reachability, completed analytic limit, nonzero divergent stage count,
response dimensions, and positive-weight scope. Exact equality to zero is
required. A reachable path with a negative finite limit is explicitly
insufficient because another finite or boundary point can dominate it. A path
with no divergent stage is not a boundary path.

The analytic fixture has two freely estimated Persons and three binary
Criterion-owned slope levels. One Person scores zero on every retained row and
the other scores one on every row. Sending the two Person coordinates in
opposite directions is a P2c-reachable additive path. All 12 observed-row log
probabilities converge to zero, the finite-distance joint likelihood is
strictly negative and increasing, and the P2f state is
`global_supremum_zero_finite_jmle_nonexistence_certified`.

## Strict additive recession from every finite point

An otherwise free extreme Person affects only that Person's response rows. If
all scores are zero, decreasing the Person coordinate strictly raises every
finite observed-row probability; if all scores are maximal, increasing the
coordinate does the same. The direction respects the parameterization because
the Person audit excludes fixed and constraint-coupled coordinates before
assigning `unbounded_low` or `unbounded_high`. Therefore every finite point can
be strictly improved and no finite global maximizer exists.

The existing global additive cone uses the observed-category contrast design.
For a certified direction `d`, every observed-category utility difference
against an alternative is nonnegative and at least one retained contrast is
strict. At any finite GPCM point, every slope is positive and every alternative
has positive probability. Along `x + t d`, the derivative of an observed row
log probability is

```text
alpha_i {d_i,y - sum_k p_i,k d_i,k} >= 0,
```

and is strict on a row with a strict contrast. All retained weights are
positive after data preparation, so the joint likelihood strictly increases.
Again no finite point can be a global maximizer.

The production P2f audit accepts the cone only when its current source
contract, model, estimator, prescreen certificate, nonzero direction, and
strict contrast count all agree. It also recognizes existing analytic slope-
only or joint additive/slope paths only when a certified analytic limit is
exactly zero. A merely competitive limit relative to the retained trace is not
enough for a global conclusion.

These positive results do not require a complete enumeration of other
boundaries. Completeness is necessary for a negative boundary conclusion, not
for exhibiting one strict direction that rules out every finite maximizer.

## Conditional finite-attainment theorem

Let `ell` be the continuous finite-parameter log likelihood on the identified
free-coordinate space `R^p`. Suppose a verified number `B` satisfies

```text
limsup_n ell(x_n) <= B
```

for every sequence `(x_n)` escaping every bounded subset of `R^p`. If a finite
point `x_0` satisfies

```text
ell(x_0) > B,
```

then the upper level set

```text
L = {x : ell(x) >= ell(x_0)}
```

is bounded. Otherwise an unbounded sequence in `L` would have a subsequence
escaping every bounded set and limsup at least `ell(x_0)`, contradicting the
boundary bound. Continuity makes `L` closed, so finite-dimensional Heine-
Borel makes it compact. Weierstrass then gives a maximizer on `L`, which is a
finite global maximizer because every point outside `L` has lower likelihood.

`mfrmr_jml_gpcm_finite_attainment_gap_theorem()` implements this implication.
It records objective continuity, closed finite parameter space, the strict
gap, and the conditional compactness conclusion. It deliberately keeps
`complete_boundary_envelope_independently_certified`,
`global_finite_jmle_existence_certified`, and `production_decision_eligible`
false. A caller boolean cannot prove that every escaping sequence was covered.

P2e is necessary but insufficient for this positive result. It shows that any
parameter sequence has a further subsequence with a classifiable likelihood
limit after the exact nonlinear contrast map. Different subsequences can have
different flags and limits, and P2e does not maximize over all reachable flags.
It also permits an unbounded parameter sequence with a bounded contrast image;
such a sequence must be included in a complete escaping-sequence envelope.

## Production states

Every current non-unit GPCM/JML fit receives
`config$boundary_audit$gpcm_global_existence` after P2e. The audit uses only
current source contracts and has three substantive states:

| State | Meaning |
| --- | --- |
| `global_supremum_zero_finite_jmle_nonexistence_certified` | A certified analytic path reaches the universal upper bound zero; the supremum is classified and no finite JMLE exists. |
| `finite_jmle_nonexistence_certified_strict_additive_recession` | A free extreme-Person ray or strict global additive cone improves every finite point; no finite JMLE exists but the supremum value is not necessarily classified. |
| `global_finite_jmle_existence_open_complete_boundary_envelope_unavailable` | No accepted positive recession certificate is present; finite existence and global boundary absence remain open. |

PCM, MML, the exact unit-slope reduction, legacy P2e sources, mismatched
source model/estimator identities, malformed P2c paths, sub-zero path limits,
bounded paths, non-strict cones, and incomplete boundary envelopes fail closed.

The production fit declares no new P2c path and does not treat optimizer stage
endpoints as an asymptotic sequence. P2f does not overwrite the narrower P1v--
P2e audit fields; it adds a separate typed global adjudication result. Existing
readiness rules already suppress primary finite values for certified extreme
Persons and recession targets, so P2f has no readiness promotion effect.

## Verification

The new P2f test file contains 157 expectation calls and passes with zero
failures, skips, warnings, or errors. It covers:

- an exact P2c-reachable zero-supremum path and increasing finite-distance
  likelihoods;
- a reachable negative boundary limit that does not classify the supremum;
- bounded, incomplete, malformed-list, and atomic path inputs;
- conditional finite-attainment with complete-gap, incomplete-envelope,
  no-gap, and invalid-input states;
- production free extreme-Person and strict additive-cone nonexistence;
- exact-zero slope-only and joint analytic certificates;
- non-strict or analytically unverified negative controls;
- production open states for fully crossed response patterns; and
- PCM, MML, unit-slope, legacy-source, inference, readiness, and external-
  comparison non-promotion.

Thirteen focused JML GPCM boundary files from P1v through P2f pass 1,346
expectations with zero failures, skips, warnings, or errors. The surrounding
claim-disposition, documentation-terminology, release-readiness, model-
identity, FACETS-role, external-comparison, and core-workflow guard files all
pass with zero failures, skips, warnings, or errors. The GPCM capability file
also passes with zero failures, warnings, or errors and its three existing
CRAN-only skips when the installed package-private registries are bound into
the isolated `test_file()` environment.

A source tarball builds successfully with the existing prebuilt vignettes.
Under R 4.5.1 on Windows, the offline
`R CMD check --no-manual --ignore-vignettes` passes installation, static code
analysis, Rd validation, examples, and the complete test suite with zero errors
and zero warnings. The single NOTE is unchanged: Rd cross-references name
unavailable optional Suggested packages `lme4`, `eRm`, `mirt`, and `TAM`.
Repository-index access warnings are consequences of the offline environment
and do not change the check status.

No external executable, recovery run, broad simulation, or confirmation run
is part of P2f.

## FACETS and claim consequence

P2f changes no FACETS comparison role. FACETS PCM/JMLE versus mfrmr PCM/JML
remains the only possible future direct common-estimand lane. Non-unit
GPCM/JML remains truth-first, FACETS PCM remains a deliberately misspecified
control, and FACETS Table 7 discrimination remains diagnostic-only.

A proof that an mfrmr GPCM conditional likelihood has no finite maximizer does
not create a shared response model, estimator, conditioning convention,
parameter identity, or output semantics with FACETS. Likewise, an open finite-
attainment state cannot be repaired by numerical agreement with a FACETS
finite output. `external_comparison_eligible` remains false and the existing
comparison-role contract is unchanged.

## Machine-readable disposition

```text
GlobalExistenceContract = mfrmr-jml-gpcm-global-existence-0.2.3-v1
EstimatorIdentity = unpenalized_fixed_effects_jml_no_finite_box
ObjectiveIdentity = identified_conditional_joint_log_likelihood
UniversalFiniteLogLikelihoodUpperBound = 0
FiniteParameterLogLikelihoodStrictlyBelowZero = TRUE
ParameterReachableDivergentZeroLimitImpliesGlobalSupremumZero = TRUE
ParameterReachableDivergentZeroLimitImpliesFiniteJMLENonexistence = TRUE
FreeExtremePersonRayImpliesFiniteJMLENonexistence = TRUE
StrictGlobalAdditiveRecessionImpliesFiniteJMLENonexistence = TRUE
SubZeroReachableBoundaryImpliesGlobalSupremum = FALSE
NegativeBoundedSearchImpliesFiniteJMLEExistence = FALSE
FiniteOptimizerTraceImpliesFiniteJMLEExistence = FALSE
CompleteEscapingSequenceBoundaryEnvelopeConstructed = FALSE
StrictFiniteOverCompleteBoundaryGapImpliesCompactUpperLevelSet = TRUE
StrictFiniteOverCompleteBoundaryGapImpliesFiniteAttainment = TRUE
CallerDeclaredEnvelopeCompletenessIsIndependentCertificate = FALSE
ProductionParameterPathDeclared = FALSE
OptimizerStageEndpointsUsedAsAsymptoticSequence = FALSE
FiniteJMLENonexistenceCanBeCertified = TRUE
FiniteJMLEExistenceCanBeCertifiedInCurrentProductionScope = FALSE
GlobalBoundaryAbsenceCanBeCertifiedInCurrentProductionScope = FALSE
MMLGeometryClassified = FALSE
ReadinessEffect = none_diagnostic_only
ExternalComparisonAuthorized = FALSE
FACETSComparisonRoleChanged = FALSE
RecoveryClaimAuthorized = FALSE
BroadSimulationAuthorized = FALSE
ConfirmationAuthorized = FALSE
NextGate = complete_escaping_sequence_boundary_envelope_or_proper_response_map
```

## Identity

| Artifact | SHA-256 |
| --- | --- |
| `R/core-jml-gpcm-global-existence.R` | `c68d1b803b45d0321aa5a856871c9dc80004b4027f5fdc6a5eb1aeb3ccac6a30` |
| `R/mfrm_core.R` | `ab2290ab0cba5031b8c4b0fea80a96b156b4c3de7de02c16a4533372092870be` |
| `R/api-estimation.R` | `5146faa1d3c471f3a1ec14ae88147f3d5c5950f3846a0780b6b79e0f1ebfa0b5` |
| `man/fit_mfrm.Rd` | `bc507147a90bc64b1eab0422f4cee578818f5d26d3445ec0ed6ac2ef6e9e8d20` |
| `tests/testthat/test-jml-gpcm-global-existence.R` | `04aa394f3a397e2235ccf7cfb2a5f43cc941a277e76e1162da091efc8fee8dd7` |
| `NEWS.md` | `0b23bf38d807e69b9d9721fcc3d225b0b76ed4e071db8a3996406cba2d71a734` |
| `ROADMAP.md` | `a3c4b1f9fbf16dbd8a9950e71759634519048ef22b860dafd6a1ef484599b71a` |
| `inst/validation/README.md` | `d2a2964a60627d4b533aed6a58c27cb3289c53d4bc4100d16983e6208a50863c` |
| `inst/validation/release-evidence-checklist-0.2.3.csv` | `556205e80e8a49260c24ffcd9e143127dbc3cec9406c92a63aabd82be72c14ee` |
