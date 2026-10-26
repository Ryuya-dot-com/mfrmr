# Resolve the retained fixed-point check's finite-difference instability.
# Reuse its probability map and unchanged acceptance tolerances. No refits.
prior_root <- 'validation-results/mirt-gpcm-two-family-fixed-point-20261006'
prior_manifest <- readRDS(file.path(prior_root,'manifest.rds'))
prior <- prior_manifest$payload
original <- file.path(prior_root,'mirt-gpcm-two-family-fixed-point-20261006.R')
stopifnot(unname(tools::md5sum(original))==unname(prior$script))
# Execute only the already checked source's definitions/input qualification,
# before its manifest and numerical phases. Its frozen hash fixes this prefix.
expressions <- parse(original)
boundary <- which(vapply(expressions,function(e)is.call(e) &&
  identical(e[[1]],as.name('<-')) && identical(e[[2]],as.name('out')),TRUE))
stopifnot(length(boundary)==1L,boundary>1L)
for (e in expressions[seq_len(boundary-1L)])eval(e,.GlobalEnv)
stopifnot(identical(prior_manifest$checksum,wide_mml_hash(prior)),
  identical(runtime,prior$runtime),identical(theta,prior$theta),
  identical(wide_mml_hash(response),prior$response),
  identical(tools::md5sum(names(prior$inputs)),prior$inputs),
  identical(tools::md5sum(names(prior$external_sources)),prior$external_sources))
reuse <- function(name) {
  x <- readRDS(file.path(prior_root,paste0(name,'.rds')))
  stopifnot(identical(x$binding,prior),identical(x$checksum,wide_mml_hash(x$payload)))
  x$payload
}
stopifnot(reuse('probability-map')$passed,!reuse('assessment')$passed)
old_results <- lapply(c('q121-d0.01','q241-d0.01','q241-d0.005'),reuse)
script <- sub('^--file=','',grep('^--file=',commandArgs(),value=TRUE))
binding <- list(prior_manifest=tools::md5sum(file.path(prior_root,'manifest.rds')),
  original_source=tools::md5sum(original),script=tools::md5sum(script),
  runtime=runtime,quadrature=rules,tolerance=prior$tolerance,scope=prior$scope,
  derivative=list(method='Richardson',r=4L,coordinate='x = retained_theta + z - 1; evaluate at z=1',
    d=c(.04,.02),reason='Uniform absolute native-coordinate steps avoid a tiny step proportional to near-zero retained coordinates. The original likelihood/map/target and stability gates are unchanged.'),
  previous=tools::md5sum(file.path(prior_root,paste0(c('probability-map','assessment',
    'q121-d0.01','q241-d0.01','q241-d0.005'),'.rds'))))
out <- file.path(prior_root,'absolute-step-review')
dir.create(out,showWarnings=FALSE)
stopifnot(identical(wide_mml_phase(file.path(out,'manifest.rds'),'two-family-absolute-step-v1',function()binding),binding))
target <- file.path(out,basename(script))
if(!file.exists(target))stopifnot(file.copy(script,target))
stopifnot(unname(tools::md5sum(target))==unname(binding$script))
phase <- function(name,compute)wide_mml_phase(file.path(out,paste0(name,'.rds')),binding,compute)
results <- list()
for (setting in list(c(121,.04),c(241,.04),c(241,.02))) {
  name <- paste0('q',setting[1],'-d',setting[2]);q <- rules[[as.character(setting[1])]]
  results[[name]] <- phase(name,function() {
    fn <- function(z)objective(theta+z-1,q);started <- proc.time();z <- rep(1,length(theta))
    list(objective=objective(theta,q),
      gradient=numDeriv::grad(fn,z,method.args=list(d=setting[2],r=4L)),
      information=numDeriv::hessian(fn,z,method.args=list(d=setting[2],r=4L)),
      seconds=unname((proc.time()-started)['elapsed']))
  })
  cat('Completed',name,'seconds',results[[name]]$seconds,'\n');flush.console()
}
# Reuse the exact original assessment expression with the unchanged tolerance
# vector and newly bound raw derivatives; this does not revisit old raw phases.
assessment_expression <- which(vapply(expressions,function(e)is.call(e) &&
  identical(e[[1]],as.name('<-')) && identical(e[[2]],as.name('assessment')),TRUE))
stopifnot(length(assessment_expression)==1L)
eval(expressions[[assessment_expression]],.GlobalEnv)
print(assessment)
stopifnot(assessment$passed,identical(wide_d_runtime(),runtime),
  identical(tools::md5sum(names(prior$inputs)),prior$inputs),
  identical(tools::md5sum(names(prior$external_sources)),prior$external_sources))
cat('Absolute-step review passed with the original tolerances.\n')
