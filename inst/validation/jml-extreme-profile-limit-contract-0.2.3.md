# JML extreme-Person profile-limit contract for mfrmr 0.2.3

Status: repository-only Draft.73 prototype contract, 2026-08-09.

## Question and estimand

This contract asks whether structural and nonextreme-Person coordinates can be
re-estimated on the exact likelihood supremum induced by independently free
all-minimum or all-maximum Persons, without pretending that the original JML
likelihood has a finite full-vector maximizer.

For a contributing Person `p` whose retained responses are all at the maximum,
positive-slope RSM/PCM/GPCM response probabilities satisfy

`log L_p(theta_p, psi) -> 0` as `theta_p -> +Inf`.

The all-minimum limit is the same as `theta_p -> -Inf`. If each such Person
coordinate is independently free of anchors, centering, and group constraints,
then

`sup_(theta_extreme, psi) log L = sup_psi log L_without_extreme_person_rows`.

The reduced objective is therefore an extended-boundary profile-likelihood
supremum. It is not a finite maximum of the original JML likelihood and is not
a finite-item bias correction.

## Scope

The prototype may run only when:

- the input is a current `method = "JML"` fit with typed Person boundaries;
- every removed Person is `unbounded_low` or `unbounded_high`;
- the Person constraint Jacobian gives every removed Person one independently
  free coordinate with no loading on any other Person; and
- at least one nonextreme Person remains.

Directly or implicitly fixed extremes remain in the likelihood. A
constraint-coupled extreme returns
`constraint_coupled_extreme_not_profiled`; it is never silently dropped.
Structural and GPCM-slope recession remain governed by their separate audits.

## Required identities and output separation

The result must retain:

- the raw finite optimizer log likelihood and parameter values;
- the profile-limit log likelihood and separately named parameter values;
- excluded Person IDs, directions, response rows, and weighted responses;
- a finite-cap path evaluated in the original JML likelihood;
- optimizer diagnostics for the reduced objective; and
- `FiniteOriginalJMLMaximum = FALSE`,
  `OriginalLikelihoodMaximumAttained = FALSE`, and
  `ReadinessEffect = "none_prototype_only"`.

Neither raw `Estimate` fields nor the stored fit readiness may be overwritten.

## Pilot verification rule

A prototype row is `profile_limit_refit_verified` only when:

1. the reduced optimizer has package convergence severity `pass`;
2. the original-likelihood finite-cap path is nondecreasing within `1e-8`;
3. every finite-cap likelihood is no greater than the reduced supremum within
   `1e-8`; and
4. the largest declared cap is within `1e-8` log-likelihood units of the
   reduced supremum.

The rule verifies the implementation on selected fixtures. It is not a
recovery, uncertainty, sample-size, incidental-bias, or public-readiness rule.

## Mandatory controls

- signed high and low free extremes in RSM, PCM, and the aligned-owner GPCM;
- raw-versus-profile parameter separation;
- monotone finite-cap convergence to the reduced objective;
- anchored extreme retained as `fixed`;
- centered/group-coupled extreme rejected from this profile rule;
- non-JML rejection; and
- malformed-cap rejection.

## Remaining gates

Before any production integration, the profile-limit route still needs
simulation recovery, interval/SE semantics, sparse and weak-link challenge
coverage, multiple extreme proportions, weights and unequal exposure,
interaction cases, independent mathematical/code review, candidate-linked
runtime evidence, and an explicit decision about whether extended-JML values
should remain validation-only. The separate TAM/immer raw/adjusted/bias-
corrected convention grid remains mandatory.
