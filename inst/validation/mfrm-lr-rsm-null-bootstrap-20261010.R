# Repository-only computational feasibility; B=20 is not coverage validation.
# Single-threaded validation runtime; args: freeze | run [case [draw]] | summarize.
script <- 'inst/validation/mfrm-lr-rsm-null-bootstrap-20261010.R'
prior <- 'validation-results/mfrm-lr-rsm-adaptive-profile-20261010'
out <- 'validation-results/mfrm-lr-rsm-null-bootstrap-20261010'
verify <- function(h) stopifnot(length(h)>0L,!anyNA(h),
  identical(unname(tools::md5sum(names(h))),unname(h)))
audit_path <- file.path(prior,'verification.rds')
stopifnot(unname(tools::md5sum(audit_path))=='3d0f9182d37aad6d78bae2f31d704f55')
audit <- readRDS(audit_path); stopifnot(audit$passed); verify(audit$retained)
old <- readRDS(file.path(prior,'manifest.rds')); verify(old$inputs)
pkgload::load_all('.',quiet=TRUE,compile=FALSE)
source('inst/validation/mfrm-lr-rsm-boundary-20261009.R')
verify(old$source[names(old$source)!='loaded_mfrmr_DLL'])
stopifnot(unname(tools::md5sum(getLoadedDLLs()[['mfrmr']][['path']]))==
  unname(old$source['loaded_mfrmr_DLL']),identical(sessionInfo(),old$session),
  identical(Sys.getenv(names(old$threads)),old$threads))
fit_paths <- names(old$inputs)[endsWith(names(old$inputs),'-fit.rds')]
selected_paths <- names(old$inputs)[endsWith(names(old$inputs),'/selected.rds')]
cases <- data.frame(Case=1:4,PriorCase=c(1L,3L,4L,5L),N=c(20L,20L,20L,240L),
  NullVariance=c(.75,.75,0,.75))
controls <- list(B=20L,order=31L,reference_order=61L,maxit=400L,reltol=1e-12,
  nll=1e-5,gradient=1e-4,boundary_margin=1e-6,level=.95)
manifest <- list(cases=cases,controls=controls,inputs=c(tools::md5sum(audit_path),
  audit$retained,old$inputs),source=c(tools::md5sum(script),old$source),
  session=sessionInfo(),threads=old$threads,
  purpose='Null-specific refitting feasibility and cost, not coverage or a confirmatory test.')
dir.create(out,recursive=TRUE,showWarnings=FALSE)
save_atomic <- function(x,path) {
  saveRDS(x,paste0(path,'.tmp')); stopifnot(file.rename(paste0(path,'.tmp'),path))
}
manifest_path <- file.path(out,'manifest.rds')
if(file.exists(manifest_path)) stopifnot(identical(readRDS(manifest_path),manifest)) else
  save_atomic(manifest,manifest_path)
binding <- unname(tools::md5sum(manifest_path))
phase <- function(key,dependency,fn) {
  path <- file.path(out,paste0(key,'.rds')); bound <- list(manifest=binding,dependency=dependency)
  if(file.exists(path)) {
    x <- readRDS(path); stopifnot(identical(x$binding,bound)); return(x)
  }
  started <- proc.time()[['elapsed']]; warnings <- character()
  x <- tryCatch(withCallingHandlers(list(value=fn(),error=''),warning=function(w) {
    warnings <<- c(warnings,conditionMessage(w)); invokeRestart('muffleWarning')
  }),error=function(e) list(value=NULL,error=conditionMessage(e)))
  x$warnings <- unique(warnings); x$elapsed <- proc.time()[['elapsed']]-started
  x$binding <- bound; save_atomic(x,path)
  cat(sprintf('%s: %.3f s%s\n',key,x$elapsed,if(nzchar(x$error)) paste(' ERROR:',x$error) else ''))
  flush.console(); x
}
require_phase <- function(x) {if(nzchar(x$error)) stop(x$error); x$value}
hash_phase <- function(key) tools::md5sum(file.path(out,paste0(key,'.rds')))

