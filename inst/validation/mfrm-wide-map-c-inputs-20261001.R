# C input freeze: linked facet/workload/category contrasts, no estimation.
# From package root: Rscript THIS_FILE OUTPUT_DIRECTORY (resumes saved bundles).
c_script <- 'inst/validation/mfrm-wide-map-c-inputs-20261001.R'
c_ab <- 'validation-results/mfrm-wide-map-r50-20261001/ab-inputs'
source(file.path(c_ab, 'source/mfrm-wide-map-ab-inputs-20261001.R'))
c_designs <- c('six-raters-paired', 'six-raters-full', 'two-tasks-same-pair',
  'two-tasks-changing-pair', 'four-tasks-all-same-pair',
  'four-tasks-all-changing-pair', 'four-tasks-two-observed',
  'five-criteria-two-tasks-changing-pair', 'three-categories', 'five-categories')

c_spec <- function(design, family) {
  nr <- if (grepl('six-raters', design)) 6L else 3L
  nc <- if (grepl('five-criteria', design)) 5L else 3L
  nt <- if (grepl('four-tasks', design)) 4L else
    if (grepl('two-tasks', design) || design == 'null-task') 2L else 0L
  K <- switch(design, 'three-categories' = 3L, 'five-categories' = 5L, 4L)
  truth <- ab_truth(family); truth$Rater <- rep(truth$Rater, nr/3L)
  if (nc == 5L) {
    extend <- function(x) c(x, sqrt(mean(x^2)), -sqrt(mean(x^2)))
    truth$Criterion <- extend(truth$Criterion)
    truth$log_slopes <- extend(truth$log_slopes)
    h <- c(-.6, 0, .6)
    w <- if (family == 'S-RSM') rep(0, 3) else sqrt(.28/18) * c(1, -2, 1)
    truth$steps <- rbind(truth$steps, h + w, h - w)
  }
  if (K != 4L) {
    q <- seq(-1, 1, length.out = K - 1L)
    u <- if (family == 'S-RSM') rep(0, 3) else c(-.1, .25, -.15)
    v <- if (family == 'S-RSM') rep(0, 3) else c(-.3, .15, .15)
    truth$steps <- outer(.6 + u, q) + outer(v, q^2 - mean(q^2))
  }
  truth$Task <- if (design == 'null-task') c(0, 0) else rep(c(-.2, .2), nt/2L)
  ratings <- if (design == 'six-raters-full') 18L else if (nt == 0L) 6L else
    if (design == 'four-tasks-two-observed') 12L else nt * 2L * nc
  list(design = design, family = family, nr = nr, nc = nc, nt = nt, K = K,
    ratings = ratings, facets = c('Rater', 'Criterion', if (nt > 0L) 'Task'), truth = truth)
}

c_mass <- function(theta, r, c, t, spec) {
  truth <- spec$truth
  eta <- theta - truth$Rater[r] - truth$Criterion[c]
  if (spec$nt > 0L) eta <- eta - truth$Task[t]
  steps <- t(apply(truth$steps, 1L, function(x) c(0, cumsum(x))))
  z <- exp(truth$log_slopes[c]) * (outer(eta, 0:(spec$K-1L)) - steps[c, , drop=FALSE])
  mass <- exp(z - apply(z, 1L, max)); mass / rowSums(mass)
}

