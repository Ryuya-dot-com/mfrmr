# Calibration/interval unit of the already allocated Gaussian D-LR study.
# Rscript THIS_FILE OUTPUT_DIRECTORY CONDITION_ID [REPLICATE ...]
# All 50 inputs remain allocated. Future scoring and other models are separate
# consumers, not implicitly counted as completed by these calibration records.
dlr_pcm_args <- function(row,root) {
  args <- dlr_fit_input(row,root,'PCM')
  args$population_formula <- stats::as.formula('~X',env=baseenv())
  args$reltol <- dlr_pcm_rule()$reltol
  if(identical(row$View,'paired-L2')) {
    events <- readRDS(row$ABBundle)$views[[row$View]]
    stopifnot('Event' %in% names(events),setequal(events$Event,1:2),
      !anyDuplicated(events[c('Person','Rater','Criterion','Event')]),
      all(table(events$Person)==12L),identical(args$data,events[names(args$data)]))
    args$data <- events[c('Person','Rater','Criterion','Score','Event')]
    args$repeated_ratings <- 'independent'
  }
  args
}

dlr_pcm_batch <- function(out,condition,replicates=1:50) {
  pkgload::load_all('.',quiet=TRUE,compile=FALSE)
  scripts <- paste0('inst/validation/mfrm-wide-map-',c('mml-stages-20261001',
    'lr-inputs-20261002','lr-pcm-boundary-20261002','lr-pcm-stages-20261004',
    'lr-pcm-r50-20261004'),'.R')
  for(script in head(scripts,-1L)) source(script)
  root <- file.path(dlr_root,'lr-inputs')
  verified <- readRDS(file.path(root,'verified-inputs.rds'))
  for(hash in verified[c('registry_md5','inputs_md5','jobs_md5')])
    stopifnot(identical(tools::md5sum(names(hash)),hash))
  index <- read.csv(file.path(root,'inputs.csv'),stringsAsFactors=FALSE)
  jobs <- index[index$Truth=='S-PCM',];rownames(jobs) <- NULL
  stopifnot(all(table(jobs$ConditionId)==50L),!anyDuplicated(jobs[c('ConditionId','Replicate')]),
    length(condition)==1L,condition %in% jobs$ConditionId,
    length(replicates)>0L,!anyDuplicated(replicates),all(replicates %in% 1:50))
  runtime <- wide_mml_runtime()
  sources <- tools::md5sum(unique(c(scripts,names(runtime$source)[!startsWith(names(runtime$source),'loaded:')])))
  manifest <- list(jobs=jobs,rule=dlr_pcm_rule(),runtime=runtime,source=sources,
    input_registry=verified$registry_md5,input_index=verified$inputs_md5,
    purpose='Development R50 PCM regression calibration/intervals; independent confirmation remains separate.',
    historical_fits='Four prior coherent fits remain development evidence; this freezes the complete q31 onward selection procedure against its current source.',
    outputs='Criterion locations and 1-minus-2 contrast, population coefficients and log residual variance; default and refinement denominators retained.')
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  saved <- wide_mml_phase(file.path(out,'manifest.rds'),'DLR-PCM-calibration-R50-v1',function()manifest)
  stopifnot(identical(saved,manifest))
  for(path in names(sources)) {
    target <- file.path(out,'source',path);dir.create(dirname(target),recursive=TRUE,showWarnings=FALSE)
    if(!file.exists(target)) stopifnot(file.copy(path,target))
    stopifnot(identical(unname(tools::md5sum(path)),unname(tools::md5sum(target))))
  }
  rows <- jobs[jobs$ConditionId==condition & jobs$Replicate %in% replicates,]
  rows <- rows[order(rows$Replicate),]
  for(i in seq_len(nrow(rows))) {
    row <- rows[i,];id <- paste0(gsub('[^a-zA-Z0-9]','_',condition),'-',row$Replicate)
    args <- dlr_pcm_args(row,root)
    spec <- list(ConditionId=row$ConditionId,Arm='PCM-MML-LR',Replicate=row$Replicate,
      InputId=wide_mml_hash(list(data=args$data,persons=args$person_data)),args=args,
      provenance=c(lr=row$BundleMD5,ab=row$ABBundleMD5),purpose=manifest$purpose)
    dir <- file.path(out,'jobs',id);cat('Starting',id,'\n');flush.console()
    selected <- dlr_pcm_stages(spec,dir)
    # Truth is joined only after the algorithm has selected its outputs.
    record <- wide_mml_phase(file.path(dir,'records.rds'),
      list(selected=wide_mml_hash(selected),inputs=spec$provenance),function() {
        z <- dlr_pcm_records(spec,selected,dir)
        lr <- readRDS(file.path(root,row$Bundle));ab <- readRDS(row$ABBundle)
        pop <- lr$population_truth[[row$CovariateView]]
        truth <- c(ab$truth$Criterion,ab$truth$Criterion[1]-ab$truth$Criterion[2],
          pop$coefficients,log(pop$residual_variance))
        names(truth) <- unique(z$Target)
        z$Truth <- unname(truth[z$Target]);z$Error <- z$Estimate-z$Truth
        z$Covered <- ifelse(z$Output=='interval' & z$Available,
          z$Lower<=z$Truth & z$Truth<=z$Upper,NA)
        z$N <- row$N;z$SD <- row$SD;z$Rho <- row$Rho;z$View <- row$View
        z$DevelopmentWitness <- row$Replicate==1L && row$N %in% c(20L,240L) &&
          row$SD==1 && row$View=='paired-L1'
        stopifnot(nrow(z)==28L,!anyNA(z$Truth));z
      })
    write.csv(record,file.path(dir,'records.csv'),row.names=FALSE)
    stopifnot(identical(sources,tools::md5sum(names(sources))))
    cat('Completed',id,'refined available',sum(record$Available[record$Rule=='refinement']),
      'of 14 outputs; point q',selected$point$order,'interval q',selected$interval$order,'\n')
    flush.console()
  }
  invisible(TRUE)
}

if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args)>=2L)
  dlr_pcm_batch(args[1L],args[2L],if(length(args)>2L)as.integer(args[-(1:2)]) else 1:50)
}
