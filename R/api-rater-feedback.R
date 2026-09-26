# A distributed sheet is a whitelist projection, never a wrapper around a fit.
mfrm_rater_feedback <- function(x, facet, rater, audience, label, max_cases, interval) {
  scalar_text <- function(value, name) {
    if (length(value) != 1L || is.na(value) || !is.character(value) || !nzchar(value)) {
      stop(paste0("`", name, "` must be one nonempty string."), call. = FALSE)
    }
    unname(as.character(value))
  }
  facet <- scalar_text(facet, "facet")
  rater <- scalar_text(rater, "rater")
  label <- if (is.null(label)) "Selected rater" else scalar_text(label, "label")
  audience <- match.arg(audience, c("rater", "researcher"))
  if (length(max_cases) != 1L || !is.numeric(max_cases) || is.na(max_cases) ||
      !is.finite(max_cases) || max_cases < 0 || max_cases != floor(max_cases)) {
    stop("`max_cases` must be a nonnegative whole number; use 0 to omit cases.", call. = FALSE)
  }
  fit <- x[["fit"]]
  if (!inherits(fit, "mfrm_fit") || inherits(fit, "mfrm_imported_fit") ||
      !isTRUE(fit$config$model %in% c("RSM", "PCM")) ||
      !isTRUE(fit$config$method %in% c("MML", "JML")) ||
      length(fit$config$interaction_specs) || length(fit$interactions$specs)) {
    stop("Rater sheets require a native additive RSM/PCM fit. GPCM, interaction, imported, testlet and random-rater models need their model-specific reports.", call. = FALSE)
  }
  if (!facet %in% fit$prep$facet_names) stop("`facet` must name a fitted non-Person facet.", call. = FALSE)
  coef <- fit$facets$others
  selected <- which(as.character(coef$Facet) == facet & as.character(coef$Level) == rater)
  if (length(selected) != 1L) stop("`rater` must select exactly one level of `facet`.", call. = FALSE)
  sign <- as.numeric(fit$config$facet_signs[facet])
  if (length(sign) != 1L || is.na(sign) || !sign %in% c(-1, 1)) {
    stop("The selected facet lacks a supported effect direction.", call. = FALSE)
  }
  estimate <- as.numeric(coef$Estimate[selected])
  ready <- isTRUE(.mfrm_fit_plot_readiness(fit)$ready)
  d <- fit$prep$data
  take <- which(as.character(d[[facet]]) == rater)
  if (!length(take)) stop("The selected rater has no retained rating rows.", call. = FALSE)
  weight <- as.numeric(d$Weight[take])
  if (any(!is.finite(weight) | weight < 0)) stop("Invalid stored rating weights.", call. = FALSE)
  tables <- list(
    severity = data.frame(Severity = -sign * estimate, Reference = 0),
    exposure = data.frame(RatingRows = length(take), Persons = length(unique(d$Person[take])),
                          WeightSum = sum(weight)),
    uncertainty = data.frame(), fit = data.frame(), categories = data.frame(), cases = data.frame()
  )
  notes <- c(
    severity = "Positive severity means lower scores are expected, with other modeled effects held constant. Zero is the fitted model's reference, which need not be the average of the other raters. This model scale is different from the original score scale. Severity is not rater quality.",
    exposure = "Counts cover retained rating rows only. They do not measure completion of planned assignments. Weight sum describes estimation weights; the other counts are unweighted.",
    uncertainty = "No saved individual-rater interval was supplied. An interval is not calculated when creating this sheet.",
    fit = "Saved ordinary-model diagnostics were not supplied. Fit statistics are not calculated when creating this sheet.",
    categories = "Category use describes these ratings and the people assigned to this rater. Unequal use alone does not show a problem with the rubric or the rater.",
    cases = "Saved ordinary-model diagnostics were not supplied. Unexpected ratings are not calculated when creating this sheet."
  )
  # Select an individual coefficient by its contrast vector, never its row label.
  intervals <- mfrm_facet_results_inputs(fit, x[["facet_intervals"]])
  interval_row <- function(ci) {
    if (!identical(ci$settings$facet, facet)) return(integer(0))
    j <- ci$contrasts
    levels <- as.character(coef$Level[as.character(coef$Facet) == facet])
    if (!is.matrix(j) || is.null(colnames(j)) || anyDuplicated(colnames(j)) ||
        !setequal(colnames(j), levels) || anyNA(j) || nrow(j) != nrow(ci$table)) return(integer(0))
    wanted <- as.numeric(colnames(j) == rater)
    which(apply(j, 1L, function(row) all(row == wanted)))
  }
  candidates <- lapply(intervals, interval_row)
  eligible <- names(candidates)[lengths(candidates) > 0L]
  if (!is.null(interval)) {
    interval <- tolower(scalar_text(interval, "interval"))
    if (!interval %in% eligible) stop("`interval` must name a saved interval containing this individual rater coefficient.", call. = FALSE)
  } else if (length(eligible) > 1L) {
    stop("Several saved intervals contain this rater. Choose one with `interval`.", call. = FALSE)
  } else if (length(eligible) == 1L) interval <- eligible
  if (!is.null(interval)) {
    ci <- intervals[[interval]]
    row <- candidates[[interval]]
    if (length(row) != 1L) stop("The saved interval repeats this individual rater coefficient.", call. = FALSE)
    tab <- ci$table[row, , drop = FALSE]
    if (!isTRUE(all.equal(as.numeric(tab$Estimate), estimate, tolerance = 1e-8))) {
      stop("The saved individual-rater estimate does not match the fit.", call. = FALSE)
    }
    if (!ci$settings$method %in% c("model", "sandwich")) stop("Unsupported saved interval method.", call. = FALSE)
    ends <- as.numeric(c(tab$Lower, tab$Upper))
    ends <- if (sign == 1) -rev(ends) else ends
    available <- identical(as.character(tab$Status), "available") && all(is.finite(ends))
    tables$uncertainty <- data.frame(Level = as.numeric(ci$settings$level),
      Lower = ends[1], Upper = ends[2], Method = as.character(ci$settings$method),
      Available = available)
    notes["uncertainty"] <- paste(
      if (available) "Saved approximate pointwise interval for this fixed rater's severity." else
        "The saved individual-rater interval is unavailable; do not interpret its endpoints as a usable interval.",
      "It conditions on the fitted facet levels and does not classify rater quality or guarantee coverage.",
      if (ci$settings$method == "sandwich") "The sandwich calculation assumes independent declared clusters and does not correct biased estimates." else
        "The model-based calculation relies on the fitted model's assumptions."
    )
  }
  score <- as.numeric(d$Score[take])
  map <- fit$prep$score_map
  mapped <- is.data.frame(map) && all(c("InternalScore", "OriginalScore") %in% names(map))
  same_scale <- mapped && isTRUE(all.equal(as.numeric(map$InternalScore), as.numeric(map$OriginalScore)))
  categories <- if (mapped) as.numeric(map$InternalScore) else sort(unique(score))
  counts <- vapply(categories, function(k) sum(score == k), numeric(1))
  sums <- vapply(categories, function(k) sum(weight[score == k]), numeric(1))
  tables$categories <- data.frame(ModelScore = categories, Ratings = counts,
    Percent = 100 * counts / length(take), WeightSum = sums)
  if (mapped) tables$categories$OriginalScore <- as.numeric(map$OriginalScore)
  if (!same_scale) notes["categories"] <- paste(notes["categories"],
    "Model scores use the fitted category coding. Expected scores and residuals below stay on that coding; they are not converted to the original scale.")
  diagnostics <- x[["diagnostics"]]
  if (!is.null(diagnostics)) {
    mfrm_results_validate_diagnostics_identity(fit, diagnostics, helper = "mfrm_report(style = 'rater')")
    measures <- diagnostics$measures
    at <- which(as.character(measures$Facet) == facet & as.character(measures$Level) == rater)
    if (length(at) == 1L && all(c("Infit", "Outfit") %in% names(measures))) {
      tables$fit <- data.frame(Statistic = c("Infit", "Outfit"),
        Value = as.numeric(c(measures$Infit[at], measures$Outfit[at])))
      notes["fit"] <- "These saved statistics compare ratings with ordinary-model expectations. Values above 1 describe more variation than expected; values below 1 describe less. Infit emphasizes informative ratings, while Outfit is more sensitive to unexpected ratings. Neither statistic is a stand-alone verdict on the rater; no automatic warning cutoff is applied. Missing values remain unavailable."
    } else notes["fit"] <- "The saved diagnostics contain no unique Infit/Outfit row for this rater."
    obs <- diagnostics$obs
    fields <- c("Observed", "Expected", "Residual", "StdResidual")
    if (all(c(facet, fields) %in% names(obs))) {
      rows <- which(as.character(obs[[facet]]) == rater & is.finite(obs$StdResidual))
      rows <- utils::head(rows[order(abs(obs$StdResidual[rows]), decreasing = TRUE)], max_cases)
      tables$cases <- data.frame(Case = seq_along(rows),
        Observed = as.numeric(obs$Observed[rows]), Expected = as.numeric(obs$Expected[rows]),
        Residual = as.numeric(obs$Residual[rows]), StandardizedResidual = as.numeric(obs$StdResidual[rows]))
      notes["cases"] <- if (length(rows)) paste(
        "Selected by largest absolute standardized residual, not by a warning threshold.",
        "Case numbers are local to this sheet and are not source row numbers.",
        "Positive residuals mean higher scores than expected. Review context before drawing conclusions."
      ) else "No finite saved standardized residuals are available for the requested case display."
    } else notes["cases"] <- "The saved diagnostics lack the observation fields needed for this section."
  }
  if (max_cases == 0) {
    tables$cases <- data.frame()
    notes["cases"] <- "Individual rating cases were omitted by request."
  }
  technical <- if (audience == "researcher") paste(
    fit$config$model, "model;", fit$config$method,
    "estimation. Severity is minus the facet sign times its fitted coefficient (logits).",
    "Fit and case summaries use saved plug-in expectations, not marginal or posterior predictive extended-model diagnostics.",
    "Reported intervals, when supplied, are fixed-facet pointwise approximations; fit statistics do not estimate diagnostic accuracy."
  ) else "Use this sheet to discuss scoring patterns with the assessment team. Differences may reflect the ratings assigned as well as the model's assumptions."
  if (audience == "rater") {
    notes["severity"] <- paste(
      "Positive values indicate a tendency toward lower scores; negative values indicate higher scores, after accounting for the other modeled effects.",
      "Zero is the model's reference, not necessarily the other raters' average. This model scale differs from the rubric's scores. Severity is not rater quality.")
    if (nrow(tables$uncertainty) && isTRUE(tables$uncertainty$Available)) {
      notes["uncertainty"] <- paste(
        "This approximate interval describes uncertainty in this rater's scoring tendency under the analysis assumptions.",
        "It is not a guarantee of accuracy or a judgement of scoring quality.",
        if (tables$uncertainty$Method == "sandwich") "The sandwich method assumes independent groups and cannot correct biased estimates." else
          "The model-based calculation depends on the model's assumptions.")
    }
    if (nrow(tables$fit)) notes["fit"] <- paste(
      "Values above 1 describe more variation than the model expects; values below 1 describe less.",
      "Infit gives more weight to ratings that help distinguish performance levels. Outfit is more influenced by unusual ratings.",
      "Neither is a verdict on the rater. No automatic warning cutoff is applied; missing values remain unavailable.")
    if (nrow(tables$cases)) notes["cases"] <- paste(
      "These are the largest departures from expected scores, taking expected variation into account.",
      "They are discussion examples, not automatically scoring errors. Positive residuals mean higher scores than expected.",
      "Case numbers refer only to this list, not the original data rows.")
  }
  # No source object, names, row names, attributes or free-form source notes cross this boundary.
  out <- list(title = "Rater feedback", label = label, audience = audience,
    review = if (ready) "Review the assessment context before sharing or acting on this sheet." else
      "The source fit needs review. Treat these values as provisional and discuss them with the analyst before acting.",
    guidance = technical, notes = notes, tables = tables)
  class(out) <- "mfrm_rater_feedback"
  out$markdown <- mfrm_rater_feedback_render(out, html = FALSE)
  out
}

