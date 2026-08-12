# mfrmr 0.2.3 GPCM release-scope disposition P1p audit
#
# P1p is a no-fit portfolio decision. It binds the completed P1o finite-grid
# registry to the existing public GPCM capability matrix and release checklist.
# It prevents an unadvertised continuous coefficient-ratio theorem from
# becoming an accidental 0.2.3 release dependency and selects the already
# registered owner-specific evidence partition as the next GPCM release-spine
# bottleneck. It promotes no public capability.

mfrmr_grsd_p1p_specification <- "0.2.3-draft.1"
mfrmr_grsd_p1p_contract <-
  "mfrmr_gpcm_release_scope_disposition_p1p_v1"
mfrmr_grsd_p1p_dependency_contract <-
  "mfrmr_gpcm_reflected_finite_grid_registry_p1o_v1"
mfrmr_grsd_p1p_dependency_sha256 <-
  "d65d94c6e8ac2df8a94091dfcf849d556e6a9736e3798bb70f6ccbaa42342e57"
mfrmr_grsd_p1p_next_release_spine_item <- "gpcm_owner_evidence_partition"
mfrmr_grsd_p1p_conditional_fit_item <- "gpcm_fit_operating_characteristics"
mfrmr_grsd_p1p_conditional_dff_item <- "gpcm_dff_estimand_specificity"
mfrmr_grsd_p1p_scope_guard_item <- "gpcm_generalized_family_scope_guards"

mfrmr_grsd_p1p_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_grsd_p1p_validation_dir <- function() {
  source_file <- tryCatch(sys.frame(1L)$ofile, error = function(...) NULL)
  if (is.null(source_file) || !nzchar(source_file)) source_file <- ""
  roots <- c(
    getwd(), dirname(source_file),
    file.path(getwd(), ".."), file.path(getwd(), "..", ".."),
    file.path(getwd(), "..", "..", "..")
  )
  candidates <- unique(normalizePath(c(
    roots, file.path(roots, "inst", "validation")
  ), winslash = "/", mustWork = FALSE))
  hit <- candidates[file.exists(file.path(
    candidates, "claim-disposition-profile-0.2.3.csv"
  ))]
  mfrmr_grsd_p1p_assert(
    length(hit) >= 1L,
    "P1p could not locate the release-scope source tables."
  )
  hit[1L]
}

mfrmr_grsd_p1p_require_sources <- function() {
  target <- environment(mfrmr_grsd_p1p_require_sources)
  required <- "mfrmr_grfg_p1o_contract"
  available <- vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )
  mfrmr_grsd_p1p_assert(
    all(available) && identical(
      get("mfrmr_grfg_p1o_contract", envir = target, inherits = TRUE),
      mfrmr_grsd_p1p_dependency_contract
    ),
    "Source P0 through P1o and the public GPCM registry before P1p."
  )
  invisible(TRUE)
}

mfrmr_grsd_p1p_capability_registry <- function() {
  target <- environment(mfrmr_grsd_p1p_capability_registry)
  fn <- if (exists(
      ".gpcm_capability_registry", envir = target, inherits = TRUE
  )) {
    get(".gpcm_capability_registry", envir = target, inherits = TRUE)
  } else if (isNamespaceLoaded("mfrmr") ||
      requireNamespace("mfrmr", quietly = TRUE)) {
    getFromNamespace(".gpcm_capability_registry", "mfrmr")
  } else {
    NULL
  }
  mfrmr_grsd_p1p_assert(
    is.function(fn),
    "P1p requires the public GPCM capability registry."
  )
  fn()
}

mfrmr_grsd_p1p_validate_result <- function(p1o) {
  mfrmr_grsd_p1p_assert(
    is.list(p1o) && identical(
      p1o$contract, mfrmr_grsd_p1p_dependency_contract
    ) && isTRUE(p1o$FullFourFixtureFiniteGridRegistryCompleted) &&
      !isTRUE(p1o$RefitFallbackRequired) &&
      !isTRUE(p1o$ContinuousGlobalProfileCertified),
    "P1p requires a complete finite-grid P1o result with global fail closure."
  )
  invisible(TRUE)
}

