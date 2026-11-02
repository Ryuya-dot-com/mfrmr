#' Read an exported Bayesian measurement summary and optional joint draws
#'
#' Bring a saved Stan/brms summary (and, when available, its checksum-bound
#' `posterior-draws.rds`) back into mfrmr for shared-calibration contrasts,
#' arbitrary equal-tailed credible levels, figures and reports without loading
#' either sampling backend or running an estimator.
#' @param path An export directory containing `posterior-summary.rds` and
#'   its matching `model-data.rds`, or the path to that summary file.
#' @param draws One of `"auto"` (default: attach `posterior-draws.rds` when
#'   present alongside `posterior-summary.rds`, or return the marginal summary
#'   alone when absent), `"require"` (require `posterior-draws.rds`, falling
#'   back to `fit.rds` when the matching backend is installed), or `"none"`
#'   (ignore saved joint draws and read only the marginal summary).
#' @return An `mfrm_posterior_summary` containing unrounded parameter and
#'   diagnostic tables, source settings, priors, mappings and constraints, plus
#'   algebraic basis metadata (`$bundle_spec`), new-Person scoring metadata
#'   (`$scoring_spec`), and, when joint draws are attached, validated
#'   chain-by-iteration draws (`$draws`) and optional contrast tables
#'   (`$contrasts`). Extended two-family bundles also retain named facet roles
#'   and the prior's slope reference in `$model_roles` and `$source`.
#' @details Run the exported bundle's `Rscript run.R --summarize` first.
#' Current `summarize.R` writes both `posterior-summary.rds` and
#' `posterior-draws.rds`, binding them by MD5 checksums to `model-data.rds`.
#' The reader checks the recorded model-data and summary checksums, parameter
#' mappings, fixed-value semantics, free-to-constrained affine/Helmert basis
#' reconstruction, and consistency of the saved sampling checks. Older
#' summaries without a checksum (or without `posterior-draws.rds` when joint
#' draws are needed) can be regenerated with the current `run.R` and
#' `summarize.R` using `--summarize`; no new sampling is needed. Keep the
#' original `model-data.rds` bytes with the fit when moving an export directory.
#'
#' When only `posterior-summary.rds` is present, the object contains marginal
#' 95% summaries, not joint posterior draws: parameter covariance is never
#' fabricated from marginal SDs, and requests for contrasts, other credible
#' levels, or empirical draw plots fail closed. When `posterior-draws.rds` is
#' attached, `summary(x, contrasts = ..., level = ...)`, `confint()`, `plot()`,
#' `as.data.frame()`, and [mfrm_report()] evaluate linear or ratio contrasts
#' directly across the shared chain-by-iteration posterior draws while checking
#' algebraic constraint bases (`fixed_anchor` and `fixed_by_constraint` roles
#' are determined from the exported basis matrices, never from sample variance).
#' Posterior SDs, equal-tailed credible intervals, and tail probabilities
#' (`prob_gt_zero`, `prob_lt_zero`) are Bayesian summaries conditional on the
#' model, priors, and fixed anchors; they are not frequentist standard errors,
#' Wald confidence intervals, two-sided p-values, or MML likelihood-ratio tests.
#'
#' Estimated-population one-family Stan summaries retain the population mean
#' and SD as reported parameters. Their schema-2 files require this newer reader;
#' existing fixed-population schema-1 summaries remain supported. Use
#' `plot(x, quantity = "population_sd")` to inspect between-Person variation
#' on the native metric. This SD is not an individual Person standard error.
#'
#' Fixed anchors and constraint-determined values have no estimated SD or
#' interval (`NA`). External calibration uncertainty has not been propagated.
#' `summary()` returns the validated object (recomputing credible bounds or
#' attaching `$contrasts` when requested); printing is compact.
#' The bundled synthetic examples use short chains and require sampling
#' review; their numbers are workflow illustrations, not assessment findings.
#' @seealso [export_mfrm_model()], [predict.mfrm_posterior_summary()],
#'   [plot.mfrm_posterior_summary()]
#' @examples
#' # 1. Marginal summary bundle (no joint draws file):
#' directory <- system.file("extdata", "posterior-example", package = "mfrmr")
#' posterior <- read_mfrm_posterior(directory)
#' summary(posterior) # Read the decision and next action before the estimates.
#' intervals <- confint(posterior)
#' head(intervals[, c("facet", "level", "value_role", "lower", "upper", "interval_status")])
#'
#' # 2. Joint posterior draws bundle: shared-calibration contrasts and custom level:
#' draws_dir <- system.file("extdata", "posterior-draws-example", package = "mfrmr")
#' joint_post <- read_mfrm_posterior(draws_dir)
#' contrasted <- summary(joint_post, contrasts = "Rater", level = 0.90)
#' contrasted$contrasts[, c("label", "value_role", "mean", "lower", "upper",
#'                          "prob_gt_zero", "interval_status")]
#' head(as.data.frame(contrasted, what = "draws"), 4)
#' report <- mfrm_report(contrasted, style = "apa", study_context = c(
#'   score_direction = "Higher coded scores indicate more favorable performance"))
#' summary(report, view = "reader")
#' @export
#' @order 1
read_mfrm_posterior <- function(path, draws = c("auto", "require", "none")) {
  if (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(path))
    stop("`path` must identify one saved export summary or directory.", call. = FALSE)
  draws <- match.arg(draws)
  file <- if (dir.exists(path)) file.path(path, "posterior-summary.rds") else path
  model_file <- file.path(dirname(file), "model-data.rds")
  if (!file.exists(file) || !file.exists(model_file))
    stop("Keep posterior-summary.rds and its matching model-data.rds together.", call. = FALSE)
  x <- readRDS(file)
  if (!is.list(x) || length(x$schema_version) != 1L || !x$schema_version %in% c(1L, 2L) ||
      !identical(x$model_data_md5, unname(tools::md5sum(model_file))))
    stop("The summary has no matching model-data checksum. Regenerate it with the current run.R and summarize.R using --summarize; no new sampling is needed.", call. = FALSE)
  bundle <- readRDS(model_file)
  if (!is.list(bundle) ||
      !is.character(bundle$source_method) || length(bundle$source_method) != 1L ||
      !bundle$source_method %in% c("MML", "specification") ||
      !is.character(bundle$model) || length(bundle$model) != 1L ||
      !bundle$model %in% c("RSM", "PCM", "GPCM"))
    stop("Expected a model-data bundle from export_mfrm_model().", call. = FALSE)
  helpers <- .mfrm_posterior_helpers()
  expected_version <- if (is.null(bundle$population)) 1L else 2L
  if (!identical(x$schema_version, expected_version) ||
      (!is.null(bundle$schema_version) && !identical(bundle$schema_version, expected_version)) ||
      (expected_version == 2L && (!identical(bundle$schema_version, 2L) ||
        !identical(x$backend, "Stan") || !identical(bundle$model, "GPCM"))))
    stop("Incompatible population bundle and summary versions; regenerate the matching summary.", call. = FALSE)
  if (!identical(x$level, .95))
    stop("Inconsistent exported posterior summary; regenerate it from the matching saved fit and bundle.", call. = FALSE)
  x$parameter_map <- helpers$mfrm_parameter_map(bundle)
  x$population <- bundle$population
  d <- bundle$stan_data
  x$source <- data.frame(Model = bundle$model, Backend = x$backend,
    Estimation = "External Bayesian sampling", ExportSourceMethod = bundle$source_method,
    PackageVersion = bundle$package_version,
    Ratings = d$N, Persons = d$J, Categories = d$C,
    Population = helpers$mfrm_population_label(x$population), ResponseMetric = "Adjacent-category logit (D = 1)",
    Interval = x$interval, Level = x$level, Chains = x$chains, ModelDataMD5 = x$model_data_md5)
  x$priors <- bundle$priors
  if (!is.null(bundle$model_roles)) {
    x$model_roles <- bundle$model_roles
    x$source$SlopeReference <- bundle$model_roles$slope_reference
    x$source$StepFacet <- bundle$model_roles$step_facet
    x$source$UncenteredFacet <- bundle$model_roles$noncenter_facet
  }
  x$constraints <- bundle$constraints
  x$categories <- bundle$categories
  x$bundle_spec <- .mfrm_extract_bundle_spec(bundle)
  x$scoring_spec <- .mfrm_extract_scoring_spec(bundle)
  draws_obj <- .mfrm_load_posterior_draws(dirname(file), file, x, bundle, mode = draws)
  if (!is.null(draws_obj)) {
    x$draws <- draws_obj
  }
  class(x) <- "mfrm_posterior_summary"
  .mfrm_validate_posterior(x)
  x
}

