# Private independent reference, generalized from the frozen October 11
# 32/64-point/Gauss-Kronrod validation. No working response, derivative,
# coordinate or quadrature implementation is called here.
# Golub--Welsch Legendre rule, normalized for integration on [0,1].
mfrm_gmfrm_reference_rule <- function(n) {
  b <- seq_len(n - 1L) / sqrt(4 * seq_len(n - 1L)^2 - 1)
  J <- matrix(0, n, n); J[cbind(1:(n-1L), 2:n)] <- b
  e <- eigen(J + t(J), symmetric = TRUE)
  o <- order(e$values)
  list(nodes = (e$values[o] + 1)/2, weights = e$vectors[1, o]^2)
}

# Literal native design, independent of package parameter/response decoders.
# The caller has validated the unweighted, unanchored fixed-N(0,1) specification.
mfrm_gmfrm_reference_design <- function(specification, par) {
  s <- specification; d <- s$data; owners <- s$slope_facets; K <- s$max_score
  lev <- lapply(d[c(s$person, owners)], function(x) sort(unique(as.character(x))))
  id <- Map(function(x, l) match(as.character(x), l), d[names(lev)], lev)
  ni <- length(lev[[2]]); nr <- length(lev[[3]])
  Z <- cbind(rbind(diag(ni-1L), rep(-1, ni-1L))[id[[2]], , drop=FALSE],
    diag(nr)[id[[3]], , drop=FALSE])
  ng <- ncol(Z); nb <- ng+nr*(K-1L)
  contrast <- rbind(diag(K-1L), rep(-1,K-1L))
  D <- lapply(0:K, function(k) {
    step <- matrix(0,nrow(d),nr*(K-1L))
    if(k>0L && K>1L) for(r in seq_len(nr)) {
      rows <- which(id[[3]]==r); cols <- (r-1L)*(K-1L)+seq_len(K-1L)
      step[rows,cols] <- rep(colSums(contrast[seq_len(k),,drop=FALSE]),each=length(rows))
    }
    cbind(k*Z,step)
  })
  if(!is.numeric(par) || is.complex(par) || length(par)!=nb+ng || any(!is.finite(par)))
    stop("Independent reference requires a finite native parameter vector.")
  offset <- vapply(D,function(x) drop(x%*%par[seq_len(nb)]),numeric(nrow(d)))
  a <- exp(drop(Z%*%par[nb+seq_len(ng)]))
  if(any(!is.finite(a)) || any(a<=0)) stop("Independent reference slope is outside the finite interior.")
  list(Z=Z,D=D,offset=offset,a=a,ng=ng,nb=nb,K=K,
    score=d[[s$score]],groups=split(seq_len(nrow(d)),id[[1]]),par=par)
}

