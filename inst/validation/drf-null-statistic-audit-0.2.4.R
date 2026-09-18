# Repository-only deterministic reference; run from the package root.
# See the September 18 addendum in interval-drf-preflight-protocol-0.2.4.md.
out <- commandArgs(TRUE)[1L]
stopifnot(!is.na(out), dir.exists(out))
integral <- function(f) integrate(f, -Inf, Inf, rel.tol = 1e-10,
  abs.tol = 1e-12, subdivisions = 200L)$value
design <- expand.grid(Rater = 1:3, Criterion = 1:2)
difficulty <- c(-.4, 0, .4)[design$Rater] + c(-.3, .3)[design$Criterion]
patterns <- as.matrix(expand.grid(rep(list(0:1), 6L)))
by_group <- lapply(c(A = 0, B = .6), function(mu) {
  # The posterior depends on the binary Rasch total. Keep each pattern's
  # probability factor exp(-sum(y * difficulty)) when averaging patterns.
  posterior <- lapply(0:6, function(total) {
    weight <- function(theta) {
      eta <- outer(theta, difficulty, '-')
      log_denom <- rowSums(pmax(eta, 0) + log1p(exp(-abs(eta))))
      exp(theta * total - log_denom) * dnorm(theta, mu, 1)
    }
    mass <- integral(weight)
    eap <- integral(function(theta) theta * weight(theta)) / mass
    integrated <- vapply(difficulty, function(b) {
      integral(function(theta) plogis(theta - b) * weight(theta)) / mass
    }, numeric(1))
    list(mass = mass, eap = eap, integrated = integrated)
  })
  probability <- numeric(nrow(patterns))
  residual <- integrated_residual <- proxy <- matrix(0, nrow(patterns), 3L)
  for (i in seq_len(nrow(patterns))) {
    y <- patterns[i, ]; p <- posterior[[sum(y) + 1L]]
    probability[i] <- p$mass * exp(-sum(y * difficulty))
    expected <- plogis(p$eap - difficulty)
    for (r in 1:3) {
      at <- design$Rater == r
      residual[i, r] <- mean(y[at] - expected[at])
      integrated_residual[i, r] <- mean(y[at] - p$integrated[at])
      proxy[i, r] <- sum(expected[at] * (1 - expected[at])) / sum(at)^2
    }
  }
  mean_residual <- as.vector(crossprod(probability, residual))
  centered <- sweep(residual, 2L, mean_residual)
  covariance <- crossprod(centered, centered * probability)
  list(probability = probability, residual = residual,
    integrated_residual = integrated_residual,
    mean = mean_residual,
    integrated_mean = as.vector(crossprod(probability, integrated_residual)),
    covariance = covariance, proxy = as.vector(crossprod(probability, proxy)))
})
rows <- do.call(rbind, lapply(names(by_group), function(g) {
  x <- by_group[[g]]
  data.frame(Group = g, Rater = paste0('R', 1:3),
    EAPResidualMean = x$mean, IntegratedResidualMean = x$integrated_mean,
    ActualPersonResidualVariance = diag(x$covariance),
    ExpectedVarianceProxy = x$proxy, ProbabilitySum = sum(x$probability))
}))
contrasts <- data.frame(Rater = paste0('R', 1:3),
  ExpectedEAPContrastAminusB = by_group$A$mean - by_group$B$mean,
  ExpectedIntegratedContrastAminusB = by_group$A$integrated_mean - by_group$B$integrated_mean,
  EqualGroupVarianceProxyRatio = (by_group$A$proxy + by_group$B$proxy) /
    (diag(by_group$A$covariance) + diag(by_group$B$covariance)))
saveRDS(by_group, file.path(out, 'enumeration.rds'))
write.csv(rows, file.path(out, 'enumeration-moments.csv'), row.names = FALSE)
write.csv(contrasts, file.path(out, 'enumeration-contrasts.csv'), row.names = FALSE)
stopifnot(all(abs(rows$ProbabilitySum - 1) < 1e-9),
  all(abs(rows$IntegratedResidualMean) < 1e-9))
print(rows, row.names = FALSE)
print(contrasts, row.names = FALSE)

