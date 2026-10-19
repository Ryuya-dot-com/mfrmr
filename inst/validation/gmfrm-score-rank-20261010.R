# Isolate the empirical-score-rank policy from the observed-information method.
# Reuse all 50 originally selected N20 point fits; no optimization or new data.
script <- 'inst/validation/gmfrm-score-rank-20261010.R'
out <- 'validation-results/gmfrm-score-rank-20261010'
candidate <- file.path(out, 'candidate-source/R/core-gpcm-product-slopes.R')
original_root <- 'validation-results/mfrm-wide-map-d-historical-two-family-r50-20261006'
archive <- file.path(original_root, 'scoring-source-v2')
proof_path <- file.path(original_root, 'complete-n60-summary/fresh-replay.rds')
reference_path <- 'tests/testthat/helper-gmfrm-information.R'
mode <- commandArgs(trailingOnly=TRUE)
stopifnot(length(mode)==1L, mode %in% c('freeze','run','summarize'))
pkgload::load_all(archive, quiet=TRUE, compile=FALSE, helpers=FALSE)
fn <- function(n) get(n, asNamespace('mfrmr'))
helpers <- c(paste0('inst/validation/mfrm-wide-map-',
  c('mml-stages','jml-stages','output-summary','multi-output'),'-20261001.R'),
  'inst/validation/mfrm-wide-map-d-output-20261005.R')
for (p in helpers) source(file.path(archive,p))
source(reference_path)
check <- function(h) stopifnot(length(h)>0L, !anyNA(h),
  identical(unname(tools::md5sum(names(h))),unname(h)))
old <- readRDS(proof_path)$Runtime
historical <- old$source[grepl('^(R/|src/|DESCRIPTION$|NAMESPACE$)',names(old$source))]
names(historical) <- file.path(archive,names(historical)); check(historical)
stopifnot(identical(R.version.string,old$R),identical(R.version$platform,old$platform),
  identical(vapply(names(old$dependencies),function(p)as.character(packageVersion(p)),''),old$dependencies),
  identical(Sys.getenv(names(old$threads)),old$threads),
  unname(tools::md5sum(getLoadedDLLs()[['mfrmr']][['path']]))==unname(old$source['loaded:mfrmr']))
# Only the candidate function is evaluated in a private environment. All other
# bodies, including information and consumers, are the verified historical code.
context <- new.env(parent=asNamespace('mfrmr'))
expressions <- parse(candidate)
selected <- Filter(function(e)is.call(e) && identical(e[[1]],as.name('<-')) &&
  identical(e[[2]],as.name('mfrm_gpcm_product_inference')),as.list(expressions))
stopifnot(length(selected)==1L); eval(selected[[1]],context)
for (n in c('fit_mfrm','run_mfrm_optimization','mfrm_gmfrm_adaptive_fit','mfrm_gmfrm_em'))
  trace(n,tracer=quote(stop('Saved-source rank review must not fit.')),
    where=asNamespace('mfrmr'),print=FALSE)
