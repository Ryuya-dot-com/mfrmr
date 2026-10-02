# E mechanism/input freeze only; no fitting, scoring or outcome-based redraw.
# From package root: Rscript THIS_FILE OUTPUT_DIRECTORY (resumes saved bundles).
e_script <- 'inst/validation/mfrm-wide-map-e-inputs-20261001.R'
e_root <- 'validation-results/mfrm-wide-map-r50-20261001'
e_c_source <- file.path(e_root,'c-inputs/source/inst/validation/mfrm-wide-map-c-inputs-20261001.R')
e_rates_path <- 'validation-results/mfrm-missingness-control-rates-20261001/verified-rates.rds'
source(e_c_source)
e_designs <- c('E0','E1-right-skew','E1-left-skew','E1-mixture',
  'E2-minus2.5','E2-plus2.5','E3-rare-category','E4-unequal','E5-ability-allocation',
  'E6-missing0.15','E6-missing0.30','E7-rater-missing','E8-score-missing',
  'E8-matched-independent','E9-rho0','E9-rho0.25','E9-rho0.5',
  'E10-link0.6','E10-link0.2','E10-link0.05')
e_joint <- c('shape-missing-right-skew-score-missing',
  'shape-missing-right-skew-matched-independent',
  'links-dependence-b0.6-rho0','links-dependence-b0.6-rho0.5',
  'links-dependence-b0.05-rho0','links-dependence-b0.05-rho0.5')
e_pairs3 <- rbind(c(1L,2L),c(2L,3L),c(3L,1L))
e_within <- rbind(c(1L,2L),c(1L,3L),c(2L,3L),c(4L,5L),c(4L,6L),c(5L,6L))
e_between <- as.matrix(expand.grid(1:3,4:6))

e_spec <- function(design,family,rates) {
  tasks <- grepl('^E9|^links-dependence',design)
  six <- grepl('^E10|^links-dependence',design)
  s <- c_spec(if(tasks)'two-tasks-same-pair' else 'six-raters-paired',family)
  s$design <- design; s$nr <- if(six)6L else 3L
  s$truth$Rater <- rep(ab_truth(family)$Rater,s$nr/3L)
  s$shape <- if(grepl('right-skew',design))'right_skew' else
    if(design=='E1-left-skew')'left_skew' else if(design=='E1-mixture')'mixture' else 'normal'
  s$theta_key <- if(design=='E2-minus2.5')'minus2.5' else
    if(design=='E2-plus2.5')'plus2.5' else s$shape
  if(design=='E3-rare-category') {
    if(family=='S-RSM') s$truth$steps[,] <- rep(c(1.5,-1.5,0),each=3L)
    else s$truth$steps[2L,] <- c(1.5,-1.5,0)
  }
  s$rho <- if(tasks)as.numeric(sub('.*rho','',design)) else 0
  s$link <- if(grepl('^E10',design))as.numeric(sub('E10-link','',design)) else
    if(six)as.numeric(sub('-rho.*','',sub('links-dependence-b','',design))) else NA_real_
  s$deletion <- if(design=='E6-missing0.15')'independent15' else
    if(design=='E6-missing0.30')'independent30' else
    if(design=='E7-rater-missing')'rater' else
    if(grepl('score-missing$',design))'score' else
    if(grepl('matched-independent$',design))'matched' else 'none'
  ix <- rates$Truth==family & rates$Shape==s$shape
  s$matched_rate <- if(s$deletion=='matched')rates$IndependentDeletionRate[ix] else NA_real_
  stopifnot(length(s$matched_rate)==1L)
  s$assignment <- if(six)'links' else if(design=='E4-unequal')'unequal' else
    if(design=='E5-ability-allocation')'ability' else 'uniform'
  s$control <- if(grepl('^shape-missing',design))c('E8-score-missing','E8-matched-independent','E1-right-skew') else
    if(grepl('^links-dependence',design))'links-dependence-b0.6-rho0' else
    if(grepl('^E9',design))'E9-rho0' else if(six)'E10-link0.6' else
    if(design=='E7-rater-missing')'E6-missing0.15' else
    if(grepl('^E8',design))c('E0','E8-matched-independent') else 'E0'
  s$covariance_sampling <- 'random_rosters'
  s$interpretation <- paste('Generating parameters and fitted working-model targets remain distinct;',
    'random_rosters does not remove dependence, informative-assignment or missingness bias.')
  s
}

