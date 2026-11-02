build_kernel_parity_case <- function(model = c("RSM", "PCM", "GPCM", "GPCM2"),
                                     method = c("MML", "JML"),
                                     weighted = FALSE,
                                     interactions = FALSE,
                                     anchored = FALSE,
                                     pop_cfg = NULL,
                                     mml_integration = "fixed") {
  model <- match.arg(model)
  method <- match.arg(method)
  d <- mfrmr:::sample_mfrm_data(seed = 108)
  d$Group <- ifelse(as.integer(factor(d$Person)) %% 2L == 0L, "G2", "G1")

  if (model == "GPCM2") {
    d2 <- d[d$Criterion == d$Criterion[1L], c("Person", "Task", "Rater", "Score", "Group")]
    d2$Score <- as.integer(d2$Score - min(d2$Score))
    setup <- mfrmr:::mfrm_gmfrm_common_setup(
      d2[, c("Person", "Task", "Rater", "Score")],
      max_score = max(d2$Score),
      slope_facets = c("Task", "Rater")
    )
    prep <- setup$prep
    idx <- setup$idx
    config <- setup$config
    if (weighted) {
      set.seed(109)
      idx$weight <- c(0, stats::runif(length(idx$score_k) - 1L, min = 0.25, max = 2.0))
      config$weight_col <- "Weight"
    }
    if (!is.null(pop_cfg)) {
      person_data <- unique(d2[, c("Person", "Group")])
      pop <- mfrmr:::prepare_mfrm_population_scaffold(
        data = d2,
        person = "Person",
        population_formula = pop_cfg$formula,
        person_data = person_data
      )
      pop <- mfrmr:::annotate_mfrm_population_scaffold(
        population = pop,
        data = d2,
        scaffold_data = d2,
        gpcm_mml_active = TRUE,
        auto_gpcm_population = FALSE,
        population_sd = pop_cfg$fixed_sd
      )
      config$population_spec <- mfrmr:::compact_population_spec(pop, prep$levels$Person)
    }
    config$estimation_control <- list(mml_integration = mml_integration)
    sizes <- mfrmr:::build_param_sizes(config)
  } else {
    if (weighted) {
      set.seed(109)
      d$Weight <- c(0, stats::runif(nrow(d) - 1L, min = 0.25, max = 2.0))
    }
    pop <- NULL
    if (!is.null(pop_cfg)) {
      person_data <- unique(d[, c("Person", "Group")])
      pop <- mfrmr:::prepare_mfrm_population_scaffold(
        data = d,
        person = "Person",
        population_formula = pop_cfg$formula,
        person_data = person_data
      )
      pop <- mfrmr:::annotate_mfrm_population_scaffold(
        population = pop,
        data = d,
        scaffold_data = d,
        gpcm_mml_active = (model == "GPCM" && method == "MML"),
        auto_gpcm_population = FALSE,
        population_sd = pop_cfg$fixed_sd
      )
    }
    prep <- mfrmr:::prepare_mfrm_data(
      d,
      person_col = "Person",
      facet_cols = c("Rater", "Task", "Criterion"),
      score_col = "Score",
      weight_col = if (weighted) "Weight" else NULL,
      keep_original = TRUE
    )
    step_facet <- if (model %in% c("PCM", "GPCM")) "Criterion" else NULL
    slope_facet <- if (model == "GPCM") "Criterion" else NULL
    facet_interactions <- if (interactions && model %in% c("RSM", "PCM")) "Rater:Criterion" else NULL
    interaction_specs <- mfrmr:::build_facet_interaction_specs(
      prep = prep,
      facet_interactions = facet_interactions,
      min_obs_per_interaction = 1L,
      interaction_policy = "silent"
    )
    signs <- mfrmr:::build_facet_signs(prep$facet_names)
    idx <- mfrmr:::build_indices(
      prep,
      step_facet = step_facet,
      slope_facet = slope_facet,
      interaction_specs = interaction_specs
    )
    anchor_df <- if (anchored) {
      data.frame(
        Facet = "Task",
        Level = prep$levels$Task[1L],
        Anchor = 0.15,
        stringsAsFactors = FALSE
      )
    } else {
      NULL
    }
    cfg <- mfrmr:::build_estimation_config(
      prep = prep,
      model = model,
      method = method,
      step_facet = step_facet,
      slope_facet = slope_facet,
      interaction_specs = interaction_specs,
      weight_col = if (weighted) "Weight" else NULL,
      facet_signs = signs$signs,
      positive_facets = signs$positive_facets,
      noncenter_facet = "Person",
      dummy_facets = character(0),
      anchor_df = anchor_df,
      group_anchor_df = NULL,
      population = pop
    )
    config <- cfg$config
    config$estimation_control <- list(mml_integration = mml_integration)
    sizes <- cfg$sizes
  }

  p <- sum(unlist(sizes))
  set.seed(211)
  par <- stats::rnorm(p, mean = 0, sd = 0.22)
  list(
    prep = prep,
    idx = idx,
    config = config,
    sizes = sizes,
    par = par,
    quad = mfrmr:::gauss_hermite_normal(7L)
  )
}

