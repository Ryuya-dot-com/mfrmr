to_float <- function(value) {
    out <- suppressWarnings(as.numeric(value))
    ifelse(length(out) == 0, NA_real_, out)
}

fmt_count <- function(value) {
    val <- to_float(value)
    if (!is.finite(val)) 
        return("NA")
    if (abs(val - round(val)) < 1e-06) 
        return(as.character(as.integer(round(val))))
    sprintf("%.0f", val)
}

marginal_coverage_notes <- function(coverage) {
    if (is.null(coverage) || !nrow(coverage)) 
        return(character(0))
    vapply(seq_len(nrow(coverage)), function(i) {
        r <- coverage[i, ]
        if (!r$Classified) {
            sprintf("%s: no classifications available; %d of %d unavailable.", r$Screen, r$Unclassified, 
                r$Total)
        }
        else {
            sprintf("%s: %d flagged among %d classified; %d of %d unavailable.", r$Screen, r$Flagged, 
                r$Classified, r$Unclassified, r$Total)
        }
    }, character(1))
}

mfrm_misfit_thresholds <- function(lower = NULL, upper = NULL) {
    lo <- if (is.null(lower)) {
        suppressWarnings(as.numeric(getOption("mfrmr.misfit_lower", 0.5)))
    }
    else {
        suppressWarnings(as.numeric(lower[1]))
    }
    up <- if (is.null(upper)) {
        suppressWarnings(as.numeric(getOption("mfrmr.misfit_upper", 1.5)))
    }
    else {
        suppressWarnings(as.numeric(upper[1]))
    }
    if (!is.finite(lo) || !is.finite(up) || lo <= 0 || up <= 0 || lo >= up) {
        stop("`mfrm_misfit_thresholds` requires `0 < lower < upper`. ", "Got lower = ", lo, ", upper = ", 
            up, ".", call. = FALSE)
    }
    c(lower = lo, upper = up)
}

format_fit_bound <- function(x) {
    text <- sprintf("%.15g", x)
    for (fmt in c("%.16g", "%.17g", "%.20g")) {
        more <- is.finite(x) & suppressWarnings(as.numeric(text)) != x
        if (!any(more)) 
            break
        text[more] <- sprintf(fmt, x[more])
    }
    text
}

format_fit_mnsq <- function(x, band) {
    text <- sprintf("%.2f", x)
    for (fmt in c("%.4f", "exact")) {
        shown <- suppressWarnings(as.numeric(text))
        near <- is.finite(x) & (sign(x - band[1]) != sign(shown - band[1]) | sign(x - band[2]) != sign(shown - 
            band[2]))
        if (!any(near)) 
            break
        text[near] <- if (fmt == "exact") 
            format_fit_bound(x[near])
        else sprintf(fmt, x[near])
    }
    text
}

fit_zstd_flag <- function(infit, outfit, cut = 2, inclusive = TRUE) {
    infit[!is.finite(infit)] <- NA_real_
    outfit[!is.finite(outfit)] <- NA_real_
    if (!inclusive) 
        return(abs(infit) > cut | abs(outfit) > cut)
    abs(infit) >= cut | abs(outfit) >= cut
}

fit_screening_summary <- function(tbl, band = mfrm_misfit_thresholds()) {
    n <- nrow(tbl) %||% 0L
    column <- function(name) suppressWarnings(as.numeric(tbl[[name]] %||% rep(NA_real_, n)))
    infit <- column("Infit")
    outfit <- column("Outfit")
    inz <- column("InfitZSTD")
    outz <- column("OutfitZSTD")
    infit[!is.finite(infit) | infit < 0] <- NA_real_
    outfit[!is.finite(outfit) | outfit < 0] <- NA_real_
    inz[!is.finite(inz)] <- NA_real_
    outz[!is.finite(outz)] <- NA_real_
    complete_mnsq <- !is.na(infit) & !is.na(outfit)
    complete_z <- !is.na(inz) & !is.na(outz)
    flags <- data.frame(MeanSquare = infit < band["lower"] | infit > band["upper"] | outfit < band["lower"] | 
        outfit > band["upper"], ZSTD2 = fit_zstd_flag(inz, outz), ZSTD3 = fit_zstd_flag(inz, outz, 3))
    counts <- do.call(rbind, lapply(seq_along(flags), function(i) {
        flag <- flags[[i]]
        available <- sum(!is.na(flag))
        data.frame(Screen = c(sprintf("MnSq outside [%s, %s]", format_fit_bound(band["lower"]), format_fit_bound(band["upper"])), 
            "|ZSTD| >= 2", "|ZSTD| >= 3")[i], Elements = n, Classified = available, Unclassified = sum(is.na(flag)), 
            IncompleteStatistics = sum(!(if (i == 1L) complete_mnsq else complete_z)), Flagged = if (available) 
                sum(flag, na.rm = TRUE)
            else NA_integer_, FlagRate = if (n > 0L && available == n) 
                mean(flag)
            else NA_real_)
    }))
    list(flags = flags, counts = counts, max_abs_z = pmax(abs(inz), abs(outz)), max_mnsq_deviation = pmax(abs(infit - 
        1), abs(outfit - 1)))
}

fit_screening_note <- function(row) {
    if (row$Classified == 0L) {
        return(sprintf("%s: no elements could be classified (%d elements total).", row$Screen, row$Elements))
    }
    text <- sprintf("%s: %d of %d classified elements flagged; %d of %d elements unclassified.", row$Screen, 
        row$Flagged, row$Classified, row$Unclassified, row$Elements)
    if (row$IncompleteStatistics > 0L) {
        text <- paste(text, sprintf("%d elements have an unavailable statistic.", row$IncompleteStatistics))
    }
    text
}

mfrm_centering_scope <- function(config) {
    config$centering_scope %||% if (length(config$facet_specs)) 
        "remainder"
    else "not_recorded"
}
