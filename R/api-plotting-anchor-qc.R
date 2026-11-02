# ============================================================================
# Anchor Drift & Equating Chain Plots
# ============================================================================

# --- Internal plot helpers (not exported) ------------------------------------

.plot_drift_dot <- function(dt, config, draw = TRUE, style = resolve_plot_preset("standard"), ...) {
  out <- new_mfrm_plot_data(
    "anchor_drift",
    list(
      plot = "drift",
      table = dt,
      title = "Anchor drift",
      subtitle = paste0("Review threshold: |drift| > ", format(config$drift_threshold)),
      legend = new_plot_legend(
        label = c("Within review band", "Flagged drift"),
        role = c("status", "status"),
        aesthetic = c("point", "point"),
        value = c(style$accent_primary, style$warn)
      ),
      reference_lines = new_reference_lines(
        axis = c("v", "v", "v"),
        value = c(-config$drift_threshold, 0, config$drift_threshold),
        label = c("Drift review threshold", "Centered drift reference", "Drift review threshold"),
        linetype = c("dotted", "dashed", "dotted"),
        role = c("threshold", "reference", "threshold")
      ),
      preset = style$name
    )
  )
  .mfrm_finalize_ggplot(out, draw = draw)
}

.plot_drift_heatmap <- function(dt, config, draw = TRUE, style = resolve_plot_preset("standard"), ...) {
  dt_wide <- dt |>
    dplyr::mutate(Element = paste0(.data$Facet, ":", .data$Level)) |>
    dplyr::select("Element", "Wave", "Drift")

  mat <- tryCatch({
    tidyr::pivot_wider(dt_wide, names_from = "Wave",
                        values_from = "Drift") |>
      tibble::column_to_rownames("Element") |>
      as.matrix()
  }, error = function(e) NULL)

  if (is.null(mat) || nrow(mat) == 0) {
    if (draw) message("Insufficient data for heatmap.")
    mat <- matrix(numeric(0), nrow = 0L, ncol = 0L)
  }

  out <- new_mfrm_plot_data(
    "anchor_drift",
    list(
      plot = "heatmap",
      table = dt,
      matrix = mat,
      title = "Anchor drift heatmap",
      subtitle = paste0("Wave-by-element drift; review threshold = ", format(config$drift_threshold)),
      legend = new_plot_legend(
        label = c("Negative drift", "Positive drift"),
        role = c("drift", "drift"),
        aesthetic = c("heatmap", "heatmap"),
        value = c(style$accent_primary, style$warn)
      ),
      reference_lines = new_reference_lines(),
      preset = style$name
    )
  )

  .mfrm_finalize_ggplot(out, draw = draw)
}

