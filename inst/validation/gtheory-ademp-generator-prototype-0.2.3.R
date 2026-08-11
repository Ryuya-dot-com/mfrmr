# Draft.83d2a deterministic G-theory ADEMP generator prototype.
#
# Repository-internal only. This file turns the Draft.83d1 scenario registry
# into complete potential, assigned, and post-missingness tables. It performs
# no backend fit and supplies no recovery or interval evidence.

mfrmr_gtd2_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gta_spec", "mfrmr_gte_mom",
    "mfrmr_gtd_registry", "mfrmr_gtd_validate_registry"
  )
  prototype_environment <- environment(mfrmr_gtd2_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = prototype_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.81, Draft.82, and Draft.83d1 before Draft.83d2a: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtd2_spec <- function(scenario) {
  design <- scenario$DesignFamily[[1L]]
  if (design == "nested_site_rater") {
    return(mfrmr_gta_spec(
      Score ~ 1 + (1 | Person) + (1 | Site/Rater) + (1 | Criterion),
      object = "Person", facets = c("Site", "Rater", "Criterion"),
      nesting = data.frame(
        Parent = "Site", Child = "Rater", stringsAsFactors = FALSE
      ),
      residual_scale_by = c("Site", "Rater", "Criterion")
    ))
  }
  formula <- if (design == "saturated_unreplicated") {
    Score ~ 1 +
      (1 | Person) + (1 | Rater) + (1 | Criterion) +
      (1 | Person:Rater) + (1 | Person:Criterion) +
      (1 | Rater:Criterion) + (1 | Person:Rater:Criterion)
  } else {
    Score ~ 1 +
      (1 | Person) + (1 | Rater) + (1 | Criterion) +
      (1 | Person:Rater) + (1 | Person:Criterion) +
      (1 | Rater:Criterion)
  }
  mfrmr_gta_spec(
    formula, object = "Person", facets = c("Rater", "Criterion"),
    residual_scale_by = c("Rater", "Criterion")
  )
}

mfrmr_gtd2_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtd2_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtd2_spec", "mfrmr_gtd2_full_design",
    "mfrmr_gtd2_component_variance", "mfrmr_gtd2_effect_key",
    "mfrmr_gtd2_residual", "mfrmr_gtd2_continuous_score",
    "mfrmr_gtd2_categorize", "mfrmr_gtd2_assignment_indices",
    "mfrmr_gtd2_missing_indices", "mfrmr_gtd2_audits",
    "mfrmr_gtd2_generate"
  )
  environment <- environment(mfrmr_gtd2_function_hashes)
  stats::setNames(vapply(
    functions,
    function(name) mfrmr_gtd2_function_hash(get(
      name, envir = environment, inherits = TRUE
    )),
    character(1L)
  ), functions)
}

mfrmr_gtd2_full_design <- function(scenario) {
  persons <- factor(sprintf("P%03d", seq_len(scenario$NPerson[[1L]])))
  criteria <- factor(sprintf("C%02d", seq_len(scenario$NCriterion[[1L]])))
  if (scenario$DesignFamily[[1L]] == "nested_site_rater") {
    total_raters <- scenario$NRater[[1L]]
    site_count <- 2L
    if (total_raters %% site_count != 0L) {
      stop("The frozen nested fixture needs equal Raters within two Sites.",
           call. = FALSE)
    }
    raters_per_site <- total_raters %/% site_count
    condition <- expand.grid(
      Site = factor(sprintf("S%02d", seq_len(site_count))),
      Rater = factor(sprintf("R%02d", seq_len(raters_per_site))),
      Criterion = criteria, KEEP.OUT.ATTRS = FALSE
    )
    data <- merge(
      data.frame(Person = persons), condition, by = NULL, sort = FALSE
    )
    data <- data[c("Person", "Site", "Rater", "Criterion")]
  } else {
    raters <- factor(sprintf("R%02d", seq_len(scenario$NRater[[1L]])))
    data <- expand.grid(
      Person = persons, Rater = raters, Criterion = criteria,
      KEEP.OUT.ATTRS = FALSE
    )
  }
  data$Person <- factor(as.character(data$Person), levels = levels(persons))
  data
}

