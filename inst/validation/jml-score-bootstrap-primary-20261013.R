# Prespecified independent primary screen; no interval endpoints or public API.
args <- commandArgs(TRUE)
stopifnot(length(args)==1L,args %in% c("prepare","run","replay"))
action <- args[1L]
script <- "inst/validation/jml-score-bootstrap-primary-20261013.R"
out <- "validation-results/jml-score-bootstrap-primary-20261013"
previous <- normalizePath("validation-results/jml-score-bootstrap-membership-20261013")
bank <- normalizePath("validation-results/jml-score-calibration-20261013")
threads <- c("OMP_NUM_THREADS","OPENBLAS_NUM_THREADS","MKL_NUM_THREADS","VECLIB_MAXIMUM_THREADS")
for(x in parse(file.path(bank,"source.R")))
  if(is.call(x)&&identical(x[[1]],as.name("<-"))&&identical(x[[2]],as.name("read_function")))eval(x)
for(n in c("check","near","save_new","ci"))assign(n,read_function(file.path(bank,"source.R"),n))

calculate <- function(input,d,job) {
  calc <- tryCatch({
    data <- jml_observed_long(input$input$counts[[as.character(job$L)]],d$cells)
    problem <- mfrmr:::mfrm_jml_adjustment_problem(data,"Person",c("Rater","Criterion"),"Score",d$owner,2L)
    stopifnot(nrow(problem$parameters)==5L,problem$parameters$Type[5L]=="log_slope",
      identical(as.integer(problem$roster),as.integer(input$input$roster)))
    groups <- split(seq_len(job$N),problem$roster)
    fn <- function(lambda)problem$mean_score(c(lambda,d$truth[5]),2L)[-5L]
    solved <- root(fn,m$policy)
    if(!solved$available)list(available=FALSE,reason="nuisance roots unavailable or inconsistent",solve=solved) else {
      beta <- c(solved$beta,d$truth[5]);ev <- problem$evaluate(beta,2L)
      derivative <- lapply(c(1e-4,5e-5),function(h)jac(function(b)problem$mean_score(b,2L),beta,h))
      valid <- all(vapply(derivative,`[[`,TRUE,"valid"));A <- derivative[[2]]$jacobian
      error <- if(valid)max(abs(derivative[[1]]$jacobian-A))/max(1,max(abs(A))) else Inf
      stat <- if(error<=1e-5)score(ev$value,A,groups) else list(available=FALSE,reason="complete derivative step instability")
      list(available=stat$available,reason=stat$reason,solve=solved,beta=beta,U=ev$value,A=A,
        A_coarse=derivative[[1]]$jacobian,derivative_error=error,groups=groups,
        statistic=stat,extremes=sum(!is.finite(ev$theta)))
    }
  },error=function(e)list(available=FALSE,reason=conditionMessage(e)))
  calc
}

rate_summary <- function(decision,label) {
  stopifnot(length(decision)==99L,all(decision%in%c("reject","nonreject","unresolved")))
  n <- length(decision);k <- sum(decision=="reject");u <- sum(decision=="unresolved")
  data.frame(Method=label,Outer=n,Reject=k,Unknown=u,Determined=n-u,
    RateLower=k/n,RateUpper=(k+u)/n,MC_Lower=ci(k,n)[1],MC_Upper=ci(k+u,n)[2],
    ReturnMC_Lower=ci(n-u,n)[1],ReturnMC_Upper=ci(n-u,n)[2],
    InflationP_Lower=pbinom(k+u-1,n,.05,lower.tail=FALSE),
    InflationP_Upper=pbinom(k-1,n,.05,lower.tail=FALSE),
    Screen=if(k>=10L)"repair_required" else if(k+u>=10L)"unresolved" else "inflation_not_detected_not_qualified")
}
stopifnot(rate_summary(c(rep("reject",10),rep("nonreject",89)),"test")$Screen=="repair_required",
  rate_summary(c(rep("reject",9),"unresolved",rep("nonreject",89)),"test")$Screen=="unresolved",
  rate_summary(rep("unresolved",99),"test")$RateUpper==1)

