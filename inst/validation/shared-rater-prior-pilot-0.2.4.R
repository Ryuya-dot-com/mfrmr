# Repository-only, fixed eight-fit pilot; see the pre-generation plan.
source('inst/validation/random-effects-brms-bridge-0.2.4.R')

run_shared_rater_prior_pilot <- function() {
  prefix <- 'inst/validation/shared-rater-prior-pilot-0.2.4'
  output <- 'validation-results/shared-rater-prior-pilot-20260918'
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  inputs <- c('../research-notes/2026-09-17-random-effects-rating-design/design-incidence.csv',
    'inst/validation/rating-design-targets-0.2.4-pairs.csv')
  sources <- c(paste0(prefix, '.R'), 'inst/validation/random-effects-brms-bridge-0.2.4.R',
    'inst/validation/local-testlet-tam-reference-0.2.4.R')
  identity <- list(hashes = tools::md5sum(c(sources, inputs)),
    software = c(brms = as.character(utils::packageVersion('brms')),
      cmdstanr = as.character(utils::packageVersion('cmdstanr')),
      cmdstan = as.character(cmdstanr::cmdstan_version()),
      posterior = as.character(utils::packageVersion('posterior'))))
  plan_path <- file.path(output, 'plan.rds')
  if (file.exists(plan_path)) {
    plan <- readRDS(plan_path)
    stopifnot(identical(plan$identity, identity))
  } else {
    incidence <- read.csv(inputs[1])
    pairs <- read.csv(inputs[2]); pairs <- pairs[pairs$PilotSelected == 'True', ]
    stopifnot(nrow(pairs) == 12L, length(unique(c(pairs$P1, pairs$P2))) == 24L)
    RNGkind('Mersenne-Twister', 'Inversion', 'Rejection'); set.seed(262018201)
    truth <- list(alpha = 0, beta = c(-.4, 0, .4), tau = c(-.6, .6),
      rater_sd = .6, theta = rnorm(240), severity = rnorm(12, sd = .6))
    universe <- expand.grid(Person = 1:240, Rater = 1:12, Criterion = 1:3)
    eta <- with(universe, truth$alpha + truth$theta[Person] - truth$beta[Criterion] - truth$severity[Rater])
    probabilities <- local_testlet_probabilities(eta, truth$tau[1])
    uniform <- runif(nrow(universe))
    universe$Score <- as.integer(uniform > probabilities[, 1]) +
      as.integer(uniform > rowSums(probabilities[, 1:2]))
    priors <- data.frame(ID = c('baseline', 'sd_tighter', 'sd_wider', 'calibration_tighter'),
      CalibrationSD = c(2, 2, 2, 1), RaterSDScale = c(1, .5, 2, 1))
    specs <- list(); mapping_errors <- numeric()
    for (design in c('A', 'D')) {
      inc <- incidence[incidence$Design == design, ]
      stopifnot(nrow(inc) == 480L, !anyDuplicated(inc[c('Person', 'Rater')]),
        all(inc$CriteriaPerBundle == 3L), all(table(inc$Person) == 2L),
        all(table(inc$Rater) == 40L))
      selected <- with(universe, paste(Person, Rater)) %in% with(inc, paste(Person, Rater))
      spec <- random_effects_brms_spec(universe[selected, ], 'shared_rater')
      args <- spec[c('formula', 'data', 'family', 'prior')]
      d <- do.call(brms::make_standata, args)
      stopifnot(d$N == 1440L, d$N_1 == 240L, d$N_2 == 12L,
        identical(as.vector(d$J_1), as.integer(spec$data$Person)),
        identical(as.vector(d$J_2), as.integer(spec$data$Rater)),
        identical(as.vector(d$Y), as.integer(spec$data$Score)))
      person_ids <- as.integer(levels(spec$data$Person))
      rater_ids <- as.integer(levels(spec$data$Rater))
      stopifnot(identical(sort(person_ids), 1:240), identical(sort(rater_ids), 1:12))
      b <- -crossprod(spec$basis$Criterion, truth$beta)
      mu <- drop(d$X %*% b) + truth$theta[person_ids[d$J_1]] - truth$severity[rater_ids[d$J_2]]
      actual <- getFromNamespace('dacat', 'brms')(1:3, eta = matrix(mu, d$N, 2),
        thres = matrix(truth$tau, d$N, 2, byrow = TRUE))
      mapping_errors[design] <- max(abs(actual - probabilities[selected, ]))
      specs[[design]] <- list(spec = spec, data = d,
        person_index = match(1:240, person_ids), rater_index = match(1:12, rater_ids))
    }
    stopifnot(all(mapping_errors <= 1e-12))
    runs <- expand.grid(Design = c('A', 'D'), Prior = priors$ID, stringsAsFactors = FALSE)
    runs$Seed <- 262018210L + seq_len(nrow(runs))
    settings <- list(chains = 4L, parallel_chains = 4L, iter_warmup = 1000L,
      iter_sampling = 2000L, thin = 1L, init = 2, adapt_delta = .95,
      max_treedepth = 12L, metric = 'diag_e', sig_figs = 18L,
      refresh = 1000L, save_warmup = FALSE)
    codes <- list()
    for (k in seq_len(nrow(priors))) {
      spec <- specs$A$spec
      spec$prior <- c(brms::set_prior(sprintf('normal(0, %g)', priors$CalibrationSD[k]), class = 'b'),
        brms::set_prior(sprintf('normal(0, %g)', priors$CalibrationSD[k]), class = 'Intercept'),
        brms::set_prior('constant(1)', class = 'sd', group = 'Person'),
        brms::set_prior(sprintf('normal(0, %g)', priors$RaterSDScale[k]), class = 'sd', group = 'Rater'))
      codes[[priors$ID[k]]] <- do.call(brms::make_stancode, spec[c('formula', 'data', 'family', 'prior')])
    }
    plan <- list(identity = identity, design = readLines(paste0(prefix, '.md')),
      incidence = incidence, pairs = pairs, truth = truth, universe = universe,
      uniform = uniform, probabilities = probabilities, specs = specs,
      priors = priors, runs = runs, settings = settings, codes = codes,
      mapping_errors = mapping_errors, session = sessionInfo(), created = Sys.time())
    saveRDS(plan, plan_path)
  }
  results <- list(); models <- list()
  compilation_path <- file.path(output, 'compilation.rds')
  compilation <- if (file.exists(compilation_path)) readRDS(compilation_path) else list()
  summarize <- function(q, name, kind) {
    interval <- stats::quantile(q, c(.025, .975), names = FALSE, type = 7)
    endpoint_mcse <- posterior::mcse_quantile(q, probs = c(.025, .975))
    out <- data.frame(Target = name, Kind = kind, Mean = mean(q), SD = stats::sd(as.vector(q)),
      Lower = interval[1], Upper = interval[2], MCSEMean = posterior::mcse_mean(q),
      MCSELower = unname(endpoint_mcse[1]), MCSEUpper = unname(endpoint_mcse[2]),
      Rhat = posterior::rhat(q), ESSBulk = posterior::ess_bulk(q), ESSTail = posterior::ess_tail(q))
    out$PrecisionPass <- with(out, is.finite(MCSEMean) & is.finite(MCSELower) & is.finite(MCSEUpper) &
      SD > 0 & Upper > Lower & MCSEMean / SD <= .05 &
      pmax(MCSELower, MCSEUpper) / (Upper - Lower) <= .03)
    out
  }
  for (i in seq_len(nrow(plan$runs))) {
    run <- plan$runs[i, ]; id <- paste(run$Design, run$Prior, sep = '_')
    directory <- file.path(output, id); dir.create(directory, showWarnings = FALSE)
    result_path <- file.path(directory, 'result.rds')
    if (file.exists(result_path)) {
      results[[id]] <- readRDS(result_path); next
    }
    cat('\nSTART', id, format(Sys.time()), '\n')
    result <- tryCatch({
      execution_path <- file.path(directory, 'execution.rds')
      started <- file.path(directory, 'started.rds')
      if (file.exists(started)) {
        csv <- list.files(directory, pattern = '^draws.*[.]csv$', full.names = TRUE)
        if (length(csv) != 4L || !file.exists(execution_path)) stop('Incomplete saved run; no replacement chains')
        execution <- readRDS(execution_path)
        stopifnot(identical(execution$csv_hashes, tools::md5sum(names(execution$csv_hashes))))
        fit <- cmdstanr::as_cmdstan_fit(csv)
      } else {
        if (is.null(models[[run$Prior]])) {
          path <- file.path(output, paste0(run$Prior, '.stan'))
          writeLines(plan$codes[[run$Prior]], path)
          t <- proc.time()[3]
          models[[run$Prior]] <- cmdstanr::cmdstan_model(path, cpp_options = list(PRECOMPILED_HEADERS = 'false'))
          compilation[[run$Prior]] <- unname(proc.time()[3] - t)
          saveRDS(compilation, compilation_path)
        }
        saveRDS(list(identity = identity, run = run, started = Sys.time()), started)
        fit <- do.call(models[[run$Prior]]$sample, c(list(data = plan$specs[[run$Design]]$data,
          seed = run$Seed, output_dir = normalizePath(directory), output_basename = 'draws'), plan$settings))
        execution <- list(return_codes = fit$return_codes(), sampler = fit$diagnostic_summary(),
          timing = fit$time(), csv_hashes = tools::md5sum(fit$output_files()))
        saveRDS(execution, execution_path)
      }
      t <- proc.time()[3]
      raw <- as.array(fit$draws(variables = c('b', 'Intercept', 'sd_2', 'r_1_1', 'r_2_1', 'z_1', 'z_2', 'lp__'),
        format = 'draws_array'))
      diagnostics <- do.call(rbind, lapply(seq_len(dim(raw)[3]), function(k) {
        q <- raw[, , k]
        data.frame(Target = dimnames(raw)[[3]][k], Rhat = posterior::rhat(q),
          ESSBulk = posterior::ess_bulk(q), ESSTail = posterior::ess_tail(q))
      }))
      effects <- list(alpha = -(raw[, , 'Intercept[1]'] + raw[, , 'Intercept[2]']) / 2,
        tau1 = (raw[, , 'Intercept[1]'] - raw[, , 'Intercept[2]']) / 2,
        RaterSD = raw[, , 'sd_2[1]'], RaterVariance = raw[, , 'sd_2[1]']^2)
      basis <- plan$specs[[run$Design]]$spec$basis$Criterion
      for (j in 1:3) effects[[paste0('beta', j)]] <-
        -basis[j, 1] * raw[, , 'b[1]'] - basis[j, 2] * raw[, , 'b[2]']
      rows <- lapply(names(effects), function(name) summarize(effects[[name]], name, 'calibration'))
      person_index <- plan$specs[[run$Design]]$person_index
      rater_index <- plan$specs[[run$Design]]$rater_index
      for (r in 1:12) rows[[length(rows) + 1L]] <- summarize(-raw[, , paste0('r_2_1[', rater_index[r], ']')], paste0('R', r), 'rater')
      for (p in 1:240) rows[[length(rows) + 1L]] <- summarize(raw[, , paste0('r_1_1[', person_index[p], ']')], paste0('P', p), 'person')
      for (k in seq_len(nrow(plan$pairs))) {
        pair <- plan$pairs[k, ]
        difference <- raw[, , paste0('r_1_1[', person_index[pair$P1], ']')] - raw[, , paste0('r_1_1[', person_index[pair$P2], ']')]
        rows[[length(rows) + 1L]] <- summarize(difference, pair$Target, pair$Stratum)
      }
      summary <- do.call(rbind, rows)
      dg <- rbind(diagnostics, summary[names(diagnostics)])
      diagnostic_pass <- with(dg, is.finite(Rhat) & Rhat < 1.01 &
        is.finite(ESSBulk) & ESSBulk >= 400 & is.finite(ESSTail) & ESSTail >= 400)
      s <- execution$sampler
      ready <- length(execution$return_codes) == 4L && all(execution$return_codes == 0) &&
        identical(dim(raw)[1:2], c(2000L, 4L)) &&
        identical(names(s), c('num_divergent', 'num_max_treedepth', 'ebfmi')) &&
        all(lengths(s) == 4L) && all(s$num_divergent == 0) && all(s$num_max_treedepth == 0) &&
        all(is.finite(s$ebfmi) & s$ebfmi >= .3) && all(diagnostic_pass)
      summary$Available <- ready & summary$PrecisionPass
      list(run = run, status = 'completed', ready = ready, summary = summary,
        diagnostics = dg, diagnostic_pass = diagnostic_pass, execution = execution,
        postprocess_seconds = unname(proc.time()[3] - t), completed = Sys.time())
    }, error = function(e) list(run = run, status = 'failed', ready = FALSE,
      error = conditionMessage(e), completed = Sys.time()))
    saveRDS(result, result_path); results[[id]] <- result
    cat('END', id, result$status, 'ready:', result$ready, format(Sys.time()), '\n')
    if (identical(result$status, 'failed')) cat(result$error, '\n')
  }
  stopifnot(identical(identity$hashes, tools::md5sum(names(identity$hashes))))
  summaries <- do.call(rbind, lapply(results, function(x) {
    if (is.null(x$summary)) return(NULL)
    cbind(Design = x$run$Design, Prior = x$run$Prior, x$summary)
  }))
  write.csv(summaries, paste0(prefix, '-summary.csv'), row.names = FALSE)
  evidence <- list(plan = plan, results = results,
    compilation = readRDS(file.path(output, 'compilation.rds')), completed = Sys.time())
  saveRDS(evidence, paste0(prefix, '-evidence.rds'))
  print(vapply(results, function(x) x$ready, logical(1)))
  invisible(evidence)
}

if (sys.nframe() == 0L) run_shared_rater_prior_pilot()
