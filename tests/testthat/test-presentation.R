presentation_fit <- function(name) {
  fit <- readRDS(system.file("examples", name, package = "mfrmr"))
  if (name == "measurement-fits.rds") fit$gpcm else fit$fit
}

presentation_layer <- function(p, geom) {
  Filter(function(layer) inherits(layer$geom, geom), p$layers)[[1L]]$data
}

test_that("Wright histograms count finite scores and densities use a separate scale", {
  f <- presentation_fit("core-jml.rds")
  f$person$Estimate <- rep(NA_real_, nrow(f$person))
  f$person$Estimate[1:6] <- c(-1, -0.75, 0, 0.1, 0.2, 1)
  p <- plot(f, "wright", binwidth = 0.5)
  bins <- presentation_layer(p, "GeomRect")
  expect_equal(bins$Count, c(2, 1, 2, 1))
  expect_equal(bins$Upper - bins$Lower, rep(0.5, 4))
  expect_match(p$labels$x, "N = 6; bin width 0.5")
  expect_match(paste(attr(p, "mfrm_notes"), collapse = " "), "6 of 48")
  den <- plot(f, "wright", person_display = "density")
  expect_match(den$labels$x, "bandwidth")
  density <- presentation_layer(den, "GeomPolygon")$Density
  expect_equal(density[-c(1, length(density))],
               stats::density(f$person$Estimate[1:6])$y)
  f$person$Estimate[1:6] <- 1
  expect_equal(sum(presentation_layer(plot(f, "wright"), "GeomRect")$Count), 6)
  expect_match(paste(attr(plot(f, "wright", person_display = "density"), "mfrm_notes"), collapse = " "), "common estimate")
  f$person$Estimate[] <- NA_real_
  expect_match(plot(f, "wright")$labels$x, "N = 0")
  expect_error(plot(f, "wright", binwidth = 0), "positive")
})

test_that("Wright counts and densities extend left from their zero", {
  f <- presentation_fit("core-jml.rds")
  p <- plot(f, "wright", binwidth = .5)
  bars <- presentation_layer(p, "GeomRect")
  axis <- p$scales$get_scales("x")
  zero <- axis$breaks[axis$labels == "0"]
  expect_equal(bars$Left, zero - bars$Count * (zero - min(bars$Left)) / max(bars$Count))
  expect_equal(unique(ggplot2::ggplot_build(p)$data[[2L]]$xmax), zero)
  den <- presentation_layer(plot(f, "wright", person_display = "density"), "GeomPolygon")
  expect_equal(den$XPos[den$Density == 0], rep(zero, sum(den$Density == 0)))
  expect_equal(den$XPos[which.max(den$Density)], min(den$XPos))
})

test_that("star tallies and signed columns agree with hand-counted ruler rows", {
  f <- presentation_fit("core-jml.rds")
  # The two half-row ties (-.25 and .25) join the higher row on this ruler.
  scores <- c(-1, -.5, -.25, rep(0, 7), .25, .5, 1, NA, Inf)
  f$person$Estimate <- rep(NA_real_, nrow(f$person))
  f$person$Estimate[seq_along(scores)] <- scores
  p <- plot(f, "wright", person_display = "stars", yardstick = list(lines = 2, range = c(-.5,.5)))
  marks <- presentation_layer(p, "GeomText")
  expect_equal(marks$Center, c(-1, -.5, 0, .5, 1))
  expect_equal(marks$Count, c(1,1,8,2,1))
  clean <- function(v) trimws(gsub("\u00a0", " ", v, fixed = TRUE))
  expect_equal(clean(marks$Mark), c("+1","+1","** +2","+2","+1"))
  expect_match(p$labels$x, "N = 13; * = 3 persons", fixed = TRUE)
  expect_true(any(grepl("2 finite person estimates outside", attr(p, "mfrm_notes"))))
  expect_equal(p$coordinates$limits$y, c(-.5,.5))
  expect_true(all(c("+Person", "-Rater", "-Criterion") %in% p$scales$get_scales("x")$labels))
  expect_equal(presentation_layer(plot(f, "wright", yardstick = 2), "GeomRect")$Count, marks$Count)
  d <- plot(f, "wright", person_display = "stars", persons_per_star = 2, yardstick = 2)
  expect_equal(clean(presentation_layer(d, "GeomText")$Mark[3]), "****")
  f$person$Estimate[] <- 0
  large <- plot(f, "wright", person_display = "stars", yardstick = 2)
  expect_equal(clean(presentation_layer(large, "GeomText")$Mark), "16 x *")
  f$person$Estimate[] <- NA_real_
  empty <- plot(f, "wright", person_display = "stars", yardstick = 2)
  expect_match(empty$labels$x, "N = 0")
  expect_false(any(vapply(empty$layers, function(l) "Mark" %in% names(l$data), logical(1))))
  expect_error(plot(f, "wright", person_display = "stars", persons_per_star = 1.5), "positive whole")
  expect_error(plot(f, "wright", yardstick = list(lines = 0)), "positive")
  expect_error(plot(f, "wright", yardstick = list(lines = 2, range = c(1,-1))), "increasing")
  expect_error(plot(f, "wright", binwidth = .5, yardstick = 2), "binwidth")
})

