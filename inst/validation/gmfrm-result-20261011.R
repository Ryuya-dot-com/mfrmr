# Retained-result handoff: run | verify. No generation, optimization or Hessians.
directory <- "validation-results/gmfrm-result-20261011/qualified"
action <- commandArgs(trailingOnly=TRUE)
stopifnot(length(action)==1L,action %in% c("run","verify"))
check_hash <- function(x) stopifnot(length(x)>0L,!anyNA(x),identical(x,tools::md5sum(names(x))))
pkgload::load_all(quiet=TRUE,compile=FALSE)
fn <- function(n) get(n,asNamespace("mfrmr"))
blocked <- function(...) stop("Refitting, Hessian computation and response generation are outside this allocation.")
for(n in c("optim","optimHess","nlminb","rnorm","runif","rbinom")) assignInNamespace(n,blocked,ns="stats")
if(action=="verify") {
  for(n in c("integrate","uniroot")) assignInNamespace(n,blocked,ns="stats")
  m <- readRDS(file.path(directory,"manifest.rds")); check_hash(m$inputs); check_hash(m$sources)
  files <- file.path(directory,paste0(names(m$runs),".rds"))
  rows <- lapply(files,function(p) {
    a <- readRDS(p); stopifnot(identical(a$manifest,tools::md5sum(file.path(directory,"manifest.rds"))))
    fn("mfrm_gmfrm_result_check")(a$result)
    stopifnot(!a$result$admission$public_fit,!a$result$admission$structural_intervals)
    if(!is.null(a$targets)) stopifnot(identical(fn("mfrm_gmfrm_result_targets")(a$result,a$contrasts),a$targets))
    if(!is.null(a$person)) stopifnot(all(a$person$estimates$Eligible),
      identical(a$person$source_identity,a$result$identity),max(a$moment_difference)<=1e-5)
    a$summary
  })
  summary <- do.call(rbind,rows)
  stopifnot(nrow(summary)==11L,sum(summary$Selected)==8L,sum(summary$Scoring)==4L)
  saveRDS(list(manifest=tools::md5sum(file.path(directory,"manifest.rds")),results=tools::md5sum(files),
    summary=summary,session=sessionInfo()),file.path(directory,"verification.rds"))
  print(summary); cat("Fresh replay passed with likelihood integration, fitting and Hessians disabled.\n")
} else {
  dir.create(directory,showWarnings=FALSE,recursive=TRUE)
  manifest_path <- file.path(directory,"manifest.rds")
  if(!file.exists(manifest_path)) {
    live_path <- "validation-results/gmfrm-run-20261011/live.rds"
    v <- readRDS("validation-results/gmfrm-run-20261011/verification.rds")
    for(h in list(v$manifest,v$boundary_manifest,v$results,v$verifier)) check_hash(h)
    previous_path <- "validation-results/gmfrm-procedure-20261011/review.rds"
    previous <- readRDS(previous_path)
    for(h in list(previous$inputs,previous$sources,previous$phases)) check_hash(h)
    old_path <- "validation-results/gmfrm-interior-finish-20261011/manifest.rds"
    old <- readRDS(old_path); check_hash(old$inputs); check_hash(old$sources)
    tests <- readRDS(file.path(directory,"tests.rds")); check_hash(tests$sources)
    stopifnot(all(tests$tests$failed==0L),!any(tests$tests$error))
    runs <- list(live_binary=readRDS(live_path)$value)
    inputs <- c(live_path,previous_path,old_path,"validation-results/gmfrm-run-20261011/verification.rds",
      names(v$manifest),names(v$boundary_manifest),names(v$results),names(v$verifier),
      names(previous$inputs),names(previous$phases),names(old$inputs),file.path(directory,"tests.rds"))
    for(label in names(previous$procedures)) {
      a <- previous$procedures[[label]]; job <- old$jobs[old$jobs$Case==sub("\\.(free|null)$","",label),][1,]
      parent_path <- old$parent$plan$Path[match(job$Parent,old$parent$plan$Case)]
      parent <- readRDS(parent_path); if(!inherits(parent,"mfrm_fit")) parent <- parent$payload$value
      s <- parent$gmfrm$specification; s$quadrature <- NULL
      if(job$Draw!="observed") {
        p <- file.path("validation-results/gmfrm-null-bootstrap-20261010",job$Parent,paste0(job$Draw,"-generation.rds"))
        s$data[[s$score]] <- readRDS(p)$value$score; inputs <- c(inputs,p)
      }
      problem <- do.call(fn("mfrm_gmfrm_problem"),c(s,list(quadrature=fn("gauss_hermite_normal")(2L))))
      common <- problem$common
      natural <- fn("mfrm_gmfrm_natural_evaluator")(common$idx,common$config,common$sizes,"rater_intercepts")
      a$specification <- s
      a$native_starts <- lapply(a$attempts,function(x) fn("mfrm_gmfrm_procedure_map")(x$start,natural)$parameters)
      a$parameter_names <- names(problem$start)
      a$integration <- runs$live_binary$integration
      a$comparisons <- lapply(a$comparisons,function(x) { x$specification <- s; x })
      a$selection <- fn("mfrm_gmfrm_select_candidates")(lapply(a$attempts,`[[`,"candidate"),
        names(a$attempts),a$reference_nll,a$comparisons)
      stopifnot(identical(a$selection$status,previous$procedures[[label]]$selection$status),
        identical(a$selection$candidate,previous$procedures[[label]]$selection$candidate))
      runs[[label]] <- a; inputs <- c(inputs,parent_path)
    }
    sources <- c(list.files("R",pattern="\\.R$",full.names=TRUE),
      "inst/validation/gmfrm-result-20261011.R","tests/testthat/test-gmfrm-result.R",
      "tests/testthat/fixtures/gmfrm-result.rds","tests/testthat/fixtures/gmfrm-result-held.rds")
    m <- list(runs=runs,inputs=tools::md5sum(unique(inputs)),sources=tools::md5sum(sources),session=sessionInfo(),
      policy="Reuse all fitted points/information/selection; one selected-point reference per result, conditional scores at free selected sources and independent moments. No statistical performance claims.")
    saveRDS(m,manifest_path)
  }
  m <- readRDS(manifest_path); check_hash(m$inputs); check_hash(m$sources)
  seal <- tools::md5sum(manifest_path)
  # Literal response kernel, continuous GK moments in centered coordinates.
  # Neither the scoring response decoder nor its GH rule is used here.
  moments <- function(s,par) {
    model <- fn("mfrm_gmfrm_reference_design")(s,par)
    do.call(rbind,lapply(model$groups,function(rows) {
      p <- fn("mfrm_gmfrm_reference_person")(model,rows)
      integral <- function(power,center=0) {
        f <- function(t) (t-center)^power*exp(p$kernel(p$mode+t)$logjoint-p$peak)
        v <- lapply(list(c(-Inf,0),c(0,Inf)),function(b) stats::integrate(f,b[1],b[2],
          rel.tol=1e-10,abs.tol=1e-12,subdivisions=1000L))
        stopifnot(all(vapply(v,function(x) x$message=="OK",TRUE)))
        c(value=sum(vapply(v,`[[`,0,"value")),error=sum(vapply(v,`[[`,0,"abs.error")))
      }
      mass <- integral(0); first <- integral(1); shift <- first["value"]/mass["value"]
      second <- integral(2,shift)
      stopifnot(mass["value"]>0,max(c(mass["error"],first["error"],second["error"]))/mass["value"]<=1e-8)
      c(Estimate=unname(p$mode+shift),PosteriorSD=unname(sqrt(second["value"]/mass["value"])))
    }))
  }
  for(label in names(m$runs)) {
    path <- file.path(directory,paste0(label,".rds"))
    if(file.exists(path)) { stopifnot(identical(readRDS(path)$manifest,seal)); next }
    seconds <- system.time({
      r <- fn("mfrm_gmfrm_result")(m$runs[[label]])
      selected <- !is.null(r$run$candidate); targets <- C <- person <- independent <- difference <- NULL
      if(selected) {
        p <- length(r$run$parameter_names); C <- diag(p)
        # Every pairwise severity contrast, retaining cross-covariances.
        at <- grep(paste0("^location:",r$run$specification$slope_facets[2],":"),r$run$parameter_names)
        pairs <- combn(at,2)
        C <- rbind(C,t(apply(pairs,2,function(j) replace(replace(numeric(p),j[1],1),j[2],-1))))
        colnames(C) <- r$run$parameter_names
        targets <- fn("mfrm_gmfrm_result_targets")(r,C)
        if(length(r$run$fixed)) stopifnot(all(is.na(targets$LocalVariance))) else
          stopifnot(max(abs(targets$LocalVariance-diag(C%*%r$run$candidate$information$covariance%*%t(C))))<=1e-10)
      }
      if(r$admission$conditional_person_scoring) {
        person <- fn("mfrm_gmfrm_result_persons")(r)
        independent <- moments(r$run$specification,r$run$candidate$native_parameters)
        difference <- abs(as.matrix(person$estimates[c("Estimate","PosteriorSD")])-independent)
        stopifnot(all(person$estimates$Eligible),max(difference)<=1e-5)
      }
      summary <- data.frame(Case=label,Selected=selected,Scoring=r$admission$conditional_person_scoring,
        Targets=if(is.null(targets)) 0L else nrow(targets),Persons=if(is.null(person)) 0L else nrow(person$estimates),
        MaxMomentDifference=if(is.null(difference)) NA_real_ else max(difference))
    })["elapsed"]
    saveRDS(list(manifest=seal,result=r,targets=targets,contrasts=C,person=person,independent=independent,
      moment_difference=difference,summary=summary,seconds=unname(seconds)),path)
    cat(label,unname(seconds),"seconds; selected",selected,"scoring",r$admission$conditional_person_scoring,"\n"); flush.console()
  }
}
