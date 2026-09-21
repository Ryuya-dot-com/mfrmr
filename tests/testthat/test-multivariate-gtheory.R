# Construct balanced data with exactly specified ANOVA covariance components.
# Orthonormal tensor contrasts provide independent mean-product targets.
mvgt_fixture <- function(indefinite = FALSE) {
  n <- c(4L, 3L, 4L)
  sources <- c("Person", "Rater", "Task", "Person:Rater", "Person:Task", "Rater:Task", "Residual")
  subsets <- list(1L, 2L, 3L, c(1L, 2L), c(1L, 3L), c(2L, 3L), 1:3)
  values <- list(c(1.2, .3, .3, .8), c(.2, .04, .04, .3),
    c(.3, -.02, -.02, .15), c(.4, .1, .1, .5),
    c(.3, -.06, -.06, .4), c(.15, .03, .03, .1), c(.6, .2, .2, .7))
  if (indefinite) values[[1L]] <- c(.01, .03, .03, .01)
  gamma <- setNames(lapply(values, matrix, nrow = 2L,
    dimnames = list(c("Content", "Organization"), c("Content", "Organization"))), sources)
  q <- lapply(n, function(k) qr.Q(qr(stats::contr.helmert(k))))
  average <- lapply(n, function(k) matrix(1 / sqrt(k), k, 1))
  y <- matrix(0, prod(n), 2)
  for (i in seq_along(subsets)) {
    s <- subsets[[i]]
    mp <- matrix(0, 2, 2)
    for (j in seq_along(subsets)) {
      if (all(s %in% subsets[[j]])) mp <- mp + prod(n[setdiff(1:3, subsets[[j]])]) * gamma[[j]]
    }
    b <- lapply(1:3, function(j) if (j %in% s) q[[j]] else average[[j]])
    basis <- kronecker(b[[3]], kronecker(b[[2]], b[[1]]))
    y <- y + basis[, 1:2, drop = FALSE] %*% chol(prod(n[s] - 1) * mp)
  }
  data <- expand.grid(Person = paste0("P", seq_len(n[1])),
    Rater = paste0("R", seq_len(n[2])), Task = paste0("T", seq_len(n[3])))
  data$Content <- y[, 1] + 10
  data$Organization <- y[, 2] + 20
  list(data = data, components = gamma, counts = n)
}

mvgt_common_task_data <- function() {
  path <- testthat::test_path("..", "..", "inst", "extdata", "mgenova-table12.csv")
  if (!file.exists(path)) path <- system.file("extdata", "mgenova-table12.csv", package = "mfrmr")
  read.csv(path)
}

test_that("common-task raw data reproduce mGENOVA Appendix E G-study and D-study values", {
  # Brennan (2001), Manual for mGENOVA 2.1, Table 12 (p. 32), Appendix E
  # (pp. 74-77): synthetic data from Generalizability Theory, Table 9.3.
  # All persons and items are shared across V and W. Here the item facet is Task.
  # This estimates matrices from the original scores, without substituting them.
  data <- mvgt_common_task_data()
  expect_equal(dim(data), c(60L, 4L))
  expect_equal(unname(colMeans(data[c("V", "W")])), c(4.516666666666667, 5.083333333333333))
  g <- mfrm_multivariate_gstudy(data, c("V", "W"), rater = NULL)
  expect_identical(g$design$counts, c(Person = 10L, Task = 6L))
  expect_null(g$design$rater)
  expect_equal(g$degrees_of_freedom$DF, c(9, 5, 45))
  expected_mp <- list(Person = c(3.46111, 2.62037, 2.62037, 3.75000),
    Task = c(4.69667, 1.62333, 1.62333, 4.73667),
    Residual = c(1.25222, .70481, .70481, 1.53667))
  expected_vc <- list(Person = c(.36815, .31926, .31926, .36889),
    Task = c(.34444, .09185, .09185, .32000),
    Residual = c(1.25222, .70481, .70481, 1.53667))
  # The manual prints only five decimals; upper-triangle component entries
  # can be correlations. Expected symmetric matrices use the covariances.
  expect_equal(lapply(g$mean_products, function(m) round(as.vector(m), 5)), expected_mp)
  expect_equal(lapply(g$components, function(m) round(as.vector(m), 5)), expected_vc)
  expect_true(all(g$component_diagnostics$PositiveSemidefinite))
  expect_output(print(g), "10 persons, 6 tasks")
  d <- mfrm_multivariate_d_study(g, weights = c(V = -1, W = 1))
  expect_identical(d$design_grid, data.frame(Tasks = 6L))
  expect_false("Raters" %in% names(d$coefficients))
  expected <- rbind(
    c(.36815, .20870, .26611, .63820, .58044, .45684, .51586),
    c(.36889, .25611, .30944, .59022, .54382, .50607, .55628),
    c(.09852, .22988, .31000, .30000, .24116, .47945, .55678))
  measures <- c("UniverseVariance", "RelativeErrorVariance", "AbsoluteErrorVariance",
                "G", "Phi", "RelativeSEM", "AbsoluteSEM")
  expect_equal(unname(round(as.matrix(d$coefficients[measures]), 5)), expected)
  expect_true(all(d$coefficients$Status == "Available"))
  expect_equal(unname(round(d$covariances[[1]]$RelativeError, 5)),
    matrix(c(.20870, .11747, .11747, .25611), 2))
  expect_equal(unname(round(d$covariances[[1]]$AbsoluteError, 5)),
    matrix(c(.26611, .13278, .13278, .30944), 2))
  expect_output(print(d), "Means over common random tasks")
})

