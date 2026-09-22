# Draft.79 matched-topology TAM/immer/mfrmr JML calibration runner.

.mfrmr_tit_runtime_identity_cache <- NULL

mfrmr_tit_require <- function() {
  target_env <- environment(mfrmr_tit_require)
  if (!exists("mfrmr_tic_graph_audit", envir = target_env,
              inherits = TRUE)) {
    candidates <- c(
      file.path(
        "inst", "validation",
        "tam-immer-jml-connected-design-0.2.3.R"
      ),
      file.path(
        "..", "inst", "validation",
        "tam-immer-jml-connected-design-0.2.3.R"
      ),
      file.path(
        "..", "..", "inst", "validation",
        "tam-immer-jml-connected-design-0.2.3.R"
      ),
      file.path(
        "..", "..", "..", "inst", "validation",
        "tam-immer-jml-connected-design-0.2.3.R"
      )
    )
    path <- candidates[file.exists(candidates)][1L]
    if (is.na(path)) {
      stop("The Draft.78 connected-design runner is unavailable.",
           call. = FALSE)
    }
    sys.source(path, envir = target_env)
  }
  mfrmr_tic_require()
  invisible(TRUE)
}

mfrmr_tit_profiles <- function() {
  reference <- data.frame(
    ProfileId = "REFERENCE_D2",
    FactorBlock = "reference",
    ContrastMembership = "reference_degree_two",
    Topology = "cyclic_degree_two",
    Persons = 120L, Raters = 8L, Criteria = 4L, Categories = 4L,
    BaseDegree = 2L, BridgePersons = 0L, LinkDropN = 0L,
    WorkloadRatio = 1, MissingMechanism = "none", MissingRate = 0,
    ExpectedAssignedConnected = TRUE,
    ExpectedObservedConnected = TRUE,
    stringsAsFactors = FALSE
  )
  disconnected <- reference
  disconnected$ProfileId <- "DISCONNECTED_B24"
  disconnected$FactorBlock <- "negative_control"
  disconnected$ContrastMembership <- "matched_count_negative"
  disconnected$Topology <- "disconnected_cluster"
  disconnected$BaseDegree <- 1L
  disconnected$BridgePersons <- 24L
  disconnected$ExpectedAssignedConnected <- FALSE
  disconnected$ExpectedObservedConnected <- FALSE
  matched <- expand.grid(
    Topology = c("path", "cycle", "distributed", "hub"),
    BridgePersons = c(8L, 12L, 24L),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  matched <- lapply(seq_len(nrow(matched)), function(i) {
    out <- reference
    out$ProfileId <- sprintf(
      "%s_B%02d", toupper(matched$Topology[i]),
      as.integer(matched$BridgePersons[i])
    )
    out$FactorBlock <- "matched_topology"
    out$ContrastMembership <- paste0(
      "bridge_count_", as.integer(matched$BridgePersons[i])
    )
    out$Topology <- matched$Topology[i]
    out$BaseDegree <- 1L
    out$BridgePersons <- as.integer(matched$BridgePersons[i])
    out
  })
  drop <- lapply(c("path", "cycle", "distributed", "hub"), function(topology) {
    out <- reference
    out$ProfileId <- paste0(toupper(topology), "_B12_DROP1")
    out$FactorBlock <- "observed_link_loss"
    out$ContrastMembership <- "bridge_count_12_adversarial_drop"
    out$Topology <- topology
    out$BaseDegree <- 1L
    out$BridgePersons <- 12L
    out$LinkDropN <- 1L
    out$ExpectedObservedConnected <-
      !topology %in% c("path", "hub")
    out
  })
  dplyr::bind_rows(c(list(reference, disconnected), matched, drop))
}

mfrmr_tit_manifest <- function(tier = c("smoke", "pilot")) {
  tier <- match.arg(tier)
  profiles <- mfrmr_tit_profiles()
  reps <- if (identical(tier, "smoke")) 1L else 5L
  grid <- merge(
    profiles,
    expand.grid(
      Model = c("RSM", "PCM"), Replicate = seq_len(reps),
      KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
    ),
    by = NULL
  )
  grid <- grid[order(grid$Model, grid$ProfileId, grid$Replicate), ]
  grid$DatasetRow <- seq_len(nrow(grid))
  grid$Tier <- tier
  grid$Seed <- 790000L + grid$DatasetRow * 101L
  grid$BridgeFraction <- grid$BridgePersons / grid$Persons
  grid$BridgePersonsTarget <- grid$BridgePersons
  grid$RatersPerPerson <- grid$BaseDegree
  grid$TargetMeanPersonRaterDegree <- ifelse(
    grid$BaseDegree == 1L,
    1 + grid$BridgePersons / grid$Persons,
    grid$BaseDegree
  )
  grid$TargetAssignmentDensity <-
    grid$TargetMeanPersonRaterDegree / grid$Raters
  grid$TargetResponsesPerPerson <-
    grid$TargetMeanPersonRaterDegree * grid$Criteria
  grid$ExpectedDatasetState <- ifelse(
    grid$ExpectedObservedConnected,
    "attempted_modes", "structurally_unidentified"
  )
  grid$MfrmrMaxit <- if (tier == "smoke") 500L else 600L
  grid$TamMaxit <- if (tier == "smoke") 800L else 1200L
  grid$ImmerMaxit <- 1000L
  grid$ExtremeFraction <- 0
  grid$LocalDependenceRho <- 0
  grid$AnchorRate <- 0
  grid$ForcedExtremeN <- 0L
  grid$FitEligible <- TRUE
  grid$FitIneligibilityReason <- ""
  grid$DatasetId <- sprintf(
    "EXT-JML-TOPOLOGY-%s-%s-R%02d",
    grid$Model, grid$ProfileId, grid$Replicate
  )
  grid$PairId <- sprintf(
    "EXT-JML-TOPOLOGY-PAIR-%s-%s-R%02d",
    grid$Model, grid$ProfileId, grid$Replicate
  )
  grid$Information <- grid$FactorBlock
  grid$FormulaIdentity <- ifelse(
    grid$Model == "RSM", "~ item + rater + step",
    "~ item + rater + item:step"
  )
  grid$ContractVersion <- "mfrmr-tam-immer-jml-topology-calibration-v1"
  rownames(grid) <- NULL
  grid
}

mfrmr_tit_edge_sequence <- function(topology, n_rater, bridge_n) {
  n_rater <- as.integer(n_rater)
  bridge_n <- as.integer(bridge_n)
  path <- cbind(seq_len(n_rater - 1L), seq.int(2L, n_rater))
  cycle <- rbind(path, c(n_rater, 1L))
  hub <- cbind(rep(1L, n_rater - 1L), seq.int(2L, n_rater))
  all_edges <- t(utils::combn(seq_len(n_rater), 2L))
  edge_key <- function(value) {
    paste(pmin(value[, 1L], value[, 2L]),
          pmax(value[, 1L], value[, 2L]), sep = "-")
  }
  distributed <- rbind(
    cycle,
    all_edges[!edge_key(all_edges) %in% edge_key(cycle), , drop = FALSE]
  )
  base <- switch(
    as.character(topology),
    path = path,
    cycle = cycle,
    distributed = distributed,
    hub = hub,
    disconnected_cluster = {
      cluster <- seq_len(min(4L, n_rater))
      rbind(
        cbind(cluster[-length(cluster)], cluster[-1L]),
        c(tail(cluster, 1L), cluster[1L])
      )
    },
    stop("Unknown matched topology: ", topology, call. = FALSE)
  )
  base[rep(seq_len(nrow(base)), length.out = bridge_n), , drop = FALSE]
}

mfrmr_tit_assignment <- function(data, row) {
  persons <- sort(unique(as.character(data$Person)))
  raters <- sort(unique(as.character(data$Rater)))
  if (as.integer(row$BaseDegree) >= 2L) {
    assigned <- mfrmr_tic_assignment(
      data, as.integer(row$BaseDegree), 0, 1,
      as.integer(row$Seed) + 1L
    )
    return(list(Data = assigned, BridgeMap = data.frame()))
  }
  bridge_n <- as.integer(row$BridgePersons)
  if (bridge_n > length(persons)) {
    stop("BridgePersons exceeds the number of Persons.", call. = FALSE)
  }
  selected <- lapply(seq_along(persons), function(i) {
    raters[((i - 1L) %% length(raters)) + 1L]
  })
  names(selected) <- persons
  edge <- mfrmr_tit_edge_sequence(
    as.character(row$Topology), length(raters), bridge_n
  )
  bridge_map <- data.frame(
    BridgeIndex = seq_len(bridge_n),
    Person = persons[seq_len(bridge_n)],
    RaterA = raters[edge[, 1L]],
    RaterB = raters[edge[, 2L]],
    stringsAsFactors = FALSE
  )
  for (i in seq_len(nrow(bridge_map))) {
    selected[[bridge_map$Person[i]]] <- c(
      bridge_map$RaterA[i], bridge_map$RaterB[i]
    )
  }
  keep <- vapply(seq_len(nrow(data)), function(i) {
    as.character(data$Rater[i]) %in%
      selected[[as.character(data$Person[i])]]
  }, logical(1))
  list(Data = data[keep, , drop = FALSE], BridgeMap = bridge_map)
}

mfrmr_tit_pair_table <- function(data, observed = TRUE) {
  keep <- if (isTRUE(observed)) !is.na(data$Score) else rep(TRUE, nrow(data))
  unique(data.frame(
    Person = as.character(data$Person[keep]),
    Rater = as.character(data$Rater[keep]),
    stringsAsFactors = FALSE
  ))
}

mfrmr_tit_shared_matrix <- function(pair, raters) {
  shared <- matrix(
    0, length(raters), length(raters), dimnames = list(raters, raters)
  )
  by_person <- split(pair$Rater, pair$Person)
  for (value in by_person) {
    value <- unique(as.character(value))
    if (length(value) < 2L) next
    combination <- utils::combn(value, 2L)
    for (j in seq_len(ncol(combination))) {
      left <- combination[1L, j]
      right <- combination[2L, j]
      shared[left, right] <- shared[left, right] + 1
      shared[right, left] <- shared[right, left] + 1
    }
  }
  shared
}

mfrmr_tit_algebraic_connectivity <- function(shared) {
  if (nrow(shared) < 2L) return(NA_real_)
  laplacian <- diag(rowSums(shared)) - shared
  value <- sort(Re(eigen(
    laplacian, symmetric = TRUE, only.values = TRUE
  )$values))[2L]
  max(0, value)
}

mfrmr_tit_graph_components <- function(shared) {
  mfrmr_tic_components((shared > 0) * 1)
}

mfrmr_tit_remove_candidate_state <- function(data, bridge_row, raters) {
  keep <- !(
    as.character(data$Person) == as.character(bridge_row$Person) &
      as.character(data$Rater) == as.character(bridge_row$RaterB)
  )
  candidate <- data
  candidate$Score[!keep] <- NA_integer_
  pair <- mfrmr_tit_pair_table(candidate, observed = TRUE)
  shared <- mfrmr_tit_shared_matrix(pair, raters)
  c(
    Components = mfrmr_tit_graph_components(shared),
    AlgebraicConnectivity = mfrmr_tit_algebraic_connectivity(shared)
  )
}

mfrmr_tit_apply_link_dropout <- function(data, bridge_map, drop_n) {
  drop_n <- as.integer(drop_n)
  if (drop_n < 1L) {
    return(list(Data = data, DroppedBridgeMap = data.frame()))
  }
  if (drop_n > nrow(bridge_map)) {
    stop("LinkDropN exceeds the available bridge Persons.", call. = FALSE)
  }
  raters <- sort(unique(as.character(data$Rater)))
  available <- bridge_map
  dropped <- vector("list", drop_n)
  for (step in seq_len(drop_n)) {
    state <- t(vapply(seq_len(nrow(available)), function(i) {
      mfrmr_tit_remove_candidate_state(
        data, available[i, , drop = FALSE], raters
      )
    }, numeric(2L)))
    order_index <- order(
      -state[, "Components"], state[, "AlgebraicConnectivity"],
      available$BridgeIndex
    )
    chosen <- available[order_index[1L], , drop = FALSE]
    remove <-
      as.character(data$Person) == as.character(chosen$Person) &
      as.character(data$Rater) == as.character(chosen$RaterB)
    data$Score[remove] <- NA_integer_
    chosen$DropStep <- step
    chosen$ComponentsAfterDrop <- state[order_index[1L], "Components"]
    chosen$AlgebraicConnectivityAfterDrop <-
      state[order_index[1L], "AlgebraicConnectivity"]
    dropped[[step]] <- chosen
    available <- available[-order_index[1L], , drop = FALSE]
  }
  list(Data = data, DroppedBridgeMap = dplyr::bind_rows(dropped))
}

mfrmr_tit_vulnerability <- function(shared) {
  adjacency <- (shared > 0) * 1
  n <- nrow(adjacency)
  components <- mfrmr_tic_components(adjacency)
  connected <- components == 1L
  graph_degree <- rowSums(adjacency)
  upper <- which(upper.tri(adjacency) & adjacency > 0, arr.ind = TRUE)
  articulation <- rep(NA, n)
  cut_edge <- rep(NA, nrow(upper))
  single_link_failure <- rep(NA, nrow(upper))
  if (connected) {
    articulation <- vapply(seq_len(n), function(i) {
      reduced <- adjacency[-i, -i, drop = FALSE]
      mfrmr_tic_components(reduced) > 1L
    }, logical(1))
    if (nrow(upper) > 0L) {
      for (i in seq_len(nrow(upper))) {
        left <- upper[i, 1L]
        right <- upper[i, 2L]
        reduced <- adjacency
        reduced[left, right] <- reduced[right, left] <- 0
        cut_edge[i] <- mfrmr_tic_components(reduced) > 1L
        one_person_less <- shared
        one_person_less[left, right] <- one_person_less[left, right] - 1
        one_person_less[right, left] <- one_person_less[right, left] - 1
        single_link_failure[i] <-
          mfrmr_tit_graph_components(one_person_less) > 1L
      }
    }
  }
  edge_weight <- shared[upper.tri(shared) & shared > 0]
  list(
    MinimumGraphDegree = if (n > 0L) min(graph_degree) else NA_real_,
    MaximumGraphDegree = if (n > 0L) max(graph_degree) else NA_real_,
    CycleRank = sum(upper.tri(adjacency) & adjacency > 0) - n + components,
    ArticulationRaterCount = if (connected) sum(articulation) else NA_integer_,
    GraphCutEdgeCount = if (connected) sum(cut_edge) else NA_integer_,
    SingleLinkPersonFailureEdgeCount = if (connected) {
      sum(single_link_failure)
    } else {
      NA_integer_
    },
    SingleRaterRemovalRobust = if (connected) !any(articulation) else FALSE,
    SingleGraphEdgeRemovalRobust = if (connected) !any(cut_edge) else FALSE,
    SingleLinkPersonRemovalRobust = if (connected) {
      !any(single_link_failure)
    } else {
      FALSE
    },
    MaximumSharedPersonsOnEdge = if (length(edge_weight) > 0L) {
      max(edge_weight)
    } else {
      0
    },
    EdgeWeightCV = if (length(edge_weight) > 1L && mean(edge_weight) > 0) {
      stats::sd(edge_weight) / mean(edge_weight)
    } else {
      0
    }
  )
}

mfrmr_tit_graph_audit <- function(data, row, stage) {
  base <- mfrmr_tic_graph_audit(data, row, stage)
  pair <- mfrmr_tit_pair_table(data, observed = identical(stage, "Observed"))
  raters <- sort(unique(as.character(data$Rater)))
  shared <- mfrmr_tit_shared_matrix(pair, raters)
  vulnerability <- mfrmr_tit_vulnerability(shared)
  for (name in names(vulnerability)) base[[name]] <- vulnerability[[name]]
  base$Topology <- as.character(row$Topology)
  base$BridgePersonsDeclared <- as.integer(row$BridgePersons)
  base$LinkDropNTarget <- as.integer(row$LinkDropN)
  base$LinkDropNRealized <- if (identical(stage, "Observed")) {
    as.integer(row$BridgePersons) - as.integer(base$BridgePersonsRealized)
  } else {
    0L
  }
  base$ExpectedObservedConnected <- isTRUE(row$ExpectedObservedConnected)
  base
}

mfrmr_tit_generate <- function(row) {
  mfrmr_tit_require()
  data <- mfrmr::simulate_mfrm_data(
    n_person = as.integer(row$Persons),
    n_rater = as.integer(row$Raters),
    n_criterion = as.integer(row$Criteria),
    raters_per_person = as.integer(row$Raters),
    score_levels = as.integer(row$Categories),
    model = as.character(row$Model),
    step_facet = "Criterion", assignment = "crossed",
    seed = as.integer(row$Seed)
  )
  truth <- attr(data, "mfrm_truth")
  assignment <- mfrmr_tit_assignment(data, row)
  data <- assignment$Data
  assigned_audit <- mfrmr_tit_graph_audit(data, row, "Assigned")
  dropout <- mfrmr_tit_apply_link_dropout(
    data, assignment$BridgeMap, as.integer(row$LinkDropN)
  )
  data <- dropout$Data
  observed_audit <- mfrmr_tit_graph_audit(data, row, "Observed")
  attr(data, "mfrm_truth") <- truth
  attr(data, "mfrmr_factor_audit") <- mfrmr_tif_design_audit(data, row)
  attr(data, "mfrmr_topology_graph_audit") <- rbind(
    assigned_audit, observed_audit
  )
  attr(data, "mfrmr_topology_bridge_map") <- assignment$BridgeMap
  attr(data, "mfrmr_topology_dropped_bridge_map") <-
    dropout$DroppedBridgeMap
  data
}

mfrmr_tit_run_cell <- function(row) {
  data <- tryCatch(mfrmr_tit_generate(row), error = function(e) e)
  if (inherits(data, "error")) {
    return(list(
      Dataset = data.frame(
        DatasetId = row$DatasetId,
        ExpectedDatasetState = row$ExpectedDatasetState,
        ObservedDatasetState = "generation_error",
        Generated = FALSE, FitAttempted = FALSE, RetainedModeRows = 0L,
        Error = conditionMessage(data), stringsAsFactors = FALSE
      ),
      Audit = data.frame(), GraphAudit = data.frame(),
      DroppedBridgeMap = data.frame(), Modes = data.frame(),
      Metrics = data.frame(), Output = NULL
    ))
  }
  audit <- attr(data, "mfrmr_factor_audit")
  graph_audit <- attr(data, "mfrmr_topology_graph_audit")
  dropped <- attr(data, "mfrmr_topology_dropped_bridge_map")
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
      Audit = audit, GraphAudit = graph_audit,
      DroppedBridgeMap = dropped, Modes = data.frame(),
      Metrics = data.frame(), Output = NULL
    ))
  }
  value$modes$ProfileId <- row$ProfileId
  value$modes$FactorBlock <- row$FactorBlock
  value$modes$Topology <- row$Topology
  value$modes$BridgePersons <- row$BridgePersons
  metrics <- mfrmr_tif_recovery_metrics(value, row)
  metrics$Topology <- row$Topology
  metrics$BridgePersons <- row$BridgePersons
  metrics$LinkDropN <- row$LinkDropN
  list(
    Dataset = data.frame(
      DatasetId = row$DatasetId,
      ExpectedDatasetState = row$ExpectedDatasetState,
      ObservedDatasetState = "attempted_modes",
      Generated = TRUE, FitAttempted = TRUE,
      RetainedModeRows = nrow(value$modes), Error = "",
      stringsAsFactors = FALSE
    ),
    Audit = audit, GraphAudit = graph_audit,
    DroppedBridgeMap = dropped, Modes = value$modes,
    Metrics = metrics, Output = value
  )
}

