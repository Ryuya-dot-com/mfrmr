# J1 engineering validation: no new sampling-coverage study or public estimator.
source("inst/validation/jml-design-adjustment-20260927.R")
out <- "validation-results/jml-general-inputs-20260928"
stopifnot(!dir.exists(out)); dir.create(out,recursive=TRUE)
hashes <- tools::md5sum(c("R/core-jml-adjustment.R","inst/validation/jml-general-inputs-20260928.R"))
saveRDS(list(source_hash=hashes,session=capture.output(sessionInfo())),file.path(out,"manifest.rds"))
long_counts <- function(counts,cells) do.call(rbind,lapply(seq_len(nrow(counts[[1]])),function(i)
  do.call(rbind,lapply(seq_along(counts),function(j) {
    score <- rep(seq_len(ncol(counts[[j]]))-1L,counts[[j]][i,])
    if(!length(score)) return(NULL)
    data.frame(Person=sprintf("p%04d",i),cells[rep(j,length(score)),,drop=FALSE],Score=score)
  }))))
reference <- list()
for(owner in c("Rater","Criterion")) {
  old <- make_jml_roster_problem(owner,c(2,1,0,2))
  d <- long_counts(old$counts,expand.grid(Rater=1:2,Criterion=1:2))
  p <- mfrm_jml_adjustment_problem(d,"Person",c("Rater","Criterion"),"Score",owner,2L)
  for(b in list(c(.3,-.4,-.6,-.9,.25),c(-.3,.4,-.3,-1.1,-.25))) {
    expected <- lapply(c(0L,1L,2L,4L),function(k) old$scores(b,k)$value)
    observed <- lapply(c(0L,1L,2L,4L),function(k) p$evaluate(b,k)$value)
    errors <- vapply(seq_along(expected),function(i)max(abs(expected[[i]]-observed[[i]])),numeric(1))
    stopifnot(max(errors)<1e-8)
    reference[[length(reference)+1L]] <- list(data=d,owner=owner,beta=b,orders=c(0L,1L,2L,4L),
      scores=expected,q=old$evaluate(b)$q,errors=errors)
  }
}
saveRDS(reference,file.path(out,"reference.rds"))
saveRDS(reference,"tests/testthat/fixtures/jml-adjustment-reference.rds",compress="xz")
cat("Frozen reference maximum score discrepancy:",max(vapply(reference,function(x)max(x$errors),numeric(1))),"\n")

# A different structure: 3 judges, 2 criteria, 4 categories, two fixed sparse
# rosters with six ratings each. Independent conditional generation below.
N <- 400L; set.seed(9283101L)
cells <- expand.grid(Rater=1:3,Criterion=1:2)
truth <- c(.2,-.1,.3,-.6,.2,-.8,.1,.18)
locations_r <- c(truth[1:2],-sum(truth[1:2])); locations_c <- c(truth[3],-truth[3])
step <- rbind(c(truth[4:5],-sum(truth[4:5])),c(truth[6:7],-sum(truth[6:7])))
slope <- exp(c(truth[8],-truth[8])); theta <- rnorm(N)
counts <- lapply(1:6,function(j)matrix(0,N,4L))
for(i in seq_len(N)) for(j in if(i<=200L)c(1,2,6) else c(4,5,3)) {
  g <- cells$Criterion[j]
  z <- slope[g]*((theta[i]-locations_r[cells$Rater[j]]-locations_c[g])*(0:3)-c(0,cumsum(step[g,])))
  prob <- exp(z-max(z)); prob <- prob/sum(prob)
  counts[[j]][i,] <- as.vector(rmultinom(1,2,prob))
}
d <- long_counts(counts,cells)
names(d)[match(c("Person","Rater","Criterion","Score"),names(d))] <- c("Candidate","Judge label","観点 名","Rating")
p <- mfrm_jml_adjustment_problem(d,"Candidate",c("Judge label","観点 名"),"Rating","観点 名",3L)
stopifnot(nrow(p$parameters)==8L,identical(unname(p$total_states),c(91L,91L)))
saveRDS(list(data=d,seed=9283101L,truth=truth),file.path(out,"sample.rds"))
starts <- list(neutral=c(0,0,0,-.5,0,-.5,0,0),opposing=c(-.2,.1,-.2,-.3,-.1,-.7,.1,-.1))
results <- list()
for(k in c(2L,4L)) {
  fn <- function(b)p$mean_score(b,k)
  attempts <- lapply(starts,function(start) {
    trials <- list()
    for(algorithm in c("broyden","newton","short_newton")) {
      fit <- tryCatch({
        z <- nleqslv::nleqslv(start,fn,
          method=if(algorithm=="broyden") "Broyden" else "Newton",
          global=if(algorithm=="broyden") "cline" else "dbldog",
          control=list(ftol=1e-10,xtol=1e-11,maxit=150,stepmax=if(algorithm=="short_newton") .25 else 1))
        covariance <- mfrm_jml_adjustment_covariance(p,z$x,k)
        list(beta=z$x,solver=z,covariance=covariance,residual=max(abs(fn(z$x))),accepted=TRUE)
      },error=function(e)list(accepted=FALSE,error=conditionMessage(e)))
      trials[[algorithm]] <- fit
      if(isTRUE(fit$accepted)) break
    }
    list(fit=fit,trials=trials)
  })
  accepted <- all(vapply(attempts,function(x)isTRUE(x$fit$accepted),logical(1)))
  spread <- if(accepted)max(abs(attempts[[1]]$fit$beta-attempts[[2]]$fit$beta)) else NA_real_
  results[[as.character(k)]] <- list(order=k,attempts=attempts,accepted=accepted && spread<1e-6,spread=spread)
  saveRDS(results[[as.character(k)]],file.path(out,paste0("order-",k,".rds")))
  cat("Order",k,"accepted",results[[as.character(k)]]$accepted,"start spread",spread,"\n");flush.console()
}
stopifnot(identical(hashes,tools::md5sum(names(hashes))))
saveRDS(results,file.path(out,"results.rds"))
stopifnot(all(vapply(results,`[[`,logical(1),"accepted")))
saveRDS(list(data=d,person="Candidate",facets=c("Judge label","観点 名"),score="Rating",owner="観点 名",
  rating_max=3L,results=lapply(results,function(x)x$attempts[[1]]$fit[c("beta","covariance","residual")])),
  "tests/testthat/fixtures/jml-adjustment-general.rds",compress="xz")