if(action=="prepare") {
  stopifnot(!dir.exists(out),all(Sys.getenv(threads)=="1"))
  pm <- readRDS(file.path(previous,"manifest.rds"));pr <- readRDS(file.path(previous,"report.rds"))
  check(pm$source);check(pm$inputs);check(pr$manifest);check(pr$results)
  old <- readRDS(file.path(pm$prior,"manifest.rds"));check(old$source)
  # Verify the wrapped calculation is the exact previously checked expression.
  found <- list()
  visit <- function(x) {
    if(!is.call(x))return()
    if(identical(x[[1]],as.name("<-"))&&identical(x[[2]],as.name("calc"))) {
      found[[length(found)+1L]] <<- x;return()
    }
    if(as.character(x[[1]])%in%c("{","if","for"))for(z in as.list(x)[-1])visit(z)
  }
  for(x in parse(file.path(previous,"source.R")))visit(x)
  stopifnot(length(found)==1L,identical(found[[1]],body(calculate)[[2]]))
  B <- R <- 99L;jobs <- data.frame(Outer=1:R,Design=2L,N=20L,L=1L)
  streams <- vector("list",R*(B+1L))
  streams[[1]] <- parallel::nextRNGStream(tail(pm$streams,1)[[1]])
  for(i in 2:length(streams))streams[[i]] <- parallel::nextRNGStream(streams[[i-1L]])
  stopifnot(!anyDuplicated(vapply(streams,paste,"",collapse=",")),old$designs[[2]]$owner=="Rater")
  dir.create(out,recursive=TRUE);stopifnot(file.copy(script,file.path(out,"source.R")))
  inputs <- c(file.path(previous,c("manifest.rds","report.rds","source.R","verification.rds")),
    file.path(pm$completion,c("source.R","report.rds")),file.path(bank,"source.R"),
    file.path(pm$reference,"source.R"),file.path(pm$prior,"manifest.rds"))
  m <- list(source=tools::md5sum(file.path(out,"source.R")),inputs=tools::md5sum(inputs),
    previous=previous,prior=pm$prior,reference=pm$reference,completion=pm$completion,
    jobs=jobs,streams=streams,B=B,outer=R,alpha=.05,policy=pm$policy,
    R=R.version,threads=Sys.getenv(threads),packages=pm$packages,
    contract=list(question="Does the unchanged null-specific procedure repair gross truth-rejection inflation in the prespecified Rater/N20/L1 primary cell, with ability law known?",
      selection="Largest previous normal-reference inflation, selected before these independent data; a single primary cell, not eight unadjusted tests",
      allocation="99 new independent outer samples, all completed without outcome-based extension/replacement; at most 99 inner draws per sample, only fixed-B logical completion",
      generator="Outer: unchanged complete structural truth and known roster ability law. Inner: observed null-constrained nuisance and same known ability law; psi=.5 throughout",
      statistic="Complete order-2 corrected score; every outer and inner sample repeats original two-start constrained nuisance solve, Person profiles/correction, nonsymmetric derivative and within-roster variance",
      comparator="Normal |T|>qnorm(.975) on the same outer statistic; paired comparison secondary; no rescaling, recentering or tuning",
      failures="Unavailable observed statistic makes both decisions unresolved; unavailable inner statistic remains unknown in all planned-B bounds; no replacements or targeted rescue",
      reference="(1+inclusive absolute-statistic exceedances)/100; nonreject only when lower>.05; reject only when upper<=.05; straddling exhausted bound unresolved",
      streams="9900 streams follow all 792 previously planned streams, including unused suffixes; each block assigns stream 0 to outer generation and 1:99 to inner draws",
      reporting="All 99 outer attempts; definite-rejection/unknown bounds, pointwise exact binomial MC envelope, determination rate and costs; paired difference bounds, with MCSE/exact discordance test only when fully observed",
      precision=list(MCSE_at_05=sqrt(.05*.95/R),worst_MCSE=.5/sqrt(R),screen_count=10L,
        power_at_15=pbinom(9,R,.15,lower.tail=FALSE),power_at_10=pbinom(9,R,.10,lower.tail=FALSE)),
      decision="At least 10 definite rejections: repair required. Possible counts straddling 10: unresolved. Otherwise inflation not detected, never nominal-coverage qualification. Finish all 99 before disposition; do not increase R/B afterward",
      cost="At most 9801 inner plus 99 outer calculations; retained corresponding bank suggests about 78 minutes of inner work if all draws needed, plus outer/I/O; not a hard limit or shorter-runtime promise",
      exclusions="No new optimizer, ability-distribution estimation, endpoint forest, all-cell campaign or public API. Preserve both owners, N20/N60 and L1/L2 requirements for broader claims",
      calculation_identical=TRUE))
  save_new(m,file.path(out,"manifest.rds"))
  cat("Frozen 99 independent outer samples, B=99, 9900 reserved streams; complete calculation identity passed.\n")
  quit(save="no")
}

out <- normalizePath(out);m <- readRDS(file.path(out,"manifest.rds"))
check(m$source);check(m$inputs)
stopifnot(identical(unname(tools::md5sum(script)),unname(m$source)),
  identical(m$R,R.version),identical(m$threads,Sys.getenv(threads)))
