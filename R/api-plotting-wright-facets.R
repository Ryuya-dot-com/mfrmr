# FACETS Table 6-style Wright-map data and base-R renderer.
#
# The helpers in this file intentionally describe a visual layout.  They do
# not change, or claim numerical equivalence with, the calibration engine used
# to produce the measures in an mfrm_fit object.

match_wright_style <- function(x, renderer = NULL) {
  if (!is.null(renderer)) {
    renderer_value <- tolower(as.character(renderer[1]))
    renderer_choices <- c("native", "facets")
    if (!(renderer_value %in% renderer_choices)) {
      stop(
        sprintf(
          "`renderer = \"%s\"` is not recognized. Choose %s.",
          renderer_value,
          paste(shQuote(renderer_choices), collapse = " or ")
        ),
        call. = FALSE
      )
    }
    return(if (identical(renderer_value, "facets")) "facets_style" else "native")
  }
  value <- tolower(as.character(x[1] %||% "native"))
  choices <- c("native", "facets_style")
  if (!(value %in% choices)) {
    stop(
      sprintf(
        "`wright_style = \"%s\"` is not recognized. Choose %s.",
        value,
        paste(shQuote(choices), collapse = " or ")
      ),
      call. = FALSE
    )
  }
  value
}

# Half-point thresholds are expected-score crossings at the midpoint between
# adjacent retained score categories.  The status columns deliberately match
# the category-curve/report contract so a renderer never turns an out-of-range
# or ambiguous crossing into an apparently exact line.
build_half_point_threshold_table <- function(expected_df, categories) {
  expected_df <- as.data.frame(expected_df %||% data.frame(), stringsAsFactors = FALSE)
  cats_num <- suppressWarnings(as.numeric(as.character(categories)))
  if (nrow(expected_df) == 0L || length(cats_num) < 2L || !all(is.finite(cats_num))) {
    return(data.frame())
  }
  needed <- c("CurveGroup", "Theta", "ExpectedScore")
  if (!all(needed %in% names(expected_df))) return(data.frame())
  cats_num <- sort(cats_num)
  rows <- list()
  idx <- 1L
  for (group in unique(as.character(expected_df$CurveGroup))) {
    line <- expected_df[as.character(expected_df$CurveGroup) == group, , drop = FALSE]
    line <- line[order(suppressWarnings(as.numeric(line$Theta))), , drop = FALSE]
    theta <- suppressWarnings(as.numeric(line$Theta))
    expected <- suppressWarnings(as.numeric(line$ExpectedScore))
    ok <- is.finite(theta) & is.finite(expected)
    theta <- theta[ok]
    expected <- expected[ok]
    for (j in seq_len(length(cats_num) - 1L)) {
      target <- (cats_num[j] + cats_num[j + 1L]) / 2
      threshold <- NA_real_
      in_range <- FALSE
      crossing_count <- 0L
      if (length(theta) > 1L) {
        centered <- expected - target
        exact <- which(abs(centered) <= sqrt(.Machine$double.eps))
        if (length(exact) > 0L) {
          threshold <- theta[exact[1]]
          in_range <- TRUE
          crossing_count <- length(exact)
        } else {
          crossing <- which(centered[-length(centered)] * centered[-1L] <= 0)
          crossing_count <- length(crossing)
          if (length(crossing) > 0L) {
            i <- crossing[1]
            y1 <- expected[i]
            y2 <- expected[i + 1L]
            x1 <- theta[i]
            x2 <- theta[i + 1L]
            threshold <- if (abs(y2 - y1) > sqrt(.Machine$double.eps)) {
              x1 + (target - y1) * (x2 - x1) / (y2 - y1)
            } else {
              mean(c(x1, x2))
            }
            in_range <- TRUE
          }
        }
      }
      rows[[idx]] <- data.frame(
        CurveGroup = group,
        PairOrder = as.integer(j),
        LowerCategory = as.character(cats_num[j]),
        UpperCategory = as.character(cats_num[j + 1L]),
        TargetScore = target,
        HalfPointThreshold = threshold,
        InThetaRange = in_range,
        CrossingCount = as.integer(crossing_count),
        CrossingStatus = dplyr::case_when(
          !in_range ~ "outside_theta_range",
          crossing_count == 1L ~ "in_range",
          crossing_count > 1L ~ "multiple_crossings",
          TRUE ~ "review"
        ),
        CrossingLabel = paste0("E[X] = ", format(target)),
        stringsAsFactors = FALSE
      )
      idx <- idx + 1L
    }
  }
  if (length(rows) == 0L) return(data.frame())
  dplyr::bind_rows(rows) |>
    dplyr::arrange(.data$CurveGroup, .data$PairOrder)
}

