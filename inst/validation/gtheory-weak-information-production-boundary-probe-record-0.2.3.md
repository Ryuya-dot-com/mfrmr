# Draft.83d2b2b1g12 production boundary-probe record

Status: completed repository-only mechanics slice, 2026-08-10. No reserved
calibration or confirmation response was generated, opened, summarized, or
used.

## Frozen identities

| Identity | SHA-256 |
| --- | --- |
| upstream b1g11 contract | `1dcc877da78d3975271b33629b3d67bd9f0f48d675fb1ed62e5704baa46b8b1a` |
| b1g12 policy | `fb7f938a0e1e5b7be598a180f7d5c06eb3176ebea7f1bfc269491befa865cb6c` |
| b1g12 analytic audit | `272e5ee2c274c8972ecde6feb039db02e9beb937d4db910555812c35af627eab` |
| b1g12 contract object | `53a36d72388eb8b4e096ef817aaf94959aa1b3fd3257190cf5c0a8164383d9da` |
| source artifact | `8c9406cb44e55f6544dc054fc5231c478cc61b48760d432b6ab020a31d33e66d` |
| contract artifact | `34a3438afb8d9246877f14d436b8c6df73ae3618a130cf6a7f62498037afcffe` |
| focused test artifact | `cc83cd6b20e80763a31003b039c7c6f3e8901c76be6eb672adff0538c974ab10` |

## Result

The production probe now preserves the backend parameterization instead of
pretending that lme4 theta zero and glmmTMB negative log-SD are the same
finite coordinate. Their common interpretation is conditional on a verified
full-profile/reduced-fit objective identity.

Every profile point reoptimizes all nuisance coordinates. Objective direction
must be both monotone and larger than a binary64-derived resolution tolerance.
Flat, nonmonotone, endpoint-mismatched, and failed profiles retain distinct
inconclusive or non-evaluable routes. First-order zero is never sufficient.

The focused real-backend fixture passed ML and REML for both packages. All
four profiles supported a finite interior and matched their reduced endpoints.
The observed differences ranged from `1.9895e-13` to `6.5340e-09`, below the
prespecified relative endpoint tolerance. The lme4 REML fixture also verified
that a primary L-BFGS-B failure is recorded and recovered only by the single
frozen `nlminb` fallback.

Eight focused tests with 120 expectations pass without failures, errors,
warnings, or skips.

## Readiness interpretation

The following narrow flag is newly true:

- `ProductionBoundaryProbeReady`.

The following remain false:

- `RunnerImplementationReady`;
- `CalibrationAuthorizationReady` and `CalibrationExecutionAuthorized`;
- `CalibrationDataGenerated` and `CalibrationResultsViewed`;
- `StationarityThresholdFrozen` and `StationarityCriterionReady`; and
- confirmation, inference, coefficient, decision, and D-study readiness.

The next admissible slice is the exact-resume runner and its nonreserved
mechanics audit. Only a later authorization identity may reconsider opening
replicate 201.
