#' Compare matched responses using MH or generalized CMH
#'
#' Compute a binary Mantel--Haenszel (MH) odds ratio or a generalized
#' Cochran--Mantel--Haenszel (GMH) association test for each target. Matching
#' strata are supplied explicitly; this function does not estimate ability
#' or fit an MFRM.
#'
#' @param data Long-format data with at most one row per Person and target.
#' @param person Name of the independent Person identifier column.
#' @param target Name of the item or other target identifier column.
#' @param score Name of a numeric response column: 0/1 for MH, or one of the
#'   declared `categories` for GMH. Missing values are allowed. No automatic
#'   dichotomization or category recoding is performed.
#' @param group Name of the group column. Each Person must belong to one group.
#' @param strata Names of one or more columns jointly defining exact matching
#'   strata, for example `c("Total", "Plan")`. Numeric values are not binned.
#'   Strata can differ across targets. Missing strata exclude that response.
#' @param groups Distinct group labels: exactly two in reference, focal order
#'   for MH; two or more for GMH. Data containing other groups are rejected
#'   rather than silently filtered.
#' @param inference `"exact"` (default) uses the conditional distribution given
#'   each stratum's margins. `"asymptotic"` uses a chi-squared approximation.
#'   GMH requires explicit `inference = "asymptotic"`.
#' @param correct Logical; request the continuity correction convention of
#'   [stats::mantelhaen.test()] for asymptotic inference. Ignored for exact
#'   inference; the resolved setting is saved. This does not correct for
#'   repeated ratings, matching errors or multiple testing. Not used by GMH.
#' @param conf_level Confidence level strictly between 0 and 1. Intervals are
#'   pointwise, not simultaneous across targets. Not used by GMH.
#' @param p_adjust A [stats::p.adjust()] method, default `"holm"`. The family
#'   includes every observed target, including targets with unavailable tests.
#' @param method `"mh"` (default) retains binary two-group odds-ratio inference.
#'   `"gmh"` tests general association for two or more groups/categories.
#' @param categories Distinct finite numeric category labels, default `c(0, 1)`.
#'   MH requires this default. GMH treats categories as nominal: their spacing
#'   and order do not define a trend test. Declare a common set per call.
#'
#' @details
#' With `method = "mh"`, an odds ratio above 1 means higher odds of score 1 in the reference group.
#' `MHOddsRatio` is always sum(A*D/N)/sum(B*C/N), with reference successes A,
#' reference failures B, focal successes C and focal failures D. No .5 is
#' added to zero cells. Zero and infinite estimates are retained.
#'
#' `OddsRatio` and its interval follow the selected inference: conditional
#' maximum likelihood and an exact equal-tail interval for `"exact"`, or the
#' MH estimate and a large-sample log-odds interval for `"asymptotic"`.
#' Exact two-sided p-values sum null probabilities no greater than the
#' observed statistic's probability, as in [stats::mantelhaen.test()]. They
#' need not invert the equal-tail interval. Asymptotic boundary estimates can
#' have an unavailable interval even when the test and point estimate are
#' available. No method is substituted automatically. Computation failures
#' and warnings remain visible in `Status`/`Message`.
#' Exact refers to the conditional distribution; numerical inversion uses
#' the standard R routine's root-finding precision. Its asymptotic continuity
#' correction subtracts .5 only when the absolute count contrast is at least
#' .5. Exact p-values exceeding 1 by at most 64 machine epsilons from rounding
#' are returned as 1; larger violations remain unavailable.
#' Asymptotic count products use double precision to avoid integer overflow
#' in large strata. This preserves the MH formulas and does not change the
#' independent-Person or large-sample assumptions.
#'
#' A stratum contributes information only when both groups and both score
#' categories occur. Other strata are retained with their counts and a reason
#' but contribute neither odds-ratio terms nor inference. This also removes
#' empty and singleton strata before calling the standard R calculation.
#' A single informative stratum is supported. `cases` retains every input
#' row, distinguishing missing responses/matching from uninformative strata.
#' Duplicate Person-target cells, including missing-score duplicates, are
#' rejected. Multiple targets may use the same Persons; dependence across
#' targets does not invalidate Holm adjustment of valid individual p-values.
#'
#' The binary MH inferential model requires independent Persons within each target and
#' a common conditional odds ratio across its strata. Small cells alone do
#' not invalidate the exact conditional calculation, but exact inference does
#' not establish these assumptions. The separate stratum odds ratios help
#' reveal opposing effects that a common MH effect can conceal; no test of
#' homogeneity, power guarantee, ETS label or automatic DIF/bias flag is given.
#' The number of independent Persons is not the number of rating rows.
#'
#' Interpreting conditional association as DIF additionally requires adequate
#' matching and comparable exposure. With a common binary Rasch item set and
#' invariant other items, the total including the studied item eliminates
#' the group ability distribution from that item's conditional response.
#' A rest score generally does not have this property. Totals from different
#' rater/task plans are not automatically comparable: supply justified joint
#' strata or restrict to a defensible common plan. Strata without group
#' overlap are visibly excluded. The function verifies data structure, not
#' the validity of a matching variable, invariance of other items, absence of
#' informative missingness, or independence beyond the supplied Person IDs.
#'
#' A rater scoring several criteria for the same Person produces repeated
#' Person-rater observations and cannot be pooled through this interface.
#' Renaming those observations as new Persons does not establish independence.
#' This is a separate conditional association analysis, not a new
#' `method` for [analyze_dff()]. Residual and linked-refit contrasts have
#' different targets; their agreement does not certify robustness or fairness.
#'
#' @section Generalized association:
#' GMH compares group-by-category distributions conditional on stratum margins.
#' It uses [stats::mantelhaen.test()] (the existing double-precision MH statistic
#' without continuity correction in the 2-by-2 case). Degrees of freedom are
#' `(length(groups) - 1) * (length(categories) - 1)`. This is an omnibus
#' association test, not an estimate of severity, a common odds ratio or a
#' confidence interval. No post-hoc group comparisons are supplied.
#'
#' Each contributing stratum needs at least two observed groups and categories;
#' different strata may support different subsets. Collectively all declared
#' groups and categories must occur, and the conditional covariance must be
#' nonsingular. Missing overall support or a failed calculation leaves the
#' test unavailable with a reason; levels are not silently dropped and a
#' reduced-rank test is not substituted. `NominalDF` retains the requested
#' dimension. Numerical availability does not establish a reliable chi-squared
#' approximation in sparse samples. The independent-Person and matching
#' requirements above still apply. Effects reversing across strata may cancel;
#' GMH is not a test of association heterogeneity across strata.
#'
#' @return A plain list with `table` (one row per target), `strata` (2-by-2
#'   counts and stratum odds ratios), `cases` (input-row inclusion audit),
#'   `matching` (unique complete stratum keys), `settings` and `notes`.
#'   `Stratum` indexes rows of `matching`. `Included` means inclusion in the
#'   conditional calculation, not proven substantive comparability.
#'   `PAdjusted` uses the family specified above; interval endpoints are not
#'   multiplicity-adjusted. Numerical availability does not certify a DIF
#'   inference. Save with [base::saveRDS()] and export each data frame with
#'   [utils::write.csv()]; reading these outputs performs no calculation.
#'   For GMH, `table` instead contains the omnibus statistic, degrees of
#'   freedom, p-values and availability; `strata` contains support counts.
#'   Additional `counts` gives observed/expected group-by-category counts and
#'   within-stratum group proportions, including zero cells; `group_counts`
#'   gives input, complete and included Person counts per target/group.
#'   Proportions describe the observed data, not an adjusted effect estimate.
#'   A row can contribute counts (`Included`) even when the target's full test
#'   is unavailable. See the [linking and DFF guide][mfrmr_linking_and_dff] for
#'   a worked GMH example and comparison with ordinal logistic models.
#'
#' @references
#' Holland, P. W., & Thayer, D. T. (1986). *Differential item functioning and
#' the Mantel-Haenszel procedure*. ETS Research Report RR-86-31, pp. 7--18.
#' \doi{10.1002/j.2330-8516.1986.tb00186.x}.
#' See [stats::mantelhaen.test()] for the numerical inference conventions.
#' Yesiltas, G., & Paek, I. (2020). A log-linear modeling approach for
#' differential item functioning detection in polytomously scored items.
#' *Educational and Psychological Measurement*, 80, 145--162.
#' \doi{10.1177/0013164419853000}.
#' @seealso [ordinal_logistic_table()], [analyze_dff()], [mfrmr_linking_and_dff]
#' @examples
#' # Optional workflow; run the example explicitly as shown below.
#' # example("mantel_haenszel_table", run.dontrun = TRUE)
#' \dontrun{
#' # One binary target per Person; both groups share two declared strata.
#' d <- data.frame(Person = paste0("P", 1:16), Item = "A",
#'   Group = rep(c("Reference", "Focal"), each = 8),
#'   Matching = rep(rep(c("Low", "High"), each = 4), 2),
#'   Score = c(0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1))
#' mh <- mantel_haenszel_table(d, "Person", "Item", "Score", "Group",
#'                            "Matching", c("Reference", "Focal"))
#' mh$table
#' mh$strata
#' }
#' @export
mantel_haenszel_table <- function(data, person, target, score, group, strata,
                                 groups, inference = c("exact", "asymptotic"),
                                 correct = TRUE, conf_level = .95, p_adjust = "holm",
                                 method = c("mh", "gmh"), categories = c(0, 1)) {
  method <- match.arg(method)
  inference <- match.arg(inference)
  p_adjust <- match.arg(p_adjust, stats::p.adjust.methods)
  if (method == "gmh" && inference != "asymptotic") stop(
    "GMH requires explicit `inference = \"asymptotic\"`; no exact method is substituted.", call. = FALSE)
  if (!is.numeric(categories) || is.complex(categories) || is.object(categories) ||
      !is.null(dim(categories)) || length(categories) < 2L ||
      any(!is.finite(categories)) || anyDuplicated(categories)) stop(
    "`categories` must contain at least two distinct finite numeric labels.", call. = FALSE)
  if (method == "mh" && !identical(as.numeric(categories), c(0, 1))) stop(
    "Binary MH requires `categories = c(0, 1)`; use GMH for other declared categories.", call. = FALSE)
  if (!is.data.frame(data) || !nrow(data) || anyNA(names(data)) ||
      anyDuplicated(names(data)) || any(!nzchar(names(data)))) stop(
    "`data` must be a nonempty data frame with unique nonblank column names.", call. = FALSE)
  data <- as.data.frame(data)
  for (nm in c("person", "target", "score", "group", "strata")) {
    v <- get(nm)
    if (!is.character(v) || !length(v) || anyNA(v) || any(!nzchar(v)) ||
        (nm != "strata" && length(v) != 1L)) stop(
      "`", nm, "` must name ", if (nm == "strata") "one or more columns." else "one column.",
      call. = FALSE)
  }
  selected <- c(person, target, score, group, strata)
  if (anyDuplicated(selected) || !all(selected %in% names(data))) stop(
    "Person, target, score, group and strata must name distinct existing columns.", call. = FALSE)
  if (!is.character(groups) || length(groups) < 2L ||
      (method == "mh" && length(groups) != 2L) || anyNA(groups) ||
      any(!nzchar(trimws(groups))) || anyDuplicated(groups)) stop(
    if (method == "mh") "`groups` must contain two distinct nonblank labels in reference, focal order." else
      "GMH `groups` must contain at least two distinct nonblank labels.", call. = FALSE)
  if (!is.logical(correct) || length(correct) != 1L || is.na(correct)) stop(
    "`correct` must be TRUE or FALSE.", call. = FALSE)
  if (!is.numeric(conf_level) || length(conf_level) != 1L || !is.finite(conf_level) ||
      conf_level <= 0 || conf_level >= 1) stop("`conf_level` must lie strictly between 0 and 1.", call. = FALSE)
  for (nm in c(person, target, group, strata)) {
    v <- data[[nm]]
    if (!is.null(dim(v)) || !(is.factor(v) || (!is.object(v) &&
        (is.character(v) || is.logical(v) || (is.numeric(v) && !is.complex(v))))) ||
        (!(nm %in% strata) && anyNA(v)) ||
        any(!is.na(v) & !nzchar(trimws(as.character(v)))) ||
        (is.numeric(v) && any(!is.na(v) & !is.finite(v)))) stop(
      "Identifiers/matching must be finite, nonblank atomic values; only matching may be missing: ", nm, ".",
      call. = FALSE)
    if (!(nm %in% strata) && length(unique(v)) != length(unique(as.character(v)))) stop(
      "Distinct identifiers must have distinct text labels: ", nm, ".", call. = FALSE)
  }
  y <- data[[score]]
  if (!is.numeric(y) || is.complex(y) || is.object(y) || !is.null(dim(y)) ||
      any(!is.na(y) & !(y %in% categories))) stop(
    if (method == "mh") "Scores must be numeric 0, 1 or NA; responses are not recoded." else
      "Scores must be numeric declared categories or NA; responses are not recoded.", call. = FALSE)
  if (anyDuplicated(data[c(person, target)])) stop(
    "Duplicate Person-target cells are not supported; repeated ratings are not independent Persons.", call. = FALSE)
  pid <- as.character(data[[person]]); tid <- as.character(data[[target]])
  g <- as.character(data[[group]])
  if (!all(g %in% groups)) stop("Data contain groups outside `groups`; subset explicitly.", call. = FALSE)
  if (anyDuplicated(pid[!duplicated(data[c(person, group)])])) stop(
    "Each Person must belong to exactly one group across all targets.", call. = FALSE)

  complete <- !is.na(y) & stats::complete.cases(data[strata])
  key_complete <- stats::complete.cases(data[strata])
  keyed <- dplyr::group_by(data[key_complete, strata, drop = FALSE], dplyr::across(dplyr::everything()))
  matching <- as.data.frame(dplyr::group_keys(keyed))
  rownames(matching) <- NULL
  sid <- rep(NA_integer_, nrow(data))
  sid[key_complete] <- dplyr::group_indices(keyed)
  cases <- data.frame(Row = seq_len(nrow(data)), Person = pid, Target = tid,
    Group = g, Score = y, Stratum = sid, Included = FALSE,
    Reason = ifelse(!key_complete & is.na(y), "missing_score_and_matching",
      ifelse(!key_complete, "missing_matching", ifelse(is.na(y), "missing_score", "pending"))))
  if (method == "gmh") return(.mfrm_gmh_tables(cases, matching,
    settings = list(person = person, target = target, score = score, group = group,
      strata = strata, groups = groups, categories = categories, method = method,
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
      reason <- if (a + b + c + d == 0) "no_complete_responses" else
        if (a + b == 0 || c + d == 0) "no_group_overlap" else
          if (a + c == 0 || b + d == 0) "constant_response" else "informative"
      data.frame(Target = t, Stratum = s, ReferenceSuccess = a, ReferenceFailure = b,
        FocalSuccess = c, FocalFailure = d, N = a + b + c + d,
        OddsRatio = if (reason == "informative") (as.double(a) * d) / (as.double(b) * c) else NA_real_,
        Informative = reason == "informative", Reason = reason)
    })
    dt <- if (length(ds)) do.call(rbind, ds) else data.frame(Target = character(),
      Stratum = integer(), ReferenceSuccess = integer(), ReferenceFailure = integer(),
      FocalSuccess = integer(), FocalFailure = integer(), N = integer(),
      OddsRatio = double(), Informative = logical(), Reason = character())
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
      mh <- sum(as.double(w$ReferenceSuccess) * w$FocalFailure / w$N) /
        sum(as.double(w$ReferenceFailure) * w$FocalSuccess / w$N)
      # Vector interface also supports one informative stratum, unlike the array interface.
      answer <- tryCatch(withCallingHandlers(if (inference == "exact") {
        stats::mantelhaen.test(
          factor(g[used], levels = groups), factor(y[used], levels = c(1, 0)),
          factor(sid[used]), exact = TRUE, conf.level = conf_level)
      } else {
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
        if (is.finite(p) && p > 1 && p <= 1 + 64 * .Machine$double.eps) p <- 1
        if (inference == "asymptotic") {
          statistic <- unname(answer$statistic); df <- unname(answer$parameter)
        }
        status <- if (is.finite(p) && p >= 0 && p <= 1 && !is.na(estimate) && estimate >= 0)
          if (nzchar(message)) "computed_with_warning" else "available" else "nonfinite_calculation"
        ci <- unname(answer$conf.int)
        interval_status <- if (length(ci) == 2L && !anyNA(ci) &&
          ci[1] >= 0 && is.finite(ci[1]) && ci[2] >= ci[1]) "available" else "unavailable_boundary_or_numerical"
        if (interval_status == "available") { lower <- ci[1]; upper <- ci[2] }
        if (status == "nonfinite_calculation") { estimate <- p <- statistic <- df <- NA_real_ }
      }
    }
    summaries[[i]] <- data.frame(Target = t, Reference = groups[1], Focal = groups[2],
      NReference = sum(g[used] == groups[1]), NFocal = sum(g[used] == groups[2]),
      InputRows = length(rows), CompleteRows = sum(complete[rows]), ExcludedRows = length(rows) - length(used),
      InformativeStrata = sum(dt$Informative), MHOddsRatio = mh, OddsRatio = estimate,
      Lower = lower, Upper = upper, ConfidenceLevel = conf_level,
      EstimateMethod = if (inference == "exact") "conditional_mle" else "mantel_haenszel",
      ChiSquared = statistic, DF = df, PValue = p, Status = status,
      IntervalStatus = interval_status, Message = message)
  }
  out <- do.call(rbind, summaries)
  out$PAdjusted <- stats::p.adjust(out$PValue, method = p_adjust, n = nrow(out))
  list(table = out, strata = do.call(rbind, details), cases = cases, matching = matching,
    settings = list(person = person, target = target, score = score, group = group,
      strata = strata, groups = groups, inference = inference,
      continuity_correction = if (inference == "exact") FALSE else correct,
      conf_level = conf_level, p_adjust = p_adjust, adjustment_family_size = nrow(out)),
    notes = c(
      "Odds ratios compare score-1 odds in the reference group to those in the focal group.",
      "Inference assumes independent Persons and a common conditional odds ratio; matching validity and comparable exposure are not certified.",
      "Exact equal-tail intervals are pointwise and need not invert the probability-ordered two-sided p-value; no simultaneous intervals are supplied.",
      "Strata without both groups and both response categories are retained but excluded from the conditional calculation.",
      "Crossing stratum effects can cancel; nondetection does not establish invariance, and statistical association alone does not establish bias.",
      "This does not extend residual/refit DFF inference or support pooled repeated Person-target ratings."))
}

# Generalized association is an omnibus test, not a scalar odds-ratio estimate.
.mfrm_gmh_tables <- function(cases, matching, settings) {
  groups <- settings$groups; categories <- settings$categories
  ng <- length(groups); nc <- length(categories)
  nominal_df <- (ng - 1L) * (nc - 1L)
  complete <- !is.na(cases$Score) & !is.na(cases$Stratum)
  targets <- unique(cases$Target)
  summaries <- details <- counts <- group_counts <- vector("list", length(targets))
  for (i in seq_along(targets)) {
    t <- targets[i]; rows <- which(cases$Target == t)
    ids <- sort(unique(cases$Stratum[rows][!is.na(cases$Stratum[rows])]))
    tables <- ds <- cs <- vector("list", length(ids))
    for (j in seq_along(ids)) {
      ix <- rows[complete[rows] & cases$Stratum[rows] %in% ids[j]]
      tab <- table(factor(cases$Group[ix], levels = groups),
        factor(match(cases$Score[ix], categories), levels = seq_len(nc)))
      storage.mode(tab) <- "double"
      tables[[j]] <- tab
      r <- rowSums(tab); c <- colSums(tab); n <- sum(tab)
      reason <- if (!n) "no_complete_responses" else
        if (sum(r > 0) < 2L) "no_group_overlap" else
          if (sum(c > 0) < 2L) "constant_response" else "informative"
      ds[[j]] <- data.frame(Target = t, Stratum = ids[j], N = n,
        GroupsObserved = sum(r > 0), CategoriesObserved = sum(c > 0),
        Informative = reason == "informative", Reason = reason)
      cs[[j]] <- data.frame(Target = t, Stratum = ids[j],
        Group = rep(groups, times = nc), Score = rep(categories, each = ng),
        Observed = as.vector(tab),
        Expected = if (n) as.vector(outer(r, c) / n) else rep(NA_real_, ng * nc),
        Proportion = ifelse(rep(r, times = nc) > 0,
          as.vector(tab) / rep(r, times = nc), NA_real_),
        Included = reason == "informative")
    }
    dt <- if (length(ds)) do.call(rbind, ds) else data.frame(Target = character(),
      Stratum = integer(), N = double(), GroupsObserved = integer(),
      CategoriesObserved = integer(), Informative = logical(), Reason = character())
    counts[[i]] <- if (length(cs)) do.call(rbind, cs) else data.frame(Target = character(),
      Stratum = integer(), Group = character(), Score = double(), Observed = double(),
      Expected = double(), Proportion = double(), Included = logical())
    details[[i]] <- dt
    valid <- rows[complete[rows]]
    cases$Reason[valid] <- dt$Reason[match(cases$Stratum[valid], dt$Stratum)]
    used <- valid[cases$Stratum[valid] %in% dt$Stratum[dt$Informative]]
    cases$Included[used] <- TRUE
    group_counts[[i]] <- data.frame(Target = t, Group = groups,
      InputRows = tabulate(match(cases$Group[rows], groups), nbins = ng),
      CompleteRows = tabulate(match(cases$Group[valid], groups), nbins = ng),
      IncludedRows = tabulate(match(cases$Group[used], groups), nbins = ng))
    statistic <- p <- df <- NA_real_
    status <- "no_informative_strata"; message <- ""
    if (length(used)) {
      if (!all(groups %in% cases$Group[used])) {
        status <- "incomplete_group_support"
        message <- "Not all declared groups occur in informative strata."
      } else if (!all(categories %in% cases$Score[used])) {
        status <- "incomplete_category_support"
        message <- "Not all declared categories occur in informative strata."
      } else {
        answer <- tryCatch(withCallingHandlers({
          informative <- tables[dt$Informative]
          if (ng == 2L && nc == 2L) {
            cells <- as.data.frame(do.call(rbind, lapply(informative, as.vector)))
            names(cells) <- c("ReferenceSuccess", "FocalSuccess", "ReferenceFailure", "FocalFailure")
            .mfrm_mh_asymptotic(cells, correct = FALSE, conf_level = .95)
          } else if (length(informative) > 1L) {
            stats::mantelhaen.test(array(unlist(informative, use.names = FALSE),
              dim = c(ng, nc, length(informative))), exact = FALSE, correct = FALSE)
          } else {
            # R's vector interface, unlike its array interface, admits one stratum.
            stats::mantelhaen.test(factor(cases$Group[used], levels = groups),
              factor(match(cases$Score[used], categories), levels = seq_len(nc)),
              cases$Stratum[used], exact = FALSE, correct = FALSE)
          }
        }, warning = function(w) {
          message <<- paste(c(message[nzchar(message)], conditionMessage(w)), collapse = "; ")
          invokeRestart("muffleWarning")
        }), error = function(e) {
          message <<- conditionMessage(e)
          NULL
        })
        status <- "computation_failed"
        if (!is.null(answer) && is.finite(answer$statistic) && answer$statistic >= 0 &&
            is.finite(answer$p.value) && answer$p.value >= 0 && answer$p.value <= 1 &&
            isTRUE(unname(answer$parameter) == nominal_df)) {
          statistic <- unname(answer$statistic); p <- answer$p.value
          df <- unname(answer$parameter)
          status <- if (nzchar(message)) "computed_with_warning" else "available"
        }
      }
    }
    summaries[[i]] <- data.frame(Target = t, NGroups = ng, NCategories = nc,
      InputRows = length(rows), CompleteRows = length(valid), IncludedRows = length(used),
      ExcludedRows = length(rows) - length(used), InformativeStrata = sum(dt$Informative),
      TestMethod = "generalized_cmh", NominalDF = nominal_df,
      ChiSquared = statistic, DF = df, PValue = p, Status = status, Message = message)
  }
  out <- do.call(rbind, summaries)
  out$PAdjusted <- stats::p.adjust(out$PValue, method = settings$p_adjust, n = nrow(out))
  settings$adjustment_family_size <- nrow(out)
  list(table = out, strata = do.call(rbind, details), cases = cases, matching = matching,
    counts = do.call(rbind, counts), group_counts = do.call(rbind, group_counts),
    settings = settings, notes = c(
      "GMH tests general conditional association; categories are nominal and no severity, common odds ratio or confidence interval is estimated.",
      "Inference is asymptotic with (groups - 1) * (categories - 1) degrees of freedom; no continuity correction or exact fallback is used.",
      "Independent Persons within each target, defensible matching and comparable exposure are required; repeated Person-target ratings are not supported.",
      "Strata need at least two observed groups and categories; all declared groups and categories must be represented collectively, with nonsingular covariance.",
      "Expected counts condition on each stratum's margins; Proportion describes its observed within-group category distribution, not a matched effect estimate.",
      "Sparse counts can undermine the chi-squared approximation even when a result is numerically available; no universal minimum sample size is certified.",
      "Opposing effects across strata can cancel; no homogeneity test, pairwise post-hoc tests or automatic DIF/bias flag is supplied."))
}

# The vector backend reconstructs integer tables; its count products can
# overflow even when the input roster and every inferential result fit in memory.
.mfrm_mh_asymptotic <- function(counts, correct, conf_level) {
  a <- as.double(counts$ReferenceSuccess); b <- as.double(counts$ReferenceFailure)
  c <- as.double(counts$FocalSuccess); d <- as.double(counts$FocalFailure)
  n <- a + b + c + d
  contrast <- sum(a - (a + b) * (a + c) / n)
  variance <- sum((a + b) * (c + d) * (a + c) * (b + d) / (n^2 * (n - 1)))
  correction <- if (isTRUE(correct) && abs(contrast) >= .5) .5 else 0
  statistic <- (abs(contrast) - correction)^2 / variance
  diagonal <- sum(a * d / n)
  off_diagonal <- sum(b * c / n)
  odds_ratio <- diagonal / off_diagonal
  interval <- c(NA_real_, NA_real_)
  if (diagonal > 0 && off_diagonal > 0) {
    # Robins--Breslow--Greenland variance of the log MH odds ratio.
    log_variance <- sum((a + d) * a * d / n^2) / (2 * diagonal^2) +
      sum(((a + d) * b * c + (b + c) * a * d) / n^2) / (2 * diagonal * off_diagonal) +
      sum((b + c) * b * c / n^2) / (2 * off_diagonal^2)
    interval <- exp(log(odds_ratio) + c(-1, 1) *
      stats::qnorm((1 - conf_level) / 2, lower.tail = FALSE) * sqrt(log_variance))
  }
  list(estimate = odds_ratio, statistic = statistic, parameter = 1,
    p.value = stats::pchisq(statistic, 1, lower.tail = FALSE), conf.int = interval)
}
