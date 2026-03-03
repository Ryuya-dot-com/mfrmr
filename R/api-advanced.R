# Advanced analysis functions: DIF, information functions, unified Wright map.

# ============================================================================
# B. DIF Analysis
# ============================================================================

#' Differential item/facet functioning analysis
#'
#' Tests whether the difficulty of facet levels differs across a grouping
#' variable (e.g., whether rater severity differs for male vs. female
#' examinees, or whether item difficulty differs across rater subgroups).
#'
#' @param fit Output from [fit_mfrm()].
#' @param diagnostics Output from [diagnose_mfrm()].
#' @param facet Character scalar naming the facet whose elements are tested
#'   for DIF (e.g., `"Criterion"` or `"Rater"`).
#' @param group Character scalar naming the column in the data that
#'   defines the grouping variable (e.g., `"Gender"`, `"Site"`).
#' @param data Optional data frame containing at least the group column
#'   and the same person/facet/score columns used to fit the model. If
#'   `NULL` (default), the data stored in `fit$prep$data` is used.
#' @param focal Optional character vector of group levels to treat as focal.
#'   If `NULL` (default), all pairwise group comparisons are performed.
#' @param method Analysis method: `"residual"` (default) uses the fitted
#'   model's residuals without re-estimation; `"refit"` re-estimates the
#'   model within each group subset. The residual method is faster and
#'   avoids convergence issues with small subsets.
#' @param min_obs Minimum number of observations per cell (facet-level x
#'   group). Cells below this threshold are flagged as sparse and their
#'   statistics set to `NA`. Default `10`.
#' @param p_adjust Method for multiple-comparison adjustment, passed to
#'   [stats::p.adjust()]. Default is `"holm"`.
#'
#' @details
#' Two methods are available:
#'
#' **Residual method** (`method = "residual"`): Uses the existing fitted
#' model's observation-level residuals from `compute_obs_table()`. For each
#' facet-level x group cell, the observed and expected score sums are
#' aggregated and a standardized residual is computed as:
#' \deqn{z = \frac{\sum Obs - \sum Exp}{\sqrt{\sum Var}}}
#' Pairwise contrasts between groups compare the mean observed-minus-expected
#' difference for each facet level.
#'
#' **Refit method** (`method = "refit"`): Subsets the data by group, refits
#' the MFRM model within each subset, and compares the resulting facet-level
#' estimates using a Welch t-statistic:
#' \deqn{t = \frac{\hat{\delta}_1 - \hat{\delta}_2}{\sqrt{SE_1^2 + SE_2^2}}}
#'
#' Effect size is classified following ETS guidelines: negligible (A: < 0.43
#' logits), moderate (B: 0.43--0.64), or large (C: >= 0.64).
#'
#' @section Interpreting output:
#' - `$dif_table`: one row per facet-level x group-pair with contrast,
#'   SE, t-statistic, p-value, adjusted p-value, effect size, and
#'   ETS classification. Includes `Method`, `N_Group1`, `N_Group2`,
#'   and `sparse` columns.
#' - `$cell_table`: (residual method only) per-cell detail with N,
#'   ObsScore, ExpScore, ObsExpAvg, StdResidual.
#' - `$summary`: counts of negligible/moderate/large DIF items.
#' - `$group_fits`: (refit method only) list of per-group facet estimates.
#'
#' @section Typical workflow:
#' 1. Fit a model with [fit_mfrm()].
#' 2. Run `analyze_dif(fit, diagnostics, facet = "Criterion", group = "Gender", data = my_data)`.
#' 3. Inspect `$dif_table` for flagged levels and `$summary` for counts.
#' 4. Use [dif_interaction_table()] for a detailed cell-level breakdown.
#'
#' @return
#' An object of class `mfrm_dif` (named list) with:
#' - `dif_table`: data.frame of DIF contrasts.
#' - `cell_table`: (residual method) per-cell detail table.
#' - `summary`: counts by ETS classification.
#' - `group_fits`: (refit method) per-group facet estimates.
#' - `config`: list with facet, group, method, min_obs, p_adjust settings.
#'
#' @seealso [fit_mfrm()], [estimate_bias()], [compare_mfrm()],
#'   [dif_interaction_table()], [plot_dif_heatmap()], [dif_report()]
#' @examples
#' set.seed(42)
#' toy <- expand.grid(
#'   Person = paste0("P", 1:8),
#'   Rater = paste0("R", 1:3),
#'   Criterion = c("Content", "Organization"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- sample(0:2, nrow(toy), replace = TRUE)
#' toy$Group <- ifelse(as.integer(factor(toy$Person)) <= 4, "A", "B")
#'
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                  method = "JML", model = "RSM", maxit = 25)
#' diag <- diagnose_mfrm(fit, residual_pca = "none")
#' dif <- analyze_dif(fit, diag, facet = "Rater", group = "Group", data = toy)
#' dif$dif_table
#' @export
analyze_dif <- function(fit,
                        diagnostics,
                        facet,
                        group,
                        data = NULL,
                        focal = NULL,
                        method = c("residual", "refit"),
                        min_obs = 10,
                        p_adjust = "holm") {
  method <- match.arg(method)
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an `mfrm_fit` object.", call. = FALSE)
  }
  if (!is.character(facet) || length(facet) != 1) {
    stop("`facet` must be a single character string.", call. = FALSE)
  }
  if (!is.character(group) || length(group) != 1) {
    stop("`group` must be a single character string naming a column in the ",
         "original data.", call. = FALSE)
  }
  if (!is.numeric(min_obs) || length(min_obs) != 1 || min_obs < 1) {
    stop("`min_obs` must be a positive integer.", call. = FALSE)
  }

  # Recover data
  orig_data <- if (!is.null(data)) data else fit$prep$data
  if (is.null(orig_data) || !is.data.frame(orig_data)) {
    stop("No data available. Pass the original data via the `data` argument.",
         call. = FALSE)
  }
  if (!group %in% names(orig_data)) {
    stop("`group` column '", group, "' not found in the data. ",
         "Available columns: ", paste(names(orig_data), collapse = ", "),
         call. = FALSE)
  }

  facet_names <- fit$config$facet_cols
  if (is.null(facet_names)) facet_names <- fit$prep$facet_names
  if (!facet %in% facet_names) {
    stop("`facet` '", facet, "' is not one of the model facets: ",
         paste(facet_names, collapse = ", "), ".", call. = FALSE)
  }

  # Group levels
  group_vals <- as.character(orig_data[[group]])
  group_levels <- sort(unique(group_vals))
  if (length(group_levels) < 2) {
    stop("Grouping variable '", group, "' must have at least 2 levels. ",
         "Found: ", length(group_levels), ".", call. = FALSE)
  }

  if (method == "residual") {
    out <- .analyze_dif_residual(
      fit = fit, facet = facet, group = group, data = data,
      orig_data = orig_data, facet_names = facet_names,
      group_levels = group_levels, focal = focal,
      min_obs = min_obs, p_adjust = p_adjust
    )
  } else {
    out <- .analyze_dif_refit(
      fit = fit, diagnostics = diagnostics,
      facet = facet, group = group,
      orig_data = orig_data, facet_names = facet_names,
      group_vals = as.character(orig_data[[group]]),
      group_levels = group_levels, focal = focal,
      min_obs = min_obs, p_adjust = p_adjust
    )
  }
  out
}

