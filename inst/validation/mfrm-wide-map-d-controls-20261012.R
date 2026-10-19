# Original N240/SD1/common truth controls, point outputs only; no new responses.
# Usage: Rscript --vanilla THIS_FILE prepare|run|summarize|replay [JOB ...]
size_script <- 'inst/validation/mfrm-wide-map-d-size-counterparts-20261011.R'
source(size_script)
script <- 'inst/validation/mfrm-wide-map-d-controls-20261012.R'
out <- 'validation-results/mfrm-wide-map-d-controls-20261012'
prototype_path <- 'validation-results/mfrm-wide-map-d-retained-output-20261005/job-003/manifest.rds'
truths <- c('H-equal','H-first-only','H-second-only')
all_arms <- c(arms,reference_arm)
ordinary_mapping <- check_mapping
check_mapping <- function(fit,mapped) {
  if(length(fit$config$slope_facet)!=2L)return(ordinary_mapping(fit,mapped))
  p <- mfrmr:::expand_params(fit$opt$par,mfrmr:::build_param_sizes(fit$config),fit$config)
  g <- mapped$grid
  stopifnot(identical(fit$config$posterior_basis,'fixed_standard_normal'))
  eta <- g$z-p$facets$Task[g$first]-p$facets$Rater[g$second]
  slope <- p$slope_components$Task$Slope[g$first]*p$slope_components$Rater$Slope[g$second]
  logmass <- matrix(0,nrow(g),3L)
  for(k in 1:2)logmass[,k+1L]<-logmass[,k]+slope*(eta-p$steps_mat[g$second,k])
  probability <- exp(logmass-apply(logmass,1L,max));probability<-probability/rowSums(probability)
  error <- max(abs(probability-mapped$probabilities))
  stopifnot(is.finite(error),error<=1e-12,max(abs(rowSums(mapped$probabilities)-1))<=1e-12)
  error
}
make_spec <- function(row,templates) {
  stopifnot(row$Truth %in% c(truths,'H-both'),row$Arm %in% all_arms,
    grepl('^D:historical-(full|reduced)-',row$ConditionId),row$SD %in% c(.5,1))
  check_hashes(setNames(row$BundleMD5,row$Bundle))
  data <- input_data(row)
  if(row$Arm==reference_arm) {
    a <- templates[['GPCM-two-family-MML']]$args;a$data<-data
  } else {
    a <- templates[[if(row$Arm==arms[1L])'PCM-MML-free' else 'GPCM-MML-free']]$args
    a$data<-data;a$facets<-c('Task','Rater');a$step_facet<-'Rater';a$rating_max<-2
    a$person_data<-data.frame(Person=sort(unique(data$Person)))
    if(row$Arm!=arms[1L])a$slope_facet<-if(row$Arm==arms[2L])'Task' else 'Rater'
  }
  stopifnot(nrow(data)==row$ObservedRows,length(unique(data$Person))==row$N,
    !anyDuplicated(data[c('Person','Task','Rater')]))
  spec <- list(ConditionId=row$ConditionId,Replicate=row$Replicate,Arm=row$Arm,
    InputId=paste(row$UnitId,row$View,row$BundleMD5,sep=':'),args=a,
    facet='Task',level=.95,purpose='D_R50_response_point_comparison')
  wide_mml_validate(spec);spec
}
collect <- function(manifest) {
  result <- collect_saved(manifest)
  result$scope <- sub('H-both N20 SD1/common','H-equal/H-first-only/H-second-only N240 SD1/common',
    result$scope,fixed=TRUE)
  result
}

