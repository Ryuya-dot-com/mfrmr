# Source after preprocess.R. All outputs are local, data-bearing research files.
# Source the scripts from the same checkout as the installed development package.

icnale_fit <- function(input, model, output_dir) {
  icnale_require(model %in% c("RSM", "PCM", "GPCM1", "GPCM2"),
    "Choose RSM, PCM, GPCM1 (Criterion slopes) or GPCM2 (Criterion and Rater slopes).")
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  d <- input$ratings
  spec <- list(person = "Person", facets = c("Rater", "Criterion"), score = "Score",
    model = if (model %in% c("GPCM1", "GPCM2")) "GPCM" else model,
    method = "MML", rating_min = 0L, rating_max = 10L,
    category_policy = "preserve", noncenter_facet = "Person",
    population_formula = stats::as.formula("~1", env = baseenv()),
    person_data = unique(d["Person"]))
  if (model != "RSM") spec$step_facet <- "Criterion"
  if (model == "GPCM1") {
    spec$slope_facet <- "Criterion"
    spec$gpcm_mml_identification <- "free_population"
  }
  if (model == "GPCM2") {
    spec$slope_facet <- c("Criterion", "Rater")
    spec$slope_reference <- "Criterion"
    spec$noncenter_facet <- "Criterion"
    spec$gpcm_mml_identification <- "fixed_standard_normal"
    spec$population_formula <- spec$person_data <- NULL
  }
  control <- list(mml_engine = "direct", mml_integration = "auto", quad_points = 31L,
    maxit = 1000L, reltol = 1e-9)
  identity <- list(input_md5 = input$source_md5, ratings = d, spec = spec, control = control,
    package_version = as.character(utils::packageVersion("mfrmr")),
    package_code = unname(tools::md5sum(file.path(find.package("mfrmr"), "R", "mfrmr.rdb"))))
  path <- file.path(output_dir, paste0(tolower(model), "-fit.rds"))
  if (file.exists(path)) {
    saved <- readRDS(path)
    icnale_require(identical(saved$identity, identity), "Saved fit has different input, settings or package code; choose a new output directory.")
    message("Reusing saved ", model, " fit.")
    return(saved$fit)
  }
  message("Fitting ", model, " to ", nrow(d), " ratings from ", length(unique(d$Person)), " writers.")
  elapsed <- system.time(fit <- tryCatch(mfrmr::fit_mfrm(d, spec = spec, control = control),
    error = function(e) e))
  if (inherits(fit, "error")) {
    saveRDS(list(identity = identity, error = fit, elapsed = elapsed, session = utils::sessionInfo()),
      file.path(output_dir, paste0(tolower(model), "-failure.rds")))
    stop(fit)
  }
  saveRDS(list(identity = identity, fit = fit, elapsed = elapsed, session = utils::sessionInfo()), path)
  fit
}

icnale_planning <- function(input) {
  # CAF are fixed score dimensions, not three sampled tasks. Missing triples
  # produce an incomplete Person x Rater source; retain them as missing.
  g <- mfrmr::mfrm_g_study(input$wide, scores = c("Complexity", "Accuracy", "Fluency"),
    person = "Person", rater = "Rater", task = NULL, method = "minque0")
  d <- mfrmr::mfrm_d_study(g, design_grid = data.frame(Raters = c(1L, 2L, 3L, 4L, 6L, 8L)),
    weights = c(Complexity = 1/3, Accuracy = 1/3, Fluency = 1/3))
  list(g = g, d = d)
}

icnale_feedback <- function(fit, output_dir, rater) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  diagnostics <- mfrmr::diagnose_mfrm(fit)
  intervals <- mfrmr::mfrm_facet_intervals(fit, facet = "Rater")
  results <- mfrmr::mfrm_results(fit, diagnostics = diagnostics,
    intervals = list(raters = intervals), compute = "never")
  sheet <- mfrmr::mfrm_report(results, style = "rater", facet = "Rater", rater = rater,
    max_cases = 0, output = "html")
  # The sheet and result RDS remain local. A recipient-safe sheet is not a
  # license to redistribute corpus-derived ratings or individual results.
  icnale_require(file.copy(sheet$path, file.path(output_dir, "rater-sheet.html"), overwrite = TRUE),
    "Could not save the HTML sheet.")
  unlink(sheet$path)
  saveRDS(results, file.path(output_dir, "results.rds"))
  list(results = results, sheet = sheet$report)
}
