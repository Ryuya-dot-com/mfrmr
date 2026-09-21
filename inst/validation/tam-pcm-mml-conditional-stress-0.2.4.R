# Conditional fixed-basis PCM lane for the retained TAM MML stress issue.

mfrmr_tpcm_specification <- "0.2.4-tam-pcm-mml-conditional-stress-v1"
mfrmr_tpcm_contract <- "mfrmr_tam_pcm_mml_conditional_stress_v1"
mfrmr_tpcm_nodes <- c(31L, 61L, 121L, 181L)
mfrmr_tpcm_tam_range <- c(-8, 8)

mfrmr_tpcm_load_core <- function(source_root = ".") {
  source_root <- normalizePath(source_root, winslash = "/", mustWork = TRUE)
  path <- file.path(
    source_root, "inst", "validation", "tam-mml-release-stress-0.2.4.R"
  )
  if (!file.exists(path)) {
    stop("The TAM MML release-stress runner is required.", call. = FALSE)
  }
  core <- new.env(parent = globalenv())
  sys.source(path, envir = core)
  core
}

mfrmr_tpcm_plan <- function(core) {
  base <- core$mfrmr_tms_plan()
  base <- base[
    base$PopulationMode == "fixed_standard_normal" &
      !duplicated(base$DatasetId),
    , drop = FALSE
  ]
  plan <- base[rep(seq_len(nrow(base)), each = length(mfrmr_tpcm_nodes)),
               , drop = FALSE]
  plan$Nodes <- rep(mfrmr_tpcm_nodes, times = nrow(base))
  plan$DatasetId <- sprintf(
    "TPCM-FIX-%s-R%02d", plan$ProfileId, plan$Replicate
  )
  plan$FitId <- sprintf("%s-Q%03d", plan$DatasetId, plan$Nodes)
  plan$Model <- "PCM"
  plan$EvidenceRole <- "0.2.4_conditional_pcm_release_stress_only"
  rownames(plan) <- NULL
  plan
}

mfrmr_tpcm_generate <- function(plan_row) {
  row <- plan_row[1L, , drop = FALSE]
  data <- mfrmr::simulate_mfrm_data(
    n_person = as.integer(row$Persons),
    n_rater = as.integer(row$Raters),
    n_criterion = as.integer(row$Criteria),
    raters_per_person = as.integer(row$RatersPerPerson),
    assignment = as.character(row$Assignment),
    score_levels = as.integer(row$Categories),
    model = "PCM",
    step_facet = "Criterion",
    seed = as.integer(row$Seed)
  )
  truth <- attr(data, "mfrm_truth")
  persons <- sort(unique(as.character(data$Person)))
  if (row$ExtremeFraction > 0) {
    each_tail <- floor(length(persons) * row$ExtremeFraction / 2)
    data$Score[as.character(data$Person) %in% persons[seq_len(each_tail)]] <- 1L
    high <- persons[seq.int(each_tail + 1L, length.out = each_tail)]
    data$Score[as.character(data$Person) %in% high] <- as.integer(row$Categories)
  }
  if (row$MissingRate > 0) {
    had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    old_seed <- if (had_seed) get(".Random.seed", envir = .GlobalEnv) else NULL
    on.exit(mfrmr_tms_restore_seed(had_seed, old_seed), add = TRUE)
    set.seed(as.integer(row$Seed) + 17L)
    remove <- sample.int(nrow(data), floor(nrow(data) * row$MissingRate))
    data <- data[-remove, , drop = FALSE]
  }
  data <- data[order(data$Person, data$Rater, data$Criterion), , drop = FALSE]
  rownames(data) <- NULL
  attr(data, "mfrm_truth") <- truth
  mfrmr_tms_assert(
    length(unique(data$Person)) == row$Persons &&
      length(unique(data$Rater)) == row$Raters &&
      length(unique(data$Criterion)) == row$Criteria &&
      all(data$Score %in% seq_len(row$Categories)),
    paste0("Generated PCM data violate the frozen profile: ", row$DatasetId)
  )
  data
}

