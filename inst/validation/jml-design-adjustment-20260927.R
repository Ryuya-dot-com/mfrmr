# Research-only design-aware GPCM score adjustments. Not a public fit/CI API.
# Scope: two fixed raters, two criteria, three categories, shared slope/step owner.
# Cells follow expand.grid(Rater=1:2, Criterion=1:2); zero exposure is unassigned.
# The earlier exact prototype is frozen; this extension must reproduce it.
source('inst/validation/jml-profile-bias-sample-20260927.R')

make_jml_roster_problem <- function(owner, exposure, max_patterns = 50000L) {
  if (!owner %in% c('Rater', 'Criterion') || length(exposure) != 4L ||
      any(!is.finite(exposure)) || any(exposure < 0 | exposure != floor(exposure)) ||
      sum(exposure) < 2L) stop('Invalid owner or four-cell assigned exposure.')
  sizes <- (exposure + 1)*(exposure + 2)/2
  if (sum(log(sizes)) > log(max_patterns))
    stop('Exact reference space exceeds max_patterns; no silent approximation.')
  cells <- expand.grid(Rater = 1:2, Criterion = 1:2)
  own <- cells[[owner]]
  sign_r <- c(1, -1)[cells$Rater]; sign_c <- c(1, -1)[cells$Criterion]
  sign_a <- c(1, -1)[own]
  truth <- c(Rater = .3, Criterion = -.4, Step1 = -.6, Step2 = -.9, LogSlope = .25)
  possible <- lapply(exposure, function(m) {
    x <- expand.grid(n0 = 0:m, n1 = 0:m)
    x <- x[rowSums(x) <= m, , drop = FALSE]
    cbind(as.matrix(x), n2 = m - rowSums(x))
  })
  patterns <- as.matrix(expand.grid(lapply(possible, function(x) seq_len(nrow(x)))))
  counts <- lapply(1:4, function(j) possible[[j]][patterns[, j], , drop = FALSE])
  n <- nrow(patterns)
  totals <- vapply(counts, function(x) x[, 2] + 2*x[, 3], numeric(n))
  owner_totals <- sapply(1:2, function(j) rowSums(totals[, own == j, drop = FALSE]))
  keys <- paste(owner_totals[, 1], owner_totals[, 2], sep = ':')
  extreme <- rowSums(totals) == 0 | rowSums(totals) == 2*sum(exposure)
  log_multiplicity <- Reduce(`+`, lapply(1:4, function(j)
    lgamma(exposure[j] + 1) - rowSums(lgamma(counts[[j]] + 1))))

  evaluate <- function(beta, theta = NULL) {
    a <- exp(sign_a * beta[5])
    offset <- -sign_r * beta[1] - sign_c * beta[2]
    step <- beta[2 + own]
    probabilities <- function(t) {
      z <- a * (outer(t + offset, 0:2) - cbind(0, step, 0))
      z <- z - apply(z, 1, max)
      exp(z) / rowSums(exp(z))
    }
    profiled <- is.null(theta)
    root_residual <- 0
    if (profiled) {
      first <- which(!duplicated(keys) & !extreme)
      roots <- vapply(first, function(i) {
        target <- sum(a * totals[i, ])
        score <- function(t) sum(exposure * a * drop(probabilities(t) %*% (0:2))) - target
        bound <- 1
        while (score(-bound) >= 0 || score(bound) <= 0) {
          bound <- 2*bound
          if (bound > 1e6) stop('Unresolved finite Person root.')
        }
        uniroot(score, c(-bound, bound), tol = 1e-12)$root
      }, numeric(1))
      theta <- roots[match(keys, keys[first])]
      theta[extreme] <- 0 # Only a placeholder; exact limiting contributions follow.
    } else theta <- rep(theta, length.out = n)
    q <- numeric(n); G <- matrix(0, n, 5); person_score <- numeric(n)
    for (j in 1:4) {
      z <- a[j] * (outer(theta + offset[j], 0:2) -
        matrix(c(0, step[j], 0), n, 3, byrow = TRUE))
      shifted <- z - apply(z, 1, max)
      logp <- shifted - log(rowSums(exp(shifted)))
      p <- exp(logp)
      residual <- exposure[j]*p - counts[[j]]
      score_residual <- drop(residual %*% (0:2))
      q <- q - rowSums(counts[[j]] * logp)
      G[, 1] <- G[, 1] - sign_r[j]*a[j]*score_residual
      G[, 2] <- G[, 2] - sign_c[j]*a[j]*score_residual
      G[, 2 + own[j]] <- G[, 2 + own[j]] - a[j]*residual[, 2]
      G[, 5] <- G[, 5] + sign_a[j]*rowSums(residual*z)
      person_score <- person_score + a[j]*score_residual
    }
    if (profiled) {
      root_residual <- max(abs(person_score[!extreme]))
      q[extreme] <- 0; G[extreme, ] <- 0
    }
    colnames(G) <- names(truth)
    list(q = q, gradient = G, root_residual = root_residual, theta = theta)
  }
  # Vectorized exact generating masses at a set of fixed abilities.
  count_matrix <- do.call(cbind, counts)
  mass <- function(beta, theta) {
    logp <- lapply(1:4, function(j) {
      a <- exp(sign_a[j] * beta[5])
      eta <- theta - sign_r[j]*beta[1] - sign_c[j]*beta[2]
      z <- a * (outer(eta, 0:2) -
        matrix(c(0, beta[2 + own[j]], 0), length(theta), 3, byrow = TRUE))
      z <- z - apply(z, 1, max)
      z - log(rowSums(exp(z)))
    })
    exp(count_matrix %*% t(do.call(cbind, logp)) + log_multiplicity)
  }
  first <- which(!duplicated(keys) & !extreme)
  group <- match(keys, keys[first])
  # U_k = (I - P_beta)^k U_0; P uses this roster and refitted Person abilities.
  # Build only a block of generating distributions at once. Probability pruning
  # is unnormalised, so omitted mass gives a direct deterministic error bound.
  scores <- function(beta, order = 1L, omit_mass = 0, block_size = 16L) {
    if (length(order) != 1L || !is.finite(order) || order < 0 || order != floor(order) ||
        length(omit_mass) != 1L || !is.finite(omit_mass) || omit_mass < 0 || omit_mass >= 1 ||
        length(block_size) != 1L || !is.finite(block_size) || block_size < 1 ||
        block_size != floor(block_size)) stop('Invalid adjustment controls.')
    prof <- evaluate(beta)
    U <- prof$gradient; bound <- numeric(ncol(U)); dropped <- 0
    for (iteration in seq_len(order)) {
      correction <- matrix(0, length(first), ncol(U))
      max_drop <- 0
      for (begin in seq.int(1L, length(first), by = block_size)) {
        ids <- begin:min(length(first), begin + block_size - 1L)
        probability <- mass(beta, prof$theta[first[ids]])
        if (max(abs(colSums(probability) - 1)) > 1e-10)
          stop('Generating mass is not normalized.')
        if (omit_mass > 0) for (j in seq_along(ids)) {
          ix <- base::order(probability[,j])
          discard <- ix[cumsum(probability[ix,j]) <= omit_mass]
          removed <- sum(probability[discard,j])
          probability[discard,j] <- 0
          max_drop <- max(max_drop, removed)
        }
        correction[ids,] <- crossprod(probability, U)
      }
      # ||(I-P)(U-Uapprox)|| <= 2 e, plus omitted mass * ||Uapprox||.
      bound <- 2*bound + max_drop*apply(abs(U), 2, max)
      U[!extreme,] <- U[!extreme,,drop=FALSE] - correction[group[!extreme],,drop=FALSE]
      dropped <- max(dropped, max_drop)
    }
    list(value = U, error_bound = bound, max_omitted_mass = dropped)
  }
  list(truth = truth, n = n, exposure = exposure, counts = counts, keys = keys,
    extreme = extreme, log_multiplicity = log_multiplicity, own = own,
    evaluate = evaluate, mass = mass, scores = scores)
}

