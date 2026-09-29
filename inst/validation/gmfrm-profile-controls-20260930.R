# Two prespecified post hoc follow-ups; original failures are never replaced.
# Budget case: same fit/grid, profile maxit 400 -> 1600, other controls unchanged.
# Integration case: public fixed-grid comparison 121 -> 181 (checked at 361),
# then default profile controls. No claim about general availability/coverage.
source("inst/validation/gmfrm-numerical-repair-20260930.R")

gmfrm_profile_controls_run <- function(out) {
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  if(file.exists(file.path(out,"manifest.rds"))) stop("Use a new output directory; completed cases remain unchanged.")
  paths <- c("inst/validation/gmfrm-profile-controls-20260930.R",
    "inst/validation/gmfrm-numerical-repair-20260930.R",names(gmfrm_sparse_sources()))
  paths <- unique(paths)
  input <- "validation-results/gmfrm-numerical-repair-20260930"
  jobs <- c(budget="011-common_persons-0.5.rds",quadrature="005-common_persons-1.rds")
  manifest <- list(jobs=jobs,input_hash=tools::md5sum(file.path(input,jobs)),
    source_hash=tools::md5sum(paths),native_hash=unname(tools::md5sum(getLoadedDLLs()[["mfrmr"]][["path"]])),
    purpose="Control sensitivity on two known failures; not independent sampling")
  saveRDS(manifest,file.path(out,"manifest.rds"))
  writeLines(capture.output(sessionInfo()),file.path(out,"session-info.txt"))
  for(p in paths) {
    dest <- file.path(out,"source",p); dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
    stopifnot(file.copy(p,dest))
  }
  worker <- function(name) {
    old <- readRDS(file.path(input,jobs[name])); fit <- old$fit$result
    comparison <- NULL
    if(name=="quadrature") {
      comparison <- gmfrm_profile_capture(function() mml_quadrature_sensitivity(fit,
        old$case$data,quad_points=c(121L,181L),theta_points=21L))
      fit <- comparison$result$fits$q181
      stopifnot(!is.null(fit))
    }
    result <- gmfrm_profile_capture(function() confint(fit,method="profile",slope=c(Task="t3"),
      profile_control=if(name=="budget") list(maxit=1600L) else list()))
    # Save the full outcome before independent checks so a failing check is retained.
    z <- list(original=file.path(input,jobs[name]),case=old$case,fit=fit,
      comparison=comparison,profile=result,source_hash=manifest$source_hash)
    saveRDS(z,file.path(out,paste0(name,".rds")))
    ci <- result$result; pr <- attr(ci,"profile"); checks <- list()
    if(!is.null(ci)) {
      order <- if(name=="budget") 241L else 361L
      baseline <- gmfrm_repair_literal_nll(fit$opt$par,old$case$data,order)
      for(side in which(pr$endpoints$Status=="computed")) {
        bound <- pr$endpoints$Bound[side]
        at <- which.min(abs(pr$profile$LogSlope-log(bound)))
        attempts <- pr$attempts[[sprintf("%.17g",pr$profile$LogSlope[at])]]
        for(start in names(attempts)) {
          a <- attempts[[start]]
          value <- gmfrm_repair_literal_nll(a$parameters,old$case$data,order)
          checks[[length(checks)+1L]] <- data.frame(Side=pr$endpoints$Side[side],Start=start,
            NLLDifference=abs(value-a$check$NLL),LRResidual=abs(2*(value-baseline)-pr$cutoff),
            ConstraintError=abs(-sum(a$parameters[15:16])-log(bound)),Passed=a$check$Passed)
        }
      }
    }
    z$identities <- do.call(rbind,checks); saveRDS(z,file.path(out,paste0(name,".rds")))
    cat(name,"seconds",result$seconds,"\n"); print(pr$endpoints); print(z$identities); flush.console()
    if(length(checks)) stopifnot(all(z$identities$Passed),all(z$identities$NLLDifference<=1e-5),
      all(z$identities$LRResidual<=1e-4),all(z$identities$ConstraintError<=1e-6))
    TRUE
  }
  done <- parallel::mclapply(names(jobs),worker,mc.cores=2L,mc.set.seed=FALSE)
  stopifnot(all(vapply(done,isTRUE,logical(1))))
}

if(sys.nframe()==0L) {
  pkgload::load_all(quiet=TRUE,compile=FALSE)
  gmfrm_profile_controls_run(commandArgs(trailingOnly=TRUE)[1])
}
