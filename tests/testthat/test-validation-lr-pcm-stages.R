# Repository orchestration checks; mocked stages are not estimator replications.
lr_paths <- test_path('..','..','inst','validation',paste0('mfrm-wide-map-',
  c('mml-stages-20261001','lr-pcm-boundary-20261002','lr-pcm-stages-20261004'),'.R'))
skip_if_not(all(file.exists(lr_paths)),'Repository-only PCM regression execution')
lr_env <- new.env(parent=globalenv())
for(path in lr_paths) sys.source(path,envir=lr_env)

test_that('boundary selection requires qualified nuisance and a resolved continuous gain', {
  z <- list(qualified=TRUE,nll=100,entropy_nll=100,reason='')
  expect_true(lr_env$dlr_pcm_boundary_decision(z,list(value=99,summed_relative_error=1e-10))$eligible)
  expect_false(lr_env$dlr_pcm_boundary_decision(z,list(value=100,summed_relative_error=0))$eligible)
  expect_false(lr_env$dlr_pcm_boundary_decision(z,list(value=99,summed_relative_error=2))$eligible)
  z$qualified <- FALSE;z$reason <- 'dual'
  expect_identical(lr_env$dlr_pcm_boundary_decision(z,NULL)$status,'boundary_unresolved')
})

test_that('PCM regression stages preserve selection, failures and immutable replay', {
  fit <- readRDS(test_path('fixtures','native-location-pcm-regression.rds'))$fit
  spec <- list(ConditionId='execution-check',Arm='PCM-MML-LR',Replicate=1L,
    InputId='control-flow-only',purpose='workflow_check',args=list(
      data=fit$prep$data[c('Person','Rater','Criterion','Score')],person='Person',
      facets=c('Rater','Criterion'),score='Score',model='PCM',method='MML',
      step_facet='Criterion',population_formula=as.formula('~X',env=baseenv()),person_data=fit$population$person_table,
      person_id='Person',population_policy='error',rating_min=0,rating_max=3,
      category_policy='preserve',mml_engine='direct',mml_integration='fixed',
      optimizer='BFGS',maxit=400L,reltol=1e-12))
  expect_silent(lr_env$dlr_pcm_validate(spec))
  repeated <- spec;repeated$args$data <- rbind(spec$args$data,spec$args$data)
  expect_error(lr_env$dlr_pcm_validate(repeated),'repeated_ratings')
  repeated$args$repeated_ratings <- 'independent'
  expect_silent(lr_env$dlr_pcm_validate(repeated))
  old <- as.list(lr_env);withr::defer(list2env(old,envir=lr_env))
  lr_env$wide_mml_runtime <- function()list(source=tools::md5sum(lr_paths))
  calls <- integer();boundary_ok <- TRUE
  lr_env$wide_mml_fit <- function(args) {
    calls <<- c(calls,args$quad_points);x <- fit
    x$config$estimation_control$quad_points <- args$quad_points;x
  }
  lr_env$dlr_pcm_boundary_context <- function(fit)list()
  lr_env$dlr_pcm_zero <- function(...)list(qualified=TRUE,nll=100,entropy_nll=100)
  lr_env$dlr_pcm_continuous_value <- function(...)list(value=if(boundary_ok)99 else 101,summed_relative_error=0)
  lr_env$wide_mml_score <- function(fit) {
    q <- fit$config$estimation_control$quad_points
    list(ready=q>=61L,parameter_ready=TRUE,local_calibration_review=list(
      basis='local_mml_and_integration_v1',integration=data.frame(
        OriginalOrder=q,ComparisonOrder=q*2L-1L,NLLChange=if(q<61L).01 else 0,
        GradientChange=0,ComparisonGradient=0)))
  }
  lr_env$dlr_pcm_interval <- function(fit,level) {
    pass <- fit$config$estimation_control$quad_points>=121L
    list(fit=fit,settings=list(procedure='mml_native_location_model_v1'),
      checks=data.frame(Check='Quadrature comparison',Passed=pass),
      numerical_checks=data.frame(InverseResidual=0,ComparisonInverseResidual=0,
        CurvatureScaledGradient=0,QuadratureScoreShift=if(pass)0 else .1,QuadratureCovarianceChange=0),
      table=data.frame(Target=c(as.character(1:3),'1-2'),Estimate=c(1:3,-1),SE=1,Lower=-2,Upper=4,
        CIEligible=pass,InferenceReview=if(pass)'' else 'integration'))
  }
  local_mocked_bindings(mfrm_population_intervals=function(object,level)list(
    table=data.frame(Target=c('beta:(Intercept)','beta:X','log_residual_variance'),
      WorkingEstimate=1:3,WorkingSE=1,WorkingLower=0,WorkingUpper=4,
      CIEligible=all(object$table$CIEligible))),.package='mfrmr')
  # Source hashes are relative to the package root, as in the real runner.
  withr::local_dir(test_path('..','..'))
  dir <- tempfile();withr::defer(unlink(dir,recursive=TRUE))
  x <- lr_env$dlr_pcm_stages(spec,dir)
  expect_identical(calls,c(31L,61L,121L))
  expect_identical(x$point$order,61L);expect_identical(x$interval$order,121L)
  expect_true(x$point$eligible);expect_true(x$interval$eligible)
  rows <- lr_env$dlr_pcm_records(spec,x,dir)
  expect_equal(nrow(rows),28L)
  expect_false(any(rows$Available[rows$Rule=='default']))
  expect_true(all(rows$Available[rows$Rule=='refinement']))
  lr_env$wide_mml_fit <- function(...)stop('Replay must not refit')
  expect_identical(lr_env$dlr_pcm_stages(spec,dir),x)
  bad <- spec;bad$args$reltol <- 1e-9
  expect_error(lr_env$dlr_pcm_stages(bad,dir))
  # A boundary miss must not turn qualified public tables into study success.
  boundary_ok <- FALSE
  lr_env$wide_mml_fit <- function(args) {x <- fit;x$config$estimation_control$quad_points <- args$quad_points;x}
  dir2 <- tempfile();withr::defer(unlink(dir2,recursive=TRUE))
  no <- lr_env$dlr_pcm_stages(spec,dir2)
  rows <- lr_env$dlr_pcm_records(spec,no,dir2)
  expect_false(any(rows$Available));expect_true(all(is.finite(rows$Estimate)))
  expect_true(all(rows$BoundaryStatus=='boundary_unresolved'))
  expect_true(all(is.na(rows$Lower)))
  # Completed errors retain every planned target and do not retry grids.
  attempts <- 0L
  lr_env$wide_mml_fit <- function(...) {attempts <<- attempts+1L;stop('recorded fitting failure')}
  dir3 <- tempfile();withr::defer(unlink(dir3,recursive=TRUE))
  err <- lr_env$dlr_pcm_stages(spec,dir3)
  rows <- lr_env$dlr_pcm_records(spec,err,dir3)
  expect_equal(attempts,1L);expect_equal(nrow(rows),28L)
  expect_true(all(!rows$Available));expect_true(all(grepl('recorded fitting failure',rows$Reason)))
})
