# mfrmr 0.2.4 public-language release-candidate transition contract.
#
# Source fixed-calibration-release-candidate-transition-0.2.4.R into the same
# environment before this file. This file replaces only the immutable
# contract values; the review implementation and fail-closed path classifier
# remain shared with the historical v1 contract.
#
# The contract never edits, stages, commits, tags, builds, checks, submits, or
# publishes the package.

if (!exists("mfrmr_rc04_review", mode = "function", inherits = FALSE)) {
  stop("Source the historical transition implementation first.", call. = FALSE)
}

mfrmr_rc04_contract <- function() {
  list(
    ContractId =
      "mfrmr_release_candidate_transition_0_2_4_v3_public_language",
    TargetVersion = "0.2.4",
    DevelopmentVersion = "0.2.4.9000",
    PublicPredecessor = "0.2.3.1",
    G6ValidatedCommit =
      "0dd03dd9830371dd13159db68f00d14ada0cb0ba",
    G6HostedRunId = "32923607662",
    G6DecisionRecord =
      "fixed-calibration-g6-public-language-final-decision-record-0.2.4.md",
    CandidatePackagePaths = c("DESCRIPTION", "NEWS.md"),
    CandidateRepositoryPaths = c(
      "CITATION.cff", "cran-comments.md", "ROADMAP.md"
    ),
    CandidateInternalPatterns = c(
      "^inst/validation/",
      "^tests/testthat/test-fixed-calibration-g4-evidence[.]R$",
      "^tests/testthat/test-release-readiness-protocol[.]R$"
    ),
    CandidateDescriptionMutableFields = c(
      "Version", "Date", "Config/mfrmr/release-status"
    ),
    CandidateCffMutableFields = c("version", "date-released"),
    CandidateNewsMutableSurface = "first_heading_only",
    ProductionChangePolicy =
      "invalidate_candidate_return_to_development_and_rerun_evidence",
    PriorCandidateReusable = FALSE,
    PriorTransitionContractReusable = FALSE,
    SubmissionAuthorized = FALSE
  )
}
