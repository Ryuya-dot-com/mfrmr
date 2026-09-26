response_fixture <- function() {
  d <- data.frame(Event = c("001", "1", "NA", "é", "5", "6", "7", "8"),
    Person = rep(c("P1", "P2"), each = 4), Rater = rep(c("A", "B"), 4),
    Task = rep(c("T1", "T1", "T2", "T2"), 2),
    Score = c(0, NA, 2, NA, 1, 2, NA, NA),
    Assigned = c(TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE))
  a <- b <- d
  a$Score[c(2, 7)] <- c(1, 0)
  b$Score[c(2, 7)] <- c(2, 1)
  list(data = d, completed = list(a, b), person = "Person", facets = c("Rater", "Task"),
    score = "Score", event_id = "Event", impute = c("1", "7"), categories = 0:2,
    assigned = "Assigned", missing = "omit", imputation_model = list(method = "test completions"))
}

test_that("response review preserves identities, assignments and explicit omissions", {
  a <- response_fixture()
  a$completed[[2]] <- a$completed[[2]][8:1, ]
  x <- do.call(mfrm_response_imputations, a)
  expect_s3_class(x, "mfrm_response_imputations")
  expect_identical(x$events$ID, a$data$Event)
  expect_equal(x$completed[[2]]$Event, a$data$Event)
  expect_identical(x$events$Imputed, seq_len(8) %in% c(2, 7))
  expect_identical(which(x$events$Omitted), 8L)
  expect_true(all(vapply(x$completed, function(d) is.na(d$Score[4]), logical(1))))
  expect_identical(x$imputation_model, a$imputation_model)
  expect_equal(summary(x)$Observed[summary(x)$Facet == "Person"], c(2, 2))
  expect_output(print(x), "1 unassigned rows; 1 omitted assigned rows")
  file <- tempfile(fileext = ".rds")
  saveRDS(x, file)
  expect_identical(readRDS(file), x)
  a$assigned <- NULL
  a$data$Assigned <- NULL
  a$completed <- lapply(a$completed, function(d) { d$Assigned <- NULL; d })
  expect_true(all(do.call(mfrm_response_imputations, a)$events$Assigned))
})

test_that("response review refuses changed evidence and impossible imputation targets", {
  base <- response_fixture()
  bad <- base; bad$missing <- "error"
  expect_error(do.call(mfrm_response_imputations, bad), "not selected")
  bad <- base; bad$impute <- c("1", "é", "7")
  expect_error(do.call(mfrm_response_imputations, bad), "Only missing scores on assigned")
  bad <- base; bad$impute <- c("001", "7")
  expect_error(do.call(mfrm_response_imputations, bad), "Only missing scores")
  bad <- base; bad$completed[[2]]$Score[1] <- 1
  expect_error(do.call(mfrm_response_imputations, bad), "Imputation 2: Observed")
  bad <- base; bad$completed[[1]]$Score[4] <- 1
  expect_error(do.call(mfrm_response_imputations, bad), "unselected scores")
  bad <- base; bad$completed[[2]]$Score[2] <- 0.5
  expect_error(do.call(mfrm_response_imputations, bad), "categories")
  bad <- base; bad$completed[[2]]$Score[2] <- NA
  expect_error(do.call(mfrm_response_imputations, bad), "must be completed")
  bad <- base; bad$completed[[1]]$Rater[2] <- "changed"
  expect_error(do.call(mfrm_response_imputations, bad), "Identifiers")
  bad <- base; bad$completed[[1]]$Assigned[4] <- TRUE
  expect_error(do.call(mfrm_response_imputations, bad), "assignment")
  bad <- base; bad$completed[[1]]$Event[2] <- "001"
  expect_error(do.call(mfrm_response_imputations, bad), "all event IDs exactly once")
  bad <- base; bad$categories <- c(0, 2)
  expect_error(do.call(mfrm_response_imputations, bad), "contiguous")
  bad <- base; bad$imputation_model <- NULL
  expect_error(do.call(mfrm_response_imputations, bad), "Retain the saved")
  bad <- base; bad$completed <- bad$completed[1]
  expect_error(do.call(mfrm_response_imputations, bad), "at least two")
  bad <- base; bad$data$Assigned[4] <- NA
  expect_error(do.call(mfrm_response_imputations, bad), "complete and logical")
  bad <- base; bad$data$Score[4] <- 1
  expect_error(do.call(mfrm_response_imputations, bad), "Unassigned rows")
})