c_registry <- function() {
  verified <- readRDS(file.path(c_ab, 'verified-inputs.rds'))
  for (hash in list(verified$registry_md5, verified$inputs_md5))
    stopifnot(identical(tools::md5sum(names(hash)), hash))
  ab <- readRDS(file.path(c_ab, 'rng-registry.rds'))
  stopifnot(unname(tools::md5sum(file.path(c_ab,
    'source/mfrm-wide-map-ab-inputs-20261001.R'))) == ab$source_md5[1L])
  ix <- which(ab$units$SD == 1 & ab$units$N %in% c(20L, 60L, 240L, 480L))
  units <- ab$units[ix, ]; rownames(units) <- NULL
  units$ABBundle <- file.path(c_ab, units$Bundle)
  units$CohortId <- units$ParentId
  units$ParentId <- sub('^AB:', 'C-extension:', units$ParentId)
  units$PairingGroup <- sub('^AB:', 'C-extension:', units$PairingGroup)
  units$Bundle <- sprintf('bundles/parent-%04d.rds', seq_len(nrow(units)))
  ab_inputs <- read.csv(file.path(c_ab, 'inputs.csv'), stringsAsFactors=FALSE)
  units$ABBundleMD5 <- ab_inputs$BundleMD5[match(units$CohortId, ab_inputs$ParentId)]
  stopifnot(nrow(units) == 600L, !anyNA(units$ABBundleMD5))
  next_stream <- ab$next_unused_unit_stream; streams <- vector('list', 600L)
  for (i in seq_len(600L)) {
    component <- next_stream; seeds <- list()
    for (name in c('ability_reserved', 'assignment_reserved', 'response', 'missingness', 'F_first_unused')) {
      seeds[[name]] <- component; component <- parallel::nextRNGSubStream(component)
    }
    streams[[i]] <- seeds; next_stream <- parallel::nextRNGStream(next_stream)
  }
  names(streams) <- units$ParentId
  stopifnot(!anyDuplicated(c(vapply(ab$streams, function(s) paste(s$ability,collapse=','), ''),
    vapply(streams, function(s) paste(s$ability_reserved,collapse=','), ''))))
  list(epoch='development-C-20261001-v1', phase='development', units=units, streams=streams,
    first_unit_stream=ab$next_unused_unit_stream, next_unused_unit_stream=next_stream,
    inherited_rng=ab$RNG, predecessor_md5=verified$registry_md5,
    scope='C response extensions share saved A/B cohorts; no fitting or F panels.')
}

c_generate <- function(unit, seeds) {
  stopifnot(unname(tools::md5sum(unit$ABBundle)) == unit$ABBundleMD5)
  ab <- readRDS(unit$ABBundle); N <- unit$N
  grid <- expand.grid(PersonIndex=seq_len(N), Rater=1:6, Criterion=1:5, Event=1:4)
  grid$RowId <- seq_len(nrow(grid))
  u <- numeric(nrow(grid))
  common <- grid$Rater <= 3L & grid$Criterion <= 3L & grid$Event <= 2L
  abrow <- grid$PersonIndex + N * (grid$Rater-1L + 3L*(grid$Criterion-1L) + 9L*(grid$Event-1L))
  assign('.Random.seed', ab$rng$response, envir=.GlobalEnv)
  u[common] <- runif(18L*N)[abrow[common]]
  assign('.Random.seed', seeds$response, envir=.GlobalEnv)
  u[!common] <- runif(sum(!common))
  slot <- match(seq_len(N), ab$person_order)
  pair3 <- rbind(c(1,2),c(2,3),c(3,1))
  pair6 <- matrix(c(1,6,2,5,3,4, 1,5,6,4,2,3, 1,4,5,3,6,2,
    1,3,4,2,5,6, 1,2,3,6,4,5), ncol=2, byrow=TRUE)
  views <- specs <- list()
  for (design in c(c_designs, 'null-task')) {
    spec <- c_spec(design, unit$Truth); specs[[design]] <- spec
    p <- grid$PersonIndex; g <- ab$assignment$PairId[p]
    if (grepl('changing-pair', design)) g <- 1L + (g + grid$Event - 2L) %% 3L
    rp <- pair3[g, , drop=FALSE]
    if (design == 'six-raters-paired') rp <- pair6[1L+(slot[p]-1L)%%15L, , drop=FALSE]
    assigned <- grid$Rater == rp[,1L] | grid$Rater == rp[,2L]
    if (design == 'six-raters-full') assigned[] <- TRUE
    if (design == 'four-tasks-two-observed') {
      rp <- pair3[1L+(slot[p]-1L)%%3L, , drop=FALSE]
      first_task <- 1L+(slot[p]-1L)%%4L; second_task <- 1L+first_task%%4L
      assigned <- (grid$Rater == rp[,1L] | grid$Rater == rp[,2L]) &
        (grid$Event == first_task | grid$Event == second_task)
    }
    keep <- assigned & grid$Rater <= spec$nr & grid$Criterion <= spec$nc &
      grid$Event <= max(1L,spec$nt)
    d <- grid[keep, ]; rownames(d) <- NULL
    mass <- c_mass(ab$theta[d$PersonIndex], d$Rater, d$Criterion, d$Event, spec)
    cdf <- mass
    for (k in 2:spec$K) cdf[,k] <- cdf[,k-1L] + mass[,k]
    score <- as.integer(rowSums(u[keep] > cdf[,seq_len(spec$K-1L),drop=FALSE]))
    data <- data.frame(RowId=d$RowId, Person=names(ab$theta)[d$PersonIndex],
      Rater=as.character(d$Rater), Criterion=as.character(d$Criterion), Event=d$Event, Score=score)
    if (spec$nt > 0L) data$Task <- as.character(data$Event)
    views[[design]] <- data
  }
  # Null Task is a check against an alias, not an additional stored response dataset.
  ab_null <- ab$views[['paired-L2']]
  key <- function(d) paste(d$Person,d$Rater,d$Criterion,d$Event,sep=':')
  stopifnot(identical(views[['null-task']]$Score,
    ab_null$Score[match(key(views[['null-task']]),key(ab_null))]))
  views[['null-task']] <- NULL
  list(unit=unit, rng=seeds, theta=ab$theta, person_order=ab$person_order,
    specs=specs, views=views, alias=list(source=unit$ABBundle,
      source_md5=unit$ABBundleMD5, view='paired-L2', transform='Task=as.character(Event)'))
}

