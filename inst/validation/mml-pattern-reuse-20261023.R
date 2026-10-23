# Exact adaptive-pattern reuse: paired work at the same parameters and Q31.
# Run from development after loading the current package. The retained source
# before this change supplies the baseline; no external fits are repeated.
mml_pattern_reuse_comparison <- function(out,
    baseline="tmp/mml-pattern-reuse-20261023/before/core-adaptive-quadrature.R",
    evidence="tmp/conquest-gpcm-mml-20261023") {
  old <- new.env(parent=asNamespace("mfrmr")); sys.source(baseline,old)
  plans <- data.frame(case=c("unconditional","unconditional","regression",
      "regression_missing","unconditional","regression","regression"),
    persons=c(24L,240L,240L,240L,1920L,1920L,1920L),
    unique_covariates=c(FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE))
  results <- details <- list()
  for(i in seq_len(nrow(plans))) {
    plan <- plans[i,]; cat("Plan",i,plan$case,plan$persons,"\n"); flush.console()
    fit <- readRDS(file.path(evidence,plan$case,"native.rds"))$fit
    cfg <- fit$config; par <- fit$opt$par; sizes <- mfrmr:::build_param_sizes(cfg)
    idx <- mfrmr:::build_indices(fit$prep,cfg$step_facet,cfg$slope_facet,cfg$interaction_specs)
    n0 <- cfg$n_person
    if(plan$persons<n0) {
      idx <- mfrmr:::mfrmr_subset_observation_indices(idx,which(idx$person<=plan$persons))
      cfg$population_spec$person_lookup <- head(cfg$population_spec$person_lookup,plan$persons)
    } else if(plan$persons>n0) {
      copies <- plan$persons/n0; stopifnot(copies==floor(copies))
      nrow0 <- length(idx$person)
      idx <- mfrmr:::mfrmr_subset_observation_indices(idx,rep(seq_len(nrow0),copies))
      idx$person <- idx$person+rep((0:(copies-1))*n0,each=nrow0)
      pop <- cfg$population_spec
      pop$design_matrix <- pop$design_matrix[rep(pop$person_lookup,copies),,drop=FALSE]
      pop$person_lookup <- seq_len(plan$persons)
      if(plan$unique_covariates) pop$design_matrix[,2] <- pop$design_matrix[,2]+
        rep((0:(copies-1))*.01,each=n0)
      cfg$population_spec <- pop
    }
    cfg$n_person <- plan$persons
    groups <- mfrmr:::mfrmr_mml_person_design_groups(idx,cfg,include_responses=TRUE)
    times <- values <- list()
    for(repetition in 1:3) for(engine in if(repetition%%2) c("before","after") else c("after","before")) {
      make <- if(engine=="before") old$mfrmr_make_adaptive_mml_evaluator else
        mfrmr:::mfrmr_make_adaptive_mml_evaluator
      gc()
      setup_time <- system.time(evaluate <- make(idx,cfg,sizes,31L))[["elapsed"]]
      evaluation_time <- system.time(answer <- evaluate(par))[["elapsed"]]
      times[[length(times)+1L]] <- data.frame(repetition,engine,setup_time,evaluation_time)
      values[[engine]] <- answer
    }
    difference <- c(objective=abs(values$before$value-values$after$value),
      gradient=max(abs(values$before$gradient-values$after$gradient)))
    stopifnot(all(difference<1e-8))
    times <- do.call(rbind,times)
    results[[i]] <- data.frame(plan=i,plan,
      unique_patterns=groups$unique_person_designs,
      objective_difference=difference["objective"],gradient_difference=difference["gradient"],
      setup_before=median(times$setup_time[times$engine=="before"]),
      setup_after=median(times$setup_time[times$engine=="after"]),
      evaluation_before=median(times$evaluation_time[times$engine=="before"]),
      evaluation_after=median(times$evaluation_time[times$engine=="after"]))
    details[[i]] <- list(plan=plan,idx=idx,config=cfg,sizes=sizes,par=par,times=times,values=values)
    write.csv(do.call(rbind,results),file.path(out,"evaluation-comparison.csv"),row.names=FALSE)
    saveRDS(details,file.path(out,"evaluation-details.rds"))
  }
  invisible(results)
}

