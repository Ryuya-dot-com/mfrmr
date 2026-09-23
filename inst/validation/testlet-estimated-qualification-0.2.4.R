# Source definitions for the bounded estimated-population testlet comparison.
testlet_qualification_conditions <- data.frame(
  Condition=1:4, Name=c('null_balanced','local_balanced','small_calibration','sparse_unequal'),
  N=c(120L,120L,24L,120L), Variance=c(0,.8,.8,.8), Sparse=c(FALSE,FALSE,FALSE,TRUE))

testlet_qualification_data <- function(condition, seed) {
  set.seed(seed)
  n <- condition$N; nt <- if (condition$Sparse) 3L else 2L
  d <- expand.grid(Criterion=paste0('C',1:3),Task=paste0('T',seq_len(nt)),
    Person=sprintf('P%03d',seq_len(n)),stringsAsFactors=FALSE)
  p <- match(d$Person,sprintf('P%03d',seq_len(n))); t <- match(d$Task,paste0('T',seq_len(nt)))
  j <- match(d$Criterion,paste0('C',1:3))
  theta <- rnorm(n,sd=1.3); gamma <- matrix(rnorm(n*nt,sd=sqrt(condition$Variance)),n,nt)
  eta <- theta[p]+gamma[cbind(p,t)]-c(-.3,0,.3)[j]
  lw <- cbind(0,eta+.6,2*eta); weights <- exp(lw-apply(lw,1,max)); prob <- weights/rowSums(weights)
  u <- runif(nrow(d)); d$Score <- as.integer(u>prob[,1])+as.integer(u>rowSums(prob[,1:2]))
  # Absent assignments, not imputed or missing scores. All Persons keep T1;
  # odd/even IDs receive T2/T3 respectively, independently of latent draws.
  keep <- if (!condition$Sparse) rep(TRUE,nrow(d)) else
    t==1L | (t==2L & p%%2L==1L & j<=2L) | (t==3L & p%%2L==0L & j==1L)
  stopifnot(max(abs(rowSums(prob)-1))<1e-14,all(d$Score %in% 0:2),
    max(abs(log(prob[,2]/prob[,1])-(eta+.6)))<1e-12,
    max(abs(log(prob[,3]/prob[,2])-(eta-.6)))<1e-12)
  list(data=d[keep,],theta=setNames(theta,sprintf('P%03d',seq_len(n))),gamma=gamma,
    assigned=keep,full_data=d,probabilities=prob,uniforms=u,seed=seed,condition=condition)
}

testlet_qualification_trial <- function(condition, seed, refine = FALSE) {
  x <- testlet_qualification_data(condition,seed)
  ids <- sprintf('P%03d',1:12)
  fits <- scores <- warnings <- errors <- list(); elapsed <- numeric()
  capture <- function(label,fun) {
    messages <- character(); error <- ''
    timing <- system.time(value <- tryCatch(withCallingHandlers(fun(),warning=function(w) {
      messages <<- c(messages,conditionMessage(w));invokeRestart('muffleWarning')
    }),error=function(e) {error <<- conditionMessage(e);NULL}))['elapsed']
    warnings[[label]] <<- messages;errors[[label]] <<- error;elapsed[label] <<- unname(timing)
    value
  }
  fits$testlet <- capture('testlet_fit',function() fit_mfrm_testlet(x$data,'Person','Score','Task',
    c('Task','Criterion'),0:2,quad_points=61,maxit=400))
  attempts <- list(testlet_61=fits$testlet)
  if (refine && !is.null(fits$testlet)) {
    ch <- fits$testlet$checks
    delta <- unlist(ch[c('LogLikDifference','GradientDifference','MomentDifference')])
    if (isTRUE(ch$Convergence==0L) && !isTRUE(ch$SearchBoundary) &&
        (any(!is.finite(delta)) || any(delta >= c(1e-6,1e-5,1e-6)))) {
      fits$testlet <- capture('testlet_refit',function() fit_mfrm_testlet(x$data,'Person','Score','Task',
        c('Task','Criterion'),0:2,quad_points=121,maxit=400))
      attempts$testlet_121 <- fits$testlet
    }
  }
  fits$ordinary <- capture('ordinary_fit',function() fit_mfrm(x$data,'Person',c('Task','Criterion'),'Score',
    population_formula=~1,person_data=unique(x$data['Person']),quad_points=121,maxit=400,
    rating_min=0,rating_max=2,keep_original=TRUE))
  for (method in names(fits)) if (!is.null(fits[[method]])) scores[[method]] <-
    capture(paste0(method,'_score'),function() score_mfrm_persons(fits[[method]],persons=ids))
  # Oracle calibration is not mislabeled as an estimated fit. Evaluate known
  # generating coordinates through the already numerically checked scorer.
  input <- mfrm_testlet_data(x$data,'Person','Score','Task',c('Task','Criterion'),0:2,'fail')
  beta <- c(rep(0,ncol(input$basis$Task)),drop(crossprod(input$basis$Criterion,c(-.3,0,.3))))
  truth_par <- c(beta,-.6,.6,condition$Variance,1.3^2)
  scores$oracle <- capture('oracle_score',function() {
    rows <- lapply(match(ids,input$persons),function(p) {
      low <- mfrm_testlet_person_interval(input,truth_par,p,gauss_hermite_normal(61),.95)
      high <- mfrm_testlet_person_interval(input,truth_par,p,gauss_hermite_normal(123),.95)
      stopifnot(all(abs(high-low)<c(1e-7,1e-7,1e-5,1e-5,1e-6)))
      data.frame(Person=input$persons[p],as.list(high[1:4]),Status='available_conditional',Reason='')
    })
    list(table=do.call(rbind,rows))
  })
  list(generated=x,fits=fits,attempts=attempts,scores=scores,warnings=warnings,errors=errors,elapsed=elapsed)
}
