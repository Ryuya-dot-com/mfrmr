# Read-only diagnosis of the completed PCM latent-regression development panel.
# The latent-ability oracle is a simulation reference, never an MFRM estimator
# or an alternative interval for observed ratings. No refits or random draws.
# Run from package root with scripts/validation-R --slave -f THIS_FILE.
root <- 'validation-results/mfrm-wide-map-lr-pcm-r50-20261004'
script <- 'inst/validation/mfrm-lr-pcm-coverage-diagnosis-20261009.R'
output <- file.path(root, 'coverage-diagnosis-20261009')
hash <- function(x) {
  p <- tempfile(); on.exit(unlink(p))
  writeBin(serialize(x, NULL, version=3), p)
  unname(tools::md5sum(p))
}
verify <- function(hashes) {
  stopifnot(length(hashes)>0L, !anyNA(hashes),
    identical(unname(tools::md5sum(names(hashes))),unname(hashes)))
}
sealed <- function(path) {
  x <- readRDS(path)
  stopifnot(identical(x$checksum,hash(x$payload)))
  x
}
comparison_path <- file.path(root,'comparison-completed-20261005.rds')
comparison <- readRDS(comparison_path)
for (h in list(comparison$final_summary,comparison$record_hashes,
               comparison$input_index,comparison$epoch_map)) verify(h)
manifests <- lapply(names(comparison$manifest_checksums),function(folder) {
  x <- sealed(file.path(folder,'manifest.rds'))
  stopifnot(identical(x$checksum,comparison$manifest_checksums[[folder]]))
  verify(setNames(unname(x$payload$source),file.path(folder,'source',names(x$payload$source))))
  x$payload
})
index <- manifests[[1L]]$jobs
for (m in manifests) stopifnot(identical(m$jobs,index))
stopifnot(nrow(index)==3600L,!anyDuplicated(index[c('ConditionId','Replicate')]))
key <- function(x) paste(x$ConditionId,x$Replicate,sep='|')
index_keys <- key(index)
inputs <- unique(index[c('ParentId','Bundle','BundleMD5','ABBundle','ABBundleMD5','N','SD')])
stopifnot(nrow(inputs)==700L,!anyDuplicated(inputs$ParentId))
input_hashes <- c(setNames(inputs$BundleMD5,
  file.path('validation-results/mfrm-wide-map-r50-20261001/lr-inputs',inputs$Bundle)),
  setNames(inputs$ABBundleMD5,inputs$ABBundle))
verify(input_hashes)

