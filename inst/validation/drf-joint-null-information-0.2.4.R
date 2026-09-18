# Saved-fit diagnostic, not a fitting or inference API. Run from package root.
# Scope and bounds: interval-drf-preflight-protocol-0.2.4.md.
args <- commandArgs(TRUE)
stopifnot(length(args) == 2L, dir.exists(args[1]), dir.exists(args[2]))
pkgload::load_all('.', quiet = TRUE)
paths <- file.path(args[1], paste0(c('RSM-group_mean_only', 'PCM-group_mean_only',
  'RSM-drf', 'PCM-drf'), '-joint.rds'))
sources <- c(list.files('R', '[.]R$', full.names = TRUE),
  'inst/validation/drf-joint-null-information-0.2.4.R',
  'inst/validation/interval-drf-preflight-protocol-0.2.4.md')
hashes <- tools::md5sum(c(paths, sources))

# Independent constrained category model: no package expansion/probability helper.
pattern_logp <- function(par, map, model, design, patterns, group) {
  block <- function(name) par[map$OptimizerIndex[map$Block == name]]
  rater <- c(block('Rater'), -sum(block('Rater')))
  criterion <- c(block('Criterion'), -sum(block('Criterion')))
  gamma <- c(block('interactions'), -sum(block('interactions')))
  offset <- -rater[design$Rater] - criterion[design$Criterion] +
    gamma[design$Rater] * if (group == 'A') 1 else -1
  step <- block('steps')
  first_step <- if (model == 'RSM') rep(step, 6L) else step[design$Criterion]
  beta <- block('beta')
  mu <- beta[1] + beta[2] * (group == 'B')
  sd <- exp(block('log_sigma2') / 2)
  # The two step values per ladder sum to zero. Numerator's response-dependent
  # part is therefore y * offset - first_step * I(y == 1).
  constant <- as.vector(patterns %*% offset - (patterns == 1) %*% first_step)
  total <- rowSums(patterns)
  log_mass <- vapply(0:12, function(s) {
    log(integrate(function(theta) {
      eta <- outer(theta, offset, '+')
      one <- sweep(eta, 2L, first_step, '-')
      two <- 2 * eta
      hi <- pmax(0, one, two)
      normalizer <- rowSums(hi + log(exp(-hi) + exp(one-hi) + exp(two-hi)))
      exp(s * theta - normalizer) * dnorm(theta, mu, sd)
    }, -Inf, Inf, rel.tol = 1e-10, abs.tol = 1e-12, subdivisions = 200L)$value)
  }, numeric(1))
  constant + log_mass[total + 1L]
}
score_difference <- function(fn, par, h) {
  vapply(seq_along(par), function(j) {
    delta <- rep(0, length(par)); delta[j] <- h
    (fn(par + delta) - fn(par - delta)) / (2 * h)
  }, numeric(length(fn(par))))
}

