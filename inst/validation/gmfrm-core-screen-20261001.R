# Core screen only: 800 new N=120/480 cases plus 400 retained N=240 cases.
# prepare OUTPUT freezes inputs and reuses the eight timing cases; no new fits.
# Then use OUTPUT/source/runner.R run OUTPUT or summary OUTPUT.
gmfrm_core_base <- "validation-results/gmfrm-adaptive-matched-20260930"
gmfrm_core_pilot <- "validation-results/gmfrm-design-screen-20261001/core-pilot"
gmfrm_core_script <- "inst/validation/gmfrm-core-screen-20261001.R"

gmfrm_core_prepare <- function(out) {
  base <- normalizePath(gmfrm_core_base); pilot <- normalizePath(gmfrm_core_pilot)
  old <- readRDS(file.path(base, "manifest.rds"))
  timing <- readRDS(file.path(pilot, "timing.rds"))
  pm <- readRDS(file.path(pilot, "manifest.rds"))
  source(file.path(base, "source/inst/validation/gmfrm-adaptive-matched-20260930.R"))
  frozen <- old$source_hashes; names(frozen) <- file.path(base, "source", names(frozen))
  gmfrm_matched_hash_check(frozen)
  gmfrm_matched_hash_check(pm$source_hashes); gmfrm_matched_hash_check(pm$input_hashes)
  gmfrm_matched_hash_check(timing$result_hashes)
  stopifnot(identical(timing$manifest_md5, unname(tools::md5sum(file.path(pilot, "manifest.rds")))))
  source(file.path(pilot, "generator.R"))
  scenarios <- gmfrm_design_plan(); scenarios <- scenarios[scenarios$Block == "core", ]
  new <- scenarios[!scenarios$Retained, ]
  stopifnot(identical(new, pm$scenarios), !dir.exists(out))
  dir.create(file.path(out, "inputs"), recursive = TRUE)
  dir.create(file.path(out, "source"))
  out <- normalizePath(out)
  stopifnot(file.copy(gmfrm_core_script, file.path(out, "source/runner.R")),
    file.copy(file.path(pilot, "generator.R"), file.path(out, "source/generator.R")),
    file.copy(file.path(base, "rows.csv"), file.path(out, "retained-rows.csv")),
    file.copy("inst/validation/gmfrm-mml-em-20260927.md", file.path(out, "protocol-before-execution.md")))
  jobs <- character()
  for (i in seq_len(nrow(new))) for (id in seq_len(new$ScreenRepetitions[i])) {
    x <- gmfrm_design_data(new[i, ], id)
    job <- sprintf("%03d-%s.rds", id, new$Scenario[i]); jobs <- c(jobs, job)
    input <- list(id = id, seed = x$seed, scenario = new[i, ], case = list(
      data = x$data, truth = x$truth, design = new$Roster[i], sd = new$AbilitySD[i]))
    gmfrm_matched_save(input, file.path(out, "inputs", job))
    if (id == 1L) {
      p <- readRDS(file.path(pilot, paste0(new$Scenario[i], ".rds")))
      stopifnot(identical(p$input, x), identical(p$manifest_md5, timing$manifest_md5))
    }
  }
  plan <- old$plan; plan$jobs <- jobs
  manifest <- list(plan = plan, scenarios = scenarios, package = file.path(base, "source"),
    source_hashes = c(frozen, tools::md5sum(c(file.path(out, "source", c("runner.R", "generator.R")),
      file.path(out, "protocol-before-execution.md")))),
    input_hashes = tools::md5sum(file.path(out, "inputs", jobs)),
    retained_hash = tools::md5sum(file.path(out, "retained-rows.csv")),
    baseline_summary_hash = tools::md5sum(file.path(base, "summary.rds")),
    pilot_manifest_hash = tools::md5sum(file.path(pilot, "manifest.rds")),
    pilot_result_hashes = timing$result_hashes, created = Sys.time(), session = capture.output(sessionInfo()))
  stopifnot(length(jobs) == 800L, !anyDuplicated(jobs))
  gmfrm_matched_save(manifest, file.path(out, "manifest.rds"))
  hash <- unname(tools::md5sum(file.path(out, "manifest.rds")))
  for (i in seq_len(nrow(new))) {
    p <- readRDS(file.path(pilot, paste0(new$Scenario[i], ".rds")))
    job <- sprintf("001-%s.rds", new$Scenario[i])
    gmfrm_matched_save(list(job = job, stages = p$stages, manifest_md5 = hash,
      provenance = list(kind = "timing-pilot",
        source = timing$result_hashes[file.path(pilot, paste0(new$Scenario[i], ".rds"))])), file.path(out, job))
  }
  cat("Prepared 800 inputs, retained 400 baseline datasets and 8 pilot fits; 792 fits remain. No new fitting.\n")
}

