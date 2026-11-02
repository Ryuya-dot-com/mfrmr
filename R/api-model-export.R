#' Export a measurement model to Stan or brms
#'
#' Write a self-contained Bayesian model bundle without running an estimator.
#' Supply either a fitted native MML `mfrm_fit` (`fit`) or a long-format rating
#' `data` table with a model specification list (`spec`) so ordinary RSM/PCM and
#' one-family GPCM bundles can be written directly without MML optimization,
#' Hessian evaluation, or EAP scoring.
#' Supports ordinary RSM/PCM and fixed-population one-family GPCM in
#' both formats. Estimated-population one-family GPCM (both `fit` and `spec`
#' routes) and two-family GPCM (`fit` route) use
#' Stan. Fixed facet/group and step anchors are retained.
#' Sources must be unit-weight, with a fixed standard-normal Person population
#' or (Stan only, one-family GPCM) an estimated intercept-only normal population,
#' and no facet interactions or
#' post-fit shrinkage. Unsupported specifications fail before files are written.
#'
#' @param fit Optional native RSM/PCM or GPCM MML `mfrm_fit` returned by
#'   [fit_mfrm()]. Supply either `fit`, or `data` together with `spec`.
#' @param output_dir Destination directory. The bundle includes observed ratings
#'   and original level labels; review it before sharing.
#' @param format Either `"stan"` (CmdStanR) or `"brms"` (custom family).
#' @param location_prior_sd Positive marginal prior SD for each varying facet
#'   location; fixed or uniquely determined locations have zero prior SD.
#' @param step_prior_sd Positive marginal prior SD for each varying step offset.
#' @param overwrite Replace bundle files that already exist? Defaults to `FALSE`.
#' @param acknowledge_sensitive Suppress the reminder that ratings and original
#'   identifiers are included. Defaults to `FALSE`.
#' @param log_slope_prior_sd Positive marginal prior SD of each component log
#'   slope for GPCM export. Defaults to 1; inspect prior
#'   sensitivity. Not used by RSM/PCM models.
#' @param population_prior Normal prior parameters for an estimated Person
#'   population: a named list with `mean = c(location, scale)` for its mean
#'   and `log_sd = c(location, scale)` for the log of its standard deviation.
#'   Each scale must be positive. Defaults give `mu ~ normal(0, 1)` and
#'   `log(sigma) ~ normal(0, 0.5)`. Unused for fixed-population exports.
#' @param data Optional long-format rating `data.frame` used with `spec` to
#'   export directly from rating data without fitting an MML model first.
#' @param spec Optional named list defining the measurement model when `data`
#'   is supplied (the same 33-key `spec` shared with [describe_mfrm_data()],
#'   [review_mfrm_anchors()], and [fit_mfrm()]). Required entries are `person`,
#'   `facets`, and `score`. Supported optional entries match [fit_mfrm()]:
#'   `model` (`"RSM"` default, `"PCM"`, or `"GPCM"`), `method` (`"MML"` only),
#'   `step_facet` (required for `"GPCM"`, not applicable to `"RSM"`),
#'   `slope_facet` (one declared facet for `"GPCM"`),
#'   `gpcm_mml_identification` (`"free_population"` default or
#'   `"fixed_standard_normal"`, `"GPCM"` only), `anchors`, `group_anchors`,
#'   `anchor_policy` (`"error"` default before writing files, `"warn"`, or
#'   `"silent"`), `min_common_anchors`, `min_obs_per_element`,
#'   `min_obs_per_category`, `noncenter_facet` (`"Person"` default),
#'   `centering_scope` (`"facet"` default or `"remainder"`), `positive_facets`,
#'   `rating_min`, `rating_max`, `category_policy` (`"collapse"` or
#'   `"preserve"`), `keep_original`, `missing_codes`, `weight` (unit weights
#'   only), and `repeated_ratings` (`"review"` default or `"independent"`).
#'   Unsupported model extensions (`population_formula`, `facet_interactions`,
#'   `dummy_facets`) or numerical `control` entries fail closed before files
#'   are written.
#' @param write_json Logical; if `TRUE` (for `format = "stan"` only), also write
#'   CmdStanR-compatible `model-data.json` alongside `model-data.rds` and the
#'   CSV label/category maps, without requiring `cmdstanr` or `jsonlite`.
#'   Defaults to `FALSE`.
#' @param run_cmdstan Logical; if `TRUE` (for `format = "stan"` only), compile
#'   and sample the exported Stan bundle immediately via `cmdstanr` using the
#'   bundle's `run.R` helper, persist `fit.rds`, `predictive-draws.rds`,
#'   `posterior-summary.rds`, `posterior-draws.rds`, and CSV diagnostic tables,
#'   and attach the validated `mfrm_posterior_summary` object as `$posterior`.
#'   Requires both the `cmdstanr` package and a configured CmdStan installation;
#'   fails before writing files when either is absent. Defaults to `FALSE`.
#' @param cmdstan_args Optional named list of sampling arguments forwarded to
#'   `cmdstanr`'s `$sample()` when `run_cmdstan = TRUE` (allowed entries:
#'   `seed`, `chains`, `parallel_chains`, `iter_warmup`, `iter_sampling`,
#'   `adapt_delta`, `max_treedepth`, `refresh`, `show_messages`,
#'   `show_exceptions`, `init`). `data` and `output_dir` are bound to the
#'   exported bundle and cannot be overridden. Defaults to `list()`.
#'
#' @details
#' The default one-family GPCM estimates its population mean and variance.
#' Its intercept-only population can be exported to Stan, retaining the native
#' metric, relative-slope constraint and supported fixed anchors. The generated
#' model uses `theta = mu + sigma * z`, with independent standard-normal `z`.
#' The population mean and SD are sampled, not fixed at their MML estimates.
#' `population_prior` adds explicit Bayesian priors: by default sigma has median
#' 1 and a central 95% prior interval of approximately 0.38 to 2.66. These are
#' starting assumptions, not a population-size recommendation; inspect prior
#' predictions and sensitivity for your rubric and anchors. The displayed
#' Person prior SD includes uncertainty in both mu and sigma, not only sigma.
#' Population regression, estimated-mean models with a fixed SD, and estimated-population
#' brms or two-family exports are not supported. Choosing
#' `gpcm_mml_identification = "fixed_standard_normal"` changes the model;
#' it is not a file-format conversion or a workaround for these exclusions.
#'
#' Both formats retain the category ladder, facet signs, facet centering and
#' RSM/PCM step ownership of the source specification. RSM/PCM adjacent-category log odds
#' are `theta + signed facet locations - step`. Steps follow their declared
#' within-owner sum targets (zero by default) and are **not ordered**. A binary
#' ladder has its single offset fixed at its target. Fixed-population ability
#' parameters have independent standard-normal priors; realized abilities are
#' not centered across the observed Persons in either population mode.
#'
#' All supported exports preserve the native logistic metric (L-metric),
#' with scaling constant \eqn{D = 1}. No extra 1.7 or 1.702 factor is used.
#' Standard-normal ability priors do not imply a normal-ogive response link.
#' The "Logistic metric (D = 1)" section of [fit_mfrm()] explains the scale
#' and the adjustments needed before comparing other parameterizations.
#'
#' Centered locations and steps use an orthonormal contrast basis. Independent
#' normal coordinates are scaled so each constrained component has the requested
#' marginal SD. A centered singleton is fixed at zero. Uncentered locations have
#' independent normal priors. These proper structural priors are additions to
#' MML: the Bayesian posterior is not a reproduction of MML point estimates or
#' frequentist confidence intervals. Review prior sensitivity for the application.
#'
#' Two-family GPCM is available with `format = "stan"` only. Its effective
#' slope is the product of the two component slopes and multiplies the entire
#' adjacent-category predictor, including locations and steps. The first
#' family's log slopes sum to zero; the second family's log slopes are free
#' on the fixed N(0,1) ability scale. Normal priors on orthonormal/free log-slope
#' coordinates give each component the specified marginal log-slope SD.
#' `slope-levels.csv` maps the generated `component_slopes` and
#' `log_component_slopes` to their owners and levels. This preserves the source
#' likelihood, not an MML interval or the exact priors/program of Uto and Ueno
#' (2020). In particular, the extra 1.7 multiplier in their Appendix is absent.
#' Additional fixed additive facets and separate step/noncentered roles are
#' supported from an existing two-family fit. Extended bundles retain these
#' roles in `model-data.rds$model_roles` and in the posterior reader. The
#' geometric-mean-one reference is the source fit's `slope_reference`. Exporting
#' a fit with another reference and fresh independent log-slope priors changes
#' the Bayesian model; it is not a prior-preserving coordinate transformation.
#' Direct `data`/`spec` export and new-Person posterior scoring remain unsupported
#' for two-family models.
#' One-family GPCM supports both formats. Its single owner's log slopes sum
#' to zero (geometric mean one); its slope also multiplies the entire predictor.
#' A singleton slope owner is fixed at one.
#'
#' Fixed non-Person facet anchors, group means and step anchors are exact affine
#' constraints. The export preserves whole-facet versus remainder centering and
#' each step owner's target. Priors on the remaining free contrasts are centered
#' so each free level shares its block's remaining total equally. These priors
#' are defined on the constrained subspace, not obtained by conditioning an
#' earlier unanchored posterior. `levels.csv` and `steps.csv` in these bundles
#' record the affine prior means, marginal SDs and fixed-coordinate indicators;
#' `model-data.rds$constraints` retains the source constraints. One-family bundles
#' use the same affine representation even without anchors. Anchors are fixed
#' inputs: zero posterior spread does not establish certainty about their earlier
#' calibration. Uncertain external calibration is not propagated. Retained step
#' constraints are exported; this does not add a step-anchor fitting argument.
#' Native two-family fitting retains its anchor exclusion. Person anchors
#' require JML in native fitting and remain outside this MML exporter.
#'
#' `model-data.rds` records the design matrices, priors and mappings used by both
#' formats. When `write_json = TRUE` (`format = "stan"` only), `model-data.json`
#' also serializes `model-data.rds$stan_data` using CmdStanR's JSON array/scalar
#' rules so external Stan runners can read the data without R; keep
#' `model-data.rds` and the CSV files for label mappings and [read_mfrm_posterior()].
#' `levels.csv` maps original labels to generated parameters;
#' `categories.csv` maps Stan/brms categories to the source score scale.
#' `run.R` fits the exported model and saves draws, diagnostics and replicated
#' ratings. Run it from the bundle directory, after installing CmdStanR/CmdStan
#' and, for the brms format, brms. Neither is required to export a bundle.
#' Both formats support `Rscript run.R --summarize` to regenerate summaries
#' from `fit.rds` without compiling or sampling. Keep `model-data.rds`,
#' `summarize.R` and the brms `model.R` with the saved fit.
#' Read `summary-decision.csv` first, then `sampling-review.csv` for the checks,
#' criteria and next actions. `parameter-summary.csv` joins original labels to
#' estimates, references and score-direction notes. `value_role` distinguishes
#' estimated values, fixed anchors and constraint-determined values. Fixed
#' values have no estimated SD or interval (`NA`); they do not establish zero
#' external calibration uncertainty. Varying parameters retain equal-tailed
#' 95% credible bounds, endpoint MCSE, R-hat and bulk/tail ESS, even during
#' review, with `interval_status` beside the values. `interval_computed` means
#' finite bounds for a varying parameter, not reliable sampling or coverage.
#' `sampler-diagnostics.csv` contains per-chain diagnostics;
#' `posterior-summary.rds` retains all four tables and interpretation notes,
#' and `posterior-draws.rds` stores the matching base-R chain-by-iteration
#' parameter draws bound by checksum for contrasts and arbitrary credible levels.
#'
#' The screen checks at least four chains, R-hat below 1.01, bulk/tail ESS at
#' least 100 per chain, zero divergences/tree-depth hits and E-BFMI at least
#' 0.3. Missing diagnostics require review; fixed coordinates are excluded
#' using model constraints, not sample variance. Tree-depth hits flag efficiency
#' separately from divergences. These checks follow the
#' [Stan diagnostic guidance](https://mc-stan.org/learn-stan/diagnostics-warnings.html)
#' and are not a certificate of validity. Review all varying coordinates,
#' model fit and priors. The larger endpoint MCSE divided by interval width
#' measures simulation precision; no universal acceptable fraction is imposed.
#' Read the matching summary, joint draws and model-data files with
#' [read_mfrm_posterior()] to use `summary()`, `confint()`, `plot()`,
#' `as.data.frame()` and [mfrm_report()] without either sampling backend.
#' Keep `fit.rds` for posterior predictive replay and backend-specific tools.
#' Generated brms callbacks support `log_lik()`, `posterior_predict()` and
#' `posterior_epred()`; the last returns category probabilities.
#'
#' Log likelihood and replicated ratings condition on the sampled abilities of
#' existing Persons. They do not provide leave-one-Person-out validation or
#' predictions for new Persons; use [predict.mfrm_posterior_summary()] to score
#' new Persons against the saved calibration posterior without updating
#' calibration parameters. Exporting does not qualify the original fit's
#' convergence, inference, or an external sampler's diagnostics. Repeated ratings
#' retain the source conditional-independence assumption.
#'
#' @return Invisibly, a list with `format`, `model`, `output_dir` and named
#'   `files` (plus `posterior`, a validated [read_mfrm_posterior()] object with
#'   joint draws attached, when `run_cmdstan = TRUE`). When `run_cmdstan = FALSE`
#'   (default), no model is fitted and no external software is required.
#' @seealso [export_mfrm_results()], [fit_mfrm()], [read_mfrm_posterior()],
#'   [predict.mfrm_posterior_summary()]
#' @references
#' Uto, M., & Ueno, M. (2020). A generalized many-facet Rasch model and its
#' Bayesian estimation using Hamiltonian Monte Carlo. *Behaviormetrika, 47*,
#' 469-496. \doi{10.1007/s41237-020-00115-7}. Equation 9, Sections 6-7 and Appendix.
#' @examples
#' # Each row in example_core is one integer rating (Person x Rater x Criterion).
#' ratings <- load_mfrmr_data("example_core")
#' # Illustrative fixed reference; applications need justified calibration values.
#' anchor <- data.frame(Facet = "Rater",
#'                      Level = as.character(ratings$Rater[1]), Anchor = 0)
#' # Direct specification export builds the Stan bundle and CmdStan JSON data
#' # without running native MML optimization, Stan, or brms.
#' spec <- list(
#'   person = "Person",
#'   facets = c("Rater", "Criterion"),
#'   score = "Score",
#'   model = "GPCM",
#'   step_facet = "Criterion",
#'   slope_facet = "Criterion",
#'   anchors = anchor
#' )
#' stan <- export_mfrm_model(
#'   output_dir = tempfile("mfrmr-stan-"),
#'   format = "stan",
#'   acknowledge_sensitive = TRUE,
#'   data = ratings,
#'   spec = spec,
#'   write_json = TRUE
#' )
#' names(stan$files) # Inspect levels.csv, categories.csv, model-data.rds/json, and README.txt
#' bundle <- readRDS(stan$files[["model-data.rds"]])
#' bundle$categories # Generated categories mapped to original scores
#' bundle$population # Estimated mean/SD and their priors
#' bundle$priors
#' unlink(stan$output_dir, recursive = TRUE)
#'
#' # An existing native MML fit can also be exported directly:
#' \dontrun{
#' fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
#'                 model = "GPCM", method = "MML", step_facet = "Criterion",
#'                 slope_facet = "Criterion", anchors = anchor,
#'                 anchor_policy = "silent")
#' from_fit <- export_mfrm_model(fit, tempfile("mfrmr-fit-stan-"), "stan",
#'                               acknowledge_sensitive = TRUE)
#' unlink(from_fit$output_dir, recursive = TRUE)
#' }
#' @export
export_mfrm_model <- function(fit = NULL, output_dir, format = c("stan", "brms"),
                              location_prior_sd = 1, step_prior_sd = 1,
                              overwrite = FALSE, acknowledge_sensitive = FALSE,
                              log_slope_prior_sd = 1,
                              population_prior = list(mean = c(0, 1), log_sd = c(0, 0.5)),
                              data = NULL, spec = NULL,
                              write_json = FALSE,
                              run_cmdstan = FALSE,
                              cmdstan_args = list()) {
  format <- match.arg(format)
  for (x in c("overwrite", "acknowledge_sensitive", "write_json", "run_cmdstan")) {
    value <- get(x)
    if (!is.logical(value) || length(value) != 1L || is.na(value)) {
      stop("`", x, "` must be TRUE or FALSE.", call. = FALSE)
    }
  }
  if (missing(output_dir) || !is.character(output_dir) || length(output_dir) != 1L ||
      is.na(output_dir) || !nzchar(output_dir)) {
    stop("`output_dir` must be one nonempty path.", call. = FALSE)
  }
  if (write_json && format != "stan") {
    stop("`write_json = TRUE` is supported for `format = 'stan'` only.", call. = FALSE)
  }
  cmdstan_args <- mfrm_validate_cmdstan_args(cmdstan_args, run_cmdstan = run_cmdstan, format = format)
  if (run_cmdstan) {
    mfrm_require_cmdstan_ready()
  }
  for (x in c("location_prior_sd", "step_prior_sd", "log_slope_prior_sd")) {
    value <- get(x)
    if (!is.numeric(value) || length(value) != 1L ||
        !is.finite(value) || value <= 0) {
      stop("`", x, "` must be a finite positive number.", call. = FALSE)
    }
  }
  if (!is.null(fit) && is.data.frame(fit) && is.null(data) && !is.null(spec)) {
    data <- fit
    fit <- NULL
  }
  has_fit <- !is.null(fit)
  has_data_or_spec <- !is.null(data) || !is.null(spec)
  if (has_fit && has_data_or_spec) {
    stop("Supply either `fit` or `data` with `spec`, not both.", call. = FALSE)
  }
  if (!has_fit && (is.null(data) || is.null(spec))) {
    stop("Supply either `fit`, or both `data` and `spec`.", call. = FALSE)
  }
  source_obj <- if (has_fit) fit else mfrm_prepare_export_spec(data, spec)
  product <- mfrm_has_product_slopes(source_obj) && identical(source_obj$config$model, "GPCM")
  if (product && format != "stan") stop(
    "Two-family GPCM model export supports format = 'stan' only.", call. = FALSE)
  bundle <- mfrm_model_export_data(source_obj, location_prior_sd, step_prior_sd,
                                  log_slope_prior_sd, population_prior)
  free_population <- !is.null(bundle$population)
  if (free_population && format != "stan") stop(paste(
    "Estimated-population one-family GPCM export supports format = 'stan' only.",
    if (has_fit) {
      "Keep the original fit; choosing fixed_standard_normal changes the model."
    } else {
      "Keep the intended specification; choosing fixed_standard_normal changes the model."
    }
  ), call. = FALSE)
  template_dir <- system.file("model-export", package = "mfrmr")
  model_file <- if (format == "stan") "model.stan" else "model.R"
  templates <- c(if (free_population) "model-population.stan" else
                   if (isTRUE(bundle$affine)) paste0("model-affine.", if (format == "stan") "stan" else "R") else
                   if (product) "model-gmfrm.stan" else model_file,
                 paste0("run-", format, ".R"), if (isTRUE(bundle$affine)) "README-affine.txt" else
                   if (product) "README-gmfrm.txt" else "README.txt", "summarize.R")
  source_files <- file.path(template_dir, templates)
  if (!all(file.exists(source_files))) {
    stop("Model export templates are missing from this installation.", call. = FALSE)
  }
  filenames <- c("model-data.rds", if (write_json) "model-data.json",
                 "levels.csv", "categories.csv",
                 model_file, "run.R", "README.txt", if (!is.null(bundle$slope_levels)) "slope-levels.csv",
                 if (isTRUE(bundle$affine)) "steps.csv", "summarize.R")
  files <- stats::setNames(file.path(output_dir, filenames), filenames)
  run_outputs <- if (run_cmdstan) {
    out_names <- c("fit.rds", "predictive-draws.rds", "posterior-summary.rds",
                   "posterior-draws.rds", "summary-decision.csv",
                   "sampling-review.csv", "parameter-summary.csv",
                   "sampler-diagnostics.csv")
    stats::setNames(file.path(output_dir, out_names), out_names)
  } else {
    character(0)
  }
  check_existing <- c(files, run_outputs)
  if (any(dir.exists(check_existing)) || (!overwrite && any(file.exists(check_existing)))) {
    stop("Bundle files already exist; use a new directory or `overwrite = TRUE`.",
         call. = FALSE)
  }
  if (!acknowledge_sensitive) {
    warning("The model bundle includes observed ratings and original level labels. Review it before sharing.",
            call. = FALSE)
  }
  if (!dir.exists(output_dir) && !dir.create(output_dir, recursive = TRUE)) {
    stop("Could not create `output_dir`.", call. = FALSE)
  }
  saveRDS(bundle, files[["model-data.rds"]])
  if (write_json) mfrm_write_stan_json(bundle$stan_data, files[["model-data.json"]])
  utils::write.csv(bundle$levels, files[["levels.csv"]], row.names = FALSE,
                   fileEncoding = "UTF-8")
  utils::write.csv(bundle$categories, files[["categories.csv"]], row.names = FALSE)
  if (!is.null(bundle$slope_levels)) utils::write.csv(bundle$slope_levels, files[["slope-levels.csv"]],
    row.names = FALSE, fileEncoding = "UTF-8")
  if (isTRUE(bundle$affine)) utils::write.csv(bundle$step_levels, files[["steps.csv"]],
    row.names = FALSE, fileEncoding = "UTF-8")
  if (!all(file.copy(source_files, files[c(model_file, "run.R", "README.txt", "summarize.R")], overwrite = overwrite))) {
    stop("Could not copy all model export templates.", call. = FALSE)
  }
  norm_dir <- normalizePath(output_dir)
  if (!run_cmdstan) {
    return(invisible(list(format = format, model = bundle$model,
                          output_dir = norm_dir, files = files)))
  }
  mfrm_execute_exported_stan(norm_dir, cmdstan_args = cmdstan_args)
  files <- c(files, run_outputs)
  posterior <- read_mfrm_posterior(norm_dir, draws = "require")
  invisible(list(format = format, model = bundle$model,
                 output_dir = norm_dir, files = files,
                 posterior = posterior))
}

