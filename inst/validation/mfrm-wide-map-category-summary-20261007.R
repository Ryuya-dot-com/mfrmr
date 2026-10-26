# Saved-output supplement to the allocated C comparison; never fit or score.
# K=3/5 and the retained K=4 control share fifty parent datasets.
args <- commandArgs(trailingOnly=TRUE)
stopifnot(length(args)==1L,args %in% c('check','collect','replay'))
mode <- args[[1L]]
root <- 'validation-results/mfrm-wide-map-c-category-r50-20261007'
ab <- 'validation-results/mfrm-wide-map-pcm-r50-portable-20261003'
bridge <- 'validation-results/mfrm-wide-map-c-output-bridge-20261006'
stopifnot(identical(normalizePath('.'),normalizePath(file.path(bridge,'source'))))
out <- file.path(root,'category-comparison')
pkgload::load_all('.',quiet=TRUE,compile=FALSE,helpers=FALSE)
d <- readRDS(file.path(root,'dispatch.rds'))
for(f in names(d$sources))if(grepl('(^|/)inst/validation/.*[.]R$',f))sys.source(f,globalenv())
check_hash <- function(h)stopifnot(length(h)>0L,!anyNA(h),identical(tools::md5sum(names(h)),h))
for(h in list(d$sources,d$inputs,d$qualification,d$rng_head))check_hash(h)
stopifnot(identical(wide_multi_runtime(),d$runtime))
for(n in c('fit_mfrm','predict_mfrm_units','extract_mfrm_calibration'))
  trace(n,tracer=quote(stop('Category summaries cannot perform numerical estimation.')),
    where=asNamespace('mfrmr'),print=FALSE)
script <- sub('^--file=','',grep('^--file=',commandArgs(),value=TRUE))
ab_manifest <- file.path(ab,'manifest.rds');m <- wide_f_read(ab_manifest)$payload
ab_summary <- file.path(ab,'summary-n20/summary.rds')
ab_replay <- file.path(ab,'summary-n20/fresh-replay.rds');af <- readRDS(ab_replay)
for(h in list(af$original_outputs,af$immutable_summary_and_job_hashes,af$source))check_hash(h)
asaved <- wide_f_read(ab_summary)
stopifnot(identical(asaved$binding$outputs,af$original_outputs),
  asaved$payload$independent_replicates==50L,af$new_fits==0L,af$new_scores==0L)
arm_map <- c('PCM-MML-free-population'='PCM-MML-free','PCM-JML'='PCM-JML',
  'GPCM-MML-free-population'='GPCM-MML-free','GPCM-JML'='GPCM-JML',
  'GPCM-JML-order2'='GPCM-JML2','GPCM-JML-order4'='GPCM-JML4')
aj <- m$jobs[m$jobs$ConditionId=='AB:paired-L1:N20:SD1:S-PCM' &
  m$jobs$Arm %in% unname(arm_map),]
stopifnot(nrow(aj)==300L,all(table(aj$Arm)==50L),length(d$jobs)==600L)
outputs <- vapply(d$jobs,function(j)file.path(j$directory,'outputs.rds'),'')
proofs <- vapply(d$jobs,function(j)file.path(j$directory,'independent-output-replay.rds'),'')
pilot <- readRDS(file.path(bridge,'numerical/dispatch.rds'))
# Reuse the already qualified C reader, including its original-pilot routing.
reader <- file.path(root,'summary/c-category-summary-v2.R')
expression <- Filter(function(x)is.call(x)&&identical(x[[1L]],as.name('<-'))&&
  identical(x[[2L]],as.name('read_completed')),as.list(parse(reader,keep.source=FALSE)))
