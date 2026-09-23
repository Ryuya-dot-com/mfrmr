# Summarize the frozen outer roster without fitting or selecting successful draws.
pkgload::load_all(".", quiet = TRUE)
out <- "validation-results/random-rater-intervals-20260923/pilot"
protocol <- readRDS(file.path(out, "protocol.rds"))
paths <- file.path(out, sprintf("outer-%02d.rds", seq_len(nrow(protocol$roster))))
if (!all(file.exists(paths))) stop("The planned outer roster is incomplete.")
results <- lapply(paths, readRDS)
stopifnot(all(vapply(seq_along(results), function(i)
  identical(results[[i]]$roster, protocol$roster[i, ]), logical(1))))
rows <- trials <- outer <- list()
for (i in seq_along(results)) {
  x <- results[[i]]; labels <- names(x$truth$rater)
  outer[[i]] <- data.frame(Outer = i, x$roster,
    FitReady = !is.null(x$fit) && isTRUE(x$fit$checks$NumericalReady) &&
      isTRUE(x$fit$checks$InformationPositive),
    Boundary = !is.null(x$fit) && isTRUE(x$fit$checks$EstimatedVarianceBoundary),
    BootstrapAvailable = !is.null(x$intervals), Seconds = unname(x$elapsed["elapsed"]),
    Errors = paste(x$errors, collapse = " | "), Warnings = paste(x$warnings, collapse = " | "))
  if (!is.null(x$intervals)) {
    b <- x$intervals
    stopifnot(nrow(b$error) == protocol$B, nrow(b$trials) == protocol$B,
      identical(b$settings$seed, x$roster$BootstrapSeed),
      identical(b$trials$Seed, b$settings$replicate_seeds),
      identical(colnames(b$error), x$fit$raters$Rater),
      isTRUE(all.equal(b$error, b$truth - b$estimates)),
      isTRUE(all.equal(b$studentized, b$error / b$prediction_se)))
    regenerated <- t(vapply(b$trials$Seed, function(seed) withr::with_seed(seed, {
      rnorm(240)
      u <- setNames(rnorm(length(labels), sd = x$fit$calibration$rater_sd),
        x$fit$input$levels[[x$fit$input$columns$rater]])
      unname(u[colnames(b$truth)])
    }), numeric(length(labels))))
    stopifnot(isTRUE(all.equal(unname(b$truth), unname(regenerated))))
    trials[[length(trials) + 1L]] <- data.frame(Outer = i, Raters = x$roster$Raters,
      x$intervals$trials)
  }
  for (method in c("ordinary", "studentized", "error")) {
    bounds <- matrix(NA_real_, length(labels), 2L, dimnames = list(labels, c("Lower", "Upper")))
    if (method == "ordinary" && !is.null(x$fit)) {
      tab <- x$fit$raters
      bounds[tab$Rater, ] <- cbind(tab$Estimate - qnorm(.975) * tab$PredictionSE,
        tab$Estimate + qnorm(.975) * tab$PredictionSE)
    } else if (!is.null(x$intervals)) {
      ci <- confint(x$intervals, level = .95, method = method)
      bounds[rownames(ci), ] <- ci
    }
    returned <- !is.na(bounds[, 1]) & !is.na(bounds[, 2])
    finite <- returned & is.finite(bounds[, 1]) & is.finite(bounds[, 2])
    rows[[length(rows) + 1L]] <- data.frame(Outer = i, Raters = x$roster$Raters,
      Method = method, Rater = labels, Truth = unname(x$truth$rater[labels]),
      Lower = bounds[, 1], Upper = bounds[, 2], Returned = returned, Finite = finite,
      Covered = ifelse(returned, bounds[, 1] <= x$truth$rater[labels] &
        bounds[, 2] >= x$truth$rater[labels], NA), Width = bounds[, 2] - bounds[, 1])
  }
}
per_rater <- do.call(rbind, rows); outer <- do.call(rbind, outer)
trials <- do.call(rbind, trials)
average <- function(x) if (all(is.na(x))) NA_real_ else mean(x, na.rm = TRUE)
mcse <- function(x) if (sum(!is.na(x)) < 2L) NA_real_ else sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x)))
per_outer <- do.call(rbind, lapply(split(per_rater, interaction(per_rater$Outer,
  per_rater$Method, drop = TRUE)), function(d) data.frame(Outer = d$Outer[1],
    Raters = d$Raters[1], Method = d$Method[1], Targets = nrow(d),
    Returned = sum(d$Returned), Finite = sum(d$Finite), Unbounded = sum(d$Returned & !d$Finite),
    CoverageReturned = average(d$Covered), CoverageFinite = average(d$Covered[d$Finite]),
    WidthReturned = average(d$Width[d$Returned]), WidthFinite = average(d$Width[d$Finite]))))
summary <- do.call(rbind, lapply(split(per_outer, interaction(per_outer$Raters,
  per_outer$Method, drop = TRUE)), function(d) data.frame(Raters = d$Raters[1],
    Method = d$Method[1], PlannedDatasets = nrow(d),
    DatasetsWithReturned = sum(!is.na(d$CoverageReturned)),
    DatasetsWithFinite = sum(!is.na(d$CoverageFinite)),
    Targets = sum(d$Targets), Returned = sum(d$Returned), Finite = sum(d$Finite),
    Unbounded = sum(d$Unbounded), CoverageReturned = average(d$CoverageReturned),
    CoverageReturnedMCSE = mcse(d$CoverageReturned), CoverageFinite = average(d$CoverageFinite),
    CoverageFiniteMCSE = mcse(d$CoverageFinite), WidthReturned = average(d$WidthReturned),
    WidthFinite = average(d$WidthFinite))))
baseline <- per_outer[per_outer$Method == "ordinary", ]
paired <- do.call(rbind, lapply(c("studentized", "error"), function(method) {
  d <- per_outer[per_outer$Method == method, ]
  at <- match(d$Outer, baseline$Outer)
  d$CoverageDifference <- d$CoverageReturned - baseline$CoverageReturned[at]
  do.call(rbind, lapply(split(d, d$Raters), function(z) data.frame(Raters = z$Raters[1],
    Method = method, PairedDatasets = sum(!is.na(z$CoverageDifference)),
    CoverageDifference = average(z$CoverageDifference), PairedMCSE = mcse(z$CoverageDifference))))
}))
for (name in c("per_rater", "per_outer", "outer", "trials", "summary", "paired")) {
  write.csv(get(name), file.path(out, paste0(name, ".csv")), row.names = FALSE)
}
print(summary, row.names = FALSE); print(paired, row.names = FALSE)
cat("Outer sources:", nrow(outer), "ready", sum(outer$FitReady), "boundary", sum(outer$Boundary), "\n")
cat("Bootstrap refits:", nrow(trials), "ready", sum(trials$FitReady),
  "boundary", sum(trials$EstimatedBoundary), "\n")
cat("Bootstrap errors:", sum(nzchar(trials$Error)), "warnings:", sum(nzchar(trials$Warnings)), "\n")