reserve <- function() {
  path <- file.path(out,'rng-registry.rds')
  head_path <- 'validation-results/mfrm-wide-map-r50-20261001/rng-head.rds'
  if(!file.exists(path)) {
    head <- readRDS(head_path); verify(head$registry_md5)
    previous <- readRDS(head$registry)
    stopifnot(head$next_unit_ordinal==10251L,previous$next_unit_ordinal==head$next_unit_ordinal)
    units <- expand.grid(Draw=seq_len(controls$B),Case=cases$Case)
    stream <- previous$next_unused_unit_stream
    streams <- lapply(seq_len(nrow(units)),function(i) {
      current <- stream; stream <<- parallel::nextRNGStream(stream); current
    })
    registry <- list(epoch='RSM-LR-null-bootstrap-feasibility-v1',manifest=binding,
      predecessor=head,predecessor_head_md5=tools::md5sum(head_path),units=units,
      streams=streams,first_unit_ordinal=head$next_unit_ordinal,
      next_unit_ordinal=head$next_unit_ordinal+nrow(units),next_unused_unit_stream=stream,
      RNG=c("L'Ecuyer-CMRG",'Inversion','Rejection'))
    verify(registry$predecessor_head_md5); save_atomic(registry,path)
  }
  registry <- readRDS(path); stopifnot(identical(registry$manifest,binding))
  next_head <- list(registry=path,registry_md5=tools::md5sum(path),
    preceding_registry_md5=registry$predecessor$registry_md5,
    last_reserved_unit_ordinal=registry$next_unit_ordinal-1L,
    next_unit_ordinal=registry$next_unit_ordinal,epoch=registry$epoch,
    note='80 null-bootstrap feasibility draws reserved before generation; no outer coverage sample.')
  head <- readRDS(head_path)
  if(identical(head,registry$predecessor)) save_atomic(next_head,head_path) else
    stopifnot(identical(head,next_head))
  registry
}

