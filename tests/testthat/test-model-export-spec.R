spec_export_small_data <- function() {
  d <- load_mfrmr_data("example_core")
  d[d$Person %in% unique(d$Person)[1:10], , drop = FALSE]
}

test_that("direct data + spec export matches fit export for RSM and PCM without running MML", {
  d <- spec_export_small_data()
  for (model in c("RSM", "PCM")) {
    step_facet <- if (model == "PCM") "Criterion" else NULL
    fit <- suppressWarnings(fit_mfrm(
      d, "Person", c("Rater", "Criterion"), "Score",
      model = model, method = "MML", step_facet = step_facet,
      positive_facets = "Criterion", noncenter_facet = "Rater",
      repeated_ratings = "independent", quad_points = 9, maxit = 40
    ))
    spec <- list(
      person = "Person",
      facets = c("Rater", "Criterion"),
      score = "Score",
      model = model,
      step_facet = step_facet,
      positive_facets = "Criterion",
      noncenter_facet = "Rater",
      repeated_ratings = "independent"
    )
    for (format in c("stan", "brms")) {
      dir_fit <- tempfile("fit-exp-")
      dir_spec <- tempfile("spec-exp-")
      dir_pos <- tempfile("pos-exp-")
      on.exit(unlink(c(dir_fit, dir_spec, dir_pos), recursive = TRUE), add = TRUE)

      out_fit <- export_mfrm_model(
        fit, dir_fit, format = format,
        location_prior_sd = 1.4, step_prior_sd = 0.8,
        acknowledge_sensitive = TRUE
      )
      out_spec <- with_mocked_bindings(
        export_mfrm_model(
          output_dir = dir_spec, format = format,
          location_prior_sd = 1.4, step_prior_sd = 0.8,
          acknowledge_sensitive = TRUE,
          data = d, spec = spec
        ),
        fit_mfrm = function(...) stop("fit_mfrm must not be called"),
        mfrm_estimate = function(...) stop("mfrm_estimate must not be called")
      )
      out_pos <- export_mfrm_model(
        d, dir_pos, format = format,
        location_prior_sd = 1.4, step_prior_sd = 0.8,
        acknowledge_sensitive = TRUE, spec = spec
      )

      expect_identical(names(out_spec$files), names(out_fit$files))
      expect_identical(names(out_pos$files), names(out_fit$files))
      for (fn in setdiff(names(out_fit$files), "model-data.rds")) {
        expect_identical(
          unname(tools::md5sum(out_spec$files[[fn]])),
          unname(tools::md5sum(out_fit$files[[fn]]))
        )
      }

      b_fit <- readRDS(out_fit$files[["model-data.rds"]])
      b_spec <- readRDS(out_spec$files[["model-data.rds"]])
      b_pos <- readRDS(out_pos$files[["model-data.rds"]])
      expect_identical(b_fit$source_method, "MML")
      expect_identical(b_spec$source_method, "specification")
      expect_identical(b_pos, b_spec)
      shared <- setdiff(names(b_fit), "source_method")
      expect_identical(b_spec[shared], b_fit[shared])

      s <- b_spec$stan_data
      sizes <- mfrmr:::build_param_sizes(fit$config)
      par <- seq(-0.6, 0.7, length.out = sum(unlist(sizes)))
      params <- mfrmr:::expand_params(par, sizes, fit$config)
      locations <- unlist(params$facets, use.names = FALSE)
      free <- drop(crossprod(s$location_basis, locations))
      steps <- if (model == "RSM") matrix(params$steps, 1L) else params$steps_mat
      theta <- seq(-1.8, 1.8, length.out = s$J)
      eta <- theta[s$person] + drop(s$X %*% free)
      logits <- outer(eta, 0:(s$C - 1L)) -
        t(apply(cbind(0, steps[s$owner, , drop = FALSE]), 1L, cumsum))
      probs <- exp(logits - apply(logits, 1L, max))
      probs <- probs / rowSums(probs)
      idx <- mfrmr:::build_indices(fit$prep, step_facet = fit$config$step_facet)
      native_eta <- mfrmr:::compute_eta(idx, params, fit$config, theta_override = theta)
      native <- mfrmr:::compute_response_probability_bundle(fit$config, idx, params, native_eta)
      expect_equal(unname(probs), unname(native$probs), tolerance = 1e-12)
    }
  }
})

