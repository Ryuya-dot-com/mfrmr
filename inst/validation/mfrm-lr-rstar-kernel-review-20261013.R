# Retained-point likelihood/score review; no optimization, generation or new CI.
action <- commandArgs(TRUE)
stopifnot(length(action)==1L, action %in% c("run", "replay"))
script <- "inst/validation/mfrm-lr-rstar-kernel-review-20261013.R"
helper <- "inst/validation/mfrm-lr-rstar-inversion-helpers-20261013.R"
boundary <- "inst/validation/mfrm-lr-rsm-boundary-20261009.R"
prior <- "validation-results/mfrm-lr-rstar-inversion-20261013"
out <- "validation-results/mfrm-lr-rstar-kernel-review-20261013"
installed <- "tmp/owner-category-20261012/install-check"
check <- function(h) stopifnot(length(h)>0L, !anyNA(h), identical(h,tools::md5sum(names(h))))
relative <- function(a,b) max(abs(a-b))/max(1,max(abs(b)))
save_new <- function(x,path) {
  stopifnot(!file.exists(path)); saveRDS(x,paste0(path,".tmp"))
  stopifnot(file.rename(paste0(path,".tmp"),path))
}
report <- function(results) {
  rows <- do.call(rbind,lapply(results,`[[`,"accuracy"))
  times <- do.call(rbind,lapply(results,`[[`,"timing"))
  curve <- do.call(rbind,lapply(results,`[[`,"curvature"))
  list(points=rows, timing=times, curvature=curve,
    all_passed=all(rows$Passed) && all(curve$Passed), coverage_qualified=FALSE)
}
if (action=="replay") {
  m <- readRDS(file.path(out,"manifest.rds")); check(m$inputs); check(m$source)
  a <- readRDS(file.path(out,"verification.rds")); check(a$files)
  z <- lapply(m$ids,function(id) readRDS(file.path(out,sprintf("case-%02d.rds",id))))
  stopifnot(identical(report(z),readRDS(file.path(out,"report.rds"))))
  cat("PASS: fresh saved-only source, input and report replay; no package load.\n")
  print(readRDS(file.path(out,"report.rds"))$curvature,row.names=FALSE)
  quit(save="no")
}
threads <- c("OMP_NUM_THREADS","OPENBLAS_NUM_THREADS","MKL_NUM_THREADS","VECLIB_MAXIMUM_THREADS")
stopifnot(all(Sys.getenv(threads)=="1"))
review <- readRDS(file.path(prior,"inversion-review.rds")); check(review$inputs); check(review$source)
old <- readRDS(file.path(prior,"manifest.rds")); check(old$inputs)
parent_path <- "validation-results/mfrm-lr-rsm-adaptive-profile-20261010/manifest.rds"
parent <- readRDS(parent_path)
fits <- names(parent$inputs)[endsWith(names(parent$inputs),"-fit.rds")]
diagnostic <- "tmp/pdfs/population-rstar-20261013/failed-upper-review.rds"
far <- readRDS(diagnostic); check(far$inputs)
# Use the already installed isolated runtime. Its three source differences are
# export/help or an unrelated GMFRM reference; every other R file must match.
saved_R <- old$source[startsWith(names(old$source),"R/")]
installed_R <- tools::md5sum(file.path(installed,"source/mfrmr",names(saved_R)))
exceptions <- c("R/api-model-export.R","R/core-gmfrm-reference.R","R/help_visual_diagnostics.R")
stopifnot(!anyNA(installed_R),identical(names(saved_R)[unname(saved_R)!=unname(installed_R)],exceptions))
library_files <- list.files(file.path(installed,"library/mfrmr"),recursive=TRUE,full.names=TRUE)
binding <- list(inputs=tools::md5sum(unique(c(names(review$inputs),parent_path,
    file.path(prior,"inversion-review.rds"),diagnostic,fits[c(1L,5L)]))),
  source=tools::md5sum(c(script,helper,boundary,names(installed_R),library_files)),
  ids=c(1L,5L),R=R.version,threads=Sys.getenv(threads),exceptions=exceptions,
  protocol=list(points="Every saved passing profile point, both refined sources and both failed-far attempts",
    models=c("adaptive31","adaptive61","fixed121","fixed241","factor241"),rounds=3L,
    nll=1e-5,gradient=1e-4,algebra_nll=1e-9,algebra_gradient=1e-8,
    hessian=1e-5,rstar=1e-5,center=1e-4,finite_difference=1e-5,
    target="Fixed-point equivalence/cost, not optimization-path equivalence or coverage"))
