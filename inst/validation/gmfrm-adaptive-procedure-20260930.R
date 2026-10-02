# Nine retained-data checks of the frozen interval procedure, not a coverage study.
# Rscript inst/validation/gmfrm-adaptive-procedure-20260930.R OUTPUT [neutral|neutral_em]
gmfrm_adaptive_refine <- function(checks, order) {
  is.data.frame(checks) && all(c("Check", "Passed") %in% names(checks)) &&
    !anyNA(checks$Passed) && order < 121L &&
    identical(checks$Check[!checks$Passed], "Quadrature sensitivity")
}

gmfrm_adaptive_procedure_check <- function() {
  checks <- data.frame(Check = c("Joint information", "Quadrature sensitivity"),
    Passed = c(TRUE, FALSE))
  stopifnot(gmfrm_adaptive_refine(checks, 31L), gmfrm_adaptive_refine(checks, 61L),
    !gmfrm_adaptive_refine(checks, 121L), !gmfrm_adaptive_refine(NULL, 31L))
  checks$Passed <- TRUE
  stopifnot(!gmfrm_adaptive_refine(checks, 31L))
  checks$Passed <- FALSE
  stopifnot(!gmfrm_adaptive_refine(checks, 31L))
  checks$Passed[1] <- NA
  stopifnot(!gmfrm_adaptive_refine(checks, 31L))
}

gmfrm_adaptive_capture <- function(call) {
  value <- NULL; error <- ""; error_condition <- NULL; warnings <- character()
  timing <- system.time(withCallingHandlers(tryCatch(value <- call(),
    error = function(e) {
      error <<- conditionMessage(e); error_condition <<- e
    }), warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning")
    }))
  list(value = value, error = error, error_condition = error_condition, warnings = unique(warnings),
    seconds = unname(timing[["elapsed"]]), cpu = sum(timing[1:2]))
}

gmfrm_adaptive_procedure <- function(data, plan) {
  stages <- list()
  for (q in plan$orders) {
    fitting <- gmfrm_adaptive_capture(function() fit_mfrm(data,
      person = "Person", facets = c("Task", "Rater"), score = "Score",
      model = "GPCM", method = "MML", slope_facet = c("Task", "Rater"),
      step_facet = "Rater", noncenter_facet = "Rater",
      gpcm_mml_identification = "fixed_standard_normal", mml_engine = "direct",
      mml_integration = "adaptive", optimizer = "BFGS", rating_min = 0,
      rating_max = 2, category_policy = "preserve", quad_points = q,
      maxit = plan$maxit, reltol = plan$reltol,
      gpcm_mml_start = plan$initialization %||% "neutral"))
    inference <- if (is.null(fitting$value)) list(value = NULL, error = "Source unavailable",
      warnings = character(), seconds = 0, cpu = 0) else gmfrm_adaptive_capture(function()
        confint(fitting$value, method = "model", level = plan$level))
    retry <- !nzchar(inference$error) &&
      gmfrm_adaptive_refine(attr(inference$value, "checks"), q)
    stages[[as.character(q)]] <- list(order = q, fitting = fitting,
      inference = inference, retry = retry)
    if (!retry) break
  }
  stages
}

