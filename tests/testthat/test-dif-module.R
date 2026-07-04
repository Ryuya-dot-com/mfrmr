# Tests for DIF analysis module and compare_mfrm enhancements.

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
  diag <- diagnose_mfrm(fit, residual_pca = "none")

  assign("toy",  toy,  envir = env)
  assign("fit",  fit,  envir = env)
  assign("diag", diag, envir = env)
}

mh_dif_fixture <- function() {
  persons <- sprintf("P%03d", seq_len(120))
  ability <- rep(0:3, each = 30)
  group <- rep(rep(c("Reference", "Focal"), each = 15), 4)
  person_tbl <- data.frame(
    Person = persons,
    AbilityBand = ability,
    Group = group,
    stringsAsFactors = FALSE
  )
  dat <- merge(
    expand.grid(
      Person = persons,
      Item = c("Anchor1", "Anchor2", "Anchor3", "Target"),
      KEEP.OUT.ATTRS = FALSE,
      stringsAsFactors = FALSE
    ),
    person_tbl,
    by = "Person",
    all.x = TRUE
  )
  dat$Score <- with(dat, ifelse(
    Item == "Anchor1", AbilityBand >= 1,
    ifelse(
      Item == "Anchor2", AbilityBand >= 2,
      ifelse(
        Item == "Anchor3", AbilityBand >= 3,
        ifelse(Group == "Reference", AbilityBand >= 2, AbilityBand >= 3)
      )
    )
  ))
  dat$Score <- as.integer(dat$Score)
  dat[, c("Person", "Item", "Score", "Group")]
}

# ================================================================
# DIF diagnostic module
# ================================================================

test_that("analyze_dff residual method returns expected structure", {
  local_dif_fixtures()

  dif <- analyze_dff(fit, diag, facet = "Criterion", group = "Group",
                     data = toy, method = "residual")

  expect_s3_class(dif, "mfrm_dff")
  expect_s3_class(dif, "mfrm_dif")
  expect_true(is.data.frame(dif$dif_table))
  expect_true(is.data.frame(dif$cell_table))
  expect_true(nrow(dif$dif_table) > 0)
  expect_true(nrow(dif$cell_table) > 0)

  # Required columns in dif_table
  required_cols <- c("Level", "Group1", "Group2", "Contrast", "SE", "t",
                     "df", "p_value", "Classification", "ClassificationSystem",
                     "ETS", "Method", "SEBasis", "StatisticLabel",
                     "ProbabilityMetric", "DFBasis", "ContrastBasis",
                     "ReportingUse", "PrimaryReportingEligible")
  expect_true(all(required_cols %in% names(dif$dif_table)))

  # Method must be "residual"
  expect_true(all(dif$dif_table$Method == "residual"))
  expect_true(all(dif$dif_table$ClassificationSystem == "screening"))
  expect_true(all(dif$dif_table$StatisticLabel == "Welch screening t"))
  expect_true(all(dif$dif_table$DFBasis == "Welch-Satterthwaite approximation"))
  expect_true(all(is.na(dif$dif_table$ETS)))
  expect_true(all(dif$dif_table$ReportingUse == "screening_only"))
  expect_true(all(!dif$dif_table$PrimaryReportingEligible))
  expect_equal(dif$config$method, "residual")
  expect_true(isTRUE(dif$config$mfrm_fit_used))
  expect_equal(dif$config$fit_model, "RSM")
  expect_equal(dif$config$model_scope, "fitted_mfrm_rasch_family_screening")
})

test_that("analyze_dff alias is backward compatible with analyze_dif", {
  local_dif_fixtures()

  dff <- analyze_dff(fit, diag, facet = "Criterion", group = "Group",
                     data = toy, method = "residual")
  dif <- analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                     data = toy, method = "residual")

  expect_equal(dff$dif_table, dif$dif_table)
  expect_equal(dff$summary, dif$summary)
  expect_equal(dff$config$functioning_label, "DIF")
})

test_that("analyze_dif_mh returns MH screening output", {
  dat <- mh_dif_fixture()

  mh <- analyze_dif_mh(
    dat,
    person = "Person",
    item = "Item",
    score = "Score",
    group = "Group",
    reference = "Reference",
    focal = "Focal"
  )

  expect_s3_class(mh, "mfrm_mh_dif")
  expect_true(is.data.frame(mh$mh_table))
  expect_false("classical_table" %in% names(mh))
  expect_true(is.data.frame(mh$strata_table))
  expect_true(is.data.frame(mh$summary))
  expect_true(nrow(mh$mh_table) > 0)
  expect_true(all(c("Item", "ReferenceGroup", "FocalGroup", "AlphaMH",
                    "MHDDelta", "MHChiSq", "p_value", "p_adjusted",
                    "Direction", "EffectBand", "Classification",
                    "ClassificationSystem", "ReportingUse",
                    "PrimaryReportingEligible") %in%
                    names(mh$mh_table)))
  expect_true(all(mh$mh_table$Method == "mantel_haenszel"))
  expect_true(all(mh$mh_table$ClassificationSystem ==
                    "mh_observed_score_screening"))
  expect_true(all(mh$mh_table$ReportingUse == "screening_only"))
  expect_true(all(!mh$mh_table$PrimaryReportingEligible))
  expect_true(all(!mh$mh_table$MFRMFitUsed))
  expect_true(all(mh$mh_table$MFRMModel == "not_applicable"))
  expect_equal(mh$config$model_scope,
               "observed_score_mh_screen_no_mfrm_fit")
  expect_false(isTRUE(mh$config$mfrm_fit_used))

  target <- subset(mh$mh_table, Item == "Target")
  expect_equal(target$Direction, "harder_for_focal")
  expect_lt(target$MHDDelta, 0)
  expect_gt(target$AlphaMH, 1)
  expect_output(print(mh))
  expect_output(print(summary(mh)))
})

