# External constrained local fit for the already qualified two-family map.
# Run from the retained D source; preserve native fits and all earlier phases.
prior_root <- 'validation-results/mirt-gpcm-two-family-fixed-point-20261006'
prior_manifest <- readRDS(file.path(prior_root,'manifest.rds')); prior <- prior_manifest$payload
original <- file.path(prior_root,'mirt-gpcm-two-family-fixed-point-20261006.R')
stopifnot(unname(tools::md5sum(original))==unname(prior$script))
expressions <- parse(original)
boundary <- which(vapply(expressions,function(e)is.call(e) &&
  identical(e[[1]],as.name('<-')) && identical(e[[2]],as.name('out')),TRUE))
stopifnot(length(boundary)==1L)
for(e in expressions[seq_len(boundary-1L)])eval(e,.GlobalEnv)
read_phase <- function(path,binding) {
  x <- readRDS(path)
  stopifnot(identical(x$binding,binding),identical(x$checksum,wide_mml_hash(x$payload)))
  x$payload
}
review_root <- file.path(prior_root,'absolute-step-review')
review <- read_phase(file.path(review_root,'manifest.rds'),'two-family-absolute-step-v1')
stopifnot(identical(prior_manifest$checksum,wide_mml_hash(prior)),
  identical(runtime,prior$runtime),identical(theta,prior$theta),
  identical(wide_mml_hash(response),prior$response),
  identical(tools::md5sum(names(prior$inputs)),prior$inputs),
  identical(tools::md5sum(names(prior$external_sources)),prior$external_sources),
  read_phase(file.path(review_root,'assessment.rds'),review)$passed)
script <- sub('^--file=','',grep('^--file=',commandArgs(),value=TRUE))
binding <- list(runtime=runtime,script=tools::md5sum(script),
  previous=tools::md5sum(c(file.path(prior_root,'manifest.rds'),original,
    file.path(review_root,c('manifest.rds','assessment.rds','fresh-replay.rds')))),
  inputs=prior$inputs,external_sources=prior$external_sources,
  external_versions=prior$external_versions,response=prior$response,
  quadrature=rules,initial=rep(0,length(theta)),
  optimizer=list(method='stats::nlminb',order=241L,
    control=list(eval.max=10000L,iter.max=3000L,rel.tol=1e-12,
      x.tol=1e-10,abs.tol=1e-12,trace=25L)),
  derivative=list(method='Richardson',r=4L,d=.02,absolute_coordinates=TRUE),
  tolerance=c(probability=1e-5,objective=1e-7,scaled_score=1e-5,
    information=1e-3,covariance=1e-3,scaled_parameter=1e-3,
    quadrature_objective=1e-7),
  scope=paste('One preselected retained N240/SD1/common sample. Independent mirt',
    'item probability engine under the exact shared nonlinear native constraints,',
    'fixed N(0,1), and qualified quadrature. Neutral native-coordinate start and',
    'nlminb optimizer. Local solution agreement only; no global maximum,',
    'boundary exclusion or sampling-coverage conclusion.'))
out <- file.path(prior_root,'neutral-local-fit')
dir.create(out,showWarnings=FALSE)
stopifnot(identical(wide_mml_phase(file.path(out,'manifest.rds'),
  'two-family-neutral-local-fit-v1',function()binding),binding))
target <- file.path(out,basename(script))
if(!file.exists(target))stopifnot(file.copy(script,target))
stopifnot(unname(tools::md5sum(target))==unname(binding$script))
phase <- function(name,compute)wide_mml_phase(file.path(out,paste0(name,'.rds')),binding,compute)
external_fit <- phase('external-fit',function()wide_mml_capture(function()
  stats::nlminb(binding$initial,function(x)objective(x,rules[['241']]),
    control=binding$optimizer$control)))
cat('External optimizer error:',external_fit$error,'\n');flush.console()
stopifnot(!nzchar(external_fit$error))
solution <- external_fit$value
cat('Optimizer',solution$convergence,solution$message,'objective',
  format(solution$objective,digits=16),'iterations',solution$iterations,'\n');flush.console()
derivatives <- phase('external-information',function() {
  x <- solution$par; fn <- function(z)objective(x+z-1,rules[['241']])
  list(gradient=numDeriv::grad(fn,rep(1,length(x)),method.args=list(d=.02,r=4L)),
    information=numDeriv::hessian(fn,rep(1,length(x)),method.args=list(d=.02,r=4L)))
})
assessment <- phase('assessment',function() {
  x <- solution$par; C <- joint$covariance; U <- chol(C)
  H <- derivatives$information
  eigenvalues <- eigen(H,symmetric=TRUE,only.values=TRUE)$values
  inverse <- if(min(eigenvalues)>0)solve(H)else matrix(NA_real_,22L,22L)
  z <- c(-3,-1,0,.7,2.5)
  errors <- c(probability=max(abs(do.call(rbind,probabilities(x,z))-
      wide_d_response_points(fit,z)$probabilities)),
    objective=abs(objective(x,rules[['241']])-fit$opt$value),
    scaled_score=max(abs(drop(U%*%derivatives$gradient))),
    information=norm(U%*%(H-joint$information$hessian)%*%t(U),'2'),
    covariance=norm(inverse-C,'2')/norm(C,'2'),
    scaled_parameter=max(abs(solve(t(U),x-theta))),
    quadrature_objective=abs(objective(x,rules[['121']])-objective(x,rules[['241']])))
  list(passed=solution$convergence==0L && min(eigenvalues)>0 &&
      all(is.finite(errors)) && all(errors<binding$tolerance[names(errors)]),
    errors=errors,tolerances=binding$tolerance,smallest_eigenvalue=min(eigenvalues),
    optimizer=solution[c('convergence','message','iterations','evaluations')],
    warnings=external_fit$warnings,scope=binding$scope,new_native_fits=0L,new_datasets=0L)
})
print(assessment);flush.console()
stopifnot(identical(wide_d_runtime(),runtime),
  identical(tools::md5sum(names(binding$previous)),binding$previous),
  identical(tools::md5sum(names(prior$inputs)),prior$inputs),
  identical(tools::md5sum(names(prior$external_sources)),prior$external_sources),
  assessment$passed)
cat('External constrained local solution comparison passed.\n')
