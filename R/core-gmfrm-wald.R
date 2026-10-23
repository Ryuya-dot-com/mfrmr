# Louis observed information from the literal reference model. The complete
# score covariance is subtracted, including all location/step/log-slope blocks.
# Vectorizing nodes avoids another pair of gradient evaluations per coordinate.
mfrm_gmfrm_louis <- function(specification, par, order=32L, tail_drop=64) {
  if (!order %in% c(32L,64L) || !tail_drop %in% c(64,96)) stop("Unsupported information reference rule.")
  model <- mfrm_gmfrm_reference_design(specification,par)
  rule <- mfrm_gmfrm_reference_rule(order); p <- length(par)
  b <- seq_len(model$nb); g <- model$nb+seq_len(model$ng)
  H <- matrix(0,p,p); score <- numeric(p); nll <- 0
  for (rows in model$groups) {
    person <- mfrm_gmfrm_reference_person(model,rows)
    cuts <- person$cuts
    if (tail_drop>64) cuts <- sort(c(cuts,vapply(c(-1,1),function(side)
      stats::uniroot(function(t) person$kernel(t)$logjoint-person$peak+tail_drop,
        sort(c(person$mode,person$mode+side*(sqrt(2*tail_drop)+1))),tol=1e-14)$root,0)))
    lower <- head(cuts,-1L); width <- diff(cuts)
    theta <- as.vector(outer(rule$nodes,width)+rep(lower,each=length(rule$nodes)))
    w <- as.vector(outer(rule$weights,width))
    kernel <- person$kernel(theta,TRUE)
    w <- w*exp(kernel$logjoint-person$peak); mass <- sum(w); w <- w/mass
    if (!is.finite(mass) || mass<=0 || any(!is.finite(w))) stop("Invalid information normalizer.")
    nq <- length(theta); complete <- matrix(0,p,p)
    for (j in rows) {
      a <- model$a[j]; z <- model$Z[j,]; y <- model$score[j]
      logits <- a*(outer(theta,0:model$K)-matrix(model$offset[j,],nq,model$K+1L,byrow=TRUE))
      logp <- logits-apply(logits,1,max); probability <- exp(logp)/rowSums(exp(logp))
      mean_derivative <- matrix(0,nq,p)
      for (k in 0:model$K) {
        d <- model$D[[k+1L]][j,]
        derivative <- cbind(matrix(-a*d,nq,length(b),byrow=TRUE),outer(logits[,k+1L],z))
        probability_k <- probability[,k+1L]
        complete <- complete+crossprod(derivative,(w*probability_k)*derivative)
        mean_derivative <- mean_derivative+probability_k*derivative
        residual <- as.numeric(y==k)-probability_k
        cross <- a*sum(w*residual)*outer(d,z)
        complete[b,g] <- complete[b,g,drop=FALSE]+cross
        complete[g,b] <- complete[g,b,drop=FALSE]+t(cross)
        complete[g,g] <- complete[g,g,drop=FALSE]-sum(w*residual*logits[,k+1L])*tcrossprod(z)
      }
      complete <- complete-crossprod(mean_derivative,w*mean_derivative)
    }
    u <- colSums(w*kernel$score)
    centered <- sweep(kernel$score,2,u,"-")
    H <- H+complete-crossprod(centered,w*centered)
    score <- score+u; nll <- nll-person$peak-log(mass)
  }
  if (any(!is.finite(c(H,score,nll)))) stop("Nonfinite Louis information reference.")
  list(information=(H+t(H))/2,gradient=-score,nll=nll,order=order,tail_drop=tail_drop)
}

