# Source after loading the checked package, from the development root.
source("inst/validation/person-interval-calibration-0.2.4.R")

ppr_populations <- function() list(
  normal=list(d=dnorm,r=rnorm,mean=0,variance=1,lower=-Inf),
  shifted=list(d=function(x) dnorm(x,0.75),r=function(n) rnorm(n,0.75),mean=0.75,variance=1,lower=-Inf),
  narrow=list(d=function(x) dnorm(x,sd=0.6),r=function(n) rnorm(n,sd=0.6),mean=0,variance=0.36,lower=-Inf),
  wide=list(d=function(x) dnorm(x,sd=1.5),r=function(n) rnorm(n,sd=1.5),mean=0,variance=2.25,lower=-Inf),
  skewed=list(d=function(x) sqrt(2)*dgamma(sqrt(2)*x+2,shape=2),
    r=function(n) (rgamma(n,shape=2)-2)/sqrt(2),mean=0,variance=1,lower=-sqrt(2)),
  bimodal=list(d=function(x) (dnorm(x,-sqrt(0.84),0.4)+dnorm(x,sqrt(0.84),0.4))/2,
    r=function(n) sample(c(-1,1),n,replace=TRUE)*sqrt(0.84)+rnorm(n,sd=0.4),mean=0,variance=1,lower=-Inf),
  heavy=list(d=function(x) dt(x/sqrt(3/5),df=5)/sqrt(3/5),
    r=function(n) rt(n,df=5)*sqrt(3/5),mean=0,variance=1,lower=-Inf))

ppr_total_probability <- function(design, theta) {
  logits <- sweep(outer(theta,0:(3*design$n)),2L,log(design$total0),"+")
  high <- logits[cbind(seq_along(theta),max.col(logits,ties.method="first"))]
  probability <- exp(logits-high)
  probability/rowSums(probability)
}

ppr_integrator <- function(density, support, tolerance) {
  function(lower,upper,power=0L) {
    lower <- max(lower,support)
    if (lower>=upper) return(c(value=0,error=0))
    cuts <- sort(unique(c(lower,c(-3,0,3)[c(-3,0,3)>lower & c(-3,0,3)<upper],upper)))
    parts <- vapply(seq_len(length(cuts)-1L),function(i) {
      x <- integrate(function(theta) density(theta)*theta^power,cuts[i],cuts[i+1L],
        rel.tol=tolerance,abs.tol=0,subdivisions=1000L)
      stopifnot(x$message=="OK",is.finite(x$value),is.finite(x$abs.error),
        x$abs.error<=1e-8*abs(x$value))
      c(value=x$value,error=x$abs.error)
    },c(value=0,error=0))
    rowSums(parts)
  }
}

ppr_self_check <- function() {
  rows <- list()
  for (model in c("RSM","PCM")) for (n in c(3L,6L,30L)) {
    d <- person_interval_design(model,n)
    for (theta in c(-4,-1,0,0.7,4)) {
      direct <- 1
      for (item in seq_len(n)) {
        next_total <- numeric(length(direct)+3L)
        for (k in 0:3) next_total[seq_along(direct)+k] <-
          next_total[seq_along(direct)+k]+direct*d$probability(theta,item)[k+1L]
        direct <- next_total
      }
      error <- max(abs(direct-as.vector(ppr_total_probability(d,theta))))
      stopifnot(error<1e-12)
      rows[[length(rows)+1L]] <- data.frame(Check="convolution",Model=model,Ratings=n,Value=theta,Error=error)
    }
  }
  for (name in names(ppr_populations())) {
    g <- ppr_populations()[[name]]
    integral <- ppr_integrator(g$d,g$lower,1e-11)
    moments <- vapply(0:2,function(k) integral(-Inf,Inf,k)[1L],0)
    error <- max(abs(moments-c(1,g$mean,g$mean^2+g$variance)))
    stopifnot(error<1e-8)
    rows[[length(rows)+1L]] <- data.frame(Check="population_moments",Model=name,Ratings=NA,Value=NA,Error=error)
  }
  do.call(rbind,rows)
}