test_that("analyze_dif_mh validates person-by-item assumptions and wrapper", {
  dat <- mh_dif_fixture()

  dat_dup <- rbind(dat, dat[1, , drop = FALSE])
  expect_error(
    analyze_dif_mh(dat_dup, "Person", "Item", "Score", "Group"),
    "one response per person x item"
  )

  dat_three <- dat
  dat_three$Group[dat_three$Person %in% unique(dat_three$Person)[1:4]] <- "Other"
  expect_error(
    analyze_dif_mh(dat_three, "Person", "Item", "Score", "Group"),
    "exactly two group levels"
  )

  dat_poly <- dat
  dat_poly$Score <- ifelse(dat_poly$Score == 1, 2, 0)
  dat_poly$Score[dat_poly$Item == "Anchor1" & dat_poly$Score == 2] <- 1
  expect_error(
    analyze_dif_mh(dat_poly, "Person", "Item", "Score", "Group"),
    "exactly two numeric levels"
  )
  mh_poly <- analyze_dif_mh(
    dat_poly, "Person", "Item", "Score", "Group", dichotomize = 1
  )
  mh_wrapper <- analyze_dif_classical(
    dat_poly, "Person", "Item", "Score", "Group", dichotomize = 1
  )
  expect_s3_class(mh_poly, "mfrm_mh_dif")
  expect_false(inherits(mh_poly, "mfrm_classical_dif"))
  expect_false("classical_table" %in% names(mh_poly))
  expect_s3_class(mh_wrapper, "mfrm_classical_dif")
  expect_s3_class(mh_wrapper, "mfrm_mh_dif")
  expect_equal(mh_wrapper$classical_table, mh_poly$mh_table)
  expect_equal(mh_wrapper$mh_table, mh_poly$mh_table)
  expect_match(mh_poly$config$score_transform, "dichotomized")
})

test_that("analyze_dif refit keeps JML contrasts descriptive even when linked", {
  local_dif_fixtures()

  dif <- analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                     data = toy, method = "refit")

  expect_s3_class(dif, "mfrm_dif")
  expect_true(is.data.frame(dif$dif_table))
  expect_true(nrow(dif$dif_table) > 0)
  expect_true(all(c("ContrastComparable", "ScaleLinkStatus", "LinkingFacets",
                    "FormalInferenceEligible", "InferenceTier",
                    "ReportingUse", "PrimaryReportingEligible",
                    "BaselineConverged", "SubgroupConverged1", "SubgroupConverged2",
                    "BaselineMethod", "BaselinePrecisionTier",
                    "BaselineSupportsFormalInference") %in% names(dif$dif_table)))
  expect_true(all(c("LinkingStatus", "LinkingDetail", "ETS_Eligible",
                    "LinkComparable", "PrecisionTier", "SupportsFormalInference") %in% names(dif$group_fits[[1]])))
  expect_true("Converged" %in% names(dif$group_fits[[1]]))
  expect_true(all(dif$dif_table$ClassificationSystem == "descriptive"))
  expect_true(all(dif$dif_table$StatisticLabel == "linked descriptive contrast"))
  expect_true(all(dif$dif_table$SEBasis == "not reported without model-based subgroup precision"))
  expect_true(all(is.na(dif$dif_table$ETS)))
  expect_true(all(dif$dif_table$ContrastComparable))
  expect_true(all(!dif$dif_table$FormalInferenceEligible))
  expect_true(all(!dif$dif_table$PrimaryReportingEligible))
  expect_true(all(dif$dif_table$InferenceTier == "exploratory"))
  expect_true(all(dif$dif_table$ScaleLinkStatus == "linked"))
  expect_true(all(dif$dif_table$ReportingUse == "screening_only"))
  expect_equal(dif$config$method, "refit")
})

test_that("analyze_dif refit surfaces subgroup diagnostics failures", {
  local_dif_fixtures()

  testthat::local_mocked_bindings(
    diagnose_mfrm = function(...) stop("forced subgroup diagnostics failure"),
    .package = "mfrmr"
  )

  dif <- analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                     data = toy, method = "refit")

  group_fit_tbl <- dif$group_fits[[1]]
  expect_true(all(c("DiagnosticsStatus", "DiagnosticsDetail") %in% names(group_fit_tbl)))
  expect_true(all(group_fit_tbl$DiagnosticsStatus == "failed"))
  expect_true(all(group_fit_tbl$PrecisionTier == "diagnostics_unavailable"))
  expect_true(all(grepl("forced subgroup diagnostics failure", group_fit_tbl$DiagnosticsDetail, fixed = TRUE)))
})

