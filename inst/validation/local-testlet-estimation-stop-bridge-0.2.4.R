# Recheck only the stopping-control change against saved solutions and starts.
source('inst/validation/local-testlet-estimation-0.2.4.R')

run_estimation_stop_bridge <- function() {
  output <- 'validation-results/local-testlet-estimation-20260917'
  plan <- readRDS(file.path(output, 'plan.rds'))
  original <- readRDS(file.path(output, 'original-completed.rds'))
  clustered <- readRDS(file.path(output, 'clustered-completed.rds'))
  boundary <- readRDS(file.path(output, 'boundary-completed.rds'))
  # The original source is retained in Git, not overwritten evidence.
  archived <- file.path(output, 'initial-runner.R')
  status <- system2('git', c('show', '02edd35:inst/validation/local-testlet-estimation-0.2.4.R'), stdout = archived)
  stopifnot(status == 0L, unname(tools::md5sum(archived)) == unname(plan$sources[1]))
  entries <- list(
    original_saved = list(fixture = plan$fixtures$original, old = original$refined, start = original$refined$par),
    clustered_saved = list(fixture = plan$fixtures$clustered, old = clustered$refined, start = clustered$refined$par),
    boundary_saved = list(fixture = boundary$fixture, old = boundary$runs$fine$captured$value,
      start = boundary$runs$fine$captured$value$par),
    boundary_zero = list(fixture = boundary$fixture, old = boundary$runs$zero$captured$value, start = plan$starts$zero),
    original_zero = list(fixture = plan$fixtures$original, old = original$runs$joint_zero$captured$value,
      start = plan$starts$zero))
  sources <- tools::md5sum(c('inst/validation/local-testlet-estimation-stop-bridge-0.2.4.R', names(plan$sources)))
  results <- list()
  for (id in names(entries)) {
    entry <- entries[[id]]
    orders <- if (endsWith(id, '_saved')) c(121L, 181L, 241L) else c(61L, 121L, 181L, 241L)
    fitted <- testlet_bounded_fit(entry$fixture, entry$start, orders = orders)
    saveRDS(list(entry = entry, result = fitted, sources = sources, executed = Sys.time()),
      file.path(output, paste0('stop-bridge-', id, '.rds')))
    value <- fitted$captured$value
    result <- data.frame(Case = id, OldCode = entry$old$convergence,
      NewCode = if (is.null(value)) NA_integer_ else value$convergence,
      Variance = if (is.null(value)) NA_real_ else value$par[6],
      LogLikDifference = if (is.null(value)) NA_real_ else abs(value$loglik - entry$old$loglik),
      ParameterDifference = if (is.null(value)) NA_real_ else max(abs(value$par - entry$old$par)),
      ProjectedScore = if (is.null(value)) NA_real_ else value$projected_score,
      FunctionEvaluations = if (is.null(value)) NA_integer_ else value$counts[1],
      Error = fitted$captured$error, Warnings = paste(fitted$captured$warnings, collapse = ' | '))
    result$Pass <- !is.na(result$NewCode) && result$NewCode == 0 &&
      result$LogLikDifference <= 1e-6 && result$ParameterDifference <= 1e-4 && result$ProjectedScore <= 1e-5
    results[[id]] <- result
  }
  results <- do.call(rbind, results)
  write.csv(results, 'inst/validation/local-testlet-estimation-0.2.4-stop-bridge.csv', row.names = FALSE)
  print(results)

  # Render the retained profile results; this performs no extra optimization.
  profiles <- read.csv('inst/validation/local-testlet-estimation-0.2.4-runs.csv')
  png('inst/validation/local-testlet-estimation-0.2.4-profiles.png', width = 1450, height = 760, res = 145)
  par(mfrow = c(1, 2), mar = c(4.7, 4.7, 3, 1), oma = c(3, 0, 2, 0))
  for (id in c('original', 'clustered')) {
    profile <- profiles[profiles$Case == id & !is.na(profiles$FixedVariance), ]
    solution <- if (id == 'original') original$refined else clustered$refined
    plot(log1p(profile$FixedVariance), solution$loglik - profile$LogLik,
      type = 'o', pch = 16, col = '#22678b', lwd = 2, xaxt = 'n',
      ylim = c(-.05, max(solution$loglik - profile$LogLik) * 1.08),
      xlab = 'Local variance v (log(1 + v) spacing)', ylab = 'Log likelihood below joint solution',
      main = if (id == 'original') 'Original fixture: 33 observations' else 'Clustered fixture: 36 observations')
    ticks <- c(0, .5, 1, 4, 9, 16)
    axis(1, log1p(ticks), ticks)
    abline(h = 0, col = '#bbbbbb', lty = 3)
    points(log1p(solution$par[6]), 0, pch = 18, cex = 1.4, col = '#ba561e')
    legend('topright', c('Fixed v; five effects refitted', sprintf('Joint v = %.3f', solution$par[6])),
      col = c('#22678b', '#ba561e'), pch = c(16, 18), lty = c(1, NA), bty = 'n', cex = .85)
  }
  mtext('Common person-by-rater local variance: bounded numerical prototype', outer = TRUE, side = 3, line = .4)
  mtext('Eight profile points per fixture. Lines connect evaluated points; no global or interval-coverage guarantee.',
    outer = TRUE, side = 1, line = 1, cex = .78)
  dev.off()
  stopifnot(all(results$Pass))
}

if (sys.nframe() == 0L) run_estimation_stop_bridge()
