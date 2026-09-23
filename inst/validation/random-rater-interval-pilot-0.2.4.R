# setup, then disjoint run ranges; freeze source before any new study outcomes.
.libPaths(c(normalizePath(".r-library"), .libPaths()))
pkgload::load_all(".", quiet = TRUE)
args <- commandArgs(TRUE); action <- args[1]
out <- "validation-results/random-rater-intervals-20260923/pilot"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
files <- c("R/api-random-rater.R", "R/api-random-rater-intervals.R", "R/core-optimizer.R",
  "R/mfrm_core.R", "R/core-data-prep.R", "inst/validation/random-rater-interval-pilot-0.2.4.R",
  "inst/validation/random-rater-interval-record-0.2.4.md")
protocol_file <- file.path(out, "protocol.rds")
if (action == "setup") {
 if (file.exists(protocol_file)) stop("Do not overwrite a frozen protocol.")
 roster <- do.call(rbind,lapply(1:2,function(c) data.frame(Condition=c,Raters=c(6L,24L)[c],
   Replicate=1:12,Seed=9241000L+100L*c+1:12)))
 roster$BootstrapSeed<-9248000L+seq_len(nrow(roster))
 saveRDS(list(roster=roster,B=99L,source=tools::md5sum(files),session=sessionInfo(),frozen=Sys.time()),protocol_file)
 for(f in files) { dest<-file.path(out,"executed-source",f);dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE);file.copy(f,dest) }
 quit(save="no")
}
protocol<-readRDS(protocol_file)
stopifnot(identical(protocol$source,tools::md5sum(files)))
for(i in seq.int(as.integer(args[2]),as.integer(args[3]))) {
 path<-file.path(out,sprintf("outer-%02d.rds",i)); if(file.exists(path)) next
 row<-protocol$roster[i,];set.seed(row$Seed)
 person<-rep(1:240,each=6);rater<-(person-1+rep(rep(0:1,each=3),240))%%row$Raters+1
 criterion<-rep(1:3,480);theta<-rnorm(240);severity<-rnorm(row$Raters,sd=.7)
 eta<-theta[person]-severity[rater]-c(-.3,0,.3)[criterion]
 w<-cbind(0,eta+.6,2*eta);w<-exp(w-apply(w,1,max));w<-w/rowSums(w)
 data<-data.frame(Person=person,Rater=rater,Criterion=criterion,
   Score=rowSums(runif(length(person))>t(apply(w,1,cumsum))))
 errors<-warnings<-character();fit<-intervals<-NULL
 elapsed<-system.time(withCallingHandlers({
  fit<-tryCatch(fit_mfrm_random_rater(person_sd = 1, data,"Person","Rater","Score","Criterion",0:2,
    quad_points=61,maxit=300),error=function(e){errors<<-c(errors,conditionMessage(e));NULL})
  if(!is.null(fit)) intervals<-tryCatch(mfrm_random_rater_intervals(fit,nsim=protocol$B,seed=row$BootstrapSeed),
    error=function(e){errors<<-c(errors,conditionMessage(e));NULL})
 },warning=function(w){warnings<<-c(warnings,conditionMessage(w));invokeRestart("muffleWarning")}))
 saveRDS(list(roster=row,truth=list(rater=setNames(severity,1:row$Raters),theta=theta),
   fit=fit,intervals=intervals,errors=errors,warnings=warnings,elapsed=elapsed),path)
 cat(i,"/24",if(is.null(intervals))"unavailable" else paste("ready",sum(intervals$trials$FitReady),
   "boundary",sum(intervals$trials$EstimatedBoundary)),"seconds",elapsed[["elapsed"]],"\n");flush.console()
}
