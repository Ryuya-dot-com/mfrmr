base <- normalizePath('.')
args <- commandArgs(TRUE)
stopifnot(length(args)==1L, args %in% c('old','new'))
epoch <- args[1]
ab <- file.path(base,'validation-results/mfrm-wide-map-pcm-r50-portable-20261003')
src <- if(epoch=='old') file.path(ab,'summary-n240/source') else file.path(ab,'transition-reuse-l2-20261007/source')
manifest <- if(epoch=='old') file.path(ab,'manifest.rds') else file.path(ab,'transition-reuse-l2-20261007/manifest.rds')
setwd(src)
source('inst/validation/mfrm-wide-map-pcm-r50-20261002.R')
wide_pcm_setup()
source(file.path(base,'inst/validation/mfrm-wide-map-resume-20261004.R'))
m <- wide_f_read(manifest)$payload
stopifnot(identical(m$source,tools::md5sum(names(m$source))),
 identical(m$input,tools::md5sum(names(m$input))),identical(m$template,tools::md5sum(names(m$template))))
actual <- wide_multi_runtime()
checks <- identical(wide_pcm_runtime_key(actual,m$runtime),m$runtime)
if (!checks) print(all.equal(wide_pcm_runtime_key(actual,m$runtime),m$runtime))
stopifnot(checks)
wide_pcm_resume_checks()
# Reuse one completed immutable phase with numerical evaluation forbidden.
id <- m$jobs$JobId[file.exists(file.path(dirname(manifest),m$jobs$JobId,'outputs.rds'))][1L]
stopifnot(!is.na(id))
p <- file.path(dirname(manifest),id,'outputs.rds'); old <- readRDS(p)
stopifnot(identical(wide_mml_phase(p,old$binding,function()stop('Numerical execution forbidden')),old$payload))
record <- list(Epoch=epoch,RuntimeMatched=checks,Runtime=actual,RNGkind=RNGkind(),
 Source=normalizePath('.'),Manifest=tools::md5sum(manifest),
 Libraries=tools::md5sum(c(file.path(R.home('lib'),'libR.dylib'),unname(actual$libraries['BLAS']),getLoadedDLLs()[['mfrmr']][['path']])),
 ReadOnlyReplay=tools::md5sum(p),NumericalPhasesExecuted=0L)
saveRDS(record,file.path(base,'validation-results/development-restart-20261009',paste0('runtime-preflight-',epoch,'.rds')))
cat('PASS:',epoch,'source, runtime, source DLL, dependencies, threads, inputs and completed-phase replay\n')
