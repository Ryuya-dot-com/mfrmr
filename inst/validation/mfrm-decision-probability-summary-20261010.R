# Summarize and independently replay saved probabilities; never fits or scores.
source('inst/validation/mfrm-decision-probability-evaluation-20261010.R')

mde_mean_interval <- function(x) {
  n <- length(x); stopifnot(all(is.finite(x)))
  if(n<2L) return(c(Mean=if(n) mean(x) else NA_real_,MCSE=NA,Lower=NA,Upper=NA))
  se <- sd(x)/sqrt(n); half <- qt(.975,n-1L)*se
  c(Mean=mean(x),MCSE=se,Lower=mean(x)-half,Upper=mean(x)+half)
}
mde_ratio_interval <- function(numerator,denominator) {
  n <- length(numerator)
  if(!any(denominator>0)) return(c(Mean=NA,MCSE=NA,Lower=NA,Upper=NA))
  estimate <- sum(numerator)/sum(denominator)
  if(sum(denominator>0)<2L) return(c(Mean=estimate,MCSE=NA,Lower=NA,Upper=NA))
  se <- sd(numerator-estimate*denominator)/(sqrt(n)*mean(denominator))
  c(Mean=estimate,MCSE=se,Lower=estimate-qt(.975,n-1)*se,Upper=estimate+qt(.975,n-1)*se)
}
mde_binomial <- function(k,n) {
  # Independent qbeta expression also checks the reporting implementation.
  ci <- c(if(k==0) 0 else qbeta(.025,k,n-k+1),
    if(k==n) 1 else qbeta(.975,k+1,n-k))
  stopifnot(max(abs(ci-binom.test(k,n)$conf.int))<1e-12)
  c(Lower=ci[1],Upper=ci[2])
}
mde_decide <- function(delivery,bias,risk,prior) {
  supported <- isTRUE(delivery['Rate']>=.98 && delivery['Lower']>=.98 &&
    bias['Lower']>=-.02 && bias['Upper']<=.02 && risk['Upper']<=.0025 && prior['Upper']<0)
  adverse <- any(c(delivery['Upper']<.98,bias['Lower']>.02,bias['Upper']< -.02,
    risk['Lower']>.0025,prior['Lower']>=0),na.rm=TRUE)
  if(supported) 'supported' else if(adverse) 'repair_required' else 'unresolved'
}
mde_replay <- function(record,x,oracle) {
  p <- record$Probabilities; q <- oracle$p
  stopifnot(identical(p,mde_matrix(record$Prediction,rownames(p))))
  ids <- x$cohort$truth$Person; theta <- x$cohort$truth$Theta
  z <- cbind(theta> -1,theta>0,theta>1,theta<= -1,
    theta> -1 & theta<=0,theta>0 & theta<=1,theta>1)*1
  prior <- c(pnorm(1),.5,pnorm(-1),pnorm(-1),.5-pnorm(-1),.5-pnorm(-1),pnorm(-1))
  max_error <- 0; strata <- list()
  for(exposure in c(3,6)) {
    data <- if(exposure==3) x$cohort$three else x$cohort$data
    raw <- matrix(NA_real_,length(ids),6L)
    slot <- as.integer(sub('R','',data$Rater))+3L*(as.integer(sub('C','',data$Criterion))-1L)
    ix <- cbind(match(data$Person,ids),slot)
    stopifnot(!anyNA(ix),!anyDuplicated(ix))
    raw[ix] <- data$Score
    observed_mask <- drop((!is.na(raw)) %*% 2^(0:5))
    stopifnot(all(rowSums(!is.na(raw))==exposure))
    at <- match(paste(observed_mask,rowSums(raw,na.rm=TRUE)),
      paste(oracle$keys$Mask,oracle$keys$Total))
    stopifnot(!anyNA(at))
    estimated <- p[at,]; known <- q[at,]
    actual <- record$Metrics$metrics
    actual <- actual[actual$NewRatings==exposure,]
    stopifnot(identical(actual$Event,mde_events))
    w <- oracle$weight*(oracle$keys$Ratings==exposure)/(if(exposure==3) 2 else 1)
    # Expand the Bernoulli loss directly, rather than reusing the excess-risk formula.
    expected <- colSums((p^2-2*p*q+q)*w)
    oracle_loss <- colSums(q*(1-q)*w)
    prior_loss <- prior*(1-prior)
    checks <- cbind(ExpectedBias=colSums(p*w)-prior,
      ExcessBrier=expected-oracle_loss,OracleBrier=oracle_loss,
      ExpectedBrier=expected,PriorBrier=prior_loss,
      ExpectedPriorDifference=expected-prior_loss,
      RealizedBias=colMeans(estimated-z),RealizedBrier=colMeans((estimated-z)^2),
      RealizedOracleBrier=colMeans((known-z)^2),
      RealizedPriorBrier=colMeans((matrix(prior,length(ids),7L,byrow=TRUE)-z)^2),
      RealizedExcess=colMeans((estimated-z)^2)-colMeans((known-z)^2),
      RealizedPriorDifference=colMeans((estimated-z)^2)-
        colMeans((matrix(prior,length(ids),7L,byrow=TRUE)-z)^2))
    max_error <- max(max_error,max(abs(checks-as.matrix(actual[colnames(checks)]))))
    for(j in 1:3) for(near in c(TRUE,FALSE)) {
      take <- (abs(theta-mde_cuts[j])<=.25)==near
      strata[[length(strata)+1L]] <- data.frame(NewRatings=exposure,Event=mde_events[j],
        Stratum=if(near) 'within_0.25_of_cut' else 'away_from_cut',Persons=sum(take),
        Bias=sum((estimated-z)[take,j]),ReferenceBias=sum((known-z)[take,j]),
        Brier=sum((estimated-z)[take,j]^2),ReferenceBrier=sum((known-z)[take,j]^2),
        ExcessBrier=sum((estimated-z)[take,j]^2-(known-z)[take,j]^2),
        PriorBrier=sum((prior[j]-z[take,j])^2),
        PriorDifference=sum((estimated-z)[take,j]^2-(prior[j]-z[take,j])^2))
    }
    for(j in 1:7) for(b in 1:5) {
      # Right-open bins except the last, using comparisons instead of floor().
      take <- p[,j]>=(b-1)/5 & (p[,j]<b/5 | (b==5 & p[,j]==1))
      raw_take <- estimated[,j]>=(b-1)/5 & (estimated[,j]<b/5 | (b==5 & estimated[,j]==1))
      found <- record$Metrics$bins
      found <- found[found$NewRatings==exposure & found$Event==mde_events[j] & found$Bin==b,]
      expected_bin <- c(Mass=sum(w[take]),ErrorSum=sum(w[take]*(p-q)[take,j]),
        PredictionSum=sum(w[take]*p[take,j]),TruthSum=sum(w[take]*q[take,j]),
        RawCount=sum(raw_take),RawErrorSum=sum((estimated-z)[raw_take,j]))
      stopifnot(nrow(found)==1)
      max_error <- max(max_error,max(abs(unlist(found[names(expected_bin)])-expected_bin)))
    }
  }
  stopifnot(max_error<1e-10)
  list(Error=max_error,Strata=do.call(rbind,strata))
}
mde_summary <- function() {
  meta_path <- file.path(mde_root,'metadata.rds'); meta <- mde_read(meta_path)
  meta_sha <- mde_sha(meta_path)
  stopifnot(identical(mde_sha(names(meta$Source)),meta$Source))
  records <- metrics <- bins <- strata <- list(); record_hashes <- character()
  for(cell in 1:8) for(replicate in 1:256) {
    path <- file.path(mde_root,'main',sprintf('cell-%02d-rep-%04d.rds',cell,replicate))
    stopifnot(file.exists(path))
    r <- mde_read(path)
    input_name <- sprintf('main/cell-%02d-rep-%04d.rds',cell,replicate)
    stopifnot(r$Cell==cell,r$Replicate==replicate,
      identical(r$MetadataSHA256,meta_sha),identical(r$InputSHA256,meta$Inputs[input_name]))
    record_hashes[path] <- mde_sha(path)
    replay_error <- NA_real_
    if(r$Available) {
      x <- mde_input(meta,'main',cell,replicate)
      replay <- mde_replay(r,x,meta$Oracle[[mde_cells$Model[cell]]])
      replay_error <- replay$Error
      strata[[length(strata)+1L]] <- cbind(Cell=cell,Replicate=replicate,replay$Strata)
      metrics[[length(metrics)+1L]] <- cbind(Cell=cell,Replicate=replicate,r$Metrics$metrics)
      bins[[length(bins)+1L]] <- cbind(Cell=cell,Replicate=replicate,r$Metrics$bins)
    }
    records[[length(records)+1L]] <- data.frame(Cell=cell,Replicate=replicate,
      Available=r$Available,Error=r$Error,Warnings=paste(r$Warnings,collapse='; '),
      LegacyError=r$LegacyError,ReplayError=replay_error,Seconds=r$Seconds)
    if(replicate==256L) {cat(sprintf('Audited cell %d: all 256 records\n',cell)); flush.console()}
  }
  records <- do.call(rbind,records); metrics <- do.call(rbind,metrics); bins <- do.call(rbind,bins)
  strata <- do.call(rbind,strata)
  availability <- do.call(rbind,lapply(1:8,function(cell) {
    r <- records[records$Cell==cell,]; ci <- mde_binomial(sum(r$Available),nrow(r))
    data.frame(mde_cells[cell,],Returned=sum(r$Available),Attempts=nrow(r),
      Rate=mean(r$Available),Lower=ci[1],Upper=ci[2],row.names=NULL)
  }))
  targets <- expand.grid(Cell=1:8,NewRatings=c(3L,6L),Event=mde_events,stringsAsFactors=FALSE)
  decisions <- measurements <- list()
  measures <- setdiff(names(metrics),c('Cell','Replicate','NewRatings','Event'))
  for(i in seq_len(nrow(targets))) {
    key <- targets[i,]
    rows <- metrics[metrics$Cell==key$Cell & metrics$NewRatings==key$NewRatings & metrics$Event==key$Event,]
    stopifnot(!anyDuplicated(rows$Replicate))
    intervals <- vapply(rows[measures],mde_mean_interval,numeric(4))
    delivery <- unlist(availability[availability$Cell==key$Cell,c('Rate','Lower','Upper')])
    decisions[[i]] <- data.frame(key,Model=mde_cells$Model[key$Cell],
      CalPersons=mde_cells$Persons[key$Cell],CalRatings=mde_cells$Exposure[key$Cell],
      Returned=nrow(rows),Attempts=256L,Delivery=delivery['Rate'],
      DeliveryLower=delivery['Lower'],
      Bias=intervals['Mean','ExpectedBias'],BiasLower=intervals['Lower','ExpectedBias'],
      BiasUpper=intervals['Upper','ExpectedBias'],
      ExcessBrier=intervals['Mean','ExcessBrier'],RiskLower=intervals['Lower','ExcessBrier'],
      RiskUpper=intervals['Upper','ExcessBrier'],
      RMSProbabilityError=sqrt(intervals['Mean','ExcessBrier']),
      RMSUpper=sqrt(max(0,intervals['Upper','ExcessBrier'])),
      OracleBrier=intervals['Mean','OracleBrier'],ExpectedBrier=intervals['Mean','ExpectedBrier'],
      PriorBrier=intervals['Mean','PriorBrier'],PriorDifferenceUpper=intervals['Upper','ExpectedPriorDifference'],
      Decision=mde_decide(delivery,intervals[,'ExpectedBias'],intervals[,'ExcessBrier'],
        intervals[,'ExpectedPriorDifference']),row.names=NULL)
    measurements[[i]] <- cbind(key,Metric=colnames(intervals),as.data.frame(t(intervals)),row.names=NULL)
  }
  decisions <- do.call(rbind,decisions); measurements <- do.call(rbind,measurements)
  bin_keys <- expand.grid(Cell=1:8,NewRatings=c(3L,6L),Event=mde_events,Bin=1:5,stringsAsFactors=FALSE)
  calibration <- do.call(rbind,lapply(seq_len(nrow(bin_keys)),function(i) {
    key <- bin_keys[i,]
    r <- bins[bins$Cell==key$Cell & bins$NewRatings==key$NewRatings &
      bins$Event==key$Event & bins$Bin==key$Bin,]
    ci <- mde_ratio_interval(r$ErrorSum,r$Mass)
    raw_ci <- mde_ratio_interval(r$RawErrorSum,r$RawCount)
    data.frame(key,Returned=nrow(r),ContributingClusters=sum(r$Mass>0),
      Mass=mean(r$Mass),Predicted=if(sum(r$Mass)>0) sum(r$PredictionSum)/sum(r$Mass) else NA,
      Truth=if(sum(r$Mass)>0) sum(r$TruthSum)/sum(r$Mass) else NA,
      Bias=ci['Mean'],MCSE=ci['MCSE'],Lower=ci['Lower'],Upper=ci['Upper'],
      RawPersons=sum(r$RawCount),RawBias=raw_ci['Mean'],RawMCSE=raw_ci['MCSE'],row.names=NULL)
  }))
  stratum_keys <- unique(strata[c('Cell','NewRatings','Event','Stratum')])
  strata_summary <- do.call(rbind,lapply(seq_len(nrow(stratum_keys)),function(i) {
    key <- stratum_keys[i,]
    r <- strata[strata$Cell==key$Cell & strata$NewRatings==key$NewRatings &
      strata$Event==key$Event & strata$Stratum==key$Stratum,]
    measures <- setdiff(names(r),c('Cell','Replicate','NewRatings','Event','Stratum','Persons'))
    do.call(rbind,lapply(measures,function(name) {
      ci <- mde_ratio_interval(r[[name]],r$Persons)
      data.frame(key,Returned=nrow(r),Persons=sum(r$Persons),Metric=name,
        Mean=ci['Mean'],MCSE=ci['MCSE'],Lower=ci['Lower'],Upper=ci['Upper'],row.names=NULL)
    }))
  }))
  # Self-check decisions at and across the prespecified boundaries.
  d <- c(Rate=1,Lower=.985,Upper=1); b <- c(Lower=-.001,Upper=.001)
  stopifnot(mde_decide(d,b,c(Lower=0,Upper=.0025),c(Lower=-.1,Upper=-.01))=='supported',
    mde_decide(d,b,c(Lower=.001,Upper=.003),c(Lower=-.1,Upper=-.01))=='unresolved',
    mde_decide(d,b,c(Lower=.003,Upper=.004),c(Lower=-.1,Upper=-.01))=='repair_required',
    nrow(decisions)==112L,nrow(calibration)==560L,
    all(table(records$Cell)==256L),!anyDuplicated(records[c('Cell','Replicate')]))
  result <- list(availability=availability,decisions=decisions,measurements=measurements,
    calibration=calibration,strata=strata_summary,records=records,replicate_metrics=metrics,
    SecondaryScope=paste('Before main summaries: true ability within .25 of each cut versus away;',
      'calibration-cluster ratio MCSE; descriptive, no population-average risk identity or new criterion.'),
    MetadataSHA256=meta_sha,RecordSHA256=record_hashes,
    SummarySourceSHA256=mde_sha('inst/validation/mfrm-decision-probability-summary-20261010.R'),
    Session=sessionInfo(),NewFits=0L,NewRandomDraws=0L,ReplayMaxError=max(records$ReplayError,na.rm=TRUE))
  path <- file.path(mde_root,'summary.rds')
  if(file.exists(path)) {
    previous <- mde_read(path)
    previous$calibration <- mde_sparse_reporting(previous$calibration)
    for(name in setdiff(names(result),c('Session','SummarySourceSHA256')))
      stopifnot(identical(result[[name]],previous[[name]]))
    cat('Saved summary reproduced exactly.\n')
  } else {
    mde_save(result,path)
    for(name in c('availability','decisions','measurements','calibration','strata','records','replicate_metrics'))
      write.csv(result[[name]],file.path(mde_root,paste0(name,'.csv')),row.names=FALSE)
  }
  print(availability)
  print(table(decisions$Decision))
  cat(sprintf('Replay maximum error %.4g; accumulated processing %.1f worker-minutes.\n',
    result$ReplayMaxError,sum(records$Seconds)/60))
  invisible(result)
}

