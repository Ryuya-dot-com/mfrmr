# Deterministic in-ball perturbations check the new generator-bound algebra.
source('inst/validation/mfrm-wide-map-pcm-r50-20261002.R');wide_pcm_setup()
source('inst/validation/jml-public-profile-bridge-20261002.R')
source('inst/validation/mfrm-wide-map-n30-accuracy-20261003.R')
args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args)==1L)
root <- args[1];out <- file.path(root,'summary-n30/accuracy-review')
audit <- wide_f_read(file.path(out,'audit.rds'))$payload
x <- audit$tables$ordinary
checks <- lapply(split(x,x$Arm),function(z) {
  id <- z$JobId[which.max(replace(z$JointGeneratorTV,!z$RootAdmitted,NA_real_))]
  fpath <- file.path(root,id,'calibration/q0-fit.rds')
  dpath <- file.path(root,'summary-n30/jml-inference/jobs',paste0(id,'.rds'))
  fit <- wide_f_read(fpath)$payload$value
  d <- wide_f_read(dpath)$payload$diagnostics;ctx <- jml_bridge_context(fit)
  gb <- wide_n30_generator_bound(ctx,d);B <- d$root_bound$transform
  r <- d$root_bound$summary$RootMetricRadius
  p <- length(ctx$beta);nl <- ncol(ctx$lin[[1]])
  finite <- is.finite(d$profile_theta);active <- which(finite)
  h <- c <- vector('list',ctx$np)
  for(i in active) {
    H <- jml_bridge_person(ctx,ctx$beta,d$profile_theta[i],ctx$groups[[i]])$hessian
    h[[i]] <- H[1,1];c[[i]] <- H[-1,1]
  }
  row_person <- integer(length(ctx$y))
  for(i in seq_along(ctx$groups))row_person[ctx$groups[[i]]] <- i
  probability <- function(beta,theta) {
    logits <- sapply(seq_len(ctx$K),function(k)
      (k-1)*theta[row_person]+drop(ctx$lin[[k]]%*%beta[seq_len(nl)]))
    slope <- if(p>nl)exp(drop(ctx$slope%*%beta[(nl+1):p])) else rep(1,length(ctx$y))
    logits <- logits*slope
    P <- matrix(0,nrow(logits),ncol(logits));keep <- finite[row_person]
    L <- logits[keep,,drop=FALSE];E <- exp(L-apply(L,1,max));P[keep,] <- E/rowSums(E)
    P[theta[row_person]==-Inf,1] <- 1;P[theta[row_person]==Inf,ctx$K] <- 1
    list(P=P,logits=logits)
  }
  base <- probability(ctx$beta,d$profile_theta)
  dim <- length(active)+p
  directions <- rbind(diag(dim),sin(outer(1:4,seq_len(dim))))
  directions <- directions/sqrt(rowSums(directions^2))
  maximum_ratio <- 0
  for(sign in c(-1,1))for(j in seq_len(nrow(directions))) {
    step <- sign*r*directions[j,];db <- drop(B%*%tail(step,p))
    theta <- d$profile_theta
    for(k in seq_along(active)) {
      i <- active[k];theta[i] <- theta[i]+step[k]/sqrt(h[[i]])-sum(c[[i]]*db)/h[[i]]
    }
    other <- probability(ctx$beta+db,theta)
    tv <- rowSums(abs(other$P-base$P))/2
    keep <- finite[row_person]
    span <- apply((other$logits-base$logits)[keep,,drop=FALSE],1,function(v)diff(range(v)))
    stopifnot(all(span<=gb$row_logit_span[keep]+1e-12),
      all(tv<=gb$row_logit_span/4+1e-12),all(tv[!keep]==0))
    maximum_ratio <- max(maximum_ratio,max(tv[keep]/(gb$row_logit_span[keep]/4)))
  }
  data.frame(JobId=id,Arm=z$Arm[1],Directions=2*nrow(directions),
    MaximumObservedTVToBound=maximum_ratio,Passed=TRUE)
})
result <- do.call(rbind,checks)
saveRDS(list(table=result,source=tools::md5sum(c(
  'inst/validation/mfrm-wide-map-n30-accuracy-check-20261003.R',
  'inst/validation/mfrm-wide-map-n30-accuracy-20261003.R')),
  inputs=tools::md5sum(file.path(out,'audit.rds')),
  interpretation='Deterministic algebra check at the two largest admitted bounds; not a proof or a new sampling experiment.'),
  file.path(out,'local-bound-checks.rds'))
print(result,row.names=FALSE)
