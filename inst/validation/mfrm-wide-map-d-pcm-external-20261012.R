# One retained PCM calibration, two external engines. No native refit or data generation.
# Usage: Rscript --vanilla THIS_FILE prepare|tam|conquest [61|121]
source('inst/validation/mfrm-wide-map-d-n60-controls-20261012.R')
bridge_script <- 'inst/validation/mfrm-wide-map-d-pcm-external-20261012.R'
bridge_dir <- 'validation-results/mfrm-wide-map-d-pcm-external-20261012'
bridge_executable <- '/Applications/ConQuest/ConQuest'
bridge_main <- function(mode,q=NULL) {
  stopifnot(requireNamespace('TAM',quietly=TRUE))
  for(name in c('fit_mfrm','simulate_mfrm_data','compute_mml_parameter_covariance'))
    trace(name,quote(stop('Reuse native calibration; no new native computation.')),
      where=asNamespace('mfrmr'),print=FALSE)
  if(mode=='prepare') {
    stopifnot(!dir.exists(bridge_dir))
    dispatch_path <- 'validation-results/mfrm-wide-map-d-size-counterparts-20261011/dispatch.rds'
    previous <- readRDS(dispatch_path);check_hashes(previous$source);check_hashes(previous$inputs)
    stopifnot(identical(wide_mml_runtime(),previous$runtime))
    row <- subset(previous$jobs,N==60L & Replicate==1L & Arm=='PCM-MML-free-population')
    stopifnot(nrow(row)==1L)
    directory <- file.path(dirname(dispatch_path),row$Job)
    output_file <- file.path(directory,'outputs.rds');output <- read_phase(output_file)$payload
    fit_file <- file.path(directory,paste0('q',output$selected$order,'-fit.rds'))
    stage <- read_phase(fit_file)$payload
    stopifnot(isTRUE(output$selected$review$ready),
      identical(wide_mml_hash(stage),output$selected$fit_hash))
    fit <- stage$value;cfg <- fit$config
    stopifnot(cfg$model=='PCM',cfg$noncenter_facet=='Person',cfg$step_facet=='Rater',
      cfg$n_cat==3L,all(cfg$facet_signs==-1),length(fit$population$coefficients)==1L)
    data <- input_data(row);people <- sort(unique(data$Person))
    # ConQuest cycles the last declared facet fastest.
    cells <- expand.grid(Rater=cfg$facet_levels$Rater,Task=cfg$facet_levels$Task,
      stringsAsFactors=FALSE)
    response <- matrix(NA_integer_,60,18,dimnames=list(people,
      paste0('Y',toupper(cells$Task),toupper(cells$Rater))))
    ri <- match(data$Person,people);ci <- match(paste(data$Task,data$Rater),
      paste(cells$Task,cells$Rater))
    stopifnot(nrow(data)==360L,length(people)==60L,!anyNA(c(ri,ci)),
      !anyDuplicated(data[c('Person','Task','Rater')]))
    response[cbind(ri,ci)] <- data$Score
    stopifnot(sum(!is.na(response))==360L,sum(is.na(response))==720L,
      identical(as.integer(response[cbind(ri,ci)]),as.integer(data$Score)),
      all(apply(response,2,function(x)setequal(x[!is.na(x)],0:2))))
    r <- match(cells$Rater,cfg$facet_levels$Rater);t <- match(cells$Task,cfg$facet_levels$Task)
    location <- cbind(contr.sum(6)[r,],contr.sum(3)[t,])
    labels <- c(paste0('Rater:',1:5),paste0('Task:',1:2),paste0('Step:',1:6))
    A <- array(0,c(18L,3L,13L),dimnames=list(colnames(response),as.character(0:2),labels))
    for(j in 1:7)A[,,j] <- -outer(location[,j],0:2)
    for(j in 1:18)A[j,2,7+r[j]] <- -1
    B <- array(rep(0:2,each=18),c(18L,3L,1L))
    stopifnot(qr(matrix(A,ncol=13))$rank==13L)
    p <- mfrmr:::expand_params(fit$opt$par,mfrmr:::build_param_sizes(cfg),cfg)
    native <- c(p$facets$Rater[1:5],p$facets$Task[1:2],p$steps_mat[,1],
      mean=unname(p$population$coefficients),variance=p$population$sigma2)
    names(native) <- c(labels,'mean','variance')
    ax <- matrix(A,ncol=13)%*%native[1:13];dim(ax)<-c(18,3)
    literal <- t(vapply(1:18,function(j)-(0:2)*(p$facets$Task[t[j]]+
      p$facets$Rater[r[j]])-c(0,cumsum(p$steps_mat[r[j],])),numeric(3)))
    stopifnot(max(abs(ax-literal))<=1e-12)
    base <- c('title N60 retained PCM external calibration;',
      'set lconstraints=items, sconstraint=none, respmiss=both, exit_on_error=yes;',
      paste0('datafile responses.csv ! filetype=csv, header=yes, columnlabels=no, pid=Person, ',
        'pidwidth=16, responses=',colnames(response)[1],' to ',tail(colnames(response),1),
        ', facets=task(3) rater(6);'),
      'codes 0,1,2;',paste0('labels ',1:3,' T',1:3,' ! task;'),
      paste0('labels ',1:6,' R',1:6,' ! rater;'),'model rater + task + rater*step;')
    dir.create(bridge_dir,recursive=TRUE)
    write.csv(data.frame(Person=people,response,check.names=FALSE),
      file.path(bridge_dir,'responses.csv'),row.names=FALSE,na='')
    writeLines(c(base,'export amatrix ! filetype=csv >> design-preflight.csv;','quit;'),
      file.path(bridge_dir,'design-preflight.cqc'))
    for(order in c(61L,121L)) {
      path <- file.path(bridge_dir,paste0('conquest-q',order));dir.create(path)
      stopifnot(file.copy(file.path(bridge_dir,'responses.csv'),path))
      command <- c(base,paste0('estimate ! method=quadrature, nodes=',order,
        ', fit=no, stderr=quick, matrixout=bridge, convergence=0.00000001, ',
        'deviancechange=0.0000000001, iterations=2000;'),
        'export parameters ! filetype=csv >> parameters.csv;',
        'export amatrix ! filetype=csv >> amatrix.csv;',
        'export reg_coefficients ! filetype=csv >> regression.csv;',
        'export covariance ! filetype=csv >> variance.csv;',
        'write bridge_history ! filetype=csv >> history.csv;',
        'show parameters ! tables=1:2:3:4 >> parameters-review.txt;','quit;')
      writeLines(command,file.path(path,'commands.cqc'))
    }
    inputs <- unique(c(dispatch_path,row$Bundle,fit_file,output_file,
      list.files(bridge_dir,'[.](cqc|csv)$',recursive=TRUE,full.names=TRUE)))
    manifest <- list(row=row,response=response,cells=cells,A=A,B=B,native=native,
      native_deviance=fit$summary$Deviance,source=tools::md5sum(c(bridge_script,names(previous$source))),
      inputs=tools::md5sum(inputs),runtime=wide_mml_runtime(),
      TAM=as.character(packageVersion('TAM')),TAM_DLL=tools::md5sum(getLoadedDLLs()[['TAM']][['path']]),
      ConQuest=digest::digest(file=bridge_executable,algo='sha256'),
      tolerance=c(map=1e-12,probability=1e-5,coordinate=1e-4,nll_per_person=1e-7,
        grid_probability=1e-6,grid_coordinate=1e-5,grid_nll_per_person=1e-8,
        integral_relative_error=1e-8),
      tam_control=list(maxiter=2000L,conv=1e-10,convD=1e-10,convM=1e-10,Msteps=20L,progress=FALSE),
      scope='One N60 H-both replication-1 PCM calibration. Existing native fit; two neutral-start external fits per engine at q61/121. No new responses, native refit, general performance or interval claim. ConQuest comparisons refer to exported decimal values, not an undocumented hidden rounding interval.')
    saveRDS(manifest,file.path(bridge_dir,'manifest.rds'))
    cat('Prepared matched 60-Person, 360-rating, 13-intercept plus mean/variance calibration.\n')
    return(invisible(manifest))
  }
  m <- readRDS(file.path(bridge_dir,'manifest.rds'))
  check_hashes(m$source);check_hashes(m$inputs)
  stopifnot(identical(wide_mml_runtime(),m$runtime),q %in% c(61L,121L),
    identical(as.character(packageVersion('TAM')),m$TAM),
    identical(tools::md5sum(names(m$TAM_DLL)),m$TAM_DLL),
    identical(digest::digest(file=bridge_executable,algo='sha256'),m$ConQuest))
  if(mode=='tam') {
    path <- file.path(bridge_dir,paste0('tam-q',q,'.rds'));stopifnot(!file.exists(path))
    control <- c(list(nodes=seq(-8,8,length.out=q)),m$tam_control)
    result <- wide_mml_capture(function()TAM::tam.mml(m$response,A=m$A,B=m$B,
      irtmodel='PCM',beta.fixed=FALSE,est.variance=TRUE,item.elim=FALSE,
      pid=rownames(m$response),verbose=FALSE,control=control))
    saveRDS(result,path);stopifnot(!nzchar(result$error))
    cat('TAM completed q',q,'iterations',result$value$iter,'deviance',result$value$deviance,'\n')
  } else {
    stopifnot(mode=='conquest')
    directory <- file.path(bridge_dir,paste0('conquest-q',q))
    stopifnot(!file.exists(file.path(directory,'console.txt')))
    old <- getwd();on.exit(setwd(old),add=TRUE);setwd(directory)
    status <- system2('/usr/bin/arch',c('-x86_64',shQuote(bridge_executable)),
      input=readLines('commands.cqc'),stdout='console.txt',stderr='stderr.txt')
    saveRDS(list(status=status,files=tools::md5sum(list.files(pattern='[.](csv|txt|cqc)$'))),'execution.rds')
    stopifnot(status==0L,any(grepl('End of Program',readLines('console.txt'),fixed=TRUE)))
    cat('ConQuest completed q',q,'\n')
  }
}
if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE)
  stopifnot(length(args)>=1L,args[1] %in% c('prepare','tam','conquest'))
  bridge_main(args[1],if(length(args)>1L)as.integer(args[2])else NULL)
}
