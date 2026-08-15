# Deterministic cross-family templates for the ConQuest simulation program.
#
# These templates close ASP-G1 without sampling responses, fitting mfrmr, or
# launching ConQuest. Prototype responses exist only to prove support,
# boundary, missingness, and rejection semantics. They are forbidden as smoke,
# calibration, or confirmation data.

mfrmr_cq_ast_specification <-
  "0.2.3-conquest-adversarial-simulation-template-contract-v1"
mfrmr_cq_ast_contract <-
  "mfrmr_conquest_adversarial_simulation_template_contract_v1"

mfrmr_cq_ast_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_ast_require_contracts <- function() {
  target <- environment(mfrmr_cq_ast_require_contracts)
  ready <- exists(
    "mfrmr_cq_asp_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_asp_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_adversarial_simulation_program_v1"
  ) && exists(
    "mfrmr_cq_p2_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_p2_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_p2_additive_adversarial_fixtures_v1"
  ) && exists(
    "mfrmr_cq_asp_scenario_registry", envir = target,
    mode = "function", inherits = TRUE
  ) && exists(
    "mfrmr_cq_p2_matrix_contract", envir = target,
    mode = "function", inherits = TRUE
  ) && exists(
    "mfrmr_cq_p2_graph_audit", envir = target,
    mode = "function", inherits = TRUE
  ) && exists(
    "mfrmr_cq_p2_support_audit", envir = target,
    mode = "function", inherits = TRUE
  )
  mfrmr_cq_ast_assert(
    ready,
    paste(
      "Source the exact adversarial-simulation program and P2 additive",
      "fixture contracts before the cross-family template contract."
    )
  )
  invisible(TRUE)
}

