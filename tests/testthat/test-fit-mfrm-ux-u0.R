test_that("fit_mfrm exposes the 19-argument U0 signature and disjoint model/control partition", {
  expected_formals <- c(
    "data", "person", "facets", "score",
    "model", "method", "step_facet", "slope_facet",
    "rating_min", "rating_max", "weight",
    "anchors", "group_anchors",
    "population_formula", "person_data",
    "facet_interactions",
    "spec", "control", "..."
  )
  expect_identical(names(formals(fit_mfrm)), expected_formals)
  expect_length(formals(fit_mfrm), 19L)

  spec_keys <- mfrmr:::.mfrm_fit_spec_keys()
  control_keys <- mfrmr:::.mfrm_fit_control_keys()
  canonical <- mfrmr:::.mfrm_fit_canonical_names()
  defaults <- mfrmr:::.mfrm_fit_canonical_defaults()

  expect_length(spec_keys, 34L)
  expect_length(control_keys, 21L)
  expect_length(canonical, 56L)
  expect_length(defaults, 56L)
  expect_length(intersect(spec_keys, control_keys), 0L)
  expect_false("data" %in% spec_keys)
  expect_false("data" %in% control_keys)
  expect_setequal(canonical, c("data", spec_keys, control_keys))
  expect_identical(names(defaults), canonical)

  # Every core formal (except data, spec, control, ...) belongs to spec_keys.
  core_formals <- setdiff(expected_formals, c("data", "spec", "control", "..."))
  expect_length(core_formals, 15L)
  expect_true(all(core_formals %in% spec_keys))

  # Zero R partial-matching prefix collisions between visible formals and
  # all 40 non-formal canonical arguments accepted via `...`.
  named_formals <- setdiff(expected_formals, "...")
  extra_canonical <- setdiff(canonical, named_formals)
  expect_length(extra_canonical, 40L)
  matches <- setNames(pmatch(extra_canonical, named_formals), extra_canonical)
  expect_identical(matches, setNames(rep(NA_integer_, length(extra_canonical)), extra_canonical))
  prefixes <- vapply(setNames(extra_canonical, extra_canonical), function(arg_nm) {
    startsWith(named_formals, arg_nm)
  }, logical(length(named_formals)))
  rownames(prefixes) <- named_formals
  expect_identical(prefixes, matrix(FALSE, nrow(prefixes), ncol(prefixes),
                                    dimnames = dimnames(prefixes)))

  # Top-level NAMESPACE export count remains strictly 163; technical reference is non-exported.
  exports <- getNamespaceExports("mfrmr")
  expect_length(exports, 163L)
  expect_false("fit_mfrm_technical_details" %in% exports)
})

expect_u0_fit_bitwise_equal <- function(new_fit, ref_fit) {
  expect_identical(class(new_fit), class(ref_fit))
  expect_identical(new_fit$summary, ref_fit$summary)
  expect_identical(new_fit$facets, ref_fit$facets)
  expect_identical(new_fit$steps, ref_fit$steps)
  expect_identical(new_fit$slopes, ref_fit$slopes)
  expect_identical(new_fit$opt$par, ref_fit$opt$par)
  expect_identical(new_fit$config$replay_inputs, ref_fit$config$replay_inputs)
}

