selection_candidate <- function(nll=10, fixed=integer(), values=numeric(), qualified=TRUE) {
  p <- c(.2,-.3,.4); p[fixed] <- values; free <- setdiff(1:3,fixed)
  list(status=if(qualified) "reference_qualified_local_candidate" else "boundary_review_required",
    fixed=fixed,selected=list(parameters=p,evaluation=list(value=nll)),native_parameters=p,
    information=if(qualified) list(parameters=p,free=free,covariance=diag(length(free))) else NULL,
    information_scope=if(!qualified) "unavailable" else if(length(fixed)) "conditional_nuisance" else "joint_unrestricted",
    stages=list(reference=list(passed=qualified,reference=list(qualified=qualified,nll=nll))),
    search=list(optimizer=list(convergence=1L)))
}
selection_pair <- function(nll=c(10,10), fixed=integer(), values=numeric()) {
  candidates <- lapply(nll,selection_candidate,fixed=fixed,values=values)
  names(candidates) <- c("retained","neutral")
  list(candidates=candidates,starts=names(candidates),reference_nll=setNames(nll,names(candidates)))
}
selection_comparison <- function(kind,nll,fixed=integer(),values=numeric(),verified=TRUE)
  list(kind=kind,nll=nll,fixed=fixed,values=values,verified=verified)

test_that("selection keeps the best agreed local candidate and its complete information", {
  x <- selection_pair(c(10,10-4e-6)); a <- do.call(mfrm_gmfrm_select_candidates,x)
  expect_identical(a$status,"local_candidate_selected")
  expect_identical(a$selected,"neutral")
  expect_identical(a$candidate,x$candidates$neutral)
  expect_identical(a$candidate$search$optimizer$convergence,1L)
  expect_match(a$global_optimality,"not assessed")
  expect_identical(a$interval_qualification,"not assessed")
  x <- selection_pair(); x$candidates <- rev(x$candidates)
  expect_identical(do.call(mfrm_gmfrm_select_candidates,x)$selected,"retained")
})

test_that("disagreement and unfinished starts cannot be hidden by selecting a passing point", {
  x <- selection_pair(c(10,10.01)); a <- do.call(mfrm_gmfrm_select_candidates,x)
  expect_identical(a$status,"start_disagreement"); expect_null(a$candidate)
  x <- selection_pair(c(10,9)); x$candidates$neutral <- selection_candidate(9,qualified=FALSE)
  a <- do.call(mfrm_gmfrm_select_candidates,x)
  expect_identical(a$status,"incomplete_start_qualification")
  expect_true(a$dominated); expect_null(a$candidate)
  expect_equal(a$best_known_nll,9)
  x$candidates$retained <- selection_candidate(10,qualified=FALSE)
  x$reference_nll[] <- NA_real_; a <- do.call(mfrm_gmfrm_select_candidates,x)
  expect_identical(a$status,"no_qualified_candidate")
  expect_true(is.na(a$best_known_nll)); expect_null(a$candidate)
  expect_equal(a$attempts$ReportedNLL,c(10,9))
})

test_that("a better feasible point or limit vetoes selection but cannot become an estimate", {
  for(kind in c("feasible_point","feasible_limit")) {
    x <- selection_pair(); x$comparisons <- list(witness=selection_comparison(kind,9))
    a <- do.call(mfrm_gmfrm_select_candidates,x)
    expect_identical(a$status,"dominated_candidate")
    expect_true(a$dominated); expect_null(a$candidate); expect_true(is.na(a$selected))
    expect_equal(a$best_known_nll,9)
    expect_identical(a$evidence,x$comparisons)
  }
})

test_that("family lower bounds exclude families and never masquerade as attained values", {
  x <- selection_pair()
  x$comparisons <- list(low=selection_comparison("family_lower_bound",1),
    high=selection_comparison("family_lower_bound",11),
    close=selection_comparison("family_lower_bound",10+5e-7))
  a <- do.call(mfrm_gmfrm_select_candidates,x)
  expect_identical(a$status,"local_candidate_selected")
  expect_false(a$dominated); expect_equal(a$best_known_nll,10)
  expect_identical(a$comparisons$FamilyExcluded,c(FALSE,TRUE,FALSE))
})

test_that("unverified likelihoods remain recorded without changing selection", {
  x <- selection_pair()
  x$comparisons <- list(low=selection_comparison("feasible_point",1,verified=FALSE),
    missing=selection_comparison("feasible_limit",NA_real_,verified=FALSE))
  a <- do.call(mfrm_gmfrm_select_candidates,x)
  expect_identical(a$status,"local_candidate_selected")
  expect_equal(a$best_known_nll,10)
  expect_identical(a$comparisons$Verified,c(FALSE,FALSE))
})

test_that("feasible witnesses and family bounds respect their different constraint domains", {
  x <- selection_pair(fixed=1L,values=.5)
  x$comparisons <- list(free=selection_comparison("feasible_limit",1),
    other_null=selection_comparison("feasible_point",1,1L,.6),
    broad_bound=selection_comparison("family_lower_bound",11))
  a <- do.call(mfrm_gmfrm_select_candidates,x)
  expect_identical(a$status,"local_candidate_selected")
  expect_identical(a$comparisons$Applicable,c(FALSE,FALSE,TRUE))
  expect_identical(a$candidate$information_scope,"conditional_nuisance")
  x$comparisons$same_null <- selection_comparison("feasible_point",1,1L,.5)
  expect_identical(do.call(mfrm_gmfrm_select_candidates,x)$status,"dominated_candidate")
  x <- selection_pair()
  x$comparisons <- list(null_bound=selection_comparison("family_lower_bound",11,1L,.5),
    null_point=selection_comparison("feasible_point",9,1L,.5))
  a <- do.call(mfrm_gmfrm_select_candidates,x)
  expect_identical(a$comparisons$Applicable,c(FALSE,TRUE))
  expect_identical(a$status,"dominated_candidate")
})

test_that("missing starts and incompatible point or null records are refused", {
  x <- selection_pair(); x$candidates$neutral <- NULL
  expect_error(do.call(mfrm_gmfrm_select_candidates,x),"every prescribed start")
  x <- selection_pair(); x$reference_nll <- x$reference_nll["retained"]
  expect_error(do.call(mfrm_gmfrm_select_candidates,x),"every prescribed start")
  x <- selection_pair(); x$candidates$neutral <- selection_candidate(10,1L,.5)
  expect_error(do.call(mfrm_gmfrm_select_candidates,x),"original constraint")
  x <- selection_pair(fixed=1L,values=.5); x$candidates$neutral <- selection_candidate(10,1L,.6)
  expect_error(do.call(mfrm_gmfrm_select_candidates,x),"original constraint")
  x <- selection_pair(); x$reference_nll[1] <- 9
  expect_error(do.call(mfrm_gmfrm_select_candidates,x),"does not match")
  x <- selection_pair(); x$reference_nll[1] <- NA_real_
  expect_error(do.call(mfrm_gmfrm_select_candidates,x),"missing its matching reference")
  x <- selection_pair(); x$comparisons <- list(bad=selection_comparison("feasible_point",NA_real_))
  expect_error(do.call(mfrm_gmfrm_select_candidates,x),"Invalid comparison")
})