# Internal: residual-based DIF analysis
.analyze_dif_residual <- function(fit, facet, group, data, orig_data,
                                  facet_names, group_levels, focal,
                                  min_obs, p_adjust) {
  # Compute observation table from the fitted model

  obs_tbl <- compute_obs_table(fit)

  # The obs_tbl has columns from prep$data (Person, facet cols, Score,

  # Weight, score_k) plus PersonMeasure, Observed, Expected, Var, Residual,
  # StdResidual, StdSq. We need to merge with orig_data to get the group col.
  # Use row-order matching: prep$data is a cleaned subset of the original
  # data, so we need the group column from the user-supplied data.
  person_col <- fit$config$person_col %||% "Person"
  score_col <- fit$config$score_col %||% "Score"

  # Build a merge key from the obs_tbl (Person + facets)
  merge_cols <- c("Person", facet_names)

  # Add group column from orig_data by joining on person + facets + score
  orig_for_merge <- orig_data
  orig_for_merge$.group_var <- as.character(orig_data[[group]])
  # Rename to match internal names
  if (person_col != "Person") {
    orig_for_merge$Person <- as.character(orig_for_merge[[person_col]])
  } else {
    orig_for_merge$Person <- as.character(orig_for_merge$Person)
  }
  for (fn in facet_names) {
    orig_for_merge[[fn]] <- as.character(orig_for_merge[[fn]])
  }

  # Ensure obs_tbl facet columns are character for merging
  obs_tbl_chr <- obs_tbl
  obs_tbl_chr$Person <- as.character(obs_tbl_chr$Person)
  for (fn in facet_names) {
    obs_tbl_chr[[fn]] <- as.character(obs_tbl_chr[[fn]])
  }

  # Use left_join on all merge keys; include Score to handle duplicate combos
  merge_key <- c("Person", facet_names)
  join_cols <- merge_key
  names(join_cols) <- merge_key

  # Add row index for stable matching
  obs_tbl_chr$.obs_row <- seq_len(nrow(obs_tbl_chr))
  orig_for_merge$.orig_row <- seq_len(nrow(orig_for_merge))

  merged <- left_join(
    obs_tbl_chr |> select(all_of(c(".obs_row", merge_key))),
    orig_for_merge |> select(all_of(c(merge_key, ".group_var"))) |> distinct(),
    by = merge_key
  )

  # Handle duplicates from many-to-many: keep first group per obs row
  merged <- merged |>
    group_by(.data$.obs_row) |>
    slice(1L) |>
    ungroup() |>
    arrange(.data$.obs_row)

  obs_tbl_chr$.group_var <- merged$.group_var

  # Filter to rows with valid group
  obs_work <- obs_tbl_chr |>
    filter(!is.na(.data$.group_var))

  # Aggregate by facet level x group
  cell_table <- obs_work |>
    group_by(.data[[facet]], .data$.group_var) |>
    summarise(
      N = n(),
      ObsScore = sum(.data$Observed, na.rm = TRUE),
      ExpScore = sum(.data$Expected, na.rm = TRUE),
      ObsExpAvg = mean(.data$Observed - .data$Expected, na.rm = TRUE),
      Var_sum = sum(.data$Var, na.rm = TRUE),
      .groups = "drop"
    ) |>
    mutate(
      sparse = .data$N < min_obs,
      StdResidual = ifelse(
        .data$sparse | .data$Var_sum <= 0,
        NA_real_,
        (.data$ObsScore - .data$ExpScore) / sqrt(.data$Var_sum)
      ),
      t = .data$StdResidual,
      df = ifelse(.data$sparse, NA_real_, .data$N - 1),
      p_value = ifelse(
        is.finite(.data$t) & is.finite(.data$df) & .data$df > 0,
        2 * stats::pt(abs(.data$t), df = .data$df, lower.tail = FALSE),
        NA_real_
      )
    )
  names(cell_table)[names(cell_table) == facet] <- "Level"
  names(cell_table)[names(cell_table) == ".group_var"] <- "GroupValue"

  # Build pairwise contrasts
  if (!is.null(focal)) {
    pairs <- expand_grid(
      Group1 = setdiff(group_levels, focal),
      Group2 = focal
    )
  } else {
    pairs <- as_tibble(as.data.frame(
      t(combn(group_levels, 2)),
      stringsAsFactors = FALSE
    ))
    names(pairs) <- c("Group1", "Group2")
  }

  facet_levels <- unique(cell_table$Level)
  dif_rows <- list()
  for (i in seq_len(nrow(pairs))) {
    g1 <- pairs$Group1[i]
    g2 <- pairs$Group2[i]
    for (lev in facet_levels) {
      c1 <- cell_table |> filter(.data$Level == lev, .data$GroupValue == g1)
      c2 <- cell_table |> filter(.data$Level == lev, .data$GroupValue == g2)
      n1 <- if (nrow(c1) > 0) c1$N[1] else 0L
      n2 <- if (nrow(c2) > 0) c2$N[1] else 0L
      is_sparse <- (n1 < min_obs) || (n2 < min_obs)
      avg1 <- if (nrow(c1) > 0 && !is_sparse) c1$ObsExpAvg[1] else NA_real_
      avg2 <- if (nrow(c2) > 0 && !is_sparse) c2$ObsExpAvg[1] else NA_real_
      contrast <- if (is.finite(avg1) && is.finite(avg2)) avg1 - avg2 else NA_real_
      # SE from pooled variance sums
      var1 <- if (nrow(c1) > 0 && !is_sparse) c1$Var_sum[1] else NA_real_
      var2 <- if (nrow(c2) > 0 && !is_sparse) c2$Var_sum[1] else NA_real_
      se_diff <- if (is.finite(var1) && is.finite(var2) && var1 > 0 && var2 > 0) {
        sqrt(1 / n1^2 * var1 + 1 / n2^2 * var2)
      } else {
        NA_real_
      }
      t_val <- if (is.finite(contrast) && is.finite(se_diff) && se_diff > 0) {
        contrast / se_diff
      } else {
        NA_real_
      }
      df_val <- if (!is_sparse) (n1 - 1) + (n2 - 1) else NA_real_
      p_val <- if (is.finite(t_val) && is.finite(df_val) && df_val > 0) {
        2 * stats::pt(abs(t_val), df = df_val, lower.tail = FALSE)
      } else {
        NA_real_
      }
      abs_diff <- abs(contrast)
      ets <- if (is.finite(abs_diff)) {
        if (abs_diff < 0.43) "A" else if (abs_diff < 0.64) "B" else "C"
      } else {
        NA_character_
      }
      dif_rows[[length(dif_rows) + 1]] <- tibble(
        Level = lev,
        Group1 = g1,
        Group2 = g2,
        Contrast = contrast,
        SE = se_diff,
        t = t_val,
        df = df_val,
        p_value = p_val,
        AbsDiff = abs_diff,
        ETS = ets,
        Method = "residual",
        N_Group1 = as.integer(n1),
        N_Group2 = as.integer(n2),
        sparse = is_sparse
      )
    }
  }
  dif_table <- bind_rows(dif_rows)

  # Adjust p-values
  if (nrow(dif_table) > 0 && any(is.finite(dif_table$p_value))) {
    dif_table$p_adjusted <- stats::p.adjust(dif_table$p_value, method = p_adjust)
  } else {
    dif_table$p_adjusted <- NA_real_
  }

  # Summary counts
  dif_summary <- tibble(
    Classification = c("A (Negligible)", "B (Moderate)", "C (Large)"),
    Count = c(
      sum(dif_table$ETS == "A", na.rm = TRUE),
      sum(dif_table$ETS == "B", na.rm = TRUE),
      sum(dif_table$ETS == "C", na.rm = TRUE)
    )
  )

  out <- list(
    dif_table = dif_table,
    cell_table = cell_table,
    summary = dif_summary,
    group_fits = NULL,
    config = list(facet = facet, group = group, method = "residual",
                  min_obs = min_obs, p_adjust = p_adjust,
                  focal = focal, group_levels = group_levels)
  )
  class(out) <- c("mfrm_dif", class(out))
  out
}

# Internal: refit-based DIF analysis (original approach)
.analyze_dif_refit <- function(fit, diagnostics, facet, group, orig_data,
                               facet_names, group_vals, group_levels, focal,
                               min_obs, p_adjust) {
  # Get full-sample facet estimates
  measures <- tibble::as_tibble(diagnostics$measures)
  facet_estimates <- measures |>
    filter(.data$Facet == facet) |>
    select("Level", "Estimate", "SE")

  person_col <- fit$config$person_col %||% "Person"
  score_col <- fit$config$score_col %||% "Score"

  group_fits <- list()
  for (g in group_levels) {
    idx <- group_vals == g
    sub_data <- orig_data[idx, , drop = FALSE]
    if (nrow(sub_data) < 5) {
      group_fits[[g]] <- tibble(
        Level = facet_estimates$Level,
        Estimate = NA_real_,
        SE = NA_real_,
        N = 0L
      )
      next
    }
    sub_fit <- tryCatch(
      suppressWarnings(fit_mfrm(
        data = sub_data,
        person = person_col,
        facets = facet_names,
        score = score_col,
        method = if (!is.null(fit$config$method)) fit$config$method else "JML",
        model = if (!is.null(fit$config$model)) fit$config$model else "RSM",
        maxit = 50,
        anchor_policy = "silent"
      )),
      error = function(e) NULL
    )
    if (is.null(sub_fit)) {
      group_fits[[g]] <- tibble(
        Level = facet_estimates$Level,
        Estimate = NA_real_,
        SE = NA_real_,
        N = sum(idx)
      )
    } else {
      sub_diag <- tryCatch(
        suppressWarnings(diagnose_mfrm(sub_fit, residual_pca = "none")),
        error = function(e) NULL
      )
      if (!is.null(sub_diag) && !is.null(sub_diag$measures)) {
        sub_measures <- tibble::as_tibble(sub_diag$measures)
        sub_est <- sub_measures |>
          filter(.data$Facet == facet) |>
          select("Level", "Estimate", "SE") |>
          mutate(N = sum(idx))
      } else {
        sub_others <- tibble::as_tibble(sub_fit$facets$others)
        sub_est <- sub_others |>
          filter(.data$Facet == facet) |>
          select("Level", "Estimate") |>
          mutate(SE = NA_real_, N = sum(idx))
      }
      group_fits[[g]] <- sub_est
    }
  }

  # Build DIF contrasts
  if (!is.null(focal)) {
    pairs <- expand_grid(
      Group1 = setdiff(group_levels, focal),
      Group2 = focal
    )
  } else {
    pairs <- as_tibble(as.data.frame(
      t(combn(group_levels, 2)),
      stringsAsFactors = FALSE
    ))
    names(pairs) <- c("Group1", "Group2")
  }

  dif_rows <- list()
  for (i in seq_len(nrow(pairs))) {
    g1 <- pairs$Group1[i]
    g2 <- pairs$Group2[i]
    est1 <- group_fits[[g1]]
    est2 <- group_fits[[g2]]
    merged <- merge(est1, est2, by = "Level", suffixes = c("_1", "_2"))
    for (j in seq_len(nrow(merged))) {
      e1 <- merged$Estimate_1[j]
      e2 <- merged$Estimate_2[j]
      se1 <- merged$SE_1[j]
      se2 <- merged$SE_2[j]
      n1 <- merged$N_1[j]
      n2 <- merged$N_2[j]
      contrast <- e1 - e2
      se_diff <- sqrt(se1^2 + se2^2)
      t_val <- if (is.finite(se_diff) && se_diff > 0) contrast / se_diff else NA_real_
      df_welch <- if (is.finite(se1) && is.finite(se2) && se1 > 0 && se2 > 0) {
        (se1^2 + se2^2)^2 / (se1^4 / max(1, n1 - 1) + se2^4 / max(1, n2 - 1))
      } else {
        NA_real_
      }
      p_val <- if (is.finite(t_val) && is.finite(df_welch) && df_welch > 0) {
        2 * stats::pt(abs(t_val), df = df_welch, lower.tail = FALSE)
      } else {
        NA_real_
      }
      abs_diff <- abs(contrast)
      is_sparse <- (n1 < min_obs) || (n2 < min_obs)
      ets <- if (is.finite(abs_diff)) {
        if (abs_diff < 0.43) "A" else if (abs_diff < 0.64) "B" else "C"
      } else {
        NA_character_
      }
      dif_rows[[length(dif_rows) + 1]] <- tibble(
        Level = merged$Level[j],
        Group1 = g1,
        Group2 = g2,
        Estimate1 = e1,
        Estimate2 = e2,
        Contrast = contrast,
        SE = se_diff,
        t = t_val,
        df = df_welch,
        p_value = p_val,
        AbsDiff = abs_diff,
        ETS = ets,
        Method = "refit",
        N_Group1 = as.integer(n1),
        N_Group2 = as.integer(n2),
        sparse = is_sparse
      )
    }
  }
  dif_table <- bind_rows(dif_rows)

  # Adjust p-values
  if (nrow(dif_table) > 0 && any(is.finite(dif_table$p_value))) {
    dif_table$p_adjusted <- stats::p.adjust(dif_table$p_value, method = p_adjust)
  } else {
    dif_table$p_adjusted <- NA_real_
  }

  # Summary counts
  dif_summary <- tibble(
    Classification = c("A (Negligible)", "B (Moderate)", "C (Large)"),
    Count = c(
      sum(dif_table$ETS == "A", na.rm = TRUE),
      sum(dif_table$ETS == "B", na.rm = TRUE),
      sum(dif_table$ETS == "C", na.rm = TRUE)
    )
  )

  out <- list(
    dif_table = dif_table,
    cell_table = NULL,
    summary = dif_summary,
    group_fits = group_fits,
    config = list(facet = facet, group = group, method = "refit",
                  min_obs = min_obs, p_adjust = p_adjust,
                  focal = focal, group_levels = group_levels)
  )
  class(out) <- c("mfrm_dif", class(out))
  out
}

