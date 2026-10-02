# Reuse the eight PCM initial fits. Run source and target-specific interval
# consumers; only the declared integration-only q61/q121 refinements may fit.
# Rscript THIS_FILE OUTPUT; no response generation, no JML refitting.
pkgload::load_all(".", quiet = TRUE, compile = FALSE)
for (name in c("mml-stages-20261001", "jml-stages-20261001", "output-summary-20261001",
    "multi-output-20261001", "recovery-20261002", "interval-recovery-20261002"))
  source(paste0("inst/validation/mfrm-wide-map-", name, ".R"))
out <- commandArgs(trailingOnly = TRUE)[1L]; stopifnot(length(out) == 1L, !is.na(out))
script <- "inst/validation/mfrm-wide-map-interval-witness-20261002.R"
old <- "validation-results/mfrm-wide-map-recovery-20261002"
unpack <- function(path) {
  z <- readRDS(path); stopifnot(identical(z$checksum, wide_mml_hash(z$payload))); z$payload
}
initial <- unpack(file.path(old, "witness-manifest.rds")); input <- initial$input
runtime <- wide_multi_runtime()
model_keys <- names(runtime$source)[grepl("^(R/|src/|loaded:)|^(DESCRIPTION|NAMESPACE)$", names(runtime$source))]
stopifnot(identical(unname(runtime$source[model_keys]), unname(initial$runtime$source[model_keys])),
  identical(initial$model_archive, tools::md5sum(names(initial$model_archive))))
jobs <- list()
for (arm in names(initial$specs)) {
  spec <- wide_interval_spec(input, initial$specs[[arm]])
  q <- if (spec$args$method == "MML") 31L else 0L
  manifest_path <- file.path(old, arm, "manifest.rds"); m <- unpack(manifest_path)
  path <- file.path(old, arm, paste0("q", q, "-fit.rds"))
  z <- readRDS(path); fitting <- unpack(path)
  stopifnot(identical(m$spec, initial$specs[[arm]]), identical(z$binding,
    list(job = wide_mml_hash(m), order = q, phase = "fit", dependency = NULL)))
  wide_recovery_fit_identity(fitting$value, input, spec)
  args <- spec$args; if (q > 0L) args$quad_points <- q
  retained <- setNames(list(list(args = args, fitting = fitting,
    provenance = list(files = tools::md5sum(c(path, manifest_path)),
      interpretation = "Exact initial fit reused; current model source and saved settings agree."))), as.character(q))
  jobs[[arm]] <- list(spec = spec, retained = retained)
}
paths <- c(script, names(runtime$source)[grepl("^inst/validation/", names(runtime$source))],
  "inst/validation/mfrm-wide-map-recovery-20261002.R", "inst/validation/mfrm-wide-map-interval-recovery-20261002.R")
manifest <- list(jobs = jobs, input = input, source = tools::md5sum(paths), runtime = runtime,
  model_archive = initial$model_archive, initial_source = tools::md5sum(file.path(old, "witness-manifest.rds")),
  protocol = list(retained_initial_fits = 8L, new_datasets = 0L, new_JML_fits = 0L,
    permitted_MML_refinements = c(61L,121L), interval_level = .95,
    interpretation = "One input; target/stage/denominator and public-output witness, not R=50 coverage evidence."))
dir.create(out, recursive = TRUE, showWarnings = FALSE)
stopifnot(identical(wide_mml_phase(file.path(out, "witness-manifest.rds"), "interval-witness-v1", function() manifest), manifest))
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
public_fit <- wide_mml_fit
wide_mml_fit <- function(args) {
  stopifnot(args$method == "MML", args$quad_points %in% c(61L,121L))
  public_fit(args)
}
results <- list()
for (arm in names(jobs)) {
  cat("Starting",arm,"\n"); flush.console()
  job <- jobs[[arm]]; dir <- file.path(out,arm)
  z <- wide_multi_run(job$spec,dir,job$retained)
  joined <- wide_interval_recovery(input,job$spec,z)
  # Verify the public call separately for stored errors, using no recomputation:
  # errors remain visible for inspection, never silently treated as unavailable CIs.
  stopifnot(all(joined$summary$Complete))
  results[[arm]] <- list(selected = z, recovery = joined)
  records <- joined$records
  cat("Completed",arm,"stages",length(z$stages),"source points",
    sum(records$Output == "point" & records$Available),"intervals",
    sum(records$Output == "interval" & records$Available),"consumer errors",
    sum(records$Output == "interval" & records$Status == "error"),"\n"); flush.console()
}
plan <- do.call(rbind,lapply(results,function(x) x$recovery$plan))
records <- do.call(rbind,lapply(results,function(x) x$recovery$records))
new_fit_paths <- unlist(lapply(names(jobs), function(arm) list.files(file.path(out,arm),
  "^q(61|121)-fit[.]rds$", full.names = TRUE)), use.names = FALSE)
new_fits <- lapply(new_fit_paths,unpack)
stopifnot(identical(tools::md5sum(paths),manifest$source),
  all(plan$Eligibility[plan$Output == "interval" & grepl("JML",plan$Arm)] == "unsupported"))
wide_mml_save(list(results = results, plan = plan, records = records,
  summary = wide_output_summary(plan,records), retained_initial_fits = 8L,
  new_fit_phases = tools::md5sum(new_fit_paths), new_fit_seconds = vapply(new_fits,`[[`,0,"elapsed"),
  new_datasets = 0L, source = manifest$source), file.path(out,"verified.rds"))