validate_wright_range <- function(x) {
  if (is.null(x)) return(NULL)
  x <- suppressWarnings(as.numeric(x))
  if (length(x) != 2L || !all(is.finite(x)) || x[1] >= x[2]) {
    stop("`wright_range` must be NULL or a finite increasing length-2 numeric vector.", call. = FALSE)
  }
  x
}

wright_score_labels <- function(fit, categories, category_labels = NULL) {
  categories <- as.character(categories)
  score_map <- as.data.frame(fit$prep$score_map %||% data.frame(), stringsAsFactors = FALSE)
  original <- categories
  if (nrow(score_map) > 0L &&
      all(c("OriginalScore", "InternalScore") %in% names(score_map))) {
    idx <- match(categories, as.character(score_map$InternalScore))
    mapped <- as.character(score_map$OriginalScore[idx])
    original[!is.na(mapped)] <- mapped[!is.na(mapped)]
  }

  rubric <- rep(NA_character_, length(categories))
  if (!is.null(category_labels)) {
    if (is.data.frame(category_labels)) {
      label_tbl <- as.data.frame(category_labels, stringsAsFactors = FALSE)
      if (!all(c("Score", "Label") %in% names(label_tbl))) {
        stop("A data-frame `category_labels` must contain `Score` and `Label` columns.", call. = FALSE)
      }
      rubric <- as.character(label_tbl$Label[match(original, as.character(label_tbl$Score))])
    } else {
      labels <- as.character(category_labels)
      label_names <- names(category_labels)
      if (!is.null(label_names) && any(nzchar(label_names))) {
        rubric <- labels[match(original, label_names)]
        internal_match <- labels[match(categories, label_names)]
        rubric[is.na(rubric)] <- internal_match[is.na(rubric)]
      } else if (length(labels) == length(categories)) {
        rubric <- labels
      } else {
        stop(
          "An unnamed `category_labels` vector must have one value per retained score category.",
          call. = FALSE
        )
      }
    }
  }
  rubric[is.na(rubric)] <- ""
  display <- ifelse(nzchar(rubric), paste0(original, " ", rubric), original)

  tibble::tibble(
    InternalScore = categories,
    OriginalScore = original,
    RubricLabel = rubric,
    DisplayLabel = display
  )
}

