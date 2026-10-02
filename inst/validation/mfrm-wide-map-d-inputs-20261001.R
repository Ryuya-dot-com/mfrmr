# D response/target freeze only. No fitting, scoring or old-queue resumption.
# From package root: Rscript THIS_FILE OUTPUT_DIRECTORY
d_script <- 'inst/validation/mfrm-wide-map-d-inputs-20261001.R'
d_root <- 'validation-results/mfrm-wide-map-r50-20261001'
d_ab <- file.path(d_root,'ab-inputs')
d_matched <- 'validation-results/gmfrm-adaptive-matched-20260930'
d_core <- 'validation-results/gmfrm-core-screen-20261001'
d_bridge <- 'validation-results/gmfrm-adaptive-independent-20261001'
d_sparse <- file.path(d_bridge,'source/inst/validation/gmfrm-sparse-intervals-20260928.R')
d_core_generator <- file.path(d_core,'source/generator.R')
source(file.path(d_ab,'source/mfrm-wide-map-ab-inputs-20261001.R'))
source(d_sparse)
source(d_core_generator)

d_hash <- function(path, hashes) {
  target <- normalizePath(path)
  index <- match(target,names(hashes))
  if(is.na(index))index<-match(target,normalizePath(names(hashes)))
  expected <- hashes[index]
  stopifnot(length(expected)==1L,!is.na(expected),unname(tools::md5sum(path))==unname(expected))
  invisible(TRUE)
}

d_context <- function() {
  matched <- readRDS(file.path(d_matched,'manifest.rds'))
  core <- readRDS(file.path(d_core,'manifest.rds'))
  bridge <- readRDS(file.path(d_bridge,'manifest.rds'))
  original <- readRDS(file.path(matched$original,'manifest.rds'))
  summary <- readRDS(file.path(d_matched,'summary.rds'))
  ab_verified<-readRDS(file.path(d_ab,'verified-inputs.rds'))
  d_hash(names(ab_verified$inputs_md5),ab_verified$inputs_md5)
  stopifnot(bridge$generator_check$reproduced_cases==400L,
    unname(tools::md5sum(d_sparse))==unname(bridge$generator_check$current_file_hash),
    identical(original$plan,gmfrm_sparse_plan()),
    summary$manifest_md5==unname(tools::md5sum(file.path(d_matched,'manifest.rds'))))
  d_hash(d_core_generator,core$source_hashes)
  list(matched=matched,core=core,bridge=bridge,original=original,summary=summary,
    ab_inputs=read.csv(file.path(d_ab,'inputs.csv'),stringsAsFactors=FALSE))
}

d_truth <- function(family, sd) {
  if(grepl('^H-',family)) {
    second <- seq(.75,1.25,length.out=6); g <- exp(mean(log(second)))
    list(facets=c('Task','Rater'),levels=list(Task=paste0('t',1:3),Rater=paste0('r',1:6)),
      locations=list(Task=c(-.4,.1,.3),Rater=seq(-.3,.3,length.out=6)),
      slopes=list(Task=if(family %in% c('H-both','H-first-only'))exp(c(-.2,0,.2)) else rep(1,3),
        Rater=if(family %in% c('H-both','H-second-only'))second else rep(g,6)),
      steps=outer(seq(.45,.7,length.out=6),c(-1,1)),K=3L,mu=0,sd=sd)
  } else {
    base <- if(family %in% c('S-PCM','rubric-first-only'))'S-PCM' else 'S-GPCM'
    b <- ab_truth(base)
    list(facets=c('Rater','Criterion'),levels=list(Rater=as.character(1:3),Criterion=as.character(1:3)),
      locations=b[c('Rater','Criterion')],
      slopes=list(Rater=if(grepl('^rubric-',family))exp(c(-.2,0,.2)) else rep(1,3),
        Criterion=exp(b$log_slopes)),steps=b$steps,K=4L,mu=0,sd=sd)
  }
}

d_probability <- function(theta, first, second, truth) {
  eta <- theta-truth$locations[[1L]][first]-truth$locations[[2L]][second]
  slope <- truth$slopes[[1L]][first]*truth$slopes[[2L]][second]
  z <- matrix(0,length(theta),truth$K)
  for(k in seq_len(truth$K-1L)) z[,k+1L] <- z[,k]+slope*(eta-truth$steps[second,k])
  mass <- exp(z-apply(z,1L,max)); mass/rowSums(mass)
}