.equating_graph_data <- function(x) {
  links <- as.data.frame(x$links %||% data.frame(), stringsAsFactors = FALSE)
  detail <- as.data.frame(x$element_detail %||% data.frame(), stringsAsFactors = FALSE)
  if (!all(c("From", "To") %in% names(links))) {
    if (all(c("Wave1", "Wave2") %in% names(links))) {
      links$From <- links$Wave1
      links$To <- links$Wave2
    } else if (nrow(links)) {
      stop("Graph view requires From/To columns in links.", call. = FALSE)
    }
  }
  waves <- as.character(x$config$waves %||% x$cumulative$Wave %||%
                          unique(c(links$From, links$To)))
  if (!length(waves) || anyNA(waves) || any(!nzchar(waves))) {
    stop("Graph view requires non-missing, non-empty wave labels.", call. = FALSE)
  }
  links$LinkID <- as.character(links$Link %||% seq_len(nrow(links)))
  if (anyNA(links$LinkID) || anyDuplicated(links$LinkID)) {
    stop("Graph view requires unique, non-missing link IDs.", call. = FALSE)
  }
  if (!all(c("FromID", "ToID") %in% names(links))) {
    # Older chains have ordered adjacent links. Never split display labels.
    adjacent <- nrow(links) == length(waves) - 1L &&
      identical(as.character(links$From), head(waves, -1L)) &&
      identical(as.character(links$To), tail(waves, -1L))
    if (adjacent) {
      links$FromID <- seq_len(nrow(links))
      links$ToID <- seq_len(nrow(links)) + 1L
    } else {
      if (nrow(links) && anyDuplicated(waves)) {
        stop("Ambiguous wave labels; rebuild the chain with explicit wave IDs.", call. = FALSE)
      }
      links$FromID <- match(links$From, waves)
      links$ToID <- match(links$To, waves)
    }
  }
  for (endpoint in c("From", "To")) {
    id <- links[[paste0(endpoint, "ID")]]
    if (!is.numeric(id) || anyNA(id) || any(id != as.integer(id)) ||
        any(id < 1L | id > length(waves)) ||
        !identical(as.character(links[[endpoint]]), waves[id])) {
      if (nrow(links)) stop("Invalid wave IDs or endpoint labels in links.", call. = FALSE)
    }
  }
  if (nrow(detail)) {
    if (!all(c("Facet", "Level") %in% names(detail))) {
      stop("Graph view requires Facet/Level columns in element_detail.", call. = FALSE)
    }
    if ("LinkID" %in% names(detail)) {
      index <- match(as.character(detail$LinkID), links$LinkID)
    } else {
      keys <- paste(links$From, links$To, sep = " -> ")
      if (!"Link" %in% names(detail) || anyDuplicated(keys)) {
        stop("Ambiguous or missing element link IDs; rebuild the chain.", call. = FALSE)
      }
      index <- match(as.character(detail$Link), keys)
    }
    if (anyNA(index)) stop("Element links do not match the links table.", call. = FALSE)
  } else {
    detail$Facet <- detail$Level <- character()
    index <- integer()
  }
  detail$LinkID <- links$LinkID[index]
  detail$Facet <- as.character(detail$Facet)
  detail$Level <- as.character(detail$Level)
  if (anyNA(detail[, c("Facet", "Level")]) ||
      anyDuplicated(detail[, c("LinkID", "Facet", "Level")])) {
    stop("Graph elements require non-missing identities and unique rows per link.", call. = FALSE)
  }
  for (flag in c("Retained", "Flag")) {
    if (is.null(detail[[flag]])) detail[[flag]] <- rep(NA, nrow(detail))
    if (!is.logical(detail[[flag]])) {
      stop(sprintf("`element_detail$%s` must be logical.", flag), call. = FALSE)
    }
  }
  detail$Status <- ifelse(is.na(detail$Retained), "candidate",
    ifelse(!detail$Retained, "excluded",
      ifelse(is.na(detail$Flag) | detail$Flag, "retained_review", "retained")))
  detail$Reason <- ifelse(detail$Status == "candidate", "Retention not recorded",
    ifelse(detail$Status == "excluded", "Excluded from the retained set",
      ifelse(detail$Status == "retained_review", "Retained; drift flagged or flag unavailable",
        "Retained; no residual drift flag")))
  anchors <- unique(detail[, c("Facet", "Level"), drop = FALSE])
  anchors$AnchorId <- sprintf("anchor_%d", seq_len(nrow(anchors)))
  detail <- dplyr::left_join(detail, anchors, by = c("Facet", "Level"))
  # A node represents one element in one reviewed link. Merging the same
  # element across links would create paths that bypass pair-specific screening.
  detail$NodeId <- sprintf("element_%d", seq_len(nrow(detail)))
  wave_nodes <- data.frame(
    NodeId = paste0("wave_", seq_along(waves)), Label = waves,
    Kind = "wave", WaveID = seq_along(waves), stringsAsFactors = FALSE
  )
  element_nodes <- data.frame(
    NodeId = detail$NodeId,
    Label = sprintf("%s: %s [L%s]", detail$Facet, detail$Level, detail$LinkID),
    Kind = rep("element", nrow(detail)),
    detail[, c("AnchorId", "LinkID", "Facet", "Level", "Status"), drop = FALSE],
    stringsAsFactors = FALSE
  )
  nodes <- as.data.frame(dplyr::bind_rows(wave_nodes, element_nodes))
  edges <- dplyr::bind_rows(lapply(c("From", "To"), function(endpoint) {
    data.frame(
      from = sprintf("wave_%d", links[[paste0(endpoint, "ID")]][index]),
      to = detail$NodeId, Wave = waves[links[[paste0(endpoint, "ID")]][index]],
      detail[, c("AnchorId", "LinkID", "Facet", "Level", "Retained", "Flag", "Status", "Reason"), drop = FALSE],
      stringsAsFactors = FALSE
    )
  }))
  retained <- !is.na(edges$Retained) & edges$Retained
  nodes$RetainedDegree <- tabulate(match(c(edges$from[retained], edges$to[retained]), nodes$NodeId), nrow(nodes))
  links$from <- sprintf("wave_%d", links$FromID)
  links$to <- sprintf("wave_%d", links$ToID)
  notes <- .mfrmr_table_.equating_graph_data_notes
  isolated <- wave_nodes$Label[nodes$RetainedDegree[seq_along(waves)] == 0L]
  if (length(isolated)) notes <- rbind(notes, data.frame(Type = "warning", Text = paste0(
    "No retained common-element connection for: ", paste(isolated, collapse = ", "), ".")))
  weak <- links$LinkSupportAdequate %in% FALSE
  if (any(weak)) notes <- rbind(notes, data.frame(Type = "warning", Text = paste0(
    "Thin or absent linking support recorded for link(s): ", paste(links$LinkID[weak], collapse = ", "),
    ". Inspect the link and common_by_facet tables; retention alone does not imply adequate support.")))
  list(data = list(nodes = nodes, edges = edges, links = links, elements = detail,
    n_waves = length(waves), n_anchors = nrow(anchors), n_element_nodes = nrow(detail)), notes = notes)
}

