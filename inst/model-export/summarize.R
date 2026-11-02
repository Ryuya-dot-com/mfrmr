# Shared by both exported runners; no mfrmr installation is needed for replay.
mfrm_population_label <- function(population = NULL) {
  if (is.null(population)) return("Fixed N(0,1)")
  if (!is.list(population) || !identical(population$mode, "estimated_normal") ||
      !identical(population$formula, "~1") ||
      !identical(population$parameterization, "noncentered"))
    stop("Unsupported exported population specification.")
  "Normal population with estimated mean and SD"
}

mfrm_parameter_map <- function(bundle) {
  d <- bundle$stan_data
  roles <- bundle$model_roles
  if (!is.null(roles)) {
    facets <- unique(bundle$levels$Facet[bundle$levels$Facet != "Person"])
    owners <- unique(as.character(bundle$slope_levels$Owner))
    uncentered <- unique(bundle$levels$Facet[bundle$levels$Facet != "Person" & !bundle$levels$Centered])
    if (!identical(bundle$model, "GPCM") || !identical(roles$equation, "full_predictor_product") ||
        !identical(roles$population, "fixed_N01") || !isTRUE(roles$link_scale == 1) ||
        !setequal(roles$facets, facets) || !identical(roles$slope_facets, owners) ||
        length(owners) != 2L || !identical(roles$slope_reference, owners[1L]) ||
        !identical(roles$slope_prior_reference, roles$slope_reference) ||
        !identical(roles$noncenter_facet, uncentered) ||
        length(roles$step_facet) != 1L || !roles$step_facet %in% facets ||
        !identical(bundle$step_owners, bundle$levels$Level[bundle$levels$Facet == roles$step_facet]))
      stop("Two-family model roles disagree with the exported parameter map.")
  }
  population_label <- mfrm_population_label(bundle$population)
  free_population <- !is.null(bundle$population)
  rows <- list()
  add <- function(variable, quantity, facet, level, fixed, value, anchored, reference, direction, transition = NA_character_) {
    rows[[length(rows) + 1L]] <<- data.frame(variable, quantity, facet, level, transition,
      value_role = if (!fixed) "estimated" else if (anchored) "fixed_anchor" else "fixed_by_constraint",
      fixed_value = if (fixed) value else NA_real_, reference, direction,
      stringsAsFactors = FALSE)
  }
  for (i in seq_len(nrow(bundle$levels))) {
    r <- bundle$levels[i, ]
    person <- startsWith(r$Parameter, "theta[")
    fixed <- !person && all(d$location_basis[r$Index, ] == 0)
    value <- if (fixed && !is.null(d$location_offset)) d$location_offset[r$Index] else 0
    spec <- bundle$constraints$facets[[r$Facet]]
    anchored <- !is.null(spec) && !is.na(spec$anchors[match(r$Level, spec$levels)])
    reference <- if (person && free_population) "Estimated normal population; native relative-slope metric; observed Persons are not centered." else
      if (person) "Population N(0,1); observed Persons are not forced to average zero." else
      if (r$Centered) "Saved facet centering constraints; zero is not a performance standard." else
        if (free_population) "Uncentered location on the native relative-slope metric." else
          "Uncentered location on the fixed N(0,1) ability scale."
    add(r$Parameter, if (person) "ability" else "location", r$Facet, r$Level,
      fixed, value, anchored, reference,
      if (r$Sign == 1) "Higher values favor higher coded scores." else "Higher values favor lower coded scores.")
  }
  if (free_population) {
    add("population_mean", "population_mean", "Population", "Mean", FALSE, NA_real_, FALSE,
      population_label, "Higher values favor higher coded scores; not necessarily better performance.")
    add("population_sd", "population_sd", "Population", "SD", FALSE, NA_real_, FALSE,
      "Native metric with geometric-mean-one relative slopes; not an individual Person SE.",
      "Larger values indicate more between-Person variation in the assumed population.")
  }
  for (g in seq_len(d$G)) for (k in seq_len(d$C - 1L)) {
    index <- (g - 1L) * (d$C - 1L) + k
    basis_row <- if (isTRUE(bundle$affine)) index else k
    fixed <- all(d$step_basis[basis_row, ] == 0)
    value <- if (fixed && !is.null(d$step_offset)) d$step_offset[index] else 0
    spec <- bundle$constraints$steps[[g]]
    anchored <- !is.null(spec) && !is.na(spec$anchors[k])
    add(paste0("steps[", g, ",", k, "]"), "step_offset", if (is.null(roles)) "Step owner" else roles$step_facet, bundle$step_owners[g],
      fixed, value, anchored, paste0("Transition ", bundle$categories$Score[k], " to ",
        bundle$categories$Score[k + 1L], "; saved within-owner sum constraint."),
      "Higher offsets reduce the adjacent-category odds of the higher coded score.",
      paste(bundle$categories$Score[k], "->", bundle$categories$Score[k + 1L]))
  }
  if (!is.null(bundle$slope_levels)) for (i in seq_len(nrow(bundle$slope_levels))) {
    r <- bundle$slope_levels[i, ]
    fixed <- all(d$slope_basis[r$Index, ] == 0)
    reference <- if (r$ScaleReference == "geometric_mean_one")
      "Owner geometric mean slope = 1; one is a reference, not a quality standard." else
        "Component scale identified by the fixed N(0,1) ability population."
    add(r$Parameter, "slope", r$Owner, r$Level, fixed, 1, FALSE, reference,
      "Steepness of the response relationship, not rater severity.")
    add(r$LogParameter, "log_slope", r$Owner, r$Level, fixed, 0, FALSE, reference,
      "Log component slope, not rater severity.")
  }
  do.call(rbind, rows)
}

