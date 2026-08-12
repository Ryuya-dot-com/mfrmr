# mfrmr 0.2.3 current-default paired-owner GPCM contract P1r
#
# P1r is a no-fit admission contract for one bounded eight-route smoke.  Two
# non-unit source-owner datasets are each shared by Criterion/Rater fit-owner
# routes under JML and current-default free-population MML.  It authorizes no
# recovery, owner-superiority, external-equivalence, or release claim.

mfrmr_gocd_p1r_specification <- "0.2.3-draft.1"
mfrmr_gocd_p1r_contract <-
  "mfrmr_gpcm_owner_current_default_contract_p1r_v1"
mfrmr_gocd_p1r_dependency_contract <-
  "mfrmr_gpcm_owner_identity_propagation_p1q_v1"
mfrmr_gocd_p1r_dependency_sha256 <-
  "8216884cb08948ae3be3b4134dacc07bcb88a635a6c96dce7e25f26d793dea73"

mfrmr_gocd_p1r_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gocd_p1r_hash <- function(object) {
  mfrmr_gocd_p1r_assert(
    requireNamespace("digest", quietly = TRUE),
    "P1r requires package `digest`."
  )
  digest::digest(object, algo = "sha256", serialize = TRUE)
}

mfrmr_gocd_p1r_identity_fields <- function() {
  c(
    "SourceSlopeOwner", "SlopeOwner", "StepOwner", "SlopeComposition",
    "LatentDimensionCount", "Estimator", "AbilityScaleContract",
    "GpcmMmlIdentification", "RatingMin", "RatingMax",
    "DeclaredCategorySupport", "RuntimeIdentity"
  )
}

