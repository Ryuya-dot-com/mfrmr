# Resolve the two retained LR bootstrap local-category refusals, without draws.
# This changes a research LR gate, not public Wald-interval readiness.
script <- 'inst/validation/mfrm-lr-rsm-local-support-20261010.R'
prior <- 'validation-results/mfrm-lr-rsm-null-bootstrap-20261010'
natural <- 'validation-results/mfrm-lr-rsm-natural-boundary-20261010'
out <- 'validation-results/mfrm-lr-rsm-local-support-20261010'
pkgload::load_all('.',quiet=TRUE,compile=FALSE)
source('inst/validation/mfrm-lr-rsm-boundary-20261009.R')
old_script <- 'inst/validation/mfrm-lr-rsm-null-bootstrap-20261010.R'
wanted <- c('verify','save_atomic','phase','require_phase','check_full','constrained','unrestricted','review')
for(expr in parse(old_script)) if(is.call(expr) && identical(expr[[1]],as.name('<-')) &&
  is.symbol(expr[[2]]) && as.character(expr[[2]]) %in% wanted) eval(expr)
for(expr in parse('inst/validation/mfrm-lr-rsm-natural-boundary-20261010.R'))
  if(is.call(expr) && identical(expr[[1]],as.name('<-')) && is.symbol(expr[[2]]) &&
    as.character(expr[[2]]) %in% c('natural_evaluator','heat_reference')) eval(expr)
old <- readRDS(file.path(prior,'manifest.rds')); controls <- old$controls
h <- old$source[!names(old$source) %in% c('loaded_mfrmr_DLL','R/help_reports_and_tables.R')]
verify(h)
canonical_session <- function(x) {
  x$loadedOnly <- x$loadedOnly[sort(names(x$loadedOnly))]
  x
}
stopifnot(unname(tools::md5sum(getLoadedDLLs()[['mfrmr']][['path']]))==
  unname(old$source['loaded_mfrmr_DLL']),identical(canonical_session(sessionInfo()),canonical_session(old$session)),
  identical(Sys.getenv(names(old$threads)),old$threads))
audit <- readRDS(file.path(prior,'verification.rds'))
stopifnot(audit$passed); verify(audit$retained)
previous <- readRDS(file.path(natural,'summary.rds'))
verify(previous$phase_hashes)
profile <- readRDS('validation-results/mfrm-lr-rsm-adaptive-profile-20261010/manifest.rds')
fit_paths <- names(profile$inputs)[endsWith(names(profile$inputs),'-fit.rds')]
stopifnot(identical(which(previous$trials$Status!='computed'),c(58L,59L)))

category_gate <- function(fit) {
  cfg <- fit$config
  audit <- mfrmr:::audit_mfrm_category_support(fit$prep,cfg,mfrmr:::build_param_sizes(cfg))
  stopifnot(cfg$model=='RSM',is.null(cfg$step_facet))
  if(!all(audit$support_table$InformationState=='adequate') ||
     audit$readiness$UnsupportedStepCoordinates!=0L ||
     audit$readiness$UnsupportedCategoryContrasts!=0L)
    stop('Shared category ladder is not supported.')
  if(!audit$readiness$CategoryState %in% c('adequate','weak_information'))
    stop('Unresolved category audit.')
  audit
}

context <- function(fit) {
  category <- category_gate(fit)
  cfg <- fit$config; cfg$estimation_control$mml_integration <- 'adaptive'
  cfg$estimation_control$quad_points <- controls$order
  sizes <- mfrmr:::build_param_sizes(cfg)
  idx <- mfrmr:::build_indices(fit$prep,cfg$step_facet,cfg$slope_facet,
    cfg$interaction_specs,gpcm_spec=cfg$gpcm_spec)
  evaluator <- function(q) {
    config <- cfg; config$estimation_control$quad_points <- q
    mfrmr:::make_mfrm_direct_evaluator('MML',
      mfrmr:::make_param_cache(sizes,config,idx,is_mml=TRUE),idx,config,sizes,
      mfrmr:::gauss_hermite_normal(q))
  }
  list(fit=fit,cfg=cfg,sizes=sizes,idx=idx,ctx=rsm_lr_boundary_context(fit),
    category=category,low=evaluator(controls$order),high=evaluator(controls$reference_order))
}

