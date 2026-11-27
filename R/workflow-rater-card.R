.mfrm_docx_table <- function(doc, heading, table, digits) {
  if (NROW(table) == 0L) return(doc)
  doc <- officer::body_add_par(doc, heading, style = "heading 2")
  table <- .tidymfrm_round_df(table, digits)
  if (requireNamespace("flextable", quietly = TRUE)) {
    ft <- flextable::autofit(flextable::theme_booktabs(flextable::flextable(table)))
    return(flextable::body_add_flextable(doc, ft))
  }
  officer::body_add_table(doc, value = table, style = NULL)
}

.mfrm_rater_card <- function(wf, rater, criterion_facet, max_cases) {
  if (!is.character(rater) || length(rater) != 1L || is.na(rater) || !nzchar(rater))
    stop("rater must be one nonempty rater ID.", call. = FALSE)
  sp <- wf$spec
  rt <- wf$diagnostics$raters
  selected <- match(rater, rt$Level)
  if (is.na(selected)) stop("Run step_mfrm_diagnose() and supply a known rater ID.", call. = FALSE)
  rx <- rt[selected, , drop = FALSE]
  ready <- .mfrm_readiness(wf$fit)$ready
  rating_rows <- wf$diagnostics$observations
  obs <- rating_rows[as.character(rating_rows[[sp$rater_facet]]) == rater, , drop = FALSE]
  cmp <- as.character(rt$Level[is.finite(rt$Estimate)])
  pos_orient <- ("Sign" %in% names(rx)) && is.finite(rx$Sign[1L]) && (rx$Sign[1L] > 0)
  sev_all <- if (pos_orient) -rt$Estimate else rt$Estimate
  sev_sel <- if (pos_orient) -rx$Estimate else rx$Estimate
  severity_rank <- if (ready && isTRUE(wf$connectivity$rater_linkage$n_components == 1L) && rater %in% cmp)
    1 + sum(sev_all[rt$Level %in% cmp] < sev_sel)
  severity <- data.frame(SeverityLogit = rx$Estimate, ModelSE = rx$ModelSE, RealSE = rx$RealSE,
                         RankFromLeastSevere = severity_rank %||% NA_real_,
                         RatersInRanking = if (length(severity_rank)) length(cmp) else NA_integer_)
  fit_basis <- wf$diagnostics$fit_method %||%
    (if ("FitBasis" %in% names(rx)) rx$FitBasis[1L] else "plugin")
  has_post <- ("PostInfitMnSq" %in% names(rx)) && is.finite(rx$PostInfitMnSq[1L])
  audit <- data.frame(
    RatingRows = nrow(obs),
    Persons = length(unique(obs[[sp$person]])),
    ObservedAverage = rx$ObsAvg,
    FairM = rx$FairM,
    Infit = rx$InfitMnSq,
    InfitZSTD = rx$InfitZSTD,
    Outfit = rx$OutfitMnSq,
    OutfitZSTD = rx$OutfitZSTD,
    stringsAsFactors = FALSE
  )
  if (has_post) {
    audit$PostInfit <- rx$PostInfitMnSq
    audit$PostInfitZSTD <- rx$PostInfitZSTD
    audit$PostOutfit <- rx$PostOutfitMnSq
    audit$PostOutfitZSTD <- rx$PostOutfitZSTD
  }
  orient_note <- if (pos_orient) {
    "Positive-facet orientation (Sign = +1): higher estimates indicate more lenient scoring (higher expected scores when other fitted effects are fixed). RankFromLeastSevere orders from most lenient to strictest."
  } else {
    "Higher severity implies lower expected scores when other fitted effects are fixed. The comparison panel uses the observed rating network."
  }
  mnsq_r <- wf$diagnostics$mnsq_range %||% c(0.70, 1.30)
  z_lim <- wf$diagnostics$zstd_limit %||% 2.0
  rule_note <- sprintf(
    "Fit rule: %s Infit MnSq outside [%.2f, %.2f] with |ZSTD| >= %.1f (calibration: %s, primary person score: %s; RealSE uses plug-in Infit MnSq).",
    if (identical(fit_basis, "posterior")) "posterior-integrated (TAM::msq.itemfit basis)" else "plug-in",
    mnsq_r[1L], mnsq_r[2L], z_lim, wf$fit$method, wf$fit$score_method
  )
  active_z <- if (identical(fit_basis, "posterior") && "PostInfitZSTD" %in% names(rx)) rx$PostInfitZSTD[1L] else rx$InfitZSTD[1L]
  z_unavail_note <- if (!is.finite(active_z)) {
    "Active Infit ZSTD is unavailable (NA); joint MnSq + ZSTD screening cannot be confirmed from MnSq alone."
  }
  notes <- c(paste("Rater:", rater, "|", rx$DiagnosticFlag),
             paste("Recommended review:", rx$RecommendedAction),
             rule_note,
             z_unavail_note,
             orient_note)

  correlation <- function(a, b, persons) {
    ok <- is.finite(a) & is.finite(b)
    if (ready && length(unique(persons[ok])) >= 3L &&
        length(unique(a[ok])) > 1L && length(unique(b[ok])) > 1L)
      stats::cor(a[ok], b[ok]) else NA_real_
  }
  possible <- setdiff(sp$facets, sp$rater_facet)
  if (!is.null(criterion_facet) && (length(criterion_facet) != 1L || !criterion_facet %in% possible))
    stop("criterion_facet must select a non-rater facet.", call. = FALSE)
  if (is.null(criterion_facet))
    criterion_facet <- if (length(possible) == 1L) possible else if ("Criterion" %in% possible) "Criterion"
  center_rows <- if (is.null(criterion_facet)) list(All = seq_len(nrow(obs))) else
    split(seq_len(nrow(obs)), as.character(obs[[criterion_facet]]))
  center <- do.call(rbind, lapply(names(center_rows), function(level) {
    z <- obs[center_rows[[level]], , drop = FALSE]
    attr(z, "metric_cols") <- attr(obs, "metric_cols", exact = TRUE)
    z_res <- .tidymfrm_obs_col(z, "Residual")
    z_exp <- .tidymfrm_obs_col(z, "Expected")
    z_obs <- .tidymfrm_obs_col(z, "Observed")
    usable <- is.finite(z_res) & is.finite(z_exp)
    constant <- length(unique(z_obs[usable])) < 2L
    value <- if (constant) NA_real_ else correlation(z_res, z_exp, z[[sp$person]])
    data.frame(Criterion = level, ResidualExpectedCorrelation = value,
      Persons = length(unique(z[[sp$person]][usable])), RatingRows = sum(usable),
      Status = if (constant) "no_observed_score_variation" else
        if (is.finite(value)) "descriptive" else "unavailable")
  }))
  rownames(center) <- NULL
  halo <- NULL
  if (!is.null(criterion_facet)) {
    criterion <- as.character(obs[[criterion_facet]])
    contexts <- c(sp$person, setdiff(sp$facets, c(sp$rater_facet, criterion_facet)))
    if (!is.null(sp$occasion) && !sp$occasion %in% contexts) {
      obs[[sp$occasion]] <- wf$data[[sp$occasion]][.tidymfrm_obs_col(obs, ".row_id")]
      contexts <- c(contexts, sp$occasion)
    }
    mc_obs <- attr(obs, "metric_cols", exact = TRUE)
    rows <- which(stats::complete.cases(obs[c(contexts, criterion_facet)]))
    key <- .mfrm_mvgt_group(lapply(obs[rows, contexts, drop = FALSE], factor))
    obs <- obs[rows, , drop = FALSE]
    attr(obs, "metric_cols") <- mc_obs
    obs_std <- .tidymfrm_obs_col(obs, "StdResidual")
    obs_val <- .tidymfrm_obs_col(obs, "Observed")
    criterion <- criterion[rows]
    if (length(unique(criterion)) >= 2L) {
      pairs <- utils::combn(unique(criterion), 2L)
      halo <- do.call(rbind, lapply(seq_len(ncol(pairs)), function(i) {
        ia <- which(criterion == pairs[1L, i])
        ib <- which(criterion == pairs[2L, i])
        ka <- key[ia]; kb <- key[ib]
        shared <- intersect(ka, kb)
        ambiguous <- anyDuplicated(ka[ka %in% shared]) || anyDuplicated(kb[kb %in% shared])
        a <- ia[match(shared, ka)]; b <- ib[match(shared, kb)]
        ok <- is.finite(obs_std[a]) & is.finite(obs_std[b])
        paired_constant <- length(unique(obs_val[a][ok])) < 2L ||
          length(unique(obs_val[b][ok])) < 2L
        value <- if (!ambiguous && !paired_constant)
          correlation(obs_std[a], obs_std[b], obs[[sp$person]][a]) else NA_real_
        data.frame(CriterionA = pairs[1L, i], CriterionB = pairs[2L, i],
                   MatchedPersons = length(unique(obs[[sp$person]][a][ok])),
                   ResidualCorrelation = value,
                   Status = if (ambiguous) "ambiguous_repeated_context" else
                     if (!any(ok)) "no_matched_scores" else
                     if (paired_constant) "no_observed_score_variation" else
                     if (is.finite(value)) "descriptive" else "unavailable")
      }))
    }
  }
  notes <- c(notes,
    "Residual versus expected-score correlations are descriptive within each criterion. Negative values may reflect score compression, model misfit or conditioning on estimated person scores; they do not establish central tendency.",
    "Criterion-pair residual correlations are descriptive. Their null baseline depends on the fitted model, person scoring and rating design and can be negative. Neither a zero cutoff nor -1/(K-1) is calibrated here. Halo claims require a design-matched reference and review of shared performance features and model misfit.",
    if (is.null(criterion_facet)) "No criterion facet was selected; the central-tendency table pools scores and may confound criterion difficulty with compression.",
    if (is.null(halo)) "Matched criterion pairs are unavailable for a halo screen.")
  cases <- wf$diagnostics$unexpected
  mc_cases <- attr(wf$diagnostics$observations, "metric_cols", exact = TRUE)
  cases <- cases[as.character(cases[[sp$rater_facet]]) == rater, , drop = FALSE]
  attr(cases, "metric_cols") <- mc_cases
  row_col <- .tidymfrm_obs_col_name(cases, ".row_id")
  m_cols <- vapply(c("Observed", "Expected", "StdResidual"), function(k) .tidymfrm_obs_col_name(cases, k), character(1))
  case_cols <- intersect(unique(c(row_col, possible, m_cols)), names(cases))
  cases <- utils::head(cases[, case_cols, drop = FALSE], max_cases)
  in_lbl <- tail(make.unique(c(setdiff(names(cases), row_col), "InputRow")), 1L)
  names(cases)[names(cases) == row_col] <- in_lbl

  enc_fit <- wf$fit$encoding
  rmin_c <- wf$fit$rating_min
  rmax_c <- wf$fit$rating_max
  obs_orig <- rating_rows[as.character(rating_rows[[sp$rater_facet]]) == rater, , drop = FALSE]
  attr(obs_orig, "metric_cols") <- attr(rating_rows, "metric_cols", exact = TRUE)
  obs_scores <- .tidymfrm_obs_col(obs_orig, "Observed")
  cat_levels <- seq.int(rmin_c, rmax_c)
  usage_groups <- if (is.null(criterion_facet)) list(All = seq_len(nrow(obs_orig))) else
    split(seq_len(nrow(obs_orig)), as.character(obs_orig[[criterion_facet]]))
  cat_usage <- do.call(rbind, lapply(names(usage_groups), function(g_lbl) {
    idx_g <- usage_groups[[g_lbl]]
    sc_g <- obs_scores[idx_g]
    allow_min <- rmin_c
    allow_max <- rmax_c
    if (!is.null(criterion_facet) && identical(enc_fit$step_facet, criterion_facet)) {
      sg_m <- match(g_lbl, enc_fit$step_owners)
      if (!is.na(sg_m)) {
        allow_min <- rmin_c + enc_fit$step_cat_min[sg_m]
        allow_max <- rmin_c + enc_fit$step_cat_max[sg_m]
      }
    }
    cnts <- as.integer(table(factor(sc_g, levels = cat_levels)))
    cnt_df <- as.data.frame(as.list(stats::setNames(cnts, paste0("Cat_", cat_levels))), stringsAsFactors = FALSE)
    cbind(
      data.frame(
        Criterion = g_lbl,
        AllowedMin = allow_min,
        AllowedMax = allow_max,
        RatingRows = sum(is.finite(sc_g)),
        stringsAsFactors = FALSE
      ),
      cnt_df
    )
  }))
  rownames(cat_usage) <- NULL

  list(notes = notes, tables = list("Severity and comparison panel" = severity,
       "Rater fit and observed rubric scores" = audit,
       "Category usage by criterion" = cat_usage,
       "Central tendency screen" = center,
       "Criterion halo screen" = halo, "Largest unexpected ratings" = cases))
}

