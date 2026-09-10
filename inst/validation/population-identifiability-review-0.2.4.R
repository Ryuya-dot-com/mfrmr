# Repository-only local identification review; no readiness promotion.
source('inst/validation/mml-structural-bias-diagnostic-0.2.4.R')

population_review_logp <- function(x, par) {
  groups <- split(seq_len(nrow(x$data)), x$data$Person)
  lp <- environment(x$objective)$log_probability
  vapply(groups, function(ix) {
    person <- match(x$data$Person[ix[1]], x$persons$Person)
    mu <- sum(c(1, x$persons$x[person]) * par[x$slices$beta])
    sd <- exp(par[x$slices$log_sigma2] / 2)
    log(integrate(function(z) {
      logp <- lp(mu + sd * z, ix, par)
      observed <- vapply(seq_along(ix), function(j)
        logp[[x$data$Score[ix[j]] + 1L]][, j], numeric(length(z)))
      exp(rowSums(observed)) * dnorm(z)
    }, -Inf, Inf, rel.tol = 1e-11, abs.tol = 1e-13, subdivisions = 200L)$value)
  }, numeric(1))
}

population_review_control_data <- function(paired) {
  persons <- sprintf('P%03d', 1:100)
  if (paired) {
    d <- expand.grid(Person = persons, Rater = c('R1', 'R2'), stringsAsFactors = FALSE)
    d$Score <- c(rep(c(0, 0, 1, 1), c(25, 45, 5, 25)),
                 rep(c(0, 1, 0, 1), c(25, 45, 5, 25)))
    d
  } else data.frame(Person = persons, Rater = rep(c('R1', 'R2'), each = 50),
                    Score = c(rep(0, 35), rep(1, 15), rep(0, 15), rep(1, 35)))
}

population_review_binary_prob <- function(par, paired) {
  patterns <- if (paired) as.matrix(expand.grid(0:1, 0:1)) else matrix(0:1, ncol = 1)
  raters <- if (paired) list(c(1, -1)) else list(1, -1)
  unlist(lapply(raters, function(signs) apply(patterns, 1, function(y) {
    integrate(function(z) {
      probability <- plogis(outer(par[2] + exp(par[3] / 2) * z, -signs * par[1], '+'))
      probability[, y == 0] <- 1 - probability[, y == 0, drop = FALSE]
      apply(probability, 1, prod) * dnorm(z)
    }, -Inf, Inf, rel.tol = 1e-11, abs.tol = 1e-13, subdivisions = 200L)$value
  })), use.names = FALSE)
}