build_wright_score_rulers <- function(fit,
                                      theta_range,
                                      category_labels = NULL,
                                      include_steps = TRUE) {
  empty_steps <- tibble::tibble(
    CurveGroup = character(), Step = character(), StepIndex = integer(),
    Estimate = numeric(), LowerScore = character(), UpperScore = character(),
    LowerLabel = character(), UpperLabel = character(),
    TransitionLabel = character()
  )
  empty_half <- tibble::tibble(
    CurveGroup = character(), LowerScore = character(), UpperScore = character(),
    LowerLabel = character(), UpperLabel = character(),
    MeanHalfScore = numeric(), Estimate = numeric(), TransitionLabel = character(),
    PairOrder = integer(), InThetaRange = logical(), CrossingCount = integer(),
    CrossingStatus = character(), CrossingLabel = character()
  )
  if (!isTRUE(include_steps)) {
    return(list(
      category_labels = tibble::tibble(),
      step_ruler = empty_steps,
      score_transitions = empty_half
    ))
  }

  curve_spec <- tryCatch(build_step_curve_spec(fit), error = function(e) NULL)
  if (is.null(curve_spec)) {
    return(list(
      category_labels = tibble::tibble(),
      step_ruler = empty_steps,
      score_transitions = empty_half
    ))
  }
  label_tbl <- wright_score_labels(
    fit,
    categories = curve_spec$categories,
    category_labels = category_labels
  )
  step_points <- tibble::as_tibble(curve_spec$step_points)
  step_ruler <- if (nrow(step_points) > 0L) {
    step_points |>
      dplyr::mutate(
        StepIndex = as.integer(.data$StepIndex),
        Estimate = as.numeric(.data$Threshold),
        LowerScore = label_tbl$OriginalScore[pmax(1L, .data$StepIndex)],
        UpperScore = label_tbl$OriginalScore[pmin(nrow(label_tbl), .data$StepIndex + 1L)],
        LowerLabel = label_tbl$DisplayLabel[pmax(1L, .data$StepIndex)],
        UpperLabel = label_tbl$DisplayLabel[pmin(nrow(label_tbl), .data$StepIndex + 1L)],
        TransitionLabel = paste(.data$LowerLabel, .data$UpperLabel, sep = " -> ")
      ) |>
      dplyr::select(
        "CurveGroup", "Step", "StepIndex", "Estimate", "LowerScore", "UpperScore",
        "LowerLabel", "UpperLabel", "TransitionLabel"
      )
  } else {
    empty_steps
  }

  theta_range <- suppressWarnings(as.numeric(theta_range))
  theta_grid <- seq(theta_range[1], theta_range[2], length.out = 1601L)
  curve_tbl <- build_curve_tables(curve_spec, theta_grid)
  exp_df <- as.data.frame(curve_tbl$expected, stringsAsFactors = FALSE)
  half_points <- build_half_point_threshold_table(exp_df, curve_spec$categories)
  score_transitions <- if (nrow(half_points) > 0L) {
    tibble::as_tibble(half_points) |>
      dplyr::mutate(
        LowerScore = label_tbl$OriginalScore[.data$PairOrder],
        UpperScore = label_tbl$OriginalScore[.data$PairOrder + 1L],
        LowerLabel = label_tbl$DisplayLabel[.data$PairOrder],
        UpperLabel = label_tbl$DisplayLabel[.data$PairOrder + 1L],
        MeanHalfScore = .data$TargetScore,
        Estimate = .data$HalfPointThreshold,
        TransitionLabel = paste(.data$LowerLabel, .data$UpperLabel, sep = " -> ")
      ) |>
      dplyr::select(
        "CurveGroup", "LowerScore", "UpperScore", "LowerLabel", "UpperLabel",
        "MeanHalfScore", "Estimate", "TransitionLabel", "PairOrder",
        "InThetaRange", "CrossingCount", "CrossingStatus", "CrossingLabel"
      )
  } else {
    empty_half
  }

  list(
    category_labels = label_tbl,
    step_ruler = tibble::as_tibble(step_ruler),
    score_transitions = tibble::as_tibble(score_transitions)
  )
}

nearest_wright_row <- function(x, lower, upper, rows_per_logit) {
  step <- 1 / rows_per_logit
  pmin(upper, pmax(lower, round((x - lower) / step) * step + lower))
}

