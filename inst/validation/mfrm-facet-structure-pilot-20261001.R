# Fixed-workload diagnostic pilot, not a repeated-sampling qualification.
# Rscript THIS_FILE prepare|fit|summary OUTPUT [JOB]
# Each fit runs in a separate process; the caller applies a 120-second limit.
pilot_script <- 'inst/validation/mfrm-facet-structure-pilot-20261001.R'
pkgload::load_all('.', quiet = TRUE, compile = FALSE, helpers = FALSE)

pilot_inputs <- function(N, seed) {
  RNGkind("L'Ecuyer-CMRG"); set.seed(seed)
  theta <- rnorm(N); person_order <- sample.int(N)
  uniforms <- array(runif(N * 8L), c(N, 2L, 2L, 2L))
  pairs3 <- rbind(c(1,2), c(2,3), c(3,1))
  pairs6 <- matrix(c(1,6,2,5,3,4,1,5,6,4,2,3,1,4,5,3,6,2,
    1,3,4,2,5,6,1,2,3,6,4,5), ncol = 2, byrow = TRUE)
  pairs4 <- rbind(c(1,2), c(2,3), c(3,4), c(4,1))
  cases <- c('base_two_facet', 'six_raters', 'null_task', 'two_tasks', 'four_tasks')
  result <- list()
  for (name in cases) {
    nr <- if (name == 'six_raters') 6L else 3L
    nt <- if (name == 'four_tasks') 4L else if (grepl('task', name)) 2L else 0L
    truth <- list(Rater = rep(c(-.3, 0, .3), nr/3), Criterion = c(-.4, .4),
      Task = if (name == 'null_task') c(0, 0) else rep(c(-.2, .2), nt/2),
      steps = rbind(c(-.6, .6), c(-.9, .9)), log_slopes = c(-.2, .2))
    rows <- vector('list', N * 8L); counter <- 0L
    for (slot in seq_len(N)) {
      i <- person_order[slot]
      rp <- if (nr == 6L) pairs6[(slot-1L) %% 15L+1L, ] else pairs3[(slot-1L) %% 3L+1L, ]
      tp <- if (nt == 4L) pairs4[(slot-1L) %% 4L+1L, ] else 1:2
      for (event in 1:2) for (r in 1:2) for (c in 1:2) {
        task <- tp[event]
        location <- truth$Rater[rp[r]] + truth$Criterion[c] +
          if (nt > 0L) truth$Task[task] else 0
        logits <- exp(truth$log_slopes[c]) *
          ((0:2) * (theta[i] - location) - c(0, cumsum(truth$steps[c, ])))
        mass <- exp(logits - max(logits)); mass <- mass / sum(mass)
        y <- sum(uniforms[i, event, r, c] > cumsum(mass))
        stopifnot(y %in% 0:2, abs(sum(mass)-1) < 1e-14)
        counter <- counter + 1L
        rows[[counter]] <- data.frame(Person = sprintf('P%03d', i),
          Rater = as.character(rp[r]), Criterion = as.character(c),
          Task = as.character(task), Event = event, Score = y)
      }
    }
    data <- do.call(rbind, rows)
    facets <- c('Rater', 'Criterion', if (nt > 0L) 'Task')
    totals <- tapply(data$Score, data$Person, sum)
    result[[name]] <- list(name = name, N = N, seed = seed, data = data,
      facets = facets, truth = truth, theta = theta, person_order = person_order,
      extremes = sum(totals %in% c(0, 16)), RNG = RNGkind())
    stopifnot(all(table(data$Person) == 8L), length(unique(data$Rater)) == nr,
      length(unique(data$Criterion)) == 2L)
  }
  stopifnot(identical(result$base_two_facet$data, result$null_task$data))
  result
}

pilot_problem <- function(x) mfrmr:::mfrm_jml_adjustment_problem(
  x$data, 'Person', x$facets, 'Score', 'Criterion', 2L)

pilot_truth <- function(x, parameters) vapply(seq_len(nrow(parameters)), function(j) {
  z <- parameters[j, ]; level <- as.integer(z$Level)
  switch(z$Type, location = x$truth[[z$Facet]][level],
    step = x$truth$steps[level, z$Step], log_slope = x$truth$log_slopes[level])
}, 0)

