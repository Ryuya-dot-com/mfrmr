# Repository-only post-confirmation mechanism diagnostic; companion record owns scope.
source('inst/validation/mml-structural-coverage-0.2.4.R')

mml_bias_pattern_logp <- function(x, indices, patterns, par, quad) {
  lp <- environment(x$objective)$log_probability(quad$nodes,indices,par)
  indicators <- do.call(rbind,lapply(0:2,function(k) t(patterns==k)))
  log(as.vector(crossprod(quad$weights,exp(do.call(cbind,lp) %*% indicators))))
}

mml_bias_pattern_score <- function(fn,par,h=1e-4) {
  vapply(seq_along(par),function(j) {
    d <- rep(0,length(par)); d[j] <- h
    (fn(par+d)-fn(par-d))/(2*h)
  },numeric(length(fn(par))))
}

mml_bias_oracle <- function(model,exposure) {
  x <- mml_information_fixture(model,'baseline',3L,51000001L,2L,exposure)
  patterns <- as.matrix(expand.grid(rep(list(0:2),exposure)))
  groups <- split(seq_len(nrow(x$data)),x$data$Person)
  if(exposure==6L) groups <- groups[1]
  quad <- mfrmr:::gauss_hermite_normal(121L)
  by_assignment <- lapply(groups,function(ix) {
    fn <- function(par) mml_bias_pattern_logp(x,ix,patterns,par,quad)
    p <- exp(fn(x$truth))
    reference <- apply(patterns,1,function(y) {
      integrate(function(theta) {
        lp <- environment(x$objective)$log_probability(theta,ix,x$truth)
        observed <- vapply(seq_along(ix),function(j) lp[[y[j]+1L]][,j],numeric(length(theta)))
        exp(rowSums(observed))*dnorm(theta)
      },-Inf,Inf,rel.tol=1e-11,abs.tol=1e-13,subdivisions=200L)$value
    })
    score <- mml_bias_pattern_score(fn,x$truth)
    score2 <- mml_bias_pattern_score(fn,x$truth,5e-5)
    metrics <- c(ProbabilitySum=abs(sum(p)-1),
      IntegrationDifference=max(abs(p-reference)),
      IntegrationRelativeDifference=max(abs(p/reference-1)),
      ExpectedScore=max(abs(colSums(score*p))),ScoreStepDifference=max(abs(score-score2)))
    stopifnot(metrics[1]<1e-10,metrics[2]<1e-10,metrics[3]<1e-7,
      metrics[4]<1e-7,metrics[5]<1e-7)
    list(indices=ix,probability=p,score=score,metrics=metrics)
  })
  information <- Reduce('+',lapply(by_assignment,function(z) crossprod(z$score,z$score*z$probability)))/length(groups)
  chol(information)
  list(model=model,exposure=exposure,x=x,patterns=patterns,assignments=by_assignment,
    information=information,quad=quad)
}

mml_bias_replay_template <- function(cell,oracle) {
  x <- mml_information_fixture(cell$Model,'baseline',3L,51000001L,cell$Persons,cell$Exposure)
  env <- environment(x$objective)
  edge <- paste(x$data$Rater,x$data$Criterion)
  ix <- match(unique(edge),edge)
  group <- split(seq_len(nrow(x$data)),x$data$Person)
  list(data=x$data,truth=x$truth,lp=env$log_probability,ix=ix,
    person=match(x$data$Person,x$persons$Person),edge=match(edge,unique(edge)),
    groups=do.call(rbind,group),assignment=if(cell$Exposure==3L) rep(1:2,length.out=cell$Persons) else rep(1L,cell$Persons))
}

mml_bias_replay <- function(template,seed) {
  set.seed(seed)
  theta <- rnorm(nrow(template$groups))
  lp <- template$lp(theta,template$ix,template$truth)
  prob <- vapply(lp,function(a) exp(a[cbind(template$person,template$edge)]),numeric(nrow(template$data)))
  score <- vapply(seq_len(nrow(prob)),function(i) sample(0:2,1,prob=prob[i,]),integer(1))
  ratings <- matrix(score[template$groups],nrow=nrow(template$groups))
  pattern <- as.integer(1+ratings %*% 3^(0:(ncol(ratings)-1)))
  list(score=score,pattern=pattern)
}

mml_bias_expanded_map <- function(x) {
  pairs <- rbind(x$facet_map[1,]-x$facet_map[2,],x$facet_map[1,]-x$facet_map[3,],
    x$facet_map[2,]-x$facet_map[3,],x$facet_map[4,]-x$facet_map[5,])
  rownames(pairs) <- c('Rater:R1-R2','Rater:R1-R3','Rater:R2-R3','Criterion:C1-C2')
  rbind(x$facet_map,x$step_map,pairs)
}

