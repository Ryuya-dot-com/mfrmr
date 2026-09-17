# Shared adaptive integration and explicit fixed-parameter integration review.

mfrmr_adaptive_integration <- function(config) {
  mode <- config$estimation_control$mml_integration %||% "fixed"
  if (!is.character(mode) || length(mode) != 1L || !mode %in% c("fixed", "adaptive")) {
    stop("Unrecognized MML integration mode in the retained configuration.", call. = FALSE)
  }
  identical(mode, "adaptive")
}

mfrmr_adaptive_posterior_location <- function(evaluate) {
  mode <- stats::uniroot(function(z) evaluate(z)$score, c(-1, 1),
                         extendInt = "downX", check.conv = TRUE, tol = 1e-12)$root
  at_mode <- evaluate(mode)
  scale <- 1 / sqrt(at_mode$information)
  if (!is.finite(scale) || scale <= 0) stop("Invalid local posterior scale.", call. = FALSE)
  list(mode = mode, scale = scale, score = at_mode$score)
}

mfrmr_adaptive_quadrature_basis <- function(idx, config, params, quad, base_eta,
                                            population_spec = NULL,
                                            person_count = config$n_person) {
  basis <- resolve_person_quadrature_basis(
    quad, population_spec %||% materialize_population_spec(config, params),
    person_count = person_count
  )
  mu <- if (isTRUE(basis$transformed)) basis$mu else rep(0, person_count)
  sigma <- if (isTRUE(basis$transformed)) basis$sigma else 1
  weights <- idx$weight %||% rep(1, length(idx$score_k))
  if (any(!is.finite(weights)) || any(weights < 0)) {
    stop("Adaptive quadrature requires finite non-negative observation weights.", call. = FALSE)
  }
  persons <- sort(unique(idx$person))
  groups <- split(seq_along(idx$person), factor(idx$person, levels = persons))
  for (i in seq_along(groups)) {
    person <- persons[i]
    rows <- groups[[i]]
    local_idx <- list(person = rep(1L, length(rows)), score_k = idx$score_k[rows],
      weight = weights[rows], step_idx = idx$step_idx[rows], slope_idx = idx$slope_idx[rows])
    evaluate <- mfrmr_adaptive_person_kernel(
      local_idx, config, params, base_eta[rows], mu[person], sigma
    )
    location <- mfrmr_adaptive_posterior_location(evaluate)
    z <- location$mode + location$scale * quad$nodes
    basis$nodes[person, ] <- mu[person] + sigma * z
    basis$log_weights[person, ] <- log(quad$weights) + stats::dnorm(z, log = TRUE) -
      stats::dnorm(quad$nodes, log = TRUE) + log(location$scale)
  }
  basis
}

# Shared one-Person kernel, with coordinates standardized to the original prior.
mfrmr_adaptive_person_kernel <- function(idx, config, params, base_eta, mu, sigma) {
  config$n_person <- 1L
  config$population_spec <- list(active = FALSE)
  categories <- seq_len(config$n_cat) - 1L
  slope <- if (identical(config$model, "GPCM")) params$slopes[idx$slope_idx] else
    rep(1, length(idx$score_k))
  if (any(!is.finite(slope)) || any(slope <= 0)) {
    stop("The retained slopes are not positive finite values.", call. = FALSE)
  }
  function(z, include_linear_part = FALSE, include_moments = TRUE) {
    # CDF integration needs only likelihoods; retain the R moment/gradient path.
    if (!include_moments && mfrm_use_cpp11_backend(config, include_linear_part)) {
      bundle <- mfrm_mml_logprob_bundle_cpp11(
        idx, config, list(nodes = mu + sigma * z, weights = rep(1, length(z))),
        params, base_eta, include_probs = FALSE
      )
      return(list(log_likelihood = colSums(bundle$log_prob_mat)))
    }
    bundle <- mfrm_mml_logprob_bundle_r(
      idx, config, list(nodes = mu + sigma * z, weights = rep(1, length(z))),
      params, base_eta, include_probs = include_moments, include_linear_part = include_linear_part
    )
    if (!include_moments) return(list(log_likelihood = colSums(bundle$log_prob_mat)))
    moments <- vapply(bundle$prob_list, function(probability) {
      expected <- as.vector(probability %*% categories)
      variance <- rowSums(probability *
        (rep(categories, each = nrow(probability)) - expected)^2)
      c(score = sigma * sum(idx$weight * slope * (idx$score_k - expected)),
        information = sigma^2 * sum(idx$weight * slope^2 * variance))
    }, c(score = 0, information = 0))
    list(log_likelihood = colSums(bundle$log_prob_mat),
         score = moments[1L, ] - z, information = moments[2L, ] + 1,
         prob_list = bundle$prob_list, linear_part_list = bundle$linear_part_list)
  }
}

