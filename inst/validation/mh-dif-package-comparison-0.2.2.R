# Optional MH DIF package comparison for 0.2.2 review.
#
# This script is intentionally not part of the CRAN-time test suite. It can be
# sourced in a validation environment with `difR` installed to compare the first
# `mfrmr` Mantel-Haenszel screen against a public R DIF implementation.

.mfrmr_mh_dif_alignment_fixture <- function(seed = 202603L,
                                            n_person = 800L) {
  set.seed(seed)
  persons <- sprintf("P%04d", seq_len(n_person))
  group <- rep(c("Reference", "Focal"), each = n_person / 2L)
  theta <- stats::rnorm(n_person)
  item_names <- paste0("I", seq_len(8L))
  difficulty <- seq(-1.4, 1.4, length.out = length(item_names))

  resp <- vapply(seq_along(item_names), function(j) {
    dif_shift <- if (identical(item_names[j], "I6")) {
      ifelse(group == "Focal", 0.75, 0)
    } else {
      0
    }
    stats::rbinom(n_person, size = 1L,
                  prob = stats::plogis(theta - difficulty[j] - dif_shift))
  }, numeric(n_person))
  colnames(resp) <- item_names
  storage.mode(resp) <- "numeric"

  long <- data.frame(
    Person = rep(persons, each = length(item_names)),
    Item = rep(item_names, times = n_person),
    Score = as.vector(t(resp)),
    Group = rep(group, each = length(item_names)),
    stringsAsFactors = FALSE
  )

  list(
    long = long,
    response_matrix = resp,
    group = group,
    seed = seed,
    n_person = n_person
  )
}

.mfrmr_get_mh_dif_function <- function() {
  if (exists("analyze_dif_mh", mode = "function", inherits = TRUE)) {
    return(get("analyze_dif_mh", mode = "function", inherits = TRUE))
  }
  if (requireNamespace("mfrmr", quietly = TRUE)) {
    return(utils::getFromNamespace("analyze_dif_mh", "mfrmr"))
  }
  stop("`analyze_dif_mh()` is not available. Load or install mfrmr first.",
       call. = FALSE)
}

mfrmr_review_mh_dif_package_comparison <- function(tolerance = 1e-8) {
  if (!requireNamespace("difR", quietly = TRUE)) {
    return(structure(
      list(
        status = "skipped",
        reason = "Package `difR` is not installed.",
        comparison = data.frame()
      ),
      class = "mfrmr_mh_dif_package_comparison"
    ))
  }
  analyze_dif_mh <- .mfrmr_get_mh_dif_function()
  fixture <- .mfrmr_mh_dif_alignment_fixture()

  mfr <- analyze_dif_mh(
    fixture$long,
    person = "Person",
    item = "Item",
    score = "Score",
    group = "Group",
    reference = "Reference",
    focal = "Focal",
    matching = "total",
    p_adjust = "none",
    zero_correction = 0
  )
  difr <- difR::difMH(
    fixture$response_matrix,
    group = fixture$group,
    focal.name = "Focal",
    match = "score",
    correct = TRUE,
    exact = FALSE,
    purify = FALSE,
    p.adjust.method = NULL
  )

  difr_table <- data.frame(
    Item = colnames(fixture$response_matrix),
    DifRAlphaMH = as.numeric(difr$alphaMH),
    DifRMHDDelta = -2.35 * log(as.numeric(difr$alphaMH)),
    DifRMHChiSq = as.numeric(difr$MH),
    DifRPValue = as.numeric(difr$p.value),
    stringsAsFactors = FALSE
  )
  comparison <- merge(
    mfr$mh_table[, c("Item", "AlphaMH", "MHDDelta", "MHChiSq", "p_value")],
    difr_table,
    by = "Item",
    all = TRUE
  )
  comparison$AlphaDiff <- comparison$AlphaMH - comparison$DifRAlphaMH
  comparison$DeltaDiff <- comparison$MHDDelta - comparison$DifRMHDDelta
  comparison$ChiSqDiff <- comparison$MHChiSq - comparison$DifRMHChiSq
  comparison$PValueDiff <- comparison$p_value - comparison$DifRPValue

  diff_cols <- c("AlphaDiff", "DeltaDiff", "ChiSqDiff", "PValueDiff")
  compared_cols <- c("AlphaMH", "MHDDelta", "MHChiSq", "p_value",
                     "DifRAlphaMH", "DifRMHDDelta", "DifRMHChiSq",
                     "DifRPValue")
  finite_ok <- all(vapply(comparison[compared_cols],
                          function(z) all(is.finite(z)), logical(1)))
  max_abs_diff <- vapply(comparison[diff_cols], function(z) {
    if (all(is.na(z))) NA_real_ else max(abs(z), na.rm = TRUE)
  }, numeric(1))
  diff_ok <- finite_ok && all(max_abs_diff <= tolerance)
  structure(
    list(
      status = if (diff_ok) "ok" else "mismatch",
      tolerance = tolerance,
      difr_version = as.character(utils::packageVersion("difR")),
      fixture_seed = fixture$seed,
      fixture_n_person = fixture$n_person,
      zero_correction = 0,
      finite_ok = finite_ok,
      max_abs_diff = max_abs_diff,
      comparison = comparison
    ),
    class = "mfrmr_mh_dif_package_comparison"
  )
}

print.mfrmr_mh_dif_package_comparison <- function(x, ...) {
  cat("mfrmr MH DIF package comparison\n")
  cat("Status:", x$status, "\n")
  if (!is.null(x$reason)) {
    cat("Reason:", x$reason, "\n")
  }
  if (!is.null(x$difr_version)) {
    cat("difR version:", x$difr_version, "\n")
    cat("Fixture seed:", x$fixture_seed,
        " | N:", x$fixture_n_person,
        " | mfrmr zero_correction:", x$zero_correction, "\n")
  }
  if (!is.null(x$max_abs_diff)) {
    cat("Max absolute differences:\n")
    print(x$max_abs_diff)
  }
  if (nrow(x$comparison) > 0L) {
    print(x$comparison, row.names = FALSE)
  }
  invisible(x)
}
