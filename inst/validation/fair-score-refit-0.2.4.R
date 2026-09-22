# Repository-only pilot; see the prespecified companion protocol.
# Rscript inst/validation/fair-score-refit-0.2.4.R /tmp/fair-score-refit
source('inst/validation/mml-independent-information-conditions-0.2.4.R')
pkgload::load_all('.', quiet = TRUE)
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else file.path(tempdir(), 'fair-score-refit')
dir.create(out, recursive = TRUE, showWarnings = FALSE)
files <- c(list.files('R',pattern='[.]R$',full.names=TRUE),
  'inst/validation/fair-score-refit-0.2.4.R','inst/validation/fair-score-refit-protocol-0.2.4.md',
  'inst/validation/mml-independent-information-conditions-0.2.4.R')
source_hash <- tools::md5sum(files)

# Independent softmax and analytic gradient, including ALL threshold coordinates.
fair_reference <- function(par, x, model, j) {
  steps <- if (model == 'RSM') x$step_map else if (j <= 3L) {
    (x$step_map[1:2, ] + x$step_map[3:4, ]) / 2
  } else x$step_map[(2*(j-4)+1):(2*(j-4)+2), ]
  cumulative <- rbind(0, apply(steps, 2, cumsum))
  lp_map <- outer(0:2, -x$facet_map[j, ]) - cumulative
  lp <- as.vector(lp_map %*% par)
  prob <- exp(lp - max(lp)); prob <- prob / sum(prob)
  value <- sum((0:2) * prob)
  list(value = value, gradient = colSums(lp_map * (prob * ((0:2)-value))),
       variance = sum(prob * ((0:2)-value)^2))
}