test_that("flat calls, spec + control, overrides, and do.call agree for ordinary MML and JML", {
  d <- load_mfrmr_data("example_core")

  # 1. Ordinary RSM / MML: flat vs spec+control vs override vs do.call
  fit_flat_mml <- fit_mfrm(
    d,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    model = "RSM",
    method = "MML",
    rating_min = 1,
    rating_max = 4,
    category_policy = "preserve",
    quad_points = 9,
    maxit = 80
  )
  spec_mml <- list(
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    model = "RSM",
    method = "MML",
    rating_min = 1,
    rating_max = 4,
    category_policy = "preserve"
  )
  ctrl_mml <- list(quad_points = 9, maxit = 80)

  fit_spec_mml <- fit_mfrm(d, spec = spec_mml, control = ctrl_mml)
  expect_u0_fit_bitwise_equal(fit_spec_mml, fit_flat_mml)

  spec_to_override <- modifyList(spec_mml, list(model = "PCM", step_facet = "Criterion"))
  fit_override_mml <- fit_mfrm(
    d,
    model = "RSM",
    step_facet = NULL,
    spec = spec_to_override,
    control = ctrl_mml
  )
  expect_u0_fit_bitwise_equal(fit_override_mml, fit_flat_mml)

  fit_docall_mml <- do.call(fit_mfrm, c(list(data = d), spec_mml, ctrl_mml))
  expect_u0_fit_bitwise_equal(fit_docall_mml, fit_flat_mml)

  # 2. PCM / JML (with empirical-Bayes facet shrinkage in `control`)
  fit_flat_jml <- fit_mfrm(
    d,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    model = "PCM",
    method = "JML",
    step_facet = "Criterion",
    facet_shrinkage = "empirical_bayes",
    facet_prior_sd = 2,
    maxit = 60
  )
  fit_spec_jml <- fit_mfrm(
    d,
    spec = list(
      person = "Person",
      facets = c("Rater", "Criterion"),
      score = "Score",
      model = "PCM",
      method = "JML",
      step_facet = "Criterion"
    ),
    control = list(
      facet_shrinkage = "empirical_bayes",
      facet_prior_sd = 2,
      maxit = 60
    )
  )
  expect_u0_fit_bitwise_equal(fit_spec_jml, fit_flat_jml)
})

test_that("corrected JML refuses an owner-total space above the exact-state limit", {
  skip_if_not_installed("nleqslv")
  d <- load_mfrmr_data("example_core")
  expect_error(
    fit_mfrm(d, person = "Person", facets = c("Rater", "Criterion"),
             score = "Score", model = "GPCM", method = "JML",
             step_facet = "Criterion", rating_min = 1, rating_max = 4,
             category_policy = "preserve", jml_correction_order = 2L),
    "Owner-total space exceeds max_states; no states were omitted.", fixed = TRUE
  )
})

test_that("flat and structured calls agree across extended estimation engines", {
  # Ordinary MML/JML exercise argument resolution on CRAN; the engine-specific
  # files retain live corrected JML, GPCM and CML numerical checks there.
  skip_on_cran()
  d <- load_mfrmr_data("example_core")
  if (requireNamespace("nleqslv", quietly = TRUE)) {
    # example_core needs 28,561 owner-total states, above the 5,000-state
    # limit. Use the existing corrected-JML reference design for equivalence.
    corrected <- readRDS(test_path("fixtures", "jml-adjustment-general.rds"))
    expect_warning(fit_flat_cjml <- fit_mfrm(
      corrected$data,
      person = corrected$person,
      facets = corrected$facets,
      score = corrected$score,
      model = "GPCM",
      method = "JML",
      step_facet = corrected$owner,
      rating_min = 0,
      rating_max = corrected$rating_max,
      category_policy = "preserve",
      jml_correction_order = 2L,
      jml_correction_sampling = "fixed_rosters",
      maxit = 40
    ), "duplicated Person")
    expect_warning(fit_spec_cjml <- fit_mfrm(
      corrected$data,
      spec = list(
        person = corrected$person,
        facets = corrected$facets,
        score = corrected$score,
        model = "GPCM",
        method = "JML",
        step_facet = corrected$owner,
        rating_min = 0,
        rating_max = corrected$rating_max,
        category_policy = "preserve"
      ),
      control = list(
        jml_correction_order = 2L,
        jml_correction_sampling = "fixed_rosters",
        maxit = 40
      )
    ), "duplicated Person")
    expect_true(fit_flat_cjml$jml_adjustment$point$available)
    expect_equal(fit_flat_cjml$jml_adjustment$point$beta,
                 corrected$results[["2"]]$beta, tolerance = 1e-7)
    expect_u0_fit_bitwise_equal(fit_spec_cjml, fit_flat_cjml)
    expect_identical(fit_spec_cjml$jml_adjustment, fit_flat_cjml$jml_adjustment)
  }

  # 3. One-family GPCM / MML
  fit_flat_gpcm <- fit_mfrm(
    d,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    model = "GPCM",
    method = "MML",
    step_facet = "Criterion",
    slope_facet = "Rater",
    gpcm_mml_identification = "fixed_standard_normal",
    quad_points = 9,
    maxit = 50
  )
  fit_spec_gpcm <- fit_mfrm(
    d,
    spec = list(
      person = "Person",
      facets = c("Rater", "Criterion"),
      score = "Score",
      model = "GPCM",
      method = "MML",
      step_facet = "Criterion",
      slope_facet = "Rater",
      gpcm_mml_identification = "fixed_standard_normal"
    ),
    control = list(quad_points = 9, maxit = 50)
  )
  expect_u0_fit_bitwise_equal(fit_spec_gpcm, fit_flat_gpcm)

  # 4. Native CML
  fit_flat_cml <- fit_mfrm(
    d,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    model = "RSM",
    method = "CML",
    category_policy = "preserve",
    maxit = 80
  )
  fit_spec_cml <- fit_mfrm(
    d,
    spec = list(
      person = "Person",
      facets = c("Rater", "Criterion"),
      score = "Score",
      model = "RSM",
      method = "CML",
      category_policy = "preserve"
    ),
    control = list(maxit = 80)
  )
  expect_identical(class(fit_spec_cml), class(fit_flat_cml))
  expect_identical(fit_spec_cml$summary, fit_flat_cml$summary)
  expect_identical(fit_spec_cml$facets, fit_flat_cml$facets)
  expect_identical(fit_spec_cml$steps, fit_flat_cml$steps)
  expect_identical(fit_spec_cml$opt$par, fit_flat_cml$opt$par)
})

