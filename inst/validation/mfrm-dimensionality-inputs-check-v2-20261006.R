# Resume the frozen allocation with the corrected top-level head branch.
# The original source/registry/head and numerical generator remain unchanged.
# Fits/diagnostic references are deliberately absent from this input stage.
args <- commandArgs(trailingOnly=TRUE)
stopifnot(length(args)==1L,args %in% c('prepare','replay'))
source_path <- 'inst/validation/mfrm-dimensionality-inputs-20261006.R'
script <- 'inst/validation/mfrm-dimensionality-inputs-check-v2-20261006.R'
map_path <- 'inst/validation/mfrm-dimensionality-tam-design-20261006.R'
source(source_path);source(map_path)
root <- 'validation-results/mfrm-wide-map-r50-20261001'
out <- file.path(root,'dimensionality-inputs')
head_path <- file.path(root,'rng-head.rds');registry_path <- file.path(out,'rng-registry.rds')
map_proof <- 'validation-results/mfrm-dimensionality-tam-design-20261006/fresh-replay.rds'
qualified_map <- readRDS(map_proof)
hashes_ok <- function(h)stopifnot(length(h)>0L,!anyNA(h),identical(tools::md5sum(names(h)),h))
stopifnot(qualified_map$ChecksPassed)
for(h in qualified_map$Binding[c('source','external')])hashes_ok(h)
hashes_ok(qualified_map$Result)
source_hashes <- tools::md5sum(c(source_path,script,map_path))
atomic_save <- function(x,path){
  tmp <- tempfile(basename(path),tmpdir=dirname(path));on.exit(unlink(tmp),add=TRUE)
  saveRDS(x,tmp,version=3);stopifnot(file.rename(tmp,path))
}
make_registry <- function(){
  head <- readRDS(head_path)
  stopifnot(head$epoch=='development-DLR-20261002-v1',head$next_unit_ordinal==6851L)
  hashes_ok(head$registry_md5);prior <- readRDS(head$registry)
  selected <- do.call(rbind,lapply(c(20L,60L,240L,480L),function(N)
    do.call(rbind,lapply(c('S-RSM','S-PCM','S-GPCM'),function(family){
      z <- prior$units[prior$units$N==N & prior$units$SD==1 & prior$units$Truth==family,]
      z <- z[order(z$Replicate),];stopifnot(identical(z$Replicate,1:50));z
    }))))
  stopifnot(nrow(selected)==600L,!anyDuplicated(selected$ParentId))
  linked <- function(type)data.frame(Type=type,N=selected$N,Family=selected$Truth,
    Replicate=selected$Replicate,UnitId=paste(type,selected$ParentId,sep=':'),
    ParentId=selected$ParentId,ABBundle=selected$ABBundle,
    DLRBundle=file.path(dirname(head$registry),selected$Bundle),stringsAsFactors=FALSE)
  dim <- do.call(rbind,lapply(c(20L,60L,240L,480L),function(N)
    do.call(rbind,lapply(c('RSM','PCM'),function(family)data.frame(Type='DIM',N=N,Family=family,
      Replicate=1:50,UnitId=sprintf('DIM:N%d:%s:rep%03d',N,family,1:50),
      ParentId='',ABBundle='',DLRBundle='')))))
  units <- rbind(linked('DLR-missing-X'),dim,linked('DLR-predictor-shape'));rownames(units) <- NULL
  units$Ordinal <- 6850L+seq_len(nrow(units))
  units$Bundle <- '';units$Bundle[units$Type=='DIM'] <- sprintf('bundles/parent-%04d.rds',1:400)
  stopifnot(nrow(units)==1600L,!anyDuplicated(units$UnitId),
    identical(units$Ordinal[units$Type=='DIM'],7451:7850))
  retained <- tools::md5sum(unique(c(selected$ABBundle,file.path(dirname(head$registry),selected$Bundle))))
  stopifnot(!anyNA(retained),all(unname(retained[selected$ABBundle])==selected$ABBundleMD5))
  stream <- prior$next_unused_unit_stream;streams <- setNames(vector('list',1600),units$UnitId)
  for(i in seq_len(nrow(units))){
    if(units$Type[i]=='DIM'){
      substream <- stream;seeds <- list()
      for(cohort in c('training','future')){
        seeds[[cohort]] <- list()
        for(role in c('ability','dependence','response','assignment','deletion')){
          seeds[[cohort]][[role]] <- substream;substream <- parallel::nextRNGSubStream(substream)
        }
      }
      seeds$reference_first_unused <- substream;streams[[i]] <- seeds
    } else streams[[i]] <- list(unit_stream=stream,components='Reserved parent only; component allocation and generation remain pending.')
    stream <- parallel::nextRNGStream(stream)
  }
  list(epoch='development-extensions-20261006-v1',phase='development',units=units,streams=streams,
    predecessor=head,predecessor_head_md5=tools::md5sum(head_path),retained_inputs=retained,
    first_unit_ordinal=6851L,next_unit_ordinal=8451L,
    first_unit_stream=prior$next_unused_unit_stream,next_unused_unit_stream=stream,
    RNG=c("L'Ecuyer-CMRG",'Inversion','Rejection'),source=source_hashes,
    map_proof=tools::md5sum(map_proof),R=R.version.string,
    scope='Reserve the three declared ranges in order. Only the400 DIM parents generate training/future responses here; missing-X and predictor/shape parent streams remain unused.')
}

