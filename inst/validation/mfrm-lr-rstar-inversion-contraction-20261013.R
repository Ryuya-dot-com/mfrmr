# Resume only N20's bracket search; numerical methods and passing phases stay fixed.
driver <- "inst/validation/mfrm-lr-rstar-inversion-20261013.R"
script <- "inst/validation/mfrm-lr-rstar-inversion-contraction-20261013.R"
expr <- as.list(parse(driver,keep.source=FALSE))
main <- which(vapply(expr,function(x) is.call(x) && identical(x[[1]],as.name("for")) &&
  identical(x[[2]],as.name("id")),TRUE))
stopifnot(length(main)==1L)
# Load the original bindings, checks and functions, without running its case loop.
for (x in expr[seq_len(main-1L)]) {
  if(is.call(x) && identical(x[[1]],as.name("for")) && identical(x[[2]],as.name("n"))) next
  eval(x)
}
# Namespace guards must be installed from the top-level script, not eval().
for (name in c("fit_mfrm","simulate_mfrm_data")) assignInNamespace(name,blocked,"mfrmr")
for (name in c("rnorm","runif","rbinom")) assignInNamespace(name,blocked,"stats")
parent_binding <- binding
continuation_binding <- list(parent=parent_binding,
  source=tools::md5sum(c(driver,script)),
  diagnostic=tools::md5sum("tmp/pdfs/population-rstar-20261013/failed-upper-review.rds"),
  change="Up to eight bracket steps; bisect toward last passing point after a failed far trial")
file <- file.path(out,"contraction-manifest.rds")
if(file.exists(file)) stopifnot(identical(readRDS(file),continuation_binding)) else
  saveRDS(continuation_binding,file)

# Replace exactly the bracket-control expression; no fitting or r* formula changes.
old_loop <- quote(for (j in seq_len(4L)) {
  if(a*b<=0) break
  outer <- outer+direction*.5*source$se*1.5^(j-1L); b <- f(outer)
})
new_loop <- quote({
  previous_passing <- outer
  for (j in seq_len(8L)) {
    if(is.finite(b) && a*b<=0) break
    outer <- if(!is.finite(b)) (previous_passing+outer)/2 else
      outer+direction*.5*source$se*1.5^(j-1L)
    b <- tryCatch(f(outer),error=function(e) NA_real_)
    if(is.finite(b)) previous_passing <- outer
  }
})
replacements <- 0L
replace_loop <- function(x) {
  if(identical(x,old_loop)) {replacements <<- replacements+1L; return(new_loop)}
  if(is.call(x)) for(j in seq_along(x)) x[j] <- list(replace_loop(x[[j]]))
  x
}
body(run_case) <- replace_loop(body(run_case)); stopifnot(replacements==1L)

phase <- function(i,name,fn) {
  path <- file.path(out,sprintf("case-%02d-%s.rds",i,name))
  if(file.exists(path)) {
    x <- readRDS(path)
    stopifnot(identical(x$binding,parent_binding) || identical(x$binding,continuation_binding))
    if(nzchar(x$error)) stop(x$error); return(x$value)
  }
  begin <- proc.time()[["elapsed"]]
  x <- tryCatch(list(value=fn(),error=""),error=function(e) list(value=NULL,error=conditionMessage(e)))
  x$elapsed <- proc.time()[["elapsed"]]-begin; x$binding <- continuation_binding
  saveRDS(x,paste0(path,".tmp")); stopifnot(file.rename(paste0(path,".tmp"),path))
  cat(i,name,round(x$elapsed,3),"seconds",x$error,"\n"); flush.console()
  if(nzchar(x$error)) stop(x$error); x$value
}
value <- phase(1L,"result-contraction",function() run_case(1L))
stopifnot(value$passed)
cat("N20 endpoints:",value$endpoints$Lower$variance,value$endpoints$Upper$variance,
    "central error:",value$center$error,"\n")
