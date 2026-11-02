# Join completed stages without refitting. The caller binds their data, model,
# source and integration provenance; this is not a cache for unrelated fits.
mfrm_gmfrm_candidate <- function(search, natural, finish = NULL,
                                 chart = NULL, reference = NULL) {
  z <- search$selected$parameters; p <- length(z); fixed <- search$fixed
  valid <- function(x, n) is.numeric(x) && !is.complex(x) && length(x) == n && all(is.finite(x))
  if (!p || !valid(z, p) || length(natural$lower) != p || anyNA(natural$lower) ||
      any(z < natural$lower) || !valid(fixed, length(fixed)) ||
      any(fixed != trunc(fixed) | fixed < 1 | fixed > p) || anyDuplicated(fixed) ||
      !identical(search$free, setdiff(seq_len(p), fixed)))
    stop("Invalid saved search or natural-coordinate bounds.")
  boundary <- which(z == natural$lower)
  out <- list(search = search, stages = list(finish = finish, chart = chart, reference = reference),
    selected = search$selected, native_parameters = NULL, fixed = fixed, boundary = boundary,
    information = NULL, information_scope = "unavailable", status = "finish_required",
    global_optimality = "not assessed", interval_qualification = "not assessed")
  if (length(boundary)) {
    # Even a good active-face audit does not supply a native interior covariance.
    out$status <- "boundary_review_required"
    return(out)
  }
  if (is.null(finish)) return(out)
  out$status <- finish$status
  if (!identical(finish$status, "interior_numerical_candidate")) return(out)
  same_point <- function(x, y) valid(x, p) && valid(y, p) && max(abs(x-y)) <= 1e-12
  if (!identical(finish$fixed, fixed) || !identical(finish$free, search$free) ||
      !same_point(natural$from_native(finish$initial$parameters), z) ||
      !valid(finish$initial$evaluation$value, 1L) ||
      !valid(search$selected$evaluation$value, 1L) ||
      abs(finish$initial$evaluation$value-search$selected$evaluation$value) > 1e-7 ||
      !identical(finish$selected$parameters[fixed], finish$initial$parameters[fixed]))
    stop("Finish does not match the saved endpoint and original constraint.")
  # Only unchanged coordinates may be passed as fixed indices in both charts.
  for (j in fixed) {
    C <- replace(numeric(p), j, 1); target <- natural$target(z, C)
    if (!isTRUE(all.equal(target$gradient, C, tolerance = 1e-12)) ||
        abs(target$value-z[j]) > 1e-12)
      stop("The fixed coordinate requires a transformed constraint, not a native index.")
  }
  passes <- function(checks, limits) is.numeric(checks) && !is.complex(checks) &&
    identical(names(checks), names(limits)) && all(is.finite(checks)) &&
    all(checks >= 0 & checks <= limits)
  if (!passes(finish$checks, c(RawScore=1e-4, MeanScore=1e-6, FixedError=0,
      StandardizedScore=1e-4, InverseResidual=1e-6, CovarianceChange=.01, IntegrationDiagnostic=1e-5))) {
    out$status <- "precision_unresolved"
    return(out)
  }
  info <- finish$information; free <- finish$free; dimension <- length(free)
  if (is.null(info) || !identical(info$parameters, finish$selected$parameters) ||
      !identical(info$free, free) || !identical(info$regularized, FALSE) ||
      !is.matrix(info$hessian) || !is.matrix(info$covariance) ||
      !identical(dim(info$hessian), c(dimension, dimension)) ||
      !identical(dim(info$covariance), c(dimension, dimension)) ||
      any(!is.finite(c(info$hessian, info$covariance))) ||
      !isSymmetric(info$hessian) || !isSymmetric(info$covariance) ||
      is.null(tryCatch(chol(info$hessian), error=function(e) NULL)) ||
      norm(info$hessian %*% info$covariance-diag(dimension), "I") > 1e-6)
    stop("Information must belong to the current point and full free-coordinate constraint.")
  out$status <- "chart_unresolved"
  if (is.null(chart) || !isTRUE(chart$passed) ||
      !passes(chart$checks, c(NLL=1e-7, Gradient=1e-6, RawNatural=1e-4,
        Target=0, Roundtrip=1e-12, IntegrationDiagnostic=1e-5))) return(out)
  if (!same_point(chart$parameters, natural$from_native(info$parameters)) ||
      !identical(chart$parameters[fixed], z[fixed]))
    stop("Natural-chart check belongs to a different point or original constraint.")
  out$status <- "reference_unresolved"
  if (is.null(reference) || !isTRUE(reference$passed) || !isTRUE(reference$reference$qualified) ||
      !passes(reference$checks, c(NLLNative=1e-7, NLLNatural=1e-7,
        GradientNative=1e-6, GradientNatural=1e-6, RawNative=1e-4, MeanNative=1e-6,
        StandardizedNative=1e-4, RawNatural=1e-4, NaturalRule=1e-6,
        NaturalTail=1e-7, IntegrationDiagnostic=1e-5, Target=0))) return(out)
  if (!valid(reference$reference$nll, 1L) ||
      !valid(finish$selected$evaluation$value, 1L) || !valid(chart$evaluation$value, 1L) ||
      !valid(finish$selected$evaluation$gradient, p) || !valid(chart$evaluation$gradient, p) ||
      abs(reference$reference$nll-finish$selected$evaluation$value) > 1e-7 ||
      abs(reference$reference$nll-chart$evaluation$value) > 1e-7 ||
      !valid(reference$native_gradient, p) || !valid(reference$natural_gradient, p) ||
      max(abs(reference$native_gradient-finish$selected$evaluation$gradient)) > 1e-6 ||
      max(abs(reference$natural_gradient-chart$evaluation$gradient)) > 1e-6)
    stop("Reference check does not match the selected likelihood and full gradients.")
  out$selected <- list(parameters = chart$parameters, evaluation = chart$evaluation)
  out$native_parameters <- info$parameters
  out$information <- info
  out$information_scope <- if (length(fixed)) "conditional_nuisance" else "joint_unrestricted"
  out$status <- "reference_qualified_local_candidate"
  out
}

