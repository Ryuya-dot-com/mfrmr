# Experimental native locations use the entire marginal information inverse.
# Keep their qualification separate from both ordinary and two-family inference.
mfrm_native_location_identity <- function(fit) {
  list(source = mfrm_gpcm_inference_source(fit),
    constraints = fit$config[c("facet_specs", "step_specs", "gpcm_spec", "facet_signs")],
    engine = fit$config$estimation_control$mml_engine_used,
    population = fit$population[c("active", "coefficients", "sigma2")],
    locations = fit$facets$others[c("Facet", "Level", "Estimate")],
    steps = fit$steps, slopes = fit$slopes,
    readiness = mfrmr_get_readiness_record(fit),
    optimizer = fit$opt$optimizer_diagnostics)
}

mfrm_native_location_source <- function(fit) {
  cfg <- fit$config
  pop <- cfg$population_spec
  active <- isTRUE(pop$active)
  gpcm <- identical(cfg$model, "GPCM")
  if (!inherits(fit, "mfrm_fit") || inherits(fit, "mfrm_imported_fit") ||
      !identical(cfg$method, "MML") || !cfg$model %in% c("RSM", "PCM", "GPCM") ||
      (!active && !gpcm) || mfrm_has_product_slopes(fit) ||
      !identical(cfg$estimation_control$mml_engine_used, "direct") ||
      !length(fit$prep$data$Weight) || any(!is.finite(fit$prep$data$Weight)) ||
      any(fit$prep$data$Weight != 1) || length(cfg$interaction_specs)) {
    stop("Native location intervals require direct MML, unit weights, no interactions, and an estimated intercept-only normal population or one-family GPCM.", call. = FALSE)
  }
  for (facet in cfg$facet_names) {
    expected <- build_facet_constraint(fit$prep$levels[[facet]])
    if (!identical(as.character(cfg$facet_levels[[facet]]), expected$levels) ||
        !isTRUE(all.equal(cfg$facet_specs[[facet]], expected))) {
      stop("Native locations require matching level coding and sum-to-zero facet constraints without anchors or groups.", call. = FALSE)
    }
  }
  step_levels <- if (identical(cfg$model, "RSM")) "shared" else
    as.character(fit$prep$levels[[cfg$step_facet]])
  steps <- setNames(lapply(step_levels, function(owner)
    build_step_constraint(cfg$n_cat - 1L, scope = owner)), step_levels)
  if (!length(steps) || !isTRUE(all.equal(cfg$step_specs, steps))) {
    stop("Native location intervals require unanchored, centered step ladders.", call. = FALSE)
  }
  design <- mfrm_population_design(fit)
  if (is.null(design) || (active &&
      (!identical(design$columns, "(Intercept)") || any(design$design != 1))) ||
      !identical(cfg$posterior_basis, if (active) "population_model" else "legacy_mml") ||
      (!active && (isTRUE(fit$population$active) ||
        !identical(cfg$gpcm_mml_identification, "fixed_standard_normal")))) {
    stop("Population coding must describe the fitted intercept-only normal population or fixed N(0,1).", call. = FALSE)
  }
  q <- cfg$estimation_control$quad_points
  # Fits saved before adaptive integration was introduced use the fixed grid.
  # Match mfrmr_adaptive_integration() without rewriting the retained fit.
  integration <- cfg$estimation_control$mml_integration %||% "fixed"
  if (!is.numeric(q) || is.complex(q) || length(q) != 1L || !is.finite(q) || q < 1 || q != floor(q) ||
      length(integration) != 1L || !integration %in% c("fixed", "adaptive")) {
    stop("Saved integration metadata must specify fixed or adaptive integration and a positive integer quadrature order.", call. = FALSE)
  }
  sizes <- build_param_sizes(cfg)
  if (length(fit$opt$par) != sum(unlist(sizes)) || any(!is.finite(fit$opt$par))) {
    stop("Retained parameters must be finite and match every free coordinate.", call. = FALSE)
  }
  params <- expand_params(fit$opt$par, sizes, cfg)
  tables <- list(locations = build_other_facet_table(cfg, fit$prep, params),
    steps = build_step_table(cfg, fit$prep, params))
  saved <- list(locations = fit$facets$others, steps = fit$steps)
  if (gpcm) {
    spec <- cfg$gpcm_spec
    if (!isTRUE(spec$active) || length(cfg$slope_facet) != 1L ||
        !cfg$slope_facet %in% cfg$facet_names || !cfg$step_facet %in% cfg$facet_names ||
        !identical(spec$identification, "sum_to_zero_log_slopes") ||
        !identical(spec$scale_reference, "geometric_mean_one") || length(spec$levels) < 2L ||
        !identical(spec$slope_facet, cfg$slope_facet) ||
        !identical(spec$step_facet, cfg$step_facet) ||
        !identical(as.character(spec$levels), as.character(cfg$facet_levels[[cfg$slope_facet]]))) {
      stop("Slope owners, levels and geometric-mean-one coordinates must match the fitted GPCM.", call. = FALSE)
    }
    tables$slopes <- build_slope_table(cfg, fit$prep, params)
    saved$slopes <- fit$slopes
  }
  for (name in names(tables)) {
    keys <- names(tables[[name]])
    if (!all(keys %in% names(saved[[name]])) ||
        !isTRUE(all.equal(saved[[name]][keys], tables[[name]],
          tolerance = 1e-10, check.attributes = FALSE))) {
      stop("Saved ", name, " must match the retained parameters and level coding.", call. = FALSE)
    }
  }
  if (active && (!isTRUE(fit$population$active) ||
      !identical(fit$population$design_columns, pop$design_columns) ||
      !isTRUE(all.equal(fit$population$design_matrix, pop$design_matrix)) ||
      !isTRUE(all.equal(pop$coefficients, params$population$coefficients, tolerance = 1e-10)) ||
      !isTRUE(all.equal(pop$sigma2, params$population$sigma2, tolerance = 1e-10)) ||
      !isTRUE(all.equal(fit$population$coefficients, params$population$coefficients, tolerance = 1e-10)) ||
      !isTRUE(all.equal(fit$population$sigma2, params$population$sigma2, tolerance = 1e-10)))) {
    stop("Saved population estimates must match the retained parameters.", call. = FALSE)
  }
  params
}

