# Repository-only RSM population-interval/source selection. Source the shared
# mml-stages and RSM boundary modules first. No truth or random draws are used.
rsm_lr_rule <- function() list(
  version='RSM-LR-interior-v1', orders=c(61L,121L),
  optimizer='BFGS', maxit=400L, reltol=1e-12, level=.95,
  boundary=rsm_lr_boundary_rule(),
  retry='One fresh neutral q121 fit, only for a finite integration-only failure after boundary qualification.',
  failure='Keep points, target-specific refusals and every attempted stage; no fallback to an earlier failed interval.',
  scope='RSM, ~X, centered Rater/Criterion, three/four categories, unit weights, no repeated events; broader designs remain separate.')

rsm_lr_contrasts <- function() {
  L <- rbind(mean_at_minus1=c(1,-1),mean_at_plus1=c(1,1),difference=c(0,2))
  colnames(L) <- c('(Intercept)','X'); L
}

rsm_lr_validate <- function(spec) {
  a <- spec$args; r <- rsm_lr_rule()
  required <- c('data','person','facets','score','model','method','population_formula',
    'person_data','person_id','population_policy','rating_min','rating_max','category_policy',
    'mml_engine','mml_integration','optimizer','maxit','reltol')
  stopifnot(all(c('ConditionId','Arm','Replicate','InputId','args','purpose') %in% names(spec)),
    setequal(names(a),required),!anyDuplicated(names(a)),a$model=='RSM',a$method=='MML',
    identical(a$facets,c('Rater','Criterion')),is.null(a$step_facet),
    identical(as.character(a$population_formula),c('~','X')),
    identical(environment(a$population_formula),baseenv()),
    a$person=='Person',a$person_id=='Person',a$population_policy=='error',a$score=='Score',
    a$rating_min==0,a$rating_max %in% c(2L,3L),a$category_policy=='preserve',
    a$mml_engine=='direct',a$mml_integration=='fixed',a$optimizer==r$optimizer,
    a$maxit==r$maxit,a$reltol==r$reltol,is.null(a$quad_points),is.null(a$contrasts),
    is.null(a$anchors),is.null(a$weight),is.null(a$interactions),is.null(a$noncenter_facet),
    is.data.frame(a$data),is.data.frame(a$person_data),
    !anyDuplicated(a$data[c(a$person,a$facets)]))
  invisible(TRUE)
}

rsm_lr_score <- function(fit,covariance=NULL) {
  mfrmr:::prediction_source_scoring_readiness(fit,covariance=covariance)
}

rsm_lr_interval <- function(fit,level,covariance=NULL) {
  mfrmr:::mfrm_population_intervals_impl(fit,level=level,
    contrasts=rsm_lr_contrasts(),covariance=covariance)
}

rsm_lr_interval_retry <- function(x) {
  # Population intervals use the same full native information qualification.
  identical(x$settings$procedure,'mml_normal_population_model_v1') &&
    wide_mml_interval_retry(list(settings=list(procedure='mml_native_location_model_v1'),
      checks=x$checks,numerical_checks=x$numerical_checks))
}

