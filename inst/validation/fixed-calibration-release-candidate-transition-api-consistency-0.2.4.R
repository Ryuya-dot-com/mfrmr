# mfrmr 0.2.4 API-consistency release-candidate transition contract.
#
# Source fixed-calibration-release-candidate-transition-0.2.4.R into the same
# environment first. This file replaces only immutable contract values and
# retains the existing fail-closed review implementation.

if (!exists("mfrmr_rc04_review", mode = "function", inherits = FALSE)) {
  stop("Source the historical transition implementation first.", call. = FALSE)
}

mfrmr_rc04_contract <- function() {
  list(
    ContractId =
      "mfrmr_release_candidate_transition_0_2_4_v4_api_consistency",
    TargetVersion = "0.2.4",
    DevelopmentVersion = "0.2.4.9000",
    PublicPredecessor = "0.2.3.1",
    G6ValidatedCommit =
      "036565f583d441c599d6650391dc0523c36d0210",
    G6HostedRunId = "32990152654",
    G6DecisionRecord =
      "fixed-calibration-human-api-review-candidate-0.2.4.md",
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
