# Fixed-calibration G4 current-source execution record: 7afff78

Status: `retained_incomplete_48_of_49_review_rule_failure`, 2026-08-25.

## Bound candidate

- Commit: `7afff78aeda811e1e9e87ab9cb7f7cd8de6734e7`
- Contract: `mfrmr_fixed_calibration_g4_current_source_evidence_v3`
- Source tarball SHA-256:
  `63ff0c960e3f870523789e3aa7b740e6150f1f2dc7b4eddf898184024a0da463`
- Tarball file-registry SHA-256:
  `1de802cbbe19d45ba5a95ee5aae3a172285f9b5cac2b0a9d1e57fb39f839144b`
- Candidate manifest SHA-256:
  `35b039b329df2d80605c95083c1bc9029139d635f2235b464367dfdbd9008c06`
- Exact tarball `R CMD check --no-manual`: `Status: OK`
- Native platform: `aarch64-apple-darwin23`, R `4.6.1` release
- Execution interval: `2026-08-25T05:07:41.621133Z` to
  `2026-08-25T05:07:51.960464Z`
- Retained receipt SHA-256:
  `a693863ddb57ab4529d1f7b5797e5d5dfecee5acfc7728b1db18b1bf6db52d2b`

## Complete denominator result

All 49 rows were returned. Forty-eight passed, including the five paths that
failed under the consumed v2 worker, and one was retained as a failure. All
three resource scales passed; the 30,000-row observation took 1.296 seconds,
profiled 676,258,744 allocated bytes, and serialized to 7,932,914 bytes.

The sole failure was `PRIOR_SENSITIVITY_ORACLE`. The frozen rule's comparison
is `review_if_greater_or_equal`: a finite shift at or above 0.20 receives a
material-review disposition, while a finite shift below 0.20 remains below
that review trigger. The worker incorrectly treated failure to reach 0.20 as
a numerical cell failure. This is a worker decision-rule error, not a
production scoring failure and not evidence for prior robustness.

Notable passes include default-31 posterior differences of `2.66e-15` (RSM)
and `1.11e-15` (PCM), source-one/default-31 differences of `1.33e-15` and
`1.11e-15`, minimum JML-source-one posterior SD `0.293`, exact interaction
replay, anchor-objective checkpoint refusal, and hybrid checkpoint reuse.

## Disposition

The v3 modular-1019/default and modular-1021/source-one identities are
consumed. Its 48 passes are not pooled into a later result. A v4 contract must
freeze the correct two-branch review disposition and use new generator
moduli, counts, offsets, fixture IDs, and calibration IDs before execution.

- `CandidateBindingComplete=TRUE`
- `CurrentExecutionOpened=TRUE`
- `ConfirmationResultObserved=TRUE`
- `DenominatorRowsRetained=49`
- `PassedCells=48`
- `FailedCells=1`
- `ResourceScalesPassed=3`
- `CORE05Complete=FALSE`
- `CORE06Complete=FALSE`
- `G4ExitComplete=FALSE`
- `RetrySameCurrentIdentityAuthorized=FALSE`
- `NextGate=new-disjoint-v4-contract-and-candidate-binding`