mfrmr_cq_ast_complete_grid <- function() {
  data <- expand.grid(
    PersonIndex = seq_len(48L),
    RaterIndex = seq_len(4L),
    CriterionIndex = seq_len(3L),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  data <- data[order(
    data$PersonIndex, data$RaterIndex, data$CriterionIndex
  ), , drop = FALSE]
  rownames(data) <- NULL
  data$Person <- sprintf("ASPT%03d", data$PersonIndex)
  data$X <- ifelse(data$PersonIndex <= 24L, -1, 1)
  data$Rater <- paste0("R", data$RaterIndex)
  data$Criterion <- paste0("C", data$CriterionIndex)
  data$Response <- as.integer(
    (3L * data$PersonIndex + 2L * data$RaterIndex +
       data$CriterionIndex + 1L) %% 4L
  )
  data[, c(
    "Person", "PersonIndex", "X", "Rater", "RaterIndex",
    "Criterion", "CriterionIndex", "Response"
  ), drop = FALSE]
}

mfrmr_cq_ast_assignment <- function(scenario_class_id, grid) {
  person <- grid$PersonIndex
  rater <- grid$RaterIndex
  if (scenario_class_id == "ASP-POS-COMPLETE") {
    return(rep(TRUE, nrow(grid)))
  }
  if (scenario_class_id %in% c(
    "ASP-POS-SPARSE-MULTIBRIDGE",
    "ASP-INV-PAIRED-MISSINGNESS",
    "ASP-SENS-RARE-BOUNDARY-CATEGORY",
    "ASP-SENS-EXTREME-PERSON",
    "ASP-NEG-UNUSED-INTERMEDIATE-CATEGORY"
  )) {
    group <- ((person - 1L) %/% 12L) + 1L
    pair <- list(c(1L, 2L), c(2L, 3L), c(3L, 4L), c(4L, 1L))
    return(vapply(seq_along(person), function(index) {
      rater[index] %in% pair[[group[index]]]
    }, logical(1L)))
  }
  if (scenario_class_id == "ASP-SENS-WEAK-SINGLE-BRIDGE") {
    return(
      (person <= 10L & rater %in% c(1L, 2L)) |
        (person >= 11L & person <= 20L & rater %in% c(2L, 3L)) |
        (person >= 21L & person <= 30L & rater %in% c(3L, 1L)) |
        (person >= 31L & person <= 32L & rater %in% c(3L, 4L)) |
        (person >= 33L & rater == 4L)
    )
  }
  if (scenario_class_id == "ASP-SENS-UNEQUAL-WORKLOAD") {
    return(
      rater == 1L |
        (rater == 2L & person <= 36L) |
        (rater == 3L & person >= 13L & person <= 36L) |
        (rater == 4L & person >= 25L)
    )
  }
  if (scenario_class_id == "ASP-NEG-DISCONNECTED-DESIGN") {
    return(
      (person <= 24L & rater %in% c(1L, 2L)) |
        (person >= 25L & rater %in% c(3L, 4L))
    )
  }
  mfrmr_cq_ast_assert(
    FALSE, paste0("Unknown ASP scenario class: `", scenario_class_id, "`.")
  )
}

mfrmr_cq_ast_rare_responses <- function(data) {
  group <- split(
    seq_len(nrow(data)), paste(data$Rater, data$Criterion, sep = "::")
  )
  response <- integer(nrow(data))
  for (index in group) {
    ordered <- index[order(data$PersonIndex[index])]
    response[ordered] <- 1L + (seq_along(ordered) %% 2L)
    zero <- 1L + ((5L * data$RaterIndex[ordered[1L]] +
                     3L * data$CriterionIndex[ordered[1L]]) %%
                    length(ordered))
    maximum <- 1L + ((7L * data$RaterIndex[ordered[1L]] +
                        5L * data$CriterionIndex[ordered[1L]] + 10L) %%
                       length(ordered))
    if (maximum == zero) maximum <- 1L + (maximum %% length(ordered))
    response[ordered[zero]] <- 0L
    response[ordered[maximum]] <- 3L
  }
  response
}

mfrmr_cq_ast_template_registry <- function() {
  mfrmr_cq_ast_require_contracts()
  scenarios <- mfrmr_cq_asp_scenario_registry()$ScenarioClassId
  out <- expand.grid(
    Family = c("RSM", "PCM"),
    ScenarioClassId = scenarios,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  out <- out[order(
    match(out$ScenarioClassId, scenarios), match(out$Family, c("RSM", "PCM"))
  ), , drop = FALSE]
  rownames(out) <- NULL
  out$ArmId <- paste(out$ScenarioClassId, out$Family, sep = "::")
  out$TemplateId <- paste0(
    "mfrmr-0.2.3-conquest-asp-template-",
    tolower(gsub("[^A-Za-z0-9]+", "-", out$ScenarioClassId)), "-",
    tolower(out$Family), "-v1"
  )
  new_arm <-
    out$ScenarioClassId == "ASP-POS-COMPLETE" |
    (out$ScenarioClassId == "ASP-INV-PAIRED-MISSINGNESS" &
       out$Family == "PCM") |
    (out$ScenarioClassId == "ASP-SENS-RARE-BOUNDARY-CATEGORY" &
       out$Family == "RSM") |
    (out$ScenarioClassId == "ASP-SENS-EXTREME-PERSON" &
       out$Family == "PCM") |
    (out$ScenarioClassId == "ASP-NEG-UNUSED-INTERMEDIATE-CATEGORY" &
       out$Family == "RSM") |
    (out$ScenarioClassId == "ASP-NEG-DISCONNECTED-DESIGN" &
       out$Family == "PCM")
  out$NewArmRelativeToP2Registry <- new_arm
  out$ExpectedLocationPredictorDimension <- ifelse(
    out$Family == "RSM", 9L, 13L
  )
  out$ExpectedLocationPredictorRank <-
    out$ExpectedLocationPredictorDimension -
    as.integer(out$ScenarioClassId == "ASP-NEG-DISCONNECTED-DESIGN")
  out$ExpectedDisposition <- ifelse(
    grepl("^ASP-NEG-", out$ScenarioClassId),
    "reject_before_numeric_comparison",
    "eligible_for_future_sampled_response_design_only"
  )
  out$PrototypeOnly <- TRUE
  out$SampledResponseData <- FALSE
  out$ExecutionAuthorized <- FALSE
  out$PublicClaimAuthorized <- FALSE
  out
}

mfrmr_cq_ast_template <- function(arm_id) {
  mfrmr_cq_ast_require_contracts()
  registry <- mfrmr_cq_ast_template_registry()
  row <- registry[registry$ArmId == as.character(arm_id)[1L], , drop = FALSE]
  mfrmr_cq_ast_assert(nrow(row) == 1L, "`arm_id` must identify one ASP arm.")
  grid <- mfrmr_cq_ast_complete_grid()
  keep <- mfrmr_cq_ast_assignment(row$ScenarioClassId, grid)
  primary <- grid[keep, , drop = FALSE]
  rownames(primary) <- NULL
  companion <- NULL
  representation <- "observed_rows_only"
  if (row$ScenarioClassId == "ASP-INV-PAIRED-MISSINGNESS") {
    companion <- grid
    companion$Response[!keep] <- NA_integer_
    representation <- "planned_absent_primary_and_explicit_missing_companion"
  }
  if (row$ScenarioClassId == "ASP-SENS-RARE-BOUNDARY-CATEGORY") {
    primary$Response <- mfrmr_cq_ast_rare_responses(primary)
  }
  if (row$ScenarioClassId == "ASP-SENS-EXTREME-PERSON") {
    primary$Response[primary$Person == "ASPT001"] <- 0L
    primary$Response[primary$Person == "ASPT048"] <- 3L
  }
  if (row$ScenarioClassId == "ASP-NEG-UNUSED-INTERMEDIATE-CATEGORY") {
    primary$Response[primary$Response == 1L] <- 2L
  }
  list(
    Specification = mfrmr_cq_ast_specification,
    ContractVersion = mfrmr_cq_ast_contract,
    ArmId = row$ArmId,
    TemplateId = row$TemplateId,
    ScenarioClassId = row$ScenarioClassId,
    Family = row$Family,
    ExpectedDisposition = row$ExpectedDisposition,
    ExpectedLocationPredictorDimension =
      row$ExpectedLocationPredictorDimension,
    ExpectedLocationPredictorRank = row$ExpectedLocationPredictorRank,
    Representation = representation,
    DeclaredCategories = 0:3,
    Data = primary,
    ExplicitMissingCompanion = companion,
    PrototypeOnly = TRUE,
    SampledResponseData = FALSE,
    ExternalExecutionAuthorized = FALSE,
    ComparisonPassed = FALSE,
    ScientificEquivalenceInferred = FALSE
  )
}

mfrmr_cq_ast_templates <- function() {
  registry <- mfrmr_cq_ast_template_registry()
  out <- lapply(registry$ArmId, mfrmr_cq_ast_template)
  names(out) <- registry$ArmId
  out
}

mfrmr_cq_ast_location_predictor_rank <- function(template) {
  mfrmr_cq_ast_require_contracts()
  data <- template$Data[!is.na(template$Data$Response), , drop = FALSE]
  cells <- unique(data[, c("X", "Rater", "Criterion"), drop = FALSE])
  contract <- mfrmr_cq_p2_matrix_contract(template$Family)
  block <- lapply(seq_len(nrow(cells)), function(index) {
    selected <- contract$C$Rater == cells$Rater[index] &
      contract$C$Criterion == cells$Criterion[index]
    category <- contract$C$Category[selected]
    cbind(
      PopulationIntercept = category,
      PopulationSlope = category * cells$X[index],
      contract$A[selected, , drop = FALSE]
    )
  })
  design <- do.call(rbind, block)
  singular <- svd(design, nu = 0L, nv = 0L)$d
  tolerance <- c(1e-12, 1e-10, 1e-8)
  rank <- vapply(tolerance, function(value) {
    sum(singular > max(singular) * value)
  }, integer(1L))
  data.frame(
    ArmId = template$ArmId,
    Dimension = ncol(design),
    RankAt1e12 = rank[1L],
    RankAt1e10 = rank[2L],
    RankAt1e8 = rank[3L],
    NullityAt1e10 = ncol(design) - rank[2L],
    SmallestSingularValue = min(singular),
    ConditionIndex = if (min(singular) > 0) {
      max(singular) / min(singular)
    } else {
      Inf
    },
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ast_missingness_equivalent <- function(template) {
  if (template$ScenarioClassId != "ASP-INV-PAIRED-MISSINGNESS") {
    return(NA)
  }
  companion <- template$ExplicitMissingCompanion
  companion <- companion[!is.na(companion$Response), , drop = FALSE]
  companion <- companion[order(
    companion$PersonIndex, companion$RaterIndex, companion$CriterionIndex
  ), , drop = FALSE]
  rownames(companion) <- NULL
  identical(template$Data, companion)
}

mfrmr_cq_ast_arm_audit <- function(template) {
  proxy <- list(Data = template$Data, RegistryRowId = template$ArmId)
  graph <- mfrmr_cq_p2_graph_audit(proxy)
  support <- mfrmr_cq_p2_support_audit(proxy)
  rank <- mfrmr_cq_ast_location_predictor_rank(template)
  scenario <- template$ScenarioClassId
  rank_match <-
    rank$Dimension == template$ExpectedLocationPredictorDimension &&
    all(c(rank$RankAt1e12, rank$RankAt1e10, rank$RankAt1e8) ==
          template$ExpectedLocationPredictorRank)
  scenario_pass <- switch(
    scenario,
    "ASP-POS-COMPLETE" =
      nrow(template$Data) == 576L && graph$Connected &&
        graph$PositiveEdgeCount == 6L && graph$BridgeEdgeCount == 0L &&
        length(unique(graph$RaterLoads)) == 1L && rank_match,
    "ASP-POS-SPARSE-MULTIBRIDGE" =
      graph$Connected && graph$PositiveEdgeCount == 4L &&
        graph$BridgeEdgeCount == 0L && rank_match,
    "ASP-SENS-WEAK-SINGLE-BRIDGE" =
      graph$Connected && graph$BridgeEdgeCount == 1L &&
        graph$MinPositiveCommonPersons == 2L && rank_match,
    "ASP-SENS-UNEQUAL-WORKLOAD" =
      graph$Connected && graph$RaterLoadMax > graph$RaterLoadMin && rank_match,
    "ASP-INV-PAIRED-MISSINGNESS" =
      graph$Connected && isTRUE(mfrmr_cq_ast_missingness_equivalent(template)) &&
        nrow(template$ExplicitMissingCompanion) == 576L &&
        sum(is.na(template$ExplicitMissingCompanion$Response)) == 288L &&
        rank_match,
    "ASP-SENS-RARE-BOUNDARY-CATEGORY" =
      all(support[, paste0("Category", 0:3)] > 0L) &&
        support$Category0 < support$Category1 &&
        support$Category3 < support$Category2 &&
        support$MinimumScorePersons == 0L &&
        support$MaximumScorePersons == 0L && rank_match,
    "ASP-SENS-EXTREME-PERSON" =
      support$MinimumScorePersons == 1L &&
        support$MaximumScorePersons == 1L && rank_match,
    "ASP-NEG-UNUSED-INTERMEDIATE-CATEGORY" =
      support$Category1 == 0L &&
        all(support[, c("Category0", "Category2", "Category3")] > 0L) &&
        rank_match,
    "ASP-NEG-DISCONNECTED-DESIGN" =
      !graph$Connected && graph$Components == 2L && rank_match,
    FALSE
  )
  data.frame(
    ArmId = template$ArmId,
    ScenarioClassId = scenario,
    Family = template$Family,
    ObservedRows = nrow(template$Data),
    GraphComponents = graph$Components,
    GraphConnected = graph$Connected,
    PredictorDimension = rank$Dimension,
    PredictorRank = rank$RankAt1e10,
    ExpectedPredictorRank = template$ExpectedLocationPredictorRank,
    RankMatchesExpected = rank_match,
    Category0 = support$Category0,
    Category1 = support$Category1,
    Category2 = support$Category2,
    Category3 = support$Category3,
    MinimumScorePersons = support$MinimumScorePersons,
    MaximumScorePersons = support$MaximumScorePersons,
    MissingnessEquivalent = mfrmr_cq_ast_missingness_equivalent(template),
    ScenarioContractPass = isTRUE(scenario_pass),
    PrototypeOnly = template$PrototypeOnly,
    SampledResponseData = template$SampledResponseData,
    ExternalExecutionAuthorized = template$ExternalExecutionAuthorized,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ast_review <- function() {
  mfrmr_cq_ast_require_contracts()
  program <- mfrmr_cq_asp_review()
  registry <- mfrmr_cq_ast_template_registry()
  templates <- mfrmr_cq_ast_templates()
  audit <- do.call(rbind, lapply(templates, mfrmr_cq_ast_arm_audit))
  rownames(audit) <- NULL
  scenario_count <- table(factor(
    registry$ScenarioClassId,
    levels = mfrmr_cq_asp_scenario_registry()$ScenarioClassId
  ))
  valid <-
    identical(program$status,
              "prospective_architecture_frozen_execution_closed") &&
    nrow(registry) == 18L && !anyDuplicated(registry$ArmId) &&
    all(scenario_count == 2L) &&
    sum(registry$NewArmRelativeToP2Registry) == 7L &&
    length(templates) == 18L &&
    !anyDuplicated(vapply(templates, `[[`, character(1L), "TemplateId")) &&
    all(grepl("^ASPT", unlist(lapply(
      templates, function(value) unique(value$Data$Person)
    )))) &&
    nrow(audit) == 18L && all(audit$RankMatchesExpected) &&
    all(audit$ScenarioContractPass) && all(audit$PrototypeOnly) &&
    !any(audit$SampledResponseData) &&
    !any(audit$ExternalExecutionAuthorized)
  list(
    specification = mfrmr_cq_ast_specification,
    contract_version = mfrmr_cq_ast_contract,
    status = if (valid) {
      "ASP_G1_cross_family_deterministic_templates_complete_execution_closed"
    } else {
      "ASP_G1_template_contract_invalid"
    },
    template_registry = registry,
    arm_audit = audit,
    scenario_classes = 9L,
    family_arms = 18L,
    scenario_gaps_closed = 6L,
    new_arms_relative_to_P2_registry = 7L,
    legacy_disconnected_label_used_as_proof = FALSE,
    disconnected_full_location_predictor_rank_checked = TRUE,
    unused_category_rejection_is_rank_claim = FALSE,
    unused_category_rejection_is_support_boundary_claim = TRUE,
    ASP_G1_complete = valid,
    next_gate = "ASP-G2-DGP-ORACLE-SEPARATION",
    prototype_responses_reusable_as_sampled_data = FALSE,
    any_random_response_generated = FALSE,
    any_fit_attempted = FALSE,
    ConQuest_execution_attempted = FALSE,
    public_text_change_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
