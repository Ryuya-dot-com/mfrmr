# Historical repository-only D-SIM-0 v3 Phase 1 admission gate.
#
# This gate is upstream of the v3 owner-input packet. It distinguishes missing
# owner evidence from a completed decision that neither ABS-PHI nor REL-G has
# an operational use. The v4 package-capability contract supersedes it as an
# active package-development gate; these functions preserve the unexecuted v3
# proposal and may still support a project-specific applied protocol. It never
# authorizes simulation, seed access, or fitting.

mfrmr_gtp1_identity <- function() {
  list(
    GateVersion = "mfrmr-gtheory-multivariate-phase1-admission-v1",
    ContractId = "MFRMR-GTHEORY-MV-DSIM0-MULTIVERSE-V3",
    ContractHash =
      "f5e2cff2e470f6ad0ab592a2c49597a873b7286f5b9f7f8e4669069635788905",
    OwnerInputPacketCandidateHash =
      "53c02d057c9d18309e1d14ad7f3725e05f8ecaf1413f6b377c15a205a919b557",
    DecisionFamilyId = c("ABS-PHI", "REL-G")
  )
}

mfrmr_gtp1_required_columns <- function() {
  c(
    "ContractId", "ContractHash", "OwnerInputPacketCandidateHash",
    "DecisionFamilyId", "RepositoryCandidateUse",
    "RepositoryClaimCeiling", "Enabled", "NamedOperationalUse",
    "DecisionOwnerId", "DecisionOwnerRole", "AffectedWorkflowIdentity",
    "TargetPopulationIdentity", "ConsequenceIdentity",
    "ExternalEvidenceAnchor", "DisableRationaleIfNotEnabled",
    "OwnerConfirmed", "Ready", "OwnerEnablementMayBeInferred",
    "SimulationExecutionAllowed"
  )
}

mfrmr_gtp1_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The Phase 1 gate requires the `digest` package.", call. = FALSE)
  }
  digest::digest(
    value, algo = "sha256", serialize = TRUE, serializeVersion = 3L
  )
}

