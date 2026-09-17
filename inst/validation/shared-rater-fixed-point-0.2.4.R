# Repository-only Series R reference; no estimation or posterior scoring.
# From development/: Rscript -e 'options(warn=2); source("inst/validation/shared-rater-fixed-point-0.2.4.R"); run_shared_rater_fixed_point()'
source('inst/validation/local-testlet-stress-0.2.4.R')

shared_rater_loglik <- function(response, beta, variance, order = 41L,
                               alpha = 0, tau1 = -.6, fixed_theta = NULL) {
  # Axes are person/rater/criterion. NA omits an observation, not its owner.
  shape <- dim(response)
  stopifnot(is.numeric(response), length(shape) == 3L, all(shape >= 1L),
    shape[2] <= 2L, all(is.na(response) | response %in% 0:2),
    is.numeric(beta), length(beta) == shape[3], all(is.finite(beta)),
    length(variance) == 1L, is.finite(variance), variance >= 0,
    length(alpha) == 1L, is.finite(alpha), length(tau1) == 1L, is.finite(tau1),
    length(order) == 1L, is.finite(order), order == as.integer(order),
    order >= 3L, order <= 121L)
  if (!is.null(fixed_theta)) stopifnot(is.numeric(fixed_theta),
    length(fixed_theta) == shape[1], all(is.finite(fixed_theta)))
  rule <- stress_normal_rule(order)
  # Zero variance removes the rater integral exactly, without a variance floor.
  u <- if (variance == 0) 0 else sqrt(variance) * rule$nodes
  uw <- if (variance == 0) 1 else rule$weights
  # ponytail: tensor reference limited to two raters; use a separately qualified
  # integration method before admitting a larger crossed design.
  grid <- as.matrix(expand.grid(rep(list(seq_along(u)), shape[2])))
  joint <- rowSums(matrix(log(uw[grid]), nrow(grid), shape[2]))
  for (p in seq_len(shape[1])) {
    theta <- if (is.null(fixed_theta)) rule$nodes else fixed_theta[p]
    tw <- if (is.null(fixed_theta)) rule$weights else 1
    conditional <- matrix(log(tw), length(theta), nrow(grid))
    for (r in seq_len(shape[2])) for (j in seq_len(shape[3])) {
      y <- response[p, r, j]
      if (is.na(y)) next
      eta <- as.vector(outer(theta, u, '-') + alpha - beta[j])
      logp <- matrix(log(local_testlet_probabilities(eta, tau1)[, y + 1L]), length(theta))
      conditional <- conditional + logp[, grid[, r], drop = FALSE]
    }
    # Sum person log likelihoods conditional on the SAME shared-rater grid.
    joint <- joint + apply(conditional, 2, stress_logsum)
  }
  loglik <- stress_logsum(joint)
  if (!is.finite(loglik)) stop('Non-finite log likelihood in bounded tensor reference')
  list(loglik = loglik, order = order)
}

