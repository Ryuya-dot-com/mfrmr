# Selection replay only; no package loading, optimization or integration.
source("R/core-gmfrm-selection.R")
blocked <- function(...) stop("Saved candidate selection attempted numerical model work.")
for(name in c("optim","optimHess","nlminb","integrate","uniroot","rnorm","runif","rbinom"))
  assignInNamespace(name,blocked,ns="stats")
stopifnot(!"mfrmr" %in% loadedNamespaces(),!"pkgload" %in% loadedNamespaces())
check_hash <- function(h) stopifnot(identical(h,tools::md5sum(names(h))))
directory <- "validation-results/gmfrm-selection-20261011"
candidate_dir <- "validation-results/gmfrm-candidate-20261011"
interior_dir <- "validation-results/gmfrm-interior-finish-20261011"
bounded_dir <- "validation-results/gmfrm-bounded-search-20261011"
face_dir <- "validation-results/gmfrm-rater-face-20261011"
envelope_dir <- "validation-results/gmfrm-zero-envelope-20261011"
candidate_path <- file.path(candidate_dir,"review.rds")
retained <- readRDS(candidate_path); replay <- readRDS(file.path(candidate_dir,"verification.rds"))
stopifnot(identical(replay$review,tools::md5sum(candidate_path)))
manifest <- readRDS(file.path(interior_dir,"manifest.rds"))
summary <- readRDS(file.path(interior_dir,"summary.rds"))
stopifnot(identical(retained$manifest,tools::md5sum(file.path(interior_dir,"manifest.rds"))),
  identical(summary$manifest,retained$manifest),identical(summary$results,retained$results))
for(h in list(retained$inputs,retained$sources,retained$results,manifest$inputs,
              manifest$sources,manifest$previous$results)) check_hash(h)
face <- readRDS(file.path(face_dir,"summary.rds"))
face_manifest <- readRDS(file.path(face_dir,"manifest.rds"))
face_replay <- readRDS(file.path(face_dir,"verification.rds"))
stopifnot(identical(face$manifest,tools::md5sum(file.path(face_dir,"manifest.rds"))),
  identical(face_replay$manifest,face$manifest),identical(face_replay$results,face$results),
  identical(face_replay$inputs,face_manifest$inputs),identical(face_replay$sources,face_manifest$sources))
check_hash(face$results)
envelope <- readRDS(file.path(envelope_dir,"results.rds"))
envelope_replay <- readRDS(file.path(envelope_dir,"verification.rds"))
check_hash(envelope$inputs); check_hash(envelope$sources)
stopifnot(identical(envelope_replay$results,tools::md5sum(file.path(envelope_dir,"results.rds"))),
  identical(manifest$parent$interior,envelope$table),
  abs(manifest$parent$b09_limit-min(envelope$paths$NLL[is.infinite(envelope$paths$Time)]))<1e-7)
tests <- readRDS(file.path(directory,"tests.rds")); check_hash(tests$sources)
stopifnot(all(tests$tests$failed==0L),!any(tests$tests$error))
sources <- tools::md5sum(c(names(retained$sources),"R/core-gmfrm-selection.R",
  "tests/testthat/test-gmfrm-selection.R","inst/validation/gmfrm-selection-20261011.R"))
input_paths <- unique(c(candidate_path,file.path(candidate_dir,"verification.rds"),
  file.path(interior_dir,c("manifest.rds","summary.rds")),names(manifest$previous$results),
  file.path(face_dir,c("manifest.rds","summary.rds","verification.rds")),names(face$results),
  file.path(envelope_dir,c("results.rds","verification.rds")),file.path(directory,"tests.rds")))
make_comparison <- function(kind,nll,fixed=integer(),values=numeric(),evidence)
  list(kind=kind,nll=nll,fixed=fixed,values=values,verified=TRUE,evidence=evidence)
