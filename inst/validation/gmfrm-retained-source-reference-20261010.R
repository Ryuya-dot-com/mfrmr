# Apply the curvature candidate's exact independent-reference gates to saved-source reuse too.
script <- 'inst/validation/gmfrm-retained-source-reference-20261010.R'
out <- 'validation-results/gmfrm-retained-source-reuse-20261010'
path <- file.path(out,'summary.rds'); s<-readRDS(path)
m<-readRDS('validation-results/gmfrm-stationarity-continuation-20261010/manifest.rds')
check<-function(h)stopifnot(identical(unname(tools::md5sum(names(h))),unname(h)))
check(s$files);check(m$sources);check(m$inputs)
archive<-'validation-results/mfrm-wide-map-d-historical-two-family-r50-20261006/scoring-source-v2'
pkgload::load_all(archive,quiet=TRUE,compile=FALSE,helpers=FALSE)
stopifnot(identical(R.version.string,m$runtime$R),
  identical(Sys.getenv(names(m$runtime$threads)),m$runtime$threads))
source('tests/testthat/helper-gmfrm-information.R')
fn<-function(n)get(n,asNamespace('mfrmr'))
rows<-lapply(Filter(function(x)x$admitted,s$results),function(x) {
  fit<-readRDS(x$job$LaterFit)$payload$value
  c<-do.call(fn('mfrm_gmfrm_problem'),fit$gmfrm$specification)$common
  config<-fit$config; q<-config$estimation_control$quad_points; par<-fit$opt$par
  params<-fn('expand_params')(par,c$sizes,config)
  basis<-fn('mfrmr_adaptive_quadrature_basis')(c$idx,config,params,
    fn('gauss_hermite_normal')(2L*q-1L),fn('compute_base_eta')(c$idx,params,config))
  ref<-gmfrm_louis_reference(fit$gmfrm$specification,par,basis$nodes,basis$log_weights)
  H<-ref$information; V<-chol2inv(chol(H)); C<-chol(x$joint$value$information$hessian)
  actual<-fn('mfrmr_make_adaptive_mml_evaluator')(c$idx,config,c$sizes,q)(par)
  d<-actual$gradient+colSums(ref$scores)
  errors<-c(nll_per_person=abs(actual$value+sum(ref$log_marginal))/nrow(ref$scores),
    scaled_score=sqrt(max(0,drop(crossprod(d,V%*%d)))),
    relative_covariance=norm(C%*%(V-x$joint$value$covariance)%*%t(C),'2'))
  data.frame(Job=x$job$Job,N=x$job$N,Replicate=x$job$Replicate,
    Passed=all(errors<=m$protocol$reference),t(errors),check.names=FALSE)
})
rows<-do.call(rbind,rows);rownames(rows)<-NULL
binding<-tools::md5sum(c(path,script,'tests/testthat/helper-gmfrm-information.R',
  'validation-results/gmfrm-stationarity-continuation-20261010/manifest.rds',names(s$files)))
result<-list(rows=rows,criteria=m$protocol$reference,inputs_and_source=binding)
target<-file.path(out,'independent-reference.rds')
if(file.exists(target))stopifnot(identical(readRDS(target),result))else saveRDS(result,target)
check(binding); print(rows,row.names=FALSE)
