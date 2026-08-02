conquest_polytomous_validation_dir <- function() {
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  candidates <- candidates[dir.exists(candidates)]
  if (length(candidates) == 0L) return(NA_character_)
  candidates[1]
}

load_conquest_polytomous_pilot <- function() {
  validation_dir <- conquest_polytomous_validation_dir()
  testthat::skip_if(
    is.na(validation_dir),
    "Repository-only ConQuest polytomous validation files are unavailable."
  )
  env <- new.env(parent = globalenv())
  script <- file.path(
    validation_dir,
    "conquest-polytomous-rsm-pcm-pilot-0.2.3.R"
  )
  sys.source(script, envir = env)
  list(env = env, script = script)
}

test_that("the ConQuest polytomous ladder is fixed and never auto-executes", {
  loaded <- load_conquest_polytomous_pilot()
  env <- loaded$env
  plan <- env$mfrmr_cq_poly_plan()

  expect_identical(env$mfrmr_cq_poly_specification, "0.2.3-draft.11")
  expect_identical(
    env$mfrmr_cq_poly_contract,
    "mfrmr_conquest_polytomous_rsm_pcm_ladder_v1"
  )
  suffix <- c("q007", "q015", "q031a", "q061", "q091", "q121", "q031b")
  expect_identical(
    plan$RunId,
    c(paste0("rsm_", suffix), paste0("pcm_", suffix))
  )
  expect_identical(plan$Model, rep(c("RSM", "PCM"), each = 7L))
  expect_identical(
    plan$ConQuestModel,
    rep(c("item + step", "item + item*step"), each = 7L)
  )
  expect_identical(
    plan$Nodes,
    rep(c(7L, 15L, 31L, 61L, 91L, 121L, 31L), times = 2L)
  )
  expect_identical(plan$ExpectedNpar, rep(c(9L, 17L), each = 7L))
  expect_identical(
    plan$CoreCandidate,
    rep(c(FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, FALSE), times = 2L)
  )
  expect_identical(
    plan$ReplicateGroup,
    c(
      NA, NA, "rsm_q31", NA, NA, NA, "rsm_q31",
      NA, NA, "pcm_q31", NA, NA, NA, "pcm_q31"
    )
  )
  expect_true(all(!plan$SelectionAuthorized))
  expect_true(all(!plan$ConfirmationAuthorized))

  q7_command <- env$mfrmr_cq_poly_command(
    "cq_rsm_q007", "item + step", sprintf("I%03d", 1:5), nodes = 7L
  )
  q121_command <- env$mfrmr_cq_poly_command(
    "cq_pcm_q121", "item + item*step", sprintf("I%03d", 1:5), nodes = 121L
  )
  expect_true(any(grepl("nodes=7,", q7_command, fixed = TRUE)))
  expect_true(any(grepl("nodes=121,", q121_command, fixed = TRUE)))
  expect_error(
    env$mfrmr_cq_poly_command("bad", "item + step", "I001", nodes = 0L),
    "positive integer",
    fixed = TRUE
  )
  retained_nodes <- list(config = list(
    estimation_control = list(quad_points = 61L),
    replay_inputs = list(quad_points = 61L)
  ))
  expect_identical(env$mfrmr_cq_poly_fit_nodes(retained_nodes), 61L)
  retained_nodes$config$replay_inputs$quad_points <- 91L
  expect_error(
    env$mfrmr_cq_poly_fit_nodes(retained_nodes),
    "unambiguous quadrature-node count",
    fixed = TRUE
  )

  script_lines <- readLines(loaded$script, warn = FALSE)
  executable_calls <- grep(
    "system2\\s*\\(|/Applications/ConQuest|ConQuestCMD",
    script_lines,
    perl = TRUE,
    value = TRUE
  )
  expect_length(executable_calls, 0L)

  occupied <- file.path(tempdir(), "occupied-conquest-polytomous")
  dir.create(occupied, recursive = TRUE, showWarnings = FALSE)
  marker <- file.path(occupied, "marker.txt")
  writeLines("do not overwrite", marker)
  expect_error(
    env$mfrmr_prepare_conquest_polytomous_pilot(occupied),
    "absent or empty",
    fixed = TRUE
  )
  expect_identical(readLines(marker, warn = FALSE), "do not overwrite")

  empty <- file.path(tempdir(), "empty-conquest-polytomous-review")
  dir.create(empty, recursive = TRUE, showWarnings = FALSE)
  expect_error(
    env$mfrmr_review_conquest_polytomous_pilot(empty),
    "manifest is missing",
    fixed = TRUE
  )
})

