# FACETS multifacet confirmation semantic-runner record (0.2.3)

Status: no-fit semantic runner frozen on 2026-08-14. No confirmation response,
fit, FACETS process, or result has been opened. External execution remains
unimplemented and unauthorized.

## Why a new result contract was necessary

The candidate-linked pilot retained facet-level maxima after checking FACETS
coordinates. That was sufficient for qualification, but not for a 9,120-row
confirmation audit. It also treated a returned mfrmr fit as sufficient for
comparison eligibility. The confirmation contract must instead preserve every
Element and Step coordinate and independently verify both solvers' numerical
stopping evidence.

The semantic runner therefore reconstructs, without generating scores:

- all 180 frozen case identities;
- all 9,120 expected Element identities; and
- all 1,350 expected Step identities.

The coordinate identities use only fixed facet labels and the frozen seed
registry. They do not depend on generated responses, file bytes, hashes, or
serialized R objects.

## Recomputed eligibility

`ComparisonEligible` is never trusted as an input assertion. It is recomputed
from all of the following:

- completed case status and no recorded error;
- FACETS return code zero;
- reported FACETS convergence values matching the requested specification and
  achieved final score-residual/logit-change criteria;
- a positive final FACETS iteration;
- returned mfrmr fit, convergence code zero, estimation convergence, and a
  finite terminal-gradient sup norm no larger than its recorded review
  tolerance; and
- complete Element and Step coordinate contracts.

Any disagreement between the supplied eligibility flag and those gates fails
closed. Failed or not-run cases remain in the 180-case manifest. Canonical
coordinate evidence is accepted only for eligible cases, so partial output
cannot contaminate the numerical denominator.

## Numerical and precision review

For every eligible coordinate, the runner verifies the supplied signed and
absolute differences from the two estimates before applying the separately
frozen inclusive 0.005-logit rule. Duplicate, missing, unexpected, non-finite,
or arithmetically inconsistent coordinates fail closed.

The runner reports per-case maxima and six model-by-facet cell summaries. The
continuous endpoints use `sd / sqrt(n_eligible)` and 95% t intervals. FACETS
convergence and comparison eligibility use the planned 30-case denominator,
binomial MCSE, and 95% Wilson intervals. MCSE targets remain precision rules,
not substitutes for coordinate agreement.

Complete fixed-core numerical passage requires all 180 cases to be executed
and eligible, all 10,470 coordinate rows to be present, every coordinate to
pass, and every cell MCSE target to be met.

## Current authorization boundary

The reviewer labels supplied evidence as lacking validated external provenance.
Even a complete synthetic pass cannot authorize a confirmation, exact-equality,
or FACETS-replacement claim. The preflight explicitly records that response
generation and external execution are not implemented. The next independent
step is an execution adapter that retains these canonical rows and a separate
authorization record; neither is created implicitly by this semantic runner.