mml_bias_diagnostic <- function(output) {
  pkgload::load_all('.',quiet=TRUE)
  original_path <- 'inst/validation/mml-structural-coverage-evidence-0.2.4.rds'
  original <- readRDS(original_path)
  payload <- original$confirmation[[1]]$Payload
  stopifnot(identical(tools::md5sum(names(payload)),payload))
  result <- list(original_md5=tools::md5sum(original_path),oracles=list(),cells=list(),
    source=readLines('inst/validation/mml-structural-bias-diagnostic-0.2.4.R'),
    plan=readLines('inst/validation/mml-structural-bias-diagnostic-record-0.2.4.md'),session=sessionInfo())
  for(model in c('RSM','PCM')) for(exposure in c(3L,6L)) {
    key <- paste(model,exposure)
    result$oracles[[key]] <- mml_bias_oracle(model,exposure)
    cat('Pattern oracle complete:',key,'\n');flush.console()
  }
  rows <- list()
  for(id in 1:8) {
    state <- original$confirmation[[id]]; cell <- state$Cell
    oracle <- result$oracles[[paste(cell$Model,cell$Exposure)]]
    template <- mml_bias_replay_template(cell,oracle)
    map <- mml_bias_expanded_map(oracle$x)
    stopifnot(identical(rownames(map),names(state$Results[[1]]$Truth)))
    for(rep in c(1L,1250L,2500L)) {
      saved <- state$Results[[rep]]
      direct <- mml_information_fixture(cell$Model,'baseline',3L,saved$Seed,cell$Persons,cell$Exposure)
      fast <- mml_bias_replay(template,saved$Seed)
      stopifnot(identical(fast$score,direct$data$Score))
    }
    first <- mml_information_fixture(cell$Model,'baseline',3L,state$Results[[1]]$Seed,cell$Persons,cell$Exposure)
    fit <- fit_mfrm(first$data,'Person',c('Rater','Criterion'),'Score',model=cell$Model,
      step_facet=if(cell$Model=='PCM') 'Criterion' else NULL,method='MML',rating_min=0,rating_max=2,
      quad_points=61L,maxit=200L,reltol=1e-10)
    idx <- mfrmr:::build_indices(fit$prep,step_facet=fit$config$step_facet)
    sizes <- mfrmr:::build_param_sizes(fit$config)
    linear <- matrix(NA_real_,2500L,nrow(map),dimnames=list(NULL,rownames(map)))
    counts <- vector('list',2500L)
    for(rep in 1:2500) {
      draw <- mml_bias_replay(template,state$Results[[rep]]$Seed)
      n <- lapply(seq_along(oracle$assignments),function(g)
        tabulate(draw$pattern[template$assignment==g],nrow(oracle$patterns)))
      counts[[rep]] <- n
      score <- Reduce('+',Map(function(n,z) as.vector(crossprod(n,z$score)),n,oracle$assignments))
      linear[rep,] <- as.vector(map %*% solve(cell$Persons*oracle$information,score))
      if(rep==1L) {
        objective <- -sum(unlist(Map(function(n,z) n*log(z$probability),n,oracle$assignments)))
        check <- c(Estimate=max(abs(as.vector(map %*% fit$opt$par)-state$Results[[1]]$Estimate)),
          Objective=abs(objective-mfrmr:::mfrm_loglik_mml(first$truth,idx,fit$config,sizes,oracle$quad)),
          Score=max(abs(score+mfrmr:::mfrm_grad_mml(first$truth,idx,fit$config,sizes,oracle$quad))))
        stopifnot(check[1]<1e-10,check[2]<1e-7,check[3]<1e-5)
      }
      if(rep %% 500L==0L) {cat('Score replay:',id,rep,'/2500\n');flush.console()}
    }
    errors <- t(vapply(state$Results,function(z) z$Estimate-z$Truth,numeric(nrow(map))))
    remainder <- errors-linear
    for(j in seq_len(nrow(map))) {
      e <- errors[,j]; l <- linear[,j]; r <- remainder[,j]; available <- vapply(state$Results,function(z)z$Available[j],logical(1))
      rows[[length(rows)+1L]] <- data.frame(cell,Coordinate=rownames(map)[j],
        Bias=mean(e),BiasMCSE=sd(e)/50,AvailableBias=mean(e[available]),
        FirstOrderMean=mean(l),FirstOrderMCSE=sd(l)/50,RemainderMean=mean(r),RemainderMCSE=sd(r)/50,
        RemainderLower=mean(r)-qnorm(.975)*sd(r)/50,RemainderUpper=mean(r)+qnorm(.975)*sd(r)/50,
        ErrorSD=sd(e),ErrorLinearCorrelation=cor(e,l),
        MaxLeaveOneOutMeanChange=max(abs((mean(e)-e)/2499)))
    }
    result$cells[[id]] <- list(cell=cell,counts=counts,linear=linear,remainder=remainder,checks=check)
    result$summary <- do.call(rbind,rows)
    saveRDS(result,output,compress='xz')
    cat('Cell complete:',id,'\n');flush.console()
  }
  print(result$summary[result$summary$Coordinate %in% c('shared:Step_2','C1:Step_2','Criterion:C1'),],row.names=FALSE)
  invisible(result)
}

