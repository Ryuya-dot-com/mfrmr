# Repository-only zero-variance qualification of four retained D-LR PCM jobs.
# No generated data, positive-variance refits, GPCM selection or public intervals.
# Run from the package root: Rscript THIS_FILE [OUTPUT_DIRECTORY]
# Completed boundary fits and subsequent checks are saved as separate phases.

dlr_pcm_boundary_context <- function(fit) {
  cfg <- fit$config; dat <- fit$prep$data
  stopifnot(cfg$model == 'PCM', cfg$method == 'MML', cfg$n_cat == 4,
    identical(cfg$facet_names, c('Rater', 'Criterion')),
    cfg$step_facet == 'Criterion', all(cfg$facet_signs == -1),
    all(dat$Weight == 1), all(dat$Score == dat$score_k),
    length(cfg$interaction_specs) == 0L, length(fit$opt$par) == 13L,
    identical(fit$population$design_columns, c('(Intercept)', 'X')))
  for (spec in cfg$facet_specs) stopifnot(identical(spec$levels, as.character(1:3)),
    spec$centered, spec$n_params == 2, all(is.na(spec$anchors)), all(is.na(spec$groups)))
  for (spec in cfg$step_specs) stopifnot(spec$n_steps == 3, spec$target == 0,
    spec$reference_index == 3, identical(spec$free_index, 1:3), all(is.na(spec$anchors)))
  sizes <- mfrmr:::build_param_sizes(cfg)
  slices <- mfrmr:::build_param_slices(sizes)
  stopifnot(identical(unname(slices[c('Rater','Criterion','steps','beta','log_sigma2')]),
    list(1:2, 3:4, 5:10, 11:12, 13L)))
  person <- match(as.character(dat$Person), fit$population$included_persons)
  # The analytic categorical likelihood also applies to the allocated higher
  # exposure views. The original four-sample proof/check remains tied to its
  # six-event inputs; each new sample needs its own numerical qualification.
  stopifnot(!anyNA(person), all(tabulate(person) > 0L))
  x <- fit$population$design_matrix[person, 'X']
  contrast <- rbind(diag(2), c(-1,-1))
  cumulative <- rbind(c(0,0), c(1,0), c(1,1), c(0,0))
  nr <- nrow(dat); r <- as.integer(dat$Rater); g <- as.integer(dat$Criterion)
  design <- lapply(0:3, function(k) {
    d <- matrix(0, nr, 12L)
    d[,1:2] <- -k*contrast[r,]; d[,3:4] <- -k*contrast[g,]
    for (owner in 1:3) d[g == owner, 4L+(2L*owner-1L): (2L*owner)] <-
      matrix(-cumulative[k+1L,], sum(g == owner), 2L, byrow=TRUE)
    d[,11:12] <- k*cbind(1,x)
    d
  })
  observed <- Reduce('+', lapply(1:4, function(k) design[[k]]*(dat$Score == k-1L)))
  list(design=design, observed=observed, y=dat$Score, groups=split(seq_len(nr),person),
    fit=fit, sizes=sizes, idx=mfrmr:::build_indices(fit$prep, step_facet='Criterion'),
    persons=length(unique(person)))
}

dlr_pcm_boundary_eval <- function(ctx, eta) {
  logits <- vapply(ctx$design, function(d) as.vector(d %*% eta), numeric(length(ctx$y)))
  peak <- apply(logits,1L,max)
  logp <- logits-peak-log(rowSums(exp(logits-peak)))
  p <- exp(logp)
  mean_design <- Reduce('+', lapply(1:4, function(k) ctx$design[[k]]*p[,k]))
  centered <- lapply(ctx$design, function(d) d-mean_design)
  info <- Reduce('+', lapply(1:4, function(k) crossprod(centered[[k]]*sqrt(p[,k]))))
  list(value=-sum(logp[cbind(seq_along(ctx$y),ctx$y+1L)]),
    gradient=colSums(mean_design-ctx$observed), hessian=info, probability=p,
    logits=logits, centered=centered)
}

dlr_pcm_boundary_fit <- function(ctx) {
  objective <- function(eta) {
    z <- dlr_pcm_boundary_eval(ctx,eta)
    value <- z$value/ctx$persons
    attr(value,'gradient') <- z$gradient/ctx$persons
    attr(value,'hessian') <- z$hessian/ctx$persons
    value
  }
  # Strict convexity and existence are established in the companion math record.
  # nlm supplies the Newton/line-search implementation; no custom optimizer.
  stats::nlm(objective,ctx$fit$opt$par[1:12],gradtol=1e-11,steptol=1e-12,
    iterlim=1000L,check.analyticals=TRUE)
}

