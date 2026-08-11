# Repository-only privacy and licensing audit for retained external evidence.
# It reads tracked files and returns paths/counts, never matched secret values.

mfrmr_erba_sha256 <- function(path) {
  if (!requireNamespace("digest", quietly = TRUE) || !file.exists(path)) {
    return(NA_character_)
  }
  tryCatch(
    tolower(digest::digest(file = path, algo = "sha256")),
    error = function(...) NA_character_
  )
}

mfrmr_erba_tracked_files <- function(root) {
  output <- tryCatch(
    system2("git", c("-C", root, "ls-files"), stdout = TRUE,
            stderr = FALSE),
    error = function(...) character(0)
  )
  output <- enc2utf8(output[nzchar(output)])
  unique(output)
}

mfrmr_erba_is_text_path <- function(path) {
  base <- basename(path)
  extension <- tolower(tools::file_ext(path))
  base %in% c(
    "DESCRIPTION", "NAMESPACE", "LICENSE", "NEWS", "NEWS.md",
    ".gitignore", ".Rbuildignore", "cran-comments.md"
  ) || extension %in% c(
    "r", "rmd", "rd", "md", "txt", "csv", "tsv", "yml", "yaml",
    "json", "toml", "cff", "bib", "tex", "css", "js", "html"
  )
}

mfrmr_erba_has_executable_magic <- function(path) {
  bytes <- tryCatch(
    readBin(path, what = "raw", n = 4L),
    error = function(...) raw(0)
  )
  if (length(bytes) < 2L) return(FALSE)
  hex <- paste(sprintf("%02x", as.integer(bytes)), collapse = "")
  startsWith(hex, "4d5a") ||
    startsWith(hex, "7f454c46") ||
    hex %in% c(
      "feedface", "feedfacf", "cefaedfe", "cffaedfe", "cafebabe"
    )
}

mfrmr_erba_external_family <- function(path) {
  value <- tolower(path)
  out <- character(0)
  if (grepl("conquest", value, fixed = TRUE)) out <- c(out, "ConQuest")
  if (grepl("facets", value, fixed = TRUE)) out <- c(out, "FACETS")
  if (grepl("(^|[/_-])tam([/._-]|$)", value, perl = TRUE)) {
    out <- c(out, "TAM")
  }
  if (grepl("immer", value, fixed = TRUE)) out <- c(out, "immer")
  if (length(out) == 0L) NA_character_ else paste(out, collapse = "+")
}

mfrmr_erba_artifact_role <- function(path) {
  if (grepl("^tests/", path)) return("regression_test")
  if (grepl("^R/", path)) return("package_source")
  if (grepl("^man/|^vignettes/", path)) return("public_documentation")
  if (grepl("^inst/references/", path)) return("reference_contract")
  if (grepl("^inst/validation/.*[.]R$", path)) {
    return("repository_validator_or_runner")
  }
  if (grepl("^inst/validation/.*[.]md$", path)) {
    return("repository_contract_or_aggregate_record")
  }
  "repository_metadata"
}

mfrmr_erba_data_asset_class <- function(path) {
  if (grepl("^data/ej2021_[^/]+[.]rda$", path)) {
    return("documented_legacy_synthetic_design")
  }
  if (grepl("^data/mfrmr_example_[^/]+[.]rda$", path)) {
    return("generated_synthetic_package_example")
  }
  if (grepl("^inst/extdata/vignette-artifacts/[^/]+[.]csv$", path)) {
    return("synthetic_vignette_aggregate")
  }
  if (identical(path, "inst/references/facets_column_contract.csv")) {
    return("public_external_schema_contract")
  }
  if (grepl(
    paste0(
      "^inst/validation/(claim-disposition-profile|",
      "external-comparison-eligibility-fixtures|external-ic-fixtures|",
      "gpcm-model-identity-contract|ic-contract-fixtures|",
      "ic-free-dimension-fixtures|readiness-contract-fixtures|",
      "release-evidence-checklist)-[^/]+[.]csv$"
    ),
    path, perl = TRUE
  )) {
    return("repository_contract_or_synthetic_fixture")
  }
  if (identical(path, "tests/testthat/fixtures/mfrm-fit-0.2.2-pcm-jml.rds")) {
    return("synthetic_compatibility_fixture")
  }
  NA_character_
}

