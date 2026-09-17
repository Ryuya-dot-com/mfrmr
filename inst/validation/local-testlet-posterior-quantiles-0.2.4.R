# Conditional research intervals; calibration is held fixed throughout.
source('inst/validation/local-testlet-estimation-0.2.4.R')

testlet_log_row_sum <- function(x) {
  largest <- do.call(pmax, lapply(seq_len(ncol(x)), function(j) x[, j]))
  largest + log(rowSums(exp(x - largest)))
}

testlet_person_likelihood_function <- function(fixture, par, person, order) {
  rule <- stress_normal_rule(order)
  gamma <- if (par[6] == 0) 0 else sqrt(par[6]) * rule$nodes
  logweights <- if (par[6] == 0) 0 else log(rule$weights)
  response <- fixture$response[person, ]
  offsets <- vapply(seq_along(response), function(i) par[1] -
    sum(fixture$criterion_contrasts[fixture$map$Criterion[i], ] * par[2:3]) -
    fixture$rater_contrasts[fixture$map$Rater[i]] * par[4], numeric(1))
  function(theta) {
    latent <- outer(theta, gamma, '+')
    out <- numeric(length(theta))
    for (r in 1:2) {
      conditional <- matrix(0, length(theta), length(gamma))
      for (i in which(fixture$map$Rater == r & !is.na(response))) {
        eta <- latent + offsets[i]
        largest <- pmax(eta - par[5], 2 * eta, 0)
        logden <- largest + log(exp(-largest) + exp(eta - par[5] - largest) + exp(2 * eta - largest))
        conditional <- conditional + response[i] * eta - (response[i] == 1) * par[5] - logden
      }
      out <- out + testlet_log_row_sum(sweep(conditional, 2, logweights, '+'))
    }
    out
  }
}

testlet_posterior_density_function <- function(target, local_order, midpoint_order) {
  likelihood <- lapply(target$persons, function(p)
    testlet_person_likelihood_function(target$fixture, target$par, p, local_order))
  if (length(likelihood) == 1L) return(function(x)
    exp(dnorm(x, log = TRUE) + likelihood[[1]](x) - target$lognormalizer))
  rule <- stress_normal_rule(midpoint_order)
  midpoint <- rule$nodes / sqrt(2)
  function(d) {
    plus <- outer(d / 2, midpoint, '+')
    minus <- outer(-d / 2, midpoint, '+')
    loglik <- matrix(likelihood[[1]](as.vector(plus)) + likelihood[[2]](as.vector(minus)),
      length(d), length(midpoint))
    exp(dnorm(d, sd = sqrt(2), log = TRUE) +
      testlet_log_row_sum(sweep(loglik, 2, log(rule$weights), '+')) - target$lognormalizer)
  }
}

testlet_continuous_posterior <- function(density, center, sd) {
  history <- list()
  integral <- function(f, lower, upper, label) {
    result <- integrate(f, lower, upper, rel.tol = 1e-9, abs.tol = 1e-9, subdivisions = 200L)
    history[[length(history) + 1L]] <<- list(label = label, lower = lower, upper = upper,
      value = result$value, absolute_error = result$abs.error, subdivisions = result$subdivisions,
      message = result$message)
    result$value
  }
  full <- function(f, label) integral(f, -Inf, center, label) + integral(f, center, Inf, label)
  mass <- full(density, 'mass')
  stopifnot(is.finite(mass), mass > 0)
  shift <- full(function(x) (x - center) * density(x), 'centered_first_moment') / mass
  variance <- full(function(x) (x - center)^2 * density(x), 'centered_second_moment') / mass - shift^2
  stopifnot(variance > 0)
  cdf <- function(x) vapply(x, function(t) {
    if (t <= center) integral(density, -Inf, t, 'cdf_left') / mass
    else 1 - integral(density, t, Inf, 'cdf_right') / mass
  }, numeric(1))
  probs <- c(.025, .5, .975)
  quantiles <- vapply(probs, function(p) uniroot(function(x) cdf(x) - p,
    c(center - 10 * sd, center + 10 * sd), tol = 1e-8)$root, numeric(1))
  normal <- center + c(-1, 1) * qnorm(.975) * sd
  normal_cdf <- cdf(normal)
  points <- sort(c(quantiles, normal))
  list(mass = mass, mean = center + shift, sd = sqrt(variance), quantiles = quantiles,
    quantile_cdf = cdf(quantiles), normal = normal, normal_cdf = normal_cdf,
    points = points, point_cdf = cdf(points), cdf = cdf, history = function() history)
}