pilot_prepare <- function(out) {
  stopifnot(!dir.exists(out))
  dir.create(file.path(out, 'inputs'), recursive = TRUE)
  dir.create(file.path(out, 'fits')); dir.create(file.path(out, 'source'))
  files <- c('DESCRIPTION', 'NAMESPACE', pilot_script,
    list.files('R', full.names = TRUE), list.files('src', pattern = '\\.(cpp|h|so)$', full.names = TRUE))
  for (f in files) {
    dest <- file.path(out, 'source', f); dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
    stopifnot(file.copy(f, dest))
  }
  preflight <- list(); jobs <- list(); inputs <- character()
  for (N in c(20L, 240L)) {
    generated <- pilot_inputs(N, if (N == 20L) 98100201L else 98100202L)
    for (x in generated) {
      id <- paste(N, x$name, sep = '-'); path <- file.path(out, 'inputs', paste0(id, '.rds'))
      p <- pilot_problem(x); x$parameters <- p$parameters; x$beta_truth <- pilot_truth(x, p$parameters)
      ng <- length(unique(p$roster)); sizes <- table(p$roster)
      started <- proc.time()[['elapsed']]; eq <- p$mean_score(x$beta_truth, 4L)
      seconds <- proc.time()[['elapsed']] - started
      # Linear location identification includes freely varying Person coordinates.
      X <- model.matrix(reformulate(c('Person', x$facets)), x$data)
      stopifnot(qr(X)$rank == ncol(X), all(p$total_states == 81L), all(is.finite(eq)))
      x$roster <- p$roster; x$total_states <- p$total_states
      saveRDS(x, path); inputs <- c(inputs, path)
      preflight[[id]] <- data.frame(Input = id, N = N, NonPersonFacets = length(x$facets),
        RaterLevels = length(p$levels$Rater), CriterionLevels = 2L,
        TaskLevels = if ('Task' %in% x$facets) length(p$levels$Task) else 0L,
        ResponsesPerPerson = 8L, Categories = 3L, StructuralParameters = nrow(p$parameters),
        Rosters = ng, SingletonRosters = sum(sizes == 1L), CenteredRankCeiling = N-ng,
        FixedRosterCovariancePossible = all(sizes >= 2L) && N-ng >= nrow(p$parameters),
        TotalStatesPerRoster = 81L, ExtremePersons = x$extremes, EquationSeconds = seconds)
      for (method in c('MML', 'JML', 'JML2', 'JML4')) {
        job <- paste(id, method, sep = '-')
        jobs[[job]] <- data.frame(Job = job, Input = id, Method = method)
      }
    }
  }
  preflight <- do.call(rbind, preflight); jobs <- do.call(rbind, jobs)
  stopifnot(nrow(jobs) == 40L, nrow(preflight) == 10L)
  manifest <- list(created = Sys.time(), preflight = preflight, jobs = jobs,
    source_md5 = tools::md5sum(files), input_md5 = tools::md5sum(inputs),
    protocol = list(repetitions = 1L, methods = c('MML','JML','JML2','JML4'),
      correction_sampling = 'fixed_rosters', maxit = 400L, optimizer = 'BFGS',
      reltol = 1e-9, MML = 'direct fixed q31; estimated intercept and SD; one relative-slope family',
      process_seconds = 120L, common_random_numbers = TRUE,
      null_task = 'Exactly identical base responses; two independent event labels become a zero-effect Task.',
      scope = 'Diagnostic subset of roadmap C: K3, Criterion2, N20/240. No bias/coverage qualification.',
      covariance = 'Fixed-roster arithmetic feasibility is necessary, not sufficient. No roster-law fallback.',
      integration = 'q31 fixed parameters are retained; no automatic refitting for interval availability.'),
    session = capture.output(sessionInfo()))
  saveRDS(manifest, file.path(out, 'manifest.rds'))
  write.csv(preflight, file.path(out, 'preflight.csv'), row.names = FALSE)
  write.table(jobs, file.path(out, 'jobs.tsv'), sep = '\t', quote = FALSE, row.names = FALSE)
  print(preflight, row.names = FALSE)
}

pilot_load <- function(out) {
  m <- readRDS(file.path(out, 'manifest.rds'))
  stopifnot(identical(tools::md5sum(names(m$source_md5)), m$source_md5),
    identical(tools::md5sum(names(m$input_md5)), m$input_md5))
  m
}

pilot_fit <- function(out, job) {
  m <- pilot_load(out); j <- m$jobs[m$jobs$Job == job, ]; stopifnot(nrow(j) == 1L)
  path <- file.path(out, 'fits', paste0(job, '.rds')); stopifnot(!file.exists(path))
  x <- readRDS(file.path(out, 'inputs', paste0(j$Input, '.rds')))
  args <- list(data = x$data, person = 'Person', facets = x$facets, score = 'Score',
    model = 'GPCM', method = if (j$Method == 'MML') 'MML' else 'JML',
    step_facet = 'Criterion', slope_facet = 'Criterion', rating_min = 0, rating_max = 2,
    category_policy = 'preserve', maxit = 400L)
  if (j$Method %in% c('JML2','JML4')) {
    args$jml_correction_order <- as.integer(sub('JML', '', j$Method))
    args$jml_correction_sampling <- 'fixed_rosters'
  } else {
    args$optimizer <- 'BFGS'; args$reltol <- 1e-9
    if (j$Method == 'MML') {
      args$quad_points <- 31L; args$mml_engine <- 'direct'; args$mml_integration <- 'fixed'
      args$population_formula <- ~1
      args$person_data <- data.frame(Person = sort(unique(x$data$Person)))
    }
  }
  warnings <- character(); started <- proc.time()[['elapsed']]
  fit <- tryCatch(withCallingHandlers(do.call(mfrmr::fit_mfrm, args),
    warning = function(w) { warnings <<- c(warnings, conditionMessage(w)); invokeRestart('muffleWarning') }),
    error = function(e) list(pilot_error = conditionMessage(e)))
  # Serialize the estimation outcome before any secondary inspection can fail.
  saveRDS(list(job = j, fit = fit, warnings = warnings,
    seconds = proc.time()[['elapsed']] - started,
    manifest_md5 = unname(tools::md5sum(file.path(out, 'manifest.rds')))), path)
  cat(job, 'saved\n')
}