mml_pattern_reuse_fit_comparison <- function(out,
    baseline="tmp/mml-pattern-reuse-20261023/before/core-adaptive-quadrature.R",
    evidence="tmp/conquest-gpcm-mml-20261023") {
  old <- new.env(parent=asNamespace("mfrmr")); sys.source(baseline,old)
  saved <- readRDS(file.path(evidence,"regression","native.rds"))
  args <- saved$args
  # Controlled workload replication, not independent recovery replications.
  args$data <- do.call(rbind,lapply(1:4,function(i) {
    d <- saved$args$data; d$Person <- paste0(d$Person,"_",i); d
  }))
  args$person_data <- do.call(rbind,lapply(1:4,function(i) {
    d <- saved$args$person_data; d$Person <- paste0(d$Person,"_",i); d
  }))
  args$reltol <- 1e-13
  results <- list()
  for(engine in c("before","after")) {
    destination <- file.path(out,paste0("fit-",engine,".rds"))
    if(file.exists(destination)) { results[[engine]] <- readRDS(destination); next }
    cat("Full fit",engine,"\n"); flush.console()
    warnings <- character()
    run <- function() withCallingHandlers(tryCatch(do.call(mfrmr::fit_mfrm,args),error=identity),
      warning=function(w) { warnings <<- c(warnings,conditionMessage(w)); invokeRestart("muffleWarning") })
    gc()
    elapsed <- system.time(fit <- if(engine=="before") testthat::with_mocked_bindings(run(),
      mfrmr_make_adaptive_mml_evaluator=old$mfrmr_make_adaptive_mml_evaluator,.package="mfrmr") else run())[["elapsed"]]
    results[[engine]] <- list(fit=fit,args=args,elapsed=elapsed,warnings=warnings)
    saveRDS(results[[engine]],destination)
  }
  stopifnot(!inherits(results$before$fit,"error"),!inherits(results$after$fit,"error"))
  a <- results$before$fit; b <- results$after$fit
  stopifnot(identical(a$config$mml_accuracy$status,"criteria_met"),
    identical(b$config$mml_accuracy$status,"criteria_met"),
    identical(a$readiness$fit$ReasonCodes,b$readiness$fit$ReasonCodes),
    !a$summary$InferenceReady,!b$summary$InferenceReady)
  differences <- c(objective=abs(a$opt$value-b$opt$value),
    parameter=max(abs(a$opt$par-b$opt$par)),
    eap=max(abs(a$facets$person$Estimate-b$facets$person$Estimate)),
    sd=max(abs(a$facets$person$PosteriorSD-b$facets$person$PosteriorSD)))
  stopifnot(differences["objective"]<1e-7,all(differences[-1]<1e-5))
  write.csv(data.frame(engine=names(results),elapsed=vapply(results,`[[`,0,"elapsed")),
    file.path(out,"fit-times.csv"),row.names=FALSE)
  write.csv(data.frame(metric=names(differences),difference=unname(differences)),
    file.path(out,"fit-differences.csv"),row.names=FALSE)
  invisible(results)
}

# Fresh-session check against installed code, without refitting saved evidence.
mml_pattern_reuse_replay <- function(out,evidence="tmp/conquest-gpcm-mml-20261023") {
  paths <- c(updated=file.path(out,"fit-after.rds"),
    setNames(file.path(evidence,c("unconditional","regression","regression_missing"),"native.rds"),
      c("unconditional","regression","regression_missing")))
  checks <- lapply(names(paths),function(name) {
    saved <- readRDS(paths[[name]]); fit <- saved$fit
    cfg <- fit$config; sizes <- mfrmr:::build_param_sizes(cfg)
    idx <- mfrmr:::build_indices(fit$prep,cfg$step_facet,cfg$slope_facet,cfg$interaction_specs)
    value <- mfrmr:::mfrmr_make_adaptive_mml_evaluator(idx,cfg,sizes,
      cfg$estimation_control$quad_points)(fit$opt$par)
    error <- abs(value$value-fit$opt$value)
    ids <- head(as.character(fit$facets$person$Person),3)
    rows <- saved$args$data[saved$args$data$Person %in% ids,]
    scored <- mfrmr::predict_mfrm_units(fit,rows,person_data=saved$args$person_data,
      readiness_policy="review")
    expected <- fit$facets$person[match(scored$estimates$Person,fit$facets$person$Person),]
    eap_error <- max(abs(scored$estimates$Estimate-expected$Estimate))
    sd_error <- max(abs(scored$estimates$SD-expected$PosteriorSD))
    stopifnot(error<1e-7,eap_error<1e-8,sd_error<1e-8,
      !fit$summary$InferenceReady,!scored$settings$source_inference_ready)
    data.frame(case=name,nll_error=error,eap_error=eap_error,sd_error=sd_error,
      inference_ready=fit$summary$InferenceReady)
  })
  checks <- do.call(rbind,checks)
  write.csv(checks,file.path(out,"installed-replay.csv"),row.names=FALSE)
  checks
}
