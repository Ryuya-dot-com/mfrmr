# Bounded diagnostic pilot: exact derivative checks and four new paired datasets.
# One replicate per condition cannot estimate bias, coverage or method superiority.
# Rscript inst/validation/jml-normal-range-pilot-20261001.R OUTPUT_DIRECTORY
source('inst/validation/jml-observed-inference-20261001.R')
source('inst/validation/jml-exposure-expansion-20260930.R')

jml_range_components <- function(problem, beta) {
  z <- problem$evaluate(beta)
  P <- matrix(0, problem$n, problem$n)
  ix <- which(!problem$extreme)
  P[ix, ] <- t(problem$mass(beta, z$theta[ix]))
  ix <- which(problem$extreme)
  P[ix, ix] <- diag(length(ix))
  stopifnot(max(abs(rowSums(P) - 1)) < 1e-12, z$root_residual < 1e-8)
  list(P = P, U = z$gradient)
}

jml_range_recur <- function(z, dP = NULL, dU = NULL) {
  values <- list(`0` = z$U); derivatives <- frozen <- list()
  U <- z$U; D <- F <- dU
  for (k in 1:4) {
    if (!is.null(D)) {
      D <- D - z$P %*% D - dP %*% U
      F <- F - z$P %*% F
      derivatives[[as.character(k)]] <- D
      frozen[[as.character(k)]] <- F
    }
    U <- U - z$P %*% U
    values[[as.character(k)]] <- U
  }
  list(values = values, derivative = derivatives, frozen = frozen)
}

jml_range_derivatives <- function(design, truth, out, tolerance) {
  rows <- detail <- list()
  for (g in 1:2) {
    p <- make_jml_roster_problem('Criterion', design$exposure[[g]])
    data <- jml_observed_long(p$counts, expand.grid(Rater = 1:2, Criterion = 1:2))
    native <- mfrmr:::mfrm_jml_adjustment_problem(data, 'Person',
      c('Rater', 'Criterion'), 'Score', 'Criterion', 2L)
    for (where in c('truth', 'off_truth')) {
      beta <- truth + if (where == 'truth') 0 else c(.08, -.06, .05, -.04, .03)
      center <- jml_range_components(p, beta)
      z <- jml_range_recur(center)
      point_error <- max(vapply(c(0L, 2L, 4L), function(k)
        max(abs(z$values[[as.character(k)]] - native$evaluate(beta, k)$value)), 0))
      stopifnot(point_error < tolerance$point)
      # Generating probabilities are held at truth when evaluation beta changes.
      weights <- p$mass(truth, seq(-6, 6, by = 2))
      for (h in c(1e-4, 5e-5)) for (j in seq_along(beta)) {
        step <- numeric(5); step[j] <- h
        plus <- jml_range_components(p, beta + step)
        minus <- jml_range_components(p, beta - step)
        dz <- jml_range_recur(center, (plus$P - minus$P) / (2*h),
          (plus$U - minus$U) / (2*h))
        up <- jml_range_recur(plus)$values
        um <- jml_range_recur(minus)$values
        for (k in c(2L, 4L)) {
          key <- as.character(k)
          complete <- (native$evaluate(beta + step, k)$value -
            native$evaluate(beta - step, k)$value) / (2*h)
          reference <- (up[[key]] - um[[key]]) / (2*h)
          scale <- max(1, max(abs(complete)))
          errors <- c(FullReference = max(abs(complete - reference)) / scale,
            ProductRule = max(abs(complete - dz$derivative[[key]])) / scale)
          id <- paste(g, where, h, j, k, sep = '-')
          detail[[id]] <- list(complete = complete, reference = reference,
            product = dz$derivative[[key]], frozen = dz$frozen[[key]])
          rows[[id]] <- data.frame(Roster = g, At = where, Step = h,
            Direction = names(truth)[j], Order = k, PointError = point_error,
            ReferenceError = errors[1], ProductError = errors[2],
            FrozenTransitionDifference = max(abs(complete - dz$frozen[[key]])) / scale,
            MaximumConditionalMeanDifference = max(abs(crossprod(weights,
              complete - dz$frozen[[key]]))), row.names = NULL)
          # Preserve the witness before stopping on a numerical correctness failure.
          if (any(errors > tolerance$derivative)) {
            saveRDS(list(rows = rows, detail = detail), file.path(out, 'derivative-failure.rds'))
            stop('Independent derivative check exceeded the predeclared tolerance.')
          }
        }
      }
    }
  }
  rows <- do.call(rbind, rows)
  saveRDS(list(rows = rows, detail = detail), file.path(out, 'derivatives.rds'))
  write.csv(rows, file.path(out, 'derivatives.csv'), row.names = FALSE)
  rows
}

