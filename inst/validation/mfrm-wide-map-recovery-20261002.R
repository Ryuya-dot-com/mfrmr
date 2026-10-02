# Initial-call recovery for the two-facet A/B comparison. Repository-only.
# Source mml-stages and output-summary first. No fitting, source review, stage
# selection or intervals. Finite numerical returns are not certified optima.
wide_recovery_input <- function(condition, replicate, data, truth, provenance) {
  facets <- c("Rater", "Criterion")
  levels <- lapply(truth[facets], names)
  stopifnot(length(condition) == 1L, nzchar(condition), length(replicate) == 1L,
    replicate >= 1L, replicate == floor(replicate), is.data.frame(data),
    all(c("Person", facets, "Score") %in% names(data)), nrow(data) > 0L,
    !anyNA(data[c("Person", facets, "Score")]), length(provenance) > 0L,
    all(vapply(levels, function(x) length(x) >= 2L && !anyNA(x) && !anyDuplicated(x), TRUE)),
    is.matrix(truth$steps), ncol(truth$steps) >= 1L,
    identical(rownames(truth$steps), levels$Criterion),
    identical(names(truth$log_slopes), levels$Criterion),
    all(is.finite(unlist(truth))),
    max(abs(c(sum(truth$Rater), sum(truth$Criterion), rowSums(truth$steps), sum(truth$log_slopes)))) < 1e-10)
  categories <- 0:ncol(truth$steps)
  stopifnot(all(data$Score %in% categories),
    all(vapply(facets, function(f) all(as.character(data[[f]]) %in% levels[[f]]), TRUE)))
  grid <- expand.grid(Theta = c(-2, -1, 0, 1, 2), Rater = levels$Rater,
    Criterion = levels$Criterion, stringsAsFactors = FALSE)
  x <- list(ConditionId = condition, Replicate = as.integer(replicate), data = data,
    truth = truth, levels = levels, categories = categories, grid = grid,
    provenance = provenance, contract = "two_facet_native_initial_recovery_v1")
  x$InputId <- wide_mml_hash(x); x
}

wide_recovery_ab_input <- function(root, condition, replicate) {
  index_path <- file.path(root, "inputs.csv")
  verified <- readRDS(file.path(root, "verified-inputs.rds"))
  stopifnot(identical(unname(tools::md5sum(index_path)), unname(verified$inputs_md5)))
  index <- read.csv(index_path, stringsAsFactors = FALSE)
  row <- index[index$ConditionId == condition & index$Replicate == replicate, ]
  stopifnot(nrow(row) == 1L)
  path <- file.path(root, row$Bundle)
  stopifnot(unname(tools::md5sum(path)) == row$BundleMD5)
  bundle <- readRDS(path); truth <- bundle$truth
  for (facet in c("Rater", "Criterion")) names(truth[[facet]]) <- as.character(seq_along(truth[[facet]]))
  rownames(truth$steps) <- names(truth$log_slopes) <- names(truth$Criterion)
  stopifnot(bundle$unit$Replicate == replicate, bundle$unit$Truth == row$Truth,
    bundle$unit$N == row$N, bundle$unit$SD == row$SD)
  wide_recovery_input(condition, replicate, bundle$views[[row$View]], truth,
    list(index = tools::md5sum(index_path), bundle = tools::md5sum(path), view = row$View))
}

wide_recovery_data <- function(data) {
  x <- data[c("Person", "Rater", "Criterion", "Score")]
  for (f in c("Person", "Rater", "Criterion")) x[[f]] <- as.character(x[[f]])
  x$Score <- as.numeric(x$Score); rownames(x) <- NULL; x
}

wide_recovery_contrasts <- function(input) lapply(input$levels, function(levels) {
  contrast <- matrix(0, 1L, length(levels), dimnames = list(paste0(levels[1], "-", levels[2]), levels))
  contrast[1, 1:2] <- c(1, -1); contrast
})