c_null <- function(x) {
  d <- readRDS(x$alias$source)$views[[x$alias$view]]
  d$Task <- as.character(d$Event); d
}

c_check <- function(x, unit, seeds) {
  stopifnot(identical(x$unit,unit),identical(x$rng,seeds),identical(names(x$views),c_designs))
  ab <- readRDS(unit$ABBundle)
  stopifnot(identical(x$theta,ab$theta),identical(x$person_order,ab$person_order))
  for (design in c_designs) {
    d <- x$views[[design]]; s <- c_spec(design,unit$Truth)
    stopifnot(identical(x$specs[[design]],s), nrow(d)==unit$N*s$ratings,
      !anyNA(d),!anyDuplicated(d$RowId),all(d$Score %in% 0:(s$K-1L)),
      all(table(d$Person)==s$ratings),length(unique(d$Rater))==s$nr,
      length(unique(d$Criterion))==s$nc,all(table(d$Criterion)==nrow(d)/s$nc),
      max(abs(rowSums(s$truth$steps)))<1e-12,abs(sum(s$truth$log_slopes))<1e-12)
    if (s$nt>0L) stopifnot(length(unique(d$Task))==s$nt,
      all(table(d$Task)==nrow(d)/s$nt))
  }
  same <- function(a,b,subset=TRUE) {
    ix <- match(a$RowId,b$RowId); ok <- !is.na(ix)
    stopifnot(any(ok),identical(a$Score[ok],b$Score[ix[ok]]))
    if(subset) stopifnot(all(ok))
  }
  same(x$views[['six-raters-paired']],x$views[['six-raters-full']])
  for (roster in c('same','changing'))
    same(x$views[[paste0('two-tasks-',roster,'-pair')]],
      x$views[[paste0('four-tasks-all-',roster,'-pair')]])
  same(x$views[['two-tasks-changing-pair']],x$views[['five-criteria-two-tasks-changing-pair']])
  same(x$views[['two-tasks-same-pair']],x$views[['two-tasks-changing-pair']],subset=FALSE)
  d <- x$views[['six-raters-full']]; d <- d[as.integer(d$Rater)<=3L, ]
  key <- function(d) paste(d$Person,d$Rater,d$Criterion,d$Event,sep=':')
  a <- ab$views[['full-L1']]
  stopifnot(nrow(d)==nrow(a),identical(d$Score,a$Score[match(key(d),key(a))]))
  for(design in c('three-categories','five-categories')) stopifnot(
    setequal(key(x$views[[design]]),key(ab$views[['paired-L1']])))
  invisible(TRUE)
}