mfrmr_grsd_p1p_release_tables <- function(validation_dir = NULL) {
  if (is.null(validation_dir)) validation_dir <- mfrmr_grsd_p1p_validation_dir()
  checklist <- utils::read.csv(
    file.path(validation_dir, "release-evidence-checklist-0.2.3.csv"),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  disposition <- utils::read.csv(
    file.path(validation_dir, "claim-disposition-profile-0.2.3.csv"),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  mfrmr_grsd_p1p_assert(
    nrow(checklist) == 106L && nrow(disposition) == 106L &&
      identical(checklist$Item, disposition$Item),
    "P1p checklist/disposition identity drifted."
  )
  list(checklist = checklist, disposition = disposition)
}

mfrmr_grsd_p1p_row <- function(tables, item) {
  index <- which(tables$checklist$Item == item)
  mfrmr_grsd_p1p_assert(
    length(index) == 1L,
    paste0("P1p expected one checklist row for ", item, ".")
  )
  data.frame(
    ChecklistRow = index,
    Item = item,
    EvidenceStatus = tables$checklist$EvidenceStatus[index],
    CriterionState = tables$checklist$CriterionState[index],
    PortfolioClass = tables$disposition$PortfolioClass[index],
    ClaimGroup = tables$disposition$ClaimGroup[index],
    UnmetAction = tables$disposition$UnmetAction[index],
    FallbackCode = tables$disposition$FallbackCode[index],
    stringsAsFactors = FALSE
  )
}

mfrmr_grsd_p1p_release_rows <- function(tables) {
  items <- c(
    mfrmr_grsd_p1p_next_release_spine_item,
    mfrmr_grsd_p1p_conditional_fit_item,
    mfrmr_grsd_p1p_conditional_dff_item,
    mfrmr_grsd_p1p_scope_guard_item
  )
  rows <- do.call(rbind, lapply(items, mfrmr_grsd_p1p_row, tables = tables))
  rownames(rows) <- NULL
  mfrmr_grsd_p1p_assert(
    identical(rows$PortfolioClass, c(
      "release_spine", "claim_conditional", "claim_conditional",
      "release_spine"
    )) &&
      identical(rows$FallbackCode[2:3], c(
        "retain_gpcm_fit_as_exploratory_no_decision",
        "disable_gpcm_dff_inferential_promotion"
      )),
    "P1p GPCM claim-disposition classes drifted."
  )
  rows
}

mfrmr_grsd_p1p_public_capabilities <- function() {
  registry <- mfrmr_grsd_p1p_capability_registry()
  required <- c(
    core_fit_summary = "supported_with_caveat",
    exploratory_diagnostics = "supported_with_caveat",
    dff_screening = "supported_with_caveat",
    mcmc_backends = "deferred",
    facets_score_review = "blocked"
  )
  index <- match(names(required), registry$CapabilityID)
  mfrmr_grsd_p1p_assert(
    !anyNA(index) && identical(
      unname(registry$Status[index]), unname(required)
    ),
    "P1p public GPCM capability boundary drifted."
  )
  advertised <- paste(
    registry$CapabilityID, registry$Area, registry$Helpers,
    registry$Status, registry$Boundary, registry$RecommendedRoute
  )
  ratio_claim <- grepl(
    "continuous[ -](coefficient[ -])?ratio|global[ -]ratio[ -]profile|two[ -]target[ -]face[ -]closure",
    advertised, ignore.case = TRUE
  )
  mfrmr_grsd_p1p_assert(
    !any(ratio_claim),
    "P1p found a public continuous coefficient-ratio capability claim."
  )
  registry[index, c(
    "CapabilityID", "Area", "Status", "Boundary", "RecommendedRoute"
  ), drop = FALSE]
}

mfrmr_grsd_p1p_claim_registry <- function(p1o, release_rows) {
  owner <- release_rows[
    release_rows$Item == mfrmr_grsd_p1p_next_release_spine_item,
    , drop = FALSE
  ]
  fit <- release_rows[
    release_rows$Item == mfrmr_grsd_p1p_conditional_fit_item,
    , drop = FALSE
  ]
  dff <- release_rows[
    release_rows$Item == mfrmr_grsd_p1p_conditional_dff_item,
    , drop = FALSE
  ]
  guard <- release_rows[
    release_rows$Item == mfrmr_grsd_p1p_scope_guard_item,
    , drop = FALSE
  ]
  data.frame(
    ClaimId = c(
      "gpcm_reflected_finite_grid",
      "gpcm_continuous_ratio_profile",
      "gpcm_aligned_owner_public_interpretation",
      "gpcm_fit_decision_promotion",
      "gpcm_dff_inferential_promotion",
      "gpcm_generalized_family_nonclaim"
    ),
    EvidenceState = c(
      if (isTRUE(p1o$FullFourFixtureFiniteGridRegistryCompleted)) {
        "internal_validated"
      } else "blocked",
      "not_established",
      owner$EvidenceStatus,
      fit$EvidenceStatus,
      dff$EvidenceStatus,
      guard$EvidenceStatus
    ),
    OperationalState = c(
      "repository_evidence_only",
      "not_public_api",
      "public_caveat_required",
      "exploratory_no_decision",
      "screening_no_inferential_promotion",
      "fail_closed_nonclaim"
    ),
    ReleaseDisposition = c(
      "retain_bounded_finite_grid_claim",
      "defer_not_required_for_retained_0_2_3_scope",
      "release_no_go_until_owner_partition_passes",
      fit$FallbackCode,
      dff$FallbackCode,
      "release_no_go_if_scope_guard_missing"
    ),
    CriterionId = c(
      "P1O-FOUR-FIXTURE-FINITE-GRID",
      "P1P-CONTINUOUS-RATIO-NONCLAIM",
      owner$Item,
      fit$Item,
      dff$Item,
      guard$Item
    ),
    EvidenceIdentity = c(
      mfrmr_grsd_p1p_dependency_sha256,
      "none_not_required",
      paste0("checklist_row_", owner$ChecklistRow),
      paste0("checklist_row_", fit$ChecklistRow),
      paste0("checklist_row_", dff$ChecklistRow),
      paste0("checklist_row_", guard$ChecklistRow)
    ),
    PublicPromotionAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_grsd_p1p_overall <- function(p1o, release_rows, capabilities, claims) {
  finite <- claims$ClaimId == "gpcm_reflected_finite_grid"
  continuous <- claims$ClaimId == "gpcm_continuous_ratio_profile"
  owner <- release_rows$Item == mfrmr_grsd_p1p_next_release_spine_item
  fit <- release_rows$Item == mfrmr_grsd_p1p_conditional_fit_item
  dff <- release_rows$Item == mfrmr_grsd_p1p_conditional_dff_item
  finite_retained <- isTRUE(p1o$FullFourFixtureFiniteGridRegistryCompleted) &&
    claims$EvidenceState[finite] == "internal_validated"
  continuous_not_required <-
    claims$ReleaseDisposition[continuous] ==
      "defer_not_required_for_retained_0_2_3_scope"
  owner_selected <- sum(owner) == 1L &&
    release_rows$PortfolioClass[owner] == "release_spine" &&
    release_rows$EvidenceStatus[owner] != "ok"
  fallbacks_preserved <-
    release_rows$FallbackCode[fit] ==
      "retain_gpcm_fit_as_exploratory_no_decision" &&
    release_rows$FallbackCode[dff] ==
      "disable_gpcm_dff_inferential_promotion"
  data.frame(
    FiniteGridClaimRetained = finite_retained,
    ContinuousRatioTheoremAdvertisedPublicly = FALSE,
    ContinuousRatioTheoremRequiredForRetainedPublicScope = FALSE,
    ContinuousRatioWorkDeferred = continuous_not_required,
    NextReleaseSpineItem = mfrmr_grsd_p1p_next_release_spine_item,
    NextReleaseSpineItemSelected = owner_selected,
    PublicCapabilityRowsAudited = nrow(capabilities),
    FitAndDFFFallbacksPreserved = fallbacks_preserved,
    ReleaseScopeDispositionComplete =
      finite_retained && continuous_not_required && owner_selected &&
        fallbacks_preserved,
    GPCMCorePromotionAuthorized = FALSE,
    ContinuousGlobalProfileCertified = FALSE,
    HessianInferenceAuthorized = FALSE,
    DFFFitRankAuthorized = FALSE,
    BroadSimulationAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_run_gpcm_release_scope_disposition_p1p <- function(
    p1o,
    validation_dir = NULL) {
  mfrmr_grsd_p1p_require_sources()
  mfrmr_grsd_p1p_validate_result(p1o)
  tables <- mfrmr_grsd_p1p_release_tables(validation_dir)
  release_rows <- mfrmr_grsd_p1p_release_rows(tables)
  capabilities <- mfrmr_grsd_p1p_public_capabilities()
  claims <- mfrmr_grsd_p1p_claim_registry(p1o, release_rows)
  overall <- mfrmr_grsd_p1p_overall(
    p1o, release_rows, capabilities, claims
  )
  structure(
    list(
      contract = mfrmr_grsd_p1p_contract,
      specification = mfrmr_grsd_p1p_specification,
      dependency_contract = mfrmr_grsd_p1p_dependency_contract,
      dependency_sha256 = mfrmr_grsd_p1p_dependency_sha256,
      release_rows = release_rows,
      public_capabilities = capabilities,
      claim_registry = claims,
      overall_decision = overall,
      p1o = p1o,
      FiniteGridClaimRetained = overall$FiniteGridClaimRetained,
      ContinuousRatioWorkDeferred = overall$ContinuousRatioWorkDeferred,
      NextReleaseSpineItem = overall$NextReleaseSpineItem,
      ReleaseScopeDispositionComplete = overall$ReleaseScopeDispositionComplete,
      GPCMCorePromotionAuthorized = FALSE,
      ContinuousGlobalProfileCertified = FALSE,
      HessianInferenceAuthorized = FALSE,
      DFFFitRankAuthorized = FALSE,
      BroadSimulationAuthorized = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_release_scope_disposition_p1p"
  )
}

print.mfrmr_gpcm_release_scope_disposition_p1p <- function(x, ...) {
  cat("GPCM release-scope disposition P1p audit\n")
  print(x$overall_decision, row.names = FALSE)
  invisible(x)
}
