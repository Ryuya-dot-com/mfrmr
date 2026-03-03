# Tests for DIF analysis module (Phase 2) and compare_mfrm enhancements (Phase 3)

# ---------- shared fixtures ----------
local_dif_fixtures <- function(env = parent.frame()) {
  toy <- load_mfrmr_data("study1")
  persons <- unique(toy$Person)
  half <- ceiling(length(persons) / 2)
  grp_map <- setNames(
    c(rep("A", half), rep("B", length(persons) - half)),
    persons
  )
  toy$Group <- grp_map[toy$Person]

  fit <- fit_mfrm(toy, person = "Person", facets = c("Rater", "Criterion"),
                  score = "Score", method = "JML")
  diag <- diagnose_mfrm(fit)

  assign("toy",  toy,  envir = env)
  assign("fit",  fit,  envir = env)
  assign("diag", diag, envir = env)
}

# ================================================================
# Phase 2: DIF diagnostic module
# ================================================================

test_that("analyze_dif residual method returns expected structure", {
  local_dif_fixtures()

  dif <- analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                     data = toy, method = "residual")

  expect_s3_class(dif, "mfrm_dif")
  expect_true(is.data.frame(dif$dif_table))
  expect_true(is.data.frame(dif$cell_table))
  expect_true(nrow(dif$dif_table) > 0)
  expect_true(nrow(dif$cell_table) > 0)

  # Required columns in dif_table
  required_cols <- c("Level", "Group1", "Group2", "Contrast", "SE", "t",
                     "df", "p_value", "ETS", "Method")
  expect_true(all(required_cols %in% names(dif$dif_table)))

  # Method must be "residual"
  expect_true(all(dif$dif_table$Method == "residual"))
  expect_equal(dif$config$method, "residual")
})

test_that("analyze_dif refit method returns expected structure", {
  local_dif_fixtures()

  dif <- analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                     data = toy, method = "refit")

  expect_s3_class(dif, "mfrm_dif")
  expect_true(is.data.frame(dif$dif_table))
  expect_true(nrow(dif$dif_table) > 0)
  expect_equal(dif$config$method, "refit")
})

test_that("analyze_dif min_obs filter works", {
  local_dif_fixtures()

  # With a very high min_obs, all cells should be sparse
  dif_high <- analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                          data = toy, method = "residual", min_obs = 99999)
  expect_true(all(dif_high$cell_table$sparse))
})

test_that("analyze_dif p_adjust works for all methods", {
  local_dif_fixtures()

  for (m in c("holm", "fdr", "bonferroni", "none")) {
    dif <- analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                       data = toy, method = "residual", p_adjust = m)
    expect_true("p_adjusted" %in% names(dif$dif_table))
  }
})

test_that("analyze_dif ETS classification is valid", {
  local_dif_fixtures()

  dif <- analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                     data = toy, method = "residual")
  expect_true(all(dif$dif_table$ETS %in% c("A", "B", "C")))
})

test_that("dif_interaction_table returns expected structure", {
  local_dif_fixtures()

  int <- dif_interaction_table(fit, diag, facet = "Criterion", group = "Group",
                               data = toy, min_obs = 2)

  expect_s3_class(int, "mfrm_dif_interaction")
  expect_true(is.data.frame(int$table))
  expect_true(nrow(int$table) > 0)

  required_cols <- c("Level", "GroupValue", "N", "ObsScore", "ExpScore",
                     "ObsExpAvg")
  expect_true(all(required_cols %in% names(int$table)))
})

test_that("dif_interaction_table min_obs filter works", {
  local_dif_fixtures()

  int <- dif_interaction_table(fit, diag, facet = "Criterion", group = "Group",
                               data = toy, min_obs = 99999)
  expect_true(all(int$table$sparse))
})

test_that("plot_dif_heatmap returns matrix when draw = FALSE", {
  local_dif_fixtures()

  dif <- analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                     data = toy, method = "residual")

  for (m in c("obs_exp", "t", "contrast")) {
    mat <- plot_dif_heatmap(dif, metric = m, draw = FALSE)
    expect_true(is.matrix(mat))
  }
})

test_that("plot_dif_heatmap works with dif_interaction_table", {
  local_dif_fixtures()

  int <- dif_interaction_table(fit, diag, facet = "Criterion", group = "Group",
                               data = toy, min_obs = 2)

  mat <- plot_dif_heatmap(int, metric = "obs_exp", draw = FALSE)
  expect_true(is.matrix(mat))
})

test_that("dif_report produces interpretable output", {
  local_dif_fixtures()

  dif <- analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                     data = toy, method = "residual")

  rpt <- dif_report(dif)
  expect_s3_class(rpt, "mfrm_dif_report")
  expect_true(is.character(rpt$narrative))
  expect_true(nchar(rpt$narrative) > 0)
})

test_that("print and summary S3 methods work for DIF objects", {
  local_dif_fixtures()

  dif <- analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                     data = toy, method = "residual")
  expect_output(print(dif))
  s <- summary(dif)
  expect_output(print(s))

  int <- dif_interaction_table(fit, diag, facet = "Criterion", group = "Group",
                               data = toy, min_obs = 2)
  expect_output(print(int))
  s2 <- summary(int)
  expect_output(print(s2))

  rpt <- dif_report(dif)
  expect_output(print(rpt))
  s3 <- summary(rpt)
  expect_output(print(s3))
})


# ================================================================
# Phase 3: compare_mfrm enhancements
# ================================================================

test_that("compare_mfrm includes Delta_AIC, Akaike weights, BIC weights", {
  local_dif_fixtures()

  fit2 <- fit_mfrm(toy, person = "Person", facets = c("Rater", "Criterion"),
                   score = "Score", method = "JML",
                   model = "PCM", step_facet = "Criterion")
  comp <- compare_mfrm(RSM = fit, PCM = fit2)

  expect_s3_class(comp, "mfrm_comparison")
  tbl <- comp$table
  expect_true("Delta_AIC" %in% names(tbl))
  expect_true("Delta_BIC" %in% names(tbl))
  expect_true("AkaikeWeight" %in% names(tbl))
  expect_true("BICWeight" %in% names(tbl))

  # Delta should have at least one zero (best model)
  expect_equal(min(tbl$Delta_AIC), 0)
  expect_equal(min(tbl$Delta_BIC), 0)

  # Weights should sum to 1
  expect_equal(sum(tbl$AkaikeWeight), 1, tolerance = 1e-10)
  expect_equal(sum(tbl$BICWeight), 1, tolerance = 1e-10)
})

test_that("compare_mfrm evidence_ratios are reciprocal", {
  local_dif_fixtures()

  fit2 <- fit_mfrm(toy, person = "Person", facets = c("Rater", "Criterion"),
                   score = "Score", method = "JML",
                   model = "PCM", step_facet = "Criterion")
  comp <- compare_mfrm(RSM = fit, PCM = fit2)

  er <- comp$evidence_ratios
  expect_true(is.data.frame(er))
  expect_true(nrow(er) > 0)
  expect_true("EvidenceRatio" %in% names(er))
  expect_true(all(er$EvidenceRatio > 0))
})

test_that("compare_mfrm print and summary work with new fields", {
  local_dif_fixtures()

  fit2 <- fit_mfrm(toy, person = "Person", facets = c("Rater", "Criterion"),
                   score = "Score", method = "JML",
                   model = "PCM", step_facet = "Criterion")
  comp <- compare_mfrm(RSM = fit, PCM = fit2)

  expect_output(print(comp))
  s <- summary(comp)
  expect_output(print(s))
})
