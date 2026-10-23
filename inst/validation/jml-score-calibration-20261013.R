# First-stage known-law calibration screen; no plug-in bootstrap or interval API.
args <- commandArgs(TRUE)
stopifnot(length(args)==1L, args %in% c("prepare","run","replay"))
action <- args[1L]
script <- "inst/validation/jml-score-calibration-20261013.R"
out <- "validation-results/jml-score-calibration-20261013"
prior <- "validation-results/jml-small-pilot-20261013"
reference <- "validation-results/jml-constrained-score-20261013"
threads <- c("OMP_NUM_THREADS","OPENBLAS_NUM_THREADS","MKL_NUM_THREADS","VECLIB_MAXIMUM_THREADS")
check <- function(h) stopifnot(length(h)>0L,!anyNA(h),identical(tools::md5sum(names(h)),h))
save_new <- function(x,path) {
  stopifnot(!file.exists(path)); saveRDS(x,paste0(path,".tmp"))
  stopifnot(file.rename(paste0(path,".tmp"),path))
}
near <- function(x,y,tol=1e-10) stopifnot(isTRUE(all.equal(unname(x),unname(y),tolerance=tol)))

# Read only named function definitions from frozen drivers, never execute their
# command dispatch. This reuses the exact checked generator and root policy.
read_function <- function(path,name) {
  found <- list()
  visit <- function(x) {
    if (!is.call(x)) return(invisible(NULL))
    if (identical(x[[1L]],as.name("<-")) && identical(x[[2L]],as.name(name)) &&
        is.call(x[[3L]]) && identical(x[[3L]][[1L]],as.name("function")))
      found[[length(found)+1L]] <<- x[[3L]]
    if (identical(x[[1L]],as.name("{"))) for (i in seq.int(2L,length(x))) visit(x[[i]])
    if (identical(x[[1L]],as.name("if"))) {
      visit(x[[3L]]); if(length(x)==4L) visit(x[[4L]])
    }
  }
  for (x in parse(path)) visit(x)
  stopifnot(length(found)==1L)
  eval(found[[1L]],envir=.GlobalEnv)
}

