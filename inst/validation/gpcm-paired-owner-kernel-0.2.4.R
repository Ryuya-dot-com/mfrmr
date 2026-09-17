# Repository-only deterministic audit; run from the development root:
# pkgload::load_all(); source("inst/validation/gpcm-paired-owner-kernel-0.2.4.R")
# run_gpcm_paired_owner_kernel("/tmp/mfrmr-gpcm-kernel-20260915/results")
# statmod is an already-installed validation dependency, not a package import.

gpk_data <- function(design) {
  d <- expand.grid(Person = sprintf("P%02d", 1:12), Rater = paste0("R", 1:4),
                   Criterion = paste0("C", 1:4), stringsAsFactors = FALSE)
  p <- match(d$Person, sprintf("P%02d", 1:12))
  r <- match(d$Rater, paste0("R", 1:4))
  c <- match(d$Criterion, paste0("C", 1:4))
  d$Score <- (p + 2*r + c) %% 5L
  d$Weight <- 1
  if (design == "cycle") d <- d[c == r | c == r %% 4L + 1L, ]
  if (design == "weak_bridge_weighted") {
    d$Weight <- rep(c(.25, 1, 3, 8), length.out = nrow(d))
    d$Score <- ifelse((p + r + c) %% 3L != 0L, 0L, (2*p + r + c) %% 4L + 1L)
    d <- d[(r <= 2L) == (c <= 2L) | (p == 1L & r == 2L & c == 3L), ]
    d <- d[order(seq_len(nrow(d)) * 37L %% 101L), ]
  }
  rownames(d) <- NULL
  d
}

# Independent, deliberately fixed layout: 12 free Persons for JML, sum-zero
# four-level facets, four row-centered four-transition blocks, GM-one slopes,
# and (for MML) an intercept and log population variance. No production
# expansion, indexing, probability, population or marginalization helper.
gpk_unpack <- function(par, method, owner, support) {
  take <- function(n) {
    value <- head(par, n)
    par <<- tail(par, -n)
    value
  }
  theta <- if (method == "JML") take(12L) else NULL
  zero <- function(x) support$mfrmr_gsap_sum_zero_expand(x, length(x) + 1L)
  facets <- list(Rater = zero(take(3L)), Criterion = zero(take(3L)))
  steps <- t(vapply(1:4, function(i) zero(take(3L)), numeric(4)))
  slopes <- exp(zero(take(3L)))
  if (method == "MML") {
    mean <- take(1L)
    sd <- exp(take(1L) / 2)
  } else mean <- sd <- NA_real_
  stopifnot(length(par) == 0L)
  other <- setdiff(names(facets), owner)
  parameters <- support$mfrmr_gsap_parameters(
    slopes, facets[[other]], sweep(steps, 1L, facets[[owner]], "+")
  )
  list(parameters = parameters, theta = theta, mean = mean, sd = sd)
}

gpk_oracle <- function(par, method, owner, data, quad, support,
                       action = "complete_predictor", details = FALSE) {
  x <- gpk_unpack(par, method, owner, support)
  theta <- if (method == "JML") x$theta else x$mean + x$sd * quad$nodes
  # Reuse the pre-existing independent adjacent-logit kernel. Normalize in
  # log space so a zero representable probability does not erase its log.
  adjacent <- support$mfrmr_gsap_adjacent_logits(theta, x$parameters, action)
  kernel <- cbind(0, t(apply(adjacent, 1L, cumsum)))
  shifted <- kernel - apply(kernel, 1L, max)
  log_probability <- shifted - log(rowSums(exp(shifted)))
  other <- setdiff(c("Rater", "Criterion"), owner)
  owner_index <- match(data[[owner]], paste0(substr(owner, 1, 1), 1:4))
  other_index <- match(data[[other]], paste0(substr(other, 1, 1), 1:4))
  person <- match(data$Person, sprintf("P%02d", 1:12))
  offset <- length(theta) * (other_index - 1L + 4L * (owner_index - 1L))
  rows <- if (method == "JML") matrix(offset + person, ncol = 1L) else
    outer(offset, seq_along(theta), "+")
  observed <- matrix(log_probability[cbind(as.vector(rows), data$Score + 1L)],
                     nrow = nrow(data)) * data$Weight
  if (method == "JML") value <- -sum(observed) else {
    joint <- sweep(rowsum(observed, person), 2L, log(quad$weights), "+")
    peak <- apply(joint, 1L, max)
    value <- -sum(peak + log(rowSums(exp(joint - peak))))
  }
  if (!details) return(value)
  list(value = value, observed = observed,
       probs = lapply(seq_len(ncol(rows)), function(i)
         exp(log_probability[rows[, i], , drop = FALSE])))
}