gmfrm_core_load <- function(out) {
  m <- readRDS(file.path(out, "manifest.rds"))
  source(file.path(m$package, "inst/validation/gmfrm-adaptive-matched-20260930.R"))
  gmfrm_matched_hash_check(m$source_hashes); gmfrm_matched_hash_check(m$input_hashes)
  gmfrm_matched_hash_check(m$retained_hash)
  script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
  stopifnot(identical(normalizePath(script), normalizePath(file.path(out, "source/runner.R"))))
  pkgload::load_all(m$package, quiet = TRUE, compile = FALSE, helpers = FALSE)
  stopifnot(unname(tools::md5sum(getLoadedDLLs()[["mfrmr"]][["path"]])) ==
    unname(m$source_hashes[file.path(m$package, "src/mfrmr.so")]))
  source(file.path(m$package, "inst/validation/gmfrm-adaptive-procedure-20260930.R"))
  m
}

gmfrm_core_metrics <- function(rows) {
  stopifnot(nrow(rows) == 1200L * 9L,
    !anyDuplicated(rows[c("Scenario", "Replicate", "SlopeOwner", "SlopeLevel")]))
  grouped <- split(rows, interaction(rows[c("Scenario", "SlopeOwner", "SlopeLevel")], drop = TRUE))
  stopifnot(length(grouped) == 12L * 9L, all(vapply(grouped, nrow, integer(1)) == 100L))
  summaries <- do.call(rbind, lapply(grouped, function(x) {
    tab <- data.frame(x[1L, c("Scenario", "Persons", "Design", "AbilitySD", "EvidenceOrigin",
      "SlopeOwner", "SlopeLevel", "Truth")], as.list(gmfrm_matched_metrics(x)))
    tab$SEtoEmpiricalSD <- tab$RootMeanLogVariance / tab$ReturnedEmpiricalLogSD
    tab$AboveTruth <- sum(x$Available & x$Lower > x$LogTruth, na.rm = TRUE)
    tab$BelowTruth <- sum(x$Available & x$Upper < x$LogTruth, na.rm = TRUE)
    tab
  }))
  # There is deliberately no nominal-coverage qualification flag in this screen.
  summaries
}

gmfrm_core_summary <- function(out, m) {
  stopifnot(all(file.exists(file.path(out, m$plan$jobs))))
  hash <- unname(tools::md5sum(file.path(out, "manifest.rds")))
  rows <- stages <- vector("list", length(m$plan$jobs))
  for (i in seq_along(m$plan$jobs)) {
    job <- m$plan$jobs[i]; input <- readRDS(file.path(out, "inputs", job))
    z <- gmfrm_matched_record(out, job, hash); final <- tail(z$stages, 1L)[[1L]]
    x <- gmfrm_matched_rows(input, final$fitting$value, final$inference$value,
      "adaptive", job, c(final$fitting$error, final$inference$error))
    x$Scenario <- input$scenario$Scenario; x$Persons <- input$scenario$Persons
    x$EvidenceOrigin <- "new-screen"; rows[[i]] <- x
    stages[[i]] <- do.call(rbind, lapply(z$stages, function(s) data.frame(Job = job, Order = s$order,
      FitError = s$fitting$error, InferenceError = s$inference$error,
      FitWarnings = paste(s$fitting$warnings, collapse = "; "),
      InferenceWarnings = paste(s$inference$warnings, collapse = "; "), Retry = s$retry,
      FitSeconds = s$fitting$seconds, InferenceSeconds = s$inference$seconds,
      CPUSeconds = s$fitting$cpu + s$inference$cpu)))
  }
  retained <- read.csv(names(m$retained_hash), stringsAsFactors = FALSE)
  retained <- retained[retained$Arm == "adaptive", ]
  stopifnot(nrow(retained) == 400L * 9L)
  retained$Scenario <- sprintf("core-n240-s%s-%s", retained$AbilitySD, retained$Design)
  retained$Persons <- 240L; retained$EvidenceOrigin <- "retained-development"
  rows <- rbind(retained, do.call(rbind, rows)); stages <- do.call(rbind, stages)
  summaries <- gmfrm_core_metrics(rows)
  gmfrm_matched_hash_check(m$source_hashes); gmfrm_matched_hash_check(m$input_hashes)
  gmfrm_matched_hash_check(m$retained_hash)
  write.csv(rows, file.path(out, "rows.csv"), row.names = FALSE)
  write.csv(stages, file.path(out, "new-stages.csv"), row.names = FALSE)
  write.csv(summaries, file.path(out, "summaries.csv"), row.names = FALSE)
  gmfrm_matched_save(list(summaries = summaries,
    result_hashes = tools::md5sum(file.path(out, m$plan$jobs)), manifest_md5 = hash,
    completed = Sys.time()), file.path(out, "summary.rds"))
}

