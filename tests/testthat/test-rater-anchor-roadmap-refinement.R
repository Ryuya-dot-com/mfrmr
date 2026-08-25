rater_anchor_roadmap_path <- function() {
  testthat::test_path("..", "..", "ROADMAP.md")
}

rater_anchor_roadmap_text <- function() {
  path <- rater_anchor_roadmap_path()
  testthat::skip_if_not(file.exists(path))
  paste(
    readLines(path, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
}

test_that("roadmap keeps release and Rater-assignment research separate", {
  roadmap <- rater_anchor_roadmap_text()

  expect_match(
    roadmap, "### Rater-assignment and direct-anchor evidence track",
    fixed = TRUE
  )
  expect_match(roadmap, "does not block G6", fixed = TRUE)
  expect_match(roadmap, "outside the 0.2.4 release-critical path", fixed = TRUE)
  expect_match(roadmap, "outside Help, vignettes, and `NEWS.md`", fixed = TRUE)
  expect_match(roadmap, "PublicApiChanged = FALSE", fixed = TRUE)
})

test_that("roadmap preserves layered scenario denominators", {
  roadmap <- rater_anchor_roadmap_text()

  expect_match(roadmap, "Typed fixed-calibration scenarios | 9", fixed = TRUE)
  expect_match(
    roadmap, "Direct-Rater-anchor configurations | 8", fixed = TRUE
  )
  expect_match(roadmap, "Assignment-network scenarios | 7", fixed = TRUE)
  expect_match(roadmap, "McEwen incomplete-design catalog | 20", fixed = TRUE)
  expect_match(roadmap, "DeMars design archetypes | 4", fixed = TRUE)
  expect_match(roadmap, "minimum successor catalog", fixed = TRUE)
  expect_match(roadmap, "contain 11 networks", fixed = TRUE)
})

test_that("roadmap records DeMars source adjudication", {
  roadmap <- rater_anchor_roadmap_text()

  expect_match(roadmap, "complete 21-page paper", fixed = TRUE)
  expect_match(roadmap, "abstract reverses the Study 1 direction", fixed = TRUE)
  expect_match(roadmap, "workload arithmetic gives `896`", fixed = TRUE)
  expect_match(roadmap, "disconnected random-pair replication", fixed = TRUE)
  expect_match(roadmap, "retain that planned identity", fixed = TRUE)
  expect_match(roadmap, "neither source selects or tests", fixed = TRUE)
})

test_that("roadmap covers breadth strength uncertainty and failure", {
  roadmap <- rater_anchor_roadmap_text()

  expect_match(roadmap, "double_rotating_pairs", fixed = TRUE)
  expect_match(roadmap, "double_random_pairs", fixed = TRUE)
  expect_match(roadmap, "single_fixed_pair_links", fixed = TRUE)
  expect_match(roadmap, "single_random_pair_links", fixed = TRUE)
  expect_match(roadmap, "empirical-to-model SE ratio", fixed = TRUE)
  expect_match(roadmap, "weighted algebraic\\s+connectivity")
  expect_match(roadmap, "unconditional generator", fixed = TRUE)
  expect_match(roadmap, "replacement of a disconnected", fixed = TRUE)
})

test_that("roadmap stages execution without authorizing claims", {
  roadmap <- rater_anchor_roadmap_text()

  expect_match(roadmap, "gives 180 candidate fits", fixed = TRUE)
  expect_match(roadmap, "planning arithmetic only", fixed = TRUE)
  expect_match(roadmap, "Six returned fits would not be scientific evidence", fixed = TRUE)
  expect_match(roadmap, "never pool networks", fixed = TRUE)
  expect_match(roadmap, "SuccessorManifestFrozen = FALSE", fixed = TRUE)
  expect_match(roadmap, "SmokeExecutionAuthorized = FALSE", fixed = TRUE)
  expect_match(roadmap, "FeasibilityExecutionAuthorized = FALSE", fixed = TRUE)
  expect_match(roadmap, "ConfirmationAuthorized = FALSE", fixed = TRUE)
  expect_match(roadmap, "AppropriateAnchorRateSelected = FALSE", fixed = TRUE)
  expect_match(
    roadmap, "OperationalAssignmentDesignSelected = FALSE", fixed = TRUE
  )
})
