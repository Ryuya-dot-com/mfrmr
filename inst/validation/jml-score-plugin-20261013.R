# Conditional generator sensitivity, not bootstrap coverage or an interval API.
args <- commandArgs(TRUE)
stopifnot(length(args)==1L,args %in% c("prepare","run","replay"))
action <- args[1L]
script <- "inst/validation/jml-score-plugin-20261013.R"
out <- "validation-results/jml-score-plugin-20261013"
bank <- normalizePath("validation-results/jml-score-calibration-20261013")
overlap <- "validation-results/jml-score-plugin-overlap-20261013"
threads <- c("OMP_NUM_THREADS","OPENBLAS_NUM_THREADS","MKL_NUM_THREADS","VECLIB_MAXIMUM_THREADS")
# Bootstrap the existing function-only loader, without dispatching its driver.
for(x in parse(file.path(bank,"source.R")))
  if(is.call(x) && identical(x[[1]],as.name("<-")) &&
     identical(x[[2]],as.name("read_function"))) eval(x)
for(n in c("check","near","save_new","rank_bounds","ci"))
  assign(n,read_function(file.path(bank,"source.R"),n))

paired_summary <- function(t,baseline) {
  B <- length(t); stopifnot(length(baseline)==B,all(is.finite(baseline)))
  known <- is.finite(t); a <- abs(t)>qnorm(.975); b <- abs(baseline)>qnorm(.975)
  lo <- hi <- a; lo[!known] <- FALSE; hi[!known] <- TRUE
  plus <- sum(a[known] & !b[known]); minus <- sum(!a[known] & b[known])
  discord <- plus+minus; complete <- all(known)
  data.frame(Returned=sum(known),Unknown=sum(!known),BaseReject=sum(b),
    PluginReject=sum(a[known]),RateLower=mean(lo),RateUpper=mean(hi),
    RateMC_Lower=ci(sum(lo),B)[1],RateMC_Upper=ci(sum(hi),B)[2],
    DifferenceLower=mean(lo-b),DifferenceUpper=mean(hi-b),
    PairedMCSE=if(complete)sd(as.numeric(a)-b)/sqrt(B) else NA_real_,
    Added=plus,Removed=minus,
    PairedP=if(!complete)NA_real_ else if(!discord)1 else binom.test(plus,discord,.5)$p.value,
    Q95Lower=rank_bounds(t,B,ceiling(.95*B))[1],Q95Upper=rank_bounds(t,B,ceiling(.95*B))[2],
    Q95_MC_Lower=rank_bounds(t,B,qbinom(.025,B,.95))[1],
    Q95_MC_Upper=rank_bounds(t,B,qbinom(.975,B,.95)+1)[2],
    BaseQ95=sort(abs(baseline))[ceiling(.95*B)])
}
# Enumerate missing-event completions to check the all-attempt paired bounds.
control <- paired_summary(c(0,3,NA_real_,NA_real_),c(0,0,3,0))
for(v in list(c(0,0),c(0,3),c(3,0),c(3,3))) {
  z <- paired_summary(c(0,3,v),c(0,0,3,0))
  stopifnot(z$DifferenceLower>=control$DifferenceLower,z$DifferenceUpper<=control$DifferenceUpper)
}
stopifnot(paired_summary(c(0,3),c(0,3))$PairedP==1)