mfrmr_gtd2_component_variance <- function(component_id, scenario) {
  if (component_id == "Person") return(1)
  if (component_id == "Residual") return(0.48)
  members <- strsplit(component_id, ":", fixed = TRUE)[[1L]]
  contains_person <- "Person" %in% members
  value <- if (length(members) == 1L) {
    if (component_id == "Criterion") 0.18 else 0.12
  } else if (contains_person) {
    if ("Criterion" %in% members) 0.30 else 0.24
  } else if (length(members) == 2L) {
    0.08
  } else {
    0.06
  }
  if (component_id == "Rater" || component_id == "Site:Rater") {
    state <- scenario$VarianceState[[1L]]
    if (state == "near_zero") value <- 1e-10
    if (state == "exact_zero") value <- 0
  }
  value
}

mfrmr_gtd2_effect_key <- function(data, members) {
  if (length(members) == 1L) return(as.character(data[[members]]))
  do.call(paste, c(lapply(data[members], as.character), list(sep = "\034")))
}

mfrmr_gtd2_residual <- function(data, variance, rho) {
  if (variance == 0) return(rep(0, nrow(data)))
  if (rho == 0) return(stats::rnorm(nrow(data), 0, sqrt(variance)))
  output <- numeric(nrow(data))
  persons <- levels(data$Person)
  for (person in persons) {
    index <- which(data$Person == person)
    size <- length(index)
    covariance <- variance * toeplitz(rho^(0:(size - 1L)))
    root <- chol(covariance)
    output[index] <- as.numeric(t(root) %*% stats::rnorm(size))
  }
  output
}

mfrmr_gtd2_continuous_score <- function(spec, data, scenario) {
  score <- numeric(nrow(data))
  truth <- stats::setNames(numeric(nrow(spec$EffectMap)),
                          spec$EffectMap$ComponentId)
  effects <- list()
  for (component_id in spec$EffectMap$ComponentId) {
    variance <- mfrmr_gtd2_component_variance(component_id, scenario)
    truth[[component_id]] <- variance
    if (component_id == "Residual") {
      value <- mfrmr_gtd2_residual(
        data, variance, scenario$LocalDependenceRho[[1L]]
      )
      score <- score + value
      effects[[component_id]] <- data.frame(
        LevelId = seq_len(nrow(data)), Effect = value,
        stringsAsFactors = FALSE
      )
      next
    }
    members <- strsplit(component_id, ":", fixed = TRUE)[[1L]]
    key <- mfrmr_gtd2_effect_key(data, members)
    levels <- sort(unique(key), method = "radix")
    value <- if (variance == 0) rep(0, length(levels)) else
      stats::rnorm(length(levels), 0, sqrt(variance))
    names(value) <- levels
    score <- score + value[key]
    effects[[component_id]] <- data.frame(
      LevelId = levels, Effect = as.numeric(value), stringsAsFactors = FALSE
    )
  }
  list(Score = score, NominalTruth = truth, GeneratedEffects = effects)
}

mfrmr_gtd2_categorize <- function(score, categories, endpoint_rate) {
  categories <- as.integer(categories)
  if (categories < 3L) stop("Bounded projection needs at least 3 categories.",
                            call. = FALSE)
  count <- length(score)
  order_index <- order(score, seq_along(score))
  endpoint_count <- as.integer(round(endpoint_rate * count))
  low_count <- endpoint_count %/% 2L
  high_count <- endpoint_count - low_count
  result <- integer(count)
  if (low_count > 0L) result[order_index[seq_len(low_count)]] <- 1L
  if (high_count > 0L) {
    result[order_index[count - seq_len(high_count) + 1L]] <- categories
  }
  remaining <- which(result == 0L)
  remaining <- remaining[order(score[remaining], remaining)]
  if (length(remaining) > 0L) {
    internal <- 2L + floor(
      (seq_along(remaining) - 1L) * (categories - 2L) / length(remaining)
    )
    result[remaining] <- pmin(internal, categories - 1L)
  }
  as.numeric(result)
}