mfrmr_gtp1_validate_response <- function(response) {
  identity <- mfrmr_gtp1_identity()
  expected_names <- mfrmr_gtp1_required_columns()
  character_or_blank_na <- function(value) {
    is.character(value) || (is.logical(value) && all(is.na(value)))
  }
  structural <- is.data.frame(response) &&
    identical(names(response), expected_names) &&
    identical(nrow(response), 2L) &&
    is.character(response$ContractId) &&
    is.character(response$ContractHash) &&
    is.character(response$OwnerInputPacketCandidateHash) &&
    is.character(response$DecisionFamilyId) &&
    is.character(response$RepositoryCandidateUse) &&
    is.character(response$RepositoryClaimCeiling) &&
    is.logical(response$Enabled) &&
    character_or_blank_na(response$NamedOperationalUse) &&
    character_or_blank_na(response$DecisionOwnerId) &&
    character_or_blank_na(response$DecisionOwnerRole) &&
    character_or_blank_na(response$AffectedWorkflowIdentity) &&
    character_or_blank_na(response$TargetPopulationIdentity) &&
    character_or_blank_na(response$ConsequenceIdentity) &&
    character_or_blank_na(response$ExternalEvidenceAnchor) &&
    character_or_blank_na(response$DisableRationaleIfNotEnabled) &&
    is.logical(response$OwnerConfirmed) &&
    is.logical(response$Ready) &&
    is.logical(response$OwnerEnablementMayBeInferred) &&
    is.logical(response$SimulationExecutionAllowed)
  if (!structural) {
    stop("The Phase 1 owner response is malformed.", call. = FALSE)
  }
  bound <- all(response$ContractId == identity$ContractId) &&
    all(response$ContractHash == identity$ContractHash) &&
    all(response$OwnerInputPacketCandidateHash ==
          identity$OwnerInputPacketCandidateHash) &&
    identical(response$DecisionFamilyId, identity$DecisionFamilyId) &&
    all(!is.na(response$RepositoryCandidateUse) &
          nzchar(response$RepositoryCandidateUse)) &&
    all(response$RepositoryClaimCeiling ==
          "repository_candidate_interpretation_only")
  if (!bound) {
    stop("The Phase 1 owner response is not bound to the current v3 candidate.",
         call. = FALSE)
  }
  if (any(response$Ready) ||
      any(response$OwnerEnablementMayBeInferred) ||
      any(response$SimulationExecutionAllowed)) {
    stop("The Phase 1 response cannot self-authorize readiness or execution.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtp1_family_readiness <- function(response) {
  mfrmr_gtp1_validate_response(response)
  present <- function(value) {
    value <- as.character(value)
    !is.na(value) & nzchar(value)
  }
  common_missing <-
    as.integer(is.na(response$Enabled)) +
    as.integer(!present(response$DecisionOwnerId)) +
    as.integer(!present(response$DecisionOwnerRole)) +
    as.integer(!present(response$ExternalEvidenceAnchor)) +
    as.integer(!response$OwnerConfirmed %in% TRUE)
  enabled_missing <- ifelse(
    response$Enabled %in% TRUE,
    as.integer(!present(response$NamedOperationalUse)) +
      as.integer(!present(response$AffectedWorkflowIdentity)) +
      as.integer(!present(response$TargetPopulationIdentity)) +
      as.integer(!present(response$ConsequenceIdentity)),
    0L
  )
  disabled_missing <- ifelse(
    !is.na(response$Enabled) & !response$Enabled,
    as.integer(!present(response$DisableRationaleIfNotEnabled)),
    0L
  )
  missing <- as.integer(common_missing + enabled_missing + disabled_missing)
  data.frame(
    DecisionFamilyId = response$DecisionFamilyId,
    EnabledState = ifelse(
      is.na(response$Enabled), "pending",
      ifelse(response$Enabled, "enabled", "disabled")
    ),
    MissingCount = missing,
    RequiredEvidenceComplete = missing == 0L,
    OwnerConfirmed = response$OwnerConfirmed,
    OwnerEnablementMayBeInferred = FALSE,
    SimulationExecutionAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtp1_adjudicate <- function(response) {
  identity <- mfrmr_gtp1_identity()
  family_rows <- mfrmr_gtp1_family_readiness(response)
  complete <- all(family_rows$RequiredEvidenceComplete)
  enabled_count <- sum(family_rows$EnabledState == "enabled")
  disabled_count <- sum(family_rows$EnabledState == "disabled")
  pending_count <- sum(!family_rows$RequiredEvidenceComplete)
  gate_status <- if (!complete) {
    "pending_external_owner_evidence"
  } else if (enabled_count == 0L) {
    "completed_stop_no_operational_use"
  } else {
    "completed_advance_to_phase2_evidence_collection"
  }
  summary <- data.frame(
    GateVersion = identity$GateVersion,
    ContractId = identity$ContractId,
    ContractHash = identity$ContractHash,
    ResponseHash = mfrmr_gtp1_hash(response),
    GateStatus = gate_status,
    EnabledFamilyCount = enabled_count,
    DisabledFamilyCount = disabled_count,
    PendingFamilyCount = pending_count,
    ResponseEvidenceComplete = complete,
    StopNoOperationalUse = identical(
      gate_status, "completed_stop_no_operational_use"
    ),
    AdvanceToPhase2EvidenceCollection = identical(
      gate_status, "completed_advance_to_phase2_evidence_collection"
    ),
    OwnerPacketFamilyRegistryConstructionAllowed = identical(
      gate_status, "completed_advance_to_phase2_evidence_collection"
    ),
    Dsim0Satisfied = FALSE,
    SimulationExecutionAllowed = FALSE,
    PlannedSeedAccessAllowed = FALSE,
    NextAction = switch(
      gate_status,
      pending_external_owner_evidence =
        "complete both owner-response rows without outcome evidence",
      completed_stop_no_operational_use =
        "record the externally anchored terminal stop; do not construct v3 owner inputs",
      completed_advance_to_phase2_evidence_collection =
        "transfer enabled-family evidence into a newly hashed typed owner packet"
    ),
    stringsAsFactors = FALSE
  )
  result <- list(Summary = summary, FamilyReadiness = family_rows)
  class(result) <- c("mfrmr_gtp1_adjudication", "list")
  result
}
