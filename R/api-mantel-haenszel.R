mantel_haenszel_table <- function(data, person, target, score, group, strata, groups, inference = c("exact", 
    "asymptotic"), correct = TRUE, conf_level = 0.95, p_adjust = "holm", method = c("mh", "gmh"), categories = c(0, 
    1)) {
    method <- match.arg(method)
    inference <- match.arg(inference)
    p_adjust <- match.arg(p_adjust, stats::p.adjust.methods)
    if (method == "gmh" && inference != "asymptotic") 
        stop("GMH requires explicit `inference = \"asymptotic\"`; no exact method is substituted.", call. = FALSE)
    if (!is.numeric(categories) || is.complex(categories) || is.object(categories) || !is.null(dim(categories)) || 
        length(categories) < 2L || any(!is.finite(categories)) || anyDuplicated(categories)) 
        stop("`categories` must contain at least two distinct finite numeric labels.", call. = FALSE)
    if (method == "mh" && !identical(as.numeric(categories), c(0, 1))) 
        stop("Binary MH requires `categories = c(0, 1)`; use GMH for other declared categories.", call. = FALSE)
    if (!is.data.frame(data) || !nrow(data) || anyNA(names(data)) || anyDuplicated(names(data)) || any(!nzchar(names(data)))) 
        stop("`data` must be a nonempty data frame with unique nonblank column names.", call. = FALSE)
    data <- as.data.frame(data)
    for (nm in c("person", "target", "score", "group", "strata")) {
        v <- get(nm)
        if (!is.character(v) || !length(v) || anyNA(v) || any(!nzchar(v)) || (nm != "strata" && length(v) != 
            1L)) 
            stop("`", nm, "` must name ", if (nm == "strata") 
                "one or more columns."
            else "one column.", call. = FALSE)
    }
    selected <- c(person, target, score, group, strata)
    if (anyDuplicated(selected) || !all(selected %in% names(data))) 
        stop("Person, target, score, group and strata must name distinct existing columns.", call. = FALSE)
    if (!is.character(groups) || length(groups) < 2L || (method == "mh" && length(groups) != 2L) || anyNA(groups) || 
        any(!nzchar(trimws(groups))) || anyDuplicated(groups)) 
        stop(if (method == "mh") 
            "`groups` must contain two distinct nonblank labels in reference, focal order."
        else "GMH `groups` must contain at least two distinct nonblank labels.", call. = FALSE)
    if (!is.logical(correct) || length(correct) != 1L || is.na(correct)) 
        stop("`correct` must be TRUE or FALSE.", call. = FALSE)
    if (!is.numeric(conf_level) || length(conf_level) != 1L || !is.finite(conf_level) || conf_level <= 
        0 || conf_level >= 1) 
        stop("`conf_level` must lie strictly between 0 and 1.", call. = FALSE)
    for (nm in c(person, target, group, strata)) {
        v <- data[[nm]]
        if (!is.null(dim(v)) || !(is.factor(v) || (!is.object(v) && (is.character(v) || is.logical(v) || 
            (is.numeric(v) && !is.complex(v))))) || (!(nm %in% strata) && anyNA(v)) || any(!is.na(v) & 
            !nzchar(trimws(as.character(v)))) || (is.numeric(v) && any(!is.na(v) & !is.finite(v)))) 
            stop("Identifiers/matching must be finite, nonblank atomic values; only matching may be missing: ", 
                nm, ".", call. = FALSE)
        if (!(nm %in% strata) && length(unique(v)) != length(unique(as.character(v)))) 
            stop("Distinct identifiers must have distinct text labels: ", nm, ".", call. = FALSE)
    }
    y <- data[[score]]
    if (!is.numeric(y) || is.complex(y) || is.object(y) || !is.null(dim(y)) || any(!is.na(y) & !(y %in% 
        categories))) 
        stop(if (method == "mh") 
            "Scores must be numeric 0, 1 or NA; responses are not recoded."
        else "Scores must be numeric declared categories or NA; responses are not recoded.", call. = FALSE)
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
    complete <- !is.na(y) & stats::complete.cases(data[strata])
    key_complete <- stats::complete.cases(data[strata])
    keyed <- dplyr::group_by(data[key_complete, strata, drop = FALSE], dplyr::across(dplyr::everything()))
    matching <- as.data.frame(dplyr::group_keys(keyed))
    rownames(matching) <- NULL
    sid <- rep(NA_integer_, nrow(data))
    sid[key_complete] <- dplyr::group_indices(keyed)
    cases <- data.frame(Row = seq_len(nrow(data)), Person = pid, Target = tid, Group = g, Score = y, 
        Stratum = sid, Included = FALSE, Reason = ifelse(!key_complete & is.na(y), "missing_score_and_matching", 
            ifelse(!key_complete, "missing_matching", ifelse(is.na(y), "missing_score", "pending"))))
    if (method == "gmh") 
        return(.mfrm_gmh_tables(cases, matching, settings = list(person = person, target = target, score = score, 
            group = group, strata = strata, groups = groups, categories = categories, method = method, 
            inference = inference, continuity_correction = FALSE, p_adjust = p_adjust)))
    targets <- unique(tid)
    summaries <- details <- vector("list", length(targets))
    for (i in seq_along(targets)) {
        t <- targets[i]
        rows <- which(tid == t)
        stratum_ids <- sort(unique(sid[rows][!is.na(sid[rows])]))
        ds <- lapply(stratum_ids, function(s) {
            ix <- rows[complete[rows] & sid[rows] %in% s]
            a <- sum(g[ix] == groups[1] & y[ix] == 1)
            b <- sum(g[ix] == groups[1] & y[ix] == 0)
            c <- sum(g[ix] == groups[2] & y[ix] == 1)
            d <- sum(g[ix] == groups[2] & y[ix] == 0)
            reason <- if (a + b + c + d == 0) 
                "no_complete_responses"
            else if (a + b == 0 || c + d == 0) 
                "no_group_overlap"
            else if (a + c == 0 || b + d == 0) 
                "constant_response"
            else "informative"
            data.frame(Target = t, Stratum = s, ReferenceSuccess = a, ReferenceFailure = b, FocalSuccess = c, 
                FocalFailure = d, N = a + b + c + d, OddsRatio = if (reason == "informative") 
                  (as.double(a) * d)/(as.double(b) * c)
                else NA_real_, Informative = reason == "informative", Reason = reason)
        })
        dt <- if (length(ds)) 
            do.call(rbind, ds)
        else data.frame(Target = character(), Stratum = integer(), ReferenceSuccess = integer(), ReferenceFailure = integer(), 
            FocalSuccess = integer(), FocalFailure = integer(), N = integer(), OddsRatio = double(), 
            Informative = logical(), Reason = character())
        details[[i]] <- dt
        valid <- rows[complete[rows]]
        cases$Reason[valid] <- dt$Reason[match(sid[valid], dt$Stratum)]
        used <- valid[sid[valid] %in% dt$Stratum[dt$Informative]]
        cases$Included[used] <- TRUE
        mh <- estimate <- lower <- upper <- p <- statistic <- df <- NA_real_
        status <- interval_status <- "no_informative_strata"
        message <- ""
        if (length(used)) {
            w <- dt[dt$Informative, ]
            mh <- sum(as.double(w$ReferenceSuccess) * w$FocalFailure/w$N)/sum(as.double(w$ReferenceFailure) * 
                w$FocalSuccess/w$N)
            answer <- tryCatch(withCallingHandlers(if (inference == "exact") {
                stats::mantelhaen.test(factor(g[used], levels = groups), factor(y[used], levels = c(1, 
                  0)), factor(sid[used]), exact = TRUE, conf.level = conf_level)
            }
            else {
                .mfrm_mh_asymptotic(w, correct = correct, conf_level = conf_level)
            }, warning = function(w) {
                message <<- paste(c(message[nzchar(message)], conditionMessage(w)), collapse = "; ")
                invokeRestart("muffleWarning")
            }), error = function(e) {
                message <<- conditionMessage(e)
                NULL
            })
            status <- interval_status <- "computation_failed"
            if (!is.null(answer)) {
                estimate <- unname(answer$estimate)
                p <- answer$p.value
                if (is.finite(p) && p > 1 && p <= 1 + 64 * .Machine$double.eps) 
                  p <- 1
                if (inference == "asymptotic") {
                  statistic <- unname(answer$statistic)
                  df <- unname(answer$parameter)
                }
                status <- if (is.finite(p) && p >= 0 && p <= 1 && !is.na(estimate) && estimate >= 0) 
                  if (nzchar(message)) 
                    "computed_with_warning"
                  else "available"
                else "nonfinite_calculation"
                ci <- unname(answer$conf.int)
                interval_status <- if (length(ci) == 2L && !anyNA(ci) && ci[1] >= 0 && is.finite(ci[1]) && 
                  ci[2] >= ci[1]) 
                  "available"
                else "unavailable_boundary_or_numerical"
                if (interval_status == "available") {
                  lower <- ci[1]
                  upper <- ci[2]
                }
                if (status == "nonfinite_calculation") {
                  estimate <- p <- statistic <- df <- NA_real_
                }
            }
        }
        summaries[[i]] <- data.frame(Target = t, Reference = groups[1], Focal = groups[2], NReference = sum(g[used] == 
            groups[1]), NFocal = sum(g[used] == groups[2]), InputRows = length(rows), CompleteRows = sum(complete[rows]), 
            ExcludedRows = length(rows) - length(used), InformativeStrata = sum(dt$Informative), MHOddsRatio = mh, 
            OddsRatio = estimate, Lower = lower, Upper = upper, ConfidenceLevel = conf_level, EstimateMethod = if (inference == 
                "exact") 
                "conditional_mle"
            else "mantel_haenszel", ChiSquared = statistic, DF = df, PValue = p, Status = status, IntervalStatus = interval_status, 
            Message = message)
    }
    out <- do.call(rbind, summaries)
    out$PAdjusted <- stats::p.adjust(out$PValue, method = p_adjust, n = nrow(out))
    list(table = out, strata = do.call(rbind, details), cases = cases, matching = matching, settings = list(person = person, 
        target = target, score = score, group = group, strata = strata, groups = groups, inference = inference, 
        continuity_correction = if (inference == "exact") FALSE else correct, conf_level = conf_level, 
        p_adjust = p_adjust, adjustment_family_size = nrow(out)), notes = c("Odds ratios compare score-1 odds in the reference group to those in the focal group.", 
        "Inference assumes independent Persons and a common conditional odds ratio; matching validity and comparable exposure are not certified.", 
        "Exact equal-tail intervals are pointwise and need not invert the probability-ordered two-sided p-value; no simultaneous intervals are supplied.", 
        "Strata without both groups and both response categories are retained but excluded from the conditional calculation.", 
        "Crossing stratum effects can cancel; nondetection does not establish invariance, and statistical association alone does not establish bias.", 
        "This does not extend residual/refit DFF inference or support pooled repeated Person-target ratings."))
}

