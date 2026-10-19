# Research-only starting-value comparison on retained inputs. No truth values,
# accepted corrected roots, penalties, bounds or equation changes enter fitting.
jml_pcm_start_pilot <- function(root, out) {
  pkgload::load_all(quiet = TRUE, compile = FALSE)
  scripts <- paste0('inst/validation/', c('jml-log-total-stability-20261003.R',
    'jml-public-profile-bridge-20261002.R', 'mfrm-wide-map-mml-stages-20261001.R'))
  for (path in scripts) source(path)
  m <- readRDS(file.path(root, 'manifest.rds'))$payload
  stopifnot(identical(m$source, tools::md5sum(names(m$source))))
  condition <- 'AB:paired-L1:N30:SD1:S-PCM'
  replicates <- c(6L, 23L, 24L, 1L)
  plan <- expand.grid(Order = c(2L, 4L), Replicate = replicates)
  jobs <- m$jobs[m$jobs$ConditionId == condition, ]
  job_id <- function(rep, arm) {
    x <- jobs$JobId[jobs$Replicate == rep & jobs$Arm == arm]
    stopifnot(length(x) == 1L); x
  }
  plan$Job <- mapply(function(rep, k) job_id(rep, paste0('GPCM-JML', k)), plan$Replicate, plan$Order)
  plan$PCMJob <- vapply(plan$Replicate, job_id, '', arm = 'PCM-JML')
  fit_paths <- setNames(file.path(root, unique(c(plan$Job, plan$PCMJob)), 'calibration/q0-fit.rds'),
    unique(c(plan$Job, plan$PCMJob)))
  source <- tools::md5sum(unique(c(names(m$source), scripts,
    'inst/validation/jml-pcm-start-pilot-20261003.R')))
  binding <- list(source = source, inputs = tools::md5sum(fit_paths), plan = plan,
    manifest = tools::md5sum(file.path(root, 'manifest.rds')),
    solver = as.character(packageVersion('nleqslv')),
    policy = list(seed = 'Retained same-data ordinary PCM coefficients, with free log slopes zero',
      perturbation = 'Original perturbed-minus-neutral vector, added to the PCM seed',
      solver = 'Unchanged complete original Broyden/Newton stages, tolerances and maxit',
      selection = 'Three previously adverse datasets plus the first replicate; both orders; diagnostic subset, not independent performance validation'))
  stopifnot(!anyNA(unlist(binding[c('source', 'inputs', 'manifest')])))
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  read_fit <- function(id) {
    x <- readRDS(fit_paths[[id]])$payload
    stopifnot(identical(x$error, '')); x$value
  }
  env <- jml_log_total_environment()
  # Prepare every initial vector before executing any corrected fit. Only PCM
  # coefficients, observed data, coordinate metadata and solver policy are used.
  prepared <- wide_mml_phase(file.path(out, 'prepared.rds'), binding, function() {
    result <- lapply(replicates, function(rep) {
      pcm <- read_fit(job_id(rep, 'PCM-JML'))
      corrected <- read_fit(job_id(rep, 'GPCM-JML2'))
      a <- corrected$jml_adjustment; s <- a$specification
      stopifnot(identical(pcm$prep$data, corrected$prep$data),
        identical(pcm$prep$levels, corrected$prep$levels), pcm$opt$convergence == 0L,
        a$policy$solver_version == binding$solver)
      args <- c(list(data = pcm$prep$data), s[c('person', 'facets', 'score', 'owner', 'rating_max', 'max_states')])
      p <- do.call(env$mfrm_jml_adjustment_problem, args)
      ctx <- jml_bridge_context(pcm)
      linear <- which(p$parameters$Type != 'log_slope'); slopes <- which(p$parameters$Type == 'log_slope')
      stopifnot(identical(linear, seq_along(ctx$beta)), length(slopes) == 2L)
      seed <- c(ctx$beta, rep(0, length(slopes)))
      raw <- p$evaluate(seed, 0L); reference <- jml_bridge_profile(ctx, ctx$beta)
      errors <- c(criterion = abs(sum(raw$q)-reference$value),
        score = max(abs(raw$value[, linear, drop = FALSE]-reference$scores)))
      stopifnot(max(errors) < 1e-8)
      perturbation <- a$policy$starts$perturbed-a$policy$starts$neutral
      stopifnot(length(perturbation) == length(seed), all(is.finite(seed)), any(perturbation != 0))
      list(args = args, starts = list(pcm = seed, pcm_perturbed = seed+perturbation),
        policy = a$policy, coordinate_check = errors)
    }); names(result) <- as.character(replicates)
    result
  })
  summary <- list()
  for (i in seq_len(nrow(plan))) {
    row <- plan[i, ]; setup <- prepared[[as.character(row$Replicate)]]
    original <- read_fit(row$Job)$jml_adjustment
    stopifnot(identical(setup$policy, original$policy))
    cat('Starting PCM-initialized', row$Job, 'rep', row$Replicate, 'order', row$Order, '\n'); flush.console()
    result <- wide_mml_phase(file.path(out, paste0(row$Job, '.rds')), list(parent = binding, job = row), function() {
      p <- do.call(env$mfrm_jml_adjustment_problem, setup$args)
      fit <- wide_mml_capture(function() mfrmr:::mfrm_jml_adjustment_fit(p, row$Order,
        starts = setup$starts, maxit = setup$policy$maxit, sampling = original$estimator$sampling))
      # Original corrected roots are consulted only after the new fitting call.
      review <- list()
      if (!nzchar(fit$error)) {
        z <- fit$value
        unchanged <- setdiff(names(setup$policy), 'starts')
        stopifnot(identical(z$policy[unchanged], setup$policy[unchanged]))
        if (isTRUE(z$point$available) && isTRUE(original$point$available))
          review$original_root_distance <- max(abs(z$point$beta-original$point$beta))
        if (isTRUE(z$covariance$available) && isTRUE(original$covariance$available))
          review$original_covariance_difference <- max(abs(z$covariance$result$vcov-original$covariance$result$vcov))
      }
      stopifnot(identical(source, tools::md5sum(names(source))))
      list(fitting = fit, comparison = review,
        original = original[c('point', 'covariance')], session = sessionInfo())
    })
    z <- result$fitting$value
    summary[[i]] <- data.frame(row, OriginalStatus = original$point$status,
      CandidateStatus = if (nzchar(result$fitting$error)) result$fitting$error else z$point$status,
      SuccessfulStarts = if (is.null(z)) 0L else z$point$successful_starts,
      Residual = if (is.null(z)) NA_real_ else z$point$equation_residual,
      RootDifference = if (is.null(result$comparison$original_root_distance)) NA_real_ else result$comparison$original_root_distance,
      CovarianceAvailable = !is.null(z) && isTRUE(z$covariance$available),
      Seconds = result$fitting$elapsed)
    print(summary[[i]]); flush.console()
  }
  summary <- do.call(rbind, summary)
  stopifnot(identical(source, tools::md5sum(names(source))),
    identical(binding$inputs, tools::md5sum(fit_paths)))
  wide_mml_phase(file.path(out, 'summary.rds'), binding, function() summary)
  write.csv(summary, file.path(out, 'summary.csv'), row.names = FALSE)
  invisible(summary)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(TRUE); stopifnot(length(args) == 2L)
  jml_pcm_start_pilot(args[1], args[2])
}
