local({
  d <- load_mfrmr_data("example_core")
  f <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score")
  intervals <- mfrm_facet_intervals(f, "Rater", method = "sandwich")

  test_that("Person scores and sandwich reproduce direct full-covariance calculations", {
    h <- compute_mml_parameter_covariance(f)
    expect_equal(intervals$parameter_covariance,
      h$cov %*% crossprod(intervals$person_scores) %*% h$cov, ignore_attr = TRUE)
    idx <- build_indices(f$prep)
    gradient <- mfrm_grad_mml(f$opt$par, idx, f$config, h$sizes, gauss_hermite_normal(31))
    expect_lt(max(abs(colSums(intervals$person_scores) + gradient)), 1e-9)
    ordinary <- mfrm_facet_intervals(f, "Rater")
    expect_equal(ordinary$table$SE, intervals$table$ModelSE)
    expect_null(ordinary$person_scores)
    j <- matrix(c(1, -1, 0, 0), 1, dimnames = list("R01 minus R02", rownames(intervals$contrasts)))
    pair <- mfrm_facet_intervals(f, "Rater", j, method = "sandwich")
    expect_equal(pair$table$SE^2, drop(j %*% intervals$covariance %*% t(j)))
    expect_equal(pair$table$Estimate, sum(j * intervals$table$Estimate))
    expect_equal(mfrm_facet_intervals(f, "Rater", j[, 4:1, drop = FALSE],
      method = "sandwich")$table, pair$table)
    expect_equal(pair$table$Lower, pair$table$Estimate - qnorm(.975) * pair$table$SE)
    expect_equal(summary(intervals), intervals$table)
    saved <- tempfile(fileext = ".rds"); saveRDS(intervals, saved)
    expect_identical(readRDS(saved), intervals)
  })

  test_that("larger clusters aggregate scores before their outer products", {
    ids <- rownames(intervals$person_scores)
    groups <- data.frame(Person = rev(ids), Cluster = rep(seq_len(16), each = 3))
    clustered <- mfrm_facet_intervals(f, "Rater", method = "sandwich", clusters = groups)
    sums <- rowsum(intervals$person_scores, groups$Cluster[match(ids, groups$Person)], reorder = FALSE)
    expect_equal(clustered$cluster_scores, sums)
    v <- intervals$model_parameter_covariance
    expect_equal(clustered$parameter_covariance, v %*% crossprod(sums) %*% v, ignore_attr = TRUE)
    adjusted <- mfrm_facet_intervals(f, "Rater", method = "sandwich", clusters = groups, adjust = TRUE)
    expect_equal(adjusted$table$SE, sqrt(16 / 15) * clustered$table$SE)
    expect_equal(adjusted$settings$adjustment_factor, 16 / 15)
    groups$Cluster <- rep(1:2, each = 24)
    too_few <- mfrm_facet_intervals(f, "Rater", method = "sandwich", clusters = groups)
    expect_true(all(too_few$table$Status == "insufficient_cluster_rank"))
    expect_true(all(is.na(too_few$table$Lower)))
    expect_equal(too_few$table$Estimate, intervals$table$Estimate)
    expect_true(all(is.finite(too_few$table$ModelLower)))
    expect_error(mfrm_facet_intervals(f, "Rater", method = "sandwich", clusters = groups[-1, ]), "exactly once")
    groups$Cluster <- 1
    expect_error(mfrm_facet_intervals(f, "Rater", method = "sandwich", clusters = groups), "at least two")
    groups$Cluster[1] <- NA
    expect_error(mfrm_facet_intervals(f, "Rater", method = "sandwich", clusters = groups), "nonmissing")
  })

  test_that("unsupported inference cannot acquire a robust label", {
    expect_error(mfrm_facet_intervals(f, "Person"), "non-person")
    expect_error(mfrm_facet_intervals(f, "Rater", adjust = TRUE), "only to method")
    expect_error(mfrm_facet_intervals(f, "Rater", level = 1), "level")
    bad <- f; bad$config$method <- "JML"
    expect_error(mfrm_facet_intervals(bad, "Rater"), "inference-ready")
    bad <- f; bad$config$population_spec$active <- TRUE
    expect_error(mfrm_facet_intervals(bad, "Rater"), "standard-normal")
    bad <- f; bad$config$model <- "GPCM"
    expect_error(mfrm_facet_intervals(bad, "Rater"), "RSM/PCM")
    bad <- f; bad$prep$data$Weight[1] <- 2
    expect_error(mfrm_facet_intervals(bad, "Rater"), "unit weights")
    bad <- f; bad$readiness$fit$InferenceReady <- FALSE
    expect_error(mfrm_facet_intervals(bad, "Rater"), "inference-ready")
    covariance <- compute_mml_parameter_covariance(f); covariance$status <- "regularized"
    local_mocked_bindings(compute_mml_parameter_covariance = function(...) covariance)
    expect_error(mfrm_facet_intervals(f, "Rater"), "Unregularized")
  })

  test_that("PCM, anchors and interaction gradients preserve their fitted constraints", {
    for (args in list(list(model = "PCM", step_facet = "Criterion"),
                     list(anchors = data.frame(Facet = "Rater", Level = "R01", Anchor = .1)),
                     list(facet_interactions = "Rater:Criterion"))) {
      fit <- suppressWarnings(do.call(fit_mfrm, c(list(data = d, person = "Person",
        facets = c("Rater", "Criterion"), score = "Score"), args)))
      result <- mfrm_facet_intervals(fit, "Rater", method = "sandwich")
      expect_true(all(result$table$Status %in% c("available", "fixed")))
      if (!is.null(args$anchors)) {
        fixed <- result$table$Target == "R01"
        expect_equal(result$table$Estimate[fixed], .1)
        expect_equal(result$table$SE[fixed], 0)
        expect_true(is.na(result$table$Lower[fixed]))
      }
    }
  })

  test_that("plots and summaries retain methods without refitting", {
    local_mocked_bindings(fit_mfrm = function(...) stop("unexpected refit"),
      compute_mml_parameter_covariance = function(...) stop("unexpected recomputation"))
    device <- grDevices::dev.cur()
    result <- plot(intervals, draw = FALSE)
    expect_identical(grDevices::dev.cur(), device)
    expect_equal(plot_data(result)$table, intervals$table)
    expect_true(plot_data(result)$comparison)
    expect_false(plot_data(plot(intervals, comparison = FALSE, draw = FALSE))$comparison)
    expect_error(plot(intervals, draw = NA), "TRUE or FALSE")
    if (requireNamespace("ggplot2", quietly = TRUE)) expect_error(as_ggplot(result), "interval methods")
    file <- tempfile(fileext = ".pdf"); grDevices::pdf(file)
    before <- graphics::par("mar"); plot(intervals)
    expect_equal(graphics::par("mar"), before)
    grDevices::dev.off()
    expect_gt(file.info(file)$size, 0)
  })
})

