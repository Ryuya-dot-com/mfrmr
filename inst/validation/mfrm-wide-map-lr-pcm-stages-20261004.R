# Gaussian PCM regression calibration for the existing D-LR allocation.
# Source mml-stages and lr-pcm-boundary first. Boundary calculations are
# numerical qualifications, not public fits or a proof of a global maximum.

dlr_pcm_rule <- function() list(
  version='PCM-LR-interior-v1-events', orders=c(31L,61L,121L),
  optimizer='BFGS', maxit=400L, reltol=1e-12, level=.95,
  structural_targets=c('1','2','3','1-2'),
  boundary=list(start=rep(0,12L), gradtol=1e-11, steptol=1e-12,
    iterlim=1000L, score=1e-6, scaled_score=1e-7,
    moment=1e-9, mass=1e-12, gap=1e-8, polish_step=1e-5, likelihood_margin=1e-6),
  retry='Only the existing finite integration-only failure; no truth-based choice.',
  failure='Keep points and all attempted stages; unavailable outputs stay in the denominator.',
  repeated_events='Allocated paired-L2 events require the explicit independent declaration before fitting.',
  scope='PCM, ~X, three centered raters/criteria, four categories, allocated exposure views; other models remain separate.')

dlr_pcm_zero <- function(ctx, rule=dlr_pcm_rule()$boundary) {
  objective <- function(eta) {
    z <- dlr_pcm_boundary_eval(ctx,eta)
    value <- z$value/ctx$persons
    attr(value,'gradient') <- z$gradient/ctx$persons
    attr(value,'hessian') <- z$hessian/ctx$persons
    value
  }
  opt <- stats::nlm(objective,rule$start,gradtol=rule$gradtol,
    steptol=rule$steptol,iterlim=rule$iterlim,check.analyticals=TRUE)
  eta <- opt$estimate; z <- dlr_pcm_boundary_eval(ctx,eta)
  # One retained Newton correction addresses objective-roundoff termination;
  # it never changes the positive-variance public fit.
  correction <- solve(z$hessian,z$gradient)
  candidate <- dlr_pcm_boundary_eval(ctx,eta-correction)
  polished <- max(abs(correction)) < rule$polish_step && all(is.finite(candidate$gradient)) &&
    max(abs(candidate$gradient)) < max(abs(z$gradient)) &&
    candidate$value <= z$value+rule$gap
  if (polished) { eta <- eta-correction; z <- candidate }
  direction <- solve(z$hessian,z$gradient)
  dual <- z$probability
  for (k in 1:4) dual[,k] <- dual[,k]*(1-as.vector(z$centered[[k]] %*% direction))
  residual <- colSums(Reduce('+',lapply(1:4,function(k) ctx$design[[k]]*dual[,k]))-
    ctx$observed)
  entropy <- if (all(is.finite(dual)) && all(dual > 0)) -sum(dual*log(dual)) else NA_real_
  checks <- c(optimizer_or_refinement=opt$code %in% c(1L,2L) || (opt$code==3L && polished),
    information=!is.null(tryCatch(chol(z$hessian),error=function(e) NULL)),
    stationarity=max(abs(z$gradient)) <= rule$score &&
      sqrt(abs(sum(z$gradient*direction))) <= rule$scaled_score,
    dual=all(is.finite(dual)) && all(dual > 0) &&
      max(abs(residual)) <= rule$moment && max(abs(rowSums(dual)-1)) <= rule$mass &&
      is.finite(entropy) && abs(z$value-entropy) <= rule$gap)
  info <- dlr_pcm_boundary_information(ctx,z)
  list(qualified=all(checks),checks=checks,opt=opt,eta=eta,polished=polished,
    newton_step=max(abs(correction)),
    nll=z$value,entropy_nll=entropy,score=max(abs(z$gradient)),
    moment_residual=max(abs(residual)),mass_residual=max(abs(rowSums(dual)-1)),
    dual_gap=z$value-entropy,minimum_probability=min(dual),
    natural_variance_score=info$natural_variance_score,
    reason=if(all(checks)) '' else paste(names(checks)[!checks],collapse='; '))
}

dlr_pcm_boundary_decision <- function(zero, interior, rule=dlr_pcm_rule()$boundary) {
  if (!isTRUE(zero$qualified)) return(list(eligible=FALSE,status='boundary_unresolved',
    gain=NA_real_,reason=paste('Zero-variance nuisance qualification failed:',zero$reason)))
  # The continuous likelihood is independent of the fitted Hermite grid.
  error <- interior$summed_relative_error
  gain <- min(zero$nll,zero$entropy_nll)-interior$value
  eligible <- is.finite(gain) && is.finite(error) && error >= 0 &&
    gain > rule$likelihood_margin+error
  list(eligible=eligible,status=if(eligible) 'zero_variance_dominated' else 'boundary_unresolved',
    gain=gain,continuous_error=error,
    reason=if(eligible) '' else paste('The retained interior point has not numerically excluded',
      'the zero-variance likelihood optimum; no interior interval/source is selected.'))
}

