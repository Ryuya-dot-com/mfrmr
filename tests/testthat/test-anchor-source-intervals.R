anchor_checked_population <- function(...) withCallingHandlers(
  mfrm_population_intervals(...), warning = function(w) {
    if (startsWith(conditionMessage(w), "Experimental pointwise population intervals:"))
      invokeRestart("muffleWarning")
  })

anchor_source_fixture <- local({
  cache <- list()
  function(model = "RSM", fixed = FALSE, integration = "adaptive") {
    key <- paste(model, fixed, integration)
    if (!is.null(cache[[key]])) return(cache[[key]])
    d <- load_mfrmr_data("example_core")
    d <- d[d$Person %in% unique(d$Person)[1:24], ]
    d$Score <- d$Score - 1L
    a <- data.frame(Facet = "Rater", Level = c("R01", "R02"), Anchor = c(.2, -.1))
    f <- suppressWarnings(fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
      model = model, step_facet = if (model == "PCM") "Criterion" else NULL,
      rating_min = 0, rating_max = 3,
      spec = list(anchors = a, noncenter_facet = "Rater", population_formula = ~1,
        person_data = unique(d["Person"]), population_sd = if (fixed) .8 else NULL),
      control = list(mml_engine = "direct", mml_integration = integration,
        quad_points = if (integration == "fixed") 121L else 61L, maxit = 400L, reltol = 1e-11)))
    va <- matrix(c(.04,.01,.01,.03), 2, dimnames = list(a$Level, a$Level))
    ci <- suppressWarnings(mfrm_facet_intervals(f, "Rater",
      anchor_covariance = va, independent_anchors = TRUE))
    cache[[key]] <<- list(fit = f, covariance = va, intervals = ci)
    cache[[key]]
  }
})

test_that("estimated-variance anchor propagation preserves the log scale and full covariance", {
  skip_on_cran()
  for (model in c("RSM", "PCM")) {
    x <- anchor_source_fixture(model); f <- x$fit; ci <- x$intervals
    expect_null(f$population$fixed_sd)
    expect_true(all(ci$checks$Passed))
    expect_true(ci$anchor_uncertainty$eligible)
    expect_identical(ci$settings$location_reference, "direct_anchor_origin")
    expect_true(all(ci$table$Status == "available"))
    expect_false(any(ci$table$CoverageQualified))
    s <- ci$anchor_uncertainty$sensitivity
    slices <- build_param_slices(build_param_sizes(f$config))
    # Common shifts of anchors change the origin, not scale or fitted probabilities.
    shift <- numeric(nrow(s)); shift[c(slices$Rater, slices$beta)] <- 1
    expect_equal(unname(rowSums(s)), shift, tolerance = 1e-5)
    expect_equal(unname(vcov(ci)[1:2,1:2]), unname(x$covariance), tolerance = 1e-10)
    pop <- anchor_checked_population(ci, contrasts = matrix(1,1,1,
      dimnames = list("Mean", "(Intercept)")))
    expect_identical(pop$table$Status, rep("available",3L))
    expect_equal(pop$table$Estimate[1], pop$table$Estimate[2])
    expect_equal(pop$table$SE[1], pop$table$SE[2])
    z <- qnorm(.975); v <- pop$table[3,]
    expect_equal(c(v$Lower,v$Upper), exp(v$WorkingEstimate+c(-1,1)*z*v$WorkingSE))
    expect_equal(v$SE, v$Estimate*v$WorkingSE)
    expect_equal(v$AnchorSourceSE, v$Estimate*v$AnchorSourceWorkingSE)
    expect_true(all(pop$table$SE >= pop$table$ConditionalSE))
    at <- c(slices$beta, slices$log_sigma2)
    expect_equal(unname(vcov(pop)), unname(ci$parameter_covariance[at,at]))
    expect_equal(as.numeric(pop$contrast_covariance), vcov(pop)[1,1])
    zero <- suppressWarnings(mfrm_facet_intervals(f,"Rater",
      anchor_covariance = 0*x$covariance, independent_anchors = TRUE))
    expect_equal(zero$table$SE, zero$table$ConditionalSE)
    expect_identical(zero$table$Status[1:2], rep("fixed",2L))
    zp <- anchor_checked_population(zero)
    expect_equal(zp$table$SE,zp$table$ConditionalSE)
    expect_equal(c(zp$table$Lower,zp$table$Upper),
      c(zp$table$ConditionalLower,zp$table$ConditionalUpper))
    expect_error(mfrm_facet_intervals(f,"Rater",method="profile",
      contrasts=matrix(c(0,0,1,-1),1,dimnames=list("difference",ci$table$Target))),
      "unanchored centered")
    expect_error(mfrm_facet_intervals(f,"Rater",method="sandwich"), "method = 'model'")
  }
})

