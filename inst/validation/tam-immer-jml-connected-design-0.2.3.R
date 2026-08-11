# Draft.78 connected-assignment stress design for TAM/immer/mfrmr JML.

mfrmr_tic_require <- function() {
  target_env <- environment(mfrmr_tic_require)
  if (!exists("mfrmr_tif_recovery_metrics", envir = target_env,
              inherits = TRUE)) {
    candidates <- c(
      file.path(
        "inst", "validation",
        "tam-immer-jml-factor-stress-0.2.3.R"
      ),
      file.path(
        "..", "inst", "validation",
        "tam-immer-jml-factor-stress-0.2.3.R"
      ),
      file.path(
        "..", "..", "inst", "validation",
        "tam-immer-jml-factor-stress-0.2.3.R"
      ),
      file.path(
        "..", "..", "..", "inst", "validation",
        "tam-immer-jml-factor-stress-0.2.3.R"
      )
    )
    path <- candidates[file.exists(candidates)][1L]
    if (is.na(path)) {
      stop("The Draft.77 factor runner is unavailable.", call. = FALSE)
    }
    sys.source(path, envir = target_env)
  }
  mfrmr_tif_require()
  if (!exists("fit_mfrm", envir = target_env, inherits = TRUE)) {
    assign(
      "fit_mfrm", getExportedValue("mfrmr", "fit_mfrm"),
      envir = target_env
    )
  }
  invisible(TRUE)
}

mfrmr_tic_reference_profile <- function() {
  data.frame(
    ProfileId = "REFERENCE_R8_D2",
    FactorBlock = "connected_reference",
    ContrastMembership = "bridge_reference;fixed_degree",
    Persons = 120L,
    Raters = 8L,
    Criteria = 4L,
    Categories = 4L,
    BaseDegree = 2L,
    BridgeFraction = 0,
    WorkloadRatio = 1,
    MissingMechanism = "none",
    MissingRate = 0,
    stringsAsFactors = FALSE
  )
}

mfrmr_tic_profile <- function(id, block, ..., reference = NULL) {
  if (is.null(reference)) reference <- mfrmr_tic_reference_profile()
  out <- reference
  out$ProfileId <- id
  out$FactorBlock <- block
  out$ContrastMembership <- block
  values <- list(...)
  for (name in names(values)) out[[name]] <- values[[name]]
  out
}

mfrmr_tic_profiles <- function() {
  ref <- mfrmr_tic_reference_profile()
  dplyr::bind_rows(
    ref,
    mfrmr_tic_profile(
      "BRIDGE_B000", "bridge_fraction_count", BaseDegree = 1L,
      BridgeFraction = 0, reference = ref
    ),
    mfrmr_tic_profile(
      "BRIDGE_B005", "bridge_fraction_count", BaseDegree = 1L,
      BridgeFraction = 0.05, reference = ref
    ),
    mfrmr_tic_profile(
      "BRIDGE_B010", "bridge_fraction_count", BaseDegree = 1L,
      BridgeFraction = 0.10, reference = ref
    ),
    mfrmr_tic_profile(
      "BRIDGE_B025", "bridge_fraction_count", BaseDegree = 1L,
      BridgeFraction = 0.25, reference = ref
    ),
    mfrmr_tic_profile(
      "BRIDGE_B050", "bridge_fraction_count", BaseDegree = 1L,
      BridgeFraction = 0.50, reference = ref
    ),
    mfrmr_tic_profile(
      "BRIDGE_P60_B010", "bridge_count", Persons = 60L,
      BaseDegree = 1L, BridgeFraction = 0.10, reference = ref
    ),
    mfrmr_tic_profile(
      "BRIDGE_P60_B020", "bridge_count", Persons = 60L,
      BaseDegree = 1L, BridgeFraction = 0.20, reference = ref
    ),
    mfrmr_tic_profile(
      "BRIDGE_P480_B0025", "bridge_count", Persons = 480L,
      BaseDegree = 1L, BridgeFraction = 0.025, reference = ref
    ),
    mfrmr_tic_profile(
      "FIXDEG_R4_D2", "fixed_degree", Raters = 4L,
      BaseDegree = 2L,
      ContrastMembership = "fixed_degree;fixed_density", reference = ref
    ),
    mfrmr_tic_profile(
      "FIXDEG_R12_D2", "fixed_degree", Raters = 12L,
      BaseDegree = 2L, reference = ref
    ),
    mfrmr_tic_profile(
      "FIXDENS_R8_D4", "fixed_density", Raters = 8L,
      BaseDegree = 4L, reference = ref
    ),
    mfrmr_tic_profile(
      "FIXDENS_R12_D6", "fixed_density", Raters = 12L,
      BaseDegree = 6L, reference = ref
    ),
    mfrmr_tic_profile(
      "LOAD4_R8_D2", "workload", BaseDegree = 2L,
      WorkloadRatio = 4, reference = ref
    ),
    mfrmr_tic_profile(
      "LOAD12_R8_D2", "workload", BaseDegree = 2L,
      WorkloadRatio = 12, reference = ref
    ),
    mfrmr_tic_profile(
      "BRIDGE_B025_MCAR30", "connected_missingness", BaseDegree = 1L,
      BridgeFraction = 0.25, MissingMechanism = "MCAR",
      MissingRate = 0.30, reference = ref
    ),
    mfrmr_tic_profile(
      "BRIDGE_B025_MAR30", "connected_missingness", BaseDegree = 1L,
      BridgeFraction = 0.25, MissingMechanism = "MAR_rater",
      MissingRate = 0.30, reference = ref
    ),
    mfrmr_tic_profile(
      "BRIDGE_B025_MNAR30", "connected_missingness", BaseDegree = 1L,
      BridgeFraction = 0.25, MissingMechanism = "MNAR_score",
      MissingRate = 0.30, reference = ref
    )
  )
}

