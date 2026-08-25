# Fixed-calibration G4 current-source execution record: 5af00ed

Status: `local_complete_49_of_49_hosted_matrix_open`, 2026-08-25.

## Bound candidate

- Commit: `5af00ed64b62be3c4314a7095c937e279649ccbd`
- Contract: `mfrmr_fixed_calibration_g4_current_source_evidence_v4`
- Source tarball SHA-256:
  `d7bf38b7898f439da8f3162d107e375e42a77a1e948364abdd1c24334ac3f840`
- Tarball file-registry SHA-256:
  `60edf899d1caee3ff9f64eb87bc3b39d0d2d4381829cd750b131b28d8742895b`
- Candidate manifest SHA-256:
  `222a9f985f6305cf110c447dd83f3cb04bf5d7317869c33f429105744d3bea67`
- Production-boundary registry SHA-256:
  `8bc3ead3efed7296f0f4af1b5a7197885e42d6181cb1a6d77592dff229103547`
- Support registry SHA-256:
  `99190cb14609d005e61ff111d1fa35206d573248c9f490409b80b3895e38cdb5`
- Exact tarball `R CMD check --no-manual`: `Status: OK`
- Native platform: `aarch64-apple-darwin23`, R `4.6.1` release
- Worker interval: `2026-08-25T06:00:57.080476Z` to
  `2026-08-25T06:01:07.127990Z`
- Current-confirmation receipt SHA-256:
  `09b016e941005a4b33b023a9007f1edd68b9b9b8074d77eec0b7fe88425106e6`
- Local hosted-cell receipt SHA-256:
  `fee7377a167fe165034cec84f051c96f3e4ecd9d47a050d8a68d8a86787fc12f`

## Complete local denominator result

All 49 required rows were returned and passed. All three prospectively frozen
resource scales passed. The 120-, 6,000-, and 30,000-row scoring observations
took 0.009, 0.246, and 1.262 seconds; profiled allocation was 58,496,
31,332,408, and 676,258,744 bytes; serialized results were 42,104, 1,594,914,
and 7,932,914 bytes.

The prior-sensitivity cell observed a maximum EAP change of `0.215858` against
the `0.20` material-review trigger. It passed with the retained disposition
`material review retained; no robustness claim`. This is neither a robustness
claim nor a numerical failure.

## Boundary

This record establishes the native local candidate result only. It does not
substitute for the frozen hosted macOS, Windows, Ubuntu devel, Ubuntu release,
or Ubuntu oldrel-1 cells. The local result therefore leaves hosted completion,
CORE-05, CORE-06, and G4 open at the repository decision boundary.

- `CandidateBindingComplete=TRUE`
- `CurrentExecutionOpened=TRUE`
- `ConfirmationResultObserved=TRUE`
- `DenominatorRowsRetained=49`
- `PassedCells=49`
- `FailedCells=0`
- `ResourceScalesPassed=3`
- `G4LocalCandidateComplete=TRUE`
- `HostedPlatformMatrixComplete=FALSE`
- `CORE05Complete=FALSE`
- `CORE06Complete=FALSE`
- `G4ExitComplete=FALSE`
- `G6Authorized=FALSE`
- `PublicAPIAuthorized=FALSE`
- `NextGate=hosted-five-platform-current-candidate-matrix`
