# Independent RSM nonzero-effect confirmation. Repository-only; from package root:
# validation-R --slave -f THIS_FILE --args freeze | prepare | optimize | run 1 | run 2 | summarize
# Set the four numerical thread variables to 1. Freeze precedes generation;
# prepare has one writer, and each of the two run shards owns distinct jobs.
rsm_confirm_root <- 'validation-results/mfrm-lr-rsm-confirmation-20261009'
rsm_confirm_script <- 'inst/validation/mfrm-lr-rsm-confirmation-20261009.R'
rsm_confirm_helpers <- paste0('inst/validation/',c('mfrm-wide-map-ab-inputs-20261001.R',
  'mfrm-wide-map-mml-stages-20261001.R','mfrm-lr-rsm-boundary-20261009.R',
  'mfrm-lr-rsm-stages-20261009.R'))

rsm_confirm_protocol <- function() list(
  version='RSM-LR-nonzero-confirmation-v1',N=c(20L,240L),SD=1,Rho=.5,
  Replicates=800L,View='paired-L1',Shards=2L,inference=rsm_lr_rule(),
  primary=c('beta:(Intercept)','beta:X','contrast:mean_at_minus1',
    'contrast:mean_at_plus1','contrast:difference','log_residual_variance'),
  secondary=c('initial q61 intervals','scoring-source qualification',
    'bias','empirical SD','mean SE','width','all-attempt returned-and-covered frequency'),
  criteria=list(level=.95,coverage=c(.92,.98),availability=.95,availability_lower=.90),
  rationale=paste('Reuse the existing independent-inference practical margins, not a theorem about universal accuracy.',
    '800 attempts allow 760 returns at .95 delivery, coverage MCSE about .00791 at p=.95,',
    'and about .913 probability that a pointwise exact 95% MC interval lies inside [.92,.98].',
    'Worst-case availability MCSE is below .02. No new outcomes informed these choices.'),
  law=paste('Independent normal Persons; theta SD1; X=.5*theta+sqrt(.75)*Z with independent normal Z.',
    'True beta=(0,.5), residual variance=.75; three centered raters and criteria, shared RSM steps, scores 0:3.',
    'Each Person has six ratings: all criteria by an independently assigned balanced cyclic rater pair.',
    'Use the retained AB response generator and its checked adjacent-category equation.'),
  decisions=paste('Primary decisions concern selected intervals separately by target and N.',
    'Support requires availability>=.95, its exact 95% lower bound>=.90,',
    'and the exact 95% conditional-coverage interval wholly inside [.92,.98].',
    'Repair review if the coverage interval lies wholly outside that band or delivery upper bound<.95;',
    'otherwise inconclusive. Overcoverage is failure of the planned nominal-calibration criterion,',
    'not evidence of undercoverage. MC intervals are pointwise, not simultaneous across targets/cells.',
    'No automatic public-API promotion, new repetitions, redraws, method tuning or pooling with development data.'),
  scope=paste('Four-category, SD1, nonzero-effect, paired-L1 RSM only. Independent parents across N.',
    'N30/40/60/120/480, SD.5, rho0, full/L2 rosters, three categories and PCM keep their existing evidence/contracts.',
    'This bounded decision does not close unit 2 or all D1, nor evaluate new-Person probability calibration.'),
  stop='Complete all 1600 attempts and issue decisions once. Infrastructure interruptions resume compatible phases; no outcome-based early stopping.')

rsm_confirm_cp <- function(k,n) {
  stopifnot(length(k)==1L,length(n)==1L,is.finite(k),is.finite(n),
    k==as.integer(k),n==as.integer(n),0<=k,k<=n)
  if(n==0L) c(NA_real_,NA_real_) else unname(stats::binom.test(k,n)$conf.int)
}

rsm_confirm_decision <- function(attempted,returned,covered) {
  stopifnot(attempted>0L,returned<=attempted)
  a <- rsm_confirm_cp(returned,attempted);c <- rsm_confirm_cp(covered,returned)
  rule <- rsm_confirm_protocol()$criteria
  availability <- returned/attempted
  supported <- availability>=rule$availability && a[1]>=rule$availability_lower &&
    returned>0L && c[1]>=rule$coverage[1] && c[2]<=rule$coverage[2]
  adverse <- a[2]<rule$availability ||
    (returned>0L && (c[2]<rule$coverage[1] || c[1]>rule$coverage[2]))
  list(status=if(supported) 'supported' else if(adverse) 'repair_required' else 'inconclusive',
    availability=a,coverage=c,joint=rsm_confirm_cp(covered,attempted))
}