mfrm_sampling_review <- function(parameters, sampler, chains) {
  checks <- list()
  add <- function(check, value, criterion, ok, action) {
    checks[[length(checks) + 1L]] <<- data.frame(Check = check, Value = value,
      Criterion = criterion, Status = if (is.na(ok)) "not_available" else if (ok) "no_flag" else "review",
      NextAction = if (isTRUE(ok)) "No action from this check." else action, stringsAsFactors = FALSE)
  }
  p <- parameters[!parameters$value_role %in% c("fixed_anchor", "fixed_by_constraint"), ]
  add("Chains", chains, ">= 4", chains >= 4, "Use at least four chains for the final sampling review.")
  for (name in c("rhat", "ess_bulk", "ess_tail")) {
    v <- p[[name]]
    known <- length(v) > 0L && all(is.finite(v))
    value <- if (!known) NA_real_ else if (name == "rhat") max(v) else min(v)
    add(name, value, if (name == "rhat") "< 1.01 for all varying coordinates" else paste0(">= ", 100 * chains, " (100 per chain)"),
      if (!known) NA else if (name == "rhat") value < 1.01 else value >= 100 * chains,
      "Inspect all varying coordinates and chain traces; diagnose poor mixing before adding draws.")
  }
  complete <- nrow(sampler) == chains && "chain" %in% names(sampler) &&
    !anyNA(sampler$chain) && !anyDuplicated(sampler$chain)
  for (name in c("num_divergent", "num_max_treedepth", "ebfmi")) {
    v <- sampler[[name]]
    known <- complete && length(v) == chains && all(is.finite(v)) && all(v >= 0)
    value <- if (!known) NA_real_ else if (name == "ebfmi") min(v) else sum(v)
    add(name, value, if (name == "ebfmi") ">= 0.3 in every chain" else "0 across chains",
      if (!known) NA else if (name == "ebfmi") value >= 0.3 else value == 0,
      if (name == "num_max_treedepth") "Review sampling efficiency and geometry; tree-depth hits alone do not establish bias." else
        "Inspect sampler diagnostics and model geometry before interpreting posterior intervals.")
  }
  do.call(rbind, checks)
}

mfrm_draws_should_na <- function(x, tol = .Machine$double.eps) {
  anyNA(x) || any(is.infinite(x)) || !length(x) || abs(max(x) - min(x)) < tol
}

mfrm_draws_split_chains <- function(x) {
  x <- as.matrix(x)
  niter <- nrow(x)
  if (niter <= 1L) return(x)
  half <- niter / 2
  cbind(x[seq_len(floor(half)), , drop = FALSE], x[ceiling(half + 1):niter, , drop = FALSE])
}

mfrm_draws_z_scale <- function(x, c = 3 / 8) {
  r <- rank(as.array(x), ties.method = "average")
  S <- length(r)
  z <- stats::qnorm((r - c) / (S - 2 * c + 1))
  z[is.na(x)] <- NA_real_
  if (!is.null(dim(x))) z <- array(z, dim = dim(x), dimnames = dimnames(x))
  z
}

