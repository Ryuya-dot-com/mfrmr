# Run from package root with build or replay; no fitting or simulated responses.
args <- commandArgs(trailingOnly=TRUE)
stopifnot(length(args)==1L,args %in% c('build','replay'))
pkgload::load_all('.',quiet=TRUE,compile=FALSE,helpers=FALSE)
design_source <- 'inst/validation/mfrm-dimensionality-tam-design-20261006.R'
script <- 'inst/validation/mfrm-dimensionality-tam-design-check-20261006.R'
source(design_source)
stopifnot(requireNamespace('TAM',quietly=TRUE))
out <- 'validation-results/mfrm-dimensionality-tam-design-20261006'
sources <- tools::md5sum(c(design_source,script,list.files('R','[.]R$',full.names=TRUE)))
tam_files <- list.files(find.package('TAM'),recursive=TRUE,full.names=TRUE)
tam_files <- tam_files[grepl('(/R/.*[.](rdb|rdx)$|/libs/.*[.](so|dylib)$|/DESCRIPTION$)',tam_files)]
external <- tools::md5sum(tam_files);stopifnot(length(external)>=4L,!anyNA(external))
binding <- list(source=sources,TAM=as.character(packageVersion('TAM')),external=external,
  R=R.version.string,platform=R.version$platform,tolerance=1e-12,
  scope='Eight fixed response-model maps: RSM/PCM x 1D/2D x additive/full centered interaction. No fitting, simulation, coverage, model-selection or integration qualification.')
