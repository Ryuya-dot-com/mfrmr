# Repository-only current-head bridge for the frozen TAM MML core calibration.
#
# Source the 0.2.3 additive design, reference preflight, and TAM calibration
# first. This bridge preserves those historical files and reuses their
# numerical comparison on the 0.2.4 development namespace.

mfrmr_tmch_specification <- "0.2.4-tam-mml-core-current-head-v1"
mfrmr_tmch_contract <- "mfrmr_tam_mml_core_current_head_v1"

mfrmr_tmch_reference_namespace <- function(source_root = ".") {
  mfrmr_cq_additive_reference_requirements()
  if (!requireNamespace("mfrmr", quietly = TRUE)) {
    stop("Load the mfrmr development working tree before this check.",
         call. = FALSE)
  }
  source_root <- normalizePath(
    as.character(source_root)[1L], winslash = "/", mustWork = TRUE
  )
  source_version <- unname(read.dcf(
    file.path(source_root, "DESCRIPTION"), fields = "Version"
  )[1L, 1L])
  namespace <- asNamespace("mfrmr")
  namespace_path <- normalizePath(
    getNamespaceInfo(namespace, "path"), winslash = "/", mustWork = TRUE
  )
  required_internal <- c(
    "category_prob_rsm", "category_prob_pcm", "fit_mfrm"
  )
  available <- vapply(
    required_internal, exists, logical(1L), envir = namespace,
    inherits = FALSE
  )
  mfrmr_cq_additive_assert(
    identical(namespace_path, source_root) && all(available) &&
      startsWith(source_version, "0.2.4") &&
      identical(as.character(utils::packageVersion("mfrmr")), source_version),
    paste0(
      "The loaded mfrmr namespace is not the requested 0.2.4 source root; ",
      "use `pkgload::load_all(source_root)`."
    )
  )
  namespace
}

mfrmr_run_tam_mml_core_current_head <- function(source_root = ".") {
  scope <- environment(mfrmr_run_tam_mml_core_current_head)
  required <- c(
    "mfrmr_cq_additive_reference_namespace",
    "mfrmr_run_tam_mml_core_calibration"
  )
  present <- vapply(
    required, exists, logical(1L), envir = scope,
    mode = "function", inherits = FALSE
  )
  if (!all(present)) {
    stop("Source the frozen TAM MML calibration stack before this bridge.",
         call. = FALSE)
  }
  historical_namespace <- get(
    "mfrmr_cq_additive_reference_namespace", envir = scope,
    inherits = FALSE
  )
  assign(
    "mfrmr_cq_additive_reference_namespace",
    mfrmr_tmch_reference_namespace,
    envir = scope
  )
  on.exit(assign(
    "mfrmr_cq_additive_reference_namespace", historical_namespace,
    envir = scope
  ), add = TRUE)

  result <- mfrmr_run_tam_mml_core_calibration(source_root)
  result$historical_specification <- result$specification
  result$historical_contract_version <- result$contract_version
  result$specification <- mfrmr_tmch_specification
  result$contract_version <- mfrmr_tmch_contract
  result$source_version <- as.character(utils::packageVersion("mfrmr"))
  result$evidence_role <- "current_head_engineering_regression_only"
  result$stress_envelope_evaluated <- FALSE
  result
}
