# Summarize and replay the completed, frozen RSM confirmation; no new fits/draws.
# From the package root, use R 4.6.1 with runtime-20261009/library and all four
# numerical thread variables set to 1. The producer's source remains unchanged.
script <- 'inst/validation/mfrm-lr-rsm-confirmation-summary-20261010.R'
pkgload::load_all('.',quiet=TRUE,compile=FALSE)
source('inst/validation/mfrm-lr-rsm-confirmation-20261009.R')
for(path in rsm_confirm_helpers) source(path)
root <- rsm_confirm_root
execution <- rsm_confirm_read(file.path(root,'execution.rds'))$payload
original <- execution$current
actual <- rsm_confirm_current()

# The relocated system R is byte-identical to the recorded R distribution.
# Accept only the two library pathname changes, and retain the actual runtime.
lock_path <- 'inst/validation/runtime-lock-20261009.json'
lock <- jsonlite::fromJSON(lock_path)
expected <- unlist(lock$R$HistoricalBinarySHA256)
binary_paths <- file.path(R.home(),names(expected))
binary_hashes <- vapply(binary_paths,function(path) {
  stopifnot(file.exists(path))
  sub(' .*','',system2('shasum',c('-a','256',shQuote(path)),stdout=TRUE))
},'')
stopifnot(identical(unname(binary_hashes),unname(expected)))
old_home <- sub('/lib/libRblas[.]0[.]dylib$','',original$runtime$libraries[['BLAS']])
new_home <- sub('/lib/libRblas[.]0[.]dylib$','',actual$runtime$libraries[['BLAS']])
mapped <- actual
for(name in c('iconv','BLAS')) {
  stopifnot(identical(gsub(old_home,new_home,original$runtime$libraries[[name]],fixed=TRUE),
    actual$runtime$libraries[[name]]))
  mapped$runtime$libraries[[name]] <- original$runtime$libraries[[name]]
}
stopifnot(identical(mapped,original))
runtime_mapping <- list(original=original$runtime,actual=actual$runtime,
  old_home=old_home,new_home=new_home,binary_sha256=binary_hashes,
  lock_hash=tools::md5sum(lock_path),scope='Saved-result summary/replay only; no numerical producer continuation.')
original_current <- rsm_confirm_current
rsm_confirm_current <- function() {
  stopifnot(identical(original_current(),actual))
  mapped
}
manifest <- rsm_confirm_manifest()
for(epoch in c('source','execution-source')) {
  hashes <- if(epoch=='source') manifest$source else original$source
  names(hashes) <- file.path(root,epoch,names(hashes))
  rsm_confirm_verify(hashes)
}
inputs <- rsm_confirm_read(file.path(root,'inputs.rds'))$payload
rsm_confirm_verify(inputs$registry);rsm_confirm_verify(inputs$bundles)
registry <- readRDS(names(inputs$registry))
stopifnot(nrow(registry$units)==1600L,!anyDuplicated(registry$units$ParentId),
  identical(as.integer(table(registry$units$N)),c(800L,800L)))

# Stop if replay accidentally reaches an estimator or a numerical review.
for(name in c('wide_mml_fit','rsm_lr_stages','rsm_lr_score','rsm_lr_interval',
    'rsm_lr_boundary_zero','rsm_lr_continuous_value','ab_generate'))
  assign(name,function(...)stop('Numerical work is disabled in summary/replay.'))

paths <- file.path(root,'jobs',sprintf('parent-%04d',seq_len(1600L)))
retained_paths <- c(file.path(root,c('manifest.rds','execution.rds','inputs.rds','rng-registry.rds')),
  list.files(file.path(root,'jobs'),'[.]rds$',recursive=TRUE,full.names=TRUE))
retained_hashes <- tools::md5sum(retained_paths)
stopifnot(!anyNA(retained_hashes))
accounting <- vector('list',length(paths)); phases <- vector('list',length(paths))
for(i in seq_along(paths)) {
  out <- paths[i];unit <- registry$units[i,]
  job <- rsm_confirm_read(file.path(out,'manifest.rds'))$payload
  selected <- rsm_confirm_read(file.path(out,'selected.rds'))
  status <- readRDS(file.path(out,'status.rds'))
  saved <- rsm_confirm_read(file.path(out,'records.rds'))$payload
  stopifnot(identical(job$rule,manifest$protocol$inference),
    identical(job$runtime[names(original$runtime)],original$runtime),
    identical(unname(job$spec$InputId),unname(inputs$bundles[i])),
    identical(selected$binding,wide_mml_hash(job)),
    identical(status$identity,selected$binding),status$status=='complete',
    identical(unique(saved$ParentId),unit$ParentId),identical(unique(saved$N),unit$N),
    identical(unique(saved$Replicate),unit$Replicate))
  # Reconstruct every row from the saved fit and selected interval/source output.
  replay <- rsm_lr_records(job$spec,selected$payload,out)
  truth <- setNames(c(0,.5,-.5,.5,1,log(.75)),manifest$protocol$primary)
  replay$Truth <- unname(truth[replay$Target]);replay$Error <- replay$Estimate-replay$Truth
  replay$Covered <- ifelse(replay$Output=='interval' & replay$Available,
    replay$Lower<=replay$Truth & replay$Truth<=replay$Upper,NA)
  replay$N <- unit$N;replay$ParentId <- unit$ParentId
  stopifnot(identical(replay,saved),nrow(saved)==24L)
  stage_paths <- list.files(out,'^q[0-9]+-.*[.]rds$',full.names=TRUE)
  phases[[i]] <- do.call(rbind,lapply(stage_paths,function(path) {
    x <- rsm_confirm_read(path)
    stopifnot(identical(x$binding$job,selected$binding))
    data.frame(ParentId=unit$ParentId,N=unit$N,Order=x$binding$order,
      Phase=x$binding$phase,Elapsed=x$payload$elapsed,Error=x$payload$error,
      Warnings=paste(x$payload$warnings,collapse='; '))
  }))
  accounting[[i]] <- data.frame(ParentId=unit$ParentId,N=unit$N,
    Stages=length(selected$payload$stages),ScoringOrder=selected$payload$point$order,
    IntervalOrder=selected$payload$interval$order,Completed=status$time,
    Elapsed=sum(phases[[i]]$Elapsed))
  if(i%%400L==0L) {cat('Verified saved jobs:',i,'/1600\n');flush.console()}
}
accounting <- do.call(rbind,accounting);phases <- do.call(rbind,phases)

