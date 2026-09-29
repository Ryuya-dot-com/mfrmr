# Matched development replay, not independent sampling confirmation.
# Frozen scope: all 40 low-SD sources/Task profiles; SD=1 common cases 5
# (Task and Rater), 9 (Task); rotating case 1 (both, successful control).
# Reuse observed data and original controls. No grid/threshold/time-limit rescue.
source("inst/validation/gmfrm-profile-feasibility-20260929.R")

gmfrm_repair_hashes <- function() tools::md5sum(sort(c(
  names(gmfrm_sparse_sources()),
  "inst/validation/gmfrm-profile-feasibility-20260929.R",
  "inst/validation/gpcm-profile-comparison-20260927.R",
  "inst/validation/gmfrm-numerical-repair-20260930.R",
  getLoadedDLLs()[["mfrmr"]][["path"]])))

# Literal score 0:2 formula; independent of the native response/likelihood kernel.
# These retained datasets have three tasks and six raters.
gmfrm_repair_literal_nll <- function(par, data, order=241L) {
  rule <- gauss_hermite_normal(order)
  task <- as.integer(factor(data$Task)); rater <- as.integer(factor(data$Rater))
  location <- c(par[1:2],-sum(par[1:2]))[task] + par[3:8][rater]
  slope <- exp(c(par[15:16],-sum(par[15:16]))[task]+par[17:22][rater])
  step <- par[9:14][rater]
  response_logp <- vapply(rule$nodes,function(theta) {
    z <- cbind(0,slope*(theta-location-step),2*slope*(theta-location))
    shift <- apply(z,1,max)
    z[cbind(seq_len(nrow(data)),data$Score+1L)]-shift-log(rowSums(exp(z-shift)))
  },numeric(nrow(data)))
  joint <- sweep(rowsum(response_logp,data$Person),2,log(rule$weights),"+")
  shift <- apply(joint,1,max)
  -sum(shift+log(rowSums(exp(joint-shift))))
}

