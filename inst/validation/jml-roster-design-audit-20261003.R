# Design/count audit and saved covariance replay; no estimation or new responses.
args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args)==1L)
out <- args[1];stopifnot(!dir.exists(out));dir.create(out,recursive=TRUE)
inputs <- character();read_input <- function(path) {
  inputs <<- union(inputs,path);readRDS(path)
}
audit_design <- function(data,facets,K,id,scope) {
  data[c('Person',facets)] <- lapply(data[c('Person',facets)],factor)
  cells <- interaction(data[facets],drop=TRUE)
  exposure <- table(data$Person,cells)
  keys <- apply(exposure,1,paste,collapse=':');counts <- as.integer(table(keys))
  N <- nrow(exposure);G <- length(counts);levels <- vapply(data[facets],nlevels,0L)
  location <- model.matrix(reformulate(facets),data)[,-1,drop=FALSE]
  for(i in levels(data$Person)) {
    ix <- which(data$Person==i)
    location[ix,] <- sweep(location[ix,,drop=FALSE],2,colMeans(location[ix,,drop=FALSE]))
  }
  owner_count <- table(data$Person,data$Criterion)
  states <- apply(owner_count,1,function(x)prod((K-1)*x+1))
  p <- sum(levels-1)+levels['Criterion']*(K-2)+levels['Criterion']-1
  list(row=data.frame(Id=id,Scope=scope,N=N,Levels=paste(levels,collapse='/'),
    Categories=K,Ratings=paste(sort(unique(rowSums(exposure))),collapse='/'),
    Rosters=G,PersonsPerRoster=paste(sort(counts),collapse='/'),Singletons=sum(counts==1),
    GPCMCoordinates=unname(p),CenteredRankCeiling=N-G,
    AdditiveLocationRank=qr(location)$rank,RequiredLocationRank=sum(levels-1),
    OwnerTotalStates=max(states),CountsAdmitFullCovariance=all(counts>=2)&N-G>=p),
    roster=setNames(keys,rownames(exposure)),counts=counts)
}
rows <- list();pilot <- 'validation-results/mfrm-facet-structure-pilot-20261001'
for(path in sort(list.files(file.path(pilot,'inputs'),'[.]rds$',full.names=TRUE))) {
  x <- read_input(path);id <- paste0('pilot-',x$N,'-',x$name)
  rows[[id]] <- audit_design(x$data,x$facets,3,id,'retained diagnostic design')$row
}
ab <- 'validation-results/mfrm-wide-map-r50-20261001/ab-inputs'
registry <- read_input(file.path(ab,'rng-registry.rds'))
u <- registry$units
for(i in which(u$Replicate==1 & u$SD==1 & u$Truth=='S-PCM')) {
  x <- read_input(file.path(ab,u$Bundle[i]))
  for(view in names(x$views)) {
    id <- paste0('AB-N',u$N[i],'-',view)
    rows[[id]] <- audit_design(x$views[[view]],c('Rater','Criterion'),4,id,
      'retained R50 design; first input checks counts, not coverage')$row
  }
}
# Verify the actually running condition on all 50 immutable parent datasets.
for(i in which(u$N==30 & u$SD==1 & u$Truth=='S-PCM')) {
  x <- read_input(file.path(ab,u$Bundle[i]))
  d <- audit_design(x$views[['paired-L1']],c('Rater','Criterion'),4,'running','counts only')
  stopifnot(identical(sort(d$counts),c(10L,10L,10L)),d$row$GPCMCoordinates==12,
    d$row$OwnerTotalStates==343,d$row$CenteredRankCeiling==27)
}
# Prospective design-only controls: same 3x2x4 levels, K=3, eight ratings.
# No Score column and no response generation or condition replacement.
block <- data.frame(Rater=c(1,2,2,3,3,1,1,2),Criterion=rep(1:2,4),Task=rep(1:4,each=2))
common <- do.call(rbind,lapply(1:20,function(i)cbind(Person=sprintf('P%03d',i),block)))
rows[['proposed-common']] <- audit_design(common,c('Rater','Criterion','Task'),3,
  'proposed-N20-common-eight-cells','prospective design only')$row
