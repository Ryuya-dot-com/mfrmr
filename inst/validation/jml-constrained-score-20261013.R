# Retained-input feasibility, not a confidence interval or coverage study.
args <- commandArgs(TRUE)
stopifnot(length(args) == 1L, args %in% c("prepare", "run", "replay"))
action <- args[1L]
out <- "validation-results/jml-constrained-score-20261013"
prior <- "validation-results/jml-small-pilot-20261013"
script <- "inst/validation/jml-constrained-score-20261013.R"
threads <- c("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")
check <- function(h) stopifnot(length(h) > 0L, !anyNA(h), identical(tools::md5sum(names(h)), h))
near <- function(x, y, tol=1e-10) stopifnot(isTRUE(all.equal(unname(x), unname(y), tolerance=tol)))
save_new <- function(x, path) {
  stopifnot(!file.exists(path)); saveRDS(x, paste0(path, ".tmp"))
  stopifnot(file.rename(paste0(path, ".tmp"), path))
}

# Interest is the last coordinate; the other coordinates remain unrestricted.
# Do not invert full A or symmetrize it. Center only for variance, not the sum.
score <- function(U, A, groups) {
  p <- ncol(U); nuisance <- seq_len(p-1L)
  sv <- svd(A[nuisance,nuisance,drop=FALSE], nu=0, nv=0)$d
  if (min(sv) <= 1e-6 || any(lengths(groups) < 2L))
    return(list(available=FALSE, reason="nuisance conditioning or roster size", min_sv=min(sv)))
  w <- c(-drop(solve(t(A[nuisance,nuisance,drop=FALSE]), A[p,nuisance])), 1)
  u <- drop(U %*% w); centered <- u
  for (g in groups) centered[g] <- u[g]-mean(u[g])
  variance <- sum(centered^2)
  if (!is.finite(variance) || variance <= 0)
    return(list(available=FALSE, reason="projected variance", min_sv=min(sv)))
  list(available=TRUE, reason="", T=sum(u)/sqrt(variance), w=w,
    numerator=sum(u), variance=variance, min_sv=min(sv),
    schur=drop(w %*% A[,p]), nuisance_residual=max(abs(colMeans(U)[nuisance])),
    projection_residual=max(abs(drop(w %*% A)[nuisance])),
    numerator_adjustment=sum(u)-sum(U[,p]))
}