jml_range_expectations <- function(design, truth, out) {
  rows <- checks <- list()
  for (g in 1:2) for (L in c(1L, 2L, 4L, 8L)) {
    base <- design$exposure[[g]]; exposure <- base * L
    p <- make_jml_total_problem('Criterion', exposure,
      lapply(exposure, function(n) matrix(c(n, 0, 0), 1, 3)))
    for (k in c(0L, 2L, 4L)) {
      z <- p$scores(truth, k); U <- z$conditional_raw - z$adjustment
      stopifnot(z$root_residual < 1e-8, all(is.finite(U)),
        all(U[c(1, nrow(U)), ] == 0), z$max_omitted_mass == 0)
      for (theta in seq(-6, 6, by = 2)) {
        mass <- jml_total_mass(p, truth, theta)
        mean <- drop(crossprod(mass, U)) / L
        b1 <- jml_block_moments('Criterion', base, truth, theta)$b1
        id <- paste(g, L, k, theta, sep = '-')
        rows[[id]] <- data.frame(Roster = g, L = L, Ratings = sum(exposure),
          Ability = theta, Order = k, Parameter = names(truth),
          NormalizedMean = mean, ScaledMean = L^(k+1) * mean,
          RawLeadingCoefficient = if (k == 0L) b1 else NA_real_,
          RawRemainderScaled = if (k == 0L) L^2 * (mean - b1/L) else NA_real_,
          ExtremeMass = sum(mass[c(1, length(mass))]), row.names = NULL)
      }
      checks[[paste(g, L, k)]] <- c(states = p$total_states, residual = z$root_residual)
    }
  }
  rows <- do.call(rbind, rows)
  saveRDS(list(rows = rows, checks = checks), file.path(out, 'expectations.rds'))
  write.csv(rows, file.path(out, 'expectations.csv'), row.names = FALSE)
  rows
}

jml_range_generate <- function(job, design, truth) {
  set.seed(job$Seed)
  roster <- rep(1:2, job$N * design$proportions)
  theta <- rnorm(job$N, sd = job$SD)
  counts <- lapply(1:4, function(j) matrix(0L, job$N, 3))
  for (g in 1:2) {
    p <- make_jml_roster_problem('Criterion', design$exposure[[g]])
    ids <- which(roster == g); mass <- p$mass(truth, theta[ids])
    stopifnot(max(abs(colSums(mass) - 1)) < 1e-12)
    draw <- vapply(seq_along(ids), function(i) sample.int(p$n, 1, prob = mass[, i]), 1L)
    for (j in 1:4) counts[[j]][ids, ] <- p$counts[[j]][draw, , drop = FALSE]
  }
  data <- jml_observed_long(counts, expand.grid(Rater = 1:2, Criterion = 1:2))
  total <- Reduce(`+`, lapply(counts, function(x) drop(x %*% (0:2))))
  maximum <- vapply(roster, function(g) 2*sum(design$exposure[[g]]), 0)
  list(job = job, roster = roster, theta = theta, counts = counts, data = data,
    extremes = sum(total == 0 | total == maximum))
}