mml_bias_vector_hessian <- function(fn,par,h) {
  value <- fn(par); d <- length(par)
  out <- array(0,c(length(value),d,d))
  for(j in seq_len(d)) {
    a <- rep(0,d);a[j] <- h
    out[,j,j] <- (fn(par+a)-2*value+fn(par-a))/h^2
    if(j<d) for(k in seq.int(j+1L,d)) {
      b <- rep(0,d);b[k] <- h
      out[,j,k] <- out[,k,j] <- (fn(par+a+b)-fn(par+a-b)-fn(par-a+b)+fn(par-a-b))/(4*h^2)
    }
  }
  out
}

mml_bias_curvature <- function(functions,par,h) {
  d <- length(par)
  prob <- lapply(functions,function(fn) exp(fn(par)))
  score <- lapply(functions,mml_bias_pattern_score,par=par)
  information <- Reduce('+',Map(function(p,u) crossprod(u,u*p),prob,score))/length(functions)
  inverse <- solve(information)
  score_hessian <- numeric(d);third <- array(0,c(d,d,d));expected_hessian <- matrix(0,d,d)
  for(g in seq_along(functions)) {
    fn <- functions[[g]];p <- prob[[g]];u <- score[[g]]
    hh <- mml_bias_vector_hessian(fn,par,h)
    expected_hessian <- expected_hessian+matrix(colSums(matrix(hh,length(p))*p),d,d)
    for(k in seq_along(p)) score_hessian <- score_hessian+p[k]*as.vector(hh[k,,] %*% inverse %*% u[k,])
    for(j in seq_len(d)) {
      a <- rep(0,d);a[j] <- h
      change <- (mml_bias_vector_hessian(fn,par+a,h)-mml_bias_vector_hessian(fn,par-a,h))/(2*h)
      third[,,j] <- third[,,j]+matrix(colSums(matrix(change,length(p))*p),d,d)
    }
  }
  score_hessian <- score_hessian/length(functions)
  third_term <- vapply(seq_len(d),function(j) sum(third[j,,]*inverse),numeric(1))/(2*length(functions))
  list(coefficient=as.vector(inverse %*% (score_hessian+third_term)),
    score_hessian=score_hessian,third_term=third_term,information=information,
    information_identity=max(abs(expected_hessian/length(functions)+information)))
}

mml_bias_curvature_check <- function() {
  pattern <- as.matrix(expand.grid(0:1,0:1));a <- matrix(c(1,-.2,.3,.7),2,2)
  par <- c(.6,-.4);p <- as.vector(plogis(a %*% par))
  fn <- function(b) {
    eta <- as.vector(a %*% b)
    as.vector(pattern %*% log(plogis(eta))+(1-pattern) %*% log(plogis(-eta)))
  }
  expected <- as.vector(solve(a,(2*p-1)/(2*p*(1-p))))
  checks <- lapply(c(.002,.001),function(h) mml_bias_curvature(list(fn),par,h))
  stopifnot(all(vapply(checks,function(x) max(abs(x$coefficient-expected))<1e-4 &&
    x$information_identity<1e-5,logical(1))))
  # Direct Bernoulli probability has an unbiased sample-mean MLE. Its two
  # nonzero curvature contributions must cancel, unlike canonical logits.
  direct <- lapply(c(.002,.001),function(h)
    mml_bias_curvature(list(function(p)c(log1p(-p),log(p))),.4,h))
  stopifnot(all(vapply(direct,function(x) abs(x$coefficient)<1e-4 &&
    abs(x$score_hessian)>.1 && abs(x$third_term)>.1,logical(1))))
  list(expected=expected,calculated=checks,direct_probability=direct)
}

mml_bias_oracle_functions <- function(oracle) {
  lapply(oracle$assignments,function(z) function(par)
    mml_bias_pattern_logp(oracle$x,z$indices,oracle$patterns,par,oracle$quad))
}

