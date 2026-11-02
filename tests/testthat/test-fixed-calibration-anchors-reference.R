# Repository reference checks retain their original mathematical assertions.

g4_mock_config <- function(family = c("RSM", "PCM")) {
  family <- match.arg(family)
  levels <- list(
    Rater = c("R1", "R2", "R3"),
    Criterion = c("C1", "C2", "C3")
  )
  config <- list(
    model = family, method = "MML", n_cat = 5L,
    facet_names = names(levels), facet_levels = levels,
    step_facet = if (identical(family, "PCM")) "Criterion" else NULL,
    interaction_specs = list(), facet_interactions = character(0),
    population_spec = list(active = FALSE),
    facet_signs = c(Rater = -1, Criterion = -1),
    score_map = data.frame(
      OriginalScore = 0:4, InternalScore = 0:4,
      stringsAsFactors = FALSE
    )
  )
  config$facet_specs <- lapply(levels, mfrmr:::build_facet_constraint)
  config$step_specs <- mfrmr:::mfrmr_default_step_specs(config)
  config
}

g4_anchor <- function(family, level = NA_character_, step, value, order) {
  data.frame(
    AnchorId = paste0("g4::", order),
    AnchorType = if (identical(family, "RSM")) "shared_step" else "owned_step",
    ParameterClass = if (identical(family, "RSM")) "shared_step" else "owned_step",
    OwnerFacet = if (identical(family, "RSM")) NA_character_ else "Criterion",
    Level = level, Step = as.character(step), GroupId = NA_character_,
    Value = as.numeric(value), CoordinateSystem = "expanded_logit",
    DeclarationOrder = as.integer(order), stringsAsFactors = FALSE
  )
}

test_that("typed anchor rebuilding preserves the whole-facet convention", {
  levels <- list(Rater = c("A", "B", "C"))
  config <- list(model = "RSM", method = "MML", n_cat = 4L, facet_names = "Rater", facet_levels = levels,
    facet_specs = list(Rater = build_facet_constraint(levels$Rater, centering_scope = "facet")),
    interaction_specs = list(), facet_interactions = character(0),
    population_spec = list(active = FALSE))
  anchor <- data.frame(AnchorId = "a", AnchorType = "direct", ParameterClass = "facet",
    OwnerFacet = "Rater", Level = "A", Step = NA_character_, GroupId = NA_character_,
    Value = .7, CoordinateSystem = "expanded_logit", DeclarationOrder = 1L)
  updated <- .mfrmr_research$mfrmr_apply_typed_anchors(config, anchor)$config
  spec <- updated$facet_specs$Rater
  expect_identical(spec$centering_scope, "facet")
  expect_equal(unname(expand_facet_with_constraints(.2, spec)), c(.7, .2, -.9))
  incompatible <- anchor[rep(1, 3), ]
  incompatible$Level <- levels$Rater
  incompatible$AnchorId <- paste0("a", 1:3)
  incompatible$DeclarationOrder <- 1:3
  error <- tryCatch(.mfrmr_research$mfrmr_apply_typed_anchors(config, incompatible),
                    mfrm_calibration_error = identity)
  expect_s3_class(error, "mfrm_calibration_error")
  expect_identical(error$code, "ANCHOR_CONSTRAINT_INCOMPATIBLE")
})

test_that("empty typed anchors reduce exactly to existing step coordinates", {
  for (model in c("RSM", "PCM")) {
    config <- g2_mock_config(model)
    original_sizes <- mfrmr:::build_param_sizes(config)
    original_start <- mfrmr:::build_initial_param_vector(config, original_sizes)
    original <- mfrmr:::expand_params(original_start, original_sizes, config)

    applied <- .mfrmr_research$mfrmr_apply_typed_anchors(
      config, mfrmr:::mfrmr_calibration_anchor_template()
    )$config
    reduced_sizes <- mfrmr:::build_param_sizes(applied)
    reduced_start <- mfrmr:::build_initial_param_vector(applied, reduced_sizes)
    reduced <- mfrmr:::expand_params(reduced_start, reduced_sizes, applied)

    expect_identical(reduced_sizes, original_sizes)
    expect_equal(reduced_start, original_start, tolerance = 0)
    expect_equal(reduced$steps, original$steps, tolerance = 0)
    expect_equal(reduced$steps_mat, original$steps_mat, tolerance = 0)
  }
})

