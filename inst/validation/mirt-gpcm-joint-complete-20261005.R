# Continue the saved comparison after supplying the required intercept-only
# Person data to native MML. Preserve the first input error and external fit.
pkgload::load_all('.',quiet=TRUE,compile=FALSE,helpers=FALSE)
.libPaths(c(.libPaths(),'/Library/Frameworks/R.framework/Resources/library'))
source('inst/validation/mfrm-wide-map-mml-stages-20261001.R')
source('inst/validation/tam-gpcm-item-only-overlap-0.2.3.R')
source('inst/validation/mirt-gpcm-joint-overlap-20261005.R')
out <- 'validation-results/mirt-gpcm-joint-overlap-20261005'
read_phase <- function(path) {
  x <- readRDS(path);stopifnot(identical(x$checksum,wide_mml_hash(x$payload)));x
}
manifest_path <- file.path(out,'manifest.rds'); manifest <- read_phase(manifest_path)$payload
runtime <- manifest$runtime
for (h in list(runtime$source[names(runtime$source)!='loaded:mfrmr'],runtime$external_sources))
  stopifnot(identical(tools::md5sum(names(h)),h))
current <- wide_mml_runtime()
stopifnot(identical(current$source,runtime$source[names(current$source)]),
  identical(current$R,runtime$R),identical(current$dependencies,runtime$dependencies),
  identical(current$threads,runtime$threads))
input <- mfrmr_tgio_data();stopifnot(identical(wide_mml_hash(input),manifest$input))
external_path <- file.path(out,'mirt-fit.rds'); external <- read_phase(external_path)
initial_error <- read_phase(file.path(out,'native-fit.rds'))
stopifnot(identical(external$binding,manifest),!nzchar(external$payload$error),
  identical(initial_error$binding,manifest),
  identical(initial_error$payload$error,'`person_data` must be a data.frame with one row per person when `population_formula` is supplied.'))
args <- list(data=input$long,person='Person',facets='Criterion',score='Score',method='MML',
  model='GPCM',step_facet='Criterion',slope_facet='Criterion',population_formula=~1,
  person_data=data.frame(Person=unique(input$long$Person)),gpcm_mml_identification='free_population',
  quad_points=61L,maxit=500L,reltol=1e-10,mml_engine='direct',mml_integration='fixed',
  optimizer='BFGS',category_policy='preserve',rating_min=0,rating_max=3)
script <- 'inst/validation/mirt-gpcm-joint-complete-20261005.R'
binding <- list(original=tools::md5sum(manifest_path),external=tools::md5sum(external_path),
  script=tools::md5sum(script),args=args,
  tolerances=c(jacobian=1e-8,probability=1e-5,deviance=1e-5,standardized_covariance=1e-3),
  reason='Missing Person-data plumbing is repaired before any native optimization. No response, model, integration, optimizer or external-fit change. Covariance tolerance is numerical agreement relative to marginal SD products; it is not a sampling-coverage margin.')
stopifnot(identical(wide_mml_phase(file.path(out,'continuation-manifest.rds'),
  'mirt-joint-continuation-v1',function()binding),binding))
phase <- function(name,compute) wide_mml_phase(file.path(out,paste0(name,'.rds')),binding,compute)
native <- phase('native-fit-with-person-data',function()wide_mml_capture(function()
  do.call(mfrmr::fit_mfrm,args)))
cat('Native fitting:',native$error,'elapsed',native$elapsed,'\n');flush.console()
stopifnot(!nzchar(native$error))
information <- phase('native-information',function()wide_mml_capture(function()
  mfrmr:::mfrm_native_location_inference(native$value)))
cat('Native information:',information$error,'eligible',information$value$check$eligible,'\n');flush.console()
stopifnot(!nzchar(information$error),isTRUE(information$value$check$eligible))
result <- phase('joint-comparison',function() {
  fit <- external$payload$value; values <- mirt::mod2values(fit)
  layout <- mirt_overlap_layout(values,input$items,4L)
  external_cov <- stats::vcov(fit); external_vector <- mirt::extract.mirt(fit,'parvec')
  stopifnot(isTRUE(mirt::extract.mirt(fit,'converged')),
    setequal(rownames(external_cov),layout$labels),identical(rownames(external_cov),colnames(external_cov)),
    length(external_vector)==length(layout$values),
    max(abs(unname(external_vector)-layout$values))<1e-12,
    all(is.finite(external_cov)),is.matrix(chol(external_cov)))
  external_cov <- external_cov[layout$labels,layout$labels,drop=FALSE]
  map <- mirt_overlap_map(layout$values,layout)
  J_check <- numDeriv::jacobian(function(v)mirt_overlap_map(v,layout)$value,layout$values)
  native_map <- mirt_overlap_native(native$value,input$items)
  native_J_check <- numDeriv::jacobian(native_map$expand,native$value$opt$par)
  jacobian_error <- c(external=max(abs(J_check-map$jacobian)),
    native=max(abs(native_J_check-native_map$jacobian)))
  Vm <- map$jacobian %*% external_cov %*% t(map$jacobian)
  Vn <- native_map$jacobian %*% information$value$covariance %*% t(native_map$jacobian)
  dimnames(Vn) <- dimnames(Vm)
  scales <- sqrt(diag(Vm));stopifnot(all(scales>0))
  covariance_error <- max(abs(Vn-Vm)/outer(scales,scales))
  z <- c(-3,-1,0,.7,2.5); probability_error <- numeric(length(input$items))
  nm <- mfrmr_tgio_mfrmr_map(native$value,input$items)
  for(i in seq_along(input$items)) {
    eta <- outer(nm$population_mean+sqrt(nm$population_variance)*z,0:3)-
      matrix(rep(c(0,cumsum(nm$thresholds[i,])),each=length(z)),length(z))
    logits <- nm$slopes[i]*eta;mass <- exp(logits-apply(logits,1,max));mass <- mass/rowSums(mass)
    probability_error[i] <- max(abs(mirt::probtrace(mirt::extract.item(fit,i),matrix(z,ncol=1L))-mass))
  }
  deviance_difference <- -2*as.numeric(logLik(fit))-2*native$value$opt$value
  checks <- c(jacobians=max(jacobian_error)<binding$tolerances['jacobian'],
    probabilities=max(probability_error)<binding$tolerances['probability'],
    deviance=abs(deviance_difference)<binding$tolerances['deviance'],
    covariance=covariance_error<binding$tolerances['standardized_covariance'])
  list(checks=checks,jacobian_error=jacobian_error,probability_error=probability_error,
    deviance_difference=deviance_difference,standardized_covariance_error=covariance_error,
    table=data.frame(Target=names(map$value),MirtMapped=map$value,Native=native_map$value,
      MirtSE=sqrt(diag(Vm)),NativeSE=sqrt(diag(Vn))),
    external_native_covariance=external_cov,transformed_external_covariance=Vm,
    expanded_native_covariance=Vn,external_layout=layout,
    external_converged=mirt::extract.mirt(fit,'converged'),native_checks=information$value$checks,
    scope=manifest$scope,new_response_datasets=0L,sampling_qualification=FALSE)
})
print(result$checks);print(result$table)
cat('Numerical differences:',result$jacobian_error,result$probability_error,
  result$deviance_difference,result$standardized_covariance_error,'\n')
stopifnot(identical(tools::md5sum(script),binding$script))
stopifnot(file.copy(script,file.path(out,'source',script),overwrite=TRUE))
