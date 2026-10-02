# Repository-only execution for one MML location family and its scoring
# calibration. Not a bulk launcher, Person-scoring runner or JML adapter.
# One worker owns each directory. Completed phases are immutable; interruption
# resumes a phase, not an optimizer's partial iterate. No random draws here.
wide_mml_hash <- function(x) mfrmr:::mfrm_checkpoint_fingerprint(x)

wide_mml_save <- function(x, path) {
  tmp <- tempfile(basename(path), tmpdir = dirname(path))
  on.exit(unlink(tmp), add = TRUE)
  saveRDS(x, tmp, version = 3)
  if (!file.rename(tmp, path)) stop("Atomic stage save failed: ", path)
  invisible(x)
}

wide_mml_runtime <- function() {
  paths <- c("inst/validation/mfrm-wide-map-mml-stages-20261001.R",
    "DESCRIPTION", "NAMESPACE", sort(list.files("R", "[.]R$", full.names = TRUE)),
    sort(list.files("src", "[.](cpp|h)$", full.names = TRUE)),
    getLoadedDLLs()[["mfrmr"]][["path"]])
  hashes <- tools::md5sum(paths)
  stopifnot(!anyNA(hashes))
  names(hashes)[length(hashes)] <- "loaded:mfrmr"
  desc <- read.dcf("DESCRIPTION")
  imports <- trimws(sub("\\s*\\(.*", "", unlist(strsplit(
    paste(desc[1, c("Depends", "Imports", "LinkingTo")], collapse = ","), ","))))
  imports <- setdiff(imports, "R")
  packages <- sort(unique(c("mfrmr", imports, unlist(tools::package_dependencies(
    imports, db = installed.packages(), recursive = TRUE), use.names = FALSE))))
  list(source = hashes, R = R.version.string, platform = R.version$platform,
    dependencies = setNames(vapply(packages, function(p) as.character(packageVersion(p)), ""), packages),
    libraries = extSoftVersion(), information_bytes = getOption("mfrmr.max_information_bytes", 256*1024^2),
    threads = Sys.getenv(c("OMP_NUM_THREADS",
      "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")))
}

wide_mml_capture <- function(call) {
  warnings <- character(); error <- ""
  started <- proc.time()
  # Interrupts deliberately propagate; they are not completed statistical errors.
  value <- withCallingHandlers(tryCatch(call(), error = function(e) {
    error <<- conditionMessage(e); NULL
  }), warning = function(w) {
    warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning")
  })
  list(value = value, error = error, warnings = unique(warnings),
    elapsed = unname((proc.time() - started)["elapsed"]))
}

wide_mml_phase <- function(path, binding, compute) {
  if (file.exists(path)) {
    old <- readRDS(path)
    if (!identical(old$binding, binding) ||
        !identical(old$checksum, wide_mml_hash(old$payload)))
      stop("Saved phase identity or checksum mismatch: ", path)
    return(old$payload)
  }
  payload <- compute()
  wide_mml_save(list(binding = binding, checksum = wide_mml_hash(payload),
    payload = payload), path)
  payload
}

wide_mml_scoring_retry <- function(x) {
  if (isTRUE(x$ready)) return(FALSE)
  local <- x$local_calibration_review
  d <- local$integration
  if (identical(local$basis, "two_family_point_calibration_v1")) {
    fields <- c("OriginalOrder", "ComparisonOrder", "NLLChangePerPerson", "ComparisonMeanGradient")
    return(isTRUE(x$parameter_ready) && is.data.frame(d) && nrow(d) == 1L &&
      all(fields %in% names(d)) && all(is.finite(unlist(d[fields]))) &&
      (d$NLLChangePerPerson > 1e-6 || d$ComparisonMeanGradient > 1e-6))
  }
  fields <- c("OriginalOrder", "ComparisonOrder", "NLLChange", "GradientChange", "ComparisonGradient")
  # Presence of these diagnostics means the consumer completed the preceding
  # local-source checks. Do not classify generic errors or two-family metrics.
  identical(local$basis, "local_mml_and_integration_v1") &&
    isTRUE(x$parameter_ready) && is.data.frame(d) && nrow(d) == 1L &&
    all(fields %in% names(d)) && all(is.finite(unlist(d[fields]))) &&
    (d$NLLChange > 1e-5 || d$GradientChange > 1e-4 || d$ComparisonGradient > 1e-4)
}

