#' Export a measurement model to Stan or brms
#'
#' Write a self-contained Bayesian model bundle without running an estimator.
#' Supports ordinary RSM/PCM MML fits in both formats and two-slope-family
#' GPCM MML fits in Stan. Sources must be unanchored and unit-weight, with
#' a fixed standard-normal Person population and no facet interactions or
#' post-fit shrinkage. Unsupported specifications fail before files are written.
#'
#' @param fit A native RSM/PCM or two-family GPCM MML `mfrm_fit` returned by
#'   [fit_mfrm()].
#' @param output_dir Destination directory. The bundle includes observed ratings
#'   and original level labels; review it before sharing.
#' @param format Either `"stan"` (CmdStanR) or `"brms"` (custom family).
#' @param location_prior_sd Positive marginal prior SD for each facet location.
#' @param step_prior_sd Positive marginal prior SD for each step offset.
#' @param overwrite Replace bundle files that already exist? Defaults to `FALSE`.
#' @param acknowledge_sensitive Suppress the reminder that ratings and original
#'   identifiers are included. Defaults to `FALSE`.
#' @param log_slope_prior_sd Positive marginal prior SD of each component log
#'   slope for two-family GPCM Stan export. Defaults to 1; inspect prior
#'   sensitivity. Not used by RSM/PCM models.
#'
#' @details
#' Both formats retain the category ladder, facet signs, facet centering and
#' RSM/PCM step ownership of the source specification. RSM/PCM adjacent-category log odds
#' are `theta + signed facet locations - step`. Steps sum to zero within their
#' owner and are **not ordered**. A binary ladder has its single offset fixed at
#' zero. Ability parameters have independent standard-normal priors; realized
#' abilities are not centered across the observed Persons.
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
#' One-family GPCM export remains unsupported.
#'
#' `model-data.rds` records the design matrices, priors and mappings used by both
#' formats. `levels.csv` maps original labels to generated parameters;
#' `categories.csv` maps Stan/brms categories to the source score scale.
#' `run.R` fits the exported model and saves draws, diagnostics and replicated
#' ratings. Run it from the bundle directory, after installing CmdStanR/CmdStan
#' and, for the brms format, brms. Neither is required to export a bundle.
#' For Stan bundles, `Rscript run.R --summarize` regenerates reports from
#' `fit.rds` without compiling or sampling. `parameter-summary.csv` contains
#' equal-tailed 95% posterior bounds, endpoint Monte Carlo SEs (MCSEs), R-hat
#' and bulk/tail effective sample sizes for reported parameters and free
#' coordinates. `sampler-diagnostics.csv` records chain diagnostics;
#' `posterior-summary.rds` retains both tables and interpretation notes.
#' Bounds remain visible when diagnostics warn. `interval_computed` indicates
#' finite endpoints, not reliable sampling or calibrated coverage. The maximum
#' endpoint MCSE divided by interval width measures simulation precision;
#' no universal acceptable fraction or automatic qualification is assigned.
#' Inspect all coordinates and chains, prior sensitivity and model fit.
#' Constant draws have unavailable MCSE/R-hat diagnostics: verify whether the
#' model fixes that component or sampling is stuck.
#' Generated brms callbacks support `log_lik()`, `posterior_predict()` and
#' `posterior_epred()`; the last returns category probabilities.
#'
#' Log likelihood and replicated ratings condition on the sampled abilities of
#' existing Persons. They do not provide leave-one-Person-out validation or
#' predictions for new Persons. Exporting does not qualify the original fit's
#' convergence, inference, or an external sampler's diagnostics. Repeated ratings
#' retain the source conditional-independence assumption.
#'
#' @return Invisibly, a list with `format`, `model`, `output_dir` and named
#'   `files`. No model is fitted and no software is installed.
#' @seealso [export_mfrm_results()], [fit_mfrm()]
#' @references
#' Uto, M., & Ueno, M. (2020). A generalized many-facet Rasch model and its
#' Bayesian estimation using Hamiltonian Monte Carlo. *Behaviormetrika, 47*,
#' 469-496. \doi{10.1007/s41237-020-00115-7}. Equation 9, Sections 6-7 and Appendix.
#' @examples
#' ratings <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
#'                  model = "RSM", method = "MML")
#' # Export runs without Stan or brms. The example data are synthetic.
#' stan <- export_mfrm_model(fit, tempfile("mfrmr-stan-"), "stan",
#'                            acknowledge_sensitive = TRUE)
#' brms <- export_mfrm_model(fit, tempfile("mfrmr-brms-"), "brms",
#'                            acknowledge_sensitive = TRUE)
#' names(stan$files)
#' bundle <- readRDS(stan$files[["model-data.rds"]])
#' bundle$categories # Generated categories mapped to original scores
#' bundle$priors
#' # Run each bundle's run.R separately if external sampling is wanted.
#' unlink(c(stan$output_dir, brms$output_dir), recursive = TRUE)
#' @export
export_mfrm_model <- function(fit, output_dir, format = c("stan", "brms"),
                              location_prior_sd = 1, step_prior_sd = 1,
                              overwrite = FALSE, acknowledge_sensitive = FALSE,
                              log_slope_prior_sd = 1) {
  format <- match.arg(format)
  for (x in c("overwrite", "acknowledge_sensitive")) {
    value <- get(x)
    if (!is.logical(value) || length(value) != 1L || is.na(value)) {
      stop("`", x, "` must be TRUE or FALSE.", call. = FALSE)
    }
  }
  if (!is.character(output_dir) || length(output_dir) != 1L ||
      is.na(output_dir) || !nzchar(output_dir)) {
    stop("`output_dir` must be one nonempty path.", call. = FALSE)
  }
  product <- mfrm_has_product_slopes(fit) && identical(fit$config$model, "GPCM")
  if (product && format != "stan") stop(
    "Two-family GPCM model export supports format = 'stan' only.", call. = FALSE)
  bundle <- mfrm_model_export_data(fit, location_prior_sd, step_prior_sd, log_slope_prior_sd)
  template_dir <- system.file("model-export", package = "mfrmr")
  model_file <- if (format == "stan") "model.stan" else "model.R"
  templates <- c(if (product) "model-gmfrm.stan" else model_file,
                 paste0("run-", format, ".R"), if (product) "README-gmfrm.txt" else "README.txt")
  source_files <- file.path(template_dir, templates)
  if (!all(file.exists(source_files))) {
    stop("Model export templates are missing from this installation.", call. = FALSE)
  }
  filenames <- c("model-data.rds", "levels.csv", "categories.csv",
                 model_file, "run.R", "README.txt", if (product) "slope-levels.csv")
  files <- stats::setNames(file.path(output_dir, filenames), filenames)
  if (any(dir.exists(files)) || (!overwrite && any(file.exists(files)))) {
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
  utils::write.csv(bundle$levels, files[["levels.csv"]], row.names = FALSE,
                   fileEncoding = "UTF-8")
  utils::write.csv(bundle$categories, files[["categories.csv"]], row.names = FALSE)
  if (product) utils::write.csv(bundle$slope_levels, files[["slope-levels.csv"]],
    row.names = FALSE, fileEncoding = "UTF-8")
  if (!all(file.copy(source_files, files[c(4, 5, 6)], overwrite = overwrite))) {
    stop("Could not copy all model export templates.", call. = FALSE)
  }
  invisible(list(format = format, model = bundle$model,
                 output_dir = normalizePath(output_dir), files = files))
}

mfrm_export_basis <- function(n, centered = TRUE) {
  if (!centered) return(diag(n))
  if (n == 1L) return(matrix(numeric(), 1L, 0L))
  h <- stats::contr.helmert(n)
  sweep(h, 2L, sqrt(colSums(h^2)), "/")
}

mfrm_model_export_data <- function(fit, location_prior_sd, step_prior_sd,
                                   log_slope_prior_sd = 1) {
  if (!inherits(fit, "mfrm_fit") ||
      inherits(fit, c("mfrm_testlet", "mfrm_random_rater"))) {
    stop("`fit` must be an ordinary mfrm_fit.", call. = FALSE)
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
  if ((!cfg$model %in% c("RSM", "PCM") && !product) || !identical(cfg$method, "MML") ||
      inherits(fit, "mfrm_imported_fit")) {
    stop("Model export supports native ordinary RSM/PCM or two-family GPCM MML specifications only.",
         call. = FALSE)
  }
  if (product) {
    mfrm_gpcm_slope_roles(cfg)
    if (any(lengths(cfg$gpcm_spec$component_levels) < 2L) ||
        !identical(cfg$gpcm_spec$component_levels, cfg$facet_levels[cfg$slope_facet]) ||
        !identical(cfg$step_facet, cfg$slope_facet[2L])) stop(
      "Two-family slope levels or step ownership disagree with the fitted specification.", call. = FALSE)
  }
  if (isTRUE(cfg$population_spec$active) ||
      length(cfg$interaction_specs) || length(cfg$dummy_facets) ||
      !identical(cfg$facet_shrinkage %||% "none", "none")) {
    stop("Model export does not support population regression, interactions, dummy facets or shrinkage.",
         call. = FALSE)
  }
  specs <- c(list(cfg$theta_spec), cfg$facet_specs)
  anchored <- vapply(specs, function(s) {
    any(!is.na(s$anchors)) || any(!is.na(s$groups) & nzchar(s$groups))
  }, logical(1))
  step_specs <- mfrmr_step_specs(cfg)
  if (any(anchored) || any(vapply(step_specs, function(s) {
    any(!is.na(s$anchors)) || !isTRUE(s$target == 0)
  }, logical(1)))) {
    stop("Model export does not support fixed or group anchors.", call. = FALSE)
  }
  d <- fit$prep$data
  if (!is.data.frame(d) || !nrow(d) || anyNA(d$Weight) ||
      any(d$Weight != 1)) {
    stop("Model export requires retained observations with unit weights.", call. = FALSE)
  }
  facets <- cfg$facet_names
  basis <- lapply(facets, function(f) {
    s <- cfg$facet_specs[[f]]
    if (!identical(as.character(s$levels), as.character(cfg$facet_levels[[f]]))) {
      stop("Facet levels and constraints disagree.", call. = FALSE)
    }
    mfrm_export_basis(length(s$levels), isTRUE(s$centered))
  })
  nr <- vapply(basis, nrow, integer(1))
  nc <- vapply(basis, ncol, integer(1))
  B <- matrix(0, sum(nr), sum(nc))
  X <- matrix(0, nrow(d), sum(nc))
  location_sd <- numeric(sum(nc))
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
    location_sd[cols] <- location_prior_sd *
      if (centered && nr[i] > 1L) sqrt(nr[i] / (nr[i] - 1L)) else 1
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
  out <- list(model = cfg$model, source_method = "MML", package_version =
         as.character(utils::packageVersion("mfrmr")),
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
  }
  out
}