e_registry <- function() {
  head <- readRDS(file.path(e_root,'rng-head.rds'))
  stopifnot(head$epoch=='development-D-20261001-v1',head$next_unit_ordinal==4151L,
    identical(tools::md5sum(head$registry),head$registry_md5))
  preceding <- readRDS(head$registry)
  units <- expand.grid(Replicate=1:50,Truth=c('S-RSM','S-PCM','S-GPCM'),
    N=c(20L,60L,240L,480L),stringsAsFactors=FALSE)
  units$CohortId <- paste('E',paste0('N',units$N),units$Truth,
    sprintf('rep%03d',units$Replicate),sep=':')
  units$Bundle <- sprintf('bundles/parent-%04d.rds',seq_len(nrow(units)))
  next_stream <- preceding$next_unused_unit_stream
  streams <- vector('list',nrow(units))
  for(i in seq_len(nrow(units))) {
    component <- next_stream; seeds <- list()
    for(name in c('ability','assignment','response','missingness','F_first_unused')) {
      seeds[[name]] <- component; component <- parallel::nextRNGSubStream(component)
    }
    streams[[i]] <- seeds; next_stream <- parallel::nextRNGStream(next_stream)
  }
  names(streams) <- units$CohortId
  list(epoch='development-E-20261001-v1',phase='development',units=units,streams=streams,
    predecessor_md5=head$registry_md5,first_unit_ordinal=head$next_unit_ordinal,
    next_unit_ordinal=head$next_unit_ordinal+nrow(units),
    first_unit_stream=preceding$next_unused_unit_stream,next_unused_unit_stream=next_stream,
    RNG=c("L'Ecuyer-CMRG",'Inversion','Rejection'),
    pairing='All E views within N/truth/replicate share primitives; distinct from A/B.',
    fit_input='views[[Design]]$data only; planned$GeneratedScore includes latent deleted responses.',
    scope='Input and mechanism freeze only; no fitted-method qualification or F panels.')
}

