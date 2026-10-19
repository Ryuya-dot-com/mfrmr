# N60 replication 1 in each truth/model: fixed-point TAM checks, no estimation.
# Usage: Rscript --vanilla THIS_FILE run|replay
source('inst/validation/mfrm-wide-map-d-n60-controls-20261012.R')
external_script <- 'inst/validation/mfrm-wide-map-d-external-map-20261012.R'
external_dir <- 'validation-results/mfrm-wide-map-d-external-map-20261012'
external_mode <- commandArgs(trailingOnly=TRUE)
stopifnot(length(external_mode)==1L,external_mode %in% c('run','replay'))
for(name in c('fit_mfrm','compute_mml_parameter_covariance','simulate_mfrm_data',
  'mfrm_gpcm_product_inference'))
  trace(name,quote(stop('Fixed-point comparison only.')),where=asNamespace('mfrmr'),print=FALSE)
for(name in c('tam.mml','tam.mml.2pl','tam.mml.mfr'))
  trace(name,quote(stop('No external fitting in the response-map check.')),
    where=asNamespace('TAM'),print=FALSE)

external_check <- function() {
  roots <- c('validation-results/mfrm-wide-map-d-n60-controls-20261012',
    'validation-results/mfrm-wide-map-d-size-counterparts-20261011')
  manifests <- lapply(file.path(roots,'dispatch.rds'),readRDS)
  for(m in manifests){check_hashes(m$source);check_hashes(m$inputs)}
  stopifnot(identical(wide_mml_runtime(),manifests[[1]]$runtime),
    identical(manifests[[1]]$runtime,manifests[[2]]$runtime))
  files <- file.path(roots,'dispatch.rds'); sources <- c(external_script,
    unique(unlist(lapply(manifests,function(m)names(m$source)))))
  cases <- list()
  add <- function(row,root,reference=FALSE) {
    if(reference){
      directory <- row$ReferenceJob
      selection_file <- file.path(directory,'selected.rds')
      output_file <- file.path(directory,'d-outputs.rds')
      selection <- read_phase(selection_file)$payload$point
      order <- as.integer(sub('^q([0-9]+):.*','\\1',selection$stage))
      saved <- read_phase(output_file)$payload$response$admitted
    } else {
      directory <- file.path(root,row$Job)
      selection_file <- output_file <- file.path(directory,'outputs.rds')
      output <- read_phase(output_file)$payload
      selection <- output$selected;order <- selection$order;saved <- output$admitted$value
    }
    fit_file <- file.path(directory,paste0('q',order,'-fit.rds'))
    stage <- read_phase(fit_file)$payload
    stopifnot(identical(wide_mml_hash(stage),selection$fit_hash),!is.null(saved))
    fit <- stage$value;cfg <- fit$config
    p <- mfrmr:::expand_params(fit$opt$par,mfrmr:::build_param_sizes(cfg),cfg)
    data <- input_data(row)
    stopifnot(nrow(data)==360L,length(unique(data$Person))==60L,
      !anyDuplicated(data[c('Person','Task','Rater')]),cfg$n_cat==3L,
      identical(cfg$step_facet,'Rater'),all(cfg$facet_signs==-1))
    cells <- expand.grid(first=1:3,second=1:6);slope <- rep(1,18)
    product <- length(cfg$slope_facet)==2L
    if(product){
      mu <- 0;sigma <- 1
      slope <- p$slope_components$Task$Slope[cells$first]*
        p$slope_components$Rater$Slope[cells$second]
    } else {
      mu <- unname(p$population$coefficients);sigma <- sqrt(p$population$sigma2)
      if(cfg$model=='GPCM')slope <- p$slopes[
        if(cfg$slope_facet=='Task')cells$first else cells$second]
    }
    # Construct external cumulative intercepts directly from native coordinates.
    ax <- t(vapply(1:18,function(j)slope[j]*
      ((0:2)*(mu-p$facets$Task[cells$first[j]]-p$facets$Rater[cells$second[j]])-
        c(0,cumsum(p$steps_mat[cells$second[j],]))),numeric(3)))
    B <- array(outer(sigma*slope,0:2),c(18L,3L,1L))
    A <- array(0,c(18L,3L,36L));xsi <- numeric(36)
    for(j in 1:18)for(k in 2:3){h<-2L*(j-1L)+k-1L;A[j,k,h]<-1;xsi[h]<-ax[j,k]}
    z <- c(-2,-1,0,1,2)
    args <- list(iIndex=1:18,A=A,AXsi=matrix(0,18,3),B=B,xsi=xsi,
      theta=matrix(z,ncol=1),nnodes=5L,maxK=3L,recalc=TRUE,maxcat=rep(3L,18))
    calc <- get('tam_mml_calc_prob',asNamespace('TAM'))
    plain <- do.call(calc,c(args,list(use_rcpp=FALSE)))
    compiled <- do.call(calc,c(args,list(use_rcpp=TRUE)))
    probabilities <- do.call(rbind,lapply(1:18,function(j)t(compiled$rprobs[j,,])))
    native <- wide_d_response_points(fit)
    error <- c(saved=max(abs(probabilities-saved$probabilities)),
      current=max(abs(probabilities-native$probabilities)),
      backend=max(abs(plain$rprobs-compiled$rprobs)),
      intercept=max(abs(compiled$AXsi-ax)))
    stopifnot(identical(native$grid,saved$grid),all(is.finite(error)),all(error<=1e-12))
    cases[[length(cases)+1L]] <<- list(Truth=row$Truth,Arm=row$Arm,
      Replicate=row$Replicate,Order=order,SourceEpoch=if(reference)'retained_product' else 'counterpart',
      errors=error,AXsi=ax,B=B,TAM=probabilities,saved=saved$probabilities)
    files <<- unique(c(files,selection_file,output_file,fit_file,row$Bundle))
  }
  for(i in 1:2){
    jobs <- subset(manifests[[i]]$jobs,N==60L & Replicate==1L)
    for(j in seq_len(nrow(jobs)))add(jobs[j,],roots[i])
  }
  reference <- subset(manifests[[2]]$references,N==60L & Replicate==1L)
  stopifnot(nrow(reference)==1L);add(reference,roots[2],TRUE)
  summary <- do.call(rbind,lapply(cases,function(x)data.frame(
    Truth=x$Truth,Arm=x$Arm,Replicate=x$Replicate,Order=x$Order,t(x$errors))))
  stopifnot(nrow(summary)==16L,all(table(summary$Truth,summary$Arm)==1L))
  list(summary=summary,cases=cases,inputs=tools::md5sum(files),source=tools::md5sum(sources),
    TAM=as.character(packageVersion('TAM')),
    TAM_function=wide_mml_hash(get('tam_mml_calc_prob',asNamespace('TAM'))),
    TAM_DLL=tools::md5sum(getLoadedDLLs()[['TAM']][['path']]),
    runtime=wide_mml_runtime(),tolerance=1e-12,
    scope='Replication 1 in each N60 truth/model. Fixed response map only; not free-estimator equivalence, optimization/information, sampling performance or interval qualification. No fits or new responses.')
}
external_result <- external_check()
external_file <- file.path(external_dir,'tam-map.rds')
if(external_mode=='run'){
  stopifnot(!file.exists(external_file));saveRDS(external_result,external_file)
  write.csv(external_result$summary,file.path(external_dir,'tam-map.csv'),row.names=FALSE)
} else stopifnot(identical(readRDS(external_file),external_result))
print(external_result$summary,row.names=FALSE)
cat('Sixteen fixed-point TAM checks passed; fitting and generation disabled.\n')
