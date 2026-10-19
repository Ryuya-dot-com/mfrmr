# Repository-only RSM likelihood refinement, with the complete pattern law.
rstar_patterns <- function(ctx) {
  Y <- as.matrix(expand.grid(rep(list(0:3),6L)))
  totals <- rowSums(Y)
  lapply(ctx$groups,function(ix) {
    D <- lapply(ix,function(i) do.call(rbind,lapply(ctx$design,function(x) x[i,])))
    Ds <- Reduce(`+`,lapply(seq_along(ix),function(j) D[[j]][Y[,j]+1L,,drop=FALSE]))
    observed <- which(rowSums(abs(sweep(Y,2,ctx$y[ix],"-")))==0)
    stopifnot(length(observed)==1L)
    list(D=D,Ds=Ds,totals=totals,observed=observed)
  })
}
pat_score <- function(person,par,gh) {
  e <- sqrt(exp(tail(par,1)))*gh$nodes; nq <- length(e)
  denominator <- totalmean <- numeric(nq); Dmean <- matrix(0,nq,length(par)-1L)
  for (D in person$D) {
    a <- outer(e,0:3)+rep(drop(D%*%head(par,-1)),each=nq)
    peak <- apply(a,1,max); lz <- peak+log(rowSums(exp(a-peak)))
    P <- exp(a-lz); denominator <- denominator+lz
    Dmean <- Dmean+P%*%D; totalmean <- totalmean+drop(P%*%(0:3))
  }
  # The posterior residual law depends on the pattern only through its total.
  a <- outer(0:18,e)-rep(denominator-log(gh$weights),each=19L)
  peak <- apply(a,1,max); integral <- peak+log(rowSums(exp(a-peak)))
  post <- exp(a-integral); idx <- person$totals+1L
  lm <- drop(person$Ds%*%head(par,-1))+integral[idx]
  score <- cbind(person$Ds-(post%*%Dmean)[idx,,drop=FALSE],
    (person$totals*drop(post%*%e)[idx]-drop(post%*%(e*totalmean))[idx])/2)
  list(mass=exp(lm),logmass=lm,score=score)
}
pattern_base <- function(persons,par,gh) {
  z <- lapply(persons,pat_score,par=par,gh=gh)
  I <- matrix(0,length(par),length(par)); nll <- mass <- score <- 0
  for (i in seq_along(z)) {
    a <- z[[i]]; mu <- colSums(a$score*a$mass)
    z[[i]]$sh <- sweep(a$score,2,mu,"-"); z[[i]]$score <- NULL
    I <- I+crossprod(z[[i]]$sh*sqrt(a$mass))
    nll <- nll-a$logmass[persons[[i]]$observed]
    mass <- max(mass,abs(sum(a$mass)-1)); score <- max(score,max(abs(mu)))
  }
  stopifnot(mass<=1e-8,score<=1e-8)
  list(patterns=z,I=I,nll=nll,mass=mass,score=score)
}
pattern_cross <- function(persons,base,par,gh) {
  S <- matrix(0,length(par),length(par)); Q <- numeric(length(par)); nll <- mass <- 0
  for (i in seq_along(persons)) {
    a <- base$patterns[[i]]; b <- pat_score(persons[[i]],par,gh); w <- a$mass
    st <- sweep(b$score,2,colSums(b$score*w),"-")
    diff <- a$logmass-b$logmass; diff <- diff-sum(w*diff)
    S <- S+crossprod(a$sh*w,st); Q <- Q+drop(crossprod(a$sh,w*diff))
    nll <- nll-b$logmass[persons[[i]]$observed]; mass <- max(mass,abs(sum(b$mass)-1))
  }
  stopifnot(mass<=1e-8); list(S=S,Q=Q,nll=nll,mass=mass)
}
rstar_adjust <- function(I,S,Q,J,H,r) {
  stopifnot(abs(r)>1e-6,all(is.finite(c(I,S,Q,J,H))))
  ld <- function(x) {d<-determinant(x); stopifnot(d$sign!=0); as.numeric(d$modulus)}
  stopifnot(min(eigen(J,symmetric=TRUE,only.values=TRUE)$values)>0,
    min(eigen(H,symmetric=TRUE,only.values=TRUE)$values)>0)
  lq <- ld(cbind(S[,-ncol(S),drop=FALSE],Q))-ld(I)+(ld(J)-ld(H))/2
  # A second elimination check also verifies the sign, rather than assigning it.
  signed_q <- tail(solve(S,Q),1)*exp(ld(S)-ld(I)+(ld(J)-ld(H))/2)
  stopifnot(signed_q/r>0,abs(log(abs(signed_q))-lq)<1e-8)
  list(r=r,q=signed_q,rstar=r+(lq-log(abs(r)))/r)
}
rstar_center <- function(I,J,B,Jdot) {
  # delta is log variance minus its MLE; v is the nuisance-profile tangent.
  eta <- seq_len(nrow(J)-1L); H <- J[eta,eta,drop=FALSE]
  v <- c(-solve(H,J[eta,nrow(J)]),1)
  h <- drop(crossprod(v,J%*%v)); t <- drop(crossprod(v,Jdot%*%v))
  C <- solve(I,B)
  b <- sum(diag(C))-.5*tail(C%*%v,1)-.5*sum(diag(solve(H,Jdot[eta,eta,drop=FALSE])))
  list(limit=as.numeric(-(b-t/(6*h))/sqrt(h)),b=as.numeric(b),t=t,h=h,v=v)
}
newton_refine <- function(p,fn,gr,max_steps=4L) {
  original <- p; path <- list()
  for (i in seq_len(max_steps)) {
    g <- gr(p)
    if (max(abs(g))<=1e-8) break
    H <- optimHess(p,fn,gr,control=list(ndeps=rep(1e-4,length(p))))
    stopifnot(min(eigen(H,symmetric=TRUE,only.values=TRUE)$values)>0)
    step <- solve(H,g); before <- fn(p); accepted <- FALSE
    for (scale in c(1,.5,.25,.125)) {
      trial <- p-scale*step; gt <- gr(trial)
      if (fn(trial)<=before+128*.Machine$double.eps*max(1,abs(before)) &&
          max(abs(gt))<max(abs(g))) {p <- trial; accepted <- TRUE; break}
    }
    path[[i]] <- list(gradient=max(abs(g)),step=step,accepted=accepted)
    if (!accepted) break
  }
  list(par=p,gradient=max(abs(gr(p))),movement=max(abs(p-original)),path=path)
}