mfrmr_tit_checkpoint_schema <- function() {
  "mfrmr-tam-immer-jml-topology-checkpoint-v1"
}

mfrmr_tit_runner_hash <- function() {
  target_env <- environment(mfrmr_tit_runner_hash)
  names <- c(
    "mfrmr_tit_manifest", "mfrmr_tit_edge_sequence",
    "mfrmr_tit_assignment", "mfrmr_tit_apply_link_dropout",
    "mfrmr_tit_vulnerability", "mfrmr_tit_graph_audit",
    "mfrmr_tit_generate", "mfrmr_ti_fit_one",
    "mfrmr_tif_recovery_metrics", "mfrmr_tit_run_cell",
    "mfrmr_tit_checkpoint", "mfrmr_tit_validate_checkpoint"
  )
  definitions <- lapply(names, function(name) {
    object <- get(name, envir = target_env, inherits = TRUE)
    list(name = name, formals = formals(object), body = body(object))
  })
  mfrmr_tif_hash_object(definitions)
}

mfrmr_tit_frozen_runtime_identity <- function() {
  target_env <- environment(mfrmr_tit_frozen_runtime_identity)
  cached <- get(
    ".mfrmr_tit_runtime_identity_cache", envir = target_env,
    inherits = FALSE
  )
  if (is.null(cached)) {
    cached <- mfrmr_ti_runtime_identity()
    assign(
      ".mfrmr_tit_runtime_identity_cache", cached, envir = target_env
    )
  }
  cached
}

