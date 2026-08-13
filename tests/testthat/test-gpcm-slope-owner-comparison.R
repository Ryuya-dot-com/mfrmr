test_that("bounded GPCM assigns level-specific slopes to exactly one facet", {
  facets <- c("Rater", "Task", "Criterion")

  criterion <- mfrmr:::resolve_step_and_slope_facets(
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    facet_names = facets
  )
  expect_identical(criterion$step_facet, "Criterion")
  expect_identical(criterion$slope_facet, "Criterion")

  rater <- mfrmr:::resolve_step_and_slope_facets(
    model = "GPCM",
    step_facet = "Rater",
    slope_facet = "Rater",
    facet_names = facets
  )
  expect_identical(rater$step_facet, "Rater")
  expect_identical(rater$slope_facet, "Rater")

  expect_error(
    mfrmr:::resolve_step_and_slope_facets(
      model = "GPCM",
      step_facet = "Criterion",
      slope_facet = "Rater",
      facet_names = facets
    ),
    "slope_facet == step_facet",
    fixed = TRUE
  )

  criterion_levels <- c("Content", "Organization", "Language")
  expect_identical(
    mfrmr:::sum_zero_param_count(length(criterion_levels)),
    2L
  )
  log_slopes <- mfrmr:::expand_sum_zero_vector(c(log(1.2), log(0.8)), 3L)
  slopes <- exp(log_slopes)
  expect_length(slopes, length(criterion_levels))
  expect_true(all(slopes > 0))
  expect_equal(exp(mean(log(slopes))), 1, tolerance = 1e-15)
})

test_that("PCM versus aligned GPCM records IC-only nesting scope", {
  make_signature_fit <- function(model,
                                 step_facet,
                                 slope_facet = NULL) {
    list(
      config = list(
        model = model,
        method = "MML",
        person_col = "Person",
        facet_cols = c("Rater", "Criterion"),
        score_col = "Score",
        rating_min = 0,
        rating_max = 3,
        score_map = data.frame(
          OriginalScore = 0:3,
          InternalScore = 0:3
        ),
        weight_col = NULL,
        step_facet = step_facet,
        slope_facet = slope_facet,
        facet_interactions = character(0),
        noncenter_facet = "Person",
        dummy_facets = character(0),
        positive_facets = character(0),
        anchors = NULL,
        group_anchors = NULL
      )
    )
  }

  pcm <- make_signature_fit("PCM", "Criterion")
  gpcm <- make_signature_fit("GPCM", "Criterion", "Criterion")
  aligned <- mfrmr:::audit_compare_mfrm_nesting(
    list(pcm, gpcm),
    labels = c("PCM", "GPCM")
  )
  expect_false(aligned$eligible)
  expect_identical(aligned$relation, "PCM_in_GPCM_ic_only")
  expect_identical(aligned$simpler, "PCM")
  expect_identical(aligned$complex, "GPCM")
  expect_match(aligned$reason, "unit-slope response-kernel reduction")
  expect_match(aligned$reason, "chi-square LRT is not implemented")

  rater_gpcm <- make_signature_fit("GPCM", "Rater", "Rater")
  mismatch <- mfrmr:::audit_compare_mfrm_nesting(
    list(pcm, rater_gpcm),
    labels = c("PCM", "rater GPCM")
  )
  expect_false(mismatch$eligible)
  expect_identical(mismatch$relation, "PCM_GPCM_owner_mismatch")
  expect_true(is.na(mismatch$simpler))
  expect_true(is.na(mismatch$complex))
  expect_match(mismatch$reason, "do not share one explicit aligned")
})

test_that("model-choice contract names level-specific single-owner slopes", {
  contract <- mfrmr:::.model_choice_score_contract("GPCM")
  expect_match(contract, "every level of one designated slope facet")
  expect_match(contract, "slope_facet == step_facet", fixed = TRUE)
  expect_match(contract, "does not combine criterion and rater slope blocks")
  expect_false(grepl("one common slope for the whole model", contract, fixed = TRUE))
})
