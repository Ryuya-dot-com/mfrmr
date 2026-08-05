# Repository-only joint-cone attribution pilot for mfrmr 0.2.3.
#
# This calibration instrument re-fits three fixed positive-cone PCM/JML data
# cells from the Draft.52 phase profile.  It projects the certified global
# cone onto every expanded target, distinguishes ordinary free extreme Person
# directions from selected joint targets, and evaluates a diagnostic quotient
# cone after profiling those already typed Person boundaries out.  The
# quotient result is evidence for a later implementation slice; this runner
# does not alter a fit, readiness, or release decision.

mfrmr_jml_joint_attribution_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "jml-joint-cone-attribution-pilot-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) > 0L) {
    return(dirname(normalizePath(
      hit[length(hit)], winslash = "/", mustWork = FALSE
    )))
  }
  candidates <- c(
    file.path(
      "inst", "validation",
      "jml-joint-cone-attribution-pilot-0.2.3.R"
    ),
    "jml-joint-cone-attribution-pilot-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else {
    dirname(normalizePath(path, winslash = "/", mustWork = TRUE))
  }
})

mfrmr_jml_joint_attribution_require_support <- function() {
  target_env <- environment(mfrmr_jml_joint_attribution_require_support)
  required <- c(
    "mfrmr_jml_phase_registry", "mfrmr_jml_profile_build",
    "mfrmr_jml_phase_semantic_hash", "mfrmr_jml_profile_take",
    "mfrmr_gpcm_stress_capture", "mfrmr_gpcm_stress_fun",
    "mfrmr_gpcm_repilot_hash_object", "mfrmr_gpcm_repilot_hash_file",
    "mfrmr_gpcm_repilot_runtime_package_identity",
    "mfrmr_target_bridge_readiness",
    "mfrmr_target_scale_artifact_inventory"
  )
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    candidates <- c(
      if (!is.na(mfrmr_jml_joint_attribution_source_dir)) {
        file.path(
          mfrmr_jml_joint_attribution_source_dir,
          "jml-phase-profile-pilot-0.2.3.R"
        )
      } else character(0),
      file.path(
        "inst", "validation", "jml-phase-profile-pilot-0.2.3.R"
      ),
      "jml-phase-profile-pilot-0.2.3.R"
    )
    path <- candidates[file.exists(candidates)][1L]
    if (is.na(path)) {
      stop("Cannot locate the Draft.52 phase-profile support.", call. = FALSE)
    }
    sys.source(path, envir = target_env)
    mfrmr_jml_phase_require_support()
  }
  if (!all(vapply(required, exists, logical(1), envir = target_env,
                  mode = "function", inherits = TRUE))) {
    stop("Joint-cone attribution support did not load completely.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_jml_joint_attribution_registry <- function() {
  mfrmr_jml_joint_attribution_require_support()
  registry <- mfrmr_jml_phase_registry()
  selected <- c(
    "JBP-R12-JML-auto",
    "JBP-C12-E02-JML-auto",
    "JBP-P200-X20-JML-auto"
  )
  index <- match(selected, registry$ScenarioId)
  if (anyNA(index)) {
    stop("The joint-cone attribution registry does not match Draft.52.",
         call. = FALSE)
  }
  out <- registry[index, , drop = FALSE]
  out$EvidenceUse <- "joint_cone_attribution_calibration_only"
  out$ConfirmationAuthorized <- FALSE
  canonical <- out[, setdiff(
    names(out), c("ScenarioId", "JointAttributionManifestSHA256")
  ), drop = FALSE]
  out$JointAttributionManifestSHA256 <-
    mfrmr_gpcm_repilot_hash_object(canonical)
  row.names(out) <- NULL
  out
}

mfrmr_jml_joint_attribution_identity <- function(registry, maxit, reltol) {
  package <- mfrmr_gpcm_repilot_runtime_package_identity()
  files <- data.frame(
    Component = c("joint_attribution", "phase_profile", "draft49_profile"),
    File = c(
      "jml-joint-cone-attribution-pilot-0.2.3.R",
      "jml-phase-profile-pilot-0.2.3.R",
      "jml-bottleneck-decomposition-pilot-0.2.3.R"
    ),
    stringsAsFactors = FALSE
  )
  paths <- file.path(mfrmr_jml_joint_attribution_source_dir, files$File)
  if (any(!file.exists(paths))) {
    stop("One or more joint-attribution identity files are missing.",
         call. = FALSE)
  }
  files$SHA256 <- vapply(
    paths, mfrmr_gpcm_repilot_hash_file, character(1)
  )
  attr(files, "CompositeSHA256") <-
    mfrmr_gpcm_repilot_hash_object(files)
  execution <- data.frame(
    Schema = "mfrmr-jml-joint-cone-attribution-v1",
    DataCells = nrow(registry),
    Maxit = as.integer(maxit),
    Reltol = as.numeric(reltol),
    ConeObjectiveTolerance = 1e-10,
    ConeCertificateTolerance = 1e-7,
    ProjectionTolerance = 1e-8,
    ManifestSHA256 = unique(registry$JointAttributionManifestSHA256),
    PackageSHA256 = package$PackageSHA256,
    RunnerSHA256 = attr(files, "CompositeSHA256"),
    EvidenceUse = "joint_cone_attribution_calibration_only",
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  execution$ExecutionSHA256 <- mfrmr_gpcm_repilot_hash_object(execution)
  list(execution = execution, package = package, runners = files)
}

mfrmr_jml_joint_attribution_fit <- function(row, maxit, reltol) {
  generated <- mfrmr_jml_profile_build(row)
  old_options <- options(mfrmr.phase_timing = TRUE)
  on.exit(options(old_options), add = TRUE)
  capture <- mfrmr_gpcm_stress_capture(do.call(
    mfrmr_gpcm_stress_fun("fit_mfrm"),
    list(
      data = generated$data,
      person = "Person",
      facets = c("Rater", "Criterion"),
      score = "Score",
      model = "PCM",
      method = "JML",
      rating_min = 1L,
      rating_max = 5L,
      step_facet = "Criterion",
      maxit = as.integer(maxit),
      reltol = as.numeric(reltol),
      optimizer = "auto"
    )
  ))
  if (inherits(capture$value, "error")) {
    stop(
      "Joint-attribution fit failed for ", row$ScenarioId, ": ",
      conditionMessage(capture$value), call. = FALSE
    )
  }
  fit <- capture$value
  config <- fit$config
  sizes <- getFromNamespace("build_param_sizes", "mfrmr")(config)
  idx <- getFromNamespace("build_indices", "mfrmr")(
    fit$prep,
    step_facet = config$step_facet,
    slope_facet = config$slope_facet,
    interaction_specs = config$interaction_specs
  )
  params <- getFromNamespace("expand_params", "mfrmr")(
    fit$opt$par, sizes, config
  )
  adjacent <- getFromNamespace(
    "mfrmr_estimability_adjacent_design", "mfrmr"
  )(
    fit$prep, idx, config, sizes,
    include_person = TRUE,
    include_population_beta = FALSE
  )
  target_system <- getFromNamespace(
    "mfrmr_jml_structural_target_system", "mfrmr"
  )(config, sizes, params, include_person = TRUE)
  contrast <- getFromNamespace(
    "mfrmr_jml_observed_contrast_design", "mfrmr"
  )(
    adjacent$design,
    score_k = idx$score_k,
    n_obs = adjacent$observation_rows,
    n_steps = adjacent$transitions
  )

  boundary <- config$boundary_audit
  joint <- boundary$joint_additive
  person_status <- as.data.frame(
    boundary$parameter_status, stringsAsFactors = FALSE
  )
  ordinary_extreme <- as.character(person_status$ParameterId[
    person_status$ParameterStatus %in% c("unbounded_low", "unbounded_high")
  ])
  cone_loadings <- as.data.frame(
    joint$cone_direction_loadings, stringsAsFactors = FALSE
  )
  direction <- numeric(nrow(adjacent$map))
  if (nrow(cone_loadings) > 0L) {
    loading_index <- match(
      cone_loadings$OptimizerIndex, adjacent$map$OptimizerIndex
    )
    if (anyNA(loading_index)) {
      stop("Cone loadings did not align with optimizer coordinates.",
           call. = FALSE)
    }
    direction[loading_index] <- cone_loadings$Loading
  }

  full_change <- as.numeric(
    target_system$expansion[
      , adjacent$map$OptimizerIndex, drop = FALSE
    ] %*% direction
  )
  selected_ids <- as.character(joint$target_status$ParameterId)
  selected_index <- match(
    selected_ids, target_system$metadata$ParameterId
  )
  if (anyNA(selected_index)) {
    stop("Selected targets did not align with the full target system.",
         call. = FALSE)
  }

  target_projection <- cbind(
    data.frame(
      ScenarioId = row$ScenarioId,
      DataCellId = row$DataCellId,
      stringsAsFactors = FALSE
    ),
    target_system$metadata
  )
  target_projection$ConeTargetChange <- full_change
  target_projection$SelectedJointTarget <-
    target_projection$ParameterId %in% selected_ids
  target_projection$NonzeroAt1e8 <- abs(full_change) > 1e-8
  target_projection$PersonBoundaryStatus <- NA_character_
  person_match <- match(
    target_projection$ParameterId, person_status$ParameterId
  )
  target_projection$PersonBoundaryStatus[!is.na(person_match)] <-
    person_status$ParameterStatus[person_match[!is.na(person_match)]]

  cone_loading_detail <- cone_loadings
  if (nrow(cone_loading_detail) > 0L) {
    map_index <- match(
      cone_loading_detail$OptimizerIndex, adjacent$map$OptimizerIndex
    )
    cone_loading_detail$Block <- adjacent$map$Block[map_index]
    cone_loading_detail$OrdinaryFreeExtremePerson <-
      cone_loading_detail$Coordinate %in% ordinary_extreme
  }
  cone_loading_detail$ScenarioId <- row$ScenarioId
  cone_loading_detail$DataCellId <- row$DataCellId

  person_ids <- paste0("Person:", fit$prep$levels$Person[idx$person])
  retained_observation <- !person_ids %in% ordinary_extreme
  retained_contrast <- rep(retained_observation, each = adjacent$transitions)
  retained_coordinate <- !adjacent$map$Coordinate %in% ordinary_extreme
  quotient_contrast <- contrast[
    retained_contrast, retained_coordinate, drop = FALSE
  ]
  quotient_started <- proc.time()
  quotient_base <- getFromNamespace(
    "mfrmr_jml_recession_lp_base", "mfrmr"
  )(quotient_contrast, representation = "sparse_triplet")
  quotient_cone <- getFromNamespace(
    "mfrmr_jml_recession_target_lp", "mfrmr"
  )(
    quotient_base,
    target = as.numeric(Matrix::colSums(quotient_contrast)),
    objective_tolerance = 1e-10,
    certificate_tolerance = 1e-7,
    timeout = 2L
  )
  quotient_seconds <- unname(as.numeric(
    (proc.time() - quotient_started)[["elapsed"]]
  ))

  selected_change <- full_change[selected_index]
  full_nonzero_ids <- as.character(target_projection$ParameterId[
    target_projection$NonzeroAt1e8
  ])
  phase <- as.data.frame(
    config$phase_timing %||% data.frame(), stringsAsFactors = FALSE
  )
  joint_seconds <- if (
    nrow(phase) > 0L && all(c("Phase", "ElapsedSeconds") %in% names(phase))
  ) {
    sum(phase$ElapsedSeconds[phase$Phase == "joint_recession_audit"])
  } else {
    NA_real_
  }
  target_certificates <- as.data.frame(
    joint$certificates %||% data.frame(), stringsAsFactors = FALSE
  )
  person_only_known <- nrow(cone_loading_detail) > 0L &&
    all(cone_loading_detail$OrdinaryFreeExtremePerson)
  projection_contract <-
    isTRUE(joint$cone_certificate$Certified) &&
    person_only_known &&
    setequal(full_nonzero_ids, ordinary_extreme) &&
    all(abs(selected_change) <= 1e-8) &&
    !any(target_certificates$Certified %||% FALSE) &&
    isTRUE(quotient_cone$evaluated) &&
    !isTRUE(quotient_cone$certified)
  readiness <- mfrmr_target_bridge_readiness(fit)

  result <- data.frame(
    ScenarioId = row$ScenarioId,
    DataCellId = row$DataCellId,
    Rows = nrow(generated$data),
    Persons = length(unique(generated$data$Person)),
    SemanticResultSHA256 = mfrmr_jml_phase_semantic_hash(fit),
    FitReadiness = readiness$FitReadiness,
    InferenceReady = readiness$InferenceReady,
    JointState = joint$state,
    JointComplete = isTRUE(joint$complete),
    JointSeconds = joint_seconds,
    JointConeCertified = isTRUE(joint$cone_certificate$Certified),
    JointConeStrictRows = joint$cone_certificate$StrictContrastRows,
    JointTargetDirections = joint$dimensions$TargetDirections,
    JointTargetLPCalls = joint$prescreen$target_lp_calls,
    JointCertifiedTargetDirections = sum(
      target_certificates$Certified %||% FALSE
    ),
    OrdinaryFreeExtremePersons = length(ordinary_extreme),
    ConePersonCoordinates = sum(
      adjacent$map$Block[direction != 0] == "Person"
    ),
    ConeStructuralCoordinates = sum(
      adjacent$map$Block[direction != 0] != "Person"
    ),
    SelectedTargets = length(selected_change),
    SelectedNonzeroTargets = sum(abs(selected_change) > 1e-8),
    MaximumAbsoluteSelectedChange = max(abs(selected_change)),
    FullNonzeroTargets = length(full_nonzero_ids),
    QuotientObservations = sum(retained_observation),
    QuotientCoordinates = sum(retained_coordinate),
    QuotientConeEvaluated = isTRUE(quotient_cone$evaluated),
    QuotientConeCertified = isTRUE(quotient_cone$certified),
    QuotientConeCapacity = quotient_cone$target_capacity,
    QuotientConeStrictRows = quotient_cone$strict_rows,
    QuotientConeLPCalls = quotient_cone$lp_calls,
    QuotientSeconds = quotient_seconds,
    AttributionContractValid = isTRUE(projection_contract),
    Warnings = paste(capture$warnings, collapse = " | "),
    EvidenceUse = "joint_cone_attribution_calibration_only",
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  person_status$ScenarioId <- row$ScenarioId
  person_status$DataCellId <- row$DataCellId
  list(
    result = result,
    cone_loadings = cone_loading_detail,
    target_projection = target_projection,
    person_status = person_status
  )
}

mfrmr_jml_joint_attribution_run <- function(
    output_dir, maxit = 60L, reltol = 1e-9) {
  mfrmr_jml_joint_attribution_require_support()
  registry <- mfrmr_jml_joint_attribution_registry()
  identity <- mfrmr_jml_joint_attribution_identity(
    registry, maxit = maxit, reltol = reltol
  )
  output_parent <- normalizePath(
    dirname(output_dir), winslash = "/", mustWork = TRUE
  )
  output_dir <- file.path(output_parent, basename(output_dir))
  staging <- paste0(output_dir, ".incomplete")
  if (file.exists(output_dir) || file.exists(staging)) {
    stop("Joint-attribution output or staging directory already exists.",
         call. = FALSE)
  }
  if (!dir.create(staging, recursive = FALSE)) {
    stop("Joint-attribution staging directory could not be created.",
         call. = FALSE)
  }
  promoted <- FALSE
  on.exit({
    if (!promoted) message("Incomplete evidence retained at: ", staging)
  }, add = TRUE)

  fitted <- lapply(seq_len(nrow(registry)), function(i) {
    mfrmr_jml_joint_attribution_fit(
      registry[i, , drop = FALSE], maxit = maxit, reltol = reltol
    )
  })
  results <- do.call(rbind, lapply(fitted, `[[`, "result"))
  cone_loadings <- do.call(rbind, lapply(fitted, `[[`, "cone_loadings"))
  target_projection <- do.call(rbind, lapply(
    fitted, `[[`, "target_projection"
  ))
  person_status <- do.call(rbind, lapply(fitted, `[[`, "person_status"))
  if (nrow(results) != nrow(registry) ||
      !identical(as.character(results$ScenarioId),
                 as.character(registry$ScenarioId)) ||
      !all(results$AttributionContractValid)) {
    stop("Joint-cone attribution completion invariant failed.",
         call. = FALSE)
  }
  summary <- data.frame(
    DataCells = nrow(results),
    PositiveOriginalCones = sum(results$JointConeCertified),
    OriginalTargetDirections = sum(results$JointTargetDirections),
    OriginalTargetLPCalls = sum(results$JointTargetLPCalls),
    OriginalCertifiedTargetDirections =
      sum(results$JointCertifiedTargetDirections),
    OrdinaryFreeExtremePersons =
      sum(results$OrdinaryFreeExtremePersons),
    ConeStructuralCoordinates = sum(results$ConeStructuralCoordinates),
    SelectedNonzeroTargets = sum(results$SelectedNonzeroTargets),
    NegativeQuotientCones = sum(!results$QuotientConeCertified),
    OriginalJointSeconds = sum(results$JointSeconds),
    QuotientConeSeconds = sum(results$QuotientSeconds),
    StatisticalOperatingCharacteristicsEstimated = FALSE,
    RuntimeCriteriaFrozen = FALSE,
    ConfirmationAuthorized = FALSE,
    EvidenceUse = "joint_cone_attribution_calibration_only",
    stringsAsFactors = FALSE
  )
  files <- list(
    "registry.csv" = registry,
    "run-results.csv" = results,
    "cone-loadings.csv" = cone_loadings,
    "target-projections.csv" = target_projection,
    "person-status.csv" = person_status,
    "run-summary.csv" = summary,
    "execution-identity.csv" = identity$execution,
    "package-identity.csv" = identity$package,
    "runner-identity.csv" = identity$runners
  )
  for (name in names(files)) {
    utils::write.csv(
      files[[name]], file.path(staging, name), row.names = FALSE, na = ""
    )
  }
  out <- list(
    registry = registry,
    results = results,
    cone_loadings = cone_loadings,
    target_projection = target_projection,
    person_status = person_status,
    summary = summary,
    execution_identity = identity$execution,
    package_identity = identity$package,
    runner_identity = identity$runners,
    confirmation_authorized = FALSE,
    session_info = utils::sessionInfo()
  )
  saveRDS(out, file.path(staging, "joint-cone-attribution.rds"))
  saveRDS(utils::sessionInfo(), file.path(staging, "session-info.rds"))
  inventory <- mfrmr_target_scale_artifact_inventory(staging)
  completion <- list(
    schema = "mfrmr-jml-joint-cone-attribution-completion-v1",
    execution_sha256 = identity$execution$ExecutionSHA256,
    artifacts = inventory,
    artifact_inventory_sha256 = mfrmr_gpcm_repilot_hash_object(inventory),
    completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    confirmation_authorized = FALSE
  )
  saveRDS(completion, file.path(staging, "run-complete.rds"))
  if (!file.rename(staging, output_dir)) {
    stop("Completed joint-attribution evidence could not be promoted.",
         call. = FALSE)
  }
  promoted <- TRUE
  invisible(out)
}

if (sys.nframe() == 0L && !interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) != 1L) {
    stop("Usage: Rscript jml-joint-cone-attribution-pilot-0.2.3.R OUTPUT_DIR",
         call. = FALSE)
  }
  mfrmr_jml_joint_attribution_run(args[[1L]])
}
