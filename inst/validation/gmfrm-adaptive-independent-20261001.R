# Repository-only independent evaluation of the unchanged matched-replay procedure.
# prepare OUTPUT creates frozen inputs/source but does not fit any dataset.
# run OUTPUT requires the maintainer's compute/deadline decision; summary OUTPUT
# refuses incomplete runs. check reuses saved examples without any new fitting.
gmfrm_independent_base <- "validation-results/gmfrm-adaptive-matched-20260930"
gmfrm_independent_script <- "inst/validation/gmfrm-adaptive-independent-20261001.R"
gmfrm_independent_generator <- "inst/validation/gmfrm-sparse-intervals-20260928.R"

gmfrm_independent_prepare <- function(out) {
  base <- normalizePath(gmfrm_independent_base)
  old <- readRDS(file.path(base, "manifest.rds"))
  source(file.path(base, "source/inst/validation/gmfrm-adaptive-matched-20260930.R"))
  frozen <- old$source_hashes
  names(frozen) <- file.path(base, "source", names(frozen))
  gmfrm_matched_hash_check(frozen)
  completed <- readRDS(file.path(base, "summary.rds"))
  gmfrm_matched_hash_check(completed$result_hashes)
  stopifnot(identical(completed$manifest_md5, unname(tools::md5sum(file.path(base, "manifest.rds")))))
  source(gmfrm_independent_generator)
  historical <- readRDS(file.path(old$original, old$plan$jobs[1L]))
  stopifnot(!dir.exists(out))
  data_plan <- gmfrm_sparse_plan()
  stopifnot(identical(data_plan, readRDS(file.path(old$original, "manifest.rds"))$plan))
  # The original script hash differs and its source was not archived. Verify
  # all retained data/truth identities without assuming the cause of that change.
  for (id in seq_len(data_plan$repetitions)) {
    replay <- gmfrm_sparse_data(id, data_plan)
    for (key in names(replay$cases)) {
      saved <- readRDS(file.path(old$original, sprintf("%03d-%s.rds", id, key)))
      stopifnot(identical(saved$case, replay$cases[[key]]), saved$seed == data_plan$seed + id)
    }
  }
  generator_check <- list(reproduced_cases = 400L,
    historical_file_hash = historical$source_hash[gmfrm_independent_generator],
    current_file_hash = tools::md5sum(gmfrm_independent_generator))
  data_plan$repetitions <- 500L
  data_plan$seed <- 93020000L
  plan <- old$plan
  keys <- c("common_persons-1", "rotating_pairs-1", "common_persons-0.5", "rotating_pairs-0.5")
  plan$jobs <- unlist(lapply(seq_len(data_plan$repetitions), function(id) sprintf("%03d-%s.rds", id, keys)))
  dir.create(file.path(out, "inputs"), recursive = TRUE)
  out <- normalizePath(out)
  from <- c(setNames(names(frozen), names(old$source_hashes)),
    setNames(normalizePath(c(gmfrm_independent_script, gmfrm_independent_generator)),
      c(gmfrm_independent_script, gmfrm_independent_generator)))
  for (name in names(from)) {
    dest <- file.path(out, "source", name)
    dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
    stopifnot(file.copy(from[[name]], dest))
  }
  source_hashes <- tools::md5sum(file.path(out, "source", names(from)))
  names(source_hashes) <- names(from)
  stopifnot(identical(source_hashes[names(old$source_hashes)], old$source_hashes))
  for (id in seq_len(data_plan$repetitions)) {
    input <- gmfrm_sparse_data(id, data_plan)
    for (key in keys) gmfrm_matched_save(list(id = id, seed = data_plan$seed + id,
      case = input$cases[[key]]), file.path(out, "inputs", sprintf("%03d-%s.rds", id, key)))
  }
  manifest <- list(plan = plan, data_plan = data_plan, source_hashes = source_hashes,
    generator_check = generator_check,
    input_hashes = tools::md5sum(file.path(out, "inputs", plan$jobs)),
    matched_manifest = tools::md5sum(file.path(base, "manifest.rds")),
    claim_margins = c(Availability = .95, AvailabilityLow = .90,
      ConditionalCoverageLow = .92, ConditionalCoverageHigh = .98),
    created = Sys.time(), session = capture.output(sessionInfo()))
  gmfrm_matched_save(manifest, file.path(out, "manifest.rds"))
  stopifnot(file.copy("inst/validation/internal-roadmap-0.2.4.md", file.path(out, "protocol-before-execution.md")))
  cat("Prepared 2,000 new inputs and frozen source; no fitting started.\n")
}

