# Classical DIF screening front door.

resolve_classical_dif_data <- function(x, data, facet, group, score, person) {
  if (inherits(x, "mfrm_fit")) {
    fit <- x
    df <- data %||% fit$prep$data
    person <- person %||% fit$config$person_col %||% "Person"
    score <- score %||% fit$config$score_col %||% "Score"
    facet_names <- fit$config$facet_cols %||% fit$config$facet_names %||% fit$prep$facet_names
    if (is.null(facet) || !facet %in% facet_names) {
      stop("`facet` must name one of the fitted model facets: ",
           paste(facet_names, collapse = ", "), ".", call. = FALSE)
    }
  } else if (is.data.frame(x)) {
    df <- x
    person <- person %||% "Person"
    score <- score %||% "Score"
    if (is.null(facet) || !is.character(facet) || length(facet) != 1L) {
      stop("`facet` must be a single column name.", call. = FALSE)
    }
  } else {
    stop("`x` must be an `mfrm_fit` object or a data frame.", call. = FALSE)
  }
  if (!is.data.frame(df) || nrow(df) == 0L) {
    stop("No data available for classical DIF analysis.", call. = FALSE)
  }
  needed <- c(person, facet, score, group)
  missing_cols <- setdiff(needed, names(df))
  if (length(missing_cols) > 0L) {
    stop("Classical DIF data are missing required column(s): ",
         paste(missing_cols, collapse = ", "), ".", call. = FALSE)
  }
  out <- data.frame(
    Person = as.character(df[[person]]),
    Level = as.character(df[[facet]]),
    Score = suppressWarnings(as.numeric(df[[score]])),
    Group = trimws(as.character(df[[group]])),
    stringsAsFactors = FALSE
  )
  ok <- !is.na(out$Person) & nzchar(out$Person) &
    !is.na(out$Level) & nzchar(out$Level) &
    !is.na(out$Group) & nzchar(out$Group) &
    is.finite(out$Score)
  if (!any(ok)) {
    stop("No complete person/facet/score/group rows are available for classical DIF.",
         call. = FALSE)
  }
  out <- out[ok, , drop = FALSE]
  out
}

classical_dif_pairs <- function(group_levels, focal) {
  if (!is.null(focal)) {
    focal <- .validate_dff_focal(focal, group_levels)
    return(expand.grid(
      Group1 = setdiff(group_levels, focal),
      Group2 = focal,
      stringsAsFactors = FALSE
    ))
  }
  pairs <- as.data.frame(t(utils::combn(group_levels, 2)), stringsAsFactors = FALSE)
  names(pairs) <- c("Group1", "Group2")
  pairs
}

classical_dif_person_level <- function(df) {
  item_scores <- df |>
    dplyr::group_by(.data$Person, .data$Group, .data$Level) |>
    dplyr::summarize(Score = mean(.data$Score, na.rm = TRUE), .groups = "drop")
  totals <- item_scores |>
    dplyr::group_by(.data$Person) |>
    dplyr::summarize(TotalScore = sum(.data$Score, na.rm = TRUE), .groups = "drop")
  item_scores |>
    dplyr::left_join(totals, by = "Person") |>
    dplyr::mutate(MatchScore = .data$TotalScore - .data$Score) |>
    as.data.frame(stringsAsFactors = FALSE)
}

classical_match_strata <- function(x, bins = 5L) {
  x <- suppressWarnings(as.numeric(x))
  bins <- max(2L, as.integer(bins))
  ux <- sort(unique(x[is.finite(x)]))
  out <- rep(NA_character_, length(x))
  if (length(ux) == 0L) return(factor(out))
  if (length(ux) <= bins) {
    out[is.finite(x)] <- as.character(round(x[is.finite(x)], 6))
    return(factor(out))
  }
  probs <- seq(0, 1, length.out = bins + 1L)
  br <- unique(as.numeric(stats::quantile(x[is.finite(x)], probs = probs,
                                          na.rm = TRUE, names = FALSE,
                                          type = 7)))
  if (length(br) < 3L) {
    out[is.finite(x)] <- as.character(round(x[is.finite(x)], 6))
    return(factor(out))
  }
  out[is.finite(x)] <- as.character(cut(x[is.finite(x)], breaks = br,
                                        include.lowest = TRUE,
                                        ordered_result = TRUE))
  factor(out)
}