test_that("structured Jeffreys and comparison-only calls retain their estimates", {
  d <- load_mfrmr_data("example_core")
  cran_reuse <- !isTRUE(as.logical(Sys.getenv("NOT_CRAN", "false")))
  reused <- 0L
  if (cran_reuse) {
    generator <- mfrmr:::mfrm_fair_jeffreys_generator
    previous <- NULL
    local_mocked_bindings(mfrm_fair_jeffreys_generator = function(fit, gradient_tol) {
      # Both public calls still prepare and validate their inputs. Only an exact
      # repeated numerical problem reuses the first fully checked solution.
      settings <- list(fit = fit, gradient_tol = gradient_tol,
        options = options()[startsWith(names(options()), "mfrmr.")],
        design = mfrmr:::mfrm_fair_jeffreys_design,
        objective = mfrmr:::mfrm_fair_jeffreys_objective,
        polish = mfrmr:::mfrm_fair_jeffreys_polish)
      if (!is.null(previous) && identical(settings, previous$settings)) {
        reused <<- reused + 1L
        return(previous$value)
      }
      warned <- FALSE
      value <- withCallingHandlers(generator(fit, gradient_tol),
        warning = function(w) warned <<- TRUE)
      if (!warned) previous <<- list(settings = settings, value = value)
      value
    }, .package = "mfrmr")
  }

  # 5. Jeffreys-penalized JML
  fit_flat_jeff <- fit_mfrm(
    d,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    model = "RSM",
    method = "JML",
    rating_min = 1,
    rating_max = 4,
    category_policy = "preserve",
    jml_penalty = "jeffreys",
    maxit = 60
  )
  fit_spec_jeff <- fit_mfrm(
    d,
    spec = list(
      person = "Person",
      facets = c("Rater", "Criterion"),
      score = "Score",
      model = "RSM",
      method = "JML",
      rating_min = 1,
      rating_max = 4,
      category_policy = "preserve"
    ),
    control = list(jml_penalty = "jeffreys", maxit = 60)
  )
  expect_identical(class(fit_spec_jeff), class(fit_flat_jeff))
  expect_identical(fit_spec_jeff$probabilities, fit_flat_jeff$probabilities)
  expect_identical(fit_spec_jeff$parameter_map, fit_flat_jeff$parameter_map)
  expect_identical(fit_spec_jeff$facets, fit_flat_jeff$facets)
  expect_identical(fit_spec_jeff$steps, fit_flat_jeff$steps)
  expect_identical(fit_spec_jeff$opt$par, fit_flat_jeff$opt$par)
  expect_identical(reused, if (cran_reuse) 1L else 0L)

  # 6. Comparison-only estimation (`fit_scope = "comparisons"`)
  comp_df <- do.call(rbind, lapply(c("A", "B"), function(g) {
    raters <- if (g == "A") c("R1", "R2", "R3") else c("R1", "R2")
    patterns <- as.matrix(expand.grid(rep(list(0:1), length(raters))))
    data.frame(
      Person = rep(paste0(g, seq_len(nrow(patterns))), each = length(raters)),
      Rater = rep(raters, nrow(patterns)),
      Group = g,
      Score = as.vector(t(patterns)),
      stringsAsFactors = FALSE
    )
  }))
  W <- rbind(pair = c(R1 = 1, R2 = -1, R3 = 0))
  comp_desc <- describe_mfrm_data(
    comp_df,
    person = "Person",
    facets = c("Rater", "Group"),
    score = "Score",
    rating_min = 0,
    rating_max = 1,
    category_policy = "preserve",
    include_agreement = FALSE,
    comparisons = list(
      facet = "Rater",
      group = "Group",
      groups = c("A", "B"),
      contrasts = W,
      model = "RSM",
      method = "CML"
    )
  )
  fit_comp_flat <- do.call(
    fit_mfrm,
    c(
      list(
        data = comp_df,
        fit_scope = "comparisons",
        comparison_review = comp_desc,
        interaction_policy = "silent"
      ),
      comp_desc$comparison_review$fit_arguments
    )
  )
  fit_comp_spec <- fit_mfrm(
    comp_df,
    spec = modifyList(
      comp_desc$comparison_review$fit_arguments,
      list(interaction_policy = "silent")
    ),
    control = list(
      fit_scope = "comparisons",
      comparison_review = comp_desc
    )
  )
  expect_identical(class(fit_comp_spec), class(fit_comp_flat))
  expect_identical(fit_comp_spec$table, fit_comp_flat$table)
  expect_identical(fit_comp_spec$summary, fit_comp_flat$summary)
})

