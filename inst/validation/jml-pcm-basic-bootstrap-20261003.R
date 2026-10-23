# Research reference, not a public CI API or a coverage study.
# Run the bounded engineering check from the package root with:
# Rscript inst/validation/jml-pcm-basic-bootstrap-check-20261003.R OUTPUT_DIRECTORY
jml_pcm_bootstrap_setup <- function() {
  pkgload::load_all('.', quiet=TRUE, compile=FALSE)
  for (name in c('mfrm-wide-map-mml-stages-20261001',
                'jml-public-profile-bridge-20261002',
                'jml-pcm-profile-certificate-20261003'))
    source(paste0('inst/validation/', name, '.R'))
}

jml_pcm_bootstrap_policy <- function() list(
  version='extended-profile-v2',
  optimizer=list(eval.max=400L, iter.max=200L, rel.tol=1e-12, x.tol=1e-12),
  curvature_distance_multiplier=1e-4, quantile_type=1L,
  extremes='Exact zero profile contribution; signed infinite ability; endpoint point-mass generation; all rows retained',
  failures='Keep every planned attempt; endpoints require every refit to pass',
  generator='Independent categorical responses at fitted fixed abilities; original rows retained',
  interpretation='Research basic quantiles; neither public estimator identity nor coverage qualified')

jml_pcm_bootstrap_context <- function(fit, independent_blocks) {
  if (!isTRUE(independent_blocks)) stop('Declare conditional independence of rating events.')
  if (fit$config$model!='PCM' || length(fit$config$facet_names)!=2L || fit$config$n_cat<3L)
    stop('This reference supports two-facet PCM with at least three declared categories.')
  ctx <- jml_bridge_context(fit)
  d <- fit$prep$data; facets <- fit$config$facet_names
  counts <- table(d[c('Person', facets)])
  if (!length(counts) || any(counts<1L) || length(unique(as.vector(counts)))!=1L)
    stop('The complete common block must have the same positive repetition count in every Person-cell.')
  ctx$blocks <- as.integer(counts[1]); ctx
}

jml_pcm_bootstrap_recession <- function(ctx, active) {
  if (!length(active)) return(list(status='no_structural_information'))
  rows <- unlist(ctx$groups[active],use.names=FALSE)
  person <- rep(seq_along(active),lengths(ctx$groups[active]))
  rr <- rep(rows,ctx$K); kk <- rep(0:(ctx$K-1L),each=length(rows))
  pp <- rep(person,ctx$K); keep <- ctx$y[rr]!=kk
  rr <- rr[keep]; kk <- kk[keep]; pp <- pp[keep]; yy <- ctx$y[rr]
  D <- t(vapply(seq_along(rr),function(i)
    ctx$lin[[yy[i]+1L]][rr[i],]-ctx$lin[[kk[i]+1L]][rr[i],],numeric(length(ctx$beta))))
  A <- cbind(Matrix::sparseMatrix(i=seq_along(rr),j=pp,x=yy-kk,
    dims=c(length(rr),length(active))),Matrix::Matrix(D,sparse=TRUE))
  # PCM centered contrast entries are integers. A positive integer witness
  # proves recession without declaring a floating LP tolerance to be exact.
  stopifnot(all(A@x==round(A@x)))
  rank <- as.integer(Matrix::rankMatrix(A,method='qr'))
  if (rank<ncol(A)) return(list(status='design_not_identified',rank=rank,dimension=ncol(A)))
  base <- mfrmr:::mfrmr_jml_recession_lp_base(A)
  objective <- as.numeric(Matrix::colSums(A))
  lp <- mfrmr:::mfrmr_jml_recession_run_lp(base,c(objective,-objective),timeout=0L)
  if (lp$status!=0L) return(list(status='recession_check_unresolved',solver_status=lp$status))
  if (lp$objval<=1e-7) return(list(status='no_recession_detected',objective=lp$objval,rank=rank))
  p <- ncol(A); direction <- lp$solution[seq_len(p)]-lp$solution[p+seq_len(p)]
  for (denominator in c(1:32,60L,120L,360L,720L)) {
    witness <- round(denominator*direction)
    margins <- as.numeric(A%*%witness)
    if (all(margins>=0) && any(margins>0) && any(tail(witness,length(ctx$beta))!=0)) {
      stopifnot(max(Matrix::rowSums(abs(A)))*max(abs(witness))<2^52)
      return(list(status='structural_recession',direction=witness,active=active,
        minimum_margin=min(margins),strict_rows=sum(margins>0),contrast=A))
    }
  }
  list(status='recession_check_unresolved',objective=lp$objval,direction=direction)
}