wide_recovery_probabilities <- function(input, parameters) {
  g <- input$grid; k <- input$categories
  eta <- g$Theta - parameters$Rater[g$Rater] - parameters$Criterion[g$Criterion]
  steps <- t(apply(parameters$steps, 1L, function(x) c(0, cumsum(x))))
  logits <- exp(parameters$log_slopes[g$Criterion]) *
    (outer(eta, k) - steps[g$Criterion, , drop = FALSE])
  out <- matrix(NA_real_, nrow(g), length(k))
  good <- apply(logits, 1L, function(x) all(is.finite(x)))
  if (any(good)) {
    mass <- exp(logits[good, , drop = FALSE] - apply(logits[good, , drop = FALSE], 1L, max))
    out[good, ] <- mass / rowSums(mass)
  }
  out
}

wide_recovery_plan <- function(input, spec) {
  a <- spec$args
  stopifnot(identical(input$contract, "two_facet_native_initial_recovery_v1"),
    identical(input$InputId, wide_mml_hash(input[setdiff(names(input), "InputId")])),
    identical(spec$ConditionId, input$ConditionId), spec$Replicate == input$Replicate,
    identical(a$data, input$data), identical(a$facets, c("Rater", "Criterion")),
    a$person == "Person", a$score == "Score", a$model %in% c("PCM", "GPCM", "RSM"),
    a$method %in% c("MML", "JML"), a$rating_min == 0,
    a$rating_max == max(input$categories), a$category_policy == "preserve")
  if (a$model != "RSM") stopifnot(a$step_facet == "Criterion")
  if (a$model == "GPCM") stopifnot(identical(a$slope_facet, "Criterion"))
  encode <- function(...) paste(..., sep = ":")
  rows <- lapply(names(input$levels), function(facet) {
    levels <- input$levels[[facet]]
    data.frame(Target = c(encode("contrast", facet, paste(levels[1:2], collapse = "-")),
      encode("location", facet, levels)), Kind = c("contrast", rep("location", length(levels))),
      Owner = facet, Coordinate = "native_location", ScaleReference = "centered_native_location",
      ReferenceValue = c(input$truth[[facet]][1] - input$truth[[facet]][2], input$truth[[facet]]),
      Eligibility = "eligible", stringsAsFactors = FALSE)
  })
  rows$slopes <- data.frame(Target = encode("log_slope", "Criterion", input$levels$Criterion),
    Kind = "log_slope", Owner = "Criterion", Coordinate = "log_slope", ScaleReference = "geometric_mean_one",
    ReferenceValue = input$truth$log_slopes, Eligibility = if (a$model == "GPCM") "eligible" else "fixed")
  g <- input$grid
  rows$probability <- data.frame(Target = unlist(lapply(input$categories, function(k)
      encode("probability", g$Theta, g$Rater, g$Criterion, k))),
    Kind = "probability", Owner = "response", Coordinate = "probability",
    ScaleReference = "canonical_theta_native_locations", ReferenceValue = as.vector(wide_recovery_probabilities(input, input$truth)),
    Eligibility = "eligible")
  plan <- do.call(rbind, rows); rownames(plan) <- NULL
  plan$ConditionId <- input$ConditionId; plan$Replicate <- input$Replicate; plan$InputId <- input$InputId
  plan$Arm <- spec$Arm; plan$Output <- "point"; plan$Reference <- "generating_parameter"
  plan$Primary <- plan$Kind != "location"
  plan <- rbind(transform(plan, Analysis = "initial_finite_return"),
    transform(plan, Analysis = "initial_numerical_pass"))
  plan
}