test_that("analyze_dif refit uses ETS only for linked model-based MML contrasts", {
  dat <- mfrmr:::sample_mfrm_data(seed = 42)
  persons <- unique(dat$Person)
  half <- ceiling(length(persons) / 2)
  grp_map <- setNames(
    c(rep("A", half), rep("B", length(persons) - half)),
    persons
  )
  dat$Group <- grp_map[dat$Person]

  fit_mml <- suppressWarnings(fit_mfrm(
    dat,
    person = "Person",
    facets = c("Rater", "Task", "Criterion"),
    score = "Score",
    method = "MML",
    quad_points = 7,
    maxit = 25
  ))
  diag_mml <- diagnose_mfrm(fit_mml, residual_pca = "none")
  dif_mml <- analyze_dif(
    fit_mml,
    diag_mml,
    facet = "Criterion",
    group = "Group",
    data = dat,
    method = "refit"
  )

  expect_true(any(dif_mml$dif_table$ClassificationSystem == "ETS"))
  ets_rows <- dif_mml$dif_table$ClassificationSystem == "ETS"
  expect_true(all(dif_mml$dif_table$ContrastComparable[ets_rows]))
  expect_true(all(dif_mml$dif_table$FormalInferenceEligible[ets_rows]))
  expect_true(all(dif_mml$dif_table$PrimaryReportingEligible[ets_rows]))
  expect_true(all(dif_mml$dif_table$InferenceTier[ets_rows] == "model_based"))
  expect_true(all(dif_mml$dif_table$ReportingUse[ets_rows] == "primary_reporting"))
  expect_true(all(stats::na.omit(dif_mml$dif_table$ETS) %in% c("A", "B", "C")))
})

test_that("analyze_dif refit demotes ETS when subgroup refits lack linking facets", {
  local_dif_fixtures()

  fit_one <- fit_mfrm(toy, person = "Person", facets = "Criterion",
                      score = "Score", method = "JML", maxit = 20)
  diag_one <- diagnose_mfrm(fit_one, residual_pca = "none")
  dif_one <- analyze_dif(fit_one, diag_one, facet = "Criterion", group = "Group",
                         data = toy, method = "refit")

  expect_true(all(dif_one$dif_table$ClassificationSystem == "descriptive"))
  expect_true(all(is.na(dif_one$dif_table$ETS)))
  expect_true(all(dif_one$dif_table$ScaleLinkStatus == "unlinked"))
  expect_true(all(!dif_one$dif_table$ContrastComparable))
  expect_match(dif_one$summary$Classification[nrow(dif_one$summary)], "insufficient linking", ignore.case = TRUE)
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

test_that("analyze_dif validates DFF control arguments", {
  local_dif_fixtures()

  expect_error(
    analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                data = toy, method = "residual", p_adjust = "not_a_method"),
    "`p_adjust`"
  )
  expect_error(
    analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                data = toy, method = "residual", min_obs = 1.5),
    "`min_obs`"
  )
  expect_error(
    analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                data = toy, method = "residual", focal = "MissingGroup"),
    "not found"
  )
  expect_error(
    analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                data = toy, method = "residual", focal = unique(toy$Group)),
    "reference group"
  )

  toy_numeric <- toy
  toy_numeric$AgeLike <- seq_len(nrow(toy_numeric))
  expect_error(
    analyze_dif(fit, diag, facet = "Criterion", group = "AgeLike",
                data = toy_numeric, method = "residual"),
    "continuous-covariate"
  )
})

test_that("analyze_dff_moderation screens continuous person covariates", {
  local_dif_fixtures()
  person_age <- data.frame(
    Person = unique(toy$Person),
    AgeLike = seq_along(unique(toy$Person)),
    stringsAsFactors = FALSE
  )
  toy_age <- merge(toy, person_age, by = "Person", all.x = TRUE)

  mod <- analyze_dff_moderation(
    fit,
    facet = "Criterion",
    covariate = "AgeLike",
    data = toy_age,
    min_obs = 2
  )

  expect_s3_class(mod, "mfrm_dff_moderation")
  expect_s3_class(mod, "mfrm_dif_moderation")
  expect_true(is.data.frame(mod$moderation_table))
  expect_true(is.data.frame(mod$summary))
  expect_true(nrow(mod$moderation_table) > 0)
  expect_true(all(c("Level", "Slope", "SE", "z", "p_value", "p_adjusted",
                    "RawSlope", "RawSE", "ModerationDirection", "N",
                    "Persons", "CovariateDistinct", "Classification",
                    "ClassificationSystem", "ReportingUse",
                    "PrimaryReportingEligible") %in%
                    names(mod$moderation_table)))
  expect_true(all(mod$moderation_table$Method == "residual_moderation"))
  expect_true(all(mod$moderation_table$ClassificationSystem == "screening"))
  expect_true(all(mod$moderation_table$ReportingUse == "screening_only"))
  expect_true(all(!mod$moderation_table$PrimaryReportingEligible))
  expect_true(isTRUE(mod$config$mfrm_fit_used))
  expect_equal(mod$config$fit_model, "RSM")
  expect_equal(mod$config$model_scope, "fitted_mfrm_rasch_family_screening")
  expect_equal(mod$config$covariate, "AgeLike")
  expect_equal(mod$config$covariate_scale, "standardized_1_sd")
  rpt_mod <- dif_report(mod, style = "apa")
  expect_s3_class(rpt_mod, "mfrm_dif_report")
  expect_match(rpt_mod$narrative, "continuous-covariate")
  expect_match(rpt_mod$narrative, "not as a categorical MH DIF test")
  expect_true(is.data.frame(rpt_mod$apa_table))
  expect_true(all(c("Level", "Slope", "z", "p_value", "p_adjusted",
                    "Classification") %in% names(rpt_mod$apa_table)))
  tbl_mod <- apa_table(mod)
  expect_s3_class(tbl_mod, "apa_table")
  expect_equal(nrow(tbl_mod$table), nrow(mod$moderation_table))

  mod_raw <- analyze_dif_moderation(
    fit,
    facet = "Criterion",
    covariate = "AgeLike",
    data = toy_age,
    min_obs = 2,
    standardize = FALSE
  )
  expect_s3_class(mod_raw, "mfrm_dff_moderation")
  expect_equal(mod_raw$config$covariate_scale, "raw_unit")
  expect_output(print(mod))
  expect_output(print(summary(mod)))
})

