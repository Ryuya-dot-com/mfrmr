# Review the retained external covariance, independently of native refitting.
# q61 completed matrix export before an unsupported decimals=12 display request.
source('inst/validation/mfrm-pcm-covariance-20261012.R')
covariance_review_script <- 'inst/validation/mfrm-pcm-covariance-review-20261012.R'

covariance_context <- function() {
  record <- readRDS(file.path(covariance_dir, 'manifest.rds'))
  check_hashes(record$source); check_hashes(record$inputs)
  stopifnot(identical(wide_mml_runtime(), record$runtime),
    identical(digest::digest(file=bridge_executable, algo='sha256'), record$executable))
  m <- readRDS(file.path(bridge_dir, 'manifest.rds'))
  for (h in list(m$source,m$inputs)) check_hashes(h)
  for (name in c('fit_mfrm','simulate_mfrm_data'))
    trace(name, quote(stop('No native refit or response generation.')),
      where=asNamespace('mfrmr'),print=FALSE)
  list(record=record,m=m)
}

covariance_q121 <- function() {
  covariance_context()
  directory <- file.path(covariance_dir,'q121')
  stopifnot(!file.exists(file.path(directory,'console.txt')))
  command <- readLines(file.path(directory,'commands.cqc'))
  fixed <- sub('decimals=12','decimals=9',command,fixed=TRUE)
  stopifnot(sum(command!=fixed)==1L,
    identical(command[grepl('^estimate ',command)],fixed[grepl('^estimate ',fixed)]))
  writeLines(fixed,file.path(directory,'commands-display-fixed.cqc'))
  old <- getwd();on.exit(setwd(old),add=TRUE);setwd(directory)
  started <- proc.time()
  status <- system2('/usr/bin/arch',c('-x86_64',shQuote(bridge_executable)),
    input=fixed,stdout='console.txt',stderr='stderr.txt')
  saveRDS(list(status=status,timing=proc.time()-started,
    display_only_correction='decimals=12 -> decimals=9; estimation command unchanged',
    files=tools::md5sum(list.files(pattern='[.](csv|txt|cqc|sys)$'))),'execution.rds')
  stopifnot(status==0L,any(grepl('End of Program',readLines('console.txt'),fixed=TRUE)))
  cat('ConQuest q121 covariance and saved system state completed.\n')
}

covariance_native <- function() {
  ctx <- covariance_context();m <- ctx$m
  path <- file.path(covariance_dir,'native-covariance.rds')
  stopifnot(!file.exists(path))
  f <- names(m$inputs)[grepl('q[0-9]+-fit[.]rds$',names(m$inputs))]
  stopifnot(length(f)==1L)
  fit <- read_phase(f)$payload$value
  stopifnot(fit$config$estimation_control$quad_points==121L)
  native <- mfrmr:::compute_mml_parameter_covariance(fit)
  stopifnot(native$status=='ok',!native$regularized,native$rank==15L)
  # Native order: Task[1:2], Rater[1:5], Step[1:6], mean, log(variance).
  order <- c(3:7,1:2,8:15)
  map <- function(p)c(p[order[1:14]],exp(p[15]))
  J <- diag(15)[order,,drop=FALSE];J[15,15]<-m$native[15]
  delta <- numDeriv::jacobian(map,fit$opt$par)
  stopifnot(max(abs(map(fit$opt$par)-m$native))<=ctx$record$tolerance['map'],
    max(abs(J-delta))<=ctx$record$tolerance['map'])
  mapped <- J%*%native$cov%*%t(J);dimnames(mapped)<-list(names(m$native),names(m$native))
  result <- list(native=native,mapped=mapped,jacobian=J,
    jacobian_error=max(abs(J-delta)),x=m$native,
    source=tools::md5sum(c(covariance_review_script,names(ctx$record$source))),
    inputs=tools::md5sum(c(file.path(covariance_dir,'manifest.rds'),f)),
    runtime=wide_mml_runtime())
  saveRDS(result,path)
  cat('Retained native optimum: covariance only, no optimization.\n')
  print(native$solution_information$evaluation_summary)
}

