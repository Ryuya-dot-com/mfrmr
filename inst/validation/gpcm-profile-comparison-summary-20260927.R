# Summaries for the fixed 100-case post-fit comparison; no fitting or rescue.
summarize_profile_comparison <- function(directory) {
  rows <- read.csv(file.path(directory,'rows.csv'),na.strings='NA')
  plan <- read.csv(file.path(directory,'plan.csv'))
  stopifnot(nrow(rows)==2*nrow(plan), !anyDuplicated(rows[c('Index','Method')]),
    all(!is.na(rows$Covered[rows$Available])), all(is.na(rows$Covered[!rows$Available])))
  model <- rows[rows$Method=='model',]; profile <- rows[rows$Method=='profile',]
  profile <- profile[match(model$Index,profile$Index),]
  stopifnot(identical(model$Index,profile$Index),setequal(model$Index,plan$Index),
    identical(model$Truth,profile$Truth))
  common <- model$Available & profile$Available
  compare <- function(a,b,label) {
    d <- as.numeric(b)-as.numeric(a)
    data.frame(Measure=label,N=length(d),Model=sum(a),Profile=sum(b),
      ProfileOnly=sum(b & !a),ModelOnly=sum(a & !b),
      Difference=if(length(d))mean(d) else NA_real_,
      MCSE=if(length(d)>1)sd(d)/sqrt(length(d)) else NA_real_)
  }
  paired <- rbind(compare(model$Available,profile$Available,'availability'),
    compare(model$Available & !is.na(model$Covered) & model$Covered,
      profile$Available & !is.na(profile$Covered) & profile$Covered,'reported_and_covered'),
    compare(model$Covered[common],profile$Covered[common],'common_available_coverage'))
  write.csv(paired,file.path(directory,'paired.csv'),row.names=FALSE)
  q <- function(x,p) if(length(x)) unname(quantile(x,p)) else NA_real_
  widths <- do.call(rbind,lapply(c('model','profile'),function(method) {
    d <- rows[rows$Method==method,]; w <- d$Upper-d$Lower
    do.call(rbind,lapply(c('available','common_available'),function(subset) {
      take <- if(subset=='available') d$Available else d$Index %in% model$Index[common]
      data.frame(Method=method,Subset=subset,N=sum(take),
        MeanWidth=if(any(take))mean(w[take]) else NA_real_,
        MedianWidth=q(w[take],.5),P90Width=q(w[take],.9),
        TruthBelowInterval=sum(take & d$Lower>d$Truth,na.rm=TRUE),
        TruthAboveInterval=sum(take & d$Upper<d$Truth,na.rm=TRUE))
    }))
  }))
  write.csv(widths,file.path(directory,'widths.csv'),row.names=FALSE)
  times <- do.call(rbind,lapply(c('model','profile'),function(method) {
    d <- rows[rows$Method==method,]
    do.call(rbind,lapply(c('all','available','unavailable'),function(subset) {
      take <- if(subset=='all') rep(TRUE,nrow(d)) else if(subset=='available') d$Available else !d$Available
      data.frame(Method=method,Subset=subset,N=sum(take),TotalElapsed=sum(d$Elapsed[take]),
        MedianElapsed=q(d$Elapsed[take],.5),P90Elapsed=q(d$Elapsed[take],.9),
        TotalCPU=sum(d$CPU[take]),MedianCPU=q(d$CPU[take],.5))
    }))
  }))
  write.csv(times,file.path(directory,'times.csv'),row.names=FALSE)
  failures <- profile[!profile$Available,c('Index','Returned','LowerStatus','UpperStatus','Reason','Warning')]
  write.csv(failures,file.path(directory,'failures.csv'),row.names=FALSE)
  summary <- read.csv(file.path(directory,'summary.csv'))
  summary$Margin <- ifelse(summary$Measure=='availability',.90,
    ifelse(summary$Measure=='conditional_coverage',.925,NA_real_))
  summary$Review <- ifelse(is.na(summary$Margin)|is.na(summary$MCLower),'descriptive',
    ifelse(summary$MCUpper<summary$Margin,'concern',
      ifelse(summary$MCLower>=summary$Margin,'clears_margin_in_this_reanalysis','inconclusive')))
  write.csv(summary,file.path(directory,'review.csv'),row.names=FALSE)
  print(summary); print(paired); print(widths); print(times)
  invisible(list(review=summary,paired=paired,widths=widths,times=times,failures=failures))
}

# Inject asymmetric availability, a miss and an unresolved interval. Reuses the
# proportion summary from the runner; no package fitting or simulated outcomes.
check_profile_comparison_summary <- function() {
  directory <- tempfile('profile-summary-'); dir.create(directory)
  on.exit(unlink(directory,recursive=TRUE))
  rows <- data.frame(Index=rep(1:3,2),Method=rep(c('model','profile'),each=3),
    Truth=1,Available=c(TRUE,TRUE,FALSE,TRUE,FALSE,TRUE),
    Covered=c(TRUE,FALSE,NA,FALSE,NA,TRUE),Lower=c(.5,1.2,NA,1.2,NA,.5),
    Upper=c(1.5,1.8,NA,1.8,NA,1.5),Returned=TRUE,
    LowerStatus='',UpperStatus='',Reason='',Warning='',Elapsed=1,CPU=.5)
  write.csv(rows,file.path(directory,'rows.csv'),row.names=FALSE)
  write.csv(data.frame(Index=1:3),file.path(directory,'plan.csv'),row.names=FALSE)
  write.csv(profile_comparison_summary(rows,3),file.path(directory,'summary.csv'),row.names=FALSE)
  invisible(capture.output(out <- summarize_profile_comparison(directory)))
  stopifnot(identical(out$paired$N,c(3L,3L,1L)),
    identical(out$paired$Difference,c(0,0,-1)),
    all(out$paired$ProfileOnly[1:2]==1), all(out$paired$ModelOnly[1:2]==1),
    all(out$review$Covered==1),all(out$review$Available==2),
    all(abs(out$review$UnresolvedUpper-2/3)<1e-12),
    nrow(out$failures)==1,out$failures$Index==2,
    sum(out$times$TotalElapsed[out$times$Subset=='all'])==6)
  invisible(TRUE)
}

profile_comparison_checks <- function(directory) {
  plan <- read.csv(file.path(directory,'plan.csv'))
  saved_checks <- lapply(plan$Index,function(i) {
    saved <- readRDS(file.path(directory,sprintf('case-%03d.rds',i)))
    result <- saved$results[[2]]$result
    profile <- attr(result,'profile'); attempts <- profile$attempts
    checks <- do.call(rbind,lapply(names(attempts),function(value) {
      do.call(rbind,lapply(names(attempts[[value]]),function(start) {
        data.frame(Index=i,LogSlope=as.numeric(value),Start=start,
          attempts[[value]][[start]]$check,row.names=NULL)
      }))
    }))
    points <- if(!is.null(profile)) data.frame(Index=i,profile$profile,row.names=NULL) else NULL
    list(checks=checks,points=points)
  })
  checks <- do.call(rbind,lapply(saved_checks,`[[`,'checks'))
  points <- do.call(rbind,lapply(saved_checks,`[[`,'points'))
  write.csv(checks,file.path(directory,'numerical-checks.csv'),row.names=FALSE)
  write.csv(points[!points$Passed,],file.path(directory,'failed-points.csv'),row.names=FALSE)
  invisible(checks)
}