.mfrm_gmh_tables <- function(cases, matching, settings) {
    groups <- settings$groups
    categories <- settings$categories
    ng <- length(groups)
    nc <- length(categories)
    nominal_df <- (ng - 1L) * (nc - 1L)
    complete <- !is.na(cases$Score) & !is.na(cases$Stratum)
    targets <- unique(cases$Target)
    summaries <- details <- counts <- group_counts <- vector("list", length(targets))
    for (i in seq_along(targets)) {
        t <- targets[i]
        rows <- which(cases$Target == t)
        ids <- sort(unique(cases$Stratum[rows][!is.na(cases$Stratum[rows])]))
        tables <- ds <- cs <- vector("list", length(ids))
        for (j in seq_along(ids)) {
            ix <- rows[complete[rows] & cases$Stratum[rows] %in% ids[j]]
            tab <- table(factor(cases$Group[ix], levels = groups), factor(match(cases$Score[ix], categories), 
                levels = seq_len(nc)))
            storage.mode(tab) <- "double"
            tables[[j]] <- tab
            r <- rowSums(tab)
            c <- colSums(tab)
            n <- sum(tab)
            reason <- if (!n) 
                "no_complete_responses"
            else if (sum(r > 0) < 2L) 
                "no_group_overlap"
            else if (sum(c > 0) < 2L) 
                "constant_response"
            else "informative"
            ds[[j]] <- data.frame(Target = t, Stratum = ids[j], N = n, GroupsObserved = sum(r > 0), CategoriesObserved = sum(c > 
                0), Informative = reason == "informative", Reason = reason)
            cs[[j]] <- data.frame(Target = t, Stratum = ids[j], Group = rep(groups, times = nc), Score = rep(categories, 
                each = ng), Observed = as.vector(tab), Expected = if (n) 
                as.vector(outer(r, c)/n)
            else rep(NA_real_, ng * nc), Proportion = ifelse(rep(r, times = nc) > 0, as.vector(tab)/rep(r, 
                times = nc), NA_real_), Included = reason == "informative")
        }
        dt <- if (length(ds)) 
            do.call(rbind, ds)
        else data.frame(Target = character(), Stratum = integer(), N = double(), GroupsObserved = integer(), 
            CategoriesObserved = integer(), Informative = logical(), Reason = character())
        counts[[i]] <- if (length(cs)) 
            do.call(rbind, cs)
        else data.frame(Target = character(), Stratum = integer(), Group = character(), Score = double(), 
            Observed = double(), Expected = double(), Proportion = double(), Included = logical())
        details[[i]] <- dt
        valid <- rows[complete[rows]]
        cases$Reason[valid] <- dt$Reason[match(cases$Stratum[valid], dt$Stratum)]
        used <- valid[cases$Stratum[valid] %in% dt$Stratum[dt$Informative]]
        cases$Included[used] <- TRUE
        group_counts[[i]] <- data.frame(Target = t, Group = groups, InputRows = tabulate(match(cases$Group[rows], 
            groups), nbins = ng), CompleteRows = tabulate(match(cases$Group[valid], groups), nbins = ng), 
            IncludedRows = tabulate(match(cases$Group[used], groups), nbins = ng))
        statistic <- p <- df <- NA_real_
        status <- "no_informative_strata"
        message <- ""
        if (length(used)) {
            if (!all(groups %in% cases$Group[used])) {
                status <- "incomplete_group_support"
                message <- "Not all declared groups occur in informative strata."
            }
            else if (!all(categories %in% cases$Score[used])) {
                status <- "incomplete_category_support"
                message <- "Not all declared categories occur in informative strata."
            }
            else {
                answer <- tryCatch(withCallingHandlers({
                  informative <- tables[dt$Informative]
                  if (ng == 2L && nc == 2L) {
                    cells <- as.data.frame(do.call(rbind, lapply(informative, as.vector)))
                    names(cells) <- c("ReferenceSuccess", "FocalSuccess", "ReferenceFailure", "FocalFailure")
                    .mfrm_mh_asymptotic(cells, correct = FALSE, conf_level = 0.95)
                  }
                  else if (length(informative) > 1L) {
                    stats::mantelhaen.test(array(unlist(informative, use.names = FALSE), dim = c(ng, 
                      nc, length(informative))), exact = FALSE, correct = FALSE)
                  }
                  else {
                    stats::mantelhaen.test(factor(cases$Group[used], levels = groups), factor(match(cases$Score[used], 
                      categories), levels = seq_len(nc)), cases$Stratum[used], exact = FALSE, correct = FALSE)
                  }
                }, warning = function(w) {
                  message <<- paste(c(message[nzchar(message)], conditionMessage(w)), collapse = "; ")
                  invokeRestart("muffleWarning")
                }), error = function(e) {
                  message <<- conditionMessage(e)
                  NULL
                })
                status <- "computation_failed"
                if (!is.null(answer) && is.finite(answer$statistic) && answer$statistic >= 0 && is.finite(answer$p.value) && 
                  answer$p.value >= 0 && answer$p.value <= 1 && isTRUE(unname(answer$parameter) == nominal_df)) {
                  statistic <- unname(answer$statistic)
                  p <- answer$p.value
                  df <- unname(answer$parameter)
                  status <- if (nzchar(message)) 
                    "computed_with_warning"
                  else "available"
                }
            }
        }
        summaries[[i]] <- data.frame(Target = t, NGroups = ng, NCategories = nc, InputRows = length(rows), 
            CompleteRows = length(valid), IncludedRows = length(used), ExcludedRows = length(rows) - 
                length(used), InformativeStrata = sum(dt$Informative), TestMethod = "generalized_cmh", 
            NominalDF = nominal_df, ChiSquared = statistic, DF = df, PValue = p, Status = status, Message = message)
    }
    out <- do.call(rbind, summaries)
    out$PAdjusted <- stats::p.adjust(out$PValue, method = settings$p_adjust, n = nrow(out))
    settings$adjustment_family_size <- nrow(out)
    list(table = out, strata = do.call(rbind, details), cases = cases, matching = matching, counts = do.call(rbind, 
        counts), group_counts = do.call(rbind, group_counts), settings = settings, notes = c("GMH tests general conditional association; categories are nominal and no severity, common odds ratio or confidence interval is estimated.", 
        "Inference is asymptotic with (groups - 1) * (categories - 1) degrees of freedom; no continuity correction or exact fallback is used.", 
        "Independent Persons within each target, defensible matching and comparable exposure are required; repeated Person-target ratings are not supported.", 
        "Strata need at least two observed groups and categories; all declared groups and categories must be represented collectively, with nonsingular covariance.", 
        "Expected counts condition on each stratum's margins; Proportion describes its observed within-group category distribution, not a matched effect estimate.", 
        "Sparse counts can undermine the chi-squared approximation even when a result is numerically available; no universal minimum sample size is certified.", 
        "Opposing effects across strata can cancel; no homogeneity test, pairwise post-hoc tests or automatic DIF/bias flag is supplied."))
}