self_check <- function() {
  A <- matrix(c(2,.3,-.2, -.1,1.6,.4, .5,-.3,1.2),3,byrow=TRUE)
  E <- cbind(sin(1:12), cos((1:12)*.8), sin((1:12)*1.7))
  groups <- list(1:6,7:12)
  for (g in groups) E[g,] <- sweep(E[g,,drop=FALSE],2,colMeans(E[g,,drop=FALSE]))
  root <- c(.1,-.2,.3); null <- -.4
  b <- c(root[1:2]-solve(A[1:2,1:2], A[1:2,3]*(null-root[3])),null)
  U <- sweep(E,2,drop(A %*% (b-root)),"+")
  s <- score(U,A,groups); V <- solve(A) %*% crossprod(E) %*% t(solve(A))/nrow(E)^2
  near(s$T, sign(s$schur)*(null-root[3])/sqrt(V[3,3]))
  near(s$numerator, sum(U[,3])); near(s$projection_residual,0)
  C <- diag(c(1,1,.5)) # beta_3=psi/2, with the equation transformed too.
  near(score(U %*% C, C %*% A %*% C,groups)$T, s$T)
  singular <- A; singular[3,] <- A[1,] + A[2,]
  weak <- score(U,singular,groups)
  stopifnot(weak$available, abs(det(singular)) < 1e-12, abs(weak$schur) < 1e-12)
  stopifnot(!score(matrix(0,12,3), A,groups)$available)
  bad <- A; bad[1:2,1:2] <- 0
  stopifnot(!score(U,bad,groups)$available)
  list(linear_T=s$T, full_singular_T=weak$T, passed=TRUE)
}
control <- self_check()
if (action == "prepare") {
  stopifnot(!dir.exists(out), all(Sys.getenv(threads) == "1"))
  old <- readRDS(file.path(prior,"manifest.rds")); done <- readRDS(file.path(prior,"completion.rds"))
  check(old$source); check(old$inputs); check(done$results)
  dir.create(out,recursive=TRUE); stopifnot(file.copy(script,file.path(out,"source.R")))
  m <- list(inputs=tools::md5sum(c(file.path(prior,c("manifest.rds","completion.rds")),
      names(done$results), names(old$inputs))), source=tools::md5sum(file.path(out,"source.R")),
    prior=normalizePath(prior), jobs=old$jobs, R=R.version, threads=Sys.getenv(threads),
    packages=vapply(c("nleqslv","Matrix","statmod","cpp11"), function(p) as.character(packageVersion(p)), ""),
    protocol=list(contrast="psi=log(a_1/a_2)=2*beta_5, within the declared shared owner",
      allocation="All 16 retained views (8 independent parents), 2 nulls each; no new responses",
      nulls=c("structural_truth","population_root"), order=2L,
      law="Independent new Persons within fixed roster counts; retain all extremes",
      solver="Original two starts restricted to nuisance coordinates, original three stages and maxit 400; no continuation/rescue",
      eligibility="Both starts pass original residual/step/rank checks and agree; full derivative step agreement <=1e-5; nuisance min singular value >1e-6; positive projected variance",
      derivative_steps=c(1e-4,5e-5), normal_cutoff=qnorm(.975),
      comparison="T uses the negative-score sign; Wald=(psi_null-psi_hat)/SE at the saved unrestricted root",
      limitation="Two starts do not certify uniqueness; finite-exposure structural bias is distinct from population-root calibration",
      decision="Constrained feasibility and complete marginal cost, not coverage, endpoints, ability-generator selection or bootstrap"))
  check(m$inputs); save_new(m,file.path(out,"manifest.rds"))
  cat("Frozen 32 null problems, two nuisance starts each; nonsymmetric/coordinate/singular controls passed.\n")
  quit(save="no")
}
out <- normalizePath(out); m <- readRDS(file.path(out,"manifest.rds"))
check(m$inputs); check(m$source)
stopifnot(identical(unname(tools::md5sum(script)),unname(m$source)),
  identical(m$R,R.version), identical(m$threads,Sys.getenv(threads)))
seal <- tools::md5sum(file.path(out,"manifest.rds"))
old <- readRDS(file.path(m$prior,"manifest.rds")); check(old$source)