mfrm_rater_feedback_render <- function(x, html = TRUE) {
  headings <- c(severity = "Scoring tendency", exposure = "Ratings included",
    uncertainty = "Uncertainty in scoring tendency", fit = "Consistency with the model",
    categories = "Category use", cases = "Ratings to discuss")
  display <- lapply(x$tables, function(tab) {
    tab[] <- lapply(tab, function(col) {
      if (is.numeric(col)) ifelse(is.na(col), "Not available", format(round(col, 3), trim = TRUE)) else col
    })
    tab
  })
  names(display$severity) <- c("Severity", "Model reference")
  names(display$exposure) <- c("Rating rows", "People rated", "Weight total")
  if (nrow(display$uncertainty)) {
    display$uncertainty$Level <- paste0(100 * x$tables$uncertainty$Level, "%")
    display$uncertainty$Method <- ifelse(display$uncertainty$Method == "model", "Model-based", "Sandwich")
    display$uncertainty$Available <- ifelse(display$uncertainty$Available, "Available", "Unavailable")
    names(display$uncertainty) <- c("Confidence", "Lower", "Upper", "Calculation", "Status")
  }
  names(display$categories) <- c("Model score", "Ratings", "Percent", "Weight total",
    if ("OriginalScore" %in% names(display$categories)) "Original score")
  if (nrow(display$cases)) names(display$cases) <- c("Case", "Observed", "Expected", "Residual", "Standardized residual")
  if (!html) return(paste(c(paste0("# ", x$title), html_escape(x$label), x$review, x$guidance,
    unlist(lapply(names(headings), function(key) c(paste0("## ", headings[key]),
      x$notes[key], if (nrow(display[[key]])) mfrm_report_markdown_table(display[[key]]))))), collapse = "\n\n"))
  sections <- vapply(names(headings), function(key) {
    table <- if (nrow(display[[key]])) sub("<table>", paste0('<table aria-label="', headings[key], '">'),
      gsub("<th>", '<th scope="col">', dataframe_to_html_table(display[[key]]), fixed = TRUE), fixed = TRUE) else ""
    bars <- if (key == "categories") paste0('<div class="bars" aria-hidden="true">',
      paste0('<div class="bar-row"><span>', html_escape(display$categories[["Model score"]]),
        '</span><span class="track"><span style="width:',
        format(x$tables$categories$Percent, scientific = FALSE, trim = TRUE),
        '%"></span></span></div>', collapse = ""), '</div>') else ""
    paste0('<section><h2>', headings[key], '</h2><p>', html_escape(x$notes[key]),
      '</p>', bars, '<div class="table-scroll" tabindex="0" role="region" aria-label="', headings[key], '">', table, '</div></section>')
  }, character(1))
  paste0('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1"><title>Rater feedback</title>',
    '<style>body{font:16px/1.5 system-ui,sans-serif;color:#192d3c;background:#f2f5f7;margin:0}',
    'main{max-width:920px;margin:auto;padding:28px}h1{margin:0;font-size:2rem}h2{font-size:1.1rem;margin:0 0 8px}',
    '.label{font-size:1.2rem;overflow-wrap:anywhere}.review{border-left:4px solid #245d75;padding:10px 14px;background:#e6eef3}',
    '.grid{display:grid;grid-template-columns:1fr 1fr;gap:16px}section{min-width:0;background:white;border:1px solid #bdcbd3;border-radius:8px;padding:16px}',
    'p{margin:0 0 12px}.table-scroll{overflow-x:auto}table{border-collapse:collapse;width:100%;font-size:.86rem}',
    'th,td{padding:5px;text-align:left;border-bottom:1px solid #ccd5db}th{background:#edf2f5}',
    '.table-scroll:focus-visible{outline:3px solid #245d75;outline-offset:2px}',
    '.bars{margin:10px 0}.bar-row{display:flex;gap:10px;align-items:center}.bar-row>span:first-child{width:2em}',
    '.track{flex:1;background:#e5ebef;height:12px}.track>span{display:block;background:#245d75;height:12px}',
    '@media(max-width:700px){main{padding:14px}.grid{grid-template-columns:1fr}}',
    '@media print{@page{size:A4;margin:12mm}body{background:white;font-size:9pt;line-height:1.3}main{padding:0;max-width:none}',
    'h1{font-size:18pt}h2{font-size:11pt}.grid{display:grid;grid-template-columns:1fr 1fr;gap:8px}section{break-inside:avoid;margin:0;padding:8px}',
    'p{margin-bottom:6px}table{font-size:8pt}.bars{display:none}.table-scroll{overflow:visible}.table-scroll:focus-visible{outline:none}}',
    '</style></head><body><main><h1>Rater feedback</h1><p class="label">', html_escape(x$label),
    '</p><p class="review">', html_escape(x$review), '</p><p>', html_escape(x$guidance),
    '</p><div class="grid">', paste(sections, collapse = ""), '</div></main></body></html>')
}

#' @export
print.mfrm_rater_feedback <- function(x, ...) {
  cat(x$title, "\n", x$label, "\n", x$review, "\n", sep = "")
  print(x$tables$severity, row.names = FALSE)
  invisible(x)
}

mfrm_rater_feedback_html <- function(report) {
  html <- mfrm_rater_feedback_render(report)
  path <- tempfile("mfrmr_rater_", fileext = ".html")
  writeLines(enc2utf8(html), path, useBytes = TRUE)
  structure(list(path = normalizePath(path, winslash = "/", mustWork = TRUE),
    report = report, html = html), class = "mfrm_report_html")
}