test_that("shared-step anchors determine free dimension, expansion, and gradient", {
  config <- g2_mock_config("RSM")
  anchor <- g2_anchor(
    "shared_step", "shared_step", step = "2", value = 0.25
  )
  applied <- .mfrmr_research$mfrmr_apply_typed_anchors(config, anchor)$config
  spec <- applied$step_specs$shared
  expanded <- mfrmr:::expand_step_constraint(-0.4, spec)
  jacobian <- mfrmr:::mfrmr_step_jacobian_sparse(
    applied, mfrmr:::build_param_sizes(applied)
  )$jacobian

  expect_identical(spec$n_params, 1L)
  expect_equal(expanded, c(-0.4, 0.25, 0.15), tolerance = 1e-15)
  expect_equal(sum(expanded), 0, tolerance = 1e-15)
  expect_identical(dim(jacobian), c(3L, 1L))
  expect_identical(as.integer(Matrix::rankMatrix(jacobian)), 1L)

  gradient <- c(0.7, -0.2, 0.4)
  analytic <- mfrmr:::project_step_constraint_gradient(gradient, spec)
  objective <- function(value) sum(
    gradient * mfrmr:::expand_step_constraint(value, spec)
  )
  epsilon <- 1e-6
  numeric <- (objective(-0.4 + epsilon) - objective(-0.4 - epsilon)) /
    (2 * epsilon)
  expect_equal(analytic, numeric, tolerance = 1e-9)
})

test_that("fully fixed coordinates reproduce expanded RSM probabilities", {
  config <- g2_mock_config("RSM")
  facet_values <- list(
    Rater = c(R1 = -0.3, R2 = 0.1, R3 = 0.2),
    Criterion = c(C1 = 0.4, C2 = -0.1, C3 = -0.3)
  )
  step_values <- c(`1` = -0.6, `2` = 0.1, `3` = 0.5)
  declarations <- list()
  for (facet in names(facet_values)) {
    for (level in names(facet_values[[facet]])) {
      declarations[[length(declarations) + 1L]] <- g2_anchor(
        "direct", "facet", facet, level, value = facet_values[[facet]][level]
      )
    }
  }
  for (step in names(step_values)) {
    declarations[[length(declarations) + 1L]] <- g2_anchor(
      "shared_step", "shared_step", step = step, value = step_values[step]
    )
  }
  anchors <- do.call(g2_bind_anchors, declarations)
  applied <- .mfrmr_research$mfrmr_apply_typed_anchors(config, anchors)$config
  sizes <- mfrmr:::build_param_sizes(applied)
  params <- mfrmr:::expand_params(numeric(0), sizes, applied)

  expect_equal(sizes$Rater, 0L)
  expect_equal(sizes$Criterion, 0L)
  expect_identical(sizes$steps, 0L)
  expect_equal(params$facets, facet_values, tolerance = 0)
  expect_equal(params$steps, unname(step_values), tolerance = 0)

  eta <- c(-1.1, -0.2, 0.7, 1.4)
  expected <- mfrmr:::category_prob_rsm(eta, c(0, cumsum(step_values)))
  actual <- mfrmr:::category_prob_rsm(eta, c(0, cumsum(params$steps)))
  expect_equal(actual, expected, tolerance = 0)

  invalid <- anchors
  index <- which(invalid$AnchorType == "shared_step")[1]
  invalid$Value[index] <- invalid$Value[index] + 0.01
  expect_identical(
    g2_capture_error(.mfrmr_research$mfrmr_apply_typed_anchors(
      config, invalid
    ))$code,
    "ANCHOR_CONSTRAINT_INCOMPATIBLE"
  )
})