stopifnot(length(expression)==1L);eval(expression[[1L]],globalenv())
apaths <- file.path(ab,aj$JobId,'outputs.rds')
amanifests <- file.path(ab,aj$JobId,'calibration/manifest.rds')
aspecs <- lapply(amanifests,function(f)wide_f_read(f)$payload$spec)
pairing <- lapply(seq_along(d$jobs),function(i) {
  j <- d$jobs[[i]];s <- j$spec;input <- j$input
  ix <- which(aj$Replicate==s$Replicate & aj$Arm==arm_map[[s$Arm]])
  stopifnot(length(ix)==1L)
  a <- aspecs[[ix]];parent <- readRDS(names(input$provenance$ab_bundle))
  design <- c('Person','Rater','Criterion')
  control <- parent$views[['paired-L1']]
  stopifnot(identical(input$data[design],control[design]),
    unname(input$provenance$ab_bundle)==aj$BundleMD5[ix],
    parent$unit$Replicate==s$Replicate,
    identical(unname(input$truth$Rater),unname(parent$truth$Rater)),
    identical(unname(input$truth$Criterion),unname(parent$truth$Criterion)),
    identical(unname(input$truth$log_slopes),unname(parent$truth$log_slopes)))
  keys <- setdiff(union(names(a$args),names(s$args)),c('data','rating_min','rating_max'))
  stopifnot(all(vapply(keys,function(k)identical(a$args[[k]],s$args[[k]]),TRUE)),
    a$args$rating_max==3,a$args$rating_min==s$args$rating_min)
  data.frame(CJob=i,ABJob=aj$JobId[ix],Replicate=s$Replicate,Arm=s$Arm,
    Categories=length(input$categories),Parent=names(input$provenance$ab_bundle))
})
pairing <- do.call(rbind,pairing)
stopifnot(all(table(pairing$Categories,pairing$Arm)==50L),
  length(unique(pairing$Parent))==50L,!anyDuplicated(pairing[c('Categories','Arm','Replicate')]))

# Retain execution epochs explicitly. This is no new equality claim for
# source-selected intervals or scoring, which use other, changed consumers.
fixed <- c(file.path(root,'dispatch.rds'),file.path(root,'fresh-input-replay.rds'),
  ab_manifest,ab_summary,ab_replay,amanifests,reader,script)
binding <- list(Files=tools::md5sum(unique(fixed)),CSources=d$sources,
  CRuntime=d$runtime,ABRuntime=m$runtime,ABSource=m$source,
  ABOriginalOutputs=af$original_outputs,Pairing=pairing)
require_complete <- function() {
  if(!file.exists(file.path(root,'summary/fresh-replay.rds')) ||
      !all(file.exists(outputs)&file.exists(proofs)))
    stop('All600 independently checked C outputs and complete-summary replay are required.')
}