test_that("mids input retains its model and enforces original data and where", {
  skip_if_not_installed("mice")
  a <- response_fixture()
  long <- do.call(rbind, lapply(0:2, function(i) {
    d <- if (i == 0) a$data else a$completed[[i]]
    d$.imp <- i; d$.id <- seq_len(nrow(d)); d
  }))
  where <- is.na(a$data); where[,] <- FALSE; where[c(2, 7), "Score"] <- TRUE
  mids <- mice::as.mids(long, where = where)
  a$completed <- mids; a$imputation_model <- NULL
  x <- do.call(mfrm_response_imputations, a)
  expect_identical(x$imputation_model, mids)
  expect_equal(x$completed[[2]]$Score[c(2, 7)], c(2, 1))
  bad <- a; bad$completed$where[4, "Score"] <- TRUE
  expect_error(do.call(mfrm_response_imputations, bad), "where.*exactly")
  bad <- a; bad$completed$data$Score[1] <- 1
  expect_error(do.call(mfrm_response_imputations, bad), "Observed")
  bad <- a; bad$completed$where[1, "Event"] <- TRUE
  expect_error(do.call(mfrm_response_imputations, bad), "identifier")
})

local({
  d <- load_mfrmr_data("example_core")
  d$Event <- paste0("E", seq_len(nrow(d)))
  # Integration fixture only: hand completions test calculation and provenance,
  # not statistical adequacy of an imputation model.
  missing_rows <- c(2, 8, 30, 100, 200, 400)
  a <- b <- d
  a$Score[missing_rows] <- c(1, 2, 3, 4, 1, 2)
  b$Score[missing_rows] <- c(3, 4, 1, 2, 2, 3)
  d$Score[missing_rows] <- NA
  x <- mfrm_response_imputations(d, list(a, b), "Person", c("Rater", "Criterion"),
    "Score", "Event", d$Event[missing_rows], 1:4,
    imputation_model = list(method = "integration fixture"))
  fitted <- fit_mfrm_imputed(x)

  test_that("all fits use the declared category ladder and common scale", {
    expect_s3_class(fitted, "mfrm_imputed_fits")
    expect_true(all(fitted$analysis_summary$InferenceReady))
    expect_length(fitted$fits, 2)
    expect_identical(fitted$settings$keep_original, TRUE)
    expect_identical(fitted$fits[[1]]$prep$score_map, fitted$fits[[2]]$prep$score_map)
    expect_equal(fitted$fits[[1]]$prep$n_obs, nrow(d))
    expect_equal(summary(fitted), fitted$analysis_summary)
    expect_error(fit_mfrm_imputed(x, method = "JML"), "supported shared fitting")
    expect_error(fit_mfrm_imputed(x, weight = "Weight"), "supported shared fitting")
    expect_error(fit_mfrm_imputed(x, model = "PCM"), "explicit model facet")
    expect_error(fit_mfrm_imputed(x, population_formula = ~1), "supported shared fitting")
  })

  test_that("pooled facet covariance and differences match independent Rubin calculations", {
    pooled <- pool_mfrm_imputed(fitted, "Rater")
    expect_s3_class(pooled, "mfrm_pooled")
    levels <- pooled$facet_levels
    q <- t(vapply(fitted$fits, function(f) f$facets$others$Estimate[
      match(levels, f$facets$others$Level)], numeric(length(levels))))
    u <- lapply(fitted$fits, function(f) {
      v <- compute_mml_parameter_covariance(f)
      j <- constraint_jacobian(f$config$facet_specs$Rater)
      j %*% v$cov[v$param_slices$Rater, v$param_slices$Rater] %*% t(j)
    })
    expect_equal(unname(pooled$estimates), unname(q))
    expect_equal(unname(pooled$total), unname((u[[1]] + u[[2]]) / 2 + 1.5 * cov(q)))
    contrast <- matrix(c(1, -1, 0, 0), 1, dimnames = list("A minus B", levels))
    difference <- pool_mfrm_imputed(fitted, "Rater", contrast, df_complete = 50)
    expected_total <- drop(contrast %*% pooled$total %*% t(contrast))
    expect_equal(difference$table$TotalVariance, expected_total)
    expect_equal(difference$table$Estimate, mean(q[, 1] - q[, 2]))
    expect_equal(difference$table$MonteCarloSE, sd(q[, 1] - q[, 2]) / sqrt(2))
    expect_equal(pool_mfrm_imputed(fitted, "Rater", contrast[, 4:1, drop = FALSE],
      df_complete = 50)$table, difference$table)
    if (requireNamespace("mice", quietly = TRUE)) {
      reference <- mice::pool.scalar(q[, 1] - q[, 2],
        vapply(u, function(v) drop(contrast %*% v %*% t(contrast)), numeric(1)), n = 51)
      expect_equal(difference$table$SE^2, reference$t)
      expect_equal(difference$table$DF, reference$df)
      expect_equal(difference$table$Lower, reference$qbar - qt(.975, reference$df) * sqrt(reference$t))
    }
    fixed <- matrix(rep(1/4, 4), 1, dimnames = list("Constrained mean", levels))
    fixed_result <- pool_mfrm_imputed(fitted, "Rater", fixed)
    expect_identical(fixed_result$table$Status, "fixed")
    expect_equal(fixed_result$table$TotalVariance, 0, tolerance = 1e-28)
    expect_true(is.na(fixed_result$table$Lower))
    file <- tempfile(fileext = ".rds"); saveRDS(pooled, file)
    expect_identical(readRDS(file), pooled)
    expect_equal(summary(pooled), pooled$table)
  })

  test_that("pooling refuses incomplete, ineligible and mismatched analyses", {
    expect_error(pool_mfrm_imputed(fitted, "Person"), "non-person")
    bad <- fitted; bad$fits[2] <- list(NULL)
    expect_error(pool_mfrm_imputed(bad, "Rater"), "imputation.*2")
    bad <- fitted; bad$fits[[2]]$config$facet_signs[1] <- -bad$fits[[2]]$config$facet_signs[1]
    expect_error(pool_mfrm_imputed(bad, "Rater"), "one category scale")
    bad <- fitted; bad$fits <- rev(bad$fits)
    expect_error(pool_mfrm_imputed(bad, "Rater"), "do not match completion")
    expect_error(pool_mfrm_imputed(fitted, "Rater", ci_level = 1), "ci_level")
    expect_error(pool_mfrm_imputed(fitted, "Rater", df_complete = 0), "df_complete")
    expect_error(pool_mfrm_imputed(fitted, "Rater", matrix(1, 1, 4)), "contrasts")
    v <- compute_mml_parameter_covariance(fitted$fits[[1]])
    v$status <- "regularized"
    local_mocked_bindings(compute_mml_parameter_covariance = function(...) v)
    expect_error(pool_mfrm_imputed(fitted, "Rater"), "unregularized")
  })

  test_that("unchanging imputations and exact anchors keep their distinct uncertainty meanings", {
    same <- x
    same$completed[[2]] <- same$completed[[1]]
    same_fits <- fitted
    same_fits$imputations <- same
    same_fits$fits[[2]] <- same_fits$fits[[1]]
    result <- pool_mfrm_imputed(same_fits, "Rater")
    expect_equal(result$between, matrix(0, 4, 4, dimnames = dimnames(result$between)))
    expect_true(all(is.infinite(result$table$DF)))
    expect_equal(result$table$Lower, result$table$Estimate - qnorm(.975) * result$table$SE)
    anchor <- data.frame(Facet = "Rater", Level = "R01", Anchor = 0)
    anchored <- fit_mfrm_imputed(x, anchors = anchor)
    result <- pool_mfrm_imputed(anchored, "Rater")
    row <- result$table$Target == "R01"
    expect_identical(result$table$Status[row], "fixed")
    expect_equal(result$table$Estimate[row], 0)
    expect_equal(result$table$SE[row], 0)
    expect_true(is.na(result$table$Lower[row]))
    expect_true(all(result$table$SE[!row] > 0))
    pcm <- fit_mfrm_imputed(x, model = "PCM", step_facet = "Criterion")
    expect_true(all(pcm$analysis_summary$InferenceReady))
    expect_true(all(is.finite(pool_mfrm_imputed(pcm, "Rater")$table$Lower)))
  })

  test_that("pooled plots reuse the selected targets and intervals without refitting", {
    pooled <- pool_mfrm_imputed(fitted, "Rater")
    local_mocked_bindings(fit_mfrm = function(...) stop("unexpected refit"),
      compute_mml_parameter_covariance = function(...) stop("unexpected covariance recalculation"))
    device <- grDevices::dev.cur()
    drawing <- plot(pooled, draw = FALSE)
    expect_identical(grDevices::dev.cur(), device)
    expect_s3_class(drawing, "mfrm_plot_data")
    expect_equal(plot_data(drawing)$table, pooled$table)
    expect_equal(plot_data(drawing)$contrasts, pooled$contrasts)
    expect_match(plot_data(drawing)$subtitle, "pointwise MI")
    expect_error(plot(pooled, draw = NA), "draw")
    if (requireNamespace("ggplot2", quietly = TRUE)) {
      expect_s3_class(as_ggplot(drawing), "ggplot")
    }
    file <- tempfile(fileext = ".pdf")
    grDevices::pdf(file)
    before <- graphics::par("mar")
    plot(pooled)
    expect_equal(graphics::par("mar"), before)
    grDevices::dev.off()
    expect_gt(file.info(file)$size, 0)
  })

  test_that("failed fits remain in their original positions and prevent pooling", {
    count <- 0L
    local_mocked_bindings(fit_mfrm = function(...) {
      count <<- count + 1L
      if (count == 2L) stop("deliberate optimizer failure")
      warning("retained review warning")
      fitted$fits[[count]]
    })
    failed <- fit_mfrm_imputed(x)
    expect_length(failed$fits, 2)
    expect_null(failed$fits[[2]])
    expect_match(failed$analysis_summary$Error[2], "deliberate optimizer failure")
    expect_match(failed$analysis_summary$Warnings[1], "retained review warning")
    expect_error(pool_mfrm_imputed(failed, "Rater"), "No imputations were discarded")
  })
})
