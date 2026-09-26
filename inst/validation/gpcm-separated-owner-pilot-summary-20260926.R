summarize_separate_owner_pilot <- function(output_dir) {
  saved <- readRDS(file.path(output_dir,'results.rds'))
  plan <- saved$manifest$plan
  template <- Filter(Negate(is.null),saved$results)[[1]]$rows
  points <- checks <- vector('list',nrow(plan))
  for (i in seq_len(nrow(plan))) {
    result <- saved$results[[i]]
    tab <- if (is.null(result)) template else result$rows
    if (is.null(result)) {
      tab$Estimate <- tab$Lower <- tab$Upper <- NA_real_
      tab$Available <- FALSE; tab$Covered <- NA; tab$Reason <- 'Planned but not executed'
    }
    points[[i]] <- cbind(plan[rep(i,nrow(tab)),],Executed=!is.null(result),tab)
    ch <- if (is.null(result)) list(Returned=FALSE,OptimizerCode=NA_integer_,
      InformationStatus=NA_character_,Integration=NA_character_,Quadrature=NA_integer_,
      Reason='Planned but not executed',Elapsed=NA_real_) else result$checks
    checks[[i]] <- cbind(plan[i,],Executed=!is.null(result),as.data.frame(ch),
      Warnings=if(is.null(result)) '' else paste(result$warnings,collapse=' | '))
  }
  points <- do.call(rbind,points); checks <- do.call(rbind,checks)
  avg <- function(x) if(length(x)) mean(x) else NA_real_
  exact <- function(k,n) if(n) unname(binom.test(k,n)$conf.int) else c(NA_real_,NA_real_)
  groups <- split(points,interaction(points$N,points$Design,points$Family,points$Target,drop=TRUE))
  summary <- do.call(rbind,lapply(groups,function(x) {
    finite <- is.finite(x$Estimate); e <- x$Estimate[finite]-x$Truth[finite]
    n <- nrow(x); a <- sum(x$Available); c <- sum(x$Covered,na.rm=TRUE)
    coverage <- exact(c,a); availability <- exact(a,n); reported <- exact(c,n)
    interval <- x$Family[1]!='step'
    data.frame(N=x$N[1],Design=x$Design[1],Family=x$Family[1],Target=x$Target[1],Truth=x$Truth[1],
      Planned=n,Executed=sum(x$Executed),PointReturned=sum(finite),Bias=avg(e),RMSE=sqrt(avg(e^2)),
      IntervalTarget=interval,Available=if(interval)a else NA_integer_,
      Availability=if(interval)a/n else NA_real_,
      AvailabilityLower=if(interval)availability[1] else NA_real_,
      AvailabilityUpper=if(interval)availability[2] else NA_real_,
      Covered=if(interval)c else NA_integer_,
      CoverageIfAvailable=if(interval && a)c/a else NA_real_,
      CoverageLower=if(interval)coverage[1] else NA_real_,
      CoverageUpper=if(interval)coverage[2] else NA_real_,
      ReportedAndCovered=if(interval)c/n else NA_real_,
      ReportedCoveredLower=if(interval)reported[1] else NA_real_,
      ReportedCoveredUpper=if(interval)reported[2] else NA_real_,
      CoverageWorstCase=if(interval)c/n else NA_real_,
      CoverageBestCase=if(interval)(c+n-a)/n else NA_real_,
      MeanWidth=if(interval)avg((x$Upper-x$Lower)[x$Available]) else NA_real_)
  }))
  rownames(summary) <- NULL
  write.csv(points,file.path(output_dir,'target-results.csv'),row.names=FALSE)
  write.csv(checks,file.path(output_dir,'dataset-checks.csv'),row.names=FALSE)
  write.csv(summary,file.path(output_dir,'target-summary.csv'),row.names=FALSE)
  # Paired complete/incomplete errors: each replicate is one independent pair.
  paired <- merge(points[points$Design=='complete',],points[points$Design=='incomplete',],
    by=c('N','Replicate','Family','Target'),suffixes=c('Complete','Incomplete'))
  paired$AbsoluteErrorChange <- abs(paired$EstimateIncomplete-paired$TruthIncomplete)-
    abs(paired$EstimateComplete-paired$TruthComplete)
  paired$WidthChange <- (paired$UpperIncomplete-paired$LowerIncomplete)-
    (paired$UpperComplete-paired$LowerComplete)
  write.csv(paired[c('N','Replicate','Family','Target','AvailableComplete','AvailableIncomplete',
    'AbsoluteErrorChange','WidthChange')],file.path(output_dir,'paired-results.csv'),row.names=FALSE)
  print(checks[!checks$Returned | nzchar(checks$Reason),c('Case','Reason')],row.names=FALSE)
  print(summary[summary$Family=='slope',c('N','Design','Target','Planned','Available','Bias','RMSE',
    'CoverageIfAvailable','CoverageLower','CoverageUpper','MeanWidth')],row.names=FALSE)
  invisible(list(summary=summary,checks=checks,points=points,paired=paired))
}