test_that("owned-step constraints are independent by PCM owner level", {
  config <- g2_mock_config("PCM")
  anchors <- g2_bind_anchors(
    g2_anchor("owned_step", "owned_step", "Criterion", "C1", "1", value = -0.4),
    g2_anchor("owned_step", "owned_step", "Criterion", "C2", "1", value = -0.2),
    g2_anchor("owned_step", "owned_step", "Criterion", "C2", "3", value = 0.3)
  )
  applied <- .mfrmr_research$mfrmr_apply_typed_anchors(config, anchors)$config
  sizes <- mfrmr:::build_param_sizes(applied)
  jacobian <- mfrmr:::mfrmr_step_jacobian_sparse(applied, sizes)$jacobian

  expect_identical(
    vapply(applied$step_specs, `[[`, integer(1), "n_params"),
    c(C1 = 1L, C2 = 0L, C3 = 2L)
  )
  expect_identical(sizes$steps, 3L)
  expect_error(
    mfrmr:::expand_step_constraints(0.15, applied$step_specs),
    "require 3"
  )
  matrix <- mfrmr:::expand_step_constraints(c(0.15, -0.25, 0.05),
                                             applied$step_specs)
  expect_equal(matrix["C1", ], c(-0.4, 0.15, 0.25), tolerance = 1e-15)
  expect_equal(matrix["C2", ], c(-0.2, -0.1, 0.3), tolerance = 1e-15)
  expect_equal(unname(rowSums(matrix)), rep(0, 3), tolerance = 1e-15)
  expect_identical(dim(jacobian), c(9L, 3L))
  expect_identical(as.integer(Matrix::rankMatrix(jacobian)), 3L)
})

test_that("direct and group anchors are jointly checked without precedence", {
  config <- g2_mock_config("RSM")
  anchors <- g2_bind_anchors(
    g2_anchor("direct", "facet", "Criterion", "C1", value = 0.2),
    g2_anchor("group", "facet", "Criterion", "C1", group = "G", value = 0.1),
    g2_anchor("group", "facet", "Criterion", "C2", group = "G", value = 0.1)
  )
  applied <- .mfrmr_research$mfrmr_apply_typed_anchors(config, anchors)$config
  spec <- applied$facet_specs$Criterion
  expanded <- mfrmr:::expand_facet_with_constraints(numeric(0), spec)

  expect_equal(spec$n_params, 0L)
  expect_equal(expanded[c("C1", "C2")], c(C1 = 0.2, C2 = 0), tolerance = 0)
  expect_equal(mean(expanded[c("C1", "C2")]), 0.1, tolerance = 0)

  group_only <- g2_bind_anchors(
    g2_anchor("group", "facet", "Criterion", "C1", group = "ALL", value = 0.1),
    g2_anchor("group", "facet", "Criterion", "C2", group = "ALL", value = 0.1),
    g2_anchor("group", "facet", "Criterion", "C3", group = "ALL", value = 0.1)
  )
  group_config <- .mfrmr_research$mfrmr_apply_typed_anchors(config, group_only)$config
  group_jacobian <- mfrmr:::mfrmr_constraint_jacobian_sparse(
    group_config$facet_specs$Criterion, "Criterion"
  )$jacobian
  expect_identical(dim(group_jacobian), c(3L, 2L))
  expect_identical(as.integer(Matrix::rankMatrix(group_jacobian)), 2L)

  inconsistent <- g2_bind_anchors(
    g2_anchor("direct", "facet", "Criterion", "C1", value = 0.4),
    g2_anchor("direct", "facet", "Criterion", "C2", value = 0.4),
    g2_anchor("group", "facet", "Criterion", "C1", group = "G", value = 0.1),
    g2_anchor("group", "facet", "Criterion", "C2", group = "G", value = 0.1)
  )
  expect_identical(
    g2_capture_error(.mfrmr_research$mfrmr_apply_typed_anchors(
      config, inconsistent
    ))$code,
    "ANCHOR_CONSTRAINT_INCOMPATIBLE"
  )
})