mfrmr_gtd2_assignment_indices <- function(data, scenario) {
  topology <- scenario$AssignmentTopology[[1L]]
  if (topology %in% c("complete", "nested", "saturated")) {
    return(seq_len(nrow(data)))
  }
  persons <- levels(data$Person)
  observations <- scenario$ObservationsPerPerson[[1L]]
  rows <- split(seq_len(nrow(data)), data$Person)
  selected <- vector("list", length(persons)); names(selected) <- persons
  rater_levels <- levels(data$Rater)
  for (person_index in seq_along(persons)) {
    index <- rows[[persons[[person_index]]]]
    cells <- data[index, , drop = FALSE]
    if (topology == "connected_cycle") {
      offset <- (person_index - 1L) %% nrow(cells)
      chosen <- ((seq_len(observations) - 1L + offset) %% nrow(cells)) + 1L
    } else if (topology == "connected_hub") {
      hub_weight <- if (scenario$WorkloadImbalance[[1L]] == "high") 15 else 4
      probability <- ifelse(cells$Rater == rater_levels[[1L]], hub_weight, 1)
      chosen <- sample.int(
        nrow(cells), observations, replace = FALSE, prob = probability
      )
    } else if (topology == "disconnected") {
      half <- length(rater_levels) %/% 2L
      allowed <- if (person_index <= length(persons) / 2) {
        rater_levels[seq_len(half)]
      } else {
        rater_levels[half + seq_len(length(rater_levels) - half)]
      }
      possible <- which(cells$Rater %in% allowed)
      offset <- (person_index - 1L) %% length(possible)
      chosen <- possible[
        ((seq_len(observations) - 1L + offset) %% length(possible)) + 1L
      ]
    } else {
      stop("Unknown assignment topology: ", topology, ".", call. = FALSE)
    }
    selected[[person_index]] <- index[chosen]
  }
  sort(unlist(selected, use.names = FALSE))
}

mfrmr_gtd2_missing_indices <- function(data, scenario) {
  rate <- scenario$MissingRate[[1L]]
  if (rate == 0) return(integer())
  count <- min(nrow(data), as.integer(round(rate * nrow(data))))
  mechanism <- scenario$MissingnessMechanism[[1L]]
  uniform <- stats::runif(nrow(data))
  if (mechanism == "MCAR") {
    risk <- uniform
  } else if (mechanism == "MAR_rater_load") {
    load <- table(data$Rater)
    value <- as.numeric(load[as.character(data$Rater)])
    standardized <- if (stats::sd(value) > 0) as.numeric(scale(value)) else 0
    risk <- standardized + uniform
  } else if (mechanism == "MNAR_score") {
    standardized <- if (stats::sd(data$Score) > 0) {
      as.numeric(scale(data$Score))
    } else 0
    risk <- standardized + uniform
  } else if (mechanism == "unknown") {
    rater <- as.integer(data$Rater)
    standardized <- if (stats::sd(data$Score) > 0) {
      as.numeric(scale(data$Score))
    } else 0
    risk <- sin(rater) + 0.5 * standardized + uniform
  } else {
    stop("Missingness rate is positive for an unsupported mechanism.",
         call. = FALSE)
  }
  order(risk, decreasing = TRUE)[seq_len(count)]
}

mfrmr_gtd2_cv <- function(value) {
  value <- as.numeric(value)
  if (length(value) < 2L || mean(value) == 0) return(0)
  stats::sd(value) / mean(value)
}

