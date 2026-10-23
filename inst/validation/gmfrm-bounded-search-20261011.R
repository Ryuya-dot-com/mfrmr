# Frozen comparison of the private bounded search, not a coverage study.
# Rscript --vanilla this-file prepare | run [Case] | summarize | verify
source("inst/validation/gmfrm-rater-face-20261011.R")
bs_script <- "inst/validation/gmfrm-bounded-search-20261011.R"
bs_out <- "validation-results/gmfrm-bounded-search-20261011"

bs_reference <- function(z, fit, full) {
  spec <- fit$gmfrm$specification
  # A positive point can use the already validated independent native
  # reference. Spell out the inverse map and propagate its numerical checks
  # into natural units; native-score precision alone would not suffice.
  if (all(z[17:22] > 0)) {
    c <- z[17:22]; q <- matrix(z[3:14], 6, 2, byrow = TRUE)
    s <- rowMeans(q)/c; tau <- (q[,1]-q[,2])/(2*c)
    p <- c(z[1:2], s, tau, z[15:16], log(c))
    model <- seg_design(fit,p)
    if (!full) return(list(nll=seg_reference(model,FALSE), method="native segmented NLL"))
    a <- seg_reference(model)
    J <- matrix(0,22,22); J[cbind(c(1:2,15:16),c(1:2,15:16))] <- 1
    for (r in 1:6) {
      J[2+r,2+2*r-c(1,0)] <- 1/(2*c[r])
      J[8+r,2+2*r-c(1,0)] <- c(1,-1)/(2*c[r])
      J[c(2+r,8+r,16+r),16+r] <- c(-s[r],-tau[r],1)/c[r]
    }
    pull <- function(score) -drop(crossprod(J,score))
    g <- pull(a$score); low <- pull(Reduce(`+`,lapply(a$people,`[[`,"low_score")))
    tail <- drop(crossprod(abs(J),Reduce(`+`,lapply(a$people,`[[`,"tail_score_bound"))))
    checks <- c(ScoreRuleDifference=max(abs(g-low)),TailScoreBound=max(tail))
    return(list(nll=a$nll,gradient=g,qualified=isTRUE(a$qualified) &&
      all(checks <= c(1e-6,1e-7)),checks=checks,native_checks=a$checks,
      method="independent native segmented reference, explicit inverse Jacobian"))
  }
  nll <- function(p) rf_literal(p,"rater_intercepts",spec)
  at <- nll(z)
  if (!full) return(list(nll=at,method="literal probabilities and base-R integration"))
  active <- which(z[17:22] == 0)+16L
  free <- setdiff(1:22,active)
  gradients <- lapply(c(1e-4,5e-5),function(h) vapply(free,function(k) {
    step <- h*max(1,abs(z[k]))
    if (k >= 17L) step <- min(step,z[k]/4)
    delta <- replace(z*0,k,step)
    (nll(z+delta)-nll(z-delta))/(2*step)
  },0))
  g <- z*0; g[free] <- (4*gradients[[2]]-gradients[[1]])/3
  outward <- lapply(active,function(k) nat_boundary_reference(z,"rater_intercepts",spec,k))
  g[active] <- vapply(outward,function(x) x[2],0)
  checks <- c(ScoreStepDifference=max(abs(gradients[[2]]-gradients[[1]])),
    NLLReferenceDifference=max(abs(vapply(outward,function(x) x[1],0)-at)))
  list(nll=at,gradient=g,qualified=all(checks <= c(1e-5,1e-7)),checks=checks,
    method="literal integrated-NLL Richardson score and directly integrated zero-slope score")
}

bs_phase <- function(key,seal,calculate,inputs=character()) {
  path <- file.path(bs_out,paste0(key,".rds")); hashes <- tools::md5sum(inputs)
  if (file.exists(path)) {
    x <- readRDS(path); stopifnot(identical(x$manifest,seal),identical(x$inputs,hashes)); return(x)
  }
  error <- ""; warnings <- character(); value <- NULL
  timing <- system.time(withCallingHandlers(tryCatch(value <- calculate(),
    error=function(e) error <<- conditionMessage(e)),warning=function(w) {
      warnings <<- c(warnings,conditionMessage(w)); invokeRestart("muffleWarning")
    }))
  x <- list(manifest=seal,inputs=hashes,value=value,error=error,warnings=unique(warnings),
    seconds=unname(timing["elapsed"]))
  temp <- paste0(path,".tmp"); saveRDS(x,temp); stopifnot(file.rename(temp,path))
  cat(key,if(nzchar(error)) error else "saved",x$seconds,"seconds\n"); flush.console(); x
}

