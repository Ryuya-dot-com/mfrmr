# Repository audit, run from the development root after pkgload::load_all().
# Source this file, then run_gpcm_continuous_points(previous_archive, output_dir)
# and run_gpcm_continuous_refits(output_dir). No production defaults are changed.
gpi_support <- function() {
  env <- new.env(parent = globalenv())
  for (file in c("gpcm-paired-owner-kernel-0.2.4.R",
                 "gpcm-slope-action-projection-p3a-0.2.3.R",
                 "adaptive-quadrature-review-0.2.4.R",
                 "gpcm-slope-action-public-mml-bridge-p3d-0.2.3.R")) {
    sys.source(file.path("inst", "validation", file), env)
  }
  env
}

gpi_reference <- function(par, owner, data, support, limit = 32) {
  # Independent expansion and raw-label indexing, including owner locations
  # in transition boundaries; no production parameter/index/probability code.
  x <- support$gpk_unpack(par, "MML", owner, support)
  other <- setdiff(c("Rater", "Criterion"), owner)
  oi <- match(data[[owner]], paste0(substr(owner, 1, 1), 1:4))
  ri <- match(data[[other]], paste0(substr(other, 1, 1), 1:4))
  do.call(rbind, lapply(split(seq_len(nrow(data)), data$Person), function(rows) {
    value <- support$aq_continuous_reference(
      data$Score[rows], -x$parameters$severities[ri[rows]],
      x$parameters$boundaries[oi[rows], , drop = FALSE],
      x$parameters$slopes[oi[rows]], data$Weight[rows], x$mean, x$sd, limit)
    data.frame(Person = data$Person[rows[1]], as.list(value), row.names = NULL)
  }))
}

gpi_qualified <- function(reference, refined) {
  stopifnot(identical(reference$Person, refined$Person))
  all(is.finite(as.matrix(refined[, 2:6]))) &&
    max(abs(as.matrix(reference[, 2:4]) - as.matrix(refined[, 2:4]))) < 1e-8 &&
    max(refined$relative_error) < 1e-9 &&
    max(refined$log_relative_tail_bound) < log(1e-12)
}

run_gpcm_continuous_points <- function(previous_archive, output_dir,
                                        fixed_orders = c(31L, 61L, 121L, 181L, 301L),
                                        adaptive_orders = c(31L, 61L, 121L)) {
  support <- gpi_support()
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  contexts <- readRDS(file.path(previous_archive, "results", "contexts.rds"))
  coordinates <- read.csv(file.path(previous_archive, "results", "gradients.csv"))
  references <- persons <- checks <- list()
  for (key in names(contexts)[grepl("/MML/", names(contexts))]) {
    context <- contexts[[key]]
    design <- strsplit(key, "/")[[1]][1]
    owner <- context$config$slope_facet
    data <- support$gpk_data(design)
    for (point in c("moderate", "wide_slopes")) {
      case <- paste(key, point, sep = "/")
      cat(case, "\n")
      saved <- coordinates[coordinates$Case == paste0(case, "/31") &
                             coordinates$Step == 1e-5, ]
      par <- saved$Parameter[order(saved$Coordinate)]
      stopifnot(length(par) == 23L)
      reference <- gpi_reference(par, owner, data, support)
      refined <- gpi_reference(par, owner, data, support, 64)
      references[[case]] <- rbind(cbind(Case = case, Limit = 32, reference),
                                   cbind(Case = case, Limit = 64, refined))
      checks[[case]] <- data.frame(Case = case,
        Qualified = gpi_qualified(reference, refined),
        RefinementChange = max(abs(as.matrix(reference[, 2:4]) - as.matrix(refined[, 2:4]))),
        RelativeError = max(refined$relative_error),
        LogRelativeTailBound = max(refined$log_relative_tail_bound))
      params <- mfrmr:::expand_params(par, context$sizes, context$config)
      for (q in fixed_orders) {
        review <- mfrmr:::mfrmr_adaptive_quadrature_review(
          context$idx, context$config, params, mfrmr:::gauss_hermite_normal(q),
          sort(unique(data$Person)), if (q == fixed_orders[1L]) adaptive_orders else 31L)
        stopifnot(all(review$Status == "computed"))
        for (mode in if (q == fixed_orders[1L]) c("fixed", "adaptive") else "fixed") {
          d <- if (mode == "fixed") review[!duplicated(review$Person), ] else review
          at <- match(d$Person, refined$Person)
          prefix <- if (mode == "fixed") "Fixed" else "Adaptive"
          persons[[paste(case, q, mode)]] <- data.frame(
            Case = case, Mode = mode, Q = if (mode == "fixed") q else d$AdaptiveNodes,
            Person = d$Person, QualifiedReference = checks[[case]]$Qualified,
            LogMarginal = d[[paste0(prefix, "LogMarginal")]],
            EAP = d[[paste0(prefix, "EAP")]], SD = d[[paste0(prefix, "PosteriorSD")]],
            ReferenceLogMarginal = refined$log_marginal[at],
            ReferenceEAP = refined$eap[at], ReferenceSD = refined$sd[at])
        }
      }
      for (name in c("references", "persons", "checks"))
        write.csv(do.call(rbind, get(name)), file.path(output_dir, paste0("points-", name, ".csv")), row.names = FALSE)
    }
  }
  stopifnot(length(checks) == 12L, all(do.call(rbind, checks)$Qualified),
            nrow(do.call(rbind, persons)) == 144L * (length(fixed_orders) + length(adaptive_orders)))
  invisible(checks)
}

