# mfrmr 0.2.3 GPCM owner external-reproducibility preflight P1t
#
# P1t classifies the admitted P1s routes before any external program is run.
# It separates exact full-model reproduction from lower-dimensional reductions
# and near-neighbour sensitivity models.  It authorizes no external execution.

mfrmr_goer_p1t_specification <- "0.2.3-draft.1"
mfrmr_goer_p1t_contract <-
  "mfrmr_gpcm_owner_external_reproducibility_preflight_p1t_v1"
mfrmr_goer_p1t_admitted_manifest_sha256 <-
  "c7e51e7e166286dc690593921e661827f049252ec5859ea8928b129ab1e34f4f"
mfrmr_goer_p1t_source_audit_sha256 <-
  "b5fea18b3a38dfc7459815e0a5b9c1665406fad65f1e7f6a42e2dc5a4b1ced66"
mfrmr_goer_p1t_sirt_source_audit_sha256 <-
  "ec774da52390ee8bfa948347971e59bbe52a9362e2f73218fa7a43fdbb186adc"

mfrmr_goer_p1t_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_goer_p1t_hash <- function(object) {
  mfrmr_goer_p1t_assert(
    requireNamespace("digest", quietly = TRUE),
    "P1t requires package `digest`."
  )
  digest::digest(object, algo = "sha256", serialize = TRUE)
}

mfrmr_goer_p1t_validate_manifest <- function(manifest) {
  required <- c(
    "RouteId", "DataScenarioId", "SourceSlopeOwner", "SlopeOwner",
    "StepOwner", "SlopeComposition", "LatentDimensionCount", "Estimator",
    "AbilityScaleContract", "GpcmMmlIdentification", "RatingMin",
    "RatingMax", "DeclaredCategorySupport", "NRaters", "NCriteria",
    "Assignment", "RuntimeIdentity", "ExecutionRunnerSHA256",
    "ContractSHA256", "ManifestSHA256", "ExternalComparisonAuthorized",
    "BroadSimulationAuthorized", "ConfirmationAuthorized"
  )
  mfrmr_goer_p1t_assert(
    is.data.frame(manifest) && nrow(manifest) == 8L &&
      all(required %in% names(manifest)),
    "P1t requires the complete admitted eight-route P1s manifest."
  )
  expected_routes <- as.vector(outer(
    c("P1R-SRCC", "P1R-SRCR"),
    c("FITC-JML", "FITC-MML", "FITR-JML", "FITR-MML"),
    paste, sep = "-"
  ))
  mfrmr_goer_p1t_assert(
    !anyDuplicated(manifest$RouteId) &&
      identical(sort(manifest$RouteId), sort(expected_routes)) &&
      identical(sort(unique(manifest$SourceSlopeOwner)),
                c("Criterion", "Rater")) &&
      identical(sort(unique(manifest$SlopeOwner)), c("Criterion", "Rater")) &&
      identical(sort(unique(manifest$Estimator)), c("JML", "MML")),
    "P1t route, owner, or estimator identity drifted."
  )
  mml <- manifest$Estimator == "MML"
  jml <- manifest$Estimator == "JML"
  mfrmr_goer_p1t_assert(
    all(manifest$SlopeOwner == manifest$StepOwner) &&
      all(manifest$SlopeComposition == "single_owner_relative_gm1") &&
      all(as.integer(manifest$LatentDimensionCount) == 1L) &&
      all(manifest$GpcmMmlIdentification[mml] == "free_population") &&
      all(manifest$AbilityScaleContract[mml] ==
            "estimated_normal_population_intercept_only_free_scale") &&
      all(manifest$GpcmMmlIdentification[jml] == "not_applicable_jml") &&
      all(manifest$AbilityScaleContract[jml] == "fixed_person_coordinates"),
    "P1t owner or estimator-scale identity drifted."
  )
  mfrmr_goer_p1t_assert(
    all(manifest$RatingMin == 1L) && all(manifest$RatingMax == 4L) &&
      all(manifest$DeclaredCategorySupport == "1:4") &&
      all(manifest$NRaters == 6L) && all(manifest$NCriteria == 6L) &&
      all(manifest$Assignment == "complete_crossing"),
    "P1t category-support or facet-design identity drifted."
  )
  mfrmr_goer_p1t_assert(
    all(!as.logical(manifest$ExternalComparisonAuthorized)) &&
      all(!as.logical(manifest$BroadSimulationAuthorized)) &&
      all(!as.logical(manifest$ConfirmationAuthorized)),
    "P1t cannot widen P1s external, simulation, or confirmation authority."
  )
  declared_hash <- unique(as.character(manifest$ManifestSHA256))
  canonical <- manifest
  canonical$ManifestSHA256 <- NULL
  mfrmr_goer_p1t_assert(
    length(declared_hash) == 1L &&
      identical(declared_hash, mfrmr_goer_p1t_hash(canonical)) &&
      identical(declared_hash,
                mfrmr_goer_p1t_admitted_manifest_sha256),
    "P1t requires the admitted P1s manifest content identity."
  )
  invisible(TRUE)
}

