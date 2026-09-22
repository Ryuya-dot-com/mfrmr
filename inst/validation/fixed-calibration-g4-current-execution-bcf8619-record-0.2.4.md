# Fixed-calibration G4 v5 current-source execution record: bcf8619

Status: `local_complete_49_of_49_hosted_matrix_open`, 2026-08-25.

## Bound candidate

- Commit: `bcf86197619e3eae4c7cdd5288b797549df47c99`
- Contract: `mfrmr_fixed_calibration_g4_current_source_evidence_v5`
- Source tarball SHA-256:
  `fd0981a87b8d30f5eb8a7d6892dd1e86a2e0b46bd82677cfebc5fe631b72b267`
- Tarball file-registry SHA-256:
  `0f20959c67620653dadb672dd0cc618dff04fff0dc88e2aecea9dda114feb917`
- Candidate manifest SHA-256:
  `c7f7302a4ab85753e3b1b14f31ff21f1bcea2615a8ec17e6677508a4cc442003`
- Production-boundary registry SHA-256:
  `ab36f6e5d8a7a61dd758208a809d2668ccd816a8e2a30bcf8708396d8624c2b7`
- Support registry SHA-256:
  `6cb6e592e48a89862061fb789935789082b0cb08df4b4f51cbce0ca22d095ca7`
- Exact tarball `R CMD check --no-manual`: `Status: OK`
- Native platform: `aarch64-apple-darwin23`, R `4.6.1` release
- Worker interval: `2026-08-25T09:29:08.610377Z` to
  `2026-08-25T09:29:18.772792Z`
- Current-confirmation output SHA-256:
  `2da35db4c818dad980ceeabb9b8835c8be4382f9dcab3cfe4f2423f4a65d898f`
- Local hosted-cell receipt hash:
  `afb5d8f9db875f221123c1dbae13e2539c9292ded9989d519738e474393f273f`

## Complete local denominator result

The check-installed package completed all 29 repository static evidence tests
with zero failures, errors, warnings, or skips. The disjoint modular-1039/1049
v5 worker then returned all 49 required rows with 49 passes and zero failures.
All three resource scales passed their frozen regression ceilings.

The 120-, 6,000-, and 30,000-row observations took 0.012, 0.244, and 1.271
seconds. Profiled allocation was 58,496, 31,332,408, and 676,258,744 bytes;
serialized results were 42,104, 1,594,914, and 7,932,914 bytes. These are
regression observations, not public performance promises.

This result binds the clean local candidate only. It does not substitute for
the hosted macOS prerequisite, four downstream OS/R cells, or five-receipt
aggregation. G4 therefore remains open.

- `CandidateBindingComplete=TRUE`
- `CurrentExecutionOpened=TRUE`
- `ConfirmationResultObserved=TRUE`
- `V5DisjointIdentitiesUsed=TRUE`
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
- `NextGate=hosted-five-platform-v5-candidate-matrix`
