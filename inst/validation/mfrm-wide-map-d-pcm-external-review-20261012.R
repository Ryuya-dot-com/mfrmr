# Correct ConQuest input ordering and review one retained PCM calibration.
# The original runner/results stay frozen, including the wrong-layout q61 fit.
# Usage: Rscript --vanilla THIS_FILE prepare|conquest|summarize|replay [61|121]
source('inst/validation/mfrm-wide-map-d-pcm-external-20261012.R')
review_script <- 'inst/validation/mfrm-wide-map-d-pcm-external-review-20261012.R'
review_manifest <- file.path(bridge_dir,'corrected-manifest.rds')
cell_key <- function(x)paste(x$Task,x$Rater)

# Literal adjacent logits, independent of the package and external A kernels.
literal_logp <- function(theta,x,cells) {
  r <- match(cells$Rater,paste0('r',1:6));t <- match(cells$Task,paste0('t',1:3))
  rho <- c(x[1:5],-sum(x[1:5]));task <- c(x[6:7],-sum(x[6:7]))
  d <- theta-task[t]-rho[r]
  eta <- cbind(0,d-x[7+r],2*d)
  eta <- eta-apply(eta,1,max)
  eta-log(rowSums(exp(eta)))
}
continuous_nll <- function(x,response,cells) {
  stopifnot(length(x)==15L,all(is.finite(x)),x[15]>0)
  answer <- t(vapply(seq_len(nrow(response)),function(i) {
    obs <- which(!is.na(response[i,]));score <- response[i,obs]+1L
    f <- function(z)vapply(z,function(zz) {
      lp <- literal_logp(x[14]+sqrt(x[15])*zz,x,cells)
      exp(sum(lp[cbind(obs,score)])+dnorm(zz,log=TRUE))
    },numeric(1))
    integral <- integrate(f,-Inf,Inf,rel.tol=1e-10,abs.tol=0,subdivisions=1000L)
    stopifnot(integral$message=='OK',integral$value>0,is.finite(integral$value))
    c(nll=-log(integral$value),relative_error=integral$abs.error/integral$value)
  },numeric(2)))
  c(nll=sum(answer[,1]),relative_error=max(answer[,2]))
}
read_cq <- function(directory,m) {
  execution <- readRDS(file.path(directory,'execution.rds'))
  hashes <- execution$files;names(hashes) <- file.path(directory,names(hashes));check_hashes(hashes)
  console <- readLines(file.path(directory,'console.txt'))
  stopifnot(execution$status==0L,any(grepl('End of Program',console,fixed=TRUE)),
    any(grepl('Deviance change is less than convergence criterion',console,fixed=TRUE)),
    any(grepl('Sorting 360 records',console,fixed=TRUE)),
    any(grepl('No. of cases retained=60',console,fixed=TRUE)),
    file.info(file.path(directory,'stderr.txt'))$size==0)
  design <- read.csv(file.path(directory,'amatrix.csv'),check.names=FALSE)
  expected_labels <- c(paste0(' rater R',1:5),paste0(' task T',1:2),
    paste0(' rater R',1:6,' category 1'))
  stopifnot(nrow(design)==54L,all(design$GIN==rep(1:18,each=3)),
    all(design$Category==rep(1:3,18)),identical(trimws(names(design)[-(1:2)]),trimws(expected_labels)))
  expected <- matrix(aperm(m$A,c(2,1,3)),54,13)
  stopifnot(max(abs(as.matrix(design[,-(1:2)])-expected))<=m$tolerance['map'],
    qr(expected)$rank==13L)
  pars <- read.csv(file.path(directory,'parameters.csv'),check.names=FALSE)
  mean <- read.csv(file.path(directory,'regression.csv'))
  variance <- read.csv(file.path(directory,'variance.csv'))
  history <- read.csv(file.path(directory,'history.csv'),check.names=FALSE)
  stopifnot(nrow(pars)==13L,all(pars$P==1:13),identical(pars$Label,expected_labels),
    nrow(mean)==1L,mean$Dimension==1,mean$Regressor==1,nrow(variance)==1L,
    variance$Dim1==1,variance$Dim2==1,all(is.finite(pars$Estimate)))
  x <- setNames(c(pars$Estimate,mean$Estimate,variance$Covariance),names(m$native))
  list(x=x,deviance=tail(history$LogLikelihood,1),iterations=tail(history$Iteration,1))
}
review_main <- function(mode,q=NULL) {
  stopifnot(requireNamespace('TAM',quietly=TRUE))
  for(name in c('fit_mfrm','simulate_mfrm_data','compute_mml_parameter_covariance'))
    trace(name,quote(stop('External review cannot refit or generate native data.')),
      where=asNamespace('mfrmr'),print=FALSE)
  trace('tam.mml',quote(stop('Use the retained TAM fits.')),where=asNamespace('TAM'),print=FALSE)
  m <- readRDS(file.path(bridge_dir,'manifest.rds'))
  check_hashes(m$source);check_hashes(m$inputs)
  stopifnot(identical(wide_mml_runtime(),m$runtime),
    identical(as.character(packageVersion('TAM')),m$TAM),
    identical(tools::md5sum(names(m$TAM_DLL)),m$TAM_DLL),
    identical(digest::digest(file=bridge_executable,algo='sha256'),m$ConQuest))
  if(mode=='prepare') {
    stopifnot(!file.exists(review_manifest))
    # Official format command: leftmost implicit facet cycles fastest in INPUT.
    # The exported GIN design instead has Rater fastest. Preserve both maps.
    input_cells <- expand.grid(Task=paste0('t',1:3),Rater=paste0('r',1:6),
      stringsAsFactors=FALSE)
    input_to_gin <- match(cell_key(input_cells),cell_key(m$cells))
    gin_to_input <- match(cell_key(m$cells),cell_key(input_cells))
    stopifnot(identical(input_to_gin[gin_to_input],1:18))
    correct <- m$response[,input_to_gin]
    stopifnot(identical(correct[,gin_to_input],m$response))
    # Reconstruct the actual misassignment from the original CSV at its reported fit.
    wrong <- m$response[,gin_to_input]
    old <- read_cq(file.path(bridge_dir,'conquest-q61'),m)
    diagnosis <- rbind(as_consumed=continuous_nll(old$x,wrong,m$cells),
      intended=continuous_nll(old$x,m$response,m$cells))
    discrepancy <- abs(2*diagnosis[,'nll']-old$deviance)
    stopifnot(discrepancy['as_consumed']<=2*60*m$tolerance['nll_per_person'],
      discrepancy['intended']>1,all(diagnosis[,'relative_error']<=m$tolerance['integral_relative_error']))
    for(order in c(61L,121L)) {
      directory <- file.path(bridge_dir,paste0('conquest-task-first-q',order))
      stopifnot(!dir.exists(directory));dir.create(directory)
      write.csv(data.frame(Person=rownames(correct),correct,check.names=FALSE),
        file.path(directory,'responses.csv'),row.names=FALSE,na='')
      command <- readLines(file.path(bridge_dir,paste0('conquest-q',order),'commands.cqc'))
      # The first and last column names are unchanged; only inner columns move.
      writeLines(command,file.path(directory,'commands.cqc'))
      loaded <- read.csv(file.path(directory,'responses.csv'),check.names=FALSE)
      stopifnot(identical(loaded$Person,rownames(m$response)),
        identical(names(loaded)[-1],colnames(correct)),
        isTRUE(all.equal(unname(as.matrix(loaded[-1])[,gin_to_input]),
          unname(m$response),check.attributes=FALSE)))
    }
    record <- list(source=tools::md5sum(review_script),
      inputs=tools::md5sum(c(file.path(bridge_dir,'manifest.rds'),
        list.files(file.path(bridge_dir,'conquest-q61'),full.names=TRUE),
        unlist(lapply(c(61,121),function(order)file.path(bridge_dir,
          paste0('conquest-task-first-q',order),c('responses.csv','commands.cqc')))))),
      input_cells=input_cells,input_to_gin=input_to_gin,gin_to_input=gin_to_input,
      diagnosis=diagnosis,original_reported_deviance=old$deviance,
      tolerance=m$tolerance,
      reason='Correct first-facet-fast input; retain distinct last-facet-fast GIN design. Original q61 used different response/context assignments. No optimization/model/tolerance change.',
      specification='https://conquestmanual.acer.org/s4-00.html#format')
    saveRDS(record,review_manifest)
    print(cbind(diagnosis,deviance_discrepancy=discrepancy));return(invisible(record))
  }
  correction <- readRDS(review_manifest);check_hashes(correction$source);check_hashes(correction$inputs)
  stopifnot(identical(correction$tolerance,m$tolerance))
  if(mode=='conquest') {
    stopifnot(q %in% c(61L,121L))
    directory <- file.path(bridge_dir,paste0('conquest-task-first-q',q))
    stopifnot(!file.exists(file.path(directory,'execution.rds')),
      !file.exists(file.path(directory,'console.txt')))
    old <- getwd();on.exit(setwd(old),add=TRUE);setwd(directory)
    status <- system2('/usr/bin/arch',c('-x86_64',shQuote(bridge_executable)),
      input=readLines('commands.cqc'),stdout='console.txt',stderr='stderr.txt')
    saveRDS(list(status=status,files=tools::md5sum(list.files(pattern='[.](csv|txt|cqc)$'))),'execution.rds')
    stopifnot(status==0L,any(grepl('End of Program',readLines('console.txt'),fixed=TRUE)))
    cat('Completed corrected ConQuest q',q,'\n');return(invisible(NULL))
  }
  stopifnot(mode %in% c('summarize','replay'))
  path <- file.path(bridge_dir,'comparison.rds')
  if(mode=='summarize')stopifnot(!file.exists(path))
  if(mode=='replay') {
    saved <- readRDS(path);check_hashes(saved$consumed)
    trace('system2',quote(stop('Replay cannot launch an estimator.')),where=baseenv(),print=FALSE)
  }
  runs <- list(Native=list(x=m$native,deviance=m$native_deviance,iterations=NA_integer_))
  consumed <- c(review_manifest,file.path(bridge_dir,'manifest.rds'))
  for(order in c(61L,121L)) {
    file <- file.path(bridge_dir,paste0('tam-q',order,'.rds'));a <- readRDS(file);f <- a$value
    stopifnot(!nzchar(a$error),length(a$warnings)==0L,f$iter<m$tam_control$maxiter,
      f$ic$Npars==15L,f$ic$ghp_obs==360L,f$ic$n==60L,
      identical(unname(f$A),unname(m$A)),identical(unname(f$B),unname(m$B)),
      isTRUE(all.equal(unname(f$resp),unname(m$response),check.attributes=FALSE)))
    runs[[paste0('TAM-q',order)]] <- list(x=setNames(c(f$xsi$xsi,f$beta,f$variance),
      names(m$native)),deviance=f$deviance,iterations=f$iter)
    directory <- file.path(bridge_dir,paste0('conquest-task-first-q',order))
    loaded <- read.csv(file.path(directory,'responses.csv'),check.names=FALSE)
    stopifnot(identical(loaded$Person,rownames(m$response)),
      isTRUE(all.equal(unname(as.matrix(loaded[-1])[,correction$gin_to_input]),
        unname(m$response),check.attributes=FALSE)))
    runs[[paste0('ConQuest-q',order)]] <- read_cq(directory,m)
    consumed <- c(consumed,file,list.files(directory,full.names=TRUE))
  }
  theta <- m$native[14]+sqrt(m$native[15])*c(-2,-1,0,1,2)
  probability <- function(x)unlist(lapply(theta,function(v)exp(literal_logp(v,x,m$cells))))
  integrals <- lapply(runs,function(a)continuous_nll(a$x,m$response,m$cells))
  probabilities <- lapply(runs,function(a)probability(a$x))
  numerical <- do.call(rbind,lapply(names(runs),function(name) {
    a <- runs[[name]];ii <- integrals[[name]]
    data.frame(Engine=name,Iterations=a$iterations,ReportedDeviance=a$deviance,
      ContinuousDeviance=2*ii['nll'],IntegralRelativeError=ii['relative_error'],
      ReportedNLLDifferencePerPerson=abs(a$deviance/2-ii['nll'])/60,
      CoordinateDifference=max(abs(a$x-m$native)),
      ProbabilityDifference=max(abs(probabilities[[name]]-probabilities$Native)),
      NLLDifferencePerPerson=abs(ii['nll']-integrals$Native['nll'])/60,row.names=NULL)
  }))
  grids <- do.call(rbind,lapply(c('TAM','ConQuest'),function(engine) {
    lo <- paste0(engine,'-q61');hi <- paste0(engine,'-q121')
    data.frame(Engine=engine,CoordinateDifference=max(abs(runs[[lo]]$x-runs[[hi]]$x)),
      ProbabilityDifference=max(abs(probabilities[[lo]]-probabilities[[hi]])),
      NLLDifferencePerPerson=abs(integrals[[lo]]['nll']-integrals[[hi]]['nll'])/60,row.names=NULL)
  }))
  stopifnot(all(numerical$IntegralRelativeError<=m$tolerance['integral_relative_error']),
    all(numerical$ReportedNLLDifferencePerPerson<=m$tolerance['nll_per_person']),
    all(numerical$CoordinateDifference<=m$tolerance['coordinate']),
    all(numerical$ProbabilityDifference<=m$tolerance['probability']),
    all(numerical$NLLDifferencePerPerson<=m$tolerance['nll_per_person']),
    all(grids$CoordinateDifference<=m$tolerance['grid_coordinate']),
    all(grids$ProbabilityDifference<=m$tolerance['grid_probability']),
    all(grids$NLLDifferencePerPerson<=m$tolerance['grid_nll_per_person']))
  result <- list(numerical=numerical,grid=grids,coordinates=lapply(runs,`[[`,'x'),
    consumed=tools::md5sum(unique(consumed)),source=tools::md5sum(review_script),
    runtime=wide_mml_runtime(),tolerance=m$tolerance,passed=TRUE,
    scope='One retained PCM point calibration, exact printed ConQuest values. No information/interval/performance/global-optimum claim. Initial ConQuest mismatch explained by input ordering; all original evidence retained.')
  if(mode=='replay')stopifnot(identical(result,saved)) else {
    saveRDS(result,path);write.csv(numerical,file.path(bridge_dir,'comparison.csv'),row.names=FALSE)
    write.csv(grids,file.path(bridge_dir,'grid-comparison.csv'),row.names=FALSE)
  }
  print(numerical,digits=10);print(grids,digits=10);cat('PCM external review',mode,'passed.\n')
  invisible(result)
}
if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE)
  stopifnot(length(args)>=1L)
  review_main(args[1],if(length(args)>1L)as.integer(args[2])else NULL)
}
