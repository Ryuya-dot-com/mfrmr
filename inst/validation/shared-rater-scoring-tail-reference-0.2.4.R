# Deterministic conditional integration using an existing joint posterior.
.libPaths(c(normalizePath('.r-library'),.libPaths()))
out <- 'validation-results/shared-rater-scoring-reference-20260923'
prefix <- 'inst/validation/shared-rater-scoring-tail-reference-0.2.4'
plan <- readRDS(file.path(out,'plan.rds'))
files <- c(paste0(prefix,c('.R','.md')),file.path(out,'plan.rds'))
path <- file.path(out,'tail-plan.rds')
if(!file.exists(path)) {
  saveRDS(list(source=tools::md5sum(files),created=Sys.time(),session=sessionInfo()),path)
  for(f in files) {
    dest <- file.path(out,'tail-source',f);dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
    stopifnot(file.copy(f,dest))
  }
}
stopifnot(identical(readRDS(path)$source,tools::md5sum(files)))
rules <- lapply(c(128L,256L),function(n) statmod::gauss.quad(n,kind='legendre'))
stopifnot(all(vapply(rules,function(r) abs(sum(12*r$weights*dnorm(12*r$nodes))-1)<1e-12,logical(1))))
likelihood <- function(z,u,input,cal,rows) {
  logp <- matrix(0,nrow(u),length(z))
  offsets <- drop(input$X[rows,,drop=FALSE] %*% cal$beta)
  cumulative <- c(0,cumsum(cal$steps))
  for(j in seq_along(rows)) {
    i <- rows[j];eta <- outer(-u[,input$rater[i]],cal$person_sd*z,'+')-offsets[j]
    lw <- lapply(0:length(cal$steps),function(k) k*eta-cumulative[k+1])
    shift <- Reduce(pmax,lw)
    logp <- logp + input$y[i]*eta-cumulative[input$y[i]+1]-shift-
      log(Reduce('+',lapply(lw,function(x) exp(x-shift))))
  }
  exp(logp)
}
integral <- function(rule,upper,u,input,cal,rows) {
  stopifnot(upper>-12,upper<=12)
  z <- -12+(upper+12)*(rule$nodes+1)/2
  weight <- (upper+12)*rule$weights*dnorm(z)/2
  answer <- numeric(nrow(u))
  for(first in seq(1L,nrow(u),by=1000L)) {
    at <- first:min(nrow(u),first+999L)
    answer[at] <- drop(likelihood(z,u[at,,drop=FALSE],input,cal,rows)%*%weight)
  }
  answer
}
for(rec in plan$records) {
  source <- file.path(out,sprintf('case-%02d.rds',rec$index))
  result_path <- file.path(out,sprintf('tails-%02d.rds',rec$index))
  if(!file.exists(source) || file.exists(result_path)) next
  x <- readRDS(source);start <- proc.time()[['elapsed']]
  u <- sapply(seq_len(rec$stan_data$R),function(i)
    as.vector(x$draws[seq(1L,8000L,by=4L),,paste0('severity[',i,']')]))
  results <- list()
  for(id in rec$persons) {
    a <- x$scores$table[x$scores$table$Person==id,]
    if(is.null(a) || !identical(a$Status,'available_conditional')) {
      results[[id]] <- list(available=FALSE,reason='Production score unavailable');next
    }
    rows <- which(rec$input$person==match(id,rec$input$levels$Person))
    cuts <- c(a$Lower-.1,a$Lower+.1,a$Upper-.1,a$Upper+.1)
    values <- lapply(rules,function(rule) {
      norm <- integral(rule,12,u,rec$input,rec$fit$calibration,rows)
      cdf <- sapply(cuts/rec$fit$calibration$person_sd,function(t)
        integral(rule,t,u,rec$input,rec$fit$calibration,rows)/norm)
      list(norm=norm,cdf=cdf)
    })
    delta <- max(abs(values[[1]]$cdf-values[[2]]$cdf))
    norm_delta <- max(abs(values[[1]]$norm/values[[2]]$norm-1))
    tail_bound <- 2*pnorm(-12)/min(values[[2]]$norm)
    continuous <- function(upper) integrate(function(z)
      drop(likelihood(z,u[1,,drop=FALSE],rec$input,rec$fit$calibration,rows))*dnorm(z),
      -Inf,upper,rel.tol=1e-10,abs.tol=1e-13,subdivisions=200L)
    norm <- continuous(Inf)
    ref <- lapply(cuts/rec$fit$calibration$person_sd,continuous)
    continuous_error <- max(abs(vapply(ref,`[[`,numeric(1),'value')/norm$value-values[[2]]$cdf[1,]))
    continuous_norm_error <- abs(norm$value/values[[2]]$norm[1]-1)
    numeric_ready <- all(is.finite(values[[2]]$norm)) && min(values[[2]]$norm)>=1e-12 &&
      is.finite(delta) && delta<=1e-7 && norm_delta<=1e-7 && tail_bound<=1e-12 &&
      continuous_error<=1e-8 && continuous_norm_error<=1e-8 &&
      identical(norm$message,'OK') && all(vapply(ref,function(z)identical(z$message,'OK'),logical(1)))
    stats <- do.call(rbind,lapply(1:4,function(j) {
      v <- matrix(values[[2]]$cdf[,j],nrow=2000,ncol=4)
      data.frame(Cut=cuts[j],Mean=mean(v),MCSE=posterior::mcse_mean(v),Rhat=posterior::rhat(v),
        BulkESS=posterior::ess_bulk(v),TailESS=posterior::ess_tail(v))
    }))
    stats$Lower <- stats$Mean-4*stats$MCSE-max(delta,tail_bound)
    stats$Upper <- stats$Mean+4*stats$MCSE+max(delta,tail_bound)
    decisions <- vapply(1:2,function(j) {
      at <- (j-1)*2+1:2;p <- c(.025,.975)[j];s <- stats[at,]
      ready <- isTRUE(x$reference_ready) && numeric_ready &&
        all(is.finite(s$MCSE) & s$MCSE<=.0005 & is.finite(s$Rhat) & s$Rhat<1.01 &
          is.finite(s$BulkESS) & s$BulkESS>=400 & is.finite(s$TailESS) & s$TailESS>=400)
      if(!ready) 'reference_unresolved' else if(s$Upper[1]<=p && s$Lower[2]>=p)
        'bounded_agreement' else if(s$Lower[1]>p || s$Upper[2]<p)
          'material_discrepancy' else 'inconclusive'
    },character(1))
    results[[id]] <- list(available=TRUE,stats=stats,decision=setNames(decisions,c('Lower','Upper')),
      numeric_ready=numeric_ready,cdf_difference=delta,normalizer_difference=norm_delta,
      min_normalizer=min(values[[2]]$norm),tail_bound=tail_bound,
      continuous_error=continuous_error,continuous_normalizer_error=continuous_norm_error,
      continuous_reference=list(normalizer=norm,cdf=ref),cdf=values[[2]]$cdf)
  }
  result <- list(index=rec$index,source=tools::md5sum(source),results=results,
    seconds=proc.time()[['elapsed']]-start,completed=Sys.time())
  saveRDS(result,result_path)
  cat('Tail reference case',rec$index,':',paste(unlist(lapply(results,`[[`,'decision')),collapse=', '),
    'seconds',result$seconds,'\n');flush.console()
}
