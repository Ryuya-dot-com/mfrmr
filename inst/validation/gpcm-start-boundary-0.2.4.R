# Repository-only multistart and finite-path audit. Run after pkgload::load_all().
# Reuses the four inputs and adaptive-Q61 fits in the continuous-integration archive.
# Paths hold nuisance coordinates fixed; no global boundary certificate is issued.
gsb_support <- function() {
  env <- new.env(parent = globalenv())
  sys.source("inst/validation/gpcm-continuous-integration-0.2.4.R", env)
  support <- env$gpi_support()
  for (name in c("gpi_reference", "gpi_qualified")) support[[name]] <- env[[name]]
  sys.source("inst/validation/gpcm-mml-continuous-binary-path-0.2.3.R", support)
  support
}

gsb_cases <- function() {
  c("complete-Criterion", "complete-Rater",
    "weak_bridge_weighted-Criterion", "weak_bridge_weighted-Rater")
}

gsb_input <- function(previous, case) {
  fit <- readRDS(file.path(previous, "refits", paste0(case, "-adaptive-61.rds")))
  data <- readRDS(file.path(previous, "refits", paste0(case, "-input.rds")))$data
  owner <- fit$config$slope_facet
  sizes <- mfrmr:::build_param_sizes(fit$config)
  stopifnot(fit$config$model == "GPCM", fit$config$method == "MML",
            fit$config$estimation_control$mml_integration == "adaptive",
            fit$config$step_facet == owner, length(fit$opt$par) == 23L)
  list(fit = fit, data = data, owner = owner, config = fit$config, sizes = sizes,
       idx = mfrmr:::build_indices(fit$prep, owner, owner),
       slices = mfrmr:::build_param_slices(sizes))
}

gsb_reference <- function(par, input, support) {
  tryCatch({
    a <- support$gpi_reference(par, input$owner, input$data, support, 32)
    b <- support$gpi_reference(par, input$owner, input$data, support, 64)
    list(qualified = support$gpi_qualified(a, b), nll = -sum(b$log_marginal),
         reference = a, refined = b, error = "")
  }, error = function(e) list(qualified = FALSE, nll = NA_real_, error = conditionMessage(e)))
}

run_gpcm_start_audit <- function(previous, output_dir) {
  support <- gsb_support()
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  rows <- list()
  for (case in gsb_cases()) {
    input <- gsb_input(previous, case)
    base <- input$fit$opt$par
    neutral <- rep(0, length(base))
    narrow <- wide <- forward <- reverse <- base
    narrow[input$slices$log_sigma2] <- log(.15^2)
    wide[input$slices$log_sigma2] <- log(4^2)
    narrow[input$slices$log_slopes] <- wide[input$slices$log_slopes] <- 0
    forward[input$slices$log_slopes] <- c(-1.5, -.5, .5)
    reverse[input$slices$log_slopes] <- c(1.5, .5, -.5)
    starts <- list(retained = base, neutral = neutral, narrow = narrow, wide = wide,
                   slope_forward = forward, slope_reverse = reverse)
    reference_base <- gsb_reference(base, input, support)
    stopifnot(reference_base$qualified)
    for (start in names(starts)) {
      key <- paste(case, start, sep = "-")
      cat(key, "\n")
      started <- proc.time()[["elapsed"]]
      captured <- if (start == "retained") list(value = input$fit$opt, warnings = character()) else
        tryCatch(support$mfrmr_gsapd_capture(mfrmr:::run_mfrm_direct_optimization(
          starts[[start]], "MML", input$idx, input$config, input$sizes,
          quad_points = 61L, maxit = 400L, reltol = 1e-10)), error = identity)
      row <- data.frame(Case = case, Start = start, Status = "error", Convergence = NA_integer_,
        Gradient = NA_real_, OwnNLL = NA_real_, ContinuousNLL = NA_real_,
        QualifiedReference = FALSE, NLLDiscrepancy = NA_real_,
        ContinuousNLLChange = NA_real_, MaxParameterChange = NA_real_,
        MinSlope = NA_real_, MaxSlope = NA_real_, PopulationSD = NA_real_,
        Elapsed = proc.time()[["elapsed"]] - started, Detail = "")
      evidence <- list(initial = starts[[start]], outcome = captured)
      if (inherits(captured, "error")) row$Detail <- conditionMessage(captured) else {
        opt <- captured$value
        reference <- gsb_reference(opt$par, input, support)
        evidence$continuous <- reference
        evaluation <- mfrmr:::mfrmr_make_adaptive_mml_evaluator(input$idx, input$config,
                                                               input$sizes, 61L)(opt$par)
        expanded <- support$gpk_unpack(opt$par, "MML", input$owner, support)
        row$Status <- "returned"
        row$Convergence <- opt$convergence
        row$Gradient <- max(abs(evaluation$gradient))
        row$OwnNLL <- evaluation$value
        row$ContinuousNLL <- reference$nll
        row$QualifiedReference <- reference$qualified
        row$NLLDiscrepancy <- evaluation$value - reference$nll
        row$ContinuousNLLChange <- reference$nll - reference_base$nll
        row$MaxParameterChange <- max(abs(opt$par - base))
        row$MinSlope <- min(expanded$parameters$slopes)
        row$MaxSlope <- max(expanded$parameters$slopes)
        row$PopulationSD <- expanded$sd
        row$Detail <- paste(c(captured$warnings, reference$error), collapse = " | ")
      }
      evidence$summary <- row
      saveRDS(evidence, file.path(output_dir, paste0(key, ".rds")))
      rows[[key]] <- row
      write.csv(do.call(rbind, rows), file.path(output_dir, "starts.csv"), row.names = FALSE)
    }
  }
  result <- do.call(rbind, rows)
  stopifnot(nrow(result) == 24L, !anyDuplicated(result[c("Case", "Start")]))
  invisible(result)
}