# Each fixed grid contributes one loss per parent, never 45 independent cases.
expected_score_loss <- function(records,K) {
  p <- records[records$Kind=='probability',]
  stopifnot(nrow(p)==45L*K,!anyDuplicated(p$Target))
  p$Category <- as.integer(sub('^.*:','',p$Target))
  p$Context <- sub(':[^:]+$','',p$Target)
  g <- expand.grid(Theta=c(-2,-1,0,1,2),Rater=as.character(1:3),Criterion=as.character(1:3))
  expected <- paste('probability',g$Theta,g$Rater,g$Criterion,sep=':')
  stopifnot(setequal(p$Context,expected))
  errors <- vapply(split(seq_len(nrow(p)),p$Context),function(ix) {
    z <- p[ix,];z <- z[order(z$Category),]
    stopifnot(identical(z$Category,0:(K-1L)))
    if(!all(z$Available))return(NA_real_)
    sum(z$Estimate*z$Category)/(K-1L)-sum(z$ReferenceValue*z$Category)/(K-1L)
  },0)
  available <- all(is.finite(errors))
  c(Available=available,Error=if(available)mean(errors)else NA_real_,
    SquaredError=if(available)mean(errors^2)else NA_real_)
}
contributions <- function(z,K,arm) {
  r <- wide_recovery_records(z$plan,z$results)
  do.call(rbind,lapply(split(r,r$Analysis),function(x) {
    stopifnot(length(unique(x$Replicate))==1L,length(unique(x$InputId))==1L,
      all(x$Status[x$Eligibility=='eligible'] %in% c('returned','error')),
      all(x$Status[x$Eligibility!='eligible']=='not_started'))
    loss <- expected_score_loss(x,K)
    # Paired location/slope errors compare the same generating coordinates.
    points <- x[x$Kind %in% c('location','contrast','log_slope') & x$Eligibility=='eligible',]
    target <- data.frame(Metric=points$Target,Truth=points$ReferenceValue,
      Available=points$Available,Error=ifelse(points$Available,points$Estimate-points$ReferenceValue,NA_real_))
    target$SquaredError <- target$Error^2
    target <- rbind(target,data.frame(Metric='normalized_expected_score',Truth=NA_real_,
      Available=as.logical(loss['Available']),Error=unname(loss['Error']),
      SquaredError=unname(loss['SquaredError'])))
    cbind(data.frame(Analysis=x$Analysis[1],Arm=arm,Categories=K,
      Replicate=x$Replicate[1],InputId=x$InputId[1]),target)
  }))
}
read_ab <- function(i) {
  z <- wide_f_read(apaths[i])
  stopifnot(identical(z$binding$job,aj[i,,drop=FALSE]),
    identical(z$binding$source,m$source),isTRUE(z$payload$completed))
  z$payload$initial
}
target <- file.path(out,'summary.rds');check <- file.path(out,'preparation.rds')
if(mode=='check') {
  stopifnot(inherits(tryCatch({require_complete();NULL},error=identity),'error'))
  ids <- which(!vapply(d$jobs,function(j)is.na(j$pilot),TRUE))
  stopifnot(length(ids)==12L)
  checked <- lapply(ids,function(i) {
    j<-d$jobs[[i]];z<-read_completed(i)$initial;K<-length(j$input$categories)
    x<-wide_recovery_records(z$plan,z$results);x<-x[x$Analysis=='initial_finite_return',]
    value<-expected_score_loss(x,K)
    stopifnot(identical(value,expected_score_loss(x[rev(seq_len(nrow(x))),],K)),
      inherits(tryCatch({expected_score_loss(x[-which(x$Kind=='probability')[1],],K);NULL},error=identity),'error'))
    endpoint<-x;ix<-which(endpoint$Kind=='probability')
    category<-as.integer(sub('^.*:','',endpoint$Target[ix]))
    endpoint$Available[ix]<-TRUE
    endpoint$Estimate[ix]<-as.numeric(category==K-1L)
    endpoint$ReferenceValue[ix]<-as.numeric(category==0L)
    stopifnot(identical(expected_score_loss(endpoint,K),c(Available=1,Error=1,SquaredError=1)))
    contributions(z,K,j$spec$Arm);TRUE
  })
  invisible(lapply(which(aj$Replicate==1L),function(i)
    contributions(read_ab(i),4L,names(arm_map)[match(aj$Arm[i],arm_map)])))
  dir.create(out,showWarnings=FALSE);stopifnot(!file.exists(check))
  saveRDS(list(ChecksPassed=TRUE,Binding=binding,COutputs=600L,ABOutputs=300L,
    IndependentParents=50L,CheckedPilots=length(checked),Fits=0L,Scores=0L,
    Scope='Initial finite and numerical-pass outputs only; no source-selected CI/scoring equivalence or coverage claim.'),check,version=3)
  cat('Category comparison:900 planned outputs matched; twelve C and six AB pilot schemas, row-order and missing-category guards pass. No partial performance summary.\n')
  quit(save='no',status=0L)
}
require_complete();prepared<-readRDS(check)
stopifnot(prepared$ChecksPassed,identical(prepared$Binding,binding))
cf <- readRDS(file.path(root,'summary/fresh-replay.rds'))
stopifnot(cf$ChecksPassed,cf$Jobs==600L,cf$IndependentParents==50L)
check_hash(cf$SummaryFiles);check_hash(cf$Binding$OutputsAndProofs)
before <- tools::md5sum(c(outputs,proofs,apaths))
rows <- c(lapply(seq_along(d$jobs),function(i) {
  j<-d$jobs[[i]];contributions(read_completed(i)$initial,length(j$input$categories),j$spec$Arm)
}),lapply(seq_len(nrow(aj)),function(i)
  contributions(read_ab(i),4L,names(arm_map)[match(aj$Arm[i],arm_map)])))