gpi_refit_data <- function(design, owner, support) {
  # One reproducible dataset per design/owner, not recovery replications.
  par <- c(-.55, -.15, .25, -.4, .1, .45,
           -1.2, -.35, .45, -.9, -.2, .35, -1.05, .15, .4, -.7, -.3, .6,
           -.45, -.1, .2, .35, log(1.3^2))
  x <- support$gpk_unpack(par, "MML", owner, support)
  set.seed(20260915L + match(owner, c("Criterion", "Rater")))
  theta <- rnorm(60L, x$mean, x$sd)
  probability <- support$mfrmr_gsap_probabilities(theta, x$parameters, "complete_predictor")
  # Reference design orders Person, other facet, slope-owner facet.
  data <- expand.grid(Person = sprintf("P%03d", 1:60), Other = 1:4, Owner = 1:4)
  data$Score <- vapply(seq_len(nrow(data)), function(i)
    sample.int(5L, 1L, prob = probability[i, ]) - 1L, 0L)
  other <- setdiff(c("Rater", "Criterion"), owner)
  data[[owner]] <- paste0(substr(owner, 1, 1), data$Owner)
  data[[other]] <- paste0(substr(other, 1, 1), data$Other)
  data$Weight <- 1
  if (design == "weak_bridge_weighted") {
    r <- match(data$Rater, paste0("R", 1:4))
    c <- match(data$Criterion, paste0("C", 1:4))
    p <- match(data$Person, sprintf("P%03d", 1:60))
    data$Weight <- rep(c(.25, 1, 3, 8), length.out = nrow(data))
    data <- data[(r <= 2L) == (c <= 2L) | (p <= 6L & r == 2L & c == 3L), ]
  }
  list(data = data[c("Person", "Rater", "Criterion", "Score", "Weight")],
       truth = par, theta = theta)
}