.mfrm_posterior_helpers <- function() {
  env <- new.env(parent = baseenv())
  sys.source(system.file("model-export", "summarize.R", package = "mfrmr"), envir = env)
  env
}

.mfrm_validate_posterior <- function(x) {
  fail <- function() stop("Inconsistent exported posterior summary; regenerate it from the matching saved fit and bundle.", call. = FALSE)
  if (!inherits(x, "mfrm_posterior_summary") ||
      !identical(x$schema_version, if (is.null(x$population)) 1L else 2L) ||
      !is.character(x$backend) || length(x$backend) != 1L || !x$backend %in% c("Stan", "brms") ||
      !is.numeric(x$level) || length(x$level) != 1L || !is.finite(x$level) || x$level <= 0 || x$level >= 1 ||
      !identical(x$interval, "equal-tailed posterior credible interval for varying parameters") ||
      length(x$chains) != 1L || !is.numeric(x$chains) || !is.finite(x$chains) || x$chains < 1 || x$chains != as.integer(x$chains)) fail()
  p <- x$parameters; map <- x$parameter_map
  numeric <- c("mean", "median", "sd", "lower", "upper", "rhat", "ess_bulk", "ess_tail", "mcse_lower", "mcse_upper", "fixed_value")
  required <- c("variable", "quantity", "facet", "level", "transition", "value_role", "role", "reference", "direction",
    "sampling_review", "interval_status", "interval_computed", numeric)
  if (!is.data.frame(p) || !nrow(p) || !all(required %in% names(p)) ||
      !is.character(p$variable) || anyNA(p$variable) || any(!nzchar(p$variable)) || anyDuplicated(p$variable) ||
      !all(vapply(p[numeric], function(v) is.numeric(v) && all(is.na(v) | is.finite(v)), logical(1))) ||
      !is.data.frame(map) || !all(c("variable", "value_role", "fixed_value") %in% names(map)) ||
      anyNA(map$variable) || anyDuplicated(map$variable) || !all(map$variable %in% p$variable)) fail()
  if (any(as.matrix(p[c("sd", "ess_bulk", "ess_tail", "mcse_lower", "mcse_upper")]) < 0, na.rm = TRUE) ||
      any(p$rhat <= 0, na.rm = TRUE) ||
      any(as.matrix(p[p$quantity %in% c("slope", "population_sd"), c("mean", "median", "lower", "upper"), drop = FALSE]) <= 0, na.rm = TRUE)) fail()
  at <- match(map$variable, p$variable)
  for (name in names(map)) if (!identical(p[[name]][at], map[[name]])) fail()
  internal <- !p$variable %in% map$variable
  if (anyNA(p$value_role) || !all(p$value_role %in% c("estimated", "fixed_anchor", "fixed_by_constraint", "sampling_coordinate")) ||
      !identical(p$role, ifelse(p$variable %in% map$variable, "reported_parameter", "free_coordinate")) ||
      any(p$value_role[internal] != "sampling_coordinate") || anyNA(p$quantity) ||
      any(p$quantity[internal] != "internal_coordinate") ||
      any(!is.na(as.matrix(p[internal, c("facet", "level", "transition", "direction", "fixed_value"), drop = FALSE])))) fail()
  fixed <- p$value_role %in% c("fixed_anchor", "fixed_by_constraint")
  if (any(!is.finite(p$mean[fixed])) || any(abs(p$mean[fixed] - p$fixed_value[fixed]) > 1e-7 * pmax(1, abs(p$fixed_value[fixed]))) ||
      any(!is.na(as.matrix(p[fixed, setdiff(numeric, c("mean", "median", "fixed_value")), drop = FALSE]))) ||
      any(p$lower > p$upper, na.rm = TRUE) ||
      !identical(p$interval_computed, is.finite(p$lower) & is.finite(p$upper) & !fixed)) fail()
  if (!is.data.frame(x$sampler) || !is.data.frame(x$checks) || !is.data.frame(x$decision)) fail()
  expected <- .mfrm_posterior_helpers()$mfrm_sampling_review(p, x$sampler, x$chains)
  fields <- c("Check", "Value", "Criterion", "Status")
  if (!all(fields %in% names(x$checks)) ||
      !isTRUE(all.equal(x$checks[fields], expected[fields], check.attributes = FALSE, tolerance = 0))) fail()
  status <- if (any(expected$Status != "no_flag")) "sampling_review_required" else "no_sampling_flags_detected"
  if (nrow(x$decision) != 1L || !identical(x$decision$Status, status) ||
      !all(c("Interpretation", "Why", "NextAction") %in% names(x$decision)) ||
      anyNA(p$sampling_review) || any(p$sampling_review != status)) fail()
  interval_status <- ifelse(fixed, "fixed_value_no_interval", ifelse(!p$interval_computed, "unavailable",
    if (status == "sampling_review_required") "computed_sampling_review_required" else "computed_model_review_required"))
  if (!identical(p$interval_status, interval_status) || !is.data.frame(x$source) || nrow(x$source) != 1L ||
      !is.character(x$source$ExportSourceMethod) || length(x$source$ExportSourceMethod) != 1L ||
      !x$source$ExportSourceMethod %in% c("MML", "specification") ||
      !identical(x$source$ModelDataMD5, x$model_data_md5) || !identical(x$source$Backend, x$backend) ||
      !identical(x$source$Level, x$level) || !identical(x$source$Population,
        .mfrm_posterior_helpers()$mfrm_population_label(x$population))) fail()
  .mfrm_validate_posterior_draws_and_contrasts(x, fail)
  invisible(x)
}