e_generate <- function(unit,seeds,rates) {
  N <- unit$N; persons <- sprintf('P%04d',seq_len(N))
  assign('.Random.seed',seeds$ability,envir=.GlobalEnv)
  ability_u <- runif(N); sign_u <- runif(N)
  normal <- qnorm(ability_u)
  abilities <- list(normal=normal,right_skew=-log1p(-ability_u)-1,
    left_skew=1+log(ability_u),mixture=.8*ifelse(sign_u<.5,-1,1)+.6*normal,
    minus2.5=normal-2.5,plus2.5=normal+2.5)
  abilities <- lapply(abilities,setNames,persons)
  assign('.Random.seed',seeds$assignment,envir=.GlobalEnv)
  pair_u <- runif(N); link_u <- runif(N)
  grid <- expand.grid(PersonIndex=seq_len(N),Rater=1:6,Criterion=1:3,Event=1:2)
  grid$RowId <- seq_len(nrow(grid))
  assign('.Random.seed',seeds$response,envir=.GlobalEnv)
  response_u <- runif(nrow(grid)); shared_z <- matrix(rnorm(2L*N),N,2L)
  error_z <- qnorm(response_u)
  assign('.Random.seed',seeds$missingness,envir=.GlobalEnv)
  missing_u <- runif(nrow(grid))
  views <- list()
  for(design in c(e_designs,if(N %in% c(20L,480L))e_joint)) {
    s <- e_spec(design,unit$Truth,rates); theta <- abilities[[s$theta_key]]
    if(s$assignment=='links') {
      bridge <- link_u<s$link
      pair <- e_within[1L+floor(6L*pair_u),,drop=FALSE]
      pair[bridge,] <- e_between[1L+floor(9L*pair_u[bridge]),,drop=FALSE]
    } else {
      probs <- switch(s$assignment,uniform=matrix(1/3,N,3L),
        unequal=matrix(rep(c(.6,.3,.1),each=N),N,3L),
        ability=cbind(1/3+.25*tanh(theta),rep(1/3,N),1/3-.25*tanh(theta)))
      pair_id <- 1L+(pair_u>probs[,1L])+(pair_u>rowSums(probs[,1:2,drop=FALSE]))
      pair <- e_pairs3[pair_id,,drop=FALSE]
    }
    p <- grid$PersonIndex
    assigned <- (grid$Rater==pair[p,1L]|grid$Rater==pair[p,2L]) &
      grid$Rater<=s$nr & grid$Event<=max(1L,s$nt)
    d <- grid[assigned,]; rownames(d) <- NULL; ids <- d$RowId
    u <- if(s$rho==0)response_u[ids] else pnorm(sqrt(s$rho)*
      shared_z[cbind(d$PersonIndex,d$Event)]+sqrt(1-s$rho)*error_z[ids])
    mass <- c_mass(theta[d$PersonIndex],d$Rater,d$Criterion,d$Event,s)
    cdf <- t(apply(mass,1L,cumsum))
    score <- as.integer(rowSums(u>cdf[,1:3,drop=FALSE]))
    deletion <- switch(s$deletion,none=rep(0,nrow(d)),independent15=rep(.15,nrow(d)),
      independent30=rep(.30,nrow(d)),rater=c(.05,.15,.25)[d$Rater],
      score=c(.05,.10,.20,.35)[score+1L],matched=rep(s$matched_rate,nrow(d)))
    keep <- missing_u[ids]>=deletion
    planned <- data.frame(RowId=ids,Person=persons[d$PersonIndex],
      Rater=as.character(d$Rater),Criterion=as.character(d$Criterion),Event=d$Event,
      GeneratedScore=score,stringsAsFactors=FALSE)
    if(s$nt>0L)planned$Task <- as.character(d$Event)
    observed <- planned[keep,]; names(observed)[names(observed)=='GeneratedScore'] <- 'Score'
    rownames(observed) <- NULL
    views[[design]] <- list(spec=s,theta_key=s$theta_key,
      assignment=data.frame(Person=persons,Rater1=pair[,1L],Rater2=pair[,2L]),
      planned=planned,deletion_probability=deletion,observed=keep,data=observed)
  }
  list(unit=unit,rng=seeds,persons=persons,abilities=abilities,
    draws=list(ability=ability_u,sign=sign_u,pair=pair_u,link=link_u,
      response=response_u,shared_normal=shared_z,missing=missing_u),views=views)
}

e_check <- function(x,unit,seeds,rates) {
  N <- unit$N
  stopifnot(identical(x$unit,unit),identical(x$rng,seeds),length(x$persons)==N,
    identical(names(x$views),c(e_designs,if(N %in% c(20L,480L))e_joint)),
    identical(unname(x$abilities$normal),qnorm(x$draws$ability)),
    identical(x$abilities$minus2.5,x$abilities$normal-2.5),
    identical(x$abilities$plus2.5,x$abilities$normal+2.5))
  for(design in names(x$views)) {
    v <- x$views[[design]]; s <- v$spec; d <- v$planned; a <- v$assignment
    stopifnot(identical(s,e_spec(design,unit$Truth,rates)),nrow(d)==N*s$ratings,
      all(table(d$Person)==s$ratings),!anyNA(d),!anyDuplicated(d$RowId),
      all(d$GeneratedScore %in% 0:3),all(v$deletion_probability>=0 & v$deletion_probability<=1),
      identical(v$observed,x$draws$missing[d$RowId]>=v$deletion_probability),
      identical(a$Person,x$persons),all(a$Rater1!=a$Rater2))
    p <- match(d$Person,x$persons); r <- as.integer(d$Rater)
    stopifnot(all(r==a$Rater1[p]|r==a$Rater2[p]),
      all(d$RowId==p+N*(r-1L+6L*(as.integer(d$Criterion)-1L)+18L*(d$Event-1L))),
      all(r<=s$nr),all(d$Event<=max(1L,s$nt)))
    observed <- d[v$observed,]; names(observed)[names(observed)=='GeneratedScore'] <- 'Score'
    rownames(observed) <- NULL
    stopifnot(identical(v$data,observed),!anyNA(v$data))
    if(s$nt>0L)stopifnot(identical(d$Task,as.character(d$Event)))
    if(s$deletion!='none') {
      control <- if(s$shape=='right_skew')'E1-right-skew' else 'E0'
      stopifnot(identical(d,x$views[[control]]$planned),
        identical(a,x$views[[control]]$assignment))
    }
  }
  v <- x$views
  stopifnot(all(!v[['E6-missing0.30']]$observed | v[['E6-missing0.15']]$observed))
  for(rho in c('0.25','0.5')) stopifnot(identical(v[['E9-rho0']]$assignment,
    v[[paste0('E9-rho',rho)]]$assignment),identical(v[['E9-rho0']]$planned$RowId,
    v[[paste0('E9-rho',rho)]]$planned$RowId))
  invisible(TRUE)
}

