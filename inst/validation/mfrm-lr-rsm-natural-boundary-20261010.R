# Repository-only continuation of saved numerical failures; no new responses.
# Single-threaded retained runtime. Actions: check | run [draw] | summarize.
script <- 'inst/validation/mfrm-lr-rsm-natural-boundary-20261010.R'
prior <- 'validation-results/mfrm-lr-rsm-null-bootstrap-20261010'
out <- 'validation-results/mfrm-lr-rsm-natural-boundary-20261010'
old_script <- 'inst/validation/mfrm-lr-rsm-null-bootstrap-20261010.R'
audit_path <- file.path(prior,'verification.rds')
stopifnot(unname(tools::md5sum(audit_path))=='118277ee88a63f79612385c49d4e1481')
# Reuse only pure helpers, without the original driver's generation/dispatch.
wanted <- c('verify','save_atomic','phase','require_phase','context','review')
for(expr in parse(old_script)) if(is.call(expr) && identical(expr[[1]],as.name('<-')) &&
  is.symbol(expr[[2]]) && as.character(expr[[2]]) %in% wanted) eval(expr)
audit <- readRDS(audit_path); stopifnot(audit$passed); verify(audit$retained); verify(audit$script)
old <- readRDS(file.path(prior,'manifest.rds')); controls <- old$controls
pkgload::load_all('.',quiet=TRUE,compile=FALSE)
source('inst/validation/mfrm-lr-rsm-boundary-20261009.R')
verify(old$source[names(old$source)!='loaded_mfrmr_DLL'])
stopifnot(unname(tools::md5sum(getLoadedDLLs()[['mfrmr']][['path']]))==
  unname(old$source['loaded_mfrmr_DLL']),identical(sessionInfo(),old$session),
  identical(Sys.getenv(names(old$threads)),old$threads))
profile <- readRDS('validation-results/mfrm-lr-rsm-adaptive-profile-20261010/manifest.rds')
fit_paths <- names(profile$inputs)[endsWith(names(profile$inputs),'-fit.rds')]
key <- function(k,b) sprintf('case-%02d-draw-%03d',k,b)
read_old <- function(k,b,stage) readRDS(file.path(prior,paste0(key(k,b),'-',stage,'.rds')))
summary_old <- readRDS(file.path(prior,'summary.rds'))
eligible <- function(k,b) {
  result <- read_old(k,b,'result')
  if(result$status!='unavailable' || !result$reason %in%
      c('Unrestricted two-start checks failed.','Interior/zero selection is unresolved.')) return(FALSE)
  f <- read_old(k,b,'free')$value; z <- read_old(k,b,'zero')$value
  ch <- do.call(rbind,lapply(f$attempts,`[[`,'check'))
  isTRUE(z$qualified && nrow(ch)==2L && all(ch$Passed) &&
    z$natural_variance_score<=-controls$boundary_margin &&
    all(ch$NLL>=z$nll-controls$boundary_margin))
}
units <- summary_old$trials[c('Case','Draw')]
units$Continue <- mapply(eligible,units$Case,units$Draw)
targets <- subset(units,Continue)
stopifnot(nrow(targets)==6L,all(targets$Case==3L),identical(targets$Draw,c(5L,7L,9L,10L,12L,17L)))
reference_points <- rbind(do.call(rbind,lapply(c('warm','neutral'),function(s)
  data.frame(Case=targets$Case,Draw=targets$Draw,Start=s))),
  data.frame(Case=c(3L,4L),Draw=c(3L,1L),Start='selected'))
settings <- list(maxit=400L,factr=100,pgtol=1e-8,reference_allowance=1e-5,
  forward_steps=c(1e-4,5e-5,2.5e-5),reference_points=reference_points)
manifest <- list(controls=controls,settings=settings,units=units,
  inputs=c(tools::md5sum(audit_path),audit$retained),
  source=c(tools::md5sum(script),old$source),session=sessionInfo(),threads=old$threads,
  rng_head=tools::md5sum('validation-results/mfrm-wide-map-r50-20261001/rng-head.rds'),
  purpose='Natural-variance boundary continuation; numerical development, not coverage validation.')
