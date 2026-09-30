# Reconcile saved population roots and all coordinates of the completed study.
# No fitting, simulation, order selection or package-API changes.
out <- "validation-results/jml-inferential-target-audit-20260930"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
paths <- c(
  population = "validation-results/jml-scope-challenge-20260927/parameters.csv",
  rows = "validation-results/jml-order-sampling-20260927/rows.csv",
  summary = "validation-results/jml-order-sampling-20260927/summary.csv",
  paired = "validation-results/jml-order-sampling-20260927/paired.csv")
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
stopifnot(identical(hashes, tools::md5sum(paths)))
write.csv(data.frame(Path = unname(paths), MD5 = unname(hashes)),
  file.path(out, "inputs.csv"), row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
print(x[, c(key, "RootDisplacement", "AbsoluteDisplacementOverLocalSE",
  "TruthCoverage", "RootCoverage")], row.names = FALSE)
