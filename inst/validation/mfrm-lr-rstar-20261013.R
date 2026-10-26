# Fixed-point discrete likelihood refinement; no fitting, generation or intervals.
action <- commandArgs(TRUE)
stopifnot(length(action)==1L, action %in% c("run", "replay"))
script <- "inst/validation/mfrm-lr-rstar-20261013.R"
out <- "validation-results/mfrm-lr-rstar-20261013"
prior <- "validation-results/mfrm-lr-rsm-adaptive-profile-20261010"
info_path <- "validation-results/mfrm-lr-rsm-inconclusive-20261010/expected-information-20261012.rds"
historical_core <- "tmp/downstream-reporting-20261012/baseline/R/mfrm_core.R"
check <- function(h) stopifnot(length(h)>0L, !anyNA(h), identical(h, tools::md5sum(names(h))))
relative <- function(a,b) max(abs(a-b))/max(1,max(abs(b)))
logdet <- function(x) {
  d <- determinant(x, logarithm=TRUE)
  stopifnot(is.finite(d$modulus), d$sign!=0)
  as.numeric(d$modulus)
}
correction <- function(I,S,Q,J,H,r) {
  d <- nrow(I); eta <- seq_len(d-1L)
  stopifnot(abs(r)>.1, all(is.finite(c(I,S,Q,J,H))),
    min(eigen(I,symmetric=TRUE,only.values=TRUE)$values)>0,
    min(eigen(J,symmetric=TRUE,only.values=TRUE)$values)>0,
    min(eigen(H,symmetric=TRUE,only.values=TRUE)$values)>0)
  M <- cbind(S[,eta,drop=FALSE],Q)
  lq <- logdet(M)-logdet(I)+(logdet(J)-logdet(H))/2
  q <- sign(r)*exp(lq)
  # Independent geometric version of DFR (21)-(22), with column-vector phi.
  normal <- solve(t(S),c(rep(0,d-1L),1)); normal <- normal/sqrt(sum(normal^2))
  distance <- abs(sum(normal*Q)); tangent <- S[,eta,drop=FALSE]
  q_geometry <- sign(r)*distance*exp((logdet(J)-2*logdet(I)-logdet(H)+
    logdet(crossprod(tangent)))/2)
  stopifnot(abs(q-q_geometry)<=1e-8*max(1,abs(q)))
  list(r=r,q=q,rstar=r+(lq-log(abs(r)))/r,geometry_q=q_geometry)
}

# In a full exponential family phi=I_hat*theta; q has a direct closed form.
I0 <- matrix(c(3,.4,.4,2),2); J0 <- I0; H0 <- matrix(4,1)
shift <- c(.2,.7); ctl <- correction(I0,I0,drop(I0%*%shift),J0,H0,1.3)
stopifnot(abs(ctl$q-shift[2]*sqrt(det(J0)/H0[1]))<1e-12)

old <- readRDS(file.path(prior,"manifest.rds")); check(old$inputs)
audit <- readRDS(file.path(prior,"verification.rds")); stopifnot(audit$passed)
check(audit$retained); check(audit$source)
expected <- readRDS(info_path)
ids <- c(1L,5L); orders <- c(121L,241L)
fit_paths <- names(old$inputs)[endsWith(names(old$inputs),"-fit.rds")]
inputs <- unique(c(info_path,historical_core,file.path(prior,c("manifest.rds","verification.rds",
  sprintf("case-%02d.rds",c(ids,4L,6L)))),fit_paths[ids]))
sources <- c(script,"inst/validation/mfrm-lr-rsm-boundary-20261009.R","R/mfrm_core.R",
  "tmp/pdfs/population-rstar-20261013/davison-fraser-reid.pdf")
binding <- list(inputs=tools::md5sum(inputs),sources=tools::md5sum(sources),
  ids=ids,orders=orders,R=R.version,
  scope="Four fixed log-variance profile points, no endpoint/coverage qualification")
# Reporting edits changed the core file, but not the three consumed helpers.
# Compare against the retained file whose bytes match the fitted source epoch.
stopifnot(unname(tools::md5sum(historical_core))==unname(old$source["R/mfrm_core.R"]))
definition <- function(path,name) {
  expr <- as.list(parse(path,keep.source=FALSE))
  hit <- vapply(expr,function(x) is.call(x) && identical(x[[1L]],as.name("<-")) &&
    identical(x[[2L]],as.name(name)),TRUE)
  stopifnot(sum(hit)==1L); expr[[which(hit)]]
}
for (name in c("build_param_sizes","build_param_slices","gauss_hermite_normal"))
  stopifnot(identical(definition(historical_core,name),definition("R/mfrm_core.R",name)))
