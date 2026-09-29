gmfrm_quadrature_fixture <- local({
  cached <- NULL
  function() {
    if (is.null(cached)) {
      d <- readRDS(test_path("fixtures","gmfrm-joint-information.rds"))$data
      # Both families deliberately use the same levels and arbitrary owner names.
      d$Task <- sub("^.*?([0-9]+)$","\\1",as.character(d$Task))
      d$Rater <- sub("^.*?([0-9]+)$","\\1",as.character(d$Rater))
      names(d)[match(c("Task","Rater"),names(d))] <- c("Task label","Assessor label")
      fit <- fit_mfrm(d,person="Person",facets=c("Task label","Assessor label"),score="Score",
        model="GPCM",method="MML",slope_facet=c("Task label","Assessor label"),
        step_facet="Assessor label",noncenter_facet="Assessor label",
        mml_engine="em",gpcm_mml_identification="fixed_standard_normal",
        quad_points=5L,maxit=500L,em_score_tol=1e-6,
        rating_min=0,rating_max=2,category_policy="preserve")
      review <- suppressWarnings(mml_quadrature_sensitivity(fit,d,
        quad_points=c(5L,31L),theta_points=21L))
      cached <<- list(data=d,fit=fit,review=review)
    }
    cached
  }
})

test_that("two-family quadrature refits preserve the model and interval evidence", {
  x <- gmfrm_quadrature_fixture(); review <- x$review
  expect_s3_class(review,"mfrm_quadrature_sensitivity")
  expect_identical(review$fits$q5,x$fit)
  expect_identical(review$fits$q31$gmfrm$controls,x$fit$gmfrm$controls)
  expect_identical(review$fits$q31$config$replay_inputs$rating_max,2)
  expect_true(mfrmr_gqs_same_prepared_data(x$fit,review$fits$q31))
  expect_true(all(review$runs$EstimationConverged))
  expect_false(any(review$runs$InferenceReady))
  expect_true(all(is.finite(review$summary$ProbabilityMaxAbsChange)))
  expect_true(all(is.finite(review$summary$RawSlopeSEMaxAbsChange)))
  expect_true(all(is.na(review$summary$EAPMaxAbsChange)))
  expect_true(all(is.na(review$summary$PosteriorSDMaxAbsChange)))
  expect_identical(review$settings$person_score_comparison,"unavailable_two_family")
  expect_true(all(is.na(review$intervals$q5)))
  expect_true(all(is.finite(review$intervals$q31)))
  expect_identical(review$summary$SlopeIntervalEligibilityChanged,c(0L,6L))
  fine <- attr(review$intervals$q31,"diagnostics")
  expect_equal(review$slopes$SlopeOwner,rep(fine$SlopeOwner,2L))
  expect_equal(review$slopes$ScaleReference,rep(fine$ScaleReference,2L))
  expect_false(anyDuplicated(review$slopes[c("Nodes","SlopeOwner","SlopeFacet")])>0)
  expect_true(any(grepl("Experimental two-family",review$conditions$Message)))
  expect_output(print(review),"Person-score comparisons are unavailable")
  expect_output(print(summary(review)),"Person-score comparisons are unavailable")
  expect_s3_class(apa_table(review,digits=5),"apa_table")
  expect_s3_class(plot(review$intervals$q31,draw=FALSE),"ggplot")
  expect_equal(as.data.frame(review),review$summary)
  expect_equal(summary(review)$intervals,review$intervals)
  path <- tempfile(fileext=".rds"); saveRDS(review,path)
  withr::defer(unlink(path))
  expect_identical(readRDS(path)$intervals,review$intervals)
})

test_that("nonconverged two-family refits keep missing intervals and their reason", {
  x <- gmfrm_quadrature_fixture()
  args <- mfrmr_gqs_refit_arguments(x$fit,x$data,5L); args$maxit <- 1L
  fit <- do.call(fit_mfrm,args)
  review <- suppressWarnings(gpcm_mml_quadrature_sensitivity(fit,x$data,
    quad_points=c(5L,7L),theta_points=21L))
  expect_false(any(review$runs$EstimationConverged))
  expect_false(any(review$slopes$CIEligible))
  expect_true(all(is.na(review$slopes$CI_Lower)))
  expect_match(review$slopes$InferenceReview[1],"EM must meet")
  expect_true(all(is.finite(review$summary$ProbabilityMaxAbsChange)))
  expect_identical(review$fits$q7$gmfrm$controls$maxit,1L)
})

test_that("quadrature probabilities and diagnostic SEs use both slope owners", {
  fit <- gmfrm_quadrature_fixture()$review$fits$q31
  got <- mfrmr_gqs_design_probabilities(fit,c(-4,4),21L)
  grid <- got$cells[rep(seq_len(nrow(got$cells)),each=21L),,drop=FALSE]
  grid$Theta <- rep(got$theta,nrow(got$cells))
  expected <- mfrm_curve_intervals(fit,grid)$table$Estimate
  expect_equal(got$values,expected,tolerance=1e-12)
  info <- compute_mml_parameter_covariance(fit)
  # Independent map: first family log slopes sum to zero, second is free.
  J <- matrix(0,6,13); J[1:3,9:10] <- rbind(c(1,0),c(0,1),c(-1,-1))
  J[4:6,11:13] <- diag(3)
  expected_se <- fit$slopes$Estimate*sqrt(diag(J%*%info$cov%*%t(J)))
  tab <- gmfrm_quadrature_fixture()$review$slopes
  expect_equal(tab$RawObservedInformationSE[tab$Nodes==31],expected_se,tolerance=1e-10)
  reordered <- fit; reordered$slopes <- fit$slopes[6:1,]
  expect_equal(mfrmr_gqs_max_named_difference(mfrmr_gqs_measurement_parameters(fit),
    mfrmr_gqs_measurement_parameters(reordered),"measurement"),0)
  expect_identical(mfrmr_gqs_slope_keys(reordered),rev(mfrmr_gqs_slope_keys(fit)))
})

test_that("two-family replay controls and unsupported integration requests stay explicit", {
  x <- gmfrm_quadrature_fixture()
  args <- mfrmr_gqs_refit_arguments(x$fit,x$data,31L)
  expect_identical(args$em_score_tol,1e-6)
  expect_null(args$reltol)
  expect_null(args$package_version)
  changed <- x$fit; changed$config$replay_inputs$em_score_tol <- 2e-6
  expect_identical(mfrmr_gqs_refit_arguments(changed,x$data,31L)$em_score_tol,2e-6)
  for (fun in list(mml_quadrature_sensitivity,gpcm_mml_quadrature_sensitivity)) {
    expect_error(fun(x$fit,x$data,quad_points=c(5L,31L),adaptive_quad_points=c(15L,31L)),
      "Adaptive quadrature review is not available for two slope families")
  }
  changed <- x$review$fits$q31
  changed$prep$data$score_k[1] <- changed$prep$data$score_k[1]+1L
  expect_false(mfrmr_gqs_same_prepared_data(x$fit,changed))
})