gmfrm_repair_run <- function(out, cores=2L) {
  original <- "validation-results/gmfrm-profile-feasibility-20260929"
  jobs <- c(sprintf("%03d-common_persons-0.5.rds",1:20),
    sprintf("%03d-rotating_pairs-0.5.rds",1:20),
    "005-common_persons-1.rds","009-common_persons-1.rds","001-rotating_pairs-1.rds")
  hashes <- gmfrm_repair_hashes()
  manifest <- list(jobs=jobs,original=original,source_hash=hashes,
    input_hash=tools::md5sum(file.path(original,jobs)),
    purpose="Matched numerical repair; not independent coverage confirmation")
  stopifnot(cores %in% 1:2,!anyNA(manifest$input_hash))
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  path <- file.path(out,"manifest.rds")
  if(file.exists(path)) stopifnot(identical(manifest,readRDS(path))) else {
    saveRDS(manifest,path)
    writeLines(capture.output(sessionInfo()),file.path(out,"session-info.txt"))
    for(p in names(hashes)) {
      dest <- file.path(out,"source",if(startsWith(p,"/")) basename(p) else p)
      dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
      stopifnot(file.copy(p,dest),unname(tools::md5sum(dest))==unname(hashes[p]))
    }
  }
  worker <- function(job) {
    old <- readRDS(file.path(original,job)); path <- file.path(out,job)
    if(file.exists(path)) {
      z <- readRDS(path)
      stopifnot(identical(z$source_hash,hashes),identical(z$case,old$case))
      return(TRUE)
    }
    started <- proc.time()[["elapsed"]]
    plan <- old$plan; case <- old$case
    targets <- if(job %in% c("005-common_persons-1.rds","001-rotating_pairs-1.rds")) 1:2 else 1L
    fitted <- gmfrm_profile_capture(function() fit_mfrm(case$data,person="Person",
      facets=c("Task","Rater"),score="Score",model="GPCM",method="MML",
      slope_facet=c("Task","Rater"),step_facet="Rater",noncenter_facet="Rater",
      gpcm_mml_identification="fixed_standard_normal",mml_engine="em",
      rating_min=0,rating_max=2,category_policy="preserve",quad_points=plan$quad_points,
      maxit=plan$maxit,em_score_tol=plan$em_score_tol))
    fit <- fitted$result
    missing <- list(result=NULL,error=paste("Source unavailable:",fitted$error),seconds=0,cpu=0)
    wald <- if(is.null(fit)) missing else gmfrm_profile_capture(function()
      confint(fit,method="model",level=plan$level))
    profiles <- lapply(targets,function(j) if(is.null(fit)) missing else
      gmfrm_profile_capture(function() confint(fit,method="profile",slope=plan$targets[[j]],
        level=plan$level,profile_control=plan$profile_control)))
    baseline <- if(is.null(fit)) NA_real_ else gmfrm_repair_literal_nll(fit$opt$par,case$data)
    identities <- list()
    rows <- do.call(rbind,lapply(seq_along(targets),function(k) {
      j <- targets[k]; target <- plan$targets[[j]]; owner <- names(target)
      ci <- profiles[[k]]$result; pr <- attr(ci,"profile")
      prior <- old$rows[old$rows$Owner==owner & old$rows$Method=="profile",]
      row <- data.frame(Replicate=old$id,Design=case$design,AbilitySD=case$sd,Owner=owner,
        Level=unname(target),OldConverged=isTRUE(old$fit$result$summary$Converged),
        Converged=isTRUE(fit$summary$Converged),OldAvailable=prior$Available,
        Available=FALSE,Lower=NA_real_,Upper=NA_real_,FailedPoints=NA_integer_,
        LowerStatus="not_returned",UpperStatus="not_returned",Error=profiles[[k]]$error,
        Seconds=profiles[[k]]$seconds)
      if(!is.null(ci)) {
        d <- attr(ci,"diagnostics")
        row$Available <- isTRUE(d$CIEligible)
        row$Lower <- d$CI_Lower; row$Upper <- d$CI_Upper
        row$LowerStatus <- pr$endpoints$Status[1]; row$UpperStatus <- pr$endpoints$Status[2]
        row$FailedPoints <- sum(!pr$profile$Passed)
        contrast <- numeric(22); if(owner=="Task") contrast[15:16] <- -1 else contrast[19] <- 1
        for(side in which(pr$endpoints$Status=="computed")) {
          bound <- pr$endpoints$Bound[side]
          at <- which.min(abs(pr$profile$LogSlope-log(bound)))
          a <- pr$attempts[[sprintf("%.17g",pr$profile$LogSlope[at])]]
          for(start in names(a)) {
            trial <- a[[start]]; literal <- gmfrm_repair_literal_nll(trial$parameters,case$data)
            identities[[length(identities)+1L]] <<- data.frame(Replicate=old$id,
              Design=case$design,AbilitySD=case$sd,Owner=owner,Side=pr$endpoints$Side[side],
              Start=start,NLLDifference=abs(literal-trial$check$NLL),
              LRResidual=abs(2*(literal-baseline)-pr$cutoff),
              ConstraintError=abs(sum(contrast*trial$parameters)-log(bound)),Passed=trial$check$Passed)
          }
        }
      }
      row
    }))
    trace <- fit$opt$em_trace
    source <- data.frame(Replicate=old$id,Design=case$design,AbilitySD=case$sd,
      Converged=isTRUE(fit$summary$Converged),Iterations=tail(trace$iteration,1),
      MaxScore=tail(trace$max_score,1),Polished=sum(trace$mstep_polished),
      MinQGain=min(trace$q_gain,na.rm=TRUE),MinLogLikGain=min(diff(trace$logLik)),
      NLLDifference=abs(baseline-fit$opt$value),Seconds=fitted$seconds)
    stopifnot(identical(hashes,gmfrm_repair_hashes()))
    z <- list(original=file.path(original,job),case=case,plan=plan,targets=targets,
      fit=fitted,wald=wald,profiles=profiles,rows=rows,source=source,
      identities=do.call(rbind,identities),source_hash=hashes,
      seconds=proc.time()[["elapsed"]]-started)
    saveRDS(z,paste0(path,".tmp")); stopifnot(file.rename(paste0(path,".tmp"),path))
    cat(job,": source",source$Converged,"profiles",sum(rows$Available),"/",nrow(rows),
      sprintf("%.1fs",z$seconds),"\n"); flush.console(); TRUE
  }
  done <- parallel::mclapply(jobs,worker,mc.cores=cores,mc.preschedule=FALSE,mc.set.seed=FALSE)
  stopifnot(all(vapply(done,isTRUE,logical(1))))
  gmfrm_repair_summary(out)
}

gmfrm_repair_summary <- function(out) {
  manifest <- readRDS(file.path(out,"manifest.rds"))
  z <- lapply(file.path(out,manifest$jobs),readRDS)
  stopifnot(all(vapply(z,function(x) identical(x$source_hash,manifest$source_hash),logical(1))))
  for(name in c("rows","source","identities")) {
    tab <- do.call(rbind,lapply(z,`[[`,name))
    write.csv(tab,file.path(out,paste0(name,".csv")),row.names=FALSE)
    if(name=="rows") print(aggregate(cbind(OldAvailable,Available) ~ Design+AbilitySD+Owner,tab,sum))
    if(name=="identities") stopifnot(all(tab$Passed),all(tab$NLLDifference<=1e-5),
      all(tab$LRResidual<=1e-4),all(tab$ConstraintError<=1e-6))
  }
}

if(sys.nframe()==0L) {
  pkgload::load_all(quiet=TRUE,compile=FALSE)
  args <- commandArgs(trailingOnly=TRUE)
  if(identical(args[1],"run")) gmfrm_repair_run(args[2])
  else if(identical(args[1],"summary")) gmfrm_repair_summary(args[2])
  else stop("Use run OUTPUT or summary OUTPUT.")
}