test_that("one-facet projections preserve averaging, score identity and contrast meaning", {
  data <- mvgt_common_task_data()
  g <- mfrm_multivariate_gstudy(data, c("V", "W"), rater = NULL)
  d <- mfrm_multivariate_d_study(g, data.frame(Tasks = c(3L, 6L, 12L)), c(V = -1, W = 1))
  composite <- d$coefficients[d$coefficients$Kind == "Composite", ]
  expect_equal(composite$UniverseVariance, rep(composite$UniverseVariance[2], 3))
  expect_equal(composite$RelativeErrorVariance, composite$RelativeErrorVariance[2] * c(2, 1, .5))
  expect_equal(composite$AbsoluteErrorVariance, composite$AbsoluteErrorVariance[2] * c(2, 1, .5))
  data$Difference <- data$W - data$V
  direct <- mfrm_multivariate_d_study(mfrm_multivariate_gstudy(data, "Difference", rater = NULL),
    d$design_grid)$coefficients
  expect_equal(direct$G, composite$G)
  expect_equal(direct$AbsoluteSEM, composite$AbsoluteSEM)
  one <- mfrm_multivariate_d_study(mfrm_multivariate_gstudy(data, "V", rater = NULL),
    d$design_grid)$coefficients
  expect_equal(one$Phi, d$coefficients$Phi[d$coefficients$Score == "V"])
  shuffled <- data[rev(seq_len(nrow(data))), ]
  names(shuffled)[1:2] <- c("Candidate", "Item")
  again <- mfrm_multivariate_gstudy(shuffled, c("W", "V"),
    person = "Candidate", rater = NULL, task = "Item")
  expect_equal(again$components, lapply(g$components, function(m) m[2:1, 2:1]))
  # Adding an unselected column is explicit and does not introduce a facet.
  data$Rater <- NA_character_
  expect_identical(mfrm_multivariate_gstudy(data, c("V", "W"), rater = NULL), g)
  # Missing rater identifiers must not silently switch the default model.
  expect_error(mfrm_multivariate_gstudy(data, c("V", "W")), "nonmissing, nonblank")
})