test_that("conditional Wright crossings give equal adjacent response probabilities", {
  d <- load_mfrmr_data("example_core")
  context <- data.frame(Rater = factor("R04"), Criterion = factor("Content"))
  ability_only <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
    model = "GPCM", step_facet = "Criterion", slope_facet = c("Rater", "Criterion"),
    spec = list(slope_reference = "Rater", slope_type = "ability_only",
                gpcm_mml_identification = "fixed_standard_normal"))
  for (f in list(presentation_fit("core-jml.rds"), presentation_fit("measurement-fits.rds"), ability_only)) {
    p <- plot(f, "wright", newdata = context)
    points <- presentation_layer(p, "GeomPoint")
    crossing <- points$Logit[points$Panel == "Ability crossings"]
    expect_length(crossing, 3L)
    # Independent category probabilities for the observed reference slope and shared design.
    ticks <- attr(p, "mfrm_fair_average")
    base <- sum(vapply(split(f$facets, f$facets$Facet), function(tb) tb$Sign[1] * mean(tb$Estimate), numeric(1)))
    alpha <- if (length(f$alpha_obs)) exp(mean(log(f$alpha_obs))) else 1
    fair_value <- function(th) {
      k <- seq.int(0, f$rating_max - f$rating_min)
      score_by_group <- apply(f$step_cumulative, 1L, function(cum) {
        lp <- if (f$encoding$slope_formula == 1L) k * (alpha * th + base) - cum else
          alpha * (k * (th + base) - cum)
        prob <- exp(lp - max(lp))
        sum((f$rating_min + k) * prob) / sum(prob)
      })
      mean(score_by_group[f$encoding$step_group0 + 1L])
    }
    expect_true(nrow(ticks) >= 2L)
    expect_equal(vapply(ticks$Logit, fair_value, numeric(1)), ticks$FairAverage, tolerance = 1e-8)
    expect_equal(vapply(f$person$Estimate, fair_value, numeric(1)), f$person$FairM, tolerance = 1e-8)
    prob <- predict(f, context[rep(1L, 3L), ], theta = crossing, type = "probs")
    expect_equal(prob[cbind(1:3, 1:3)], prob[cbind(1:3, 2:4)], tolerance = 1e-10)
    expect_match(attr(p, "mfrm_notes")[1], "Rater = R04, Criterion = Content", fixed = TRUE)
    curves <- plot(f, "category_curves", newdata = context)$data
    at_zero <- subset(curves, theta == 0)
    expect_equal(at_zero$Probability, as.numeric(predict(f, context, theta = 0, type = "probs")))
  }
  expect_error(plot(ability_only, "wright", newdata = d[1:2, ]), "one row")
})