wide_mml_interval_retry <- function(x) {
  checks <- x$checks; d <- x$numerical_checks
  if (isTRUE(x$settings$two_family)) {
    fields <- c("InverseResidual", "MaximumMeanScore", "CurvatureScaledGradient",
      "QuadratureScoreShift", "QuadratureCovarianceChange")
    return(is.data.frame(checks) && all(c("Check", "Passed") %in% names(checks)) &&
      !anyNA(checks$Passed) && identical(checks$Check[!checks$Passed], "Quadrature sensitivity") &&
      is.data.frame(d) && nrow(d) == 1L && all(fields %in% names(d)) &&
      all(is.finite(unlist(d[fields]))) && d$InverseResidual <= 1e-6 &&
      d$MaximumMeanScore <= 1e-6 && d$CurvatureScaledGradient <= .01 &&
      (d$QuadratureScoreShift > .01 || d$QuadratureCovarianceChange > .01))
  }
  fields <- c("InverseResidual", "ComparisonInverseResidual",
    "CurvatureScaledGradient", "QuadratureScoreShift", "QuadratureCovarianceChange")
  identical(x$settings$procedure, "mml_native_location_model_v1") &&
    is.data.frame(checks) && all(c("Check", "Passed") %in% names(checks)) &&
    !anyNA(checks$Passed) && identical(checks$Check[!checks$Passed], "Quadrature comparison") &&
    is.data.frame(d) && nrow(d) == 1L && all(fields %in% names(d)) &&
    all(is.finite(unlist(d[fields]))) && d$InverseResidual <= 1e-6 &&
    d$ComparisonInverseResidual <= 1e-6 && d$CurvatureScaledGradient <= .01 &&
    (d$QuadratureScoreShift > .01 || d$QuadratureCovarianceChange > .01)
}

wide_mml_fit <- function(args) do.call(mfrmr::fit_mfrm, args)
wide_mml_score <- function(fit) mfrmr:::prediction_source_scoring_readiness(fit)
wide_mml_interval <- function(fit, facet, level) mfrmr::mfrm_facet_intervals(fit, facet, level = level)

wide_mml_validate <- function(spec) {
  a <- spec$args
  product <- identical(a$model, "GPCM") && length(a$slope_facet) == 2L
  stopifnot(all(c("ConditionId", "Arm", "Replicate", "InputId", "args", "facet", "level", "purpose") %in% names(spec)),
    identical(a$method, "MML"), a$model %in% c("RSM", "PCM", "GPCM"),
    identical(a$mml_engine, "direct"),
    identical(a$mml_integration, if (product) "adaptive" else "fixed"),
    identical(a$optimizer, "BFGS"), a$maxit == if (product) 500L else 400L,
    a$reltol == if (product) 1e-10 else 1e-9,
    is.null(a$quad_points), spec$facet %in% a$facets, is.data.frame(a$data),
    length(unique(a$data[[spec$facet]])) >= 2L, !anyNA(a$data[[spec$facet]]),
    is.finite(spec$level), spec$level > 0, spec$level < 1,
    a$category_policy == "preserve", is.null(a$contrasts))
  if (product) {
    stopifnot(identical(a$facets, a$slope_facet), !anyDuplicated(a$slope_facet),
      identical(a$step_facet, a$slope_facet[2L]), identical(a$noncenter_facet, a$step_facet),
      identical(a$gpcm_mml_identification, "fixed_standard_normal"),
      identical(a$gpcm_mml_start, "neutral_em"), is.null(a$population_formula),
      a$rating_min == 0, a$rating_max >= 1, a$rating_max == as.integer(a$rating_max))
    return(invisible(TRUE))
  }
  # Ordinary fixed-population RSM/PCM uses its existing interval procedure.
  if (a$model == "GPCM") stopifnot(length(a$slope_facet) == 1L,
    a$gpcm_mml_identification %in% c("free_population", "fixed_standard_normal"))
  if (!is.null(a$population_formula) ||
      identical(a$gpcm_mml_identification, "free_population"))
    stopifnot(inherits(a$population_formula, "formula"),
      identical(all.vars(a$population_formula), character()),
      identical(as.character(a$population_formula), c("~", "1")))
  if (identical(a$gpcm_mml_identification, "fixed_standard_normal"))
    stopifnot(is.null(a$population_formula))
  invisible(TRUE)
}

wide_mml_fixed_ordinary <- function(fit) {
  fit$config$model %in% c("RSM", "PCM") &&
    !isTRUE(fit$config$population_spec$active)
}

