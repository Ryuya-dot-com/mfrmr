# Repository-only current-source audit; no statistical or release pass is issued.
# From the package root:
# Rscript inst/validation/public-claim-evidence-audit-0.2.4.R /tmp/mfrmr-claim-audit

public_claim_evidence_audit <- function(output_directory) {
  stopifnot(file.exists("DESCRIPTION"), requireNamespace("pkgload", quietly = TRUE))
  inventory <- utils::read.csv(
    "inst/validation/public-claim-evidence-inventory-0.2.4.csv",
    stringsAsFactors = FALSE
  )
  ns <- readLines("NAMESPACE", warn = FALSE)
  declared <- grep("^(export|S3method)\\(", ns, value = TRUE)
  stopifnot(!anyDuplicated(inventory$Declaration),
            setequal(declared, inventory$Declaration),
            all(file.exists(inventory$SourceFile)),
            all(nzchar(inventory$ClaimGroups)))
  pkgload::load_all(".", quiet = TRUE)
  exports <- sub("^export\\((.*)\\)$", "\\1",
                 grep("^export\\(", ns, value = TRUE))
  stopifnot(all(vapply(exports, function(name) {
    is.function(getExportedValue("mfrmr", name))
  }, logical(1))))
  if (!dir.exists(output_directory)) {
    dir.create(output_directory, recursive = TRUE)
  }
  stopifnot(dir.exists(output_directory))
  data <- load_mfrmr_data("example_core")
  observations <- list()
  covariance_rows <- list()
  conditions <- character()
  for (method in c("MML", "JML")) {
    for (model in c("RSM", "PCM", "GPCM")) {
      withCallingHandlers({
        fit <- fit_mfrm(
          data, "Person", c("Rater", "Criterion"), "Score",
          method = method, model = model,
          step_facet = if (model == "RSM") NULL else "Criterion",
          slope_facet = if (model == "GPCM") "Criterion" else NULL,
          quad_points = 31L, maxit = 150L
        )
        diagnostics <- diagnose_mfrm(fit, residual_pca = "none")
        decision <- summary(fit, diagnostics = diagnostics)$decision
        for (bound in c(0.5, 5)) {
          # 5 is a deliberate diagnostic probe, not a recommended bound.
          eq <- tryCatch(analyze_facet_equivalence(
            fit, diagnostics = diagnostics, facet = "Rater",
            equivalence_bound = bound
          ), error = function(e) e)
          unavailable <- inherits(eq, "error")
          expected_ready <- method == "MML" && model %in% c("RSM", "PCM")
          stopifnot(identical(!unavailable, expected_ready))
          if (unavailable) {
            stopifnot(grepl("requires an inference-ready MML fit", conditionMessage(eq), fixed = TRUE))
          }
          observations[[length(observations) + 1L]] <- data.frame(
            Method = method, Model = model, EquivalenceBound = bound,
            FitReadiness = fit$readiness$fit$FitReadiness,
            FormalInference = decision$FormalInference,
            PrecisionTier = diagnostics$precision_profile$PrecisionTier,
            SupportsFormalInference = diagnostics$precision_profile$SupportsFormalInference,
            SlopeSEEligible = if (nrow(fit$slopes)) any(fit$slopes$SEEligible) else NA,
            EquivalenceDecision = if (unavailable) "unavailable" else eq$summary$Decision,
            EquivalencePairs = if (unavailable) NA_integer_ else eq$summary$PairwiseEquivalent,
            UnavailableReason = if (unavailable) conditionMessage(eq) else "",
            UnsupportedPositiveDecision = !isTRUE(diagnostics$precision_profile$SupportsFormalInference) &&
              !unavailable && isTRUE(eq$summary$AnyPairEquivalent),
            stringsAsFactors = FALSE
          )
          if (method == "MML" && model %in% c("RSM", "PCM") && bound == 0.5) {
            covariance <- mfrmr:::compute_mml_parameter_covariance(fit)
            stopifnot(identical(covariance$status, "ok"))
            spec <- fit$config$facet_specs$Rater
            slice <- covariance$param_slices$Rater
            jac <- mfrmr:::constraint_jacobian(spec)
            expanded <- jac %*% covariance$cov[slice, slice, drop = FALSE] %*% t(jac)
            for (i in seq_len(nrow(eq$pairwise))) {
              pair <- eq$pairwise[i, ]
              a <- match(pair$ElementA, spec$levels)
              b <- match(pair$ElementB, spec$levels)
              stopifnot(!is.na(a), !is.na(b))
              correct_se <- sqrt(expanded[a, a] + expanded[b, b] - 2 * expanded[a, b])
              covariance_rows[[length(covariance_rows) + 1L]] <- data.frame(
                Model = model, ElementA = pair$ElementA, ElementB = pair$ElementB,
                ReportedSE = pair$SE_Diff, CovarianceAwareSE = correct_se,
                CovarianceAB = expanded[a, b],
                RelativeSEError = pair$SE_Diff / correct_se - 1,
                stringsAsFactors = FALSE
              )
            }
          }
        }
      }, warning = function(w) {
        conditions <<- c(conditions, paste(method, model, conditionMessage(w), sep = ": "))
        invokeRestart("muffleWarning")
      })
    }
  }
  observations <- do.call(rbind, observations)
  covariance_rows <- do.call(rbind, covariance_rows)
  stopifnot(!any(observations$UnsupportedPositiveDecision),
            max(abs(covariance_rows$RelativeSEError)) < 1e-10)
  utils::write.csv(observations, file.path(output_directory, "runtime.csv"), row.names = FALSE)
  utils::write.csv(covariance_rows, file.path(output_directory, "covariance.csv"), row.names = FALSE)
  writeLines(conditions, file.path(output_directory, "warnings.txt"))
  writeLines(utils::capture.output(utils::sessionInfo()), file.path(output_directory, "session-info.txt"))
  print(observations, row.names = FALSE)
  cat("Namespace declarations mapped:", nrow(inventory), "\n")
  cat("Unsupported positive-decision rows:", sum(observations$UnsupportedPositiveDecision), "\n")
  cat("Maximum absolute relative contrast-SE discrepancy:",
      max(abs(covariance_rows$RelativeSEError)), "\n")
  invisible(list(runtime = observations, covariance = covariance_rows))
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  stopifnot(length(args) == 1L)
  public_claim_evidence_audit(args[[1L]])
}
