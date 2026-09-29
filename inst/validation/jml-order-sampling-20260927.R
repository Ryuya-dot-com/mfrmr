# Research study; see companion protocol before execution.
# Rscript <file> worker CONDITION FIRST LAST | summary
source('inst/validation/jml-design-adjustment-20260927.R')
source('inst/validation/jml-total-expectation-20260927.R')
out <- 'validation-results/jml-order-sampling-20260927'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
planned <- 200L; N <- 400L
conditions <- list(
  list(owner='Criterion',design='unequal',exposure=list(c(2,1,0,1),c(0,2,2,2)),
    proportions=c(.6,.4),ability=list(c(0,1,2),c(-2,-1,0))),
  list(owner='Rater',design='sparse',exposure=list(c(2,1,0,2),c(0,2,2,1)),
    proportions=c(.5,.5),ability=list(c(-2,-1,0),c(0,1,2))))
starts <- list(neutral=c(0,0,-.8,-.8,0),opposing=c(-.3,.4,-.3,-1.1,-.25))
paths <- c('inst/validation/jml-order-sampling-20260927.R',
  'inst/validation/jml-order-sampling-20260927.md',
  'inst/validation/jml-design-adjustment-20260927.R',
  'inst/validation/jml-total-expectation-20260927.R',
  'inst/validation/jml-profile-bias-sample-20260927.R',
  'inst/validation/jml-profile-bias-exact-20260927.R',
  'validation-results/jml-scope-challenge-20260927/parameters.csv')
hashes <- function() tools::md5sum(paths)
original_hash <- hashes()

fit_order <- function(ps,weights,proportions,k) {
  eq <- make_jml_design_equation(ps,weights,proportions,k)
  attempts <- lapply(starts,function(start) {
    record <- jml_design_root(eq,k,start)
    if(!isTRUE(record$fit$reviewed)) {
      record$small_step <- tryCatch({
        z <- nleqslv::nleqslv(start,eq$mean_score,method='Newton',global='dbldog',
          control=list(ftol=1e-10,xtol=1e-11,maxit=150,stepmax=.25))
        A <- jml_sample_jacobian(eq$mean_score,z$x,5e-5)
        A1 <- jml_sample_jacobian(eq$mean_score,z$x,1e-4)
        residual <- max(abs(eq$mean_score(z$x)))
        singular <- min(svd(A,nu=0,nv=0)$d)
        error <- max(abs(A1-A))/max(1,max(abs(A)))
        list(beta=z$x,A=A,solver=z,residual=residual,min_singular=singular,
          jacobian_error=error,reviewed=residual<1e-7 && singular>1e-6 && error<1e-5)
      },error=function(e) list(reviewed=FALSE,error=conditionMessage(e)))
      record$fit <- record$small_step
    }
    record
  })
  fits <- lapply(attempts,`[[`,'fit')
  point <- all(vapply(fits,function(f)isTRUE(f$reviewed),logical(1)))
  status <- if(point) 'roots_reviewed' else 'root_unavailable'
  spread <- if(point) max(abs(fits[[1]]$beta-fits[[2]]$beta)) else NA_real_
  if(point && spread>=1e-6) { point <- FALSE; status <- 'roots_disagree' }
  beta <- se <- rep(NA_real_,5); covariance <- NULL; available <- FALSE
  if(point) {
    beta <- fits[[1]]$beta
    covariance <- tryCatch(jml_design_covariance(eq,beta,N,fits[[1]]$A,'fixed_rosters'),
      error=function(e)list(error=conditionMessage(e)))
    if(is.null(covariance$error)) {
      se <- sqrt(diag(covariance$vcov))
      available <- all(is.finite(se) & se>0)
      status <- if(available) 'available' else 'se_unavailable'
      covariance <- covariance[c('vcov','meat','means','global','sampling')]
    } else status <- 'covariance_unavailable'
  }
  list(point_available=point,available=available,status=status,beta=beta,se=se,
    covariance=covariance,attempts=attempts,spread=spread,
    fallbacks=sum(vapply(attempts,function(a)length(a$attempts)>1L ||
      !is.null(a$small_step),logical(1))))
}