.mfrm_has_cmdstanr <- function() {
  requireNamespace("cmdstanr", quietly = TRUE)
}

.mfrm_cmdstan_path <- function() {
  tryCatch(cmdstanr::cmdstan_path(), error = function(e) NULL)
}

mfrm_require_cmdstan_ready <- function() {
  if (!isTRUE(.mfrm_has_cmdstanr())) {
    stop(
      "Optional Stan execution (`run_cmdstan = TRUE`) requires the `cmdstanr` package. ",
      "Install `cmdstanr` and CmdStan (see https://mc-stan.org/cmdstanr/), or set `run_cmdstan = FALSE` to write the bundle without sampling.",
      call. = FALSE
    )
  }
  cmdstan_dir <- .mfrm_cmdstan_path()
  if (!is.character(cmdstan_dir) || length(cmdstan_dir) != 1L ||
      is.na(cmdstan_dir) || !nzchar(cmdstan_dir) || !dir.exists(cmdstan_dir)) {
    stop(
      "`cmdstanr` is installed, but no configured CmdStan toolchain was found (`cmdstanr::cmdstan_path()`). ",
      "Run `cmdstanr::install_cmdstan()` or `cmdstanr::set_cmdstan_path()`, or set `run_cmdstan = FALSE`.",
      call. = FALSE
    )
  }
  invisible(cmdstan_dir)
}