test_that("the fixed polytomous fixture covers every item category", {
  env <- load_conquest_polytomous_pilot()$env
  fixture <- env$mfrmr_cq_poly_fixture()

  expect_identical(fixture$seed, 20260727L)
  expect_identical(fixture$generating_model, "PCM")
  expect_equal(nrow(fixture$long), 600L)
  expect_equal(nrow(fixture$wide), 120L)
  expect_identical(names(fixture$wide), c(
    "Person", "X", sprintf("I%03d", 1:5)
  ))
  expect_identical(sort(unique(fixture$long$Score)), 0:3)
  expect_equal(nrow(fixture$category_counts), 20L)
  expect_true(all(fixture$category_counts$Freq > 0L))
  expect_equal(
    as.numeric(tapply(
      fixture$category_counts$Freq,
      fixture$category_counts$Item,
      sum
    )),
    rep(120, 5L)
  )

  expect_identical(
    env$mfrmr_cq_poly_expected_parameter_labels("RSM", fixture$items),
    c(
      paste("item", tolower(fixture$items[1:4])),
      "category 1", "category 2"
    )
  )
  expect_length(
    env$mfrmr_cq_poly_expected_parameter_labels("PCM", fixture$items),
    14L
  )
})

test_that("the ConQuest polytomous constraint reconstruction is explicit", {
  env <- load_conquest_polytomous_pilot()$env
  items <- sprintf("I%03d", 1:5)

  rsm <- env$mfrmr_cq_poly_reconstruct_full(
    "RSM",
    c(-0.8, -0.4, 0.1, 0.3, -0.9, -0.2),
    items
  )
  expect_equal(nrow(rsm$table), 8L)
  expect_equal(rsm$max_constraint_residual, 0)
  expect_equal(
    sum(rsm$table$Estimate[rsm$table$Component == "Item"]),
    0
  )
  expect_equal(
    sum(rsm$table$Estimate[rsm$table$Component == "Step"]),
    0
  )

  pcm <- env$mfrmr_cq_poly_reconstruct_full(
    "PCM",
    c(-0.8, -0.4, 0.1, 0.3, rep(c(-1, 0.2), 5L)),
    items
  )
  expect_equal(nrow(pcm$table), 20L)
  expect_equal(pcm$max_constraint_residual, 0)
  expect_equal(
    rowsum(
      pcm$table$Estimate[pcm$table$Component == "Step"],
      pcm$table$Group[pcm$table$Component == "Step"]
    )[, 1],
    stats::setNames(rep(0, 5L), items)
  )
  expect_error(
    env$mfrmr_cq_poly_reconstruct_full("RSM", 1:5, items),
    "two coordinates",
    fixed = TRUE
  )
})