rsm_confirm_verify <- function(h) stopifnot(!anyNA(h),
  identical(unname(tools::md5sum(names(h))),unname(h)))
rsm_confirm_read <- function(path) {
  x <- readRDS(path);stopifnot(identical(x$checksum,wide_mml_hash(x$payload)));x
}
rsm_confirm_current <- function() {
  runtime <- wide_mml_runtime()
  stopifnot(all(runtime$threads=='1'))
  list(protocol=rsm_confirm_protocol(),runtime=runtime,source=tools::md5sum(unique(c(
    rsm_confirm_script,rsm_confirm_helpers,names(runtime$source)[names(runtime$source)!='loaded:mfrmr']))))
}
rsm_confirm_manifest <- function() {
  x <- rsm_confirm_read(file.path(rsm_confirm_root,'manifest.rds'))
  now <- rsm_confirm_current()
  stopifnot(identical(x$binding,now$protocol$version))
  path <- file.path(rsm_confirm_root,'execution.rds')
  if(file.exists(path)) {
    execution <- rsm_confirm_read(path)$payload
    rsm_confirm_verify(execution$parent);rsm_confirm_verify(execution$inputs)
    rsm_confirm_verify(execution$evidence)
    stopifnot(identical(execution$current,now),identical(x$payload$protocol,now$protocol))
  } else stopifnot(identical(x$payload[names(now)],now))
  rsm_confirm_verify(x$payload$template_file);rsm_confirm_verify(x$payload$evidence);x$payload
}

# Bind a computational continuation to the original contract and prepared inputs.
rsm_confirm_optimize <- function() {
  manifest_path <- file.path(rsm_confirm_root,'manifest.rds')
  old <- rsm_confirm_read(manifest_path)$payload;now <- rsm_confirm_current()
  inputs_path <- file.path(rsm_confirm_root,'inputs.rds')
  inputs <- rsm_confirm_read(inputs_path)
  stopifnot(identical(inputs$binding,wide_mml_hash(old)),identical(old$protocol,now$protocol),
    identical(old$runtime[-1L],now$runtime[-1L]),identical(names(old$source),names(now$source)),
    identical(old$runtime$source['loaded:mfrmr'],now$runtime$source['loaded:mfrmr']))
  changed <- names(old$source)[old$source!=now$source]
  stopifnot(setequal(changed,c(rsm_confirm_script,'inst/validation/mfrm-lr-rsm-stages-20261009.R',
    'R/api-prediction.R','R/api-population-intervals.R','R/core-native-location-inference.R')))
  archived <- old$source;names(archived) <- file.path(rsm_confirm_root,'source',names(archived))
  rsm_confirm_verify(archived)
  rsm_confirm_verify(inputs$payload$registry);rsm_confirm_verify(inputs$payload$bundles)
  evidence_path <- file.path(rsm_confirm_root,'efficiency','evidence.rds')
  evidence <- rsm_confirm_read(evidence_path)$payload
  rsm_confirm_verify(evidence$inputs);rsm_confirm_verify(evidence$script)
  numerical <- setdiff(names(now$source),rsm_confirm_script)
  stopifnot(identical(evidence$current[c('protocol','runtime')],now[c('protocol','runtime')]),
    identical(evidence$current$source[numerical],now$source[numerical]),isTRUE(evidence$equivalent),
    identical(evidence$new_fits,0L),identical(evidence$new_random_samples,0L))
  path <- file.path(rsm_confirm_root,'execution.rds')
  if(!file.exists(path)) stopifnot(!length(list.files(file.path(rsm_confirm_root,'jobs'),
    '[.]rds$',recursive=TRUE)))
  execution <- list(current=now,parent=tools::md5sum(manifest_path),
    inputs=tools::md5sum(inputs_path),evidence=tools::md5sum(evidence_path),changed_sources=changed)
  for(src in names(now$source)) {
    dest <- file.path(rsm_confirm_root,'execution-source',src)
    dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
    if(!file.exists(dest)) stopifnot(file.copy(src,dest))
    stopifnot(unname(tools::md5sum(dest))==now$source[[src]])
  }
  saved <- wide_mml_phase(path,'RSM-LR-information-reuse-v1',function()execution)
  stopifnot(identical(saved,execution));rsm_confirm_manifest()
  cat('Execution continuation verified; original contract, 1600 inputs and RNG reservation retained.\n')
}

