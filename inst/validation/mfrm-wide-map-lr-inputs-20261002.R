# D-LR Gaussian covariate views of existing A/B responses. No fitting here.
# Rscript THIS_FILE OUTPUT_DIRECTORY; immutable registry/bundles support resume.
dlr_script <- 'inst/validation/mfrm-wide-map-lr-inputs-20261002.R'
dlr_root <- 'validation-results/mfrm-wide-map-r50-20261001'

dlr_save <- function(x, path) {
  tmp <- tempfile(basename(path), tmpdir=dirname(path))
  on.exit(unlink(tmp), add=TRUE)
  saveRDS(x,tmp,version=3)
  if (!file.rename(tmp,path)) stop('Atomic save failed: ',path)
}

dlr_models <- function(truth) switch(truth,
  'S-RSM'='RSM', 'S-PCM'=c('PCM','GPCM'), 'S-GPCM'='GPCM',
  stop('Unknown A/B response truth.'))

dlr_registry <- function(root=dlr_root) {
  head_path <- file.path(root,'rng-head.rds'); head <- readRDS(head_path)
  stopifnot(head$epoch=='development-E-20261001-v1', head$next_unit_ordinal==4751L,
    identical(tools::md5sum(head$registry),head$registry_md5))
  previous <- readRDS(head$registry)
  ab_root <- file.path(root,'ab-inputs')
  verified <- readRDS(file.path(ab_root,'verified-inputs.rds'))
  for (hash in list(verified$registry_md5,verified$inputs_md5))
    stopifnot(identical(tools::md5sum(names(hash)),hash))
  ab <- readRDS(file.path(ab_root,'rng-registry.rds'))
  index <- read.csv(file.path(ab_root,'inputs.csv'),stringsAsFactors=FALSE)
  units <- ab$units
  units$ABBundle <- file.path(ab_root,units$Bundle)
  units$ABBundleMD5 <- index$BundleMD5[match(units$ParentId,index$ParentId)]
  units$Bundle <- sprintf('bundles/parent-%04d.rds',seq_len(nrow(units)))
  stopifnot(nrow(units)==2100L,!anyNA(units$ABBundleMD5))
  stream <- previous$next_unused_unit_stream
  streams <- setNames(vector('list',nrow(units)),units$ParentId)
  for (i in seq_len(nrow(units))) {
    streams[[i]] <- list(covariate=stream,
      future_covariate_first_unused=parallel::nextRNGSubStream(stream))
    stream <- parallel::nextRNGStream(stream)
  }
  list(epoch='development-DLR-20261002-v1',units=units,streams=streams,rhos=c(0,.5),
    RNG=c("L'Ecuyer-CMRG",'Inversion','Rejection'),
    predecessor=head, predecessor_head_md5=tools::md5sum(head_path),
    ab_registry_md5=verified$registry_md5,ab_index_md5=verified$inputs_md5,
    first_unit_ordinal=4751L,next_unit_ordinal=6851L,
    first_unit_stream=previous$next_unused_unit_stream,next_unused_unit_stream=stream,
    pairing='One Z per A/B Person, shared by rho and exposure views; no sample standardization.',
    scope='Gaussian X core only; categorical/missingness extensions and F covariate allocation remain open.')
}

dlr_generate <- function(unit,seeds) {
  stopifnot(unname(tools::md5sum(unit$ABBundle))==unit$ABBundleMD5)
  ab <- readRDS(unit$ABBundle)
  stopifnot(ab$unit$ParentId==unit$ParentId,ab$unit$N==unit$N,
    ab$unit$SD==unit$SD,length(ab$theta)==unit$N)
  kind <- RNGkind(); had <- exists('.Random.seed',.GlobalEnv,inherits=FALSE)
  if (had) old <- get('.Random.seed',.GlobalEnv)
  on.exit({do.call(RNGkind,as.list(kind)); if(had) assign('.Random.seed',old,.GlobalEnv)
    else if(exists('.Random.seed',.GlobalEnv,inherits=FALSE)) rm('.Random.seed',envir=.GlobalEnv)},add=TRUE)
  RNGkind("L'Ecuyer-CMRG",normal.kind='Inversion',sample.kind='Rejection')
  assign('.Random.seed',seeds$covariate,.GlobalEnv); z <- rnorm(unit$N)
  persons <- lapply(c(0,.5),function(rho) data.frame(Person=names(ab$theta),
    X=unname(rho*ab$theta/unit$SD+sqrt(1-rho^2)*z)))
  names(persons) <- c('rho0','rho0.5')
  truth <- lapply(c(0,.5),function(rho) list(coefficients=c('(Intercept)'=0,X=rho*unit$SD),
    residual_variance=unit$SD^2*(1-rho^2),marginal_variance=unit$SD^2,rho=rho))
  names(truth) <- names(persons)
  list(unit=unit,rng=seeds,z=z,person_data=persons,population_truth=truth,
    contract='AB_joint_normal_covariates_v1')
}

