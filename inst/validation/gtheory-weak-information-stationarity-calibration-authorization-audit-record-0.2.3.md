# Draft.83d2b2b1g7 stationarity-calibration preauthorization audit record

Status: completed repository-only fail-closed audit, 2026-08-10. No reserved
calibration or confirmation data were generated, read, summarized, or used to
select a rule.

## Frozen identities

| Identity | SHA-256 |
| --- | --- |
| b1g5 upstream design | `278353d1668501d04dd3af4adc96dfcd39b232796057242418f89601b22b99ac` |
| b1g5 upstream manifest | `0dbe9e92bed7baa27b6c5f29bed0759a789bcc02c285bd77d749a9cc9666e4d0` |
| b1g6 reference contract | `60e04706736c0e7273dfa321d0d41a3a9ed4bb8362a0b7d428f8507653ecce9a` |
| b1g6 reference manifest | `87b42667d3dbeb2ecd045b23b32cf23a5f9919b0d26ac75c5771baf691770d3a` |
| b1g6 reference execution | `28f155c91065cb56ebe695234eab7867392e25fe413ab362717e760f5e775e72` |
| b1g7 authorization audit | `b293987e768ec0e998d3224a6df0689f0ab8b6f2268704ef422e333865d82765` |
| b1g7 corrected manifest | `7cce9d42faccfbbdf928c9ec4978fef25c50aa562750141fbab45a53b75885f8` |

## Audit finding

The b1g5 sealed 144,000 count applied six candidate profiles to every
backend. Reconstructing the operative registries shows six glmmTMB profiles
but only three lme4 profiles. The corrected planned upper bound is:

| Quantity | b1g5 sealed value | b1g7 prospective value |
| --- | ---: | ---: |
| independent datasets | 3,000 | 3,000 |
| dataset-method units | 12,000 | 12,000 |
| candidate-fit upper bound | 144,000 | 108,000 |
| high-accuracy reference problems | 24,000 | 24,000 |

This is a 36,000-fit accounting correction, not evidence from a simulation
run. b1g5 remains an intact historical design identity; a future runner must
bind the b1g7 corrected manifest instead of rewriting b1g5.

## Reference-coverage audit

Only glmmTMB REML has passed the b1g6 nonreserved high-accuracy replay.
glmmTMB ML has not been replayed, and likelihood-faithful lme4 ML/REML
reference mechanics do not yet exist. Therefore one of four method lanes is
reference-ready and `ReferenceMethodCoverageComplete=FALSE`.

The retained b1g6 receipt revalidates when
`/private/tmp/mfrmr-gtwta-reference-replay-v4.rds` is present. Mutation of its
execution identity fails validation. The local RDS remains a validation cache,
not a packaged release artifact.

## Frozen semantics

The audit freezes two safeguards:

- optimizer profiles are aggregated separately for each dataset, method, and
  model role by minimum returned finite objective, with frozen profile
  priority as the exact-tie rule; neither a stationarity metric nor generating
  truth can choose a profile; and
- boundary, first-order, curvature, and application states remain typed.
  Numerical eligibility requires stationary-zone evidence and a factorable
  positive-definite Hessian. Nonfactorable spectral positivity and near-
  singular curvature are indeterminate, while indefinite curvature or a
  nonstationary-zone score is numerically ineligible.

The production boundary probe, acceptance policy, and execution runner remain
unimplemented. Consequently the frozen state algebra is not a frozen
stationarity criterion.

## Verification

Five focused tests with 71 expectations pass. They cover:

- six-profile glmmTMB versus three-profile lme4 accounting;
- the 108,000 candidate-fit upper bound and unchanged 24,000 references;
- fail-closed state precedence and invalid-state rejection;
- objective-only profile selection, exact-tie priority, and incomplete-ledger
  rejection;
- b1g5/b1g6 hash binding, corrected-manifest mutation rejection, reserved-band
  separation, and the retained b1g6 receipt when locally available.

`PreauthorizationAuditReady=TRUE` records completion of this audit only.
`CalibrationAuthorizationReady=FALSE`, `CalibrationExecutionAuthorized=FALSE`,
`ConfirmationAuthorized=FALSE`, and `InferenceReady=FALSE` prevent that flag
from being interpreted as permission to open reserved data.

## Ordered next gate

The next admissible work is nonreserved method-coverage work: first replay the
b1g6 mechanics for glmmTMB ML, then implement and analytically validate a
likelihood-faithful lme4 reference surface for ML and REML. In parallel only
at the design level, specify the candidate acceptance loss, indeterminate
handling, Monte Carlo uncertainty rule, and exact checkpoint schema. Reserved
replicate 201 remains sealed until all of those receive a new immutable
authorization identity.