eval_with_backend <- function(use_cpp, expr) {
  old <- options(mfrmr.use_cpp11_backend = use_cpp)
  on.exit(options(old), add = TRUE)
  force(expr)
}

test_that("fused fixed-grid MML and EM kernels match pure-R reference across models and options", {
  skip_if_not(mfrmr:::mfrm_cpp11_backend_available())

  pop_specs <- list(
    none = NULL,
    free_int = list(formula = ~ 1, fixed_sd = NULL),
    free_grp = list(formula = ~ Group, fixed_sd = NULL),
    fixed_grp = list(formula = ~ Group, fixed_sd = 1.25)
  )

  for (model in c("RSM", "PCM", "GPCM", "GPCM2")) {
    for (pop_name in names(pop_specs)) {
      fx <- build_kernel_parity_case(
        model = model,
        method = "MML",
        weighted = TRUE,
        interactions = TRUE,
        anchored = TRUE,
        pop_cfg = pop_specs[[pop_name]]
      )
      label <- paste(model, pop_name)

      val_r <- eval_with_backend(
        FALSE,
        mfrmr:::mfrm_loglik_mml(fx$par, fx$idx, fx$config, fx$sizes, fx$quad)
      )
      val_cpp <- eval_with_backend(
        TRUE,
        mfrmr:::mfrm_loglik_mml(fx$par, fx$idx, fx$config, fx$sizes, fx$quad)
      )
      expect_equal(val_cpp, val_r, tolerance = 1e-13, info = paste("val", label))

      grad_r <- eval_with_backend(
        FALSE,
        mfrmr:::mfrm_grad_mml(fx$par, fx$idx, fx$config, fx$sizes, fx$quad)
      )
      grad_cpp <- eval_with_backend(
        TRUE,
        mfrmr:::mfrm_grad_mml(fx$par, fx$idx, fx$config, fx$sizes, fx$quad)
      )
      expect_equal(grad_cpp, grad_r, tolerance = 1e-13, info = paste("grad", label))

      for (reuse_ws in c(FALSE, TRUE)) {
        run_direct <- function(use_cpp) {
          eval_with_backend(use_cpp, {
            cache <- mfrmr:::make_param_cache(fx$sizes, fx$config, fx$idx, is_mml = TRUE)
            ev <- mfrmr:::make_mfrm_direct_evaluator(
              "MML", cache, fx$idx, fx$config, fx$sizes, fx$quad,
              reuse_probability_workspace = reuse_ws
            )
            v1 <- ev$value(fx$par)
            v2 <- ev$value(fx$par)
            g1 <- ev$gradient(fx$par)
            g2 <- ev$gradient(fx$par)
            p2 <- fx$par + 0.01
            g3 <- ev$gradient(p2)
            v3 <- ev$value(p2)
            list(v = c(v1, v2, v3), g1 = g1, g2 = g2, g3 = g3, diag = ev$diagnostics())
          })
        }
        dr <- run_direct(FALSE)
        dc <- run_direct(TRUE)
        expect_equal(dc$v, dr$v, tolerance = 1e-13, info = paste("direct v", label, reuse_ws))
        expect_equal(dc$g1, dr$g1, tolerance = 1e-13, info = paste("direct g1", label, reuse_ws))
        expect_equal(dc$g2, dr$g2, tolerance = 1e-13, info = paste("direct g2", label, reuse_ws))
        expect_equal(dc$g3, dr$g3, tolerance = 1e-13, info = paste("direct g3", label, reuse_ws))
        expect_identical(dc$diag, dr$diag, info = paste("direct diag", label, reuse_ws))
      }
    }
  }

  for (model in c("RSM", "PCM")) {
    fx <- build_kernel_parity_case(
      model = model,
      method = "MML",
      weighted = TRUE,
      interactions = TRUE,
      anchored = TRUE,
      pop_cfg = NULL
    )
    state <- eval_with_backend(
      FALSE,
      mfrmr:::build_mfrm_mml_em_state(fx$par, fx$idx, fx$config, fx$sizes, fx$quad)
    )
    obs_post <- state$posterior_bundle$obs_posterior
    par_next <- fx$par - 0.03

    for (reuse_ws in c(FALSE, TRUE)) {
      run_em <- function(use_cpp) {
        eval_with_backend(use_cpp, {
          cache <- mfrmr:::make_param_cache(fx$sizes, fx$config, fx$idx, is_mml = TRUE)
          ev <- mfrmr:::make_mfrm_em_mstep_evaluator(
            cache, fx$idx, fx$config, fx$sizes, fx$quad, obs_post,
            reuse_probability_workspace = reuse_ws
          )
          list(v = ev$value(par_next), g = ev$gradient(par_next))
        })
      }
      em_r <- run_em(FALSE)
      em_cpp <- run_em(TRUE)
      expect_equal(em_cpp$v, em_r$v, tolerance = 1e-13, info = paste("EM v", model, reuse_ws))
      expect_equal(em_cpp$g, em_r$g, tolerance = 1e-13, info = paste("EM g", model, reuse_ws))
    }
  }

  fx_gpcm <- build_kernel_parity_case(model = "GPCM", method = "MML")
  state_gpcm <- eval_with_backend(
    FALSE,
    mfrmr:::build_mfrm_mml_em_state(fx_gpcm$par, fx_gpcm$idx, fx_gpcm$config, fx_gpcm$sizes, fx_gpcm$quad)
  )
  for (use_cpp in c(FALSE, TRUE)) {
    expect_error(
      eval_with_backend(use_cpp, {
        cache <- mfrmr:::make_param_cache(fx_gpcm$sizes, fx_gpcm$config, fx_gpcm$idx, is_mml = TRUE)
        ev <- mfrmr:::make_mfrm_em_mstep_evaluator(
          cache, fx_gpcm$idx, fx_gpcm$config, fx_gpcm$sizes, fx_gpcm$quad,
          state_gpcm$posterior_bundle$obs_posterior
        )
        ev$gradient(fx_gpcm$par)
      }),
      "Complete-data EM updates are currently implemented only for RSM/PCM"
    )
  }
})

