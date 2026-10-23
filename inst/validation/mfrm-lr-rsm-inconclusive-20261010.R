# Diagnose the completed RSM confirmation from its already verified aggregate.
# Run from the package root with Rscript --vanilla. Base R only: no fitting,
# package loading, integration, response generation or outcome-based extension.
started <- proc.time()[['elapsed']]
script <- 'inst/validation/mfrm-lr-rsm-inconclusive-20261010.R'
root <- 'validation-results/mfrm-lr-rsm-confirmation-20261009'
out <- 'validation-results/mfrm-lr-rsm-inconclusive-20261010'
verify_path <- file.path(root, 'summary-verification-20261010.rds')
stopifnot(unname(tools::md5sum(verify_path)) == '381320c691947d7f3bf3f12564eb7afb')
verification <- readRDS(verify_path)
verify_hashes <- function(h) stopifnot(!anyNA(h),
  identical(unname(tools::md5sum(names(h))), unname(h)))
# These consumed aggregates have already been reconciled to all raw phases.
# Verify their identity; do not repeat the 9,827-phase reconstruction.
inputs <- verification$outputs[file.path(root,
  c('summary.rds', 'phase-accounting.csv', 'job-accounting.csv'))]
stopifnot(isTRUE(verification$passed), verification$jobs == 1600L,
  verification$rows == 38400L, verification$phase_count == 9827L)
verify_hashes(inputs)
saved <- readRDS(file.path(root, 'summary.rds'))$payload
records <- subset(saved$records, Output == 'interval')
selected <- subset(records, Selection == 'selected')
stopifnot(nrow(records) == 19200L, nrow(selected) == 9600L,
  !anyDuplicated(selected[c('ParentId', 'Target')]))
near <- function(a, b) isTRUE(all.equal(a, b, tolerance = 1e-12, check.attributes = FALSE))
cp <- function(k, n) c(if (k == 0) 0 else qbeta(.025, k, n-k+1),
  if (k == n) 1 else qbeta(.975, k+1, n-k))
diagnostics <- selection <- rescued <- list()
for (n in c(20L, 240L)) for (target in unique(selected$Target)) {
  z <- subset(selected, N == n & Target == target)
  a <- z[z$Available, ]; w <- a$Error / a$SE
  s <- subset(saved$summary, N == n & Target == target &
    Output == 'interval' & Selection == 'selected')
  below <- a$Upper < a$Truth; above <- a$Lower > a$Truth
  stopifnot(nrow(z) == 800L, nrow(a) == s$Delivered, all(is.finite(w)), all(a$SE > 0),
    all(a$Covered == !(below | above)), sum(a$Covered) == s$Covered,
    near(cp(sum(a$Covered), nrow(a)), c(s$CoverageLower, s$CoverageUpper)),
    near(a$Lower, a$Estimate - qnorm(.975)*a$SE),
    near(a$Upper, a$Estimate + qnorm(.975)*a$SE),
    near(mean(a$Error), s$Bias), near(sd(a$Error), s$EmpiricalSD))
  tails_below <- cp(sum(below), nrow(a)); tails_above <- cp(sum(above), nrow(a))
  q <- quantile(w, c(.025, .5, .975), names = FALSE)
  diagnostics[[length(diagnostics)+1L]] <- data.frame(N = n, Target = target,
    Decision = s$Decision, Attempted = nrow(z), Returned = nrow(a),
    Covered = sum(a$Covered), BelowTruth = sum(below), AboveTruth = sum(above),
    BelowRate = mean(below), BelowLower = tails_below[1], BelowUpper = tails_below[2],
    AboveRate = mean(above), AboveLower = tails_above[1], AboveUpper = tails_above[2],
    Bias = mean(a$Error), BiasMCSE = sd(a$Error)/sqrt(nrow(a)),
    MeanSEtoSD = mean(a$SE)/sd(a$Error), RMSSEtoSD = sqrt(mean(a$SE^2))/sd(a$Error),
    ZMean = mean(w), ZSD = sd(w), Z025 = q[1], ZMedian = q[2], Z975 = q[3],
    EstimateSECorrelation = cor(a$Estimate, a$SE))
  before <- subset(records, N == n & Target == target & Selection == 'initial')
  before <- before[match(z$ParentId, before$ParentId), ]
  stopifnot(identical(before$ParentId, z$ParentId))
  both <- before$Available & z$Available
  added <- !before$Available & z$Available
  lost <- before$Available & !z$Available
  fields <- c('Estimate', 'SE', 'Lower', 'Upper', 'Covered')
  old <- before[both, fields]; current <- z[both, fields]
  rownames(old) <- rownames(current) <- NULL
  stopifnot(!any(lost), identical(old, current))
  selection[[length(selection)+1L]] <- data.frame(N = n, Target = target,
    InitiallyReturned = sum(before$Available), FinallyReturned = sum(z$Available),
    RetainedUnchanged = sum(both), Added = sum(added), Lost = sum(lost),
    AddedCovered = sum(z$Covered[added]), AddedBelowTruth = sum(z$Upper[added] < z$Truth[added]),
    AddedAboveTruth = sum(z$Lower[added] > z$Truth[added]))
  if (any(added)) rescued[[length(rescued)+1L]] <- data.frame(N = n, Target = target,
    ParentId = z$ParentId[added], InitialReason = before$Reason[added],
    InitialEstimate = before$Estimate[added], SelectedEstimate = z$Estimate[added],
    Movement = z$Estimate[added] - before$Estimate[added],
    SelectedSE = z$SE[added], Covered = z$Covered[added])
}
diagnostics <- do.call(rbind, diagnostics); selection <- do.call(rbind, selection)
rescued <- do.call(rbind, rescued)