jml_pcm_bootstrap_refit <- function(ctx, start, policy) {
  direction <- vapply(ctx$groups,function(ix)
    if(all(ctx$y[ix]==0L))-1L else if(all(ctx$y[ix]==ctx$K-1L))1L else 0L,1L)
  extremes <- direction!=0L
  out <- list(available=FALSE, reason='', extremes=sum(extremes),
    active_persons=sum(!extremes),extreme_direction=direction,beta=NULL,
    finite_joint_maximum=if(any(extremes))FALSE else NA,
    threshold=policy$curvature_distance_multiplier/(ctx$np*ctx$blocks)^.25,
    curvature_distance=NA_real_, certificate=NULL, optimizer=NULL)
  existence <- wide_mml_capture(function()jml_pcm_bootstrap_recession(ctx,which(!extremes)))
  out$existence <- existence
  if (nzchar(existence$error)) {out$reason <- paste('recession_check_error:',existence$error); return(out)}
  if (existence$value$status!='no_recession_detected') {
    out$reason <- existence$value$status; return(out)
  }
  cache_beta <- cache_value <- NULL
  evaluate <- function(beta) {
    if (!identical(beta, cache_beta)) {
      cache_value <<- jml_bridge_profile(ctx, beta); cache_beta <<- beta
    }
    cache_value
  }
  captured <- wide_mml_capture(function() {
    opt <- nlminb(start, function(b)evaluate(b)$value,
      function(b)evaluate(b)$gradient, function(b)evaluate(b)$hessian,
      control=policy$optimizer)
    z <- evaluate(opt$par)
    certificate <- jml_pcm_profile_certificate(ctx, z)
    distance <- if (isTRUE(certificate$available))
      certificate$summary$StructuralRadius *
        sqrt(max(eigen(z$hessian, symmetric=TRUE, only.values=TRUE)$values)) else Inf
    list(beta=opt$par, profile=z, certificate=certificate, optimizer=opt,
      curvature_distance=distance)
  })
  out$elapsed <- captured$elapsed; out$warnings <- captured$warnings
  if (nzchar(captured$error)) {out$reason <- paste('refit_error:', captured$error); return(out)}
  for (name in names(captured$value)) out[[name]] <- captured$value[[name]]
  theta <- out$profile$theta
  out$available <- all(is.finite(out$beta)) && all(is.finite(theta[!extremes])) &&
    all(theta[extremes]==direction[extremes]*Inf) &&
    isTRUE(out$certificate$available) && is.finite(out$curvature_distance) &&
    out$curvature_distance <= out$threshold
  if(out$available) out$finite_joint_maximum <- !any(extremes)
  if (!out$available) out$reason <- if (!isTRUE(out$certificate$available))
    paste('root_bound:', out$certificate$reason) else 'numerical_distance_exceeds_budget'
  out
}