make_jml_design_equation <- function(problems, weights, proportions, order,
                                     omit_mass = 0, block_size = 16L) {
  if (length(problems) != length(weights) || length(proportions) != length(weights) ||
      any(!is.finite(proportions) | proportions <= 0) || abs(sum(proportions)-1)>1e-10)
    stop('Invalid roster proportions.')
  for (i in seq_along(problems)) if(length(weights[[i]]) != problems[[i]]$n ||
      any(!is.finite(weights[[i]]) | weights[[i]] < 0) || abs(sum(weights[[i]])-1)>1e-10)
    stop('Invalid within-roster weights.')
  components <- function(beta) lapply(problems, function(p)
    p$scores(beta, order, omit_mass, block_size))
  mean_score <- function(beta) {
    U <- components(beta)
    Reduce(`+`, lapply(seq_along(U), function(i)
      proportions[i]*drop(crossprod(weights[[i]], U[[i]]$value))))
  }
  bound <- function(beta) Reduce(`+`, Map(function(p, z) p*z$error_bound,
    proportions, components(beta)))
  objective <- function(beta) sum(vapply(seq_along(problems), function(i)
    proportions[i]*sum(weights[[i]]*problems[[i]]$evaluate(beta)$q), numeric(1)))
  list(mean_score = mean_score, components = components, bound = bound,
       objective = objective, weights = weights, proportions = proportions)
}