bs_tables <- function(m,seal) {
  rows <- lapply(seq_len(nrow(m$jobs)),function(j) {
    job <- m$jobs[j,]; f <- readRDS(file.path(bs_out,paste0("fit-",job$Key,".rds")))
    r <- readRDS(file.path(bs_out,paste0("reference-",job$Key,".rds")))
    stopifnot(identical(f$manifest,seal),identical(r$manifest,seal))
    seg_hash_check(r$inputs); a <- f$value; v <- r$value
    data.frame(job[c("Case","Kind","Start","Key")],Candidate=isTRUE(a$candidate),
      ReferencePass=isTRUE(v$passed),Code=if(is.null(a$optimizer)) NA_integer_ else a$optimizer$convergence,
      NLL=if(is.null(a)) NA_real_ else a$selected$evaluation$value,
      ReferenceNLL=if(is.null(v)) NA_real_ else v$reference$nll,
      ProjectedScore=if(is.null(a)) NA_real_ else unname(a$checks["ProjectedScore"]),
      Active=if(is.null(a)) "" else paste(a$active,collapse=","),
      Rejected=if(is.null(a)) NA_integer_ else a$rejected_points,
      NLLDifference=if(is.null(v)) NA_real_ else unname(v$checks["NLL"]),
      GradientDifference=if(is.null(v)) NA_real_ else unname(v$checks["Gradient"]),
      ReferenceScore=if(is.null(v)) NA_real_ else unname(v$checks["ProjectedScore"]),
      Iterations=if(is.null(a$optimizer)) NA_integer_ else a$optimizer$iterations,
      FitSeconds=f$seconds,ReferenceSeconds=r$seconds,
      FitError=paste(c(f$error,a$error)[nzchar(c(f$error,a$error))],collapse="; "),ReferenceError=r$error)
  })
  attempts <- do.call(rbind,rows)
  pairs <- do.call(rbind,lapply(split(attempts,interaction(attempts$Case,attempts$Kind,drop=TRUE)),function(x) {
    prior <- subset(m$interior,Case == x$Case[1] & Kind == x$Kind[1])$InteriorNLL
    # This limit is feasible only for the free b09 model; never substitute it
    # for the original null or call it a finite attained optimum.
    competitor <- min(prior,if(x$Case[1] == "N20-b09" && x$Kind[1] == "free") m$b09_limit else Inf)
    spread <- diff(range(x$ReferenceNLL)); dominated <- min(x$ReferenceNLL) > competitor+1e-5
    data.frame(Case=x$Case[1],Kind=x$Kind[1],ReferencePasses=sum(x$ReferencePass),
      StartSpread=spread,BestReferenceNLL=min(x$ReferenceNLL),KnownFeasibleOrLimitNLL=competitor,
      Dominated=dominated,Passed=all(x$ReferencePass) && is.finite(spread) && spread <= 1e-5 && !dominated)
  }))
  list(attempts=attempts,pairs=pairs)
}

