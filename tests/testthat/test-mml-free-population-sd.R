simulate_rsm_free_sd_fixture <- function(seed = 926,
                                         n_person = 50L,
                                         theta_sd = 1.45) {
  set.seed(seed)
  persons <- paste0("P", seq_len(n_person))
  raters <- paste0("R", seq_len(3L))
  criteria <- paste0("C", seq_len(2L))
  theta <- stats::rnorm(n_person, 0, theta_sd)
  theta <- theta - mean(theta)
  rater <- c(-0.35, 0.05, 0.30)
  rater <- rater - mean(rater)
  criterion <- c(-0.25, 0.25)
  criterion <- criterion - mean(criterion)
  steps <- c(-1.1, 0.1, 1.0)
  steps <- steps - mean(steps)
  step_cum <- c(0, cumsum(steps))
  k_vals <- 0:3

  dat <- expand.grid(
    Person = persons,
    Rater = raters,
    Criterion = criteria,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  dat$Score <- vapply(seq_len(nrow(dat)), function(i) {
    eta <- theta[match(dat$Person[i], persons)] -
      rater[match(dat$Rater[i], raters)] -
      criterion[match(dat$Criterion[i], criteria)]
    log_num <- k_vals * eta - step_cum
    prob <- exp(log_num - max(log_num))
    prob <- prob / sum(prob)
    sample.int(4L, size = 1L, prob = prob)
  }, integer(1))

  list(
    data = dat,
    theta = theta,
    realized_theta_sd = sqrt(mean(theta^2))
  )
}

test_that("ordinary MML can estimate a free normal population SD under EM", {
  fixture <- simulate_rsm_free_sd_fixture()
  fit <- fit_mfrm(
    fixture$data,
    "Person", c("Rater", "Criterion"), "Score",
    method = "MML",
    model = "RSM",
    quad_points = 9,
    maxit = 80,
    reltol = 1e-4,
    mml_engine = "em",
    estimate_population_sd = TRUE
  )

  expect_identical(fit$summary$PopulationSDMode[1], "estimated")
  expect_identical(fit$summary$MMLEngineUsed[1], "em")
  expect_true(is.finite(fit$summary$EstimatedPopulationSD[1]))
  expect_gt(fit$summary$EstimatedPopulationSD[1], 1.10)
  expect_equal(
    fit$summary$EstimatedPopulationSD[1],
    fixture$realized_theta_sd,
    tolerance = 0.30
  )
  expect_true(is.finite(fit$summary$PopulationSDSE[1]))
  expect_identical(fit$summary$PopulationSDSEStatus[1], "ok")
  expect_equal(fit$summary$Parameters[1], length(fit$opt$par) + 1L)
  expect_true(length(fit$opt$sigma_trace) >= 2L)
  expect_equal(
    utils::tail(fit$opt$sigma_trace, 1L),
    fit$summary$EstimatedPopulationSD[1],
    tolerance = 1e-12
  )
  expect_identical(fit$config$posterior_basis, "estimated_population_sd_mml")
})

test_that("population SD flag-off preserves the fixed standard-normal MML path", {
  toy <- load_mfrmr_data("example_core")
  default_fit <- fit_mfrm(
    toy,
    "Person", c("Rater", "Criterion"), "Score",
    method = "MML",
    model = "RSM",
    quad_points = 5,
    maxit = 20
  )
  explicit_fixed <- fit_mfrm(
    toy,
    "Person", c("Rater", "Criterion"), "Score",
    method = "MML",
    model = "RSM",
    quad_points = 5,
    maxit = 20,
    estimate_population_sd = FALSE
  )

  expect_identical(default_fit$summary$PopulationSDMode[1], "fixed")
  expect_equal(default_fit$summary$LogLik[1], explicit_fixed$summary$LogLik[1], tolerance = 1e-12)
  expect_equal(default_fit$summary$AIC[1], explicit_fixed$summary$AIC[1], tolerance = 1e-12)
  expect_equal(
    default_fit$facets$person$Estimate,
    explicit_fixed$facets$person$Estimate,
    tolerance = 1e-12
  )
})

test_that("fixed MML prior SD is not clipped by free-SD bounds", {
  toy <- load_mfrmr_data("example_core")
  fit <- suppressWarnings(fit_mfrm(
    toy,
    "Person", c("Rater", "Criterion"), "Score",
    method = "MML",
    model = "RSM",
    quad_points = 3,
    maxit = 3,
    mml_engine = "em",
    population_prior_sd = 12,
    population_sd_bounds = c(0.05, 10),
    estimate_population_sd = FALSE
  ))

  expect_identical(fit$summary$PopulationSDMode[1], "fixed")
  expect_equal(fit$summary$PopulationPriorSD[1], 12, tolerance = 1e-12)
  expect_equal(fit$config$population_prior_sd, 12, tolerance = 1e-12)
  expect_true(is.na(fit$summary$EstimatedPopulationSD[1]))
})

test_that("free population SD records engine override and supports bounded GPCM", {
  toy <- load_mfrmr_data("example_core")
  fit <- suppressWarnings(fit_mfrm(
    toy,
    "Person", c("Rater", "Criterion"), "Score",
    method = "MML",
    model = "RSM",
    quad_points = 5,
    maxit = 20,
    mml_engine = "direct",
    estimate_population_sd = TRUE
  ))
  expect_identical(fit$summary$MMLEngineRequested[1], "direct")
  expect_identical(fit$summary$MMLEngineUsed[1], "em")
  expect_true(grepl("requires the MML EM variance M-step",
                    fit$summary$MMLEngineDetail[1], fixed = TRUE))

  s <- summary(fit)
  expect_identical(as.character(s$population_overview$PopulationSDMode[1]), "estimated")
  expect_true(is.finite(s$population_overview$EstimatedPopulationSD[1]))
  expect_true(any(s$status$Item == "Population metric"))
  expect_true(any(grepl("estimated the normal marginal population SD", s$notes, fixed = TRUE)))

  res <- suppressWarnings(mfrm_results(fit, include = c("fit", "diagnostics")))
  sx_res <- summary(res)
  expect_identical(as.character(sx_res$overview$PopulationSDMode[1]), "estimated")
  expect_true(is.finite(sx_res$overview$EstimatedPopulationSD[1]))
  expect_identical(
    as.character(sx_res$overview$PopulationSDSEStatus[1]),
    as.character(fit$summary$PopulationSDSEStatus[1])
  )
  expect_true(grepl("estimated SD", sx_res$overview$PopulationMetric[1], fixed = TRUE))
  expect_true(any(sx_res$triage$Area == "Population metric" &
                    sx_res$triage$Signal == "population_sd_estimated"))

  apa_report <- mfrm_report(res, style = "apa")
  expect_true(any(apa_report$sections$Section == "Model and data setup" &
                    grepl("population metric = estimated SD",
                          apa_report$sections$Evidence, fixed = TRUE)))
  expect_true(any(grepl("population metric: estimated SD",
                        apa_report$narrative$Text, fixed = TRUE)))

  out_dir <- file.path(tempdir(), paste0("mfrmr_free_sd_results_", sample.int(1e6, 1)))
  exported <- export_mfrm_results(
    res,
    output_dir = out_dir,
    prefix = "free_sd",
    include = c("summary", "manifest"),
    overwrite = TRUE
  )
  overview_path <- exported$written_files$Path[
    exported$written_files$Component == "summary_overview"
  ][1]
  exported_overview <- utils::read.csv(overview_path, stringsAsFactors = FALSE)
  expect_identical(as.character(exported_overview$PopulationSDMode[1]), "estimated")
  expect_true(is.finite(exported_overview$EstimatedPopulationSD[1]))

  manifest <- suppressWarnings(build_mfrm_manifest(fit))
  expect_identical(as.character(manifest$summary$PopulationSDMode[1]), "estimated")
  expect_true(is.finite(manifest$summary$EstimatedPopulationSD[1]))
  expect_identical(
    as.character(manifest$model_settings$Value[manifest$model_settings$Setting == "population_sd_mode"][1]),
    "estimated"
  )

  replay <- build_mfrm_replay_script(fit, data_file = "analysis_data.csv")
  expect_identical(as.character(replay$summary$PopulationSDMode[1]), "estimated")
  expect_match(replay$script, "estimate_population_sd = TRUE", fixed = TRUE)
  expect_match(replay$script, "population_prior_sd = 1", fixed = TRUE)
  expect_match(replay$script, "population_sd_bounds = c\\(0.05, 10\\)")

  gpcm <- suppressWarnings(fit_mfrm(
    toy,
    "Person", c("Rater", "Criterion"), "Score",
    method = "MML",
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    quad_points = 5,
    maxit = 30,
    mml_engine = "direct",
    estimate_population_sd = TRUE
  ))
  expect_identical(gpcm$summary$Model[1], "GPCM")
  expect_identical(gpcm$summary$MMLEngineRequested[1], "direct")
  expect_identical(gpcm$summary$MMLEngineUsed[1], "em")
  expect_identical(gpcm$summary$PopulationSDMode[1], "estimated")
  expect_true(is.finite(gpcm$summary$EstimatedPopulationSD[1]))
  expect_s3_class(gpcm$slopes, "data.frame")
  expect_gt(nrow(gpcm$slopes), 0L)
  slope_vals <- as.numeric(gpcm$slopes$Estimate)
  expect_equal(
    exp(mean(log(slope_vals))),
    1,
    tolerance = 1e-8
  )
})

test_that("compare_mfrm carries population-SD metrics and reviews free-SD nesting", {
  toy <- load_mfrmr_data("example_core")
  fixed <- suppressWarnings(fit_mfrm(
    toy,
    "Person", c("Rater", "Criterion"), "Score",
    method = "MML",
    model = "RSM",
    quad_points = 5,
    maxit = 20,
    estimate_population_sd = FALSE
  ))
  free <- suppressWarnings(fit_mfrm(
    toy,
    "Person", c("Rater", "Criterion"), "Score",
    method = "MML",
    model = "RSM",
    quad_points = 5,
    maxit = 20,
    mml_engine = "em",
    estimate_population_sd = TRUE
  ))

  comp <- compare_mfrm(fixed, free, labels = c("Fixed", "Free"))
  expect_true(all(c(
    "MMLEngineRequested", "MMLEngineUsed", "PopulationSDMode",
    "PopulationPriorSD", "EstimatedPopulationSD", "PopulationSDSE",
    "PopulationSDCI_Lower", "PopulationSDCI_Upper", "PopulationSDSEStatus",
    "ComparisonFamily", "ComparisonStrength", "InterpretationGuard"
  ) %in% names(comp$table)))
  expect_identical(as.character(comp$table$PopulationSDMode), c("fixed", "estimated"))
  expect_equal(comp$table$npar[comp$table$Label == "Free"],
               comp$table$npar[comp$table$Label == "Fixed"] + 1L)
  expect_true(is.na(comp$table$EstimatedPopulationSD[comp$table$Label == "Fixed"]))
  expect_true(is.finite(comp$table$EstimatedPopulationSD[comp$table$Label == "Free"]))
  expect_identical(comp$comparison_basis$comparison_family, "population_sd_sensitivity")
  expect_identical(comp$comparison_basis$comparison_strength, "formal_mml_ic_available")
  expect_identical(
    as.character(comp$comparison_guidance$ComparisonFamily[1]),
    "population_sd_sensitivity"
  )
  expect_match(
    comp$comparison_guidance$APAStyleTemplate[1],
    "population-SD sensitivity",
    fixed = TRUE
  )

  comp_lrt <- suppressWarnings(compare_mfrm(fixed, free, labels = c("Fixed", "Free"), nested = TRUE))
  review <- comp_lrt$comparison_basis$nesting_review
  expect_true(isTRUE(review$eligible))
  expect_identical(as.character(review$relation), "population_sd_extension")
  expect_identical(as.character(review$simpler), "Fixed")
  expect_identical(as.character(review$complex), "Free")

  choice <- build_model_choice_review(Fixed = fixed, Free = free)
  expect_true(isTRUE(choice$overview$MixedPopulationSDModes[1]))
  expect_identical(as.character(choice$overview$ComparisonFamily[1]), "population_sd_sensitivity")
  expect_true(any(grepl("mixed MML population-SD modes", choice$key_warnings, fixed = TRUE)))
  expect_true(all(c("PopulationSDMode", "PopulationMetric") %in% names(choice$model_roles)))
  expect_identical(as.character(choice$model_roles$PopulationSDMode), c("fixed", "estimated"))
  expect_true(all(c("comparison_guidance", "comparison_reporting_templates") %in% names(choice)))
  expect_identical(
    as.character(choice$comparison_guidance$ComparisonFamily[1]),
    "population_sd_sensitivity"
  )
})

test_that("comparison guidance separates mixed metric and response-model changes", {
  guide <- compare_mfrm_family_guidance(
    tbl = data.frame(
      Model = c("RSM", "GPCM"),
      PopulationSDMode = c("fixed", "estimated"),
      stringsAsFactors = FALSE
    ),
    nesting_review = list(relation = "unsupported"),
    ic_comparable = TRUE
  )

  expect_identical(as.character(guide$ComparisonFamily[1]), "mixed_metric_and_response_model")
  expect_identical(as.character(guide$ComparisonStrength[1]), "formal_mml_ic_available")
  expect_match(guide$InterpretationGuard[1], "Do not make one combined model-choice claim", fixed = TRUE)
  expect_match(guide$NextAction[1], "two-step sensitivity grid", fixed = TRUE)
})

test_that("population SD profile marks boundary curvature as unavailable", {
  fixture <- simulate_rsm_free_sd_fixture()
  fit <- fit_mfrm(
    fixture$data,
    "Person", c("Rater", "Criterion"), "Score",
    method = "MML",
    model = "RSM",
    quad_points = 7,
    maxit = 50,
    reltol = 1e-4,
    mml_engine = "em",
    estimate_population_sd = TRUE,
    population_sd_bounds = c(0.05, 0.30)
  )

  expect_equal(fit$summary$EstimatedPopulationSD[1], 0.30, tolerance = 1e-12)
  expect_true(is.na(fit$summary$PopulationSDSE[1]))
  expect_identical(fit$summary$PopulationSDSEStatus[1], "unavailable")
  expect_true(grepl("boundary", fit$config$population_sd_se_reason, fixed = TRUE))
})