test_that("one-facet designs refuse incomplete cells and unavailable rater projections", {
  data <- mvgt_common_task_data()
  scores <- c("V", "W")
  expect_error(mfrm_multivariate_gstudy(data, scores), "column names")
  expect_error(mfrm_multivariate_gstudy(data[-1, ], scores, rater = NULL), "complete, balanced")
  expect_error(mfrm_multivariate_gstudy(rbind(data, data[1, ]), scores, rater = NULL), "Duplicate")
  expect_error(mfrm_multivariate_gstudy(subset(data, Task == 1), scores, rater = NULL), "at least two")
  expect_error(mfrm_multivariate_gstudy(data, scores, rater = NULL, task = NULL), "distinct")
  missing <- data
  missing$V[1] <- NA_real_
  expect_error(mfrm_multivariate_gstudy(missing, scores, rater = NULL), "finite numeric")
  # Multiple raters cannot be dropped or averaged implicitly.
  crossed <- mvgt_fixture()$data
  expect_error(mfrm_multivariate_gstudy(crossed, c("Content", "Organization"), rater = NULL), "Duplicate")
  g <- mfrm_multivariate_gstudy(data, scores, rater = NULL)
  for (grid in list(data.frame(Raters = 1, Tasks = 6), data.frame(Raters = 6),
      data.frame(Tasks = 0), data.frame(Tasks = 1.5), data.frame(Tasks = NA_real_),
      data.frame(Tasks = numeric()))) {
    expect_error(mfrm_multivariate_d_study(g, grid), "positive integer Tasks")
  }
  # The common PSD policy also applies to the one-facet estimator.
  data$V <- data$V - ave(data$V, data$Person, FUN = mean)
  negative <- mfrm_multivariate_gstudy(data, scores, rater = NULL)
  expect_lt(negative$components$Person[1, 1], 0)
  expect_true(all(is.na(mfrm_multivariate_d_study(negative)$coefficients$G)))
})

test_that("balanced multivariate ANOVA recovers cross-covariances and matches a QR reference", {
  f <- mvgt_fixture()
  g <- mfrm_multivariate_gstudy(f$data, c("Content", "Organization"))
  expect_s3_class(g, "mfrm_multivariate_gstudy")
  expect_equal(g$components, f$components, tolerance = 1e-12)
  expect_true(all(g$component_diagnostics$PositiveSemidefinite))
  expect_equal(sum(g$degrees_of_freedom$DF), nrow(f$data) - 1)
  # Independent saturated linear-model QR effects plus EMS inversion.
  mm <- model.matrix(~ Person * Rater * Task, f$data)
  fit <- lm.fit(mm, as.matrix(f$data[c("Content", "Organization")]))
  assignment <- attr(mm, "assign")
  mp <- lapply(1:7, function(i) crossprod(fit$effects[assignment == i, , drop = FALSE]) / sum(assignment == i))
  subsets <- list(1L, 2L, 3L, c(1L, 2L), c(1L, 3L), c(2L, 3L), 1:3)
  ems <- matrix(0, 7, 7)
  for (i in 1:7) for (j in 1:7) {
    if (all(subsets[[i]] %in% subsets[[j]])) ems[i, j] <- prod(f$counts[setdiff(1:3, subsets[[j]])])
  }
  reference <- solve(ems, t(vapply(mp, as.vector, numeric(4))))
  expect_equal(unname(t(vapply(g$components, as.vector, numeric(4)))), unname(reference), tolerance = 1e-12)
  expect_identical(summary(g), g$component_diagnostics)
  expect_output(print(g), "highest-order interaction and residual are combined")
  # Row order and literal identifier column names do not change estimates.
  shuffled <- f$data[rev(seq_len(nrow(f$data))), ]
  names(shuffled)[1:3] <- c("Participant id", "Assessor id", "Task id")
  again <- mfrm_multivariate_gstudy(shuffled, c("Content", "Organization"),
    "Participant id", "Assessor id", "Task id")
  expect_equal(again$components, g$components, tolerance = 1e-12)
})