test_that("Wright Fair average separates a pooled rubric mix from a specified reference panel", {
  d <- load_mfrmr_data("example_core")
  # Half of the examinees have no Content ratings.
  d <- d[!(as.integer(sub("P", "", d$Person)) %% 2L == 0L & d$Criterion == "Content"), ]
  fit <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", model = "PCM", step_facet = "Criterion")
  plan <- data.frame(Rater = c("R02", "R04"), Criterion = c("Accuracy", "Content"), Weight = c(1, 3))
  p <- plot(fit, "wright", yardstick = list(lines = 2, range = c(-2,2)))
  actual <- attr(p, "mfrm_fair_average")
  counts <- table(factor(d$Criterion, levels = fit$encoding$step_owners))
  expect_equal(unname(attr(actual, "step_weights")), as.numeric(counts / sum(counts)))
  expect_equal(unique(actual$Reference), "Rating-weighted step-group mix")
  offset <- sum(vapply(split(fit$facets, fit$facets$Facet), function(tb) tb$Sign[1] * mean(tb$Estimate), numeric(1)))
  eval_group <- function(th) apply(fit$step_cumulative, 1L, function(cum) {
    k <- seq_along(cum) - 1L
    lp <- (th + offset) * k - cum
    w <- exp(lp - max(lp))
    sum((fit$rating_min + k) * w)/sum(w)
  })
  expect_equal(vapply(actual$Logit, function(th) weighted.mean(eval_group(th), as.numeric(counts)), numeric(1)),
               actual$FairAverage, tolerance = 1e-8)
  wf <- mfrm_workflow(d, "Person", c("Rater","Criterion"), "Score", fit = fit)
  specified <- plot(wf, "wright", draw = FALSE, newdata = plan[1, ], reference_plan = plan,
                    yardstick = list(lines = 2, range = c(-2,2)))
  ticks <- attr(specified, "mfrm_fair_average")
  expect_equal(attr(ticks, "reference_plan")$NormalizedWeight, c(.25,.75))
  direct <- function(th) weighted.mean(predict(fit, plan[c("Rater","Criterion")], theta = th), plan$Weight)
  expect_equal(vapply(ticks$Logit, direct, numeric(1)), ticks$FairAverage, tolerance = 1e-8)
  expect_equal(vapply(fit$person$Estimate, direct, numeric(1)),
               fair_average_table(fit, reference_plan = plan)$reference_scores$Estimate, tolerance = 1e-10)
  expect_false(isTRUE(all.equal(actual$Logit, ticks$Logit)))
  expect_null(attr(plot(fit, "wright", fair_average = FALSE), "mfrm_fair_average"))
  expect_error(plot(fit, "wright", reference_plan = transform(plan, Weight = -1)), "positive")
  fit$converged <- FALSE
  withheld <- plot(fit, "wright", reference_plan = plan)
  expect_null(attr(withheld, "mfrm_fair_average"))
  expect_true(any(grepl("Fair average withheld:.*optimizer_not_converged", attr(withheld, "mfrm_notes"))))
})

test_that("formatted parameters preserve the interval basis, units and summary access", {
  f <- presentation_fit("measurement-fits.rds")
  for (basis in c("model", "real", "sandwich")) {
    tab <- .mfrm_parameter_table(f, "facets", basis, 0.9)
    expect_equal(tab$Estimate, f$facets$Estimate)
    expect_equal(tab$SE, f$facets[[switch(basis, model="ModelSE", real="RealSE", sandwich="SandwichSE")]])
    expect_equal(unname(as.matrix(tab[c("Lower", "Upper")])),
                 unname(confint(f, component = "facets", se_type = basis, level = 0.9)))
  }
  slopes <- .mfrm_parameter_table(f, "slopes", "sandwich", .95)
  expect_equal(slopes$Lower, slopes$Estimate * exp(-qnorm(.975) * slopes$SE / slopes$Estimate))
  expect_match(format_mfrm_table(f, "persons"), "Posterior SD")
  expect_match(format_mfrm_table(f, "raters", se_type = "real", conf.level = .9), "Real SE .*90% lower")
  expect_error(format_mfrm_table(f, "steps", se_type = "real"), "Real SE")
  expect_output(print(summary(f)), "Inference: ready")
  expect_equal(summary(f)$facets, f$facets)
  expect_equal(summary(f)$overview$Persons, f$n_person)
  if (requireNamespace("kableExtra", quietly=TRUE)) {
    h <- format_mfrm_table(f, "raters", engine = "kableExtra")
    expect_match(as.character(h), "GPCM \\(MML\\)")
  }
  if (requireNamespace("flextable", quietly=TRUE))
    expect_equal(format_mfrm_table(f, "raters", engine = "flextable")$body$dataset$Estimate,
                 round(f$facets$Estimate[f$facets$Facet == "Rater"], 3))
})

