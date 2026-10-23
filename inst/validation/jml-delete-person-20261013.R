# Fixed-roster deletion sensitivity: no new responses and no interval qualification.
args <- commandArgs(TRUE)
stopifnot(length(args) == 1L, args %in% c("prepare", "run", "replay"))
action <- args[1]; script <- "inst/validation/jml-delete-person-20261013.R"
out <- "validation-results/jml-delete-person-20261013"
prior <- "validation-results/jml-small-pilot-20261013"
threads <- c("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")
check <- function(h) stopifnot(length(h) > 0L, !anyNA(h), identical(tools::md5sum(names(h)), h))
save_new <- function(x, p) {
  stopifnot(!file.exists(p)); saveRDS(x, paste0(p, ".tmp"))
  stopifnot(file.rename(paste0(p, ".tmp"), p))
}
near <- function(a, b, tol = 1e-9) stopifnot(length(a) == length(b), max(abs(a - b)) < tol)
jack_cov <- function(delta, groups) Reduce(`+`, lapply(groups, function(ix) {
  x <- sweep(delta[ix, , drop = FALSE], 2, colMeans(delta[ix, , drop = FALSE]))
  (length(ix) - 1) / length(ix) * crossprod(x)
}))
# Independent affine-equation control: updated-Jacobian deletion is exact,
# and holding the Jacobian fixed is exactly the finite-roster sandwich.
affine_control <- function() {
  N <- 5L; p <- 2L; groups <- list(1:3, 4:5)
  D <- lapply(1:N, function(i) matrix(c(1 + i/10, -.2, .3, 2 + i/5), 2))
  a <- cbind(c(-1, 2, 0, 3, -2), c(2, -1, 3, -2, 1))
  A <- Reduce(`+`, D)/N; beta <- -solve(A, colMeans(a))
  U <- t(vapply(1:N, function(i) a[i, ] + D[[i]] %*% beta, numeric(p)))
  fixed <- delta <- matrix(NA_real_, N, p); weighted <- U
  for (ix in groups) for (i in ix) {
    n <- length(ix); k <- n/N/(n-1); u <- U[i, ] - colMeans(U[ix, , drop=FALSE])
    minus <- A - k*(D[[i]] - Reduce(`+`, D[ix])/n)
    delta[i, ] <- solve(minus, k*u); fixed[i, ] <- solve(A, k*u)
    w <- rep(1, N); w[ix] <- n/(n-1); w[i] <- 0
    exact <- -solve(Reduce(`+`, Map(`*`, D, w))/N, colMeans(a*w))
    near(beta + delta[i, ], exact)
    weighted[i, ] <- sqrt(n/(n-1)) * u
  }
  V <- solve(A) %*% crossprod(weighted) %*% t(solve(A))/N^2
  near(jack_cov(fixed, groups), V)
  list(max_error = max(abs(jack_cov(fixed, groups) - V)))
}
control <- affine_control()
if (action == "prepare") {
  stopifnot(!dir.exists(out), all(Sys.getenv(threads) == "1"))
  old <- readRDS(file.path(prior, "manifest.rds")); done <- readRDS(file.path(prior, "completion.rds"))
  check(old$source); check(old$inputs); check(done$results)
  dir.create(out, recursive = TRUE)
  stopifnot(file.copy(script, file.path(out, "source.R")))
  files <- c(file.path(prior, c("manifest.rds", "completion.rds")), names(done$results),
    "tmp/jml-small-sample-literature-20261013/saws/inst/doc/FayGraubard.pdf")
  m <- list(inputs = tools::md5sum(files), source = tools::md5sum(file.path(out, "source.R")),
    prior = normalizePath(prior), jobs = old$jobs, R = R.version, threads = Sys.getenv(threads),
    solver_version = as.character(packageVersion("nleqslv")),
    protocol = list(target = "Deletion sensitivity and covariance about the adjusted-equation root; not truth coverage",
      design = "Preserve original roster proportions, remove one entire Person, reweight remaining Persons within that roster",
      one_step = "All sixteen retained pilot fits; full Person derivatives at two step sizes; no symmetrization",
      references = "First replicate, N20, both designs and L1/L2: four complete sets, eighty deletions",
      rule = "Reuse original two starts, solver stages, maxit and root checks; no covariance computation or rescue",
      surrogate_check = "Every deletion returned; maximum coordinate error <= .05 original SE and every coordinate SE within 5% of nonlinear deletion SE",
      scope = "Engineering comparison only; failures retained; no extension, new responses, t critical value or calibrated interval"))
  check(m$inputs); save_new(m, file.path(out, "manifest.rds"))
  cat("Frozen 16 derivative reviews and 80 deletion-root attempts; affine control passed.\n")
  quit(save="no")
}
out <- normalizePath(out); m <- readRDS(file.path(out, "manifest.rds"))
check(m$inputs); check(m$source)
stopifnot(identical(unname(tools::md5sum(script)), unname(m$source)),
  identical(m$R, R.version), identical(m$threads, Sys.getenv(threads)),
  identical(m$solver_version, as.character(packageVersion("nleqslv"))))
