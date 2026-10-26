# Bound retained-stage replay of the new orchestration; no new model evaluation.
source("inst/validation/gmfrm-interior-finish-20261011.R")
pkgload::load_all(quiet=TRUE,compile=FALSE)
blocked <- function(...) stop("Procedure replay attempted new numerical model work.")
for(name in c("optim","optimHess","nlminb","integrate","uniroot","rnorm","runif","rbinom"))
  assignInNamespace(name,blocked,ns="stats")
directory <- "validation-results/gmfrm-procedure-20261011"
selection_path <- "validation-results/gmfrm-selection-20261011/review.rds"
previous <- readRDS(selection_path)
selection_replay <- readRDS("validation-results/gmfrm-selection-20261011/verification.rds")
stopifnot(identical(selection_replay$review,tools::md5sum(selection_path)))
manifest <- readRDS(file.path(fi_out,"manifest.rds")); seal <- tools::md5sum(file.path(fi_out,"manifest.rds"))
for(h in list(previous$inputs,previous$sources,previous$results,manifest$inputs,
              manifest$sources,manifest$previous$results)) seg_hash_check(h)
tests <- readRDS(file.path(directory,"tests.rds")); seg_hash_check(tests$sources)
stopifnot(all(tests$tests$failed==0L),!any(tests$tests$error))
new_sources <- c("R/core-gmfrm-procedure.R","tests/testthat/test-gmfrm-procedure.R",
  "inst/validation/gmfrm-procedure-20261011.R")
sources <- tools::md5sum(unique(c(names(previous$sources),new_sources)))
inputs <- tools::md5sum(c(selection_path,"validation-results/gmfrm-selection-20261011/verification.rds",
  file.path(fi_out,"manifest.rds"),file.path(directory,"tests.rds")))

