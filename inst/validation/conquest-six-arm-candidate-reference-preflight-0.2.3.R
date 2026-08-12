# Repository-only numerical-reference preflight for corrected ConQuest
# candidate 002. It validates source-bound mfrmr q31/q61 references without
# launching ConQuest and without treating numerical-reference readiness as
# scientific inference readiness.

mfrmr_cq_crp_specification <-
  "0.2.3-wave-c-conquest-six-arm-candidate-reference-v1"
mfrmr_cq_crp_contract <-
  "mfrmr_conquest_six_arm_candidate_reference_v1"
mfrmr_cq_crp_candidate_id <- "mfrmr-0.2.3-conquest-six-arm-002"
mfrmr_cq_crp_reference_bundle_sha256 <-
  "0d23be47efce2965c8f4fa76c93d6aa569bc5aa313bce6550286ac2d9f7942a8"
mfrmr_cq_crp_source_bundle_sha256 <-
  "c0dfb7cf32a27e652bfed6ae644a7fe2aa606970f04a8d4a43d0ba1a71b11e2c"

mfrmr_cq_crp_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_crp_require_binding <- function() {
  target <- environment(mfrmr_cq_crp_require_binding)
  required <- c(
    "mfrmr_cq_cb_review", "mfrmr_cq_cb_arm_registry",
    "mfrmr_cq_cb_canonical_text", "mfrmr_cq_cb_source_status"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity_ok <- exists(
    "mfrmr_cq_cb_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_cb_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_six_arm_candidate_binding_v2"
  ) && identical(
    get("mfrmr_cq_cb_candidate_id", envir = target, inherits = TRUE),
    mfrmr_cq_crp_candidate_id
  )
  mfrmr_cq_crp_assert(
    all(available) && identity_ok,
    "Source the corrected candidate-002 binding before this preflight."
  )
  invisible(TRUE)
}

mfrmr_cq_crp_reference_registry <- function() {
  binary <- data.frame(
    ArmId = rep(c("binary_q031", "binary_q061"), each = 4L),
    Family = "Binary",
    Nodes = rep(c(31L, 61L), each = 4L),
    ArtifactKind = rep(c(
      "item_map", "parameter_item", "summary", "parameter_population"
    ), 2L),
    RelativePath = c(
      file.path("binary", "q031a", c(
        "cq_q031a_item_map.csv",
        "cq_q031a_mfrmr_item_estimates.csv",
        "cq_q031a_mfrmr_ladder_reference.csv",
        "cq_q031a_mfrmr_population.csv"
      )),
      file.path("binary", "q061", c(
        "cq_q061_item_map.csv",
        "cq_q061_mfrmr_item_estimates.csv",
        "cq_q061_mfrmr_ladder_reference.csv",
        "cq_q061_mfrmr_population.csv"
      ))
    ),
    SHA256 = c(
      "ad79be379c650424649b260534f7ad537c27adf91518f7695dd71ff6fd1e2112",
      "a525c51a62277c0bc88a1b222cddab16bcbea27e6f924e31f7488169177e421e",
      "bebdf8de532f01f2175d025e400293ba7a886e405c81777c27fdcf37278f65f1",
      "6e5c61ea0e67983d656afd7b454ee0a65c3d4a0621b4a8e00101ea9e0ace1da9",
      "ad79be379c650424649b260534f7ad537c27adf91518f7695dd71ff6fd1e2112",
      "f95f734b85d3a1cab1d20e010a14fa3ebc469ed4bcbbb3ee9074a05cb2b6b6eb",
      "c8ed3789aff430f035cf6fd4d2beebdb61447d73e943821c3c752448ceafc5f3",
      "786061dfeecb3b9f66ce68e30babc5f1683af20ba45770615b0e1a5eee2dddfc"
    ),
    stringsAsFactors = FALSE
  )
  additive <- data.frame(
    ArmId = rep(c("rsm_q031", "rsm_q061", "pcm_q031", "pcm_q061"),
                each = 2L),
    Family = rep(c("RSM", "RSM", "PCM", "PCM"), each = 2L),
    Nodes = rep(c(31L, 61L, 31L, 61L), each = 2L),
    ArtifactKind = rep(c("summary", "parameter"), 4L),
    RelativePath = file.path(
      "additive", "mfrmr_reference",
      c(
        "rsm_q031_mfrmr_reference_summary.csv",
        "rsm_q031_mfrmr_reference_parameters.csv",
        "rsm_q061_mfrmr_reference_summary.csv",
        "rsm_q061_mfrmr_reference_parameters.csv",
        "pcm_q031_mfrmr_reference_summary.csv",
        "pcm_q031_mfrmr_reference_parameters.csv",
        "pcm_q061_mfrmr_reference_summary.csv",
        "pcm_q061_mfrmr_reference_parameters.csv"
      )
    ),
    SHA256 = c(
      "4b2325d872a28b76df426e55009e62b88c44a5c6f5e87a931ad722e96032b878",
      "6a253b9d843cbe3b1270f9b8d662958435a82a37c8a71ad9336649630e6ae4be",
      "5683850a9e92d731ec7d8a0f72888b89cbfc6a74f272d79b5c69278f30d42af0",
      "d849a12a747ab453a0b7cbcf64d46adb03f15c56bb1a869bf08010c7e7149c4a",
      "028b674831774513fc45a773611cd3cc375a4eedf98908aeee4eb172d9799a2d",
      "4e0d92cb09296f1d4713f7aa24c093e838e4d9e4787e236142f98c28a9a631f6",
      "be887ac3d2cd77267d9daccf6e7defae375927966b12355faa397fd7b5314f47",
      "191027d6f13c014650bf5e5e9b7d77ce326a2f4b1d04aeeaec66764634f0e681"
    ),
    stringsAsFactors = FALSE
  )
  out <- rbind(binary, additive)
  rownames(out) <- NULL
  mfrmr_cq_crp_assert(
    nrow(out) == 16L && !anyDuplicated(paste(out$ArmId, out$ArtifactKind)),
    "The candidate reference registry must contain 16 unique arm artifacts."
  )
  out
}

mfrmr_cq_crp_source_registry <- function() {
  data.frame(
    Artifact = c(
      "inst/validation/conquest-binary-ladder-pilot-0.2.3.R",
      "inst/validation/conquest-additive-mfrm-design-0.2.3.R",
      paste0(
        "inst/validation/",
        "conquest-additive-mfrm-reference-preflight-0.2.3.R"
      )
    ),
    SHA256 = c(
      "1a135e9fa877775284f1657e55a41246876fe3f7fde337e545b9a3339489e9a0",
      "4698b9f7eb83896c1f97e8b6eb98326c00b028ca0517c2d954c5f1fce8633a21",
      "a91d41916eb151efac2270ae3d4da05e8f918597396b5436b2d354edec4a8f2a"
    ),
    SourceCommit = "8ee7958f7af08141df156b333fe1fc732e2b2bc6",
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_crp_bundle_hashes <- function() {
  mfrmr_cq_crp_require_binding()
  mfrmr_cq_crp_assert(
    requireNamespace("digest", quietly = TRUE),
    "The candidate reference preflight requires `digest`."
  )
  reference <- mfrmr_cq_crp_reference_registry()
  source <- mfrmr_cq_crp_source_registry()
  data.frame(
    Bundle = c("reference_artifact", "reference_source"),
    SHA256 = c(
      digest::digest(
        mfrmr_cq_cb_canonical_text(reference, c("ArmId", "ArtifactKind")),
        algo = "sha256", serialize = FALSE
      ),
      digest::digest(
        mfrmr_cq_cb_canonical_text(source, "Artifact"),
        algo = "sha256", serialize = FALSE
      )
    ),
    ExpectedSHA256 = c(
      mfrmr_cq_crp_reference_bundle_sha256,
      mfrmr_cq_crp_source_bundle_sha256
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_crp_read <- function(root, registry, arm_id, kind) {
  index <- which(
    registry$ArmId == arm_id & registry$ArtifactKind == kind
  )
  mfrmr_cq_crp_assert(
    length(index) == 1L,
    paste0("Reference artifact identity is ambiguous for `", arm_id, "`." )
  )
  utils::read.csv(
    file.path(root, registry$RelativePath[index]),
    stringsAsFactors = FALSE, check.names = FALSE
  )
}

mfrmr_cq_crp_binary_arm <- function(root, registry, arm_id, nodes) {
  summary <- mfrmr_cq_crp_read(root, registry, arm_id, "summary")
  population <- mfrmr_cq_crp_read(
    root, registry, arm_id, "parameter_population"
  )
  item <- mfrmr_cq_crp_read(root, registry, arm_id, "parameter_item")
  item_map <- mfrmr_cq_crp_read(root, registry, arm_id, "item_map")
  run_id <- if (nodes == 31L) "q031a" else "q061"
  population_index <- match(
    c("(Intercept)", "X", "sigma2"), population$Parameter
  )
  free <- c(
    population$Estimate[population_index], item$CenteredEstimate[1:5]
  )
  names(free) <- c(
    "population_intercept", "population_slope", "population_variance",
    paste0("item_difficulty_", 1:5)
  )
  summary_free <- unlist(summary[1L, c(
    "Intercept", "Slope", "Variance", paste0("Item", 1:5)
  )], use.names = FALSE)
  mfrmr_cq_crp_assert(
    nrow(summary) == 1L && summary$RunId == run_id &&
      summary$Nodes == nodes && summary$MfrmrNpar == 8L &&
      summary$Persons == 60L && summary$MfrmrMaxit == 2000L &&
      summary$MfrmrReltol == 1e-12 &&
      is.finite(summary$MfrmrTerminalGradientSupNorm) &&
      summary$MfrmrTerminalGradientSupNorm <= 1e-5 &&
      is.finite(summary$MfrmrDeviance) && is.finite(summary$MfrmrLogLik) &&
      abs(summary$MfrmrDeviance + 2 * summary$MfrmrLogLik) <= 1e-10 &&
      !summary$MfrmrInferenceReady && !summary$ConfirmationAuthorized &&
      nrow(population) == 3L && !anyNA(population_index) &&
      nrow(item) == 6L && nrow(item_map) == 6L &&
      identical(as.character(item$ResponseVar),
                as.character(item_map$ResponseVar)) &&
      all(is.finite(c(free, item$CenteredEstimate))) &&
      abs(sum(item$CenteredEstimate)) <= 1e-12 &&
      max(abs(free - summary_free)) <= 1e-12 &&
      abs(item$CenteredEstimate[6] - summary$ConstrainedItem6) <= 1e-12,
    paste0("The Binary numerical reference failed for `", arm_id, "`.")
  )
  list(
    summary = data.frame(
      ArmId = arm_id, Family = "Binary", Nodes = nodes,
      Npar = 8L, Deviance = summary$MfrmrDeviance,
      TerminalGradientSupNorm = summary$MfrmrTerminalGradientSupNorm,
      NumericalReferenceReady = TRUE, OracleChecked = FALSE,
      AllPatternLocalRankRetained = FALSE, InferenceReady = FALSE,
      ReferenceBasis =
        "converged_finite_internal_coordinate_consistency",
      stringsAsFactors = FALSE
    ),
    free = free
  )
}

mfrmr_cq_crp_additive_arm <- function(
    root, registry, arm_id, family, nodes, expected_npar) {
  summary <- mfrmr_cq_crp_read(root, registry, arm_id, "summary")
  parameter <- mfrmr_cq_crp_read(root, registry, arm_id, "parameter")
  free_index <- which(!is.na(parameter$FreeOrder))
  free_index <- free_index[order(parameter$FreeOrder[free_index])]
  free <- parameter$Estimate[free_index]
  names(free) <- paste(
    parameter$MfrmrRole[free_index], parameter$Level[free_index], sep = "::"
  )
  mfrmr_cq_crp_assert(
    nrow(summary) == 1L && summary$RunId == arm_id &&
      summary$Model == family && summary$Nodes == nodes &&
      summary$Npar == expected_npar &&
      summary$ConvergenceStatus == "converged" &&
      is.finite(summary$TerminalGradientSupNorm) &&
      summary$TerminalGradientSupNorm <= 1e-4 &&
      summary$AllPatternStatus ==
        "evaluated_all_patterns_local_diagnostic_only" &&
      summary$EvaluatedPatternDesigns == 512L &&
      summary$LocalRank == expected_npar && summary$LocalNullity == 0L &&
      !summary$RankToleranceSensitive &&
      summary$OracleLogLikAbsDifference <= 1e-9 &&
      summary$OracleProbabilityMaxAbsDifference <= 1e-13 &&
      summary$QuadratureWeightSumDifference <= 1e-13 &&
      !summary$InferenceReady &&
      summary$ReadinessReasonCodes == "design_rank_not_evaluated" &&
      !summary$CandidateBound && !summary$ExternalExecutionAuthorized &&
      !summary$ComparisonReady && length(free) == expected_npar &&
      all(is.finite(parameter$Estimate)) &&
      all(!parameter$ComparisonEligible),
    paste0("The additive numerical reference failed for `", arm_id, "`.")
  )
  list(
    summary = data.frame(
      ArmId = arm_id, Family = family, Nodes = nodes,
      Npar = expected_npar, Deviance = summary$Deviance,
      TerminalGradientSupNorm = summary$TerminalGradientSupNorm,
      NumericalReferenceReady = TRUE, OracleChecked = TRUE,
      AllPatternLocalRankRetained = TRUE, InferenceReady = FALSE,
      ReferenceBasis =
        "independent_probability_and_marginal_likelihood_oracle",
      stringsAsFactors = FALSE
    ),
    free = free
  )
}

mfrmr_cq_crp_review <- function(candidate_root, repo_root = ".") {
  mfrmr_cq_crp_require_binding()
  mfrmr_cq_crp_assert(
    requireNamespace("digest", quietly = TRUE),
    "The candidate reference preflight requires `digest`."
  )
  root <- normalizePath(
    as.character(candidate_root)[1L], winslash = "/", mustWork = TRUE
  )
  registry <- mfrmr_cq_crp_reference_registry()
  registry$ObservedSHA256 <- vapply(
    file.path(root, registry$RelativePath),
    mfrmr_cq_cb_file_sha256, character(1L)
  )
  registry$IdentityOK <- registry$ObservedSHA256 == registry$SHA256
  bundle <- mfrmr_cq_crp_bundle_hashes()
  binding <- mfrmr_cq_cb_review(root)
  source <- mfrmr_cq_cb_source_status(repo_root)
  arm_spec <- data.frame(
    ArmId = c(
      "binary_q031", "binary_q061", "rsm_q031", "rsm_q061",
      "pcm_q031", "pcm_q061"
    ),
    Family = c("Binary", "Binary", "RSM", "RSM", "PCM", "PCM"),
    Nodes = c(31L, 61L, 31L, 61L, 31L, 61L),
    Npar = c(8L, 8L, 7L, 7L, 9L, 9L),
    stringsAsFactors = FALSE
  )
  reference <- lapply(seq_len(nrow(arm_spec)), function(index) {
    arm <- arm_spec[index, , drop = FALSE]
    if (arm$Family == "Binary") {
      mfrmr_cq_crp_binary_arm(root, registry, arm$ArmId, arm$Nodes)
    } else {
      mfrmr_cq_crp_additive_arm(
        root, registry, arm$ArmId, arm$Family, arm$Nodes, arm$Npar
      )
    }
  })
  arm_summary <- do.call(rbind, lapply(reference, `[[`, "summary"))
  integration <- do.call(rbind, lapply(c("Binary", "RSM", "PCM"), function(family) {
    index <- which(arm_spec$Family == family)
    q31 <- reference[[index[arm_spec$Nodes[index] == 31L]]]$free
    q61 <- reference[[index[arm_spec$Nodes[index] == 61L]]]$free
    deviance <- arm_summary$Deviance[arm_summary$Family == family]
    data.frame(
      Family = family,
      CoordinateMaxAbsDifference = max(abs(q61 - q31)),
      CoordinateTolerance = 2e-6,
      CoordinatePass = max(abs(q61 - q31)) <= 2e-6,
      DevianceAbsDifference = abs(diff(deviance)),
      DevianceTolerance = 2e-6,
      DeviancePass = abs(diff(deviance)) <= 2e-6,
      stringsAsFactors = FALSE
    )
  }))
  ready <- all(registry$IdentityOK %in% TRUE) &&
    all(bundle$SHA256 == bundle$ExpectedSHA256) &&
    isTRUE(binding$candidate_core_structurally_authorized) &&
    !isTRUE(binding$candidate_execution_authorized) &&
    isTRUE(source$IdentityOK) &&
    all(arm_summary$NumericalReferenceReady) &&
    all(integration$CoordinatePass) && all(integration$DeviancePass)
  out <- list(
    specification = mfrmr_cq_crp_specification,
    contract_version = mfrmr_cq_crp_contract,
    status = if (ready) {
      "six_arm_numerical_reference_ready_execution_handoff_pending"
    } else {
      "six_arm_numerical_reference_invalid"
    },
    candidate_id = mfrmr_cq_crp_candidate_id,
    artifact_registry = registry,
    bundle_hashes = bundle,
    candidate_binding = binding,
    source_status = source,
    arm_summary = arm_summary,
    integration = integration,
    numerical_reference_ready = ready,
    inference_ready = FALSE,
    numerical_reference_promotes_inference = FALSE,
    candidate_execution_authorized = FALSE,
    execution_hold_reason = "candidate_execution_handoff_not_frozen",
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE,
    sparse_extension_authorized = FALSE,
    large_simulation_authorized = FALSE
  )
  class(out) <- c("mfrmr_conquest_candidate_reference_review", class(out))
  out
}
