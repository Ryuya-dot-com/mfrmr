# Repository-only matched replay. No new data, statistical tuning or release gate.
# From the development root: Rscript <file> prepare OUTPUT
# Then: Rscript OUTPUT/source/inst/validation/<file> run OUTPUT
# Other modes: check (from development root), summary OUTPUT (frozen runner).
gmfrm_matched_hash_check <- function(hashes) {
  stopifnot(length(hashes) > 0L,
    identical(tools::md5sum(names(hashes)), hashes))
}

gmfrm_matched_save <- function(value, path) {
  saveRDS(value, paste0(path, ".tmp"))
  stopifnot(file.rename(paste0(path, ".tmp"), path))
}

gmfrm_matched_prepare <- function(out) {
  root <- normalizePath(".")
  original <- file.path(root, "validation-results/gmfrm-sparse-intervals-20260928")
  revised <- paste0(original, "-revised")
  starts <- file.path(root, "validation-results/gmfrm-adaptive-start-20260930")
  repair <- file.path(root, "validation-results/gmfrm-adaptive-stationarity-20260930")
  prior <- readRDS(file.path(repair, "replay-manifest.rds"))
  gmfrm_matched_hash_check(prior$source_hashes)
  gmfrm_matched_hash_check(prior$input_hashes)
  plan <- prior$plan
  keys <- c("common_persons-1", "rotating_pairs-1", "common_persons-0.5", "rotating_pairs-0.5")
  plan$jobs <- unlist(lapply(1:100, function(id) sprintf("%03d-%s.rds", id, keys)))
  stopifnot(!dir.exists(out), length(plan$jobs) == 400L)
  input_files <- c(file.path(original, c("manifest.rds", plan$jobs)),
    file.path(revised, c("manifest.rds", plan$jobs)),
    file.path(starts, c("manifest.rds", prior$plan$jobs)),
    file.path(repair, c("replay-manifest.rds", prior$refit_jobs,
      "weak-information-intervals.rds", "binary-identity.rds")))
  input_hashes <- tools::md5sum(input_files)
  stopifnot(!anyNA(input_hashes))
  # The revised comparator must still be the same datasets AND fixed-grid fits.
  for (job in plan$jobs) {
    a <- readRDS(file.path(original, job)); b <- readRDS(file.path(revised, job))
    stopifnot(identical(a$case, b$case), identical(a$seed, b$seed),
      identical(a$fit, b$fit), identical(a$ci, b$original_ci))
  }
  files <- c("DESCRIPTION", "NAMESPACE", "LICENSE",
    list.files(c("R", "data", "man", "inst/extdata"), recursive = TRUE, full.names = TRUE),
    list.files("src", "[.](cpp|h|so)$", full.names = TRUE),
    "inst/validation/gmfrm-adaptive-procedure-20260930.R",
    "inst/validation/gmfrm-adaptive-matched-20260930.R")
  hashes <- tools::md5sum(files)
  stopifnot(!anyNA(hashes), unname(hashes["src/mfrmr.so"]) ==
    readRDS(file.path(repair, "binary-identity.rds"))$loaded_binary_md5)
  dir.create(file.path(out, "source"), recursive = TRUE)
  out <- normalizePath(out)
  for (file in files) {
    dest <- file.path(out, "source", file)
    dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
    stopifnot(file.copy(file, dest), unname(tools::md5sum(dest)) == unname(hashes[file]))
  }
  stopifnot(file.copy("inst/validation/internal-roadmap-0.2.4.md",
    file.path(out, "protocol-before-execution.md")))
  manifest <- list(plan = plan, original = original, revised = revised,
    source_hashes = hashes, input_hashes = input_hashes,
    reused_jobs = prior$plan$jobs, created = Sys.time(),
    session = capture.output(sessionInfo()))
  gmfrm_matched_save(manifest, file.path(out, "manifest.rds"))
  manifest_md5 <- unname(tools::md5sum(file.path(out, "manifest.rds")))
  for (job in prior$plan$jobs) {
    path <- file.path(if (job %in% prior$refit_jobs) repair else starts, job)
    saved <- readRDS(path); stages <- saved$stages
    if (job %in% prior$reused_jobs) {
      eligible <- vapply(stages, function(s) any(vapply(
        s$fitting$value$opt$mml_initialization$attempts, function(a)
          isTRUE(a$value$optimizer_polish$Triggered) && identical(
            a$value$optimizer_diagnostics$ConvergenceReason,
            "code_zero_large_gradient"), TRUE)), TRUE)
      stopifnot(!any(eligible))
    }
    origins <- path
    if (identical(job, "026-rotating_pairs-0.5.rds")) {
      origins <- c(origins, file.path(repair, "weak-information-intervals.rds"))
      stopifnot(length(stages) == 1L)
      stages[[1]]$inference <- readRDS(origins[2])$inference
    }
    result <- list(job = job, manifest_md5 = manifest_md5, stages = stages,
      provenance = list(kind = "reused", files = tools::md5sum(origins),
        prior_source_hashes = saved$source_hashes,
        prior_input_hashes = saved$input_hashes %||% saved$input_hash))
    gmfrm_matched_save(result, file.path(out, job))
  }
  gmfrm_matched_hash_check(input_hashes)
  cat("Prepared 400 matched jobs; retained 9 prior results; 391 fits remain.\n")
  invisible(out)
}

