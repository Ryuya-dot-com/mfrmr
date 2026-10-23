# Small retained-data inversion review; not a public interval/coverage claim.
action <- commandArgs(TRUE)
stopifnot(length(action)==1L,action %in% c("run","replay"))
script <- "inst/validation/mfrm-lr-rstar-inversion-20261013.R"
helper <- "inst/validation/mfrm-lr-rstar-inversion-helpers-20261013.R"
out <- "validation-results/mfrm-lr-rstar-inversion-20261013"
old_dir <- "validation-results/mfrm-lr-rstar-20261013"
prior <- "validation-results/mfrm-lr-rsm-adaptive-profile-20261010"
check <- function(h) stopifnot(length(h)>0L,!anyNA(h),identical(h,tools::md5sum(names(h))))
relative <- function(a,b) max(abs(a-b))/max(1,max(abs(b)))
old <- readRDS(file.path(old_dir,"manifest.rds")); check(old$inputs); check(old$sources)
parents <- readRDS(file.path(prior,"manifest.rds"))
fits <- names(parents$inputs)[endsWith(names(parents$inputs),"-fit.rds")]
source(helper)
binding <- list(inputs=tools::md5sum(c(file.path(old_dir,c("manifest.rds","case-01.rds",
  "case-05.rds","controls.rds")),names(old$inputs))),
  source=tools::md5sum(c(script,helper,list.files("R",full.names=TRUE),
    "inst/validation/mfrm-lr-rsm-boundary-20261009.R","DESCRIPTION","NAMESPACE")),
  controls=list(ids=c(1L,5L),adaptive=c(31L,61L),moments=c(121L,241L),max_points=32L,
    maxit=400L,gradient=1e-8,nll=1e-5,moment=1e-6,rstar=1e-5,endpoint=1e-4,
    central_steps=c(.01,.005),central_profile=c(-.1,-.05,.05,.1),limit=1e-4,
    extrapolation=1e-3),R=R.version.string)
if (action=="replay") {
  stopifnot(identical(readRDS(file.path(out,"manifest.rds")),binding))
  audit <- readRDS(file.path(out,"verification.rds")); check(audit$files)
  for (i in binding$controls$ids) {
    x <- readRDS(file.path(out,sprintf("case-%02d-result.rds",i)))
    stopifnot(identical(x$binding,binding))
    z <- x$value
    for (e in z$endpoints) {
      p <- e$point; a <- rstar_adjust(z$I,p$cross$S,p$cross$Q,z$J,p$H,p$adjust$r)
      stopifnot(identical(a,p$adjust))
    }
  }
  cat("PASS: saved endpoint formula, source/input and complete phase-file replay.\n")
  print(readRDS(file.path(out,"summary.rds")),row.names=FALSE); quit(save="no")
}
stopifnot(all(Sys.getenv(c("OMP_NUM_THREADS","OPENBLAS_NUM_THREADS",
  "MKL_NUM_THREADS","VECLIB_MAXIMUM_THREADS"))=="1"))
dir.create(out,recursive=TRUE,showWarnings=FALSE)
manifest <- file.path(out,"manifest.rds")
if (file.exists(manifest)) stopifnot(identical(readRDS(manifest),binding)) else saveRDS(binding,manifest)
pkgload::load_all(".",quiet=TRUE,compile=FALSE)
source("inst/validation/mfrm-lr-rsm-boundary-20261009.R")
blocked <- function(...) stop("No new data or full package fit in this review")
for (n in c("fit_mfrm","simulate_mfrm_data")) assignInNamespace(n,blocked,"mfrmr")
for (n in c("rnorm","runif","rbinom")) assignInNamespace(n,blocked,"stats")

# Normal location/variance: the nuisance-aware central limit is 5/(6 sqrt(n/2)).
n <- 20; I <- diag(c(n,n/2)); B <- -I; Jdot <- -I
ctl <- rstar_center(I,I,B,Jdot)
stopifnot(abs(ctl$limit-5/(6*sqrt(n/2)))<1e-12)
normal_rstar <- function(delta) {
  t <- exp(-delta); r <- -sign(delta)*sqrt(n*(expm1(-delta)+delta))
  q <- sqrt(n/2)*(t-1)*sqrt(t)
  r+log(q/r)/r
}
stopifnot(abs(mean(vapply(c(-.001,.001),normal_rstar,0.))-ctl$limit)<1e-6)

