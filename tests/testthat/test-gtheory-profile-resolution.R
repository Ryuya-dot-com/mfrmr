test_that("all REML target searches reject cutoffs below deviance resolution", {
  v <- c(1,.2,1)
  s <- list(valid=TRUE,status="Checked",relative_variances=v,components=v,
    sigma2=1,fit=list(objective=100))
  joint <- list(valid=TRUE,status="Checked",fit=list(covariance=.2,
    factors=list(diag(2)),fit=list(objective=100)))
  local_mocked_bindings(
    .mfrm_mvgt_profile_at=function(...)stop("Unexpected target optimization"),
    .mfrm_mvgt_variance_at=function(...)stop("Unexpected target optimization"),
    .mfrm_mvgt_joint_fit=function(...)stop("Unexpected target optimization"),
    .mfrm_mvgt_contrast_profile_at=function(...)stop("Unexpected target optimization"),
    .mfrm_mvgt_sem_contrast_profile_at=function(...)stop("Unexpected target optimization"))
  a <- c(0,.2,.2); b <- c(0,.1,.1)
  for (level in c(1e-10,1e-200)) {
    results <- list(
      .mfrm_mvgt_profile_set(s,a,level),
      .mfrm_mvgt_variance_set(s,a,level),
      .mfrm_mvgt_joint_set(joint,1L,level),
      .mfrm_mvgt_contrast_profile_set(s,a,b,level),
      .mfrm_mvgt_contrast_profile_set(s,a,b,level,sem=TRUE))
    for (ans in results) {
      expect_true(is.finite(ans$center))
      expect_true(all(is.na(ans$bounds)))
      expect_match(ans$status,"cutoff below numeric resolution")
      expect_false(ans$cutoff$valid)
    }
    identical_plan <- .mfrm_mvgt_contrast_profile_set(s,a,a,level)
    expect_true(identical_plan$valid)
    expect_equal(identical_plan$bounds,c(0,0))
  }
  s$valid <- FALSE; s$status <- "Unresolved source"
  bad <- .mfrm_mvgt_profile_set(s,a,.95)
  expect_match(bad$status,"Unresolved source")
  expect_true(all(is.na(bad$bounds)))
})

test_that("profile cutoff accuracy scales to the requested level", {
  s <- list(valid=TRUE,components=c(1,1,1),sigma2=1,status="Checked",fit=list(objective=100))
  local_mocked_bindings(.mfrm_mvgt_variance_at=function(source,target,weights)
    list(target=target,weights=weights,lr=(target-1)^2/.04,valid=TRUE,
      check=list(kkt=0,error=0)))
  for (level in c(.001,.01,.5,.95)) {
    z <- .mfrm_mvgt_variance_set(s,c(0,0,1),level)
    expected <- 1+c(-1,1)*sqrt(qchisq(level,1)*.04)
    expect_equal(z$bounds,expected,tolerance=1e-9)
    expect_lte(max(abs((z$bounds-1)^2/.04-qchisq(level,1))),z$cutoff$tolerance)
  }
  expect_equal(.mfrm_mvgt_profile_cutoff(.95,100)$tolerance,1e-5)
})

test_that("profile unit restoration cannot turn a positive width into certainty", {
  ans <- list(center=1,bounds=c(.9,1.1),candidate_bounds=c(.9,1.1),status="Computed")
  for (restore in list(function(x)x*1e-200*1e-200,
      function(x)x*1e200*1e200,function(x)1+x*.Machine$double.eps/10)) {
    result <- .mfrm_mvgt_profile_restore(ans,restore)
    expect_false(result$available)
    expect_true(all(is.na(result$values[2:3])))
    expect_match(result$status,"reported units")
    expect_identical(ans$bounds,c(.9,1.1))
  }
  signed <- ans; signed$center <- 0
  signed$bounds <- signed$candidate_bounds <- c(-1,2)
  result <- .mfrm_mvgt_profile_restore(signed,function(x)x*1e-200)
  expect_true(result$available)
  expect_equal(result$values[2:3]/1e-200,c(-1,2))
  zero <- ans; zero$center <- 0; zero$bounds <- zero$candidate_bounds <- c(0,0)
  zero$status <- "Identical future errors"
  expect_true(.mfrm_mvgt_profile_restore(zero,identity)$available)
  failed <- ans; failed$bounds[] <- NA_real_; failed$status <- "Unresolved tail"
  expect_identical(.mfrm_mvgt_profile_restore(failed,identity)$status,failed$status)
})

test_that("REML composite normalization preserves reciprocal score and weight units", {
  skip_if_not_installed("lme4"); skip_if_not_installed("minqa")
  x <- read.csv(system.file("extdata","mgenova-table12.csv",package="mfrmr"))
  g <- mfrm_g_study(x,c("V","W"),rater=NULL)
  w <- c(V=.4,W=.6)
  source <- .mfrm_mvgt_profile_source(g,w)
  x$V <- x$V*1e100; x$W <- x$W*1e-100
  changed <- mfrm_g_study(x,c("V","W"),rater=NULL)
  scaled_w <- w*c(1e-100,1e100)
  other <- .mfrm_mvgt_profile_source(changed,scaled_w)
  expect_true(source$valid && other$valid)
  expect_equal(other$y,source$y,tolerance=1e-12)
  expect_equal(other$score_scale,source$score_scale,tolerance=1e-12)
  expect_equal(other$estimate,source$estimate,tolerance=1e-12)
  expect_equal(other$fit$objective,source$fit$objective,tolerance=1e-8)
  call <- function(g,w,level=.95)confint(g,parm="Residual",weights=w,
    method="reml_profile",assumption="normal",level=level)
  base <- call(g,w); scaled <- call(changed,scaled_w)
  expect_true(base$Available && scaled$Available)
  for (column in c("Estimate","IntervalCenter","Lower","Upper"))
    expect_equal(scaled[[column]],base[[column]],tolerance=1e-6)
  narrow <- call(g,w,1e-10)
  expect_false(narrow$Available)
  expect_true(is.finite(narrow$Estimate) && is.finite(narrow$IntervalCenter))
  expect_true(is.na(narrow$Lower) && is.na(narrow$Upper))
  expect_match(narrow$Status,"cutoff below numeric resolution")
})
