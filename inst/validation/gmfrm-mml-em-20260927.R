# Local algorithm verification, not a recovery/coverage study or public API.
# Run after pkgload::load_all(compile = FALSE).
run_gmfrm_em_validation <- function(out) {
  if (dir.exists(out)) stop("Refusing to overwrite validation output.")
  dir.create(out, recursive = TRUE)
  set.seed(20260927)
  d <- expand.grid(Person = sprintf("p%03d", 1:240), Task = paste0("t", 1:3), Rater = paste0("r", 1:3))
  theta <- rnorm(240)
  # Independent literal response equation for generation.
  b <- c(-.4, .1, .3); s <- c(-.25, .05, .3)
  a <- c(.85, 1.05, 1 / (.85 * 1.05)); c <- c(.85, 1, 1.1)
  steps <- rbind(c(-.7, .7), c(-.45, .45), c(-.6, .6))
  d$Score <- vapply(seq_len(nrow(d)), function(o) {
    i <- as.integer(d$Task[o]); r <- as.integer(d$Rater[o])
    z <- c(0, cumsum(a[i] * c[r] * (theta[as.integer(d$Person[o])] - b[i] - s[r] - steps[r, ])))
    sample(0:2, 1, prob = exp(z - max(z)))
  }, integer(1))
  results <- list()
  fits <- list()
  for (nq in c(31L, 61L)) {
    p <- mfrm_gmfrm_problem(d, 2L, gauss_hermite_normal(nq))
    started <- proc.time()[3]
    em <- mfrm_gmfrm_em(p)
    # Two independent starts for direct maximization, neither initialized at EM.
    direct <- lapply(list(p$start, p$start + seq(-.15, .15, length.out = length(p$start))), function(start)
      optim(start, function(v) p$marginal(v)$value, function(v) p$marginal(v)$gradient,
        method = "BFGS", control = list(reltol = 1e-13, maxit = 1000L)))
    information <- p$n_person * optimHess(em$par,
      function(v) p$marginal(v)$value, function(v) p$marginal(v)$gradient)
    results[[as.character(nq)]] <- data.frame(Nodes = nq, Persons = p$n_person,
      Ratings = nrow(d), EMConverged = em$converged, EMIterations = nrow(em$trace) - 1L,
      EMMaxMeanScore = em$max_score, EMLogLik = em$logLik,
      DirectConverged = all(vapply(direct, function(x) x$convergence == 0L, logical(1))),
      DirectMaxMeanScore = max(vapply(direct, function(x) max(abs(p$marginal(x$par)$gradient)), numeric(1))),
      MaxParameterDifference = max(vapply(direct, function(x) max(abs(x$par - em$par)), numeric(1))),
      MaxLogLikDifference = max(vapply(direct, function(x) abs(-x$value * p$n_person - em$logLik), numeric(1))),
      MinLikelihoodIncrement = min(diff(em$trace$logLik)),
      MinInformationEigenvalue = min(eigen(information, symmetric = TRUE)$values),
      ElapsedSeconds = unname(proc.time()[3] - started))
    fits[[as.character(nq)]] <- list(em = em, direct = direct, information = information)
    print(results[[as.character(nq)]], row.names = FALSE)
    saveRDS(list(data = d, results = results, fits = fits), file.path(out, "results.rds"))
  }
  summary <- do.call(rbind, results)
  write.csv(summary, file.path(out, "summary.csv"), row.names = FALSE)
  grid_change <- max(abs(fits[[1]]$em$par - fits[[2]]$em$par))
  cat("Maximum 31-to-61-node parameter change:", grid_change, "\n")
  # sirt's actual probability kernel: equality only in a declared overlap
  # (zero locations/steps). This is not agreement between free estimators.
  if (requireNamespace("sirt", quietly = TRUE)) {
    par <- p$start
    par[grepl("log_slope:Task", names(par))] <- log(a[1:2])
    par[grepl("log_slope:Rater", names(par))] <- log(c)
    u <- p$unpack(par)
    sirt_prob <- getFromNamespace("rm_facets_calcprobs", "sirt")(
      b.item = rep(0, 3), b.rater = rep(0, 3), Qmatrix = matrix(1:2, 3, 2, byrow = TRUE),
      tau.item = matrix(0, 3, 2), VV = 3L, K = 2L, I = nrow(p$cells), TP = length(p$nodes),
      a.item = unname(u$slopes$Task), a.rater = unname(u$slopes$Rater),
      item.index = p$cells$Task, rater.index = p$cells$Rater, theta.k = p$nodes, RR = 3L)
    sirt_prob <- matrix(aperm(sirt_prob, c(1, 3, 2)), nrow(p$cells) * length(p$nodes), 3)
    difference <- max(abs(sirt_prob - p$kernel(par)$prob))
    cat("sirt", as.character(packageVersion("sirt")), "zero-intercept overlap probability error:", difference, "\n")
    saveRDS(list(version = packageVersion("sirt"), difference = difference,
      grid_change = grid_change, session = sessionInfo()), file.path(out, "comparison.rds"))
    stopifnot(difference < 1e-12)
  }
  stopifnot(all(summary$EMConverged), all(summary$DirectConverged),
    all(summary$DirectMaxMeanScore < 1e-6), all(summary$MaxParameterDifference < 1e-4),
    all(summary$MaxLogLikDifference < 1e-6), all(summary$MinLikelihoodIncrement > -1e-8),
    all(summary$MinInformationEigenvalue > 0), grid_change < 1e-4)
  invisible(summary)
}