test_that("the ConQuest polytomous ladder summary remains pilot-only", {
  env <- load_conquest_polytomous_pilot()$env
  plan <- env$mfrmr_cq_poly_plan()
  accepted <- !(plan$Nodes %in% c(7L, 15L))
  rsm <- plan$Model == "RSM"
  pcm <- plan$Model == "PCM"
  results <- data.frame(
    RunId = plan$RunId,
    Model = plan$Model,
    Nodes = plan$Nodes,
    CoreCandidate = plan$CoreCandidate,
    EvidenceRole = plan$EvidenceRole,
    ReplicateGroup = plan$ReplicateGroup,
    InputMD5 = rep("fixed-input", nrow(plan)),
    AdapterStatus = ifelse(accepted, "accepted_arithmetic", "rejected"),
    ConQuestDeviance = ifelse(
      accepted,
      ifelse(rsm, 1426.254015, 1393.460210),
      NA_real_
    ),
    MfrmrDeviance = ifelse(
      rsm, 1426.25401514183, 1393.46021124811
    ),
    CrossEngineDevianceDifference = ifelse(
      accepted,
      ifelse(rsm, -1.4183e-7, -1.24811e-6),
      NA_real_
    ),
    MaxFreeParameterAbsDifference = ifelse(
      accepted,
      ifelse(rsm, 1.528469e-6, 1.604646e-6),
      NA_real_
    ),
    MaxFullParameterAbsDifference = ifelse(
      accepted,
      ifelse(rsm, 1.481114e-6, 1.604646e-6),
      NA_real_
    ),
    MaxConstraintResidual = ifelse(accepted, 0, NA_real_),
    Npar = ifelse(accepted, plan$ExpectedNpar, NA_integer_),
    ExpectedNpar = plan$ExpectedNpar,
    NativeOutputFingerprint = paste0("native-", plan$RunId),
    ComparisonReady = FALSE,
    stringsAsFactors = FALSE
  )
  results$NativeOutputFingerprint[results$RunId == "rsm_q031b"] <-
    results$NativeOutputFingerprint[results$RunId == "rsm_q031a"]
  results$NativeOutputFingerprint[results$RunId == "pcm_q031b"] <-
    results$NativeOutputFingerprint[results$RunId == "pcm_q031a"]

  summary <- env$mfrmr_cq_poly_summarize(results)
  expect_identical(summary$Status, "review")
  expect_true(summary$InputByteIdentical)
  expect_equal(summary$RsmCoreDistinctNodes, 4L)
  expect_equal(summary$PcmCoreDistinctNodes, 4L)
  expect_true(summary$RsmCoreArithmeticAccepted)
  expect_true(summary$PcmCoreArithmeticAccepted)
  expect_true(summary$BothFamiliesArithmeticAccepted)
  expect_true(summary$FreeDimensionsMatched)
  expect_equal(summary$MaxAbsCrossEngineDevianceDifference, 1.24811e-6)
  expect_equal(summary$MaxFreeParameterAbsDifference, 1.604646e-6)
  expect_equal(summary$MaxFullParameterAbsDifference, 1.604646e-6)
  expect_equal(summary$MaxConstraintResidual, 0)
  expect_equal(summary$RsmCoreConQuestDevianceRange, 0)
  expect_equal(summary$PcmCoreConQuestDevianceRange, 0)
  expect_equal(summary$RsmCoreMfrmrDevianceRange, 0)
  expect_equal(summary$PcmCoreMfrmrDevianceRange, 0)
  expect_equal(summary$RsmPcmFreeDimensionDifference, 8)
  expect_lt(summary$MaxAbsRsmPcmDevianceDropDifference, 1.2e-6)
  expect_true(summary$RsmQ31ReplicationByteIdentical)
  expect_true(summary$PcmQ31ReplicationByteIdentical)
  expect_true(summary$RsmQ31ReplicationDevianceIdentical)
  expect_true(summary$PcmQ31ReplicationDevianceIdentical)
  expect_identical(summary$RsmQ7Status, "rejected")
  expect_identical(summary$RsmQ15Status, "rejected")
  expect_identical(summary$PcmQ7Status, "rejected")
  expect_identical(summary$PcmQ15Status, "rejected")
  expect_identical(
    summary$ConstraintMappingStatus,
    "same_platform_ladder_complete"
  )
  expect_identical(summary$IndependentPlatformStatus, "not_run")
  expect_identical(summary$IntegrationStabilityStatus, "review")
  expect_identical(summary$FreezeCriterionStatus, "pilot_required")
  expect_false(summary$AnyComparisonReady)
  expect_false(summary$SelectionAuthorized)
  expect_false(summary$ConfirmationAuthorized)

  nonrepeat <- results
  nonrepeat$NativeOutputFingerprint[nonrepeat$RunId == "pcm_q031b"] <-
    "changed-native-output"
  nonrepeat_summary <- env$mfrmr_cq_poly_summarize(nonrepeat)
  expect_false(nonrepeat_summary$PcmQ31ReplicationByteIdentical)
  expect_identical(nonrepeat_summary$ConstraintMappingStatus, "review")

  changed_input <- results
  changed_input$InputMD5[1] <- "different-input"
  changed_input_summary <- env$mfrmr_cq_poly_summarize(changed_input)
  expect_false(changed_input_summary$InputByteIdentical)
  expect_identical(changed_input_summary$ConstraintMappingStatus, "review")

  rejected_core <- results
  rejected_core$AdapterStatus[rejected_core$RunId == "pcm_q061"] <- "rejected"
  rejected_summary <- env$mfrmr_cq_poly_summarize(rejected_core)
  expect_false(rejected_summary$BothFamiliesArithmeticAccepted)
  expect_identical(rejected_summary$ConstraintMappingStatus, "review")

  expect_error(
    env$mfrmr_cq_poly_summarize(results[, "RunId", drop = FALSE]),
    "summary contract",
    fixed = TRUE
  )
})