gmfrm_matched_load <- function(out) {
  out <- normalizePath(out)
  m <- readRDS(file.path(out, "manifest.rds"))
  frozen <- file.path(out, "source")
  script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
  stopifnot(identical(normalizePath(script), normalizePath(file.path(frozen,
    "inst/validation/gmfrm-adaptive-matched-20260930.R"))))
  expected <- m$source_hashes
  names(expected) <- file.path(frozen, names(expected))
  gmfrm_matched_hash_check(expected)
  gmfrm_matched_hash_check(m$input_hashes)
  setwd(frozen)
  pkgload::load_all(".", quiet = TRUE, compile = FALSE, helpers = FALSE)
  stopifnot(unname(tools::md5sum(getLoadedDLLs()[["mfrmr"]][["path"]])) ==
    unname(m$source_hashes["src/mfrmr.so"]))
  source("inst/validation/gmfrm-adaptive-procedure-20260930.R")
  m
}

gmfrm_matched_record <- function(out, job, manifest_md5) {
  z <- readRDS(file.path(out, job))
  stopifnot(identical(z$job, job), identical(z$manifest_md5, manifest_md5),
    length(z$stages) > 0L, is.list(z$provenance))
  z
}

gmfrm_matched_run <- function(out, m) {
  lock <- file.path(out, "RUNNING")
  if (!dir.create(lock, showWarnings = FALSE))
    stop("RUNNING exists. Check its PID before removing a stale lock and resuming.")
  on.exit(unlink(lock, recursive = TRUE), add = TRUE)
  writeLines(as.character(Sys.getpid()), file.path(lock, "pid"))
  writeLines(capture.output(sessionInfo()), file.path(out, "execution-session.txt"))
  manifest_md5 <- unname(tools::md5sum(file.path(out, "manifest.rds")))
  finished <- m$plan$jobs[file.exists(file.path(out, m$plan$jobs))]
  invisible(lapply(finished, function(job) gmfrm_matched_record(out, job, manifest_md5)))
  pending <- setdiff(m$plan$jobs, finished)
  gmfrm_adaptive_procedure_check()
  cat(format(Sys.time(), tz = "Asia/Tokyo"), "JST: starting", length(pending),
    "pending jobs on", m$plan$cores, "workers\n"); flush.console()
  timing <- system.time(done <- parallel::mclapply(pending, function(job) {
    input <- file.path(m$original, job)
    inputs <- m$input_hashes[c(input, file.path(m$revised, job))]
    gmfrm_matched_hash_check(inputs)
    original <- readRDS(input)
    stages <- gmfrm_adaptive_procedure(original$case$data, m$plan)
    gmfrm_matched_hash_check(m$source_hashes)
    gmfrm_matched_hash_check(inputs)
    result <- list(job = job, manifest_md5 = manifest_md5, stages = stages,
      provenance = list(kind = "refit", source_hashes = m$source_hashes, input_hashes = inputs))
    gmfrm_matched_save(result, file.path(out, job))
    final <- tail(stages, 1L)[[1]]
    cat(format(Sys.time(), tz = "Asia/Tokyo"), job, "order", final$order,
      "intervals", sum(attr(final$inference$value, "diagnostics")$CIEligible),
      "seconds", sum(vapply(stages, function(s) s$fitting$seconds + s$inference$seconds, 0)), "\n")
    flush.console(); TRUE
  }, mc.cores = m$plan$cores, mc.preschedule = FALSE, mc.set.seed = FALSE))
  stopifnot(all(vapply(done, isTRUE, TRUE)))
  gmfrm_matched_hash_check(m$source_hashes)
  gmfrm_matched_hash_check(m$input_hashes)
  gmfrm_matched_save(list(started_jobs = pending, timing = timing, completed = Sys.time()),
    file.path(out, paste0("run-", format(Sys.time(), "%Y%m%d-%H%M%S"), ".rds")))
  gmfrm_matched_summary(out, m)
  cat("All 400 paired records and summaries saved.\n")
}