rsm_confirm_freeze <- function() {
  now <- rsm_confirm_current()
  path <- 'validation-results/mfrm-lr-rsm-boundary-20261009/manifest.rds'
  previous <- rsm_confirm_read(path)$payload
  template <- previous$jobs[['N20-rho0.5-four-category']]$args;template$quad_points <- NULL
  evidence <- tools::md5sum(c('validation-results/mfrm-lr-rsm-boundary-20261009/evidence.rds',
    'validation-results/mfrm-lr-rsm-selection-20261009/scoring-continuation/evidence.rds',
    'validation-results/mfrm-lr-pcm-current-inference-20261009/evidence.rds'))
  stopifnot(identical(unname(evidence),c('ddae4c9e67ab5ea77a87eca9fdbd2e88',
    '769dc91271c35676aa81b58701bc3e1b','6b4e3c24c16934dba3ac8b5ceb711473')))
  manifest <- c(now,list(template=template,template_file=tools::md5sum(path),evidence=evidence,
    cost=list(retained_seconds=c(N20=4.948,N240=12.788),
      single_process_base_hours=800*(4.948+12.788)/3600,
      two_process_planning_hours=c(2,4),storage_planning_GiB=c(1,2),
      basis=paste('One existing paired-L1/rho.5 fit at each N; fit, boundary, integration, interval and scoring stages.',
        'About four serial hours before I/O/retries/load. Two-process range is projected, not a deadline or stop rule.',
        'Retained per-job disk sizes 216/532 KiB imply about .57 GiB before new inputs, records, sources and retries.'))))
  rsm_lr_validate(list(ConditionId='planned',Arm='RSM-MML-LR',Replicate=1L,
    InputId='not-generated',purpose='independent_confirmation',args=template))
  dir.create(rsm_confirm_root,recursive=TRUE,showWarnings=FALSE)
  saved <- wide_mml_phase(file.path(rsm_confirm_root,'manifest.rds'),now$protocol$version,function()manifest)
  stopifnot(identical(saved,manifest))
  for(path in names(now$source)) {
    dest <- file.path(rsm_confirm_root,'source',path);dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
    if(!file.exists(dest)) stopifnot(file.copy(path,dest))
    stopifnot(unname(tools::md5sum(dest))==now$source[[path]])
  }
  cat('Contract frozen: 800 independent parents at each N20/N240. No streams reserved or data generated.\n')
}

