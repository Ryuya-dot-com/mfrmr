# Sharded non-CRAN regression evidence for the Draft.62 native JML policy.

mfrmr_native_regression_hash_file <- function(path) {
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_native_regression_hash_object <- function(value) {
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_native_regression_atomic_rds <- function(value, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  temporary <- paste0(path, ".tmp-", Sys.getpid())
  saveRDS(value, temporary)
  if (!file.rename(temporary, path)) stop(
    "Could not publish regression evidence atomically.", call. = FALSE
  )
  invisible(path)
}

mfrmr_native_regression_source_path <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "jml-recession-native-policy-regression-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) > 0L) return(normalizePath(
    hit[length(hit)], winslash = "/", mustWork = FALSE
  ))
  candidates <- c(
    file.path(
      "inst", "validation",
      "jml-recession-native-policy-regression-0.2.3.R"
    ),
    "jml-recession-native-policy-regression-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else normalizePath(
    path, winslash = "/", mustWork = TRUE
  )
})

mfrmr_native_regression_test_inventory <- function(test_dir) {
  paths <- sort(list.files(
    test_dir, pattern = "^test.*\\.R$", full.names = TRUE
  ))
  out <- data.frame(
    File = basename(paths),
    Bytes = as.numeric(file.info(paths)$size),
    SHA256 = vapply(
      paths, mfrmr_native_regression_hash_file, character(1)
    ),
    stringsAsFactors = FALSE
  )
  rownames(out) <- NULL
  out
}

mfrmr_native_regression_package_identity <- function(package = "mfrmr") {
  root <- normalizePath(
    system.file(package = package), winslash = "/", mustWork = TRUE
  )
  paths <- sort(list.files(root, recursive = TRUE, full.names = TRUE))
  paths <- paths[file.info(paths)$isdir %in% FALSE]
  prefix <- paste0(root, "/")
  relative <- substring(
    normalizePath(paths, winslash = "/", mustWork = TRUE),
    nchar(prefix) + 1L
  )
  inventory <- data.frame(
    File = relative,
    Bytes = as.numeric(file.info(paths)$size),
    SHA256 = vapply(
      paths, mfrmr_native_regression_hash_file, character(1)
    ),
    stringsAsFactors = FALSE
  )
  data.frame(
    Package = package,
    Version = as.character(utils::packageVersion(package)),
    Files = nrow(inventory),
    PackageSHA256 = mfrmr_native_regression_hash_object(inventory),
    stringsAsFactors = FALSE
  )
}

