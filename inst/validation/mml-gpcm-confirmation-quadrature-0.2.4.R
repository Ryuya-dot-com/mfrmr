# Review stored Q101 fits: no simulation and no optimization.
# Run from development with MFRMR_PREFLIGHT_ARM=current or ablation.
source('inst/validation/mml-gpcm-confirmation-preflight-0.2.4.R')
arm <- Sys.getenv('MFRMR_PREFLIGHT_ARM')
stopifnot(arm %in% c('current','ablation'))
lib <- normalizePath(file.path(confirmation_root,paste0('lib-',arm)))
library('mfrmr',lib.loc=lib,character.only=TRUE)
dll <- normalizePath(getLoadedDLLs()[['mfrmr']][['path']])
stopifnot(startsWith(dll,paste0(lib,'/')),
  identical(normalizePath(find.package('mfrmr')),file.path(lib,'mfrmr')))
ns <- asNamespace('mfrmr')
plan <- read.csv(file.path(confirmation_root,'preflight-plan.csv'))
results <- list()
for(cell in plan$Cell) {
  input <- file.path(confirmation_root,'preflight',sprintf('%s-%02d.rds',arm,cell))
  x <- readRDS(input); spec <- x$spec; target <- confirmation_targets(spec)
  stopifnot(identical(x$arm,arm),identical(x$identity[['Runner']],unname(tools::md5sum(confirmation_runner))),
    identical(x$identity[['Manifest']],unname(tools::md5sum(file.path(confirmation_root,'source-manifest.csv')))))
  dest <- file.path(confirmation_root,'preflight',sprintf('%s-%02d-q101-outputs.rds',arm,cell))
  stopifnot(!file.exists(dest))
  rows <- target$rows; rows$Attempted <- TRUE; rows$FitReturned <- !is.null(x$q101)
  errors <- warnings <- character(); objects <- list()
  started <- proc.time()[['elapsed']]
  capture <- function(label,expr) tryCatch(withCallingHandlers(expr,warning=function(w) {
    warnings <<- c(warnings,paste(label,conditionMessage(w))); invokeRestart('muffleWarning')
  }),error=function(e) {errors <<- c(errors,paste(label,conditionMessage(e)));NULL})
  info <- if(!is.null(x$q101))capture('solution_check',ns$mfrm_gpcm_inference(x$q101)) else NULL
  rows$SolutionEligible <- isTRUE(info$check$eligible)
  if(!is.null(x$q101)) for(method in c('model','sandwich')) for(adjustment in c('none','bonferroni')) {
    for(kind in c('relative','standardized','ratio','difference','probability','information')) {
      at <- which(rows$Kind==kind & rows$Method==method & rows$Adjustment==adjustment)
      label <- paste(kind,method,adjustment,sep='_')
      obj <- capture(label,{
        if(kind %in% c('probability','information')) mfrmr::mfrm_curve_intervals(x$q101,target$grid,
          type=kind,method=method,simultaneous=adjustment) else {
          opts <- list(object=x$q101,scale=if(kind %in% c('relative','ratio'))'relative' else 'standardized',
            method=method,simultaneous=adjustment)
          if(kind %in% c('ratio','difference')) {opts$contrasts <- target$contrasts; opts$contrast_scale <- kind}
          do.call(stats::confint,opts)
        }
      })
      objects[[label]] <- obj
      if(is.null(obj)) {rows$Reason[at] <- tail(errors,1);next}
      tab <- if(kind %in% c('probability','information'))obj$table else attr(obj,'diagnostics')
      stopifnot(nrow(tab)==length(at))
      rows$Estimate[at] <- tab$Estimate; rows$Returned[at] <- tab$CIEligible
      rows$Lower[at] <- if('Lower' %in% names(tab))tab$Lower else tab$CI_Lower
      rows$Upper[at] <- if('Upper' %in% names(tab))tab$Upper else tab$CI_Upper
      rows$Reason[at] <- tab$InferenceReview
    }
  }
  confirmation_counts(rows)
  stopifnot(identical(rows[c('Kind','Method','Adjustment','Target')],x$rows[c('Kind','Method','Adjustment','Target')]))
  both <- rows$Returned & x$rows$Returned
  finite <- both & is.finite(rows$Lower) & is.finite(rows$Upper) &
    is.finite(x$rows$Lower) & is.finite(x$rows$Upper)
  difference <- data.frame(rows[c('Kind','Method','Adjustment','Target')],
    Q61Returned=x$rows$Returned,Q101Returned=rows$Returned,
    EstimateDifference=rows$Estimate-x$rows$Estimate,
    LowerDifference=rows$Lower-x$rows$Lower,UpperDifference=rows$Upper-x$rows$Upper)
  maximum <- function(x) if(length(x))max(abs(x)) else NA_real_
  summary <- data.frame(Arm=arm,Cell=cell,Q61Eligible=isTRUE(x$check$eligible),
    Q101Eligible=isTRUE(info$check$eligible),Lost=sum(x$rows$Returned & !rows$Returned),
    Gained=sum(!x$rows$Returned & rows$Returned),BothFinite=sum(finite),
    MaxEstimateChange=maximum(difference$EstimateDifference[both]),
    MaxFiniteEndpointChange=maximum(c(difference$LowerDifference[finite],difference$UpperDifference[finite])),
    Errors=length(errors),Elapsed=proc.time()[['elapsed']]-started)
  saveRDS(list(summary=summary,rows=rows,differences=difference,outputs=objects,
    warnings=unique(warnings),errors=errors,source_identity=x$identity,
    input_md5=unname(tools::md5sum(input)),dll=dll,session=sessionInfo()),dest)
  results[[length(results)+1L]] <- summary
  cat(arm,cell,'Q101 outputs saved\n')
}
write.csv(do.call(rbind,results),file.path(confirmation_root,paste0('preflight-q101-',arm,'.csv')),row.names=FALSE)
