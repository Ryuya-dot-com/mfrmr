# Five frozen diagnostic datasets; prepare | run | verify. No new responses.
# Same-data public baseline -> adaptive/neutral segmented starts -> joint Wald.
args <- commandArgs(TRUE); stopifnot(length(args)==1L,args %in% c("prepare","run","verify"))
action <- args[[1]]
directory <- "validation-results/gmfrm-complete-procedure-20261011"
script <- "inst/validation/gmfrm-complete-procedure-20261011.R"
manifest_path <- file.path(directory,"manifest.rds")
pkgload::load_all(quiet=TRUE,compile=FALSE)
fn <- function(n) get(n,asNamespace("mfrmr"))
check <- function(h) stopifnot(length(h)>0L,!anyNA(h),identical(h,tools::md5sum(names(h))))
blocked <- function(...) stop("Numerical work outside the complete-procedure allocation.")
for(n in c("rnorm","runif","rbinom")) assignInNamespace(n,blocked,"stats")
old_dir <- "validation-results/gmfrm-result-20261011/qualified"
read_fit <- function(path) {
  x <- readRDS(path); if(inherits(x,"mfrm_fit")) x else x$payload$value
}
capture <- function(calculate) {
  value <- NULL; error <- NULL; warnings <- character()
  seconds <- system.time(withCallingHandlers(tryCatch(value <- calculate(),
    error=function(e) error <<- e),warning=function(w) {
      warnings <<- c(warnings,conditionMessage(w)); invokeRestart("muffleWarning")
    }))[["elapsed"]]
  list(value=value,error=error,warnings=warnings,seconds=seconds)
}
if(action=="prepare") {
  stopifnot(!file.exists(manifest_path)); dir.create(directory,recursive=TRUE,showWarnings=FALSE)
  old_manifest <- readRDS(file.path(old_dir,"manifest.rds"))
  check(old_manifest$inputs)
  old <- readRDS("validation-results/gmfrm-interior-finish-20261011/manifest.rds")
  stopifnot(identical(old$session$R.version,sessionInfo()$R.version),
    identical(old$threads,Sys.getenv(names(old$threads))))
  packages <- c(old$session$otherPkgs,old$session$loadedOnly)
  stopifnot(identical(old$session$BLAS,sessionInfo()$BLAS),
    identical(old$session$LAPACK,sessionInfo()$LAPACK),
    all(vapply(packages,function(p) identical(package_version(p$Version),
      utils::packageVersion(p$Package)),TRUE)))
  paths <- setNames(old$parent$plan$Path,old$parent$plan$Case)
  cases <- c("N20-observed","N60-observed","N240-observed","N20-b09","N20-b19")
  inputs <- c(paths,file.path(old_dir,paste0(cases,".free.rds")),
    file.path("validation-results/gmfrm-wald-20261011",paste0(cases,".free.rds")),
    file.path("validation-results/gmfrm-null-bootstrap-20261010/N20",paste0(c("b09","b19"),"-generation.rds")),
    file.path("validation-results/gmfrm-run-20261011",paste0("scaled-reference-N20-",c("b09","b19"),"-free-neutral.rds")),
    file.path(old_dir,"manifest.rds"),file.path(old_dir,"verification.rds"),
    "validation-results/gmfrm-interior-finish-20261011/manifest.rds")
  # All prior numerical files stay bound. Changes to public explicit-start
  # support do not change the default neutral/EM branch (AST check below).
  previous <- readRDS("validation-results/gmfrm-procedure-20261011/review.rds")
  check(previous$phases); check(previous$inputs)
  changed <- names(previous$sources)[previous$sources!=tools::md5sum(names(previous$sources))]
  numerical_changed <- changed[grepl("^R/core-",changed)]
  stopifnot(setequal(numerical_changed,c("R/core-gmfrm-em.R","R/core-gpcm-profile.R")))
  # The changed profile dispatcher is not called by this estimation/Wald path.
  epoch <- "validation-results/gmfrm-adaptive-profile-20261010/package-source/R/core-gmfrm-em.R"
  e <- new.env(parent=asNamespace("mfrmr")); sys.source(epoch,e)
  syntax <- function(x) parse(text=deparse(x),keep.source=FALSE)[[1L]]
  for(n in c("mfrm_gmfrm_problem","mfrm_gmfrm_em","mfrm_gmfrm_assemble_fit"))
    stopifnot(identical(syntax(body(e[[n]])),syntax(body(fn(n)))),identical(formals(e[[n]]),formals(fn(n))))
  before <- as.list(syntax(body(e$mfrm_gmfrm_adaptive_fit))); after <- as.list(syntax(body(fn("mfrm_gmfrm_adaptive_fit"))))
  # Normalize only the new explicit-list branch, never the optimizer body.
  stopifnot(identical(after[[3]],quote(supplied <- is.list(policy))),
    identical(after[[4]],quote(starts <- if (supplied) policy else list(neutral = problem$start))),
    identical(after[[5]][[1]],as.name("if")),identical(after[[5]][[2]],as.name("supplied")))
  after <- c(after[1:2],before[3],after[-(1:5)])
  stopifnot(identical(before,after))
  records <- lapply(cases,function(case) {
    parent <- strsplit(case,"-",fixed=TRUE)[[1]][1]
    fit <- read_fit(paths[[parent]]); s <- fit$gmfrm$specification; s$quadrature <- NULL
    if(!grepl("observed$",case)) s$data[[s$score]] <- readRDS(file.path(
      "validation-results/gmfrm-null-bootstrap-20261010/N20",paste0(sub("N20-","",case),"-generation.rds")))$value$score
    retained <- readRDS(file.path(old_dir,paste0(case,".free.rds")))$result
    stopifnot(identical(s,retained$run$specification))
    if(grepl("observed$",case)) {
      a <- fit$opt$mml_initialization
      stopifnot(identical(a$policy,"neutral_em"),
        identical(a$controls,list(quad_points=31L,maxit=500L,reltol=1e-10,optimizer="BFGS")),
        identical(unname(a$attempts$neutral$start),numeric(22)),
        identical(a$attempts$em$start,a$em$value$par),
        max(abs(unname(fit$opt$par)-retained$run$native_starts$retained)) <=
          64*.Machine$double.eps*max(1,abs(fit$opt$par)))
    }
    list(specification=s,parent_path=paths[[parent]],reuse_baseline=grepl("observed$",case))
  }); names(records) <- cases
  m <- list(cases=records,inputs=tools::md5sum(unique(c(inputs,names(previous$phases),epoch))),
    sources=tools::md5sum(c(script,list.files("R",pattern="[.]R$",full.names=TRUE),"src/mfrmr.so")),
    session=sessionInfo(),threads=Sys.getenv(c("OMP_NUM_THREADS","OPENBLAS_NUM_THREADS","MKL_NUM_THREADS","VECLIB_MAXIMUM_THREADS")),
    policy=c("Fixed five diagnostic cases; no performance denominators or new responses.",
      "Public adaptive neutral/EM GH31 maxit500 BFGS reltol1e-10; candidate uses selected same-data public point plus neutral.",
      "Segmented rater_intercepts, maxit400, unchanged reference and information gates; every start retained.",
      "All three observed paths and both adverse neutral paths reused; only absent adverse baseline/adaptive path computed.",
      "Earlier likelihood witnesses challenge results separately, never initialize this recipe; no automatic global/boundary guarantee."))
  saveRDS(m,manifest_path)
  cat("Frozen 5 cases; 3 complete optimizations and 2 neutral paths reusable.\n")
  quit(save="no")
}
m <- readRDS(manifest_path); check(m$inputs); check(m$sources); seal <- tools::md5sum(manifest_path)
stopifnot(identical(sessionInfo(),m$session),identical(Sys.getenv(names(m$threads)),m$threads))
phase <- function(key,calculate) {
  path <- file.path(directory,paste0(key,".rds"))
  if(file.exists(path)) {
    a <- readRDS(path); stopifnot(identical(a$manifest,seal)); return(a)
  }
  stopifnot(action=="run")
  a <- capture(calculate); a$manifest <- seal
  tmp <- paste0(path,".tmp"); saveRDS(a,tmp); stopifnot(file.rename(tmp,path))
  cat(key,if(is.null(a$error)) "saved" else conditionMessage(a$error),a$seconds,"seconds\n"); flush.console()
  a
}
value <- function(x) { if(!is.null(x$error)) stop(x$error); x$value }
if(action=="verify") for(n in c("optim","optimHess","nlminb","integrate","uniroot"))
  assignInNamespace(n,blocked,"stats")
