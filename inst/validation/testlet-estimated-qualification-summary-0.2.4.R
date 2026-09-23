# Complete-roster analysis; no fitting, scoring or replacement of failed trials.
out <- 'validation-results/testlet-estimated-qualification-20260923'
p <- readRDS(file.path(out,'main-protocol.rds'))
hash <- tools::md5sum(file.path(out,'main-source',names(p$source)))
names(hash) <- names(p$source); stopifnot(identical(hash,p$source))
paths <- file.path(out,sprintf('main-%04d.rds',p$roster$Trial))
stopifnot(all(file.exists(paths)),nrow(p$roster)==480L)
mc <- function(x,probability=FALSE) {
  x<-x[is.finite(x)];n<-length(x);est<-if(n) mean(x) else NA_real_
  se<-if(n>1) sd(x)/sqrt(n) else NA_real_
  delta<-if(n>1) qt(.975,n-1)*se else NA_real_
  lo<-est-delta;hi<-est+delta
  if(probability) {lo<-max(0,lo);hi<-min(1,hi)}
  c(N=n,Estimate=est,MCSE=se,Lower=lo,Upper=hi)
}
binomial <- function(x) {
  n<-length(x);est<-mean(x);bounds<-binom.test(sum(x),n)$conf.int
  c(N=n,Estimate=est,MCSE=sqrt(est*(1-est)/n),Lower=bounds[1],Upper=bounds[2])
}
decision <- function(cov,avail) {
  if(!is.finite(cov['Upper'])) return('unavailable')
  if(cov['Upper']<.925) return('adverse_undercoverage')
  if(cov['Lower']>=.925 && cov['Estimate']<=.975 && avail['Lower']>=.95) return('bounded_support')
  'inconclusive'
}
person_rows<-panels<-fit_rows<-contrast_rows<-list()
for (i in seq_along(paths)) {
  saved<-readRDS(paths[i]);stopifnot(identical(saved$roster,p$roster[i,,drop=FALSE]))
  x<-saved$result;id<-saved$roster; c<-x$generated$condition
  selected<-sprintf('P%03d',1:12);truth<-unname(x$generated$theta[selected])
  f<-x$fits$testlet;o<-x$fits$ordinary
  if(!is.null(f)) stopifnot(identical(f$input$data,x$generated$data[unique(c('Person','Score','Task','Criterion'))]))
  for (method in c('testlet','ordinary','oracle')) {
    s<-x$scores[[method]]
    row<-data.frame(Person=selected,Truth=truth,Estimate=NA_real_,ConditionalSD=NA_real_,
      Lower=NA_real_,Upper=NA_real_,Status='unavailable',Reason='Fit or scoring unavailable')
    if(!is.null(s)) {
      stopifnot(setequal(s$table$Person,selected),!anyDuplicated(s$table$Person))
      at<-match(selected,s$table$Person)
      for (name in c('Estimate','ConditionalSD','Lower','Upper','Status','Reason')) row[[name]]<-s$table[[name]][at]
      if(method=='ordinary') {
        origin<-as.numeric(o$population$coefficients)
        stopifnot(length(origin)==1L,is.finite(origin))
        row[c('Estimate','Lower','Upper')]<-row[c('Estimate','Lower','Upper')]-origin
      }
    }
    row$Available<-row$Status=='available_conditional' & is.finite(row$Estimate) &
      is.finite(row$ConditionalSD) & row$ConditionalSD>0 & is.finite(row$Lower) & is.finite(row$Upper)
    row$Covered<-ifelse(row$Available,row$Lower<=row$Truth & row$Upper>=row$Truth,NA)
    row$Width<-ifelse(row$Available,row$Upper-row$Lower,NA_real_)
    row$Error<-ifelse(row$Available,row$Estimate-row$Truth,NA_real_)
    row$AbilityBand<-ifelse(row$Truth< -1.3,'below_-1.3',ifelse(row$Truth>1.3,'above_1.3','within_1.3'))
    person_rows[[length(person_rows)+1L]]<-cbind(id[rep(1,12),],Method=method,row)
    complete<-all(row$Available)
    panels[[length(panels)+1L]]<-data.frame(id,Method=method,Complete=complete,
      Available=sum(row$Available),Covered=sum(row$Covered %in% TRUE),
      Coverage=if(complete) mean(row$Covered) else NA_real_,
      Width=if(complete) mean(row$Width) else NA_real_,
      Bias=if(complete) mean(row$Error) else NA_real_,
      MSE=if(complete) mean(row$Error^2) else NA_real_)
  }
  fit_rows[[i]]<-data.frame(id,N=c$N,TrueLocalVariance=c$Variance,
    InitialReady=isTRUE(x$attempts$testlet_61$checks$NumericalReady),
    Refined='testlet_refit' %in% names(x$elapsed),
    TestletReady=!is.null(f) && isTRUE(f$checks$NumericalReady) && isTRUE(f$checks$InformationPositive),
    LocalBoundary=isTRUE(f$checks$EstimatedVarianceBoundary),PersonBoundary=isTRUE(f$checks$EstimatedPersonVarianceBoundary),
    PersonSD=if(!is.null(f)) f$calibration$person_sd else NA_real_,
    LocalVariance=if(!is.null(f)) f$calibration$variance else NA_real_,
    QuadPoints=if(!is.null(f)) f$settings$quad_points else NA_integer_,
    OrdinaryPersonSD=if(!is.null(o)) sqrt(o$population$sigma2) else NA_real_,
    Seconds=sum(x$elapsed),FitError=paste(unlist(x$errors[c('testlet_fit','testlet_refit')]),collapse=' | '),
    ScoreError=paste(unlist(x$errors[c('testlet_score','ordinary_score','oracle_score')]),collapse=' | '))
  target<-data.frame(id,Estimate=NA_real_,SE=NA_real_,Lower=NA_real_,Upper=NA_real_,
    PointAvailable=FALSE,IntervalAvailable=FALSE,OrdinaryEstimate=NA_real_)
  if(!is.null(f)) {
    basis<-f$input$basis$Criterion;contrast<-basis['C3',]-basis['C1',]
    at<-ncol(f$input$basis$Task)+seq_len(ncol(basis))
    target$Estimate<-sum(contrast*f$calibration$beta[at])
    ready<-isTRUE(f$checks$NumericalReady) && isTRUE(f$checks$InformationPositive)
    target$PointAvailable<-ready && is.finite(target$Estimate)
    regular<-ready && !isTRUE(f$checks$EstimatedVarianceBoundary) && !isTRUE(f$checks$EstimatedPersonVarianceBoundary)
    if(regular) {
      target$SE<-sqrt(drop(contrast %*% f$covariance[at,at,drop=FALSE] %*% contrast))
      target$Lower<-target$Estimate-qnorm(.975)*target$SE;target$Upper<-target$Estimate+qnorm(.975)*target$SE
      target$IntervalAvailable<-all(is.finite(unlist(target[c('SE','Lower','Upper')])) )
    }
  }
  if(!is.null(o)) {
    ot<-subset(o$facets$others,Facet=='Criterion')
    target$OrdinaryEstimate<-ot$Estimate[match('C3',ot$Level)]-ot$Estimate[match('C1',ot$Level)]
  }
  target$Covered<-ifelse(target$IntervalAvailable,target$Lower<=.6 & target$Upper>=.6,NA)
  contrast_rows[[i]]<-target
}
persons<-do.call(rbind,person_rows);panels<-do.call(rbind,panels)
fits<-do.call(rbind,fit_rows);contrasts<-do.call(rbind,contrast_rows)
for(name in c('persons','panels','fits','contrasts')) write.csv(get(name),file.path(out,paste0(name,'.csv')),row.names=FALSE)
primary<-do.call(rbind,lapply(split(panels,list(panels$Condition,panels$Method),drop=TRUE),function(d) {
  cv<-mc(d$Coverage,TRUE);av<-binomial(d$Complete)
  data.frame(Condition=d$Condition[1],Method=d$Method[1],Planned=nrow(d),Complete=sum(d$Complete),
    Availability=av['Estimate'],AvailabilityLower=av['Lower'],AvailabilityUpper=av['Upper'],
    Coverage=cv['Estimate'],CoverageMCSE=cv['MCSE'],CoverageLower=cv['Lower'],CoverageUpper=cv['Upper'],
    Width=mean(d$Width,na.rm=TRUE),MSE=mean(d$MSE,na.rm=TRUE),Bias=mean(d$Bias,na.rm=TRUE),
    AvailablePersons=sum(d$Available),PlannedPersons=12*nrow(d),
    AllTrialLower=sum(d$Covered)/(12*nrow(d)),
    AllTrialUpper=(sum(d$Covered)+12*nrow(d)-sum(d$Available))/(12*nrow(d)),
    Decision=decision(cv,av),row.names=NULL)
}))
paired<-list()
for(c in 1:4) for(comparator in c('ordinary','oracle')) {
  a<-subset(panels,Condition==c & Method=='testlet'); b<-subset(panels,Condition==c & Method==comparator)
  b<-b[match(a$Trial,b$Trial),]; stopifnot(identical(a$Trial,b$Trial))
  ok<-a$Complete & b$Complete
  for(metric in c('Coverage','MSE','Bias','Width')) {
    m<-mc(a[[metric]][ok]-b[[metric]][ok],FALSE)
    paired[[length(paired)+1L]]<-data.frame(Condition=c,Comparator=comparator,Metric=metric,as.list(m),row.names=NULL)
  }
}
paired<-do.call(rbind,paired)
population<-do.call(rbind,lapply(split(fits,fits$Condition),function(d) {
  do.call(rbind,lapply(c('PersonSD','LocalVariance'),function(target) {
    truth<-if(target=='PersonSD')1.3 else d$TrueLocalVariance[1]
    margin<-if(target=='PersonSD').13 else .08
    v<-mc(d[[target]][d$TestletReady]-truth)
    data.frame(Condition=d$Condition[1],Target=target,Truth=truth,as.list(v),
      Boundaries=sum(if(target=='PersonSD')d$PersonBoundary else d$LocalBoundary),
      ClearAdverseBias=is.finite(v['Lower']) && (v['Lower']>margin || v['Upper']< -margin),row.names=NULL)
  }))
}))
contrast_summary<-do.call(rbind,lapply(split(contrasts,contrasts$Condition),function(d) {
  bias<-mc(d$Estimate[d$PointAvailable]-.6);cover<-mc(as.numeric(d$Covered[d$IntervalAvailable]),TRUE)
  avail<-binomial(d$IntervalAvailable)
  data.frame(Condition=d$Condition[1],PointAvailable=sum(d$PointAvailable),FiniteIntervals=sum(d$IntervalAvailable),
    Bias=bias['Estimate'],BiasMCSE=bias['MCSE'],BiasLower=bias['Lower'],BiasUpper=bias['Upper'],
    ClearAdverseBias=is.finite(bias['Lower']) && (bias['Lower']>.1 || bias['Upper']< -.1),
    Coverage=cover['Estimate'],CoverageMCSE=cover['MCSE'],CoverageLower=cover['Lower'],CoverageUpper=cover['Upper'],
    AvailabilityLower=avail['Lower'],Decision=decision(cover,avail),row.names=NULL)
}))
# Ability-band results keep the dataset as the independent MC unit; zero-count
# bands contribute no conditional estimate, not a fabricated zero coverage.
band_rows<-do.call(rbind,lapply(split(persons,list(persons$Trial,persons$Method,persons$AbilityBand),drop=TRUE),function(d)
  data.frame(Condition=d$Condition[1],Trial=d$Trial[1],Method=d$Method[1],Band=d$AbilityBand[1],
    N=nrow(d),Available=sum(d$Available),Coverage=mean(d$Covered,na.rm=TRUE),Bias=mean(d$Error,na.rm=TRUE))))
bands<-do.call(rbind,lapply(split(band_rows,list(band_rows$Condition,band_rows$Method,band_rows$Band),drop=TRUE),function(d)
  data.frame(Condition=d$Condition[1],Method=d$Method[1],Band=d$Band[1],Persons=sum(d$N),
    Available=sum(d$Available),as.list(mc(d$Coverage,TRUE)),Bias=mean(d$Bias,na.rm=TRUE),row.names=NULL)))
for(name in c('primary','paired','population','contrast_summary','bands')) write.csv(get(name),file.path(out,paste0(name,'.csv')),row.names=FALSE)
saveRDS(list(primary=primary,paired=paired,population=population,contrast=contrast_summary,bands=bands),file.path(out,'summary.rds'))
print(primary);print(paired);print(population);print(contrast_summary)
