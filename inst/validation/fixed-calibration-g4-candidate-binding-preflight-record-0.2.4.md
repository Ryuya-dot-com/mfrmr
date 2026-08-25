# Fixed-calibration G4 candidate-binding preflight record

Status: `preflight_implemented_live_candidate_unbound`, 2026-08-25.

## Result

The read-only candidate-binding preflight is implemented. It observes the live
Git commit, tree, branch, complete porcelain status, package version, five-file
production boundary, prospective contract, confirmation worker, confirmation
test, and its own implementation. When a source tarball is supplied, it first
rejects unsafe archive layouts, extracts only into a temporary directory,
hashes every package file, reads the packaged version, and requires the five
production files to match the observed repository byte for byte.

The preflight cannot turn a caller-supplied synthetic clean status into live
readiness: it takes a second Git observation and requires exact identity. Its
manifest is recomputed before a bound candidate can be admitted. Mutating a
readiness flag, source hash, refusal, or observed identity invalidates the
manifest.

The 2026-08-25 live development tree is not a candidate. It contains ongoing
tracked and untracked work and no bound source tarball was supplied. The
preflight therefore returns a typed refusal and keeps current confirmation
unopened. This is the intended result, not a failed numerical cell.

No Git state was changed, no tarball was built or installed, and no fit,
score, replay, checkpoint, package check, platform job, or confirmation result
was executed. The next transition requires one deliberately reviewed clean
commit and its matching `mfrmr_0.2.4.9000.tar.gz` payload.

- `CandidateBindingPreflightImplemented=TRUE`
- `LiveCandidateBindingComplete=FALSE`
- `LiveSourceTarballBound=FALSE`
- `SyntheticCleanPromotionAllowed=FALSE`
- `CurrentExecutionOpened=FALSE`
- `ConfirmationResultObserved=FALSE`
- `CORE05Complete=FALSE`
- `CORE06Complete=FALSE`
- `G4ExitComplete=FALSE`
- `G6Authorized=FALSE`
- `PublicAPIAuthorized=FALSE`
- `NextGate=review-clean-commit-build-and-bind-source-tarball`