.mfrm_render_rater_card <- function(wf, rater, criterion_facet, max_cases, format, file, title, digits) {
  card <- .mfrm_rater_card(wf, rater, criterion_facet, max_cases)
  if (identical(format, "docx")) {
    if (!requireNamespace("officer", quietly = TRUE)) stop("Install officer to export Word.", call. = FALSE)
    if (is.null(file) || !nzchar(file)) stop("Supply file for Word output.", call. = FALSE)
    doc <- officer::body_add_par(officer::read_docx(), title, style = "heading 1")
    for (line in card$notes) doc <- officer::body_add_par(doc, line)
    for (heading in names(card$tables)) doc <- .mfrm_docx_table(doc, heading, card$tables[[heading]], digits)
    print(doc, target = file)
    return(invisible(file))
  }
  lines <- c(paste("#", title), "", paste0("- ", card$notes), "")
  for (heading in names(card$tables)) {
    table <- card$tables[[heading]]
    if (NROW(table)) lines <- c(lines, paste("##", heading), "", .tidymfrm_fmt_df_md(table, digits), "")
  }
  report <- paste(lines, collapse = "\n")
  report <- if (identical(format, "html")) .tidymfrm_md_to_html(report, title) else
    .tidymfrm_escape_markdown_html(report)
  if (!is.null(file)) writeLines(report, file, useBytes = TRUE)
  report
}
