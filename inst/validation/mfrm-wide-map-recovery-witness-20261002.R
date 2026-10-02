# One prespecified retained PCM input, all eight A/B calibration arms.
# This initial-call workflow/cost witness is not an R=50 performance result.
# Rscript THIS_FILE OUTPUT; completed fit phases are immutable and resumable.
pkgload::load_all(".", quiet = TRUE, compile = FALSE)
for (name in c("mml-stages-20261001", "jml-stages-20261001", "output-summary-20261001", "recovery-20261002"))
  source(paste0("inst/validation/mfrm-wide-map-", name, ".R"))
out <- commandArgs(trailingOnly = TRUE)[1L]; stopifnot(length(out) == 1L, !is.na(out))
script <- "inst/validation/mfrm-wide-map-recovery-witness-20261002.R"
input <- wide_recovery_ab_input("validation-results/mfrm-wide-map-r50-20261001/ab-inputs",
  "AB:paired-L1:N20:SD1:S-PCM", 1L)
definitions <- data.frame(Arm = c("PCM-MML-free", "PCM-MML-fixed", "PCM-JML",
  "GPCM-MML-free", "GPCM-MML-fixed", "GPCM-JML", "GPCM-JML2", "GPCM-JML4"),
  Model = c(rep("PCM", 3), rep("GPCM", 5)), Method = c("MML","MML","JML","MML","MML","JML","JML","JML"),
  Population = c("free","fixed","none","free","fixed","none","none","none"),
  Order = c(NA,NA,NA,NA,NA,NA,2L,4L), stringsAsFactors = FALSE)
specs <- lapply(seq_len(nrow(definitions)), function(i) {
  d <- definitions[i, ]
  args <- list(data = input$data, person = "Person", facets = c("Rater", "Criterion"), score = "Score",
    model = d$Model, method = d$Method, step_facet = "Criterion", rating_min = 0, rating_max = 3,
    category_policy = "preserve", maxit = 400L)
  if (d$Model == "GPCM") args$slope_facet <- "Criterion"
  if (is.na(d$Order)) { args$optimizer <- "BFGS"; args$reltol <- 1e-9 } else {
    args$jml_correction_order <- d$Order; args$jml_correction_sampling <- "fixed_rosters"
  }
  if (d$Method == "MML") {
    args$mml_engine <- "direct"; args$mml_integration <- "fixed"
    if (d$Population == "free") {
      # A literal intercept has no caller variables. Do not serialize the
      # lapply frame (including its mutable args) with the formula.
      args$population_formula <- stats::as.formula("~1", env = baseenv())
      args$person_data <- data.frame(Person = sort(unique(input$data$Person)))
    }
    if (d$Model == "GPCM") args$gpcm_mml_identification <-
      if (d$Population == "free") "free_population" else "fixed_standard_normal"
  }
  list(ConditionId = input$ConditionId, Replicate = input$Replicate, InputId = input$InputId,
    Arm = d$Arm, args = args, purpose = "workflow_witness_only")
})
names(specs) <- definitions$Arm
plans <- lapply(specs, function(spec) wide_recovery_plan(input, spec))
runtime <- wide_jml_runtime()
runtime$source <- c(runtime$source, tools::md5sum(c(script,
  "inst/validation/mfrm-wide-map-recovery-20261002.R", "inst/validation/mfrm-wide-map-output-summary-20261001.R")))
archive <- "validation-results/mfrm-wide-map-two-family-stages-20261001/source"
model_keys <- names(runtime$source)[grepl("^(R/|src/|loaded:)|^(DESCRIPTION|NAMESPACE)$", names(runtime$source))]
archived <- file.path(archive, sub("^loaded:mfrmr$", "mfrmr.so", model_keys))
stopifnot(identical(unname(tools::md5sum(archived)), unname(runtime$source[model_keys])))
manifest <- list(input = input, definitions = definitions, specs = specs, plans = plans,
  runtime = runtime, model_archive = tools::md5sum(archived), protocol = list(
    initial_only = TRUE, new_datasets = 0L, new_fit_limit = 8L, response_rows = nrow(input$data),
    source_scoring = "Not recomputed; initial point recovery does not require scoring admission.",
    inference = "No new covariance, intervals, scoring or likelihood ranking.",
    interpretation = "One prespecified workflow/cost witness, not independent R=50 qualification."))