e_account <- function(v,persons) {
  d <- v$data; s <- v$spec; N <- length(persons)
  exposure <- tabulate(match(d$Person,persons),nbins=N)
  total <- numeric(N)
  if(nrow(d)>0L) { a <- tapply(d$Score,d$Person,sum); total[match(names(a),persons)] <- a }
  bridges <- if(s$nr==6L)sum((v$assignment$Rater1<=3L)!=(v$assignment$Rater2<=3L)) else NA_integer_
  c(PlannedPersons=N,ObservedPersons=sum(exposure>0L),ZeroObservedPersons=sum(exposure==0L),
    PlannedRows=nrow(v$planned),ObservedRows=nrow(d),MissingRows=sum(!v$observed),
    ExtremePersons=sum(exposure>0L & (total==0 | total==3L*exposure)),
    LostRaterLevels=s$nr-length(unique(d$Rater)),LostCriterionLevels=3L-length(unique(d$Criterion)),
    LostTaskLevels=if(s$nt>0L)s$nt-length(unique(d$Task)) else 0L,
    MissingCategories=sum(tabulate(d$Score+1L,nbins=4L)==0L),
    Category0=sum(d$Score==0L),Category1=sum(d$Score==1L),
    Category2=sum(d$Score==2L),Category3=sum(d$Score==3L),BridgePersons=bridges)
}