classical_mh_one <- function(sub, min_obs, match_bins) {
  if (nrow(sub) < 2L) {
    return(list(
      statistic = NA_real_, df = NA_real_, p_value = NA_real_,
      detail = "insufficient_rows"
    ))
  }
  n_by_group <- table(sub$Group)
  if (length(n_by_group) != 2L || any(n_by_group < min_obs)) {
    return(list(
      statistic = NA_real_, df = NA_real_, p_value = NA_real_,
      detail = "insufficient_group_n"
    ))
  }
  score_levels <- sort(unique(sub$Score))
  if (length(score_levels) < 2L) {
    return(list(
      statistic = NA_real_, df = NA_real_, p_value = NA_real_,
      detail = "single_score_category"
    ))
  }
  sub$ScoreFactor <- factor(sub$Score, levels = score_levels, ordered = TRUE)
  sub$MatchStratum <- classical_match_strata(sub$MatchScore, bins = match_bins)
  keep_strata <- names(which(tapply(sub$Group, sub$MatchStratum, function(g) {
    length(unique(g)) == 2L
  })))
  sub <- sub[sub$MatchStratum %in% keep_strata, , drop = FALSE]
  if (nrow(sub) == 0L || length(unique(sub$MatchStratum)) == 0L) {
    return(list(
      statistic = NA_real_, df = NA_real_, p_value = NA_real_,
      detail = "no_common_match_strata"
    ))
  }
  tab <- stats::xtabs(~ Group + ScoreFactor + MatchStratum, data = sub)
  res <- tryCatch(stats::mantelhaen.test(tab, correct = FALSE),
                  error = function(e) e)
  if (inherits(res, "error")) {
    return(list(
      statistic = NA_real_, df = NA_real_, p_value = NA_real_,
      detail = paste0("mh_failed: ", conditionMessage(res))
    ))
  }
  list(
    statistic = unname(as.numeric(res$statistic)),
    df = unname(as.numeric(res$parameter %||% NA_real_)),
    p_value = unname(as.numeric(res$p.value)),
    detail = "generalized_cmh_by_total_score"
  )
}

