# Deterministic finite-B design review; no model fitting or random generation.
# Run once, or use `verify` to check the saved evidence without repeating it.
script <- 'inst/validation/mfrm-lr-rsm-finite-mc-20261010.R'
out <- 'validation-results/mfrm-lr-rsm-finite-mc-20261010'
prior <- 'validation-results/mfrm-lr-rsm-null-bootstrap-20261010'
repair <- 'validation-results/mfrm-lr-rsm-natural-boundary-20261010'
verify <- function(h) stopifnot(length(h)>0L, !anyNA(h),
  identical(tools::md5sum(names(h)), h))
path <- file.path(out, 'review.rds')
if (identical(commandArgs(TRUE), 'verify')) {
  a <- readRDS(path)
  stopifnot(a$passed)
  verify(a$inputs); verify(a$source); verify(a$outputs)
  cat('PASS: retained evidence, source, outputs and RNG hashes unchanged; no arithmetic rerun.\n')
  quit(save='no')
}
stopifnot(!length(commandArgs(TRUE)), !file.exists(path))
audits <- file.path(c(prior, repair), 'verification.rds')
stopifnot(identical(unname(tools::md5sum(audits)),
  c('118277ee88a63f79612385c49d4e1481', '4227d6ddec7aa72979ab8837caa4cdab')))
for (p in audits) {
  a <- readRDS(p); stopifnot(a$passed); verify(a$retained)
  verify(if (is.null(a$source)) a$script else a$source)
}
inputs <- tools::md5sum(unique(c(audits,
  unlist(lapply(audits, function(p) names(readRDS(p)$retained))),
  file.path(prior, 'phase-accounting.csv'),
  'validation-results/mfrm-wide-map-r50-20261001/rng-head.rds')))
source_hash <- tools::md5sum(script)
started <- proc.time()[['elapsed']]

# Denominator is the planned B+1, including unresolved and uncomputed draws.
decision <- function(E, L, B, denominator=20L) {
  r <- (B+1L) %/% denominator
  ifelse(E >= r, 'retain', ifelse(L >= B-r+1L, 'reject', 'unresolved'))
}
curtail <- function(x, denominator=20L) {
  x <- unname(x)
  B <- length(x)
  stopifnot(B>0L, all(x %in% c('E','L','U')))
  E <- c(0L, cumsum(x=='E')); L <- c(0L, cumsum(x=='L'))
  d <- decision(E,L,B,denominator)
  k <- which(d!='unresolved')[1L]
  if (is.na(k)) k <- B+1L
  c(Count=k-1L, Decision=d[k], Lower=(1+E[k])/(B+1), Upper=(1+B-L[k])/(B+1))
}
# Independent terminal reference: enumerate every possible binary completion.
terminal <- function(x, denominator) {
  reject <- denominator*(1+sum(x=='E')+seq.int(0L,sum(x=='U'))) <= length(x)+1L
  if (all(reject)) 'reject' else if (!any(reject)) 'retain' else 'unresolved'
}
expected <- function(B, e, l, denominator=20L) {
  stopifnot(e>=0,l>=0,e+l<=1)
  r <- (B+1L) %/% denominator; t <- B-r+1L; n <- 0:(B-1L)
  # The two absorbing events cannot both occur before or at B: r+t=B+1.
  cont <- pbinom(r-1L,n,e)-pbinom(t-1L,n,l,lower.tail=FALSE)
  reject <- pbinom(t-1L,B,l,lower.tail=FALSE)
  retain <- pbinom(r-1L,B,e,lower.tail=FALSE)
  c(MeanCount=sum(pmax(0,cont)), Reject=reject, Retain=retain,
    Unresolved=max(0,1-reject-retain))
}

patterns <- as.matrix(expand.grid(rep(list(c('E','L','U')),8L),
  KEEP.OUT.ATTRS=FALSE,stringsAsFactors=FALSE))
checks <- list()
for (den in c(2L,5L)) {
  stopped <- t(apply(patterns,1L,curtail,denominator=den))
  final <- apply(patterns,1L,terminal,denominator=den)
  stopifnot(identical(unname(stopped[,'Decision']),unname(final)))
  for (prob in list(c(E=.07,L=.83,U=.10),c(E=.4,L=.5,U=.1),c(E=.1,L=.9,U=0))) {
    weights <- apply(patterns,1L,function(x) prod(prob[x]))
    direct <- c(MeanCount=sum(weights*as.numeric(stopped[,'Count'])),
      Reject=sum(weights[final=='reject']),Retain=sum(weights[final=='retain']),
      Unresolved=sum(weights[final=='unresolved']))
    delta <- max(abs(direct-expected(8L,prob['E'],prob['L'],den)))
    stopifnot(abs(sum(weights)-1)<1e-12,delta<1e-12)
    checks[[length(checks)+1L]] <- c(Denominator=den,prob,MaxError=delta)
  }
}
# Alpha=.05 edge cases, including an unavailable comparison at the cutoff.
fixtures <- list(rep('E',20),rep('L',20),rep('U',20),c(rep('L',19),'U'),
  c(rep('U',19),'E'),c(rep('L',18),'E','U'),rep('L',19))
for (x in fixtures) stopifnot(curtail(x)['Decision']==terminal(x,20L))

# Frozen criterion: <=.01 disagreement outside [.025,.075], among full returns.
candidate_B <- seq.int(19L,3999L,20L)
r <- (candidate_B+1L) %/% 20L
allocation <- data.frame(B=candidate_B,RetainAtLow=pbinom(r-1L,candidate_B,.025,lower.tail=FALSE),
  RejectAtHigh=pbinom(r-1L,candidate_B,.075))