run_gpcm_continuous_refits <- function(output_dir) {
  support <- gpi_support()
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  plan <- data.frame(Mode = c(rep("fixed", 4L), rep("adaptive", 2L)),
                     Q = c(31L, 61L, 121L, 301L, 31L, 61L))
  write.csv(plan, file.path(output_dir, "refit-plan.csv"), row.names = FALSE)
  results <- references <- coordinates <- persons <- list()
  for (design in c("complete", "weak_bridge_weighted")) for (owner in c("Criterion", "Rater")) {
    case <- paste(design, owner, sep = "-")
    generated <- gpi_refit_data(design, owner, support)
    data <- generated$data
    saveRDS(generated, file.path(output_dir, paste0(case, "-input.rds")))
    write.csv(data, file.path(output_dir, paste0(case, "-input.csv")), row.names = FALSE)
    for (i in seq_len(nrow(plan))) {
      mode <- plan$Mode[i]; q <- plan$Q[i]
      key <- paste(case, mode, q, sep = "-")
      cat(key, "\n")
      started <- proc.time()[["elapsed"]]
      captured <- tryCatch(support$mfrmr_gsapd_capture(mfrmr::fit_mfrm(
        data, "Person", c("Rater", "Criterion"), "Score", weight = "Weight",
        model = "GPCM", method = "MML", step_facet = owner, slope_facet = owner,
        rating_min = 0, rating_max = 4, quad_points = q, mml_integration = mode,
        maxit = 400L, reltol = 1e-10)), error = identity)
      row <- data.frame(Case = case, Mode = mode, Q = q, Nobs = nrow(data),
        WeightedN = sum(data$Weight), Status = "error", Convergence = NA_integer_,
        TerminalGradient = NA_real_, NLL = NA_real_, ContinuousNLL = NA_real_,
        QualifiedReference = FALSE, NLLDifference = NA_real_, EAPDifference = NA_real_,
        SDDifference = NA_real_, InferenceReady = FALSE, SlopeCIEligible = FALSE,
        Elapsed = proc.time()[["elapsed"]] - started, Conditions = "")
      if (inherits(captured, "error")) row$Conditions <- conditionMessage(captured) else {
        fit <- captured$value
        saveRDS(fit, file.path(output_dir, paste0(key, ".rds")))
        row$Status <- "returned"
        row$Conditions <- paste(c(captured$warnings, captured$messages), collapse = " | ")
        row$Convergence <- fit$opt$convergence
        row$TerminalGradient <- fit$summary$TerminalGradientSupNorm
        row$NLL <- -fit$summary$LogLik
        row$InferenceReady <- mfrmr:::mfrm_inference_ready(fit)
        row$SlopeCIEligible <- any(fit$slopes$CIEligible)
        coordinates[[key]] <- data.frame(Case = case, Mode = mode, Q = q,
          Coordinate = seq_along(fit$opt$par), Value = fit$opt$par)
        ref <- tryCatch({
          a <- gpi_reference(fit$opt$par, owner, data, support)
          b <- gpi_reference(fit$opt$par, owner, data, support, 64)
          list(a = a, b = b, qualified = gpi_qualified(a, b))
        }, error = identity)
        if (inherits(ref, "error")) row$Conditions <- paste(row$Conditions, "Reference:", conditionMessage(ref)) else {
          references[[key]] <- rbind(cbind(Case = case, Mode = mode, Q = q, Limit = 32, ref$a),
                                      cbind(Case = case, Mode = mode, Q = q, Limit = 64, ref$b))
          row$QualifiedReference <- ref$qualified
          row$ContinuousNLL <- -sum(ref$b$log_marginal)
          row$NLLDifference <- row$NLL - row$ContinuousNLL
          at <- match(fit$facets$person$Person, ref$b$Person)
          stopifnot(!anyNA(at))
          row$EAPDifference <- max(abs(fit$facets$person$Estimate - ref$b$eap[at]))
          row$SDDifference <- max(abs(fit$facets$person$SD - ref$b$sd[at]))
          persons[[key]] <- data.frame(Case = case, Mode = mode, Q = q,
            Person = fit$facets$person$Person, EAP = fit$facets$person$Estimate,
            SD = fit$facets$person$SD, ReferenceEAP = ref$b$eap[at], ReferenceSD = ref$b$sd[at])
        }
      }
      results[[key]] <- row
      for (name in c("results", "references", "coordinates", "persons"))
        if (length(get(name))) write.csv(do.call(rbind, get(name)),
          file.path(output_dir, paste0("refit-", name, ".csv")), row.names = FALSE)
    }
  }
  result <- do.call(rbind, results)
  stopifnot(nrow(result) == 24L, !any(result$SlopeCIEligible))
  capture.output(sessionInfo(), file = file.path(output_dir, "session-info.txt"))
  invisible(result)
}