# Unknown |T| values range over [0,Inf]; no successful-only denominator.
rank_bounds <- function(values,B,k) {
  finite <- sort(abs(values[is.finite(values)])); f <- B-length(finite)
  c(lower=if(k<=f) 0 else finite[k-f],
    upper=if(k>length(finite)) Inf else finite[k])
}
p_bounds <- function(observed,values,B) {
  if(!is.finite(observed)) return(c(lower=0,upper=1))
  known <- is.finite(values); exceed <- sum(abs(values[known])>=abs(observed))
  c(lower=(1+exceed)/(B+1),upper=(1+exceed+sum(!known))/(B+1))
}
ci <- function(k,n) unname(binom.test(k,n)$conf.int)
rank_control <- function() {
  values <- c(.2,.5,1.1,NA_real_); k <- 3L
  envelope <- rank_bounds(values,4L,k)
  for (v in c(0,.3,.9,1.5,100)) {
    completed <- c(values[1:3],v); q <- sort(completed)[k]
    stopifnot(q>=envelope[1],q<=envelope[2])
    p <- (1+sum(completed>=.5))/5
    b <- p_bounds(.5,values,4L); stopifnot(p>=b[1],p<=b[2])
  }
  near(rank_bounds(values,4L,3L),c(.5,1.1))
  near(p_bounds(.5,values,4L),c(.6,.8))
  near(rank_bounds(rep(NA_real_,4),4L,3L),c(0,Inf))
  near(p_bounds(NA_real_,values,4L),c(0,1))
  stopifnot(p_bounds(.5,c(.5,.5,.5),3L)[1]==1)
  TRUE
}
stopifnot(rank_control())
if(action=="prepare") {
  stopifnot(!dir.exists(out),all(Sys.getenv(threads)=="1"))
  old <- readRDS(file.path(prior,"manifest.rds")); done <- readRDS(file.path(prior,"completion.rds"))
  ref <- readRDS(file.path(reference,"report.rds"))
  check(old$source); check(old$inputs); check(done$results); check(ref$results)
  score <- read_function(file.path(reference,"source.R"),"score")
  stopifnot(read_function(file.path(reference,"source.R"),"self_check")()$passed)
  B <- 99L
  parents <- expand.grid(Design=1:2,N=c(20L,60L),Replicate=seq_len(B))
  parents$Parent <- seq_len(nrow(parents))
  streams <- vector("list",nrow(parents))
  streams[[1L]] <- parallel::nextRNGStream(tail(old$streams,1L)[[1L]])
  for(i in 2:length(streams)) streams[[i]] <- parallel::nextRNGStream(streams[[i-1L]])
  policy <- readRDS(file.path(prior,"fit-01-L1.rds"))$fit$result$policy
  policy$starts <- lapply(policy$starts,function(b) b[-5L])
  dir.create(out,recursive=TRUE); stopifnot(file.copy(script,file.path(out,"source.R")))
  inputs <- c(file.path(prior,c("manifest.rds","completion.rds")),
    file.path(reference,c("manifest.rds","report.rds","source.R")),names(done$results),names(ref$results))
  m <- list(source=tools::md5sum(file.path(out,"source.R")),inputs=tools::md5sum(inputs),
    prior=normalizePath(prior),reference=normalizePath(reference),parents=parents,streams=streams,
    B=B,policy=policy,R=R.version,threads=Sys.getenv(threads),
    packages=vapply(c("nleqslv","Matrix","statmod","cpp11"),function(p)as.character(packageVersion(p)),""),
    protocol=list(aim="Screen normal-reference size/delivery under the fully known law before estimating a bootstrap generator",
      allocation="396 independent new parents, 792 paired L1/L2 views; 99 per design/N/L; one structural-truth null per view",
      generator="Unchanged three-point ability mixture per fixed roster and complete true structural vector; not a fitted nuisance bootstrap",
      target="psi=log(a1/a2)=.5; order-2 complete constrained equation, exact retained starts/stages/checks",
      statistic="Absolute nuisance-adjusted score, within-roster variance, normal threshold qnorm(.975); no recentering",
      precision=list(MCSE_at_05=sqrt(.05*.95/B),worst_MCSE=.5/sqrt(B),
        pointwise_reject_count=qbinom(.95,B,.05)+1,
        power_at_15=pbinom(qbinom(.95,B,.05),B,.15,lower.tail=FALSE),
        power_at_10=pbinom(qbinom(.95,B,.05),B,.10,lower.tail=FALSE)),
      failure="Retain unknown draws; rejection bounds k/B to (k+f)/B; rank bounds; never replace or delete failures",
      quantiles="Empirical |T| .95 order ceil(.95B), plus pointwise binomial-rank 95% uncertainty envelope",
      observed="Original 16 development views receive exploratory inclusive Monte Carlo p bounds; not independent validation",
      decision="Record exact pointwise uncertainty and Holm-adjusted gross-inflation screens; no favorable-result extension or qualification from nonrejection",
      limitations="No endpoint delivery/power validation, population-root reanalysis, estimated abilities, higher-order correction, nested bootstrap or public claim",
      expected_phase_seconds=sum(ref$rows$TotalSeconds[ref$rows$Null=="structural_truth"])/2*B))
  check(m$inputs); save_new(m,file.path(out,"manifest.rds"))
  cat("Frozen",nrow(parents),"parents /",2*nrow(parents),"null calculations; expected phase seconds",m$protocol$expected_phase_seconds,"\n")
  quit(save="no")
}
out <- normalizePath(out); m <- readRDS(file.path(out,"manifest.rds"))
check(m$inputs); check(m$source)
stopifnot(identical(unname(tools::md5sum(script)),unname(m$source)),
  identical(m$R,R.version),identical(m$threads,Sys.getenv(threads)))
seal <- tools::md5sum(file.path(out,"manifest.rds"))
old <- readRDS(file.path(m$prior,"manifest.rds")); check(old$source)
score <- read_function(file.path(m$reference,"source.R"),"score")

