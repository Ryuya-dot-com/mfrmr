# D-SIM-3 Bounded Exploratory Launch Record (0.2.4)

Date: 2026-08-31
Scope: repository-internal, fixed-denominator exploratory execution
Disposition: `bounded_exploratory_execution_complete_unadjudicated`

## Frozen identity

- Contract: `MFRMR-GTHEORY-MV-DSIM3-BOUNDED-LAUNCH-V1`
- Contract hash: `5ea53cc09a1261b1b73eac3d72f433273a454aaa1ae7ee6302921c278dd7a642`
- Launch-input hash: `b3df6175d1ec82e54b97be466a08a8dc16f115a1aa1cbca2425d5f4ed29679b4`
- Result-manifest hash: `84b89383d974f7a3a40df738b0ce618f86324d3b1ea54ea99ea2ed20a4019aea`
- Completion hash: `fddce2750f0d873ff9394dce5a1d565988ecf33aef255f739a3fcbd7509d8b9f`
- Parent final-readiness manifest:
  `3e3106fa3550c83696235b95b4e9e2ea30b512d5e6c670f39eeb30e6aee82a81`
- Controller source SHA-256:
  `f91e6657550be7bc5da5c4abbe789797451858179fc72e979e47d75af913483a`
- Worker source SHA-256:
  `cc3239a00235a2d9eb9d47e2c6d4a18d2172b5d7290ba5a0922ce32256aa0e27`
- Runner source SHA-256:
  `72b36d8b325233d43e0e9bfd1a088547d666efcf5b9cd92ccb33f73491dc343f`

The raw local evidence is retained under
`validation-results/gtheory-multivariate-dsim3-bounded-exploratory-launch-0.2.4/`.
That directory is deliberately outside the package payload. Its principal
file hashes are:

- `launch-input.rds`:
  `6eeea2a9a71236ea4bc05ad1f300a8787803719d19d1f2e87cf95c647569ba1a`
- `launch-result.rds`:
  `67ac964b910a4a136c53d1959a6f9d22b326a77c9e3cdb9eeb52c69a7e842224`
- `run-complete.rds`:
  `84e858bb7695aadfed06c1a8219566222c75a9cfccf3a35cfcee8ad354aeda96`

## Attempt accounting

- All 42/42 registered datasets were attempted once; 42/42 child processes
  exited successfully and 42/42 atomic checkpoints were committed.
- New checkpoints: 42; resumed checkpoints: 0; parent-created failure
  checkpoints: 0. No attempt or seed was replaced or rerun.
- Dataset generation terminal states: 42 `generation_complete`, zero
  generation failure, and zero generation resource-limit state.
- Candidate route terminal states: 49 `complete_nonpromoting` and one
  `metric_failure`, preserving all 50/50 attempted routes.
- Planned metric results: 98 `complete_nonpromoting` and two
  `metric_failure`, preserving all 100/100 metric requests.
- Exact terminal receipts: 92/92, with exactly one receipt for every one of
  42 dataset and 50 candidate-route terminal requests.
- The full denominator remains 210 routes and 420 route-estimand coordinates;
  all 160 frozen no-call routes were retained without execution.

The 42 child processes used 3,462.166 seconds in total (median 81.288,
maximum 89.652 seconds per dataset). Peak observed RSS was 857.672 MiB, below
the frozen 8,192 MiB dataset-pipeline ceiling. Memory was observed for all
42 processes.

## Preserved non-complete route

The sole non-complete route is not a missing result and was not replenished:

- Scenario: `D3-S012`; replicate: 2; data seed: `856012002`
- Dataset: `D3P-D024-0616c89d54f13664`
- Route: `separate_univariate`
- Route unit: `D3P-U119-6a28d196b52d2c42`
- Backend request: `D3X-B030-56b87694ee9bddf5`
- Terminal receipt: `D3AC-TR-27bdd8487bf4926a695e`
- Terminal receipt hash:
  `27bdd8487bf4926a695ec39c7e76ddb85aff3f3fe83f985aaa24223b7a559f99`
- State: `metric_failure`; evidence text:
  `A planned metric vector is incomplete.`

The backend was called and returned both planned stratum fits. One fit was
singular and carried a convergence message. No complete named coefficient
vector was returned, so both `ABS-PHI` and `REL-G` metric requests remain
uncomputed. The route is retained in every denominator; it must not be rerun,
excluded, pooled, voted away, or assigned a replacement seed.

## Diagnostics and non-claims

- Actual fit calls: 102; singular fit calls: 21; warning fit calls: 0;
  convergence-message fit calls: 21.
- Diagnostic overrides, scalar pooling, package-selected decision weights,
  historical receipt inheritance, and public-support promotion are all zero.
- The planned 856 RNG streams, exploratory responses, backend calls, fits,
  metrics, and planned receipts are now real exploratory evidence.
- Recovery evidence remains uncomputed. This record does not establish bias,
  RMSE, interval coverage, reference parity, model adequacy, confirmation,
  simulation validation, or public package support.

## Next bounded transition

Compute the prespecified descriptive recovery and failure-denominator
summaries from these immutable checkpoints. Keep `D3-S012` replicate 2 in all
denominators, distinguish singular/convergence diagnostics from the one metric
failure, and do not use route voting or outcome-adaptive exclusion. Only after
that descriptive adjudication may a separate D-SIM-4 confirmation contract be
considered; this exploratory result cannot authorize it by itself.