groups <- split(manifest$jobs,interaction(manifest$jobs$Case,manifest$jobs$Kind,drop=TRUE))
answers <- rows <- reference_errors <- list()
for(label in names(groups)) {
  jobs <- groups[[label]]; starts <- c("retained","neutral")
  stopifnot(nrow(jobs)==2L,setequal(jobs$Start,starts))
  jobs <- jobs[match(starts,jobs$Start),]
  case <- jobs$Case[1]; kind <- jobs$Kind[1]
  parent_path <- manifest$parent$plan$Path[match(jobs$Parent[1],manifest$parent$plan$Case)]
  parent <- readRDS(parent_path); if(!inherits(parent,"mfrm_fit")) parent <- parent$payload$value
  original_null <- unname(parent$opt$par[15]+.5)
  candidates <- setNames(retained$candidates[jobs$Key],starts)
  refs <- setNames(rep(NA_real_,2),starts)
  for(i in seq_along(starts)) {
    a <- candidates[[i]]
    if(jobs$Interior[i]) refs[i] <- a$stages$reference$reference$nll else {
      path <- file.path(bounded_dir,paste0("reference-",jobs$Key[i],".rds"))
      old <- readRDS(path); stopifnot(identical(old$manifest,manifest$previous$manifest))
      check_hash(old$inputs)
      if(!nzchar(old$error) && !is.null(old$value$reference$nll)) {
        stopifnot(is.finite(old$value$checks["NLL"]),old$value$checks["NLL"]<=1e-7)
        refs[i] <- old$value$reference$nll
      }
      reference_errors[[jobs$Key[i]]] <- old$error
    }
  }
  comparisons <- list()
  witness <- subset(manifest$parent$interior,Case==case)
  for(i in seq_len(nrow(witness))) {
    w <- witness[i,]; constrained <- grepl("-null-",w$InteriorKey,fixed=TRUE)
    comparisons[[paste0("earlier-",w$Kind)]] <- make_comparison("feasible_point",w$InteriorNLL,
      if(constrained) 15L else integer(),if(constrained) original_null else numeric(),
      list(key=w$InteriorKey,source=file.path(envelope_dir,"results.rds")))
  }
  if(case=="N20-b09") comparisons$b09_free_limit <- make_comparison("feasible_limit",
    manifest$parent$b09_limit,evidence=list(source=file.path(envelope_dir,"results.rds"),
      detail="Feasible b09-free limiting path; no attained finite parameter vector."))
  if(case=="N20-b19") for(path in names(face$results)) {
    f <- readRDS(path)
    stopifnot(identical(f$manifest,face$manifest),identical(f$status,"local_face_candidate"),
      f$target_error==0,f$coordinates[15]==original_null)
    comparisons[[paste0("rater5-zero-",f$start)]] <- make_comparison("feasible_point",f$value$value,
      15L,original_null,list(source=path,detail="Finite intercept-chart point, not a native interior candidate."))
  }
  bound <- unique(witness$SaturatedLowerNLL); stopifnot(length(bound)==1L)
  comparisons$common_zero_family <- make_comparison("family_lower_bound",bound,
    evidence=list(source=file.path(envelope_dir,"results.rds"),
      detail="Saturated independent Task-by-Rater bound on the exact common-zero family only."))
  answer <- mfrm_gmfrm_select_candidates(candidates,starts,refs,comparisons)
  fixed <- if(kind=="null") 15L else integer()
  stopifnot(identical(answer$fixed,fixed),
    identical(unname(answer$fixed_values),if(kind=="null") original_null else numeric()))
  expected <- subset(summary$pairs,Case==case & Kind==kind)
  stopifnot(nrow(expected)==1L,identical(answer$status=="local_candidate_selected",expected$Passed))
  if(!is.na(answer$selected)) stopifnot(identical(answer$candidate,candidates[[answer$selected]]))
  # Arithmetic check independent of the selector: bounds never enter this minimum.
  acceptable <- Filter(function(x) x$kind!="family_lower_bound" &&
    (kind=="free" || (15L %in% x$fixed && x$values[match(15L,x$fixed)]==original_null)),comparisons)
  known <- min(c(refs[is.finite(refs)],vapply(acceptable,`[[`,0,"nll")))
  stopifnot(identical(answer$best_known_nll,known),
    identical(answer$comparisons$FamilyExcluded[answer$comparisons$Name=="common_zero_family"],bound-known>1e-6))
  if(kind=="null" && case=="N20-b09") stopifnot(
    !answer$comparisons$Applicable[answer$comparisons$Name=="b09_free_limit"])
  answers[[label]] <- answer
  rows[[label]] <- data.frame(Case=case,Kind=kind,Status=answer$status,Selected=answer$selected,
    Qualified=sum(answer$attempts$Qualified),ReferenceValues=sum(is.finite(refs)),
    StartSpread=answer$start_spread,BestKnownNLL=answer$best_known_nll,
    CommonZeroExcluded=bound-known>1e-6,
    EndpointsWithBetterWitness=sum(refs[is.finite(refs)]>known+1e-5))
}
rows <- do.call(rbind,rows)
stopifnot(nrow(rows)==10L,sum(rows$Status=="local_candidate_selected")==7L,
  sum(rows$CommonZeroExcluded)==8L,sum(nzchar(unlist(reference_errors)))==2L)
result <- list(inputs=tools::md5sum(input_paths),sources=sources,results=retained$results,
  selections=answers,summary=rows,reference_errors=reference_errors,session=sessionInfo())
path <- file.path(directory,"review.rds"); args <- commandArgs(trailingOnly=TRUE)
if(identical(args,"verify")) {
  previous <- readRDS(path)
  for(h in list(previous$inputs,previous$sources,previous$results)) check_hash(h)
  stopifnot(identical(previous,result))
  saveRDS(list(review=tools::md5sum(path),session=sessionInfo(),
    note="Fresh selection replay without package loading, fitting, integration or generation."),
    file.path(directory,"verification.rds"))
} else {
  stopifnot(length(args)==0L,!file.exists(path)); saveRDS(result,path)
}
print(rows,row.names=FALSE,digits=12)
cat("All ten comparisons reconciled, including two unavailable reference values; no numerical model work.\n")