# Reuse the original simulated data/estimates to exercise common parameter
# management. One direct fit from zero, no new data or repeated recovery study.
run_gmfrm_common_validation <- function(saved_results) {
  saved <- readRDS(saved_results)
  rows <- lapply(c(31L, 61L), function(nq) {
    p <- mfrm_gmfrm_problem(saved$data, 2L, gauss_hermite_normal(nq))
    setup <- p$common
    ev <- make_mfrm_direct_evaluator("MML",
      make_param_cache(setup$sizes, setup$config, setup$idx, is_mml = TRUE),
      setup$idx, setup$config, setup$sizes, gauss_hermite_normal(nq))
    old <- saved$fits[[as.character(nq)]]$em
    row <- data.frame(Nodes = nq,
      SavedLogLikDifference = abs(-ev$value(old$par) - old$logLik),
      MarginalScoreDifference = max(abs(ev$gradient(old$par) / p$n_person - p$marginal(old$par)$gradient)),
      RoundtripDifference = max(abs(collapse_expanded_params(
        expand_params(old$par, setup$sizes, setup$config), setup$config) - old$par)),
      DirectConverged = NA, DirectMaxMeanScore = NA_real_,
      DirectParameterDifference = NA_real_, DirectLogLikDifference = NA_real_)
    if (nq == 61L) {
      fit <- optim(p$start, function(x) ev$value(x) / p$n_person,
        function(x) ev$gradient(x) / p$n_person, method = "BFGS",
        control = list(reltol = 1e-13, maxit = 1000L))
      row$DirectConverged <- fit$convergence == 0L
      row$DirectMaxMeanScore <- max(abs(ev$gradient(fit$par))) / p$n_person
      row$DirectParameterDifference <- max(abs(fit$par - old$par))
      row$DirectLogLikDifference <- abs(-ev$value(fit$par) - old$logLik)
      stopifnot(row$DirectConverged, row$DirectMaxMeanScore < 1e-6,
        row$DirectParameterDifference < 1e-4, row$DirectLogLikDifference < 1e-6)
    }
    stopifnot(row$SavedLogLikDifference < 1e-8, row$MarginalScoreDifference < 1e-10,
      row$RoundtripDifference < 1e-12)
    row
  })
  result <- do.call(rbind, rows)
  print(result, row.names = FALSE, digits = 10)
  invisible(result)
}