# Run the unchanged, prespecified summarizer and its original identity guards.
rsm_confirm_summarize()
result <- rsm_confirm_read(file.path(root,'summary.rds'))$payload
stopifnot(identical(result$records,do.call(rbind,lapply(paths,function(p)
  rsm_confirm_read(file.path(p,'records.rds'))$payload))))

# Independently check binomial bounds via beta quantiles, record counts,
# arithmetic and the frozen decision criteria. No fitted quantities are changed.
beta_bounds <- function(k,n) {
  if(n==0L) return(c(NA_real_,NA_real_))
  c(if(k==0L) 0 else qbeta(.025,k,n-k+1),
    if(k==n) 1 else qbeta(.975,k+1,n-k))
}
near <- function(x,y) isTRUE(all.equal(x,y,tolerance=1e-13,check.attributes=FALSE))
for(i in seq_len(nrow(result$summary))) {
  s <- result$summary[i,]
  z <- subset(result$records,N==s$N & Selection==s$Selection & Output==s$Output & Target==s$Target)
  a <- z[z$Available,];n <- nrow(a);k <- if(s$Output=='interval') sum(a$Covered) else 0L
  ab <- beta_bounds(n,nrow(z));cb <- beta_bounds(k,n);jb <- beta_bounds(k,nrow(z))
  stopifnot(nrow(z)==800L,!anyDuplicated(z$ParentId),s$Delivered==n,
    near(c(s$AvailabilityLower,s$AvailabilityUpper),ab),
    near(s$Bias,if(n) mean(a$Estimate-a$Truth) else NA_real_),
    near(s$EmpiricalSD,if(n>1L) sd(a$Estimate-a$Truth) else NA_real_))
  if(s$Output=='interval') {
    stopifnot(s$Covered==k,near(c(s$CoverageLower,s$CoverageUpper),cb),
      near(c(s$JointLower,s$JointUpper),jb),
      near(s$ReturnedAndCovered,k/800),near(s$MeanSE,if(n) mean(a$SE) else NA_real_),
      near(s$MeanWidth,if(n) mean(a$Upper-a$Lower) else NA_real_))
    if(s$Selection=='selected') {
      rule <- manifest$protocol$criteria
      support <- n/800>=rule$availability && ab[1]>=rule$availability_lower && n>0 &&
        cb[1]>=rule$coverage[1] && cb[2]<=rule$coverage[2]
      repair <- ab[2]<rule$availability || (n>0 && (cb[2]<rule$coverage[1] || cb[1]>rule$coverage[2]))
      decision <- if(support) 'supported' else if(repair) 'repair_required' else 'inconclusive'
      stopifnot(identical(s$Decision,decision))
    }
  } else {
    stopifnot(all(is.na(s[c('Covered','CoverageLower','CoverageUpper',
      'JointLower','JointUpper','MeanSE','MeanWidth')])),s$Decision=='descriptive')
  }
}
changed <- result$records;changed$Estimate[1] <- changed$Estimate[1]+.01
stopifnot(wide_mml_hash(changed)!=wide_mml_hash(result$records))
rsm_confirm_verify(retained_hashes)
write.csv(result$refusals,file.path(root,'refusals.csv'),row.names=FALSE)
write.csv(accounting,file.path(root,'job-accounting.csv'),row.names=FALSE)
write.csv(phases,file.path(root,'phase-accounting.csv'),row.names=FALSE)
evidence <- list(passed=TRUE,scope='All 1600 attempts replayed; original summary/decision procedure unchanged.',
  runtime_mapping=runtime_mapping,script_hash=tools::md5sum(script),retained_hashes=retained_hashes,
  outputs=tools::md5sum(file.path(root,c('summary.rds','summary.csv','refusals.csv',
    'job-accounting.csv','phase-accounting.csv'))),jobs=1600L,rows=nrow(result$records),
  summaries=nrow(result$summary),phase_count=nrow(phases),independent_beta_bounds=TRUE,
  numeric_change_detected=TRUE,new_fits=0L,new_draws=0L,session=sessionInfo())
wide_mml_save(evidence,file.path(root,'summary-verification-20261010.rds'))
cat('Summary, all saved rows/phase seals and independent decision checks: PASS\n')
