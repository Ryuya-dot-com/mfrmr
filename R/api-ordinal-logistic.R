ordinal_logistic_table <- function(data, person, target, score, group, matching, groups, categories, 
    p_adjust = "holm") {
    p_adjust <- match.arg(p_adjust, stats::p.adjust.methods)
    if (!is.data.frame(data) || !nrow(data) || anyNA(names(data)) || anyDuplicated(names(data)) || any(!nzchar(names(data)))) 
        stop("`data` must be a nonempty data frame with unique nonblank column names.", call. = FALSE)
    data <- as.data.frame(data)
    for (nm in c("person", "target", "score", "group", "matching")) {
        v <- get(nm)
        if (!is.character(v) || length(v) != 1L || is.na(v) || !nzchar(v)) 
            stop("`", nm, "` must name one column.", call. = FALSE)
    }
    selected <- c(person, target, score, group, matching)
    if (anyDuplicated(selected) || !all(selected %in% names(data))) 
        stop("Person, target, score, group and matching must name distinct existing columns.", call. = FALSE)
    if (!is.character(groups) || length(groups) < 2L || anyNA(groups) || any(!nzchar(trimws(groups))) || 
        anyDuplicated(groups)) 
        stop("`groups` must contain at least two distinct nonblank labels, with the reference first.", 
            call. = FALSE)
    for (nm in c(person, target, group)) {
        v <- data[[nm]]
        if (!is.null(dim(v)) || !(is.factor(v) || (!is.object(v) && (is.character(v) || is.logical(v) || 
            (is.numeric(v) && !is.complex(v))))) || anyNA(v) || any(!nzchar(trimws(as.character(v)))) || 
            (is.numeric(v) && any(!is.finite(v))) || length(unique(v)) != length(unique(as.character(v)))) 
            stop("Identifiers must have distinct finite, nonblank atomic labels: ", nm, ".", call. = FALSE)
    }
    x <- data[[matching]]
    if (!is.numeric(x) || is.complex(x) || is.object(x) || !is.null(dim(x)) || any(!is.na(x) & !is.finite(x))) 
        stop("Matching must be finite numeric values or NA.", call. = FALSE)
    y <- data[[score]]
    if (is.factor(y)) 
        y <- as.character(y)
    if (is.factor(categories)) 
        categories <- as.character(categories)
    valid_labels <- function(v) !is.object(v) && is.null(dim(v)) && (is.character(v) || (is.numeric(v) && 
        !is.complex(v) && all(is.na(v) | is.finite(v))))
    if (!valid_labels(y) || !valid_labels(categories) || length(categories) < 2L || anyNA(categories) || 
        anyDuplicated(categories) || is.numeric(y) != is.numeric(categories)) 
        stop("Scores and `categories` must have matching numeric or character types; declare at least two distinct nonmissing categories.", 
            call. = FALSE)
    code <- match(y, categories)
    if (any(!is.na(y) & is.na(code))) 
        stop("Scores outside declared `categories`.", call. = FALSE)
    if (anyDuplicated(data[c(person, target)])) 
        stop("Duplicate Person-target cells are not supported; repeated ratings are not independent Persons.", 
            call. = FALSE)
    pid <- as.character(data[[person]])
    tid <- as.character(data[[target]])
    g <- as.character(data[[group]])
    if (!all(g %in% groups)) 
        stop("Data contain groups outside `groups`; subset explicitly.", call. = FALSE)
    if (anyDuplicated(pid[!duplicated(data[c(person, group)])])) 
        stop("Each Person must belong to exactly one group across all targets.", call. = FALSE)
    if (!requireNamespace("ordinal", quietly = TRUE)) 
        stop("Install the optional package `ordinal` to use `ordinal_logistic_table()`.", call. = FALSE)
    k <- length(categories)
    ng <- length(groups)
    complete <- !is.na(code) & !is.na(x)
    cases <- data.frame(Row = seq_len(nrow(data)), Person = pid, Target = tid, Group = g, Score = y, 
        Matching = x, Included = FALSE, Reason = ifelse(is.na(code) & is.na(x), "missing_score_and_matching", 
            ifelse(is.na(x), "missing_matching", ifelse(is.na(code), "missing_score", "pending"))))
    targets <- unique(tid)
    comparisons <- models <- coefficients <- contrasts <- diagnostics <- matches <- vector("list", length(targets))
    for (i in seq_along(targets)) {
        t <- targets[i]
        rows <- which(tid == t)
        used <- rows[complete[rows]]
        counts <- tabulate(code[used], nbins = k)
        group_x <- lapply(groups, function(label) x[used[g[used] == label]])
        ranges <- lapply(group_x, function(v) if (length(v)) 
            range(v)
        else c(NA_real_, NA_real_))
        lo <- max(unlist(lapply(ranges, `[`, 1L)))
        hi <- min(unlist(lapply(ranges, `[`, 2L)))
        center <- scale <- NA_real_
        reason <- if (!length(used)) 
            "no_complete_responses"
        else if (any(lengths(group_x) == 0L)) 
            "missing_group"
        else if (any(counts == 0)) 
            "unused_category"
        else if (any(vapply(ranges, function(r) r[1] == r[2], logical(1)))) 
            "constant_matching_within_group"
        else if (lo >= hi) 
            "no_matching_range_overlap"
        else "eligible"
        if (reason == "eligible") {
            center <- min(x[used])/2 + max(x[used])/2
            scale <- max(abs(x[used] - center))
            if (!is.finite(scale) || scale <= 0) 
                reason <- "invalid_matching_scale"
        }
        matches[[i]] <- do.call(rbind, lapply(seq.int(2L, ng), function(h) data.frame(Target = t, Reference = groups[1], 
            Focal = groups[h], InputRows = length(rows), CompleteRows = length(used), NReference = length(group_x[[1]]), 
            NFocal = length(group_x[[h]]), ReferenceMin = ranges[[1]][1], ReferenceMax = ranges[[1]][2], 
            FocalMin = ranges[[h]][1], FocalMax = ranges[[h]][2], OverlapMin = lo, OverlapMax = hi, Center = center, 
            Scale = scale, Status = reason)))
        cases$Reason[used] <- if (reason == "eligible") 
            "model_input"
        else reason
        cases$Included[used] <- reason == "eligible"
        fits <- setNames(vector("list", 3L + (k > 2L)), c("M1", "M2", "M3", if (k > 2L) "NonPO"))
        ll0 <- if (length(used)) 
            sum(counts[counts > 0] * log(counts[counts > 0]/length(used)))
        else NA_real_
        forms <- list(y ~ z, y ~ z + g, y ~ z * g, y ~ 1)
        model_data <- if (reason == "eligible") 
            data.frame(y = ordered(code[used], levels = seq_len(k)), z = (x[used] - center)/scale, g = if (ng == 
                2L) 
                as.integer(g[used] == groups[2])
            else factor(match(g[used], groups), levels = seq_len(ng)))
        else NULL
        if (ng > 2L && !is.null(model_data)) 
            stats::contrasts(model_data$g) <- stats::contr.treatment(as.character(seq_len(ng)), base = 1L)
        for (j in seq_along(fits)) {
            f <- mfrm_ordinal_fit(model_data, forms[[j]], nominal = if (j == 4L) 
                ~z * g
            else NULL, unavailable = reason)
            f$row$Target <- t
            f$row$Model <- names(fits)[j]
            f$row$N <- length(used)
            f$row$NagelkerkeR2 <- if (f$row$Status == "available") 
                (-expm1(2 * (ll0 - f$row$LogLik)/length(used)))/(-expm1(2 * ll0/length(used)))
            else NA_real_
            fits[[j]] <- f
        }
        models[[i]] <- do.call(rbind, lapply(fits, `[[`, "row"))
        coefficients[[i]] <- do.call(rbind, lapply(names(fits), function(name) {
            f <- fits[[name]]
            if (f$row$Status != "available") 
                return(NULL)
            data.frame(Target = t, Model = name, Parameter = names(f$coefficients), Estimate = unname(f$coefficients))
        }))
        pairs <- list(Uniform = c("M1", "M2"), Nonuniform = c("M2", "M3"), Joint = c("M1", "M3"))
        comparisons[[i]] <- do.call(rbind, lapply(names(pairs), function(name) {
            p <- pairs[[name]]
            out <- mfrm_ordinal_lr(fits[[p[1]]]$row, fits[[p[2]]]$row)
            data.frame(Target = t, Comparison = name, Reduced = p[1], Full = p[2], out, DeltaNagelkerkeR2 = if (out$Status == 
                "available") 
                fits[[p[2]]]$row$NagelkerkeR2 - fits[[p[1]]]$row$NagelkerkeR2
            else NA_real_)
        }))
        diagnostics[[i]] <- data.frame(Target = t, if (k > 2L) 
            mfrm_ordinal_lr(fits$M3$row, fits$NonPO$row)
        else data.frame(ChiSquared = NA_real_, DF = NA_real_, PValue = NA_real_, Status = "not_applicable_binary"))
        points <- if (reason == "eligible") 
            c(lo, lo/2 + hi/2, hi)
        else rep(NA_real_, 3)
        contrasts[[i]] <- do.call(rbind, lapply(seq.int(2L, ng), function(h) {
            logor <- rep(NA_real_, 3)
            if (fits$M3$row$Status == "available") {
                b <- fits$M3$coefficients
                term <- if (ng == 2L) 
                  "g"
                else paste0("g", h)
                logor <- unname(-(b[term] + b[paste0("z:", term)] * (points - center)/scale))
            }
            data.frame(Target = t, Reference = groups[1], Focal = groups[h], Position = c("OverlapMin", 
                "OverlapMid", "OverlapMax"), Matching = points, LogOddsRatio = logor, OddsRatio = exp(logor), 
                Status = fits$M3$row$Status)
        }))
    }
    out <- lapply(list(table = comparisons, models = models, coefficients = coefficients, contrasts = contrasts, 
        proportional_odds = diagnostics, matching = matches), function(x) {
        ans <- do.call(rbind, x)
        rownames(ans) <- NULL
        ans
    })
    if (is.null(out$coefficients)) 
        out$coefficients <- data.frame(Target = character(), Model = character(), Parameter = character(), 
            Estimate = double())
    out$table$PAdjusted <- stats::p.adjust(out$table$PValue, method = p_adjust, n = nrow(out$table))
    out$proportional_odds$PAdjusted <- stats::p.adjust(out$proportional_odds$PValue, method = p_adjust, 
        n = length(targets))
    out$cases <- cases
    out$settings <- list(person = person, target = target, score = score, group = group, matching = matching, 
        groups = groups, categories = categories, p_adjust = p_adjust, adjustment_family_size = nrow(out$table), 
        diagnostic_family_size = length(targets), link = "logit", group_coding = if (ng == 2L) c(reference = 0L, 
            focal = 1L) else stats::setNames(c("reference", paste0("g", seq.int(2L, ng))), groups), backend = "ordinal::clm", 
        backend_version = as.character(utils::packageVersion("ordinal")), gradient_tolerance = 1e-06, 
        newton_step_tolerance = 1e-04, hessian_relative_tolerance = sqrt(.Machine$double.eps))
    out$notes <- c("Likelihood-ratio p-values are asymptotic; numerical availability does not certify DIF inference.", 
        "Contrasts are reference/focal upper-tail odds ratios from M3 within overlapping matching ranges.", 
        "Proportional-odds diagnostics and matching-by-group interactions address different assumptions.", 
        "Matching validity, common exposure, independence and sparse-sample inference require substantive justification.", 
        "Repeated Person-target ratings and estimation of matching/calibration uncertainty are not supported.")
    out
}

