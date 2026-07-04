# APA reporting review for 0.2.2 DIF/DFF helpers.
#
# This script is intentionally not part of the CRAN-time test suite. It builds
# representative DFF/DIF objects and checks that the APA reporting adapters keep
# the method route, table, note, caption, and overclaim boundaries aligned.

`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0L) y else x
}

.mfrmr_dif_apa_get_function <- function(name) {
  if (exists(name, mode = "function", inherits = TRUE)) {
    return(get(name, mode = "function", inherits = TRUE))
  }
  if (requireNamespace("mfrmr", quietly = TRUE)) {
    return(utils::getFromNamespace(name, "mfrmr"))
  }
  stop("`", name, "()` is not available. Load or install mfrmr first.",
       call. = FALSE)
}

.mfrmr_dif_apa_get_internal <- function(name) {
  if (exists(name, mode = "function", inherits = TRUE)) {
    return(get(name, mode = "function", inherits = TRUE))
  }
  if (requireNamespace("mfrmr", quietly = TRUE)) {
    return(utils::getFromNamespace(name, "mfrmr"))
  }
  stop("Internal helper `", name, "()` is not available.", call. = FALSE)
}

.mfrmr_dif_apa_fixture_data <- function() {
  load_mfrmr_data <- .mfrmr_dif_apa_get_function("load_mfrmr_data")
  dat <- load_mfrmr_data("study1")
  persons <- sort(unique(as.character(dat$Person)))
  idx <- match(as.character(dat$Person), persons)
  dat$Group2 <- ifelse(idx <= ceiling(length(persons) / 2), "Reference", "Focal")
  dat$Group3 <- c("G1", "G2", "G3")[
    ((idx - 1L) %% 3L) + 1L
  ]
  dat$AgeLike <- idx
  dat
}

.mfrmr_dif_apa_mh_fixture <- function() {
  persons <- sprintf("P%03d", seq_len(120))
  ability <- rep(0:3, each = 30)
  group <- rep(rep(c("Reference", "Focal"), each = 15), 4)
  person_tbl <- data.frame(
    Person = persons,
    AbilityBand = ability,
    Group = group,
    stringsAsFactors = FALSE
  )
  dat <- merge(
    expand.grid(
      Person = persons,
      Item = c("Anchor1", "Anchor2", "Anchor3", "Target"),
      KEEP.OUT.ATTRS = FALSE,
      stringsAsFactors = FALSE
    ),
    person_tbl,
    by = "Person",
    all.x = TRUE
  )
  dat$Score <- with(dat, ifelse(
    Item == "Anchor1", AbilityBand >= 1,
    ifelse(
      Item == "Anchor2", AbilityBand >= 2,
      ifelse(
        Item == "Anchor3", AbilityBand >= 3,
        ifelse(Group == "Reference", AbilityBand >= 2, AbilityBand >= 3)
      )
    )
  ))
  dat$Score <- as.integer(dat$Score)
  dat[, c("Person", "Item", "Score", "Group")]
}

.mfrmr_dif_apa_gpcm_data <- function() {
  sample_mfrm_data <- .mfrmr_dif_apa_get_internal("sample_mfrm_data")
  dat <- sample_mfrm_data(seed = 42)
  persons <- sort(unique(as.character(dat$Person)))
  idx <- match(as.character(dat$Person), persons)
  dat$Group2 <- ifelse(idx <= ceiling(length(persons) / 2), "Reference", "Focal")
  dat
}

.mfrmr_dif_apa_forbidden_hits <- function(text) {
  forbidden <- c(
    "bias was detected",
    "measurement bias was detected",
    "fairness was established",
    "invariance was established",
    "establishes measurement bias",
    "proved measurement bias",
    "proved fairness",
    "operational subgroup decision was made"
  )
  forbidden[vapply(forbidden, function(pattern) {
    grepl(tolower(pattern), tolower(text), fixed = TRUE)
  }, logical(1))]
}

.mfrmr_dif_apa_check_row <- function(case, check, passed, detail = "") {
  data.frame(
    Case = as.character(case),
    Check = as.character(check),
    Passed = isTRUE(passed),
    Detail = as.character(detail),
    stringsAsFactors = FALSE
  )
}

.mfrmr_dif_apa_case_review <- function(case,
                                       result,
                                       required_patterns = character(),
                                       table_required = character()) {
  dif_report <- .mfrmr_dif_apa_get_function("dif_report")
  apa_table <- .mfrmr_dif_apa_get_function("apa_table")
  rpt <- dif_report(result, style = "apa")
  tbl <- apa_table(result)
  rpt_table <- as.data.frame(rpt$apa_table, stringsAsFactors = FALSE)
  adapter_table <- as.data.frame(tbl$table, stringsAsFactors = FALSE)
  narrative <- paste(as.character(rpt$narrative %||% ""), collapse = " ")
  note <- paste(as.character(rpt$apa_note %||% ""), collapse = " ")
  caption <- paste(as.character(rpt$apa_caption %||% ""), collapse = " ")
  forbidden_hits <- .mfrmr_dif_apa_forbidden_hits(
    paste(narrative, note, caption, collapse = " ")
  )

  checks <- list(
    .mfrmr_dif_apa_check_row(
      case, "report_class",
      inherits(rpt, "mfrm_dif_report"),
      paste(class(rpt), collapse = "/")
    ),
    .mfrmr_dif_apa_check_row(
      case, "narrative_nonempty",
      nzchar(trimws(narrative)),
      paste0("chars=", nchar(narrative))
    ),
    .mfrmr_dif_apa_check_row(
      case, "apa_table_nonempty",
      is.data.frame(rpt_table) && nrow(rpt_table) > 0L,
      paste0("rows=", nrow(rpt_table), "; cols=", ncol(rpt_table))
    ),
    .mfrmr_dif_apa_check_row(
      case, "adapter_table_row_alignment",
      nrow(adapter_table) == nrow(rpt_table),
      paste0("apa_table=", nrow(adapter_table), "; report=", nrow(rpt_table))
    ),
    .mfrmr_dif_apa_check_row(
      case, "note_and_caption_nonempty",
      nzchar(trimws(note)) && nzchar(trimws(caption)),
      paste0("note_chars=", nchar(note), "; caption_chars=", nchar(caption))
    ),
    .mfrmr_dif_apa_check_row(
      case, "note_keeps_screening_boundary",
      grepl("screening", note, ignore.case = TRUE) &&
        grepl("measurement bias", note, ignore.case = TRUE),
      note
    ),
    .mfrmr_dif_apa_check_row(
      case, "no_positive_overclaim",
      length(forbidden_hits) == 0L,
      if (length(forbidden_hits) == 0L) "none" else paste(forbidden_hits, collapse = "; ")
    )
  )
  if (length(required_patterns) > 0L) {
    checks <- c(checks, lapply(required_patterns, function(pattern) {
      .mfrmr_dif_apa_check_row(
        case,
        paste0("required_text:", pattern),
        grepl(tolower(pattern), tolower(narrative), fixed = TRUE) ||
          grepl(tolower(pattern), tolower(note), fixed = TRUE),
        pattern
      )
    }))
  }
  if (length(table_required) > 0L) {
    checks <- c(checks, list(.mfrmr_dif_apa_check_row(
      case,
      "required_table_columns",
      all(table_required %in% names(rpt_table)),
      paste(setdiff(table_required, names(rpt_table)), collapse = "; ")
    )))
  }

  list(
    report = rpt,
    table = tbl,
    case_summary = data.frame(
      Case = case,
      ReportClass = class(rpt)[1],
      Rows = nrow(rpt_table),
      Columns = ncol(rpt_table),
      Section = as.character(rpt$apa_section %||% ""),
      Caption = caption,
      NoteChars = nchar(note),
      NarrativeChars = nchar(narrative),
      stringsAsFactors = FALSE
    ),
    checks = do.call(rbind, checks)
  )
}

.mfrmr_dif_apa_add_route_check <- function(review, check, passed, detail = "") {
  review$checks <- rbind(
    review$checks,
    .mfrmr_dif_apa_check_row(review$case_summary$Case[1], check, passed, detail)
  )
  review
}

mfrmr_review_dif_apa_reporting <- function(include_refit = TRUE,
                                           include_gpcm = TRUE) {
  fit_mfrm <- .mfrmr_dif_apa_get_function("fit_mfrm")
  diagnose_mfrm <- .mfrmr_dif_apa_get_function("diagnose_mfrm")
  analyze_dff <- .mfrmr_dif_apa_get_function("analyze_dff")
  analyze_dif_mh <- .mfrmr_dif_apa_get_function("analyze_dif_mh")
  analyze_dff_moderation <- .mfrmr_dif_apa_get_function("analyze_dff_moderation")
  dif_interaction_table <- .mfrmr_dif_apa_get_function("dif_interaction_table")
  build_apa_outputs <- .mfrmr_dif_apa_get_function("build_apa_outputs")

  dat <- .mfrmr_dif_apa_fixture_data()
  fit <- fit_mfrm(
    dat,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "JML"
  )
  diag <- diagnose_mfrm(fit, residual_pca = "none")

  cases <- list()

  dff_two <- analyze_dff(
    fit, diag, facet = "Criterion", group = "Group2",
    data = dat, method = "residual", min_obs = 2
  )
  cases$categorical_two_level <- .mfrmr_dif_apa_case_review(
    "categorical_two_level",
    dff_two,
    required_patterns = c("DIF screening", "differential-functioning screening"),
    table_required = c(
      "Level", "Group1", "Group2", "Contrast", "p_value", "p_adjusted",
      "Classification", "ReportingUse", "PrimaryReportingEligible"
    )
  )
  apa_two <- build_apa_outputs(fit, diag, dif_results = dff_two)
  cases$categorical_two_level <- .mfrmr_dif_apa_add_route_check(
    cases$categorical_two_level,
    "build_apa_outputs_section_added",
    "results_differential_functioning" %in% apa_two$section_map$SectionId,
    paste(apa_two$section_map$SectionId, collapse = "; ")
  )
  cases$categorical_two_level <- .mfrmr_dif_apa_add_route_check(
    cases$categorical_two_level,
    "build_apa_outputs_note_added",
    grepl("Differential-functioning note", apa_two$table_figure_notes,
          fixed = TRUE),
    apa_two$table_figure_notes
  )

  dff_three <- analyze_dff(
    fit, diag, facet = "Criterion", group = "Group3",
    data = dat, method = "residual", min_obs = 2
  )
  cases$categorical_three_level <- .mfrmr_dif_apa_case_review(
    "categorical_three_level",
    dff_three,
    required_patterns = c("DIF screening", "contrast(s)"),
    table_required = c("Level", "Group1", "Group2", "Classification")
  )
  group_pairs <- unique(paste(dff_three$dif_table$Group1,
                              dff_three$dif_table$Group2, sep = " vs "))
  cases$categorical_three_level <- .mfrmr_dif_apa_add_route_check(
    cases$categorical_three_level,
    "multi_level_group_pairs_present",
    length(group_pairs) >= 3L,
    paste(group_pairs, collapse = "; ")
  )

  mod <- analyze_dff_moderation(
    fit,
    facet = "Criterion",
    covariate = "AgeLike",
    data = dat,
    min_obs = 2
  )
  cases$continuous_covariate <- .mfrmr_dif_apa_case_review(
    "continuous_covariate",
    mod,
    required_patterns = c("continuous-covariate", "not as a categorical MH"),
    table_required = c("Level", "Slope", "z", "p_value", "p_adjusted",
                       "Classification")
  )

  mh <- analyze_dif_mh(
    .mfrmr_dif_apa_mh_fixture(),
    person = "Person",
    item = "Item",
    score = "Score",
    group = "Group",
    reference = "Reference",
    focal = "Focal"
  )
  cases$observed_score_mh <- .mfrmr_dif_apa_case_review(
    "observed_score_mh",
    mh,
    required_patterns = c("observed-score Mantel-Haenszel DIF",
                          "not as fitted-MFRM"),
    table_required = c("Item", "AlphaMH", "MHDDelta", "MHChiSq",
                       "p_value", "p_adjusted", "MFRMFitUsed")
  )
  cases$observed_score_mh <- .mfrmr_dif_apa_add_route_check(
    cases$observed_score_mh,
    "mh_not_fitted_mfrm",
    all(!as.logical(cases$observed_score_mh$report$apa_table$MFRMFitUsed)),
    paste(unique(cases$observed_score_mh$report$apa_table$MFRMFitUsed),
          collapse = "; ")
  )

  inter <- dif_interaction_table(
    fit, diag, facet = "Criterion", group = "Group2",
    data = dat, min_obs = 2
  )
  cases$interaction_screen <- .mfrmr_dif_apa_case_review(
    "interaction_screen",
    inter,
    required_patterns = c("Cell-level differential-functioning",
                          "cell-level residual screening"),
    table_required = c("Level", "GroupValue", "ObsExpAvg", "t")
  )

  if (isTRUE(include_refit)) {
    refit <- suppressWarnings(suppressMessages(analyze_dff(
      fit, diag, facet = "Criterion", group = "Group2",
      data = dat, method = "refit", min_obs = 2
    )))
    cases$refit_branch <- .mfrmr_dif_apa_case_review(
      "refit_branch",
      refit,
      required_patterns = c("refit route", "classification"),
      table_required = c("Level", "Group1", "Group2", "Contrast",
                         "ETS", "ScaleLinkStatus", "ClassificationSystem")
    )
    cases$refit_branch <- .mfrmr_dif_apa_add_route_check(
      cases$refit_branch,
      "refit_columns_expose_ets_boundary",
      all(c("ETS", "ScaleLinkStatus", "PrimaryReportingEligible") %in%
            names(refit$dif_table)),
      paste(names(refit$dif_table), collapse = "; ")
    )
  }

  if (isTRUE(include_gpcm)) {
    gdat <- .mfrmr_dif_apa_gpcm_data()
    gfit <- suppressWarnings(suppressMessages(fit_mfrm(
      gdat,
      person = "Person",
      facets = c("Rater", "Task", "Criterion"),
      score = "Score",
      model = "GPCM",
      step_facet = "Criterion",
      method = "JML",
      maxit = 30
    )))
    gdiag <- diagnose_mfrm(gfit, residual_pca = "none")
    gdff <- analyze_dff(
      gfit, gdiag, facet = "Criterion", group = "Group2",
      data = gdat, method = "residual", min_obs = 2
    )
    cases$bounded_gpcm <- .mfrmr_dif_apa_case_review(
      "bounded_gpcm",
      gdff,
      required_patterns = c("DIF screening", "Bounded GPCM note"),
      table_required = c("Level", "Group1", "Group2", "Classification")
    )
    cases$bounded_gpcm <- .mfrmr_dif_apa_add_route_check(
      cases$bounded_gpcm,
      "gpcm_boundary_visible",
      is.data.frame(cases$bounded_gpcm$report$gpcm_boundary) &&
        nrow(cases$bounded_gpcm$report$gpcm_boundary) > 0L &&
        grepl("Bounded GPCM note", cases$bounded_gpcm$report$apa_note,
              fixed = TRUE),
      paste0(
        "gpcm_boundary_rows=",
        nrow(cases$bounded_gpcm$report$gpcm_boundary),
        "; note=",
        cases$bounded_gpcm$report$apa_note
      )
    )
  }

  case_table <- do.call(rbind, lapply(cases, `[[`, "case_summary"))
  checks <- do.call(rbind, lapply(cases, `[[`, "checks"))
  status <- if (all(checks$Passed)) "ok" else "concern"
  structure(
    list(
      status = status,
      include_refit = isTRUE(include_refit),
      include_gpcm = isTRUE(include_gpcm),
      case_table = case_table,
      checks = checks
    ),
    class = "mfrmr_dif_apa_reporting_review"
  )
}

print.mfrmr_dif_apa_reporting_review <- function(x, ...) {
  cat("mfrmr DIF/DFF APA reporting review\n")
  cat("Status:", x$status, "\n")
  cat("Refit case:", x$include_refit, " | GPCM case:", x$include_gpcm, "\n\n")
  cat("Cases:\n")
  print(x$case_table, row.names = FALSE)
  failed <- x$checks[!x$checks$Passed, , drop = FALSE]
  if (nrow(failed) > 0L) {
    cat("\nFailed checks:\n")
    print(failed, row.names = FALSE)
  } else {
    cat("\nAll checks passed.\n")
  }
  invisible(x)
}