population_identifiability_review <- function() {
  pkgload::load_all('.', quiet = TRUE)
  prior_path <- 'inst/validation/mml-use-condition-audit-evidence-0.2.4.rds'
  paths <- c(list.files('R', pattern = '[.]R$', full.names = TRUE), prior_path,
    'inst/validation/population-identifiability-review-0.2.4.R',
    'inst/validation/mml-structural-bias-diagnostic-0.2.4.R',
    'inst/validation/mml-independent-information-conditions-0.2.4.R')
  payload <- tools::md5sum(paths)
  prior <- readRDS(prior_path)
  rows <- list(); details <- list(); fresh <- list(); controls <- list(); ridge <- list()
  started <- Sys.time()
  for (model in c('RSM', 'PCM')) {
    case <- prior$cases[[paste0(model, '-population')]]
    x <- mml_information_fixture(model, 'population', 3L, case$Seed)
    stopifnot(identical(x$data, case$Data))
    fn <- function(par) population_review_logp(x, par)
    for (q in c(31L, 61L, 121L)) {
      id <- paste0(model, '-q', q)
      fit <- prior$results[[paste0(model, '-population-q', q)]]$result$fit
      sizes <- mfrmr:::build_param_sizes(fit$config)
      stopifnot(identical(as.integer(unlist(sizes[sizes > 0])), as.integer(x$sizes)))
      idx <- mfrmr:::build_indices(fit$prep, step_facet = fit$config$step_facet)
      package <- mfrmr:::mfrmr_mml_observed_person_score_matrix(
        fit$opt$par, idx, fit$config, sizes, mfrmr:::gauss_hermite_normal(q))
      reference <- mml_bias_pattern_score(fn, fit$opt$par, 1e-4)
      fine <- mml_bias_pattern_score(fn, fit$opt$par, 5e-5)
      ord <- match(fit$prep$levels$Person[package$person_ids], rownames(fine))
      stopifnot(!anyNA(ord))
      fine <- fine[ord, , drop = FALSE]; reference <- reference[ord, , drop = FALSE]
      singular <- svd(fine, nu = 0L, nv = 0L)$d
      ranks <- vapply(c(1e-12, 1e-10, 1e-8), function(t) sum(singular > t * max(singular)), integer(1))
      local <- fit$data_review$estimability$nonlinear_local_estimability
      row <- data.frame(Model = model, Q = q, FreeDimension = ncol(fine),
        FixedQRank = local$local_rank, ContinuousRank = min(ranks),
        SmallestSingularValue = min(singular), ConditionNumber = max(singular) / min(singular),
        ScoreVsFixedQMaxAbs = max(abs(fine - package$score)),
        DifferenceStepMaxAbs = max(abs(fine - reference)),
        ObjectiveVsFixedQAbs = abs(-sum(fn(fit$opt$par)) - fit$opt$value),
        FullPatternStatus = fit$data_review$estimability$mml_all_pattern_information$status)
      row$ContinuousRankStable <- all(ranks == ncol(fine))
      row$NumericalAgreement <- row$ScoreVsFixedQMaxAbs < 1e-7 &&
        row$DifferenceStepMaxAbs < 1e-7 && row$ObjectiveVsFixedQAbs < 1e-6
      # Retain disagreements at the original bounds and continue other grids.
      stopifnot(all(is.finite(fine)), row$DifferenceStepMaxAbs < 1e-7)
      rows[[id]] <- row; details[[id]] <- list(reference = fine, coarser = reference,
        package = package, singular_values = singular, tolerance_ranks = ranks)
      cat(id, ': local rank', row$ContinuousRank, '/', row$FreeDimension,
          '; score discrepancy', row$ScoreVsFixedQMaxAbs, '\n'); flush.console()
    }
    warnings <- character()
    fit <- withCallingHandlers(do.call(fit_mfrm, c(list(data = x$data, person = 'Person',
      facets = c('Rater', 'Criterion'), score = 'Score', model = model, method = 'MML',
      step_facet = if (model == 'PCM') 'Criterion' else NULL, rating_min = 0, rating_max = 2,
      quad_points = 61L, maxit = 200L, reltol = 1e-10, mml_engine = 'direct'), x$extra)),
      warning = function(w) {warnings <<- c(warnings, conditionMessage(w)); invokeRestart('muffleWarning')})
    diagnostic <- diagnose_mfrm(fit, residual_pca = 'none')
    stopifnot(!mfrmr:::mfrm_inference_ready(fit), !diagnostic$precision_profile$SupportsFormalInference,
      grepl('design_rank_not_evaluated', fit$readiness$fit$ReasonCodes),
      fit$data_review$estimability$nonlinear_local_estimability$local_full_rank_sufficient,
      inherits(tryCatch(analyze_facet_equivalence(fit), error = identity), 'error'))
    fresh[[model]] <- list(fit = fit, diagnostic = diagnostic, warnings = warnings)
  }
  for (paired in c(FALSE, TRUE)) {
    d <- population_review_control_data(paired); warnings <- character()
    fit <- withCallingHandlers(fit_mfrm(d, 'Person', 'Rater', 'Score', method = 'MML',
      population_formula = ~ 1, person_data = unique(d['Person']), rating_min = 0,
      rating_max = 1, quad_points = 61L, maxit = 300L, reltol = 1e-10),
      warning = function(w) {warnings <<- c(warnings, conditionMessage(w)); invokeRestart('muffleWarning')})
    a <- fit$data_review$estimability
    expected <- if (paired) 3L else 2L
    stopifnot(a$readiness$Rank == 2L, a$nonlinear_local_estimability$local_rank == expected,
      !mfrmr:::mfrm_inference_ready(fit), a$mml_all_pattern_information$local_rank == expected)
    controls[[as.character(paired)]] <- list(fit = fit, warnings = warnings)
    sizes <- mfrmr:::build_param_sizes(fit$config)
    idx <- mfrmr:::build_indices(fit$prep)
    for (variance in c(1e-6, .1, 1, 4)) {
      b <- uniroot(function(b) population_review_binary_prob(c(b, 0, log(variance)), FALSE)[2] - .3,
                   c(0, 10), tol = 1e-12)$root
      par <- c(b, 0, log(variance))
      probability <- population_review_binary_prob(par, paired)
      score <- mml_bias_pattern_score(function(p) log(population_review_binary_prob(p, paired)), par)
      package <- mfrmr:::mfrmr_mml_all_pattern_expected_information(par, idx, fit$config,
        sizes, mfrmr:::gauss_hermite_normal(121L))
      information <- crossprod(score, score * probability) * if (paired) 100 else 50
      eig <- eigen(package$expected_information, symmetric = TRUE, only.values = TRUE)$values
      state <- mfrmr:::audit_mfrm_mml_all_pattern_information(list(par = par), fit$prep,
        idx, fit$config, sizes, 121L, 'log_sigma2')
      row <- data.frame(Paired = paired, Variance = variance, RaterDifficulty = b,
        P_R1 = if (paired) sum(probability[c(2, 4)]) else probability[2],
        P_R2 = if (paired) sum(probability[c(3, 4)]) else probability[4],
        P_BothOne = if (paired) probability[4] else NA_real_,
        LocalRank = state$local_rank, FreeDimension = state$free_dimension,
        MinimumInformationEigenvalue = min(eig),
        InformationVsIndependentMaxAbs = max(abs(information - package$expected_information)),
        LogVarianceInformationGivenNuisance = if (paired) {
          v <- package$expected_information
          as.numeric(v[3, 3] - v[3, 1:2] %*% solve(v[1:2, 1:2], v[1:2, 3]))
        } else NA_real_)
      stopifnot(abs(row$P_R1 - .3) < 1e-10, abs(row$P_R2 - .7) < 1e-10,
                row$InformationVsIndependentMaxAbs < 1e-6, row$LocalRank == expected)
      id <- paste(paired, variance, sep = '-')
      ridge[[id]] <- row
      controls[[as.character(paired)]][[as.character(variance)]] <- list(par = par,
        probability = probability, score = score, independent_information = information,
        package = package, audit = state)
    }
  }
  stopifnot(identical(payload, tools::md5sum(paths)))
  evidence <- list(summary = do.call(rbind, rows), ridge = do.call(rbind, ridge),
    details = details, fresh = fresh, controls = controls, payload = payload,
    source = setNames(lapply(paths[endsWith(paths, '.R')], readLines), paths[endsWith(paths, '.R')]),
    started = started, completed = Sys.time(), session = sessionInfo())
  prefix <- 'inst/validation/population-identifiability-review'
  write.csv(evidence$summary, paste0(prefix, '-summary-0.2.4.csv'), row.names = FALSE)
  write.csv(evidence$ridge, paste0(prefix, '-controls-0.2.4.csv'), row.names = FALSE)
  saveRDS(evidence, paste0(prefix, '-evidence-0.2.4.rds'), compress = 'xz')
  invisible(evidence)
}

if (sys.nframe() == 0L) population_identifiability_review()
