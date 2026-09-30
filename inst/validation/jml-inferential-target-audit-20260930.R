# Reconcile saved population roots and all coordinates of the completed study.
# No fitting, simulation or order selection. Also reconcile the repeated-
# sampling target by exact variance decomposition at the saved population roots.
out <- "validation-results/jml-inferential-target-audit-20260930"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
paths <- c(
  population = "validation-results/jml-scope-challenge-20260927/parameters.csv",
  rows = "validation-results/jml-order-sampling-20260927/rows.csv",
  summary = "validation-results/jml-order-sampling-20260927/summary.csv",
  paired = "validation-results/jml-order-sampling-20260927/paired.csv")
scope <- "validation-results/jml-scope-challenge-20260927"
cases <- expand.grid(Owner = c("Criterion", "Rater"),
  Design = c("sparse", "unequal"), Order = c(1L, 2L, 4L),
  stringsAsFactors = FALSE)
case_paths <- file.path(scope, paste0(apply(cases, 1, paste, collapse = "-"), ".rds"))
sources <- paste0("inst/validation/", c("jml-design-adjustment-20260927.R",
  "jml-profile-bias-sample-20260927.R", "jml-profile-bias-exact-20260927.R"))
paths <- c(paths, contract = file.path(scope, "contract.rds"), case_paths, sources)
hashes <- tools::md5sum(paths)
p <- read.csv(paths[["population"]])
r <- read.csv(paths[["rows"]])
s <- read.csv(paths[["summary"]])
paired <- read.csv(paths[["paired"]])
key <- c("Owner", "Design", "Order", "Parameter")
p <- p[p$N == 400 & p$Order %in% c(2, 4), ]
x <- merge(s, p, by = key, suffixes = c("Sample", "Population"), sort = FALSE)
stopifnot(nrow(s) == 20L, nrow(x) == nrow(s), !anyDuplicated(x[key]),
  all(x$PointAvailable == 200L), all(x$IntervalAvailable == 200L),
  all(is.finite(x$LocalSE) & x$LocalSE > 0))
for (i in seq_len(nrow(x))) {
  z <- r[r$Owner == x$Owner[i] & r$Design == x$Design[i] &
    r$Order == x$Order[i] & r$Parameter == x$Parameter[i], ]
  stopifnot(nrow(z) == 200L, setequal(z$Replicate, 1:200),
    all(z$PointAvailable), all(z$IntervalAvailable),
    max(abs(z$Truth - x$Truth[i])) < 1e-12,
    max(abs(z$PopulationRoot - x$PopulationRoot[i])) < 1e-12)
  independently <- c(
    BiasSample = mean(z$Estimate - z$Truth),
    EmpiricalSD = sd(z$Estimate), RootMeanVariance = sqrt(mean(z$SE^2)),
    TruthCoverage = mean(z$Lower <= z$Truth & z$Upper >= z$Truth),
    RootCoverage = mean(z$Lower <= z$PopulationRoot & z$Upper >= z$PopulationRoot))
  stopifnot(max(abs(independently - unlist(x[i, names(independently)]))) < 1e-12)
}
x$RootDisplacement <- x$PopulationRoot - x$Truth
x$AbsoluteDisplacementOverLocalSE <- abs(x$RootDisplacement) / x$LocalSE
x$AbsoluteDisplacementOverLocalSE_N1600 <- 2 * x$AbsoluteDisplacementOverLocalSE
# N=1600 is an algebraic scaling of the retained population covariance, not
# another simulation. Check it against the earlier stored population result.
p1600 <- read.csv(paths[["population"]])
p1600 <- p1600[p1600$N == 1600 & p1600$Order %in% c(2, 4), c(key, "LocalSE")]
check <- merge(x, p1600, by = key, suffixes = c("", "1600"))
stopifnot(max(abs(check$LocalSE1600 - check$LocalSE / 2)) < 1e-12)
columns <- c(key, "Truth", "PopulationRoot", "RootDisplacement", "LocalSE",
  "AbsoluteDisplacementOverLocalSE", "AbsoluteDisplacementOverLocalSE_N1600",
  "BiasSample", "BiasMCSE", "EmpiricalSD", "RootMeanVariance",
  "TruthCoverage", "TruthCoverageLow", "TruthCoverageHigh", "RootCoverage")
x <- x[order(x$Condition, x$Order, match(x$Parameter,
  c("Rater", "Criterion", "Step1", "Step2", "LogSlope"))), columns]