results <- runs <- high_checks <- drawings <- list()
for (mi in 1:2) for (replicate in 1:20) {
  model <- c('RSM', 'PCM')[mi]
  seed <- 72000000L + 10000L*mi + replicate
  x <- mml_information_fixture(model, 'baseline', 3L, seed, 80L, 6L)
  warnings <- character(); started <- proc.time()[['elapsed']]
  ready <- FALSE; covariance_status <- 'not_computed'; fit <- NULL
  error <- tryCatch(withCallingHandlers({
    fit_args <- list(data=x$data, person='Person', facets=c('Rater','Criterion'),
      score='Score', model=model, method='MML', step_facet=if(model=='PCM') 'Criterion' else NULL,
      rating_min=0, rating_max=2, quad_points=61L, maxit=200L, reltol=1e-10)
    fit <- do.call(fit_mfrm, fit_args)
    ready <- mfrmr:::mfrm_inference_ready(fit)
    covariance <- mfrmr:::compute_mml_parameter_covariance(fit)
    covariance_status <- covariance$status
    fa <- fair_average_table(fit)
    conditional <- plot_fair_average(fit, metric='FairZ', show_ci=TRUE, draw=FALSE)$data$data
    for (j in 1:5) {
      facet <- if(j<=3) 'Rater' else 'Criterion'
      level <- if(j<=3) paste0('R',j) else paste0('C',j-3)
      key <- paste(facet, level, sep=':')
      actual <- fair_reference(fit$opt$par, x, model, j)
      truth <- fair_reference(x$truth, x, model, j)$value
      numerical <- mfrmr:::finite_difference_gradient(function(p) fair_reference(p,x,model,j)$value, fit$opt$par)
      stopifnot(max(abs(numerical-actual$gradient)) < 1e-7)
      tbl <- fa$raw_by_facet[[facet]]
      stopifnot(abs(tbl$FairZ[match(level,tbl$Level)]-actual$value)<1e-9)
      joint_se <- if (identical(covariance_status,'ok')) sqrt(as.numeric(t(actual$gradient) %*% covariance$cov %*% actual$gradient)) else NA_real_
      at <- which(conditional$Facet==facet & conditional$Level==level)
      focal_se <- conditional$CI_SE[at]
      if (identical(covariance_status,'ok')) stopifnot(abs(focal_se-actual$variance*sqrt(as.numeric(x$facet_map[j,,drop=FALSE] %*% covariance$cov %*% x$facet_map[j,])))<1e-8)
      for (method in c('conditional_measure','joint_structural_candidate')) {
        se <- if(method=='conditional_measure') focal_se else joint_se
        available <- ready && identical(covariance_status,'ok') && is.finite(se) && se>0
        lower <- if(available) max(0,actual$value-qnorm(.975)*se) else NA_real_
        upper <- if(available) min(2,actual$value+qnorm(.975)*se) else NA_real_
        results[[length(results)+1L]] <- data.frame(Model=model, Replicate=replicate,
          Seed=seed, Target=key, Method=method, Truth=truth, Estimate=actual$value,
          SE=se, Lower=lower, Upper=upper, Available=available,
          Covered=if(available) lower<=truth && upper>=truth else NA)
      }
    }
    if (replicate==1L) {
      fit_args$quad_points <- 121L
      high <- do.call(fit_mfrm, fit_args)
      hc <- mfrmr:::compute_mml_parameter_covariance(high)
      differences <- lapply(1:5,function(j) {
        a <- fair_reference(fit$opt$par,x,model,j); b <- fair_reference(high$opt$par,x,model,j)
        sa <- sqrt(as.numeric(t(a$gradient)%*%covariance$cov%*%a$gradient))
        sb <- sqrt(as.numeric(t(b$gradient)%*%hc$cov%*%b$gradient))
        data.frame(Model=model, Target=rownames(x$facet_map)[j], ScoreChange=b$value-a$value,
          RelativeSEChange=sb/sa-1, MaxEndpointChange=max(abs(
            pmin(2,pmax(0,b$value+c(-1,1)*qnorm(.975)*sb))-
            pmin(2,pmax(0,a$value+c(-1,1)*qnorm(.975)*sa)))),
          MaxParameterChange=max(abs(high$opt$par-fit$opt$par)),
          MaxPersonEAPChange=max(abs(high$facets$person$Estimate-fit$facets$person$Estimate)),
          HighReady=mfrmr:::mfrm_inference_ready(high), HighCovariance=hc$status)
      })
      high_checks[[mi]] <- do.call(rbind,differences)
      saveRDS(list(data=x$data,fit=fit,high=high),file.path(out,paste0(model,'-refits.rds')))
      dx <- diagnose_mfrm(fit,residual_pca='none')
      for (type in c('measure','scatter','difference')) for (preset in c('publication','monochrome')) {
        plot_args <- list(x=if(preset=='publication') fit else fa, diagnostics=dx,
          facet='Person',metric='FairZ',plot_type=type,top_n=20,show_ci=preset=='publication',
          preset=preset,show_title=preset=='publication',show_notes=preset=='publication')
        p <- do.call(plot_fair_average,c(plot_args,list(draw=FALSE)))
        saveRDS(p,file.path(out,paste(model,type,preset,'payload.rds',sep='-')))
        for (engine in c('base','ggplot')) for (device in c('png','pdf')) {
          file <- paste0(paste(model,type,preset,engine,sep='-'),'.',device)
          if(device=='png') png(file.path(out,file),width=8,height=6,units='in',res=130)
          else pdf(file.path(out,file),width=8,height=6)
          draw_warning <- character()
          draw_error <- tryCatch(withCallingHandlers({
            if(engine=='base') stopifnot(identical(p,do.call(plot_fair_average,plot_args)))
            else print(as_ggplot(p))
            ''
          },warning=function(w){draw_warning <<- c(draw_warning,conditionMessage(w));invokeRestart('muffleWarning')}),error=function(e)conditionMessage(e))
          dev.off()
          drawings[[length(drawings)+1L]] <- data.frame(File=file,Error=draw_error,Warnings=paste(draw_warning,collapse=' | '))
        }
      }
    }
    ''
  },warning=function(w){warnings <<- c(warnings,conditionMessage(w));invokeRestart('muffleWarning')}),error=function(e)conditionMessage(e))
  runs[[length(runs)+1L]] <- data.frame(Model=model,Replicate=replicate,Seed=seed,
    Ready=ready,Covariance=covariance_status,Error=error,Warnings=paste(warnings,collapse=' | '),
    Seconds=proc.time()[['elapsed']]-started)
  if(nzchar(error)) saveRDS(list(data=x$data,fit=fit,error=error),file.path(out,paste0(model,'-',replicate,'-failure.rds')))
  cat(model,replicate,'error:',error,'\n'); flush.console()
}
runs <- do.call(rbind,runs); results <- do.call(rbind,results)
summary <- do.call(rbind,lapply(split(results,list(results$Model,results$Target,results$Method),drop=TRUE),function(d) {
  use <- d[d$Available,]; n <- nrow(use); err <- use$Estimate-use$Truth
  ci <- if(n) binom.test(sum(use$Covered),n)$conf.int else c(NA,NA)
  data.frame(Model=d$Model[1],Target=d$Target[1],Method=d$Method[1],Assigned=20,
    Available=n,Availability=n/20,Bias=if(n) mean(err) else NA, EmpiricalSD=if(n>1) sd(err) else NA,
    RMSSE=if(n) sqrt(mean(use$SE^2)) else NA,
    SERatio=if(n>1) sqrt(mean(use$SE^2))/sd(err) else NA,
    Coverage=if(n) mean(use$Covered) else NA,CoverageLower=ci[1],CoverageUpper=ci[2],
    MeanWidth=if(n) mean(use$Upper-use$Lower) else NA,
    CoveredPerAssigned=sum(use$Covered)/20)
}))
high_checks <- do.call(rbind,high_checks); drawings <- do.call(rbind,drawings)
for (name in c('runs','results','summary','high_checks','drawings')) write.csv(get(name),file.path(out,paste0(name,'.csv')),row.names=FALSE)
write.csv(data.frame(File=files,MD5=unname(source_hash)),file.path(out,'source-md5.csv'),row.names=FALSE)
writeLines(capture.output(sessionInfo()),file.path(out,'session-info.txt'))
stopifnot(identical(source_hash,tools::md5sum(files)),
  nrow(runs)==40L,all(runs$Error==''),nrow(results)==400L,
  all(high_checks$HighReady),all(high_checks$HighCovariance=='ok'),
  max(abs(high_checks$ScoreChange))<=1e-5,max(high_checks$MaxEndpointChange)<=1e-5,
  max(abs(high_checks$RelativeSEChange))<=.001,
  nrow(drawings)==48L,all(drawings$Error==''),all(drawings$Warnings==''))
print(summary)
