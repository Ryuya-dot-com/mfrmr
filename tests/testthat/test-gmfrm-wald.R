source(test_path("helper-gmfrm-information.R"),local=TRUE)

test_that("vectorized Louis information matches the independent scalar reference and derivatives", {
  for(K in c(1L,3L)) {
    d <- expand.grid(Candidate=paste0("p",1:3),Item=c("i1","i2"),Judge=paste0("j",1:3))
    d <- d[-1,]; d$Rating <- rep(0:K,length.out=nrow(d))
    problem <- mfrm_gmfrm_problem(d,K,gauss_hermite_normal(241L),c("Item","Judge"),"Candidate","Rating")
    s <- problem$specification; q <- s$quadrature; s$quadrature <- NULL
    p <- .1*sin(seq_along(problem$start)); n <- problem$n_person
    scalar <- gmfrm_louis_reference(s,p,matrix(rep(q$nodes,each=n),n),matrix(rep(log(q$weights),each=n),n))
    vector <- mfrm_gmfrm_louis(s,p,64L,96)
    expect_equal(vector$information,scalar$information,tolerance=1e-8)
    expect_equal(vector$gradient,-colSums(scalar$scores),tolerance=1e-8)
    expect_equal(vector$nll,-sum(scalar$log_marginal),tolerance=1e-8)
    # At a nonstationary point, the complete-logit second derivatives cannot
    # be dropped. This directional check includes their cross/slope blocks.
    direction <- cos(seq_along(p)); direction <- direction/sqrt(sum(direction^2)); h <- 1e-5
    numerical <- (problem$marginal(p+h*direction)$gradient-problem$marginal(p-h*direction)$gradient)*n/(2*h)
    expect_equal(drop(vector$information%*%direction),numerical,tolerance=1e-7)
  }
})

test_that("the information reference never calls the working likelihood or Hessian", {
  run <- readRDS(test_path("fixtures","gmfrm-result.rds"))$run
  forbidden <- function(...) stop("working estimator was called")
  testthat::local_mocked_bindings(expand_params=forbidden,mfrm_gmfrm_segmented_evaluator=forbidden,
    mfrm_gmfrm_finish_interior=forbidden,mfrm_gmfrm_bounded_search=forbidden)
  x <- mfrm_gmfrm_louis(run$specification,run$candidate$native_parameters)
  expect_equal(x$nll,run$candidate$stages$reference$reference$nll,tolerance=1e-10)
  expect_true(all(eigen(x$information,symmetric=TRUE,only.values=TRUE)$values>0))
})

test_that("Wald output preserves native contrasts, log-scale endpoints and full covariance", {
  r <- readRDS(test_path("fixtures","gmfrm-wald-result.rds"))
  p <- length(r$run$parameter_names)
  C <- rbind(severity_difference=c(0,1,-1,0,0,0),dependent_item=c(0,0,0,-1,0,0))
  colnames(C) <- r$run$parameter_names
  x <- mfrm_gmfrm_wald(r,C,c(FALSE,TRUE)); tab <- x$intervals
  expect_true(x$information$eligible); expect_true(all(tab$NumericallyAvailable))
  expect_true(all(!tab$CoverageQualified)); expect_identical(x$source_identity,r$identity)
  variance <- diag(C%*%r$run$candidate$information$covariance%*%t(C))
  estimate <- drop(C%*%r$run$candidate$native_parameters)
  lower <- estimate-qnorm(.975)*sqrt(variance); upper <- estimate+qnorm(.975)*sqrt(variance)
  lower[2] <- exp(lower[2]); upper[2] <- exp(upper[2])
  expect_equal(tab$NativeSE,unname(sqrt(variance)),tolerance=1e-12)
  expect_equal(tab$Lower,unname(lower),tolerance=1e-12); expect_equal(tab$Upper,unname(upper),tolerance=1e-12)
  expect_identical(r$admission$structural_intervals,FALSE)
  expect_identical(mfrm_gmfrm_wald(r)$intervals$Target,r$run$parameter_names)
  expect_error(mfrm_gmfrm_wald(r,C,level=1),"strictly between")
  expect_error(mfrm_gmfrm_wald(r,C,NA),"exponentiation")
  expect_error(mfrm_gmfrm_wald(r,C*0),"nonzero")
  colnames(C) <- rev(colnames(C)); expect_error(mfrm_gmfrm_wald(r,C),"parameter order")
})

test_that("constraints, boundary refusals and discrepant information never acquire intervals", {
  r <- readRDS(test_path("fixtures","gmfrm-wald-result.rds"))
  original <- mfrm_gmfrm_louis
  testthat::local_mocked_bindings(mfrm_gmfrm_louis=function(...) {
    x <- original(...); x$information <- 2*x$information; x
  })
  x <- mfrm_gmfrm_wald(r)
  expect_false(x$information$eligible); expect_true(all(is.na(x$intervals$Lower)))
  expect_gt(x$information$checks["RetainedCovarianceChange"],.01)
  testthat::local_mocked_bindings(mfrm_gmfrm_louis=function(...) stop("unexpected reference call"))
  for(name in c("N20-observed.null","N20-b09.free")) {
    r <- readRDS(test_path("fixtures",paste0("gmfrm-wald-",name,".rds")))
    x <- mfrm_gmfrm_wald(r)
    expect_false(x$information$eligible); expect_null(x$information$reference)
    expect_true(all(!x$intervals$NumericallyAvailable)); expect_true(all(is.na(x$intervals$NativeSE)))
  }
  bad <- readRDS(test_path("fixtures","gmfrm-wald-result.rds"))
  bad$components$State[bad$components$Component=="category"] <- "unsupported_coordinate"
  # Isolate the new interval admission rule; this fixture is deliberately
  # resealed here, not presented as a numerically requalified source.
  bad$identity <- NULL; bad$identity <- mfrm_checkpoint_fingerprint(bad)
  x <- mfrm_gmfrm_wald(bad)
  expect_false(x$information$eligible); expect_null(x$information$reference)
  expect_match(x$information$reason,"category")
  r$run$parameter_names[1] <- "changed"
  expect_error(mfrm_gmfrm_wald(r),"changed after qualification")
})
