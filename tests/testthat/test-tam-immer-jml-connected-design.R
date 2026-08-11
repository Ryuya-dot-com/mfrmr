tam_immer_connected_runner_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "tam-immer-jml-connected-design-0.2.3.R"
  )
}

load_tam_immer_connected_runner <- function() {
  skip_if_not_installed("TAM")
  skip_if_not_installed("immer")
  runner <- tam_immer_connected_runner_path()
  skip_if_not(file.exists(runner),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(runner, envir = env)
  env
}

connected_manifest_row <- function(env, model, profile) {
  manifest <- env$mfrmr_tic_manifest()
  manifest[
    manifest$Model == model & manifest$ProfileId == profile,
    , drop = FALSE
  ]
}

test_that("connected-design manifest separates bridge rate from count", {
  env <- load_tam_immer_connected_runner()
  manifest <- env$mfrmr_run_tam_immer_jml_connected_design(dry_run = TRUE)

  expect_equal(nrow(manifest), 36L)
  expect_setequal(manifest$Model, c("RSM", "PCM"))
  expect_equal(
    sum(manifest$ExpectedDatasetState == "structurally_unidentified"),
    6L
  )
  expect_equal(
    sum(manifest$ExpectedDatasetState == "attempted_modes"),
    30L
  )
  expect_true(all(
    manifest$ExpectedDatasetState[
      manifest$ProfileId %in%
        c("BRIDGE_B000", "BRIDGE_B005", "BRIDGE_P60_B010")
    ] == "structurally_unidentified"
  ))
  expect_true(all(
    manifest$ExpectedDatasetState[
      manifest$ProfileId %in%
        c("BRIDGE_B010", "BRIDGE_P60_B020", "BRIDGE_P480_B0025")
    ] == "attempted_modes"
  ))
  p60 <- manifest[
    manifest$Model == "RSM" & manifest$ProfileId == "BRIDGE_P60_B010",
    , drop = FALSE
  ]
  p120 <- manifest[
    manifest$Model == "RSM" & manifest$ProfileId == "BRIDGE_B010",
    , drop = FALSE
  ]
  expect_equal(p60$BridgeFraction, p120$BridgeFraction)
  expect_equal(p60$BridgePersonsTarget, 6L)
  expect_equal(p120$BridgePersonsTarget, 12L)
  expect_false(p60$ExpectedAssignedConnected)
  expect_true(p120$ExpectedAssignedConnected)
})

test_that("connected generator audits graph state and density identity", {
  env <- load_tam_immer_connected_runner()
  profiles <- c(
    "BRIDGE_B000", "BRIDGE_B005", "BRIDGE_B010",
    "BRIDGE_P60_B010", "BRIDGE_P60_B020", "BRIDGE_P480_B0025",
    "FIXDEG_R4_D2", "FIXDENS_R12_D6"
  )
  audits <- lapply(profiles, function(profile) {
    row <- connected_manifest_row(env, "RSM", profile)
    data <- env$mfrmr_tic_generate(row)
    attr(data, "mfrmr_connected_graph_audit")
  })
  audit <- dplyr::bind_rows(audits)
  assigned <- audit[audit$Stage == "Assigned", , drop = FALSE]

  expect_equal(
    assigned$RaterGraphComponents[
      assigned$ProfileId == "BRIDGE_B000"
    ],
    8L
  )
  expect_equal(
    assigned$RaterGraphComponents[
      assigned$ProfileId == "BRIDGE_B005"
    ],
    2L
  )
  expect_true(all(!assigned$RaterGraphConnected[
    assigned$ProfileId %in% c("BRIDGE_B000", "BRIDGE_B005",
                              "BRIDGE_P60_B010")
  ]))
  expect_true(all(assigned$RaterGraphConnected[
    assigned$ProfileId %in% c("BRIDGE_B010", "BRIDGE_P60_B020",
                              "BRIDGE_P480_B0025")
  ]))
  expect_true(all(
    assigned$BridgePersonsTarget == assigned$BridgePersonsRealized
  ))
  expect_equal(
    assigned$AssignmentDensity,
    assigned$MeanPersonRaterDegree / assigned$DeclaredRaters,
    tolerance = 1e-12
  )
  expect_true(all(
    assigned$AlgebraicConnectivityWeighted[
      !assigned$RaterGraphConnected
    ] < 1e-10
  ))
  expect_true(all(
    assigned$AlgebraicConnectivityWeighted[
      assigned$RaterGraphConnected
    ] > 0
  ))
  expect_equal(
    assigned$AssignmentDensity[
      assigned$ProfileId == "FIXDEG_R4_D2"
    ],
    0.5
  )
  expect_equal(
    assigned$AssignmentDensity[
      assigned$ProfileId == "FIXDENS_R12_D6"
    ],
    0.5
  )
})

test_that("graph state agrees with structural fitting state", {
  env <- load_tam_immer_connected_runner()

  negative <- env$mfrmr_tic_run_cell(
    connected_manifest_row(env, "RSM", "BRIDGE_B005")
  )
  expect_identical(
    negative$Dataset$ObservedDatasetState,
    "structurally_unidentified"
  )
  expect_equal(nrow(negative$Modes), 0L)
  expect_match(negative$Dataset$Error, "rank 131 of 132")

  positive <- env$mfrmr_tic_run_cell(
    connected_manifest_row(env, "RSM", "BRIDGE_B010")
  )
  expect_identical(positive$Dataset$ObservedDatasetState, "attempted_modes")
  expect_equal(nrow(positive$Modes), 9L)
  expect_true(all(positive$Modes$ProfileId == "BRIDGE_B010"))
  expect_true(all(positive$Metrics$EvidenceReady == FALSE))
  coverage <- positive$Metrics[
    positive$Metrics$Metric == "SECoverage95", , drop = FALSE
  ]
  separation <- positive$Metrics[
    positive$Metrics$Metric == "ReportedFacetSeparation", , drop = FALSE
  ]
  expect_true(all(!coverage$Eligible & is.na(coverage$Value)))
  expect_true(all(!separation$Eligible & is.na(separation$Value)))
})
