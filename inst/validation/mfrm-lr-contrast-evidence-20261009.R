# Retained-data review of the new population-contrast API; no new samples/fits.
# Run from package root with scripts/validation-R --slave -f THIS_FILE.
# The three contrasts below were chosen before this reanalysis, not before
# the original development samples. Their coverage is descriptive, not confirmation.
pkgload::load_all('.', quiet=TRUE, compile=FALSE)
script <- 'inst/validation/mfrm-lr-contrast-evidence-20261009.R'
out <- 'validation-results/mfrm-lr-contrast-evidence-20261009'
stopifnot(!dir.exists(out))
dir.create(out)
source_paths <- c(script, list.files('R', '[.]R$', full.names=TRUE))
source_hashes <- tools::md5sum(source_paths)
source_text <- setNames(lapply(source_paths, readLines), source_paths)
hash <- function(x) {
  p <- tempfile(); on.exit(unlink(p))
  writeBin(serialize(x, NULL, version=3), p)
  unname(tools::md5sum(p))
}
sealed <- function(path) {
  x <- readRDS(path)
  stopifnot(identical(x$checksum, hash(x$payload)))
  x
}
verify <- function(h) stopifnot(!anyNA(h),
  identical(unname(tools::md5sum(names(h))), unname(h)))
L <- rbind(mean_at_minus1=c(1,-1), mean_at_plus1=c(1,1),
  plus1_minus_minus1=c(0,2))
colnames(L) <- c('(Intercept)', 'X')
critical <- qnorm(.975)
summarize <- function(z) {
  a <- z[z$Available, ]; n <- nrow(a); k <- sum(a$Covered)
  bounds <- function(k,n) if(n) as.numeric(binom.test(k,n)$conf.int) else c(NA_real_,NA_real_)
  ac <- bounds(n,nrow(z)); cc <- bounds(k,n); jc <- bounds(k,nrow(z))
  data.frame(Target=z$Target[1], Planned=nrow(z), Delivered=n, Covered=k,
    Availability=n/nrow(z), AvailabilityLower=ac[1], AvailabilityUpper=ac[2],
    ReturnedAndCovered=k/nrow(z), ReturnedAndCoveredLower=jc[1], ReturnedAndCoveredUpper=jc[2],
    ConditionalCoverage=if(n) k/n else NA_real_, CoverageLower=cc[1], CoverageUpper=cc[2],
    Bias=mean(a$Estimate-a$Truth), EmpiricalSD=sd(a$Estimate-a$Truth),
    MeanSE=mean(a$SE), MeanWidth=mean(a$Upper-a$Lower))
}
api_rows <- function(native, weights, truth) {
  ci <- suppressWarnings(mfrm_population_intervals(native, contrasts=weights))
  tab <- subset(ci$table, Type=='coefficient_contrast')
  b <- native$fit$population$coefficients
  sizes <- mfrmr:::build_param_sizes(native$fit$config)
  at <- mfrmr:::build_param_slices(sizes)$beta
  V <- native$parameter_covariance[at,at,drop=FALSE]
  # Scalar equations independently check the new matrix-interface path.
  estimate <- c(b[1]-b[2], b[1]+b[2], 2*b[2])
  variance <- c(V[1,1]-2*V[1,2]+V[2,2], V[1,1]+2*V[1,2]+V[2,2], 4*V[2,2])
  stopifnot(all(tab$CIEligible), max(abs(tab$Estimate-estimate))<1e-12,
    max(abs(tab$SE-sqrt(variance)))<1e-12,
    max(abs(tab$Lower-estimate+critical*sqrt(variance)))<1e-12,
    max(abs(tab$Upper-estimate-critical*sqrt(variance)))<1e-12)
  data.frame(Target=rownames(weights), Truth=truth, Estimate=tab$Estimate,
    SE=tab$SE, Lower=tab$Lower, Upper=tab$Upper, Available=tab$CIEligible,
    Covered=tab$Lower<=truth & truth<=tab$Upper)
}

