# Repository orchestration checks; these are not sampling replications.
rsm_paths <- test_path('..','..','inst','validation',c('mfrm-wide-map-mml-stages-20261001.R',
  'mfrm-lr-rsm-boundary-20261009.R','mfrm-lr-rsm-stages-20261009.R'))
skip_if_not(all(file.exists(rsm_paths)),'Repository-only RSM regression execution')
rsm_env <- new.env(parent=globalenv())
for(path in rsm_paths) sys.source(path,envir=rsm_env)

test_that('RSM selection separates targets and sources and keeps terminal refusals', {
  fixture <- readRDS(test_path('fixtures','native-location-rsm-zero-boundary.rds'))
  fit <- fixture$fit
  spec <- list(ConditionId='control-flow',Arm='RSM-MML-LR',Replicate=1L,
    InputId='no-sampling',purpose='workflow_check',args=list(
      data=fit$prep$data[c('Person','Rater','Criterion','Score')],person='Person',
      facets=c('Rater','Criterion'),score='Score',model='RSM',method='MML',
      population_formula=as.formula('~X',env=baseenv()),person_data=fit$population$person_table,
      person_id='Person',population_policy='error',rating_min=0,rating_max=2,
      category_policy='preserve',mml_engine='direct',mml_integration='fixed',
      optimizer='BFGS',maxit=400L,reltol=1e-12))
  expect_silent(rsm_env$rsm_lr_validate(spec))
  bad <- spec;bad$args$data <- rbind(bad$args$data,bad$args$data)
  expect_error(rsm_env$rsm_lr_validate(bad),'anyDuplicated')
  bad <- spec;bad$args$facet_interactions <- 'Rater:Criterion'
  expect_error(rsm_env$rsm_lr_validate(bad),'setequal')
  bad <- spec;bad$args$optimizer <- NULL
  expect_error(rsm_env$rsm_lr_validate(bad),'setequal')
  old <- as.list(rsm_env);withr::defer(list2env(old,envir=rsm_env))
  withr::local_dir(test_path('..','..'))
  root <- tempfile();dir.create(root);withr::defer(unlink(root,recursive=TRUE))
  rsm_env$wide_mml_runtime <- function()list(source=tools::md5sum(rsm_paths))
  calls <- integer();point_order <- 61L;interval_order <- 121L
  information_calls <- integer()
  local_mocked_bindings(compute_mml_parameter_covariance=function(res) {
    information_calls <<- c(information_calls,res$config$estimation_control$quad_points)
    list(status='ok')
  },.package='mfrmr')
  boundary_ok <- TRUE;failed_target <- FALSE;fail_order <- 0L
  rsm_env$wide_mml_fit <- function(args) {
    calls <<- c(calls,args$quad_points)
    if(args$quad_points==fail_order) stop('recorded fit failure')
    x <- fit;x$config$estimation_control$quad_points <- args$quad_points;x
  }
  rsm_env$rsm_lr_boundary_context <- function(fit)list()
  rsm_env$rsm_lr_boundary_zero <- function(...)list(qualified=TRUE,nll=100,entropy_nll=100)
  rsm_env$rsm_lr_continuous_value <- function(...)list(value=if(boundary_ok)99 else 101,summed_relative_error=0)
  rsm_env$rsm_lr_score <- function(fit,covariance=NULL) {
    covariance(fit)
    q <- fit$config$estimation_control$quad_points
    list(ready=q>=point_order,parameter_ready=TRUE,local_calibration_review=list(
      basis='local_mml_and_integration_v1',integration=data.frame(
        OriginalOrder=q,ComparisonOrder=q*2L-1L,NLLChange=if(q<point_order).01 else 0,
        GradientChange=0,ComparisonGradient=0)))
  }
  rsm_env$rsm_lr_interval <- function(fit,level,covariance=NULL) {
    covariance(fit)
    pass <- fit$config$estimation_control$quad_points>=interval_order
    x <- fixture$legacy_population;x$fit <- fit
    x$checks <- data.frame(Check='Quadrature comparison',Passed=pass)
    x$numerical_checks <- data.frame(InverseResidual=0,ComparisonInverseResidual=0,
      CurvatureScaledGradient=0,QuadratureScoreShift=if(pass)0 else .1,QuadratureCovarianceChange=0)
    x$table$CIEligible <- pass;x$table$InferenceReview <- if(pass)'' else 'integration'
    if(failed_target) {
      x$table$CIEligible[3L] <- FALSE;x$table$InferenceReview[3L] <- 'target arithmetic failure'
    }
    x
  }
  run <- function(name) {
    out <- file.path(root,name);x <- rsm_env$rsm_lr_stages(spec,out)
    list(x=x,rows=rsm_env$rsm_lr_records(spec,x,out),out=out)
  }
  a <- run('interval-retry')
  expect_identical(calls,c(61L,121L))
  expect_identical(information_calls,c(61L,121L))
  expect_identical(a$x$point$order,61L);expect_identical(a$x$interval$order,121L)
  expect_equal(nrow(a$rows),24L)
  expect_true(all(a$rows$Available[a$rows$Selection=='selected']))
  expect_false(any(a$rows$Available[a$rows$Selection=='initial' & a$rows$Output=='interval']))
  rsm_env$wide_mml_fit <- function(...)stop('Replay must not fit')
  expect_identical(rsm_env$rsm_lr_stages(spec,a$out),a$x)
  expect_identical(information_calls,c(61L,121L))
  # Interrupted after scoring: no in-memory information survives the restart.
  unlink(file.path(a$out,c('q121-population.rds','selected.rds')))
  resumed <- rsm_env$rsm_lr_stages(spec,a$out)
  expect_identical(information_calls,c(61L,121L,121L))
  expect_identical(rsm_env$rsm_lr_records(spec,resumed,a$out),a$rows)
  # Remaining cases use the same mock estimator, including a terminal q121 error.
  rsm_env$wide_mml_fit <- function(args) {
    calls <<- c(calls,args$quad_points)
    if(args$quad_points==fail_order) stop('recorded fit failure')
    x <- fit;x$config$estimation_control$quad_points <- args$quad_points;x
  }
  point_order <- 121L;interval_order <- 61L
  b <- run('source-retry')
  expect_identical(b$x$point$order,121L);expect_identical(b$x$interval$order,61L)
  point_order <- 61L;failed_target <- TRUE;calls <- integer()
  c <- run('one-target-refused')
  tab <- subset(c$rows,Selection=='selected' & Output=='interval')
  expect_identical(calls,61L);expect_equal(sum(tab$Available),5L)
  expect_identical(tab$Reason[!tab$Available],'target arithmetic failure')
  expect_true(all(is.finite(tab$Estimate)));expect_true(all(is.na(tab$Lower[!tab$Available])))
  failed_target <- FALSE;boundary_ok <- FALSE;point_order <- interval_order <- 121L;calls <- integer()
  d <- run('boundary-refusal')
  expect_identical(calls,61L);expect_false(any(d$rows$Available))
  expect_true(all(is.finite(d$rows$Estimate)));expect_true(all(nzchar(d$rows$Reason)))
  expect_true(all(d$rows$BoundaryStatus=='boundary_unresolved'))
  boundary_ok <- TRUE;point_order <- 61L;fail_order <- 121L
  e <- run('retry-fit-failure')
  expect_identical(e$x$point$order,61L);expect_identical(e$x$interval$order,121L)
  expect_true(all(subset(e$rows,Selection=='selected' & Output=='scoring_source')$Available))
  expect_true(all(grepl('recorded fit failure',subset(e$rows,Selection=='selected' & Output=='interval')$Reason)))
  fail_order <- 0L;interval_order <- 241L;calls <- integer()
  ceiling <- run('retry-ceiling')
  expect_identical(calls,c(61L,121L))
  expect_false(any(subset(ceiling$rows,Selection=='selected' & Output=='interval')$Available))
  fail_order <- 61L;calls <- integer()
  f <- run('initial-fit-failure')
  expect_identical(calls,61L);expect_equal(nrow(f$rows),24L)
  expect_false(any(f$rows$Available));expect_true(all(grepl('recorded fit failure',f$rows$Reason)))
  bad <- spec;bad$InputId <- 'changed'
  expect_error(rsm_env$rsm_lr_stages(bad,a$out),'identical')
  path <- file.path(a$out,'q61-fit.rds');saved <- readRDS(path)
  saved$payload$error <- 'tampered';saveRDS(saved,path)
  expect_error(rsm_env$rsm_lr_stages(spec,a$out),'checksum mismatch')
  expect_error(rsm_env$rsm_lr_records(spec,a$x,a$out),'identical')
})