test_that("one-family GPCM spec export matches fit export for estimated and fixed populations and anchors", {
  d <- spec_export_small_data()
  raters <- sort(unique(as.character(d$Rater)))
  criteria <- sort(unique(as.character(d$Criterion)))
  anchors <- data.frame(Facet = "Rater", Level = raters[1], Anchor = 0.35)
  groups <- if (length(criteria) >= 3L) {
    data.frame(
      Facet = "Criterion",
      Level = criteria[1:2],
      Group = c("G1", "G1"),
      GroupValue = c(-0.2, -0.2)
    )
  } else {
    NULL
  }

  # 1. Default estimated population (Stan supported; brms rejected before creating output_dir)
  fit_free <- suppressWarnings(fit_mfrm(
    d, "Person", c("Rater", "Criterion"), "Score",
    model = "GPCM", method = "MML",
    step_facet = "Criterion", slope_facet = "Criterion",
    anchors = anchors, group_anchors = groups,
    anchor_policy = "error", repeated_ratings = "independent",
    quad_points = 9, maxit = 35
  ))
  spec_free <- list(
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    anchors = anchors,
    group_anchors = groups,
    repeated_ratings = "independent"
  )
  dir_fit_free <- tempfile("gpcm-fit-free-")
  dir_spec_free <- tempfile("gpcm-spec-free-")
  dir_bad_brms <- tempfile("gpcm-spec-brms-")
  on.exit(unlink(c(dir_fit_free, dir_spec_free, dir_bad_brms), recursive = TRUE), add = TRUE)

  export_mfrm_model(fit_free, dir_fit_free, "stan",
                    log_slope_prior_sd = 0.55,
                    population_prior = list(mean = c(0.2, 0.9), log_sd = c(-0.1, 0.4)),
                    acknowledge_sensitive = TRUE)
  export_mfrm_model(output_dir = dir_spec_free, format = "stan",
                    log_slope_prior_sd = 0.55,
                    population_prior = list(mean = c(0.2, 0.9), log_sd = c(-0.1, 0.4)),
                    acknowledge_sensitive = TRUE,
                    data = d, spec = spec_free)

  b_fit_free <- readRDS(file.path(dir_fit_free, "model-data.rds"))
  b_spec_free <- readRDS(file.path(dir_spec_free, "model-data.rds"))
  shared_free <- setdiff(names(b_fit_free), "source_method")
  expect_identical(b_spec_free[shared_free], b_fit_free[shared_free])
  expect_identical(b_spec_free$schema_version, 2L)
  expect_identical(b_spec_free$population$mode, "estimated_normal")

  expect_error(
    export_mfrm_model(output_dir = dir_bad_brms, format = "brms",
                      acknowledge_sensitive = TRUE, data = d, spec = spec_free),
    "supports format = 'stan' only"
  )
  expect_false(dir.exists(dir_bad_brms))

  # 2. Fixed standard-normal population with separate step/slope owners and both centering scopes
  for (scope in c("facet", "remainder")) {
    fit_fixed <- suppressWarnings(fit_mfrm(
      d, "Person", c("Rater", "Criterion"), "Score",
      model = "GPCM", method = "MML",
      step_facet = "Criterion", slope_facet = "Rater",
      gpcm_mml_identification = "fixed_standard_normal",
      anchors = anchors, group_anchors = groups,
      centering_scope = scope, positive_facets = "Criterion",
      anchor_policy = "error", repeated_ratings = "independent",
      quad_points = 9, maxit = 35
    ))
    spec_fixed <- list(
      person = "Person",
      facets = c("Rater", "Criterion"),
      score = "Score",
      model = "GPCM",
      step_facet = "Criterion",
      slope_facet = "Rater",
      gpcm_mml_identification = "fixed_standard_normal",
      anchors = anchors,
      group_anchors = groups,
      centering_scope = scope,
      positive_facets = "Criterion",
      repeated_ratings = "independent"
    )
    for (format in c("stan", "brms")) {
      dir_f <- tempfile("gpcm-f-")
      dir_s <- tempfile("gpcm-s-")
      on.exit(unlink(c(dir_f, dir_s), recursive = TRUE), add = TRUE)
      export_mfrm_model(fit_fixed, dir_f, format, log_slope_prior_sd = 0.45,
                        acknowledge_sensitive = TRUE)
      export_mfrm_model(output_dir = dir_s, format = format, log_slope_prior_sd = 0.45,
                        acknowledge_sensitive = TRUE, data = d, spec = spec_fixed)
      bf <- readRDS(file.path(dir_f, "model-data.rds"))
      bs <- readRDS(file.path(dir_s, "model-data.rds"))
      expect_identical(bs[setdiff(names(bf), "source_method")],
                       bf[setdiff(names(bf), "source_method")])
    }
  }
})