classical_logistic_one <- function(sub, min_obs, threshold) {
  n_by_group <- table(sub$Group)
  if (length(n_by_group) != 2L || any(n_by_group < min_obs)) {
    return(list(rows = data.frame(), detail = "insufficient_group_n"))
  }
  score_levels <- sort(unique(sub$Score))
  if (is.null(threshold)) {
    if (length(score_levels) != 2L) {
      return(list(rows = data.frame(), detail = "requires_binary_or_threshold"))
    }
    threshold <- max(score_levels)
  }
  threshold <- suppressWarnings(as.numeric(threshold))
  if (!is.finite(threshold)) {
    return(list(rows = data.frame(), detail = "invalid_threshold"))
  }
  sub$Y <- as.integer(sub$Score >= threshold)
  if (length(unique(sub$Y)) < 2L) {
    return(list(rows = data.frame(), detail = "single_binary_outcome"))
  }
  sub$GroupBinary <- as.integer(as.character(sub$Group) == levels(sub$Group)[2])
  fit0 <- tryCatch(suppressWarnings(stats::glm(Y ~ MatchScore, data = sub, family = stats::binomial())),
                   error = function(e) e)
  fit1 <- tryCatch(suppressWarnings(stats::glm(Y ~ MatchScore + GroupBinary, data = sub, family = stats::binomial())),
                   error = function(e) e)
  fit2 <- tryCatch(suppressWarnings(stats::glm(Y ~ MatchScore * GroupBinary, data = sub, family = stats::binomial())),
                   error = function(e) e)
  if (inherits(fit0, "error") || inherits(fit1, "error") || inherits(fit2, "error")) {
    return(list(rows = data.frame(), detail = "glm_failed"))
  }
  a01 <- tryCatch(stats::anova(fit0, fit1, test = "Chisq"), error = function(e) NULL)
  a12 <- tryCatch(stats::anova(fit1, fit2, test = "Chisq"), error = function(e) NULL)
  coefs <- summary(fit2)$coefficients
  uniform_effect <- if ("GroupBinary" %in% rownames(coefs)) coefs["GroupBinary", "Estimate"] else NA_real_
  uniform_se <- if ("GroupBinary" %in% rownames(coefs)) coefs["GroupBinary", "Std. Error"] else NA_real_
  interaction_row <- grep("MatchScore:GroupBinary|GroupBinary:MatchScore",
                          rownames(coefs), value = TRUE)
  nonuniform_effect <- if (length(interaction_row) > 0L) coefs[interaction_row[1], "Estimate"] else NA_real_
  nonuniform_se <- if (length(interaction_row) > 0L) coefs[interaction_row[1], "Std. Error"] else NA_real_
  rows <- data.frame(
    Method = c("logistic_uniform", "logistic_nonuniform"),
    Contrast = c(uniform_effect, nonuniform_effect),
    SE = c(uniform_se, nonuniform_se),
    Statistic = c(
      if (!is.null(a01) && nrow(a01) >= 2L) a01$Deviance[2] else NA_real_,
      if (!is.null(a12) && nrow(a12) >= 2L) a12$Deviance[2] else NA_real_
    ),
    df = c(
      if (!is.null(a01) && nrow(a01) >= 2L) a01$Df[2] else NA_real_,
      if (!is.null(a12) && nrow(a12) >= 2L) a12$Df[2] else NA_real_
    ),
    p_value = c(
      if (!is.null(a01) && nrow(a01) >= 2L) a01$`Pr(>Chi)`[2] else NA_real_,
      if (!is.null(a12) && nrow(a12) >= 2L) a12$`Pr(>Chi)`[2] else NA_real_
    ),
    LogisticThreshold = threshold,
    stringsAsFactors = FALSE
  )
  list(rows = rows, detail = "binary_logistic_lrt")
}