run_gpcm_finite_paths <- function(previous, output_dir) {
  support <- gsb_support()
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  rows <- list()
  for (case in gsb_cases()) {
    input <- gsb_input(previous, case)
    base <- input$fit$opt$par
    reference_base <- gsb_reference(base, input, support)
    stopifnot(reference_base$qualified)
    directions <- list()
    for (positive in 1:4) for (negative in setdiff(1:4, positive)) {
      full <- numeric(4L); full[positive] <- 1; full[negative] <- -1
      direction <- numeric(length(base)); direction[input$slices$log_slopes] <- full[1:3]
      directions[[paste0("slope_", positive, "_", negative)]] <- direction
    }
    for (sign in c(-1, 1)) {
      direction <- numeric(length(base)); direction[input$slices$log_sigma2] <- 2 * sign
      directions[[if (sign < 0) "sd_down" else "sd_up"]] <- direction
    }
    for (path in names(directions)) for (distance in c(.5, 1.5, 3)) {
      key <- paste(case, path, distance, sep = "-")
      cat(key, "\n")
      par <- base + distance * directions[[path]]
      reference <- gsb_reference(par, input, support)
      expanded <- support$gpk_unpack(par, "MML", input$owner, support)
      row <- data.frame(Case = case, Path = path, Distance = distance,
        QualifiedReference = reference$qualified, ContinuousNLL = reference$nll,
        ChangeFromRetained = reference$nll - reference_base$nll,
        MinSlope = min(expanded$parameters$slopes), MaxSlope = max(expanded$parameters$slopes),
        PopulationSD = expanded$sd, Detail = reference$error)
      saveRDS(list(par = par, reference = reference, summary = row),
              file.path(output_dir, paste0(key, ".rds")))
      rows[[key]] <- row
      write.csv(do.call(rbind, rows), file.path(output_dir, "paths.csv"), row.names = FALSE)
    }
    # Exact zero-variance endpoint with the other coordinates held fixed.
    # One conditional category distribution per facet pair, evaluated at mu.
    x <- support$gpk_unpack(base, "MML", input$owner, support)
    adjacent <- support$mfrmr_gsap_adjacent_logits(x$mean, x$parameters, "complete_predictor")
    kernel <- cbind(0, t(apply(adjacent, 1L, cumsum)))
    centered <- kernel - apply(kernel, 1L, max)
    log_probability <- centered - log(rowSums(exp(centered)))
    other <- setdiff(c("Rater", "Criterion"), input$owner)
    oi <- match(input$data[[input$owner]], paste0(substr(input$owner, 1, 1), 1:4))
    ri <- match(input$data[[other]], paste0(substr(other, 1, 1), 1:4))
    nll <- -sum(input$data$Weight * log_probability[cbind(ri + 4L * (oi - 1L), input$data$Score + 1L)])
    rows[[paste0(case, "-sd_zero")]] <- data.frame(Case = case, Path = "sd_zero",
      Distance = Inf, QualifiedReference = TRUE, ContinuousNLL = nll,
      ChangeFromRetained = nll - reference_base$nll,
      MinSlope = min(x$parameters$slopes), MaxSlope = max(x$parameters$slopes),
      PopulationSD = 0, Detail = "exact conditional endpoint; nuisance coordinates not refitted")
    write.csv(do.call(rbind, rows), file.path(output_dir, "paths.csv"), row.names = FALSE)
  }
  # The existing analytic binary control improves toward a slope boundary.
  # It checks the improvement direction without transferring a certificate to
  # the unrelated four polytomous datasets.
  positive <- do.call(rbind, lapply(c(0, .5, 1.5, 3), support$mfrmr_gmcb_point))
  write.csv(positive, file.path(output_dir, "positive-control.csv"), row.names = FALSE)
  stopifnot(all(diff(-log(positive$MarginalProbability)) < 0),
            all(positive$AnalyticDerivative[-1] > 0),
            all(abs(positive$PairIdentityDifference) < 1e-10), length(rows) == 172L)
  invisible(do.call(rbind, rows))
}

