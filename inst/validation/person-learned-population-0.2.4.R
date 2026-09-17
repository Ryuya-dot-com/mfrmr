# Public fit/scoring comparison; see the frozen sampling plan.
source('inst/validation/person-estimated-calibration-0.2.4.R')
source('inst/validation/person-prior-robustness-0.2.4.R')

plp_cells <- function() {
  x <- expand.grid(Model=c('RSM','PCM'),Persons=c(80L,320L),
    Distribution=c('normal','shifted','wide','skewed'),stringsAsFactors=FALSE)
  cbind(Cell=seq_len(nrow(x)),x)
}

plp_generate <- function(fixture,population,n,seed,prefix) {
  set.seed(seed)
  theta <- population$r(n); persons <- paste0(prefix,sprintf('%04d',seq_len(n)))
  d <- expand.grid(Person=persons,Rater=paste0('R',1:3),Criterion=c('C1','C2'),stringsAsFactors=FALSE)
  lp <- environment(fixture$objective)$log_probability
  d$Score <- 0L; d$Weight <- 1
  for (r in paste0('R',1:3)) for (c in c('C1','C2')) {
    i <- which(d$Rater==r & d$Criterion==c)
    old <- which(fixture$data$Rater==r & fixture$data$Criterion==c)[1L]
    probability <- vapply(lp(theta,old,fixture$truth),function(x) as.vector(exp(x)),numeric(n))
    stopifnot(identical(d$Person[i],persons),max(abs(rowSums(probability)-1))<1e-12)
    d$Score[i] <- as.integer(rowSums(runif(n)>cbind(probability[,1L],rowSums(probability[,1:2]))))
  }
  pi <- match(d$Person,persons)
  keep <- (pi+match(d$Rater,paste0('R',1:3)))%%2L==match(d$Criterion,c('C1','C2'))-1L
  list(data=d,three=d[keep,],truth=data.frame(Person=persons,Theta=theta),seed=seed)
}

plp_parts <- function(rows,fixture,par,model) {
  structural <- par[seq_along(fixture$truth)]
  facets <- as.vector(fixture$facet_map %*% structural)
  ri <- match(rows$Rater,paste0('R',1:3)); ci <- match(rows$Criterion,c('C1','C2'))
  steps <- matrix(fixture$step_map %*% structural,ncol=2L,byrow=TRUE)
  list(base=-facets[ri]-facets[3L+ci],steps=steps[if(model=='RSM') rep(1L,nrow(rows)) else ci,,drop=FALSE])
}

plp_probability <- function(prob0,theta) {
  logits <- sweep(outer(theta,seq_along(prob0)-1L),2L,log(prob0),'+')
  high <- logits[cbind(seq_along(theta),max.col(logits,ties.method='first'))]
  p <- exp(logits-high); p/rowSums(p)
}

plp_zero <- function(parts) {
  logits <- outer(parts$base,0:2)-cbind(0,t(apply(parts$steps,1L,cumsum)))
  p <- exp(logits-apply(logits,1L,max)); p <- p/rowSums(p)
  total <- 1
  for (i in seq_len(nrow(p))) {
    next_total <- numeric(length(total)+2L)
    for (k in 0:2) next_total[seq_along(total)+k] <- next_total[seq_along(total)+k]+total*p[i,k+1L]
    total <- next_total
  }
  list(probability=p,total=total)
}

plp_oracle <- function(model,fixture,population,profiles) {
  do.call(rbind,lapply(split(profiles,profiles$Person),function(rows) {
    parts <- plp_parts(rows,fixture,fixture$truth,model); prob0 <- plp_zero(parts)$total
    total <- sum(rows$Score)
    integral <- ppr_integrator(function(theta) population$d(theta)*plp_probability(prob0,theta)[,total+1L],
      population$lower,1e-11)
    moments <- vapply(0:2,function(k) integral(-Inf,Inf,k)[1L],0)
    mass <- moments[1L]; mean <- moments[2L]/mass
    lower <- uniroot(function(z) integral(-Inf,z)[1L]/mass-.025,c(-8,8),extendInt='upX',tol=1e-9)$root
    upper <- uniroot(function(z) integral(z,Inf)[1L]/mass-.025,c(-8,8),extendInt='downX',tol=1e-9)$root
    stopifnot(abs(integral(lower,upper)[1L]/mass-.95)<1e-7)
    data.frame(Person=rows$Person[1L],Estimate=mean,SD=sqrt(moments[3L]/mass-mean^2),
      Lower=lower,Upper=upper,Probability=mass,row.names=NULL)
  }))
}