d_draw <- function(theta, first, second, uniform, truth) {
  mass <- d_probability(theta,first,second,truth); cumulative <- numeric(length(theta))
  score <- integer(length(theta))
  for(k in seq_len(truth$K-1L)) {
    cumulative <- cumulative+mass[,k]; score <- score+as.integer(uniform>cumulative)
  }
  score
}

d_contract <- function(truth) {
  fixed <- truth; fixed$locations[[1L]] <- truth$locations[[1L]]/truth$sd
  fixed$locations[[2L]] <- (truth$locations[[2L]]-truth$mu)/truth$sd
  fixed$steps <- truth$steps/truth$sd; fixed$slopes[[2L]] <- truth$sd*truth$slopes[[2L]]
  fixed$mu <- 0; fixed$sd <- 1
  g <- exp(mean(log(truth$slopes[[2L]])))
  relative <- truth; relative$locations <- lapply(truth$locations,function(x)g*x)
  relative$steps <- g*truth$steps; relative$slopes[[2L]] <- truth$slopes[[2L]]/g
  relative$mu <- g*truth$mu; relative$sd <- g*truth$sd
  first_equal <- max(abs(truth$slopes[[1L]]-1))<1e-12
  second_equal <- max(abs(truth$slopes[[2L]]-g))<1e-12
  list(canonical=truth,two_family_fixed_normal=fixed,relative_population=relative,
    correctly_specified=c(PCM=first_equal&&second_equal,GPCM_first=second_equal,
      GPCM_second=first_equal,two_family=TRUE),
    native_parameters_if_misspecified='No true native MLE target asserted; compare population-relative probabilities.',
    z_grid=c(-2,-1,0,1,2),two_family_parameters=
      2L*(length(truth$levels[[1L]])-1L)+length(truth$levels[[2L]])*truth$K)
}

d_registry <- function(context) {
  head <- readRDS(file.path(d_root,'rng-head.rds'))
  stopifnot(head$epoch=='development-C-20261001-v1')
  d_hash(head$registry,head$registry_md5)
  predecessor <- readRDS(head$registry)
  rows <- list(); add <- function(type,N,rep,sd=NA_real_,roster='',abrow=NULL) {
    id <- paste('D',type,paste0('N',N),paste0('SD',sd),roster,sprintf('rep%03d',rep),sep=':')
    if(type=='rubric')id<-paste0('D-rubric:',abrow$ParentId)
    rows[[length(rows)+1L]] <<- data.frame(Type=type,N=N,SD=sd,Roster=roster,Replicate=rep,
      UnitId=id,CohortId=if(type=='rubric')abrow$ParentId else id,
      ABParent=if(type=='rubric')file.path(d_ab,abrow$Bundle) else '',
      ABFamily=if(type=='rubric')abrow$Truth else '',stringsAsFactors=FALSE)
  }
  for(N in c(20L,30L,40L,60L))for(rep in 1:50)add('historical-new',N,rep)
  for(rep in 1:50)add('historical-240',240L,rep)
  for(N in c(120L,480L))for(sd in c(.5,1))for(roster in c('common_persons','rotating_pairs'))
    for(rep in 1:50)add('historical-core',N,rep,sd,roster)
  av <- readRDS(file.path(d_ab,'verified-inputs.rds')); d_hash(names(av$registry_md5),av$registry_md5)
  ab <- readRDS(file.path(d_ab,'rng-registry.rds'))
  selected <- ab$units[ab$units$N %in% c(20L,60L,240L,480L)&ab$units$Truth!='S-RSM',]
  for(i in seq_len(nrow(selected)))add('rubric',selected$N[i],selected$Replicate[i],selected$SD[i],abrow=selected[i,])
  units <- do.call(rbind,rows); units$Bundle <- sprintf('bundles/parent-%04d.rds',seq_len(nrow(units)))
  stopifnot(nrow(units)==1450L,!anyDuplicated(units$UnitId))
  streams <- vector('list',nrow(units)); next_stream <- predecessor$next_unused_unit_stream
  for(i in seq_len(nrow(units))) {
    state <- next_stream; seeds <- list()
    for(name in c('ability','assignment','response','missingness','F_first_unused')) {
      seeds[[name]]<-state; state<-parallel::nextRNGSubStream(state)
    }
    streams[[i]]<-seeds; next_stream<-parallel::nextRNGStream(next_stream)
  }
  names(streams)<-units$UnitId
  list(epoch='development-D-20261001-v1',phase='development',units=units,streams=streams,
    predecessor_md5=head$registry_md5,first_unit_ordinal=head$next_unit_ordinal,
    next_unit_ordinal=head$next_unit_ordinal+nrow(units),
    first_unit_stream=predecessor$next_unused_unit_stream,next_unused_unit_stream=next_stream,
    source_note=context$bridge$generator_check)
}

