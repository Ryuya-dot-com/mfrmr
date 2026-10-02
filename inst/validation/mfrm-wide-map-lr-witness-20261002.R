# Eight prespecified initial calls, not the full D-LR study or interval review.
# Rscript THIS_FILE OUTPUT_DIRECTORY; completed fits replay without estimation.
pkgload::load_all('.',quiet=TRUE,compile=FALSE)
source('inst/validation/mfrm-wide-map-mml-stages-20261001.R')
source('inst/validation/mfrm-wide-map-lr-inputs-20261002.R')
out <- commandArgs(trailingOnly=TRUE)[1L]; stopifnot(length(out)==1L,!is.na(out))
root <- file.path(dlr_root,'lr-inputs')
verified <- readRDS(file.path(root,'verified-inputs.rds'))
for(hash in verified[c('registry_md5','inputs_md5','jobs_md5')])
  stopifnot(identical(tools::md5sum(names(hash)),hash))
index <- read.csv(file.path(root,'inputs.csv'),stringsAsFactors=FALSE)
selected <- subset(index,Truth=='S-PCM' & SD==1 & View=='paired-L1' & Replicate==1 & N %in% c(20L,240L))
stopifnot(nrow(selected)==4L)
runtime <- wide_mml_runtime()
runtime$lr_sources <- tools::md5sum(c(dlr_script,'inst/validation/mfrm-wide-map-lr-witness-20261002.R'))
jobs <- list()
for(i in seq_len(nrow(selected))) for(model in c('PCM','GPCM')) {
  row <- selected[i, ]; args <- dlr_fit_input(row,root,model)
  # The formula carries no generator-frame environment into estimation.
  args$population_formula <- stats::as.formula('~ X',env=baseenv())
  args$quad_points <- 31L
  x <- readRDS(file.path(root,row$Bundle))
  id <- paste0('N',row$N,'-',row$CovariateView,'-',model)
  jobs[[id]] <- list(input=row,args=args,population_truth=x$population_truth[[row$CovariateView]])
}
dir.create(out,recursive=TRUE,showWarnings=FALSE)
manifest <- list(jobs=jobs,runtime=runtime,input_registry=verified$registry_md5,
  input_index=verified$inputs_md5,protocol=tools::md5sum('inst/validation/internal-roadmap-0.2.4.md'),
  rule='initial_q31_no_refit_no_interval',independent_parent_cohorts=2L)
path <- file.path(out,'manifest.rds')
if(file.exists(path)) {
  old <- readRDS(path)$payload
  # The archived protocol is immutable; later prose updates do not change jobs.
  manifest$protocol <- old$protocol
}
manifest <- wide_mml_phase(path,'DLR_initial_witness_v1',function() manifest)
stopifnot(identical(manifest$jobs,jobs),identical(manifest$runtime,runtime))
source_files <- c(names(runtime$source)[!startsWith(names(runtime$source),'loaded:')],
  names(runtime$lr_sources),'inst/validation/internal-roadmap-0.2.4.md')
for(file in unique(source_files)) {
  dest <- file.path(out,'source',file); dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
  if(!file.exists(dest)) stopifnot(file.copy(file,dest))
}
points <- statuses <- list(); replays <- 0L
for(id in names(jobs)) {
  job <- jobs[[id]]; dir <- file.path(out,id); dir.create(dir,showWarnings=FALSE)
  cat('Starting',id,'\n'); flush.console()
  fitting <- wide_mml_phase(file.path(dir,'fit.rds'),
    list(manifest=wide_mml_hash(manifest),job=id,phase='initial_fit'),
    function() wide_mml_capture(function() wide_mml_fit(job$args)))
  record <- wide_mml_phase(file.path(dir,'output.rds'),
    list(fitting=wide_mml_hash(fitting),job=id,phase='population_output'),function() {
      truth <- job$population_truth
      target <- c(truth$coefficients,log_residual_variance=log(truth$residual_variance))
      estimates <- setNames(rep(NA_real_,3L),names(target))
      population_summary <- convergence <- NULL
      if(!nzchar(fitting$error)) {
        fit <- fitting$value
        estimates[] <- c(fit$population$coefficients[names(truth$coefficients)],log(fit$population$sigma2))
        public <- summary(fit)
        population_summary <- public[c('population_coefficients','population_overview','population_coding','caveats')]
        convergence <- mfrmr:::mfrm_convergence_state(fit)
        stopifnot(is.data.frame(population_summary$population_coefficients),
          is.data.frame(population_summary$population_overview))
      }
      list(points=data.frame(Job=id,N=job$input$N,Rho=job$input$Rho,Model=job$args$model,
        Replicate=1L,Target=names(target),Truth=unname(target),Estimate=unname(estimates),
        Error=unname(estimates-target),Available=is.finite(estimates),
        SE=NA_real_,Lower=NA_real_,Upper=NA_real_,
        IntervalStatus='public_population_intervals_unavailable'),
        summary=population_summary,convergence=convergence)
    })
  if(!nzchar(fitting$error)) {
    public <- summary(unserialize(serialize(fitting$value,NULL,version=3)))
    stopifnot(identical(public[names(record$summary)],record$summary))
    replays <- replays+1L
  }
  points[[id]] <- record$points
  statuses[[id]] <- data.frame(Job=id,Returned=!nzchar(fitting$error),
    Seconds=fitting$elapsed,Warnings=paste(fitting$warnings,collapse='; '),Error=fitting$error,
    FinitePopulationTargets=sum(record$points$Available))
  cat('Completed',id,'seconds',fitting$elapsed,'finite targets',sum(record$points$Available),'\n'); flush.console()
}
result <- list(points=do.call(rbind,points),statuses=do.call(rbind,statuses),public_summary_replays=replays,
  independent_parent_cohorts=2L,source=runtime,
  interpretation='Eight initial calls on two existing parent cohorts; no bias/coverage claim, retry or public population interval.')
wide_mml_save(result,file.path(out,'verified.rds'))
write.csv(result$points,file.path(out,'population-points.csv'),row.names=FALSE)
write.csv(result$statuses,file.path(out,'fit-status.csv'),row.names=FALSE)
print(result$statuses,row.names=FALSE)