pcm_root <- 'validation-results/mfrm-wide-map-lr-pcm-r50-20261004'
diagnosis_path <- file.path(pcm_root,'coverage-diagnosis-20261009.rds')
comparison_path <- file.path(pcm_root,'comparison-completed-20261005.rds')
full_path <- 'inst/validation/population-full-information-evidence-0.2.4.rds'
rsm_path <- 'validation-results/mfrm-wide-map-lr-pcm-location-intervals-20261004/retained-rsm-regression.rds'
preflight_path <- 'inst/validation/population-coverage-preflight-evidence-0.2.4.rds'
input_hashes <- tools::md5sum(c(diagnosis_path,comparison_path,full_path,rsm_path,preflight_path))
d <- readRDS(diagnosis_path); comparison <- readRDS(comparison_path)
verify(d$source); verify(d$comparison); verify(d$input_hashes); verify(d$record_hashes)
stopifnot(identical(d$record_hashes,comparison$record_hashes))

# No fitting or differentiation is allowed for the completed PCM allocation
# or the independently qualified RSM example.
reuse <- testthat::with_mocked_bindings({
  rows <- vector('list',nrow(d$records)); selected_hashes <- character(nrow(d$records))
  for(i in seq_len(nrow(d$records))) {
    old <- d$records[i,]; record_path <- names(d$record_hashes)[i]
    record <- sealed(record_path)
    stopifnot(record$payload$ConditionId[1]==old$ConditionId,
      record$payload$Replicate[1]==old$Replicate)
    path <- file.path(dirname(record_path),'selected.rds'); selected <- sealed(path)
    selected_hashes[i] <- tools::md5sum(path); names(selected_hashes)[i] <- path
    stopifnot(identical(record$binding$selected,selected$checksum),
      old$Order==selected$payload$interval$order)
    stage <- selected$payload$interval
    truth <- c(-old$BetaTruth,old$BetaTruth,2*old$BetaTruth)
    if(old$Available) {
      stopifnot(isTRUE(stage$eligible))
      tab <- api_rows(stage$structural$value,L,truth)
      stopifnot(tab$Covered[3]==old$Covered, abs(tab$SE[3]-2*old$SE)<1e-12,
        abs(tab$Estimate[3]-2*old$Estimate)<1e-12)
    } else {
      # Preserve the original complete procedure's refusal, including boundaries.
      # A local matrix alone cannot override its selected interval disposition.
      b <- stage$population$value$fit$population$coefficients
      estimate <- if(length(b)==2L) drop(L %*% b) else rep(NA_real_,3L)
      tab <- data.frame(Target=rownames(L),Truth=truth,Estimate=estimate,
        SE=NA_real_,Lower=NA_real_,Upper=NA_real_,Available=FALSE,Covered=FALSE)
    }
    rows[[i]] <- cbind(old[rep(1L,3L),c('ConditionId','Replicate','N','SD','Rho','View','Reason')],tab)
    if(i%%600L==0L) {cat('PCM retained jobs',i,'/',nrow(d$records),'\n'); flush.console()}
  }
  rsm <- readRDS(rsm_path); reference <- readRDS(full_path)$results[['RSM-61']]$result
  stopifnot(isTRUE(all.equal(rsm$fit,reference$fit)),
    max(abs(rsm$fit$opt$par-reference$fit$opt$par))==0)
  weights <- L; colnames(weights)[2] <- 'x'
  ci <- suppressWarnings(mfrm_population_intervals(rsm,contrasts=weights))
  expected <- weights %*% reference$reference$covariance[5:6,5:6] %*% t(weights)
  discrepancy <- max(abs(ci$contrast_covariance-expected)/sqrt(outer(diag(expected),diag(expected))))
  stopifnot(all(ci$table$CIEligible),discrepancy<1e-5)
  list(records=do.call(rbind,rows), selected_hashes=selected_hashes,
    rsm=ci,rsm_reference_difference=discrepancy)
},fit_mfrm=function(...) stop('No refits'),
  mfrm_native_location_inference=function(...) stop('No repeated qualification'),
  compute_mml_parameter_covariance=function(...) stop('No repeated information'),.package='mfrmr')