mfrmr_tit_execution_identity <- function(tier, manifest) {
  mfrmr_tit_require()
  identity <- list(
    Schema = mfrmr_tit_checkpoint_schema(),
    Tier = as.character(tier),
    ManifestSHA256 = mfrmr_tif_hash_object(manifest),
    RunnerSHA256 = mfrmr_tit_runner_hash(),
    RuntimeIdentity = mfrmr_tit_frozen_runtime_identity(),
    RVersion = R.version.string,
    Platform = R.version$platform,
    RNGKind = RNGkind()
  )
  identity$ExecutionSHA256 <- mfrmr_tif_hash_object(identity)
  identity
}

mfrmr_tit_checkpoint_path <- function(checkpoint_dir, dataset_id) {
  if (length(dataset_id) != 1L || is.na(dataset_id) ||
      !grepl("^[A-Za-z0-9._-]+$", dataset_id)) {
    stop("Unsafe topology-checkpoint dataset identifier.", call. = FALSE)
  }
  file.path(checkpoint_dir, paste0(dataset_id, ".rds"))
}

mfrmr_tit_atomic_save_rds <- function(object, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  if (file.exists(path)) {
    stop("Refusing to replace existing topology artifact: ", path,
         call. = FALSE)
  }
  temporary <- tempfile(
    pattern = paste0(".", basename(path), "-"),
    tmpdir = dirname(path), fileext = ".partial"
  )
  on.exit(unlink(temporary, force = TRUE), add = TRUE)
  saveRDS(object, temporary)
  verified <- tryCatch(readRDS(temporary), error = function(e) e)
  if (inherits(verified, "error") ||
      !identical(mfrmr_tif_hash_object(object),
                 mfrmr_tif_hash_object(verified))) {
    stop("Temporary topology artifact verification failed.", call. = FALSE)
  }
  if (!file.rename(temporary, path)) {
    stop("Atomic topology artifact rename failed: ", path, call. = FALSE)
  }
  invisible(path)
}

