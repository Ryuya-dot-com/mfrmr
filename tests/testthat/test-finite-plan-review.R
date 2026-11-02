finite_plan_fixture <- function(duplicate = FALSE, reference = 1L) {
  g <- mfrm_g_study(mfrmr_example_gtheory_crossed, c("Content", "Organization"))
  grid <- data.frame(Raters = c(2, 3, 4), Tasks = c(6, 4, 3))
  if (duplicate) grid <- rbind(grid, grid[1, ])
  d <- mfrm_d_study(g, grid, c(Content = .5, Organization = .5))
  list(g = g, d = d, comparison = mfrm_multivariate_d_compare(d,
    reference = reference, assumption = "normal"))
}

test_that("finite-plan uncertainty agrees with independent MS covariance and numerical gradients", {
  z <- finite_plan_fixture()
  g <- z$g; d <- z$d; cmp <- z$comparison
  n <- unname(g$design$counts[1]); r <- unname(g$design$counts[2]); t <- unname(g$design$counts[3])
  L <- rbind(c(r*t,0,0,t,r,0,1), c(0,n*t,0,t,0,n,1),
    c(0,0,n*r,0,r,n,1), c(0,0,0,t,0,0,1), c(0,0,0,0,r,0,1),
    c(0,0,0,0,0,n,1), c(0,0,0,0,0,0,1))
  A <- solve(L)
  w <- c(.5, .5)
  ms <- vapply(g$mean_products, function(m) sum(outer(w, w) * m), numeric(1))
  theta <- drop(A %*% ms)
  df <- c(n-1, r-1, t-1, (n-1)*(r-1), (n-1)*(t-1), (r-1)*(t-1), (n-1)*(r-1)*(t-1))
  # The paired API uses 2 MS^2 / df, not the separate vcov(g) df+2 correction.
  C <- A %*% diag(2 * ms^2 / df) %*% t(A)
  metric <- function(v, plan) {
    r <- d$design_grid$Raters[plan]; t <- d$design_grid$Tasks[plan]
    relative <- v[4]/r + v[5]/t + v[7]/(r*t)
    absolute <- relative + v[2]/r + v[3]/t + v[6]/(r*t)
    c(G = v[1]/(v[1]+relative), Phi = v[1]/(v[1]+absolute),
      RelativeSEM = sqrt(relative), AbsoluteSEM = sqrt(absolute))
  }
  changes <- function(v) unlist(lapply(2:3, function(i) metric(v, i) - metric(v, 1)), use.names = FALSE)
  h <- max(abs(theta)) * 1e-5
  J <- vapply(seq_along(theta), function(j) {
    step <- numeric(7); step[j] <- h
    (changes(theta + step) - changes(theta - step))/(2*h)
  }, numeric(8))
  expected <- J %*% C %*% t(J)
  expect_equal(cmp$comparisons$Difference, changes(theta), tolerance = 1e-12)
  expect_equal(unname(cmp$covariance), expected, tolerance = 1e-8)
  expect_equal(cmp$comparisons$SE, sqrt(diag(expected)), tolerance = 1e-8)
  expect_equal(cmp$comparisons$Lower, changes(theta)-qnorm(.975)*sqrt(diag(expected)), tolerance = 1e-8)
  expect_equal(cmp$comparisons$Upper, changes(theta)+qnorm(.975)*sqrt(diag(expected)), tolerance = 1e-8)
  reviewed <- recommend_mfrm_design(cmp)
  expect_identical(reviewed$comparisons, cmp$comparisons)
  expect_identical(reviewed$covariance, cmp$covariance)
  expect_identical(reviewed$weights, cmp$weights)
})