test_that("category collapse vs preserve, permutations, missing_codes, and UTF-8 labels behave consistently", {
  d <- spec_export_small_data()
  # Map scores to 10, 20, 50 (unobserved interior scores 30, 40)
  d_gap <- d
  u_scores <- sort(unique(d_gap$Score))
  map_scores <- c(10L, 20L, 50L, 50L, 50L)[seq_along(u_scores)]
  d_gap$Score <- map_scores[match(d_gap$Score, u_scores)]

  dir_collapse <- tempfile("cat-collapse-")
  dir_preserve <- tempfile("cat-preserve-")
  on.exit(unlink(c(dir_collapse, dir_preserve), recursive = TRUE), add = TRUE)

  expect_warning(
    export_mfrm_model(
      output_dir = dir_collapse, format = "stan", acknowledge_sensitive = TRUE,
      data = d_gap,
      spec = list(
        person = "Person", facets = c("Rater", "Criterion"), score = "Score",
        model = "RSM", category_policy = "collapse", repeated_ratings = "independent"
      )
    ),
    "non-consecutive"
  )
  b_col <- readRDS(file.path(dir_collapse, "model-data.rds"))
  expect_identical(b_col$categories$Score, c(10L, 20L, 50L))
  expect_identical(b_col$stan_data$C, 3L)

  expect_error(
    export_mfrm_model(
      output_dir = dir_preserve, format = "stan", acknowledge_sensitive = TRUE,
      data = d_gap,
      spec = list(
        person = "Person", facets = c("Rater", "Criterion"), score = "Score",
        model = "RSM", category_policy = "preserve", repeated_ratings = "independent"
      )
    )
  )
  expect_false(dir.exists(dir_preserve))

  # UTF-8 labels + permuted rows + unused factor levels + missing/sentinel rows under default GPCM
  d_utf <- d
  p_old <- sort(unique(as.character(d_utf$Person)))
  r_old <- sort(unique(as.character(d_utf$Rater)))
  c_old <- sort(unique(as.character(d_utf$Criterion)))
  p_new <- sprintf("受験者_%02d_é", seq_along(p_old))
  r_new <- paste0("評価者_", seq_along(r_old))
  c_new <- paste0("基準_", seq_along(c_old))
  d_utf$Person <- p_new[match(as.character(d_utf$Person), p_old)]
  d_utf$Rater <- r_new[match(as.character(d_utf$Rater), r_old)]
  d_utf$Criterion <- c_new[match(as.character(d_utf$Criterion), c_old)]
  names(d_utf)[match(c("Person", "Rater", "Criterion", "Score"), names(d_utf))] <-
    c("受験者列", "評定者列", "基準列", "得点列")

  # Add omitted rows: one Person whose only row has Score = NA, and a sentinel missing code row
  extra_rows <- d_utf[1:2, , drop = FALSE]
  extra_rows[["受験者列"]] <- c("欠測のみ受験者", "番兵除外受験者")
  extra_rows[["得点列"]] <- as.character(d_utf[["得点列"]][1:2])
  d_utf_aug <- d_utf
  d_utf_aug[["得点列"]] <- as.character(d_utf_aug[["得点列"]])
  extra_rows[["得点列"]][1] <- NA_character_
  extra_rows[["得点列"]][2] <- "999"
  d_utf_aug <- rbind(d_utf_aug, extra_rows)

  withr::local_seed(1030)
  perm <- sample(nrow(d_utf_aug))
  d_utf_perm <- d_utf_aug[perm, , drop = FALSE]
  d_utf_perm[["評定者列"]] <- factor(d_utf_perm[["評定者列"]], levels = c("未使用水準", rev(r_new)))

  spec_utf <- list(
    person = "受験者列",
    facets = c("評定者列", "基準列"),
    score = "得点列",
    model = "GPCM",
    step_facet = "基準列",
    slope_facet = "基準列",
    missing_codes = "999",
    repeated_ratings = "independent"
  )
  dir_u1 <- tempfile("utf1-")
  dir_u2 <- tempfile("utf2-")
  on.exit(unlink(c(dir_u1, dir_u2), recursive = TRUE), add = TRUE)
  export_mfrm_model(output_dir = dir_u1, acknowledge_sensitive = TRUE,
                    data = d_utf_aug, spec = spec_utf)
  export_mfrm_model(output_dir = dir_u2, acknowledge_sensitive = TRUE,
                    data = d_utf_perm, spec = spec_utf)

  b1 <- readRDS(file.path(dir_u1, "model-data.rds"))
  b2 <- readRDS(file.path(dir_u2, "model-data.rds"))
  expect_identical(b1$levels, b2$levels)
  expect_identical(b1$slope_levels, b2$slope_levels)
  expect_identical(b1$step_levels, b2$step_levels)
  expect_identical(b1$population, b2$population)
  expect_false("欠測のみ受験者" %in% b1$population$person_levels)
  expect_false("未使用水準" %in% b2$levels$Level)

  levels_csv <- utils::read.csv(file.path(dir_u2, "levels.csv"), fileEncoding = "UTF-8")
  expect_identical(levels_csv$Level, b2$levels$Level)

  # Total log-likelihood invariance under arbitrary parameter vector
  s1 <- b1$stan_data
  s2 <- b2$stan_data
  theta <- seq(-1.2, 1.2, length.out = s1$J)
  loc_free <- seq(-0.4, 0.4, length.out = s1$P)
  step_free <- seq(-0.3, 0.3, length.out = s1$T)
  slope_free <- seq(-0.2, 0.2, length.out = s1$S)
  ll_eval <- function(s) {
    steps <- matrix(as.vector(s$step_offset) + drop(s$step_basis %*% step_free),
                    nrow = s$G, ncol = s$C - 1L, byrow = TRUE)
    a <- exp(drop(s$slope_X %*% slope_free))
    eta <- theta[s$person] + as.vector(s$eta_offset) + drop(s$X %*% loc_free)
    logits <- (outer(eta, 0:(s$C - 1L)) -
      t(apply(cbind(0, steps[s$owner, , drop = FALSE]), 1L, cumsum))) * a
    lse <- apply(logits, 1L, function(r) { m <- max(r); m + log(sum(exp(r - m))) })
    sum(logits[cbind(seq_len(s$N), as.integer(s$y))] - lse)
  }
  expect_equal(ll_eval(s1), ll_eval(s2), tolerance = 1e-12)
})

