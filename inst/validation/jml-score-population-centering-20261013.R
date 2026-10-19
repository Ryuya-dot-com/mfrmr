# Finite-support population centering; no response simulation or coverage claim.
args <- commandArgs(TRUE)
stopifnot(length(args)==1L,args %in% c("prepare","run","replay"))
action <- args[1]
script <- "inst/validation/jml-score-population-centering-20261013.R"
out <- "validation-results/jml-score-population-centering-20261013"
prior <- "validation-results/jml-small-pilot-20261013"
growth <- "validation-results/jml-exposure-roots-20261001"
bank <- "validation-results/jml-score-calibration-20261013"
threads <- c("OMP_NUM_THREADS","OPENBLAS_NUM_THREADS","MKL_NUM_THREADS","VECLIB_MAXIMUM_THREADS")
for(x in parse(file.path(bank,"source.R")))
  if(is.call(x)&&identical(x[[1]],as.name("<-"))&&identical(x[[2]],as.name("read_function")))eval(x)
for(n in c("check","near","save_new"))assign(n,read_function(file.path(bank,"source.R"),n))
project <- function(mean,meat,A) {
  sv <- min(svd(A[1:4,1:4],nu=0,nv=0)$d)
  stopifnot(sv>1e-6)
  w <- c(-solve(t(A[1:4,1:4]),A[5,1:4]),1)
  b <- sum(w*mean);v <- drop(w%*%meat%*%w)
  stopifnot(is.finite(v),v>0,max(abs(drop(w%*%A)[1:4]))<1e-10)
  list(w=w,b=b,variance=v,drift=b/sqrt(v),min_sv=sv)
}
if(action=="prepare") {
  stopifnot(!dir.exists(out),all(Sys.getenv(threads)=="1"))
  old <- readRDS(file.path(prior,"manifest.rds"));check(old$source)
  gm <- readRDS(file.path(growth,"manifest.rds"));bm <- readRDS(file.path(bank,"manifest.rds"))
  check(bm$source);check(bm$inputs)
  helpers <- c("jml-exposure-roots-20261001.R","jml-total-expectation-20260927.R","jml-exposure-expansion-20260930.R")
  original <- file.path("inst/validation",helpers)
  frozen <- file.path(growth,"source",original)
  stopifnot(identical(unname(tools::md5sum(frozen)),unname(gm$hashes[original])))
  references <- unlist(old$population,use.names=FALSE)
  jobs <- expand.grid(Design=1:2,L=1:2)
  dir.create(out,recursive=TRUE);stopifnot(file.copy(script,file.path(out,"source.R")))
  m <- list(source=tools::md5sum(file.path(out,"source.R")),
    inputs=tools::md5sum(c(file.path(prior,"manifest.rds"),file.path(growth,"manifest.rds"),
      file.path(bank,c("source.R","manifest.rds")),file.path(bm$reference,"source.R"),
      "inst/validation/jml-score-plugin-overlap-20261013.R",frozen,references)),
    prior=normalizePath(prior),reference=bm$reference,helpers=setNames(normalizePath(frozen),helpers),
    references=old$population,jobs=jobs,policy=bm$policy,R=R.version,
    threads=Sys.getenv(threads),packages=bm$packages,
    contract=list(aim="Population drift under the true law and its null-constrained plug-in limit",
      allocation="Four design/exposure cells; two population nuisance roots each; no N-specific refits, response draws or new observed-data fits",
      laws="Known roster ability mixture; gamma0=original truth, gamma1=(lambda_bar(gamma0),beta5=.25); re-solve nuisance under gamma1",
      equations="Reuse complete order-2 owner-total expectations and full within-roster response covariance; never use between-total variance alone",
      root="Original two starts/stages/maxit400 and independent residual/Newton-step checks; retain every attempt; no rescue policy changes",
      precision="Full nonsymmetric derivative at 1e-4 and 5e-5, relative agreement <=1e-5; nuisance singular >1e-6; both roots agree <=1e-6",
      comparison="Signed b/s and absolute drift gap; report derivative-step sensitivity and root residuals; no rounded equality or coverage threshold",
      checks="Reuse old full roots to check old mean/meat; compare new mean/meat with full count enumeration through frozen native package",
      interpretation="For |T|, a stable nonzero gap in |b|/s is evidence against leading-drift matching; double precision is not an outward-rounded proof",
      scales=c(20L,60L,240L,400L,480L),
      limit="Scaled drifts are LLN leading terms, not finite-N expected statistics, rejection rates or confidence limits",
      stop="No inner/outer bootstrap allocation, estimated ability law, higher adjustment order or endpoint search follows automatically"))
  save_new(m,file.path(out,"manifest.rds"));cat("Frozen 4 design/exposure cells, 8 population nuisance roots.\n")
  quit(save="no")
}
out <- normalizePath(out);m <- readRDS(file.path(out,"manifest.rds"))
check(m$source);check(m$inputs)
stopifnot(identical(unname(tools::md5sum(script)),unname(m$source)),
  identical(m$R,R.version),identical(m$threads,Sys.getenv(threads)))
