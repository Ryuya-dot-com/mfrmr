# Exploratory diagnostics of retained experiments; no candidate correction is fitted.
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 1L, args %in% c("review", "replay"))
script <- "inst/validation/jml-studentization-review-20261013.R"
out <- "validation-results/jml-studentization-review-20261013"
prior_path <- "validation-results/jml-exposure-evidence-20261012/review.rds"
prior <- readRDS(prior_path)
inputs <- tools::md5sum(c(prior_path, script))
read_prior <- function(path) {
  stopifnot(path %in% names(prior$inputs))
  h <- tools::md5sum(path)
  stopifnot(identical(unname(h), unname(prior$inputs[path])))
  inputs <<- c(inputs, h[!names(h) %in% names(inputs)])
  readRDS(path)
}
near <- function(a, b) {
  stopifnot(length(a) == length(b))
  if (length(a)) stopifnot(max(abs(a - b)) < 1e-10)
}
mean_or_na <- function(x) if (length(x)) mean(x) else NA_real_
critical <- qnorm(.975)
records <- list(); covariance_error <- numeric()
summaries <- names(prior$inputs)[endsWith(names(prior$inputs), "jml-inference/summary.rds")]
stopifnot(length(summaries) == 4L)
for (path in summaries) {
  summary <- read_prior(path)
  for (job in names(summary$binding$jobs)) {
    z <- read_prior(job)$payload
    d <- z$diagnostics
    influence <- NULL
    if (!is.null(d$scores) && !is.null(d$jacobian)) {
      U <- d$scores; N <- nrow(U); groups <- split(seq_len(N), d$roster)
      centered <- U; weights <- numeric(N)
      for (ix in groups) {
        centered[ix, ] <- sweep(U[ix, , drop = FALSE], 2, colMeans(U[ix, , drop = FALSE]))
        weights[ix] <- length(ix) / (length(ix) - 1L)
      }
      influence <- -centered %*% t(solve(d$jacobian))
    }
    for (normalization in names(z$candidates)) {
      x <- z$candidates[[normalization]]$rows
      x <- x[x$Output == "interval", ]
      x$InfluenceMaxShare <- x$InfluenceConcentrationCount <- NA_real_
      if (!is.null(influence)) {
        v <- influence * sqrt(if (normalization == "finite_roster") weights else 1)
        rebuilt <- crossprod(v) / N^2
        covariance_error <- c(covariance_error, max(abs(rebuilt - z$covariances[[normalization]])))
        near(rebuilt, z$covariances[[normalization]])
        cvar <- (v %*% t(z$map$H))^2 / N^2
        sums <- colSums(cvar)
        near(sums, rowSums((z$map$H %*% rebuilt) * z$map$H))
        match_target <- match(x$Target, z$map$targets)
        stopifnot(!anyNA(match_target))
        ok <- x$Available
        near(sums[match_target[ok]], x$SE[ok]^2)
        x$InfluenceMaxShare <- apply(cvar, 2, max)[match_target] / sums[match_target]
        x$InfluenceConcentrationCount <- (sums^2 / colSums(cvar^2))[match_target]
      }
      x$Error <- x$Estimate - x$ReferenceValue
      x$StudentizedError <- ifelse(x$Available, x$Error / x$SE, NA_real_)
      records[[length(records) + 1L]] <- x
    }
  }
}
records <- do.call(rbind, records)
keys <- c("ConditionId", "Arm", "Target", "CovarianceNormalization")
key <- do.call(paste, c(records[keys], sep = "\r"))
diagnostics <- do.call(rbind, lapply(split(records, key), function(x) {
  stopifnot(nrow(x) == 50L, setequal(x$Replicate, 1:50), !anyDuplicated(x$Replicate))
  a <- x[x$Available, ]; e <- a$Error; se <- a$SE; R <- nrow(a)
  bias <- mean(e); s <- sd(e); Z <- e / se
  truth <- abs(Z) <= critical
  # Morris et al.'s bias-eliminated coverage is diagnostic, not an interval rule.
  # Its center is estimated from these same replications: no binomial MC CI.
  no_bias <- abs((e - bias) / se) <= critical
  fixed_width <- abs(e) <= critical * s
  both <- abs(e - bias) <= critical * s
  stopifnot(sum(truth) == sum(a$Lower <= a$ReferenceValue & a$Upper >= a$ReferenceValue))
  cbind(x[1, keys], data.frame(Planned = 50L, Returned = R, Covered = sum(truth),
    Bias = bias, EmpiricalSD = s, AverageModelSE = sqrt(mean(se^2)),
    Coverage = mean(truth), DeliveredCoverage = sum(truth) / 50,
    BiasEliminated = mean(no_bias), FixedEmpiricalWidth = mean(fixed_width),
    BiasEliminatedFixedWidth = mean(both), StudentizedMean = mean(Z), StudentizedSD = sd(Z),
    LowerMiss = sum(Z < -critical), UpperMiss = sum(Z > critical),
    VarianceCV = sd(se^2) / mean(se^2),
    MaxInfluenceShare = mean_or_na(a$InfluenceMaxShare[is.finite(a$InfluenceMaxShare)]),
    InfluenceConcentrationCount = mean_or_na(a$InfluenceConcentrationCount[is.finite(a$InfluenceConcentrationCount)])))
}))
# The earlier unequal-slope experiment has independently computed population
# roots and covariance. It can separate known-root/known-width diagnostics.
raw_path <- "validation-results/jml-order-sampling-20260927/rows.csv"
audit_root <- "validation-results/jml-inferential-target-audit-20260930"
bindings <- read.csv(file.path(audit_root, "inputs.csv"))
stopifnot(unname(tools::md5sum(raw_path)) == bindings$MD5[match(raw_path, bindings$Path)])
population_path <- "validation-results/jml-scope-challenge-20260927/parameters.csv"
stopifnot(unname(tools::md5sum(population_path)) == bindings$MD5[match(population_path, bindings$Path)])
inputs <- c(inputs, tools::md5sum(c(raw_path, population_path, file.path(audit_root, "inputs.csv"))))
raw <- read.csv(raw_path); population <- read.csv(population_path)
pk <- c("Owner", "Design", "Order", "Parameter")
oracle <- do.call(rbind, lapply(split(raw, do.call(paste, c(raw[pk], sep = "\r"))), function(x) {
  p <- population[population$N == 400 & population$Owner == x$Owner[1] &
    population$Design == x$Design[1] & population$Order == x$Order[1] &
    population$Parameter == x$Parameter[1], ]
  stopifnot(nrow(p) == 1L, nrow(x) == 200L, all(x$IntervalAvailable), all(x$PointAvailable))
  near(x$PopulationRoot, rep(p$PopulationRoot, 200L))
  cbind(x[1, pk], data.frame(Planned = 200L,
    ActualTruth = sum(abs((x$Estimate - x$Truth) / x$SE) <= critical),
    ActualPopulationRoot = sum(abs((x$Estimate - x$PopulationRoot) / x$SE) <= critical),
    OracleWidthTruth = sum(abs((x$Estimate - x$Truth) / p$LocalSE) <= critical),
    OracleWidthPopulationRoot = sum(abs((x$Estimate - x$PopulationRoot) / p$LocalSE) <= critical),
    Bias = mean(x$Estimate - x$Truth), RootBias = mean(x$Estimate - x$PopulationRoot),
    EmpiricalSD = sd(x$Estimate), AverageModelSE = sqrt(mean(x$SE^2)),
    PopulationSE = p$LocalSE, StandardizedPopulationDisplacement = (p$PopulationRoot - p$Truth) / p$LocalSE))
}))
# Formula controls: coverage is invariant to positive rescaling; recentering is
# a diagnostic transformation, not a change to the stored fitted estimator.
e <- c(-3, -1, .1, .8, 2); se <- c(1, .5, .3, .4, 1)
stopifnot(identical(abs(e / se) <= critical, abs((7 * e) / (7 * se)) <= critical),
  identical(abs((e - mean(e)) / se) <= critical, abs((e + 5 - mean(e + 5)) / se) <= critical),
  all(is.finite(covariance_error)), max(covariance_error) < 1e-10,
  !exists(".Random.seed", .GlobalEnv), !"mfrmr" %in% loadedNamespaces())
result <- list(inputs = inputs, diagnostics = diagnostics, records = records, oracle = oracle,
  maximum_covariance_reconstruction_error = max(covariance_error),
  interpretation = "Exploratory same-replication transformations; no new calibrated procedure. Influence concentration is not degrees of freedom or a cluster leverage correction.")
stopifnot(identical(tools::md5sum(names(inputs)), inputs))
path <- file.path(out, "review.rds")
if (args == "review") {
  stopifnot(!file.exists(path)); dir.create(out, recursive = TRUE, showWarnings = FALSE)
  saveRDS(result, path)
} else stopifnot(identical(result, readRDS(path)))
print(subset(diagnostics, Arm == "GPCM-JML2" & Target == "contrast:Criterion:1-2" &
  CovarianceNormalization == "asymptotic"), row.names = FALSE)
print(oracle, row.names = FALSE)
cat("Saved-only", args, "passed; maximum covariance reconstruction error:", max(covariance_error), "\n")