test_that("one shared spec list works unchanged across all 4 entrypoints with top-level overrides", {
  d <- load_mfrmr_data("example_core")
  r_levels <- sort(unique(as.character(d$Rater)))
  anch <- data.frame(
    Facet = "Rater",
    Level = r_levels[1L],
    Anchor = 0.15,
    stringsAsFactors = FALSE
  )

  shared_spec <- list(
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    model = "PCM",
    method = "MML",
    step_facet = "Criterion",
    rating_min = 1,
    rating_max = 4,
    category_policy = "preserve",
    anchors = anch,
    anchor_policy = "error",
    min_common_anchors = 1L,
    min_obs_per_element = 2L,
    min_obs_per_category = 1L,
    min_obs_per_interaction = 10L,
    interaction_policy = "warn"
  )

  # 1. describe_mfrm_data (accepts the full shared_spec even when anchor/fit keys are present)
  desc_spec <- describe_mfrm_data(d, spec = shared_spec, include_agreement = FALSE)
  desc_flat <- describe_mfrm_data(
    d,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 1,
    rating_max = 4,
    category_policy = "preserve",
    include_agreement = FALSE
  )
  expect_identical(desc_spec, desc_flat)

  # Top-level override on describe_mfrm_data
  desc_override <- describe_mfrm_data(
    d,
    rating_max = 5,
    spec = shared_spec,
    include_agreement = FALSE
  )
  expect_identical(desc_override$score_support$rating_max, 5L)

  # 2. review_mfrm_anchors
  rev_spec <- review_mfrm_anchors(d, spec = shared_spec)
  rev_flat <- review_mfrm_anchors(
    d,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 1,
    rating_max = 4,
    category_policy = "preserve",
    anchors = anch,
    min_common_anchors = 1L,
    min_obs_per_element = 2L,
    min_obs_per_category = 1L
  )
  expect_identical(rev_spec, rev_flat)

  rev_override <- review_mfrm_anchors(d, min_obs_per_element = 5L, spec = shared_spec)
  expect_equal(rev_override$thresholds$min_obs_per_element, 5)

  # 3. fit_mfrm
  fit_spec <- fit_mfrm(d, spec = shared_spec, control = list(quad_points = 9, maxit = 60))
  fit_flat <- fit_mfrm(
    d,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    model = "PCM",
    method = "MML",
    step_facet = "Criterion",
    rating_min = 1,
    rating_max = 4,
    category_policy = "preserve",
    anchors = anch,
    anchor_policy = "error",
    min_common_anchors = 1L,
    min_obs_per_element = 2L,
    min_obs_per_category = 1L,
    min_obs_per_interaction = 10L,
    interaction_policy = "warn",
    quad_points = 9,
    maxit = 60
  )
  expect_identical(fit_spec$summary, fit_flat$summary)
  expect_identical(fit_spec$opt$par, fit_flat$opt$par)

  # 4. export_mfrm_model (direct spec export without running fit_mfrm)
  out_dir <- withr::local_tempdir()
  exp_spec <- suppressWarnings(export_mfrm_model(
    data = d,
    spec = shared_spec,
    format = "stan",
    output_dir = out_dir
  ))
  expect_type(exp_spec, "list")
  expect_identical(exp_spec$format, "stan")
  expect_true(file.exists(file.path(out_dir, "model.stan")))
  expect_true(file.exists(file.path(out_dir, "model-data.rds")))
})

