# Fixed-point external likelihood and full-information comparison, not a refit
# or a sampling study. Run from the retained D source with its original runtime.
pkgload::load_all('.', quiet=TRUE, compile=FALSE, helpers=FALSE)
.libPaths(c(.libPaths(), '/Library/Frameworks/R.framework/Resources/library'))
for (x in c('mml-stages','jml-stages','output-summary','multi-output'))
  source(paste0('inst/validation/mfrm-wide-map-',x,'-20261001.R'))
source('inst/validation/mfrm-wide-map-d-output-20261005.R')
source('inst/validation/mfrm-wide-map-d-response-20261005.R')
stopifnot(requireNamespace('mirt',quietly=TRUE),requireNamespace('numDeriv',quietly=TRUE))
root <- 'validation-results/mfrm-wide-map-d-retained-output-20261005'
dispatch <- readRDS(file.path(root,'dispatch.rds'))
runtime <- wide_d_runtime()
stopifnot(identical(runtime,dispatch$runtime))
row <- dispatch$rows[dispatch$rows$ConditionId=='D:historical-full-common:N240:SD1:H-both' &
  dispatch$rows$Replicate==1L,]
stopifnot(nrow(row)==1L,identical(row$Job,'job-003'))
paths <- file.path(root,row$Job,c('manifest.rds','q31-fit.rds','q31-joint-inference.rds'))
saved <- lapply(paths,readRDS)
for (x in saved) stopifnot(identical(x$checksum,wide_mml_hash(x$payload)))
manifest <- saved[[1]]$payload
stopifnot(identical(manifest$runtime,runtime),
  identical(saved[[2]]$binding,list(job=wide_mml_hash(manifest),order=31L,phase='fit',dependency=NULL)),
  identical(saved[[3]]$binding,list(job=wide_mml_hash(manifest),order=31L,
    phase='joint-inference',dependency=wide_mml_hash(saved[[2]]$payload))))
fit <- saved[[2]]$payload$value; joint <- saved[[3]]$payload$value
stopifnot(!nzchar(saved[[2]]$payload$error),!nzchar(saved[[3]]$payload$error),
  all(joint$checks$Passed),joint$information$status=='ok',
  !joint$information$regularized,joint$information$rank==22L)
# Guard against accidental native re-estimation or information recomputation.
for (n in c('fit_mfrm','compute_mml_parameter_covariance'))
  trace(n,tracer=quote(stop('Native estimation/information must be reused')),where=asNamespace('mfrmr'),print=FALSE)
theta <- fit$opt$par; params <- wide_d_fixed_normal_parameters(fit)
stopifnot(length(theta)==22L,params$K==3L,identical(params$facets,c('Task','Rater')))
dat <- fit$prep$data
grid <- expand.grid(Task=params$levels$Task,Rater=params$levels$Rater)
items <- paste(grid$Task,grid$Rater,sep='_')
response <- matrix(NA_integer_,length(levels(dat$Person)),length(items),
  dimnames=list(levels(dat$Person),items))
positions <- cbind(match(dat$Person,rownames(response)),
  match(paste(dat$Task,dat$Rater,sep='_'),items))
stopifnot(!anyNA(positions),!anyDuplicated(as.data.frame(positions)),all(dat$Weight==1),
  nrow(response)==240L,ncol(response)==18L,nrow(dat)==1440L)
response[positions] <- dat$Score
exposure <- rowSums(!is.na(response))
stopifnot(sum(exposure==3L)==192L,sum(exposure==18L)==48L,sum(!is.na(response))==nrow(dat),
  all(vapply(seq_along(items),function(i)identical(sort(unique(na.omit(response[,i]))),0:2),TRUE)))
template <- mirt::mirt(response,1,itemtype='gpcm',pars='values',verbose=FALSE)
template$lbound[template$name=='a1'] <- 0
item_rows <- lapply(items,function(x)which(template$item==x))
stopifnot(all(vapply(item_rows,function(ix)identical(template$name[ix],
  c('a1','ak0','ak1','ak2','d0','d1','d2')),TRUE)))
