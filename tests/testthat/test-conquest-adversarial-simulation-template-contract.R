load_conquest_adversarial_simulation_templates <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  paths <- file.path(validation, c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-adversarial-simulation-program-0.2.3.R",
    "conquest-adversarial-simulation-template-contract-0.2.3.R"
  ))
  skip_if_not(all(file.exists(paths)), "ConQuest ASP templates are excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("nine scenario classes form eighteen family arms", {
  env <- load_conquest_adversarial_simulation_templates()$env
  registry <- env$mfrmr_cq_ast_template_registry()

  expect_identical(nrow(registry), 18L)
  expect_identical(anyDuplicated(registry$ArmId), 0L)
  expect_identical(
    as.integer(table(factor(registry$Family, levels = c("RSM", "PCM")))),
    c(9L, 9L)
  )
  expect_true(all(table(registry$ScenarioClassId) == 2L))
  expect_identical(sum(registry$NewArmRelativeToP2Registry), 7L)
  expect_false(any(registry$SampledResponseData))
  expect_false(any(registry$ExecutionAuthorized))
  expect_false(any(registry$PublicClaimAuthorized))
})

test_that("prototype identities and data are deterministic and disjoint", {
  env <- load_conquest_adversarial_simulation_templates()$env
  templates <- env$mfrmr_cq_ast_templates()
  repeated <- env$mfrmr_cq_ast_templates()

  expect_identical(length(templates), 18L)
  expect_identical(
    lapply(templates, `[[`, "Data"), lapply(repeated, `[[`, "Data")
  )
  expect_identical(anyDuplicated(vapply(
    templates, `[[`, character(1L), "TemplateId"
  )), 0L)
  expect_true(all(grepl("^ASPT", unlist(lapply(
    templates, function(value) unique(value$Data$Person)
  )))))
  expect_false(any(grepl("candidate-004", vapply(
    templates, `[[`, character(1L), "TemplateId"
  ), fixed = TRUE)))
  expect_true(all(vapply(templates, `[[`, logical(1L), "PrototypeOnly")))
  expect_false(any(vapply(
    templates, `[[`, logical(1L), "SampledResponseData"
  )))
})

test_that("positive topology classes remain distinct in both families", {
  env <- load_conquest_adversarial_simulation_templates()$env
  review <- env$mfrmr_cq_ast_review()
  row <- function(scenario) review$arm_audit[
    review$arm_audit$ScenarioClassId == scenario, , drop = FALSE
  ]

  complete <- row("ASP-POS-COMPLETE")
  expect_identical(complete$ObservedRows, c(576L, 576L))
  expect_true(all(complete$GraphConnected))
  multi <- row("ASP-POS-SPARSE-MULTIBRIDGE")
  expect_true(all(multi$GraphConnected))
  weak <- row("ASP-SENS-WEAK-SINGLE-BRIDGE")
  expect_true(all(weak$GraphConnected))
  workload <- row("ASP-SENS-UNEQUAL-WORKLOAD")
  expect_true(all(workload$GraphConnected))
  expect_true(all(rbind(complete, multi, weak, workload)$ScenarioContractPass))
})

test_that("missingness representations match in RSM and PCM", {
  env <- load_conquest_adversarial_simulation_templates()$env
  templates <- env$mfrmr_cq_ast_templates()
  ids <- names(templates)[grepl("ASP-INV-PAIRED-MISSINGNESS", names(templates),
                                fixed = TRUE)]

  expect_identical(length(ids), 2L)
  for (id in ids) {
    template <- templates[[id]]
    expect_identical(nrow(template$Data), 288L)
    expect_identical(nrow(template$ExplicitMissingCompanion), 576L)
    expect_identical(
      sum(is.na(template$ExplicitMissingCompanion$Response)), 288L
    )
    expect_true(env$mfrmr_cq_ast_missingness_equivalent(template))
  }
})

