# Scoped live-caller qualification. prepare | references | run | boundary | verify
# One predetermined binary data set; retained references are evaluated, not refit.
source("inst/validation/gmfrm-segmented-reference-20261011.R")
directory <- "validation-results/gmfrm-run-20261011"
manifest_path <- file.path(directory,"manifest.rds")
new_sources <- c("R/core-gmfrm-reference.R","R/core-gmfrm-run.R",
  "tests/testthat/test-gmfrm-run.R","inst/validation/gmfrm-run-20261011.R")
action <- commandArgs(trailingOnly=TRUE)
stopifnot(length(action)==1L,action %in% c("prepare","references","run","boundary","verify"))
if(action!="verify") pkgload::load_all(quiet=TRUE,compile=FALSE)
blocked <- function(...) stop("Work outside the live-caller allocation is forbidden.")
for(name in c("rnorm","runif","rbinom")) assignInNamespace(name,blocked,ns="stats")
if(action=="verify") for(name in c("optim","optimHess","nlminb","integrate","uniroot"))
  assignInNamespace(name,blocked,ns="stats")
if(action=="prepare") {
  stopifnot(!file.exists(manifest_path))
  previous_path <- "validation-results/gmfrm-procedure-20261011/review.rds"
  previous <- readRDS(previous_path)
  replay <- readRDS("validation-results/gmfrm-procedure-20261011/verification.rds")
  stopifnot(identical(replay$review,tools::md5sum(previous_path)))
  for(h in list(previous$inputs,previous$sources,previous$phases)) seg_hash_check(h)
  tests <- readRDS(file.path(directory,"tests.rds")); seg_hash_check(tests$sources)
  stopifnot(all(tests$tests$failed==0L),!any(tests$tests$error))
  old <- readRDS("validation-results/gmfrm-interior-finish-20261011/manifest.rds")
  candidate <- readRDS("validation-results/gmfrm-candidate-20261011/review.rds")
  positive <- paste0(c("N20","N60","N240"),"-observed-free-retained")
  boundary <- old$jobs$Key[!old$jobs$Interior]
  references <- lapply(c(positive,boundary),function(key) {
    job <- old$jobs[old$jobs$Key==key,]; c <- candidate$candidates[[key]]
    parent_path <- old$parent$plan$Path[match(job$Parent,old$parent$plan$Case)]
    parent <- seg_parent(parent_path); specification <- parent$gmfrm$specification
    if(job$Draw!="observed") specification$data[[specification$score]] <-
      readRDS(file.path(seg_old,job$Parent,paste0(job$Draw,"-generation.rds")))$value$score
    specification$quadrature <- NULL
    list(key=key,specification=specification,z=c$selected$parameters,p=c$native_parameters,
      expected=if(job$Interior) c$stages$reference else readRDS(file.path(
        "validation-results/gmfrm-bounded-search-20261011",paste0("reference-",key,".rds"))))
  }); names(references) <- c(positive,boundary)
  # Predetermined response-pattern counts, not draws or performance replications.
  patterns <- as.matrix(expand.grid(rep(list(0:1),4)))
  counts <- c(5,1,1,1,0,1,1,0,1,1,1,1,1,0,1,4)
  responses <- patterns[rep(seq_len(nrow(patterns)),counts),,drop=FALSE]
  d <- expand.grid(Examinee=sprintf("p%02d",seq_len(nrow(responses))),
    Item=c("i1","i2"),Judge=c("j1","j2"))
  d$Rating <- as.vector(responses)
  args <- list(data=d,max_score=1L,starts=list(neutral=numeric(6),
    perturbed=c(.05,-.04,.03,.1,-.05,.06)),slope_facets=c("Item","Judge"),
    person="Examinee",score="Rating",fixed=integer(),maxit=400L,chart="rater_intercepts")
  stopifnot(nrow(responses)==20L,nrow(d)==80L)
  input_paths <- unique(c(previous_path,"validation-results/gmfrm-procedure-20261011/verification.rds",
    "validation-results/gmfrm-interior-finish-20261011/manifest.rds",
    "validation-results/gmfrm-candidate-20261011/review.rds",names(old$inputs),
    names(previous$phases),file.path(directory,"tests.rds")))
  m <- list(inputs=tools::md5sum(input_paths),sources=tools::md5sum(unique(c(names(previous$sources),new_sources))),
    references=references,args=args,session=sessionInfo(),
    threads=Sys.getenv(c("OMP_NUM_THREADS","OPENBLAS_NUM_THREADS","MKL_NUM_THREADS","VECLIB_MAXIMUM_THREADS")),
    policy=c("Three retained N20/N60/N240 interior reference evaluations and all six boundary references; no retained fit or Hessian repeated.",
      "One predetermined N20 binary 2-by-2 design, two prescribed native starts, unchanged maxit400 and local qualification criteria.",
      "Actual data-to-result execution, no mocked numerical kernels. No new starts, rescue, sampling-performance or public-output admission.",
      "The tiny fixed rule in input setup is never used as the fitting/reference rule. Completed phases are reused."))
  saveRDS(m,manifest_path)
  for(s in new_sources) {
    dest <- file.path(directory,"epoch-source",s); dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
    stopifnot(file.copy(s,dest,overwrite=FALSE))
  }
  cat("Bound 9 reference-only comparisons and one live N20 binary caller witness.\n")
} else {
  m <- readRDS(manifest_path); seal <- tools::md5sum(manifest_path)
  seg_hash_check(m$inputs); seg_hash_check(m$sources[!names(m$sources)%in%new_sources])
  stopifnot(identical(unname(tools::md5sum(file.path(directory,"epoch-source",new_sources))),unname(m$sources[new_sources])))
  # Source-level reuse: only the boundary integral changed. The live witness
  # and three positive references never entered that branch.
  old_functions <- new.env(parent=baseenv()); current_functions <- new.env(parent=baseenv())
  sys.source(file.path(directory,"epoch-source/R/core-gmfrm-reference.R"),old_functions)
  sys.source("R/core-gmfrm-reference.R",current_functions)
  unchanged <- setdiff(ls(old_functions),"mfrm_gmfrm_reference_boundary")
  stopifnot(setequal(ls(old_functions),ls(current_functions)),all(vapply(unchanged,function(n)
    identical(formals(old_functions[[n]]),formals(current_functions[[n]])) &&
      identical(body(old_functions[[n]]),body(current_functions[[n]])),TRUE)),
    identical(unname(tools::md5sum("R/core-gmfrm-run.R")),unname(m$sources["R/core-gmfrm-run.R"])))
  phase <- function(key,calculate) {
    path <- file.path(directory,paste0(key,".rds"))
    if(file.exists(path)) {
      a <- readRDS(path); stopifnot(identical(a$manifest,seal)); return(a)
    }
    value <- NULL; error <- ""; warnings <- character()
    seconds <- system.time(withCallingHandlers(tryCatch(value <- calculate(),
      error=function(e) error <<- conditionMessage(e)),warning=function(w) {
        warnings <<- c(warnings,conditionMessage(w)); invokeRestart("muffleWarning")
      }))["elapsed"]
    a <- list(manifest=seal,value=value,error=error,warnings=warnings,seconds=unname(seconds))
    temp <- paste0(path,".tmp"); saveRDS(a,temp); stopifnot(file.rename(temp,path))
    cat(key,if(nzchar(error)) error else "saved",seconds,"seconds\n"); flush.console(); a
  }
  if(action %in% c("references","run")) {
    seg_hash_check(m$sources)
    stopifnot(identical(sessionInfo(),m$session),identical(Sys.getenv(names(m$threads)),m$threads))
    if(action=="references") for(key in names(m$references)) {
      a <- m$references[[key]]
      phase(paste0("reference-",key),function() get("mfrm_gmfrm_reference",asNamespace("mfrmr"))(
        a$specification,"rater_intercepts")(a$z,a$p))
    } else invisible(phase("live",function() do.call(get("mfrm_gmfrm_run",asNamespace("mfrmr")),m$args)))
  } else {
    boundary_path <- file.path(directory,"boundary-manifest.rds")
    boundary_keys <- names(Filter(function(x) is.null(x$p),m$references))
    if(action=="boundary" && !file.exists(boundary_path)) {
      tests <- readRDS(file.path(directory,"boundary-tests.rds")); seg_hash_check(tests$sources)
      stopifnot(all(tests$tests$failed==0L),!any(tests$tests$error))
      b <- list(inputs=tools::md5sum(c(manifest_path,file.path(directory,"boundary-tests.rds"),
          file.path(directory,paste0(c("live",paste0("reference-",names(m$references))),".rds")))),
        sources=tools::md5sum(new_sources),keys=boundary_keys,session=sessionInfo(),
        note="Only mode-scaled boundary references are reevaluated; interior function bodies and live caller are unchanged.")
      saveRDS(b,boundary_path)
      for(s in new_sources) {
        dest <- file.path(directory,"boundary-source",s); dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
        stopifnot(file.copy(s,dest,overwrite=FALSE))
      }
    }
    b <- readRDS(boundary_path); boundary_seal <- tools::md5sum(boundary_path)
    seg_hash_check(b$inputs)
    # A read-only verifier correction does not invalidate completed numerics.
    if(action=="boundary") seg_hash_check(b$sources) else
      seg_hash_check(b$sources[names(b$sources)!="inst/validation/gmfrm-run-20261011.R"])
    stopifnot(identical(unname(tools::md5sum(file.path(directory,"boundary-source",new_sources))),unname(b$sources)))
    if(action=="boundary") {
      stopifnot(identical(sessionInfo(),b$session),identical(Sys.getenv(names(m$threads)),m$threads))
      seal <- boundary_seal
      for(key in boundary_keys) {
        a <- m$references[[key]]
        invisible(phase(paste0("scaled-reference-",key),function() get("mfrm_gmfrm_reference",asNamespace("mfrmr"))(
          a$specification,"rater_intercepts")(a$z,NULL)))
      }
      quit(save="no",status=0L)
    }
    records <- file.path(directory,paste0(c(paste0("reference-",names(m$references)),"live"),".rds"))
    rows <- lapply(names(m$references),function(key) {
      expected <- m$references[[key]]; a <- readRDS(file.path(directory,paste0("reference-",key,".rds")))
      stopifnot(identical(a$manifest,seal))
      first_error <- a$error
      working_difference <- NA_real_
      if(is.null(expected$p)) {
        stopifnot(identical(first_error,if(nzchar(expected$expected$error)) expected$expected$error else
          "Independent boundary likelihood did not meet its accuracy criterion."))
        a <- readRDS(file.path(directory,paste0("scaled-reference-",key,".rds")))
        stopifnot(identical(a$manifest,boundary_seal))
        delta <- if(nzchar(a$error) || nzchar(expected$expected$error)) NA_real_ else
          abs(a$value$reference$nll-expected$expected$value$reference$nll)
        if(!nzchar(expected$expected$error)) stopifnot(!nzchar(a$error),delta<1e-7)
        working <- readRDS(file.path("validation-results/gmfrm-bounded-search-20261011",
          paste0("fit-",key,".rds")))$value$selected$evaluation$value
        if(!nzchar(a$error)) working_difference <- abs(a$value$reference$nll-working)
        # Finite integration is not reference agreement: both b19-free points
        # remain refused by the unchanged 1e-7 likelihood identity criterion.
        if(nzchar(expected$expected$error)) stopifnot(is.finite(working_difference),working_difference>1e-7)
        gradient <- NA_real_
      } else {
        stopifnot(!nzchar(a$error),isTRUE(a$value$reference$qualified))
        delta <- abs(a$value$reference$nll-expected$expected$reference$nll)
        gradient <- max(abs(a$value$native_gradient-expected$expected$native_gradient))
        stopifnot(delta<1e-7,gradient<1e-6)
      }
      data.frame(Key=key,NLLDifference=delta,GradientDifference=gradient,
        WorkingNLLDifference=working_difference,FirstError=first_error,Error=a$error,Seconds=a$seconds)
    })
    rows <- do.call(rbind,rows)
    live <- readRDS(file.path(directory,"live.rds")); stopifnot(identical(live$manifest,seal),!nzchar(live$error))
    a <- live$value; expected_specification <- m$args[c("data","max_score","slope_facets","person","score")]
    expected_specification$data <- as.data.frame(m$args$data[c(m$args$person,m$args$slope_facets,m$args$score)])
    stopifnot(identical(a$specification,expected_specification),identical(a$native_starts,m$args$starts),
      identical(names(a$attempts),names(m$args$starts)),length(a$attempts)==2L,
      !inherits(a,"mfrm_fit"),!any(unlist(a$admission[c("public_fit","intervals","person_scoring")])) )
    if(!is.null(a$candidate)) stopifnot(identical(a$candidate$status,"reference_qualified_local_candidate"),
      identical(a$candidate$information,a$attempts[[a$selection$selected]]$stages$finish$value$information))
    stopifnot(all(vapply(a$attempts,function(x) !length(x$candidate$boundary),TRUE)))
    tab <- do.call(rbind,lapply(names(a$attempts),function(name) {
      attempt <- a$attempts[[name]]; c <- attempt$candidate
      data.frame(Start=name,Status=attempt$status,SearchCode=attempt$stages$search$value$optimizer$convergence,
        ReferenceNLL=unname(a$reference_nll[name]),InformationScope=c$information_scope)
    }))
    records <- c(records,file.path(directory,paste0("scaled-reference-",boundary_keys,".rds")))
    result <- list(manifest=seal,boundary_manifest=boundary_seal,results=tools::md5sum(records),references=rows,live=tab,
      live_status=a$status,seconds=live$seconds,evaluations=a$evaluations,
      verifier=tools::md5sum("inst/validation/gmfrm-run-20261011.R"),session=sessionInfo())
    path <- file.path(directory,"verification.rds")
    if(file.exists(path)) stopifnot(identical(result,readRDS(path))) else saveRDS(result,path)
    print(rows,row.names=FALSE); print(tab,row.names=FALSE)
    cat("Live result:",a$status,";",live$seconds,"seconds. Fresh read-only verification passed.\n")
  }
}