phase <- function(i,name,fn) {
  path <- file.path(out,sprintf("case-%02d-%s.rds",i,name))
  if (file.exists(path)) {
    x <- readRDS(path); stopifnot(identical(x$binding,binding))
    if(nzchar(x$error)) stop(x$error); return(x$value)
  }
  begin <- proc.time()[["elapsed"]]
  x <- tryCatch(list(value=fn(),error=""),error=function(e) list(value=NULL,error=conditionMessage(e)))
  x$elapsed <- proc.time()[["elapsed"]]-begin; x$binding <- binding
  saveRDS(x,paste0(path,".tmp")); stopifnot(file.rename(paste0(path,".tmp"),path))
  cat(i,name,round(x$elapsed,3),"seconds",x$error,"\n"); flush.console()
  if(nzchar(x$error)) stop(x$error); x$value
}
run_case <- function(id) {
  fit <- readRDS(fits[id])$payload$value; ctx <- rsm_lr_boundary_context(fit)
  persons <- rstar_patterns(ctx); d <- length(fit$opt$par); eta <- seq_len(d-1L)
  gh <- lapply(c(121L,241L),mfrmr:::gauss_hermite_normal)
  saved <- readRDS(file.path(prior,sprintf("case-%02d.rds",id)))
  former <- readRDS(file.path(old_dir,sprintf("case-%02d.rds",id)))$value
  equivalent <- phase(id,"compression",function() {
    errors <- numeric()
    for (j in 1:2) {
      base <- pattern_base(persons,saved$source$parameters,gh[[j]])
      errors <- c(errors,relative(base$I,former$orders[[j]]$I))
      for (side in c("Lower","Upper")) {
        ref <- former$orders[[j]]$points[[side]]
        z <- pattern_cross(persons,base,ref$parameters,gh[[j]])
        a <- rstar_adjust(base$I,z$S,z$Q,former$J,ref$H,ref$adjustment$r)
        errors <- c(errors,relative(z$S,ref$S),relative(z$Q,ref$Q),
          abs(a$rstar-ref$adjustment$rstar))
      }
    }
    stopifnot(max(errors)<=1e-8)
    list(max_error=max(errors),patterns=4096L,latent_integrals=19L)
  })
  cfg <- fit$config; sizes <- mfrmr:::build_param_sizes(cfg)
  idx <- mfrmr:::build_indices(fit$prep,cfg$step_facet,cfg$slope_facet,
    cfg$interaction_specs,gpcm_spec=cfg$gpcm_spec)
  evaluator <- function(q) {
    config <- cfg; config$estimation_control$mml_integration <- "adaptive"
    config$estimation_control$quad_points <- q
    mfrmr:::make_mfrm_direct_evaluator("MML",mfrmr:::make_param_cache(sizes,config,idx,
      is_mml=TRUE),idx,config,sizes,mfrmr:::gauss_hermite_normal(q))
  }
  low <- evaluator(31L); high <- evaluator(61L)
  source <- phase(id,"source",function() {
    a <- newton_refine(saved$source$parameters,high$value,high$gradient)
    p <- a$par; J <- optimHess(p,high$value,high$gradient,control=list(ndeps=rep(1e-4,d)))
    reference <- rsm_lr_continuous_value(ctx,head(p,-1),exp(tail(p,1)))
    checks <- c(gradient=a$gradient<=1e-8,positive=min(eigen(J,symmetric=TRUE)$values)>0,
      integration=abs(low$value(p)-high$value(p))<=1e-5,
      scores=max(abs(low$gradient(p)-high$gradient(p)))<=1e-4,
      reference=abs(high$value(p)-reference$value)+reference$summed_relative_error<=1e-5)
    stopifnot(all(checks))
    list(p=p,J=J,refinement=a,nll=high$value(p),reference=reference,
      se=sqrt(solve(J)[d,d]),checks=checks)
  })
  base <- lapply(gh,function(g) pattern_base(persons,source$p,g))
  stopifnot(relative(base[[1]]$I,base[[2]]$I)<=1e-6)
  center <- phase(id,"center",function() {
    J <- source$J; v <- c(-solve(J[eta,eta],J[eta,d]),1)
    results <- lapply(c(.01,.005)*source$se,function(h) {
      p <- source$p+h*v; m <- source$p-h*v
      B <- (pattern_cross(persons,base[[2]],p,gh[[2]])$S-
            pattern_cross(persons,base[[2]],m,gh[[2]])$S)/(2*h)
      Jp <- optimHess(p,high$value,high$gradient,control=list(ndeps=rep(1e-4,d)))
      Jm <- optimHess(m,high$value,high$gradient,control=list(ndeps=rep(1e-4,d)))
      jd <- (Jp-Jm)/(2*h)
      list(h=h,B=B,Jdot=jd,value=rstar_center(base[[2]]$I,J,B,jd))
    })
    change <- abs(results[[1]]$value$limit-results[[2]]$value$limit)
    stopifnot(change<=1e-4)
    list(derivatives=results,limit=results[[2]]$value$limit,change=change)
  })
  points <- list(); contrast <- c(rep(0,d-1L),1)
  evaluate <- function(rho) {
    key <- sprintf("%.12f",rho)
    if (!is.null(points[[key]])) return(points[[key]])
    stopifnot(length(points)<32L)
    z <- phase(id,paste0("point-",key),function() {
      attempts <- lapply(list(source$p,rep(0,d)),function(start) {
        a <- mfrmr:::mfrm_gpcm_profile_nuisance(low,high,start,contrast,rho,400L)
        stopifnot(a$check$Passed)
        embed <- function(x) c(x,rho)
        refine <- newton_refine(head(a$parameters,-1),function(x) high$value(embed(x)),
          function(x) head(high$gradient(embed(x)),-1))
        p <- embed(refine$par)
        stopifnot(refine$gradient<=1e-8,abs(low$value(p)-high$value(p))<=1e-5,
          max(abs(low$gradient(p)-high$gradient(p)))<=1e-4)
        list(p=p,nll=high$value(p),refinement=refine,initial=a)
      })
      spread <- diff(range(vapply(attempts,`[[`,0.,"nll"))); stopifnot(spread<=1e-5)
      a <- attempts[[which.min(vapply(attempts,`[[`,0.,"nll"))]]; p <- a$p
      stopifnot(a$nll>=source$nll-1e-8)
      embed <- function(x) c(x,rho)
      H <- optimHess(head(p,-1),function(x) high$value(embed(x)),
        function(x) head(high$gradient(embed(x)),-1),control=list(ndeps=rep(1e-4,d-1)))
      cross <- pattern_cross(persons,base[[2]],p,gh[[2]])
      r <- sign(tail(source$p,1)-rho)*sqrt(2*(a$nll-source$nll))
      adjustment <- rstar_adjust(base[[2]]$I,cross$S,cross$Q,source$J,H,r)
      list(rho=rho,p=p,nll=a$nll,H=H,cross=cross,adjust=adjustment,attempts=attempts,
        spread=spread)
    })
    points[[key]] <<- z; z
  }
  central <- lapply(c(-.1,-.05,.05,.1),function(x) evaluate(tail(source$p,1)+x*source$se))
  vals <- vapply(central,function(x) x$adjust$rstar,0.)
  extrapolation <- (4*mean(vals[c(2,3)])-mean(vals[c(1,4)]))/3
  center$extrapolation <- extrapolation; center$error <- abs(extrapolation-center$limit)
  stopifnot(center$error<=1e-3)
  ends <- lapply(c(Lower=-1,Upper=1),function(direction) {
    target <- -direction*qnorm(.975)
    inner <- tail(source$p,1)+direction*.1*source$se
    side <- if(direction<0) "Lower" else "Upper"
    outer <- tail(saved$terminal[[side]]$parameters,1)
    f <- function(x) evaluate(x)$adjust$rstar-target
    a <- f(inner); b <- f(outer)
    for (j in seq_len(4L)) {
      if(a*b<=0) break
      outer <- outer+direction*.5*source$se*1.5^(j-1L); b <- f(outer)
    }
    stopifnot(a*b<=0)
    root <- uniroot(f,sort(c(inner,outer)),tol=1e-6,maxiter=12L)$root
    point <- evaluate(root)
    phase(id,paste0("terminal-",side),function() {
      ref <- rsm_lr_continuous_value(ctx,head(point$p,-1),exp(tail(point$p,1)))
      lower <- pattern_cross(persons,base[[1]],point$p,gh[[1]])
      a <- rstar_adjust(base[[1]]$I,lower$S,lower$Q,source$J,point$H,point$adjust$r)
      independent_r <- sign(tail(source$p,1)-root)*sqrt(2*(ref$value-source$reference$value))
      independent <- rstar_adjust(base[[2]]$I,point$cross$S,point$cross$Q,
        source$J,point$H,independent_r)
      diagnostics <- c(moment=max(relative(base[[1]]$I,base[[2]]$I),
          relative(lower$S,point$cross$S),relative(lower$Q,point$cross$Q)),
        rstar_order=abs(a$rstar-point$adjust$rstar),
        nll=abs(point$nll-ref$value)+ref$summed_relative_error,
        fixed_nll=abs(point$cross$nll-ref$value)+ref$summed_relative_error,
        cutoff=abs(independent$rstar-target),
        integration_rstar=abs(independent$rstar-point$adjust$rstar))
      passed <- all(diagnostics<=c(1e-6,1e-5,1e-5,1e-5,1e-4,1e-5))
      list(side=side,variance=exp(root),point=point,reference=ref,
        low=lower,independent=independent,diagnostics=diagnostics,passed=passed)
    })
  })
  ordered <- points[order(vapply(points,`[[`,0.,"rho"))]
  monotone <- all(diff(vapply(ordered,function(x) x$adjust$rstar,0.))<=1e-4)
  list(id=id,N=ctx$persons,source=source,compression=equivalent,I=base[[2]]$I,J=source$J,
    center=center,endpoints=ends,locations=length(points),sampled_monotone=monotone,
    passed=all(vapply(ends,`[[`,TRUE,"passed")) && monotone,
    coverage_qualified=FALSE)
}
for (id in c(1L,5L)) {
  tryCatch(phase(id,"result",function() run_case(id)),error=function(e) {
    cat("Retained case",id,"unavailable:",conditionMessage(e),"\n")
  })
}
rows <- lapply(c(1L,5L),function(id) {
  x <- readRDS(file.path(out,sprintf("case-%02d-result.rds",id)))
  if(nzchar(x$error)) return(data.frame(Case=id,N=if(id==1L)20L else 240L,
    Lower=NA_real_,Upper=NA_real_,Center=NA_real_,CenterError=NA_real_,Locations=NA_integer_,
    Seconds=x$elapsed,Passed=FALSE,Reason=x$error))
  z <- x$value
  data.frame(Case=id,N=z$N,Lower=z$endpoints$Lower$variance,Upper=z$endpoints$Upper$variance,
    Center=z$center$limit,CenterError=z$center$error,Locations=z$locations,
    Seconds=x$elapsed,Passed=z$passed,Reason="")
})
table <- do.call(rbind,rows); print(table,row.names=FALSE)
saveRDS(table,file.path(out,"summary.rds")); write.csv(table,file.path(out,"summary.csv"),row.names=FALSE)
boundary <- readRDS(file.path(prior,"case-04.rds")); refused <- readRDS(file.path(prior,"case-06.rds"))
stopifnot(boundary$zero_in_candidate_set,refused$status=="source_refused")
saveRDS(list(boundary="unevaluated: zero boundary/incomplete profile",
  refused="unevaluated: category refusal",new_responses=0L,normal_control=ctl,session=sessionInfo()),
  file.path(out,"controls.rds"))
files <- list.files(out,full.names=TRUE); files <- files[!endsWith(files,"verification.rds")]
saveRDS(list(files=tools::md5sum(files),binding=binding,all_passed=all(table$Passed)),
  file.path(out,"verification.rds"))