test_that("adaptive quadrature basis and evaluator match pure-R reference across models", {
  skip_if_not(mfrmr:::mfrm_cpp11_backend_available())

  pop_specs <- list(
    none = NULL,
    free_grp = list(formula = ~ Group, fixed_sd = NULL),
    fixed_grp = list(formula = ~ Group, fixed_sd = 1.2)
  )

  for (model in c("RSM", "PCM", "GPCM", "GPCM2")) {
    for (pop_name in names(pop_specs)) {
      fx <- build_kernel_parity_case(
        model = model,
        method = "MML",
        weighted = TRUE,
        interactions = TRUE,
        anchored = TRUE,
        pop_cfg = pop_specs[[pop_name]],
        mml_integration = "adaptive"
      )
      params <- mfrmr:::expand_params(fx$par, fx$sizes, fx$config)
      base_eta <- mfrmr:::compute_base_eta(fx$idx, params, fx$config)
      label <- paste("adaptive", model, pop_name)

      basis_r <- eval_with_backend(
        FALSE,
        mfrmr:::mfrmr_adaptive_quadrature_basis(fx$idx, fx$config, params, fx$quad, base_eta)
      )
      basis_cpp <- eval_with_backend(
        TRUE,
        mfrmr:::mfrmr_adaptive_quadrature_basis(fx$idx, fx$config, params, fx$quad, base_eta)
      )
      expect_equal(basis_cpp$nodes, basis_r$nodes, tolerance = 1e-11, info = paste("nodes", label))
      expect_equal(basis_cpp$log_weights, basis_r$log_weights, tolerance = 1e-11, info = paste("lw", label))

      for (reuse_pat in c(TRUE, FALSE)) {
        res_r <- eval_with_backend(FALSE, {
          ev <- mfrmr:::mfrmr_make_adaptive_mml_evaluator(
            fx$idx, fx$config, fx$sizes, quad_points = 7L,
            reuse_identical_patterns = reuse_pat,
            include_person_summaries = TRUE
          )
          ev(fx$par)
        })
        res_cpp <- eval_with_backend(TRUE, {
          ev <- mfrmr:::mfrmr_make_adaptive_mml_evaluator(
            fx$idx, fx$config, fx$sizes, quad_points = 7L,
            reuse_identical_patterns = reuse_pat,
            include_person_summaries = TRUE
          )
          ev(fx$par)
        })
        expect_equal(res_cpp$value, res_r$value, tolerance = 1e-12, info = paste("val", label, reuse_pat))
        expect_equal(res_cpp$gradient, res_r$gradient, tolerance = 1e-11, info = paste("grad", label, reuse_pat))
        expect_equal(res_cpp$per_person, res_r$per_person, tolerance = 1e-11, info = paste("sum", label, reuse_pat))
      }
    }
  }
})