run_testlet_posterior_quantiles <- function() {
  prefix <- 'inst/validation/local-testlet-posterior-quantiles-0.2.4'
  output <- 'validation-results/local-testlet-posterior-quantiles-20260917'
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  input <- 'inst/validation/local-testlet-information-0.2.4-evidence.rds'
  saved <- readRDS(input)
  targets <- list()
  for (case in saved$plan$cases) {
    value <- testlet_estimation_evaluate(case$fixture, case$fit$par, 181L)
    add <- function(persons, label) {
      moments <- case$fit$moments[persons, 1:2, drop = FALSE]
      targets[[paste(case$id, label, sep = '_')]] <<- list(case = case$id, fixture = case$fixture,
        par = case$fit$par, persons = persons, lognormalizer = sum(value$person_loglik[persons]),
        center = if (length(persons) == 1) moments[1, 1] else moments[1, 1] - moments[2, 1],
        sd = sqrt(sum(moments[, 2]^2)), exact_normal = FALSE)
    }
    for (p in 1:6) add(p, paste0('P', p))
    if (case$id == 'original') { add(c(1, 2), 'P1_minus_P2'); add(c(4, 5), 'P4_minus_P5') }
    if (case$id == 'clustered') add(c(4, 5), 'P4_minus_P5')
    if (case$id == 'boundary') add(c(1, 2), 'P1_minus_P2')
  }
  missing <- saved$plan$cases$original$fixture
  missing$response <- missing$response[1:2, , drop = FALSE]
  missing$response[] <- NA_real_
  for (n in 1:2) targets[[paste0('missing_', n)]] <- list(case = 'missing', fixture = missing,
    par = saved$plan$cases$original$fit$par, persons = seq_len(n), lognormalizer = 0,
    center = 0, sd = sqrt(n), exact_normal = TRUE)
  rules <- rbind(c(61L, 41L), c(121L, 81L), c(181L, 121L), c(241L, 181L))
  sources <- tools::md5sum(c(paste0(prefix, '.R'),
    'inst/validation/local-testlet-estimation-0.2.4.R', 'inst/validation/local-testlet-stress-0.2.4.R',
    'inst/validation/local-testlet-tam-reference-0.2.4.R'))
  plan <- list(targets = targets, rules = rules, sources = sources, input = tools::md5sum(input),
    design = readLines(paste0(prefix, '.md')), started = Sys.time(),
    parent = system2('git', 'rev-parse HEAD', stdout = TRUE), session = sessionInfo())
  saveRDS(plan, file.path(output, 'plan.rds'))
  checks <- results <- rows <- list()
  check <- function(id, quantity, error, tolerance) {
    checks[[length(checks) + 1L]] <<- data.frame(Target = id, Quantity = quantity,
      Error = error, Tolerance = tolerance, Pass = is.finite(error) && error <= tolerance)
    write.csv(do.call(rbind, checks), paste0(prefix, '-checks.csv'), row.names = FALSE)
  }
  for (id in names(targets)) {
    target <- targets[[id]]
    attempts <- list()
    previous <- selected <- NULL
    for (k in seq_len(nrow(rules))) {
      cat('QUANTILES', id, 'local', rules[k, 1], 'midpoint', rules[k, 2], '\n')
      captured <- stress_capture({
        density <- testlet_posterior_density_function(target, rules[k, 1], rules[k, 2])
        fit <- testlet_continuous_posterior(density, target$center, target$sd)
        comparison <- if (is.null(previous)) rep(Inf, 3) else c(
          max(abs(c(fit$mass - previous$mass, fit$mean - previous$mean, fit$sd - previous$sd))),
          max(abs(fit$cdf(previous$quantiles) - c(.025, .5, .975))),
          max(abs(fit$quantiles - previous$quantiles)))
        answer <- fit[!names(fit) %in% c('cdf', 'history')]
        answer$integration <- fit$history()
        answer$comparison <- comparison
        answer$moment_error <- max(abs(c(fit$mean - target$center, fit$sd - target$sd)))
        answer$qualified <- all(comparison <= c(1e-7, 1e-7, 1e-5)) &&
          abs(fit$mass - 1) <= 1e-7 && answer$moment_error <= 1e-6
        answer
      })
      attempts[[k]] <- list(rule = rules[k, ], captured = captured)
      saveRDS(list(target = target, attempts = attempts, sources = sources), file.path(output, paste0(id, '.rds')))
      if (!is.null(captured$value) && !length(captured$warnings)) {
        if (captured$value$qualified) { selected <- attempts[[k]]; break }
        previous <- captured$value
      }
    }
    results[[id]] <- list(target = target, attempts = attempts, selected = selected)
    check(id, 'resolved_density_and_quantiles', if (!is.null(selected)) 0 else Inf, 0)
    if (is.null(selected)) next
    value <- selected$captured$value
    check(id, 'posterior_mass', abs(value$mass - 1), 1e-7)
    check(id, 'moments', value$moment_error, 1e-6)
    check(id, 'quantile_cdf', max(abs(value$quantile_cdf - c(.025, .5, .975))), 1e-7)
    check(id, 'cdf_monotonicity', max(0, -diff(value$point_cdf)), 1e-10)
    if (target$exact_normal) check(id, 'exact_normal_quantiles',
      max(abs(value$quantiles - qnorm(c(.025, .5, .975), sd = target$sd))), 1e-6)
    rows[[id]] <- data.frame(Target = id, Kind = if (length(target$persons) == 1) 'person' else 'difference',
      Mean = value$mean, SD = value$sd, Lower = value$quantiles[1], Median = value$quantiles[2],
      Upper = value$quantiles[3], NormalLower = value$normal[1], NormalUpper = value$normal[2],
      NormalPosteriorMass = diff(value$normal_cdf), NormalLeftTail = value$normal_cdf[1],
      NormalRightTail = 1 - value$normal_cdf[2], MaxEndpointDifference = max(abs(value$quantiles[c(1, 3)] - value$normal)),
      LocalOrder = selected$rule[1], MidpointOrder = if (length(target$persons) == 2) selected$rule[2] else NA_integer_,
      CalibrationKnown = TRUE, EstimatedCalibrationIntervalAvailable = FALSE)
    write.csv(do.call(rbind, rows), paste0(prefix, '-intervals.csv'), row.names = FALSE)
  }
  for (id in c('original_P1_minus_P2', 'original_P4_minus_P5')) {
    entry <- results[[id]]
    if (is.null(entry$selected)) next
    target <- entry$target
    selected <- entry$selected
    value <- selected$captured$value
    extra <- stress_capture({
      density <- testlet_posterior_density_function(target, selected$rule[1], selected$rule[2])
      reversed <- target
      reversed$persons <- rev(target$persons)
      reverse_density <- testlet_posterior_density_function(reversed, selected$rule[1], selected$rule[2])
      reflection <- max(abs(density(-value$quantiles) - reverse_density(value$quantiles)))
      make_person <- function(p) {
        person <- results[[paste0('original_P', p)]]
        f <- testlet_posterior_density_function(person$target, selected$rule[1], selected$rule[2])
        function(x) f(x) / person$selected$captured$value$mass
      }
      fp <- make_person(target$persons[1])
      fq <- make_person(target$persons[2])
      inner_errors <- numeric()
      convolution <- integrate(function(t) fq(t) * vapply(t, function(x) {
        z <- integrate(fp, -Inf, x, rel.tol = 1e-7, abs.tol = 1e-7, subdivisions = 200L)
        inner_errors <<- c(inner_errors, z$abs.error)
        z$value
      }, numeric(1)), -Inf, Inf, rel.tol = 1e-6, abs.tol = 1e-6, subdivisions = 200L)
      direct <- integrate(density, -Inf, 0, rel.tol = 1e-9, abs.tol = 1e-9, subdivisions = 200L)
      list(reflection = reflection, convolution = convolution[c('value', 'abs.error', 'subdivisions', 'message')],
        direct = direct$value / value$mass, direct_error = direct$abs.error,
        inner_error_max = max(inner_errors), inner_calls = length(inner_errors))
    })
    results[[id]]$independent <- extra
    saveRDS(extra, file.path(output, paste0(id, '-independent.rds')))
    check(id, 'independent_capture', if (!is.null(extra$value) && !length(extra$warnings)) 0 else Inf, 0)
    if (!is.null(extra$value)) {
      check(id, 'reversed_density', extra$value$reflection, 1e-8)
      check(id, 'convolution_cdf_at_zero', abs(extra$value$convolution$value - extra$value$direct), 1e-5)
    }
  }
  check('provenance', 'source_and_input_identity', if (identical(sources, tools::md5sum(names(sources))) &&
    identical(plan$input, tools::md5sum(input))) 0 else Inf, 0)
  completed <- list(plan = plan, results = results, intervals = do.call(rbind, rows),
    checks = do.call(rbind, checks), finished = Sys.time())
  saveRDS(completed, file.path(output, 'completed.rds'))
  saveRDS(completed, paste0(prefix, '-evidence.rds'))
  print(completed$intervals)
  print(table(completed$checks$Pass))
  stopifnot(all(completed$checks$Pass))
}

if (sys.nframe() == 0L) run_testlet_posterior_quantiles()