mfrm_validate_cmdstan_args <- function(cmdstan_args, run_cmdstan, format) {
  if (!is.list(cmdstan_args) || is.data.frame(cmdstan_args)) {
    stop("`cmdstan_args` must be a named list of CmdStanR sampling options.", call. = FALSE)
  }
  if (!run_cmdstan) {
    if (length(cmdstan_args) > 0L) {
      stop("`cmdstan_args` requires `run_cmdstan = TRUE`.", call. = FALSE)
    }
    return(list())
  }
  if (format != "stan") {
    stop("`run_cmdstan = TRUE` is supported for `format = 'stan'` only.", call. = FALSE)
  }
  if (!length(cmdstan_args)) {
    return(list())
  }
  nm <- names(cmdstan_args)
  if (is.null(nm) || anyNA(nm) || any(!nzchar(nm)) || anyDuplicated(nm)) {
    stop("`cmdstan_args` must have unique non-empty names.", call. = FALSE)
  }
  if (any(c("data", "output_dir") %in% nm)) {
    stop(
      "`cmdstan_args` cannot override `data` or `output_dir`; `export_mfrm_model()` binds both to the exported bundle.",
      call. = FALSE
    )
  }
  allowed <- c(
    "seed", "chains", "parallel_chains", "iter_warmup", "iter_sampling",
    "adapt_delta", "max_treedepth", "refresh", "show_messages",
    "show_exceptions", "init"
  )
  extra <- setdiff(nm, allowed)
  if (length(extra) > 0L) {
    stop(
      "Unsupported entries in `cmdstan_args`: ", paste(extra, collapse = ", "),
      ". Allowed entries: ", paste(allowed, collapse = ", "), ".",
      call. = FALSE
    )
  }
  cmdstan_args
}