rsm_confirm_prepare <- function() {
  manifest <- rsm_confirm_manifest();p <- manifest$protocol
  head_path <- 'validation-results/mfrm-wide-map-r50-20261001/rng-head.rds'
  registry_path <- file.path(rsm_confirm_root,'rng-registry.rds')
  if(!file.exists(registry_path)) {
    head <- readRDS(head_path);rsm_confirm_verify(head$registry_md5)
    previous <- readRDS(head$registry)
    stopifnot(head$next_unit_ordinal==8651L,previous$next_unit_ordinal==head$next_unit_ordinal)
    units <- expand.grid(Replicate=seq_len(p$Replicates),N=p$N)
    units$Truth <- 'S-RSM';units$SD <- p$SD
    units$ParentId <- paste0('CONF-RSM:N',units$N,':rho0.5:rep',sprintf('%03d',units$Replicate))
    stream <- previous$next_unused_unit_stream
    streams <- lapply(seq_len(nrow(units)),function(i) {
      component <- stream;seeds <- list()
      for(name in c('ability','assignment','response','covariate')) {
        seeds[[name]] <- component;component <- parallel::nextRNGSubStream(component)
      }
      stream <<- parallel::nextRNGStream(stream);seeds
    })
    registry <- list(epoch=p$version,manifest=wide_mml_hash(manifest),predecessor=head,
      predecessor_head_md5=tools::md5sum(head_path),units=units,streams=streams,
      first_unit_ordinal=head$next_unit_ordinal,next_unit_ordinal=head$next_unit_ordinal+nrow(units),
      next_unused_unit_stream=stream,RNG=c("L'Ecuyer-CMRG",'Inversion','Rejection'))
    rsm_confirm_verify(registry$predecessor_head_md5);wide_mml_save(registry,registry_path)
  }
  registry <- readRDS(registry_path)
  stopifnot(identical(registry$manifest,wide_mml_hash(manifest)))
  next_head <- list(registry=registry_path,registry_md5=tools::md5sum(registry_path),
    preceding_registry_md5=registry$predecessor$registry_md5,
    last_reserved_unit_ordinal=registry$next_unit_ordinal-1L,next_unit_ordinal=registry$next_unit_ordinal,
    epoch=registry$epoch,note='1600 independent RSM nonzero-effect confirmation parents reserved before generation.')
  head <- readRDS(head_path)
  if(identical(head,registry$predecessor)) wide_mml_save(next_head,head_path)
  else stopifnot(identical(head,next_head))
  RNGkind("L'Ecuyer-CMRG",normal.kind='Inversion',sample.kind='Rejection');ab_check_equation()
  dir.create(file.path(rsm_confirm_root,'bundles'),showWarnings=FALSE)
  paths <- character(nrow(registry$units))
  for(i in seq_along(paths)) {
    unit <- registry$units[i,];seeds <- registry$streams[[i]]
    path <- paths[i] <- file.path(rsm_confirm_root,'bundles',sprintf('parent-%04d.rds',i))
    if(!file.exists(path)) {
      ab <- ab_generate(unit,seeds);ab_check_bundle(ab,unit,seeds)
      assign('.Random.seed',seeds$covariate,.GlobalEnv);Z <- rnorm(unit$N)
      persons <- data.frame(Person=names(ab$theta),X=p$Rho*unname(ab$theta)/p$SD+sqrt(1-p$Rho^2)*Z)
      wide_mml_save(list(ab=ab,persons=persons,Z=Z),path)
    }
    x <- readRDS(path);ab_check_bundle(x$ab,unit,seeds)
    stopifnot(identical(x$persons$Person,names(x$ab$theta)),
      identical(x$persons$X,p$Rho*unname(x$ab$theta)/p$SD+sqrt(1-p$Rho^2)*x$Z))
  }
  inputs <- list(registry=tools::md5sum(registry_path),bundles=tools::md5sum(paths))
  # Replay one actual input from each N without creating another sampling unit.
  for(i in match(p$N,registry$units$N)) {
    saved <- readRDS(paths[i]);unit <- registry$units[i,];seeds <- registry$streams[[i]]
    regenerated <- ab_generate(unit,seeds)
    assign('.Random.seed',seeds$covariate,.GlobalEnv)
    stopifnot(identical(regenerated,saved$ab),identical(rnorm(unit$N),saved$Z))
  }
  saved <- wide_mml_phase(file.path(rsm_confirm_root,'inputs.rds'),wide_mml_hash(manifest),function()inputs)
  stopifnot(identical(saved,inputs));cat('All 1600 inputs frozen; no fits run.\n')
}

rsm_confirm_run <- function(shard) {
  manifest <- rsm_confirm_manifest();p <- manifest$protocol
  execution <- rsm_confirm_current()
  stopifnot(length(shard)==1L,!is.na(shard),shard %in% seq_len(p$Shards))
  inputs <- rsm_confirm_read(file.path(rsm_confirm_root,'inputs.rds'))
  stopifnot(identical(inputs$binding,wide_mml_hash(manifest)))
  rsm_confirm_verify(inputs$payload$registry);rsm_confirm_verify(inputs$payload$bundles)
  registry <- readRDS(names(inputs$payload$registry));paths <- names(inputs$payload$bundles)
  jobs <- seq(shard,length(paths),by=p$Shards)
  for(i in jobs) {
    x <- readRDS(paths[i]);unit <- registry$units[i,];args <- manifest$template
    args$data <- x$ab$views[[p$View]][c('Person','Rater','Criterion','Score')]
    args$person_data <- x$persons
    spec <- list(ConditionId=paste0('CONF-RSM:N',unit$N,':SD1:rho0.5:paired-L1'),
      Arm='RSM-MML-LR',Replicate=unit$Replicate,InputId=unname(inputs$payload$bundles[i]),
      args=args,purpose='independent_confirmation')
    out <- file.path(rsm_confirm_root,'jobs',sprintf('parent-%04d',i))
    selected <- rsm_lr_stages(spec,out)
    wide_mml_phase(file.path(out,'records.rds'),list(selected=wide_mml_hash(selected),
      input=inputs$payload$bundles[i],manifest=wide_mml_hash(manifest),
      execution=wide_mml_hash(execution)),function() {
        z <- rsm_lr_records(spec,selected,out)
        truth <- setNames(c(0,.5,-.5,.5,1,log(.75)),p$primary)
        z$Truth <- unname(truth[z$Target]);z$Error <- z$Estimate-z$Truth
        z$Covered <- ifelse(z$Output=='interval' & z$Available,z$Lower<=z$Truth & z$Truth<=z$Upper,NA)
        z$N <- unit$N;z$ParentId <- unit$ParentId
        stopifnot(nrow(z)==24L,!anyNA(z$Truth));z
      })
    rsm_confirm_verify(execution$source)
    cat('Shard',shard,'job',i,'complete\n');flush.console()
  }
}

