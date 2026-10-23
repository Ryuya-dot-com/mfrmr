# Independent saved-data audit and calibration-cluster analysis; no package loading.
source('inst/validation/mfrm-decision-pcm-retained-20261010.R')
mfp_procedure <- function(job) if(job$Arm=='PCM-MML-free')
  paste0('MML-free-',job$Prior) else sub('PCM-','',job$Arm)
mfp_procedures <- c('MML-fixed','MML-free-retained','MML-free-reference','JML')

mfp_audit <- function(r,meta) {
  p <- r$Probabilities
  stopifnot(identical(p,mfp_matrix(r$Prediction,rownames(p),r$Prior)))
  panels <- mfp_phase(r$Job$PanelPath)$payload$panels
  laws <- if(r$Job$N==30) 'population_L1' else names(mfp_laws)
  max_error <- 0
  for(law in laws) {
    o <- meta$Oracle[[law]]; w <- o$weight; q <- o$p
    panel <- panels[[law]]; ids <- panel$planned$Person; theta <- panel$planned$Theta
    raw <- matrix(NA_real_,60L,9L)
    slot <- as.integer(panel$data$Rater)+3L*(as.integer(panel$data$Criterion)-1L)
    ix <- cbind(match(panel$data$Person,ids),slot)
    stopifnot(!anyNA(ix),!anyDuplicated(ix)); raw[ix] <- panel$data$Score
    mask <- drop((!is.na(raw)) %*% 2^(0:8))
    stopifnot(all(rowSums(!is.na(raw))==6),all(table(mask)==20))
    at <- match(paste(mask,rowSums(raw,na.rm=TRUE)),paste(o$keys$Mask,o$keys$Total))
    stopifnot(!anyNA(at))
    z <- cbind(theta> -1,theta>0,theta>1,theta<= -1,
      theta> -1 & theta<=0,theta>0 & theta<=1,theta>1)*1
    estimated <- p[at,]; known <- q[at,]
    expected <- colSums((p^2-2*p*q+q)*w)
    oracle <- colSums(q*(1-q)*w)
    target_prior <- o$prior*(1-o$prior)
    used <- c(pnorm(c(-1,0,1),r$Prior[1],r$Prior[2],lower.tail=FALSE),
      diff(pnorm(c(-Inf,-1,0,1,Inf),r$Prior[1],r$Prior[2])))
    used_loss <- used^2-2*used*o$prior+o$prior
    found <- r$Metrics$metrics[r$Metrics$metrics$Law==law,]
    stopifnot(identical(found$Event,mde_events))
    expected_values <- cbind(ExpectedBias=colSums(p*w)-o$prior,
      ExcessBrier=expected-oracle,OracleBrier=oracle,ExpectedBrier=expected,
      TargetPriorBrier=target_prior,ScoringPriorBrier=used_loss,
      TargetPriorDifference=expected-target_prior,ScoringPriorDifference=expected-used_loss,
      RealizedBias=colMeans(estimated-z),RealizedBrier=colMeans((estimated-z)^2),
      RealizedOracleBrier=colMeans((known-z)^2),
      RealizedExcess=colMeans((estimated-z)^2)-colMeans((known-z)^2))
    max_error <- max(max_error,abs(expected_values-as.matrix(found[colnames(expected_values)])))
    for(j in 1:7) for(b in 1:5) {
      take <- p[,j]>=(b-1)/5 & (p[,j]<b/5 | (b==5 & p[,j]==1))
      values <- c(Mass=sum(w[take]),ErrorSum=sum(w[take]*(p-q)[take,j]),
        PredictionSum=sum(w[take]*p[take,j]),TruthSum=sum(w[take]*q[take,j]))
      found <- r$Metrics$bins
      found <- found[found$Law==law & found$Event==mde_events[j] & found$Bin==b,]
      stopifnot(nrow(found)==1)
      max_error <- max(max_error,abs(unlist(found[names(values)])-values))
    }
  }
  stopifnot(max_error<1e-10); max_error
}
mfp_summarize <- function() {
  metadata_path <- file.path(mfp_root,'metadata.rds'); meta <- mde_read(metadata_path)
  stopifnot(identical(mde_sha(names(meta$Source)),meta$Source))
  mfp_verify_inputs(meta,names(meta$Inputs))
  script <- 'inst/validation/mfrm-decision-pcm-summary-20261010.R'
  paths <- setNames(file.path(mfp_root,'jobs',paste0(meta$Plan$Id,'.rds')),meta$Plan$Id)
  stopifnot(all(file.exists(paths)),length(paths)==1000L)
  result_path <- file.path(mfp_root,'summary.rds')
  if(file.exists(result_path)) {
    saved <- mde_read(result_path)
    stopifnot(identical(saved$SummarySourceSHA256,mde_sha(script)),
      identical(saved$MetadataSHA256,mde_sha(metadata_path)),
      identical(saved$RecordSHA256,mde_sha(unname(paths))))
    cat('Completed summary and all input/result hashes verified; no repeated scoring or arithmetic audit.\n')
    return(invisible(saved))
  }
  records <- metrics <- bins <- list()
  for(i in seq_len(nrow(meta$Plan))) {
    job <- meta$Plan[i,]; r <- mde_read(paths[[job$Id]])
    stopifnot(identical(r$Job,job),identical(r$MetadataSHA256,mde_sha(metadata_path)))
    key <- data.frame(N=job$N,Replicate=job$Replicate,Procedure=mfp_procedure(job))
    replay_error <- NA_real_
    if(r$Available) {
      replay_error <- mfp_audit(r,meta)
      metrics[[length(metrics)+1L]] <- cbind(key,r$Metrics$metrics)
      bins[[length(bins)+1L]] <- cbind(key,r$Metrics$bins)
    }
    records[[i]] <- data.frame(key,Id=job$Id,Available=r$Available,
      HistoricalSourceReady=job$HistoricalReady,PriorMean=r$Prior[1],PriorSD=r$Prior[2],
      Error=r$Error,Warnings=paste(r$Warnings,collapse='; '),Seconds=r$Seconds,
      ReplayError=replay_error,row.names=NULL)
    if(i%%200==0) {cat('Audited',i,'/1000 jobs\n'); flush.console()}
  }
  records <- do.call(rbind,records); metrics <- do.call(rbind,metrics); bins <- do.call(rbind,bins)
  targets <- do.call(rbind,lapply(mfp_ns,function(n) expand.grid(N=n,
    Procedure=mfp_procedures,Law=if(n==30) 'population_L1' else names(mfp_laws),
    Event=mde_events,stringsAsFactors=FALSE)))
  availability <- do.call(rbind,lapply(mfp_ns,function(n) do.call(rbind,
    lapply(mfp_procedures,function(procedure) {
      r <- records[records$N==n & records$Procedure==procedure,]
      stopifnot(nrow(r)==50L,setequal(r$Replicate,1:50))
      ci <- mde_binomial(sum(r$Available),50L)
      data.frame(N=n,Procedure=procedure,Attempts=50L,Returned=sum(r$Available),
        Rate=mean(r$Available),Lower=ci[1],Upper=ci[2],
        HistoricalSourceReady=sum(r$HistoricalSourceReady),
        NewRefusals=sum(r$HistoricalSourceReady & !r$Available),
        NewReturns=sum(!r$HistoricalSourceReady & r$Available),row.names=NULL)
    }))))
  decisions <- measurements <- list()
  measures <- setdiff(names(metrics),c('N','Replicate','Procedure','Law','Event'))
  for(i in seq_len(nrow(targets))) {
    key <- targets[i,]
    rows <- metrics[metrics$N==key$N & metrics$Procedure==key$Procedure &
      metrics$Law==key$Law & metrics$Event==key$Event,]
    intervals <- vapply(rows[measures],mde_mean_interval,numeric(4))
    delivered <- availability[availability$N==key$N & availability$Procedure==key$Procedure,]
    delivery <- unlist(delivered[c('Rate','Lower','Upper')])
    bias <- intervals[,'ExpectedBias']; risk <- intervals[,'ExcessBrier']
    prior <- intervals[,'TargetPriorDifference']
    accuracy <- if(!nrow(rows)) 'unavailable' else
      mde_decide(c(Rate=1,Lower=1,Upper=1),bias,risk,prior)
    decisions[[i]] <- data.frame(key,Returned=nrow(rows),Attempts=50L,
      Delivery=delivery['Rate'],DeliveryLower=delivery['Lower'],
      Bias=bias['Mean'],BiasLower=bias['Lower'],BiasUpper=bias['Upper'],
      ExcessBrier=risk['Mean'],RiskLower=risk['Lower'],RiskUpper=risk['Upper'],
      RMSProbabilityError=sqrt(risk['Mean']),
      RMSUpper=if(is.finite(risk['Upper']))sqrt(max(0,risk['Upper'])) else NA_real_,
      ExpectedBrier=intervals['Mean','ExpectedBrier'],
      TargetPriorBrier=intervals['Mean','TargetPriorBrier'],
      ScoringPriorBrier=intervals['Mean','ScoringPriorBrier'],
      TargetPriorDifferenceUpper=prior['Upper'],
      AccuracyDecision=accuracy,Decision=mde_decide(delivery,bias,risk,prior),row.names=NULL)
    measurements[[i]] <- cbind(key,Metric=colnames(intervals),as.data.frame(t(intervals)),row.names=NULL)
  }
  decisions <- do.call(rbind,decisions); measurements <- do.call(rbind,measurements)
  contrasts <- list('free_retained_minus_fixed'=c('MML-free-retained','MML-fixed'),
    'free_reference_minus_fixed'=c('MML-free-reference','MML-fixed'),
    'free_retained_minus_reference'=c('MML-free-retained','MML-free-reference'),
    'jml_minus_fixed'=c('JML','MML-fixed'))
  comparison_keys <- unique(targets[c('N','Law','Event')])
  paired <- do.call(rbind,lapply(seq_len(nrow(comparison_keys)),function(i) {
    key <- comparison_keys[i,]
    r <- metrics[metrics$N==key$N & metrics$Law==key$Law & metrics$Event==key$Event,]
    do.call(rbind,lapply(names(contrasts),function(name) {
      pair <- contrasts[[name]]
      a <- r[r$Procedure==pair[1],]; b <- r[r$Procedure==pair[2],]
      common <- intersect(a$Replicate,b$Replicate)
      difference <- a$ExpectedBrier[match(common,a$Replicate)]-
        b$ExpectedBrier[match(common,b$Replicate)]
      ci <- mde_mean_interval(difference)
      data.frame(key,Comparison=name,ReturnedA=nrow(a),ReturnedB=nrow(b),
        Paired=length(common),Attempts=50L,Mean=ci['Mean'],MCSE=ci['MCSE'],
        Lower=ci['Lower'],Upper=ci['Upper'],row.names=NULL)
    }))
  }))
  bin_keys <- targets[rep(seq_len(nrow(targets)),each=5L),]
  bin_keys$Bin <- rep(1:5,nrow(targets))
  calibration <- do.call(rbind,lapply(seq_len(nrow(bin_keys)),function(i) {
    key <- bin_keys[i,]
    r <- bins[bins$N==key$N & bins$Procedure==key$Procedure & bins$Law==key$Law &
      bins$Event==key$Event & bins$Bin==key$Bin,]
    ci <- mde_ratio_interval(r$ErrorSum,r$Mass)
    data.frame(key,Returned=nrow(r),ContributingClusters=sum(r$Mass>0),
      Mass=if(nrow(r))mean(r$Mass) else NA_real_,
      Predicted=if(sum(r$Mass)>0)sum(r$PredictionSum)/sum(r$Mass) else NA_real_,
      Truth=if(sum(r$Mass)>0)sum(r$TruthSum)/sum(r$Mass) else NA_real_,
      Bias=ci['Mean'],MCSE=ci['MCSE'],Lower=ci['Lower'],Upper=ci['Upper'],row.names=NULL)
  }))
  stopifnot(nrow(decisions)==364L,nrow(paired)==364L,nrow(calibration)==1820L,
    all(table(records$N,records$Procedure)==50L),
    all(is.na(calibration$MCSE[calibration$ContributingClusters<2])))
  link_path <- file.path(mfp_root,'input-link-verification.rds')
  if(!file.exists(link_path)) {
    jobs <- meta$Plan[!duplicated(meta$Plan$JobId),]
    for(i in seq_len(nrow(jobs))) {
      job <- jobs[i,]; spec <- mfp_phase(job$ManifestPath)$payload$spec
      panel <- mfp_phase(job$PanelPath)$payload
      stopifnot(identical(spec$InputId,panel$calibration_input),
        spec$ConditionId==job$ConditionId,spec$Replicate==job$Replicate,spec$Arm==job$Arm)
    }
    saveRDS(list(Sources=nrow(jobs),InputIdentifiersMatched=TRUE,
      MetadataSHA256=mde_sha(metadata_path)),link_path)
  }
  input_links <- readRDS(link_path)
  stopifnot(input_links$Sources==750L,isTRUE(input_links$InputIdentifiersMatched),
    identical(input_links$MetadataSHA256,mde_sha(metadata_path)))
  archive <- file.path(mfp_root,'source',script)
  if(!file.exists(archive)) stopifnot(file.copy(script,archive))
  stopifnot(identical(unname(mde_sha(script)),unname(mde_sha(archive))))
  results <- list(availability=availability,decisions=decisions,measurements=measurements,
    paired=paired,calibration=calibration,records=records,replicate_metrics=metrics,replicate_bins=bins,
    MetadataSHA256=mde_sha(metadata_path),RecordSHA256=mde_sha(unname(paths)),
    SummarySourceSHA256=mde_sha(script),InputLinkAudit=input_links,
    ReplayMaxError=max(records$ReplayError,na.rm=TRUE),
    CalibrationBundles=250L,HistoricalFits=750L,ProfileJobs=1000L,
    DistinctSavedFuturePersons=39000L,NewFits=0L,NewDraws=0L,Session=sessionInfo())
  mde_save(results,result_path)
  for(name in c('availability','decisions','measurements','paired','calibration','records','replicate_metrics'))
    write.csv(results[[name]],file.path(mfp_root,paste0(name,'.csv')),row.names=FALSE)
  print(availability)
  print(with(decisions,table(Law,AccuracyDecision)))
  print(table(decisions$Decision))
  cat('Maximum independent replay error:',results$ReplayMaxError,'\n')
  invisible(results)
}
if(sys.nframe()==0L) {
  stopifnot(!'mfrmr' %in% loadedNamespaces()); mfp_summarize()
  stopifnot(!'mfrmr' %in% loadedNamespaces())
}