#' Classical DIF screening for long-format many-facet data
#'
#' Runs limited classical DIF screens on a long-format score table. The
#' Mantel-Haenszel route uses a generalized Cochran-Mantel-Haenszel test over
#' ordered score categories and total-score strata. The logistic route is a
#' binary logistic-regression screen; for polytomous data it runs only when
#' `logistic_threshold` is supplied, making the dichotomization explicit.
#'
#' @details
#' Rows are first collapsed to one mean score per `person` x `group` x
#' `facet` level. The matching variable for a target level is the person's
#' total observed score across the screened facet minus the target-level
#' score, so the target response is not used to condition on itself. When the
#' matching score has more distinct values than `match_bins`, quantile bins are
#' used as score strata.
#'
#' The Mantel-Haenszel option forms a
#' \eqn{Group \times Score \times MatchStratum} table and calls
#' [stats::mantelhaen.test()] without continuity correction. This is a
#' generalized Cochran-Mantel-Haenszel screening p value for ordered score
#' categories. The reported `Contrast` remains the simple Group2-minus-Group1
#' mean score difference for direction; it is not a Mantel-Haenszel common odds
#' ratio.
#'
#' The logistic option fits binary models
#' \deqn{Y \sim MatchScore,}
#' \deqn{Y \sim MatchScore + Group,}
#' \deqn{Y \sim MatchScore * Group.}
#' The `logistic_uniform` row is the likelihood-ratio comparison of the first
#' two models. The `logistic_nonuniform` row is the likelihood-ratio comparison
#' of the second and third models. For polytomous scores, `Y` is defined as
#' \eqn{1(Score \ge logistic_threshold)}; no implicit dichotomization is used.
#'
#' @param x An `mfrm_fit` or a data frame.
#' @param facet Facet/item column to screen level by level.
#' @param group Grouping column.
#' @param data Optional original data when `x` is a fit and `group` is not in
#'   `fit$prep$data`.
#' @param score Score column. Inferred from `x` when `x` is an `mfrm_fit`;
#'   defaults to `"Score"` for data frames.
#' @param person Person/respondent column. Inferred from `x` when possible;
#'   defaults to `"Person"` for data frames.
#' @param methods One or more of `"mantel_haenszel"` and `"logistic"`.
#' @param focal Optional focal group level(s). If omitted, all group pairs are
#'   compared.
#' @param min_obs Minimum person-level observations per group and facet level.
#' @param match_bins Number of total-score strata used by the generalized
#'   Mantel-Haenszel route when the matching score has many distinct values.
#' @param p_adjust Adjustment method passed to [stats::p.adjust()].
#' @param logistic_threshold Numeric threshold for binary logistic DIF on
#'   polytomous scores. Scores greater than or equal to this value are coded 1.
#'
#' @return An object of class `mfrm_dff` / `mfrm_dif` with `dif_table`,
#'   `cell_table`, `summary`, and `config` fields.
#'
#' @section Scope:
#' This is a classical screening helper, not a replacement for
#' [analyze_dff()] or SIBTEST. It does not estimate MFRM subgroup parameters,
#' does not use anchors, and does not claim ETS A/B/C classifications.
#'
#' @section References:
#' - Mantel, N., & Haenszel, W. (1959). Statistical aspects of the analysis of
#'   data from retrospective studies of disease. *Journal of the National
#'   Cancer Institute, 22*, 719-748.
#' - Holland, P. W., & Thayer, D. T. (1988). Differential item performance and
#'   the Mantel-Haenszel procedure. In H. Wainer & H. I. Braun (Eds.),
#'   *Test validity*.
#' - Swaminathan, H., & Rogers, H. J. (1990). Detecting differential item
#'   functioning using logistic regression procedures. *Journal of Educational
#'   Measurement, 27*(4), 361-370.
#'
#' @examples
#' toy <- load_mfrmr_data("example_bias")
#' cls <- analyze_dif_classical(
#'   toy, facet = "Criterion", group = "Group",
#'   person = "Person", score = "Score",
#'   methods = "mantel_haenszel"
#' )
#' cls$summary
#' @export
analyze_dif_classical <- function(x,
                                  facet,
                                  group,
                                  data = NULL,
                                  score = NULL,
                                  person = NULL,
                                  methods = c("mantel_haenszel", "logistic"),
                                  focal = NULL,
                                  min_obs = 10L,
                                  match_bins = 5L,
                                  p_adjust = "holm",
                                  logistic_threshold = NULL) {
  methods <- unique(match.arg(methods, several.ok = TRUE))
  min_obs <- .validate_dff_count_arg(min_obs, "min_obs")
  match_bins <- .validate_dff_count_arg(match_bins, "match_bins")
  p_adjust <- .validate_p_adjust_method(p_adjust)
  df <- resolve_classical_dif_data(x, data, facet, group, score, person)
  group_levels <- sort(unique(df$Group))
  if (length(group_levels) < 2L) {
    stop("`group` must have at least two non-missing levels.", call. = FALSE)
  }
  pairs <- classical_dif_pairs(group_levels, focal)
  person_level <- classical_dif_person_level(df)
  levels <- sort(unique(person_level$Level))

  cell_table <- person_level |>
    dplyr::group_by(.data$Level, .data$Group) |>
    dplyr::summarize(
      N = dplyr::n(),
      MeanScore = mean(.data$Score, na.rm = TRUE),
      MeanMatchScore = mean(.data$MatchScore, na.rm = TRUE),
      .groups = "drop"
    ) |>
    as.data.frame(stringsAsFactors = FALSE)

  rows <- list()
  for (lev in levels) {
    lev_dat <- person_level[person_level$Level == lev, , drop = FALSE]
    for (i in seq_len(nrow(pairs))) {
      g1 <- pairs$Group1[i]
      g2 <- pairs$Group2[i]
      sub <- lev_dat[lev_dat$Group %in% c(g1, g2), , drop = FALSE]
      sub$Group <- factor(sub$Group, levels = c(g1, g2))
      n1 <- sum(sub$Group == g1, na.rm = TRUE)
      n2 <- sum(sub$Group == g2, na.rm = TRUE)
      mean1 <- mean(sub$Score[sub$Group == g1], na.rm = TRUE)
      mean2 <- mean(sub$Score[sub$Group == g2], na.rm = TRUE)
      mean_diff <- mean2 - mean1

      if ("mantel_haenszel" %in% methods) {
        mh <- classical_mh_one(sub, min_obs = min_obs, match_bins = match_bins)
        rows[[length(rows) + 1L]] <- data.frame(
          Level = lev,
          Group1 = g1,
          Group2 = g2,
          Contrast = mean_diff,
          ContrastDirection = dplyr::case_when(
            is.finite(mean_diff) & mean_diff > 0 ~ "higher_for_group2",
            is.finite(mean_diff) & mean_diff < 0 ~ "higher_for_group1",
            is.finite(mean_diff) ~ "no_mean_difference",
            TRUE ~ NA_character_
          ),
          SE = NA_real_,
          t = NA_real_,
          df = mh$df %||% NA_real_,
          p_value = mh$p_value %||% NA_real_,
          AbsDiff = abs(mean_diff),
          Method = "mantel_haenszel",
          Statistic = mh$statistic %||% NA_real_,
          N_Group1 = as.integer(n1),
          N_Group2 = as.integer(n2),
          sparse = n1 < min_obs || n2 < min_obs,
          ContrastComparable = TRUE,
          FormalInferenceEligible = FALSE,
          PrimaryReportingEligible = FALSE,
          InferenceTier = "classical_screening",
          ComparisonMethod = "generalized_cmh_total_score",
          ScaleLinkStatus = "not_applicable",
          ReportingUse = "screening_only",
          Detail = mh$detail %||% NA_character_,
          LogisticThreshold = NA_real_,
          stringsAsFactors = FALSE
        )
      }

      if ("logistic" %in% methods) {
        lg <- classical_logistic_one(sub, min_obs = min_obs,
                                     threshold = logistic_threshold)
        if (nrow(lg$rows) == 0L) {
          rows[[length(rows) + 1L]] <- data.frame(
            Level = lev, Group1 = g1, Group2 = g2,
            Contrast = NA_real_, ContrastDirection = NA_character_,
            SE = NA_real_, t = NA_real_, df = NA_real_,
            p_value = NA_real_, AbsDiff = NA_real_,
            Method = "logistic_unavailable", Statistic = NA_real_,
            N_Group1 = as.integer(n1), N_Group2 = as.integer(n2),
            sparse = n1 < min_obs || n2 < min_obs,
            ContrastComparable = FALSE,
            FormalInferenceEligible = FALSE,
            PrimaryReportingEligible = FALSE,
            InferenceTier = "classical_screening",
            ComparisonMethod = "binary_logistic_lrt",
            ScaleLinkStatus = "not_applicable",
            ReportingUse = "screening_only",
            Detail = lg$detail %||% NA_character_,
            LogisticThreshold = logistic_threshold %||% NA_real_,
            stringsAsFactors = FALSE
          )
        } else {
          for (r in seq_len(nrow(lg$rows))) {
            rr <- lg$rows[r, , drop = FALSE]
            rows[[length(rows) + 1L]] <- data.frame(
              Level = lev, Group1 = g1, Group2 = g2,
              Contrast = rr$Contrast,
              ContrastDirection = dplyr::case_when(
                is.finite(rr$Contrast) & rr$Contrast > 0 ~ "higher_odds_for_group2",
                is.finite(rr$Contrast) & rr$Contrast < 0 ~ "higher_odds_for_group1",
                is.finite(rr$Contrast) ~ "no_log_odds_difference",
                TRUE ~ NA_character_
              ),
              SE = rr$SE, t = NA_real_, df = rr$df,
              p_value = rr$p_value, AbsDiff = abs(rr$Contrast),
              Method = rr$Method, Statistic = rr$Statistic,
              N_Group1 = as.integer(n1), N_Group2 = as.integer(n2),
              sparse = n1 < min_obs || n2 < min_obs,
              ContrastComparable = TRUE,
              FormalInferenceEligible = FALSE,
              PrimaryReportingEligible = FALSE,
              InferenceTier = "classical_screening",
              ComparisonMethod = "binary_logistic_lrt",
              ScaleLinkStatus = "not_applicable",
              ReportingUse = "screening_only",
              Detail = lg$detail,
              LogisticThreshold = rr$LogisticThreshold,
              stringsAsFactors = FALSE
            )
          }
        }
      }
    }
  }
  dif_table <- if (length(rows) > 0L) {
    dplyr::bind_rows(rows)
  } else {
    data.frame()
  }
  if (nrow(dif_table) > 0L && any(is.finite(dif_table$p_value))) {
    dif_table$p_adjusted <- stats::p.adjust(dif_table$p_value, method = p_adjust)
  } else {
    dif_table$p_adjusted <- NA_real_
  }
  sig <- ifelse(is.finite(dif_table$p_adjusted),
                dif_table$p_adjusted <= 0.05,
                ifelse(is.finite(dif_table$p_value), dif_table$p_value <= 0.05, NA))
  dif_table$ContrastBasis <- ifelse(
    dif_table$Method == "mantel_haenszel",
    "focal-minus-reference mean score difference; p from generalized CMH",
    "binary logistic regression coefficient or interaction"
  )
  dif_table$SEBasis <- ifelse(grepl("^logistic", dif_table$Method),
                              "glm coefficient standard error",
                              "not reported for generalized CMH mean contrast")
  dif_table$StatisticLabel <- ifelse(dif_table$Method == "mantel_haenszel",
                                     "Cochran-Mantel-Haenszel chi-square",
                                     "logistic likelihood-ratio chi-square")
  dif_table$ProbabilityMetric <- "classical screening p value"
  dif_table$DFBasis <- "asymptotic chi-square"
  dif_table$EffectMetric <- ifelse(dif_table$Method == "mantel_haenszel",
                                   "mean_score_difference",
                                   "log_odds")
  dif_table$ClassificationSystem <- "classical_screening"
  dif_table$Classification <- dplyr::case_when(
    !is.finite(dif_table$Contrast) & !is.finite(dif_table$p_value) ~ NA_character_,
    sig %in% TRUE ~ "Screen positive",
    sig %in% FALSE ~ "Screen negative",
    TRUE ~ NA_character_
  )
  dif_table$ETS <- NA_character_

  summary <- data.frame(
    Classification = c("Screen positive", "Screen negative", "Unclassified"),
    Count = c(
      sum(dif_table$Classification == "Screen positive", na.rm = TRUE),
      sum(dif_table$Classification == "Screen negative", na.rm = TRUE),
      sum(is.na(dif_table$Classification), na.rm = TRUE)
    ),
    stringsAsFactors = FALSE
  )
  out <- list(
    dif_table = dif_table,
    cell_table = cell_table,
    summary = summary,
    group_fits = NULL,
    config = list(
      facet = facet,
      group = group,
      method = "classical",
      methods = methods,
      min_obs = min_obs,
      match_bins = match_bins,
      p_adjust = p_adjust,
      focal = focal,
      group_levels = group_levels,
      logistic_threshold = logistic_threshold,
      functioning_label = functioning_label_for_facet(facet)
    )
  )
  class(out) <- c("mfrm_dff", "mfrm_dif", "mfrm_classical_dif", class(out))
  out
}
