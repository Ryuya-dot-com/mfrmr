# Publication tables use the same interval calculation as confint(fit).
.mfrm_parameter_table <- function(fit, component, se_type, conf.level) {
  fit <- .mfrm_refresh_steps(fit)
  enc <- fit$encoding
  part <- switch(component, raters = "facets", persons = "person", component)
  if (!part %in% c("facets", "person", "steps", "slopes"))
    stop("Select facets, raters, persons, steps or slopes for a fitted model.", call. = FALSE)
  if (se_type == "real" && !part %in% c("facets", "person"))
    stop("Real SE is available for facets and persons.", call. = FALSE)
  if (se_type == "sandwich" && (fit$method != "MML" || part == "person"))
    stop("Sandwich SE is available for structural parameters of an MML fit.", call. = FALSE)
  .mfrm_validate_interval_level(conf.level)
  tb <- fit[[part]]
  n <- NROW(tb)
  fixed <- rep(FALSE, n)
  supported <- identified <- rep(TRUE, n)
  if (part == "steps") {
    group <- if (enc$model_code == 1L) paste("Steps within", enc$step_facet) else "Shared steps"
    level <- tb$ScaleLevel
    term <- paste(tb$FromCategory, "to", tb$ToCategory)
    scale <- if (isTRUE(enc$slope_formula == 1L)) "Step offset (response logits)" else "Step offset (logits)"
    fixed <- rowSums(abs(.mfrm_step_basis(enc, fit$xi_layout))) == 0
    supported <- tb$Supported
    identified <- tb$Identified
  } else if (part == "slopes") {
    group <- tb$Facet
    level <- tb$Level
    term <- "Discrimination"
    scale <- "Slope ratio (interval on log scale)"
    for (i in seq_along(enc$slope_facets)) {
      rows <- which(group == enc$slope_facets[i])
      ix <- match(level[rows], enc$facet_levels[[match(enc$slope_facets[i], enc$facets)]])
      fixed[rows] <- rowSums(abs(enc$slope_B[[i]]))[ix] == 0
    }
  } else if (part == "person") {
    group <- "Person"
    level <- tb$Person
    term <- fit$score_method
    scale <- "Ability (logits)"
  } else {
    group <- tb$Facet
    level <- tb$Level
    term <- "Location"
    scale <- ifelse(tb$Sign < 0, "Logits (subtracted)", "Logits (added)")
    if (isTRUE(enc$slope_formula == 1L)) scale <- sub("Logits", "Response logits", scale, fixed = TRUE)
    for (i in seq_along(enc$base_facets)) {
      rows <- which(group == enc$base_facets[i])
      ix <- match(level[rows], enc$facet_levels[[i]])
      fixed[rows] <- rowSums(abs(.mfrm_facet_basis(enc, i)))[ix] == 0
    }
  }
  ready <- .mfrm_readiness(fit)
  ci <- if (ready$ready) stats::confint(fit, component = part, level = conf.level, se_type = se_type) else
    matrix(NA_real_, n, 2L)
  se <- tb[[switch(se_type, model = "ModelSE", real = "RealSE", sandwich = "SandwichSE")]]
  status <- rep("Estimated", n)
  status[!is.finite(ci[, 1L]) | !is.finite(ci[, 2L])] <- "Interval unavailable"
  if (!ready$ready) status[] <- paste("Review:", paste(ready$reason_codes, collapse = ", "))
  if (part == "facets" && "MLEEstimate" %in% names(tb)) status[] <- "Shrunken estimate; interval unavailable"
  status[fixed] <- "Fixed by constraint"
  status[!identified] <- "Unidentified"
  status[!supported] <- "Outside rubric support"
  se[status != "Estimated"] <- NA_real_
  ci[status != "Estimated", ] <- NA_real_
  df <- data.frame(Group = as.character(rep_len(group, n)), Level = as.character(level), Parameter = rep_len(term, n),
    Scale = rep_len(scale, n), Estimate = as.numeric(tb$Estimate), SE = as.numeric(se),
    Lower = ci[, 1L], Upper = ci[, 2L], Status = status, row.names = NULL, check.names = FALSE)
  if (component == "raters") {
    rater <- infer_default_rater_facet(enc$base_facets, fallback_first = FALSE)
    if (is.null(rater)) stop("Cannot identify a rater facet. Select component = 'facets'.", call. = FALSE)
    df <- df[df$Group == rater, , drop = FALSE]
  }
  df
}

.mfrm_se_label <- function(fit, component, se_type) {
  if (component == "persons" && fit$score_method == "EAP" && se_type == "model") return("Posterior SD")
  switch(se_type, model = "Model SE", real = "Real SE", sandwich = "Sandwich SE")
}