run_shared_rater_fixed_point <- function() {
  prefix <- 'inst/validation/shared-rater-fixed-point-0.2.4'
  input <- '../research-notes/2026-09-17-random-effects-rating-design/model-sharing-check.json'
  python <- sub('[.]json$', '.py', input)
  saved <- jsonlite::fromJSON(input, simplifyVector = FALSE)
  fixture <- saved$shared_and_local_models
  # JSON varies criterion fastest; R varies the first array axis fastest.
  response <- aperm(array(unlist(fixture$responses), c(2L, 2L, 2L)), c(3, 2, 1))
  beta <- unlist(fixture$criterion_difficulties)
  stopifnot(identical(unname(response[1, , ]), rbind(c(0L, 0L), c(1L, 1L))),
    identical(unname(response[2, , ]), rbind(c(1L, 0L), c(2L, 1L))),
    identical(unlist(fixture$thresholds), c(-.6, .6)), fixture$person_sd == 1)
  output <- 'validation-results/shared-rater-fixed-point-20260917'
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  sources <- c(paste0(prefix, '.R'), 'inst/validation/local-testlet-stress-0.2.4.R',
    'inst/validation/local-testlet-tam-reference-0.2.4.R', input, python)
  provenance <- list(started = Sys.time(), sources = tools::md5sum(sources),
    plan = readLines(paste0(prefix, '.md')), session = sessionInfo(),
    parent = system2('git', 'rev-parse HEAD', stdout = TRUE))
  values <- checks <- list()
  evaluate <- function(id, y = response, variance = fixture$rater_sd^2,
                       order = 41L, fixed_theta = NULL) {
    elapsed <- system.time(value <- shared_rater_loglik(y, beta, variance, order,
      fixed_theta = fixed_theta))[['elapsed']]
    values[[id]] <<- data.frame(Case = id, Order = order, LogLik = value$loglik,
      Likelihood = exp(value$loglik), Seconds = elapsed)
    value$loglik
  }
  check <- function(id, error, tolerance) {
    checks[[length(checks) + 1L]] <<- data.frame(Check = id, Error = error,
      Tolerance = tolerance, Pass = is.finite(error) && error <= tolerance)
  }
  low <- evaluate('shared_q41')
  high <- evaluate('shared_q81', order = 81L)
  check('saved_python_q41_loglik', abs(low - log(fixture$q41$shared_rater_likelihood)), 1e-7)
  check('saved_python_q81_loglik', abs(high - log(fixture$q81$shared_rater_likelihood)), 1e-7)
  check('q41_q81_loglik', abs(low - high), 1e-7)
  zero <- evaluate('zero_rater_variance', variance = 0)
  check('saved_zero_variance_loglik', abs(zero - log(fixture$zero_rater_sd$shared_rater_likelihood)), 1e-7)
  # Direct one-dimensional reduction with no rater grid or shared wrapper.
  rule <- stress_normal_rule(41L)
  direct <- sum(vapply(1:2, function(p) {
    conditional <- log(rule$weights)
    for (r in 1:2) for (j in 1:2) conditional <- conditional +
      log(local_testlet_probabilities(rule$nodes - beta[j], -.6)[, response[p, r, j] + 1L])
    stress_logsum(conditional)
  }, numeric(1)))
  check('exact_zero_reduction', abs(zero - direct), 1e-12)
  check('rater_relabeling', abs(low - evaluate('rater_relabeling', response[, 2:1, , drop = FALSE])), 1e-12)
  check('person_relabeling', abs(low - evaluate('person_relabeling', response[2:1, , , drop = FALSE])), 1e-12)
  redrawn <- sum(vapply(1:2, function(p)
    evaluate(paste0('person_redrawn_', p), response[p, , , drop = FALSE], order = 81L), numeric(1)))
  check('saved_person_redrawn_loglik', abs(redrawn - log(fixture$q81$person_local_rater_likelihood)), 1e-7)
  check('shared_vs_redrawn_gap', abs(high - redrawn - fixture$q81$log_likelihood_difference), 1e-7)
  one <- saved$independent_integration_check
  one_response <- aperm(array(unlist(one$responses), c(2L, 1L, 2L)), c(3, 2, 1))
  fixed <- evaluate('one_rater_fixed_abilities', one_response, order = 81L,
    fixed_theta = unlist(one$fixed_abilities))
  check('saved_adaptive_one_rater_loglik', abs(fixed - log(one$shared_rater_quad)), 1e-7)
  empty <- response; empty[] <- NA_real_
  check('empty_data_loglik', abs(evaluate('empty_data', empty)), 1e-12)
  missing <- response; missing[, 2, ] <- NA_real_
  check('unobserved_rater_integrates_out', abs(evaluate('unobserved_rater', missing) -
    evaluate('observed_rater_only', response[, 1, , drop = FALSE])), 1e-12)
  rejected <- function(...) inherits(tryCatch(shared_rater_loglik(...), error = identity), 'error')
  invalid <- response; invalid[1, 1, 1] <- 3
  check('reject_invalid_category', as.integer(!rejected(invalid, beta, .49)), 0)
  check('reject_negative_variance', as.integer(!rejected(response, beta, -.1)), 0)
  check('reject_larger_tensor', as.integer(!rejected(array(0, c(2, 3, 2)), beta, .49)), 0)
  values <- do.call(rbind, values); rownames(values) <- NULL
  checks <- do.call(rbind, checks)
  saveRDS(list(provenance = provenance, input = saved, response = response,
    values = values, checks = checks, completed = Sys.time()), file.path(output, 'evidence.rds'))
  write.csv(values, paste0(prefix, '-values.csv'), row.names = FALSE)
  write.csv(checks, paste0(prefix, '-checks.csv'), row.names = FALSE)
  print(checks, row.names = FALSE)
  stopifnot(all(checks$Pass))
  invisible(checks)
}

if (sys.nframe() == 0L) run_shared_rater_fixed_point()
