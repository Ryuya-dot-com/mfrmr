# Read-only combination of the original and precision-refined references.
out <- 'validation-results/shared-rater-calibration-reference-20260923'
plan <- readRDS(file.path(out,'plan.rds'))
original <- readRDS(file.path(out,'summary.rds'))
transport_plan <- readRDS(file.path(out,'transport-plan.rds'))
for(p in list(plan,transport_plan)) {
  for(f in names(p$source)) {
    if(grepl('^validation-results/',f)) stopifnot(unname(tools::md5sum(f))==unname(p$source[f])) else {
      folder <- if(f %in% names(transport_plan$source)) 'transport-source' else 'source'
      stopifnot(unname(tools::md5sum(file.path(out,folder,f)))==unname(p$source[f]))
    }
  }
}
values <- diagnostics <- list()
for(rec in plan$records) {
  old <- readRDS(file.path(out,sprintf('case-%02d.rds',rec$index)))
  x <- readRDS(file.path(out,sprintf('transport-%02d.rds',rec$index)))
  stopifnot(x$index==rec$index,identical(x$source,tools::md5sum(names(x$source))),
    identical(x$stats$Laplace,old$stats$Laplace),nrow(x$stats)==18L)
  values[[rec$index]] <- cbind(Case=rec$index,Trial=rec$trial,Condition=rec$condition,x$stats)
  diagnostics[[rec$index]] <- data.frame(Case=rec$index,
    PlannedPoints=nrow(x$stats),DistinctPoints=nrow(unique(round(t(rec$changes[,-1]),12))),
    SecondsOriginal=old$seconds,SecondsAffine=x$seconds,ZeroError=x$zero_error,StanError=x$stan_error,
    MaxModeGradient=max(vapply(x$maps,`[[`,numeric(1),'gradient')),
    MaxGradientCheck=max(vapply(x$maps,function(m)max(m$checks['Gradient',]),numeric(1))),
    MaxHessianCheck=max(vapply(x$maps,function(m)max(m$checks['Hessian',]),numeric(1))),
    MaxJacobianError=max(vapply(x$maps,`[[`,numeric(1),'determinant_error')))
}
values <- do.call(rbind,values);diagnostics <- do.call(rbind,diagnostics)
stopifnot(nrow(values)==144L,nrow(original$comparisons)==144L,nrow(diagnostics)==8L)
saveRDS(list(original=original,comparisons=values,diagnostics=diagnostics,
  source=tools::md5sum(c('inst/validation/shared-rater-calibration-summary-0.2.4.R',
    file.path(out,c('plan.rds','summary.rds','transport-plan.rds'))))),file.path(out,'transport-summary.rds'))
write.csv(values,file.path(out,'transport-comparisons.csv'),row.names=FALSE)
write.csv(diagnostics,file.path(out,'transport-diagnostics.csv'),row.names=FALSE)
cat('Original comparison:\n');print(table(original$comparisons$Decision))
cat('Affine comparison:\n');print(table(values$Case,values$Decision))
print(aggregate(cbind(AbsoluteError=abs(Error),MaxErrorAllowance,LogMCSE,ParetoK,
  QuadratureDifference,DirectError)~Case,values,max),row.names=FALSE)
print(diagnostics,row.names=FALSE)
cat('Min importance/bulk/tail ESS:',min(values$ImportanceESS),min(values$BulkESS),min(values$TailESS),
  '; max Rhat:',max(values$Rhat),'\n')