test_that("fused JML kernel matches pure-R reference across RSM, PCM, and GPCM", {
  skip_if_not(mfrmr:::mfrm_cpp11_backend_available())

  for (model in c("RSM", "PCM", "GPCM")) {
    fx <- build_kernel_parity_case(
      model = model,
      method = "JML",
      weighted = TRUE,
      interactions = TRUE,
      anchored = TRUE
    )
    val_r <- eval_with_backend(FALSE, mfrmr:::mfrm_loglik_jml(fx$par, fx$idx, fx$config, fx$sizes))
    val_cpp <- eval_with_backend(TRUE, mfrmr:::mfrm_loglik_jml(fx$par, fx$idx, fx$config, fx$sizes))
    expect_equal(val_cpp, val_r, tolerance = 1e-13, info = paste("JML val", model))

    grad_r <- eval_with_backend(FALSE, mfrmr:::mfrm_grad_jml(fx$par, fx$idx, fx$config, fx$sizes))
    grad_cpp <- eval_with_backend(TRUE, mfrmr:::mfrm_grad_jml(fx$par, fx$idx, fx$config, fx$sizes))
    expect_equal(grad_cpp, grad_r, tolerance = 1e-13, info = paste("JML grad", model))

    for (reuse_ws in c(FALSE, TRUE)) {
      run_jml_direct <- function(use_cpp) {
        eval_with_backend(use_cpp, {
          cache <- mfrmr:::make_param_cache(fx$sizes, fx$config, fx$idx, is_mml = FALSE)
          ev <- mfrmr:::make_mfrm_direct_evaluator(
            "JML", cache, fx$idx, fx$config, fx$sizes, quad = NULL,
            reuse_probability_workspace = reuse_ws
          )
          list(v = ev$value(fx$par), g = ev$gradient(fx$par), diag = ev$diagnostics())
        })
      }
      jr <- run_jml_direct(FALSE)
      jc <- run_jml_direct(TRUE)
      expect_equal(jc$v, jr$v, tolerance = 1e-13, info = paste("JML direct v", model, reuse_ws))
      expect_equal(jc$g, jr$g, tolerance = 1e-13, info = paste("JML direct g", model, reuse_ws))
      expect_identical(jc$diag, jr$diag, info = paste("JML direct diag", model, reuse_ws))
    }
  }
})