d_legacy <- function(path,context) {
  hashes <- c(context$matched$input_hashes,context$core$input_hashes)
  d_hash(path,hashes); readRDS(path)
}

d_new_rosters <- function(N, seed) {
  assign('.Random.seed',seed,envir=.GlobalEnv)
  common <- matrix(FALSE,N,6); ix <- sample.int(N); bridge <- N%/%5L
  common[ix[seq_len(bridge)],] <- TRUE
  remaining <- N-bridge; counts <- rep(remaining%/%6L,6)+as.integer(1:6<=remaining%%6L)
  common[cbind(ix[-seq_len(bridge)],rep(1:6,counts))] <- TRUE
  pairs <- rbind(c(1,2),c(3,4),c(5,6),c(2,3),c(4,5),c(6,1))
  counts <- rep(N%/%6L,6)+as.integer(1:6<=N%%6L)
  panel <- pairs[rep(1:6,counts),]; ix2 <- sample.int(N); rotating <- matrix(FALSE,N,6)
  rotating[cbind(ix2,panel[,1])]<-TRUE; rotating[cbind(ix2,panel[,2])]<-TRUE
  stopifnot(sum(common)==2L*N,sum(rotating)==2L*N,
    diff(range(colSums(common)))<=1,diff(range(colSums(rotating)))<=1)
  list(rosters=list(common_persons=common,rotating_pairs=rotating),
    orders=list(common=ix,rotating=ix2))
}

