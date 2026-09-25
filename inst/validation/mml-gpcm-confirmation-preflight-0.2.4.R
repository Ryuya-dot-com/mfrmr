# Engineering preflight only: no confirmation seeds and no nested bootstrap.
# Run from the development root. Separate installed namespace per worker.
confirmation_root <- 'validation-results/mml-gpcm-confirmation-20260925'
confirmation_runner <- 'inst/validation/mml-gpcm-confirmation-preflight-0.2.4.R'

confirmation_decode <- function(v) {
  stopifnot(length(v) == 11L, all(is.finite(v)))
  list(rater = c(v[1:2], -sum(v[1:2])), criterion = c(v[3:4], -sum(v[3:4])),
    steps = cbind(v[5:7], -v[5:7]), slope = exp(c(v[8:9], -sum(v[8:9]))),
    mu = v[10], sigma = exp(v[11]/2))
}
confirmation_truth <- function(spec) {
  c(-.5, 0, -.4, 0, -.7, -1.1, -1.5,
    if (spec$Slopes == 'unit') c(0,0) else c(-.4,0), 0, 0)
}
confirmation_logprob <- function(theta, rater, criterion, p, owner) {
  owner_id <- if (owner == 'Rater') rater else criterion
  eta <- theta - p$rater[rater] - p$criterion[criterion]
  adjacent <- p$slope[owner_id] * (eta - p$steps[owner_id, , drop=FALSE])
  logits <- cbind(0, adjacent[,1], rowSums(adjacent))
  shift <- apply(logits, 1L, max)
  centered <- logits - shift
  centered - log(rowSums(exp(centered)))
}
confirmation_generate <- function(spec) {
  kind <- RNGkind(); had_seed <- exists('.Random.seed', .GlobalEnv, inherits=FALSE)
  if (had_seed) old_seed <- get('.Random.seed', .GlobalEnv)
  on.exit({do.call(RNGkind,as.list(kind)); if (had_seed) assign('.Random.seed',old_seed,.GlobalEnv)
    else if (exists('.Random.seed',.GlobalEnv,inherits=FALSE)) rm('.Random.seed',envir=.GlobalEnv)})
  RNGkind('Mersenne-Twister','Inversion','Rejection'); set.seed(spec$Seed)
  d <- expand.grid(Person=seq_len(spec$N),Rater=1:3,Criterion=1:3)
  if (spec$RatersPerPerson == 2L) d <- d[d$Rater == 1L+(d$Person-1L)%%3L |
    d$Rater == 1L+d$Person%%3L, , drop=FALSE]
  rownames(d) <- NULL
  theta <- rnorm(spec$N)
  p <- confirmation_decode(confirmation_truth(spec))
  prob <- exp(confirmation_logprob(theta[d$Person],d$Rater,d$Criterion,p,spec$Owner))
  u <- runif(nrow(d))
  d$Score <- 1L + as.integer(u > prob[,1]) + as.integer(u > prob[,1]+prob[,2])
  d$Person <- sprintf('P%03d',d$Person)
  d$Rater <- sprintf('R%02d',d$Rater); d$Criterion <- sprintf('C%02d',d$Criterion)
  list(data=d,theta=theta,truth=confirmation_truth(spec),spec=spec,
    rng=c('Mersenne-Twister','Inversion','Rejection'))
}
confirmation_reference <- function(v, d, owner, q=61L) {
  p <- confirmation_decode(v)
  quad <- statmod::gauss.quad.prob(q, dist='normal')
  r <- match(d$Rater,sprintf('R%02d',1:3)); c <- match(d$Criterion,sprintf('C%02d',1:3))
  lp <- vapply(quad$nodes,function(z) {
    x <- confirmation_logprob(p$mu+p$sigma*z,r,c,p,owner)
    x[cbind(seq_len(nrow(d)),d$Score)]
  },numeric(nrow(d)))
  person_lp <- rowsum(lp,d$Person,reorder=FALSE)
  marginal <- sweep(person_lp,2L,log(quad$weights),'+')
  mx <- apply(marginal,1L,max)
  -sum(mx+log(rowSums(exp(marginal-mx))))
}
confirmation_continuous <- function(v,d,owner) {
  p <- confirmation_decode(v)
  groups <- split(d,d$Person)
  values <- lapply(groups,function(rows) {
    r <- match(rows$Rater,sprintf('R%02d',1:3)); c <- match(rows$Criterion,sprintf('C%02d',1:3))
    log_density <- function(z) vapply(z,function(t) {
      lp <- confirmation_logprob(p$mu+p$sigma*t,r,c,p,owner)
      sum(lp[cbind(seq_len(nrow(rows)),rows$Score)])+dnorm(t,log=TRUE)
    },numeric(1))
    shift <- max(log_density(seq(-10,10,length.out=81)))
    cuts <- c(-Inf,-8,-4,0,4,8,Inf)
    pieces <- lapply(seq_len(length(cuts)-1L),function(j)
      integrate(function(z) exp(log_density(z)-shift),cuts[j],cuts[j+1L],
        rel.tol=1e-9,abs.tol=1e-11,subdivisions=500L,stop.on.error=TRUE))
    integral <- sum(vapply(pieces,`[[`,numeric(1),'value'))
    c(log_value=shift+log(integral),relative_error=sum(vapply(pieces,`[[`,numeric(1),'abs.error'))/integral)
  })
  list(nll=-sum(vapply(values,`[`,numeric(1),'log_value')),
       reported_relative_error=max(vapply(values,`[`,numeric(1),'relative_error')))
}
confirmation_difference <- function(fn,v,h=1e-5) {
  vapply(seq_along(v),function(j) {
    step <- h*max(1,abs(v[j])); plus <- minus <- v
    plus[j] <- plus[j]+step; minus[j] <- minus[j]-step
    (fn(plus)-fn(minus))/(2*step)
  },numeric(1))
}
confirmation_targets <- function(spec) {
  p <- confirmation_decode(confirmation_truth(spec))
  labels <- sprintf('%s%02d',substr(spec$Owner,1,1),1:3)
  grid <- expand.grid(Theta=c(-1,0,1),Rater=sprintf('R%02d',1:3),Criterion=sprintf('C%02d',1:3),
    stringsAsFactors=FALSE)
  ri <- match(grid$Rater,sprintf('R%02d',1:3)); ci <- match(grid$Criterion,sprintf('C%02d',1:3))
  prob <- exp(confirmation_logprob(grid$Theta,ri,ci,p,spec$Owner))
  mean <- drop(prob %*% (0:2)); variance <- drop(prob %*% (0:2)^2)-mean^2
  kinds <- list(relative=p$slope,standardized=p$slope,
    ratio=p$slope[1:2]/p$slope[2:3],difference=p$slope[1:2]-p$slope[2:3],
    probability=as.vector(t(prob)),information=variance*p$slope[if(spec$Owner=='Rater')ri else ci]^2)
  rows <- list()
  for (method in c('model','sandwich')) for (adjustment in c('none','bonferroni')) for (k in names(kinds)) {
    targets <- if (k %in% c('relative','standardized')) labels else
      if (k %in% c('ratio','difference')) c('first_vs_second','second_vs_third') else
        if(k=='probability') paste0('row',rep(1:27,each=3),'_category',rep(1:3,27)) else paste0('row',1:27)
    rows[[length(rows)+1L]] <- data.frame(Kind=k,Method=method,Adjustment=adjustment,
      Target=targets,Truth=as.numeric(kinds[[k]]),Attempted=FALSE,FitReturned=FALSE,
      SolutionEligible=FALSE,Returned=FALSE,Estimate=NA_real_,Lower=NA_real_,Upper=NA_real_,
      Reason='not attempted',stringsAsFactors=FALSE)
  }
  list(rows=do.call(rbind,rows),grid=grid,contrasts=matrix(c(1,-1,0,0,1,-1),2,byrow=TRUE,
    dimnames=list(c('first_vs_second','second_vs_third'),labels)))
}
confirmation_counts <- function(x) {
  stopifnot(!any(x$Returned & (!x$Attempted | !x$FitReturned | !x$SolutionEligible)),
    !any(x$Returned & (is.na(x$Lower) | is.na(x$Upper) | x$Lower>x$Upper)))
  available <- x$Returned; finite <- available & is.finite(x$Lower) & is.finite(x$Upper)
  covered <- available & !is.na(x$Lower) & !is.na(x$Upper) & x$Lower<=x$Truth & x$Upper>=x$Truth
  width <- x$Upper[available]-x$Lower[available]
  n <- sum(available); nf <- sum(finite); k <- sum(covered)
  bounds <- if(n) binom.test(k,n)$conf.int else c(NA_real_,NA_real_)
  data.frame(Assigned=nrow(x),Attempted=sum(x$Attempted),FitReturned=sum(x$FitReturned),
    SolutionEligible=sum(x$SolutionEligible),Intervals=n,FiniteIntervals=nf,Covered=k,
    ConditionalCoverage=if(n) k/n else NA_real_,CoveredPerAssigned=k/nrow(x),
    FiniteCoverage=if(nf)sum(covered & finite)/nf else NA_real_,
    MC_Lower=bounds[1],MC_Upper=bounds[2],
    MeanWidth=if(n)mean(width) else NA_real_,MedianWidth=if(n)median(width) else NA_real_)
}
confirmation_selfcheck <- function() {
  p <- confirmation_decode(rep(0,11)); prob <- exp(confirmation_logprob(0,1L,1L,p,'Rater'))
  stopifnot(max(abs(prob-1/3))<1e-15)
  spec <- read.csv(file.path(confirmation_root,'preflight-plan.csv'))[1,]
  set.seed(42); before <- .Random.seed
  a <- confirmation_generate(spec); b <- confirmation_generate(spec)
  stopifnot(identical(before,.Random.seed),identical(a,b),nrow(a$data)==40*2*3,
    all(a$data$Score %in% 1:3),all(table(a$data$Person)==6))
  t <- confirmation_targets(spec); stopifnot(nrow(t$rows)==472L,nrow(t$grid)==27L)
  x <- t$rows[rep(1,5),]; x$Attempted <- c(TRUE,TRUE,TRUE,TRUE,FALSE)
  x$FitReturned <- c(TRUE,TRUE,TRUE,FALSE,FALSE); x$SolutionEligible <- x$FitReturned
  x$Returned <- x$FitReturned; x$Lower <- c(.5,2,-Inf,NA,NA); x$Upper <- c(1.5,3,Inf,NA,NA)
  out <- confirmation_counts(x)
  stopifnot(out$Assigned==5,out$Attempted==4,out$FitReturned==3,out$FiniteIntervals==2,
    out$Covered==2,out$ConditionalCoverage==2/3,out$CoveredPerAssigned==.4,
    out$FiniteCoverage==.5,is.infinite(out$MeanWidth))
  x$Returned[] <- FALSE; x$Lower[] <- x$Upper[] <- NA_real_
  stopifnot(is.na(confirmation_counts(x)$ConditionalCoverage))
  message('Independent generator and injected-failure denominator checks pass.')
}
confirmation_run <- function(arm,cell) {
  lib <- normalizePath(file.path(confirmation_root,paste0('lib-',arm)))
  library('mfrmr',lib.loc=lib,character.only=TRUE)
  ns <- asNamespace('mfrmr')
  dll <- normalizePath(getLoadedDLLs()[['mfrmr']][['path']])
  stopifnot(startsWith(dll,paste0(lib,'/')),identical(normalizePath(find.package('mfrmr')),file.path(lib,'mfrmr')))
  input_path <- file.path(confirmation_root,'preflight-data',sprintf('cell-%02d.rds',cell))
  input <- readRDS(input_path); spec <- input$spec; d <- input$data
  identity <- c(Runner=unname(tools::md5sum(confirmation_runner)),Data=unname(tools::md5sum(input_path)),
    Manifest=unname(tools::md5sum(file.path(confirmation_root,'source-manifest.csv'))))
  dest <- file.path(confirmation_root,'preflight',sprintf('%s-%02d.rds',arm,cell))
  stopifnot(!file.exists(dest))
  target <- confirmation_targets(spec); rows <- target$rows; rows$Attempted <- TRUE
  warnings <- character(); failures <- character(); stages <- list(); objects <- list()
  capture <- function(label,expr) {
    started <- proc.time()[['elapsed']]
    val <- tryCatch(withCallingHandlers(expr,warning=function(w){
      warnings <<- c(warnings,paste(label,conditionMessage(w)));invokeRestart('muffleWarning')}),
      error=function(e) {failures <<- c(failures,paste(label,conditionMessage(e)));NULL})
    stages[[length(stages)+1L]] <<- data.frame(Stage=label,Elapsed=proc.time()[['elapsed']]-started,Returned=!is.null(val))
    val
  }
  args <- list(data=d,person='Person',facets=c('Rater','Criterion'),score='Score',model='GPCM',
    method='MML',step_facet=spec$Owner,slope_facet=spec$Owner,optimizer='BFGS',mml_engine='direct',
    population_formula=~1,person_data=data.frame(Person=unique(d$Person)),person_id='Person',
    rating_min=1,rating_max=3,category_policy='preserve',quad_points=61L,mml_integration='fixed',
    maxit=400L,reltol=1e-10)
  started <- proc.time()[['elapsed']]
  fit <- capture('fit_gpcm',do.call(mfrmr::fit_mfrm,args)); rows$FitReturned <- !is.null(fit)
  check <- reference <- qfit <- pcm <- comparison <- NULL
  if (!is.null(fit)) {
    info <- capture('solution_check',ns$mfrm_gpcm_inference(fit))
    if(!is.null(info)) {check <- info$check; rows$SolutionEligible <- isTRUE(check$eligible)}
    reference <- capture('reference',{
      sizes <- ns$build_param_sizes(fit$config)
      stopifnot(identical(as.integer(unlist(sizes)),c(0L,2L,2L,3L,2L,1L,1L)),
        identical(fit$config$facet_names,c('Rater','Criterion')),all(fit$config$facet_signs==-1))
      p <- confirmation_decode(fit$opt$par)
      native <- ns$expand_params(fit$opt$par,sizes,fit$config)
      stopifnot(max(abs(p$rater-native$facets$Rater))<1e-12,
        max(abs(p$criterion-native$facets$Criterion))<1e-12,max(abs(p$steps-native$steps_mat))<1e-12,
        max(abs(p$slope-native$slopes))<1e-12,abs(p$mu-native$population$coefficients)<1e-12,
        abs(p$sigma^2-native$population$sigma2)<1e-12)
      idx <- ns$build_indices(fit$prep,spec$Owner,spec$Owner,fit$config$interaction_specs)
      nq <- ns$gauss_hermite_normal(61)
      v <- fit$opt$par; ref <- function(v) confirmation_reference(v,d,spec$Owner)
      g <- ns$mfrm_grad_mml(v,idx,fit$config,sizes,nq); rg <- confirmation_difference(ref,v)
      grid <- target$grid; ri <- match(grid$Rater,sprintf('R%02d',1:3)); ci <- match(grid$Criterion,sprintf('C%02d',1:3))
      owner_id <- if(spec$Owner=='Rater')ri else ci
      probability <- exp(confirmation_logprob(grid$Theta,ri,ci,p,spec$Owner))
      native_probability <- ns$category_prob_gpcm(grid$Theta-p$rater[ri]-p$criterion[ci],
        cbind(0,p$steps[,1],rowSums(p$steps)),owner_id,p$slope,owner_id)
      continuous <- confirmation_continuous(v,d,spec$Owner)
      data.frame(ProbabilityError=max(abs(probability-native_probability)),
        ObjectiveError=abs(ref(v)-fit$opt$value),ObjectiveTolerance=1e-8*max(1,abs(fit$opt$value)),
        ScaledGradientError=max(abs(g-rg)/pmax(1,abs(g),abs(rg))),
        ContinuousNLL=continuous$nll,ContinuousDifference=continuous$nll-fit$opt$value,
        ContinuousReportedError=continuous$reported_relative_error)
    })
    for (method in c('model','sandwich')) for (adjustment in c('none','bonferroni')) {
      for (kind in c('relative','standardized','ratio','difference','probability','information')) {
        at <- which(rows$Kind==kind & rows$Method==method & rows$Adjustment==adjustment)
        label <- paste(kind,method,adjustment,sep='_')
        obj <- capture(label,{
          if(kind %in% c('probability','information')) mfrmr::mfrm_curve_intervals(fit,target$grid,
            type=kind,method=method,simultaneous=adjustment) else {
            opt <- list(object=fit,scale=if(kind %in% c('relative','ratio'))'relative' else 'standardized',
              method=method,simultaneous=adjustment)
            if(kind %in% c('ratio','difference')) {opt$contrasts <- target$contrasts; opt$contrast_scale <- kind}
            do.call(stats::confint,opt)
          }
        })
        objects[[label]] <- obj
        if(is.null(obj)) {rows$Reason[at] <- tail(failures,1);next}
        tab <- if(kind %in% c('probability','information')) obj$table else attr(obj,'diagnostics')
        stopifnot(nrow(tab)==length(at))
        rows$Estimate[at] <- tab$Estimate; rows$Returned[at] <- tab$CIEligible
        rows$Lower[at] <- if('Lower' %in% names(tab))tab$Lower else tab$CI_Lower
        rows$Upper[at] <- if('Upper' %in% names(tab))tab$Upper else tab$CI_Upper
        rows$Reason[at] <- tab$InferenceReview
      }
    }
    qargs <- args; qargs$quad_points <- 101L
    qfit <- capture('q101_refit',do.call(mfrmr::fit_mfrm,qargs))
    if(spec$Slopes=='unit') {
      args$model <- 'PCM'; args$slope_facet <- NULL
      pcm <- capture('fit_pcm',do.call(mfrmr::fit_mfrm,args))
      if(!is.null(pcm)) comparison <- capture('comparison',mfrmr::compare_mfrm(pcm,fit,
        labels=c('PCM','GPCM'),nested=TRUE))
    }
  } else rows$Reason <- paste(failures,collapse=' | ')
  result <- list(arm=arm,spec=spec,identity=identity,rows=rows,fit=fit,check=check,reference=reference,
    q101=qfit,pcm=pcm,comparison=comparison,outputs=objects,
    warnings=unique(warnings),errors=failures,stages=do.call(rbind,stages),elapsed=proc.time()[['elapsed']]-started,
    dll=dll,session=sessionInfo(),thread_env=Sys.getenv(c('OMP_NUM_THREADS','OPENBLAS_NUM_THREADS','VECLIB_MAXIMUM_THREADS')))
  saveRDS(result,dest)
  cat(arm,cell,'saved',result$elapsed,'seconds;',length(failures),'operation errors\n')
}

args <- commandArgs(trailingOnly=TRUE)
if(length(args)) {
  if(args[1]=='prepare') {
    confirmation_selfcheck()
    plan <- read.csv(file.path(confirmation_root,'preflight-plan.csv'))
    dir.create(file.path(confirmation_root,'preflight-data'),showWarnings=FALSE)
    dir.create(file.path(confirmation_root,'preflight'),showWarnings=FALSE)
    for(i in seq_len(nrow(plan))) {
      path <- file.path(confirmation_root,'preflight-data',sprintf('cell-%02d.rds',plan$Cell[i]))
      stopifnot(!file.exists(path)); saveRDS(confirmation_generate(plan[i,]),path)
    }
  } else if(args[1]=='worker') {
    stopifnot(length(args)==3L,args[2] %in% c('current','ablation'),as.integer(args[3]) %in% 1:16)
    confirmation_run(args[2],as.integer(args[3]))
  } else stop('Choose prepare or worker; this runner does not launch confirmation or bootstrap trials.')
}