mfrmr_goer_p1t_program_registry <- function() {
  data.frame(
    Program = c("ConQuest", "TAM", "immer", "sirt"),
    Version = c("5.47.5", "4.3-25", "1.5-13", "4.2-133"),
    OfficialSource = c(
      "https://conquestmanual.acer.org/s2-00.html",
      "https://cran.r-project.org/web/packages/TAM/TAM.pdf",
      "https://search.r-project.org/CRAN/refmans/immer/html/immer_jml.html",
      "https://search.r-project.org/CRAN/refmans/sirt/html/rm.facets.html"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_goer_p1t_classification_registry <- function() {
  data.frame(
    Program = rep(c("ConQuest", "TAM", "immer", "sirt"), each = 2L),
    Estimator = rep(c("JML", "MML"), 4L),
    EstimatorSupport = c(
      "unsupported_free_scores", "supported",
      "supported_pcm_reduction", "supported_nonfaceted_gpcm_only",
      "supported_pcm_reduction", "unsupported",
      "unsupported", "supported_near_neighbour"
    ),
    FullModelIdentity = c(
      "not_applicable", "unproved_multifacet_score_owner_map",
      "mismatch_free_slope_gpcm", "mismatch_faceted_slope_unavailable",
      "mismatch_unit_slope_pcm", "not_applicable",
      "not_applicable", "mismatch_product_trait_slope_kernel"
    ),
    CoordinateMapStatus = c(
      "not_applicable", "item_only_map_not_transportable_to_p1s",
      "not_applicable", "item_only_map_required",
      "not_applicable", "not_applicable",
      "not_applicable", "finite_box_and_kernel_difference"
    ),
    Disposition = c(
      "unsupported", "no_exact_route_established",
      "reduction_only", "no_exact_route_established",
      "reduction_only", "unsupported",
      "unsupported", "non_equivalent"
    ),
    ReasonCode = c(
      "jml_cannot_estimate_item_scores",
      "standard_multifacet_scoresfree_does_not_establish_single_owner_scaling",
      "tam_jml_is_unit_slope_pcm_not_p1s_gpcm",
      "tam_mml_mfr_does_not_estimate_slopes",
      "immer_jml_is_unit_slope_pcm_not_p1s_gpcm",
      "immer_has_no_matching_mml_route",
      "rm_facets_is_mml_not_jml",
      "sirt_scales_trait_term_by_item_rater_product_and_uses_finite_slope_box"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_goer_p1t_projection_registry <- function() {
  data.frame(
    ProjectionId = c(
      "CQ-ITEMONLY-MML", "TAM-ITEMONLY-MML", "IMMER-PCM-JML",
      "SIRT-EQUAL-DISCRIM-MML", "SIRT-ITEMONLY-GPCM-MML"
    ),
    Program = c("ConQuest", "TAM", "immer", "sirt", "sirt"),
    Estimator = c("MML", "MML", "JML", "MML", "MML"),
    Projection = c(
      "drop_rater_and_criterion_facets_item_only_intercept_population",
      "drop_rater_and_criterion_facets_item_only_intercept_population",
      "fix_all_slopes_to_one_pcm_design",
      "fix_all_discriminations_equal_many_facet_pcm",
      "drop_nonitem_facets_item_only_gpcm"
    ),
    StructuralStatus = c(
      "exact_coordinate_map_established",
      "candidate_requires_coordinate_audit",
      "reduction_only",
      "reduction_only",
      "near_neighbour_finite_box_difference"
    ),
    ExistingNumericEvidence = c(
      "one_covariate_microcase_review_only_not_p1s",
      "none_for_p1s",
      "separate_pcm_pilots_not_p1s",
      "none_for_p1s",
      "none_for_p1s"
    ),
    FullP1sReproduction = FALSE,
    ExternalExecutionAuthorized = FALSE,
    ClaimAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_goer_p1t_validate_result <- function(result) {
  ledger <- result$RouteLedger
  projections <- result$ProjectionRegistry
  mfrmr_goer_p1t_assert(
    is.data.frame(ledger) && nrow(ledger) == 32L &&
      nrow(unique(ledger[c("RouteId", "Program")])) == 32L &&
      setequal(unique(ledger$Program), c("ConQuest", "TAM", "immer", "sirt")) &&
      all(as.integer(table(ledger$RouteId)) == 4L),
    "P1t route-by-program denominator is incomplete."
  )
  expected_dispositions <- c(
    no_exact_route_established = 8L, non_equivalent = 4L,
    reduction_only = 8L, unsupported = 12L
  )
  observed_dispositions <- table(ledger$Disposition)
  mfrmr_goer_p1t_assert(
    identical(
      unname(as.integer(observed_dispositions[names(expected_dispositions)])),
      unname(expected_dispositions)
    ) &&
      all(!ledger$FullP1sExactReproduction) &&
      all(!ledger$ExternalExecutionAuthorized),
    "P1t full-model disposition or authority drifted."
  )
  mfrmr_goer_p1t_assert(
    is.data.frame(projections) && nrow(projections) == 5L &&
      !anyDuplicated(projections$ProjectionId) &&
      all(!projections$FullP1sReproduction) &&
      all(!projections$ExternalExecutionAuthorized) &&
      all(!projections$ClaimAuthorized),
    "P1t projection boundary drifted."
  )
  mfrmr_goer_p1t_assert(
    isTRUE(result$NoFitPreflightComplete) &&
      identical(result$FullP1sExactRoutes, 0L) &&
      identical(result$ExternalFitsRun, 0L) &&
      !isTRUE(result$P1sReproducedExternally) &&
      !isTRUE(result$ExternalExecutionAuthorized),
    "P1t result cannot claim external reproduction or execution."
  )
  invisible(TRUE)
}

mfrmr_run_gpcm_owner_external_reproducibility_preflight_p1t <-
    function(manifest) {
  mfrmr_goer_p1t_validate_manifest(manifest)
  programs <- mfrmr_goer_p1t_program_registry()
  classification <- mfrmr_goer_p1t_classification_registry()
  ledger <- merge(
    manifest[, c(
      "RouteId", "DataScenarioId", "SourceSlopeOwner", "SlopeOwner",
      "StepOwner", "SlopeComposition", "LatentDimensionCount", "Estimator",
      "AbilityScaleContract", "GpcmMmlIdentification", "RatingMin",
      "RatingMax", "DeclaredCategorySupport", "RuntimeIdentity",
      "ManifestSHA256"
    ), drop = FALSE],
    classification,
    by = "Estimator", all = TRUE, sort = FALSE
  )
  ledger <- merge(ledger, programs, by = "Program", all.x = TRUE, sort = FALSE)
  route_order <- match(ledger$RouteId, manifest$RouteId)
  program_order <- match(ledger$Program, programs$Program)
  ledger <- ledger[order(route_order, program_order), , drop = FALSE]
  rownames(ledger) <- NULL
  ledger$FullP1sExactReproduction <- FALSE
  ledger$ExternalExecutionAuthorized <- FALSE
  ledger$NumericComparisonAuthorized <- FALSE

  out <- list(
    Specification = mfrmr_goer_p1t_specification,
    Contract = mfrmr_goer_p1t_contract,
    P1sManifestSHA256 = unique(manifest$ManifestSHA256),
    SourceAuditSHA256 = mfrmr_goer_p1t_source_audit_sha256,
    SirtSourceAuditSHA256 = mfrmr_goer_p1t_sirt_source_audit_sha256,
    RouteLedger = ledger,
    ProjectionRegistry = mfrmr_goer_p1t_projection_registry(),
    NoFitPreflightComplete = TRUE,
    PlannedFullRouteProgramPairs = nrow(ledger),
    FullP1sExactRoutes = 0L,
    ExternalFitsRun = 0L,
    P1sReproducedExternally = FALSE,
    ExternalExecutionAuthorized = FALSE,
    NumericComparisonAuthorized = FALSE,
    BroadSimulationAuthorized = FALSE,
    ConfirmationAuthorized = FALSE
  )
  class(out) <- c(
    "mfrmr_gpcm_owner_external_reproducibility_preflight_p1t", "list"
  )
  mfrmr_goer_p1t_validate_result(out)
  out
}