jml_range_reference <- function(input, design, result, k) {
  ps <- lapply(1:2, function(g) make_jml_total_problem('Criterion',
    design$exposure[[g]], lapply(input$counts, function(x)
      x[input$roster == g, , drop = FALSE])))
  N <- input$job$N
  eq <- make_jml_design_equation(ps, lapply(design$proportions,
    function(w) rep(1/(N*w), N*w)), design$proportions, k)
  beta <- result$point$beta; cv <- result$covariance$result
  A <- jml_sample_jacobian(eq$mean_score, beta, 5e-5)
  V <- jml_design_covariance(eq, beta, N, A, 'fixed_rosters')
  errors <- c(jacobian = max(abs(A - cv$jacobian)) / max(1, max(abs(A))),
    meat = max(abs(V$meat - cv$meat)),
    covariance = max(abs(V$vcov - cv$vcov)) / max(abs(V$vcov)),
    influence = max(abs(crossprod(cv$influence)/N^2 - cv$vcov)))
  list(errors = errors, passed = all(errors < 1e-7))
}

jml_range_fit <- function(input, k, truth, design, seconds_limit) {
  warnings <- character(); started <- proc.time()[['elapsed']]
  args <- list(data = input$data, person = 'Person', facets = c('Rater', 'Criterion'),
    score = 'Score', model = 'GPCM', method = 'JML', step_facet = 'Criterion',
    slope_facet = 'Criterion', rating_min = 0, rating_max = 2,
    category_policy = 'preserve', maxit = 400L)
  if (k == 0L) args$reltol <- 1e-9 else {
    args$jml_correction_order <- k
    args$jml_correction_sampling <- 'fixed_rosters'
  }
  setTimeLimit(cpu = Inf, elapsed = seconds_limit, transient = TRUE)
  fit <- tryCatch(withCallingHandlers(
    do.call(mfrmr::fit_mfrm, args),
    warning = function(w) {warnings <<- c(warnings, conditionMessage(w)); invokeRestart('muffleWarning')}),
    error = function(e) list(error = conditionMessage(e)),
    finally = setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE))
  seconds <- proc.time()[['elapsed']] - started
  row <- data.frame(input$job, Order = k, ExtremePersons = input$extremes,
    FitReturned = is.null(fit$error), PointAvailable = FALSE, Status = 'error',
    CovarianceAvailable = FALSE, CovarianceReason = '', EquationResidual = NA_real_,
    MaxAbsoluteError = NA_real_, LogSlopeError = NA_real_, ReferenceError = NA_real_,
    Seconds = seconds, WarningCount = length(warnings), Error = '', row.names = NULL)
  beta <- rep(NA_real_, 5); check <- NULL
  if (!is.null(fit$error)) row$Error <- fit$error else if (k == 0L) {
    f <- fit$facets$others; s <- fit$steps; a <- fit$slopes
    beta <- c(f$Estimate[f$Facet == 'Rater' & f$Level == '1'],
      f$Estimate[f$Facet == 'Criterion' & f$Level == '1'],
      s$Estimate[s$StepFacet == '1' & s$Step == 'Step_1'],
      s$Estimate[s$StepFacet == '2' & s$Step == 'Step_1'],
      a$LogEstimate[a$SlopeFacet == '1'])
    stopifnot(length(beta) == 5L)
    row$PointAvailable <- all(is.finite(beta))
    row$Status <- paste(fit$summary$ConvergenceSeverity[1],
      fit$readiness$fit$FitReadiness[1], sep = ':')
    row$CovarianceReason <- 'ordinary_public_structural_sampling_covariance_unavailable'
    # Profile the nuisance coordinates at the unchanged public structural point.
    check <- tryCatch({
      U <- matrix(0, input$job$N, 5)
      for (g in 1:2) {
        ix <- which(input$roster == g)
        p <- make_jml_total_problem('Criterion', design$exposure[[g]],
          lapply(input$counts, function(x) x[ix, , drop = FALSE]))
        U[ix, ] <- p$scores(beta, 0L)$value
      }
      list(profile_mean = colMeans(U),
        interpretation = 'Residual at public point; no structural reference refit or curvature error certificate.')
    }, error = function(e) list(error = conditionMessage(e)))
    if (is.null(check[['error', exact = TRUE]]))
      row$EquationResidual <- max(abs(check$profile_mean))
  } else {
    z <- fit$jml_adjustment
    row$PointAvailable <- isTRUE(z$point$available); row$Status <- z$point$status
    row$CovarianceAvailable <- isTRUE(z$covariance$available)
    row$CovarianceReason <- z$covariance$reason
    row$EquationResidual <- z$point$equation_residual
    if (row$PointAvailable) beta <- z$point$beta
    if (row$CovarianceAvailable) {
      check <- tryCatch(jml_range_reference(input, design, z, k),
        error = function(e) list(error = conditionMessage(e)))
      if (is.null(check[['error', exact = TRUE]])) row$ReferenceError <- max(check$errors)
    }
  }
  if (row$PointAvailable) {
    row$MaxAbsoluteError <- max(abs(beta - truth)); row$LogSlopeError <- beta[5] - truth[5]
  }
  list(row = row, beta = beta, fit = fit, warnings = warnings, reference = check)
}