dlr_check <- function(x,unit,seeds) {
  ab <- readRDS(unit$ABBundle)
  stopifnot(identical(x$unit,unit),identical(x$rng,seeds),
    identical(names(x$person_data),c('rho0','rho0.5')),length(x$z)==unit$N,all(is.finite(x$z)))
  for (key in names(x$person_data)) {
    p <- x$person_data[[key]]; t <- x$population_truth[[key]]; rho <- t$rho
    stopifnot(identical(names(p),c('Person','X')),identical(p$Person,names(ab$theta)),
      identical(p$X,unname(rho*ab$theta/unit$SD+sqrt(1-rho^2)*x$z)),
      identical(t$coefficients,c('(Intercept)'=0,X=rho*unit$SD)),
      t$residual_variance==unit$SD^2*(1-rho^2),t$marginal_variance==unit$SD^2)
  }
  invisible(TRUE)
}

dlr_fit_input <- function(row, out, model) {
  stopifnot(nrow(row)==1L,model %in% dlr_models(row$Truth))
  path <- file.path(out,row$Bundle)
  stopifnot(unname(tools::md5sum(path))==row$BundleMD5,
    unname(tools::md5sum(row$ABBundle))==row$ABBundleMD5)
  x <- readRDS(path); ab <- readRDS(row$ABBundle)
  stopifnot(x$unit$ParentId==row$ParentId,x$unit$Replicate==row$Replicate,
    x$unit$N==row$N,x$unit$SD==row$SD,x$unit$Truth==row$Truth,
    row$View %in% names(ab$views),
    row$ControlConditionId==paste('AB',row$View,paste0('N',row$N),paste0('SD',row$SD),row$Truth,sep=':'),
    row$ConditionId==paste('DLR',row$CovariateView,row$ControlConditionId,sep=':'),
    x$population_truth[[row$CovariateView]]$rho==row$Rho)
  # Only observed response columns and X enter fitting. Z/theta/truth stay out.
  args <- list(data=ab$views[[row$View]][c('Person','Rater','Criterion','Score')],
    person='Person',facets=c('Rater','Criterion'),score='Score',rating_min=0,rating_max=3,
    model=model,method='MML',population_formula=~X,person_data=x$person_data[[row$CovariateView]],
    person_id='Person',population_policy='error',category_policy='preserve',
    mml_engine='direct',mml_integration='fixed',optimizer='BFGS',maxit=400L,reltol=1e-9)
  if(model!='RSM') args$step_facet <- 'Criterion'
  if(model=='GPCM') {
    args$slope_facet <- 'Criterion'; args$gpcm_mml_identification <- 'free_population'
  }
  args
}