test_that("individual marginal scores match independent continuous integration", {
  with_preserved_rng_seed(9812, {
    d <- expand.grid(Person = paste0("P", 1:40), Rater = c("A", "B"),
      Task = c("X", "Y"), stringsAsFactors = FALSE)
    theta <- rnorm(40)
    r <- ifelse(d$Rater == "A", 1, -1); t <- ifelse(d$Task == "X", 1, -1)
    eta <- theta[match(d$Person, unique(d$Person))] - .3 * r - .4 * t
    logits <- cbind(0, eta + .6, 2 * eta)
    prob <- exp(logits - apply(logits, 1, max)); prob <- prob / rowSums(prob)
    d$Score <- vapply(seq_len(nrow(d)), function(i) sample(0:2, 1, prob = prob[i, ]), integer(1))
  })
  for (model in c("RSM", "PCM")) {
    f <- fit_mfrm(d, "Person", c("Rater", "Task"), "Score", model = model,
      step_facet = if (model == "PCM") "Task" else NULL, quad_points = 61)
    scores <- mfrm_person_likelihood_scores(f)
    par <- f$opt$par
    for (person in c("P1", "P2", "P3")) {
      rows <- which(d$Person == person)
      loglik <- function(p) {
        density <- function(z) {
          eta <- outer(z, r[rows] * p[1] + t[rows] * p[2], "-")
          steps <- if (model == "RSM") rep(p[3], length(rows)) else p[2 + match(d$Task[rows], c("X", "Y"))]
          middle <- sweep(eta, 2, steps, "-")
          hi <- pmax(0, middle, 2 * eta)
          normalizer <- hi + log(exp(-hi) + exp(middle - hi) + exp(2 * eta - hi))
          numerator <- sweep(eta, 2, d$Score[rows], "*") -
            matrix(steps * (d$Score[rows] == 1), nrow(eta), length(rows), byrow = TRUE)
          exp(rowSums(numerator - normalizer)) * dnorm(z)
        }
        log(integrate(density, -Inf, Inf, rel.tol = 1e-10)$value)
      }
      reference <- vapply(seq_along(par), function(j) {
        delta <- numeric(length(par)); delta[j] <- 1e-4
        (loglik(par + delta) - loglik(par - delta)) / 2e-4
      }, numeric(1))
      expect_equal(unname(scores[person, ]), reference, tolerance = 1e-6)
    }
  }
})