if(action=="run") {
  run_start <- proc.time()[["elapsed"]]
  stopifnot(identical(m$packages,vapply(names(m$packages),function(p)as.character(packageVersion(p)),"")))
  library(mfrmr,lib.loc=file.path(m$prior,"library"))
  stopifnot(identical(normalizePath(find.package("mfrmr")),file.path(m$prior,"library/mfrmr")))
  setwd(file.path(m$prior,"source")); source("inst/validation/jml-observed-inference-20261001.R")
  generate <- read_function(file.path(m$prior,"source/inst/validation/jml-small-pilot-20261013.R"),"generate")
  root <- read_function(file.path(m$reference,"source.R"),"root")
  jac <- mfrmr:::mfrmr_numeric_transformation_jacobian
  for(i in seq_len(nrow(m$parents))) {
    parent <- m$parents[i,]; d <- old$designs[[parent$Design]]
    ip <- file.path(out,sprintf("input-%04d.rds",i))
    if(!file.exists(ip)) {
      timer <- proc.time()[["elapsed"]]; input <- generate(d,parent$N,m$streams[[i]])
      save_new(list(manifest=seal,parent=parent,input=input,
        seconds=proc.time()[["elapsed"]]-timer),ip)
    }
    input <- readRDS(ip)
    stopifnot(identical(input$manifest,seal),identical(input$parent,parent),
      identical(input$input$stream,m$streams[[i]]))
    ih <- tools::md5sum(ip)
    for(L in 1:2) {
      fp <- file.path(out,sprintf("fit-%04d-L%d.rds",i,L))
      if(file.exists(fp)) {
        saved <- readRDS(fp); stopifnot(identical(saved$input,ih),identical(saved$manifest,seal)); next
      }
      timer <- proc.time()[["elapsed"]]
      calc <- tryCatch({
        data <- jml_observed_long(input$input$counts[[as.character(L)]],d$cells)
        problem <- mfrmr:::mfrm_jml_adjustment_problem(data,"Person",c("Rater","Criterion"),"Score",d$owner,2L)
        stopifnot(nrow(problem$parameters)==5L,problem$parameters$Type[5L]=="log_slope",
          identical(as.integer(problem$roster),as.integer(input$input$roster)))
        groups <- split(seq_len(parent$N),problem$roster)
        fn <- function(lambda) problem$mean_score(c(lambda,d$truth[5L]),2L)[-5L]
        solved <- root(fn,m$policy)
        if(!solved$available) list(available=FALSE,reason="nuisance roots unavailable or inconsistent",solve=solved) else {
          beta <- c(solved$beta,d$truth[5L]); ev <- problem$evaluate(beta,2L)
          derivative <- lapply(c(1e-4,5e-5),function(h)jac(function(b)problem$mean_score(b,2L),beta,h))
          valid <- all(vapply(derivative,`[[`,TRUE,"valid")); A <- derivative[[2L]]$jacobian
          error <- if(valid)max(abs(derivative[[1L]]$jacobian-A))/max(1,max(abs(A))) else Inf
          stat <- if(error<=1e-5)score(ev$value,A,groups) else
            list(available=FALSE,reason="complete derivative step instability")
          list(available=stat$available,reason=stat$reason,solve=solved,beta=beta,U=ev$value,A=A,
            A_coarse=derivative[[1L]]$jacobian,derivative_error=error,groups=groups,
            statistic=stat,extremes=sum(!is.finite(ev$theta)))
        }
      },error=function(e)list(available=FALSE,reason=conditionMessage(e)))
      save_new(list(manifest=seal,input=ih,parent=parent,L=L,calculation=calc,
        seconds=proc.time()[["elapsed"]]-timer),fp)
    }
    if(i%%10L==0L || i==nrow(m$parents)) {
      cat("Completed parent",i,"/",nrow(m$parents),"elapsed",proc.time()[["elapsed"]]-run_start,"seconds\n")
      flush.console()
    }
  }
  cat("All planned inputs and null attempts complete; run elapsed",proc.time()[["elapsed"]]-run_start,"seconds\n")
  quit(save="no")
}

