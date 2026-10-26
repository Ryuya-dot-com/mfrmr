# One retained-data, equivalent-model joint-covariance comparison.
# No new response generation, multifacet equivalence or sampling qualification.
pkgload::load_all('.', quiet=TRUE, compile=FALSE, helpers=FALSE)
.libPaths(c(.libPaths(), '/Library/Frameworks/R.framework/Resources/library'))
source('inst/validation/mfrm-wide-map-mml-stages-20261001.R')
source('inst/validation/tam-gpcm-item-only-overlap-0.2.3.R')
source('inst/validation/mirt-gpcm-joint-overlap-20261005.R')
stopifnot(requireNamespace('mirt',quietly=TRUE), requireNamespace('numDeriv',quietly=TRUE))
out <- 'validation-results/mirt-gpcm-joint-overlap-20261005'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
scripts <- c('inst/validation/mirt-gpcm-joint-run-20261005.R',
  'inst/validation/mirt-gpcm-joint-overlap-20261005.R',
  'inst/validation/tam-gpcm-item-only-overlap-0.2.3.R')
input <- mfrmr_tgio_data(); items <- input$items; K <- 4L
stopifnot(nrow(input$response)==392L,length(items)==3L,
  !anyNA(input$response),identical(sort(unique(input$long$Score)),0:3))
quad <- mfrmr:::gauss_hermite_normal(61L)
# Reuse the already qualified native normal rule in both engines so that
# likelihood/information differences cannot be attributed to different nodes.
stopifnot(length(quad$nodes)==61L,all(quad$weights>0),abs(sum(quad$weights)-1)<1e-12)
technical <- list(customTheta=matrix(quad$nodes,ncol=1L),
  customPriorFun=local({weights <- quad$weights; function(Theta,Etable) weights}),
  NCYCLES=2000L,zeroExtreme=FALSE)
parameters <- mirt::mirt(input$response,1,itemtype='gpcm',pars='values',verbose=FALSE)
parameters$lbound[parameters$name=='a1'] <- 0
layout <- mirt_overlap_layout(parameters,items,K)
runtime <- wide_mml_runtime()
external <- c('mirt','TAM','numDeriv')
external <- sort(unique(c(external,unlist(tools::package_dependencies(
  external,db=installed.packages(),recursive=TRUE),use.names=FALSE))))
runtime$external_versions <- setNames(vapply(external,function(p)as.character(packageVersion(p)),''),external)
external_files <- unlist(lapply(external,function(p) {
  root <- system.file(package=p)
  list.files(root,'(DESCRIPTION|[.]rdb|[.]rdx|[.]so)$',recursive=TRUE,full.names=TRUE)
}),use.names=FALSE)
runtime$external_sources <- tools::md5sum(external_files)
runtime$source <- c(runtime$source,tools::md5sum(c(scripts,'src/mfrmr.so')))
binding <- list(runtime=runtime,input=wide_mml_hash(input),quadrature=quad,
  mirt=list(method='EM',SE.type='Louis',TOL=1e-9,cycles=2000L,parameters=parameters,
    zeroExtreme=FALSE,positive_slope_closure=TRUE),
  native=list(quad_points=61L,maxit=500L,reltol=1e-10,mml_engine='direct',
    mml_integration='fixed',optimizer='BFGS',gpcm_mml_identification='free_population'),
  scope='Item-only GPCM, all 392 original Persons, normal population and matching 61-node Gaussian rule. Retain observed full covariance; no diagonal approximation or sampling-coverage claim.')
stopifnot(identical(wide_mml_phase(file.path(out,'manifest.rds'),'mirt-joint-v1',function()binding),binding))
source_root <- file.path(out,'source'); dir.create(source_root,showWarnings=FALSE)
for (path in names(runtime$source)[names(runtime$source)!='loaded:mfrmr']) {
  target <- file.path(source_root,path);dir.create(dirname(target),recursive=TRUE,showWarnings=FALSE)
  if (!file.exists(target)) stopifnot(file.copy(path,target))
  stopifnot(unname(tools::md5sum(target))==unname(runtime$source[path]))
}
phase <- function(name,compute) wide_mml_phase(file.path(out,paste0(name,'.rds')),binding,compute)
preflight <- phase('coordinate-preflight',function() {
  probe <- parameters;probe$value[probe$name=='a1'] <- c(.7,1.1,1.6)
  l <- mirt_overlap_layout(probe,items,K); map <- mirt_overlap_map(l$values,l)
  numeric_J <- numDeriv::jacobian(function(v)mirt_overlap_map(v,l)$value,l$values)
  delta <- max(abs(numeric_J-map$jacobian)); stopifnot(delta<1e-8,abs(map$mu)>1e-3)
  object <- mirt::mirt(input$response,1,itemtype='gpcm',pars=probe,TOL=NaN,
    technical=technical,verbose=FALSE)
  returned <- mirt::mod2values(object)
  stopifnot(identical(returned$value,probe$value))
  z <- c(-3,-1,0,.7,2.5); probability_error <- numeric(length(items))
  for (i in seq_along(items)) {
    threshold <- map$thresholds[i,]+map$mu
    eta <- outer(map$mu+map$sigma*z,0:(K-1L))-
      matrix(rep(c(0,cumsum(threshold)),each=length(z)),length(z))
    logits <- map$relative_slopes[i]*eta
    mass <- exp(logits-apply(logits,1,max));mass <- mass/rowSums(mass)
    external <- mirt::probtrace(mirt::extract.item(object,i),matrix(z,ncol=1L))
    probability_error[i] <- max(abs(external-mass))
  }
  stopifnot(max(probability_error)<1e-12)
  list(jacobian_error=delta,probability_errors=probability_error,unequal_slopes=TRUE,
    nonzero_population_mean=map$mu,new_fits=0L,new_response_datasets=0L)
})
cat('Coordinate map and analytic Jacobian passed before estimation.\n');flush.console()
external_fit <- phase('mirt-fit',function()wide_mml_capture(function()
  mirt::mirt(input$response,1,itemtype='gpcm',pars=parameters,method='EM',
    SE=TRUE,SE.type='Louis',TOL=1e-9,technical=technical,verbose=FALSE)))
cat('mirt fit completed; error:',external_fit$error,'elapsed:',external_fit$elapsed,'\n');flush.console()
native_fit <- phase('native-fit',function()wide_mml_capture(function()
  mfrmr::fit_mfrm(input$long,person='Person',facets='Criterion',score='Score',
    method='MML',model='GPCM',step_facet='Criterion',slope_facet='Criterion',
    population_formula=~1,gpcm_mml_identification='free_population',
    quad_points=61L,maxit=500L,reltol=1e-10,mml_engine='direct',
    mml_integration='fixed',optimizer='BFGS',category_policy='preserve',rating_min=0,rating_max=3)))
cat('Native fit completed; error:',native_fit$error,'elapsed:',native_fit$elapsed,'\n');flush.console()
stopifnot(!nzchar(external_fit$error),!nzchar(native_fit$error))
native_information <- phase('native-information',function()wide_mml_capture(function()
  mfrmr:::mfrm_native_location_inference(native_fit$value)))
stopifnot(identical(tools::md5sum(names(runtime$source)[names(runtime$source)!='loaded:mfrmr']),
  runtime$source[names(runtime$source)!='loaded:mfrmr']),
  identical(tools::md5sum(names(runtime$external_sources)),runtime$external_sources))
cat('Joint overlap fitting/information phases saved; numerical qualification and transformed-covariance comparison still required.\n')
