# Prospective execution on retained development inputs, not coverage validation.
args <- commandArgs(TRUE)
stopifnot(length(args)==1L,args %in% c("prepare","run","replay"))
action <- args[1L]
script <- "inst/validation/jml-score-bootstrap-membership-20261013.R"
out <- "validation-results/jml-score-bootstrap-membership-20261013"
bank <- normalizePath("validation-results/jml-score-calibration-20261013")
completion_dir <- normalizePath("validation-results/jml-score-bootstrap-completion-20261013")
threads <- c("OMP_NUM_THREADS","OPENBLAS_NUM_THREADS","MKL_NUM_THREADS","VECLIB_MAXIMUM_THREADS")
for(x in parse(file.path(bank,"source.R")))
  if(is.call(x)&&identical(x[[1]],as.name("<-"))&&identical(x[[2]],as.name("read_function")))eval(x)
for(n in c("check","near","save_new"))assign(n,read_function(file.path(bank,"source.R"),n))
completion <- read_function(file.path(completion_dir,"source.R"),"completion")

if(action=="prepare") {
  stopifnot(!dir.exists(out),all(Sys.getenv(threads)=="1"))
  bm <- readRDS(file.path(bank,"manifest.rds"));check(bm$source);check(bm$inputs)
  cr <- readRDS(file.path(completion_dir,"report.rds"));check(cr$inputs);check(cr$results)
  source_files <- file.path(bm$reference,sprintf("case-%02d-structural_truth.rds",9:16))
  sources <- lapply(source_files,readRDS)
  stopifnot(all(vapply(sources,function(x)x$job$Replicate==2 && x$calculation$available,TRUE)))
  jobs <- do.call(rbind,lapply(seq_along(sources),function(i)data.frame(Case=i,SourceCase=i+8L,sources[[i]]$job)))
  stopifnot(nrow(unique(jobs[c("Design","N","L")]))==8L,length(unique(jobs$Parent))==4L)
  streams <- vector("list",8L*99L)
  streams[[1]] <- parallel::nextRNGStream(tail(bm$streams,1)[[1]])
  for(i in 2:length(streams))streams[[i]] <- parallel::nextRNGStream(streams[[i-1L]])
  stopifnot(!anyDuplicated(vapply(streams,paste,"",collapse=",")))
  dir.create(out,recursive=TRUE);stopifnot(file.copy(script,file.path(out,"source.R")))
  inputs <- c(file.path(bank,c("manifest.rds","source.R")),source_files,
    file.path(completion_dir,c("source.R","report.rds")))
  m <- list(source=tools::md5sum(file.path(out,"source.R")),inputs=tools::md5sum(inputs),
    bank=bank,prior=bm$prior,reference=bm$reference,completion=completion_dir,
    jobs=jobs,sources=sources,streams=streams,B=99L,alpha=.05,policy=bm$policy,
    R=R.version,threads=Sys.getenv(threads),packages=bm$packages,
    contract=list(aim="Execute the complete null-specific procedure with prospective fixed-B stopping and restart-safe independent streams",
      allocation="All eight remaining original development views (second replicate per design/N/L), four original parents; no new outer data",
      roles="Development and process checks only; no independent coverage validation or error-rate estimate from these eight views",
      target="Structural truth psi=log(a1/a2)=.5; not a fitted-root null, endpoint inversion or power study",
      generator="Four nuisance values fitted under the observed null; known roster-specific ability mixtures; fixed counts/exposures and all extreme Persons retained",
      statistic="Recompute complete order-2 profiles, correction, two-start nuisance solve, nonsymmetric derivative, projection and within-roster variance in every draw",
      reference="Inclusive absolute statistic and (1+exceedances)/100; first logical completion, never a prefix denominator or approximate p-value stopping",
      failures="Save every attempted input and fit; nonfinite statistics unknown, no replacements or one-case rescue; unresolved final bounds remain unresolved",
      streams="792 independent L'Ecuyer streams frozen after the reference bank; one per case/draw, including unattempted suffixes; no outcome-dependent stream reuse",
      precision="B=99 has p-grid .01; eight development views cannot assess coverage. Later R=99/cell has MCSE .02190 at .05 and .94047 pointwise power against .15; not a qualification allocation here",
      cost="At most 792 inner fits; prior eight complete banks cost 469.232 s generation/calculation, not a hard time bound; low-T replay 48.255 s does not forecast tail cost",
      decision="Complete all eight declared cases to a logical decision or B exhaustion, audit/replay, then decide outer allocation; no automatic larger batch, B increase or public-method adoption"))
  save_new(m,file.path(out,"manifest.rds"))
  cat("Frozen eight development cases, B=99, 792 independent planned streams; no outer simulation.\n")
  quit(save="no")
}

out <- normalizePath(out);m <- readRDS(file.path(out,"manifest.rds"))
check(m$source);check(m$inputs)
stopifnot(identical(unname(tools::md5sum(script)),unname(m$source)),
  identical(m$R,R.version),identical(m$threads,Sys.getenv(threads)))
