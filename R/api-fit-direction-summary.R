mfrm_misfit_direction_rate_row <- function(infit,
                                           outfit,
                                           lower = NULL,
                                           upper = NULL,
                                           inclusive = FALSE) {
  direction <- mfrm_classify_mnsq_direction(
    infit,
    outfit,
    lower = lower,
    upper = upper,
    inclusive = inclusive
  )
  classified <- sum(!is.na(direction))
  count <- function(value) sum(direction == value, na.rm = TRUE)
  rate <- function(n) if (classified > 0L) n / classified else NA_real_
  in_band_n <- count("in_band")
  underfit_n <- count("underfit")
  overfit_n <- count("overfit")
  mixed_n <- count("mixed")
  any_n <- underfit_n + overfit_n + mixed_n

  data.frame(
    MisfitClassified = classified,
    InBandN = in_band_n,
    UnderfitN = underfit_n,
    OverfitN = overfit_n,
    MixedMisfitN = mixed_n,
    MnSqMisfitN = any_n,
    InBandRate = rate(in_band_n),
    UnderfitRate = rate(underfit_n),
    OverfitRate = rate(overfit_n),
    MixedMisfitRate = rate(mixed_n),
    MnSqMisfitRate = rate(any_n),
    stringsAsFactors = FALSE
  )
}

mfrm_direction_summary_empty <- function() {
  out <- tibble::tibble(
    Scope = character(0),
    Facet = character(0),
    FitReference = character(0),
    DFMethod = character(0),
    ZSTDCap = numeric(0),
    PAdjustMethod = character(0),
    Alpha = numeric(0),
    Lower = numeric(0),
    Upper = numeric(0),
    Rows = integer(0),
    Classified = integer(0),
    InBandN = integer(0),
    UnderfitN = integer(0),
    OverfitN = integer(0),
    MixedN = integer(0),
    AnyMisfitN = integer(0),
    MnSqFlagN = integer(0),
    PFlagN = integer(0),
    AnyFlagN = integer(0),
    InBandRate = numeric(0),
    UnderfitRate = numeric(0),
    OverfitRate = numeric(0),
    MixedRate = numeric(0),
    AnyMisfitRate = numeric(0),
    MnSqFlagRate = numeric(0),
    PFlagRate = numeric(0),
    AnyFlagRate = numeric(0),
    MeanInfit = numeric(0),
    MeanOutfit = numeric(0)
  )
  class(out) <- c("mfrm_fit_direction_summary", class(out))
  out
}

mfrm_prepare_fit_p_table <- function(fit,
                                     diagnostics = NULL,
                                     scope = c("element", "person", "category"),
                                     p_adjust = "holm",
                                     alpha = 0.05,
                                     lower = NULL,
                                     upper = NULL,
                                     reference = c("mfrmr", "facets"),
                                     zstd_cap = c("auto", "none", "facets")) {
  if (is.data.frame(fit) && all(c("MisfitDirection", "Infit", "Outfit") %in% names(fit))) {
    return(as.data.frame(fit, stringsAsFactors = FALSE))
  }
  scope <- match.arg(scope)
  fit_p_table(
    fit = fit,
    diagnostics = diagnostics,
    scope = scope,
    p_adjust = p_adjust,
    alpha = alpha,
    lower = lower,
    upper = upper,
    reference = reference,
    zstd_cap = zstd_cap
  )
}

