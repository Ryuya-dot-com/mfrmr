calibration_public_fixture <- local({
  cache <- NULL
  function() {
    if (!is.null(cache)) return(cache)
    data <- load_mfrmr_data("example_core")
    persons <- unique(as.character(data$Person))[seq_len(18L)]
    training <- data[as.character(data$Person) %in% persons, , drop = FALSE]
    fit <- suppressWarnings(fit_mfrm(
      training,
      person = "Person",
      facets = c("Rater", "Criterion"),
      score = "Score",
      method = "MML",
      model = "RSM",
      quad_points = 5,
      maxit = 20
    ))
    draft <- extract_mfrm_calibration(
      fit,
      calibration_id = "public-api-rsm",
      source_fit_id = "public-api-source-fit",
      created_at_utc = "2026-08-26T00:00:00Z"
    )
    validated <- validate_mfrm_calibration(
      draft, validated_at_utc = "2026-08-26T00:01:00Z"
    )
    frozen <- freeze_mfrm_calibration(
      validated, frozen_at_utc = "2026-08-26T00:02:00Z"
    )
    rows <- training[
      as.character(training$Person) %in% persons[seq_len(2L)],
      c("Person", "Rater", "Criterion", "Score"),
      drop = FALSE
    ]
    person_map <- stats::setNames(c("NEW_LOW", "NEW_HIGH"), persons[seq_len(2L)])
    rows$Person <- unname(person_map[as.character(rows$Person)])
    rows$Score[rows$Person == "NEW_LOW"] <- min(training$Score)
    rows$Score[rows$Person == "NEW_HIGH"] <- max(training$Score)
    rownames(rows) <- NULL
    cache <<- list(
      data = training, fit = fit, draft = draft, validated = validated,
      frozen = frozen, rows = rows
    )
    cache
  }
})

test_that("portable calibration exports only the reviewed public workflow", {
  expected <- c(
    "mfrm_calibration_capabilities", "extract_mfrm_calibration",
    "review_mfrm_calibration", "validate_mfrm_calibration",
    "freeze_mfrm_calibration", "supersede_mfrm_calibration",
    "retire_mfrm_calibration", "save_mfrm_calibration",
    "load_mfrm_calibration", "score_mfrm_calibration"
  )
  exports <- getNamespaceExports("mfrmr")
  expect_true(all(expected %in% exports))
  expect_false(any(c(
    "mfrmr_extract_calibration_draft", "mfrmr_review_calibration",
    "mfrmr_validate_calibration_draft", "mfrmr_freeze_calibration",
    "mfrmr_score_calibration"
  ) %in% exports))
})

test_that("public capability matrix states the bounded artifact envelope", {
  capabilities <- mfrm_calibration_capabilities()
  expect_identical(nrow(capabilities), 6L)
  expect_identical(
    names(capabilities),
    c(
      "Model", "Estimator", "ScoringBasis", "PortableCalibration",
      "AnchorSupport", "InteractionSupport", "ExistingAlternative",
      "Limitation"
    )
  )
  available <- capabilities$PortableCalibration == "available"
  expect_identical(which(available), c(1L, 2L))
  expect_identical(capabilities$Model[available], c("RSM", "PCM"))
  expect_true(all(capabilities$Estimator[available] == "MML"))
  expect_true(all(
    capabilities$ScoringBasis[available] == "fixed standard normal"
  ))
  expect_true(all(nzchar(capabilities$ExistingAlternative[!available])))
  expect_true(all(nzchar(capabilities$Limitation)))

  guide <- mfrmr_output_guide("calibration")
  expect_identical(nrow(guide), 4L)
  expect_true(all(guide$Scope == "calibration"))
  expect_true(all(guide$RecommendedEntry))
  expect_true(any(grepl(
    "mfrm_calibration_capabilities()", guide$MainFunction, fixed = TRUE
  )))
  expect_true(any(grepl(
    "score_mfrm_calibration()", guide$MainFunction, fixed = TRUE
  )))
  expect_true(any(grepl(
    "does not construct typed step anchors", guide$Notes, fixed = TRUE
  )))
  expect_true(any(grepl(
    "excludes calibration-parameter uncertainty",
    guide$DecisionBoundary,
    fixed = TRUE
  )))
})