mfrm_ordinal_fit <- function(data, formula, nominal, unavailable) {
    row <- data.frame(LogLik = NA_real_, Parameters = NA_real_, Convergence = NA_integer_, MaxGradient = NA_real_, 
        MinEigenvalue = NA_real_, ConditionNumber = NA_real_, MaxNewtonStep = NA_real_, Status = unavailable, 
        Message = "")
    if (is.null(data)) 
        return(list(row = row, coefficients = NULL))
    warnings <- character()
    fit <- tryCatch(withCallingHandlers(ordinal::clm(formula, data = data, nominal = nominal, link = "logit", 
        threshold = "flexible", control = ordinal::clm.control(convergence = "silent")), warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
    }), error = function(e) {
        warnings <<- c(warnings, conditionMessage(e))
        NULL
    })
    row$Message <- paste(unique(warnings), collapse = "; ")
    row$Status <- "computation_failed"
    if (is.null(fit)) 
        return(list(row = row, coefficients = NULL))
    row$LogLik <- fit$logLik
    row$Parameters <- fit$edf
    row$Convergence <- fit$convergence$code
    row$MaxGradient <- fit$maxGradient
    row$Message <- paste(c(warnings, fit$convergence$messages, fit$convergence$alg.message), collapse = "; ")
    finite <- all(is.finite(c(fit$coefficients, fit$Hessian, fit$gradient, fit$logLik)))
    eigenvalues <- if (finite) 
        eigen(fit$Hessian, symmetric = TRUE, only.values = TRUE)$values
    else NA_real_
    row$MinEigenvalue <- min(eigenvalues)
    row$ConditionNumber <- max(eigenvalues)/min(eigenvalues)
    row$MaxNewtonStep <- if (finite) 
        tryCatch(max(abs(solve(fit$Hessian, fit$gradient))), error = function(e) Inf)
    else NA_real_
    row$Status <- if (any(unlist(fit$aliased))) 
        "aliased_parameters"
    else if (!finite) 
        "nonfinite_calculation"
    else if (fit$convergence$code != 0L) 
        "nonconvergence_or_nonunique"
    else if (length(warnings)) 
        "backend_warning"
    else if (row$MinEigenvalue <= sqrt(.Machine$double.eps) * max(1, max(eigenvalues))) 
        "ill_conditioned_hessian"
    else if (row$MaxGradient > 1e-06 || !is.finite(row$MaxNewtonStep) || row$MaxNewtonStep > 1e-04) 
        "stationarity_not_established"
    else "available"
    list(row = row, coefficients = fit$coefficients)
}

mfrm_ordinal_lr <- function(reduced, full) {
    out <- data.frame(ChiSquared = NA_real_, DF = NA_real_, PValue = NA_real_, Status = "model_unavailable")
    if (reduced$Status != "available" || full$Status != "available") 
        return(out)
    delta <- full$LogLik - reduced$LogLik
    tol <- 64 * .Machine$double.eps * max(1, abs(c(reduced$LogLik, full$LogLik)))
    df <- full$Parameters - reduced$Parameters
    if (delta < -tol || df <= 0) {
        out$Status <- "invalid_nested_comparison"
        return(out)
    }
    out$ChiSquared <- 2 * max(0, delta)
    out$DF <- df
    out$PValue <- stats::pchisq(out$ChiSquared, df, lower.tail = FALSE)
    out$Status <- "available"
    out
}