if(action=="prepare") {
  stopifnot(!dir.exists(out),all(Sys.getenv(threads)=="1"))
  bm <- readRDS(file.path(bank,"manifest.rds")); br <- readRDS(file.path(bank,"report.rds"))
  om <- readRDS(file.path(overlap,"manifest.rds")); or <- readRDS(file.path(overlap,"report.rds"))
  check(bm$source);check(bm$inputs);check(br$results);check(om$source);check(om$inputs)
  stopifnot(!any(or$rows$ReuseBoundPass))
  sources <- lapply(1:8,function(i)readRDS(file.path(bm$reference,sprintf("case-%02d-structural_truth.rds",i))))
  stopifnot(all(vapply(sources,function(x)x$job$Replicate==1 && x$calculation$available,TRUE)))
  jobs <- do.call(rbind,lapply(seq_along(sources),function(i) {
    s <- sources[[i]]; index <- which(bm$parents$Design==s$job$Design & bm$parents$N==s$job$N)
    stopifnot(length(index)==99L)
    data.frame(Case=i,Design=s$job$Design,N=s$job$N,L=s$job$L,
      Replicate=bm$parents$Replicate[index],Parent=bm$parents$Parent[index])
  }))
  dir.create(out,recursive=TRUE);stopifnot(file.copy(script,file.path(out,"source.R")))
  inputs <- c(file.path(bank,c("manifest.rds","report.rds","source.R")),names(br$results),
    file.path(overlap,c("manifest.rds","report.rds")),
    file.path(bm$reference,sprintf("case-%02d-structural_truth.rds",1:8)))
  m <- list(source=tools::md5sum(file.path(out,"source.R")),inputs=tools::md5sum(inputs),
    bank=bank,prior=bm$prior,reference=bm$reference,sources=sources,jobs=jobs,B=99L,
    policy=bm$policy,R=R.version,threads=Sys.getenv(threads),packages=bm$packages,
    contract=list(aim="Isolate null-constrained structural nuisance substitution with known ability law",
      selection="First retained replicate of each design/N/L, fixed by the overlap contract before its results; eight generators",
      allocation="99 independent draws per fixed generator, 792 complete null calculations; no outer coverage trials",
      generator="Replace four structural nuisance values by retained constrained estimates; psi=.5 and roster-specific three-point ability law unchanged",
      pairing="Reuse matching baseline parent RNG stream; same abilities/rosters; correct generator marginals without guaranteed variance reduction",
      exposure="L1 and L2 have separately fitted generating nuisance values; not nested samples from one law",
      statistic="Identical order-2 Person profiles, two nuisance starts/stages, full derivative and roster-projected variance; no recentering or truth start",
      primary="Paired change in P(|T|>qnorm(.975)); report all-attempt bounds, paired MCSE and exact discordance p with Holm across eight fixed generators",
      secondary="Absolute-T .95 quantile and pointwise binomial-rank uncertainty; not cutoff adoption or observed-data p-value validation",
      precision="B=99: individual-probability MCSE .02190 at .05; paired worst-case MCSE 1/sqrt(99); actual paired MCSE reported; nonsignificance cannot establish equivalence",
      failures="Save inputs before fitting, keep all attempts; no replacements; unidentified paired tests remain NA, all-attempt difference/rank bounds retained",
      decision="Sensitivity and cost only; no favorable-result extension, larger N, ability estimation, endpoint search or public qualification",
      expected_phase_seconds=br$phase_seconds))
  save_new(m,file.path(out,"manifest.rds"))
  cat("Frozen 8 generators x 99 draws; expected phase seconds",m$contract$expected_phase_seconds,"\n")
  quit(save="no")
}
out <- normalizePath(out);m <- readRDS(file.path(out,"manifest.rds"))
check(m$source);check(m$inputs)
stopifnot(identical(unname(tools::md5sum(script)),unname(m$source)),
  identical(m$R,R.version),identical(m$threads,Sys.getenv(threads)))
bm <- readRDS(file.path(m$bank,"manifest.rds"));check(bm$source);check(bm$inputs)
old <- readRDS(file.path(m$prior,"manifest.rds"));check(old$source)
seal <- tools::md5sum(file.path(out,"manifest.rds"))
score <- read_function(file.path(m$reference,"source.R"),"score")