dir.create(out,recursive=TRUE,showWarnings=FALSE)
mp <- file.path(out,"manifest.rds")
if(file.exists(mp)) stopifnot(identical(readRDS(mp),binding)) else save_new(binding,mp)
library(mfrmr,lib.loc=file.path(installed,"library"))
stopifnot(identical(normalizePath(find.package("mfrmr")),normalizePath(file.path(installed,"library/mfrmr"))))
source(helper); source(boundary)
blocked <- function(...) stop("No fitting, response generation or unrelated GMFRM calculation in this review")
for(name in c("fit_mfrm","simulate_mfrm_data","mfrm_gmfrm_reference_integrate"))
  assignInNamespace(name,blocked,"mfrmr")
for(name in c("optim","nlminb","nlm","rnorm","runif","rbinom")) assignInNamespace(name,blocked,"stats")
stopifnot(mfrmr:::mfrm_cpp11_backend_available())

for(id in binding$ids) {
  path <- file.path(out,sprintf("case-%02d.rds",id))
  if(file.exists(path)) next
  fit <- readRDS(fits[id])$payload$value; ctx <- rsm_lr_boundary_context(fit)
  stopifnot(ctx$K==4L,all(lengths(ctx$groups)==6L))
  result_path <- file.path(prior,if(id==1L) "case-01-result-contraction.rds" else "case-05-result.rds")
  old_result <- readRDS(result_path)$value
  points <- list(source=old_result$source$p)
  point_paths <- list.files(prior,sprintf("^case-%02d-point-.*rds$",id),full.names=TRUE)
  old_failures <- character()
  for(p in point_paths) {
    x <- readRDS(p)
    if(nzchar(x$error)) old_failures <- c(old_failures,basename(p)) else
      points[[basename(p)]] <- x$value$p
  }
  if(id==1L) for(j in seq_along(far$attempts)) points[[paste0("failed-far-start",j)]] <- far$attempts[[j]]$parameters
  stopifnot(!anyDuplicated(points))
  # The existing complete-pattern formula also accepts only the observed row.
  observed <- lapply(ctx$groups,function(ix) list(
    D=lapply(ix,function(i) do.call(rbind,lapply(ctx$design,function(D) D[i,]))),
    Ds=matrix(colSums(ctx$observed[ix,,drop=FALSE]),1L),totals=sum(ctx$y[ix])))
  gh <- mfrmr:::gauss_hermite_normal(241L)
  factor_eval <- function(p) {
    z <- lapply(observed,pat_score,par=p,gh=gh)
    c(value=-sum(vapply(z,function(x) x$logmass,0.)),
      gradient=-colSums(do.call(rbind,lapply(z,`[[`,"score"))))
  }
  idx <- mfrmr:::build_indices(fit$prep,fit$config$step_facet,fit$config$slope_facet,
    fit$config$interaction_specs,gpcm_spec=fit$config$gpcm_spec)
  make <- function(model) {
    if(model=="factor241") return(list(evaluate=factor_eval))
    cfg <- fit$config; adaptive <- startsWith(model,"adaptive")
    q <- as.integer(sub("[a-z]+","",model)); cfg$estimation_control$mml_integration <- if(adaptive) "adaptive" else "fixed"
    cfg$estimation_control$quad_points <- q
    e <- mfrmr:::make_mfrm_direct_evaluator("MML",
      mfrmr:::make_param_cache(ctx$sizes,cfg,idx,is_mml=TRUE),idx,cfg,ctx$sizes,
      mfrmr:::gauss_hermite_normal(q))
    list(evaluate=function(p) c(value=e$value(p),gradient=e$gradient(p)),evaluator=e)
  }
  results <- list(); timing <- list()
  for(round in seq_len(binding$protocol$rounds)) {
    models <- binding$protocol$models
    if(round%%2==0L) models <- rev(models)
    for(model in models) {
      setup <- proc.time()[["elapsed"]]; e <- make(model); setup <- proc.time()[["elapsed"]]-setup
      begin <- proc.time()[["elapsed"]]
      values <- do.call(rbind,lapply(points,e$evaluate))
      seconds <- proc.time()[["elapsed"]]-begin
      count <- if(is.null(e$evaluator)) length(points) else e$evaluator$diagnostics()$SharedEvaluations
      stopifnot(count==length(points),all(is.finite(values)))
      if(round==1L) results[[model]] <- values else stopifnot(identical(results[[model]],values))
      timing[[length(timing)+1L]] <- data.frame(Case=id,N=ctx$persons,Model=model,
        Round=round,Points=length(points),Seconds=seconds,SetupSeconds=setup,Evaluations=count)
      cat(id,round,model,round(seconds,3),"seconds\n"); flush.console()
    }
  }
  a <- results$adaptive61; f <- results$fixed241; lower <- results$fixed121; exact <- results$factor241
  accuracy <- data.frame(Case=id,N=ctx$persons,Point=names(points),
    FixedAdaptiveNLL=abs(f[,1]-a[,1]),FixedAdaptiveGradient=apply(abs(f[,-1]-a[,-1]),1,max),
    FixedOrderNLL=abs(f[,1]-lower[,1]),FixedOrderGradient=apply(abs(f[,-1]-lower[,-1]),1,max),
    FactorNLL=abs(exact[,1]-f[,1]),FactorGradient=apply(abs(exact[,-1]-f[,-1]),1,max),
    AdaptiveOrderNLL=abs(results$adaptive31[,1]-a[,1]),
    AdaptiveOrderGradient=apply(abs(results$adaptive31[,-1]-a[,-1]),1,max))
  accuracy$Passed <- with(accuracy,FixedAdaptiveNLL<=1e-5 & FixedAdaptiveGradient<=1e-4 &
    FixedOrderNLL<=1e-5 & FixedOrderGradient<=1e-4 & FactorNLL<=1e-9 & FactorGradient<=1e-8)
  save_new(list(accuracy=accuracy,results=results,timing=do.call(rbind,timing),
    points=points,old_failures=old_failures,manifest=tools::md5sum(mp)),
    file.path(out,sprintf("case-%02d-evaluations.rds",id)))
  stopifnot(all(accuracy$Passed))
  high <- make("fixed241")$evaluator; d <- length(points$source)
  hessian <- function(p) optimHess(p,high$value,high$gradient,control=list(ndeps=rep(1e-4,d)))
  J <- hessian(points$source)
  curvature <- list(data.frame(Case=id,N=ctx$persons,Point="source",
    HessianRelativeError=relative(J,old_result$J),StatisticError=NA_real_,
    ContinuousNLL=abs(high$value(points$source)-old_result$source$reference$value)+old_result$source$reference$summed_relative_error))
  for(side in names(old_result$endpoints)) {
    end <- old_result$endpoints[[side]]; p <- end$point$p
    H <- hessian(p)[-d,-d,drop=FALSE]
    r <- sign(tail(points$source,1)-tail(p,1))*sqrt(2*(high$value(p)-high$value(points$source)))
    star <- rstar_adjust(old_result$I,end$point$cross$S,end$point$cross$Q,J,H,r)
    curvature[[length(curvature)+1L]] <- data.frame(Case=id,N=ctx$persons,Point=side,
      HessianRelativeError=relative(H,end$point$H),StatisticError=abs(star$rstar-end$point$adjust$rstar),
      ContinuousNLL=abs(high$value(p)-end$reference$value)+end$reference$summed_relative_error)
  }
  c <- tail(old_result$center$derivatives,1L)[[1L]]; v <- c$value$v
  jd <- (hessian(points$source+c$h*v)-hessian(points$source-c$h*v))/(2*c$h)
  center <- rstar_center(old_result$I,J,c$B,jd)
  center_error <- abs(center$limit-old_result$center$limit)
  fd <- vapply(seq_len(d),function(j) {
    h <- 1e-5*max(1,abs(points$source[j])); plus <- minus <- points$source
    plus[j] <- plus[j]+h; minus[j] <- minus[j]-h
    (factor_eval(plus)[1]-factor_eval(minus)[1])/(2*h)
  },0.)
  fd_error <- max(abs(fd-factor_eval(points$source)[-1]))
  curve <- do.call(rbind,curvature)
  curve$Passed <- with(curve,HessianRelativeError<=1e-5 & ContinuousNLL<=1e-5 &
    (is.na(StatisticError)|StatisticError<=1e-5))
  stopifnot(all(curve$Passed),center_error<=1e-4,fd_error<=1e-5)
  z <- list(accuracy=accuracy,timing=do.call(rbind,timing),curvature=curve,
    center_error=center_error,finite_difference_error=fd_error,results=results,
    points=points,old_failures=old_failures,manifest=tools::md5sum(mp))
  save_new(z,path)
  cat("PASS: case",id,"points, curvature, center and independent finite differences.\n"); flush.console()
}
check(binding$inputs); check(binding$source)
paths <- file.path(out,sprintf("case-%02d.rds",binding$ids))
z <- lapply(paths,readRDS); result <- report(z)
stopifnot(result$all_passed)
save_new(result,file.path(out,"report.rds"))
write.csv(result$points,file.path(out,"points.csv"),row.names=FALSE)
write.csv(result$timing,file.path(out,"timing.csv"),row.names=FALSE)
write.csv(result$curvature,file.path(out,"curvature.csv"),row.names=FALSE)
save_new(list(files=tools::md5sum(c(mp,paths,file.path(out,c("report.rds","points.csv","timing.csv","curvature.csv"))))),
  file.path(out,"verification.rds"))
cat("PASS: no optimization, response generation or public API changes.\n")
