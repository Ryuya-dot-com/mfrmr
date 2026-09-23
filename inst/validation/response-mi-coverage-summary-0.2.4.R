# No fitting or sampling: summarize every planned independent dataset.
args <- commandArgs(TRUE)
directory <- if (length(args)) args[1] else "validation-results/response-mi-coverage-20260923"
plan <- readRDS(file.path(directory, "plan.rds"))
binomial <- function(x) {
  n <- length(x)
  if (!n) return(c(N = 0, Estimate = NA, MCSE = NA, Lower = NA, Upper = NA))
  est <- mean(x); ci <- binom.test(sum(x), n)$conf.int
  c(N = n, Estimate = est, MCSE = sqrt(est * (1 - est) / n), Lower = ci[1], Upper = ci[2])
}
mean_mc <- function(x) {
  x <- x[is.finite(x)]; n <- length(x)
  if (!n) return(c(N = 0, Estimate = NA, MCSE = NA, Lower = NA, Upper = NA))
  se <- if (n > 1) sd(x) / sqrt(n) else NA_real_
  delta <- if (n > 1) qt(.975, n - 1) * se else NA_real_
  c(N = n, Estimate = mean(x), MCSE = se, Lower = mean(x) - delta, Upper = mean(x) + delta)
}
rows <- diagnostics <- fit_reviews <- list()
for (id in seq_len(plan$replications)) for (mask in c("MAR", "MNAR")) {
  path <- file.path(directory, sprintf("trial-%04d-%s.rds", id, mask))
  if (!file.exists(path)) stop("The main sample is incomplete: ", path)
  x <- readRDS(path)
  stopifnot(identical(x$id, id), identical(x$mask, mask), !x$preflight,
    x$seed == 92231000L + id, nrow(x$data) == 480L,
    sum(!x$data$Assigned) == 20L,
    all(is.na(x$data$Score[!x$data$Assigned])),
    all(x$data$Score[!is.na(x$data$Score)] == x$generating_scores[!is.na(x$data$Score)]))
  for (method in c("MML", "Bayes", "MI")) {
    a <- x$methods[[method]]
    available <- !is.null(a) && nrow(a) == 1L &&
      all(is.finite(unlist(a[c("Estimate", "SE", "Lower", "Upper")]))) &&
      a$SE > 0 && a$Lower < a$Upper
    take <- function(name) if (!is.null(a) && name %in% names(a)) as.numeric(a[[name]]) else NA_real_
    rows[[length(rows) + 1L]] <- data.frame(Id = id, Mask = mask, Method = method,
      Available = available, Estimate = take("Estimate"), SE = take("SE"),
      Lower = take("Lower"), Upper = take("Upper"),
      Covered = if (available) a$Lower <= plan$truth && a$Upper >= plan$truth else NA,
      Error = take("Estimate") - plan$truth,
      Width = take("Upper") - take("Lower"),
      WithinVariance = take("WithinVariance"), BetweenVariance = take("BetweenVariance"),
      TotalVariance = take("TotalVariance"), MonteCarloSE = take("MonteCarloSE"),
      Missing = length(x$missing), Assigned = sum(x$data$Assigned), Seconds = x$seconds)
  }
  dg <- x$diagnostics
  diagnostics[[length(diagnostics) + 1L]] <- data.frame(Id = id, Mask = mask,
    SamplingReady = isTRUE(x$sampling_ready),
    MaxRhat = if (!is.null(dg)) max(dg$rhat) else NA,
    MinBulkESS = if (!is.null(dg)) min(dg$ess_bulk) else NA,
    MinTailESS = if (!is.null(dg)) min(dg$ess_tail) else NA,
    MaxGridDifference = if (!is.null(x$grid)) max(x$grid) else NA,
    ErrorStages = paste(names(x$errors), collapse = " | "),
    Errors = paste(unlist(x$errors), collapse = " | "),
    Warnings = paste(unique(unlist(x$warnings)), collapse = " | "))
  if (!is.null(x$analyses)) fit_reviews[[length(fit_reviews) + 1L]] <-
    cbind(Id = id, Mask = mask, x$analyses$analysis_summary)
}
rows <- do.call(rbind, rows)
diagnostics <- do.call(rbind, diagnostics)
fit_reviews <- do.call(rbind, fit_reviews)
stopifnot(nrow(rows) == plan$replications * 2L * 3L,
  !anyDuplicated(rows[c("Id", "Mask", "Method")]))