write.csv(x, file.path(out, "coordinate-audit.csv"), row.names = FALSE)
write.csv(paired, file.path(out, "retained-paired-mse.csv"), row.names = FALSE)

# The saved fixed-roster experiment sampled new Persons from each roster's
# ability mixture. It did not hold each Person's ability fixed across repeats.
source(sources[1])
contract <- readRDS(paths[["contract"]])
ability_weight <- c(.25, .5, .25)
decomposition <- lapply(seq_len(nrow(cases)), function(i) {
  id <- cases[i, ]
  saved <- readRDS(case_paths[i])
  stopifnot(saved$summary$Reviewed, saved$summary$CovarianceAvailable)
  design <- contract$designs[[id$Design]]
  N <- 400L
  counts <- N * design$proportions
  stopifnot(all(counts == round(counts)))
  response <- ability <- fixed <- empirical <- matrix(0, 5L, 5L)
  for (g in seq_along(design$exposure)) {
    reference <- make_jml_roster_problem(id$Owner, design$exposure[[g]])
    mass <- reference$mass(saved$truth, design$ability[[g]])
    mixture <- drop(mass %*% ability_weight)
    U <- saved$covariance$scores[[g]]$value
    stopifnot(max(abs(colSums(mass) - 1)) < 1e-12,
      max(abs(mixture - saved$weights[[g]])) < 1e-12)
    means <- crossprod(mass, U)
    mean <- drop(crossprod(ability_weight, means))
    within <- Reduce(`+`, lapply(seq_along(ability_weight), function(h) {
      centered <- sweep(U, 2, means[h, ])
      ability_weight[h] * crossprod(centered, mass[, h] * centered)
    }))
    centered_means <- sweep(means, 2, mean)
    between <- crossprod(centered_means, ability_weight * centered_means)
    centered <- sweep(U, 2, mean)
    total <- crossprod(centered, mixture * centered)
    stopifnot(max(abs(total - within - between)) < 1e-12,
      max(abs(mean - saved$covariance$means[[g]])) < 1e-12)
    weight <- design$proportions[g]
    response <- response + weight * within
    ability <- ability + weight * between
    fixed <- fixed + weight * total
    # Expected uncorrected sample-centered meat at a KNOWN root; this is not
    # the expectation of the nonlinear fitted sandwich or an SE correction.
    empirical <- empirical + weight * (1 - 1 / counts[g]) * total
  }
  roster_means <- do.call(rbind, saved$covariance$means)
  centered_means <- sweep(roster_means, 2, saved$covariance$global)
  roster <- crossprod(centered_means, design$proportions * centered_means)
  Ainv <- solve(saved$attempts[[1]]$fit$A)
  V <- function(B) Ainv %*% B %*% t(Ainv) / N
  stopifnot(max(abs(fixed - saved$covariance$meat)) < 1e-12,
    max(abs(V(fixed) - saved$covariance$vcov)) < 1e-12,
    min(eigen(ability, symmetric = TRUE)$values) > -1e-12,
    min(eigen(roster, symmetric = TRUE)$values) > -1e-12)
  data.frame(id, Parameter = names(saved$truth),
    FixedAbilityVariance = diag(V(response)),
    AbilityCompositionVariance = diag(V(ability)),
    FixedRosterVariance = diag(V(fixed)),
    RosterCompositionVariance = diag(V(roster)),
    RandomRosterVariance = diag(V(fixed + roster)),
    AbilityShare = diag(V(ability)) / diag(V(fixed)),
    ExpectedCenteredMeatVarianceRatio = diag(V(empirical)) / diag(V(fixed)),
    row.names = NULL)
})
decomposition <- do.call(rbind, decomposition)
stopifnot(nrow(decomposition) == 60L,
  max(abs(with(decomposition, FixedAbilityVariance + AbilityCompositionVariance -
    FixedRosterVariance))) < 1e-12)
write.csv(decomposition, file.path(out, "sampling-decomposition.csv"), row.names = FALSE)
stopifnot(identical(hashes, tools::md5sum(paths)))
write.csv(data.frame(Path = unname(paths), MD5 = unname(hashes)),
  file.path(out, "inputs.csv"), row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
print(x[, c(key, "RootDisplacement", "AbsoluteDisplacementOverLocalSE",
  "TruthCoverage", "RootCoverage")], row.names = FALSE)
print(aggregate(cbind(AbilityShare, ExpectedCenteredMeatVarianceRatio) ~ Order,
  decomposition, range), row.names = FALSE)
