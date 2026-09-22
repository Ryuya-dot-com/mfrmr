load_conquest_optional_package_boundary_audit <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  script <- file.path(
    validation, "conquest-optional-package-boundary-audit-0.2.3.R"
  )
  skip_if_not(file.exists(script), "ConQuest package-boundary audit is excluded.")
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  list(root = root, validation = validation, script = script, env = env)
}

test_that("ConQuest remains outside dependencies and runtime launch paths", {
  ctx <- load_conquest_optional_package_boundary_audit()
  audit <- ctx$env$mfrmr_cq_opba_audit(ctx$root)

  expect_identical(audit$status, "conquest_optional_package_boundary_passed")
  expect_false(audit$package_dependency_declared)
  expect_false(audit$runtime_launch_primitive_detected)
  expect_false(audit$runtime_machine_path_detected)
  expect_false(audit$source_distribution_external_binary_detected)
  expect_true(audit$pure_R_handoff_exports_present)
  expect_true(audit$pass)
})

test_that("ordinary tests and source-package exclusions stay separated", {
  ctx <- load_conquest_optional_package_boundary_audit()
  audit <- ctx$env$mfrmr_cq_opba_audit(ctx$root)

  expect_gt(audit$ordinary_test_file_count, 0L)
  expect_gt(audit$ordinary_conquest_API_test_file_count, 0L)
  expect_false(audit$ordinary_test_launch_primitive_detected)
  expect_false(audit$ordinary_test_machine_path_detected)
  expect_true(audit$validation_tree_excluded)
  expect_true(audit$validation_results_excluded)
  expect_true(audit$external_conquest_tests_excluded)
  expect_false(audit$conquest_available_during_ordinary_check_required)
})

test_that("audit itself cannot launch ConQuest or bless comparison claims", {
  ctx <- load_conquest_optional_package_boundary_audit()
  source <- paste(readLines(ctx$script, warn = FALSE), collapse = "\n")
  source_names <- all.names(parse(file = ctx$script), functions = TRUE)

  expect_false(any(c("system2", "system", "shell") %in% source_names))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
  expect_false(grepl("EvidencePromotionAuthorized=TRUE", source, fixed = TRUE))
  expect_false(grepl("ScientificEquivalenceInferred=TRUE", source, fixed = TRUE))
})

test_that("record and roadmap retain the optional boundary", {
  ctx <- load_conquest_optional_package_boundary_audit()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-optional-package-boundary-audit-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_opba_specification, fixed = TRUE)
  expect_match(record, "`ConQuestRuntimeDependency=FALSE`", fixed = TRUE)
  expect_match(record, "`ConQuestCRANCheckDependency=FALSE`", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Confirm that ConQuest remains optional",
    fixed = TRUE
  )
})
