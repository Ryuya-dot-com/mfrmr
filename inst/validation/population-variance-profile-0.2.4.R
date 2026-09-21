# Repository-only bounded variance profiles. The companion record owns scope.
source('inst/validation/population-identifiability-review-0.2.4.R')
source('inst/validation/numerical-stationarity-pilot-0.2.3.R')
source('inst/validation/gpcm-solution-stability-p0-0.2.3.R')
source('inst/validation/gpcm-zero-variance-boundary-p1c-0.2.3.R')

population_profile_context <- function(fit, variance, q) {
  sizes <- mfrmr:::build_param_sizes(fit$config)
  slices <- mfrmr:::build_param_slices(sizes)
  idx <- mfrmr:::build_indices(fit$prep, step_facet = fit$config$step_facet)
  evaluator <- mfrmr:::make_mfrm_direct_evaluator('MML',
    mfrmr:::make_param_cache(sizes, fit$config, idx, is_mml = TRUE),
    idx, fit$config, sizes, mfrmr:::gauss_hermite_normal(q))
  embed <- function(par) {
    par[slices$log_sigma2] <- if (variance == 0) 0 else log(variance)
    par
  }
  list(slices = slices, coordinates = data.frame(Index = seq_along(fit$opt$par)),
    fn = function(par) evaluator$value(embed(par)),
    gr = function(par) evaluator$gradient(embed(par)), raw = evaluator, embed = embed)
}

population_profile_reference <- function(case, par, variance) {
  par[length(par)] <- if (variance == 0) 0 else log(variance)
  if (!is.null(case$x)) {
    if (variance > 0) return(-sum(population_review_logp(case$x, par)))
    x <- case$x; lp <- environment(x$objective)$log_probability
    groups <- split(seq_len(nrow(x$data)), x$data$Person)
    return(-sum(vapply(groups, function(ix) {
      person <- match(x$data$Person[ix[1]], x$persons$Person)
      mu <- sum(c(1, x$persons$x[person]) * par[x$slices$beta])
      logp <- lp(mu, ix, par)
      sum(vapply(seq_along(ix), function(j) logp[[x$data$Score[ix[j]] + 1L]][1, j], numeric(1)))
    }, numeric(1))))
  }
  if (variance == 0) par[3] <- -Inf
  probability <- population_review_binary_prob(par, case$paired)
  counts <- if (case$paired) c(25, 5, 45, 25) else c(35, 15, 15, 35)
  -sum(counts * log(probability))
}