test_that("missing-category audit distinguishes fixed and free transitions", {
  config <- g2_mock_config("PCM")
  anchors <- g2_bind_anchors(
    g2_anchor("owned_step", "owned_step", "Criterion", "C1", "1", value = -0.4),
    g2_anchor("owned_step", "owned_step", "Criterion", "C1", "2", value = 0.1),
    g2_anchor("owned_step", "owned_step", "Criterion", "C1", "3", value = 0.3)
  )
  applied <- .mfrmr_research$mfrmr_apply_typed_anchors(config, anchors)$config
  prep <- list(
    rating_min = 0L,
    rating_max = 3L,
    facet_names = config$facet_names,
    levels = config$facet_levels,
    data = data.frame(
      Score = c(0L, 1L, 3L, 0L, 2L, 3L, 0L, 1L, 2L, 3L),
      Weight = 1,
      Rater = rep(c("R1", "R2"), 5L),
      Criterion = c(rep("C1", 3L), rep("C2", 3L), rep("C3", 4L)),
      stringsAsFactors = FALSE
    )
  )
  audit <- mfrmr:::audit_mfrm_category_support(
    prep, applied, mfrmr:::build_param_sizes(applied)
  )
  c1 <- audit$step_status[audit$step_status$StepScope == "Criterion=C1", ]

  expect_true(all(c1$Fixed))
  expect_true(all(c1$ParameterStatus == "fixed"))
  expect_true(all(c1$ConstraintRole == "fixed_anchor"))
  expect_identical(
    audit$support$FixedStepCount[audit$support$StepScope == "Criterion=C1"],
    3L
  )
  expect_identical(
    audit$support$FreeStepCount[audit$support$StepScope == "Criterion=C1"],
    0L
  )
})

test_that("reversed external score map does not relabel internal transitions", {
  ordinary <- g2_mock_config("RSM", reversed = FALSE)
  reversed <- g2_mock_config("RSM", reversed = TRUE)
  anchor <- g2_anchor(
    "shared_step", "shared_step", step = "1", value = -0.2
  )
  ordinary_applied <- .mfrmr_research$mfrmr_apply_typed_anchors(ordinary, anchor)$config
  reversed_applied <- .mfrmr_research$mfrmr_apply_typed_anchors(reversed, anchor)$config

  expect_identical(ordinary_applied$step_specs, reversed_applied$step_specs)
  expect_equal(
    mfrmr:::expand_step_constraint(c(0.1), ordinary_applied$step_specs$shared),
    mfrmr:::expand_step_constraint(c(0.1), reversed_applied$step_specs$shared),
    tolerance = 0
  )
  expect_identical(reversed$score_map$OriginalScore, 3:0)
  expect_identical(reversed$score_map$InternalScore, 0:3)
})