test_that("fixed anchors, constraint-determined values, and zero-dimensional bases work via spec", {
  # Binary ladder (C = 2 -> T = 0), singleton slope/step owner (S = 0), and anchored 2-level facet
  d_bin <- data.frame(
    Person = rep(paste0("P", 1:6), each = 2L),
    Rater = rep(c("R1", "R2"), times = 6L),
    Item = "SingleItem",
    Score = c(0L, 1L, 1L, 0L, 1L, 1L, 0L, 0L, 1L, 0L, 0L, 1L)
  )
  dir_bin <- tempfile("bin-spec-")
  on.exit(unlink(dir_bin, recursive = TRUE), add = TRUE)

  expect_warning(
    export_mfrm_model(
      output_dir = dir_bin, format = "stan", acknowledge_sensitive = TRUE,
      write_json = TRUE, data = d_bin,
      spec = list(
        person = "Person",
        facets = c("Rater", "Item"),
        score = "Score",
        model = "GPCM",
        step_facet = "Item",
        slope_facet = "Item",
        gpcm_mml_identification = "fixed_standard_normal",
        anchors = data.frame(Facet = "Rater", Level = "R1", Anchor = 0.5),
        centering_scope = "facet",
        repeated_ratings = "independent"
      )
    ),
    "single-level facet"
  )
  b <- readRDS(file.path(dir_bin, "model-data.rds"))
  expect_identical(b$stan_data$P, 0L)
  expect_identical(b$stan_data$T, 0L)
  expect_identical(b$stan_data$S, 0L)
  expect_identical(b$stan_data$A, 1L)

  env <- new.env(parent = globalenv())
  sys.source(system.file("model-export", "summarize.R", package = "mfrmr"), env)
  map <- env$mfrm_parameter_map(b)
  expect_identical(map$value_role[map$facet == "Rater" & map$level == "R1"], "fixed_anchor")
  expect_equal(map$fixed_value[map$facet == "Rater" & map$level == "R1"], 0.5)
  # R2 is determined by whole-facet sum-to-zero (-0.5), not a direct anchor
  expect_identical(map$value_role[map$facet == "Rater" & map$level == "R2"], "fixed_by_constraint")
  expect_equal(map$fixed_value[map$facet == "Rater" & map$level == "R2"], -0.5)
  expect_identical(map$value_role[map$facet == "Item" & map$quantity == "location"], "fixed_by_constraint")
  expect_identical(map$value_role[map$quantity == "slope"], "fixed_by_constraint")
  expect_equal(map$fixed_value[map$quantity == "slope"], 1)
  expect_identical(map$value_role[map$quantity == "step_offset"], "fixed_by_constraint")
  expect_equal(map$fixed_value[map$quantity == "step_offset"], 0)
})

