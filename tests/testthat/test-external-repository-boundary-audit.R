load_external_repository_boundary_audit <- function() {
  path <- testthat::test_path(
    "..", "..", "inst", "validation",
    "external-repository-boundary-audit-0.2.3.R"
  )
  skip_if_not(file.exists(path),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  env <- new.env(parent = globalenv())
  sys.source(path, envir = env)
  env
}

test_that("external repository evidence respects privacy and license boundary", {
  env <- load_external_repository_boundary_audit()
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  audit <- env$mfrmr_external_repository_boundary_audit(root)

  expect_identical(audit$Decision$Status, "ok")
  expect_true(audit$Decision$RepositoryBoundaryReady)
  expect_gt(audit$Summary$TrackedFiles, 100L)
  expect_gt(audit$Summary$ExternalArtifacts, 25L)
  expect_identical(audit$Summary$ExternalFamilies, 4L)
  expect_gt(audit$Summary$TrackedDataAssets, 10L)
  expect_identical(audit$Summary$UnclassifiedDataAssets, 0L)
  expect_identical(audit$Summary$AllowedSyntheticLocalPathFixtures, 1L)
  expect_identical(audit$Summary$ProhibitedFindings, 0L)
  expect_true(audit$Summary$FilesResolve)
  expect_true(audit$Summary$RelativePathsOnly)
  expect_true(audit$Summary$ExternalFamilySetComplete)
  expect_match(audit$Summary$ManifestSHA256, "^[0-9a-f]{64}$")
  expect_identical(nrow(audit$ArtifactManifest),
                   audit$Summary$ExternalArtifacts)
  expect_true(all(file.exists(file.path(
    root, audit$ArtifactManifest$Path
  ))))
  expect_true(all(grepl(
    "^[0-9a-f]{64}$", audit$ArtifactManifest$SHA256
  )))
  expect_true(all(!is.na(audit$DataAssetManifest$Class)))
  expect_true(all(grepl(
    "^[0-9a-f]{64}$", audit$DataAssetManifest$SHA256
  )))
  expect_identical(nrow(audit$Findings), 0L)

  validation <- file.path(root, "inst", "validation")
  record <- paste(readLines(file.path(
    validation, "external-repository-boundary-audit-record-0.2.3.md"
  ), warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  bound_paths <- c(
    file.path(validation,
              "external-repository-boundary-audit-0.2.3.R"),
    file.path(validation,
              "portfolio-purpose-and-conquest-audit-0.2.3.md")
  )
  bound_hashes <- vapply(bound_paths, env$mfrmr_erba_sha256, character(1))
  expect_true(all(vapply(
    bound_hashes, grepl, logical(1), x = record, fixed = TRUE
  )))
})

test_that("external repository boundary fails closed without exposing values", {
  env <- load_external_repository_boundary_audit()
  root <- tempfile("mfrmr-external-boundary-")
  dir.create(file.path(root, "external"), recursive = TRUE)
  paths <- c(
    "external/conquest.exe", "external/facets-case.dat",
    "external/local-path.md", "external/activation-key.txt",
    "external/unclassified.csv"
  )
  writeBin(as.raw(c(0x4d, 0x5a)), file.path(root, paths[1L]))
  writeLines("synthetic case", file.path(root, paths[2L]))
  writeLines(paste0("/", "Users", "/private/study"),
             file.path(root, paths[3L]))
  writeLines(paste0("activation", "_key=", "ABCDEFGHIJKL", "1234"),
             file.path(root, paths[4L]))
  writeLines("person_id,score\nP001,4", file.path(root, paths[5L]))

  audit <- env$mfrmr_external_repository_boundary_audit(
    root, tracked_files = paths, allowed_local_path_fixtures = character(0)
  )

  expect_identical(audit$Decision$Status, "concern")
  expect_false(audit$Decision$RepositoryBoundaryReady)
  expect_gte(audit$Summary$ProhibitedFindings, 5L)
  expect_setequal(unique(audit$Findings$Finding), c(
    "proprietary_binary_or_key_extension",
    "license_or_serial_key_filename",
    "identifier_bearing_external_case_extension",
    "unclassified_tracked_data_asset",
    "local_absolute_path",
    "sensitive_key_material"
  ))
  expect_false(any(grepl("ABCDEFGHIJKL1234", audit$Findings$Path,
                         fixed = TRUE)))
})