map <- function(x) {
  f <- fit;f$opt$par <- x;p <- wide_d_fixed_normal_parameters(f)
  a <- p$slopes$Task[grid$Task]*p$slopes$Rater[grid$Rater]
  location <- p$locations$Task[grid$Task]+p$locations$Rater[grid$Rater]
  cum <- t(apply(p$steps,1,cumsum))[match(grid$Rater,p$levels$Rater),,drop=FALSE]
  cbind(a,0,1,2,0,-a*(location+cum[,1]),-a*(2*location+cum[,2]))
}
values <- function(x) {
  out <- template;v <- map(x)
  for(i in seq_along(items))out$value[item_rows[[i]]] <- v[i,]
  out
}
rules <- lapply(c(121L,241L),mfrmr:::gauss_hermite_normal)
names(rules) <- c('121','241')
for (q in rules) stopifnot(all(q$weights>0),abs(sum(q$weights)-1)<1e-12)
technical <- list(customTheta=matrix(rules[['121']]$nodes,ncol=1L),
  customPriorFun=local({w <- rules[['121']]$weights;function(Theta,Etable)w}),
  NCYCLES=2000L,zeroExtreme=FALSE)
fixed_object <- function(x) {
  v <- values(x)
  obj <- mirt::mirt(response,1,itemtype='gpcm',pars=v,TOL=NaN,
    technical=technical,verbose=FALSE)
  stopifnot(identical(mirt::mod2values(obj)$value,v$value))
  obj
}
obj <- fixed_object(theta)
item_objects <- lapply(seq_along(items),function(i) {
  x <- mirt::extract.item(obj,i)
  stopifnot(identical(x@parnames,template$name[item_rows[[i]]]),
    identical(x@par,values(theta)$value[item_rows[[i]]]))
  x
})
probabilities <- function(x,z) {
  v <- map(x)
  lapply(seq_along(items),function(i) {
    item <- item_objects[[i]];item@par <- unname(v[i,])
    mirt::probtrace(item,matrix(z,ncol=1L))
  })
}
observed <- lapply(seq_along(items),function(i)which(!is.na(response[,i])))
objective <- function(x,q) {
  probs <- probabilities(x,q$nodes)
  ll <- matrix(0,nrow(response),length(q$nodes))
  for (i in seq_along(items)) {
    use <- observed[[i]]
    p <- t(probs[[i]][,response[use,i]+1L,drop=FALSE])
    stopifnot(all(is.finite(p)),all(p>0),all(p<=1))
    ll[use,] <- ll[use,,drop=FALSE]+log(p)
  }
  ll <- sweep(ll,2,log(q$weights),'+');offset <- apply(ll,1,max)
  -sum(offset+log(rowSums(exp(ll-offset))))
}
out <- 'validation-results/mirt-gpcm-two-family-fixed-point-20261006'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
script <- sub('^--file=','',grep('^--file=',commandArgs(),value=TRUE))
external <- sort(unique(c('mirt','numDeriv',unlist(tools::package_dependencies(
  c('mirt','numDeriv'),db=installed.packages(),recursive=TRUE),use.names=FALSE))))
external_files <- unlist(lapply(external,function(p)list.files(system.file(package=p),
  '(DESCRIPTION|[.]rdb|[.]rdx|[.]so)$',recursive=TRUE,full.names=TRUE)),use.names=FALSE)
binding <- list(runtime=runtime,inputs=tools::md5sum(c(file.path(root,'dispatch.rds'),paths)),
  script=tools::md5sum(script),parameter_map_source=tools::md5sum('inst/validation/mfrm-wide-map-d-response-20261005.R'),
  external_versions=setNames(vapply(external,function(p)as.character(packageVersion(p)),''),external),
  external_sources=tools::md5sum(external_files),quadrature=rules,response=wide_mml_hash(response),
  theta=theta,native_information=wide_mml_hash(joint),
  design=list(persons=240L,crossings=18L,ratings_per_person=table(exposure),missing_cells=sum(is.na(response))),
  derivative=list(method='Richardson',r=4L,d=c(.01,.005)),
  tolerance=c(probability=1e-12,objective=1e-7,scaled_score=1e-5,
    information=1e-3,covariance=1e-3,quadrature_information=1e-4,step_information=1e-4),
  scope='One preselected retained two-family fixed-N(0,1) point. External item probability engine; fixed qualified native Gaussian nodes. Direct derivatives in all 22 native coordinates include map curvature. No optimizer, new data, existence/globality or sampling-coverage qualification.')