mfrmr_gtd2_audits <- function(
    full, assigned, analysis, scenario, missing_index) {
  person_count <- table(assigned$Person)
  rater_count <- table(assigned$Rater)
  endpoint_rate <- if (scenario$ScoreSupport[[1L]] == "bounded_ordinal") {
    mean(assigned$Score %in% c(1, scenario$CategoryCount[[1L]]))
  } else NA_real_
  list(
    Assignment = data.frame(
      PotentialRows = nrow(full), AssignedRows = nrow(assigned),
      PlannedObservationsPerPerson = scenario$ObservationsPerPerson[[1L]],
      MinimumObservationsPerPerson = min(person_count),
      MaximumObservationsPerPerson = max(person_count),
      RealizedAssignmentDensity = nrow(assigned) / nrow(full),
      RaterLoadCV = mfrmr_gtd2_cv(rater_count),
      ZeroLoadRaters = sum(rater_count == 0L), stringsAsFactors = FALSE
    ),
    Missingness = data.frame(
      AssignedRows = nrow(assigned), OmittedRows = length(missing_index),
      RealizedMissingRate = length(missing_index) / nrow(assigned),
      RetainedRows = sum(is.finite(analysis$Score)),
      Mechanism = scenario$MissingnessMechanism[[1L]], stringsAsFactors = FALSE
    ),
    Score = data.frame(
      Support = scenario$ScoreSupport[[1L]],
      DeclaredCategories = scenario$CategoryCount[[1L]],
      ObservedCategoryCount = if (scenario$ScoreSupport[[1L]] ==
                                  "bounded_ordinal") {
        length(unique(assigned$Score))
      } else NA_integer_,
      EndpointRate = endpoint_rate,
      LocalDependenceRho = scenario$LocalDependenceRho[[1L]],
      stringsAsFactors = FALSE
    )
  )
}

mfrmr_gtd2_hash_data <- function(data) {
  payload <- data.frame(
    lapply(data, function(value) {
      if (is.factor(value)) as.character(value) else value
    }), stringsAsFactors = FALSE, check.names = FALSE
  )
  mfrmr_gta_hash(payload)
}

mfrmr_gtd2_generate <- function(
    registry = mfrmr_gtd_registry(), scenario_id, replicate = 1L) {
  mfrmr_gtd2_require_primitives()
  mfrmr_gtd_validate_registry(registry)
  scenario_id <- as.character(scenario_id)
  if (length(scenario_id) != 1L || !scenario_id %in%
      registry$Scenarios$ScenarioId) {
    stop("`scenario_id` is not present in the frozen registry.", call. = FALSE)
  }
  if (!is.numeric(replicate) || length(replicate) != 1L ||
      is.na(replicate) || !is.finite(replicate) || replicate < 1L ||
      replicate != floor(replicate)) {
    stop("`replicate` must be one positive integer.", call. = FALSE)
  }
  replicate <- as.integer(replicate)
  scenario <- registry$Scenarios[
    registry$Scenarios$ScenarioId == scenario_id, , drop = FALSE
  ]
  seed <- scenario$SeedStart[[1L]] + replicate - 1L
  if (scenario$ExecutionEligibility[[1L]] != "executable_smoke") {
    result <- list(
      ContractVersion = "mfrmr-gtheory-ademp-generator-draft83d2a-v1",
      ScenarioId = scenario_id, Replicate = replicate, Seed = seed,
      RegistryHash = registry$RegistryHash,
      GenerationState = "blocked_not_current_gstudy_operation",
      BlockingReason = scenario$ExecutionEligibility[[1L]],
      FullPotentialData = NULL, AssignedData = NULL, AnalysisData = NULL,
      GenerationEvidenceReady = FALSE, EstimationReady = FALSE,
      InferenceReady = FALSE, CoefficientEligible = FALSE,
      DecisionReady = FALSE
    )
    class(result) <- c("mfrmr_gtd2_generation", "list")
    return(result)
  }
  old_seed <- if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
    get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  } else NULL
  on.exit({
    if (is.null(old_seed)) {
      if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
        rm(".Random.seed", envir = .GlobalEnv)
      }
    } else {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    }
  }, add = TRUE)
  set.seed(seed)

  spec <- mfrmr_gtd2_spec(scenario)
  full <- mfrmr_gtd2_full_design(scenario)
  generated <- mfrmr_gtd2_continuous_score(spec, full, scenario)
  full$LatentContinuousScore <- generated$Score
  full$Score <- if (scenario$ScoreSupport[[1L]] == "bounded_ordinal") {
    mfrmr_gtd2_categorize(
      generated$Score, scenario$CategoryCount[[1L]],
      scenario$EndpointRateTarget[[1L]]
    )
  } else generated$Score
  assignment_index <- mfrmr_gtd2_assignment_indices(full, scenario)
  assigned <- full[assignment_index, , drop = FALSE]
  row.names(assigned) <- NULL
  missing_index <- mfrmr_gtd2_missing_indices(assigned, scenario)
  analysis <- assigned
  if (length(missing_index) > 0L) analysis$Score[missing_index] <- NA_real_
  audits <- mfrmr_gtd2_audits(
    full, assigned, analysis, scenario, missing_index
  )
  projection_truth <- NULL
  projection_hash <- NA_character_
  if (scenario$TargetBasis[[1L]] ==
      "full_potential_observed_score_projection") {
    projection <- mfrmr_gte_mom(spec, full)
    projection_truth <- stats::setNames(
      projection$Components$Estimate, projection$Components$ComponentId
    )
    projection_hash <- projection$ResultHash
  }
  generator_identity <- list(
    Version = "mfrmr-gtheory-ademp-generator-draft83d2a-v1",
    RegistryHash = registry$RegistryHash, ScenarioId = scenario_id,
    Replicate = replicate, Seed = seed, DesignHash = spec$DesignHash,
    ScenarioRowHash = mfrmr_gta_hash(scenario),
    FullPotentialDataHash = mfrmr_gtd2_hash_data(full),
    AssignedDataHash = mfrmr_gtd2_hash_data(assigned),
    AnalysisDataHash = mfrmr_gtd2_hash_data(analysis),
    NominalTruthHash = mfrmr_gta_hash(generated$NominalTruth),
    ProjectionTruthHash = projection_hash,
    AssignmentAuditHash = mfrmr_gta_hash(audits$Assignment),
    MissingnessAuditHash = mfrmr_gta_hash(audits$Missingness),
    ScoreAuditHash = mfrmr_gta_hash(audits$Score)
  )
  generator_identity$FunctionHashes <- mfrmr_gtd2_function_hashes()
  result <- list(
    ContractVersion = generator_identity$Version,
    ScenarioId = scenario_id, Replicate = replicate, Seed = seed,
    RegistryHash = registry$RegistryHash, Scenario = scenario, Spec = spec,
    GenerationState = "generated_not_fitted",
    FullPotentialData = full, AssignedData = assigned,
    AnalysisData = analysis, NominalTruth = generated$NominalTruth,
    ProjectionTruth = projection_truth,
    GeneratedEffects = generated$GeneratedEffects,
    AssignmentAudit = audits$Assignment,
    MissingnessAudit = audits$Missingness, ScoreAudit = audits$Score,
    GeneratorIdentity = generator_identity,
    GeneratorHash = mfrmr_gta_hash(generator_identity),
    GenerationEvidenceReady = TRUE, EstimationReady = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )
  class(result) <- c("mfrmr_gtd2_generation", "list")
  result
}

