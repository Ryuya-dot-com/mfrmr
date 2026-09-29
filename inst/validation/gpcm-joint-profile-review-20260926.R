# Review retained profile vectors; no optimization or selection of a new fit.
review_gpcm_joint_profile <- function(output_dir) {
  source('inst/validation/adaptive-quadrature-review-0.2.4.R', local = TRUE)
  fits <- list(shared = readRDS('validation-results/gpcm-probability-refit-20260925/refit-788.rds')$fit,
    separate = readRDS('validation-results/portable-gpcm-development-probe.rds')$review$fits$q41)
  rows <- read.csv(file.path(output_dir,'rows.csv'))
  plan <- read.csv(file.path(output_dir,'plan.csv'))
  write.csv(plan[!plan$Id %in% rows$Id,],file.path(output_dir,'unexecuted.csv'),row.names=FALSE)
  profile <- rows[rows$Target != 'unconstrained',]
  groups <- split(profile,paste(profile$Owner,profile$Target,profile$Offset))
  paired <- do.call(rbind,lapply(groups,function(d) {
    valid <- d$Returned & d$NuisancePass & is.finite(d$CommonNLL)
    data.frame(Owner=d$Owner[1],Target=d$Target[1],Offset=d$Offset[1],
      Attempts=nrow(d),NuisanceQualified=sum(valid),
      BothIntegrationStable=all(valid) && nrow(d)==2 && all(d$IntegrationDifference<=1e-5),
      CommonNLLDifference=if(all(valid) && nrow(d)==2) diff(range(d$CommonNLL)) else NA_real_,
      LowestQualifiedNLL=if(any(valid))min(d$CommonNLL[valid]) else NA_real_)
  }))
  write.csv(paired,file.path(output_dir,'paired.csv'),row.names=FALSE)
  reference <- list()
  for (owner in names(fits)) {
    f<-fits[[owner]]; cfg<-f$config; sizes<-mfrmr:::build_param_sizes(cfg)
    idx<-mfrmr:::build_indices(f$prep,cfg$step_facet,cfg$slope_facet,cfg$interaction_specs)
    d<-rows[rows$Owner==owner,]
    select<-list(baseline=d[d$Target=='unconstrained',])
    for(target in c('log_variance','first_log_relative_slope')) {
      offsets<-if(target=='log_variance')c(-4,4) else c(-3,3)
      for(offset in offsets) select[[paste(target,offset)]]<-d[d$Target==target & d$Offset==offset,]
    }
    for(key in names(select)) {
      cand<-select[[key]]; cand<-cand[cand$NuisancePass & is.finite(cand$CommonNLL),]
      if(!nrow(cand)) {
        reference[[paste(owner,key)]]<-data.frame(Owner=owner,Point=key,Id=NA_character_,
          Qualified=FALSE,ContinuousNLL=NA_real_,CommonNLL=NA_real_,Difference=NA_real_,
          MaxRefinementChange=NA_real_,MaxRelativeError=NA_real_,MaxLogTailBound=NA_real_,Detail='No qualified nuisance result')
        next
      }
      cand<-cand[which.min(cand$CommonNLL),]
      cat('continuous reference:',owner,key,cand$Id,'\n');flush.console()
      p<-readRDS(file.path(output_dir,paste0(cand$Id,'.rds')))$result$selected$full
      pars<-mfrmr:::expand_params(p,sizes,cfg)
      base<-mfrmr:::compute_base_eta(idx,pars,cfg)
      mu<-unname(pars$population$coefficients[1]);sigma<-sqrt(pars$population$sigma2)
      reference_path <- file.path(output_dir,paste0('continuous-',cand$Id,'.rds'))
      results<-if(file.exists(reference_path)) readRDS(reference_path) else tryCatch(lapply(c(32,64),function(limit) do.call(rbind,lapply(split(seq_along(idx$person),idx$person),function(obs) {
        aq_continuous_reference(idx$score_k[obs],base[obs],pars$steps_mat[idx$step_idx[obs],,drop=FALSE],
          pars$slopes[idx$slope_idx[obs]],idx$weight[obs],mu,sigma,limit)
      }))),error=identity)
      if(inherits(results,'error')) {
        reference[[paste(owner,key)]]<-data.frame(Owner=owner,Point=key,Id=cand$Id,
          Qualified=FALSE,ContinuousNLL=NA_real_,CommonNLL=cand$CommonNLL,Difference=NA_real_,
          MaxRefinementChange=NA_real_,MaxRelativeError=NA_real_,MaxLogTailBound=NA_real_,Detail=conditionMessage(results))
        write.csv(do.call(rbind,reference),file.path(output_dir,'continuous-reference.csv'),row.names=FALSE)
        next
      }
      change<-max(abs(results[[1]][,1:3]-results[[2]][,1:3]))
      error<-max(results[[2]][,'relative_error']); tail<-max(results[[2]][,'log_relative_tail_bound'])
      nll<- -sum(results[[2]][,'log_marginal'])
      qualified<-all(is.finite(results[[2]])) && change<1e-8 && error<1e-9 && tail<log(1e-12)
      reference[[paste(owner,key)]]<-data.frame(Owner=owner,Point=key,Id=cand$Id,
        Qualified=qualified,ContinuousNLL=nll,CommonNLL=cand$CommonNLL,Difference=cand$CommonNLL-nll,
        MaxRefinementChange=change,MaxRelativeError=error,MaxLogTailBound=tail,Detail='')
      saveRDS(results,file.path(output_dir,paste0('continuous-',cand$Id,'.rds')))
      write.csv(do.call(rbind,reference),file.path(output_dir,'continuous-reference.csv'),row.names=FALSE)
    }
  }
  write.csv(do.call(rbind,reference),file.path(output_dir,'continuous-reference.csv'),row.names=FALSE)
  print(paired); print(do.call(rbind,reference))
  invisible(list(paired=paired,reference=reference))
}