test_that("analyze_dff_moderation validates continuous-covariate contract", {
  local_dif_fixtures()
  toy_bad <- toy
  toy_bad$AgeLike <- as.character(seq_len(nrow(toy_bad)))
  expect_error(
    analyze_dff_moderation(fit, facet = "Criterion",
                           covariate = "AgeLike", data = toy_bad),
    "must be numeric"
  )

  toy_conflict <- toy
  toy_conflict$AgeLike <- ave(seq_len(nrow(toy_conflict)), toy_conflict$Person,
                              FUN = seq_along)
  expect_error(
    analyze_dff_moderation(fit, facet = "Criterion",
                           covariate = "AgeLike", data = toy_conflict),
    "person-level"
  )

  person_two <- data.frame(
    Person = unique(toy$Person),
    AgeLike = rep(1:2, length.out = length(unique(toy$Person))),
    stringsAsFactors = FALSE
  )
  toy_two <- merge(toy, person_two, by = "Person", all.x = TRUE)
  expect_error(
    analyze_dff_moderation(fit, facet = "Criterion",
                           covariate = "AgeLike", data = toy_two),
    "at least three distinct"
  )
})

test_that("analyze_dff_moderation carries bounded GPCM caveat boundary", {
  dat <- simulate_mfrm_data(
    n_person = 30,
    n_rater = 3,
    n_criterion = 3,
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    slopes = data.frame(
      SlopeFacet = paste0("C0", 1:3),
      Estimate = c(0.80, 1.00, 1.25),
      stringsAsFactors = FALSE
    ),
    seed = 303
  )
  persons <- sort(unique(as.character(dat$Person)))
  dat$AgeLike <- match(as.character(dat$Person), persons)
  fit_gpcm <- suppressWarnings(fit_mfrm(
    dat,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    method = "MML",
    quad_points = 5,
    maxit = 20
  ))

  mod <- analyze_dff_moderation(
    fit_gpcm,
    facet = "Criterion",
    covariate = "AgeLike",
    data = dat,
    min_obs = 3
  )

  expect_equal(mod$config$model_scope,
               "fitted_mfrm_bounded_gpcm_screening_with_caveat")
  expect_true(is.data.frame(mod$gpcm_boundary))
  expect_gt(nrow(mod$gpcm_boundary), 0L)
  expect_true(any(mod$gpcm_boundary$Status == "supported_with_caveat"))
  expect_match(mod$gpcm_boundary$Area[1], "Differential facet functioning")
})

test_that("analyze_dif handles missing and empty group values explicitly", {
  local_dif_fixtures()
  toy_bad <- toy
  toy_bad$Group[1] <- NA_character_
  toy_bad$Group[2] <- " "

  expect_message(
    dif <- analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                       data = toy_bad, method = "residual"),
    "Dropped 2 row"
  )
  expect_false(anyNA(dif$cell_table$GroupValue))
  expect_false(any(dif$cell_table$GroupValue == ""))

  toy_empty <- toy
  toy_empty$Group <- NA_character_
  expect_error(
    analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                data = toy_empty, method = "residual"),
    "no non-missing"
  )
})

test_that("residual method uses screening labels instead of ETS categories", {
  local_dif_fixtures()

  dif <- analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                     data = toy, method = "residual")
  expect_true(all(dif$summary$Classification %in% c("Screen positive", "Screen negative", "Unclassified")))
  expect_true(all(is.na(dif$dif_table$ETS)))
})

test_that("residual method uses Welch-Satterthwaite degrees of freedom", {
  local_dif_fixtures()

  dif <- analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                     data = toy, method = "residual")
  first_row <- dif$dif_table[1, , drop = FALSE]
  c1 <- subset(dif$cell_table, Level == first_row$Level & GroupValue == first_row$Group1)
  c2 <- subset(dif$cell_table, Level == first_row$Level & GroupValue == first_row$Group2)
  comp1 <- c1$Var_sum[1] / c1$N[1]^2
  comp2 <- c2$Var_sum[1] / c2$N[1]^2
  expected_df <- (comp1 + comp2)^2 / ((comp1^2) / (c1$N[1] - 1) + (comp2^2) / (c2$N[1] - 1))

  expect_equal(first_row$df, expected_df, tolerance = 1e-8)
})