# A finite native target and a local variance are distinct from an interval.
mfrm_gmfrm_candidate_target <- function(candidate, natural, C) {
  z <- candidate$selected$parameters
  if (!is.numeric(C) || is.complex(C) || length(C) != length(z) || any(!is.finite(C)))
    stop("Supply a finite real native target vector.")
  target <- tryCatch(natural$target(z, C), error=function(e) {
    if (!identical(conditionMessage(e), "This native target is not supported at this boundary.")) stop(e)
    NULL
  })
  out <- list(defined = !is.null(target), value = if (is.null(target)) NA_real_ else target$value,
    local_variance = NA_real_, variance_scope = "unavailable",
    detail = "A defined target does not establish identification or interval eligibility.")
  if (!is.null(target) && !is.finite(out$value)) stop("Nonfinite native target.")
  if (is.null(target)) {
    out$detail <- "The native target is not defined on this zero-slope boundary."
  } else if (identical(candidate$information_scope, "conditional_nuisance")) {
    out$detail <- "Constrained nuisance information does not supply an unrestricted target variance."
  } else if (identical(candidate$status, "reference_qualified_local_candidate") &&
             identical(candidate$information_scope, "joint_unrestricted")) {
    info <- candidate$information
    if (!identical(info$parameters, candidate$native_parameters) ||
        max(abs(natural$from_native(info$parameters)-z)) > 1e-12 ||
        !identical(info$free, seq_along(C))) stop("Target information no longer matches the candidate.")
    out$local_variance <- drop(crossprod(C, info$covariance %*% C))
    if (!is.finite(out$local_variance) || out$local_variance < 0) stop("Invalid local target variance.")
    out$variance_scope <- "local_model_based"
    out$detail <- "Full joint observed-information variance; sampling coverage and interval eligibility are not qualified."
  }
  out
}
