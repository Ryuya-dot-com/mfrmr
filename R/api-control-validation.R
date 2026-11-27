# Validate before coercion so recorded controls are the controls actually used.
.mfrm_validate_numerics <- function(quad_points, maxit, reltol, slope_prior_sd = NULL,
                                  facet_prior_sd = NULL) {
  scalar <- function(x) is.numeric(x) && !is.complex(x) && is.null(dim(x)) && length(x) == 1L && is.finite(x)
  for (nm in c("quad_points", "maxit")) {
    x <- get(nm)
    lower <- if (nm == "quad_points") 5L else 1L
    if (!scalar(x) || x < lower || x > .Machine$integer.max || x != floor(x))
      stop("`", nm, "` must be a finite integer of at least ", lower, ".", call. = FALSE)
  }
  if (!scalar(reltol) || reltol <= 0)
    stop("`reltol` must be finite and positive.", call. = FALSE)
  for (nm in c("slope_prior_sd", "facet_prior_sd")) {
    x <- get(nm)
    if (!is.null(x) && (!scalar(x) || x <= 0))
      stop("`", nm, "` must be NULL or a finite positive scalar.", call. = FALSE)
  }
  invisible(NULL)
}

.mfrm_validate_interval_level <- function(level) {
  if (!is.numeric(level) || is.complex(level) || !is.null(dim(level)) || length(level) != 1L || !is.finite(level) || level <= 0 || level >= 1)
    stop("`level` must be a finite number strictly between zero and one.", call. = FALSE)
}

.mfrm_validate_rating_bound <- function(value, name) {
  if (!is.numeric(value) || is.complex(value) || !is.null(dim(value)) ||
      length(value) != 1L || !is.finite(value) || value != round(value)) {
    stop("`", name, "` must be one finite integer rubric score.", call. = FALSE)
  }
  as.double(value)
}

.mfrm_validate_count <- function(value, name, lower = 1L) {
  if (!is.numeric(value) || is.complex(value) || !is.null(dim(value)) ||
      length(value) != 1L || !is.finite(value) || value != floor(value) ||
      value < lower || value > .Machine$integer.max) {
    stop("`", name, "` must be a finite integer of at least ", lower, ".", call. = FALSE)
  }
  as.integer(value)
}

.mfrm_extract_weights <- function(data, weight = NULL) {
  if (is.null(weight)) return(rep(1.0, nrow(data)))
  w <- data[[weight]]
  if (is.factor(w) || is.object(w) || is.complex(w) || !is.null(dim(w)) ||
      (!is.numeric(w) && !all(is.na(w)))) {
    stop("The weight column must contain plain numeric observation weights; factor or character weights are not coerced.", call. = FALSE)
  }
  as.double(w)
}

.mfrm_validate_estimation_options <- function(model, method, integration, shrinkage, slope_prior_sd) {
  if (integration != "fixed" && method != "MML")
    stop("Automatic or adaptive quadrature applies only to MML.", call. = FALSE)
  if (method == "CML" && shrinkage == "laplace")
    stop("CML does not support Laplace facet regularization.", call. = FALSE)
  if (model != "GPCM" && !is.null(slope_prior_sd))
    stop("`slope_prior_sd` requires a GMFRM with estimated slopes.", call. = FALSE)
}

.mfrm_rating_rows <- function(data, person, facets, score, weight = NULL) {
  if (is.factor(data[[score]])) {
    stop("The score column must contain numeric rating values. Convert factor labels to numeric scores before calibration.", call. = FALSE)
  }
  weights <- .mfrm_extract_weights(data, weight)
  is.finite(as.numeric(data[[score]])) & is.finite(weights) & weights > 0 &
    stats::complete.cases(data[c(person, facets)])
}