#' @export
summary.mfrm_dif <- function(object, ...) {
  out <- list(
    dif_table = object$dif_table,
    cell_table = object$cell_table,
    summary = object$summary,
    config = object$config
  )
  class(out) <- "summary.mfrm_dif"
  out
}

#' @export
print.summary.mfrm_dif <- function(x, ...) {
  cat("--- DIF Analysis ---\n")
  cat("Method:", x$config$method %||% "refit", "\n")
  cat("Facet:", x$config$facet, " | Group:", x$config$group, "\n")
  cat("Groups:", paste(x$config$group_levels, collapse = ", "), "\n")
  if (!is.null(x$config$min_obs)) {
    cat("Min observations per cell:", x$config$min_obs, "\n")
  }
  cat("\n")

  if (nrow(x$dif_table) > 0) {
    show_cols <- intersect(
      c("Level", "Group1", "Group2", "Contrast", "SE", "t",
        "p_adjusted", "ETS", "N_Group1", "N_Group2", "sparse"),
      names(x$dif_table)
    )
    print_tbl <- x$dif_table |> select(all_of(show_cols))
    print(as.data.frame(print_tbl), row.names = FALSE, digits = 3)
  } else {
    cat("No DIF contrasts computed.\n")
  }

  cat("\nETS Classification Summary:\n")
  print(as.data.frame(x$summary), row.names = FALSE)
  invisible(x)
}

#' @export
print.mfrm_dif <- function(x, ...) {
  print(summary(x))
  invisible(x)
}

# ============================================================================
# B2. DIF Interaction Table
# ============================================================================

#' Compute interaction table between a facet and a grouping variable
#'
#' Produces a FACETS Table 30/31-style interaction table showing
#' Obs-Exp differences, standardized residuals, and significance
#' for each facet-level x group-value cell.
#'
#' @param fit Output from [fit_mfrm()].
#' @param diagnostics Output from [diagnose_mfrm()].
#' @param facet Character scalar naming the facet.
#' @param group Character scalar naming the grouping column.
#' @param data Optional data frame with the group column. If `NULL`
#'   (default), the data stored in `fit$prep$data` is used, but it
#'   must contain the `group` column.
#' @param min_obs Minimum observations per cell. Cells with fewer than
#'   this many observations are flagged as sparse and their test
#'   statistics set to `NA`. Default `10`.
#' @param p_adjust P-value adjustment method, passed to
#'   [stats::p.adjust()]. Default `"holm"`.
#' @param abs_t_warn Threshold for flagging cells by absolute t-value.
#'   Default `2`.
#' @param abs_bias_warn Threshold for flagging cells by absolute
#'   Obs-Exp average (in logits). Default `0.5`.
#'
#' @details
#' This function uses the fitted model's observation-level residuals
#' (from the internal `compute_obs_table()` function) rather than
#' re-estimating the model. For each facet-level x group-value cell,
#' it computes:
#' \itemize{
#'   \item N: number of observations in the cell
#'   \item ObsScore: sum of observed scores
#'   \item ExpScore: sum of expected scores
#'   \item ObsExpAvg: mean observed-minus-expected difference
#'   \item Var_sum: sum of model variances
#'   \item StdResidual: (ObsScore - ExpScore) / sqrt(Var_sum)
#'   \item t: approximate t-statistic (equal to StdResidual)
#'   \item df: N - 1
#'   \item p_value: two-tailed p-value from the t-distribution
#' }
#'
#' @section Interpreting output:
#' - `$table`: the full interaction table with one row per cell.
#' - `$summary`: overview counts of flagged and sparse cells.
#' - `$config`: analysis configuration parameters.
#' - Cells with `|t| > abs_t_warn` or `|ObsExpAvg| > abs_bias_warn`
#'   are flagged in the `flag_t` and `flag_bias` columns.
#' - Sparse cells (N < min_obs) have `sparse = TRUE` and NA statistics.
#'
#' @section Typical workflow:
#' 1. Fit a model with [fit_mfrm()].
#' 2. Run `dif_interaction_table(fit, diag, facet = "Rater", group = "Gender", data = df)`.
#' 3. Inspect `$table` for flagged cells.
#' 4. Visualize with [plot_dif_heatmap()].
#'
#' @return Object of class `mfrm_dif_interaction` with:
#' - `table`: tibble with per-cell statistics and flags.
#' - `summary`: tibble summarizing flagged and sparse cell counts.
#' - `config`: list of analysis parameters.
#'
#' @seealso [analyze_dif()], [plot_dif_heatmap()], [dif_report()],
#'   [estimate_bias()]
#' @examples
#' set.seed(42)
#' toy <- expand.grid(
#'   Person = paste0("P", 1:8),
#'   Rater = paste0("R", 1:3),
#'   Criterion = c("Content", "Organization"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- sample(0:2, nrow(toy), replace = TRUE)
#' toy$Group <- ifelse(as.integer(factor(toy$Person)) <= 4, "A", "B")
#'
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                  method = "JML", model = "RSM", maxit = 25)
#' diag <- diagnose_mfrm(fit, residual_pca = "none")
#' int <- dif_interaction_table(fit, diag, facet = "Rater",
#'                              group = "Group", data = toy, min_obs = 2)
#' int$table
#' @export
dif_interaction_table <- function(fit, diagnostics, facet, group, data = NULL,
                                  min_obs = 10, p_adjust = "holm",
                                  abs_t_warn = 2, abs_bias_warn = 0.5) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an `mfrm_fit` object.", call. = FALSE)
  }
  if (!is.character(facet) || length(facet) != 1) {
    stop("`facet` must be a single character string.", call. = FALSE)
  }
  if (!is.character(group) || length(group) != 1) {
    stop("`group` must be a single character string.", call. = FALSE)
  }
  if (!is.numeric(min_obs) || length(min_obs) != 1 || min_obs < 1) {
    stop("`min_obs` must be a positive integer.", call. = FALSE)
  }
  if (!is.numeric(abs_t_warn) || length(abs_t_warn) != 1) {
    stop("`abs_t_warn` must be a single numeric value.", call. = FALSE)
  }
  if (!is.numeric(abs_bias_warn) || length(abs_bias_warn) != 1) {
    stop("`abs_bias_warn` must be a single numeric value.", call. = FALSE)
  }

  # Recover data
  orig_data <- if (!is.null(data)) data else fit$prep$data
  if (is.null(orig_data) || !is.data.frame(orig_data)) {
    stop("No data available. Pass the original data via the `data` argument.",
         call. = FALSE)
  }
  if (!group %in% names(orig_data)) {
    stop("`group` column '", group, "' not found in the data.",
         call. = FALSE)
  }

  facet_names <- fit$config$facet_cols
  if (is.null(facet_names)) facet_names <- fit$prep$facet_names
  if (!facet %in% facet_names) {
    stop("`facet` '", facet, "' is not one of the model facets: ",
         paste(facet_names, collapse = ", "), ".", call. = FALSE)
  }

  group_levels <- sort(unique(as.character(orig_data[[group]])))
  if (length(group_levels) < 2) {
    stop("Grouping variable '", group, "' must have at least 2 levels.",
         call. = FALSE)
  }

  # Compute observation table
  obs_tbl <- compute_obs_table(fit)

  person_col <- fit$config$person_col %||% "Person"

  # Prepare merge keys
  merge_cols <- c("Person", facet_names)
  obs_chr <- obs_tbl
  obs_chr$Person <- as.character(obs_chr$Person)
  for (fn in facet_names) {
    obs_chr[[fn]] <- as.character(obs_chr[[fn]])
  }

  orig_for_merge <- orig_data
  orig_for_merge$.group_var <- as.character(orig_data[[group]])
  if (person_col != "Person") {
    orig_for_merge$Person <- as.character(orig_for_merge[[person_col]])
  } else {
    orig_for_merge$Person <- as.character(orig_for_merge$Person)
  }
  for (fn in facet_names) {
    orig_for_merge[[fn]] <- as.character(orig_for_merge[[fn]])
  }

  obs_chr$.obs_row <- seq_len(nrow(obs_chr))
  merged <- left_join(
    obs_chr |> select(all_of(c(".obs_row", merge_cols))),
    orig_for_merge |> select(all_of(c(merge_cols, ".group_var"))) |> distinct(),
    by = merge_cols
  )
  merged <- merged |>
    group_by(.data$.obs_row) |>
    slice(1L) |>
    ungroup() |>
    arrange(.data$.obs_row)

  obs_chr$.group_var <- merged$.group_var
  obs_work <- obs_chr |> filter(!is.na(.data$.group_var))

  # Aggregate by facet level x group
  int_table <- obs_work |>
    group_by(.data[[facet]], .data$.group_var) |>
    summarise(
      N = n(),
      ObsScore = sum(.data$Observed, na.rm = TRUE),
      ExpScore = sum(.data$Expected, na.rm = TRUE),
      ObsExpAvg = mean(.data$Observed - .data$Expected, na.rm = TRUE),
      Var_sum = sum(.data$Var, na.rm = TRUE),
      .groups = "drop"
    ) |>
    mutate(
      sparse = .data$N < min_obs,
      StdResidual = ifelse(
        .data$sparse | .data$Var_sum <= 0,
        NA_real_,
        (.data$ObsScore - .data$ExpScore) / sqrt(.data$Var_sum)
      ),
      t = .data$StdResidual,
      df = ifelse(.data$sparse, NA_real_, .data$N - 1),
      p_value = ifelse(
        is.finite(.data$t) & is.finite(.data$df) & .data$df > 0,
        2 * stats::pt(abs(.data$t), df = .data$df, lower.tail = FALSE),
        NA_real_
      )
    )
  names(int_table)[names(int_table) == facet] <- "Level"
  names(int_table)[names(int_table) == ".group_var"] <- "GroupValue"

  # Adjust p-values
  if (nrow(int_table) > 0 && any(is.finite(int_table$p_value))) {
    int_table$p_adjusted <- stats::p.adjust(int_table$p_value, method = p_adjust)
  } else {
    int_table$p_adjusted <- NA_real_
  }

  # Flag cells
  int_table <- int_table |>
    mutate(
      flag_t = ifelse(.data$sparse, NA, abs(.data$t) > abs_t_warn),
      flag_bias = ifelse(.data$sparse, NA, abs(.data$ObsExpAvg) > abs_bias_warn)
    )

  # Summary
  n_total <- nrow(int_table)
  n_sparse <- sum(int_table$sparse, na.rm = TRUE)
  n_flag_t <- sum(int_table$flag_t == TRUE, na.rm = TRUE)
  n_flag_bias <- sum(int_table$flag_bias == TRUE, na.rm = TRUE)
  int_summary <- tibble(
    Metric = c("Total cells", "Sparse cells (N < min_obs)",
               "Flagged by |t|", "Flagged by |Obs-Exp Avg|"),
    Count = c(n_total, n_sparse, n_flag_t, n_flag_bias)
  )

  out <- list(
    table = int_table,
    summary = int_summary,
    config = list(facet = facet, group = group, min_obs = min_obs,
                  p_adjust = p_adjust, abs_t_warn = abs_t_warn,
                  abs_bias_warn = abs_bias_warn,
                  group_levels = group_levels)
  )
  class(out) <- c("mfrm_dif_interaction", class(out))
  out
}