test_that("anchored reparameterization preserves likelihood and artifact semantics", {
  data <- load_mfrmr_data("example_core")
  persons <- unique(data$Person)[seq_len(18L)]
  data <- data[data$Person %in% persons, , drop = FALSE]
  fit <- suppressWarnings(fit_mfrm(
    data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "MML",
    model = "RSM",
    quad_points = 5,
    maxit = 15
  ))
  old_sizes <- mfrmr:::build_param_sizes(fit$config)
  old_params <- mfrmr:::expand_params(fit$opt$par, old_sizes, fit$config)
  anchor <- g2_anchor(
    "shared_step", "shared_step", step = "2", value = old_params$steps[2]
  )
  applied <- .mfrmr_research$mfrmr_apply_typed_anchors(fit$config, anchor)$config
  new_par <- mfrmr:::collapse_expanded_params(old_params, applied)
  new_sizes <- mfrmr:::build_param_sizes(applied)
  reconstructed <- mfrmr:::expand_params(new_par, new_sizes, applied)

  expect_equal(reconstructed$facets, old_params$facets, tolerance = 0)
  expect_equal(reconstructed$steps, old_params$steps, tolerance = 1e-12)
  expect_identical(new_sizes$steps, old_sizes$steps - 1L)
  idx <- mfrmr:::build_indices(
    fit$prep,
    step_facet = fit$config$step_facet,
    slope_facet = fit$config$slope_facet,
    interaction_specs = fit$config$interaction_specs
  )
  quad <- mfrmr:::gauss_hermite_normal(5L)
  old_objective <- mfrmr:::mfrm_loglik_mml(
    fit$opt$par, idx, fit$config, old_sizes, quad
  )
  new_objective <- mfrmr:::mfrm_loglik_mml(
    new_par, idx, applied, new_sizes, quad
  )
  expect_equal(new_objective, old_objective, tolerance = 1e-12)

  anchored_fit <- fit
  anchored_fit$config <- applied
  anchored_fit$opt$par <- new_par
  draft <- mfrmr:::mfrmr_extract_calibration_draft(
    anchored_fit,
    calibration_id = "g2-partial-rsm",
    source_fit_id = "g2-source-rsm",
    created_at_utc = "2026-08-22T03:00:00Z"
  )
  expect_identical(nrow(mfrmr:::mfrmr_review_calibration(draft)), 0L)
  expect_identical(draft$constraints$anchors$AnchorType, "shared_step")
  expect_equal(draft$constraints$anchors$Value, old_params$steps[2],
               tolerance = 0)
  step_identification <- draft$constraints$identification[
    draft$constraints$identification$ParameterClass == "shared_step",
    , drop = FALSE
  ]
  expect_identical(step_identification$ConstraintType,
                   "sum_to_zero_with_fixed_anchors")
  expect_identical(step_identification$FreeDimension, 1L)

  mismatch <- draft
  mismatch$constraints$anchors$Value <-
    mismatch$constraints$anchors$Value + 0.01
  expect_true("ANCHOR_COORDINATE_MISMATCH" %in%
                mfrmr:::mfrmr_review_calibration(mismatch)$Code)
})

test_that("independent explicit step Jacobians reproduce RSM and PCM ranks", {
  rsm <- g4_mock_config("RSM")
  rsm_anchor <- g4_anchor("RSM", step = 2L, value = 0.2, order = 1L)
  rsm_applied <- .mfrmr_research$mfrmr_apply_typed_anchors(rsm, rsm_anchor)$config
  rsm_actual <- as.matrix(mfrmr:::mfrmr_step_jacobian_sparse(
    rsm_applied, mfrmr:::build_param_sizes(rsm_applied)
  )$jacobian)
  rsm_oracle <- matrix(c(
    1, 0,
    0, 0,
    0, 1,
    -1, -1
  ), nrow = 4L, byrow = TRUE)
  expect_equal(unname(rsm_actual), rsm_oracle, tolerance = 0)
  expect_identical(qr(rsm_oracle)$rank, 2L)

  pcm <- g4_mock_config("PCM")
  pcm_anchors <- rbind(
    g4_anchor("PCM", "C1", 2L, 0.2, 1L),
    g4_anchor("PCM", "C2", 1L, -0.3, 2L),
    g4_anchor("PCM", "C2", 4L, 0.1, 3L)
  )
  pcm_applied <- .mfrmr_research$mfrmr_apply_typed_anchors(pcm, pcm_anchors)$config
  pcm_actual <- as.matrix(mfrmr:::mfrmr_step_jacobian_sparse(
    pcm_applied, mfrmr:::build_param_sizes(pcm_applied)
  )$jacobian)
  block <- function(rows) {
    out <- matrix(0, nrow = rows, ncol = rows - 1L)
    if (ncol(out) > 0L) {
      out[seq_len(ncol(out)), ] <- diag(ncol(out))
      out[rows, ] <- -1
    }
    out
  }
  c1 <- rbind(c(1, 0), c(0, 0), c(0, 1), c(-1, -1))
  c2 <- matrix(c(0, 1, -1, 0), ncol = 1L)
  c3 <- block(4L)
  pcm_oracle <- matrix(0, nrow = 12L, ncol = 6L)
  pcm_oracle[1:4, 1:2] <- c1
  pcm_oracle[5:8, 3] <- c2[, 1]
  pcm_oracle[9:12, 4:6] <- c3
  expect_equal(unname(pcm_actual), pcm_oracle, tolerance = 0)
  expect_identical(qr(pcm_oracle)$rank, 6L)
})