gmfrm_independent_load <- function(out) {
  out <- normalizePath(out)
  m <- readRDS(file.path(out, "manifest.rds"))
  source(file.path(out, "source/inst/validation/gmfrm-adaptive-matched-20260930.R"))
  frozen <- m$source_hashes
  names(frozen) <- file.path(out, "source", names(frozen))
  gmfrm_matched_hash_check(frozen)
  gmfrm_matched_hash_check(m$input_hashes)
  script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
  stopifnot(identical(normalizePath(script), normalizePath(file.path(out, "source", gmfrm_independent_script))))
  setwd(file.path(out, "source"))
  pkgload::load_all(".", quiet = TRUE, compile = FALSE, helpers = FALSE)
  stopifnot(unname(tools::md5sum(getLoadedDLLs()[["mfrmr"]][["path"]])) ==
    unname(m$source_hashes["src/mfrmr.so"]))
  source("inst/validation/gmfrm-adaptive-procedure-20260930.R")
  m
}

gmfrm_independent_metrics <- function(rows, margins) {
  grouping <- c("Design", "AbilitySD", "SlopeOwner", "SlopeLevel")
  tab <- do.call(rbind, lapply(split(rows, interaction(rows[grouping], drop = TRUE)), function(x)
    data.frame(x[1L, c(grouping, "Truth")], as.list(gmfrm_matched_metrics(x)))))
  tab$AvailabilityMarginMet <- tab$Availability >= margins[["Availability"]] &
    tab$AvailabilityLow >= margins[["AvailabilityLow"]]
  tab$CoverageMarginMet <- is.finite(tab$ConditionalCoverageLow) &
    is.finite(tab$ConditionalCoverageHigh) &
    tab$ConditionalCoverageLow >= margins[["ConditionalCoverageLow"]] &
    tab$ConditionalCoverageHigh <= margins[["ConditionalCoverageHigh"]]
  tab$LimitedClaimSupported <- tab$AvailabilityMarginMet & tab$CoverageMarginMet
  tab
}

gmfrm_independent_summary <- function(out, m) {
  stopifnot(all(file.exists(file.path(out, m$plan$jobs))))
  hash <- unname(tools::md5sum(file.path(out, "manifest.rds")))
  rows <- stages <- vector("list", length(m$plan$jobs))
  for (i in seq_along(m$plan$jobs)) {
    job <- m$plan$jobs[i]
    input <- readRDS(file.path(out, "inputs", job))
    record <- gmfrm_matched_record(out, job, hash)
    final <- tail(record$stages, 1L)[[1L]]
    rows[[i]] <- gmfrm_matched_rows(input, final$fitting$value, final$inference$value, "adaptive", job,
      c(final$fitting$error, final$inference$error))
    stages[[i]] <- do.call(rbind, lapply(record$stages, function(s) data.frame(
      Job = job, Order = s$order, SelectedStart = s$fitting$value$opt$mml_initialization$selected %||% NA_character_,
      FitError = s$fitting$error, InferenceError = s$inference$error,
      FitWarnings = paste(s$fitting$warnings, collapse = "; "),
      InferenceWarnings = paste(s$inference$warnings, collapse = "; "),
      FitSeconds = s$fitting$seconds, InferenceSeconds = s$inference$seconds,
      CPUSeconds = s$fitting$cpu + s$inference$cpu, Retry = s$retry)))
  }
  rows <- do.call(rbind, rows); stages <- do.call(rbind, stages)
  summaries <- gmfrm_independent_metrics(rows, m$claim_margins)
  stopifnot(nrow(rows) == 2000L * 9L, nrow(summaries) == 36L,
    all(summaries$Attempted == 500L))
  write.csv(rows, file.path(out, "rows.csv"), row.names = FALSE)
  write.csv(stages, file.path(out, "stages.csv"), row.names = FALSE)
  write.csv(summaries, file.path(out, "summaries.csv"), row.names = FALSE)
  gmfrm_matched_save(list(summaries = summaries,
    result_hashes = tools::md5sum(file.path(out, m$plan$jobs)),
    manifest_md5 = hash, completed = Sys.time()), file.path(out, "summary.rds"))
}