pilot_beta <- function(fit, parameters) vapply(seq_len(nrow(parameters)), function(j) {
  z <- parameters[j, ]
  if (z$Type == 'location') {
    a <- fit$facets$others; value <- a$Estimate[a$Facet == z$Facet & a$Level == z$Level]
  } else if (z$Type == 'step') {
    a <- fit$steps; value <- a$Estimate[a$StepFacet == z$Level & a$Step == paste0('Step_', z$Step)]
  } else {
    a <- fit$slopes; value <- a$LogEstimate[a$SlopeFacet == z$Level]
  }
  stopifnot(length(value) == 1L); value
}, 0)

pilot_summary <- function(out) {
  m <- pilot_load(out); rows <- checks <- list()
  for (i in seq_len(nrow(m$jobs))) {
    j <- m$jobs[i, ]; path <- file.path(out, 'fits', paste0(j$Job, '.rds'))
    x <- readRDS(file.path(out, 'inputs', paste0(j$Input, '.rds')))
    row <- data.frame(j, N = x$N, PointAvailable = FALSE, Status = 'not_returned',
      CovarianceAvailable = FALSE, CovarianceReason = '', EquationResidual = NA_real_,
      MaxAbsoluteError = NA_real_, Seconds = NA_real_, Warnings = NA_integer_, Error = '')
    if (file.exists(path)) {
      z <- readRDS(path); fit <- z$fit; row$Seconds <- z$seconds; row$Warnings <- length(z$warnings)
      stopifnot(identical(z$manifest_md5, unname(tools::md5sum(file.path(out, 'manifest.rds')))))
      if (!is.null(fit[['pilot_error', exact = TRUE]])) {
        row$Status <- 'error'; row$Error <- fit[['pilot_error', exact = TRUE]]
      } else {
        beta <- pilot_beta(fit, x$parameters)
        if (j$Method %in% c('JML2','JML4')) {
          a <- fit$jml_adjustment
          row$PointAvailable <- isTRUE(a$point$available); row$Status <- a$point$status
          row$CovarianceAvailable <- isTRUE(a$covariance$available)
          row$CovarianceReason <- a$covariance$reason
          row$EquationResidual <- a$point$equation_residual
          if (row$PointAvailable) stopifnot(max(abs(beta-a$point$beta)) < 1e-12)
        } else {
          row$PointAvailable <- all(is.finite(beta))
          row$Status <- paste(fit$summary$ConvergenceSeverity[1], fit$readiness$fit$FitReadiness[1], sep = ':')
          row$CovarianceReason <- if (j$Method == 'JML') 'structural_sampling_covariance_unavailable' else 'native_model_hessian_not_assessed_in_this_pilot'
        }
        if (row$PointAvailable) row$MaxAbsoluteError <- max(abs(beta-x$beta_truth))
        checks[[j$Job]] <- list(parameters = x$parameters, truth = x$beta_truth, estimate = beta)
      }
    } else {
      status_path <- file.path(out, 'fits', paste0(j$Job, '.status'))
      if (file.exists(status_path)) row$Error <- paste(readLines(status_path), collapse = ' ')
    }
    rows[[j$Job]] <- row
  }
  rows <- do.call(rbind, rows)
  saveRDS(list(rows = rows, checks = checks, preflight = m$preflight,
    fit_md5 = tools::md5sum(list.files(file.path(out,'fits'), '\\.rds$', full.names = TRUE))),
    file.path(out, 'summary.rds'))
  write.csv(rows, file.path(out, 'rows.csv'), row.names = FALSE)
  print(rows, row.names = FALSE)
}

args <- commandArgs(trailingOnly = TRUE)
if (length(args) >= 2L) switch(args[1],
  prepare = pilot_prepare(args[2]), fit = pilot_fit(args[2], args[3]),
  summary = pilot_summary(args[2]), stop('Expected prepare, fit or summary.'))
