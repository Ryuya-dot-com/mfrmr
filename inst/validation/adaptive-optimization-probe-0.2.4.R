# Experimental refits, deliberately outside the public package API.
# From the development root, load mfrmr, then source this file and run
# run_adaptive_optimization_probe(output_dir), then
# review_adaptive_optimization_probe(output_dir). No mfrm_fit is fabricated.

aqopt_data <- function(model, mass, sparse = FALSE, interaction = FALSE) {
  data <- expand.grid(Person = sprintf("P%02d", 1:8), Rater = c("R1", "R2"),
    Criterion = c("C1", "C2"), Score = 0:3, stringsAsFactors = FALSE)
  theta <- stats::qnorm((1:8 - 0.5) / 8)
  steps <- if (model == "RSM") rbind(c(-1, 0.2, 0.8), c(-1, 0.2, 0.8)) else
    rbind(c(-1.3, 0.1, 1.2), c(-0.7, 0.2, 0.5))
  slopes <- if (model == "GPCM") c(0.7, 1 / 0.7) else c(1, 1)
  person <- match(data$Person, sprintf("P%02d", 1:8))
  rater <- match(data$Rater, c("R1", "R2"))
  criterion <- match(data$Criterion, c("C1", "C2"))
  data$Weight <- vapply(seq_len(nrow(data)), function(i) {
    eta <- theta[person[i]] - c(-0.4, 0.4)[rater[i]] - c(-0.7, 0.7)[criterion[i]]
    if (interaction) eta <- eta + if (rater[i] == criterion[i]) 0.25 else -0.25
    logits <- slopes[criterion[i]] * ((0:3) * eta - c(0, cumsum(steps[criterion[i], ])))
    probability <- exp(logits - max(logits)) / sum(exp(logits - max(logits)))
    mass * probability[data$Score[i] + 1L]
  }, 0)
  if (sparse) {
    # A connected incomplete design, not disconnected components made valid by anchors.
    keep <- !((person %% 2L == 0L & rater == 2L & criterion == 1L) |
              (person %% 2L == 1L & rater == 1L & criterion == 2L))
    data <- data[keep, , drop = FALSE]
  }
  data
}

aqopt_context <- function(fit, continuous_reference) {
  stopifnot(inherits(fit, "mfrm_fit"), fit$config$method == "MML")
  config <- fit$config
  sizes <- mfrmr:::build_param_sizes(config)
  idx <- mfrmr:::build_indices(fit$prep, config$step_facet, config$slope_facet,
                               config$interaction_specs)
  labels <- fit$prep$levels$Person
  expand <- function(par) mfrmr:::expand_params(par, sizes, config)
  review <- function(par, order) {
    # The existing internal reviewer accepts a single adaptive order. Q1 is
    # only a cheap unused fixed comparator; it does not enter this objective.
    out <- mfrmr:::mfrmr_adaptive_quadrature_review(
      idx, config, expand(par), list(nodes = 0, weights = 1), labels, order
    )
    if (nrow(out) != length(labels) || any(out$Status != "computed")) {
      stop("Adaptive objective unavailable: ", paste(unique(out$Detail), collapse = "; "))
    }
    out
  }
  reference <- function(par, limit = 32) {
    params <- expand(par)
    base <- mfrmr:::compute_base_eta(idx, params, config)
    basis <- mfrmr:::resolve_person_quadrature_basis(
      list(nodes = c(0, 1), weights = c(1, 1)),
      mfrmr:::materialize_population_spec(config, params), person_count = length(labels)
    )
    mu <- if (isTRUE(basis$transformed)) basis$mu else rep(0, length(labels))
    sigma <- if (isTRUE(basis$transformed)) basis$sigma else 1
    result <- lapply(seq_along(labels), function(person) {
      rows <- which(idx$person == person)
      steps <- if (config$model == "RSM") {
        matrix(params$steps, length(rows), length(params$steps), byrow = TRUE)
      } else params$steps_mat[idx$step_idx[rows], , drop = FALSE]
      slopes <- if (config$model == "GPCM") params$slopes[idx$slope_idx[rows]] else rep(1, length(rows))
      weights <- if (is.null(idx$weight)) rep(1, length(rows)) else idx$weight[rows]
      continuous_reference(idx$score_k[rows], base[rows], steps, slopes, weights,
                               mu[person], sigma, limit = limit)
    })
    result <- do.call(rbind, result)
    stopifnot(all(result[, "relative_error"] < 1e-9),
              all(result[, "log_relative_tail_bound"] < log(1e-12)))
    result
  }
  list(config = config, sizes = sizes, idx = idx, labels = labels, expand = expand,
    review = review, reference = reference,
    initial = mfrmr:::build_initial_param_vector(config, sizes),
    adaptive = function(order) function(par) -sum(review(par, order)$AdaptiveLogMarginal),
    continuous = function(par) -sum(reference(par)[, "log_marginal"]))
}