rows <- do.call(rbind,rows);rownames(rows)<-NULL
group <- c('Analysis','Arm','Metric')
mcse <- function(x)if(length(x)>1L)sd(x)/sqrt(length(x))else NA_real_
within <- paired <- list()
for(ix in split(seq_len(nrow(rows)),do.call(paste,c(rows[group],sep='|')))) {
  z<-rows[ix,];stopifnot(!anyDuplicated(z[c('Categories','Replicate')]),
    all(table(z$Categories)==50L),setequal(z$Categories,3:5),
    all(vapply(split(z$Replicate,z$Categories),function(x)setequal(x,1:50),TRUE)),
    z$Metric[1]=='normalized_expected_score'||length(unique(z$Truth))==1L)
  for(K in 3:5) {
    x<-z[z$Categories==K,];ok<-x$Available;e<-x$Error[ok];s<-x$SquaredError[ok]
    within[[length(within)+1L]]<-cbind(z[1,group],data.frame(Categories=K,Planned=50L,
      Available=sum(ok),MeanError=if(length(e))mean(e)else NA_real_,ErrorMCSE=mcse(e),
      MSE=if(length(s))mean(s)else NA_real_,MSEMCSE=mcse(s)))
  }
  for(K in combn(3:5,2L,simplify=FALSE)) {
    a<-z[z$Categories==K[1],];b<-z[z$Categories==K[2],];b<-b[match(a$Replicate,b$Replicate),]
    joint<-a$Available&b$Available;de<-a$Error[joint]-b$Error[joint]
    ds<-a$SquaredError[joint]-b$SquaredError[joint];da<-as.integer(a$Available)-as.integer(b$Available)
    paired[[length(paired)+1L]]<-cbind(z[1,group],data.frame(CategoriesA=K[1],CategoriesB=K[2],
      PlannedPairs=50L,AAvailable=sum(a$Available),BAvailable=sum(b$Available),BothAvailable=sum(joint),
      AvailabilityDifference=mean(da),AvailabilityDifferenceMCSE=mcse(da),
      ErrorDifference=if(length(de))mean(de)else NA_real_,ErrorDifferenceMCSE=mcse(de),
      MSEDifference=if(length(ds))mean(ds)else NA_real_,MSEDifferenceMCSE=mcse(ds)))
  }
}
tables<-list(within_category=do.call(rbind,within),paired_category=do.call(rbind,paired))
result<-list(tables=tables,contributions=rows,Binding=binding,Outputs=before,
  CCompleteReplay=tools::md5sum(file.path(root,'summary/fresh-replay.rds')),
  Note='Fifty paired parents; fixed grids do not increase the replication count. Error contrasts condition on joint returns; availability retains all planned parents. Each normalized expected-score error uses its own category truth and divisor K-1. The same fitting settings retain distinct recorded source/runtime epochs. Initial numerical pass is not an optimum, structural-inference or coverage certificate.')
stopifnot(identical(tools::md5sum(names(before)),before))
if(mode=='collect') {
  stopifnot(!file.exists(target));saveRDS(result,target,version=3)
  for(n in names(tables))write.csv(tables[[n]],file.path(out,paste0(n,'.csv')),row.names=FALSE)
} else {
  stopifnot(identical(readRDS(target),result),!file.exists(file.path(out,'fresh-replay.rds')))
  paths<-c(target,file.path(out,paste0(names(tables),'.csv')));h<-tools::md5sum(paths)
  for(n in names(tables)) {
    f<-tempfile();write.csv(tables[[n]],f,row.names=FALSE)
    stopifnot(unname(tools::md5sum(f))==unname(h[file.path(out,paste0(n,'.csv'))]));unlink(f)
  }
  saveRDS(list(ChecksPassed=TRUE,SummaryFiles=h,Binding=binding,IndependentParents=50L,
    Fits=0L,Scores=0L,NewInferenceCalculations=0L),file.path(out,'fresh-replay.rds'),version=3)
}
cat('Complete paired category comparison',mode,'passed without numerical estimation.\n')
