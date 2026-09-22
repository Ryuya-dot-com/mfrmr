# Multivariate G-theory D-SIM-4 admission decision (0.2.4)

Date: 2026-08-31
Scope: repository-internal package-capability validation
Decision: `admit_contract_construction_only`
Current disposition: `dsim4_contract_construction_admitted_execution_closed`

## Exact identity

- Admission contract:
  `a4158f9afc9aab4e250a6b4a1c5341299ba79da094fb5b60b5bf72928ff72380`
- Admission manifest:
  `2c98b5f29bafca074f4d095ce51c5c9ad2e04253cef48292a691b307d9c45282`
- Parent v4 capability contract:
  `9b68d194e13625ec73992f314a9494e29c36f77838e0da19a15020f2af74a214`
- Parent D-SIM-3 descriptive contract:
  `e274e2a73934a94578b79af347b5643724c56b99490791b693cb2cc12edd98c5`
- Parent D-SIM-3 descriptive manifest:
  `ad97f0f48f382bd41c6353dab6ce1405453b6146ce3fd4dfbb4ea04406fb8f8f`
- Admission source SHA-256:
  `c6fd3d1e12ae4999d1ab712ac332dd611e6b4a59833db71740ee2b2c78e0227e`
- Runner SHA-256:
  `c691c5a361a9cc31c67065f8564b09efe229560c0b396ab245c95142bf4705eb`
- Local binary admission evidence SHA-256:
  `637c0fb0715079da48961fc4a2da286f3fdda08754617c3099d56711b937dea2`

The local binary is stored outside the package payload at
`validation-results/gtheory-multivariate-dsim4-admission-0.2.4/admission-manifest.rds`.

## Decision

D-SIM-4 contract construction is admitted. D-SIM-4 is the package's
confirmation-freeze stage, not confirmation execution. This decision therefore
authorizes one bounded, role-complete contract-design task and nothing else.
It does not authorize a new seed, response, backend call, fit, D-SIM-5 launch,
simulation-validation claim, reference-validation claim, or public support.

The admission is based on 8/8 required criteria:

1. the D-SIM-3 exploratory denominator has a final read-only adjudication;
2. all 188 direct-truth scalar positions and the failed route remain counted;
3. standardized bias, interval coverage, and Monte Carlo acceptance remain
   genuinely unanswered with two replicates per scenario;
4. ABS-PHI and REL-G remain separate package estimands;
5. the finite-sample signal is nontrivial rather than an exact mechanical pass;
6. within-backend parity is explicitly not an independent reference;
7. no exploratory result has been promoted to validation or support; and
8. package maturity remains `specified`.

This is a package-validation decision. It does not depend on an operational
owner, a user action threshold, or evidence that users should enable a feature.
Users retain responsibility for substantive D-study choices; the package
retains responsibility for establishing whether its stated estimands and
inferential procedures work in their declared design domain.

## Why admission is warranted

Stopping permanently at D-SIM-3 would leave the central package question
unanswered. The 184/188 available direct comparisons describe finite-sample
error, but cannot assess the v4 standardized-bias or 95% interval-coverage
rules. ABS-PHI and REL-G RMSE are 0.05240607 and 0.05008863, the largest
absolute error is 0.3240437 in boundary profile D3-S010, and 40/40
multivariate scalar pairs share a backend and therefore do not supply an
independent reference. These facts warrant confirmation design; they do not
choose a favorable confirmation subset or acceptance threshold.

The admission also stops the local-optimization loop. No additional D-SIM-3
micro-scenario, boundary patch, diagnostic exclusion, or route vote is the
next unit. Either a complete D-SIM-4 contract is frozen or this lane remains
closed.

## Conditions before D-SIM-5

The admission freezes 0/14 confirmation requirements. The next contract must
bind all 14 together before any new response is generated:

1. separate recovery, interval-coverage, and fail-closed questions;
2. both nonvoting estimands;
3. all four scenario roles: boundary, closure, full anchor, and targeted
   structural;
4. a coverage-based selection rule that cannot use D-SIM-3 error ranks;
5. the unchanged v4 regular-interior standardized-bias and coverage rules;
6. structural and attempt-accounting rules for boundary/control cells;
7. an exact interval construction and nominal level;
8. a replication count derived from a declared worst-case MCSE target;
9. an actually independent formula or implementation on a named overlap;
10. content-addressed source, dependency, platform, and implementation
    identity, without an operational-owner gate;
11. a disjoint unopened seed namespace and exact seed formula;
12. one terminal state per attempt, with no replacement, replenishment, or
    post-outcome exclusion;
13. descriptive runtime and peak-memory reporting that is not an enablement
    gate; and
14. invalidation and versioning after any estimator, generator, truth,
    interval, or routing change.

D-SIM-3 high-error profiles may justify retaining the boundary role, but may
not select individual confirmation scenarios or receive special weights.
Conversely, low-error anchor or structural profiles may not be preferentially
selected. The confirmation multiverse must remain role-complete and
outcome-independent at the new-seed stage.

## Claim boundary

- D-SIM-4 contract construction admitted: **yes**
- D-SIM-4 confirmation freeze complete: **no**
- D-SIM-5 execution authorized: **no**
- planned response generation allowed: **no**
- simulation validation ready: **no**
- reference validation ready: **no**
- public support ready: **no**
- feature maturity: `specified`

The next bounded task is to construct and freeze the single D-SIM-4 contract.
Execution remains closed until all 14 requirements are exact and jointly
validated.