settings <- list(draws=c(18L,19L),natural=list(maxit=400L,factr=100,pgtol=1e-8),
  rule=paste('For research LR only, shared RSM ladder must be adequate with no unsupported coordinates/contrasts.',
    'Local non-owner rarity remains reported; finite likelihood, rank, two-start, gradient, information,',
    'integration and one-sided natural-variance checks must pass. Public Wald gates are unchanged.'))
manifest <- list(settings=settings,controls=controls,
  source=c(tools::md5sum(script),old$source),
  current_guide=tools::md5sum('R/help_reports_and_tables.R'),
  inputs=c(tools::md5sum(c(file.path(prior,'verification.rds'),file.path(natural,'summary.rds'))),
    audit$retained,profile$inputs),session=sessionInfo(),threads=old$threads)
dir.create(out,recursive=TRUE,showWarnings=FALSE)
manifest_path <- file.path(out,'manifest.rds')
if(file.exists(manifest_path)) stopifnot(identical(readRDS(manifest_path),manifest)) else save_atomic(manifest,manifest_path)
binding <- unname(tools::md5sum(manifest_path))

fits <- lapply(settings$draws,function(b) {
  fit <- readRDS(fit_paths[4])$payload$value
  input <- require_phase(readRDS(file.path(prior,sprintf('case-03-draw-%03d-input.rds',b))))
  fit$prep$data$Score <- fit$prep$data$score_k <- input$scores
  a <- category_gate(fit)
  stopifnot(a$readiness$CategoryState=='weak_information',
    all(a$support_table$InformationState=='adequate'),a$readiness$WeakLocalScopes>0)
  # Unsupported shared interior and empty boundary categories still refuse.
  for(cat in c(1L,0L)) {
    bad <- fit; bad$prep$data$Score[bad$prep$data$Score==cat] <- 2L
    bad$prep$data$score_k <- bad$prep$data$Score
    stopifnot(inherits(try(category_gate(bad),silent=TRUE),'try-error'))
  }
  fit
})