#' @export
summary.mfrm_dif_interaction <- function(object, ...) {
  out <- list(
    table = object$table,
    summary = object$summary,
    config = object$config
  )
  class(out) <- "summary.mfrm_dif_interaction"
  out
}

#' @export
print.summary.mfrm_dif_interaction <- function(x, ...) {
  cat("--- DIF Interaction Table ---\n")
  cat("Facet:", x$config$facet, " | Group:", x$config$group, "\n")
  cat("Groups:", paste(x$config$group_levels, collapse = ", "), "\n")
  cat("Min obs:", x$config$min_obs, " | |t| warn:", x$config$abs_t_warn,
      " | |bias| warn:", x$config$abs_bias_warn, "\n\n")

  cat("Cell Summary:\n")
  print(as.data.frame(x$summary), row.names = FALSE)
  cat("\n")

  if (nrow(x$table) > 0) {
    show_cols <- intersect(
      c("Level", "GroupValue", "N", "ObsExpAvg", "StdResidual",
        "p_adjusted", "sparse", "flag_t", "flag_bias"),
      names(x$table)
    )
    print(as.data.frame(x$table |> select(all_of(show_cols))),
          row.names = FALSE, digits = 3)
  }
  invisible(x)
}

#' @export
print.mfrm_dif_interaction <- function(x, ...) {
  print(summary(x))
  invisible(x)
}

# ============================================================================
# B3. DIF Heatmap
# ============================================================================

#' Plot DIF interaction heatmap
#'
#' Visualizes the interaction between a facet and a grouping variable
#' as a heatmap. Rows represent facet levels, columns represent group
#' values, and cell color indicates the selected metric.
#'
#' @param x Output from [dif_interaction_table()] or [analyze_dif()].
#'   When an `mfrm_dif` object is passed, the `cell_table` element
#'   is used (requires `method = "residual"`).
#' @param metric Which metric to plot: `"obs_exp"` for observed-minus-expected
#'   average (default), `"t"` for the standardized residual / t-statistic,
#'   or `"contrast"` for pairwise DIF contrast (only for `mfrm_dif`
#'   objects with `dif_table`).
#' @param draw If `TRUE` (default), draw the plot.
#' @param ... Additional graphical parameters passed to [graphics::image()].
#'
#' @section Interpreting output:
#' - Warm colors (red) indicate positive Obs-Exp values (the model
#'   underestimates the facet level for that group).
#' - Cool colors (blue) indicate negative Obs-Exp values (the model
#'   overestimates).
#' - White/neutral indicates no systematic difference.
#'
#' @section Typical workflow:
#' 1. Compute interaction with [dif_interaction_table()].
#' 2. Plot with `plot_dif_heatmap(interaction_result)`.
#' 3. Identify extreme cells for follow-up.
#'
#' @return Invisibly, the matrix used for plotting.
#'
#' @seealso [dif_interaction_table()], [analyze_dif()], [dif_report()]
#' @examples
#' set.seed(42)
#' toy <- expand.grid(
#'   Person = paste0("P", 1:8),
#'   Rater = paste0("R", 1:3),
#'   Criterion = c("Content", "Organization"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- sample(0:2, nrow(toy), replace = TRUE)
#' toy$Group <- ifelse(as.integer(factor(toy$Person)) <= 4, "A", "B")
#'
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                  method = "JML", model = "RSM", maxit = 25)
#' diag <- diagnose_mfrm(fit, residual_pca = "none")
#' int <- dif_interaction_table(fit, diag, facet = "Rater",
#'                              group = "Group", data = toy, min_obs = 2)
#' plot_dif_heatmap(int, metric = "obs_exp")
#' @export
plot_dif_heatmap <- function(x, metric = c("obs_exp", "t", "contrast"),
                             draw = TRUE, ...) {
  metric <- match.arg(metric)

  # Resolve input: accept mfrm_dif_interaction or mfrm_dif
  if (inherits(x, "mfrm_dif_interaction")) {
    tbl <- x$table
    value_col <- switch(metric,
      obs_exp = "ObsExpAvg",
      t       = "StdResidual",
      contrast = {
        stop("metric = 'contrast' requires an `mfrm_dif` object with `dif_table`.",
             call. = FALSE)
      }
    )
    row_var <- "Level"
    col_var <- "GroupValue"
  } else if (inherits(x, "mfrm_dif")) {
    if (metric == "contrast") {
      tbl <- x$dif_table
      if (is.null(tbl) || nrow(tbl) == 0) {
        stop("No DIF contrasts available.", call. = FALSE)
      }
      value_col <- "Contrast"
      row_var <- "Level"
      # For contrast, pivot: rows = Level, columns = Group pairs
      tbl$col_label <- paste0(tbl$Group1, " vs ", tbl$Group2)
      col_var <- "col_label"
    } else {
      # Use cell_table
      tbl <- x$cell_table
      if (is.null(tbl) || nrow(tbl) == 0) {
        stop("No cell_table available. Use method = 'residual' in analyze_dif().",
             call. = FALSE)
      }
      value_col <- switch(metric,
        obs_exp = "ObsExpAvg",
        t       = "StdResidual"
      )
      row_var <- "Level"
      col_var <- "GroupValue"
    }
  } else {
    stop("`x` must be an `mfrm_dif_interaction` or `mfrm_dif` object.",
         call. = FALSE)
  }

  # Build matrix
  rows <- sort(unique(as.character(tbl[[row_var]])))
  cols <- sort(unique(as.character(tbl[[col_var]])))
  mat <- matrix(NA_real_, nrow = length(rows), ncol = length(cols),
                dimnames = list(rows, cols))
  for (i in seq_len(nrow(tbl))) {
    r <- as.character(tbl[[row_var]][i])
    cc <- as.character(tbl[[col_var]][i])
    val <- tbl[[value_col]][i]
    if (r %in% rows && cc %in% cols) {
      mat[r, cc] <- val
    }
  }

  if (draw) {
    # Color scale: blue-white-red
    n_colors <- 64
    max_abs <- max(abs(mat), na.rm = TRUE)
    if (!is.finite(max_abs) || max_abs == 0) max_abs <- 1
    breaks <- seq(-max_abs, max_abs, length.out = n_colors + 1)
    blue_white_red <- grDevices::colorRampPalette(
      c("steelblue", "white", "firebrick")
    )(n_colors)

    old_par <- graphics::par(mar = c(6, 8, 4, 2), no.readonly = TRUE)
    on.exit(graphics::par(old_par), add = TRUE)

    metric_label <- switch(metric,
      obs_exp = "Obs - Exp Average",
      t       = "Standardized Residual (t)",
      contrast = "DIF Contrast (logits)"
    )

    graphics::image(
      x = seq_len(ncol(mat)),
      y = seq_len(nrow(mat)),
      z = t(mat),
      col = blue_white_red,
      breaks = breaks,
      axes = FALSE,
      xlab = "", ylab = "",
      main = paste("DIF Heatmap:", metric_label),
      ...
    )
    graphics::axis(1, at = seq_len(ncol(mat)), labels = cols,
                   las = 2, cex.axis = 0.8)
    graphics::axis(2, at = seq_len(nrow(mat)), labels = rows,
                   las = 1, cex.axis = 0.8)
    graphics::box()

    # Add cell text
    for (ri in seq_len(nrow(mat))) {
      for (ci in seq_len(ncol(mat))) {
        val <- mat[ri, ci]
        if (is.finite(val)) {
          graphics::text(ci, ri, sprintf("%.2f", val), cex = 0.6)
        }
      }
    }
  }

  invisible(mat)
}

# ============================================================================
# C. Information Function Computation and Plotting
# ============================================================================

#' Compute test and facet-level information functions
#'
#' Calculates the Fisher information as a function of the latent trait
#' (theta) for the fitted MFRM model. Returns both the total test
#' information function (TIF) and per-facet-level item information
#' functions (IIF).
#'
#' @param fit Output from [fit_mfrm()].
#' @param theta_range Numeric vector of length 2 giving the range of theta
#'   values. Default `c(-6, 6)`.
#' @param theta_points Integer number of points at which to evaluate
#'   information. Default `201`.
#'
#' @details
#' For a polytomous Rasch model with K+1 categories, the information at
#' theta for a specific item/facet combination is:
#' \deqn{I(\theta) = \sum_{k=0}^{K} P_k(\theta) \left(k - E(\theta)\right)^2}
#' where \eqn{P_k} is the category probability and \eqn{E(\theta)} is the
#' expected score at theta.
#'
#' The total test information is the sum of information across all facet
#' levels (excluding person), and the standard error of measurement at each
#' theta is \eqn{SE(\theta) = 1 / \sqrt{I(\theta)}}.
#'
#' @section Interpreting output:
#' - `$tif`: test information function data with theta, Information, and SE.
#' - `$iif`: per-facet-level information.
#' - Higher information implies more precise measurement at that theta.
#' - SE is inversely related to information.
#'
#' @section Typical workflow:
#' 1. Fit a model with [fit_mfrm()].
#' 2. Run `compute_information(fit)`.
#' 3. Plot with `plot_information(info)`.
#'
#' @return
#' An object of class `mfrm_information` (named list) with:
#' - `tif`: tibble with columns `Theta`, `Information`, `SE`.
#' - `iif`: tibble with columns `Theta`, `Facet`, `Level`, `Information`.
#' - `theta_range`: the evaluated theta range.
#'
#' @seealso [fit_mfrm()], [plot_information()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                  method = "JML", model = "RSM", maxit = 25)
#' info <- compute_information(fit)
#' info$tif
#' @export
compute_information <- function(fit,
                                theta_range = c(-6, 6),
                                theta_points = 201L) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an `mfrm_fit` object.", call. = FALSE)
  }

  theta_grid <- seq(theta_range[1], theta_range[2], length.out = theta_points)

  # Extract model parameters
  steps <- fit$steps
  if (is.null(steps) || nrow(steps) == 0 || !"Estimate" %in% names(steps)) {
    stop("Step/threshold estimates are required for information computation.",
         call. = FALSE)
  }
  step_est <- steps$Estimate
  K <- length(step_est)  # number of thresholds (categories = K+1)

  facet_tbl <- tibble::as_tibble(fit$facets$others)
  if (nrow(facet_tbl) == 0) {
    stop("Facet estimates are required for information computation.",
         call. = FALSE)
  }

  model <- toupper(as.character(fit$config$model[1]))
  signs <- fit$config$signs
  if (is.null(signs)) signs <- rep(-1, length(fit$config$facet_cols))

  # Compute category probabilities for RSM
  compute_probs <- function(theta, delta, step_params) {
    # delta = sum of facet difficulties for this combination
    # step_params = threshold parameters
    ncat <- length(step_params) + 1
    log_numerator <- numeric(ncat)
    log_numerator[1] <- 0
    for (k in seq_along(step_params)) {
      log_numerator[k + 1] <- log_numerator[k] + (theta - delta - step_params[k])
    }
    log_denom <- max(log_numerator) + log(sum(exp(log_numerator - max(log_numerator))))
    exp(log_numerator - log_denom)
  }

  # Information for a single facet level at each theta
  compute_level_info <- function(theta_grid, delta, step_params) {
    vapply(theta_grid, function(th) {
      probs <- compute_probs(th, delta, step_params)
      categories <- seq(0, length(step_params))
      expected <- sum(categories * probs)
      sum(probs * (categories - expected)^2)
    }, numeric(1))
  }

  # Iterate over facet levels
  iif_rows <- list()
  total_info <- rep(0, length(theta_grid))

  for (i in seq_len(nrow(facet_tbl))) {
    f_name <- facet_tbl$Facet[i]
    f_level <- facet_tbl$Level[i]
    f_est <- facet_tbl$Estimate[i]
    if (!is.finite(f_est)) next

    # For RSM all levels share the same step parameters
    delta <- f_est
    level_info <- compute_level_info(theta_grid, delta, step_est)

    iif_rows[[length(iif_rows) + 1]] <- tibble(
      Theta = theta_grid,
      Facet = f_name,
      Level = f_level,
      Information = level_info
    )
    total_info <- total_info + level_info
  }

  iif <- bind_rows(iif_rows)
  tif <- tibble(
    Theta = theta_grid,
    Information = total_info,
    SE = ifelse(total_info > 0, 1 / sqrt(total_info), NA_real_)
  )

  out <- list(tif = tif, iif = iif, theta_range = theta_range)
  class(out) <- c("mfrm_information", class(out))
  out
}

