# Saved-stage integration only. Run normally, or with "verify" for a fresh replay.
source("inst/validation/gmfrm-interior-finish-20261011.R")
pkgload::load_all(quiet=TRUE,compile=FALSE)
blocked <- function(...) stop("Candidate handoff must not perform fitting or integration.")
for(name in c("optim","optimHess","nlminb","integrate","uniroot","rnorm","runif","rbinom"))
  assignInNamespace(name,blocked,ns="stats")

directory <- "validation-results/gmfrm-candidate-20261011"
path <- file.path(directory,"review.rds")
manifest <- readRDS(file.path(fi_out,"manifest.rds"))
summary <- readRDS(file.path(fi_out,"summary.rds"))
seal <- tools::md5sum(file.path(fi_out,"manifest.rds"))
stopifnot(identical(summary$manifest,seal))
for(h in list(manifest$inputs,manifest$sources,summary$results)) seg_hash_check(h)
stopifnot(identical(unname(tools::md5sum(file.path(fi_out,"epoch-source",names(manifest$sources)))),
  unname(manifest$sources)))
tests <- readRDS(file.path(directory,"tests.rds")); seg_hash_check(tests$sources)
stopifnot(all(tests$tests$failed==0L),!any(tests$tests$error))
for(name in c("verification.rds","verification-arithmetic.rds")) {
  replay <- readRDS(file.path(fi_out,name))
  stopifnot(identical(replay$manifest,seal),
    identical(replay$summary,tools::md5sum(file.path(fi_out,"summary.rds"))))
}
sources <- tools::md5sum(c(names(manifest$sources),"R/core-gmfrm-candidate.R",
  "tests/testthat/test-gmfrm-candidate.R","inst/validation/gmfrm-candidate-20261011.R"))
inputs <- tools::md5sum(c(file.path(fi_out,c("manifest.rds","summary.rds",
  "verification.rds","verification-arithmetic.rds")),file.path(directory,"tests.rds")))