if (action == "run") {
  stopifnot(identical(m$packages,vapply(names(m$packages),function(p) as.character(packageVersion(p)),"")))
  library(mfrmr,lib.loc=file.path(m$prior,"library"))
  stopifnot(identical(normalizePath(find.package("mfrmr")),file.path(m$prior,"library/mfrmr")))
  setwd(file.path(m$prior,"source")); source("inst/validation/jml-observed-inference-20261001.R")
  jac <- mfrmr:::mfrmr_numeric_transformation_jacobian
  # Keep the existing bounded root policy; evaluate complete equations at every beta.
  root <- function(fn, policy) {
    attempts <- roots <- list(); timer <- proc.time()[["elapsed"]]
    for (s in seq_along(policy$starts)) for (stage in seq_len(nrow(policy$stages))) {
      setting <- policy$stages[stage,]; warnings <- character()
      a <- tryCatch(withCallingHandlers({
        z <- nleqslv::nleqslv(policy$starts[[s]],fn,method=setting$method,global=setting$global,
          control=list(maxit=policy$maxit,ftol=policy$ftol,xtol=policy$xtol,
            stepmax=setting$stepmax,allowSingular=FALSE))
        residual <- max(abs(fn(z$x))); ok <- is.finite(residual) && residual <= policy$equation_tolerance
        step <- NA_real_
        if (ok) {
          J <- jac(fn,z$x,policy$jacobian_step); ok <- J$valid
          if (ok) {
            sv <- svd(J$jacobian,nu=0,nv=0)$d
            ok <- min(sv) > max(sv)*length(z$x)*.Machine$double.eps
          }
          if (ok) { step <- max(abs(solve(J$jacobian,fn(z$x)))); ok <- step <= policy$root_step_tolerance }
        }
        list(beta=z$x,available=ok,residual=residual,step=step,solver=z)
      },warning=function(w) { warnings <<- c(warnings,conditionMessage(w)); invokeRestart("muffleWarning") }),
        error=function(e) list(available=FALSE,error=conditionMessage(e)))
      a$start <- s; a$stage <- stage; a$warnings <- warnings
      attempts[[length(attempts)+1L]] <- a
      if (isTRUE(a$available)) { roots[[length(roots)+1L]] <- a$beta; break }
    }
    spread <- if(length(roots)) max(vapply(roots,function(b) max(abs(b-roots[[1]])),0)) else NA_real_
    ok <- length(roots)==length(policy$starts) && spread <= policy$root_agreement_tolerance
    list(available=ok,beta=if(ok) roots[[1]] else NULL,spread=spread,attempts=attempts,
      seconds=proc.time()[["elapsed"]]-timer)
  }
  for (j in seq_len(nrow(m$jobs))) {
    paths <- file.path(out,sprintf("case-%02d-%s.rds",j,m$protocol$nulls))
    if (all(file.exists(paths))) next
    job <- m$jobs[j,]; d <- old$designs[[job$Design]]; timer <- proc.time()[["elapsed"]]
    base <- readRDS(file.path(m$prior,sprintf("fit-%02d-L%d.rds",job$Parent,job$L)))$fit$result
    input <- readRDS(file.path(m$prior,sprintf("input-%02d.rds",job$Parent)))$input
    population <- readRDS(file.path(m$prior,"../..",old$population[[job$Design]][[job$L]]))
    data <- jml_observed_long(input$counts[[as.character(job$L)]],d$cells)
    problem <- mfrmr:::mfrm_jml_adjustment_problem(data,"Person",c("Rater","Criterion"),"Score",d$owner,2L)
    stopifnot(identical(problem$parameters,base$parameters),nrow(problem$parameters)==5L,
      problem$parameters$Type[5L]=="log_slope",base$point$available,base$covariance$available,
      isTRUE(population$status$Reviewed))
    groups <- split(seq_len(job$N),problem$roster)
    policy <- base$policy; policy$starts <- lapply(policy$starts,function(b) b[-5L])
    setup_seconds <- proc.time()[["elapsed"]]-timer
    for (h in seq_along(paths)) {
      if (file.exists(paths[h])) next
      null <- m$protocol$nulls[h]; b0 <- if(h==1L) d$truth[5L] else population$root[5L]
      timer <- proc.time()[["elapsed"]]
      fn <- function(lambda) problem$mean_score(c(lambda,b0),2L)[-5L]
      solved <- root(fn,policy)
      calc <- tryCatch({
        if (!solved$available) list(available=FALSE,reason="nuisance roots unavailable or inconsistent") else {
          beta <- c(solved$beta,b0); ev <- problem$evaluate(beta,2L)
          derivative <- lapply(m$protocol$derivative_steps,function(h)
            jac(function(b) problem$mean_score(b,2L),beta,h))
          valid <- all(vapply(derivative,`[[`,TRUE,"valid"))
          A <- derivative[[2]]$jacobian
          error <- if(valid) max(abs(derivative[[1]]$jacobian-A))/max(1,max(abs(A))) else Inf
          stat <- if(error <= 1e-5) score(ev$value,A,groups) else
            list(available=FALSE,reason="complete derivative step instability")
          list(available=stat$available,reason=stat$reason,beta=beta,U=ev$value,A=A,
            A_coarse=derivative[[1]]$jacobian,derivative_error=error,statistic=stat,
            extreme_persons=sum(!is.finite(ev$theta)))
        }
      },error=function(e) list(available=FALSE,reason=conditionMessage(e)))
      item <- list(manifest=seal,job=job,owner=d$owner,null=null,psi_null=2*unname(b0),
        psi_hat=2*base$point$beta[5L],se=2*sqrt(base$covariance$result$vcov[5L,5L]),
        groups=groups,policy=policy,solve=solved,calculation=calc,setup_seconds=setup_seconds,
        calculation_seconds=proc.time()[["elapsed"]]-timer)
      # Charge setup to each null for standalone cost; paired total counts it once.
      item$total_seconds <- item$setup_seconds+item$calculation_seconds
      save_new(item,paths[h])
      cat(sprintf("view %02d / %-16s: available=%s, %.3f seconds\n",j,null,calc$available,item$total_seconds))
    }
  }
  quit(save="no")
}

