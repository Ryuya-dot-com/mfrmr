# A complete condition is 50 parent datasets x eight arms, not 400 independent
# datasets. Read saved outputs only. Never fit, score, retry or replace a draw.
wide_pcm_condition_files <- function(root, condition) {
  m <- wide_f_read(file.path(root,'manifest.rds'))$payload
  jobs <- m$jobs[m$jobs$ConditionId==condition,]
  stopifnot(nrow(jobs)==400L,all(table(jobs$Arm)==50L),
    all(vapply(split(jobs$Replicate,jobs$Arm),function(x)setequal(x,1:50),TRUE)))
  paths <- file.path(root,jobs$JobId,'outputs.rds')
  list(manifest=m,jobs=jobs,paths=paths,complete=all(file.exists(paths)),
    finished=sum(file.exists(paths)),expected=length(paths))
}

wide_pcm_paired_scoring_summary <- function(contributions, expected=1:50) {
  group <- c('ConditionId','Rule','Panel','ArmA','PriorA','ArmB','PriorB')
  ids <- do.call(paste,c(contributions[group],sep='\r'))
  do.call(rbind,lapply(split(seq_len(nrow(contributions)),ids),function(i) {
    z <- contributions[i,];stopifnot(!anyDuplicated(z$Replicate))
    complete <- setequal(z$Replicate,expected)
    out <- z[1,group,drop=FALSE];out$Replicates <- nrow(z);out$Complete <- complete
    for (metric in c('AAvailable','BAvailable','Joint')) {
      a <- wide_f_ratio(z[[metric]],z$Planned);if(!complete)a[] <- NA_real_
      out[[paste0(metric,'Rate')]] <- a['value'];out[[paste0(metric,'MCSE')]] <- a['MCSE']
    }
    for (metric in c('ErrorDifference','SquaredErrorDifference')) {
      a <- wide_f_ratio(z[[paste0(metric,'Sum')]],z$Joint);if(!complete)a[] <- NA_real_
      out[[metric]] <- a['value'];out[[paste0(metric,'MCSE')]] <- a['MCSE']
    }
    out$Conditioning <- 'Error contrasts use joint returns; availability uses all planned Persons.'
    out
  }))
}

wide_pcm_candidate_variation <- function(plan,records) {
  z <- wide_output_records(plan,records)
  ids <- paste(z$ConditionId,z$Arm,z$Target,sep='\r')
  do.call(rbind,lapply(split(seq_len(nrow(z)),ids),function(i) {
    x <- z[i,];ok <- x$Available;v <- x$Estimate[ok]
    stopifnot(setequal(x$Replicate,1:50))
    data.frame(ConditionId=x$ConditionId[1],Arm=x$Arm[1],Target=x$Target[1],
      Replicates=nrow(x),CandidateReturned=sum(ok),
      EmpiricalSD=if(length(v)>1L)sd(v) else NA_real_,
      RootMeanEstimatedVariance=if(any(ok))sqrt(mean(x$SE[ok]^2)) else NA_real_,
      Conditioning='Candidate-delivered datasets only; not truth-centering or covariance qualification.')
  }))
}

wide_pcm_scoring_delivery <- function(records) {
  # Count batches once per parent dataset, retaining the reason for refusal.
  # Persons and different precision rules never add independent replications.
  keys <- c('ConditionId','Arm','Prior','Rule','Panel')
  ids <- do.call(paste,c(records[c(keys,'Replicate')],sep='\r'))
  batches <- do.call(rbind,lapply(split(seq_len(nrow(records)),ids),function(i) {
    z <- records[i,];stopifnot(!anyDuplicated(z$Person),length(unique(z$BatchStatus))==1L,
      length(unique(z$ScoringOrder))==1L)
    cbind(z[1,c(keys,'Replicate','BatchStatus','ScoringOrder')],
      data.frame(Planned=nrow(z),Scores=sum(z$ScoreAvailable),Intervals=sum(z$IntervalAvailable),
        Reason=paste(sort(unique(z$Reason[nzchar(z$Reason)])),collapse='; ')))
  }))
  group <- c(keys,'BatchStatus','ScoringOrder','Reason')
  ids <- do.call(paste,c(batches[group],sep='\r'))
  out <- do.call(rbind,lapply(split(seq_len(nrow(batches)),ids),function(i) {
    z <- batches[i,];stopifnot(!anyDuplicated(z$Replicate))
    cbind(z[1,group],data.frame(Datasets=nrow(z),PlannedPersons=sum(z$Planned),
      Scores=sum(z$Scores),Intervals=sum(z$Intervals)))
  }))
  rownames(out) <- NULL;out
}

