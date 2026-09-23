# Analyze the complete prespecified roster, with one dataset as the MC unit.
out <- 'validation-results/estimated-model-qualification-20260923'
protocol <- readRDS(file.path(out,'protocol.rds'))
paths <- file.path(out,sprintf('trial-%04d.rds',protocol$roster$Trial))
stopifnot(all(file.exists(paths)))
# Analyze the frozen executed source, even after output-only follow-up changes.
snapshot <- tools::md5sum(file.path(out, 'executed-source', names(protocol$source)))
names(snapshot) <- names(protocol$source)
stopifnot(identical(protocol$source, snapshot))
mean_mc <- function(x, probability=FALSE) {
  x<-x[is.finite(x)];n<-length(x);m<-if(n) mean(x) else NA_real_
  se<-if(n>1) sd(x)/sqrt(n) else NA_real_;delta<-if(n>1) qt(.975,n-1)*se else NA_real_
  lo<-m-delta;hi<-m+delta
  if(probability) {lo<-max(0,lo);hi<-min(1,hi)}
  c(N=n,Estimate=m,MCSE=se,MCLower=lo,MCUpper=hi)
}
binary_mc <- function(x) {
  x<-x[!is.na(x)];n<-length(x);yes<-sum(x)
  ci<-if(n) binom.test(yes,n)$conf.int else c(NA_real_,NA_real_)
  c(N=n,Estimate=if(n) yes/n else NA_real_,MCSE=if(n) sqrt(yes/n*(1-yes/n)/n) else NA_real_,MCLower=ci[1],MCUpper=ci[2])
}
interval_decision <- function(coverage,availability) {
  if(!is.finite(coverage['MCUpper'])) return('unavailable')
  if(coverage['MCUpper']<.925) return('adverse_undercoverage')
  if(coverage['MCLower']>=.925 && coverage['Estimate']<=.975 && availability['MCLower']>=.95) return('bounded_support')
  'inconclusive'
}
datasets<-targets<-populations<-vector('list',length(paths))
for(i in seq_along(paths)) {
  x<-readRDS(paths[i]);stopifnot(identical(x$roster,protocol$roster[i,,drop=FALSE]))
  row<-x$roster;f<-x$fits$shared;o<-x$fits$ordinary
  sr<-!is.null(f) && isTRUE(f$checks$NumericalReady) && isTRUE(f$checks$InformationPositive)
  ordinary_ready<-!is.null(o) && identical(as.character(o$summary$NumericalState),'ready') &&
    isTRUE(o$population$estimation_converged) && !identical(o$readiness$fit$FitReadiness,'blocked')
  boundary_r<-!is.null(f) && isTRUE(f$checks$EstimatedVarianceBoundary)
  boundary_p<-!is.null(f) && isTRUE(f$checks$EstimatedPersonVarianceBoundary)
  regular<-sr && !boundary_r && !boundary_p
  named<-function(tab,id,value,ids) if(is.null(tab)) rep(NA_real_,length(ids)) else tab[[value]][match(ids,tab[[id]])]
  rids<-names(x$truth$raters);cids<-names(x$truth$criterion)
  rt<-f$raters
  ct<-if(!is.null(f)) subset(f$calibration_table,Parameter=='Fixed facet' & Facet=='Criterion') else NULL
  r_est<-named(rt,'Rater','Estimate',rids);c_est<-named(ct,'Level','Estimate',cids)
  coef<-if(!is.null(f)) f$input$basis$Criterion['C3',]-f$input$basis$Criterion['C1',] else rep(NA_real_,2)
  delta_est<-if(!is.null(f)) sum(coef*f$calibration$beta) else NA_real_
  delta_se<-if(regular) sqrt(drop(coef %*% f$covariance[1:2,1:2] %*% coef)) else NA_real_
  tab<-data.frame(Target=c(paste0('rater:',rids),paste0('criterion:',cids),'criterion:C3-C1'),
    Family=c(rep('rater',length(rids)),rep('criterion',length(cids)),'contrast'),
    Truth=c(x$truth$raters,x$truth$criterion,.6),Estimate=c(r_est,c_est,delta_est),
    Lower=c(named(rt,'Rater','Lower',rids),named(ct,'Level','Lower',cids),delta_est-qnorm(.975)*delta_se),
    Upper=c(named(rt,'Rater','Upper',rids),named(ct,'Level','Upper',cids),delta_est+qnorm(.975)*delta_se),row.names=NULL)
  tab$PointAvailable<-sr & is.finite(tab$Estimate)
  tab$IntervalAvailable<-regular & is.finite(tab$Lower) & is.finite(tab$Upper)
  tab$Covered<-ifelse(tab$IntervalAvailable,tab$Lower<=tab$Truth & tab$Upper>=tab$Truth,NA)
  tab$Width<-ifelse(tab$IntervalAvailable,tab$Upper-tab$Lower,NA_real_)
  tab$Error<-ifelse(tab$PointAvailable,tab$Estimate-tab$Truth,NA_real_)
  targets[[i]]<-cbind(row[rep(1,nrow(tab)),],tab)
  populations[[i]]<-cbind(row[rep(1,2),],data.frame(Target=c('ability_sd','rater_sd'),Truth=c(1.3,.7),
    Estimate=if(sr) c(f$calibration$person_sd,f$calibration$rater_sd) else c(NA_real_,NA_real_),
    Boundary=c(boundary_p,boundary_r)))
  # Both ordinary and shared rater summaries target sample-centered effects here.
  ord_r<-if(!is.null(o)) subset(o$facets$others,Facet=='Rater') else NULL
  ord_c<-if(!is.null(o)) subset(o$facets$others,Facet=='Criterion') else NULL
  ordinary_r<-named(ord_r,'Level','Estimate',rids);ordinary_c<-named(ord_c,'Level','Estimate',cids)
  truth_centered<-x$truth$raters-mean(x$truth$raters)
  err_s<-if(sr) r_est-mean(r_est)-truth_centered else rep(NA_real_,length(rids))
  err_o<-if(ordinary_ready) ordinary_r-mean(ordinary_r)-truth_centered else rep(NA_real_,length(rids))
  rtrows<-tab[tab$Family=='rater',]
  eligible<-all(rtrows$IntervalAvailable)
  ds<-data.frame(SharedReady=sr,OrdinaryReady=ordinary_ready,
    OrdinaryInferenceReady=if(is.null(o)) FALSE else isTRUE(o$population$inference_ready),
    RaterBoundary=boundary_r,AbilityBoundary=boundary_p,RaterIntervalAvailable=eligible,
    RaterCoverage=if(eligible) mean(rtrows$Covered) else NA_real_,
    RaterJointCoverage=mean(rtrows$Covered %in% TRUE),
    RaterCoverageUpperBound=mean(is.na(rtrows$Covered) | rtrows$Covered %in% TRUE),
    RaterWidth=if(eligible) mean(rtrows$Width) else NA_real_,
    SharedRaterMSE=mean(err_s^2),OrdinaryRaterMSE=mean(err_o^2),
    SharedRaterMAE=mean(abs(err_s)),OrdinaryRaterMAE=mean(abs(err_o)),
    SharedContrastError=if(sr) delta_est-.6 else NA_real_,
    OrdinaryContrastError=if(ordinary_ready) ordinary_c[3]-ordinary_c[1]-.6 else NA_real_,
    SharedSeconds=x$elapsed['shared'],OrdinarySeconds=x$elapsed['ordinary'],
    SharedWarnings=paste(x$warnings$shared,collapse=' | '),SharedErrors=paste(x$errors$shared,collapse=' | '),
    OrdinaryWarnings=paste(x$warnings$ordinary,collapse=' | '),OrdinaryErrors=paste(x$errors$ordinary,collapse=' | '),row.names=NULL)
  datasets[[i]]<-cbind(row,ds)
}
datasets<-do.call(rbind,datasets);targets<-do.call(rbind,targets);populations<-do.call(rbind,populations)
for(n in c('datasets','targets','populations')) write.csv(get(n),file.path(out,paste0(n,'.csv')),row.names=FALSE)
summary<-do.call(rbind,lapply(split(datasets,datasets$Condition),function(d) {
  coverage<-mean_mc(d$RaterCoverage,TRUE);availability<-binary_mc(d$RaterIntervalAvailable)
  data.frame(d[1,c('Condition','Raters','Design')],Planned=nrow(d),SharedReady=sum(d$SharedReady),
    OrdinaryReady=sum(d$OrdinaryReady),RaterBoundaries=sum(d$RaterBoundary),AbilityBoundaries=sum(d$AbilityBoundary),
    FiniteIntervals=sum(d$RaterIntervalAvailable),AvailabilityLower=availability['MCLower'],
    Coverage=coverage['Estimate'],CoverageMCSE=coverage['MCSE'],CoverageLower=coverage['MCLower'],CoverageUpper=coverage['MCUpper'],
    AllTrialCoverageLower=mean(d$RaterJointCoverage),AllTrialCoverageUpper=mean(d$RaterCoverageUpperBound),
    MeanWidth=mean(d$RaterWidth,na.rm=TRUE),IntervalDecision=interval_decision(coverage,availability),
    MedianSharedSeconds=median(d$SharedSeconds),MedianOrdinarySeconds=median(d$OrdinarySeconds),row.names=NULL)
}))
write.csv(summary,file.path(out,'rater-interval-summary.csv'),row.names=FALSE)
target_summary<-do.call(rbind,lapply(split(targets,interaction(targets$Condition,targets$Target,drop=TRUE)),function(d) {
  cov<-binary_mc(d$Covered);avail<-binary_mc(d$IntervalAvailable);bias<-mean_mc(d$Error)
  data.frame(d[1,c('Condition','Raters','Design','Target','Family')],Planned=nrow(d),
    FiniteIntervals=sum(d$IntervalAvailable),Coverage=cov['Estimate'],CoverageLower=cov['MCLower'],CoverageUpper=cov['MCUpper'],
    Bias=bias['Estimate'],BiasMCSE=bias['MCSE'],BiasLower=bias['MCLower'],BiasUpper=bias['MCUpper'],
    RMSE=sqrt(mean(d$Error^2,na.rm=TRUE)),IntervalDecision=interval_decision(cov,avail),row.names=NULL)
}))
write.csv(target_summary,file.path(out,'target-summary.csv'),row.names=FALSE)
population_summary<-do.call(rbind,lapply(split(populations,interaction(populations$Condition,populations$Target)),function(d) {
  bias<-mean_mc(d$Estimate-d$Truth);tol<-.1*d$Truth[1]
  data.frame(d[1,c('Condition','Raters','Design','Target','Truth')],Available=bias['N'],Bias=bias['Estimate'],
    BiasMCSE=bias['MCSE'],BiasLower=bias['MCLower'],BiasUpper=bias['MCUpper'],
    RMSE=sqrt(mean((d$Estimate-d$Truth)^2,na.rm=TRUE)),Tolerance=tol,
    AdverseBias=is.finite(bias['MCLower']) && (bias['MCLower']>tol || bias['MCUpper']< -tol),row.names=NULL)
}))
write.csv(population_summary,file.path(out,'population-summary.csv'),row.names=FALSE)
paired<-do.call(rbind,lapply(split(datasets,datasets$Condition),function(d) do.call(rbind,lapply(c('RaterMSE','RaterMAE','ContrastMSE'),function(metric) {
  s<-if(metric=='ContrastMSE') d$SharedContrastError^2 else d[[paste0('Shared',metric)]]
  o<-if(metric=='ContrastMSE') d$OrdinaryContrastError^2 else d[[paste0('Ordinary',metric)]]
  keep<-is.finite(s)&is.finite(o);m<-mean_mc(s-o)
  data.frame(d[1,c('Condition','Raters','Design')],Metric=metric,Planned=nrow(d),Pairs=sum(keep),
    SharedMean=mean(s[keep]),OrdinaryMean=mean(o[keep]),Difference=m['Estimate'],MCSE=m['MCSE'],
    MCLower=m['MCLower'],MCUpper=m['MCUpper'],row.names=NULL)
}))))
write.csv(paired,file.path(out,'paired-model-summary.csv'),row.names=FALSE)
design_pairs<-do.call(rbind,lapply(c(6,24),function(r) {
  a<-subset(datasets,Raters==r & Design=='rotating');b<-subset(datasets,Raters==r & Design=='weak')
  b<-b[match(a$Replicate,b$Replicate),];stopifnot(identical(a$Seed,b$Seed))
  do.call(rbind,lapply(c('RaterCoverage','RaterJointCoverage','SharedRaterMSE','OrdinaryRaterMSE'),function(metric) {
    m<-mean_mc(b[[metric]]-a[[metric]])
    data.frame(Raters=r,Metric=metric,Planned=nrow(a),Pairs=m['N'],WeakMinusRotating=m['Estimate'],MCSE=m['MCSE'],MCLower=m['MCLower'],MCUpper=m['MCUpper'],row.names=NULL)
  }))
}))
write.csv(design_pairs,file.path(out,'paired-design-summary.csv'),row.names=FALSE)
saveRDS(list(datasets=datasets,targets=targets,populations=populations,intervals=summary,
  target_summary=target_summary,population_summary=population_summary,paired_models=paired,paired_designs=design_pairs),file.path(out,'summary.rds'))
print(summary);print(population_summary);print(paired)
