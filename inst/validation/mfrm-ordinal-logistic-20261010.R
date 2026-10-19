# Run from the package root with the retained October 9 R library.
# Frozen conditional-model contract: see internal-roadmap-0.2.4.md.
pkgload::load_all(".", quiet = TRUE, compile = FALSE)
out <- "validation-results/ordinal-logistic-20261010"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
sources <- c("R/api-ordinal-logistic.R", "inst/validation/mfrm-ordinal-logistic-20261010.R")
identity <- list(md5 = tools::md5sum(sources), R = R.version.string,
  ordinal = as.character(packageVersion("ordinal")),
  settings = list(N = c(40L, 200L, 1000L), replicates = 1000L,
    mechanisms = c("null", "uniform", "crossing", "nonPO_null")))
manifest <- file.path(out, "sampling-identity.rds")
if (file.exists(manifest)) stopifnot(identical(readRDS(manifest), identity)) else saveRDS(identity, manifest)
writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))

grid <- expand.grid(N = identity$settings$N, Mechanism = identity$settings$mechanisms,
  stringsAsFactors = FALSE)
for (cell in seq_len(nrow(grid))) {
  path <- file.path(out, paste0("cell-", cell, ".rds"))
  if (file.exists(path)) { stopifnot(identical(readRDS(path)$identity, identity)); next }
  N <- grid$N[cell]; mechanism <- grid$Mechanism[cell]
  z <- rep(seq(-1, 1, length.out = N / 2), 2)
  g <- rep(0:1, each = N / 2)
  eta <- .8 * z + if (mechanism == "uniform") .6 * g else
    if (mechanism == "crossing") .9 * z * g else 0
  cdf <- if (mechanism == "nonPO_null") cbind(plogis(-.6 - .5 * z), plogis(.9 - 1.3 * z)) else
    cbind(plogis(-.6 - eta), plogis(.9 - eta))
  stopifnot(all(cdf[, 1] < cdf[, 2]))
  d <- data.frame(Person = paste0("P", seq_len(N)), Item = "A", Score = 0L,
    Group = ifelse(g == 0, "R", "F"), Match = z)
  set.seed(20261010L + cell)
  u <- matrix(runif(N * identity$settings$replicates), N)
  responses <- (u > cdf[, 1]) + (u > cdf[, 2])
  records <- model_status <- vector("list", ncol(responses))
  start <- proc.time()[["elapsed"]]
  for (b in seq_len(ncol(responses))) {
    d$Score <- responses[, b]
    a <- ordinal_logistic_table(d, "Person", "Item", "Score", "Group", "Match", c("R", "F"), 0:2)
    v <- rbind(a$table[c("Comparison", "PValue", "PAdjusted", "Status")],
      data.frame(Comparison = "ProportionalOdds", a$proportional_odds[c("PValue", "PAdjusted", "Status")]))
    v$Replicate <- b; records[[b]] <- v
    v <- a$models[c("Model", "Status", "MaxGradient", "MinEigenvalue", "MaxNewtonStep")]
    v$Replicate <- b; model_status[[b]] <- v
  }
  elapsed <- proc.time()[["elapsed"]] - start
  saveRDS(list(identity = identity, cell = grid[cell, ], data = d[c("Person", "Item", "Group", "Match")],
    responses = responses, cdf = cdf, records = do.call(rbind, records),
    model_status = do.call(rbind, model_status), elapsed = elapsed), path)
  cat("Completed", cell, "/", nrow(grid), "N", N, mechanism, "seconds", round(elapsed, 2), "\n")
  flush.console()
}

# Wilson intervals describe Monte Carlo uncertainty, not uncertainty of a user's DIF effect.
wilson <- function(success, n) {
  if (!n) return(c(NA_real_, NA_real_, NA_real_))
  z <- qnorm(.975); p <- success / n
  half <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / (1 + z^2 / n)
  center <- (p + z^2 / (2 * n)) / (1 + z^2 / n)
  c(p, center - half, center + half)
}
summaries <- failures <- vector("list", nrow(grid))
for (cell in seq_len(nrow(grid))) {
  saved <- readRDS(file.path(out, paste0("cell-", cell, ".rds")))
  stopifnot(identical(saved$identity, identity))
  r <- saved$records
  rows <- list()
  for (name in unique(r$Comparison)) {
    v <- r[r$Comparison == name, ]; available <- is.finite(v$PValue)
    for (adjusted in c(FALSE, TRUE)) {
      p <- if (adjusted) v$PAdjusted else v$PValue
      rejected <- sum(p < .05, na.rm = TRUE)
      unc <- wilson(rejected, nrow(v)); cond <- wilson(rejected, sum(available))
      rows[[length(rows) + 1L]] <- data.frame(saved$cell, Comparison = name, Adjusted = adjusted,
        Replicates = nrow(v), Available = sum(available), Rejected = rejected,
        Unconditional = unc[1], UnconditionalLower = unc[2], UnconditionalUpper = unc[3],
        Conditional = cond[1], ConditionalLower = cond[2], ConditionalUpper = cond[3])
    }
  }
  summaries[[cell]] <- do.call(rbind, rows)
  counts <- as.data.frame(table(saved$model_status[c("Model", "Status")]))
  failures[[cell]] <- cbind(saved$cell[rep(1, nrow(counts)), ], counts)
}
write.csv(do.call(rbind, summaries), file.path(out, "sampling-summary.csv"), row.names = FALSE)
write.csv(do.call(rbind, failures), file.path(out, "model-status.csv"), row.names = FALSE)
cat("Saved 12 cells, 12000 attempted target analyses. No fitted MFRM calculations.\n")