mfrmr_gocd_p1r_manifest <- function(runtime_identity,
                                     execution_runner_sha256,
                                     contract_sha256) {
  hashes <- c(runtime_identity, execution_runner_sha256, contract_sha256)
  mfrmr_gocd_p1r_assert(
    length(hashes) == 3L && all(grepl("^[0-9a-f]{64}$", hashes)),
    "P1r execution identities must be lower-case SHA-256 values."
  )
  design <- expand.grid(
    SourceSlopeOwner = c("Criterion", "Rater"),
    SlopeOwner = c("Criterion", "Rater"),
    Estimator = c("JML", "MML"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  design <- design[order(
    match(design$SourceSlopeOwner, c("Criterion", "Rater")),
    match(design$SlopeOwner, c("Criterion", "Rater")),
    match(design$Estimator, c("JML", "MML"))
  ), , drop = FALSE]
  source_code <- ifelse(design$SourceSlopeOwner == "Criterion", "C", "R")
  fit_code <- ifelse(design$SlopeOwner == "Criterion", "C", "R")
  design$RouteId <- paste(
    "P1R", paste0("SRC", source_code), paste0("FIT", fit_code),
    design$Estimator, sep = "-"
  )
  design$DataScenarioId <- paste0("P1R-SOURCE-", source_code)
  design$DataSeed <- ifelse(
    design$SourceSlopeOwner == "Criterion", 3461001L, 3461002L
  )
  design$StepOwner <- design$SlopeOwner
  design$SlopeComposition <- "single_owner_relative_gm1"
  design$LatentDimensionCount <- 1L
  design$AbilityScaleContract <- ifelse(
    design$Estimator == "MML",
    "estimated_normal_population_intercept_only_free_scale",
    "fixed_person_coordinates"
  )
  design$GpcmMmlIdentification <- ifelse(
    design$Estimator == "MML", "free_population", "not_applicable_jml"
  )
  design$FitArgumentGpcmMmlIdentification <- "free_population"
  design$RatingMin <- 1L
  design$RatingMax <- 4L
  design$DeclaredCategorySupport <- "1:4"
  design$KeepOriginal <- TRUE
  design$NPersons <- 120L
  design$NRaters <- 6L
  design$NCriteria <- 6L
  design$NCategories <- 4L
  design$Assignment <- "complete_crossing"
  design$SourceSlopeRegime <- "mild_nonunit"
  design$ComparisonRole <- ifelse(
    design$SourceSlopeOwner == design$SlopeOwner,
    "source_owner_aligned", "alternate_owner_misspecified"
  )
  design$PairingUnit <- "DataScenarioId"
  design$DataHashRequired <- TRUE
  design$QuadPoints <- ifelse(design$Estimator == "MML", 31L, NA_integer_)
  design$Maxit <- 400L
  design$RuntimeIdentity <- runtime_identity
  design$ExecutionRunnerSHA256 <- execution_runner_sha256
  design$ContractSHA256 <- contract_sha256
  design$EvidenceUse <- "software_identity_and_paired_attribution_smoke_only"
  design$ExecutionStatus <- "contract_only_not_run"
  design$RecoveryThresholdFrozen <- FALSE
  design$OwnerSuperiorityClaimAuthorized <- FALSE
  design$ExternalComparisonAuthorized <- FALSE
  design$BroadSimulationAuthorized <- FALSE
  design$SelectionAuthorized <- FALSE
  design$ConfirmationAuthorized <- FALSE
  rownames(design) <- NULL
  canonical <- design
  design$ManifestSHA256 <- mfrmr_gocd_p1r_hash(canonical)
  mfrmr_gocd_p1r_validate_manifest(design)
  design
}

mfrmr_gocd_p1r_validate_manifest <- function(manifest) {
  identity <- mfrmr_gocd_p1r_identity_fields()
  required <- c(
    "RouteId", "DataScenarioId", "DataSeed", identity,
    "FitArgumentGpcmMmlIdentification", "KeepOriginal", "NCategories",
    "NPersons", "NRaters", "NCriteria", "Assignment",
    "SourceSlopeRegime", "EvidenceUse", "ExecutionStatus",
    "ComparisonRole", "PairingUnit", "DataHashRequired", "QuadPoints",
    "Maxit", "ExecutionRunnerSHA256", "ContractSHA256", "ManifestSHA256",
    "RecoveryThresholdFrozen", "OwnerSuperiorityClaimAuthorized",
    "ExternalComparisonAuthorized", "BroadSimulationAuthorized",
    "SelectionAuthorized", "ConfirmationAuthorized"
  )
  mfrmr_gocd_p1r_assert(
    is.data.frame(manifest) && nrow(manifest) == 8L &&
      all(required %in% names(manifest)),
    "P1r requires the complete eight-route manifest schema."
  )
  mfrmr_gocd_p1r_assert(
    !anyDuplicated(manifest$RouteId) &&
      identical(sort(unique(manifest$DataScenarioId)),
                c("P1R-SOURCE-C", "P1R-SOURCE-R")) &&
      all(manifest$DataScenarioId == ifelse(
        manifest$SourceSlopeOwner == "Criterion",
        "P1R-SOURCE-C", "P1R-SOURCE-R"
      )) && all(manifest$DataSeed == ifelse(
        manifest$SourceSlopeOwner == "Criterion", 3461001L, 3461002L
      )),
    "P1r route or source-dataset identity drifted."
  )
  groups <- split(manifest, manifest$DataScenarioId)
  paired <- vapply(groups, function(x) {
    nrow(x) == 4L && length(unique(x$DataSeed)) == 1L &&
      identical(sort(unique(x$SlopeOwner)), c("Criterion", "Rater")) &&
      identical(sort(unique(x$Estimator)), c("JML", "MML")) &&
      nrow(unique(x[, c("SlopeOwner", "Estimator")])) == 4L
  }, logical(1L))
  mfrmr_gocd_p1r_assert(
    length(groups) == 2L && all(paired),
    "P1r routes are not a complete paired common-data design."
  )
  mml <- manifest$Estimator == "MML"
  jml <- manifest$Estimator == "JML"
  mfrmr_gocd_p1r_assert(
    all(manifest$SlopeOwner == manifest$StepOwner) &&
      all(manifest$SlopeComposition == "single_owner_relative_gm1") &&
      all(as.integer(manifest$LatentDimensionCount) == 1L) &&
      all(manifest$FitArgumentGpcmMmlIdentification == "free_population") &&
      all(manifest$GpcmMmlIdentification[mml] == "free_population") &&
      all(manifest$AbilityScaleContract[mml] ==
            "estimated_normal_population_intercept_only_free_scale") &&
      all(manifest$GpcmMmlIdentification[jml] == "not_applicable_jml") &&
      all(manifest$AbilityScaleContract[jml] == "fixed_person_coordinates"),
    "P1r owner, slope, dimension, or ability-scale identity drifted."
  )
  mfrmr_gocd_p1r_assert(
    all(manifest$RatingMin == 1L) && all(manifest$RatingMax == 4L) &&
      all(manifest$DeclaredCategorySupport == "1:4") &&
      all(manifest$NCategories == 4L) && all(manifest$KeepOriginal) &&
      all(manifest$NPersons == 120L) && all(manifest$NRaters == 6L) &&
      all(manifest$NCriteria == 6L) &&
      all(manifest$Assignment == "complete_crossing") &&
      all(manifest$SourceSlopeRegime == "mild_nonunit") &&
      all(manifest$DataHashRequired) &&
      all(manifest$PairingUnit == "DataScenarioId") &&
      all(manifest$QuadPoints[mml] == 31L) &&
      all(is.na(manifest$QuadPoints[jml])) && all(manifest$Maxit == 400L),
    "P1r support, pairing, quadrature, or optimizer ceiling drifted."
  )
  source_aligned <- manifest$SourceSlopeOwner == manifest$SlopeOwner
  mfrmr_gocd_p1r_assert(
    all(manifest$ComparisonRole[source_aligned] == "source_owner_aligned") &&
      all(manifest$ComparisonRole[!source_aligned] ==
            "alternate_owner_misspecified"),
    "P1r paired-owner comparison roles drifted."
  )
  hash_fields <- c(
    "RuntimeIdentity", "ExecutionRunnerSHA256", "ContractSHA256",
    "ManifestSHA256"
  )
  mfrmr_gocd_p1r_assert(
    all(vapply(manifest[hash_fields], function(x) {
      length(unique(x)) == 1L && all(grepl("^[0-9a-f]{64}$", x))
    }, logical(1L))),
    "P1r execution or manifest hashes are incomplete."
  )
  forbidden <- c(
    "RecoveryThresholdFrozen", "OwnerSuperiorityClaimAuthorized",
    "ExternalComparisonAuthorized", "BroadSimulationAuthorized",
    "SelectionAuthorized", "ConfirmationAuthorized"
  )
  mfrmr_gocd_p1r_assert(
    all(vapply(manifest[forbidden], function(x) all(!x), logical(1L))),
    "P1r contract cannot authorize inference, expansion, or confirmation."
  )
  mfrmr_gocd_p1r_assert(
    all(manifest$EvidenceUse ==
          "software_identity_and_paired_attribution_smoke_only") &&
      all(manifest$ExecutionStatus == "contract_only_not_run"),
    "P1r evidence-use or execution-state boundary drifted."
  )
  declared_hash <- unique(as.character(manifest$ManifestSHA256))
  canonical <- manifest
  canonical$ManifestSHA256 <- NULL
  mfrmr_gocd_p1r_assert(
    length(declared_hash) == 1L &&
      identical(declared_hash, mfrmr_gocd_p1r_hash(canonical)),
    "P1r manifest content hash mismatch."
  )
  invisible(TRUE)
}

mfrmr_gocd_p1r_surface_contract <- function() {
  fields <- paste(mfrmr_gocd_p1r_identity_fields(), collapse = ";")
  surface <- c(
    "declared_manifest", "generated_data_ledger", "run_result",
    "checkpoint_row_manifest", "checkpoint_result", "summary_by_stratum",
    "rate_summary", "numeric_summary", "execution_identity_by_stratum",
    "execution_policy_by_stratum", "checkpoint_ledger", "replay_call",
    "external_normalizer_if_instantiated"
  )
  data.frame(
    Surface = surface,
    RequiredIdentityFields = fields,
    Binding = ifelse(
      grepl("summary|execution_", surface),
      "four_stratum_registry_expansion", "direct_columns_or_arguments"
    ),
    Admission = ifelse(
      surface == "external_normalizer_if_instantiated",
      "conditional_required_before_external_claim", "required_for_smoke"
    ),
    MissingFieldPolicy = "fail_closed_no_evidence_admission",
    stringsAsFactors = FALSE
  )
}

mfrmr_run_gpcm_owner_current_default_contract_p1r <- function(
    runtime_identity, execution_runner_sha256, contract_sha256) {
  manifest <- mfrmr_gocd_p1r_manifest(
    runtime_identity, execution_runner_sha256, contract_sha256
  )
  surfaces <- mfrmr_gocd_p1r_surface_contract()
  structure(
    list(
      specification = mfrmr_gocd_p1r_specification,
      contract = mfrmr_gocd_p1r_contract,
      dependency_contract = mfrmr_gocd_p1r_dependency_contract,
      dependency_sha256 = mfrmr_gocd_p1r_dependency_sha256,
      manifest = manifest,
      surface_contract = surfaces,
      PairedDatasets = 2L,
      PlannedRoutes = 8L,
      ContractComplete = TRUE,
      BoundedSmokeAdmissibleAfterRuntimeBinding = TRUE,
      SmokeExecuted = FALSE,
      CurrentDefaultOwnerEvidenceComplete = FALSE,
      RecoveryClaimAuthorized = FALSE,
      OwnerSuperiorityClaimAuthorized = FALSE,
      ExternalComparisonAuthorized = FALSE,
      AdditionalReplicationAuthorized = FALSE,
      BroadSimulationAuthorized = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_owner_current_default_contract_p1r"
  )
}