test_that("D-studies retain interaction-specific averaging and composite covariances", {
  f <- mvgt_fixture()
  g <- mfrm_multivariate_gstudy(f$data, c("Content", "Organization"))
  grid <- data.frame(Raters = c(2L, 4L), Tasks = c(3L, 3L))
  w <- c(Organization = .4, Content = .6)
  d <- mfrm_multivariate_d_study(g, grid, w)
  expect_s3_class(d, "mfrm_multivariate_d_study")
  expect_equal(nrow(d$coefficients), 6)
  expect_true(all(d$coefficients$Status == "Available"))
  expect_true(all(d$coefficients$Phi <= d$coefficients$G))
  # Hand-computed variances at 2 raters x 3 tasks.
  # Composite quadratic variances include BOTH symmetric covariance entries.
  u <- .6^2 * 1.2 + .4^2 * .8 + 2 * .6 * .4 * .3
  pr <- .6^2 * .4 + .4^2 * .5 + 2 * .6 * .4 * .1
  pt <- .6^2 * .3 + .4^2 * .4 - 2 * .6 * .4 * .06
  re <- .6^2 * .6 + .4^2 * .7 + 2 * .6 * .4 * .2
  r <- .6^2 * .2 + .4^2 * .3 + 2 * .6 * .4 * .04
  t <- .6^2 * .3 + .4^2 * .15 - 2 * .6 * .4 * .02
  rt <- .6^2 * .15 + .4^2 * .1 + 2 * .6 * .4 * .03
  relative <- pr / 2 + pt / 3 + re / 6
  absolute <- relative + r / 2 + t / 3 + rt / 6
  first <- d$coefficients[3L, ]
  expect_equal(first$UniverseVariance, u)
  expect_equal(first$RelativeErrorVariance, relative)
  expect_equal(first$AbsoluteErrorVariance, absolute)
  expect_equal(first$G, u / (u + relative))
  expect_equal(first$Phi, u / (u + absolute))
  expect_equal(first$RelativeSEM, sqrt(relative))
  expect_equal(first$AbsoluteSEM, sqrt(absolute))
  expect_equal(d$covariances[[1L]]$RelativeError,
    f$components[["Person:Rater"]] / 2 + f$components[["Person:Task"]] / 3 + f$components$Residual / 6)
  expect_identical(d$weights, w[g$design$scores])
  expect_identical(d$gstudy, g)
  expect_identical(summary(d), d$coefficients)
  expect_output(print(d), "no confidence intervals")
  baseline <- mfrm_multivariate_d_study(g)
  expect_equal(baseline$design_grid, data.frame(Raters = 3L, Tasks = 4L))
  expect_true(all(baseline$coefficients$Kind == "Score"))
  # Shared complete-case observations, no separate univariate averaging.
  opposite <- f$data
  opposite$Organization <- -opposite$Organization
  other <- mfrm_multivariate_d_study(mfrm_multivariate_gstudy(opposite,
    c("Content", "Organization")), grid, w)$coefficients
  expect_equal(other$G[other$Kind == "Score"], d$coefficients$G[d$coefficients$Kind == "Score"])
  expect_true(all(abs(other$G[other$Kind == "Composite"] - d$coefficients$G[d$coefficients$Kind == "Composite"]) > .001))
  # A single column reduces to the full-interaction univariate model.
  one <- mfrm_multivariate_gstudy(f$data, "Content")
  one_d <- mfrm_multivariate_d_study(one, grid)
  expect_equal(one_d$coefficients$G, d$coefficients$G[d$coefficients$Score == "Content"])
  expect_equal(one_d$coefficients$Phi, d$coefficients$Phi[d$coefficients$Score == "Content"])
  expect_equal(one_d$coefficients$RelativeErrorVariance[1], .4 / 2 + .3 / 3 + .6 / 6)
  # Perfectly duplicated scores give a rank-deficient but valid point projection.
  duplicated <- f$data
  duplicated$Organization <- duplicated$Content
  duplicate_g <- mfrm_multivariate_gstudy(duplicated, c("Content", "Organization"))
  expect_true(all(duplicate_g$component_diagnostics$Rank == 1L))
  duplicate_d <- mfrm_multivariate_d_study(duplicate_g, grid,
    c(Content = .6, Organization = .4))$coefficients
  expect_equal(duplicate_d$G[duplicate_d$Kind == "Composite"], one_d$coefficients$G)
  expect_equal(duplicate_d$RelativeSEM[duplicate_d$Kind == "Composite"], one_d$coefficients$RelativeSEM)
})