# Separate follow-up for failed nuisance stationarity; original rows stay intact.
# One existing curvature proposal per returned failed point, no iteration ladder.
review_gpcm_profile_curvature <- function(output_dir, max_elapsed_seconds = 60) {
  rows <- read.csv(file.path(output_dir,'rows.csv'))
  failed <- rows[rows$Returned & !rows$NuisancePass & rows$Target!='unconstrained',]
  fits <- list(shared=readRDS('validation-results/gpcm-probability-refit-20260925/refit-788.rds')$fit,
    separate=readRDS('validation-results/portable-gpcm-development-probe.rds')$review$fits$q41)
  result_path <- file.path(output_dir,'curvature-review.csv')
  result <- if(file.exists(result_path)) {
    prior <- read.csv(result_path, na.strings='NA'); split(prior,prior$Id)
  } else list()
  started <- proc.time()[['elapsed']]
  for(i in seq_len(nrow(failed))) {
    if(failed$Id[i] %in% names(result)) next
    if(proc.time()[['elapsed']]-started>max_elapsed_seconds) break
    row<-failed[i,]; saved<-readRDS(file.path(output_dir,paste0(row$Id,'.rds')))
    ctx<-gjp_context(fits[[row$Owner]],31L); dense<-gjp_context(fits[[row$Owner]],61L)
    p<-saved$result$selected$full; free<-setdiff(seq_along(p),row$Index)
    embed<-function(z) { ans<-p; ans[free]<-z; ans }
    fn<-function(z)ctx$evaluator$value(embed(z))
    gr<-function(z)ctx$evaluator$gradient(embed(z))[free]
    step<-mfrmr:::mfrm_optimizer_curvature_proposal(p[free],fn,gr)
    out<-data.frame(Id=row$Id,Owner=row$Owner,OriginalGradient=row$Gradient,
      Proposed=!is.null(step$par),Gradient=NA_real_,ObjectiveChange=NA_real_,
      IntegrationDifference=NA_real_,StationarityPass=FALSE,Detail=step$error)
    if(!is.null(step$par)) {
      final<-embed(step$par); gradient<-ctx$evaluator$gradient(final)[free]
      out$Gradient<-max(abs(gradient));out$ObjectiveChange<-ctx$evaluator$value(final)-row$OwnNLL
      out$IntegrationDifference<-abs(ctx$evaluator$value(final)-dense$evaluator$value(final))
      out$StationarityPass<-all(is.finite(gradient)) && out$Gradient<=1e-4
    } else final<-NULL
    saveRDS(list(original=saved,row=out,proposal=step,parameters=final),
      file.path(output_dir,paste0('curvature-',row$Id,'.rds')))
    result[[row$Id]]<-out
  }
  write.csv(failed[!failed$Id %in% names(result),],file.path(output_dir,'curvature-unexecuted.csv'),row.names=FALSE)
  if(length(result))write.csv(do.call(rbind,result),file.path(output_dir,'curvature-review.csv'),row.names=FALSE)
  if(length(result))print(do.call(rbind,result))
  invisible(result)
}