jml_range_refit_saved <- function(out, complete = FALSE) {
  manifest <- readRDS(file.path(out, 'manifest.rds'))
  script <- 'inst/validation/jml-normal-range-pilot-20261001.R'
  current <- tools::md5sum(names(manifest$source_md5))
  stopifnot(identical(current[names(current) != script],
    manifest$source_md5[names(current) != script]))
  dest <- file.path(out, if (complete) 'saved-input-completion' else 'saved-input-refit')
  if (dir.exists(dest)) stop('Refusing to overwrite saved-input refit evidence.')
  dir.create(dest)
  stopifnot(file.copy(script, file.path(dest, basename(script))))
  saveRDS(list(source_md5 = current, input_md5 = tools::md5sum(
    file.path(out, paste0('input-', 1:4, '.rds'))),
    reason = if (complete) 'Preserve reference failures without aborting; reuse six saved fits; repair exact field lookup for reference errors.' else
      'Initial calls rejected before estimation: ordinary received correction-only sampling; corrected received reltol.',
    scope = 'Same four saved inputs; skip previously saved fits; no regeneration or repeated derivative/expectation grid.'),
    file.path(dest, 'manifest.rds'))
  rows <- list()
  for (i in 1:4) {
    input <- readRDS(file.path(out, paste0('input-', i, '.rds')))
    for (k in c(0L, 2L, 4L)) {
      id <- paste(i, k, sep = '-')
      previous <- file.path(out, 'saved-input-refit', paste0('fit-', id, '.rds'))
      reused <- complete && file.exists(previous)
      if (reused) z <- readRDS(previous) else {
        z <- jml_range_fit(input, k, manifest$truth, manifest$design, manifest$per_fit_seconds)
        saveRDS(z, file.path(dest, paste0('fit-', id, '.rds')))
      }
      if (!is.null(z$reference$errors)) z$row$ReferenceError <- max(z$reference$errors)
      z$row$ReusedSavedFit <- reused
      z$row$EvidenceFile <- if (reused) previous else file.path(dest, paste0('fit-', id, '.rds'))
      rows[[id]] <- z$row; print(z$row, row.names = FALSE); flush.console()
      write.csv(do.call(rbind, rows), file.path(dest, 'fits.csv'), row.names = FALSE)
    }
  }
  stopifnot(identical(tools::md5sum(names(current)), current))
  saveRDS(list(fits = do.call(rbind, rows), source_md5 = current), file.path(dest, 'completion.rds'))
}