test_that("fixed SD and fixed-grid source propagation remain supported", {
  skip_on_cran()
  for (fixed in c(FALSE,TRUE)) {
    x <- anchor_source_fixture(fixed=fixed,integration="fixed")
    pop <- anchor_checked_population(x$intervals)
    expect_true(x$intervals$anchor_uncertainty$eligible)
    expect_identical(pop$table$Status, c("available",if(fixed)"fixed" else "available"))
    expect_equal(nrow(vcov(pop)),if(fixed)1L else 2L)
    if(fixed) {
      expect_equal(pop$table$Estimate[2],.64)
      expect_true(all(is.na(pop$table[2,c("SE","Lower","Upper","WorkingSE")])) )
    }
  }
})

test_that("anchor-source results preserve unavailable states, source identity and saved workflows", {
  skip_on_cran()
  x <- anchor_source_fixture(); f <- x$fit; ci <- x$intervals
  expect_error(mfrm_facet_intervals(f,"Rater",anchor_covariance=x$covariance),"must be independent")
  bad <- x$covariance; bad[1,2] <- .2
  expect_error(mfrm_facet_intervals(f,"Rater",anchor_covariance=bad,independent_anchors=TRUE),"symmetric")
  bad <- matrix(c(1,2,2,1),2,dimnames=dimnames(bad))
  expect_error(mfrm_facet_intervals(f,"Rater",anchor_covariance=bad,independent_anchors=TRUE),"positive semidefinite")
  request <- mfrmr_anchor_uncertainty_request(f,x$covariance,TRUE)
  conditional <- suppressWarnings(mfrm_facet_intervals(f,"Rater"))
  conditional$parameter_covariance <- NULL
  failed <- mfrmr_anchor_uncertainty_intervals(conditional,request)
  expect_true(all(failed$table$Status=="anchor_propagation_unavailable"))
  expect_true(all(is.na(failed$table$SE)))
  expect_identical(failed$table$Estimate,ci$table$Estimate)
  cp <- anchor_checked_population(f); cp$parameter_covariance <- NULL
  failedp <- mfrmr_anchor_uncertainty_intervals(cp,request)
  expect_true(all(failedp$table$Status=="anchor_propagation_unavailable"))
  expect_equal(dim(vcov(failedp)),c(2L,2L))
  pop <- anchor_checked_population(ci)
  path <- tempfile(fileext=".rds"); on.exit(unlink(path),add=TRUE)
  saveRDS(list(ci=ci,pop=pop),path); saved <- readRDS(path)
  expect_identical(summary(saved$ci),summary(ci))
  expect_identical(confint(saved$pop),confint(pop))
  expect_true(isTRUE(all.equal(plot_data(saved$pop),plot_data(pop),
    tolerance=0,check.environment=FALSE)))
  expect_identical(anchor_checked_population(saved$ci)$table,pop$table)
  saved$ci$anchor_uncertainty$covariance[1,1] <- 2
  expect_error(anchor_checked_population(saved$ci),"unchanged fit")
  expect_equal(f,x$intervals$fit,tolerance=0)
})
