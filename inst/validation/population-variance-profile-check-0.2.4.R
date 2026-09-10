# Replay checks and figure for the retained numerical review (no new fits).
directory <- 'inst/validation'
main_path <- file.path(directory, 'population-variance-profile-evidence-0.2.4.rds')
refine_path <- file.path(directory, 'population-variance-profile-refinement-evidence-0.2.4.rds')
main <- readRDS(main_path); refine <- readRDS(refine_path)
stopifnot(identical(unname(refine$input_md5), unname(tools::md5sum(main_path))))
for (x in list(main, refine)) {
  stopifnot(identical(x$payload, tools::md5sum(names(x$payload))))
  stopifnot(all(x$summary$Returned), length(x$results) == nrow(x$plan))
  for (i in seq_len(nrow(x$plan))) {
    par <- x$results[[i]]$result$par
    stopifnot(abs(tail(par, 1) - if (x$plan$Variance[i] == 0) 0 else
      log(x$plan$Variance[i])) < 1e-14)
  }
}
stopifnot(nrow(main$plan) == 184L, nrow(refine$plan) == 32L,
  all(subset(main$summary, Variance == 0)$ZeroPlaceholderDifference == 0),
  max(abs(main$ridge$Objective - main$ridge$SaturatedBound)) < 1e-10)
zero <- subset(main$summary, Variance == 0)
stopifnot(max(abs(zero$Objective - zero$ReferenceObjective)) < 1e-10)
for (id in c('RSM', 'PCM', 'paired')) {
  e <- subset(main$envelope, Case == id & ContinuousNuisanceQualified)
  stopifnot(min(e$ReferenceObjective) < e$ReferenceObjective[e$Variance == 0])
}
cat('Passed: 216 fixed-variance vectors, exact zero, analytical ridge, interior improvement, source/input integrity.\n')

png(file.path(directory, 'population-variance-profile-0.2.4.png'),
  width = 1600, height = 1160, res = 150)
par(mfrow = c(2, 2), mar = c(4.5, 4.8, 2.3, 1), oma = c(3.7, 0, 2.5, 0))
titles <- c(RSM = 'RSM latent regression', PCM = 'PCM latent regression',
  single = 'One binary rating per Person', paired = 'Paired binary ratings')
for (id in names(titles)) {
  original <- subset(main$envelope, Case == id & Variance != 1e-6)
  e <- subset(original, Q %in% c(1, 121))
  r <- subset(refine$envelope, Case == id & Q == 961)
  baseline <- if (id == 'single') main$ridge$SaturatedBound[1] else
    min(e$ReferenceObjective[e$ContinuousNuisanceQualified])
  upper <- max(1, original$Objective - baseline, r$ReferenceObjective - baseline)
  plot(NA, xlim = c(0, log10(65)), ylim = c(-.025 * upper, 1.05 * upper),
    xaxt = 'n', xlab = 'Population variance (log(1 + variance) spacing)',
    ylab = 'Negative log likelihood above reference minimum', main = titles[id])
  ticks <- c(0, 1, 4, 16, 64); axis(1, log10(1 + ticks), ticks)
  abline(h = 0, col = '#dddddd')
  for (q in c(61, 121)) {
    z <- subset(original, Q %in% c(1, q)); z <- z[order(z$Variance), ]
    lines(log10(1 + z$Variance), z$Objective - baseline,
      col = if (q == 61) '#999999' else '#627c99', lty = if (q == 61) 3 else 2)
  }
  points(log10(1 + e$Variance), e$ReferenceObjective - baseline,
    pch = ifelse(e$ContinuousNuisanceQualified, 16, 1),
    col = ifelse(e$ContinuousNuisanceQualified, '#165da3', '#bf5700'), cex = .9)
  points(log10(1 + r$Variance), r$ReferenceObjective - baseline,
    pch = ifelse(r$ContinuousNuisanceQualified, 18, 5),
    col = ifelse(r$ContinuousNuisanceQualified, '#156744', '#bf5700'), cex = 1.15)
}
mtext('Bounded variance profiles: four retained datasets, two independent starts',
  side = 3, outer = TRUE, line = .6, cex = 1.05)
mtext('Lines: q61 / q121 native objectives. Circles: q1 / q121 independent values. Diamonds: q961 independent values.',
  side = 1, outer = TRUE, line = .8, cex = .75)
mtext('Filled: continuous nuisance checks passed. Hollow: not qualified. Finite grid; no calibrated test or confidence interval.',
  side = 1, outer = TRUE, line = 2, cex = .75)
dev.off()
