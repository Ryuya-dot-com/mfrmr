# ConQuest P2 additive adversarial fixture record for mfrmr 0.2.3

Status: deterministic P2 additive fixtures, independent A/C coefficient maps,
conditional-probability oracle, and continuous-target marginal-likelihood
oracle complete; metric rules and independent review pending, 2026-08-15.

- Specification: `0.2.3-conquest-p2-additive-adversarial-fixtures-v1`
- Contract: `mfrmr_conquest_p2_additive_adversarial_fixtures_v1`

This work was completed without launching ConQuest or fitting mfrmr. It creates
no candidate, tolerance, numerical pass, or scientific-equivalence claim.

## Fixed design axis

The fixtures are disjoint from Candidate 003. They use 48 Persons, 4 Raters,
3 Criteria, categories `0:3`, and a balanced numeric `X` coded `-1/+1`.
Candidate 003 used the earlier 96-Person, 2-Rater, 2-Criterion design. Every P2
fixture has a semantic identifier under the new P2 contract rather than
reusing a prior execution identity or byte digest.

All fixtures use the same truth:

- population mean `0.10 + 0.45 X` and variance `0.70`;
- four sum-zero Rater severities;
- three sum-zero Criterion difficulties;
- either one shared sum-zero three-transition RSM ladder or three
  Criterion-specific sum-zero PCM ladders.

The response arrays are deterministic and reconstructable from Person, Rater,
and Criterion indices. No pseudorandom response draw or opened external result
selects their support.

## Thirteen P2 fixtures

The fixture set covers all eleven prospective P2 additive rows and both P2
negative controls:

| Design pair/control | Observed rows | Components | Positive Rater edges | Graph bridges | Rater-load range |
| --- | ---: | ---: | ---: | ---: | ---: |
| RSM/PCM connected multibridge | 288 each | 1 | 4 | 0 | 72--72 |
| RSM/PCM weak single bridge | 240 each | 1 | 4 | 1 | 54--66 |
| RSM/PCM unequal workload | 396 each | 1 | 6 | 0 | 72--144 |
| planned-row absence | 288 | 1 | 4 | 0 | 72--72 |
| explicit missing values | 288 retained of 576 physical rows | 1 | 4 | 0 | 72--72 |
| rare boundary categories | 288 | 1 | 4 | 0 | 72--72 |
| nonextreme Person | 288 | 1 | 4 | 0 | 72--72 |
| extreme Person | 288 | 1 | 4 | 0 | 72--72 |
| unused intermediate category | 288 | 1 | 4 | 0 | 72--72 |
| disconnected negative control | 288 | 2 | 2 | 2 | 72--72 |

The connected multibridge graph is a four-edge cycle: removing any single edge
does not disconnect it. The weak-link graph contains a three-Rater cycle plus
one two-Person edge to the fourth Rater; exactly that edge is a graph bridge.
The disconnected control has two components and is ineligible before numeric
agreement.

## Missingness, categories, and extremes

The planned-row and explicit-missing fixtures reduce to exactly the same 288
nonmissing rows in the same semantic order. Their independently reconstructed
continuous-target log likelihood is also exactly equal. This freezes the
expected equality without claiming that arbitrary missingness mechanisms are
equivalent.

The rare-boundary fixture contains 12 category-0, 132 category-1, 132
category-2, and 12 category-3 responses. Boundary observations are distributed
across Persons so this fixture has no minimum- or maximum-score Person. The
separate extreme fixture has exactly one minimum-score and one maximum-score
Person. The unused-category control contains zero category-1 responses while
retaining categories 0, 2, and 3, and must be rejected or typed ineligible.

## Independent A/C and probability reconstruction

For each Rater--Criterion--category row, the independent conditional-log-kernel
contract constructs:

- a C-side category/trait score `k`;
- sum-zero contrast coefficients for Rater and Criterion effects; and
- cumulative shared-step coefficients for RSM or Criterion-blocked cumulative
  step coefficients for PCM.

The resulting RSM A coefficient matrix is `48 x 7`; adding three population
coordinates gives free dimension 10. The PCM A matrix is `48 x 11`; adding the
same population coordinates gives free dimension 14. Direct adjacent-category
probabilities and matrix probabilities were compared over 120 combinations of
model, ability, Rater, and Criterion. The maximum absolute difference was
`3.330669e-16`.

These are repository-defined conditional-log-kernel matrices. A future native
ConQuest A/C export must be mapped to this declared orientation and row key; a
matching dimension or label alone is insufficient.

## Continuous-target oracle

For every one of the thirteen fixtures, each Person contribution is integrated
over the standard-normal residual using independent adaptive numerical
integration of the declared population model and direct probability oracle.
All 48-Person log likelihoods are finite; totals range from approximately
`-653.306` to `-337.713`. The oracle is a common continuous target, not a
ConQuest or mfrmr quadrature result and not an acceptance tolerance.

## Remaining gates

The fixture/oracle implementation returns
`P2_additive_fixtures_and_independent_oracles_ready_for_review`, while retaining
all of the following as false:

- `MetricSpecificRulesFrozen`;
- `ExternalExecutionAuthorized`;
- `ComparisonPassed`; and
- `ScientificEquivalenceInferred`.

Before an external P2 slice is eligible, maintainers must still freeze typed
extreme/boundary quantities, parameter-class coordinate and decision metrics,
raw-token rules, complete-denominator adjudication, stop/invalidation rules,
and the expiry-aware execution cap. P0/P1 independent reviews and the remaining
P3 independent-review work also stay open.

## Artifacts

- `conquest-p2-additive-adversarial-fixtures-0.2.3.R` owns the deterministic
  generator, graph/support audits, A/C coefficient maps, and mathematical
  oracles.
- `test-conquest-p2-additive-adversarial-fixtures.R` exercises all thirteen
  fixtures and runs every continuous-target oracle without an external engine.
- This record states the observed semantic summaries and remaining gates.

No hash is used as a scientific acceptance criterion. No public README or NEWS
claim follows from this internal fixture construction.