dlr_pcm_validate <- function(spec) {
  a <- spec$args; r <- dlr_pcm_rule()
  stopifnot(all(c('ConditionId','Arm','Replicate','InputId','args','purpose') %in% names(spec)),
    a$model=='PCM',a$method=='MML',identical(a$facets,c('Rater','Criterion')),
    a$step_facet=='Criterion',identical(as.character(a$population_formula),c('~','X')),
    identical(environment(a$population_formula),baseenv()),
    a$person=='Person',a$person_id=='Person',a$population_policy=='error',
    a$score=='Score',a$rating_min==0,a$rating_max==3,a$category_policy=='preserve',
    a$mml_engine=='direct',a$mml_integration=='fixed',a$optimizer==r$optimizer,
    a$maxit==r$maxit,a$reltol==r$reltol,is.null(a$quad_points),is.null(a$contrasts),
    is.null(a$anchors),is.null(a$weight),is.null(a$interactions),
    is.data.frame(a$data),is.data.frame(a$person_data))
  if(anyDuplicated(a$data[c(a$person,a$facets)]))
    stopifnot(identical(a$repeated_ratings,'independent'))
  invisible(TRUE)
}

dlr_pcm_interval <- function(fit,level) {
  C <- rbind(diag(3),c(1,-1,0));dimnames(C) <- list(c('1','2','3','1-2'),as.character(1:3))
  mfrmr::mfrm_facet_intervals(fit,'Criterion',contrasts=C,level=level)
}

dlr_pcm_stages <- function(spec,out) {
  dlr_pcm_validate(spec); rule <- dlr_pcm_rule(); runtime <- wide_mml_runtime()
  runtime$lr_sources <- tools::md5sum(c(
    'inst/validation/mfrm-wide-map-lr-pcm-stages-20261004.R',
    'inst/validation/mfrm-wide-map-lr-pcm-boundary-20261002.R'))
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  manifest <- list(spec=spec,rule=rule,runtime=runtime)
  sealed <- wide_mml_phase(file.path(out,'manifest.rds'),rule$version,function()manifest)
  stopifnot(identical(sealed,manifest)); identity <- wide_mml_hash(manifest)
  phase <- 'start'; q <- 31L; finished <- FALSE
  state <- function(status) wide_mml_save(list(identity=identity,status=status,
    phase=phase,order=q,time=Sys.time()),file.path(out,'status.rds'))
  on.exit(if(!finished) state('interrupted'),add=TRUE)
  run <- function(name,dependency,call) {
    phase <<- name; state('running')
    wide_mml_phase(file.path(out,paste0('q',q,'-',name,'.rds')),
      list(job=identity,order=q,phase=name,dependency=dependency),call)
  }
  need_point <- need_interval <- TRUE; point <- interval <- NULL; stages <- list()
  zero <- initial <- NULL
  for(order in rule$orders) {
    q <- order
    fitting <- run('fit',NULL,function() wide_mml_capture(function()
      wide_mml_fit(c(spec$args,list(quad_points=q)))))
    fit <- fitting$value; fh <- wide_mml_hash(fitting)
    stage <- list(order=q,fit_hash=fh,fit_error=fitting$error)
    candidate <- list(order=q,fit_hash=fh,error=fitting$error,value=NULL,eligible=FALSE)
    if(nzchar(fitting$error)) {
      if(need_point) point <- candidate
      if(need_interval) interval <- candidate
      if(q==31L) initial <- list(point=point,interval=interval)
      stages[[as.character(q)]] <- stage; break
    }
    stopifnot(inherits(fit,'mfrm_fit'),fit$config$estimation_control$quad_points==q)
    ctx <- dlr_pcm_boundary_context(fit)
    if(is.null(zero)) zero <- run('zero-variance',fh,function()
      wide_mml_capture(function() dlr_pcm_zero(ctx,rule$boundary)))
    boundary <- run('boundary-review',list(fit=fh,zero=wide_mml_hash(zero)),function()
      wide_mml_capture(function() {
        if(nzchar(zero$error)) return(list(eligible=FALSE,status='boundary_unresolved',
          reason=zero$error,gain=NA_real_))
        if(!isTRUE(zero$value$qualified)) return(dlr_pcm_boundary_decision(zero$value,NULL,rule$boundary))
        value <- dlr_pcm_continuous_value(ctx,fit$opt$par[1:12],fit$population$sigma2)
        c(dlr_pcm_boundary_decision(zero$value,value,rule$boundary),list(interior=value))
      }))
    boundary_ok <- !nzchar(boundary$error) && isTRUE(boundary$value$eligible)
    candidate$boundary <- boundary
    retry_point <- retry_interval <- FALSE
    if(need_point) {
      review <- run('scoring-source',fh,function()wide_mml_capture(function()wide_mml_score(fit)))
      point <- c(candidate,list(review=review))
      point$eligible <- boundary_ok && !nzchar(review$error) && isTRUE(review$value$ready)
      retry_point <- !nzchar(review$error) && wide_mml_scoring_retry(review$value)
      need_point <- retry_point && q < max(rule$orders)
    }
    if(need_interval) {
      ci <- run('interval',fh,function()wide_mml_capture(function()dlr_pcm_interval(fit,rule$level)))
      pop <- run('population-interval',wide_mml_hash(ci),function()wide_mml_capture(function() {
        if(nzchar(ci$error)) stop(ci$error)
        mfrmr::mfrm_population_intervals(ci$value,level=rule$level)
      }))
      interval <- c(candidate,list(structural=ci,population=pop))
      interval$eligible <- boundary_ok && !nzchar(ci$error) && !nzchar(pop$error) &&
        all(ci$value$table$CIEligible) && all(pop$value$table$CIEligible)
      retry_interval <- !nzchar(ci$error) && wide_mml_interval_retry(ci$value)
      need_interval <- retry_interval && q < max(rule$orders)
    }
    stage$boundary <- boundary; stage$retry_point <- retry_point; stage$retry_interval <- retry_interval
    stages[[as.character(q)]] <- stage
    if(q==31L) initial <- list(point=point,interval=interval)
    if(!need_point && !need_interval) break
  }
  stopifnot(identical(runtime$source,wide_mml_runtime()$source),
    identical(runtime$lr_sources,tools::md5sum(names(runtime$lr_sources))))
  result <- list(identity=identity,spec_hash=wide_mml_hash(spec),point=point,
    interval=interval,initial=initial,zero=zero,stages=stages,purpose=spec$purpose)
  saved <- wide_mml_phase(file.path(out,'selected.rds'),identity,function()result)
  stopifnot(identical(saved,result)); phase <- 'complete'; state('complete'); finished <- TRUE
  saved
}