mfrmr_tpcm_prepare_tam <- function(data) {
  persons <- sort(unique(as.character(data$Person)))
  raters <- sort(unique(as.character(data$Rater)))
  criteria <- sort(unique(as.character(data$Criterion)))
  item_map <- expand.grid(
    Rater = raters, Criterion = criteria,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  source_key <- paste(data$Person, data$Rater, data$Criterion, sep = "\r")
  response <- vapply(seq_len(nrow(item_map)), function(index) {
    target <- paste(
      persons, item_map$Rater[index], item_map$Criterion[index], sep = "\r"
    )
    matched <- match(target, source_key)
    value <- rep(NA_integer_, length(persons))
    keep <- !is.na(matched)
    value[keep] <- as.integer(data$Score[matched[keep]]) - 1L
    value
  }, integer(length(persons)))
  response <- as.data.frame(response, stringsAsFactors = FALSE)
  support <- as.data.frame(matrix(
    rep(0:3, each = length(criteria), times = length(raters)),
    ncol = length(criteria), byrow = TRUE
  ))
  names(support) <- criteria
  design <- mfrmr_tms_capture(TAM::tam.mml.mfr(
    resp = support,
    facets = data.frame(
      rater = rep(raters, each = 4L), stringsAsFactors = FALSE
    ),
    pid = sprintf("SUPPORT%03d", seq_len(nrow(support))),
    formulaA = ~ item + rater + item:step,
    constraint = "items",
    est.variance = FALSE,
    control = list(maxiter = 2L, progress = FALSE),
    verbose = FALSE
  ))
  item_names <- dimnames(design$value$A)[[1L]]
  observed_raters <- sub("^.*-rater", "", item_names)
  mfrmr_tms_assert(
    identical(dim(design$value$A)[1L], nrow(item_map)) &&
      identical(observed_raters, item_map$Rater) &&
      identical(dim(design$value$A)[2L], 4L) &&
      identical(dim(response), c(length(persons), nrow(item_map))) &&
      all(rowSums(!is.na(response)) > 0L),
    "TAM PCM pseudo-item design does not match the frozen facet map."
  )
  names(response) <- item_names
  zero_weight_support <- as.data.frame(matrix(
    rep(0:3, each = ncol(response)), nrow = 4L, byrow = TRUE
  ))
  names(zero_weight_support) <- item_names
  tam_response <- rbind(response, zero_weight_support)
  list(
    resp = tam_response,
    real_person_count = length(persons),
    pweights = c(rep(1, length(persons)), rep(0, 4L)),
    deviance_scale = length(persons) / nrow(tam_response),
    A = design$value$A,
    item_map = item_map,
    persons = persons,
    design_warnings = design$warnings,
    design_messages = design$messages,
    input_hash = digest::digest(
      data[c("Person", "Rater", "Criterion", "Score")],
      algo = "sha256", serialize = TRUE
    )
  )
}

mfrmr_tpcm_fit_mfrmr <- function(data, row) {
  mfrmr_tms_capture(mfrmr::fit_mfrm(
    data = data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 1L,
    rating_max = as.integer(row$Categories),
    method = "MML",
    model = "PCM",
    step_facet = "Criterion",
    quad_points = as.integer(row$Nodes),
    maxit = 1000L,
    reltol = 1e-12,
    mml_engine = "direct"
  ))
}

mfrmr_tpcm_fit_tam <- function(prepared, row) {
  mfrmr_tms_capture(TAM::tam.mml(
    resp = prepared$resp,
    A = prepared$A,
    pweights = prepared$pweights,
    beta.fixed = cbind(1, 1, 0),
    est.variance = FALSE,
    control = list(
      nodes = seq(
        mfrmr_tpcm_tam_range[1L], mfrmr_tpcm_tam_range[2L],
        length.out = as.integer(row$Nodes)
      ),
      snodes = 0L,
      QMC = TRUE,
      maxiter = 1000L,
      conv = 1e-8,
      convD = 1e-8,
      convM = 1e-8,
      Msteps = 20L,
      progress = FALSE
    ),
    verbose = FALSE
  ))
}

mfrmr_tpcm_mfrmr_surface <- function(fit, item_map) {
  facets <- as.data.frame(fit$facets$others, stringsAsFactors = FALSE)
  rater <- facets[facets$Facet == "Rater", , drop = FALSE]
  criterion <- facets[facets$Facet == "Criterion", , drop = FALSE]
  rater <- stats::setNames(as.numeric(rater$Estimate), as.character(rater$Level))
  criterion <- stats::setNames(
    as.numeric(criterion$Estimate), as.character(criterion$Level)
  )
  steps <- as.data.frame(fit$steps, stringsAsFactors = FALSE)
  do.call(rbind, lapply(seq_len(nrow(item_map)), function(index) {
    owner <- as.character(item_map$Criterion[index])
    owned_steps <- steps[steps$StepFacet == owner, , drop = FALSE]
    owned_steps <- owned_steps[order(
      as.integer(sub("Step_", "", owned_steps$Step, fixed = TRUE))
    ), , drop = FALSE]
    k <- seq_len(nrow(owned_steps))
    data.frame(
      Criterion = owner,
      Rater = as.character(item_map$Rater[index]),
      Category = k,
      MfrmrEstimate = k * (
        criterion[owner] + rater[item_map$Rater[index]]
      ) + cumsum(as.numeric(owned_steps$Estimate)),
      stringsAsFactors = FALSE
    )
  }))
}

mfrmr_tpcm_install_core <- function(core) {
  assign("mfrmr_tpcm_tam_range", mfrmr_tpcm_tam_range, envir = core)
  replacements <- list(
    mfrmr_tms_generate = mfrmr_tpcm_generate,
    mfrmr_tms_prepare_tam = mfrmr_tpcm_prepare_tam,
    mfrmr_tms_fit_mfrmr = mfrmr_tpcm_fit_mfrmr,
    mfrmr_tms_fit_tam = mfrmr_tpcm_fit_tam,
    mfrmr_tms_mfrmr_surface = mfrmr_tpcm_mfrmr_surface
  )
  for (name in names(replacements)) {
    fun <- replacements[[name]]
    environment(fun) <- core
    assign(name, fun, envir = core)
  }
  invisible(core)
}

mfrmr_tpcm_integration_rows <- function(core, summaries, surfaces, scores) {
  transitions <- matrix(
    c(31L, 61L, 61L, 121L, 121L, 181L), ncol = 2L, byrow = TRUE,
    dimnames = list(NULL, c("LowNodes", "HighNodes"))
  )
  out <- lapply(seq_len(nrow(transitions)), function(index) {
    low <- transitions[index, "LowNodes"]
    high <- transitions[index, "HighNodes"]
    selected <- summaries$Nodes %in% c(low, high)
    aliased <- summaries[selected, , drop = FALSE]
    aliased$Nodes <- ifelse(aliased$Nodes == low, 31L, 61L)
    movement <- core$mfrmr_tms_integration_rows(
      aliased,
      surfaces[surfaces$FitId %in% aliased$FitId, , drop = FALSE],
      scores[scores$FitId %in% aliased$FitId, , drop = FALSE]
    )
    movement$LowNodes <- low
    movement$HighNodes <- high
    movement
  })
  out <- do.call(rbind, out)
  rownames(out) <- NULL
  out
}

mfrmr_run_tam_pcm_mml_conditional_stress <- function(source_root = ".") {
  core <- mfrmr_tpcm_load_core(source_root)
  runtime <- core$mfrmr_tms_runtime_identity(source_root)
  mfrmr_tpcm_install_core(core)
  plan <- mfrmr_tpcm_plan(core)
  dataset_plan <- plan[!duplicated(plan$DatasetId), , drop = FALSE]
  cache <- lapply(seq_len(nrow(dataset_plan)), function(index) {
    data <- NULL
    tryCatch({
      data <- core$mfrmr_tms_generate(dataset_plan[index, , drop = FALSE])
      list(
        data = data, prepared = core$mfrmr_tms_prepare_tam(data), error = ""
      )
    }, error = function(condition) {
      list(data = data, prepared = NULL, error = conditionMessage(condition))
    })
  })
  names(cache) <- dataset_plan$DatasetId
  runs <- lapply(seq_len(nrow(plan)), function(index) {
    row <- plan[index, , drop = FALSE]
    cached <- cache[[as.character(row$DatasetId)]]
    if (nzchar(cached$error)) {
      return(core$mfrmr_tms_failed_comparison(
        row, cached$data, cached$prepared, cached$error
      ))
    }
    tryCatch(
      core$mfrmr_tms_compare_one(row, cached$data, cached$prepared),
      error = function(condition) core$mfrmr_tms_failed_comparison(
        row, cached$data, cached$prepared, conditionMessage(condition)
      )
    )
  })
  summaries <- do.call(rbind, lapply(runs, `[[`, "summary"))
  surfaces <- do.call(rbind, lapply(runs, `[[`, "surface"))
  scores <- do.call(rbind, lapply(runs, `[[`, "scores"))
  rownames(summaries) <- rownames(surfaces) <- rownames(scores) <- NULL
  integration <- mfrmr_tpcm_integration_rows(
    core, summaries, surfaces, scores
  )
  high <- summaries$Nodes == max(mfrmr_tpcm_nodes)
  complete <- nrow(summaries) == 60L && nrow(integration) == 45L &&
    all(runtime$IdentityMatch) && all(summaries$Error == "") &&
    all(summaries$PairPassed[high]) && all(integration$IntegrationPassed)
  list(
    specification = mfrmr_tpcm_specification,
    contract_version = mfrmr_tpcm_contract,
    status = if (complete) {
      "bounded_tam_pcm_mml_conditional_stress_passed"
    } else {
      "bounded_tam_pcm_mml_conditional_stress_requires_review"
    },
    runtime_identity = runtime,
    plan = plan,
    summaries = summaries,
    surfaces = surfaces,
    scores = scores,
    integration = integration,
    conditional_stress_complete = complete,
    tam_parity_established = FALSE,
    portable_scope_broadened = FALSE,
    release_authorized = FALSE
  )
}

mfrmr_write_tam_pcm_mml_conditional_stress <- function(result, output_dir) {
  if (!is.list(result) ||
      !identical(result$contract_version, mfrmr_tpcm_contract)) {
    stop("`result` is not a TAM PCM conditional-stress result.", call. = FALSE)
  }
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  tables <- c(
    runtime = "runtime_identity", plan = "plan", summary = "summaries",
    surface = "surfaces", score = "scores", integration = "integration"
  )
  paths <- vapply(names(tables), function(name) {
    path <- file.path(
      output_dir,
      paste0("tam-pcm-mml-conditional-stress-", name, "-0.2.4.csv")
    )
    utils::write.csv(result[[tables[[name]]]], path, row.names = FALSE, na = "")
    path
  }, character(1L))
  invisible(paths)
}
