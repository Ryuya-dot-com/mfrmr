# Read the selected point-calibration stage of the frozen PCM regression study.
# The original source review and boundary decision remain separate evidence.
# Source mml-stages, recovery, f-scoring and lr-scoring helpers first.
dlr_f_saved_source <- function(path, row, runtime) {
  manifest_path <- file.path(path,'manifest.rds')
  selected_path <- file.path(path,'selected.rds')
  m <- wide_f_read(manifest_path)$payload
  selected_record <- wide_f_read(selected_path);selected <- selected_record$payload
  identity <- wide_mml_hash(m);spec <- m$spec
  stopifnot(identical(selected_record$binding,identity),
    identical(selected$identity,identity),identical(selected$spec_hash,wide_mml_hash(spec)),
    identical(spec$ConditionId,row$ConditionId),spec$Replicate==row$Replicate,
    identical(spec$provenance,c(lr=row$BundleMD5,ab=row$ABBundleMD5)),
    identical(spec$InputId,wide_mml_hash(list(data=spec$args$data,persons=spec$args$person_data))),
    spec$Arm=='PCM-MML-LR',spec$args$model=='PCM',spec$args$method=='MML')
  # Calibration ran with one numerical thread. Scoring's qualified runtime is
  # checked by its caller; record this distinction instead of rewriting either.
  for(name in setdiff(names(runtime),'threads'))
    stopifnot(identical(runtime[[name]],m$runtime[[name]]))
  stopifnot(all(m$runtime$threads=='1'))
  x <- selected$point
  fit_path <- file.path(path,paste0('q',x$order,'-fit.rds'))
  f <- wide_f_read(fit_path)
  stopifnot(identical(f$checksum,x$fit_hash),identical(f$payload$error,x$error),
    identical(f$binding,list(job=identity,order=x$order,phase='fit',dependency=NULL)))
  fit <- f$payload$value
  if(!nzchar(x$error)) stopifnot(inherits(fit,'mfrm_fit'),
    fit$config$estimation_control$quad_points==x$order)
  paths <- c(manifest_path,selected_path,fit_path)
  if(!is.null(x$review)) {
    review_path <- file.path(path,paste0('q',x$order,'-scoring-source.rds'))
    review <- wide_f_read(review_path)
    stopifnot(identical(review$payload,x$review),
      identical(review$binding,list(job=identity,order=x$order,phase='scoring-source',dependency=f$checksum)))
    paths <- c(paths,review_path)
  }
  if(!is.null(x$boundary)) {
    boundary_path <- file.path(path,paste0('q',x$order,'-boundary-review.rds'))
    boundary <- wide_f_read(boundary_path)
    stopifnot(identical(boundary$payload,x$boundary))
    paths <- c(paths,boundary_path)
  }
  public_ready <- !is.null(x$review) && !nzchar(x$review$error) && isTRUE(x$review$value$ready)
  boundary_ready <- !is.null(x$boundary) && !nzchar(x$boundary$error) && isTRUE(x$boundary$value$eligible)
  stopifnot(identical(isTRUE(x$eligible),!nzchar(x$error) && public_ready && boundary_ready))
  reasons <- c(x$error,x$review$error,x$review$value$reason_codes,
    x$boundary$error,x$boundary$value$reason)
  review <- list(ready=isTRUE(x$eligible),
    reason_codes=unique(reasons[!is.na(reasons) & nzchar(reasons)]),
    local_calibration_review=x$review$value$local_calibration_review)
  source <- list(fit=fit,review=review,error=x$error,
    stage=paste0('q',x$order,':',f$checksum),spec=spec,
    model_source=m$runtime$source,calibration_runtime=m$runtime,
    public_source_review=x$review,study_boundary=x$boundary,
    files=tools::md5sum(paths),
    selection='Frozen selected point source; interval selection never substitutes for scoring admission.')
  source$SourceId <- wide_mml_hash(source)
  source
}