# Replay only an observed failed search to preserve the offending trial vector.
# This does not rescue the search or change any numerical acceptance threshold.
diagnose_gpcm_profile_failure <- function(output_dir, id = 'profile-44') {
  original <- readRDS(file.path(output_dir,paste0(id,'.rds')))
  stopifnot(!original$row$Returned, original$spec$Owner == 'separate')
  fit <- readRDS('validation-results/portable-gpcm-development-probe.rds')$review$fits$q41
  ctx <- gjp_context(fit,31L); errors <- list()
  capture <- function(fun) function(p) tryCatch(fun(p),error=function(e) {
    if(conditionMessage(e) %in% vapply(original$result$stages,`[[`,'','error'))
      errors[[length(errors)+1L]] <<- list(parameters=p+0,error=conditionMessage(e))
    stop(e)
  })
  ev <- list(value=capture(ctx$evaluator$value),gradient=capture(ctx$evaluator$gradient))
  start <- if(original$spec$Start == 'neutral') rep(0,length(fit$opt$par)) else fit$opt$par
  result <- gjp_fit(ev,start,original$spec$Index,original$spec$Value)
  details <- lapply(errors,function(e) {
    p <- mfrmr:::expand_params(e$parameters,ctx$sizes,ctx$config)
    list(error=e$error,parameters=e$parameters,population=p$population,slopes=p$slopes,
      squared_slopes_finite=all(is.finite(p$slopes^2)))
  })
  saveRDS(list(original=original,result=result,errors=details),
    file.path(output_dir,paste0('failure-replay-',id,'.rds')))
  print(details)
  invisible(details)
}

# Fixed, failure-driven repair checks. Original grid results are never replaced.
repair_gpcm_joint_profiles <- function(original_dir) {
  out <- file.path(original_dir,'repairs')
  stopifnot(!dir.exists(out)); dir.create(out)
  saveRDS(list(source=tools::md5sum(c(list.files('R','[.]R$',full.names=TRUE),
    'inst/validation/gpcm-joint-profile-review-20260926.R',
    'inst/validation/gpcm-joint-profile-20260926.md')),session=sessionInfo()),file.path(out,'manifest.rds'))
  fits <- list(shared=readRDS('validation-results/gpcm-probability-refit-20260925/refit-788.rds')$fit,
    separate=readRDS('validation-results/portable-gpcm-development-probe.rds')$review$fits$q41)
  rows <- list()
  for(id in c('profile-44','profile-14','profile-42')) {
    cat('repair:',id,'\n'); flush.console()
    old <- readRDS(file.path(original_dir,paste0(id,'.rds')))
    fit <- fits[[old$spec$Owner]]; ctx <- gjp_context(fit,31L)
    if(id=='profile-44') {
      result <- gjp_fit(ctx$evaluator,rep(0,length(fit$opt$par)),old$spec$Index,old$spec$Value)
      p <- if(is.null(result$selected)) NULL else result$selected$full
      curvature <- NULL
    } else {
      origin <- old$result$selected$full; free <- setdiff(seq_along(origin),old$spec$Index)
      embed <- function(z) { p<-origin;p[free]<-z;p }
      fn <- function(z)ctx$evaluator$value(embed(z))
      gr <- function(z)ctx$evaluator$gradient(embed(z))[free]
      curvature <- mfrmr:::mfrm_optimizer_curvature_scale(origin[free],fn,gr)
      stopifnot(!is.null(curvature$transform))
      native <- function(z)embed(origin[free]+drop(curvature$transform %*% z))
      safe <- mfrmr:::make_mfrm_boundary_safe_objective(ctx$evaluator)
      result <- gjp_fit(list(value=function(z)safe$value(native(z)),
        gradient=function(z)drop(crossprod(curvature$transform,safe$gradient(native(z))[free]))),
        rep(0,length(free)))
      p <- if(is.null(result$selected)) NULL else native(result$selected$full)
    }
    row <- data.frame(Id=id,Returned=!is.null(p),NLL=NA_real_,Gradient=NA_real_,
      IntegrationDifference=NA_real_,StationarityPass=FALSE)
    if(!is.null(p)) {
      free <- setdiff(seq_along(p),old$spec$Index)
      row$NLL <- ctx$evaluator$value(p)
      row$Gradient <- max(abs(ctx$evaluator$gradient(p)[free]))
      row$IntegrationDifference <- abs(row$NLL-gjp_context(fit,61L)$evaluator$value(p))
      row$StationarityPass <- result$selected$opt$convergence==0L && row$Gradient<=1e-4
    }
    saveRDS(list(original=old,result=result,parameters=p,curvature=curvature,row=row),file.path(out,paste0(id,'.rds')))
    rows[[id]]<-row;write.csv(do.call(rbind,rows),file.path(out,'searches.csv'),row.names=FALSE)
  }
  # Higher-order evaluation only: no automatic refit or grid expansion.
  integration <- list()
  for(id in c('profile-07','profile-20','profile-21')) {
    old <- readRDS(file.path(original_dir,paste0(id,'.rds')))
    fit <- fits[[old$spec$Owner]];p<-old$result$selected$full
    for(order in c(61L,121L,201L,301L)) {
      cat('integration:',id,order,'\n');flush.console()
      ctx<-gjp_context(fit,order)
      integration[[paste(id,order)]]<-data.frame(Id=id,Order=order,NLL=ctx$evaluator$value(p),
        Gradient=max(abs(ctx$evaluator$gradient(p)[-old$spec$Index])))
      write.csv(do.call(rbind,integration),file.path(out,'integration.csv'),row.names=FALSE)
    }
  }
  invisible(rows)
}