dlr_pcm_boundary_information <- function(ctx, z, rows=seq_along(ctx$y)) {
  p <- z$probability[rows,,drop=FALSE]
  mean <- as.vector(p %*% (0:3))
  e <- matrix(0:3,nrow(p),4L,byrow=TRUE)-mean
  variance <- rowSums(p*e^2); fourth <- rowSums(p*e^4)
  A <- Reduce('+',lapply(1:4, function(k)
    crossprod(z$centered[[k]][rows,,drop=FALSE]*sqrt(p[,k]))))
  c <- Reduce('+',lapply(1:4, function(k)
    as.vector(crossprod(z$centered[[k]][rows,,drop=FALSE],p[,k]*e[,k]^2))))/2
  groups <- Filter(length,lapply(ctx$groups,function(ix) match(intersect(ix,rows),rows)))
  pair <- sum(vapply(groups,function(ix) (sum(variance[ix])^2-sum(variance[ix]^2))/2,0))
  d <- sum(fourth-variance^2)/4+pair
  information <- rbind(cbind(A,c),c(c,d))
  observed <- ctx$y[rows]-mean
  score <- sum(vapply(groups,function(ix) (sum(observed[ix])^2-sum(variance[ix]))/2,0))
  list(information=information,
    efficient=if (length(rows) == length(ctx$y)) d-sum(c*solve(A,c)) else NA_real_,
    pair_lower_bound=pair,
    natural_variance_score=score, mean=mean, variance=variance)
}

dlr_pcm_boundary_enumeration <- function(ctx,z,rows) {
  patterns <- as.matrix(expand.grid(rep(list(0:3),length(rows))))
  probability <- rep(1,nrow(patterns)); score <- matrix(0,nrow(patterns),13L)
  residual_sum <- rep(0,nrow(patterns)); variance_sum <- 0
  for (j in seq_along(rows)) {
    row <- rows[j]; p <- z$probability[row,]; y <- patterns[,j]
    centered <- do.call(rbind,lapply(z$centered,function(d) d[row,]))
    probability <- probability*p[y+1L]
    score[,1:12] <- score[,1:12]+centered[y+1L,,drop=FALSE]
    mean <- sum((0:3)*p)
    residual_sum <- residual_sum+y-mean
    variance_sum <- variance_sum+sum(((0:3)-mean)^2*p)
  }
  score[,13] <- (residual_sum^2-variance_sum)/2
  list(information=crossprod(score*sqrt(probability)), mass=sum(probability),
    mean=colSums(score*probability), patterns=nrow(patterns))
}

dlr_pcm_continuous_value <- function(ctx,eta,variance) {
  z <- dlr_pcm_boundary_eval(ctx,eta)
  log_pattern <- function(nodes,rows) {
    value <- numeric(length(nodes))
    for (row in rows) {
      logits <- outer(sqrt(variance)*nodes,0:3)+
        matrix(z$logits[row,],length(nodes),4L,byrow=TRUE)
      peak <- apply(logits,1L,max)
      value <- value+logits[,ctx$y[row]+1L]-peak-log(rowSums(exp(logits-peak)))
    }
    value
  }
  details <- lapply(ctx$groups,function(rows) {
    reference <- log_pattern(0,rows)
    integral <- stats::integrate(function(nodes)
      exp(log_pattern(nodes,rows)-reference+dnorm(nodes,log=TRUE)),
      -Inf,Inf,rel.tol=1e-11,abs.tol=1e-13,subdivisions=200L)
    stopifnot(integral$message == 'OK',integral$value > 0,
      integral$abs.error/integral$value < 1e-10)
    c(log_probability=reference+log(integral$value),
      relative_error=integral$abs.error/integral$value)
  })
  details <- do.call(rbind,details)
  list(value=-sum(details[,'log_probability']),details=details,
    summed_relative_error=sum(details[,'relative_error']))
}

dlr_pcm_package_evaluator <- function(ctx,q) {
  mfrmr:::make_mfrm_direct_evaluator('MML',
    mfrmr:::make_param_cache(ctx$sizes,ctx$fit$config,ctx$idx,is_mml=TRUE),
    ctx$idx,ctx$fit$config,ctx$sizes,mfrmr:::gauss_hermite_normal(q))
}

