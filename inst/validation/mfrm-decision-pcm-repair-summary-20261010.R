# Audit only the changed records; retain the preceding study's other evidence.
source('inst/validation/mfrm-decision-pcm-repair-20261010.R')
mpr_summarize <- function() {
  metadata_path <- file.path(mpr_root,'metadata.rds'); m <- mde_read(metadata_path)
  stopifnot(identical(mde_sha(names(m$Source)),m$Source),
    identical(mde_sha(names(m$Inputs)),m$Inputs))
  script <- 'inst/validation/mfrm-decision-pcm-repair-summary-20261010.R'
  paths <- file.path(mpr_root,'jobs',m$Plan$JobId,'completed.rds')
  stopifnot(length(paths)==44L,all(file.exists(paths)))
  result_path <- file.path(mpr_root,'summary.rds')
  if(file.exists(result_path)) {
    s <- mde_read(result_path)
    stopifnot(identical(s$MetadataSHA256,mde_sha(metadata_path)),
      identical(s$SummarySourceSHA256,mde_sha(script)),
      identical(s$PhaseSHA256,mde_sha(names(s$PhaseSHA256))))
    cat('Continuation metadata, sources, inputs and all saved phases verified; no repeated numerical work.\n')
    return(invisible(s))
  }
  original <- mde_read(file.path(mfp_root,'summary.rds'))
  records <- original$records; records$Epoch <- 'original_retained'
  metrics <- list(original$replicate_metrics); bins <- list(original$replicate_bins)
  repairs <- list(); updated <- character(); checks <- list(); phase_paths <- paths
  for(i in seq_len(nrow(m$Plan))) {
    job <- m$Plan[i,]; dir <- file.path(mpr_root,'jobs',job$JobId)
    done <- mde_read(paths[i])
    stopifnot(identical(done$Job,job),identical(done$MetadataSHA256,mde_sha(metadata_path)),
      identical(done$PhaseSHA256,mde_sha(names(done$PhaseSHA256))))
    phase_paths <- c(phase_paths,names(done$PhaseSHA256))
    orders <- as.integer(names(done$Stages)); new_seconds <- reused_seconds <- 0
    new_fits <- reused_fits <- 0L
    for(q in orders) {
      f <- mde_read(file.path(dir,paste0('q',q,'-fit.rds')))
      if(f$Origin=='current_public_fit') {new_seconds <- new_seconds+f$elapsed; new_fits <- new_fits+1L}
      else {reused_seconds <- reused_seconds+f$elapsed; reused_fits <- reused_fits+1L}
    }
    ic <- if(is.null(done$InitialCheck))c(OldGradient=NA,NewGradient=NA,ObjectiveChange=NA) else done$InitialCheck
    final_gradient <- tail(done$Stages,1)[[1]]$Gradient
    repairs[[i]] <- data.frame(JobId=job$JobId,N=job$N,Replicate=job$Replicate,
      InitialOrder=job$InitialOrder,SelectedOrder=done$SelectedOrder,SourceReady=done$SourceReady,
      OriginalGradient=ic['OldGradient'],RepairedGradient=ic['NewGradient'],
      FinalGradient=if(length(final_gradient))final_gradient else NA_real_,
      SameOrderObjectiveChange=ic['ObjectiveChange'],
      NewFitPhases=new_fits,ReusedFitPhases=reused_fits,
      NewFitSeconds=new_seconds,HistoricalReusedFitSeconds=reused_seconds,row.names=NULL)
    for(prior in c('retained','reference')) {
      r <- mde_read(file.path(dir,paste0(prior,'-probabilities.rds')))
      at <- match(r$Job$Id,records$Id); old_job <- m$Original$Plan[match(r$Job$Id,m$Original$Plan$Id),]
      stopifnot(!is.na(at),!records$Available[at],identical(r$Job,old_job),
        identical(r$MetadataSHA256,mde_sha(metadata_path)))
      key <- data.frame(N=job$N,Replicate=job$Replicate,Procedure=mfp_procedure(r$Job))
      replay_error <- NA_real_
      if(r$Available) {
        replay_error <- mfp_audit(r,m$Original)
        metrics[[length(metrics)+1L]] <- cbind(key,r$Metrics$metrics)
        bins[[length(bins)+1L]] <- cbind(key,r$Metrics$bins)
      }
      records$Available[at] <- r$Available; records$PriorMean[at] <- r$Prior[1]
      records$PriorSD[at] <- r$Prior[2]; records$Error[at] <- r$Error
      records$Warnings[at] <- paste(r$Warnings,collapse='; ')
      records$Seconds[at] <- r$Seconds; records$ReplayError[at] <- replay_error
      records$Epoch[at] <- 'stationarity_continuation'; updated <- c(updated,r$Job$Id)
      checks[[length(checks)+1L]] <- data.frame(key,Reference=r$Checks['Reference'],
        Legacy=r$Checks['Legacy'],RawLookup=r$Checks['RawLookup'],ReplayError=replay_error,row.names=NULL)
    }
  }
  metrics <- do.call(rbind,metrics); bins <- do.call(rbind,bins)
  repairs <- do.call(rbind,repairs); checks <- do.call(rbind,checks)
  stopifnot(length(updated)==88L,!anyDuplicated(updated),
    !anyDuplicated(metrics[c('N','Replicate','Procedure','Law','Event')]),
    !anyDuplicated(bins[c('N','Replicate','Procedure','Law','Event','Bin')]))
  unchanged <- !records$Id %in% updated
  stopifnot(identical(records[unchanged,names(original$records)],original$records[unchanged,]))
  affected <- function(x) x$N %in% c(240L,480L) &
    x$Procedure %in% c('MML-free-retained','MML-free-reference')
  availability <- original$availability
  availability$OriginalReturned <- availability$Returned
  for(i in which(affected(availability))) {
    r <- records[records$N==availability$N[i] & records$Procedure==availability$Procedure[i],]
    ci <- mde_binomial(sum(r$Available),50L)
    availability[i,c('Returned','Rate','Lower','Upper','NewReturns')] <-
      list(sum(r$Available),mean(r$Available),ci[1],ci[2],sum(!r$HistoricalSourceReady & r$Available))
  }
  decisions <- original$decisions
  measures <- setdiff(names(metrics),c('N','Replicate','Procedure','Law','Event'))
  measurements <- list(original$measurements[!affected(original$measurements),])
  for(i in which(affected(decisions))) {
    key <- decisions[i,c('N','Procedure','Law','Event')]
    rows <- metrics[metrics$N==key$N & metrics$Procedure==key$Procedure &
      metrics$Law==key$Law & metrics$Event==key$Event,]
    intervals <- vapply(rows[measures],mde_mean_interval,numeric(4))
    a <- availability[availability$N==key$N & availability$Procedure==key$Procedure,]
    delivery <- unlist(a[c('Rate','Lower','Upper')])
    bias <- intervals[,'ExpectedBias']; risk <- intervals[,'ExcessBrier']; prior <- intervals[,'TargetPriorDifference']
    decisions[i,] <- data.frame(key,Returned=nrow(rows),Attempts=50L,
      Delivery=delivery['Rate'],DeliveryLower=delivery['Lower'],
      Bias=bias['Mean'],BiasLower=bias['Lower'],BiasUpper=bias['Upper'],
      ExcessBrier=risk['Mean'],RiskLower=risk['Lower'],RiskUpper=risk['Upper'],
      RMSProbabilityError=sqrt(risk['Mean']),
      RMSUpper=if(is.finite(risk['Upper']))sqrt(max(0,risk['Upper'])) else NA_real_,
      ExpectedBrier=intervals['Mean','ExpectedBrier'],TargetPriorBrier=intervals['Mean','TargetPriorBrier'],
      ScoringPriorBrier=intervals['Mean','ScoringPriorBrier'],TargetPriorDifferenceUpper=prior['Upper'],
      AccuracyDecision=if(nrow(rows))mde_decide(c(Rate=1,Lower=1,Upper=1),bias,risk,prior) else 'unavailable',
      Decision=mde_decide(delivery,bias,risk,prior),row.names=NULL)
    measurements[[length(measurements)+1L]] <- cbind(key,Metric=colnames(intervals),
      as.data.frame(t(intervals)),row.names=NULL)
  }
  measurements <- do.call(rbind,measurements)
  # New sources change all three free-MML paired contrasts, including the fixed comparator subset.
  paired <- original$paired
  contrasts <- list('free_retained_minus_fixed'=c('MML-free-retained','MML-fixed'),
    'free_reference_minus_fixed'=c('MML-free-reference','MML-fixed'),
    'free_retained_minus_reference'=c('MML-free-retained','MML-free-reference'))
  for(i in which(paired$N %in% c(240L,480L) & paired$Comparison %in% names(contrasts))) {
    key <- paired[i,]; r <- metrics[metrics$N==key$N & metrics$Law==key$Law & metrics$Event==key$Event,]
    pair <- contrasts[[key$Comparison]]; a <- r[r$Procedure==pair[1],]; b <- r[r$Procedure==pair[2],]
    common <- intersect(a$Replicate,b$Replicate)
    ci <- mde_mean_interval(a$ExpectedBrier[match(common,a$Replicate)]-b$ExpectedBrier[match(common,b$Replicate)])
    paired[i,c('ReturnedA','ReturnedB','Paired','Mean','MCSE','Lower','Upper')] <-
      list(nrow(a),nrow(b),length(common),ci['Mean'],ci['MCSE'],ci['Lower'],ci['Upper'])
  }
  calibration <- original$calibration
  for(i in which(affected(calibration))) {
    key <- calibration[i,]; r <- bins[bins$N==key$N & bins$Procedure==key$Procedure &
      bins$Law==key$Law & bins$Event==key$Event & bins$Bin==key$Bin,]
    ci <- mde_ratio_interval(r$ErrorSum,r$Mass)
    calibration[i,c('Returned','ContributingClusters','Mass','Predicted','Truth','Bias','MCSE','Lower','Upper')] <-
      list(nrow(r),sum(r$Mass>0),if(nrow(r))mean(r$Mass) else NA_real_,
        if(sum(r$Mass)>0)sum(r$PredictionSum)/sum(r$Mass) else NA_real_,
        if(sum(r$Mass)>0)sum(r$TruthSum)/sum(r$Mass) else NA_real_,
        ci['Mean'],ci['MCSE'],ci['Lower'],ci['Upper'])
  }
  stopifnot(identical(decisions[!affected(decisions),],original$decisions[!affected(decisions),]),
    nrow(decisions)==364L,nrow(records)==1000L,nrow(paired)==364L,nrow(calibration)==1820L,
    nrow(measurements)==4368L,all(table(records$N,records$Procedure)==50L),
    all(is.na(calibration$MCSE[calibration$ContributingClusters<2])))
  archive <- file.path(mpr_root,'source',script)
  if(!file.exists(archive)) stopifnot(file.copy(script,archive))
  stopifnot(identical(unname(mde_sha(script)),unname(mde_sha(archive))))
  s <- list(availability=availability,decisions=decisions,measurements=measurements,
    paired=paired,calibration=calibration,records=records,replicate_metrics=metrics,replicate_bins=bins,
    repairs=repairs,checks=checks,ReusedProbabilityJobs=sum(unchanged),NewProbabilityJobs=length(updated),
    OriginalSummarySHA256=mde_sha(file.path(mfp_root,'summary.rds')),
    MetadataSHA256=mde_sha(metadata_path),PhaseSHA256=mde_sha(unique(phase_paths)),
    SummarySourceSHA256=mde_sha(script),Session=sessionInfo())
  mde_save(s,result_path)
  for(name in c('availability','decisions','measurements','paired','calibration','records','replicate_metrics','repairs','checks'))
    write.csv(s[[name]],file.path(mpr_root,paste0(name,'.csv')),row.names=FALSE)
  print(availability); print(table(decisions$Decision))
  cat('New fit phases:',sum(repairs$NewFitPhases),'; retained repair fit phases:',sum(repairs$ReusedFitPhases),
    '; independent metric replay error:',max(checks$ReplayError,na.rm=TRUE),'\n')
  invisible(s)
}
if(sys.nframe()==0L) {
  stopifnot(!'mfrmr' %in% loadedNamespaces()); mpr_summarize()
  stopifnot(!'mfrmr' %in% loadedNamespaces())
}
