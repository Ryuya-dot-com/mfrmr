# Exact independent-reference reuse on the ten retained regularized states.
# No new data, fits or altered integration tolerances. Run `check`, then `replay`.
options(warn = 2)
action <- commandArgs(TRUE)
stopifnot(length(action) == 1L, action %in% c("check", "replay"))
directory <- "validation-results/gmfrm-regularized-feasibility-20261012"
script <- "inst/validation/gmfrm-reference-patterns-20261012.R"
source <- "R/core-gmfrm-reference.R"
output <- file.path(directory, "pattern-check.rds")
check_hash <- function(h) stopifnot(length(h) > 0L, !anyNA(h),
  identical(h, tools::md5sum(names(h))))
threads <- c("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")
blocked <- function(...) stop("No generation or estimation in reference-pattern validation.")
for (n in c("rnorm", "runif", "rbinom", "optim", "nlminb")) assignInNamespace(n, blocked, "stats")
verify <- function(record) {
  stopifnot(length(record$results) == 10L)
  for (r in record$results) {
    stopifnot(isTRUE(r$new$qualified), isTRUE(r$saved$qualified),
      identical(names(r$new$people), names(r$saved$people)),
      abs(r$new$nll - r$saved$nll) < 1e-9,
      max(abs(r$new$score - r$saved$score)) < 1e-9,
      max(abs(r$new$checks - r$saved$checks)) < 1e-9,
      isTRUE(all.equal(r$new$people, r$saved$people, tolerance = 1e-10)))
    if (!is.null(r$old)) stopifnot(isTRUE(all.equal(r$old, r$saved, tolerance = 1e-10)))
  }
  invisible(TRUE)
}
if (action == "replay") {
  assignInNamespace("integrate", blocked, "stats")
  record <- readRDS(output); check_hash(record$inputs); check_hash(record$source)
  verify(record)
  print(record$summary, row.names = FALSE)
  cat("Fresh saved-result replay passed; no integration, estimation or generation.\n")
  quit(save = "no")
}
stopifnot(!file.exists(output), all(Sys.getenv(threads) == "1"))
manifest <- file.path(directory, "manifest.rds")
m <- readRDS(manifest); check_hash(m$inputs); check_hash(m$source)
retained <- readRDS(file.path(directory, "replay.rds")); check_hash(retained$outputs)
stopifnot(identical(retained$manifest, tools::md5sum(manifest)), identical(m$R, R.version))
frozen <- file.path(directory, c("pattern-reference.R", "pattern-check-source.R"))
stopifnot(!any(file.exists(frozen)), file.copy(source, frozen[1L]), file.copy(script, frozen[2L]))
library(mfrmr, lib.loc = file.path(directory, "library"))
stopifnot(identical(normalizePath(find.package("mfrmr")),
  normalizePath(file.path(directory, "library/mfrmr"))))
old <- asNamespace("mfrmr"); current <- new.env(parent = old)
sys.source(frozen[1L], current)
calls <- 0L; person <- current$mfrm_gmfrm_reference_person
current$mfrm_gmfrm_reference_person <- function(model, rows) {
  calls <<- calls + 1L
  person(model, rows)
}
record <- list(inputs = tools::md5sum(c(manifest, file.path(directory, "replay.rds"),
    names(m$inputs), names(retained$outputs))),
  source = c(tools::md5sum(c(frozen, script, source)), m$source),
  R = R.version, threads = Sys.getenv(threads), session = sessionInfo(), results = list())
for (case in names(m$cases)) for (kind in c("free", "null")) {
  x <- readRDS(file.path(directory, paste0(case, "-", kind, ".rds")))
  stopifnot(identical(x$manifest, tools::md5sum(manifest)))
  model <- current$mfrm_gmfrm_reference_design(m$cases[[case]]$specification,
    x$reference$value$state$par)
  # Only the three observed free states need a fresh uncompressed timing.
  # Saved uncompressed references are the numerical oracle for all ten states.
  baseline <- NULL; old_seconds <- NA_real_
  if (kind == "free" && grepl("observed$", case))
    old_seconds <- system.time(baseline <- old$mfrm_gmfrm_reference_integrate(model))[["elapsed"]]
  calls <- 0L
  seconds <- system.time(value <- current$mfrm_gmfrm_reference_integrate(model))[["elapsed"]]
  key <- paste(case, kind, sep = "/")
  record$results[[key]] <- list(new = value, saved = x$reference$value$reference,
    old = baseline, seconds = seconds, old_seconds = old_seconds,
    persons = length(model$groups), patterns = calls)
  cat(key, "persons", length(model$groups), "patterns", calls,
    "seconds", seconds, "old_seconds", old_seconds, "\n"); flush.console()
}
verify(record)
record$summary <- do.call(rbind, lapply(names(record$results), function(key) {
  r <- record$results[[key]]
  data.frame(State = key, Persons = r$persons, Patterns = r$patterns,
    OldSeconds = r$old_seconds, NewSeconds = r$seconds,
    NLLError = abs(r$new$nll - r$saved$nll),
    ScoreError = max(abs(r$new$score - r$saved$score)),
    CheckError = max(abs(r$new$checks - r$saved$checks)), Qualified = r$new$qualified)
}))
check_hash(record$inputs); check_hash(record$source)
saveRDS(record, output)
print(record$summary, row.names = FALSE)
cat("All ten retained references agree, with every person and accuracy check retained.\n")
