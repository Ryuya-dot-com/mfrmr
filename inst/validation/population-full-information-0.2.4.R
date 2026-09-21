# Repository-only full-coordinate audit; the companion record fixes scope.
source('inst/validation/population-variance-profile-0.2.4.R')

population_full_reference <- function(case, par) {
  population_profile_reference(case, par, exp(tail(par, 1)))
}

population_full_information <- function(directory) {
  pkgload::load_all('.', quiet = TRUE)
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  inputs <- paste0('inst/validation/', c('population-variance-profile-evidence-0.2.4.rds',
    'population-variance-profile-refinement-evidence-0.2.4.rds',
    'population-output-contract-evidence-0.2.4.rds'))
  main <- readRDS(inputs[1]); tail_run <- readRDS(inputs[2])
  helpers <- c('population-full-information-0.2.4.R',
    'population-variance-profile-0.2.4.R', 'population-identifiability-review-0.2.4.R',
    'mml-independent-information-conditions-0.2.4.R','mml-independent-rsm-information-0.2.4.R',
    'mml-structural-bias-diagnostic-0.2.4.R','mml-structural-coverage-0.2.4.R',
    'numerical-stationarity-pilot-0.2.3.R','gpcm-solution-stability-p0-0.2.3.R',
    'gpcm-zero-variance-boundary-p1c-0.2.3.R')
  paths <- c(list.files('R', pattern = '[.]R$', full.names = TRUE), inputs,
    paste0('inst/validation/', helpers))
  payload <- tools::md5sum(paths)
  design <- readLines('inst/validation/population-full-information-record-0.2.4.md')
  plan <- expand.grid(Case = names(main$cases), FitQ = c(31L,61L,121L), stringsAsFactors = FALSE)
  stopifnot(nrow(plan) == 12L)
  results <- list(); rows <- list(); grid_rows <- list(); targets <- list(); started <- Sys.time()
  for (i in seq_len(nrow(plan))) {
    spec <- plan[i, ]; case <- main$cases[[spec$Case]]; warnings <- character()
    begin <- Sys.time()
    result <- tryCatch(withCallingHandlers({
      args <- if (!is.null(case$x)) c(list(data = case$x$data, person = 'Person',
        facets = c('Rater','Criterion'), score = 'Score', model = spec$Case,
        step_facet = if (spec$Case == 'PCM') 'Criterion' else NULL,
        rating_min = 0, rating_max = 2), case$x$extra) else
        list(data = population_review_control_data(case$paired), person = 'Person',
          facets = 'Rater', score = 'Score', model = 'RSM', rating_min = 0, rating_max = 1,
          population_formula = ~1, person_data = unique(case$fit$prep$data['Person']))
      fit <- do.call(fit_mfrm, c(args, list(method = 'MML', quad_points = spec$FitQ,
        maxit = 300L, reltol = 1e-10, mml_engine = 'direct')))
      p <- fit$opt$par; context <- mfrmr_num_fit_context(fit)
      if (!is.null(case$x)) stopifnot(identical(context$coordinates$ParameterClass,
        rep(names(case$x$sizes), case$x$sizes)))
      fn <- function(par) population_full_reference(case, par)
      g1 <- mfrmr_num_central_gradient(fn, p, 1e-4)
      g2 <- mfrmr_num_central_gradient(fn, p, 5e-5)
      h1 <- mml_independent_central_hessian(fn, p, .001)
      h2 <- mml_independent_central_hessian(fn, p, .0005)
      e1 <- eigen(h1, symmetric = TRUE, only.values = TRUE)$values
      e2 <- eigen(h2, symmetric = TRUE, only.values = TRUE)$values
      pd <- min(e1) > 0 && min(e2) > 0
      reference_cov <- if (spec$Case != 'single' && pd) chol2inv(chol(h2)) else NULL
      ref <- list(objective = fn(p), gradient = g2, gradient_coarse = g1,
        hessian = h2, hessian_coarse = h1, eigenvalues = e2, eigenvalues_coarse = e1,
        covariance = reference_cov)
      map <- diag(length(p)); rownames(map) <- context$coordinates$CoordinateLabel
      if (!is.null(case$x)) map <- rbind(map, case$x$facet_map, case$x$step_map)
      variance_map <- numeric(length(p)); variance_map[context$slices$log_sigma2] <- exp(tail(p,1))
      map <- rbind(map, PopulationVariance = variance_map)
      ref_se <- if (!is.null(reference_cov)) sqrt(diag(map %*% reference_cov %*% t(map))) else rep(NA_real_,nrow(map))
      grids <- list()
      for (q in c(31L,61L,121L,241L)) {
        view <- fit; view$config$estimation_control$quad_points <- q
        ctx <- mfrmr_num_fit_context(view)
        cov <- mfrmr:::compute_mml_parameter_covariance(view)
        value <- ctx$fn(p); gradient <- ctx$gr(p)
        hs <- max(1,max(abs(h2)))
        row <- data.frame(Case = spec$Case, FitQ = spec$FitQ, EvaluationQ = q,
          ObjectiveAbsDifference = abs(value-ref$objective),
          FullGradientNorm = max(abs(g2)), GradientStepDifference = max(abs(g2-g1)),
          GradientVsPackageDifference = max(abs(gradient-g2)),
          HessianStepRelativeDifference = max(abs(h2-h1))/hs,
          HessianEntryScaledDifference = max(abs(cov$hessian-h2)/pmax(1,sqrt(abs(outer(diag(h2),diag(h2)))))),
          PackageCovarianceStatus = cov$status, ReferenceCovarianceAvailable = !is.null(reference_cov),
          CovarianceEntryScaledDifference = NA_real_, FreeSERelativeDifference = NA_real_,
          ExpandedSERelativeDifference = NA_real_)
        package_se <- if (!is.null(cov$cov)) sqrt(diag(map %*% cov$cov %*% t(map))) else rep(NA_real_,nrow(map))
        if (!is.null(reference_cov) && identical(cov$status,'ok')) {
          row$CovarianceEntryScaledDifference <- max(abs(cov$cov-reference_cov)/sqrt(outer(diag(reference_cov),diag(reference_cov))))
          row$FreeSERelativeDifference <- max(abs(package_se[seq_along(p)]/ref_se[seq_along(p)]-1))
          row$ExpandedSERelativeDifference <- max(abs(package_se/ref_se-1))
        }
        row$StationaryReference <- row$FullGradientNorm <= 1e-4 && row$GradientStepDifference <= 1e-7
        row$NumericalAgreement <- row$ObjectiveAbsDifference <= 1e-6 && row$GradientVsPackageDifference <= 1e-7
        row$InformationAgreement <- isTRUE(row$HessianStepRelativeDifference <= 1e-5 &&
          row$HessianEntryScaledDifference <= 1e-5 && row$CovarianceEntryScaledDifference <= 1e-5 &&
          row$FreeSERelativeDifference <= 1e-5 && row$ExpandedSERelativeDifference <= 1e-5)
        grids[[as.character(q)]] <- list(row = row, covariance = cov, gradient = gradient,
          objective = value, target_se = package_se)
        key <- paste(spec$Case,spec$FitQ,q,sep='-')
        grid_rows[[key]] <- row
        targets[[key]] <- data.frame(Case = spec$Case, FitQ = spec$FitQ, EvaluationQ = q,
          Target = rownames(map), ReferenceSE = ref_se, PackageSE = package_se)
      }
      stopifnot(!mfrmr:::mfrm_inference_ready(fit),
        !mfrmr:::prediction_source_scoring_readiness(fit)$ready)
      list(fit = fit, reference = ref, grids = grids, map = map, reference_se = ref_se)
    }, warning = function(w) {warnings <<- c(warnings,conditionMessage(w));invokeRestart('muffleWarning')}),
      error = identity)
    error <- inherits(result,'error')
    row <- data.frame(Case = spec$Case, FitQ = spec$FitQ, Returned = !error,
      Seconds = as.numeric(difftime(Sys.time(),begin,units='secs')), Warnings = length(warnings),
      Error = if(error) conditionMessage(result) else '', NativePass = FALSE,
      Variance = NA_real_, FullGradientNorm = NA_real_, LogVarianceGradient = NA_real_,
      MinEigenvalue = NA_real_, ConditionNumber = NA_real_, ReferenceCovarianceAvailable = FALSE)
    if (!error) {
      row$NativePass <- identical(result$fit$opt$optimizer_diagnostics$ConvergenceSeverity,'pass')
      row$Variance <- result$fit$population$sigma2
      row$FullGradientNorm <- max(abs(result$reference$gradient))
      row$LogVarianceGradient <- tail(result$reference$gradient,1)
      row$MinEigenvalue <- min(result$reference$eigenvalues)
      row$ConditionNumber <- if(row$MinEigenvalue>0) max(result$reference$eigenvalues)/row$MinEigenvalue else Inf
      row$ReferenceCovarianceAvailable <- !is.null(result$reference$covariance)
    }
    key <- paste(spec$Case,spec$FitQ,sep='-')
    rows[[key]] <- row; results[[key]] <- list(result=result,warnings=warnings)
    saveRDS(results[[key]],file.path(directory,paste0(key,'.rds')))
    cat(key, 'full gradient',row$FullGradientNorm,'covariance',row$ReferenceCovarianceAvailable,row$Error,'\n');flush.console()
  }
  drift <- list()
  for (id in names(main$cases)) for (q in c(31L,61L)) {
    low <- results[[paste(id,q,sep='-')]]$result
    high <- results[[paste(id,121L,sep='-')]]$result
    if(inherits(low,'error') || inherits(high,'error')) next
    row <- data.frame(Case=id,FitQ=q,ParameterAbsoluteChange=max(abs(low$fit$opt$par-high$fit$opt$par)),
      ParameterChangeInReferenceSE=NA_real_,PackageSERelativeChange=NA_real_,ReferenceSERelativeChange=NA_real_)
    if(!is.null(high$reference$covariance) && !is.null(low$reference$covariance)) {
      row$ParameterChangeInReferenceSE <- max(abs(low$fit$opt$par-high$fit$opt$par)/sqrt(diag(high$reference$covariance)))
      row$PackageSERelativeChange <- max(abs(low$grids[[as.character(q)]]$target_se/high$grids[['121']]$target_se-1))
      row$ReferenceSERelativeChange <- max(abs(low$reference_se/high$reference_se-1))
    }
    row$DriftWithinDiagnosticBounds <- isTRUE(row$ParameterChangeInReferenceSE <= .001 &&
      row$PackageSERelativeChange <= .001 && row$ReferenceSERelativeChange <= .001)
    drift[[paste(id,q)]] <- row
  }
  probes <- list()
  for(id in c('RSM','PCM')) {
    e <- subset(tail_run$envelope,Case==id & Variance==16 & Q==961)
    stopifnot(nrow(e)==1L,e$ContinuousNuisanceQualified)
    z <- tail_run$results[[e$Row]]$result
    fn <- function(p) population_full_reference(main$cases[[id]],p)
    g1 <- mfrmr_num_central_gradient(fn,z$par,1e-4)
    g2 <- mfrmr_num_central_gradient(fn,z$par,5e-5)
    probes[[id]] <- list(par=z$par,coarse=g1,fine=g2,
      summary=data.frame(Case=id,Variance=16,NuisanceGradient=max(abs(head(g2,-1))),
        LogVarianceGradient=tail(g2,1),FullGradient=max(abs(g2)),StepDifference=max(abs(g2-g1))))
  }
  stopifnot(identical(payload,tools::md5sum(paths)))
  evidence <- list(plan=plan,summary=do.call(rbind,rows),grids=do.call(rbind,grid_rows),
    targets=do.call(rbind,targets),drift=do.call(rbind,drift),probes=probes,results=results,
    payload=payload,source=setNames(lapply(paths[endsWith(paths,'.R')],readLines),paths[endsWith(paths,'.R')]),
    design=design,started=started,completed=Sys.time(),session=sessionInfo())
  saveRDS(evidence,file.path(directory,'evidence.rds'),compress='xz')
  for(name in c('summary','grids','targets','drift')) write.csv(evidence[[name]],file.path(directory,paste0(name,'.csv')),row.names=FALSE)
  invisible(evidence)
}

if(sys.nframe()==0L) {
  args<-commandArgs(trailingOnly=TRUE);stopifnot(length(args)==1L)
  population_full_information(args[1])
}