check(old$source["inst/validation/mfrm-lr-rsm-boundary-20261009.R"])
if (action=="replay") {
  m <- readRDS(file.path(out,"manifest.rds")); stopifnot(identical(m,binding))
  check(m$inputs); check(m$sources)
  results <- lapply(ids,function(i) readRDS(file.path(out,sprintf("case-%02d.rds",i))))
  for (z in results) {
    stopifnot(identical(z$binding,binding))
    for (ord in z$value$orders) for (p in ord$points) {
      again <- correction(ord$I,p$S,p$Q,z$value$J,p$H,p$adjustment$r)
      stopifnot(identical(again,p$adjustment))
    }
  }
  summary <- do.call(rbind,lapply(results,function(z) z$value$table))
  stopifnot(identical(summary,readRDS(file.path(out,"summary.rds"))))
  cat("PASS: saved matrices, controls, source/input bindings and fixed-point replay.\n")
  print(summary,row.names=FALSE); quit(save="no")
}
stopifnot(!dir.exists(out),all(Sys.getenv(c("OMP_NUM_THREADS","OPENBLAS_NUM_THREADS",
  "MKL_NUM_THREADS","VECLIB_MAXIMUM_THREADS"))=="1"))
dir.create(out,recursive=TRUE); saveRDS(binding,file.path(out,"manifest.rds"))
pkgload::load_all(".",quiet=TRUE,compile=FALSE)
source("inst/validation/mfrm-lr-rsm-boundary-20261009.R")
blocked <- function(...) stop("Unplanned fit, information differentiation or RNG")
for (n in c("fit_mfrm","compute_mml_parameter_covariance","simulate_mfrm_data"))
  assignInNamespace(n,blocked,"mfrmr")
for (n in c("optim","optimHess","nlminb","rnorm","runif","rbinom"))
  assignInNamespace(n,blocked,"stats")

# Person-level joint response probabilities, not products of marginal row laws.
patterns <- as.matrix(expand.grid(rep(list(0:3),6L)))
pattern_scores <- function(ctx,ix,par,gh) {
  e <- sqrt(exp(tail(par,1)))*gh$nodes; q <- length(e)
  lp <- matrix(0,nrow(patterns),q); Dsum <- matrix(0,nrow(patterns),ctx$p)
  Dmean <- matrix(0,q,ctx$p); totalmean <- numeric(q)
  for (j in seq_along(ix)) {
    D <- do.call(rbind,lapply(ctx$design,function(M) M[ix[j],]))
    v <- outer(e,0:3)+rep(drop(D%*%head(par,-1)),each=q)
    hi <- apply(v,1,max); v <- v-hi-log(rowSums(exp(v-hi))); P <- exp(v)
    lp <- lp+t(v[,patterns[,j]+1L,drop=FALSE])
    Dsum <- Dsum+D[patterns[,j]+1L,,drop=FALSE]
    Dmean <- Dmean+P%*%D; totalmean <- totalmean+drop(P%*%(0:3))
  }
  joint <- sweep(exp(lp),2,gh$weights,"*"); mass <- rowSums(joint)
  stopifnot(all(mass>0),all(is.finite(mass)))
  post <- joint/mass
  score <- cbind(Dsum-post%*%Dmean,
    (rowSums(patterns)*drop(post%*%e)-drop(post%*%(e*totalmean)))/2)
  list(mass=mass,logmass=log(mass),score=score)
}