mfrm_execute_exported_stan <- function(bundle_dir, cmdstan_args = list()) {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(bundle_dir)
  run_env <- new.env(parent = globalenv())
  sys.source("run.R", envir = run_env)
  if (isFALSE(cmdstan_args$show_messages)) {
    invisible(utils::capture.output(
      run_env$run_mfrm_stan(args = character(0), sample_args = cmdstan_args)
    ))
  } else {
    run_env$run_mfrm_stan(args = character(0), sample_args = cmdstan_args)
  }
  invisible(TRUE)
}

mfrm_export_basis <- function(n, centered = TRUE) {
  if (!centered) return(diag(n))
  if (n == 1L) return(matrix(numeric(), 1L, 0L))
  h <- stats::contr.helmert(n)
  sweep(h, 2L, sqrt(colSums(h^2)), "/")
}

mfrm_model_export_data <- function(fit, location_prior_sd, step_prior_sd,
                                   log_slope_prior_sd = 1,
                                   population_prior = list(mean = c(0, 1), log_sd = c(0, 0.5))) {
  is_spec <- inherits(fit, "mfrm_export_spec")
  if (!is_spec && (!inherits(fit, "mfrm_fit") ||
      inherits(fit, c("mfrm_testlet", "mfrm_random_rater")))) {
    stop("`fit` must be an ordinary mfrm_fit, or supply `data` and `spec`.", call. = FALSE)
  }
  for (x in c("location_prior_sd", "step_prior_sd", "log_slope_prior_sd")) {
    value <- get(x)
    if (!is.numeric(value) || length(value) != 1L ||
        !is.finite(value) || value <= 0) {
      stop("`", x, "` must be a finite positive number.", call. = FALSE)
    }
  }
  cfg <- fit$config
  product <- identical(cfg$model, "GPCM") && mfrm_has_product_slopes(fit)
  if (!cfg$model %in% c("RSM", "PCM", "GPCM") || !identical(cfg$method, "MML") ||
      inherits(fit, "mfrm_imported_fit")) {
    stop("Model export supports native ordinary RSM/PCM/GPCM MML specifications only.",
         call. = FALSE)
  }
  single <- identical(cfg$model, "GPCM") && !product
  if (single && (length(cfg$slope_facet) != 1L ||
      !identical(cfg$gpcm_spec$levels, cfg$facet_levels[[cfg$slope_facet]]) ||
      !identical(cfg$gpcm_spec$identification, "sum_to_zero_log_slopes") ||
      !identical(cfg$gpcm_spec$scale_reference, "geometric_mean_one") ||
      cfg$gpcm_spec$n_params != max(length(cfg$gpcm_spec$levels) - 1L, 0L))) {
    stop("One-family slope levels or constraints disagree with the fitted specification.", call. = FALSE)
  }
  if (product) {
    mfrm_gpcm_slope_roles(cfg)
    roles <- mfrm_gmfrm_roles(cfg$facet_names, cfg$slope_facet,
      cfg$step_facet, cfg$noncenter_facet, cfg$slope_facet[1L])
    if (any(lengths(cfg$gpcm_spec$component_levels) < 2L) ||
        !identical(cfg$gpcm_spec$component_levels, cfg$facet_levels[cfg$slope_facet]) ||
        !identical(cfg$step_facet, cfg$gpcm_spec$step_facet)) stop(
      "Two-family slope levels or step ownership disagree with the fitted specification.", call. = FALSE)
    extended_roles <- length(cfg$facet_names) != 2L ||
      !identical(cfg$noncenter_facet, cfg$slope_facet[2L]) ||
      !identical(cfg$step_facet, cfg$slope_facet[2L])
    if (extended_roles && (!identical(vapply(cfg$facet_specs, function(s) isTRUE(s$centered), logical(1)),
          stats::setNames(cfg$facet_names != cfg$noncenter_facet, cfg$facet_names)) ||
        !identical(roles, mfrm_gmfrm_roles(fit$gmfrm$specification$facets,
          fit$gmfrm$specification$slope_facets, fit$gmfrm$specification$step_facet,
          fit$gmfrm$specification$noncenter_facet, fit$gmfrm$specification$slope_reference))))
      stop("Saved two-family roles and location constraints disagree with the fitted specification.", call. = FALSE)
  }
  pop <- cfg$population_spec
  free_population <- isTRUE(pop$active)
  if (free_population) {
    Xp <- pop$design_matrix
    if (!single || !is.null(pop$fixed_sd) || !is.matrix(Xp) ||
        !is.numeric(Xp) || ncol(Xp) != 1L || !nrow(Xp) ||
        anyNA(Xp) || any(Xp != 1) ||
        !identical(pop$design_columns, "(Intercept)")) {
      stop("Estimated-population export requires one-family GPCM with an intercept-only normal population and free SD; regression and two-family populations are unsupported.", call. = FALSE)
    }
    ids <- as.character(fit$population$person_table[[pop$person_id]])
    lookup <- pop$person_lookup
    if (length(ids) != nrow(Xp) || anyNA(ids) || anyDuplicated(ids) ||
        !is.numeric(lookup) || length(lookup) != length(cfg$person_levels) ||
        anyNA(lookup) || any(!is.finite(lookup)) || any(lookup != as.integer(lookup)) ||
        any(lookup < 1 | lookup > length(ids)) ||
        !identical(ids[lookup], as.character(cfg$person_levels))) {
      stop("Population rows do not match the fitted Person identities.", call. = FALSE)
    }
    if (!is.list(population_prior) || length(population_prior) != 2L ||
        !setequal(names(population_prior), c("mean", "log_sd")) ||
        !all(vapply(population_prior, function(x) is.numeric(x) && length(x) == 2L &&
          all(is.finite(x)) && x[2L] > 0, logical(1)))) {
      stop("`population_prior` must contain mean and log_sd, each c(location, positive scale).", call. = FALSE)
    }
  }
  if (length(cfg$interaction_specs) || length(cfg$dummy_facets) ||
      !identical(cfg$facet_shrinkage %||% "none", "none")) {
    stop("Model export does not support interactions, dummy facets or shrinkage.",
         call. = FALSE)
  }
  specs <- c(list(cfg$theta_spec), cfg$facet_specs)
  anchored <- vapply(specs, function(s) {
    any(!is.na(s$anchors)) || any(!is.na(s$groups) & nzchar(s$groups))
  }, logical(1))
  step_specs <- mfrmr_step_specs(cfg)
  if (anchored[1L]) {
    stop("MML model export does not support Person anchors.", call. = FALSE)
  }
  affine <- single || any(anchored) || any(vapply(step_specs, function(s) {
    any(!is.na(s$anchors)) || !isTRUE(s$target == 0)
  }, logical(1)))
  d <- fit$prep$data
  if (!is.data.frame(d) || !nrow(d) || anyNA(d$Weight) ||
      any(d$Weight != 1)) {
    stop("Model export requires retained observations with unit weights.", call. = FALSE)
  }
  facets <- cfg$facet_names
  maps <- lapply(facets, function(f) {
    s <- cfg$facet_specs[[f]]
    if (!identical(as.character(s$levels), as.character(cfg$facet_levels[[f]]))) {
      stop("Facet levels and constraints disagree.", call. = FALSE)
    }
    mfrm_export_affine_map(s, location_prior_sd)
  })
  basis <- lapply(maps, `[[`, "basis")
  nr <- vapply(basis, nrow, integer(1))
  nc <- vapply(basis, ncol, integer(1))
  B <- matrix(0, sum(nr), sum(nc))
  X <- matrix(0, nrow(d), sum(nc))
  location_sd <- numeric(sum(nc))
  location_offset <- numeric(sum(nr))
  eta_offset <- numeric(nrow(d))
  levels <- list(data.frame(Facet = "Person", Level = cfg$person_levels,
                            Index = seq_along(cfg$person_levels),
                            Parameter = paste0("theta[", seq_along(cfg$person_levels), "]"),
                            Sign = 1, Centered = FALSE))
  row_start <- col_start <- 0L
  for (i in seq_along(facets)) {
    f <- facets[i]
    rows <- row_start + seq_len(nr[i])
    cols <- col_start + seq_len(nc[i])
    index <- match(as.character(d[[f]]), cfg$facet_levels[[f]])
    sign <- cfg$facet_signs[[f]]
    if (anyNA(index) || length(sign) != 1L || !sign %in% c(-1, 1)) {
      stop("Invalid retained facet indices or signs.", call. = FALSE)
    }
    B[rows, cols] <- basis[[i]]
    X[, cols] <- sign * basis[[i]][index, , drop = FALSE]
    centered <- isTRUE(cfg$facet_specs[[f]]$centered)
    location_sd[cols] <- maps[[i]]$sd
    location_offset[rows] <- maps[[i]]$offset
    eta_offset <- eta_offset + sign * maps[[i]]$offset[index]
    levels[[length(levels) + 1L]] <- data.frame(
      Facet = f, Level = cfg$facet_levels[[f]], Index = rows,
      Parameter = paste0("locations[", rows, "]"), Sign = sign, Centered = centered)
    row_start <- row_start + nr[i]
    col_start <- col_start + nc[i]
  }
  C <- as.integer(cfg$n_cat)
  H <- mfrm_export_basis(C - 1L)
  owner <- if (cfg$model == "RSM") rep(1L, nrow(d)) else
    match(as.character(d[[cfg$step_facet]]), cfg$facet_levels[[cfg$step_facet]])
  person <- match(as.character(d$Person), cfg$person_levels)
  y <- as.integer(d$score_k) + 1L
  if (anyNA(person) || anyNA(owner) || anyNA(y) || any(y < 1L | y > C) ||
      any(d$score_k != y - 1L)) {
    stop("Invalid retained Person, step-owner or category indices.", call. = FALSE)
  }
  out <- list(model = cfg$model,
         source_method = if (is_spec) "specification" else "MML",
         package_version = as.character(utils::packageVersion("mfrmr")),
       stan_data = list(N = nrow(d), J = length(cfg$person_levels), C = C,
                        P = ncol(X), L = nrow(B), G = length(step_specs),
                        Q = ncol(H), person = as.array(person),
                        owner = as.array(owner), y = as.array(y),
                        X = X, location_basis = B, step_basis = H,
                        location_sd = as.array(location_sd),
                        step_sd = if (C > 2L) step_prior_sd * sqrt((C - 1) / (C - 2)) else step_prior_sd),
       levels = do.call(rbind, levels), step_owners = names(step_specs),
       categories = data.frame(Category = seq_len(C),
                               InternalScore = cfg$rating_min + seq_len(C) - 1L,
                               Score = cfg$score_map$OriginalScore[match(
                                 cfg$rating_min + seq_len(C) - 1L,
                                 cfg$score_map$InternalScore)]),
       priors = list(ability = "independent normal(0, 1)",
                     location_marginal_sd = location_prior_sd,
                     step_marginal_sd = step_prior_sd),
       source_columns = cfg$source_columns,
       step_facet = cfg$step_facet,
       slope_facet = cfg$slope_facet,
       repeated_ratings = cfg$repeated_ratings)
  if (product) {
    owners <- cfg$slope_facet
    n <- lengths(cfg$gpcm_spec$component_levels)
    first <- mfrm_export_basis(n[1L])
    slope_basis <- matrix(0, sum(n), sum(n) - 1L)
    first_cols <- seq_len(n[1L] - 1L)
    second_cols <- n[1L] - 1L + seq_len(n[2L])
    slope_basis[seq_len(n[1L]), first_cols] <- first
    slope_basis[n[1L] + seq_len(n[2L]), second_cols] <- diag(n[2L])
    ids <- lapply(owners, function(f) match(as.character(d[[f]]), cfg$facet_levels[[f]]))
    if (anyNA(unlist(ids))) stop("Invalid retained slope-owner indices.", call. = FALSE)
    slope_X <- cbind(first[ids[[1L]], , drop = FALSE], diag(n[2L])[ids[[2L]], , drop = FALSE])
    out$stan_data <- c(out$stan_data, list(S = ncol(slope_basis), A = nrow(slope_basis),
      slope_basis = slope_basis, slope_X = slope_X,
      log_slope_sd = as.array(c(rep(log_slope_prior_sd * sqrt(n[1L] / (n[1L] - 1L)), n[1L] - 1L),
        rep(log_slope_prior_sd, n[2L])))))
    out$slope_levels <- data.frame(Owner = rep(owners, n),
      Level = unlist(cfg$gpcm_spec$component_levels, use.names = FALSE),
      Index = seq_len(sum(n)), Parameter = paste0("component_slopes[", seq_len(sum(n)), "]"),
      LogParameter = paste0("log_component_slopes[", seq_len(sum(n)), "]"),
      ScaleReference = rep(c("geometric_mean_one", "fixed_standard_normal"), n))
    out$priors$log_slope_marginal_sd <- log_slope_prior_sd
    if (extended_roles) {
      out$model_roles <- c(list(equation = "full_predictor_product"), roles,
        list(population = "fixed_N01", link_scale = 1,
             slope_prior_reference = roles$slope_reference))
    }
  }
  if (single) {
    f <- cfg$slope_facet
    labels <- cfg$gpcm_spec$levels
    n <- length(labels)
    sb <- mfrm_export_basis(n)
    index <- match(as.character(d[[f]]), labels)
    if (anyNA(index)) stop("Invalid retained slope-owner indices.", call. = FALSE)
    out$stan_data <- c(out$stan_data, list(S = ncol(sb), A = n,
      slope_basis = sb, slope_X = sb[index, , drop = FALSE],
      log_slope_sd = as.array(rep(log_slope_prior_sd * if (n > 1L) sqrt(n / (n - 1L)) else 1, ncol(sb)))))
    out$slope_levels <- data.frame(Owner = f, Level = labels, Index = seq_len(n),
      Parameter = paste0("component_slopes[", seq_len(n), "]"),
      LogParameter = paste0("log_component_slopes[", seq_len(n), "]"),
      ScaleReference = "geometric_mean_one")
    out$priors$log_slope_marginal_sd <- log_slope_prior_sd
  }
  if (affine) {
    sm <- lapply(step_specs, mfrm_export_affine_map, prior_sd = step_prior_sd, step = TRUE)
    counts <- vapply(sm, function(x) ncol(x$basis), integer(1))
    K <- C - 1L
    step_basis <- matrix(0, length(sm) * K, sum(counts))
    start <- 0L
    for (g in seq_along(sm)) {
      step_basis[(g - 1L) * K + seq_len(K), start + seq_len(counts[g])] <- sm[[g]]$basis
      start <- start + counts[g]
    }
    out$affine <- TRUE
    out$constraints <- list(facets = cfg$facet_specs, steps = step_specs)
    out$stan_data$Q <- NULL
    out$stan_data$T <- sum(counts)
    out$stan_data$step_basis <- step_basis
    out$stan_data$step_sd <- as.array(unlist(lapply(sm, `[[`, "sd"), use.names = FALSE))
    out$stan_data$step_offset <- as.array(unlist(lapply(sm, `[[`, "offset"), use.names = FALSE))
    out$stan_data$location_offset <- as.array(location_offset)
    out$stan_data$eta_offset <- as.array(eta_offset)
    if (is.null(out$stan_data$S)) out$stan_data <- c(out$stan_data, list(S = 0L, A = 0L,
      slope_basis = matrix(0, 0, 0), slope_X = matrix(0, nrow(d), 0), log_slope_sd = array(numeric())))
    out$levels$PriorMean <- c(rep(0, out$stan_data$J), location_offset)
    out$levels$PriorSD <- c(rep(1, out$stan_data$J), sqrt(rowSums(sweep(B, 2L, location_sd, `*`)^2)))
    out$levels$Fixed <- out$levels$PriorSD == 0
    out$step_levels <- data.frame(Owner = rep(names(step_specs), each = K), Transition = rep(seq_len(K), length(sm)),
      Parameter = unlist(lapply(seq_along(sm), function(g) paste0("steps[", g, ",", seq_len(K), "]"))),
      PriorMean = as.vector(out$stan_data$step_offset),
      PriorSD = sqrt(rowSums(sweep(step_basis, 2L, out$stan_data$step_sd, `*`)^2)))
    out$step_levels$Fixed <- out$step_levels$PriorSD == 0
    out$priors$anchor_basis <- "Conditional on fixed anchors and group means; normal free contrasts about the affine prior means."
  }
  if (free_population) {
    prior <- lapply(population_prior[c("mean", "log_sd")], as.numeric)
    person_sd <- sqrt(prior$mean[2L]^2 + exp(2 * prior$log_sd[1L] + 2 * prior$log_sd[2L]^2))
    if (!is.finite(person_sd)) stop("The marginal Person prior SD exceeds the numeric range; review population_prior.", call. = FALSE)
    out$schema_version <- 2L
    out$population <- list(mode = "estimated_normal", formula = "~1",
      parameterization = "noncentered", prior = prior,
      person_levels = as.character(cfg$person_levels),
      source_identification = pop$identification_role)
    out$stan_data$population_mean_prior <- as.array(prior$mean)
    out$stan_data$population_log_sd_prior <- as.array(prior$log_sd)
    out$priors$ability <- "normal(population_mean, population_sd); conditionally independent"
    out$priors$population <- prior
    is_person <- out$levels$Facet == "Person"
    out$levels$PriorMean[is_person] <- prior$mean[1L]
    out$levels$PriorSD[is_person] <- person_sd
  }
  out
}

