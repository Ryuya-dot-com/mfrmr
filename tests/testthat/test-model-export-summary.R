export_summary_helpers <- function() {
  env <- new.env(parent = globalenv())
  sys.source(system.file("model-export", "summarize.R", package = "mfrmr"), env)
  env
}

test_that("posterior labels and fixed status come from exported constraints", {
  env <- export_summary_helpers()
  fit <- readRDS(test_path("fixtures", "anchored-gpcm.rds"))$fixed_population$fit
  bundle <- mfrmr:::mfrm_model_export_data(fit, 1, 1, 1)
  map <- env$mfrm_parameter_map(bundle)
  locations <- map[match(bundle$levels$Parameter, map$variable), ]
  expect_identical(locations$level, bundle$levels$Level)
  expect_equal(!is.na(locations$fixed_value), bundle$levels$Fixed)
  expect_true(any(locations$value_role == "fixed_anchor"))
  expect_true(all(locations$value_role[locations$quantity == "ability"] == "estimated"))
  expect_match(locations$direction[locations$quantity == "ability"][1], "higher coded scores", fixed = TRUE)
  expect_true(all(grepl("lower coded scores", locations$direction[locations$quantity == "location"], fixed = TRUE)))
  expect_false(anyDuplicated(map$variable) > 0L)

  # A singleton slope and a binary centered step are identified constants, not anchors.
  bundle$stan_data$slope_basis <- matrix(numeric(), 1L, 0L)
  bundle$slope_levels <- bundle$slope_levels[1L, ]
  bundle$stan_data$C <- 2L
  bundle$stan_data$step_basis <- matrix(numeric(), bundle$stan_data$G, 0L)
  bundle$stan_data$step_offset <- rep(0, bundle$stan_data$G)
  bundle$constraints$steps <- NULL
  singleton <- env$mfrm_parameter_map(bundle)
  expect_true(all(singleton$value_role[singleton$quantity %in% c("slope", "step_offset")] == "fixed_by_constraint"))
  expect_equal(singleton$fixed_value[singleton$quantity == "slope"], 1)
  expect_equal(singleton$fixed_value[singleton$quantity == "log_slope"], 0)
})

test_that("missing or poor diagnostics cannot become a clean sampling screen", {
  env <- export_summary_helpers()
  p <- data.frame(value_role = c("estimated", "fixed_anchor", "sampling_coordinate"),
    rhat = c(1, NA, 1), ess_bulk = c(800, NA, 700), ess_tail = c(700, NA, 600))
  sampler <- data.frame(chain = 1:4, num_divergent = 0, num_max_treedepth = 0, ebfmi = .8)
  clean <- env$mfrm_sampling_review(p, sampler, 4L)
  expect_true(all(clean$Status == "no_flag"))
  p$rhat[3] <- NA_real_
  missing <- env$mfrm_sampling_review(p, sampler, 4L)
  expect_identical(missing$Status[missing$Check == "rhat"], "not_available")
  p$rhat[3] <- 1.02
  sampler$num_divergent[2] <- 1
  sampler$ebfmi[3] <- .2
  bad <- env$mfrm_sampling_review(p, sampler, 4L)
  expect_true(all(bad$Status[bad$Check %in% c("rhat", "num_divergent", "ebfmi")] == "review"))
  incomplete <- env$mfrm_sampling_review(p, sampler[-1L, ], 4L)
  expect_true(all(incomplete$Status[incomplete$Check %in% c("num_divergent", "num_max_treedepth", "ebfmi")] == "not_available"))
  sampler$chain[2] <- 1
  duplicate <- env$mfrm_sampling_review(p, sampler, 4L)
  expect_true(all(duplicate$Status[duplicate$Check %in% c("num_divergent", "num_max_treedepth", "ebfmi")] == "not_available"))
})

test_that("legacy unanchored maps retain binary steps and both slope owners", {
  env <- export_summary_helpers()
  fit <- readRDS(test_path("fixtures", "gmfrm-adaptive-profiles.rds"))$fit
  bundle <- mfrmr:::mfrm_model_export_data(fit, 1, 1, 1)
  expect_false(isTRUE(bundle$affine))
  map <- env$mfrm_parameter_map(bundle)
  slopes <- map[map$quantity == "slope", ]
  expect_identical(slopes$level, bundle$slope_levels$Level)
  expect_identical(slopes$facet, bundle$slope_levels$Owner)
  expect_true(all(slopes$value_role == "estimated"))
  expect_true(any(grepl("geometric mean slope = 1", slopes$reference, fixed = TRUE)))
  expect_true(any(grepl("Component scale identified", slopes$reference, fixed = TRUE)))
  # RSM/PCM without affine anchors use the same shared step basis.
  bundle$slope_levels <- NULL
  bundle$stan_data$C <- 2L
  bundle$stan_data$step_basis <- matrix(numeric(), 1L, 0L)
  binary <- env$mfrm_parameter_map(bundle)
  expect_true(all(binary$value_role[binary$quantity == "step_offset"] == "fixed_by_constraint"))
  expect_true(all(binary$fixed_value[binary$quantity == "step_offset"] == 0))
})

test_that("both bundle runners can be sourced without executing estimation", {
  for (format in c("stan", "brms")) {
    env <- new.env(parent = globalenv())
    expect_silent(sys.source(system.file("model-export", paste0("run-", format, ".R"), package = "mfrmr"), env))
    expect_true(is.function(env[[paste0("summarize_mfrm_", format)]]))
    expect_error(env[[paste0("run_mfrm_", format)]]("--unknown"), "Usage:")
  }
})
