# Output-only research arithmetic. This file never generates or refits data.
# Unknown refits occupy their original ranks; no successful-only distribution.
# Completion envelopes are not qualified confidence intervals for the truth.
jml_bootstrap_order_bounds <- function(known, total, orders) {
  stopifnot(is.numeric(known), all(is.finite(known)), length(total)==1L,
    is.finite(total), total>=1L, total==floor(total), length(known)<=total,
    all(is.finite(orders)), all(orders==floor(orders)),
    all(orders>=0L), all(orders<=total+1L))
  known <- sort(known); missing <- total-length(known)
  data.frame(
    Lower=vapply(orders,function(k) {
      if(k==total+1L) Inf else if(k<=missing) -Inf else known[k-missing]
    },0.0),
    Upper=vapply(orders,function(k) {
      if(k==0L) -Inf else if(k>length(known)) Inf else known[k]
    },0.0))
}

jml_pcm_bootstrap_completion <- function(original, attempts, contrasts,
                                         level=.95, mc_level=.95) {
  stopifnot(length(level)==1L, is.finite(level), level>0, level<1,
    length(mc_level)==1L, is.finite(mc_level), mc_level>0, mc_level<1,
    is.matrix(contrasts), is.numeric(contrasts), nrow(contrasts)>0L,
    all(is.finite(contrasts)), all(rowSums(abs(contrasts))>0),
    !is.null(rownames(contrasts)), all(nzchar(rownames(contrasts))),
    !anyDuplicated(rownames(contrasts)))
  settings <- list(level=level,mc_level=mc_level,targets=rownames(contrasts))
  if(!isTRUE(original$available)) return(list(status='original_unavailable',
    reason=original$reason, intervals=data.frame(), quantiles=data.frame(),
    settings=settings,source_available=FALSE,
    source_point=rep(NA_real_,nrow(contrasts)),inference_qualified=FALSE))
  stopifnot(length(original$beta)==ncol(contrasts), all(is.finite(original$beta)),
    is.list(attempts), length(attempts)>0L)
  B <- length(attempts); point <- drop(contrasts%*%original$beta)
  ok <- vapply(attempts,function(a)isTRUE(a$available),TRUE)
  reasons <- vapply(attempts,function(a)if(is.null(a$reason))'' else a$reason,'')
  status <- ifelse(ok,'accepted',ifelse(reasons=='structural_recession',
    'structural_nonexistence',ifelse(reasons %in%
      c('no_structural_information','design_not_identified'),
      'structural_nonidentification','unresolved')))
  draws <- matrix(NA_real_,B,length(point),dimnames=list(NULL,rownames(contrasts)))
  for(i in which(ok)) {
    stopifnot(length(attempts[[i]]$beta)==ncol(contrasts),
      all(is.finite(attempts[[i]]$beta)))
    draws[i,] <- drop(contrasts%*%attempts[[i]]$beta)
  }
  stopifnot(all(is.finite(point)),all(is.finite(draws[ok,,drop=FALSE])))
  probs <- c((1-level)/2,(1+level)/2)
  # Use the same R type-1 convention as v2, including floating rank boundaries.
  orders <- as.integer(quantile(seq_len(B),probs,type=1L,names=FALSE))
  # Four one-sided errors: Bonferroni covers both tails for ONE target.
  tail_error <- (1-mc_level)/4
  mc_low <- qbinom(tail_error,B,probs)
  mc_high <- qbinom(1-tail_error,B,probs)+1L
  quantiles <- lapply(seq_along(point),function(j) {
    delta <- draws[ok,j]-point[j]
    empirical <- jml_bootstrap_order_bounds(delta,B,orders)
    lower <- jml_bootstrap_order_bounds(delta,B,mc_low)$Lower
    upper <- jml_bootstrap_order_bounds(delta,B,mc_high)$Upper
    data.frame(Target=rownames(contrasts)[j],Probability=probs,
      EmpiricalOrder=orders,CompletionLower=empirical$Lower,
      CompletionUpper=empirical$Upper,MCFamilyLevel=mc_level,
      MCLowerOrder=mc_low,MCUpperOrder=mc_high,
      MCCompletionLower=lower,MCCompletionUpper=upper)
  })
  interval <- do.call(rbind,lapply(seq_along(point),function(j) {
    q <- quantiles[[j]]
    lo <- point[j]-q$CompletionUpper[2L]
    hi <- point[j]-q$CompletionLower[1L]
    data.frame(Target=rownames(contrasts)[j],Estimate=point[j],NominalLevel=level,
      Planned=B,Accepted=sum(ok),Unresolved=sum(status=='unresolved'),
      StructuralUnavailable=sum(grepl('^structural_',status)),
      CompletionLower=lo,CompletionUpper=hi,
      FiniteCompletionEnvelope=is.finite(lo)&&is.finite(hi),
      MCOuterLower=point[j]-q$MCCompletionUpper[2L],
      MCOuterUpper=point[j]-q$MCCompletionLower[1L],
      AllRefitsAccepted=all(ok),InferenceQualified=FALSE,row.names=NULL)
  }))
  list(status=if(all(ok))'complete_empirical_quantiles' else 'completion_envelope_only',
    settings=settings,source_available=TRUE,source_point=point,
    intervals=interval,quantiles=do.call(rbind,quantiles),draws=draws,
    attempts=data.frame(Replicate=seq_len(B),Available=ok,Status=status,Reason=reasons),
    inference_qualified=FALSE,
    interpretation=paste('Encloses empirical basic intervals for every scalar completion.',
      'Undefined structural estimates still require an estimator definition/theorem.',
      'MC bounds require a fixed-size iid bootstrap of a declared completed statistic;',
      'their family level covers two tails within one target, not all targets.',
      'Accepted numerical values inherit the v2 root-diagnostic limitations.'))
}