if(sys.nframe()==0L) {
  arguments <- commandArgs(trailingOnly=TRUE)
  stopifnot(length(arguments)>=1L,arguments[1L] %in% c('prepare','run','summarize','replay'))
  mode<-arguments[1L]
  if(mode=='prepare') {
    stopifnot(!dir.exists(out))
    previous<-readRDS(previous_dispatch)
    check_hashes(previous$source);check_hashes(previous$inputs)
    runtime<-wide_mml_runtime();stopifnot(identical(runtime,previous$runtime))
    prototype<-read_phase(prototype_path)$payload
    stopifnot(identical(prototype$runtime,previous$reference_runtime))
    templates<-previous$templates
    templates[['GPCM-two-family-MML']]<-list(args=prototype$spec$args)
    index<-read.csv(registry,stringsAsFactors=FALSE)
    rows<-subset(index,N==240L & SD==1 & Design=='historical-reduced-common' & Truth %in% truths)
    stopifnot(nrow(rows)==150L,all(table(rows$Truth)==50L),
      all(rows$Selector=='views[[View]]$data'),all(rows$ObservedRows==1440L))
    contracts<-readRDS(contracts_path)$contracts
    baseline<-subset(index,ConditionId=='D:historical-full-common:N240:SD1:H-both')
    # Pairing of rosters, latent draws and uniforms is established by the frozen bundles.
    for(i in seq_len(nrow(rows))) {
      row<-rows[i,];old<-baseline[baseline$Replicate==row$Replicate,]
      check_hashes(setNames(c(row$BundleMD5,old$BundleMD5),c(row$Bundle,old$Bundle)))
      stopifnot(identical(input_data(row)[c('Person','Task','Rater')],
        input_data(old)[c('Person','Task','Rater')]),row$MetadataBundle==old$MetadataBundle,
        row$MetadataMD5==old$MetadataMD5)
      truth<-contracts[[row$ConditionId]]$two_family_fixed_normal
      other<-contracts[[old$ConditionId]]$two_family_fixed_normal
      stopifnot(identical(truth$locations,other$locations),identical(truth$steps,other$steps),
        identical(truth$levels,other$levels),truth$sd==1,truth$mu==0)
    }
    jobs<-do.call(rbind,lapply(all_arms,function(arm){x<-rows;x$Arm<-arm;x}))
    jobs<-jobs[order(match(jobs$Truth,truths),jobs$Replicate,match(jobs$Arm,all_arms)),]
    rownames(jobs)<-NULL;jobs$Job<-sprintf('job-%04d',seq_len(nrow(jobs)))
    for(i in seq_len(nrow(jobs)))make_spec(jobs[i,],templates)
    sources<-unique(c(script,size_script,continuation_script,names(previous$source)))
    inputs<-unique(c(previous_dispatch,names(previous$inputs),prototype_path,registry,
      contracts_path,rows$Bundle,rows$MetadataBundle,
      'validation-results/mfrm-wide-map-d-counterparts-20261011/comparison.rds'))
    audit<-readRDS('/tmp/mfrmr-d-control-saved-stages-20261012.rds')
    stopifnot(is.null(audit$matches));check_hashes(audit$paths)
    manifest<-list(jobs=jobs,references=jobs[FALSE,],templates=templates,orders=c(31L,61L,121L),
      source=tools::md5sum(sources),inputs=tools::md5sum(inputs),runtime=runtime,
      reference_runtime=previous$reference_runtime,new_responses=0L,saved_stage_inspection=audit,
      protocol=c('Original three N240/SD1/common truth controls, all 50 attempts, four models each.',
        'Unchanged point_job fitting/admission body; product arguments from the retained prototype.',
        'Point-only execution preserves original first admission; no unused interval consumers.',
        'Initial diagnostics, all-attempt delivery, pair/four-return losses and exploratory MC intervals.',
        'Retain the H-both source epoch; no new responses, optimizer rescue or interval qualification.'))
    check_hashes(manifest$source);check_hashes(manifest$inputs)
    dir.create(file.path(out,'source'),recursive=TRUE)
    for(p in sources){dest<-file.path(out,'source',p);dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE);stopifnot(file.copy(p,dest))}
    wide_mml_save(manifest,file.path(out,'dispatch.rds'))
    write.csv(jobs[c('Job','ConditionId','Replicate','Truth','Arm')],file.path(out,'jobs.csv'),row.names=FALSE)
    cat('Frozen 600 missing point jobs on 150 existing control datasets. No fitting.\n')
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
        stopifnot(identical(readRDS(file),result));cat('Fresh replay reproduced the three truth controls without numerical recomputation.\n')
      } else {
        stopifnot(!file.exists(file));wide_mml_save(result,file)
        for(n in c('rows','summary','paired'))write.csv(result[[n]],file.path(out,paste0(n,'.csv')),row.names=FALSE)
        print(result$summary[result$summary$Selection=='admitted',c('ConditionId','Arm','Returned','ProbabilityMSE')],row.names=FALSE)
      }
    }
    check_hashes(manifest$source);check_hashes(manifest$inputs)
  }
}