test_that("refit method ETS classification is valid", {
  dat <- mfrmr:::sample_mfrm_data(seed = 99)
  dat$Group <- ifelse(dat$Person %in% unique(dat$Person)[1:30], "A", "B")
  fit_mml <- suppressWarnings(fit_mfrm(
    dat,
    person = "Person",
    facets = c("Rater", "Task", "Criterion"),
    score = "Score",
    method = "MML",
    quad_points = 7,
    maxit = 25
  ))
  diag_mml <- diagnose_mfrm(fit_mml, residual_pca = "none")
  dif <- analyze_dif(fit_mml, diag_mml, facet = "Criterion", group = "Group",
                     data = dat, method = "refit")
  expect_true(all(stats::na.omit(dif$dif_table$ETS) %in% c("A", "B", "C")))
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

test_that("dif_interaction_table validates controls and group missingness", {
  local_dif_fixtures()

  expect_error(
    dif_interaction_table(fit, diag, facet = "Criterion", group = "Group",
                          data = toy, p_adjust = "not_a_method"),
    "`p_adjust`"
  )
  expect_error(
    dif_interaction_table(fit, diag, facet = "Criterion", group = "Group",
                          data = toy, min_obs = 2.5),
    "`min_obs`"
  )
  expect_error(
    dif_interaction_table(fit, diag, facet = "Criterion", group = "Group",
                          data = toy, abs_t_warn = Inf),
    "`abs_t_warn`"
  )

  toy_bad <- toy
  toy_bad$Group[1] <- NA_character_
  expect_message(
    int <- dif_interaction_table(fit, diag, facet = "Criterion",
                                 group = "Group", data = toy_bad,
                                 min_obs = 2),
    "Dropped 1 row"
  )
  expect_false(anyNA(int$table$GroupValue))
})

test_that("plot_dif_heatmap returns mfrm_plot_data with matrix payload (draw = FALSE)", {
  local_dif_fixtures()

  dif <- analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                     data = toy, method = "residual")

  for (m in c("obs_exp", "t", "contrast")) {
    p <- plot_dif_heatmap(dif, metric = m, draw = FALSE)
    expect_s3_class(p, "mfrm_plot_data")
    expect_true(is.matrix(p$data$matrix))
    expect_identical(p$data$metric, m)
    if (identical(m, "contrast")) {
      expect_false(isTRUE(p$data$ets_display_eligible))
      expect_equal(p$data$classification_system, "screening")
    }
  }
})

test_that("plot_dif_heatmap supports interpretive display controls", {
  local_dif_fixtures()

  dif <- analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                     data = toy, method = "residual")
  p <- plot_dif_heatmap(dif, metric = "t", draw = FALSE,
                        show_values = FALSE, value_digits = 1,
                        flag_threshold = 2, scale_limit = 3)

  expect_s3_class(p, "mfrm_plot_data")
  expect_true(is.matrix(p$data$flag_matrix))
  expect_identical(dim(p$data$flag_matrix), dim(p$data$matrix))
  expect_equal(p$data$thresholds$Threshold, 2)
  expect_equal(p$data$settings$scale_limit, 3)
  expect_true(is.data.frame(p$data$interpretation_guide))

  expect_error(plot_dif_heatmap(dif, draw = FALSE, show_values = NA),
               "`show_values`")
  expect_error(plot_dif_heatmap(dif, draw = FALSE, value_digits = -1),
               "`value_digits`")
  expect_error(plot_dif_heatmap(dif, draw = FALSE, flag_threshold = -0.1),
               "`flag_threshold`")
  expect_error(plot_dif_heatmap(dif, draw = FALSE, scale_limit = 0),
               "`scale_limit`")
})

test_that("plot_dif_heatmap works with dif_interaction_table", {
  local_dif_fixtures()

  int <- dif_interaction_table(fit, diag, facet = "Criterion", group = "Group",
                               data = toy, min_obs = 2)

  p <- plot_dif_heatmap(int, metric = "obs_exp", draw = FALSE)
  expect_s3_class(p, "mfrm_plot_data")
  expect_true(is.matrix(p$data$matrix))
})

test_that("dif_report produces interpretable output", {
  local_dif_fixtures()

  dif <- analyze_dif(fit, diag, facet = "Criterion", group = "Group",
                     data = toy, method = "residual")

  rpt <- dif_report(dif)
  expect_s3_class(rpt, "mfrm_dif_report")
  expect_true(is.character(rpt$narrative))
  expect_true(nchar(rpt$narrative) > 0)
  expect_match(rpt$narrative, "screening", ignore.case = TRUE)

  rpt_apa <- dif_report(dif, style = "apa")
  expect_s3_class(rpt_apa, "mfrm_dif_report")
  expect_match(rpt_apa$narrative, "Differential functioning")
  expect_match(rpt_apa$narrative, "adjusted p")
  expect_true(is.data.frame(rpt_apa$apa_table))
  expect_gt(nrow(rpt_apa$apa_table), 0)
  expect_true(all(c("Level", "Group1", "Group2", "Contrast",
                    "p_value", "p_adjusted", "Classification",
                    "ReportingUse", "PrimaryReportingEligible") %in%
                    names(rpt_apa$apa_table)))
  expect_match(rpt_apa$apa_note, "Screening evidence")
  expect_match(rpt_apa$apa_note, "measurement bias")

  tbl_from_report <- apa_table(rpt_apa)
  expect_s3_class(tbl_from_report, "apa_table")
  expect_equal(nrow(tbl_from_report$table), nrow(rpt_apa$apa_table))
  expect_match(tbl_from_report$note, "Screening evidence")

  tbl_from_result <- apa_table(dif)
  expect_s3_class(tbl_from_result, "apa_table")
  expect_equal(nrow(tbl_from_result$table), nrow(dif$dif_table))
  expect_equal(tbl_from_result$digits, 3)

  apa <- build_apa_outputs(fit, diag, dif_results = dif)
  expect_s3_class(apa, "mfrm_apa_outputs")
  expect_s3_class(apa$dif_report, "mfrm_dif_report")
  expect_true("results_differential_functioning" %in% apa$section_map$SectionId)
  expect_match(as.character(apa$report_text), "Differential functioning")
  expect_match(apa$table_figure_notes, "Differential-functioning note")
})