# Use the native affine constraints, but symmetric priors on free contrasts.
mfrm_export_affine_map <- function(spec, prior_sd, step = FALSE) {
  if (step) {
    checked <- build_step_constraint(spec$n_steps, spec$anchors[!is.na(spec$anchors)], spec$target, spec$scope)
    if (!isTRUE(all.equal(checked, spec))) stop("Inconsistent step constraints for export.", call. = FALSE)
    offset <- expand_step_constraint(numeric(spec$n_params), spec)
    blocks <- list(spec$free_index)
    centered <- TRUE
  } else {
    checked <- build_facet_constraint(spec$levels, spec$anchors[!is.na(spec$anchors)],
      spec$groups[!is.na(spec$groups)], spec$group_values, spec$centered, spec$centering_scope %||% "remainder")
    if (!isTRUE(all.equal(checked, spec))) stop("Inconsistent facet constraints for export.", call. = FALSE)
    offset <- as.numeric(expand_facet_with_constraints(numeric(spec$n_params), spec))
    free <- which(is.na(spec$anchors))
    ids <- unique(stats::na.omit(spec$groups[free]))
    ids <- ids[nzchar(ids)]
    blocks <- lapply(ids, function(g) which(is.na(spec$anchors) & !is.na(spec$groups) & spec$groups == g))
    blocks <- c(blocks, list(free[is.na(spec$groups[free]) | !nzchar(spec$groups[free])]))
    centered <- c(rep(TRUE, length(ids)), isTRUE(spec$centered))
  }
  B <- matrix(0, length(offset), spec$n_params)
  sd <- numeric(spec$n_params)
  used <- 0L
  for (i in seq_along(blocks)) {
    rows <- blocks[[i]]
    if (!length(rows)) next
    h <- mfrm_export_basis(length(rows), centered[i])
    cols <- used + seq_len(ncol(h))
    if (centered[i]) offset[rows] <- mean(offset[rows])
    B[rows, cols] <- h
    sd[cols] <- prior_sd * if (centered[i] && length(rows) > 1L) sqrt(length(rows) / (length(rows) - 1L)) else 1
    used <- used + ncol(h)
  }
  stopifnot(used == spec$n_params, all(is.finite(offset)))
  list(offset = offset, basis = B, sd = sd)
}