#' Summarize underfit and overfit directions from fit statistics
#'
#' Build a compact direction table from [fit_p_table()] output. The table
#' separates `underfit`, `overfit`, `mixed`, and `in_band` labels so researchers
#' can report whether misfit is driven by noisy/unpredictable responses
#' (MnSq above the upper band) or overly predictable responses (MnSq below the
#' lower band).
#'
#' @param fit Output from [fit_mfrm()] or a data frame returned by
#'   [fit_p_table()].
#' @param diagnostics Optional output from [diagnose_mfrm()]. Ignored when
#'   `fit` is already a fit-p table.
#' @param scope Fit-statistic scope passed to [fit_p_table()].
#' @param p_adjust Multiplicity adjustment passed to [fit_p_table()].
#' @param alpha Screening alpha used for adjusted p-value counts.
#' @param lower,upper Optional MnSq screening band. Defaults to
#'   [mfrm_misfit_thresholds()].
#' @param reference Fit-statistic reference passed to [fit_p_table()].
#' @param zstd_cap ZSTD cap policy passed to [fit_p_table()].
#'
#' @details
#' Direction labels are MnSq-band labels. ZSTD and adjusted p values are counted
#' separately through `PFlagN` and `PFlagRate`; they do not define the
#' underfit/overfit direction. This keeps the substantive interpretation
#' stable when users compare `reference = "mfrmr"` with `reference = "facets"`.
#'
#' @return A data frame of class `mfrm_fit_direction_summary` with one row per
#'   `Scope` x `Facet` x reference combination. Count columns report the number
#'   of levels in each direction; rate columns use the number of classified
#'   levels as denominator. The original fit-p table is stored in the `detail`
#'   attribute.
#' @seealso [fit_p_table()], [plot_fit_direction_summary()],
#'   [summarize_simulation_misfit()]
#' @examples
#' \donttest{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 25)
#' diag <- diagnose_mfrm(fit, residual_pca = "none")
#' dir_tab <- fit_direction_summary(fit, diagnostics = diag)
#' dir_tab[, c("Facet", "UnderfitRate", "OverfitRate", "AnyMisfitRate")]
#' }
#' @export
fit_direction_summary <- function(fit,
                                  diagnostics = NULL,
                                  scope = c("element", "person", "category"),
                                  p_adjust = "holm",
                                  alpha = 0.05,
                                  lower = NULL,
                                  upper = NULL,
                                  reference = c("mfrmr", "facets"),
                                  zstd_cap = c("auto", "none", "facets")) {
  band <- mfrm_misfit_thresholds(lower = lower, upper = upper)
  lower <- as.numeric(band["lower"])
  upper <- as.numeric(band["upper"])
  tab <- mfrm_prepare_fit_p_table(
    fit = fit,
    diagnostics = diagnostics,
    scope = scope,
    p_adjust = p_adjust,
    alpha = alpha,
    lower = lower,
    upper = upper,
    reference = reference,
    zstd_cap = zstd_cap
  )
  if (!is.data.frame(tab) || nrow(tab) == 0L) {
    out <- mfrm_direction_summary_empty()
    attr(out, "detail") <- tab
    return(out)
  }

  for (nm in c("Scope", "Facet", "FitReference", "DFMethod", "PAdjustMethod")) {
    if (!nm %in% names(tab)) tab[[nm]] <- NA_character_
    tab[[nm]] <- as.character(tab[[nm]])
  }
  for (nm in c("ZSTDCap", "Alpha", "Infit", "Outfit")) {
    if (!nm %in% names(tab)) tab[[nm]] <- NA_real_
    tab[[nm]] <- suppressWarnings(as.numeric(tab[[nm]]))
  }
  for (nm in c("MnSqFlag", "PFlag")) {
    if (!nm %in% names(tab)) tab[[nm]] <- FALSE
    tab[[nm]] <- tab[[nm]] %in% TRUE
  }
  if (!"MisfitDirection" %in% names(tab)) {
    tab$MisfitDirection <- mfrm_classify_mnsq_direction(
      tab$Infit,
      tab$Outfit,
      lower = lower,
      upper = upper
    )
  }
  tab$MisfitDirection <- as.character(tab$MisfitDirection)
  if (all(!is.finite(tab$Alpha))) tab$Alpha <- alpha

  grouped <- tab |>
    dplyr::group_by(
      .data$Scope,
      .data$Facet,
      .data$FitReference,
      .data$DFMethod,
      .data$ZSTDCap,
      .data$PAdjustMethod,
      .data$Alpha
    ) |>
    dplyr::summarize(
      Lower = lower,
      Upper = upper,
      Rows = dplyr::n(),
      Classified = sum(!is.na(.data$MisfitDirection)),
      InBandN = sum(.data$MisfitDirection == "in_band", na.rm = TRUE),
      UnderfitN = sum(.data$MisfitDirection == "underfit", na.rm = TRUE),
      OverfitN = sum(.data$MisfitDirection == "overfit", na.rm = TRUE),
      MixedN = sum(.data$MisfitDirection == "mixed", na.rm = TRUE),
      MnSqFlagN = sum(.data$MnSqFlag, na.rm = TRUE),
      PFlagN = sum(.data$PFlag, na.rm = TRUE),
      AnyFlagN = sum(.data$MnSqFlag | .data$PFlag, na.rm = TRUE),
      MeanInfit = mean(.data$Infit, na.rm = TRUE),
      MeanOutfit = mean(.data$Outfit, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      AnyMisfitN = .data$UnderfitN + .data$OverfitN + .data$MixedN,
      InBandRate = dplyr::if_else(.data$Classified > 0, .data$InBandN / .data$Classified, NA_real_),
      UnderfitRate = dplyr::if_else(.data$Classified > 0, .data$UnderfitN / .data$Classified, NA_real_),
      OverfitRate = dplyr::if_else(.data$Classified > 0, .data$OverfitN / .data$Classified, NA_real_),
      MixedRate = dplyr::if_else(.data$Classified > 0, .data$MixedN / .data$Classified, NA_real_),
      AnyMisfitRate = dplyr::if_else(.data$Classified > 0, .data$AnyMisfitN / .data$Classified, NA_real_),
      MnSqFlagRate = dplyr::if_else(.data$Rows > 0, .data$MnSqFlagN / .data$Rows, NA_real_),
      PFlagRate = dplyr::if_else(.data$Rows > 0, .data$PFlagN / .data$Rows, NA_real_),
      AnyFlagRate = dplyr::if_else(.data$Rows > 0, .data$AnyFlagN / .data$Rows, NA_real_)
    ) |>
    dplyr::select(dplyr::all_of(c(
      "Scope", "Facet", "FitReference", "DFMethod", "ZSTDCap",
      "PAdjustMethod", "Alpha", "Lower", "Upper", "Rows", "Classified",
      "InBandN", "UnderfitN", "OverfitN", "MixedN", "AnyMisfitN",
      "MnSqFlagN", "PFlagN", "AnyFlagN", "InBandRate", "UnderfitRate",
      "OverfitRate", "MixedRate", "AnyMisfitRate", "MnSqFlagRate",
      "PFlagRate", "AnyFlagRate", "MeanInfit", "MeanOutfit"
    ))) |>
    dplyr::arrange(.data$Scope, .data$Facet, .data$FitReference)

  class(grouped) <- c("mfrm_fit_direction_summary", class(grouped))
  attr(grouped, "detail") <- tab
  grouped
}

mfrm_fit_direction_long <- function(summary_tbl,
                                    directions = c("underfit", "overfit", "mixed", "in_band"),
                                    value = c("rate", "count")) {
  value <- match.arg(value)
  directions <- unique(as.character(directions))
  directions <- directions[directions %in% c("underfit", "overfit", "mixed", "in_band", "any")]
  if (length(directions) == 0L) {
    stop("`directions` must include at least one of underfit, overfit, mixed, in_band, or any.",
         call. = FALSE)
  }
  rate_cols <- c(
    underfit = "UnderfitRate",
    overfit = "OverfitRate",
    mixed = "MixedRate",
    in_band = "InBandRate",
    any = "AnyMisfitRate"
  )
  count_cols <- c(
    underfit = "UnderfitN",
    overfit = "OverfitN",
    mixed = "MixedN",
    in_band = "InBandN",
    any = "AnyMisfitN"
  )
  col_map <- if (identical(value, "rate")) rate_cols else count_cols
  pieces <- lapply(directions, function(direction) {
    col <- unname(col_map[[direction]])
    tbl <- summary_tbl
    tbl$Direction <- direction
    tbl$Value <- if (col %in% names(tbl)) suppressWarnings(as.numeric(tbl[[col]])) else NA_real_
    tbl
  })
  dplyr::bind_rows(pieces)
}

#' Plot underfit and overfit direction rates
#'
#' Visualize the direction table returned by [fit_direction_summary()]. The
#' default plot is a stacked base-R bar chart; with `draw = FALSE`, the function
#' returns a stable `mfrm_plot_data` payload for custom graphics.
#'
#' @param x Output from [fit_direction_summary()], [fit_p_table()], or
#'   [fit_mfrm()].
#' @param diagnostics Optional diagnostics passed through when `x` is a fit.
#' @param facet Optional facet filter.
#' @param directions Direction labels to include.
#' @param value Plot rates or counts.
#' @param draw If `TRUE`, draw with base graphics; otherwise return plotting
#'   data invisibly.
#' @param ... Passed to [fit_direction_summary()] when `x` is a fit or
#'   fit-p table.
#'
#' @return An `mfrm_plot_data` object with `summary` and long-form `data`
#'   slots.
#' @seealso [fit_direction_summary()], [fit_p_table()],
#'   [plot_simulation_misfit_rates()]
#' @examples
#' \donttest{
#' toy <- load_mfrmr_data("example_core")
#' fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
#'                 method = "JML", maxit = 25)
#' diag <- diagnose_mfrm(fit, residual_pca = "none")
#' p <- plot_fit_direction_summary(fit, diagnostics = diag, draw = FALSE)
#' p$data$data
#' }
#' @export
plot_fit_direction_summary <- function(x,
                                       diagnostics = NULL,
                                       facet = NULL,
                                       directions = c("underfit", "overfit", "mixed", "in_band"),
                                       value = c("rate", "count"),
                                       draw = TRUE,
                                       ...) {
  value <- match.arg(value)
  summary_tbl <- if (inherits(x, "mfrm_fit_direction_summary")) {
    x
  } else {
    fit_direction_summary(x, diagnostics = diagnostics, ...)
  }
  summary_tbl <- tibble::as_tibble(summary_tbl)
  if (!is.null(facet)) {
    facet <- as.character(facet[1])
    summary_tbl <- summary_tbl[as.character(summary_tbl$Facet) == facet, , drop = FALSE]
  }
  if (nrow(summary_tbl) == 0L) {
    stop("No direction-summary rows are available for plotting.", call. = FALSE)
  }
  long_tbl <- mfrm_fit_direction_long(summary_tbl, directions = directions, value = value)
  long_tbl$Panel <- paste(long_tbl$Scope, long_tbl$Facet, sep = ": ")

  if (isTRUE(draw)) {
    panels <- unique(as.character(long_tbl$Panel))
    dirs <- unique(as.character(long_tbl$Direction))
    mat <- matrix(0, nrow = length(dirs), ncol = length(panels),
                  dimnames = list(dirs, panels))
    for (i in seq_len(nrow(long_tbl))) {
      mat[as.character(long_tbl$Direction[i]), as.character(long_tbl$Panel[i])] <- long_tbl$Value[i]
    }
    pal <- c(
      underfit = "#C43C39",
      overfit = "#2C7BB6",
      mixed = "#8E5EA2",
      in_band = "#74A57F",
      any = "#6B7280"
    )
    graphics::barplot(
      mat,
      beside = FALSE,
      col = unname(pal[rownames(mat)]),
      las = 2,
      ylim = if (identical(value, "rate")) c(0, 1) else NULL,
      ylab = if (identical(value, "rate")) "Proportion of classified levels" else "Number of levels",
      main = "Misfit direction summary"
    )
    graphics::legend("topright", legend = rownames(mat), fill = unname(pal[rownames(mat)]), bty = "n")
  }

  out <- new_mfrm_plot_data(
    "fit_direction_summary",
    list(
      data = long_tbl,
      summary = summary_tbl,
      directions = unique(as.character(long_tbl$Direction)),
      value = value,
      title = "Misfit direction summary"
    )
  )
  invisible(out)
}
