# Draft.75 matched TAM/immer/mfrmr JML mode comparison.

mfrmr_ti_or <- function(value, replacement) {
  if (is.null(value) || length(value) == 0L) replacement else value
}

mfrmr_ti_require <- function() {
  for (pkg in c("TAM", "immer", "digest", "dplyr", "tibble")) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop("Draft.75 requires the local `", pkg, "` package.",
           call. = FALSE)
    }
  }
  target_env <- environment(mfrmr_ti_require)
  if (!exists("mfrmr_jml_profile_recovery_apply", envir = target_env,
              inherits = TRUE)) {
    candidates <- c(
      file.path(
        "inst", "validation",
        "jml-extreme-profile-recovery-pilot-0.2.3.R"
      ),
      file.path(
        "..", "inst", "validation",
        "jml-extreme-profile-recovery-pilot-0.2.3.R"
      ),
      file.path(
        "..", "..", "inst", "validation",
        "jml-extreme-profile-recovery-pilot-0.2.3.R"
      ),
      file.path(
        "..", "..", "..", "inst", "validation",
        "jml-extreme-profile-recovery-pilot-0.2.3.R"
      )
    )
    path <- candidates[file.exists(candidates)][1L]
    if (is.na(path)) {
      stop("The Draft.74 paired-profile runner is unavailable.",
           call. = FALSE)
    }
    sys.source(path, envir = target_env)
  }
  mfrmr_jml_profile_recovery_require()
  invisible(TRUE)
}

mfrmr_ti_function_hash <- function(package, name) {
  object <- get(name, envir = asNamespace(package), inherits = FALSE)
  digest::digest(
    list(formals = formals(object), body = body(object)),
    algo = "sha256", serialize = TRUE
  )
}