e_preflight <- function(registry,rates) {
  pkgload::load_all('.',quiet=TRUE,compile=FALSE,helpers=FALSE)
  error <- 0
  for(family in c('S-RSM','S-PCM','S-GPCM')) for(design in c('E0','E3-rare-category','E9-rho0','links-dependence-b0.6-rho0')) {
    s <- e_spec(design,family,rates)
    g <- expand.grid(theta=c(-4,0,4),r=seq_len(s$nr),c=1:3,t=seq_len(max(1L,s$nt)))
    p <- c_mass(g$theta,g$r,g$c,g$t,s)
    eta <- g$theta-s$truth$Rater[g$r]-s$truth$Criterion[g$c]
    if(s$nt>0L)eta <- eta-s$truth$Task[g$t]
    steps <- t(apply(s$truth$steps,1L,function(z)c(0,cumsum(z))))
    native <- if(family=='S-GPCM')mfrmr:::category_prob_gpcm(eta,steps,g$c,
      exp(s$truth$log_slopes),g$c) else mfrmr:::category_prob_pcm(eta,steps,g$c)
    error <- max(error,abs(p-native))
    for(j in seq_len(nrow(g))) {
      w <- c(1,cumprod(exp(exp(s$truth$log_slopes[g$c[j]])*
        (eta[j]-s$truth$steps[g$c[j],]))))
      error <- max(error,abs(p[j,]-w/sum(w)))
    }
  }
  # Check the copula's category-CDF marginals without generating extra datasets.
  copula <- expand.grid(rho=c(.25,.5),probability=c(.01,.2,.5,.85,.99))
  copula$IntegratedCDF <- mapply(function(rho,p)integrate(function(z)
    pnorm((qnorm(p)-sqrt(rho)*z)/sqrt(1-rho))*dnorm(z),-Inf,Inf,
    abs.tol=1e-11,rel.tol=1e-11)$value,copula$rho,copula$probability)
  copula_error <- max(abs(copula$IntegratedCDF-copula$probability))
  assignment_mean <- integrate(function(z)(1/3+.25*tanh(z))*dnorm(z),-Inf,Inf,
    abs.tol=1e-11,rel.tol=1e-11)$value
  incidence <- function(pairs) sapply(1:6,function(r)rowSums(pairs==r))
  for(b in c(.6,.2,.05))stopifnot(max(abs(colSums(incidence(e_between))*b/9+
    colSums(incidence(e_within))*(1-b)/6-1/3))<1e-14)
  stopifnot(error<1e-12,copula_error<1e-10,abs(assignment_mean-1/3)<1e-12)
  for(i in which(registry$units$Replicate==1L)) {
    x <- e_generate(registry$units[i,],registry$streams[[i]],rates)
    e_check(x,registry$units[i,],registry$streams[[i]],rates)
  }
  # Explicit all-missing accounting fixture; not an added study replication.
  v <- x$views[['E0']]; v$data <- v$data[FALSE,]; v$observed[] <- FALSE
  a <- e_account(v,x$persons)
  stopifnot(a['ObservedPersons']==0,a['ZeroObservedPersons']==x$unit$N,
    a['ObservedRows']==0,a['MissingRows']==nrow(v$planned),a['ExtremePersons']==0,
    a['LostRaterLevels']==3,a['LostCriterionLevels']==3,a['MissingCategories']==4)
  list(maximum_probability_error=error,copula_marginal_checks=copula,
    maximum_copula_marginal_error=copula_error,ability_assignment_marginal=assignment_mean,
    all_missing_accounting=TRUE,fit_calls=0L)
}

