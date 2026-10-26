# Adaptive endpoint feasibility on retained cases, not a public interval method.
# Use the single-threaded validation runtime. Optional argument: case number 1:6.
script <- 'inst/validation/mfrm-lr-rsm-adaptive-profile-20261010.R'
prior <- 'validation-results/mfrm-lr-rsm-profile-20261010'
accuracy <- 'validation-results/mfrm-lr-rsm-adaptive-points-20261010'
out <- 'validation-results/mfrm-lr-rsm-adaptive-profile-20261010'
verify <- function(h) stopifnot(length(h)>0L,!anyNA(h),
  identical(unname(tools::md5sum(names(h))),unname(h)))
audit_files <- c(file.path(prior,'verification.rds'),file.path(accuracy,'verification.rds'))
stopifnot(identical(unname(tools::md5sum(audit_files)),
  c('53685d88f9841801ba2848dcd1f5436f','d80f56bae9eaddad3bdb33208cbc656b')))
audits <- lapply(audit_files,readRDS)
for (a in audits) {stopifnot(a$passed); verify(a$retained)}
verify(audits[[1]]$manifest)
old <- readRDS(names(audits[[1]]$manifest)); verify(old$inputs)
cases <- lapply(file.path(prior,sprintf('case-%02d.rds',1:6)),readRDS)
fit_paths <- names(old$inputs)[endsWith(names(old$inputs),'-fit.rds')]
selected_paths <- names(old$inputs)[endsWith(names(old$inputs),'/selected.rds')]
stopifnot(length(fit_paths)==6L,length(selected_paths)==6L,
  cases[[6]]$status=='source_refused')
pkgload::load_all('.',quiet=TRUE,compile=FALSE)
source('inst/validation/mfrm-lr-rsm-boundary-20261009.R')
source_files <- c(script,'inst/validation/mfrm-lr-rsm-boundary-20261009.R',
  list.files('R',full.names=TRUE),'DESCRIPTION','NAMESPACE',
  getLoadedDLLs()[['mfrmr']][['path']])
hashes <- tools::md5sum(source_files); names(hashes)[length(hashes)] <- 'loaded_mfrmr_DLL'
common <- intersect(names(hashes),names(old$source))
stopifnot(identical(hashes[common],old$source[common]))
controls <- list(order=31L,reference_order=61L,level=.95,maxit=400L,
  max_steps=8L,initial_step=.5,nll=1e-5,gradient=1e-4,endpoint=1e-4,constraint=1e-10)
manifest <- list(inputs=old$inputs,audits=tools::md5sum(audit_files),source=hashes,
  cases=old$cases,controls=controls,session=sessionInfo(),
  threads=Sys.getenv(c('OMP_NUM_THREADS','OPENBLAS_NUM_THREADS',
    'MKL_NUM_THREADS','VECLIB_MAXIMUM_THREADS')))
stopifnot(all(manifest$threads=='1'))
dir.create(out,recursive=TRUE,showWarnings=FALSE)
manifest_path <- file.path(out,'manifest.rds')
if (file.exists(manifest_path)) stopifnot(identical(readRDS(manifest_path),manifest)) else
  saveRDS(manifest,manifest_path)
binding <- unname(tools::md5sum(manifest_path))
writeLines(capture.output(sessionInfo()),file.path(out,'session-info.txt'))
writeLines(tail(source_files,1L),file.path(out,'loaded-dll-path.txt'))

phase <- function(i,name,fn) {
  path <- file.path(out,sprintf('case-%02d-%s.rds',i,name))
  if (file.exists(path)) {
    x <- readRDS(path); stopifnot(identical(x$binding,binding),x$case==i,x$phase==name)
    return(x)
  }
  start <- proc.time()[['elapsed']]
  x <- tryCatch(list(value=fn(),error=''),error=function(e) list(value=NULL,error=conditionMessage(e)))
  x$elapsed <- proc.time()[['elapsed']]-start
  x$binding <- binding; x$case <- i; x$phase <- name
  saveRDS(x,paste0(path,'.tmp')); stopifnot(file.rename(paste0(path,'.tmp'),path))
  cat(sprintf('case-%02d %s: %.3f s%s\n',i,name,x$elapsed,
    if(nzchar(x$error)) paste(' ERROR:',x$error) else '')); flush.console()
  x
}