mfrmr_external_repository_boundary_audit <- function(
    root = ".",
    tracked_files = NULL,
    allowed_local_path_fixtures =
      "tests/testthat/test-bundle-summary-privacy.R") {
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  if (is.null(tracked_files)) {
    tracked_files <- mfrmr_erba_tracked_files(root)
  }
  tracked_files <- sort(
    unique(gsub("\\\\", "/", tracked_files)), method = "radix"
  )
  relative_paths_ok <- length(tracked_files) > 0L &&
    all(nzchar(tracked_files)) &&
    all(!grepl("^/|^[A-Za-z]:/|(^|/)\\.\\.(/|$)", tracked_files,
               perl = TRUE))
  full_paths <- file.path(root, tracked_files)
  files_resolve <- length(tracked_files) > 0L && all(file.exists(full_paths))

  external_family <- vapply(
    tracked_files, mfrmr_erba_external_family, character(1)
  )
  external <- !is.na(external_family)
  external_paths <- tracked_files[external]
  external_full_paths <- full_paths[external]
  external_hashes <- vapply(external_full_paths, mfrmr_erba_sha256,
                            character(1))
  artifact_manifest <- data.frame(
    Path = external_paths,
    Family = external_family[external],
    Role = vapply(external_paths, mfrmr_erba_artifact_role, character(1)),
    SHA256 = external_hashes,
    ContainsProprietarySoftware = FALSE,
    ContainsIdentifierBearingCaseData = FALSE,
    stringsAsFactors = FALSE
  )

  prohibited_binary_extensions <- c(
    "exe", "dmg", "pkg", "msi", "app", "lic", "key", "pem", "p12"
  )
  binary_extension <- tolower(tools::file_ext(tracked_files)) %in%
    prohibited_binary_extensions
  binary_magic <- vapply(full_paths, mfrmr_erba_has_executable_magic,
                         logical(1))
  prohibited_binary_paths <- unique(tracked_files[
    binary_extension | binary_magic
  ])
  prohibited_key_name <- grepl(
    "(license[-_. ]?key|activation[-_. ]?key|serial[-_. ]?(key|number))",
    basename(tracked_files), ignore.case = TRUE, perl = TRUE
  )
  prohibited_key_paths <- tracked_files[prohibited_key_name]

  case_extensions <- c(
    "sav", "zsav", "por", "dta", "sas7bdat", "xlsx", "xls", "dat",
    "rep", "out", "score"
  )
  identifier_case <- external &
    tolower(tools::file_ext(tracked_files)) %in% case_extensions
  identifier_case_paths <- tracked_files[identifier_case]

  data_asset <- tolower(tools::file_ext(tracked_files)) %in%
    c("csv", "tsv", "rds", "rda", "rdata")
  data_asset_paths <- tracked_files[data_asset]
  data_asset_classes <- vapply(
    data_asset_paths, mfrmr_erba_data_asset_class, character(1)
  )
  unclassified_data_asset_paths <- data_asset_paths[
    is.na(data_asset_classes)
  ]
  data_asset_manifest <- data.frame(
    Path = data_asset_paths,
    Class = data_asset_classes,
    SHA256 = vapply(
      file.path(root, data_asset_paths), mfrmr_erba_sha256, character(1)
    ),
    stringsAsFactors = FALSE
  )

  text_index <- which(vapply(tracked_files, mfrmr_erba_is_text_path,
                             logical(1)) & file.exists(full_paths))
  local_path_hits <- character(0)
  sensitive_material_hits <- character(0)
  user_root_pattern <- paste0("/", "Users", "/")
  home_root_pattern <- paste0("/", "home", "/")
  private_key_pattern <- paste0(
    "BEGIN ", "(RSA |EC |OPENSSH )?", "PRIVATE KEY"
  )
  assigned_key_pattern <- paste0(
    "(?i)(license|serial|activation)[_ -]?(key|code)",
    "[[:space:]]*[:=][[:space:]]*[\\\"']?",
    "[A-Za-z0-9+/=_-]{12,}"
  )
  for (i in text_index) {
    lines <- tryCatch(
      readLines(full_paths[i], warn = FALSE, encoding = "UTF-8"),
      error = function(...) character(0)
    )
    has_local_path <- any(grepl(user_root_pattern, lines, fixed = TRUE)) ||
      any(grepl(home_root_pattern, lines, fixed = TRUE)) ||
      any(grepl(
        "[A-Za-z]:[/\\\\](Users|Documents|Program Files)[/\\\\]",
        lines, perl = TRUE
      ))
    if (has_local_path) local_path_hits <- c(local_path_hits, tracked_files[i])
    has_sensitive_material <-
      any(grepl(private_key_pattern, lines, perl = TRUE)) ||
      any(grepl(assigned_key_pattern, lines, perl = TRUE))
    if (has_sensitive_material) {
      sensitive_material_hits <- c(sensitive_material_hits, tracked_files[i])
    }
  }
  local_path_hits <- unique(local_path_hits)
  allowed_local_path_hits <- intersect(
    local_path_hits, allowed_local_path_fixtures
  )
  prohibited_local_path_hits <- setdiff(
    local_path_hits, allowed_local_path_fixtures
  )

  bad_symlink_paths <- character(0)
  for (i in seq_along(full_paths)) {
    target <- Sys.readlink(full_paths[i])
    if (nzchar(target) &&
        (grepl("^/|^[A-Za-z]:[/\\\\]", target, perl = TRUE) ||
         grepl("(^|/)\\.\\.(/|$)", target, perl = TRUE))) {
      bad_symlink_paths <- c(bad_symlink_paths, tracked_files[i])
    }
  }

  manifest_hash <- if (nrow(artifact_manifest) == 0L ||
                       anyNA(artifact_manifest$SHA256)) {
    NA_character_
  } else {
    canonical <- apply(artifact_manifest, 1L, paste, collapse = "|")
    digest::digest(paste(canonical, collapse = "\n"), algo = "sha256",
                   serialize = FALSE)
  }
  findings <- data.frame(
    Finding = c(
      rep("proprietary_binary_or_key_extension",
          length(prohibited_binary_paths)),
      rep("license_or_serial_key_filename", length(prohibited_key_paths)),
      rep("identifier_bearing_external_case_extension",
          length(identifier_case_paths)),
      rep("unclassified_tracked_data_asset",
          length(unclassified_data_asset_paths)),
      rep("local_absolute_path", length(prohibited_local_path_hits)),
      rep("sensitive_key_material", length(sensitive_material_hits)),
      rep("external_or_parent_symlink", length(bad_symlink_paths))
    ),
    Path = c(
      prohibited_binary_paths, prohibited_key_paths, identifier_case_paths,
      unclassified_data_asset_paths, prohibited_local_path_hits,
      sensitive_material_hits, bad_symlink_paths
    ),
    stringsAsFactors = FALSE
  )
  complete_family_set <- all(
    c("ConQuest", "FACETS", "TAM", "immer") %in%
      unique(unlist(strsplit(artifact_manifest$Family, "+", fixed = TRUE)))
  )
  ready <- relative_paths_ok && files_resolve && nrow(artifact_manifest) > 0L &&
    all(!is.na(artifact_manifest$SHA256)) && complete_family_set &&
    nrow(findings) == 0L

  list(
    Decision = data.frame(
      Status = if (ready) "ok" else "concern",
      RepositoryBoundaryReady = ready,
      Interpretation = if (ready) {
        paste0(
          "tracked_external_sources_contracts_tests_and_aggregate_records_",
          "only_no_proprietary_binary_key_local_path_or_case_asset"
        )
      } else {
        "repository_boundary_concern_review_findings_without_exposing_values"
      },
      stringsAsFactors = FALSE
    ),
    Summary = data.frame(
      TrackedFiles = length(tracked_files),
      ExternalArtifacts = nrow(artifact_manifest),
      ExternalFamilies = length(unique(unlist(strsplit(
        artifact_manifest$Family, "+", fixed = TRUE
      )))),
      TrackedDataAssets = nrow(data_asset_manifest),
      UnclassifiedDataAssets = length(unclassified_data_asset_paths),
      AllowedSyntheticLocalPathFixtures = length(allowed_local_path_hits),
      ProhibitedFindings = nrow(findings),
      FilesResolve = files_resolve,
      RelativePathsOnly = relative_paths_ok,
      ExternalFamilySetComplete = complete_family_set,
      ManifestSHA256 = manifest_hash,
      stringsAsFactors = FALSE
    ),
    ArtifactManifest = artifact_manifest,
    DataAssetManifest = data_asset_manifest,
    AllowedLocalPathFixtures = allowed_local_path_hits,
    Findings = findings
  )
}