read_empirical_covariance <- function(q,m) {
  directory <- file.path(covariance_dir,paste0('q',q))
  execution <- readRDS(file.path(directory,'execution.rds'))
  hashes <- execution$files;names(hashes)<-file.path(directory,names(hashes));check_hashes(hashes)
  console <- readLines(file.path(directory,'console.txt'))
  stopifnot(any(grepl('Calculation of empirical errors complete',console,fixed=TRUE)),
    any(grepl('Deviance change is less than convergence criterion',console,fixed=TRUE)),
    file.info(file.path(directory,'stderr.txt'))$size==0)
  if(q==61L) stopifnot(execution$status!=0L,
    identical(tail(console,1L),'<Decimals option must be an integer less than 10')) else
    stopifnot(execution$status==0L,any(grepl('End of Program',console,fixed=TRUE)))
  original <- file.path(bridge_dir,paste0('conquest-task-first-q',q))
  previous <- read_cq(original,m)
  for (name in c('responses.csv','amatrix.csv','parameters.csv','regression.csv','variance.csv','history.csv'))
    stopifnot(identical(unname(tools::md5sum(file.path(directory,name))),
      unname(tools::md5sum(file.path(original,name)))))
  tab <- read.csv(file.path(directory,'estimatecovariances.csv'),check.names=FALSE)
  labels <- c(paste0('rater R',1:5),paste0('task T',1:2),
    paste0('rater R',1:6,' category 1'),'Intercept','Var(1)')
  stopifnot(nrow(tab)==15L,identical(trimws(names(tab)[-1]),labels),
    identical(tab[[1]],paste0('row_',1:15)))
  V <- as.matrix(tab[-1]); storage.mode(V)<-'double'
  if(q==121L) {
    # Table 10 retains more digits than the six-decimal matrix CSV.
    full <- matrix(NA_real_,15,15); cols<-integer()
    for(line in readLines(file.path(directory,'covariance-review.txt'))) {
      tokens<-strsplit(trimws(line),'[[:space:]]+')[[1]]
      if(length(tokens) && all(grepl('^[0-9]+$',tokens))) cols<-as.integer(tokens)
      if(length(cols) && length(tokens)==length(cols)+1L &&
         grepl('^[0-9]+$',tokens[1]) && all(grepl('e[-+][0-9]+$',tokens[-1]))) {
        row<-as.integer(tokens[1]); stopifnot(all(is.na(full[row,cols])))
        full[row,cols]<-as.numeric(tokens[-1])
      }
    }
    stopifnot(all(is.finite(full)),max(abs(full-V))<=5.1e-7)
    V<-full
  }
  dimnames(V)<-list(names(m$native),names(m$native))
  stopifnot(all(is.finite(V)),max(abs(V-t(V)))<=1e-10,
    min(eigen(V,symmetric=TRUE,only.values=TRUE)$values)>0)
  list(x=previous$x,cov=V,status=execution$status,timing=execution$timing,
    precision=if(q==121L)'Table 10 scientific output, cross-checked against CSV' else 'six-decimal CSV',
    export_complete=TRUE,session_complete=q==121L)
}