.mfrm_models_table <- function(fits, component, se_type, conf.level, digits, nested) {
  labels <- names(fits)
  if (length(fits) < 2L || is.null(labels) || anyNA(labels) || any(!nzchar(trimws(labels))) ||
      anyDuplicated(labels) || !all(vapply(fits, inherits, logical(1), "mfrm_fit")))
    stop("Supply a list of at least two fitted models with unique nonempty names.", call. = FALSE)
  if (component == "comparison") {
    cmp <- do.call(compare_mfrm, c(unname(fits), list(labels = labels, nested = nested, warn_constraints = FALSE)))
    t <- cmp$table
    t$Persons <- vapply(fits, function(f) as.integer(f$n_person), integer(1))
    t$Inference <- vapply(fits, function(f) {
      r <- .mfrm_readiness(f)
      paste(c(r$status, r$reason_codes), collapse = " ")
    }, character(1))
    t$ICComparison <- if (cmp$comparison_basis$ic_comparable) "Comparable" else "Differences unavailable"
    if (nested) {
      t$LRT <- cmp$comparison_basis$lrt_status
      if (NROW(cmp$lrt)) {
        at <- match(cmp$lrt$Complex, labels)
        t$LRT <- "Reference"
        p <- trimws(format.pval(cmp$lrt$pValue, digits = max(1L, digits)))
        t$LRT[at] <- sprintf("vs %s: chi-square = %s, df = %d, p %s", cmp$lrt$Simpler,
          format(round(cmp$lrt$ChiSq, digits), trim = TRUE), cmp$lrt$df,
          ifelse(startsWith(p, "<"), p, paste("=", p)))
      }
    }
    t <- .tidymfrm_round_df(t[setdiff(names(t), "Model")], digits)
    out <- data.frame(Statistic = names(t), check.names = FALSE)
    for (i in seq_along(fits)) out[[paste("Model", labels[i])]] <- unlist(lapply(t, function(v) as.character(v[i])), use.names = FALSE)
    return(out)
  }
  if (nested) stop("Select component = 'comparison' to request nested tests.", call. = FALSE)
  # Equal level labels alone do not identify a common origin, sign or logit unit.
  scale_spec <- function(fit) {
    e <- fit$encoding
    fields <- c("base_facets", "facets", "rating_min", "rating_max", "facet_levels", "facet_signs",
      "anchor_fixed", "anchor_val", "facet_noncenter", "centering_scope", "custom_facet_d0",
      "custom_facet_B", "pop_mode", "fixed_sigma", "pop_col_names")
    fields <- c(fields, "pop_X_mat", "has_custom_step_map", "custom_step_d0", "custom_step_B")
    list(spec = e[fields], observations = .mfrm_observation_basis(e))
  }
  ref <- scale_spec(fits[[1L]])
  if (!all(vapply(fits[-1L], function(f) identical(scale_spec(f), ref), logical(1))))
    stop("Side-by-side parameters require matching observations, facet coding, rubric and identification. Use separate parameter tables or component = 'comparison'.", call. = FALSE)
  generalized <- Filter(function(f) NROW(f$slopes) > 0L, fits)
  if (length(generalized) > 1L) {
    slope_spec <- function(f) f$encoding[c("slope_facets", "slope_formula", "slope_reference", "slope_d0", "slope_B")]
    if (!all(vapply(generalized[-1L], function(f) identical(slope_spec(f), slope_spec(generalized[[1L]])), logical(1))))
      stop("Discrimination coding differs. Use separate parameter tables or component = 'comparison'.", call. = FALSE)
  }
  keys <- c("Group", "Level", "Parameter", "Scale")
  rows <- lapply(fits, function(f) {
    d <- .mfrm_parameter_table(f, component, se_type, conf.level)
    nums <- lapply(d[c("Estimate", "SE", "Lower", "Upper")], function(v)
      ifelse(is.finite(v), formatC(v, format = "f", digits = digits), "NA"))
    value <- if (nrow(d)) paste0(nums$Estimate, " (", nums$SE, ") [", nums$Lower, ", ", nums$Upper, "]") else character()
    review <- d$Status != "Estimated"
    value[review] <- paste(nums$Estimate[review], d$Status[review], sep = " / ")
    data.frame(d[keys], Value = value, check.names = FALSE)
  })
  result <- unique(do.call(rbind, unname(lapply(rows, `[`, keys))))
  for (i in seq_along(rows)) {
    column <- paste0(labels[i], " / ", fits[[i]]$method, " / ", .mfrm_se_label(fits[[i]], component, se_type), " / ", 100 * conf.level, "% interval")
    right <- rows[[i]]
    names(right)[names(right) == "Value"] <- column
    result <- dplyr::left_join(result, right, by = keys)
    result[[column]][is.na(result[[column]])] <- "Not in model"
  }
  result
}
