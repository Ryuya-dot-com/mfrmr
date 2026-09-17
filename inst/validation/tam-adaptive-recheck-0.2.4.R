# Repository-only follow-up; see the frozen plan beside this file.
run_tam_adaptive_recheck <- function(output_dir, platform = c("macos", "linux")) {
  platform <- match.arg(platform)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  rsm <- new.env(parent = globalenv())
  sys.source("inst/validation/tam-mml-release-stress-0.2.4.R", rsm)
  pcm <- new.env(parent = globalenv())
  sys.source("inst/validation/tam-mml-release-stress-0.2.4.R", pcm)
  sys.source("inst/validation/tam-pcm-mml-conditional-stress-0.2.4.R", pcm)
  pcm_plan <- pcm$mfrmr_tpcm_plan(pcm)
  pcm$mfrmr_tpcm_install_core(pcm)
  source("inst/validation/adaptive-quadrature-review-0.2.4.R", local = environment())
  cores <- list(RSM = rsm, PCM = pcm)
  plan <- rbind(rsm$mfrmr_tms_plan(), pcm_plan)
  plan <- plan[!duplicated(plan$DatasetId), ]
  if (platform == "linux") plan <- plan[plan$Replicate == 1L &
    plan$PopulationMode == "fixed_standard_normal", ]
  runtime <- data.frame(package = c("mfrmr", "TAM", "TAM"),
    version = c(as.character(packageVersion("mfrmr")), rep(as.character(packageVersion("TAM")), 2)),
    function_name = c("fit_mfrm", "tam.mml", "tam.mml.mfr"),
    sha256 = vapply(list(mfrmr::fit_mfrm, TAM::tam.mml, TAM::tam.mml.mfr),
      rsm$mfrmr_tms_function_hash, ""))
  # Reviewed before any Linux numerical runs: the two installed bodies differ
  # only in rounding of the initial deviance.min sentinel (approximately 1e100).
  expected_tam <- if (platform == "linux") c(
    "e021213c65ecd3a54231661c0a2980244be4da7745d44ce6dde430b8d147216b",
    "c5baaf49013d2f4546dd8485bccb1b457c00196cf7c1eba5bdfe172aee42812c"
  ) else unname(rsm$mfrmr_tms_expected_tam_hashes)
  write.csv(runtime, file.path(output_dir, "runtime.csv"), row.names = FALSE)
  stopifnot(all(runtime$version[-1] == rsm$mfrmr_tms_expected_tam_version),
    identical(runtime$sha256[-1], expected_tam),
    "mml_integration" %in% names(formals(mfrmr::fit_mfrm)))
  capture.output(sessionInfo(), file = file.path(output_dir, "session.txt"))
  history <- dplyr::bind_rows(
    read.csv("inst/validation/tam-mml-release-stress-summary-0.2.4.csv"),
    read.csv("inst/validation/tam-pcm-mml-conditional-stress-summary-0.2.4.csv"))
  inputs <- lapply(seq_len(nrow(plan)), function(i) {
    row <- plan[i, ]; core <- cores[[row$Model]]
    data <- core$mfrmr_tms_generate(row)
    prepared <- core$mfrmr_tms_prepare_tam(data)
    expected <- unique(history$InputSHA256[history$DatasetId == row$DatasetId])
    stopifnot(length(expected) == 1L, prepared$input_hash == expected)
    list(data = data, prepared = prepared)
  })
  plan$InputSHA256 <- vapply(inputs, function(x) x$prepared$input_hash, "")
  write.csv(plan, file.path(output_dir, "plan.csv"), row.names = FALSE)
  saveRDS(inputs, file.path(output_dir, "inputs.rds"))
  tables <- list(runs = list(), comparisons = list(), reference = list(),
                 restarts = list(), covariance = list(), surfaces = list(), scores = list())
  append <- function(name, value) {
    tables[[name]][[length(tables[[name]]) + 1L]] <<- value
  }
  write_tables <- function() for (name in names(tables)) {
    if (length(tables[[name]])) write.csv(dplyr::bind_rows(tables[[name]]),
      file.path(output_dir, paste0(name, ".csv")), row.names = FALSE)
  }
  attempt <- function(expr) {
    warnings <- messages <- character()
    started <- proc.time()[["elapsed"]]
    value <- withCallingHandlers(tryCatch(expr, error = identity),
      warning = function(w) { warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning") },
      message = function(m) { messages <<- c(messages, conditionMessage(m)); invokeRestart("muffleMessage") })
    list(value = value, elapsed = proc.time()[["elapsed"]] - started,
      warnings = paste(unique(warnings), collapse = " | "),
      messages = paste(unique(messages), collapse = " | "),
      error = if (inherits(value, "error")) conditionMessage(value) else "")
  }
  for (i in seq_len(nrow(plan))) {
    row <- plan[i, ]; core <- cores[[row$Model]]
    data <- inputs[[i]]$data; prepared <- inputs[[i]]$prepared
    message(i, "/", nrow(plan), " ", row$DatasetId)
    fitted <- list()
    specs <- data.frame(engine = c(rep("mfrmr", 5), rep("TAM", 4)),
      integration = c("fixed", "fixed", rep("adaptive", 3), rep("equal_spacing", 4)),
      q = c(31L, 61L, 15L, 31L, 61L, 31L, 61L, 181L, 301L),
      range = c(rep(NA_real_, 5), rep(if (row$Model == "RSM") 6 else 8, 2), 8, 8))
    for (j in seq_len(nrow(specs))) {
      spec <- specs[j, ]
      key <- paste(spec$engine, spec$integration, spec$q, sep = "_")
      run <- attempt({
        estimated <- row$PopulationMode == "estimated_intercept_only"
        if (spec$engine == "mfrmr") {
          args <- list(data = data, person = "Person", facets = c("Rater", "Criterion"),
            score = "Score", rating_min = 1L, rating_max = 4L, model = row$Model,
            method = "MML", mml_engine = "direct", mml_integration = spec$integration,
            step_facet = if (row$Model == "PCM") "Criterion" else NULL,
            quad_points = spec$q, maxit = 1000L, reltol = 1e-12)
          if (estimated) {
            args$population_formula <- stats::as.formula("~ 1", env = baseenv())
            args$person_data <- data.frame(Person = prepared$persons)
          }
          fit <- do.call(mfrmr::fit_mfrm, args)
          surface <- core$mfrmr_tms_mfrmr_surface(fit, prepared$item_map)$MfrmrEstimate
          score <- mfrmr::predict_mfrm_units(fit, data, scoring_quad_points = spec$q,
            readiness_policy = "review")$estimates
          index <- match(prepared$persons, score$Person)
          stopifnot(!anyNA(index))
          covariance <- if (spec$integration == "adaptive" && spec$q >= 31L) {
            mfrmr:::compute_mml_parameter_covariance(fit)
          } else NULL
          if (!is.null(covariance$cov)) append("covariance", data.frame(
            DatasetId = row$DatasetId, Run = key, Coordinate = seq_len(nrow(covariance$cov)),
            Variance = diag(covariance$cov), Status = covariance$status))
          list(fit = fit, surface = surface, eap = score$Estimate[index], sd = score$SD[index],
            deviance = fit$summary$Deviance, raw_deviance = fit$summary$Deviance,
            mean = if (estimated) unname(fit$population$coefficients["(Intercept)"]) else 0,
            variance = if (estimated) fit$population$sigma2 else 1,
            gradient = fit$summary$TerminalGradientSupNorm,
            ready = fit$summary$InferenceReady,
            converged = fit$summary$ConvergenceStatus == "converged", iterations = NA_integer_)
        } else {
          fit <- TAM::tam.mml(resp = prepared$resp, A = prepared$A, pweights = prepared$pweights,
            beta.fixed = if (estimated) FALSE else cbind(1, 1, 0), est.variance = estimated,
            control = list(nodes = seq(-spec$range, spec$range, length.out = spec$q),
              snodes = 0L, QMC = TRUE, maxiter = 1000L, conv = 1e-8, convD = 1e-8,
              convM = 1e-8, Msteps = 20L, progress = FALSE), verbose = FALSE)
          score <- fit$person[seq_len(prepared$real_person_count), ]
          list(fit = fit, surface = as.numeric(t(-as.matrix(fit$AXsi)[, -1L, drop = FALSE])),
            eap = score$EAP, sd = score$SD.EAP,
            deviance = fit$deviance * prepared$deviance_scale, raw_deviance = fit$deviance,
            mean = if (estimated) fit$beta[1L, 1L] else 0,
            variance = if (estimated) fit$variance[1L, 1L] else 1,
            gradient = NA_real_, ready = NA, converged = fit$iter < 1000L, iterations = fit$iter)
        }
      })
      entry <- data.frame(DatasetId = row$DatasetId, Model = row$Model, Profile = row$ProfileId,
        PopulationMode = row$PopulationMode, Replicate = row$Replicate, Run = key, spec,
        Elapsed = run$elapsed, Warnings = run$warnings, Messages = run$messages, Error = run$error)
      if (!nzchar(run$error)) {
        value <- run$value
        fitted[[key]] <- value
        entry$Deviance <- value$deviance; entry$RawDeviance <- value$raw_deviance
        entry$Mean <- value$mean; entry$Variance <- value$variance
        entry$Gradient <- value$gradient; entry$Converged <- value$converged
        entry$InferenceReady <- value$ready; entry$Iterations <- value$iterations
        append("surfaces", data.frame(DatasetId = row$DatasetId, Run = key,
          Coordinate = seq_along(value$surface), Estimate = value$surface))
        append("scores", data.frame(DatasetId = row$DatasetId, Run = key,
          Person = prepared$persons, EAP = value$eap, SD = value$sd))
      }
      append("runs", entry)
    }
    compare <- function(a, b, role) {
      left <- fitted[[a]]; right <- fitted[[b]]
      values <- rep(NA_real_, 6)
      if (!is.null(left) && !is.null(right)) values <- c(
        abs(left$deviance - right$deviance), max(abs(left$surface - right$surface)),
        max(abs(left$eap - right$eap)), max(abs(left$sd - right$sd)),
        abs(left$mean - right$mean), abs(left$variance - right$variance))
      out <- data.frame(DatasetId = row$DatasetId, A = a, B = b, Role = role,
        Deviance = values[1], Surface = values[2], EAP = values[3], SD = values[4],
        Mean = values[5], Variance = values[6])
      tolerance <- if (role == "order_movement") 1e-3 else 1e-4
      out$WithinBound <- all(is.finite(values)) && all(values <= tolerance)
      out$EnginesConverged <- isTRUE(left$converged) && isTRUE(right$converged)
      append("comparisons", out)
    }
    for (q in c(31L, 61L)) {
      compare(paste0("mfrmr_fixed_", q), paste0("TAM_equal_spacing_", q), "historical_grid")
      compare(paste0("mfrmr_adaptive_", q), "TAM_equal_spacing_301", "primary")
    }
    compare("mfrmr_adaptive_15", "mfrmr_adaptive_31", "order_movement")
    compare("mfrmr_adaptive_31", "mfrmr_adaptive_61", "order_movement")
    compare("mfrmr_fixed_31", "mfrmr_fixed_61", "order_movement")
    compare("TAM_equal_spacing_181", "TAM_equal_spacing_301", "order_movement")
    for (key in c("mfrmr_adaptive_61", "TAM_equal_spacing_301")) {
      value <- fitted[[key]]
      reference <- attempt({
        stopifnot(!is.null(value))
        cumulative <- matrix(value$surface, ncol = 3L, byrow = TRUE)
        steps <- cumulative - cbind(0, cumulative[, 1:2, drop = FALSE])
        item <- match(paste(data$Rater, data$Criterion),
          paste(prepared$item_map$Rater, prepared$item_map$Criterion))
        groups <- split(seq_len(nrow(data)), factor(data$Person, levels = prepared$persons))
        result <- t(vapply(groups, function(rows) aq_continuous_reference(
          data$Score[rows] - 1L, rep(0, length(rows)), steps[item[rows], , drop = FALSE],
          rep(1, length(rows)), rep(1, length(rows)), value$mean, sqrt(value$variance)), numeric(5)))
        data.frame(Person = prepared$persons, result, EAPError = result[, "eap"] - value$eap,
          SDError = result[, "sd"] - value$sd, TotalDevianceError =
            -2 * sum(result[, "log_marginal"]) - value$deviance, row.names = NULL)
      })
      append("reference", dplyr::bind_cols(data.frame(DatasetId = row$DatasetId, Run = key,
        Error = reference$error), if (!nzchar(reference$error)) reference$value else data.frame(Available = FALSE)))
    }
    baseline <- fitted$mfrmr_adaptive_31
    for (start in c("fixed31", "perturbed61")) {
      restart <- attempt({
        stopifnot(!is.null(baseline))
        fit <- baseline$fit; config <- fit$config
        sizes <- mfrmr:::build_param_sizes(config)
        idx <- mfrmr:::build_indices(fit$prep, config$step_facet, config$slope_facet, config$interaction_specs)
        cache <- mfrmr:::make_param_cache(sizes, config, idx, is_mml = TRUE)
        evaluate <- mfrmr:::make_mfrm_direct_evaluator("MML", cache, idx, config, sizes,
          mfrmr:::gauss_hermite_normal(31L))
        initial <- if (start == "fixed31") fitted$mfrmr_fixed_31$fit$opt$par else {
          par <- fitted$mfrmr_adaptive_61$fit$opt$par
          par + 0.3 * sin(seq_along(par))
        }
        stopifnot(length(initial) == length(fit$opt$par))
        opt <- stats::optim(initial, evaluate$value, evaluate$gradient, method = "BFGS",
          control = list(maxit = 200L, reltol = 1e-12))
        initial_gradient <- max(abs(evaluate$gradient(opt$par)))
        initial_nll <- opt$value
        if (initial_gradient > 1e-4) opt <- stats::optim(opt$par,
          evaluate$value, evaluate$gradient, method = "BFGS", control = list(maxit = 200L, reltol = 1e-14))
        data.frame(Convergence = opt$convergence, InitialGradient = initial_gradient,
          Gradient = max(abs(evaluate$gradient(opt$par))), PolishImprovement = initial_nll - opt$value,
          NLLChange = opt$value - fit$opt$value, ParameterChange = max(abs(opt$par - fit$opt$par)))
      })
      append("restarts", dplyr::bind_cols(data.frame(DatasetId = row$DatasetId, Start = start,
        Elapsed = restart$elapsed, Error = restart$error),
        if (!nzchar(restart$error)) restart$value else data.frame(Available = FALSE)))
    }
    saveRDS(fitted, file.path(output_dir, paste0(row$DatasetId, ".rds")))
    write_tables()
  }
  result <- lapply(tables, dplyr::bind_rows)
  stopifnot(nrow(result$runs) == nrow(plan) * 9L,
    nrow(result$comparisons) == nrow(plan) * 8L,
    nrow(result$restarts) == nrow(plan) * 2L)
  invisible(result)
}

# Adjudicate the frozen comparisons without replacing unsuccessful diagnostics.
summarize_tam_adaptive_recheck <- function(raw_root, output_prefix) {
  read <- function(platform, table) read.csv(file.path(raw_root, platform,
    paste0(table, ".csv")), stringsAsFactors = FALSE,
    colClasses = if (table %in% c("runs", "reference", "restarts")) c(Error = "character") else NA_character_)
  primary <- list()
  for (platform in c("macos", "linux")) {
    plan <- read(platform, "plan"); runs <- read(platform, "runs")
    comparisons <- read(platform, "comparisons"); reference <- read(platform, "reference")
    restarts <- read(platform, "restarts"); covariance <- read(platform, "covariance")
    stopifnot(nrow(plan) == if (platform == "macos") 36L else 10L,
      nrow(runs) == nrow(plan) * 9L, nrow(comparisons) == nrow(plan) * 8L,
      nrow(restarts) == nrow(plan) * 2L)
    for (id in plan$DatasetId) {
      ref <- reference[reference$DatasetId == id, ]
      ref_values <- c(ref$TotalDevianceError / 2, ref$EAPError, ref$SDError)
      reference_ok <- nrow(ref) == 160L && all(ref$Error == "") &&
        all(is.finite(ref_values)) && all(abs(ref_values) < 1e-7) &&
        all(is.finite(ref$relative_error)) && all(ref$relative_error < 1e-9) &&
        all(ref$log_relative_tail_bound < log(1e-12))
      order <- comparisons[comparisons$DatasetId == id &
        comparisons$A == "TAM_equal_spacing_181", ]
      stopifnot(nrow(order) == 1L)
      restart <- restarts[restarts$DatasetId == id, ]
      cov <- covariance[covariance$DatasetId == id, ]
      cov <- merge(cov[cov$Run == "mfrmr_adaptive_31", ],
        cov[cov$Run == "mfrmr_adaptive_61", ], by = "Coordinate")
      cov_ok <- nrow(cov) > 0L && all(is.finite(cov$Variance.x)) &&
        all(is.finite(cov$Variance.y)) && all(cov$Variance.x > 0) && all(cov$Variance.y > 0)
      for (q in c(31L, 61L)) {
        row <- comparisons[comparisons$DatasetId == id & comparisons$Role == "primary" &
          comparisons$A == paste0("mfrmr_adaptive_", q), ]
        run <- runs[runs$DatasetId == id & runs$Run == row$A, ]
        stopifnot(nrow(row) == 1L, nrow(run) == 1L)
        row$Platform <- platform; row$Model <- run$Model; row$Profile <- run$Profile
        row$PopulationMode <- run$PopulationMode; row$Gradient <- run$Gradient
        row$GradientWithinBound <- is.finite(run$Gradient) && run$Gradient < 1e-4
        row$TAMOrderStable <- isTRUE(order$WithinBound) && isTRUE(order$EnginesConverged)
        row$IndependentReferenceWithinBound <- isTRUE(reference_ok)
        row$PrimaryPass <- isTRUE(row$WithinBound) && isTRUE(row$EnginesConverged) &&
          row$GradientWithinBound && row$TAMOrderStable && row$IndependentReferenceWithinBound
        row$InferenceReady <- run$InferenceReady
        row$RestartCount <- nrow(restart)
        row$StationaryRestarts <- sum(restart$Error == "" & restart$Convergence == 0 &
          is.finite(restart$Gradient) & restart$Gradient < 1e-4, na.rm = TRUE)
        row$MaxRestartGradient <- max(restart$Gradient)
        row$MaxRestartParameterChange <- max(abs(restart$ParameterChange))
        row$MaxRestartNLLChange <- max(abs(restart$NLLChange))
        row$MaxReferenceLogLikError <- max(abs(ref$TotalDevianceError / 2))
        row$MaxReferenceEAPError <- max(abs(ref$EAPError))
        row$MaxReferenceSDError <- max(abs(ref$SDError))
        row$FinitePositiveCovarianceDiagonals <- cov_ok
        row$MaxSEOrderChange <- if (cov_ok) max(abs(sqrt(cov$Variance.x) - sqrt(cov$Variance.y))) else NA_real_
        row$MaxRelativeSEOrderChange <- if (cov_ok) max(abs(sqrt(cov$Variance.x / cov$Variance.y) - 1)) else NA_real_
        primary[[length(primary) + 1L]] <- row
      }
    }
  }
  primary <- do.call(rbind, primary)
  cross <- list()
  mac_runs <- read("macos", "runs"); linux_runs <- read("linux", "runs")
  surfaces <- merge(read("macos", "surfaces"), read("linux", "surfaces"),
    by = c("DatasetId", "Run", "Coordinate"))
  scores <- merge(read("macos", "scores"), read("linux", "scores"),
    by = c("DatasetId", "Run", "Person"))
  for (i in seq_len(nrow(linux_runs))) {
    linux <- linux_runs[i, ]
    mac <- mac_runs[mac_runs$DatasetId == linux$DatasetId & mac_runs$Run == linux$Run, ]
    s <- surfaces[surfaces$DatasetId == linux$DatasetId & surfaces$Run == linux$Run, ]
    p <- scores[scores$DatasetId == linux$DatasetId & scores$Run == linux$Run, ]
    stopifnot(nrow(mac) == 1L)
    cross[[i]] <- data.frame(DatasetId = linux$DatasetId, Run = linux$Run,
      BothExecuted = mac$Error == "" && linux$Error == "", SurfaceCount = nrow(s), PersonCount = nrow(p),
      Deviance = abs(mac$Deviance - linux$Deviance), Surface = max(abs(s$Estimate.x - s$Estimate.y)),
      EAP = max(abs(p$EAP.x - p$EAP.y)), SD = max(abs(p$SD.x - p$SD.y)),
      Mean = abs(mac$Mean - linux$Mean), Variance = abs(mac$Variance - linux$Variance))
  }
  cross <- do.call(rbind, cross)
  stopifnot(nrow(primary) == 92L, !anyNA(primary$PrimaryPass), nrow(cross) == 90L)
  write.csv(primary, paste0(output_prefix, "-results.csv"), row.names = FALSE)
  write.csv(cross, paste0(output_prefix, "-platforms.csv"), row.names = FALSE)
  invisible(list(primary = primary, platforms = cross))
}

# Post-hoc diagnostic: retry every nonstationary standalone restart with the
# existing public optimizer policy, from its original start. Do not overwrite
# the frozen BFGS results or change their classification.
followup_tam_adaptive_restarts <- function(raw_dir) {
  restarts <- read.csv(file.path(raw_dir, "restarts.csv"), colClasses = c(Error = "character"))
  selected <- restarts[restarts$Error != "" | !is.finite(restarts$Gradient) |
    restarts$Gradient >= 1e-4 | restarts$Convergence != 0, ]
  results <- stages <- list()
  for (i in seq_len(nrow(selected))) {
    row <- selected[i, ]
    fits <- readRDS(file.path(raw_dir, paste0(row$DatasetId, ".rds")))
    fit <- fits$mfrmr_adaptive_31$fit; config <- fit$config
    sizes <- mfrmr:::build_param_sizes(config)
    idx <- mfrmr:::build_indices(fit$prep, config$step_facet, config$slope_facet, config$interaction_specs)
    initial <- if (row$Start == "fixed31") fits$mfrmr_fixed_31$fit$opt$par else {
      par <- fits$mfrmr_adaptive_61$fit$opt$par
      par + 0.3 * sin(seq_along(par))
    }
    opt <- mfrmr:::run_mfrm_direct_optimization(initial, "MML", idx, config, sizes,
      quad_points = 31L, maxit = 200L, reltol = 1e-12, optimizer = "auto")
    results[[i]] <- data.frame(DatasetId = row$DatasetId, Start = row$Start,
      FrozenRestartGradient = row$Gradient,
      Gradient = opt$optimizer_diagnostics$TerminalGradientSupNorm,
      Convergence = opt$convergence, NLLChange = opt$value - fit$opt$value,
      ParameterChange = max(abs(opt$par - fit$opt$par)),
      Method = opt$optimizer_plan$Used, PolishStages = opt$optimizer_plan$PolishStages)
    stages[[i]] <- cbind(DatasetId = row$DatasetId, Start = row$Start, opt$optimizer_polish$Stages)
    saveRDS(opt, file.path(raw_dir, paste0(row$DatasetId, "-", row$Start, "-followup.rds")))
  }
  result <- dplyr::bind_rows(results)
  stopifnot(nrow(result) == nrow(selected))
  write.csv(result, file.path(raw_dir, "restart-followup.csv"), row.names = FALSE)
  write.csv(dplyr::bind_rows(stages), file.path(raw_dir, "restart-followup-stages.csv"), row.names = FALSE)
  invisible(result)
}