if(action=="run") {
  timer_run <- proc.time()[["elapsed"]]
  stopifnot(identical(m$packages,vapply(names(m$packages),function(p)as.character(packageVersion(p)),"")))
  library(mfrmr,lib.loc=file.path(m$prior,"library"))
  stopifnot(identical(normalizePath(find.package("mfrmr")),file.path(m$prior,"library/mfrmr")))
  helper <- file.path(m$prior,"source/inst/validation/jml-observed-inference-20261001.R")
  for(n in c("jml_observed_long","jml_observed_expand")) assign(n,read_function(helper,n))
  generate <- read_function(file.path(m$prior,"source/inst/validation/jml-small-pilot-20261013.R"),"generate")
  root <- read_function(file.path(m$reference,"source.R"),"root")
  jac <- mfrmr:::mfrmr_numeric_transformation_jacobian
  for(i in seq_len(nrow(m$jobs))) {
    job <- m$jobs[i,];d <- old$designs[[job$Design]]
    d$truth <- m$sources[[job$Case]]$calculation$beta
    baseline <- readRDS(file.path(m$bank,sprintf("input-%04d.rds",job$Parent)))$input
    ip <- file.path(out,sprintf("input-%04d.rds",i))
    if(!file.exists(ip)) {
      timer <- proc.time()[["elapsed"]];input <- generate(d,job$N,bm$streams[[job$Parent]])
      stopifnot(identical(input$roster,baseline$roster),identical(input$theta,baseline$theta))
      save_new(list(manifest=seal,job=job,beta=d$truth,input=input,
        seconds=proc.time()[["elapsed"]]-timer),ip)
    }
    input <- readRDS(ip);ih <- tools::md5sum(ip)
    stopifnot(identical(input$manifest,seal),identical(input$job,job),identical(input$beta,d$truth),
      identical(input$input$stream,bm$streams[[job$Parent]]))
    fp <- file.path(out,sprintf("fit-%04d.rds",i))
    if(file.exists(fp)) {
      saved <- readRDS(fp);stopifnot(identical(saved$input,ih),identical(saved$manifest,seal));next
    }
    timer <- proc.time()[["elapsed"]]
    calc <- tryCatch({
      data <- jml_observed_long(input$input$counts[[as.character(job$L)]],d$cells)
      problem <- mfrmr:::mfrm_jml_adjustment_problem(data,"Person",c("Rater","Criterion"),"Score",d$owner,2L)
      stopifnot(nrow(problem$parameters)==5L,problem$parameters$Type[5L]=="log_slope",
        identical(as.integer(problem$roster),as.integer(input$input$roster)))
      groups <- split(seq_len(job$N),problem$roster)
      fn <- function(lambda)problem$mean_score(c(lambda,d$truth[5]),2L)[-5L]
      solved <- root(fn,m$policy)
      if(!solved$available) list(available=FALSE,reason="nuisance roots unavailable or inconsistent",solve=solved) else {
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
    save_new(list(manifest=seal,input=ih,job=job,calculation=calc,seconds=proc.time()[["elapsed"]]-timer),fp)
    if(i%%25L==0L || i==nrow(m$jobs)) {
      cat("Completed",i,"/",nrow(m$jobs),"elapsed",proc.time()[["elapsed"]]-timer_run,"seconds\n");flush.console()
    }
  }
  cat("All planned draws and attempts complete; run seconds",proc.time()[["elapsed"]]-timer_run,"\n")
  quit(save="no")
}

stopifnot(!"mfrmr" %in% loadedNamespaces(),!"nleqslv" %in% loadedNamespaces(),!exists(".Random.seed",.GlobalEnv))
files <- character();rows <- list();generation_seconds <- 0
br <- readRDS(file.path(m$bank,"report.rds"))
for(i in seq_len(nrow(m$jobs))) {
  job <- m$jobs[i,];ip <- file.path(out,sprintf("input-%04d.rds",i));input <- readRDS(ip)
  stopifnot(identical(input$manifest,seal),identical(input$job,job),
    identical(input$beta,m$sources[[job$Case]]$calculation$beta),
    identical(input$input$stream,bm$streams[[job$Parent]]))
  baseline <- readRDS(file.path(m$bank,sprintf("input-%04d.rds",job$Parent)))$input
  stopifnot(identical(input$input$roster,baseline$roster),identical(input$input$theta,baseline$theta))
  fp <- file.path(out,sprintf("fit-%04d.rds",i));x <- readRDS(fp);check(x$input)
  stopifnot(identical(x$manifest,seal),identical(x$job,job))
  files <- c(files,ip,fp);generation_seconds <- generation_seconds+input$seconds
  z <- x$calculation;T <- NA_real_
  if(isTRUE(z$available)) {
    s <- score(z$U,z$A,z$groups);near(s,z$statistic)
    stopifnot(z$solve$available,z$solve$spread<=m$policy$root_agreement_tolerance,
      s$nuisance_residual<=m$policy$equation_tolerance,s$projection_residual<1e-10)
    err <- max(abs(z$A_coarse-z$A))/max(1,max(abs(z$A)));near(err,z$derivative_error);stopifnot(err<=1e-5)
    E <- z$U;for(g in z$groups)E[g,] <- sweep(z$U[g,,drop=FALSE],2,colMeans(z$U[g,,drop=FALSE]))
    w <- c(-drop(z$A[5,-5,drop=FALSE]%*%solve(z$A[-5,-5,drop=FALSE])),1)
    near(s$T,sum(drop(z$U%*%w))/sqrt(drop(w%*%crossprod(E)%*%w)));T <- s$T
  }
  base <- br$rows[br$rows$Parent==job$Parent & br$rows$L==job$L,]
  stopifnot(nrow(base)==1L,base$Available,base$Design==job$Design,base$N==job$N)
  rows[[i]] <- data.frame(job,Available=z$available,Reason=z$reason,T=T,BaseT=base$T,
    Seconds=x$seconds,Attempts=length(z$solve$attempts))
}
rows <- do.call(rbind,rows)
summary <- do.call(rbind,lapply(1:8,function(i) {
  z <- rows[rows$Case==i,];stopifnot(nrow(z)==m$B,identical(z$Replicate,1:m$B))
  data.frame(z[1,c("Case","Design","N","L")],Owner=old$designs[[z$Design[1]]]$owner,
    B=m$B,paired_summary(z$T,z$BaseT),Seconds=sum(z$Seconds))
}))
summary$HolmP <- p.adjust(summary$PairedP,"holm",n=8)
report <- list(manifest=seal,results=tools::md5sum(files),rows=rows,summary=summary,
  generation_seconds=generation_seconds,phase_seconds=generation_seconds+sum(rows$Seconds),
  scope="Conditional generator sensitivity; eight fixed retained nuisance vectors, not bootstrap coverage or a valid composite-null test")
path <- file.path(out,"report.rds")
if(file.exists(path))near(report,readRDS(path)) else {
  save_new(report,path);write.csv(rows,file.path(out,"rows.csv"),row.names=FALSE)
  write.csv(summary,file.path(out,"summary.csv"),row.names=FALSE)
}
print(summary,row.names=FALSE)
cat("Saved-only replay passed:",nrow(rows),"attempts; phase seconds",report$phase_seconds,"\n")