groups <- split(rows, list(rows$Mask, rows$Method), drop = TRUE)
summary <- do.call(rbind, lapply(groups, function(d) {
  a <- d[d$Available, ]
  cv <- binomial(a$Covered); av <- binomial(d$Available)
  joint <- binomial(d$Available & !is.na(d$Covered) & d$Covered)
  bias <- mean_mc(a$Error); width <- mean_mc(a$Width)
  coverage_decision <- if (!is.finite(cv["Upper"])) "unavailable" else
    if (cv["Upper"] < .925) "adverse_undercoverage" else
    if (cv["Lower"] >= .925 && cv["Estimate"] <= .975) "bounded_support" else "inconclusive"
  bias_decision <- if (!is.finite(bias["Lower"])) "unavailable" else
    if (bias["Lower"] > .05 || bias["Upper"] < -.05) "adverse_bias" else
    if (bias["Lower"] >= -.05 && bias["Upper"] <= .05) "bounded_support" else "inconclusive"
  availability_decision <- if (av["Lower"] >= .95) "bounded_support" else "inconclusive"
  decision <- if (grepl("^adverse", coverage_decision)) coverage_decision else
    if (grepl("^adverse", bias_decision)) bias_decision else
    if (all(c(coverage_decision, bias_decision, availability_decision) == "bounded_support")) "bounded_support" else "inconclusive"
  data.frame(Mask = d$Mask[1], Method = d$Method[1], Planned = nrow(d),
    Available = nrow(a), Availability = av["Estimate"], AvailabilityLower = av["Lower"],
    AvailabilityUpper = av["Upper"], Coverage = cv["Estimate"], CoverageMCSE = cv["MCSE"],
    CoverageLower = cv["Lower"], CoverageUpper = cv["Upper"],
    JointAvailableCovered = joint["Estimate"], JointLower = joint["Lower"], JointUpper = joint["Upper"],
    Bias = bias["Estimate"], BiasMCSE = bias["MCSE"], BiasLower = bias["Lower"], BiasUpper = bias["Upper"],
    RMSE = sqrt(mean(a$Error^2)), EmpiricalSD = sd(a$Estimate), MeanSE = mean(a$SE),
    Width = width["Estimate"], WidthMCSE = width["MCSE"],
    MeanMissing = mean(d$Missing), MeanMissingFraction = mean(d$Missing / d$Assigned),
    MeanWithinVariance = if (all(is.na(a$WithinVariance))) NA else mean(a$WithinVariance),
    MeanBetweenVariance = if (all(is.na(a$BetweenVariance))) NA else mean(a$BetweenVariance),
    MeanTotalVariance = if (all(is.na(a$TotalVariance))) NA else mean(a$TotalVariance),
    MeanMI_MCSE_to_SE = if (all(is.na(a$MonteCarloSE))) NA else mean(a$MonteCarloSE / a$SE),
    CoverageDecision = coverage_decision, BiasDecision = bias_decision,
    AvailabilityDecision = availability_decision, Decision = decision, row.names = NULL)
}))
paired <- list()
for (mask in c("MAR", "MNAR")) for (reference in c("MML", "Bayes")) {
  a <- rows[rows$Mask == mask & rows$Method == "MI", ]
  b <- rows[rows$Mask == mask & rows$Method == reference, ]
  b <- b[match(a$Id, b$Id), ]; keep <- a$Available & b$Available
  for (metric in c("Estimate", "Width", "Covered")) {
    delta <- as.numeric(a[[metric]][keep]) - as.numeric(b[[metric]][keep])
    z <- mean_mc(delta)
    paired[[length(paired) + 1L]] <- data.frame(Mask = mask, Comparison = paste("MI minus", reference),
      Metric = metric, N = sum(keep), Difference = z["Estimate"], MCSE = z["MCSE"],
      Lower = z["Lower"], Upper = z["Upper"], row.names = NULL)
  }
}
paired <- do.call(rbind, paired)
for (name in c("rows", "summary", "paired", "diagnostics", "fit_reviews"))
  write.csv(get(name), file.path(directory, paste0(name, ".csv")), row.names = FALSE)
saveRDS(list(plan = plan, rows = rows, summary = summary, paired = paired,
  diagnostics = diagnostics, fit_reviews = fit_reviews,
  summary_source = tools::md5sum("inst/validation/response-mi-coverage-summary-0.2.4.R")),
  file.path(directory, "summary.rds"))
print(summary[c("Mask", "Method", "Available", "Coverage", "CoverageLower", "CoverageUpper", "Bias", "Width", "Decision")], row.names = FALSE)