# Exactly seven planned targets remain present even when a call fails. Public
# tables are preserved separately; study eligibility also requires the
# zero-variance review and must not overwrite the public object's status.
dlr_pcm_records <- function(spec,selected,out,rule='refinement') {
  stopifnot(identical(selected$spec_hash,wide_mml_hash(spec)))
  structural <- dlr_pcm_rule()$structural_targets
  targets <- c(paste0('Criterion:',structural),'beta:(Intercept)','beta:X','log_residual_variance')
  rows <- lapply(c('point','interval'),function(output) {
    x <- selected[[output]]
    z <- data.frame(ConditionId=spec$ConditionId,Arm=spec$Arm,Replicate=spec$Replicate,
      Target=targets,Output=output,Rule=rule,Order=x$order,Available=FALSE,
      Estimate=NA_real_,SE=NA_real_,Lower=NA_real_,Upper=NA_real_,
      BoundaryStatus=if(is.null(x$boundary)) 'not_evaluated' else
        if(is.null(x$boundary$value$status)) 'boundary_error' else x$boundary$value$status,Reason=x$error)
    fitting <- readRDS(file.path(out,paste0('q',x$order,'-fit.rds')))$payload
    fit <- fitting$value
    if(!is.null(fit)) {
      locations <- fit$facets$others[fit$facets$others$Facet=='Criterion',]
      estimates <- locations$Estimate[match(as.character(1:3),locations$Level)]
      z$Estimate <- c(estimates,estimates[1]-estimates[2],
        unname(fit$population$coefficients[c('(Intercept)','X')]),log(fit$population$sigma2))
    }
    if(output=='interval' && !is.null(x$structural$value) && !is.null(x$population$value)) {
      s <- x$structural$value$table; p <- x$population$value$table
      s <- s[match(structural,s$Target),]; p <- p[match(targets[5:7],p$Target),]
      stopifnot(!anyNA(s$Target),!anyNA(p$Target))
      z$Estimate <- c(s$Estimate,p$WorkingEstimate)
      if(isTRUE(x$eligible)) {
        z$SE <- c(s$SE,p$WorkingSE);z$Lower <- c(s$Lower,p$WorkingLower)
        z$Upper <- c(s$Upper,p$WorkingUpper)
      }
    }
    z$Available <- isTRUE(x$eligible) & is.finite(z$Estimate)
    if(!isTRUE(x$eligible)) {
      reasons <- c(x$error,x$boundary$error,x$boundary$value$reason,
        x$review$error,x$review$value$reason_codes,x$review$value$local_calibration_review$review,
        x$structural$error,x$population$error)
      if(!is.null(x$structural$value)) reasons <- c(reasons,
        x$structural$value$table$InferenceReview[!x$structural$value$table$CIEligible])
      z$Reason <- paste(unique(reasons[!is.na(reasons) & nzchar(reasons)]),collapse='; ')
    }
    z
  })
  refined <- do.call(rbind,rows)
  if(rule=='default') return(refined)
  initial <- selected; initial$point <- selected$initial$point; initial$interval <- selected$initial$interval
  rbind(dlr_pcm_records(spec,initial,out,'default'),refined)
}