old <- readRDS(file.path(m$prior,"manifest.rds"));check(old$source)
seal <- tools::md5sum(file.path(out,"manifest.rds"))
if(action=="run") {
  started <- proc.time()[["elapsed"]]
  stopifnot(identical(m$packages,vapply(names(m$packages),function(p)as.character(packageVersion(p)),"")))
  library(mfrmr,lib.loc=file.path(m$prior,"library"))
  stopifnot(identical(normalizePath(find.package("mfrmr")),file.path(m$prior,"library/mfrmr")))
  for(n in c("jml_count_moments","jml_count_derivative","make_jml_growth_roster","make_jml_growth_equation"))
    assign(n,read_function(m$helpers[["jml-exposure-roots-20261001.R"]],n))
  make_jml_total_problem <- read_function(m$helpers[["jml-total-expectation-20260927.R"]],"make_jml_total_problem")
  jml_total_mass <- read_function(m$helpers[["jml-exposure-expansion-20260930.R"]],"jml_total_mass")
  root <- read_function(file.path(m$reference,"source.R"),"root")
  jac <- mfrmr:::mfrmr_numeric_transformation_jacobian
  for(n in c("patterns","log_mass","log_sum"))
    assign(n,read_function("inst/validation/jml-score-plugin-overlap-20261013.R",n))
  jml_observed_long <- read_function(file.path(m$prior,"source/inst/validation/jml-observed-inference-20261001.R"),"jml_observed_long")
  for(i in seq_len(nrow(m$jobs))) {
    job <- m$jobs[i,];d <- old$designs[[job$Design]];gamma <- d$truth
    for(law in c("truth","plugin_limit")) {
      fp <- file.path(out,sprintf("cell-%d-%s.rds",i,law))
      if(file.exists(fp)) {
        saved <- readRDS(fp);stopifnot(identical(saved$manifest,seal),identical(saved$generator,gamma))
        if(!isTRUE(saved$available))break
        gamma <- saved$beta;next
      }
      timer <- proc.time()[["elapsed"]]
      eq <- make_jml_growth_equation(d$owner,d,job$L,gamma,2L)
      prior_checks <- NULL
      if(law=="truth") {
        ref <- readRDS(m$references[[job$Design]][[job$L]])
        prev <- eq$evaluate(ref$root)
        prior_checks <- c(mean=max(abs(prev$mean-ref$meat$mean)),meat=max(abs(prev$meat-ref$meat$meat)))
        stopifnot(max(prior_checks)<1e-8)
      }
      fn <- function(lambda)eq$mean_score(c(lambda,gamma[5]))[-5L]
      solved <- root(fn,m$policy)
      if(!solved$available) {
        save_new(list(manifest=seal,job=job,law=law,generator=gamma,available=FALSE,
          solve=solved,seconds=proc.time()[["elapsed"]]-timer),fp);break
      }
      beta <- c(solved$beta,gamma[5]);ev <- eq$evaluate(beta)
      derivatives <- lapply(c(1e-4,5e-5),function(h)jac(eq$mean_score,beta,h))
      stopifnot(all(vapply(derivatives,`[[`,TRUE,"valid")))
      A <- derivatives[[2]]$jacobian;Ac <- derivatives[[1]]$jacobian
      derivative_error <- max(abs(A-Ac))/max(1,max(abs(A)))
      stopifnot(derivative_error<=1e-5,max(abs(ev$mean[1:4]))<=m$policy$equation_tolerance)
      s <- project(ev$mean,ev$meat,A);sc <- project(ev$mean,ev$meat,Ac)
      # Full response counts retain variation within owner totals independently.
      native <- lapply(seq_along(d$proportions),function(g) {
        counts <- patterns(job$L*d$exposure[[g]])
        weight <- exp(log_mass(counts,d,gamma,g));stopifnot(abs(sum(weight)-1)<1e-12)
        data <- jml_observed_long(counts,d$cells)
        p <- mfrmr:::mfrm_jml_adjustment_problem(data,"Person",c("Rater","Criterion"),"Score",d$owner,2L)
        stopifnot(nrow(p$parameters)==5L,p$parameters$Type[5]=="log_slope")
        U <- p$evaluate(beta,2L)$value
        stopifnot(nrow(U)==length(weight))
        mu <- drop(crossprod(weight,U));E <- sweep(U,2,mu)
        meat <- crossprod(E,weight*E)
        z <- ev$rosters[[g]]
        error <- c(mean=max(abs(mu-z$mean)),meat=max(abs(meat-z$meat)))
        stopifnot(max(error)<1e-8)
        list(weight=weight,U=U,mean=mu,meat=meat,error=error,patterns=length(weight))
      })
      save_new(list(manifest=seal,job=job,law=law,generator=gamma,available=TRUE,
        solve=solved,beta=beta,A=A,A_coarse=Ac,derivative_error=derivative_error,
        evaluation=ev,statistic=s,coarse=sc,native=native,prior_checks=prior_checks,
        states=vapply(eq$rosters,`[[`,0,"states"),seconds=proc.time()[["elapsed"]]-timer),fp)
      gamma <- beta
      cat("Completed cell",i,law,"drift",s$drift,"seconds",proc.time()[["elapsed"]]-timer,"\n");flush.console()
    }
  }
  stopifnot(!exists(".Random.seed",.GlobalEnv))
  cat("Population calculation complete, run seconds",proc.time()[["elapsed"]]-started,"\n")
  quit(save="no")
}

