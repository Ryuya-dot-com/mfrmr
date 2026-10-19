# Boundary-score information identities, not finite-sample coverage evidence.
# Uses the five frozen sources and no simulation, integration or optimization.
script <- 'inst/validation/mfrm-lr-rsm-boundary-information-20261010.R'
root <- 'validation-results/mfrm-lr-rsm-adaptive-profile-20261010'
audit_path <- file.path(root,'verification.rds')
stopifnot(unname(tools::md5sum(audit_path))=='3d0f9182d37aad6d78bae2f31d704f55')
audit <- readRDS(audit_path)
verify <- function(h) stopifnot(length(h)>0L,!anyNA(h),
  identical(unname(tools::md5sum(names(h))),unname(h)))
stopifnot(audit$passed); verify(audit$retained); verify(audit$source)
manifest <- readRDS(file.path(root,'manifest.rds')); verify(manifest$inputs)
pkgload::load_all('.',quiet=TRUE,compile=FALSE)
source('inst/validation/mfrm-lr-rsm-boundary-20261009.R')
verify(manifest$source[names(manifest$source)!='loaded_mfrmr_DLL'])
stopifnot(unname(tools::md5sum(getLoadedDLLs()[['mfrmr']][['path']]))==
  unname(manifest$source['loaded_mfrmr_DLL']),
  identical(sessionInfo(),manifest$session),
  identical(Sys.getenv(names(manifest$threads)),manifest$threads))
fit_paths <- names(manifest$inputs)[endsWith(names(manifest$inputs),'-fit.rds')]
selected_paths <- names(manifest$inputs)[endsWith(names(manifest$inputs),'/selected.rds')]
stopifnot(length(fit_paths)==6L,length(selected_paths)==6L)
started <- proc.time()[['elapsed']]
results <- rows <- list()
for (i in 1:6) {
  case <- readRDS(file.path(root,sprintf('case-%02d.rds',i)))
  if (case$status=='source_refused') {
    results[[i]] <- list(status=case$status,reason=case$reason)
    next
  }
  fit <- readRDS(fit_paths[i])$payload$value
  zero <- readRDS(selected_paths[i])$payload$zero$value
  stopifnot(zero$qualified)
  ctx <- rsm_lr_boundary_context(fit); z <- rsm_lr_boundary_eval(ctx,zero$eta)
  P <- z$probability; K <- ctx$K; p <- ctx$p
  stopifnot(K==4L,all(lengths(ctx$groups)==6L))
  Y <- as.matrix(expand.grid(rep(list(0:(K-1L)),6L)))
  mu <- drop(P %*% (0:(K-1L)))
  U <- matrix(0:(K-1L),nrow(P),K,byrow=TRUE)-mu
  V <- rowSums(P*U^2); M4 <- rowSums(P*U^4)
  # The cross-rating products are orthogonal to every additive nuisance score.
  pairs <- sum(vapply(ctx$groups,function(ix)
    (sum(V[ix])^2-sum(V[ix]^2))/2,0.))
  Ivv <- sum(M4-V^2)/4+pairs
  Iev <- Reduce('+',lapply(seq_len(K),function(k)
    colSums(z$centered[[k]]*(P[,k]*U[,k]^2/2))))
  information <- rbind(cbind(z$hessian,Iev),c(Iev,Ivv))
  enumerated <- matrix(0,p+1L,p+1L); mass_error <- score_error <- 0
  for (ix in ctx$groups) {
    weight <- rep(1,nrow(Y)); S <- matrix(0,nrow(Y),p)
    for (j in seq_along(ix)) {
      row <- ix[j]; categories <- Y[,j]+1L
      weight <- weight*P[row,categories]
      category_scores <- do.call(rbind,lapply(z$centered,function(D) D[row,]))
      S <- S+category_scores[categories,,drop=FALSE]
    }
    Sv <- ((rowSums(Y)-sum(mu[ix]))^2-sum(V[ix]))/2
    scores <- cbind(S,Sv)
    mass_error <- max(mass_error,abs(sum(weight)-1))
    score_error <- max(score_error,max(abs(colSums(scores*weight))))
    enumerated <- enumerated+crossprod(scores*sqrt(weight))
  }
  relative_error <- max(abs(enumerated-information))/max(1,max(abs(information)))
  efficient <- Ivv-drop(crossprod(Iev,solve(z$hessian,Iev)))
  efficient_enum <- enumerated[p+1L,p+1L]-drop(crossprod(enumerated[1:p,p+1L],
    solve(enumerated[1:p,1:p],enumerated[1:p,p+1L])))
  min_eigen <- min(eigen(information,symmetric=TRUE,only.values=TRUE)$values)
  stopifnot(mass_error<=1e-10,score_error<=1e-10,relative_error<=1e-10,
    abs(efficient-efficient_enum)/max(1,efficient)<=1e-10,
    pairs>0,efficient>=pairs-1e-10*max(1,efficient),min_eigen>0)
  rows[[i]] <- data.frame(Case=i,N=ctx$persons,PatternsPerPerson=nrow(Y),
    MassError=mass_error,ExpectedScoreError=score_error,InformationRelativeError=relative_error,
    EfficientInformation=efficient,CrossRatingLowerBound=pairs,MinimumEigenvalue=min_eigen)
  results[[i]] <- list(status='identity_verified',information=information,
    enumerated_information=enumerated,eta=zero$eta,summary=rows[[i]])
}
summary <- do.call(rbind,rows)
stopifnot(nrow(summary)==5L,results[[6]]$status=='source_refused')
evidence <- list(passed=TRUE,results=results,summary=summary,
  inputs=c(tools::md5sum(audit_path),audit$retained,manifest$inputs),
  source=tools::md5sum(c(script,'inst/validation/mfrm-lr-rsm-boundary-20261009.R')),
  elapsed=proc.time()[['elapsed']]-started,session=sessionInfo(),
  new_fits=0L,new_draws=0L,new_profile_searches=0L,
  scope='Boundary information identities at saved nuisance values; no coverage qualification.')
saveRDS(evidence,file.path(root,'boundary-information.rds'))
write.csv(summary,file.path(root,'boundary-information.csv'),row.names=FALSE)
print(summary,digits=7)
cat(sprintf('PASS: all five boundary identities; refusal retained; %.3f seconds; no fits or draws.\n',evidence$elapsed))