c_structure <- function(data, spec, N) {
  cell <- do.call(paste,c(data[spec$facets],sep=':'))
  exposure <- table(data$Person,cell)
  roster <- apply(exposure,1L,paste,collapse=':'); counts <- table(roster)
  X <- model.matrix(reformulate(spec$facets), data)[,-1L,drop=FALSE]
  person <- match(data$Person,rownames(exposure))
  means <- rowsum(X,person,reorder=FALSE)/as.numeric(table(person))
  centered <- X-means[match(person,unique(person)),,drop=FALSE]
  rank <- qr(centered)$rank
  location_p <- spec$nr-1L+spec$nc-1L+max(0L,spec$nt-1L)
  p <- location_p+spec$nc*(spec$K-2L)+spec$nc-1L
  states <- ((spec$K-1L)*spec$ratings/spec$nc+1)^spec$nc
  rater_persons <- table(unique(data[c('Person','Rater')])$Rater)
  stopifnot(rank==location_p)
  data.frame(Design=spec$design,N=N,NonPersonFacets=length(spec$facets),
    RaterLevels=spec$nr,CriterionLevels=spec$nc,TaskLevels=spec$nt,Categories=spec$K,
    RatingsPerPerson=spec$ratings,LocationRank=rank,LocationParameters=location_p,
    MinPersonsPerRater=min(rater_persons),MaxPersonsPerRater=max(rater_persons),
    GPCMParameters=p,OwnerTotalStates=states,Rosters=length(counts),
    SingletonRosters=sum(counts==1L),FixedRosterRankCeiling=N-length(counts),
    CorrectedCapacity=states<=5000,
    FixedRosterCountFeasible=all(counts>=2L)&&N-length(counts)>=p)
}