mfrm_validate_export_anchor_inputs <- function(anchors, group_anchors) {
  if (!is.null(anchors)) {
    if (!is.data.frame(anchors)) {
      stop("`spec$anchors` must be NULL or a data.frame.", call. = FALSE)
    }
    if (nrow(anchors) > 0L) {
      anm <- tolower(names(anchors))
      fc <- which(anm %in% c("facet", "facets"))
      lc <- which(anm %in% c("level", "element", "label"))
      if (length(fc) > 0L && length(lc) > 0L) {
        fval <- trimws(as.character(anchors[[fc[1L]]]))
        lval <- trimws(as.character(anchors[[lc[1L]]]))
        if (anyNA(fval) || any(!nzchar(fval)) || anyNA(lval) || any(!nzchar(lval))) {
          stop("`spec$anchors` cannot contain missing or blank Facet/Level entries.",
               call. = FALSE)
        }
      }
    }
  }
  if (!is.null(group_anchors)) {
    if (!is.data.frame(group_anchors)) {
      stop("`spec$group_anchors` must be NULL or a data.frame.", call. = FALSE)
    }
    if (nrow(group_anchors) > 0L) {
      gnm <- tolower(names(group_anchors))
      fc <- which(gnm %in% c("facet", "facets"))
      lc <- which(gnm %in% c("level", "element", "label"))
      gc <- which(gnm %in% c("group", "subset"))
      if (length(fc) > 0L && length(lc) > 0L && length(gc) > 0L) {
        fval <- trimws(as.character(group_anchors[[fc[1L]]]))
        lval <- trimws(as.character(group_anchors[[lc[1L]]]))
        gval <- trimws(as.character(group_anchors[[gc[1L]]]))
        if (anyNA(fval) || any(!nzchar(fval)) || anyNA(lval) || any(!nzchar(lval)) ||
            anyNA(gval) || any(!nzchar(gval))) {
          stop("`spec$group_anchors` cannot contain missing or blank Facet/Level/Group entries.",
               call. = FALSE)
        }
      }
    }
  }
  invisible(NULL)
}