aqopt_gradient <- function(fn, par, step = 1e-4) {
  vapply(seq_along(par), function(i) {
    plus <- minus <- par
    plus[i] <- plus[i] + step
    minus[i] <- minus[i] - step
    (fn(plus) - fn(minus)) / (2 * step)
  }, 0)
}

run_adaptive_optimization_probe <- function(output_dir, cases = NULL) {
  source("inst/validation/adaptive-quadrature-review-0.2.4.R", local = environment())
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  specifications <- data.frame(
    case = c("rsm_short", "pcm_short", "gpcm_short", "rsm_long", "pcm_long", "gpcm_long",
             "pcm_sparse_anchor", "rsm_interaction", "gpcm_free_population", "rsm_regression"),
    model = c("RSM", "PCM", "GPCM", "RSM", "PCM", "GPCM", "PCM", "RSM", "GPCM", "RSM"),
    mass = c(2, 2, 2, rep(80, 7)), stringsAsFactors = FALSE
  )
  if (!is.null(cases)) {
    stopifnot(length(cases) > 0L, !anyNA(cases), !anyDuplicated(cases),
              all(cases %in% specifications$case))
    specifications <- specifications[specifications$case %in% cases, , drop = FALSE]
  }
  runs <- coordinates <- checks <- conditions <- inputs <- list()
  captured <- function(expr, case, run) {
    withCallingHandlers(tryCatch(expr, error = identity), warning = function(w) {
      conditions[[length(conditions) + 1L]] <<- data.frame(case = case, run = run,
        type = "warning", detail = conditionMessage(w))
      invokeRestart("muffleWarning")
    })
  }
  write_results <- function() {
    for (name in c("runs", "coordinates", "checks", "conditions", "inputs")) {
      value <- get(name)
      if (length(value)) write.csv(do.call(rbind, value),
        file.path(output_dir, paste0(name, ".csv")), row.names = FALSE)
    }
  }
  for (i in seq_len(nrow(specifications))) {
    spec <- specifications[i, ]
    message("Case: ", spec$case)
    sparse <- spec$case == "pcm_sparse_anchor"
    interaction <- spec$case == "rsm_interaction"
    data <- aqopt_data(spec$model, spec$mass, sparse, interaction)
    inputs[[length(inputs) + 1L]] <- data.frame(case = spec$case, data)
    arguments <- list(data = data, person = "Person", facets = c("Rater", "Criterion"),
      score = "Score", weight = "Weight", model = spec$model, method = "MML",
      step_facet = if (spec$model != "RSM") "Criterion" else NULL,
      slope_facet = if (spec$model == "GPCM") "Criterion" else NULL,
      gpcm_mml_identification = if (spec$case == "gpcm_free_population") {
        "free_population"
      } else "fixed_standard_normal",
      quad_points = 31L, reltol = 1e-12, maxit = 400L, anchor_policy = "silent")
    if (sparse) arguments$anchors <- data.frame(Facet = "Rater", Level = "R1", Anchor = -0.4)
    if (interaction) {
      arguments$facet_interactions <- "Rater:Criterion"
      arguments$min_obs_per_interaction <- 0
    }
    if (spec$case == "rsm_regression") {
      # A pure formula must not capture this mutable audit execution frame.
      arguments$population_formula <- stats::as.formula("~ X", env = baseenv())
      arguments$person_data <- data.frame(Person = sprintf("P%02d", 1:8), X = rep(c(-1, 1), 4))
    }
    fit <- captured(do.call(mfrmr::fit_mfrm, arguments), spec$case, "source_q31")
    if (inherits(fit, "error")) stop("Source fixture failed: ", spec$case, ": ", conditionMessage(fit))
    context <- aqopt_context(fit, aq_continuous_reference)
    original <- serialize(fit, NULL)
    candidates <- list(fixed31 = fit$opt)
    for (q in c(61L, 181L, 301L)) {
      candidates[[paste0("fixed", q)]] <- captured(mfrmr:::run_mfrm_direct_optimization(
        context$initial, "MML", context$idx, context$config, context$sizes,
        q, maxit = 400L, reltol = 1e-12), spec$case, paste0("fixed", q))
    }
    plans <- data.frame(order = c(15L, 31L, 61L, 31L),
                        start = c("fixed31", "fixed31", "fixed31", "initial"))
    for (j in seq_len(nrow(plans))) {
      plan <- plans[j, ]
      label <- paste0("adaptive", plan$order, "_", plan$start)
      start <- if (plan$start == "initial") context$initial else fit$opt$par
      fn <- context$adaptive(plan$order)
      calls <- 0L
      counted <- function(par) { calls <<- calls + 1L; fn(par) }
      # ponytail: finite differences scale linearly with parameter count;
      # derive moving-node gradients before considering a public optimizer.
      elapsed <- system.time(candidate <- captured(stats::optim(
        start, counted, method = "BFGS", gr = NULL,
        control = list(ndeps = rep(1e-4, length(start)), reltol = 1e-12, maxit = 200L)
      ), spec$case, label))[["elapsed"]]
      if (!inherits(candidate, "error")) {
        candidate$objective_calls <- calls
        candidate$elapsed <- elapsed
      }
      candidates[[label]] <- candidate
    }
    baseline <- candidates$adaptive61_fixed31
    if (inherits(baseline, "error")) stop("Adaptive reference failed: ", conditionMessage(baseline))
    baseline_review <- context$review(baseline$par, 61L)
    baseline_params <- context$expand(baseline$par)
    for (label in names(candidates)) {
      candidate <- candidates[[label]]
      if (inherits(candidate, "error")) {
        conditions[[length(conditions) + 1L]] <- data.frame(case = spec$case, run = label,
          type = "error", detail = conditionMessage(candidate))
        next
      }
      params <- context$expand(candidate$par)
      at61 <- context$review(candidate$par, 61L)
      measurement <- function(p) unlist(p[c("facets", "steps", "steps_mat", "interactions")])
      order <- as.integer(sub(".*?([0-9]+).*", "\\1", label))
      adaptive <- startsWith(label, "adaptive")
      objective <- if (adaptive) context$adaptive(order) else function(par) {
        mfrmr:::mfrm_loglik_mml(par, context$idx, context$config, context$sizes,
                                mfrmr:::gauss_hermite_normal(order))
      }
      g1 <- aqopt_gradient(objective, candidate$par)
      g2 <- aqopt_gradient(objective, candidate$par, 5e-5)
      runs[[length(runs) + 1L]] <- data.frame(case = spec$case, model = spec$model,
        run = label, order = order, adaptive = adaptive, parameters = length(candidate$par),
        convergence = candidate$convergence, own_nll = candidate$value,
        adaptive61_nll = -sum(at61$AdaptiveLogMarginal),
        own_gradient_max = max(abs(g2)), gradient_step_change = max(abs(g1 - g2)),
        free_parameter_change = max(abs(candidate$par - baseline$par)),
        measurement_change = max(abs(measurement(params) - measurement(baseline_params))),
        slope_change = if (spec$model == "GPCM") max(abs(params$slopes - baseline_params$slopes)) else NA_real_,
        population_sd = if (is.null(params$population)) 1 else sqrt(params$population$sigma2),
        eap_change = max(abs(at61$AdaptiveEAP - baseline_review$AdaptiveEAP)),
        sd_change = max(abs(at61$AdaptivePosteriorSD - baseline_review$AdaptivePosteriorSD)),
        objective_calls = if (is.null(candidate$objective_calls)) NA_integer_ else candidate$objective_calls,
        elapsed = if (is.null(candidate$elapsed)) NA_real_ else candidate$elapsed)
      coordinates[[length(coordinates) + 1L]] <- data.frame(case = spec$case, run = label,
        coordinate = seq_along(candidate$par), value = candidate$par)
    }
    # Independent integration, and derivatives of that integration, at the
    # adaptive solution. Do not substitute the fixed-grid analytical gradient.
    reference <- context$reference(baseline$par)
    refined <- context$reference(baseline$par, limit = 64)
    continuous_gradient <- aqopt_gradient(context$continuous, baseline$par)
    adaptive_gradient <- aqopt_gradient(context$adaptive(61L), baseline$par)
    hessian <- stats::optimHess(baseline$par, context$adaptive(61L),
                               control = list(ndeps = rep(1e-4, length(baseline$par))))
    checks[[length(checks) + 1L]] <- data.frame(case = spec$case,
      reference_nll = -sum(reference[, "log_marginal"]),
      nll_error = abs(-sum(reference[, "log_marginal"]) - baseline$value),
      eap_error = max(abs(reference[, "eap"] - baseline_review$AdaptiveEAP)),
      sd_error = max(abs(reference[, "sd"] - baseline_review$AdaptivePosteriorSD)),
      reference_range_change = max(abs(reference[, 1:3] - refined[, 1:3])),
      reference_relative_error = max(reference[, "relative_error"]),
      reference_log_tail_bound = max(reference[, "log_relative_tail_bound"]),
      continuous_gradient_max = max(abs(continuous_gradient)),
      gradient_reference_error = max(abs(continuous_gradient - adaptive_gradient)),
      hessian_min_eigenvalue = min(eigen(hessian, symmetric = TRUE, only.values = TRUE)$values),
      source_unchanged = identical(serialize(fit, NULL), original),
      anchor_change = if (sparse) abs(baseline_params$facets$Rater[1L] + 0.4) else NA_real_)
    saveRDS(list(fit = fit, candidates = candidates), file.path(output_dir, paste0(spec$case, ".rds")))
    write_results()
  }
  # A runnable numerical regression check; thresholds qualify this bounded
  # prototype, not applied-score accuracy, coverage, or release readiness.
  check <- do.call(rbind, checks)
  run <- do.call(rbind, runs)
  stopifnot(nrow(run) == 8L * nrow(specifications), all(run$convergence == 0L),
    all(check$source_unchanged), all(check$nll_error < 1e-7), all(check$eap_error < 1e-7),
    all(check$sd_error < 1e-7), all(check$reference_range_change < 1e-8),
    all(check$gradient_reference_error < 1e-5), all(check$hessian_min_eigenvalue > 0),
    all(check$anchor_change[is.finite(check$anchor_change)] < 1e-12))
  invisible(list(runs = run, checks = check))
}