#' Plot test and item information functions
#'
#' Visualize the test information function (TIF) and optionally
#' per-facet-level item information functions (IIF) from
#' [compute_information()].
#'
#' @param x Output from [compute_information()].
#' @param type `"tif"` for test information (default), `"iif"` for
#'   item/facet-level information, `"se"` for standard error of
#'   measurement, or `"both"` for TIF with SE on a secondary axis.
#' @param facet For `type = "iif"`, which facet to plot. If `NULL`,
#'   the first facet is used.
#' @param draw If `TRUE` (default), draw the plot. If `FALSE`, return
#'   the plot data invisibly.
#' @param ... Additional graphical parameters.
#'
#' @section Interpreting output:
#' - TIF peaks where measurement is most precise.
#' - SE is the inverse square root of information; lower is better.
#' - IIF shows which facet levels contribute most information at each theta.
#'
#' @section Typical workflow:
#' 1. Compute information with [compute_information()].
#' 2. Plot with `plot_information(info)` for TIF.
#' 3. Use `plot_information(info, type = "iif", facet = "Rater")` for IIF.
#'
#' @return Invisibly, the plot data (tibble).
#'
#' @seealso [compute_information()], [fit_mfrm()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                  method = "JML", model = "RSM", maxit = 25)
#' info <- compute_information(fit)
#' plot_information(info, type = "tif")
#' @export
plot_information <- function(x,
                             type = c("tif", "iif", "se", "both"),
                             facet = NULL,
                             draw = TRUE,
                             ...) {
  if (!inherits(x, "mfrm_information")) {
    stop("`x` must be an `mfrm_information` object.", call. = FALSE)
  }
  type <- match.arg(type)

  if (type == "tif" || type == "both") {
    plot_data <- x$tif
    if (draw) {
      if (type == "both") {
        par_old <- graphics::par(mar = c(5, 4, 4, 4) + 0.1)
        on.exit(graphics::par(par_old), add = TRUE)
      }
      plot(plot_data$Theta, plot_data$Information,
           type = "l", lwd = 2, col = "steelblue",
           xlab = expression(theta), ylab = "Information",
           main = "Test Information Function", ...)
      graphics::grid()
      if (type == "both") {
        graphics::par(new = TRUE)
        plot(plot_data$Theta, plot_data$SE,
             type = "l", lwd = 2, col = "coral", lty = 2,
             axes = FALSE, xlab = "", ylab = "")
        graphics::axis(4, col = "coral", col.axis = "coral")
        graphics::mtext("SE", side = 4, line = 2.5, col = "coral")
        graphics::legend("topright",
                         legend = c("Information", "SE"),
                         col = c("steelblue", "coral"),
                         lty = c(1, 2), lwd = 2, bty = "n")
      }
    }
    invisible(plot_data)
  } else if (type == "se") {
    plot_data <- x$tif
    if (draw) {
      plot(plot_data$Theta, plot_data$SE,
           type = "l", lwd = 2, col = "coral",
           xlab = expression(theta), ylab = "Standard Error",
           main = "Standard Error of Measurement", ...)
      graphics::grid()
    }
    invisible(plot_data)
  } else {
    # IIF
    iif <- x$iif
    if (is.null(facet)) {
      facet <- unique(iif$Facet)[1]
    }
    plot_data <- iif |> filter(.data$Facet == facet)
    if (nrow(plot_data) == 0) {
      stop("No information data for facet '", facet, "'.", call. = FALSE)
    }
    if (draw) {
      levels_u <- unique(plot_data$Level)
      n_lev <- length(levels_u)
      cols <- grDevices::rainbow(n_lev, s = 0.7, v = 0.8)
      yr <- range(plot_data$Information, na.rm = TRUE)
      plot(NA, xlim = range(plot_data$Theta), ylim = yr,
           xlab = expression(theta), ylab = "Information",
           main = paste("Item Information:", facet), ...)
      for (k in seq_along(levels_u)) {
        sub <- plot_data |> filter(.data$Level == levels_u[k])
        graphics::lines(sub$Theta, sub$Information, col = cols[k], lwd = 1.5)
      }
      graphics::legend("topright", legend = levels_u, col = cols,
                       lty = 1, lwd = 1.5, bty = "n", cex = 0.8)
      graphics::grid()
    }
    invisible(plot_data)
  }
}

# ============================================================================
# D. Unified Wright Map (persons + all facets on shared logit scale)
# ============================================================================

#' Plot a unified Wright map with all facets on a shared logit scale
#'
#' Produces a FACETS-style variable map showing person ability distribution
#' alongside measure estimates for every facet in side-by-side columns on
#' the same logit scale.
#'
#' @param fit Output from [fit_mfrm()].
#' @param diagnostics Optional output from [diagnose_mfrm()].
#' @param bins Integer number of bins for the person histogram. Default `20`.
#' @param show_thresholds Logical; if `TRUE`, display threshold/step
#'   positions on the map. Default `TRUE`.
#' @param draw If `TRUE` (default), draw the plot. If `FALSE`, return
#'   plot data invisibly.
#' @param ... Additional graphical parameters.
#'
#' @details
#' This unified map arranges:
#' - Column 1: Person measure distribution (horizontal histogram)
#' - Columns 2..N: One column per facet, with level labels positioned at
#'   their estimated measure on the shared logit axis
#' - Final column (optional): Threshold/step positions
#'
#' The logit scale on the y-axis is shared, allowing direct visual
#' comparison of all facets and persons.
#'
#' @section Interpreting output:
#' - Facet levels at the same height on the map are at similar difficulty.
#' - The person histogram shows where examinees cluster relative to the
#'   facet scale.
#' - Thresholds (if shown) indicate category boundary positions.
#'
#' @section Typical workflow:
#' 1. Fit a model with [fit_mfrm()].
#' 2. Plot with `plot_wright_unified(fit)`.
#' 3. Compare person distribution with facet level locations.
#'
#' @return Invisibly, a list with `persons`, `facets`, and `thresholds`
#'   data used for the plot.
#'
#' @seealso [fit_mfrm()], [plot.mfrm_fit()]
#' @examples
#' toy <- expand.grid(
#'   Person = paste0("P", 1:4),
#'   Rater = paste0("R", 1:2),
#'   Criterion = c("Content", "Organization", "Language"),
#'   stringsAsFactors = FALSE
#' )
#' toy$Score <- (
#'   as.integer(factor(toy$Person)) +
#'   2 * as.integer(factor(toy$Rater)) +
#'   as.integer(factor(toy$Criterion))
#' ) %% 3
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                  method = "JML", model = "RSM", maxit = 25)
#' plot_wright_unified(fit)
#' @export
plot_wright_unified <- function(fit,
                                diagnostics = NULL,
                                bins = 20L,
                                show_thresholds = TRUE,
                                draw = TRUE,
                                ...) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an `mfrm_fit` object.", call. = FALSE)
  }

  # Extract persons
  person_tbl <- tibble::as_tibble(fit$facets$person)
  person_est <- person_tbl$Estimate[is.finite(person_tbl$Estimate)]
  if (length(person_est) == 0) {
    stop("No finite person estimates available.", call. = FALSE)
  }

  # Extract facets
  facet_tbl <- tibble::as_tibble(fit$facets$others)
  facet_tbl <- facet_tbl[is.finite(facet_tbl$Estimate), , drop = FALSE]
  facet_names <- unique(facet_tbl$Facet)

  # Thresholds
  thresh_tbl <- NULL
  if (show_thresholds && !is.null(fit$steps) && nrow(fit$steps) > 0) {
    thresh_tbl <- tibble::as_tibble(fit$steps)
    thresh_tbl <- thresh_tbl[is.finite(thresh_tbl$Estimate), , drop = FALSE]
  }

  # Compute y-axis range
  all_measures <- c(person_est, facet_tbl$Estimate)
  if (!is.null(thresh_tbl) && nrow(thresh_tbl) > 0) {
    all_measures <- c(all_measures, thresh_tbl$Estimate)
  }
  y_range <- range(all_measures, na.rm = TRUE)
  y_pad <- diff(y_range) * 0.05
  y_lim <- c(y_range[1] - y_pad, y_range[2] + y_pad)

  # Number of columns: persons + facets + (optional thresholds)
  n_facets <- length(facet_names)
  n_cols <- 1 + n_facets + if (show_thresholds && !is.null(thresh_tbl)) 1 else 0

  plot_data <- list(
    persons = person_est,
    facets = facet_tbl,
    thresholds = thresh_tbl,
    facet_names = facet_names,
    y_lim = y_lim
  )

  if (!draw) return(invisible(plot_data))

  # Draw
  old_par <- graphics::par(mar = c(4, 4, 3, 1), no.readonly = TRUE)
  on.exit(graphics::par(old_par), add = TRUE)

  col_widths <- c(2, rep(1.5, n_facets))
  if (show_thresholds && !is.null(thresh_tbl)) {
    col_widths <- c(col_widths, 1)
  }
  graphics::layout(matrix(seq_len(n_cols), nrow = 1), widths = col_widths)

  # Column 1: Person histogram (horizontal)
  graphics::par(mar = c(4, 4, 3, 0.5))
  h <- graphics::hist(person_est, breaks = bins, plot = FALSE)
  graphics::barplot(
    h$counts,
    horiz = TRUE,
    space = 0,
    col = "lightblue",
    border = "steelblue",
    axes = FALSE,
    xlim = c(0, max(h$counts) * 1.2),
    ylim = c(0, bins),
    main = ""
  )
  # Map bin midpoints to y positions
  bin_centers <- h$mids
  y_positions <- (bin_centers - y_lim[1]) / diff(y_lim) * bins
  graphics::axis(2, at = y_positions, labels = round(bin_centers, 1),
                 las = 1, cex.axis = 0.7)
  graphics::mtext("Persons", side = 3, line = 0.5, cex = 0.8)
  graphics::mtext("Logits", side = 2, line = 2.5, cex = 0.7)

  # Columns 2..N+1: Facet columns
  for (fi in seq_along(facet_names)) {
    graphics::par(mar = c(4, 0.5, 3, 0.5))
    f_sub <- facet_tbl |> filter(.data$Facet == facet_names[fi])

    plot(NA, xlim = c(0, 1), ylim = y_lim, axes = FALSE,
         xlab = "", ylab = "")
    graphics::abline(h = pretty(y_lim), col = "gray90", lty = 3)

    # Place labels at measure positions
    for (r in seq_len(nrow(f_sub))) {
      lbl <- as.character(f_sub$Level[r])
      if (nchar(lbl) > 12) lbl <- paste0(substr(lbl, 1, 10), "..")
      graphics::text(0.5, f_sub$Estimate[r], lbl, cex = 0.7, adj = 0.5)
      graphics::points(0.5, f_sub$Estimate[r], pch = 16, cex = 0.6,
                       col = "gray40")
    }
    graphics::mtext(facet_names[fi], side = 3, line = 0.5, cex = 0.8)
  }

  # Optional threshold column
  if (show_thresholds && !is.null(thresh_tbl) && nrow(thresh_tbl) > 0) {
    graphics::par(mar = c(4, 0.5, 3, 1))
    plot(NA, xlim = c(0, 1), ylim = y_lim, axes = FALSE,
         xlab = "", ylab = "")
    graphics::abline(h = pretty(y_lim), col = "gray90", lty = 3)
    for (r in seq_len(nrow(thresh_tbl))) {
      lbl <- if ("Step" %in% names(thresh_tbl)) {
        as.character(thresh_tbl$Step[r])
      } else {
        paste0("T", r)
      }
      graphics::text(0.5, thresh_tbl$Estimate[r], lbl, cex = 0.7, adj = 0.5)
      graphics::segments(0.1, thresh_tbl$Estimate[r],
                         0.9, thresh_tbl$Estimate[r],
                         col = "darkorange", lwd = 1.5)
    }
    graphics::mtext("Steps", side = 3, line = 0.5, cex = 0.8)
  }

  graphics::mtext("Unified Wright Map", side = 3, outer = TRUE,
                  line = -1.5, cex = 1.1, font = 2)

  invisible(plot_data)
}

