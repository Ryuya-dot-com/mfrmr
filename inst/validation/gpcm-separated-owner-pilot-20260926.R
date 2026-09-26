# Repository-only runner. Load the current package source before sourcing this file.
separate_owner_truth <- function(theta, rater, criterion) {
  steps <- rbind(c(-.8,.8),c(-.45,.45),c(-1,1))
  t(vapply(seq_along(theta),function(i) {
    eta <- theta[i]-c(-.25,0,.25)[rater[i]]-c(-.15,.15)[criterion[i]]
    z <- c(0,cumsum(c(.8,1.25)[criterion[i]]*(eta-steps[rater[i],])))
    w <- exp(z-max(z)); w/sum(w)
  },numeric(3)))
}

run_separate_owner_pilot <- function(output_dir, limit=80L) {
  source_files <- sort(c(list.files('R',pattern='[.]R$',full.names=TRUE),
    'inst/validation/gpcm-separated-owner-pilot-20260926.R',
    'inst/validation/gpcm-separated-owner-pilot-20260926.md'))
  source_hash <- tools::md5sum(source_files)
  plan <- expand.grid(N=c(120L,400L),Design=c('complete','incomplete'),Replicate=1:20,
    stringsAsFactors=FALSE)
  plan$Seed <- 926800L+100L*plan$N+plan$Replicate
  plan$Case <- sprintf('n%d-%s-%02d',plan$N,plan$Design,plan$Replicate)
  dir.create(output_dir,recursive=TRUE,showWarnings=FALSE)
  manifest <- list(plan=plan,source_hash=source_hash)
  manifest_path <- file.path(output_dir,'manifest.rds')
  if (file.exists(manifest_path)) stopifnot(identical(readRDS(manifest_path),manifest)) else {
    saveRDS(manifest,manifest_path)
    write.csv(plan,file.path(output_dir,'plan.csv'),row.names=FALSE)
  }
  grid <- expand.grid(Theta=c(-1,0,1),Rater=paste0('R',1:3),Criterion=paste0('C',1:2),
    stringsAsFactors=FALSE)
  curve_truth <- as.vector(t(separate_owner_truth(grid$Theta,
    match(grid$Rater,paste0('R',1:3)),match(grid$Criterion,paste0('C',1:2)))))
  curve_ids <- paste(rep(paste(grid$Theta,grid$Rater,grid$Criterion,sep='/'),each=3),
    rep(0:2,nrow(grid)),sep='/')
  targets <- data.frame(Family=c(rep('slope',2),rep('step',6),rep('probability',54)),
    Target=c('C1','C2',as.vector(t(outer(paste0('R',1:3),paste0('Step_',1:2),paste,sep='/'))),curve_ids),
    Truth=c(.8,1.25,-.8,.8,-.45,.45,-1,1,curve_truth))
  run_case <- function(row) {
    started <- proc.time()[['elapsed']]; warnings <- character()
    rows <- targets
    rows$Estimate <- rows$Lower <- rows$Upper <- NA_real_
    rows$Available <- FALSE; rows$Covered <- NA; rows$Reason <- 'Not evaluated'
    fit <- intervals <- curves <- NULL
    checks <- list(Returned=FALSE,OptimizerCode=NA_integer_,InformationStatus=NA_character_,
      Integration=NA_character_,Quadrature=NA_integer_,Reason='')
    tryCatch(withCallingHandlers({
      set.seed(row$Seed)
      d <- expand.grid(Person=paste0('P',seq_len(row$N)),Rater=paste0('R',1:3),
        Criterion=paste0('C',1:2),stringsAsFactors=FALSE)
      person <- match(d$Person,unique(d$Person)); rater <- match(d$Rater,paste0('R',1:3))
      criterion <- match(d$Criterion,paste0('C',1:2)); theta <- rnorm(row$N,sd=1.2)
      p <- separate_owner_truth(theta[person],rater,criterion)
      stopifnot(all(is.finite(p)),max(abs(rowSums(p)-1))<1e-12)
      d$Score <- vapply(seq_len(nrow(d)),function(i) sample.int(3,1,prob=p[i,])-1L,integer(1))
      if (row$Design=='incomplete') d <- d[rater != 1+person%%3,]
      fit <- fit_mfrm(d,'Person',c('Rater','Criterion'),'Score',model='GPCM',method='MML',
        step_facet='Rater',slope_facet='Criterion',gpcm_mml_identification='free_population',
        rating_min=0,rating_max=2,category_policy='preserve',mml_integration='fixed',
        quad_points=31,maxit=400,reltol=1e-10)
      checks$Returned <- TRUE; checks$OptimizerCode <- fit$opt$convergence
      checks$Integration <- fit$config$estimation_control$mml_integration
      checks$Quadrature <- fit$config$estimation_control$quad_points
      rows$Estimate[1:2] <- fit$slopes$Estimate[match(rows$Target[1:2],fit$slopes$SlopeFacet)]
      rows$Estimate[3:8] <- fit$steps$Estimate[match(rows$Target[3:8],paste(fit$steps$StepFacet,fit$steps$Step,sep='/'))]
      rows$Reason[3:8] <- 'Point-estimate target; no step interval evaluated'
      cv <- mfrmr:::compute_mml_parameter_covariance(fit)
      checks$InformationStatus <- cv$status
      intervals <- confint(fit,level=.95)
      tab <- attr(intervals,'diagnostics'); at <- match(rows$Target[1:2],tab$SlopeFacet)
      rows$Lower[1:2] <- tab$CI_Lower[at]; rows$Upper[1:2] <- tab$CI_Upper[at]
      rows$Available[1:2] <- tab$CIEligible[at]; rows$Reason[1:2] <- tab$InferenceReview[at]
      curves <- mfrm_curve_intervals(fit,grid,level=.95)
      ct <- curves$table
      ids <- paste(ct$Theta,ct$Rater,ct$Criterion,ct$Category,sep='/')
      at <- match(curve_ids,ids); stopifnot(!anyNA(at),!anyDuplicated(ids))
      rows$Estimate[9:62] <- ct$Estimate[at]; rows$Lower[9:62] <- ct$Lower[at]
      rows$Upper[9:62] <- ct$Upper[at]; rows$Available[9:62] <- ct$CIEligible[at]
      rows$Reason[9:62] <- ct$InferenceReview[at]
    },warning=function(w) {warnings <<- c(warnings,conditionMessage(w)); invokeRestart('muffleWarning')}),
    error=function(e) {checks$Reason <<- conditionMessage(e)
      rows$Reason[rows$Reason=='Not evaluated'] <<- conditionMessage(e)})
    rows$Covered[rows$Available] <- rows$Lower[rows$Available] <= rows$Truth[rows$Available] &
      rows$Upper[rows$Available] >= rows$Truth[rows$Available]
    checks$Elapsed <- proc.time()[['elapsed']]-started
    list(plan=row,rows=rows,checks=checks,warnings=unique(warnings),fit=fit,intervals=intervals,curves=curves)
  }
  started <- proc.time()[['elapsed']]; new_cases <- 0L
  for (i in seq_len(nrow(plan))) {
    path <- file.path(output_dir,paste0(plan$Case[i],'.rds'))
    if (file.exists(path)) next
    if (new_cases>=limit || proc.time()[['elapsed']]-started>900) break
    result <- run_case(plan[i,]); saveRDS(result,path)
    new_cases <- new_cases+1L
    cat(plan$Case[i],sprintf('%.2fs',result$checks$Elapsed),result$checks$Reason,'\n'); flush.console()
  }
  results <- lapply(seq_len(nrow(plan)),function(i) {
    path <- file.path(output_dir,paste0(plan$Case[i],'.rds'))
    if(file.exists(path)) readRDS(path) else NULL
  })
  saveRDS(list(manifest=manifest,results=results),file.path(output_dir,'results.rds'))
  invisible(results)
}