mfrmr_gtd2_generate_registry_smoke <- function(
    registry = mfrmr_gtd_registry()) {
  mfrmr_gtd_validate_registry(registry)
  results <- lapply(registry$Scenarios$ScenarioId, function(scenario_id) {
    mfrmr_gtd2_generate(registry, scenario_id, replicate = 1L)
  })
  names(results) <- registry$Scenarios$ScenarioId
  summary <- do.call(rbind, lapply(results, function(result) {
    if (result$GenerationState != "generated_not_fitted") {
      return(data.frame(
        ScenarioId = result$ScenarioId,
        GenerationState = result$GenerationState,
        FullRows = NA_integer_, AssignedRows = NA_integer_,
        RetainedRows = NA_integer_, GeneratorHash = NA_character_,
        stringsAsFactors = FALSE
      ))
    }
    data.frame(
      ScenarioId = result$ScenarioId,
      GenerationState = result$GenerationState,
      FullRows = nrow(result$FullPotentialData),
      AssignedRows = nrow(result$AssignedData),
      RetainedRows = sum(is.finite(result$AnalysisData$Score)),
      GeneratorHash = result$GeneratorHash, stringsAsFactors = FALSE
    )
  }))
  row.names(summary) <- NULL
  list(
    RegistryHash = registry$RegistryHash, Results = results,
    Summary = summary, GeneratedScenarios = sum(
      summary$GenerationState == "generated_not_fitted"
    ),
    BlockedScenarios = sum(
      summary$GenerationState == "blocked_not_current_gstudy_operation"
    ),
    GeneratorSmokeHash = mfrmr_gta_hash(summary),
    EstimationReady = FALSE, DecisionReady = FALSE
  )
}
