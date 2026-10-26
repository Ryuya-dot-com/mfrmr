# Finish the remaining original SD1/common H-both cells without new responses.
# Usage: Rscript --vanilla THIS_FILE prepare|run|summarize|replay [JOB ...]
size_script <- 'inst/validation/mfrm-wide-map-d-size-counterparts-20261011.R'
source(size_script)
script <- 'inst/validation/mfrm-wide-map-d-remaining-counterparts-20261011.R'
out <- 'validation-results/mfrm-wide-map-d-remaining-counterparts-20261011'
sample_sizes <- c(30L,40L,120L)
collect <- function(manifest) {
  result <- collect_saved(manifest)
  result$scope <- sub('N20 SD1/common', 'N30/N40/N120 SD1/common', result$scope, fixed=TRUE)
  result
}

if (sys.nframe() == 0L) {
  arguments <- commandArgs(trailingOnly=TRUE)
  stopifnot(length(arguments)>=1L, arguments[1L] %in% c('prepare','run','summarize','replay'))
  mode <- arguments[1L]
  if (mode=='prepare') {
    stopifnot(!dir.exists(out))
    previous <- readRDS(previous_dispatch)
    check_hashes(previous$source); check_hashes(previous$inputs)
    runtime <- wide_mml_runtime(); stopifnot(identical(runtime,previous$runtime))
    index <- read.csv(registry,stringsAsFactors=FALSE)
    references <- list(); consumed <- character()
    for (n in sample_sizes) {
      condition <- paste0('D:historical-full-common:N',n,':SD1:H-both')
      path <- file.path(reference_root,paste0('n',n,'-sd1-common'))
      d <- readRDS(file.path(path,'dispatch.rds'))
      completed <- read_phase(file.path(path,'native-summary.rds'))
      check_hashes(completed$binding$dispatch); check_hashes(completed$binding$outputs)
      stopifnot(identical(d$runtime,previous$reference_runtime))
      rows <- index[index$ConditionId==condition,]
      stopifnot(nrow(rows)==50L,setequal(rows$Replicate,1:50),d$new_responses==0L)
      files <- names(completed$binding$outputs); stopifnot(length(files)==50L)
      specs <- lapply(dirname(files),function(p)read_phase(file.path(p,'manifest.rds'))$payload)
      reps <- vapply(specs,function(s)s$spec$Replicate,1L)
      stopifnot(setequal(reps,1:50),!anyDuplicated(reps))
      at <- match(rows$Replicate,reps)
      rows$ReferenceJob <- dirname(files[at]); rows$Arm <- reference_arm
      for (i in seq_len(nrow(rows))) {
        row <- rows[i,]; original <- specs[[at[i]]]
        check_hashes(setNames(row$BundleMD5,row$Bundle))
        stopifnot(identical(original$runtime,d$runtime),
          identical(original$spec$ConditionId,row$ConditionId),
          identical(original$spec$Replicate,row$Replicate),
          identical(original$spec$args$data,input_data(row)))
        output <- read_phase(file.path(row$ReferenceJob,'d-outputs.rds'))
        selected <- read_phase(file.path(row$ReferenceJob,'selected.rds'))
        stopifnot(identical(output$binding$selected,wide_mml_hash(selected$payload)))
      }
      references[[as.character(n)]] <- rows
      consumed <- c(consumed,file.path(path,c('dispatch.rds','native-summary.rds')),
        file.path(rows$ReferenceJob,'d-outputs.rds'),file.path(rows$ReferenceJob,'selected.rds'),
        file.path(rows$ReferenceJob,'manifest.rds'))
    }
    references <- do.call(rbind,references); rownames(references) <- NULL
    templates <- read_phase(template_path)$payload$specs[c('PCM-MML-free','GPCM-MML-free')]
    jobs <- do.call(rbind,lapply(arms,function(arm){x<-references;x$Arm<-arm;x}))
    jobs <- jobs[order(jobs$N,jobs$Replicate,match(jobs$Arm,arms)),]; rownames(jobs)<-NULL
    jobs$Job <- sprintf('job-%04d',seq_len(nrow(jobs)))
    stopifnot(nrow(jobs)==450L,nrow(references)==150L)
    for (i in seq_len(nrow(jobs))) make_spec(jobs[i,],templates)
    sources <- unique(c(script,size_script,continuation_script,names(previous$source)))
    inputs <- unique(c(previous_dispatch,names(previous$inputs),registry,contracts_path,
      template_path,references$Bundle,consumed))
    manifest <- list(jobs=jobs,references=references,templates=templates,orders=c(31L,61L,121L),
      source=tools::md5sum(sources),inputs=tools::md5sum(inputs),runtime=runtime,
      reference_runtime=previous$reference_runtime,new_responses=0L,
      protocol=c('Original N30/N40/N120 SD1/common H-both R50 allocations; every input retained.',
        'Frozen N240 point_job and N20 collector; only selectors, reference paths and scope label differ.',
        'Unchanged free-population PCM/one-family fitting, source admission and integration-only retry.',
        'Compare probability/normalized-score MSE and standardized Task/Rater discrepancies.',
        'All-attempt delivery and paired/four-return conditional losses; exploratory MC intervals within cells.',
        'N20/N60/N240/N480 controls reused; no generic N threshold, model-choice or interval qualification.'))
    check_hashes(manifest$source); check_hashes(manifest$inputs)
    dir.create(file.path(out,'source'),recursive=TRUE)
    for(p in sources) {
      dest <- file.path(out,'source',p);dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
      stopifnot(file.copy(p,dest))
    }
    wide_mml_save(manifest,file.path(out,'dispatch.rds'))
    write.csv(jobs[c('Job','ConditionId','Replicate','N','Arm','ReferenceJob')],
      file.path(out,'jobs.csv'),row.names=FALSE)
    cat('Frozen 450 missing N30/N40/N120 jobs and 150 retained GMFRM outcomes. No fits.\n')
  } else {
    manifest <- readRDS(file.path(out,'dispatch.rds'))
    check_hashes(manifest$source);check_hashes(manifest$inputs)
    stopifnot(identical(wide_mml_runtime(),manifest$runtime))
    if (mode=='run') {
      ids <- if(length(arguments)>1L)as.integer(arguments[-1L])else seq_len(nrow(manifest$jobs))
      stopifnot(!anyNA(ids),!anyDuplicated(ids),all(ids %in% seq_len(nrow(manifest$jobs))))
      lock <- file.path(out,'RUNNING');stopifnot(dir.create(lock,showWarnings=FALSE))
      execute <- function() {
        on.exit(unlink(lock,recursive=TRUE))
        writeLines(as.character(Sys.getpid()),file.path(lock,'pid'))
        chunks <- split(ids,rep(1:2,length.out=length(ids)))
        status <- parallel::mclapply(chunks,function(at) {
          for(i in at)point_job(manifest$jobs[i,],manifest)
          TRUE
        },mc.cores=min(2L,length(chunks)),mc.set.seed=FALSE)
        stopifnot(all(vapply(status,isTRUE,TRUE)))
      }
      execute();cat('Completed requested jobs; cached phases reused.\n')
    } else {
      for(name in c('fit_mfrm','compute_mml_parameter_covariance','simulate_mfrm_data'))
        trace(name,quote(stop('No numerical recomputation in summary/replay.')),
          where=asNamespace('mfrmr'),print=FALSE)
      result <- collect(manifest);result$summary_source<-tools::md5sum(script)
      file <- file.path(out,'comparison.rds')
      if(mode=='replay') {
        stopifnot(identical(readRDS(file),result))
        cat('Fresh replay reproduced N30/N40/N120 comparison without fitting, generation or information.\n')
      } else {
        stopifnot(!file.exists(file));wide_mml_save(result,file)
        for(n in c('rows','summary','paired'))
          write.csv(result[[n]],file.path(out,paste0(n,'.csv')),row.names=FALSE)
        print(result$summary[,c('ConditionId','Arm','Selection','Returned','ProbabilityMSE')],row.names=FALSE)
      }
    }
    check_hashes(manifest$source);check_hashes(manifest$inputs)
  }
}