dir.create(out,recursive=TRUE,showWarnings=FALSE)
manifest_path <- file.path(out,'manifest.rds')
if(file.exists(manifest_path)) stopifnot(identical(readRDS(manifest_path),manifest)) else
  save_atomic(manifest,manifest_path)
binding <- unname(tools::md5sum(manifest_path))
unit_context <- function(k,b) {
  fit <- readRDS(fit_paths[old$cases$PriorCase[k]])$payload$value
  input <- require_phase(read_old(k,b,'input'))
  fit$prep$data$Score <- fit$prep$data$score_k <- input$scores
  context(fit)
}

# The boundary has a one-sided variance derivative, not a zero log-variance score.
natural_evaluator <- function(evaluator,ctx) {
  cached <- state <- NULL
  evaluate <- function(par) {
    if(identical(par,cached)) return(state)
    stopifnot(length(par)==ctx$p+1L,all(is.finite(par)),tail(par,1L)>=0)
    v <- tail(par,1L); eta <- head(par,-1L)
    if(v==0) {
      z <- rsm_lr_boundary_eval(ctx,eta)
      answer <- list(value=z$value,gradient=c(z$gradient,-z$natural_variance_score))
    } else {
      p <- c(eta,log(v)); g <- evaluator$gradient(p); g[length(g)] <- tail(g,1L)/v
      answer <- list(value=evaluator$value(p),gradient=g)
    }
    stopifnot(all(is.finite(c(answer$value,answer$gradient))))
    cached <<- par+0; state <<- answer; answer
  }
  list(evaluate=evaluate,value=function(p)evaluate(p)$value,gradient=function(p)evaluate(p)$gradient)
}

# Heat identity: f''/f = U^2-A. Continuous integrals avoid division by v.
heat_reference <- function(ctx,eta,v) {
  stopifnot(is.finite(v),v>=0)
  z <- rsm_lr_boundary_eval(ctx,eta); categories <- 0:(ctx$K-1L)
  details <- lapply(ctx$groups,function(rows) {
    kernel <- function(nodes) {
      logp <- U <- A <- numeric(length(nodes))
      for(row in rows) {
        logits <- outer(sqrt(v)*nodes,categories)+
          matrix(z$logits[row,],length(nodes),ctx$K,byrow=TRUE)
        peak <- apply(logits,1L,max); lp <- logits-peak-log(rowSums(exp(logits-peak)))
        p <- exp(lp); mean <- drop(p %*% categories)
        logp <- logp+lp[,ctx$y[row]+1L]; U <- U+ctx$y[row]-mean
        A <- A+rowSums(p*(matrix(categories,length(nodes),ctx$K,byrow=TRUE)-mean)^2)
      }
      list(logp=logp,score=(U^2-A)/2)
    }
    base <- kernel(0)$logp
    integral <- function(score) integrate(function(nodes) {
      a <- kernel(nodes); value <- exp(a$logp-base+dnorm(nodes,log=TRUE))
      if(score) value*a$score else value
    },-Inf,Inf,rel.tol=1e-11,abs.tol=1e-13,subdivisions=200L)
    d <- integral(FALSE); n <- integral(TRUE); relative <- d$abs.error/d$value
    stopifnot(d$message=='OK',n$message=='OK',d$value>0,relative<1e-10)
    score <- n$value/d$value
    c(nll=-base-log(d$value),gradient=-score,nll_error=relative,
      gradient_error=(n$abs.error/d$value+abs(score)*relative)/(1-relative))
  })
  details <- do.call(rbind,details)
  list(value=sum(details[,'nll']),gradient=sum(details[,'gradient']),
    nll_error=sum(details[,'nll_error']),gradient_error=sum(details[,'gradient_error']),details=details)
}
reference_key <- function(k,b,start) paste0(key(k,b),'-reference-',start)
check_reference <- function(row) {
  k<-row$Case; b<-row$Draw; start<-row$Start
  dependency <- tools::md5sum(file.path(prior,paste0(key(k,b),c('-input.rds','-free.rds'))))
  phase(reference_key(k,b,start),dependency,function() {
    e <- unit_context(k,b); f <- read_old(k,b,'free')$value
    p <- if(start=='selected') f$parameters else f$attempts[[start]]$parameters
    v <- exp(tail(p,1L)); par <- c(head(p,-1L),v)
    a <- natural_evaluator(e$low,e$ctx)$evaluate(par)
    h <- natural_evaluator(e$high,e$ctx)$evaluate(par)
    ref <- heat_reference(e$ctx,head(par,-1L),v)
    checks <- c(nll_agreement=abs(a$value-h$value)<=controls$nll,
      gradient_agreement=max(abs(a$gradient-h$gradient))<=controls$gradient,
      nll_reference=max(abs(c(a$value,h$value)-ref$value))+ref$nll_error<=controls$nll,
      gradient_reference=max(abs(c(tail(a$gradient,1),tail(h$gradient,1))-ref$gradient))+
        ref$gradient_error<=controls$gradient,reference_allowance=ref$gradient_error<=settings$reference_allowance)
    list(passed=all(checks),checks=checks,parameters=par,low=a,high=h,reference=ref)
  })
}
reference_paths <- file.path(out,mapply(function(k,b,s)paste0(reference_key(k,b,s),'.rds'),
  reference_points$Case,reference_points$Draw,reference_points$Start))