population_variance_profile <- function(directory) {
  pkgload::load_all('.', quiet = TRUE)
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  prior_path <- 'inst/validation/population-identifiability-review-evidence-0.2.4.rds'
  prior <- readRDS(prior_path)
  helpers <- c('population-variance-profile-0.2.4.R', 'population-identifiability-review-0.2.4.R',
    'mml-structural-bias-diagnostic-0.2.4.R', 'mml-structural-coverage-0.2.4.R',
    'mml-independent-information-conditions-0.2.4.R', 'mml-independent-rsm-information-0.2.4.R',
    'numerical-stationarity-pilot-0.2.3.R', 'gpcm-solution-stability-p0-0.2.3.R',
    'gpcm-zero-variance-boundary-p1c-0.2.3.R')
  paths <- c(list.files('R', pattern = '[.]R$', full.names = TRUE), prior_path,
    paste0('inst/validation/', helpers))
  payload <- tools::md5sum(paths)
  cases <- list()
  for (model in c('RSM', 'PCM')) {
    seed <- 20260909L + if (model == 'RSM') 2L else 8L
    cases[[model]] <- list(fit = prior$fresh[[model]]$fit,
      x = mml_information_fixture(model, 'population', 3L, seed))
  }
  for (paired in c(FALSE, TRUE)) cases[[if (paired) 'paired' else 'single']] <-
    list(fit = prior$controls[[as.character(paired)]]$fit, paired = paired)
  plan <- do.call(rbind, lapply(names(cases), function(id) {
    v <- sort(unique(c(0, 1e-6, .01, .1, .3, .5, 1, 2, 4, 16, 64,
      cases[[id]]$fit$population$sigma2)))
    do.call(rbind, lapply(v, function(value) expand.grid(Case = id, Variance = value,
      Q = if (value == 0) 1L else c(61L, 121L), Start = c('retained', 'zero'),
      stringsAsFactors = FALSE)))
  }))
  stopifnot(nrow(plan) == 184L)
  write.csv(plan, file.path(directory, 'plan.csv'), row.names = FALSE)
  results <- list(); rows <- list(); started <- Sys.time()
  for (i in seq_len(nrow(plan))) {
    p <- plan[i, ]; case <- cases[[p$Case]]; fit <- case$fit
    context <- population_profile_context(fit, p$Variance, p$Q)
    high <- population_profile_context(fit, p$Variance, if (p$Variance == 0) 1L else 241L)
    start <- if (p$Start == 'retained') fit$opt$par else rep(0, length(fit$opt$par))
    warnings <- character(); errors <- character()
    result <- tryCatch(withCallingHandlers({
      opt <- mfrmr_gzb_p1c_optimize_boundary(context, start, maxit = 400L, reltol = 1e-12)
      if (!opt$returned) stop('No finite nuisance vector returned.')
      par <- context$embed(opt$par)
      objective <- context$fn(par); dense <- high$fn(par)
      reference <- population_profile_reference(case, par, p$Variance)
      nuisance <- opt$nuisance_index
      dense_gradient <- high$gr(par)[nuisance]
      zero_invariance <- if (p$Variance == 0) {
        values <- vapply(c(-32, 0, 32), function(dummy) {
          copy <- par; copy[context$slices$log_sigma2] <- dummy
          context$raw$value(copy)
        }, numeric(1))
        max(abs(values - objective))
      } else NA_real_
      list(opt = opt, par = par, objective = objective, dense = dense,
        reference = reference, dense_gradient = dense_gradient, zero_invariance = zero_invariance)
    }, warning = function(w) {warnings <<- c(warnings, conditionMessage(w)); invokeRestart('muffleWarning')}),
      error = function(e) {errors <<- conditionMessage(e); NULL})
    row <- cbind(Row = i, p, Returned = !is.null(result), Objective = NA_real_,
      ReferenceObjective = NA_real_, Q241Objective = NA_real_, NuisanceGradient = NA_real_,
      Q241NuisanceGradient = NA_real_, NativePass = FALSE, ReferenceValueAgreement = FALSE,
      ZeroPlaceholderDifference = NA_real_, Seconds = NA_real_, Warnings = 0L, Error = '')
    if (!is.null(result)) {
      z <- result$opt
      warnings <- c(warnings, z$warnings)
      errors <- c(errors, z$errors[nzchar(z$errors)])
      row$Objective <- result$objective; row$ReferenceObjective <- result$reference
      row$Q241Objective <- result$dense
      row$NuisanceGradient <- z$selected$diagnostics$TerminalGradientSupNorm
      row$Q241NuisanceGradient <- max(abs(result$dense_gradient))
      row$NativePass <- identical(z$selected$diagnostics$ConvergenceSeverity, 'pass')
      row$ReferenceValueAgreement <- abs(result$objective - result$reference) <= 1e-6
      row$ZeroPlaceholderDifference <- result$zero_invariance; row$Seconds <- z$elapsed
    }
    row$Warnings <- length(warnings); row$Error <- paste(errors, collapse = ' | ')
    rows[[i]] <- row; results[[i]] <- list(result = result, warnings = warnings, errors = errors)
    saveRDS(results[[i]], file.path(directory, paste0('row-', i, '.rds')))
    cat(i, '/', nrow(plan), p$Case, 'variance', p$Variance, 'q', p$Q, p$Start,
        'pass', row$NativePass, 'reference', row$ReferenceValueAgreement, row$Error, '\n'); flush.console()
  }
  summary <- do.call(rbind, rows)
  envelope <- list(); selected <- list(); paths_zero <- list()
  keys <- unique(summary[c('Case', 'Variance', 'Q')])
  for (k in seq_len(nrow(keys))) {
    key <- keys[k, ]; at <- which(summary$Case == key$Case & summary$Variance == key$Variance &
      summary$Q == key$Q & summary$Returned)
    if (!length(at)) next
    best <- at[which.min(summary$Objective[at])]
    row <- summary[best, ]; row$StartObjectiveRange <- diff(range(summary$Objective[at]))
    row$IndependentGradient <- row$DerivativeStepDifference <- row$DerivativeVsQ241Difference <- NA_real_
    row$ContinuousNuisanceQualified <- FALSE
    if (key$Q %in% c(1L, 121L)) {
      z <- results[[best]]$result; case <- cases[[key$Case]]
      fn <- function(nuisance) {
        par <- z$par; par[z$opt$nuisance_index] <- nuisance
        population_profile_reference(case, par, key$Variance)
      }
      n <- z$par[z$opt$nuisance_index]
      derivatives <- tryCatch(list(coarse = mfrmr_num_central_gradient(fn, n, 1e-4),
        fine = mfrmr_num_central_gradient(fn, n, 5e-5)), error = identity)
      if (!inherits(derivatives, 'error')) {
        row$IndependentGradient <- max(abs(derivatives$fine))
        row$DerivativeStepDifference <- max(abs(derivatives$fine - derivatives$coarse))
        row$DerivativeVsQ241Difference <- max(abs(derivatives$fine - z$dense_gradient))
        row$ContinuousNuisanceQualified <- row$NativePass && row$ReferenceValueAgreement &&
          row$IndependentGradient <= 1e-4 && row$DerivativeStepDifference <= 1e-7 &&
          row$DerivativeVsQ241Difference <= 1e-7
      }
      selected[[as.character(best)]] <- derivatives
      if (key$Variance == 0) {
        paths_zero[[key$Case]] <- do.call(rbind, lapply(c(1e-6, 1e-5, 1e-4), function(v) {
          context <- population_profile_context(case$fit, v, 121L)
          value <- context$fn(z$par)
          data.frame(Case = key$Case, Variance = v, ZeroObjective = z$objective,
            Objective = value, DifferenceQuotient = (value - z$objective) / v)
        }))
      }
    }
    envelope[[k]] <- row
    cat('Envelope', key$Case, key$Variance, key$Q, row$ContinuousNuisanceQualified, '\n'); flush.console()
  }
  ridge <- do.call(rbind, lapply(unique(plan$Variance[plan$Case == 'single']), function(v) {
    b <- uniroot(function(b) population_review_binary_prob(c(b, 0, if (v == 0) -Inf else log(v)), FALSE)[2] - .3,
      c(0, 50), tol = 1e-12)$root
    value <- population_profile_reference(cases$single, c(b, 0, 0), v)
    bound <- -sum(c(35, 15, 15, 35) * log(c(.7, .3, .3, .7)))
    stopifnot(abs(value - bound) < 1e-10)
    data.frame(Variance = v, RaterDifficulty = b, Objective = value, SaturatedBound = bound)
  }))
  stopifnot(identical(payload, tools::md5sum(paths)))
  evidence <- list(plan = plan, summary = summary, envelope = do.call(rbind, envelope),
    zero_path = do.call(rbind, paths_zero), ridge = ridge, results = results,
    derivatives = selected, cases = cases, payload = payload,
    source = setNames(lapply(paths[endsWith(paths, '.R')], readLines), paths[endsWith(paths, '.R')]),
    design = readLines('inst/validation/population-variance-profile-record-0.2.4.md'),
    started = started, completed = Sys.time(), session = sessionInfo())
  saveRDS(evidence, file.path(directory, 'evidence.rds'), compress = 'xz')
  for (name in c('summary', 'envelope', 'zero_path', 'ridge'))
    write.csv(evidence[[name]], file.path(directory, paste0(name, '.csv')), row.names = FALSE)
  invisible(evidence)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE); stopifnot(length(args) == 1L)
  population_variance_profile(args[1])
}