stopifnot(!"mfrmr" %in% loadedNamespaces(),!"nleqslv" %in% loadedNamespaces(),!exists(".Random.seed",.GlobalEnv))
files <- character(); rows <- list(); generation_seconds <- 0
for(i in seq_len(nrow(m$parents))) {
  ip <- file.path(out,sprintf("input-%04d.rds",i)); input <- readRDS(ip)
  stopifnot(identical(input$manifest,seal),identical(input$input$stream,m$streams[[i]]))
  files <- c(files,ip); generation_seconds <- generation_seconds+input$seconds
  for(L in 1:2) {
    fp <- file.path(out,sprintf("fit-%04d-L%d.rds",i,L)); x <- readRDS(fp); check(x$input)
    stopifnot(identical(x$manifest,seal),identical(x$parent,m$parents[i,]),x$L==L)
    files <- c(files,fp); z <- x$calculation; T <- NA_real_
    if(isTRUE(z$available)) {
      s <- score(z$U,z$A,z$groups); near(s,z$statistic)
      stopifnot(z$solve$available,z$solve$spread<=m$policy$root_agreement_tolerance,
        s$nuisance_residual<=m$policy$equation_tolerance,s$projection_residual<1e-10)
      err <- max(abs(z$A_coarse-z$A))/max(1,max(abs(z$A))); near(err,z$derivative_error)
      stopifnot(err<=1e-5)
      E <- z$U
      for(g in z$groups) E[g,] <- sweep(z$U[g,,drop=FALSE],2,colMeans(z$U[g,,drop=FALSE]))
      c0 <- z$A[5,-5,drop=FALSE]%*%solve(z$A[-5,-5,drop=FALSE]); w <- c(-c0,1)
      near(s$T,sum(drop(z$U%*%w))/sqrt(drop(w%*%crossprod(E)%*%w)))
      T <- s$T
    }
    rows[[length(rows)+1L]] <- data.frame(x$parent,L=L,Available=z$available,Reason=z$reason,
      T=T,Seconds=x$seconds,Attempts=length(z$solve$attempts))
  }
}
rows <- do.call(rbind,rows); summaries <- list(); observed <- list()
ref <- readRDS(file.path(m$reference,"report.rds"))$rows
for(design in 1:2) for(N in c(20L,60L)) for(L in 1:2) {
  z <- rows[rows$Design==design & rows$N==N & rows$L==L,]
  stopifnot(nrow(z)==m$B,setequal(z$Replicate,seq_len(m$B)),!anyDuplicated(z$Replicate))
  values <- z$T; ok <- is.finite(values); f <- sum(!ok); k <- sum(abs(values[ok])>qnorm(.975))
  empirical <- rank_bounds(values,m$B,ceiling(.95*m$B))
  qlo <- rank_bounds(values,m$B,qbinom(.025,m$B,.95))[1]
  qhi <- rank_bounds(values,m$B,qbinom(.975,m$B,.95)+1)[2]
  lower_ci <- ci(k,m$B)[1]; upper_ci <- ci(k+f,m$B)[2]
  summary <- data.frame(Design=design,Owner=old$designs[[design]]$owner,N=N,L=L,B=m$B,
    Returned=sum(ok),Unknown=f,NormalReject=k,RejectLower=k/m$B,RejectUpper=(k+f)/m$B,
    MC_Lower=lower_ci,MC_Upper=upper_ci,ReturnLower=ci(sum(ok),m$B)[1],ReturnUpper=ci(sum(ok),m$B)[2],
    LowerTail=sum(values[ok]< -qnorm(.975)),UpperTail=sum(values[ok]>qnorm(.975)),
    ReturnedMean=mean(values[ok]),ReturnedSD=sd(values[ok]),Q95Lower=empirical[1],Q95Upper=empirical[2],
    Q95_MC_Lower=qlo,Q95_MC_Upper=qhi,
    InflationP_Lower=pbinom(k+f-1,m$B,.05,lower.tail=FALSE),
    InflationP_Upper=pbinom(k-1,m$B,.05,lower.tail=FALSE),Seconds=sum(z$Seconds))
  summaries[[length(summaries)+1L]] <- summary
  selected <- ref[ref$Design==design & ref$N==N & ref$L==L & ref$Null=="structural_truth",]
  for(j in seq_len(nrow(selected))) {
    b <- p_bounds(selected$T[j],values,m$B)
    observed[[length(observed)+1L]] <- data.frame(Design=design,N=N,L=L,Replicate=selected$Replicate[j],
      T=selected$T[j],P_Lower=b[1],P_Upper=b[2],NormalAccept=selected$ScoreAccept[j])
  }
}
summary <- do.call(rbind,summaries)
summary$HolmP_Lower <- p.adjust(summary$InflationP_Lower,"holm")
summary$HolmP_Upper <- p.adjust(summary$InflationP_Upper,"holm")
report <- list(manifest=seal,results=tools::md5sum(files),rows=rows,summary=summary,
  observed=do.call(rbind,observed),generation_seconds=generation_seconds,
  phase_seconds=generation_seconds+sum(rows$Seconds),
  scope="Known-law normal-reference screen; shared reference ranks on development inputs are exploratory, not calibrated-method coverage")
path <- file.path(out,"report.rds")
if(file.exists(path)) near(report,readRDS(path)) else {
  save_new(report,path); write.csv(summary,file.path(out,"summary.csv"),row.names=FALSE)
  write.csv(rows,file.path(out,"rows.csv"),row.names=FALSE)
  write.csv(report$observed,file.path(out,"observed.csv"),row.names=FALSE)
}
print(summary,row.names=FALSE)
cat("Saved-only replay passed:",nrow(rows),"attempts; phase seconds",report$phase_seconds,"\n")
