# Numerical qualification of the existing E Task conditions, using original
# saved calibration and F-pop data. All six declared arms remain in the plan.
wide_task_qualification <- function(mode) {
  root <- 'validation-results/mfrm-wide-map-facet-output-bridge-20261006'
  stopifnot(mode %in% c('prepare','run'),
    identical(normalizePath('.'),normalizePath(file.path(root,'source'))))
  pkgload::load_all('.',quiet=TRUE,compile=FALSE,helpers=FALSE)
  helpers <- paste0('inst/validation/mfrm-wide-map-',c('mml-stages-20261001',
    'jml-stages-20261001','output-summary-20261001','multi-output-20261001',
    'recovery-20261002','interval-recovery-20261002','f-scoring-20261002',
    'e-output-20261006','e-jml-candidate-20261006','e-run-20261006',
    'e-gpcm-run-20261006','facet-outputs-20261006'),'.R')
  for(f in helpers)sys.source(f,envir=globalenv())
  script <- sub('^--file=','',grep('^--file=',commandArgs(),value=TRUE))
  sources <- tools::md5sum(c(helpers,script))
  proof_path <- file.path(root,'check.rds'); proof <- readRDS(proof_path)
  stopifnot(isTRUE(proof$ChecksPassed),identical(proof$Runtime,wide_multi_runtime()),
    identical(tools::md5sum(names(proof$Sources)),proof$Sources),
    identical(tools::md5sum(names(proof$Inputs)),proof$Inputs),!anyNA(sources))
  out <- file.path(root,'numerical'); path <- file.path(out,'dispatch.rds')
  if(mode=='prepare') {
    stopifnot(!dir.exists(out));dir.create(out)
    jobs <- list(); inputs <- list()
    conditions <- paste0('E:E9-rho',c('0','0.5'),':N20:SD1:S-PCM')
    future <- 'validation-results/mfrm-wide-map-e-output-bridge-20261006/future-parent-2.rds'
    for(condition in conditions)inputs[[condition]] <- wide_e_input(condition,1L)
    # Freeze all jobs before any result. Ordinary arms first expose scoring
    # integration issues while the more expensive corrected roots stay planned.
    for(corrected in c(FALSE,TRUE))for(input in inputs) {
      specs <- wide_e_specs(input)
      for(spec in specs)if(identical(!is.null(spec$args$jml_correction_order),corrected)) {
        wide_e_future_panel(input,wide_f_read(future)$payload)
        jobs[[length(jobs)+1L]] <- list(input=input,spec=spec,future=future)
      }
    }
    stopifnot(length(jobs)==12L)
    d <- list(jobs=jobs,runtime=wide_multi_runtime(),sources=sources,
      qualification=tools::md5sum(proof_path),
      inputs=tools::md5sum(unique(c(future,unlist(lapply(inputs,function(x)names(x$provenance$bundle)))))),
      scope='Twelve Task numerical output jobs on two existing paired mechanisms of one N20 PCM parent. All six arms retained; not independent replications, coverage qualification, or the full Task study.')
    wide_mml_save(d,path)
    cat('Prepared twelve Task jobs; no fitting or data generation.\n')
    return(invisible(NULL))
  }
  d <- readRDS(path)
  stopifnot(identical(d$runtime,wide_multi_runtime()),identical(d$sources,sources))
  for(h in list(d$inputs,d$qualification))stopifnot(identical(tools::md5sum(names(h)),h))
  lock <- file.path(out,'RUNNING');stopifnot(dir.create(lock,showWarnings=FALSE))
  on.exit(unlink(lock,recursive=TRUE),add=TRUE)
  writeLines(as.character(Sys.getpid()),file.path(lock,'pid'))
  for(i in seq_along(d$jobs)) {
    j <- d$jobs[[i]]; runner <- if(j$spec$args$model=='GPCM')wide_e_gpcm_job else wide_e_job
    runner(j$input,j$spec,j$future,file.path(out,sprintf('job-%03d',i)),d$runtime,d$sources)
  }
  invisible(NULL)
}
if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args)==1L)
  wide_task_qualification(args)
}