test_that("unsupported spec settings and malformed inputs fail closed before creating output_dir", {
  d <- spec_export_small_data()
  d$W <- 2
  base <- list(
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    repeated_ratings = "independent"
  )

  bad_specs <- list(
    modifyList(base, list(method = "JML")),
    modifyList(base, list(method = "CML")),
    modifyList(base, list(population_formula = ~ 1)),
    modifyList(base, list(population_sd = 1.2)),
    modifyList(base, list(facet_interactions = list(c("Rater", "Criterion")))),
    modifyList(base, list(dummy_facets = "Rater")),
    modifyList(base, list(facet_shrinkage = "empirical_bayes")),
    modifyList(base, list(weight = "W")),
    modifyList(base, list(anchors = data.frame(Facet = "Person", Level = as.character(d$Person[1]), Anchor = 0))),
    modifyList(base, list(anchors = data.frame(Facet = "Rater", Level = NA_character_, Anchor = 0))),
    modifyList(base, list(anchors = data.frame(Facet = "Rater", Level = "UNKNOWN_LEVEL", Anchor = 0))),
    modifyList(base, list(anchors = data.frame(Facet = "Rater", Value = 0))),
    modifyList(base, list(anchors = c(R1 = 0))),
    modifyList(base, list(group_anchors = data.frame(Facet = "Rater", Level = as.character(d$Rater[1]), Group = "", GroupValue = 0))),
    modifyList(base, list(model = "RSM", step_facet = "Criterion")),
    modifyList(base, list(model = "RSM", slope_facet = "Criterion")),
    modifyList(base, list(model = "PCM", step_facet = "Criterion", slope_facet = "Criterion")),
    modifyList(base, list(model = "RSM", gpcm_mml_identification = "free_population")),
    modifyList(base, list(model = "GPCM")),
    modifyList(base, list(model = "GPCM", step_facet = "Criterion", slope_facet = c("Rater", "Criterion"))),
    modifyList(base, list(model = "GPCM", step_facet = "Criterion", noncenter_facet = "Rater")),
    modifyList(base, list(centering_scope = "anchor_origin")),
    modifyList(base, list(noncenter_facet = "NotAFacet")),
    modifyList(base, list(positive_facets = "NotAFacet")),
    modifyList(base, list(quad_points = 15)),
    modifyList(base, list(unknown_option = TRUE))
  )

  for (s in bad_specs) {
    target <- tempfile("fail-closed-")
    expect_error(export_mfrm_model(output_dir = target, acknowledge_sensitive = TRUE,
                                   data = d, spec = s))
    expect_false(file.exists(target))
    expect_false(dir.exists(target))
  }

  # Input routing & write_json guards
  fit_rsm <- suppressWarnings(fit_mfrm(
    d, "Person", c("Rater", "Criterion"), "Score",
    model = "RSM", method = "MML", quad_points = 7, maxit = 20
  ))
  for (call_fn in list(
    function(p) export_mfrm_model(fit = fit_rsm, output_dir = p, data = d, spec = base),
    function(p) export_mfrm_model(output_dir = p, data = d),
    function(p) export_mfrm_model(output_dir = p, spec = base),
    function(p) export_mfrm_model(output_dir = p),
    function(p) export_mfrm_model(output_dir = p, format = "brms", write_json = TRUE, data = d, spec = base),
    function(p) export_mfrm_model(output_dir = p, format = "stan", write_json = NA, data = d, spec = base)
  )) {
    target <- tempfile("guard-closed-")
    expect_error(call_fn(target))
    expect_false(dir.exists(target))
  }
})