#' @rdname read_mfrm_posterior
#' @param object A saved `mfrm_posterior_summary`.
#' @param ... Unused.
#' @export
print.mfrm_posterior_summary <- function(x, ...) {
  rlang::check_dots_empty()
  .mfrm_validate_posterior(x)
  cat("External Bayesian measurement summary\n")
  cat(x$source$Model, "|", x$backend, "|", x$source$Population, "\n")
  cat(x$decision$Interpretation, "\nWhy: ", x$decision$Why,
    "\nNext: inspect $checks, then model fit, prior sensitivity and target-specific MCSE.\n", sep = "")
  cat(sum(x$parameters$role == "reported_parameter"), "mapped parameters; fixed values have no estimated interval.\n")
  if (!is.null(x$draws)) {
    cat("Joint draws attached: ", x$chains, " chains x ", x$draws$iterations,
        " iterations (", format(100 * x$level, trim = TRUE), "% credible level).\n", sep = "")
  }
  main <- x$parameters[x$parameters$role == "reported_parameter" & x$parameters$quantity != "log_slope", ]
  tab <- utils::head(main[!duplicated(main[c("quantity", "value_role")]), ], 8L)
  label <- paste(tab$facet, tab$level, sep = ": ")
  steps <- !is.na(tab$transition)
  label[steps] <- paste(label[steps], tab$transition[steps], sep = " | ")
  display <- data.frame(Parameter = label, Role = tab$value_role,
    Mean = tab$mean, Lower = tab$lower, Upper = tab$upper,
    Interval = ifelse(!is.na(tab$fixed_value), "Fixed value", ifelse(!tab$interval_computed, "Unavailable",
      ifelse(tab$sampling_review == "sampling_review_required", "Sampling review", "Model review remains"))))
  print(round_numeric_df(display, digits = 3L), row.names = FALSE)
  if (!is.null(x$contrasts) && nrow(x$contrasts) > 0L) {
    cat("Attached contrasts (", nrow(x$contrasts), "):\n", sep = "")
    ct <- utils::head(x$contrasts, 6L)
    ct_disp <- data.frame(
      Contrast = ct$label,
      Role = ct$value_role,
      Mean = ct$mean,
      Lower = ct$lower,
      Upper = ct$upper,
      ProbGT = ct$prob_gt_zero
    )
    print(round_numeric_df(ct_disp, digits = 3L), row.names = FALSE)
  }
  cat("Use $parameters, confint(x), plot(x), or mfrm_report(x). Sampling checks do not establish model validity.\n")
  invisible(x)
}