covariance_outputs <- function(native,external) {
  engines<-c(list(Native=list(x=native$x,cov=native$mapped)),external)
  ref<-native$mapped;scale<-sqrt(outer(diag(ref),diag(ref)))
  agreement<-do.call(rbind,lapply(names(external),function(name) {
    V<-external[[name]]$cov
    data.frame(Engine=name,MaxCovarianceDifference=max(abs(V-ref)),
      MaxScaledDifference=max(abs(V-ref)/scale),MaxRelativeSEDifference=max(abs(sqrt(diag(V)/diag(ref))-1)))
  }))
  grid<-max(abs(external[[1]]$cov-external[[2]]$cov)/scale)
  contrasts<-list(Rater_r1_minus_r6=c(2,rep(1,4),rep(0,10)),
    Task_t1_minus_t3=c(rep(0,5),2,1,rep(0,8)))
  limits<-rows<-list()
  for(name in names(engines)) {
    x<-engines[[name]]$x;V<-engines[[name]]$cov
    for(target in names(contrasts)) {
      c<-contrasts[[target]];difference<-sum(c*x)
      for(standardized in c(FALSE,TRUE)) {
        J<-c;value<-difference
        if(standardized) {
          value<-difference/sqrt(x[15]);J<-c/sqrt(x[15]);J[15]<- -difference/(2*x[15]^1.5)
        }
        se<-sqrt(drop(J%*%V%*%J))
        limits[[length(limits)+1L]]<-data.frame(Engine=name,Target=target,
          Scale=if(standardized)'population_SD' else 'native',Estimate=value,SE=se,
          Lower=value-qnorm(.975)*se,Upper=value+qnorm(.975)*se)
      }
    }
    for(facet in c('Rater','Task')) {
      ids<-if(facet=='Rater')1:5 else 6:7;K<-length(ids)+1L
      A<-matrix(0,K,15);A[,ids]<-rbind(diag(K-1),-rep(1,K-1))
      estimate<-drop(A%*%x);W<-A%*%V%*%t(A);C<-diag(K)-matrix(1/K,K,K)
      stopifnot(max(abs(rowSums(W)))<=1e-10)
      spread<-var(estimate);mse<-mean(diag(W));centered<-sum(diag(C%*%W))/(K-1)
      stopifnot(abs(centered-mse*K/(K-1))<=1e-12)
      contrast<-cbind(diag(K-1),-rep(1,K-1));d<-drop(contrast%*%estimate)
      joint_q<-drop(t(d)%*%solve(contrast%*%W%*%t(contrast),d))
      weights<-1/diag(W);diagonal_q<-sum(weights*estimate^2)-sum(weights*estimate)^2/sum(weights)
      for(basis in c('current_diagonal_index','centered_error_sensitivity')) {
        error<-if(basis=='current_diagonal_index')mse else centered
        true<-max(spread-error,0);G<-sqrt(true/error);R<-true/spread;H<-(4*G+1)/3
        if(basis=='current_diagonal_index') {
          package<-mfrmr:::summarize_precision_basis(data.frame(Estimate=estimate,SE=sqrt(diag(W))),'SE')
          stopifnot(max(abs(c(G,R,H)-unlist(package[c('Separation','Reliability','Strata')])))<=1e-10)
        }
        rows[[length(rows)+1L]]<-data.frame(Engine=name,Facet=facet,Levels=K,Basis=basis,
          ObservedVariance=spread,ErrorVariance=error,Separation=G,Reliability=R,Strata=H,
          DiagonalChiSq=diagonal_q,JointContrastChiSq=joint_q,DF=K-1,
          DiagonalP=pchisq(diagonal_q,K-1,lower.tail=FALSE),JointP=pchisq(joint_q,K-1,lower.tail=FALSE))
      }
    }
  }
  list(agreement=agreement,grid_scaled_difference=grid,
    contrasts=do.call(rbind,limits),downstream=do.call(rbind,rows))
}

covariance_summary <- function(replay=FALSE) {
  ctx<-covariance_context();path<-file.path(covariance_dir,'comparison.rds')
  native<-readRDS(file.path(covariance_dir,'native-covariance.rds'))
  check_hashes(native$source);check_hashes(native$inputs)
  # Summary and fresh-session replay cannot refit or redifferentiate.
  trace('compute_mml_parameter_covariance',quote(stop('Use retained covariance.')),
    where=asNamespace('mfrmr'),print=FALSE)
  trace('system2',quote(stop('Summary cannot launch an estimator.')),where=baseenv(),print=FALSE)
  if(replay) { saved<-readRDS(path);check_hashes(saved$consumed) } else stopifnot(!file.exists(path))
  external<-setNames(lapply(c(61L,121L),read_empirical_covariance,m=ctx$m),c('ConQuest61','ConQuest121'))
  result<-covariance_outputs(native,external)
  result$tolerance<-ctx$record$tolerance
  result$passed<-with(result,all(agreement$MaxScaledDifference<=tolerance['covariance_scaled']) &&
    all(agreement$MaxRelativeSEDifference<=tolerance['relative_se']) &&
    grid_scaled_difference<=tolerance['grid_covariance_scaled'])
  if(replay) {
    stopifnot(identical(result,saved$result));cat('Fresh replay exactly reproduced saved comparison.\n')
  } else {
    files<-c(covariance_review_script,file.path(covariance_dir,c('manifest.rds','native-covariance.rds')),
      unlist(lapply(c(61,121),function(q)list.files(file.path(covariance_dir,paste0('q',q)),full.names=TRUE))))
    saveRDS(list(result=result,external=external,consumed=tools::md5sum(files)),path)
    for(name in c('agreement','contrasts','downstream'))write.csv(result[[name]],
      file.path(covariance_dir,paste0(name,'.csv')),row.names=FALSE)
  }
  print(result$agreement);cat('Scaled grid difference:',result$grid_scaled_difference,'passed:',result$passed,'\n')
  print(subset(result$downstream,Engine=='Native'))
  invisible(result)
}

if(sys.nframe()==0L) {
  args<-commandArgs(trailingOnly=TRUE)
  stopifnot(length(args)==1L,args %in% c('conquest121','native','summarize','replay'))
  switch(args,conquest121=covariance_q121(),native=covariance_native(),
    summarize=covariance_summary(),replay=covariance_summary(TRUE))
}