summarize_gpcm_continuous_audit <- function(output_dir) {
  support <- gpi_support()
  points <- read.csv(file.path(output_dir, "points", "points-persons.csv"))
  higher <- read.csv(file.path(output_dir, "points-higher", "points-persons.csv"))
  points <- rbind(points, higher[higher$Mode == "adaptive", ])
  groups <- split(points, interaction(points$Case, points$Mode, points$Q, drop = TRUE))
  point_summary <- do.call(rbind, lapply(groups, function(d) data.frame(
    Case = d$Case[1], Mode = d$Mode[1], Q = d$Q[1],
    QualifiedReference = all(d$QualifiedReference),
    NLLDifference = -sum(d$LogMarginal - d$ReferenceLogMarginal),
    EAPDifference = max(abs(d$EAP - d$ReferenceEAP)),
    SDDifference = max(abs(d$SD - d$ReferenceSD)))))
  write.csv(point_summary, file.path(output_dir, "points-summary.csv"), row.names = FALSE)
  fits <- read.csv(file.path(output_dir, "refits", "refit-results.csv"))
  coordinates <- read.csv(file.path(output_dir, "refits", "refit-coordinates.csv"))
  persons <- read.csv(file.path(output_dir, "refits", "refit-persons.csv"))
  pairs <- list()
  for (case in unique(fits$Case)) {
    owner <- if (endsWith(case, "Criterion")) "Criterion" else "Rater"
    plan <- data.frame(FromMode = c(rep("fixed", 3), "adaptive", "fixed", "fixed"),
      FromQ = c(31, 61, 121, 31, 301, 31),
      ToMode = c(rep("fixed", 3), rep("adaptive", 3)), ToQ = c(61, 121, 301, 61, 61, 61))
    pick <- function(d, mode, q) d[d$Case == case & d$Mode == mode & d$Q == q, ]
    for (i in seq_len(nrow(plan))) {
      p <- plan[i, ]
      a <- pick(fits, p$FromMode, p$FromQ); b <- pick(fits, p$ToMode, p$ToQ)
      if (a$Status != "returned" || b$Status != "returned") next
      ca <- pick(coordinates, p$FromMode, p$FromQ)
      cb <- pick(coordinates, p$ToMode, p$ToQ)
      stopifnot(identical(ca$Coordinate, cb$Coordinate), nrow(ca) == 23L)
      x <- support$gpk_unpack(ca$Value, "MML", owner, support)
      y <- support$gpk_unpack(cb$Value, "MML", owner, support)
      pa <- pick(persons, p$FromMode, p$FromQ); pb <- pick(persons, p$ToMode, p$ToQ)
      at <- match(pa$Person, pb$Person)
      pairs[[length(pairs) + 1L]] <- data.frame(Case = case, p,
        BothStationary = a$Convergence == 0 & b$Convergence == 0 &
          a$TerminalGradient <= 1e-4 & b$TerminalGradient <= 1e-4,
        QualifiedReferences = a$QualifiedReference & b$QualifiedReference,
        ContinuousNLLChange = b$ContinuousNLL - a$ContinuousNLL,
        MaxFreeCoordinateChange = max(abs(ca$Value - cb$Value)),
        MaxLogSlopeChange = max(abs(log(x$parameters$slopes) - log(y$parameters$slopes))),
        MaxSlopeChange = max(abs(x$parameters$slopes - y$parameters$slopes)),
        MaxBoundaryChange = max(abs(x$parameters$boundaries - y$parameters$boundaries)),
        PopulationMeanChange = y$mean - x$mean, PopulationSDChange = y$sd - x$sd,
        NativeEAPChange = if (nrow(pa) && nrow(pb)) max(abs(pa$EAP - pb$EAP[at])) else NA_real_,
        ContinuousEAPChange = if (nrow(pa) && nrow(pb)) max(abs(pa$ReferenceEAP - pb$ReferenceEAP[at])) else NA_real_)
    }
  }
  write.csv(do.call(rbind, pairs), file.path(output_dir, "refit-pairs.csv"), row.names = FALSE)
  # These are numerical reporting tolerances from the earlier adaptive audit,
  # not empirical recovery/coverage criteria or guaranteed quadrature orders.
  qualifies <- function(d) d$QualifiedReference & abs(d$NLLDifference) < 1e-7 &
    d$EAPDifference < 1e-7 & d$SDDifference < 1e-7
  point_summary$NumericalToleranceMet <- qualifies(point_summary)
  fits$NumericalToleranceMet <- qualifies(fits)
  write.csv(point_summary, file.path(output_dir, "points-summary.csv"), row.names = FALSE)
  write.csv(fits, file.path(output_dir, "refit-summary.csv"), row.names = FALSE)
  stopifnot(nrow(point_summary) == 120L, nrow(fits) == 24L,
            all(point_summary$QualifiedReference), !any(fits$SlopeCIEligible))
  invisible(list(points = point_summary, fits = fits, pairs = do.call(rbind, pairs)))
}

verify_gpcm_continuous_gradients <- function(output_dir) {
  support <- gpi_support()
  sys.source("inst/validation/adaptive-optimization-probe-0.2.4.R", support)
  fits <- read.csv(file.path(output_dir, "refits", "refit-results.csv"))
  selected <- fits[fits$Mode == "adaptive" & fits$Q == 61L, ]
  gradients <- list()
  for (case in selected$Case) {
    cat(case, "\n")
    fit <- readRDS(file.path(output_dir, "refits", paste0(case, "-adaptive-61.rds")))
    data <- readRDS(file.path(output_dir, "refits", paste0(case, "-input.rds")))$data
    owner <- fit$config$slope_facet
    fn <- function(par) {
      ref <- gpi_reference(par, owner, data, support, 64)
      stopifnot(max(ref$relative_error) < 1e-9,
                max(ref$log_relative_tail_bound) < log(1e-12))
      -sum(ref$log_marginal)
    }
    sizes <- mfrmr:::build_param_sizes(fit$config)
    idx <- mfrmr:::build_indices(fit$prep, owner, owner)
    evaluate <- mfrmr:::mfrmr_make_adaptive_mml_evaluator(idx, fit$config, sizes, 61L)
    analytic <- evaluate(fit$opt$par)$gradient
    numerical <- support$aqopt_gradient(fn, fit$opt$par, step = 5e-5)
    gradients[[case]] <- data.frame(Case = case, Coordinate = seq_along(analytic),
      Analytic = analytic, ContinuousNumeric = numerical, Difference = analytic - numerical)
    write.csv(do.call(rbind, gradients), file.path(output_dir, "continuous-gradients.csv"), row.names = FALSE)
  }
  result <- do.call(rbind, gradients)
  stopifnot(nrow(result) == 92L, all(abs(result$Difference) < 1e-5))
  invisible(result)
}