mfrmr_tic_manifest <- function() {
  profiles <- mfrmr_tic_profiles()
  grid <- merge(
    profiles,
    data.frame(Model = c("RSM", "PCM"), stringsAsFactors = FALSE),
    by = NULL
  )
  grid <- grid[order(grid$Model, grid$ProfileId), , drop = FALSE]
  grid$DatasetRow <- seq_len(nrow(grid))
  grid$Tier <- "connected_smoke"
  grid$Replicate <- 1L
  grid$Seed <- 780000L + grid$DatasetRow * 101L
  grid$BridgePersonsTarget <- floor(grid$Persons * grid$BridgeFraction)
  grid$SpanningBridgeThreshold <- pmax(grid$Raters - 1L, 0L)
  grid$ExpectedAssignedConnected <-
    grid$BaseDegree >= 2L |
    grid$BridgePersonsTarget >= grid$SpanningBridgeThreshold
  grid$ExpectedDatasetState <- ifelse(
    grid$ExpectedAssignedConnected,
    "attempted_modes", "structurally_unidentified"
  )
  grid$RatersPerPerson <- grid$BaseDegree
  grid$TargetMeanPersonRaterDegree <-
    pmin(grid$Raters, grid$BaseDegree + grid$BridgeFraction)
  grid$TargetAssignmentDensity <-
    grid$TargetMeanPersonRaterDegree / grid$Raters
  grid$TargetResponsesPerPerson <-
    grid$TargetMeanPersonRaterDegree * grid$Criteria *
    (1 - grid$MissingRate)
  grid$MfrmrMaxit <- 500L
  grid$TamMaxit <- 500L
  grid$ImmerMaxit <- 1000L
  grid$ExtremeFraction <- 0
  grid$LocalDependenceRho <- 0
  grid$AnchorRate <- 0
  grid$ForcedExtremeN <- 0L
  grid$FitEligible <- TRUE
  grid$FitIneligibilityReason <- ""
  grid$DatasetId <- sprintf(
    "EXT-JML-CONNECTED-%s-%s", grid$Model, grid$ProfileId
  )
  grid$PairId <- sprintf(
    "EXT-JML-CONNECTED-PAIR-%s-%s", grid$Model, grid$ProfileId
  )
  grid$Information <- grid$FactorBlock
  grid$FormulaIdentity <- ifelse(
    grid$Model == "RSM", "~ item + rater + step",
    "~ item + rater + item:step"
  )
  grid$ContractVersion <- "mfrmr-tam-immer-jml-connected-design-v1"
  rownames(grid) <- NULL
  grid
}