gmfrm_core_run <- function(out, m) {
  lock <- file.path(out, "RUNNING")
  if (!dir.create(lock, showWarnings = FALSE)) stop("RUNNING exists; inspect before resuming.")
  on.exit(unlink(lock, recursive = TRUE), add = TRUE)
  writeLines(as.character(Sys.getpid()), file.path(lock, "pid"))
  writeLines(capture.output(sessionInfo()), file.path(out,
    paste0("session-", format(Sys.time(), "%Y%m%d-%H%M%S"), ".txt")))
  hash <- unname(tools::md5sum(file.path(out, "manifest.rds")))
  jobs <- m$plan$jobs; finished <- jobs[file.exists(file.path(out, jobs))]
  invisible(lapply(finished, function(job) gmfrm_matched_record(out, job, hash)))
  pending <- setdiff(jobs, finished)
  gmfrm_adaptive_procedure_check()
  cat(format(Sys.time(), tz = "Asia/Tokyo"), "JST: starting", length(pending), "core screen cases\n")
  flush.console()
  timing <- system.time(done <- parallel::mclapply(pending, function(job) {
    input <- readRDS(file.path(out, "inputs", job))
    stages <- gmfrm_adaptive_procedure(input$case$data, m$plan)
    gmfrm_matched_hash_check(m$input_hashes[file.path(out, "inputs", job)])
    gmfrm_matched_save(list(job = job, stages = stages, manifest_md5 = hash,
      provenance = list(kind = "new-screen")), file.path(out, job))
    final <- tail(stages, 1L)[[1L]]
    cat(job, "order", final$order, "intervals", sum(attr(final$inference$value, "diagnostics")$CIEligible),
      "seconds", sum(vapply(stages, function(s) s$fitting$seconds + s$inference$seconds, 0)), "\n")
    flush.console(); TRUE
  }, mc.cores = m$plan$cores, mc.preschedule = FALSE, mc.set.seed = FALSE))
  stopifnot(all(vapply(done, isTRUE, logical(1))))
  gmfrm_matched_save(list(jobs = pending, timing = timing, completed = Sys.time()),
    file.path(out, paste0("run-", format(Sys.time(), "%Y%m%d-%H%M%S"), ".rds")))
  gmfrm_core_summary(out, m)
}

gmfrm_core_check <- function() {
  source(file.path(gmfrm_core_base, "source/inst/validation/gmfrm-adaptive-matched-20260930.R"))
  baseline <- read.csv(file.path(gmfrm_core_base, "rows.csv"), stringsAsFactors = FALSE)
  baseline <- baseline[baseline$Arm == "adaptive", ]
  # Accounting fixtures only; duplicating retained rows creates no evidence.
  rows <- do.call(rbind, lapply(c(120L, 240L, 480L), function(n) {
    x <- baseline; x$Persons <- n
    x$Scenario <- sprintf("core-n%d-s%s-%s", n, x$AbilitySD, x$Design)
    x$EvidenceOrigin <- "fixture"; x
  }))
  tab <- gmfrm_core_metrics(rows)
  stopifnot(nrow(tab) == 108L, all(tab$Attempted == 100L),
    all(tab$ReturnedN[tab$Design == "rotating_pairs" & tab$AbilitySD == .5] == 99L),
    inherits(try(gmfrm_core_metrics(rows[-1L, ]), silent = TRUE), "try-error"),
    inherits(try(gmfrm_core_summary(tempdir(), list(plan = list(jobs = "missing-case.rds"))), silent = TRUE), "try-error"))
  missing <- rows$Scenario == rows$Scenario[1L]
  rows$Available[missing] <- FALSE; rows$Covered[missing] <- NA
  rows$DeliveredCovered[missing] <- FALSE
  tab <- gmfrm_core_metrics(rows); unavailable <- tab$Scenario == rows$Scenario[1L]
  stopifnot(all(tab$ReturnedN[unavailable] == 0L),
    all(tab$AllQualifiedN[unavailable] == 100L),
    all(is.na(tab$ConditionalCoverage[unavailable])))
  cat("Core accounting, separate sample sizes, retained refusals and incomplete-summary checks passed; no fitting.\n")
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (identical(args[1L], "check")) gmfrm_core_check() else if (length(args) == 2L && args[1L] == "prepare")
    gmfrm_core_prepare(args[2L]) else if (length(args) == 2L && args[1L] %in% c("run", "summary")) {
      out <- normalizePath(args[2L]); m <- gmfrm_core_load(out)
      if (args[1L] == "run") gmfrm_core_run(out, m) else gmfrm_core_summary(out, m)
    } else stop("Use check, prepare OUTPUT, or the frozen runner with run OUTPUT / summary OUTPUT.")
}
