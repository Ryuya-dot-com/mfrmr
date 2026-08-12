# mfrmr 0.2.3 GPCM reflected finite-grid registry P1o audit
#
# P1o materializes the exact P1n category-reflection map over every stored P1k
# and P1l point. It builds a four-fixture finite-grid cell registry without
# optimizing a reflected fixture. Finite-grid completion is kept distinct from
# a continuous coefficient-ratio profile or full two-target-face closure.

mfrmr_grfg_p1o_specification <- "0.2.3-draft.1"
mfrmr_grfg_p1o_contract <-
  "mfrmr_gpcm_reflected_finite_grid_registry_p1o_v1"
mfrmr_grfg_p1o_dependency_contract <-
  "mfrmr_gpcm_category_reflection_transport_p1n_v1"
mfrmr_grfg_p1o_dependency_sha256 <-
  "8dba2f8393837fcb54c2124ea7a01eb90ad4051d8919ebc8f65b35f380e5b357"
mfrmr_grfg_p1o_objective_tolerance <- 1e-9
mfrmr_grfg_p1o_gradient_tolerance <- 1e-9

mfrmr_grfg_p1o_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_grfg_p1o_require_sources <- function() {
  target <- environment(mfrmr_grfg_p1o_require_sources)
  required <- c(
    "mfrmr_gcrt_p1n_contract", "mfrmr_gcrt_p1n_reflect_x",
    "mfrmr_gcrt_p1n_reflection_matrix", "mfrmr_gcrt_p1n_low_scenario",
    "mfrmr_gorb_p1j_bundle", "mfrmr_gorb_p1j_contexts",
    "mfrmr_gss_hash_vector"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )
  mfrmr_grfg_p1o_assert(
    all(available) && identical(
      get("mfrmr_gcrt_p1n_contract", envir = target, inherits = TRUE),
      mfrmr_grfg_p1o_dependency_contract
    ),
    "Source P0 through P1n before P1o."
  )
  invisible(TRUE)
}

mfrmr_grfg_p1o_validate_result <- function(p1n) {
  mfrmr_grfg_p1o_assert(
    is.list(p1n) && identical(
      p1n$contract, mfrmr_grfg_p1o_dependency_contract
    ) && isTRUE(p1n$ReflectedRepresentativeFixturesEvaluated) &&
      !isTRUE(p1n$RefitFallbackRequired) && is.list(p1n$p1m),
    "P1o requires one complete P1n result with no fallback refit."
  )
  invisible(TRUE)
}

mfrmr_grfg_p1o_sources <- function(p1n) {
  p1m <- p1n$p1m
  p1k <- p1m$objective_p1l$p1k
  objective <- p1m$objective_p1l
  coordinate <- p1m$coordinate_p1l
  mfrmr_grfg_p1o_assert(
    nrow(p1k$pairwise) == 168L && length(p1k$profile_objects) == 336L &&
      nrow(objective$cells) == 33L &&
      length(objective$profile_objects) == 766L &&
      nrow(coordinate$cells) == 10L &&
      length(coordinate$profile_objects) == 260L &&
      length(intersect(objective$cells$CellId, coordinate$cells$CellId)) == 0L,
    "P1o source P1k/P1l registry dimensions drifted."
  )
  list(p1k = p1k, objective = objective, coordinate = coordinate)
}