test_that("cost keys, point targets and paired directions remain distinct and retain every plan", {
  x <- finite_plan_fixture()$comparison
  original <- serialize(x, NULL)
  costs <- data.frame(Scenario = c(3L, 1L, 2L), RaterHours = c(NA, 0, 44),
    TotalRatings = c(1200, 1200, 1200))
  rec <- recommend_mfrm_design(x, costs = costs,
    limits = c(RaterHours = 42, TotalRatings = 1200),
    targets = c(G = .58, Phi = .39, RelativeSEM = .55))
  s <- summary(rec, planning = TRUE)
  expect_identical(serialize(x, NULL), original)
  expect_identical(s$plans$Scenario, 1:3)
  expect_identical(s$plans$Feasibility, c("feasible", "infeasible", "unavailable"))
  expect_identical(s$plans$TargetStatus, c("fail", "pass", "pass"))
  expect_equal(s$plans$RatingsPerPerson, rep(12, 3))
  expect_equal(s$costs$RaterHours, c(0, 44, NA))
  expect_equal(nrow(s$checks), 15L)
  expect_equal(sum(s$checks$Status == "unavailable"), 1L)
  expect_false(any(s$plans$ReviewRequired))
  expect_identical(s$differences$Direction,
    rep(c("improved", "inconclusive", "improved", "inconclusive"), 2))
  expect_identical(summary(rec), summary(x))
  reordered <- x
  reordered$comparisons <- reordered$comparisons[rev(seq_len(nrow(x$comparisons))), ]
  expect_identical(summary(recommend_mfrm_design(reordered, costs = costs[3:1, ],
    limits = c(RaterHours = 42, TotalRatings = 1200),
    targets = c(G = .58, Phi = .39, RelativeSEM = .55)), planning = TRUE)$plans, s$plans)
  expect_identical(s$basis$Target, "Observed-score mean")
  expect_match(paste(s$notes, collapse = " "), "selection bias", fixed = TRUE)
  expect_match(paste(s$notes, collapse = " "), "not a confidence statement", fixed = TRUE)
  unrequested <- summary(recommend_mfrm_design(x, costs = costs), planning = TRUE)
  expect_true(all(unrequested$plans$Feasibility == "not_requested"))
  expect_true(all(unrequested$plans$TargetStatus == "not_requested"))
  expect_equal(nrow(unrequested$checks), 0L)
  expect_error(summary(x, planning = TRUE), "Attach costs")
  expect_error(summary(rec, planning = NA), "TRUE or FALSE")
  # Reapplying criteria replaces the review, not its numerical comparison.
  expect_identical(recommend_mfrm_design(rec), recommend_mfrm_design(x))
})

test_that("same plans, reversed comparisons and unavailable or flagged inference are not erased", {
  duplicate <- summary(recommend_mfrm_design(finite_plan_fixture(TRUE)$comparison), planning = TRUE)
  expect_identical(duplicate$differences$Direction[duplicate$differences$Scenario == 4], rep("identical_plan", 4))
  reversed <- summary(recommend_mfrm_design(finite_plan_fixture(reference = 2)$comparison), planning = TRUE)
  expect_identical(reversed$differences$Direction[reversed$differences$Scenario == 1],
    c("worse", "inconclusive", "worse", "inconclusive"))
  # Synthetic stored states exercise reporting only; they are not new inference evidence.
  x <- finite_plan_fixture()$comparison
  x$comparisons$Lower[1] <- 0
  x$comparisons[2, c("Value", "Difference", "SE", "Lower", "Upper")] <- NA_real_
  x$comparisons$Status[2] <- "Point projection unavailable"
  x$component_diagnostics$PositiveSemidefinite[1] <- FALSE
  before <- serialize(x, NULL)
  rec <- recommend_mfrm_design(x, targets = c(Phi = .39))
  s <- summary(rec, planning = TRUE)
  expect_identical(s$differences$Direction[1:2], c("inconclusive", "unavailable"))
  expect_true(all(s$plans$ReviewRequired))
  expect_identical(s$plans$TargetStatus, c("fail", "unavailable", "pass"))
  expect_identical(rec$comparisons, x$comparisons)
  expect_identical(serialize(x, NULL), before)
  expect_equal(nrow(s$plans), 3L)
  expect_equal(nrow(s$differences), 8L)
})