.equating_link_topology <- function(graph_data, removal = FALSE) {
  data <- graph_data$data
  nodes <- data$nodes[data$nodes$Kind == "wave", c("NodeId", "Label", "WaveID"), drop = FALSE]
  links <- data$links
  elements <- data$elements
  li <- match(elements$LinkID, links$LinkID)
  retained <- elements$Retained %in% TRUE
  links$RetainedElements <- tabulate(li[retained], nrow(links))
  links$UnknownRetention <- tabulate(li[is.na(elements$Retained)], nrow(links))
  links$ReviewElements <- tabulate(li[retained & (is.na(elements$Flag) | elements$Flag)], nrow(links))
  links$Connected <- links$RetainedElements > 0L
  support <- links$LinkSupportAdequate %||% rep(NA, nrow(links))
  links$Status <- ifelse(!links$Connected, "no_retained",
    ifelse(links$ReviewElements > 0L | is.na(support) | !support,
      "retained_review", "retained"))
  membership <- function(connected) {
    uf <- make_union_find(nodes$NodeId)
    for (i in which(connected)) uf$union(links$from[i], links$to[i])
    root <- vapply(nodes$NodeId, uf$find, character(1))
    match(root, unique(root))
  }
  baseline <- membership(links$Connected)
  nodes$Component <- baseline
  connected_pairs <- function(component) {
    size <- as.numeric(table(component))
    sum(size * (size - 1) / 2)
  }
  baseline_pairs <- connected_pairs(baseline)
  result <- list(nodes = nodes, links = links, elements = elements,
    summary = data.frame(Waves = nrow(nodes), RecordedLinks = nrow(links),
      RetainedLinks = sum(links$Connected), Components = length(unique(baseline)),
      ConnectedPairs = baseline_pairs, UnknownRetention = sum(links$UnknownRetention)))
  notes <- rbind(graph_data$notes, data.frame(Type = "definition", Text =
    "A wave-to-wave edge exists when at least one common element is recorded as Retained = TRUE. Flagged retained elements are included; unknown retention is not counted. Component labels describe only this recorded graph."))
  if (any(is.na(elements$Retained))) notes <- rbind(notes, data.frame(Type = "warning", Text =
    "Retention is missing for some elements. Connectivity uses known retained rows only; absence of a recorded connection is not evidence of a disconnected rating design."))
  if (!removal) return(list(data = result, notes = notes))

  audit <- unique(elements[, c("AnchorId", "Facet", "Level"), drop = FALSE])
  audit$RetainedOccurrences <- audit$UnknownOccurrences <- audit$LostLinks <- audit$NewlyDisconnectedPairs <- integer(nrow(audit))
  audit$ComponentsAfter <- rep(length(unique(baseline)), nrow(audit))
  component_rows <- lost_link_rows <- lost_pair_rows <- list()
  # ponytail: one deletion per element; large wave sets may need lazy pair export.
  for (i in seq_len(nrow(audit))) {
    removed <- retained & elements$AnchorId == audit$AnchorId[i]
    remaining <- links$RetainedElements - tabulate(li[removed], nrow(links))
    lost <- links$Connected & remaining == 0L
    after <- if (any(lost)) membership(remaining > 0L) else baseline
    audit$RetainedOccurrences[i] <- sum(removed)
    audit$UnknownOccurrences[i] <- sum(is.na(elements$Retained) & elements$AnchorId == audit$AnchorId[i])
    audit$LostLinks[i] <- sum(lost)
    audit$ComponentsAfter[i] <- length(unique(after))
    audit$NewlyDisconnectedPairs[i] <- baseline_pairs - connected_pairs(after)
    component_rows[[i]] <- data.frame(AnchorId = audit$AnchorId[i],
      WaveID = nodes$WaveID, Wave = nodes$Label, Before = baseline, After = after)
    lost_link_rows[[i]] <- data.frame(AnchorId = rep(audit$AnchorId[i], sum(lost)),
      links[lost, c("LinkID", "FromID", "ToID", "From", "To"), drop = FALSE])
    # Enumerate only newly separated pairs, keeping existing disconnections out.
    pairs <- lapply(seq_len(nrow(nodes)), function(a) {
      b <- which(seq_len(nrow(nodes)) > a & baseline == baseline[a] & after != after[a])
      data.frame(AnchorId = rep(audit$AnchorId[i], length(b)),
        FromID = rep(nodes$WaveID[a], length(b)), ToID = nodes$WaveID[b],
        From = rep(nodes$Label[a], length(b)), To = nodes$Label[b])
    })
    lost_pair_rows[[i]] <- dplyr::bind_rows(pairs)
  }
  result$removal <- audit
  result$components_after <- if (length(component_rows)) dplyr::bind_rows(component_rows) else
    data.frame(AnchorId = character(), WaveID = integer(), Wave = character(), Before = integer(), After = integer())
  result$lost_links <- if (length(lost_link_rows)) dplyr::bind_rows(lost_link_rows) else
    data.frame(AnchorId = character(), LinkID = character(), FromID = integer(), ToID = integer(), From = character(), To = character())
  result$lost_pairs <- if (length(lost_pair_rows)) dplyr::bind_rows(lost_pair_rows) else
    data.frame(AnchorId = character(), FromID = integer(), ToID = integer(), From = character(), To = character())
  notes <- rbind(notes, data.frame(Type = "interpretation", Text =
    "Each scenario removes one facet/level identity from all recorded comparisons, starting from the unchanged baseline. Screening and other retained flags are held fixed. Newly disconnected pairs were connected at baseline, including indirect paths. Zero means no new graph disconnection, not negligible statistical influence. No offsets, estimates or SEs are recomputed."))
  list(data = result, notes = notes)
}

