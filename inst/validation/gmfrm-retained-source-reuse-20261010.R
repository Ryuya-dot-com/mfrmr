# Check already saved later sources before allocating any further optimization.
# No refitting, new observations, or source selection using truth/coverage.
script <- 'inst/validation/gmfrm-retained-source-reuse-20261010.R'
audit_path <- 'validation-results/gmfrm-interval-disposition-20261010/review.rds'
parent <- 'validation-results/gmfrm-stationarity-continuation-20261010'
out <- 'validation-results/gmfrm-retained-source-reuse-20261010'
archive <- 'validation-results/mfrm-wide-map-d-historical-two-family-r50-20261006/scoring-source-v2'
args <- commandArgs(trailingOnly=TRUE)
stopifnot(length(args)==1L,args %in% c('prepare','run','summarize'))
pkgload::load_all(archive,quiet=TRUE,compile=FALSE,helpers=FALSE)
for (n in c('mml-stages','jml-stages','output-summary','multi-output'))
  source(file.path(archive,paste0('inst/validation/mfrm-wide-map-',n,'-20261001.R')))
source(file.path(archive,'inst/validation/mfrm-wide-map-d-output-20261005.R'))
check <- function(h) stopifnot(length(h)>0L,!anyNA(h),
  identical(unname(tools::md5sum(names(h))),unname(h)))
original <- readRDS(file.path(parent,'manifest.rds'))
check(original$sources); check(original$inputs)
stopifnot(identical(R.version.string,original$runtime$R),
  identical(Sys.getenv(names(original$runtime$threads)),original$runtime$threads),
  identical(vapply(names(original$runtime$dependencies),function(p)as.character(packageVersion(p)),''),original$runtime$dependencies),
  unname(tools::md5sum(getLoadedDLLs()[['mfrmr']][['path']])) == unname(original$runtime$source['loaded:mfrmr']))
# An accidental fitting call is an execution error, not an inferential refusal.
for(n in c('fit_mfrm','run_mfrm_optimization','mfrm_gmfrm_adaptive_fit'))
  trace(n,tracer=quote(stop('Reuse saved fits; optimization is disabled.')),
    where=asNamespace('mfrmr'),print=FALSE)
metadata_path <- file.path(out,'metadata.rds')
if(args=='prepare') {
  stopifnot(!file.exists(metadata_path))
  plan <- original$plan
  for(i in seq_len(nrow(plan))) {
    s <- readRDS(plan$SelectedPath[i])$payload
    plan$OldStage[i] <- s$intervals$slopes$stage
    plan$LaterStage[i] <- s$point$stage
    plan$LaterPointReady[i] <- isTRUE(s$point$value$ready)
    plan$LaterFit[i] <- file.path(dirname(plan$FitPath[i]),
      paste0(sub(':.*$','',s$point$stage),'-fit.rds'))
  }
  plan <- plan[plan$OldStage!=plan$LaterStage,]; rownames(plan)<-NULL
  stopifnot(nrow(plan)==31L,all(file.exists(plan$LaterFit)))
  m <- list(plan=plan,sources=tools::md5sum(script),
    inputs=tools::md5sum(unique(c(audit_path,file.path(parent,'manifest.rds'),
      plan$LaterFit,plan$ManifestPath,plan$SelectedPath))),
    protocol='Exactly the 31 already saved later sources in the 32-case stationary-refusal group. Apply unchanged joint-information and all twenty public interval consumers. Never optimize or select using truth. Original results remain immutable; this is development evidence only.')
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  wide_mml_save(m,metadata_path); cat('Prepared 31 saved-source reuses; no numerical work.\n')
  quit(save='no')
}
m <- readRDS(metadata_path); check(m$sources);check(m$inputs)
seal <- tools::md5sum(metadata_path)
if(args=='run') for(i in seq_len(nrow(m$plan))) {
  j<-m$plan[i,]; p<-file.path(out,paste0(j$Job,'.rds'))
  binding<-list(metadata=seal,job=j$Job)
  wide_mml_phase(p,binding,function() {
    fit<-readRDS(j$LaterFit)$payload$value
    spec<-readRDS(j$ManifestPath)$payload$spec
    joint<-wide_mml_capture(function()mfrmr:::mfrm_gpcm_product_inference(fit))
    admitted<-!nzchar(joint$error)&&isTRUE(joint$value$check$eligible)
    intervals<-NULL; reason<-joint$error
    if(admitted) {
      consume<-wide_d_consumers(fit,joint)
      intervals<-do.call(rbind,lapply(spec$outputs,function(c) {
        value<-consume(fit,c,spec$level)
        wide_multi_interval_table(value,spec,c,fit)
      }))
      rownames(intervals)<-NULL
      stopifnot(nrow(intervals)==20L,all(intervals$Available))
    } else if(!nzchar(reason)) reason<-joint$value$check$review
    cat(j$Job,if(admitted)'admitted' else reason,'\n');flush.console()
    list(job=j,admitted=admitted,reason=reason,intervals=intervals,joint=joint)
  })
}
if(args=='summarize') {
  paths<-file.path(out,paste0(m$plan$Job,'.rds'));stopifnot(all(file.exists(paths)))
  values<-lapply(paths,function(p){x<-readRDS(p);stopifnot(identical(x$checksum,wide_mml_hash(x$payload)));x$payload})
  rows<-do.call(rbind,lapply(values,function(x)data.frame(N=x$job$N,
    Replicate=x$job$Replicate,Admitted=x$admitted,Reason=x$reason)))
  wide_mml_save(list(rows=rows,results=values,metadata=seal,files=tools::md5sum(paths)),file.path(out,'summary.rds'))
  print(with(rows,table(N,Admitted)))
}
check(m$sources);check(m$inputs)
