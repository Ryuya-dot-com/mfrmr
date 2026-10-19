# Complete the missing corrected-candidate/native-training/re-scoring outputs
# on the retained eight-arm A/B witness. No simulation or calibration refit.
wide_comparison_outputs <- function(out) {
  pkgload::load_all('.', quiet=TRUE, compile=FALSE)
  for (n in c('mml-stages-20261001','jml-stages-20261001','output-summary-20261001',
    'recovery-20261002','interval-recovery-20261002','f-scoring-20261002'))
    source(paste0('inst/validation/mfrm-wide-map-',n,'.R'))
  old <- 'validation-results/mfrm-wide-map-recovery-20261002'
  fm <- 'validation-results/mfrm-wide-map-f-scoring-20261002/witness-manifest.rds'
  m <- wide_f_read(file.path(old,'witness-manifest.rds'))$payload
  sources <- wide_f_read(fm)$payload$sources
  runtime <- wide_jml_runtime()
  scripts <- paste0('inst/validation/mfrm-wide-map-',c('comparison-outputs-20261002',
    'recovery-20261002','interval-recovery-20261002','f-scoring-20261002','output-summary-20261001'),'.R')
  runtime$output_sources <- tools::md5sum(scripts)
  fits <- setNames(lapply(names(m$specs), function(arm) {
    q <- if(m$specs[[arm]]$args$method=='MML')31L else 0L
    path <- file.path(old,arm,paste0('q',q,'-fit.rds'))
    list(path=path,phase=wide_f_read(path),q=q)
  }), names(m$specs))
  for (s in sources) stopifnot(identical(tools::md5sum(names(s$files)),s$files))
  input <- m$input; panel <- wide_training_panel(input)
  manifest <- list(input=input,panel=panel,sources=sources,runtime=runtime,
    fits=tools::md5sum(vapply(fits,`[[`,'','path')),original=tools::md5sum(c(fm,file.path(old,'witness-manifest.rds'))))
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  sealed <- wide_mml_phase(file.path(out,'manifest.rds'),'comparison-outputs-v1',function()manifest)
  stopifnot(identical(sealed,manifest))
  native <- candidates <- rescored <- list()
  for (arm in names(fits)) {
    f <- fits[[arm]]; spec <- m$specs[[arm]]
    stage <- paste0('initial:q',f$q,':',f$phase$checksum)
    native[[arm]] <- wide_training_native(input,spec,f$phase$payload,stage)
    if (!is.null(spec$args$jml_correction_order)) {
      z <- wide_jml_candidate(input,spec,f$phase$payload,stage)
      # Frozen earlier candidate supplies an independent expanded-coordinate
      # check; contrasts additionally exercise off-diagonal covariance terms.
      source('inst/validation/jml-observed-inference-20261001.R')
      ref <- jml_observed_candidate(f$phase$payload$value$jml_adjustment)
      stopifnot(isTRUE(all.equal(unname(as.matrix(z$records[seq_len(nrow(ref)),
        c('Estimate','SE','Lower','Upper','DisplayEstimate','DisplayLower','DisplayUpper')])),
        unname(as.matrix(ref[c('Estimate','SE','Lower','Upper','DisplayEstimate','DisplayLower','DisplayUpper')])),
        tolerance=1e-12)))
      a <- f$phase$payload$value$jml_adjustment
      for (facet in names(input$levels)) {
        ix <- which(a$parameters$Type=='location' & a$parameters$Facet==facet)[1:2]
        row <- z$records$Target==paste('contrast',facet,'1-2',sep=':')
        V <- a$covariance$result$vcov
        stopifnot(abs(z$records$SE[row]^2-(V[ix[1],ix[1]]+V[ix[2],ix[2]]-2*V[ix[1],ix[2]])) < 1e-12)
      }
      for (failure in c('unresolved_start','covariance','fit')) {
        bad <- f$phase$payload
        if (failure=='unresolved_start') bad$value$jml_adjustment$point$status <- 'root_with_unresolved_starts'
        if (failure=='covariance') bad$value$jml_adjustment$covariance$available <- FALSE
        if (failure=='fit') { bad$value <- NULL; bad$error <- 'test fixture: no fit' }
        b <- wide_jml_candidate(input,spec,bad,stage)
        stopifnot(!any(b$records$Available),all(is.na(b$records$SE)),nrow(b$records)==nrow(z$records))
      }
      candidates[[arm]] <- z
    }
    for (prior in c('reference','retained')) {
      key <- paste(arm,prior,sep='--')
      z <- wide_f_run(sources[[arm]],panel,prior,file.path(out,key),runtime)
      rescored[[key]] <- wide_f_records(sources[[arm]],panel,z)
      cat(key,'training re-scoring order',z$selected_order,'\n'); flush.console()
    }
  }
  native <- do.call(rbind,native); rescored <- do.call(rbind,rescored)
  native_summary <- wide_training_summary(native,1L)
  synthetic <- native[native$Arm=='PCM-JML',]
  synthetic$Estimate[1] <- Inf; synthetic$Error[1] <- synthetic$SquaredError[1] <- Inf
  synthetic$Finite[1] <- FALSE; synthetic$Infinite[1] <- TRUE
  synthetic$ResponseExtreme[1] <- 'high'
  bad <- wide_training_summary(synthetic,1L)
  stopifnot(bad$Infinite==1L,is.infinite(bad$MSE),is.na(bad$MSEMCSE),bad$Returned==20L,
    all(!wide_training_summary(native,1:50)$Complete))
  rescore_summary <- wide_f_summary(wide_f_contributions(rescored),1L)
  stopifnot(nrow(native)==160L,nrow(rescored)==640L,all(native$Observed==6L),
    all(rescored$Observed==6L),all(rescored$Family=='training_rescore'),
    identical(manifest$fits,tools::md5sum(names(manifest$fits))),
    identical(runtime$output_sources,tools::md5sum(scripts)))
  result <- list(native=native,native_summary=native_summary,candidates=candidates,
    rescored=rescored,rescore_summary=rescore_summary,runtime=runtime,
    source_code=setNames(lapply(scripts,readLines),scripts),calibration_refits=0L,new_responses=0L,
    independent_datasets=1L,interpretation='Output/source witness, not R=50 performance or public JML truth-inference qualification.')
  wide_mml_save(result,file.path(out,'verified.rds'))
  write.csv(native_summary,file.path(out,'native-summary.csv'),row.names=FALSE)
  write.csv(rescore_summary,file.path(out,'rescore-summary.csv'),row.names=FALSE)
  write.csv(do.call(rbind,lapply(candidates,`[[`,'records')),file.path(out,'jml-candidates.csv'),row.names=FALSE)
  invisible(result)
}
if (sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE)
  wide_comparison_outputs(if(length(args))args[1] else 'validation-results/mfrm-wide-map-comparison-outputs-20261002')
}