for(i in seq_along(fits)) {
  b <- settings$draws[i]; prefix <- sprintf('case-03-draw-%03d',b)
  e <- context(fits[[i]])
  dependency <- tools::md5sum(c(fit_paths[4],file.path(prior,paste0(prefix,'-input.rds'))))
  save_atomic(e$category,file.path(out,paste0(prefix,'-category.rds')))
  z <- require_phase(phase(paste0(prefix,'-zero'),dependency,function()rsm_lr_boundary_zero(e$ctx)))
  stopifnot(z$qualified)
  n <- constrained(e,0,c(z$eta,log(.75)),z)
  full <- require_phase(phase(paste0(prefix,'-free'),dependency,function()unrestricted(e,n$parameters,z)))
  if(!isTRUE(full$passed) && z$natural_variance_score<=-controls$boundary_margin) {
    lo <- natural_evaluator(e$low,e$ctx); hi <- natural_evaluator(e$high,e$ctx)
    attempts <- lapply(c('warm','neutral'),function(start) require_phase(phase(
      paste0(prefix,'-natural-',start),dependency,function() {
        p <- full$attempts[[start]]$parameters; p[length(p)] <- exp(tail(p,1))
        opt <- optim(p,lo$value,lo$gradient,method='L-BFGS-B',lower=c(rep(-Inf,e$ctx$p),0),control=settings$natural)
        a <- lo$evaluate(opt$par); h <- hi$evaluate(opt$par)
        projected <- function(g) {g[length(g)]<-min(tail(g,1),0);max(abs(g))}
        checks <- c(code=opt$convergence==0L,exact_zero=tail(opt$par,1)==0,
          nll=abs(a$value-h$value)<=controls$nll,gradient=max(abs(a$gradient-h$gradient))<=controls$gradient,
          score=max(projected(a$gradient),projected(h$gradient))<=controls$gradient,
          boundary=max(abs(c(a$value,h$value)-z$nll))<=controls$nll)
        list(passed=all(checks),checks=checks,opt=opt,low=a,high=h)
      })))
    stopifnot(all(vapply(attempts,function(x)x$passed,TRUE)))
    full <- list(passed=TRUE,kind='zero',parameters=c(z$eta,-Inf),nll=z$nll,
      continuous=list(value=z$nll,summed_relative_error=0),attempts=attempts)
  }
  stopifnot(isTRUE(full$passed))
  ref <- require_phase(phase(paste0(prefix,'-reference'),dependency,function() {
    eta <- head(full$parameters,-1L); v <- exp(tail(full$parameters,1L))
    ref <- heat_reference(e$ctx,eta,v)
    a <- natural_evaluator(e$low,e$ctx)$evaluate(c(eta,v))
    h <- natural_evaluator(e$high,e$ctx)$evaluate(c(eta,v))
    H <- if(v==0) rsm_lr_boundary_eval(e$ctx,eta)$hessian else full$hessian
    checks <- c(nll=max(abs(c(a$value,h$value)-ref$value))+ref$nll_error<=controls$nll,
      derivative=max(abs(c(tail(a$gradient,1),tail(h$gradient,1))-ref$gradient))+ref$gradient_error<=controls$gradient,
      information=min(eigen(H,symmetric=TRUE,only.values=TRUE)$values)>0)
    if(v==0) {
      steps <- c(1e-4,5e-5,2.5e-5)
      points <- lapply(c(0,steps),function(v)rsm_lr_continuous_value(e$ctx,eta,v))
      values <- vapply(points,`[[`,0.,'value'); errors <- vapply(points,`[[`,0.,'summed_relative_error')
      step <- steps[2]; coarse <- (-3*values[1]+4*values[3]-values[2])/(2*step)
      fine <- (-3*values[1]+4*values[4]-values[3])/step
      allowance <- (3*errors[1]+4*errors[4]+errors[3])/step
      checks <- c(checks,forward_derivative=abs(fine+z$natural_variance_score)+abs(coarse-fine)+allowance<=controls$gradient,
        boundary_score=z$natural_variance_score<=-controls$boundary_margin)
    }
    list(passed=all(checks),checks=checks,reference=ref,low=a,high=h,hessian=H)
  }))
  stopifnot(ref$passed)
  result <- list(status='computed',reason='',review=review(n,full,0),full=full,
    category=e$category$readiness,reference=ref,binding=binding,case=3L,draw=b)
  save_atomic(result,file.path(out,paste0(prefix,'-result.rds')))
  cat(prefix,': LR=',result$review$LR,'kind=',full$kind,'\n')
}

trials <- previous$trials
for(b in settings$draws) {
  x <- readRDS(file.path(out,sprintf('case-03-draw-%03d-result.rds',b)))
  at <- which(trials$Case==3L & trials$Draw==b)
  trials$Status[at] <- x$status; trials$Reason[at] <- ''
  trials$LR[at] <- x$review$LR; trials$StructuralZero[at] <- x$review$StructuralZero
  observed <- readRDS(file.path(prior,'case-03-draw-000-result.rds'))$review
  trials$NumericallyAmbiguous[at] <- abs(x$review$LR-observed$LR)<=
    x$review$NumericalAllowance+observed$NumericalAllowance && !(x$review$StructuralZero && observed$StructuralZero)
}
unchanged <- !(trials$Case==3L & trials$Draw %in% settings$draws)
stopifnot(identical(trials[unchanged,],previous$trials[unchanged,]),sum(unchanged)==78L)
files <- list.files(out,'-(zero|free|natural-warm|natural-neutral|reference|result|category)[.]rds$',full.names=TRUE)
result <- list(trials=trials,manifest=tools::md5sum(manifest_path),phase_hashes=tools::md5sum(files),
  passed=all(trials$Status=='computed'),note='Computability only; not finite-sample bootstrap calibration or coverage.')
save_atomic(result,file.path(out,'summary.rds'))
write.csv(trials,file.path(out,'trials.csv'),row.names=FALSE)
print(table(trials$Case,trials$Status))
