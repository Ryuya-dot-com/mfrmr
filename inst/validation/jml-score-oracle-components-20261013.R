# Saved-only exploratory components; oracle values do not define usable tests.
args <- commandArgs(TRUE)
stopifnot(length(args)==1L,args %in% c("review","replay"))
out <- "validation-results/jml-score-oracle-components-20261013"
script <- "inst/validation/jml-score-oracle-components-20261013.R"
bank <- "validation-results/jml-score-calibration-20261013"
population <- "validation-results/jml-score-population-centering-20261013"
for(x in parse(file.path(bank,"source.R")))
  if(is.call(x)&&identical(x[[1]],as.name("<-"))&&identical(x[[2]],as.name("read_function")))eval(x)
for(n in c("check","near","save_new","ci"))assign(n,read_function(file.path(bank,"source.R"),n))
patterns <- read_function("inst/validation/jml-score-plugin-overlap-20261013.R","patterns")
br <- readRDS(file.path(bank,"report.rds"));pr <- readRDS(file.path(population,"report.rds"))
bm <- readRDS(file.path(bank,"manifest.rds"));pm <- readRDS(file.path(population,"manifest.rds"))
check(br$results);check(pr$results);check(pm$inputs);check(pm$source)
old <- readRDS(file.path(bm$prior,"manifest.rds"))
inputs <- tools::md5sum(c(script,file.path(bank,c("source.R","manifest.rds","report.rds")),
  file.path(population,c("manifest.rds","report.rds")),file.path(bm$prior,"manifest.rds")))
key <- function(counts)apply(do.call(cbind,counts),1,paste,collapse=":")
studentize <- function(numerator,variance)if(is.finite(variance)&&variance>0)numerator/sqrt(variance) else NA_real_
stopifnot(is.na(studentize(0,0)),is.na(studentize(1,-1)),studentize(3,4)==1.5)
start <- proc.time()[["elapsed"]]
references <- lapply(1:4,function(i) {
  x <- readRDS(file.path(population,sprintf("cell-%d-truth.rds",i)))
  d <- old$designs[[x$job$Design]]
  x$keys <- lapply(1:2,function(g)key(patterns(x$job$L*d$exposure[[g]])))
  stopifnot(all(!vapply(x$keys,anyDuplicated,0L)))
  x
})
rows <- list();max_reconstruction_error <- 0
for(i in seq_len(nrow(br$rows))) {
  row <- br$rows[i,];p <- which(pm$jobs$Design==row$Design & pm$jobs$L==row$L)
  stopifnot(length(p)==1L)
  ref <- references[[p]];s <- ref$statistic
  input <- readRDS(file.path(bank,sprintf("input-%04d.rds",row$Parent)))$input
  x <- readRDS(file.path(bank,sprintf("fit-%04d-L%d.rds",row$Parent,row$L)))$calculation
  u <- numeric(row$N)
  groups <- split(seq_len(row$N),input$roster)
  for(g in seq_along(groups)) {
    ids <- groups[[g]]
    k <- key(lapply(input$counts[[as.character(row$L)]],function(c)c[ids,,drop=FALSE]))
    ix <- match(k,ref$keys[[g]]);stopifnot(!anyNA(ix))
    u[ids] <- drop(ref$native[[g]]$U[ix,,drop=FALSE]%*%s$w)
  }
  centered <- u;for(ids in groups)centered[ids] <- u[ids]-mean(u[ids])
  fixed_variance <- row$N*s$variance;oracle_numerator <- sum(u)
  fitted_numerator <- fitted_variance <- NA_real_
  if(isTRUE(x$available)) {
    fitted_numerator <- sum(drop(x$U%*%x$statistic$w))
    fitted_variance <- x$statistic$variance
    error <- abs(studentize(fitted_numerator,fitted_variance)-row$T)
    max_reconstruction_error <- max(max_reconstruction_error,error);stopifnot(error<1e-10)
  }
  numerator <- c(fitted_numerator,fitted_numerator,oracle_numerator,oracle_numerator)
  variance <- c(fitted_variance,fixed_variance,sum(centered^2),fixed_variance)
  value <- mapply(studentize,numerator,variance)
  rows[[i]] <- data.frame(row[c("Design","N","Replicate","Parent","L")],
    Component=c("unchanged","fixed_variance","fixed_equation","fixed_both"),
    Numerator=numerator,Variance=variance,T=value,OriginalT=row$T,row.names=NULL)
}
rows <- do.call(rbind,rows)
keys <- unique(rows[c("Design","N","L","Component")])
summary <- do.call(rbind,lapply(seq_len(nrow(keys)),function(i) {
  k <- keys[i,];x <- rows[rows$Design==k$Design & rows$N==k$N & rows$L==k$L & rows$Component==k$Component,]
  stopifnot(nrow(x)==99L,setequal(x$Replicate,1:99),!anyDuplicated(x$Replicate))
  ok <- is.finite(x$T);reject <- abs(x$T)>qnorm(.975);base <- abs(x$OriginalT)>qnorm(.975)
  lo <- hi <- reject;lo[!ok] <- FALSE;hi[!ok] <- TRUE
  cbind(k,data.frame(Owner=old$designs[[k$Design]]$owner,B=nrow(x),Returned=sum(ok),
    Reject=sum(reject[ok]),Unknown=sum(!ok),RateLower=mean(lo),RateUpper=mean(hi),
    MC_Lower=ci(sum(lo),nrow(x))[1],MC_Upper=ci(sum(hi),nrow(x))[2],
    Mean=mean(x$T[ok]),SD=sd(x$T[ok]),DifferenceLower=mean(lo-base),DifferenceUpper=mean(hi-base),
    PairedMCSE=if(all(ok))sd(as.numeric(reject)-base)/sqrt(nrow(x)) else NA_real_))
}))
stopifnot(!exists(".Random.seed",.GlobalEnv),!"mfrmr"%in%loadedNamespaces(),!"nleqslv"%in%loadedNamespaces())
check(inputs)
result <- list(inputs=inputs,bank_results=br$results,population_results=pr$results,
  rows=rows,summary=summary,max_reconstruction_error=max_reconstruction_error,
  interpretation="Exploratory paired oracle diagnostics; population constrained beta/projection and variance are unavailable in practice; not four implementable tests, independent validation, a causal decomposition or a selected correction")
fp <- file.path(out,"report.rds")
if(args=="review") {
  stopifnot(!file.exists(fp));dir.create(out,recursive=TRUE,showWarnings=FALSE);save_new(result,fp)
  write.csv(summary,file.path(out,"summary.csv"),row.names=FALSE)
  save_new(list(seconds=proc.time()[["elapsed"]]-start),file.path(out,"timing.rds"))
} else near(result,readRDS(fp))
print(summary[c("Owner","N","L","Component","Returned","Reject","Mean","SD","PairedMCSE")],row.names=FALSE)
cat("Saved-only",args,"passed; no fitting, new responses or RNG state.\n")