mfrmr_ti_runtime_identity <- function() {
  mfrmr_ti_require()
  data.frame(
    Engine = c("mfrmr", "TAM", "immer"),
    Version = c(
      as.character(utils::packageVersion("mfrmr")),
      as.character(utils::packageVersion("TAM")),
      as.character(utils::packageVersion("immer"))
    ),
    PrimaryFunction = c("fit_mfrm", "tam.jml", "immer_jml"),
    FunctionSHA256 = c(
      mfrmr_ti_function_hash("mfrmr", "fit_mfrm"),
      mfrmr_ti_function_hash("TAM", "tam.jml"),
      mfrmr_ti_function_hash("immer", "immer_jml")
    ),
    Documentation = c(
      "package help: fit_mfrm",
      "https://search.r-project.org/CRAN/refmans/TAM/html/tam.jml.html",
      "https://cran.r-project.org/package=immer"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_ti_mode_registry <- function() {
  data.frame(
    ModeId = c(
      "MFRMR_RAW", "MFRMR_PROFILE",
      "TAM_RAW", "TAM_ADJ", "TAM_BC", "TAM_BC_ADJ",
      "IMMER_JML", "IMMER_EPS", "IMMER_BC"
    ),
    ScenarioId = c(
      "INT-MFRMR-JML-RAW", "INT-JML-EXT-PROFILE",
      "EXT-TAM-JML-RAW", "EXT-TAM-JML-ADJ",
      "EXT-TAM-JML-BC", "EXT-TAM-JML-BC-ADJ",
      "EXT-IMMER-JML-RAW", "EXT-IMMER-JML-EPS",
      "EXT-IMMER-JML-BC"
    ),
    Engine = c(
      "mfrmr", "mfrmr", rep("TAM", 4L), rep("immer", 3L)
    ),
    EstimatorCall = c(
      "fit_mfrm(method='JML')",
      "extended_profile_limit_v1",
      "tam.jml(adj=0,bias=FALSE)",
      "tam.jml(adj=0.3,bias=FALSE)",
      "tam.jml(adj=0,bias=TRUE)",
      "tam.jml(adj=0.3,bias=TRUE)",
      "immer_jml(est_method='jml',eps=0.3)",
      "immer_jml(est_method='eps_adj',eps=0.3)",
      "immer_jml(est_method='jml_bc',eps=0.3)"
    ),
    ExtremePolicy = c(
      "typed_unbounded_primary_finite_trace_retained",
      "independently_free_boundary_profile",
      "none_adj_zero",
      "score_extremes_plus_or_minus_0.3",
      "none_adj_zero",
      "score_extremes_plus_or_minus_0.3",
      "epsilon_0.3_for_extreme_person_scores",
      "epsilon_0.3_fuzzy_person_and_item_scores",
      "epsilon_0.3_for_extreme_person_scores"
    ),
    BiasPolicy = c(
      "none", "none", "none", "none",
      "postmultiply_xsi_by_(I-1)/I",
      "postmultiply_xsi_by_(I-1)/I",
      "none", "epsilon_estimating_equation",
      "postmultiply_xsi_by_(Ibar-1)/Ibar"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_ti_manifest <- function(tier = c("smoke", "pilot")) {
  tier <- match.arg(tier)
  if (identical(tier, "smoke")) {
    grid <- expand.grid(
      Model = c("RSM", "PCM"),
      ExtremeFraction = c(0, 0.125),
      Information = "core",
      Replicate = 1L,
      KEEP.OUT.ATTRS = FALSE,
      stringsAsFactors = FALSE
    )
    grid$Persons <- 64L
    grid$Raters <- 3L
    grid$Criteria <- 3L
    grid$Seed <- 750501L
    grid$MfrmrMaxit <- 400L
    grid$TamMaxit <- 400L
    grid$ImmerMaxit <- 1000L
  } else {
    grid <- expand.grid(
      Model = c("RSM", "PCM"),
      Information = c("low", "high"),
      ExtremeFraction = c(0, 0.10, 0.25),
      Replicate = seq_len(5L),
      KEEP.OUT.ATTRS = FALSE,
      stringsAsFactors = FALSE
    )
    grid$Persons <- 80L
    grid$Raters <- ifelse(grid$Information == "low", 3L, 5L)
    grid$Criteria <- ifelse(grid$Information == "low", 2L, 4L)
    grid$Seed <- 755000L +
      match(paste(grid$Model, grid$Information, grid$Replicate),
            unique(paste(grid$Model, grid$Information, grid$Replicate))) *
      101L
    grid$MfrmrMaxit <- 500L
    grid$TamMaxit <- 600L
    grid$ImmerMaxit <- 1000L
  }
  grid$RatersPerPerson <- grid$Raters
  grid$ResponsesPerPerson <- grid$Raters * grid$Criteria
  grid$ForcedExtremeN <- 2L * floor(
    grid$Persons * grid$ExtremeFraction / 2L
  )
  grid$DatasetRow <- seq_len(nrow(grid))
  grid$Tier <- tier
  grid$DatasetId <- sprintf(
    "EXT-JML-MODE-%s-%s-E%03d-R%02d",
    grid$Model, toupper(grid$Information),
    as.integer(round(100 * grid$ExtremeFraction)), grid$Replicate
  )
  grid$PairId <- sprintf(
    "EXT-JML-PAIR-%s-%s-S%d-R%02d",
    grid$Model, toupper(grid$Information), grid$Seed, grid$Replicate
  )
  grid$FormulaIdentity <- ifelse(
    grid$Model == "RSM",
    "~ item + rater + step",
    "~ item + rater + item:step"
  )
  grid$ContractVersion <- "mfrmr-tam-immer-jml-mode-comparison-v1"
  grid[, c(
    "ContractVersion", "DatasetRow", "DatasetId", "PairId", "Tier",
    "Model", "Information", "Persons", "Raters", "Criteria",
    "RatersPerPerson", "ResponsesPerPerson", "ExtremeFraction",
    "ForcedExtremeN", "Replicate", "Seed", "MfrmrMaxit",
    "TamMaxit", "ImmerMaxit", "FormulaIdentity"
  )]
}

mfrmr_ti_generate <- function(row) {
  model <- as.character(row$Model)
  data <- simulate_mfrm_data(
    n_person = as.integer(row$Persons),
    n_rater = as.integer(row$Raters),
    n_criterion = as.integer(row$Criteria),
    raters_per_person = as.integer(row$RatersPerPerson),
    assignment = "crossed",
    score_levels = as.integer(mfrmr_ti_or(row$Categories, 4L)),
    model = model,
    step_facet = "Criterion",
    seed = as.integer(row$Seed)
  )
  truth <- attr(data, "mfrm_truth")
  persons <- sort(unique(as.character(data$Person)))
  n_extreme <- as.integer(row$ForcedExtremeN)
  n_signed <- n_extreme %/% 2L
  high <- if (n_signed > 0L) persons[seq_len(n_signed)] else character(0)
  low <- if (n_signed > 0L) {
    persons[seq.int(n_signed + 1L, length.out = n_signed)]
  } else {
    character(0)
  }
  data$Score[as.character(data$Person) %in% high] <-
    as.integer(mfrmr_ti_or(row$Categories, 4L))
  data$Score[as.character(data$Person) %in% low] <- 1L
  attr(data, "mfrm_truth") <- truth
  attr(data, "mfrmr_forced_extremes") <- list(high = high, low = low)
  data
}

mfrmr_ti_formula <- function(model) {
  if (identical(model, "RSM")) {
    stats::as.formula("~ item + rater + step")
  } else {
    stats::as.formula("~ item + rater + item:step")
  }
}

mfrmr_ti_prepare_external <- function(data, model) {
  persons <- sort(unique(as.character(data$Person)))
  raters <- sort(unique(as.character(data$Rater)))
  criteria <- sort(unique(as.character(data$Criterion)))
  grid <- unique(data.frame(
    Person = as.character(data$Person),
    Rater = as.character(data$Rater),
    stringsAsFactors = FALSE
  ))
  grid <- grid[order(grid$Person, grid$Rater), , drop = FALSE]
  source_key <- paste(data$Person, data$Rater, data$Criterion, sep = "\r")
  response <- vapply(criteria, function(criterion) {
    target <- paste(grid$Person, grid$Rater, criterion, sep = "\r")
    index <- match(target, source_key)
    value <- rep(NA_integer_, nrow(grid))
    retained <- !is.na(index)
    value[retained] <- as.integer(data$Score[index[retained]]) - 1L
    value
  }, integer(nrow(grid)))
  response <- as.data.frame(response, stringsAsFactors = FALSE)
  names(response) <- criteria
  retained_grid <- rowSums(!is.na(response)) > 0L
  grid <- grid[retained_grid, , drop = FALSE]
  response <- response[retained_grid, , drop = FALSE]
  if (nrow(response) == 0L) {
    stop("The matched external comparison has no observed Person-Rater row.",
         call. = FALSE)
  }
  facets <- data.frame(rater = grid$Rater, stringsAsFactors = FALSE)
  output <- utils::capture.output(
    design <- suppressWarnings(TAM::tam.mml.mfr(
      resp = response,
      facets = facets,
      formulaA = mfrmr_ti_formula(model),
      pid = grid$Person,
      control = list(maxiter = 2L, progress = FALSE),
      verbose = FALSE
    ))
  )
  item <- rownames(design$A)
  item_map <- data.frame(
    Item = item,
    Criterion = sub("-rater.*$", "", item),
    Rater = sub("^.*-rater", "", item),
    stringsAsFactors = FALSE
  )
  if (!identical(sort(unique(item_map$Criterion)), criteria) ||
      !identical(sort(unique(item_map$Rater)), raters)) {
    stop("TAM pseudoitem labels do not match the declared facets.",
         call. = FALSE)
  }
  list(
    resp = design$resp,
    A_tam = design$A,
    A_immer = design$A[, -1L, , drop = FALSE],
    item_map = item_map,
    design_output = output,
    formula = paste(deparse(mfrmr_ti_formula(model)), collapse = "")
  )
}

mfrmr_ti_step_values <- function(table, criterion, model) {
  table <- as.data.frame(table, stringsAsFactors = FALSE)
  if (nrow(table) == 0L) return(numeric(0))
  if ("StepFacet" %in% names(table)) {
    facets <- as.character(table$StepFacet)
    selected <- facets %in% c("Common", criterion)
    if (any(facets == criterion)) selected <- facets == criterion
    table <- table[selected, , drop = FALSE]
  }
  if ("StepIndex" %in% names(table)) {
    table <- table[order(as.integer(table$StepIndex)), , drop = FALSE]
  } else if ("Step" %in% names(table)) {
    index <- suppressWarnings(as.integer(sub(".*_", "", table$Step)))
    table <- table[order(index), , drop = FALSE]
  }
  as.numeric(table$Estimate)
}

mfrmr_ti_surface_from_components <- function(item_map, facets, steps,
                                              model) {
  rater <- facets$Rater
  criterion <- facets$Criterion
  out <- lapply(seq_len(nrow(item_map)), function(i) {
    rr <- as.character(item_map$Rater[i])
    cc <- as.character(item_map$Criterion[i])
    step <- mfrmr_ti_step_values(steps, cc, model)
    category <- seq_along(step)
    data.frame(
      Item = as.character(item_map$Item[i]),
      Criterion = cc,
      Rater = rr,
      Category = category,
      Estimate = category * (as.numeric(rater[[rr]]) +
                               as.numeric(criterion[[cc]])) + cumsum(step),
      stringsAsFactors = FALSE
    )
  })
  dplyr::bind_rows(out)
}

mfrmr_ti_truth_surface <- function(item_map, truth, model) {
  facets <- list(
    Rater = truth$facets$Rater,
    Criterion = truth$facets$Criterion
  )
  mfrmr_ti_surface_from_components(
    item_map, facets, truth$step_table, model
  )
}

mfrmr_ti_fit_surface <- function(item_map, fit, model) {
  others <- as.data.frame(fit$facets$others, stringsAsFactors = FALSE)
  rater <- others[others$Facet == "Rater", , drop = FALSE]
  criterion <- others[others$Facet == "Criterion", , drop = FALSE]
  facets <- list(
    Rater = stats::setNames(as.numeric(rater$Estimate), rater$Level),
    Criterion = stats::setNames(
      as.numeric(criterion$Estimate), criterion$Level
    )
  )
  mfrmr_ti_surface_from_components(item_map, facets, fit$steps, model)
}

mfrmr_ti_matrix_surface <- function(matrix, item_map) {
  matrix <- as.matrix(matrix)
  if (nrow(matrix) != nrow(item_map)) {
    stop("External cumulative-difficulty rows do not align.", call. = FALSE)
  }
  if (is.null(rownames(matrix))) rownames(matrix) <- item_map$Item
  index <- match(item_map$Item, rownames(matrix))
  if (anyNA(index)) {
    stop("External cumulative-difficulty labels do not align.", call. = FALSE)
  }
  matrix <- matrix[index, , drop = FALSE]
  dplyr::bind_rows(lapply(seq_len(ncol(matrix)), function(k) {
    data.frame(
      Item = item_map$Item,
      Criterion = item_map$Criterion,
      Rater = item_map$Rater,
      Category = k,
      Estimate = as.numeric(matrix[, k]),
      stringsAsFactors = FALSE
    )
  }))
}

mfrmr_ti_align_truth <- function(surface, truth) {
  key <- c("Item", "Criterion", "Rater", "Category")
  joined <- merge(
    surface, truth,
    by = key, suffixes = c("", ".Truth"), sort = FALSE
  )
  if (nrow(joined) != nrow(truth) || nrow(joined) != nrow(surface)) {
    stop("Structural surfaces do not form a complete truth pairing.",
         call. = FALSE)
  }
  k <- as.numeric(joined$Category)
  shift <- sum(k * (joined$Estimate - joined$Estimate.Truth)) / sum(k^2)
  joined$LocationShift <- shift
  joined$EstimateAligned <- joined$Estimate - k * shift
  joined$Truth <- joined$Estimate.Truth
  joined$ErrorAligned <- joined$EstimateAligned - joined$Truth
  joined$Estimate.Truth <- NULL
  joined
}

mfrmr_ti_mode_row <- function(row, registry_row, fit_returned,
                              finite_surface, iterations = NA_integer_,
                              elapsed = NA_real_, error = "",
                              effective_items = NA_real_,
                              bias_factor = 1,
                              profile_state = NA_character_,
                              actual_extreme_n = NA_integer_) {
  data.frame(
    ContractVersion = as.character(row$ContractVersion),
    DatasetRow = as.integer(row$DatasetRow),
    DatasetId = as.character(row$DatasetId),
    PairId = as.character(row$PairId),
    Model = as.character(row$Model),
    Information = as.character(row$Information),
    ExtremeFraction = as.numeric(row$ExtremeFraction),
    ForcedExtremeN = as.integer(row$ForcedExtremeN),
    ActualExtremeN = as.integer(actual_extreme_n),
    ModeId = as.character(registry_row$ModeId),
    ScenarioId = as.character(registry_row$ScenarioId),
    Engine = as.character(registry_row$Engine),
    EstimatorCall = as.character(registry_row$EstimatorCall),
    ExtremePolicy = as.character(registry_row$ExtremePolicy),
    BiasPolicy = as.character(registry_row$BiasPolicy),
    OriginalRawEligible = as.integer(actual_extreme_n) == 0L &&
      as.character(registry_row$ModeId) %in%
        c("MFRMR_RAW", "TAM_RAW", "IMMER_JML"),
    OriginalMaximumClaimed = FALSE,
    FitReturned = isTRUE(fit_returned),
    FiniteSurface = isTRUE(finite_surface),
    Iterations = as.integer(iterations),
    EffectiveItems = as.numeric(effective_items),
    BiasFactor = as.numeric(bias_factor),
    ProfileState = as.character(profile_state),
    ElapsedSeconds = as.numeric(elapsed),
    Error = as.character(error),
    stringsAsFactors = FALSE
  )
}

mfrmr_ti_fit_tam <- function(prepared, row, registry_row,
                             actual_extreme_n) {
  mode <- as.character(registry_row$ModeId)
  adj <- if (mode %in% c("TAM_ADJ", "TAM_BC_ADJ")) 0.3 else 0
  bias <- mode %in% c("TAM_BC", "TAM_BC_ADJ")
  started <- proc.time()[["elapsed"]]
  value <- tryCatch({
    output <- utils::capture.output(
      fit <- suppressWarnings(TAM::tam.jml(
        resp = prepared$resp,
        A = prepared$A_tam,
        adj = adj,
        bias = bias,
        constraint = "cases",
        verbose = FALSE,
        control = list(
          maxiter = as.integer(row$TamMaxit),
          Msteps = 10L, conv = 1e-8, progress = FALSE
        )
      ))
    )
    list(fit = fit, output = output)
  }, error = function(e) e)
  elapsed <- proc.time()[["elapsed"]] - started
  if (inherits(value, "error")) {
    return(list(
      row = mfrmr_ti_mode_row(
        row, registry_row, FALSE, FALSE, elapsed = elapsed,
        error = conditionMessage(value),
        effective_items = ncol(prepared$resp),
        bias_factor = if (bias) {
          (ncol(prepared$resp) - 1) / ncol(prepared$resp)
        } else 1,
        actual_extreme_n = actual_extreme_n
      ),
      surface = NULL, fit = value
    ))
  }
  fit <- value$fit
  surface <- mfrmr_ti_matrix_surface(
    -as.matrix(fit$AXsi[, -1L, drop = FALSE]), prepared$item_map
  )
  finite <- all(is.finite(surface$Estimate))
  list(
    row = mfrmr_ti_mode_row(
      row, registry_row, TRUE, finite,
      iterations = fit$iter, elapsed = elapsed,
      effective_items = fit$nitems,
      bias_factor = if (bias) (fit$nitems - 1) / fit$nitems else 1,
      actual_extreme_n = actual_extreme_n
    ),
    surface = surface, fit = fit
  )
}

mfrmr_ti_fit_immer <- function(prepared, row, registry_row,
                               actual_extreme_n) {
  mode <- as.character(registry_row$ModeId)
  est_method <- c(
    IMMER_JML = "jml", IMMER_EPS = "eps_adj", IMMER_BC = "jml_bc"
  )[[mode]]
  started <- proc.time()[["elapsed"]]
  value <- tryCatch(suppressWarnings(immer::immer_jml(
    dat = prepared$resp,
    A = prepared$A_immer,
    est_method = est_method,
    eps = 0.3,
    center_theta = TRUE,
    maxiter = as.integer(row$ImmerMaxit),
    conv = 1e-8,
    verbose = FALSE,
    use_Rcpp = TRUE,
    shortcut = TRUE
  )), error = function(e) e)
  elapsed <- proc.time()[["elapsed"]] - started
  effective <- mean(rowSums(!is.na(prepared$resp)))
  factor <- if (identical(est_method, "jml_bc")) {
    (effective - 1) / effective
  } else 1
  if (inherits(value, "error")) {
    return(list(
      row = mfrmr_ti_mode_row(
        row, registry_row, FALSE, FALSE, elapsed = elapsed,
        error = conditionMessage(value), effective_items = effective,
        bias_factor = factor, actual_extreme_n = actual_extreme_n
      ),
      surface = NULL, fit = value
    ))
  }
  surface <- mfrmr_ti_matrix_surface(value$b, prepared$item_map)
  finite <- all(is.finite(surface$Estimate))
  list(
    row = mfrmr_ti_mode_row(
      row, registry_row, TRUE, finite,
      iterations = value$iter, elapsed = elapsed,
      effective_items = effective, bias_factor = factor,
      actual_extreme_n = actual_extreme_n
    ),
    surface = surface, fit = value
  )
}

mfrmr_ti_fit_mfrmr <- function(data, prepared, row, registry,
                               actual_extreme_n) {
  args <- list(
    data = data, person = "Person",
    facets = c("Rater", "Criterion"), score = "Score",
    rating_min = 1,
    rating_max = as.integer(mfrmr_ti_or(row$Categories, 4L)),
    keep_original = TRUE,
    method = "JML", model = as.character(row$Model),
    maxit = as.integer(row$MfrmrMaxit), reltol = 1e-10,
    optimizer = "BFGS"
  )
  if (identical(as.character(row$Model), "PCM")) {
    args$step_facet <- "Criterion"
  }
  started <- proc.time()[["elapsed"]]
  fit <- suppressMessages(suppressWarnings(do.call(fit_mfrm, args)))
  elapsed_raw <- proc.time()[["elapsed"]] - started
  person <- as.data.frame(fit$facets$person, stringsAsFactors = FALSE)
  free_extreme <- person$ParameterStatus %in%
    c("unbounded_low", "unbounded_high")
  raw_surface <- mfrmr_ti_fit_surface(
    prepared$item_map, fit, as.character(row$Model)
  )
  raw_registry <- registry[registry$ModeId == "MFRMR_RAW", , drop = FALSE]
  raw_row <- mfrmr_ti_mode_row(
    row, raw_registry, TRUE, all(is.finite(raw_surface$Estimate)),
    iterations = mfrmr_ti_or(fit$opt$counts[[1L]], NA_integer_),
    elapsed = elapsed_raw,
    profile_state = "raw_finite_optimizer_trace",
    actual_extreme_n = actual_extreme_n
  )
  profile_started <- proc.time()[["elapsed"]]
  profile <- if (any(free_extreme)) {
    suppressWarnings(mfrmr_jml_profile_limit_refit(
      fit, caps = c(4, 8, 12, 16, 24, 32, 48, 64),
      maxit = as.integer(row$MfrmrMaxit), reltol = 1e-10,
      optimizer = "BFGS", limit_tolerance = 1e-8
    ))
  } else {
    list(
      State = "no_free_extreme_persons", Complete = TRUE,
      EstimateRole = "profile_limit_noop"
    )
  }
  elapsed_profile <- proc.time()[["elapsed"]] - profile_started
  profile_fit <- if (identical(
    profile$EstimateRole, "extended_jml_profile_limit"
  )) {
    mfrmr_jml_profile_recovery_apply(fit, profile)
  } else fit
  profile_surface <- mfrmr_ti_fit_surface(
    prepared$item_map, profile_fit, as.character(row$Model)
  )
  profile_registry <- registry[
    registry$ModeId == "MFRMR_PROFILE", , drop = FALSE
  ]
  profile_ok <- identical(profile$State, "profile_limit_refit_verified") ||
    identical(profile$State, "no_free_extreme_persons")
  profile_row <- mfrmr_ti_mode_row(
    row, profile_registry, profile_ok,
    profile_ok && all(is.finite(profile_surface$Estimate)),
    iterations = if (!is.null(profile$profile_opt)) {
      mfrmr_ti_or(profile$profile_opt$counts[[1L]], NA_integer_)
    } else 0L,
    elapsed = elapsed_profile,
    profile_state = as.character(profile$State),
    actual_extreme_n = actual_extreme_n
  )
  list(
    rows = dplyr::bind_rows(raw_row, profile_row),
    surfaces = list(
      MFRMR_RAW = raw_surface,
      MFRMR_PROFILE = profile_surface
    ),
    fit = fit, profile = profile
  )
}

mfrmr_ti_surface_max_difference <- function(a, b, multiplier = 1) {
  if (is.null(a) || is.null(b)) return(NA_real_)
  key <- c("Item", "Criterion", "Rater", "Category")
  joined <- merge(a, b, by = key, suffixes = c(".A", ".B"), sort = FALSE)
  if (nrow(joined) != nrow(a) || nrow(joined) != nrow(b)) return(NA_real_)
  max(abs(joined$Estimate.A - multiplier * joined$Estimate.B))
}

mfrmr_ti_location_aligned_max_difference <- function(a, b) {
  if (is.null(a) || is.null(b)) return(NA_real_)
  key <- c("Item", "Criterion", "Rater", "Category")
  joined <- merge(a, b, by = key, suffixes = c(".A", ".B"), sort = FALSE)
  if (nrow(joined) != nrow(a) || nrow(joined) != nrow(b)) return(NA_real_)
  k <- as.numeric(joined$Category)
  difference <- joined$Estimate.A - joined$Estimate.B
  location_shift <- sum(k * difference) / sum(k^2)
  max(abs(difference - k * location_shift))
}

mfrmr_ti_invariant_row <- function(row, name, estimate, threshold,
                                   required, direction = "lte") {
  pass <- if (!isTRUE(required)) {
    NA
  } else if (!is.finite(estimate)) {
    FALSE
  } else if (identical(direction, "lte")) {
    estimate <= threshold
  } else {
    estimate >= threshold
  }
  data.frame(
    DatasetId = as.character(row$DatasetId),
    Model = as.character(row$Model),
    ExtremeFraction = as.numeric(row$ExtremeFraction),
    Invariant = name,
    Estimate = as.numeric(estimate),
    Threshold = as.numeric(threshold),
    Direction = direction,
    Required = isTRUE(required),
    Passed = pass,
    stringsAsFactors = FALSE
  )
}

mfrmr_ti_invariants <- function(row, modes, surfaces) {
  extreme <- modes$ActualExtremeN[1L] > 0L
  get_surface <- function(name) surfaces[[name]]
  fit_returned <- function(name) {
    value <- modes$FitReturned[modes$ModeId == name]
    length(value) == 1L && isTRUE(value)
  }
  bias_factor <- function(name) {
    value <- modes$BiasFactor[modes$ModeId == name]
    if (length(value) == 1L) as.numeric(value) else NA_real_
  }
  dplyr::bind_rows(
    mfrmr_ti_invariant_row(
      row, "mfrmr_vs_tam_raw_location_aligned_no_extremes",
      mfrmr_ti_location_aligned_max_difference(
        get_surface("MFRMR_RAW"), get_surface("TAM_RAW")
      ), 5e-5, !extreme
    ),
    mfrmr_ti_invariant_row(
      row, "tam_raw_vs_immer_jml_no_extremes",
      mfrmr_ti_surface_max_difference(
        get_surface("TAM_RAW"), get_surface("IMMER_JML")
      ), 2e-5, !extreme
    ),
    mfrmr_ti_invariant_row(
      row, "tam_adj_vs_immer_jml_with_extremes",
      mfrmr_ti_surface_max_difference(
        get_surface("TAM_ADJ"), get_surface("IMMER_JML")
      ), 2e-5, extreme
    ),
    mfrmr_ti_invariant_row(
      row, "tam_adjustment_is_noop_without_extremes",
      mfrmr_ti_surface_max_difference(
        get_surface("TAM_ADJ"), get_surface("TAM_RAW")
      ), 1e-12, !extreme
    ),
    mfrmr_ti_invariant_row(
      row, "tam_bias_factor_after_adjustment",
      mfrmr_ti_surface_max_difference(
        get_surface("TAM_BC_ADJ"), get_surface("TAM_ADJ"),
        bias_factor("TAM_BC_ADJ")
      ), 1e-12, TRUE
    ),
    mfrmr_ti_invariant_row(
      row, "tam_bias_factor_without_adjustment",
      mfrmr_ti_surface_max_difference(
        get_surface("TAM_BC"), get_surface("TAM_RAW"),
        bias_factor("TAM_BC")
      ), 1e-12, !extreme
    ),
    mfrmr_ti_invariant_row(
      row, "immer_bias_factor_after_extreme_handling",
      mfrmr_ti_surface_max_difference(
        get_surface("IMMER_BC"), get_surface("IMMER_JML"),
        bias_factor("IMMER_BC")
      ), 1e-12, TRUE
    ),
    mfrmr_ti_invariant_row(
      row, "mfrmr_profile_is_noop_without_extremes",
      mfrmr_ti_surface_max_difference(
        get_surface("MFRMR_PROFILE"), get_surface("MFRMR_RAW")
      ), 1e-12, !extreme
    ),
    mfrmr_ti_invariant_row(
      row, "mfrmr_profile_state_with_extremes",
      as.numeric(!(
        modes$ProfileState[modes$ModeId == "MFRMR_PROFILE"] ==
          "profile_limit_refit_verified"
      )), 0, extreme
    ),
    mfrmr_ti_invariant_row(
      row, "mfrmr_profile_vs_tam_adjusted_descriptive",
      mfrmr_ti_location_aligned_max_difference(
        get_surface("MFRMR_PROFILE"), get_surface("TAM_ADJ")
      ), NA_real_, FALSE
    ),
    mfrmr_ti_invariant_row(
      row, "tam_adj0_fails_closed_with_extremes",
      as.numeric(fit_returned("TAM_RAW") || fit_returned("TAM_BC")),
      0, extreme
    )
  )
}

mfrmr_ti_fit_one <- function(row, data = NULL) {
  mfrmr_ti_require()
  registry <- mfrmr_ti_mode_registry()
  if (is.null(data)) data <- mfrmr_ti_generate(row)
  truth <- attr(data, "mfrm_truth")
  prepared <- mfrmr_ti_prepare_external(data, as.character(row$Model))
  by_person <- split(as.integer(data$Score), as.character(data$Person))
  extreme_ids <- names(by_person)[vapply(
    by_person, function(x) {
      x <- x[!is.na(x)]
      length(x) > 0L && length(unique(x)) == 1L &&
        unique(x) %in% c(
          1L, as.integer(mfrmr_ti_or(row$Categories, 4L))
        )
    }, logical(1)
  )]
  actual_extreme_n <- length(extreme_ids)
  truth_surface <- mfrmr_ti_truth_surface(
    prepared$item_map, truth, as.character(row$Model)
  )
  internal <- mfrmr_ti_fit_mfrmr(
    data, prepared, row, registry, actual_extreme_n
  )
  mode_rows <- list(internal$rows)
  surfaces <- internal$surfaces
  fits <- list(
    MFRMR_RAW = internal$fit,
    MFRMR_PROFILE = internal$profile
  )
  for (mode in c("TAM_RAW", "TAM_ADJ", "TAM_BC", "TAM_BC_ADJ")) {
    registry_row <- registry[registry$ModeId == mode, , drop = FALSE]
    value <- mfrmr_ti_fit_tam(
      prepared, row, registry_row, actual_extreme_n
    )
    mode_rows[[length(mode_rows) + 1L]] <- value$row
    surfaces[[mode]] <- value$surface
    fits[[mode]] <- value$fit
  }
  for (mode in c("IMMER_JML", "IMMER_EPS", "IMMER_BC")) {
    registry_row <- registry[registry$ModeId == mode, , drop = FALSE]
    value <- mfrmr_ti_fit_immer(
      prepared, row, registry_row, actual_extreme_n
    )
    mode_rows[[length(mode_rows) + 1L]] <- value$row
    surfaces[[mode]] <- value$surface
    fits[[mode]] <- value$fit
  }
  modes <- dplyr::bind_rows(mode_rows)
  recovery <- dplyr::bind_rows(lapply(names(surfaces), function(mode) {
    surface <- surfaces[[mode]]
    if (is.null(surface)) return(tibble::tibble())
    aligned <- mfrmr_ti_align_truth(surface, truth_surface)
    aligned$DatasetId <- as.character(row$DatasetId)
    aligned$PairId <- as.character(row$PairId)
    aligned$Model <- as.character(row$Model)
    aligned$ExtremeFraction <- as.numeric(row$ExtremeFraction)
    aligned$ModeId <- mode
    mode_index <- match(mode, modes$ModeId)
    aligned$Engine <- modes$Engine[mode_index]
    aligned$ScenarioId <- modes$ScenarioId[mode_index]
    aligned$OriginalRawEligible <- modes$OriginalRawEligible[mode_index]
    aligned$ExtremePolicy <- modes$ExtremePolicy[mode_index]
    aligned$BiasPolicy <- modes$BiasPolicy[mode_index]
    aligned
  }))
  invariants <- mfrmr_ti_invariants(row, modes, surfaces)
  list(
    modes = modes, recovery = recovery, invariants = invariants,
    surfaces = surfaces, truth_surface = truth_surface,
    prepared = prepared, fits = fits
  )
}

mfrmr_run_tam_immer_jml_mode_comparison <- function(
    tier = c("smoke", "pilot"), dry_run = FALSE,
    authorize_pilot = FALSE, progress = interactive()) {
  tier <- match.arg(tier)
  manifest <- mfrmr_ti_manifest(tier)
  if (isTRUE(dry_run)) return(manifest)
  if (identical(tier, "pilot") && !isTRUE(authorize_pilot)) {
    stop(
      "The 60-dataset Draft.75 pilot requires `authorize_pilot = TRUE`; ",
      "use `dry_run = TRUE` to inspect the manifest.", call. = FALSE
    )
  }
  mfrmr_ti_require()
  outputs <- vector("list", nrow(manifest))
  modes <- vector("list", nrow(manifest))
  recovery <- vector("list", nrow(manifest))
  invariants <- vector("list", nrow(manifest))
  for (i in seq_len(nrow(manifest))) {
    if (isTRUE(progress)) {
      message("[", i, "/", nrow(manifest), "] ", manifest$DatasetId[i])
    }
    value <- mfrmr_ti_fit_one(manifest[i, , drop = FALSE])
    outputs[[i]] <- value
    modes[[i]] <- value$modes
    recovery[[i]] <- value$recovery
    invariants[[i]] <- value$invariants
  }
  modes <- dplyr::bind_rows(modes)
  recovery <- dplyr::bind_rows(recovery)
  invariants <- dplyr::bind_rows(invariants)
  summary <- recovery |>
    dplyr::group_by(
      .data$Model, .data$ExtremeFraction, .data$ModeId,
      .data$Engine, .data$OriginalRawEligible,
      .data$ExtremePolicy, .data$BiasPolicy
    ) |>
    dplyr::summarise(
      Rows = dplyr::n(),
      RMSE = sqrt(mean(.data$ErrorAligned^2)),
      MAE = mean(abs(.data$ErrorAligned)),
      MaximumAbsoluteError = max(abs(.data$ErrorAligned)),
      .groups = "drop"
    )
  required_modes <- !modes$ModeId %in% c("TAM_RAW", "TAM_BC") |
    modes$ActualExtremeN == 0L
  contract_passed <- all(modes$FitReturned[required_modes]) &&
    all(modes$FiniteSurface[required_modes]) &&
    all(invariants$Passed[invariants$Required])
  list(
    ContractVersion = "mfrmr-tam-immer-jml-mode-comparison-v1",
    Tier = tier,
    RuntimeIdentity = mfrmr_ti_runtime_identity(),
    ModeRegistry = mfrmr_ti_mode_registry(),
    Manifest = manifest,
    Modes = modes,
    Recovery = recovery,
    Summary = summary,
    Invariants = invariants,
    Outputs = outputs,
    ContractPassed = contract_passed,
    EvidenceReady = FALSE,
    ReadinessEffect = "none_calibration_only",
    Limitations = paste(
      "RSM/PCM complete-crossed calibration only. External modes are",
      "method identities, not ground truth. No Person agreement, SE/coverage,",
      "numeric release threshold, correction selection, or confirmation."
    )
  )
}