mfrmr_tit_checkpoint <- function(row, result, identity) {
  structure(
    list(
      Schema = mfrmr_tit_checkpoint_schema(),
      ExecutionSHA256 = identity$ExecutionSHA256,
      DatasetId = as.character(row$DatasetId),
      ManifestRowSHA256 = mfrmr_tif_hash_object(row),
      ResultSHA256 = mfrmr_tif_hash_object(result),
      ManifestRow = row, Result = result,
      CompletedUTC = format(Sys.time(), tz = "UTC", usetz = TRUE)
    ),
    class = "mfrmr_tit_checkpoint"
  )
}

mfrmr_tit_validate_checkpoint <- function(checkpoint, row, identity) {
  fail <- function(message) {
    stop("Topology checkpoint validation failed: ", message, call. = FALSE)
  }
  if (!inherits(checkpoint, "mfrmr_tit_checkpoint")) {
    fail("unexpected object class")
  }
  if (!identical(checkpoint$Schema, mfrmr_tit_checkpoint_schema())) {
    fail("schema mismatch")
  }
  if (!identical(checkpoint$ExecutionSHA256, identity$ExecutionSHA256)) {
    fail("execution identity mismatch")
  }
  if (!identical(checkpoint$DatasetId, as.character(row$DatasetId))) {
    fail("dataset identity mismatch")
  }
  if (!identical(checkpoint$ManifestRowSHA256,
                 mfrmr_tif_hash_object(row))) {
    fail("manifest row hash mismatch")
  }
  if (!identical(checkpoint$ResultSHA256,
                 mfrmr_tif_hash_object(checkpoint$Result))) {
    fail("result payload hash mismatch")
  }
  required <- c(
    "Dataset", "Audit", "GraphAudit", "DroppedBridgeMap",
    "Modes", "Metrics", "Output"
  )
  if (!is.list(checkpoint$Result) ||
      !all(required %in% names(checkpoint$Result))) {
    fail("result schema mismatch")
  }
  invisible(TRUE)
}

