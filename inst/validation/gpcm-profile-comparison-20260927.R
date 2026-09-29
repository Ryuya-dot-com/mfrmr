# Repository-only post-fit comparison. Load the development source first.
profile_comparison_summary <- function(rows, planned) {
  exact <- function(k, n) if (n) unname(stats::binom.test(k, n)$conf.int) else c(NA_real_, NA_real_)
  do.call(rbind, lapply(c('model', 'profile'), function(method) {
    d <- rows[rows$Method == method, ]
    a <- sum(d$Available); k <- sum(d$Covered, na.rm=TRUE)
    measures <- c(availability=a/planned, conditional_coverage=if(a) k/a else NA_real_,
      reported_and_covered=k/planned)
    ci <- rbind(exact(a,planned), exact(k,a), exact(k,planned))
    data.frame(Method=method, Measure=names(measures), Value=unname(measures),
      MCLower=ci[,1], MCUpper=ci[,2], Planned=planned, Attempted=nrow(d),
      Available=a, Covered=k, UnresolvedLower=k/planned,
      UnresolvedUpper=(k+planned-a)/planned)
  }))
}

run_profile_comparison <- function(output_dir) {
  original <- 'validation-results/gpcm-slope-intervals-20260924/coverage'
  prior <- 'validation-results/gpcm-probability-refit-20260925'
  plan <- read.csv(file.path(prior,'plan.csv'))
  stopifnot(nrow(plan)==100L, identical(plan$Rep,1:100),
    all(plan$Owner=='Rater' & plan$Design=='rotating_40' & plan$Condition=='spread'))
  plan$Fit <- file.path(prior,sprintf('refit-%03d.rds',plan$Index))
  plan$Original <- file.path(original,sprintf('interval-%03d.rds',plan$Index))
  audit <- read.csv('validation-results/gpcm-target-reanalysis-20260925/truth-audit.csv')
  stopifnot(identical(unname(tools::md5sum(plan$Original)),audit$MD5[match(plan$Index,audit$Index)]))
  files <- sort(c(list.files('R',pattern='[.]R$',full.names=TRUE),
    list.files('src',pattern='[.](cpp|h|so)$',full.names=TRUE),
    'inst/validation/gpcm-profile-comparison-20260927.R',
    'inst/validation/gpcm-profile-comparison-20260927.md',
    file.path(prior,'plan.csv'), plan$Fit,plan$Original))
  manifest <- list(plan=plan,hashes=tools::md5sum(files),
    native=getLoadedDLLs()[['mfrmr']][['path']], version=as.character(packageVersion('mfrmr')))
  dir.create(output_dir,recursive=TRUE,showWarnings=FALSE)
  path <- file.path(output_dir,'manifest.rds')
  if(file.exists(path)) stopifnot(identical(readRDS(path),manifest)) else {
    saveRDS(manifest,path)
    write.csv(plan,file.path(output_dir,'plan.csv'),row.names=FALSE)
    writeLines(capture.output(sessionInfo()),file.path(output_dir,'session-info.txt'))
    file.copy(files[grepl('^R/|^src/',files)],file.path(output_dir,basename(files[grepl('^R/|^src/',files)])))
  }
  run <- function(i) {
    path <- file.path(output_dir,sprintf('case-%03d.rds',plan$Index[i]))
    if(file.exists(path)) return(readRDS(path))
    source <- readRDS(plan$Original[i]); fit <- readRDS(plan$Fit[i])$fit
    truth <- attr(source$data,'mfrm_truth')$slope_table
    truth <- truth$Estimate[truth$SlopeFacet=='R01']
    stopifnot(length(truth)==1L,abs(truth-exp(-.4))<1e-12,
      identical(fit$prep$data,source$fit$prep$data))
    results <- lapply(c('model','profile'),function(method) {
      warnings <- character(); error <- ''; result <- NULL; started <- proc.time()
      tryCatch(withCallingHandlers({
        result <- if(method=='profile') confint(fit,method=method,slope='R01') else confint(fit,method=method)
      },warning=function(w) { warnings <<- c(warnings,conditionMessage(w));invokeRestart('muffleWarning') }),
      error=function(e) error <<- conditionMessage(e))
      elapsed <- proc.time()-started
      row <- data.frame(Index=plan$Index[i],Rep=plan$Rep[i],Method=method,Truth=truth,
        Returned=!is.null(result),Available=FALSE,Estimate=NA_real_,Lower=NA_real_,Upper=NA_real_,
        Covered=NA,Reason=error,Warning=paste(unique(warnings),collapse=' | '),
        LowerStatus='',UpperStatus='',Elapsed=unname(elapsed['elapsed']),
        CPU=unname(sum(elapsed[c('user.self','sys.self')])))
      if(!is.null(result)) {
        tab <- attr(result,'diagnostics'); tab <- tab[tab$SlopeFacet=='R01',]
        stopifnot(nrow(tab)==1L)
        row$Estimate <- tab$Estimate; row$Lower <- tab$CI_Lower; row$Upper <- tab$CI_Upper
        row$Available <- isTRUE(tab$CIEligible) && all(is.finite(c(row$Lower,row$Upper)))
        row$Reason <- tab$InferenceReview
        if(row$Available) row$Covered <- row$Lower<=truth && truth<=row$Upper
        if(method=='profile') {
          endpoints <- attr(result,'profile')$endpoints
          row$LowerStatus <- endpoints$Status[1]; row$UpperStatus <- endpoints$Status[2]
        }
      }
      list(row=row,result=result)
    })
    out <- list(plan=plan[i,],results=results)
    saveRDS(out,path)
    rows <- do.call(rbind,lapply(results,`[[`,'row'))
    cat(sprintf('Case %03d: available %s/%s; %.2fs total\n',plan$Index[i],
      rows$Available[1],rows$Available[2],sum(rows$Elapsed))); flush.console()
    out
  }
  started <- proc.time()[['elapsed']]
  results <- parallel::mclapply(seq_len(nrow(plan)),run,mc.cores=2L,mc.preschedule=FALSE)
  stopifnot(!any(vapply(results,inherits,logical(1),'try-error')))
  rows <- do.call(rbind,lapply(results,function(x) do.call(rbind,lapply(x$results,`[[`,'row'))))
  stopifnot(nrow(rows)==200L, !anyDuplicated(rows[c('Index','Method')]))
  write.csv(rows,file.path(output_dir,'rows.csv'),row.names=FALSE)
  summary <- profile_comparison_summary(rows,nrow(plan))
  write.csv(summary,file.path(output_dir,'summary.csv'),row.names=FALSE)
  saveRDS(list(wall_seconds=proc.time()[['elapsed']]-started,completed=nrow(plan)),
    file.path(output_dir,'completion.rds'))
  print(summary)
  invisible(rows)
}
