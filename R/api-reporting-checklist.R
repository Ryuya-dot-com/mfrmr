#' @aliases mfrm_report_checklist reporting_checklist
#' @rdname mfrm_report
#' @name mfrm_report_checklist
NULL

.mfrm_report_checklist <- function(fit,
                                diagnostics = NULL,
                                bias_results = NULL,
                                hierarchical_structure = NULL,
                                include_references = TRUE) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
  }
  if (is.null(diagnostics)) {
    diagnostics <- diagnose_mfrm(fit, residual_pca = "none")
  }
  if (!is.list(diagnostics) || is.null(diagnostics$obs)) {
    stop("`diagnostics` must be output from diagnose_mfrm().", call. = FALSE)
  }
  mfrm_results_validate_diagnostics_identity(fit, diagnostics,
                                             helper = "mfrm_report(fit, type = 'checklist')")
  mfrm_validate_bias_identity(fit, bias_results, helper = "mfrm_report(fit, type = 'checklist')")
  .ha_validate_data_identity(fit, hierarchical_structure)

  config <- fit$config %||% list()
  prep <- fit$prep %||% list()
  measures <- as.data.frame(diagnostics$measures %||% data.frame(), stringsAsFactors = FALSE)
  obs_df <- as.data.frame(diagnostics$obs %||% data.frame(), stringsAsFactors = FALSE)
  rel_df <- as.data.frame(diagnostics$reliability %||% data.frame(), stringsAsFactors = FALSE)
  precision_profile_df <- as.data.frame(diagnostics$precision_profile %||% data.frame(), stringsAsFactors = FALSE)
  steps_df <- as.data.frame(fit$steps %||% data.frame(), stringsAsFactors = FALSE)
  pca_obj <- diagnostics$pca %||%
    diagnostics$residual_pca_overall %||%
    diagnostics$residual_pca_by_facet %||%
    NULL

  br_in <- validate_bias_results_input(bias_results, helper = "mfrm_report(fit, type = 'checklist')")
  bias_error_tbl <- data.frame()
  bias_tbls <- list()
  if (!is.null(br_in)) {
    if (inherits(br_in, "mfrm_bias_collection")) {
      bias_error_tbl <- as.data.frame(br_in$errors %||% data.frame(), stringsAsFactors = FALSE)
      br_in <- br_in$by_pair %||% list()
    }
    if (inherits(br_in, "mfrm_bias")) {
      bias_tbls <- list(bias = as.data.frame(br_in$table %||% data.frame(), stringsAsFactors = FALSE))
    } else if (is.list(br_in) && !is.data.frame(br_in)) {
      nms <- names(br_in) %||% paste0("bias_", seq_along(br_in))
      for (i in seq_along(br_in)) {
        if (inherits(br_in[[i]], "mfrm_bias")) {
          bias_tbls[[nms[i]]] <- as.data.frame(br_in[[i]]$table %||% data.frame(), stringsAsFactors = FALSE)
        }
      }
    }
  }
  n_bias_errors <- if (is.data.frame(bias_error_tbl)) nrow(bias_error_tbl) else 0L

  convergence <- mfrm_convergence_state(fit)
  fit_readiness_record <- mfrmr_get_readiness_record(fit)
  converged <- convergence$inference_ready
  summary_msg <- if (is.data.frame(fit$summary) && "Message" %in% names(fit$summary)) {
    as.character(fit$summary$Message[1] %||% "")
  } else ""
  conv_msg <- as.character(convergence$detail %||% fit$opt$message %||% summary_msg %||% "")
  n_bias_pairs <- length(bias_tbls)
  has_bias_sig <- FALSE
  bias_stat_parse_issue <- FALSE
  if (n_bias_pairs > 0L) {
    has_bias_sig <- any(vapply(bias_tbls, function(tbl) {
      if (!is.data.frame(tbl) || nrow(tbl) == 0 || !"t" %in% names(tbl)) return(FALSE)
      raw_t <- as.character(tbl$t)
      t_vals <- suppressWarnings(as.numeric(raw_t))
      if (any(is.na(t_vals) & !is.na(raw_t) & nzchar(trimws(raw_t)))) bias_stat_parse_issue <<- TRUE
      any(is.finite(t_vals) & abs(t_vals) >= 2)
    }, logical(1)))
  }

  has_resid <- nrow(obs_df) > 0 && "StdResidual" %in% names(obs_df)
  has_meas <- nrow(measures) > 0 && "Estimate" %in% names(measures)
  has_fit <- has_meas && all(c("Infit", "Outfit") %in% names(measures))
  has_ci <- has_meas && "SE" %in% names(measures)
  has_rel <- nrow(rel_df) > 0
  precision_tier <- as.character(precision_profile_df$PrecisionTier[1] %||% NA_character_)
  formal_precision <- isTRUE(precision_profile_df$SupportsFormalInference[1] %||% FALSE) && converged
  measure_formal <- if (has_meas && "SupportsFormalInference" %in% names(measures)) {
    any(as.logical(measures$SupportsFormalInference), na.rm = TRUE)
  } else formal_precision
  ci_ready <- if (has_meas && "CIEligible" %in% names(measures)) {
    any(as.logical(measures$CIEligible), na.rm = TRUE)
  } else has_ci && formal_precision
  has_steps <- nrow(steps_df) > 0
  has_pca <- !is.null(pca_obj) && length(pca_obj) > 0
  has_counts <- has_resid && "Observed" %in% names(obs_df)
  has_person_measure <- has_resid && "PersonMeasure" %in% names(obs_df)
  subset_summary_df <- as.data.frame(diagnostics$subsets$summary %||% data.frame(), stringsAsFactors = FALSE)
  has_subsets <- !is.null(diagnostics$subsets) && nrow(subset_summary_df) > 0L
  subset_count <- if (has_subsets) nrow(subset_summary_df) else NA_integer_
  common_scale_linked <- identical(subset_count, 1L)
  connectivity_detail <- if (!has_subsets) {
    "No subset/connectivity output"
  } else if (common_scale_linked) {
    "One connected subset; the observed design satisfies the graph-connectivity requirement. Review other identification and design assumptions separately."
  } else {
    paste0(subset_count, " disconnected subsets; connectivity was assessed, but cross-subset comparisons require a reviewed linking design before reporting.")
  }
  marginal_fit_bundle <- diagnostics$marginal_fit %||% list()
  strict_marginal_available <- isTRUE(marginal_fit_bundle$available)
  strict_pairwise_available <- isTRUE(marginal_fit_bundle$pairwise$available)
  strict_marginal_reason <- if (strict_marginal_available) {
    if (strict_pairwise_available) {
      "Strict marginal first-order and pairwise bundles are available for plotting."
    } else {
      "Strict marginal first-order bundle is available, but pairwise follow-up is unavailable."
    }
  } else {
    as.character(
      marginal_fit_bundle$summary$Reason[1] %||%
        marginal_fit_bundle$notes[1] %||%
        "Strict marginal diagnostics are unavailable for the current run."
    )
  }
  fit_df_review_available <- nrow(measures) > 0 &&
    all(c("DF_Infit_FACETS", "DF_Outfit_FACETS", "InfitZSTD_FACETS", "OutfitZSTD_FACETS") %in% names(measures))
  fit_separation_boundary_available <- has_fit || has_rel || fit_df_review_available
  fit_separation_boundary_detail <- paste0(
    "MnSq fit=", if (has_fit) "available" else "missing",
    "; separation/reliability=", if (has_rel) "available" else "missing",
    "; df/ZSTD review=", if (fit_df_review_available) "available" else "not requested"
  )
  population <- fit$population %||% list()
  population_active <- isTRUE(population$active)
  population_is_gpcm_identification <- population_active &&
    identical(as.character(population$source %||% ""), "gpcm_mml_default_identification")
  population_coefficients <- as.numeric(population$coefficients %||% numeric(0))
  population_coefficients_finite <- length(population_coefficients) > 0L && all(is.finite(population_coefficients))
  population_sigma2 <- suppressWarnings(as.numeric(population$sigma2 %||% NA_real_))
  population_formula <- if (!is.null(population$formula)) paste(deparse(population$formula), collapse = " ") else ""
  population_posterior_basis <- as.character(population$posterior_basis %||% "legacy_mml")
  population_coding <- population_coding_summary_table(population)
  population_design_columns <- as.character(population$design_columns %||% character(0))
  population_omitted_persons <- length(population$omitted_persons %||% character(0))
  population_omitted_rows <- suppressWarnings(as.integer(population$response_rows_omitted %||% 0L))
  if (!is.finite(population_omitted_rows)) population_omitted_rows <- 0L

  finalize_schema_rows <- function(schema, avail_vec, ready_vec, detail_vec, avail_act_override = NULL) {
    avail_vec <- as.logical(avail_vec) & !is.na(avail_vec)
    ready_vec <- as.logical(ready_vec) & !is.na(ready_vec)
    sev_pri <- c(required = "high", recommended = "medium", optional = "low")
    priority <- ifelse(ready_vec, "ready", unname(sev_pri[schema$Severity]))
    avail_act <- schema$AvailableAction
    if (!is.null(avail_act_override)) {
      keep_ov <- !is.na(avail_act_override) & nzchar(avail_act_override)
      avail_act[keep_ov] <- avail_act_override[keep_ov]
    }
    empty_act <- is.na(avail_act) | !nzchar(avail_act)
    avail_act[empty_act] <- ifelse(
      ready_vec[empty_act],
      "Available; adapt this evidence into the manuscript draft after methodological review.",
      "Available, but keep the documented cautionary language when drafting."
    )
    data.frame(
      Section = schema$Section,
      Item = schema$Item,
      Available = avail_vec,
      DraftReady = ready_vec,
      ReadyForAPA = ready_vec,
      Severity = schema$Severity,
      Priority = as.character(priority),
      SourceComponent = schema$SourceComponent,
      Detail = as.character(detail_vec),
      PlotHelper = schema$PlotHelper,
      DrawFreeRoute = schema$DrawFreeRoute,
      PlotReturnClass = schema$PlotReturnClass,
      NextAction = as.character(ifelse(avail_vec, avail_act, schema$MissingAction)),
      stringsAsFactors = FALSE
    )
  }

  flag <- suppressWarnings(as.character(fit$summary$FacetSampleSizeFlag %||% NA_character_))
  min_n <- suppressWarnings(as.integer(fit$summary$FacetMinLevelN %||% NA_integer_))
  sparse_n <- suppressWarnings(as.integer(fit$summary$FacetSparseCount %||% NA_integer_))
  has_rmse_tsd <- has_rel && any(c("RMSE", "TrueSD") %in% names(rel_df))
  has_bias_any <- n_bias_pairs > 0 || n_bias_errors > 0
  has_obs_rows <- nrow(obs_df) > 0

  core_avail <- c(
    !is.null(config$model) && !is.null(config$method),
    is.finite(as.numeric(prep$n_obs %||% NA)),
    nrow(precision_profile_df) > 0,
    converged,
    has_subsets,
    TRUE,
    !is.na(flag) && flag %in% c("sparse", "marginal", "standard", "strong"),
    !is.null(hierarchical_structure),
    has_resid,
    has_pca,
    fit_separation_boundary_available,
    has_rel,
    has_rel,
    has_rmse_tsd,
    has_ci,
    has_ci,
    has_fit,
    has_fit,
    has_counts,
    has_person_measure,
    has_steps,
    has_steps,
    has_bias_any,
    has_bias_any,
    TRUE,
    has_obs_rows,
    has_pca,
    has_subsets,
    has_fit || has_resid,
    strict_marginal_available,
    has_bias_any,
    converged,
    has_fit || has_steps
  )

  core_ready <- core_avail
  core_ready[5L] <- common_scale_linked
  core_ready[11L] <- fit_separation_boundary_available
  core_ready[12L] <- has_rel && formal_precision
  core_ready[13L] <- has_rel && formal_precision
  core_ready[15L] <- has_ci && measure_formal
  core_ready[16L] <- ci_ready
  core_ready[24L] <- FALSE
  core_ready[30L] <- FALSE
  core_ready[31L] <- FALSE
  core_ready[32L] <- converged && formal_precision

  hs_detail <- if (!is.null(hierarchical_structure)) {
    hs_sum <- hierarchical_structure$summary
    paste0(
      "Hierarchical review available for ", paste(hierarchical_structure$facets, collapse = ", "),
      if (!is.null(hierarchical_structure$data_identity$person)) paste0(" (person column: ", hierarchical_structure$data_identity$person, ")") else "",
      "; ", hierarchical_structure$data_identity$rows, " retained rating rows, ",
      hs_sum$NestedPairs %||% 0L, " nested pair(s), ",
      hs_sum$CrossedPairs %||% 0L, " crossed pair(s)",
      if (isTRUE(hs_sum$ICCAvailable)) "; ICC available" else "; ICC not available", "."
    )
  } else {
    "Structural review (nesting, ICC, design effect) is optional but recommended when raters, criteria, or persons span strata (regions, schools, cohorts) that additive fixed-effects MFRM cannot partition out."
  }

  core_detail <- c(
    sprintf("Model=%s; Method=%s", as.character(config$model %||% "NA"), as.character(config$method %||% "NA")),
    sprintf("%s observations; %s persons; %s categories (%s-%s)",
            format(prep$n_obs %||% NA, big.mark = ","), format(prep$n_person %||% NA, big.mark = ","),
            as.character(config$n_cat %||% NA), as.character(prep$rating_min %||% NA), as.character(prep$rating_max %||% NA)),
    if (nrow(precision_profile_df) > 0) paste0("Precision tier = ", precision_tier, "; ", as.character(precision_profile_df$RecommendedUse[1] %||% "")) else "No precision-profile summary",
    if (nzchar(conv_msg)) conv_msg else if (converged) "Optimizer diagnostics support inference-ready status." else "Optimizer diagnostics require review before inference.",
    connectivity_detail,
    if (!identical(as.character(config$facet_shrinkage %||% "none"), "none")) "A post-hoc zero-centered adjustment is recorded. Check its target, omitted covariance and conditional SEs; shrinkage does not establish adequate precision." else "Original fixed-effects estimates are retained. Small counts alone do not require shrinkage or establish that these estimates are stable.",
    if (is.na(flag)) "Rating-count screening flag unavailable in fit summary." else sprintf("Lowest count band: %s (minimum retained rows per level = %s; sparse levels = %s). Count labels do not establish precision or coverage.", flag, if (is.na(min_n)) NA_character_ else as.character(min_n), if (is.na(sparse_n)) NA_character_ else as.character(sparse_n)),
    hs_detail,
    if (has_resid) "Observation-level standardized residuals available" else "No standardized residuals",
    if (has_pca) "Residual PCA output available" else "Residual PCA not computed",
    fit_separation_boundary_detail,
    if (has_rel) (if (formal_precision) "Facet separation/reliability table available with model-based precision" else "Facet separation/reliability table available as an exploratory precision summary") else "No reliability table",
    if (has_rel) (if (formal_precision) "Facet-level variability summary available with fixed/random reference statistics" else "Facet-level variability summary available, but precision is not fully model-based") else "No variability summary",
    if (has_rmse_tsd) "RMSE/True SD columns present" else "RMSE/True SD not found",
    if (has_ci) (if (formal_precision) "Element estimates with model-based SE / ModelSE are available" else "Element estimates with exploratory SE / ModelSE are available") else "Estimate/SE columns not complete",
    if (has_ci) (if (formal_precision) "Approximate normal CIs can be derived from Estimate +/- 1.96 * SE" else "Exploratory normal CIs can be derived from Estimate +/- 1.96 * SE") else "SE not available",
    if (has_fit) "Infit/Outfit columns available" else "Fit statistics not complete",
    if (has_fit) "Misfit counts can be summarized from element fit" else "No fit table for misfit counting",
    if (has_counts) "Observed score distribution available" else "Observed score counts unavailable",
    if (has_person_measure) "Person measures can be summarized by observed category" else "Person measures unavailable",
    if (has_steps) "Step/threshold table available" else "No step table",
    if (has_steps) "Curve inputs available from threshold table" else "No step table for curves",
    if (n_bias_errors > 0) sprintf("%d bias result bundle(s); %d requested pair(s) failed", n_bias_pairs, n_bias_errors) else sprintf("%d bias result bundle(s)", n_bias_pairs),
    if (n_bias_errors > 0) sprintf("Bias screening completed for %d bundle(s), but %d requested pair(s) failed; review the bias collection errors before interpreting screen-positive counts.", n_bias_pairs, n_bias_errors) else if (bias_stat_parse_issue) "Bias screening output included non-numeric screening statistics; verify the bias tables before interpreting screen-positive counts." else if (has_bias_sig) "At least one interaction row exceeded the screening threshold." else if (n_bias_pairs > 0) "Bias screening was run and no interaction rows crossed the current screening threshold." else "No bias screening output available.",
    "Supported by plot.mfrm_fit() / plot(x, type = \"wright\", view = \"unified\")",
    if (has_obs_rows) "plot(x, type = \"qc\") / plot(x, type = \"facet_dashboard\") can use the current diagnostics bundle" else "No observation-level diagnostics for dashboard plotting",
    if (has_pca) "plot(x, type = \"residual_pca\") can render scree/loadings from the current residual PCA bundle" else "Residual PCA not computed",
    if (has_subsets) paste0("subset_connectivity_report() and plot(..., type = \"design_matrix\") can use the current subset bundle; ", connectivity_detail) else "No subset/connectivity bundle available",
    if (has_fit || has_resid) "plot(x, type = \"displacement\") is available; plot(x, type = \"agreement\") is available when a rater facet is present" else "No fit/residual inputs for displacement or inter-rater visuals",
    strict_marginal_reason,
    if (n_bias_errors > 0) "plot(x, type = \"bias\") can use the current bias bundle, but failed pair requests should be reviewed before interpretation" else if (n_bias_pairs > 0) "plot(x, type = \"bias\") can use the current bias bundle; use plot(x, type = \"heatmap\") when a DIF result is available" else "No bias screening bundle available",
    if (converged) "compute_information() / plot(x) are available for the current fitted model" else "Information curves are not recommended until convergence is resolved",
    if (has_fit || has_steps) "Plotting inputs available for fit/category visuals" else "No fit or step visuals available"
  )

  core_act_ov <- rep(NA_character_, 33L)
  core_act_ov[3L] <- if (formal_precision) "Report the precision tier as model-based in the APA narrative." else "Report the precision tier explicitly and keep the exploratory/hybrid caution in the APA narrative."
  core_act_ov[5L] <- if (common_scale_linked) "Document the single connected subset before making common-scale claims." else "Do not make cross-subset or common-scale claims until the design or an external linking justification has been reviewed."
  core_act_ov[12L] <- if (formal_precision) "Report facet reliability/separation directly in the APA results section." else "Report facet reliability/separation as exploratory or hybrid, not as formal inferential evidence."
  core_act_ov[13L] <- if (formal_precision) "Use the fixed/random variability summary in the results text or table notes." else "Describe the variability summary as exploratory or screening-oriented."
  core_act_ov[15L] <- if (formal_precision) "Use ModelSE/RealSE language consistently in tables and notes." else "Use the available SE columns, but label them as exploratory or fit-adjusted summaries."
  core_act_ov[16L] <- if (formal_precision) "Report approximate normal intervals if they are substantively useful." else "If reported, label the intervals as approximate and exploratory."
  core_act_ov[32L] <- if (formal_precision) "Use information curves to describe precision across theta when that is the reporting question." else "Use information curves descriptively and keep the current precision-tier caveat in the narrative."

  checklist <- finalize_schema_rows(
    .mfrmr_table_report_checklist_core_schema,
    core_avail, core_ready, core_detail, core_act_ov
  )

  if (population_active) {
    pop_sc <- .mfrmr_table_report_checklist_pop_schema
    if (population_is_gpcm_identification) {
      pop_sc$Item[1L] <- "GPCM population-scale identification basis"
    }
    coding_detail <- if (nrow(population_coding) > 0L) {
      paste0("Stored coding for ", paste(population_coding$Variable, collapse = ", "),
             "; encoded columns: ", paste(population_coding$EncodedColumns[nzchar(population_coding$EncodedColumns)], collapse = ", "))
    } else {
      "No categorical coding was recorded; formula appears intercept-only, numeric, or logical."
    }
    if (!nzchar(coding_detail)) coding_detail <- "No encoded categorical columns recorded."
    omission_detail <- paste0("Omitted persons = ", population_omitted_persons, "; omitted response rows = ", population_omitted_rows, "; policy = ", as.character(population$policy %||% NA_character_))
    pop_avail <- c(
      population_active && identical(population_posterior_basis, "population_model"),
      population_coefficients_finite && is.finite(population_sigma2),
      length(population_design_columns) > 0L,
      TRUE, TRUE, TRUE
    )
    pop_ready <- c(
      pop_avail[1L],
      pop_avail[2L] && population_sigma2 > 0,
      pop_avail[3L],
      population_omitted_persons == 0L && population_omitted_rows == 0L,
      TRUE, FALSE
    )
    pop_detail <- c(
      paste0("Formula=", population_formula, "; posterior basis=", population_posterior_basis, "; model=", as.character(config$model %||% NA_character_), "; method=", as.character(config$method %||% NA_character_)),
      paste0(length(population_coefficients), " coefficient(s); residual variance = ", if (is.finite(population_sigma2)) signif(population_sigma2, 4) else NA_real_),
      coding_detail,
      omission_detail,
      "Active latent-regression scoring should condition on the fitted population model; new-person scoring requires matching `person_data` when covariates are present.",
      if (population_is_gpcm_identification) "An exact probability/coordinate map exists for item-only GPCM MML and ConQuest scoresfree; multifacet generalized-item equivalence remains unproved and the public external-table bundle does not yet cover GPCM." else "Current public external-table overlap is narrow RSM/PCM unidimensional conditional-normal latent regression."
    )
    pop_act_ov <- c(
      if (population_is_gpcm_identification) "Describe the intercept-only population model as the GPCM MML scale-identification basis, not as a substantive covariate regression." else "Describe the fit as a conditional-normal latent-regression MML model, not as a post hoc regression on EAP/MLE scores.",
      if (population_is_gpcm_identification) "Report the population intercept and variance as GPCM location/scale coordinates; use population SD times relative slope for fixed-latent-SD discrimination comparisons." else "Report coefficients and residual variance as conditional-normal population-model parameters, with scale/coding notes.",
      NA_character_,
      if (population_omitted_persons == 0L && population_omitted_rows == 0L) "State that no persons were omitted by the population-model covariate policy." else "Document the complete-case policy and omitted-person/row counts before reporting latent-regression results.",
      NA_character_,
      if (population_is_gpcm_identification) "Use conservative wording: the exact ConQuest GPCM map is item-only and parameterization-level; it is not a many-facet or accepted external-equivalence claim." else "Use conservative wording: ConQuest overlap is limited to the documented latent-regression MML comparison scope."
    )
    checklist <- rbind(checklist, finalize_schema_rows(pop_sc, pop_avail, pop_ready, pop_detail, pop_act_ov))
  }

  section_summary <- checklist |>
    dplyr::group_by(.data$Section) |>
    dplyr::summarise(
      Items = dplyr::n(),
      Available = sum(.data$Available, na.rm = TRUE),
      DraftReady = sum(.data$DraftReady, na.rm = TRUE),
      ReadyForAPA = sum(.data$ReadyForAPA, na.rm = TRUE),
      Missing = .data$Items - .data$Available,
      NeedsDraftWork = .data$Items - .data$DraftReady,
      NeedsAction = .data$Items - .data$ReadyForAPA,
      .groups = "drop"
    )

  model_up <- toupper(as.character(config$model %||% NA_character_))[1L]
  method_up <- toupper(as.character(config$method %||% config$method_input %||% NA_character_))
  conquest_candidate <- population_active && identical(method_up, "MML") && model_up %in% c("RSM", "PCM")
  software_scope <- .mfrmr_table_external_software_scope_base
  software_scope$CurrentSupport[3L] <- if (conquest_candidate) "candidate fit; additional documented comparison restrictions apply" else "not active for this fit"

  vis_status <- function(item) {
    row <- checklist[checklist$Section == "Visual Displays" & checklist$Item == item, , drop = FALSE]
    if (nrow(row) == 0L) return("not listed in reporting checklist")
    if (isTRUE(row$Available[1L])) return("available for current fit")
    paste0("not ready for current fit: ", as.character(row$NextAction[1L]))
  }
  has_step_est <- nrow(steps_df) > 0 && "Estimate" %in% names(steps_df)
  surface_status <- if (has_step_est && model_up %in% c("RSM", "PCM", "GPCM")) {
    "active plot-data route for current fit"
  } else if (!(model_up %in% c("RSM", "PCM", "GPCM"))) {
    paste0("not active for current model: ", model_up)
  } else {
    "not ready for current fit: step/threshold estimates are required"
  }
  visual_scope <- .mfrmr_table_visual_scope_base
  visual_scope$CurrentSupport <- c(
    vis_status("QC / facet dashboard"),
    vis_status("Wright map"),
    vis_status("Fit/category visuals"),
    surface_status,
    vis_status("Precision / information curves"),
    vis_status("Strict marginal visuals"),
    vis_status("Bias / DIF visuals"),
    vis_status("Residual PCA visuals")
  )

  out <- list(
    checklist = checklist,
    fit_readiness = as.data.frame(fit_readiness_record$fit, stringsAsFactors = FALSE),
    fit_readiness_components = as.data.frame(fit_readiness_record$components %||% data.frame(), stringsAsFactors = FALSE),
    fit_readiness_parameters = as.data.frame(fit_readiness_record$parameters %||% mfrmr_readiness_empty_parameter_table, stringsAsFactors = FALSE),
    summary = as.data.frame(section_summary, stringsAsFactors = FALSE),
    section_summary = as.data.frame(section_summary, stringsAsFactors = FALSE),
    software_scope = software_scope,
    facets_positioning = facets_guide("positioning"),
    visual_scope = visual_scope,
    references = if (isTRUE(include_references)) .mfrmr_table_reporting_checklist_data else data.frame(),
    settings = list(
      include_references = isTRUE(include_references),
      diagnostics_supplied = !missing(diagnostics) && !is.null(diagnostics),
      bias_result_count = n_bias_pairs,
      bias_error_count = n_bias_errors,
      precision_tier = precision_tier
    )
  )
  as_mfrm_bundle(out, "mfrm_reporting_checklist")
}