target <- file.path(out,'check.rds')
if(args=='replay'){
  saved <- readRDS(target);stopifnot(identical(saved$binding,binding))
  before <- tools::md5sum(target)
} else stopifnot(!file.exists(target))
ns <- asNamespace('mfrmr');tam <- asNamespace('TAM')
trace('fit_mfrm',tracer=quote(stop('No fitting in design qualification.')),where=ns,print=FALSE)
trace('tam.mml',tracer=quote(stop('No fitting in design qualification.')),where=tam,print=FALSE)
native <- function(name)get(name,ns)
# Deterministic complete rectangle supplies metadata only. The four category
# endpoints/patterns are never fitted or counted as study datasets.
data <- expand.grid(Rater=as.character(1:3),Criterion=as.character(1:6),Person=as.character(1:4))
data$Score <- as.integer(data$Person)-1L
prep <- native('prepare_mfrm_data')(data,'Person',c('Rater','Criterion'),'Score',rating_min=0,rating_max=3)
grid1 <- matrix(c(-2,-.5,0,.7,2),ncol=1L)
grid2 <- as.matrix(expand.grid(D1=grid1[,1],D2=grid1[,1]))
records <- maps <- list()
for(model in c('RSM','PCM'))for(dimensions in 1:2)for(interaction in c(FALSE,TRUE)){
  map <- wide_dim_tam_design(model,dimensions,interaction)
  spec <- native('build_facet_interaction_specs')(prep,
    if(interaction)'Rater:Criterion' else NULL,min_obs_per_interaction=0,interaction_policy='silent')
  built <- native('build_estimation_config')(prep,model,'MML',
    if(model=='PCM')'Criterion' else NULL,NULL,interaction_specs=spec,weight_col=NULL,
    facet_signs=c(Rater=-1,Criterion=-1),positive_facets=character(),
    noncenter_facet='Person',dummy_facets=character(),anchor_df=NULL,group_anchor_df=NULL,population=NULL)
  config <- built$config;sizes <- built$sizes;p <- sum(unlist(sizes))
  expected <- (if(model=='RSM')9L else 19L)+if(interaction)10L else 0L
  stopifnot(p==expected,dim(map$A)[3]==p,
    qr(matrix(map$A,ncol=p))$rank==p,
    all(rowSums(map$Q)==1),all(map$A[,1,]==0),all(map$B[,1,]==0),
    !isTRUE(config$population_spec$active))
  theta <- if(dimensions==1L)grid1 else grid2
  # Include the declared truth and a perturbation in every native coordinate;
  # this prevents a coincidental match at one rank-one interaction pattern.
  par <- numeric(p);par[1:2] <- c(-.4,0);par[3:7] <- c(-.6,0,.6,-.6,0)
  if(interaction)par[8:17] <- as.vector(-.4*outer(c(-1,0),c(1,1,1,-1,-1)))
  step_truth <- if(model=='RSM')c(-.8,0) else
    rep(c(-1,0,-.8,.2,-.6,-.2),2)
  par[seq.int(p-length(step_truth)+1L,p)] <- step_truth
  points <- cbind(truth=par,sweep(diag(p)*.173,1,par,'+'))
  max_probability <- max_intercept <- max_native <- max_backend <- 0
  for(i in seq_len(ncol(points))){
    x <- points[,i];expanded <- native('expand_params')(x,sizes,config)
    step <- if(model=='RSM')matrix(expanded$steps,6L,3L,byrow=TRUE) else expanded$steps_mat
    h <- if(interaction)expanded$interactions[['Rater:Criterion']] else matrix(0,3,6)
    stopifnot(max(abs(c(rowSums(h),colSums(h))))<1e-14,
      abs(sum(expanded$facets$Rater))<1e-14,abs(sum(expanded$facets$Criterion))<1e-14,
      max(abs(rowSums(step)))<1e-14)
    idx <- list(score_k=integer(18),facets=map$cells,
      interactions=if(interaction)list('Rater:Criterion'=1:18) else list())
    base_eta <- native('compute_base_eta')(idx,expanded,config)
    oracle <- array(0,c(18L,4L,nrow(theta)));ax <- matrix(0,18,4)
    for(j in 1:18){
      r <- map$cells$Rater[j];c <- map$cells$Criterion[j]
      location <- expanded$facets$Rater[r]+expanded$facets$Criterion[c]-h[r,c]
      stopifnot(abs(base_eta[j]+location)<1e-13)
      d <- which(map$Q[j,]==1)
      ax[j,] <- c(0,cumsum(-location-step[c,]))
      for(q in seq_len(nrow(theta))){
        logits <- c(0,cumsum(theta[q,d]-location-step[c,]));mass <- exp(logits-max(logits))
        oracle[j,,q] <- mass/sum(mass)
      }
      # The native model has one ability. For 2D this checks the response
      # kernel at each designated coordinate, not a native 2D fit.
      native_probability <- if(model=='RSM')native('category_prob_rsm')(
        theta[,d]+base_eta[j],c(0,cumsum(step[c,]))) else native('category_prob_pcm')(
        theta[,d]+base_eta[j],t(apply(step,1,function(z)c(0,cumsum(z)))),rep(c,nrow(theta)))
      max_native <- max(max_native,abs(native_probability-t(oracle[j,,])))
    }
    calc <- get('tam_mml_calc_prob',tam)
    input <- list(iIndex=1:18,A=map$A,AXsi=matrix(0,18,4),B=map$B,xsi=x,
      theta=theta,nnodes=nrow(theta),maxK=4L,recalc=TRUE,maxcat=rep(4L,18))
    plain <- do.call(calc,c(input,list(use_rcpp=FALSE)))
    compiled <- do.call(calc,c(input,list(use_rcpp=TRUE)))
    max_probability <- max(max_probability,abs(plain$rprobs-oracle))
    max_intercept <- max(max_intercept,abs(plain$AXsi-ax))
    max_backend <- max(max_backend,abs(compiled$rprobs-plain$rprobs),abs(compiled$AXsi-plain$AXsi))
  }
  stopifnot(max(c(max_probability,max_intercept,max_native,max_backend))<binding$tolerance)
  key <- paste(model,dimensions,interaction,sep=':');maps[[key]] <- map
  records[[key]] <- data.frame(Model=model,Dimensions=dimensions,Interaction=interaction,
    ResponseParameters=p,CovarianceParameters=map$covariance_parameters,Points=ncol(points),
    ProbabilityDifference=max_probability,InterceptDifference=max_intercept,
    NativeKernelDifference=max_native,TAMBackendDifference=max_backend)
}
result <- list(ChecksPassed=TRUE,records=do.call(rbind,records),maps=maps,
  NewFits=0L,NewDatasets=0L,PopulationFitQualified=FALSE,IntegrationQualified=FALSE,
  NativeMultidimensionalSupport=FALSE)
stopifnot(identical(tools::md5sum(names(sources)),sources),
  identical(tools::md5sum(names(external)),external))
if(args=='build'){
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  saveRDS(list(binding=binding,result=result),target)
  stopifnot(all(file.copy(c(design_source,script),out,overwrite=FALSE)))
} else {
  stopifnot(identical(saved$result,result),identical(tools::md5sum(target),before))
  proof <- file.path(out,'fresh-replay.rds');stopifnot(!file.exists(proof))
  saveRDS(list(ChecksPassed=TRUE,Binding=binding,Result=before,NewFits=0L,NewDatasets=0L),proof)
}
print(result$records,row.names=FALSE)
cat('Eight response-model maps checked; fitted covariance and numerical integration remain unqualified.\n')
