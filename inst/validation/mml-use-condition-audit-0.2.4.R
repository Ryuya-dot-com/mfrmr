# Repository-only use-condition audit; companion record owns design and scope.
source('inst/validation/mml-structural-bias-diagnostic-0.2.4.R')
source('inst/validation/tam-mml-release-stress-0.2.4.R')
source('inst/validation/tam-pcm-mml-conditional-stress-0.2.4.R')

mml_use_cases <- function() {
  out<-list()
  add<-function(id,model,x,seed,source,grids=c(31L,61L,121L),categories=3L) {
    out[[id]]<<-list(Id=id,Model=model,Seed=seed,Source=source,Data=x$data,
      Extra=x$extra,Grids=grids,Categories=categories)
  }
  for(i in 1:8) {
    cell<-mml_coverage_cells()[i,];seed<-61000000L+10000L*i+1L
    x<-mml_information_fixture(cell$Model,'baseline',3L,seed,cell$Persons,cell$Exposure)
    add(paste0('coverage-',i),cell$Model,x,seed,'coverage_first_seed')
  }
  for(model in c('RSM','PCM')) for(condition in c('population','weights')) {
    seed<-20260909L+if(model=='RSM') if(condition=='population') 2L else 6L else
      if(condition=='population') 8L else 12L
    x<-mml_information_fixture(model,condition,3L,seed)
    if(condition=='weights') x$data$Weight<-c(.5,1,1.5)[match(x$data$Rater,paste0('R',1:3))]
    add(paste(model,condition,sep='-'),model,x,seed,condition)
  }
  plan<-mfrmr_tms_plan()
  plan<-plan[plan$PopulationMode=='fixed_standard_normal' & plan$Replicate==1L &
    plan$Nodes==31L & plan$ProfileId %in% c('BASELINE','SPARSE_RATER'),]
  for(model in c('RSM','PCM')) for(i in seq_len(nrow(plan))) {
    row<-plan[i,];d<-if(model=='RSM') mfrmr_tms_generate(row) else mfrmr_tpcm_generate(row)
    file<-if(model=='RSM') 'tam-mml-release-stress-summary-0.2.4.csv' else
      'tam-pcm-mml-conditional-stress-summary-0.2.4.csv'
    old<-read.csv(paste0('inst/validation/',file))
    expected<-unique(old$InputSHA256[old$ProfileId==row$ProfileId & old$Replicate==1L &
      old$PopulationMode=='fixed_standard_normal'])
    actual<-digest::digest(d[c('Person','Rater','Criterion','Score')],algo='sha256',serialize=TRUE)
    stopifnot(length(expected)==1L,identical(actual,expected))
    id<-paste(model,row$ProfileId,sep='-')
    add(id,model,list(data=d,extra=list()),row$Seed,'historical_stress',c(31L,61L,121L,181L),4L)
    out[[id]]$HistoricalInputSHA256<-actual
  }
  stopifnot(length(out)==16L,sum(vapply(out,function(z)length(z$Grids),integer(1)))==52L)
  out
}

mml_use_se <- function(fit,covariance) {
  facets<-mfrmr:::compute_mml_facet_model_se(fit,covariance)$table
  steps<-mfrmr:::compute_mml_structural_parameter_se(fit,covariance)$steps
  owner<-if('StepFacet' %in% names(steps)) steps$StepFacet else 'shared'
  out<-c(setNames(facets$ModelSE,paste(facets$Facet,facets$Level,sep=':')),
    setNames(steps$SE,paste(owner,steps$Step,sep=':')))
  stopifnot(!anyDuplicated(names(out)))
  out
}