test_that("model tables align shared parameter meanings and delegate comparisons", {
  d <- load_mfrmr_data("example_core")
  rsm <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score")
  pcm <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", model = "PCM", step_facet = "Criterion")
  models <- list(RSM = rsm, PCM = pcm)
  tab <- .mfrm_models_table(models, "steps", "model", .95, 3, FALSE)
  expect_true(all(tab[[6]][tab$Group == "Shared steps"] == "Not in model"))
  expect_true(all(tab[[5]][tab$Group == "Steps within Criterion"] == "Not in model"))
  expect_equal(nrow(tab), nrow(rsm$steps) + nrow(pcm$steps))
  ref <- compare_mfrm(rsm, pcm, labels = names(models), nested = TRUE)
  out <- .mfrm_models_table(models, "comparison", "model", .95, 3, TRUE)
  expect_equal(as.numeric(out[["Model PCM"]][out$Statistic == "AIC"]), round(ref$table$AIC[2], 3))
  expect_match(out[["Model PCM"]][out$Statistic == "LRT"], as.character(round(ref$lrt$ChiSq, 3)), fixed = TRUE)
  expect_match(format_mfrm_table(list(JML = presentation_fit("core-jml.rds"), MML = rsm)),
               "Differences unavailable")
  expect_error(format_mfrm_table(list(rsm, pcm)), "unique nonempty")
  changed <- pcm
  changed$encoding$weight[1] <- 2
  expect_error(format_mfrm_table(list(RSM=rsm, PCM=changed), "facets"), "matching observations")
  expect_match(format_mfrm_table(list(RSM=rsm, PCM=pcm), "slopes"), "No rows")
  gm <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", model = "GPCM",
    slope_facet = "Rater", step_facet = "Criterion", spec = list(gpcm_mml_identification = "fixed_standard_normal"))
  sl <- .mfrm_models_table(list(RSM=rsm, PCM=pcm, GMFRM=gm), "slopes", "model", .95, 3, FALSE)
  expect_equal(sl$Level, gm$slopes$Level)
  expect_true(all(sl[[5]] == "Not in model" & sl[[6]] == "Not in model"))
  expect_false(any(sl[[7]] == "Not in model"))
})

test_that("optional widgets retain counts, diagnostic notes, and conditional curves", {
  skip_if_not_installed("plotly")
  f <- presentation_fit("core-jml.rds")
  wf <- mfrm_workflow(load_mfrmr_data("example_core"), "Person", c("Rater","Criterion"), "Score", fit = f)
  ctx <- data.frame(Rater = c("R01","R04"), Criterion = "Content")
  w <- plot(f, "wright", interactive = TRUE)
  text <- function(w) unlist(lapply(plotly::plotly_build(w)$x$data, "[[", "text"), use.names = FALSE)
  expect_s3_class(w, "plotly")
  expect_equal(attr(w, "mfrm_notes"), attr(plot(f, "wright"), "mfrm_notes"))
  expect_true(any(grepl("Count: [0-9]", text(w))))
  stars <- plot(wf, "wright", person_display = "stars", persons_per_star = 3,
                yardstick = list(lines = 2, range = c(-2,2)), interactive = TRUE)
  traces <- Filter(function(tr) identical(tr$textposition, "middle left"), plotly::plotly_build(stars)$x$data)
  expect_length(traces, 1L)
  static <- plot(f, "wright", person_display = "stars", yardstick = list(lines = 2, range = c(-2,2)))
  marks <- presentation_layer(static, "GeomText")
  expect_equal(as.character(traces[[1L]]$text), marks$Mark)
  expect_equal(as.integer(sub(".*Count: ", "", traces[[1L]]$hovertext)), marks$Count)
  expect_equal(stars$x$layout$yaxis$range, c(-2,2))
  ticks <- attr(static, "mfrm_fair_average")
  expect_equal(attr(stars, "mfrm_fair_average"), ticks)
  fair_trace <- Filter(function(tr) any(grepl("^Fair average: ", tr$hovertext)), stars$x$data)
  expect_length(fair_trace, 1L)
  expect_equal(as.numeric(fair_trace[[1L]]$y), ticks$Logit)
  expect_equal(as.numeric(fair_trace[[1L]]$text), ticks$FairAverage)
  wf_curves <- plot(wf, "category_curves", newdata = ctx, interactive = TRUE)
  expect_true(any(grepl("R04", text(wf_curves))))
  expect_true(any(grepl("Probability: ", text(wf_curves))))
  expect_true(any(grepl("Fit Basis: ", text(plot(f, "pathway", interactive=TRUE)))))
  expect_error(plot(f, "residual_qq", interactive = TRUE), "Interactive plots support")
})
