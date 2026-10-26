# Fill the missing finer-grid evidence for the saved fixed-normal PCM arm.
# Fixed parameters only: no optimization, response generation or replacement.
wide_fixed_pcm_quadrature <- function(root,out) {
  source('inst/validation/mfrm-wide-map-pcm-r50-20261002.R');wide_pcm_setup()
  for(n in c('optim','nlminb','uniroot'))trace(n,
    tracer=quote(stop('Refitting forbidden in fixed-parameter quadrature audit')),
    print=FALSE,where=asNamespace('stats'))
  on.exit(for(n in c('optim','nlminb','uniroot'))untrace(n,where=asNamespace('stats')),add=TRUE)
  manifest <- wide_f_read(file.path(root,'manifest.rds'))$payload
  stopifnot(identical(manifest$source,tools::md5sum(names(manifest$source))))
  summary <- wide_f_read(file.path(root,'summary-n30/summary.rds'))$payload
  jobs <- summary$jobs[summary$jobs$Arm=='PCM-MML-fixed',]
  stopifnot(nrow(jobs)==50L,all(jobs$ConditionId=='AB:paired-L1:N30:SD1:S-PCM'))
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  binding <- list(source=tools::md5sum('inst/validation/mfrm-wide-map-fixed-pcm-quadrature-20261003.R'),
    runtime=wide_mml_runtime(),orders=c(31L,61L,121L),parameters='fixed saved q31 solution')
  rows <- lapply(seq_len(nrow(jobs)),function(i) {
    job <- jobs[i,];path <- file.path(root,job$JobId,'calibration/selected.rds')
    selected <- wide_f_read(path)$payload
    bind <- c(binding,list(input=tools::md5sum(path)))
    wide_mml_phase(file.path(out,paste0(job$JobId,'.rds')),bind,function() {
      fit <- selected$intervals$rater$value$fit;par <- fit$opt$par
      cov <- selected$intervals$rater$value$parameter_covariance
      stopifnot(fit$config$model=='PCM',fit$config$method=='MML',length(par)==10L,
        fit$config$estimation_control$quad_points==31L,
        identical(cov,selected$intervals$criterion$value$parameter_covariance))
      H <- solve(cov);rootH <- chol(H)
      cfg <- fit$config;sizes <- mfrmr:::build_param_sizes(cfg)
      idx <- mfrmr:::build_indices(fit$prep,cfg$step_facet,cfg$slope_facet,cfg$interaction_specs)
      ev <- mfrmr:::make_mfrm_direct_evaluator('MML',
        mfrmr:::make_param_cache(sizes,cfg,idx,is_mml=TRUE),idx,cfg,sizes,
        mfrmr:::gauss_hermite_normal(31L))
      g <- ev$gradient(par);value <- ev$value(par)
      stopifnot(abs(value-fit$opt$value)<1e-8)
      fine <- lapply(c(61L,121L),function(q) {
        view <- fit;view$config$estimation_control$quad_points <- q
        z <- mfrmr:::compute_mml_parameter_covariance(view)
        stopifnot(z$status=='ok',!z$regularized,identical(view$opt$par,par))
        list(order=q,info=z)
      })
      records <- lapply(fine,function(z) {
        info <- z$info;gf <- info$solution_information$gradient
        change <- norm(rootH%*%(info$cov-cov)%*%t(rootH),'2')
        shift <- sqrt(drop(crossprod(gf-g,cov%*%(gf-g))))
        scaled <- sqrt(drop(crossprod(g,cov%*%g)))
        residual <- norm(info$hessian%*%info$cov-diag(length(par)),'I')
        data.frame(JobId=job$JobId,Replicate=job$Replicate,OriginalOrder=31L,
          ComparisonOrder=z$order,NLLChange=abs(value-info$solution_information$evaluation_summary$ReevaluatedObjective),
          GradientChange=max(abs(gf-g)),ComparisonGradient=max(abs(gf)),
          CurvatureScaledGradient=scaled,QuadratureScoreShift=shift,
          QuadratureCovarianceChange=change,ComparisonInverseResidual=residual,
          SourceTolerancePassed=max(abs(gf-g))<=1e-4 && max(abs(gf))<=1e-4 &&
            abs(value-info$solution_information$evaluation_summary$ReevaluatedObjective)<=1e-5,
          IntervalTolerancePassed=scaled<=.01 && shift<=.01 && change<=.01 && residual<=1e-6)
      })
      C61 <- fine[[1]]$info$cov;C121 <- fine[[2]]$info$cov
      r61 <- chol(fine[[1]]$info$hessian)
      list(records=do.call(rbind,records),fine_covariance_change=norm(r61%*%(C121-C61)%*%t(r61),'2'),
        information=fine,new_fits=0L,notes='Observed-information Hessians use numerical differences of analytic gradients; fixed stored parameters throughout.')
    })
  })
  tables <- do.call(rbind,lapply(rows,`[[`,'records'))
  write.csv(tables,file.path(out,'summary.csv'),row.names=FALSE)
  wide_mml_phase(file.path(out,'summary.rds'),c(binding,list(jobs=tools::md5sum(
    file.path(out,paste0(jobs$JobId,'.rds'))))),function()list(table=tables,
      fine_covariance_change=vapply(rows,`[[`,0,'fine_covariance_change'),new_fits=0L))
  stopifnot(identical(manifest$source,tools::md5sum(names(manifest$source))))
  print(aggregate(cbind(SourceTolerancePassed,IntervalTolerancePassed)~ComparisonOrder,tables,sum))
  invisible(tables)
}

if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args)==2L)
  wide_fixed_pcm_quadrature(args[1L],args[2L])
}
