# Targeted v2 checks; reuse the v1 finite-source evidence, no coverage claim.
jml_pcm_bootstrap_check <- function(out) {
  source('inst/validation/jml-pcm-basic-bootstrap-20261003.R')
  jml_pcm_bootstrap_setup()
  old <- 'validation-results/jml-pcm-basic-bootstrap-20261003'
  read_checked <- function(path) {
    z <- readRDS(path); stopifnot(identical(z$checksum,wide_mml_hash(z$payload))); z$payload
  }
  public_path <- file.path(old,'public-fit.rds')
  fit <- read_checked(public_path)$value
  baseline <- read_checked(file.path(old,'reference','result.rds'))
  prior_sources <- baseline$binding$source
  main_path <- 'inst/validation/jml-pcm-basic-bootstrap-20261003.R'
  snapshot <- file.path(old,'source-v1',basename(main_path))
  stopifnot(unname(tools::md5sum(snapshot))==unname(prior_sources[main_path]),
    identical(prior_sources[names(prior_sources)!=main_path],
      tools::md5sum(names(prior_sources)[names(prior_sources)!=main_path])))
  ctx <- jml_pcm_bootstrap_context(fit,TRUE); H <- baseline$binding$contrasts
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  numerical <- list(input=tools::md5sum(public_path),
    source=tools::md5sum(main_path),runtime=wide_mml_runtime())
  # One unchanged-source refit checks the new preflight; old inner fits are reused.
  finite <- wide_mml_phase(file.path(out,'finite-control.rds'),numerical,
    function()jml_pcm_bootstrap_refit(ctx,ctx$beta,jml_pcm_bootstrap_policy()))
  stopifnot(finite$available,finite$finite_joint_maximum,
    max(abs(finite$beta-baseline$original$beta))<1e-12)
  p <- jml_pcm_bootstrap_probabilities(ctx,finite$beta,finite$profile$theta)
  for(i in seq_len(12L)) {
    saved <- read_checked(file.path(old,'reference',sprintf('draw-%04d.rds',i)))
    stopifnot(identical(saved$response,jml_pcm_bootstrap_draw(p,baseline$trials$Seed[i])))
  }

  # Deliberate boundary fixture: two original Persons remain in all 180 rows.
  # This is a branch check, not a newly sampled outer dataset.
  extreme_fit <- fit
  extreme_fit$prep$data$score_k[ctx$groups[[1L]]] <- 0L
  extreme_fit$prep$data$score_k[ctx$groups[[2L]]] <- ctx$K-1L
  extreme <- jml_pcm_bootstrap_context(extreme_fit,TRUE)
  result <- jml_pcm_basic_bootstrap(extreme_fit,H,12L,20261003L,
    file.path(out,'two-extremes'),TRUE)
  stopifnot(result$original$available,result$generated==12L,
    result$original$extremes==2L,!result$original$finite_joint_maximum,
    nrow(result$trials)==12L,all(result$trials$ExtremePersons>=2L),
    all(!result$trials$FiniteJointMaximum))
  z <- result$original; theta <- z$profile$theta
  stopifnot(theta[1L]==-Inf,theta[2L]==Inf,
    all(z$profile$scores[1:2,]==0),all(vapply(z$profile$persons[1:2],is.null,TRUE)))
  probability <- jml_pcm_bootstrap_probabilities(extreme,z$beta,theta)
  low <- extreme$groups[[1L]]; high <- extreme$groups[[2L]]
  stopifnot(all(probability[low,1L]==1),all(probability[low,-1L]==0),
    all(probability[high,ctx$K]==1),all(probability[high,-ctx$K]==0))
  set.seed(18L); rng <- .Random.seed
  draw <- jml_pcm_bootstrap_draw(probability,49L)
  stopifnot(identical(rng,.Random.seed),identical(draw,jml_pcm_bootstrap_draw(probability,49L)),
    all(draw[low]==0L),all(draw[high]==ctx$K-1L),length(draw)==length(ctx$y))
  for(i in seq_len(12L)) {
    a <- read_checked(file.path(out,'two-extremes',sprintf('draw-%04d.rds',i)))
    stopifnot(length(a$response)==length(ctx$y),all(a$response[low]==0L),
      all(a$response[high]==ctx$K-1L))
  }

  # Full original likelihood at increasing finite abilities approaches the
  # extended-profile supremum. These caps diagnose a limit, not fit clipping.
  # Indices also contain the observed scores, so rebuild them for this fixture.
  idx <- mfrmr:::build_indices(extreme_fit$prep,fit$config$step_facet,fit$config$slope_facet)
  ev <- mfrmr:::make_mfrm_direct_evaluator('JML',
    mfrmr:::make_param_cache(ctx$sizes,fit$config,idx,is_mml=FALSE),idx,fit$config,ctx$sizes,NULL)
  caps <- c(10,20,40,80)
  path <- do.call(rbind,lapply(caps,function(cap) {
    t <- theta; t[1:2] <- c(-cap,cap); par <- c(t,z$beta)
    gradient <- ev$gradient(par)
    data.frame(Cap=cap,Gap=ev$value(par)-z$profile$value,
      StructuralGradientDifference=max(abs(tail(gradient,length(z$beta))-z$profile$gradient)),
      ExtremeAbilityGradient=max(abs(gradient[1:2])))
  }))
  stopifnot(all(path$Gap>=-1e-8),all(diff(path$Gap)<=1e-8),
    abs(tail(path$Gap,1L))<1e-8,
    tail(path$StructuralGradientDifference,1L)<1e-8,
    tail(path$ExtremeAbilityGradient,1L)<1e-8)

  # No nonextreme Persons: structural profile is flat, not an identified fit.
  all_extreme <- extreme_fit
  for(i in seq_along(ctx$groups))
    all_extreme$prep$data$score_k[ctx$groups[[i]]] <- if(i%%2L)0L else ctx$K-1L
  empty <- jml_pcm_basic_bootstrap(all_extreme,H,2L,73L,file.path(out,'all-extreme'),TRUE)
  stopifnot(!empty$available,empty$generated==0L,
    empty$original$reason=='no_structural_information')
  # No extreme Persons, but structural separation: every response is category 1.
  separated <- ctx; separated$y[] <- 1L
  separation <- wide_mml_phase(file.path(out,'separation.rds'),numerical,
    function()jml_pcm_bootstrap_refit(separated,ctx$beta,jml_pcm_bootstrap_policy()))
  stopifnot(!separation$available,separation$extremes==0L,
    separation$reason=='structural_recession',is.null(separation$optimizer))
  witness <- separation$existence$value
  margins <- as.numeric(witness$contrast%*%witness$direction)
  stopifnot(all(margins>=0),any(margins>0))
  nonidentified <- jml_pcm_basic_bootstrap({f <- fit; f$prep$data$score_k[] <- 1L; f},
    H,2L,73L,file.path(out,'separated-source'),TRUE)
  stopifnot(!nonidentified$available,nonidentified$generated==0L,
    nonidentified$original$reason=='structural_recession')

  # Constraints coupling an extreme Person are outside the profiling identity.
  anchored <- extreme_fit; anchored$config$theta_spec$anchors[1L] <- 0
  stopifnot(inherits(try(jml_pcm_bootstrap_context(anchored,TRUE),silent=TRUE),'try-error'))
  incomplete <- fit; incomplete$prep$data <- incomplete$prep$data[-1L,]
  stopifnot(inherits(try(jml_pcm_bootstrap_context(incomplete,TRUE),silent=TRUE),'try-error'))
  stopifnot(inherits(try(jml_pcm_bootstrap_context(fit,FALSE),silent=TRUE),'try-error'))
  bad_theta <- finite$profile$theta; bad_theta[1L] <- Inf
  stopifnot(inherits(try(jml_pcm_bootstrap_probabilities(ctx,finite$beta,bad_theta),silent=TRUE),'try-error'))
  fake <- lapply(c(8,9,10,14),function(b)list(available=TRUE,beta=b))
  one <- matrix(1,1,1,dimnames=list('q',NULL))
  formula <- jml_pcm_bootstrap_intervals(list(beta=10),fake,one,.5)
  stopifnot(formula$intervals$Lower==10,formula$intervals$Upper==12)
  fake[[2L]]$available <- FALSE
  refused <- jml_pcm_bootstrap_intervals(list(beta=10),fake,one,.5)
  stopifnot(!refused$intervals$ComputationallyAvailable,is.na(refused$intervals$Lower),
    is.na(refused$intervals$Upper),nrow(refused$draws)==4L)
  local({
    refit <- jml_pcm_bootstrap_refit; generator <- jml_pcm_bootstrap_draw
    on.exit({assign('jml_pcm_bootstrap_refit',refit,envir=.GlobalEnv)
      assign('jml_pcm_bootstrap_draw',generator,envir=.GlobalEnv)})
    blocked <- function(...)stop('Completed evidence must not be recomputed')
    assign('jml_pcm_bootstrap_refit',blocked,envir=.GlobalEnv)
    assign('jml_pcm_bootstrap_draw',blocked,envir=.GlobalEnv)
    replay <- jml_pcm_basic_bootstrap(extreme_fit,H,12L,20261003L,
      file.path(out,'two-extremes'),TRUE)
    stopifnot(identical(result,replay))
  })
  checks <- list(passed=TRUE,source=tools::md5sum('inst/validation/jml-pcm-basic-bootstrap-check-20261003.R'),
    prior_input=tools::md5sum(public_path),prior_finite_source_difference=max(abs(finite$beta-baseline$original$beta)),
    original_extremes=result$original$extremes,attempted=result$generated,
    accepted=sum(result$trials$Available),limit_path=path,
    separation_minimum_margin=min(margins),separation_strict_rows=sum(margins>0),
    interpretation='Extended-profile implementation checks on a deliberate boundary fixture; no coverage qualification')
  wide_mml_phase(file.path(out,paste0('checks-',unname(checks$source),'.rds')),checks$source,function()checks)
  print(checks); print(result$trials,row.names=FALSE); print(result$quantile_mc,row.names=FALSE)
  invisible(result)
}

if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE); stopifnot(length(args)==1L)
  jml_pcm_bootstrap_check(args[1])
}
