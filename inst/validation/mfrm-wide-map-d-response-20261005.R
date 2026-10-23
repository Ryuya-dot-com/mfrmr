# D's common population-relative point targets. No fitting, integration,
# source selection or uncertainty propagation. The caller retains those stages.
wide_d_fixed_normal_parameters <- function(fit) {
  cfg <- fit$config
  facets <- cfg$facet_names
  product <- identical(cfg$model, "GPCM") && length(cfg$slope_facet) == 2L
  stopifnot(inherits(fit, "mfrm_fit"), !inherits(fit, "mfrm_imported_fit"),
    identical(cfg$method, "MML"), cfg$model %in% c("PCM", "GPCM"),
    length(facets) == 2L, !anyDuplicated(facets),
    identical(cfg$step_facet, facets[2L]), length(cfg$facet_signs[facets]) == 2L,
    all(cfg$facet_signs[facets] == -1),
    !length(cfg$interaction_specs), fit$prep$rating_min == 0,
    cfg$n_cat >= 2L, cfg$n_cat == as.integer(cfg$n_cat),
    fit$prep$rating_max == cfg$n_cat - 1L,
    is.numeric(fit$opt$par), !is.complex(fit$opt$par), all(is.finite(fit$opt$par)))
  sizes <- mfrmr:::build_param_sizes(cfg)
  stopifnot(length(fit$opt$par) == sum(unlist(sizes)))
  params <- mfrmr:::expand_params(fit$opt$par, sizes, cfg)
  levels <- cfg$facet_levels[facets]
  slopes <- lapply(levels, function(x) setNames(rep(1, length(x)), x))
  if (product) {
    stopifnot(identical(cfg$slope_facet, facets),
      identical(cfg$noncenter_facet, facets[2L]),
      identical(cfg$posterior_basis, "fixed_standard_normal"),
      !isTRUE(cfg$population_spec$active), !isTRUE(fit$population$active))
    for (owner in facets) {
      tab <- params$slope_components[[owner]]
      stopifnot(identical(tab$Level, levels[[owner]]))
      slopes[[owner]][] <- tab$Slope
    }
    mu <- 0; sigma <- 1
  } else {
    stopifnot(isTRUE(cfg$population_spec$active), isTRUE(fit$population$active),
      identical(names(params$population$coefficients), "(Intercept)"))
    mu <- unname(params$population$coefficients)
    sigma <- sqrt(params$population$sigma2)
    if (cfg$model == "GPCM") {
      stopifnot(length(cfg$slope_facet) == 1L, cfg$slope_facet %in% facets,
        identical(cfg$gpcm_spec$levels, levels[[cfg$slope_facet]]))
      slopes[[cfg$slope_facet]][] <- params$slopes
    }
  }
  stopifnot(length(mu) == 1L, length(sigma) == 1L,
    is.finite(mu), is.finite(sigma), sigma > 0)
  locations <- lapply(params$facets[facets], function(x) x/sigma)
  locations[[2L]] <- locations[[2L]] - mu/sigma
  slopes[[2L]] <- sigma * slopes[[2L]]
  steps <- params$steps_mat/sigma
  stopifnot(all(is.finite(c(unlist(locations), unlist(slopes), steps))),
    all(unlist(slopes) > 0), is.matrix(steps),
    nrow(steps) == length(levels[[2L]]), ncol(steps) == cfg$n_cat - 1L)
  list(facets = facets, levels = levels, locations = locations, slopes = slopes,
    steps = steps, K = cfg$n_cat, mu = 0, sd = 1,
    native_population = c(mean = mu, sd = sigma),
    scale = "fixed_standard_normal_response_equivalent",
    interpretation = "Transformed point values only; numerical admission and joint transformation uncertainty are separate.")
}

wide_d_response_points <- function(fit, z = c(-2, -1, 0, 1, 2)) {
  stopifnot(is.numeric(z), !is.complex(z), length(z) > 0L,
    !anyNA(z), all(is.finite(z)), !anyDuplicated(z))
  params <- wide_d_fixed_normal_parameters(fit)
  grid <- expand.grid(z = z, first = seq_along(params$levels[[1L]]),
    second = seq_along(params$levels[[2L]]))
  eta <- grid$z - params$locations[[1L]][grid$first] - params$locations[[2L]][grid$second]
  slope <- params$slopes[[1L]][grid$first] * params$slopes[[2L]][grid$second]
  cumulative <- t(apply(params$steps, 1L, function(x) c(0, cumsum(x))))
  probabilities <- mfrmr:::category_prob_gpcm(eta, cumulative, grid$second, slope, seq_len(nrow(grid)))
  stopifnot(is.matrix(probabilities), nrow(probabilities) == nrow(grid),
    ncol(probabilities) == params$K, all(is.finite(probabilities)),
    all(probabilities >= 0 & probabilities <= 1))
  grid[[params$facets[1L]]] <- params$levels[[1L]][grid$first]
  grid[[params$facets[2L]]] <- params$levels[[2L]][grid$second]
  list(parameters = params, grid = grid, probabilities = probabilities,
    expected_score = drop(probabilities %*% (0:(params$K - 1L))),
    normalized_expected_score = drop(probabilities %*% (0:(params$K - 1L)))/(params$K - 1L))
}
