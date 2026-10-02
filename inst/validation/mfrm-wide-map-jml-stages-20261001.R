# Repository-only single-call JML execution. Source mml-stages first for the
# atomic save, capture and identity helpers. No quadrature/refit ladder, order
# selection, replacement roots or structural confidence-interval construction.
wide_jml_validate <- function(spec) {
  a <- spec$args; order <- a$jml_correction_order
  stopifnot(all(c("ConditionId", "Arm", "Replicate", "InputId", "args", "facet", "purpose") %in% names(spec)),
    identical(a$method, "JML"), a$model %in% c("RSM", "PCM", "GPCM"),
    is.data.frame(a$data), spec$facet %in% a$facets, a$maxit == 400L,
    a$category_policy == "preserve", is.null(a$population_formula), is.null(a$person_data),
    is.null(a$quad_points), is.null(a$mml_engine), is.null(a$mml_integration))
  if (a$model == "GPCM") stopifnot(length(a$slope_facet) == 1L, identical(a$slope_facet, a$step_facet))
  if (is.null(order)) stopifnot(identical(a$optimizer, "BFGS"), a$reltol == 1e-9) else
    stopifnot(a$model == "GPCM", length(order) == 1L, order %in% c(2L, 4L),
      a$jml_correction_sampling %in% c("fixed_rosters", "random_rosters"),
      is.null(a$optimizer), is.null(a$reltol), is.null(a$noncenter_facet))
  invisible(TRUE)
}

wide_jml_source <- function(fit) {
  if (mfrmr:::mfrm_has_jml_adjustment(fit)) mfrmr:::mfrm_jml_scoring_components(fit)$source else
    mfrmr:::prediction_source_scoring_readiness(fit)
}

wide_jml_runtime <- function() {
  x <- wide_mml_runtime()
  x$source <- c(x$source, tools::md5sum("inst/validation/mfrm-wide-map-jml-stages-20261001.R"))
  x$optional_solvers <- setNames(vapply(c("nleqslv", "lpSolve"), function(p)
    if (requireNamespace(p, quietly = TRUE)) as.character(packageVersion(p)) else "unavailable", ""),
    c("nleqslv", "lpSolve"))
  x
}

wide_jml_run <- function(spec, out, initial = NULL) {
  wide_jml_validate(spec)
  if (!is.null(initial)) stopifnot(spec$purpose == "workflow_witness_only",
    identical(initial$args, spec$args), inherits(initial$fit, "mfrm_fit"), length(initial$provenance) > 0L)
  runtime <- wide_jml_runtime()
  manifest <- list(spec = spec, runtime = runtime, initial = initial)
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  old <- wide_mml_phase(file.path(out, "manifest.rds"), "jml-single-call-v1", function() manifest)
  if (!identical(old, manifest)) stop("JML job data/settings/source changed; saved phases cannot be reused.")
  identity <- wide_mml_hash(manifest)
  finished <- FALSE; phase <- "fit"
  state <- function(status) wide_mml_save(list(identity = identity, status = status,
    phase = phase, time = Sys.time()), file.path(out, "status.rds"))
  on.exit(if (!finished) state("interrupted"), add = TRUE)
  run <- function(name, dependency, call) {
    phase <<- name; state("running")
    wide_mml_phase(file.path(out, paste0(name, ".rds")),
      list(job = identity, phase = name, dependency = dependency), call)
  }
  fitting <- run("fit", NULL, function() {
    if (!is.null(initial)) return(list(value = initial$fit, error = "", warnings = character(),
      elapsed = 0, origin = "retained_workflow_witness"))
    wide_mml_capture(function() wide_mml_fit(spec$args))
  })
  fit <- fitting$value; fh <- wide_mml_hash(fitting)
  review <- list(value = NULL, error = fitting$error)
  point <- NULL; root <- NULL; covariance <- NULL
  if (!nzchar(fitting$error)) {
    stopifnot(inherits(fit, "mfrm_fit"), fit$config$method == "JML", fit$config$model == spec$args$model)
    order <- spec$args$jml_correction_order
    if (is.null(order)) stopifnot(!mfrmr:::mfrm_has_jml_adjustment(fit)) else stopifnot(
      identical(fit$jml_adjustment$estimator$order, as.integer(order)),
      identical(fit$jml_adjustment$estimator$sampling, spec$args$jml_correction_sampling))
    point <- fit$facets$others[fit$facets$others$Facet == spec$facet, ]
    root <- fit$jml_adjustment$point
    covariance <- fit$jml_adjustment$covariance
    review <- run("scoring-source", fh, function() wide_mml_capture(function() wide_jml_source(fit)))
  }
  selected <- list(identity = identity, spec_hash = wide_mml_hash(spec),
    stage = paste0("initial:", fh), fit_error = fitting$error, initial_points = point,
    scoring_source = review, root = root, root_covariance = covariance,
    numerical = fit$opt$optimizer_diagnostics, readiness = fit$readiness,
    formal_structural_intervals = FALSE,
    interval_reason = "No qualified structural-parameter CI procedure in this study arm; ordinary screening SE and corrected RootSE are not substituted.")
  stopifnot(identical(wide_jml_runtime(), runtime))
  result <- run("selected", fh, function() selected)
  stopifnot(identical(result, selected))
  phase <- "complete"; state("complete"); finished <- TRUE
  result
}

# Same meaning as the MML ledger's point rows: source-reviewed structural
# points, with raw public initial-call points and root dispositions retained.
wide_jml_records <- function(spec, selected) {
  if (!identical(selected$spec_hash, wide_mml_hash(spec))) stop("Selected JML outputs must retain their exact job specification.")
  targets <- sort(unique(as.character(spec$args$data[[spec$facet]])))
  review <- selected$scoring_source
  error <- if (nzchar(selected$fit_error)) selected$fit_error else review$error
  values <- selected$initial_points$Estimate[match(targets, selected$initial_points$Level)]
  if (!length(values)) values <- rep(NA_real_, length(targets))
  reason <- if (nzchar(error)) error else paste(c(review$value$reason_codes,
    review$value$local_calibration_review$review), collapse = "; ")
  available <- !nzchar(error) & isTRUE(review$value$ready) & is.finite(values)
  data.frame(ConditionId = spec$ConditionId, Arm = spec$Arm, Replicate = spec$Replicate,
    Target = paste(spec$facet, targets, sep = ":"), Output = "point",
    Status = if (nzchar(error)) "error" else "returned", Available = available,
    Estimate = values, SE = NA_real_, Lower = NA_real_, Upper = NA_real_,
    SourceStage = selected$stage, Reason = ifelse(available, "", reason))
}

wide_jml_output_plan <- function(spec) {
  rows <- wide_mml_output_plan(spec)
  rows$Eligibility[rows$Output == "interval"] <- "unsupported"
  rows$ExclusionReason[rows$Output == "interval"] <- "Formal JML structural interval procedure remains unresolved."
  rows
}