test_that("spec, control, ..., and fit_mfrm_imputed fail closed on invalid or duplicate keys", {
  d <- load_mfrmr_data("example_core")
  base_spec <- list(person = "Person", facets = c("Rater", "Criterion"), score = "Score")

  # Unnamed extra argument in `...`
  expect_error(
    fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", "RSM", "MML", NULL, NULL, 1, 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, list(), 99),
    "Unnamed extra arguments"
  )

  # Unknown extra argument in `...` with typo hint
  expect_error(
    fit_mfrm(d, spec = base_spec, quad_point = 15),
    "Did you mean `quad_points` \\(in `control = list\\(...\\)`\\)"
  )
  expect_error(
    fit_mfrm(d, spec = base_spec, category_polic = "preserve"),
    "Did you mean `category_policy`"
  )

  # `spec` / `control` type validation
  expect_error(fit_mfrm(d, spec = "not_a_list"), "`spec`.*must be NULL or a named list")
  expect_error(fit_mfrm(d, spec = list("Person")), "`spec`.*must have unique non-empty names")
  expect_error(fit_mfrm(d, spec = base_spec, control = "not_a_list"), "`control`.*must be.*named list")
  expect_error(fit_mfrm(d, spec = base_spec, control = list(15)), "`control`.*must have unique non-empty names")

  # Misplaced `control` key inside `spec` fails closed across all 4 entrypoints
  bad_spec_ctrl <- modifyList(base_spec, list(maxit = 50))
  expect_error(fit_mfrm(d, spec = bad_spec_ctrl), "maxit.*`control = list\\(...\\)`")
  expect_error(describe_mfrm_data(d, spec = bad_spec_ctrl), "maxit.*`control = list\\(...\\)`")
  expect_error(review_mfrm_anchors(d, spec = bad_spec_ctrl), "maxit.*`control = list\\(...\\)`")
  # Model export has no numerical-control destination and must reject before writing.
  bad_export_dir <- tempfile("invalid-control-export-")
  withr::defer(unlink(bad_export_dir, recursive = TRUE))
  expect_error(
    export_mfrm_model(data = d, spec = bad_spec_ctrl, output_dir = bad_export_dir),
    "maxit.*omit numerical controls when exporting a model specification"
  )
  expect_false(dir.exists(bad_export_dir))

  # Misplaced `spec` key inside `control`
  expect_error(
    fit_mfrm(d, spec = base_spec, control = list(category_policy = "preserve")),
    "category_policy.*`spec = list\\(...\\)`"
  )
  expect_error(
    fit_mfrm(d, spec = base_spec, control = list(anchors = data.frame())),
    "anchors.*`spec = list\\(...\\)`"
  )

  # Duplicate across `spec` and `...`
  expect_error(
    fit_mfrm(d, spec = modifyList(base_spec, list(category_policy = "preserve")), category_policy = "preserve"),
    "Duplicate specification in both `spec` and `...`: category_policy", fixed = TRUE
  )

  # Duplicate across `control` and `...`
  expect_error(
    fit_mfrm(d, spec = base_spec, control = list(maxit = 50), maxit = 50),
    "Duplicate specification in both `control` and `...`: maxit", fixed = TRUE
  )

  # Missing required columns fail cleanly across describe_mfrm_data and review_mfrm_anchors
  expect_error(describe_mfrm_data(d), "`person` must be a single non-empty character string")
  expect_error(review_mfrm_anchors(d, person = "Person"),
               "`facets` must be a character vector of one or more facet column names")

  # fit_mfrm_imputed supports structured control/spec while preserving blocked-key guards
  raw_imp <- data.frame(
    Event = as.character(1:8),
    Person = rep(c("P1", "P2", "P3", "P4"), each = 2),
    Rater = rep(c("R1", "R2"), times = 4),
    Score = c(0, NA, 1, 2, 0, 1, 2, 1),
    stringsAsFactors = FALSE
  )
  imp1 <- imp2 <- raw_imp
  imp1$Score[2] <- 1
  imp2$Score[2] <- 2
  rev_imp <- review_mfrm_imputations(
    raw_imp,
    list(imp1, imp2),
    person = "Person",
    facets = "Rater",
    score = "Score",
    event_id = "Event",
    impute_ids = "2",
    categories = 0:2,
    imputation_model = list(method = "test fixture")
  )
  # This workflow fixes method = MML; use only its supported shared settings.
  imp_flat <- fit_mfrm_imputed(rev_imp, centering_scope = "facet", quad_points = 9, maxit = 40)
  imp_ctrl <- fit_mfrm_imputed(
    rev_imp,
    spec = list(centering_scope = "facet"),
    control = list(quad_points = 9, maxit = 40)
  )
  expect_length(imp_flat$fits, 2L)
  expect_true(all(vapply(imp_flat$fits, inherits, logical(1), "mfrm_fit")))
  expect_false(any(nzchar(imp_flat$analysis_summary$Error)))
  expect_identical(imp_ctrl$analysis_summary, imp_flat$analysis_summary)
  imputed_fit_values <- function(x) list(
    summary = x$summary, facets = x$facets, steps = x$steps,
    par = x$opt$par, replay_inputs = x$config$replay_inputs
  )
  expect_identical(
    lapply(imp_ctrl$fits, imputed_fit_values),
    lapply(imp_flat$fits, imputed_fit_values)
  )
  expect_error(fit_mfrm_imputed(rev_imp, method = "JML"), "supported shared fitting")
  expect_error(fit_mfrm_imputed(rev_imp, spec = list(method = "JML")), "supported shared fitting")
  expect_error(
    fit_mfrm_imputed(rev_imp, control = list(checkpoint = list())),
    "supported shared fitting"
  )
  expect_error(
    fit_mfrm_imputed(rev_imp, spec = list(category_policy = "collapse")),
    "supported shared fitting"
  )
})

