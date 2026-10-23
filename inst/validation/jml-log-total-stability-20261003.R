# Research isolation of owner-total arithmetic. The running R50 study keeps its
# sealed package source and results. This candidate changes neither its equation
# nor its root/interval acceptance rules, and is not a public API change.
jml_log_total_table <- function(design, exposure, log_probability) {
  nc <- length(exposure); K <- length(design$categories)
  lapply(seq_len(design$owners), function(g) {
    log_mass <- 0; counts <- matrix(0, 1L, nc * K)
    for (j in which(design$owner == g)) for (repeat_id in seq_len(exposure[j])) {
      w <- as.numeric(log_probability(0, j)); M <- length(log_mass)
      if (any(!is.finite(w))) stop("Nonfinite category log probabilities.")
      next_log <- rep(-Inf, M + K - 1L)
      next_counts <- matrix(0, M + K - 1L, nc * K)
      for (k in seq_len(K)) {
        rows <- seq_len(M) + k - 1L; column <- K * (j - 1L) + k
        old <- next_log[rows]; added <- log_mass + w[k]
        combined <- pmax(old, added) + log1p(exp(-abs(old - added)))
        contribution <- counts; contribution[, column] <- contribution[, column] + 1
        next_counts[rows, ] <- exp(old - combined) * next_counts[rows, , drop = FALSE] +
          exp(added - combined) * contribution
        next_log[rows] <- combined
      }
      log_mass <- next_log; counts <- next_counts
    }
    if (any(!is.finite(log_mass)) || any(!is.finite(counts)))
      stop("Nonfinite owner-total log mass or conditional counts.")
    list(log_probability = log_mass, counts = counts)
  })
}

jml_log_total_environment <- function() {
  # Reuse the complete existing equation. Only the convolution block and its
  # log-mass accessor are substituted in a private environment; never assign
  # into the package namespace or modify a sealed source file.
  path <- 'R/core-jml-adjustment.R'; code <- readLines(path)
  begin <- which(code == '    # Positive forward convolution; no subtraction or probability pruning.')
  end <- which(code == '    expected_score <- function(theta) {')
  access <- '          z <- outer(0:maximum[g], ag[g] * theta[ii]) + log(table[[g]]$probability)'
  stopifnot(length(begin) == 1L, length(end) == 1L, end > begin, sum(code == access) == 1L)
  code[code == access] <- '          z <- outer(0:maximum[g], ag[g] * theta[ii]) + table[[g]]$log_probability'
  code <- c(head(code, begin - 1L),
    '    table <- jml_log_total_table(design, exposure, log_probability)',
    code[end:length(code)])
  env <- new.env(parent = asNamespace('mfrmr'))
  env$jml_log_total_table <- jml_log_total_table
  eval(parse(text = code), env)
  env
}

jml_log_total_saved_problem <- function(fit, constructor) {
  s <- fit$jml_adjustment$specification
  do.call(constructor, c(list(data = fit$prep$data),
    s[c('person', 'facets', 'score', 'owner', 'rating_max', 'max_states')]))
}

# Independent, small-design oracle: enumerate ordered responses within each
# owner; do not use either convolution recurrence. Used only for validation.
jml_literal_total_table <- function(design, exposure, log_probability) {
  nc <- length(exposure); K <- length(design$categories)
  lapply(seq_len(design$owners), function(g) {
    cells <- which(design$owner == g)
    cells <- rep(cells, exposure[cells])
    if (!length(cells)) return(list(log_probability = 0, counts = matrix(0, 1L, nc*K)))
    stopifnot(length(cells)*log(K) <= log(1e5))
    y <- as.matrix(expand.grid(rep(list(design$categories), length(cells))))
    log_weight <- numeric(nrow(y)); counts <- matrix(0, nrow(y), nc*K)
    for (j in seq_along(cells)) {
      log_weight <- log_weight + as.numeric(log_probability(0, cells[j]))[y[, j]+1L]
      ix <- cbind(seq_len(nrow(y)), K*(cells[j]-1L)+y[, j]+1L)
      counts[ix] <- counts[ix]+1
    }
    totals <- rowSums(y); log_mass <- numeric(max(totals)+1L)
    expected <- matrix(0, length(log_mass), nc*K)
    for (s in 0:max(totals)) {
      rows <- which(totals == s); m <- max(log_weight[rows]); w <- exp(log_weight[rows]-m)
      log_mass[s+1L] <- m+log(sum(w))
      expected[s+1L, ] <- colSums(w*counts[rows, , drop = FALSE])/sum(w)
    }
    list(log_probability = log_mass, counts = expected)
  })
}

