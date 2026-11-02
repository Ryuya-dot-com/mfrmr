population_identification_setup <- function(model = "RSM", n = 6L, data = NULL) {
  if (is.null(data)) {
    data <- expand.grid(Person = paste0("P", seq_len(n)), Rater = c("R1", "R2"),
      Criterion = c("C1", "C2"), stringsAsFactors = FALSE)
    data$Score <- rep(0:2, length.out = nrow(data))
  }
  prep <- prepare_mfrm_data(data, "Person", c("Rater", "Criterion"), "Score",
    rating_min = 0, rating_max = 2)
  pop <- list(active = TRUE, person_id = "Person",
    person_table = data.frame(Person = prep$levels$Person),
    design_matrix = cbind("(Intercept)" = 1, X = seq(-1, 1, length.out = prep$n_person)))
  cfg <- build_estimation_config(prep, model, "MML",
    step_facet = if (model != "RSM") "Criterion", slope_facet = if (model == "GPCM") "Criterion",
    interaction_specs = list(), weight_col = NULL,
    facet_signs = c(Rater = -1, Criterion = -1), positive_facets = character(),
    noncenter_facet = "Person", dummy_facets = character(), anchor_df = NULL,
    group_anchor_df = NULL, population = pop, centering_scope = "facet")$config
  list(prep = prep, config = cfg, sizes = build_param_sizes(cfg),
    idx = build_indices(prep, cfg$step_facet, cfg$slope_facet))
}

population_identification_audit <- function(x) {
  do.call(audit_mfrm_estimability, x)$normal_population_identification
}

test_that("normal-population identification covers repeated designs beyond numerical audit caps", {
  for (model in c("RSM", "PCM")) for (n in c(6L, 240L, 960L)) {
    x <- population_identification_setup(model, n)
    a <- population_identification_audit(x)
    expect_true(a$sufficient_conditions_met)
    expect_equal(a$additive_rank, if (model == "RSM") 5L else 6L)
    expect_equal(a$additive_dimension, a$additive_rank)
    expect_equal(c(a$repeated_persons, a$singleton_persons), c(n, 0))
    expect_identical(a$readiness_effect, "none_identification_only")
    expect_match(a$limitations, "boundary exclusion")
    full <- do.call(audit_mfrm_estimability, x)
    expect_false(full$complete)
    expect_match(full$readiness$ReasonCodes, "design_rank_not_evaluated")
    # Model category support is different from realized category usage.
    x$prep$data$Score[] <- 0
    expect_identical(population_identification_audit(x), a)
  }
})

test_that("singleton mixtures require full rank on the repeated subset", {
  x <- population_identification_setup()
  d <- x$prep$data[c(which(x$prep$data$Person != "P6"),
    which(x$prep$data$Person == "P6")[1]), c("Person", "Rater", "Criterion", "Score")]
  for (model in c("RSM", "PCM")) {
    mixed <- population_identification_setup(model, data = d)
    a <- population_identification_audit(mixed)
    expect_true(a$sufficient_conditions_met)
    expect_equal(c(a$repeated_persons, a$singleton_persons), c(5, 1))
    # Only a singleton supplies this predictor contrast: full overall rank
    # does not imply that the sufficient repeated-subset condition holds.
    mixed$config$population_spec$design_matrix[, "X"] <- c(0,0,0,0,0,1)
    audit <- do.call(audit_mfrm_estimability, mixed)
    expect_identical(audit$design$state, "identified")
    expect_false(audit$normal_population_identification$sufficient_conditions_met)
    expect_identical(audit$normal_population_identification$state, "inconclusive")
  }
  one <- d[!duplicated(d$Person), ]
  one$Rater <- rep(c("R1", "R2"),3); one$Criterion <- rep(c("C1","C2"),each=3)
  a <- population_identification_audit(population_identification_setup(data = one))
  expect_false(a$sufficient_conditions_met)
  expect_equal(a$repeated_persons, 0L)
  expect_match(a$reason, "not a nonidentification certificate")
})

test_that("aliases and tolerance-sensitive rank do not receive a certificate", {
  x <- population_identification_setup()
  d <- x$prep$data; d$Criterion <- sub("R", "C", d$Rater)
  d <- d[!duplicated(d[c("Person","Rater","Criterion")]),]
  a <- population_identification_audit(population_identification_setup(data = d))
  expect_false(a$sufficient_conditions_met)
  expect_lt(a$additive_rank, a$additive_dimension)
  x$config$population_spec$design_matrix[, "X"] <- 1 + 1e-9 * seq(-1, 1, length.out=6)
  a <- population_identification_audit(x)
  expect_false(a$sufficient_conditions_met)
  expect_match(a$reason, "depends on the recorded tolerance")
})

test_that("other models and unresolved repeated-cell dependence remain outside the certificate", {
  x <- population_identification_setup()
  variants <- list(
    function(z) {z$config$method <- "JML"; z},
    function(z) {z$config$model <- "GPCM"; z},
    function(z) {z$config$population_spec$active <- FALSE; z},
    function(z) {z$config$population_spec$fixed_sd <- 1; z},
    function(z) {z$config$interaction_specs <- list(unreviewed = TRUE); z},
    function(z) {z$config$facet_specs$Rater$anchors[1] <- 0; z},
    function(z) {z$config$facet_specs$Rater$groups[1] <- "g"; z},
    function(z) {z$config$step_specs[[1]]$anchors[1] <- 0; z},
    function(z) {z$idx$weight[1] <- 1.5; z},
    function(z) {z$prep$preparation_notes <- data.frame(Condition="duplicate_person_facet_cells"); z})
  primary <- mfrmr_estimability_adjacent_design(x$prep, x$idx, x$config, x$sizes)
  rank <- mfrmr_estimability_rank_audit(primary$design, primary$map)
  for (change in variants) {
    z <- change(x)
    a <- mfrmr_normal_population_identification(z$prep,z$idx,z$config,z$sizes,primary,rank)
    expect_false(a$sufficient_conditions_met)
    expect_identical(a$state, "not_applicable")
  }
  x$prep$preparation_notes <- data.frame(Condition="independent_repeated_ratings_declared")
  expect_true(mfrmr_normal_population_identification(x$prep,x$idx,x$config,x$sizes,
    primary,rank)$sufficient_conditions_met)
})

test_that("public fits and saved summaries expose identification without promoting inference", {
  d <- load_mfrmr_data("example_core")
  fit <- suppressWarnings(fit_mfrm(d,"Person",c("Rater","Criterion"),"Score",
    population_formula=~1,person_data=unique(d["Person"]),
    control=list(quad_points=21L,maxit=200L)))
  a <- fit$data_review$estimability$normal_population_identification
  expect_true(a$sufficient_conditions_met)
  expect_identical(fit$config$estimability_audit$normal_population_identification,a)
  expect_false(fit$readiness$fit$InferenceReady)
  expect_identical(summary(fit)$decision$FormalInference,"No")
  path <- tempfile(fileext=".rds"); on.exit(unlink(path),add=TRUE)
  saveRDS(fit,path); saved <- readRDS(path)
  expect_identical(summary(saved)$data_review$estimability$normal_population_identification,a)
  saved$data_review$estimability$normal_population_identification <- NULL
  saved$config$estimability_audit$normal_population_identification <- NULL
  expect_null(summary(saved)$data_review$estimability$normal_population_identification)
  expect_identical(summary(saved)$decision$FormalInference,"No")
})
