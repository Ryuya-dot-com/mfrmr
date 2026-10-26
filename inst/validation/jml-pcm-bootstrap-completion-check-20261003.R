# Deterministic rank checks and saved-v2 replay; no new responses or estimates.
jml_pcm_bootstrap_completion_check <- function(out) {
  source('inst/validation/jml-pcm-basic-bootstrap-20261003.R')
  jml_pcm_bootstrap_setup()
  source('inst/validation/jml-pcm-bootstrap-completion-20261003.R')
  root <- 'validation-results/jml-pcm-extended-bootstrap-20261003'
  saved_files <- list.files(root,recursive=TRUE,full.names=TRUE)
  before <- tools::md5sum(saved_files)
  input <- file.path(root,'two-extremes')
  result <- readRDS(file.path(input,'result.rds'))$payload
  stopifnot(identical(result$binding$source,tools::md5sum(names(result$binding$source))))
  # Tripwires make a repeated numerical stage an error, not a hidden cost.
  jml_pcm_bootstrap_refit <<- function(...)stop('Unexpected refit')
  jml_pcm_bootstrap_draw <<- function(...)stop('Unexpected generation')
  completed <- jml_pcm_bootstrap_completion_saved(input)
  stopifnot(identical(completed$intervals$CompletionLower,result$intervals$Lower),
    identical(completed$intervals$CompletionUpper,result$intervals$Upper),
    all(completed$intervals$Accepted==12L),all(completed$intervals$AllRefitsAccepted),
    !any(completed$intervals$InferenceQualified),
    all(completed$intervals$MCOuterLower==-Inf),all(completed$intervals$MCOuterUpper==Inf))
  attempts <- lapply(1:12,function(i)
    readRDS(file.path(input,sprintf('draw-%04d.rds',i)))$payload)
  H <- result$binding$contrasts
  hidden <- attempts; hidden[[1L]]$available <- FALSE
  hidden[[1L]]$reason <- 'numerical_distance_exceeds_budget'
  hidden[[1L]]$beta[] <- 1e90 # An unaccepted finite iterate must not enter a quantile.
  masked <- jml_pcm_bootstrap_completion(result$original,hidden,H)
  stopifnot(all(masked$intervals$CompletionLower==-Inf),
    all(masked$intervals$CompletionUpper==Inf),all(is.na(masked$draws[1L,])),
    all(masked$intervals$Unresolved==1L),all(masked$intervals$StructuralUnavailable==0L))
  hidden[[1L]] <- readRDS(file.path(root,'separation.rds'))$payload
  boundary <- jml_pcm_bootstrap_completion(result$original,hidden,H)
  stopifnot(all(boundary$intervals$StructuralUnavailable==1L),
    boundary$attempts$Status[1L]=='structural_nonexistence',
    !any(boundary$intervals$InferenceQualified))
  unavailable <- jml_pcm_bootstrap_completion_saved(file.path(root,'all-extreme'))
  stopifnot(unavailable$status=='original_unavailable',unavailable$generated==0L,
    nrow(unavailable$intervals)==0L,unavailable$reason=='no_structural_information')

  # Sharp order bounds: enumerate completions, including both infinities and ties.
  # This independently sorts each complete sample; it does not reuse the formula.
  enumerated <- 0L
  for(B in 1:7) for(m in 0:min(3L,B)) {
    known <- rep(c(-1,0,0,1),length.out=B-m)
    fill <- if(m==0L)matrix(numeric(),1L,0L) else
      as.matrix(expand.grid(rep(list(c(-Inf,-2,0,2,Inf)),m)))
    actual <- vapply(seq_len(nrow(fill)),function(i)
      c(-Inf,sort(c(known,fill[i,])),Inf),numeric(B+2L))
    bound <- jml_bootstrap_order_bounds(known,B,0:(B+1L))
    stopifnot(identical(bound$Lower,unname(apply(actual,1L,min))),
      identical(bound$Upper,unname(apply(actual,1L,max))))
    enumerated <- enumerated+nrow(fill)
  }
  original <- list(available=TRUE,beta=100)
  toy_H <- matrix(1,1,1,dimnames=list('Toy contrast',NULL))
  toy <- lapply(1:199,function(i)list(available=TRUE,beta=i,reason=''))
  full <- jml_pcm_bootstrap_completion(original,toy,toy_H)
  toy[[100L]] <- list(available=FALSE,beta=1e90,reason='refit_error: synthetic')
  one <- jml_pcm_bootstrap_completion(original,toy,toy_H)
  stopifnot(full$intervals$CompletionLower==5,full$intervals$CompletionUpper==195,
    one$intervals$CompletionLower==4,one$intervals$CompletionUpper==196,
    one$intervals$Planned==199L,one$intervals$Accepted==198L,
    !one$intervals$AllRefitsAccepted,!one$intervals$InferenceQualified)
  previous <- one$intervals
  for(i in c(98L,99L,101L,97L)) {
    toy[[i]] <- toy[[100L]]
    current <- jml_pcm_bootstrap_completion(original,toy,toy_H)$intervals
    stopifnot(current$CompletionLower<=previous$CompletionLower,
      current$CompletionUpper>=previous$CompletionUpper)
    if(current$Accepted==195L) stopifnot(current$FiniteCompletionEnvelope)
    previous <- current
  }
  stopifnot(previous$CompletionLower==-Inf,previous$CompletionUpper==Inf)
  all_unknown <- jml_pcm_bootstrap_completion(original,rep(toy[100L],199L),toy_H)
  stopifnot(all_unknown$intervals$CompletionLower==-Inf,
    all_unknown$intervals$CompletionUpper==Inf,all_unknown$intervals$Accepted==0L)
  # Basic, not percentile, arithmetic on a skewed sample.
  skew <- lapply(c(8,9,10,14),function(b)list(available=TRUE,beta=b,reason=''))
  z <- jml_pcm_bootstrap_completion(list(available=TRUE,beta=10),skew,toy_H,level=.5)
  stopifnot(z$intervals$CompletionLower==10,z$intervals$CompletionUpper==12)

  # Binomial tail budgets imply joint MC coverage >= .95 for the two
  # ideal quantiles of one declared statistic (continuous case; ties conservative).
  mc_checks <- do.call(rbind,lapply(c(12L,199L,999L),function(B)
    do.call(rbind,lapply(c(.8,.9,.95,.99),function(level) {
      p <- c((1-level)/2,(1+level)/2)
      lo <- qbinom(.05/4,B,p); hi <- qbinom(1-.05/4,B,p)+1L
      error <- pbinom(lo-1L,B,p)+pbinom(hi-1L,B,p,lower.tail=FALSE)
      stopifnot(sum(error)<=.05+1e-14)
      data.frame(B=B,NominalLevel=level,MCJointLowerBound=1-sum(error))
    }))))
  # A complete rule: .045 statistical error + .005 MC error, pointwise.
  adjusted <- jml_pcm_bootstrap_completion_saved(input,level=.955,mc_level=.995)
  whole <- jml_pcm_bootstrap_procedure(adjusted,level=.95,mc_error=.005)
  stopifnot(all(whole$intervals$FullLine),!any(whole$intervals$SourceFallback),
    all(whole$intervals$PointAvailable),!any(whole$intervals$InferenceQualified))
  source_cases <- lapply(c('all-extreme','separated-source'),function(name) {
    z <- jml_pcm_bootstrap_completion_saved(file.path(root,name),level=.955,mc_level=.995)
    jml_pcm_bootstrap_procedure(z,level=.95,mc_error=.005)
  })
  stopifnot(all(vapply(source_cases,function(z)
    all(z$intervals$FullLine & z$intervals$SourceFallback & !z$intervals$PointAvailable),TRUE)),
    all(vapply(source_cases,function(z)all(is.na(z$intervals$Estimate)),TRUE)),
    inherits(try(jml_pcm_bootstrap_procedure(completed,.95,.005),silent=TRUE),'try-error'),
    inherits(try(jml_pcm_bootstrap_procedure(adjusted,.95,.05),silent=TRUE),'try-error'))
  # A recorded generation failure is a source fallback; corruption is an error.
  fixture <- tempfile('pcm-generation-failure-'); dir.create(fixture)
  on.exit(unlink(fixture,recursive=TRUE),add=TRUE)
  stopifnot(all(file.copy(file.path(input,c('manifest.rds','original.rds')),fixture)))
  recorded <- readRDS(file.path(input,'result.rds'))
  recorded$payload <- list(original=result$original,binding=result$binding,
    trials=data.frame(),planned=12L,generated=0L,available=FALSE,
    reason='Source generation unavailable: synthetic branch check',inference_qualified=FALSE)
  recorded$checksum <- wide_mml_hash(recorded$payload)
  saveRDS(recorded,file.path(fixture,'result.rds'))
  generation_case <- jml_pcm_bootstrap_procedure(
    jml_pcm_bootstrap_completion_saved(fixture,level=.955,mc_level=.995),.95,.005)
  stopifnot(all(generation_case$intervals$SourceFallback),
    all(generation_case$intervals$PointAvailable),
    all(is.finite(generation_case$intervals$Estimate)))
  recorded$checksum <- 'deliberately corrupted'
  saveRDS(recorded,file.path(fixture,'result.rds'))
  stopifnot(inherits(try(jml_pcm_bootstrap_completion_saved(fixture),silent=TRUE),'try-error'))

  # Counts, not new simulated datasets: exact binomial weights assess MC
  # containment when unknown values depend on the would-be estimate itself.
  containment <- lapply(c(.1,.9),function(probability) {
    contained <- vapply(0:60,function(k) {
      values <- c(rep(0,60-k),rep(1,k))
      hidden_value <- if(probability==.1)1 else 0
      a <- lapply(values,function(b)list(available=b!=hidden_value,beta=b,reason='unresolved'))
      z <- jml_pcm_bootstrap_completion(list(available=TRUE,beta=.1),a,toy_H,level=.85)
      w <- jml_pcm_bootstrap_procedure(z,level=.8,mc_error=.05)$intervals
      # The exact .075 and .925 quantiles are 0 and 1 in both laws.
      w$Lower<=-.8 && w$Upper>=.2
    },TRUE)
    bound <- sum(dbinom(0:60,60,probability)*contained)
    stopifnot(bound>=.95-1e-14)
    data.frame(ProbabilityOne=probability,MCContainment=bound,States=61L)
  })
  budget_ranks <- do.call(rbind,lapply(c(12L,199L,263L,264L,999L),function(B) {
    p <- .045/2; lo <- qbinom(.005/2,B,p); hi <- qbinom(1-.005/2,B,1-p)+1L
    error <- pbinom(lo-1L,B,p)+pbinom(hi-1L,B,1-p,lower.tail=FALSE)
    stopifnot(error<=.005+1e-14)
    data.frame(B=B,LowerOrder=lo,UpperOrder=hi,ErrorBound=error,
      MaximumUnknownForFinite=min(lo-1L,B-hi))
  }))
  stopifnot(budget_ranks$MaximumUnknownForFinite[budget_ranks$B==263L]==-1,
    budget_ranks$MaximumUnknownForFinite[budget_ranks$B==264L]==0,
    budget_ranks$MaximumUnknownForFinite[budget_ranks$B==999L]==10)
  deliveries <- data.frame(Target='synthetic',Replicate=1:5,Truth=0,
    Lower=c(-1,1,-Inf,-Inf,0),Upper=c(1,2,Inf,Inf,Inf),
    SourceFallback=c(FALSE,FALSE,TRUE,FALSE,FALSE))
  accounting <- jml_pcm_bootstrap_delivery(deliveries,5L)
  stopifnot(accounting$AllSampleCoverage==.8,accounting$FiniteIntervalRate==.4,
    accounting$FiniteTruthDelivery==.2,accounting$CoverageAmongFinite==.5,
    accounting$FullLineRate==.4,accounting$SourceFallbackRate==.2,
    accounting$MeanWidth==Inf,accounting$MeanFiniteWidth==1.5,
    inherits(try(jml_pcm_bootstrap_delivery(deliveries[-1L,],5L),silent=TRUE),'try-error'))
  deliveries$Lower <- -Inf; deliveries$Upper <- Inf; deliveries$SourceFallback <- TRUE
  all_fallback <- jml_pcm_bootstrap_delivery(deliveries,5L)
  stopifnot(all_fallback$AllSampleCoverage==1,all_fallback$FiniteIntervalRate==0,
    all_fallback$FiniteTruthDelivery==0,is.na(all_fallback$CoverageAmongFinite))
  stopifnot(identical(before,tools::md5sum(saved_files)))
  r50 <- readRDS('validation-results/mfrm-wide-map-pcm-r50-portable-20261003/manifest.rds')$payload
  stopifnot(identical(r50$source,tools::md5sum(names(r50$source))))
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  binding <- list(inputs=before,source=tools::md5sum(paste0('inst/validation/',
    c('jml-pcm-bootstrap-completion-20261003',
      'jml-pcm-bootstrap-completion-check-20261003'),'.R')),R=R.version.string)
  evidence <- list(saved=completed,masked_one_of_twelve=masked,
    substituted_separation=boundary,unavailable_source=unavailable,
    synthetic_one_of_199=one,enumerated_completions=enumerated,mc_checks=mc_checks,
    new_fits=0L,new_generated_datasets=0L,saved_files_unchanged=TRUE,
    frozen_r50_sources_unchanged=TRUE,whole_procedure=whole,source_failures=source_cases,
    generation_failure=generation_case,exact_mc_containment=do.call(rbind,containment),
    budget_ranks=budget_ranks,delivery_accounting=accounting,all_fallback=all_fallback)
  wide_mml_phase(file.path(out,'checks-whole-sample.rds'),binding,function()evidence)
  cat('PASS:',enumerated,'enumerated completions; saved-v2 equality; unavailable-source,\n',
    'failure accounting, basic arithmetic, MC budgets and unchanged numerical evidence.\n',
    'Whole-sample fallback, joint error budget, exact MC containment and delivery accounting passed.\n',
    'New fits: 0; new generated datasets: 0.\n')
  print(budget_ranks)
  print(do.call(rbind,containment))
  invisible(evidence)
}

if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE)
  stopifnot(length(args)==1L)
  jml_pcm_bootstrap_completion_check(args[1L])
}