test_that("CML elementary symmetric function C++ kernel matches pure-R reference", {
  skip_if_not(mfrmr:::mfrm_cpp11_backend_available())

  set.seed(303)
  p <- 8L
  features <- lapply(c(3L, 5L, 4L, 6L, 2L), function(n_cat) {
    matrix(stats::rnorm(n_cat * p, sd = 0.4), nrow = n_cat, ncol = p)
  })
  par <- stats::rnorm(p, sd = 0.35)

  for (info_flag in c(FALSE, TRUE)) {
    esf_r <- mfrmr:::mfrmr_cml_esf_r(features, par, information = info_flag)
    esf_cpp <- eval_with_backend(TRUE, mfrmr:::mfrmr_cml_esf(features, par, information = info_flag))
    expect_equal(esf_cpp$logz, esf_r$logz, tolerance = 1e-13, info = paste("logz", info_flag))
    expect_equal(esf_cpp$means, esf_r$means, tolerance = 1e-13, info = paste("means", info_flag))
    if (info_flag) {
      expect_equal(esf_cpp$covariance, esf_r$covariance, tolerance = 1e-13, info = "covariance")
    } else {
      expect_null(esf_cpp$covariance)
    }
  }

  bad_par <- par
  bad_par[2L] <- NA_real_
  expect_error(
    eval_with_backend(TRUE, mfrmr:::mfrmr_cml_esf(features, bad_par, information = FALSE)),
    "Nonfinite CML category predictors"
  )
})

test_that("hash-indexed make_union_find preserves exact roots, tie-breaking, and long chains", {
  nodes <- c("A:1", "A:2", "B:1", "B:2", "C:1", "C:2", "")
  uf <- mfrmr:::make_union_find(nodes)
  uf$union("A:1", "B:1")
  uf$union("B:1", "C:1")
  expect_identical(uf$find("C:1"), "A:1")
  expect_identical(uf$find("A:2"), "A:2")
  expect_identical(uf$find(""), "")
  expect_identical(uf$find("MISSING"), NA_character_)
  expect_identical(uf$find(NA_character_), NA_character_)

  chain_nodes <- paste0("N", seq_len(6000L))
  uf_chain <- mfrmr:::make_union_find(chain_nodes)
  uf_chain$union_pairs(chain_nodes[-length(chain_nodes)], chain_nodes[-1L])
  expect_identical(unique(uf_chain$find_many(chain_nodes)), "N1")
})