# ============================================================================
# E. Anchoring & Equating Workflow (Phase 4)
# ============================================================================

# --- Internal helper: compute drift between anchored fit and baseline --------
.compute_drift <- function(fit, anchor_tbl, diagnostics = NULL) {
  # Get new estimates
  new_est <- make_anchor_table(fit, include_person = FALSE)

  # Join with baseline anchors
  joined <- dplyr::inner_join(
    anchor_tbl |> dplyr::rename(Baseline = "Anchor"),
    new_est |> dplyr::rename(New = "Anchor"),
    by = c("Facet", "Level")
  )

  if (nrow(joined) == 0) {
    return(tibble::tibble(
      Facet = character(), Level = character(), Baseline = numeric(),
      New = numeric(), Drift = numeric(), SE_New = numeric(),
      Drift_SE_Ratio = numeric(), Flag = logical()
    ))
  }

  # Get SE from diagnostics$measures (fit$facets$others does not contain SE)
  if (is.null(diagnostics)) {
    diagnostics <- diagnose_mfrm(fit)
  }
  measures <- tibble::as_tibble(diagnostics$measures)
  se_tbl <- measures |>
    dplyr::filter(.data$Facet != "Person") |>
    dplyr::transmute(
      Facet = as.character(.data$Facet),
      Level = as.character(.data$Level),
      SE_New = as.numeric(.data$SE)
    ) |>
    dplyr::distinct()

  joined <- dplyr::left_join(joined, se_tbl, by = c("Facet", "Level"))

  joined |>
    dplyr::mutate(
      Drift = .data$New - .data$Baseline,
      Drift_SE_Ratio = ifelse(is.na(.data$SE_New) | .data$SE_New == 0,
                               NA_real_, abs(.data$Drift) / .data$SE_New),
      Flag = abs(.data$Drift) > 0.5 | (!is.na(.data$Drift_SE_Ratio) & .data$Drift_SE_Ratio > 2)
    ) |>
    dplyr::arrange(dplyr::desc(abs(.data$Drift)))
}

# --- anchor_to_baseline ------------------------------------------------------

#' Fit new data anchored to a baseline calibration
#'
#' Re-estimates a many-facet Rasch model on new data while holding selected
#' facet parameters fixed at the values from a previous (baseline) calibration.
#' This is the standard workflow for monitoring rater stability, linking test
#' forms, or equating across administration windows.
#'
#' @param new_data Data frame in long format (one row per rating).
#' @param baseline_fit An `mfrm_fit` object from a previous calibration.
#' @param person Character column name for person/examinee.
#' @param facets Character vector of facet column names.
#' @param score Character column name for the rating score.
#' @param anchor_facets Character vector of facets to anchor (default: all
#'   non-Person facets).
#' @param include_person If `TRUE`, also anchor person estimates.
#' @param weight Optional character column name for observation weights.
#' @param model Scale model override; defaults to baseline model.
#' @param method Estimation method override; defaults to baseline method.
#' @param anchor_policy How to handle anchor issues: `"warn"`, `"error"`,
#'   `"silent"`.
#' @param ... Additional arguments passed to [fit_mfrm()].
#'
#' @details
#' This function automates the baseline-anchored calibration workflow:
#'
#' 1. Extracts anchor values from the baseline fit using [make_anchor_table()].
#' 2. Re-estimates the model on `new_data` with those anchors fixed via
#'    `fit_mfrm(..., anchors = anchor_table)`.
#' 3. Runs [diagnose_mfrm()] on the anchored fit.
#' 4. Computes element-level drift statistics (new estimate minus baseline
#'    estimate) for every common element.
#'
#' The `model` and `method` arguments default to the baseline fit's settings
#' so the calibration framework remains consistent.  Elements present in the
#' anchor table but absent from the new data are handled according to
#' `anchor_policy`: `"warn"` (default) emits a message, `"error"` stops
#' execution, and `"silent"` ignores silently.
#'
#' Drift is calculated for every element that appears in both the baseline
#' and the new calibration:
#' \deqn{\Delta_e = \hat{\delta}_{e,\text{new}} - \hat{\delta}_{e,\text{base}}}
#' An element is **flagged** when \eqn{|\Delta_e| > 0.5} logits or
#' \eqn{|\Delta_e / SE_e| > 2.0}.
#'
#' @section Interpreting output:
#' - `$drift`: one row per common element with columns `Facet`, `Level`,
#'   `Baseline`, `New`, `Drift`, `SE_New`, `Drift_SE_Ratio`, and `Flag`.
#'   Small absolute drift values (< 0.3 logits) indicate a stable scale.
#'   Flagged elements warrant further investigation.
#' - `$fit`: the full anchored `mfrm_fit` object, usable with
#'   [diagnose_mfrm()], [measurable_summary_table()], etc.
#' - `$diagnostics`: pre-computed diagnostics for the anchored calibration.
#' - `$baseline_anchors`: the anchor table fed to [fit_mfrm()], useful for
#'   auditing which elements were constrained.
#'
#' @section Typical workflow:
#' 1. Fit the baseline model: `fit1 <- fit_mfrm(...)`.
#' 2. Collect new data (e.g., a later administration).
#' 3. Call `res <- anchor_to_baseline(new_data, fit1, ...)`.
#' 4. Inspect `summary(res)` for flagged drift.
#' 5. For multi-wave monitoring, pass multiple fits to
#'    [detect_anchor_drift()] or [build_equating_chain()].
#'
#' @return Object of class `mfrm_anchored_fit` with components:
#'   \describe{
#'     \item{fit}{The anchored `mfrm_fit` object.}
#'     \item{diagnostics}{Output of [diagnose_mfrm()] on the anchored fit.}
#'     \item{baseline_anchors}{Anchor table extracted from the baseline.}
#'     \item{drift}{Tibble of element-level drift statistics.}
#'   }
#'
#' @seealso [fit_mfrm()], [make_anchor_table()], [detect_anchor_drift()],
#'   [diagnose_mfrm()], [build_equating_chain()]
#' @export
#' @examples
#' d1 <- load_mfrmr_data("study1")
#' fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score",
#'                  method = "JML", maxit = 25)
#' d2 <- load_mfrmr_data("study2")
#' res <- anchor_to_baseline(d2, fit1, "Person",
#'                           c("Rater", "Criterion"), "Score",
#'                           anchor_facets = "Criterion")
#' summary(res)
#' res$drift
anchor_to_baseline <- function(new_data, baseline_fit,
                               person, facets, score,
                               anchor_facets = NULL,
                               include_person = FALSE,
                               weight = NULL,
                               model = NULL, method = NULL,
                               anchor_policy = "warn",
                               ...) {
  # Validate baseline_fit
  stopifnot(inherits(baseline_fit, "mfrm_fit"))

  # Inherit model/method from baseline if not specified
  if (is.null(model))  model  <- baseline_fit$config$model
  if (is.null(method)) method <- baseline_fit$config$method

  # Extract anchor table from baseline
  anchor_tbl <- make_anchor_table(baseline_fit, facets = anchor_facets,
                                   include_person = include_person)

  if (nrow(anchor_tbl) == 0) {
    stop("No anchors could be extracted from the baseline fit.", call. = FALSE)
  }

  # Fit new data with anchors
  new_fit <- fit_mfrm(new_data, person = person, facets = facets, score = score,
                      weight = weight, model = model, method = method,
                      anchors = anchor_tbl, anchor_policy = anchor_policy, ...)

  # Compute diagnostics
  new_diag <- diagnose_mfrm(new_fit)

  # Compute drift: compare new estimates to baseline anchors for common elements
  drift <- .compute_drift(new_fit, anchor_tbl, diagnostics = new_diag)

  out <- list(
    fit = new_fit,
    diagnostics = new_diag,
    baseline_anchors = anchor_tbl,
    drift = drift
  )
  class(out) <- c("mfrm_anchored_fit", "list")
  out
}

