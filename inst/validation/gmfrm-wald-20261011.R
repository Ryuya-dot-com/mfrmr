# Independent full-information and Wald handoff, using saved point results.
# run | verify. No response generation, search or finite-difference Hessians.
action <- commandArgs(trailingOnly=TRUE)
stopifnot(length(action)==1L,action %in% c("run","verify"))
directory <- "validation-results/gmfrm-wald-20261011"
previous <- "validation-results/gmfrm-result-20261011/qualified"
check <- function(h) stopifnot(length(h)>0L,!anyNA(h),identical(h,tools::md5sum(names(h))))
pkgload::load_all(quiet=TRUE,compile=FALSE)
fn <- function(n) get(n,asNamespace("mfrmr"))
blocked <- function(...) stop("Generation, optimization and finite-difference information are forbidden.")
for(n in c("rnorm","runif","rbinom","optim","optimHess","nlminb")) assignInNamespace(n,blocked,ns="stats")
manifest_path <- file.path(directory,"manifest.rds")
if(action=="run" && !file.exists(manifest_path)) {
  v <- readRDS(file.path(previous,"verification.rds")); check(v$manifest); check(v$results)
  old <- readRDS(file.path(previous,"manifest.rds")); check(old$sources); check(old$inputs)
  tests <- readRDS(file.path(directory,"tests.rds")); check(tests$sources)
  stopifnot(all(tests$tests$failed==0L),!any(tests$tests$error))
  sources <- unique(c(names(old$sources),"R/core-gmfrm-wald.R","tests/testthat/test-gmfrm-wald.R",
    "tests/testthat/helper-gmfrm-information.R","inst/validation/gmfrm-wald-20261011.R",
    list.files("tests/testthat/fixtures",pattern="^gmfrm-wald.*[.]rds$",full.names=TRUE)))
  m <- list(inputs=tools::md5sum(c(file.path(previous,"verification.rds"),names(v$manifest),names(v$results),
    file.path(directory,"tests.rds"))),sources=tools::md5sum(sources),paths=names(v$results),session=sessionInfo(),
    policy=c("Four unconstrained results: independent Louis 32/64 rules, tail drop 64/96; full covariance comparison <= .01.",
      "All eleven results retain refusals. Same original parameter vector and covariance; no fit, generation or finite-difference Hessian.",
      "Pointwise Wald is the existing experimental reference method, not finite-sample performance qualification."))
  saveRDS(m,manifest_path)
}
m <- readRDS(manifest_path); check(m$inputs); check(m$sources); seal <- tools::md5sum(manifest_path)
if(action=="verify") {
  for(n in c("integrate","uniroot")) assignInNamespace(n,blocked,ns="stats")
  assignInNamespace("mfrm_gmfrm_louis",blocked,ns="mfrmr")
  rows <- lapply(m$paths,function(path) {
    file <- file.path(directory,basename(path)); x <- readRDS(file)
    stopifnot(identical(x$manifest,seal),identical(x$source,tools::md5sum(path)))
    r <- readRDS(path)$result; fn("mfrm_gmfrm_result_check")(r)
    tab <- x$wald$intervals
    stopifnot(identical(x$wald$source_identity,r$identity),!any(tab$CoverageQualified))
    if(x$wald$information$eligible) {
      C <- x$wald$contrasts; value <- drop(C%*%r$run$candidate$native_parameters)
      V <- r$run$candidate$information$covariance
      se <- sqrt(diag(C%*%V%*%t(C))); lower <- value-qnorm(.975)*se; upper <- value+qnorm(.975)*se
      at <- tab$Scale=="exp_native"; lower[at] <- exp(lower[at]); upper[at] <- exp(upper[at])
      stopifnot(max(abs(tab$NativeSE-se))<=1e-12,max(abs(tab$Lower-lower))<=1e-12,
        max(abs(tab$Upper-upper))<=1e-12,all(tab$NumericallyAvailable))
    } else stopifnot(all(!tab$NumericallyAvailable),all(is.na(tab$Lower)),all(is.na(tab$Upper)))
    x$summary
  })
  summary <- do.call(rbind,rows)
  stopifnot(nrow(summary)==11L,sum(summary$Eligible)==4L)
  saveRDS(list(manifest=seal,results=tools::md5sum(file.path(directory,basename(m$paths))),
    summary=summary,session=sessionInfo()),file.path(directory,"verification.rds"))
  print(summary); cat("Fresh saved-result replay passed with all numerical information work disabled.\n")
} else for(path in m$paths) {
  file <- file.path(directory,basename(path))
  if(file.exists(file)) { stopifnot(identical(readRDS(file)$manifest,seal)); next }
  r <- readRDS(path)$result
  seconds <- system.time({
    common <- do.call(fn("mfrm_gmfrm_common_setup"),r$run$specification)
    cfg <- common$config; p <- length(r$run$parameter_names)
    # Include native free coordinates, every expanded owner location, pairwise
    # second-owner severity contrasts, and all component log slopes.
    C <- diag(p); rownames(C) <- r$run$parameter_names
    slices <- fn("build_param_slices")(common$sizes)
    for(owner in r$run$specification$slope_facets) {
      jac <- fn("constraint_jacobian")(cfg$facet_specs[[owner]])
      J <- matrix(0,nrow(jac),p); J[,slices[[owner]]] <- jac
      rownames(J) <- paste0("expanded_location:",owner,":",cfg$facet_levels[[owner]])
      C <- rbind(C,J)
      if(owner==r$run$specification$slope_facets[2L]) {
        pairs <- combn(seq_len(nrow(J)),2)
        contrasts <- t(apply(pairs,2,function(j) J[j[1],]-J[j[2],]))
        rownames(contrasts) <- apply(pairs,2,function(j) paste0("severity:",j[1],"-",j[2]))
        C <- rbind(C,contrasts)
      }
    }
    target <- fn("mfrm_gpcm_product_slope_targets")(rep(0,p),cfg)$components
    J <- target$jacobian; rownames(J) <- paste0("slope:",target$labels)
    C <- rbind(C,J); colnames(C) <- r$run$parameter_names
    exponentiate <- c(rep(FALSE,nrow(C)-nrow(J)),rep(TRUE,nrow(J)))
    x <- fn("mfrm_gmfrm_wald")(r,C,exponentiate)
    checks <- x$information$checks
    summary <- data.frame(Case=sub("[.]rds$","",basename(path)),Eligible=x$information$eligible,
      Targets=nrow(x$intervals),Computed=sum(x$intervals$NumericallyAvailable),
      RetainedCovarianceChange=if(is.null(checks)) NA_real_ else unname(checks["RetainedCovarianceChange"]),
      ReferenceCovarianceChange=if(is.null(checks)) NA_real_ else unname(checks["ReferenceCovarianceChange"]))
  })["elapsed"]
  saveRDS(list(manifest=seal,source=tools::md5sum(path),wald=x,summary=summary,seconds=unname(seconds)),file)
  cat(summary$Case,unname(seconds),"seconds; eligible",summary$Eligible,"computed",summary$Computed,"\n"); flush.console()
}