results <- lapply(paths, function(path) {
  x <- readRDS(path); null <- x$fits$null; fit <- x$fits$alternative
  map <- fit$config$estimability_audit$mml_observed_pattern_score$parameter_map
  null_map <- null$config$estimability_audit$mml_observed_pattern_score$parameter_map
  at <- match(null_map$Coordinate, map$Coordinate)
  stopifnot(!anyNA(at), !anyDuplicated(map$Coordinate),
    identical(null_map$Constraint, map$Constraint[at]),
    identical(null_map$ReferenceLevel, map$ReferenceLevel[at]))
  par <- numeric(length(fit$opt$par))
  par[map$OptimizerIndex[at]] <- null$opt$par[null_map$OptimizerIndex]
  gamma <- map$OptimizerIndex[map$Block == 'interactions']
  nuisance <- setdiff(seq_along(par), gamma)
  stopifnot(length(gamma) == 2L, all(par[gamma] == 0),
    identical(sort(map$OptimizerIndex), seq_along(par)))
  sizes <- mfrmr:::build_param_sizes(fit$config)
  idx <- mfrmr:::build_indices(fit$prep, step_facet = fit$config$step_facet,
    interaction_specs = fit$config$interaction_specs)
  quad <- mfrmr:::gauss_hermite_normal(61L)
  embedding_error <- abs(-sum(mfrmr:::mfrmr_mml_person_log_marginals(
    par, idx, fit$config, sizes, quad)$log_marginal) - null$opt$value)
  package <- mfrmr:::mfrmr_mml_all_pattern_expected_information(
    par, idx, fit$config, sizes, quad)
  d <- fit$prep$data
  persons <- unique(d[c('Person', 'Group')])
  stopifnot(nrow(persons) == length(unique(d$Person)),
    all(table(d$Person) == 6L), all(d$Weight == 1), fit$config$n_cat == 3L,
    identical(fit$prep$levels$Group, c('A', 'B')))
  design <- expand.grid(Rater = 1:3, Criterion = 1:2)
  patterns <- as.matrix(expand.grid(rep(list(0:2), 6L)))
  design_key <- paste(fit$prep$levels$Rater[design$Rater],
    fit$prep$levels$Criterion[design$Criterion])
  info <- matrix(0, length(par), length(par))
  reference <- list(); probability_error <- score_error <- step_error <- 0
  independent_nll <- 0
  for (g in c('A', 'B')) {
    fn <- function(p) pattern_logp(p, map, fit$config$model, design, patterns, g)
    logp <- fn(par); probability <- exp(logp)
    score <- score_difference(fn, par, 5e-5)
    coarse <- score_difference(fn, par, 1e-4)
    n <- sum(persons$Group == g)
    info <- info + n * crossprod(score, score * probability)
    probability_error <- max(probability_error, abs(sum(probability) - 1))
    score_error <- max(score_error, abs(colSums(score * probability)))
    step_error <- max(step_error, abs(score - coarse))
    for (p in persons$Person[persons$Group == g]) {
      dp <- d[d$Person == p, ]
      order <- match(design_key, paste(dp$Rater, dp$Criterion))
      stopifnot(!anyNA(order), !anyDuplicated(order))
      row <- as.integer(1 + sum(dp$score_k[order] * 3^(0:5)))
      independent_nll <- independent_nll - logp[row]
    }
    reference[[g]] <- list(logp = logp, score = score, persons = n)
  }
  eig <- eigen(info, symmetric = TRUE, only.values = TRUE)$values
  ranks <- vapply(c(1e-12, 1e-10, 1e-8), function(tol)
    sum(eig > max(eig) * tol), integer(1))
  efficient <- info[gamma, gamma] - info[gamma, nuisance] %*%
    solve(info[nuisance, nuisance], info[nuisance, gamma])
  eff_eig <- eigen(efficient, symmetric = TRUE, only.values = TRUE)$values
  b <- x$comparison$comparison_basis
  checks <- c('same_method', 'all_mml', 'same_nobs', 'same_data',
    'all_inference_ready', 'all_current_contract', 'all_stored_ic_consistent',
    'all_ic_eligible', 'all_ic_selectable', 'same_ic_contract',
    'same_integration_evaluation', 'same_formula_contract', 'same_constraint_basis')
  row <- data.frame(Cell = sub('-joint.rds', '', basename(path), fixed = TRUE),
    EmbeddingError = embedding_error,
    ContinuousNLLError = abs(independent_nll - null$opt$value),
    ProbabilityError = probability_error, ExpectedScoreError = score_error,
    ScoreStepError = step_error,
    InformationError = max(abs(info - package$expected_information)),
    FreeDimension = length(par), MinimumRank = min(ranks), MaximumRank = max(ranks),
    MinInformationEigenvalue = min(eig), MinInteractionEigenvalue = min(eff_eig),
    MaxInteractionEigenvalue = max(eff_eig),
    UnmetComparisonChecks = paste(checks[!vapply(b[checks], isTRUE, logical(1))], collapse = ';'),
    NestingEligible = b$nesting_review$eligible, PublicLRTStatus = b$lrt_status)
  row$NumericalAgreement <- embedding_error <= 1e-8 && row$ContinuousNLLError <= 1e-5 &&
    probability_error <= 1e-9 && score_error <= 1e-7 && step_error <= 1e-7 &&
    row$InformationError <= 1e-5
  saveRDS(list(summary = row, null_coordinates = par, map = map, reference = reference,
    information = info, package_information = package$expected_information,
    eigenvalues = eig, ranks = ranks, efficient_information = efficient),
    file.path(args[2], basename(path)))
  print(row); flush.console()
  row
})
results <- do.call(rbind, results)
write.csv(results, file.path(args[2], 'summary.csv'), row.names = FALSE)
write.csv(data.frame(File = names(hashes), MD5 = unname(hashes)),
  file.path(args[2], 'source-input-md5.csv'), row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(args[2], 'session-info.txt'))
stopifnot(identical(hashes, tools::md5sum(names(hashes))))