wide_recovery_fit_identity <- function(fit, input, spec) {
  a <- spec$args; cfg <- fit$config
  stopifnot(inherits(fit, "mfrm_fit"), !inherits(fit, "mfrm_imported_fit"),
    identical(cfg$model, a$model), identical(cfg$method, a$method),
    identical(cfg$facet_names, a$facets), identical(cfg$facet_levels, input$levels),
    cfg$n_cat == length(input$categories), fit$prep$rating_min == 0,
    fit$prep$rating_max == max(input$categories), all(fit$prep$data$Weight == 1),
    identical(wide_recovery_data(fit$prep$data), wide_recovery_data(input$data)),
    !length(fit$interactions$specs), nrow(fit$interactions$effects) == 0L)
  adjusted <- mfrmr:::mfrm_has_jml_adjustment(fit)
  stopifnot(identical(adjusted, !is.null(a$jml_correction_order)))
  if (adjusted) {
    stopifnot(identical(fit$jml_adjustment$estimator$order, as.integer(a$jml_correction_order)),
      identical(fit$jml_adjustment$estimator$sampling, a$jml_correction_sampling))
  } else {
    stopifnot(all(cfg$facet_signs[a$facets] == -1), !length(cfg$interaction_specs))
    for (facet in a$facets) stopifnot(isTRUE(all.equal(cfg$facet_specs[[facet]],
      mfrmr:::build_facet_constraint(input$levels[[facet]]))))
    owners <- if (a$model == "RSM") "shared" else input$levels$Criterion
    expected <- setNames(lapply(owners, function(x) mfrmr:::build_step_constraint(
      length(input$categories) - 1L, scope = x)), owners)
    stopifnot(isTRUE(all.equal(cfg$step_specs, expected)))
  }
  if (a$model != "RSM") stopifnot(cfg$step_facet == "Criterion")
  if (a$model == "GPCM") {
    stopifnot(identical(cfg$slope_facet, "Criterion"))
    if (!adjusted) stopifnot(cfg$gpcm_spec$scale_reference == "geometric_mean_one")
  }
  if (a$method == "MML") {
    active <- !is.null(a$population_formula)
    stopifnot(identical(isTRUE(fit$population$active), active))
    if (active) stopifnot(identical(as.character(a$population_formula), c("~", "1")),
      identical(fit$population$design_columns, "(Intercept)"))
  }
  invisible(TRUE)
}

# Read the first shared-fit phase, never the later source-selected point stage.
wide_recovery_initial_phase <- function(input, out) {
  unpack <- function(path) {
    z <- readRDS(path); stopifnot(identical(z$checksum, wide_mml_hash(z$payload))); z
  }
  manifest <- unpack(file.path(out, "manifest.rds"))$payload
  q <- if (manifest$spec$args$method == "MML") 31L else 0L
  z <- unpack(file.path(out, paste0("q", q, "-fit.rds")))
  stopifnot(identical(z$binding, list(job = wide_mml_hash(manifest), order = q,
    phase = "fit", dependency = NULL)))
  wide_recovery_collect(input, manifest$spec, z$payload, paste0("initial:q", q, ":", z$checksum))
}

wide_recovery_parameters <- function(fit, input) {
  lookup <- function(keys, values, expected) {
    if (anyDuplicated(keys)) stop("Duplicate saved parameter labels.")
    unname(values[match(expected, keys)])
  }
  parameters <- lapply(names(input$levels), function(facet) {
    tab <- fit$facets$others; tab <- tab[tab$Facet == facet, ]
    setNames(lookup(tab$Level, tab$Estimate, input$levels[[facet]]), input$levels[[facet]])
  }); names(parameters) <- names(input$levels)
  tab <- fit$steps; owners <- input$levels$Criterion; steps <- paste0("Step_", seq_len(length(input$categories)-1L))
  parameters$steps <- t(vapply(owners, function(owner) {
    x <- if (fit$config$model == "RSM") tab else tab[tab$StepFacet == owner, ]
    lookup(x$Step, x$Estimate, steps)
  }, numeric(length(steps))))
  rownames(parameters$steps) <- owners
  parameters$log_slopes <- setNames(if (fit$config$model == "GPCM")
    lookup(fit$slopes$SlopeFacet, log(fit$slopes$Estimate), owners) else rep(0, length(owners)), owners)
  parameters
}