# Numerical admission for a private local Wald calculation. This is separate
# from the result's public-adoption and sampling-coverage decisions.
mfrm_gmfrm_wald_information <- function(result) {
  mfrm_gmfrm_result_check(result)
  out <- list(eligible=FALSE,covariance=NULL,checks=NULL,reference=NULL,
    source_identity=result$identity,reason="No unrestricted selected local candidate.")
  a <- result$run$candidate
  if (is.null(a) || !identical(a$information_scope,"joint_unrestricted")) return(out)
  states <- setNames(result$components$State,result$components$Component)
  if (!identical(unname(states["input"]),"pass") || !identical(unname(states["category"]),"adequate") ||
      !states["estimability"] %in% c("identified","not_evaluated") ||
      !states["boundary"] %in% c("finite","not_applicable","not_evaluated")) {
    out$reason <- "Source input, category, identification or boundary conditions prevent intervals."
    return(out)
  }
  tryCatch({
    low <- mfrm_gmfrm_louis(result$run$specification,a$native_parameters,32L,64)
    high <- mfrm_gmfrm_louis(result$run$specification,a$native_parameters,64L,96)
    out$reference <- list(coarse=low,fine=high)
    info <- a$information; H <- info$hessian; V <- info$covariance; root <- chol(H)
    lowV <- chol2inv(chol(low$information)); highV <- chol2inv(chol(high$information))
    p <- length(a$native_parameters); n <- length(unique(result$run$specification$data[[result$run$specification$person]]))
    distance <- function(A,B) norm(root%*%(A-B)%*%t(root),"2")
    out$checks <- c(NLLDifference=abs(high$nll-result$reference$reference$nll),
      GradientDifference=max(abs(high$gradient-result$reference$native_gradient)),
      MeanScore=max(abs(high$gradient))/n,
      StandardizedScore=sqrt(drop(crossprod(high$gradient,V%*%high$gradient))),
      ReferenceNLLChange=abs(high$nll-low$nll),ReferenceGradientChange=max(abs(high$gradient-low$gradient)),
      ReferenceCovarianceChange=distance(highV,lowV),RetainedCovarianceChange=distance(highV,V),
      ReferenceInverseResidual=norm(high$information%*%highV-diag(p),"I"))
    out$eligible <- all(is.finite(out$checks)) && all(out$checks>=0 &
      out$checks<=c(1e-7,1e-6,1e-6,1e-4,1e-7,1e-6,.01,.01,1e-6))
    if(out$eligible) out$covariance <- V
    out$reason <- if(out$eligible) "Independent observed information supports a local numerical Wald approximation; coverage is unqualified." else
      "Independent information or integration comparisons failed; no Wald limits are available."
    out
  },error=function(e) { out$reason <- conditionMessage(e); out })
}

mfrm_gmfrm_wald <- function(result, contrasts, exponentiate=FALSE, level=.95) {
  mfrm_gmfrm_result_check(result)
  names <- result$run$parameter_names; p <- length(names)
  if (missing(contrasts)) { contrasts <- diag(p); dimnames(contrasts) <- list(names,names) }
  if (!is.matrix(contrasts) || !is.numeric(contrasts) || is.complex(contrasts) ||
      ncol(contrasts)!=p || !nrow(contrasts) || any(!is.finite(contrasts)) ||
      any(rowSums(abs(contrasts))==0) ||
      (!is.null(colnames(contrasts)) && !identical(colnames(contrasts),names)))
    stop("Supply nonzero finite native contrasts in the saved parameter order.")
  if (!is.numeric(level) || is.complex(level) || length(level)!=1L || !is.finite(level) || level<=0 || level>=1)
    stop("The confidence level must be strictly between zero and one.")
  if (!is.logical(exponentiate) || anyNA(exponentiate) || !length(exponentiate) %in% c(1L,nrow(contrasts)))
    stop("Supply one exponentiation flag or one per target.")
  exponentiate <- rep(exponentiate,length.out=nrow(contrasts))
  information <- mfrm_gmfrm_wald_information(result)
  estimate <- if(is.null(result$run$candidate)) rep(NA_real_,nrow(contrasts)) else
    drop(contrasts%*%result$run$candidate$native_parameters)
  se <- if(information$eligible) sqrt(rowSums((contrasts%*%information$covariance)*contrasts)) else
    rep(NA_real_,nrow(contrasts))
  z <- stats::qnorm((1-level)/2,lower.tail=FALSE)
  lower <- estimate-z*se; upper <- estimate+z*se; reported <- estimate
  lower[exponentiate] <- exp(lower[exponentiate]); upper[exponentiate] <- exp(upper[exponentiate])
  reported[exponentiate] <- exp(reported[exponentiate])
  available <- information$eligible & is.finite(lower) & is.finite(upper) &
    (!exponentiate | (lower>0 & upper>0))
  lower[!available] <- upper[!available] <- NA_real_
  table <- data.frame(Target=rownames(contrasts) %||% as.character(seq_len(nrow(contrasts))),
    Estimate=reported,NativeEstimate=unname(estimate),NativeSE=unname(se),Lower=unname(lower),Upper=unname(upper),
    Level=level,Scale=ifelse(exponentiate,"exp_native","native"),NumericallyAvailable=available,
    CoverageQualified=FALSE,row.names=NULL)
  list(intervals=table,information=information,contrasts=contrasts,source_identity=result$identity,
    method="experimental local Wald from full joint observed marginal information",
    notes=c("Pointwise normal limits on the native target; exponentiation transforms both endpoints, not the standard error.",
      "Numerical availability does not establish global identification, boundary absence or finite-sample coverage.",
      "These structural intervals are distinct from conditional Person posterior uncertainty. Public dispatch is unchanged."))
}
