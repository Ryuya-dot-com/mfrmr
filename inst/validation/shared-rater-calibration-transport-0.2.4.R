.libPaths(c(normalizePath('.r-library'),.libPaths()))
out <- 'validation-results/shared-rater-calibration-reference-20260923'
prefix <- 'inst/validation/shared-rater-calibration-transport-0.2.4'
plan <- readRDS(file.path(out,'plan.rds'))
stopifnot(identical(plan$source,tools::md5sum(names(plan$source))))
files <- c(paste0(prefix,c('.R','.cpp','.md')),file.path(out,c('plan.rds','summary.rds')),
  file.path(out,sprintf('case-%02d.rds',1:8)))
frozen <- file.path(out,'transport-plan.rds')
if(!file.exists(frozen)) {
  saveRDS(list(source=tools::md5sum(files),created=Sys.time(),session=sessionInfo()),frozen)
  for(f in files[!grepl('^validation-results/',files)]) {
    dest <- file.path(out,'transport-source',f);dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
    stopifnot(file.copy(f,dest))
  }
}
stopifnot(identical(readRDS(frozen)$source,tools::md5sum(files)))
Rcpp::sourceCpp(paste0(prefix,'.cpp'),cacheDir=file.path(out,'transport-compile'),showOutput=FALSE)