# Reuse existing data and existing public fitting/comparison APIs.
pkgload::load_all('.', quiet = TRUE)
continuous_nll <- function(fit, data) {
  effects <- fit$facets$others
  offset <- rep(0, nrow(data))
  for (facet in c('Rater', 'Criterion', 'Group')) {
    tab <- effects[effects$Facet == facet, ]
    offset <- offset - tab$Estimate[match(data[[facet]], tab$Level)]
  }
  interaction <- fit$interactions$effects
  if (!is.null(interaction) && nrow(interaction)) {
    key <- paste(interaction$FacetA_Level, interaction$FacetB_Level)
    offset <- offset + interaction$Estimate[match(paste(data$Rater, data$Group), key)]
  }
  steps <- fit$steps
  profiles <- if (fit$config$model == 'RSM') list(Common = steps$Estimate) else {
    split(steps$Estimate, steps$StepFacet)
  }
  cumulative <- t(vapply(profiles, function(z) c(0, cumsum(z)), numeric(3)))
  owner <- if (fit$config$model == 'RSM') rep(1L, nrow(data)) else {
    match(data$Criterion, names(profiles))
  }
  score <- data$Score - 1L
  beta <- fit$population$coefficients
  sigma <- sqrt(fit$population$sigma2)
  -sum(vapply(split(seq_len(nrow(data)), data$Person), function(at) {
    mu <- beta['(Intercept)'] + beta['GroupB'] * (data$Group[at[1L]] == 'B')
    integral(function(theta) {
      eta <- outer(theta, offset[at], '+')
      lp1 <- sweep(eta, 2L, cumulative[owner[at], 2L], '-')
      lp2 <- sweep(2 * eta, 2L, cumulative[owner[at], 3L], '-')
      hi <- pmax(0, lp1, lp2)
      normalizer <- hi + log(exp(-hi) + exp(lp1 - hi) + exp(lp2 - hi))
      observed <- sweep(eta, 2L, score[at], '*')
      observed <- sweep(observed, 2L, cumulative[cbind(owner[at], score[at] + 1L)], '-')
      exp(rowSums(observed - normalizer)) * dnorm(theta, mu, sigma)
    }) |> log()
  }, numeric(1)))
}
cells <- as.vector(outer(c('RSM', 'PCM'), c('group_mean_only', 'drf'), paste, sep = '-'))
paths <- file.path('inst/validation/drf-execution-preflight-0.2.4/final', paste0(cells, '.rds'))
saved_hash <- tools::md5sum(paths)
files <- c(list.files('R', '[.]R$', full.names = TRUE),
  'inst/validation/drf-null-statistic-audit-0.2.4.R',
  'inst/validation/interval-drf-preflight-protocol-0.2.4.md')
source_hash <- tools::md5sum(files)
runs <- lapply(seq_along(cells), function(i) {
  cell <- cells[i]; x <- readRDS(paths[i]); d <- x$data
  model <- x$fit$config$model; fits <- list(); cmp <- NULL
  warnings <- character(); error <- ''; reference <- rep(NA_real_, 2L)
  started <- proc.time()[['elapsed']]
  tryCatch(withCallingHandlers({
    args <- list(data = d, person = 'Person', facets = c('Rater', 'Criterion', 'Group'),
      score = 'Score', model = model, method = 'MML', rating_min = 1, rating_max = 3,
      step_facet = if (model == 'PCM') 'Criterion' else NULL,
      dummy_facets = 'Group', population_formula = ~ Group,
      person_data = unique(d[c('Person', 'Group')]),
      quad_points = 61L, maxit = 200L, reltol = 1e-10)
    fits$null <- do.call(fit_mfrm, args)
    args$facet_interactions <- 'Rater:Group'
    fits$alternative <- do.call(fit_mfrm, args)
    cmp <- compare_mfrm(fits$null, fits$alternative, labels = c('Null', 'DRF'), nested = TRUE)
    reference <- vapply(fits, continuous_nll, numeric(1), data = d)
  }, warning = function(w) {
    warnings <<- c(warnings, conditionMessage(w)); invokeRestart('muffleWarning')
  }), error = function(e) error <<- conditionMessage(e))
  saveRDS(list(data_path = paths[i], fits = fits, comparison = cmp,
    reference_nll = reference, warnings = warnings, error = error),
    file.path(out, paste0(cell, '-joint.rds')))
  complete <- length(fits) == 2L
  row <- data.frame(Cell = cell, Error = error, Warnings = paste(warnings, collapse = ' | '),
    NullReady = complete && isTRUE(fits$null$readiness$fit$InferenceReady),
    AlternativeReady = complete && isTRUE(fits$alternative$readiness$fit$InferenceReady),
    NullReason = if (complete) fits$null$readiness$fit$ReasonCodes else NA_character_,
    AlternativeReason = if (complete) fits$alternative$readiness$fit$ReasonCodes else NA_character_,
    AddedParameters = if (complete) length(fits$alternative$opt$par) - length(fits$null$opt$par) else NA_integer_,
    MaxNLLDifference = if (complete && all(is.finite(reference))) {
      max(abs(reference - vapply(fits, function(f) f$opt$value, numeric(1))))
    } else NA_real_,
    LRStatistic = if (complete) 2 * (fits$null$opt$value - fits$alternative$opt$value) else NA_real_,
    PublicLRTStatus = if (!is.null(cmp)) cmp$comparison_basis$lrt_status else NA_character_,
    Seconds = proc.time()[['elapsed']] - started)
  print(row); flush.console()
  row
})
runs <- do.call(rbind, runs)
write.csv(runs, file.path(out, 'joint-runs.csv'), row.names = FALSE)
write.csv(data.frame(File = paths, MD5 = unname(saved_hash)), file.path(out, 'saved-md5.csv'), row.names = FALSE)
write.csv(data.frame(File = files, MD5 = unname(source_hash)), file.path(out, 'source-md5.csv'), row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(out, 'session-info.txt'))
stopifnot(identical(saved_hash, tools::md5sum(paths)), identical(source_hash, tools::md5sum(files)),
  all(runs$Error == ''), all(runs$AddedParameters == 2L), all(runs$MaxNLLDifference <= 1e-5))