run_case <- function(i) {
  if (!cases[[i]]$case$Available) return(list(status='source_refused',
    reason=cases[[i]]$case$Reason,phase_seconds=0))
  fit <- readRDS(fit_paths[i])$payload$value
  selected <- readRDS(selected_paths[i])$payload
  original <- fit$opt$par
  stopifnot(identical(original,cases[[i]]$source_terminal$parameters))
  cfg <- fit$config; sizes <- mfrmr:::build_param_sizes(cfg)
  idx <- mfrmr:::build_indices(fit$prep,cfg$step_facet,cfg$slope_facet,
    cfg$interaction_specs,gpcm_spec=cfg$gpcm_spec)
  evaluator <- function(q) {
    config <- cfg; config$estimation_control$mml_integration <- 'adaptive'
    config$estimation_control$quad_points <- q
    mfrmr:::make_mfrm_direct_evaluator('MML',
      mfrmr:::make_param_cache(sizes,config,idx,is_mml=TRUE),idx,config,sizes,
      mfrmr:::gauss_hermite_normal(q))
  }
  low <- evaluator(controls$order); high <- evaluator(controls$reference_order)
  ctx <- rsm_lr_boundary_context(fit)
  contrast <- rep(0,length(original)); contrast[ctx$slices$log_sigma2] <- 1
  check_point <- function(p) {
    a <- low$gradient(p); b <- high$gradient(p)
    data.frame(NLL=low$value(p),NLLChange=abs(low$value(p)-high$value(p)),
      GradientChange=max(abs(a-b)),NativeGradient=max(abs(a)),ReferenceGradient=max(abs(b)))
  }
  integration_ok <- function(x) isTRUE(x$NLLChange<=controls$nll &&
    x$GradientChange<=controls$gradient)
  stationary <- function(x) isTRUE(integration_ok(x) &&
    x$NativeGradient<=controls$gradient && x$ReferenceGradient<=controls$gradient)
  source <- phase(i,'source',function() {
    initial <- check_point(original); p <- original; stages <- list()
    if (!integration_ok(initial)) return(list(passed=FALSE,initial=initial,
      reason='source_integration_failed',parameters=p))
    if (!stationary(initial)) {
      stages$curvature <- mfrmr:::mfrm_optimizer_curvature_proposal(p,low$value,low$gradient)
      if (!is.null(stages$curvature$par)) p <- stages$curvature$par
      if (!stationary(check_point(p))) {
        safe <- mfrmr:::make_mfrm_boundary_safe_objective(low)
        stages$bfgs <- optim(p,safe$value,safe$gradient,method='BFGS',
          control=mfrmr:::build_mfrm_optim_control('BFGS',controls$maxit,1e-13))
        p <- stages$bfgs$par
        if (!stationary(check_point(p))) {
          stages$polish <- mfrmr:::mfrm_optimizer_curvature_proposal(p,low$value,low$gradient)
          if (!is.null(stages$polish$par)) p <- stages$polish$par
        }
      }
    }
    check <- check_point(p)
    continuous <- if (identical(p,original)) cases[[i]]$source_terminal$continuous else
      rsm_lr_continuous_value(ctx,head(p,-1L),exp(tail(p,1L)))
    H <- optimHess(p,high$value,high$gradient)
    zero <- selected$zero$value
    stopifnot(isTRUE(zero$qualified),
      abs(rsm_lr_boundary_eval(ctx,zero$eta)$value-zero$nll)<=1e-8)
    source_gates <- c(integration=integration_ok(check),stationarity=stationary(check),
      optimizer=is.null(stages$bfgs) || stages$bfgs$convergence==0L,
      positive_hessian=!is.null(tryCatch(chol(H),error=function(e) NULL)),
      nonworsening=check$NLL<=initial$NLL+64*.Machine$double.eps*max(1,abs(initial$NLL)),
      continuous=abs(check$NLL-continuous$value)+continuous$summed_relative_error<=controls$nll,
      interior=zero$nll-continuous$value>1e-6+continuous$summed_relative_error)
    list(passed=all(source_gates),reason=paste(names(source_gates)[!source_gates],collapse=';'),
      initial=initial,check=check,parameters=p,stages=stages,gates=source_gates,
      hessian=H,continuous=continuous,zero_nll=zero$nll,
      zero_lr=2*(zero$nll-continuous$value),movement=max(abs(p-original)),
      original=original,evaluations=list(low=low$diagnostics(),high=high$diagnostics()))
  })
  if (nzchar(source$error) || !isTRUE(source$value$passed)) return(list(
    status='source_unavailable',reason=if(nzchar(source$error)) source$error else source$value$reason,
    source=source$value,phase_seconds=source$elapsed))
  baseline <- source$value
  search <- phase(i,'search',function() {
    x <- mfrmr:::mfrm_gpcm_profile_search(low,high,baseline$parameters,contrast,
      level=controls$level,maxit=controls$maxit,max_steps=controls$max_steps,
      initial_step=controls$initial_step)
    names(x$profile)[1:2] <- c('LogVariance','Variance')
    x$evaluations <- list(low=low$diagnostics(),high=high$diagnostics())
    x
  })
  if (nzchar(search$error)) return(list(status='profile_error',reason=search$error,
    source=baseline,phase_seconds=source$elapsed+search$elapsed))
  x <- search$value; endpoints <- x$endpoints; terminal <- list(); costs <- numeric()
  for (j in which(endpoints$Status=='computed')) {
    side <- endpoints$Side[j]; target <- log(endpoints$Bound[j])
    keys <- names(x$attempts); key <- keys[which.min(abs(as.numeric(keys)-target))]
    stopifnot(abs(as.numeric(key)-target)<=1e-12)
    attempts <- x$attempts[[key]]
    p <- attempts[[which.min(vapply(attempts,function(a)a$check$NLL,0.))]]$parameters
    checked <- phase(i,paste0('terminal-',tolower(side)),function() {
      map <- mfrmr:::mfrm_gpcm_profile_constraint(p,contrast,target)
      H <- optimHess(p[map$free],function(z) high$value(map$embed(z)),
        function(z) drop(crossprod(map$basis,high$gradient(map$embed(z)))))
      independent <- rsm_lr_continuous_value(ctx,head(p,-1L),exp(tail(p,1L)))
      error <- independent$summed_relative_error
      lr <- 2*(independent$value-baseline$continuous$value)
      free_gradient <- drop(crossprod(map$basis,high$gradient(p)))
      checks <- data.frame(ConstraintError=abs(sum(contrast*p)-target),
        IndependentNLLDifference=abs(independent$value-low$value(p)),
        NLLAllowance=error,IndependentLR=lr,CutoffError=abs(lr-x$cutoff),
        LRAllowance=2*(error+baseline$continuous$summed_relative_error),
        ReferenceGradient=max(abs(free_gradient)),
        MinimumEigenvalue=min(eigen(H,symmetric=TRUE,only.values=TRUE)$values))
      checks$Passed <- checks$ConstraintError<=controls$constraint &&
        checks$IndependentNLLDifference+checks$NLLAllowance<=controls$nll &&
        checks$CutoffError+checks$LRAllowance<=controls$endpoint &&
        checks$ReferenceGradient<=controls$gradient && checks$MinimumEigenvalue>0
      list(checks=checks,parameters=p,hessian=H,continuous=independent)
    })
    terminal[[side]] <- checked$value; costs[side] <- checked$elapsed
    if (nzchar(checked$error) || !isTRUE(checked$value$checks$Passed)) {
      endpoints$Bound[j] <- NA_real_; endpoints$Status[j] <- 'independent_terminal_failure'
    }
  }
  list(status=if(all(endpoints$Status=='computed')) 'two_numerical_endpoints' else
    'incomplete_numerical_endpoints',source=baseline,search=x,endpoints=endpoints,
    terminal=terminal,zero_in_candidate_set=baseline$zero_lr<=x$cutoff,
    phase_seconds=source$elapsed+search$elapsed+sum(costs))
}