.equating_offset_sensitivity <- function(x) {
  source <- .equating_graph_data(x)$data
  links <- source$links
  elements <- source$elements
  waves <- source$nodes[source$nodes$Kind == "wave", c("WaveID", "Label"), drop = FALSE]
  threshold <- x$config$drift_threshold
  guideline <- x$config$min_common_per_facet
  if (!identical(x$config$method, "screened_common_element_alignment") ||
      !is.numeric(threshold) || length(threshold) != 1L || is.na(threshold) || threshold < 0 ||
      !is.numeric(guideline) || length(guideline) != 1L || !is.finite(guideline) || guideline < 1 || guideline != floor(guideline)) {
    stop("Offset sensitivity requires the recorded screened-linking method, drift threshold and support guideline; rebuild the chain.", call. = FALSE)
  }
  if (nrow(waves) < 2L || nrow(links) != nrow(waves) - 1L ||
      !identical(as.integer(links$FromID), seq_len(nrow(links))) ||
      !identical(as.integer(links$ToID), seq_len(nrow(links)) + 1L)) {
    stop("Offset sensitivity requires an ordered adjacent chain.", call. = FALSE)
  }
  for (field in c("Est_From", "Est_To", "SE_From", "SE_To")) {
    if (!nrow(elements)) elements[[field]] <- numeric()
    if (!is.numeric(elements[[field]])) stop(
      "Offset sensitivity requires numeric Est_From/Est_To and SE_From/SE_To columns; rebuild the chain.", call. = FALSE)
  }
  if (!is.numeric(links$Offset)) stop("Offset sensitivity requires recorded numeric offsets.", call. = FALSE)
  by_link <- split(seq_len(nrow(elements)), factor(elements$LinkID, levels = links$LinkID))
  recalculate <- function(removed = NA_character_) {
    rows <- support <- detail <- vector("list", nrow(links))
    for (j in seq_len(nrow(links))) {
      original <- elements[by_link[[j]], , drop = FALSE]
      e <- original[is.na(removed) | original$AnchorId != removed, , drop = FALSE]
      diffs <- e$Est_To - e$Est_From
      info <- compute_equating_offset(diffs, e$SE_From, e$SE_To, threshold)
      s <- .summarise_link_support(e, info$retained, guideline)
      # Keep a baseline facet visible when deletion removes its last element.
      s <- dplyr::left_join(data.frame(Facet = unique(original$Facet)), s, by = "Facet")
      for (field in c("N_Common", "N_Retained")) s[[field]][is.na(s[[field]])] <- 0L
      s$GuidelineMinCommon <- rep(guideline, nrow(s))
      s$LinkSupportAdequate <- s$N_Retained >= guideline
      s$LinkID <- rep(links$LinkID[j], nrow(s))
      support[[j]] <- s
      status <- info$status
      rows[[j]] <- data.frame(LinkID = links$LinkID[j], FromID = links$FromID[j],
        ToID = links$ToID[j], From = links$From[j], To = links$To[j],
        N_Common = nrow(e), N_Retained = info$n_retained,
        N_Contributing = sum(info$contributing), Offset = if (status == "computed") info$offset else NA_real_,
        Offset_Prelim = info$offset_prelim, Offset_Method = info$weighting,
        ScreeningFallback = info$screening_fallback,
        LinkSupportAdequate = nrow(s) > 0L && all(s$LinkSupportAdequate),
        Status = status, Reason = info$reason)
      detail[[j]] <- data.frame(LinkID = e$LinkID, AnchorId = e$AnchorId,
        Facet = e$Facet, Level = e$Level, Est_From = e$Est_From, Est_To = e$Est_To,
        SE_From = e$SE_From, SE_To = e$SE_To, Retained = info$retained,
        Contributing = info$contributing, Flag = abs(info$residual) > threshold)
    }
    l <- dplyr::bind_rows(rows)
    list(links = l, support = dplyr::bind_rows(support), elements = dplyr::bind_rows(detail),
      cumulative = data.frame(WaveID = waves$WaveID, Wave = waves$Label,
        Offset = .linking_cumulative_offsets(l$Offset)))
  }
  baseline <- recalculate()
  same <- (is.na(links$Offset) & is.na(baseline$links$Offset)) |
    (is.finite(links$Offset) & is.finite(baseline$links$Offset) &
       abs(links$Offset - baseline$links$Offset) <= 1e-8 * pmax(1, abs(links$Offset)))
  if (anyNA(same) || !all(same)) stop(
    "Recomputed baseline does not match recorded offsets; rebuild the chain before sensitivity analysis.", call. = FALSE)
  audit <- unique(elements[, c("AnchorId", "Facet", "Level"), drop = FALSE])
  audit$MaxAbsLinkChange <- audit$MaxAbsCumulativeChange <- rep(NA_real_, nrow(audit))
  audit$UnavailableLinksAfter <- audit$NewlyUnavailableLinks <- audit$RetentionChanges <- audit$FallbackLinks <- integer(nrow(audit))
  audit$CompleteComparison <- rep(FALSE, nrow(audit))
  link_rows <- cumulative_rows <- changed_rows <- support_rows <- vector("list", nrow(audit))
  max_finite <- function(z) if (any(is.finite(z))) max(abs(z[is.finite(z)])) else NA_real_
  # ponytail: independent deletion reruns; retain full tables before adding batch optimizations.
  for (i in seq_len(nrow(audit))) {
    id <- audit$AnchorId[i]
    after <- recalculate(id)
    l <- after$links
    l$RemovedAnchorId <- rep(id, nrow(l))
    l$Offset_Before <- baseline$links$Offset
    l$Change <- l$Offset - l$Offset_Before
    link_rows[[i]] <- l
    c <- after$cumulative
    c$RemovedAnchorId <- rep(id, nrow(c))
    c$Offset_Before <- baseline$cumulative$Offset
    c$Change <- c$Offset - c$Offset_Before
    cumulative_rows[[i]] <- c
    after$support$RemovedAnchorId <- rep(id, nrow(after$support))
    support_rows[[i]] <- after$support
    fields <- c("LinkID", "AnchorId", "Facet", "Level", "Retained", "Contributing", "Flag")
    e <- dplyr::inner_join(baseline$elements[, fields], after$elements[, fields],
      by = c("LinkID", "AnchorId", "Facet", "Level"), suffix = c("_Before", "_After"))
    changed <- function(a, b) (is.na(a) != is.na(b)) | (!is.na(a) & !is.na(b) & a != b)
    retention_changed <- changed(e$Retained_Before, e$Retained_After)
    e <- e[retention_changed | changed(e$Contributing_Before, e$Contributing_After) |
      changed(e$Flag_Before, e$Flag_After), , drop = FALSE]
    e$RemovedAnchorId <- rep(id, nrow(e))
    changed_rows[[i]] <- e
    audit$MaxAbsLinkChange[i] <- max_finite(l$Change)
    audit$MaxAbsCumulativeChange[i] <- max_finite(c$Change[c$WaveID > 1L])
    audit$UnavailableLinksAfter[i] <- sum(!is.finite(l$Offset))
    audit$NewlyUnavailableLinks[i] <- sum(is.finite(l$Offset_Before) & !is.finite(l$Offset))
    audit$RetentionChanges[i] <- sum(retention_changed)
    audit$FallbackLinks[i] <- sum(l$ScreeningFallback)
    audit$CompleteComparison[i] <- all(is.finite(c$Change[c$WaveID > 1L]))
  }
  list(data = list(settings = data.frame(Method = x$config$method, DriftThreshold = threshold,
      MinCommonPerFacet = guideline, SourceEstimatesFixed = TRUE, SourceSEsFixed = TRUE, BaselineTolerance = 1e-8),
    removal = audit, baseline_links = baseline$links,
    baseline_cumulative = baseline$cumulative, baseline_elements = baseline$elements,
    links = dplyr::bind_rows(link_rows), cumulative = dplyr::bind_rows(cumulative_rows),
    retention_changes = dplyr::bind_rows(changed_rows), common_by_facet = dplyr::bind_rows(support_rows)),
    notes = .mfrmr_table_.equating_offset_sensitivity_data)
}




