# Retained-endpoint qualification; no new starts or response generation.
# Rscript --vanilla this-file prepare | run [Parent] | summarize | verify
source("inst/validation/gmfrm-segmented-estimation-20261011.R")
fi_script <- "inst/validation/gmfrm-interior-finish-20261011.R"
fi_out <- "validation-results/gmfrm-interior-finish-20261011"
fi_old <- "validation-results/gmfrm-bounded-search-20261011"

# Explicit positive-interior inverse and Jacobian dp/dz. The native Hessian
# stays native: no nonlinear Hessian is transported by congruence alone.
fi_native <- function(z) {
  stopifnot(length(z)==22L, all(is.finite(z)), all(z[17:22]>0))
  c <- z[17:22]; q <- matrix(z[3:14],6,2,byrow=TRUE)
  s <- rowMeans(q)/c; tau <- (q[,1]-q[,2])/(2*c)
  J <- matrix(0,22,22); J[cbind(c(1:2,15:16),c(1:2,15:16))] <- 1
  for (r in 1:6) {
    cols <- 2+2*r-c(1,0)
    J[2+r,cols] <- 1/(2*c[r]); J[8+r,cols] <- c(1,-1)/(2*c[r])
    J[c(2+r,8+r,16+r),16+r] <- c(-s[r],-tau[r],1)/c[r]
  }
  list(parameters=c(z[1:2],s,tau,z[15:16],log(c)), jacobian=J)
}
fi_metric <- function(g,V) {
  square <- drop(crossprod(g,V%*%g))
  stopifnot(is.finite(square),square>=0); sqrt(square)
}
fi_phase <- function(key,seal,calculate,inputs) {
  path <- file.path(fi_out,paste0(key,".rds")); hashes <- tools::md5sum(inputs)
  if (file.exists(path)) {
    x <- readRDS(path)
    stopifnot(identical(x$manifest,seal),identical(x$inputs,hashes)); return(x)
  }
  value <- NULL; error <- ""; warnings <- character()
  timing <- system.time(withCallingHandlers(tryCatch(value <- calculate(),
    error=function(e) error <<- conditionMessage(e)), warning=function(w) {
      warnings <<- c(warnings,conditionMessage(w)); invokeRestart("muffleWarning")
    }))
  x <- list(manifest=seal,inputs=hashes,value=value,error=error,warnings=unique(warnings),
    seconds=unname(timing["elapsed"]))
  temp <- paste0(path,".tmp"); saveRDS(x,temp); stopifnot(file.rename(temp,path))
  cat(key,if(nzchar(error)) error else "saved",x$seconds,"seconds\n"); flush.console(); x
}
fi_tables <- function(m,seal) {
  files <- character()
  rows <- lapply(seq_len(nrow(m$jobs)),function(i) {
    job <- m$jobs[i,]; old <- m$previous$attempts[m$previous$attempts$Key==job$Key,]
    row <- data.frame(job,PreviousCode=old$Code,PreviousCandidate=old$Candidate,
      Status="boundary_route_retained",Passed=FALSE,NLL=old$NLL,ReferenceNLL=NA_real_,
      RawNative=NA_real_,RawNatural=NA_real_,Standardized=NA_real_,MinEigenvalue=NA_real_,
      CovarianceChange=NA_real_,ReferenceNLLDifference=NA_real_,ReferenceGradientDifference=NA_real_,
      TargetError=NA_real_,Evaluations=0L,FinishSeconds=0,ChartSeconds=0,ReferenceSeconds=0,
      Error="",stringsAsFactors=FALSE)
    if (!job$Interior) return(row)
    paths <- file.path(fi_out,paste0(c("finish-","chart-","reference-"),job$Key,".rds"))
    files <<- c(files,paths)
    phases <- lapply(paths,function(p) {
      x <- readRDS(p); stopifnot(identical(x$manifest,seal)); seg_hash_check(x$inputs); x
    })
    f <- phases[[1]]; c <- phases[[2]]; r <- phases[[3]]; a <- f$value$finish
    row$Status <- if (nzchar(f$error)) "finish_error" else a$status
    row$Passed <- isTRUE(r$value$passed)
    if (row$Passed) row$Status <- "reference_qualified_local_candidate"
    else if (!nzchar(f$error) && identical(a$status,"interior_numerical_candidate"))
      row$Status <- if (!isTRUE(c$value$passed)) "chart_unresolved" else "reference_unresolved"
    if (!is.null(a$selected)) row$NLL <- a$selected$evaluation$value
    if (!is.null(a$checks)) {
      row$RawNative <- unname(a$checks["RawScore"])
      if ("StandardizedScore" %in% names(a$checks)) row$Standardized <- unname(a$checks["StandardizedScore"])
      if ("CovarianceChange" %in% names(a$checks)) row$CovarianceChange <- unname(a$checks["CovarianceChange"])
    }
    if (!is.null(a$information)) row$MinEigenvalue <- min(eigen(a$information$hessian,
      symmetric=TRUE,only.values=TRUE)$values)
    if (!is.null(c$value$checks)) {
      row$RawNatural <- unname(c$value$checks["RawNatural"])
      row$TargetError <- unname(c$value$checks["Target"])
    }
    if (!is.null(r$value$checks)) {
      row$ReferenceNLL <- r$value$reference$nll
      row$ReferenceNLLDifference <- max(r$value$checks[c("NLLNative","NLLNatural")])
      row$ReferenceGradientDifference <- max(r$value$checks[c("GradientNative","GradientNatural")])
    }
    if (!is.null(a$evaluations)) row$Evaluations <- a$evaluations
    row[c("FinishSeconds","ChartSeconds","ReferenceSeconds")] <-
      lapply(phases,function(x) x$seconds)
    row$Error <- paste(unique(c(f$error,a$error,c$error,r$error)[nzchar(c(f$error,a$error,c$error,r$error))]),collapse="; ")
    row
  })
  attempts <- do.call(rbind,rows)
  pairs <- do.call(rbind,lapply(split(attempts,interaction(attempts$Case,attempts$Kind,drop=TRUE)),function(x) {
    prior <- subset(m$parent$interior,Case==x$Case[1] & Kind==x$Kind[1])$InteriorNLL
    competitor <- min(prior,if(x$Case[1]=="N20-b09" && x$Kind[1]=="free") m$parent$b09_limit else Inf)
    available <- all(is.finite(x$ReferenceNLL))
    spread <- if (available) diff(range(x$ReferenceNLL)) else NA_real_
    best <- if (available) min(x$ReferenceNLL) else NA_real_
    data.frame(Case=x$Case[1],Kind=x$Kind[1],Interior=all(x$Interior),
      Passes=sum(x$Passed),StartSpread=spread,BestReferenceNLL=best,KnownFeasibleOrLimitNLL=competitor,
      Passed=all(x$Passed) && available && spread<=1e-5 && best<=competitor+1e-5)
  }))
  list(attempts=attempts,pairs=pairs,results=tools::md5sum(files))
}

