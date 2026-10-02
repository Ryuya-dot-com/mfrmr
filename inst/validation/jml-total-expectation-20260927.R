# Research-only exact expectation using owner score totals and conditional counts.
# Two raters/criteria, three categories, shared step/slope owner, whole-predictor GPCM.
# No full response-pattern enumeration and no probability truncation.
make_jml_total_problem <- function(owner, exposure, observed_counts, max_states=5000L) {
  if(length(owner)!=1L || !owner %in% c('Rater','Criterion') || length(exposure)!=4L ||
     any(!is.finite(exposure)) || any(exposure<0 | exposure!=floor(exposure)) ||
     sum(exposure)<2L || length(observed_counts)!=4L || length(max_states)!=1L ||
     !is.finite(max_states) || max_states<1) stop('Invalid owner, exposure or state limit.')
  N <- nrow(observed_counts[[1]])
  if(is.null(N) || N<1L || any(!vapply(seq_len(4L),function(j) {
    x <- observed_counts[[j]]
    is.matrix(x) && identical(dim(x),c(N,3L)) && all(is.finite(x)) &&
      all(x>=0 & x==floor(x)) && all(rowSums(x)==exposure[j])
  },logical(1)))) stop('Observed category counts must match the assigned exposure.')
  cells <- expand.grid(Rater=1:2,Criterion=1:2)
  own <- cells[[owner]]
  sr <- c(1,-1)[cells$Rater]; sc <- c(1,-1)[cells$Criterion]; sa <- c(1,-1)[own]
  max_total <- vapply(1:2,function(g) 2*sum(exposure[own==g]),numeric(1))
  if(prod(max_total+1)>max_states) stop('Owner-total space exceeds max_states.')
  totals <- as.matrix(expand.grid(first=0:max_total[1],second=0:max_total[2]))
  G <- nrow(totals)
  extreme <- rowSums(totals)==0 | rowSums(totals)==sum(max_total)
  observed_totals <- matrix(vapply(1:2,function(g) Reduce(`+`,lapply(which(own==g),
    function(j) drop(observed_counts[[j]]%*%(0:2)))),numeric(N)),nrow=N,ncol=2L)
  group <- 1L+observed_totals[,1]+(max_total[1]+1)*observed_totals[,2]
  parameter <- c('Rater','Criterion','Step1','Step2','LogSlope')

  # Polynomial convolution carries both score mass and mass-weighted cell counts.
  # Conditioning on an owner's total cancels its common exp(a*theta*total) tilt.
  conditional <- function(beta) {
    a <- exp(sa*beta[5]); offset <- -sr*beta[1]-sc*beta[2]
    lapply(1:2,function(g) {
      probability <- 1; moment <- matrix(0,1,12)
      for(j in which(own==g)) for(repeat_id in seq_len(exposure[j])) {
        z <- a[j]*(offset[j]*(0:2)-c(0,beta[2+g],0))
        w <- exp(z-max(z)); w <- w/sum(w)
        M <- length(probability)
        next_p <- numeric(M+2L); next_m <- matrix(0,M+2L,12L)
        for(category in 0:2) {
          ii <- seq_len(M)+category
          next_p[ii] <- next_p[ii]+w[category+1]*probability
          contribution <- moment
          col <- 3L*(j-1L)+category+1L
          contribution[,col] <- contribution[,col]+probability
          next_m[ii,] <- next_m[ii,,drop=FALSE]+w[category+1]*contribution
        }
        probability <- next_p; moment <- next_m
      }
      if(any(!is.finite(probability)) || any(probability<=0))
        stop('Numerical underflow in owner-total masses; no silent state removal.')
      list(probability=probability,counts=moment/probability)
    })
  }

  evaluate <- function(beta, order=1L, block_size=16L) {
    if(length(beta)!=5L || any(!is.finite(beta)) || length(order)!=1L ||
       !is.finite(order) || order<0 || order!=floor(order) || length(block_size)!=1L ||
       !is.finite(block_size) || block_size<1 || block_size!=floor(block_size))
      stop('Invalid coordinates or adjustment controls.')
    a <- exp(sa*beta[5]); ag <- exp(c(1,-1)*beta[5])
    offset <- -sr*beta[1]-sc*beta[2]
    if(any(!is.finite(a)) || any(a==0)) stop('Nonfinite slope.')
    table <- conditional(beta)
    expected_score <- function(theta) {
      mean <- numeric(length(theta))
      for(j in which(exposure>0)) {
        z <- a[j]*(outer(theta+offset[j],0:2)-
          matrix(c(0,beta[2+own[j]],0),length(theta),3,byrow=TRUE))
        z <- z-apply(z,1,max); p <- exp(z)/rowSums(exp(z))
        mu <- drop(p%*%(0:2))
        mean <- mean+exposure[j]*a[j]*mu
      }
      mean
    }
    # Bracketed vector bisection matches the scalar profile equation. A fixed
    # tight theta tolerance avoids noisy stopping based only on a small slope.
    ix <- which(!extreme); target <- drop(totals[ix,,drop=FALSE]%*%ag)
    bound <- 1
    while(any(expected_score(-bound)>=target) || any(expected_score(bound)<=target)) {
      bound <- 2*bound
      if(bound>1e6) stop('Unresolved finite Person root.')
    }
    lo <- rep(-bound,length(ix)); hi <- rep(bound,length(ix))
    for(iteration in seq_len(100L)) {
      mid <- (lo+hi)/2
      score <- expected_score(mid)-target
      lo[score<0] <- mid[score<0]; hi[score>=0] <- mid[score>=0]
      if(max(hi-lo)<1e-12) break
    }
    if(max(hi-lo)>=1e-12) stop('Profile bisection failed theta tolerance.')
    theta <- numeric(G); theta[ix] <- (lo+hi)/2
    root_residual <- max(abs(expected_score(theta[ix])-target))
    # Raw negative profile gradient is affine in the observed category counts.
    raw <- function(counts,theta,extreme_rows) {
      n <- length(theta); U <- matrix(0,n,5); q <- numeric(n)
      for(j in 1:4) {
        z <- a[j]*(outer(theta+offset[j],0:2)-
          matrix(c(0,beta[2+own[j]],0),n,3,byrow=TRUE))
        z0 <- z-apply(z,1,max); logp <- z0-log(rowSums(exp(z0)))
        residual <- exposure[j]*exp(logp)-counts[[j]]
        score <- drop(residual%*%(0:2))
        q <- q-rowSums(counts[[j]]*logp)
        U[,1] <- U[,1]-sr[j]*a[j]*score
        U[,2] <- U[,2]-sc[j]*a[j]*score
        U[,2+own[j]] <- U[,2+own[j]]-a[j]*residual[,2]
        U[,5] <- U[,5]+sa[j]*rowSums(residual*z)
      }
      U[extreme_rows,] <- 0; q[extreme_rows] <- 0
      colnames(U) <- parameter
      list(value=U,q=q)
    }
    expected_counts <- lapply(1:4,function(j)
      table[[own[j]]]$counts[totals[,own[j]]+1,3*(j-1)+(1:3),drop=FALSE])
    raw_group <- raw(expected_counts,theta,extreme)$value
    actual <- raw(observed_counts,theta[group],extreme[group])
    # T sends a function of totals to its plug-in generating expectation.
    apply_transition <- function(values) {
      answer <- matrix(0,G,ncol(values))
      for(begin in seq.int(1L,length(ix),by=block_size)) {
        ii <- ix[begin:min(length(ix),begin+block_size-1L)]
        marginal <- lapply(1:2,function(g) {
          z <- outer(0:max_total[g],ag[g]*theta[ii])+log(table[[g]]$probability)
          z <- sweep(z,2,apply(z,2,max))
          p <- exp(z); sweep(p,2,colSums(p),'/')
        })
        probability <- marginal[[1]][totals[,1]+1,,drop=FALSE]*
          marginal[[2]][totals[,2]+1,,drop=FALSE]
        if(max(abs(colSums(probability)-1))>1e-10) stop('Total-state mass not normalized.')
        answer[ii,] <- crossprod(probability,values)
      }
      # Extreme states are absorbing; both raw and adjusted values there are zero.
      answer
    }
    adjustment <- matrix(0,G,5)
    for(k in seq_len(order)) adjustment <- adjustment+apply_transition(raw_group-adjustment)
    actual$value <- actual$value-adjustment[group,,drop=FALSE]
    total_theta <- theta
    total_theta[rowSums(totals)==0] <- -Inf
    total_theta[rowSums(totals)==sum(max_total)] <- Inf
    list(value=actual$value,q=actual$q,theta=theta[group],root_residual=root_residual,
      total_theta=total_theta,
      conditional_raw=raw_group,adjustment=adjustment,total_states=G,
      error_bound=rep(0,5),max_omitted_mass=0)
  }
  list(n=N,exposure=exposure,counts=observed_counts,total_states=G,totals=totals,
    extreme=extreme[group],group=group,conditional=conditional,
    scores=function(beta,order=1L,omit_mass=0,block_size=16L) {
      if(length(omit_mass)!=1L || !is.finite(omit_mass) || omit_mass!=0)
        stop('Total-state calculation is exact; probability pruning is not implemented.')
      evaluate(beta,order,block_size)
    }, evaluate=function(beta) {
      z <- evaluate(beta,0L)
      list(q=z$q,gradient=z$value,theta=z$theta,root_residual=z$root_residual)
    })
}