mfrmr_tic_assignment <- function(data, base_degree, bridge_fraction,
                                  workload_ratio, seed) {
  persons <- sort(unique(as.character(data$Person)))
  raters <- sort(unique(as.character(data$Rater)))
  n_person <- length(persons)
  n_rater <- length(raters)
  base_degree <- as.integer(base_degree)
  if (base_degree < 1L || base_degree > n_rater) {
    stop("BaseDegree must be between one and the number of Raters.",
         call. = FALSE)
  }
  bridge_n <- min(
    n_person,
    max(0L, as.integer(floor(n_person * as.numeric(bridge_fraction))))
  )
  set.seed(as.integer(seed))
  probability <- exp(
    seq(0, log(max(1, as.numeric(workload_ratio))), length.out = n_rater)
  )
  selected <- vector("list", n_person)
  for (i in seq_len(n_person)) {
    if (workload_ratio <= 1 || i <= n_rater || base_degree == n_rater) {
      index <- ((i - 1L) + seq_len(base_degree) - 1L) %% n_rater + 1L
      selected[[i]] <- raters[index]
    } else {
      selected[[i]] <- sample(
        raters, size = base_degree, replace = FALSE, prob = probability
      )
    }
  }
  if (bridge_n > 0L && base_degree < n_rater) {
    for (i in seq_len(bridge_n)) {
      next_rater <- raters[(i %% n_rater) + 1L]
      selected[[i]] <- unique(c(selected[[i]], next_rater))
    }
  }
  names(selected) <- persons
  keep <- vapply(seq_len(nrow(data)), function(i) {
    as.character(data$Rater[i]) %in%
      selected[[as.character(data$Person[i])]]
  }, logical(1))
  data[keep, , drop = FALSE]
}

mfrmr_tic_components <- function(adjacency) {
  n <- nrow(adjacency)
  if (n == 0L) return(0L)
  visited <- rep(FALSE, n)
  components <- 0L
  for (start in seq_len(n)) {
    if (visited[start]) next
    components <- components + 1L
    queue <- start
    visited[start] <- TRUE
    while (length(queue) > 0L) {
      current <- queue[1L]
      queue <- queue[-1L]
      neighbour <- which(adjacency[current, ] > 0 & !visited)
      if (length(neighbour) > 0L) {
        visited[neighbour] <- TRUE
        queue <- c(queue, neighbour)
      }
    }
  }
  components
}

mfrmr_tic_graph_audit <- function(data, row, stage) {
  raters <- sort(unique(as.character(data$Rater)))
  retained <- if (identical(stage, "Observed")) {
    !is.na(data$Score)
  } else {
    rep(TRUE, nrow(data))
  }
  pair <- unique(data.frame(
    Person = as.character(data$Person[retained]),
    Rater = as.character(data$Rater[retained]),
    stringsAsFactors = FALSE
  ))
  persons <- sort(unique(as.character(data$Person)))
  degrees <- table(factor(pair$Person, levels = persons))
  workload <- table(factor(pair$Rater, levels = raters))
  shared <- matrix(0, length(raters), length(raters),
                   dimnames = list(raters, raters))
  by_person <- split(pair$Rater, pair$Person)
  for (value in by_person) {
    value <- unique(as.character(value))
    if (length(value) < 2L) next
    combinations <- utils::combn(value, 2L)
    for (j in seq_len(ncol(combinations))) {
      left <- combinations[1L, j]
      right <- combinations[2L, j]
      shared[left, right] <- shared[left, right] + 1
      shared[right, left] <- shared[right, left] + 1
    }
  }
  adjacency <- (shared > 0) * 1
  components <- mfrmr_tic_components(adjacency)
  laplacian <- diag(rowSums(shared)) - shared
  eigenvalues <- sort(Re(eigen(laplacian, symmetric = TRUE,
                               only.values = TRUE)$values))
  algebraic <- if (length(eigenvalues) >= 2L) {
    max(0, eigenvalues[2L])
  } else {
    NA_real_
  }
  edge_weight <- shared[upper.tri(shared) & shared > 0]
  base_degree <- as.integer(row$BaseDegree)
  data.frame(
    DatasetId = as.character(row$DatasetId),
    Model = as.character(row$Model),
    ProfileId = as.character(row$ProfileId),
    Stage = stage,
    DeclaredPersons = as.integer(row$Persons),
    DeclaredRaters = as.integer(row$Raters),
    PersonRaterPairs = nrow(pair),
    MeanPersonRaterDegree = mean(as.numeric(degrees)),
    MinPersonRaterDegree = min(as.numeric(degrees)),
    MaxPersonRaterDegree = max(as.numeric(degrees)),
    BridgePersonsTarget = as.integer(row$BridgePersonsTarget),
    BridgePersonsRealized = sum(as.numeric(degrees) > base_degree),
    AssignmentDensity = nrow(pair) /
      (as.integer(row$Persons) * as.integer(row$Raters)),
    RaterWorkloadGini = mfrmr_tif_gini(workload),
    RaterWorkloadMaxMinRatio = if (min(workload) > 0) {
      max(workload) / min(workload)
    } else {
      Inf
    },
    RaterGraphEdges = sum(upper.tri(adjacency) & adjacency > 0),
    RaterGraphComponents = components,
    RaterGraphConnected = components == 1L,
    MinimumSharedPersonsOnEdge = if (length(edge_weight) > 0L) {
      min(edge_weight)
    } else {
      0
    },
    AlgebraicConnectivityWeighted = algebraic,
    ExpectedAssignedConnected = isTRUE(row$ExpectedAssignedConnected),
    stringsAsFactors = FALSE
  )
}