c_preflight <- function(registry) {
  pkgload::load_all('.',quiet=TRUE,compile=FALSE,helpers=FALSE)
  rows <- list(); fixtures <- list(); max_native <- max_recurrence <- 0
  for (i in which(registry$units$Replicate==1L)) {
    x <- c_generate(registry$units[i, ],registry$streams[[i]])
    c_check(x,registry$units[i, ],registry$streams[[i]])
    fixtures[[as.character(i)]] <- x
    for (design in c(c_designs,'null-task')) {
      d <- if (design=='null-task') c_null(x) else x$views[[design]]
      s <- x$specs[[design]]; key <- paste(x$unit$N,x$unit$Truth,design,sep=':')
      rows[[key]] <- cbind(Truth=x$unit$Truth,c_structure(d,s,x$unit$N))
      if (x$unit$N != 20L) next
      prep <- mfrmr:::prepare_mfrm_data(d,'Person',s$facets,'Score',rating_min=0,rating_max=s$K-1L)
      config <- list(model=sub('^S-','',x$unit$Truth),facet_names=s$facets,
        n_person=x$unit$N,population_spec=list(active=FALSE))
      params <- list(facets=s$truth[s$facets],steps=s$truth$steps[1L,],
        steps_mat=s$truth$steps,slopes=exp(s$truth$log_slopes))
      idx <- mfrmr:::build_indices(prep,'Criterion','Criterion')
      nodes <- c(-3,0,3)
      native <- mfrmr:::mfrm_mml_logprob_bundle_r(idx,config,
        list(nodes=nodes,weights=rep(1/3,3)),params,
        mfrmr:::compute_base_eta(idx,params,config),include_probs=TRUE)$prob_list
      for (q in seq_along(nodes)) {
        r <- as.integer(d$Rater); cc <- as.integer(d$Criterion); t <- d$Event
        mass <- c_mass(rep(nodes[q],nrow(d)),r,cc,t,s)
        max_native <- max(max_native,abs(mass-native[[q]]))
        # Direct scalar adjacent ratios on every distinct rating context.
        context <- !duplicated(d[c(s$facets)])
        for (j in which(context)) {
          eta <- nodes[q]-s$truth$Rater[r[j]]-s$truth$Criterion[cc[j]]-
            if (s$nt>0L) s$truth$Task[t[j]] else 0
          odds <- exp(exp(s$truth$log_slopes[cc[j]])*(eta-s$truth$steps[cc[j],]))
          weights <- c(1,cumprod(odds))
          max_recurrence <- max(max_recurrence,abs(mass[j,]-weights/sum(weights)))
        }
      }
      if (x$unit$Truth=='S-GPCM') {
        native_problem <- tryCatch(mfrmr:::mfrm_jml_adjustment_problem(d,'Person',s$facets,
          'Score','Criterion',s$K-1L),error=function(e)e)
        row <- rows[[key]]
        if (row$CorrectedCapacity) stopifnot(!inherits(native_problem,'error'),
          nrow(native_problem$parameters)==row$GPCMParameters,
          all(native_problem$total_states==row$OwnerTotalStates),
          length(unique(native_problem$roster))==row$Rosters,
          sum(table(native_problem$roster)==1L)==row$SingletonRosters)
        else stopifnot(inherits(native_problem,'error'),
          grepl('Owner-total space exceeds max_states',conditionMessage(native_problem),fixed=TRUE))
      }
    }
  }
  stopifnot(max_native<1e-12,max_recurrence<1e-12)
  list(rows=do.call(rbind,rows),fixtures=fixtures,native_probability_error=max_native,
    scalar_recurrence_error=max_recurrence,fit_calls=0L)
}

