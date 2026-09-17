# Post-screen boundary diagnosis; retains the original two fixtures and results.
source('inst/validation/local-testlet-estimation-0.2.4.R')

run_estimation_boundary <- function() {
  output <- 'validation-results/local-testlet-estimation-20260917'
  plan <- readRDS(file.path(output, 'plan.rds'))
  fixture <- local_testlet_fixture()
  permutations <- rbind(c(0,1,2), c(0,2,1), c(1,0,2), c(1,2,0), c(2,0,1), c(2,1,0))
  fixture$response[] <- cbind(permutations, permutations)
  sources <- tools::md5sum(c('inst/validation/local-testlet-estimation-boundary-0.2.4.R', names(plan$sources)))
  runs <- list()
  for (id in names(plan$starts)) {
    cat('BOUNDARY', id, '\n')
    runs[[id]] <- testlet_bounded_fit(fixture, plan$starts[[id]])
    saveRDS(list(fixture = fixture, result = runs[[id]], sources = sources),
      file.path(output, paste0('boundary-', id, '.rds')))
  }
  retained <- Filter(function(x) !is.null(x$captured$value), runs)
  stopifnot(length(retained) > 0)
  best <- retained[[which.max(vapply(retained, function(x) x$captured$value$loglik, numeric(1)))]]$captured$value
  runs$fine <- testlet_bounded_fit(fixture, best$par, orders = c(121L, 181L, 241L))
  refined <- runs$fine$captured$value
  saveRDS(list(fixture = fixture, runs = runs, sources = sources, executed = Sys.time()),
    file.path(output, 'boundary-completed.rds'))
  summary <- do.call(rbind, lapply(names(runs), function(id) {
    captured <- runs[[id]]$captured
    x <- captured$value
    data.frame(Run = id, Variance = if (is.null(x)) NA_real_ else x$par[6],
      LogLik = if (is.null(x)) NA_real_ else x$loglik,
      ProjectedScore = if (is.null(x)) NA_real_ else x$projected_score,
      RightVarianceScore = if (is.null(x)) NA_real_ else x$gradient[6],
      Convergence = if (is.null(x)) NA_integer_ else x$convergence,
      Seconds = captured$elapsed, Error = captured$error)
  }))
  write.csv(summary, 'inst/validation/local-testlet-estimation-0.2.4-boundary.csv', row.names = FALSE)
  if (is.null(refined)) return(invisible(summary))
  # This diagnostic targets exact zero. Retain any different outcome above.
  if (refined$par[6] != 0) return(invisible(summary))
  previous <- readRDS('validation-results/local-testlet-tam-reference-20260917/evidence.rds')
  template <- previous$fits[['variance_0.49']]
  case <- list(fixture = fixture, parameters = refined$par[1:5], variance = 0)
  nodes <- seq(-7, 7, length.out = 41)
  external <- stress_capture(stress_tam(case, nodes, template))
  checks <- list()
  if (!is.null(external$value)) {
    checks[[1]] <- data.frame(Quantity = 'loglik', Error = abs(external$value$loglik - refined$loglik), Tolerance = 1e-6)
    checks[[2]] <- data.frame(Quantity = 'moments', Error = max(abs(external$value$moments - refined$moments)), Tolerance = 1e-6)
    checks[[3]] <- data.frame(Quantity = 'node_probabilities', Error = external$value$probability_error, Tolerance = 1e-12)
    for (a in 1:6) {
      estimates <- vapply(c(1e-4, 5e-5), function(h) {
        plus <- minus <- case
        if (a <= 5) {
          plus$parameters[a] <- plus$parameters[a] + h
          minus$parameters[a] <- minus$parameters[a] - h
        } else plus$variance <- h
        fp <- stress_capture(stress_tam(plus, nodes, template))
        fm <- if (a == 6) external else stress_capture(stress_tam(minus, nodes, template))
        saveRDS(list(plus = fp, minus = fm), file.path(output, paste0('boundary-gradient-', a, '-', h, '.rds')))
        if (is.null(fp$value) || is.null(fm$value)) return(NA_real_)
        (fp$value$loglik - fm$value$loglik) / if (a == 6) h else 2 * h
      }, numeric(1))
      comparison <- if (a == 6) 2 * estimates[2] - estimates[1] else estimates
      checks[[length(checks) + 1L]] <- data.frame(Quantity = names(refined$gradient)[a],
        Error = max(abs(comparison - refined$gradient[a])), Tolerance = 1e-5)
    }
  }
  saveRDS(list(external = external, refined = refined, sources = sources), file.path(output, 'boundary-tam.rds'))
  if (length(checks)) {
    checks <- do.call(rbind, checks)
    checks$Pass <- is.finite(checks$Error) & checks$Error <= checks$Tolerance
    write.csv(checks, 'inst/validation/local-testlet-estimation-0.2.4-boundary-checks.csv', row.names = FALSE)
    print(checks)
  }
  print(summary)
}

if (sys.nframe() == 0L) run_estimation_boundary()