check_bundle <- function(x,unit,seeds,external=FALSE){
  stopifnot(identical(x$unit,unit),identical(x$rng,seeds))
  answer <- list();profiles <- dim_profiles()
  stopifnot(identical(profiles$Profile,c('DIM1','DIM2-45','DIM2-90','DIM1-I','DIM2-45-I','DIM1-LD')),
    identical(profiles$Rho,c(1,.45,.90,1,.45,1)),identical(profiles$Eta,c(0,0,0,0,0,.30)),
    identical(profiles$Interaction,c(FALSE,FALSE,FALSE,TRUE,TRUE,FALSE)))
  for(cohort in c('training','future')){
    z <- x[[cohort]];p <- z$primitive;N <- if(cohort=='training')unit$N else 60L
    stopifnot(p$N==N,identical(sort(p$assignment),seq_len(N)),
      identical(names(z$profiles),profiles$Profile),nrow(z$roster)==N,
      identical(as.integer(table(factor(z$roster$PairId,levels=1:3))),
        rep(N%/%3L,3)+as.integer(1:3<=N%%3L)))
    masks <- list();paired_ids <- NULL
    for(j in seq_len(nrow(profiles))){
      case <- z$profiles[[j]];t <- case$truth;v <- case$views
      full <- v$full;paired <- v$paired;missing <- v[['paired-MCAR30']]
      stopifnot(nrow(full)==18L*N,nrow(paired)==12L*N,nrow(missing)==12L*N,
        identical(sort(unique(full$Person)),sort(p$persons)),!anyNA(full$Score),
        all(full$Score %in% 0:3),identical(full$RowId,seq_len(18L*N)),
        all(rowSums(table(full$Person,full$Criterion))==18L),
        all(table(paired$Person)==12L),all(table(paired$Person,paired$Criterion)==2L))
      subset <- full[paired$RowId,];rownames(subset) <- NULL
      pair_map <- rbind(c('1','2'),c('2','3'),c('3','1'))
      pair_id <- z$roster$PairId[match(full$Person,z$roster$Person)]
      assigned <- full$Rater==pair_map[pair_id,1] | full$Rater==pair_map[pair_id,2]
      stopifnot(identical(paired,subset),identical(paired[1:4],missing[1:4]),
        identical(paired$RowId,full$RowId[assigned]),
        identical(is.na(missing$Score),as.vector(p$deletion)[paired$RowId]<.30),
        identical(missing$Score[!is.na(missing$Score)],paired$Score[!is.na(missing$Score)]))
      if(is.null(paired_ids))paired_ids <- paired$RowId else stopifnot(identical(paired_ids,paired$RowId))
      masks[[j]] <- is.na(missing$Score)
      stopifnot(identical(case$theta[,1],p$ability[,1]),
        identical(case$theta[,2],t$rho*p$ability[,1]+sqrt(1-t$rho^2)*p$ability[,2]),
        identical(t$rater,c(-.4,0,.4)),identical(t$criterion,rep(c(-.6,0,.6),2)),
        t$rho==profiles$Rho[j],t$eta==profiles$Eta[j],
        identical(t$dimension,c(1L,1L,1L,2L,2L,2L)),
        identical(t$H,if(profiles$Interaction[j]).4*outer(c(-1,0,1),c(1,1,1,-1,-1,-1)) else matrix(0,3,6)),
        identical(t$steps,if(unit$Family=='RSM')matrix(c(-.8,0,.8),6,3,byrow=TRUE) else
          rbind(c(-1,0,1),c(-.8,.2,.6),c(-.6,-.2,.8),c(-1,0,1),c(-.8,.2,.6),c(-.6,-.2,.8))),
        max(abs(c(rowSums(t$H),colSums(t$H),rowSums(t$steps))))<1e-14)
      if(external){
        dimensions <- if(t$rho==1)1L else 2L
        map <- wide_dim_tam_design(unit$Family,dimensions,profiles$Interaction[j])
        par <- c(t$rater[1:2],t$criterion[1:5],
          if(profiles$Interaction[j])as.vector(-t$H[1:2,1:5]) else numeric(),
          if(unit$Family=='RSM')t$steps[1,1:2] else as.vector(t(t$steps[,1:2])))
        theta <- if(dimensions==1L)matrix(case$theta[,1],ncol=1) else case$theta
        probability <- get('tam_mml_calc_prob',asNamespace('TAM'))(1:18,map$A,matrix(0,18,4),
          map$B,par,theta,N,4L,recalc=TRUE,use_rcpp=TRUE,maxcat=rep(4L,18))$rprobs
        probability <- matrix(aperm(probability,c(3,1,2)),ncol=4)
        r <- as.integer(full$Rater);c <- as.integer(full$Criterion);person <- match(full$Person,p$persons)
        block <- ifelse(c<=3,1L,2L)
        normal <- if(t$eta==0)as.vector(p$response) else
          sqrt(.30)*p$dependence[cbind(person,block)]+sqrt(.70)*as.vector(p$response)
        cdf <- t(apply(probability,1,cumsum))[,1:3,drop=FALSE]
        expected <- as.integer(rowSums(pnorm(normal)>cdf))
        stopifnot(identical(full$Score,expected))
      }
      observed <- !is.na(missing$Score)
      nobs <- tabulate(match(missing$Person[observed],p$persons),nbins=N)
      # Every planned Person is retained, including a zero-observation Person.
      answer[[length(answer)+1L]] <- data.frame(ParentId=unit$UnitId,Replicate=unit$Replicate,
        N=unit$N,Family=unit$Family,Cohort=cohort,Profile=profiles$Profile[j],
        Persons=N,FullRatings=nrow(full),PairedRatings=nrow(paired),ObservedMCAR=sum(observed),
        ZeroObservationPersons=sum(nobs==0L))
    }
    stopifnot(all(vapply(masks,function(m)identical(m,masks[[1]]),TRUE)))
  }
  do.call(rbind,answer)
}