dir.create(out, recursive = TRUE, showWarnings = FALSE)
sealed <- wide_mml_phase(file.path(out, "witness-manifest.rds"), "initial-recovery-v1", function() manifest)
stopifnot(identical(manifest, sealed))
dir.create(file.path(out, "source"), showWarnings = FALSE)
paths <- names(runtime$source)[grepl("^inst/validation/", names(runtime$source))]
for (p in paths) {
  dest <- file.path(out, "source", basename(p))
  if (!file.exists(dest)) stopifnot(file.copy(p, dest))
  stopifnot(unname(tools::md5sum(p)) == unname(tools::md5sum(dest)))
}
if (!file.exists(file.path(out, "protocol-before-execution.md"))) {
  stopifnot(file.copy("inst/validation/internal-roadmap-0.2.4.md", file.path(out, "protocol-before-execution.md")))
  writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
}
results <- list(); timing <- list()
for (arm in names(specs)) {
  spec <- specs[[arm]]; dir <- file.path(out, arm); dir.create(dir, showWarnings = FALSE)
  m <- list(spec = spec, runtime = runtime, input = input$InputId, protocol = manifest$protocol)
  stopifnot(identical(wide_mml_phase(file.path(dir, "manifest.rds"), "initial-recovery-job-v1", function() m), m))
  q <- if (spec$args$method == "MML") 31L else 0L
  cat("Starting", arm, "\n"); flush.console()
  fitting <- wide_mml_phase(file.path(dir, paste0("q", q, "-fit.rds")),
    list(job = wide_mml_hash(m), order = q, phase = "fit", dependency = NULL), function() {
      args <- spec$args; if (q > 0L) args$quad_points <- q
      wide_mml_capture(function() wide_mml_fit(args))
    })
  z <- wide_recovery_initial_phase(input, dir)
  saved <- wide_mml_phase(file.path(dir, "recovery.rds"), list(job = wide_mml_hash(m),
    fitting = wide_mml_hash(fitting)), function() z)
  stopifnot(identical(saved, z))
  results[[arm]] <- z
  timing[[arm]] <- data.frame(Arm = arm, Seconds = fitting$elapsed, FitReturned = !nzchar(fitting$error),
    InitialNumericalPass = z$numerical_pass, Error = fitting$error,
    FiniteTargets = sum(z$results$Available & z$results$Analysis == "initial_finite_return"))
  cat("Completed", arm, "seconds", fitting$elapsed, "numerical pass", z$numerical_pass, "\n"); flush.console()
}
plan <- do.call(rbind, lapply(results, `[[`, "plan")); records <- do.call(rbind, lapply(results, `[[`, "results"))
point_summary <- wide_recovery_summary(plan, records)
losses <- wide_recovery_grid_losses(plan, records); grid_summary <- wide_recovery_grid_summary(losses)
pairs <- combn(names(specs), 2, simplify = FALSE)
paired <- lapply(pairs, function(a) wide_recovery_paired(plan, records, a[1], a[2]))
names(paired) <- vapply(pairs, paste, "", collapse = "__")
stopifnot(all(point_summary$Complete), all(is.na(point_summary$RMSEMCSE)),
  all(grid_summary$Planned == 1L), all(is.na(grid_summary$MSEMCSE)),
  identical(unname(tools::md5sum(names(runtime$source)[!grepl("^loaded:", names(runtime$source))])),
    unname(runtime$source[!grepl("^loaded:", names(runtime$source))])))
wide_mml_save(list(plan = plan, records = records, point_summary = point_summary,
  grid_losses = losses, grid_summary = grid_summary, paired = paired, timing = do.call(rbind, timing),
  protocol = manifest$protocol, source = runtime$source), file.path(out, "verified.rds"))
print(do.call(rbind, timing), row.names = FALSE)
