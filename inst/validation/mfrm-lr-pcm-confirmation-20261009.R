# Targeted independent follow-up of the N40/SD.5/rho0 development anomaly.
# Usage from package root: scripts/validation-R --slave -f THIS_FILE --args
# prepare | run full-L1 | run paired-L1 | summarize
# No early stopping, outcome-based redraw, or replacement of development fits.
out <- 'validation-results/mfrm-lr-pcm-confirmation-20261009'
script <- 'inst/validation/mfrm-lr-pcm-confirmation-20261009.R'
pkgload::load_all('.',quiet=TRUE,compile=FALSE)
sources <- c('inst/validation/mfrm-wide-map-ab-inputs-20261001.R',
  'inst/validation/mfrm-wide-map-mml-stages-20261001.R',
  'inst/validation/mfrm-wide-map-lr-pcm-boundary-20261002.R',
  'inst/validation/mfrm-wide-map-lr-pcm-stages-20261004.R')
for (path in sources) source(path)
sealed <- function(path) {
  x <- readRDS(path)
  stopifnot(identical(x$checksum,wide_mml_hash(x$payload)))
  x$payload
}
verify <- function(hashes) stopifnot(!anyNA(hashes),
  identical(unname(tools::md5sum(names(hashes))),unname(hashes)))
protocol <- list(N=40L,SD=.5,Rho=0,Replicates=200L,
  Views=c('full-L1','paired-L1'),PrimaryTarget='beta:X',
  inference=dlr_pcm_rule(),
  purpose=paste('Independent targeted confirmation, not broad method qualification.',
    'Assess whether the N40/SD.5/rho0 beta:X development undercoverage recurs.',
    'Two exposure views share each parent and are not independent replications.'),
  analysis=paste('Report availability, returned-and-covered and coverage among returns,',
    'each with pointwise exact 95% Monte Carlo intervals; bias, SE/empirical SD and width.',
    'Retain all seven original targets as secondary descriptive results.',
    'No pooled development/confirmation estimate, optional stopping, threshold tuning or method selection.',
    'At 95% coverage, 200 independent parents give Monte Carlo SE about .0154.',
    'Existing N20/30/60/120/240/480 records remain separate development controls.'))
runtime <- wide_mml_runtime()
source_hashes <- tools::md5sum(unique(c(script,sources,
  names(runtime$source)[!startsWith(names(runtime$source),'loaded:')])))
manifest_path <- file.path(out,'manifest.rds')
registry_path <- file.path(out,'rng-registry.rds')