stopifnot(!"mfrmr"%in%loadedNamespaces(),!"nleqslv"%in%loadedNamespaces(),!exists(".Random.seed",.GlobalEnv))
files <- character();rows <- summaries <- list();seconds <- 0
for(i in seq_len(nrow(m$jobs))) {
  job <- m$jobs[i,];d <- old$designs[[job$Design]];z <- list()
  for(law in c("truth","plugin_limit")) {
    fp <- file.path(out,sprintf("cell-%d-%s.rds",i,law));x <- readRDS(fp)
    stopifnot(identical(x$manifest,seal),identical(x$job,job),x$available)
    files <- c(files,fp);seconds <- seconds+x$seconds;e <- x$evaluation
    near(project(e$mean,e$meat,x$A),x$statistic)
    near(project(e$mean,e$meat,x$A_coarse),x$coarse)
    mean <- meat <- NULL
    for(g in seq_along(x$native)) {
      a <- x$native[[g]];mu <- drop(crossprod(a$weight,a$U));E <- sweep(a$U,2,mu)
      B <- crossprod(E,a$weight*E);near(mu,a$mean);near(B,a$meat)
      stopifnot(max(abs(mu-e$rosters[[g]]$mean))<1e-8,max(abs(B-e$rosters[[g]]$meat))<1e-8)
      mean <- if(is.null(mean))d$proportions[g]*mu else mean+d$proportions[g]*mu
      meat <- if(is.null(meat))d$proportions[g]*B else meat+d$proportions[g]*B
    }
    near(mean,e$mean,1e-8);near(meat,e$meat,1e-8)
    s <- x$statistic
    rows[[length(rows)+1]] <- data.frame(job,Owner=d$owner,Law=law,Mean=s$b,SD=sqrt(s$variance),
      Drift=s$drift,AbsDrift=abs(s$drift),NuisanceResidual=max(abs(e$mean[1:4])),
      RootSpread=x$solve$spread,DerivativeError=x$derivative_error,
      DriftStepDifference=abs(s$drift-x$coarse$drift),MinSingular=s$min_sv,
      NativeMeanError=max(vapply(x$native,function(a)a$error[1],0)),
      NativeMeatError=max(vapply(x$native,function(a)a$error[2],0)),Seconds=x$seconds)
    z[[law]] <- x
  }
  near(z$truth$generator,d$truth);near(z$plugin_limit$generator,z$truth$beta)
  a <- z$truth$statistic$drift;b <- z$plugin_limit$statistic$drift
  coarse_gap <- abs(z$plugin_limit$coarse$drift)-abs(z$truth$coarse$drift)
  gap <- abs(b)-abs(a)
  summaries[[i]] <- data.frame(job,Owner=d$owner,TruthDrift=a,PluginDrift=b,
    SignedGap=b-a,AbsGap=gap,GapStepDifference=abs(gap-coarse_gap),
    NuisanceDisplacement=max(abs(z$truth$beta[-5]-d$truth[-5])))
}
rows <- do.call(rbind,rows);summary <- do.call(rbind,summaries)
scaled <- do.call(rbind,lapply(m$contract$scales,function(N)
  transform(summary,N=N,TruthLeading=sqrt(N)*TruthDrift,PluginLeading=sqrt(N)*PluginDrift,
    AbsLeadingGap=sqrt(N)*AbsGap)))
report <- list(manifest=seal,results=tools::md5sum(files),rows=rows,summary=summary,scaled=scaled,
  seconds=seconds,scope="Finite-support conditional population centering, not coverage or an interval implementation")
fp <- file.path(out,"report.rds")
if(file.exists(fp))near(report,readRDS(fp)) else {
  save_new(report,fp);write.csv(rows,file.path(out,"rows.csv"),row.names=FALSE)
  write.csv(summary,file.path(out,"summary.csv"),row.names=FALSE)
  write.csv(scaled,file.path(out,"scaled.csv"),row.names=FALSE)
}
print(summary,row.names=FALSE);print(rows,row.names=FALSE)
cat("Saved-only replay passed, calculation seconds",seconds,"\n")