mfrmr_validate_adaptive_quad_points <- function(points) {
  if (is.null(points)) return(NULL)
  if (!is.numeric(points) || length(points) < 2L || any(!is.finite(points)) ||
      any(points < 3 | points > .Machine$integer.max | points != floor(points)) ||
      length(unique(points)) < 2L) {
    stop("`adaptive_quad_points` must be NULL or at least two distinct integer orders >= 3.",
         call. = FALSE)
  }
  points <- sort(unique(as.integer(points)))
  # Validate representability once, before fitting or scoring.
  invisible(lapply(points, gauss_hermite_normal))
  points
}

mfrmr_adaptive_quadrature_review <- function(
    idx, config, params, quad, person_labels, adaptive_quad_points,
    population_spec = NULL, base_eta = NULL) {
  rules <- lapply(adaptive_quad_points, gauss_hermite_normal)
  basis <- resolve_person_quadrature_basis(
    list(nodes = c(0, 1), weights = c(1, 1)),
    population_spec = population_spec %||% materialize_population_spec(config, params),
    person_count = length(person_labels)
  )
  mu <- if (isTRUE(basis$transformed)) basis$mu else rep(0, length(person_labels))
  sigma <- if (isTRUE(basis$transformed)) basis$sigma else 1
  base_eta <- base_eta %||% compute_base_eta(idx, params, config)
  weights <- idx$weight %||% rep(1, length(idx$score_k))
  if (any(!is.finite(weights)) || any(weights < 0)) {
    stop("Adaptive quadrature review requires finite non-negative observation weights.",
         call. = FALSE)
  }
  person_ids <- sort(unique(idx$person))
  groups <- split(seq_along(idx$person), factor(idx$person, levels = person_ids))

  rows <- lapply(seq_along(groups), function(index) {
    person <- person_ids[index]
    observations <- groups[[index]]
    local_idx <- list(
      person = rep(1L, length(observations)),
      score_k = idx$score_k[observations], weight = weights[observations],
      step_idx = idx$step_idx[observations], slope_idx = idx$slope_idx[observations]
    )
    out <- data.frame(
      Person = rep(as.character(person_labels[person]), length(rules)),
      FixedNodes = length(quad$nodes), AdaptiveNodes = adaptive_quad_points,
      FixedLogMarginal = NA_real_, AdaptiveLogMarginal = NA_real_,
      LogMarginalChange = NA_real_,
      FixedEAP = NA_real_, AdaptiveEAP = NA_real_, EAPChange = NA_real_,
      FixedPosteriorSD = NA_real_, AdaptivePosteriorSD = NA_real_,
      PosteriorSDChange = NA_real_,
      AdaptiveLogMarginalChangeFromPrevious = NA_real_,
      AdaptiveEAPChangeFromPrevious = NA_real_,
      AdaptiveSDChangeFromPrevious = NA_real_,
      PosteriorMode = NA_real_, LocalPosteriorSD = NA_real_,
      ModeScore = NA_real_, Status = "unavailable", Detail = "",
      stringsAsFactors = FALSE
    )
    tryCatch({
      evaluate <- mfrmr_adaptive_person_kernel(
        local_idx, config, params, base_eta[observations], mu[person], sigma
      )
      summarize <- function(z, joint) {
        if (any(!is.finite(joint))) stop("Non-finite integration terms.", call. = FALSE)
        normalizer <- logsumexp(joint)
        probability <- exp(joint - normalizer)
        center <- sum(probability * z)
        value <- c(log_marginal = normalizer, eap = mu[person] + sigma * center,
                   sd = sigma * sqrt(sum(probability * (z - center)^2)))
        if (any(!is.finite(value))) stop("Non-finite posterior moments.", call. = FALSE)
        value
      }
      fixed <- summarize(quad$nodes, log(quad$weights) + evaluate(quad$nodes)$log_likelihood)
      # For non-negative weights and positive slopes the normal-prior log
      # posterior is strictly concave: information = 1 + sum(w a^2 Var(K)).
      location <- mfrmr_adaptive_posterior_location(evaluate)
      mode <- location$mode
      scale <- location$scale
      adaptive <- vapply(rules, function(rule) {
        z <- mode + scale * rule$nodes
        # The density ratio and Jacobian retain the original prior/integral.
        joint <- log(rule$weights) + evaluate(z)$log_likelihood +
          stats::dnorm(z, log = TRUE) - stats::dnorm(rule$nodes, log = TRUE) + log(scale)
        summarize(z, joint)
      }, c(log_marginal = 0, eap = 0, sd = 0))
      out$FixedLogMarginal <- fixed["log_marginal"]
      out$AdaptiveLogMarginal <- adaptive["log_marginal", ]
      out$LogMarginalChange <- out$AdaptiveLogMarginal - out$FixedLogMarginal
      out$FixedEAP <- fixed["eap"]
      out$AdaptiveEAP <- adaptive["eap", ]
      out$EAPChange <- out$AdaptiveEAP - out$FixedEAP
      out$FixedPosteriorSD <- fixed["sd"]
      out$AdaptivePosteriorSD <- adaptive["sd", ]
      out$PosteriorSDChange <- out$AdaptivePosteriorSD - out$FixedPosteriorSD
      out$AdaptiveLogMarginalChangeFromPrevious <- c(NA_real_, diff(out$AdaptiveLogMarginal))
      out$AdaptiveEAPChangeFromPrevious <- c(NA_real_, diff(out$AdaptiveEAP))
      out$AdaptiveSDChangeFromPrevious <- c(NA_real_, diff(out$AdaptivePosteriorSD))
      out$PosteriorMode <- mu[person] + sigma * mode
      out$LocalPosteriorSD <- sigma * scale
      out$ModeScore <- location$score
      out$Status <- "computed"
      out
    }, error = function(condition) {
      out$Detail <- conditionMessage(condition)
      out
    })
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_adaptive_quadrature_note <- function() {
  paste(
    "The quadrature_review table holds calibration parameters and the prior fixed",
    "and compares a fixed-prior grid with mode/curvature-adapted grids.",
    "Inspect both fixed/adaptive differences and changes between adaptive orders.",
    "Computed rows are numerical diagnostics, not certified accuracy or revised scores;",
    "unavailable rows retain the reason. Fit and score readiness are unchanged."
  )
}

mfrmr_adaptive_quadrature_overview <- function(review) {
  if (is.null(review) || nrow(review) == 0L) return(data.frame())
  groups <- split(review, interaction(review$FixedNodes, review$AdaptiveNodes, drop = TRUE))
  out <- do.call(rbind, lapply(groups, function(rows) {
    maximum <- function(column) {
      values <- abs(rows[[column]][rows$Status == "computed"])
      if (length(values) == 0L) NA_real_ else max(values, na.rm = TRUE)
    }
    data.frame(FixedNodes = rows$FixedNodes[1L], AdaptiveNodes = rows$AdaptiveNodes[1L],
      Persons = nrow(rows), Unavailable = sum(rows$Status != "computed"),
      MaxAbsLogMarginalChange = maximum("LogMarginalChange"),
      MaxAbsEAPChange = maximum("EAPChange"),
      MaxAbsSDChange = maximum("PosteriorSDChange"))
  }))
  rownames(out) <- NULL
  out
}

# The gradient differentiates the finite adaptive sum, including mode, scale
# and Jacobian, in the optimizer's actual free coordinates.
mfrmr_make_adaptive_mml_evaluator <- function(idx, config, sizes, quad_points) {
  if (!identical(config$method, "MML")) {
    stop("Adaptive MML evaluation requires an MML configuration.", call. = FALSE)
  }
  rule <- gauss_hermite_normal(quad_points)
  n <- length(idx$score_k)
  p <- sum(unlist(sizes, use.names = FALSE))
  categories <- seq_len(config$n_cat) - 1L
  weights <- idx$weight %||% rep(1, n)
  if (length(weights) != n || any(!is.finite(weights)) || any(weights < 0)) {
    stop("Adaptive MML requires finite non-negative observation weights.", call. = FALSE)
  }
  slices <- build_param_slices(sizes)
  adjacent <- mfrmr_estimability_adjacent_design(
    NULL, idx, config, sizes, include_person = FALSE, include_population_beta = FALSE
  )
  mapping <- Matrix::sparseMatrix(
    i = seq_len(ncol(adjacent$design)), j = adjacent$map$OptimizerIndex, x = 1,
    dims = c(ncol(adjacent$design), p)
  )
  adjacent <- adjacent$design %*% mapping
  cumulative <- lapply(seq_len(config$n_cat - 1L), function(k) {
    adjacent[seq_len(n) + (k - 1L) * n, , drop = FALSE]
  })
  cumulative <- do.call(rbind, Reduce(`+`, cumulative, accumulate = TRUE))
  log_slope_design <- mfrmr_empty_sparse_matrix(n, p)
  if (length(slices$log_slopes)) {
    log_slope_design[, slices$log_slopes] <-
      sum_zero_jacobian(length(config$gpcm_spec$levels))[idx$slope_idx, , drop = FALSE]
  }
  person_ids <- sort(unique(idx$person))
  groups <- split(seq_len(n), factor(idx$person, levels = person_ids))
  # Keep category designs sparse. Only the current Person's probabilities are dense.
  designs <- lapply(groups, function(rows) {
    list(cumulative = cumulative[as.vector(outer(rows, (categories[-1L] - 1L) * n, `+`)),
                                 , drop = FALSE],
         log_slope = log_slope_design[rows, , drop = FALSE])
  })
  function(par) {
    if (length(par) != p || any(!is.finite(par))) {
      stop("Adaptive MML requires a finite free-parameter vector of the expected length.", call. = FALSE)
    }
    params <- expand_params(par, sizes, config)
    base <- compute_base_eta(idx, params, config)
    population <- materialize_population_spec(config, params)
    basis <- resolve_person_quadrature_basis(
      list(nodes = 0, weights = 1), population, person_count = config$n_person
    )
    mu <- if (isTRUE(basis$transformed)) basis$mu else rep(0, config$n_person)
    sigma <- if (isTRUE(basis$transformed)) basis$sigma else 1
    value <- 0
    gradient <- numeric(p)
    for (i in seq_along(groups)) {
      person <- person_ids[i]
      rows <- groups[[i]]
      local_idx <- list(person = rep(1L, length(rows)), score_k = idx$score_k[rows],
        weight = weights[rows], step_idx = idx$step_idx[rows], slope_idx = idx$slope_idx[rows])
      slope <- if (identical(config$model, "GPCM")) params$slopes[local_idx$slope_idx] else
        rep(1, length(rows))
      evaluate <- mfrmr_adaptive_person_kernel(
        local_idx, config, params, base[rows], mu[person], sigma
      )
      location <- mfrmr_adaptive_posterior_location(evaluate)
      mode <- location$mode
      at_mode <- evaluate(mode, include_linear_part = TRUE)
      scale <- location$scale
      mean_derivative <- variance_derivative <- numeric(p)
      if (length(slices$beta)) {
        mean_derivative[slices$beta] <-
          population$design_matrix[population$person_lookup[person], ]
      }
      if (length(slices$log_sigma2)) variance_derivative[slices$log_sigma2] <- 1
      # Projects category-logit derivatives into the optimizer's actual free
      # coordinates, including anchored steps and signed facet interactions.
      project <- function(coefficient, linear) {
        answer <- as.numeric(Matrix::crossprod(designs[[i]]$cumulative,
          as.vector(coefficient[, -1L, drop = FALSE] * slope)))
        if (length(slices$log_slopes)) {
          answer <- answer + as.numeric(Matrix::crossprod(designs[[i]]$log_slope,
            rowSums(coefficient * linear) * slope))
        }
        answer
      }
      probability <- at_mode$prob_list[[1L]]
      expected <- as.vector(probability %*% categories)
      centered <- rep(categories, each = length(rows)) - expected
      variance <- rowSums(probability * centered^2)
      w <- local_idx$weight
      linear <- at_mode$linear_part_list[[1L]]
      # In physical theta coordinates: dm = h_theta,psi/H and
      # d log(s) = -(H_psi + H_theta dm)/(2H), H = -h_theta,theta.
      mixed <- -project(probability * centered * (w * slope), linear) +
        as.numeric(Matrix::crossprod(designs[[i]]$log_slope,
          w * slope * (local_idx$score_k - expected))) +
        mean_derivative / sigma^2 + mode / sigma * variance_derivative
      curvature_derivative <- project(
        probability * (centered^2 - variance) * (w * slope^2), linear
      ) + as.numeric(Matrix::crossprod(designs[[i]]$log_slope, 2 * w * slope^2 * variance)) -
        variance_derivative / sigma^2
      curvature_theta <- sum(w * slope^3 * rowSums(probability * centered^3))
      curvature <- at_mode$information / sigma^2
      mode_derivative <- mixed / curvature
      log_scale_derivative <- -(curvature_derivative + curvature_theta * mode_derivative) /
        (2 * curvature)
      z <- mode + scale * rule$nodes
      nodes <- evaluate(z, include_linear_part = TRUE)
      joint <- log(rule$weights) + nodes$log_likelihood + stats::dnorm(z, log = TRUE) -
        stats::dnorm(rule$nodes, log = TRUE) + log(scale)
      if (any(!is.finite(joint))) stop("Non-finite integration terms.", call. = FALSE)
      normalizer <- logsumexp(joint)
      posterior <- exp(joint - normalizer)
      value <- value - normalizer
      for (q in seq_along(rule$nodes)) {
        residual <- -nodes$prob_list[[q]]
        observed <- cbind(seq_along(rows), local_idx$score_k + 1L)
        residual[observed] <- residual[observed] + 1
        fixed_derivative <- project(residual * w, nodes$linear_part_list[[q]]) +
          z[q] / sigma * mean_derivative + (z[q]^2 - 1) / 2 * variance_derivative
        node_derivative <- mode_derivative + sigma * scale * rule$nodes[q] * log_scale_derivative
        gradient <- gradient - posterior[q] * (fixed_derivative +
          nodes$score[q] / sigma * node_derivative + log_scale_derivative)
      }
    }
    if (!is.finite(value) || any(!is.finite(gradient))) {
      stop("Non-finite adaptive MML objective or gradient.", call. = FALSE)
    }
    list(value = value, gradient = gradient)
  }
}