manifest_path <- file.path(out,'manifest.rds')
if(mode=='freeze') {
  stopifnot(!file.exists(manifest_path))
  plan <- data.frame(Replicate=seq_len(50L))
  plan$Job <- sprintf('n20-r%03d',plan$Replicate)
  dirs <- file.path(original_root,'n20-sd1-common',sprintf('job-%03d',plan$Replicate))
  plan$Selected <- file.path(dirs,'selected.rds')
  plan$Manifest <- file.path(dirs,'manifest.rds')
  plan$Original <- file.path(dirs,'d-outputs.rds')
  plan$Fit <- vapply(plan$Selected,function(p) {
    s<-readRDS(p)$payload
    file.path(dirname(p),paste0(sub(':.*$','',s$point$stage),'-fit.rds'))
  },'')
  inputs<-tools::md5sum(c(proof_path,plan$Selected,plan$Manifest,plan$Original,plan$Fit))
  check(inputs)
  m<-list(plan=plan,inputs=inputs,
    sources=tools::md5sum(c(names(historical),file.path(archive,helpers),candidate,script,reference_path)),
    runtime=old,session=capture.output(sessionInfo()),
    protocol=list(selection='All 50 previously selected point sources, regardless of readiness; never select by interval outcome or truth. No retries, refitting, new data or changes to original design exclusions.',
      change='Remove full empirical Person-score rank as a prerequisite for inverse-observed-information intervals; preserve all other gates and report deficient rank.',
      reference=c(nll_per_person=1e-6,scaled_score=1e-4,relative_covariance=1e-3),
      targets='All 20 retained location/contrast/log-slope targets, when eligible.',
      scope='New-procedure numerical development evidence, not independent coverage qualification.'))
  wide_mml_save(m,manifest_path); cat('Frozen 50 original selected N20 sources.\n')
  quit(save='no')
}
m<-readRDS(manifest_path);check(m$inputs);check(m$sources)
seal<-tools::md5sum(manifest_path)
if(mode=='run') for(i in seq_len(nrow(m$plan))) {
  j<-m$plan[i,]; path<-file.path(out,paste0(j$Job,'.rds'))
  wide_mml_phase(path,list(manifest=seal,job=j$Job),function() {
    saved<-readRDS(j$Fit)
    stopifnot(identical(saved$checksum,wide_mml_hash(saved$payload)))
    fit<-saved$payload$value
    spec<-readRDS(j$Manifest)$payload$spec
    original<-readRDS(j$Original)$payload
    stopifnot(sum(original$plan$Output=='interval')==20L,
      all(original$plan$Eligibility[original$plan$Output=='interval']=='design_excluded'))
    joint<-wide_mml_capture(function()context$mfrm_gpcm_product_inference(fit))
    returned<-!nzchar(joint$error) && isTRUE(joint$value$check$eligible)
    intervals<-reference<-NULL; reason<-joint$error
    if(returned) {
      consume<-wide_d_consumers(fit,joint)
      intervals<-do.call(rbind,lapply(spec$outputs,function(c)
        wide_multi_interval_table(suppressWarnings(consume(fit,c,spec$level)),spec,c,fit)))
      stopifnot(nrow(intervals)==20L,all(intervals$Available))
      reference<-wide_mml_capture(function() {
        c<-do.call(fn('mfrm_gmfrm_problem'),fit$gmfrm$specification)$common
        config<-fit$config; q<-config$estimation_control$quad_points; par<-fit$opt$par
        params<-fn('expand_params')(par,c$sizes,config)
        basis<-fn('mfrmr_adaptive_quadrature_basis')(c$idx,config,params,
          fn('gauss_hermite_normal')(2L*q-1L),fn('compute_base_eta')(c$idx,params,config))
        ref<-gmfrm_louis_reference(fit$gmfrm$specification,par,basis$nodes,basis$log_weights)
        V<-chol2inv(chol(ref$information)); C<-chol(joint$value$information$hessian)
        actual<-fn('mfrmr_make_adaptive_mml_evaluator')(c$idx,config,c$sizes,q)(par)
        d<-actual$gradient+colSums(ref$scores)
        errors<-c(nll_per_person=abs(actual$value+sum(ref$log_marginal))/nrow(ref$scores),
          scaled_score=sqrt(max(0,drop(crossprod(d,V%*%d)))),
          relative_covariance=norm(C%*%(V-joint$value$covariance)%*%t(C),'2'))
        list(errors=errors,passed=all(errors<=m$protocol$reference),
          min_information_eigenvalue=min(eigen(ref$information,symmetric=TRUE,only.values=TRUE)$values),
          information=ref$information)
      })
    } else if(!nzchar(reason)) reason<-joint$value$check$review
    verified<-returned && !nzchar(reference$error) && isTRUE(reference$value$passed)
    cat(j$Job,'returned:',returned,'reference:',verified,reason,'\n');flush.console()
    list(job=j,returned=returned,verified=verified,reason=reason,
      joint=joint,intervals=intervals,reference=reference)
  })
}
if(mode=='summarize') {
  paths<-file.path(out,paste0(m$plan$Job,'.rds'));stopifnot(all(file.exists(paths)))
  values<-lapply(paths,function(p) {
    x<-readRDS(p);stopifnot(identical(x$checksum,wide_mml_hash(x$payload)));x$payload
  })
  rows<-do.call(rbind,lapply(values,function(x)data.frame(Replicate=x$job$Replicate,
    Returned=x$returned,Verified=x$verified,Reason=x$reason)))
  result<-list(rows=rows,results=values,manifest=seal,files=tools::md5sum(paths))
  wide_mml_save(result,file.path(out,'summary.rds'))
  write.csv(rows,file.path(out,'summary.csv'),row.names=FALSE)
  print(with(rows,table(Returned,Verified)));print(table(rows$Reason))
}
check(m$inputs);check(m$sources)