jml_log_total_check <- function(root, out) {
  pkgload::load_all(quiet = TRUE, compile = FALSE)
  manifest <- readRDS(file.path(root, 'manifest.rds'))$payload
  stopifnot(identical(manifest$source, tools::md5sum(names(manifest$source))))
  env <- jml_log_total_environment(); evidence <- list()
  oracle <- jml_log_total_environment(); oracle$jml_log_total_table <- jml_literal_total_table
  reference <- 'tests/testthat/fixtures/jml-adjustment-reference.rds'
  general <- 'tests/testthat/fixtures/jml-adjustment-general.rds'
  errors <- list()
  for (x in readRDS(reference)) {
    p <- env$mfrm_jml_adjustment_problem(x$data, 'Person', c('Rater', 'Criterion'), 'Score', x$owner, 2L)
    errors[[length(errors) + 1L]] <- vapply(seq_along(x$orders), function(i) {
      z <- p$evaluate(x$beta, x$orders[i])
      stopifnot(max(abs(z$q - x$q)) < 1e-9,
        all(z$value[!is.finite(z$theta), , drop = FALSE] == 0))
      max(abs(z$value - x$scores[[i]]))
    }, 0)
  }
  stopifnot(max(unlist(errors)) < 1e-8)
  evidence$full_pattern_reference_score_errors <- errors
  cat('Frozen full-pattern references passed; max error', max(unlist(errors)), '\n')
  x <- readRDS(general)
  p <- do.call(env$mfrm_jml_adjustment_problem, x[c('data', 'person', 'facets', 'score', 'owner', 'rating_max')])
  evidence$saved_covariance_errors <- sapply(c(2L, 4L), function(k) {
    z <- x$results[[as.character(k)]]
    V <- env$mfrm_jml_adjustment_covariance(p, z$beta, k)
    max(abs(V$vcov - z$covariance$vcov))
  })
  stopifnot(max(evidence$saved_covariance_errors) < 1e-10)
  cat('Saved full-Jacobian covariance checks passed\n')
  # Closed-form independent oracle: two exchangeable binary cells, with two
  # and three ratings. Conditional on total s, their expected successes are
  # 2s/5 and 3s/5, even when each success probability underflows at theta = 0.
  design <- list(categories = 0:1, owners = 2L, owner = c(1L, 1L))
  lp <- function(theta, j) c(-log1p(exp(-1000)), -1000 - log1p(exp(-1000)))
  z <- jml_log_total_table(design, c(2L, 3L), lp)
  s <- 0:5
  expected_log <- lchoose(5, s) - 1000 * s - 5 * log1p(exp(-1000))
  expected_counts <- cbind(2 - 2*s/5, 2*s/5, 3 - 3*s/5, 3*s/5)
  evidence$extreme_binomial_errors <- c(log_mass = max(abs(z[[1]]$log_probability - expected_log)),
    counts = max(abs(z[[1]]$counts - expected_counts)))
  stopifnot(max(evidence$extreme_binomial_errors) < 1e-10,
    identical(z[[2]]$log_probability, 0), all(z[[2]]$counts == 0))
  cat('Extreme closed-form binomial and absent-owner checks passed\n')
  # Same fixed coordinates on the actual five refused corrected fits. These
  # are equation evaluations, not a new simulation or a structural refit.
  jobs <- c('job-03647', 'job-03783', 'job-03784', 'job-03791', 'job-03792')
  paths <- file.path(root, jobs, 'calibration/q0-fit.rds')
  evidence$saved_cases <- lapply(seq_along(paths), function(i) {
    fit <- readRDS(paths[i])$payload$value; a <- fit$jml_adjustment
    old <- jml_log_total_saved_problem(fit, mfrmr:::mfrm_jml_adjustment_problem)
    candidate <- jml_log_total_saved_problem(fit, env$mfrm_jml_adjustment_problem)
    literal <- jml_log_total_saved_problem(fit, oracle$mfrm_jml_adjustment_problem)
    beta <- c(list(accepted = a$point$beta), setNames(lapply(a$attempts, `[[`, 'beta'),
      paste0('attempt_', seq_along(a$attempts))))
    beta <- beta[!vapply(beta, is.null, TRUE)]
    rows <- lapply(names(beta), function(label) {
      b <- beta[[label]]
      x <- old$evaluate(b, a$estimator$order); y <- candidate$evaluate(b, a$estimator$order)
      z <- literal$evaluate(b, a$estimator$order)
      error <- max(abs(x$value-y$value))
      oracle_error <- max(abs(z$value-y$value))
      stopifnot(oracle_error < 1e-9 * max(1, max(abs(z$value))),
        identical(x$theta, y$theta), identical(x$q, y$q))
      if (label == 'accepted') stopifnot(error < 1e-9)
      data.frame(Job = jobs[i], Coordinate = label, ScoreDifference = error,
        LiteralDifference = oracle_error, OldResidual = max(abs(colMeans(x$value))),
        CandidateResidual = max(abs(colMeans(y$value))))
    })
    do.call(rbind, rows)
  })
  evidence$saved_cases <- do.call(rbind, evidence$saved_cases)
  stopifnot(identical(manifest$source, tools::md5sum(names(manifest$source))))
  evidence$source <- tools::md5sum(c('inst/validation/jml-log-total-stability-20261003.R',
    names(manifest$source), reference, general, paths))
  evidence$interpretation <- 'Fixed-coordinate arithmetic validation; no new data, no refits, no truth-coverage or multiple-start qualification.'
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  saveRDS(evidence, file.path(out, 'arithmetic-check.rds'))
  print(evidence$saved_cases)
  invisible(evidence)
}

