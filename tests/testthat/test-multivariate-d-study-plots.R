mvgt_plot_data <- function() {
  path <- testthat::test_path("..", "..", "inst", "extdata", "mgenova-table12.csv")
  if (!file.exists(path)) path <- system.file("extdata", "mgenova-table12.csv", package = "mfrmr")
  read.csv(path)
}

test_that("D-study plots preserve stored values, units, weights and score identities", {
  tasks <- mvgt_plot_data()
  g <- mfrm_multivariate_gstudy(tasks, c("V", "W"), rater = NULL)
  d <- mfrm_multivariate_d_study(g, data.frame(Tasks = c(12, 3, 6)), c(V = -1, W = 1))
  before <- serialize(d, NULL)
  device <- grDevices::dev.cur()
  p <- plot_data(plot(d, draw = FALSE))
  expect_identical(grDevices::dev.cur(), device)
  expect_identical(p$kind, "Composite")
  expect_equal(p$table, d$coefficients[d$coefficients$Kind == "Composite", ])
  expect_equal(p$series$Value[p$series$Metric == "G"], p$table$G)
  expect_equal(p$series$Value[p$series$Metric == "Phi"], p$table$Phi)
  expect_identical(p$weights, c(V = -1, W = 1))
  expect_identical(p$x_var, "Tasks")
  expect_length(p$group_var, 0)
  expect_equal(nrow(p$reference_lines), 0)
  sem <- plot_data(plot(d, type = "sem", draw = FALSE))
  expect_equal(sem$series$Value[sem$series$Metric == "RelativeSEM"], p$table$RelativeSEM)
  expect_equal(sem$series$Value[sem$series$Metric == "AbsoluteSEM"], p$table$AbsoluteSEM)
  v <- plot_data(plot(d, score = "V", draw = FALSE))
  expect_equal(v$table, d$coefficients[d$coefficients$Kind == "Score" & d$coefficients$Score == "V", ])
  expect_identical(serialize(d, NULL), before)
  # Plotting only needs stored coefficients and identities, not a refittable G-study.
  d$gstudy$components <- NULL
  expect_identical(plot_data(plot(d, draw = FALSE)), p)

  names(tasks)[names(tasks) == "V"] <- "Composite"
  g <- mfrm_multivariate_gstudy(tasks, c("Composite", "W"), rater = NULL)
  d <- mfrm_multivariate_d_study(g, weights = c(Composite = -1, W = 1))
  expect_identical(plot_data(plot(d, draw = FALSE))$kind, "Composite")
  expect_identical(plot_data(plot(d, score = "Composite", draw = FALSE))$kind, "Score")
  d <- mfrm_multivariate_d_study(g)
  expect_identical(plot_data(plot(d, draw = FALSE))$score, "Composite")
  expect_identical(plot_data(plot(d, draw = FALSE))$kind, "Score")
})

test_that("D-study plots hold the other facet fixed and keep nonrectangular scenarios", {
  ratings <- merge(mvgt_plot_data(), data.frame(Rater = 1:3))
  ratings$V <- ratings$V + ratings$Rater
  ratings$W <- ratings$W + 2 * ratings$Rater
  g <- mfrm_multivariate_gstudy(ratings, c("V", "W"))
  grid <- data.frame(Raters = c(2, 4, 2, 4), Tasks = c(3, 3, 9, 6))
  d <- mfrm_multivariate_d_study(g, grid)
  expect_true(all(d$coefficients$Status == "Available"))
  p <- plot_data(plot(d, draw = FALSE))
  expect_identical(p$design_grid, grid)
  expect_equal(p$series$X, rep(grid$Tasks, 2))
  expect_equal(p$series$Group, rep(paste("Raters =", grid$Raters), 2))
  expect_equal(p$series$Scenario, rep(seq_len(nrow(grid)), 2))
  expect_equal(p$series$Value[p$series$Metric == "G"], d$coefficients$G[d$coefficients$Score == "V"])
  flipped <- plot_data(plot(d, x_var = "Raters", draw = FALSE))
  expect_equal(flipped$series$X, rep(grid$Raters, 2))
  expect_identical(flipped$group_var, "Tasks")
  only_raters <- mfrm_multivariate_d_study(g, grid[1:2, ])
  expect_identical(plot_data(plot(only_raters, draw = FALSE))$x_var, "Raters")

  grDevices::pdf(NULL, width = 7, height = 7)
  on.exit(grDevices::dev.off(), add = TRUE)
  old <- graphics::par(c("mfrow", "mar", "oma", "cex", "mex", "bg", "fg", "cex.axis"))
  expect_no_warning(plot(d))
  expect_no_warning(plot(d, type = "sem", x_var = "Raters", preset = "monochrome"))
  expect_equal(graphics::par(names(old)), old)
})