rp <- list(c(1,2),c(2,3),c(3,1),c(1,2));tp <- list(c(1,2),c(2,3),c(3,4),c(4,1))
replicated <- do.call(rbind,lapply(1:20,function(i) {
  g <- (i-1)%/%5+1
  cbind(Person=sprintf('P%03d',i),expand.grid(Rater=rp[[g]],Criterion=1:2,Task=tp[[g]]))
}))
rows[['proposed-four']] <- audit_design(replicated,c('Rater','Criterion','Task'),3,
  'proposed-N20-four-replicated-rosters','prospective design only')$row
for(id in c('proposed-common','proposed-four')) {
  r <- rows[[id]];stopifnot(r$CountsAdmitFullCovariance,r$GPCMCoordinates==9,
    r$AdditiveLocationRank==r$RequiredLocationRank,r$OwnerTotalStates==81)
}
replays <- list()
for(N in c(20,30)) for(order in c(2,4)) {
  if(N==20) {
    fitpath <- file.path(pilot,'fits',paste0('20-base_two_facet-JML',order,'.rds'))
    fit <- read_input(fitpath)$fit
    x <- read_input(file.path(pilot,'inputs/20-base_two_facet.rds'))
    d <- audit_design(x$data,x$facets,3,'replay','retained')
  } else {
    job <- if(order==2)'job-03607' else 'job-03608'
    fitpath <- file.path('validation-results/mfrm-wide-map-pcm-r50-portable-20261003',job,'calibration/q0-fit.rds')
    fit <- read_input(fitpath)$payload$value
    x <- read_input(file.path(ab,u$Bundle[u$N==30 & u$SD==1 & u$Truth=='S-PCM' & u$Replicate==1]))
    d <- audit_design(x$views[['paired-L1']],c('Rater','Criterion'),4,'replay','retained')
  }
  a <- fit$jml_adjustment;z <- a$covariance$result
  stopifnot(a$covariance$available,z$sampling=='fixed_rosters',z$order==order)
  U <- z$scores; groups <- d$roster[a$persons];stopifnot(!anyNA(groups),nrow(U)==N)
  centered <- U;weights <- numeric(N)
  for(g in unique(groups)) {
    ix <- which(groups==g);ng <- length(ix);stopifnot(ng>=2)
    centered[ix,] <- sweep(U[ix,,drop=FALSE],2,colMeans(U[ix,,drop=FALSE]))
    weights[ix] <- ng/(ng-1)
  }
  inverse <- solve(z$jacobian);influence <- -centered%*%t(inverse)
  V <- crossprod(influence)/N^2
  adjusted <- crossprod(influence*sqrt(weights))/N^2
  stopifnot(max(abs(V-z$vcov))<1e-10)
  if(N==30)stopifnot(max(abs(adjusted-(10/9)*V))<1e-10)
  replays[[paste(N,order,sep='-')]] <- data.frame(N=N,Order=order,
    RootStatus=a$point$status,StoredCovariance=TRUE,CenteredScoreRank=qr(centered)$rank,
    Coordinates=ncol(U),ReplayDifference=max(abs(V-z$vcov)),
    MinVarianceRatio=min(diag(adjusted)/diag(V)),MaxVarianceRatio=max(diag(adjusted)/diag(V)),
    MinSERatio=min(sqrt(diag(adjusted)/diag(V))),MaxSERatio=max(sqrt(diag(adjusted)/diag(V))))
}
summary <- do.call(rbind,rows);replays <- do.call(rbind,replays)
stopifnot(summary$Singletons[summary$Id=='pilot-20-four_tasks']==4,
  summary$CenteredRankCeiling[summary$Id=='pilot-20-four_tasks']==8)
write.csv(summary,file.path(out,'designs.csv'),row.names=FALSE)
write.csv(replays,file.path(out,'covariance-replay.csv'),row.names=FALSE)
saveRDS(list(designs=summary,covariance_replay=replays,
  prospective=list(common=common,four_replicated=replicated),
  source=tools::md5sum('inst/validation/jml-roster-design-audit-20261003.R'),
  inputs=tools::md5sum(inputs),session=capture.output(sessionInfo()),
  interpretation='Count/rank feasibility, not statistical sufficiency. Bessel-weighted meat is a separate research sensitivity; frozen worker estimates/covariances unchanged.'),
  file.path(out,'audit.rds'))
print(summary,row.names=FALSE);print(replays,row.names=FALSE)