jml_log_total_capture <- function(root, out, job = 'job-03647') {
  # Replay only the first failed solver stage, with its exact saved settings,
  # to retain the trial vector discarded by the original exception handler.
  # Stop at that same exception. This does not continue a candidate root search.
  pkgload::load_all(quiet = TRUE, compile = FALSE)
  manifest <- readRDS(file.path(root, 'manifest.rds'))$payload
  stopifnot(identical(manifest$source, tools::md5sum(names(manifest$source))))
  path <- file.path(root, job, 'calibration/q0-fit.rds')
  fit <- readRDS(path)$payload$value; a <- fit$jml_adjustment
  first <- a$attempts[[1L]]; policy <- a$policy
  stopifnot(grepl('Underflow in owner-total probabilities', first$error, fixed = TRUE),
    policy$solver_version == as.character(packageVersion('nleqslv')))
  old <- jml_log_total_saved_problem(fit, mfrmr:::mfrm_jml_adjustment_problem)
  captured <- NULL; evaluations <- 0L
  fn <- function(b) {
    evaluations <<- evaluations + 1L
    tryCatch(old$mean_score(b, a$estimator$order), error = function(e) {
      captured <<- list(beta = b, error = conditionMessage(e), evaluation = evaluations)
      stop(e)
    })
  }
  stage <- first$settings
  result <- tryCatch(nleqslv::nleqslv(policy$starts[[first$start]], fn,
    method = stage$method, global = stage$global,
    control = list(maxit = policy$maxit, ftol = policy$ftol, xtol = policy$xtol,
      stepmax = stage$stepmax, allowSingular = FALSE)), error = function(e) conditionMessage(e))
  stopifnot(!is.null(captured), identical(captured$error, first$error))
  env <- jml_log_total_environment()
  candidate <- jml_log_total_saved_problem(fit, env$mfrm_jml_adjustment_problem)
  captured$candidate <- tryCatch(candidate$evaluate(captured$beta, a$estimator$order),
    error = function(e) list(error = conditionMessage(e)))
  oracle <- jml_log_total_environment(); oracle$jml_log_total_table <- jml_literal_total_table
  literal <- jml_log_total_saved_problem(fit, oracle$mfrm_jml_adjustment_problem)
  captured$literal <- tryCatch(literal$evaluate(captured$beta, a$estimator$order),
    error = function(e) list(error = conditionMessage(e)))
  if (is.null(captured$candidate$error) && is.null(captured$literal$error)) {
    captured$literal_difference <- max(abs(captured$candidate$value-captured$literal$value))
    stopifnot(captured$literal_difference < 1e-9*max(1, max(abs(captured$literal$value))))
  }
  captured$job <- job; captured$order <- a$estimator$order; captured$policy <- policy
  captured$original_result <- result
  captured$source <- tools::md5sum(c('inst/validation/jml-log-total-stability-20261003.R',
    names(manifest$source), path))
  stopifnot(identical(manifest$source, tools::md5sum(names(manifest$source))))
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  saveRDS(captured, file.path(out, paste0(job, '-captured-trial.rds')))
  print(list(job = job, evaluation = captured$evaluation, old_error = captured$error,
    candidate_error = captured$candidate$error,
    literal_difference = captured$literal_difference,
    candidate_residual = if (is.null(captured$candidate$error)) max(abs(colMeans(captured$candidate$value))) else NA_real_))
  invisible(captured)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(TRUE)
  stopifnot(length(args) == 3L, args[1] %in% c('check', 'capture'))
  if (args[1] == 'check') jml_log_total_check(args[2], args[3]) else jml_log_total_capture(args[2], args[3])
}
