# Saved-case numerical review; run from package root, with screen/reference/refit.
.libPaths(c(normalizePath('.r-library'), .libPaths()))
pkgload::load_all('.', quiet = TRUE)
original <- 'validation-results/estimated-model-qualification-20260923'
out <- 'validation-results/shared-rater-integration-20260923'
dir.create(out, recursive = TRUE, showWarnings = FALSE)
checks <- read.csv(file.path(original, 'numerical-checks.csv'))
failed <- subset(checks, !NumericalReady)
worst <- vapply(split(failed, failed$Condition), function(d)
  d$Trial[which.max(d$GradientDifference)], integer(1))
controls <- vapply(split(subset(checks, NumericalReady), checks$Condition[checks$NumericalReady]),
  function(d) d$Trial[which.max(d$GradientDifference)], integer(1))
ids <- sort(unique(c(failed$Trial, controls, checks$Trial[checks$EstimatedVarianceBoundary])))
read_trial <- function(id) readRDS(file.path(original, sprintf('trial-%04d.rds', id)))
objective <- function(fit, q, random = TRUE) mfrm_random_rater_objective(fit$input, q,
  fixed_sd = if (fit$checks$EstimatedVarianceBoundary) 0 else fit$settings$fixed_rater_sd,
  fixed_person_sd = mfrm_random_rater_fixed_person_sd(fit), random = random)

# Independent continuous Person integrals. The only inputs shared with the
# production implementation are observed scores, design coding and calibration.
# No production quadrature or probability/moment helper is used.
continuous <- function(input, par, z, moments = TRUE) {
  nb <- ncol(input$X); ns <- length(input$score_levels) - 1L
  beta <- par[seq_len(nb)]; steps <- par[nb + seq_len(ns)]
  sr <- unname(par['sd']); sp <- unname(par['person_sd']); nr <- length(z)
  offset <- drop(input$X %*% beta) + sr * z[input$rater]
  nll <- sum(z^2) / 2 + nr * log(2*pi) / 2
  gradient <- c(rep(0, nb + ns), z, 0, 0)
  H <- diag(nr); errors <- numeric()
  for (rows in split(seq_along(input$y), input$person)) {
    r <- sort(unique(input$rater[rows])); ir <- match(input$rater[rows], r)
    M <- sapply(r, function(a) as.numeric(input$rater[rows] == a))
    X <- input$X[rows, , drop = FALSE]; y <- input$y[rows]
    # Vectorize over integration nodes; category probabilities use direct
    # cumulative adjacent logits with max subtraction for numerical stability.
    values <- function(t) {
      eta <- outer(sp * t, offset[rows], '-')
      logden <- matrix(0, length(t), length(rows))
      a <- lapply(0:ns, function(k) k * eta - sum(steps[seq_len(k)]))
      shift <- Reduce(pmax, a)
      w <- lapply(a, function(v) exp(v - shift)); den <- Reduce('+', w)
      prob <- lapply(w, '/', den)
      mu <- Reduce('+', Map('*', prob, 0:ns))
      v <- Reduce('+', Map('*', prob, (0:ns)^2)) - mu^2
      lp <- rowSums(sweep(eta, 2, y, '*') -
        matrix(c(0,cumsum(steps))[y+1], length(t), length(rows), byrow=TRUE) - shift - log(den))
      weight <- exp(lp + dnorm(t, log=TRUE))
      residual <- matrix(y, length(t), length(rows), byrow=TRUE) - mu
      sz <- -sr * (residual %*% M)
      sb <- -residual %*% X
      ss <- sapply(seq_len(ns), function(k) rowSums(Reduce('+', prob[(k+1):(ns+1)])) - sum(y >= k))
      ssd <- -drop(residual %*% z[input$rater[rows]])
      ssp <- t * rowSums(residual)
      list(weight=weight, sz=sz, sb=sb, ss=ss, ssd=ssd, ssp=ssp, v=v)
    }
    integrate_value <- function(fn) {
      ans <- integrate(function(t) { a <- values(t); a$weight * fn(a) },
        -Inf, Inf, rel.tol=2e-11, abs.tol=1e-13, subdivisions=200L)
      stopifnot(identical(ans$message, 'OK'), is.finite(ans$value))
      errors <<- c(errors, ans$abs.error)
      ans$value
    }
    mass <- integrate_value(function(a) rep(1, length(a$weight)))
    stopifnot(mass > 1e-10)
    nll <- nll - log(mass)
    ez <- vapply(seq_along(r), function(j) integrate_value(function(a) a$sz[,j]) / mass, numeric(1))
    gradient[nb+ns+r] <- gradient[nb+ns+r] - ez
    for (j in seq_along(r)) for (k in seq_len(j)) {
      raw <- integrate_value(function(a) a$sz[,j]*a$sz[,k] -
        if (j == k) sr^2 * drop(a$v %*% M[,j]) else 0) / mass
      h <- -(raw - ez[j]*ez[k]); H[r[j],r[k]] <- H[r[j],r[k]] + h
      if (j != k) H[r[k],r[j]] <- H[r[k],r[j]] + h
    }
    if (moments) {
      for (j in seq_len(nb)) gradient[j] <- gradient[j] - integrate_value(function(a) a$sb[,j]) / mass
      for (j in seq_len(ns)) gradient[nb+j] <- gradient[nb+j] - integrate_value(function(a) a$ss[,j]) / mass
      gradient[nb+ns+nr+1] <- gradient[nb+ns+nr+1] - integrate_value(function(a) a$ssd) / mass
      gradient[nb+ns+nr+2] <- gradient[nb+ns+nr+2] - integrate_value(function(a) a$ssp) / mass
    }
  }
  stopifnot(min(eigen(H, symmetric=TRUE, only.values=TRUE)$values) > 0)
  list(joint=nll, gradient=gradient, hessian=H,
    laplace=nll + as.numeric(determinant(H, logarithm=TRUE)$modulus)/2 - nr*log(2*pi)/2,
    mode_gradient=max(abs(gradient[nb+ns+seq_len(nr)])), max_absolute_error=max(errors))
}

