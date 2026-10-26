# Compare existing portable scoring with retained fitted-object batches.
# No new responses, calibration refits, procedure changes or skipped checks.
wide_pcm_portable_check <- function(out, jobs = c('job-14007','job-14008')) {
  source('inst/validation/mfrm-wide-map-pcm-r50-20261002.R');wide_pcm_setup()
  root <- 'validation-results/mfrm-wide-map-pcm-r50-20261002'
  manifest <- wide_f_read(file.path(root,'manifest.rds'))$payload
  stopifnot(all(jobs %in% manifest$jobs$JobId))
  runtime <- wide_multi_runtime()
  script <- 'inst/validation/mfrm-wide-map-pcm-portable-20261003.R'
  checks <- list()
  for (job in jobs) {
    dir <- file.path(root,job)
    output <- wide_f_read(file.path(dir,'outputs.rds'))$payload
    stopifnot(output$completed,output$job$Arm %in% c('GPCM-JML2','GPCM-JML4'))
    input <- wide_recovery_ab_input(manifest$root,output$job$ConditionId,output$job$Replicate)
    src <- wide_f_source(file.path(dir,'calibration'),input)
    stopifnot(src$review$ready,!isTRUE(src$fit$population$active))
    ppath <- file.path(root,'panels',paste0(gsub('[^a-zA-Z0-9]','_',input$ConditionId),'-',input$Replicate,'.rds'))
    panels <- c(list(training=wide_training_panel(input)),wide_f_read(ppath)$payload$panels)
    for (q in c(31L,61L,121L)) {
      used <- vapply(panels,function(panel)any(vapply(c('reference','retained'),function(prior)
        file.exists(file.path(dir,'scoring',paste(panel$Panel,prior,sep='--'),paste0('score-q',q,'.rds'))),TRUE)),TRUE)
      if (!any(used)) next
      prefix <- file.path(out,job,paste0('q',q));dir.create(prefix,recursive=TRUE,showWarnings=FALSE)
      binding <- list(source=src$SourceId,q=q,runtime=runtime,script=tools::md5sum(script))
      artifact_path <- file.path(prefix,'artifact.rds')
      artifact_binding <- binding
      if(file.exists(artifact_path)) {
        old <- wide_f_read(artifact_path)
        # The named-facet scoring fix changes no extraction arguments. Reuse
        # the complete frozen artifact only at identical source/order/runtime.
        fields <- c('source','q','runtime')
        stopifnot(identical(old$binding[fields],binding[fields]))
        artifact_binding <- old$binding
      }
      extraction <- wide_mml_phase(artifact_path,artifact_binding,function()
        wide_mml_capture(function() mfrmr::freeze_mfrm_calibration(mfrmr::validate_mfrm_calibration(
          mfrmr::extract_mfrm_calibration(src$fit,calibration_id=paste(job,q,sep='-'),
            source_fit_id=src$SourceId,scoring_quad_points=q)))))
      stopifnot(!nzchar(extraction$error))
      for (panel in panels[used]) for (prior in c('reference','retained')) {
        key <- paste(panel$Panel,prior,sep='--')
        path <- file.path(dir,'scoring',key,paste0('score-q',q,'.rds'))
        if (!file.exists(path)) next
        saved <- wide_f_read(path)$payload
        rows <- panel$data
        # Events identify repeated ratings. This changes no rating or weight.
        if (!'Event' %in% names(rows)) rows$Event <- ave(seq_len(nrow(rows)),
          interaction(rows$Person,rows$Rater,rows$Criterion,drop=TRUE),FUN=seq_along)
        b <- c(binding,list(panel=panel$PanelId,prior=prior,reference=tools::md5sum(path)))
        observed <- wide_mml_phase(file.path(prefix,paste0(key,'--named-facets.rds')),b,function()
          wide_mml_capture(function() mfrmr::score_mfrm_calibration(extraction$value,rows,
            person='Person',facets=c(Rater='Rater',Criterion='Criterion'),score='Score',event_id='Event',
            scoring_prior=if(prior=='reference')list(mean=0,sd=1) else NULL,interval_level=.95)))
        returned <- !nzchar(saved$error)
        stopifnot(returned==!nzchar(observed$error))
        difference <- NA_real_
        if (returned) {
          a <- saved$value$estimates;b <- observed$value$estimates
          stopifnot(setequal(a$Person,b$Person),!anyDuplicated(b$Person))
          b <- b[match(a$Person,b$Person),]
          fields <- c('Estimate','SD','Lower','Upper','PriorMean','PriorSD')
          difference <- max(abs(as.matrix(a[fields])-as.matrix(b[fields])))
          stopifnot(is.finite(difference),difference<1e-8,
            all(observed$value$settings$score_integration_review$Passed))
        } else stopifnot(wide_f_retry(saved$error),grepl('SCORING_INTEGRATION_FAILED',observed$error,fixed=TRUE))
        checks[[paste(job,q,key,sep=':')]] <- data.frame(Job=job,Arm=output$job$Arm,
          Panel=panel$Panel,Prior=prior,Q=q,Returned=returned,MaximumDifference=difference,
          FittedSeconds=saved$elapsed,PortableSeconds=observed$elapsed,
          ExtractionSeconds=extraction$elapsed)
      }
    }
  }
  result <- do.call(rbind,checks);rownames(result) <- NULL
  write.csv(result,file.path(out,'summary.csv'),row.names=FALSE)
  invisible(result)
}
if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args)>=1L)
  wide_pcm_portable_check(args[1],if(length(args)>1L)args[-1L] else c('job-14007','job-14008'))
}
