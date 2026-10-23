# All retained stationarity refusals, under the frozen historical GMFRM source.
# Rscript --vanilla <this file> freeze | run | summarize
script <- 'inst/validation/gmfrm-stationarity-continuation-20261010.R'
out <- 'validation-results/gmfrm-stationarity-continuation-20261010'
audit_path <- 'validation-results/gmfrm-interval-disposition-20261010/review.rds'
old_root <- 'validation-results/mfrm-wide-map-d-historical-two-family-r50-20261006'
archive <- file.path(old_root, 'scoring-source-v2')
proof_path <- file.path(old_root, 'complete-n60-summary/fresh-replay.rds')
reference_path <- 'tests/testthat/helper-gmfrm-information.R'
args <- commandArgs(trailingOnly=TRUE)
stopifnot(length(args)==1L, args %in% c('freeze','run','summarize'))
pkgload::load_all(archive,quiet=TRUE,compile=FALSE,helpers=FALSE)
fn <- function(n) get(n, envir=asNamespace('mfrmr'))
source(reference_path)
helpers <- c(paste0('inst/validation/mfrm-wide-map-',
  c('mml-stages','jml-stages','output-summary','multi-output'),'-20261001.R'),
  'inst/validation/mfrm-wide-map-d-output-20261005.R')
for (p in helpers) source(file.path(archive,p))
save <- function(x,p) {
  temp <- tempfile(basename(p),tmpdir=dirname(p)); on.exit(unlink(temp))
  saveRDS(x,temp); stopifnot(file.rename(temp,p)); invisible(x)
}
check_hash <- function(h) stopifnot(length(h)>0L,!anyNA(h),
  identical(unname(tools::md5sum(names(h))),unname(h)))
old <- readRDS(proof_path)$Runtime
historical <- old$source[grepl('^(R/|src/|DESCRIPTION$|NAMESPACE$)',names(old$source))]
names(historical) <- file.path(archive,names(historical)); check_hash(historical)
stopifnot(identical(R.version.string,old$R),identical(R.version$platform,old$platform),
  identical(vapply(names(old$dependencies),function(p) as.character(packageVersion(p)),''),old$dependencies),
  identical(Sys.getenv(names(old$threads)),old$threads),
  unname(tools::md5sum(getLoadedDLLs()[['mfrmr']][['path']])) == unname(old$source['loaded:mfrmr']))
