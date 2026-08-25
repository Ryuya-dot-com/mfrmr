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

Commit `c65ad6141ed8ab55f01e12ed076c3dd18baff67b` then produced the first
fully bound candidate manifest and its exact source tarball passed local
`R CMD check --no-manual`. Before a current confirmation cell was opened, a
denominator audit found that the prospective contract declared 49 cells but
the hash-bound worker did not yet expose a one-to-one executable cell
registry. That candidate is retained as an admitted pre-confirmation harness
milestone, not as confirmation evidence, and is superseded by the worker
hardening described here.

Candidate `53f5f212625761f141d9de5270de41797e38602d` subsequently bound the
exact 49-handler worker and opened one complete current-source v2 execution.
Its immutable receipt retained 44 passes and five worker-specification
failures, so it did not close G4. The detailed execution record consumes the
modular-1009 and modular-1013 identities. The next candidate must bind the new
disjoint v3 contract rather than retry that opened evidence.

Candidate admission now sources the hash-bound worker in a non-executing
environment. Its declared cell IDs and handler names must both equal the
frozen 49-row denominator in exact order. A matching file hash alone is not
sufficient: a missing, duplicated, or reordered handler produces
`CONFIRMATION_WORKER_DENOMINATOR_INCOMPLETE` and keeps confirmation closed.

The 2026-08-25 live development tree is not a candidate. It contains ongoing
tracked and untracked work and no bound source tarball was supplied. The
preflight therefore returns a typed refusal and keeps current confirmation
unopened. This is the intended result, not a failed numerical cell.

The preflight itself performs no Git mutation, build, installation, fit,
score, replay, checkpoint, package check, or platform action. The admitted
`c65ad61` audit built and checked a tarball outside the preflight, but opened
no current confirmation result. The next transition requires a new reviewed
clean commit containing the complete worker and its matching
`mfrmr_0.2.4.9000.tar.gz` payload.

- `CandidateBindingPreflightImplemented=TRUE`
- `FirstFullyBoundPreconfirmationCandidate=c65ad6141ed8ab55f01e12ed076c3dd18baff67b`
- `FirstFullyBoundPreconfirmationCandidateCheckStatus=OK`
- `FirstFullyBoundPreconfirmationCandidateOpenedConfirmation=FALSE`
- `ConfirmationWorkerExactDenominatorRequired=TRUE`
- `ConfirmationWorkerDeclaredCells=49`
- `FirstCompleteCurrentExecutionCandidate=53f5f212625761f141d9de5270de41797e38602d`
- `FirstCompleteCurrentExecutionPassedCells=44`
- `FirstCompleteCurrentExecutionFailedCells=5`
- `FirstCompleteCurrentExecutionClosedG4=FALSE`
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