review_gpcm_repaired_integrals <- function(original_dir,
    ids = c('profile-07','profile-20','profile-21','profile-44','profile-14','profile-42')) {
  source('inst/validation/adaptive-quadrature-review-0.2.4.R',local=TRUE)
  out <- file.path(original_dir,'repairs')
  fits <- list(shared=readRDS('validation-results/gpcm-probability-refit-20260925/refit-788.rds')$fit,
    separate=readRDS('validation-results/portable-gpcm-development-probe.rds')$review$fits$q41)
  prior_path <- file.path(out,'review.csv')
  rows <- if(file.exists(prior_path)) {
    prior <- read.csv(prior_path); split(prior,prior$Id)
  } else list()
  for(id in ids) {
    if(id %in% names(rows)) next
    old <- readRDS(file.path(original_dir,paste0(id,'.rds')))
    fit <- fits[[old$spec$Owner]]
    refit <- id %in% c('profile-07','profile-20','profile-21')
    order <- if(refit)301L else 31L
    ctx <- gjp_context(fit,order)
    cat('refit/reference:',id,'order',order,'\n');flush.console()
    if(refit) {
      ans <- gjp_fit(ctx$evaluator,old$result$selected$full,old$spec$Index,old$spec$Value)
      stopifnot(!is.null(ans$selected))
      p <- ans$selected$full
      free <- setdiff(seq_along(p),old$spec$Index)
      embed <- function(z) { a<-p;a[free]<-z;a }
      proposal <- NULL
      if(max(abs(ctx$evaluator$gradient(p)[free]))>1e-4) {
        proposal <- mfrmr:::mfrm_optimizer_curvature_proposal(p[free],
          function(z)ctx$evaluator$value(embed(z)),function(z)ctx$evaluator$gradient(embed(z))[free])
        if(!is.null(proposal$par))p<-embed(proposal$par)
      }
    } else {
      path <- file.path(out,paste0(id,'.rds'))
      if(!file.exists(path)) path <- file.path(original_dir,paste0('curvature-',id,'.rds'))
      repaired <- readRDS(path)
      p <- repaired$parameters
      ans <- if(is.null(repaired$result)) old$result else repaired$result
      proposal<-NULL
      free <- setdiff(seq_along(p),old$spec$Index)
    }
    value <- ctx$evaluator$value(p);g <- ctx$evaluator$gradient(p)[free]
    comparison <- gjp_context(fit,if(refit)201L else 61L)
    pars <- mfrmr:::expand_params(p,ctx$sizes,ctx$config)
    base <- mfrmr:::compute_base_eta(ctx$idx,pars,ctx$config)
    reference <- lapply(c(32,64),function(limit)do.call(rbind,
      lapply(split(seq_along(ctx$idx$person),ctx$idx$person),function(obs)
        aq_continuous_reference(ctx$idx$score_k[obs],base[obs],
          pars$steps_mat[ctx$idx$step_idx[obs],,drop=FALSE],pars$slopes[ctx$idx$slope_idx[obs]],
          ctx$idx$weight[obs],unname(pars$population$coefficients[1]),sqrt(pars$population$sigma2),limit))))
    r <- data.frame(Id=id,Order=order,NLL=value,Gradient=max(abs(g)),
      OptimizerCode=ans$selected$opt$convergence,StationarityPass=max(abs(g))<=1e-4,
      ComparisonDifference=abs(value-comparison$evaluator$value(p)),
      ComparisonGradientDifference=max(abs(g-comparison$evaluator$gradient(p)[free])),
      ContinuousNLL= -sum(reference[[2]][,'log_marginal']),
      ReferenceChange=max(abs(reference[[1]][,1:3]-reference[[2]][,1:3])),
      ReferenceRelativeError=max(reference[[2]][,'relative_error']),
      ReferenceLogTailBound=max(reference[[2]][,'log_relative_tail_bound']))
    r$ReferenceDifference <- r$NLL-r$ContinuousNLL
    r$ReferenceQualified <- all(is.finite(reference[[2]])) && r$ReferenceChange<1e-8 &&
      r$ReferenceRelativeError<1e-9 && r$ReferenceLogTailBound<log(1e-12)
    saveRDS(list(parameters=p,original=old,result=ans,proposal=proposal,reference=reference,row=r),
      file.path(out,paste0('review-',id,'.rds')))
    rows[[id]]<-r;write.csv(do.call(rbind,rows),file.path(out,'review.csv'),row.names=FALSE)
    print(r);flush.console()
  }
  invisible(rows)
}