test_that("technical-details help preserves verbatim specs and output guide exposes core_workflow", {
  rd_db <- tools::Rd_db("mfrmr")
  expect_true("fit_mfrm.Rd" %in% names(rd_db))
  expect_true("fit_mfrm_technical_details.Rd" %in% names(rd_db))

  fit_txt <- paste(
    capture.output(tools::Rd2txt(rd_db[["fit_mfrm.Rd"]], options = list(underline_titles = FALSE))),
    collapse = "\n"
  )
  tech_txt <- paste(
    capture.output(tools::Rd2txt(rd_db[["fit_mfrm_technical_details.Rd"]], options = list(underline_titles = FALSE))),
    collapse = "\n"
  )

  # Concise primary help links to technical reference and core_workflow
  expect_match(fit_txt, "fit_mfrm_technical_details", fixed = TRUE)
  expect_match(fit_txt, "core_workflow", fixed = TRUE)

  # Technical reference retains specialist mathematics, identification, polish ladder, and provenance
  for (marker in c(
    "Logistic metric (D = 1)",
    "Corrected JML",
    "Two slope families",
    "Jeffreys-penalized JML",
    "Conditional maximum likelihood",
    "Comparison-only estimation",
    "Latent-regression workflow",
    "Detailed return-object provenance",
    "provenance_version = 2",
    "jml_information_polish",
    "10.1214/08-EJS349"
  )) {
    expect_match(tech_txt, marker, fixed = TRUE)
  }
  for (key in c(mfrmr:::.mfrm_fit_spec_keys(), mfrmr:::.mfrm_fit_control_keys())) {
    expect_match(tech_txt, key, fixed = TRUE)
  }

  # Core-5 workflow scope has 5 rows while beginner scope retains its 6-row contract
  core_wf <- mfrmr_output_guide("core_workflow")
  expect_equal(nrow(core_wf), 5L)
  expect_true(all(core_wf$Scope == "core_workflow"))
  expect_true(all(core_wf$RecommendedEntry))
  expect_true(all(core_wf$UserLevel == "beginner"))
  expect_equal(nrow(mfrmr_output_guide("beginner")), 6L)
})