rsm_confirm_summarize <- function() {
  manifest <- rsm_confirm_manifest();p <- manifest$protocol
  execution <- rsm_confirm_current()
  inputs <- rsm_confirm_read(file.path(rsm_confirm_root,'inputs.rds'))$payload
  rsm_confirm_verify(inputs$registry);rsm_confirm_verify(inputs$bundles)
  paths <- file.path(rsm_confirm_root,'jobs',sprintf('parent-%04d',seq_along(inputs$bundles)),'records.rds')
  stopifnot(length(paths)==1600L,all(file.exists(paths)))
  records <- do.call(rbind,lapply(seq_along(paths),function(i) {
    z <- rsm_confirm_read(paths[i]);selected <- rsm_confirm_read(file.path(dirname(paths[i]),'selected.rds'))
    stopifnot(identical(z$binding,list(selected=selected$checksum,input=inputs$bundles[i],
      manifest=wide_mml_hash(manifest),execution=wide_mml_hash(execution))))
    z$payload
  }))
  summary <- do.call(rbind,lapply(split(records,paste(records$N,records$Selection,records$Output,records$Target)),function(z) {
    stopifnot(nrow(z)==p$Replicates,!anyDuplicated(z$ParentId),!anyNA(z$Available))
    a <- z[z$Available,];n <- nrow(a);interval <- z$Output[1]=='interval'
    k <- if(interval)sum(a$Covered) else 0L
    decision <- rsm_confirm_decision(nrow(z),n,k)
    primary <- interval && z$Selection[1]=='selected'
    data.frame(N=z$N[1],Selection=z$Selection[1],Output=z$Output[1],Target=z$Target[1],
      Planned=nrow(z),Delivered=n,Covered=if(interval)k else NA_integer_,Availability=n/nrow(z),
      AvailabilityLower=decision$availability[1],AvailabilityUpper=decision$availability[2],
      ConditionalCoverage=if(interval && n)k/n else NA_real_,
      CoverageLower=if(interval)decision$coverage[1] else NA_real_,CoverageUpper=if(interval)decision$coverage[2] else NA_real_,
      ReturnedAndCovered=if(interval)k/nrow(z) else NA_real_,
      JointLower=if(interval)decision$joint[1] else NA_real_,JointUpper=if(interval)decision$joint[2] else NA_real_,
      Bias=if(n)mean(a$Error) else NA_real_,EmpiricalSD=if(n>1L)sd(a$Error) else NA_real_,
      MeanSE=if(interval && n)mean(a$SE) else NA_real_,MeanWidth=if(interval && n)mean(a$Upper-a$Lower) else NA_real_,
      Decision=if(primary)decision$status else 'descriptive')
  }))
  missing <- subset(records,Selection=='selected' & !Available)
  refusals <- if(nrow(missing)) aggregate(list(Count=rep(1L,nrow(missing))),
    missing[c('N','Output','Target','BoundaryStatus','Reason')],sum) else data.frame()
  result <- list(summary=summary,records=records,refusals=refusals,record_hashes=tools::md5sum(paths),
    manifest=tools::md5sum(file.path(rsm_confirm_root,'manifest.rds')),
    inputs=tools::md5sum(file.path(rsm_confirm_root,'inputs.rds')),source=manifest$source,session=sessionInfo())
  wide_mml_phase(file.path(rsm_confirm_root,'summary.rds'),wide_mml_hash(manifest),function()result)
  write.csv(summary,file.path(rsm_confirm_root,'summary.csv'),row.names=FALSE)
  print(subset(summary,Decision!='descriptive'),row.names=FALSE)
}

if(sys.nframe()==0L) {
  pkgload::load_all('.',quiet=TRUE,compile=FALSE)
  for(path in rsm_confirm_helpers) source(path)
  args <- commandArgs(TRUE);stopifnot(length(args)>=1L)
  switch(args[1],freeze=rsm_confirm_freeze(),prepare=rsm_confirm_prepare(),optimize=rsm_confirm_optimize(),
    run=rsm_confirm_run(as.integer(args[2])),summarize=rsm_confirm_summarize(),stop('Unknown phase'))
}