test_that("2D testlet quadrature C++ kernel matches pure-R reference across variance, gradient, and person subsets", {
  skip_if_not(mfrmr:::mfrm_cpp11_backend_available())

  y <- rbind(
    c(0, 1, 2, 2, 1, 0),
    c(2, 2, 1, 1, 0, 0),
    c(1, 0, 1, 2, 2, 1),
    rep(0, 6),
    rep(2, 6),
    c(NA, NA, NA, 1, 2, 0)
  )
  d <- data.frame(
    Person = rep(paste0("P", 1:6), each = 6L),
    Rater = rep(rep(c("A", "B"), each = 3L), 6L),
    Criterion = rep(1:3, 12L),
    Score = as.vector(t(y)),
    stringsAsFactors = FALSE
  )
  ref_in <- mfrmr:::mfrm_testlet_data(
    d, "Person", "Score", "Rater", c("Rater", "Criterion"), 0:2, "omit"
  )
  empty_rows <- d[1:6, ]
  empty_rows$Person <- "Unobserved"
  empty_rows$Score <- NA_real_
  input <- mfrmr:::mfrm_testlet_data(
    rbind(d, empty_rows), "Person", "Score", "Rater", c("Rater", "Criterion"),
    0:2, "omit", reference = ref_in
  )
  rule <- mfrmr:::gauss_hermite_normal(11L)
  theta_grid <- c(-1.4, 0.0, 0.95)

  for (v_val in c(0, 0.65)) {
    par <- c(0.15 * sin(seq_len(ncol(input$X))), -0.65, 0.65, v_val)
    for (grad_flag in c(FALSE, TRUE)) {
      for (p_sel in list(
        seq_along(input$persons),
        c(6L, 1L, 6L),
        c(7L, 2L),
        7L,
        integer()
      )) {
        res_r <- eval_with_backend(
          FALSE,
          mfrmr:::mfrm_testlet_kernel(input, par, theta_grid, rule, gradient = grad_flag, persons = p_sel)
        )
        res_cpp <- eval_with_backend(
          TRUE,
          mfrmr:::mfrm_testlet_kernel(input, par, theta_grid, rule, gradient = grad_flag, persons = p_sel)
        )
        expect_identical(names(res_cpp), names(res_r))
        expect_identical(dim(res_cpp$loglik), dim(res_r$loglik))
        expect_equal(res_cpp$loglik, res_r$loglik, tolerance = 1e-13)
        if (grad_flag) {
          expect_identical(dim(res_cpp$score), dim(res_r$score))
          expect_equal(res_cpp$score, res_r$score, tolerance = 1e-13)
          expect_equal(res_cpp$theta_score, res_r$theta_score, tolerance = 1e-13)
          expect_equal(res_cpp$theta_curvature, res_r$theta_curvature, tolerance = 1e-13)
        }
      }
    }
  }

  fit_cpp <- eval_with_backend(
    TRUE,
    suppressWarnings(fit_mfrm_testlet(
      d, "Person", "Score", "Rater", c("Rater", "Criterion"), 0:2,
      quad_points = 15L, missing = "omit", person_sd = 1
    ))
  )
  expect_null(fit_cpp$input$.cpp_csr)
})

test_that("marginal pairwise expectations C++ kernel matches pure-R reference with weights and invalid rows", {
  skip_if_not(mfrmr:::mfrm_cpp11_backend_available())

  set.seed(404)
  n_obs <- 72L
  q_pts <- 9L
  k_cat <- 4L
  obs_df <- data.frame(
    Person = rep(paste0("P", 1:12), each = 6L),
    Rater = rep(paste0("R", 1:3), times = 24L),
    Criterion = rep(c("C1", "C2"), times = 36L),
    Observed = sample(0:3, n_obs, replace = TRUE),
    stringsAsFactors = FALSE
  )
  weights <- c(0, stats::runif(n_obs - 1L, min = 0.25, max = 1.75))
  person_post <- matrix(stats::runif(12L * q_pts), nrow = 12L, ncol = q_pts)
  person_post <- person_post / rowSums(person_post)
  obs_post <- person_post[match(obs_df$Person, paste0("P", 1:12)), , drop = FALSE]
  obs_post[11L, ] <- c(0.7, 0.7, rep(0, q_pts - 2L))

  prob_list <- lapply(seq_len(q_pts), function(q) {
    pm <- matrix(stats::runif(n_obs * k_cat), nrow = n_obs, ncol = k_cat)
    pm <- pm / rowSums(pm)
    if (q == 3L) pm[5L, ] <- c(NA_real_, 0.5, 0.5, 0)
    pm
  })

  expected_core <- list(
    prep = list(data = obs_df),
    config = list(facet_names = c("Rater", "Criterion")),
    logprob_bundle = list(prob_list = prob_list),
    posterior_bundle = list(obs_posterior = obs_post),
    observed_cat = obs_df$Observed,
    weights = weights,
    categories = 0:3
  )

  pair_r <- eval_with_backend(FALSE, mfrmr:::calc_marginal_pairwise_bundle(expected_core))
  pair_cpp <- eval_with_backend(TRUE, mfrmr:::calc_marginal_pairwise_bundle(expected_core))
  expect_identical(pair_cpp$available, pair_r$available)
  expect_identical(pair_cpp$pairs[, c("Facet", "Level1", "Level2", "ContextPairs", "EvaluatedPairs", "ExcludedPairs", "Flag")],
                   pair_r$pairs[, c("Facet", "Level1", "Level2", "ContextPairs", "EvaluatedPairs", "ExcludedPairs", "Flag")])
  expect_equal(pair_cpp$pairs, pair_r$pairs, tolerance = 1e-13)
  expect_equal(pair_cpp$summary, pair_r$summary, tolerance = 1e-13)
})

