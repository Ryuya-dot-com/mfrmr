test_that("Wright groups use one label per retained Person and unchanged densities", {
  person <- data.frame(Person = letters[1:12], Estimate = seq(-1, 1, length.out = 12))
  x <- list(facets = list(person = person))
  groups <- data.frame(Person = person$Person, Cohort = rep(c("A", "B"), each = 6))
  actual <- .build_wright_group_density(x, "Cohort", groups)
  expected <- do.call(rbind, lapply(c("A", "B"), function(g) {
    d <- stats::density(person$Estimate[groups$Cohort == g], n = 256L)
    data.frame(Group = g, Theta = d$x, Density = d$y)
  }))
  expect_identical(actual, expected)
  expect_identical(.build_wright_group_density(x, "Cohort", rbind(groups, groups)), actual)
  expect_identical(.build_wright_group_density(x, "Cohort",
    rbind(groups, data.frame(Person = "a", Cohort = NA_character_))), actual)
  expect_error(.build_wright_group_density(x, "Cohort",
    rbind(groups, data.frame(Person = "a", Cohort = "B"))), "conflicting group labels")
  expect_identical(.build_wright_group_density(x, "Cohort",
    rbind(groups, data.frame(Person = c("outside", "outside"), Cohort = c("A", "B")))), actual)
  omitted <- .build_wright_group_density(x, "Cohort", groups,
    person_exclusions = data.frame(Person = "a"))
  d <- stats::density(person$Estimate[2:6], n = 256L)
  expect_identical(omitted$Density[omitted$Group == "A"], d$y)
  expect_identical(omitted$Theta[omitted$Group == "A"], d$x)
  expect_identical(omitted[omitted$Group == "B", ], actual[actual$Group == "B", ])
  bad <- x; bad$facets$person$Person[2] <- "a"
  expect_error(.build_wright_group_density(bad, groups$Cohort), "one estimate row")
  bad$facets$person$Person[2] <- NA_character_
  expect_error(.build_wright_group_density(bad, groups$Cohort), "one estimate row")
  x$prep$data <- groups
  expect_identical(.build_wright_group_density(x, "Cohort"), actual)
  expect_error(.build_wright_group_density(x, "Cohort", groups["Person"]), "Group column not found")
  expect_error(.build_wright_group_density(x, matrix(groups$Cohort)), "column name or a vector")
  sparse <- x; sparse$facets$person$Estimate[7:12] <- Inf
  retained <- .build_wright_group_density(sparse, "Cohort", groups)
  expect_identical(retained, actual[actual$Group == "A", ])
  missing <- groups; missing$Cohort[1] <- NA_character_
  expect_identical(.build_wright_group_density(x, "Cohort", missing), omitted)
  small <- x; small$facets$person <- person[1:8, ]
  expect_message(expect_null(.build_wright_group_density(small, rep(c("A", "B"), each = 4))),
    "No subgroup had at least 5 finite person estimates", fixed = TRUE)
})

test_that("public Wright plots reject bad groups and keep exclusions aligned", {
  fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))$fit
  original <- serialize(fit, NULL)
  group <- rep(c("A", "B"), length.out = nrow(fit$facets$person))
  groups <- data.frame(Person = fit$facets$person$Person, Cohort = group)
  ordinary <- plot(fit, type = "wright", group = "Cohort", group_data = groups,
    show_ci = FALSE, draw = FALSE)
  expect_s3_class(ordinary, "mfrm_plot_data")
  expect_identical(names(ordinary$data$group), c("Group", "Theta", "Density"))
  expect_error(plot(fit, type = "wright", group = "AbsentColumn", group_data = groups,
    show_ci = FALSE, draw = FALSE), "Group column not found")
  expect_error(plot(fit, type = "wright", group = "Cohort", group_data =
    rbind(groups, data.frame(Person = groups$Person[1], Cohort = "B")),
    show_ci = FALSE, draw = FALSE), "conflicting group labels")
  expect_error(plot(fit, type = "wright", group = c("A", "B"),
    show_ci = FALSE, draw = FALSE), "column name or a vector")
  expect_error(plot(fit, type = "wright", group = rep("A", length(group)),
    show_ci = FALSE, draw = FALSE), "at least two distinct group levels")
  blocked <- fit
  blocked$facets$person$SourceFitReadiness <- "blocked"
  blocked$facets$person$ReasonCodes <- ""
  blocked$facets$person$ReasonCodes[1] <- "mml_extreme_response_prior_regularized"
  p <- plot(blocked, type = "wright", group = group, show_ci = FALSE, draw = FALSE)
  expect_equal(nrow(p$data$person_exclusions), 1L)
  reduced <- fit; reduced$facets$person <- reduced$facets$person[-1L, ]
  expected <- .build_wright_group_density(reduced, group[-1L])
  expect_identical(p$data$group, expected)
  column <- plot(blocked, type = "wright", group = "Cohort", group_data = groups,
    show_ci = FALSE, draw = FALSE)
  expect_identical(column$data$group, .build_wright_group_density(reduced, "Cohort", groups))
  grDevices::pdf(NULL, width = 10, height = 6)
  on.exit(grDevices::dev.off(), add = TRUE)
  expect_identical(plot(blocked, type = "wright", group = group,
    show_ci = FALSE, draw = TRUE), p)
  expect_identical(serialize(fit, NULL), original)
})

test_that("Wright ggplot group names cannot reuse location or statistic keys", {
  skip_if_not_installed("ggplot2", minimum_version = "3.4.0")
  fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))$fit
  labels <- c("Facet level", "Step threshold", "Person mean", "Person median",
              "Group: Facet level")
  groups <- rep(labels, length.out = nrow(fit$facets$person))
  p <- plot(fit, type = "wright", group = groups, show_ci = FALSE, draw = FALSE)
  raw <- serialize(p, NULL)
  gg <- as_ggplot(p)
  built <- ggplot2::ggplot_build(gg)
  colour <- built$plot$scales$get_scales("colour")
  linetype <- built$plot$scales$get_scales("linetype")
  expect_setequal(colour$get_limits(), c("Facet level", "Step threshold", paste0("Group: ", labels)))
  expect_setequal(linetype$get_limits(), c("Person mean", "Person median", paste0("Group: ", labels)))
  expect_identical(unname(colour$map(c("Facet level", "Step threshold"))),
    unname(.plot_series_colors(c("facet_level", "step_threshold"))))
  expect_identical(unname(linetype$map(c("Person mean", "Person median"))), c("dotted", "dashed"))
  expect_identical(serialize(p, NULL), raw)
  expect_setequal(plot_data(gg, "group")$Group, labels)
  path <- tempfile(fileext = ".rds"); on.exit(unlink(path), add = TRUE)
  saveRDS(p, path)
  expect_identical(ggplot2::ggplot_build(as_ggplot(readRDS(path)))$data, built$data)
})
