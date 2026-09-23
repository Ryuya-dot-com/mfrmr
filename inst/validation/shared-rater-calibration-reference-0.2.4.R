# Local likelihood-shape comparison using existing posterior draws only.
.libPaths(c(normalizePath('.r-library'),.libPaths()))
pkgload::load_all('.',quiet=TRUE)
out <- 'validation-results/shared-rater-calibration-reference-20260923'
input_dir <- 'validation-results/shared-rater-scoring-reference-20260923'
prefix <- 'inst/validation/shared-rater-calibration-reference-0.2.4'
args <- commandArgs(TRUE); mode <- if(length(args)) args[1] else 'summary'
plan_file <- file.path(out,'plan.rds')
if(mode=='init') {
  stopifnot(!file.exists(plan_file))
  old <- readRDS(file.path(input_dir,'plan.rds'))
  records <- old$records[1:8]
  for(i in seq_along(records)) {
    rec <- records[[i]]; v <- rec$fit$covariance; par <- rec$fit$coefficients
    stopifnot(rec$roster=='full',length(par)==6L,all(is.finite(v)),
      isTRUE(rec$fit$checks$NumericalReady),isTRUE(rec$fit$checks$InformationPositive))
    c1 <- which(as.character(rec$input$data$Criterion)=='C1')[1]
    c3 <- which(as.character(rec$input$data$Criterion)=='C3')[1]
    targets <- cbind(c(rec$input$X[c3,]-rec$input$X[c1,],rep(0,4)),diag(6)[,5:6])
    directions <- cbind(t(chol(v)),v%*%targets%*%diag(1/sqrt(diag(t(targets)%*%v%*%targets))))
    colnames(directions) <- c(paste0('information_',1:6),'C3_minus_C1','rater_sd','person_sd')
    stopifnot(max(abs(diag(t(directions)%*%rec$fit$information%*%directions)-1))<1e-8)
    changes <- cbind(rep(0,6),do.call(cbind,lapply(1:ncol(directions),function(j)
      cbind(-directions[,j],directions[,j]))))
    rownames(changes) <- names(par)
    points <- data.frame(Direction=c('control',rep(colnames(directions),each=2)),
      Sign=c(0,rep(c(-1,1),ncol(directions))))
    rec$directions <- directions;rec$changes <- changes;rec$points <- points
    rec$case_file <- file.path(input_dir,sprintf('case-%02d.rds',rec$index))
    records[[i]] <- rec
  }
  files <- c(paste0(prefix,c('.R','.cpp','.md')), 'R/api-random-rater.R',
    file.path(input_dir,c('plan.rds','summary.rds')),
    vapply(records,`[[`,character(1),'case_file'))
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  source_files <- tools::md5sum(files)
  saveRDS(list(records=records,source=source_files,created=Sys.time(),session=sessionInfo()),plan_file)
  for(f in files[!grepl('^validation-results/',files)]) {
    dst <- file.path(out,'source',f);dir.create(dirname(dst),recursive=TRUE,showWarnings=FALSE)
    stopifnot(file.copy(f,dst))
  }
  cat('Frozen eight rosters and 144 nonzero likelihood points.\n')
  quit(status=0)
}
plan <- readRDS(plan_file)
stopifnot(identical(plan$source,tools::md5sum(names(plan$source))))
if(mode=='run') {
  start_all <- proc.time()[['elapsed']]
  Rcpp::sourceCpp(paste0(prefix,'.cpp'),cacheDir=file.path(out,'compile'),showOutput=FALSE)
  direct_joint <- function(b,u,par,input) {
    eta <- b[input$person]-u[input$rater]-drop(input$X%*%par[1:2])
    cumulative <- c(0,cumsum(par[3:4]))
    logits <- outer(eta,0:2)-matrix(rep(cumulative,each=length(eta)),ncol=3)
    shift <- apply(logits,1,max)
    sum(input$y*eta-cumulative[input$y+1]-shift-log(rowSums(exp(logits-shift))))+
      sum(dnorm(b,sd=par[6],log=TRUE))+sum(dnorm(u,sd=par[5],log=TRUE))
  }
  original_summary <- readRDS(file.path(input_dir,'summary.rds'))
  for(rec in plan$records) {
    destination <- file.path(out,sprintf('case-%02d.rds',rec$index))
    if(file.exists(destination)) next
    if(proc.time()[['elapsed']]-start_all>1200) stop('Execution budget reached; keep unfinished cases.')
    begin <- proc.time()[['elapsed']]
    x <- readRDS(rec$case_file);a <- unclass(x$draws)
    stopifnot(isTRUE(x$reference_ready),identical(dim(a)[1:2],c(8000L,4L)),
      original_summary$status$MaxLogJointError[rec$index]<1e-8)
    b <- matrix(a[,,paste0('theta[',1:rec$stan_data$P,']')],nrow=32000)
    u <- matrix(a[,,paste0('severity[',1:rec$stan_data$R,']')],nrow=32000)
    input <- rec$input;par <- rec$fit$coefficients;delta <- rec$changes
    pars <- sweep(delta,1,par,'+')
    if(any(pars[5:6,]<=0)) stop('Nonpositive planned SD: preserve point as unresolved before execution.')
    dx <- input$X%*%delta[1:2,,drop=FALSE]
    shift <- rowsum(dx,input$person)/as.numeric(table(input$person))
    shift <- sweep(shift,2,colMeans(delta[3:4,,drop=FALSE]),'+')
    change_eta <- shift[input$person,,drop=FALSE]-dx
    change_cumulative <- rbind(0,delta[3,],delta[3,]+delta[4,])
    constant <- colSums(input$y*change_eta-change_cumulative[input$y+1,,drop=FALSE])
    weights <- translated_log_weights(b,u,input$person,input$rater,
      drop(input$X%*%par[1:2]),par[3:4],change_eta,delta[3:4,,drop=FALSE],
      shift,constant,pars[5,],pars[6,],par[5],par[6])
    stopifnot(all(is.finite(weights)),max(abs(weights[,1]))<1e-10)
    at <- 1L+8000L*(0:3)
    direct_error <- sapply(seq_len(ncol(delta)),function(j)
      max(vapply(at,function(i) abs(weights[i,j]-(
        direct_joint(b[i,]+shift[,j],u[i,],pars[,j],input)-direct_joint(b[i,],u[i,],par,input))),numeric(1))))
    stopifnot(all(direct_error<1e-8))
    likelihood <- sapply(c(123L,241L),function(q) {
      objective <- mfrm_random_rater_objective(input,q,fixed_person_sd=NULL)
      value <- vapply(seq_len(ncol(pars)),function(j) -as.numeric(objective$fn(pars[,j])),numeric(1))
      value
    })
    stopifnot(all(is.finite(likelihood)))
    relative <- sweep(likelihood,2,likelihood[1,],'-')
    stats <- lapply(2:ncol(weights),function(j) {
      lw <- matrix(weights[,j],nrow=8000,ncol=4);m <- max(lw);w <- exp(lw-m)
      mn <- mean(w);mc <- posterior::mcse_mean(w)
      lower <- if(mn>4*mc) log(mn-4*mc)+m else -Inf
      upper <- log(mn+4*mc)+m
      khat <- as.numeric(loo::pareto_k_values(loo::psis(as.vector(lw))))
      row <- data.frame(rec$points[j,,drop=FALSE],Reference=log(mn)+m,
        ReferenceLower=lower,ReferenceUpper=upper,LogMCSE=mc/mn,
        Rhat=posterior::rhat(w),BulkESS=posterior::ess_bulk(w),TailESS=posterior::ess_tail(w),
        ImportanceESS=sum(w)^2/sum(w^2),ParetoK=khat,Laplace=relative[j,2],
        QuadratureDifference=abs(diff(relative[j,])),DirectError=direct_error[j])
      ready <- with(row,all(is.finite(unlist(row[-1]))) && Rhat<1.01 && BulkESS>=400 &&
        TailESS>=400 && ImportanceESS>=1000 && ParetoK<.5 && LogMCSE<=.01)
      row$Error <- row$Laplace-row$Reference
      row$MaxErrorAllowance <- max(abs(row$Laplace-c(lower,upper)))
      row$Decision <- if(!ready) 'reference_unresolved' else if(row$QuadratureDifference>=1e-5)
        'person_quadrature_unresolved' else if(row$MaxErrorAllowance<=.05) 'bounded_agreement' else if(
          row$Laplace-lower < -.05 || row$Laplace-upper > .05) 'material_discrepancy' else 'inconclusive'
      row
    })
    result <- list(index=rec$index,trial=rec$trial,stats=do.call(rbind,stats),
      log_weights=weights,log_likelihood=likelihood,direct_error=direct_error,
      zero_error=max(abs(weights[,1])),source=tools::md5sum(c(rec$case_file,plan_file)),
      seconds=proc.time()[['elapsed']]-begin,completed=Sys.time())
    saveRDS(result,destination)
    cat('Case',rec$index,'trial',rec$trial,':',paste(names(table(result$stats$Decision)),
      table(result$stats$Decision),collapse='; '),'seconds',result$seconds,'\n');flush.console()
    rm(x,a,b,u,weights);invisible(gc())
    size <- sum(file.info(list.files(out,recursive=TRUE,full.names=TRUE))$size,na.rm=TRUE)
    if(size>512*1024^2) stop('New-artifact budget reached; keep unfinished cases.')
  }
} else if(mode=='summary') {
  status <- do.call(rbind,lapply(plan$records,function(rec) {
    path <- file.path(out,sprintf('case-%02d.rds',rec$index))
    data.frame(Case=rec$index,Trial=rec$trial,Complete=file.exists(path))
  }))
  values <- lapply(plan$records,function(rec) {
    path <- file.path(out,sprintf('case-%02d.rds',rec$index))
    if(!file.exists(path)) return(NULL)
    x <- readRDS(path)
    stopifnot(identical(x$source,tools::md5sum(names(x$source))))
    cbind(Case=rec$index,Trial=rec$trial,Condition=rec$condition,x$stats)
  })
  values <- do.call(rbind,values)
  saveRDS(list(status=status,comparisons=values,source=plan$source),file.path(out,'summary.rds'))
  write.csv(values,file.path(out,'comparisons.csv'),row.names=FALSE)
  print(status,row.names=FALSE)
  if(nrow(values)) {
    print(table(values$Case,values$Decision))
    print(aggregate(cbind(AbsoluteError=abs(Error),MaxErrorAllowance,LogMCSE,ParetoK,
      QuadratureDifference,DirectError)~Case,values,max),row.names=FALSE)
  }
} else stop('Use init, run or summary.')