test_that("write_json produces CmdStanR-compatible JSON matching write_stan_json and preserves RDS/CSV", {
  skip_if_not_installed("jsonlite")
  d <- spec_export_small_data()
  cases <- list(
    list(model = "RSM"),
    list(model = "GPCM", step_facet = "Criterion", slope_facet = "Criterion")
  )
  for (cs in cases) {
    spec <- c(list(person = "Person", facets = c("Rater", "Criterion"),
                   score = "Score", repeated_ratings = "independent"), cs)
    dir_j <- tempfile("json-bundle-")
    on.exit(unlink(dir_j, recursive = TRUE), add = TRUE)
    out <- export_mfrm_model(
      output_dir = dir_j, format = "stan", write_json = TRUE,
      acknowledge_sensitive = TRUE, data = d, spec = spec
    )
    expect_true("model-data.json" %in% names(out$files))
    expect_true(all(c("model-data.rds", "levels.csv", "categories.csv") %in% names(out$files)))
    expect_true(all(file.exists(out$files)))
    expect_error(
      export_mfrm_model(output_dir = dir_j, format = "stan", write_json = TRUE,
                        acknowledge_sensitive = TRUE, data = d, spec = spec),
      "already exist"
    )

    bundle <- readRDS(out$files[["model-data.rds"]])
    parsed <- jsonlite::fromJSON(out$files[["model-data.json"]], simplifyVector = FALSE)
    expect_identical(names(parsed), names(bundle$stan_data))

    if (requireNamespace("cmdstanr", quietly = TRUE)) {
      ref_file <- tempfile(fileext = ".json")
      on.exit(unlink(ref_file), add = TRUE)
      cmdstanr::write_stan_json(bundle$stan_data, ref_file)
      ref_parsed <- jsonlite::fromJSON(ref_file, simplifyVector = FALSE)
      expect_equal(parsed, ref_parsed, tolerance = 1e-14)
    }

    # Check bit-exact IEEE-754 fidelity on basis matrices
    reconstructed_B <- matrix(
      unlist(lapply(parsed$location_basis, unlist), use.names = FALSE),
      nrow = bundle$stan_data$L, ncol = bundle$stan_data$P, byrow = TRUE
    )
    expect_equal(reconstructed_B, unname(bundle$stan_data$location_basis), tolerance = 0)
  }

  # Edge-case shapes against cmdstanr::write_stan_json (0-len array, 1-len array, Nx0 and 0xN matrices)
  edge <- list(
    n = 3L,
    s = sqrt(2),
    empty_arr = array(numeric(0)),
    unit_arr = array(1.25),
    mat_3x0 = matrix(0, 3, 0),
    mat_0x3 = matrix(0, 0, 3),
    mat_0x0 = matrix(0, 0, 0),
    mat_1x2 = matrix(c(1.5, -2.5), 1, 2)
  )
  f_own <- tempfile(fileext = ".json")
  on.exit(unlink(f_own), add = TRUE)
  mfrmr:::mfrm_write_stan_json(edge, f_own)
  p_own <- jsonlite::fromJSON(f_own, simplifyVector = FALSE)
  expect_identical(p_own$n, 3L)
  expect_equal(p_own$s, sqrt(2), tolerance = 0)
  expect_identical(p_own$empty_arr, list())
  expect_identical(p_own$unit_arr, list(1.25))
  expect_identical(p_own$mat_3x0, list(list(), list(), list()))
  expect_identical(p_own$mat_0x3, list())
  expect_identical(p_own$mat_0x0, list())
  expect_identical(p_own$mat_1x2, list(list(1.5, -2.5)))
  if (requireNamespace("cmdstanr", quietly = TRUE)) {
    f_cmd <- tempfile(fileext = ".json")
    on.exit(unlink(f_cmd), add = TRUE)
    cmdstanr::write_stan_json(edge, f_cmd)
    expect_equal(p_own, jsonlite::fromJSON(f_cmd, simplifyVector = FALSE), tolerance = 1e-14)
  }
})