mfrmr_tic_generate <- function(row) {
  mfrmr_tic_require()
  data <- mfrmr::simulate_mfrm_data(
    n_person = as.integer(row$Persons),
    n_rater = as.integer(row$Raters),
    n_criterion = as.integer(row$Criteria),
    raters_per_person = as.integer(row$Raters),
    score_levels = as.integer(row$Categories),
    model = as.character(row$Model),
    step_facet = "Criterion",
    assignment = "crossed",
    seed = as.integer(row$Seed)
  )
  truth <- attr(data, "mfrm_truth")
  data <- mfrmr_tic_assignment(
    data, as.integer(row$BaseDegree), as.numeric(row$BridgeFraction),
    as.numeric(row$WorkloadRatio), as.integer(row$Seed) + 1L
  )
  assigned_audit <- mfrmr_tic_graph_audit(data, row, "Assigned")
  data <- mfrmr_tif_apply_missingness(
    data, as.character(row$MissingMechanism), as.numeric(row$MissingRate),
    as.integer(row$Seed) + 2L
  )
  observed_audit <- mfrmr_tic_graph_audit(data, row, "Observed")
  attr(data, "mfrm_truth") <- truth
  attr(data, "mfrmr_factor_audit") <- mfrmr_tif_design_audit(data, row)
  attr(data, "mfrmr_connected_graph_audit") <- rbind(
    assigned_audit, observed_audit
  )
  data
}

mfrmr_tic_run_cell <- function(row) {
  data <- tryCatch(mfrmr_tic_generate(row), error = function(e) e)
  if (inherits(data, "error")) {
    return(list(
      Dataset = data.frame(
        DatasetId = row$DatasetId,
        ExpectedDatasetState = row$ExpectedDatasetState,
        ObservedDatasetState = "generation_error",
        Generated = FALSE, FitAttempted = FALSE, RetainedModeRows = 0L,
        Error = conditionMessage(data), stringsAsFactors = FALSE
      ),
      Audit = data.frame(), GraphAudit = data.frame(), Modes = data.frame(),
      Metrics = data.frame(), Output = NULL
    ))
  }
  audit <- attr(data, "mfrmr_factor_audit")
  graph_audit <- attr(data, "mfrmr_connected_graph_audit")
  value <- tryCatch(mfrmr_ti_fit_one(row, data = data), error = function(e) e)
  if (inherits(value, "error")) {
    observed_state <- if (grepl(
      "structurally unidentified", conditionMessage(value), fixed = TRUE
    )) {
      "structurally_unidentified"
    } else {
      "attempted_failure"
    }
    return(list(
      Dataset = data.frame(
        DatasetId = row$DatasetId,
        ExpectedDatasetState = row$ExpectedDatasetState,
        ObservedDatasetState = observed_state,
        Generated = TRUE, FitAttempted = TRUE, RetainedModeRows = 0L,
        Error = conditionMessage(value), stringsAsFactors = FALSE
      ),
      Audit = audit, GraphAudit = graph_audit, Modes = data.frame(),
      Metrics = data.frame(), Output = NULL
    ))
  }
  value$modes$ProfileId <- row$ProfileId
  value$modes$FactorBlock <- row$FactorBlock
  value$modes$ContrastMembership <- row$ContrastMembership
  list(
    Dataset = data.frame(
      DatasetId = row$DatasetId,
      ExpectedDatasetState = row$ExpectedDatasetState,
      ObservedDatasetState = "attempted_modes",
      Generated = TRUE, FitAttempted = TRUE,
      RetainedModeRows = nrow(value$modes), Error = "",
      stringsAsFactors = FALSE
    ),
    Audit = audit,
    GraphAudit = graph_audit,
    Modes = value$modes,
    Metrics = mfrmr_tif_recovery_metrics(value, row),
    Output = value
  )
}

