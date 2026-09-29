# Repository-only, fixed independent feasibility study; see the companion protocol.
source("inst/validation/gmfrm-sparse-intervals-20260928.R")
source("inst/validation/gpcm-profile-comparison-20260927.R")

gmfrm_profile_feasibility_plan <- function() {
  p <- gmfrm_sparse_plan()
  p$repetitions <- 20L; p$seed <- 92960000L
  p$quad_points <- 121L; p$em_score_tol <- 1e-7
  p$targets <- list(c(Task="t3"), c(Rater="r3"))
  p$profile_control <- list(maxit=400L, max_steps=8L, initial_step=.5)
  p
}

gmfrm_profile_feasibility_hashes <- function() tools::md5sum(sort(c(
  names(gmfrm_sparse_sources()),
  "inst/validation/gpcm-profile-comparison-20260927.R",
  "inst/validation/gmfrm-profile-feasibility-20260929.R",
  "inst/validation/gmfrm-profile-feasibility-20260929.md",
  getLoadedDLLs()[["mfrmr"]][["path"]])))

gmfrm_profile_capture <- function(call) {
  warnings <- character(); error <- ""; result <- NULL
  elapsed <- system.time(tryCatch(withCallingHandlers(result <- call(),
    warning=function(w) { warnings <<- c(warnings,conditionMessage(w)); invokeRestart("muffleWarning") }),
    error=function(e) error <<- conditionMessage(e)))
  list(result=result,error=error,warnings=unique(warnings),seconds=elapsed[["elapsed"]],
    cpu=sum(elapsed[c("user.self","sys.self")]))
}

gmfrm_profile_feasibility_run <- function(out, cores=2L) {
  plan <- gmfrm_profile_feasibility_plan(); hashes <- gmfrm_profile_feasibility_hashes()
  stopifnot(cores %in% 1:2)
  keys <- names(gmfrm_sparse_data(1L,plan)$cases)
  jobs <- expand.grid(id=seq_len(plan$repetitions),key=keys,stringsAsFactors=FALSE)
  manifest <- list(plan=plan,jobs=jobs,source_hash=hashes)
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  path <- file.path(out,"manifest.rds")
  if(file.exists(path)) stopifnot(identical(readRDS(path),manifest)) else {
    saveRDS(manifest,path)
    writeLines(capture.output(sessionInfo()),file.path(out,"session-info.txt"))
  }
  worker <- function(i) {
    id <- jobs$id[i]; key <- jobs$key[i]
    case <- gmfrm_sparse_data(id,plan)$cases[[key]]
    path <- file.path(out,sprintf("%03d-%s.rds",id,key))
    if(file.exists(path)) {
      old <- readRDS(path)
      stopifnot(identical(old$id,id),identical(old$key,key),identical(old$case,case),
        identical(old$plan,plan),identical(old$source_hash,hashes))
      return(TRUE)
    }
    started <- proc.time()[["elapsed"]]
    fitted <- gmfrm_profile_capture(function() fit_mfrm(case$data,person="Person",
      facets=c("Task","Rater"),score="Score",model="GPCM",method="MML",
      slope_facet=c("Task","Rater"),step_facet="Rater",noncenter_facet="Rater",
      gpcm_mml_identification="fixed_standard_normal",mml_engine="em",
      rating_min=0,rating_max=2,category_policy="preserve",quad_points=plan$quad_points,
      maxit=plan$maxit,em_score_tol=plan$em_score_tol))
    fit <- fitted$result
    unavailable <- list(result=NULL,error=paste("Source fit unavailable:",fitted$error),
      warnings=character(),seconds=0,cpu=0)
    wald <- if(is.null(fit)) unavailable else gmfrm_profile_capture(function()
      confint(fit,method="model",level=plan$level))
    profiles <- lapply(plan$targets,function(target) if(is.null(fit)) unavailable else
      gmfrm_profile_capture(function() confint(fit,method="profile",slope=target,
        level=plan$level,profile_control=plan$profile_control)))
    rows <- do.call(rbind,lapply(seq_along(plan$targets),function(j) {
      target <- plan$targets[[j]]; owner <- names(target); lev <- unname(target)
      truth <- case$truth$Truth[case$truth$SlopeOwner==owner & case$truth$SlopeLevel==lev]
      stopifnot(length(truth)==1L)
      do.call(rbind,lapply(c("model","profile"),function(method) {
        value <- if(method=="model") wald else profiles[[j]]
        ci <- value$result
        row <- data.frame(Replicate=id,Design=case$design,AbilitySD=case$sd,
          Owner=owner,Level=lev,Method=method,Truth=truth,Converged=isTRUE(fit$summary$Converged),
          Returned=!is.null(ci),Available=FALSE,Covered=FALSE,Estimate=NA_real_,
          Lower=NA_real_,Upper=NA_real_,Reason=value$error,
          LowerStatus="not_returned",UpperStatus="not_returned",Seconds=value$seconds,CPU=value$cpu)
        if(!is.null(ci)) {
          d <- attr(ci,"diagnostics")
          d <- d[d$SlopeOwner==owner & d$SlopeLevel==lev,,drop=FALSE]
          stopifnot(nrow(d)==1L)
          row$Estimate <- d$Estimate; row$Lower <- d$CI_Lower; row$Upper <- d$CI_Upper
          row$Available <- isTRUE(d$CIEligible) && all(is.finite(c(row$Lower,row$Upper)))
          row$Covered <- row$Available && row$Lower<=truth && row$Upper>=truth
          row$Reason <- d$InferenceReview
          if(method=="profile") {
            e <- attr(ci,"profile")$endpoints
            row$LowerStatus <- e$Status[1]; row$UpperStatus <- e$Status[2]
          } else row$LowerStatus <- row$UpperStatus <- if(row$Available) "computed" else "source_checks_failed"
        }
        row
      }))
    }))
    stopifnot(identical(hashes,gmfrm_profile_feasibility_hashes()))
    result <- list(id=id,key=key,case=case,plan=plan,fit=fitted,wald=wald,profiles=profiles,
      rows=rows,source_hash=hashes,seconds=proc.time()[["elapsed"]]-started)
    saveRDS(result,paste0(path,".tmp")); stopifnot(file.rename(paste0(path,".tmp"),path))
    cat(sprintf("%03d %s: Wald %d/2; profile %d/2; %.1fs\n",id,key,
      sum(rows$Available[rows$Method=="model"]),sum(rows$Available[rows$Method=="profile"]),result$seconds))
    flush.console(); TRUE
  }
  done <- parallel::mclapply(seq_len(nrow(jobs)),worker,mc.cores=cores,mc.preschedule=FALSE,mc.set.seed=FALSE)
  stopifnot(all(vapply(done,isTRUE,logical(1))))
  gmfrm_profile_feasibility_summary(out)
}