test_that("dif_report provides APA boundaries for observed-score MH DIF", {
  dat <- mh_dif_fixture()
  mh <- analyze_dif_mh(
    dat,
    person = "Person",
    item = "Item",
    score = "Score",
    group = "Group",
    reference = "Reference",
    focal = "Focal"
  )

  rpt <- dif_report(mh, style = "apa")
  expect_s3_class(rpt, "mfrm_dif_report")
  expect_match(rpt$narrative, "observed-score Mantel-Haenszel DIF",
               ignore.case = TRUE)
  expect_match(rpt$narrative, "not as fitted-MFRM")
  expect_true(is.data.frame(rpt$apa_table))
  expect_true(all(c("Item", "AlphaMH", "MHDDelta", "MHChiSq",
                    "p_value", "p_adjusted", "MFRMFitUsed") %in%
                    names(rpt$apa_table)))
  expect_true(all(!rpt$apa_table$MFRMFitUsed))
  expect_match(rpt$apa_note, "do not use a fitted MFRM")

  tbl <- apa_table(mh)
  expect_s3_class(tbl, "apa_table")
  expect_match(tbl$caption, "Mantel-Haenszel")
  expect_equal(nrow(tbl$table), nrow(mh$mh_table))
  expect_equal(tbl$digits, 3)
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
# compare_mfrm enhancements
# ================================================================

test_that("compare_mfrm reports comparable IC quantities on a common basis", {
  toy_small <- load_mfrmr_data("example_core")

  fit_rsm <- suppressWarnings(fit_mfrm(
    toy_small,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "MML",
    model = "RSM",
    quad_points = 5,
    maxit = 15
  ))
  fit_pcm <- suppressWarnings(fit_mfrm(
    toy_small,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "MML",
    model = "PCM",
    step_facet = "Criterion",
    quad_points = 5,
    maxit = 15
  ))
  fit_rsm$summary$Converged[1] <- TRUE
  fit_pcm$summary$Converged[1] <- TRUE

  comp <- compare_mfrm(RSM = fit_rsm, PCM = fit_pcm)

  expect_s3_class(comp, "mfrm_comparison")
  tbl <- comp$table
  expect_true(all(tbl$ICComparable))
  expect_true("Delta_AIC" %in% names(tbl))
  expect_true("Delta_BIC" %in% names(tbl))
  expect_true("AkaikeWeight" %in% names(tbl))
  expect_true("BICWeight" %in% names(tbl))
  expect_true(all(c("WeightedN", "ICSampleSize", "ICSampleSizeBasis") %in% names(tbl)))
  expect_true(all(c(
    "ComparisonFamily", "ComparisonStrength", "InterpretationGuard"
  ) %in% names(tbl)))
  expect_equal(tbl$WeightedN, as.numeric(tbl$nobs))
  expect_equal(tbl$ICSampleSize, as.numeric(tbl$nobs))
  expect_equal(tbl$ICSampleSizeBasis, rep("row_count", nrow(tbl)))

  # Delta should have at least one zero (best model)
  expect_equal(min(tbl$Delta_AIC), 0)
  expect_equal(min(tbl$Delta_BIC), 0)

  # Weights should sum to 1
  expect_equal(sum(tbl$AkaikeWeight), 1, tolerance = 1e-10)
  expect_equal(sum(tbl$BICWeight), 1, tolerance = 1e-10)
  expect_true(isTRUE(comp$comparison_basis$ic_comparable))
  expect_true(isTRUE(comp$comparison_basis$same_data))
  expect_identical(comp$comparison_basis$comparison_family, "response_model_choice")
  expect_identical(comp$comparison_basis$comparison_strength, "formal_mml_ic_available")
  expect_s3_class(comp$comparison_guidance, "data.frame")
  expect_identical(as.character(comp$comparison_guidance$ComparisonFamily[1]), "response_model_choice")

  fit_rsm_w <- fit_rsm
  fit_pcm_w <- fit_pcm
  w <- rep(c(1, 2), length.out = nrow(fit_rsm_w$prep$data))
  fit_rsm_w$config$weight_col <- "Weight"
  fit_pcm_w$config$weight_col <- "Weight"
  fit_rsm_w$prep$data$Weight <- w
  fit_pcm_w$prep$data$Weight <- w
  fit_rsm_w$summary$N[1] <- sum(w)
  fit_pcm_w$summary$N[1] <- sum(w)
  comp_w <- compare_mfrm(RSM = fit_rsm_w, PCM = fit_pcm_w)
  expect_equal(comp_w$table$WeightedN, rep(sum(w), nrow(comp_w$table)))
  expect_equal(comp_w$table$ICSampleSize, rep(sum(w), nrow(comp_w$table)))
  expect_equal(comp_w$table$ICSampleSizeBasis, rep("sum_weights", nrow(comp_w$table)))

  comp_lrt <- compare_mfrm(RSM = fit_rsm, PCM = fit_pcm, nested = TRUE)
  n_steps <- fit_rsm$config$n_cat - 1L
  step_levels <- length(fit_pcm$config$facet_levels[[fit_pcm$config$step_facet]])
  expected_df <- (step_levels - 1L) * max(n_steps - 1L, 0L)
  expect_s3_class(comp_lrt, "mfrm_comparison")
  expect_true(isTRUE(comp_lrt$comparison_basis$nesting_review$eligible))
  expect_identical(as.character(comp_lrt$comparison_basis$nesting_review$relation), "RSM_in_PCM")
  expect_equal(comp_lrt$lrt$df, expected_df)
  expect_equal(
    diff(range(comp_lrt$table$npar)),
    expected_df
  )
})

test_that("compare_mfrm evidence_ratios are reciprocal", {
  toy_small <- load_mfrmr_data("example_core")

  fit_rsm <- suppressWarnings(fit_mfrm(
    toy_small,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "MML",
    model = "RSM",
    quad_points = 5,
    maxit = 15
  ))
  fit_pcm <- suppressWarnings(fit_mfrm(
    toy_small,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "MML",
    model = "PCM",
    step_facet = "Criterion",
    quad_points = 5,
    maxit = 15
  ))
  fit_rsm$summary$Converged[1] <- TRUE
  fit_pcm$summary$Converged[1] <- TRUE

  comp <- compare_mfrm(RSM = fit_rsm, PCM = fit_pcm)

  er <- comp$evidence_ratios
  expect_true(is.data.frame(er))
  expect_true(nrow(er) > 0)
  expect_true("EvidenceRatio" %in% names(er))
  expect_true(all(er$EvidenceRatio > 0))
})

test_that("compare_mfrm print and summary work with new fields", {
  toy_small <- load_mfrmr_data("example_core")

  fit_rsm <- suppressWarnings(fit_mfrm(
    toy_small,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "MML",
    model = "RSM",
    quad_points = 5,
    maxit = 15
  ))
  fit_pcm <- suppressWarnings(fit_mfrm(
    toy_small,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "MML",
    model = "PCM",
    step_facet = "Criterion",
    quad_points = 5,
    maxit = 15
  ))
  fit_rsm$summary$Converged[1] <- TRUE
  fit_pcm$summary$Converged[1] <- TRUE

  comp <- compare_mfrm(RSM = fit_rsm, PCM = fit_pcm)

  expect_output(print(comp))
  s <- summary(comp)
  expect_true("comparison_guidance" %in% names(s))
  expect_identical(as.character(s$comparison_guidance$ComparisonFamily[1]), "response_model_choice")
  expect_output(print(s))
})

test_that("compare_mfrm suppresses IC ranking outside the formal MML path and requires nested = TRUE for LRT", {
  toy_small <- load_mfrmr_data("example_core")

  fit_jml <- suppressWarnings(fit_mfrm(
    toy_small,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "JML",
    model = "RSM",
    maxit = 15
  ))
  fit_mml <- suppressWarnings(fit_mfrm(
    toy_small,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "MML",
    model = "RSM",
    quad_points = 5,
    maxit = 15
  ))
  fit_jml$summary$Converged[1] <- TRUE
  fit_mml$summary$Converged[1] <- TRUE

  expect_warning(
    comp <- compare_mfrm(JML = fit_jml, MML = fit_mml),
    "different estimation methods"
  )

  expect_false(isTRUE(comp$comparison_basis$ic_comparable))
  expect_true(all(is.na(comp$table$Delta_AIC)))
  expect_true(all(is.na(comp$table$AkaikeWeight)))
  expect_null(comp$lrt)

  fit_pcm <- suppressWarnings(fit_mfrm(
    toy_small,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "JML",
    model = "PCM",
    step_facet = "Criterion",
    maxit = 15
  ))
  fit_pcm$summary$Converged[1] <- TRUE

  expect_warning(
    comp_no_lrt <- compare_mfrm(RSM = fit_jml, PCM = fit_pcm),
    "limited to converged MML fits"
  )
  expect_null(comp_no_lrt$lrt)

  expect_warning(
    comp_lrt <- compare_mfrm(RSM = fit_jml, PCM = fit_pcm, nested = TRUE),
    "formal MML likelihood basis"
  )
  expect_true(isTRUE(comp_lrt$comparison_basis$nested_requested))
  expect_null(comp_lrt$lrt)
  expect_identical(comp_lrt$comparison_basis$lrt_status, "not_computed")
  expect_match(comp_lrt$comparison_basis$lrt_reason, "formal MML likelihood basis")
  expect_true(isTRUE(comp_lrt$comparison_basis$nesting_review$eligible))
  expect_identical(as.character(comp_lrt$comparison_basis$nesting_review$relation), "RSM_in_PCM")

  fit_rsm_2 <- suppressWarnings(fit_mfrm(
    toy_small,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "JML",
    model = "RSM",
    maxit = 15
  ))
  fit_rsm_2$summary$Converged[1] <- TRUE

  expect_warning(
    comp_same <- compare_mfrm(RSM1 = fit_jml, RSM2 = fit_rsm_2, nested = TRUE),
    "formal MML likelihood basis"
  )
  expect_null(comp_same$lrt)
  expect_identical(comp_same$comparison_basis$lrt_status, "not_computed")
  expect_match(comp_same$comparison_basis$lrt_reason, "formal MML likelihood basis")
  expect_false(isTRUE(comp_same$comparison_basis$ic_comparable))
  expect_false(isTRUE(comp_same$comparison_basis$nesting_review$eligible))
  expect_identical(as.character(comp_same$comparison_basis$nesting_review$relation), "same_model")
})

test_that("compare_mfrm records why boundary LRTs are not reported", {
  toy_small <- load_mfrmr_data("example_core")

  fit_rsm <- suppressWarnings(fit_mfrm(
    toy_small,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "MML",
    model = "RSM",
    quad_points = 5,
    maxit = 15
  ))
  fit_pcm <- suppressWarnings(fit_mfrm(
    toy_small,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "MML",
    model = "PCM",
    step_facet = "Criterion",
    quad_points = 5,
    maxit = 15
  ))
  fit_rsm$summary$Converged[1] <- TRUE
  fit_pcm$summary$Converged[1] <- TRUE

  fit_pcm_worse <- fit_pcm
  fit_pcm_worse$summary$LogLik[1] <- fit_rsm$summary$LogLik[1] - 1
  fit_pcm_worse$summary$AIC[1] <- 2 * length(fit_pcm_worse$opt$par) -
    2 * fit_pcm_worse$summary$LogLik[1]
  fit_pcm_worse$summary$BIC[1] <- log(nrow(fit_pcm_worse$prep$data)) *
    length(fit_pcm_worse$opt$par) - 2 * fit_pcm_worse$summary$LogLik[1]

  expect_warning(
    comp_neg <- compare_mfrm(RSM = fit_rsm, PCM = fit_pcm_worse, nested = TRUE),
    "not interpretable"
  )
  expect_null(comp_neg$lrt)
  expect_identical(comp_neg$comparison_basis$lrt_status, "not_computed")
  expect_match(comp_neg$comparison_basis$lrt_reason, "negative likelihood-ratio statistic")
  expect_output(print(summary(comp_neg)), "LRT status")

  fit_pcm_bad <- fit_pcm
  fit_pcm_bad$summary$LogLik[1] <- NA_real_
  fit_pcm_bad$summary$AIC[1] <- NA_real_
  fit_pcm_bad$summary$BIC[1] <- NA_real_

  expect_warning(
    comp_na <- compare_mfrm(RSM = fit_rsm, PCM = fit_pcm_bad, nested = TRUE),
    "non-finite"
  )
  expect_null(comp_na$lrt)
  expect_identical(comp_na$comparison_basis$lrt_status, "not_computed")
  expect_match(comp_na$comparison_basis$lrt_reason, "non-finite")
})

test_that("compare_mfrm suppresses IC ranking for JML-only comparisons", {
  local_dif_fixtures()

  fit2 <- fit_mfrm(toy, person = "Person", facets = c("Rater", "Criterion"),
                   score = "Score", method = "JML",
                   model = "PCM", step_facet = "Criterion")
  fit$summary$Converged[1] <- TRUE
  fit2$summary$Converged[1] <- TRUE

  expect_warning(
    comp <- compare_mfrm(RSM = fit, PCM = fit2),
    "limited to converged MML fits"
  )

  expect_false(isTRUE(comp$comparison_basis$ic_comparable))
  expect_false(isTRUE(comp$comparison_basis$all_mml))
  expect_true(all(is.na(comp$table$Delta_AIC)))
  expect_true(all(is.na(comp$table$AkaikeWeight)))
  expect_null(comp$evidence_ratios)
})

test_that("compare_mfrm suppresses IC ranking when a fit is marked unconverged", {
  local_dif_fixtures()

  fit2 <- fit_mfrm(toy, person = "Person", facets = c("Rater", "Criterion"),
                   score = "Score", method = "JML",
                   model = "PCM", step_facet = "Criterion")
  fit2$summary$Converged[1] <- FALSE

  expect_warning(
    comp <- compare_mfrm(RSM = fit, PCM = fit2),
    "did not converge"
  )

  expect_false(isTRUE(comp$comparison_basis$ic_comparable))
  expect_false(isTRUE(comp$comparison_basis$all_converged))
  expect_true(all(is.na(comp$table$Delta_AIC)))
  expect_true(all(is.na(comp$table$AkaikeWeight)))
})

test_that("compare_mfrm requires the same prepared response data for IC ranking", {
  toy_small <- load_mfrmr_data("example_core")

  fit_a <- suppressWarnings(fit_mfrm(
    toy_small,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "MML",
    model = "RSM",
    quad_points = 5,
    maxit = 15
  ))
  fit_a$summary$Converged[1] <- TRUE

  toy_perm <- toy_small[sample.int(nrow(toy_small)), , drop = FALSE]
  fit_perm <- suppressWarnings(fit_mfrm(
    toy_perm,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "MML",
    model = "RSM",
    quad_points = 5,
    maxit = 15
  ))
  fit_perm$summary$Converged[1] <- TRUE

  comp_same <- compare_mfrm(RSM1 = fit_a, RSM2 = fit_perm)
  expect_true(isTRUE(comp_same$comparison_basis$same_data))
  expect_true(all(comp_same$table$ICComparable))

  toy_shuf <- toy_small
  toy_shuf$Score <- sample(toy_shuf$Score)
  fit_shuf <- suppressWarnings(fit_mfrm(
    toy_shuf,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "MML",
    model = "RSM",
    quad_points = 5,
    maxit = 15
  ))
  fit_shuf$summary$Converged[1] <- TRUE

  expect_warning(
    comp_diff <- compare_mfrm(A = fit_a, B = fit_shuf),
    "same prepared response data"
  )
  expect_false(isTRUE(comp_diff$comparison_basis$same_data))
  expect_false(any(comp_diff$table$ICComparable))
  expect_true(all(is.na(comp_diff$table$Delta_AIC)))
  expect_true(all(is.na(comp_diff$table$AkaikeWeight)))
})