old <- readRDS(file.path(m$prior,"manifest.rds"));check(old$source)
seal <- tools::md5sum(file.path(out,"manifest.rds"))
score <- read_function(file.path(m$reference,"source.R"),"score")
completion <- read_function(file.path(m$completion,"source.R"),"completion")
value <- function(z)if(isTRUE(z$available))z$statistic$T else NA_real_

if(action=="run") {
  timer_run <- proc.time()[["elapsed"]]
  stopifnot(identical(m$packages,vapply(names(m$packages),function(p)as.character(packageVersion(p)),"")))
  library(mfrmr,lib.loc=file.path(m$prior,"library"))
  stopifnot(identical(normalizePath(find.package("mfrmr")),file.path(m$prior,"library/mfrmr")))
  helper <- file.path(m$prior,"source/inst/validation/jml-observed-inference-20261001.R")
  for(n in c("jml_observed_long","jml_observed_expand"))assign(n,read_function(helper,n))
  generate <- read_function(file.path(m$prior,"source/inst/validation/jml-small-pilot-20261013.R"),"generate")
  root <- read_function(file.path(m$reference,"source.R"),"root")
  jac <- mfrmr:::mfrmr_numeric_transformation_jacobian
  attempt <- function(i,b,d,job) {
    stream <- m$streams[[(i-1L)*(m$B+1L)+1L+b]]
    ip <- file.path(out,sprintf("input-%03d-%03d.rds",i,b))
    if(!file.exists(ip)) {
      timer <- proc.time()[["elapsed"]];input <- generate(d,job$N,stream)
      save_new(list(manifest=seal,job=job,draw=b,beta=d$truth,input=input,
        seconds=proc.time()[["elapsed"]]-timer),ip)
    }
    input <- readRDS(ip);ih <- tools::md5sum(ip)
    stopifnot(identical(input$manifest,seal),identical(input$job,job),input$draw==b,
      identical(input$beta,d$truth),identical(input$input$stream,stream))
    fp <- file.path(out,sprintf("fit-%03d-%03d.rds",i,b))
    if(!file.exists(fp)) {
      timer <- proc.time()[["elapsed"]];calc <- calculate(input,d,job)
      save_new(list(manifest=seal,input=ih,job=job,draw=b,calculation=calc,
        seconds=proc.time()[["elapsed"]]-timer),fp)
    }
    fit <- readRDS(fp)
    stopifnot(identical(fit$manifest,seal),identical(fit$input,ih),identical(fit$job,job),fit$draw==b)
    fit$calculation
  }
  for(i in seq_len(m$outer)) {
    job <- m$jobs[i,];d <- old$designs[[job$Design]]
    observed <- attempt(i,0L,d,job);obs <- value(observed)
    normal <- if(!is.finite(obs))"unresolved" else if(abs(obs)>qnorm(.975))"reject" else "nonreject"
    values <- numeric();state <- completion(obs,values,m$B,m$alpha)
    if(state$decision=="continue") {
      d$truth <- observed$beta
      for(b in seq_len(m$B)) {
        if(state$decision!="continue")break
        fit <- attempt(i,b,d,job);values <- c(values,value(fit))
        state <- completion(obs,values,m$B,m$alpha)
      }
    }
    stopifnot(state$decision!="continue")
    result <- list(manifest=seal,job=job,observed=obs,normal=normal,values=values,state=state)
    path <- file.path(out,sprintf("case-%03d.rds",i))
    if(file.exists(path))near(result,readRDS(path),0) else save_new(result,path)
    cat("Completed outer",i,"/",m$outer,"with",state$attempted,"inner attempts; elapsed",
      proc.time()[["elapsed"]]-timer_run,"seconds\n");flush.console()
  }
  cat("All 99 prespecified outer attempts complete; run seconds",proc.time()[["elapsed"]]-timer_run,"\n")
  quit(save="no")
}