mfrm_prepare_export_spec <- function(data, spec) {
  if (!is.data.frame(data) || !nrow(data)) {
    stop("`data` must be a non-empty data.frame.", call. = FALSE)
  }
  if (!is.list(spec) || is.data.frame(spec)) {
    stop("`spec` must be a named list of model specification settings.", call. = FALSE)
  }
  nm <- names(spec)
  if (!length(spec) || is.null(nm) || anyNA(nm) || any(!nzchar(nm)) || anyDuplicated(nm)) {
    stop("`spec` must be a non-empty list with unique non-empty names.", call. = FALSE)
  }
  if ("method" %in% nm) {
    if (!is.character(spec$method) || length(spec$method) != 1L ||
        is.na(spec$method) || !identical(toupper(spec$method), "MML")) {
      stop("Model export supports MML specifications only.", call. = FALSE)
    }
  }
  if (any(vapply(c("population_formula", "person_data", "person_id", "population_sd"),
                 function(k) k %in% nm && !is.null(spec[[k]]), logical(1)))) {
    stop("Model export does not support population regression (`population_formula`, `person_data`) or custom `population_sd`.",
         call. = FALSE)
  }
  if ((("facet_interactions" %in% nm) && length(spec$facet_interactions) > 0L) ||
      (("dummy_facets" %in% nm) && length(spec$dummy_facets) > 0L) ||
      (("facet_shrinkage" %in% nm) && !identical(spec$facet_shrinkage, "none")) ||
      (("facet_prior_sd" %in% nm) && !is.null(spec$facet_prior_sd))) {
    stop("Model export does not support interactions, dummy facets or shrinkage.",
         call. = FALSE)
  }
  if ((("fit_scope" %in% nm) && !identical(spec$fit_scope, "full")) ||
      (("comparison_review" %in% nm) && !is.null(spec$comparison_review)) ||
      (("jml_correction_order" %in% nm) && !is.null(spec$jml_correction_order)) ||
      (("jml_penalty" %in% nm) && !identical(spec$jml_penalty, "none"))) {
    stop("Model export supports full ordinary RSM/PCM and one-family GPCM MML specifications only.",
         call. = FALSE)
  }
  if (!is.null(spec$slope_reference))
    stop("Direct data/spec export does not support two-family slope_reference; export a supported explicit fit instead.", call. = FALSE)
  allowed_keys <- .mfrm_fit_spec_keys()
  extra <- setdiff(nm, allowed_keys)
  if (length(extra) > 0L) {
    in_ctrl <- intersect(extra, .mfrm_fit_control_keys())
    if (length(in_ctrl) > 0L) {
      stop("`spec` in export_mfrm_model() contains estimation/numerical control entries (",
           paste(in_ctrl, collapse = ", "),
           "); omit numerical controls when exporting a model specification.",
           call. = FALSE)
    }
    stop("Unsupported or unknown entries in `spec`: ",
         paste(extra, collapse = ", "), ".", .mfrm_argument_hint(extra),
         call. = FALSE)
  }
  if ("interaction_policy" %in% nm) {
    ip <- spec$interaction_policy
    if (!is.character(ip) || length(ip) != 1L || is.na(ip) ||
        !tolower(ip) %in% c("warn", "error", "silent")) {
      stop("`spec$interaction_policy` must be 'warn', 'error', or 'silent'.", call. = FALSE)
    }
  }
  if ("population_policy" %in% nm) {
    pp <- spec$population_policy
    if (!is.character(pp) || length(pp) != 1L || is.na(pp) ||
        !tolower(pp) %in% c("error", "omit")) {
      stop("`spec$population_policy` must be 'error' or 'omit'.", call. = FALSE)
    }
  }
  if ("min_obs_per_interaction" %in% nm) {
    moi <- spec$min_obs_per_interaction
    if (!is.numeric(moi) || length(moi) != 1L || !is.finite(moi) || moi < 0) {
      stop("`spec$min_obs_per_interaction` must be a non-negative finite number.", call. = FALSE)
    }
  }
  for (thr_nm in c("min_common_anchors", "min_obs_per_element", "min_obs_per_category")) {
    if (thr_nm %in% nm && !is.null(spec[[thr_nm]])) {
      val <- spec[[thr_nm]]
      if (!is.numeric(val) || length(val) != 1L || !is.finite(val) || val < 0) {
        stop("`spec$", thr_nm, "` must be a non-negative finite number.", call. = FALSE)
      }
    }
  }

  person <- spec$person
  if (!is.character(person) || length(person) != 1L || is.na(person) || !nzchar(person)) {
    stop("`spec$person` must be a single non-empty character string naming the person column.",
         call. = FALSE)
  }
  facets <- spec$facets
  if (!is.character(facets) || !length(facets) || anyNA(facets) || any(!nzchar(facets))) {
    stop("`spec$facets` must be a character vector of one or more non-empty facet column names.",
         call. = FALSE)
  }
  score <- spec$score
  if (!is.character(score) || length(score) != 1L || is.na(score) || !nzchar(score)) {
    stop("`spec$score` must be a single non-empty character string naming the score column.",
         call. = FALSE)
  }
  weight <- spec$weight
  if (!is.null(weight) &&
      (!is.character(weight) || length(weight) != 1L || is.na(weight) || !nzchar(weight))) {
    stop("`spec$weight` must be NULL or a single non-empty character string naming the weight column.",
         call. = FALSE)
  }

  model_raw <- spec$model %||% "RSM"
  if (!is.character(model_raw) || length(model_raw) != 1L || is.na(model_raw) ||
      !toupper(model_raw) %in% c("RSM", "PCM", "GPCM")) {
    stop("`spec$model` must be 'RSM', 'PCM', or 'GPCM'.", call. = FALSE)
  }
  model <- toupper(model_raw)

  step_facet <- spec$step_facet
  if (identical(model, "RSM") && !is.null(step_facet)) {
    stop("`spec$step_facet` is not applicable when `model = 'RSM'`.", call. = FALSE)
  }
  if (!is.null(step_facet)) {
    if (!is.character(step_facet) || length(step_facet) != 1L ||
        is.na(step_facet) || !nzchar(step_facet) || !step_facet %in% facets) {
      stop("`spec$step_facet` must name one declared facet in `spec$facets`.", call. = FALSE)
    }
  } else if (identical(model, "GPCM")) {
    stop("`model = 'GPCM'` requires an explicit `step_facet` in `spec`.", call. = FALSE)
  }

  slope_facet <- spec$slope_facet
  if (!identical(model, "GPCM") && !is.null(slope_facet)) {
    stop("`spec$slope_facet` applies only when `model = 'GPCM'`.", call. = FALSE)
  }
  if (!is.null(slope_facet)) {
    if (!is.character(slope_facet) || !length(slope_facet) ||
        anyNA(slope_facet) || any(!nzchar(slope_facet))) {
      stop("`spec$slope_facet` must name one declared facet in `spec$facets`.", call. = FALSE)
    }
    if (length(slope_facet) > 1L) {
      stop("Direct `spec` export currently supports one-family GPCM (`length(slope_facet) == 1`); fit two-family GPCM explicitly with fit_mfrm() before exporting.",
           call. = FALSE)
    }
    if (!slope_facet %in% facets) {
      stop("`spec$slope_facet` must name one declared facet in `spec$facets`.", call. = FALSE)
    }
  }

  if ("gpcm_mml_identification" %in% nm && !identical(model, "GPCM")) {
    stop("`spec$gpcm_mml_identification` applies only when `model = 'GPCM'`.", call. = FALSE)
  }
  gpcm_id <- spec$gpcm_mml_identification %||% "free_population"
  if (!is.character(gpcm_id) || length(gpcm_id) != 1L || is.na(gpcm_id) ||
      !gpcm_id %in% c("free_population", "fixed_standard_normal")) {
    stop("`spec$gpcm_mml_identification` must be 'free_population' or 'fixed_standard_normal'.",
         call. = FALSE)
  }

  centering_scope <- spec$centering_scope %||% "facet"
  if (!is.character(centering_scope) || length(centering_scope) != 1L || is.na(centering_scope)) {
    stop("`spec$centering_scope` must be 'facet' or 'remainder'.", call. = FALSE)
  }
  if (identical(centering_scope, "anchor_origin")) {
    stop("`centering_scope = 'anchor_origin'` requires JML and is not supported by model export.",
         call. = FALSE)
  }
  if (!centering_scope %in% c("facet", "remainder")) {
    stop("`spec$centering_scope` must be 'facet' or 'remainder'.", call. = FALSE)
  }

  noncenter_facet <- spec$noncenter_facet %||% "Person"
  if (!is.character(noncenter_facet) || length(noncenter_facet) != 1L ||
      is.na(noncenter_facet) || !noncenter_facet %in% c("Person", facets)) {
    stop("`spec$noncenter_facet` must be 'Person' or one of `spec$facets`.", call. = FALSE)
  }
  if (identical(model, "GPCM") && identical(gpcm_id, "free_population") &&
      !identical(noncenter_facet, "Person")) {
    stop(
      "Default GPCM MML identification estimates an intercept-only ",
      "population model and therefore requires `noncenter_facet = \"Person\"`. ",
      "Use the default centering, or request ",
      "`gpcm_mml_identification = \"fixed_standard_normal\"` only when ",
      "the legacy restricted likelihood is intended.",
      call. = FALSE
    )
  }

  positive_facets <- spec$positive_facets
  if (!is.null(positive_facets)) {
    if (!is.character(positive_facets) || anyNA(positive_facets) ||
        any(!positive_facets %in% facets)) {
      stop("`spec$positive_facets` must name declared facets in `spec$facets`.",
           call. = FALSE)
    }
  }

  repeated_ratings <- spec$repeated_ratings %||% "review"
  if (!is.character(repeated_ratings) || length(repeated_ratings) != 1L ||
      is.na(repeated_ratings) || !repeated_ratings %in% c("review", "independent")) {
    stop("`spec$repeated_ratings` must be 'review' or 'independent'.", call. = FALSE)
  }

  anchor_policy_raw <- spec$anchor_policy %||% "error"
  if (!is.character(anchor_policy_raw) || length(anchor_policy_raw) != 1L ||
      is.na(anchor_policy_raw) ||
      !tolower(anchor_policy_raw) %in% c("error", "warn", "silent")) {
    stop("`spec$anchor_policy` must be 'error', 'warn', or 'silent'.", call. = FALSE)
  }
  anchor_policy <- tolower(anchor_policy_raw)

  keep_original <- resolve_mfrm_category_policy(
    spec$keep_original %||% FALSE,
    spec$category_policy,
    "keep_original" %in% nm
  )
  mfrm_validate_export_anchor_inputs(spec$anchors, spec$group_anchors)

  prior_announce_opt <- getOption("mfrmr._rating_range_announced")
  options(mfrmr._rating_range_announced = FALSE)
  on.exit(options(mfrmr._rating_range_announced = prior_announce_opt), add = TRUE)
  prior_prep_message_opt <- getOption("mfrmr._preparation_messages_announced")
  options(mfrmr._preparation_messages_announced = FALSE)
  on.exit(options(mfrmr._preparation_messages_announced = prior_prep_message_opt), add = TRUE)
  prior_score_recode_opt <- getOption("mfrmr._score_recode_announced")
  options(mfrmr._score_recode_announced = FALSE)
  on.exit(options(mfrmr._score_recode_announced = prior_score_recode_opt), add = TRUE)
  prior_duplicate_warning_opt <- getOption("mfrmr._duplicate_warning_announced")
  options(mfrmr._duplicate_warning_announced = FALSE)
  on.exit(options(mfrmr._duplicate_warning_announced = prior_duplicate_warning_opt), add = TRUE)

  gpcm_mml_active <- identical(model, "GPCM")
  auto_gpcm_population <- gpcm_mml_active && identical(gpcm_id, "free_population")
  prep <- prepare_mfrm_data(
    data = data,
    person_col = person,
    facet_cols = facets,
    score_col = score,
    rating_min = spec$rating_min,
    rating_max = spec$rating_max,
    weight_col = weight,
    keep_original = keep_original,
    missing_codes = spec$missing_codes,
    repeated_ratings = repeated_ratings,
    allow_single_person = model %in% c("RSM", "PCM") && !auto_gpcm_population
  )

  if (auto_gpcm_population) {
    auto_in <- prepare_mfrm_auto_gpcm_scaffold_inputs(data, person, spec$missing_codes)
    population <- prepare_mfrm_population_scaffold(
      data = auto_in$scaffold_data,
      person = person,
      population_formula = auto_in$population_formula,
      person_data = auto_in$person_data,
      person_id = auto_in$person_id,
      population_policy = "error"
    )
    population <- annotate_mfrm_population_scaffold(
      population = population,
      data = data,
      scaffold_data = auto_in$scaffold_data,
      gpcm_mml_active = gpcm_mml_active,
      auto_gpcm_population = TRUE
    )
  } else {
    population <- prepare_mfrm_population_scaffold(
      data = data,
      person = person,
      population_formula = NULL
    )
    population <- annotate_mfrm_population_scaffold(
      population = population,
      data = data,
      scaffold_data = data,
      gpcm_mml_active = gpcm_mml_active,
      auto_gpcm_population = FALSE
    )
  }

  anchor_bundle <- review_mfrm_prepared_anchors(
    prep = prep,
    anchors = spec$anchors,
    group_anchors = spec$group_anchors,
    min_common_anchors = spec$min_common_anchors %||% 5L,
    min_obs_per_element = spec$min_obs_per_element %||% 30,
    min_obs_per_category = spec$min_obs_per_category %||% 10,
    noncenter_facet = noncenter_facet,
    dummy_facets = NULL,
    centering_scope = centering_scope
  )
  anchor_review <- anchor_bundle$anchor_review
  enforce_mfrm_anchor_review_policy(anchor_review, anchor_policy)

  structure_bundle <- prepare_mfrm_estimation_structure(
    model = model,
    method = "MML",
    step_facet = step_facet,
    slope_facet = slope_facet,
    weight_col = weight,
    noncenter_facet = noncenter_facet,
    dummy_facets = character(0),
    positive_facets = positive_facets %||% character(0),
    anchor_df = anchor_review$anchors,
    group_anchor_df = anchor_review$group_anchors,
    population = population,
    repeated_ratings = repeated_ratings,
    centering_scope = centering_scope,
    prep = prep,
    anchor_review = anchor_review,
    constraint_specs = anchor_bundle$constraint_specs
  )
  structure_bundle$config$facet_shrinkage <- "none"
  structure(
    list(
      config = structure_bundle$config,
      prep = structure_bundle$prep,
      population = population
    ),
    class = "mfrm_export_spec"
  )
}