mode <- commandArgs(trailingOnly=TRUE)[1]
if (mode == 'screen') {
  stopifnot(nrow(failed)==53L, length(worst)==4L)
  sources <- c('R/api-random-rater.R','R/mfrm_core.R','R/core-optimizer.R',
    'inst/validation/shared-rater-integration-review-0.2.4.R',
    'inst/validation/shared-rater-integration-review-0.2.4.md')
  saveRDS(list(sources=tools::md5sum(sources), inputs=tools::md5sum(
    file.path(original,sprintf('trial-%04d.rds',ids))), ids=ids, worst=worst,
    controls=controls, session=sessionInfo(), started=Sys.time()), file.path(out,'protocol.rds'))
  result <- list()
  for (id in ids) {
    f <- read_trial(id)$fits$shared
    values <- lapply(c(61L,123L,241L),function(q) {
      obj <- objective(f,q); value <- as.numeric(obj$fn(f$coefficients)); g <- as.vector(obj$gr(f$coefficients))
      list(q=q,value=value,gradient=g)
    })
    saveRDS(values,file.path(out,sprintf('fixed-%04d.rds',id)))
    result[[length(result)+1L]] <- data.frame(Trial=id, OriginalReady=f$checks$NumericalReady,
      OldValue=abs(values[[1]]$value-values[[2]]$value),
      OldGradient=max(abs(values[[1]]$gradient-values[[2]]$gradient)),
      FineValue=abs(values[[2]]$value-values[[3]]$value),
      FineGradient=max(abs(values[[2]]$gradient-values[[3]]$gradient)))
    write.csv(do.call(rbind,result),file.path(out,'fixed-comparison.csv'),row.names=FALSE)
    cat('fixed',id,'fine differences',tail(result,1)[[1]]$FineValue,tail(result,1)[[1]]$FineGradient,'\n');flush.console()
    gc()
  }
} else if (mode == 'reference') {
  summary <- list()
  for (id in worst) {
    f <- read_trial(id)$fits$shared; par <- f$coefficients
    obj <- objective(f,241L); val <- as.numeric(obj$fn(par)); grad <- as.vector(obj$gr(par))
    z <- as.numeric(obj$env$parList(par=obj$env$last.par)$z)
    joint <- objective(f,241L,FALSE); nb <- length(f$calibration$beta); ns <- length(f$calibration$steps)
    jp <- c(par[seq_len(nb+ns)],z,par['sd'],par['person_sd'])
    jv <- as.numeric(joint$fn(jp)); jg <- as.vector(joint$gr(jp)); jh <- joint$he(jp)
    ref <- continuous(f$input,par,z)
    hz <- jh[nb+ns+seq_along(z),nb+ns+seq_along(z)]
    row <- data.frame(Trial=id,JointError=abs(jv-ref$joint),
      GradientError=max(abs(jg-ref$gradient)),HessianError=max(abs(hz-ref$hessian)),
      LaplaceError=abs(val-ref$laplace),ModeGradient=ref$mode_gradient,
      IntegralAbsoluteError=ref$max_absolute_error)
    saveRDS(list(par=par,z=z,reference=ref,joint_value=jv,joint_gradient=jg,
      joint_hessian=hz,laplace=val,gradient=grad),file.path(out,sprintf('reference-%04d.rds',id)))
    summary[[length(summary)+1L]] <- row
    print(row);flush.console();gc()
  }
  write.csv(do.call(rbind,summary),file.path(out,'continuous-comparison.csv'),row.names=FALSE)
  id <- failed$Trial[which.max(failed$GradientDifference)]
  f <- read_trial(id)$fits$shared; vals <- readRDS(file.path(out,sprintf('fixed-%04d.rds',id)))
  index <- which.max(abs(vals[[1]]$gradient-vals[[3]]$gradient)); par <- f$coefficients
  obj <- objective(f,241L)
  stencil <- lapply(c(1e-4,5e-5),function(h) {
    answer <- lapply(c(-1,1),function(sign) {
      at <- par; at[index] <- at[index]+sign*h
      obj$fn(at); z <- as.numeric(obj$env$parList(par=obj$env$last.par)$z)
      ref <- continuous(f$input,at,z,moments=FALSE)
      list(value=ref$laplace,mode_gradient=ref$mode_gradient)
    })
    data.frame(Trial=id,Coordinate=names(par)[index],Step=h,
      Continuous=(answer[[2]]$value-answer[[1]]$value)/(2*h),
      Q61=vals[[1]]$gradient[index],Q241=vals[[3]]$gradient[index],
      ModeGradient=max(vapply(answer,`[[`,numeric(1),'mode_gradient')))
  })
  write.csv(do.call(rbind,stencil),file.path(out,'continuous-gradient.csv'),row.names=FALSE)
  print(do.call(rbind,stencil))
} else if (mode %in% c('refit','refit-remaining')) {
  args <- commandArgs(trailingOnly=TRUE)
  run_ids <- worst; suffix <- ''
  if (mode == 'refit-remaining') {
    worker <- as.integer(args[2]); stopifnot(worker %in% 1:2)
    pending <- setdiff(failed$Trial,worst)
    stopifnot(length(pending)==49L)
    run_ids <- pending[(seq_along(pending)-1L) %% 2L == worker-1L]
    suffix <- paste0('-',worker)
    saveRDS(list(ids=run_ids,started=Sys.time(),source=tools::md5sum(c(
      'R/api-random-rater.R','R/mfrm_core.R','R/core-optimizer.R',
      'inst/validation/shared-rater-integration-review-0.2.4.R',
      'inst/validation/shared-rater-integration-review-0.2.4.md'))),
      file.path(out,paste0('refit-protocol',suffix,'.rds')))
  }
  result <- list()
  for (id in run_ids) {
    x <- read_trial(id); f <- x$fits$shared
    elapsed <- system.time(g <- fit_mfrm_random_rater(x$data,'Person','Rater','Score','Criterion',0:2,
      person_sd=NULL,quad_points=121L,maxit=400L))['elapsed']
    hi <- objective(g,241L); value <- as.numeric(hi$fn(g$coefficients)); grad <- as.vector(hi$gr(g$coefficients))
    H <- optimHess(g$coefficients,hi$fn,hi$gr)
    row <- data.frame(Trial=id,Ready=g$checks$NumericalReady,
      InformationPositive=g$checks$InformationPositive,
      CheckValue=g$checks$LogLikDifference,CheckGradient=g$checks$GradientDifference,
      Q241Value=abs(value+g$loglik),Q241Gradient=max(abs(grad)),
      InformationRelative=max(abs(H-g$information))/max(abs(H)),
      MaxCalibrationChange=max(abs(g$coefficients-f$coefficients)),
      MaxRaterChange=max(abs(g$rater_mode-f$rater_mode)),Seconds=unname(elapsed))
    saveRDS(g,file.path(out,sprintf('refit-%04d.rds',id)))
    result[[length(result)+1L]] <- row
    write.csv(do.call(rbind,result),file.path(out,paste0('refits',suffix,'.csv')),row.names=FALSE)
    print(row);flush.console();gc()
  }
} else stop('Use screen, reference or refit')