if(file.exists(registry_path)){
  registry <- readRDS(registry_path)
  # Registry sources refer to the immutable freeze, including the failed
  # original orchestration script. Resolve those against its saved archive.
  archived_sources <- file.path(out,'source',basename(names(registry$source)))
  stopifnot(identical(unname(tools::md5sum(archived_sources)),unname(registry$source)))
  stopifnot(identical(registry$source[c(source_path,map_path)],source_hashes[c(source_path,map_path)]))
} else {
  stopifnot(args=='prepare');registry <- make_registry()
}
hashes_ok(registry$retained_inputs);hashes_ok(registry$predecessor$registry_md5)
all_states <- unlist(lapply(registry$streams,function(s){
  if('unit_stream' %in% names(s))list(s$unit_stream) else
    c(s$training,s$future,list(s$reference_first_unused))
}),recursive=FALSE)
stopifnot(length(all_states)==5600L,
  !anyDuplicated(vapply(all_states,paste,collapse=',',FUN.VALUE='')))
dim_rows <- which(registry$units$Type=='DIM')
qualification <- dim_rows[registry$units$Replicate[dim_rows]==1L]
stopifnot(length(qualification)==8L)
bundles <- list();qualification_rows <- list()
for(i in qualification){
  unit <- registry$units[i,,drop=FALSE];seeds <- registry$streams[[i]]
  kind <- RNGkind();had <- exists('.Random.seed',.GlobalEnv,inherits=FALSE)
  if(had)seed_before <- .Random.seed
  x <- dim_generate(unit,seeds)
  stopifnot(identical(RNGkind(),kind),identical(exists('.Random.seed',.GlobalEnv,inherits=FALSE),had))
  if(had)stopifnot(identical(.Random.seed,seed_before))
  qualification_rows[[unit$UnitId]] <- check_bundle(x,unit,seeds,external=TRUE)
  bundles[[unit$UnitId]] <- x
}
cat('Generator qualification passed across all four N and both response families.\n');flush.console()
hashes_ok(source_hashes)
if(!file.exists(registry_path)){
  # Freeze sources and the exact predecessor before consuming study streams.
  stopifnot(identical(tools::md5sum(head_path),registry$predecessor_head_md5))
  dir.create(file.path(out,'bundles'),recursive=TRUE,showWarnings=FALSE)
  dir.create(file.path(out,'source'),showWarnings=FALSE)
  stopifnot(all(file.copy(c(source_path,script,map_path),file.path(out,'source'),overwrite=FALSE)))
  atomic_save(registry,registry_path)
}
new_head <- list(registry=registry_path,registry_md5=tools::md5sum(registry_path),
  preceding_registry_md5=registry$predecessor$registry_md5,last_reserved_unit_ordinal=8450L,
  next_unit_ordinal=8451L,epoch=registry$epoch,
  note='Missing-X6851:7450, DIM7451:7850, predictor/shape7851:8450 reserved in declared order; only DIM generates new inputs in this stage.')