gmfrm_profile_feasibility_summary <- function(out) {
  manifest <- readRDS(file.path(out,"manifest.rds")); jobs <- manifest$jobs
  paths <- file.path(out,sprintf("%03d-%s.rds",jobs$id,jobs$key))
  stopifnot(all(file.exists(paths)))
  cases <- lapply(paths,readRDS)
  stopifnot(all(vapply(cases,function(z) identical(z$source_hash,manifest$source_hash),logical(1))))
  rows <- do.call(rbind,lapply(cases,`[[`,"rows"))
  stopifnot(nrow(rows)==4L*nrow(jobs),!anyDuplicated(rows[c("Replicate","Design","AbilitySD","Owner","Level","Method")]))
  groups <- split(rows,interaction(rows$Design,rows$AbilitySD,rows$Owner,rows$Level,drop=TRUE))
  summary <- do.call(rbind,lapply(groups,function(d) {
    s <- profile_comparison_summary(d,manifest$plan$repetitions)
    cbind(d[rep(1L,nrow(s)),c("Design","AbilitySD","Owner","Level")],s)
  }))
  paired <- do.call(rbind,lapply(groups,function(d) {
    w <- d[d$Method=="model",]; p <- d[d$Method=="profile",]
    p <- p[match(w$Replicate,p$Replicate),]; both <- w$Available & p$Available
    data.frame(d[1,c("Design","AbilitySD","Owner","Level")],
      Both=sum(both),WaldOnly=sum(w$Available & !p$Available),
      ProfileOnly=sum(!w$Available & p$Available),Neither=sum(!w$Available & !p$Available),
      WaldCoveredWhenBoth=sum(w$Covered[both]),ProfileCoveredWhenBoth=sum(p$Covered[both]))
  }))
  failures <- aggregate(rep(1L,nrow(rows)),rows[c("Design","AbilitySD","Owner","Level","Method","LowerStatus","UpperStatus")],sum)
  names(failures)[ncol(failures)] <- "Count"
  cost <- do.call(rbind,lapply(split(rows,interaction(rows$Design,rows$AbilitySD,rows$Owner,rows$Level,rows$Method,drop=TRUE)),function(d) {
    width <- log(d$Upper[d$Available])-log(d$Lower[d$Available])
    data.frame(d[1,c("Design","AbilitySD","Owner","Level","Method")],Converged=sum(d$Converged),
      Returned=sum(d$Returned),MeanLogWidth=if(length(width)) mean(width) else NA_real_,
      MedianCallSeconds=median(d$Seconds),MaxCallSeconds=max(d$Seconds),TotalCallCPU=sum(d$CPU))
  }))
  # Wald is one call per fit, repeated in two target rows only for per-target comparison.
  timing <- data.frame(Fits=length(cases),TotalFitSeconds=sum(vapply(cases,function(z)z$fit$seconds,0)),
    TotalWaldSeconds=sum(vapply(cases,function(z)z$wald$seconds,0)),
    TotalProfileSeconds=sum(vapply(cases,function(z)sum(vapply(z$profiles,`[[`,0,"seconds")),0)))
  for(name in c("rows","summary","paired","failures","cost","timing"))
    write.csv(get(name),file.path(out,paste0(name,".csv")),row.names=FALSE)
  print(paired); print(timing)
  invisible(summary)
}

if(sys.nframe()==0L) {
  pkgload::load_all(quiet=TRUE,compile=FALSE)
  args <- commandArgs(trailingOnly=TRUE)
  if(identical(args[1],"run")) gmfrm_profile_feasibility_run(args[2])
  else if(identical(args[1],"summary")) gmfrm_profile_feasibility_summary(args[2])
  else stop("Use run OUTPUT or summary OUTPUT.")
}