dlr_pcm_boundary_check <- function(ctx,opt) {
  eta <- opt$estimate; z <- dlr_pcm_boundary_eval(ctx,eta)
  info <- dlr_pcm_boundary_information(ctx,z)
  q1 <- dlr_pcm_package_evaluator(ctx,1L)
  package_values <- vapply(c(-32,0,32),function(dummy) q1$value(c(eta,dummy)),0)
  package_gradient <- q1$gradient(c(eta,0))[1:12]
  derivatives <- lapply(c(1e-4,5e-5),function(h) {
    gradient <- numeric(12); hessian <- matrix(0,12,12)
    for (j in 1:12) {
      plus <- minus <- eta; plus[j] <- plus[j]+h; minus[j] <- minus[j]-h
      zp <- dlr_pcm_boundary_eval(ctx,plus); zm <- dlr_pcm_boundary_eval(ctx,minus)
      gradient[j] <- (zp$value-zm$value)/(2*h)
      hessian[,j] <- (zp$gradient-zm$gradient)/(2*h)
    }
    list(gradient=gradient,hessian=hessian)
  })
  # Analytic dual-feasible correction of fitted category probabilities.
  # Retain floating-point feasibility and gap; do not call it an interval proof.
  direction <- solve(z$hessian,z$gradient)
  dual <- z$probability
  for (k in 1:4) dual[,k] <- dual[,k]*(1-as.vector(z$centered[[k]] %*% direction))
  stopifnot(all(dual > 0))
  dual_gradient <- colSums(Reduce('+',lapply(1:4,function(k) ctx$design[[k]]*dual[,k]))-
    ctx$observed)
  dual_gap <- z$value+sum(dual*log(dual))
  rows <- ctx$groups[[1L]]
  enum <- dlr_pcm_boundary_enumeration(ctx,z,rows)
  row_info <- dlr_pcm_boundary_information(ctx,z,rows)
  # Evaluate three nearby variances once for two second-order one-sided checks.
  steps <- c(1e-4,5e-5,2.5e-5)
  paths <- lapply(steps,function(v) dlr_pcm_continuous_value(ctx,eta,v))
  f <- vapply(paths,`[[`,0,'value')
  forward <- c((-3*z$value+4*f[2]-f[1])/(2*steps[2]),
    (-3*z$value+4*f[3]-f[2])/(2*steps[3]))
  interior <- dlr_pcm_continuous_value(ctx,ctx$fit$opt$par[1:12],ctx$fit$population$sigma2)
  checks <- c(
    optimizer=opt$code %in% c(1L,2L),
    stationarity=max(abs(z$gradient)) <= 1e-6 &&
      sqrt(abs(sum(z$gradient*direction))) <= 1e-7,
    dual=max(abs(dual_gradient)) <= 1e-9 && max(abs(rowSums(dual)-1)) <= 1e-12 &&
      abs(dual_gap) <= 1e-8,
    package=max(abs(package_values-z$value)) <= 1e-8 &&
      max(abs(package_gradient-z$gradient)) <= 1e-8,
    derivatives=max(abs(derivatives[[2]]$gradient-z$gradient))/ctx$persons <= 1e-7 &&
      max(abs(derivatives[[2]]$gradient-derivatives[[1]]$gradient))/ctx$persons <= 1e-7 &&
      max(abs(derivatives[[2]]$hessian-z$hessian))/max(1,max(abs(z$hessian))) <= 1e-6,
    information=min(eigen(info$information,symmetric=TRUE,only.values=TRUE)$values) > 0 &&
      info$efficient >= info$pair_lower_bound-1e-9,
    enumeration=abs(enum$mass-1) <= 1e-12 && max(abs(enum$mean)) <= 1e-10 &&
      max(abs(enum$information-row_info$information)) <= 1e-9,
    variance_derivative=max(abs(forward+info$natural_variance_score))/ctx$persons <= 1e-6)
  list(opt=opt,boundary=z,information=info,package_values=package_values,
    package_gradient=package_gradient,derivatives=derivatives,
    dual=list(gap=dual_gap,moment_residual=max(abs(dual_gradient)),
      row_mass_residual=max(abs(rowSums(dual)-1)),minimum_probability=min(dual)),
    enumeration=enum,enumeration_reference=row_info,variance_steps=steps,
    paths=paths,nll_forward_derivative=forward,interior=interior,checks=checks)
}

