# Repository-only same-vector PCM information audit. No generated data.
# Rscript THIS_FILE [OUTPUT_DIRECTORY]
source('inst/validation/mfrm-wide-map-lr-pcm-boundary-20261002.R')
source('inst/validation/mfrm-wide-map-mml-stages-20261001.R')

dlr_pcm_information_reference <- function(ctx,par,path,check_derivatives) {
  script <- 'inst/validation/mfrm-wide-map-lr-pcm-information-20261002.py'
  binding <- list(par=par,rows=ctx$fit$prep$data,population=ctx$fit$population$design_matrix,
    included=ctx$fit$population$included_persons,derivatives=check_derivatives,
    script=tools::md5sum(script),adapter=body(dlr_pcm_information_reference))
  wide_mml_phase(paste0(path,'.rds'),binding,function() {
    dat <- ctx$fit$prep$data
    input <- list(par=par,check_derivatives=check_derivatives,
      rows=cbind(match(as.character(dat$Person),ctx$fit$population$included_persons)-1L,
        as.integer(dat$Rater)-1L,as.integer(dat$Criterion)-1L,dat$Score),
      x=unname(ctx$fit$population$design_matrix[,'X']))
    jsonlite::write_json(input,paste0(path,'-input.json'),auto_unbox=TRUE,digits=NA)
    status <- system2('python3',shQuote(c(script,paste0(path,'-input.json'),paste0(path,'-output.json'))))
    stopifnot(status == 0L)
    jsonlite::read_json(paste0(path,'-output.json'),simplifyVector=TRUE)
  })
}

dlr_pcm_information_native <- function(ctx,par,q,path,runtime) {
  wide_mml_phase(path,list(par=par,q=q,runtime=runtime,
    helper=body(dlr_pcm_information_native)),function() {
    view <- ctx$fit
    # Evaluation-only parameter container, never returned as a modified public fit.
    view$opt$par <- par
    view$config$estimation_control$quad_points <- q
    info <- mfrmr:::compute_mml_parameter_covariance(view)
    stopifnot(info$status == 'ok',!info$regularized)
    list(value=info$solution_information$evaluation_summary$ReevaluatedObjective,
      gradient=info$solution_information$gradient,hessian=info$hessian,covariance=info$cov,
      inverse_residual=norm(info$hessian %*% info$cov-diag(13),'I'))
  })
}

dlr_pcm_information_compare <- function(reference,native,par) {
  h <- reference$hessian; v <- chol2inv(chol(h))
  map <- diag(13)
  for (cols in list(1:2,3:4,5:6,7:8,9:10)) {
    row <- numeric(13); row[cols] <- -1; map <- rbind(map,row)
  }
  row <- numeric(13); row[13] <- exp(par[13]); map <- rbind(map,row)
  scale <- pmax(1,sqrt(abs(outer(diag(h),diag(h)))))
  sd <- sqrt(diag(v)); shift <- as.vector(v %*% reference$gradient)
  row <- data.frame(ObjectiveDifference=abs(native$value-reference$value),
    GradientDifference=max(abs(native$gradient-reference$gradient)),
    HessianScaledDifference=max(abs(native$hessian-h)/scale),
    CovarianceScaledDifference=max(abs(native$covariance-v)/outer(sd,sd)),
    ExpandedSDRelativeDifference=max(abs(sqrt(diag(map %*% native$covariance %*% t(map)))/
      sqrt(diag(map %*% v %*% t(map)))-1)),
    ReferenceGradient=max(abs(reference$gradient)),
    ReferenceScaledGradient=sqrt(sum(reference$gradient*shift)),
    NewtonShiftInSD=max(abs(shift)/sd),
    ReferenceMinEigenvalue=min(eigen(h,symmetric=TRUE,only.values=TRUE)$values),
    InverseResidual=native$inverse_residual)
  row$IntegrationAgreement <- row$ObjectiveDifference <= 1e-6 && row$GradientDifference <= 1e-7
  row$InformationAgreement <- all(row[c('HessianScaledDifference','CovarianceScaledDifference',
    'ExpandedSDRelativeDifference')] <= 1e-5) && row$InverseResidual <= 1e-6
  row$Stationary <- row$ReferenceGradient <= 1e-4
  row
}

