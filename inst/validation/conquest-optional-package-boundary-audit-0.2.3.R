# Repository audit that keeps ConQuest an optional external comparator.
#
# Pure-R bundle construction and normalization APIs are package features. This
# audit forbids a ConQuest executable, invocation, fixed machine path, package
# dependency, or repository-only external test from entering package runtime
# or the ordinary source-package check surface.

mfrmr_cq_opba_specification <-
  "0.2.3-conquest-optional-package-boundary-audit-v1"
mfrmr_cq_opba_contract <-
  "mfrmr_conquest_optional_package_boundary_audit_v1"

mfrmr_cq_opba_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_opba_read_text <- function(paths) {
  paste(vapply(
    paths,
    function(path) paste(readLines(path, warn = FALSE), collapse = "\n"),
    character(1L)
  ), collapse = "\n")
}

mfrmr_cq_opba_buildignore_patterns <- function(pkg_dir) {
  path <- file.path(pkg_dir, ".Rbuildignore")
  mfrmr_cq_opba_assert(file.exists(path), ".Rbuildignore is required.")
  patterns <- readLines(path, warn = FALSE)
  patterns[nzchar(patterns)]
}

mfrmr_cq_opba_is_excluded <- function(paths, patterns) {
  vapply(paths, function(path) {
    any(vapply(patterns, grepl, logical(1L), x = path, perl = TRUE))
  }, logical(1L))
}

mfrmr_cq_opba_dependency_tokens <- function(pkg_dir) {
  description <- read.dcf(file.path(pkg_dir, "DESCRIPTION"))
  fields <- intersect(
    c("Depends", "Imports", "LinkingTo", "Suggests", "Enhances"),
    colnames(description)
  )
  text <- paste(description[1L, fields], collapse = ",")
  tokens <- trimws(unlist(strsplit(text, ",", fixed = TRUE)))
  sub("[[:space:]]*\\(.*$", "", tokens)
}

mfrmr_cq_opba_audit <- function(pkg_dir = ".") {
  pkg_dir <- normalizePath(pkg_dir, mustWork = TRUE)
  patterns <- mfrmr_cq_opba_buildignore_patterns(pkg_dir)
  relative_files <- list.files(
    pkg_dir, recursive = TRUE, all.files = TRUE,
    include.dirs = FALSE, no.. = TRUE
  )
  relative_files <- gsub("\\\\", "/", relative_files)
  included_files <- relative_files[
    !mfrmr_cq_opba_is_excluded(relative_files, patterns)
  ]

  r_files <- list.files(
    file.path(pkg_dir, "R"), pattern = "[.]R$", full.names = TRUE
  )
  r_text <- mfrmr_cq_opba_read_text(r_files)
  launch_pattern <- paste0(
    "\\b(?:system2|system|shell|Sys[.]which)\\s*\\(",
    "|processx::(?:run|process|process$new)\\s*\\("
  )
  fixed_path_pattern <- paste0(
    "/Applications/ConQuest|",
    "(?:^|[^[:alnum:]_])[A-Za-z]:[/\\\\][^\\n]*ConQuest|",
    "CONQUEST_EXECUTABLE|ConQuestCMD"
  )

  test_rel <- list.files(
    file.path(pkg_dir, "tests", "testthat"),
    pattern = "[.]R$", full.names = FALSE
  )
  test_paths <- paste0("tests/testthat/", test_rel)
  ordinary_test_rel <- test_rel[
    !mfrmr_cq_opba_is_excluded(test_paths, patterns)
  ]
  ordinary_test_files <- file.path(
    pkg_dir, "tests", "testthat", ordinary_test_rel
  )
  ordinary_conquest_files <- ordinary_test_files[vapply(
    ordinary_test_files,
    function(path) any(grepl(
      "ConQuest", readLines(path, warn = FALSE),
      ignore.case = TRUE, fixed = FALSE
    )),
    logical(1L)
  )]
  ordinary_conquest_text <- if (length(ordinary_conquest_files)) {
    mfrmr_cq_opba_read_text(ordinary_conquest_files)
  } else {
    ""
  }

  dependency_tokens <- mfrmr_cq_opba_dependency_tokens(pkg_dir)
  namespace <- readLines(file.path(pkg_dir, "NAMESPACE"), warn = FALSE)
  handoff_exports <- c(
    "build_conquest_overlap_bundle", "normalize_conquest_overlap_exports",
    "normalize_conquest_overlap_files", "normalize_conquest_overlap_tables",
    "review_conquest_overlap"
  )
  export_present <- vapply(
    handoff_exports,
    function(fun) paste0("export(", fun, ")") %in% namespace,
    logical(1L)
  )
  external_binary <- grepl(
    "(^|/)(conquest[^/]*|[^/]*conquest)[.](exe|app|bin|cmd|bat)$",
    included_files, ignore.case = TRUE, perl = TRUE
  )
  required_exclusions <- c(
    validation = "inst/validation",
    results = "validation-results",
    conquest_test = "tests/testthat/test-conquest-example.R"
  )
  exclusion_pass <- stats::setNames(
    mfrmr_cq_opba_is_excluded(unname(required_exclusions), patterns),
    names(required_exclusions)
  )

  pass <-
    !any(tolower(dependency_tokens) == "conquest") &&
    !grepl(launch_pattern, r_text, perl = TRUE) &&
    !grepl(fixed_path_pattern, r_text, ignore.case = TRUE, perl = TRUE) &&
    !grepl(launch_pattern, ordinary_conquest_text, perl = TRUE) &&
    !grepl(
      fixed_path_pattern, ordinary_conquest_text,
      ignore.case = TRUE, perl = TRUE
    ) &&
    !any(external_binary) && all(exclusion_pass) && all(export_present)

  list(
    specification = mfrmr_cq_opba_specification,
    contract_version = mfrmr_cq_opba_contract,
    status = if (pass) {
      "conquest_optional_package_boundary_passed"
    } else {
      "conquest_package_boundary_violation"
    },
    source_R_file_count = length(r_files),
    ordinary_test_file_count = length(ordinary_test_files),
    ordinary_conquest_API_test_file_count = length(ordinary_conquest_files),
    package_dependency_declared = any(tolower(dependency_tokens) == "conquest"),
    runtime_launch_primitive_detected = grepl(
      launch_pattern, r_text, perl = TRUE
    ),
    runtime_machine_path_detected = grepl(
      fixed_path_pattern, r_text, ignore.case = TRUE, perl = TRUE
    ),
    ordinary_test_launch_primitive_detected = grepl(
      launch_pattern, ordinary_conquest_text, perl = TRUE
    ),
    ordinary_test_machine_path_detected = grepl(
      fixed_path_pattern, ordinary_conquest_text,
      ignore.case = TRUE, perl = TRUE
    ),
    source_distribution_external_binary_detected = any(external_binary),
    validation_tree_excluded = unname(exclusion_pass["validation"]),
    validation_results_excluded = unname(exclusion_pass["results"]),
    external_conquest_tests_excluded = unname(exclusion_pass["conquest_test"]),
    pure_R_handoff_exports_present = all(export_present),
    source_build_and_check_observation_required = TRUE,
    conquest_available_during_ordinary_check_required = FALSE,
    pass = pass
  )
}
