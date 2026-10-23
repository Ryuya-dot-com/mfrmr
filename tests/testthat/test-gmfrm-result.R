result_run <- function() readRDS(test_path("fixtures","gmfrm-result.rds"))$run

test_that("an unselected boundary result retains its references without native information", {
  run <- readRDS(test_path("fixtures","gmfrm-result-held.rds"))
  r <- mfrm_gmfrm_result(run)
  expect_identical(r$run,run); expect_null(r$tables); expect_null(r$reference)
  expect_false(r$admission$conditional_person_scoring)
  expect_error(mfrm_gmfrm_result_targets(r),"no selected")
  expect_error(mfrm_gmfrm_result_persons(r),"not eligible")
})

test_that("private results preserve evidence and full native contrast covariance", {
  run <- result_run()
  forbidden <- function(...) stop("No refitting or Hessian work is permitted.")
  testthat::local_mocked_bindings(mfrm_gmfrm_bounded_search=forbidden,mfrm_gmfrm_finish_interior=forbidden)
  r <- mfrm_gmfrm_result(run)
  expect_false(inherits(r,"mfrm_fit")); expect_identical(r$run,run)
  expect_true(r$admission$conditional_person_scoring)
  expect_false(r$admission$public_fit); expect_false(r$admission$structural_intervals)
  expect_identical(vapply(r$run$attempts,function(x) x$candidate$search$optimizer$convergence,0L),
    c(neutral=1L,perturbed=1L))
  tab <- mfrm_gmfrm_result_targets(r)
  expect_identical(tab$Target,run$parameter_names)
  expect_equal(tab$Estimate,run$candidate$native_parameters,tolerance=1e-12)
  expect_equal(tab$LocalVariance,diag(run$candidate$information$covariance),tolerance=1e-12)
  C <- matrix(c(0,1,-1,0,0,0),1,dimnames=list("Judge j1 - j2",run$parameter_names))
  difference <- mfrm_gmfrm_result_targets(r,C)
  expect_equal(difference$Estimate,unname(drop(C%*%run$candidate$native_parameters)),tolerance=1e-12)
  expect_equal(difference$LocalVariance,drop(C%*%run$candidate$information$covariance%*%t(C)),tolerance=1e-12)
  expect_false(difference$IntervalEligible)
  p <- tempfile(); on.exit(unlink(p), add = TRUE); saveRDS(r,p)
  expect_identical(mfrm_gmfrm_result_targets(readRDS(p),C),difference)
  colnames(C) <- rev(colnames(C)); expect_error(mfrm_gmfrm_result_targets(r,C),"parameter order")
})

test_that("handoff refuses stale model, selection, stage and constraint evidence", {
  run <- result_run()
  bad <- run; bad$parameter_names <- rev(bad$parameter_names)
  expect_error(mfrm_gmfrm_result(bad),"parameter order")
  bad <- run; bad$candidate$native_parameters[1] <- 0
  expect_error(mfrm_gmfrm_result(bad),"selection")
  bad <- run; bad$attempts[[1]]$stages$finish$value$information$parameters[1] <- 0
  expect_error(mfrm_gmfrm_result(bad),"Information")
  bad <- run; bad$fixed <- 1L
  expect_error(mfrm_gmfrm_result(bad),"prescribed start")
  bad <- run; bad$specification$data$Rating[1] <- 1
  expect_error(mfrm_gmfrm_result(bad),"independent likelihood/score")
  r <- mfrm_gmfrm_result(run); r$tables$slopes$Estimate[1] <- 0
  expect_error(mfrm_gmfrm_result_persons(r),"changed after qualification")
  expect_error(mfrm_gmfrm_result_targets(r),"changed after qualification")
})

test_that("Person scoring preserves labels, known-level products and fixed calibration", {
  r <- mfrm_gmfrm_result(result_run()); old <- r
  x <- mfrm_gmfrm_result_persons(r)
  expect_true(all(x$estimates$Eligible)); expect_true(all(x$estimates$PosteriorSD>0))
  expect_identical(r,old); expect_identical(x$source_identity,r$identity)
  expect_identical(x$method,"conditional EAP; adaptive Gauss-Hermite 31/61")
  d <- r$run$specification$data
  permuted <- mfrm_gmfrm_result_persons(r,d[rev(seq_len(nrow(d))),])
  expect_equal(permuted$estimates,x$estimates,tolerance=1e-12)
  # Sparse new-Person batch: retain the source level order even when only the
  # second level is observed. Overlapping IDs do not reuse training responses.
  new <- d[c(61,1,21),]; new$Examinee <- c("future","future","single")
  scored <- mfrm_gmfrm_result_persons(r,new)$estimates
  expect_identical(scored$Person,c("future","single")); expect_true(all(scored$Eligible))
  single <- mfrm_gmfrm_result_persons(r,new[3,,drop=FALSE])$estimates
  expect_equal(single,scored[scored$Person=="single",],tolerance=1e-12,ignore_attr=TRUE)
  bad <- new; bad$Judge <- "unseen"
  expect_error(mfrm_gmfrm_result_persons(r,bad),"known facet")
  bad <- new; bad$Rating[1] <- 2
  expect_error(mfrm_gmfrm_result_persons(r,bad),"category ladder")
  expect_error(mfrm_gmfrm_result_persons(r,rbind(new,new[1,])),"unique person-facet")
})

test_that("category and per-Person integration failures remain refusals", {
  run <- result_run()
  original <- audit_mfrm_category_support
  testthat::local_mocked_bindings(audit_mfrm_category_support=function(...) {
    a <- original(...); a$readiness$CategoryState <- "unsupported_coordinate"; a
  })
  r <- mfrm_gmfrm_result(run)
  expect_false(r$admission$conditional_person_scoring)
  expect_error(mfrm_gmfrm_result_persons(r),"not eligible")
  testthat::local_mocked_bindings(audit_mfrm_category_support=original)
  r <- mfrm_gmfrm_result(run)
  review <- mfrmr_adaptive_quadrature_review
  testthat::local_mocked_bindings(mfrmr_adaptive_quadrature_review=function(...) {
    x <- review(...); x$AdaptiveEAP[1] <- x$AdaptiveEAP[1]+.01; x
  })
  x <- mfrm_gmfrm_result_persons(r)
  expect_false(x$estimates$Eligible[1]); expect_true(is.na(x$estimates$Estimate[1]))
  expect_true(is.na(x$estimates$PosteriorSD[1])); expect_true(all(x$estimates$Eligible[-1]))
})
