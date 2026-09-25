# G3: pointwise interval availability and coverage, per slope level.
# Reuse every G2 null fit. Add only the missing unequal-slope conditions.
# Replicates, not the three dependent intervals, are the independent MC units.
run_gpcm_slope_intervals <- function(output_dir, null_dir, repetitions = 100L, cores = 4L) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  plan <- read.csv(file.path(null_dir, 'plan.csv'), stringsAsFactors = FALSE)
  stopifnot(nrow(plan) == repetitions * 4L)
  plan$Condition <- 'unit'; plan$SourceIndex <- seq_len(nrow(plan))
  additional <- plan; additional$Condition <- 'spread'
  additional$Seed <- 202609241L + 1000L + seq_len(nrow(additional))
  additional$SourceIndex <- NA_integer_
  plan <- rbind(plan, additional)
  write.csv(plan, file.path(output_dir, 'plan.csv'), row.names = FALSE)
  run <- function(i) {
    p <- plan[i, ]; filename <- file.path(output_dir, sprintf('interval-%03d.rds', i))
    if (file.exists(filename)) return(readRDS(filename)$rows)
    warnings <- character(); fit <- data <- intervals <- NULL
    truth <- if (p$Condition == 'unit') rep(1,3) else exp(c(-.4,0,.4))
    levels <- sprintf('%s%02d', substr(p$Owner,1,1), 1:3)
    rows <- cbind(p[rep(1,3), ], Level = levels, Truth = truth, Returned = FALSE,
      Available = FALSE, Estimate = NA_real_, Lower = NA_real_, Upper = NA_real_,
      Covered = NA, Reason = '', Elapsed = NA_real_)
    started <- proc.time()[['elapsed']]
    tryCatch(withCallingHandlers({
      if (p$Condition == 'unit') {
        source <- readRDS(file.path(null_dir, sprintf('pair-%03d.rds',p$SourceIndex)))
        fit <- source$gpcm; data <- source$data
      } else {
        data <- simulate_mfrm_data(n_person=p$N,n_rater=3,n_criterion=3,
          raters_per_person=p$RatersPerPerson, score_levels=3,model='GPCM',
          step_facet=p$Owner,slope_facet=p$Owner,slopes=setNames(truth,levels),
          thresholds=matrix(c(-.7,-1.1,-1.5,.7,1.1,1.5),3,dimnames=list(levels,NULL)),seed=p$Seed)
        fit <- fit_mfrm(data,person='Person',facets=c('Rater','Criterion'),score='Score',
          model='GPCM',method='MML',step_facet=p$Owner,slope_facet=p$Owner,
          population_formula=~1,person_data=data.frame(Person=unique(data$Person)),person_id='Person',
          rating_min=1,rating_max=3,category_policy='preserve',quad_points=p$Q,
          mml_integration='fixed',maxit=400,reltol=1e-10)
      }
      rows$Returned <- !is.null(fit)
      intervals <- confint(fit,parm='slopes',level=.95)
      tab <- attr(intervals,'diagnostics'); idx <- match(levels,tab$SlopeFacet)
      stopifnot(!anyNA(idx), all(is.finite(truth)))
      rows$Available <- tab$CIEligible[idx]
      rows$Estimate <- tab$Estimate[idx]
      rows$Lower <- tab$CI_Lower[idx]; rows$Upper <- tab$CI_Upper[idx]
      rows$Covered <- ifelse(rows$Available, rows$Lower <= truth & rows$Upper >= truth, NA)
      rows$Reason <- tab$InferenceReview[idx]
    }, warning=function(w) {warnings <<- c(warnings,conditionMessage(w)); invokeRestart('muffleWarning')}),
      error=function(e) rows$Reason <<- paste('Error:',conditionMessage(e)))
    rows$Elapsed <- proc.time()[['elapsed']] - started
    saveRDS(list(rows=rows,fit=if(p$Condition=='spread')fit else NULL,data=if(p$Condition=='spread')data else NULL,
      intervals=intervals,warnings=warnings), filename)
    rows
  }
  out <- parallel::mclapply(seq_len(nrow(plan)),run,mc.cores=cores,mc.preschedule=FALSE)
  stopifnot(all(vapply(out,is.data.frame,logical(1))))
  results <- do.call(rbind,out)
  write.csv(results,file.path(output_dir,'results.csv'),row.names=FALSE)
  groups <- split(results,interaction(results$Condition,results$Owner,results$Design,results$Level,drop=TRUE))
  summary <- do.call(rbind,lapply(groups,function(x) {
    n <- sum(x$Available); covered <- sum(x$Covered,na.rm=TRUE)
    ci <- if(n) binom.test(covered,n)$conf.int else c(NA,NA)
    data.frame(Condition=x$Condition[1],Owner=x$Owner[1],Design=x$Design[1],Level=x$Level[1],
      Truth=x$Truth[1],Planned=nrow(x),Returned=sum(x$Returned),Available=n,Covered=covered,
      Coverage=if(n)covered/n else NA,CoveredPerPlanned=covered/nrow(x),
      MC_Lower95=ci[1],MC_Upper95=ci[2],MeanWidth=mean((x$Upper-x$Lower)[x$Available]),
      Bias=mean(x$Estimate[x$Available]-x$Truth[x$Available]))
  }))
  write.csv(summary,file.path(output_dir,'summary.csv'),row.names=FALSE)
  print(summary, row.names=FALSE)
  invisible(summary)
}