rownames(reuse$records) <- NULL
pcm_summary <- do.call(rbind,lapply(split(reuse$records,
  paste(reuse$records$ConditionId,reuse$records$Target)),function(z)
    cbind(z[1,c('ConditionId','N','SD','Rho','View')],summarize(z))))
rownames(pcm_summary) <- NULL
stopifnot(nrow(pcm_summary)==216L,nrow(reuse$records)==10800L)

# Twenty RSM preflight samples already exist. Evaluate the current public
# numerical checks at their saved vectors; retain the older protocol separately.
preflight <- readRDS(preflight_path); rsm_rows <- list(); rsm_results <- list()
for(s in preflight$states) if(s$Cell$Model=='RSM') for(r in s$Results) {
  weights <- L; colnames(weights)[2] <- 'x'
  native <- suppressWarnings(mfrm_facet_intervals(r$Detail$fit,'Rater'))
  id <- paste(s$Cell$Cell,r$Replicate,sep='-')
  stopifnot(all(native$checks$Passed),max(abs(native$parameter_covariance-r$Covariance))<1e-12,
    identical(native$fit$opt$par,r$Parameters))
  tab <- api_rows(native,weights,c(-.3,.7,1))
  stopifnot(tab$Covered[3]==(r$Lower['Slope']<=.5 && .5<=r$Upper['Slope']))
  rsm_rows[[id]] <- cbind(s$Cell[rep(1L,3L),],Replicate=r$Replicate,tab)
  rsm_results[[id]] <- native
}
rsm_records <- do.call(rbind,rsm_rows); rownames(rsm_records) <- NULL
rsm_summary <- do.call(rbind,lapply(split(rsm_records,paste(rsm_records$Cell,rsm_records$Target)),
  function(z) cbind(z[1,c('Cell','Model','Persons','Exposure')],summarize(z))))
stopifnot(length(rsm_results)==20L,nrow(rsm_summary)==12L)
verify(input_hashes); verify(source_hashes); verify(reuse$selected_hashes)
result <- list(contrasts=L,pcm_summary=pcm_summary,pcm_records=reuse$records,
  rsm_preflight_summary=rsm_summary,rsm_preflight_records=rsm_records,
  rsm_preflight_qualified=rsm_results,rsm_continuous_reference=reuse$rsm,
  rsm_reference_difference=reuse$rsm_reference_difference,
  input_hashes=input_hashes,selected_hashes=reuse$selected_hashes,
  source_hashes=source_hashes,source=source_text,session=sessionInfo(),
  dll=tools::md5sum(getLoadedDLLs()[['mfrmr']][['path']]),
  scope=paste('Retained-data, post hoc descriptive contrast assessment; no new fits or samples.',
    'PCM retains all 72 conditions and original interval refusals.',
    'RSM uses one independent continuous-information reference and only five preflight samples per cell.',
    'No nominal sampling qualification, simultaneous inference, individual differences or causal effect claim.'),
  new_fits=0L,new_samples=0L)
saveRDS(result,file.path(out,'evidence.rds'),version=3)
write.csv(pcm_summary,file.path(out,'pcm-summary.csv'),row.names=FALSE)
write.csv(rsm_summary,file.path(out,'rsm-preflight-summary.csv'),row.names=FALSE)
cat('RSM continuous-reference covariance difference:',reuse$rsm_reference_difference,'\n')
print(subset(pcm_summary,Rho==.5 & SD==.5 & View=='paired-L1')[
  c('N','Target','Delivered','Covered','ConditionalCoverage','CoverageLower','CoverageUpper')],row.names=FALSE)
