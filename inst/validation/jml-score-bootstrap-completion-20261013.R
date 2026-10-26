# Fixed-B computational completion; this does not establish bootstrap validity.
args <- commandArgs(TRUE)
stopifnot(length(args)==1L,args %in% c("review","replay"))
script <- "inst/validation/jml-score-bootstrap-completion-20261013.R"
out <- "validation-results/jml-score-bootstrap-completion-20261013"
bank <- "validation-results/jml-score-calibration-20261013"
plugin <- "validation-results/jml-score-plugin-20261013"
for(x in parse(file.path(bank,"source.R")))
  if(is.call(x)&&identical(x[[1]],as.name("<-"))&&identical(x[[2]],as.name("read_function")))eval(x)
for(n in c("check","near","save_new"))assign(n,read_function(file.path(bank,"source.R"),n))

completion <- function(observed,values,B=99L,alpha=.05) {
  stopifnot(length(observed)==1L,is.numeric(observed),is.numeric(values),
    length(B)==1L,is.finite(B),B>=1,B==as.integer(B),length(values)<=B,
    length(alpha)==1L,is.finite(alpha),alpha>0,alpha<1)
  n <- length(values);known <- is.finite(values);failed <- sum(!known)
  if(!is.finite(observed))return(list(decision="unresolved",reason="observed statistic unavailable",
    attempted=n,failed=failed,unattempted=B-n,exceedances=NA_integer_,lower=0,upper=1))
  e <- sum(abs(values[known])>=abs(observed))
  lower <- (1+e)/(B+1);upper <- (1+e+failed+B-n)/(B+1)
  decision <- if(upper<=alpha)"reject" else if(lower>alpha)"nonreject" else if(n<B)"continue" else "unresolved"
  list(decision=decision,reason=if(decision=="unresolved")"failed inner statistics leave decision unresolved" else "fixed-B completion bound",
    attempted=n,failed=failed,unattempted=B-n,exceedances=e,lower=lower,upper=upper)
}
first_completion <- function(observed,values,B=99L,alpha=.05) {
  stopifnot(length(values)==B)
  for(n in 0:B) {
    state <- completion(observed,values[seq_len(n)],B,alpha)
    if(state$decision!="continue")return(state)
  }
  stop("unreachable completion state")
}

# Independent enumeration of every binary completion of small ternary prefixes.
controls <- function() {
  prefixes <- completions <- 0L
  for(n in 0:7) {
    grid <- if(n)as.matrix(expand.grid(rep(list(c(0,2,NA_real_)),n))) else matrix(numeric(),1,0)
    for(i in seq_len(nrow(grid))) {
      values <- grid[i,];s <- completion(1,values,7L,.25)
      known <- is.finite(values);e <- sum(values[known]>=1)
      missing <- sum(!known)+7L-n
      binary <- if(missing)as.matrix(expand.grid(rep(list(0:1),missing))) else matrix(0,1,0)
      p <- (1+e+rowSums(binary))/8
      near(c(s$lower,s$upper),range(p),0)
      expected <- if(all(p<=.25))"reject" else if(all(p>.25))"nonreject" else if(n<7)"continue" else "unresolved"
      stopifnot(identical(s$decision,expected))
      prefixes <- prefixes+1L;completions <- completions+length(p)
    }
  }
  # Inclusive ties, the .05 boundary, unavailable observation and failure bounds.
  stopifnot(first_completion(1,rep(1,99))$attempted==5L,
    first_completion(1,rep(-1,99))$decision=="nonreject",
    first_completion(1,rep(0,99))$attempted==95L,
    completion(1,c(rep(2,4),rep(0,95)))$decision=="reject",
    completion(1,c(rep(2,5),rep(0,94)))$decision=="nonreject",
    completion(1,c(rep(2,4),rep(0,94),NA_real_))$decision=="unresolved",
    completion(1,c(rep(0,95),rep(NA_real_,4)))$decision=="reject",
    completion(1,c(rep(0,94),rep(NA_real_,5)))$decision=="unresolved",
    first_completion(NA_real_,rep(0,99))$attempted==0L,
    first_completion(Inf,rep(0,99))$decision=="unresolved",
    first_completion(1,rep(NA_real_,99))$decision=="unresolved",
    completion(1,c(Inf,NaN))$failed==2L,
    first_completion(0,rep(0,99))$decision=="nonreject")
  list(prefixes=prefixes,binary_completions=completions,boundary_controls=13L)
}

timer <- proc.time()[["elapsed"]]
verification <- controls()
m <- readRDS(file.path(plugin,"manifest.rds"));r <- readRDS(file.path(plugin,"report.rds"))
check(m$source);check(m$inputs);check(r$manifest);check(r$results)
stopifnot(m$B==99L,length(m$sources)==8L)
inputs <- tools::md5sum(c(script,file.path(plugin,c("manifest.rds","report.rds","source.R")),
  file.path(bank,"source.R")))
