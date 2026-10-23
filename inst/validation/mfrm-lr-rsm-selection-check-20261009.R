# Audit and exercise the frozen RSM procedure with existing, exactly matched
# q61 fits. No new fits, boundary fits or sampling units. Scoring qualification
# needs solution diagnostics absent from the saved population-interval objects.
# Run from package root with thread variables=1 and validation-R, then --args replay.
pkgload::load_all('.',quiet=TRUE,compile=FALSE)
helpers <- paste0('inst/validation/',c('mfrm-wide-map-mml-stages-20261001.R',
  'mfrm-lr-rsm-boundary-20261009.R','mfrm-lr-rsm-stages-20261009.R'))
for(path in helpers) source(path)
script <- 'inst/validation/mfrm-lr-rsm-selection-check-20261009.R'
# The parent directory preserves the first harness failure: blocking information
# evaluation also blocked the as-yet uncomputed scoring review. It is not a
# statistical refusal. Completed estimator/interval/boundary phases stay intact.
root <- 'validation-results/mfrm-lr-rsm-selection-20261009/scoring-continuation'
dir.create(root,recursive=TRUE,showWarnings=FALSE)
mode <- commandArgs(trailingOnly=TRUE)
if(!length(mode)) mode <- 'compute'
stopifnot(length(mode)==1L,mode %in% c('compute','replay'))
check_hashes <- function(h) stopifnot(identical(unname(tools::md5sum(names(h))),unname(h)))
sealed <- function(path,binding) {
  x <- readRDS(path)
  stopifnot(identical(x$binding,binding),identical(x$checksum,wide_mml_hash(x$payload)))
  x$payload
}
if(mode=='compute') {
  old_root <- 'validation-results/mfrm-lr-rsm-boundary-20261009'
  manifest_path <- file.path(old_root,'manifest.rds')
  old <- sealed(manifest_path,'RSM-LR-boundary-review-v1')
  check_hashes(old$inputs)
  runtime <- wide_mml_runtime()
  stopifnot(identical(old$runtime[names(runtime)[-1L]],runtime[-1L]),
    identical(old$rule,rsm_lr_rule()$boundary))
  previous <- old$runtime$source
  archived <- names(previous)!='loaded:mfrmr'
  h <- previous[archived];names(h) <- file.path(old_root,'source',names(h));check_hashes(h)
  stopifnot(identical(names(previous),names(runtime$source)))
  changed <- names(previous)[previous!=runtime$source]
  # Two reviewed inference edits and one comment-only help edit; no fitting change.
  stopifnot(setequal(changed,c('R/api-population-intervals.R','R/core-native-location-inference.R',
    'R/api-facet-intervals.R')),
    identical(parse('R/api-facet-intervals.R',keep.source=FALSE),
      parse(file.path(old_root,'source/R/api-facet-intervals.R'),keep.source=FALSE)))
  check_hashes(old$runtime$boundary_sources)
  public_path <- 'validation-results/mfrm-lr-boundary-api-20261009/evidence.rds'
  public <- readRDS(public_path);check_hashes(public$input_hashes)
  dll <- endsWith(names(public$source_hashes),'/mfrmr.so')
  stopifnot(sum(dll)==1L,unname(public$source_hashes[dll])==unname(runtime$source['loaded:mfrmr']))
  check_hashes(public$source_hashes[!dll])
  evidence_path <- file.path(old_root,'evidence.rds')
  evidence <- readRDS(evidence_path)
  stopifnot(unname(tools::md5sum(evidence_path))=='ddae4c9e67ab5ea77a87eca9fdbd2e88',
    unname(tools::md5sum(public_path))=='841685063e79b7a31976e2c3f8c2000f')
  inputs <- tools::md5sum(c(manifest_path,evidence_path,public_path))
  results <- list();records <- list()
  ids <- names(old$jobs)[vapply(old$jobs,function(job)!is.null(job$args),TRUE)]
  stopifnot(length(ids)==5L)
  testthat::with_mocked_bindings({
    for(id in ids) {
      a <- old$jobs[[id]]$args;stopifnot(a$quad_points==61L);a$quad_points <- NULL
      spec <- list(ConditionId=id,Arm='RSM-MML-LR',Replicate=1L,InputId=id,
        purpose='workflow_witness_only',args=a)
      binding <- list(manifest=wide_mml_hash(old),job=id)
      path <- file.path(old_root,id,'fit.rds')
      fitting <- sealed(path,c(binding,list(phase='fit',dependency=NULL)))
      dependency <- wide_mml_hash(fitting)
      phase <- function(name) sealed(file.path(old_root,id,paste0(name,'.rds')),
        c(binding,list(phase=name,dependency=dependency)))
      zero <- phase('zero');interior <- phase('interior');ci <- public$results[[id]]
      stopifnot(identical(ci$fit,fitting$value),identical(zero,evidence$results[[id]]$zero),
        identical(interior,evidence$results[[id]]$interior))
      initial <- list(args=c(a,list(quad_points=61L)),fit=fitting,zero=zero,interior=interior,
        population=list(value=ci,error='',warnings=ci$cautions,elapsed=0),
        provenance=list(inputs=inputs,source_changes=changed,
          reused=c('fit','zero','interior','population'),new='scoring-source qualification only',
          scope='Workflow witness; not an independent sampling replication.'))
      out <- file.path(root,id)
      selected <- rsm_lr_stages(spec,out,initial)
      rows <- rsm_lr_records(spec,selected,out)
      wanted <- id!='balanced-zero-control'
      stopifnot(length(selected$stages)==1L,all(rows$Available==wanted),
        all(is.finite(rows$Estimate)))
      results[[id]] <- list(spec=spec,selected=selected)
      records[[id]] <- rows
    }
  },fit_mfrm=function(...)stop('No refitting'),
    mfrm_native_location_inference=function(...)stop('Reuse saved interval qualification'),.package='mfrmr')
  sources <- c(helpers,script,names(runtime$source)[names(runtime$source)!='loaded:mfrmr'])
  sources <- unique(sources)
  for(path in sources) {
    dest <- file.path(root,'source',path);dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
    if(!file.exists(dest)) stopifnot(file.copy(path,dest))
    stopifnot(unname(tools::md5sum(path))==unname(tools::md5sum(dest)))
  }
  result <- list(rule=rsm_lr_rule(),contrasts=rsm_lr_contrasts(),runtime=runtime,
    source_hashes=tools::md5sum(sources),inputs=inputs,results=results,
    records=do.call(rbind,records),session=sessionInfo(),new_fits=0L,new_random_samples=0L,
    scope='Bounded workflow qualification; sampling coverage remains unqualified.')
  wide_mml_phase(file.path(root,'evidence.rds'),rsm_lr_rule()$version,function()result)
  write.csv(result$records,file.path(root,'records.csv'),row.names=FALSE)
  print(aggregate(Available~ConditionId+Output+Selection,result$records,sum),row.names=FALSE)
} else {
  x <- sealed(file.path(root,'evidence.rds'),rsm_lr_rule()$version)
  check_hashes(x$inputs);check_hashes(x$source_hashes)
  rows <- lapply(names(x$results),function(id) {
    saved <- x$results[[id]];out <- file.path(root,id)
    selected <- sealed(file.path(out,'selected.rds'),saved$selected$identity)
    stopifnot(identical(selected,saved$selected))
    manifest <- sealed(file.path(out,'manifest.rds'),x$rule$version)
    stopifnot(identical(wide_mml_hash(manifest),selected$identity),identical(manifest$spec,saved$spec))
    for(path in list.files(out,'^q[0-9]+-.*[.]rds$',full.names=TRUE)) {
      phase <- readRDS(path)
      stopifnot(identical(phase$checksum,wide_mml_hash(phase$payload)),
        identical(phase$binding$job,selected$identity))
    }
    rsm_lr_records(saved$spec,selected,out)
  })
  names(rows) <- names(x$results)
  stopifnot(identical(do.call(rbind,rows),x$records))
  saveRDS(list(passed=TRUE,evidence_hash=tools::md5sum(file.path(root,'evidence.rds')),
    session=sessionInfo()),file.path(root,paste0('replay-R',getRversion(),'.rds')),version=3)
  cat('All selection records and refusals replay without fitting or inference.\n')
}