ppr_cell <- function(design_id, distribution_id, intervals, tolerance=1e-9) {
  designs <- expand.grid(n=c(3L,6L,30L),model=c("RSM","PCM"),stringsAsFactors=FALSE)
  d <- person_interval_design(designs$model[design_id],designs$n[design_id])
  populations <- ppr_populations(); name <- names(populations)[distribution_id]; g <- populations[[distribution_id]]
  all <- intervals[intervals$Design==design_id & intervals$Level==0.95,]
  get <- function(mode,q) all[all$Integration==mode & all$Order==q,]
  methods <- list(normal_fixed31=get("fixed",31),normal_fixed121=get("fixed",121),
    normal_adaptive61=get("adaptive",61))
  primary <- methods[[1L]]
  stopifnot(identical(primary$Total,0:(3L*d$n)))
  for (x in methods) stopifnot(identical(x$Total,primary$Total),
    max(abs(x$Lower-primary$Lower),abs(x$Upper-primary$Upper))<1e-8)
  strata <- c(-Inf,-2,-1,0,1,2,Inf)
  profile <- stratum <- list()
  for (total in primary$Total) {
    row <- primary[total+1L,]
    integral <- ppr_integrator(function(theta) g$d(theta)*ppr_total_probability(d,theta)[,total+1L],
      g$lower,tolerance)
    moments <- vapply(0:2,function(k) integral(-Inf,Inf,k)[1L],0)
    mass <- moments[1L]; mean <- moments[2L]/mass; variance <- moments[3L]/mass-mean^2
    stopifnot(mass>0,variance>0)
    lower <- uniroot(function(x) integral(-Inf,x)[1L]/mass-0.025,c(-8,8),
      extendInt="upX",tol=1e-9,check.conv=TRUE)$root
    upper <- uniroot(function(x) integral(x,Inf)[1L]/mass-0.025,c(-8,8),
      extendInt="downX",tol=1e-9,check.conv=TRUE)$root
    oracle_covered <- integral(lower,upper)[1L]
    tail_error <- max(abs(c(integral(-Inf,lower)[1L],integral(upper,Inf)[1L])/mass-0.025))
    stopifnot(tail_error<1e-7)
    profile[[total+1L]] <- data.frame(Total=total,Probability=mass,FirstMoment=moments[2L],
      SecondMoment=moments[3L],EAP=mean,SD=sqrt(variance),Lower=lower,Upper=upper,
      NormalCovered=integral(row$Lower,row$Upper)[1L],OracleCovered=oracle_covered,TailError=tail_error)
    for (s in 1:6) {
      m <- vapply(0:2,function(k) integral(strata[s],strata[s+1L],k)[1L],0)
      stratum[[length(stratum)+1L]] <- data.frame(Total=total,Stratum=s,Probability=m[1L],
        FirstMoment=m[2L],SecondMoment=m[3L],
        NormalCovered=integral(max(strata[s],row$Lower),min(strata[s+1L],row$Upper))[1L],
        OracleCovered=integral(max(strata[s],lower),min(strata[s+1L],upper))[1L])
    }
  }
  profile <- do.call(rbind,profile); stratum <- do.call(rbind,stratum)
  stopifnot(abs(sum(profile$Probability)-1)<1e-8,
    abs(sum(profile$FirstMoment)-g$mean)<1e-8,
    abs(sum(profile$SecondMoment)-g$variance-g$mean^2)<1e-8,
    abs(sum(profile$OracleCovered)-0.95)<1e-7)
  if (name=="normal") {
    reference <- get("adaptive",61)
    stopifnot(max(abs(profile$EAP-(reference$EAP-reference$EAPError)),
      abs(profile$SD-(reference$SD-reference$SDError)),abs(profile$Lower-reference$OracleLower),
      abs(profile$Upper-reference$OracleUpper),abs(profile$Probability-reference$Probability))<1e-7)
  }
  methods$oracle <- profile
  summaries <- list()
  for (method in names(methods)) for (s in 0:6) {
    weights <- if (s==0) profile else stratum[stratum$Stratum==s,]
    x <- methods[[method]]; mass <- sum(weights$Probability)
    covered <- if (method=="oracle") weights$OracleCovered else weights$NormalCovered
    estimates <- c(Coverage=sum(covered),MeanWidth=sum(weights$Probability*(x$Upper-x$Lower)),
      Bias=sum(weights$Probability*x$EAP-weights$FirstMoment),
      MSE=sum(weights$Probability*x$EAP^2-2*x$EAP*weights$FirstMoment+weights$SecondMoment),
      MeanSD=sum(weights$Probability*x$SD),ExtremeTotal=sum(weights$Probability[weights$Total %in% c(0,3*d$n)]))
    estimates <- if (mass>0) estimates/mass else estimates*NA_real_
    summaries[[length(summaries)+1L]] <- data.frame(Design=design_id,Model=d$model,Ratings=d$n,
      Distribution=name,Method=method,Stratum=s,PopulationMass=mass,
      as.list(estimates),RMSE=sqrt(estimates["MSE"]),row.names=NULL)
  }
  list(profile=profile,strata=stratum,summary=do.call(rbind,summaries),
    normal_bounds=primary[c("Total","Lower","Upper")])
}

