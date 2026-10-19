# Complete the prespecified comparison after a negative accuracy finding.
# Keep the original driver/results and reuse its finished N20 evaluations.
driver <- "inst/validation/mfrm-lr-rstar-kernel-review-20261013.R"
continuation <- "inst/validation/mfrm-lr-rstar-kernel-completion-20261013.R"
folder <- "validation-results/mfrm-lr-rstar-kernel-review-20261013"
cm <- file.path(folder,"completion-manifest.rds")
if(identical(commandArgs(TRUE),"replay")) {
  c <- readRDS(cm)
  stopifnot(identical(c$source,tools::md5sum(names(c$source))),
    identical(c$inputs,tools::md5sum(names(c$inputs))))
  source(driver)
}
expr <- as.list(parse(driver,keep.source=FALSE))
main <- which(vapply(expr,function(x) is.call(x) && identical(x[[1]],as.name("for")) &&
  identical(x[[2]],as.name("id")),TRUE))
stopifnot(length(main)==1L)
for(x in expr[seq_len(main-1L)]) {
  if(is.call(x) && identical(x[[1]],as.name("for")) && identical(x[[2]],as.name("name"))) next
  eval(x)
}
# Namespace guards require the top-level script caller, not eval().
for(name in c("fit_mfrm","simulate_mfrm_data","mfrm_gmfrm_reference_integrate"))
  assignInNamespace(name,blocked,"mfrmr")
for(name in c("optim","nlminb","nlm","rnorm","runif","rbinom")) assignInNamespace(name,blocked,"stats")
cb <- list(parent=tools::md5sum(mp),source=tools::md5sum(c(driver,continuation)),
  inputs=tools::md5sum(file.path(out,"case-01-evaluations.rds")),
  change="Record failed acceptance criteria; reuse finished evaluations; complete planned N240/curvature comparisons without changing thresholds")
if(file.exists(cm)) stopifnot(identical(readRDS(cm),cb)) else save_new(cb,cm)
changes <- integer(4L)
rewrite <- function(x) {
  if(is.call(x) && identical(x[[1]],as.name("for")) && identical(x[[2]],as.name("round"))) {
    changes[1] <<- changes[1]+1L
    return(substitute({
      checkpoint <- file.path(out,sprintf("case-%02d-evaluations.rds",id))
      if(file.exists(checkpoint)) {
        cached <- readRDS(checkpoint); stopifnot(identical(cached$manifest,tools::md5sum(mp)),identical(cached$points,points))
        results <- cached$results; timing <- list(cached$timing)
      } else LOOP
    },list(LOOP=x)))
  }
  if(identical(x,quote(stopifnot(all(accuracy$Passed))))) {
    changes[2] <<- changes[2]+1L; return(quote(invisible(accuracy$Passed)))
  }
  if(identical(x,quote(stopifnot(all(curve$Passed),center_error<=1e-4,fd_error<=1e-5)))) {
    changes[3] <<- changes[3]+1L
    return(quote(curve$Passed <- curve$Passed & center_error<=1e-4 & fd_error<=1e-5))
  }
  if(is.call(x) && identical(x[[1]],as.name("save_new")) &&
      any(grepl("evaluations.rds",deparse(x),fixed=TRUE))) {
    changes[4] <<- changes[4]+1L
    return(substitute(if(!file.exists(file.path(out,sprintf("case-%02d-evaluations.rds",id)))) SAVE,
      list(SAVE=x)))
  }
  if(is.call(x)) for(j in seq_along(x)) x[j] <- list(rewrite(x[[j]]))
  x
}
loop <- rewrite(expr[[main]]); stopifnot(identical(changes,rep(1L,4L)))
eval(loop)
check(binding$inputs); check(binding$source); check(cb$source); check(cb$inputs)
paths <- file.path(out,sprintf("case-%02d.rds",binding$ids))
result <- report(lapply(paths,readRDS)); save_new(result,file.path(out,"report.rds"))
for(name in c("points","timing","curvature"))
  write.csv(result[[name]],file.path(out,paste0(name,".csv")),row.names=FALSE)
save_new(list(files=tools::md5sum(c(mp,cm,paths,file.path(out,c("report.rds","points.csv","timing.csv","curvature.csv"))))),
  file.path(out,"verification.rds"))
cat("Completed retained-point comparison. All acceptance criteria met:",result$all_passed,"\n")
print(result$curvature,row.names=FALSE)