prepare <- function() {
  head_path <- 'validation-results/mfrm-wide-map-r50-20261001/rng-head.rds'
  dir.create(file.path(out,'bundles'),recursive=TRUE,showWarnings=FALSE)
  if (!file.exists(registry_path)) {
    head <- readRDS(head_path); verify(head$registry_md5)
    previous <- readRDS(head$registry)
    stopifnot(head$next_unit_ordinal==8451L,
      previous$next_unit_ordinal==head$next_unit_ordinal)
    stream <- previous$next_unused_unit_stream
    streams <- lapply(seq_len(protocol$Replicates),function(i) {
      component <- stream; seeds <- list()
      for (name in c('ability','assignment','response','covariate')) {
        seeds[[name]] <- component; component <- parallel::nextRNGSubStream(component)
      }
      stream <<- parallel::nextRNGStream(stream)
      seeds
    })
    registry <- list(epoch='confirmation-DLR-N40-20261009-v1',phase='targeted_confirmation',
      protocol=protocol,predecessor=head,predecessor_head_md5=tools::md5sum(head_path),
      first_unit_ordinal=head$next_unit_ordinal,
      next_unit_ordinal=head$next_unit_ordinal+protocol$Replicates,
      streams=streams,next_unused_unit_stream=stream,source=source_hashes,
      RNG=c("L'Ecuyer-CMRG",'Inversion','Rejection'))
    verify(registry$predecessor_head_md5)
    wide_mml_save(registry,registry_path)
  }
  registry <- readRDS(registry_path)
  stopifnot(identical(registry$protocol,protocol),identical(registry$source,source_hashes))
  head <- readRDS(head_path)
  new_head <- list(registry=registry_path,registry_md5=tools::md5sum(registry_path),
    preceding_registry_md5=registry$predecessor$registry_md5,
    last_reserved_unit_ordinal=registry$next_unit_ordinal-1L,
    next_unit_ordinal=registry$next_unit_ordinal,epoch=registry$epoch,
    note='200 independent N40 PCM latent-regression confirmation parents reserved before generation.')
  if (identical(head,registry$predecessor)) wide_mml_save(new_head,head_path)
  else stopifnot(identical(head,new_head))
  base_path <- paste0('validation-results/mfrm-wide-map-lr-pcm-r50-20261004/jobs/',
    'DLR_rho0_AB_full_L1_N40_SD0_5_S_PCM-1/manifest.rds')
  template <- sealed(base_path)$spec$args
  manifest <- list(protocol=protocol,runtime=runtime,source=source_hashes,
    registry=tools::md5sum(registry_path),template=template,template_file=tools::md5sum(base_path))
  saved <- wide_mml_phase(manifest_path,registry$epoch,function() manifest)
  stopifnot(identical(saved,manifest))
  for (path in names(source_hashes)) {
    target <- file.path(out,'source',path)
    dir.create(dirname(target),recursive=TRUE,showWarnings=FALSE)
    if (!file.exists(target)) stopifnot(file.copy(path,target))
    stopifnot(unname(tools::md5sum(target))==source_hashes[[path]])
  }
  RNGkind("L'Ecuyer-CMRG",normal.kind='Inversion',sample.kind='Rejection')
  ab_check_equation()
  paths <- character(protocol$Replicates)
  for (i in seq_len(protocol$Replicates)) {
    unit <- data.frame(Replicate=i,Truth='S-PCM',SD=protocol$SD,N=protocol$N,
      ParentId=sprintf('CONF-DLR:N40:SD0.5:rho0:rep%03d',i))
    path <- paths[i] <- file.path(out,'bundles',sprintf('parent-%03d.rds',i))
    if (!file.exists(path)) {
      ab <- ab_generate(unit,registry$streams[[i]])
      ab_check_bundle(ab,unit,registry$streams[[i]])
      assign('.Random.seed',registry$streams[[i]]$covariate,.GlobalEnv)
      persons <- data.frame(Person=names(ab$theta),X=rnorm(protocol$N))
      wide_mml_save(list(ab=ab,persons=persons),path)
    }
    x <- readRDS(path); ab_check_bundle(x$ab,unit,registry$streams[[i]])
    stopifnot(identical(x$persons$Person,names(x$ab$theta)),all(is.finite(x$persons$X)))
  }
  input_index <- tools::md5sum(paths)
  saved <- wide_mml_phase(file.path(out,'inputs.rds'),wide_mml_hash(manifest),function()input_index)
  stopifnot(identical(saved,input_index))
  cat('Frozen 200 independent parents, 400 paired-view jobs, no outcomes selected.\n')
}