mfrm_draws_autocovariance <- function(x) {
  N <- length(x)
  varx <- stats::var(x)
  if (is.na(varx) || varx == 0) return(rep(0, N))
  M <- stats::nextn(N)
  yc <- c(x - mean(x), rep.int(0, 2L * M - N))
  ac <- Re(stats::fft(abs(stats::fft(yc))^2, inverse = TRUE)[seq_len(N)])
  ac / ac[1L] * varx * (N - 1) / N
}

mfrm_draws_rhat_split <- function(x) {
  x <- as.matrix(x)
  if (mfrm_draws_should_na(x) || ncol(x) < 2L || nrow(x) < 2L) return(NA_real_)
  niter <- nrow(x)
  c_mean <- colMeans(x)
  c_var <- colSums((x - rep(c_mean, each = niter))^2) / (niter - 1)
  var_b <- niter * stats::var(c_mean)
  var_w <- mean(c_var)
  if (!is.finite(var_w) || var_w <= 0) return(NA_real_)
  sqrt((var_b / var_w + niter - 1) / niter)
}

mfrm_draws_rhat <- function(x) {
  x <- as.matrix(x)
  if (mfrm_draws_should_na(x)) return(NA_real_)
  rb <- mfrm_draws_rhat_split(mfrm_draws_z_scale(mfrm_draws_split_chains(x)))
  rt <- mfrm_draws_rhat_split(mfrm_draws_z_scale(mfrm_draws_split_chains(abs(x - stats::median(x)))))
  if (is.na(rb) || is.na(rt)) return(NA_real_)
  max(rb, rt)
}

mfrm_draws_ess <- function(x) {
  x <- as.matrix(x)
  nchains <- ncol(x); niter <- nrow(x)
  if (niter < 3L || mfrm_draws_should_na(x)) return(NA_real_)
  acov <- apply(x, 2L, mfrm_draws_autocovariance)
  if (!is.matrix(acov)) acov <- matrix(acov, nrow = niter)
  acov_means <- rowMeans(acov)
  mean_var <- acov_means[1L] * niter / (niter - 1)
  var_plus <- mean_var * (niter - 1) / niter
  if (nchains > 1L) var_plus <- var_plus + stats::var(colMeans(x))
  if (!is.finite(var_plus) || var_plus <= 0) return(NA_real_)
  rho_hat_t <- rep.int(0, niter)
  t <- 0L
  rho_hat_even <- 1
  rho_hat_t[t + 1L] <- rho_hat_even
  rho_hat_odd <- 1 - (mean_var - acov_means[t + 2L]) / var_plus
  rho_hat_t[t + 2L] <- rho_hat_odd
  while (t < nrow(acov) - 5L && !is.nan(rho_hat_even + rho_hat_odd) && (rho_hat_even + rho_hat_odd > 0)) {
    t <- t + 2L
    rho_hat_even <- 1 - (mean_var - acov_means[t + 1L]) / var_plus
    rho_hat_odd <- 1 - (mean_var - acov_means[t + 2L]) / var_plus
    if ((rho_hat_even + rho_hat_odd) >= 0) {
      rho_hat_t[t + 1L] <- rho_hat_even
      rho_hat_t[t + 2L] <- rho_hat_odd
    }
  }
  max_t <- t
  if (rho_hat_even > 0) rho_hat_t[max_t + 1L] <- rho_hat_even
  t <- 0L
  while (t <= max_t - 4L) {
    t <- t + 2L
    if (rho_hat_t[t + 1L] + rho_hat_t[t + 2L] > rho_hat_t[t - 1L] + rho_hat_t[t]) {
      rho_hat_t[t + 1L] <- (rho_hat_t[t - 1L] + rho_hat_t[t]) / 2
      rho_hat_t[t + 2L] <- rho_hat_t[t + 1L]
    }
  }
  ess <- nchains * niter
  tau_hat <- -1 + 2 * sum(rho_hat_t[seq_len(max_t)]) + rho_hat_t[max_t + 1L]
  tau_bound <- 1 / log10(ess)
  if (tau_hat < tau_bound) tau_hat <- tau_bound
  ess / tau_hat
}

mfrm_draws_ess_bulk <- function(x) {
  mfrm_draws_ess(mfrm_draws_z_scale(mfrm_draws_split_chains(x)))
}