# Direct scalar R joint density and analytic latent derivatives.
components <- function(z,par,input) {
  np <- max(input$person);nr <- max(input$rater);b <- z[1:np];u <- z[np+1:nr]
  eta <- b[input$person]-u[input$rater]-drop(input$X%*%par[1:2])
  logits <- cbind(0,eta-par[3],2*eta-par[3]-par[4]);m <- apply(logits,1,max)
  weights <- exp(logits-m);den <- rowSums(weights);probs <- weights/den
  mean <- probs[,2]+2*probs[,3];variance <- probs[,2]+4*probs[,3]-mean^2
  value <- -sum(logits[cbind(seq_along(eta),input$y+1)]-m-log(den))-
    sum(dnorm(b,sd=par[6],log=TRUE))-sum(dnorm(u,sd=par[5],log=TRUE))
  totals <- function(v,id) as.vector(rowsum(v,id))
  gradient <- c(totals(mean-input$y,input$person)+b/par[6]^2,
    totals(input$y-mean,input$rater)+u/par[5]^2)
  H <- diag(c(totals(variance,input$person)+1/par[6]^2,
    totals(variance,input$rater)+1/par[5]^2))
  v <- rowsum(variance,(input$person-1L)*nr+input$rater)
  k <- as.integer(rownames(v));p <- (k-1L)%/%nr+1L;r <- (k-1L)%%nr+1L
  H[cbind(p,np+r)] <- -v;H[cbind(np+r,p)] <- -v
  list(value=value,gradient=gradient,H=H)
}
mode_at <- function(par,input,start) {
  z <- start
  for(iteration in 1:50) {
    s <- components(z,par,input)
    if(max(abs(s$gradient))<1e-7) break
    R <- chol(s$H);delta <- backsolve(R,forwardsolve(t(R),s$gradient))
    length <- 1
    for(line in 1:30) {
      proposed <- z-length*delta
      if(components(proposed,par,input)$value <= s$value-1e-4*length*sum(s$gradient*delta)+1e-10) break
      length <- length/2
    }
    if(line==30) stop('Latent mode line search unresolved')
    z <- proposed
  }
  s <- components(z,par,input)
  stopifnot(max(abs(s$gradient))<1e-7)
  R <- chol(s$H);n <- length(z)
  directions <- cbind(rep(1/sqrt(n),n),c(1,rep(0,n-1)),c(rep(0,n-1),1))
  checks <- sapply(1:3,function(j) {
    v <- directions[,j];plus <- components(z+1e-5*v,par,input);minus <- components(z-1e-5*v,par,input)
    c(Gradient=abs((plus$value-minus$value)/2e-5-sum(s$gradient*v)),
      Hessian=max(abs((plus$gradient-minus$gradient)/2e-5-s$H%*%v)))
  })
  stopifnot(max(checks['Gradient',])<1e-6,max(checks['Hessian',])<1e-5)
  list(mode=z,R=R,gradient=max(abs(s$gradient)),checks=checks,iterations=iteration)
}
start_all <- proc.time()[['elapsed']]
for(rec in plan$records) {
  destination <- file.path(out,sprintf('transport-%02d.rds',rec$index))
  if(file.exists(destination)) next
  if(proc.time()[['elapsed']]-start_all>1200) stop('Transport execution budget reached')
  begin <- proc.time()[['elapsed']]
  original <- readRDS(file.path(out,sprintf('case-%02d.rds',rec$index)))
  x <- readRDS(rec$case_file);a <- unclass(x$draws)
  np <- rec$stan_data$P;nr <- rec$stan_data$R
  z <- matrix(a[,,c(paste0('theta[',1:np,']'),paste0('severity[',1:nr,']'))],nrow=32000)
  par <- rec$fit$coefficients;input <- rec$input;pars <- sweep(rec$changes,1,par,'+')
  base <- mode_at(par,input,rep(0,np+nr))
  standardized <- base$R%*%t(sweep(z,2,base$mode,'-'))
  joint <- function(z,p) calibration_joint_logdensity(z,np,input$person,input$rater,input$y,
    drop(input$X%*%p[1:2]),p)
  base_density <- joint(z,par)
  stan_error <- max(abs(base_density-as.vector(a[,,'log_joint'])))
  stopifnot(stan_error<1e-8)
  values <- maps <- list();weights <- matrix(NA_real_,32000,ncol(pars))
  for(j in 1:ncol(pars)) {
    map <- if(j==1) base else mode_at(pars[,j],input,base$mode)
    transformed <- sweep(t(backsolve(map$R,standardized)),2,map$mode,'+')
    log_jacobian <- sum(log(diag(base$R)))-sum(log(diag(map$R)))
    determinant_error <- abs(as.numeric(determinant(backsolve(map$R,base$R),logarithm=TRUE)$modulus)-log_jacobian)
    stopifnot(determinant_error<1e-8)
    lw <- joint(transformed,pars[,j])-base_density+log_jacobian
    at <- 1L+8000L*(0:3)
    direct_error <- max(vapply(at,function(i)abs(lw[i]-(
      -components(transformed[i,],pars[,j],input)$value+components(z[i,],par,input)$value+log_jacobian)),numeric(1)))
    stopifnot(all(is.finite(lw)),direct_error<1e-8)
    weights[,j] <- lw;maps[[j]] <- c(map,list(log_jacobian=log_jacobian,determinant_error=determinant_error,
      direct_error=direct_error))
    if(j==1) {stopifnot(max(abs(lw))<1e-10);next}
    m <- max(lw);w <- matrix(exp(lw-m),nrow=8000,ncol=4)
    mn <- mean(w);mc <- posterior::mcse_mean(w)
    lower <- if(mn>4*mc) log(mn-4*mc)+m else -Inf
    upper <- log(mn+4*mc)+m
    row <- data.frame(rec$points[j,,drop=FALSE],Reference=log(mn)+m,ReferenceLower=lower,ReferenceUpper=upper,
      LogMCSE=mc/mn,Rhat=posterior::rhat(w),BulkESS=posterior::ess_bulk(w),TailESS=posterior::ess_tail(w),
      ImportanceESS=sum(w)^2/sum(w^2),ParetoK=as.numeric(loo::pareto_k_values(loo::psis(as.vector(lw)))),
      Laplace=original$stats$Laplace[j-1],QuadratureDifference=original$stats$QuadratureDifference[j-1],DirectError=direct_error)
    ready <- with(row,all(is.finite(unlist(row[-1]))) && Rhat<1.01 && BulkESS>=400 && TailESS>=400 &&
      ImportanceESS>=1000 && ParetoK<.5 && LogMCSE<=.01)
    row$Error <- row$Laplace-row$Reference
    row$MaxErrorAllowance <- max(abs(row$Laplace-c(lower,upper)))
    row$Decision <- if(!ready) 'reference_unresolved' else if(row$QuadratureDifference>=1e-5)
      'person_quadrature_unresolved' else if(row$MaxErrorAllowance<=.05) 'bounded_agreement' else if(
        row$Laplace-lower < -.05 || row$Laplace-upper > .05) 'material_discrepancy' else 'inconclusive'
    values[[j-1]] <- row
  }
  result <- list(index=rec$index,trial=rec$trial,stats=do.call(rbind,values),maps=maps,
    log_weights=weights,stan_error=stan_error,zero_error=max(abs(weights[,1])),
    source=tools::md5sum(c(rec$case_file,file.path(out,sprintf('case-%02d.rds',rec$index)),frozen)),
    seconds=proc.time()[['elapsed']]-begin,completed=Sys.time())
  saveRDS(result,destination)
  cat('Affine case',rec$index,':',paste(names(table(result$stats$Decision)),table(result$stats$Decision),collapse='; '),
    'seconds',result$seconds,'\n');flush.console()
  rm(x,a,z,standardized,weights);invisible(gc())
  size <- sum(file.info(list.files(out,pattern='^transport',recursive=TRUE,full.names=TRUE))$size,na.rm=TRUE)
  if(size>512*1024^2) stop('Transport artifact budget reached')
}