gmfrm_matched_rows <- function(original, fit, ci, arm, job, error = "") {
  truth <- original$case$truth; n <- nrow(truth)
  estimate <- se <- lower <- upper <- rep(NA_real_, n)
  available <- rep(FALSE, n)
  qualified <- isTRUE(fit$summary$Converged) &&
    identical(fit$opt$optimizer_diagnostics$ConvergenceSeverity, "pass") &&
    length(fit$opt$par) > 0L && all(is.finite(fit$opt$par)) &&
    length(fit$opt$value) == 1L && is.finite(fit$opt$value)
  if (!is.null(fit)) {
    index <- mfrm_match_slope_table(truth$SlopeOwner, truth$SlopeLevel, fit$slopes)
    stopifnot(length(index) == n, !anyNA(index))
    estimate <- fit$slopes$Estimate[index]
  }
  if (!is.null(ci)) {
    tab <- attr(ci, "diagnostics")
    stopifnot(identical(tab$SlopeOwner, truth$SlopeOwner),
      identical(tab$SlopeLevel, truth$SlopeLevel), !anyNA(tab$CIEligible),
      isTRUE(all.equal(tab$Estimate, estimate, tolerance = 1e-12)))
    available <- tab$CIEligible
    stopifnot(!any(available) || qualified,
      all(is.finite(tab$CI_Lower[available]) & tab$CI_Lower[available] > 0),
      all(is.finite(tab$CI_Upper[available]) & tab$CI_Upper[available] > tab$CI_Lower[available]),
      all(is.finite(tab$LogSE[available]) & tab$LogSE[available] > 0),
      all(is.finite(estimate[available]) & estimate[available] > 0))
    se[available] <- tab$LogSE[available]
    lower[available] <- log(tab$CI_Lower[available])
    upper[available] <- log(tab$CI_Upper[available])
  }
  finite <- is.finite(estimate) & estimate > 0
  log_estimate <- rep(NA_real_, n); log_estimate[finite] <- log(estimate[finite])
  checks <- attr(ci, "checks")
  failed_checks <- if (is.data.frame(checks)) checks$Check[!checks$Passed] else character()
  covered <- ifelse(available, lower <= log(truth$Truth) & upper >= log(truth$Truth), NA)
  data.frame(Arm = arm, Job = job, Design = original$case$design,
    AbilitySD = original$case$sd, Replicate = original$id, truth,
    LogTruth = log(truth$Truth), LogEstimate = log_estimate, LogSE = se,
    Lower = lower, Upper = upper, QualifiedPoint = qualified & finite,
    Available = available, Covered = covered, DeliveredCovered = available & !is.na(covered) & covered,
    PointReason = fit$opt$optimizer_diagnostics$ConvergenceReason %||% "Source unavailable",
    Failure = paste(c(failed_checks, error[nzchar(error)]), collapse = "; "))
}

gmfrm_matched_rate <- function(k, n, prefix) {
  p <- if (n) k / n else NA_real_
  bounds <- if (n) unname(binom.test(k, n)$conf.int) else c(NA_real_, NA_real_)
  setNames(c(p, if (n) sqrt(p * (1 - p) / n) else NA_real_, bounds),
    paste0(prefix, c("", "MCSE", "Low", "High")))
}

gmfrm_matched_point <- function(x, keep, prefix) {
  err <- x$LogEstimate[keep] - x$LogTruth[keep]; n <- length(err)
  setNames(c(n, if (n) mean(err) else NA_real_, sd(err) / sqrt(n),
    if (n) sqrt(mean(err^2)) else NA_real_, sd(x$LogEstimate[keep])),
    paste0(prefix, c("N", "LogBias", "BiasMCSE", "LogRMSE", "EmpiricalLogSD")))
}

