# Requalify saved fits after the small-optimization-residual warning change.
# No response generation, parameter fitting, changed grid or tolerance search.
# Rscript <file> BASELINE OUTPUT
source("inst/validation/gmfrm-sparse-intervals-20260928.R")
pkgload::load_all(quiet=TRUE,compile=FALSE)
args <- commandArgs(trailingOnly=TRUE); baseline <- args[1]; out <- args[2]
stopifnot(length(args)==2L,!dir.exists(out))
manifest <- readRDS(file.path(baseline,"manifest.rds"))
keys <- names(gmfrm_sparse_data(1L,manifest$plan)$cases)
files <- unlist(lapply(seq_len(manifest$plan$repetitions),function(id)
  file.path(baseline,sprintf("%03d-%s.rds",id,keys))))
stopifnot(length(files)==400L,all(file.exists(files)))
original_hash <- manifest$source_hash
hashes <- c(gmfrm_sparse_sources(),tools::md5sum("inst/validation/gmfrm-sparse-reanalysis-20260928.R"))
manifest$baseline_hash <- original_hash; manifest$source_hash <- hashes
manifest$reanalysis <- "Same fits and integration; 1e-4 scaled-score caution and 0.01 refusal"
manifest$session <- capture.output(sessionInfo())
dir.create(out,recursive=TRUE); saveRDS(manifest,file.path(out,"manifest.rds"))
done <- parallel::mclapply(files,function(path) {
  z <- readRDS(path); stopifnot(identical(z$source_hash,original_hash))
  z$original_ci <- z$ci; z$original_error <- z$error
  z$original_warnings <- z$warnings; z$original_seconds <- z$seconds
  z$ci <- NULL; z$error <- NULL; z$warnings <- character()
  z$seconds <- unname(system.time(withCallingHandlers(tryCatch({
    if(!is.null(z$fit)) z$ci <- confint(z$fit,level=manifest$plan$level)
    else z$error <- z$original_error
  },error=function(e) z$error <<- conditionMessage(e)),warning=function(w) {
    z$warnings <<- c(z$warnings,conditionMessage(w)); invokeRestart("muffleWarning")
  }))["elapsed"])
  stopifnot(identical(c(gmfrm_sparse_sources(),
    tools::md5sum("inst/validation/gmfrm-sparse-reanalysis-20260928.R")),hashes))
  z$source_hash <- hashes; z$baseline_hash <- original_hash
  saveRDS(z,file.path(out,basename(path)))
  cat(basename(path),"intervals",if(is.null(z$ci)) 0L else sum(attr(z$ci,"diagnostics")$CIEligible),"\n")
  TRUE
},mc.cores=2L,mc.set.seed=FALSE)
stopifnot(all(vapply(done,isTRUE,logical(1))))
gmfrm_sparse_summary(out)