#' @rdname read_mfrm_posterior
#' @param contrasts Optional contrast specification evaluated on shared
#'   chain-by-iteration draws (`posterior-draws.rds` required): a character
#'   vector of facet/owner names (for example `"Rater"` or `"Step owner"`), a
#'   `data.frame` with `lhs` and `rhs` (plus optional `facet`, `quantity`,
#'   `label`, and `scale = c("difference", "ratio")`), or a non-empty named list
#'   of numeric weight vectors keyed by `variable` or `"Facet: Level"`.
#' @param level Equal-tailed posterior credible interval level strictly between
#'   `0` and `1` (defaults to `object$level`, initially `0.95`). Changing `level`
#'   requires attached joint draws (`posterior-draws.rds`) and is rejected rather
#'   than approximated from marginal SDs when draws are absent.
#' @export
summary.mfrm_posterior_summary <- function(object, contrasts = NULL, level = object$level, ...) {
  rlang::check_dots_empty()
  .mfrm_validate_posterior(object)
  level <- .mfrm_validate_credible_level(level)
  if (is.null(contrasts) && abs(level - object$level) <= 1e-12) {
    return(object)
  }
  if (abs(level - object$level) > 1e-12) {
    object <- .mfrm_recompute_posterior_level(object, level)
  }
  if (!is.null(contrasts)) {
    specs <- .mfrm_resolve_contrast_specs(object, contrasts)
    res <- .mfrm_evaluate_contrast_specs(object, specs, level = level)
    object$contrasts <- res$contrasts
    object$contrast_draws <- res$contrast_draws
  }
  .mfrm_validate_posterior(object)
  object
}