# Fresh-session arithmetic replay: no package loading, derivatives or root solves.
stopifnot(!"mfrmr" %in% loadedNamespaces(),!"nleqslv" %in% loadedNamespaces())
files <- unlist(lapply(seq_len(nrow(m$jobs)),function(j)
  file.path(out,sprintf("case-%02d-%s.rds",j,m$protocol$nulls))))
rows <- lapply(files,function(path) {
  x <- readRDS(path); stopifnot(identical(x$manifest,seal))
  z <- x$calculation; T <- derivative_error <- min_sv <- schur <- NA_real_
  if (isTRUE(z$available)) {
    s <- score(z$U,z$A,x$groups); near(s,z$statistic)
    derivative_error <- max(abs(z$A_coarse-z$A))/max(1,max(abs(z$A)))
    stopifnot(derivative_error <= 1e-5,s$nuisance_residual <= x$policy$equation_tolerance,
      s$projection_residual < 1e-10,x$solve$available)
    # Independent block expression and summed cross-product variance.
    coefficient <- z$A[5L,-5L,drop=FALSE] %*% solve(z$A[-5L,-5L,drop=FALSE])
    projected <- z$U[,5L]-drop(z$U[,-5L,drop=FALSE] %*% t(coefficient))
    E <- z$U
    for (g in x$groups) E[g,] <- sweep(z$U[g,,drop=FALSE],2,colMeans(z$U[g,,drop=FALSE]))
    variance <- drop(c(-coefficient,1) %*% crossprod(E) %*% c(-coefficient,1))
    near(s$T,sum(projected)/sqrt(variance))
    bound <- nrow(z$U)*sum(abs(s$w[-5L]))*s$nuisance_residual+1e-10
    stopifnot(abs(s$numerator_adjustment) <= bound)
    C <- diag(c(1,1,1,1,.5)); near(score(z$U %*% C,C %*% z$A %*% C,x$groups)$T,s$T)
    T <- s$T; min_sv <- s$min_sv; schur <- s$schur
  }
  W <- (x$psi_null-x$psi_hat)/x$se
  data.frame(x$job,Owner=x$owner,Null=x$null,Available=z$available,Reason=z$reason,
    PsiNull=x$psi_null,PsiHat=x$psi_hat,SE=x$se,T=T,Wald=W,
    ScoreAccept=if(is.finite(T)) abs(T)<=m$protocol$normal_cutoff else NA,
    WaldAccept=abs(W)<=m$protocol$normal_cutoff,MinNuisanceSingular=min_sv,
    Schur=schur,DerivativeError=derivative_error,RootSpread=x$solve$spread,
    Attempts=length(x$solve$attempts),SetupSeconds=x$setup_seconds,
    SolveSeconds=x$solve$seconds,CalculationSeconds=x$calculation_seconds,
    TotalSeconds=x$total_seconds)
})
rows <- do.call(rbind,rows)
report <- list(manifest=seal,results=tools::md5sum(files),control=control,rows=rows,
  paired_seconds=sum(rows$CalculationSeconds)+sum(rows$SetupSeconds[!duplicated(rows[c("Parent","L")])]),
  interpretation="32 fixed nulls from 8 independent parents / 16 nested views; engineering results, not coverage or interval endpoints")
path <- file.path(out,"report.rds")
if (file.exists(path)) near(report,readRDS(path)) else {
  save_new(report,path); write.csv(rows,file.path(out,"summary.csv"),row.names=FALSE)
}
print(rows[,c("Owner","N","Replicate","L","Null","Available","T","Wald","ScoreAccept","WaldAccept","TotalSeconds")],row.names=FALSE)
cat("Fresh arithmetic replay passed; paired seconds:",report$paired_seconds,"\n")