wide_pcm_condition_summary <- function(root,condition,out) {
  source('inst/validation/mfrm-wide-map-pcm-r50-20261002.R');wide_pcm_setup()
  registry <- wide_pcm_condition_files(root,condition)
  if(!registry$complete) stop(sprintf('Condition incomplete: %d/%d complete output jobs. No performance summary produced.',
    registry$finished,registry$expected))
  # Bind aggregation to the saved numerical epoch, not unrelated current files.
  saved <- lapply(seq_along(registry$paths),function(i) {
    z <- wide_f_read(registry$paths[i]);j <- registry$jobs[i,,drop=FALSE]
    stopifnot(identical(z$binding$job,j),identical(z$payload$job,j),
      identical(z$binding$source,registry$manifest$source),isTRUE(z$payload$completed))
    z$payload
  })
  bind <- function(field,member=NULL)do.call(rbind,lapply(saved,function(x)
    if(is.null(member))x[[field]] else x[[field]][[member]]))
  p <- bind('initial','plan');r <- bind('initial','results')
  ip <- bind('intervals','plan');ir <- bind('intervals','records')
  cp <- bind('candidate','plan');cr <- bind('candidate','records')
  native <- bind('native');scoring <- bind('scoring')
  arms <- unique(registry$jobs$Arm);pairs <- combn(arms,2,simplify=FALSE)
  paired_initial <- lapply(pairs,function(a)wide_recovery_paired(p,r,a[1],a[2]))
  paired_selected <- lapply(pairs,function(a) {
    targets <- intersect(ip$Target[ip$Arm==a[1] & ip$Output=='point' & ip$Eligibility=='eligible'],
      ip$Target[ip$Arm==a[2] & ip$Output=='point' & ip$Eligibility=='eligible'])
    wide_paired_point_summary(ip[ip$Target %in% targets,],ir[ir$Target %in% targets,],a[1],a[2])
  })
  scoring_pairs <- list()
  for (a in pairs) for(prior in c('reference','retained'))
    scoring_pairs[[paste(a[1],a[2],prior)]] <- wide_f_paired(scoring,a[1],prior,a[2],prior)
  for(a in arms)scoring_pairs[[paste(a,'prior')]] <- wide_f_paired(scoring,a,'reference',a,'retained')
  tables <- list(initial=wide_recovery_summary(p,r),
    probability=wide_recovery_grid_summary(wide_recovery_grid_losses(p,r)),
    source_reviewed=wide_output_summary(ip,ir),
    research_candidate=wide_output_summary(cp,cr),
    candidate_variation=wide_pcm_candidate_variation(cp,cr),
    native=wide_training_summary(native),
    scoring=wide_f_summary(wide_f_contributions(scoring)),
    scoring_delivery=wide_pcm_scoring_delivery(scoring),
    paired_initial=do.call(rbind,lapply(paired_initial,`[[`,'points')),
    paired_probability=do.call(rbind,lapply(paired_initial,`[[`,'grid')),
    paired_source_reviewed=do.call(rbind,paired_selected),
    paired_scoring=wide_pcm_paired_scoring_summary(do.call(rbind,scoring_pairs)))
  stopifnot(all(vapply(tables,function(x)!'Complete' %in% names(x)||all(x$Complete),TRUE)))
  scripts <- paste0('inst/validation/mfrm-wide-map-',c('pcm-summary-20261003',
    'output-summary-20261001','recovery-20261002','f-scoring-20261002'),'.R')
  binding <- list(condition=condition,outputs=tools::md5sum(registry$paths),
    numerical_manifest=tools::md5sum(file.path(root,'manifest.rds')),summary_source=tools::md5sum(scripts))
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  result <- wide_mml_phase(file.path(out,'summary.rds'),binding,function()
    list(tables=tables,jobs=registry$jobs,independent_replicates=50L,
      note='Descriptive mapping; research JML intervals and conditional score intervals are not qualified structural truth inference.'))
  stopifnot(identical(result$tables,tables))
  for(n in names(tables))write.csv(tables[[n]],file.path(out,paste0(n,'.csv')),row.names=FALSE)
  invisible(result)
}

if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args)==3L)
  wide_pcm_condition_summary(args[1],args[2],args[3])
  # Separate research extension: ordinary-JML intervals and roster-normalization
  # sensitivity, using original fits. The original summary remains reproducible.
  source('inst/validation/jml-basic-inference-comparison-20261003.R')
  jml_basic_setup()
  jml_basic_condition(args[1],args[2],file.path(args[3],'jml-inference'))
  source('inst/validation/mfrm-wide-map-pcm-report-20261003.R')
  wide_pcm_report(args[3])
}