#' @rdname anchor_to_baseline
#' @param x An `mfrm_anchored_fit` object.
#' @param ... Ignored.
#' @export
print.mfrm_anchored_fit <- function(x, ...) {
  print(summary(x))
  invisible(x)
}

#' @rdname anchor_to_baseline
#' @param object An `mfrm_anchored_fit` object (for `summary`).
#' @export
summary.mfrm_anchored_fit <- function(object, ...) {
  drift <- object$drift
  n_anchored <- nrow(object$baseline_anchors)
  n_common <- nrow(drift)
  n_flagged <- sum(drift$Flag, na.rm = TRUE)

  out <- list(
    n_anchored = n_anchored, n_common = n_common, n_flagged = n_flagged,
    drift_summary = if (n_common > 0) {
      drift |> dplyr::group_by(.data$Facet) |>
        dplyr::summarise(N = dplyr::n(), Mean_Drift = mean(abs(.data$Drift)),
                         Max_Drift = max(abs(.data$Drift)),
                         N_Flagged = sum(.data$Flag, na.rm = TRUE),
                         .groups = "drop")
    } else {
      tibble::tibble()
    },
    flagged = drift |> dplyr::filter(.data$Flag),
    converged = object$fit$summary$Converged
  )
  class(out) <- "summary.mfrm_anchored_fit"
  out
}

#' @rdname anchor_to_baseline
#' @export
print.summary.mfrm_anchored_fit <- function(x, ...) {
  cat("--- Anchored Fit Summary ---\n")
  cat("Converged:", x$converged, "\n")
  cat("Anchors used:", x$n_anchored, "| Common elements:", x$n_common,
      "| Flagged:", x$n_flagged, "\n\n")
  if (nrow(x$drift_summary) > 0) {
    cat("Drift by facet:\n")
    print(as.data.frame(x$drift_summary), row.names = FALSE, digits = 3)
  }
  if (nrow(x$flagged) > 0) {
    cat("\nFlagged elements (|Drift| > 0.5 or |Drift|/SE > 2):\n")
    print(as.data.frame(x$flagged), row.names = FALSE, digits = 3)
  }
  invisible(x)
}

# --- detect_anchor_drift -----------------------------------------------------

#' Detect anchor drift across multiple calibrations
#'
#' Compares facet estimates across two or more calibration waves to identify
#' elements whose difficulty/severity has shifted beyond acceptable thresholds.
#' Useful for monitoring rater drift over time or checking the stability of
#' item banks.
#'
#' @param fits Named list of `mfrm_fit` objects (e.g.,
#'   `list(Year1 = fit1, Year2 = fit2)`).
#' @param facets Character vector of facets to compare (default: all
#'   non-Person facets).
#' @param drift_threshold Absolute drift threshold for flagging (logits,
#'   default 0.5).
#' @param flag_se_ratio Drift/SE ratio threshold for flagging (default 2.0).
#' @param reference Index or name of the reference fit (default: first).
#' @param include_person Include person estimates in comparison.
#'
#' @details
#' For each non-reference wave, the function extracts facet-level estimates
#' using [make_anchor_table()] and computes the element-by-element difference
#' against the reference wave.  Standard errors are obtained from
#' [diagnose_mfrm()] applied to each fit.  Only elements common to both the
#' reference and a comparison wave are included.
#'
#' An element is **flagged** when either condition is met:
#' \deqn{|\Delta_e| > \texttt{drift\_threshold}}
#' \deqn{|\Delta_e / SE_e| > \texttt{flag\_se\_ratio}}
#' The dual-criterion approach guards against flagging elements with large
#' but imprecise estimates, and against missing small but precisely estimated
#' shifts.
#'
#' When `facets` is `NULL`, all non-Person facets are compared.  Providing a
#' subset (e.g., `facets = "Criterion"`) restricts comparison to those facets
#' only.
#'
#' @section Interpreting output:
#' - `$drift_table`: one row per element x wave combination, with columns
#'   `Facet`, `Level`, `Wave`, `Ref_Est`, `Wave_Est`, `Drift`, `SE`,
#'   `Drift_SE_Ratio`, and `Flag`.  Large drift signals instability.
#' - `$summary`: aggregated statistics by facet and wave: number of elements,
#'   mean/max absolute drift, and count of flagged elements.
#' - `$common_elements`: matrix of pairwise common element counts.  Small
#'   overlap weakens the comparison and results should be interpreted
#'   cautiously.
#' - `$config`: records the analysis parameters for reproducibility.
#'
#' @section Typical workflow:
#' 1. Fit separate models for each administration wave.
#' 2. Combine into a named list: `fits <- list(Spring = fit_s, Fall = fit_f)`.
#' 3. Call `drift <- detect_anchor_drift(fits)`.
#' 4. Review `summary(drift)` and `plot_anchor_drift(drift)`.
#' 5. Flagged elements may need to be removed from anchor sets or
#'    investigated for substantive causes (e.g., rater re-training).
#'
#' @return Object of class `mfrm_anchor_drift` with components:
#'   \describe{
#'     \item{drift_table}{Tibble of element-level drift statistics.}
#'     \item{summary}{Drift summary aggregated by facet and wave.}
#'     \item{common_elements}{Pairwise counts of common elements.}
#'     \item{config}{List of analysis configuration.}
#'   }
#'
#' @seealso [anchor_to_baseline()], [build_equating_chain()],
#'   [make_anchor_table()], [plot_anchor_drift()]
#' @export
#' @examples
#' d1 <- load_mfrmr_data("study1")
#' d2 <- load_mfrmr_data("study2")
#' fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score",
#'                  method = "JML", maxit = 25)
#' fit2 <- fit_mfrm(d2, "Person", c("Rater", "Criterion"), "Score",
#'                  method = "JML", maxit = 25)
#' drift <- detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2))
#' summary(drift)
#' drift$drift_table
detect_anchor_drift <- function(fits,
                                facets = NULL,
                                drift_threshold = 0.5,
                                flag_se_ratio = 2.0,
                                reference = 1L,
                                include_person = FALSE) {
  # Validate
  stopifnot(is.list(fits), length(fits) >= 2)
  for (f in fits) stopifnot(inherits(f, "mfrm_fit"))
  if (is.null(names(fits))) names(fits) <- paste0("Wave", seq_along(fits))

  ref_idx <- if (is.character(reference)) match(reference, names(fits)) else as.integer(reference)
  stopifnot(!is.na(ref_idx), ref_idx >= 1, ref_idx <= length(fits))

  # Extract estimates from each fit
  est_list <- lapply(fits, function(f) {
    make_anchor_table(f, facets = facets, include_person = include_person)
  })

  # Get SE from diagnostics$measures for each fit
  se_list <- lapply(fits, function(f) {
    diag <- diagnose_mfrm(f)
    measures <- tibble::as_tibble(diag$measures)
    if (isTRUE(include_person)) {
      measures |>
        dplyr::transmute(
          Facet = as.character(.data$Facet),
          Level = as.character(.data$Level),
          SE = as.numeric(.data$SE)
        ) |>
        dplyr::distinct()
    } else {
      measures |>
        dplyr::filter(.data$Facet != "Person") |>
        dplyr::transmute(
          Facet = as.character(.data$Facet),
          Level = as.character(.data$Level),
          SE = as.numeric(.data$SE)
        ) |>
        dplyr::distinct()
    }
  })

  ref_est <- est_list[[ref_idx]]
  wave_names <- names(fits)

  # Build drift table: for each non-reference wave, compute drift vs reference
  drift_rows <- list()
  for (i in seq_along(fits)) {
    if (i == ref_idx) next
    wave_est <- est_list[[i]]
    wave_se <- se_list[[i]]

    joined <- dplyr::inner_join(
      ref_est |> dplyr::rename(Ref_Est = "Anchor"),
      wave_est |> dplyr::rename(Wave_Est = "Anchor"),
      by = c("Facet", "Level")
    )

    if (nrow(joined) > 0) {
      joined <- dplyr::left_join(joined, wave_se, by = c("Facet", "Level"))
      joined <- joined |>
        dplyr::mutate(
          Reference = wave_names[ref_idx],
          Wave = wave_names[i],
          Drift = .data$Wave_Est - .data$Ref_Est,
          Drift_SE_Ratio = ifelse(is.na(.data$SE) | .data$SE == 0,
                                   NA_real_, abs(.data$Drift) / .data$SE),
          Flag = abs(.data$Drift) > drift_threshold |
            (!is.na(.data$Drift_SE_Ratio) & .data$Drift_SE_Ratio > flag_se_ratio)
        )
      drift_rows <- c(drift_rows, list(joined))
    }
  }

  drift_table <- if (length(drift_rows) > 0) {
    dplyr::bind_rows(drift_rows) |>
      dplyr::select("Facet", "Level", "Reference", "Wave",
                     "Ref_Est", "Wave_Est", "Drift", "SE",
                     "Drift_SE_Ratio", "Flag") |>
      dplyr::arrange(dplyr::desc(abs(.data$Drift)))
  } else {
    tibble::tibble(Facet = character(), Level = character(),
                   Reference = character(), Wave = character(),
                   Ref_Est = numeric(), Wave_Est = numeric(),
                   Drift = numeric(), SE = numeric(),
                   Drift_SE_Ratio = numeric(), Flag = logical())
  }

  # Summary by facet
  drift_summary <- if (nrow(drift_table) > 0) {
    drift_table |>
      dplyr::group_by(.data$Facet, .data$Wave) |>
      dplyr::summarise(
        N = dplyr::n(), Mean_Drift = mean(abs(.data$Drift)),
        Max_Drift = max(abs(.data$Drift)),
        N_Flagged = sum(.data$Flag, na.rm = TRUE), .groups = "drop"
      )
  } else {
    tibble::tibble()
  }

  # Common elements count
  common_counts <- tibble::tibble(
    Wave1 = character(), Wave2 = character(), N_Common = integer()
  )
  for (i in seq_along(fits)) {
    for (j in seq_along(fits)) {
      if (j <= i) next
      n_common <- nrow(dplyr::inner_join(est_list[[i]], est_list[[j]],
                                          by = c("Facet", "Level")))
      common_counts <- dplyr::bind_rows(common_counts,
        tibble::tibble(Wave1 = wave_names[i], Wave2 = wave_names[j],
                       N_Common = as.integer(n_common)))
    }
  }

  out <- list(
    drift_table = drift_table, summary = drift_summary,
    common_elements = common_counts,
    config = list(reference = wave_names[ref_idx],
                  drift_threshold = drift_threshold,
                  flag_se_ratio = flag_se_ratio,
                  facets = facets, waves = wave_names)
  )
  class(out) <- c("mfrm_anchor_drift", "list")
  out
}

