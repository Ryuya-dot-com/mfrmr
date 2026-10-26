# Finite-sum overlap check before allocating null-specific bootstrap fits.
args <- commandArgs(TRUE)
stopifnot(length(args)==1L,args %in% c("run","replay"))
out <- "validation-results/jml-score-plugin-overlap-20261013"
script <- "inst/validation/jml-score-plugin-overlap-20261013.R"
prior <- "validation-results/jml-small-pilot-20261013"
bank <- "validation-results/jml-score-calibration-20261013"
nulls <- "validation-results/jml-constrained-score-20261013"
check <- function(h) stopifnot(length(h)>0L,!anyNA(h),identical(tools::md5sum(names(h)),h))
near <- function(a,b,tol=1e-10) stopifnot(isTRUE(all.equal(unname(a),unname(b),tolerance=tol)))
save_new <- function(x,path) { stopifnot(!file.exists(path)); saveRDS(x,path) }

log_sum <- function(x) { a <- max(x); a+log(sum(exp(x-a))) }
patterns <- function(exposure) {
  cells <- lapply(exposure,function(n) {
    z <- expand.grid(n0=0:n,n1=0:n); z <- z[rowSums(z)<=n,]
    as.matrix(cbind(z,n2=n-rowSums(z)))
  })
  index <- as.matrix(expand.grid(lapply(cells,function(x)seq_len(nrow(x)))))
  lapply(seq_along(cells),function(j)cells[[j]][index[,j],,drop=FALSE])
}
log_mass <- function(counts,d,beta,g) {
  n <- nrow(counts[[1]]); theta <- d$ability[[g]]
  lp <- matrix(0,n,length(theta)); multiplicity <- numeric(n)
  for(j in seq_along(counts)) {
    c <- counts[[j]]; own <- d$cells[[d$owner]][j]
    a <- exp(c(1,-1)[own]*beta[5]); step <- beta[2+own]
    eta <- theta-c(1,-1)[d$cells$Rater[j]]*beta[1]-c(1,-1)[d$cells$Criterion[j]]*beta[2]
    z <- cbind(0,a*(eta-step),2*a*eta)
    z <- z-apply(z,1,max); z <- z-log(rowSums(exp(z)))
    # Independent adjacent-category recurrence checks the centered-step map.
    odds <- cbind(exp(a*(eta-step)),exp(a*(eta+step)))
    q <- cbind(1,odds[,1],odds[,1]*odds[,2]); q <- q/rowSums(q)
    near(exp(z),q,1e-12)
    lp <- lp+c%*%t(z)
    multiplicity <- multiplicity+lgamma(rowSums(c)+1)-rowSums(lgamma(c+1))
  }
  apply(sweep(lp,2,log(c(.25,.5,.25)),"+"),1,log_sum)+multiplicity
}
input_logweight <- function(input,L,d,beta) {
  v <- numeric(length(input$roster))
  for(g in seq_along(d$proportions)) {
    ix <- which(input$roster==g)
    counts <- lapply(input$counts[[as.character(L)]],function(c)c[ix,,drop=FALSE])
    v[ix] <- log_mass(counts,d,beta,g)-log_mass(counts,d,d$truth,g)
  }
  sum(v)
}
if(args=="run") {
  stopifnot(!dir.exists(out))
  old <- readRDS(file.path(prior,"manifest.rds")); b <- readRDS(file.path(bank,"report.rds"))
  r <- readRDS(file.path(nulls,"report.rds")); check(old$source);check(b$results);check(r$results)
  dir.create(out,recursive=TRUE)
  m <- list(source=tools::md5sum(script),inputs=tools::md5sum(c(file.path(prior,"manifest.rds"),
    file.path(bank,c("manifest.rds","report.rds")),file.path(nulls,"report.rds"),names(b$results),names(r$results))),
    contract=list(scope="All 16 retained truth-null generators; select first replicate per design/N/L for any bounded direct follow-up",
      calculation="Exact per-roster finite sums under known three-point ability law; full-sample moments multiply across independent Persons",
      precision="Sufficient reuse screen: sqrt((E_Q W^2-1)/99)<=.025 for estimating any fixed-event probability difference",
      limitation="Failure of this conservative bound does not prove every weighted tail estimate unusable; ESS is diagnostic, not certification",
      rule="No density clipping, self-normalized p-value claim, new response, fit, or unseen nuisance search"))
  save_new(m,file.path(out,"manifest.rds"))
} else m <- readRDS(file.path(out,"manifest.rds"))
check(m$source);check(m$inputs)
old <- readRDS(file.path(prior,"manifest.rds")); ref <- readRDS(file.path(nulls,"report.rds"))$rows
b <- readRDS(file.path(bank,"report.rds")); bm <- readRDS(file.path(bank,"manifest.rds"))
rows <- cases <- list(); start <- proc.time()[["elapsed"]]
for(j in 1:16) {
  x <- readRDS(file.path(nulls,sprintf("case-%02d-structural_truth.rds",j)))
  d <- old$designs[[x$job$Design]]; beta <- x$calculation$beta
  N <- x$job$N; L <- x$job$L; second <- affinity <- numeric(length(d$proportions))
  support <- vector("list",length(second))
  for(g in seq_along(second)) {
    counts <- patterns(L*d$exposure[[g]])
    q <- log_mass(counts,d,d$truth,g); p <- log_mass(counts,d,beta,g)
    near(sum(exp(q)),1,1e-12); near(sum(exp(p)),1,1e-12)
    near(sum(exp(q)*exp(p-q)),1,1e-12)
    second[g] <- log_sum(2*p-q); affinity[g] <- log_sum((p+q)/2)
    support[[g]] <- list(logQ=q,logP=p)
  }
  log_m2 <- sum(N*d$proportions*second); log_affinity <- sum(N*d$proportions*affinity)
  index <- which(bm$parents$Design==x$job$Design & bm$parents$N==N)
  lw <- vapply(index,function(i) {
    input <- readRDS(file.path(bank,sprintf("input-%04d.rds",i)))$input
    input_logweight(input,L,d,beta)
  },0)
  values <- b$rows[b$rows$Design==x$job$Design & b$rows$N==N & b$rows$L==L,]
  stopifnot(identical(values$Parent,bm$parents$Parent[index]),length(lw)==99L)
  w <- exp(lw); gate <- sqrt(max(0,expm1(log_m2))/99)
  row <- data.frame(x$job,SecondMoment=exp(log_m2),RMSEBound=gate,
    ReuseBoundPass=gate<=.025,WeightMean=mean(w),RealizedESS=sum(w)^2/sum(w^2),
    MaxWeightShare=max(w)/sum(w),HellingerAffinity=exp(log_affinity),
    RawTailDifference=mean((w-1)*(abs(values$T)>qnorm(.975))))
  rows[[j]] <- row; cases[[j]] <- list(beta=beta,support=support,logweights=lw,statistics=values$T)
}
result <- list(manifest=tools::md5sum(file.path(out,"manifest.rds")),rows=do.call(rbind,rows),cases=cases,
  scope="Finite-sum and retained-bank diagnostics only; no calibrated p-values or statistical qualification")
stopifnot(!exists(".Random.seed",.GlobalEnv),!"mfrmr" %in% loadedNamespaces())
if(args=="run") {
  save_new(result,file.path(out,"report.rds")); write.csv(result$rows,file.path(out,"summary.csv"),row.names=FALSE)
  save_new(list(seconds=proc.time()[["elapsed"]]-start),file.path(out,"timing.rds"))
} else near(result,readRDS(file.path(out,"report.rds")))
print(result$rows,row.names=FALSE)
cat("Finite-sum",args,"complete; no generation or fitting.\n")