run_jml_range_pilot <- function(out) {
  if (dir.exists(out)) stop('Refusing to overwrite or silently resume a pilot.')
  dir.create(out, recursive = TRUE)
  contract_file <- 'validation-results/jml-scope-challenge-20260927/contract.rds'
  design <- readRDS(contract_file)$designs$unequal
  truth <- c(Rater = .3, Criterion = -.4, Step1 = -.6, Step2 = -.9, LogSlope = .25)
  jobs <- expand.grid(N = c(40L, 120L), SD = c(1, 2)); jobs$Seed <- 98100100L + 1:4
  files <- unique(c('DESCRIPTION', list.files('R', pattern = '[.]R$', full.names = TRUE),
    contract_file, paste0('inst/validation/', c('jml-normal-range-pilot-20261001.R',
      'jml-observed-inference-20261001.R', 'jml-exposure-expansion-20260930.R',
      'jml-total-expectation-20260927.R', 'jml-design-adjustment-20260927.R',
      'jml-profile-bias-sample-20260927.R', 'jml-profile-bias-exact-20260927.R'))))
  manifest <- list(design = design, owner = 'Criterion', truth = truth, jobs = jobs,
    orders = c(0L, 2L, 4L), exposure = c(1L, 2L, 4L, 8L), ability = seq(-6, 6, by = 2),
    derivative_steps = c(1e-4, 5e-5), tolerance = list(point = 1e-8, derivative = 1e-6),
    per_fit_seconds = 60, cores = 1L, source_md5 = tools::md5sum(files),
    session = capture.output(sessionInfo()), rng = RNGkind(),
    interpretation = 'Numerical/availability pilot; four datasets, one per condition; no coverage estimate.',
    authorization = 'User requested small new estimation/simulation/numerical differentiation; paused studies remain paused.')
  saveRDS(manifest, file.path(out, 'manifest.rds'))
  for (file in files) {
    dest <- file.path(out, 'source', file); dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
    stopifnot(file.copy(file, dest))
  }
  cat('Derivative checks: two rosters, truth/off-truth, five directions, two steps, orders 2/4.\n'); flush.console()
  derivatives <- jml_range_derivatives(design, truth, out, manifest$tolerance)
  cat('Derivative checks complete. Exact expectation grid next.\n'); flush.console()
  expectations <- jml_range_expectations(design, truth, out)
  cat('Expectation grid complete. Four new inputs and twelve public fits next.\n'); flush.console()
  rows <- list()
  for (i in seq_len(nrow(jobs))) {
    input <- jml_range_generate(jobs[i, ], design, truth)
    saveRDS(input, file.path(out, paste0('input-', i, '.rds')))
    for (k in c(0L, 2L, 4L)) {
      z <- jml_range_fit(input, k, truth, design, manifest$per_fit_seconds)
      id <- paste(i, k, sep = '-'); saveRDS(z, file.path(out, paste0('fit-', id, '.rds')))
      rows[[id]] <- z$row; print(z$row, row.names = FALSE); flush.console()
      write.csv(do.call(rbind, rows), file.path(out, 'fits.csv'), row.names = FALSE)
    }
  }
  rows <- do.call(rbind, rows)
  stopifnot(identical(tools::md5sum(files), manifest$source_md5), nrow(rows) == 12L)
  saveRDS(list(derivative_rows = nrow(derivatives), expectation_rows = nrow(expectations),
    datasets = nrow(jobs), fits = rows, source_md5 = manifest$source_md5,
    derivative_maxima = vapply(derivatives[c('PointError', 'ReferenceError', 'ProductError')], max, 0)),
    file.path(out, 'completion.rds'))
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) == 2L && args[1] %in% c('refit-saved', 'complete-saved'))
    jml_range_refit_saved(args[2], complete = args[1] == 'complete-saved') else {
    stopifnot(length(args) == 1L); run_jml_range_pilot(args[1])
  }
}