targets <- diag(22); rownames(targets) <- paste0("native-",seq_len(22))
for(pair in combn(1:6,2,simplify=FALSE)) {
  C <- numeric(22); C[2+pair] <- c(1,-1)
  targets <- rbind(targets,C); rownames(targets)[nrow(targets)] <- paste0("severity-",paste(pair,collapse="-"))
}
C <- numeric(22); C[1:2] <- -1; targets <- rbind(targets,`Task-location-3`=C)
C[] <- 0; C[15:16] <- -1; targets <- rbind(targets,`Task-log-slope-3`=C)
candidates <- list(); rows <- target_rows <- list()
for(j in seq_len(nrow(manifest$jobs))) {
  job <- manifest$jobs[j,]
  search_path <- file.path(fi_old,paste0("fit-",job$Key,".rds"))
  search <- readRDS(search_path)$value
  parent <- seg_parent(manifest$parent$plan$Path[match(job$Parent,manifest$parent$plan$Case)])
  if(job$Draw!="observed") {
    score <- readRDS(file.path(seg_old,job$Parent,paste0(job$Draw,"-generation.rds")))$value$score
    parent$prep$data$Score <- parent$prep$data$score_k <- score
    parent$gmfrm$specification$data[[parent$gmfrm$specification$score]] <- score
  }
  config <- parent$config; sizes <- est_fn("build_param_sizes")(config)
  stopifnot(config$n_cat==3L,identical(unname(lengths(config$gpcm_spec$component_levels)),c(3L,6L)))
  idx <- est_fn("build_indices")(parent$prep,config$step_facet,config$slope_facet,
    config$interaction_specs,gpcm_spec=config$gpcm_spec)
  natural <- est_fn("mfrm_gmfrm_natural_evaluator")(idx,config,sizes,"rater_intercepts")
  natural$evaluate <- natural$value <- natural$gradient <- blocked
  phases <- if(job$Interior) lapply(c("finish","chart","reference"),function(stage) {
    x <- readRDS(file.path(fi_out,paste0(stage,"-",job$Key,".rds")))
    stopifnot(identical(x$manifest,seal)); seg_hash_check(x$inputs); x
  }) else NULL
  a <- est_fn("mfrm_gmfrm_candidate")(search,natural,
    if(job$Interior) phases[[1]]$value$finish else NULL,
    if(job$Interior) phases[[2]]$value else NULL,
    if(job$Interior) phases[[3]]$value else NULL)
  stopifnot(identical(a$search,search),natural$diagnostics()$Evaluations==0L)
  if(job$Kind=="null") stopifnot(identical(a$selected$parameters[15],unname(parent$opt$par[15]+.5)))
  before <- subset(summary$attempts,Key==job$Key)
  stopifnot(identical(a$status=="reference_qualified_local_candidate",before$Passed))
  if(job$Interior) stopifnot(identical(a$information,phases[[1]]$value$finish$information),
    identical(a$information$binding$original_endpoint,tools::md5sum(search_path)),
    identical(a$information$binding$manifest,seal))
  candidates[[job$Key]] <- a
  rows[[j]] <- data.frame(Key=job$Key,Parent=job$Parent,Kind=job$Kind,Status=a$status,
    InformationScope=a$information_scope,PreviousCode=search$optimizer$convergence,
    Evaluations=natural$diagnostics()$Evaluations)
  # Independent literal coordinates for the retained three-category design.
  z <- a$selected$parameters; slopes <- z[17:22]; q <- matrix(z[3:14],6,2,byrow=TRUE)
  zero <- which(slopes==0); unsupported <- c(2+zero,8+zero,16+zero)
  native <- c(z[1:2],rowMeans(q)/slopes,(q[,1]-q[,2])/(2*slopes),z[15:16],log(slopes))
  localV <- if(identical(a$information_scope,"joint_unrestricted")) solve(a$information$hessian) else NULL
  for(t in seq_len(nrow(targets))) {
    C <- targets[t,]; result <- est_fn("mfrm_gmfrm_candidate_target")(a,natural,C)
    defined <- !any(C[unsupported]!=0)
    stopifnot(identical(result$defined,defined))
    if(defined) stopifnot(abs(result$value-sum(C[C!=0]*native[C!=0]))<=1e-10*max(1,abs(result$value)))
    if(!is.null(localV)) {
      variance <- drop(crossprod(C,localV%*%C))
      stopifnot(abs(result$local_variance-variance)<=1e-10*max(1,abs(variance)))
    } else stopifnot(is.na(result$local_variance))
    target_rows[[length(target_rows)+1L]] <- data.frame(Key=job$Key,Target=rownames(targets)[t],
      Defined=result$defined,Value=result$value,LocalVariance=result$local_variance,
      VarianceScope=result$variance_scope)
  }
}
rows <- do.call(rbind,rows); target_rows <- do.call(rbind,target_rows)
stopifnot(nrow(rows)==20L,nrow(target_rows)==780L,sum(rows$Evaluations)==0L)
answer <- list(inputs=inputs,sources=sources,manifest=seal,results=summary$results,
  candidates=candidates,attempts=rows,targets=target_rows,session=sessionInfo())
args <- commandArgs(trailingOnly=TRUE)
if(identical(args,"verify")) {
  old <- readRDS(path); seg_hash_check(old$inputs); seg_hash_check(old$sources); seg_hash_check(old$results)
  stopifnot(identical(answer,old))
  saveRDS(list(review=tools::md5sum(path),session=sessionInfo(),
    note="Fresh candidate/target replay; fitting, integration and RNG disabled."),
    file.path(directory,"verification.rds"))
} else {
  stopifnot(length(args)==0L,!file.exists(path))
  saveRDS(answer,path)
}
print(table(rows$Status,rows$InformationScope))
print(table(target_rows$Defined,target_rows$VarianceScope))
cat("All 20 endpoints and 780 target checks reconciled without likelihood evaluations.\n")