# Only the costly kernels are replaced by exact input-bound saved calls.
# The orchestration, generic chart mapping, checks, handoff and selection run.
env <- new.env(parent=asNamespace("mfrmr"))
sys.source("R/core-gmfrm-procedure.R",env)
groups <- split(manifest$jobs,interaction(manifest$jobs$Case,manifest$jobs$Kind,drop=TRUE))
answers <- rows <- list(); phase_paths <- character()
for(label in names(groups)) {
  jobs <- groups[[label]]; jobs <- jobs[match(c("retained","neutral"),jobs$Start),]
  parent <- seg_parent(manifest$parent$plan$Path[match(jobs$Parent[1],manifest$parent$plan$Case)])
  if(jobs$Draw[1]!="observed") {
    score <- readRDS(file.path(seg_old,jobs$Parent[1],paste0(jobs$Draw[1],"-generation.rds")))$value$score
    parent$prep$data$Score <- parent$prep$data$score_k <- score
    parent$gmfrm$specification$data[[parent$gmfrm$specification$score]] <- score
  }
  config <- parent$config; sizes <- est_fn("build_param_sizes")(config)
  idx <- est_fn("build_indices")(parent$prep,config$step_facet,config$slope_facet,
    config$interaction_specs,gpcm_spec=config$gpcm_spec)
  natural <- est_fn("mfrm_gmfrm_natural_evaluator")(idx,config,sizes,"rater_intercepts")
  fixed <- if(jobs$Kind[1]=="null") 15L else integer()
  searches <- phases <- list()
  for(i in seq_len(nrow(jobs))) {
    key <- jobs$Key[i]; name <- jobs$Start[i]
    path <- file.path(fi_old,paste0("fit-",key,".rds")); phase_paths <- c(phase_paths,path)
    old <- readRDS(path); stopifnot(identical(old$manifest,manifest$previous$manifest))
    if(length(old$inputs)) seg_hash_check(old$inputs)
    searches[[name]] <- old$value
    stage_names <- if(jobs$Interior[i]) c("finish","chart","reference") else "reference"
    phases[[name]] <- setNames(lapply(stage_names,function(stage) {
      path <- file.path(if(jobs$Interior[i]) fi_out else fi_old,paste0(stage,"-",key,".rds"))
      phase_paths <<- c(phase_paths,path); a <- readRDS(path)
      stopifnot(identical(a$manifest,if(jobs$Interior[i]) seal else manifest$previous$manifest))
      seg_hash_check(a$inputs); a
    }),stage_names)
  }
  starts <- setNames(manifest$parent$starts[jobs$Key],jobs$Start)
  # These are the original natural-coordinate starts, already bound by the manifest.
  active <- NULL; calls <- c(search=0L,initial=0L,finish=0L,chart=0L,reference=0L)
  env$mfrm_gmfrm_bounded_search <- function(start,evaluator,fixed,maxit) {
    name <- names(starts)[vapply(starts,identical,TRUE,start)]
    stopifnot(length(name)==1L,identical(fixed,searches[[name]]$fixed),identical(maxit,400L))
    active <<- name; calls["search"] <<- calls["search"]+1L
    stopifnot(max(abs(searches[[name]]$initial$parameters-start))<=1e-12)
    searches[[name]]
  }
  native <- list(optimization_scale=config$n_person,evaluate=function(p) {
    f <- phases[[active]]$finish$value$finish
    stopifnot(!is.null(f),max(abs(p-f$initial$parameters))<=1e-12)
    calls["initial"] <<- calls["initial"]+1L; f$initial$evaluation
  })
  env$mfrm_gmfrm_finish_interior <- function(start,evaluator,fixed) {
    f <- phases[[active]]$finish$value$finish
    stopifnot(!is.null(f),max(abs(start-f$initial$parameters))<=1e-12,identical(fixed,f$fixed))
    calls["finish"] <<- calls["finish"]+1L; f
  }
  natural$evaluate <- function(z) {
    c <- phases[[active]]$chart$value
    stopifnot(!is.null(c),identical(z,c$parameters))
    calls["chart"] <<- calls["chart"]+1L; c$evaluation
  }
  natural$value <- natural$gradient <- blocked
  reference <- function(z,p) {
    f <- phases[[active]]$finish$value$finish; r <- phases[[active]]$reference
    expected <- if(is.null(f)) searches[[active]]$selected$parameters else phases[[active]]$chart$value$parameters
    stopifnot(identical(z,expected),identical(p,if(is.null(f)) NULL else f$selected$parameters))
    calls["reference"] <<- calls["reference"]+1L
    if(nzchar(r$error)) stop(r$error)
    r$value
  }
  answer <- env$mfrm_gmfrm_procedure(starts,native,natural,reference,fixed,
    previous$selections[[label]]$evidence,maxit=400L)
  before <- previous$selections[[label]]
  stopifnot(identical(answer$status,before$status),
    identical(answer$selection[names(before)!="candidate"],before[names(before)!="candidate"]),
    identical(calls, c(search=2L,initial=as.integer(sum(jobs$Interior)),finish=as.integer(sum(jobs$Interior)),
      chart=as.integer(sum(jobs$Interior)),reference=2L)),natural$diagnostics()$Evaluations==0L)
  for(i in seq_len(nrow(jobs))) {
    name <- jobs$Start[i]; a <- answer$attempts[[name]]
    stopifnot(identical(a$candidate$search,searches[[name]]))
    if(jobs$Interior[i]) {
      f <- phases[[name]]$finish$value$finish
      stopifnot(identical(a$candidate$information,f$information),
        identical(a$candidate$native_parameters,f$selected$parameters),
        max(abs(a$stages$chart$value$checks-phases[[name]]$chart$value$checks))<1e-10,
        max(abs(a$stages$reference$value$checks-phases[[name]]$reference$value$checks))<1e-10)
    } else stopifnot(is.null(a$candidate$information),!"finish" %in% names(a$stages))
    if(jobs$Kind[i]=="null") stopifnot(identical(a$candidate$selected$parameters[15],unname(parent$opt$par[15]+.5)))
    expected_error <- phases[[name]]$reference$error
    if(nzchar(expected_error)) stopifnot(identical(a$failed_stages,"reference"),
      identical(conditionMessage(a$stages$reference$error),expected_error)) else stopifnot(!length(a$failed_stages))
  }
  answers[[label]] <- answer
  rows[[label]] <- data.frame(Case=jobs$Case[1],Kind=jobs$Kind[1],Status=answer$status,
    Selected=answer$selection$selected,SearchesReused=calls["search"],FinishesReused=calls["finish"],
    ReferenceErrors=sum(vapply(answer$attempts,function(a) "reference" %in% a$failed_stages,TRUE)))
}
rows <- do.call(rbind,rows)
stopifnot(sum(rows$SearchesReused)==20L,sum(rows$FinishesReused)==14L,
  sum(rows$Status=="local_candidate_selected")==7L,sum(rows$ReferenceErrors)==2L)
result <- list(inputs=inputs,sources=sources,phases=tools::md5sum(unique(phase_paths)),
  procedures=answers,summary=rows,session=sessionInfo())
path <- file.path(directory,"review.rds"); args <- commandArgs(trailingOnly=TRUE)
if(identical(args,"verify")) {
  saved <- readRDS(path)
  for(h in list(saved$inputs,saved$sources,saved$phases)) seg_hash_check(h)
  stopifnot(identical(saved,result),identical(unname(tools::md5sum(file.path(directory,"epoch-source",new_sources))),
    unname(sources[new_sources])))
  saveRDS(list(review=tools::md5sum(path),session=sessionInfo(),
    note="Fresh orchestration replay; expensive kernels replaced by exact input-bound saved calls; all new numerical model work blocked."),
    file.path(directory,"verification.rds"))
} else {
  stopifnot(length(args)==0L,!file.exists(path))
  for(s in new_sources) {
    dest <- file.path(directory,"epoch-source",s); dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
    stopifnot(file.copy(s,dest,overwrite=FALSE))
  }
  saveRDS(result,path)
}
print(rows,row.names=FALSE)
cat("All ten complete routes reconciled; no new likelihood, optimizer, Hessian or generated response.\n")
