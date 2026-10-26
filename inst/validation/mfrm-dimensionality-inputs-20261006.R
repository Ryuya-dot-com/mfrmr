# Research inputs for the declared dimensionality allocation; no estimators.
dim_profiles <- function() data.frame(
  Profile=c('DIM1','DIM2-45','DIM2-90','DIM1-I','DIM2-45-I','DIM1-LD'),
  Rho=c(1,.45,.90,1,.45,1),Interaction=c(FALSE,FALSE,FALSE,TRUE,TRUE,FALSE),
  Eta=c(0,0,0,0,0,.30))

dim_truth <- function(family,profile) {
  stopifnot(family %in% c('RSM','PCM'),nrow(profile)==1L)
  steps <- if(family=='RSM')matrix(c(-.8,0,.8),6,3,byrow=TRUE) else
    rbind(c(-1,0,1),c(-.8,.2,.6),c(-.6,-.2,.8),
          c(-1,0,1),c(-.8,.2,.6),c(-.6,-.2,.8))
  list(family=family,profile=profile$Profile,rho=profile$Rho,eta=profile$Eta,
    rater=c(-.4,0,.4),criterion=rep(c(-.6,0,.6),2),steps=steps,
    H=if(profile$Interaction).4*outer(c(-1,0,1),c(1,1,1,-1,-1,-1)) else matrix(0,3,6),
    dimension=c(1L,1L,1L,2L,2L,2L),category=0:3)
}

# Called only within dim_generate(), which restores the caller's RNG state.
dim_primitives <- function(N,seeds,prefix) {
  draw <- function(seed,expression){assign('.Random.seed',seed,.GlobalEnv);force(expression)}
  list(N=N,persons=sprintf(paste0(prefix,'%04d'),seq_len(N)),
    ability=draw(seeds$ability,matrix(rnorm(2L*N),N,2L)),
    dependence=draw(seeds$dependence,matrix(rnorm(2L*N),N,2L)),
    response=draw(seeds$response,matrix(rnorm(18L*N),N,18L)),
    assignment=draw(seeds$assignment,sample.int(N)),
    deletion=draw(seeds$deletion,matrix(runif(18L*N),N,18L)))
}

dim_cohort <- function(primitive,family) {
  N <- primitive$N;profiles <- dim_profiles()
  counts <- rep(N%/%3L,3)+as.integer(1:3<=N%%3L)
  pair <- integer(N);pair[primitive$assignment] <- rep(1:3,counts)
  pair_map <- rbind(c(1L,2L),c(2L,3L),c(3L,1L))
  grid <- expand.grid(PersonIndex=seq_len(N),RaterIndex=1:3,CriterionIndex=1:6)
  assigned <- grid$RaterIndex==pair_map[pair[grid$PersonIndex],1L] |
    grid$RaterIndex==pair_map[pair[grid$PersonIndex],2L]
  missing <- as.vector(primitive$deletion)<.30
  roster <- data.frame(Person=primitive$persons,PairId=pair)
  results <- setNames(vector('list',nrow(profiles)),profiles$Profile)
  for(j in seq_len(nrow(profiles))){
    truth <- dim_truth(family,profiles[j,,drop=FALSE])
    theta <- cbind(primitive$ability[,1],truth$rho*primitive$ability[,1]+
      sqrt(1-truth$rho^2)*primitive$ability[,2])
    block <- truth$dimension[grid$CriterionIndex]
    eta <- theta[cbind(grid$PersonIndex,block)]-truth$rater[grid$RaterIndex]-
      truth$criterion[grid$CriterionIndex]-truth$H[cbind(grid$RaterIndex,grid$CriterionIndex)]
    step_cum <- t(apply(truth$steps,1,function(z)c(0,cumsum(z))))
    logits <- outer(eta,0:3)-step_cum[grid$CriterionIndex,]
    mass <- exp(logits-pmax(logits[,1],logits[,2],logits[,3],logits[,4]))
    mass <- mass/rowSums(mass)
    normal <- if(truth$eta==0)as.vector(primitive$response) else
      sqrt(truth$eta)*primitive$dependence[cbind(grid$PersonIndex,block)]+
      sqrt(1-truth$eta)*as.vector(primitive$response)
    cdf <- cbind(mass[,1],mass[,1]+mass[,2],mass[,1]+mass[,2]+mass[,3])
    full <- data.frame(RowId=seq_len(nrow(grid)),Person=primitive$persons[grid$PersonIndex],
      Rater=as.character(grid$RaterIndex),Criterion=as.character(grid$CriterionIndex),
      Score=as.integer(rowSums(pnorm(normal)>cdf)))
    paired <- full[assigned,];rownames(paired) <- NULL
    mcar <- paired;mcar$Score[missing[assigned]] <- NA_integer_
    results[[j]] <- list(truth=truth,theta=theta,
      views=list(full=full,paired=paired,'paired-MCAR30'=mcar))
  }
  list(primitive=primitive,roster=roster,profiles=results)
}

dim_generate <- function(unit,seeds) {
  stopifnot(nrow(unit)==1L,unit$N %in% c(20L,60L,240L,480L),
    unit$Family %in% c('RSM','PCM'),unit$Replicate %in% 1:50,
    identical(names(seeds),c('training','future','reference_first_unused')))
  for(cohort in c('training','future')){
    stopifnot(identical(names(seeds[[cohort]]),c('ability','dependence','response','assignment','deletion')))
    for(seed in seeds[[cohort]])stopifnot(is.integer(seed),length(seed)==7L,seed[1]==10407L)
  }
  kind <- RNGkind();had <- exists('.Random.seed',.GlobalEnv,inherits=FALSE)
  if(had)old <- get('.Random.seed',.GlobalEnv)
  on.exit({do.call(RNGkind,as.list(kind));if(had)assign('.Random.seed',old,.GlobalEnv)
    else if(exists('.Random.seed',.GlobalEnv,inherits=FALSE))rm('.Random.seed',envir=.GlobalEnv)},add=TRUE)
  RNGkind("L'Ecuyer-CMRG",normal.kind='Inversion',sample.kind='Rejection')
  list(unit=unit,rng=seeds,
    training=dim_cohort(dim_primitives(unit$N,seeds$training,'P'),unit$Family),
    future=dim_cohort(dim_primitives(60L,seeds$future,'F'),unit$Family))
}
