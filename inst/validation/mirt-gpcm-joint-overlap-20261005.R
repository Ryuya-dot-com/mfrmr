# Research-only item GPCM coordinate/covariance comparison. No import API.
# mirt uses k*a_i*z+d_ik, with d_i0=0 and z~N(0,1).
# Native mfrmr uses relative slopes, centered locations/steps, and free mu/SD.
mirt_overlap_layout <- function(parameters, items, K) {
  stopifnot(all(parameters$prior.type == 'none'),
    all(!parameters$est[parameters$item == 'GROUP']),
    parameters$value[parameters$name == 'MEAN_1'] == 0,
    parameters$value[parameters$name == 'COV_11'] == 1)
  z <- parameters[parameters$est, ]
  expected <- c('a1', paste0('d', seq_len(K-1L)))
  stopifnot(nrow(z) == length(items)*K, !anyDuplicated(z$parnum))
  index <- t(vapply(items, function(item) {
    rows <- which(z$item == item)
    stopifnot(setequal(z$name[rows], expected))
    rows[match(expected, z$name[rows])]
  }, integer(K)))
  for (item in items) {
    q <- parameters[parameters$item == item, ]
    stopifnot(identical(q$value[match(paste0('ak', 0:(K-1L)), q$name)], as.numeric(0:(K-1L))),
      all(!q$est[match(paste0('ak', 0:(K-1L)), q$name)]),
      q$value[q$name == 'd0'] == 0, !q$est[q$name == 'd0'])
  }
  list(index = index, items = items, K = K,
    labels = paste(z$name, z$parnum, sep = '.'), values = z$value,
    parameters = z[c('item', 'name', 'parnum')])
}

mirt_overlap_map <- function(v, layout) {
  ix <- layout$index; I <- nrow(ix); S <- layout$K-1L; P <- length(v)
  stopifnot(length(v) == length(layout$labels), all(is.finite(v)))
  a <- v[ix[,1L]]; stopifnot(all(a > 0))
  sigma <- exp(mean(log(a)))
  d <- matrix(v[ix[,-1L,drop=FALSE]], I, S)
  delta <- d-cbind(0, d[,-S,drop=FALSE])
  thresholds <- -sigma*delta/a
  J <- matrix(0, I*S, P)
  for (i in seq_len(I)) for (k in seq_len(S)) {
    row <- (i-1L)*S+k
    J[row, ix[,1L]] <- thresholds[i,k]*(1/(I*a)-(seq_len(I)==i)/a[i])
    J[row, ix[i,k+1L]] <- -sigma/a[i]
    if (k > 1L) J[row, ix[i,k]] <- sigma/a[i]
  }
  mu <- -mean(thresholds); Jmu <- -colMeans(J)
  locations <- rowMeans(thresholds)+mu
  Jrow <- t(vapply(seq_len(I), function(i) colMeans(J[(i-1L)*S+seq_len(S),,drop=FALSE]), numeric(P)))
  Jlocations <- sweep(Jrow, 2L, Jmu, '+')
  steps <- thresholds-rowMeans(thresholds)
  Jsteps <- J-Jrow[rep(seq_len(I), each=S),,drop=FALSE]
  Jlog <- matrix(0,I,P)
  Jlog[,ix[,1L]] <- diag(1/a,I)-matrix(rep(1/(I*a),each=I),I)
  Jsd <- numeric(P); Jsd[ix[,1L]] <- sigma/(I*a)
  value <- c(locations, as.vector(t(steps)), log(a)-log(sigma), mu, sigma)
  labels <- c(paste0('Location:',layout$items),
    paste0('Step:',rep(layout$items,each=S),':',rep(seq_len(S),I)),
    paste0('LogSlope:',layout$items),'PopulationMean','PopulationSD')
  jacobian <- rbind(Jlocations,Jsteps,Jlog,Jmu,Jsd)
  names(value) <- rownames(jacobian) <- labels; colnames(jacobian) <- layout$labels
  list(value=value,jacobian=jacobian,thresholds=thresholds,
    absolute_slopes=a,relative_slopes=a/sigma,mu=mu,sigma=sigma)
}

mirt_overlap_native <- function(fit, items) {
  cfg <- fit$config; sizes <- mfrmr:::build_param_sizes(cfg)
  stopifnot(identical(cfg$facet_names,'Criterion'), cfg$n_cat == 4L,
    identical(cfg$slope_facet,'Criterion'), isTRUE(cfg$population_spec$active),
    identical(cfg$population_spec$design_columns,'(Intercept)'))
  at <- match(items,cfg$facet_levels$Criterion); stopifnot(!anyNA(at))
  expand <- function(v) {
    z <- mfrmr:::expand_params(v,sizes,cfg)
    c(z$facets$Criterion[at], as.vector(t(z$steps_mat[at,,drop=FALSE])),
      z$log_slopes[at], unname(z$population$coefficients), sqrt(z$population$sigma2))
  }
  value <- expand(fit$opt$par); P <- length(fit$opt$par); zero <- expand(numeric(P))
  # All reported coordinates except SD are linear constraint expansions.
  jacobian <- vapply(seq_len(P), function(j) {
    v <- numeric(P); v[j] <- 1; expand(v)-zero
  }, numeric(length(value)))
  sd_row <- length(value); jacobian[sd_row,] <- 0
  slices <- mfrmr:::build_param_slices(sizes)
  jacobian[sd_row,slices$log_sigma2] <- value[sd_row]/2
  stopifnot(max(abs(drop(jacobian[-sd_row,,drop=FALSE] %*% fit$opt$par)+zero[-sd_row]-value[-sd_row])) < 1e-12)
  list(value=value,jacobian=jacobian,expand=expand)
}
