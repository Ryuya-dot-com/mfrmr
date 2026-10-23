# Retained-data reanalysis; contract in internal-roadmap-0.2.4.md, unit 1.
# Rscript --vanilla <this file> prepare|preflight|run [comma-separated cells]
mde_old <- 'validation-results/person-estimated-calibration-20260914'
mde_root <- 'validation-results/mfrm-decision-probability-evaluation-20261010'
mde_script <- 'inst/validation/mfrm-decision-probability-evaluation-20261010.R'
mde_cuts <- c(Low=-1,Central=0,High=1)
mde_events <- c(names(mde_cuts),paste0('Band',1:4))
mde_cells <- data.frame(Cell=1:8,Model=rep(c('RSM','PCM'),each=4),
  Persons=rep(c(80L,80L,320L,320L),2),Exposure=rep(c(3L,6L),4))
mde_sha <- function(path) vapply(path,digest::digest,'',file=TRUE,algo='sha256')
mde_save <- function(x,path) {
  stopifnot(!file.exists(path))
  saveRDS(x,paste0(path,'.tmp'))
  stopifnot(file.rename(paste0(path,'.tmp'),path))
  writeLines(unname(mde_sha(path)),paste0(path,'.sha256'))
}
mde_read <- function(path) {
  stopifnot(identical(unname(mde_sha(path)),readLines(paste0(path,'.sha256'))))
  readRDS(path)
}
mde_runtime <- function() {
  lock <- jsonlite::fromJSON('inst/validation/runtime-lock-20261009.json')
  historical <- unlist(lock$R$HistoricalBinarySHA256)
  actual <- setNames(mde_sha(file.path(R.home(),names(historical))),names(historical))
  stopifnot(identical(actual,historical))
  packages <- c('Matrix','Rcpp','RcppArmadillo','numDeriv','MASS',
    'digest','pkgload','jsonlite')
  list(R=R.version,RHome=R.home(),External=extSoftVersion(),Libraries=.libPaths(),
    BinarySHA256=actual,Packages=setNames(vapply(packages,function(p)
      as.character(packageVersion(p)),''),packages),
    DLL=mde_sha('src/mfrmr.so'),Threads=Sys.getenv(c('OMP_NUM_THREADS',
      'OPENBLAS_NUM_THREADS','MKL_NUM_THREADS','VECLIB_MAXIMUM_THREADS')))
}
mde_key <- function(d) {
  # The six slots are fixed by the retained generator, not by row order.
  slot <- match(d$Rater,paste0('R',1:3))+3L*(match(d$Criterion,c('C1','C2'))-1L)
  stopifnot(!anyNA(slot),!anyDuplicated(paste(d$Person,slot)),
    all(d$Score %in% 0:2))
  groups <- split(seq_len(nrow(d)),d$Person)
  data.frame(Person=names(groups),Mask=vapply(groups,function(i) sum(2^(slot[i]-1)),0),
    Total=vapply(groups,function(i) sum(d$Score[i]),0),
    Ratings=lengths(groups),row.names=NULL)
}
mde_lookup <- function(keys,profile_keys) {
  key <- function(x) paste(x$Mask,x$Total)
  at <- match(key(keys),key(profile_keys))
  stopifnot(!anyNA(at)); at
}
mde_matrix <- function(prediction,persons) {
  d <- prediction$decisions
  stopifnot(nrow(d)==length(persons)*7L,!anyDuplicated(paste(d$Person,d$Label)),
    all(d$Status=='available_conditional'),all(d$PriorMean==0),all(d$PriorSD==1),
    all(d$Uncertainty=='conditional_on_point_calibration_and_prior'))
  at <- match(as.vector(t(outer(persons,mde_events,paste))),paste(d$Person,d$Label))
  stopifnot(!anyNA(at))
  p <- matrix(d$Probability[at],ncol=7L,byrow=TRUE,
    dimnames=list(persons,mde_events))
  stopifnot(all(is.finite(p)),all(p>=0 & p<=1),max(abs(rowSums(p[,4:7])-1))<1e-9,
    max(abs(p[,1]-(1-p[,4])))<1e-9,max(abs(p[,3]-p[,7]))<1e-9)
  p
}
mde_predict <- function(fit,data) {
  warnings <- character()
  result <- tryCatch(withCallingHandlers(
    predict_mfrm_units(fit,data,scoring_quad_points=61L,cut_scores=mde_cuts),
    warning=function(w) {warnings <<- c(warnings,conditionMessage(w)); invokeRestart('muffleWarning')}),
    error=identity)
  list(result=result,warnings=unique(warnings))
}