# Independent Person log probabilities for a complete six-rating assignment.
plp_logp <- function(data,fixture,par,model,learned,profiles) {
  rows <- profiles[profiles$Person=='A3T00',]
  z <- plp_zero(plp_parts(rows,fixture,par,model))
  mu <- if(learned) par[length(par)-1L] else 0
  sigma <- if(learned) exp(tail(par,1L)/2) else 1
  masses <- vapply(seq_along(z$total),function(i) {
    integral <- ppr_integrator(function(theta) plp_probability(z$total,theta)[,i]*dnorm(theta,mu,sigma),-Inf,1e-11)
    integral(-Inf,Inf)[1L]
  },0)
  person <- match(data$Person,unique(data$Person))
  position <- match(paste(data$Rater,data$Criterion),paste(rows$Rater,rows$Criterion))
  log0 <- rowsum(log(z$probability[cbind(position,data$Score+1L)]),person,reorder=FALSE)[,1L]
  total <- rowsum(data$Score,person,reorder=FALSE)[,1L]
  log0-log(z$total[total+1L])+log(masses[total+1L])
}

plp_reference_check <- function(fit,fixture,profiles,scores) {
  errors <- c(Moment=0,Tail=0)
  learned <- isTRUE(fit$population$active)
  mu <- if(learned) unname(fit$population$coefficients[1L]) else 0
  sigma <- if(learned) sqrt(fit$population$sigma2) else 1
  for (rows in split(profiles,profiles$Person)) {
    parts <- plp_parts(rows,fixture,fit$opt$par,fit$config$model)
    ref <- aq_continuous_reference(rows$Score,parts$base,parts$steps,rep(1,nrow(rows)),rep(1,nrow(rows)),mu,sigma)
    actual <- scores[scores$Person==rows$Person[1L],]
    cumulative <- cbind(0,t(apply(parts$steps,1L,cumsum)))
    density <- function(z) vapply(z,function(value) {
      logits <- outer(mu+sigma*value+parts$base,0:2)-cumulative
      high <- apply(logits,1L,max)
      lp <- sum(logits[cbind(seq_len(nrow(rows)),rows$Score+1L)]-high-log(rowSums(exp(logits-high))))
      exp(lp+dnorm(value,log=TRUE)-ref['log_marginal'])
    },0)
    integral <- ppr_integrator(density,-Inf,1e-11)
    tails <- c(integral(-Inf,(actual$Lower-mu)/sigma)[1L],integral((actual$Upper-mu)/sigma,Inf)[1L])
    errors <- pmax(errors,c(Moment=max(abs(c(actual$Estimate-ref['eap'],actual$SD-ref['sd']))),
      Tail=max(abs(tails-.025))))
  }
  errors
}