# The difference contrast is deterministically twice the slope, including
# its uncertainty and coverage events; it is not another independent study.
for (n in c(20L, 240L)) {
  b <- subset(selected, N == n & Target == 'beta:X')
  d <- subset(selected, N == n & Target == 'contrast:difference')
  d <- d[match(b$ParentId, d$ParentId), ]
  stopifnot(identical(b$Available, d$Available), identical(b$Covered, d$Covered))
  for (field in c('Estimate', 'SE', 'Lower', 'Upper', 'Truth'))
    stopifnot(near(d[[field]], 2*b[[field]]))
}

# Analytic planning scenarios, not a new confirmation or an adopted allocation.
# n is a FIXED number of returned intervals. A future study must instead fix
# attempts and include delivery uncertainty; never sample until n returns.
scenarios <- expand.grid(Returned = c(800L, 1600L, 3200L),
  AssumedCoverage = c(.92, .932, .93875, .95, .97255, .98))
for (n in unique(scenarios$Returned)) {
  k <- 0:n
  lower <- c(0, qbeta(.025, k[-1], n-k[-1]+1))
  upper <- c(qbeta(.975, k[-length(k)]+1, n-k[-length(k)]), 1)
  accepted <- k[lower >= .92 & upper <= .98]
  for (i in which(scenarios$Returned == n)) {
    p <- scenarios$AssumedCoverage[i]
    mass <- sum(dbinom(accepted, n, p))
    check <- if (length(accepted)) pbinom(max(accepted), n, p) -
      pbinom(min(accepted)-1, n, p) else 0
    stopifnot(near(mass, check))
    scenarios$PassLowerCount[i] <- min(accepted)
    scenarios$PassUpperCount[i] <- max(accepted)
    scenarios$CoverageCriterionProbability[i] <- mass
  }
}

phases <- read.csv(file.path(root, 'phase-accounting.csv'))
jobs <- read.csv(file.path(root, 'job-accounting.csv'))
stopifnot(nrow(phases) == verification$phase_count, nrow(jobs) == verification$jobs,
  near(sum(phases$Elapsed), sum(jobs$Elapsed)))
cost <- aggregate(Elapsed ~ N + Phase, phases, sum)
counts <- aggregate(Elapsed ~ N + Phase, phases, length)
cost$Calls <- counts$Elapsed[match(paste(cost$N, cost$Phase), paste(counts$N, counts$Phase))]
cost$MeanSeconds <- cost$Elapsed / cost$Calls
cost$Scope <- 'Historical summed worker-call seconds, not wall time or a new speed benchmark'

stopifnot(!'mfrmr' %in% loadedNamespaces())
dir.create(out, recursive = TRUE, showWarnings = FALSE)
write.csv(diagnostics, file.path(out, 'diagnostics.csv'), row.names = FALSE)
write.csv(selection, file.path(out, 'selection.csv'), row.names = FALSE)
write.csv(rescued, file.path(out, 'rescued-intervals.csv'), row.names = FALSE)
write.csv(scenarios, file.path(out, 'precision-scenarios.csv'), row.names = FALSE)
write.csv(cost, file.path(out, 'historical-phase-cost.csv'), row.names = FALSE)
verify_hashes(inputs)
saveRDS(list(diagnostics = diagnostics, selection = selection, rescued = rescued, precision_scenarios = scenarios,
  historical_cost = cost, inputs = c(inputs, tools::md5sum(verify_path)), script = tools::md5sum(script),
  scoring_only_retry_jobs = sum(jobs$ScoringOrder > jobs$IntervalOrder),
  new_fits = 0L, new_information_evaluations = 0L, new_draws = 0L,
  raw_phase_reconstructions = 0L, original_decisions = subset(saved$summary,
    Selection == 'selected' & Output == 'interval'), elapsed = proc.time()[['elapsed']] - started,
  scope = 'Exploratory diagnosis of already inspected confirmation; not independent repair confirmation.',
  session = sessionInfo()), file.path(out, 'diagnosis.rds'))
print(subset(diagnostics, Decision == 'inconclusive', select = c(N, Target, Returned,
  BelowTruth, AboveTruth, RMSSEtoSD, Z025, Z975)))
cat('Saved-result diagnosis complete; zero new fits, information evaluations, random draws or raw-phase reconstructions.\n')