test_that("score order, score units and composite units are respected", {
  f <- mvgt_fixture()
  scores <- c("Content", "Organization")
  weights <- c(Content = .6, Organization = .4)
  g <- mfrm_multivariate_gstudy(f$data, scores)
  d <- mfrm_multivariate_d_study(g, weights = weights)$coefficients
  reversed <- mfrm_multivariate_d_study(mfrm_multivariate_gstudy(f$data, rev(scores)), weights = weights)$coefficients
  expect_equal(reversed[c(2, 1, 3), c("G", "Phi", "RelativeSEM", "AbsoluteSEM")],
    d[c("G", "Phi", "RelativeSEM", "AbsoluteSEM")], ignore_attr = TRUE)
  factors <- c(Content = 1e-4, Organization = 1e3)
  changed <- f$data
  changed[scores] <- sweep(as.matrix(changed[scores]), 2, factors, "*")
  scaled_g <- mfrm_multivariate_gstudy(changed, scores)
  scaled <- mfrm_multivariate_d_study(scaled_g, weights = weights / factors)$coefficients
  expect_identical(scaled_g$component_diagnostics$PositiveSemidefinite, g$component_diagnostics$PositiveSemidefinite)
  expect_equal(scaled$G, d$G)
  expect_equal(scaled$Phi, d$Phi)
  expect_equal(scaled$RelativeSEM[3], d$RelativeSEM[3])
  expect_equal(scaled$AbsoluteSEM[1:2], d$AbsoluteSEM[1:2] * unname(factors))
  double <- mfrm_multivariate_d_study(g, weights = 2 * weights)$coefficients[3, ]
  expect_equal(double$G, d$G[3])
  expect_equal(double$Phi, d$Phi[3])
  expect_equal(double$AbsoluteSEM, 2 * d$AbsoluteSEM[3])
  zero_weight <- mfrm_multivariate_d_study(g, weights = c(Content = 1, Organization = 0))$coefficients
  expect_equal(zero_weight$G[3], zero_weight$G[1])
  tiny <- mfrm_multivariate_d_study(g, weights = 1e-100 * weights)$coefficients[3, ]
  expect_equal(tiny$G, d$G[3])
  expect_equal(tiny$AbsoluteSEM / 1e-100, d$AbsoluteSEM[3])
  # A third, linearly dependent score preserves the same composite meaning.
  third <- f$data
  third$Language <- .5 * third$Content + third$Organization
  three <- mfrm_multivariate_d_study(mfrm_multivariate_gstudy(third,
    c(scores, "Language")), weights = c(Content = .2, Organization = .3, Language = .5))
  equivalent <- mfrm_multivariate_d_study(g, weights = c(Content = .45, Organization = .8))
  expect_equal(three$coefficients[4, c("G", "Phi", "AbsoluteSEM")],
    equivalent$coefficients[3, c("G", "Phi", "AbsoluteSEM")], ignore_attr = TRUE)
  expect_true(all(three$component_diagnostics$Dimension == 3L))
})

test_that("signed weights agree with direct difference scores and respect sign reversal", {
  data <- mvgt_fixture()$data
  g <- mfrm_multivariate_gstudy(data, c("Content", "Organization"))
  w <- c(Content = 1, Organization = -1)
  difference <- mfrm_multivariate_d_study(g, weights = w)$coefficients[3, ]
  data$Difference <- data$Content - data$Organization
  direct <- mfrm_multivariate_d_study(mfrm_multivariate_gstudy(data, "Difference"))$coefficients
  measures <- c("UniverseVariance", "RelativeErrorVariance", "AbsoluteErrorVariance",
                "G", "Phi", "RelativeSEM", "AbsoluteSEM")
  expect_equal(difference[measures], direct[measures], ignore_attr = TRUE)
  expect_equal(difference$UniverseVariance, 1.2 + .8 - 2 * .3)
  reversed <- mfrm_multivariate_d_study(g, weights = -w)$coefficients[3, ]
  expect_equal(reversed[measures], difference[measures])
  scaled <- mfrm_multivariate_d_study(g, weights = -2 * w)$coefficients[3, ]
  expect_equal(scaled[c("G", "Phi")], difference[c("G", "Phi")])
  expect_equal(scaled$AbsoluteSEM, 2 * difference$AbsoluteSEM)
  negative <- mfrm_multivariate_d_study(g,
    weights = c(Content = -1, Organization = 0))$coefficients
  expect_equal(negative[3, measures], negative[1, measures], ignore_attr = TRUE)
  # A contrast of identical scores has no universe variance, not perfect reliability.
  data$Organization <- data$Content
  zero <- mfrm_multivariate_d_study(mfrm_multivariate_gstudy(data,
    c("Content", "Organization")), weights = w)$coefficients[3, ]
  expect_equal(zero$UniverseVariance, 0)
  expect_true(is.na(zero$G) && is.na(zero$Phi))
  expect_identical(zero$Status, "Universe variance is not positive")
})

