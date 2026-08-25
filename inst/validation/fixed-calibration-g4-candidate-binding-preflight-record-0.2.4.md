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

The first clean-tree source build was retained as a pre-confirmation harness
incident. All four production R files matched byte for byte, while
`DESCRIPTION` differed only because `R CMD build` normalized DCF whitespace
and added `NeedsCompilation`, `Packaged`, `Author`, and `Maintainer`. The
preflight initially refused this payload with `TARBALL_SOURCE_MISMATCH`; no
confirmation cell was opened. The binding rule now requires normalized DCF
equality for every source field, permits exactly those four build-added
fields, and continues to require byte equality for all production R files.

The first fully matching clean-candidate preflight then exposed a zero-refusal
transport bug: the empty reason table combined zero-length code columns with a
length-one disposition column. The preflight stopped before returning a bound
manifest and before any confirmation cell opened. The disposition column now
has exactly the reason-code length, including zero, and an explicit empty-table
regression prevents a success-only recurrence.

The next clean-candidate recomputation retained a second success-only harness
incident before admission: the tarball file-hash vector carried names derived
from the temporary extraction directory, so otherwise identical observations
received different data-frame row names and registry hashes. The manifest
assertion rejected the first observation; no receipt or confirmation result
was accepted. Tarball hashes are now explicitly unnamed and registry row names
reset, so ephemeral extraction paths cannot enter candidate identity.

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
- `InitialDescriptionNormalizationIncidentRetained=TRUE`
- `InitialDescriptionNormalizationIncidentOpenedConfirmation=FALSE`
- `ZeroRefusalTransportIncidentRetained=TRUE`
- `ZeroRefusalTransportIncidentOpenedConfirmation=FALSE`
- `EphemeralTarballRowNameIncidentRetained=TRUE`
- `EphemeralTarballRowNameIncidentOpenedConfirmation=FALSE`
- `CurrentExecutionOpened=FALSE`
- `ConfirmationResultObserved=FALSE`
- `CORE05Complete=FALSE`
- `CORE06Complete=FALSE`
- `G4ExitComplete=FALSE`
- `G6Authorized=FALSE`
- `PublicAPIAuthorized=FALSE`
- `NextGate=review-clean-commit-build-and-bind-source-tarball`
