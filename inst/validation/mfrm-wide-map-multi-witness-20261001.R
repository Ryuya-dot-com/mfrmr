# Shared-output replay of six existing workflow jobs, nine retained fit stages.
# No new optimization or response generation. Source this only through Rscript.
# Rscript THIS_FILE OUTPUT  (rerunning reuses completed phases)
pkgload::load_all(".", quiet = TRUE, compile = FALSE)
for (name in c("mml-stages", "jml-stages", "output-summary", "multi-output"))
  source(paste0("inst/validation/mfrm-wide-map-", name, "-20261001.R"))
out <- commandArgs(trailingOnly = TRUE)[1L]
stopifnot(length(out) == 1L, !is.na(out))
script <- "inst/validation/mfrm-wide-map-multi-witness-20261001.R"
roots <- c(native60 = "validation-results/mfrm-wide-map-mml-stages-20261001",
  two120 = "validation-results/mfrm-wide-map-two-family-stages-20261001/retained120",
  two20 = "validation-results/mfrm-wide-map-two-family-stages-20261001/small20",
  JML = "validation-results/mfrm-wide-map-jml-stages-20261001/JML",
  JML2 = "validation-results/mfrm-wide-map-jml-stages-20261001/JML2",
  JML4 = "validation-results/mfrm-wide-map-jml-stages-20261001/JML4")
unpack <- function(path) {
  z <- readRDS(path); stopifnot(identical(z$checksum, wide_mml_hash(z$payload))); z$payload
}
jobs <- list(); cached <- list()
runtime <- wide_multi_runtime()
for (name in names(roots)) {
  root <- roots[[name]]; manifest_path <- file.path(root, "manifest.rds")
  m <- unpack(manifest_path)
  # Only the execution/summary helpers changed since these workflow runs.
  fields <- names(m$runtime$source)[grepl("^(R/|src/|loaded:)", names(m$runtime$source))]
  stopifnot(identical(unname(m$runtime$source[fields]), unname(runtime$source[fields])))
  spec <- m$spec; spec$facet <- NULL; spec$level <- .95
  spec$outputs <- setNames(lapply(spec$args$facets, function(f) list(kind = "location", facet = f)),
    paste0("location", seq_along(spec$args$facets)))
  spec$outputs$slopes <- list(kind = "slopes")
  spec$witness_source <- tools::md5sum(script)
  paths <- if (spec$args$method == "MML") list.files(root, "^q[0-9]+-fit[.]rds$", full.names = TRUE) else
    file.path(root, "fit.rds")
  retained <- list()
  for (p in paths) {
    q <- if (spec$args$method == "MML") as.integer(sub("^q([0-9]+)-fit[.]rds$", "\\1", basename(p))) else 0L
    z <- readRDS(p); stopifnot(identical(z$binding$job, wide_mml_hash(m)))
    fitting <- unpack(p); args <- spec$args; if (q > 0L) args$quad_points <- q
    retained[[as.character(q)]] <- list(args = args, fitting = fitting,
      provenance = list(files = tools::md5sum(c(p, manifest_path)),
        interpretation = "Reuse a prior workflow stage under matched model source; not a new independent replication."))
  }
  # The two existing Rater location objects have the identical fit and current
  # model source; reuse them instead of repeating their full information check.
  interval <- file.path(root, "q31-interval.rds")
  if (file.exists(interval)) {
    z <- readRDS(interval); value <- unpack(interval)$value
    stopifnot(identical(z$binding$job, wide_mml_hash(m)),
      identical(value$fit, retained[["31"]]$fitting$value), value$settings$level == spec$level)
    cached[[name]] <- value
    spec$retained_interval_source <- tools::md5sum(interval)
  }
  jobs[[name]] <- list(spec = spec, retained = retained)
}
dir.create(out, recursive = TRUE, showWarnings = FALSE)
paths <- c(script, paste0("inst/validation/mfrm-wide-map-",
  c("mml-stages", "jml-stages", "output-summary", "multi-output"), "-20261001.R"))
archive <- "validation-results/mfrm-wide-map-two-family-stages-20261001/source"
model_keys <- names(runtime$source)[grepl("^(R/|src/|loaded:)|^(DESCRIPTION|NAMESPACE)$", names(runtime$source))]
archived_paths <- file.path(archive, sub("^loaded:mfrmr$", "mfrmr.so", model_keys))
stopifnot(identical(unname(tools::md5sum(archived_paths)), unname(runtime$source[model_keys])))
manifest <- list(jobs = jobs, source = tools::md5sum(paths), model_archive = tools::md5sum(archived_paths))
sealed <- wide_mml_phase(file.path(out, "witness-manifest.rds"), "multi-witness-v1", function() manifest)
stopifnot(identical(sealed, manifest))
dir.create(file.path(out, "source"), showWarnings = FALSE)
for (p in paths) {
  dest <- file.path(out, "source", basename(p))
  if (!file.exists(dest)) stopifnot(file.copy(p, dest))
  stopifnot(unname(tools::md5sum(p)) == unname(tools::md5sum(dest)))
}
if (!file.exists(file.path(out, "protocol-before-execution.md"))) {
  stopifnot(file.copy("inst/validation/internal-roadmap-0.2.4.md", file.path(out, "protocol-before-execution.md")))
  writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
}
wide_mml_fit <- function(...) stop("No fitting is allowed in this retained multi-output witness")
public_consumer <- wide_multi_consume
wide_multi_consume <- function(fit, consumer, level) {
  if (consumer$kind == "location") for (x in cached) {
    if (identical(x$fit, fit) && identical(x$settings$facet, consumer$facet) && x$settings$level == level) return(x)
  }
  public_consumer(fit, consumer, level)
}
results <- list()
for (name in names(jobs)) {
  job <- jobs[[name]]; cat("Starting", name, "\n"); flush.console()
  z <- wide_multi_run(job$spec, file.path(out, name), job$retained)
  records <- wide_multi_records(job$spec, z)
  summary <- wide_output_summary(z$plan, records)
  stopifnot(all(summary$Complete), all(is.na(summary$ConditionalCoverage)))
  # Output adapter errors must not be mistaken for scientific refusals.
  stopifnot(all(vapply(z$intervals, function(x) !nzchar(x$error), TRUE)))
  results[[name]] <- list(selected = z, records = records, summary = summary)
  cat("Completed", name, "fit stages", length(z$stages), "point outputs",
    sum(records$Output == "point" & records$Available), "interval outputs",
    sum(records$Output == "interval" & records$Available), "\n"); flush.console()
}
stopifnot(length(results$native60$selected$stages) == 3L,
  length(results$two120$selected$stages) == 1L,
  length(results$two20$selected$stages) == 2L,
  !length(results$two20$selected$intervals),
  all(vapply(results[c("JML", "JML2", "JML4")], function(x) !length(x$selected$intervals), TRUE)))
wide_mml_score <- wide_jml_source <- wide_multi_consume <- function(...) stop("No computation during completed replay")
for (name in names(jobs)) {
  job <- jobs[[name]]; dir <- file.path(out, name)
  paths <- setdiff(list.files(dir, "[.]rds$", full.names = TRUE), file.path(dir, "status.rds"))
  hashes <- tools::md5sum(paths)
  stopifnot(identical(wide_multi_run(job$spec, dir, job$retained), results[[name]]$selected),
    identical(tools::md5sum(paths), hashes))
}
wide_mml_save(list(results = results, new_fit_calls = 0L, new_datasets = 0L,
  retained_fit_stages = 9L, replay_without_computation = TRUE,
  source = manifest$source, model_archive = manifest$model_archive), file.path(out, "verified.rds"))