mfrmr_run_tam_immer_jml_connected_design <- function(
    dry_run = FALSE, progress = interactive()) {
  manifest <- mfrmr_tic_manifest()
  if (isTRUE(dry_run)) return(manifest)
  mfrmr_tic_require()
  results <- vector("list", nrow(manifest))
  for (i in seq_len(nrow(manifest))) {
    if (isTRUE(progress)) {
      message("[", i, "/", nrow(manifest), "] ", manifest$DatasetId[i])
    }
    results[[i]] <- mfrmr_tic_run_cell(manifest[i, , drop = FALSE])
  }
  datasets <- dplyr::bind_rows(lapply(results, `[[`, "Dataset"))
  audits <- dplyr::bind_rows(lapply(results, `[[`, "Audit"))
  graph_audits <- dplyr::bind_rows(lapply(results, `[[`, "GraphAudit"))
  modes <- dplyr::bind_rows(lapply(results, `[[`, "Modes"))
  metrics <- dplyr::bind_rows(lapply(results, `[[`, "Metrics"))
  expected_mode_rows <- 9L * sum(
    manifest$ExpectedDatasetState == "attempted_modes"
  )
  assigned <- graph_audits[graph_audits$Stage == "Assigned", , drop = FALSE]
  assigned <- assigned[match(manifest$DatasetId, assigned$DatasetId), ]
  observed <- graph_audits[graph_audits$Stage == "Observed", , drop = FALSE]
  observed <- observed[match(manifest$DatasetId, observed$DatasetId), ]
  contract_passed <-
    identical(as.character(datasets$DatasetId),
              as.character(manifest$DatasetId)) &&
    identical(as.character(datasets$ObservedDatasetState),
              as.character(manifest$ExpectedDatasetState)) &&
    all(datasets$RetainedModeRows[
      datasets$ExpectedDatasetState == "attempted_modes"
    ] == 9L) &&
    all(datasets$RetainedModeRows[
      datasets$ExpectedDatasetState == "structurally_unidentified"
    ] == 0L) &&
    nrow(modes) == expected_mode_rows &&
    !anyNA(assigned$RaterGraphConnected) &&
    identical(as.logical(assigned$RaterGraphConnected),
              as.logical(manifest$ExpectedAssignedConnected)) &&
    identical(as.logical(observed$RaterGraphConnected),
              as.logical(manifest$ExpectedAssignedConnected)) &&
    nrow(metrics) > 0L && all(metrics$EvidenceReady == FALSE)
  list(
    ContractVersion = "mfrmr-tam-immer-jml-connected-design-v1",
    Manifest = manifest,
    Datasets = datasets,
    Audit = audits,
    GraphAudit = graph_audits,
    Modes = modes,
    Metrics = metrics,
    Outputs = lapply(results, `[[`, "Output"),
    ContractPassed = isTRUE(contract_passed),
    EvidenceReady = FALSE,
    CompletedUTC = format(Sys.time(), tz = "UTC", usetz = TRUE)
  )
}
