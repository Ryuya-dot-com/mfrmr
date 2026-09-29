# Prespecified paired comparison. See matching .md before execution.
# Rscript <this-file> worker FIRST LAST | summary
source('inst/validation/jml-profile-bias-sample-20260927.R')
out <- 'validation-results/jml-sample-comparison-20260927'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
args <- commandArgs(trailingOnly=TRUE)
paths <- c('inst/validation/jml-sample-comparison-20260927.md',
  'inst/validation/jml-sample-comparison-20260927.R',
  'inst/validation/jml-profile-bias-exact-20260927.R',
  'inst/validation/jml-profile-bias-sample-20260927.R',
  'validation-results/jml-profile-bias-roots-20260927/resolved-roots.csv')
hashes <- function() vapply(paths,function(f) digest::digest(file=f,algo='sha256'),character(1))
original_hash <- hashes()
p <- make_jml_exact_problem('Criterion',2)
truth_mass <- drop(p$mass(p$truth,c(-1,0,1)) %*% c(.25,.5,.25))
N <- 400L; planned <- 200L
starts <- list(neutral=c(0,0,-.8,-.8,0),opposing=c(-.3,.4,-.3,-1.1,-.25))
population <- read.csv(paths[5])
population <- population[population$Owner=='Criterion' & population$Ratings==8 &
  population$Start=='neutral',]

fit_sample <- function(weights, adjusted) {
  attempts <- list(); selected <- list()
  for(start in names(starts)) {
    fit <- tryCatch(jml_sample_root(p,weights,adjusted,starts[[start]]),
      error=function(e) list(reviewed=FALSE,error=conditionMessage(e)))
    attempts[[start]] <- fit
    if(adjusted && !fit$reviewed) {
      fit <- tryCatch(jml_sample_root(p,weights,TRUE,starts[[start]],
        method='Newton',global='dbldog'),
        error=function(e) list(reviewed=FALSE,error=conditionMessage(e)))
      attempts[[paste0(start,'_fallback')]] <- fit
    }
    selected[[start]] <- fit
  }
  available <- all(vapply(selected,`[[`,logical(1),'reviewed'))
  status <- if(available) 'roots_reviewed' else 'root_unavailable'
  if(available && max(abs(selected[[1]]$beta-selected[[2]]$beta))>=1e-6) {
    available <- FALSE; status <- 'roots_disagree'
  }
  covariance <- NULL; beta <- rep(NA_real_,5); se <- beta; error <- NA_character_
  point_available <- available
  if(available) {
    beta <- selected[[1]]$beta
    covariance <- tryCatch(jml_sample_covariance(p,weights,N,beta,adjusted,selected[[1]]$A),
      error=function(e) list(error=conditionMessage(e)))
    if(!is.null(covariance$error)) {
      available <- FALSE; status <- 'covariance_unavailable'; error <- covariance$error
    } else {
      se <- sqrt(diag(covariance$vcov))
      available <- all(is.finite(se) & se>0)
      status <- if(available) 'available' else 'se_unavailable'
      covariance <- covariance[c('vcov','meat','mean')]
    }
  }
  list(point_available=point_available,available=available,status=status,beta=beta,se=se,
    covariance=covariance,attempts=attempts,error=error,
    fallback=sum(grepl('_fallback$',names(attempts))))
}