mfrm_native_location_inference <- function(fit) {
  out <- list(covariance = NULL, information = NULL,
    checks = data.frame(Check = character(), Passed = logical(), Detail = character()),
    check = list(eligible = FALSE, review = "Native location inference was not evaluated."))
  record <- function(name, passed, detail) {
    out$checks <<- rbind(out$checks, data.frame(Check = name, Passed = isTRUE(passed), Detail = detail))
    isTRUE(passed)
  }
  refuse <- function() {
    out$check$review <- paste(out$checks$Detail[!out$checks$Passed], collapse = " ")
    out
  }
  cfg <- fit$config
  readiness <- mfrmr_get_readiness_record(fit)$fit
  slope_boundary <- cfg$boundary_audit$gpcm_slope_boundary
  if (!record("Identification and boundary",
      !identical(as.character(readiness$EstimabilityState[1]), "structurally_unidentified") &&
      !isTRUE(cfg$estimability_audit$nonlinear_local_estimability$local_first_order_rank_deficient) &&
      as.character(readiness$BoundaryState[1]) %in% c("finite", "not_applicable", "not_evaluated") &&
      !any(slope_boundary$certificates$Certified %in% TRUE) &&
      !identical(slope_boundary$state, "certified_monotone_boundary_path"),
      "A recorded identification failure or boundary certificate prevents native location intervals.")) return(refuse())
  category <- audit_mfrm_category_support(fit$prep, cfg, build_param_sizes(cfg))
  if (!record("Category support", identical(category$readiness$CategoryState, "adequate"),
      "Fresh category support must be adequate for native location intervals.")) return(refuse())
  info <- compute_mml_parameter_covariance(fit)
  out$information <- info
  valid <- function(x) identical(x$status, "ok") && !isTRUE(x$regularized) &&
    is.matrix(x$cov) && is.matrix(x$hessian) && all(is.finite(x$cov)) &&
    all(is.finite(x$hessian)) &&
    !is.null(tryCatch(chol(x$hessian), error = function(e) NULL)) &&
    !is.null(tryCatch(chol(x$cov), error = function(e) NULL))
  if (!record("Joint information", valid(info),
      paste("Finite positive unregularized full information is required.", info$detail))) return(refuse())
  local <- if (identical(cfg$model, "GPCM")) mfrm_gpcm_slope_inference_check(fit, info) else
    mfrm_ic_fit_check(fit, mfrm_extract_fit_ic_contract(fit), information = info$solution_information)
  if (!record("Local solution", local$eligible, local$review)) return(refuse())
  p <- length(fit$opt$par)
  q <- cfg$estimation_control$quad_points
  g <- info$solution_information$gradient
  if (!record("Full gradient", length(g) == p && all(is.finite(g)),
      "The full marginal gradient must be finite and dimensionally consistent.")) return(refuse())
  scaled <- sqrt(max(0, drop(crossprod(g, info$cov %*% g))))
  residual <- norm(info$hessian %*% info$cov - diag(p), "I")
  out$numerical_checks <- data.frame(QuadraturePoints = q, ComparisonPoints = 2 * q - 1,
    Integration = if (mfrmr_adaptive_integration(cfg)) "adaptive" else "fixed",
    FreeParameters = p, CurvatureScaledGradient = scaled, InverseResidual = residual,
    ComparisonInverseResidual = NA_real_, QuadratureScoreShift = NA_real_,
    QuadratureCovarianceChange = NA_real_, OptimizationCaution = scaled > 1e-4)
  if (!record("Stationarity and inverse", is.finite(scaled) && scaled <= .01 &&
      is.finite(residual) && residual <= 1e-6,
      "Curvature-scaled gradient must be at most .01 and inverse residual at most 1e-6.")) return(refuse())
  view <- fit
  view$config$estimation_control$quad_points <- 2 * q - 1
  # The coarse Hessian and covariance remain live during the finer evaluation.
  fine <- tryCatch(compute_mml_parameter_covariance(view, retained_matrices = 2L),
    error = function(e) list(status = "unavailable", detail = conditionMessage(e)))
  out$comparison_information_review <- fine$solution_information$inverse_review
  gp <- fine$solution_information$gradient
  ev <- fine$solution_information$evaluation_summary
  if (!record("Comparison information", valid(fine) && length(gp) == p &&
      all(is.finite(gp)) && isTRUE(is.finite(ev$ReevaluatedObjective)),
      paste("Finer-grid full information and gradient must be finite and unregularized.", fine$detail))) return(refuse())
  fine_residual <- norm(fine$hessian %*% fine$cov - diag(p), "I")
  shift <- sqrt(max(0, drop(crossprod(gp - g, info$cov %*% (gp - g)))))
  root <- chol(info$hessian)
  change <- norm(root %*% (fine$cov - info$cov) %*% t(root), "2")
  out$numerical_checks$ComparisonInverseResidual <- fine_residual
  out$numerical_checks$QuadratureScoreShift <- shift
  out$numerical_checks$QuadratureCovarianceChange <- change
  if (!record("Quadrature comparison", all(is.finite(c(fine_residual, shift, change))) &&
      fine_residual <= 1e-6 && shift <= .01 && change <= .01,
      "Finer-grid inverse residual must be at most 1e-6; standardized score displacement and full covariance change must each be at most .01.")) return(refuse())
  out$covariance <- info$cov
  out$check <- list(eligible = TRUE,
    review = "Experimental native-scale pointwise normal intervals from full joint MML information; numerical checks passed, sampling coverage is unqualified.",
    caution = c(local$caution, if (scaled > 1e-4)
      "Residual optimization error exceeds 1e-4 local standard errors; inspect the saved numerical checks."))
  out
}