e_prepare <- function(out) {
  rates_object <- readRDS(e_rates_path); rates <- rates_object$rows
  stopifnot(identical(tools::md5sum(names(rates_object$source_md5)),rates_object$source_md5),
    identical(rates_object$specification$deletion,c(.05,.10,.20,.35)),nrow(rates)==6L)
  if(!dir.exists(out)) {
    registry <- e_registry(); preflight <- e_preflight(registry,rates)
    dir.create(file.path(out,'bundles'),recursive=TRUE);dir.create(file.path(out,'source'))
    sources <- c(e_script,e_c_source,file.path(c_ab,'source/mfrm-wide-map-ab-inputs-20261001.R'),
      e_rates_path,names(rates_object$source_md5),ab_allocation,ab_protocol,
      list.files('R',full.names=TRUE),list.files('src',pattern='\\.(cpp|h|so)$',full.names=TRUE))
    for(f in sources) {
      dest <- file.path(out,'source',f);dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
      stopifnot(file.copy(f,dest))
    }
    registry$source_md5 <- tools::md5sum(sources);registry$session <- capture.output(sessionInfo())
    ab_atomic_save(registry,file.path(out,'rng-registry.rds'))
    ab_atomic_save(preflight,file.path(out,'preflight.rds'))
  } else registry <- readRDS(file.path(out,'rng-registry.rds'))
  executable <- registry$source_md5[names(registry$source_md5)!=ab_protocol]
  stopifnot(identical(tools::md5sum(names(executable)),executable),
    identical(unname(tools::md5sum(file.path(out,'source',names(registry$source_md5)))),
      unname(registry$source_md5)),
    identical(tools::md5sum(names(registry$predecessor_md5)),registry$predecessor_md5))
  if(file.exists(file.path(out,'verified-inputs.rds'))) {
    v <- readRDS(file.path(out,'verified-inputs.rds'))
    for(h in list(v$registry_md5,v$inputs_md5,v$preflight_md5))
      stopifnot(identical(tools::md5sum(names(h)),h))
    f <- unique(read.csv(file.path(out,'inputs.csv'))[c('Bundle','BundleMD5')])
    stopifnot(identical(unname(tools::md5sum(f$Bundle)),f$BundleMD5))
    cat('Completed E inputs verified without regeneration.\n');return(invisible(v))
  }
  rows <- list();k <- 0L
  for(i in seq_len(nrow(registry$units))) {
    unit <- registry$units[i,];seeds <- registry$streams[[i]];path <- file.path(out,unit$Bundle)
    if(!file.exists(path)) {
      x <- e_generate(unit,seeds,rates);e_check(x,unit,seeds,rates);ab_atomic_save(x,path)
    }
    x <- readRDS(path);e_check(x,unit,seeds,rates);hash <- unname(tools::md5sum(path))
    for(design in names(x$views)) {
      v <- x$views[[design]];s <- v$spec;k <- k+1L
      rows[[k]] <- cbind(data.frame(ConditionId=paste('E',design,paste0('N',unit$N),'SD1',unit$Truth,sep=':'),
        Replicate=unit$Replicate,CohortId=unit$CohortId,Bundle=path,BundleMD5=hash,View=design,
        Selector='views[[View]]$data',N=unit$N,SD=1,Truth=unit$Truth,Design=design,
        NonPersonFacets=length(s$facets),RaterLevels=s$nr,CriterionLevels=3L,TaskLevels=s$nt,
        Categories=4L,ThetaKey=s$theta_key,Rho=s$rho,LinkProbability=s$link,
        CovarianceSampling=s$covariance_sampling,MatchedRate=s$matched_rate,
        Controls=paste(s$control,collapse=';')),
        as.data.frame(as.list(e_account(v,x$persons))))
    }
    if(i%%100L==0L)cat('Prepared',i,'of 600 E parent bundles\n')
  }
  rows <- do.call(rbind,rows);allocation <- read.csv(ab_allocation,stringsAsFactors=FALSE)
  allocation <- allocation[allocation$Block=='E',]
  stopifnot(nrow(rows)==13800L,setequal(rows$ConditionId,allocation$ConditionId),
    all(table(rows$ConditionId)==50L),!anyDuplicated(rows[c('ConditionId','Replicate')]),
    all(rows$ObservedRows+rows$MissingRows==rows$PlannedRows),
    all(rows$ObservedPersons+rows$ZeroObservedPersons==rows$N),
    sum(allocation$InitialConfigurations)*50L==55200L)
  ix <- c(101L,251L,551L)
  generate <- function(i)e_generate(registry$units[i,],registry$streams[[i]],rates)
  serial <- lapply(rev(ix),generate)
  forked <- parallel::mclapply(ix,generate,mc.cores=2L,mc.set.seed=FALSE)
  for(j in seq_along(ix)) {
    saved <- readRDS(file.path(out,registry$units$Bundle[ix[j]]))
    stopifnot(identical(saved,serial[[length(ix)+1L-j]]),identical(saved,forked[[j]]))
  }
  write.csv(rows,file.path(out,'inputs.csv'),row.names=FALSE)
  ab_atomic_save(list(new_records=13800L,condition_templates=276L,parent_cohorts=600L,
    independent_replicates_per_condition=50L,planned_rows_in_views=sum(rows$PlannedRows),
    observed_rows_in_views=sum(rows$ObservedRows),missing_rows_in_views=sum(rows$MissingRows),
    records_with_zero_observation_persons=sum(rows$ZeroObservedPersons>0),
    records_with_lost_levels=sum(rows$LostRaterLevels+rows$LostCriterionLevels+rows$LostTaskLevels>0),
    fit_calls=0L,reordered_and_two_worker_replay_identical=TRUE,
    registry_md5=tools::md5sum(file.path(out,'rng-registry.rds')),
    inputs_md5=tools::md5sum(file.path(out,'inputs.csv')),
    preflight_md5=tools::md5sum(file.path(out,'preflight.rds')),
    completed=Sys.time(),session=capture.output(sessionInfo())),file.path(out,'verified-inputs.rds'))
  cat('E complete: 13800 new condition views in 600 parent cohorts; no fits.\n')
}

if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args)==1L)
  e_prepare(args[1L])
}