gmfrm_matched_metrics <- function(x) {
  n <- nrow(x); returned <- sum(x$Available); covered <- sum(x$DeliveredCovered)
  c(Attempted = n,
    gmfrm_matched_point(x, x$QualifiedPoint, "AllQualified"),
    gmfrm_matched_point(x, x$Available, "Returned"),
    gmfrm_matched_rate(returned, n, "Availability"),
    gmfrm_matched_rate(covered, returned, "ConditionalCoverage"),
    gmfrm_matched_rate(covered, n, "ReturnedAndCovered"),
    RootMeanLogVariance = if (returned) sqrt(mean(x$LogSE[x$Available]^2)) else NA_real_,
    MeanLogWidth = if (returned) mean(x$Upper[x$Available] - x$Lower[x$Available]) else NA_real_)
}

gmfrm_matched_pair <- function(old, new) {
  stopifnot(identical(old$Job, new$Job), nrow(old) == nrow(new))
  n <- nrow(old)
  a0 <- as.numeric(old$Available); a1 <- as.numeric(new$Available)
  d0 <- as.numeric(old$DeliveredCovered); d1 <- as.numeric(new$DeliveredCovered)
  p0 <- if (sum(a0)) sum(d0) / sum(a0) else NA_real_
  p1 <- if (sum(a1)) sum(d1) / sum(a1) else NA_real_
  # Paired delta-method MCSE for the difference of two conditional ratios.
  influence <- if (sum(a0) && sum(a1))
    (d1 - p1 * a1) / mean(a1) - (d0 - p0 * a0) / mean(a0) else NA_real_
  both <- as.logical(a0 & a1)
  c(Pairs = n, AvailabilityDifference = mean(a1 - a0),
    AvailabilityDifferenceMCSE = sd(a1 - a0) / sqrt(n),
    ReturnedAndCoveredDifference = mean(d1 - d0),
    ReturnedAndCoveredDifferenceMCSE = sd(d1 - d0) / sqrt(n),
    ConditionalCoverageDifference = p1 - p0,
    ConditionalCoverageDifferenceMCSE = sd(influence) / sqrt(n),
    BothAvailableN = sum(both),
    BothAvailableCoverageDifference = if (any(both)) mean(d1[both] - d0[both]) else NA_real_,
    BothAvailableCoverageDifferenceMCSE = sd(d1[both] - d0[both]) / sqrt(sum(both)))
}

gmfrm_matched_summary <- function(out, m) {
  stopifnot(all(file.exists(file.path(out, m$plan$jobs))))
  manifest_md5 <- unname(tools::md5sum(file.path(out, "manifest.rds")))
  rows <- list(); stages <- list()
  for (job in m$plan$jobs) {
    a <- readRDS(file.path(m$original, job)); b <- readRDS(file.path(m$revised, job))
    z <- gmfrm_matched_record(out, job, manifest_md5)
    last <- tail(z$stages, 1L)[[1]]
    rows[[job]] <- rbind(
      gmfrm_matched_rows(a, a$fit, a$ci, "original_fixed_em", job, a$error),
      gmfrm_matched_rows(a, b$fit, b$ci, "revised_fixed_em", job, b$error),
      gmfrm_matched_rows(a, last$fitting$value, last$inference$value, "adaptive", job,
        c(last$fitting$error, last$inference$error)))
    stages[[job]] <- do.call(rbind, lapply(z$stages, function(s) data.frame(
      Job = job, Order = s$order, Provenance = z$provenance$kind,
      SelectedStart = s$fitting$value$opt$mml_initialization$selected %||% NA_character_,
      FitError = s$fitting$error, InferenceError = s$inference$error,
      FitWarnings = paste(s$fitting$warnings, collapse = "; "),
      InferenceWarnings = paste(s$inference$warnings, collapse = "; "),
      FitSeconds = s$fitting$seconds, InferenceSeconds = s$inference$seconds,
      CPUSeconds = s$fitting$cpu + s$inference$cpu, Retry = s$retry)))
  }
  rows <- do.call(rbind, rows); stages <- do.call(rbind, stages)
  grouping <- c("Design", "AbilitySD", "SlopeOwner", "SlopeLevel")
  summaries <- do.call(rbind, lapply(split(rows, interaction(rows[c("Arm", grouping)], drop = TRUE)),
    function(x) data.frame(x[1, c("Arm", grouping, "Truth")],
      as.list(gmfrm_matched_metrics(x)))))
  paired <- do.call(rbind, lapply(split(rows, interaction(rows[grouping], drop = TRUE)), function(x) {
    old <- x[x$Arm == "revised_fixed_em", ]; new <- x[x$Arm == "adaptive", ]
    data.frame(x[1, c(grouping, "Truth")], as.list(gmfrm_matched_pair(old, new)))
  }))
  stopifnot(nrow(rows) == 400L * 9L * 3L, nrow(summaries) == 4L * 9L * 3L,
    nrow(paired) == 4L * 9L, all(summaries$Attempted == 100L))
  for (name in c("rows", "stages", "summaries", "paired"))
    write.csv(get(name), file.path(out, paste0(name, ".csv")), row.names = FALSE)
  gmfrm_matched_save(list(summaries = summaries, paired = paired,
    result_hashes = tools::md5sum(file.path(out, m$plan$jobs)), manifest_md5 = manifest_md5,
    completed = Sys.time()), file.path(out, "summary.rds"))
  invisible(summaries)
}