verify_gpcm_convergence_reports <- function(previous, output_dir, old_reporting) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  old <- new.env(parent = asNamespace("mfrmr"))
  sys.source(old_reporting, old)
  support <- gsb_support()
  rows <- lapply(gsb_cases(), function(case) {
    fit <- gsb_input(previous, case)$fit
    state <- mfrmr:::mfrm_convergence_state(fit$summary)
    before <- old$summarize_convergence_metrics(fit$summary)
    after <- mfrmr:::summarize_convergence_metrics(fit$summary)
    captured <- support$mfrmr_gsapd_capture({
      diagnostics <- diagnose_mfrm(fit, residual_pca = "none")
      list(brief = summary(fit, diagnostics = diagnostics),
           apa = build_apa_outputs(fit, diagnostics))
    })
    result <- captured$value
    row <- data.frame(Case = case, CodeConverged = state$code_converged,
      NumericalPass = identical(state$severity, "pass"), InferenceReady = state$inference_ready,
      BeforeUnknown = grepl("had unknown convergence status", before, fixed = TRUE),
      AfterNumericalPass = grepl("met the numerical convergence checks", after, fixed = TRUE),
      APANumericalPass = grepl("met the numerical convergence checks",
                              gsub("[[:space:]]+", " ", result$apa$report_text), fixed = TRUE),
      BriefFormalInference = result$brief$decision$FormalInference,
      APAFormalInference = result$apa$decision$FormalInference)
    stopifnot(row$CodeConverged, row$NumericalPass, !row$InferenceReady,
              row$BeforeUnknown, row$AfterNumericalPass, row$APANumericalPass,
              row$BriefFormalInference == "No", row$APAFormalInference == "No")
    saveRDS(list(before = before, after = after, output = captured, summary = row),
            file.path(output_dir, paste0(case, ".rds")))
    writeLines(as.character(result$apa$report_text), file.path(output_dir, paste0(case, "-apa.txt")))
    row
  })
  result <- do.call(rbind, rows)
  write.csv(result, file.path(output_dir, "reporting.csv"), row.names = FALSE)
  invisible(result)
}