old <- readRDS(file.path(m$prior,"manifest.rds"));check(old$source)
seal <- tools::md5sum(file.path(out,"manifest.rds"))
score <- read_function(file.path(m$reference,"source.R"),"score")

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
  for(i in seq_len(nrow(m$jobs))) {
    job <- m$jobs[i,];d <- old$designs[[job$Design]]
    d$truth <- m$sources[[i]]$calculation$beta
    obs <- m$sources[[i]]$calculation$statistic$T
    values <- numeric();state <- completion(obs,values,m$B,m$alpha)
    for(b in seq_len(m$B)) {
      if(state$decision!="continue")break
      stream <- m$streams[[(i-1L)*m$B+b]]
      ip <- file.path(out,sprintf("input-%02d-%03d.rds",i,b))
      if(!file.exists(ip)) {
        timer <- proc.time()[["elapsed"]];input <- generate(d,job$N,stream)
        save_new(list(manifest=seal,job=job,draw=b,beta=d$truth,input=input,
          seconds=proc.time()[["elapsed"]]-timer),ip)
      }
      input <- readRDS(ip);ih <- tools::md5sum(ip)
      stopifnot(identical(input$manifest,seal),identical(input$job,job),input$draw==b,
        identical(input$beta,d$truth),identical(input$input$stream,stream))
      fp <- file.path(out,sprintf("fit-%02d-%03d.rds",i,b))
      if(!file.exists(fp)) {
        timer <- proc.time()[["elapsed"]]
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
        save_new(list(manifest=seal,input=ih,job=job,draw=b,calculation=calc,
          seconds=proc.time()[["elapsed"]]-timer),fp)
      }
      fit <- readRDS(fp)
      stopifnot(identical(fit$manifest,seal),identical(fit$input,ih),identical(fit$job,job),fit$draw==b)
      values <- c(values,if(isTRUE(fit$calculation$available))fit$calculation$statistic$T else NA_real_)
      state <- completion(obs,values,m$B,m$alpha)
    }
    stopifnot(state$decision!="continue")
    result <- list(manifest=seal,job=job,observed=obs,values=values,state=state)
    path <- file.path(out,sprintf("case-%02d.rds",i))
    if(file.exists(path))near(result,readRDS(path),0) else save_new(result,path)
    cat("Case",i,"of 8:",state$decision,"after",state$attempted,"attempts; elapsed",
      proc.time()[["elapsed"]]-timer_run,"seconds\n");flush.console()
  }
  cat("All eight declared cases complete; run seconds",proc.time()[["elapsed"]]-timer_run,"\n")
  quit(save="no")
}

stopifnot(!exists(".Random.seed",.GlobalEnv),!"mfrmr"%in%loadedNamespaces(),!"nleqslv"%in%loadedNamespaces())
rows <- draws <- list();files <- character()
for(i in seq_len(nrow(m$jobs))) {
  job <- m$jobs[i,];path <- file.path(out,sprintf("case-%02d.rds",i));case <- readRDS(path)
  stopifnot(identical(case$manifest,seal),identical(case$job,job))
  near(case$observed,m$sources[[i]]$calculation$statistic$T,0)
  s <- completion(case$observed,case$values,m$B,m$alpha);near(s,case$state,0)
  stopifnot(s$decision!="continue")
  files <- c(files,path);seconds <- 0
  if(s$attempted)for(b in seq_len(s$attempted)) {
    stopifnot(completion(case$observed,case$values[seq_len(b-1L)],m$B,m$alpha)$decision=="continue")
    ip <- file.path(out,sprintf("input-%02d-%03d.rds",i,b));input <- readRDS(ip)
    fp <- file.path(out,sprintf("fit-%02d-%03d.rds",i,b));x <- readRDS(fp);check(x$input)
    stopifnot(identical(input$manifest,seal),identical(x$manifest,seal),
      identical(input$job,job),identical(x$job,job),input$draw==b,x$draw==b,
      identical(input$beta,m$sources[[i]]$calculation$beta),
      identical(input$input$stream,m$streams[[(i-1L)*m$B+b]]))
    z <- x$calculation;T <- NA_real_
    if(isTRUE(z$available)) {
      stat <- score(z$U,z$A,z$groups);near(stat,z$statistic)
      stopifnot(z$solve$available,z$solve$spread<=m$policy$root_agreement_tolerance,
        stat$nuisance_residual<=m$policy$equation_tolerance,stat$projection_residual<1e-10)
      err <- max(abs(z$A_coarse-z$A))/max(1,max(abs(z$A)));near(err,z$derivative_error)
      stopifnot(err<=1e-5,z$beta[5]==input$beta[5],identical(z$groups,split(seq_len(job$N),input$input$roster)))
      T <- stat$T
    }
    near(T,case$values[b]);elapsed <- input$seconds+x$seconds;seconds <- seconds+elapsed
    draws[[length(draws)+1L]] <- data.frame(Case=i,Draw=b,Available=z$available,Reason=z$reason,
      T=T,Seconds=elapsed,Attempts=length(z$solve$attempts))
    files <- c(files,ip,fp)
  }
  stopifnot(length(list.files(out,pattern=sprintf("^input-%02d-[0-9]{3}\\.rds$",i)))==s$attempted,
    length(list.files(out,pattern=sprintf("^fit-%02d-[0-9]{3}\\.rds$",i)))==s$attempted)
  rows[[i]] <- data.frame(job,Observed=case$observed,Decision=s$decision,Attempted=s$attempted,
    Failed=s$failed,Unattempted=s$unattempted,Lower=s$lower,Upper=s$upper,Seconds=seconds)
}
rows <- do.call(rbind,rows);draws <- do.call(rbind,draws)
report <- list(manifest=seal,results=tools::md5sum(files),rows=rows,draws=draws,
  phase_seconds=sum(rows$Seconds),scope=m$contract$roles)
fp <- file.path(out,"report.rds")
if(file.exists(fp))near(report,readRDS(fp),0) else {
  save_new(report,fp);write.csv(rows,file.path(out,"rows.csv"),row.names=FALSE)
  write.csv(draws,file.path(out,"draws.csv"),row.names=FALSE)
}
stopifnot(!exists(".Random.seed",.GlobalEnv),!"mfrmr"%in%loadedNamespaces(),!"nleqslv"%in%loadedNamespaces())
print(rows,row.names=FALSE)
cat("Saved-only replay passed;",nrow(draws),"inner attempts, phase seconds",report$phase_seconds,"\n")