qualifies <- allocation$RetainAtLow<=.01 & allocation$RejectAtHigh<=.01
stopifnot(any(qualifies))
chosen <- which(qualifies)[1L]; B <- candidate_B[chosen]
allocation <- allocation[seq_len(chosen),]
q <- c(.01,.025,.04,.05,.06,.075,.10,.25,.50)
curves <- data.frame(B=B,Q=q,Reject=pbinom((B+1L)%/%20L-1L,B,q))
curves$MeanCount <- vapply(q,function(p) expected(B,p,1-p)['MeanCount'],0.)
stopifnot(max(abs(curves$Reject-vapply(q,function(p)
  sum(dbinom(0:((B+1L)%/%20L-1L),B,p)),0.)))<1e-12)
scenarios <- expand.grid(KnownExceed=c(.025,.05,.10,.50),Unknown=c(0,.02,.10))
scenarios$KnownLess <- 1-scenarios$KnownExceed-scenarios$Unknown
scenarios <- cbind(scenarios,t(mapply(function(e,l) expected(B,e,l),
  scenarios$KnownExceed,scenarios$KnownLess)))

new <- readRDS(file.path(repair,'summary.rds'))
accounting <- read.csv(file.path(prior,'phase-accounting.csv'))
accounting$Case <- as.integer(sub('case-([0-9]+)-.*','\\1',accounting$File))
accounting$Draw <- as.integer(sub('.*-draw-([0-9]+)-.*','\\1',accounting$File))
accounting$Stage <- sub('.*-([a-z]+)[.]rds$','\\1',accounting$File)
for (i in seq_len(nrow(accounting))) {
  x <- readRDS(file.path(prior,accounting$File[i]))
  stopifnot(abs(x$elapsed-accounting$Seconds[i])<1e-10,identical(x$error,accounting$Error[i]))
}
replay <- do.call(rbind,lapply(1:4,function(k) {
  rows <- subset(new$trials,Case==k); rows <- rows[order(rows$Draw),]
  obs <- subset(new$summary,Case==k)$LR
  x <- ifelse(rows$Status!='computed' | rows$NumericallyAmbiguous,'U',
    ifelse(rows$LR>=obs,'E','L'))
  z <- curtail(x); stopifnot(z['Decision']==terminal(x,20L))
  n <- as.integer(z['Count'])
  phases <- subset(accounting,Case==k & Draw>0)
  extras <- list.files(repair,paste0('^case-0',k,'.*-(natural-(warm|neutral)|zero-reference)[.]rds$'),
    full.names=TRUE)
  extra <- if(length(extras)) sum(vapply(extras,function(p) readRDS(p)$elapsed,0.)) else 0
  data.frame(Case=k,StoppedAt=n,Decision=z['Decision'],
    FullRankLower=subset(new$summary,Case==k)$PValueLower,
    FullRankUpper=subset(new$summary,Case==k)$PValueUpper,
    PrefixLower=as.numeric(z['Lower']),PrefixUpper=as.numeric(z['Upper']),
    OriginalPhaseSeconds=sum(phases$Seconds),
    OriginalPrefixSeconds=sum(phases$Seconds[phases$Draw<=n]),
    BoundaryRepairSeconds=extra,MeanOriginalDrawSeconds=sum(phases$Seconds)/20,
    row.names=NULL)
}))
phase_cost <- aggregate(Seconds~Case+Stage,subset(accounting,Draw>0),sum)
n <- 0:(B-1L); r <- (B+1L)%/%20L; t <- B-r+1L
uniform_mean <- sum(1-pmax(n-r+1L,0)/(n+1)-pmax(n-t+1L,0)/(n+1))
cost <- data.frame(Case=replay$Case,OriginalDrawSeconds=replay$MeanOriginalDrawSeconds,
  FullCapHours=B*replay$MeanOriginalDrawSeconds/3600,
  UniformBenchmarkMeanCount=uniform_mean,
  UniformBenchmarkHours=uniform_mean*replay$MeanOriginalDrawSeconds/3600,
  Illustrative800OuterHours=800*uniform_mean*replay$MeanOriginalDrawSeconds/3600)
# Uniform q is a fully specified continuous-null benchmark, not a bootstrap forecast.
verify(inputs); verify(source_hash)
stopifnot(!exists('.Random.seed',envir=.GlobalEnv,inherits=FALSE))
dir.create(out,recursive=TRUE,showWarnings=FALSE)
tables <- list(allocation=allocation,curves=curves,scenarios=scenarios,replay=replay,
  phase_cost=phase_cost,cost=cost)
for (name in names(tables)) write.csv(tables[[name]],file.path(out,paste0(name,'.csv')),row.names=FALSE)
evidence <- list(passed=TRUE,B=B,criterion=list(alpha=.05,low=.025,high=.075,risk=.01),
  enumeration=do.call(rbind,checks),patterns_per_level=nrow(patterns),fixtures=length(fixtures),
  tables=tables,inputs=inputs,source=source_hash,
  outputs=tools::md5sum(file.path(out,paste0(names(tables),'.csv'))),
  session=sessionInfo(),elapsed=proc.time()[['elapsed']]-started,
  new_fits=0L,new_sampling_units=0L)
saveRDS(evidence,path)
print(tail(allocation,2L),row.names=FALSE)
print(curves,row.names=FALSE); print(replay,row.names=FALSE); print(cost,row.names=FALSE)
cat('PASS: finite-B curtailment and exact probability/cost review; no refit or sampling.\n')