rows <- traces <- list()
for(i in seq_along(m$sources)) {
  source <- m$sources[[i]];z <- r$rows[r$rows$Case==i,]
  z <- z[order(z$Replicate),];stopifnot(identical(z$Replicate,1:99),all(z$Available==is.finite(z$T)))
  generation <- vapply(which(m$jobs$Case==i),function(j)
    readRDS(file.path(plugin,sprintf("input-%04d.rds",j)))$seconds,0.0)
  stopifnot(length(generation)==99L)
  # These thresholds test computation/cost only, not additional observed datasets.
  thresholds <- c(observed=source$calculation$statistic$T,zero=0,
    normal_cutoff=qnorm(.975),tail_probe=qnorm(.9995),
    inclusive_tie=z$T[which(is.finite(z$T))[1]],beyond_saved=max(abs(z$T),na.rm=TRUE)+1)
  for(label in names(thresholds)) {
    obs <- thresholds[[label]];s <- first_completion(obs,z$T);full <- completion(obs,z$T)
    stopifnot(identical(s$decision,full$decision),full$lower>=s$lower,full$upper<=s$upper)
    tr <- do.call(rbind,lapply(0:99,function(n) {
      q <- completion(obs,z$T[seq_len(n)])
      data.frame(Case=i,Probe=label,Prefix=n,Decision=q$decision,Lower=q$lower,Upper=q$upper)
    }))
    stopifnot(all(diff(tr$Lower)>=0),all(diff(tr$Upper)<=0),
      all(tr$Decision[tr$Prefix>=s$attempted]==s$decision))
    traces[[length(traces)+1L]] <- tr
    rows[[length(rows)+1L]] <- data.frame(Case=i,source$job[c("Design","N","L")],Probe=label,
      Observed=obs,Decision=s$decision,Attempted=s$attempted,Failed=s$failed,
      Unattempted=s$unattempted,Lower=s$lower,Upper=s$upper,
      FullLower=full$lower,FullUpper=full$upper,
      PrefixSeconds=sum((z$Seconds+generation)[seq_len(s$attempted)]),
      FullSeconds=sum(z$Seconds+generation),row.names=NULL)
  }
}
rows <- do.call(rbind,rows);traces <- do.call(rbind,traces)
summary <- do.call(rbind,lapply(unique(rows$Probe),function(probe) {
  x <- rows[rows$Probe==probe,]
  data.frame(Probe=probe,Cases=nrow(x),Attempted=sum(x$Attempted),
    Skipped=sum(x$Unattempted),Failed=sum(x$Failed),Reject=sum(x$Decision=="reject"),
    Nonreject=sum(x$Decision=="nonreject"),Unresolved=sum(x$Decision=="unresolved"),
    PrefixSeconds=sum(x$PrefixSeconds),FullSeconds=sum(x$FullSeconds))
}))
stopifnot(!exists(".Random.seed",.GlobalEnv),!"mfrmr"%in%loadedNamespaces(),!"nleqslv"%in%loadedNamespaces())
check(inputs)
result <- list(inputs=inputs,results=r$results,verification=verification,rows=rows,
  traces=traces,summary=summary,
  contract=list(B=99L,alpha=.05,ties="inclusive absolute statistic",
    failures="nonfinite inner results unknown; no replacement; unavailable observed statistic unresolved",
    denominator="planned B+1 throughout; bounds are logical completions, not confidence intervals",
    stopping="first logically determined full-B decision; rejected when upper <= alpha; nonrejected when lower > alpha",
    generator="observed null-constrained nuisance; known roster ability law; every inner draw recomputes nuisance, profiles, correction, derivative and variance",
    scope="saved development data and deterministic cost probes; no new fits, responses, outer coverage trials, or finite-sample validity theorem",
    timing="sum of retained generation and calculation times for actually consumed prefixes; excludes driver/I/O and outer fit cost; not a new wall-time benchmark"))
fp <- file.path(out,"report.rds")
if(args=="review") {
  stopifnot(!dir.exists(out));dir.create(out,recursive=TRUE)
  stopifnot(file.copy(script,file.path(out,"source.R")))
  save_new(result,fp);write.csv(rows,file.path(out,"rows.csv"),row.names=FALSE)
  write.csv(summary,file.path(out,"summary.csv"),row.names=FALSE)
  save_new(list(seconds=proc.time()[["elapsed"]]-timer),file.path(out,"timing.rds"))
} else {
  stopifnot(identical(unname(tools::md5sum(script)),unname(tools::md5sum(file.path(out,"source.R")))))
  near(result,readRDS(fp),0)
}
print(summary,row.names=FALSE)
print(verification)
cat("Saved-only",args,"passed; no new fits, responses or RNG state.\n")
