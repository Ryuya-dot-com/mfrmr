test_that("matched MML tutorial contract freezes scope without authorizing execution", {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  path <- file.path(
    root, "inst", "validation",
    "matched-mml-tutorial-preexecution-contract-0.2.4.md"
  )
  expect_true(file.exists(path))
  contract <- paste(readLines(path, warn = FALSE), collapse = "\n")

  for (token in c(
    "MML-MATCH-PREEXEC-v1",
    "654461b6634bac2ecffeba27b73eaa45ec913c63c1dfb4bd584aebee4d1545e4",
    "MM-RSM-ESTVAR",
    "MM-PCM-ESTVAR-TAM",
    "MM-PCM-ESTVAR-SIRT",
    "population_formula = ~ 1",
    "TAM::tam.mml.mfr()",
    "sirt::rm.facets()",
    "31 and 61 deterministic points",
    "fit$person$EAP",
    "not `TAM::tam.wle()`",
    "subset may replace the frozen denominator"
  )) {
    expect_match(contract, token, fixed = TRUE)
  }

  expect_match(contract, "execution remains locked until", fixed = TRUE)
  expect_match(contract, "descriptive calibration", fixed = TRUE)
  expect_match(contract, "authorizes no fit", fixed = TRUE)
  expect_false(grepl("EXT-TAM-TOL.*=", contract))

  roadmap_path <- file.path(
    root, "inst", "validation", "mfrmr-internal-strategic-roadmap.html"
  )
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")
  expect_match(roadmap, "MML-MATCH-PREEXEC-v1", fixed = TRUE)
  expect_match(
    roadmap, "protocol frozen · execution after D5", fixed = TRUE
  )
  expect_match(
    roadmap,
    "matched-mml-tutorial-preexecution-contract-0.2.4.md",
    fixed = TRUE
  )
})