d_generate <- function(unit,seeds,context) {
  N<-unit$N; saved<-list(); sources<-character(); roster_orders<-NULL
  if(unit$Type=='historical-240') {
    RNGkind('Mersenne-Twister','Inversion','Rejection')
    replay<-gmfrm_sparse_data(unit$Replicate,context$original$plan)
    old_seed<-context$original$plan$seed+unit$Replicate
    set.seed(old_seed); z<-rnorm(N); u<-runif(18L*N)
    stopifnot(identical(z,replay$z)); rosters<-replay$rosters
    for(key in names(replay$cases)) {
      path<-file.path(context$matched$original,sprintf('%03d-%s.rds',unit$Replicate,key))
      old<-d_legacy(path,context)
      stopifnot(identical(old$case,replay$cases[[key]]),old$seed==old_seed)
      saved[[key]]<-list(case=old$case,path=path,seed=old$seed)
      sources<-c(sources,path)
    }
    sds<-c(.5,1); rng_origin<-list(kind=RNGkind(),seed=old_seed,
      reconstruction='Recorded-source bridge; exact saved case/truth/seed identity.')
  } else if(unit$Type=='historical-core') {
    plan<-context$core$scenarios
    s<-plan[plan$Persons==N&plan$AbilitySD==unit$SD&plan$Roster==unit$Roster,]
    stopifnot(nrow(s)==1L)
    replay<-gmfrm_design_data(s,unit$Replicate)
    path<-file.path(d_core,'inputs',sprintf('%03d-%s.rds',unit$Replicate,s$Scenario))
    old<-d_legacy(path,context)
    check<-list(data=replay$data,truth=replay$truth,design=s$Roster,sd=s$AbilitySD)
    stopifnot(identical(old$case,check),identical(old$scenario,s),old$seed==replay$seed)
    set.seed(replay$seed,kind='Mersenne-Twister',normal.kind='Inversion',sample.kind='Rejection')
    z<-rnorm(N);u<-runif(18L*N);stopifnot(identical(unit$SD*z,replay$theta))
    rosters<-setNames(list(replay$roster),unit$Roster);sds<-unit$SD
    saved[[paste(unit$Roster,unit$SD,sep='-')]]<-list(case=old$case,path=path,seed=old$seed)
    sources<-path;rng_origin<-list(kind=RNGkind(),seed=old$seed,reconstruction='Frozen core generator, exact case/truth/scenario identity.')
  } else if(unit$Type=='historical-new') {
    assign('.Random.seed',seeds$ability,envir=.GlobalEnv);z<-rnorm(N)
    a<-d_new_rosters(N,seeds$assignment);rosters<-a$rosters;roster_orders<-a$orders
    assign('.Random.seed',seeds$response,envir=.GlobalEnv);u<-runif(18L*N);sds<-c(.5,1)
    rng_origin<-list(kind=RNGkind(),seeds=seeds)
  } else {
    av<-context$ab_inputs
    hash<-av$BundleMD5[match(unit$CohortId,av$ParentId)]
    stopifnot(unname(tools::md5sum(unit$ABParent))==hash)
    ab<-readRDS(unit$ABParent);z<-ab$theta/unit$SD
    assign('.Random.seed',ab$rng$response,envir=.GlobalEnv);u<-runif(9L*N)
    sources<-unit$ABParent;rng_origin<-list(kind=RNGkind(),inherited=ab$rng)
  }
  views<-list()
  if(unit$Type!='rubric') {
    grid<-expand.grid(Person=seq_len(N),First=1:3,Second=1:6)
    families<-c('H-both',if(N %in% c(20L,60L,240L,480L))c('H-equal','H-first-only','H-second-only'))
    for(sd in sds)for(roster in names(rosters))for(family in families) {
      truth<-d_truth(family,sd);keep<-rosters[[roster]][cbind(grid$Person,grid$Second)]
      score<-d_draw(sd*z[grid$Person],grid$First,grid$Second,u,truth)
      key<-paste(roster,sd,sep='-'); base<-saved[[key]]
      short<-if(roster=='common_persons')'common' else 'rotating-pair'
      design<-paste0(if(family=='H-both')'historical-full-' else 'historical-reduced-',short)
      id<-paste('D',design,paste0('N',N),paste0('SD',sd),family,sep=':')
      data<-data.frame(Person=sprintf('p%03d',grid$Person[keep]),Task=paste0('t',grid$First[keep]),
        Rater=paste0('r',grid$Second[keep]),Score=score[keep])
      if(!is.null(base)) {
        original<-base$case$data
        stopifnot(identical(as.character(original$Person),data$Person),
          identical(as.character(original$Task),data$Task),identical(as.character(original$Rater),data$Rater))
        if(family=='H-both') {
          stopifnot(identical(original$Score,data$Score),
            max(abs(base$case$truth$Truth-c(truth$slopes[[1]],sd*truth$slopes[[2]])))<1e-12)
          data<-NULL
        } else { original$Score<-data$Score;data<-original }
      }
      reused<-family=='H-both'&&!is.null(base)
      views[[id]]<-list(data=data,truth=truth,design=design,family=family,sd=sd,
        reused=reused,source=if(reused)base$path else '',rows=6L*N)
    }
  } else {
    grid<-expand.grid(Person=seq_len(N),First=1:3,Second=1:3)
    family<-if(unit$ABFamily=='S-PCM')'rubric-first-only' else 'rubric-both'
    truth<-d_truth(family,unit$SD)
    score<-d_draw(ab$theta[grid$Person],grid$First,grid$Second,u,truth)
    baseline<-d_draw(ab$theta[grid$Person],grid$First,grid$Second,u,d_truth(unit$ABFamily,unit$SD))
    for(design in c('full-L1','paired-L1')) {
      data<-ab$views[[design]];stopifnot(identical(data$Score,baseline[data$RowId]))
      data$Score<-score[data$RowId]
      id<-paste('D',design,paste0('N',N),paste0('SD',unit$SD),family,sep=':')
      views[[id]]<-list(data=data,truth=truth,design=design,family=family,sd=unit$SD,
        reused=FALSE,source='',rows=nrow(data))
    }
    rosters<-NULL
  }
  list(unit=unit,stream=seeds,latent_z=z,uniform=u,rosters=rosters,roster_orders=roster_orders,
    rng_origin=rng_origin,source_md5=tools::md5sum(sources),views=views)
}

d_view_data <- function(view) if(view$reused) readRDS(view$source)$case$data else view$data