wide_mml_interval_table <- function(value) {
  tab <- value$table
  if (!"CIEligible" %in% names(tab)) {
    # The older public fixed-population object uses Status, without the newer
    # native-location diagnostics. Normalize a copy, preserving the public object.
    stopifnot(wide_mml_fixed_ordinary(value$fit), value$settings$method == "model",
      all(c("Target", "Estimate", "SE", "Lower", "Upper", "Status") %in% names(tab)))
    tab$CIEligible <- tab$Status == "available"
    tab$InferenceReview <- ifelse(tab$CIEligible, "", paste("Fixed-population interval:", tab$Status))
  }
  tab
}

wide_mml_interval_plan <- function(spec) {
  a <- spec$args
  if (identical(a$model, "GPCM") && length(a$slope_facet) == 2L) {
    n <- length(unique(a$data[[a$person]]))
    levels <- vapply(a$slope_facet, function(f) length(unique(a$data[[f]])), 1L)
    # First locations/log slopes are centered; the second family is free.
    # Each second-owner step ladder has K-2 free coordinates.
    p <- unname(2L * (levels[1L] - 1L) + (a$rating_max + 1L) * levels[2L])
    if (n < p) return(list(eligibility = "design_excluded", persons = n, parameters = p,
      reason = sprintf("Current two-family interval procedure requires Person-score rank %d; at most %d observed Persons are available. This is not a general identification verdict.", p, n)))
  }
  list(eligibility = "eligible", reason = "")
}

wide_mml_run <- function(spec, out, initial = NULL) {
  wide_mml_validate(spec)
  # Historical imports are explicitly limited to workflow witnesses until the
  # original estimator/binary/source bridge for study counting is established.
  if (!is.null(initial)) stopifnot(spec$purpose == "workflow_witness_only",
    identical(initial$args, c(spec$args, list(quad_points = 31L))),
    inherits(initial$fit, "mfrm_fit"), length(initial$provenance) > 0L,
    initial$fit$config$estimation_control$quad_points == 31L)
  runtime <- wide_mml_runtime()
  manifest <- list(spec = spec, runtime = runtime, initial = initial, orders = c(31L, 61L, 121L))
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  manifest <- wide_mml_phase(file.path(out, "manifest.rds"), "mml-location-stages-v2", function() manifest)
  if (!identical(manifest, list(spec = spec, runtime = runtime, initial = initial, orders = c(31L, 61L, 121L))))
    stop("Job data/settings/source changed; saved phases cannot be reused.")
  identity <- wide_mml_hash(manifest)
  finished <- FALSE; phase <- "start"; q <- 31L
  state <- function(status) wide_mml_save(list(identity = identity, status = status,
    phase = phase, order = q, time = Sys.time()), file.path(out, "status.rds"))
  on.exit(if (!finished) state("interrupted"), add = TRUE)
  run <- function(name, dependency, call) {
    phase <<- name; state("running")
    wide_mml_phase(file.path(out, paste0("q", q, "-", name, ".rds")),
      list(job = identity, order = q, phase = name, dependency = dependency), call)
  }
  point <- interval <- NULL; stages <- list()
  interval_plan <- wide_mml_interval_plan(spec)
  need_point <- TRUE; need_interval <- interval_plan$eligibility == "eligible"
  for (order in manifest$orders) {
    q <- order
    fitting <- run("fit", NULL, function() {
      if (q == 31L && !is.null(initial)) return(list(value = initial$fit,
        error = "", warnings = character(), elapsed = 0, origin = "retained_workflow_witness"))
      wide_mml_capture(function() wide_mml_fit(c(spec$args, list(quad_points = q))))
    })
    fit <- fitting$value; fh <- wide_mml_hash(fitting); stage <- paste0("q", q, ":", fh)
    if (nzchar(fitting$error)) {
      failed <- list(stage = stage, fit_hash = fh, error = fitting$error, value = NULL)
      if (need_point) point <- failed
      if (need_interval) interval <- failed
      stages[[as.character(q)]] <- list(stage = stage, fit_error = fitting$error,
        retry_point = FALSE, retry_interval = FALSE)
      break
    }
    stopifnot(inherits(fit, "mfrm_fit"), fit$config$estimation_control$quad_points == q)
    retry_point <- retry_interval <- FALSE
    if (need_point) {
      review <- run("scoring-source", fh, function() wide_mml_capture(function() wide_mml_score(fit)))
      point <- list(stage = stage, fit_hash = fh, error = review$error, value = review$value,
        estimates = fit$facets$others[fit$facets$others$Facet == spec$facet, ])
      retry_point <- !nzchar(review$error) && wide_mml_scoring_retry(review$value)
      need_point <- retry_point && q < 121L
    }
    if (need_interval) {
      ci <- run("interval", fh, function() wide_mml_capture(function() wide_mml_interval(fit, spec$facet, spec$level)))
      if (!nzchar(ci$error)) stopifnot(identical(ci$value$fit, fit),
        if (wide_mml_fixed_ordinary(fit)) !isTRUE(ci$value$settings$two_family) else
        if (length(spec$args$slope_facet) == 2L) isTRUE(ci$value$settings$two_family) else
          identical(ci$value$settings$procedure, "mml_native_location_model_v1"))
      interval <- list(stage = stage, fit_hash = fh, error = ci$error, value = ci$value)
      retry_interval <- !nzchar(ci$error) && wide_mml_interval_retry(ci$value)
      need_interval <- retry_interval && q < 121L
    }
    stages[[as.character(q)]] <- list(stage = stage, fit_error = "",
      retry_point = retry_point, retry_interval = retry_interval)
    if (!need_point && !need_interval) break
  }
  # Recheck source bytes before sealing results. Completed phases remain even
  # if this final identity check or selected-output save fails.
  stopifnot(identical(wide_mml_runtime()$source, runtime$source))
  selected <- list(identity = identity, spec_hash = wide_mml_hash(spec),
    point = point, interval = interval, interval_plan = interval_plan, stages = stages,
    initial_stage = "q31-fit.rds", purpose = spec$purpose)
  result <- wide_mml_phase(file.path(out, "selected.rds"), identity, function() selected)
  stopifnot(identical(result, selected))
  phase <- "complete"; state("complete"); finished <- TRUE
  result
}