test_that("supplied mGENOVA matrices reproduce Appendix F D-study values", {
  # Brennan (2001), Manual for mGENOVA Version 2.1, Table 14 and Appendix F,
  # pp. 79-81. This is a D-study-only fixture, NOT a G-study estimate.
  # The original design has common tasks but local raters. Its zero
  # rater-related cross-covariances give the same arithmetic for this balanced
  # projection. This does not validate raw-data estimation or local-rater support.
  scores <- c("Listening", "Writing")
  values <- list(Person = c(.324, .356, .356, .691),
    Rater = c(.012, 0, 0, .010), Task = c(.127, .039, .039, .025),
    `Person:Rater` = c(.014, 0, 0, .047),
    `Person:Task` = c(.393, .030, .030, .159),
    `Rater:Task` = c(.022, 0, 0, .008), Residual = c(.317, 0, 0, .218))
  g <- structure(list(
    components = lapply(values, matrix, nrow = 2, dimnames = list(scores, scores)),
    score_scale = setNames(c(1, 1), scores),
    design = list(scores = scores, calculation_version = 1L,
      counts = c(Person = 50L, Rater = 2L, Task = 6L))),
    class = "mfrm_multivariate_gstudy")
  d <- mfrm_multivariate_d_study(g, weights = c(Listening = 1, Writing = -1))
  expect_true(all(d$coefficients$Status == "Available"))
  # Printed values have five decimal places. Upper triangles of the manual's
  # output matrices contain correlations; lower triangles contain covariances.
  expected <- rbind(
    c(.32400, .09892, .12792, .76611, .71695, .31451, .35765),
    c(.69100, .06817, .07800, .91021, .89857, .26109, .27928),
    c(.30300, .15708, .18292, .65858, .62356, .39634, .42769))
  measures <- c("UniverseVariance", "RelativeErrorVariance", "AbsoluteErrorVariance",
                "G", "Phi", "RelativeSEM", "AbsoluteSEM")
  expect_equal(unname(round(as.matrix(d$coefficients[measures]), 5)), expected)
  expect_equal(unname(d$covariances[[1]]$Universe), matrix(values$Person, 2))
  expect_equal(unname(round(d$covariances[[1]]$RelativeError, 5)),
    matrix(c(.09892, .00500, .00500, .06817), 2))
  expect_equal(unname(round(d$covariances[[1]]$AbsoluteError, 5)),
    matrix(c(.12792, .01150, .01150, .07800), 2))
})

test_that("inadmissible components are retained without usable coefficients", {
  f <- mvgt_fixture(indefinite = TRUE)
  g <- mfrm_multivariate_gstudy(f$data, c("Content", "Organization"))
  expect_equal(g$components, f$components, tolerance = 1e-12)
  expect_false(g$component_diagnostics$PositiveSemidefinite[1])
  expect_true(all(diag(g$components$Person) > 0))
  d <- mfrm_multivariate_d_study(g, weights = c(Content = .5, Organization = .5))
  expect_true(all(is.na(as.matrix(d$coefficients[c("G", "Phi", "RelativeSEM", "AbsoluteSEM")]))))
  expect_true(all(d$coefficients$Status == "Non-PSD component estimates"))
  expect_equal(d$coefficients$UniverseVariance[1], .01)
  # Negative diagonal estimates are also kept, not replaced with zero.
  f <- mvgt_fixture()
  f$data$Content <- f$data$Content - ave(f$data$Content, f$data$Person, FUN = mean)
  negative <- mfrm_multivariate_gstudy(f$data, c("Content", "Organization"))
  expect_lt(negative$components$Person[1, 1], 0)
  expect_true(all(is.na(mfrm_multivariate_d_study(negative)$coefficients$G)))
  constant <- f$data
  constant$Content <- constant$Organization <- 7
  zero <- mfrm_multivariate_gstudy(constant, c("Content", "Organization"))
  expect_true(all(unlist(zero$components) == 0))
  expect_true(all(is.na(mfrm_multivariate_d_study(zero)$coefficients$G)))
  expect_true(all(mfrm_multivariate_d_study(zero)$coefficients$Status == "Universe variance is not positive"))
})