mfrm_draws_ess_quantile <- function(x, prob) {
  if (mfrm_draws_should_na(x)) return(NA_real_)
  x <- as.matrix(x)
  if (prob == 1) {
    len <- length(x)
    prob <- (len - 0.5) / len
  }
  I <- x <= stats::quantile(x, prob, names = FALSE)
  mfrm_draws_ess(mfrm_draws_split_chains(I))
}

mfrm_draws_ess_tail <- function(x) {
  e1 <- mfrm_draws_ess_quantile(x, 0.05)
  e2 <- mfrm_draws_ess_quantile(x, 0.95)
  if (is.na(e1) || is.na(e2)) return(NA_real_)
  min(e1, e2)
}

mfrm_draws_mcse_quantile <- function(x, prob) {
  ess <- mfrm_draws_ess_quantile(x, prob)
  if (is.na(ess) || !is.finite(ess)) return(NA_real_)
  p <- c(0.1586553, 0.8413447)
  a <- stats::qbeta(p, ess * prob + 1, ess * (1 - prob) + 1)
  ssims <- sort(as.numeric(x))
  S <- length(ssims)
  th1 <- ssims[max(floor(a[1L] * S), 1L)]
  th2 <- ssims[min(ceiling(a[2L] * S), S)]
  (th2 - th1) / 2
}

mfrm_summarize_draw_array <- function(draws_array, level = 0.95) {
  vars <- dimnames(draws_array)[[3L]]
  alpha_low <- (1 - level) / 2
  alpha_high <- 1 - alpha_low
  n_var <- length(vars)
  n_iter <- dim(draws_array)[1L]
  n_chain <- dim(draws_array)[2L]
  mean_v <- median_v <- sd_v <- lower_v <- upper_v <- numeric(n_var)
  rhat_v <- ess_b <- ess_t <- mcse_l <- mcse_u <- numeric(n_var)
  for (j in seq_len(n_var)) {
    mat <- matrix(draws_array[, , j], nrow = n_iter, ncol = n_chain)
    vec <- as.numeric(mat)
    mean_v[j] <- base::mean(vec)
    median_v[j] <- stats::median(vec)
    sd_v[j] <- stats::sd(vec)
    qs <- stats::quantile(vec, probs = c(alpha_low, alpha_high), names = FALSE)
    lower_v[j] <- qs[1L]
    upper_v[j] <- qs[2L]
    rhat_v[j] <- mfrm_draws_rhat(mat)
    ess_b[j] <- mfrm_draws_ess_bulk(mat)
    ess_t[j] <- mfrm_draws_ess_tail(mat)
    mcse_l[j] <- mfrm_draws_mcse_quantile(mat, alpha_low)
    mcse_u[j] <- mfrm_draws_mcse_quantile(mat, alpha_high)
  }
  data.frame(
    variable = vars,
    mean = mean_v, median = median_v, sd = sd_v,
    lower = lower_v, upper = upper_v,
    rhat = rhat_v, ess_bulk = ess_b, ess_tail = ess_t,
    mcse_lower = mcse_l, mcse_upper = mcse_u,
    stringsAsFactors = FALSE
  )
}

