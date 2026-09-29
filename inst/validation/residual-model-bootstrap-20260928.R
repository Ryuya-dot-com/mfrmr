# Repository-only pilot. Run from the package root; does not run in examples/check.
# Rscript inst/validation/residual-model-bootstrap-20260928.R setup <directory>
# Rscript inst/validation/residual-model-bootstrap-20260928.R run <directory> [cores]
# Rscript inst/validation/residual-model-bootstrap-20260928.R summary <directory>

residual_pilot_conditions <- function() {
  data.frame(Condition = c("rsm_null_dense", "pcm_null_dense", "block_dense",
      "sd15_dense", "null_common", "null_rotating", "block_common", "block_rotating"),
    Model = c("RSM", "PCM", rep("RSM", 6)),
    Design = c(rep("dense", 4), "common", "rotating", "common", "rotating"),
    Scenario = c("null", "null", "block", "sd15", "null", "null", "block", "block"),
    stringsAsFactors = FALSE)
}

residual_pilot_data <- function(condition, seed) {
  set.seed(seed)
  n <- 80L
  theta <- rnorm(n)
  block <- matrix(rnorm(n * 2L), n, 2L)
  # Var(z_b)=1, Cor(z_1,z_2)=.5: either shared ability + block effects
  # or a two-trait simple-structure model, with exactly the same response law.
  z <- if (condition$Scenario == "block") sqrt(.5) * (theta + block) else {
    matrix(theta * if (condition$Scenario == "sd15") 1.5 else 1, n, 2L)
  }
  data <- expand.grid(Person = sprintf("P%03d", seq_len(n)),
    Rater = paste0("R", 1:4), Criterion = paste0("C", 1:6),
    stringsAsFactors = FALSE)
  p <- match(data$Person, unique(data$Person))
  r <- match(data$Rater, unique(data$Rater))
  c <- match(data$Criterion, unique(data$Criterion))
  eta <- z[cbind(p, ifelse(c <= 3L, 1L, 2L))] -
    c(-.45, -.15, .15, .45)[r] - seq(-.5, .5, length.out = 6)[c]
  width <- if (condition$Model == "PCM") seq(.35, .85, length.out = 6)[c] else .6
  logp <- cbind(0, eta + width, 2 * eta)
  prob <- exp(logp - apply(logp, 1, max))
  prob <- prob / rowSums(prob)
  u <- runif(nrow(data))
  data$Score <- (u > prob[, 1]) + (u > prob[, 1] + prob[, 2])
  keep <- if (condition$Design == "common") {
    # Eight common Persons (all raters), 56 panel Persons (two raters),
    # and 16 single-rater Persons: 160 Person-rater cells, 40 per rater.
    p <= 8L | (p %in% 9:36 & r <= 2L) | (p %in% 37:64 & r >= 3L) |
      (p >= 65L & r == (p - 65L) %% 4L + 1L)
  } else if (condition$Design == "rotating") {
    first <- (p - 1L) %% 4L + 1L
    r == first | r == first %% 4L + 1L
  } else rep(TRUE, nrow(data))
  data <- data[keep, ]; rownames(data) <- NULL
  data
}

residual_pilot_setup <- function(directory) {
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(directory, "protocol.rds")
  if (file.exists(path)) stop("The protocol already exists; do not overwrite it.")
  conditions <- residual_pilot_conditions()
  roster <- merge(conditions, data.frame(Replicate = 1:12), by = NULL)
  roster$ID <- sprintf("%s-%02d", roster$Condition, roster$Replicate)
  roster$DataSeed <- 202609280L + roster$Replicate
  roster$ReferenceSeed <- 902800L + roster$Replicate
  paths <- c(sort(list.files("R", full.names = TRUE, pattern = "\\.R$")),
    sort(list.files("src", full.names = TRUE, pattern = "\\.(cpp|h)$")), "DESCRIPTION",
    "inst/validation/residual-model-bootstrap-20260928.R")
  paths <- paths[file.exists(paths)]
  protocol <- list(roster = roster, source = tools::md5sum(paths),
    outer_reps = 12L, bootstrap_reps = 39L, quantile = .95, persons = 80L,
    quad_points = 31L, maxit = 400L, reltol = 1e-9,
    purpose = "Pilot for gross miscalibration, scope availability and alternative sensitivity; not release qualification",
    primary = "First Criterion residual eigenvalue above componentwise model-bootstrap cutoff",
    secondary = "Any Criterion eigenvalue above its unadjusted cutoff; first overall eigenvalue; scope availability",
    failure = "Retain all planned datasets and all bootstrap attempts; report missing-outcome bounds, never replace failures",
    session = sessionInfo())
  saveRDS(protocol, path)
  write.csv(roster, file.path(directory, "roster.csv"), row.names = FALSE)
}