.mfrm_mh_asymptotic <- function(counts, correct, conf_level) {
    a <- as.double(counts$ReferenceSuccess)
    b <- as.double(counts$ReferenceFailure)
    c <- as.double(counts$FocalSuccess)
    d <- as.double(counts$FocalFailure)
    n <- a + b + c + d
    contrast <- sum(a - (a + b) * (a + c)/n)
    variance <- sum((a + b) * (c + d) * (a + c) * (b + d)/(n^2 * (n - 1)))
    correction <- if (isTRUE(correct) && abs(contrast) >= 0.5) 
        0.5
    else 0
    statistic <- (abs(contrast) - correction)^2/variance
    diagonal <- sum(a * d/n)
    off_diagonal <- sum(b * c/n)
    odds_ratio <- diagonal/off_diagonal
    interval <- c(NA_real_, NA_real_)
    if (diagonal > 0 && off_diagonal > 0) {
        log_variance <- sum((a + d) * a * d/n^2)/(2 * diagonal^2) + sum(((a + d) * b * c + (b + c) * 
            a * d)/n^2)/(2 * diagonal * off_diagonal) + sum((b + c) * b * c/n^2)/(2 * off_diagonal^2)
        interval <- exp(log(odds_ratio) + c(-1, 1) * stats::qnorm((1 - conf_level)/2, lower.tail = FALSE) * 
            sqrt(log_variance))
    }
    list(estimate = odds_ratio, statistic = statistic, parameter = 1, p.value = stats::pchisq(statistic, 
        1, lower.tail = FALSE), conf.int = interval)
}