d_check <- function(x,unit,seeds) {
  stopifnot(identical(x$unit,unit),identical(x$stream,seeds),length(x$latent_z)==unit$N,
    all(is.finite(x$latent_z)),all(x$uniform>=0&x$uniform<1))
  for(view in x$views) {
    data<-d_view_data(view);t<-view$truth
    stopifnot(nrow(data)==view$rows,all(data$Score %in% 0:(t$K-1L)),
      length(unique(data$Person))==unit$N,!anyNA(data),
      !anyDuplicated(data[c('Person',t$facets)]),
      abs(sum(log(t$slopes[[1]])))<1e-12,max(abs(rowSums(t$steps)))<1e-12)
    for(f in t$facets)stopifnot(setequal(as.character(data[[f]]),t$levels[[f]]))
    exposure<-table(data$Person)
    if(grepl('historical-',view$design)) {
      stopifnot(nrow(data)==6L*unit$N)
      if(grepl('-common$',view$design))stopifnot(sum(exposure==18L)==unit$N/5L,
        sum(exposure==3L)==4L*unit$N/5L) else stopifnot(all(exposure==6L))
    } else stopifnot(all(exposure==if(view$design=='full-L1')9L else 6L))
  }
  if(unit$Type=='rubric') {
    a<-x$views[[1]]$data;b<-x$views[[2]]$data
    stopifnot(identical(b$Score,a$Score[match(b$RowId,a$RowId)]))
  }
  invisible(TRUE)
}

d_preflight <- function(allocation) {
  pkgload::load_all('.',quiet=TRUE,compile=FALSE,helpers=FALSE)
  contracts<-list();errors<-list()
  for(i in seq_len(nrow(allocation))) {
    s<-allocation[i,];t<-d_truth(s$Truth,s$SD);contract<-d_contract(t)
    contracts[[s$ConditionId]]<-contract
    error<-0
    for(mu in c(0,.7)) {
      shifted<-t;shifted$mu<-mu;c<-d_contract(shifted)
      grid<-expand.grid(z=c$z_grid,first=seq_along(t$levels[[1]]),second=seq_along(t$levels[[2]]))
      theta<-mu+t$sd*grid$z
      reference<-d_probability(theta,grid$first,grid$second,shifted)
      fixed<-d_probability(grid$z,grid$first,grid$second,c$two_family_fixed_normal)
      step<-t(apply(shifted$steps,1,function(x)c(0,cumsum(x))))
      native<-mfrmr:::category_prob_gpcm(theta-t$locations[[1]][grid$first]-t$locations[[2]][grid$second],
        step,grid$second,t$slopes[[1]][grid$first]*t$slopes[[2]][grid$second],seq_len(nrow(grid)))
      error<-max(error,abs(reference-fixed),abs(reference-native))
      r<-c$relative_population;eta<-r$mu+r$sd*grid$z-r$locations[[1]][grid$first]-r$locations[[2]][grid$second]
      step<-t(apply(r$steps,1,function(x)c(0,cumsum(x))))
      for(arm in names(c$correctly_specified)[1:3]) if(c$correctly_specified[[arm]]) {
        p<-if(arm=='PCM')mfrmr:::category_prob_pcm(eta,step,grid$second) else {
          owner<-if(arm=='GPCM_first')1L else 2L
          index<-if(owner==1L)grid$first else grid$second
          mfrmr:::category_prob_gpcm(eta,step,grid$second,r$slopes[[owner]],index)
        }
        error<-max(error,abs(reference-p))
      }
    }
    stopifnot(error<1e-12)
    errors[[s$ConditionId]]<-data.frame(ConditionId=s$ConditionId,ProbabilityError=error,
      TwoFamilyParameters=contract$two_family_parameters,
      ScoreRankCountPossible=s$N-1L>=contract$two_family_parameters)
  }
  list(contracts=contracts,checks=do.call(rbind,errors),fit_calls=0L)
}

d_candidate <- function(view,context) {
  if(!view$reused)return(list(path='',hash='',stages=0L))
  base<-if(grepl('core-n',basename(view$source),fixed=TRUE))d_core else d_matched
  path<-file.path(base,basename(view$source))
  if(!file.exists(path))return(list(path='',hash='',stages=0L))
  saved<-readRDS(path)
  stopifnot(saved$manifest_md5==unname(tools::md5sum(file.path(base,'manifest.rds'))))
  if(base==d_matched)d_hash(path,context$summary$result_hashes) else {
    h<-saved$provenance$source
    stopifnot(identical(tools::md5sum(names(h)),h),
      identical(saved$stages,readRDS(names(h)[1L])$stages))
  }
  list(path=path,hash=unname(tools::md5sum(path)),stages=length(saved$stages))
}