test_that("incomplete, repeated or malformed observed designs are refused", {
  data <- mvgt_fixture()$data
  scores <- c("Content", "Organization")
  expect_error(mfrm_multivariate_gstudy(data[-1, ], scores), "complete, balanced")
  expect_error(mfrm_multivariate_gstudy(rbind(data, data[1, ]), scores), "Duplicate")
  expect_error(mfrm_multivariate_gstudy(subset(data, Rater == "R1"), scores), "at least two")
  for (value in list(NA_real_, NaN, Inf, "unknown")) {
    bad <- data
    bad$Content[1] <- value
    expect_error(mfrm_multivariate_gstudy(bad, scores), "finite numeric")
  }
  for (value in list(NA_character_, " ")) {
    bad <- data
    bad$Rater <- as.character(bad$Rater)
    bad$Rater[1] <- value
    expect_error(mfrm_multivariate_gstudy(bad, scores), "nonmissing, nonblank")
  }
  bad <- data
  bad$Content <- factor(bad$Content)
  expect_error(mfrm_multivariate_gstudy(bad, scores), "finite numeric")
  expect_error(mfrm_multivariate_gstudy(data, c("Content", "Content")), "distinct")
  expect_error(mfrm_multivariate_gstudy(data, "Rater"), "distinct")
  expect_error(mfrm_multivariate_gstudy(data, "Absent"), "distinct")
  expect_error(mfrm_multivariate_gstudy(data, scores, person = c("Person", "Task")), "distinct")
  expect_error(mfrm_multivariate_gstudy(data, scores, rater = "Person"), "distinct")
  extra <- data
  extra$Unused <- NA_real_
  expect_identical(mfrm_multivariate_gstudy(extra, scores), mfrm_multivariate_gstudy(data, scores))
  bad <- data
  bad$Content <- bad$Content * 1e200
  expect_error(mfrm_multivariate_gstudy(bad, scores), "rescale")
  bad$Content <- data$Content * 1e-200
  expect_error(mfrm_multivariate_gstudy(bad, scores), "rescale")
})

test_that("D-study input checks preserve the declared covariance identities", {
  g <- mfrm_multivariate_gstudy(mvgt_fixture()$data, c("Content", "Organization"))
  for (grid in list(data.frame(Raters = 0, Tasks = 3), data.frame(Raters = 2.5, Tasks = 3),
      data.frame(Raters = NA_real_, Tasks = 3), data.frame(Raters = Inf, Tasks = 3),
      data.frame(Raters = "2", Tasks = 3), data.frame(Raters = 2),
      data.frame(Raters = 2, Tasks = 3, Persons = 100), data.frame(Raters = numeric(), Tasks = numeric()))) {
    expect_error(mfrm_multivariate_d_study(g, grid), "positive integer")
  }
  for (w in list(c(.6, .4), c(Content = .6), c(Content = .6, Absent = .4),
      c(Content = .6, Content = .4),
      c(Content = 0, Organization = 0), c(Content = Inf, Organization = 1),
      c(Content = NA_real_, Organization = 1))) {
    expect_error(mfrm_multivariate_d_study(g, weights = w), "name every score")
  }
  bad <- g
  bad$components$Person[1, 2] <- 9
  expect_error(mfrm_multivariate_d_study(bad), "covariance matrices")
  bad <- g
  bad$components$Person <- bad$components$Person[2:1, 2:1]
  expect_error(mfrm_multivariate_d_study(bad), "score identities")
  bad <- g
  bad$components$Task <- NULL
  expect_error(mfrm_multivariate_d_study(bad), "incomplete")
  expect_error(mfrm_multivariate_d_study(list()), "current mfrm_multivariate_gstudy")
  expect_error(mfrm_multivariate_d_study(g, weights = c(Content = 1e308, Organization = 1e308)), "rescale")
  expect_error(mfrm_multivariate_d_study(g, weights = c(Content = 1e-200, Organization = 1e-200)), "rescale")
})
