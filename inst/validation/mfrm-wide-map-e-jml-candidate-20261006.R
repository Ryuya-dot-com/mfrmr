# E specialization of the retained corrected-JML research collector.
# The parameter map, interval arithmetic and availability rule are unchanged;
# the sampling law is declared from the frozen E input before any fit.
wide_e_jml_candidate <- function(input, spec, fitting, stage, level = .95) {
  bundle <- wide_e_bundle(input)
  stopifnot(identical(input$provenance$covariance_sampling, "random_rosters"))
  wide_recovery_plan(input, spec)
  stopifnot(spec$args$method == "JML", spec$args$model == "GPCM",
    spec$args$jml_correction_order %in% c(2L, 4L),
    spec$args$jml_correction_sampling == "random_rosters",
    is.finite(level), level > 0, level < 1, nzchar(stage))
  levels <- input$levels; owners <- levels$Criterion; ns <- length(input$categories)-1L
  sizes <- c(lengths(levels), rep(ns, length(owners)), length(owners))
  H <- as.matrix(Matrix::bdiag(lapply(sizes, mfrmr:::sum_zero_jacobian)))
  targets <- c(unlist(lapply(names(levels), function(f)
    paste("location", f, levels[[f]], sep = ":")), use.names = FALSE),
    unlist(lapply(owners, function(g) paste("step", "Criterion", g, seq_len(ns), sep = ":"))),
    paste("log_slope", "Criterion", owners, sep = ":"))
  reference <- c(unlist(input$truth[names(levels)], use.names = FALSE),
    as.vector(t(input$truth$steps)), unname(input$truth$log_slopes))
  for (facet in names(levels)) {
    ix <- match(paste("location", facet, levels[[facet]][1:2], sep = ":"), targets)
    H <- rbind(H, H[ix[1], ]-H[ix[2], ])
    targets <- c(targets, paste("contrast", facet, paste(levels[[facet]][1:2], collapse = "-"), sep = ":"))
    reference <- c(reference, input$truth[[facet]][1]-input$truth[[facet]][2])
  }
  plan <- data.frame(ConditionId = spec$ConditionId, Arm = spec$Arm, Replicate = spec$Replicate,
    InputId = input$InputId, Target = targets, Output = "interval", Eligibility = "eligible",
    Reference = "generating_parameter", ReferenceValue = reference,
    Procedure = paste0("corrected_jml_research_wald_order", spec$args$jml_correction_order, "_random_rosters_v1"),
    FormalStructuralInference = FALSE, Level = level)
  result <- plan[c("ConditionId", "Arm", "Replicate", "Target", "Output")]
  result$Status <- if (nzchar(fitting$error)) "error" else "returned"
  result$Available <- FALSE; result$Estimate <- result$SE <- result$Lower <- result$Upper <- NA_real_
  result$SourceStage <- stage; result$Reason <- fitting$error
  if (!nzchar(fitting$error)) {
    fit <- fitting$value; wide_recovery_fit_identity(fit, input, spec)
    a <- fit$jml_adjustment
    stopifnot(identical(a$persons, sort(unique(as.character(input$data$Person)))))
    stopifnot(identical(a$levels[names(levels)], levels),
      identical(a$estimator$formal_structural_intervals, FALSE))
    result$Reason <- paste("Research interval unavailable:", a$point$status, a$covariance$status,
      a$covariance$reason)
    if (isTRUE(a$point$available)) {
      stopifnot(length(a$point$beta) == ncol(H), all(is.finite(a$point$beta)))
      result$Estimate <- drop(H %*% a$point$beta)
      tables <- mfrmr:::mfrm_jml_adjustment_tables(a)
      check <- c(tables$facets$others$Estimate, tables$steps$Estimate, log(tables$slopes$Estimate))
      stopifnot(max(abs(head(result$Estimate, length(check))-check)) < 1e-10)
      if (identical(a$point$status, "consistent_roots") && isTRUE(a$covariance$available)) {
        V <- a$covariance$result$vcov
        stopifnot(identical(dim(V), c(ncol(H), ncol(H))), all(is.finite(V)),
          a$covariance$result$sampling == "random_rosters",
          nrow(a$covariance$result$scores) == length(a$persons),
          a$covariance$result$order == spec$args$jml_correction_order,
          max(abs(V-t(V))) < 1e-10)
        variance <- rowSums((H %*% V)*H)
        ok <- is.finite(variance) & variance > 0
        se <- sqrt(pmax(0, variance)); half <- stats::qnorm((1+level)/2)*se
        ok <- ok & is.finite(result$Estimate-half) & is.finite(result$Estimate+half)
        slope <- startsWith(targets, "log_slope:")
        ok[slope] <- ok[slope] & is.finite(exp(result$Estimate[slope]-half[slope])) &
          is.finite(exp(result$Estimate[slope]+half[slope]))
        result$Available <- ok; result$SE[ok] <- se[ok]
        result$Lower[ok] <- result$Estimate[ok]-half[ok]
        result$Upper[ok] <- result$Estimate[ok]+half[ok]
        result$Reason[ok] <- ""
        result$Reason[!ok] <- "Research interval requires positive finite variance and finite bounds"
        public_se <- c(tables$facets$others$RootSE, tables$steps$RootSE, tables$slopes$LogRootSE)
        stopifnot(max(abs(head(se, length(public_se))-public_se)) < 1e-10)
      }
    }
  }
  result$DisplayEstimate <- result$Estimate
  result$DisplayLower <- result$Lower; result$DisplayUpper <- result$Upper
  slope <- startsWith(targets, "log_slope:")
  for (field in c("DisplayEstimate", "DisplayLower", "DisplayUpper"))
    result[[field]][slope] <- exp(result[[field]][slope])
  list(plan = plan, records = result, rows = wide_output_records(plan, result),
    map = H, summary = wide_output_summary(plan, result),
    sampling = list(law = "random_rosters", PlannedPersons = length(bundle$persons),
      ObservedPersons = length(unique(input$data$Person)),
      target = "Local variation around the selected adjusted-equation root among contributing Persons"),
    interpretation = "Research pointwise interval candidate under random-roster sampling of contributing Persons; residual structural or mechanism bias may remain. Not a public formal CI.")
}
