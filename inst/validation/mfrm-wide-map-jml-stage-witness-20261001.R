# Retained N=20 ordinary/order-2/order-4 JML source-review and replay witnesses.
# No response generation or optimization. Root covariance is never a truth CI.
# Rscript THIS_FILE OUTPUT   (same command reuses all completed phases)
pkgload::load_all(".", quiet = TRUE, compile = FALSE)
source("inst/validation/mfrm-wide-map-mml-stages-20261001.R")
source("inst/validation/mfrm-wide-map-jml-stages-20261001.R")
source("inst/validation/mfrm-wide-map-output-summary-20261001.R")
out <- commandArgs(trailingOnly = TRUE)[1L]
stopifnot(length(out) == 1L, !is.na(out))
script <- "inst/validation/mfrm-wide-map-jml-stage-witness-20261001.R"
old <- "validation-results/mfrm-facet-structure-pilot-20261001"
input_path <- file.path(old, "inputs", "20-base_two_facet.rds")
data <- readRDS(input_path)$data
manifest_path <- file.path(old, "manifest.rds")
jobs <- list()
for (method in c("JML", "JML2", "JML4")) {
  path <- file.path(old, "fits", paste0("20-base_two_facet-", method, ".rds"))
  saved <- readRDS(path)
  stopifnot(saved$manifest_md5 == unname(tools::md5sum(manifest_path)))
  args <- list(data = data, person = "Person", facets = c("Rater", "Criterion"), score = "Score",
    model = "GPCM", method = "JML", slope_facet = "Criterion", step_facet = "Criterion",
    category_policy = "preserve", rating_min = 0, rating_max = 2, maxit = 400L)
  if (method == "JML") { args$optimizer <- "BFGS"; args$reltol <- 1e-9 } else {
    args$jml_correction_order <- as.integer(sub("JML", "", method))
    args$jml_correction_sampling <- "fixed_rosters"
  }
  spec <- list(ConditionId = "retained-pilot-N20-Rater3-Criterion2", Arm = method, Replicate = 1L,
    InputId = paste(input_path, unname(tools::md5sum(input_path)), sep = ":"),
    args = args, facet = "Rater", purpose = "workflow_witness_only", witness_source = tools::md5sum(script))
  jobs[[method]] <- list(spec = spec, initial = list(args = args, fit = saved$fit,
    provenance = list(files = tools::md5sum(c(path, input_path, manifest_path)),
      interpretation = "Retained public fit checked by current source consumer; not a new independent replication.")))
}
dir.create(out, recursive = TRUE, showWarnings = FALSE)
paths <- c(script, "inst/validation/mfrm-wide-map-mml-stages-20261001.R",
  "inst/validation/mfrm-wide-map-jml-stages-20261001.R", "inst/validation/mfrm-wide-map-output-summary-20261001.R",
  "DESCRIPTION", "NAMESPACE", list.files("R", "[.]R$", full.names = TRUE), list.files("src", "[.](cpp|h)$", full.names = TRUE))
manifest <- list(jobs = jobs, source = tools::md5sum(paths))
old_manifest <- wide_mml_phase(file.path(out, "witness-manifest.rds"), "jml-witness-v1", function() manifest)
stopifnot(identical(old_manifest, manifest))
for (p in paths) {
  dest <- file.path(out, "source", p); dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  if (!file.exists(dest)) stopifnot(file.copy(p, dest))
  stopifnot(unname(tools::md5sum(dest)) == unname(tools::md5sum(p)))
}
if (!file.exists(file.path(out, "source", "mfrmr.so"))) {
  stopifnot(file.copy(getLoadedDLLs()[["mfrmr"]][["path"]], file.path(out, "source", "mfrmr.so")),
    file.copy("inst/validation/internal-roadmap-0.2.4.md", file.path(out, "protocol-before-execution.md")))
  writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
}
wide_mml_fit <- function(...) stop("No JML fitting in this retained witness")
results <- list()
for (method in names(jobs)) {
  job <- jobs[[method]]
  z <- wide_jml_run(job$spec, file.path(out, method), job$initial)
  records <- wide_jml_records(job$spec, z); plan <- wide_jml_output_plan(job$spec)
  summary <- wide_output_summary(plan, records)
  stopifnot(all(summary$Complete), all(is.na(summary$ConditionalCoverage)), !z$formal_structural_intervals)
  results[[method]] <- list(selected = z, plan = plan, records = records, summary = summary)
  cat(method, "source available:", isTRUE(z$scoring_source$value$ready),
    "root status:", if (is.null(z$root)) "not_adjusted" else z$root$status, "\n"); flush.console()
}
wide_jml_source <- function(...) stop("No source recalculation on completed replay")
for (method in names(jobs)) {
  job <- jobs[[method]]; dir <- file.path(out, method)
  paths <- file.path(dir, c("fit.rds", "scoring-source.rds", "selected.rds")); hashes <- tools::md5sum(paths)
  stopifnot(identical(wide_jml_run(job$spec, dir, job$initial), results[[method]]$selected),
    identical(tools::md5sum(paths), hashes))
}
wide_mml_save(list(results = results, new_fits = 0L, new_datasets = 0L, replay_without_computation = TRUE,
  source_hashes = manifest$source), file.path(out, "verified.rds"))