run_case <- function(k,b) {
  result_path <- file.path(out,paste0(key(k,b),'-result.rds'))
  if(file.exists(result_path)) {
    x<-readRDS(result_path); stopifnot(identical(x$binding,binding)); return(x)
  }
  stopifnot(eligible(k,b),all(file.exists(reference_paths)),
    all(vapply(lapply(reference_paths,readRDS),function(x)isTRUE(require_phase(x)$passed),TRUE)))
  e<-unit_context(k,b); z<-read_old(k,b,'zero')$value; f<-read_old(k,b,'free')$value
  lo<-natural_evaluator(e$low,e$ctx); hi<-natural_evaluator(e$high,e$ctx)
  dependency <- c(tools::md5sum(reference_paths),tools::md5sum(file.path(prior,
    paste0(key(k,b),c('-input.rds','-zero.rds','-free.rds')))))
  attempts <- lapply(names(f$attempts),function(start) phase(paste0(key(k,b),'-natural-',start),
    dependency,function() {
      p<-f$attempts[[start]]$parameters; p[length(p)]<-exp(tail(p,1))
      opt<-optim(p,lo$value,lo$gradient,method='L-BFGS-B',lower=c(rep(-Inf,e$ctx$p),0),
        control=list(maxit=settings$maxit,factr=settings$factr,pgtol=settings$pgtol))
      a<-lo$evaluate(opt$par); h<-hi$evaluate(opt$par)
      projected <- function(g) {
        if(tail(opt$par,1)==0) g[length(g)]<-min(tail(g,1),0)
        max(abs(g))
      }
      checks<-c(code=opt$convergence==0L,exact_zero=tail(opt$par,1)==0,
        nll_agreement=abs(a$value-h$value)<=controls$nll,
        gradient_agreement=max(abs(a$gradient-h$gradient))<=controls$gradient,
        projected_gradient=max(projected(a$gradient),projected(h$gradient))<=controls$gradient,
        zero_agreement=max(abs(c(a$value,h$value)-z$nll))<=controls$nll)
      list(passed=all(checks),checks=checks,opt=opt,low=a,high=h)
    }))
  names(attempts)<-names(f$attempts)
  result <- tryCatch({
    a<-lapply(attempts,require_phase)
    stopifnot(all(vapply(a,function(x)x$passed,TRUE)),
      diff(range(vapply(a,function(x)x$low$value,0.)))<=controls$nll,
      z$qualified,z$natural_variance_score<=-controls$boundary_margin)
    fd <- phase(paste0(key(k,b),'-zero-reference'),dependency,function() {
      points<-lapply(c(0,settings$forward_steps),function(v)rsm_lr_continuous_value(e$ctx,z$eta,v))
      values<-vapply(points,`[[`,0.,'value'); errors<-vapply(points,`[[`,0.,'summed_relative_error')
      h<-settings$forward_steps[2]
      coarse<-(-3*values[1]+4*values[3]-values[2])/(2*h)
      fine<-(-3*values[1]+4*values[4]-values[3])/h
      allowance<-(3*errors[1]+4*errors[4]+errors[3])/h
      exact<-rsm_lr_boundary_eval(e$ctx,z$eta)
      checks<-c(value=abs(values[1]-z$nll)+errors[1]<=controls$nll,
        information=min(eigen(exact$hessian,symmetric=TRUE,only.values=TRUE)$values)>0,
        one_sided_derivative=abs(fine+z$natural_variance_score)+abs(coarse-fine)+allowance<=controls$gradient)
      list(passed=all(checks),checks=checks,points=points,coarse=coarse,fine=fine,allowance=allowance,
        gradient=exact$gradient,hessian=exact$hessian,variance_score=z$natural_variance_score)
    })
    stopifnot(require_phase(fd)$passed)
    full<-list(passed=TRUE,kind='zero',parameters=c(z$eta,-Inf),nll=z$nll,
      continuous=list(value=z$nll,summed_relative_error=0))
    list(status='computed',reason='',review=review(require_phase(read_old(k,b,'null')),full,old$cases$NullVariance[k]),full=full)
  },error=function(err)list(status='unavailable',reason=conditionMessage(err)))
  result$binding<-binding; result$case<-k;result$draw<-b
  save_atomic(result,result_path)
  cat(sprintf('%s: %s %s\n',key(k,b),result$status,result$reason));flush.console();result
}
summarize <- function() {
  trials<-summary_old$trials; trials$Continuation<-units$Continue
  for(i in which(units$Continue)) {
    path<-file.path(out,paste0(key(units$Case[i],units$Draw[i]),'-result.rds'))
    if(!file.exists(path))next
    x<-readRDS(path);stopifnot(x$binding==binding)
    trials$Status[i]<-x$status; trials$Reason[i]<-x$reason
    if(x$status=='computed') {
      trials$LR[i]<-x$review$LR;trials$StructuralZero[i]<-x$review$StructuralZero
      obs<-read_old(x$case,0,'result')$review
      trials$NumericallyAmbiguous[i]<-abs(x$review$LR-obs$LR)<=
        x$review$NumericalAllowance+obs$NumericalAllowance && !(x$review$StructuralZero && obs$StructuralZero)
    }
  }
  summary<-do.call(rbind,lapply(old$cases$Case,function(k) {
    t<-subset(trials,Case==k);v<-t$LR
    v[t$Status!='computed' | t$NumericallyAmbiguous]<-NA_real_
    cbind(Case=k,mfrmr:::mfrm_gpcm_bootstrap_test(v,read_old(k,0,'result')$review$LR))
  }))
  files<-list.files(out,'-(reference-(warm|neutral|selected)|natural-(warm|neutral)|zero-reference)[.]rds$',full.names=TRUE)
  accounting<-do.call(rbind,lapply(files,function(f){x<-readRDS(f);data.frame(File=basename(f),Seconds=x$elapsed,Error=x$error)}))
  save_atomic(list(summary=summary,trials=trials,phases=accounting,manifest=tools::md5sum(manifest_path),
    phase_hashes=tools::md5sum(files)),file.path(out,'summary.rds'))
  write.csv(trials,file.path(out,'trials.csv'),row.names=FALSE)
  write.csv(summary,file.path(out,'summary.csv'),row.names=FALSE)
  print(summary);invisible(summary)
}
args<-commandArgs(TRUE);action<-if(length(args))args[1] else 'summarize'
stopifnot(action %in% c('check','run','summarize'))
if(action=='check')for(i in seq_len(nrow(reference_points)))check_reference(reference_points[i,])
if(action=='run') {
  chosen<-if(length(args)>1L)subset(targets,Draw==as.integer(args[2])) else targets
  stopifnot(nrow(chosen)>0)
  for(i in seq_len(nrow(chosen)))run_case(chosen$Case[i],chosen$Draw[i])
}
if(action %in% c('run','summarize'))summarize()
