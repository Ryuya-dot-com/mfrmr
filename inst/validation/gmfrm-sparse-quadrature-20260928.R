# Same-data follow-up of all 100 common-Person, SD=1 replicates.
# Keep the public neutral start, score tolerance and iteration cap unchanged.
# Rscript <file> BASELINE OUTPUT NODES
source("inst/validation/gmfrm-sparse-intervals-20260928.R")
pkgload::load_all(quiet=TRUE,compile=FALSE)
args <- commandArgs(trailingOnly=TRUE)
stopifnot(length(args)==3L)
baseline <- args[1]; out <- args[2]; nodes <- as.integer(args[3])
stopifnot(is.finite(nodes),nodes>=61L,!dir.exists(out))
manifest <- readRDS(file.path(baseline,"manifest.rds"))
original_hash <- manifest$source_hash
hashes <- c(gmfrm_sparse_sources(),tools::md5sum("inst/validation/gmfrm-sparse-quadrature-20260928.R"))
manifest$baseline_hash <- original_hash; manifest$source_hash <- hashes
manifest$case_keys <- "common_persons-1"
manifest$followup <- paste("Public neutral-start refits at",nodes,
  "nodes; original score tolerance/iteration cap; no new data")
manifest$plan$quad_points <- nodes
manifest$session <- capture.output(sessionInfo())
dir.create(out,recursive=TRUE); saveRDS(manifest,file.path(out,"manifest.rds"))
files <- file.path(baseline,sprintf("%03d-common_persons-1.rds",seq_len(manifest$plan$repetitions)))
stopifnot(all(file.exists(files)))
done <- parallel::mclapply(files,function(path) {
  old <- readRDS(path); stopifnot(identical(old$source_hash,original_hash))
  z <- old; z$original_fit <- old$fit; z$original_ci <- old$ci
  z$original_seconds <- old$seconds; z$fit <- z$ci <- z$error <- NULL; z$warnings <- character()
  replay <- old$fit$config$replay_inputs
  replay$package_version <- NULL; replay$data <- old$case$data; replay$quad_points <- nodes
  stopifnot(replay$em_score_tol==manifest$plan$em_score_tol,replay$maxit==manifest$plan$maxit)
  z$seconds <- unname(system.time(withCallingHandlers(tryCatch({
    z$fit <- do.call(fit_mfrm,replay)
    z$ci <- confint(z$fit,level=manifest$plan$level)
  },error=function(e) z$error <<- conditionMessage(e)),warning=function(w) {
    z$warnings <<- c(z$warnings,conditionMessage(w)); invokeRestart("muffleWarning")
  }))["elapsed"])
  stopifnot(identical(c(gmfrm_sparse_sources(),
    tools::md5sum("inst/validation/gmfrm-sparse-quadrature-20260928.R")),hashes))
  z$source_hash <- hashes; z$baseline_hash <- original_hash
  saveRDS(z,file.path(out,basename(path)))
  cat(basename(path),"converged",isTRUE(z$fit$summary$Converged),"intervals",
    if(is.null(z$ci)) 0L else sum(attr(z$ci,"diagnostics")$CIEligible),"seconds",z$seconds,"\n")
  TRUE
},mc.cores=2L,mc.set.seed=FALSE)
stopifnot(all(vapply(done,isTRUE,logical(1))))
gmfrm_sparse_summary(out)
