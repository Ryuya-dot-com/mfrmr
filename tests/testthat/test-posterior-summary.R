posterior_example <- function() read_mfrm_posterior(system.file(
  "extdata", "posterior-example", package = "mfrmr"))

test_that("saved posterior summaries connect to methods without a backend", {
  x <- posterior_example()
  expect_s3_class(x, "mfrm_posterior_summary")
  expect_identical(x$source$Estimation, "External Bayesian sampling")
  expect_identical(x$source$ExportSourceMethod, "MML")
  expect_identical(summary(x), x)
  before <- serialize(x, NULL)
  expect_output(print(x), "Sampling checks do not establish model validity", fixed = TRUE)
  ci <- confint(x)
  p <- x$parameters[x$parameters$role == "reported_parameter", ]
  expect_identical(ci[names(p)], p)
  fixed <- ci$value_role %in% c("fixed_anchor", "fixed_by_constraint")
  expect_true(any(fixed))
  expect_true(all(is.na(ci$lower[fixed]) & is.na(ci$upper[fixed])))
  expect_true(all(ci$interval_status[!fixed] == "computed_sampling_review_required"))
  expect_match(unique(ci$interval_type), "posterior credible", fixed = TRUE)
  expect_identical(confint(x, parm = "locations[1]")$variable, "locations[1]")
  expect_identical(confint(x, parm = 1L)$variable, x$parameters$variable[1L])
  expect_error(confint(x, level = .9), "backend's draws", fixed = TRUE)
  for (parm in list("unknown", c(1L, 1L), 0, 1.5, NA, logical()))
    expect_error(confint(x, parm = parm), "parm")
  expect_identical(serialize(x, NULL), before)
})

test_that("checksum, fixed-value and diagnostic inconsistencies fail before reporting", {
  dir <- tempfile(); dir.create(dir); on.exit(unlink(dir, recursive = TRUE), add = TRUE)
  src <- system.file("extdata", "posterior-example", package = "mfrmr")
  file.copy(file.path(src, c("model-data.rds", "posterior-summary.rds")), dir)
  expect_s3_class(read_mfrm_posterior(file.path(dir, "posterior-summary.rds")), "mfrm_posterior_summary")
  b <- readRDS(file.path(dir, "model-data.rds"))
  # Recompression preserves R values but breaks the saved file identity.
  saveRDS(b, file.path(dir, "model-data.rds"), compress = FALSE)
  expect_identical(readRDS(file.path(dir, "model-data.rds")), b)
  expect_error(read_mfrm_posterior(dir), "checksum")
  b$priors$location_marginal_sd <- 2
  saveRDS(b, file.path(dir, "model-data.rds"))
  expect_error(read_mfrm_posterior(dir), "checksum")
  expect_error(read_mfrm_posterior(tempfile()), "together")
  x <- posterior_example()
  mutations <- list(
    function(z) {z$parameters$level[1] <- "another person"; z},
    function(z) {z$parameters$mean[z$parameters$value_role == "fixed_anchor"][1] <- 5; z},
    function(z) {z$parameters$lower[z$parameters$value_role == "fixed_anchor"][1] <- 0; z},
    function(z) {z$decision$Status <- "no_sampling_flags_detected"; z},
    function(z) {z$checks$Status[] <- "no_flag"; z},
    function(z) {z$sampler <- z$sampler[-1, ]; z},
    function(z) {z$parameters$variable[2] <- z$parameters$variable[1]; z},
    function(z) {z$parameters$lower[z$parameters$quantity == "slope"][1] <- -.1; z},
    function(z) {z$parameters$interval_status[] <- "computed_model_review_required"; z})
  for (change in mutations) {
    bad <- change(x)
    expect_error(summary(bad), "Inconsistent")
    expect_error(confint(bad), "Inconsistent")
  }
})