test_that("public lifecycle is explicit and artifact scoring performs no refit", {
  fixture <- calibration_public_fixture()
  expect_s3_class(fixture$draft, "mfrm_calibration")
  expect_identical(fixture$draft$lifecycle$state, "draft")
  expect_identical(nrow(review_mfrm_calibration(fixture$draft)), 0L)
  expect_identical(fixture$validated$lifecycle$state, "validated")
  expect_identical(fixture$frozen$lifecycle$state, "frozen")

  scored <- score_mfrm_calibration(
    fixture$frozen, fixture$rows, interval_level = 0.90
  )
  expect_s3_class(scored, "mfrm_calibration_score")
  expect_identical(scored$settings$engine_identity, "artifact_coordinates_v1")
  expect_identical(scored$settings$lifecycle_state, "frozen")
  expect_true(all(scored$estimates$SD > 0))
  expect_gt(
    scored$estimates$Estimate[scored$estimates$Person == "NEW_HIGH"],
    scored$estimates$Estimate[scored$estimates$Person == "NEW_LOW"]
  )

  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path), add = TRUE)
  saved <- save_mfrm_calibration(fixture$frozen, path)
  expect_identical(normalizePath(path), saved)
  restored <- load_mfrm_calibration(path)
  expect_identical(restored, fixture$frozen)
  expect_identical(
    score_mfrm_calibration(restored, fixture$rows),
    score_mfrm_calibration(fixture$frozen, fixture$rows)
  )

  retired <- retire_mfrm_calibration(
    fixture$frozen,
    record_id = "public-api-rsm-retired",
    retired_at_utc = "2026-08-26T00:03:00Z"
  )
  expect_identical(retired$lifecycle$state, "retired")
  error <- tryCatch(
    score_mfrm_calibration(retired, fixture$rows),
    mfrm_calibration_error = identity
  )
  expect_s3_class(error, "mfrm_calibration_error")
  expect_identical(error$code, "LIFECYCLE_NOT_FROZEN")
})

test_that("public loader explicitly refuses incompatible schema fixtures", {
  fixture <- calibration_public_fixture()
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path), add = TRUE)

  newer <- fixture$frozen
  newer$header$schema_version <- newer$header$schema_version + 1L
  saveRDS(newer, path, version = 3)
  newer_error <- tryCatch(
    load_mfrm_calibration(path),
    mfrm_calibration_error = identity
  )
  expect_s3_class(newer_error, "mfrm_calibration_error")
  expect_identical(newer_error$code, "SCHEMA_VERSION_UNSUPPORTED")

  unknown <- fixture$frozen
  unknown$future_section <- list(value = 1L)
  saveRDS(unknown, path, version = 3)
  unknown_error <- tryCatch(
    load_mfrm_calibration(path),
    mfrm_calibration_error = identity
  )
  expect_s3_class(unknown_error, "mfrm_calibration_error")
  expect_identical(unknown_error$code, "SCHEMA_FIELD_UNEXPECTED")

  partial <- fixture$frozen
  partial$response$score_map <- NULL
  saveRDS(partial, path, version = 3)
  partial_error <- tryCatch(
    load_mfrm_calibration(path),
    mfrm_calibration_error = identity
  )
  expect_s3_class(partial_error, "mfrm_calibration_error")
  expect_true(partial_error$code %in% c(
    "SCHEMA_FIELD_MISSING", "SCORE_MAP_INVALID"
  ))
})

test_that("public extraction refusals give actionable non-internal alternatives", {
  fixture <- calibration_public_fixture()
  cases <- list(
    family = list(
      code = "MODEL_FAMILY_UNSUPPORTED",
      mutate = function(fit) {
        fit$config$model <- "GPCM"
        fit
      }
    ),
    estimator = list(
      code = "MODEL_ESTIMATOR_UNSUPPORTED",
      mutate = function(fit) {
        fit$config$method <- "JML"
        fit
      }
    ),
    population = list(
      code = "SCORING_BASIS_UNSUPPORTED",
      mutate = function(fit) {
        fit$config$population_spec <- list(active = TRUE)
        fit
      }
    )
  )
  for (case in cases) {
    error <- tryCatch(
      extract_mfrm_calibration(case$mutate(fixture$fit)),
      mfrm_calibration_error = identity
    )
    expect_s3_class(error, "mfrm_calibration_error")
    expect_identical(error$code, case$code)
    expect_match(conditionMessage(error), "fitted-object scoring", fixed = TRUE)
    expect_false(grepl("OPT-[0-9]|CORE-[0-9]|G[0-6] exit|internal",
                       conditionMessage(error), perl = TRUE))
  }
})

