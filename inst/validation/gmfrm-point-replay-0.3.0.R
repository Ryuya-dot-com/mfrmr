# Reanalyse saved three-facet simulations; never refit or drop a failed attempt.
# Rscript gmfrm-point-replay-0.3.0.R <three-facet-sampling> <output-directory>
args <- commandArgs(TRUE)
stopifnot(length(args) == 2L)
input <- normalizePath(args[1])
output <- args[2]
dir.create(output, recursive = TRUE, showWarnings = FALSE)
protocol <- jsonlite::read_json(file.path(input, "protocol.json"), simplifyVector = TRUE)
hash <- unname(tools::md5sum(file.path(input, "protocol.json")))
files <- list.files(file.path(input, "results"), "[.]rds$", full.names = TRUE)
stopifnot(length(files) == 800L)

truth <- data.frame(
  Type = c(rep("location", 6), rep("step", 4), rep("slope", 4)),
  Facet = c(rep(c("Task", "Rater", "Criterion"), each = 2),
            rep("Criterion", 4), rep(c("Task", "Rater"), each = 2)),
  Level = c("t1", "t2", "r1", "r2", "c1", "c2",
            "c1", "c1", "c2", "c2", "t1", "t2", "r1", "r2"),
  Step = c(rep("", 6), rep(c("Step_1", "Step_2"), 2), rep("", 4)),
  Truth = c(protocol$truth$Task_locations, protocol$truth$Rater_locations,
            protocol$truth$Criterion_locations, as.vector(t(protocol$truth$Criterion_steps)),
            protocol$truth$Task_slopes, protocol$truth$Rater_slopes))
rows <- lapply(files, function(path) {
  x <- readRDS(path)
  stopifnot(identical(x$protocol_hash, hash))
  d <- truth
  d$Estimate <- NA_real_
  if (!is.null(x$fit)) {
    f <- x$fit
    for (i in seq_len(nrow(d))) {
      z <- switch(d$Type[i],
        location = f$facets$others$Estimate[f$facets$others$Facet == d$Facet[i] &
                                            f$facets$others$Level == d$Level[i]],
        step = f$steps$Estimate[f$steps$StepFacet == d$Level[i] & f$steps$Step == d$Step[i]],
        slope = f$slopes$OptimizerEstimate[f$slopes$SlopeOwner == d$Facet[i] &
                                           f$slopes$SlopeFacet == d$Level[i]])
      stopifnot(length(z) == 1L)
      d$Estimate[i] <- z
    }
  }
  logs <- d[d$Type == "slope", ]
  logs$Type <- "log_slope"
  logs$Truth <- log(logs$Truth)
  logs$Estimate <- log(logs$Estimate)
  d <- rbind(d, logs)
  cbind(x$run[rep(1L, nrow(d)), c("Replicate", "P", "O", "Converged", "NumericalEligible")], d)
})
d <- do.call(rbind, rows)
rownames(d) <- NULL
stopifnot(nrow(d) == 800L * 18L, !anyDuplicated(d[c("Replicate", "P", "O", "Type", "Facet", "Level", "Step")]))
write.csv(d, file.path(output, "points.csv"), row.names = FALSE, na = "")
groups <- interaction(d[c("P", "O", "Type", "Facet", "Level", "Step")], drop = TRUE)
summary <- do.call(rbind, lapply(split(d, groups), function(z) {
  available <- z$Converged & z$NumericalEligible & is.finite(z$Estimate)
  err <- z$Estimate[available] - z$Truth[available]
  n <- length(err)
  rmse <- sqrt(mean(err^2))
  cbind(z[1, c("P", "O", "Type", "Facet", "Level", "Step", "Truth")],
    data.frame(Attempts = nrow(z), NumericalPoints = n, Bias = mean(err),
      BiasMCSE = sd(err) / sqrt(n), RMSE = rmse,
      RMSEMCSE = if (rmse > 0) sd(err^2) / (2 * rmse * sqrt(n)) else 0,
      MaxAbsError = max(abs(err))))
}))
rownames(summary) <- NULL
stopifnot(nrow(summary) == 72L, all(summary$Attempts == 200L))
write.csv(summary, file.path(output, "point-summary.csv"), row.names = FALSE, na = "")
# Match the original study's two slope summaries, independently of its interval code.
old <- read.csv(file.path(input, "summary.csv"))
for (i in which(summary$Type == "slope" & summary$Level %in% c("t1", "r1"))) {
  z <- summary[i, ]; key <- paste(z$Facet, z$Level, "slope", sep = "_")
  ref <- old[old$P == z$P & old$O == z$O & old$Target == key, ]
  stopifnot(nrow(ref) == 1L, max(abs(unlist(z[c("Bias", "BiasMCSE", "RMSE")]) -
    unlist(ref[c("Bias", "BiasMCSE", "RMSE")]))) < 1e-12)
}
cat(nrow(d), "saved numerical estimates;", nrow(summary), "parameter/condition summaries.\n")
print(summary[summary$Type == "slope", ], row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(output, "sessionInfo.txt"))