build_facets_style_wright_data <- function(fit,
                                           plot_data,
                                           category_labels = NULL,
                                           rows_per_logit = 2L,
                                           wright_range = NULL,
                                           extreme_placement = c("ends", "estimate"),
                                           persons_per_star = NULL,
                                           include_steps = TRUE) {
  rows_per_logit <- suppressWarnings(as.integer(rows_per_logit[1]))
  if (!is.finite(rows_per_logit) || rows_per_logit < 1L || rows_per_logit > 20L) {
    stop("`rows_per_logit` must be an integer from 1 through 20.", call. = FALSE)
  }
  wright_range <- validate_wright_range(wright_range)
  extreme_placement <- match.arg(tolower(as.character(extreme_placement[1])), c("ends", "estimate"))

  base_values <- c(
    suppressWarnings(as.numeric(plot_data$person$Estimate)),
    suppressWarnings(as.numeric(plot_data$locations$Estimate))
  )
  base_values <- base_values[is.finite(base_values)]
  if (length(base_values) == 0L) base_values <- c(-1, 1)
  provisional <- c(floor(min(base_values)), ceiling(max(base_values)))
  if (diff(provisional) <= 0) provisional <- mean(provisional) + c(-1, 1)
  score_rulers <- build_wright_score_rulers(
    fit,
    theta_range = provisional + c(-6, 6),
    category_labels = category_labels,
    include_steps = include_steps
  )
  transition_values <- c(
    suppressWarnings(as.numeric(score_rulers$step_ruler$Estimate)),
    suppressWarnings(as.numeric(score_rulers$score_transitions$Estimate))
  )
  transition_values <- transition_values[is.finite(transition_values)]
  all_values <- c(base_values, transition_values)
  if (is.null(wright_range)) {
    lower <- floor(min(all_values) * rows_per_logit) / rows_per_logit
    upper <- ceiling(max(all_values) * rows_per_logit) / rows_per_logit
    if (!is.finite(lower) || !is.finite(upper) || lower >= upper) {
      center <- mean(all_values, na.rm = TRUE)
      lower <- center - 1
      upper <- center + 1
    }
  } else {
    lower <- wright_range[1]
    upper <- wright_range[2]
  }
  row_step <- 1 / rows_per_logit
  ruler_values <- seq(lower, upper + row_step / 10, by = row_step)
  ruler_values <- ruler_values[ruler_values <= upper + sqrt(.Machine$double.eps)]
  ruler_rows <- tibble::tibble(
    Row = seq_along(ruler_values),
    Logit = ruler_values,
    Major = abs(ruler_values - round(ruler_values)) < sqrt(.Machine$double.eps),
    Label = ifelse(
      abs(ruler_values - round(ruler_values)) < sqrt(.Machine$double.eps),
      format(round(ruler_values), trim = TRUE),
      format(round(ruler_values, 3), trim = TRUE)
    )
  )

  person <- as.data.frame(plot_data$person, stringsAsFactors = FALSE)
  extreme <- if ("Extreme" %in% names(person)) tolower(as.character(person$Extreme)) else rep("none", nrow(person))
  extreme[is.na(extreme) | !nzchar(extreme)] <- "none"
  person$OriginalEstimate <- suppressWarnings(as.numeric(person$Estimate))
  person$DisplayEstimate <- person$OriginalEstimate
  if (identical(extreme_placement, "ends")) {
    person$DisplayEstimate[extreme == "low"] <- lower
    person$DisplayEstimate[extreme == "high"] <- upper
  }
  person$BelowRange <- person$DisplayEstimate < lower
  person$AboveRange <- person$DisplayEstimate > upper
  person$DisplayEstimate <- pmin(upper, pmax(lower, person$DisplayEstimate))
  person$RulerValue <- nearest_wright_row(person$DisplayEstimate, lower, upper, rows_per_logit)
  person$ExtremePlacement <- extreme

  person_frequency <- person |>
    dplyr::filter(is.finite(.data$RulerValue)) |>
    dplyr::count(.data$RulerValue, name = "Count") |>
    dplyr::right_join(
      ruler_rows |>
        dplyr::transmute(RulerValue = .data$Logit),
      by = "RulerValue"
    ) |>
    dplyr::mutate(Count = dplyr::coalesce(.data$Count, 0L)) |>
    dplyr::arrange(.data$RulerValue)
  if (is.null(persons_per_star)) {
    persons_per_star <- max(1L, ceiling(max(person_frequency$Count, na.rm = TRUE) / 20))
  } else {
    persons_per_star <- suppressWarnings(as.numeric(persons_per_star[1]))
    if (!is.finite(persons_per_star) || persons_per_star <= 0) {
      stop("`persons_per_star` must be NULL or one positive number.", call. = FALSE)
    }
  }
  person_frequency$StarCount <- ifelse(
    person_frequency$Count > 0,
    pmax(1L, ceiling(person_frequency$Count / persons_per_star)),
    0L
  )
  person_frequency$Stars <- vapply(
    person_frequency$StarCount,
    function(n) if (n > 0L) paste(rep("*", n), collapse = "") else "",
    character(1)
  )

  facet_ruler <- as.data.frame(
    plot_data$locations[plot_data$locations$PlotType == "Facet level", , drop = FALSE],
    stringsAsFactors = FALSE
  )
  signs <- fit$config$facet_signs %||%
    stats::setNames(rep(-1, length(unique(facet_ruler$Group))), unique(facet_ruler$Group))
  sign_value <- suppressWarnings(as.numeric(signs[as.character(facet_ruler$Group)]))
  sign_value[!is.finite(sign_value)] <- -1
  facet_ruler$Facet <- as.character(facet_ruler$Group)
  facet_ruler$Level <- as.character(facet_ruler$Label)
  facet_ruler$Sign <- sign_value
  facet_ruler$Orientation <- ifelse(sign_value >= 0, "positive", "negative")
  facet_ruler$Header <- paste0(ifelse(sign_value >= 0, "+", "-"), facet_ruler$Facet)
  facet_ruler$OriginalEstimate <- suppressWarnings(as.numeric(facet_ruler$Estimate))
  facet_ruler$BelowRange <- facet_ruler$OriginalEstimate < lower
  facet_ruler$AboveRange <- facet_ruler$OriginalEstimate > upper
  facet_ruler$DisplayEstimate <- pmin(upper, pmax(lower, facet_ruler$OriginalEstimate))
  facet_ruler$RulerValue <- nearest_wright_row(facet_ruler$DisplayEstimate, lower, upper, rows_per_logit)
  facet_ruler$DisplayLabel <- ifelse(
    facet_ruler$BelowRange | facet_ruler$AboveRange,
    paste0("(", facet_ruler$Level, ")"),
    facet_ruler$Level
  )
  facet_cells <- tibble::as_tibble(facet_ruler) |>
    dplyr::group_by(.data$Facet, .data$Header, .data$RulerValue) |>
    dplyr::summarise(
      CellLabel = paste(.data$DisplayLabel, collapse = ", "),
      N = dplyr::n(),
      .groups = "drop"
    )

  add_ruler_position <- function(tbl) {
    if (nrow(tbl) == 0L) return(tbl)
    tbl |>
      dplyr::mutate(
        InRange = is.finite(.data$Estimate) & .data$Estimate >= lower & .data$Estimate <= upper,
        DisplayEstimate = pmin(upper, pmax(lower, .data$Estimate)),
        RulerValue = nearest_wright_row(.data$DisplayEstimate, lower, upper, rows_per_logit)
      )
  }
  step_ruler <- add_ruler_position(score_rulers$step_ruler)
  score_transitions <- add_ruler_position(score_rulers$score_transitions)
  step_headers <- if (nrow(step_ruler) > 0L) {
    tibble::tibble(
      CurveGroup = unique(as.character(step_ruler$CurveGroup)),
      Header = paste0("Scale:", unique(as.character(step_ruler$CurveGroup)))
    )
  } else {
    tibble::tibble(CurveGroup = character(), Header = character())
  }

  settings <- tibble::tibble(
    Renderer = "facets",
    WrightStyle = "facets_style",
    VisualParity = "FACETS Table 6-style layout; not a claim of FACETS numerical equivalence",
    LowerLogit = lower,
    UpperLogit = upper,
    RowsPerLogit = rows_per_logit,
    ExtremePlacement = extreme_placement,
    PersonsPerStar = persons_per_star,
    StarsPerPerson = 1 / persons_per_star,
    PersonN = nrow(person)
  )
  headers <- dplyr::bind_rows(
    tibble::tibble(ColumnType = "person", Group = "Person", Header = "+Person"),
    unique(facet_ruler[, c("Facet", "Header"), drop = FALSE]) |>
      dplyr::transmute(ColumnType = "facet", Group = .data$Facet, Header = .data$Header),
    step_headers |>
      dplyr::transmute(ColumnType = "step", Group = .data$CurveGroup, Header = .data$Header)
  )

  list(
    ruler_rows = ruler_rows,
    person_frequency = tibble::as_tibble(person_frequency),
    person_placements = tibble::as_tibble(person),
    facet_ruler = tibble::as_tibble(facet_ruler),
    facet_cells = tibble::as_tibble(facet_cells),
    step_ruler = tibble::as_tibble(step_ruler),
    score_transitions = tibble::as_tibble(score_transitions),
    category_labels = tibble::as_tibble(score_rulers$category_labels),
    headers = tibble::as_tibble(headers),
    settings = settings
  )
}