rsm_lr_stages <- function(spec,out,initial=NULL) {
  rsm_lr_validate(spec); rule <- rsm_lr_rule(); runtime <- wide_mml_runtime()
  runtime$lr_sources <- tools::md5sum(c('inst/validation/mfrm-lr-rsm-stages-20261009.R',
    'inst/validation/mfrm-lr-rsm-boundary-20261009.R'))
  # Audited imports exercise orchestration; they never become new sampling units.
  if(!is.null(initial)) stopifnot(spec$purpose=='workflow_witness_only',
    identical(initial$args,c(spec$args,list(quad_points=rule$orders[1L]))),
    length(initial$provenance)>0L,all(c('fit','zero','interior','population') %in% names(initial)),
    inherits(initial$fit$value,'mfrm_fit'),!nzchar(initial$fit$error),
    identical(initial$population$value$fit,initial$fit$value),
    identical(initial$population$value$contrasts,rsm_lr_contrasts()),
    initial$population$value$settings$level==rule$level)
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  manifest <- list(spec=spec,rule=rule,contrasts=rsm_lr_contrasts(),runtime=runtime,initial=initial)
  saved <- wide_mml_phase(file.path(out,'manifest.rds'),rule$version,function()manifest)
  stopifnot(identical(saved,manifest)); identity <- wide_mml_hash(manifest)
  phase <- 'start'; q <- rule$orders[1L]; finished <- FALSE
  state <- function(status) wide_mml_save(list(identity=identity,status=status,
    phase=phase,order=q,time=Sys.time()),file.path(out,'status.rds'))
  on.exit(if(!finished) state('interrupted'),add=TRUE)
  run <- function(name,dependency,call) {
    phase <<- name; state('running')
    wide_mml_phase(file.path(out,paste0('q',q,'-',name,'.rds')),
      list(job=identity,order=q,phase=name,dependency=dependency),function() {
        if(q==rule$orders[1L] && name %in% names(initial)) initial[[name]] else wide_mml_capture(call)
      })
  }
  need_point <- need_interval <- TRUE; point <- interval <- zero <- first <- NULL; stages <- list()
  for(order in rule$orders) {
    q <- order
    fitting <- run('fit',NULL,function()wide_mml_fit(c(spec$args,list(quad_points=q))))
    fit <- fitting$value; fh <- wide_mml_hash(fitting)
    candidate <- list(order=q,fit_hash=fh,error=fitting$error,boundary=NULL)
    stage <- list(order=q,fit_hash=fh,fit_error=fitting$error)
    if(nzchar(fitting$error)) {
      if(need_point) point <- c(candidate,list(eligible=FALSE))
      if(need_interval) interval <- candidate
      stages[[as.character(q)]] <- stage
      if(q==rule$orders[1L]) first <- list(point=point,interval=interval)
      break
    }
    stopifnot(inherits(fit,'mfrm_fit'),fit$config$estimation_control$quad_points==q)
    covariance <- mfrmr:::mfrm_mml_covariance_reuse(fit)
    context <- wide_mml_capture(function()rsm_lr_boundary_context(fit))
    if(is.null(zero)) zero <- run('zero',fh,function() {
      if(nzchar(context$error)) stop(context$error)
      rsm_lr_boundary_zero(context$value,rule$boundary)
    })
    interior <- run('interior',fh,function() {
      if(nzchar(context$error)) stop(context$error)
      rsm_lr_continuous_value(context$value,head(fit$opt$par,-1L),fit$population$sigma2)
    })
    boundary <- run('boundary-review',c(wide_mml_hash(zero),wide_mml_hash(interior)),function() {
      if(nzchar(zero$error)) stop(zero$error)
      if(nzchar(interior$error)) stop(interior$error)
      rsm_lr_boundary_decision(zero$value,interior$value,rule$boundary)
    })
    boundary_ok <- !nzchar(boundary$error) && isTRUE(boundary$value$eligible)
    candidate$boundary <- boundary
    retry_point <- retry_interval <- FALSE
    if(need_point) {
      review <- run('scoring-source',fh,function()rsm_lr_score(fit,covariance))
      point <- c(candidate,list(review=review,
        eligible=boundary_ok && !nzchar(review$error) && isTRUE(review$value$ready)))
      retry_point <- boundary_ok && !nzchar(review$error) && wide_mml_scoring_retry(review$value)
      need_point <- retry_point && q<max(rule$orders)
    }
    if(need_interval) {
      ci <- run('population',fh,function()rsm_lr_interval(fit,rule$level,covariance))
      interval <- c(candidate,list(population=ci))
      retry_interval <- boundary_ok && !nzchar(ci$error) && rsm_lr_interval_retry(ci$value)
      need_interval <- retry_interval && q<max(rule$orders)
    }
    stage$boundary <- boundary;stage$retry_point <- retry_point;stage$retry_interval <- retry_interval
    stages[[as.character(q)]] <- stage
    if(q==rule$orders[1L]) first <- list(point=point,interval=interval)
    if(!need_point && !need_interval) break
  }
  stopifnot(identical(runtime$source,wide_mml_runtime()$source),
    identical(runtime$lr_sources,tools::md5sum(names(runtime$lr_sources))))
  result <- list(identity=identity,spec_hash=wide_mml_hash(spec),point=point,interval=interval,
    initial=first,zero=zero,stages=stages,purpose=spec$purpose)
  saved <- wide_mml_phase(file.path(out,'selected.rds'),identity,function()result)
  stopifnot(identical(saved,result));phase <- 'complete';state('complete');finished <- TRUE
  saved
}