run <- function(view) {
  stopifnot(length(view)==1L,view %in% protocol$Views)
  manifest <- sealed(manifest_path)
  stopifnot(identical(manifest$protocol,protocol),identical(manifest$runtime,runtime),
    identical(manifest$source,source_hashes))
  verify(manifest$registry); verify(manifest$template_file)
  inputs <- sealed(file.path(out,'inputs.rds')); verify(inputs)
  for (i in seq_len(protocol$Replicates)) {
    bundle <- readRDS(names(inputs)[i]); args <- manifest$template
    args$data <- bundle$ab$views[[view]][c('Person','Rater','Criterion','Score')]
    args$person_data <- bundle$persons
    spec <- list(ConditionId=paste0('CONF:rho0:AB:',view,':N40:SD0.5:S-PCM'),
      Arm='PCM-MML-LR',Replicate=i,
      InputId=wide_mml_hash(list(data=args$data,persons=args$person_data)),args=args,
      provenance=inputs[i],purpose=protocol$purpose)
    job <- file.path(out,'jobs',paste0(view,'-',sprintf('%03d',i)))
    selected <- dlr_pcm_stages(spec,job)
    wide_mml_phase(file.path(job,'records.rds'),
      list(selected=wide_mml_hash(selected),inputs=spec$provenance),function() {
        z <- dlr_pcm_records(spec,selected,job)
        truth <- c(bundle$ab$truth$Criterion,diff(bundle$ab$truth$Criterion[2:1]),
          0,0,log(protocol$SD^2))
        names(truth) <- unique(z$Target)
        z$Truth <- unname(truth[z$Target]); z$Error <- z$Estimate-z$Truth
        z$Covered <- ifelse(z$Output=='interval' & z$Available,
          z$Lower<=z$Truth & z$Truth<=z$Upper,NA)
        z$N <- protocol$N; z$SD <- protocol$SD; z$Rho <- protocol$Rho; z$View <- view
        z$ParentId <- bundle$ab$unit$ParentId
        stopifnot(nrow(z)==28L,!anyNA(z$Truth)); z
      })
    verify(source_hashes)
    cat(view,i,'/',protocol$Replicates,'complete\n'); flush.console()
  }
}

summarize <- function() {
  manifest <- sealed(manifest_path); verify(manifest$source)
  paths <- unlist(lapply(protocol$Views,function(view)file.path(out,'jobs',
    paste0(view,'-',sprintf('%03d',seq_len(protocol$Replicates))),'records.rds')))
  stopifnot(all(file.exists(paths)))
  records <- do.call(rbind,lapply(paths,sealed))
  cp <- function(k,n) if(n)unname(binom.test(k,n)$conf.int)else c(NA_real_,NA_real_)
  summary <- do.call(rbind,lapply(split(records,paste(records$View,records$Rule,
    records$Output,records$Target)),function(z) {
    stopifnot(nrow(z)==protocol$Replicates,!anyDuplicated(z$ParentId),!anyNA(z$Available))
    a <- z[z$Available,]; n <- nrow(a); interval <- z$Output[1]=='interval'
    k <- if(interval)sum(z$Covered %in% TRUE)else NA_integer_
    availability <- cp(n,nrow(z)); coverage <- if(interval)cp(k,n)else c(NA,NA)
    joint <- if(interval)cp(k,nrow(z))else c(NA,NA)
    data.frame(View=z$View[1],Rule=z$Rule[1],Output=z$Output[1],Target=z$Target[1],
      Planned=nrow(z),Delivered=n,Covered=k,Availability=n/nrow(z),
      AvailabilityLower=availability[1],AvailabilityUpper=availability[2],
      ReturnedAndCovered=k/nrow(z),ReturnedAndCoveredLower=joint[1],ReturnedAndCoveredUpper=joint[2],
      ConditionalCoverage=k/n,ConditionalCoverageLower=coverage[1],ConditionalCoverageUpper=coverage[2],
      Bias=mean(a$Error),EmpiricalSD=sd(a$Error),MeanSE=if(interval)mean(a$SE)else NA_real_,
      MeanWidth=if(interval)mean(a$Upper-a$Lower)else NA_real_)
  }))
  result <- list(summary=summary,records=records,record_hashes=tools::md5sum(paths),
    manifest=tools::md5sum(manifest_path),inputs=tools::md5sum(file.path(out,'inputs.rds')),
    source=source_hashes,session=sessionInfo())
  saved <- wide_mml_phase(file.path(out,'summary.rds'),wide_mml_hash(manifest),function()result)
  stopifnot(identical(saved,result))
  write.csv(summary,file.path(out,'summary.csv'),row.names=FALSE)
  print(subset(summary,Rule=='refinement' & Output=='interval' & Target=='beta:X'),row.names=FALSE)
}
args <- commandArgs(TRUE); stopifnot(length(args)>=1L)
switch(args[1],prepare=prepare(),run=run(args[2]),summarize=summarize(),stop('Unknown phase'))