.plot_equating_chain <- function(x, draw = TRUE, style = resolve_plot_preset("standard"),
                                 show_title = FALSE, show_notes = FALSE, ...) {
  cum <- x$cumulative
  out <- new_mfrm_plot_data(
    "anchor_drift",
    list(
      plot = "chain",
      table = cum,
      links = x$links,
      display = list(show_title = show_title, show_notes = show_notes),
      title = "Equating chain",
      subtitle = "Cumulative offsets across linked calibration waves",
      legend = new_plot_legend(
        label = c("Cumulative offset", "Centered chain reference"),
        role = c("offset", "reference"),
        aesthetic = c("line-point", "line"),
        value = c(style$accent_primary, style$foreground)
      ),
      reference_lines = new_reference_lines("h", 0, "Centered chain reference", "dashed", "reference"),
      preset = style$name
    )
  )
  out$data$notes <- .mfrm_plot_notes(out$data)
  .mfrm_finalize_ggplot(out, draw = draw)
}

# --- Exported plot function --------------------------------------------------

#' Plot anchor drift or a screened linking chain
#'
#' Creates ggplot2 figures for inspecting anchor drift across calibration waves
#' or visualising the cumulative offset in a screened linking chain.
#'
#' @param x An `mfrm_anchor_drift` or `mfrm_equating_chain` object.
#' @param type Plot type: `"drift"` (dot plot of element drift),
#'   `"chain"` (cumulative offset line plot), `"heatmap"`
#'   (wave-by-element drift heatmap), or `"forest"` (per-(Facet, Level,
#'   Wave) anchor estimate with `+/- z * SE` whiskers; requires
#'   `mfrm_anchor_drift`).
#' @param facet Optional character vector to filter drift plots to specific
#'   facets.
#' @param ci_level Confidence level used by `type = "forest"` for the
#'   anchor-estimate whiskers (default `0.95`). Ignored for other
#'   plot types.
#' @param preset Visual preset (`"standard"`, `"publication"`, `"compact"`, or `"monochrome"`).
#' @param draw If `FALSE`, return the `ggplot` object invisibly without printing.
#' @param ... Reserved for compatibility; use the named plot controls.
#'
#' @details
#' Four plot types are supported:
#'
#' - **`"drift"`** (for `mfrm_anchor_drift` objects): A dot plot of each
#'   element's drift value. Vertical reference lines mark the drift threshold.
#'   The preset's warning colour indicates flagged elements.
#' - **`"heatmap"`** (for `mfrm_anchor_drift` objects): A wave-by-element
#'   heat matrix showing drift magnitude.  Darker cells represent larger
#'   absolute drift.  Useful for spotting systematic patterns (e.g., all
#'   criteria shifting in the same direction).
#' - **`"forest"`** (for `mfrm_anchor_drift` objects): Per-wave estimates
#'   with approximate normal whiskers from their available SEs. These are
#'   not intervals for between-wave differences; linking-offset uncertainty
#'   and cross-wave covariance are not included.
#' - **`"chain"`** (for `mfrm_equating_chain` objects): A line plot of
#'   cumulative offsets across the screened linking chain. A flatter line
#'   indicates smaller between-wave shifts; steep segments suggest larger
#'   link offsets that deserve review.
#'
#' @section Which plot should I use?:
#' - Use `type = "drift"` with an `mfrm_anchor_drift` object to review flagged
#'   elements directly.
#' - Use `type = "heatmap"` with an `mfrm_anchor_drift` object to spot
#'   wave-by-element patterns.
#' - Use `type = "chain"` with an `mfrm_equating_chain` object after
#'   [build_equating_chain()] to inspect cumulative offsets across waves.
#'
#' @section Interpreting plots:
#' **Drift** is the change in an element's estimated measure between
#' calibration waves, after accounting for the screened common-element link
#' offset. An
#' element is flagged when its absolute drift exceeds a threshold
#' (typically 0.5 logits) **and** the drift-to-SE ratio exceeds a
#' secondary criterion (typically 2.0). These are heuristic screening rules,
#' not a calibrated test of change. Subtracting a common offset can remove
#' a panel-wide shift; unflagged elements do not establish absence of annual drift.
#'
#' - Drift dots distinguish flagged elements. Heatmap shading shows magnitude,
#'   not whether both screening thresholds were exceeded. Possible explanations
#'   require substantive review, including changes in scoring or exposure.
#' - In chain plots, uneven changes between waves indicate differential
#'   shifts in the screened linking offsets. The \eqn{y}-axis shows cumulative
#'   logit-scale offsets; flatter segments indicate more stable adjacent links.
#'   Steep segments should be checked alongside `LinkSupportAdequate` and the
#'   retained common-element counts before making longitudinal claims.
#' - For drift objects, it is usually best to read `summary(x)` first
#'   and then use the plot to see where the flagged values sit.
#'
#' @section Typical workflow:
#' 1. Build a drift or screened-linking object with [detect_anchor_drift()] or
#'    [build_equating_chain()].
#' 2. Start with `draw = FALSE` if you want the plotting data for custom
#'    reporting.
#' 3. Use the plot for quick screening and then inspect the underlying
#'    tables for exact values.
#'
#' @section Further guidance:
#' For a plot-selection guide and a longer walkthrough, see
#' [mfrmr_visual_diagnostics] and
#' `vignette("mfrmr-visual-diagnostics", package = "mfrmr")`.
#'
#' @return Invisibly, a `ggplot` object. Use [plot_data()] to retrieve its
#'   reusable plotting data and notes. With
#'   `draw = FALSE`, `plot_data(p, "table")` contains the filtered drift or chain
#'   table, `plot_data(p, "matrix")` contains the heatmap matrix when requested,
#'   and the returned plot data includes package-native `title`, `subtitle`,
#'   `legend`, and `reference_lines`.
#'
#' @seealso [detect_anchor_drift()], [build_equating_chain()],
#'   [plot(x, type = "heatmap")][plot.mfrm_dif], [plot(x, type = "bubble")][plot.mfrm_fit], [mfrmr_visual_diagnostics]
#' @concept confidence intervals
#' @concept visual diagnostics
#' @concept linking
#' @section Session plot defaults:
#' See [mfrmr_visual_diagnostics] for `options(mfrmr.plot_preset)`, argument
#' precedence, and appearance when saving or reusing a plot.
#' @keywords internal
#' @section Migration in 0.2.4:
#' This renderer is internal. Use the corresponding `plot()` route in
#' [mfrmr_plot_migration]; the former exported name is no longer available.
plot_anchor_drift <- function(x, type = c("drift", "chain", "heatmap", "forest"),
                              facet = NULL,
                              ci_level = 0.95,
                              preset = c("standard", "publication", "compact", "monochrome"),
                              draw = TRUE, ...) {
  if (missing(preset)) preset <- .mfrm_default_plot_preset()
  type <- match.arg(type)
  style <- resolve_plot_preset(preset)

  if (inherits(x, "mfrm_equating_chain")) {
    if (type == "chain") {
      return(.plot_equating_chain(x, draw = draw, style = style, ...))
    }
  }

  if (inherits(x, "mfrm_anchor_drift")) {
    dt <- x$drift_table
    if (!is.null(facet)) dt <- dt |> dplyr::filter(.data$Facet %in% facet)

    if (nrow(dt) == 0) {
      if (draw) message("No drift data to plot.")
      return(.mfrm_finalize_ggplot(
        new_mfrm_plot_data(
          "anchor_drift",
          list(plot = type, table = dt, data = dt, matrix = matrix(numeric(0), 0L, 0L), preset = style$name)
        ),
        draw = draw
      ))
    }

    if (type == "drift") {
      return(.plot_drift_dot(dt, x$config, draw = draw, style = style, ...))
    } else if (type == "heatmap") {
      return(.plot_drift_heatmap(dt, x$config, draw = draw, style = style, ...))
    } else if (type == "forest") {
      return(.plot_drift_forest(dt, x$config, ci_level = ci_level,
                                 draw = draw, style = style, ...))
    }
  }

  stop("Unsupported object class or plot type combination.", call. = FALSE)
}