if(identical(args[1],'worker')) {
  first <- as.integer(args[2]); last <- as.integer(args[3])
  stopifnot(first>=1,last<=planned,first<=last,abs(sum(truth_mass)-1)<1e-12)
  for(id in first:last) {
    path <- file.path(out,sprintf('rep-%03d.rds',id))
    if(file.exists(path)) stop('Refusing to overwrite a planned replicate: ',id)
    set.seed(27100000L+id)
    counts <- tabulate(sample.int(p$n,N,replace=TRUE,prob=truth_mass),nbins=p$n)
    weights <- counts/N
    elapsed <- system.time({
      fit <- list(raw=fit_sample(weights,FALSE),one_step=fit_sample(weights,TRUE))
    })[['elapsed']]
    saveRDS(list(id=id,seed=27100000L+id,counts=counts,fit=fit,seconds=elapsed,
      source_hash=original_hash),path)
    cat(id,'raw',fit$raw$status,'adjusted',fit$one_step$status,'seconds',elapsed,'\n')
    flush.console()
  }
  stopifnot(identical(original_hash,hashes()))
  write.csv(data.frame(Path=paths,SHA256=unname(original_hash)),
    file.path(out,paste0('sources-',first,'-',last,'.csv')),row.names=FALSE)
  writeLines(capture.output(sessionInfo()),file.path(out,paste0('session-',first,'-',last,'.txt')))
} else if(identical(args[1],'summary')) {
  files <- file.path(out,sprintf('rep-%03d.rds',seq_len(planned)))
  stopifnot(all(file.exists(files)))
  records <- lapply(files,readRDS)
  stopifnot(identical(vapply(records,`[[`,integer(1),'id'),seq_len(planned)),
    all(vapply(records,function(z) identical(z$source_hash,original_hash),logical(1))))
  rows <- do.call(rbind,lapply(records,function(z) do.call(rbind,lapply(names(z$fit),function(method) {
    f <- z$fit[[method]]
    root <- as.numeric(population[population$Method==method,
      c('Rater','Criterion','Step1','Step2','LogSlope')])
    data.frame(Replicate=z$id,Method=method,Parameter=names(p$truth),
      PointAvailable=f$point_available,IntervalAvailable=f$available,Status=f$status,
      Estimate=f$beta,SE=f$se,Truth=unname(p$truth),PopulationRoot=root,
      Lower=if(f$available) f$beta-qnorm(.975)*f$se else NA_real_,
      Upper=if(f$available) f$beta+qnorm(.975)*f$se else NA_real_,Fallbacks=f$fallback)
  }))))
  wilson <- function(k,n) {
    if(!n) return(c(NA_real_,NA_real_))
    z <- qnorm(.975); a <- (k+z*z/2)/(n+z*z)
    b <- z*sqrt(k*(n-k)/n+z*z/4)/(n+z*z)
    c(a-b,a+b)
  }
  summarize <- function(x) {
    point <- x[x$PointAvailable,]; interval <- x[x$IntervalAvailable,]
    err <- point$Estimate-point$Truth
    covered <- interval$Lower<=interval$Truth & interval$Upper>=interval$Truth
    root_covered <- interval$Lower<=interval$PopulationRoot & interval$Upper>=interval$PopulationRoot
    bounds <- wilson(sum(covered),nrow(interval)); rb <- wilson(sum(root_covered),nrow(interval))
    # Empty or singleton groups remain unavailable, not zero error/coverage.
    avg <- function(v) if(length(v)) mean(v) else NA_real_
    data.frame(Method=x$Method[1],Parameter=x$Parameter[1],Attempted=nrow(x),
      PointAvailable=nrow(point),IntervalAvailable=nrow(interval),
      Availability=nrow(interval)/nrow(x),Bias=avg(err),BiasMCSE=sd(err)/sqrt(length(err)),
      RMSE=sqrt(avg(err^2)),EmpiricalSD=sd(interval$Estimate),
      RootMeanVariance=sqrt(avg(interval$SE^2)),
      SD_to_SE=sd(interval$Estimate)/sqrt(avg(interval$SE^2)),
      MeanWidth=avg(interval$Upper-interval$Lower),
      TruthCoverage=avg(covered),TruthCoverageLow=bounds[1],TruthCoverageHigh=bounds[2],
      RootCoverage=avg(root_covered),RootCoverageLow=rb[1],RootCoverageHigh=rb[2],
      DeliveryAndTruthInclusion=sum(covered)/nrow(x),
      TruthBelow=sum(interval$Lower>interval$Truth),TruthAbove=sum(interval$Upper<interval$Truth))
  }
  summary <- do.call(rbind,lapply(split(rows,interaction(rows$Method,rows$Parameter)),summarize))
  paired <- do.call(rbind,lapply(names(p$truth),function(parameter) {
    a <- rows[rows$Method=='one_step' & rows$Parameter==parameter,]
    b <- rows[rows$Method=='raw' & rows$Parameter==parameter,]
    stopifnot(identical(a$Replicate,b$Replicate))
    ok <- a$PointAvailable & b$PointAvailable
    d <- (a$Estimate[ok]-a$Truth[ok])^2-(b$Estimate[ok]-b$Truth[ok])^2
    se <- sd(d)/sqrt(length(d)); delta <- if(length(d)) mean(d) else NA_real_
    data.frame(Parameter=parameter,Paired=length(d),Attempted=planned,
      AdjustedMinusRawMSE=delta,PairedMCSE=se,
      MonteCarloLow=delta-qnorm(.975)*se,MonteCarloHigh=delta+qnorm(.975)*se)
  }))
  write.csv(rows,file.path(out,'rows.csv'),row.names=FALSE)
  write.csv(summary,file.path(out,'summary.csv'),row.names=FALSE)
  write.csv(paired,file.path(out,'paired.csv'),row.names=FALSE)
  status <- rows[rows$Parameter=='LogSlope',c('Replicate','Method','Status','Fallbacks')]
  write.csv(status,file.path(out,'dispositions.csv'),row.names=FALSE)
  writeLines(capture.output(sessionInfo()),file.path(out,'summary-session.txt'))
  print(summary[summary$Parameter=='LogSlope',],row.names=FALSE)
  print(paired[paired$Parameter=='LogSlope',],row.names=FALSE)
  cat('Attempted datasets:',planned,'; total worker seconds:',sum(vapply(records,`[[`,numeric(1),'seconds')),'\n')
} else stop('Choose worker FIRST LAST or summary.')