wilson <- function(k,n) {
  if(!n) return(c(NA_real_,NA_real_))
  z <- qnorm(.975); a <- (k+z*z/2)/(n+z*z)
  b <- z*sqrt(k*(n-k)/n+z*z/4)/(n+z*z)
  c(a-b,a+b)
}

args <- commandArgs(trailingOnly=TRUE)
if(identical(args[1],'worker')) {
  condition <- as.integer(args[2]); first <- as.integer(args[3]); last <- as.integer(args[4])
  stopifnot(condition %in% 1:2,first>=1,last<=planned,first<=last)
  d <- conditions[[condition]]
  reference <- lapply(d$exposure,function(e)make_jml_roster_problem(d$owner,e))
  truth <- reference[[1]]$truth
  ps <- lapply(reference,function(p)make_jml_total_problem(d$owner,p$exposure,p$counts))
  mass <- Map(function(p,a)drop(p$mass(truth,a)%*%c(.25,.5,.25)),reference,d$ability)
  stopifnot(all(vapply(mass,function(w)abs(sum(w)-1)<1e-12,logical(1))),
    all(N*d$proportions==round(N*d$proportions)))
  for(id in first:last) {
    path <- file.path(out,sprintf('case-%d-rep-%03d.rds',condition,id))
    if(file.exists(path)) stop('Refusing to overwrite ',path)
    seed <- 27300000L+1000L*condition+id
    set.seed(seed)
    counts <- lapply(seq_along(ps),function(i)tabulate(sample.int(ps[[i]]$n,
      N*d$proportions[i],replace=TRUE,prob=mass[[i]]),nbins=ps[[i]]$n))
    weights <- Map(function(x,p)x/(N*p),counts,d$proportions)
    elapsed <- system.time(fits <- lapply(c(2L,4L),function(k)
      fit_order(ps,weights,d$proportions,k)))[['elapsed']]
    names(fits) <- c('2','4')
    stopifnot(identical(original_hash,hashes()))
    record <- list(condition=condition,id=id,seed=seed,counts=counts,fit=fits,
      seconds=elapsed,source_hash=original_hash)
    saveRDS(record,paste0(path,'.tmp')); file.rename(paste0(path,'.tmp'),path)
    cat('Condition',condition,'replicate',id,'order2',fits[[1]]$status,
      'order4',fits[[2]]$status,'seconds',elapsed,'\n'); flush.console()
  }
  writeLines(capture.output(sessionInfo()),file.path(out,
    sprintf('session-%d-%d-%d.txt',condition,first,last)))
} else if(identical(args[1],'summary')) {
  population <- read.csv(tail(paths,1))
  files <- unlist(lapply(1:2,function(c)file.path(out,
    sprintf('case-%d-rep-%03d.rds',c,seq_len(planned)))))
  stopifnot(all(file.exists(files)))
  records <- lapply(files,readRDS)
  stopifnot(identical(vapply(records,`[[`,integer(1),'id'),rep(seq_len(planned),2)),
    identical(vapply(records,`[[`,integer(1),'condition'),rep(1:2,each=planned)),
    all(vapply(records,function(z)identical(z$source_hash,original_hash),logical(1))))
  rows <- do.call(rbind,lapply(records,function(z)do.call(rbind,lapply(names(z$fit),function(k) {
    d <- conditions[[z$condition]]; f <- z$fit[[k]]
    p <- population[population$Owner==d$owner & population$Design==d$design &
      population$Order==as.integer(k) & population$N==N,]
    stopifnot(nrow(p)==5L,identical(p$Parameter,c('Rater','Criterion','Step1','Step2','LogSlope')))
    data.frame(Condition=z$condition,Owner=d$owner,Design=d$design,Replicate=z$id,
      Order=as.integer(k),Parameter=p$Parameter,PointAvailable=f$point_available,
      IntervalAvailable=f$available,Status=f$status,Estimate=f$beta,SE=f$se,
      Truth=p$Truth,PopulationRoot=p$PopulationRoot,
      Lower=if(f$available) f$beta-qnorm(.975)*f$se else NA_real_,
      Upper=if(f$available) f$beta+qnorm(.975)*f$se else NA_real_,Fallbacks=f$fallbacks)
  }))))
  avg <- function(x)if(length(x))mean(x) else NA_real_
  summarize <- function(x) {
    point <- x[x$PointAvailable,]; interval <- x[x$IntervalAvailable,]
    err <- point$Estimate-point$Truth
    covered <- interval$Lower<=interval$Truth & interval$Upper>=interval$Truth
    root <- interval$Lower<=interval$PopulationRoot & interval$Upper>=interval$PopulationRoot
    ci <- wilson(sum(covered),length(covered)); ri <- wilson(sum(root),length(root))
    di <- wilson(sum(covered),nrow(x)); ai <- wilson(nrow(interval),nrow(x))
    data.frame(Condition=x$Condition[1],Owner=x$Owner[1],Design=x$Design[1],
      Order=x$Order[1],Parameter=x$Parameter[1],Attempted=nrow(x),
      PointAvailable=nrow(point),IntervalAvailable=nrow(interval),
      Availability=nrow(interval)/nrow(x),AvailabilityLow=ai[1],AvailabilityHigh=ai[2],
      Bias=avg(err),BiasMCSE=sd(err)/sqrt(length(err)),RMSE=sqrt(avg(err^2)),
      EmpiricalSD=sd(interval$Estimate),RootMeanVariance=sqrt(avg(interval$SE^2)),
      SD_to_SE=sd(interval$Estimate)/sqrt(avg(interval$SE^2)),
      MeanWidth=avg(interval$Upper-interval$Lower),TruthCoverage=avg(covered),
      TruthCoverageLow=ci[1],TruthCoverageHigh=ci[2],RootCoverage=avg(root),
      RootCoverageLow=ri[1],RootCoverageHigh=ri[2],
      DeliveryAndTruthInclusion=sum(covered)/nrow(x),DeliveryLow=di[1],DeliveryHigh=di[2],
      TruthBelow=sum(interval$Lower>interval$Truth),TruthAbove=sum(interval$Upper<interval$Truth))
  }
  summary <- do.call(rbind,lapply(split(rows,interaction(rows$Condition,rows$Order,
    rows$Parameter,drop=TRUE)),summarize))
  paired <- do.call(rbind,lapply(split(rows,interaction(rows$Condition,rows$Parameter,
    drop=TRUE)),function(x) {
    a <- x[x$Order==4,]; b <- x[x$Order==2,]
    stopifnot(identical(a$Replicate,b$Replicate))
    ok <- a$PointAvailable & b$PointAvailable
    d <- (a$Estimate[ok]-a$Truth[ok])^2-(b$Estimate[ok]-b$Truth[ok])^2
    delta <- avg(d); se <- sd(d)/sqrt(length(d))
    data.frame(Condition=x$Condition[1],Parameter=x$Parameter[1],Paired=sum(ok),
      Attempted=planned,Order4MinusOrder2MSE=delta,PairedMCSE=se,
      MonteCarloLow=delta-qnorm(.975)*se,MonteCarloHigh=delta+qnorm(.975)*se)
  }))
  write.csv(rows,file.path(out,'rows.csv'),row.names=FALSE)
  write.csv(summary,file.path(out,'summary.csv'),row.names=FALSE)
  write.csv(paired,file.path(out,'paired.csv'),row.names=FALSE)
  write.csv(rows[rows$Parameter=='LogSlope',c('Condition','Replicate','Order','Status','Fallbacks')],
    file.path(out,'dispositions.csv'),row.names=FALSE)
  write.csv(data.frame(Path=names(original_hash),MD5=unname(original_hash)),
    file.path(out,'sources.csv'),row.names=FALSE)
  print(summary[summary$Parameter=='LogSlope',],row.names=FALSE)
  print(paired[paired$Parameter=='LogSlope',],row.names=FALSE)
  cat('All datasets:',length(records),'; total worker seconds:',
    sum(vapply(records,`[[`,numeric(1),'seconds')),'\n')
} else stop('Choose worker CONDITION FIRST LAST or summary.')