mfrm_gmfrm_reference_person <- function(model, rows) {
  a <- model$a[rows]; z <- model$Z[rows, , drop = FALSE]
  off <- model$offset[rows, , drop = FALSE]; y <- model$score[rows]
  design <- lapply(model$D, function(x) x[rows, , drop = FALSE])
  nb <- model$nb; ng <- model$ng; p <- nb+ng; K <- model$K
  delta <- lapply(seq_along(rows), function(j)
    t(vapply(design, function(x) design[[y[j]+1L]][j, ] - x[j, ], numeric(nb))))
  # |complete score_j(theta)| <= c0_j + c1_j |theta|.
  c0 <- c1 <- numeric(p)
  for (j in seq_along(rows)) {
    c0[seq_len(nb)] <- c0[seq_len(nb)] + a[j]*apply(abs(delta[[j]]), 2, max)
    c0[nb+seq_len(ng)] <- c0[nb+seq_len(ng)] +
      a[j]*max(abs(off[j, y[j]+1L] - off[j, ]))*abs(z[j, ])
    c1[nb+seq_len(ng)] <- c1[nb+seq_len(ng)] +
      a[j]*max(abs(y[j] - 0:K))*abs(z[j, ])
  }
  kernel <- function(theta, scores = FALSE) {
    n <- length(theta); lj <- stats::dnorm(theta, log = TRUE); ts <- -theta
    U <- if (scores) matrix(0, n, p) else NULL
    for (j in seq_along(rows)) {
      logits <- a[j]*(outer(theta, 0:K) - matrix(off[j, ], n, K+1L, byrow = TRUE))
      high <- apply(logits,1L,max)
      lp <- logits - high; lp <- lp - log(rowSums(exp(lp)))
      pr <- exp(lp); lj <- lj + lp[, y[j]+1L]
      # Sum p_k (y-k), rather than y-E(k), retains tiny tail residuals.
      residual <- drop(pr %*% (y[j] - 0:K))
      ts <- ts + a[j]*residual
      if (scores) {
        U[, seq_len(nb)] <- U[, seq_len(nb), drop = FALSE] - a[j]*(pr %*% delta[[j]])
        log_residual <- a[j]*(theta*residual -
          drop(pr %*% (off[j, y[j]+1L] - off[j, ])))
        U[, nb+seq_len(ng)] <- U[, nb+seq_len(ng), drop = FALSE] + outer(log_residual, z[j, ])
      }
    }
    list(logjoint = lj, theta_score = ts, score = U)
  }
  left <- -1; right <- 1
  while (kernel(left)$theta_score < 0) left <- left*2
  while (kernel(right)$theta_score > 0) right <- right*2
  mode <- stats::uniroot(function(x) kernel(x)$theta_score, c(left, right), tol = 1e-14)$root
  peak <- kernel(mode)$logjoint
  drops <- c(.5, 2, 8, 32, 64)
  # Strong log concavity guarantees that sqrt(2*drop) brackets each crossing.
  bounds <- vapply(c(-1, 1), function(sign) vapply(drops, function(drop) {
    interval <- sort(c(mode, mode + sign*(sqrt(2*drop) + 1)))
    stats::uniroot(function(x) kernel(x)$logjoint - peak + drop, interval, tol = 1e-14)$root
  }, 0), numeric(length(drops)))
  lower <- bounds[length(drops), 1]; upper <- bounds[length(drops), 2]
  cuts <- c(mode, bounds)
  for (j in seq_along(rows)) for (k in seq_len(K)) for (l in 0:(k-1L)) {
    crossing <- (off[j, k+1L] - off[j, l+1L])/(k-l)
    width <- 1/(a[j]*(k-l))
    cuts <- c(cuts, crossing + c(-40, -16, -4, -1, 0, 1, 4, 16, 40)*width)
  }
  cuts <- sort(unique(c(lower, cuts[cuts > lower & cuts < upper], upper)))
  # Concavity gives f(b +/- t) <= f(b)-s*t. Integrate this envelope,
  # including |theta| <= |b|+t, to bound both normalizer and score tails.
  tail_mass <- 0; tail_score <- numeric(p)
  for (side in c(-1, 1)) {
    b <- if (side < 0) lower else upper; at <- kernel(b)
    s <- -side*at$theta_score; h <- exp(at$logjoint - peak)
    stopifnot(is.finite(s), s > 0)
    tail_mass <- tail_mass + h/s
    tail_score <- tail_score + h*((c0 + c1*abs(b))/s + c1/s^2)
  }
  list(kernel = kernel, cuts = cuts, peak = peak, mode = mode,
    tail_mass = tail_mass, tail_score = tail_score)
}

mfrm_gmfrm_reference_integral <- function(person, rule, scores) {
  lo <- head(person$cuts, -1); width <- diff(person$cuts)
  theta <- as.vector(outer(rule$nodes, width) + rep(lo, each = length(rule$nodes)))
  w <- as.vector(outer(rule$weights, width))
  value <- person$kernel(theta, scores)
  w <- w*exp(value$logjoint - person$peak)
  mass <- sum(w); stopifnot(is.finite(mass), mass > 0)
  list(mass = mass, log_marginal = person$peak + log(mass),
    score = if (scores) colSums(w*value$score)/mass else NULL)
}