test_that("sparse co-occurrence calc_interrater_agreement preserves exact counts, types, and model expectations", {
  fcols <- c("Person", "Rater", "Criterion")

  # Complete design -> all R*(R-1)/2 pairs have N > 0 (integer count columns)
  complete_df <- expand.grid(
    Person = paste0("P", 1:5),
    Rater = paste0("R", 1:3),
    Criterion = c("C1", "C2"),
    stringsAsFactors = FALSE
  )
  set.seed(505)
  complete_df$Observed <- sample(1:4, nrow(complete_df), replace = TRUE)
  ia_comp <- mfrmr:::calc_interrater_agreement(complete_df, fcols, "Rater", res = NULL)
  expect_identical(nrow(ia_comp$pairs), 3L)
  expect_type(ia_comp$pairs$N, "integer")
  expect_type(ia_comp$pairs$ExactCount, "integer")

  # Sparse high-cardinality rater design with duplicate context ratings, NAs, and disjoint raters
  sparse_rows <- lapply(seq_len(40L), function(p) {
    r1 <- sprintf("R%02d", ((p - 1L) %% 30L) + 1L)
    r2 <- sprintf("R%02d", ((p + 3L) %% 30L) + 1L)
    data.frame(
      Person = sprintf("P%02d", p),
      Rater = c(r1, r2),
      Criterion = "C1",
      Score = c((p %% 4L) + 1L, ((p + 1L) %% 4L) + 1L),
      stringsAsFactors = FALSE
    )
  })
  sparse_df <- do.call(rbind, sparse_rows)
  sparse_df <- rbind(
    sparse_df,
    sparse_df[1L, ],
    data.frame(Person = "P01", Rater = "R99_solo", Criterion = "C1", Score = NA_integer_, stringsAsFactors = FALSE)
  )
  obs_sparse <- sparse_df
  names(obs_sparse)[names(obs_sparse) == "Score"] <- "Observed"
  ia_sp <- mfrmr:::calc_interrater_agreement(obs_sparse, fcols, "Rater", res = NULL)
  expect_identical(nrow(ia_sp$pairs), as.integer(choose(length(unique(obs_sparse$Rater)), 2L)))
  expect_type(ia_sp$pairs$N, "double")
  expect_identical(sum(ia_sp$pairs$N), ia_sp$summary$TotalPairs)
  expect_identical(sum(ia_sp$pairs$OpportunityCount), ia_sp$summary$OpportunityCount)

  # Single-rater and zero-overlap edge cases
  ia_one <- mfrmr:::calc_interrater_agreement(complete_df[complete_df$Rater == "R1", ], fcols, "Rater", res = NULL)
  expect_identical(nrow(ia_one$pairs), 0L)

  disjoint_df <- rbind(
    complete_df[complete_df$Person == "P1" & complete_df$Rater == "R1", ],
    complete_df[complete_df$Person == "P2" & complete_df$Rater == "R2", ]
  )
  ia_dis <- mfrmr:::calc_interrater_agreement(disjoint_df, fcols, "Rater", res = NULL)
  expect_identical(nrow(ia_dis$pairs), 1L)
  expect_identical(ia_dis$pairs$N, 0)
  expect_true(is.na(ia_dis$pairs$Exact))
})

test_that("iteration_limit warning reports maxit and free parameter dimension without altering opt status", {
  d <- mfrmr:::sample_mfrm_data(seed = 606)
  warns <- character()
  fit <- withCallingHandlers(
    fit_mfrm(d, "Person", c("Rater", "Task", "Criterion"), "Score", model = "RSM", method = "JML", maxit = 2L),
    warning = function(w) {
      warns <<- c(warns, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  expect_identical(fit$opt$optimizer_diagnostics$ConvergenceStatus, "iteration_limit")
  expect_true(any(grepl("maxit = 2, free parameters =", warns, fixed = TRUE)))
})