test_that("planning inputs reject mismatched identities, units and route-specific arguments", {
  x <- finite_plan_fixture()$comparison
  good <- data.frame(Scenario = 1:3, Hours = c(4, 5, 6))
  for (bad in list(good[-1, ], good[c(1,1,3), ], transform(good, Scenario = c(1,2,4)),
                   transform(good, Scenario = as.character(Scenario))))
    expect_error(recommend_mfrm_design(x, costs = bad), "each Scenario exactly once")
  for (values in list(c(1,-1,3), c(1,Inf,3), c(1,NaN,3), letters[1:3], c(1+1i,2,3))) {
    bad <- good; bad$Hours <- values
    expect_error(recommend_mfrm_design(x, costs = bad), "finite nonnegative")
  }
  for (bound in list(1, c(NoSuchCost = 5), c(Hours = -1), c(Hours = Inf), c(Hours = 1, Hours = 2)))
    expect_error(recommend_mfrm_design(x, costs = good, limits = bound), "uniquely named")
  for (target in list(c(G = 1.01), c(Phi = -1), c(AbsoluteSEM = -1), c(Reliability = .8), c(G = NA)))
    expect_error(recommend_mfrm_design(x, targets = target), "targets|point targets")
  expect_error(recommend_mfrm_design(x, min_reliability = .8), "Simulation-screening")
  expect_error(recommend_mfrm_design(x, prefer = "Raters"), "Simulation-screening")
  saved <- readRDS(system.file("examples", "simulation-design.rds", package = "mfrmr"))$result
  expect_error(recommend_mfrm_design(saved, targets = c(G = .8)), "saved mfrm_multivariate_d_compare")
  bad <- x; bad$comparisons <- bad$comparisons[-1, ]
  expect_error(recommend_mfrm_design(bad), "each candidate/metric once")
  bad <- x; bad$comparisons$Difference[1] <- 1
  expect_error(recommend_mfrm_design(bad), "consistent paired differences")
})

test_that("planning tables and cautions reach plots, reports, CSV and saved results", {
  x <- finite_plan_fixture()$comparison
  # This workflow annotates saved evidence; it must not refit or recalculate it.
  local_mocked_bindings(
    mfrm_g_study = function(...) stop("Unexpected G-study recalculation"),
    mfrm_d_study = function(...) stop("Unexpected D-study recalculation"),
    mfrm_multivariate_d_compare = function(...) stop("Unexpected paired interval recalculation"))
  rec <- recommend_mfrm_design(x, costs = data.frame(Scenario = 1:3, Hours = c(4,7,NA)),
    limits = c(Hours = 5), targets = c(G = .58))
  s <- summary(rec, planning = TRUE)
  expect_output(print(rec), "Resource feasibility and point targets")
  r <- mfrm_report(rec, study_context = c(universe = "Comparable tasks and raters from the declared pools"))
  for (name in c("plans", "costs", "checks", "differences", "basis"))
    expect_identical(r$tables[[paste0("planning_", name)]], s[[name]])
  expect_true(all(s$notes %in% r$tables$interpretation_notes$Note))
  for (view in c("plans", "differences")) {
    p <- plot(rec, view = view, draw = FALSE)
    expect_s3_class(p, "ggplot")
    expect_identical(plot_data(p, "planning_plans"), s$plans)
    expect_identical(plot_data(p, "planning_checks"), s$checks)
    expect_identical(plot_data(p, "planning_differences"), s$differences)
    expect_equal(nrow(plot_data(p, "series")), 6L)
    expect_true(any(grepl("infeasible", plot_data(p, "series")$Plan, fixed = TRUE)))
    axes <- ggplot2::ggplot_build(p)$layout$panel_params[[1L]]
    labels <- if (view == "plans") axes$x$get_labels() else axes$y$get_labels()
    expect_true(any(grepl("infeasible", labels, fixed = TRUE)))
    expect_match(paste(plot_data(p, "notes")$Text, collapse = " "), "selection bias", fixed = TRUE)
    expect_null(p$labels$title)
  }
  expect_s3_class(apa_table(rec, which = "planning_checks"), "apa_table")
  bundle <- build_summary_table_bundle(rec, top_n = 1)
  expect_identical(bundle$tables$planning_plans, s$plans)
  out <- tempfile(); dir.create(out); on.exit(unlink(out, recursive = TRUE), add = TRUE)
  export_summary_appendix(rec, output_dir = out, prefix = "plans")
  csv <- list.files(out, "planning_checks.*csv$", full.names = TRUE)
  expect_length(csv, 1L)
  tab <- read.csv(csv)
  expect_equal(tab$Value, s$checks$Value, tolerance = 1e-12)
  expect_identical(tab$Status, s$checks$Status)
  saveRDS(rec, file.path(out, "plans.rds"))
  reopened <- readRDS(file.path(out, "plans.rds"))
  expect_identical(summary(reopened, planning = TRUE), s)
  expect_identical(mfrm_report(reopened)$tables$planning_differences, s$differences)
})