fi_main <- function(args) {
  stopifnot(length(args)>=1L,args[1] %in% c("prepare","run","summarize","verify"))
  manifest <- file.path(fi_out,"manifest.rds")
  if (args[1]=="prepare") {
    stopifnot(!file.exists(manifest))
    parent <- readRDS(file.path(fi_old,"manifest.rds"))
    previous <- readRDS(file.path(fi_old,"summary.rds"))
    seg_hash_check(parent$inputs); seg_hash_check(parent$sources); seg_hash_check(previous$results)
    tests_path <- file.path(fi_old,"interior-finish-tests.rds"); tests <- readRDS(tests_path)
    seg_hash_check(tests$sources)
    stopifnot(all(tests$tests$failed==0L),!any(tests$tests$error),sum(tests$tests$passed)==68L,
      identical(previous$manifest,tools::md5sum(file.path(fi_old,"manifest.rds"))))
    jobs <- parent$jobs; starts <- list(); jobs$Interior <- FALSE
    for (j in seq_len(nrow(jobs))) {
      a <- readRDS(file.path(fi_old,paste0("fit-",jobs$Key[j],".rds")))$value
      z <- a$selected$parameters
      jobs$Interior[j] <- all(z[17:22]>0)
      if (jobs$Interior[j]) {
        p <- fi_native(z)$parameters
        fit <- seg_parent(parent$plan$Path[match(jobs$Parent[j],parent$plan$Case)])
        if(jobs$Kind[j]=="null") stopifnot(identical(p[15],unname(fit$opt$par[15]+.5)))
        starts[[jobs$Key[j]]] <- p
      } else stopifnot(length(a$active)>0L)
    }
    stopifnot(sum(jobs$Interior)==14L,sum(!jobs$Interior)==6L)
    sources <- unique(c(fi_script,est_script,seg_script,list.files("R",full.names=TRUE),"src/mfrmr.so"))
    inputs <- unique(c(file.path(fi_old,c("manifest.rds","summary.rds","verification.rds")),
      tests_path,names(parent$inputs),names(previous$results)))
    m <- list(parent=parent,previous=previous,jobs=jobs,starts=starts,
      inputs=tools::md5sum(inputs),sources=tools::md5sum(sources),session=sessionInfo(),
      threads=Sys.getenv(c("OMP_NUM_THREADS","OPENBLAS_NUM_THREADS","MKL_NUM_THREADS","VECLIB_MAXIMUM_THREADS")),
      policy=c("Fourteen retained positive-slope endpoints, including previously passing endpoints; six exact-boundary outcomes retained.",
        "One private native Newton proposal only; original fixed Task-t1 coordinate and all old search codes preserved.",
        "Native raw <=1e-4, native mean <=1e-6, current-H standardized score <=1e-4; full unregularized nuisance information.",
        "Native final Hessians at steps1e-4/5e-5 positive definite, inverse residual<=1e-6 and covariance change<=.01.",
        "Working natural score<=1e-4; native/natural NLL agreement<=1e-7 and full gradient agreement<=1e-6; target exact.",
        "Independent 32/64/GK reference only after native and natural checks. NLL<=1e-7, gradient<=1e-6 in both charts.",
        "Independent native raw/mean/standardized and natural raw use the same limits; reference integration/tail gates retained.",
        "Working and reference componentwise integration diagnostics in native covariance metric<=1e-5; not rigorous error bounds.",
        "Two-start spread<=1e-5 and not dominated by known feasible/limiting NLL; no global optimum or coverage claim.",
        "Checkpoint finish, chart and reference separately; no optimizer restarts, iteration extensions, RNG or public dispatch."))
    stopifnot(unname(tools::md5sum(getLoadedDLLs()[["mfrmr"]][["path"]]))==unname(m$sources["src/mfrmr.so"]))
    dir.create(fi_out,recursive=TRUE,showWarnings=FALSE); saveRDS(m,manifest)
    for(s in sources) {
      dest <- file.path(fi_out,"epoch-source",s); dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
      stopifnot(file.copy(s,dest,overwrite=FALSE))
    }
    print(jobs[c("Key","Interior")],row.names=FALSE); return(invisible(NULL))
  }
  m <- readRDS(manifest); seal <- tools::md5sum(manifest)
  seg_hash_check(m$inputs); seg_hash_check(m$sources)
  if (args[1] %in% c("summarize","verify")) {
    tab <- fi_tables(m,seal)
    stopifnot(length(tab$results)==42L)
    path <- file.path(fi_out,"summary.rds")
    if(args[1]=="verify") {
      saved <- readRDS(path); seg_hash_check(saved$results)
      stopifnot(identical(saved,c(list(manifest=seal),tab)),
        identical(unname(tools::md5sum(file.path(fi_out,"epoch-source",names(m$sources)))),unname(m$sources)))
      saveRDS(list(manifest=seal,summary=tools::md5sum(path),session=sessionInfo(),
        note="Fresh saved-result replay with optimization, integration, package loading and RNG disabled."),
        file.path(fi_out,"verification.rds"))
    } else {
      saveRDS(c(list(manifest=seal),tab),path)
      write.csv(tab$attempts,file.path(fi_out,"attempts.csv"),row.names=FALSE)
      write.csv(tab$pairs,file.path(fi_out,"pairs.csv"),row.names=FALSE)
    }
    print(tab$attempts,row.names=FALSE); print(tab$pairs,row.names=FALSE); return(invisible(NULL))
  }
  stopifnot(identical(sessionInfo(),m$session),identical(Sys.getenv(names(m$threads)),m$threads))
  jobs <- m$jobs[m$jobs$Interior,]
  if(length(args)>1L) {
    stopifnot(length(args)==2L,args[2] %in% jobs$Parent); jobs <- jobs[jobs$Parent==args[2],]
  }
  for (j in seq_len(nrow(jobs))) {
    job <- jobs[j,]; path <- file.path(fi_old,paste0("fit-",job$Key,".rds"))
    parent_path <- m$parent$plan$Path[match(job$Parent,m$parent$plan$Case)]
    parent <- seg_parent(parent_path); original <- readRDS(path)$value
    score <- if(job$Draw=="observed") NULL else readRDS(file.path(seg_old,job$Parent,paste0(job$Draw,"-generation.rds")))$value$score
    x <- est_context(parent,score); fixed <- if(job$Kind=="null") 15L else integer()
    target <- if(job$Kind=="null") unname(parent$opt$par[15]+.5) else NULL
    fpath <- file.path(fi_out,paste0("finish-",job$Key,".rds"))
    cpath <- file.path(fi_out,paste0("chart-",job$Key,".rds"))
    f <- fi_phase(paste0("finish-",job$Key),seal,function() {
      p <- m$starts[[job$Key]]; at <- x$evaluator$evaluate(p)
      J <- fi_native(original$selected$parameters)$jacobian
      initial_checks <- c(NLL=abs(at$value-original$selected$evaluation$value),
        Gradient=max(abs(drop(crossprod(J,at$gradient))-original$selected$evaluation$gradient)))
      stopifnot(all(initial_checks<=c(1e-7,1e-6)))
      a <- est_fn("mfrm_gmfrm_finish_interior")(p,x$evaluator,fixed)
      if(!is.null(a$information)) a$information$binding <- list(manifest=seal,
        original_endpoint=tools::md5sum(path),target=target,chart="native",integration="segmented16/32")
      list(finish=a,initial_checks=initial_checks,actual_evaluations=x$evaluator$diagnostics(),
        previous_code=original$optimizer$convergence)
    },c(path,parent_path))
    c <- fi_phase(paste0("chart-",job$Key),seal,function() {
      a <- f$value$finish
      if(nzchar(f$error) || !identical(a$status,"interior_numerical_candidate"))
        return(list(passed=FALSE,skipped="Native finish did not qualify."))
      p <- a$selected$parameters
      idx <- est_fn("build_indices")(x$fit$prep,x$config$step_facet,x$config$slope_facet,
        x$config$interaction_specs,gpcm_spec=x$config$gpcm_spec)
      ev <- est_fn("mfrm_gmfrm_natural_evaluator")(idx,x$config,x$sizes,"rater_intercepts")
      z <- ev$from_native(p); natural <- ev$evaluate(z); map <- fi_native(z)
      V <- a$information$covariance; free <- a$free
      native_error <- drop(crossprod(abs(solve(map$jacobian)),Reduce(`+`,natural$score_error)))
      checks <- c(NLL=abs(natural$value-a$selected$evaluation$value),
        Gradient=max(abs(natural$gradient-drop(crossprod(map$jacobian,a$selected$evaluation$gradient)))),
        RawNatural=max(abs(natural$gradient[free])),Target=if(is.null(target)) 0 else abs(z[15]-target),
        Roundtrip=max(abs(map$parameters-p)),IntegrationDiagnostic=fi_metric(native_error[free],abs(V)))
      list(parameters=z,evaluation=natural,jacobian=map$jacobian,checks=checks,
        passed=all(is.finite(checks)) && all(checks<=c(1e-7,1e-6,1e-4,0,1e-12,1e-5)))
    },c(fpath,path))
    fi_phase(paste0("reference-",job$Key),seal,function() {
      if(nzchar(c$error) || !isTRUE(c$value$passed))
        return(list(passed=FALSE,skipped="Working chart checks did not qualify."))
      a <- f$value$finish; p <- a$selected$parameters; z <- c$value$parameters
      ref <- seg_reference(seg_design(x$fit,p)); gn <- -ref$score; J <- c$value$jacobian
      gz <- drop(crossprod(J,gn)); free <- a$free; V <- a$information$covariance
      er <- Reduce(`+`,lapply(ref$people,function(person) abs(person$score-person$low_score)))
      et <- Reduce(`+`,lapply(ref$people,`[[`,"tail_score_bound"))
      checks <- c(NLLNative=abs(ref$nll-a$selected$evaluation$value),
        NLLNatural=abs(ref$nll-c$value$evaluation$value),
        GradientNative=max(abs(gn-a$selected$evaluation$gradient)),
        GradientNatural=max(abs(gz-c$value$evaluation$gradient)),
        RawNative=max(abs(gn[free])),MeanNative=max(abs(gn[free]))/x$config$n_person,
        StandardizedNative=fi_metric(gn[free],V),RawNatural=max(abs(gz[free])),
        NaturalRule=max(drop(crossprod(abs(J),er))),NaturalTail=max(drop(crossprod(abs(J),et))),
        IntegrationDiagnostic=fi_metric((er+et)[free],abs(V)),Target=if(is.null(target)) 0 else abs(p[15]-target))
      list(reference=ref,native_gradient=gn,natural_gradient=gz,score_error=list(rule=er,tail=et),
        checks=checks,passed=isTRUE(ref$qualified) && all(is.finite(checks)) &&
          all(checks<=c(1e-7,1e-7,1e-6,1e-6,1e-4,1e-6,1e-4,1e-4,1e-6,1e-7,1e-5,0)))
    },c(fpath,cpath,parent_path))
  }
}
if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE)
  if(args[1] %in% c("prepare","run")) pkgload::load_all(quiet=TRUE,compile=FALSE)
  blocked <- function(...) stop("Interior finish attempted forbidden numerical work.")
  for(name in c("optim","nlminb","rnorm","runif","rbinom")) assignInNamespace(name,blocked,ns="stats")
  if(args[1] %in% c("summarize","verify")) {
    for(name in c("optimHess","integrate","uniroot")) assignInNamespace(name,blocked,ns="stats")
    stopifnot(!"mfrmr" %in% loadedNamespaces(),!"pkgload" %in% loadedNamespaces())
  }
  fi_main(args)
}