#' @rdname detect_anchor_drift
#' @param x An `mfrm_anchor_drift` object.
#' @param ... Ignored.
#' @export
print.mfrm_anchor_drift <- function(x, ...) {
  print(summary(x))
  invisible(x)
}

#' @rdname detect_anchor_drift
#' @param object An `mfrm_anchor_drift` object (for `summary`).
#' @export
summary.mfrm_anchor_drift <- function(object, ...) {
  dt <- object$drift_table
  out <- list(
    n_comparisons = nrow(dt), n_flagged = sum(dt$Flag, na.rm = TRUE),
    summary = object$summary, common_elements = object$common_elements,
    flagged = dt |> dplyr::filter(.data$Flag),
    config = object$config
  )
  class(out) <- "summary.mfrm_anchor_drift"
  out
}

#' @rdname detect_anchor_drift
#' @export
print.summary.mfrm_anchor_drift <- function(x, ...) {
  cat("--- Anchor Drift Detection ---\n")
  cat("Reference:", x$config$reference, "\n")
  cat("Comparisons:", x$n_comparisons, "| Flagged:", x$n_flagged, "\n\n")
  if (nrow(x$summary) > 0) {
    cat("Drift summary by facet and wave:\n")
    print(as.data.frame(x$summary), row.names = FALSE, digits = 3)
  }
  if (nrow(x$common_elements) > 0) {
    cat("\nCommon elements:\n")
    print(as.data.frame(x$common_elements), row.names = FALSE)
  }
  if (nrow(x$flagged) > 0) {
    cat("\nFlagged elements:\n")
    print(as.data.frame(x$flagged |> utils::head(20)), row.names = FALSE, digits = 3)
    if (nrow(x$flagged) > 20) cat("... (", nrow(x$flagged) - 20, " more)\n")
  }
  invisible(x)
}

# --- build_equating_chain ----------------------------------------------------

#' Build an equating chain across ordered calibrations
#'
#' Links a series of calibration waves by computing mean offsets between
#' adjacent pairs of fits. Common linking elements (e.g., raters or items
#' that appear in consecutive administrations) are used to estimate the
#' scale shift. Cumulative offsets place all waves on a common metric
#' anchored to the first wave.
#'
#' @param fits Named list of `mfrm_fit` objects in chain order.
#' @param anchor_facets Character vector of facets to use as linking
#'   elements.
#' @param include_person Include person estimates in linking.
#' @param drift_threshold Threshold for flagging large residuals in links.
#'
#' @details
#' The equating chain uses the **mean offset** method.  For each pair of
#' adjacent waves \eqn{(A, B)}, the function:
#'
#' 1. Identifies common linking elements (facet levels present in both fits).
#' 2. Computes per-element differences:
#'    \deqn{d_e = \hat{\delta}_{e,B} - \hat{\delta}_{e,A}}
#' 3. Estimates the link offset as the mean of these differences:
#'    \deqn{\text{Offset}_{A \to B} = \bar{d}}
#' 4. Records `Offset_SD` (standard deviation of \eqn{d_e}) and
#'    `Max_Residual` (maximum absolute deviation from the mean) as
#'    indicators of link quality.
#'
#' Cumulative offsets are computed by chaining link offsets from Wave 1
#' forward, placing all waves onto the metric of the first wave.
#'
#' Elements whose per-link residual exceeds `drift_threshold` are flagged
#' in `$element_detail$Flag`.  A high `Offset_SD` or many flagged elements
#' signals an unstable link that may compromise the equating.
#'
#' @section Interpreting output:
#' - `$links`: one row per adjacent pair with `Link`, `N_Common`, `Offset`,
#'   `Offset_SD`, `Max_Residual`, and `N_Flagged`.  Small `Offset_SD`
#'   relative to the offset indicates a consistent shift across elements.
#' - `$cumulative`: one row per wave with its cumulative offset from Wave 1.
#'   Wave 1 always has offset 0.
#' - `$element_detail`: per-element linking statistics (estimate in each
#'   wave, difference, residual from mean offset, and flag status).
#'   Flagged elements may indicate DIF or rater re-training effects.
#' - `$config`: records wave names and analysis parameters.
#'
#' @section Typical workflow:
#' 1. Fit each administration wave separately: `fit_a <- fit_mfrm(...)`.
#' 2. Combine into an ordered named list:
#'    `fits <- list(Spring23 = fit_s, Fall23 = fit_f, Spring24 = fit_s2)`.
#' 3. Call `chain <- build_equating_chain(fits)`.
#' 4. Review `summary(chain)` for link quality.
#' 5. Visualize with `plot_anchor_drift(chain, type = "chain")`.
#' 6. For problematic links, investigate flagged elements in
#'    `chain$element_detail` and consider removing them from the anchor set.
#'
#' @return Object of class `mfrm_equating_chain` with components:
#'   \describe{
#'     \item{links}{Tibble of link-level statistics (offset, SD, etc.).}
#'     \item{cumulative}{Tibble of cumulative offsets per wave.}
#'     \item{element_detail}{Tibble of element-level linking details.}
#'     \item{config}{List of analysis configuration.}
#'   }
#'
#' @seealso [detect_anchor_drift()], [anchor_to_baseline()],
#'   [make_anchor_table()], [plot_anchor_drift()]
#' @export
#' @examples
#' d1 <- load_mfrmr_data("study1")
#' d2 <- load_mfrmr_data("study2")
#' fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score",
#'                  method = "JML", maxit = 25)
#' fit2 <- fit_mfrm(d2, "Person", c("Rater", "Criterion"), "Score",
#'                  method = "JML", maxit = 25)
#' chain <- build_equating_chain(list(Form1 = fit1, Form2 = fit2))
#' summary(chain)
#' chain$links
build_equating_chain <- function(fits,
                                 anchor_facets = NULL,
                                 include_person = FALSE,
                                 drift_threshold = 0.5) {
  stopifnot(is.list(fits), length(fits) >= 2)
  for (f in fits) stopifnot(inherits(f, "mfrm_fit"))
  if (is.null(names(fits))) names(fits) <- paste0("Form", seq_along(fits))

  wave_names <- names(fits)
  n_waves <- length(fits)

  # Extract estimates
  est_list <- lapply(fits, function(f) {
    make_anchor_table(f, facets = anchor_facets, include_person = include_person)
  })

  # Build links between adjacent pairs
  links <- list()
  element_details <- list()

  for (i in seq_len(n_waves - 1)) {
    from <- est_list[[i]]
    to <- est_list[[i + 1]]

    common <- dplyr::inner_join(
      from |> dplyr::rename(Est_From = "Anchor"),
      to |> dplyr::rename(Est_To = "Anchor"),
      by = c("Facet", "Level")
    )

    n_common <- nrow(common)

    if (n_common == 0) {
      warning(sprintf("No common elements between '%s' and '%s'.",
                       wave_names[i], wave_names[i + 1]),
              call. = FALSE)
      offset <- NA_real_
      offset_sd <- NA_real_
      max_drift <- NA_real_
    } else {
      diffs <- common$Est_To - common$Est_From
      offset <- mean(diffs)
      offset_sd <- if (n_common > 1) stats::sd(diffs) else 0
      max_drift <- max(abs(diffs - offset))  # max residual after mean shift

      common <- common |>
        dplyr::mutate(
          Link = paste0(wave_names[i], " -> ", wave_names[i + 1]),
          Diff = .data$Est_To - .data$Est_From,
          Residual = .data$Diff - offset,
          Flag = abs(.data$Residual) > drift_threshold
        )
      element_details <- c(element_details, list(common))
    }

    links <- c(links, list(tibble::tibble(
      Link = i,
      From = wave_names[i], To = wave_names[i + 1],
      N_Common = as.integer(n_common),
      Offset = offset, Offset_SD = offset_sd, Max_Residual = max_drift
    )))
  }

  links_tbl <- dplyr::bind_rows(links)

  # Cumulative offsets
  cum_offset <- cumsum(c(0, links_tbl$Offset))
  cumulative <- tibble::tibble(
    Wave = wave_names,
    Cumulative_Offset = cum_offset
  )

  element_detail <- if (length(element_details) > 0) {
    dplyr::bind_rows(element_details)
  } else {
    tibble::tibble()
  }

  out <- list(
    links = links_tbl, cumulative = cumulative,
    element_detail = element_detail,
    config = list(anchor_facets = anchor_facets,
                  drift_threshold = drift_threshold,
                  waves = wave_names)
  )
  class(out) <- c("mfrm_equating_chain", "list")
  out
}

#' @rdname build_equating_chain
#' @param x An `mfrm_equating_chain` object.
#' @param ... Ignored.
#' @export
print.mfrm_equating_chain <- function(x, ...) {
  print(summary(x))
  invisible(x)
}

#' @rdname build_equating_chain
#' @param object An `mfrm_equating_chain` object (for `summary`).
#' @export
summary.mfrm_equating_chain <- function(object, ...) {
  out <- list(links = object$links, cumulative = object$cumulative,
              n_flagged = sum(object$element_detail$Flag, na.rm = TRUE),
              config = object$config)
  class(out) <- "summary.mfrm_equating_chain"
  out
}

#' @rdname build_equating_chain
#' @export
print.summary.mfrm_equating_chain <- function(x, ...) {
  cat("--- Equating Chain ---\n")
  cat("Links:", nrow(x$links), "| Waves:",
      paste(x$config$waves, collapse = " -> "), "\n\n")
  cat("Link details:\n")
  print(as.data.frame(x$links), row.names = FALSE, digits = 3)
  cat("\nCumulative offsets:\n")
  print(as.data.frame(x$cumulative), row.names = FALSE, digits = 3)
  if (x$n_flagged > 0) cat("\nFlagged linking elements:", x$n_flagged, "\n")
  invisible(x)
}