plp_fit <- function(cell,data,cohort,fixture,profiles,oracle,preflight) {
  all <- list()
  for (method in c('fixed','learned')) {
    learned <- method=='learned'; fit <- scores <- NULL; warnings <- character(); metrics <- NULL
    status <- data.frame(Method=method,Returned=FALSE,NativePass=FALSE,FitReady=FALSE,ScoringReady=FALSE,
      Available=FALSE,NumericalOK=FALSE,CovarianceStatus='unavailable',Mean=NA_real_,SD=NA_real_,
      ObjectiveChange=NA_real_,Gradient241=NA_real_,Gradient321=NA_real_,
      IndependentObjective=NA_real_,IndependentGradient=NA_real_,GradientStep=NA_real_,
      ReferenceGradient=NA_real_,ScoringOrder=NA_real_,ReferenceMoment=NA_real_,ReferenceTail=NA_real_,
      DirectLookup=NA_real_,Error='',Warnings='',Seconds=NA_real_)
    started <- proc.time()[['elapsed']]
    error <- tryCatch(withCallingHandlers({
      extra <- if(learned) list(population_formula=~1,person_data=data.frame(Person=unique(data$Person))) else list()
      fit <- do.call(fit_mfrm,c(list(data=data,person='Person',facets=c('Rater','Criterion'),score='Score',
        model=cell$Model,method='MML',step_facet=if(cell$Model=='PCM') 'Criterion' else NULL,
        rating_min=0,rating_max=2,quad_points=241L,maxit=300L,reltol=1e-10,mml_engine='direct'),extra))
      status$Returned <- TRUE
      status$NativePass <- identical(fit$opt$optimizer_diagnostics$ConvergenceSeverity,'pass')
      status$FitReady <- mfrmr:::mfrm_inference_ready(fit)
      status$ScoringReady <- mfrmr:::prediction_source_scoring_readiness(fit)$ready
      status$Mean <- if(learned) unname(fit$population$coefficients[1L]) else 0
      status$SD <- if(learned) sqrt(fit$population$sigma2) else 1
      stopifnot(all(is.finite(fit$opt$par)),is.finite(status$SD),status$SD>0)
      sizes <- mfrmr:::build_param_sizes(fit$config)
      active <- unlist(sizes);active <- active[active>0L]
      expected <- c(fixture$sizes,if(learned) c(beta=1L,log_sigma2=1L))
      stopifnot(identical(names(active),names(expected)),all(active==expected))
      idx <- mfrmr:::build_indices(fit$prep,step_facet=fit$config$step_facet)
      q241 <- mfrmr:::gauss_hermite_normal(241L); q321 <- mfrmr:::gauss_hermite_normal(321L)
      gradient <- mfrmr:::mfrm_grad_mml(fit$opt$par,idx,fit$config,sizes,q241)
      status$Gradient241 <- max(abs(gradient))
      status$Gradient321 <- max(abs(mfrmr:::mfrm_grad_mml(fit$opt$par,idx,fit$config,sizes,q321)))
      status$ObjectiveChange <- abs(mfrmr:::mfrm_loglik_mml(fit$opt$par,idx,fit$config,sizes,q321)-fit$opt$value)
      status$NumericalOK <- status$ObjectiveChange<=1e-6 && max(status$Gradient241,status$Gradient321)<=1e-4
      covariance <- mfrmr:::compute_mml_parameter_covariance(fit)
      status$CovarianceStatus <- covariance$status
      scores <- predict_mfrm_units(fit,profiles,scoring_quad_points=241L,readiness_policy='review')
      finite <- all(is.finite(as.matrix(scores$estimates[c('Estimate','SD','Lower','Upper')])))
      status$Available <- status$NativePass && covariance$status=='ok' && finite
      if(status$Available) for(exposure in c(3L,6L)) {
        new <- if(exposure==3L) cohort$three else cohort$data
        metrics <- rbind(metrics,pec_measures(pec_lookup(scores$estimates,profiles,new),cohort$truth,method,exposure))
      }
      if(preflight) {
        high <- predict_mfrm_units(fit,profiles,scoring_quad_points=321L,readiness_policy='review')$estimates
        fields <- c('Estimate','SD','Lower','Upper')
        status$ScoringOrder <- max(abs(as.matrix(scores$estimates[fields])-as.matrix(high[fields])))
        reference <- plp_reference_check(fit,fixture,profiles,scores$estimates)
        status$ReferenceMoment <- reference['Moment']; status$ReferenceTail <- reference['Tail']
        fn <- function(par) plp_logp(data,fixture,par,cell$Model,learned,profiles)
        status$IndependentObjective <- abs(-sum(fn(fit$opt$par))-fit$opt$value)
        derivative <- function(step) vapply(seq_along(fit$opt$par),function(i) {
          h <- step*max(1,abs(fit$opt$par[i])); direction <- rep(0,length(fit$opt$par));direction[i] <- h
          -sum(fn(fit$opt$par+direction)-fn(fit$opt$par-direction))/(2*h)
        },0)
        g1 <- derivative(2.5e-5);g2 <- derivative(1.25e-5)
        status$GradientStep <- max(abs(g1-g2));status$IndependentGradient <- max(abs(g2-gradient))
        status$ReferenceGradient <- max(abs(g2))
        status$DirectLookup <- 0
        for(exposure in c(3L,6L)) {
          new <- if(exposure==3L) cohort$three else cohort$data
          new <- new[new$Person %in% cohort$truth$Person[1:48],]
          direct <- predict_mfrm_units(fit,new,scoring_quad_points=241L,readiness_policy='review')$estimates
          expected <- pec_lookup(scores$estimates,profiles,new)
          expected <- expected[match(direct$Person,expected$Person),]
          status$DirectLookup <- max(status$DirectLookup,abs(as.matrix(direct[fields])-as.matrix(expected[fields])))
        }
      }
      NULL
    },warning=function(w) {warnings <<- c(warnings,conditionMessage(w));invokeRestart('muffleWarning')}),error=identity)
    if(inherits(error,'error')) status$Error <- conditionMessage(error)
    status$Warnings <- paste(unique(warnings),collapse=' | ')
    status$Seconds <- proc.time()[['elapsed']]-started
    all[[method]] <- list(status=status,fit=fit,scores=scores,metrics=metrics,warnings=warnings)
  }
  all
}

