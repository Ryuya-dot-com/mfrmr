# Original N60/SD1/common controls; reuse the qualified point procedure.
# Usage: Rscript --vanilla THIS_FILE prepare|run|summarize|replay [JOB ...]
control_script <- 'inst/validation/mfrm-wide-map-d-controls-20261012.R'
source(control_script)
script <- 'inst/validation/mfrm-wide-map-d-n60-controls-20261012.R'
out <- 'validation-results/mfrm-wide-map-d-n60-controls-20261012'
control_dispatch <- 'validation-results/mfrm-wide-map-d-n20-controls-20261012/dispatch.rds'
baseline_dispatch <- 'validation-results/mfrm-wide-map-d-size-counterparts-20261011/dispatch.rds'
baseline_comparison <- 'validation-results/mfrm-wide-map-d-size-counterparts-20261011/comparison.rds'
collect <- function(manifest) {
  result <- collect_saved(manifest)
  result$scope <- sub('H-both N20 SD1/common','H-equal/H-first-only/H-second-only N60 SD1/common',
    result$scope,fixed=TRUE)
  result
}

if(sys.nframe()==0L) {
  arguments <- commandArgs(trailingOnly=TRUE)
  stopifnot(length(arguments)>=1L,arguments[1L] %in% c('prepare','run','summarize','replay'))
  mode <- arguments[1L]
  if(mode=='prepare') {
    stopifnot(!dir.exists(out))
    previous <- readRDS(control_dispatch)
    check_hashes(previous$source);check_hashes(previous$inputs)
    runtime <- wide_mml_runtime();stopifnot(identical(runtime,previous$runtime))
    qualification_path <- file.path(dirname(control_dispatch),'qualification.rds')
    qualification <- readRDS(qualification_path)
    stopifnot(isTRUE(qualification$passed),identical(qualification$source,previous$source))
    check_hashes(qualification$consumed);check_hashes(qualification$test)
    check_hashes(qualification$inherited_qualification)
    baseline <- readRDS(baseline_dispatch)
    check_hashes(baseline$source);check_hashes(baseline$inputs)
    saved_baseline <- readRDS(baseline_comparison);check_hashes(saved_baseline$consumed)
    stopifnot(identical(runtime,baseline$runtime),
      identical(previous$reference_runtime,baseline$reference_runtime))

    # Earlier absence audits were for other N; inspect all current dispatches for N60.
    inspection <- readRDS('/tmp/mfrmr-d-n60-control-audit-20261012.rds')
    stopifnot(length(inspection$matches)==0L);check_hashes(inspection$paths)
    index <- read.csv(registry,stringsAsFactors=FALSE)
    rows <- subset(index,N==60L & SD==1 & Design=='historical-reduced-common' & Truth %in% truths)
    stopifnot(nrow(rows)==150L,all(table(rows$Truth)==50L),
      all(rows$Selector=='views[[View]]$data'),all(rows$ObservedRows==360L))
    contracts <- readRDS(contracts_path)$contracts
    reference <- subset(index,ConditionId=='D:historical-full-common:N60:SD1:H-both')
    for(i in seq_len(nrow(rows))) {
      row<-rows[i,];old<-reference[reference$Replicate==row$Replicate,]
      check_hashes(setNames(c(row$BundleMD5,old$BundleMD5),c(row$Bundle,old$Bundle)))
      stopifnot(identical(input_data(row)[c('Person','Task','Rater')],
        input_data(old)[c('Person','Task','Rater')]),row$MetadataBundle==old$MetadataBundle,
        row$MetadataMD5==old$MetadataMD5)
      truth<-contracts[[row$ConditionId]]$two_family_fixed_normal
      other<-contracts[[old$ConditionId]]$two_family_fixed_normal
      stopifnot(identical(truth$locations,other$locations),identical(truth$steps,other$steps),
        identical(truth$levels,other$levels),truth$sd==1,truth$mu==0)
    }
    jobs <- do.call(rbind,lapply(all_arms,function(arm){x<-rows;x$Arm<-arm;x}))
    jobs <- jobs[order(match(jobs$Truth,truths),jobs$Replicate,match(jobs$Arm,all_arms)),]
    rownames(jobs)<-NULL;jobs$Job<-sprintf('job-%04d',seq_len(nrow(jobs)))
    templates<-previous$templates
    for(i in seq_len(nrow(jobs)))make_spec(jobs[i,],templates)
    sources<-unique(c(script,control_script,names(previous$source)))
    inputs<-unique(c(control_dispatch,names(previous$inputs),qualification_path,
      baseline_dispatch,baseline_comparison,names(baseline$inputs),
      names(saved_baseline$consumed),rows$Bundle,rows$MetadataBundle))
    manifest<-list(jobs=jobs,references=jobs[FALSE,],templates=templates,orders=previous$orders,
      source=tools::md5sum(sources),inputs=tools::md5sum(inputs),runtime=runtime,
      reference_runtime=previous$reference_runtime,new_responses=0L,saved_stage_inspection=inspection,
      protocol=c('Original three N60/SD1/common controls, all 50 attempts, all four point models.',
        'Inherit N240 make_spec, point_job, independent mappings and numerical collector.',
        'Reuse N20 qualification; qualify the retained N60 baseline without new fitting.',
        'Same source-admission rule and q31/61/121 integration-only retry; preserve refusals.',
        'Delivery first; own-admitted and matched losses are conditional, not unconditional risk.',
        'Reuse N60 H-both and N20/N240 controls; no general model-ranking qualification.',
        'No new responses, optimizer tuning, interval qualification or public changes.'))
    check_hashes(manifest$source);check_hashes(manifest$inputs)
    dir.create(file.path(out,'source'),recursive=TRUE)
    for(p in sources){dest<-file.path(out,'source',p);dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE);stopifnot(file.copy(p,dest))}
    wide_mml_save(manifest,file.path(out,'dispatch.rds'))
    write.csv(jobs[c('Job','ConditionId','Replicate','Truth','Arm')],file.path(out,'jobs.csv'),row.names=FALSE)
    cat('Frozen 600 missing N60 control point jobs on 150 existing datasets. No fitting.\n')
  } else {
    manifest<-readRDS(file.path(out,'dispatch.rds'))
    check_hashes(manifest$source);check_hashes(manifest$inputs)
    stopifnot(identical(wide_mml_runtime(),manifest$runtime))
    if(mode=='run') {
      q<-readRDS(file.path(out,'qualification.rds'))
      stopifnot(isTRUE(q$passed),identical(q$source,manifest$source))
      ids<-if(length(arguments)>1L)as.integer(arguments[-1L])else seq_len(nrow(manifest$jobs))
      stopifnot(!anyNA(ids),!anyDuplicated(ids),all(ids %in% seq_len(nrow(manifest$jobs))))
      lock<-file.path(out,'RUNNING');stopifnot(dir.create(lock,showWarnings=FALSE))
      execute<-function(){
        on.exit(unlink(lock,recursive=TRUE))
        writeLines(as.character(Sys.getpid()),file.path(lock,'pid'))
        chunks<-split(ids,rep(1:2,each=4L,length.out=length(ids)))
        status<-parallel::mclapply(chunks,function(at){for(i in at)point_job(manifest$jobs[i,],manifest);TRUE},
          mc.cores=min(2L,length(chunks)),mc.set.seed=FALSE)
        stopifnot(all(vapply(status,isTRUE,TRUE)))
      }
      execute();cat('Completed requested jobs; cached phases reused.\n')
    } else {
      for(name in c('fit_mfrm','compute_mml_parameter_covariance','simulate_mfrm_data','mfrm_gpcm_product_inference'))
        trace(name,quote(stop('No numerical recomputation in summary/replay.')),where=asNamespace('mfrmr'),print=FALSE)
      result<-collect(manifest);result$summary_source<-tools::md5sum(script)
      file<-file.path(out,'comparison.rds')
      if(mode=='replay') {
        stopifnot(identical(readRDS(file),result));cat('Fresh replay reproduced the N60 controls without numerical recomputation.\n')
      } else {
        stopifnot(!file.exists(file));wide_mml_save(result,file)
        for(n in c('rows','summary','paired'))write.csv(result[[n]],file.path(out,paste0(n,'.csv')),row.names=FALSE)
        print(result$summary[result$summary$Selection=='admitted',c('ConditionId','Arm','Returned','ProbabilityMSE')],row.names=FALSE)
      }
    }
    check_hashes(manifest$source);check_hashes(manifest$inputs)
  }
}