dlr_prepare <- function(out,root=dlr_root) {
  registry_path <- file.path(out,'rng-registry.rds'); head_path <- file.path(root,'rng-head.rds')
  if(!file.exists(registry_path)) {
    stopifnot(!length(list.files(file.path(out,'bundles'))))
    registry <- dlr_registry(root)
    dir.create(file.path(out,'bundles'),recursive=TRUE,showWarnings=FALSE)
    dir.create(file.path(out,'source'),showWarnings=FALSE)
    sources <- c(dlr_script,'inst/validation/internal-roadmap-0.2.4.md')
    for(path in sources) {
      target <- file.path(out,'source',basename(path))
      if(!file.exists(target)) stopifnot(file.copy(path,target))
      stopifnot(unname(tools::md5sum(path))==unname(tools::md5sum(target)))
    }
    registry$source_paths <- sources; registry$source_md5 <- tools::md5sum(sources)
    dlr_save(registry,registry_path)
  } else registry <- readRDS(registry_path)
  stopifnot(unname(tools::md5sum(dlr_script))==unname(registry$source_md5[1]),
    identical(unname(tools::md5sum(file.path(out,'source',basename(registry$source_paths)))),
      unname(registry$source_md5)))
  for(hash in list(registry$ab_registry_md5,registry$ab_index_md5,registry$predecessor$registry_md5))
    stopifnot(identical(tools::md5sum(names(hash)),hash))
  # Reserve the whole allocation before drawing, including after an interrupted
  # first run. Existing A-E registries and F substreams remain unchanged.
  head <- readRDS(head_path)
  new_head <- list(registry=registry_path,registry_md5=tools::md5sum(registry_path),
    preceding_registry_md5=registry$predecessor$registry_md5,
    last_reserved_unit_ordinal=6850L,next_unit_ordinal=6851L,epoch=registry$epoch,
    note='A-E and D-LR Gaussian covariate streams reserved; each D-LR parent retains a future-covariate substream.')
  if(identical(head,registry$predecessor)) dlr_save(new_head,head_path)
  else stopifnot(identical(head,new_head))

  ab_index <- read.csv(names(registry$ab_index_md5),stringsAsFactors=FALSE)
  rows <- list(); next_row <- 0L
  for(i in seq_len(nrow(registry$units))) {
    unit <- registry$units[i, ]; seeds <- registry$streams[[i]]; path <- file.path(out,unit$Bundle)
    stopifnot(unname(tools::md5sum(unit$ABBundle))==unit$ABBundleMD5)
    if(!file.exists(path)) dlr_save(dlr_generate(unit,seeds),path)
    x <- readRDS(path); dlr_check(x,unit,seeds)
    base <- ab_index[ab_index$ParentId==unit$ParentId, ]; base$Bundle <- unit$Bundle
    base$BundleMD5 <- unname(tools::md5sum(path)); base$ABBundle <- unit$ABBundle
    base$ABBundleMD5 <- unit$ABBundleMD5; base$ControlConditionId <- base$ConditionId
    for(key in names(x$person_data)) {
      z <- base; z$CovariateView <- key; z$Rho <- x$population_truth[[key]]$rho
      z$ConditionId <- paste('DLR',key,z$ControlConditionId,sep=':')
      next_row <- next_row+1L; rows[[next_row]] <- z
    }
    if(i%%300L==0L) {cat('Prepared',i,'of',nrow(registry$units),'covariate bundles\n'); flush.console()}
  }
  inputs <- do.call(rbind,rows); rownames(inputs) <- NULL
  jobs <- do.call(rbind,lapply(seq_len(nrow(inputs)),function(i) {
    x <- inputs[i, ]; models <- dlr_models(x$Truth)
    data.frame(ConditionId=x$ConditionId,Replicate=x$Replicate,Model=models,
      Arm=paste0(models,'-MML-LR'),ControlConditionId=x$ControlConditionId,
      ControlArm=paste0(models,'-MML-free-population'),Status='allocated_not_fitted')
  }))
  stopifnot(nrow(inputs)==10800L,length(unique(inputs$ConditionId))==216L,
    all(table(inputs$ConditionId)==50L),!anyDuplicated(inputs[c('ConditionId','Replicate')]),
    nrow(jobs)==14400L,nrow(unique(jobs[c('ControlConditionId','Replicate','ControlArm')]))==7200L)
  write.csv(inputs,file.path(out,'inputs.csv'),row.names=FALSE)
  write.csv(jobs,file.path(out,'initial-jobs.csv'),row.names=FALSE)
  dlr_save(list(parent_cohorts=2100L,covariate_tables=4200L,condition_templates=216L,
    condition_records=10800L,initial_fit_slots=14400L,shared_control_slots=7200L,
    new_response_rows=0L,fit_calls=0L,replicates_per_condition=50L,
    registry_md5=tools::md5sum(registry_path),inputs_md5=tools::md5sum(file.path(out,'inputs.csv')),
    jobs_md5=tools::md5sum(file.path(out,'initial-jobs.csv')),
    completed=Sys.time(),session=capture.output(sessionInfo())),file.path(out,'verified-inputs.rds'))
  cat('D-LR complete: 10800 covariate views, 14400 allocated fits, no fitting.\n')
}

if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE); stopifnot(length(args)==1L)
  dlr_prepare(args[1L])
}