sources <- tools::md5sum(c(names(historical),file.path(archive,helpers),script,reference_path))
manifest_path <- file.path(out,'manifest.rds')
if(args=='freeze') {
  stopifnot(!file.exists(manifest_path))
  audit <- readRDS(audit_path); check_hash(audit$inputs_and_source)
  plan <- audit$refusals[audit$refusals$FirstFailedCheck=='Stationary local maximum',]
  rownames(plan) <- NULL
  stopifnot(nrow(plan)==32L,all(plan$OptimizerPass))
  plan$Job <- sprintf('n%d-r%03d',plan$N,plan$Replicate)
  plan$ManifestPath <- file.path(dirname(plan$FitPath),'manifest.rds')
  inputs <- tools::md5sum(unique(c(audit_path,proof_path,plan$FitPath,
    plan$SelectedPath,plan$ManifestPath)))
  check_hash(inputs)
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  m <- list(plan=plan,inputs=inputs,sources=sources,runtime=old,
    protocol=list(proposal='One existing guarded curvature proposal, then the existing optimizer.',
      controls='Saved order, maxit, reltol and optimizer. No extra retries or new data.',
      reference=c(nll_per_person=1e-6,scaled_score=1e-4,relative_covariance=1e-3),
      targets='All 20 existing location/contrast/log-slope intervals; original refusals and other 468 cases retained.',
      scope='Numerical development continuation only, not public implementation or independent coverage qualification.'),
    session=capture.output(sessionInfo()))
  save(m,manifest_path); cat('Frozen all 32 retained stationarity cases.\n')
  quit(save='no')
}
m <- readRDS(manifest_path); check_hash(m$inputs); check_hash(m$sources)
stopifnot(identical(sources,m$sources))
seal <- tools::md5sum(manifest_path)
phase <- function(dir,name,compute) {
  p <- file.path(dir,paste0(name,'.rds'))
  binding <- list(manifest=seal,job=basename(dir),phase=name)
  if(file.exists(p)) {
    x <- readRDS(p)
    stopifnot(identical(x$binding,binding),identical(x$checksum,wide_mml_hash(x$payload)))
    return(x$payload)
  }
  value <- wide_mml_capture(compute)
  save(list(binding=binding,checksum=wide_mml_hash(value),payload=value),p)
  value
}
if(args=='run') for(i in seq_len(nrow(m$plan))) {
  j <- m$plan[i,]; dir <- file.path(out,j$Job)
  dir.create(dir,recursive=TRUE,showWarnings=FALSE)
  result_path <- file.path(dir,'result.rds')
  if(file.exists(result_path)) next
  fit <- readRDS(j$FitPath)$payload$value
  selected <- readRDS(j$SelectedPath)$payload
  spec <- readRDS(j$ManifestPath)$payload$spec
  stopifnot(!is.null(spec),identical(wide_mml_hash(spec),selected$spec_hash))
  problem <- do.call(fn('mfrm_gmfrm_problem'),fit$gmfrm$specification)
  common <- problem$common; config <- fit$config
  q <- config$estimation_control$quad_points
  evaluate <- fn('mfrmr_make_adaptive_mml_evaluator')(common$idx,config,common$sizes,q)
  at <- evaluate(fit$opt$par)
  stopifnot(abs(at$value-fit$opt$value)<1e-7)
  proposal <- phase(dir,'proposal',function()
    fn('mfrm_optimizer_curvature_proposal')(fit$opt$par,
      function(p)evaluate(p)$value,function(p)evaluate(p)$gradient))
  fitted <- joint <- reference <- NULL
  if(!nzchar(proposal$error) && !is.null(proposal$value$par)) {
    fitted <- phase(dir,'fitted',function() {
      control <- config$estimation_control
      opt <- fn('run_mfrm_optimization')(proposal$value$par,'MML',common$idx,config,
        common$sizes,q,control$maxit,control$reltol,optimizer=fit$opt$optimizer_plan$Used)
      stopifnot(opt$value<=fit$opt$value+64*.Machine$double.eps*max(1,abs(fit$opt$value)))
      opt$mml_engine <- fit$opt$mml_engine
      opt$research_continuation <- list(original=tools::md5sum(j$FitPath),
        proposal=tools::md5sum(file.path(dir,'proposal.rds')))
      fn('mfrm_gmfrm_assemble_fit')(problem,config,opt,fit$gmfrm$controls,
        fn('mfrmr_nonlinear_transformation_audit')(opt$par,common$sizes,config,'log_slopes'))
    })
    if(!nzchar(fitted$error)) {
      new <- fitted$value
      joint <- phase(dir,'joint',function()fn('mfrm_gpcm_product_inference')(new))
      if(!nzchar(joint$error) && isTRUE(joint$value$check$eligible)) {
        reference <- phase(dir,'reference',function() {
          par <- new$opt$par
          params <- fn('expand_params')(par,common$sizes,config)
          basis <- fn('mfrmr_adaptive_quadrature_basis')(common$idx,config,params,
            fn('gauss_hermite_normal')(2L*q-1L),fn('compute_base_eta')(common$idx,params,config))
          literal <- gmfrm_louis_reference(new$gmfrm$specification,par,basis$nodes,basis$log_weights)
          H <- literal$information; ch <- chol(H); V <- chol2inv(ch)
          H0 <- joint$value$information$hessian; C <- chol(H0)
          actual <- evaluate(par)
          d <- actual$gradient+colSums(literal$scores)
          errors <- c(nll_per_person=abs(actual$value+sum(literal$log_marginal))/nrow(literal$scores),
            scaled_score=sqrt(max(0,drop(crossprod(d,V%*%d)))),
            relative_covariance=norm(C%*%(V-joint$value$covariance)%*%t(C),'2'))
          list(passed=all(errors<=m$protocol$reference),errors=errors,
            smallest_curvature=min(eigen(H,symmetric=TRUE,only.values=TRUE)$values),literal=literal)
        })
      }
    }
  }
  admitted <- !is.null(reference) && !nzchar(reference$error) && isTRUE(reference$value$passed)
  intervals <- NULL
  if(admitted) {
    intervals <- phase(dir,'intervals',function() {
      consume <- wide_d_consumers(new,joint)
      z <- lapply(spec$outputs,function(consumer) {
        value <- consume(new,consumer,spec$level)
        wide_multi_interval_table(value,spec,consumer,new)
      })
      table <- do.call(rbind,z); rownames(table)<-NULL
      stopifnot(nrow(table)==20L,all(table$Available))
      table
    })
    admitted <- !nzchar(intervals$error)
  }
  reason <- if(admitted) '' else if(nzchar(proposal$error)) proposal$error else
    if(is.null(proposal$value$par)) proposal$value$error else
    if(nzchar(fitted$error)) fitted$error else if(nzchar(joint$error)) joint$error else
    if(!isTRUE(joint$value$check$eligible)) joint$value$check$review else
    if(nzchar(reference$error)) reference$error else if(!isTRUE(reference$value$passed))
      'Independent reference checks failed.' else intervals$error
  files <- list.files(dir,'[.]rds$',full.names=TRUE)
  result <- list(job=j,manifest=seal,admitted=admitted,reason=reason,
    old_nll=fit$opt$value,new_nll=if(!is.null(fitted)&&!nzchar(fitted$error))fitted$value$opt$value else NA_real_,
    intervals=if(admitted)intervals$value else NULL,phases=tools::md5sum(files))
  save(result,result_path)
  cat(j$Job,if(admitted)'admitted' else reason,'\n'); flush.console()
}
if(args=='summarize') {
  paths <- file.path(out,m$plan$Job,'result.rds'); stopifnot(all(file.exists(paths)))
  results <- lapply(paths,readRDS)
  for(i in seq_along(results)) {
    x <- results[[i]]; check_hash(x$phases)
    stopifnot(identical(x$manifest,seal),identical(x$job,m$plan[i,]))
  }
  rows <- do.call(rbind,lapply(results,function(x)data.frame(N=x$job$N,
    Replicate=x$job$Replicate,Admitted=x$admitted,Reason=x$reason,
    ObjectiveChange=x$new_nll-x$old_nll)))
  save(list(rows=rows,results=results,manifest=seal,files=tools::md5sum(paths)),file.path(out,'summary.rds'))
  write.csv(rows,file.path(out,'summary.csv'),row.names=FALSE)
  print(with(rows,table(N,Admitted))); cat('All 32 continuation attempts accounted for.\n')
}
check_hash(m$inputs); check_hash(m$sources)