# Requires jml_pcm_bootstrap_setup(); loading it does not run the fitter.
# Save this output separately: frozen v2 numerical bindings are never rewritten.
jml_pcm_bootstrap_completion_saved <- function(directory, mc_level=.95, level=NULL) {
  paths <- character()
  read_checked <- function(name,binding=NULL) {
    path <- file.path(directory,name); z <- readRDS(path)
    stopifnot(identical(z$checksum,wide_mml_hash(z$payload)))
    if(!is.null(binding)) stopifnot(identical(z$binding,binding))
    paths <<- c(paths,path); z$payload
  }
  binding <- read_checked('manifest.rds','ordinary-pcm-basic-reference-v2')
  key <- wide_mml_hash(binding)
  original <- read_checked('original.rds',key)
  result <- read_checked('result.rds',key)
  stopifnot(identical(result$binding,binding),identical(result$original,original))
  if(is.null(level)) level <- binding$level
  attempts <- list()
  generation_failed <- isTRUE(original$available) && result$generated==0L
  if(isTRUE(original$available) && !generation_failed) {
    stopifnot(result$generated==binding$reps,nrow(result$trials)==binding$reps,
      identical(as.integer(result$trials$Replicate),seq_len(binding$reps)))
    attempts <- lapply(seq_len(binding$reps),function(i)
      read_checked(sprintf('draw-%04d.rds',i),
        list(manifest=key,replicate=i,seed=result$trials$Seed[i])))
    stopifnot(identical(vapply(attempts,function(a)isTRUE(a$available),TRUE),
      result$trials$Available))
  }
  source <- original
  if(generation_failed) {
    stopifnot(nrow(result$trials)==0L,length(result$reason)==1L,nzchar(result$reason))
    source$available <- FALSE; source$reason <- result$reason
  }
  output <- jml_pcm_bootstrap_completion(source,attempts,binding$contrasts,level,mc_level)
  if(generation_failed) {
    output$status <- 'generator_unavailable'; output$source_available <- TRUE
    output$source_point <- drop(binding$contrasts%*%original$beta)
  }
  output$binding <- list(numerical=binding,input=tools::md5sum(paths),
    source=tools::md5sum('inst/validation/jml-pcm-bootstrap-completion-20261003.R'),
    analysis_level=level,mc_level=mc_level,R=R.version.string)
  output$planned <- binding$reps; output$generated <- result$generated
  output
}

