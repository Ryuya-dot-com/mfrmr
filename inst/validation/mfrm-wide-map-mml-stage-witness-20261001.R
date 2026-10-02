# Bounded real-data workflow witness: retain the preselected q31 A/B fit, then
# allow only the protocol's integration-driven q61/q121 refinements. No new data.
# Rscript THIS_FILE NEW_OUTPUT_DIRECTORY
pkgload::load_all(".", quiet = TRUE, compile = FALSE)
source("inst/validation/mfrm-wide-map-mml-stages-20261001.R")
source("inst/validation/mfrm-wide-map-output-summary-20261001.R")
out <- commandArgs(trailingOnly = TRUE)[1L]
stopifnot(length(out) == 1L, !is.na(out), !dir.exists(out))
old <- "validation-results/native-location-branches-20261001"
manifest_path <- file.path(old, "fixed-gpcm-manifest.rds")
fit_path <- file.path(old, "fixed-gpcm-fit.rds")
m <- readRDS(manifest_path); saved <- readRDS(fit_path)
stopifnot(identical(tools::md5sum(manifest_path), saved$manifest_md5))
input_path <- names(m$input_md5)
stopifnot(identical(tools::md5sum(input_path), m$input_md5),
  identical(readRDS(input_path)$views[[m$input$View]], m$args$data))
changed <- names(m$source_md5)[tools::md5sum(names(m$source_md5)) != m$source_md5]
stopifnot(setequal(changed, c("R/api-facet-intervals.R", "R/core-native-location-inference.R",
  "R/help_gpcm_scope.R", "R/help_reports_and_tables.R")))
args <- m$args; args$quad_points <- NULL
spec <- list(ConditionId = m$input$ConditionId, Arm = "GPCM-fixed-N01-location-witness",
  Replicate = m$input$Replicate, InputId = paste(m$input$ParentId, m$input$View, m$input$BundleMD5, sep = ":"),
  args = args, facet = "Rater", level = .95, purpose = "workflow_witness_only",
  witness_source = tools::md5sum("inst/validation/mfrm-wide-map-mml-stage-witness-20261001.R"))
initial <- list(args = c(args, list(quad_points = 31L)), fit = saved$fit,
  provenance = list(files = tools::md5sum(c(manifest_path, fit_path, input_path)),
    original_R_hashes = m$source_md5, changed_R_files = changed,
    limit = "Original compiled-library checksum was not recorded. Retained q31 is a workflow witness, not a newly qualified broad-study replication."))
dir.create(out, recursive = TRUE)
snapshot <- c("inst/validation/mfrm-wide-map-mml-stages-20261001.R",
  "inst/validation/mfrm-wide-map-mml-stage-witness-20261001.R",
  "inst/validation/mfrm-wide-map-output-summary-20261001.R", "DESCRIPTION", "NAMESPACE",
  list.files("R", "[.]R$", full.names = TRUE), list.files("src", "[.](cpp|h)$", full.names = TRUE))
for (p in snapshot) {
  dest <- file.path(out, "source", p); dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  stopifnot(file.copy(p, dest), unname(tools::md5sum(p)) == unname(tools::md5sum(dest)))
}
stopifnot(file.copy(getLoadedDLLs()[["mfrmr"]][["path"]], file.path(out, "source", "mfrmr.so")),
  file.copy("inst/validation/internal-roadmap-0.2.4.md", file.path(out, "protocol-before-execution.md")))
writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
real_fit <- wide_mml_fit
new_fit_orders <- integer()
wide_mml_fit <- function(args) {
  if (args$quad_points == 61L) signalCondition(structure(list(message = "Deliberate interruption before q61 fitting"),
    class = c("interrupt", "condition")))
  stop("Unexpected fit before the interruption witness")
}
interrupted <- tryCatch(wide_mml_run(spec, out, initial), interrupt = function(e) conditionMessage(e))
stopifnot(identical(interrupted, "Deliberate interruption before q61 fitting"),
  readRDS(file.path(out, "status.rds"))$status == "interrupted")
first_paths <- file.path(out, paste0("q31-", c("fit", "scoring-source", "interval"), ".rds"))
first_hashes <- tools::md5sum(first_paths)
stopifnot(!anyNA(first_hashes), !file.exists(file.path(out, "q61-fit.rds")))
wide_mml_save(list(status = readRDS(file.path(out, "status.rds")), hashes = first_hashes,
  new_fit_calls = 0L), file.path(out, "interruption-witness.rds"))
wide_mml_fit <- function(args) {
  new_fit_orders <<- c(new_fit_orders, args$quad_points)
  real_fit(args)
}
selected <- wide_mml_run(spec, out, initial)
stopifnot(identical(tools::md5sum(first_paths), first_hashes),
  all(new_fit_orders %in% c(61L, 121L)), !anyDuplicated(new_fit_orders),
  identical(selected$interval$value$fit, saved$fit), all(selected$interval$value$table$CIEligible))
records <- wide_mml_records(spec, selected)
plan <- records[c("ConditionId", "Arm", "Replicate", "Target", "Output")]
plan$InputId <- spec$InputId; plan$Eligibility <- "eligible"
plan$Reference <- "none"; plan$ReferenceValue <- NA_real_
summary <- wide_output_summary(plan, records)
stopifnot(all(summary$Complete), all(is.na(summary$ConditionalCoverage)))
immutable <- list.files(out, "[.]rds$", full.names = TRUE)
immutable <- setdiff(immutable, file.path(out, "status.rds"))
hashes <- tools::md5sum(immutable)
wide_mml_fit <- wide_mml_score <- wide_mml_interval <- function(...) stop("Completed replay must not compute")
replay <- wide_mml_run(spec, out, initial)
stopifnot(identical(replay, selected), identical(tools::md5sum(immutable), hashes))
wide_mml_save(list(spec = spec, plan = plan, records = records, summary = summary,
  new_fit_orders = new_fit_orders, retained_fit_calls = 1L, generated_datasets = 0L,
  interrupted_before_new_fit = TRUE, completed_phase_hashes_unchanged = TRUE,
  replay_without_computation = TRUE, source_hashes = tools::md5sum(snapshot)),
  file.path(out, "verified.rds"))
write.csv(records, file.path(out, "selected-outputs.csv"), row.names = FALSE)
print(records); cat("New fit orders:", new_fit_orders, "\n")