#' @rdname mfrm_report
#' @details `summary()` method: Summarize a reporting-checklist bundle for manuscript work
#' @param object Output from [mfrm_report_checklist].
#' @param top_n Maximum number of draft-action rows shown in the compact action
#'   table.
#' @param ... Reserved for generic compatibility.
#' @return For `summary()`: An object of class `summary.mfrm_reporting_checklist` with:
#' - `overview`: run-level counts of available and draft-ready items
#' - `section_summary`: section-level checklist coverage
#' - `software_scope`: external-software relationship summary
#' - `facets_positioning`: report-ready FACETS relationship wording
#' - `visual_scope`: available plots and data for custom rendering, including
#'   the main `InterpretationCheck` caveat for each type of plot
#' - `priority_summary`: counts by priority/severity
#' - `action_items`: highest-priority rows that still need draft work
#' - `settings`: checklist settings rendered as a compact table
#' - `notes`: interpretation notes
#' @seealso [mfrm_report_checklist], [summary.mfrm_apa_outputs]
#' @examples # Long-running workflow; run explicitly when needed.
#' # example("summary.mfrm_reporting_checklist", run.dontrun = TRUE)
#' \dontrun{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "MML", quad_points = 7, maxit = 30)
#' diag <- diagnose_mfrm(fit, residual_pca = "both", diagnostic_mode = "both")
#' chk <- mfrm_report(type = "checklist", fit, diagnostics = diag)
#' summary(chk)
#' }
#' @method summary mfrm_reporting_checklist
#' @export
summary.mfrm_reporting_checklist <- function(object, top_n = 10, ...) {
  if (!inherits(object, "mfrm_reporting_checklist")) {
    stop("`object` must be output from mfrm_report(fit, type = 'checklist').", call. = FALSE)
  }

  top_n <- max(1L, as.integer(top_n[1]))
  checklist <- as.data.frame(object$checklist %||% data.frame(), stringsAsFactors = FALSE)
  section_summary <- as.data.frame(object$section_summary %||% object$summary %||% data.frame(), stringsAsFactors = FALSE)
  software_scope <- as.data.frame(object$software_scope %||% data.frame(), stringsAsFactors = FALSE)
  facets_positioning <- as.data.frame(object$facets_positioning %||% facets_guide('positioning'), stringsAsFactors = FALSE)
  visual_scope <- as.data.frame(object$visual_scope %||% data.frame(), stringsAsFactors = FALSE)

  overview <- data.frame(
    Sections = if (nrow(checklist) > 0) length(unique(checklist$Section)) else 0L,
    Items = nrow(checklist),
    Available = if (nrow(checklist) > 0) sum(checklist$Available %in% TRUE, na.rm = TRUE) else 0L,
    DraftReady = if (nrow(checklist) > 0) sum(checklist$DraftReady %in% TRUE, na.rm = TRUE) else 0L,
    Missing = if (nrow(checklist) > 0) sum(checklist$Available %in% FALSE, na.rm = TRUE) else 0L,
    NeedsDraftWork = if (nrow(checklist) > 0) sum(checklist$DraftReady %in% FALSE, na.rm = TRUE) else 0L,
    stringsAsFactors = FALSE
  )

  priority_summary <- data.frame()
  if (nrow(checklist) > 0 && all(c("Priority", "Severity") %in% names(checklist))) {
    priority_summary <- checklist |>
      dplyr::count(.data$Priority, .data$Severity, name = "Items") |>
      dplyr::arrange(
        factor(.data$Priority, levels = c("high", "medium", "low", "ready")),
        factor(.data$Severity, levels = c("required", "recommended", "optional"))
      ) |>
      as.data.frame(stringsAsFactors = FALSE)
  }

  action_items <- data.frame()
  if (nrow(checklist) > 0) {
    action_items <- checklist |>
      dplyr::filter(.data$DraftReady %in% FALSE | .data$Available %in% FALSE) |>
      dplyr::arrange(
        factor(.data$Priority, levels = c("high", "medium", "low", "ready")),
        .data$Section,
        .data$Item
      ) |>
      dplyr::select(
        "Section", "Item", "Available", "DraftReady", "Severity",
        "Priority", "NextAction"
      ) |>
      utils::head(n = top_n) |>
      as.data.frame(stringsAsFactors = FALSE)
  }

  settings_tbl <- bundle_settings_table(object$settings)
  notes <- c(
    "This summary is a manuscript-preparation guide.",
    "DraftReady indicates that the corresponding reporting element can be drafted with the package's documented caveats; it does not certify inferential adequacy.",
    "Detailed FACETS positioning, software scope, and visual scope tables are available in `$facets_positioning`, `$software_scope`, and `$visual_scope`."
  )
  if (nrow(action_items) == 0) {
    notes <- c(notes, "No remaining draft-action rows were detected in the current checklist.")
  }

  out <- list(
    overview = overview,
    fit_readiness = as.data.frame(
      object$fit_readiness %||% data.frame(), stringsAsFactors = FALSE
    ),
    fit_readiness_components = as.data.frame(
      object$fit_readiness_components %||% data.frame(),
      stringsAsFactors = FALSE
    ),
    fit_readiness_parameters = as.data.frame(
      object$fit_readiness_parameters %||%
        mfrmr_readiness_empty_parameter_table,
      stringsAsFactors = FALSE
    ),
    section_summary = section_summary,
    software_scope = software_scope,
    facets_positioning = facets_positioning,
    visual_scope = visual_scope,
    priority_summary = priority_summary,
    action_items = action_items,
    settings = settings_tbl,
    notes = notes,
    top_n = top_n
  )
  class(out) <- "summary.mfrm_reporting_checklist"
  out
}

#' @export
print.summary.mfrm_reporting_checklist <- function(x, ...) {
  cat("mfrmr Reporting Checklist Summary\n")

  print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_reporting_checklist_01"]])
  if (!is.null(x$facets_positioning) && nrow(x$facets_positioning) > 0) {
    cat("\nFACETS positioning\n")
    pos_cols <- intersect(c("Topic", "RecommendedWording"), names(x$facets_positioning))
    print(as.data.frame(x$facets_positioning[, pos_cols, drop = FALSE]), row.names = FALSE)
  }
  print_summary_sections(x, .mfrmr_summary_print_sections[["print.summary.mfrm_reporting_checklist_02"]])
  if (length(x$notes %||% character(0)) > 0L) {
    cat("\nNotes\n")
    for (line in x$notes) cat(" - ", line, "\n", sep = "")
  }
  invisible(x)
}