draw_wright_facets_style <- function(plot_data,
                                     title = NULL,
                                     palette = NULL,
                                     show_ci = FALSE,
                                     ci_level = 0.95) {
  facets_data <- plot_data$facets_style
  if (is.null(facets_data) || !is.list(facets_data)) {
    stop("FACETS-style Wright-map data are missing.", call. = FALSE)
  }
  pal <- resolve_palette(
    palette = palette,
    defaults = c(
      facet_level = "#1b9e77",
      step_threshold = "#d95f02",
      person_hist = "gray25",
      person_star = "gray20",
      grid = "#e5e7eb",
      range = "#94a3b8",
      iqr = "#334155"
    )
  )
  headers <- as.data.frame(facets_data$headers, stringsAsFactors = FALSE)
  if (nrow(headers) == 0L) stop("No Wright-map columns are available.", call. = FALSE)
  n_col <- nrow(headers)
  settings <- facets_data$settings
  yr <- c(settings$LowerLogit[1], settings$UpperLogit[1])
  old_par <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(old_par), add = TRUE)
  graphics::par(
    mar = c(4.6, 4.8, 5.4, 2.2),
    mgp = c(2.6, 0.8, 0),
    xpd = NA
  )
  graphics::plot(
    NA_real_, NA_real_,
    xlim = c(0.45, n_col + 0.55),
    ylim = yr,
    xaxt = "n", yaxt = "n", xlab = "", ylab = "Logit ruler",
    main = title %||% "FACETS-style Wright map"
  )
  rows <- facets_data$ruler_rows
  major <- !is.na(rows$Major) & rows$Major
  graphics::abline(h = rows$Logit, col = grDevices::adjustcolor(pal["grid"], alpha.f = 0.8), lty = 1)
  graphics::abline(h = rows$Logit[major], col = grDevices::adjustcolor(pal["range"], alpha.f = 0.75), lwd = 1.1)
  graphics::abline(v = seq(0.5, n_col + 0.5, by = 1), col = grDevices::adjustcolor(pal["grid"], alpha.f = 0.9))
  graphics::axis(2, at = rows$Logit, labels = rows$Label, las = 1, cex.axis = 0.78)
  graphics::axis(4, at = rows$Logit[major], labels = rows$Label[major], las = 1, cex.axis = 0.78)
  graphics::axis(3, at = seq_len(n_col), labels = headers$Header, tick = FALSE, line = 0.25, cex.axis = 0.78)

  person_x <- which(headers$ColumnType == "person")[1]
  person_freq <- facets_data$person_frequency
  if (is.finite(person_x) && nrow(person_freq) > 0L) {
    graphics::text(
      x = person_x,
      y = person_freq$RulerValue,
      labels = person_freq$Stars,
      cex = 0.78,
      family = "mono",
      col = pal["person_star"]
    )
  }

  facet_cells <- facets_data$facet_cells
  facet_ruler <- facets_data$facet_ruler
  facet_headers <- headers[headers$ColumnType == "facet", , drop = FALSE]
  for (i in seq_len(nrow(facet_headers))) {
    x_pos <- match(facet_headers$Header[i], headers$Header)
    cell <- facet_cells[facet_cells$Facet == facet_headers$Group[i], , drop = FALSE]
    if (nrow(cell) > 0L) {
      graphics::text(
        x = x_pos,
        y = cell$RulerValue,
        labels = cell$CellLabel,
        cex = 0.68,
        col = pal["facet_level"]
      )
    }
    if (isTRUE(show_ci) && all(c("SE", "Estimate") %in% names(facet_ruler))) {
      sub <- facet_ruler[facet_ruler$Facet == facet_headers$Group[i], , drop = FALSE]
      ci_ok <- is.finite(sub$SE) & sub$SE > 0 & is.finite(sub$Estimate)
      if (any(ci_ok)) {
        z <- stats::qnorm(1 - (1 - ci_level) / 2)
        lo <- pmax(yr[1], sub$Estimate[ci_ok] - z * sub$SE[ci_ok])
        hi <- pmin(yr[2], sub$Estimate[ci_ok] + z * sub$SE[ci_ok])
        graphics::segments(
          x0 = x_pos - 0.36, y0 = lo,
          x1 = x_pos - 0.36, y1 = hi,
          col = grDevices::adjustcolor(pal["facet_level"], alpha.f = 0.65), lwd = 1
        )
        graphics::segments(
          x0 = x_pos - 0.40, y0 = lo,
          x1 = x_pos - 0.32, y1 = lo,
          col = grDevices::adjustcolor(pal["facet_level"], alpha.f = 0.65)
        )
        graphics::segments(
          x0 = x_pos - 0.40, y0 = hi,
          x1 = x_pos - 0.32, y1 = hi,
          col = grDevices::adjustcolor(pal["facet_level"], alpha.f = 0.65)
        )
      }
    }
  }

  step_headers <- headers[headers$ColumnType == "step", , drop = FALSE]
  step_ruler <- facets_data$step_ruler
  half_ruler <- facets_data$score_transitions
  for (i in seq_len(nrow(step_headers))) {
    x_pos <- match(step_headers$Header[i], headers$Header)
    step_sub <- step_ruler[
      step_ruler$CurveGroup == step_headers$Group[i] & step_ruler$InRange,
      , drop = FALSE
    ]
    if (nrow(step_sub) > 0L) {
      graphics::segments(
        x0 = x_pos - 0.34, y0 = step_sub$RulerValue,
        x1 = x_pos + 0.34, y1 = step_sub$RulerValue,
        col = pal["step_threshold"], lwd = 1.5
      )
      graphics::text(
        x = x_pos,
        y = step_sub$RulerValue,
        labels = step_sub$TransitionLabel,
        pos = 3, offset = 0.18, cex = 0.58,
        col = pal["step_threshold"]
      )
    }
    half_sub <- half_ruler[
      half_ruler$CurveGroup == step_headers$Group[i] & half_ruler$InRange,
      , drop = FALSE
    ]
    if (nrow(half_sub) > 0L) {
      graphics::segments(
        x0 = x_pos - 0.22, y0 = half_sub$RulerValue,
        x1 = x_pos + 0.22, y1 = half_sub$RulerValue,
        col = grDevices::adjustcolor(pal["step_threshold"], alpha.f = 0.55),
        lty = 3, lwd = 1
      )
    }
  }

  graphics::mtext(
    sprintf("* = %s person(s); rows/logit = %d", format(settings$PersonsPerStar[1], trim = TRUE), settings$RowsPerLogit[1]),
    side = 1, line = 2.7, adj = 0, cex = 0.75
  )
  graphics::mtext(
    "FACETS Table 6-style visual layout; estimates remain mfrmr estimates (not numerical equivalence).",
    side = 1, line = 3.7, adj = 0, cex = 0.67, col = "gray35"
  )
  invisible(NULL)
}