results <- lapply(seq_along(ids),function(k) {
  id <- ids[k]; start <- proc.time()[["elapsed"]]
  saved <- readRDS(file.path(prior,sprintf("case-%02d.rds",id)))
  fit <- readRDS(fit_paths[id])$payload$value; ctx <- rsm_lr_boundary_context(fit)
  stopifnot(saved$source$passed,all(saved$endpoints$Status=="computed"),
    ctx$K==4L,all(lengths(ctx$groups)==6L))
  theta <- saved$source$parameters; d <- length(theta); J <- saved$source$hessian
  by_order <- lapply(orders,function(order) {
    gh <- mfrmr:::gauss_hermite_normal(order)
    I <- matrix(0,d,d); source_nll <- 0; mass_error <- score_error <- 0
    points <- lapply(saved$terminal,function(t) list(S=matrix(0,d,d),Q=numeric(d),
      nll=0,H=t$hessian,parameters=t$parameters))
    for (ix in ctx$groups) {
      base <- pattern_scores(ctx,ix,theta,gh)
      w <- base$mass; s <- base$score
      # Center at the full source law, also removing floating expected-score error.
      sh <- sweep(s,2,colSums(s*w),"-")
      I <- I+crossprod(sh*sqrt(w))
      mass_error <- max(mass_error,abs(sum(w)-1))
      score_error <- max(score_error,max(abs(colSums(s*w))))
      observed <- which(rowSums(abs(sweep(patterns,2,ctx$y[ix],"-")))==0)
      stopifnot(length(observed)==1L)
      source_nll <- source_nll-base$logmass[observed]
      for (side in names(points)) {
        test <- pattern_scores(ctx,ix,points[[side]]$parameters,gh)
        st <- sweep(test$score,2,colSums(test$score*w),"-")
        diff <- base$logmass-test$logmass; diff <- diff-sum(w*diff)
        points[[side]]$S <- points[[side]]$S+crossprod(sh*w,st)
        points[[side]]$Q <- points[[side]]$Q+drop(crossprod(sh,w*diff))
        points[[side]]$nll <- points[[side]]$nll-test$logmass[observed]
        mass_error <- max(mass_error,abs(sum(test$mass)-1))
      }
    }
    for (side in names(points)) {
      t <- saved$terminal[[side]]; stopifnot(t$checks$Passed)
      r <- sign(tail(theta,1)-tail(t$parameters,1))*sqrt(t$checks$IndependentLR)
      points[[side]]$adjustment <- correction(I,points[[side]]$S,points[[side]]$Q,J,t$hessian,r)
    }
    list(I=I,points=points,nll=source_nll,mass_error=mass_error,score_error=score_error)
  })
  low <- by_order[[1]]; high <- by_order[[2]]
  controls <- c(MassError=max(low$mass_error,high$mass_error),
    ScoreError=max(low$score_error,high$score_error),
    SourceInformation=relative(high$I,expected$cases[[k]]$orders[[2]]$information),
    SourceNLL=abs(high$nll-saved$source$continuous$value)+saved$source$continuous$summed_relative_error)
  table <- do.call(rbind,lapply(names(high$points),function(side) {
    a <- low$points[[side]]; b <- high$points[[side]]; t <- saved$terminal[[side]]
    moment_change <- max(relative(low$I,high$I),relative(a$S,b$S),relative(a$Q,b$Q))
    rs_change <- abs(a$adjustment$rstar-b$adjustment$rstar)
    nll_error <- abs(b$nll-t$continuous$value)+t$continuous$summed_relative_error
    passed <- all(controls<=c(1e-8,1e-8,1e-6,1e-5)) &&
      moment_change<=1e-6 && rs_change<=1e-5 && nll_error<=1e-5
    data.frame(Case=id,N=ctx$persons,Side=side,Variance=exp(tail(t$parameters,1)),
      R=b$adjustment$r,Rstar=b$adjustment$rstar,Correction=b$adjustment$rstar-b$adjustment$r,
      MomentOrderChange=moment_change,RstarOrderChange=rs_change,NLLReferenceError=nll_error,
      NumericalChecksPassed=passed,CoverageQualified=FALSE)
  }))
  value <- list(orders=by_order,J=J,controls=controls,table=table,
    elapsed=proc.time()[["elapsed"]]-start)
  saveRDS(list(binding=binding,value=value),file.path(out,sprintf("case-%02d.rds",id)))
  for (side in names(high$points)) {
    p <- high$points[[side]]; stem <- file.path(out,paste0("case",id,"-",side,"-"))
    for (name in c("I","J","S","Q","H")) {
      mat <- switch(name,I=high$I,J=J,S=p$S,Q=p$Q,H=p$H)
      write.table(mat,paste0(stem,name,".csv"),sep=",",row.names=FALSE,col.names=FALSE)
    }
  }
  print(table,row.names=FALSE); print(controls); cat("Phase seconds:",value$elapsed,"\n"); flush.console()
  value
})
table <- do.call(rbind,lapply(results,`[[`,"table"))
saveRDS(table,file.path(out,"summary.rds")); write.csv(table,file.path(out,"summary.csv"),row.names=FALSE)
boundary <- readRDS(file.path(prior,"case-04.rds")); refused <- readRDS(file.path(prior,"case-06.rds"))
stopifnot(boundary$zero_in_candidate_set,is.na(boundary$endpoints$Bound[1]),refused$status=="source_refused")
saveRDS(list(boundary="not evaluated: unresolved lower end / zero variance in LR set",
  refused="not evaluated: retained category support refusal",new_fits=0L,new_responses=0L,
  session=sessionInfo()),file.path(out,"controls.rds"))
cat("Fixed-point review complete; failed numerical comparisons are retained.\n")
