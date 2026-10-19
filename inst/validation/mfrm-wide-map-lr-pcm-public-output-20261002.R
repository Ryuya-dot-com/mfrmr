# Produce coherent public fits at the already qualified integration orders.
# The public API has no one-family direct-MML warm-start/finalization entry
# point, so four bounded full calls are needed; no fit is assembled by editing
# opt$par alone. Preserve original fits and research Newton solutions.
dlr_pcm_public_output <- function(out) {
  pkgload::load_all('.',quiet=TRUE,compile=FALSE)
  source('inst/validation/mfrm-wide-map-lr-pcm-information-20261002.R')
  root <- 'validation-results/mfrm-wide-map-lr-witness-20261002'
  mp <- file.path(root,'manifest.rds'); m <- readRDS(mp)$payload
  rp <- 'validation-results/mfrm-wide-map-lr-pcm-information-20261002/refined-verified.rds'
  prior <- readRDS(rp); runtime <- wide_mml_runtime()
  stopifnot(identical(runtime$source,prior$runtime$source))
  script <- 'inst/validation/mfrm-wide-map-lr-pcm-public-output-20261002.R'
  dir.create(out,recursive=TRUE,showWarnings=FALSE); results <- list()
  for(id in prior$summary$Job) {
    args <- m$jobs[[id]]$args
    q <- prior$summary$Q[match(id,prior$summary$Job)]
    args$quad_points <- as.integer(q); args$reltol <- 1e-12
    dir <- file.path(out,id);dir.create(dir,showWarnings=FALSE)
    binding <- list(args=args,runtime=runtime,source=tools::md5sum(script),
      original=tools::md5sum(mp),qualified=tools::md5sum(rp))
    cat('Coherent public PCM output:',id,'q',q,'\n');flush.console()
    fitting <- wide_mml_phase(file.path(dir,'fit.rds'),binding,
      function()wide_mml_capture(function()do.call(mfrmr::fit_mfrm,args)))
    stopifnot(!nzchar(fitting$error))
    fit <- fitting$value; ctx <- dlr_pcm_boundary_context(fit)
    par <- fit$opt$par; expanded <- mfrmr:::expand_params(par,ctx$sizes,fit$config)
    for(actual in list(fit$population,fit$config$population_spec)) {
      stopifnot(isTRUE(all.equal(actual$coefficients,expanded$population$coefficients,tolerance=1e-12)),
        isTRUE(all.equal(actual$sigma2,expanded$population$sigma2,tolerance=1e-12)))
    }
    stopifnot(isTRUE(all.equal(mfrmr:::build_other_facet_table(fit$config,fit$prep,expanded),fit$facets$others)),
      isTRUE(all.equal(mfrmr:::build_step_table(fit$config,fit$prep,expanded),fit$steps)),
      identical(summary(fit),summary(unserialize(serialize(fit,NULL,version=3)))))
    ref <- dlr_pcm_information_reference(ctx,par,file.path(dir,'continuous'),FALSE)
    native <- dlr_pcm_information_native(ctx,par,q,file.path(dir,paste0('q',q,'-information.rds')),runtime)
    check <- dlr_pcm_information_compare(ref,native,par)
    stopifnot(check$Stationary,check$IntegrationAgreement,check$InformationAgreement)
    labels <- c(paste0('Rater:',1:2),paste0('Criterion:',1:2),
      paste0('step:Criterion:',rep(1:3,each=2),':',rep(1:2,3)),
      'population:(Intercept)','population:X','population:log_variance')
    covariance <- chol2inv(chol(ref$hessian));dimnames(covariance) <- list(labels,labels)
    points <- data.frame(Target=labels,Estimate=par,DiagnosticSD=sqrt(diag(covariance)),
      IntervalStatus='population_truth_intervals_unqualified')
    comparison <- cbind(Job=id,Q=q,FitSeconds=fitting$elapsed,check,
      DifferenceFromResearchNewton=max(abs(par-prior$details[[id]]$par)),
      DifferenceInReferenceSD=max(abs(par-prior$details[[id]]$par)/sqrt(diag(covariance))))
    results[[id]] <- list(fit_path=file.path(dir,'fit.rds'),fit_hash=wide_mml_hash(fitting),
      comparison=comparison,public_summary=summary(fit),points=points,covariance=covariance,
      reference=ref,native=native,source=binding)
    print(comparison[c('Job','Q','FitSeconds','ReferenceGradient','DifferenceInReferenceSD')],row.names=FALSE)
  }
  summary <- do.call(rbind,lapply(results,`[[`,'comparison'))
  wide_mml_save(list(summary=summary,details=results,runtime=runtime,source=tools::md5sum(script),
    source_code=readLines(script),new_datasets=0L,public_fit_calls=4L,
    scope='Coherent retained PCM public points and research joint covariance; no new formal interval eligibility.'),
    file.path(out,'verified.rds'))
  write.csv(summary,file.path(out,'summary.csv'),row.names=FALSE)
  invisible(results)
}
if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE)
  dlr_pcm_public_output(if(length(args))args[1] else 'validation-results/mfrm-wide-map-lr-pcm-public-output-20261002')
}