mfrm_format_stan_json_num <- function(x, is_int = FALSE) {
  if (!length(x)) return(character(0))
  if (is_int) return(sprintf("%d", as.integer(x)))
  x <- as.double(x)
  x[x == 0] <- 0
  sprintf("%.17g", x)
}

mfrm_stan_json_value <- function(var, name) {
  if (is.logical(var)) storage.mode(var) <- "integer"
  if (!is.numeric(var) || is.complex(var)) {
    stop("Stan JSON variable `", name, "` must be numeric.", call. = FALSE)
  }
  if (anyNA(var) || any(!is.finite(var))) {
    stop("Stan JSON variable `", name, "` must contain finite non-missing values.",
         call. = FALSE)
  }
  is_int <- is.integer(var)
  d <- dim(var)
  if (is.null(d)) {
    if (length(var) != 1L) {
      return(paste0("[", paste(mfrm_format_stan_json_num(var, is_int), collapse = ", "), "]"))
    }
    return(mfrm_format_stan_json_num(var, is_int))
  }
  if (length(d) == 1L) {
    if (d[1L] == 0L) return("[]")
    return(paste0("[", paste(mfrm_format_stan_json_num(var, is_int), collapse = ", "), "]"))
  }
  if (length(d) == 2L) {
    nr <- d[1L]
    nc <- d[2L]
    if (nr == 0L) return("[]")
    if (nc == 0L) {
      return(paste0("[\n", paste(rep("    []", nr), collapse = ",\n"), "\n  ]"))
    }
    formatted <- matrix(mfrm_format_stan_json_num(var, is_int), nrow = nr, ncol = nc)
    row_body <- if (nc == 1L) {
      formatted[, 1L]
    } else {
      do.call(paste, c(lapply(seq_len(nc), function(j) formatted[, j]), list(sep = ", ")))
    }
    rows <- paste0("    [", row_body, "]")
    return(paste0("[\n", paste(rows, collapse = ",\n"), "\n  ]"))
  }
  stop("Stan JSON variable `", name, "` exceeds supported 2D array rank.", call. = FALSE)
}

mfrm_write_stan_json <- function(data, file) {
  if (!is.list(data)) {
    stop("`data` must be a named list for Stan JSON export.", call. = FALSE)
  }
  nm <- names(data)
  if (length(data) > 0L &&
      (is.null(nm) || anyNA(nm) || any(!nzchar(nm)) || anyDuplicated(nm))) {
    stop("All Stan JSON elements must have unique non-empty names.", call. = FALSE)
  }
  if (!length(data)) {
    writeLines("{}", con = file, useBytes = TRUE)
    return(invisible(file))
  }
  entries <- vapply(seq_along(data), function(i) {
    key <- gsub("([\\\"\\\\])", "\\\\\\1", nm[i])
    paste0("  \"", key, "\": ", mfrm_stan_json_value(data[[i]], nm[i]))
  }, character(1))
  lines <- paste0("{\n", paste(entries, collapse = ",\n"), "\n}")
  writeLines(enc2utf8(lines), con = file, useBytes = TRUE)
  invisible(file)
}