gmfrm_independent_run <- function(out, m) {
  lock <- file.path(out, "RUNNING")
  if (!dir.create(lock, showWarnings = FALSE)) stop("RUNNING exists; inspect its PID before resuming.")
  on.exit(unlink(lock, recursive = TRUE), add = TRUE)
  writeLines(as.character(Sys.getpid()), file.path(lock, "pid"))
  writeLines(capture.output(sessionInfo()), file.path(out, "execution-session.txt"))
  hash <- unname(tools::md5sum(file.path(out, "manifest.rds")))
  jobs <- m$plan$jobs
  finished <- jobs[file.exists(file.path(out, jobs))]
  invisible(lapply(finished, function(job) gmfrm_matched_record(out, job, hash)))
  pending <- setdiff(jobs, finished)
  gmfrm_adaptive_procedure_check()
  cat(format(Sys.time(), tz = "Asia/Tokyo"), "JST: starting", length(pending), "pending jobs\n")
  flush.console()
  timing <- system.time(done <- parallel::mclapply(pending, function(job) {
    input_hash <- m$input_hashes[file.path(out, "inputs", job)]
    gmfrm_matched_hash_check(input_hash)
    input <- readRDS(names(input_hash))
    stages <- gmfrm_adaptive_procedure(input$case$data, m$plan)
    gmfrm_matched_hash_check(input_hash)
    gmfrm_matched_save(list(job = job, manifest_md5 = hash, stages = stages,
      provenance = list(kind = "independent", input_hash = input_hash)), file.path(out, job))
    final <- tail(stages, 1L)[[1L]]
    cat(format(Sys.time(), tz = "Asia/Tokyo"), job, "order", final$order,
      "intervals", sum(attr(final$inference$value, "diagnostics")$CIEligible),
      "seconds", sum(vapply(stages, function(s) s$fitting$seconds + s$inference$seconds, 0)), "\n")
    flush.console()
    TRUE
  }, mc.cores = m$plan$cores, mc.preschedule = FALSE, mc.set.seed = FALSE))
  stopifnot(all(vapply(done, isTRUE, TRUE)))
  gmfrm_matched_hash_check(m$source_hashes)
  gmfrm_matched_hash_check(m$input_hashes)
  gmfrm_matched_save(list(started_jobs = pending, timing = timing, completed = Sys.time()),
    file.path(out, paste0("run-", format(Sys.time(), "%Y%m%d-%H%M%S"), ".rds")))
  gmfrm_independent_summary(out, m)
  cat("All 2,000 independent records and summaries saved.\n")
}

gmfrm_independent_check <- function() {
  base <- normalizePath(gmfrm_independent_base)
  pkgload::load_all(file.path(base, "source"), quiet = TRUE, compile = FALSE, helpers = FALSE)
  source(file.path(base, "source/inst/validation/gmfrm-adaptive-matched-20260930.R"))
  source(gmfrm_independent_generator)
  old <- readRDS(file.path(base, "manifest.rds"))
  input <- readRDS(file.path(old$original, old$plan$jobs[1L]))
  regenerated <- gmfrm_sparse_data(1L)
  stopifnot(identical(input$case, regenerated$cases[["common_persons-1"]]))
  plan <- gmfrm_sparse_plan(); plan$repetitions <- 500L; plan$seed <- 93020000L
  a <- gmfrm_sparse_data(1L, plan); b <- gmfrm_sparse_data(1L, plan)
  stopifnot(identical(a, b), !identical(a, regenerated), length(a$cases) == 4L,
    all(vapply(a$cases, function(x) nrow(x$data) == 1440L && nrow(x$truth) == 9L, TRUE)))
  # Accounting fixtures only: no new fitting and no simulated coverage evidence.
  rows <- read.csv(file.path(base, "rows.csv"))
  rows <- rows[rows$Arm == "adaptive" & rows$Design == "common_persons" & rows$AbilitySD == 1 &
    rows$SlopeOwner == "Task" & rows$SlopeLevel == "t3", ]
  rows <- rows[rep(1L, 500L), ]; rows$Replicate <- seq_len(500L)
  rows$Available <- TRUE; rows$Covered <- rows$DeliveredCovered <- seq_len(500L) <= 475L
  margins <- c(Availability = .95, AvailabilityLow = .90, ConditionalCoverageLow = .92, ConditionalCoverageHigh = .98)
  tab <- gmfrm_independent_metrics(rows, margins)
  stopifnot(tab$Attempted == 500, tab$LimitedClaimSupported, tab$ConditionalCoverage == .95)
  rows$Available <- FALSE; rows$Covered <- NA; rows$DeliveredCovered <- FALSE
  tab <- gmfrm_independent_metrics(rows, margins)
  stopifnot(!tab$LimitedClaimSupported, tab$ReturnedN == 0, is.na(tab$ConditionalCoverage))
  scratch <- tempfile(); dir.create(scratch); on.exit(unlink(scratch, recursive = TRUE), add = TRUE)
  stopifnot(inherits(try(gmfrm_independent_summary(scratch, list(plan = list(jobs = "absent.rds"))), silent = TRUE), "try-error"))
  cat("Generator identity/new seeds, accounting margins, missing denominators and incomplete-run refusal passed. No new fitting.\n")
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  stopifnot(length(args) >= 1L)
  if (args[1L] == "check") gmfrm_independent_check() else if (args[1L] == "prepare") {
    gmfrm_independent_prepare(args[2L])
  } else if (args[1L] %in% c("run", "summary")) {
    out <- normalizePath(args[2L]); m <- gmfrm_independent_load(out)
    if (args[1L] == "run") gmfrm_independent_run(out, m) else gmfrm_independent_summary(out, m)
  } else stop("Use prepare OUTPUT, run OUTPUT, summary OUTPUT, or check.")
}