mfrmr_grfg_p1o_point <- function(
    object,
    source_layer,
    contexts,
    transformation) {
  row <- object$row
  high_scenario <- as.character(row$ScenarioId)
  low_scenario <- mfrmr_gcrt_p1n_low_scenario(high_scenario)
  if (identical(source_layer, "P1k")) {
    value <- as.numeric(object$value)
    x <- value[-length(value)]
    rho <- value[length(value)]
    mfrmr_grfg_p1o_assert(
      abs(rho - row$Rho) <= 1e-12,
      "P1o P1k stored rho and coordinate differ."
    )
    eligible <- isTRUE(row$ProfileCandidateEligible)
  } else {
    x <- as.numeric(object$value)
    rho <- as.numeric(row$Rho)
    eligible <- isTRUE(row$ContinuationCandidateEligible)
  }
  reflected_x <- mfrmr_gcrt_p1n_reflect_x(x, contexts$high)
  high <- mfrmr_gorb_p1j_bundle(
    x, row$Mu, rho, contexts$high, row$FastIndex, row$SlowIndex,
    include_gradient = TRUE
  )
  low <- mfrmr_gorb_p1j_bundle(
    reflected_x, row$Mu, rho, contexts$low,
    row$FastIndex, row$SlowIndex, include_gradient = TRUE
  )
  objective_difference <- abs(high$objective - low$objective)
  gradient_difference <- max(abs(c(
    high$gradient - as.vector(t(transformation) %*% low$gradient),
    high$mu_gradient - low$mu_gradient,
    high$rho_gradient - low$rho_gradient
  )))
  identity <- eligible &&
    objective_difference <= mfrmr_grfg_p1o_objective_tolerance &&
    gradient_difference <= mfrmr_grfg_p1o_gradient_tolerance
  cell_id <- paste(high_scenario, row$OrderedPairId, row$Mu, sep = "::")
  data.frame(
    SourceLayer = source_layer,
    HighScenarioId = high_scenario,
    LowScenarioId = low_scenario,
    CellId = cell_id,
    OrderedPairId = row$OrderedPairId,
    FastIndex = row$FastIndex,
    SlowIndex = row$SlowIndex,
    TargetSetId = row$TargetSetId,
    RouteId = row$RouteId,
    Mu = row$Mu,
    Rho = rho,
    SourcePointEligible = eligible,
    ObjectiveAbsDifference = objective_difference,
    GradientTransportMaxAbsDifference = gradient_difference,
    SourceVectorSHA256 = mfrmr_gss_hash_vector(x),
    ReflectedVectorSHA256 = mfrmr_gss_hash_vector(reflected_x),
    ReflectedPointIdentityVerified = identity,
    RefitRequired = !identity,
    FiniteGridOnly = TRUE,
    ContinuousGlobalProfileCertified = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_grfg_p1o_point_registry <- function(sources, progress = FALSE) {
  p1i <- sources$p1k$p1j$p1i
  cache <- list()
  for (scenario in sources$p1k$scenarios) {
    high <- mfrmr_gorb_p1j_contexts(p1i, scenario)[["121"]]
    low <- mfrmr_gorb_p1j_contexts(
      p1i, mfrmr_gcrt_p1n_low_scenario(scenario)
    )[["121"]]
    cache[[scenario]] <- list(
      high = high,
      low = low,
      transformation = mfrmr_gcrt_p1n_reflection_matrix(high)
    )
  }
  layers <- list(
    P1k = sources$p1k$profile_objects,
    P1lObjective = sources$objective$profile_objects,
    P1lCoordinate = sources$coordinate$profile_objects
  )
  rows <- vector("list", sum(vapply(layers, length, integer(1L))))
  index <- 1L
  for (layer in names(layers)) {
    if (isTRUE(progress)) message(
      "P1o: ", layer, " / ", length(layers[[layer]]), " stored points"
    )
    for (object in layers[[layer]]) {
      scenario <- as.character(object$row$ScenarioId)
      rows[[index]] <- mfrmr_grfg_p1o_point(
        object, if (layer == "P1k") "P1k" else layer,
        cache[[scenario]][c("high", "low")],
        cache[[scenario]]$transformation
      )
      index <- index + 1L
    }
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_grfg_p1o_high_cells <- function(sources, points) {
  base <- sources$p1k$pairwise
  base$CellId <- paste(
    base$ScenarioId, base$OrderedPairId, base$Mu, sep = "::"
  )
  continuation <- rbind(
    transform(
      sources$objective$cells,
      ContinuationScope = "objective_discordant"
    ),
    transform(
      sources$coordinate$cells,
      ContinuationScope = "coordinate_only"
    )
  )
  classified <- merge(
    base,
    continuation[, c("CellId", "ContinuationScope", "MechanismClass")],
    by = "CellId", all.x = TRUE, sort = FALSE
  )
  classified$EvidenceLayer <- ifelse(
    is.na(classified$ContinuationScope), "P1k_agreeing", "P1l_continuation"
  )
  classified$MechanismClass[is.na(classified$MechanismClass)] <-
    "p1k_routes_agree_within_tolerance"
  point_split <- split(points, points$CellId)
  classified$SourcePointCount <- vapply(classified$CellId, function(cell_id) {
    nrow(point_split[[cell_id]])
  }, integer(1L))
  classified$AllSourcePointIdentitiesVerified <- vapply(
    classified$CellId, function(cell_id) {
      all(point_split[[cell_id]]$ReflectedPointIdentityVerified)
    }, logical(1L)
  )
  classified$HighFiniteGridCellClassified <-
    classified$BothRoutesEligible & (
      classified$RoutesAgreeWithinTolerance |
        classified$EvidenceLayer == "P1l_continuation"
    )
  classified$FiniteGridOnly <- TRUE
  classified$ContinuousGlobalProfileCertified <- FALSE
  classified$SelectionAuthorized <- FALSE
  classified$ConfirmationAuthorized <- FALSE
  classified
}

mfrmr_grfg_p1o_four_fixture_registry <- function(high) {
  high_rows <- data.frame(
    ScenarioId = high$ScenarioId,
    TransportedFromScenarioId = NA_character_,
    ReflectionStatus = "source_high",
    high,
    ReflectedFiniteGridCellTransported = FALSE,
    RefitRequired = FALSE,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  reflected <- high
  reflected$ScenarioId <- vapply(
    high$ScenarioId, mfrmr_gcrt_p1n_low_scenario, character(1L)
  )
  reflected$CellId <- paste(
    reflected$ScenarioId, reflected$OrderedPairId, reflected$Mu, sep = "::"
  )
  reflected_rows <- data.frame(
    ScenarioId = reflected$ScenarioId,
    TransportedFromScenarioId = high$ScenarioId,
    ReflectionStatus = "transported_low",
    reflected,
    ReflectedFiniteGridCellTransported =
      reflected$AllSourcePointIdentitiesVerified &
        reflected$HighFiniteGridCellClassified,
    RefitRequired = !(
      reflected$AllSourcePointIdentitiesVerified &
        reflected$HighFiniteGridCellClassified
    ),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  # Remove the duplicate ScenarioId introduced by data.frame(..., high).
  high_rows <- high_rows[, !duplicated(names(high_rows)), drop = FALSE]
  reflected_rows <- reflected_rows[
    , !duplicated(names(reflected_rows)), drop = FALSE
  ]
  out <- rbind(high_rows, reflected_rows)
  rownames(out) <- NULL
  out
}

mfrmr_grfg_p1o_overall <- function(points, high, registry) {
  all_points <- nrow(points) == 1362L &&
    all(points$ReflectedPointIdentityVerified)
  all_high <- nrow(high) == 168L && all(high$HighFiniteGridCellClassified)
  reflected <- registry$ReflectionStatus == "transported_low"
  all_reflected <- sum(reflected) == 168L &&
    all(registry$ReflectedFiniteGridCellTransported[reflected])
  complete <- all_points && all_high && all_reflected && nrow(registry) == 336L
  data.frame(
    SourceStoredPointCount = nrow(points),
    SourceHighCellCount = nrow(high),
    ReflectedLowCellCount = sum(reflected),
    FourFixtureFiniteGridCellCount = nrow(registry),
    P1kAgreeingHighCellCount = sum(high$EvidenceLayer == "P1k_agreeing"),
    P1lContinuationHighCellCount =
      sum(high$EvidenceLayer == "P1l_continuation"),
    AllStoredPointReflectionIdentitiesVerified = all_points,
    AllHighFiniteGridCellsClassified = all_high,
    AllReflectedFiniteGridCellsTransported = all_reflected,
    FullFourFixtureFiniteGridRegistryCompleted = complete,
    RefitFallbackRequired = !complete,
    ReflectedFiniteGridFixturesEvaluated = complete,
    ReflectedFixturesEvaluated = FALSE,
    FullFourFixtureRatioProfilesCompleted = FALSE,
    ContinuousMonotonicityCertified = FALSE,
    ContinuousGlobalProfileCertified = FALSE,
    CoefficientRatioProfilesCompleted = FALSE,
    AllSixTwoTargetFacesGloballyCertified = FALSE,
    ThreeTargetFacesEvaluated = FALSE,
    EmptyRandomProductHierarchyComplete = FALSE,
    GlobalJointBoundaryProfileCertified = FALSE,
    HessianInferenceAuthorized = FALSE,
    DFFFitRankAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_run_gpcm_reflected_finite_grid_registry_p1o <- function(
    p1n,
    progress = FALSE) {
  mfrmr_grfg_p1o_require_sources()
  mfrmr_grfg_p1o_validate_result(p1n)
  sources <- mfrmr_grfg_p1o_sources(p1n)
  points <- mfrmr_grfg_p1o_point_registry(sources, progress = progress)
  high <- mfrmr_grfg_p1o_high_cells(sources, points)
  registry <- mfrmr_grfg_p1o_four_fixture_registry(high)
  overall <- mfrmr_grfg_p1o_overall(points, high, registry)
  structure(
    list(
      contract = mfrmr_grfg_p1o_contract,
      specification = mfrmr_grfg_p1o_specification,
      dependency_contract = mfrmr_grfg_p1o_dependency_contract,
      dependency_sha256 = mfrmr_grfg_p1o_dependency_sha256,
      points = points,
      high_cells = high,
      four_fixture_registry = registry,
      overall_decision = overall,
      p1n = p1n,
      FullFourFixtureFiniteGridRegistryCompleted =
        overall$FullFourFixtureFiniteGridRegistryCompleted,
      RefitFallbackRequired = overall$RefitFallbackRequired,
      ReflectedFiniteGridFixturesEvaluated =
        overall$ReflectedFiniteGridFixturesEvaluated,
      ReflectedFixturesEvaluated = FALSE,
      FullFourFixtureRatioProfilesCompleted = FALSE,
      ContinuousGlobalProfileCertified = FALSE,
      CoefficientRatioProfilesCompleted = FALSE,
      AllSixTwoTargetFacesGloballyCertified = FALSE,
      ThreeTargetFacesEvaluated = FALSE,
      EmptyRandomProductHierarchyComplete = FALSE,
      GlobalJointBoundaryProfileCertified = FALSE,
      HessianInferenceAuthorized = FALSE,
      DFFFitRankAuthorized = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_reflected_finite_grid_registry_p1o"
  )
}

print.mfrmr_gpcm_reflected_finite_grid_registry_p1o <- function(x, ...) {
  cat("GPCM reflected finite-grid registry P1o audit\n")
  print(x$overall_decision, row.names = FALSE)
  invisible(x)
}