dlr_pcm_boundary_refine <- function(ctx,initial) {
  result <- initial
  eta <- initial$opt$estimate
  polished <- !all(initial$checks[c('optimizer','stationarity')])
  if (polished) {
    # nlm can stop on objective roundoff before the stricter score criterion.
    # One analytic Newton correction uses its retained Hessian; no new start.
    z <- initial$boundary
    correction <- solve(z$hessian,z$gradient)
    eta <- eta-correction
    candidate <- dlr_pcm_boundary_eval(ctx,eta)
    stopifnot(max(abs(correction)) < 1e-5, candidate$value <= z$value+1e-9)
    view <- initial$opt; view$estimate <- eta
    result <- dlr_pcm_boundary_check(ctx,view)
    result$opt <- initial$opt  # Preserve the actual nlm return, including code 3.
    names(result$checks)[names(result$checks) == 'optimizer'] <- 'newton_refinement'
    result$checks['newton_refinement'] <- result$checks['stationarity'] && result$checks['dual']
  }
  # Retain the coarse derivative miss; add only one smaller variance evaluation.
  step <- tail(result$variance_steps,1L)/2
  finer <- dlr_pcm_continuous_value(ctx,eta,step)
  forward <- (-3*result$boundary$value+4*finer$value-tail(result$paths,1L)[[1L]]$value)/(2*step)
  result$variance_steps <- c(result$variance_steps,step)
  result$paths <- c(result$paths,list(finer))
  result$nll_forward_derivative <- c(result$nll_forward_derivative,forward)
  result$checks['variance_derivative'] <-
    max(abs(tail(result$nll_forward_derivative,2L)+result$information$natural_variance_score))/ctx$persons <= 1e-6
  result$estimate <- eta
  result$refinement <- list(newton_steps=as.integer(polished),
    initial_checks=initial$checks,initial_nll=initial$boundary$value,
    initial_variance_derivative_error=max(abs(initial$nll_forward_derivative+
      initial$information$natural_variance_score)))
  result
}