seal <- tools::md5sum(file.path(out, "manifest.rds"))
old <- readRDS(file.path(m$prior, "manifest.rds")); check(old$source)
if (action == "run") {
  library(mfrmr, lib.loc=file.path(m$prior,"library"))
  stopifnot(identical(normalizePath(find.package("mfrmr")), file.path(m$prior,"library/mfrmr")))
  setwd(file.path(m$prior, "source")); source("inst/validation/jml-observed-inference-20261001.R")
  jac <- mfrmr:::mfrmr_numeric_transformation_jacobian
  # Same local-root policy as the retained fit, without calculating a second,
  # irrelevant covariance from the deletion-weighted contributions.
  root <- function(fn, policy) {
    attempts <- list(); roots <- list(); start_time <- proc.time()[["elapsed"]]
    for (s in seq_along(policy$starts)) for (stage in seq_len(nrow(policy$stages))) {
      setting <- policy$stages[stage, ]; warnings <- character()
      a <- tryCatch(withCallingHandlers({
        z <- nleqslv::nleqslv(policy$starts[[s]], fn, method=setting$method,
          global=setting$global, control=list(maxit=policy$maxit, ftol=policy$ftol,
          xtol=policy$xtol, stepmax=setting$stepmax, allowSingular=FALSE))
        residual <- max(abs(fn(z$x))); ok <- is.finite(residual) && residual <= policy$equation_tolerance
        step <- NA_real_
        if (ok) {
          J <- jac(fn, z$x, policy$jacobian_step)
          ok <- J$valid
          if (ok) {
            sv <- svd(J$jacobian, nu=0, nv=0)$d
            ok <- min(sv) > max(sv)*length(z$x)*.Machine$double.eps
          }
          if (ok) { step <- max(abs(solve(J$jacobian, fn(z$x)))); ok <- step <= policy$root_step_tolerance }
        }
        list(beta=z$x, available=ok, residual=residual, step=step, solver=z)
      }, warning=function(w) { warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning") }),
      error=function(e) list(available=FALSE, error=conditionMessage(e)))
      a$warnings <- warnings; a$start <- s; a$stage <- stage
      attempts[[length(attempts)+1L]] <- a
      if (isTRUE(a$available)) { roots[[length(roots)+1L]] <- a$beta; break }
    }
    spread <- if (length(roots)) max(vapply(roots, function(b) max(abs(b-roots[[1]])), 0)) else NA_real_
    ok <- length(roots)==length(policy$starts) && spread <= policy$root_agreement_tolerance
    list(available=ok, beta=if(ok) roots[[1]] else NULL, spread=spread,
      attempts=attempts, seconds=proc.time()[["elapsed"]]-start_time)
  }
  for (j in seq_len(nrow(m$jobs))) {
    job <- m$jobs[j, ]; d <- old$designs[[job$Design]]
    path <- file.path(out, sprintf("case-%02d.rds", j))
    base <- readRDS(file.path(m$prior, sprintf("fit-%02d-L%d.rds", job$Parent,job$L)))$fit$result
    input <- readRDS(file.path(m$prior, sprintf("input-%02d.rds",job$Parent)))$input
    data <- jml_observed_long(input$counts[[as.character(job$L)]], d$cells)
    problem <- mfrmr:::mfrm_jml_adjustment_problem(data,"Person",c("Rater","Criterion"),"Score",d$owner,2L)
    evaluate <- function(b) problem$evaluate(b,2L)$value
    beta <- base$point$beta; N <- job$N; p <- length(beta); groups <- split(seq_len(N),problem$roster)
    if (!file.exists(path)) {
      timer <- proc.time()[["elapsed"]]; U <- evaluate(beta); F <- colMeans(U)
      near(U, base$covariance$result$scores)
      derivative <- lapply(c(1e-4,5e-5), function(h) jac(function(b) as.vector(evaluate(b)),beta,h))
      stopifnot(all(vapply(derivative, `[[`, TRUE, "valid")))
      D <- array(derivative[[2]]$jacobian, c(N,p,p)); A <- apply(D,c(2,3),mean)
      derivative_error <- max(abs(derivative[[1]]$jacobian-derivative[[2]]$jacobian))/max(1,max(abs(D)))
      stopifnot(derivative_error < 1e-5); near(A,base$covariance$result$jacobian,1e-8)
      fixed <- delta <- matrix(NA_real_,N,p); min_sv <- numeric(N); weighted <- U
      identity_error <- transform_error <- 0
      S <- T <- diag(p); S[1,2] <- .3; T[2,1] <- -.4; T[p,p] <- 1.7
      for (ix in groups) for (i in ix) {
        n <- length(ix); k <- n/N/(n-1)
        centered <- U[i, ] - colMeans(U[ix, , drop=FALSE])
        minus_F <- F - k*centered
        minus_A <- A - k*(D[i,,] - apply(D[ix,,,drop=FALSE],c(2,3),mean))
        w <- rep(1,N); w[ix] <- n/(n-1); w[i] <- 0
        identity_error <- max(identity_error,max(abs(minus_F-colMeans(U*w))),
          max(abs(minus_A-apply(D*w,c(2,3),mean))))
        min_sv[i] <- min(svd(minus_A,nu=0,nv=0)$d)
        fixed[i, ] <- -solve(A,minus_F)
        weighted[i, ] <- sqrt(n/(n-1))*centered
        if (min_sv[i] > 1e-6) {
          delta[i, ] <- -solve(minus_A,minus_F)
          transformed <- -T %*% solve(S %*% minus_A %*% T, S %*% minus_F)
          transform_error <- max(transform_error,max(abs(transformed-delta[i, ])))
        }
      }
      finite <- solve(A) %*% crossprod(weighted) %*% t(solve(A))/N^2
      near(jack_cov(fixed,groups),finite); stopifnot(identity_error<1e-9,transform_error<1e-9)
      save_new(list(manifest=seal,job=job,beta=beta,base_se=sqrt(diag(base$covariance$result$vcov)),
        groups=groups,U=U,D=D,A=A,fixed=fixed,delta=delta,min_sv=min_sv,finite=finite,
        derivative_error=derivative_error,identity_error=identity_error,transform_error=transform_error,
        seconds=proc.time()[["elapsed"]]-timer),path)
    }
    z <- readRDS(path); stopifnot(identical(z$manifest,seal),identical(z$job,job))
    if (job$N==20L && job$Replicate==1L) for (i in seq_len(N)) {
      fp <- file.path(out,sprintf("delete-%02d-%02d.rds",j,i))
      if(file.exists(fp)) next
      ix <- groups[[which(vapply(groups,function(g) i %in% g,TRUE))]]
      w <- rep(1,N); w[ix] <- length(ix)/(length(ix)-1); w[i] <- 0
      ans <- root(function(b) colMeans(evaluate(b)*w),base$policy)
      save_new(list(manifest=seal,case=tools::md5sum(path),person=i,result=ans),fp)
    }
    cat("Completed case",j,"N",N,"L",job$L,"\n"); flush.console()
  }
}
setwd(dirname(dirname(out)))
rows <- list(); bindings <- character()
for (j in seq_len(nrow(m$jobs))) {
  path <- file.path(out,sprintf("case-%02d.rds",j)); z <- readRDS(path)
  stopifnot(identical(z$manifest,seal)); bindings <- c(bindings,path)
  job <- z$job; available <- all(is.finite(z$delta)); V <- if(available) jack_cov(z$delta,z$groups) else matrix(NA_real_,5,5)
  ref <- job$N==20L && job$Replicate==1L
  count <- 0L; ref_seconds <- 0; error <- se_error <- NA_real_; accepted <- NA
  ref_ratio <- rep(NA_real_,5)
  if(ref) {
    records <- lapply(seq_len(job$N),function(i) {
      f <- file.path(out,sprintf("delete-%02d-%02d.rds",j,i)); x <- readRDS(f)
      stopifnot(identical(x$manifest,seal),identical(x$case,tools::md5sum(path)),x$person==i)
      bindings <<- c(bindings,f); x$result
    })
    count <- sum(vapply(records,`[[`,TRUE,"available")); ref_seconds <- sum(vapply(records,`[[`,0,"seconds"))
    accepted <- FALSE
    if (count==job$N && available) {
      delta <- t(vapply(records,function(x) x$beta-z$beta,numeric(5)))
      reference <- jack_cov(delta,z$groups)
      error <- max(abs(sweep(z$delta-delta,2,z$base_se,"/")))
      se_error <- max(abs(sqrt(diag(V)/diag(reference))-1))
      ref_ratio <- sqrt(diag(reference)/diag(z$finite))
      accepted <- error<=.05 && se_error<=.05
    }
  }
  ratio <- sqrt(diag(V)/diag(z$finite))
  rows[[j]] <- cbind(job,data.frame(OneStepAvailable=available,ReferenceRequested=ref,
    ReferenceReturned=count,MaxErrorOverBaseSE=error,MaxRelativeSEError=se_error,SurrogateAccepted=accepted,
    OneStepSEratioMin=min(ratio),OneStepSEratioMax=max(ratio),
    ReferenceSEratioMin=min(ref_ratio),ReferenceSEratioMax=max(ref_ratio),
    MinDeletedSingular=min(z$min_sv),JacobianAsymmetry=max(abs(z$A-t(z$A)))/max(abs(z$A)),
    DerivativeError=z$derivative_error,IdentityError=z$identity_error,TransformError=z$transform_error,
    DerivativeSeconds=z$seconds,ReferenceSeconds=ref_seconds))
}
result <- list(manifest=seal,files=tools::md5sum(bindings),summary=do.call(rbind,rows),affine_control=control,
  interpretation="Root sensitivity and computational approximation only; no new response data or truth coverage")
dest <- file.path(out,"review.rds")
if(action=="run") save_new(result,dest) else {
  stopifnot(identical(result,readRDS(dest)),!"mfrmr" %in% loadedNamespaces())
}
stopifnot(!exists(".Random.seed",.GlobalEnv))
print(result$summary,row.names=FALSE)
cat("Saved review/replay passed;",sum(result$summary$ReferenceReturned),"deletion roots returned.\n")