mml_bias_finish <- function(input,output) {
  result <- readRDS(input)
  result$curvature_check <- mml_bias_curvature_check()
  result$curvature <- list()
  for(key in names(result$oracles)) {
    oracle <- result$oracles[[key]];fns <- mml_bias_oracle_functions(oracle)
    a <- mml_bias_curvature(fns,oracle$x$truth,.002)
    b <- mml_bias_curvature(fns,oracle$x$truth,.001)
    difference <- max(abs(a$coefficient-b$coefficient))
    stopifnot(difference<1e-4,a$information_identity<1e-5,b$information_identity<1e-5)
    result$curvature[[key]] <- list(coarse=a,fine=b,step_difference=difference)
    cat('Curvature:',key,'step difference',difference,'\n');flush.console()
  }
  for(id in 1:8) {
    cell <- result$cells[[id]]$cell;key <- paste(cell$Model,cell$Exposure)
    map <- mml_bias_expanded_map(result$oracles[[key]]$x)
    take <- result$summary$Cell==id
    result$summary$CurvatureBias[take] <- as.vector(map %*% result$curvature[[key]]$fine$coefficient)/cell$Persons
  }
  original <- readRDS('inst/validation/mml-structural-coverage-evidence-0.2.4.rds')
  refits <- list();refit_parameters <- list()
  targets <- c('1'='shared:Step_2','5'='C1:Step_2','7'='Criterion:C1')
  for(id in c(1L,3L,5L,7L)) {
    state <- original$confirmation[[id]];cell <- state$Cell
    oracle <- result$oracles[[paste(cell$Model,cell$Exposure)]]
    fns <- mml_bias_oracle_functions(oracle);map <- mml_bias_expanded_map(oracle$x)
    selected <- which(!vapply(state$Results,`[[`,logical(1),'FitReady'))
    if(as.character(id) %in% names(targets)) {
      error <- vapply(state$Results,function(z) z$Estimate[targets[as.character(id)]]-z$Truth[targets[as.character(id)]],numeric(1))
      selected <- sort(unique(c(selected,order(error)[c(1L,1250L,2500L)])))
    }
    free_names <- c('Rater:R1','Rater:R2','Criterion:C1',if(cell$Model=='RSM') 'shared:Step_1' else c('C1:Step_1','C2:Step_1'))
    for(rep in selected) {
      saved <- state$Results[[rep]];counts <- result$cells[[id]]$counts[[rep]]
      par <- unname(saved$Estimate[free_names])
      stopifnot(max(abs(as.vector(map %*% par)-saved$Estimate))<1e-10)
      fn <- function(p) -sum(vapply(seq_along(counts),function(g) sum(counts[[g]]*fns[[g]](p)),numeric(1)))
      old_value <- fn(par)
      for(start in c('saved','truth')) {
        refit <- nlminb(if(start=='saved') par else oracle$x$truth,fn,
          control=list(eval.max=2000L,iter.max=1000L,rel.tol=1e-13,x.tol=1e-12))
        movement <- max(abs(as.vector(map %*% (refit$par-par)))/saved$SE)
        delta <- abs(refit$objective-old_value)
        hessian <- mml_independent_central_hessian(fn,refit$par,.0005)
        chol(hessian)
        gradient <- as.vector(mml_bias_pattern_score(fn,refit$par))
        newton <- max(abs(as.vector(map %*% solve(hessian,gradient)))/saved$SE)
        refits[[length(refits)+1L]] <- data.frame(Cell=id,Replicate=rep,Seed=saved$Seed,
          OriginallyReady=saved$FitReady,Start=start,Convergence=refit$convergence,
          Message=refit$message,ObjectiveDifference=delta,MaxMovementSE=movement,
          MaxNewtonSE=newton,MinInformationEigenvalue=min(eigen(hessian,symmetric=TRUE,only.values=TRUE)$values))
        refit_parameters[[length(refits)]] <- refit$par
      }
    }
  }
  result$refits <- do.call(rbind,refits)
  result$refit_parameters <- refit_parameters
  result$completed_source <- readLines('inst/validation/mml-structural-bias-diagnostic-0.2.4.R')
  result$completed_session <- sessionInfo()
  saveRDS(result,output,compress='xz')
  stopifnot(all(result$refits$ObjectiveDifference<=1e-6),all(result$refits$MaxMovementSE<=.001),
    all(result$refits$MaxNewtonSE<=.001))
  write.csv(result$summary,sub('[.]rds$','-summary.csv',output),row.names=FALSE)
  print(result$summary[result$summary$Coordinate %in% c('shared:Step_2','C1:Step_2','Criterion:C1'),
    c('Cell','Coordinate','Bias','FirstOrderMean','RemainderMean','RemainderMCSE','CurvatureBias')],row.names=FALSE)
  print(result$refits,row.names=FALSE)
  invisible(result)
}

if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args)==1L)
  mml_bias_diagnostic(args[1])
  mml_bias_finish(args[1],args[1])
}
