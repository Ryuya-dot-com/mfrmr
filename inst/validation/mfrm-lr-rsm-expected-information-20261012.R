# Fixed-source information geometry; not a small-sample interval correction.
# Use the single-threaded runtime. Optional argument 'replay' performs no numerics.
script <- 'inst/validation/mfrm-lr-rsm-expected-information-20261012.R'
prior <- 'validation-results/mfrm-lr-rsm-adaptive-profile-20261010'
points <- 'validation-results/mfrm-lr-rsm-adaptive-points-20261010'
out <- 'validation-results/mfrm-lr-rsm-inconclusive-20261010'
prefix <- file.path(out, 'expected-information-20261012')
verify <- function(h) stopifnot(length(h)>0L, !anyNA(h),
  identical(unname(tools::md5sum(names(h))), unname(h)))
audit_path <- file.path(prior, 'verification.rds')
audit <- readRDS(audit_path)
stopifnot(isTRUE(audit$passed)); verify(audit$retained); verify(audit$source)
manifest_path <- file.path(prior, 'manifest.rds')
manifest <- readRDS(manifest_path); verify(manifest$inputs)
fit_paths <- names(manifest$inputs)[endsWith(names(manifest$inputs), '-fit.rds')]
stopifnot(length(fit_paths)==6L)
ids <- c(1L, 5L)
source_paths <- file.path(prior, sprintf('case-%02d-source.rds', ids))
reference_paths <- c(file.path(points, 'case01-source.rds'),
                     file.path(points, 'reference-repair.rds'))
point_audit <- readRDS(file.path(points, 'verification.rds'))
stopifnot(point_audit$passed); verify(point_audit$retained)
binding <- list(inputs=tools::md5sum(c(audit_path, manifest_path, source_paths,
  reference_paths, fit_paths[ids], file.path(prior, 'case-06.rds'),
  file.path(points, 'verification.rds'))),
  source=tools::md5sum(c(script, 'inst/validation/mfrm-lr-rsm-boundary-20261009.R',
    list.files('R',full.names=TRUE),'DESCRIPTION','NAMESPACE')),
  orders=c(61L,121L), cases=manifest$cases[ids,],
  scope='Full expected marginal information at two fixed RSM sources; no interval qualification.')
check_result <- function(x) {
  stopifnot(identical(x$binding,binding), all(x$checks),
    identical(x$refusal$status,'source_refused'))
  for (case in x$cases) {
    z <- case$orders[[2L]]
    stopifnot(max(abs(z$information-z$response_information))/max(1,max(abs(z$information)))<=1e-6)
    stopifnot(max(abs(z$information[case$beta,case$rho]-z$missing_cross))<=1e-6)
    expected <- solve(z$information); observed <- solve(case$observed_information)
    se <- function(V) sqrt(diag(case$contrasts %*% V %*% t(case$contrasts)))
    stopifnot(max(abs(se(expected)-case$targets$ExpectedSE))<=1e-12,
      max(abs(se(observed)-case$targets$ObservedSE))<=1e-12)
  }
  invisible(TRUE)
}
if (identical(commandArgs(TRUE),'replay')) {
  result <- readRDS(paste0(prefix,'.rds')); check_result(result)
  table <- read.csv(paste0(prefix,'.csv'),stringsAsFactors=FALSE)
  stopifnot(isTRUE(all.equal(table,result$targets,check.attributes=FALSE,tolerance=1e-12)))
  cat('PASS: fresh base-R input/source, full-matrix and target replay; no new calculations.\n')
  quit(save='no')
}
pkgload::load_all('.',quiet=TRUE,compile=FALSE)
source('inst/validation/mfrm-lr-rsm-boundary-20261009.R')
# Only sizes, slices and normal nodes are consumed from the package. Their
# shared source is unchanged; later reporting/API changes do not refit inputs.
verify(manifest$source[c('R/mfrm_core.R',
  'inst/validation/mfrm-lr-rsm-boundary-20261009.R')])
threads <- Sys.getenv(c('OMP_NUM_THREADS','OPENBLAS_NUM_THREADS',
  'MKL_NUM_THREADS','VECLIB_MAXIMUM_THREADS'))