ppr_run <- function(interval_file,output,designs=1:6,tolerance=1e-9) {
  dir.create(output,recursive=TRUE,showWarnings=FALSE)
  intervals <- read.csv(interval_file)
  stopifnot(nrow(intervals)==2880L,all(intervals$EndpointPass))
  write.csv(ppr_self_check(),file.path(output,"self-checks.csv"),row.names=FALSE)
  summaries <- list()
  for (design in designs) for (distribution in 1:7) {
    message("design ",design," distribution ",distribution," tolerance ",tolerance)
    x <- ppr_cell(design,distribution,intervals,tolerance)
    saveRDS(x,file.path(output,sprintf("design-%d-distribution-%d.rds",design,distribution)))
    summaries[[length(summaries)+1L]] <- x$summary
    write.csv(do.call(rbind,summaries),file.path(output,"summary.csv"),row.names=FALSE)
  }
  capture.output(sessionInfo(),file=file.path(output,"session.txt"))
  invisible(do.call(rbind,summaries))
}

ppr_monte_carlo <- function(directory,output) {
  dir.create(output,recursive=TRUE,showWarnings=FALSE)
  rows <- list(); populations <- ppr_populations()
  for (design in 1:6) for (distribution in 1:7) {
    x <- readRDS(file.path(directory,sprintf("design-%d-distribution-%d.rds",design,distribution)))
    summary <- x$summary[x$summary$Stratum==0,]
    d <- person_interval_design(summary$Model[1L],summary$Ratings[1L])
    seed <- 114000000L+1000L*design+distribution
    set.seed(seed); theta <- populations[[distribution]]$r(20000L); total <- integer(length(theta))
    for (item in seq_len(d$n)) {
      probability <- d$probability(theta,item)
      total <- total+rowSums(runif(length(theta))>t(apply(probability,1L,cumsum))[,1:3,drop=FALSE])
    }
    saveRDS(list(theta=theta,total=total,seed=seed,RNGkind=RNGkind()),
      file.path(output,sprintf("design-%d-distribution-%d.rds",design,distribution)))
    for (method in c("normal_fixed31","oracle")) {
      bounds <- if (method=="oracle") x$profile else x$normal_bounds
      covered <- theta>=bounds$Lower[total+1L] & theta<=bounds$Upper[total+1L]
      target <- summary$Coverage[summary$Method==method]
      se <- sqrt(target*(1-target)/length(theta))
      stopifnot(abs(mean(covered)-target)<=5*se)
      rows[[length(rows)+1L]] <- data.frame(Design=design,Model=d$model,Ratings=d$n,
        Distribution=names(populations)[distribution],Method=method,Persons=length(theta),
        IntegratedCoverage=target,Coverage=mean(covered),MCSE=se,Z=(mean(covered)-target)/se,Seed=seed)
    }
    write.csv(do.call(rbind,rows),file.path(output,"checks.csv"),row.names=FALSE)
  }
  invisible(do.call(rbind,rows))
}
