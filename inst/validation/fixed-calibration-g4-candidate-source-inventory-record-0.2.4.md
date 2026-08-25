# Fixed-calibration G4 candidate-source inventory record

Status: `research_history_committed_release_history_unstaged`, 2026-08-25.

## Decision

Every live tracked and untracked path is classified before any staging or
commit. The inventory has four substantive classes:

1. 0.2.4 production code and package metadata;
2. 0.2.4 public/user-facing surfaces;
3. 0.2.4 build, regression, and repository-only evidence; and
4. deferred multivariate G-theory or Rater-assignment research.

Unknown paths fail closed. Research paths receive the separate
`separate_research_history_before_candidate_freeze` lane and have no public
scope effect. They are protected by existing `.Rbuildignore` rules for all
`inst/validation` material and all `test-gtheory-*` and
`test-rater-anchor-*` files. They therefore need not be deleted or hidden, but
they must not be confused with the 0.2.4 package payload or release claim.

The release lanes contain the scoring/replay/checkpoint hardening, fixed-
calibration schema and evidence, package metadata, regression tests, and
user-facing documentation that must be reviewed together. Repository-only G4
and G5 evidence remains excluded from the source package.

The public-language audit covers `NEWS.md`, all help pages, and all vignettes.
It finds no internal gate identifiers, claim-ledger mechanics, candidate-
binding terminology, hosted-run identifiers, amended-G4 labels, or Draft.85
research identifiers. `ROADMAP.md` is deliberately not treated as Help or
release notes; it retains governance and scope decisions.

The classification first authorized a commit plan rather than a pooled commit.
The 103 research paths were then staged with exact pathspecs, audited for zero
release-path contamination, and committed separately as `9e59878`. No research
file was deleted, hidden, or placed in the package payload. The 42 release
paths remained unstaged while their release-critical regression surface was
rerun. The unique focused denominator comprised 142 tests and 1,715
expectations with zero failures, errors, warnings, or skips: the scoring,
replay, checkpoint, fixed-calibration, and GPCM boundary group contributed 102
tests; the three CRAN-skipped GPCM helpers were explicitly rerun under
`NOT_CRAN=true`; and the repository release-readiness protocol contributed 40
tests and 794 expectations. No source tarball was built, installed, or used
for confirmation at this stage.

- `AllLiveChangesClassified=TRUE`
- `UnknownPathCount=0`
- `ResearchPackagePayloadExpected=FALSE`
- `PublicInternalLanguageClean=TRUE`
- `CommitPlanReady=TRUE`
- `ResearchHistoryCommit=9e59878`
- `ResearchHistoryPathCount=103`
- `ResearchHistoryReleasePathContamination=0`
- `ReleaseHistoryPathCount=42`
- `ReleaseFocusedTests=142`
- `ReleaseFocusedExpectations=1715`
- `ReleaseFocusedFailures=0`
- `ReleaseFocusedErrors=0`
- `ReleaseFocusedWarnings=0`
- `ReleaseFocusedSkips=0`
- `ReleaseHistoryCommitComplete=FALSE`
- `WorkingTreeClean=FALSE`
- `CandidateBindingComplete=FALSE`
- `CurrentExecutionOpened=FALSE`
- `G4ExitComplete=FALSE`
- `PublicAPIAuthorized=FALSE`
- `NextGate=release-regression-and-release-history-commit`