rsm_lr_records <- function(spec,selected,out) {
  stopifnot(identical(selected$spec_hash,wide_mml_hash(spec)))
  L <- rsm_lr_contrasts()
  targets <- c('beta:(Intercept)','beta:X',paste0('contrast:',rownames(L)),'log_residual_variance')
  reason <- function(x) paste(unique(x[!is.na(x) & nzchar(x)]),collapse='; ')
  rows <- lapply(c('initial','selected'),function(selection) {
    source <- if(selection=='initial') selected$initial else selected
    do.call(rbind,lapply(c('point','interval'),function(output) {
      x <- source[[output]]
      path <- file.path(out,paste0('q',x$order,'-fit.rds'))
      saved <- readRDS(path)
      stopifnot(identical(saved$checksum,x$fit_hash),identical(saved$checksum,wide_mml_hash(saved$payload)),
        identical(saved$binding,list(job=selected$identity,order=x$order,phase='fit',dependency=NULL)))
      fit <- saved$payload$value
      z <- data.frame(ConditionId=spec$ConditionId,Arm=spec$Arm,Replicate=spec$Replicate,
        Purpose=spec$purpose,Target=targets,Output=if(output=='point') 'scoring_source' else 'interval',
        Selection=selection,Order=x$order,Available=FALSE,Estimate=NA_real_,SE=NA_real_,
        Lower=NA_real_,Upper=NA_real_,BoundaryStatus=if(is.null(x$boundary)) 'not_evaluated' else
          if(nzchar(x$boundary$error)) 'boundary_error' else x$boundary$value$status,Reason=x$error)
      if(!is.null(fit)) {
        b <- unname(fit$population$coefficients[colnames(L)])
        z$Estimate <- c(b,drop(L %*% b),log(fit$population$sigma2))
      }
      common <- reason(c(x$error,x$boundary$error,x$boundary$value$reason))
      if(output=='point') {
        z$Available <- isTRUE(x$eligible) & is.finite(z$Estimate)
        z$Reason <- reason(c(common,x$review$error,x$review$value$reason_codes,
          if(!isTRUE(x$eligible)) x$review$value$local_calibration_review$review))
      } else {
        z$Reason <- reason(c(common,x$population$error))
        if(!is.null(x$population$value)) {
          tab <- x$population$value$table
          tab <- tab[match(targets,tab$Target),];stopifnot(!anyNA(tab$Target))
          z$Estimate <- tab$WorkingEstimate
          z$Available <- isTRUE(x$boundary$value$eligible) & !nzchar(x$boundary$error) &
            tab$CIEligible %in% TRUE & is.finite(tab$WorkingEstimate)
          z$SE <- ifelse(z$Available,tab$WorkingSE,NA_real_)
          z$Lower <- ifelse(z$Available,tab$WorkingLower,NA_real_)
          z$Upper <- ifelse(z$Available,tab$WorkingUpper,NA_real_)
          for(i in which(!z$Available)) z$Reason[i] <- reason(c(z$Reason[i],
            if(!isTRUE(tab$CIEligible[i])) tab$InferenceReview[i]))
        }
      }
      z$Reason[z$Available] <- ''
      z
    }))
  })
  do.call(rbind,rows)
}