mml_use_fit <- function(case,q) {
  stress<-case$Source=='historical_stress'
  fit<-do.call(fit_mfrm,c(list(data=case$Data,person='Person',facets=c('Rater','Criterion'),
    score='Score',model=case$Model,step_facet=if(case$Model=='PCM') 'Criterion' else NULL,
    method='MML',rating_min=if(stress)1L else 0L,rating_max=if(stress)4L else 2L,
    quad_points=q,maxit=if(stress)1000L else 200L,reltol=if(stress)1e-12 else 1e-10,
    mml_engine='direct'),case$Extra))
  covariance<-mfrmr:::compute_mml_parameter_covariance(fit)
  high<-fit;high$config$estimation_control$quad_points<-241L
  reference<-mfrmr:::compute_mml_parameter_covariance(high)
  stopifnot(covariance$status=='ok',reference$status=='ok')
  idx<-mfrmr:::build_indices(fit$prep,step_facet=fit$config$step_facet)
  quad<-mfrmr:::gauss_hermite_normal(241L)
  value<-mfrmr:::mfrm_loglik_mml(fit$opt$par,idx,fit$config,covariance$sizes,quad)
  score<-mfrmr:::mfrm_grad_mml(fit$opt$par,idx,fit$config,covariance$sizes,quad)
  se<-mml_use_se(fit,covariance);reference_se<-mml_use_se(fit,reference)
  stopifnot(identical(names(se),names(reference_se)),all(is.finite(se)&se>0))
  diagnostic<-diagnose_mfrm(fit,residual_pca='none')
  equivalence<-tryCatch(analyze_facet_equivalence(fit,facet='Rater'),error=identity)
  metrics<-data.frame(ObjectiveChange=abs(value-fit$opt$value),
    ExpandedSEChange=max(abs(reference_se/se-1)),
    FreeSEChange=max(abs(sqrt(diag(reference$cov)/diag(covariance$cov))-1)),
    ScaledNewton=max(abs(reference$cov %*% score)/sqrt(diag(covariance$cov))),
    InferenceReady=mfrmr:::mfrm_inference_ready(fit),
    FormalInference=diagnostic$precision_profile$SupportsFormalInference,
    WeightPolicy=mfrmr:::mfrm_ic_weight_policy(fit$prep,fit$config),
    ReadinessReasons=fit$readiness$fit$ReasonCodes,
    EquivalenceAvailable=!inherits(equivalence,'error'),
    EquivalenceReason=if(inherits(equivalence,'error'))conditionMessage(equivalence) else '')
  metrics$NumericalPass<-metrics$ObjectiveChange<=1e-6 && metrics$ExpandedSEChange<=.001 &&
    metrics$ScaledNewton<=.001
  list(fit=fit,covariance=covariance,reference=reference,reference_score=score,
    reference_value=value,metrics=metrics,precision_profile=diagnostic$precision_profile,
    equivalence=equivalence)
}

mml_use_weight_patterns <- function() {
  prior<-readRDS('inst/validation/mml-structural-bias-diagnostic-evidence-0.2.4.rds')
  rows<-list();details<-list()
  for(model in c('RSM','PCM')) for(mode in c('unit','heterogeneous')) {
    oracle<-prior$oracles[[paste(model,3L)]];x<-oracle$x
    for(g in seq_along(oracle$assignments)) {
      assignment<-oracle$assignments[[g]];ix<-assignment$indices
      w<-if(mode=='unit') rep(1,3) else c(.5,1,1.5)[match(x$data$Rater[ix],paste0('R',1:3))]
      fn<-function(par) {
        lp<-environment(x$objective)$log_probability(oracle$quad$nodes,ix,par)
        indicators<-do.call(rbind,lapply(0:2,function(k)t(oracle$patterns==k)))*rep(w,3)
        log(as.vector(crossprod(oracle$quad$weights,exp(do.call(cbind,lp)%*%indicators))))
      }
      score<-mml_bias_pattern_score(fn,x$truth)
      score2<-mml_bias_pattern_score(fn,x$truth,5e-5)
      expected<-colSums(score*assignment$probability)
      mass<-sum(exp(fn(x$truth)))
      stopifnot(max(abs(score-score2))<1e-7,all(is.finite(expected)),is.finite(mass))
      if(mode=='unit') stopifnot(abs(mass-1)<1e-10,max(abs(expected))<1e-7)
      id<-paste(model,mode,g,sep='-')
      rows[[id]]<-data.frame(Model=model,WeightMode=mode,Assignment=g,PoweredMass=mass,
        MaxExpectedScore=max(abs(expected)),ScoreStepChange=max(abs(score-score2)))
      details[[id]]<-list(weights=w,expected_score=expected,score=score,pattern_integrals=exp(fn(x$truth)))
    }
  }
  list(summary=do.call(rbind,rows),details=details)
}