# Independent response equation; no package posterior/index/constraint helper.
mde_category <- function(theta,rows,par,model) {
  r <- c(par[1:2],-sum(par[1:2])); c <- c(par[3],-par[3])
  ri <- match(rows$Rater,paste0('R',1:3)); ci <- match(rows$Criterion,c('C1','C2'))
  step <- if(model=='RSM') rep(par[4],length(ci)) else par[3+ci]
  eta <- outer(theta,-r[ri]-c[ci],'+')
  logits <- list(matrix(0,length(theta),nrow(rows)),sweep(eta,2,step,'-'),2*eta)
  high <- Reduce(pmax,logits)
  values <- lapply(logits,function(x) exp(x-high))
  normalizer <- Reduce('+',values)
  lapply(values,function(x) x/normalizer)
}
mde_integrate <- function(f,lower,upper) {
  z <- integrate(f,lower,upper,rel.tol=1e-11,abs.tol=1e-13,subdivisions=1000L)
  stopifnot(z$message=='OK',z$abs.error<=1e-10)
  z$value
}
mde_reference <- function(rows,par,model) {
  density <- function(theta) {
    p <- mde_category(theta,rows,par,model)
    v <- rep(1,length(theta))
    for(j in seq_len(nrow(rows))) v <- v*p[[rows$Score[j]+1L]][,j]
    v*dnorm(theta)
  }
  edges <- c(-12,unname(mde_cuts),12)
  mass <- vapply(1:4,function(k) mde_integrate(density,edges[k],edges[k+1L]),0)
  stopifnot(2*pnorm(-12)/sum(mass)<1e-12)
  bands <- mass/sum(mass)
  setNames(c(rev(cumsum(rev(bands)))[2:4],bands),mde_events)
}
mde_oracle <- function(profiles,model) {
  keys <- mde_key(profiles); profiles <- profiles[order(profiles$Person),]
  par <- if(model=='RSM') c(.3,-.1,.4,-.6) else c(.3,-.1,.4,-.7,-.2)
  p <- matrix(NA_real_,nrow(keys),7L,dimnames=list(keys$Person,mde_events))
  weight <- numeric(nrow(keys)); max_pattern_error <- 0
  for(mask in unique(keys$Mask)) {
    ix <- which(keys$Mask==mask)
    rows <- profiles[profiles$Person==keys$Person[ix[1]],]
    total_density <- function(theta,total) {
      category <- mde_category(theta,rows,par,model)
      law <- matrix(1,length(theta),1L)
      for(j in seq_len(nrow(rows))) {
        next_law <- matrix(0,length(theta),ncol(law)+2L)
        for(k in 0:2) next_law[,seq_len(ncol(law))+k] <-
          next_law[,seq_len(ncol(law))+k]+law*category[[k+1L]][,j]
        law <- next_law
      }
      law[,total+1L]*dnorm(theta)
    }
    for(i in ix) {
      edges <- c(-12,unname(mde_cuts),12)
      joint <- vapply(1:4,function(k) mde_integrate(function(theta)
        total_density(theta,keys$Total[i]),edges[k],edges[k+1L]),0)
      weight[i] <- sum(joint)
      band <- joint/weight[i]
      p[i,] <- c(rev(cumsum(rev(band)))[2:4],band)
      ref <- mde_reference(profiles[profiles$Person==keys$Person[i],],par,model)
      max_pattern_error <- max(max_pattern_error,max(abs(ref-p[i,])))
    }
    prior <- c(pnorm(mde_cuts,lower.tail=FALSE),diff(pnorm(c(-Inf,mde_cuts,Inf))))
    stopifnot(abs(sum(weight[ix])-1)<1e-9,
      max(abs(colSums(p[ix,]*weight[ix])-prior))<1e-9)
  }
  stopifnot(max_pattern_error<1e-9)
  list(keys=keys,p=p,weight=weight,truth=par,MaxPatternError=max_pattern_error)
}
mde_input <- function(meta,stage,cell,replicate) {
  relative <- sprintf('%s/cell-%02d-rep-%04d.rds',stage,cell,replicate)
  path <- file.path(mde_old,relative)
  stopifnot(identical(unname(mde_sha(path)),unname(meta$Inputs[relative])))
  x <- readRDS(path)
  stopifnot(x$status$Cell==cell,x$status$Replicate==replicate,x$status$Stage==stage,
    isTRUE(x$status$Available),isTRUE(x$status$NumericalOK),
    identical(x$payload,meta$HistoricalPayload[[stage]]),
    identical(x$calibration_truth,meta$Oracle[[mde_cells$Model[cell]]]$truth),
    x$fit$config$model==mde_cells$Model[cell],x$fit$config$method=='MML',
    all(x$calibration_data$Weight==1))
  x
}
mde_guard <- function(meta) {
  stopifnot(identical(mde_sha(names(meta$Source)),meta$Source),
    identical(mde_runtime(),meta$Runtime))
}
mde_prepare <- function() {
  path <- file.path(mde_root,'metadata.rds')
  if(file.exists(path)) {mde_guard(mde_read(path)); return(invisible(TRUE))}
  historical <- read.csv(file.path(mde_old,'manifest.csv'),stringsAsFactors=FALSE)
  selected <- grepl('^(main|preflight)/cell-[0-9]{2}-rep-[0-9]{4}[.]rds$',historical$File)
  inputs <- setNames(historical$SHA256[selected],historical$File[selected])
  stopifnot(length(inputs)==2088L,
    identical(unname(mde_sha(file.path(mde_old,names(inputs)))),unname(inputs)))
  old_meta <- lapply(setNames(c('main','preflight'),c('main','preflight')),function(stage)
    readRDS(file.path(mde_old,stage,'metadata.rds')))
  stopifnot(identical(old_meta$main$Profiles,old_meta$preflight$Profiles))
  profiles <- old_meta$main$Profiles
  roadmap <- readLines('inst/validation/internal-roadmap-0.2.4.md')
  start <- which(startsWith(roadmap,'**October 10 retained-cohort probability contract'))
  end <- grep('^### 2[.] Complete existing population inference',roadmap)
  stopifnot(length(start)==1L,length(end)==1L,end>start)
  source <- c(list.files('R',pattern='[.]R$',full.names=TRUE),
    list.files('src',pattern='[.](cpp|h|hpp|so)$',full.names=TRUE),
    'DESCRIPTION','NAMESPACE',mde_script)
  dir.create(file.path(mde_root,'source'),recursive=TRUE,showWarnings=FALSE)
  for(f in source) {
    target <- file.path(mde_root,'source',f)
    dir.create(dirname(target),recursive=TRUE,showWarnings=FALSE)
    stopifnot(file.copy(f,target,overwrite=TRUE),identical(unname(mde_sha(f)),unname(mde_sha(target))))
  }
  oracle <- lapply(setNames(c('RSM','PCM'),c('RSM','PCM')),function(model)
    mde_oracle(profiles,model))
  meta <- list(Contract=roadmap[start:(end-1L)],Cuts=mde_cuts,Cells=mde_cells,
    Profiles=profiles,Inputs=inputs,HistoricalPayload=lapply(old_meta,`[[`,'Payload'),
    HistoricalManifestSHA256=mde_sha(file.path(mde_old,'manifest.csv')),
    Source=mde_sha(source),Runtime=mde_runtime(),Oracle=oracle,
    Session=sessionInfo(),Created=as.character(Sys.time()))
  mde_save(meta,path)
  cat('Prepared: 2088 historical inputs verified; two independent oracle laws complete.\n')
}
mde_preflight <- function(meta) {
  path <- file.path(mde_root,'preflight.rds')
  if(file.exists(path)) return(invisible(mde_read(path)))
  checks <- lapply(1:8,function(cell) {
    x <- mde_input(meta,'preflight',cell,1L)
    started <- proc.time()[['elapsed']]
    z <- mde_predict(x$fit,meta$Profiles)
    seconds <- proc.time()[['elapsed']]-started
    stopifnot(!inherits(z$result,'error'),!length(z$warnings))
    persons <- meta$Oracle[[mde_cells$Model[cell]]]$keys$Person
    p <- mde_matrix(z$result,persons)
    ref <- t(vapply(persons,function(person) mde_reference(
      meta$Profiles[meta$Profiles$Person==person,],x$fit$opt$par,mde_cells$Model[cell]),numeric(7)))
    fields <- c('Estimate','SD','Lower','Upper')
    legacy <- x$scores$estimates[match(z$result$estimates$Person,x$scores$estimates$Person),]
    old_error <- max(abs(as.matrix(z$result$estimates[fields])-as.matrix(legacy[fields])))
    direct_error <- 0
    for(data in list(x$cohort$three,x$cohort$data)) {
      data <- data[data$Person %in% x$cohort$truth$Person[1:48],]
      keys <- mde_key(data)
      direct <- mde_predict(x$fit,data)
      stopifnot(!inherits(direct$result,'error'),!length(direct$warnings))
      observed <- mde_matrix(direct$result,keys$Person)
      lookup <- p[mde_lookup(keys,meta$Oracle[[mde_cells$Model[cell]]]$keys),]
      direct_error <- max(direct_error,max(abs(observed-lookup)))
    }
    check <- data.frame(Cell=cell,PublicSeconds=seconds,ReferenceError=max(abs(p-ref)),
      LegacyError=old_error,RawLookupError=direct_error)
    stopifnot(max(check[c('ReferenceError','LegacyError','RawLookupError')])<1e-8)
    cat(sprintf('Preflight cell %d: public %.3fs reference %.3g lookup %.3g\n',
      cell,seconds,check$ReferenceError,direct_error)); flush.console()
    list(check=check,prediction=z$result)
  })
  mde_guard(meta)
  mde_save(list(Checks=do.call(rbind,lapply(checks,`[[`,'check')),Results=checks,
    MetadataSHA256=mde_sha(file.path(mde_root,'metadata.rds'))),path)
}
mde_metrics <- function(p,x,oracle) {
  all_metrics <- all_bins <- list()
  full_key <- paste(x$cohort$data$Person,x$cohort$data$Rater,x$cohort$data$Criterion)
  three_at <- match(paste(x$cohort$three$Person,x$cohort$three$Rater,x$cohort$three$Criterion),full_key)
  stopifnot(!anyNA(three_at),!anyDuplicated(full_key),
    identical(x$cohort$three$Score,x$cohort$data$Score[three_at]),nrow(x$cohort$truth)==512L)
  prior <- setNames(c(pnorm(mde_cuts,lower.tail=FALSE),diff(pnorm(c(-Inf,mde_cuts,Inf)))),mde_events)
  for(exposure in c(3L,6L)) {
    data <- if(exposure==3L) x$cohort$three else x$cohort$data
    keys <- mde_key(data); at <- mde_lookup(keys,oracle$keys)
    theta <- x$cohort$truth$Theta[match(keys$Person,x$cohort$truth$Person)]
    stopifnot(nrow(keys)==512L,all(keys$Ratings==exposure),!anyNA(theta),
      if(exposure==3L) all(table(keys$Mask)==256L) else length(unique(keys$Mask))==1L)
    z <- cbind(outer(theta,mde_cuts,'>'),
      outer(theta,c(-Inf,mde_cuts),'>') & outer(theta,c(mde_cuts,Inf),'<=') )*1
    colnames(z) <- mde_events
    w <- oracle$weight*(oracle$keys$Ratings==exposure)/(if(exposure==3L) 2 else 1)
    stopifnot(abs(sum(w)-1)<1e-9)
    error <- p-oracle$p
    risk <- colSums(error^2*w)
    bayes <- colSums(oracle$p*(1-oracle$p)*w)
    observed <- p[at,]; q <- oracle$p[at,]
    baseline <- matrix(prior,nrow(z),7L,byrow=TRUE)
    all_metrics[[as.character(exposure)]] <- data.frame(NewRatings=exposure,
      Event=mde_events,ExpectedBias=colSums(error*w),ExcessBrier=risk,
      OracleBrier=bayes,ExpectedBrier=bayes+risk,PriorBrier=prior*(1-prior),
      ExpectedPriorDifference=bayes+risk-prior*(1-prior),
      RealizedBias=colMeans(observed-z),RealizedBrier=colMeans((observed-z)^2),
      RealizedOracleBrier=colMeans((q-z)^2),RealizedPriorBrier=colMeans((baseline-z)^2),
      RealizedExcess=colMeans((observed-z)^2-(q-z)^2),
      RealizedPriorDifference=colMeans((observed-z)^2-(baseline-z)^2),row.names=NULL)
    all_bins[[as.character(exposure)]] <- do.call(rbind,lapply(1:7,function(j)
      do.call(rbind,lapply(1:5,function(b) {
        selected <- pmin(5L,floor(p[,j]*5)+1L)==b
        raw <- pmin(5L,floor(observed[,j]*5)+1L)==b
        data.frame(NewRatings=exposure,Event=mde_events[j],Bin=b,
          Mass=sum(w[selected]),ErrorSum=sum(w[selected]*error[selected,j]),
          PredictionSum=sum(w[selected]*p[selected,j]),TruthSum=sum(w[selected]*oracle$p[selected,j]),
          RawCount=sum(raw),RawErrorSum=sum((observed-z)[raw,j]))
      }))))
  }
  list(metrics=do.call(rbind,all_metrics),bins=do.call(rbind,all_bins))
}
mde_run <- function(meta,cells) {
  preflight <- mde_read(file.path(mde_root,'preflight.rds'))
  meta_sha <- mde_sha(file.path(mde_root,'metadata.rds'))
  stopifnot(identical(preflight$MetadataSHA256,meta_sha),all(cells %in% 1:8),!anyDuplicated(cells))
  dir.create(file.path(mde_root,'main'),showWarnings=FALSE)
  for(cell in cells) for(replicate in 1:256) {
    path <- file.path(mde_root,'main',sprintf('cell-%02d-rep-%04d.rds',cell,replicate))
    if(file.exists(path)) {
      existing <- mde_read(path)
      stopifnot(identical(existing$MetadataSHA256,meta_sha),existing$Cell==cell,
        existing$Replicate==replicate)
      next
    }
    if(replicate%%64L==1L) mde_guard(meta)
    x <- mde_input(meta,'main',cell,replicate)
    started <- proc.time()[['elapsed']]
    predicted <- mde_predict(x$fit,meta$Profiles)
    oracle <- meta$Oracle[[mde_cells$Model[cell]]]
    # A public refusal is a completed failed attempt; a driver error must be repaired.
    failure <- if(inherits(predicted$result,'error')) conditionMessage(predicted$result) else ''
    p <- if(nzchar(failure)) NULL else tryCatch(mde_matrix(predicted$result,oracle$keys$Person),error=identity)
    if(inherits(p,'error')) {failure <- conditionMessage(p); p <- NULL}
    metrics <- if(is.null(p)) NULL else mde_metrics(p,x,oracle)
    fields <- c('Estimate','SD','Lower','Upper')
    legacy_error <- if(is.null(p)) NA_real_ else max(abs(
      as.matrix(predicted$result$estimates[fields])-
      as.matrix(x$scores$estimates[match(predicted$result$estimates$Person,x$scores$estimates$Person),fields])))
    if(!is.null(p)) stopifnot(legacy_error<1e-8)
    record <- list(Cell=cell,Replicate=replicate,Available=!is.null(p),Error=failure,
      Warnings=predicted$warnings,LegacyError=legacy_error,Prediction=predicted$result,
      Probabilities=p,Metrics=metrics,Seconds=proc.time()[['elapsed']]-started,
      InputSHA256=meta$Inputs[sprintf('main/cell-%02d-rep-%04d.rds',cell,replicate)],
      MetadataSHA256=meta_sha)
    mde_save(record,path)
    if(replicate%%32L==0L || nzchar(failure)) {
      cat(sprintf('Cell %d replicate %d/256: %.3fs available=%s %s\n',
        cell,replicate,record$Seconds,record$Available,failure)); flush.console()
    }
  }
  mde_guard(meta)
}
if(sys.nframe()==0L) {
  args <- commandArgs(TRUE)
  stopifnot(length(args)>=1L,args[1] %in% c('prepare','preflight','run'))
  pkgload::load_all('.',quiet=TRUE,compile=FALSE)
  # Load before taking a runtime record; no numerical-runtime alias is introduced.
  requireNamespace('jsonlite'); requireNamespace('digest')
  if(args[1]=='prepare') mde_prepare() else {
    meta <- mde_read(file.path(mde_root,'metadata.rds')); mde_guard(meta)
    if(args[1]=='preflight') mde_preflight(meta) else {
      cells <- if(length(args)>=2L) as.integer(strsplit(args[2],',',fixed=TRUE)[[1]]) else 1:8
      mde_run(meta,cells)
    }
  }
}