mfrmr_native_regression_warning_rows <- function(result, file) {
  rows <- list()
  cursor <- 0L
  for (test in result) {
    values <- test$results
    for (value in values) {
      if (inherits(value, "expectation_warning")) {
        cursor <- cursor + 1L
        rows[[cursor]] <- data.frame(
          File = file,
          Test = as.character(test$test),
          Message = as.character(value$message),
          stringsAsFactors = FALSE
        )
      }
    }
  }
  if (length(rows) == 0L) return(data.frame(
    File = character(0), Test = character(0), Message = character(0),
    stringsAsFactors = FALSE
  ))
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_run_native_regression_shard <- function(shard_id,
                                               total_shards,
                                               output_path,
                                               test_dir = "tests/testthat") {
  shard_id <- as.integer(shard_id)
  total_shards <- as.integer(total_shards)
  if (length(shard_id) != 1L || is.na(shard_id) || shard_id < 1L ||
      length(total_shards) != 1L || is.na(total_shards) ||
      total_shards < 1L || shard_id > total_shards) stop(
    "Regression shard identifiers are invalid.", call. = FALSE
  )
  if (file.exists(output_path) || dir.exists(output_path)) stop(
    "Regression shard output already exists.", call. = FALSE
  )
  required <- c("mfrmr", "testthat", "digest")
  available <- vapply(required, requireNamespace, logical(1), quietly = TRUE)
  if (any(!available)) stop(
    "Regression shard lacks: ",
    paste(required[!available], collapse = ", "), call. = FALSE
  )
  suppressPackageStartupMessages(library(mfrmr))
  Sys.setenv(NOT_CRAN = "true")
  test_dir <- normalizePath(test_dir, winslash = "/", mustWork = TRUE)
  inventory <- mfrmr_native_regression_test_inventory(test_dir)
  selected <- seq_len(nrow(inventory))
  selected <- selected[(selected - 1L) %% total_shards + 1L == shard_id]
  selected_inventory <- inventory[selected, , drop = FALSE]
  test_rows <- list()
  file_rows <- list()
  warning_rows <- list()
  test_cursor <- file_cursor <- warning_cursor <- 0L
  for (position in seq_len(nrow(selected_inventory))) {
    file <- selected_inventory$File[position]
    path <- file.path(test_dir, file)
    started <- unname(proc.time()[["elapsed"]])
    value <- tryCatch(
      testthat::test_file(
        path, reporter = "silent", package = "mfrmr"
      ),
      error = identity
    )
    elapsed <- max(0, unname(proc.time()[["elapsed"]]) - started)
    file_cursor <- file_cursor + 1L
    if (inherits(value, "error")) {
      file_rows[[file_cursor]] <- data.frame(
        File = file, Tests = 0L, Expectations = 0L, Passed = 0L,
        Failed = 0L, Errors = 1L, Warnings = 0L, Skips = 0L,
        ElapsedSeconds = elapsed,
        FatalError = conditionMessage(value),
        stringsAsFactors = FALSE
      )
      next
    }
    data <- as.data.frame(value)
    if (nrow(data) > 0L) {
      test_cursor <- test_cursor + 1L
      test_rows[[test_cursor]] <- data.frame(
        File = rep(file, nrow(data)),
        Test = as.character(data$test),
        Expectations = as.integer(data$nb),
        Passed = as.integer(data$passed),
        Failed = as.integer(data$failed),
        Error = as.logical(data$error),
        Warnings = as.integer(data$warning),
        Skipped = as.logical(data$skipped),
        RealSeconds = as.numeric(data$real),
        stringsAsFactors = FALSE
      )
    }
    warnings <- mfrmr_native_regression_warning_rows(value, file)
    if (nrow(warnings) > 0L) {
      warning_cursor <- warning_cursor + 1L
      warning_rows[[warning_cursor]] <- warnings
    }
    file_rows[[file_cursor]] <- data.frame(
      File = file,
      Tests = nrow(data),
      Expectations = sum(data$nb),
      Passed = sum(data$passed),
      Failed = sum(data$failed),
      Errors = sum(data$error),
      Warnings = sum(data$warning),
      Skips = sum(data$skipped),
      ElapsedSeconds = elapsed,
      FatalError = NA_character_,
      stringsAsFactors = FALSE
    )
  }
  tests <- if (length(test_rows) == 0L) data.frame(
    File = character(0), Test = character(0), Expectations = integer(0),
    Passed = integer(0), Failed = integer(0), Error = logical(0),
    Warnings = integer(0), Skipped = logical(0), RealSeconds = numeric(0),
    stringsAsFactors = FALSE
  ) else do.call(rbind, test_rows)
  files <- do.call(rbind, file_rows)
  warnings <- if (length(warning_rows) == 0L) data.frame(
    File = character(0), Test = character(0), Message = character(0),
    stringsAsFactors = FALSE
  ) else do.call(rbind, warning_rows)
  rownames(tests) <- rownames(files) <- rownames(warnings) <- NULL
  source_sha256 <- mfrmr_native_regression_hash_file(
    mfrmr_native_regression_source_path
  )
  package_identity <- mfrmr_native_regression_package_identity()
  output <- list(
    schema = "mfrmr-jml-recession-native-regression-shard-v1",
    shard_id = shard_id,
    total_shards = total_shards,
    runner_sha256 = source_sha256,
    package_identity = package_identity,
    full_test_inventory_sha256 =
      mfrmr_native_regression_hash_object(inventory),
    selected_inventory = selected_inventory,
    files = files,
    tests = tests,
    warnings = warnings,
    failures = sum(files$Failed),
    errors = sum(files$Errors),
    completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    session_info = utils::sessionInfo()
  )
  mfrmr_native_regression_atomic_rds(output, output_path)
  invisible(output)
}

mfrmr_native_regression_artifact_inventory <- function(root) {
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  paths <- sort(list.files(root, recursive = TRUE, full.names = TRUE))
  paths <- paths[file.info(paths)$isdir %in% FALSE]
  paths <- paths[basename(paths) != "run-complete.rds"]
  prefix <- paste0(root, "/")
  relative <- substring(
    normalizePath(paths, winslash = "/", mustWork = TRUE),
    nchar(prefix) + 1L
  )
  data.frame(
    File = relative,
    Bytes = as.numeric(file.info(paths)$size),
    SHA256 = vapply(
      paths, mfrmr_native_regression_hash_file, character(1)
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_aggregate_native_regression <- function(staging_dir,
                                               output_dir,
                                               total_shards = 10L,
                                               test_dir = "tests/testthat") {
  total_shards <- as.integer(total_shards)
  staging_dir <- normalizePath(
    staging_dir, winslash = "/", mustWork = TRUE
  )
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = FALSE)
  if (file.exists(output_dir) || dir.exists(output_dir)) stop(
    "Regression output already exists.", call. = FALSE
  )
  shard_paths <- file.path(
    staging_dir, "shards", sprintf("shard-%02d.rds", seq_len(total_shards))
  )
  if (any(!file.exists(shard_paths))) stop(
    "Regression shard set is incomplete.", call. = FALSE
  )
  shards <- lapply(shard_paths, function(path) tryCatch(
    readRDS(path), error = identity
  ))
  if (any(vapply(shards, inherits, logical(1), "error")) ||
      !all(vapply(shards, function(value) identical(
        value$schema,
        "mfrmr-jml-recession-native-regression-shard-v1"
      ), logical(1))) ||
      !identical(sort(vapply(shards, `[[`, integer(1), "shard_id")),
                 seq_len(total_shards)) ||
      any(vapply(shards, `[[`, integer(1), "total_shards") !=
          total_shards)) stop(
    "Regression shard schemas or identifiers are invalid.", call. = FALSE
  )
  runner_hashes <- unique(vapply(shards, `[[`, character(1), "runner_sha256"))
  package_hashes <- unique(vapply(shards, function(value) {
    value$package_identity$PackageSHA256
  }, character(1)))
  inventory_hashes <- unique(vapply(shards, `[[`, character(1),
                                     "full_test_inventory_sha256"))
  if (length(runner_hashes) != 1L || length(package_hashes) != 1L ||
      length(inventory_hashes) != 1L || !identical(
        runner_hashes,
        mfrmr_native_regression_hash_file(
          mfrmr_native_regression_source_path
        )
      )) stop(
    "Regression shards do not share exact source/package identity.",
    call. = FALSE
  )
  expected_inventory <- mfrmr_native_regression_test_inventory(test_dir)
  selected_inventory <- do.call(rbind, lapply(
    shards, `[[`, "selected_inventory"
  ))
  selected_inventory <- selected_inventory[
    match(expected_inventory$File, selected_inventory$File), , drop = FALSE
  ]
  rownames(selected_inventory) <- NULL
  if (anyNA(selected_inventory$File) ||
      anyDuplicated(do.call(rbind, lapply(
        shards, `[[`, "selected_inventory"
      ))$File) || !identical(selected_inventory, expected_inventory) ||
      !identical(
        mfrmr_native_regression_hash_object(expected_inventory),
        inventory_hashes
      )) stop(
    "Regression shards do not cover the exact test inventory once.",
    call. = FALSE
  )
  files <- do.call(rbind, lapply(shards, `[[`, "files"))
  tests <- do.call(rbind, lapply(shards, `[[`, "tests"))
  warning_values <- lapply(shards, `[[`, "warnings")
  warnings <- if (sum(vapply(warning_values, nrow, integer(1))) == 0L) {
    data.frame(
      File = character(0), Test = character(0), Message = character(0),
      stringsAsFactors = FALSE
    )
  } else do.call(rbind, warning_values[vapply(
    warning_values, nrow, integer(1)
  ) > 0L])
  files <- files[match(expected_inventory$File, files$File), , drop = FALSE]
  rownames(files) <- rownames(tests) <- rownames(warnings) <- NULL
  if (nrow(files) != nrow(expected_inventory) || anyNA(files$File) ||
      any(files$Failed > 0L) || any(files$Errors > 0L)) stop(
    "Full regression contains a failure, error, or missing file.",
    call. = FALSE
  )
  shard_summary <- do.call(rbind, lapply(shards, function(value) {
    data.frame(
      Shard = value$shard_id,
      Files = nrow(value$files),
      Tests = sum(value$files$Tests),
      Expectations = sum(value$files$Expectations),
      Passed = sum(value$files$Passed),
      Failed = sum(value$files$Failed),
      Errors = sum(value$files$Errors),
      Warnings = sum(value$files$Warnings),
      Skips = sum(value$files$Skips),
      stringsAsFactors = FALSE
    )
  }))
  run_summary <- data.frame(
    Schema = "mfrmr-jml-recession-native-regression-v1",
    Shards = total_shards,
    TestFiles = nrow(files),
    Tests = sum(files$Tests),
    Expectations = sum(files$Expectations),
    Passed = sum(files$Passed),
    Failed = sum(files$Failed),
    Errors = sum(files$Errors),
    Warnings = sum(files$Warnings),
    Skips = sum(files$Skips),
    RunnerSHA256 = runner_hashes,
    TestInventorySHA256 = inventory_hashes,
    InstalledPackageSHA256 = package_hashes,
    RegressionValidationComplete = TRUE,
    PackageCheckComplete = FALSE,
    ReplayBlockerResolved = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  package_identity <- shards[[1L]]$package_identity
  execution <- data.frame(
    Schema = "mfrmr-jml-recession-native-regression-identity-v1",
    RunnerSHA256 = runner_hashes,
    TestInventorySHA256 = inventory_hashes,
    InstalledPackageSHA256 = package_hashes,
    FileSummarySHA256 = mfrmr_native_regression_hash_object(files),
    TestSummarySHA256 = mfrmr_native_regression_hash_object(tests),
    WarningSummarySHA256 = mfrmr_native_regression_hash_object(warnings),
    ShardSummarySHA256 = mfrmr_native_regression_hash_object(shard_summary),
    RegressionValidationComplete = TRUE,
    PackageCheckComplete = FALSE,
    ReplayBlockerResolved = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  execution$ExecutionSHA256 <-
    mfrmr_native_regression_hash_object(execution)
  utils::write.csv(
    expected_inventory, file.path(staging_dir, "test-inventory.csv"),
    row.names = FALSE
  )
  utils::write.csv(
    files, file.path(staging_dir, "file-summary.csv"), row.names = FALSE,
    na = ""
  )
  utils::write.csv(
    tests, file.path(staging_dir, "test-summary.csv"), row.names = FALSE,
    na = ""
  )
  utils::write.csv(
    warnings, file.path(staging_dir, "warning-summary.csv"),
    row.names = FALSE, na = ""
  )
  utils::write.csv(
    shard_summary, file.path(staging_dir, "shard-summary.csv"),
    row.names = FALSE
  )
  utils::write.csv(
    package_identity, file.path(staging_dir, "package-identity.csv"),
    row.names = FALSE
  )
  utils::write.csv(
    execution, file.path(staging_dir, "execution-identity.csv"),
    row.names = FALSE
  )
  utils::write.csv(
    run_summary, file.path(staging_dir, "run-summary.csv"),
    row.names = FALSE
  )
  output <- list(
    schema = "mfrmr-jml-recession-native-regression-v1",
    test_inventory = expected_inventory,
    files = files,
    tests = tests,
    warnings = warnings,
    shard_summary = shard_summary,
    package_identity = package_identity,
    execution_identity = execution,
    run_summary = run_summary,
    regression_validation_complete = TRUE,
    package_check_complete = FALSE,
    replay_blocker_resolved = FALSE,
    confirmation_authorized = FALSE,
    session_info = utils::sessionInfo()
  )
  saveRDS(output, file.path(
    staging_dir, "jml-recession-native-regression.rds"
  ))
  saveRDS(utils::sessionInfo(), file.path(staging_dir, "session-info.rds"))
  inventory <- mfrmr_native_regression_artifact_inventory(staging_dir)
  marker <- list(
    schema = "mfrmr-jml-recession-native-regression-completion-v1",
    execution_sha256 = execution$ExecutionSHA256,
    artifacts = inventory,
    artifact_inventory_sha256 =
      mfrmr_native_regression_hash_object(inventory),
    completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    regression_validation_complete = TRUE,
    package_check_complete = FALSE,
    replay_blocker_resolved = FALSE,
    confirmation_authorized = FALSE
  )
  saveRDS(marker, file.path(staging_dir, "run-complete.rds"))
  if (!file.rename(staging_dir, output_dir)) stop(
    "Completed regression evidence could not be promoted.", call. = FALSE
  )
  invisible(output)
}

if (identical(environment(), globalenv()) && !interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) > 0L) {
    if (length(args) != 6L || !identical(args[1L], "shard")) stop(
      paste(
        "Usage: Rscript jml-recession-native-policy-regression-0.2.3.R",
        "shard ID TOTAL OUTPUT PACKAGE_LIB AUXILIARY_LIB"
      ),
      call. = FALSE
    )
    .libPaths(unique(c(
      normalizePath(args[5L], winslash = "/", mustWork = TRUE),
      normalizePath(args[6L], winslash = "/", mustWork = TRUE),
      .libPaths()
    )))
    mfrmr_run_native_regression_shard(
      shard_id = args[2L],
      total_shards = args[3L],
      output_path = args[4L]
    )
  }
}
