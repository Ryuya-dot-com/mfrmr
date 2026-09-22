# Internal D-SIM-3 generic stochastic response-generation adapter.
#
# This third shared-substrate layer generates one nonpromoting shadow fixture
# per frozen profile. It never opens the reserved 855 exploratory band, calls a
# backend, fits a model, or produces simulation-validation evidence.

mfrmr_gtds3g_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3_manifest",
    "mfrmr_gtds3_assert_manifest", "mfrmr_gtds3c_contract",
    "mfrmr_gtds3c_compile_profile", "mfrmr_gtds3b_contract",
    "mfrmr_gtds3b_manifest", "mfrmr_gtds3b_assert_manifest",
    "mfrmr_gtds3b_bind_profile", "mfrmr_gtds3b_assert_binding",
    "mfrmr_gtds3b_correlation", "mfrmr_gtds3b_matrix_audit"
  )
  target <- environment(mfrmr_gtds3g_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the D-SIM-3 covariance/distribution binding chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3g_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3g_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-RESPONSE-GENERATOR-ADAPTER-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentBindingContractId =
      "MFRMR-GTHEORY-MV-DSIM3-COVARIANCE-DISTRIBUTION-BINDING-V1",
    ParentBindingContractHash =
      "293dd2af3e8f13282ae545efa6063306f4cf59d4d7bf1027dca57de9376ae1c4",
    ParentBindingManifestHash =
      "8fcdc0297a0f09c0525a10f8c1a1ffca4310f7b7509f4df3f793f14f68151625",
    ParentBindingRecord = paste0(
      "gtheory-multivariate-dsim3-covariance-distribution-binding-record-",
      "0.2.4.md"
    )
  )
}

mfrmr_gtds3g_contract <- function() {
  mfrmr_gtds3g_require_primitives()
  identity <- mfrmr_gtds3g_identity()
  payload <- c(identity, list(
    ExpectedProfileCount = 21L,
    ExpectedComponentCount = 4L,
    ExpectedUnitCovarianceAuditCount = 84L,
    ExpectedShadowFixtureCount = 21L,
    ShadowSeedBandId = "NONRESERVED-FIXTURE-854",
    ShadowSeedBase = 854100000L,
    ShadowSeedFormula = "ShadowSeedBase+ScenarioOrdinal",
    MinimumShadowSeed = 854100001L,
    MaximumShadowSeed = 854100021L,
    ReservedExploratoryLowerInclusive = 855000000L,
    ReservedExploratoryUpperInclusive = 855999999L,
    RNGKind = "L'Ecuyer-CMRG",
    NormalKind = "Inversion",
    SampleKind = "Rejection",
    SubstreamOrder = c(
      "Object", "Rater", "Object:Rater", "Residual", "Missingness"
    ),
    ComponentIdentityColumns = c(
      Object = "ObjectId", Rater = "ConditionId",
      `Object:Rater` = "ObjectConditionId", Residual = "EventId"
    ),
    ComponentEffectsAreGaussian = c(
      Object = TRUE, Rater = TRUE, `Object:Rater` = TRUE, Residual = FALSE
    ),
    ResidualIsResponseInnovation = TRUE,
    DuplicateResidualRepresentationAllowed = FALSE,
    EffectiveCovarianceIdentityEquation =
      "EffectiveCovariance=UnitCovariance*IdentityOverlap",
    FixedCountMcarRule =
      "uniform_random_rank_outcome_independent_conditional_on_count",
    StochasticMcarSupportRepairAllowed = FALSE,
    CallerRngStateMustBeRestored = TRUE,
    AssignmentUsesRandomness = FALSE,
    OneDrawVectorPerComponentIdentity = TRUE,
    ScenarioSpecificPatchCount = 0L,
    FullGeneratorAdapterQualificationRequired = TRUE,
    Planned855RngStreamAllowed = FALSE,
    BackendCallAllowed = FALSE,
    FitAllowed = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE,
    MatrixTolerance = 1e-10
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3g_hash(payload)
  )), class = c("mfrmr_gtds3g_contract", "list"))
}