review_adaptive_optimization_probe <- function(output_dir) {
  source("inst/validation/adaptive-quadrature-review-0.2.4.R", local = environment())
  runs <- utils::read.csv(file.path(output_dir, "runs.csv"), stringsAsFactors = FALSE)
  terminal <- common <- list()
  for (case in unique(runs$case)) {
    saved <- readRDS(file.path(output_dir, paste0(case, ".rds")))
    context <- aqopt_context(saved$fit, aq_continuous_reference)
    reference_par <- saved$candidates$adaptive61_fixed31$par
    for (label in names(saved$candidates)[startsWith(names(saved$candidates), "adaptive")]) {
      before <- saved$candidates[[label]]
      order <- runs$order[runs$case == case & runs$run == label]
      fn <- context$adaptive(order)
      g_before <- max(abs(aqopt_gradient(fn, before$par, 5e-5)))
      # A bounded audit follow-up, not a new public stopping/acceptance rule.
      after <- if (g_before > 1e-4) stats::optim(
        before$par, fn, method = "BFGS", gr = NULL,
        control = list(ndeps = rep(1e-4, length(before$par)), reltol = 1e-14, maxit = 200L)
      ) else before
      terminal[[length(terminal) + 1L]] <- data.frame(case = case, run = label,
        polished = g_before > 1e-4, before_gradient_max = g_before,
        after_gradient_max = max(abs(aqopt_gradient(fn, after$par, 5e-5))),
        after_gradient_step_change = max(abs(aqopt_gradient(fn, after$par, 5e-5) -
                                               aqopt_gradient(fn, after$par, 2.5e-5))),
        nll_improvement = before$value - after$value, convergence = after$convergence,
        parameter_change = max(abs(after$par - before$par)),
        parameter_difference_from_q61 = max(abs(after$par - reference_par)))
    }
    for (label in c("fixed31", "fixed301", "adaptive61_fixed31")) {
      candidate <- saved$candidates[[label]]
      independent <- context$reference(candidate$par)
      value <- context$adaptive(61L)(candidate$par)
      common[[length(common) + 1L]] <- data.frame(case = case, run = label,
        independent_nll = -sum(independent[, "log_marginal"]), adaptive61_nll = value,
        integration_error = abs(value + sum(independent[, "log_marginal"])),
        adaptive61_gradient_max = max(abs(aqopt_gradient(context$adaptive(61L), candidate$par, 5e-5))))
    }
  }
  terminal <- do.call(rbind, terminal)
  common <- do.call(rbind, common)
  write.csv(terminal, file.path(output_dir, "terminal.csv"), row.names = FALSE)
  write.csv(common, file.path(output_dir, "common.csv"), row.names = FALSE)
  stopifnot(all(terminal$convergence == 0L), all(terminal$after_gradient_max < 1e-4),
    all(terminal$nll_improvement > -1e-9), all(common$integration_error < 1e-7))
  invisible(list(terminal = terminal, common = common))
}