mfrm_gmfrm_reference_integrate <- function(model, full = TRUE) {
  rules <- lapply(c(32L, 64L), mfrm_gmfrm_reference_rule)
  # Equal totals or equal probabilities at this parameter are insufficient:
  # derivatives also depend on the literal facet/step design. Use all person
  # kernel inputs, with exact binary keys and row-order-independent patterns.
  signature <- cbind(model$a, model$score, model$Z, model$offset,
    do.call(cbind, model$D))
  keys <- vapply(model$groups, function(rows) {
    x <- signature[rows, , drop = FALSE]
    x <- x[do.call(order, as.data.frame(x)), , drop = FALSE]
    paste(serialize(unname(x), NULL, version = 2L), collapse = "")
  }, "")
  first <- which(!duplicated(keys))
  people <- lapply(model$groups[first], function(rows) {
    p <- mfrm_gmfrm_reference_person(model, rows); high <- mfrm_gmfrm_reference_integral(p, rules[[2]], full)
    if (!full) return(list(log_marginal = high$log_marginal))
    low <- mfrm_gmfrm_reference_integral(p, rules[[1]], TRUE)
    lo <- head(p$cuts, -1); width <- diff(p$cuts)
    gk <- lapply(seq_along(lo), function(j) stats::integrate(function(t)
      width[j]*exp(p$kernel(lo[j]+width[j]*t)$logjoint - p$peak), 0, 1,
      rel.tol = 1e-10, abs.tol = 1e-12/length(lo), subdivisions = 1000L))
    stopifnot(all(vapply(gk, function(x) x$message == "OK", TRUE)))
    mass <- sum(vapply(gk, `[[`, 0, "value"))
    list(log_marginal = high$log_marginal, score = high$score,
      low_score = low$score, low_log_marginal = low$log_marginal,
      gk_log_marginal = p$peak + log(mass),
      gk_relative_error = sum(vapply(gk, `[[`, 0, "abs.error"))/mass,
      tail_log_bound = log1p(p$tail_mass/high$mass),
      tail_score_bound = (p$tail_score + abs(high$score)*p$tail_mass)/high$mass,
      mode = p$mode, segments = length(lo))
  })
  # Restore every person, including multiplicity, before aggregating errors
  # and scores. Downstream person-level reference diagnostics stay aligned.
  people <- people[match(keys, keys[first])]
  names(people) <- names(model$groups)
  nll <- -sum(vapply(people, `[[`, 0, "log_marginal"))
  if (!full) return(nll)
  score <- Reduce(`+`, lapply(people, `[[`, "score"))
  low_score <- Reduce(`+`, lapply(people, `[[`, "low_score"))
  checks <- c(NLLRuleDifference = abs(nll + sum(vapply(people, `[[`, 0, "low_log_marginal"))),
    NLLGKDifference = abs(nll + sum(vapply(people, `[[`, 0, "gk_log_marginal"))),
    ScoreRuleDifference = max(abs(score - low_score)),
    GKEstimatedRelativeError = sum(vapply(people, `[[`, 0, "gk_relative_error")),
    TailNLLBound = sum(vapply(people, `[[`, 0, "tail_log_bound")),
    TailScoreBound = max(Reduce(`+`, lapply(people, `[[`, "tail_score_bound"))))
  qualified <- all(is.finite(checks)) &&
    all(checks[1:2] <= 1e-7) && checks[3] <= 1e-6 &&
    all(checks[4:5] <= 1e-8) && checks[6] <= 1e-7
  list(nll = nll, score = score, checks = checks, qualified = unname(qualified), people = people)
}