gmfrm_matched_check <- function() {
  old <- data.frame(Job = letters[1:4], Available = c(TRUE, TRUE, FALSE, FALSE),
    DeliveredCovered = c(TRUE, FALSE, FALSE, FALSE))
  new <- old; new$Available <- c(TRUE, FALSE, TRUE, FALSE)
  p <- gmfrm_matched_pair(old, new)
  stopifnot(p["AvailabilityDifference"] == 0, p["ConditionalCoverageDifference"] == 0,
    abs(p["ConditionalCoverageDifferenceMCSE"] - sqrt(2/3)/2) < 1e-14,
    p["ReturnedAndCoveredDifferenceMCSE"] == 0,
    all(is.na(gmfrm_matched_rate(0, 0, "rate"))))
  old$Available <- FALSE; old$DeliveredCovered <- FALSE
  stopifnot(is.na(gmfrm_matched_pair(old, new)["ConditionalCoverageDifferenceMCSE"]))
  original <- readRDS("validation-results/gmfrm-sparse-intervals-20260928/001-common_persons-1.rds")
  z <- readRDS("validation-results/gmfrm-adaptive-stationarity-20260930/001-common_persons-1.rds")
  s <- tail(z$stages, 1L)[[1]]
  x <- gmfrm_matched_rows(original, s$fitting$value, s$inference$value, "adaptive", z$job)
  stopifnot(nrow(x) == 9L, all(x$QualifiedPoint), all(x$Available), !anyNA(x$Covered))
  missing <- gmfrm_matched_rows(original, s$fitting$value, NULL, "adaptive", z$job)
  stopifnot(all(missing$QualifiedPoint), !any(missing$Available), all(is.na(missing$Covered)),
    !any(missing$DeliveredCovered), gmfrm_matched_metrics(missing)["AllQualifiedN"] == 9,
    gmfrm_matched_metrics(missing)["ReturnedN"] == 0)
  bad <- s$fitting$value; bad$opt$optimizer_diagnostics$ConvergenceSeverity <- "warning"
  failed <- gmfrm_matched_rows(original, bad, NULL, "adaptive", z$job)
  stopifnot(!any(failed$QualifiedPoint), all(is.finite(failed$LogEstimate)),
    inherits(try(gmfrm_matched_rows(original, bad, s$inference$value, "adaptive", z$job),
      silent = TRUE), "try-error"))
  scratch <- tempfile(); dir.create(scratch); on.exit(unlink(scratch, recursive = TRUE))
  gmfrm_matched_save(list(job = "a.rds", manifest_md5 = "right", stages = list(s),
    provenance = list(kind = "fixture")), file.path(scratch, "a.rds"))
  stopifnot(is.list(gmfrm_matched_record(scratch, "a.rds", "right")),
    inherits(try(gmfrm_matched_record(scratch, "a.rds", "wrong"), silent = TRUE), "try-error"))
  hashes <- tools::md5sum(file.path(scratch, "a.rds")); gmfrm_matched_hash_check(hashes)
  gmfrm_matched_save(NULL, file.path(scratch, "a.rds"))
  stopifnot(inherits(try(gmfrm_matched_hash_check(hashes), silent = TRUE), "try-error"))
  cat("Matched summary, failure retention, paired uncertainty and resume checks passed.\n")
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  stopifnot(length(args) >= 1L)
  if (args[1] %in% c("prepare", "check")) {
    pkgload::load_all(".", quiet = TRUE, compile = FALSE, helpers = FALSE)
    if (args[1] == "check") gmfrm_matched_check() else gmfrm_matched_prepare(args[2])
  } else if (args[1] %in% c("run", "summary")) {
    out <- normalizePath(args[2]); m <- gmfrm_matched_load(out)
    if (args[1] == "run") gmfrm_matched_run(out, m) else gmfrm_matched_summary(out, m)
  } else stop("Use prepare OUTPUT, run OUTPUT, summary OUTPUT, or check.")
}
