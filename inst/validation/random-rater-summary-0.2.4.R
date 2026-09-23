# Summarize every planned trial; unavailable results retain their denominator.
root <- "validation-results/random-rater-20260923/pilot-final"
protocol <- readRDS(file.path(root, "protocol.rds"))
trials <- lapply(seq_len(nrow(protocol$roster)), function(i) {
  path <- file.path(root, sprintf("trial-%03d.rds", i))
  if (!file.exists(path)) stop("The planned roster is incomplete: ", i)
  readRDS(path)
})
rows <- lapply(trials, function(x) {
  row <- x$roster; f <- x$fit; p <- x$profile
  ready <- !is.null(f) && isTRUE(f$checks$NumericalReady)
  row$NumericalReady <- ready
  row$InformationPositive <- !is.null(f) && isTRUE(f$checks$InformationPositive)
  row$Boundary <- !is.null(f) && isTRUE(f$checks$EstimatedVarianceBoundary)
  row$SDEstimate <- if (ready) f$calibration$rater_sd else NA_real_
  row$SDLower <- if (is.matrix(p)) p[1, "Lower"] else NA_real_
  row$SDUpper <- if (is.matrix(p)) p[1, "Upper"] else NA_real_
  row$SDCoverage <- if (is.matrix(p)) row$SD >= row$SDLower && row$SD <= row$SDUpper else NA
  row$RaterCoverage <- row$RaterRMSE <- row$FixedCoverage <- row$FixedBias <- NA_real_
  if (!is.null(f)) {
    r <- f$raters; truth <- x$truth$rater[r$Rater]
    if (ready) row$RaterRMSE <- sqrt(mean((r$Estimate - truth)^2))
    if (all(is.finite(r$Lower)) && all(is.finite(r$Upper))) {
      row$RaterCoverage <- mean(r$Lower <= truth & r$Upper >= truth)
    }
    tab <- f$calibration_table[f$calibration_table$Parameter != "Population SD", ]
    truth <- c(x$truth$criterion, x$truth$steps)
    if (ready) row$FixedBias <- mean(tab$Estimate - truth)
    if (all(is.finite(tab$Lower)) && all(is.finite(tab$Upper))) {
      row$FixedCoverage <- mean(tab$Lower <= truth & tab$Upper >= truth)
    }
  }
  row$Seconds <- x$elapsed[["elapsed"]]
  row$Error <- paste(x$errors, collapse = " | ")
  row$Warnings <- paste(x$warnings, collapse = " | ")
  row
})
rows <- do.call(rbind, rows)
write.csv(rows, file.path(root, "trials.csv"), row.names = FALSE)
mean_or_na <- function(x) if (any(is.finite(x))) mean(x[is.finite(x)]) else NA_real_
mcse <- function(x) { x <- x[is.finite(x)]; if (length(x) > 1L) sd(x) / sqrt(length(x)) else NA_real_ }
summary <- do.call(rbind, lapply(split(rows, rows$Condition), function(x) {
  n <- nrow(x); available <- sum(!is.na(x$SDCoverage)); covered <- sum(x$SDCoverage, na.rm = TRUE)
  ci <- if (available) binom.test(covered, available)$conf.int else c(NA, NA)
  data.frame(Condition = x$Condition[1], Raters = x$Raters[1], TrueSD = x$SD[1], Planned = n,
    NumericalReady = sum(x$NumericalReady), PositiveInformation = sum(x$InformationPositive),
    Boundary = sum(x$Boundary), MeanSD = mean_or_na(x$SDEstimate),
    SDBias = mean_or_na(x$SDEstimate - x$SD), SDBiasMCSE = mcse(x$SDEstimate - x$SD),
    SDRMSE = sqrt(mean_or_na((x$SDEstimate - x$SD)^2)),
    ProfileAvailable = available, ProfileCovered = covered,
    ProfileCoverage = if (available) covered / available else NA_real_,
    CoverageMCLower = ci[1], CoverageMCUpper = ci[2],
    PlannedCoverageLower = covered / n, PlannedCoverageUpper = (covered + n - available) / n,
    ProfileMeanWidth = mean_or_na(x$SDUpper - x$SDLower),
    RaterIntervalsAvailable = sum(is.finite(x$RaterCoverage)),
    MeanRaterCoverage = mean_or_na(x$RaterCoverage), RaterCoverageMCSE = mcse(x$RaterCoverage),
    MeanRaterRMSE = mean_or_na(x$RaterRMSE),
    FixedIntervalsAvailable = sum(is.finite(x$FixedCoverage)),
    MeanFixedCoverage = mean_or_na(x$FixedCoverage), FixedCoverageMCSE = mcse(x$FixedCoverage),
    MedianSeconds = median(x$Seconds))
}))
write.csv(summary, file.path(root, "summary.csv"), row.names = FALSE)
# Keep named targets distinct, rather than hiding offsetting biases in a mean.
fixed <- do.call(rbind, lapply(trials, function(x) {
  if (is.null(x$fit)) return(NULL)
  z <- subset(x$fit$calibration_table, Parameter != "Population SD")
  z$Truth <- c(x$truth$criterion, x$truth$steps)
  z$Condition <- x$roster$Condition; z$Replicate <- x$roster$Replicate
  z$NumericalReady <- x$fit$checks$NumericalReady
  z
}))
write.csv(fixed, file.path(root, "fixed-targets.csv"), row.names = FALSE)
fixed_summary <- do.call(rbind, lapply(split(fixed, interaction(fixed$Condition, fixed$Parameter, fixed$Level, drop = TRUE)), function(z) {
  ready <- z$NumericalReady; available <- is.finite(z$Lower) & is.finite(z$Upper)
  data.frame(Condition = z$Condition[1], Parameter = z$Parameter[1], Level = z$Level[1],
    EstimateAvailable = sum(ready), Bias = mean_or_na(z$Estimate[ready] - z$Truth[ready]),
    BiasMCSE = mcse(z$Estimate[ready] - z$Truth[ready]), IntervalAvailable = sum(available),
    Coverage = mean_or_na(as.numeric(z$Lower[available] <= z$Truth[available] & z$Upper[available] >= z$Truth[available])))
}))
write.csv(fixed_summary, file.path(root, "fixed-summary.csv"), row.names = FALSE)
print(summary, row.names = FALSE)
print(fixed_summary, row.names = FALSE)
print(rows[nzchar(rows$Error), c("Condition", "Replicate", "Error")], row.names = FALSE)