mfrmr_tit_read_checkpoint <- function(path, row, identity) {
  checkpoint <- tryCatch(readRDS(path), error = function(e) e)
  if (inherits(checkpoint, "error")) {
    stop(
      "Topology checkpoint validation failed: unreadable file ",
      basename(path), " (", conditionMessage(checkpoint), ")",
      call. = FALSE
    )
  }
  mfrmr_tit_validate_checkpoint(checkpoint, row, identity)
  checkpoint
}

mfrmr_tit_result_hash <- function(result) {
  ledger <- result$CheckpointLedger[, c(
    "DatasetId", "CheckpointFile", "CheckpointSHA256"
  ), drop = FALSE]
  mfrmr_tif_hash_object(list(
    ContractVersion = result$ContractVersion,
    Tier = result$Tier,
    ExecutionIdentity = result$ExecutionIdentity,
    Manifest = result$Manifest,
    Datasets = result$Datasets,
    DesignAudit = result$DesignAudit,
    GraphAudit = result$GraphAudit,
    DroppedBridgeMap = result$DroppedBridgeMap,
    Modes = result$Modes,
    Metrics = result$Metrics,
    Summary = result$Summary,
    CheckpointLedger = ledger,
    ContractPassed = result$ContractPassed,
    EvidenceReady = result$EvidenceReady
  ))
}