#' @rdname read_mfrm_posterior
#' @param parm Optional saved parameter names (for example `"locations[1]"`),
#'   row indices in `$parameters`, or `"contrasts"` when contrasts are attached.
#'   `NULL` returns mapped model parameters (unless `contrasts` is supplied).
#' @export
confint.mfrm_posterior_summary <- function(object, parm = NULL, level = object$level,
                                           contrasts = NULL, ...) {
  rlang::check_dots_empty()
  .mfrm_validate_posterior(object)
  level <- .mfrm_validate_credible_level(level)
  if (is.null(object$draws) && abs(level - object$level) > 1e-12) {
    stop("Only the stored 95% posterior credible interval is available. Use the backend's draws for another level.", call. = FALSE)
  }
  if (!is.null(contrasts)) {
    if (!is.null(parm)) {
      stop("Supply either `parm` or `contrasts`, not both.", call. = FALSE)
    }
    specs <- .mfrm_resolve_contrast_specs(object, contrasts)
    res <- .mfrm_evaluate_contrast_specs(object, specs, level = level)
    out <- res$contrasts
    out$interval_type <- "equal-tailed posterior credible interval for varying contrasts"
    attr(out, "notes") <- object$notes
    return(out)
  }
  if (identical(parm, "contrasts")) {
    if (is.null(object$contrasts)) {
      stop("No posterior contrasts are attached; supply `contrasts` or call `summary(object, contrasts = ...)` first.", call. = FALSE)
    }
    if (abs(level - object$level) > 1e-12) {
      object <- .mfrm_recompute_posterior_level(object, level)
    }
    out <- object$contrasts
    out$interval_type <- "equal-tailed posterior credible interval for varying contrasts"
    attr(out, "notes") <- object$notes
    return(out)
  }
  if (abs(level - object$level) > 1e-12) {
    object <- .mfrm_recompute_posterior_level(object, level)
  }
  p <- object$parameters
  if (is.null(parm)) at <- which(p$role == "reported_parameter") else if (is.character(parm)) {
    at <- match(parm, p$variable)
  } else if (is.numeric(parm) && all(is.finite(parm)) && all(parm == as.integer(parm))) {
    at <- as.integer(parm)
  } else stop("`parm` must select saved parameter names or row indices.", call. = FALSE)
  if (!length(at) || anyNA(at) || any(at < 1L | at > nrow(p)) || anyDuplicated(at))
    stop("`parm` must select distinct existing parameters.", call. = FALSE)
  out <- p[at, , drop = FALSE]
  out$interval_type <- object$interval
  out$credible_level <- object$level
  attr(out, "notes") <- object$notes
  out
}

#' @rdname read_mfrm_posterior
#' @param row.names Optional row names passed to [base::as.data.frame()].
#' @param optional Logical passed to [base::as.data.frame()].
#' @param what Component to extract as a `data.frame`: `"parameters"` (default),
#'   `"contrasts"` (posterior contrast summary table), `"draws"` (long
#'   chain-by-iteration parameter draws), or `"contrast_draws"` (long
#'   chain-by-iteration contrast draws).
#' @export
as.data.frame.mfrm_posterior_summary <- function(x, row.names = NULL, optional = FALSE, ...,
                                                 what = c("parameters", "contrasts", "draws", "contrast_draws"),
                                                 contrasts = NULL, level = x$level) {
  rlang::check_dots_empty()
  .mfrm_validate_posterior(x)
  what <- match.arg(what)
  level <- .mfrm_validate_credible_level(level)
  if (!is.null(contrasts) || abs(level - x$level) > 1e-12) {
    x <- summary.mfrm_posterior_summary(x, contrasts = contrasts, level = level)
  }
  d <- switch(
    what,
    parameters = x$parameters,
    contrasts = {
      if (is.null(x$contrasts)) {
        stop("No posterior contrasts are attached; supply `contrasts` or call `summary(x, contrasts = ...)` first.", call. = FALSE)
      }
      x$contrasts
    },
    draws = .mfrm_posterior_draws_long(x, "draws"),
    contrast_draws = .mfrm_posterior_draws_long(x, "contrast_draws")
  )
  as.data.frame(d, row.names = row.names, optional = optional, stringsAsFactors = FALSE)
}
