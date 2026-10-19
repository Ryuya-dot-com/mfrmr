# Research-only fixed-correlation likelihood slices. This is not an estimated
# correlation procedure, an uncertainty method, or a public fitting adapter.
# Source mfrm-dimensionality-tam-design-20261006.R before constructing maps.
wide_dim_tam_fixed_profile_v3 <- function(response, map, rho = NULL,
                                          nodes = 41L, span = 6, start = NULL, conv = 1e-9) {
  stopifnot(is.matrix(response), ncol(response) == 18L,
    identical(colnames(response), rownames(map$Q)),
    all(is.na(response) | response %in% 0:3),
    length(nodes) == 1L, nodes %in% c(15L, 21L, 31L, 41L, 61L, 81L, 121L),
    length(span) == 1L, span %in% c(6, 8, 10),
    length(conv) == 1L, is.finite(conv), conv > 0, conv <= 1e-7,
    is.null(start) || (is.numeric(start) && length(start) == dim(map$A)[3] && all(is.finite(start))))
  if (!any(response == 3L, na.rm = TRUE)) {
    return(list(status = 'unsupported_category_support',
      reason = 'TAM derives its global category count from observed scores; the declared 0:3 support cannot be passed unchanged.',
      fit = NULL))
  }
  if (map$dimensions == 1L) {
    stopifnot(is.null(rho))
    loading <- matrix(1, 1L, 1L)
  } else {
    stopifnot(length(rho) == 1L, is.finite(rho), abs(rho) <= 1)
    # theta = loading %*% z, z ~ N(0, I). The singular endpoints are exact
    # one-dimensional distributions; no eigenvalue clipping is involved.
    loading <- if (abs(rho) == 1) matrix(c(1, rho), 2L, 1L) else
      matrix(c(1, rho, 0, sqrt((1 - rho) * (1 + rho))), 2L, 2L)
  }
  d <- ncol(loading)
  B <- array(0, c(18L, 4L, d),
    dimnames = list(dimnames(map$B)[[1]], dimnames(map$B)[[2]], paste0('Z', seq_len(d))))
  for (k in seq_len(d)) for (j in seq_len(map$dimensions)) {
    B[, , k] <- B[, , k] + map$B[, , j] * loading[j, k]
  }
  variance <- diag(d)
  index <- which(upper.tri(variance, diag = TRUE), arr.ind = TRUE)
  fixed_variance <- local({ value <- variance; function(ignored) value })
  control <- list(nodes = seq(-span, span, length.out = nodes), snodes = 0L,
    QMC = FALSE, maxiter = 1000L, conv = conv, convM = conv, convD = 1e-8,
    Msteps = 4L, max.increment = 1, min.variance = .001, ridge = 0,
    xsi.start0 = TRUE, increment.factor = 1, fac.oldxsi = 0,
    acceleration = 'none', dev_crit = 'absolute', trim_increment = 'half',
    progress = FALSE)
  # Supplying Q would overwrite the transformed B. With Q=NULL, TAM constructs
  # an unused random Q draft before retaining supplied A/B. Restore caller RNG.
  had_seed <- exists('.Random.seed', .GlobalEnv, inherits = FALSE)
  seed <- if (had_seed) get('.Random.seed', .GlobalEnv) else NULL
  kind <- RNGkind()
  on.exit({
    do.call(RNGkind, as.list(kind))
    if (had_seed) assign('.Random.seed', seed, .GlobalEnv) else if (
      exists('.Random.seed', .GlobalEnv, inherits = FALSE)) rm('.Random.seed', envir = .GlobalEnv)
  })
  warnings <- character()
  timing <- system.time(fit <- tryCatch(withCallingHandlers(TAM::tam.mml(
    resp = response, irtmodel = 'PCM', A = map$A, B = B, Q = NULL,
    xsi.inits = if (is.null(start)) NULL else cbind(seq_along(start), start),
    pid = rownames(response), beta.fixed = cbind(1L, seq_len(d), 0),
    variance.inits = variance, variance.fixed = cbind(index, variance[index]),
    userfct.variance = fixed_variance, est.variance = TRUE,
    constraint = 'cases', item.elim = FALSE, verbose = FALSE, control = control),
    warning = function(w) { warnings <<- c(warnings, conditionMessage(w)); invokeRestart('muffleWarning') }),
    error = function(e) e))
  if (inherits(fit, 'error')) return(list(status = 'error',
    reason = conditionMessage(fit), warnings = warnings, timing = timing, fit = NULL))
  stopifnot(identical(fit$A, map$A), identical(fit$B, B), is.null(fit$Q),
    identical(fit$resp, response), all(fit$beta == 0),
    identical(unname(fit$variance), variance), fit$maxK == 4L,
    nrow(fit$xsi) == dim(map$A)[3], fit$ic$Nparscov == 0)
  list(status = if (fit$iter < control$maxiter) 'returned' else 'iteration_limit',
    map = map, loading = loading, rho = rho, control = control,
    start = start, span = span,
    warnings = warnings, timing = timing, fit = fit,
    scope = 'Response parameters estimated at a fixed population covariance. Return does not establish stationarity, integration accuracy, globality or an unknown-correlation fit.')
}