# Closed-form simple normal regression, independently checked by QR equations.
# The known-variance z interval and unknown-variance t interval are oracle-only.
oracle <- do.call(rbind,lapply(seq_len(nrow(inputs)),function(i) {
  row <- inputs[i,]
  lr <- readRDS(names(input_hashes)[i]); ab <- readRDS(row$ABBundle)
  stopifnot(lr$unit$ParentId==row$ParentId,ab$unit$ParentId==row$ParentId)
  do.call(rbind,lapply(names(lr$person_data),function(view) {
    p <- lr$person_data[[view]]; truth <- lr$population_truth[[view]]
    stopifnot(identical(p$Person,names(ab$theta)),length(ab$theta)==row$N,
      identical(p$X,unname(truth$rho*ab$theta/row$SD+sqrt(1-truth$rho^2)*lr$z)))
    x <- p$X; y <- unname(ab$theta); xc <- x-mean(x); sxx <- sum(xc^2)
    slope <- sum(xc*(y-mean(y)))/sxx; intercept <- mean(y)-slope*mean(x)
    residual <- y-intercept-slope*x
    residual_variance <- sum(residual^2)/(row$N-2L)
    X <- cbind(1,x); coefficients <- qr.coef(qr(X),y)
    stopifnot(max(abs(coefficients-c(intercept,slope)))<1e-12,
      abs(solve(crossprod(X))[2,2]-1/sxx)<1e-12)
    error <- slope-truth$coefficients[['X']]
    known_se <- sqrt(truth$residual_variance/sxx)
    estimated_se <- sqrt(residual_variance/sxx)
    data.frame(ParentId=row$ParentId,CovariateView=view,N=row$N,SD=row$SD,Rho=truth$rho,
      OracleSlope=slope,OracleError=error,OracleKnownSE=known_se,
      OracleEstimatedSE=estimated_se,OracleResidualVariance=residual_variance,
      ResidualVarianceTruth=truth$residual_variance,BetaTruth=truth$coefficients[['X']],
      OracleKnownCovered=abs(error)<=qnorm(.975)*known_se,
      OracleTCovered=abs(error)<=qt(.975,row$N-2L)*estimated_se)
  }))
}))
oracle_key <- paste(oracle$ParentId,oracle$CovariateView,sep='|')
stopifnot(nrow(oracle)==1400L,!anyDuplicated(oracle_key))
records <- do.call(rbind,lapply(names(comparison$record_hashes),function(path) {
  x <- sealed(path); z <- x$payload
  j <- match(key(z[1,]),index_keys); stopifnot(!is.na(j),nrow(z)==28L)
  row <- index[j,]
  stopifnot(identical(x$binding$inputs,c(lr=row$BundleMD5,ab=row$ABBundleMD5)))
  selected <- z[z$Rule=='refinement' & z$Output=='interval',]
  beta <- selected[selected$Target=='beta:X',]
  variance <- selected[selected$Target=='log_residual_variance',]
  stopifnot(nrow(beta)==1L,nrow(variance)==1L,beta$Order==variance$Order,
    all(z$N==row$N),all(z$SD==row$SD),all(z$Rho==row$Rho),all(z$View==row$View))
  o <- oracle[match(paste(row$ParentId,row$CovariateView,sep='|'),oracle_key),]
  stopifnot(nrow(o)==1L,!is.na(o$ParentId),beta$Truth==o$BetaTruth,
    abs(exp(variance$Truth)-o$ResidualVarianceTruth)<1e-14)
  cbind(beta,o[setdiff(names(o),c('N','SD','Rho'))],
    ResidualVarianceEstimate=exp(variance$Estimate),
    ResidualVarianceIntervalAvailable=variance$Available)
}))
rownames(records) <- NULL
stopifnot(nrow(records)==3600L,!anyDuplicated(key(records)))
records$MeasurementError <- records$Estimate-records$OracleSlope
records$Pivot <- ifelse(records$Available,records$Error/records$SE,NA_real_)
mcse <- function(x) sd(x)/sqrt(length(x))
summary <- do.call(rbind,lapply(split(records,records$ConditionId),function(z) {
  a <- z[z$Available,]; n <- nrow(a)
  old <- subset(comparison$precision, ConditionId==z$ConditionId[1L] &
    Rule=='refinement' & Output=='interval' & Target=='beta:X')
  stopifnot(nrow(z)==50L,nrow(old)==1L,n==old$Delivered,
    sum(z$Covered %in% TRUE)==old$Covered,
    isTRUE(all.equal(mean(a$Error),old$Bias,tolerance=1e-14)),
    max(abs(a$Error-a$OracleError-a$MeasurementError))<1e-13,
    abs(var(a$Error)-var(a$OracleError)-var(a$MeasurementError)-
      2*cov(a$OracleError,a$MeasurementError))<1e-12)
  decomposition <- c(var(a$OracleError),var(a$MeasurementError),
    2*cov(a$OracleError,a$MeasurementError))/var(a$Error)
  loo <- vapply(seq_len(n),function(i) mean(a$SE[-i])/sd(a$Error[-i]),0.)
  cbind(old[c('ConditionId','N','SD','Rho','View','Planned','Delivered','Covered',
    'Bias','EmpiricalSD','MeanSE','CoverageDeliveredLower','CoverageDeliveredUpper')],
    SEToEmpiricalSD=mean(a$SE)/sd(a$Error),RMSSEToEmpiricalSD=sqrt(mean(a$SE^2))/sd(a$Error),
    OracleKnownCovered=sum(z$OracleKnownCovered),OracleTCovered=sum(z$OracleTCovered),
    OracleCommonKnownCovered=sum(a$OracleKnownCovered),OracleCommonTCovered=sum(a$OracleTCovered),
    OracleBias=mean(a$OracleError),OracleSEToEmpiricalSD=mean(a$OracleKnownSE)/sd(a$OracleError),
    MeasurementBias=mean(a$MeasurementError),ErrorOracleCorrelation=cor(a$Error,a$OracleError),
    OracleVarianceFraction=decomposition[1L],MeasurementVarianceFraction=decomposition[2L],
    TwiceCovarianceFraction=decomposition[3L],
    MedianAbsPivot=median(abs(a$Pivot)),MaxAbsPivot=max(abs(a$Pivot)),
    MissBelow=sum(a$Upper<a$Truth),MissAbove=sum(a$Lower>a$Truth),
    VarianceEstimateRatio=mean(a$ResidualVarianceEstimate/a$ResidualVarianceTruth),
    VarianceRatioMCSE=mcse(a$ResidualVarianceEstimate/a$ResidualVarianceTruth),
    VarianceRatioMiss=mean(a$ResidualVarianceEstimate[!a$Covered]/a$ResidualVarianceTruth[!a$Covered]),
    VarianceRatioCovered=mean(a$ResidualVarianceEstimate[a$Covered]/a$ResidualVarianceTruth[a$Covered]),
    LargestSquaredErrorFraction=max(a$Error^2)/sum(a$Error^2),
    LeaveOneOutSERatioMin=min(loo),LeaveOneOutSERatioMax=max(loo))
}))
rownames(summary) <- NULL
summary <- summary[order(summary$N,summary$SD,summary$Rho,summary$View),]
result <- list(summary=summary,records=records,oracle=oracle,
  source=tools::md5sum(script),comparison=tools::md5sum(comparison_path),
  input_hashes=input_hashes,record_hashes=comparison$record_hashes,
  checks=c(original_summary_preserved=TRUE,all_record_and_input_hashes=TRUE,
    oracle_closed_form_matches_qr=TRUE,error_variance_decomposition=TRUE),
  scope=paste('Development diagnosis; all 72 conditions and planned failures retained.',
    'Oracle theta is unavailable in real assessments. Its known-variance normal and estimated-variance t intervals',
    'do not define or qualify intervals for the marginal rating likelihood.',
    'Error decomposition and leave-one-out ranges condition on returned MML intervals;',
    'no observations are removed from the main summaries. No fitting, new data, independent confirmation or tuning.'),
  session=sessionInfo())
if (file.exists(paste0(output,'.rds'))) {
  previous <- readRDS(paste0(output,'.rds'))
  stopifnot(identical(result[names(result)!='session'],previous[names(previous)!='session']))
} else {
  saveRDS(result,paste0(output,'.rds'),version=3)
  write.csv(summary,paste0(output,'.csv'),row.names=FALSE)
}
print(subset(summary, SD==.5 & Rho==0 & View=='full-L1')[c('N','Delivered','Covered',
  'SEToEmpiricalSD','OracleKnownCovered','OracleTCovered','OracleSEToEmpiricalSD',
  'OracleVarianceFraction','MeasurementVarianceFraction','TwiceCovarianceFraction',
  'VarianceEstimateRatio','LeaveOneOutSERatioMin','LeaveOneOutSERatioMax')],row.names=FALSE)