gmfrm_adaptive_procedure_run <- function(out, policy = "neutral") {
  policy <- match.arg(policy, c("neutral", "neutral_em"))
  gmfrm_adaptive_procedure_check()
  baseline <- "validation-results/gmfrm-sparse-intervals-20260928"
  keys <- c("common_persons-1", "rotating_pairs-1", "common_persons-0.5", "rotating_pairs-0.5")
  jobs <- c(unlist(lapply(1:2, function(id) sprintf("%03d-%s.rds", id, keys))),
    "026-rotating_pairs-0.5.rds")
  plan <- list(orders = c(31L, 61L, 121L), maxit = 500L, reltol = 1e-10,
    level = .95, cores = 2L, jobs = jobs, initialization = policy)
  paths <- file.path(baseline, jobs)
  stopifnot(all(file.exists(paths)))
  source_files <- c("inst/validation/gmfrm-adaptive-procedure-20260930.R",
    "DESCRIPTION", "NAMESPACE", sort(list.files("R", "[.]R$", full.names = TRUE)),
    sort(list.files("src", "[.](cpp|h)$", full.names = TRUE)),
    getLoadedDLLs()[["mfrmr"]][["path"]])
  source_hashes <- function() {
    hashes <- tools::md5sum(source_files)
    # pkgload copies the same binary to a new temporary path in each R process.
    names(hashes)[length(hashes)] <- "loaded:mfrmr"
    hashes
  }
  hashes <- source_hashes()
  manifest <- list(plan = plan, source_hashes = hashes, input_hashes = tools::md5sum(paths),
    baseline_hash = tools::md5sum(file.path(baseline, "manifest.rds")))
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  manifest_file <- file.path(out, "manifest.rds")
  if (file.exists(manifest_file)) stopifnot(identical(readRDS(manifest_file), manifest)) else {
    saveRDS(manifest, manifest_file)
    writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
    for (i in seq_along(source_files)) {
      p <- source_files[i]
      dest <- file.path(out, "source", if (startsWith(p, "/")) basename(p) else p)
      dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
      stopifnot(file.copy(p, dest), unname(tools::md5sum(dest)) == unname(hashes[i]))
    }
    stopifnot(file.copy("inst/validation/internal-roadmap-0.2.4.md",
      file.path(out, "protocol-before-execution.md")))
  }
  started <- proc.time()[["elapsed"]]
  done <- parallel::mclapply(jobs, function(job) {
    file <- file.path(out, job)
    if (file.exists(file)) {
      old <- readRDS(file)
      stopifnot(identical(old$source_hashes, hashes), identical(old$input_hashes, manifest$input_hashes))
      return(TRUE)
    }
    original <- readRDS(file.path(baseline, job))
    stages <- gmfrm_adaptive_procedure(original$case$data, plan)
    stopifnot(identical(source_hashes(), hashes),
      identical(tools::md5sum(paths), manifest$input_hashes))
    result <- list(job = job, case = original$case, seed = original$seed,
      stages = stages, source_hashes = hashes, input_hashes = manifest$input_hashes)
    saveRDS(result, paste0(file, ".tmp"))
    stopifnot(file.rename(paste0(file, ".tmp"), file))
    final <- tail(stages, 1L)[[1]]
    cat(job, "order", final$order, "intervals",
      sum(attr(final$inference$value, "diagnostics")$CIEligible), "seconds",
      sum(vapply(stages, function(s) s$fitting$seconds + s$inference$seconds, 0)), "\n")
    flush.console(); TRUE
  }, mc.cores = plan$cores, mc.preschedule = FALSE, mc.set.seed = FALSE)
  stopifnot(all(vapply(done, isTRUE, logical(1))))
  elapsed <- proc.time()[["elapsed"]] - started
  records <- lapply(file.path(out, jobs), readRDS)
  stages <- do.call(rbind, lapply(records, function(z) do.call(rbind, lapply(z$stages, function(s) {
    fit <- s$fitting$value; ci <- s$inference$value
    checks <- attr(ci, "checks"); numerical <- attr(ci, "numerical_checks")
    scalar <- function(name) if (is.null(numerical[[name]])) NA_real_ else numerical[[name]][1]
    slopes <- fit$slopes$Estimate
    data.frame(Job = z$job, Order = s$order, Converged = isTRUE(fit$summary$Converged),
      Available = sum(attr(ci, "diagnostics")$CIEligible),
      Failure = paste(checks$Check[!checks$Passed], collapse = "; "),
      FitError = s$fitting$error, InferenceError = s$inference$error, Retry = s$retry,
      MinimumSlope = if (length(slopes)) min(slopes) else NA_real_,
      MaximumSlope = if (length(slopes)) max(slopes) else NA_real_,
      NewtonDisplacement = scalar("CurvatureScaledGradient"),
      QuadratureScoreShift = scalar("QuadratureScoreShift"),
      QuadratureCovarianceChange = scalar("QuadratureCovarianceChange"),
      OptimizerStages = nrow(fit$opt$optimizer_polish$Stages) %||% 0L,
      FitSeconds = s$fitting$seconds, InferenceSeconds = s$inference$seconds,
      CPUSeconds = s$fitting$cpu + s$inference$cpu)
  }))))
  write.csv(stages, file.path(out, "stages.csv"), row.names = FALSE)
  disposition <- stages[!duplicated(stages$Job, fromLast = TRUE), ]
  totals <- rowsum(stages$FitSeconds + stages$InferenceSeconds, stages$Job)
  disposition$TotalSeconds <- drop(totals[disposition$Job, ])
  write.csv(disposition, file.path(out, "dispositions.csv"), row.names = FALSE)
  run <- list(elapsed = elapsed, fit_seconds = sum(stages$FitSeconds),
    inference_seconds = sum(stages$InferenceSeconds), cpu_seconds = sum(stages$CPUSeconds),
    complete_jobs = length(records), cores = plan$cores)
  # Replays of completed jobs must not overwrite the original timing measurement.
  if (!file.exists(file.path(out, "timing.rds"))) saveRDS(run, file.path(out, "timing.rds"))
  print(disposition, row.names = FALSE); print(run)
  invisible(disposition)
}

if (sys.nframe() == 0L) {
  pkgload::load_all(".", quiet = TRUE, compile = FALSE)
  args <- commandArgs(trailingOnly = TRUE)
  stopifnot(length(args) %in% 1:2)
  gmfrm_adaptive_procedure_run(args[1], if (length(args) == 2L) args[2] else "neutral")
}