jml_pcm_bootstrap_probabilities <- function(ctx, beta, theta) {
  stopifnot(length(beta)==length(ctx$beta), length(theta)==ctx$np,
    all(is.finite(beta)), !anyNA(theta), ncol(ctx$slope)==0L)
  person <- integer(length(ctx$y))
  probability <- matrix(0,length(ctx$y),ctx$K)
  for (i in seq_along(ctx$groups)) {
    rows <- ctx$groups[[i]]; person[rows] <- i
    if(is.infinite(theta[i])) {
      endpoint <- if(theta[i]<0)0L else ctx$K-1L
      stopifnot(all(ctx$y[rows]==endpoint))
      probability[rows,endpoint+1L] <- 1
    }
  }
  finite <- which(is.finite(theta[person]))
  if(length(finite)) {
    logits <- outer(theta[person[finite]], 0:(ctx$K-1L)) +
      vapply(ctx$lin, function(x)drop(x[finite,,drop=FALSE]%*%beta), numeric(length(finite)))
    p <- exp(logits-apply(logits,1L,max)); p <- p/rowSums(p)
    stopifnot(all(p>0)); probability[finite,] <- p
  }
  stopifnot(all(is.finite(probability)), all(probability>=0),
    max(abs(rowSums(probability)-1))<1e-12)
  probability
}

jml_pcm_bootstrap_draw <- function(probability, seed) {
  mfrmr:::with_preserved_rng_seed(seed, {
    cumulative <- t(apply(probability, 1L, cumsum)); cumulative[,ncol(cumulative)] <- 1
    as.integer(rowSums(runif(nrow(probability)) >= cumulative))
  })
}

jml_pcm_bootstrap_intervals <- function(original, attempts, contrasts, level) {
  point <- drop(contrasts%*%original$beta)
  draws <- matrix(NA_real_, length(attempts), length(point),
    dimnames=list(NULL, rownames(contrasts)))
  ok <- vapply(attempts, function(x)isTRUE(x$available), TRUE)
  for (i in which(ok)) draws[i,] <- drop(contrasts%*%attempts[[i]]$beta)
  result <- data.frame(Target=rownames(contrasts), Estimate=point, Level=level,
    Lower=NA_real_, Upper=NA_real_, ComputationallyAvailable=all(ok),
    InferenceQualified=FALSE, Reason=if(all(ok))'Quantile precision and sampling performance unqualified' else
      'At least one planned refit unavailable; successful-only endpoints refused', row.names=NULL)
  mc <- NULL
  if (all(ok)) {
    delta <- sweep(draws,2L,point); probs <- c((1-level)/2,(1+level)/2)
    q <- apply(delta,2L,quantile,probs=probs,type=1L,names=FALSE)
    result$Lower <- point-q[2,]; result$Upper <- point-q[1,]
    # Conditional 95% order-statistic bounds for the two ideal bootstrap
    # quantiles. Infinite bounds expose inadequate inner replication counts.
    B <- nrow(draws)
    mc <- do.call(rbind,lapply(seq_along(point),function(j)
      do.call(rbind,lapply(probs,function(p) {
        lo <- qbinom(.025,B,p); hi <- qbinom(.975,B,p)+1L; sorted <- sort(delta[,j])
        data.frame(Target=rownames(contrasts)[j], Probability=p, MCLevel=.95,
          LowerOrder=lo, UpperOrder=hi,
          QuantileLower=if(lo<1L)-Inf else sorted[lo],
          QuantileUpper=if(hi>B)Inf else sorted[hi])
      }))))
  }
  list(intervals=result, draws=draws, quantile_mc=mc)
}