# Forest-style anchor-drift visualisation. Each (Facet, Level, Wave)
# row is rendered as a horizontal CI whisker around the per-wave
# anchor estimate; rows are grouped by Facet level so reviewers see
# one ladder of CI bands per anchored element across waves.
.plot_drift_forest <- function(drift_tbl, config, ci_level = 0.95,
                               draw = TRUE, style = NULL, ...) {
  if (is.null(style)) style <- resolve_plot_preset("standard")
  dt <- as.data.frame(drift_tbl, stringsAsFactors = FALSE)
  est_col <- if ("Estimate" %in% names(dt)) "Estimate" else if ("Wave_Est" %in% names(dt)) "Wave_Est" else NA_character_
  if (is.na(est_col) || !all(c("Facet", "Level", "Wave") %in% names(dt))) {
    stop("Forest plot requires Facet, Level, Wave, and Estimate (or Wave_Est) columns.",
         call. = FALSE)
  }
  dt$Estimate <- dt[[est_col]]
  se_col <- if ("SE_Wave" %in% names(dt)) "SE_Wave" else if ("SE" %in% names(dt)) "SE" else if ("ModelSE" %in% names(dt)) "ModelSE" else NA_character_
  z_ci <- stats::qnorm((1 - ci_level) / 2, lower.tail = FALSE)
  if (!is.na(se_col)) {
    dt$CI_Lower <- dt$Estimate - z_ci * dt[[se_col]]
    dt$CI_Upper <- dt$Estimate + z_ci * dt[[se_col]]
  } else {
    dt$CI_Lower <- NA_real_
    dt$CI_Upper <- NA_real_
  }
  dt$Label <- paste0(dt$Facet, ":", dt$Level, " @ ", dt$Wave)
  dt <- dt[order(dt$Facet, dt$Level, dt$Wave), , drop = FALSE]
  out <- new_mfrm_plot_data(
    "anchor_drift_forest",
    list(
      data = dt,
      ci_level = ci_level,
      title = "Anchor drift forest",
      subtitle = sprintf("Per-wave anchor estimates with %g%% CI",
                         round(100 * ci_level)),
      preset = style$name,
      legend = new_plot_legend(
        label = c("Anchor estimate", "CI whisker"),
        role = c("location", "uncertainty"),
        aesthetic = c("point", "segment"),
        value = c(style$accent_primary, style$accent_primary)
      ),
      reference_lines = new_reference_lines("v", 0,
                                             "Centred logit reference",
                                             "dashed", "reference")
    )
  )
  .mfrm_finalize_ggplot(out, draw = draw)
}

