tam_immer_topology_runner_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "tam-immer-jml-topology-calibration-0.2.3.R"
  )
}

load_tam_immer_topology_runner <- function() {
  skip_if_not_installed("TAM")
  skip_if_not_installed("immer")
  runner <- tam_immer_topology_runner_path()
  skip_if_not(file.exists(runner),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(runner, envir = env)
  env
}

topology_manifest_row <- function(env, model, profile, tier = "smoke",
                                  replicate = 1L) {
  manifest <- env$mfrmr_tit_manifest(tier)
  manifest[
    manifest$Model == model & manifest$ProfileId == profile &
      manifest$Replicate == replicate,
    , drop = FALSE
  ]
}

test_that("topology manifests match bridge count without claiming evidence", {
  env <- load_tam_immer_topology_runner()
  smoke <- env$mfrmr_run_tam_immer_jml_topology_calibration(
    "smoke", dry_run = TRUE
  )
  pilot <- env$mfrmr_run_tam_immer_jml_topology_calibration(
    "pilot", dry_run = TRUE
  )

  expect_equal(nrow(smoke), 36L)
  expect_equal(nrow(pilot), 180L)
  expect_equal(
    sum(smoke$ExpectedDatasetState == "structurally_unidentified"), 6L
  )
  expect_equal(
    sum(pilot$ExpectedDatasetState == "structurally_unidentified"), 30L
  )
  expect_setequal(
    smoke$Topology,
    c("cyclic_degree_two", "disconnected_cluster", "path", "cycle",
      "distributed", "hub")
  )
  matched <- smoke[
    smoke$FactorBlock == "matched_topology", , drop = FALSE
  ]
  expect_setequal(matched$BridgePersons, c(8L, 12L, 24L))
  expect_equal(
    length(unique(matched$TargetMeanPersonRaterDegree[
      matched$BridgePersons == 12L
    ])),
    1L
  )
  expect_error(
    env$mfrmr_run_tam_immer_jml_topology_calibration("pilot"),
    "authorize_pilot = TRUE"
  )
  expect_error(
    env$mfrmr_run_tam_immer_jml_topology_calibration(
      "pilot", authorize_pilot = TRUE
    ),
    "requires a checkpoint directory"
  )
})

test_that("matched bridge count retains distinct topology vulnerability", {
  env <- load_tam_immer_topology_runner()
  profiles <- c("PATH_B12", "CYCLE_B12", "DISTRIBUTED_B12", "HUB_B12")
  audit <- dplyr::bind_rows(lapply(profiles, function(profile) {
    row <- topology_manifest_row(env, "RSM", profile)
    data <- env$mfrmr_tit_generate(row)
    value <- attr(data, "mfrmr_topology_graph_audit")
    value[value$Stage == "Assigned", , drop = FALSE]
  }))

  expect_true(all(audit$BridgePersonsRealized == 12L))
  expect_equal(length(unique(audit$MeanPersonRaterDegree)), 1L)
  expect_equal(length(unique(audit$AssignmentDensity)), 1L)
  expect_equal(
    audit$RaterGraphEdges[match(
      profiles, audit$ProfileId
    )],
    c(7L, 8L, 12L, 7L)
  )
  expect_equal(
    audit$ArticulationRaterCount[match(
      profiles, audit$ProfileId
    )],
    c(6L, 0L, 0L, 1L)
  )
  expect_equal(
    audit$GraphCutEdgeCount[match(
      profiles, audit$ProfileId
    )],
    c(7L, 0L, 0L, 7L)
  )
  hub <- audit[audit$ProfileId == "HUB_B12", , drop = FALSE]
  cycle <- audit[audit$ProfileId == "CYCLE_B12", , drop = FALSE]
  expect_gt(
    hub$AlgebraicConnectivityWeighted,
    cycle$AlgebraicConnectivityWeighted
  )
  expect_false(hub$SingleRaterRemovalRobust)
  expect_true(cycle$SingleRaterRemovalRobust)
})

test_that("adversarial link loss distinguishes connectivity from resilience", {
  env <- load_tam_immer_topology_runner()
  profiles <- c(
    "PATH_B12_DROP1", "CYCLE_B12_DROP1",
    "DISTRIBUTED_B12_DROP1", "HUB_B12_DROP1"
  )
  audit <- dplyr::bind_rows(lapply(profiles, function(profile) {
    row <- topology_manifest_row(env, "RSM", profile)
    data <- env$mfrmr_tit_generate(row)
    value <- attr(data, "mfrmr_topology_graph_audit")
    expect_equal(
      nrow(attr(data, "mfrmr_topology_dropped_bridge_map")), 1L,
      info = profile
    )
    value
  }))
  assigned <- audit[audit$Stage == "Assigned", , drop = FALSE]
  observed <- audit[audit$Stage == "Observed", , drop = FALSE]

  expect_true(all(assigned$RaterGraphConnected))
  expect_equal(observed$BridgePersonsRealized, rep(11L, 4L))
  expect_false(observed$RaterGraphConnected[
    observed$ProfileId == "PATH_B12_DROP1"
  ])
  expect_false(observed$RaterGraphConnected[
    observed$ProfileId == "HUB_B12_DROP1"
  ])
  expect_true(observed$RaterGraphConnected[
    observed$ProfileId == "CYCLE_B12_DROP1"
  ])
  expect_true(observed$RaterGraphConnected[
    observed$ProfileId == "DISTRIBUTED_B12_DROP1"
  ])
  distributed <- observed[
    observed$ProfileId == "DISTRIBUTED_B12_DROP1", , drop = FALSE
  ]
  expect_equal(distributed$ArticulationRaterCount, 2L)
  expect_equal(distributed$GraphCutEdgeCount, 2L)
})

test_that("topology state agrees with exact-rank fitting state", {
  env <- load_tam_immer_topology_runner()
  negative <- env$mfrmr_tit_run_cell(
    topology_manifest_row(env, "RSM", "PATH_B12_DROP1")
  )
  expect_identical(
    negative$Dataset$ObservedDatasetState,
    "structurally_unidentified"
  )
  expect_equal(nrow(negative$Modes), 0L)

  positive <- env$mfrmr_tit_run_cell(
    topology_manifest_row(env, "RSM", "CYCLE_B12_DROP1")
  )
  expect_identical(positive$Dataset$ObservedDatasetState, "attempted_modes")
  expect_equal(nrow(positive$Modes), 9L)
  expect_true(all(positive$Metrics$EvidenceReady == FALSE))
})

test_that("topology checkpoints bind execution row and payload", {
  env <- load_tam_immer_topology_runner()
  manifest <- env$mfrmr_tit_manifest("smoke")
  identity <- env$mfrmr_tit_execution_identity("smoke", manifest)
  row <- topology_manifest_row(env, "RSM", "DISCONNECTED_B24")
  result <- env$mfrmr_tit_run_cell(row)
  checkpoint <- env$mfrmr_tit_checkpoint(row, result, identity)

  expect_no_error(
    env$mfrmr_tit_validate_checkpoint(checkpoint, row, identity)
  )
  changed <- row
  changed$Seed <- changed$Seed + 1L
  expect_error(
    env$mfrmr_tit_validate_checkpoint(checkpoint, changed, identity),
    "manifest row hash mismatch"
  )
  tampered <- checkpoint
  tampered$Result$Dataset$Generated <- FALSE
  expect_error(
    env$mfrmr_tit_validate_checkpoint(tampered, row, identity),
    "result payload hash mismatch"
  )
})