d_prepare <- function(out) {
  context<-d_context();allocation<-read.csv(ab_allocation,stringsAsFactors=FALSE)
  allocation<-allocation[allocation$Block=='D',]
  if(!dir.exists(out)) {
    registry<-d_registry(context);preflight<-d_preflight(allocation)
    # Range/representation checks precede the full input freeze.
    for(i in which(registry$units$Replicate==1L)) {
      x<-d_generate(registry$units[i,],registry$streams[[i]],context)
      d_check(x,registry$units[i,],registry$streams[[i]])
    }
    dir.create(file.path(out,'bundles'),recursive=TRUE);dir.create(file.path(out,'source'))
    sources<-c(d_script,ab_allocation,ab_protocol,d_sparse,d_core_generator,
      file.path(d_ab,'source/mfrm-wide-map-ab-inputs-20261001.R'),
      file.path(d_matched,c('manifest.rds','summary.rds')),file.path(d_core,'manifest.rds'),
      file.path(d_bridge,'manifest.rds'),file.path(context$matched$original,'manifest.rds'),
      list.files('R',full.names=TRUE),list.files('src',pattern='\\.(cpp|h|so)$',full.names=TRUE))
    for(f in sources) {
      # Source references may be absolute; only the original manifest is so here.
      dest<-file.path(out,'source',sub(paste0('^',normalizePath('.'),'/'),'',f))
      dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE);stopifnot(file.copy(f,dest))
    }
    registry$source_md5<-tools::md5sum(sources);registry$session<-capture.output(sessionInfo())
    ab_atomic_save(registry,file.path(out,'rng-registry.rds'))
    ab_atomic_save(preflight,file.path(out,'target-contracts.rds'))
    write.csv(preflight$checks,file.path(out,'scale-checks.csv'),row.names=FALSE)
  } else registry<-readRDS(file.path(out,'rng-registry.rds'))
  frozen<-file.path(out,'source',sub(paste0('^',normalizePath('.'),'/'),'',names(registry$source_md5)))
  executable<-registry$source_md5[names(registry$source_md5)!=ab_protocol]
  stopifnot(identical(tools::md5sum(names(executable)),executable),
    identical(unname(tools::md5sum(frozen)),unname(registry$source_md5)))
  if(file.exists(file.path(out,'verified-inputs.rds'))) {
    v<-readRDS(file.path(out,'verified-inputs.rds'))
    for(h in list(v$registry_md5,v$inputs_md5))stopifnot(identical(tools::md5sum(names(h)),h))
    rows<-read.csv(file.path(out,'inputs.csv'));f<-unique(rows[c('Bundle','BundleMD5')])
    metadata<-unique(rows[c('MetadataBundle','MetadataMD5')]);names(metadata)<-names(f)
    candidates<-unique(rows[nzchar(rows$CandidateFit),c('CandidateFit','CandidateMD5')]);names(candidates)<-names(f)
    f<-unique(rbind(f,metadata,candidates))
    stopifnot(identical(unname(tools::md5sum(f$Bundle)),f$BundleMD5))
    cat('Completed D inputs verified without regeneration.\n');return(invisible(v))
  }
  rows<-list();k<-0L
  for(i in seq_len(nrow(registry$units))) {
    unit<-registry$units[i,];path<-file.path(out,unit$Bundle)
    if(!file.exists(path)) {
      x<-d_generate(unit,registry$streams[[i]],context);d_check(x,unit,registry$streams[[i]])
      ab_atomic_save(x,path)
    }
    x<-readRDS(path);d_check(x,unit,registry$streams[[i]])
    for(id in names(x$views)) {
      view<-x$views[[id]];data<-d_view_data(view);candidate<-d_candidate(view,context)
      bundle<-if(view$reused)view$source else path
      total<-tapply(data$Score,data$Person,sum);exposure<-table(data$Person)
      k<-k+1L
      rows[[k]]<-data.frame(ConditionId=id,Replicate=unit$Replicate,CohortId=unit$CohortId,
        UnitId=unit$UnitId,Bundle=bundle,BundleMD5=unname(tools::md5sum(bundle)),
        Selector=if(view$reused)'case$data' else 'views[[View]]$data',View=id,
        MetadataBundle=path,MetadataMD5=unname(tools::md5sum(path)),
        Origin=if(view$reused)'retained_historical' else 'new_response_view',
        N=unit$N,SD=view$sd,Truth=view$family,Design=view$design,ObservedRows=nrow(data),
        ExtremePersons=sum(total==0|total==(view$truth$K-1L)*as.numeric(exposure)),
        CandidateFit=candidate$path,CandidateMD5=candidate$hash,CandidateStages=candidate$stages,
        FitReuseStatus=if(nzchar(candidate$path))'integrity_checked_workflow_bridge_pending' else 'none')
    }
    if(i%%250L==0L)cat('Prepared',i,'of 1450 D parent/extension bundles\n')
  }
  ab<-read.csv(file.path(d_ab,'inputs.csv'),stringsAsFactors=FALSE)
  aliases<-allocation[tolower(allocation$InputAlias)=='true',]
  for(i in seq_len(nrow(aliases)))for(rep in 1:50) {
    s<-aliases[i,];a<-ab[ab$ConditionId==s$InputId&ab$Replicate==rep,];stopifnot(nrow(a)==1L)
    bundle<-file.path(d_ab,a$Bundle);stopifnot(unname(tools::md5sum(bundle))==a$BundleMD5)
    k<-k+1L;rows[[k]]<-data.frame(ConditionId=s$ConditionId,Replicate=rep,CohortId=a$ParentId,
      UnitId=a$ParentId,Bundle=bundle,BundleMD5=a$BundleMD5,Selector='views[[View]]',View=a$View,
      MetadataBundle=file.path(out,'target-contracts.rds'),MetadataMD5=unname(tools::md5sum(file.path(out,'target-contracts.rds'))),
      Origin='AB_alias',N=s$N,SD=s$SD,Truth=s$Truth,Design=s$Design,ObservedRows=a$ObservedRows,
      ExtremePersons=a$ExtremePersons,CandidateFit='',CandidateMD5='',CandidateStages=0L,FitReuseStatus='none')
  }
  rows<-do.call(rbind,rows)
  stopifnot(nrow(rows)==8200L,sum(rows$Origin=='new_response_view')==4800L,
    sum(rows$Origin=='retained_historical')==600L,sum(rows$Origin=='AB_alias')==2800L,
    sum(nzchar(rows$CandidateFit))==208L,setequal(rows$ConditionId,allocation$ConditionId),
    all(table(rows$ConditionId)==50L),!anyDuplicated(rows[c('ConditionId','Replicate')]),
    sum(rows$ObservedRows[rows$Origin=='new_response_view'])==5460000L)
  ix<-c(1L,601L,1450L)
  generate<-function(i)d_generate(registry$units[i,],registry$streams[[i]],context)
  serial<-lapply(rev(ix),generate)
  forked<-parallel::mclapply(ix,generate,mc.cores=2L,mc.set.seed=FALSE)
  for(j in seq_along(ix)) {
    saved<-readRDS(file.path(out,registry$units$Bundle[ix[j]]))
    stopifnot(identical(saved,serial[[length(ix)+1L-j]]),identical(saved,forked[[j]]))
  }
  write.csv(rows,file.path(out,'inputs.csv'),row.names=FALSE)
  preflight<-readRDS(file.path(out,'target-contracts.rds'))
  ab_atomic_save(list(new_records=4800L,retained_records=600L,AB_aliases=2800L,
    condition_templates=164L,independent_new_historical_cohorts=200L,
    independent_replicates_per_condition=50L,new_response_rows=5460000L,
    retained_fit_candidates=208L,fit_calls=0L,maximum_probability_error=max(preflight$checks$ProbabilityError),
    reordered_and_two_worker_replay_identical=TRUE,source_mismatch_bridge=context$bridge$generator_check,
    registry_md5=tools::md5sum(file.path(out,'rng-registry.rds')),
    inputs_md5=tools::md5sum(file.path(out,'inputs.csv')),completed=Sys.time(),
    session=capture.output(sessionInfo())),file.path(out,'verified-inputs.rds'))
  cat('D complete: 4800 new views, 600 retained inputs and 2800 A/B aliases; no fits.\n')
}

if(sys.nframe()==0L) {
  args<-commandArgs(trailingOnly=TRUE);stopifnot(length(args)==1L);d_prepare(args[1L])
}