mml_use_audit <- function(directory) {
  pkgload::load_all('.',quiet=TRUE)
  cases<-mml_use_cases();dir.create(directory,recursive=TRUE,showWarnings=FALSE)
  paths<-c(list.files('R',pattern='[.]R$',full.names=TRUE),
    paste0('inst/validation/',c('mml-use-condition-audit-0.2.4.R',
      'mml-independent-information-conditions-0.2.4.R','mml-independent-rsm-information-0.2.4.R',
      'mml-structural-coverage-0.2.4.R','mml-structural-bias-diagnostic-0.2.4.R',
      'mml-structural-bias-diagnostic-evidence-0.2.4.rds',
      'tam-mml-release-stress-0.2.4.R','tam-pcm-mml-conditional-stress-0.2.4.R')))
  evidence<-list(cases=cases,results=list(),payload=tools::md5sum(paths),
    plan=readLines('inst/validation/mml-use-condition-audit-record-0.2.4.md'),
    source=readLines('inst/validation/mml-use-condition-audit-0.2.4.R'),session=sessionInfo())
  rows<-list()
  for(case in cases) for(q in case$Grids) {
    id<-paste0(case$Id,'-q',q);started<-proc.time()[['elapsed']];warnings<-character()
    result<-tryCatch(withCallingHandlers(mml_use_fit(case,q),warning=function(w) {
      warnings<<-c(warnings,conditionMessage(w));invokeRestart('muffleWarning')
    }),error=identity)
    row<-data.frame(Id=case$Id,Model=case$Model,Source=case$Source,Seed=case$Seed,Q=q,
      Persons=length(unique(case$Data$Person)),ResponsesPerPerson=nrow(case$Data)/length(unique(case$Data$Person)),
      Seconds=proc.time()[['elapsed']]-started,Warnings=length(warnings),
      Error=if(inherits(result,'error'))conditionMessage(result) else '')
    if(!inherits(result,'error')) row<-cbind(row,result$metrics)
    rows[[id]]<-row;evidence$results[[id]]<-list(result=result,warnings=warnings)
    saveRDS(evidence$results[[id]],file.path(directory,paste0(id,'.rds')))
    cat(id,':',row$Error,if(!inherits(result,'error'))paste('numerical',row$NumericalPass), '\n');flush.console()
  }
  fields<-unique(unlist(lapply(rows,names)))
  evidence$summary<-do.call(rbind,lapply(rows,function(z){z[setdiff(fields,names(z))]<-NA;z}))
  evidence$summary$ParameterShiftInHighGridSE<-NA_real_
  for(case in cases) {
    high<-evidence$results[[paste0(case$Id,'-q',max(case$Grids))]]$result
    if(inherits(high,'error')) next
    for(q in case$Grids) {
      low<-evidence$results[[paste0(case$Id,'-q',q)]]$result
      if(inherits(low,'error')) next
      at<-evidence$summary$Id==case$Id & evidence$summary$Q==q
      evidence$summary$ParameterShiftInHighGridSE[at]<-max(abs(low$fit$opt$par-high$fit$opt$par)/sqrt(diag(high$covariance$cov)))
    }
  }
  evidence$weights<-mml_use_weight_patterns()
  for(model in c('RSM','PCM')) {
    id<-paste0(model,'-weights');case<-cases[[id]]
    x<-mml_information_fixture(model,'weights',3L,case$Seed)
    environment(x$objective)$d<-case$Data
    result<-evidence$results[[paste0(id,'-q121')]]$result
    if(inherits(result,'error')) {
      evidence$weights$integral_check[[model]]<-c(WholeLine=NA_real_,Q241=NA_real_)
      next
    }
    fit<-result$fit
    reference<-x$objective(fit$opt$par)
    evidence$weights$integral_check[[model]]<-c(WholeLine=reference,
      Q241=result$reference_value)
  }
  stopifnot(identical(tools::md5sum(paths),evidence$payload))
  saveRDS(evidence,file.path(directory,'evidence.rds'))
  write.csv(evidence$summary,file.path(directory,'summary.csv'),row.names=FALSE)
  write.csv(evidence$weights$summary,file.path(directory,'weights.csv'),row.names=FALSE)
  invisible(evidence)
}

if(sys.nframe()==0L) {
  args<-commandArgs(trailingOnly=TRUE);stopifnot(length(args)==1L)
  mml_use_audit(args[1])
}
