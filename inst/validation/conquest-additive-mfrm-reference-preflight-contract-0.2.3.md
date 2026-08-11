# ConQuest additive mfrmr reference preflight for 0.2.3

Status: source-bound four-arm mfrmr preflight completed, 2026-08-11. This is
internal reference evidence only. It does not execute ConQuest, bind a release
candidate, set an external equivalence tolerance, or establish inferential or
cross-engine equivalence.

## Why the design was reduced before fitting

The original no-fit draft used 3 Raters and 4 Criteria. With four categories,
12 responses per Person, and 96 distinct continuous-covariate rows, the strict
MML all-response-pattern audit would require approximately
`96 * 4^12 = 1.61 billion` pattern/design evaluations. A trial fit therefore
converged numerically but remained `InferenceReady = FALSE` because the exact
audit exceeded its execution limit. That was a self-inflicted design cost, not
evidence about ConQuest agreement.

The sealed reduction keeps both facets but uses 2 Raters, 2 Criteria, and a
balanced numeric covariate with levels `-1` and `1`. It has 96 Persons, four
responses per Person, 384 observations, complete crossing, all 16
Rater-by-Criterion-by-category cells nonempty, and no all-minimum or all-maximum
Person. Exact reuse reduces the all-pattern audit to `2 * 4^4 = 512`
pattern/design evaluations. The RSM and PCM free dimensions are independently
7 and 9.

## Source and mathematical binding

`conquest-additive-mfrm-reference-preflight-0.2.3.R` requires the loaded mfrmr
namespace path to equal the requested working-tree root and records SHA-256 for
`DESCRIPTION`, `NAMESPACE`, every `R/*.R` file, the no-fit design, and the
preflight itself. At the recorded run, the combined source-tree SHA-256 was
`8ed5fb40efd5f6c98fbe0cdd99f5b40894d601d283a9ebb067f785da76c94dd6`.

For every RSM/PCM q=31/q=61 arm it independently:

1. extracts the population, Rater, Criterion, and step coordinates;
2. checks all declared sum-zero constraints and the 7/9 free dimensions;
3. constructs standard-normal Gauss-Hermite nodes and weights by a separate
   Golub-Welsch implementation;
4. evaluates the declared adjacent-category probability oracle;
5. reconstructs the person-marginal likelihood independently;
6. compares that reconstruction with the fitted mfrmr log likelihood and the
   package conditional probability kernel; and
7. requires the 512-pattern information diagnostic to be locally full column
   rank, nullity zero, and rank-tolerance insensitive.

## Recorded source-bound result

| Arm | Npar | LogLik | Deviance | terminal gradient | oracle LogLik abs diff | probability max abs diff |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| RSM q31 | 7 | -465.4921978889994 | 930.9843957779988 | 4.9633927e-06 | 5.6843419e-14 | 1.5543122e-15 |
| RSM q61 | 7 | -465.4921978889982 | 930.9843957779965 | 4.9604265e-06 | 5.6843419e-14 | 1.7763568e-15 |
| PCM q31 | 9 | -465.2523897842369 | 930.5047795684739 | 1.2972456e-06 | 5.6843419e-14 | 1.6653345e-15 |
| PCM q61 | 9 | -465.2523897842357 | 930.5047795684713 | 1.2975280e-06 | 1.1368684e-13 | 1.7763568e-15 |

All four optimizers reported `converged`. The all-pattern local ranks were 7
and 9 with nullity zero and no tolerance sensitivity. The observed q31/q61
deviance differences were `2.2737368e-12` for RSM and `2.5011104e-12` for PCM.
These differences are recorded as integration observations only; no
acceptance threshold or pass decision was selected after seeing them.

All four fits retain `InferenceReady = FALSE` and
`design_rank_not_evaluated`. This is expected under the current readiness
policy: even a completed full-rank all-pattern information calculation is
classified as a local diagnostic and is not promoted to structural
identification. The preflight therefore distinguishes a valid numerical
cross-engine objective reference from an inferential-readiness claim.

## Decision and next gate

The source-only validator returns `no_go_native_matrix_and_candidate_missing`:

- the mfrmr reference and independent oracle are ready;
- inference readiness remains review by explicit policy;
- ConQuest execution is outside this source-only function;
- its base artifact does not itself contain native `amatrix` coordinates or
  raw export tokens;
- the release candidate is not bound; and
- external comparison remains unauthorized and not comparison-ready.

The preliminary sandbox-crash diagnosis was subsequently disproved by the
user's interactive run and an unsandboxed control. The SHA-matched executable
completed a minimal command and all four RSM/PCM q31/q61 arms. Native A
matrices are exact and descriptive coordinate differences from this reference
are at most `2.74e-6`; raw-token rounding remains unestablished. During that
review, the reference exporter was repaired so PCM step rows can no longer be
written as missing, and this validator now requires every exported parameter
estimate to be finite. See
`conquest-additive-native-four-arm-record-0.2.3.md`.

The combined external state is
`four_arm_native_outputs_ready_tolerance_and_candidate_missing`, not a
scientific-equivalence pass. Sparse assignment, workload imbalance,
missingness, extreme raters, and larger simulation remain downstream of an
independent tolerance decision and a fresh candidate-bound core rerun.