bs_main <- function(args) {
  stopifnot(length(args) >= 1L,args[1] %in% c("prepare","run","summarize","verify"))
  manifest <- file.path(bs_out,"manifest.rds")
  if (args[1] == "prepare") {
    stopifnot(!file.exists(manifest))
    old <- readRDS(file.path(nat_out,"manifest.rds"))
    envelope <- readRDS("validation-results/gmfrm-zero-envelope-20261011/results.rds")
    face <- readRDS(file.path(rf_out,"summary.rds"))
    seg_hash_check(old$inputs); seg_hash_check(envelope$inputs); seg_hash_check(face$results)
    jobs <- old$points[c("Case","Parent","Draw","Kind","Start","Key")]
    starts <- lapply(seq_len(nrow(jobs)),function(j) {
      job <- jobs[j,]; parent <- seg_parent(old$plan$Path[match(job$Parent,old$plan$Case)])
      x <- est_context(parent); idx <- est_fn("build_indices")(x$fit$prep,x$config$step_facet,
        x$config$slope_facet,x$config$interaction_specs,gpcm_spec=x$config$gpcm_spec)
      ev <- est_fn("mfrm_gmfrm_natural_evaluator")(idx,x$config,x$sizes,"rater_intercepts")
      native <- if(job$Start == "retained") parent$opt$par else parent$opt$par*0
      if(job$Kind == "null") native[15] <- parent$opt$par[15]+.5
      ev$from_native(native)
    }); names(starts) <- jobs$Key
    source_paths <- unique(c(bs_script,names(readRDS(file.path(rf_out,"manifest.rds"))$sources),
      list.files("R",full.names=TRUE),"src/mfrmr.so"))
    input_paths <- unique(c(old$plan$Path,file.path(seg_old,"N20",paste0(c("b09","b19"),"-generation.rds")),
      file.path(nat_out,c("manifest.rds","summary.rds")),
      "validation-results/gmfrm-zero-envelope-20261011/results.rds",
      file.path(rf_out,c("summary.rds","verification.rds")),names(face$results)))
    # Stored three limiting paths agreed to <8.4e-8; the minimum is a known
    # feasible-limit competitor, not a new optimizer or a global lower bound.
    limit_file <- "validation-results/gmfrm-zero-envelope-20261011/paths.csv"
    paths <- read.csv(limit_file)
    stopifnot(sum(is.infinite(paths$Time)) == 3L)
    m <- list(jobs=jobs,plan=old$plan,starts=starts,interior=envelope$table,b09_limit=min(paths$NLL[is.infinite(paths$Time)]),
      inputs=tools::md5sum(c(input_paths,limit_file)),sources=tools::md5sum(source_paths),
      session=sessionInfo(),threads=Sys.getenv(c("OMP_NUM_THREADS","OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS","VECLIB_MAXIMUM_THREADS")),
      policy=c("20 searches: five retained datasets, free/original Task-t1 null, original-parent/native-zero starts.",
        "Starts are mapped to the direct rater-intercept chart; null15=original parent15+0.5 exactly.",
        "Private bounded PORT search, maxit400, N objective scale, frozen start parameter scale, no restarts or extensions.",
        "Exact c>=0 bounds. Raw projected score<=1e-4, zero fixed error, code0 and no search error for candidate.",
        "Checkpoint each search before reference; compare independent NLL for every evaluable selected point.",
        "Full independent reference only for first-order candidates; natural-unit NLL<=1e-7 and gradient<=1e-6 agreement, reference projected score<=1e-4.",
        "Positive reference uses native segmented 32/64/GK and explicit inverse Jacobian, including natural score/tail checks.",
        "Zero-slope reference uses literal integrated-NLL two-step scores (difference<=1e-5), exact outward integral and NLL cross-check<=1e-7.",
        "Pair requires two reference passes, NLL spread<=1e-5, and no domination by saved feasible interior or applicable b09-free limit at 1e-5.",
        "Retain all failures. This tests first-order search and start agreement, not curvature/global MLE/LR/coverage.",
        "No data generation, bootstrap, face-by-face retries or public dispatch change."))
    dir.create(bs_out,recursive=TRUE,showWarnings=FALSE); saveRDS(m,manifest)
    for(path in source_paths) {
      dest <- file.path(bs_out,"epoch-source",path); dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
      stopifnot(file.copy(path,dest,overwrite=FALSE))
    }
    cat("Frozen 20 searches and conditional independent checks. No generation.\n"); return(invisible(NULL))
  }
  m <- readRDS(manifest); seal <- tools::md5sum(manifest); seg_hash_check(m$inputs); seg_hash_check(m$sources)
  if(args[1] %in% c("summarize","verify")) {
    tab <- bs_tables(m,seal)
    files <- list.files(bs_out,pattern="^(fit|reference)-.*[.]rds$",full.names=TRUE)
    stopifnot(length(files) == 40L)
    if(args[1] == "verify") {
      s <- readRDS(file.path(bs_out,"summary.rds")); seg_hash_check(s$results)
      stopifnot(identical(tab$attempts,s$attempts),identical(tab$pairs,s$pairs),identical(s$manifest,seal))
      saveRDS(list(manifest=seal,inputs=m$inputs,sources=m$sources,results=s$results,
        session=sessionInfo(),note="Fresh replay with package loading, optimization, quadrature and RNG disabled."),
        file.path(bs_out,"verification.rds"))
      cat("Fresh numerical-work-disabled replay passed.\n")
    } else {
      saveRDS(c(list(manifest=seal,results=tools::md5sum(files)),tab),file.path(bs_out,"summary.rds"))
      write.csv(tab$attempts,file.path(bs_out,"attempts.csv"),row.names=FALSE)
      write.csv(tab$pairs,file.path(bs_out,"pairs.csv"),row.names=FALSE)
    }
    print(tab$attempts,row.names=FALSE); print(tab$pairs,row.names=FALSE); return(invisible(NULL))
  }
  stopifnot(identical(sessionInfo(),m$session),identical(Sys.getenv(names(m$threads)),m$threads))
  jobs <- m$jobs
  if(length(args)>1L) { stopifnot(length(args)==2L,args[2] %in% jobs$Case); jobs <- jobs[jobs$Case==args[2],] }
  for(j in seq_len(nrow(jobs))) {
    job <- jobs[j,]; parent <- seg_parent(m$plan$Path[match(job$Parent,m$plan$Case)])
    score <- if(job$Draw == "observed") NULL else readRDS(file.path(seg_old,job$Parent,paste0(job$Draw,"-generation.rds")))$value$score
    x <- est_context(parent,score); fixed <- if(job$Kind == "null") 15L else integer()
    f <- bs_phase(paste0("fit-",job$Key),seal,function() {
      idx <- est_fn("build_indices")(x$fit$prep,x$config$step_facet,x$config$slope_facet,
        x$config$interaction_specs,gpcm_spec=x$config$gpcm_spec)
      ev <- est_fn("mfrm_gmfrm_natural_evaluator")(idx,x$config,x$sizes,"rater_intercepts")
      est_fn("mfrm_gmfrm_bounded_search")(m$starts[[job$Key]],ev,fixed=fixed,maxit=400L)
    })
    bs_phase(paste0("reference-",job$Key),seal,function() {
      if(nzchar(f$error)) stop(f$error)
      a <- f$value; z <- a$selected$parameters
      reference <- bs_reference(z,x$fit,isTRUE(a$candidate))
      checks <- c(NLL=abs(reference$nll-a$selected$evaluation$value),Gradient=NA_real_,ProjectedScore=NA_real_,
        Target=if(job$Kind == "null") abs(z[15]-parent$opt$par[15]-.5) else 0)
      if(isTRUE(a$candidate)) {
        checks["Gradient"] <- max(abs(reference$gradient-a$selected$evaluation$gradient))
        g <- reference$gradient[a$free]; active <- a$free %in% a$active; g[active] <- pmin(g[active],0)
        checks["ProjectedScore"] <- max(abs(g))
      }
      list(reference=reference,checks=checks,passed=isTRUE(a$candidate) && isTRUE(reference$qualified) &&
        all(is.finite(checks)) && all(checks <= c(1e-7,1e-6,1e-4,1e-12)))
    },file.path(bs_out,paste0("fit-",job$Key,".rds")))
  }
}
if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE)
  if(!args[1] %in% c("summarize","verify")) pkgload::load_all(quiet=TRUE,compile=FALSE)
  blocked <- function(...) stop("Bounded comparison attempted forbidden numerical work.")
  assignInNamespace("rnorm",blocked,ns="stats")
  if(args[1] %in% c("summarize","verify")) {
    for(name in c("optim","optimHess","nlminb","integrate","uniroot")) assignInNamespace(name,blocked,ns="stats")
    assignInNamespace("load_all",blocked,ns="pkgload")
  }
  bs_main(args)
}