residual_pilot_one <- function(row, protocol, directory) {
  path <- file.path(directory, paste0(row$ID, ".rds"))
  if (file.exists(path)) return(row$ID)
  warnings <- character()
  start <- proc.time()[[3]]
  outcome <- tryCatch(withCallingHandlers({
    data <- residual_pilot_data(row, row$DataSeed)
    fit <- fit_mfrm(data, "Person", c("Rater", "Criterion"), "Score",
      model = row$Model, method = "MML",
      step_facet = if (row$Model == "PCM") "Criterion" else NULL,
      rating_min = 0, rating_max = 2, quad_points = protocol$quad_points,
      maxit = protocol$maxit, reltol = protocol$reltol, attach_diagnostics = FALSE)
    pca <- analyze_residual_pca(fit, mode = "both", parallel = TRUE,
      parallel_method = "model_bootstrap", parallel_reps = protocol$bootstrap_reps,
      parallel_quantile = protocol$quantile, seed = row$ReferenceSeed)
    list(pca = pca, responses = nrow(data),
      readiness = mfrmr_get_readiness_record(fit)$fit)
  }, warning = function(w) {
    warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning")
  }), error = function(e) list(error = conditionMessage(e)))
  outcome$row <- row
  outcome$warnings <- unique(warnings)
  outcome$elapsed <- proc.time()[[3]] - start
  temporary <- paste0(path, ".tmp")
  saveRDS(outcome, temporary)
  stopifnot(file.rename(temporary, path))
  message(row$ID, ": ", if (is.null(outcome$error)) "recorded" else outcome$error)
  row$ID
}

residual_pilot_summary <- function(protocol, directory) {
  rows <- lapply(seq_len(nrow(protocol$roster)), function(i) {
    row <- protocol$roster[i, ]
    path <- file.path(directory, paste0(row$ID, ".rds"))
    x <- if (file.exists(path)) readRDS(path) else list(error = "Not run")
    criterion <- x$pca$by_facet$Criterion$parallel$table
    overall <- x$pca$overall$parallel$table
    rater <- x$pca$by_facet$Rater$parallel$table
    available <- function(z) is.data.frame(z) && nrow(z) > 0L
    flag <- function(z, any_component = FALSE) {
      if (!available(z)) return(NA)
      if (any_component) any(z$ExceedsParallelCutoff) else z$ExceedsParallelCutoff[1]
    }
    data.frame(row, Completed = file.exists(path), SourceError = x$error %||% "",
      CriterionAvailable = available(criterion), PrimaryFlag = flag(criterion),
      AnyCriterionFlag = flag(criterion, TRUE), OverallAvailable = available(overall),
      OverallFirstFlag = flag(overall), RaterAvailable = available(rater),
      Elapsed = x$elapsed %||% NA_real_, stringsAsFactors = FALSE)
  })
  outcomes <- do.call(rbind, rows)
  summaries <- lapply(split(outcomes, outcomes$Condition), function(z) {
    do.call(rbind, lapply(c("PrimaryFlag", "AnyCriterionFlag", "OverallFirstFlag"), function(metric) {
      known <- !is.na(z[[metric]]); flagged <- sum(z[[metric]][known]); n <- nrow(z)
      missing <- sum(!known)
      data.frame(Condition = z$Condition[1], Metric = metric, Planned = n,
        Available = sum(known), Flagged = flagged, Unavailable = missing,
        RateAmongAvailable = if (any(known)) flagged / sum(known) else NA_real_,
        RateLower = flagged / n, RateUpper = (flagged + missing) / n,
        MonteCarloLower = binom.test(flagged, n)$conf.int[1],
        MonteCarloUpper = binom.test(flagged + missing, n)$conf.int[2])
    }))
  })
  summary <- do.call(rbind, summaries); rownames(summary) <- NULL
  write.csv(outcomes, file.path(directory, "outcomes.csv"), row.names = FALSE)
  write.csv(summary, file.path(directory, "summary.csv"), row.names = FALSE)
  print(summary, row.names = FALSE)
  invisible(list(outcomes = outcomes, summary = summary))
}

if (sys.nframe() == 0L) {
  args <- commandArgs(TRUE)
  stopifnot(length(args) >= 2L, args[1] %in% c("setup", "run", "summary"))
  pkgload::load_all(quiet = TRUE, compile = FALSE)
  directory <- args[2]
  if (args[1] == "setup") {
    residual_pilot_setup(directory)
  } else {
    protocol <- readRDS(file.path(directory, "protocol.rds"))
    if (args[1] == "run") {
      stopifnot(identical(tools::md5sum(names(protocol$source)), protocol$source))
      cores <- if (length(args) >= 3L) as.integer(args[3]) else 1L
      pending <- which(!file.exists(file.path(directory, paste0(protocol$roster$ID, ".rds"))))
      parallel::mclapply(pending, function(i) {
        residual_pilot_one(protocol$roster[i, ], protocol, directory)
      }, mc.cores = cores, mc.set.seed = FALSE, mc.preschedule = FALSE)
    } else residual_pilot_summary(protocol, directory)
  }
}
