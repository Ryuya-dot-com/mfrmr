# One known-calibration posterior check; see the fixed pre-sampling plan.
run_shared_rater_brms_posterior <- function() {
  prefix <- 'inst/validation/shared-rater-brms-posterior-0.2.4'
  output <- 'validation-results/shared-rater-brms-posterior-20260918'
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  input_paths <- c('inst/validation/random-effects-brms-bridge-0.2.4-evidence.rds',
    'inst/validation/shared-rater-posterior-visual-0.2.4.json')
  bridge <- readRDS(input_paths[1])
  reference <- jsonlite::fromJSON(input_paths[2])
  stopifnot(all(bridge$checks$Pass), all(reference$checks$pass),
    identical(bridge$hashes, tools::md5sum(names(bridge$hashes))))
  software <- c(brms = as.character(utils::packageVersion('brms')),
    cmdstanr = as.character(utils::packageVersion('cmdstanr')),
    cmdstan = as.character(cmdstanr::cmdstan_version()),
    posterior = as.character(utils::packageVersion('posterior')))
  identity <- list(hashes = tools::md5sum(c(paste0(prefix, '.R'), input_paths)), software = software)
  spec <- bridge$records$shared_rater$spec
  b <- bridge$records$shared_rater$conditional_point$b
  spec$prior <- c(brms::set_prior(sprintf('constant(%.17g)', b), class = 'b'),
    brms::set_prior('constant("to_vector({-0.6, 0.6})", broadcast = FALSE)', class = 'Intercept'),
    brms::set_prior('constant(1)', class = 'sd', group = 'Person'),
    brms::set_prior('constant(0.7)', class = 'sd', group = 'Rater'))
  args <- spec[c('formula', 'data', 'family', 'prior')]
  stan_data <- do.call(brms::make_standata, args)
  code <- do.call(brms::make_stancode, args)
  settings <- list(chains = 4L, parallel_chains = 4L, seed = 262018101L,
    iter_warmup = 1000L, iter_sampling = 8000L, thin = 1L, init = 2,
    adapt_delta = .9, max_treedepth = 10L, metric = 'diag_e', sig_figs = 18L,
    refresh = 2000L, save_warmup = FALSE, output_dir = normalizePath(output),
    output_basename = 'shared-rater-known')
  plan_path <- file.path(output, 'plan.rds')
  if (file.exists(plan_path)) {
    plan <- readRDS(plan_path)
    stopifnot(identical(plan$identity, identity), identical(plan$code, code),
      identical(plan$stan_data, stan_data), identical(plan$settings, settings))
  } else {
    plan <- list(identity = identity, spec = spec, code = code, stan_data = stan_data,
      settings = settings, reference = reference, design = readLines(paste0(prefix, '.md')),
      session = sessionInfo(), created = Sys.time())
    saveRDS(plan, plan_path)
  }
  model_path <- file.path(output, 'shared-rater-known.stan')
  writeLines(code, model_path)
  fit_path <- file.path(output, 'fit.rds')
  started <- file.path(output, 'sampling-started.rds')
  if (file.exists(fit_path)) {
    fit <- readRDS(fit_path)
  } else if (file.exists(started)) {
    csv <- list.files(output, pattern = '^shared-rater-known.*[.]csv$', full.names = TRUE)
    if (length(csv) != settings$chains) stop('Incomplete saved run: inspect it; do not launch replacement chains')
    fit <- cmdstanr::as_cmdstan_fit(csv)
  } else {
    model <- cmdstanr::cmdstan_model(model_path, cpp_options = list(PRECOMPILED_HEADERS = 'false'))
    saveRDS(list(identity = identity, started = Sys.time()), started)
    fit <- do.call(model$sample, c(list(data = stan_data), settings))
    fit$save_object(fit_path)
  }
  # Retain completed chains before checking diagnostics; failed runs are evidence.
  draws <- fit$draws(variables = c('r_1_1', 'r_2_1'), format = 'draws_array')
  raw <- as.array(draws)
  p1 <- raw[, , 'r_1_1[1]']; p2 <- raw[, , 'r_1_1[2]']
  difference <- p1 - p2
  c1 <- p1 - reference$mean[1]; c2 <- p2 - reference$mean[2]
  quantities <- list(MeanP1 = p1, MeanP2 = p2, MeanDifference = difference,
    VarianceP1 = c1^2, VarianceP2 = c2^2, Covariance = c1 * c2,
    VarianceDifference = (c1 - c2)^2)
  expected <- c(reference$mean, reference$difference_mean,
    diag(reference$covariance), reference$covariance[1, 2], reference$difference_variance)
  comparison <- do.call(rbind, lapply(seq_along(quantities), function(k) {
    q <- quantities[[k]]
    mcse <- posterior::mcse_mean(q)
    error <- abs(mean(q) - expected[k])
    data.frame(Quantity = names(quantities)[k], Estimate = mean(q), Reference = expected[k],
      AbsoluteError = error, MCSE = mcse, Tolerance = 4 * mcse + 1e-7,
      PrecisionPass = is.finite(mcse) && mcse > 0 && mcse <= .01,
      AgreementPass = is.finite(error) && is.finite(mcse) && error <= 4 * mcse + 1e-7)
  }))
  latent <- lapply(seq_len(dim(raw)[3]), function(k) raw[, , k])
  names(latent) <- dimnames(raw)[[3]]
  diagnostics <- do.call(rbind, lapply(names(c(latent, quantities)), function(name) {
    q <- c(latent, quantities)[[name]]
    data.frame(Quantity = name, Rhat = posterior::rhat(q),
      ESSBulk = posterior::ess_bulk(q), ESSTail = posterior::ess_tail(q))
  }))
  diagnostics$Pass <- with(diagnostics, is.finite(Rhat) & Rhat < 1.01 &
    is.finite(ESSBulk) & ESSBulk >= 400 & is.finite(ESSTail) & ESSTail >= 400)
  sampler <- fit$diagnostic_summary()
  covariance <- stats::cov(cbind(as.vector(p1), as.vector(p2)))
  summary <- list(mean = c(mean(p1), mean(p2)), covariance = covariance,
    difference_mean = mean(difference), difference_variance = stats::var(as.vector(difference)),
    difference_sd = stats::sd(as.vector(difference)),
    difference_sd_without_covariance = sqrt(sum(diag(covariance))))
  contrast_error <- abs(summary$difference_variance - sum(diag(covariance)) + 2 * covariance[1, 2])
  unchanged <- identical(identity$hashes, tools::md5sum(names(identity$hashes)))
  checks <- data.frame(Check = c('source_and_input_identity', 'complete_chains', 'no_divergences',
      'no_treedepth_hits', 'chain_ebfmi', 'rhat_and_ess', 'moment_mcse', 'moment_agreement', 'contrast_identity'),
    Pass = c(unchanged, all(fit$return_codes() == 0) && identical(dim(raw)[1:2], c(8000L, 4L)),
      all(sampler$num_divergent == 0), all(sampler$num_max_treedepth == 0),
      all(is.finite(sampler$ebfmi) & sampler$ebfmi >= .3), all(diagnostics$Pass),
      all(comparison$PrecisionPass), all(comparison$AgreementPass), contrast_error <= 1e-12))
  result <- list(plan = plan, draws = draws, sampler_diagnostics = fit$sampler_diagnostics(),
    sampler = sampler, diagnostics = diagnostics, comparison = comparison, summary = summary,
    contrast_error = contrast_error, checks = checks, timing = fit$time(),
    csv_hashes = tools::md5sum(fit$output_files()), completed = Sys.time())
  saveRDS(result, paste0(prefix, '-evidence.rds'))
  write.csv(comparison, paste0(prefix, '-comparison.csv'), row.names = FALSE)
  write.csv(diagnostics, paste0(prefix, '-diagnostics.csv'), row.names = FALSE)
  write.csv(checks, paste0(prefix, '-checks.csv'), row.names = FALSE)
  print(comparison, row.names = FALSE); print(sampler); print(checks, row.names = FALSE)
  stopifnot(all(checks$Pass))
  invisible(result)
}

if (sys.nframe() == 0L) run_shared_rater_brms_posterior()
