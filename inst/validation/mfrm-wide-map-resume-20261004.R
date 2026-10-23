# Resume the frozen PCM comparison after relocating the same R installation.
# Original checkpoint paths are identity labels, not the current installation.
# Record the actual runtime and library hashes separately before any new fit.
# No estimator, input, acceptance rule or completed checkpoint is changed.

wide_pcm_runtime_key <- function(actual, reference, actual_home = R.home()) {
  saved_home <- dirname(dirname(unname(reference$libraries["BLAS"])))
  stopifnot(length(saved_home) == 1L, !is.na(saved_home), nzchar(saved_home),
    identical(names(actual$libraries), names(reference$libraries)))
  for (field in c("iconv", "BLAS")) {
    saved <- reference$libraries[[field]]
    relocated <- sub(saved_home, actual_home, saved, fixed = TRUE)
    if (!identical(actual$libraries[[field]], relocated))
      stop("Runtime library differs beyond the R installation path: ", field)
    actual$libraries[[field]] <- saved
  }
  actual
}

wide_pcm_resume <- function(out, condition, evidence_path, driver) {
  source("inst/validation/mfrm-wide-map-pcm-r50-20261002.R")
  wide_pcm_setup()
  sealed <- wide_f_read(file.path(out, "manifest.rds"))
  m <- sealed$payload
  stopifnot(length(condition) == 1L, condition %in% m$jobs$ConditionId,
    identical(m$source, tools::md5sum(names(m$source))),
    identical(m$input, tools::md5sum(names(m$input))),
    identical(m$template, tools::md5sum(names(m$template))))
  actual <- wide_multi_runtime()
  if (!identical(wide_pcm_runtime_key(actual, m$runtime), m$runtime))
    stop("Runtime, dependencies, numerical source or controls changed; continuation refused.")
  jobs <- m$jobs[m$jobs$ConditionId == condition, , drop = FALSE]
  stopifnot(nrow(jobs) == 400L, all(table(jobs$Replicate) == 8L))
  completed <- jobs$JobId[file.exists(file.path(out, jobs$JobId, "outputs.rds"))]
  for (id in completed) {
    saved <- wide_f_read(file.path(out, id, "outputs.rds"))
    stopifnot(isTRUE(saved$payload$completed), identical(saved$payload$job$JobId, id))
  }
  libraries <- c(R = file.path(R.home("lib"), "libR.dylib"),
    BLAS = unname(actual$libraries["BLAS"]),
    mfrmr = getLoadedDLLs()[["mfrmr"]][["path"]])
  hashes <- tools::md5sum(libraries)
  stopifnot(!anyNA(hashes))
  states <- setNames(lapply(jobs$JobId, function(id) {
    p <- file.path(out, id, "calibration", "status.rds")
    if (file.exists(p)) readRDS(p) else NULL
  }), jobs$JobId)
  binding <- list(manifest = sealed$checksum, condition = condition,
    driver = tools::md5sum(driver), actual_runtime = actual, libraries = hashes)
  dir.create(dirname(evidence_path), recursive = TRUE, showWarnings = FALSE)
  evidence <- wide_mml_phase(evidence_path, binding, function() list(
    recorded_at = Sys.time(), source_root = normalizePath("."),
    original_runtime = m$runtime, actual_runtime = actual, libraries = hashes,
    completed_before = completed, statuses_before = states,
    interpretation = paste("Only R installation paths are normalized for checkpoint identity.",
      "Actual runtime is retained here; all numerical source, dependency versions,",
      "inputs, method controls, attempt denominators and completed stages are preserved.")))
  stopifnot(identical(evidence$actual_runtime, actual), identical(evidence$libraries, hashes))
  # Scope the alias to this process; package files and saved manifests stay intact.
  scope <- environment(wide_multi_runtime)
  original <- get("wide_mml_runtime", envir = scope, inherits = FALSE)
  assign("wide_mml_runtime", function() wide_pcm_runtime_key(original(), m$runtime), envir = scope)
  on.exit(assign("wide_mml_runtime", original, envir = scope), add = TRUE)
  stopifnot(identical(wide_multi_runtime(), m$runtime))
  cat("Resuming", condition, "with", length(completed), "completed jobs retained\n")
  flush.console()
  for (i in seq_len(nrow(jobs))) wide_pcm_job(m, jobs[i, , drop = FALSE], out)
  stopifnot(identical(tools::md5sum(libraries), hashes))
  invisible(evidence)
}

wide_pcm_resume_checks <- function() {
  old_home <- "/recorded/R"
  new_home <- "/relocated/R"
  reference <- list(R = "same version", source = c(kernel = "unchanged"),
    dependencies = c(Matrix = "same version"), optional_solvers = c(lpSolve = "same version"),
    libraries = c(iconv = paste("Apple or GNU libiconv 1.11", old_home, sep = " "),
      BLAS = paste0(old_home, "/lib/libRblas.0.dylib"), zlib = "same version"))
  reference$libraries["iconv"] <- paste0(reference$libraries["iconv"], "/lib/libR.dylib")
  relocated <- reference
  relocated$libraries <- sub(old_home, new_home, relocated$libraries, fixed = TRUE)
  stopifnot(identical(wide_pcm_runtime_key(relocated, reference, new_home), reference),
    identical(wide_pcm_runtime_key(reference, reference, old_home), reference))
  for (field in c("iconv", "BLAS")) {
    bad <- relocated; bad$libraries[field] <- paste0(bad$libraries[field], "-changed")
    stopifnot(inherits(try(wide_pcm_runtime_key(bad, reference, new_home), silent = TRUE), "try-error"))
  }
  for (field in c("R", "source", "dependencies", "optional_solvers")) {
    bad <- relocated; bad[[field]][1] <- "changed"
    stopifnot(!identical(wide_pcm_runtime_key(bad, reference, new_home), reference))
  }
  bad <- relocated; bad$libraries["zlib"] <- "changed"
  stopifnot(!identical(wide_pcm_runtime_key(bad, reference, new_home), reference))
  cat("Relocation admitted; changed source, versions, solvers and libraries rejected.\n")
  invisible(TRUE)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (identical(args, "check")) wide_pcm_resume_checks() else {
    stopifnot(length(args) == 3L)
    driver <- sub("^--file=", "", commandArgs()[grepl("^--file=", commandArgs())])
    stopifnot(length(driver) == 1L)
    wide_pcm_resume(args[1], args[2], args[3], driver)
  }
}