stopifnot(!exists(".Random.seed",.GlobalEnv),!"mfrmr"%in%loadedNamespaces(),!"nleqslv"%in%loadedNamespaces())
rows <- draws <- list();files <- character()
for(i in seq_len(m$outer)) {
  job <- m$jobs[i,];path <- file.path(out,sprintf("case-%03d.rds",i));case <- readRDS(path)
  stopifnot(identical(case$manifest,seal),identical(case$job,job))
  s <- completion(case$observed,case$values,m$B,m$alpha);near(s,case$state,0)
  stopifnot(s$decision!="continue")
  normal <- if(!is.finite(case$observed))"unresolved" else if(abs(case$observed)>qnorm(.975))"reject" else "nonreject"
  stopifnot(identical(case$normal,normal))
  files <- c(files,path);seconds <- c(outer=0,inner=0);outer <- NULL
  for(b in 0:s$attempted) {
    if(b)stopifnot(completion(case$observed,case$values[seq_len(b-1L)],m$B,m$alpha)$decision=="continue")
    ip <- file.path(out,sprintf("input-%03d-%03d.rds",i,b));input <- readRDS(ip)
    fp <- file.path(out,sprintf("fit-%03d-%03d.rds",i,b));x <- readRDS(fp);check(x$input)
    stopifnot(identical(input$manifest,seal),identical(x$manifest,seal),
      identical(input$job,job),identical(x$job,job),input$draw==b,x$draw==b,
      identical(input$input$stream,m$streams[[(i-1L)*(m$B+1L)+1L+b]]))
    z <- x$calculation
    if(!b)outer <- z
    generator <- if(!b)old$designs[[job$Design]]$truth else outer$beta
    stopifnot(identical(input$beta,generator))
    if(isTRUE(z$available)) {
      stat <- score(z$U,z$A,z$groups);near(stat,z$statistic)
      stopifnot(z$solve$available,z$solve$spread<=m$policy$root_agreement_tolerance,
        stat$nuisance_residual<=m$policy$equation_tolerance,stat$projection_residual<1e-10)
      err <- max(abs(z$A_coarse-z$A))/max(1,max(abs(z$A)));near(err,z$derivative_error)
      stopifnot(err<=1e-5,z$beta[5]==input$beta[5],identical(z$groups,split(seq_len(job$N),input$input$roster)))
    }
    T <- value(z);near(T,if(!b)case$observed else case$values[b])
    elapsed <- input$seconds+x$seconds;kind <- if(!b)"outer" else "inner"
    seconds[kind] <- seconds[kind]+elapsed
    draws[[length(draws)+1L]] <- data.frame(Outer=i,Draw=b,Kind=kind,NumericalAvailable=z$available,
      FiniteStatistic=is.finite(T),Reason=z$reason,T=T,Seconds=elapsed,Attempts=length(z$solve$attempts))
    files <- c(files,ip,fp)
  }
  stopifnot(length(list.files(out,pattern=sprintf("^input-%03d-[0-9]{3}\\.rds$",i)))==s$attempted+1L,
    length(list.files(out,pattern=sprintf("^fit-%03d-[0-9]{3}\\.rds$",i)))==s$attempted+1L)
  rows[[i]] <- data.frame(job,Observed=case$observed,Normal=normal,Bootstrap=s$decision,
    Attempted=s$attempted,Failed=s$failed,Unattempted=s$unattempted,Lower=s$lower,Upper=s$upper,
    OuterSeconds=unname(seconds["outer"]),InnerSeconds=unname(seconds["inner"]))
}
rows <- do.call(rbind,rows);draws <- do.call(rbind,draws)
summary <- rbind(rate_summary(rows$Normal,"normal"),rate_summary(rows$Bootstrap,"bootstrap"))
nlo <- rows$Normal=="reject";nhi <- rows$Normal!="nonreject"
blo <- rows$Bootstrap=="reject";bhi <- rows$Bootstrap!="nonreject"
known <- rows$Normal!="unresolved" & rows$Bootstrap!="unresolved"
plus <- sum(blo[known]&!nlo[known]);minus <- sum(!blo[known]&nlo[known]);discord <- plus+minus
paired <- data.frame(CompletePairs=sum(known),Added=plus,Removed=minus,
  DifferenceLower=mean(blo-nhi),DifferenceUpper=mean(bhi-nlo),
  MCSE=if(all(known))sd(as.numeric(blo)-nlo)/sqrt(m$outer) else NA_real_,
  ExactDiscordanceP=if(!all(known))NA_real_ else if(!discord)1 else binom.test(plus,discord,.5)$p.value)
report <- list(manifest=seal,results=tools::md5sum(files),rows=rows,draws=draws,summary=summary,paired=paired,
  phase_seconds=sum(draws$Seconds),scope="Independent single-cell gross-inflation screen with known ability law; not general coverage or endpoint/API qualification")
fp <- file.path(out,"report.rds")
if(file.exists(fp))near(report,readRDS(fp),0) else {
  save_new(report,fp);write.csv(rows,file.path(out,"rows.csv"),row.names=FALSE)
  write.csv(draws,file.path(out,"draws.csv"),row.names=FALSE)
  write.csv(summary,file.path(out,"summary.csv"),row.names=FALSE)
}
stopifnot(!exists(".Random.seed",.GlobalEnv),!"mfrmr"%in%loadedNamespaces(),!"nleqslv"%in%loadedNamespaces())
print(summary,row.names=FALSE);print(paired,row.names=FALSE)
cat("Saved-only replay passed:",m$outer,"outer and",sum(rows$Attempted),"inner attempts; phase seconds",report$phase_seconds,"\n")
