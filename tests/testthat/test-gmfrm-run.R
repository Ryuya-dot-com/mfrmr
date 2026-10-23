run_problem <- function(K=1L) {
  d <- expand.grid(Candidate=paste0("p",1:3),Item=c("i1","i2"),Judge=paste0("j",1:3))
  d <- d[-1,]; d$Rating <- rep(0:K,length.out=nrow(d))
  names(d)[2:3] <- c("First owner","Second owner")
  mfrm_gmfrm_problem(d,K,gauss_hermite_normal(241L),c("First owner","Second owner"),"Candidate","Rating")
}

test_that("generic independent references agree with working and fixed-rule equations", {
  for(K in c(1L,3L)) {
    problem <- run_problem(K); s <- problem$specification; common <- problem$common
    p <- .15*sin(seq_along(problem$start)); s$quadrature <- NULL
    ev <- mfrm_gmfrm_segmented_evaluator(common$idx,common$config,common$sizes)
    ref <- mfrm_gmfrm_reference(s)(NULL,p); working <- ev$evaluate(p)
    fixed <- problem$marginal(p)
    expect_true(ref$reference$qualified)
    expect_equal(ref$reference$nll,working$value,tolerance=1e-9)
    expect_equal(ref$native_gradient,working$gradient,tolerance=1e-8)
    expect_equal(ref$reference$nll,-fixed$logLik,tolerance=1e-8)
    expect_equal(ref$native_gradient,fixed$gradient*problem$n_person,tolerance=1e-7)
    direction <- cos(seq_along(p)); direction <- direction/sqrt(sum(direction^2)); h <- 1e-5
    plus <- mfrm_gmfrm_reference_integrate(mfrm_gmfrm_reference_design(s,p+h*direction),FALSE)
    minus <- mfrm_gmfrm_reference_integrate(mfrm_gmfrm_reference_design(s,p-h*direction),FALSE)
    expect_equal((plus-minus)/(2*h),sum(ref$native_gradient*direction),tolerance=1e-7)
    expect_true(all(ref$score_error$rule>=0)); expect_true(all(ref$score_error$tail>=0))
    expect_length(ref$native_gradient,length(p))
    expect_length(ref$reference$people,3L)
  }
})

test_that("independent reference does not call working parameter, response or quadrature kernels", {
  problem <- run_problem(); s <- problem$specification; s$quadrature <- NULL
  forbidden <- function(...) stop("working kernel was called")
  testthat::local_mocked_bindings(expand_params=forbidden,mfrm_legendre_unit_rule=forbidden,
    mfrm_segmented_relative_logits=forbidden,mfrm_gmfrm_coordinates=forbidden,
    mfrm_jml_probability_bundle=forbidden)
  r <- mfrm_gmfrm_reference(s)(NULL,unname(problem$start))
  expect_true(r$reference$qualified)
  expect_true(is.finite(r$reference$nll))
})

test_that("both boundary charts retain finite response laws without native information", {
  for(K in c(1L,3L)) {
    problem <- run_problem(K); s <- problem$specification; s$quadrature <- NULL; x <- problem$common
    p <- .1*sin(seq_along(problem$start))
    for(chart in c("rater_intercepts","common_scale")) {
      ev <- mfrm_gmfrm_natural_evaluator(x$idx,x$config,x$sizes,chart)
      ref <- mfrm_gmfrm_reference(s,chart)
      for(indices in unique(list(ev$natural[1L],ev$natural))) {
        z <- ev$from_native(p); z[indices] <- 0
        r <- ref(z,NULL)
        expect_equal(r$reference$nll,ev$value(z),tolerance=1e-9)
        expect_lte(r$reference$relative_error,1e-8)
        expect_null(r$native_gradient)
      }
    }
  }
})

test_that("caller binds data, native starts, constraints, model roles and reference", {
  problem <- run_problem(3L); s <- problem$specification; p <- unname(problem$start)
  args <- c(s[c("data","max_score","slope_facets","person","score")],
    list(starts=list(neutral=p,perturbed=p+.01*sin(seq_along(p))),fixed=integer()))
  testthat::local_mocked_bindings(mfrm_gmfrm_procedure=function(starts,native,natural,reference,fixed,comparisons,maxit) {
    expect_named(starts,c("neutral","perturbed")); expect_identical(maxit,400L)
    expect_equal(starts$neutral,natural$from_native(p))
    expect_equal(reference(starts$neutral,p)$reference$nll,native$value(p),tolerance=1e-8)
    list(status="test-bound-caller",candidate=NULL)
  })
  answer <- do.call(mfrm_gmfrm_run,args)
  expect_identical(answer$specification,s[setdiff(names(s),"quadrature")])
  expect_identical(answer$native_starts,args$starts)
  expect_identical(answer$parameter_names,names(problem$start))
  expect_identical(answer$admission[c("public_fit","intervals","person_scoring")],
    list(public_fit=FALSE,intervals=FALSE,person_scoring=FALSE))
  expect_false(inherits(answer,"mfrm_fit"))
  path <- tempfile(); on.exit(unlink(path), add = TRUE); saveRDS(answer,path); expect_identical(readRDS(path),answer)
  bad <- args; bad$starts$neutral <- setNames(p,rev(names(problem$start)))
  expect_error(do.call(mfrm_gmfrm_run,bad),"parameter order")
  bad <- args; bad$comparisons <- list(foreign=list(nll=1,specification=list()))
  expect_error(do.call(mfrm_gmfrm_run,bad),"exact same data/model")
  bad <- args; bad$data <- rbind(bad$data,bad$data[1,])
  expect_error(do.call(mfrm_gmfrm_run,bad),"Repeated person-facet")
})

test_that("reference failures are propagated instead of manufacturing successful values", {
  problem <- run_problem(); s <- problem$specification; s$quadrature <- NULL
  p <- unname(problem$start)
  expect_error(mfrm_gmfrm_reference(s)(NULL,p[-1]),"finite native parameter")
  expect_error(mfrm_gmfrm_reference(s)(NULL,replace(p,length(p),1000)),"finite interior")
  testthat::local_mocked_bindings(mfrm_gmfrm_reference_integral=function(...) stop("reference arithmetic refusal"))
  expect_error(mfrm_gmfrm_reference(s)(NULL,p),"reference arithmetic refusal")
})

test_that("boundary reference scales tiny likelihoods before applying a relative accuracy gate", {
  for(K in c(1L,3L)) {
    problem <- run_problem(K); s <- problem$specification; s$quadrature <- NULL; x <- problem$common
    ev <- mfrm_gmfrm_natural_evaluator(x$idx,x$config,x$sizes,"rater_intercepts")
    z <- ev$from_native(unname(problem$start)); z[ev$natural] <- 0
    z[1L+seq_len(3L*K)] <- 200
    # All slopes are zero: identical logits -200*k are constant in theta.
    categories <- 0:K; log_normalizer <- log(sum(exp(-200*categories)))
    exact <- sum(200*s$data[[s$score]]+log_normalizer)
    r <- mfrm_gmfrm_reference(s)(z,NULL)
    expect_gt(exact,1000)
    expect_equal(r$reference$nll,exact,tolerance=1e-12)
    expect_lte(r$reference$relative_error,1e-8)
    expect_null(r$native_gradient)
  }
})