# Whole-sample research rule, pointwise in a prespecified contrast. The explicit
# MC budget is part of the procedure; alpha_stat + alpha_mc = 1 - target level.
# Source failure returns the full real line, never a fabricated point estimate.
jml_pcm_bootstrap_procedure <- function(completion, level, mc_error) {
  stopifnot(length(level)==1L,is.finite(level),level>0,level<1,
    length(mc_error)==1L,is.finite(mc_error),mc_error>0,mc_error<1-level,
    isTRUE(all.equal(completion$settings$level,level+mc_error,tolerance=1e-14)),
    isTRUE(all.equal(completion$settings$mc_level,1-mc_error,tolerance=1e-14)))
  source_fallback <- completion$status %in% c('original_unavailable','generator_unavailable')
  stopifnot(source_fallback || completion$status %in%
    c('complete_empirical_quantiles','completion_envelope_only'))
  targets <- completion$settings$targets; point <- completion$source_point
  stopifnot(length(targets)>0L,length(point)==length(targets))
  ranks <- NULL; B <- if(is.null(completion$draws))0L else nrow(completion$draws)
  lower <- rep(-Inf,length(targets)); upper <- rep(Inf,length(targets))
  if(!source_fallback) {
    p <- c((1-level-mc_error)/2,(1+level+mc_error)/2)
    # Only these two one-sided events are needed to enclose the basic interval.
    orders <- c(qbinom(mc_error/2,B,p[1L]),qbinom(1-mc_error/2,B,p[2L])+1L)
    ranks <- data.frame(Probability=p,Order=orders,
      Side=c('lower bound on lower quantile','upper bound on upper quantile'),
      OneSidedErrorBudget=mc_error/2)
    ok <- completion$attempts$Available
    for(j in seq_along(targets)) {
      bounds <- jml_bootstrap_order_bounds(completion$draws[ok,j]-point[j],B,orders)
      lower[j] <- point[j]-bounds$Upper[2L]
      upper[j] <- point[j]-bounds$Lower[1L]
    }
  }
  intervals <- data.frame(Target=targets,Estimate=point,Lower=lower,Upper=upper,
    TargetLevel=level,IdealBasicLevel=level+mc_error,MCErrorBudget=mc_error,
    PointAvailable=completion$source_available,SourceFallback=source_fallback,
    FiniteInterval=is.finite(lower)&is.finite(upper),
    FullLine=lower==-Inf & upper==Inf,InferenceQualified=FALSE,row.names=NULL)
  list(intervals=intervals,ranks=ranks,completion=completion,
    policy=list(version='whole-sample-reference-v1',scope='Pointwise prespecified contrast',level=level,
      statistical_error=1-level-mc_error,mc_error=mc_error,
      original_failure='Full real line; retain cause and point availability separately',
      comparison_statistic=paste('Exact extended-profile structural MLE when finite and unique;',
        'zero vector on mathematical nonexistence/nonidentification.',
        'The zero is only a theoretical completion, never an imputed unknown draw.'),
      claim=paste('Coverage transfer conditional on a justified ideal bootstrap law and',
        'correct accepted numerical values/generator; not a finite-sample coverage guarantee.')),
    inference_qualified=FALSE)
}

# One declared outer condition at a time. All planned rows must be present;
# full-line containment is reported separately from delivery of finite intervals.
jml_pcm_bootstrap_delivery <- function(rows, expected) {
  stopifnot(length(expected)==1L,is.finite(expected),expected>=1L,
    expected==floor(expected),nrow(rows)>0L,
    all(c('Target','Replicate','Truth','Lower','Upper','SourceFallback') %in% names(rows)),
    !anyNA(rows[c('Target','Replicate','Truth','Lower','Upper','SourceFallback')]),
    all(is.finite(rows$Truth)),all(rows$Lower<=rows$Upper),
    is.logical(rows$SourceFallback))
  do.call(rbind,lapply(split(rows,rows$Target),function(x) {
    stopifnot(nrow(x)==expected,!anyDuplicated(x$Replicate))
    finite <- is.finite(x$Lower)&is.finite(x$Upper)
    full <- x$Lower==-Inf & x$Upper==Inf
    stopifnot(all(!x$SourceFallback | full))
    covered <- x$Lower<=x$Truth & x$Truth<=x$Upper
    data.frame(Target=x$Target[1L],Attempted=nrow(x),
      AllSampleCoverage=mean(covered),FiniteIntervalRate=mean(finite),
      FiniteTruthDelivery=mean(finite & covered),
      CoverageAmongFinite=if(any(finite))mean(covered[finite]) else NA_real_,
      FullLineRate=mean(full),SourceFallbackRate=mean(x$SourceFallback),
      MeanWidth=mean(x$Upper-x$Lower),
      MeanFiniteWidth=if(any(finite))mean(x$Upper[finite]-x$Lower[finite]) else NA_real_,
      InferenceQualified=FALSE,row.names=NULL)
  }))
}