rows <- list()
for(case in names(m$cases)) {
  job <- m$cases[[case]]; s <- job$specification
  old_result <- readRDS(file.path(old_dir,paste0(case,".free.rds")))$result
  baseline <- phase(paste0(case,"-baseline"),function() {
    if(job$reuse_baseline) return(read_fit(job$parent_path))
    fit_mfrm(s$data,person=s$person,facets=s$slope_facets,score=s$score,
      rating_min=0,rating_max=s$max_score,keep_original=TRUE,category_policy="preserve",
      model="GPCM",method="MML",step_facet=s$slope_facets[2],slope_facet=s$slope_facets,
      noncenter_facet=s$slope_facets[2],quad_points=31L,maxit=500L,optimizer="BFGS",
      mml_engine="direct",mml_integration="adaptive",gpcm_mml_identification="fixed_standard_normal",
      reltol=1e-10,gpcm_mml_start="neutral_em")
  })
  answer <- phase(paste0(case,"-answer"),function() {
    if(!is.null(baseline$error)) return(list(status="baseline_unavailable",error=conditionMessage(baseline$error)))
    fit <- baseline$value; p <- unname(fit$opt$par)
    stopifnot(all(is.finite(p)),length(p)==22L)
    common <- do.call(fn("mfrm_gmfrm_common_setup"),s)
    natural <- fn("mfrm_gmfrm_natural_evaluator")(common$idx,common$config,common$sizes,"rater_intercepts")
    reference <- fn("mfrm_gmfrm_reference")(s,"rater_intercepts")
    b <- phase(paste0(case,"-baseline-reference"),function() reference(natural$from_native(p),p))
    comparisons <- list()
    if(is.null(b$error)) comparisons$baseline <- list(kind="feasible_point",nll=b$value$reference$nll,
      fixed=integer(),values=numeric(),verified=TRUE,specification=s)
    if(job$reuse_baseline) {
      run <- old_result$run
      # The earlier adapter reconstructed native starts from the natural chart.
      # Bind to the exact original natural search input, not roundtrip bits.
      stopifnot(identical(natural$from_native(p),run$attempts$retained$stages$search$value$initial$parameters))
      names(run$native_starts) <- names(run$attempts) <- names(run$reference_nll) <- c("adaptive","neutral")
      run$native_starts$adaptive <- p
      run$comparisons <- comparisons
      run$selection <- fn("mfrm_gmfrm_select_candidates")(lapply(run$attempts,`[[`,"candidate"),
        names(run$attempts),run$reference_nll,comparisons)
      run$candidate <- run$selection$candidate; run$status <- run$selection$status
    } else {
      # Replay the unchanged, input-bound neutral path. Other stages are live
      # and checkpointed separately so a stopped connection need not restart.
      e <- new.env(parent=asNamespace("mfrmr"))
      for(path in c("R/core-gmfrm-run.R","R/core-gmfrm-procedure.R")) sys.source(path,e)
      active <- NULL; neutral <- old_result$run$attempts$neutral
      start_z <- list(adaptive=natural$from_native(p),neutral=natural$from_native(numeric(22)))
      e$mfrm_gmfrm_bounded_search <- function(start,evaluator,fixed,maxit) {
        active <<- names(start_z)[vapply(start_z,identical,TRUE,start)]
        stopifnot(length(active)==1L,identical(fixed,integer()),identical(maxit,400L))
        if(active=="neutral") {
          stopifnot(identical(start,neutral$start)); return(neutral$stages$search$value)
        }
        value(phase(paste0(case,"-adaptive-search"),function()
          fn("mfrm_gmfrm_bounded_search")(start,evaluator,fixed,maxit)))
      }
      e$mfrm_gmfrm_finish_interior <- function(start,evaluator,fixed) value(phase(
        paste0(case,"-",active,"-finish"),function() fn("mfrm_gmfrm_finish_interior")(start,evaluator,fixed)))
      e$mfrm_gmfrm_procedure_chart <- function(finish,natural,original) value(phase(
        paste0(case,"-",active,"-chart"),function() fn("mfrm_gmfrm_procedure_chart")(finish,natural,original)))
      e$mfrm_gmfrm_reference <- function(specification,chart) {
        stopifnot(identical(specification,s),identical(chart,"rater_intercepts"))
        function(z,p) {
          if(active=="neutral") {
            stopifnot(is.null(p),identical(z,neutral$candidate$selected$parameters))
            saved <- readRDS(file.path("validation-results/gmfrm-run-20261011",
              paste0("scaled-reference-",case,"-free-neutral.rds")))
            if(nzchar(saved$error)) stop(saved$error)
            return(saved$value)
          }
          value(phase(paste0(case,"-adaptive-reference"),function() reference(z,p)))
        }
      }
      run <- do.call(e$mfrm_gmfrm_run,c(s,list(starts=list(adaptive=p,neutral=numeric(22)),
        comparisons=comparisons,maxit=400L,chart="rater_intercepts")))
    }
    # External challenges do not manufacture an automatically found optimum.
    challenges <- old_result$run$comparisons
    challenged <- if(all(vapply(run$attempts,function(x) !is.null(x$candidate),TRUE)))
      fn("mfrm_gmfrm_select_candidates")(lapply(run$attempts,`[[`,"candidate"),names(run$attempts),
        run$reference_nll,c(comparisons,challenges)) else NULL
    result <- phase(paste0(case,"-result"),function() fn("mfrm_gmfrm_result")(run))
    wald <- NULL
    if(is.null(result$error)) {
      r <- result$value
      old_wald <- readRDS(file.path("validation-results/gmfrm-wald-20261011",paste0(case,".free.rds")))$wald
      C <- old_wald$contrasts
      # Add the missing first-family 1-minus-2 contrast, preserving all 55
      # prior targets and their ordered full-nuisance Jacobians.
      ctask <- numeric(ncol(C)); ctask[1:2] <- c(1,-1)
      C <- rbind(C,"location:Task:1-2"=ctask)
      exponentiate <- c(old_wald$intervals$Scale=="exp_native",FALSE)
      wald <- phase(paste0(case,"-wald"),function() {
        e <- new.env(parent=asNamespace("mfrmr")); sys.source("R/core-gmfrm-wald.R",e)
        if(identical(run$candidate,old_result$run$candidate)) e$mfrm_gmfrm_wald_information <- function(result) {
          fn("mfrm_gmfrm_result_check")(result)
          stopifnot(identical(result$components,old_result$components),
            identical(result$run$specification,old_result$run$specification))
          info <- old_wald$information; info$source_identity <- result$identity; info
        }
        e$mfrm_gmfrm_wald(r,C,exponentiate)
      })
    }
    list(status=run$status,baseline_reference=b,run=run,challenged=challenged,result=result,wald=wald)
  })
  a <- value(answer); w <- a$wald$value; r <- a$run; b <- a$baseline_reference$value
  available <- if(is.null(w)) 0L else sum(w$intervals$NumericallyAvailable)
  if(!is.null(a$challenged) && a$challenged$status!="local_candidate_selected") stopifnot(available==0L)
  row <- data.frame(Case=case,BaselineReused=job$reuse_baseline,
    BaselineCode=if(is.null(baseline$value)) NA_integer_ else baseline$value$opt$convergence,
    BaselineReferenceNLL=if(is.null(b)) NA_real_ else b$reference$nll,
    BaselineReferenceScore=if(is.null(b)) NA_real_ else max(abs(b$native_gradient)),
    CandidateStatus=a$status,ChallengeStatus=if(is.null(a$challenged)) NA_character_ else a$challenged$status,
    SelectedNLL=if(is.null(r$candidate)) NA_real_ else r$candidate$stages$reference$reference$nll,
    SelectedScore=if(is.null(r$candidate)) NA_real_ else max(abs(r$candidate$stages$reference$native_gradient)),
    NumericalIntervals=available,CoverageQualified=FALSE)
  if(action=="verify" && !is.null(r)) {
    stopifnot(identical(r$native_starts$adaptive,unname(baseline$value$opt$par)),
      identical(r$native_starts$neutral,numeric(22)),identical(r$specification,s),
      identical(names(r$attempts),c("adaptive","neutral")))
    if(!is.null(a$result$value)) fn("mfrm_gmfrm_result_check")(a$result$value)
    if(!is.null(w)) {
      stopifnot(!any(w$intervals$CoverageQualified),nrow(w$intervals)==56L)
      if(w$information$eligible) {
        C <- w$contrasts; p <- r$candidate$native_parameters; V <- w$information$covariance
        se <- sqrt(diag(C%*%V%*%t(C)))
        stopifnot(max(abs(w$intervals$NativeEstimate-drop(C%*%p)))<1e-12,
          max(abs(w$intervals$NativeSE-se))<1e-12)
      } else stopifnot(all(is.na(w$intervals$Lower)),all(is.na(w$intervals$Upper)))
    }
  }
  rows[[case]] <- row; print(row,row.names=FALSE); flush.console()
}
summary <- do.call(rbind,rows)
path <- file.path(directory,"summary.rds")
if(action=="run") {
  if(file.exists(path)) stopifnot(identical(readRDS(path),summary)) else saveRDS(summary,path)
  write.csv(summary,file.path(directory,"summary.csv"),row.names=FALSE)
} else {
  stopifnot(identical(readRDS(path),summary))
  saveRDS(list(manifest=seal,results=tools::md5sum(list.files(directory,pattern="[.]rds$",full.names=TRUE)),
    note="Fresh replay with optimizers, integration and RNG blocked; all five outcomes retained."),
    file.path(directory,"verification.rds"))
  cat("Fresh complete-procedure replay passed.\n")
}