summarize_mfrm_draws <- function(draws, bundle, sampler, backend) {
  if (!(is.array(draws) && length(dim(draws)) == 3L && is.numeric(draws) &&
        !is.null(dimnames(draws)[[3L]]))) {
    draws <- posterior::as_draws_array(draws)
  }
  raw_draws <- array(as.numeric(draws), dim = dim(draws),
    dimnames = list(NULL, NULL, dimnames(draws)[[3L]]))
  var_names <- dimnames(raw_draws)[[3L]]
  map <- mfrm_parameter_map(bundle)
  if (anyDuplicated(map$variable) || !all(map$variable %in% var_names))
    stop("Draws do not contain the complete exported parameter map. Keep fit.rds and check the matching bundle.")
  # Fixed status comes from the model map, never from a zero sample variance.
  for (i in which(!is.na(map$fixed_value))) {
    v <- raw_draws[, , map$variable[i]]
    if (any(!is.finite(v)) || any(abs(v - map$fixed_value[i]) > 1e-7 * max(1, abs(map$fixed_value[i]))))
      stop("Draws disagree with fixed constraints. Check that fit.rds and model-data.rds belong together.")
  }
  p <- mfrm_summarize_draw_array(raw_draws, level = .95)
  m <- map[match(p$variable, map$variable), setdiff(names(map), "variable"), drop = FALSE]
  unknown <- is.na(m$value_role)
  m$value_role[unknown] <- "sampling_coordinate"
  m$quantity[unknown] <- "internal_coordinate"
  m$reference[unknown] <- "Internal sampling coordinate; use mapped parameters for substantive reporting."
  p <- cbind(p, m); rownames(p) <- NULL
  p$role <- ifelse(unknown, "free_coordinate", "reported_parameter")
  fixed <- p$value_role %in% c("fixed_anchor", "fixed_by_constraint")
  p$interval_computed <- is.finite(p$lower) & is.finite(p$upper) & !fixed
  # A fixed value has no estimated uncertainty; raw constant draws remain in fit.rds.
  p[fixed, c("sd", "lower", "upper", "rhat", "ess_bulk", "ess_tail", "mcse_lower", "mcse_upper")] <- NA_real_
  width <- p$upper - p$lower
  p$endpoint_mcse_fraction <- ifelse(is.finite(width) & width > 0,
    pmax(p$mcse_lower, p$mcse_upper) / width, NA_real_)
  checks <- mfrm_sampling_review(p, sampler, dim(raw_draws)[2L])
  flagged <- checks$Status != "no_flag"
  status <- if (any(flagged)) "sampling_review_required" else "no_sampling_flags_detected"
  p$sampling_review <- status
  p$interval_status <- ifelse(fixed, "fixed_value_no_interval", ifelse(!p$interval_computed,
    "unavailable", if (any(flagged)) "computed_sampling_review_required" else "computed_model_review_required"))
  first <- c("variable", "quantity", "facet", "level", "transition", "value_role", "mean", "median", "sd",
    "lower", "upper", "interval_status", "sampling_review", "fixed_value", "reference", "direction")
  p <- p[, c(first, setdiff(names(p), first))]
  reasons <- c(Chains = "Fewer than four chains", rhat = "Chain mixing (R-hat) needs review",
    ess_bulk = "Effective sample size for central summaries needs review",
    ess_tail = "Effective sample size for tail summaries needs review",
    num_divergent = "Divergent transitions", num_max_treedepth = "Tree-depth limit reached",
    ebfmi = "Energy exploration needs review")
  why <- unname(reasons[checks$Check])
  why[checks$Status == "not_available"] <- paste("Diagnostic unavailable:", checks$Check[checks$Status == "not_available"])
  decision <- data.frame(Status = status,
    Interpretation = if (any(flagged)) "Review sampling before interpreting intervals" else "No sampling flags detected; model review remains",
    Why = if (any(flagged)) paste(why[flagged], collapse = "; ") else "Listed sampling checks detected no flags.",
    NextAction = if (any(flagged)) "Read sampling-review.csv before interpreting estimates or intervals." else
      "Review model fit, priors and target-specific Monte Carlo error before reporting.")
  result <- list(schema_version = if (is.null(bundle$population)) 1L else 2L, chains = as.integer(dim(raw_draws)[2L]),
    model_data_md5 = if (file.exists("model-data.rds")) unname(tools::md5sum("model-data.rds")) else NA_character_,
    parameters = p, sampler = sampler, decision = decision, checks = checks,
    backend = backend, interval = "equal-tailed posterior credible interval for varying parameters", level = .95,
    notes = c("Sampling checks are a screen, not a certificate of validity or calibrated coverage.",
      "Fixed anchors and constraint-determined values have no estimated interval; calibration uncertainty is not propagated.",
      "Computed intervals remain visible during review; examine all varying coordinates and chains.",
      "Endpoint MCSE is simulation error, not posterior uncertainty. Choose sufficient precision for the intended claim.",
      "Higher coded scores need not mean better performance; retain the original rubric direction.",
      "Review prior sensitivity and posterior predictive fit; Bayesian intervals do not validate MML coverage.",
      "Screening criteria: https://mc-stan.org/learn-stan/diagnostics-warnings.html"))
  if (!is.null(bundle$model_roles)) {
    r <- bundle$model_roles
    result$notes <- c(result$notes,
      paste0("Two-family full-predictor model: slope facets ", paste(r$slope_facets, collapse = ", "),
        "; geometric-mean-one reference ", r$slope_reference, "; step facet ", r$step_facet,
        "; uncentered location facet ", r$noncenter_facet, "."),
      "The log-slope prior is tied to the exported geometric-mean-one reference. Exporting another reference with fresh independent priors changes the Bayesian model.")
  }
  for (name in c("parameters", "sampler", "checks", "decision")) {
    file <- c(parameters = "parameter-summary.csv", sampler = "sampler-diagnostics.csv",
      checks = "sampling-review.csv", decision = "summary-decision.csv")[[name]]
    utils::write.csv(result[[name]], file, row.names = FALSE, fileEncoding = "UTF-8")
  }
  saveRDS(result, "posterior-summary.rds")
  draws_ordered <- raw_draws[, , result$parameters$variable, drop = FALSE]
  draws_bundle <- list(
    schema_version = result$schema_version,
    backend = backend,
    chains = result$chains,
    iterations = as.integer(dim(draws_ordered)[1L]),
    model_data_md5 = result$model_data_md5,
    posterior_summary_md5 = if (file.exists("posterior-summary.rds")) unname(tools::md5sum("posterior-summary.rds")) else NA_character_,
    draws = draws_ordered
  )
  saveRDS(draws_bundle, "posterior-draws.rds")
  cat("Posterior review (", backend, ")\n", sep = "")
  cat(decision$Interpretation, "\nWhy: ", decision$Why, "\nNext: ", decision$NextAction, "\n", sep = "")
  cat("Fixed values have no estimated interval. Sampling checks do not establish model validity.\n")
  main <- p[p$role == "reported_parameter" & p$quantity != "log_slope", ]
  preview <- which(!duplicated(main[, c("quantity", "value_role")]))
  print(utils::head(main[preview, c("quantity", "facet", "level", "transition", "value_role", "mean", "lower", "upper", "interval_status")], 8L), row.names = FALSE)
  cat(nrow(main), "mapped parameters; all rows and diagnostic coordinates are in parameter-summary.csv.\n")
  invisible(result)
}