plp_prepare <- function(stage,directory) {
  stopifnot(stage %in% c('preflight','main'))
  dir.create(directory,recursive=TRUE,showWarnings=FALSE)
  files <- c(list.files('R',pattern='[.]R$',full.names=TRUE),list.files('src',pattern='[.](cpp|h|hpp)$',full.names=TRUE),
    paste0('inst/validation/',c('person-learned-population-0.2.4.R','person-learned-population-0.2.4-plan.md',
      'person-estimated-calibration-0.2.4.R','person-prior-robustness-0.2.4.R','person-interval-calibration-0.2.4.R',
      'mml-structural-coverage-0.2.4.R','mml-independent-information-conditions-0.2.4.R',
      'mml-independent-rsm-information-0.2.4.R','adaptive-quadrature-review-0.2.4.R')))
  payload <- tools::md5sum(files)
  path <- file.path(directory,'metadata.rds')
  if(file.exists(path)) {
    meta <- readRDS(path);stopifnot(identical(meta$Payload,payload),identical(meta$Stage,stage));return(invisible(meta))
  }
  profiles <- pec_profiles();populations <- ppr_populations();populations <- populations[c('normal','shifted','wide','skewed')]
  fixtures <- lapply(setNames(c('RSM','PCM'),c('RSM','PCM')),function(model)
    mml_information_fixture(model,'baseline',3L,124000001L,2L,6L))
  oracle <- lapply(names(fixtures),function(model) lapply(populations,function(g) plp_oracle(model,fixtures[[model]],g,profiles)))
  names(oracle) <- names(fixtures)
  for (model in names(oracle)) for(g in names(populations)) {
    ref <- oracle[[model]][[g]]
    for (assignment in c('A1','A2','A3')) stopifnot(abs(sum(ref$Probability[startsWith(ref$Person,assignment)])-1)<1e-8)
  }
  seeds <- unlist(lapply(c(124000000L,134000000L),function(base) unlist(lapply(1:16,function(cell)
    c(base+10000L*cell+1:128,base+10000L*cell+2000L+1:128)))))
  stopifnot(!anyDuplicated(seeds))
  meta <- list(Stage=stage,Planned=if(stage=='preflight') 3L else 128L,Payload=payload,
    Profiles=profiles,Populations=populations,Fixtures=fixtures,Oracle=oracle,Cells=plp_cells(),Session=sessionInfo())
  saveRDS(meta,path);invisible(meta)
}

plp_run <- function(directory,cells=1:16) {
  meta <- readRDS(file.path(directory,'metadata.rds'))
  stopifnot(identical(meta$Payload,tools::md5sum(names(meta$Payload))),all(cells %in% 1:16),!anyDuplicated(cells))
  for(id in cells) for(rep in seq_len(meta$Planned)) {
    path <- file.path(directory,sprintf('cell-%02d-rep-%04d.rds',id,rep))
    if(file.exists(path)) {
      existing <- readRDS(path)
      stopifnot(identical(existing$Payload,meta$Payload),existing$Cell==id,existing$Replicate==rep)
      next
    }
    cell <- meta$Cells[id,];seed <- (if(meta$Stage=='preflight') 124000000L else 134000000L)+10000L*id+rep
    fixture <- meta$Fixtures[[cell$Model]];g <- meta$Populations[[cell$Distribution]]
    data <- plp_generate(fixture,g,cell$Persons,seed,'CAL')
    cohort <- plp_generate(fixture,g,512L,seed+2000L,'NEW')
    stopifnot(!any(data$truth$Person %in% cohort$truth$Person),all(table(data$data$Person)==6L),
      all(table(cohort$three$Person)==3L),all(data$data$Weight==1))
    oracle <- meta$Oracle[[cell$Model]][[cell$Distribution]]
    metrics <- do.call(rbind,lapply(c(3L,6L),function(exposure) {
      new <- if(exposure==3L) cohort$three else cohort$data
      pec_measures(pec_lookup(oracle,meta$Profiles,new),cohort$truth,'oracle',exposure)
    }))
    fits <- plp_fit(cell,data$data,cohort,fixture,meta$Profiles,oracle,meta$Stage=='preflight' && rep==1L)
    value <- list(Cell=id,Replicate=rep,Seed=seed,Stage=meta$Stage,Payload=meta$Payload,
      calibration=data,cohort=cohort,fits=fits,metrics=rbind(metrics,fits$fixed$metrics,fits$learned$metrics))
    saveRDS(value,paste0(path,'.tmp'));stopifnot(file.rename(paste0(path,'.tmp'),path))
    for(method in names(fits)) {
      s <- fits[[method]]$status
      cat(sprintf('%s cell %d rep %d/%d %s available=%s numerical=%s seconds=%.2f error=%s\n',
        meta$Stage,id,rep,meta$Planned,method,s$Available,s$NumericalOK,s$Seconds,s$Error))
    }
    flush.console()
  }
  invisible(TRUE)
}