jml_design_root <- function(eq, order, start) {
  # Reuse the reviewed solver/Jacobian policy without changing its frozen source.
  proxy <- list(mean_score = function(beta, weights, adjusted) eq$mean_score(beta),
    evaluate = function(beta) list(q = eq$objective(beta)))
  first <- tryCatch(jml_sample_root(proxy, 1, order > 0, start),
    error = function(e) list(reviewed=FALSE,error=conditionMessage(e)))
  attempts <- list(first=first)
  if (!first$reviewed && order>0) attempts$fallback <- tryCatch(
    jml_sample_root(proxy, 1, TRUE, start, method='Newton', global='dbldog'),
    error = function(e) list(reviewed=FALSE,error=conditionMessage(e)))
  list(fit = attempts[[length(attempts)]], attempts = attempts)
}

jml_design_covariance <- function(eq, beta, N, A, sampling) {
  sampling <- match.arg(sampling, c('fixed_rosters','random_rosters'))
  if(length(N)!=1 || !is.finite(N) || N <= length(beta)) stop('Invalid Person count.')
  U <- eq$components(beta)
  means <- lapply(seq_along(U), function(i)
    drop(crossprod(eq$weights[[i]],U[[i]]$value)))
  global <- Reduce(`+`, Map(`*`,eq$proportions,means))
  centered <- lapply(seq_along(U),function(i) sweep(U[[i]]$value,2,
    if(sampling=='fixed_rosters') means[[i]] else global))
  B <- Reduce(`+`,lapply(seq_along(U),function(i)
    eq$proportions[i]*crossprod(centered[[i]],eq$weights[[i]]*centered[[i]])))
  if (min(svd(A,nu=0,nv=0)$d)<=1e-6 ||
      qr(do.call(rbind,lapply(seq_along(U),function(i)
        sqrt(eq$proportions[i]*eq$weights[[i]])*centered[[i]])))$rank<length(beta))
    stop('Insufficient rank for design covariance.')
  inverse <- solve(A)
  list(vcov=inverse %*% B %*% t(inverse)/N, meat=B,
    means=means, global=global, centered=centered, scores=U, sampling=sampling)
}