jml_pcm_basic_bootstrap <- function(fit, contrasts, reps, seed, out,
                                    independent_blocks, level=.95) {
  stopifnot(length(reps)==1L, is.finite(reps), reps>=2L, reps==floor(reps),
    length(seed)==1L, is.finite(seed), seed>=0, seed<.Machine$integer.max, seed==floor(seed),
    length(level)==1L, is.finite(level), level>0, level<1)
  ctx <- jml_pcm_bootstrap_context(fit, independent_blocks)
  stopifnot(is.matrix(contrasts), is.numeric(contrasts), nrow(contrasts)>0L,
    ncol(contrasts)==length(ctx$beta), all(is.finite(contrasts)),
    all(rowSums(abs(contrasts))>0), !is.null(rownames(contrasts)),
    all(nzchar(rownames(contrasts))), !anyDuplicated(rownames(contrasts)))
  policy <- jml_pcm_bootstrap_policy()
  scripts <- paste0('inst/validation/',c('jml-pcm-basic-bootstrap-20261003',
    'jml-public-profile-bridge-20261002','jml-pcm-profile-certificate-20261003'),'.R')
  binding <- list(input=wide_mml_hash(fit), contrasts=contrasts, reps=reps, seed=seed,
    level=level, independent_blocks=independent_blocks, policy=policy,
    source=tools::md5sum(scripts), runtime=wide_mml_runtime(), rng=RNGkind())
  dir.create(out, recursive=TRUE, showWarnings=FALSE)
  wide_mml_phase(file.path(out,'manifest.rds'),'ordinary-pcm-basic-reference-v2',function()binding) -> frozen
  stopifnot(identical(frozen,binding))
  key <- wide_mml_hash(binding)
  original <- wide_mml_phase(file.path(out,'original.rds'),key,
    function()jml_pcm_bootstrap_refit(ctx,ctx$beta,policy))
  if (!original$available) return(wide_mml_phase(file.path(out,'result.rds'),key,function()
    list(original=original, trials=data.frame(), planned=reps, generated=0L,
      available=FALSE, reason=paste('Original reference unavailable:',original$reason),
      inference_qualified=FALSE, binding=binding)))
  generation <- wide_mml_capture(function()
    jml_pcm_bootstrap_probabilities(ctx,original$beta,original$profile$theta))
  if(nzchar(generation$error)) return(wide_mml_phase(file.path(out,'result.rds'),key,function()
    list(original=original,trials=data.frame(),planned=reps,generated=0L,
      available=FALSE,reason=paste('Source generation unavailable:',generation$error),
      inference_qualified=FALSE,binding=binding)))
  probability <- generation$value
  seeds <- mfrmr:::with_preserved_rng_seed(seed,sample.int(.Machine$integer.max,reps))
  attempts <- vector('list',reps)
  for (i in seq_len(reps)) {
    attempts[[i]] <- wide_mml_phase(file.path(out,sprintf('draw-%04d.rds',i)),
      list(manifest=key, replicate=i, seed=seeds[i]),function() {
        generated <- ctx; generated$y <- jml_pcm_bootstrap_draw(probability,seeds[i])
        result <- jml_pcm_bootstrap_refit(generated,original$beta,policy)
        result$response <- generated$y
        result$empty_categories <- sum(tabulate(generated$y+1L,ctx$K)==0L)
        result
      })
    cat('PCM bootstrap',i,'of',reps,if(attempts[[i]]$available)'accepted' else attempts[[i]]$reason,'\n')
    flush.console()
  }
  wide_mml_phase(file.path(out,'result.rds'),key,function() {
    trials <- do.call(rbind,lapply(seq_len(reps),function(i) {
      a <- attempts[[i]]
      data.frame(Replicate=i,Seed=seeds[i],Available=a$available,Reason=a$reason,
        ExtremePersons=a$extremes,EmptyCategories=a$empty_categories,
        ActivePersons=a$active_persons,FiniteJointMaximum=a$finite_joint_maximum,
        OptimizerCode=if(is.null(a$optimizer))NA_integer_ else a$optimizer$convergence,
        CurvatureDistance=a$curvature_distance,Threshold=a$threshold)
    }))
    interval <- jml_pcm_bootstrap_intervals(original,attempts,contrasts,level)
    c(list(original=original,public_beta=ctx$beta,
      public_point_shift=original$beta-ctx$beta, trials=trials, planned=reps, generated=reps,
      available=all(trials$Available), inference_qualified=FALSE,
      binding=binding, design=list(N=ctx$np,L=ctx$blocks,
        levels=lengths(fit$prep$levels[fit$config$facet_names]),categories=ctx$K)),interval)
  })
}