dlr_pcm_information_run <- function(out) {
  pkgload::load_all('.',quiet=TRUE,compile=FALSE)
  prior <- readRDS('validation-results/mfrm-wide-map-lr-pcm-boundary-20261002/verified.rds')
  runtime <- wide_mml_runtime()
  stopifnot(identical(runtime$source,prior$runtime$source),
    identical(unname(prior$source),unname(tools::md5sum(
      'inst/validation/mfrm-wide-map-lr-pcm-boundary-20261002.R'))))
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  rows <- details <- list()
  for (id in prior$summary$Job) {
    fit <- readRDS(file.path('validation-results/mfrm-wide-map-lr-witness-20261002',id,'fit.rds'))$payload$value
    ctx <- dlr_pcm_boundary_context(fit); par <- fit$opt$par
    dir <- file.path(out,id); dir.create(dir,showWarnings=FALSE)
    cat('Continuous information:',id,'\n'); flush.console()
    ref <- dlr_pcm_information_reference(ctx,par,file.path(dir,'initial-continuous'),TRUE)
    stopifnot(abs(ref$value-prior$details[[id]]$interior$value) <= 1e-8)
    q <- 31L; grids <- list()
    repeat {
      native <- dlr_pcm_information_native(ctx,par,q,file.path(dir,paste0('initial-q',q,'.rds')),runtime)
      comparison <- cbind(Job=id,Q=q,dlr_pcm_information_compare(ref,native,par))
      grids[[as.character(q)]] <- list(comparison=comparison,native=native)
      rows[[paste(id,q)]] <- comparison
      print(comparison[c('Job','Q','ReferenceGradient','GradientDifference',
        'InformationAgreement','IntegrationAgreement')],row.names=FALSE)
      write.csv(do.call(rbind,rows),file.path(out,'initial-summary.csv'),row.names=FALSE)
      if (comparison$IntegrationAgreement) {
        if (!comparison$InformationAgreement)
          stop('Investigate Hessian differentiation at an integration-qualified order: ',id,' q',q)
        break
      }
      q <- 2L*q-1L
    }
    details[[id]] <- list(reference=ref,grids=grids,qualified_q=q,par=par)
  }
  sources <- c('inst/validation/mfrm-wide-map-lr-pcm-information-20261002.R',
    'inst/validation/mfrm-wide-map-lr-pcm-information-20261002.py')
  evidence <- list(summary=do.call(rbind,rows),details=details,runtime=runtime,
    sources=tools::md5sum(sources),source_code=setNames(lapply(sources,readLines),sources))
  wide_mml_save(evidence,file.path(out,'initial-verified.rds'))
  invisible(evidence)
}

dlr_pcm_information_refine <- function(out) {
  pkgload::load_all('.',quiet=TRUE,compile=FALSE)
  initial <- readRDS(file.path(out,'initial-verified.rds'))
  runtime <- wide_mml_runtime()
  stopifnot(identical(runtime,initial$runtime))
  rows <- details <- list()
  for (id in names(initial$details)) {
    old <- initial$details[[id]]; reference <- old$reference
    q <- old$qualified_q; par <- old$par
    qualified <- old$grids[[as.character(q)]]$comparison
    if (qualified$Stationary) next
    # Reuse independent full curvature for one local Newton correction. These
    # are research parameter vectors, not reconstructed or promoted public fits.
    step <- solve(reference$hessian,reference$gradient)
    candidate <- par-as.vector(step)
    stopifnot(max(abs(step)) < .01, qualified$NewtonShiftInSD < .01)
    fit <- readRDS(file.path('validation-results/mfrm-wide-map-lr-witness-20261002',id,'fit.rds'))$payload$value
    ctx <- dlr_pcm_boundary_context(fit)
    dir <- file.path(out,id)
    cat('Local correction:',id,'q',q,'\n'); flush.console()
    ref <- dlr_pcm_information_reference(ctx,candidate,file.path(dir,'refined-continuous'),FALSE)
    native <- dlr_pcm_information_native(ctx,candidate,q,file.path(dir,paste0('refined-q',q,'.rds')),runtime)
    comparison <- dlr_pcm_information_compare(ref,native,candidate)
    v0 <- chol2inv(chol(reference$hessian)); v1 <- chol2inv(chol(ref$hessian))
    row <- cbind(Job=id,Q=q,comparison,
      NLLImprovement=reference$value-ref$value,
      MaximumParameterChange=max(abs(candidate-par)),
      ParameterChangeInReferenceSD=max(abs(candidate-par)/sqrt(diag(v1))),
      SameContinuousSDChange=max(abs(sqrt(diag(v1)/diag(v0))-1)),
      Gamma0=candidate[11],Gamma1=candidate[12],Variance=exp(candidate[13]),
      Gamma0SD=sqrt(v1[11,11]),Gamma1SD=sqrt(v1[12,12]),LogVarianceSD=sqrt(v1[13,13]))
    row$AllChecksPassed <- row$IntegrationAgreement && row$InformationAgreement &&
      row$Stationary && row$NLLImprovement >= -1e-8
    rows[[id]] <- row
    details[[id]] <- list(par=candidate,step=step,reference=ref,native=native,
      comparison=row,initial_par=par,initial_reference=reference,
      status='research_local_refinement_no_public_fit_replacement')
    print(row[c('Job','Q','ReferenceGradient','NLLImprovement',
      'ParameterChangeInReferenceSD','AllChecksPassed')],row.names=FALSE)
    write.csv(do.call(rbind,rows),file.path(out,'refinement-summary.csv'),row.names=FALSE)
  }
  sources <- c('inst/validation/mfrm-wide-map-lr-pcm-information-20261002.R',
    'inst/validation/mfrm-wide-map-lr-pcm-information-20261002.py')
  evidence <- list(summary=do.call(rbind,rows),details=details,runtime=runtime,
    input=tools::md5sum(file.path(out,'initial-verified.rds')),
    sources=tools::md5sum(sources),source_code=setNames(lapply(sources,readLines),sources))
  wide_mml_save(evidence,file.path(out,'refined-verified.rds'))
  stopifnot(all(evidence$summary$AllChecksPassed))
  invisible(evidence)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly=TRUE)
  out <- if (length(args)) args[1L] else 'validation-results/mfrm-wide-map-lr-pcm-information-20261002'
  if (length(args) >= 2L && args[2L] == 'refine') dlr_pcm_information_refine(out) else
    dlr_pcm_information_run(out)
}
