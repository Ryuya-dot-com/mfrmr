# Saved-only verification and combined reporting of the original/continued runs.
out <- "validation-results/mfrm-lr-rstar-inversion-20261013"
script <- "inst/validation/mfrm-lr-rstar-inversion-review-20261013.R"
helper <- "inst/validation/mfrm-lr-rstar-inversion-helpers-20261013.R"
source(helper)
check <- function(h) stopifnot(!anyNA(h),identical(h,tools::md5sum(names(h))))
parent <- readRDS(file.path(out,"manifest.rds")); check(parent$inputs); check(parent$source)
continuation <- readRDS(file.path(out,"contraction-manifest.rds"))
stopifnot(identical(continuation$parent,parent)); check(continuation$source); check(continuation$diagnostic)
old_audit <- readRDS(file.path(out,"verification.rds")); check(old_audit$files)
paths <- file.path(out,c("case-01-result-contraction.rds","case-05-result.rds"))
results <- lapply(paths,readRDS)
stopifnot(identical(results[[1]]$binding,continuation),identical(results[[2]]$binding,parent))
stopifnot(all(vapply(results,function(x) !nzchar(x$error) && isTRUE(x$value$passed),TRUE)))
export <- list(); rows <- list()
for (i in seq_along(results)) {
  z <- results[[i]]$value; id <- z$id
  for (e in z$endpoints) {
    p <- e$point
    a <- rstar_adjust(z$I,p$cross$S,p$cross$Q,z$J,p$H,p$adjust$r)
    stopifnot(identical(a,p$adjust),e$passed)
    export[[length(export)+1L]] <- list(case=id,side=e$side,I=z$I,S=p$cross$S,Q=p$cross$Q,
      J=z$J,H=p$H,r=p$adjust$r,rstar=p$adjust$rstar)
  }
  for (c in z$center$derivatives) {
    v <- c$value$v; eta <- seq_len(nrow(z$I)-1L)
    M0 <- cbind(z$I[,eta],-z$I%*%v)
    M1 <- cbind(c$B[,eta],-c$B%*%v/2)
    b <- sum(diag(solve(M0,M1)))-sum(diag(solve(z$J[eta,eta],c$Jdot[eta,eta])))/2
    limit <- -(b-c$value$t/(6*c$value$h))/sqrt(c$value$h)
    stopifnot(abs(limit-c$value$limit)<1e-10)
  }
  points <- list.files(out,pattern=sprintf("^case-%02d-point-.*rds$",id),full.names=TRUE)
  all <- lapply(points,readRDS)
  stopifnot(length(points)<=32L)
  failures <- sum(vapply(all,function(x) nzchar(x$error),TRUE))
  phases <- list.files(out,pattern=sprintf("^case-%02d-.*rds$",id),full.names=TRUE)
  phases <- phases[!grepl("-result",basename(phases),fixed=TRUE)]
  seconds <- sum(vapply(lapply(phases,readRDS),`[[`,0.,"elapsed"))
  old <- readRDS(sprintf("validation-results/mfrm-lr-rstar-20261013/case-%02d.rds",id))$value
  compression <- readRDS(file.path(out,sprintf("case-%02d-compression.rds",id)))
  rows[[i]] <- data.frame(Case=id,N=z$N,Lower=z$endpoints$Lower$variance,
    Upper=z$endpoints$Upper$variance,Center=z$center$limit,CenterError=z$center$error,
    AttemptedLocations=length(points),FailedLocations=failures,PhaseSeconds=seconds,
    OldMomentSeconds=old$elapsed,CompressedMomentSeconds=compression$elapsed,
    SourceMovement=z$source$refinement$movement,SourceGradient=z$source$refinement$gradient,
    Passed=z$passed,CoverageQualified=FALSE)
}
table <- do.call(rbind,rows)
input_paths <- c(file.path(out,c("manifest.rds","contraction-manifest.rds","verification.rds")),
  paths,unlist(lapply(c(1L,5L),function(id) list.files(out,
    pattern=sprintf("^case-%02d-.*rds$",id),full.names=TRUE))))
review <- list(table=table,inputs=tools::md5sum(unique(input_paths)),
  source=tools::md5sum(c(script,helper)),all_passed=TRUE)
path <- file.path(out,"inversion-review.rds")
if(file.exists(path)) stopifnot(identical(readRDS(path),review)) else {
  saveRDS(review,path); write.csv(table,file.path(out,"inversion-review.csv"),row.names=FALSE)
  jsonlite::write_json(export,file.path(out,"independent-input.json"),digits=NA,auto_unbox=TRUE)
}
print(table,row.names=FALSE)
cat("PASS: complete saved-only interval, central-limit, failed-location and binding review.\n")
