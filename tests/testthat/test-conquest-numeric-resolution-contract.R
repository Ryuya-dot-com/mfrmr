conquest_resolution_validation_dir <- function() {
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  candidates <- candidates[dir.exists(candidates)]
  if (length(candidates) == 0L) return(NA_character_)
  candidates[1]
}

load_conquest_resolution_contract <- function() {
  testthat::skip_if_not_installed("digest")
  validation_dir <- conquest_resolution_validation_dir()
  testthat::skip_if(
    is.na(validation_dir),
    "Repository-only ConQuest resolution files are unavailable."
  )
  env <- new.env(parent = globalenv())
  script <- file.path(
    validation_dir, "conquest-numeric-resolution-contract-0.2.3.R"
  )
  sys.source(script, envir = env)
  list(env = env, script = script)
}

test_that("ConQuest numeric tokens are retained before conversion", {
  env <- load_conquest_resolution_contract()$env
  file <- tempfile(fileext = ".csv")
  writeLines(c(
    "ID,Estimate,Aux",
    "a,424.738979,1.250000E-06",
    "b,-0.000000,.5",
    "c,10,1.2300"
  ), file)

  audit <- env$mfrmr_cq_resolution_audit_file(
    file,
    numeric_columns = c("Estimate", "Aux"),
    file_role = "synthetic_native",
    rounding_rule = "unknown"
  )
  expect_identical(
    env$mfrmr_cq_resolution_specification,
    "0.2.3-wave-c-resolution-v1"
  )
  expect_identical(
    env$mfrmr_cq_resolution_contract,
    "mfrmr_conquest_numeric_resolution_v1"
  )
  expect_identical(
    audit$summary$Status,
    "raw_tokens_retained_rounding_unestablished"
  )
  expect_true(audit$summary$AllNumericTokensValid)
  expect_false(audit$summary$AllRoundingRulesEstablished)
  expect_equal(nrow(audit$tokens), 6L)
  expect_true(all(nchar(audit$tokens$FileSHA256) == 64L))
  estimate <- audit$tokens[audit$tokens$Column == "Estimate", ]
  aux <- audit$tokens[audit$tokens$Column == "Aux", ]
  expect_identical(
    estimate$LexicalToken,
    c("424.738979", "-0.000000", "10")
  )
  expect_equal(estimate$LexicalUnitCandidate, c(1e-6, 1e-6, 1))
  expect_equal(aux$LexicalUnitCandidate, c(1e-12, 1e-1, 1e-4))
  expect_equal(aux$SignificantDigits, c(7L, 1L, 5L))
  expect_true(all(is.na(audit$tokens$IntervalLower)))
  expect_true(all(!audit$tokens$ScientificEquivalenceInferred))
})

test_that("rounding compatibility, tolerance, and equivalence stay separate", {
  env <- load_conquest_resolution_contract()$env
  file <- tempfile(fileext = ".csv")
  writeLines(c(
    "ID,Estimate,Aux",
    "a,424.738979,1.2300"
  ), file)
  audit <- env$mfrmr_cq_resolution_audit_file(
    file,
    numeric_columns = c("Estimate", "Aux"),
    file_role = "native",
    rounding_rule = c(Estimate = "nearest", Aux = "exact")
  )
  reference <- data.frame(
    FileRole = c("native", "native"),
    Row = c(1L, 1L),
    Column = c("Estimate", "Aux"),
    ReferenceToken = c("424.738979414154", "1.23"),
    ReferenceValue = c(424.738979414154, 1.23),
    stringsAsFactors = FALSE
  )
  comparison_object <- env$mfrmr_cq_resolution_compare(
    audit$tokens, reference, tolerance = 1e-7
  )
  comparison <- comparison_object$comparison
  estimate <- comparison[comparison$Column == "Estimate", ]
  aux <- comparison[comparison$Column == "Aux", ]

  expect_true(estimate$ReportedResolutionCompatible)
  expect_false(estimate$TolerancePassed)
  expect_identical(
    estimate$ComparisonState,
    "compatible_at_established_resolution"
  )
  expect_lt(estimate$MinCompatibleAbsDifference, 1e-12)
  expect_gt(estimate$MaxCompatibleAbsDifference, 8e-7)
  expect_false(aux$ExactLexicalEquality)
  expect_equal(aux$AbsDifference, 0)
  expect_identical(
    aux$ComparisonState,
    "numeric_equality_lexically_distinct"
  )
  expect_true(is.na(estimate$ScientificEquivalent))
  expect_false(comparison_object$scientific_equivalence_inferred)
})

test_that("the native five-file audit remains fail closed", {
  env <- load_conquest_resolution_contract()$env
  root <- tempfile("cq-resolution-native-")
  dir.create(root)
  files <- file.path(root, c(
    "history.csv", "parameter.csv", "regression.csv", "covariance.csv",
    "cases.csv"
  ))
  writeLines(c(
    "RowLabels,Run Number,Iteration,LogLikelihood,beta,sigma,xsi",
    "estimate,1,1,424.738979,0.123456,0.987654,-0.111111"
  ), files[1])
  writeLines(c(
    "P,Estimate,Label", "1,-0.111111,item i001"
  ), files[2])
  writeLines(c(
    "Dimension,Regressor,Estimate", "1,1,0.123456"
  ), files[3])
  writeLines(c(
    "Dim1,Dim2,Covariance", "1,1,0.987654"
  ), files[4])
  writeLines(c(
    "SeqNum,PID,EAP_1,weight_raw,weight_scaled",
    "1,P001,0.012345,1.000000,1.000000"
  ), files[5])

  audit <- env$mfrmr_cq_resolution_audit_native_exports(
    files[1], files[2], files[3], files[4], files[5]
  )
  expect_identical(
    audit$status,
    "raw_tokens_retained_rounding_unestablished"
  )
  expect_equal(nrow(audit$summary), 5L)
  expect_true(all(audit$summary$AllNumericTokensValid))
  expect_true(all(!audit$summary$AllRoundingRulesEstablished))
  expect_setequal(
    audit$summary$FileRole,
    c(
      "matrixout_history", "parameter_export", "regression_export",
      "covariance_export", "case_export"
    )
  )

  writeLines(c(
    "P,Estimate,Label", "1,not_numeric,item i001"
  ), files[2])
  rejected <- env$mfrmr_cq_resolution_audit_native_exports(
    files[1], files[2], files[3], files[4], files[5]
  )
  expect_identical(rejected$status, "rejected_invalid_numeric_token")
  expect_false(
    rejected$summary$AllNumericTokensValid[
      rejected$summary$FileRole == "parameter_export"
    ]
  )
})

test_that("lexical units never establish rounding by themselves", {
  env <- load_conquest_resolution_contract()$env
  parsed <- env$mfrmr_cq_resolution_parse_tokens(c(
    "1.000000", "1e-6", "Inf", "NA", "1,000"
  ))
  expect_equal(parsed$LexicalUnitCandidate[1:2], c(1e-6, 1e-6))
  expect_identical(
    parsed$NumericGrammarValid,
    c(TRUE, TRUE, FALSE, FALSE, FALSE)
  )
  expect_error(
    env$mfrmr_cq_resolution_rules(
      c(Estimate = "nearest"), c("Estimate", "Variance")
    ),
    "cover every numeric column",
    fixed = TRUE
  )
})