# ============================================================================
# QC Pipeline Plot
# ============================================================================

#' Plot QC pipeline results
#'
#' Visualizes the output from [run_qc_pipeline()] as either a traffic-light
#' bar chart or a panel containing each check's explanation.
#'
#' @param x Output from [run_qc_pipeline()].
#' @param type Plot type: `"traffic_light"` (default) or `"detail"`.
#' @param draw If `FALSE`, return plot data invisibly without drawing.
#' @param ... Additional graphical parameters passed to plotting functions.
#'
#' @details
#' Two plot types are provided for visual triage of QC results:
#'
#' - **`"traffic_light"`** (default): A horizontal bar chart with one row
#'   per QC check.  Bars are coloured green (Pass), amber (Warn), or red
#'   (Fail).  Provides an at-a-glance summary of the current QC review state.
#' - **`"detail"`**: A panel showing the saved `Detail` text beside each
#'   verdict. Read this explanation and the returned table to understand
#'   why a check was flagged or unavailable.
#'
#' @section Interpretation:
#' The rows are the actual checks returned by [run_qc_pipeline()]: convergence,
#' global fit, selected-facet reliability and separation, element misfit,
#' unexpected responses, category structure, connectivity, inter-rater
#' agreement, and the functioning/bias screen. Element misfit uses the
#' configured mean-square band; it is not a ZSTD test. PCA and displacement
#' are separate diagnostics and are not checks in this pipeline.
#'
#' Green (Pass), amber (Warn), and red (Fail) describe the selected screening
#' rules. Grey (Skip) marks unrequested or unavailable checks; `AffectsOverall`
#' in the returned data distinguishes their contribution to the overall result.
#' A missing result is not evidence of acceptable fit. High rater separation
#' is not high agreement, and no colour establishes statistical validity or
#' justifies deleting raters or collapsing categories without further review.
#'
#' @return Invisibly, a `ggplot` object. `plot_data(p, "verdicts")` returns
#'   the verdicts tibble from the QC pipeline.
#'
#' @seealso [run_qc_pipeline()], [plot(x, type = "qc")][plot.mfrm_fit],
#'   [build_visual_summaries()], [mfrmr_visual_diagnostics]
#' @keywords internal
#' @section Migration in 0.2.4:
#' This renderer is internal. Use the corresponding `plot()` route in
#' [mfrmr_plot_migration]; the former exported name is no longer available.
plot_qc_pipeline <- function(x, type = c("traffic_light", "detail"),
                             draw = TRUE, ...) {
  type <- match.arg(type)
  stopifnot(inherits(x, "mfrm_qc_pipeline"))
  validate_qc_pipeline_output(x)

  vt <- x$verdicts
  out <- new_mfrm_plot_data(
    "qc_pipeline",
    list(
      plot = type,
      verdicts = vt,
      table = vt,
      title = "QC pipeline"
    )
  )
  .mfrm_finalize_ggplot(out, draw = draw)
}
