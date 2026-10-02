# Two predeclared workflow witnesses, not R=50 performance assessment.
# Reuse N=120 q31; fit the saved N=20 response view with the frozen public
# two-family procedure. No new responses and no old queue resumption.
# Rscript THIS_FILE OUTPUT   (same command resumes completed phases)
pkgload::load_all(".", quiet = TRUE, compile = FALSE)
source("inst/validation/mfrm-wide-map-mml-stages-20261001.R")
source("inst/validation/mfrm-wide-map-output-summary-20261001.R")
out <- commandArgs(trailingOnly = TRUE)[1L]
stopifnot(length(out) == 1L, !is.na(out))
script <- "inst/validation/mfrm-wide-map-two-family-witness-20261001.R"
root <- "validation-results/mfrm-wide-map-r50-20261001/d-inputs"
registry <- read.csv(file.path(root, "inputs.csv"), stringsAsFactors = FALSE)
row <- registry[registry$ConditionId == "D:historical-full-common:N20:SD1:H-both" & registry$Replicate == 1L, ]
stopifnot(nrow(row) == 1L, unname(tools::md5sum(row$Bundle)) == row$BundleMD5)
small <- readRDS(row$Bundle)$views[[row$View]]$data
old <- "validation-results/gmfrm-design-screen-20261001/core-pilot"
old_path <- file.path(old, "core-n120-s1-common_persons.rds")
saved <- readRDS(old_path); old_manifest <- readRDS(file.path(old, "manifest.rds"))
stopifnot(saved$manifest_md5 == unname(tools::md5sum(file.path(old, "manifest.rds"))),
  identical(unname(tools::md5sum(names(old_manifest$source_hashes))), unname(old_manifest$source_hashes)))
fit <- saved$stages[["31"]]$fitting$value
stopifnot(identical(fit$gmfrm$specification$data, saved$input$data),
  fit$config$estimation_control$gpcm_mml_start == "neutral_em",
  fit$config$estimation_control$maxit == 500L, fit$config$estimation_control$reltol == 1e-10,
  fit$config$estimation_control$mml_integration == "adaptive")
args <- function(data) list(data = data, person = "Person", facets = c("Task", "Rater"),
  score = "Score", model = "GPCM", method = "MML", slope_facet = c("Task", "Rater"),
  step_facet = "Rater", noncenter_facet = "Rater", gpcm_mml_identification = "fixed_standard_normal",
  mml_engine = "direct", mml_integration = "adaptive", optimizer = "BFGS", rating_min = 0,
  rating_max = 2, category_policy = "preserve", maxit = 500L, reltol = 1e-10, gpcm_mml_start = "neutral_em")
spec <- function(data, id, input) list(ConditionId = id, Arm = "two-family-fixed-N01-location-witness",
  Replicate = 1L, InputId = input, args = args(data), facet = "Rater", level = .95,
  purpose = "workflow_witness_only", witness_source = tools::md5sum(script))
specs <- list(small20 = spec(small, row$ConditionId, paste(row$UnitId, row$View, row$BundleMD5, sep = ":")),
  retained120 = spec(saved$input$data, "retained-core-n120-s1-common_persons",
    paste(old_path, unname(tools::md5sum(old_path)), sep = ":")))
initial <- list(small20 = NULL, retained120 = list(args = c(specs$retained120$args, list(quad_points = 31L)),
  fit = fit, provenance = list(files = tools::md5sum(c(old_path, file.path(old, "manifest.rds"))),
    original_source_hashes = old_manifest$source_hashes,
    interpretation = "Retained development fit inspected by current consumers; not a broad-study source bridge.")))
stopifnot(wide_mml_interval_plan(specs$small20)$parameters == 22L,
  wide_mml_interval_plan(specs$small20)$persons == 20L,
  wide_mml_interval_plan(specs$retained120)$eligibility == "eligible")
dir.create(out, recursive = TRUE, showWarnings = FALSE)
paths <- c(script, "inst/validation/mfrm-wide-map-mml-stages-20261001.R",
  "inst/validation/mfrm-wide-map-output-summary-20261001.R", "DESCRIPTION", "NAMESPACE",
  list.files("R", "[.]R$", full.names = TRUE), list.files("src", "[.](cpp|h)$", full.names = TRUE))
manifest <- list(specs = specs, initial = initial, source = tools::md5sum(paths),
  inputs = tools::md5sum(c(row$Bundle, old_path, file.path(root, "inputs.csv"))))
sealed <- wide_mml_phase(file.path(out, "witness-manifest.rds"), "two-family-witness-v1", function() manifest)
stopifnot(identical(sealed, manifest))
for (p in paths) {
  dest <- file.path(out, "source", p); dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  if (!file.exists(dest)) stopifnot(file.copy(p, dest))
  stopifnot(unname(tools::md5sum(p)) == unname(tools::md5sum(dest)))
}
if (!file.exists(file.path(out, "source", "mfrmr.so"))) {
  stopifnot(file.copy(getLoadedDLLs()[["mfrmr"]][["path"]], file.path(out, "source", "mfrmr.so")),
    file.copy("inst/validation/internal-roadmap-0.2.4.md", file.path(out, "protocol-before-execution.md")))
  writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
}
results <- list()
for (name in names(specs)) {
  cat("Starting", name, "\n"); flush.console()
  s <- specs[[name]]; dir <- file.path(out, name)
  z <- wide_mml_run(s, dir, initial[[name]])
  if (name == "small20") {
    f <- readRDS(file.path(dir, "q31-fit.rds"))$payload$value
    if (!is.null(f)) stopifnot(length(f$opt$par) == 22L)
    stopifnot(is.null(z$interval), !length(list.files(dir, "-interval[.]rds$")))
  }
  plan <- wide_mml_output_plan(s); records <- wide_mml_records(s, z)
  results[[name]] <- list(selected = z, plan = plan, records = records,
    summary = wide_output_summary(plan, records))
  wide_mml_save(results[[name]], file.path(out, paste0(name, "-ledger.rds")))
  cat("Completed", name, "point available:", isTRUE(z$point$value$ready),
    "interval:", z$interval_plan$eligibility, "orders:", names(z$stages), "\n"); flush.console()
}
wide_mml_fit <- wide_mml_score <- wide_mml_interval <- function(...) stop("Completed replay must not compute")
for (name in names(specs)) {
  dir <- file.path(out, name)
  paths <- list.files(dir, "^(q[0-9]+-.*|selected)[.]rds$", full.names = TRUE)
  before <- tools::md5sum(paths)
  replay <- wide_mml_run(specs[[name]], dir, initial[[name]])
  stopifnot(identical(replay, results[[name]]$selected), identical(tools::md5sum(paths), before))
}
wide_mml_save(list(results = results, manifest_hash = tools::md5sum(file.path(out, "witness-manifest.rds")),
  generated_datasets = 0L, replay_without_computation = TRUE), file.path(out, "verified.rds"))
print(do.call(rbind, lapply(results, function(x) x$summary[c("ConditionId", "Output", "Eligibility", "Started", "Available", "Excluded")])) )