c_prepare <- function(out) {
  if (!dir.exists(out)) {
    registry <- c_registry(); preflight <- c_preflight(registry)
    dir.create(file.path(out,'bundles'),recursive=TRUE); dir.create(file.path(out,'source'))
    sources <- c(c_script,ab_allocation,ab_protocol,
      file.path(c_ab,'source/mfrm-wide-map-ab-inputs-20261001.R'),
      list.files('R',full.names=TRUE),list.files('src',pattern='\\.(cpp|h|so)$',full.names=TRUE))
    for (f in sources) {
      dest <- file.path(out,'source',f); dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
      stopifnot(file.copy(f,dest))
    }
    registry$source_md5 <- tools::md5sum(sources)
    registry$session <- capture.output(sessionInfo())
    ab_atomic_save(registry,file.path(out,'rng-registry.rds'))
    ab_atomic_save(preflight[names(preflight)!='fixtures'],file.path(out,'preflight.rds'))
    write.csv(preflight$rows,file.path(out,'design-checks.csv'),row.names=FALSE)
  } else {
    registry <- readRDS(file.path(out,'rng-registry.rds'))
    preflight <- readRDS(file.path(out,'preflight.rds'))
  }
  frozen <- file.path(out,'source',names(registry$source_md5))
  executable <- registry$source_md5[names(registry$source_md5)!=ab_protocol]
  stopifnot(identical(unname(tools::md5sum(frozen)),unname(registry$source_md5)),
    identical(tools::md5sum(names(executable)),executable),
    identical(tools::md5sum(names(registry$predecessor_md5)),registry$predecessor_md5))
  if(file.exists(file.path(out,'verified-inputs.rds'))) {
    verified <- readRDS(file.path(out,'verified-inputs.rds'))
    for(hash in list(verified$registry_md5,verified$inputs_md5,verified$design_md5))
      stopifnot(identical(tools::md5sum(names(hash)),hash))
    saved <- unique(read.csv(file.path(out,'inputs.csv'))[c('Bundle','BundleMD5')])
    stopifnot(identical(unname(tools::md5sum(saved$Bundle)),saved$BundleMD5))
    cat('Completed C freeze verified; no regeneration.\n'); return(invisible(verified))
  }
  inputs <- list(); k <- 0L
  for (i in seq_len(nrow(registry$units))) {
    unit <- registry$units[i, ]; seeds <- registry$streams[[i]]
    path <- file.path(out,unit$Bundle)
    if(!file.exists(path)) {
      x <- preflight$fixtures[[as.character(i)]]
      if (is.null(x)) x <- c_generate(unit,seeds)
      c_check(x,unit,seeds); ab_atomic_save(x,path)
    }
    x <- readRDS(path); c_check(x,unit,seeds)
    hash <- unname(tools::md5sum(path))
    for (design in c(c_designs,'null-task')) {
      alias <- design=='null-task'; d <- if (alias) c_null(x) else x$views[[design]]
      s <- x$specs[[design]]; total <- tapply(d$Score,d$Person,sum)
      k <- k+1L
      inputs[[k]] <- data.frame(ConditionId=paste('C',design,paste0('N',unit$N),'SD1',unit$Truth,sep=':'),
        Replicate=unit$Replicate,ExtensionId=unit$ParentId,CohortId=unit$CohortId,
        Bundle=if(alias)unit$ABBundle else path,BundleMD5=if(alias)unit$ABBundleMD5 else hash,
        View=if(alias)'paired-L2' else design,InputAlias=alias,
        Transform=if(alias)'Task=as.character(Event)' else 'none',
        Design=design,N=unit$N,SD=1,Truth=unit$Truth,ObservedRows=nrow(d),
        ExtremePersons=sum(total==0|total==s$ratings*(s$K-1L)))
    }
    if (i%%100L==0L) cat('Prepared',i,'of 600 C extension bundles\n')
  }
  inputs <- do.call(rbind,inputs); allocation <- read.csv(ab_allocation,stringsAsFactors=FALSE)
  expected <- allocation[allocation$Block=='C',]
  stopifnot(nrow(inputs)==6600L,sum(!inputs$InputAlias)==6000L,sum(inputs$InputAlias)==600L,
    setequal(unique(inputs$ConditionId),expected$ConditionId),all(table(inputs$ConditionId)==50L),
    !anyDuplicated(inputs[c('ConditionId','Replicate')]),
    sum(inputs$ObservedRows[!inputs$InputAlias])==16800000L)
  ix <- c(101L,451L)
  generate <- function(i)c_generate(registry$units[i,],registry$streams[[i]])
  serial <- lapply(rev(ix),generate)
  parallel <- parallel::mclapply(ix,generate,mc.cores=2L,mc.set.seed=FALSE)
  for(j in seq_along(ix)) {
    saved <- readRDS(file.path(out,registry$units$Bundle[ix[j]]))
    stopifnot(identical(saved,serial[[3L-j]]),identical(saved,parallel[[j]]))
  }
  write.csv(inputs,file.path(out,'inputs.csv'),row.names=FALSE)
  ab_atomic_save(list(new_records=6000L,aliases=600L,condition_templates=132L,
    new_response_rows=16800000L,extension_stream_units=600L,new_independent_cohorts=0L,
    independent_replicates_per_condition=50L,fit_calls=0L,
    native_probability_error=preflight$native_probability_error,
    scalar_recurrence_error=preflight$scalar_recurrence_error,
    reordered_and_two_worker_replay_identical=TRUE,
    registry_md5=tools::md5sum(file.path(out,'rng-registry.rds')),
    inputs_md5=tools::md5sum(file.path(out,'inputs.csv')),
    design_md5=tools::md5sum(file.path(out,'design-checks.csv')),
    completed=Sys.time(),session=capture.output(sessionInfo())),file.path(out,'verified-inputs.rds'))
  cat('C complete: 6000 new views + 600 A/B aliases; no fits.\n')
}

if (sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE); stopifnot(length(args)==1L)
  c_prepare(args[1L])
}