test_that("rare and extreme support contracts hold in both families", {
  env <- load_conquest_adversarial_simulation_templates()$env
  audit <- env$mfrmr_cq_ast_review()$arm_audit
  rare <- audit[
    audit$ScenarioClassId == "ASP-SENS-RARE-BOUNDARY-CATEGORY", , drop = FALSE
  ]
  extreme <- audit[
    audit$ScenarioClassId == "ASP-SENS-EXTREME-PERSON", , drop = FALSE
  ]

  expect_true(all(rare[, paste0("Category", 0:3)] > 0L))
  expect_true(all(rare$Category0 < rare$Category1))
  expect_true(all(rare$Category3 < rare$Category2))
  expect_true(all(rare$MinimumScorePersons == 0L))
  expect_true(all(rare$MaximumScorePersons == 0L))
  expect_true(all(extreme$MinimumScorePersons == 1L))
  expect_true(all(extreme$MaximumScorePersons == 1L))
  expect_true(all(rare$ScenarioContractPass))
  expect_true(all(extreme$ScenarioContractPass))
})

test_that("negative controls fail for different proven reasons", {
  env <- load_conquest_adversarial_simulation_templates()$env
  audit <- env$mfrmr_cq_ast_review()$arm_audit
  unused <- audit[
    audit$ScenarioClassId == "ASP-NEG-UNUSED-INTERMEDIATE-CATEGORY", ,
    drop = FALSE
  ]
  disconnected <- audit[
    audit$ScenarioClassId == "ASP-NEG-DISCONNECTED-DESIGN", , drop = FALSE
  ]

  expect_identical(unused$Category1, c(0L, 0L))
  expect_identical(unused$PredictorRank, c(9L, 13L))
  expect_true(all(unused$RankMatchesExpected))
  expect_false(any(disconnected$GraphConnected))
  expect_identical(disconnected$GraphComponents, c(2L, 2L))
  expect_identical(disconnected$PredictorDimension, c(9L, 13L))
  expect_identical(disconnected$PredictorRank, c(8L, 12L))
  expect_true(all(disconnected$RankMatchesExpected))
  expect_true(all(unused$ScenarioContractPass))
  expect_true(all(disconnected$ScenarioContractPass))
})

test_that("G1 closes without sampling, fitting, or external execution", {
  ctx <- load_conquest_adversarial_simulation_templates()
  review <- ctx$env$mfrmr_cq_ast_review()
  source <- paste(readLines(ctx$paths[4L], warn = FALSE), collapse = "\n")

  expect_identical(
    review$status,
    "ASP_G1_cross_family_deterministic_templates_complete_execution_closed"
  )
  expect_identical(review$scenario_classes, 9L)
  expect_identical(review$family_arms, 18L)
  expect_identical(review$scenario_gaps_closed, 6L)
  expect_identical(review$new_arms_relative_to_P2_registry, 7L)
  expect_false(review$legacy_disconnected_label_used_as_proof)
  expect_true(review$disconnected_full_location_predictor_rank_checked)
  expect_false(review$unused_category_rejection_is_rank_claim)
  expect_true(review$unused_category_rejection_is_support_boundary_claim)
  expect_true(review$ASP_G1_complete)
  expect_identical(review$next_gate, "ASP-G2-DGP-ORACLE-SEPARATION")
  expect_false(review$prototype_responses_reusable_as_sampled_data)
  expect_false(review$any_random_response_generated)
  expect_false(review$any_fit_attempted)
  expect_false(review$ConQuest_execution_attempted)
  expect_false(review$public_text_change_authorized)
  expect_false(review$scientific_equivalence_inferred)
  expect_false(grepl("rnorm\\s*\\(|runif\\s*\\(|sample\\s*\\(",
                     source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(|system2\\s*\\(|system\\s*\\(",
                     source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source,
                     ignore.case = TRUE))
})

test_that("record and roadmap identify G2 as the next closed execution gate", {
  ctx <- load_conquest_adversarial_simulation_templates()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-adversarial-simulation-template-contract-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_ast_specification, fixed = TRUE)
  expect_match(record, "`ASPG1Complete=TRUE`", fixed = TRUE)
  expect_match(record, "rank 8 of 9 for RSM and 12 of 13 for PCM", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Complete the six missing cross-family or disjoint deterministic",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[ ] Freeze exact DGP values and implement a neutral response",
    fixed = TRUE
  )
})
