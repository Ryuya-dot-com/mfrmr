# Post-result q121/q181 diagnostic for the retained TAM MML stress failure.
# Source tam-mml-release-stress-0.2.4.R first.

mfrmr_tmdd_specification <- "0.2.4-tam-mml-density-diagnostic-v1"
mfrmr_tmdd_contract <- "mfrmr_tam_mml_density_diagnostic_v1"

mfrmr_tmdd_require <- function() {
  required <- c(
    "mfrmr_tms_plan", "mfrmr_tms_generate", "mfrmr_tms_prepare_tam",
    "mfrmr_tms_compare_one", "mfrmr_tms_failed_comparison",
    "mfrmr_tms_integration_rows", "mfrmr_tms_runtime_identity"
  )
  scope <- environment(mfrmr_tmdd_require)
  present <- vapply(
    required, exists, logical(1L), envir = scope,
    mode = "function", inherits = TRUE
  )
  if (!all(present)) {
    stop("Source `tam-mml-release-stress-0.2.4.R` first.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_tmdd_plan <- function() {
  mfrmr_tmdd_require()
  base <- mfrmr_tms_plan()
  base <- base[!duplicated(base$DatasetId), , drop = FALSE]
  plan <- base[rep(seq_len(nrow(base)), each = 2L), , drop = FALSE]
  plan$Nodes <- rep(c(121L, 181L), times = nrow(base))
  plan$FitId <- sprintf("TMS-DIAG-%s-Q%03d", plan$DatasetId, plan$Nodes)
  plan$EvidenceRole <- "post_result_density_diagnostic_only"
  rownames(plan) <- NULL
  plan
}

mfrmr_run_tam_mml_density_diagnostic <- function(source_root = ".") {
  mfrmr_tmdd_require()
  runtime <- mfrmr_tms_runtime_identity(source_root)
  plan <- mfrmr_tmdd_plan()
  dataset_plan <- plan[!duplicated(plan$DatasetId), , drop = FALSE]
  cache <- lapply(seq_len(nrow(dataset_plan)), function(index) {
    data <- NULL
    tryCatch({
      data <- mfrmr_tms_generate(dataset_plan[index, , drop = FALSE])
      list(data = data, prepared = mfrmr_tms_prepare_tam(data), error = "")
    }, error = function(condition) {
      list(data = data, prepared = NULL, error = conditionMessage(condition))
    })
  })
  names(cache) <- dataset_plan$DatasetId
  runs <- lapply(seq_len(nrow(plan)), function(index) {
    row <- plan[index, , drop = FALSE]
    cached <- cache[[as.character(row$DatasetId)]]
    if (nzchar(cached$error)) {
      return(mfrmr_tms_failed_comparison(
        row, cached$data, cached$prepared, cached$error
      ))
    }
    tryCatch(
      mfrmr_tms_compare_one(row, cached$data, cached$prepared),
      error = function(condition) mfrmr_tms_failed_comparison(
        row, cached$data, cached$prepared, conditionMessage(condition)
      )
    )
  })
  summaries <- do.call(rbind, lapply(runs, `[[`, "summary"))
  surfaces <- do.call(rbind, lapply(runs, `[[`, "surface"))
  scores <- do.call(rbind, lapply(runs, `[[`, "scores"))
  rownames(summaries) <- rownames(surfaces) <- rownames(scores) <- NULL

  # Reuse the frozen q-pair implementation; only its two node labels are
  # aliased for the structural completeness check.
  aliased <- summaries
  aliased$Nodes <- ifelse(aliased$Nodes == 121L, 31L, 61L)
  integration <- mfrmr_tms_integration_rows(aliased, surfaces, scores)
  integration$LowNodes <- 121L
  integration$HighNodes <- 181L
  rownames(integration) <- NULL
  q181 <- summaries$Nodes == 181L
  diagnostic_complete <- nrow(summaries) == 42L &&
    nrow(integration) == 21L && all(runtime$IdentityMatch) &&
    all(summaries$Error == "") && all(summaries$PairPassed[q181]) &&
    all(integration$IntegrationPassed)
  list(
    specification = mfrmr_tmdd_specification,
    contract_version = mfrmr_tmdd_contract,
    status = if (diagnostic_complete) {
      "density_diagnostic_supports_integration_mechanism"
    } else {
      "density_diagnostic_requires_further_review"
    },
    runtime_identity = runtime,
    plan = plan,
    summaries = summaries,
    surfaces = surfaces,
    scores = scores,
    integration = integration,
    diagnostic_complete = diagnostic_complete,
    changes_frozen_42_pair_result = FALSE,
    release_authorized = FALSE
  )
}

mfrmr_write_tam_mml_density_diagnostic <- function(result, output_dir) {
  mfrmr_tms_assert(
    is.list(result) && identical(result$contract_version, mfrmr_tmdd_contract),
    "`result` is not a TAM MML density diagnostic."
  )
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  tables <- c(
    plan = "plan", summary = "summaries", surface = "surfaces",
    score = "scores", integration = "integration"
  )
  paths <- vapply(names(tables), function(name) {
    path <- file.path(
      output_dir, paste0("tam-mml-density-diagnostic-", name, "-0.2.4.csv")
    )
    utils::write.csv(result[[tables[[name]]]], path, row.names = FALSE, na = "")
    path
  }, character(1L))
  invisible(paths)
}