mfrmr_run_tam_immer_jml_topology_calibration <- function(
    tier = c("smoke", "pilot"), dry_run = FALSE,
    authorize_pilot = FALSE, progress = interactive(),
    checkpoint_dir = NULL, resume = FALSE, interrupt_after_new = NULL) {
  tier <- match.arg(tier)
  manifest <- mfrmr_tit_manifest(tier)
  if (isTRUE(dry_run)) return(manifest)
  if (identical(tier, "pilot") && !isTRUE(authorize_pilot)) {
    stop(
      "The Draft.79 replicated topology pilot requires ",
      "`authorize_pilot = TRUE`.", call. = FALSE
    )
  }
  if (identical(tier, "pilot") && is.null(checkpoint_dir)) {
    stop("The Draft.79 pilot requires a checkpoint directory.", call. = FALSE)
  }
  if (isTRUE(resume) && is.null(checkpoint_dir)) {
    stop("`resume = TRUE` requires `checkpoint_dir`.", call. = FALSE)
  }
  mfrmr_tit_require()
  identity <- mfrmr_tit_execution_identity(tier, manifest)
  checkpoint_paths <- rep(NA_character_, nrow(manifest))
  marker_path <- NA_character_
  if (!is.null(checkpoint_dir)) {
    dir.create(checkpoint_dir, recursive = TRUE, showWarnings = FALSE)
    checkpoint_paths <- vapply(
      manifest$DatasetId,
      function(id) mfrmr_tit_checkpoint_path(checkpoint_dir, id),
      character(1)
    )
    marker_path <- file.path(checkpoint_dir, "completion-marker.rds")
    found <- list.files(checkpoint_dir, pattern = "[.]rds$", full.names = TRUE)
    unexpected <- setdiff(
      basename(found), c(basename(checkpoint_paths), basename(marker_path))
    )
    if (length(unexpected) > 0L) {
      stop(
        "Unexpected topology checkpoint artifact(s): ",
        paste(sort(unexpected), collapse = ", "), call. = FALSE
      )
    }
    existing <- checkpoint_paths[file.exists(checkpoint_paths)]
    if ((length(existing) > 0L || file.exists(marker_path)) &&
        !isTRUE(resume)) {
      stop(
        "Existing topology artifacts require `resume = TRUE`; ",
        "refusing to mix runs.", call. = FALSE
      )
    }
    if (file.exists(marker_path) && !all(file.exists(checkpoint_paths))) {
      stop(
        "Topology completion marker exists without every checkpoint.",
        call. = FALSE
      )
    }
  }
  if (!is.null(interrupt_after_new)) {
    if (is.null(checkpoint_dir) || length(interrupt_after_new) != 1L ||
        is.na(interrupt_after_new) || interrupt_after_new < 1L ||
        interrupt_after_new != as.integer(interrupt_after_new)) {
      stop(
        "`interrupt_after_new` requires a checkpoint directory and one ",
        "positive integer.", call. = FALSE
      )
    }
    interrupt_after_new <- as.integer(interrupt_after_new)
  }
  results <- vector("list", nrow(manifest))
  ledger <- vector("list", nrow(manifest))
  new_count <- 0L
  for (i in seq_len(nrow(manifest))) {
    row <- manifest[i, , drop = FALSE]
    if (isTRUE(progress)) {
      message("[", i, "/", nrow(manifest), "] ", row$DatasetId)
    }
    path <- checkpoint_paths[i]
    resumed <- !is.na(path) && file.exists(path)
    if (resumed) {
      checkpoint <- mfrmr_tit_read_checkpoint(path, row, identity)
      result <- checkpoint$Result
    } else {
      result <- mfrmr_tit_run_cell(row)
      if (!is.na(path)) {
        checkpoint <- mfrmr_tit_checkpoint(row, result, identity)
        mfrmr_tit_validate_checkpoint(checkpoint, row, identity)
        mfrmr_tit_atomic_save_rds(checkpoint, path)
      }
      new_count <- new_count + 1L
    }
    results[[i]] <- result
    ledger[[i]] <- data.frame(
      DatasetId = as.character(row$DatasetId),
      Source = if (resumed) "resumed_checkpoint" else "executed",
      CheckpointFile = if (is.na(path)) NA_character_ else basename(path),
      CheckpointSHA256 = if (is.na(path)) NA_character_ else {
        mfrmr_tif_hash_file(path)
      },
      stringsAsFactors = FALSE
    )
    if (!resumed && !is.null(interrupt_after_new) &&
        new_count >= interrupt_after_new) {
      stop(
        "Intentional topology interruption after ", new_count,
        " new dataset checkpoint(s).", call. = FALSE
      )
    }
  }
  datasets <- dplyr::bind_rows(lapply(results, `[[`, "Dataset"))
  audits <- dplyr::bind_rows(lapply(results, `[[`, "Audit"))
  graph_audits <- dplyr::bind_rows(lapply(results, `[[`, "GraphAudit"))
  dropped <- dplyr::bind_rows(lapply(results, `[[`, "DroppedBridgeMap"))
  modes <- dplyr::bind_rows(lapply(results, `[[`, "Modes"))
  metrics <- dplyr::bind_rows(lapply(results, `[[`, "Metrics"))
  outputs <- lapply(results, `[[`, "Output")
  ledger <- dplyr::bind_rows(ledger)
  summary <- if (nrow(metrics) == 0L) tibble::tibble() else metrics |>
    dplyr::group_by(
      .data$Model, .data$ProfileId, .data$FactorBlock,
      .data$Topology, .data$BridgePersons,
      .data$ModeId, .data$Facet, .data$Metric
    ) |>
    dplyr::summarise(
      PlannedRows = dplyr::n(), EligibleRows = sum(.data$Eligible),
      Mean = if (!any(.data$Eligible) ||
                  all(is.na(.data$Value[.data$Eligible]))) {
        NA_real_
      } else {
        mean(.data$Value[.data$Eligible], na.rm = TRUE)
      },
      .groups = "drop"
    )
  assigned <- graph_audits[
    graph_audits$Stage == "Assigned", , drop = FALSE
  ]
  assigned <- assigned[match(manifest$DatasetId, assigned$DatasetId), ]
  observed <- graph_audits[
    graph_audits$Stage == "Observed", , drop = FALSE
  ]
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
    identical(as.logical(assigned$RaterGraphConnected),
              as.logical(manifest$ExpectedAssignedConnected)) &&
    identical(as.logical(observed$RaterGraphConnected),
              as.logical(manifest$ExpectedObservedConnected)) &&
    nrow(metrics) > 0L && all(metrics$EvidenceReady == FALSE)
  result <- list(
    ContractVersion = "mfrmr-tam-immer-jml-topology-calibration-v1",
    Tier = tier, RuntimeIdentity = identity$RuntimeIdentity,
    ExecutionIdentity = identity, Manifest = manifest,
    Datasets = datasets, DesignAudit = audits,
    GraphAudit = graph_audits, DroppedBridgeMap = dropped,
    Modes = modes, Metrics = metrics, Summary = summary,
    Outputs = outputs, CheckpointLedger = ledger,
    ResumedDatasets = sum(ledger$Source == "resumed_checkpoint"),
    ContractPassed = isTRUE(contract_passed), EvidenceReady = FALSE,
    ReadinessEffect = "none_topology_calibration_only"
  )
  if (!is.na(marker_path)) {
    ledger_identity <- ledger[, c(
      "DatasetId", "CheckpointFile", "CheckpointSHA256"
    ), drop = FALSE]
    marker <- structure(
      list(
        Schema = mfrmr_tit_checkpoint_schema(),
        ExecutionSHA256 = identity$ExecutionSHA256,
        ManifestSHA256 = identity$ManifestSHA256,
        CheckpointLedgerSHA256 = mfrmr_tif_hash_object(ledger_identity),
        ResultSHA256 = mfrmr_tit_result_hash(result),
        CompletedUTC = format(Sys.time(), tz = "UTC", usetz = TRUE)
      ),
      class = "mfrmr_tit_completion_marker"
    )
    if (file.exists(marker_path)) {
      existing_marker <- tryCatch(readRDS(marker_path), error = function(e) e)
      valid <- !inherits(existing_marker, "error") &&
        inherits(existing_marker, "mfrmr_tit_completion_marker") &&
        identical(existing_marker$Schema, marker$Schema) &&
        identical(existing_marker$ExecutionSHA256,
                  marker$ExecutionSHA256) &&
        identical(existing_marker$ManifestSHA256, marker$ManifestSHA256) &&
        identical(existing_marker$CheckpointLedgerSHA256,
                  marker$CheckpointLedgerSHA256) &&
        identical(existing_marker$ResultSHA256, marker$ResultSHA256)
      if (!valid) {
        stop("Topology completion marker validation failed.", call. = FALSE)
      }
      marker <- existing_marker
    } else {
      mfrmr_tit_atomic_save_rds(marker, marker_path)
    }
    result$CompletionMarker <- marker
    result$CompletionMarkerSHA256 <- mfrmr_tif_hash_file(marker_path)
  } else {
    result$CompletionMarker <- NULL
    result$CompletionMarkerSHA256 <- NA_character_
  }
  result
}