run_gpcm_paired_owner_kernel <- function(output_dir) {
  stopifnot(requireNamespace("statmod", quietly = TRUE))
  support <- new.env(parent = globalenv())
  for (file in c("gpcm-slope-action-projection-p3a-0.2.3.R",
                 "numerical-stationarity-pilot-0.2.3.R")) {
    sys.source(file.path("inst", "validation", file), support)
  }
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  write <- function(x, name) write.csv(x, file.path(output_dir, paste0(name, ".csv")),
                                      row.names = FALSE)
  # Numerical tolerances set before the initial probe; all difference widths
  # are retained. The initial probe motivated Richardson extrapolation below.
  limits <- c(probability = 1e-11, log_probability = 1e-9, objective = 1e-8,
              gradient_scaled = 1e-6, cache_gradient = 1e-10)
  write(data.frame(Metric = names(limits), Limit = limits), "limits")
  orders <- c(31L, 61L, 121L)
  quadrature <- lapply(orders, function(q) {
    rule <- statmod::gauss.quad.prob(q, "normal")
    # Production nodes are descending; align coordinates before comparing
    # probabilities. Node permutation leaves either marginal NLL unchanged.
    order <- order(rule$nodes, decreasing = TRUE)
    list(nodes = rule$nodes[order], weights = rule$weights[order])
  })
  names(quadrature) <- orders
  rules <- do.call(rbind, lapply(orders, function(q) {
    native <- mfrmr:::gauss_hermite_normal(q)
    ref <- quadrature[[as.character(q)]]
    data.frame(Q = q, NativeZeroWeights = sum(native$weights == 0),
               ReferenceZeroWeights = sum(ref$weights == 0),
               MinimumNativeWeight = min(native$weights),
               NodeDifference = max(abs(native$nodes - ref$nodes)),
               RelativeWeightDifference = max(abs(native$weights / ref$weights - 1)))
  }))
  write(rules, "quadrature")
  rows <- gradients <- inputs <- contexts <- conditions <- list()
  for (design in c("complete", "cycle", "weak_bridge_weighted")) {
    data <- gpk_data(design)
    inputs[[design]] <- cbind(Design = design, data)
    for (method in c("JML", "MML")) for (owner in c("Criterion", "Rater")) {
      key <- paste(design, method, owner, sep = "/")
      cat(key, "\n")
      messages <- character()
      # One iteration obtains the public preparation/configuration contract.
      # Its output estimates are never used as a convergence/recovery result.
      fit <- withCallingHandlers(mfrmr::fit_mfrm(
        data, "Person", c("Rater", "Criterion"), "Score", weight = "Weight",
        model = "GPCM", method = method, step_facet = owner, slope_facet = owner,
        rating_min = 0, rating_max = 4, maxit = 1L
      ), warning = function(w) {
        messages <<- c(messages, conditionMessage(w)); invokeRestart("muffleWarning")
      }, message = function(m) {
        messages <<- c(messages, conditionMessage(m)); invokeRestart("muffleMessage")
      })
      config <- fit$config
      sizes <- mfrmr:::build_param_sizes(config)
      expected <- c(theta = if (method == "JML") 12L else 0L,
                    Rater = 3L, Criterion = 3L, steps = 12L, log_slopes = 3L)
      if (method == "MML") expected <- c(expected, beta = 1L, log_sigma2 = 1L)
      stopifnot(identical(names(sizes), names(expected)),
                all(unlist(sizes) == expected), config$step_facet == owner,
                config$slope_facet == owner,
                all(as.character(fit$prep$data$Person) == data$Person),
                all(fit$prep$data$Score == data$Score))
      idx <- mfrmr:::build_indices(fit$prep, owner, owner)
      contexts[[key]] <- list(config = config, sizes = sizes, idx = idx)
      conditions[[key]] <- data.frame(Case = key, Conditions = paste(messages, collapse = " | "))
      for (point in c("moderate", "wide_slopes")) {
        par <- c(if (method == "JML") seq(-1.4, 1.7, length.out = 12L),
                 -.55, -.15, .25, -.4, .1, .45,
                 -1.2, -.35, .45, -.9, -.2, .35,
                 -1.05, .15, .4, -.7, -.3, .6,
                 if (point == "moderate") c(-.45, -.1, .2) else c(-3, -1, 1),
                 if (method == "MML") c(.35, log(1.3^2)))
        for (q in if (method == "JML") 0L else orders) {
          label <- paste(key, point, q, sep = "/")
          quad <- if (q == 0L) NULL else mfrmr:::gauss_hermite_normal(q)
          ref_quad <- if (q == 0L) NULL else quadrature[[as.character(q)]]
          oracle <- function(v) gpk_oracle(v, method, owner, data, ref_quad, support)
          ref <- gpk_oracle(par, method, owner, data, ref_quad, support, details = TRUE)
          cache <- mfrmr:::make_param_cache(sizes, config, idx, is_mml = method == "MML")
          evaluator <- mfrmr:::make_mfrm_direct_evaluator(method, cache, idx, config, sizes, quad)
          params <- mfrmr:::expand_params(par, sizes, config)
          if (method == "JML") {
            value <- mfrmr:::mfrm_loglik_jml(par, idx, config, sizes)
            gradient <- mfrmr:::mfrm_grad_jml(par, idx, config, sizes)
            b <- mfrmr:::mfrm_jml_probability_bundle(
              mfrmr:::compute_eta(idx, params, config), idx$score_k, "GPCM",
              t(apply(params$steps_mat, 1L, function(x) c(0, cumsum(x)))),
              idx$step_idx, params$slopes, idx$slope_idx)
            probs <- list(b$probs)
            observed <- matrix(b$log_prob_obs * idx$weight, ncol = 1L)
          } else {
            value <- mfrmr:::mfrm_loglik_mml(par, idx, config, sizes, quad)
            gradient <- mfrmr:::mfrm_grad_mml(par, idx, config, sizes, quad)
            b <- mfrmr:::mfrm_mml_logprob_bundle(idx, config, quad, params,
              mfrmr:::compute_base_eta(idx, params, config), include_probs = TRUE)
            probs <- b$prob_list
            observed <- b$log_prob_mat
          }
          stopifnot(identical(dim(observed), dim(ref$observed)),
                    length(probs) == length(ref$probs),
                    all(vapply(seq_along(probs), function(i)
                      identical(dim(probs[[i]]), dim(ref$probs[[i]])), TRUE)))
          numeric_gradients <- list()
          for (h in c(3e-5, 1e-5, 3e-6)) {
            numeric_gradient <- support$mfrmr_num_central_gradient(oracle, par, h)
            numeric_gradients[[as.character(h)]] <- numeric_gradient
            difference <- abs(gradient - numeric_gradient)
            scaled <- difference / pmax(1, abs(gradient), abs(numeric_gradient))
            gradients[[paste(label, h)]] <- data.frame(
              Case = label, Step = h, Coordinate = seq_along(par),
              Block = rep(names(sizes), unlist(sizes)), Parameter = par,
              Analytic = gradient, IndependentNumeric = numeric_gradient,
              AbsoluteDifference = difference, ScaledDifference = scaled)
            if (h == 1e-5) primary <- max(scaled)
          }
          # Cancel the O(h^2) central-difference term using the existing 3h/h
          # evaluations. Keep the failed primary probe, rather than relabeling
          # the smallest observed difference as the original acceptance rule.
          richardson <- (9 * numeric_gradients[["1e-05"]] -
                            numeric_gradients[["3e-05"]]) / 8
          richardson_scaled <- max(abs(gradient - richardson) /
                                    pmax(1, abs(gradient), abs(richardson)))
          fine_scaled <- max(abs(gradient - numeric_gradients[["3e-06"]]) /
            pmax(1, abs(gradient), abs(numeric_gradients[["3e-06"]])))
          wrong <- gpk_oracle(par, method, owner, data, ref_quad, support,
                              action = "loading_only", details = TRUE)
          rows[[label]] <- data.frame(
            Case = label, Design = design, Method = method, Owner = owner,
            Point = point, Q = q, Nobs = nrow(data), WeightedN = sum(data$Weight),
            NativeNLL = value, ReferenceNLL = ref$value,
            ObjectiveDifference = abs(value - ref$value),
            ProbabilityDifference = max(abs(unlist(probs) - unlist(ref$probs))),
            LogProbabilityDifference = max(abs(observed - ref$observed)),
            PrimaryScaledGradientDifference = primary,
            RichardsonScaledGradientDifference = richardson_scaled,
            FineScaledGradientDifference = fine_scaled,
            CachedObjectiveDifference = abs(evaluator$value(par) - ref$value),
            CachedGradientDifference = max(abs(evaluator$gradient(par) - gradient)),
            WrongActionProbabilityDifference = max(abs(unlist(ref$probs) - unlist(wrong$probs))))
          write(do.call(rbind, rows), "cases")
        }
      }
    }
  }
  result <- do.call(rbind, rows)
  ladder <- reshape(result[result$Method == "MML",
    c("Design", "Owner", "Point", "Q", "NativeNLL", "ReferenceNLL")],
    idvar = c("Design", "Owner", "Point"), timevar = "Q", direction = "wide")
  ladder$NativeChange31to61 <- ladder$NativeNLL.61 - ladder$NativeNLL.31
  ladder$NativeChange61to121 <- ladder$NativeNLL.121 - ladder$NativeNLL.61
  ladder$ReferenceChange31to61 <- ladder$ReferenceNLL.61 - ladder$ReferenceNLL.31
  ladder$ReferenceChange61to121 <- ladder$ReferenceNLL.121 - ladder$ReferenceNLL.61
  write(ladder, "integration-ladder")
  write(do.call(rbind, gradients), "gradients")
  write(do.call(rbind, inputs), "inputs")
  write(do.call(rbind, conditions), "setup-conditions")
  saveRDS(contexts, file.path(output_dir, "contexts.rds"))
  capture.output(sessionInfo(), file = file.path(output_dir, "session-info.txt"))
  # One runnable regression check; every planned case and every gradient
  # coordinate remains in the evidence, including the nonprimary step sizes.
  stopifnot(nrow(result) == 48L,
    all(rules$NativeZeroWeights == 0L & rules$ReferenceZeroWeights == 0L),
    all(result$ProbabilityDifference <= limits["probability"]),
    all(result$LogProbabilityDifference <= limits["log_probability"]),
    all(result$ObjectiveDifference <= limits["objective"]),
    all(result$CachedObjectiveDifference <= limits["objective"]),
    all(result$CachedGradientDifference <= limits["cache_gradient"]),
    all(result$RichardsonScaledGradientDifference <= limits["gradient_scaled"]),
    all(result$FineScaledGradientDifference <= limits["gradient_scaled"]),
    all(result$WrongActionProbabilityDifference > 1e-3))
  invisible(result)
}