case_rows <- function(z,i) {
  e <- z$endpoints
  if (is.null(e)) e <- data.frame(Side=c('Lower','Upper'),Bound=NA_real_,Status=z$status)
  cbind(data.frame(Case=i,ParentId=cases[[i]]$case$ParentId,N=cases[[i]]$case$N,
    Outcome=z$status,PhaseSeconds=z$phase_seconds,
    Movement=if(is.null(z$source$movement)) NA_real_ else z$source$movement,
    ZeroLR=if(is.null(z$source$zero_lr)) NA_real_ else z$source$zero_lr,
    Points=if(is.null(z$search)) 0L else nrow(z$search$profile),
    FailedPoints=if(is.null(z$search)) 0L else sum(!z$search$profile$Passed)),e)
}
args <- commandArgs(TRUE)
chosen <- if(length(args)) as.integer(args) else c(3L,1L,2L,4L,5L,6L)
stopifnot(length(chosen)>0L,!anyNA(chosen),all(chosen %in% 1:6))
for (i in chosen) {
  path <- file.path(out,sprintf('case-%02d.rds',i))
  if (file.exists(path)) {stopifnot(identical(readRDS(path)$binding,binding)); next}
  result <- run_case(i); result$binding <- binding
  saveRDS(result,paste0(path,'.tmp')); stopifnot(file.rename(paste0(path,'.tmp'),path))
  print(case_rows(result,i)); flush.console()
}
complete <- which(file.exists(file.path(out,sprintf('case-%02d.rds',1:6))))
summary <- do.call(rbind,lapply(complete,function(i)
  case_rows(readRDS(file.path(out,sprintf('case-%02d.rds',i))),i)))
write.csv(summary,file.path(out,'endpoints.csv'),row.names=FALSE)