refine_gpcm_finite_paths <- function(previous, paths_dir, output_dir) {
  support <- gsb_support()
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  initial <- read.csv(file.path(paths_dir, "paths.csv"))
  stopifnot(nrow(initial) == 172L)
  selected <- initial[!initial$QualifiedReference, , drop = FALSE]
  rows <- lapply(seq_len(nrow(selected)), function(i) {
    row <- selected[i, ]
    key <- paste(row$Case, row$Path, row$Distance, sep = "-")
    cat(key, "\n")
    point <- readRDS(file.path(paths_dir, paste0(key, ".rds")))
    input <- gsb_input(previous, row$Case)
    a <- point$reference$refined
    b <- support$gpi_reference(point$par, input$owner, input$data, support, 128)
    base <- gsb_reference(input$fit$opt$par, input, support)
    stopifnot(base$qualified)
    row$QualifiedReference <- support$gpi_qualified(a, b)
    row$ContinuousNLL <- -sum(b$log_marginal)
    row$ChangeFromRetained <- row$ContinuousNLL - base$nll
    row$Detail <- "follow-up: local limits 64 versus 128; original tolerances unchanged"
    saveRDS(list(par = point$par, reference = a, refined = b, summary = row),
            file.path(output_dir, paste0(key, ".rds")))
    row
  })
  result <- if (length(rows)) do.call(rbind, rows) else selected
  write.csv(result, file.path(output_dir, "paths-refined.csv"), row.names = FALSE)
  invisible(result)
}

summarize_gpcm_start_boundary <- function(previous, output_dir) {
  support <- gsb_support()
  starts <- read.csv(file.path(output_dir, "starts", "starts.csv"))
  paths <- read.csv(file.path(output_dir, "paths", "paths.csv"))
  refined <- read.csv(file.path(output_dir, "paths-refinement", "paths-refined.csv"))
  key <- function(x) paste(x$Case, x$Path, x$Distance, sep = "-")
  stopifnot(nrow(starts) == 24L, nrow(paths) == 172L,
            !anyDuplicated(starts[c("Case", "Start")]), !anyDuplicated(key(paths)),
            identical(sort(key(refined)), sort(key(paths[!paths$QualifiedReference, ]))))
  paths[match(key(refined), key(paths)), ] <- refined
  rows <- lapply(gsb_cases(), function(case) {
    s <- starts[starts$Case == case, ]
    p <- paths[paths$Case == case, ]
    input <- gsb_input(previous, case)
    b <- readRDS(file.path(output_dir, "starts", paste0(case, "-retained.rds")))
    candidates <- lapply(s$Start, function(k) {
      readRDS(file.path(output_dir, "starts", paste0(case, "-", k, ".rds")))
    })
    base_slopes <- support$gpk_unpack(b$outcome$value$par, "MML", input$owner, support)$parameters$slopes
    slope_changes <- vapply(candidates, function(x) {
      max(abs(support$gpk_unpack(x$outcome$value$par, "MML", input$owner, support)$parameters$slopes - base_slopes))
    }, 0.0)
    stopifnot(nrow(s) == 6L, nrow(p) == 43L, all(s$Status == "returned"),
              all(s$Convergence == 0L), all(s$Gradient < 1e-4),
              all(s$QualifiedReference), all(p$QualifiedReference))
    data.frame(Case = case, Candidates = nrow(s), MaxGradient = max(s$Gradient),
      ContinuousNLLRange = diff(range(s$ContinuousNLL)),
      MaxParameterChange = max(s$MaxParameterChange), MaxSlopeChange = max(slope_changes),
      PopulationSDRange = diff(range(s$PopulationSD)),
      MaxEAPChange = max(vapply(candidates, function(x) max(abs(x$continuous$refined$eap - b$continuous$refined$eap)), 0.0)),
      MaxPosteriorSDChange = max(vapply(candidates, function(x) max(abs(x$continuous$refined$sd - b$continuous$refined$sd)), 0.0)),
      FinitePoints = sum(is.finite(p$Distance)),
      MinimumFiniteNLLIncrease = min(p$ChangeFromRetained[is.finite(p$Distance)]),
      ZeroSDNLLIncrease = p$ChangeFromRetained[p$Path == "sd_zero"],
      MinPathSlope = min(p$MinSlope), MaxPathSlope = max(p$MaxSlope),
      MinPositivePathSD = min(p$PopulationSD[p$PopulationSD > 0]), MaxPathSD = max(p$PopulationSD))
  })
  result <- do.call(rbind, rows)
  write.csv(paths, file.path(output_dir, "paths-final.csv"), row.names = FALSE)
  write.csv(result, file.path(output_dir, "summary.csv"), row.names = FALSE)
  invisible(result)
}