mfrmr_gtds3g_validate_contract <- function(
    contract = mfrmr_gtds3g_contract(), binding_manifest = NULL) {
  mfrmr_gtds3g_require_primitives()
  if (is.null(binding_manifest)) binding_manifest <- mfrmr_gtds3b_manifest()
  mfrmr_gtds3b_assert_manifest(binding_manifest)
  canonical <- mfrmr_gtds3g_contract()
  valid <- inherits(contract, "mfrmr_gtds3g_contract") &&
    identical(contract, canonical) &&
    identical(
      contract$ParentBindingContractHash,
      binding_manifest$Contract$ContractHash
    ) && identical(
      contract$ParentBindingManifestHash, binding_manifest$ManifestHash
    ) && identical(contract$ExpectedProfileCount, 21L) &&
    identical(contract$ExpectedComponentCount, 4L) &&
    identical(contract$ExpectedUnitCovarianceAuditCount, 84L) &&
    identical(contract$ExpectedShadowFixtureCount, 21L) &&
    identical(length(contract$SubstreamOrder), 5L) &&
    all(contract$SubstreamOrder[1:4] ==
          binding_manifest$Contract$ComponentRegistry$ComponentId) &&
    contract$MaximumShadowSeed < contract$ReservedExploratoryLowerInclusive &&
    contract$MinimumShadowSeed > 854000000L &&
    isTRUE(contract$ResidualIsResponseInnovation) &&
    !isTRUE(contract$DuplicateResidualRepresentationAllowed) &&
    !isTRUE(contract$StochasticMcarSupportRepairAllowed) &&
    isTRUE(contract$CallerRngStateMustBeRestored) &&
    !isTRUE(contract$AssignmentUsesRandomness) &&
    isTRUE(contract$OneDrawVectorPerComponentIdentity) &&
    identical(contract$ScenarioSpecificPatchCount, 0L) &&
    isTRUE(contract$FullGeneratorAdapterQualificationRequired) &&
    !isTRUE(contract$Planned855RngStreamAllowed) &&
    !isTRUE(contract$BackendCallAllowed) && !isTRUE(contract$FitAllowed) &&
    !isTRUE(contract$ExploratoryExecutionAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-3 response-generator contract is invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3g_with_seed <- function(seed, contract, code) {
  if (!is.function(code) || length(seed) != 1L || is.na(seed) ||
      seed < contract$MinimumShadowSeed ||
      seed > contract$MaximumShadowSeed ||
      seed >= contract$ReservedExploratoryLowerInclusive) {
    stop("A valid nonreserved shadow seed and callback are required.",
         call. = FALSE)
  }
  old_kind <- RNGkind()
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) old_seed <- get(".Random.seed", envir = .GlobalEnv)
  on.exit({
    RNGkind(
      kind = old_kind[[1L]], normal.kind = old_kind[[2L]],
      sample.kind = old_kind[[3L]]
    )
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  RNGkind(
    kind = contract$RNGKind, normal.kind = contract$NormalKind,
    sample.kind = contract$SampleKind
  )
  set.seed(as.integer(seed))
  code()
}

mfrmr_gtds3g_streams <- function(contract) {
  state <- get(".Random.seed", envir = .GlobalEnv)
  states <- stats::setNames(vector("list", length(contract$SubstreamOrder)),
                            contract$SubstreamOrder)
  for (index in seq_along(states)) {
    states[[index]] <- state
    state <- parallel::nextRNGSubStream(state)
  }
  registry <- data.frame(
    StreamOrdinal = seq_along(states),
    StreamId = names(states),
    StreamStateHash = vapply(states, mfrmr_gtds3g_hash, character(1L)),
    Reserved855Identity = FALSE,
    stringsAsFactors = FALSE
  )
  list(States = states, Registry = registry)
}

mfrmr_gtds3g_activate_stream <- function(state) {
  if (!is.integer(state) || length(state) != 7L || state[[1L]] != 10407L) {
    stop("A valid L'Ecuyer-CMRG substream state is required.",
         call. = FALSE)
  }
  assign(".Random.seed", state, envir = .GlobalEnv)
  invisible(TRUE)
}

mfrmr_gtds3g_unit_covariance <- function(
    binding, component_id, binding_contract, contract) {
  component <- binding$ComponentBindings[[component_id]]
  if (is.null(component)) {
    stop("The requested component binding is unavailable.", call. = FALSE)
  }
  strata <- rownames(component$CovarianceMatrix)
  full_identity_overlap <- matrix(
    1, nrow = length(strata), ncol = length(strata),
    dimnames = list(strata, strata)
  )
  profile <- unlist(binding$Profile, use.names = TRUE)
  correlation <- mfrmr_gtds3b_correlation(
    binding_contract, profile, component_id, full_identity_overlap
  )
  scale <- diag(sqrt(component$MarginalVariances), nrow = length(strata))
  dimnames(scale) <- list(strata, strata)
  covariance <- scale %*% correlation %*% scale
  dimnames(covariance) <- list(strata, strata)
  audit <- mfrmr_gtds3b_matrix_audit(
    covariance, paste0("UnitCovariance/", component_id),
    contract$MatrixTolerance, binding_contract$BoundaryTolerance
  )
  factor <- signif(t(chol(covariance)), 14L)
  rownames(factor) <- strata
  colnames(factor) <- paste0("UnitFactor", seq_along(strata))
  reconstruction <- factor %*% t(factor)
  dimnames(reconstruction) <- list(strata, strata)
  reconstruction_error <- max(abs(reconstruction - covariance))
  implied_effective <- covariance * component$OverlapMatrix
  dimnames(implied_effective) <- list(strata, strata)
  implication_error <- max(abs(
    implied_effective - component$CovarianceMatrix
  ))
  if (reconstruction_error > contract$MatrixTolerance ||
      implication_error > contract$MatrixTolerance) {
    stop("The unit covariance does not reproduce its effective binding.",
         call. = FALSE)
  }
  list(
    ComponentId = component_id,
    IdentityColumn = binding$OverlapBindings[[component_id]]$IdentityColumn,
    IdentityOverlapMatrix = component$OverlapMatrix,
    UnitCorrelationMatrix = correlation,
    UnitCovarianceMatrix = covariance,
    UnitFactorMatrix = factor,
    UnitCovarianceAudit = audit,
    UnitFactorReconstructionMaximumError = reconstruction_error,
    ImpliedEffectiveCovarianceMatrix = implied_effective,
    EffectiveCovarianceImplicationMaximumError = implication_error,
    UnitCovarianceHash = mfrmr_gtds3g_hash(covariance),
    UnitFactorHash = mfrmr_gtds3g_hash(factor)
  )
}

mfrmr_gtds3g_identity_vector <- function(assignments, component_id) {
  if (identical(component_id, "Object")) return(assignments$ObjectId)
  if (identical(component_id, "Rater")) return(assignments$ConditionId)
  if (identical(component_id, "Object:Rater")) {
    return(paste(assignments$ObjectId, assignments$ConditionId, sep = "/"))
  }
  if (identical(component_id, "Residual")) return(assignments$EventId)
  stop("The response-generator component identity is unknown.",
       call. = FALSE)
}

mfrmr_gtds3g_draw_component <- function(
    assignments, component_id, unit_binding, stream_state,
    response_kernel) {
  identities_by_row <- mfrmr_gtds3g_identity_vector(
    assignments, component_id
  )
  identities <- sort(unique(identities_by_row), method = "radix")
  strata <- rownames(unit_binding$UnitCovarianceMatrix)
  mfrmr_gtds3g_activate_stream(stream_state)
  innovations <- matrix(
    stats::rnorm(length(identities) * length(strata)),
    nrow = length(identities), ncol = length(strata)
  )
  draws <- innovations %*% t(unit_binding$UnitFactorMatrix)
  distribution <- "gaussian_component_effect"
  scale_draw_count <- 0L
  if (identical(component_id, "Residual") &&
      identical(response_kernel$LatentInnovation, "student_t")) {
    degrees <- response_kernel$DegreesFreedom
    scales <- sqrt((degrees - 2) / stats::rchisq(length(identities), degrees))
    draws <- draws * scales
    distribution <- "standardized_multivariate_student_t_df5_innovation"
    scale_draw_count <- length(identities)
  } else if (identical(component_id, "Residual")) {
    distribution <- "gaussian_response_innovation"
  }
  rownames(draws) <- identities
  colnames(draws) <- strata
  pairs <- unique(data.frame(
    IdentityId = as.character(identities_by_row),
    Stratum = as.character(assignments$Stratum),
    stringsAsFactors = FALSE
  ))
  pairs <- pairs[order(pairs$IdentityId, pairs$Stratum, method = "radix"),
                 , drop = FALSE]
  pairs$Effect <- draws[cbind(
    match(pairs$IdentityId, identities), match(pairs$Stratum, strata)
  )]
  row.names(pairs) <- NULL
  row_key <- paste(identities_by_row, assignments$Stratum, sep = "\036")
  pair_key <- paste(pairs$IdentityId, pairs$Stratum, sep = "\036")
  effect <- pairs$Effect[match(row_key, pair_key)]
  if (anyNA(effect) || any(!is.finite(effect)) || anyDuplicated(pair_key)) {
    stop("A component effect was not generated exactly once per identity.",
         call. = FALSE)
  }
  list(
    ComponentId = component_id,
    IdentityColumn = unit_binding$IdentityColumn,
    DrawDistribution = distribution,
    IdentityDrawVectorCount = length(identities),
    UsedIdentityStratumCount = nrow(pairs),
    GaussianInnovationDrawCount = length(innovations),
    ScaleDrawCount = scale_draw_count,
    EffectRegistry = pairs,
    EffectByAssignment = effect,
    FullDrawMatrixHash = mfrmr_gtds3g_hash(draws),
    EffectRegistryHash = mfrmr_gtds3g_hash(pairs),
    StreamStateHash = mfrmr_gtds3g_hash(stream_state),
    OneDrawVectorPerIdentity = TRUE
  )
}

mfrmr_gtds3g_missingness <- function(
    assignments, profile, stream_state) {
  level <- profile[["missingness"]]
  original <- assignments$ResponseScheduled
  randomized <- level %in% c("mcar_10", "mcar_30")
  if (randomized) {
    rate <- if (identical(level, "mcar_10")) 0.10 else 0.30
    target <- as.integer(floor(nrow(assignments) * rate + 1e-12))
    mfrmr_gtds3g_activate_stream(stream_state)
    ranks <- stats::runif(nrow(assignments))
    omitted <- rep(FALSE, nrow(assignments))
    if (target > 0L) {
      omitted[order(
        ranks, assignments$AssignmentOrdinal, method = "radix"
      )[seq_len(target)]] <- TRUE
    }
    scheduled <- !omitted
    disposition <- ifelse(
      omitted, paste0("shadow_fixed_count_", level), "scheduled_observed"
    )
    rank_hash <- mfrmr_gtds3g_hash(ranks)
  } else {
    scheduled <- original
    omitted <- !scheduled
    disposition <- assignments$MissingnessDisposition
    target <- sum(omitted)
    rank_hash <- NA_character_
  }
  if (sum(omitted) != target) {
    stop("The shadow missingness mask changed its fixed denominator.",
         call. = FALSE)
  }
  list(
    MissingnessLevel = level,
    ResponseScheduled = scheduled,
    MissingnessDisposition = disposition,
    OmittedCount = sum(omitted),
    ScheduledCount = sum(scheduled),
    RandomizedFixedCountMcar = randomized,
    SupportRepairApplied = FALSE,
    OutcomeValuesInspected = FALSE,
    CompilerMaskChanged = !identical(scheduled, original),
    RandomRankHash = rank_hash,
    MaskHash = mfrmr_gtds3g_hash(scheduled),
    StreamStateHash = mfrmr_gtds3g_hash(stream_state)
  )
}

mfrmr_gtds3g_apply_kernel <- function(
    latent_response, total_variance, response_kernel) {
  standardized <- latent_response / sqrt(total_variance)
  distribution <- response_kernel$ResponseDistribution
  if (identical(distribution, "ordinal_aggregate")) {
    response <- response_kernel$ScoreValues[
      findInterval(standardized, response_kernel$Cutpoints) + 1L
    ]
    qualified <- all(response %in% response_kernel$ScoreValues) &&
      all(response == as.integer(response))
  } else {
    response <- latent_response
    qualified <- all(is.finite(response))
  }
  list(
    PotentialResponse = response,
    StandardizedLatentResponse = standardized,
    ResponseSupportQualified = qualified,
    PotentialResponseHash = mfrmr_gtds3g_hash(response)
  )
}

mfrmr_gtds3g_generation_fields <- function() {
  c(
    "ContractId", "ContractHash", "ParentBindingHash", "ScenarioId",
    "ScenarioOrdinal", "ShadowSeed", "Profile", "StreamRegistry",
    "UnitCovarianceBindings", "ComponentDraws", "MissingnessBinding",
    "GeneratedData", "Summary"
  )
}

mfrmr_gtds3g_generate_profile <- function(
    scenario_id, contract = mfrmr_gtds3g_contract(),
    binding_contract = mfrmr_gtds3b_contract(),
    compiler_contract = mfrmr_gtds3c_contract(),
    coverage = mfrmr_gtds3_manifest(), validate = TRUE) {
  if (isTRUE(validate)) {
    binding_manifest <- mfrmr_gtds3b_manifest()
    mfrmr_gtds3g_validate_contract(contract, binding_manifest)
    mfrmr_gtds3_assert_manifest(coverage)
  }
  scenario_row <- coverage$ScenarioRegistry[
    coverage$ScenarioRegistry$ScenarioId == scenario_id, , drop = FALSE
  ]
  if (nrow(scenario_row) != 1L) {
    stop("The response-generator scenario is not frozen.", call. = FALSE)
  }
  scenario_ordinal <- scenario_row$ScenarioOrdinal[[1L]]
  shadow_seed <- as.integer(contract$ShadowSeedBase + scenario_ordinal)
  if (shadow_seed >= contract$ReservedExploratoryLowerInclusive) {
    stop("The response-generator attempted to enter the reserved 855 band.",
         call. = FALSE)
  }
  binding <- mfrmr_gtds3b_bind_profile(
    scenario_id, binding_contract, compiler_contract, coverage,
    validate = FALSE
  )
  mfrmr_gtds3b_assert_binding(
    binding, binding_contract, compiler_contract, coverage,
    validate = FALSE, replay = FALSE
  )
  compilation <- mfrmr_gtds3c_compile_profile(
    scenario_id, compiler_contract, coverage, validate = FALSE
  )
  assignments <- compilation$AssignmentRegistry
  profile <- unlist(binding$Profile, use.names = TRUE)
  components <- binding_contract$ComponentRegistry$ComponentId
  unit_bindings <- stats::setNames(lapply(components, function(component) {
    mfrmr_gtds3g_unit_covariance(
      binding, component, binding_contract, contract
    )
  }), components)
  stochastic <- mfrmr_gtds3g_with_seed(shadow_seed, contract, function() {
    streams <- mfrmr_gtds3g_streams(contract)
    draws <- stats::setNames(lapply(components, function(component) {
      mfrmr_gtds3g_draw_component(
        assignments, component, unit_bindings[[component]],
        streams$States[[component]], binding$ResponseKernel
      )
    }), components)
    missingness <- mfrmr_gtds3g_missingness(
      assignments, profile, streams$States$Missingness
    )
    list(Streams = streams, Draws = draws, Missingness = missingness)
  })
  effect_matrix <- vapply(stochastic$Draws, function(draw) {
    draw$EffectByAssignment
  }, numeric(nrow(assignments)))
  colnames(effect_matrix) <- paste0(
    gsub(":", "By", components, fixed = TRUE), "Effect"
  )
  latent <- rowSums(effect_matrix)
  total_variance_by_stratum <- stats::setNames(vapply(
    compilation$StratumRegistry$Stratum, function(stratum) {
      sum(vapply(unit_bindings, function(unit) {
        unit$UnitCovarianceMatrix[stratum, stratum]
      }, numeric(1L)))
    }, numeric(1L)), compilation$StratumRegistry$Stratum
  )
  total_variance <- total_variance_by_stratum[assignments$Stratum]
  kernel_output <- mfrmr_gtds3g_apply_kernel(
    latent, total_variance, binding$ResponseKernel
  )
  scheduled <- stochastic$Missingness$ResponseScheduled
  generated <- assignments
  generated$ResponseScheduled <- scheduled
  generated$MissingnessDisposition <-
    stochastic$Missingness$MissingnessDisposition
  generated$ResponseGenerated <- scheduled
  generated <- cbind(generated, as.data.frame(effect_matrix))
  generated$LatentPotentialResponse <- latent
  generated$StandardizedLatentPotentialResponse <-
    kernel_output$StandardizedLatentResponse
  generated$Score <- ifelse(
    scheduled, kernel_output$PotentialResponse, NA_real_
  )
  response_count <- sum(generated$ResponseGenerated)
  unit_qualified <- all(vapply(unit_bindings, function(unit) {
    isTRUE(unit$UnitCovarianceAudit$PositiveSemidefinite) &&
      unit$UnitFactorReconstructionMaximumError <= contract$MatrixTolerance &&
      unit$EffectiveCovarianceImplicationMaximumError <=
        contract$MatrixTolerance
  }, logical(1L)))
  draw_qualified <- all(vapply(stochastic$Draws, function(draw) {
    isTRUE(draw$OneDrawVectorPerIdentity) &&
      all(is.finite(draw$EffectByAssignment))
  }, logical(1L)))
  generator_qualified <- unit_qualified && draw_qualified &&
    isTRUE(kernel_output$ResponseSupportQualified) &&
    response_count == stochastic$Missingness$ScheduledCount &&
    all(is.na(generated$Score[!scheduled])) &&
    all(is.finite(generated$Score[scheduled]))
  summary <- list(
    ScenarioId = scenario_id,
    ScenarioOrdinal = scenario_ordinal,
    ParentBindingHash = binding$BindingHash,
    ShadowSeed = shadow_seed,
    PlannedRowCount = nrow(generated),
    GeneratedResponseCount = response_count,
    OmittedResponseCount = sum(!scheduled),
    VarianceRegime = profile[["variance_regime"]],
    CrossStratumCovariance = profile[["cross_stratum_covariance"]],
    ResponseDistribution = profile[["response_distribution"]],
    MissingnessLevel = profile[["missingness"]],
    RandomizedFixedCountMcar =
      stochastic$Missingness$RandomizedFixedCountMcar,
    UnitCovarianceQualifiedCount = sum(vapply(
      unit_bindings, function(unit) {
        isTRUE(unit$UnitCovarianceAudit$PositiveSemidefinite) &&
          unit$EffectiveCovarianceImplicationMaximumError <=
            contract$MatrixTolerance
      }, logical(1L)
    )),
    ComponentDrawQualifiedCount = sum(vapply(
      stochastic$Draws, function(draw) draw$OneDrawVectorPerIdentity,
      logical(1L)
    )),
    ResponseSupportQualified = kernel_output$ResponseSupportQualified,
    FullGeneratorAdapterQualified = generator_qualified,
    GeneratorSemanticsQualified = generator_qualified,
    ShadowRngStreamOpened = TRUE,
    Planned855RngStreamOpened = FALSE,
    ShadowResponseGenerated = TRUE,
    ExploratoryResponseGenerated = FALSE,
    BackendCallMade = FALSE,
    FitExecuted = FALSE,
    StreamRegistryHash = mfrmr_gtds3g_hash(stochastic$Streams$Registry),
    UnitCovarianceRegistryHash = mfrmr_gtds3g_hash(unit_bindings),
    ComponentDrawRegistryHash = mfrmr_gtds3g_hash(stochastic$Draws),
    MissingnessMaskHash = stochastic$Missingness$MaskHash,
    GeneratedDataHash = mfrmr_gtds3g_hash(generated)
  )
  payload <- list(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    ParentBindingHash = binding$BindingHash,
    ScenarioId = scenario_id,
    ScenarioOrdinal = scenario_ordinal,
    ShadowSeed = shadow_seed,
    Profile = binding$Profile,
    StreamRegistry = stochastic$Streams$Registry,
    UnitCovarianceBindings = unit_bindings,
    ComponentDraws = stochastic$Draws,
    MissingnessBinding = stochastic$Missingness,
    GeneratedData = generated,
    Summary = summary
  )
  structure(c(payload, list(
    GenerationHash = mfrmr_gtds3g_hash(payload)
  )), class = c("mfrmr_gtds3g_generation", "list"))
}

mfrmr_gtds3g_assert_generation <- function(
    generation, contract = mfrmr_gtds3g_contract(),
    binding_contract = mfrmr_gtds3b_contract(),
    compiler_contract = mfrmr_gtds3c_contract(),
    coverage = mfrmr_gtds3_manifest(), validate = TRUE, replay = TRUE) {
  fields <- mfrmr_gtds3g_generation_fields()
  if (!inherits(generation, "mfrmr_gtds3g_generation") ||
      !identical(names(generation), c(fields, "GenerationHash"))) {
    stop("A typed D-SIM-3 shadow generation is required.", call. = FALSE)
  }
  if (isTRUE(validate)) {
    mfrmr_gtds3g_validate_contract(contract)
    mfrmr_gtds3_assert_manifest(coverage)
  }
  canonical_match <- !isTRUE(replay) || identical(
    generation,
    mfrmr_gtds3g_generate_profile(
      generation$ScenarioId, contract, binding_contract,
      compiler_contract, coverage, validate = FALSE
    )
  )
  summary <- generation$Summary
  data <- generation$GeneratedData
  valid <- canonical_match &&
    identical(generation$ContractId, contract$ContractId) &&
    identical(generation$ContractHash, contract$ContractHash) &&
    identical(
      generation$GenerationHash, mfrmr_gtds3g_hash(generation[fields])
    ) && generation$ShadowSeed >= contract$MinimumShadowSeed &&
    generation$ShadowSeed <= contract$MaximumShadowSeed &&
    generation$ShadowSeed < contract$ReservedExploratoryLowerInclusive &&
    identical(nrow(generation$StreamRegistry), 5L) &&
    all(!generation$StreamRegistry$Reserved855Identity) &&
    identical(length(generation$UnitCovarianceBindings), 4L) &&
    identical(length(generation$ComponentDraws), 4L) &&
    identical(nrow(data), summary$PlannedRowCount) &&
    identical(sum(data$ResponseGenerated), summary$GeneratedResponseCount) &&
    all(is.na(data$Score[!data$ResponseGenerated])) &&
    all(is.finite(data$Score[data$ResponseGenerated])) &&
    identical(summary$UnitCovarianceQualifiedCount, 4L) &&
    identical(summary$ComponentDrawQualifiedCount, 4L) &&
    isTRUE(summary$ResponseSupportQualified) &&
    isTRUE(summary$FullGeneratorAdapterQualified) &&
    isTRUE(summary$GeneratorSemanticsQualified) &&
    isTRUE(summary$ShadowRngStreamOpened) &&
    !isTRUE(summary$Planned855RngStreamOpened) &&
    isTRUE(summary$ShadowResponseGenerated) &&
    !isTRUE(summary$ExploratoryResponseGenerated) &&
    !isTRUE(summary$BackendCallMade) && !isTRUE(summary$FitExecuted)
  if (!valid) {
    stop("The D-SIM-3 shadow generation was altered.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3g_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds3g_require_primitives", "mfrmr_gtds3g_hash",
    "mfrmr_gtds3g_identity", "mfrmr_gtds3g_contract",
    "mfrmr_gtds3g_validate_contract", "mfrmr_gtds3g_with_seed",
    "mfrmr_gtds3g_streams", "mfrmr_gtds3g_activate_stream",
    "mfrmr_gtds3g_unit_covariance", "mfrmr_gtds3g_identity_vector",
    "mfrmr_gtds3g_draw_component", "mfrmr_gtds3g_missingness",
    "mfrmr_gtds3g_apply_kernel", "mfrmr_gtds3g_generation_fields",
    "mfrmr_gtds3g_generate_profile", "mfrmr_gtds3g_assert_generation",
    "mfrmr_gtds3g_implementation_identity", "mfrmr_gtds3g_manifest_fields",
    "mfrmr_gtds3g_manifest", "mfrmr_gtds3g_assert_manifest"
  )
  target <- environment(mfrmr_gtds3g_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds3g_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)), stringsAsFactors = FALSE
  )
}

mfrmr_gtds3g_manifest_fields <- function() {
  c(
    "Contract", "ParentBindingManifestHash", "ProfileGenerationRegistry",
    "UnitCovarianceAuditRegistry", "ImplementationIdentity", "Summary"
  )
}

mfrmr_gtds3g_manifest <- function(
    contract = mfrmr_gtds3g_contract(),
    binding_contract = mfrmr_gtds3b_contract(),
    compiler_contract = mfrmr_gtds3c_contract(),
    coverage = mfrmr_gtds3_manifest(), binding_manifest = NULL) {
  if (is.null(binding_manifest)) binding_manifest <- mfrmr_gtds3b_manifest()
  mfrmr_gtds3g_validate_contract(contract, binding_manifest)
  mfrmr_gtds3_assert_manifest(coverage)
  profile_rows <- list(); unit_rows <- list(); unit_cursor <- 0L
  for (index in seq_len(nrow(coverage$ScenarioRegistry))) {
    scenario_id <- coverage$ScenarioRegistry$ScenarioId[[index]]
    generation <- mfrmr_gtds3g_generate_profile(
      scenario_id, contract, binding_contract, compiler_contract,
      coverage, validate = FALSE
    )
    mfrmr_gtds3g_assert_generation(
      generation, contract, binding_contract, compiler_contract,
      coverage, validate = FALSE, replay = FALSE
    )
    summary <- generation$Summary
    profile_rows[[index]] <- data.frame(
      GenerationOrdinal = index, ScenarioId = scenario_id,
      ScenarioOrdinal = summary$ScenarioOrdinal,
      ParentBindingHash = summary$ParentBindingHash,
      ShadowSeed = summary$ShadowSeed,
      PlannedRowCount = summary$PlannedRowCount,
      GeneratedResponseCount = summary$GeneratedResponseCount,
      OmittedResponseCount = summary$OmittedResponseCount,
      VarianceRegime = summary$VarianceRegime,
      CrossStratumCovariance = summary$CrossStratumCovariance,
      ResponseDistribution = summary$ResponseDistribution,
      MissingnessLevel = summary$MissingnessLevel,
      RandomizedFixedCountMcar = summary$RandomizedFixedCountMcar,
      UnitCovarianceQualifiedCount = summary$UnitCovarianceQualifiedCount,
      ComponentDrawQualifiedCount = summary$ComponentDrawQualifiedCount,
      ResponseSupportQualified = summary$ResponseSupportQualified,
      FullGeneratorAdapterQualified = summary$FullGeneratorAdapterQualified,
      GeneratorSemanticsQualified = summary$GeneratorSemanticsQualified,
      ShadowRngStreamOpened = TRUE, Planned855RngStreamOpened = FALSE,
      ShadowResponseGenerated = TRUE,
      ExploratoryResponseGenerated = FALSE,
      BackendCallMade = FALSE, FitExecuted = FALSE,
      MissingnessMaskHash = summary$MissingnessMaskHash,
      GeneratedDataHash = summary$GeneratedDataHash,
      GenerationHash = generation$GenerationHash,
      stringsAsFactors = FALSE
    )
    for (component_id in names(generation$UnitCovarianceBindings)) {
      unit_cursor <- unit_cursor + 1L
      unit <- generation$UnitCovarianceBindings[[component_id]]
      unit_rows[[unit_cursor]] <- data.frame(
        UnitAuditOrdinal = unit_cursor, ScenarioId = scenario_id,
        ComponentId = component_id,
        IdentityColumn = unit$IdentityColumn,
        MinimumEigenvalue = unit$UnitCovarianceAudit$MinimumEigenvalue,
        PositiveSemidefinite =
          unit$UnitCovarianceAudit$PositiveSemidefinite,
        UnitFactorReconstructionMaximumError =
          unit$UnitFactorReconstructionMaximumError,
        EffectiveCovarianceImplicationMaximumError =
          unit$EffectiveCovarianceImplicationMaximumError,
        UnitCovarianceHash = unit$UnitCovarianceHash,
        UnitFactorHash = unit$UnitFactorHash,
        stringsAsFactors = FALSE
      )
    }
  }
  profiles <- do.call(rbind, profile_rows)
  units <- do.call(rbind, unit_rows)
  row.names(profiles) <- row.names(units) <- NULL
  implementation <- mfrmr_gtds3g_implementation_identity()
  summary <- list(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    ParentBindingManifestHash = contract$ParentBindingManifestHash,
    ProfileGenerationCount = nrow(profiles),
    QualifiedProfileGenerationCount =
      sum(profiles$GeneratorSemanticsQualified),
    UnitCovarianceAuditCount = nrow(units),
    QualifiedUnitCovarianceAuditCount = sum(
      units$PositiveSemidefinite &
        units$UnitFactorReconstructionMaximumError <=
          contract$MatrixTolerance &
        units$EffectiveCovarianceImplicationMaximumError <=
          contract$MatrixTolerance
    ),
    RandomizedFixedCountMcarProfileCount =
      sum(profiles$RandomizedFixedCountMcar),
    PlannedStructuralRowCount = sum(profiles$PlannedRowCount),
    ShadowGeneratedResponseCount = sum(profiles$GeneratedResponseCount),
    ShadowOmittedResponseCount = sum(profiles$OmittedResponseCount),
    ScenarioSpecificPatchCount = contract$ScenarioSpecificPatchCount,
    FullGeneratorAdapterQualified = all(
      profiles$FullGeneratorAdapterQualified
    ),
    GeneratorSemanticsQualifiedProfileCount = sum(
      profiles$GeneratorSemanticsQualified
    ),
    ShadowGeneratedFixtureCount = nrow(profiles),
    ExploratoryGeneratedDatasetCount = 0L,
    ShadowRngStreamOpened = TRUE,
    Planned855RngStreamOpened = FALSE,
    ShadowResponseGenerated = TRUE,
    ExploratoryResponseGenerated = FALSE,
    RouteAdapterQualified = FALSE,
    TerminalReceiptAdapterQualified = FALSE,
    ResourceControllerQualified = FALSE,
    BackendCallMade = FALSE, FitExecuted = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE,
    FeatureMaturity = "specified",
    NextAction = paste(
      "qualify generic shared-dataset route and terminal-receipt adapters",
      "plus the five-scope resource controller without opening reserved",
      "855 exploratory streams"
    )
  )
  payload <- list(
    Contract = contract,
    ParentBindingManifestHash = contract$ParentBindingManifestHash,
    ProfileGenerationRegistry = profiles,
    UnitCovarianceAuditRegistry = units,
    ImplementationIdentity = implementation,
    Summary = summary
  )
  structure(c(payload, list(
    ManifestHash = mfrmr_gtds3g_hash(payload)
  )), class = c("mfrmr_gtds3g_manifest", "list"))
}

mfrmr_gtds3g_assert_manifest <- function(manifest) {
  fields <- mfrmr_gtds3g_manifest_fields()
  if (!inherits(manifest, "mfrmr_gtds3g_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-3 response-generator manifest is required.",
         call. = FALSE)
  }
  mfrmr_gtds3g_validate_contract(manifest$Contract)
  profiles <- manifest$ProfileGenerationRegistry
  units <- manifest$UnitCovarianceAuditRegistry
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds3g_hash(manifest[fields])
  ) && identical(
    manifest$ImplementationIdentity, mfrmr_gtds3g_implementation_identity()
  ) && identical(nrow(profiles), 21L) &&
    identical(profiles$ScenarioId, sprintf("D3-S%03d", 1:21)) &&
    identical(profiles$ShadowSeed, 854100000L + 1:21) &&
    all(profiles$ShadowSeed < 855000000L) &&
    !anyDuplicated(profiles$ShadowSeed) && identical(nrow(units), 84L) &&
    all(units$PositiveSemidefinite) &&
    all(units$UnitFactorReconstructionMaximumError <=
          manifest$Contract$MatrixTolerance) &&
    all(units$EffectiveCovarianceImplicationMaximumError <=
          manifest$Contract$MatrixTolerance) &&
    all(profiles$ResponseSupportQualified) &&
    all(profiles$FullGeneratorAdapterQualified) &&
    all(profiles$GeneratorSemanticsQualified) &&
    all(profiles$ShadowRngStreamOpened) &&
    all(!profiles$Planned855RngStreamOpened) &&
    all(profiles$ShadowResponseGenerated) &&
    all(!profiles$ExploratoryResponseGenerated) &&
    all(!profiles$BackendCallMade) && all(!profiles$FitExecuted) &&
    identical(manifest$Summary$ProfileGenerationCount, 21L) &&
    identical(manifest$Summary$QualifiedProfileGenerationCount, 21L) &&
    identical(manifest$Summary$UnitCovarianceAuditCount, 84L) &&
    identical(manifest$Summary$QualifiedUnitCovarianceAuditCount, 84L) &&
    identical(manifest$Summary$RandomizedFixedCountMcarProfileCount, 9L) &&
    identical(manifest$Summary$PlannedStructuralRowCount, 147948L) &&
    identical(manifest$Summary$ShadowGeneratedResponseCount, 130694L) &&
    identical(manifest$Summary$ShadowOmittedResponseCount, 17254L) &&
    identical(manifest$Summary$ScenarioSpecificPatchCount, 0L) &&
    isTRUE(manifest$Summary$FullGeneratorAdapterQualified) &&
    identical(
      manifest$Summary$GeneratorSemanticsQualifiedProfileCount, 21L
    ) && identical(manifest$Summary$ShadowGeneratedFixtureCount, 21L) &&
    identical(manifest$Summary$ExploratoryGeneratedDatasetCount, 0L) &&
    isTRUE(manifest$Summary$ShadowRngStreamOpened) &&
    !isTRUE(manifest$Summary$Planned855RngStreamOpened) &&
    isTRUE(manifest$Summary$ShadowResponseGenerated) &&
    !isTRUE(manifest$Summary$ExploratoryResponseGenerated) &&
    !isTRUE(manifest$Summary$RouteAdapterQualified) &&
    !isTRUE(manifest$Summary$TerminalReceiptAdapterQualified) &&
    !isTRUE(manifest$Summary$ResourceControllerQualified) &&
    !isTRUE(manifest$Summary$BackendCallMade) &&
    !isTRUE(manifest$Summary$FitExecuted) &&
    !isTRUE(manifest$Summary$ExploratoryExecutionAllowed) &&
    !isTRUE(manifest$Summary$SimulationValidationReady) &&
    !isTRUE(manifest$Summary$PublicSupportReady) &&
    identical(manifest$Summary$FeatureMaturity, "specified")
  if (!valid) {
    stop("The D-SIM-3 response-generator manifest was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}