# A finite-intercept boundary can have no finite native inverse. Its independent
# likelihood remains a comparison witness, never a native-score certificate.
mfrm_gmfrm_reference_boundary <- function(z, s, chart) {
  d <- s$data; K <- s$max_score
  id <- lapply(d[c(s$person,s$slope_facets)],function(x) match(as.character(x),sort(unique(as.character(x)))))
  ni <- max(id[[2]]); nr <- max(id[[3]]); nb <- ni-1L+nr*K
  b <- c(z[seq_len(ni-1L)],-sum(z[seq_len(ni-1L)]))
  ai <- exp(c(z[nb+seq_len(ni-1L)],-sum(z[nb+seq_len(ni-1L)])))
  r <- tail(z,nr)
  if(chart=="rater_intercepts") {
    if(any(r<0)) stop("Independent boundary reference requires nonnegative slopes.")
    q <- matrix(z[ni-1L+seq_len(nr*K)],nr,K,byrow=TRUE)
    a <- ai[id[[2]]]*r[id[[3]]]
    intercept <- -ai[id[[2]]]*(r[id[[3]]]*b[id[[2]]]+q[id[[3]],,drop=FALSE])
  } else {
    if(tail(r,1L)<0) stop("Independent boundary reference requires nonnegative variance.")
    rho <- exp(c(head(r,-1L),-sum(head(r,-1L))))
    a <- ai[id[[2]]]*rho[id[[3]]]*sqrt(tail(r,1L))
    severity <- z[ni-1L+seq_len(nr)]
    tau <- matrix(z[ni-1L+nr+seq_len(nr*(K-1L))],nr,K-1L,byrow=TRUE)
    tau <- cbind(tau,-rowSums(tau))
    intercept <- -ai[id[[2]]]*rho[id[[3]]]*(b[id[[2]]]+severity[id[[3]]]+tau[id[[3]],,drop=FALSE])
  }
  if(any(!is.finite(c(a,intercept)))) stop("Nonfinite independent boundary response law.")
  people <- lapply(split(seq_len(nrow(d)),id[[1]]),function(rows) {
    joint <- function(theta) {
      value <- stats::dnorm(theta,log=TRUE)
      score <- -theta
      for(j in rows) {
        logits <- outer(theta,0:K)*a[j]+matrix(c(0,cumsum(intercept[j,])),length(theta),K+1L,byrow=TRUE)
        high <- apply(logits,1L,max)
        lp <- logits-high; lp <- lp-log(rowSums(exp(lp)))
        value <- value+lp[,d[[s$score]][j]+1L]
        score <- score+a[j]*drop(exp(lp)%*%(d[[s$score]][j]-0:K))
      }
      list(logjoint=value,theta_score=score)
    }
    # Scale before quadrature: an absolute tolerance on a tiny unscaled
    # likelihood cannot certify its relative or log-likelihood accuracy.
    mode <- stats::uniroot(function(t) joint(t)$theta_score,c(-1,1),
      extendInt="downX",check.conv=TRUE,tol=1e-14)$root
    peak <- joint(mode)$logjoint
    at <- stats::integrate(function(t) exp(joint(mode+t)$logjoint-peak),
      -Inf,Inf,rel.tol=1e-11,abs.tol=1e-14)
    if(at$message!="OK" || !is.finite(at$value) || at$value<=0 || at$abs.error/at$value>1e-8)
      stop("Independent boundary likelihood did not meet its accuracy criterion.")
    list(log_marginal=peak+log(at$value),relative_error=at$abs.error/at$value)
  })
  error <- sum(vapply(people,`[[`,0,"relative_error"))
  if(error>1e-8) stop("Independent boundary likelihood accumulated error exceeds its criterion.")
  list(nll=-sum(vapply(people,`[[`,0,"log_marginal")),relative_error=error,
    method="mode-scaled literal boundary probabilities and base-R integration")
}

mfrm_gmfrm_reference <- function(specification, chart=c("rater_intercepts","common_scale")) {
  chart <- match.arg(chart); s <- specification
  # Input validation is shared with the caller; arithmetic and integration are independent.
  force(s)
  function(z, native_parameters) {
    if(is.null(native_parameters)) return(list(reference=mfrm_gmfrm_reference_boundary(z,s,chart)))
    ref <- mfrm_gmfrm_reference_integrate(mfrm_gmfrm_reference_design(s,native_parameters))
    list(reference=ref,native_gradient=-ref$score,
      score_error=list(rule=Reduce(`+`,lapply(ref$people,function(x) abs(x$score-x$low_score))),
        tail=Reduce(`+`,lapply(ref$people,`[[`,"tail_score_bound"))))
  }
}