stopifnot(identical(wide_mml_phase(file.path(out,'manifest.rds'),'two-family-fixed-point-v1',function()binding),binding))
target <- file.path(out,basename(script))
if(!file.exists(target))stopifnot(file.copy(script,target))
stopifnot(unname(tools::md5sum(target))==unname(binding$script))
phase <- function(name,compute)wide_mml_phase(file.path(out,paste0(name,'.rds')),binding,compute)
preflight <- phase('probability-map',function() {
  z <- c(-3,-1,0,.7,2.5)
  perturbed <- theta+.01*sin(seq_along(theta))
  native_errors <- copy_errors <- numeric(2)
  for(j in 1:2) {
    x <- if(j==1)theta else perturbed
    f <- fit;f$opt$par <- x
    native <- wide_d_response_points(f,z)$probabilities
    external <- do.call(rbind,probabilities(x,z))
    native_errors[j] <- max(abs(native-external))
    fresh <- fixed_object(x)
    copy_errors[j] <- max(abs(external-do.call(rbind,lapply(seq_along(items),function(i)
      mirt::probtrace(mirt::extract.item(fresh,i),matrix(z,ncol=1L))))))
  }
  J <- numDeriv::jacobian(function(x)as.vector(t(map(x)[,c(1,6,7)])),theta)
  list(native_errors=native_errors,private_copy_errors=copy_errors,
    map_jacobian_rank=qr(J,tol=1e-8)$rank,map_jacobian=J,
    passed=max(c(native_errors,copy_errors))<binding$tolerance['probability'] && qr(J,tol=1e-8)$rank==22L)
})
print(preflight[c('native_errors','private_copy_errors','map_jacobian_rank','passed')]);flush.console()
stopifnot(preflight$passed)
results <- list()
for (setting in list(c(121,.01),c(241,.01),c(241,.005))) {
  name <- paste0('q',setting[1],'-d',setting[2]);q <- rules[[as.character(setting[1])]]
  results[[name]] <- phase(name,function() {
    fn <- function(x)objective(x,q);started <- proc.time()
    g <- numDeriv::grad(fn,theta,method.args=list(d=setting[2],r=4L))
    H <- numDeriv::hessian(fn,theta,method.args=list(d=setting[2],r=4L))
    list(objective=fn(theta),gradient=g,information=H,
      seconds=unname((proc.time()-started)['elapsed']))
  })
  cat('Completed',name,'objective',format(results[[name]]$objective,digits=16),
    'seconds',results[[name]]$seconds,'\n');flush.console()
}
assessment <- phase('assessment',function() {
  H <- joint$information$hessian;C <- joint$covariance
  Croot <- chol(C);whiten <- function(x)norm(Croot%*%x%*%t(Croot),'2')
  native_g <- joint$information$solution_information$gradient
  rows <- do.call(rbind,lapply(names(results),function(name) {
    x <- results[[name]];e <- eigen(x$information,symmetric=TRUE,only.values=TRUE)$values
    inverse <- if(min(e)>0)solve(x$information)else matrix(NA_real_,22,22)
    data.frame(Setting=name,ObjectiveDifference=x$objective-fit$opt$value,
      ScaledScoreDifference=max(abs(drop(Croot%*%(x$gradient-native_g)))),
      InformationDifference=whiten(x$information-H),
      CovarianceDifference=norm(inverse-C,'2')/norm(C,'2'),SmallestEigenvalue=min(e))
  }))
  qdiff <- whiten(results[[1]]$information-results[[2]]$information)
  ddiff <- whiten(results[[2]]$information-results[[3]]$information)
  t <- binding$tolerance
  passed <- all(is.finite(as.matrix(rows[,-1]))) &&
    all(abs(rows$ObjectiveDifference)<t['objective']) &&
    all(rows$ScaledScoreDifference<t['scaled_score']) &&
    all(rows$InformationDifference<t['information']) &&
    all(rows$CovarianceDifference<t['covariance']) && all(rows$SmallestEigenvalue>0) &&
    qdiff<t['quadrature_information'] && ddiff<t['step_information']
  list(passed=passed,comparisons=rows,quadrature_information_change=qdiff,
    step_information_change=ddiff,scope=binding$scope,new_optimizer_runs=0L,new_datasets=0L)
})
print(assessment)
stopifnot(identical(wide_d_runtime(),runtime),
  identical(tools::md5sum(names(binding$inputs)),binding$inputs),
  identical(tools::md5sum(names(binding$external_sources)),binding$external_sources),
  assessment$passed)
cat('Fixed-point external full-information comparison passed. Sampling qualification remains separate.\n')