wide_recovery_collect <- function(input, spec, fitting, stage) {
  plan <- wide_recovery_plan(input, spec)
  stopifnot(length(stage) == 1L, nzchar(stage), is.character(fitting$error), length(fitting$error) == 1L)
  pass <- FALSE; diagnostics <- list(); values <- rep(NA_real_, nrow(plan)/2L)
  if (!nzchar(fitting$error)) {
    fit <- fitting$value
    wide_recovery_fit_identity(fit, input, spec)
    parameters <- wide_recovery_parameters(fit, input)
    values <- c(unlist(lapply(names(input$levels), function(facet)
      c(parameters[[facet]][1] - parameters[[facet]][2], parameters[[facet]])), use.names = FALSE),
      unname(parameters$log_slopes), as.vector(wide_recovery_probabilities(input, parameters)))
    adjusted <- mfrmr:::mfrm_has_jml_adjustment(fit)
    pass <- if (adjusted) isTRUE(fit$jml_adjustment$point$available) &&
      identical(fit$jml_adjustment$point$status, "consistent_roots") else
      isTRUE(fit$summary$Converged[1]) && identical(fit$summary$ConvergenceSeverity[1], "pass")
    diagnostics <- list(summary = fit$summary, readiness = fit$readiness,
      numerical = fit$opt$optimizer_diagnostics, root = fit$jml_adjustment$point,
      person_status = fit$facets$person, slopes = fit$slopes)
  }
  result <- plan[c("ConditionId", "Arm", "Replicate", "Target", "Output", "Analysis")]
  result$Estimate <- rep(values, 2L)
  result$Status <- if (nzchar(fitting$error)) "error" else "returned"
  result$Available <- !nzchar(fitting$error) & is.finite(result$Estimate) &
    (result$Analysis == "initial_finite_return" | pass)
  result$SE <- result$Lower <- result$Upper <- NA_real_; result$SourceStage <- stage
  result$Reason <- if (nzchar(fitting$error)) fitting$error else "No finite initial-call target value"
  result$Reason[is.finite(result$Estimate) & !result$Available] <- "Stored initial numerical checks did not pass"
  result$Reason[result$Available] <- ""
  result <- result[plan$Eligibility == "eligible", ]
  wide_recovery_records(plan, result)
  list(plan = plan, results = result, diagnostics = diagnostics, numerical_pass = pass,
    interpretation = "Finite initial algorithm returns and the stored-numerical-pass subset; neither certifies an identified finite/profile optimum or scoring admission.")
}

wide_recovery_records <- function(plan, results) {
  allowed <- c("initial_finite_return", "initial_numerical_pass")
  stopifnot(all(plan$Analysis %in% allowed), all(results$Analysis %in% allowed),
    all(results$Analysis %in% plan$Analysis))
  do.call(rbind, lapply(unique(plan$Analysis), function(analysis) {
    p <- plan[plan$Analysis == analysis, ]; r <- results[results$Analysis == analysis, ]
    r$Analysis <- NULL
    wide_output_records(p, r)
  }))
}

wide_recovery_summary <- function(plan, results) {
  x <- wide_recovery_records(plan, results)
  do.call(rbind, lapply(unique(plan$Analysis), function(analysis) {
    p <- plan[plan$Analysis == analysis, ]; r <- results[results$Analysis == analysis, ]; r$Analysis <- NULL
    s <- wide_output_summary(p, r); s$Analysis <- analysis
    s$AvailabilityMCSE <- ifelse(s$Eligible > 0, sqrt(s$Availability*(1-s$Availability)/s$Eligible), NA_real_)
    s$RMSEMCSE <- vapply(seq_len(nrow(s)), function(i) {
      z <- x[x$Analysis == analysis & x$ConditionId == s$ConditionId[i] &
        x$Arm == s$Arm[i] & x$Target == s$Target[i] & x$Available, ]
      loss <- (z$Estimate - z$ReferenceValue)^2
      if (!s$Complete[i] || length(loss) < 2L) NA_real_ else
        if (mean(loss) == 0) 0 else sd(loss)/(2*sqrt(mean(loss))*sqrt(length(loss)))
    }, 0)
    s
  }))
}

