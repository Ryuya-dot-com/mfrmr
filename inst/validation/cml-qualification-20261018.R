# Reuse the exact eight-cell MML sandwich study, without repeating MML fits.
# Rscript --vanilla inst/validation/cml-qualification-20261018.R preflight
# Rscript --vanilla inst/validation/cml-qualification-20261018.R run
source("inst/validation/facet-sandwich-0.2.4.R")
pkgload::load_all(quiet = TRUE)
directory <- "tmp/cml-20261018"
dir.create(directory, recursive = TRUE, showWarnings = FALSE)
prior <- "validation-results/robust-intervals-20260922"
generator <- "inst/validation/facet-sandwich-0.2.4.R"
sources <- tools::md5sum(c("R/core-cml.R", "R/core-estimability.R", "R/core-data-prep.R",
  "R/mfrm_core.R", "R/api-estimation.R", "R/api-facet-intervals.R", generator))
cells <- sandwich_cells()
targets <- readRDS(file.path(prior, "targets.rds"))
for (cell in cells$Cell) {
  old <- readRDS(file.path(prior, paste0("cell-", cell, ".rds")))
  stopifnot(unname(old$source[generator]) == unname(sources[generator]))
}
run_one <- function(cell, replicate) {
  spec <- cells[cell, ]
  target <- targets[[paste(spec$Model, spec$Adverse, sep = "_")]]
  seed <- 92230000L + 1000L * cell + replicate
  d <- sandwich_generate(target$case, spec$Persons, seed)
  map <- matrix(0, 4L, length(target$case$truth))
  map[1:3, 1:2] <- rbind(c(1, -1), c(2, 1), c(1, 2)); map[4, 3] <- 2
  start <- proc.time()[["elapsed"]]
  warnings <- character()
  fitted <- tryCatch(withCallingHandlers(fit_mfrm(d, "Person", c("Rater", "Criterion"),
    "Score", method = "CML", model = spec$Model,
    step_facet = if (spec$Model == "PCM") "Criterion" else NULL,
    rating_min = 0, rating_max = 2, category_policy = "preserve", reltol = 1e-10),
    warning = function(w) { warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning") }),
    error = identity)
  ok <- inherits(fitted, "mfrm_cml_fit")
  data.frame(Cell = cell, Model = spec$Model, Persons = spec$Persons,
    Adverse = spec$Adverse, Replicate = replicate, Seed = seed,
    Target = c("R1-R2", "R1-R3", "R2-R3", "C1-C2"),
    Truth = drop(map %*% target$case$truth),
    Estimate = if (ok) drop(map %*% fitted$opt$par) else NA_real_,
    SE = if (ok) sqrt(diag(map %*% vcov(fitted) %*% t(map))) else NA_real_,
    Available = ok, Error = if (ok) "" else conditionMessage(fitted),
    Warnings = paste(unique(warnings), collapse = " | "),
    Gradient = if (ok) fitted$checks$gradient_max else NA_real_,
    Seconds = proc.time()[["elapsed"]] - start)
}
action <- commandArgs(trailingOnly = TRUE)[1L]
if (identical(action, "preflight")) {
  rows <- do.call(rbind, lapply(cells$Cell, run_one, replicate = 1L))
  saveRDS(list(rows = rows, source = sources, session = sessionInfo()), file.path(directory, "preflight.rds"))
  print(rows[rows$Target == "R1-R2", c("Cell", "Model", "Persons", "Adverse", "Available", "Seconds", "Error")])
} else if (identical(action, "run")) {
  preflight <- readRDS(file.path(directory, "preflight.rds"))
  stopifnot(identical(sources, preflight$source), all(preflight$rows$Available))
  for (cell in cells$Cell) {
    path <- file.path(directory, paste0("sampling-", cell, ".rds"))
    if (file.exists(path)) {
      stopifnot(identical(readRDS(path)$source, sources))
      next
    }
    rows <- list(preflight$rows[preflight$rows$Cell == cell, ])
    for (i in 2:200) {
      rows[[i]] <- run_one(cell, i)
      if (i %% 50L == 0L) cat("Cell", cell, "completed", i, "of 200\n")
    }
    saveRDS(list(rows = do.call(rbind, rows), source = sources,
      session = sessionInfo()), path)
  }
  rows <- do.call(rbind, lapply(cells$Cell, function(cell)
    readRDS(file.path(directory, paste0("sampling-", cell, ".rds")))$rows))
  old <- read.csv(file.path(prior, "replications.csv"))
  keys <- c("Cell", "Replicate", "Seed", "Target", "Truth")
  paired <- merge(rows, old[c(keys, "Estimate", "ModelSE", "SandwichSE", "Available")],
    by = keys, suffixes = c("CML", "MML"))
  stopifnot(nrow(rows) == 6400L, nrow(paired) == nrow(rows))
  summary <- do.call(rbind, lapply(split(rows, interaction(rows$Cell, rows$Target, drop = TRUE)), function(d) {
    a <- d[d$Available, ]; covered <- abs(a$Estimate - a$Truth) <= qnorm(.975) * a$SE
    ci <- if (nrow(a)) binom.test(sum(covered), nrow(a))$conf.int else c(NA, NA)
    data.frame(d[1L, c("Cell", "Model", "Persons", "Adverse", "Target")],
      Assigned = nrow(d), Available = nrow(a), Covered = sum(covered),
      Coverage = mean(covered), MCLower = ci[1L], MCUpper = ci[2L],
      AvailableAndCovered = sum(covered) / nrow(d), Bias = mean(a$Estimate - a$Truth),
      BiasMCSE = sd(a$Estimate) / sqrt(nrow(a)), EmpiricalSD = sd(a$Estimate), MeanSE = mean(a$SE))
  }))
  write.csv(rows, file.path(directory, "sampling-rows.csv"), row.names = FALSE)
  write.csv(summary, file.path(directory, "sampling-summary.csv"), row.names = FALSE)
  saveRDS(paired, file.path(directory, "paired-mml.rds"))
  print(summary)
} else stop("Use preflight or run.")
