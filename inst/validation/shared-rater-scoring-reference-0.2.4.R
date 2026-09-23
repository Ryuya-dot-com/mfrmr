# Fixed-calibration numerical comparison. Run init, then run, then summarize.
.libPaths(c(normalizePath('.r-library'), .libPaths()))
pkgload::load_all('.', quiet = TRUE)
prefix <- 'inst/validation/shared-rater-scoring-reference-0.2.4'
out <- 'validation-results/shared-rater-scoring-reference-20260923'
original <- 'validation-results/estimated-model-qualification-20260923'
refined <- 'validation-results/shared-rater-integration-20260923'
mode <- commandArgs(TRUE)[1]
dir.create(out, recursive = TRUE, showWarnings = FALSE)
plan_path <- file.path(out, 'plan.rds')
if (identical(mode, 'init')) {
  stopifnot(!file.exists(plan_path))
  ids <- c(1L,201L,401L,601L,141L,340L,455L,742L,1L,201L,401L,601L)
  records <- lapply(seq_along(ids), function(i) {
    path <- file.path(original, sprintf('trial-%04d.rds', ids[i])); x <- readRDS(path)
    fit_path <- if (i %in% 5:8) file.path(refined, sprintf('refit-%04d.rds', ids[i])) else path
    fit <- if (i %in% 5:8) readRDS(fit_path) else x$fits$shared
    stopifnot(isTRUE(fit$checks$NumericalReady), isTRUE(fit$checks$InformationPositive),
      fit$calibration$rater_sd > 0, fit$calibration$person_sd > 0)
    data <- x$data
    if (i >= 9) data <- subset(data, Person %in% sprintf('P%03d', c(1:24,121:144)) & Criterion == 'C1')
    total <- tapply(data$Score, data$Person, sum); total <- total[!names(total) %in% c('P001','P121')]
    persons <- c('P001','P121',names(total)[order(total,names(total))[1]],
      names(total)[order(-total,names(total))[1]])
    stopifnot(length(unique(persons)) == 4)
    input <- mfrm_random_rater_data(data,'Person','Rater','Criterion','Score',0:2, reference=fit$input)
    stan_data <- list(P=length(input$levels$Person), R=length(input$levels$Rater), K=3L,
      N=length(input$y), person=input$person, rater=input$rater, y=input$y+1L,
      facet_offset=drop(input$X %*% fit$calibration$beta), step=fit$calibration$steps,
      person_sd=fit$calibration$person_sd, rater_sd=fit$calibration$rater_sd)
    list(index=i, trial=ids[i], condition=x$roster$Condition, roster=if(i>=9) 'reduced' else 'full',
      source=tools::md5sum(unique(c(path,fit_path))), fit=fit, data=data, input=input,
      persons=persons, stan_data=stan_data, seed=92328000L+i)
  })
  files <- c(sort(list.files('R', pattern='[.]R$', full.names=TRUE)),
    paste0(prefix,c('.R','.md','.stan')), 'DESCRIPTION','NAMESPACE')
  plan <- list(records=records, source=tools::md5sum(files), created=Sys.time(), session=sessionInfo(),
    settings=list(chains=4L, parallel_chains=4L, iter_warmup=2000L, iter_sampling=8000L,
      adapt_delta=.9, max_treedepth=10L, metric='diag_e', init=2, sig_figs=18L,
      refresh=2000L, save_warmup=FALSE))
  saveRDS(plan, plan_path)
  for (f in files) {
    dst <- file.path(out,'source',f); dir.create(dirname(dst), recursive=TRUE, showWarnings=FALSE)
    stopifnot(file.copy(f,dst))
  }
  stopifnot(file.copy(paste0(prefix,'.stan'),file.path(out,'reference.stan'),overwrite=TRUE))
  cat('Frozen twelve scoring rosters and 48 requested Persons.\n')
  quit(status=0)
}
plan <- readRDS(plan_path)
# Summaries can be repaired without replacing sampling or scoring artifacts.
stopifnot(identical(unname(plan$source),unname(tools::md5sum(
  file.path(out,'source',names(plan$source))))))