dlr_pcm_boundary_run <- function(out) {
  pkgload::load_all('.',quiet=TRUE,compile=FALSE)
  source('inst/validation/mfrm-wide-map-mml-stages-20261001.R')
  input <- 'validation-results/mfrm-wide-map-lr-witness-20261002'
  manifest <- readRDS(file.path(input,'manifest.rds'))$payload
  ids <- names(manifest$jobs)[endsWith(names(manifest$jobs),'-PCM')]
  stopifnot(length(ids) == 4L)
  # The publication changes to plots, two-family GPCM replay and the Matrix
  # import were reviewed separately; none changes this PCM likelihood route.
  hashes <- manifest$runtime$source
  files <- names(hashes)[startsWith(names(hashes),'R/') | startsWith(names(hashes),'src/')]
  current <- tools::md5sum(files)
  changed <- files[unname(current) != unname(hashes[files])]
  reviewed <- c('R/api-gpcm-curve-intervals.R'='a505c4585abcb388f9bbbe4c4dbcbc7a',
    'R/api-plotting-multivariate-d-compare.R'='db24044e286071eebdbc3d0426539873',
    'R/core-gmfrm-em.R'='916e826e3a449a65ad2c0b1c411aabeb',
    'R/core-gpcm-product-slopes.R'='6e6ac21729378230c01180d06c184e75',
    'R/mfrmr-package.R'='5843e8e17355b40fd967419f2f902ff8')
  stopifnot(all(changed %in% names(reviewed)),
    identical(unname(current[changed]),unname(reviewed[changed])))
  source_changes <- data.frame(File=changed,Archived=unname(hashes[changed]),
    Current=unname(current[changed]))
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  runtime <- wide_mml_runtime(); summary <- details <- list()
  for (id in ids) {
    path <- file.path(input,id,'fit.rds'); saved <- readRDS(path)
    stopifnot(identical(saved$checksum,wide_mml_hash(saved$payload)))
    ctx <- dlr_pcm_boundary_context(saved$payload$value)
    # Retain the original data and population design; never call a generator.
    original <- manifest$jobs[[id]]$args$data
    for (nm in c('Person','Rater','Criterion')) original[[nm]] <-
      factor(original[[nm]],levels=levels(ctx$fit$prep$data[[nm]]))
    stopifnot(identical(original,ctx$fit$prep$data[names(original)]))
    cat('Boundary:',id,'\n'); flush.console()
    binding <- list(input=tools::md5sum(path),R=R.version.string,
      functions=lapply(list(dlr_pcm_boundary_context,dlr_pcm_boundary_eval,dlr_pcm_boundary_fit),body))
    opt <- wide_mml_phase(file.path(out,paste0(id,'-fit.rds')),binding,
      function() dlr_pcm_boundary_fit(ctx))
    verification <- list(input=binding,fit=wide_mml_hash(opt),runtime=runtime,
      functions=lapply(list(dlr_pcm_boundary_check,dlr_pcm_boundary_information,
        dlr_pcm_boundary_enumeration,dlr_pcm_continuous_value,dlr_pcm_package_evaluator),body))
    result <- wide_mml_phase(file.path(out,paste0(id,'-checks.rds')),verification,
      function() dlr_pcm_boundary_check(ctx,opt))
    result <- wide_mml_phase(file.path(out,paste0(id,'-refinement.rds')),
      list(initial=wide_mml_hash(result),verification=verification,
        refinement=body(dlr_pcm_boundary_refine)),
      function() dlr_pcm_boundary_refine(ctx,result))
    z <- result$boundary; i <- result$information
    row <- data.frame(Job=id,N=ctx$persons,Rho=manifest$jobs[[id]]$input$Rho,
      InitialIterations=opt$iterations,InitialOptimizerCode=opt$code,
      NewtonRefinementSteps=result$refinement$newton_steps,
      BoundaryNLL=z$value,BoundaryGamma0=result$estimate[11],BoundaryGamma1=result$estimate[12],
      GradientSup=max(abs(z$gradient)),DualGap=result$dual$gap,
      DualMomentResidual=result$dual$moment_residual,
      NaturalVarianceScore=i$natural_variance_score,EfficientVarianceInformation=i$efficient,
      PairInformationLowerBound=i$pair_lower_bound,
      JointInformationMinEigenvalue=min(eigen(i$information,symmetric=TRUE,only.values=TRUE)$values),
      PackageNLLDifference=max(abs(result$package_values-z$value)),
      PackageGradientDifference=max(abs(result$package_gradient-z$gradient)),
      FDGradientDifference=max(abs(result$derivatives[[2]]$gradient-z$gradient)),
      FDHessianDifference=max(abs(result$derivatives[[2]]$hessian-z$hessian)),
      InitialVarianceDerivativeDifference=result$refinement$initial_variance_derivative_error,
      VarianceDerivativeDifference=max(abs(tail(result$nll_forward_derivative,2L)+i$natural_variance_score)),
      EnumerationInformationDifference=max(abs(result$enumeration$information-result$enumeration_reference$information)),
      InteriorVariance=ctx$fit$population$sigma2,InteriorContinuousNLL=result$interior$value,
      InteriorQ31NLL=ctx$fit$opt$value,Q31MinusContinuousNLL=ctx$fit$opt$value-result$interior$value,
      InteriorLogLikelihoodGain=z$value-result$interior$value,
      IntegrationErrorEstimate=result$interior$summed_relative_error,
      AllChecksPassed=all(result$checks))
    summary[[id]] <- row; details[[id]] <- result
    print(row[c('Job','NaturalVarianceScore','InteriorLogLikelihoodGain','AllChecksPassed')],row.names=FALSE)
    write.csv(do.call(rbind,summary),file.path(out,'summary.csv'),row.names=FALSE)
  }
  summary <- do.call(rbind,summary)
  evidence <- list(summary=summary,details=details,runtime=runtime,source_changes=source_changes,
    source=tools::md5sum('inst/validation/mfrm-wide-map-lr-pcm-boundary-20261002.R'),
    script=readLines('inst/validation/mfrm-wide-map-lr-pcm-boundary-20261002.R'),
    scope='Four saved PCM covariate views of two parent cohorts; boundary qualification only.')
  wide_mml_save(evidence,file.path(out,'verified.rds'))
  stopifnot(all(summary$AllChecksPassed))
  invisible(evidence)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly=TRUE)
  out <- if (length(args)) args[1L] else 'validation-results/mfrm-wide-map-lr-pcm-boundary-20261002'
  dlr_pcm_boundary_run(out)
}
