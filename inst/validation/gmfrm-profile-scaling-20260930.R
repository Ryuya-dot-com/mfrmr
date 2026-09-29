pkgload::load_all(quiet=TRUE,compile=FALSE)
source("inst/validation/gmfrm-numerical-repair-20260930.R")
out<-"validation-results/gmfrm-profile-scaled-20260930"
dir.create(out,recursive=TRUE,showWarnings=FALSE)
paths<-names(gmfrm_sparse_sources())
hashes<-tools::md5sum(paths)
for(p in paths) {
  dest<-file.path(out,"source",p); dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
  stopifnot(file.copy(p,dest))
}
writeLines(capture.output(sessionInfo()),file.path(out,"session-info.txt"))
for(job in c("011-common_persons-0.5.rds","016-rotating_pairs-0.5.rds")) {
  old<-readRDS(file.path("validation-results/gmfrm-numerical-repair-20260930",job))
  fit<-old$fit$result
  result<-gmfrm_profile_capture(function() confint(fit,method="profile",slope=c(Task="t3")))
  z<-list(original=job,fit=fit,profile=result,source_hash=hashes)
  saveRDS(z,file.path(out,job))
  pr<-attr(result$result,"profile"); checks<-list()
  baseline<-gmfrm_repair_literal_nll(fit$opt$par,old$case$data)
  for(i in which(pr$endpoints$Status=="computed")) {
    bound<-pr$endpoints$Bound[i]; at<-which.min(abs(pr$profile$LogSlope-log(bound)))
    attempts<-pr$attempts[[sprintf("%.17g",pr$profile$LogSlope[at])]]
    for(start in names(attempts)) {
      a<-attempts[[start]]; literal<-gmfrm_repair_literal_nll(a$parameters,old$case$data)
      checks[[length(checks)+1L]]<-data.frame(Side=pr$endpoints$Side[i],Start=start,
        NLLDifference=abs(literal-a$check$NLL),LRResidual=abs(2*(literal-baseline)-pr$cutoff),
        ConstraintError=abs(-sum(a$parameters[15:16])-log(bound)),Passed=a$check$Passed)
    }
  }
  z$identities<-do.call(rbind,checks); saveRDS(z,file.path(out,job))
  cat(job,"seconds",result$seconds,"\n"); print(pr$endpoints); print(z$identities); flush.console()
  stopifnot(!is.null(result$result),all(pr$endpoints$Status=="computed"),all(z$identities$Passed),
    all(z$identities$NLLDifference<=1e-5),all(z$identities$LRResidual<=1e-4),all(z$identities$ConstraintError<=1e-6))
}
