# Fixed-calibration G4 current-source execution record: 53f5f21

Status: `retained_incomplete_44_of_49_worker_failures`, 2026-08-25.

## Bound candidate

- Commit: `53f5f212625761f141d9de5270de41797e38602d`
- Source tarball SHA-256:
  `325a443def729d1beaf76879107489a5565bf9681f72ecb4d2ae9c90779a1f24`
- Tarball file-registry SHA-256:
  `babeeb7cf28bc5584dba3b355625265c4a4a5e71a2562caa7249094f13454df5`
- Candidate manifest SHA-256:
  `7df82660029a60f45c62a15b856b46ad1b7accf0c68e7b2564bd64d993c27213`
- Candidate binding complete before execution: `TRUE`
- Worker/denominator static match before execution: `49/49`
- Exact tarball `R CMD check --no-manual`: `Status: OK`
- Native platform: `aarch64-apple-darwin23`, R `4.6.1` release
- Execution interval: `2026-08-25T04:58:37.912286Z` to
  `2026-08-25T04:58:47.095690Z`
- Retained receipt SHA-256:
  `10d0a6a765e54b9eee47a7d243a6235851c4d7f0af04b92850b451d0e1739d24`

## Complete denominator result

All 49 rows were returned without dropping or pooling a failure. Forty-four
passed and five were retained as failures. All three resource observations
passed their frozen ceilings; the 30,000-row observation took 1.294 seconds,
profiled 676,258,744 allocated bytes, and serialized to 7,932,914 bytes.

The retained failures were:

1. `SCORING_ALGORITHM_MUTATION_REFUSAL`: production refused with
   `SCORING_BASIS_UNSUPPORTED`; the worker incorrectly required
   `IDENTITY_COMPONENT_MISMATCH`.
2. `QUADRATURE_ORDER_MUTATION_REFUSAL`: production refused with
   `QUADRATURE_ORDER_INVALID`; the worker incorrectly required
   `IDENTITY_COMPONENT_MISMATCH`.
3. `INTERACTION_REPLAY_FULL_ROUNDTRIP`: the worker requested the optional
   `predictions` export component while supplying no prediction object.
4. `CHECKPOINT_ANCHOR_MUTATION_SAME_LAYOUT_REFUSAL`: the worker supplied a
   named numeric vector although the public `fit_mfrm()` anchor contract
   requires a `Facet`/`Level`/`Anchor` table.
5. `HYBRID_CHECKPOINT_WRITE_RESUME`: the checkpoint was written and the
   installed implementation emitted the expected completed-warm-start
   message in a diagnostic reproduction, but the worker had suppressed that
   message before testing for it.

These are worker-specification failures, not evidence that the corresponding
production boundary accepted an unsafe state. They nevertheless fail this
candidate. The receipt is not rewritten and the 44 passing cells are not
pooled into a future result.

Notable retained passes include maximum default-31 posterior differences of
`6.66e-16` (RSM) and `1.33e-15` (PCM), source-one/default-31 differences of
`7.77e-16` and `1.11e-15`, minimum JML-source-one posterior SD `0.287`, and
exact pure-EM continuation (`parameter difference = 0`,
`log-likelihood difference = 0`). Prior sensitivity crossed its review rule
at `0.210`; the no-robustness-claim disposition remains unchanged.

## Disposition

Because worker decision logic will change after observing this result, the
modular-1009/default and modular-1013/source-one confirmation identities are
consumed for G4 authorization. A replacement contract must use new generator
moduli, offsets, fixture IDs, and calibration IDs. Historical explicit-nine
controls remain non-authorizing.

- `CandidateBindingComplete=TRUE`
- `CurrentExecutionOpened=TRUE`
- `ConfirmationResultObserved=TRUE`
- `DenominatorRowsRetained=49`
- `PassedCells=44`
- `FailedCells=5`
- `ResourceScalesPassed=3`
- `CORE05Complete=FALSE`
- `CORE06Complete=FALSE`
- `G4ExitComplete=FALSE`
- `G6Authorized=FALSE`
- `PublicAPIAuthorized=FALSE`
- `RetrySameCurrentIdentityAuthorized=FALSE`
- `NextGate=new-disjoint-v3-contract-and-candidate-binding`
