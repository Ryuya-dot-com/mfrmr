# Repository-only execution cases, not a power/coverage study.
# See interval-drf-preflight-protocol-0.2.4.md; use a new output directory.
pkgload::load_all('.',quiet=TRUE)
out <- commandArgs(TRUE)[1]; stopifnot(!is.na(out),!dir.exists(out))
dir.create(out,recursive=TRUE)
files <- c(list.files('R','[.]R$',full.names=TRUE),
  'inst/validation/drf-execution-preflight-0.2.4.R',
  'inst/validation/interval-drf-preflight-protocol-0.2.4.md')
hash <- tools::md5sum(files)
cases <- c('null','group_mean_only','drf','interaction','combined',
  'connected_incomplete','no_common_raters')
runs <- screens <- guards <- list()
for(mi in 1:2) for(ci in seq_along(cases)) {
  model <- c('RSM','PCM')[mi]; case <- cases[ci]; id <- paste(model,case,sep='-')
  seed <- 75000000L + 10000L*mi + ci
  mean_shift <- if(case %in% c('group_mean_only','combined')) .6 else 0
  drf <- if(case %in% c('drf','combined','connected_incomplete','no_common_raters')) c(.4,-.4,0) else c(0,0,0)
  interaction <- if(case %in% c('interaction','combined')) c(.3,-.3,0) else c(0,0,0)
  effects <- data.frame(Group='B',Rater=paste0('R0',1:3),Effect=mean_shift+drf)
  int_effects <- expand.grid(Rater=paste0('R0',1:3),Criterion=paste0('C0',1:2),stringsAsFactors=FALSE)
  int_effects$Effect <- as.vector(outer(interaction,c(1,-1)))
  thresholds <- if(model=='RSM') c(-.6,.6) else list(C01=c(-.7,.7),C02=c(-.2,.2))
  d <- simulate_mfrm_data(n_person=80,n_rater=3,n_criterion=2,
    raters_per_person=if(case=='connected_incomplete') 2L else 3L,
    score_levels=3,model=model,thresholds=thresholds,group_levels=c('A','B'),
    dif_effects=effects,interaction_effects=int_effects,seed=seed)
  truth <- attr(d,'mfrm_truth')
  if(case=='no_common_raters') d <- d[(d$Group=='A' & d$Rater!='R03') | (d$Group=='B' & d$Rater=='R03'),]
  ri <- match(d$Rater,paste0('R0',1:3)); ki <- match(d$Criterion,paste0('C0',1:2))
  # Independent decomposition: the common group shift belongs to effective theta.
  effective_theta <- truth$person + mean_shift*(truth$groups[names(truth$person)]=='B')
  eta <- effective_theta[d$Person]-truth$facets$Rater[d$Rater]-truth$facets$Criterion[d$Criterion] +
    (d$Group=='B')*drf[ri] + interaction[ri]*c(1,-1)[ki]
  package_eta <- truth$person[d$Person]-truth$facets$Rater[d$Rater]-truth$facets$Criterion[d$Criterion] +
    mfrmr:::simulation_apply_effects(d,truth$signals$dif_effects) +
    mfrmr:::simulation_apply_effects(d,truth$signals$interaction_effects)
  cum <- if(model=='RSM') matrix(c(0,cumsum(thresholds)),1) else t(vapply(thresholds,function(z)c(0,cumsum(z)),numeric(3)))
  lp <- outer(as.numeric(eta),0:2)-cum[if(model=='RSM') rep(1L,nrow(d)) else ki,,drop=FALSE]
  probability <- exp(lp-apply(lp,1,max)); probability <- probability/rowSums(probability)
  actual <- if(model=='RSM') mfrmr:::category_prob_rsm(package_eta,as.numeric(cum)) else
    mfrmr:::category_prob_pcm(package_eta,cum,ki)
  probability_error <- max(abs(probability-actual)); eta_error <- max(abs(eta-package_eta))
  warnings <- character(); started <- proc.time()[['elapsed']]
  fit <- represented <- NULL; fitted_screens <- list(); numerical_fit_seconds <- NA_real_
  error <- tryCatch(withCallingHandlers({
    stopifnot(probability_error<1e-12,eta_error<1e-12,
      all(d$Score %in% 1:3),abs(sum(drf))<1e-12,abs(sum(interaction))<1e-12)
    args <- list(data=d,person='Person',facets=c('Rater','Criterion'),score='Score',
      model=model,method='MML',step_facet=if(model=='PCM') 'Criterion' else NULL,
      rating_min=1,rating_max=3,quad_points=61L,maxit=200L,reltol=1e-10)
    ft <- proc.time()[['elapsed']]; fit <- do.call(fit_mfrm,args)
    numerical_fit_seconds <- proc.time()[['elapsed']]-ft
    dx <- diagnose_mfrm(fit,residual_pca='none')
    for(method in c('residual','refit')) {
      st <- proc.time()[['elapsed']]
      ans <- tryCatch(analyze_dff(fit,dx,facet='Rater',group='Group',data=d,
        method=method,min_obs=10,p_adjust='holm'),error=identity)
      if(inherits(ans,'error')) {
        stopifnot(case=='no_common_raters')
        guards[[length(guards)+1L]] <- data.frame(Cell=id,Route=method,ExpectedUnavailable=TRUE,
          Error=conditionMessage(ans),Seconds=proc.time()[['elapsed']]-st)
      } else {
        tab <- ans$dif_table
        stopifnot(!any(tab$FormalInferenceEligible,na.rm=TRUE),
          !any(tab$PrimaryReportingEligible,na.rm=TRUE))
        if(case=='no_common_raters') stopifnot(!any(is.finite(tab$Contrast)))
        # Retain the complete method-specific table; bind only common fields below.
        write.csv(tab,file.path(out,paste0(id,'-',method,'.csv')),row.names=FALSE)
        screens[[length(screens)+1L]] <- data.frame(Cell=id,Method=method,Rows=nrow(tab),
          Available=sum(is.finite(tab$Contrast)),AdjustedPAvailable=sum(is.finite(tab$p_adjusted)),
          WithinFixtureFlags=sum(tab$p_adjusted<.05,na.rm=TRUE),
          FormalEligible=sum(tab$FormalInferenceEligible,na.rm=TRUE),
          Seconds=proc.time()[['elapsed']]-st)
        fitted_screens[[method]] <- ans
      }
    }
    if(case %in% c('interaction','combined','group_mean_only')) {
      if(case=='group_mean_only') {
        args$population_formula <- ~ Group
        args$person_data <- unique(d[c('Person','Group')])
      } else args$facet_interactions <- 'Rater:Criterion'
      represented <- do.call(fit_mfrm,args)
      rdx <- diagnose_mfrm(represented,residual_pca='none')
      rs <- analyze_dff(represented,rdx,facet='Rater',group='Group',data=d,method='residual',min_obs=10,p_adjust='holm')
      stopifnot(!any(rs$dif_table$FormalInferenceEligible,na.rm=TRUE))
      fitted_screens$represented_residual <- rs
      write.csv(rs$dif_table,file.path(out,paste0(id,'-represented-residual.csv')),row.names=FALSE)
      denied <- tryCatch(analyze_dff(represented,rdx,facet='Rater',group='Group',data=d,method='refit'),error=identity)
      stopifnot(inherits(denied,'error'),grepl('cannot currently reproduce',conditionMessage(denied),fixed=TRUE))
      guards[[length(guards)+1L]] <- data.frame(Cell=id,Route='represented_refit',ExpectedUnavailable=TRUE,
        Error=conditionMessage(denied),Seconds=NA_real_)
    }
    ''
  },warning=function(w){warnings <<- c(warnings,conditionMessage(w));invokeRestart('muffleWarning')}),error=function(e)conditionMessage(e))
  runs[[length(runs)+1L]] <- data.frame(Cell=id,Seed=seed,GroupMeanShift=mean_shift,
    DRFAmplitude=max(abs(drf)),InteractionAmplitude=max(abs(interaction)),Observations=nrow(d),
    ProbabilityError=probability_error,EtaError=eta_error,FitSeconds=numerical_fit_seconds,
    TotalSeconds=proc.time()[['elapsed']]-started,Error=error,Warnings=paste(warnings,collapse=' | '))
  saveRDS(list(data=d,truth=truth,effective_theta=effective_theta,drf=drf,
    interaction=interaction,fit=fit,represented=represented,screens=fitted_screens,error=error),
    file.path(out,paste0(id,'.rds')))
  cat(id,'error:',error,'\n');flush.console()
}
runs <- do.call(rbind,runs); screens <- do.call(rbind,screens); guards <- do.call(rbind,guards)
for(name in c('runs','screens','guards')) write.csv(get(name),file.path(out,paste0(name,'.csv')),row.names=FALSE)
write.csv(data.frame(File=files,MD5=unname(hash)),file.path(out,'source-md5.csv'),row.names=FALSE)
writeLines(capture.output(sessionInfo()),file.path(out,'session-info.txt'))
stopifnot(identical(hash,tools::md5sum(files)),nrow(runs)==14L,all(runs$Error==''),
  all(screens$FormalEligible==0L),sum(guards$Route=='represented_refit')==6L)
print(runs)