run_jml_design_review <- function(out) {
  if(file.exists(file.path(out,'results.rds'))) stop('Refusing to overwrite evidence.')
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  checks <- c(); results <- list(); rows <- list()
  # Reproduce both owner conventions and both older complete-roster spaces.
  for(owner in c('Criterion','Rater')) for(m in 1:2) {
    old <- make_jml_exact_problem(owner,m)
    p <- make_jml_roster_problem(owner,rep(m,4))
    for(beta in list(p$truth,c(-.3,.4,-.3,-1.1,-.25))) {
      checks <- c(checks, all(vapply(1:4,function(j)
        identical(unname(p$counts[[j]]),unname(old$counts[[j]])),logical(1))))
      for(k in 0:1) checks <- c(checks,
        max(abs(p$scores(beta,k)$value-old$scores(beta,k==1)))<1e-11)
      checks <- c(checks,max(abs(p$mass(beta,c(-1,0,1))-
        old$mass(beta,c(-1,0,1))))<1e-12)
    }
  }
  refused <- try(make_jml_roster_problem('Criterion',rep(100,4)),silent=TRUE)
  checks <- c(checks,inherits(refused,'try-error'))
  design <- list(complete=list(make_jml_roster_problem('Criterion',rep(2,4))),
    sparse=list(make_jml_roster_problem('Criterion',c(2,1,0,2)),
                make_jml_roster_problem('Criterion',c(0,2,2,1))))
  starts <- list(neutral=c(0,0,-.8,-.8,0),opposing=c(-.3,.4,-.3,-1.1,-.25))
  for(d in names(design)) {
    ps <- design[[d]]; prop <- rep(1/length(ps),length(ps)); truth <- ps[[1]]$truth
    population <- lapply(ps,function(p) drop(p$mass(truth,c(-1,0,1))%*%c(.25,.5,.25)))
    # Fixed roster counts; generating ability is not passed to any sample fit.
    set.seed(if(d=='complete') 271901L else 271902L)
    ids <- lapply(seq_along(ps),function(i) sample.int(ps[[i]]$n,400*prop[i],
      replace=TRUE,prob=population[[i]]))
    sample_weights <- lapply(seq_along(ps),function(i) tabulate(ids[[i]],ps[[i]]$n)/length(ids[[i]]))
    saveRDS(list(problems=lapply(ps,function(p) list(exposure=p$exposure,counts=p$counts)),
      ids=ids,weights=sample_weights),file.path(out,paste0(d,'-observed-patterns.rds')))
    for(target in c('population','sample')) for(k in c(0L,1L,2L,4L)) {
      weights <- if(target=='population') population else sample_weights
      eq <- make_jml_design_equation(ps,weights,prop,k)
      attempts <- lapply(starts,function(start) jml_design_root(eq,k,start))
      fits <- lapply(attempts,`[[`,'fit')
      ok <- all(vapply(fits,`[[`,logical(1),'reviewed'))
      spread <- if(ok) max(abs(fits[[1]]$beta-fits[[2]]$beta)) else NA_real_
      ok <- ok && spread<1e-6
      id <- paste(d,target,k,sep='-')
      row <- data.frame(Design=d,Target=target,Order=k,Reviewed=ok,StartSpread=spread,
        LogSlope=NA_real_,Displacement=NA_real_,LogSlopeSE=NA_real_,
        MinSingular=NA_real_,Condition=NA_real_,ScoreRMS=NA_real_,
        NormalizedMinSingular=NA_real_,MeanScoreAtTruth=max(abs(eq$mean_score(truth))))
      record <- list(attempts=attempts,weights=weights,proportions=prop)
      if(ok) {
        fit <- fits[[1]]
        fixed <- jml_design_covariance(eq,fit$beta,400,fit$A,'fixed_rosters')
        random <- jml_design_covariance(eq,fit$beta,400,fit$A,'random_rosters')
        row$LogSlope <- fit$beta[5]; row$Displacement <- fit$beta[5]-truth[5]
        row$LogSlopeSE <- sqrt(fixed$vcov[5,5])
        s <- svd(fit$A,nu=0,nv=0)$d
        row$MinSingular <- min(s); row$Condition <- max(s)/min(s)
        row$ScoreRMS <- sqrt(sum(diag(fixed$meat)))
        row$NormalizedMinSingular <- min(s)/row$ScoreRMS
        record$fixed <- fixed; record$random <- random
        between <- Reduce(`+`,lapply(seq_along(ps),function(i)
          prop[i]*tcrossprod(fixed$means[[i]]-fixed$global)))
        checks <- c(checks,max(abs(random$meat-fixed$meat-between))<1e-10)
        if(target=='sample') {
          expanded <- do.call(rbind,lapply(seq_along(ps),function(i)
            fixed$centered[[i]][ids[[i]],,drop=FALSE]))
          influence <- -t(solve(fit$A,t(expanded)))
          checks <- c(checks,max(abs(crossprod(influence)/400^2-fixed$vcov))<1e-10)
        }
        for(i in seq_along(ps)) checks <- c(checks,
          all(fixed$scores[[i]]$value[ps[[i]]$extreme,]==0))
      }
      record$summary <- row; results[[id]] <- record; rows[[id]] <- row
      saveRDS(record,file.path(out,paste0(id,'.rds')))
      print(row,row.names=FALSE); flush.console()
    }
  }
  # Counterexample: two isolated single-cell rosters cannot identify all five
  # structural coordinates. Connectivity in pooled data is not a rank guarantee.
  isolated <- list(make_jml_roster_problem('Criterion',c(2,0,0,0)),
                   make_jml_roster_problem('Criterion',c(0,0,0,2)))
  w <- lapply(isolated,function(p) drop(p$mass(p$truth,c(-1,0,1))%*%c(.25,.5,.25)))
  eq <- make_jml_design_equation(isolated,w,c(.5,.5),1L)
  A <- jml_sample_jacobian(eq$mean_score,isolated[[1]]$truth,5e-5)
  refused <- try(jml_design_covariance(eq,isolated[[1]]$truth,400,A,'fixed_rosters'),silent=TRUE)
  checks <- c(checks,inherits(refused,'try-error'))
  results$isolated <- list(A=A,covariance_refusal=as.character(refused))
  saveRDS(results,file.path(out,'results.rds'))
  write.csv(do.call(rbind,rows),file.path(out,'summary.csv'),row.names=FALSE)
  writeLines(capture.output(sessionInfo()),file.path(out,'sessionInfo.txt'))
  saveRDS(checks,file.path(out,'checks.rds'))
  stopifnot(all(checks))
  invisible(results)
}
if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE)
  run_jml_design_review(if(length(args)) args[[1]] else
    'validation-results/jml-design-adjustment-20260927')
}