context <- function(fit) {
  cfg <- fit$config; cfg$estimation_control$mml_integration <- 'adaptive'
  cfg$estimation_control$quad_points <- controls$order
  sizes <- mfrmr:::build_param_sizes(cfg)
  category <- mfrmr:::audit_mfrm_category_support(fit$prep,cfg,sizes)
  if(!identical(category$readiness$CategoryState,'adequate'))
    stop(paste('Category support:',category$readiness$CategoryState))
  idx <- mfrmr:::build_indices(fit$prep,cfg$step_facet,cfg$slope_facet,
    cfg$interaction_specs,gpcm_spec=cfg$gpcm_spec)
  evaluator <- function(q) {
    config <- cfg; config$estimation_control$quad_points <- q
    mfrmr:::make_mfrm_direct_evaluator('MML',
      mfrmr:::make_param_cache(sizes,config,idx,is_mml=TRUE),idx,config,sizes,
      mfrmr:::gauss_hermite_normal(q))
  }
  list(fit=fit,cfg=cfg,sizes=sizes,idx=idx,ctx=rsm_lr_boundary_context(fit),
    low=evaluator(controls$order),high=evaluator(controls$reference_order))
}
check_full <- function(e,p,code) {
  a <- e$low$gradient(p); b <- e$high$gradient(p)
  x <- data.frame(NLL=e$low$value(p),OptimizerCode=code,
    MaxGradient=max(abs(a)),ReferenceGradient=max(abs(b)),
    NLLChange=abs(e$low$value(p)-e$high$value(p)),GradientChange=max(abs(a-b)))
  x$Passed <- isTRUE(code==0L && all(is.finite(unlist(x))) &&
    x$NLLChange<=controls$nll && max(x$MaxGradient,x$ReferenceGradient,x$GradientChange)<=controls$gradient)
  x
}
constrained <- function(e,v,warm,zero) {
  if(v==0) return(list(parameters=c(zero$eta,-Inf),nll=zero$nll,
    continuous=list(value=zero$nll,summed_relative_error=0),hessian=NULL,attempts=NULL))
  contrast <- c(rep(0,length(warm)-1L),1)
  attempts <- lapply(list(warm=warm,neutral=rep(0,length(warm))),function(p)
    mfrmr:::mfrm_gpcm_profile_nuisance(e$low,e$high,p,contrast,log(v),controls$maxit))
  checks <- do.call(rbind,lapply(attempts,`[[`,'check'))
  if(!all(checks$Passed) || diff(range(checks$NLL))>controls$nll)
    return(list(passed=FALSE,attempts=attempts,reason='Constrained two-start checks failed.'))
  p <- attempts[[which.min(checks$NLL)]]$parameters
  map <- mfrmr:::mfrm_gpcm_profile_constraint(p,contrast,log(v))
  H <- optimHess(p[map$free],function(z)e$high$value(map$embed(z)),
    function(z)drop(crossprod(map$basis,e$high$gradient(map$embed(z)))))
  continuous <- rsm_lr_continuous_value(e$ctx,head(p,-1L),v)
  stopifnot(abs(tail(p,1L)-log(v))<=1e-10,
    min(eigen(H,symmetric=TRUE,only.values=TRUE)$values)>0,
    abs(continuous$value-min(checks$NLL))+continuous$summed_relative_error<=controls$nll)
  list(passed=TRUE,parameters=p,nll=min(checks$NLL),continuous=continuous,hessian=H,attempts=attempts)
}
unrestricted <- function(e,warm,zero) {
  if(!is.finite(tail(warm,1L))) warm[length(warm)] <- log(.75)
  attempts <- lapply(list(warm=warm,neutral=rep(0,length(warm))),function(start) {
    opt <- mfrmr:::run_mfrm_direct_optimization(start,'MML',e$idx,e$cfg,e$sizes,
      controls$order,controls$maxit,controls$reltol,optimizer='BFGS',suppress_convergence_warning=TRUE)
    p <- opt$par; check <- check_full(e,p,opt$convergence); polish <- NULL
    if(opt$convergence==0L && max(check$MaxGradient,check$ReferenceGradient)>controls$gradient) {
      polish <- mfrmr:::mfrm_optimizer_curvature_proposal(p,e$low$value,e$low$gradient)
      if(!is.null(polish$par)) p <- polish$par
      check <- check_full(e,p,opt$convergence)
    }
    list(parameters=p,check=check,opt=opt,polish=polish)
  })
  checks <- do.call(rbind,lapply(attempts,`[[`,'check'))
  if(!all(checks$Passed) || diff(range(checks$NLL))>controls$nll)
    return(list(passed=FALSE,attempts=attempts,reason='Unrestricted two-start checks failed.'))
  p <- attempts[[which.min(checks$NLL)]]$parameters
  continuous <- rsm_lr_continuous_value(e$ctx,head(p,-1L),exp(tail(p,1L)))
  stopifnot(abs(continuous$value-min(checks$NLL))+continuous$summed_relative_error<=controls$nll)
  if(zero$nll-continuous$value>controls$boundary_margin+continuous$summed_relative_error) {
    H <- optimHess(p,e$high$value,e$high$gradient)
    stopifnot(min(eigen(H,symmetric=TRUE,only.values=TRUE)$values)>0)
    return(list(passed=TRUE,kind='interior',parameters=p,nll=min(checks$NLL),
      continuous=continuous,hessian=H,attempts=attempts))
  }
  if(zero$natural_variance_score<=-controls$boundary_margin &&
      all(abs(checks$NLL-zero$nll)<=controls$nll)) return(list(passed=TRUE,kind='zero',
    parameters=c(zero$eta,-Inf),nll=zero$nll,
    continuous=list(value=zero$nll,summed_relative_error=0),attempts=attempts,
    positive_candidate_continuous=continuous))
  list(passed=FALSE,attempts=attempts,reason='Interior/zero selection is unresolved.',continuous=continuous)
}
review <- function(null,full,v) {
  if(identical(null$passed,FALSE)) stop(null$reason)
  if(!isTRUE(full$passed)) stop(full$reason)
  raw <- 2*(null$continuous$value-full$continuous$value)
  error <- 2*(null$continuous$summed_relative_error+full$continuous$summed_relative_error)
  stopifnot(is.finite(raw),raw>=-2*controls$nll-error)
  structural_zero <- v==0 && full$kind=='zero'
  if(structural_zero) stopifnot(raw==0)
  list(LR=max(0,raw),RawLR=raw,IntegrationAllowance=error,
    NumericalAllowance=if(structural_zero) 0 else 2*controls$nll+error,
    StructuralZero=structural_zero,UnrestrictedKind=full$kind)
}
generate <- function(fit,eta,v,stream) {
  RNGkind("L'Ecuyer-CMRG",normal.kind='Inversion',sample.kind='Rejection')
  assign('.Random.seed',stream,.GlobalEnv)
  z <- rsm_lr_boundary_eval(rsm_lr_boundary_context(fit),eta)
  standard_normal <- rnorm(fit$config$n_person); uniform <- runif(nrow(fit$prep$data))
  logits <- z$logits+outer(sqrt(v)*standard_normal[as.integer(fit$prep$data$Person)],0:3)
  peak <- apply(logits,1L,max); probability <- exp(logits-peak)
  probability <- probability/rowSums(probability)
  scores <- as.integer(pmin(rowSums(uniform>t(apply(probability,1L,cumsum))),3))
  stopifnot(all(is.finite(probability)),all(probability>0),max(abs(rowSums(probability)-1))<1e-12)
  package_agrees <- NA
  if(v>0) {
    template <- fit; template$opt$par <- c(eta,log(v))
    assign('.Random.seed',stream,.GlobalEnv)
    existing <- mfrmr:::mfrm_gpcm_bootstrap_generate(template,NULL)
    package_agrees <- identical(as.integer(existing$Score),scores)
    stopifnot(package_agrees)
  } else stopifnot(max(abs(probability-z$probability))<1e-14)
  list(scores=scores,standard_normal=standard_normal,uniform=uniform,
    stream=stream,package_agrees=package_agrees)
}
run_unit <- function(k,b,registry) {
  row <- cases[k,]; i <- row$PriorCase; v <- row$NullVariance
  key <- sprintf('case-%02d-draw-%03d',k,b)
  result_path <- file.path(out,paste0(key,'-result.rds'))
  if(file.exists(result_path)) {
    x <- readRDS(result_path); stopifnot(identical(x$binding,binding)); return(x)
  }
  fit <- readRDS(fit_paths[i])$payload$value
  observed <- readRDS(file.path(prior,sprintf('case-%02d.rds',i)))
  input_key <- paste0(key,'-input')
  if(b>0L) {
    parent <- run_unit(k,0L,registry)
    if(parent$status!='computed') {
      x <- list(status='observed_null_unavailable',reason=parent$reason,binding=binding,case=k,draw=b)
      save_atomic(x,result_path); return(x)
    }
    null <- require_phase(readRDS(file.path(out,sprintf('case-%02d-draw-000-null.rds',k))))
    at <- which(registry$units$Case==k & registry$units$Draw==b); stopifnot(length(at)==1L)
    input <- phase(input_key,tools::md5sum(file.path(out,
      c('rng-registry.rds',sprintf('case-%02d-draw-000-null.rds',k)))),function()
        generate(fit,head(null$parameters,-1L),v,registry$streams[[at]]))
    if(!nzchar(input$error)) {
      fit$prep$data$Score <- input$value$scores; fit$prep$data$score_k <- input$value$scores
    }
    dependency <- hash_phase(input_key)
  } else dependency <- c(tools::md5sum(fit_paths[i]),
    tools::md5sum(file.path(prior,sprintf('case-%02d.rds',i))))
  result <- tryCatch({
    if(b>0L) require_phase(input)
    e <- context(fit)
    zero_key <- paste0(key,'-zero')
    zero <- phase(zero_key,dependency,function() {
      z <- if(b==0L) readRDS(selected_paths[i])$payload$zero$value else rsm_lr_boundary_zero(e$ctx)
      stopifnot(z$qualified,abs(rsm_lr_boundary_eval(e$ctx,z$eta)$value-z$nll)<=1e-8); z
    })
    z <- require_phase(zero)
    null_key <- paste0(key,'-null')
    null <- phase(null_key,hash_phase(zero_key),function()
      constrained(e,v,observed$source$parameters,z))
    n <- require_phase(null); if(identical(n$passed,FALSE)) stop(n$reason)
    free_key <- paste0(key,'-free')
    free <- phase(free_key,hash_phase(null_key),function() {
      if(b==0L) return(list(passed=TRUE,kind='interior',parameters=observed$source$parameters,
        nll=observed$source$check$NLL,continuous=observed$source$continuous,reused=TRUE))
      unrestricted(e,n$parameters,z)
    })
    terminal_key <- paste0(key,'-review')
    terminal <- phase(terminal_key,c(hash_phase(null_key),hash_phase(free_key)),function()
      review(n,require_phase(free),v))
    list(status='computed',reason='',review=require_phase(terminal))
  },error=function(err) list(status='unavailable',reason=conditionMessage(err)))
  result$binding <- binding; result$case <- k; result$draw <- b
  save_atomic(result,result_path)
  cat(sprintf('%s: %s %s\n',key,result$status,result$reason)); flush.console(); result
}
summarize <- function() {
  trials <- summary <- list()
  for(k in cases$Case) {
    obs_path <- file.path(out,sprintf('case-%02d-draw-000-result.rds',k))
    if(!file.exists(obs_path)) next
    obs <- readRDS(obs_path); values <- rep(NA_real_,controls$B)
    for(b in 1:controls$B) {
      path <- file.path(out,sprintf('case-%02d-draw-%03d-result.rds',k,b))
      if(!file.exists(path)) next
      x <- readRDS(path); stopifnot(identical(x$binding,binding))
      ambiguous <- FALSE
      if(x$status=='computed' && obs$status=='computed') {
        d <- x$review$LR-obs$review$LR
        allowance <- x$review$NumericalAllowance+obs$review$NumericalAllowance
        tie <- x$review$StructuralZero && obs$review$StructuralZero
        ambiguous <- abs(d)<=allowance && !tie
        if(!ambiguous) values[b] <- x$review$LR
      }
      trials[[length(trials)+1L]] <- data.frame(Case=k,Draw=b,Status=x$status,
        Reason=x$reason,LR=if(is.null(x$review)) NA_real_ else x$review$LR,
        StructuralZero=isTRUE(x$review$StructuralZero),NumericallyAmbiguous=ambiguous)
    }
    if(obs$status=='computed') {
      s <- mfrmr:::mfrm_gpcm_bootstrap_test(values,obs$review$LR)
      s$Case <- k; s$N <- cases$N[k]; s$NullVariance <- cases$NullVariance[k]
      s$Use <- 'Feasibility only; no confirmatory significance or coverage decision.'
      summary[[length(summary)+1L]] <- s
    }
  }
  trials <- if(length(trials)) do.call(rbind,trials) else data.frame()
  summary <- if(length(summary)) do.call(rbind,summary) else data.frame()
  phases <- list.files(out,'-(input|zero|null|free|review)[.]rds$',full.names=TRUE)
  accounting <- do.call(rbind,lapply(phases,function(f) {
    x <- readRDS(f); data.frame(File=basename(f),Seconds=x$elapsed,Error=x$error)
  }))
  refusal <- readRDS(file.path(prior,'case-06.rds'))
  stopifnot(refusal$status=='source_refused')
  save_atomic(list(summary=summary,trials=trials,phases=accounting,
    source_refusal=refusal,manifest=tools::md5sum(manifest_path),
    phase_hashes=tools::md5sum(phases),
    result_hashes=tools::md5sum(list.files(out,'-result[.]rds$',full.names=TRUE))),file.path(out,'summary.rds'))
  write.csv(summary,file.path(out,'summary.csv'),row.names=FALSE)
  write.csv(trials,file.path(out,'trials.csv'),row.names=FALSE)
  write.csv(accounting,file.path(out,'phase-accounting.csv'),row.names=FALSE)
  print(summary); invisible(summary)
}
args <- commandArgs(TRUE); action <- if(length(args)) args[1] else 'summarize'
stopifnot(action %in% c('freeze','run','summarize'))
if(action=='freeze') {reserve(); cat('Frozen: four cases, 20 draws each; no responses generated.\n')}
if(action=='run') {
  registry <- reserve()
  chosen <- if(length(args)>1L) as.integer(args[2]) else cases$Case
  draws <- if(length(args)>2L) as.integer(args[3]) else seq_len(controls$B)
  stopifnot(all(chosen %in% cases$Case),all(draws %in% 0:controls$B))
  for(k in chosen) for(b in draws) run_unit(k,b,registry)
  summarize()
}
if(action=='summarize') summarize()