wide_mml_records <- function(spec, selected) {
  if (!identical(selected$spec_hash, wide_mml_hash(spec)))
    stop("Selected outputs must retain their exact job specification.")
  targets <- sort(unique(as.character(spec$args$data[[spec$facet]])))
  rows <- lapply(c("point", "interval"), function(output) {
    if (output == "interval" && selected$interval_plan$eligibility != "eligible") return(NULL)
    x <- selected[[output]]
    z <- data.frame(ConditionId = spec$ConditionId, Arm = spec$Arm, Replicate = spec$Replicate,
      Target = paste(spec$facet, targets, sep = ":"), Output = output,
      Status = if (nzchar(x$error)) "error" else "returned", Available = FALSE,
      Estimate = NA_real_, SE = NA_real_, Lower = NA_real_, Upper = NA_real_,
      SourceStage = x$stage, Reason = if (nzchar(x$error)) x$error else "Source/output review failed")
    if (output == "point" && !is.null(x$estimates)) {
      z$Estimate <- x$estimates$Estimate[match(targets, x$estimates$Level)]
      z$Available <- !nzchar(x$error) & isTRUE(x$value$ready) & is.finite(z$Estimate)
      if (!isTRUE(x$value$ready) && !nzchar(x$error))
        z$Reason <- paste(c(x$value$reason_codes, x$value$local_calibration_review$review), collapse = "; ")
    }
    if (output == "interval" && !is.null(x$value)) {
      tab <- wide_mml_interval_table(x$value)
      t <- tab[match(targets, tab$Target), ]
      stopifnot(!anyNA(t$Target), !any(t$Status == "fixed"))
      z$Estimate <- t$Estimate; z$Available <- t$CIEligible
      z$SE[z$Available] <- t$SE[z$Available]
      z$Lower[z$Available] <- t$Lower[z$Available]; z$Upper[z$Available] <- t$Upper[z$Available]
      z$Reason <- t$InferenceReview
    }
    z$Reason[z$Available] <- ""; z
  })
  do.call(rbind, rows)
}

# Reference values are deliberately left for the separately specified analysis
# plan; execution never reads truth to choose a source stage.
wide_mml_output_plan <- function(spec) {
  targets <- sort(unique(as.character(spec$args$data[[spec$facet]])))
  rows <- expand.grid(Target = paste(spec$facet, targets, sep = ":"),
    Output = c("point", "interval"), stringsAsFactors = FALSE)
  rows$ConditionId <- spec$ConditionId; rows$Arm <- spec$Arm; rows$Replicate <- spec$Replicate
  rows$InputId <- spec$InputId; rows$Eligibility <- "eligible"
  interval <- wide_mml_interval_plan(spec)
  rows$Eligibility[rows$Output == "interval"] <- interval$eligibility
  rows$ExclusionReason <- ifelse(rows$Output == "interval", interval$reason, "")
  rows$Reference <- "none"; rows$ReferenceValue <- NA_real_; rows
}
