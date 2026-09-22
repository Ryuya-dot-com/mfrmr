# mfrmr 0.2.3 repository-only ConQuest polytomous RSM/PCM node-ladder pilot
#
# This runner prepares one fixed four-category item-only latent-regression
# fixture for matched RSM and PCM node ladders, then reviews native ConQuest
# output and same-platform q=31 repeats.
# It deliberately does not launch ConQuest, freeze a tolerance, authorize
# model selection, or turn same-platform pilot agreement into confirmation.
#
# From the repository root:
#
#   pkgload::load_all(".")
#   source("inst/validation/conquest-polytomous-rsm-pcm-pilot-0.2.3.R")
#   prepared <- mfrmr_prepare_conquest_polytomous_pilot(tempfile())
#   # Run each generated .cqc file separately and capture the complete console
#   # stream at the ExpectedConsoleLog path listed in prepared$commands.
#   reviewed <- mfrmr_review_conquest_polytomous_pilot(prepared$output_dir)

mfrmr_cq_poly_specification <- "0.2.3-draft.11"
mfrmr_cq_poly_contract <- "mfrmr_conquest_polytomous_rsm_pcm_ladder_v1"

mfrmr_cq_poly_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_poly_plan <- function() {
  suffix <- c("q007", "q015", "q031a", "q061", "q091", "q121", "q031b")
  nodes <- c(7L, 15L, 31L, 61L, 91L, 121L, 31L)
  tier <- c(
    "coarse_screening", "intermediate_review", "standard_start",
    "dense_sensitivity", "dense_sensitivity", "dense_sensitivity",
    "same_platform_replication"
  )
  model <- rep(c("RSM", "PCM"), each = length(suffix))
  run_suffix <- rep(suffix, times = 2L)
  run_nodes <- rep(nodes, times = 2L)
  data.frame(
    RunId = paste0(tolower(model), "_", run_suffix),
    Model = model,
    MfrmrStepFacet = ifelse(model == "RSM", "", "Item"),
    ConQuestModel = ifelse(
      model == "RSM", "item + step", "item + item*step"
    ),
    Nodes = run_nodes,
    ExpectedNpar = ifelse(model == "RSM", 9L, 17L),
    IntegrationTier = rep(tier, times = 2L),
    EvidenceRole = ifelse(
      run_suffix == "q031b",
      "same_platform_replication",
      "polytomous_node_ladder_pilot"
    ),
    CoreCandidate = run_nodes %in% c(31L, 61L, 91L, 121L) &
      run_suffix != "q031b",
    ReplicateGroup = ifelse(
      run_suffix %in% c("q031a", "q031b"),
      paste0(tolower(model), "_q31"),
      NA_character_
    ),
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_poly_loaded_namespace <- function() {
  if (!requireNamespace("mfrmr", quietly = TRUE)) {
    stop(
      "Load the mfrmr working-tree source before running the ConQuest polytomous pilot.",
      call. = FALSE
    )
  }
  namespace <- asNamespace("mfrmr")
  required <- c("with_preserved_rng_seed", "mfrm_ic_common_panel")
  available <- vapply(
    required,
    exists,
    logical(1),
    envir = namespace,
    inherits = FALSE
  )
  if (!all(available)) {
    stop(
      "The loaded mfrmr namespace is not the 0.2.3 working-tree source; use pkgload::load_all('.').",
      call. = FALSE
    )
  }
  namespace
}

mfrmr_cq_poly_fixture <- function(seed = 20260727L) {
  namespace <- mfrmr_cq_poly_loaded_namespace()
  preserve_seed <- get("with_preserved_rng_seed", envir = namespace)
  preserve_seed(as.integer(seed), {
    persons <- sprintf("P%03d", seq_len(120L))
    items <- sprintf("I%03d", seq_len(5L))
    x <- seq(-1.6, 1.6, length.out = length(persons))
    theta <- 0.15 + 0.65 * x +
      stats::rnorm(length(persons), sd = sqrt(0.45))
    item_effect <- c(-0.80, -0.35, 0, 0.35, 0.80)
    step_matrix <- rbind(
      c(-1.40, -0.10, 1.50),
      c(-1.10, -0.20, 1.30),
      c(-0.90,  0.00, 0.90),
      c(-1.30,  0.20, 1.10),
      c(-0.70, -0.10, 0.80)
    )

    long <- expand.grid(
      Person = persons,
      Item = items,
      stringsAsFactors = FALSE
    )
    item_index <- match(long$Item, items)
    eta <- theta[match(long$Person, persons)] - item_effect[item_index]
    log_kernel <- t(vapply(seq_len(nrow(long)), function(index) {
      value <- (0:3) * eta[index] -
        c(0, cumsum(step_matrix[item_index[index], ]))
      value - max(value)
    }, numeric(4L)))
    probability <- exp(log_kernel)
    probability <- probability / rowSums(probability)
    long$Score <- vapply(seq_len(nrow(long)), function(index) {
      sample.int(4L, size = 1L, prob = probability[index, ]) - 1L
    }, integer(1L))

    category_counts <- as.data.frame(
      table(
        Item = factor(long$Item, levels = items),
        Score = factor(long$Score, levels = 0:3)
      ),
      stringsAsFactors = FALSE
    )
    category_counts$Item <- as.character(category_counts$Item)
    category_counts$Score <- as.integer(as.character(category_counts$Score))
    mfrmr_cq_poly_assert(
      nrow(category_counts) == length(items) * 4L &&
        all(category_counts$Freq > 0L),
      "The fixed PCM-generating fixture must contain every category 0:3 for every item."
    )

    score_matrix <- matrix(
      long$Score,
      nrow = length(persons),
      ncol = length(items),
      dimnames = list(persons, items)
    )
    person_data <- data.frame(
      Person = persons,
      X = x,
      stringsAsFactors = FALSE
    )
    wide <- data.frame(
      person_data,
      score_matrix,
      check.names = FALSE,
      stringsAsFactors = FALSE
    )
    mfrmr_cq_poly_assert(
      identical(as.character(wide$Person), persons) &&
        identical(names(wide), c("Person", "X", items)),
      "The fixed polytomous fixture did not retain its declared wide-data order."
    )

    list(
      seed = as.integer(seed),
      persons = persons,
      items = items,
      long = long,
      wide = wide,
      person_data = person_data,
      category_counts = category_counts,
      generating_model = "PCM",
      generating_item_effects = stats::setNames(item_effect, items),
      generating_steps = step_matrix
    )
  })
}

mfrmr_cq_poly_expected_parameter_labels <- function(model, items) {
  model <- toupper(as.character(model)[1])
  items <- tolower(as.character(items))
  item_labels <- paste("item", items[-length(items)])
  if (identical(model, "RSM")) {
    return(c(item_labels, "category 1", "category 2"))
  }
  if (!identical(model, "PCM")) {
    stop("The polytomous pilot model must be RSM or PCM.", call. = FALSE)
  }
  step_labels <- unlist(lapply(items, function(item) {
    paste("item", item, "category", 1:2)
  }), use.names = FALSE)
  c(item_labels, step_labels)
}

mfrmr_cq_poly_fit_nodes <- function(fit) {
  node_candidates <- suppressWarnings(as.integer(c(
    fit$config$quad_points,
    fit$config$estimation_control$quad_points,
    fit$config$replay_inputs$quad_points
  )))
  node_candidates <- unique(node_candidates[is.finite(node_candidates)])
  nodes <- node_candidates[1]
  mfrmr_cq_poly_assert(
    length(node_candidates) == 1L && length(nodes) == 1L &&
      is.finite(nodes) && nodes > 0L,
    "The mfrmr fit does not retain one unambiguous quadrature-node count."
  )
  nodes
}

mfrmr_cq_poly_reference <- function(fit, model, items) {
  model <- toupper(as.character(model)[1])
  items <- as.character(items)
  fit_summary <- as.data.frame(fit$summary, stringsAsFactors = FALSE)
  mfrmr_cq_poly_assert(nrow(fit_summary) > 0L, "The mfrmr fit has no summary row.")
  fit_summary <- fit_summary[1, , drop = FALSE]
  nodes <- mfrmr_cq_poly_fit_nodes(fit)

  population <- fit$population
  beta <- as.numeric(population$coefficients[c("(Intercept)", "X")])
  mfrmr_cq_poly_assert(
    length(beta) == 2L && all(is.finite(beta)) &&
      is.finite(as.numeric(population$sigma2)),
    "The polytomous pilot requires finite intercept, X, and variance estimates."
  )

  item_table <- as.data.frame(fit$facets$others, stringsAsFactors = FALSE)
  item_table <- item_table[item_table$Facet == "Item", , drop = FALSE]
  item_table <- item_table[match(items, as.character(item_table$Level)), , drop = FALSE]
  item_estimate <- as.numeric(item_table$Estimate)
  mfrmr_cq_poly_assert(
    length(item_estimate) == length(items) && all(is.finite(item_estimate)),
    "The mfrmr item estimates do not match the fixed fixture."
  )

  step_table <- as.data.frame(fit$steps, stringsAsFactors = FALSE)
  if (identical(model, "RSM")) {
    step_table <- step_table[match(
      paste0("Step_", 1:3), as.character(step_table$Step)
    ), , drop = FALSE]
    step_free <- as.numeric(step_table$Estimate[1:2])
    step_rows <- data.frame(
      Component = "Step",
      Group = "shared",
      Coordinate = paste0("Step_", 1:3),
      Estimate = as.numeric(step_table$Estimate),
      ConstraintRole = c("free", "free", "derived_sum_zero"),
      stringsAsFactors = FALSE
    )
  } else {
    mfrmr_cq_poly_assert(
      identical(model, "PCM") &&
        all(c("StepFacet", "Step", "Estimate") %in% names(step_table)),
      "The PCM fit does not expose the expected item-specific step table."
    )
    ordered_rows <- unlist(lapply(items, function(item) {
      match(
        paste(item, paste0("Step_", 1:3), sep = "\r"),
        paste(step_table$StepFacet, step_table$Step, sep = "\r")
      )
    }), use.names = FALSE)
    mfrmr_cq_poly_assert(!anyNA(ordered_rows), "The PCM step table is incomplete.")
    step_table <- step_table[ordered_rows, , drop = FALSE]
    step_free <- unlist(lapply(split(
      as.numeric(step_table$Estimate),
      factor(step_table$StepFacet, levels = items)
    ), function(value) value[1:2]), use.names = FALSE)
    step_rows <- data.frame(
      Component = "Step",
      Group = rep(items, each = 3L),
      Coordinate = rep(paste0("Step_", 1:3), times = length(items)),
      Estimate = as.numeric(step_table$Estimate),
      ConstraintRole = rep(c("free", "free", "derived_sum_zero"), times = length(items)),
      stringsAsFactors = FALSE
    )
  }

  parameter_labels <- mfrmr_cq_poly_expected_parameter_labels(model, items)
  free <- data.frame(
    FreeOrder = seq_len(3L + length(items) - 1L + length(step_free)),
    Component = c(
      "Regression", "Regression", "Covariance",
      rep("Item", length(items) - 1L),
      rep("Step", length(step_free))
    ),
    Group = c(
      "Dimension_1", "Dimension_1", "Dimension_1",
      rep("Item", length(items) - 1L),
      if (identical(model, "RSM")) {
        rep("shared", length(step_free))
      } else {
        rep(items, each = 2L)
      }
    ),
    Coordinate = c(
      "Intercept", "X", "Variance",
      items[-length(items)],
      if (identical(model, "RSM")) {
        paste0("Step_", 1:2)
      } else {
        rep(paste0("Step_", 1:2), times = length(items))
      }
    ),
    NativeLabel = c(
      "regression intercept", "regression X", "conditional variance",
      parameter_labels
    ),
    Estimate = c(
      beta,
      as.numeric(population$sigma2),
      item_estimate[-length(item_estimate)],
      step_free
    ),
    stringsAsFactors = FALSE
  )

  full <- rbind(
    data.frame(
      Component = "Item",
      Group = "Item",
      Coordinate = items,
      Estimate = item_estimate,
      ConstraintRole = c(
        rep("free", length(items) - 1L), "derived_sum_zero"
      ),
      stringsAsFactors = FALSE
    ),
    step_rows
  )
  expected_npar <- if (identical(model, "RSM")) 9L else 17L
  mfrmr_cq_poly_assert(
    nrow(free) == expected_npar &&
      as.integer(fit_summary$Npar) == expected_npar,
    "The mfrmr free dimension does not match the prespecified RSM/PCM pilot."
  )
  mfrmr_cq_poly_assert(
    abs(sum(item_estimate)) < 1e-8 &&
      if (identical(model, "RSM")) {
        abs(sum(step_rows$Estimate)) < 1e-8
      } else {
        all(abs(rowsum(step_rows$Estimate, step_rows$Group)[, 1]) < 1e-8)
      },
    "The mfrmr item or step estimates do not satisfy the declared sum-zero constraints."
  )

  summary <- data.frame(
    Specification = mfrmr_cq_poly_specification,
    ContractVersion = mfrmr_cq_poly_contract,
    Model = model,
    Nodes = nodes,
    MfrmrDeviance = as.numeric(fit_summary$Deviance),
    MfrmrLogLik = as.numeric(fit_summary$LogLik),
    MfrmrNpar = as.integer(fit_summary$Npar),
    Persons = as.integer(fit_summary$Persons),
    MfrmrMaxit = 2000L,
    MfrmrReltol = 1e-12,
    MfrmrTerminalGradientSupNorm = as.numeric(
      fit_summary$TerminalGradientSupNorm
    ),
    MfrmrInferenceReady = isTRUE(fit_summary$InferenceReady),
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  list(summary = summary, free = free, full = full)
}

mfrmr_cq_poly_command <- function(prefix, conquest_model, items, nodes = 31L) {
  nodes <- suppressWarnings(as.integer(nodes[1]))
  mfrmr_cq_poly_assert(
    length(nodes) == 1L && is.finite(nodes) && nodes > 0L,
    "`nodes` must be one positive integer."
  )
  response_spec <- paste0(items[1], " to ", items[length(items)])
  c(
    paste0("export logfile >> ", prefix, "_conquest_internal.log;"),
    paste0(
      "datafile ", prefix,
      "_wide.csv ! filetype=csv, columnlabels=yes, pid=Person, pidwidth=32, responses=",
      response_spec,
      ", keeps=X, keepswidth=32;"
    ),
    "codes 0,1,2,3;",
    "regression X;",
    paste0("model ", conquest_model, ";"),
    paste0(
      "estimate ! method=quadrature, nodes=", nodes,
      ", fit=no, stderr=quick, ",
      "matrixout=mfrmrCQ, convergence=0.00000001, ",
      "deviancechange=0.0000000001, iterations=2000;"
    ),
    paste0("export parameters ! filetype=csv >> ", prefix, "_conquest_parameters.csv;"),
    paste0("export reg_coefficients ! filetype=csv >> ", prefix, "_conquest_reg_coefficients.csv;"),
    paste0("export covariance ! filetype=csv >> ", prefix, "_conquest_covariance.csv;"),
    paste0("show cases ! estimates=eap, filetype=csv, regressors=yes >> ", prefix, "_conquest_cases_eap.csv;"),
    paste0("write mfrmrCQ_history ! filetype=csv >> ", prefix, "_conquest_history.csv;"),
    paste0("show parameters ! tables=1:2:3:4, estimates=eap >> ", prefix, "_conquest_parameters_review.txt;"),
    "quit;"
  )
}

mfrmr_prepare_conquest_polytomous_pilot <- function(output_dir) {
  mfrmr_cq_poly_loaded_namespace()
  output_dir <- normalizePath(
    as.character(output_dir)[1], winslash = "/", mustWork = FALSE
  )
  mfrmr_cq_poly_assert(
    !is.na(output_dir) && nzchar(output_dir),
    "`output_dir` must be one non-empty path."
  )
  if (dir.exists(output_dir) &&
      length(list.files(output_dir, all.files = TRUE, no.. = TRUE)) > 0L) {
    stop(
      "The ConQuest polytomous output directory must be absent or empty; use a new restricted directory for every pilot.",
      call. = FALSE
    )
  }
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  mfrmr_cq_poly_assert(
    dir.exists(output_dir),
    "The ConQuest polytomous output directory could not be created."
  )

  fixture <- mfrmr_cq_poly_fixture()
  plan <- mfrmr_cq_poly_plan()
  fit_fun <- getExportedValue("mfrmr", "fit_mfrm")
  manifest_rows <- vector("list", nrow(plan))

  for (index in seq_len(nrow(plan))) {
    row <- plan[index, , drop = FALSE]
    run_dir <- file.path(output_dir, row$RunId)
    dir.create(run_dir, recursive = TRUE, showWarnings = FALSE)
    prefix <- paste0("cq_", row$RunId)

    fit_args <- list(
      data = fixture$long,
      person = "Person",
      facets = "Item",
      score = "Score",
      rating_min = 0,
      rating_max = 3,
      method = "MML",
      model = row$Model,
      population_formula = ~ X,
      person_data = fixture$person_data,
      quad_points = row$Nodes,
      maxit = 2000L,
      reltol = 1e-12,
      mml_engine = "direct"
    )
    if (identical(row$Model, "PCM")) fit_args$step_facet <- "Item"
    fit <- suppressWarnings(do.call(fit_fun, fit_args))
    reference <- mfrmr_cq_poly_reference(
      fit = fit,
      model = row$Model,
      items = fixture$items
    )
    mfrmr_cq_poly_assert(
      isTRUE(reference$summary$MfrmrInferenceReady),
      paste0("The strict mfrmr ", row$Model, " pilot fit is not inference-ready.")
    )

    wide_file <- file.path(run_dir, paste0(prefix, "_wide.csv"))
    long_file <- file.path(run_dir, paste0(prefix, "_long.csv"))
    person_file <- file.path(run_dir, paste0(prefix, "_person_data.csv"))
    count_file <- file.path(run_dir, paste0(prefix, "_category_counts.csv"))
    summary_file <- file.path(run_dir, paste0(prefix, "_mfrmr_summary.csv"))
    free_file <- file.path(run_dir, paste0(prefix, "_mfrmr_free_parameters.csv"))
    full_file <- file.path(run_dir, paste0(prefix, "_mfrmr_full_parameters.csv"))
    command_file <- file.path(run_dir, paste0(prefix, ".cqc"))

    utils::write.csv(fixture$wide, wide_file, row.names = FALSE, na = "")
    utils::write.csv(fixture$long, long_file, row.names = FALSE, na = "")
    utils::write.csv(fixture$person_data, person_file, row.names = FALSE, na = "")
    utils::write.csv(fixture$category_counts, count_file, row.names = FALSE, na = "")
    utils::write.csv(reference$summary, summary_file, row.names = FALSE, na = "")
    utils::write.csv(reference$free, free_file, row.names = FALSE, na = "")
    utils::write.csv(reference$full, full_file, row.names = FALSE, na = "")
    writeLines(
      mfrmr_cq_poly_command(
        prefix, row$ConQuestModel, fixture$items, nodes = row$Nodes
      ),
      command_file,
      useBytes = TRUE
    )

    manifest_rows[[index]] <- data.frame(
      Specification = mfrmr_cq_poly_specification,
      ContractVersion = mfrmr_cq_poly_contract,
      RunId = row$RunId,
      Model = row$Model,
      Nodes = row$Nodes,
      ExpectedNpar = row$ExpectedNpar,
      ConQuestModel = row$ConQuestModel,
      IntegrationTier = row$IntegrationTier,
      EvidenceRole = row$EvidenceRole,
      CoreCandidate = row$CoreCandidate,
      ReplicateGroup = row$ReplicateGroup,
      RunDirectory = row$RunId,
      Prefix = prefix,
      CommandFile = file.path(row$RunId, basename(command_file)),
      ExpectedConsoleLog = file.path(
        row$RunId, paste0(prefix, "_console.log")
      ),
      WideFile = file.path(row$RunId, basename(wide_file)),
      WideMD5 = unname(tools::md5sum(wide_file)),
      CommandMD5 = unname(tools::md5sum(command_file)),
      MfrmrDeviance = reference$summary$MfrmrDeviance,
      MfrmrNpar = reference$summary$MfrmrNpar,
      MfrmrTerminalGradientSupNorm =
        reference$summary$MfrmrTerminalGradientSupNorm,
      MfrmrInferenceReady = reference$summary$MfrmrInferenceReady,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }

  manifest <- do.call(rbind, manifest_rows)
  mfrmr_cq_poly_assert(
    length(unique(manifest$WideMD5)) == 1L,
    "The RSM and PCM ladder rows did not retain byte-identical input data."
  )
  manifest_file <- file.path(
    output_dir, "conquest_polytomous_rsm_pcm_manifest.csv"
  )
  utils::write.csv(manifest, manifest_file, row.names = FALSE, na = "")
  commands <- manifest[, c(
    "RunId", "Model", "Nodes", "IntegrationTier", "EvidenceRole",
    "RunDirectory", "CommandFile", "ExpectedConsoleLog"
  ), drop = FALSE]
  out <- list(
    specification = mfrmr_cq_poly_specification,
    contract_version = mfrmr_cq_poly_contract,
    status = "prepared_external_execution_required",
    selection_authorized = FALSE,
    confirmation_authorized = FALSE,
    output_dir = output_dir,
    manifest_file = manifest_file,
    plan = plan,
    manifest = manifest,
    commands = commands,
    category_counts = fixture$category_counts,
    notes = c(
      "This repository-only helper never executes ConQuest.",
      "Capture the complete ConQuest console stream at ExpectedConsoleLog; the internal ConQuest logfile is supplementary and does not replace it.",
      "Every generated run directory contains Person identifiers, responses, covariates, and case-level outputs; do not commit or share it without review.",
      "The fixture is generated once from a fixed PCM mechanism and fitted as both RSM and PCM across q=7, 15, 31, 61, 91, and 121; q=31 is repeated independently within each family.",
      "The ladder is same-platform pilot evidence only and is not a model-selection exercise."
    )
  )
  class(out) <- c("mfrmr_conquest_polytomous_preparation", class(out))
  out
}

mfrmr_cq_poly_file_set <- function(output_dir, manifest_row) {
  run_dir <- file.path(output_dir, manifest_row$RunDirectory)
  prefix <- as.character(manifest_row$Prefix)
  path <- function(suffix) file.path(run_dir, paste0(prefix, suffix))
  list(
    run_dir = run_dir,
    console = path("_console.log"),
    wide = path("_wide.csv"),
    category_counts = path("_category_counts.csv"),
    summary = path("_mfrmr_summary.csv"),
    free = path("_mfrmr_free_parameters.csv"),
    full = path("_mfrmr_full_parameters.csv"),
    history = path("_conquest_history.csv"),
    parameter = path("_conquest_parameters.csv"),
    regression = path("_conquest_reg_coefficients.csv"),
    covariance = path("_conquest_covariance.csv"),
    cases = path("_conquest_cases_eap.csv")
  )
}

mfrmr_cq_poly_reconstruct_full <- function(model, parameter_estimate, items) {
  model <- toupper(as.character(model)[1])
  parameter_estimate <- as.numeric(parameter_estimate)
  items <- as.character(items)
  item_free_n <- length(items) - 1L
  item_free <- parameter_estimate[seq_len(item_free_n)]
  item_full <- c(item_free, -sum(item_free))
  parameter_step <- parameter_estimate[-seq_len(item_free_n)]

  if (identical(model, "RSM")) {
    mfrmr_cq_poly_assert(
      length(parameter_step) == 2L,
      "The ConQuest RSM free-step vector must contain two coordinates."
    )
    step_full <- c(parameter_step, -sum(parameter_step))
    step_rows <- data.frame(
      Component = "Step",
      Group = "shared",
      Coordinate = paste0("Step_", 1:3),
      Estimate = step_full,
      stringsAsFactors = FALSE
    )
    constraint_residual <- max(abs(sum(item_full)), abs(sum(step_full)))
  } else {
    mfrmr_cq_poly_assert(
      identical(model, "PCM") && length(parameter_step) == length(items) * 2L,
      "The ConQuest PCM free-step vector must contain two coordinates per item."
    )
    step_free_matrix <- matrix(
      parameter_step,
      nrow = length(items),
      ncol = 2L,
      byrow = TRUE
    )
    step_rows <- do.call(rbind, lapply(seq_along(items), function(index) {
      value <- c(
        step_free_matrix[index, ],
        -sum(step_free_matrix[index, ])
      )
      data.frame(
        Component = "Step",
        Group = items[index],
        Coordinate = paste0("Step_", 1:3),
        Estimate = value,
        stringsAsFactors = FALSE
      )
    }))
    step_sums <- rowsum(step_rows$Estimate, step_rows$Group)[, 1]
    constraint_residual <- max(abs(c(sum(item_full), step_sums)))
  }

  table <- rbind(
    data.frame(
      Component = "Item",
      Group = "Item",
      Coordinate = items,
      Estimate = item_full,
      stringsAsFactors = FALSE
    ),
    step_rows
  )
  list(table = table, max_constraint_residual = constraint_residual)
}

mfrmr_cq_poly_empty_result <- function(manifest_row, status, reason) {
  data.frame(
    Specification = mfrmr_cq_poly_specification,
    ContractVersion = mfrmr_cq_poly_contract,
    RunId = as.character(manifest_row$RunId),
    Model = as.character(manifest_row$Model),
    Nodes = as.integer(manifest_row$Nodes),
    IntegrationTier = as.character(manifest_row$IntegrationTier),
    EvidenceRole = as.character(manifest_row$EvidenceRole),
    CoreCandidate = isTRUE(manifest_row$CoreCandidate),
    ReplicateGroup = as.character(manifest_row$ReplicateGroup),
    InputMD5 = as.character(manifest_row$WideMD5),
    ExecutionComplete = FALSE,
    DevianceTerminationObserved = FALSE,
    ParameterTerminationObserved = FALSE,
    HigherLikelihoodRetained = FALSE,
    CategoryCoveragePass = FALSE,
    NativeParameterLabelsMatched = FALSE,
    AdapterStatus = as.character(status),
    AdapterReason = as.character(reason),
    ConQuestDeviance = NA_real_,
    MfrmrDeviance = as.numeric(manifest_row$MfrmrDeviance),
    CrossEngineDevianceDifference = NA_real_,
    MaxFreeParameterAbsDifference = NA_real_,
    MaxFullParameterAbsDifference = NA_real_,
    MaxConstraintResidual = NA_real_,
    HistoryExportMaxAbsDifference = NA_real_,
    HistoryRows = NA_integer_,
    Npar = NA_integer_,
    ExpectedNpar = as.integer(manifest_row$ExpectedNpar),
    Persons = NA_integer_,
    ArithmeticEligible = FALSE,
    ComparisonReady = FALSE,
    NativeOutputFingerprint = NA_character_,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_poly_summarize <- function(results) {
  required <- c(
    "RunId", "Model", "Nodes", "CoreCandidate", "EvidenceRole",
    "ReplicateGroup", "InputMD5", "AdapterStatus",
    "ConQuestDeviance", "MfrmrDeviance",
    "CrossEngineDevianceDifference", "MaxFreeParameterAbsDifference",
    "MaxFullParameterAbsDifference", "MaxConstraintResidual",
    "Npar", "ExpectedNpar", "NativeOutputFingerprint", "ComparisonReady"
  )
  mfrmr_cq_poly_assert(
    is.data.frame(results) && all(required %in% names(results)),
    "`results` does not satisfy the ConQuest polytomous summary contract."
  )
  finite_max_abs <- function(value) {
    value <- suppressWarnings(as.numeric(value))
    value <- value[is.finite(value)]
    if (length(value) == 0L) NA_real_ else max(abs(value))
  }
  finite_range <- function(value) {
    value <- suppressWarnings(as.numeric(value))
    value <- value[is.finite(value)]
    if (length(value) == 0L) NA_real_ else diff(range(value))
  }
  run_status <- function(run_id) {
    value <- as.character(results$AdapterStatus[results$RunId == run_id])
    if (length(value) == 1L) value else NA_character_
  }
  model_npar <- function(model) {
    value <- unique(suppressWarnings(as.numeric(
      results$Npar[
        results$Model == model &
          results$AdapterStatus == "accepted_arithmetic"
      ]
    )))
    value <- value[is.finite(value)]
    if (length(value) == 1L) value else NA_real_
  }
  replication_state <- function(model) {
    group <- paste0(tolower(model), "_q31")
    rows <- results[
      results$Model == model & results$ReplicateGroup %in% group,
      ,
      drop = FALSE
    ]
    list(
      byte_identical = nrow(rows) == 2L &&
        all(rows$AdapterStatus == "accepted_arithmetic") &&
        all(!is.na(rows$NativeOutputFingerprint)) &&
        length(unique(rows$NativeOutputFingerprint)) == 1L,
      deviance_identical = nrow(rows) == 2L &&
        all(is.finite(rows$ConQuestDeviance)) &&
        identical(rows$ConQuestDeviance[1], rows$ConQuestDeviance[2])
    )
  }

  core <- results[results$CoreCandidate %in% TRUE, , drop = FALSE]
  rsm_core <- core[core$Model == "RSM", , drop = FALSE]
  pcm_core <- core[core$Model == "PCM", , drop = FALSE]
  expected_core_nodes <- c(31L, 61L, 91L, 121L)
  rsm_core_nodes_matched <- nrow(rsm_core) == 4L && identical(
    sort(unique(as.integer(rsm_core$Nodes))), expected_core_nodes
  )
  pcm_core_nodes_matched <- nrow(pcm_core) == 4L && identical(
    sort(unique(as.integer(pcm_core$Nodes))), expected_core_nodes
  )
  rsm_core_accepted <- rsm_core_nodes_matched &&
    all(rsm_core$AdapterStatus == "accepted_arithmetic")
  pcm_core_accepted <- pcm_core_nodes_matched &&
    all(pcm_core$AdapterStatus == "accepted_arithmetic")
  both_core_accepted <- rsm_core_accepted && pcm_core_accepted
  input_byte_identical <- nrow(results) == nrow(mfrmr_cq_poly_plan()) &&
    all(!is.na(results$InputMD5)) &&
    length(unique(results$InputMD5)) == 1L
  accepted <- results[
    results$AdapterStatus == "accepted_arithmetic", , drop = FALSE
  ]
  npar_matched <- nrow(accepted) > 0L && all(
    is.finite(accepted$Npar) & accepted$Npar == accepted$ExpectedNpar
  )
  rsm_replication <- replication_state("RSM")
  pcm_replication <- replication_state("PCM")

  primary_core <- core[
    core$EvidenceRole == "polytomous_node_ladder_pilot",
    ,
    drop = FALSE
  ]
  rsm_pair <- primary_core[
    primary_core$Model == "RSM",
    c("Nodes", "ConQuestDeviance", "MfrmrDeviance"),
    drop = FALSE
  ]
  pcm_pair <- primary_core[
    primary_core$Model == "PCM",
    c("Nodes", "ConQuestDeviance", "MfrmrDeviance"),
    drop = FALSE
  ]
  names(rsm_pair)[-1] <- paste0("RSM_", names(rsm_pair)[-1])
  names(pcm_pair)[-1] <- paste0("PCM_", names(pcm_pair)[-1])
  paired <- merge(rsm_pair, pcm_pair, by = "Nodes", sort = TRUE)
  cq_drop <- paired$RSM_ConQuestDeviance - paired$PCM_ConQuestDeviance
  mfrmr_drop <- paired$RSM_MfrmrDeviance - paired$PCM_MfrmrDeviance
  drop_difference <- cq_drop - mfrmr_drop
  ladder_complete <- input_byte_identical && both_core_accepted &&
    isTRUE(rsm_replication$byte_identical) &&
    isTRUE(pcm_replication$byte_identical) &&
    isTRUE(rsm_replication$deviance_identical) &&
    isTRUE(pcm_replication$deviance_identical)

  data.frame(
    Specification = mfrmr_cq_poly_specification,
    ContractVersion = mfrmr_cq_poly_contract,
    Status = "review",
    InputByteIdentical = input_byte_identical,
    RsmCoreDistinctNodes = length(unique(rsm_core$Nodes)),
    PcmCoreDistinctNodes = length(unique(pcm_core$Nodes)),
    RsmCoreArithmeticAccepted = rsm_core_accepted,
    PcmCoreArithmeticAccepted = pcm_core_accepted,
    BothFamiliesArithmeticAccepted = both_core_accepted,
    FreeDimensionsMatched = npar_matched,
    MaxAbsCrossEngineDevianceDifference = finite_max_abs(
      core$CrossEngineDevianceDifference
    ),
    MaxFreeParameterAbsDifference = finite_max_abs(
      core$MaxFreeParameterAbsDifference
    ),
    MaxFullParameterAbsDifference = finite_max_abs(
      core$MaxFullParameterAbsDifference
    ),
    MaxConstraintResidual = finite_max_abs(core$MaxConstraintResidual),
    RsmCoreConQuestDevianceRange = finite_range(rsm_core$ConQuestDeviance),
    PcmCoreConQuestDevianceRange = finite_range(pcm_core$ConQuestDeviance),
    RsmCoreMfrmrDevianceRange = finite_range(rsm_core$MfrmrDeviance),
    PcmCoreMfrmrDevianceRange = finite_range(pcm_core$MfrmrDeviance),
    MaxAbsRsmPcmDevianceDropDifference = finite_max_abs(drop_difference),
    RsmPcmFreeDimensionDifference =
      model_npar("PCM") - model_npar("RSM"),
    RsmQ31ReplicationByteIdentical = rsm_replication$byte_identical,
    PcmQ31ReplicationByteIdentical = pcm_replication$byte_identical,
    RsmQ31ReplicationDevianceIdentical = rsm_replication$deviance_identical,
    PcmQ31ReplicationDevianceIdentical = pcm_replication$deviance_identical,
    RsmQ7Status = run_status("rsm_q007"),
    RsmQ15Status = run_status("rsm_q015"),
    PcmQ7Status = run_status("pcm_q007"),
    PcmQ15Status = run_status("pcm_q015"),
    ConstraintMappingStatus = if (ladder_complete && npar_matched) {
      "same_platform_ladder_complete"
    } else {
      "review"
    },
    IndependentPlatformStatus = "not_run",
    IntegrationStabilityStatus = "review",
    FreezeCriterionStatus = "pilot_required",
    AnyComparisonReady = any(results$ComparisonReady %in% TRUE),
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_review_conquest_polytomous_pilot <- function(
    output_dir,
    pkg_dir = ".",
    engine_version = "5.47.5 Demonstration Version",
    run_date = Sys.Date(),
    candidate_id = "working-tree-pilot") {
  mfrmr_cq_poly_loaded_namespace()
  output_dir <- normalizePath(
    as.character(output_dir)[1], winslash = "/", mustWork = TRUE
  )
  manifest_file <- file.path(
    output_dir, "conquest_polytomous_rsm_pcm_manifest.csv"
  )
  mfrmr_cq_poly_assert(
    file.exists(manifest_file),
    "The ConQuest polytomous manifest is missing."
  )
  manifest <- utils::read.csv(
    manifest_file, stringsAsFactors = FALSE, check.names = FALSE
  )
  plan <- mfrmr_cq_poly_plan()
  manifest_replicate_group <- as.character(manifest$ReplicateGroup)
  manifest_replicate_group[
    is.na(manifest_replicate_group) | !nzchar(manifest_replicate_group)
  ] <- NA_character_
  mfrmr_cq_poly_assert(
    identical(as.character(manifest$RunId), plan$RunId) &&
      identical(as.character(manifest$Model), plan$Model) &&
      identical(as.integer(manifest$Nodes), plan$Nodes) &&
      identical(as.integer(manifest$ExpectedNpar), plan$ExpectedNpar) &&
      identical(as.character(manifest$IntegrationTier), plan$IntegrationTier) &&
      identical(as.character(manifest$EvidenceRole), plan$EvidenceRole) &&
      identical(as.logical(manifest$CoreCandidate), plan$CoreCandidate) &&
      identical(manifest_replicate_group, plan$ReplicateGroup) &&
      all(!as.logical(manifest$SelectionAuthorized)) &&
      all(!as.logical(manifest$ConfirmationAuthorized)),
    "The ConQuest polytomous manifest does not match the draft.11 plan."
  )
  normalizer_file <- file.path(
    normalizePath(pkg_dir, winslash = "/", mustWork = TRUE),
    "inst", "validation", "external-ic-normalizer-0.2.3.R"
  )
  mfrmr_cq_poly_assert(
    file.exists(normalizer_file),
    "The repository-only external IC normalizer is missing."
  )
  normalizer <- new.env(parent = globalenv())
  sys.source(normalizer_file, envir = normalizer)
  results <- vector("list", nrow(manifest))

  for (index in seq_len(nrow(manifest))) {
    row <- manifest[index, , drop = FALSE]
    files <- mfrmr_cq_poly_file_set(output_dir, row)
    required_paths <- unlist(
      files[c(
        "console", "wide", "category_counts", "summary", "free", "full",
        "history", "parameter", "regression", "covariance", "cases"
      )],
      use.names = FALSE
    )
    missing <- required_paths[!file.exists(required_paths)]
    if (length(missing) > 0L) {
      results[[index]] <- mfrmr_cq_poly_empty_result(
        row,
        status = "not_run",
        reason = paste(
          "Missing required external files:",
          paste(basename(missing), collapse = ", ")
        )
      )
      next
    }
    if (!identical(
      unname(tools::md5sum(files$wide)),
      as.character(row$WideMD5)
    )) {
      results[[index]] <- mfrmr_cq_poly_empty_result(
        row, "rejected", "The reviewed wide CSV does not match the prepared manifest fingerprint."
      )
      next
    }

    console_lines <- readLines(files$console, warn = FALSE)
    execution_complete <- any(grepl(
      "End of Program", console_lines, fixed = TRUE
    ))
    higher_likelihood <- any(grepl(
      "higher likelihood", console_lines, ignore.case = TRUE
    ))
    deviance_termination <- any(grepl(
      "Deviance change is less than convergence criterion",
      console_lines,
      fixed = TRUE
    ))
    parameter_termination <- any(grepl(
      "maximum change in the estimates is less than the convergence criterion",
      console_lines,
      ignore.case = TRUE
    ))
    convergence_pass <- execution_complete && !higher_likelihood &&
      (deviance_termination || parameter_termination)
    convergence_evidence_id <- if (deviance_termination) {
      "conquest_console_deviance_change_termination"
    } else if (parameter_termination) {
      "conquest_console_parameter_change_termination"
    } else if (higher_likelihood) {
      "conquest_console_higher_likelihood_retained_review"
    } else {
      NA_character_
    }

    wide <- utils::read.csv(
      files$wide, stringsAsFactors = FALSE, check.names = FALSE
    )
    counts <- utils::read.csv(
      files$category_counts, stringsAsFactors = FALSE, check.names = FALSE
    )
    reference_summary <- utils::read.csv(
      files$summary, stringsAsFactors = FALSE, check.names = FALSE
    )
    reference_free <- utils::read.csv(
      files$free, stringsAsFactors = FALSE, check.names = FALSE
    )
    reference_full <- utils::read.csv(
      files$full, stringsAsFactors = FALSE, check.names = FALSE
    )
    history <- utils::read.csv(
      files$history, stringsAsFactors = FALSE, check.names = FALSE
    )
    parameter <- utils::read.csv(
      files$parameter, stringsAsFactors = FALSE, check.names = FALSE
    )
    regression <- utils::read.csv(
      files$regression, stringsAsFactors = FALSE, check.names = FALSE
    )
    covariance <- utils::read.csv(
      files$covariance, stringsAsFactors = FALSE, check.names = FALSE
    )
    schema_ok <- nrow(history) > 0L && ncol(history) >= 5L &&
      all(c("P", "Estimate", "Label") %in% names(parameter)) &&
      all(c("Dimension", "Regressor", "Estimate") %in% names(regression)) &&
      all(c("Dim1", "Dim2", "Covariance") %in% names(covariance)) &&
      all(c(
        "FreeOrder", "Component", "Group", "Coordinate", "Estimate"
      ) %in% names(reference_free)) &&
      all(c(
        "Component", "Group", "Coordinate", "Estimate"
      ) %in% names(reference_full)) &&
      nrow(reference_summary) == 1L &&
      "MfrmrDeviance" %in% names(reference_summary)
    if (!schema_ok) {
      result <- mfrmr_cq_poly_empty_result(
        row,
        "rejected",
        "A required native or mfrmr reference table does not satisfy the polytomous pilot schema."
      )
      result$ExecutionComplete <- execution_complete
      result$DevianceTerminationObserved <- deviance_termination
      result$ParameterTerminationObserved <- parameter_termination
      result$HigherLikelihoodRetained <- higher_likelihood
      results[[index]] <- result
      next
    }
    category_coverage <- all(
      c("Item", "Score", "Freq") %in% names(counts)
    ) && nrow(counts) == 20L && all(counts$Freq > 0L)
    items <- names(wide)[-(1:2)]
    expected_labels <- mfrmr_cq_poly_expected_parameter_labels(
      row$Model, items
    )
    observed_labels <- if ("Label" %in% names(parameter)) {
      tolower(trimws(as.character(parameter$Label)))
    } else {
      character(0)
    }
    labels_matched <- identical(observed_labels, expected_labels)
    if (!category_coverage || !labels_matched) {
      reason <- if (!category_coverage) {
        "The four-category-by-item coverage contract failed."
      } else {
        "The native ConQuest parameter labels do not match the audited 5.47.5 RSM/PCM coordinate order."
      }
      result <- mfrmr_cq_poly_empty_result(row, "rejected", reason)
      result$ExecutionComplete <- execution_complete
      result$DevianceTerminationObserved <- deviance_termination
      result$ParameterTerminationObserved <- parameter_termination
      result$HigherLikelihoodRetained <- higher_likelihood
      result$CategoryCoveragePass <- category_coverage
      result$NativeParameterLabelsMatched <- labels_matched
      results[[index]] <- result
      next
    }

    exported_vector <- c(
      as.numeric(regression$Estimate),
      as.numeric(covariance$Covariance),
      as.numeric(parameter$Estimate)
    )
    history_vector <- suppressWarnings(as.numeric(unlist(
      history[nrow(history), seq.int(5L, ncol(history)), drop = FALSE],
      recursive = FALSE,
      use.names = FALSE
    )))
    history_export_difference <- if (
      length(exported_vector) == length(history_vector) &&
      all(is.finite(exported_vector)) && all(is.finite(history_vector))
    ) {
      max(abs(exported_vector - history_vector))
    } else {
      NA_real_
    }
    reference_vector <- as.numeric(
      reference_free$Estimate[order(reference_free$FreeOrder)]
    )
    reference_order_ok <- identical(
      as.integer(sort(reference_free$FreeOrder)),
      seq_len(as.integer(row$ExpectedNpar))
    ) && length(reference_vector) == length(exported_vector)
    if (!reference_order_ok) {
      result <- mfrmr_cq_poly_empty_result(
        row,
        "rejected",
        "The mfrmr reference free-coordinate order or dimension does not match the prepared manifest and native exports."
      )
      result$ExecutionComplete <- execution_complete
      result$DevianceTerminationObserved <- deviance_termination
      result$ParameterTerminationObserved <- parameter_termination
      result$HigherLikelihoodRetained <- higher_likelihood
      result$CategoryCoveragePass <- category_coverage
      result$NativeParameterLabelsMatched <- labels_matched
      results[[index]] <- result
      next
    }
    reconstructed <- tryCatch(
      mfrmr_cq_poly_reconstruct_full(
        row$Model, parameter$Estimate, items
      ),
      error = function(error) error
    )
    if (inherits(reconstructed, "error")) {
      result <- mfrmr_cq_poly_empty_result(
        row, "rejected", conditionMessage(reconstructed)
      )
      result$ExecutionComplete <- execution_complete
      result$CategoryCoveragePass <- category_coverage
      result$NativeParameterLabelsMatched <- labels_matched
      results[[index]] <- result
      next
    }
    full_key <- paste(
      reference_full$Component,
      reference_full$Group,
      reference_full$Coordinate,
      sep = "\r"
    )
    reconstructed_key <- paste(
      reconstructed$table$Component,
      reconstructed$table$Group,
      reconstructed$table$Coordinate,
      sep = "\r"
    )
    full_match <- match(full_key, reconstructed_key)
    if (anyNA(full_match)) {
      result <- mfrmr_cq_poly_empty_result(
        row, "rejected", "The reconstructed ConQuest full-coordinate table does not match the mfrmr reference keys."
      )
      result$ExecutionComplete <- execution_complete
      result$CategoryCoveragePass <- category_coverage
      result$NativeParameterLabelsMatched <- labels_matched
      results[[index]] <- result
      next
    }
    max_full_difference <- max(abs(
      reconstructed$table$Estimate[full_match] - reference_full$Estimate
    ))

    constraint_basis <- if (identical(row$Model, "RSM")) {
      "matched-item-sum-zero-and-shared-step-sum-zero-v1"
    } else {
      "matched-item-sum-zero-and-item-step-row-sum-zero-v1"
    }
    likelihood_basis <- if (identical(row$Model, "RSM")) {
      "matched-adjacent-category-rsm-v1"
    } else {
      "matched-adjacent-category-pcm-v1"
    }
    record <- tryCatch(
      normalizer$mfrmr_external_ic_from_conquest(
        history_file = files$history,
        parameter_file = files$parameter,
        regression_file = files$regression,
        covariance_file = files$covariance,
        case_file = files$cases,
        engine_version = engine_version,
        run_date = run_date,
        run_id = paste0("cq-poly-", row$RunId),
        model_id = paste0("EXT-CQ-", row$Model, "-PILOT"),
        quadrature_nodes = row$Nodes,
        expected_person_ids = as.character(wide$Person),
        observation_set_id = paste0(
          "cq-polytomous-wide-md5:", row$WideMD5
        ),
        likelihood_basis_id = likelihood_basis,
        constraint_basis_id = constraint_basis,
        integration_comparison_id = "cq-polytomous-rsm-pcm-ladder-draft11",
        convergence_status = if (convergence_pass) "pass" else "review",
        convergence_evidence_id = convergence_evidence_id,
        integration_stability_status = "review",
        candidate_id = candidate_id
      ),
      error = function(error) error
    )
    native_paths <- unlist(
      files[c("history", "parameter", "regression", "covariance", "cases")],
      use.names = FALSE
    )
    native_fingerprint <- paste(
      unname(tools::md5sum(native_paths)), collapse = ":"
    )
    if (inherits(record, "error")) {
      result <- mfrmr_cq_poly_empty_result(
        row, "rejected", conditionMessage(record)
      )
      result$ExecutionComplete <- execution_complete
      result$DevianceTerminationObserved <- deviance_termination
      result$ParameterTerminationObserved <- parameter_termination
      result$HigherLikelihoodRetained <- higher_likelihood
      result$CategoryCoveragePass <- category_coverage
      result$NativeParameterLabelsMatched <- labels_matched
      result$HistoryExportMaxAbsDifference <- history_export_difference
      result$HistoryRows <- nrow(history)
      result$NativeOutputFingerprint <- native_fingerprint
      results[[index]] <- result
      next
    }

    adapter_status <- if (convergence_pass) {
      "accepted_arithmetic"
    } else {
      "review"
    }
    results[[index]] <- data.frame(
      Specification = mfrmr_cq_poly_specification,
      ContractVersion = mfrmr_cq_poly_contract,
      RunId = as.character(row$RunId),
      Model = as.character(row$Model),
      Nodes = as.integer(row$Nodes),
      IntegrationTier = as.character(row$IntegrationTier),
      EvidenceRole = as.character(row$EvidenceRole),
      CoreCandidate = isTRUE(row$CoreCandidate),
      ReplicateGroup = as.character(row$ReplicateGroup),
      InputMD5 = as.character(row$WideMD5),
      ExecutionComplete = execution_complete,
      DevianceTerminationObserved = deviance_termination,
      ParameterTerminationObserved = parameter_termination,
      HigherLikelihoodRetained = higher_likelihood,
      CategoryCoveragePass = category_coverage,
      NativeParameterLabelsMatched = labels_matched,
      AdapterStatus = adapter_status,
      AdapterReason = if (convergence_pass) {
        as.character(record$record$Reason)
      } else {
        "convergence_evidence_review"
      },
      ConQuestDeviance = as.numeric(record$record$Deviance),
      MfrmrDeviance = as.numeric(reference_summary$MfrmrDeviance),
      CrossEngineDevianceDifference =
        as.numeric(record$record$Deviance) -
        as.numeric(reference_summary$MfrmrDeviance),
      MaxFreeParameterAbsDifference = max(abs(
        exported_vector - reference_vector
      )),
      MaxFullParameterAbsDifference = max_full_difference,
      MaxConstraintResidual = reconstructed$max_constraint_residual,
      HistoryExportMaxAbsDifference = history_export_difference,
      HistoryRows = as.integer(record$audit$HistoryRows),
      Npar = as.integer(record$record$Npar),
      ExpectedNpar = as.integer(row$ExpectedNpar),
      Persons = as.integer(record$record$Persons),
      ArithmeticEligible = isTRUE(record$record$ArithmeticEligible),
      ComparisonReady = isTRUE(record$record$ComparisonReady),
      NativeOutputFingerprint = native_fingerprint,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }

  results <- do.call(rbind, results)
  summary <- mfrmr_cq_poly_summarize(results)
  out <- list(
    specification = mfrmr_cq_poly_specification,
    contract_version = mfrmr_cq_poly_contract,
    status = "review",
    selection_authorized = FALSE,
    confirmation_authorized = FALSE,
    manifest = manifest,
    results = results,
    summary = summary,
    notes = c(
      "Same-platform RSM/PCM arithmetic and constraint mapping are pilot evidence only.",
      "No tolerance is frozen and no model-selection or confirmation action is authorized.",
      "Independent platform/version replication and candidate-linked reruns remain required."
    )
  )
  class(out) <- c("mfrmr_conquest_polytomous_review", class(out))
  out
}