test_that("installed public surfaces share the bounded calibration wording", {
  root <- normalizePath(find.package("mfrmr"), winslash = "/")
  article_candidates <- file.path(
    root,
    c(
      "doc/mfrmr-portable-calibration.Rmd",
      "vignettes/mfrmr-portable-calibration.Rmd"
    )
  )
  article <- article_candidates[file.exists(article_candidates)][1L]
  expect_true(file.exists(file.path(root, "README.md")))
  expect_true(file.exists(file.path(root, "NEWS.md")))
  expect_length(article, 1L)
  expect_true(!is.na(article) && file.exists(article))

  text <- list(
    README = paste(
      readLines(file.path(root, "README.md"), warn = FALSE), collapse = "\n"
    ),
    NEWS = paste(
      readLines(file.path(root, "NEWS.md"), warn = FALSE), collapse = "\n"
    ),
    article = paste(readLines(article, warn = FALSE), collapse = "\n")
  )

  core_surfaces <- text[c("README", "article")]
  for (surface in core_surfaces) {
    expect_match(surface, "RSM", fixed = TRUE)
    expect_match(surface, "PCM", fixed = TRUE)
    expect_match(surface, "MML", fixed = TRUE)
    expect_match(surface, "fixed\\s+standard-normal", perl = TRUE)
    expect_match(surface, "GPCM", fixed = TRUE)
    expect_match(surface, "JML", fixed = TRUE)
  }
  expect_match(text$README, "mfrm_calibration_capabilities()", fixed = TRUE)
  expect_match(
    text$article,
    "score_mfrm_calibration(calibration, new_rows)",
    fixed = TRUE
  )

  public_text <- paste(unlist(text, use.names = FALSE), collapse = "\n")
  expect_false(grepl("mfrmr:::|CORE-[0-9]|G[0-6] exit|PublicAPIAuthorized",
                     public_text, perl = TRUE))
})

test_that("installed public API scores a saved artifact in a fresh process", {
  package_path <- normalizePath(find.package("mfrmr"), winslash = "/")
  library_roots <- normalizePath(.libPaths(), winslash = "/", mustWork = FALSE)
  package_is_installed <- dirname(package_path) %in% library_roots
  skip_if_not(
    package_is_installed,
    "Fresh-process evidence requires the check-installed package."
  )

  fixture <- calibration_public_fixture()
  artifact_path <- tempfile(fileext = ".rds")
  rows_path <- tempfile(fileext = ".rds")
  result_path <- tempfile(fileext = ".rds")
  script_path <- tempfile(fileext = ".R")
  paths <- c(artifact_path, rows_path, result_path, script_path)
  on.exit(unlink(paths), add = TRUE)
  save_mfrm_calibration(fixture$frozen, artifact_path)
  saveRDS(fixture$rows, rows_path, version = 3)

  script <- c(
    "args <- commandArgs(trailingOnly = TRUE)",
    ".libPaths(c(args[1L], .libPaths()))",
    "library(mfrmr)",
    "calibration <- load_mfrm_calibration(args[2L])",
    "rows <- readRDS(args[3L])",
    "result <- score_mfrm_calibration(calibration, rows)",
    "saveRDS(result, args[4L], version = 3)"
  )
  expect_false(any(grepl(":::|mfrmr_", script)))
  writeLines(script, script_path, useBytes = TRUE)
  rscript <- file.path(
    R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"
  )
  output <- suppressWarnings(system2(
    rscript,
    c(
      "--vanilla", shQuote(script_path), shQuote(dirname(package_path)),
      shQuote(artifact_path), shQuote(rows_path), shQuote(result_path)
    ),
    stdout = TRUE,
    stderr = TRUE
  ))
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  expect_identical(as.integer(status), 0L, info = paste(output, collapse = "\n"))
  expect_true(file.exists(result_path))
  result <- readRDS(result_path)
  expect_s3_class(result, "mfrm_calibration_score")
  expect_identical(result$settings$calibration_id, "public-api-rsm")
  expect_identical(result$settings$engine_identity, "artifact_coordinates_v1")
})