head <- readRDS(head_path)
if(args=='prepare' && identical(head,registry$predecessor)){
  atomic_save(new_head,head_path)
} else stopifnot(identical(head,new_head))
if(args=='prepare'){
  archived <- file.path(out,'source',basename(script))
  if(!file.exists(archived))stopifnot(file.copy(script,archived))
  stopifnot(unname(tools::md5sum(archived))==unname(source_hashes[script]))
}
summaries <- list();input_paths <- character()
for(i in dim_rows){
  unit <- registry$units[i,,drop=FALSE];seeds <- registry$streams[[i]];path <- file.path(out,unit$Bundle)
  if(!file.exists(path)){
    stopifnot(args=='prepare')
    x <- bundles[[unit$UnitId]]
    if(is.null(x))x <- dim_generate(unit,seeds)
    atomic_save(x,path)
  }
  x <- readRDS(path)
  if(unit$UnitId %in% names(bundles))stopifnot(identical(x,bundles[[unit$UnitId]]))
  summaries[[unit$UnitId]] <- check_bundle(x,unit,seeds)
  input_paths <- c(input_paths,path)
  if(length(input_paths)%%50L==0L){cat('Verified',length(input_paths),'of400 DIM parents.\n');flush.console()}
}
summary <- do.call(rbind,summaries);rownames(summary) <- NULL
stopifnot(nrow(summary)==4800L,length(unique(summary$ParentId))==400L,
  all(table(summary$N,summary$Family,summary$Cohort,summary$Profile)==50L))
binding <- list(source=source_hashes,registry=tools::md5sum(registry_path),
  registry_sources=tools::md5sum(file.path(out,'source',basename(names(registry$source)))),
  map_proof=tools::md5sum(map_proof),inputs=tools::md5sum(input_paths),R=R.version.string)
hashes_ok(registry$retained_inputs);hashes_ok(source_hashes)
target <- file.path(out,'verified-inputs.rds')
if(args=='prepare'){
  stopifnot(!file.exists(target))
  atomic_save(list(ChecksPassed=TRUE,binding=binding,summary=summary,
    qualification=qualification_rows,ParentCohorts=400L,TrainingViews=7200L,FutureViews=7200L,
    NewFits=0L,ReferenceReplicates=0L,OtherReservedParentsGenerated=0L),target)
} else {
  before <- tools::md5sum(target);saved <- readRDS(target)
  stopifnot(saved$ChecksPassed,identical(saved$binding,binding),identical(saved$summary,summary),
    identical(saved$qualification,qualification_rows),identical(tools::md5sum(target),before))
  proof <- file.path(out,'fresh-replay.rds');stopifnot(!file.exists(proof))
  atomic_save(list(ChecksPassed=TRUE,Result=before,Binding=binding,
    RegeneratedQualificationParents=8L,NewFits=0L,Head=tools::md5sum(head_path)),proof)
}
cat('DIM inputs complete:400 parents,7200 training and7200 future views; no fitting or diagnostic references.\n')