stopifnot(all(threads=='1'))
for (name in c('fit_mfrm','compute_mml_parameter_covariance','simulate_mfrm_data'))
  trace(name,quote(stop('No fitting, observed Hessian or sampling in this review.')),
    where=asNamespace('mfrmr'),print=FALSE)

enumerate <- function(ctx,par,q) {
  gh <- mfrmr:::gauss_hermite_normal(q)
  stopifnot(abs(sum(gh$weights)-1)<=1e-12,
    abs(sum(gh$weights*gh$nodes^2)-1)<=1e-12,
    abs(sum(gh$weights*gh$nodes^4)-3)<=1e-11)
  v <- exp(tail(par,1)); e <- sqrt(v)*gh$nodes
  beta <- ctx$slices$beta; rho <- ctx$p+1L; d <- length(par)
  Y <- as.matrix(expand.grid(rep(list(0:(ctx$K-1L)),6L)))
  totals <- rowSums(Y); patterns <- nrow(Y)
  info <- response_info <- matrix(0,d,d)
  missing_cross <- numeric(length(beta)); nll <- 0; gradient <- numeric(d)
  mass_error <- score_error <- representation_error <- 0
  for (ix in ctx$groups) {
    stopifnot(length(ix)==6L)
    log_pattern <- matrix(0,patterns,q)
    design_sum <- matrix(0,patterns,ctx$p)
    mean_design <- matrix(0,q,ctx$p); mean_total <- numeric(q)
    for (j in seq_along(ix)) {
      row <- ix[j]
      D <- do.call(rbind,lapply(ctx$design,function(M) M[row,]))
      logits <- outer(e,0:(ctx$K-1L))+rep(drop(D %*% head(par,-1L)),each=q)
      peak <- apply(logits,1L,max)
      logp <- logits-peak-log(rowSums(exp(logits-peak)))
      P <- exp(logp)
      log_pattern <- log_pattern+t(logp[,Y[,j]+1L,drop=FALSE])
      design_sum <- design_sum+D[Y[,j]+1L,,drop=FALSE]
      mean_design <- mean_design+P %*% D
      mean_total <- mean_total+drop(P %*% (0:(ctx$K-1L)))
    }
    joint <- sweep(exp(log_pattern),2L,gh$weights,'*')
    mass <- rowSums(joint); stopifnot(all(is.finite(mass)),all(mass>0))
    posterior <- joint/mass
    moments <- posterior %*% cbind(e,e^2,e^3)
    # Differentiate the predictor at fixed standardized residuals.
    response_score <- cbind(design_sum-posterior %*% mean_design,
      (totals*moments[,1L]-drop(posterior %*% (e*mean_total)))/2)
    # Differentiate the normal density at fixed latent ability instead.
    score <- response_score
    X <- ctx$fit$population$design_matrix[
      match(as.character(ctx$fit$prep$data$Person[ix[1L]]),
        ctx$fit$population$included_persons),,drop=FALSE]
    score[,beta] <- (moments[,1L]/v) %o% as.numeric(X)
    score[,rho] <- (moments[,2L]/v-1)/2
    info <- info+crossprod(score*sqrt(mass))
    response_info <- response_info+crossprod(response_score*sqrt(mass))
    missing_cross <- missing_cross-as.numeric(X)*
      sum(mass*(moments[,3L]-moments[,1L]*moments[,2L]))/(2*v^2)
    mass_error <- max(mass_error,abs(sum(mass)-1))
    score_error <- max(score_error,max(abs(colSums(score*mass))))
    representation_error <- max(representation_error,
      sqrt(max(colSums((score-response_score)^2*mass))))
    observed <- which(rowSums(abs(sweep(Y,2L,ctx$y[ix],'-')))==0)
    stopifnot(length(observed)==1L)
    nll <- nll-log(mass[observed]); gradient <- gradient-score[observed,]
  }
  list(information=info,response_information=response_info,missing_cross=missing_cross,
    mass_error=mass_error,score_error=score_error,
    weighted_score_representation_error=representation_error,nll=nll,gradient=gradient)
}
results <- lapply(seq_along(ids),function(k) {
  file <- sprintf('%s-case%02d.rds',prefix,ids[k])
  if (file.exists(file)) {
    cached <- readRDS(file); stopifnot(identical(cached$binding,binding))
    return(cached$value)
  }
  started <- proc.time()[['elapsed']]
  fit <- readRDS(fit_paths[ids[k]])$payload$value
  source <- readRDS(source_paths[k])$value; reference <- readRDS(reference_paths[k])
  stopifnot(source$passed,identical(source$parameters,reference$point$par))
  ctx <- rsm_lr_boundary_context(fit)
  stopifnot(ctx$K==4L,ctx$persons==c(20L,240L)[k])
  orders <- lapply(binding$orders,function(q) enumerate(ctx,source$parameters,q))
  low <- orders[[1L]]; high <- orders[[2L]]
  relative <- function(a,b) max(abs(a-b))/max(1,max(abs(b)))
  gradient_allowance <- max(vapply(reference$finite_difference,function(x)
    x$refinement+x$reported_gradient_error,0.))
  diagnostics <- c(MassError=high$mass_error,ExpectedScoreError=high$score_error,
    OrderChange=relative(low$information,high$information),
    ScoreRepresentation=relative(high$response_information,high$information),
    MissingIdentity=max(abs(high$information[ctx$slices$beta,ctx$p+1L]-high$missing_cross)),
    NLLReference=abs(high$nll-reference$reference$value)+reference$reference$summed_relative_error,
    GradientReference=max(abs(high$gradient-reference$reference_gradient))+gradient_allowance)
  checks <- c(mass=all(vapply(orders,function(z) z$mass_error<=1e-8,TRUE)),
    score=all(vapply(orders,function(z) z$score_error<=1e-8,TRUE)),
    order=diagnostics['OrderChange']<=1e-6,
    representation=diagnostics['ScoreRepresentation']<=1e-6,
    missing=diagnostics['MissingIdentity']<=1e-6,
    nll=diagnostics['NLLReference']<=1e-5,gradient=diagnostics['GradientReference']<=1e-4,
    positive=min(eigen(high$information,symmetric=TRUE,only.values=TRUE)$values)>0)
  C <- matrix(0,2L,length(source$parameters))
  C[1L,ctx$slices$beta] <- 1; C[2L,ctx$p+1L] <- 1
  se <- function(I) sqrt(diag(C %*% solve(I,t(C))))
  targets <- data.frame(N=ctx$persons,Target=c('mean_at_plus_one','log_variance'),
    ExpectedSE=se(high$information),ObservedSE=se(source$hessian))
  targets$ExpectedOverObserved <- targets$ExpectedSE/targets$ObservedSE
  correlation <- cov2cor(high$information)[ctx$slices$beta,ctx$p+1L]
  value <- list(orders=orders,checks=checks,diagnostics=diagnostics,targets=targets,
    observed_information=source$hessian,contrasts=C,beta=ctx$slices$beta,rho=ctx$p+1L,
    mean_logvariance_information_correlation=correlation,
    elapsed=proc.time()[['elapsed']]-started)
  saveRDS(list(binding=binding,value=value),file)
  print(diagnostics); print(targets)
  cat('Case',ids[k],if(all(checks)) 'PASS' else 'UNRESOLVED',value$elapsed,'seconds\n')
  flush.console(); value
})
result <- list(binding=binding,cases=results,
  checks=unlist(lapply(results,`[[`,'checks')),
  targets=do.call(rbind,lapply(results,`[[`,'targets')),
  refusal=readRDS(file.path(prior,'case-06.rds')),
  session=sessionInfo(),threads=threads,new_fits=0L,new_draws=0L,new_observed_hessians=0L)
saveRDS(result,paste0(prefix,'.rds'))
write.csv(result$targets,paste0(prefix,'.csv'),row.names=FALSE)
check_result(result)
cat('PASS: both fixed-source information checks; no small-sample coverage claim.\n')