test_that("moved spec-exported bundle roundtrips through summarize.R and read_mfrm_posterior in a fresh R session", {
  skip_if_not_installed("posterior")
  withr::local_seed(20261030)
  d <- spec_export_small_data()
  anchor <- data.frame(Facet = "Rater", Level = as.character(d$Rater[1]), Anchor = 0)
  orig_dir <- tempfile("spec-orig-")
  moved_dir <- tempfile("spec-moved-")
  on.exit(unlink(c(orig_dir, moved_dir), recursive = TRUE), add = TRUE)

  export_mfrm_model(
    output_dir = orig_dir, format = "stan", write_json = TRUE,
    acknowledge_sensitive = TRUE, data = d,
    spec = list(
      person = "Person", facets = c("Rater", "Criterion"), score = "Score",
      model = "GPCM", step_facet = "Criterion", slope_facet = "Criterion",
      anchors = anchor, repeated_ratings = "independent"
    )
  )
  expect_true(file.rename(orig_dir, moved_dir))
  expect_false(dir.exists(orig_dir))

  bundle <- readRDS(file.path(moved_dir, "model-data.rds"))
  env <- new.env(parent = globalenv())
  sys.source(file.path(moved_dir, "summarize.R"), env)
  map <- env$mfrm_parameter_map(bundle)
  vars <- c(map$variable, "population_log_sd", "theta_raw[1]")
  draws <- array(
    stats::rnorm(160L * 4L * length(vars), sd = 0.25),
    c(160L, 4L, length(vars)),
    dimnames = list(NULL, NULL, vars)
  )
  for (i in which(map$quantity %in% c("slope", "population_sd"))) {
    draws[, , i] <- exp(draws[, , i])
  }
  for (i in which(!is.na(map$fixed_value))) {
    draws[, , i] <- map$fixed_value[i]
  }
  sampler <- data.frame(chain = 1:4, num_divergent = 0, num_max_treedepth = 0, ebfmi = 0.85)
  withr::with_dir(moved_dir, env$summarize_mfrm_draws(draws, bundle, sampler, "Stan"))

  post <- read_mfrm_posterior(moved_dir)
  expect_identical(post$source$ExportSourceMethod, "specification")
  expect_identical(post$schema_version, 2L)
  expect_identical(summary(post), post)
  ci <- confint(post)
  expect_true(any(ci$value_role == "fixed_anchor"))
  p_post <- plot(post, quantity = "location", draw = FALSE)
  expect_s3_class(p_post, "ggplot")
  expect_s3_class(attr(p_post, "mfrmr_plot_data"), "mfrm_plot_data")
  rep_obj <- mfrm_report(post)
  expect_identical(rep_obj$tables$source_model$ExportSourceMethod, "specification")
})