mde_sparse_reporting <- function(table) {
  sparse <- table$ContributingClusters<2L
  table[sparse,c('MCSE','Lower','Upper','RawMCSE')] <- NA_real_
  table
}
mde_qualify_saved <- function() {
  # Correct only unsupported bin uncertainty; reuse the completed raw-response audit.
  path <- file.path(mde_root,'summary.rds'); result <- mde_read(path)
  stopifnot(identical(mde_sha(file.path(mde_root,'metadata.rds')),result$MetadataSHA256),
    identical(mde_sha(names(result$RecordSHA256)),result$RecordSHA256))
  original <- result$calibration
  result$calibration <- mde_sparse_reporting(original)
  stopifnot(identical(original[c('Mass','Predicted','Truth','Bias','RawPersons','RawBias')],
    result$calibration[c('Mass','Predicted','Truth','Bias','RawPersons','RawBias')]))
  result$ReportingSourceSHA256 <- mde_sha('inst/validation/mfrm-decision-probability-summary-20261010.R')
  result$ReportingInputSHA256 <- mde_sha(path)
  result$ReportingNote <- paste('Fewer than two contributing calibration clusters: bin uncertainty unavailable.',
    'Original arithmetic audit and primary decisions retained; no refitting, scoring or raw-response replay.')
  output <- file.path(mde_root,'summary-qualified.rds')
  if(file.exists(output)) stopifnot(identical(mde_read(output),result)) else mde_save(result,output)
  write.csv(result$calibration,file.path(mde_root,'calibration-qualified.csv'),row.names=FALSE)
  cat('Qualified report: primary decisions unchanged; single-cluster bin intervals unavailable.\n')
  invisible(result)
}
if(sys.nframe()==0L) {
  stopifnot(!'mfrmr' %in% loadedNamespaces())
  args <- commandArgs(TRUE)
  if(!file.exists(file.path(mde_root,'summary.rds')) || 'replay' %in% args) mde_summary()
  mde_qualify_saved()
  stopifnot(!'mfrmr' %in% loadedNamespaces())
}