test_that("unavailable D-study estimates remain missing with their reasons", {
  tasks <- mvgt_plot_data()
  sparse <- tasks[(tasks$Person + tasks$Task) %% 3 != 0, ]
  sparse$V[1] <- NA_real_
  g <- mfrm_multivariate_gstudy(sparse, c("V", "W"), rater = NULL,
    method = "minque0", missing = "omit")
  d <- mfrm_multivariate_d_study(g, data.frame(Tasks = c(6, 12)))
  p <- plot_data(plot(d, draw = FALSE))
  expect_true(all(is.na(p$series$Value)))
  expect_identical(p$unavailable, p$series)
  expect_true(all(p$unavailable$Status == "Non-PSD component estimates"))
  expect_match(p$subtitle, "Future complete crossed designs")
  grDevices::pdf(NULL, width = 7, height = 7)
  on.exit(grDevices::dev.off(), add = TRUE)
  expect_no_warning(plot(d))
  expect_no_warning(plot(d, type = "sem"))

  g <- mfrm_multivariate_gstudy(tasks, c("V", "W"), rater = NULL)
  d <- mfrm_multivariate_d_study(g, data.frame(Tasks = c(3, 6, 12)))
  # Exercise a gap in a stored projection without using zero as a placeholder.
  gap <- d$coefficients$Scenario == 2
  d$coefficients[gap, c("G", "Phi", "RelativeSEM", "AbsoluteSEM")] <- NA_real_
  d$coefficients$Status[gap] <- "Negative projected error variance"
  p <- plot_data(plot(d, draw = FALSE))
  expect_equal(p$unavailable$Scenario, c(2L, 2L))
  expect_true(all(is.na(p$series$Value[p$series$Scenario == 2])))
  expect_no_warning(plot(d))
  single <- mfrm_multivariate_d_study(g, data.frame(Tasks = 6))
  expect_no_warning(plot(single))
  expect_error(plot(single, x_var = "Raters"), "facet count present")
  expect_error(plot(single, score = "unknown"), "one original score")
  expect_error(plot(single, score = c("V", "W")), "one original score")
  expect_error(plot(single, draw = NA), "TRUE or FALSE")
  expect_error(plot(single, unused = TRUE), "must be empty")
})

test_that("ggplot conversion retains D-study metrics, units, groups and unavailable gaps", {
  skip_if_not_installed("ggplot2", minimum_version = "3.4.0")
  ratings <- merge(mvgt_plot_data(), data.frame(Rater = 1:3))
  ratings$V <- ratings$V + ratings$Rater
  ratings$W <- ratings$W + 2 * ratings$Rater
  g <- mfrm_multivariate_gstudy(ratings, c("V", "W"))
  d <- mfrm_multivariate_d_study(g, expand.grid(Raters = c(2, 4), Tasks = c(3, 6, 12)),
    c(V = .4, W = .6))
  before <- grDevices::dev.cur()
  as_ggplot(d)
  expect_identical(grDevices::dev.cur(), before)
  grDevices::pdf(NULL, width = 7, height = 7)
  on.exit(grDevices::dev.off(), add = TRUE)
  for (type in c("coefficients", "sem")) {
    before <- grDevices::dev.cur()
    payload <- plot(d, type = type, preset = "monochrome", draw = FALSE)
    p <- as_ggplot(payload)
    expect_identical(grDevices::dev.cur(), before)
    expect_equal(p$data$Value, payload$data$series$Value)
    expect_equal(p$data$X, payload$data$series$X)
    expect_identical(as.character(p$data$Group), payload$data$series$Group)
    expect_identical(levels(p$data$Panel), payload$data$panel_labels)
    expect_identical(p$labels$x, "Number of tasks")
    expect_match(p$labels$y, if (type == "sem") "score units" else "Dependability")
    built <- ggplot2::ggplot_build(p)
    expect_identical(unname(built$plot$scales$get_scales("colour")$map(payload$data$legend$label)),
      payload$data$legend$value)
    expect_equal(sort(built$data[[2]]$y), sort(payload$data$series$Value))
    expect_no_warning(ggplot2::ggplotGrob(p))
  }
  direct <- as_ggplot(d, type = "sem", score = "V", x_var = "Raters")
  expect_identical(direct$labels$title, "Score: V")
  expect_identical(direct$labels$x, "Number of raters")
  expect_true(all(direct$data$Kind == "Score"))

  gaps <- d$coefficients$Tasks == 6
  d$coefficients[gaps, c("G", "Phi", "RelativeSEM", "AbsoluteSEM")] <- NA_real_
  d$coefficients$Status[gaps] <- "Negative projected error variance"
  p <- as_ggplot(d)
  expect_true(all(is.na(p$data$Value[p$data$X == 6])))
  expect_true(all(is.na(p$layers[[1]]$data$Value[p$layers[[1]]$data$X == 6])))
  expect_match(gsub("\n", " ", p$labels$caption), "Unavailable estimates in 2 scenario")
  expect_no_warning(ggplot2::ggplotGrob(p))

  d$coefficients[c("G", "Phi", "RelativeSEM", "AbsoluteSEM")] <- NA_real_
  d$coefficients$Status <- "Non-PSD component estimates"
  p <- as_ggplot(d)
  expect_true(all(is.na(p$data$Value)))
  expect_match(p$layers[[3]]$data$Label, "Covariance components failed validity checks")
  expect_match(p$layers[[4]]$data$Label, "Covariance components failed validity checks")
  expect_no_warning(ggplot2::ggplotGrob(p))
  single <- mfrm_multivariate_d_study(g)
  expect_no_warning(ggplot2::ggplotGrob(as_ggplot(single)))
})