# Collapse the fixed grid within a dataset before calculating Monte Carlo SEs.
# Categories, contexts and ability points are not independent replications.
wide_recovery_grid_losses <- function(plan, results) {
  x <- wide_recovery_records(plan, results); x <- x[x$Kind == "probability", ]
  group <- c("Analysis", "ConditionId", "Arm", "Replicate")
  ids <- do.call(paste, c(x[group], sep = "\r"))
  do.call(rbind, lapply(split(seq_len(nrow(x)), ids), function(i) {
    z <- x[i, ]; stopifnot(length(unique(z$InputId)) == 1L,
      length(unique(z$SourceStage[z$Status == "returned"])) <= 1L)
    settled <- all(z$Status %in% c("returned", "error")); available <- all(z$Available)
    data.frame(z[1, group], InputId = z$InputId[1], GridCells = nrow(z),
      Complete = settled, Available = available,
      MSE = if (available) mean((z$Estimate-z$ReferenceValue)^2) else NA_real_)
  }))
}

wide_recovery_grid_summary <- function(losses) {
  group <- c("Analysis", "ConditionId", "Arm")
  ids <- do.call(paste, c(losses[group], sep = "\r"))
  do.call(rbind, lapply(split(seq_len(nrow(losses)), ids), function(i) {
    z <- losses[i, ]; stopifnot(!anyDuplicated(z$Replicate), length(unique(z$GridCells)) == 1L)
    complete <- all(z$Complete); v <- z$MSE[z$Available]; n <- length(v); mse <- if (n) mean(v) else NA_real_
    mcse <- if (complete && n > 1L) sd(v)/sqrt(n) else NA_real_
    data.frame(z[1, group], Planned = nrow(z), Available = n, Complete = complete,
      Availability = if (complete) n/nrow(z) else NA_real_,
      MSE = if (complete) mse else NA_real_, MSEMCSE = mcse,
      RMSE = if (complete) sqrt(mse) else NA_real_,
      RMSEMCSE = if (complete && n > 1L) if (mse == 0) 0 else mcse/(2*sqrt(mse)) else NA_real_)
  }))
}

wide_recovery_paired <- function(plan, results, arm_a, arm_b) {
  # Fixed PCM/RSM slopes are not estimated outputs. All remaining common
  # targets must be prespecified in both arms, including every replication.
  fixed <- unique(plan$Target[plan$Arm %in% c(arm_a, arm_b) & plan$Eligibility == "fixed"])
  p <- plan[!plan$Target %in% fixed, ]; r <- results[!results$Target %in% fixed, ]
  points <- do.call(rbind, lapply(unique(p$Analysis), function(analysis) {
    a <- p[p$Analysis == analysis, ]; b <- r[r$Analysis == analysis, ]; b$Analysis <- NULL
    out <- wide_paired_point_summary(a, b, arm_a, arm_b); out$Analysis <- analysis; out
  }))
  losses <- wide_recovery_grid_losses(p, r)
  keys <- c("Analysis", "ConditionId", "Replicate")
  z <- merge(losses[losses$Arm == arm_a, ], losses[losses$Arm == arm_b, ], by = keys,
    suffixes = c("_A", "_B"), all = TRUE)
  stopifnot(!anyNA(z$Arm_A), !anyNA(z$Arm_B), all(z$InputId_A == z$InputId_B), all(z$GridCells_A == z$GridCells_B))
  ids <- paste(z$Analysis, z$ConditionId, sep = "\r")
  grid <- do.call(rbind, lapply(split(seq_len(nrow(z)), ids), function(i) {
    a <- z[i, ]; both <- a$Available_A & a$Available_B; complete <- all(a$Complete_A & a$Complete_B)
    d <- a$MSE_A[both] - a$MSE_B[both]
    data.frame(Analysis = a$Analysis[1], ConditionId = a$ConditionId[1], ArmA = arm_a, ArmB = arm_b,
      PlannedPairs = nrow(a), AAvailable = sum(a$Available_A), BAvailable = sum(a$Available_B),
      BothAvailable = sum(both), Complete = complete,
      MeanSquaredErrorDifference = if (complete && length(d)) mean(d) else NA_real_,
      PairedMCSE = if (complete && length(d) > 1L) sd(d)/sqrt(length(d)) else NA_real_)
  }))
  list(points = points, grid = grid, not_compared_fixed_targets = fixed)
}