mfrm_brms_draws <- function(fit, parameters) {
  # Transform each preserved chain/iteration in the same chain-major order used by extract_mfrm_parameters().
  raw <- posterior::as_draws_array(fit)
  parts <- list()
  for (name in c("theta", "locations", "steps", "component_slopes", "log_component_slopes")) {
    x <- parameters[[name]]
    if (is.null(x) || length(x) == 0L) next
    dims <- dim(x)
    mat <- matrix(x, nrow = dims[1L])
    indices <- if (length(dims) == 3L) apply(expand.grid(seq_len(dims[2L]), seq_len(dims[3L])), 1L, paste, collapse = ",") else seq_len(ncol(mat))
    colnames(mat) <- paste0(name, "[", indices, "]")
    parts[[name]] <- mat
  }
  mapped <- do.call(cbind, parts)
  if (nrow(mapped) != prod(dim(raw)[1:2])) stop("Mapped brms draws lost their chain/iteration alignment.")
  transformed <- posterior::as_draws_array(array(mapped, c(dim(raw)[1:2], ncol(mapped)),
    dimnames = list(dimnames(raw)[[1]], dimnames(raw)[[2]], colnames(mapped))))
  internal <- posterior::subset_draws(raw, variable = grep("^(b_|lp__$)", posterior::variables(raw), value = TRUE))
  posterior::bind_draws(transformed, internal, along = "variable")
}

mfrm_brms_sampler <- function(fit) {
  nuts <- brms::nuts_params(fit)
  depth <- brms::control_params(fit)$max_treedepth
  chains <- posterior::nchains(fit)
  do.call(rbind, lapply(seq_len(chains), function(chain) {
    get <- function(name) {
      x <- nuts[nuts$Chain == chain & nuts$Parameter == name, ]
      x$Value[order(x$Iteration)]
    }
    divergent <- get("divergent__"); tree <- get("treedepth__"); energy <- get("energy__")
    expected <- posterior::niterations(fit)
    complete <- function(x) length(x) == expected && all(is.finite(x))
    data.frame(chain = chain,
      num_divergent = if (complete(divergent)) sum(divergent) else NA_real_,
      num_max_treedepth = if (complete(tree) && length(depth) == 1L && is.finite(depth)) sum(tree >= depth) else NA_real_,
      ebfmi = if (complete(energy) && length(energy) > 1L && stats::var(energy) > 0)
        mean(diff(energy)^2) / stats::var(energy) else NA_real_)
  }))
}