joint_difference <- function(draws,d) {
  raw <- unclass(draws)
  direct <- function(a) {
    theta <- a[paste0('theta[',seq_len(d$P),']')]
    u <- a[paste0('severity[',seq_len(d$R),']')]
    eta <- theta[d$person]-u[d$rater]-d$facet_offset
    lp <- outer(eta,0:(d$K-1)) - matrix(c(0,cumsum(d$step)),d$N,d$K,byrow=TRUE)
    shift <- apply(lp,1,max)
    sum(lp[cbind(seq_len(d$N),d$y)]-shift-log(rowSums(exp(lp-shift)))) +
      sum(dnorm(theta,sd=d$person_sd,log=TRUE)) + sum(dnorm(u,sd=d$rater_sd,log=TRUE))
  }
  unlist(lapply(1:4,function(chain) vapply(1:10,function(i)
    direct(raw[i,chain,])-raw[i,chain,'log_joint'],numeric(1))))
}
if (identical(mode,'run')) {
  stopifnot(identical(plan$source,tools::md5sum(names(plan$source))))
  stopifnot(unname(tools::md5sum(file.path(out,'reference.stan'))) ==
    unname(plan$source[paste0(prefix,'.stan')]))
  model <- cmdstanr::cmdstan_model(file.path(out,'reference.stan'),
    cpp_options=list(PRECOMPILED_HEADERS='false'))
  started <- Sys.time()
  for (rec in plan$records) {
    path <- file.path(out,sprintf('case-%02d.rds',rec$index))
    if (file.exists(path)) next
    stopifnot(identical(rec$source,tools::md5sum(names(rec$source))))
    directory <- file.path(out,sprintf('case-%02d',rec$index))
    dir.create(directory,showWarnings=FALSE)
    marker <- file.path(directory,'started.rds')
    fit_path <- file.path(directory,'sampling.rds')
    if (file.exists(marker) && !file.exists(fit_path)) stop('Incomplete saved sampling: review, do not replace.')
    timing <- system.time({
      if (!file.exists(fit_path)) {
        saveRDS(list(started=Sys.time(),index=rec$index),marker)
        sample <- do.call(model$sample,c(list(data=rec$stan_data, seed=rec$seed,
          output_dir=normalizePath(directory),output_basename='reference'),plan$settings))
        sample$save_object(fit_path)
      } else sample <- readRDS(fit_path)
      draws <- unclass(sample$draws(c('theta','severity','log_joint'),format='draws_array'))
      diagnostic <- sample$summary(c('theta','severity'))
      sampler <- sample$diagnostic_summary()
      reference_ready <- all(sample$return_codes()==0) &&
        identical(dim(draws)[1:2],c(8000L,4L)) &&
        all(is.finite(diagnostic$rhat) & diagnostic$rhat < 1.01 &
          diagnostic$ess_bulk >= 400 & diagnostic$ess_tail >= 400) &&
        all(sampler$num_divergent==0 & sampler$num_max_treedepth==0 &
          is.finite(sampler$ebfmi) & sampler$ebfmi >= .3)
      identity <- joint_difference(draws,rec$stan_data)
      error <- warning <- character()
      scores <- tryCatch(withCallingHandlers(score_mfrm_random_rater(rec$fit,
        newdata=rec$data,persons=rec$persons,quad_points=121),warning=function(w) {
          warning <<- c(warning,conditionMessage(w)); invokeRestart('muffleWarning')
        }),error=function(e) {error <<- conditionMessage(e);NULL})
    })
    result <- list(index=rec$index, trial=rec$trial, roster=rec$roster, draws=draws,
      diagnostic=diagnostic, sampler=sampler, sampler_diagnostics=sample$sampler_diagnostics(),
      return_codes=sample$return_codes(), reference_ready=reference_ready,
      log_joint_difference=identity, scores=scores, errors=error, warnings=warning,
      seconds=timing[['elapsed']], csv_hashes=tools::md5sum(sample$output_files()))
    saveRDS(result,path)
    stopifnot(identical(result,readRDS(path)))
    cat('Case',rec$index,'trial',rec$trial,rec$roster,'reference ready',reference_ready,
      'scores',if(is.null(scores)) 'error' else paste(scores$table$Status,collapse=','),
      'seconds',timing[['elapsed']],'\n');flush.console()
    if (as.numeric(difftime(Sys.time(),started,units='mins'))>60) stop('Time budget reached; retain incomplete cases.')
    bytes <- sum(file.info(list.files(out,recursive=TRUE,full.names=TRUE))$size,na.rm=TRUE)
    if (bytes > 3*1024^3) stop('Archive budget reached; retain incomplete cases.')
    gc()
  }
} else if (identical(mode,'summarize')) {
  comparisons <- masses <- status <- list()
  for (rec in plan$records) {
    path <- file.path(out,sprintf('case-%02d.rds',rec$index)); stopifnot(file.exists(path))
    x <- readRDS(path)
    x$draws <- unclass(x$draws)
    # Original failed audit values remain in the unchanged case archive.
    identity <- joint_difference(x$draws,rec$stan_data)
    stopifnot(identical(x$index,rec$index),all(is.finite(identity)),max(abs(identity))<1e-8)
    status[[length(status)+1L]] <- data.frame(Case=rec$index,Trial=rec$trial,Roster=rec$roster,
      Raters=rec$stan_data$R,Persons=rec$stan_data$P,Responses=rec$stan_data$N,
      ReferenceReady=x$reference_ready,MaxRhat=max(x$diagnostic$rhat),
      MinBulkESS=min(x$diagnostic$ess_bulk),MinTailESS=min(x$diagnostic$ess_tail),
      OriginalLogJointCheckAvailable=all(is.finite(x$log_joint_difference)),
      MaxLogJointError=max(abs(identity)),Seconds=x$seconds)
    for (person in rec$persons) {
      k <- match(person,rec$input$levels$Person); q <- x$draws[,,paste0('theta[',k,']')]
      value <- c(Estimate=mean(q),ConditionalSD=sd(as.vector(q)),
        Lower=unname(quantile(q,.025)),Upper=unname(quantile(q,.975)))
      mcse <- c(posterior::mcse_mean(q),posterior::mcse_sd(q),posterior::mcse_quantile(q,c(.025,.975)))
      a <- if (!is.null(x$scores)) x$scores$table[x$scores$table$Person==person,] else NULL
      available <- !is.null(a) && identical(a$Status,'available_conditional')
      actual <- if (available) unlist(a[names(value)],use.names=FALSE) else rep(NA_real_,4)
      tolerance <- c(.05,.05,.1,.1); precision <- is.finite(mcse) & mcse <= c(.01,.01,.02,.02)
      error <- abs(actual-value); upper <- error+4*mcse; lower <- pmax(0,error-4*mcse)
      decision <- if (!x$reference_ready) rep('reference_unresolved',4) else
        if (!available) rep('score_unavailable',4) else
        ifelse(!precision,'mc_precision_unresolved',ifelse(upper<=tolerance,'bounded_agreement',
          ifelse(lower>tolerance,'material_discrepancy','inconclusive')))
      comparisons[[length(comparisons)+1L]] <- data.frame(Case=rec$index,Trial=rec$trial,
        Roster=rec$roster,Person=person,Quantity=names(value),Laplace=actual,Reference=value,
        MCSE=mcse,AbsoluteError=error,ErrorUpper=upper,Tolerance=tolerance,Decision=decision,row.names=NULL)
      indicator <- if(available) (q>=a$Lower & q<=a$Upper)*1 else q*NA_real_
      masses[[length(masses)+1L]] <- data.frame(Case=rec$index,Person=person,
        Roster=rec$roster,Mass=mean(indicator),MCSE=posterior::mcse_mean(indicator))
    }
  }
  comparisons <- do.call(rbind,comparisons); masses <- do.call(rbind,masses);status <- do.call(rbind,status)
  stopifnot(nrow(comparisons)==192,nrow(masses)==48,nrow(status)==12)
  for(n in c('comparisons','masses','status')) write.csv(get(n),file.path(out,paste0(n,'.csv')),row.names=FALSE)
  saveRDS(list(comparisons=comparisons,masses=masses,status=status,source=plan$source,
    summary_source=tools::md5sum(paste0(prefix,'.R'))),file.path(out,'summary.rds'))
  print(status,row.names=FALSE);print(table(comparisons$Roster,comparisons$Decision))
  print(aggregate(cbind(AbsoluteError,ErrorUpper,MCSE)~Roster+Quantity,comparisons,max),row.names=FALSE)
  print(aggregate(Mass~Roster,masses,range),row.names=FALSE)
} else stop('Use init, run or summarize.')
