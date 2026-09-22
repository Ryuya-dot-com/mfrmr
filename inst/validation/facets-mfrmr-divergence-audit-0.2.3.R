# Repository-only FACETS/mfrmr divergence audit for mfrmr 0.2.3.
#
# This script does not run FACETS and is not installed with the package. It
# audits an already completed paired pilot before any numerical difference is
# treated as evidence about the estimator. In particular, it checks the
# estimand contract (category support and retained scale dimension), the
# constrained main-effect design rank, and the extreme-score convention.

mfrmr_divergence_sum_zero_columns <- function(x, prefix) {
  x <- factor(as.character(x), levels = sort(unique(as.character(x))))
  indicator <- stats::model.matrix(~ x - 1L)
  if (ncol(indicator) <= 1L) {
    return(matrix(numeric(), nrow = length(x), ncol = 0L))
  }
  out <- indicator[, seq_len(ncol(indicator) - 1L), drop = FALSE] -
    indicator[, ncol(indicator)]
  colnames(out) <- paste0(prefix, "::", levels(x)[seq_len(ncol(out))])
  out
}

mfrmr_divergence_design_audit <- function(data,
                                           person = "participant_id",
                                           centered_facets = c("rater_id", "criteria")) {
  required <- c(person, centered_facets)
  if (!all(required %in% names(data))) {
    stop("Design data lack: ", paste(setdiff(required, names(data)), collapse = ", "))
  }

  person_factor <- factor(
    as.character(data[[person]]),
    levels = sort(unique(as.character(data[[person]])))
  )
  design <- stats::model.matrix(~ person_factor - 1L)
  colnames(design) <- paste0(person, "::", levels(person_factor))
  for (facet in centered_facets) {
    design <- cbind(
      design,
      mfrmr_divergence_sum_zero_columns(data[[facet]], facet)
    )
  }

  singular <- svd(design, nu = 0L, nv = 0L)$d
  tolerance <- max(dim(design)) * max(singular) * .Machine$double.eps
  rank <- sum(singular > tolerance)
  smallest <- if (length(singular)) min(singular) else NA_real_
  condition <- if (!length(singular) || smallest <= 0) Inf else max(singular) / smallest

  data.frame(
    Rows = nrow(design),
    FreeColumns = ncol(design),
    Rank = rank,
    Nullity = ncol(design) - rank,
    MinSingularValue = smallest,
    ConditionNumber = condition,
    FullColumnRank = rank == ncol(design),
    AuditScope = paste0(
      "main-effect location design: ", person,
      " noncentered; ", paste(centered_facets, collapse = ", "),
      " sum-to-zero"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_divergence_declared_categories <- function(anchor_lines) {
  model_lines <- grep(";\\s*R[0-9]+K?\\s*$", anchor_lines, value = TRUE)
  if (!length(model_lines)) {
    return(NA_integer_)
  }
  match <- regexec("R([0-9]+)K?\\s*$", model_lines[1L])
  value <- regmatches(model_lines[1L], match)[[1L]]
  if (length(value) < 2L) NA_integer_ else as.integer(value[2L]) + 1L
}

mfrmr_divergence_retained_scales <- function(anchor_lines) {
  headers <- grep(
    "^Rating \\(or partial credit\\) scale = ",
    anchor_lines
  )
  if (!length(headers)) {
    return(data.frame(
      Scale = character(), RetainedCategories = integer(),
      stringsAsFactors = FALSE
    ))
  }

  result <- lapply(seq_along(headers), function(index) {
    start <- headers[index]
    next_header <- if (index < length(headers)) headers[index + 1L] - 1L else length(anchor_lines)
    terminator <- which(seq_along(anchor_lines) > start & trimws(anchor_lines) == "*")
    stop_at <- if (length(terminator)) min(next_header, terminator[1L]) else next_header
    block <- anchor_lines[seq.int(start, stop_at)]
    scale <- sub(
      "^Rating \\(or partial credit\\) scale = ([^,]+),.*$",
      "\\1", block[1L]
    )
    categories <- grep("^\\s*-?[0-9]+\\s*=", block, value = TRUE)
    data.frame(
      Scale = scale,
      RetainedCategories = length(categories),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, result)
}

mfrmr_divergence_category_audit <- function(data, model, anchor_path) {
  if (!all(c("criteria", "score") %in% names(data))) {
    stop("Category data must contain criteria and score.")
  }
  anchor_lines <- readLines(anchor_path, warn = FALSE, encoding = "UTF-8")
  declared <- mfrmr_divergence_declared_categories(anchor_lines)
  retained <- mfrmr_divergence_retained_scales(anchor_lines)
  model <- toupper(model)

  if (identical(model, "PCM")) {
    levels <- sort(unique(as.character(data$criteria)))
    support <- do.call(rbind, lapply(seq_along(levels), function(index) {
      score <- sort(unique(data$score[data$criteria == levels[index]]))
      data.frame(
        ScaleScope = levels[index],
        InputSupportedCategories = length(score),
        InputCategoryValues = paste(score, collapse = ";"),
        stringsAsFactors = FALSE
      )
    }))
    if (nrow(retained) == nrow(support)) {
      retained$ScaleScope <- levels
    } else {
      retained$ScaleScope <- retained$Scale
    }
  } else {
    score <- sort(unique(data$score))
    support <- data.frame(
      ScaleScope = "common",
      InputSupportedCategories = length(score),
      InputCategoryValues = paste(score, collapse = ";"),
      stringsAsFactors = FALSE
    )
    if (nrow(retained)) retained$ScaleScope <- "common"
  }

  merged <- merge(support, retained, by = "ScaleScope", all.x = TRUE, sort = FALSE)
  merged$DeclaredCategories <- declared
  merged$InputSupportComplete <- merged$InputSupportedCategories == declared
  merged$FACETSScaleDimensionComplete <-
    !is.na(merged$RetainedCategories) & merged$RetainedCategories == declared
  merged$CategoryContractComparable <-
    merged$InputSupportComplete & merged$FACETSScaleDimensionComplete
  merged[, c(
    "ScaleScope", "DeclaredCategories", "InputSupportedCategories",
    "InputCategoryValues", "RetainedCategories", "InputSupportComplete",
    "FACETSScaleDimensionComplete", "CategoryContractComparable"
  )]
}

mfrmr_divergence_extreme_rows <- function(data, declared_min = 0L,
                                           declared_max = 3L) {
  split_score <- split(data$score, as.character(data$participant_id))
  status <- vapply(split_score, function(score) {
    if (length(score) && all(score == declared_min)) {
      "extreme_low"
    } else if (length(score) && all(score == declared_max)) {
      "extreme_high"
    } else {
      "nonextreme"
    }
  }, character(1L))
  data.frame(
    element_label = names(status),
    ExtremeClass = unname(status),
    stringsAsFactors = FALSE
  )
}

mfrmr_divergence_person_audit <- function(data, mfrmr_estimates,
                                           facets_truth, model, scenario,
                                           declared_min = 0L,
                                           declared_max = 3L) {
  ours <- subset(
    mfrmr_estimates,
    Model == model & Scenario == scenario & facet == "participant_id",
    select = c("element_label", "estimate")
  )
  names(ours)[2L] <- "MfrmrEstimate"
  theirs <- subset(
    facets_truth,
    facet == "participant_id",
    select = c("element_label", "estimate")
  )
  names(theirs)[2L] <- "FACETSEstimate"
  rows <- Reduce(
    function(x, y) merge(x, y, by = "element_label", all = FALSE),
    list(
      ours, theirs,
      mfrmr_divergence_extreme_rows(data, declared_min, declared_max)
    )
  )
  rows$Difference <- rows$MfrmrEstimate - rows$FACETSEstimate
  rows$AbsoluteDifference <- abs(rows$Difference)
  rows$Model <- model
  rows$Scenario <- scenario
  rows$PrimaryMeasureComparable <- rows$ExtremeClass == "nonextreme"
  rows$ComparisonReason <- ifelse(
    rows$PrimaryMeasureComparable,
    "same finite JML person-measure class",
    "FACETS adjusted extreme display measure versus unbounded JML estimand"
  )
  rows
}

mfrmr_divergence_person_summary <- function(rows) {
  if (!nrow(rows)) return(data.frame())
  groups <- split(rows, rows$ExtremeClass)
  do.call(rbind, lapply(groups, function(x) {
    data.frame(
      Model = x$Model[1L],
      Scenario = x$Scenario[1L],
      ExtremeClass = x$ExtremeClass[1L],
      Persons = nrow(x),
      MAE = mean(x$AbsoluteDifference),
      MaxAbsoluteDifference = max(x$AbsoluteDifference),
      PrimaryMeasureComparable = all(x$PrimaryMeasureComparable),
      stringsAsFactors = FALSE
    )
  }))
}

mfrmr_divergence_read_csv <- function(path) {
  utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
}

mfrmr_divergence_parse_args <- function(args) {
  result <- list(facets_work_dir = NULL, work_dir = NULL)
  for (arg in args) {
    if (grepl("^--facets-work-dir=", arg)) {
      result$facets_work_dir <- sub("^--facets-work-dir=", "", arg)
    } else if (grepl("^--work-dir=", arg)) {
      result$work_dir <- sub("^--work-dir=", "", arg)
    }
  }
  result
}

mfrmr_divergence_run <- function(facets_work_dir, work_dir) {
  facets_work_dir <- normalizePath(facets_work_dir, mustWork = TRUE)
  if (!dir.exists(work_dir)) dir.create(work_dir, recursive = TRUE)
  work_dir <- normalizePath(work_dir, mustWork = TRUE)
  manifest <- mfrmr_divergence_read_csv(
    file.path(facets_work_dir, "scenario_manifest.csv")
  )
  estimates <- mfrmr_divergence_read_csv(
    file.path(facets_work_dir, "mfrmr_estimates.csv")
  )

  contract_rows <- list()
  design_rows <- list()
  person_rows <- list()
  person_summary <- list()
  index <- 0L
  for (row in seq_len(nrow(manifest))) {
    model <- as.character(manifest$Model[row])
    scenario <- as.character(manifest$Scenario[row])
    stem <- paste0("dataset-", scenario)
    data_path <- file.path(facets_work_dir, tolower(model), "data", paste0(stem, ".csv"))
    output_dir <- file.path(facets_work_dir, tolower(model), "facets_output", stem)
    anchor_path <- file.path(output_dir, "anchor.anc")
    truth_path <- file.path(output_dir, "truth_comparison.csv")
    if (!all(file.exists(c(data_path, anchor_path, truth_path)))) next

    index <- index + 1L
    data <- mfrmr_divergence_read_csv(data_path)
    category <- mfrmr_divergence_category_audit(data, model, anchor_path)
    category$Model <- model
    category$Scenario <- scenario
    contract_rows[[index]] <- category[, c("Model", "Scenario", setdiff(names(category), c("Model", "Scenario")))]

    design <- mfrmr_divergence_design_audit(data)
    design$Model <- model
    design$Scenario <- scenario
    design_rows[[index]] <- design[, c("Model", "Scenario", setdiff(names(design), c("Model", "Scenario")))]

    facets_truth <- mfrmr_divergence_read_csv(truth_path)
    persons <- mfrmr_divergence_person_audit(
      data, estimates, facets_truth, model, scenario
    )
    person_rows[[index]] <- persons
    person_summary[[index]] <- mfrmr_divergence_person_summary(persons)
  }

  contract <- do.call(rbind, contract_rows)
  design <- do.call(rbind, design_rows)
  persons <- do.call(rbind, person_rows)
  person_groups <- do.call(rbind, person_summary)
  scenario_contract <- stats::aggregate(
    CategoryContractComparable ~ Model + Scenario,
    data = contract,
    FUN = all
  )
  names(scenario_contract)[3L] <- "CategoryContractComparable"
  scenario <- merge(
    design, scenario_contract,
    by = c("Model", "Scenario"), all.x = TRUE, sort = FALSE
  )
  scenario$CommonParameterComparisonEligible <-
    scenario$FullColumnRank & scenario$CategoryContractComparable
  scenario$PersonComparisonRule <- ifelse(
    scenario$CommonParameterComparisonEligible,
    "compare nonextreme persons; report extreme status separately",
    "do not interpret raw parameter differences until contract/rank failure is resolved"
  )
  scenario$ReasonCodes <- paste0(
    ifelse(scenario$FullColumnRank, "", "rank_deficient;"),
    ifelse(scenario$CategoryContractComparable, "", "category_map_or_step_dimension_mismatch;"),
    "extreme_score_convention_separate"
  )

  utils::write.csv(contract, file.path(work_dir, "category_contract.csv"), row.names = FALSE)
  utils::write.csv(design, file.path(work_dir, "design_rank.csv"), row.names = FALSE)
  utils::write.csv(persons, file.path(work_dir, "person_difference_rows.csv"), row.names = FALSE)
  utils::write.csv(person_groups, file.path(work_dir, "person_difference_by_extreme.csv"), row.names = FALSE)
  utils::write.csv(scenario, file.path(work_dir, "comparison_eligibility.csv"), row.names = FALSE)

  summary <- data.frame(
    PilotRows = nrow(scenario),
    FullRankRows = sum(scenario$FullColumnRank),
    CategoryComparableRows = sum(scenario$CategoryContractComparable),
    EligibleRows = sum(scenario$CommonParameterComparisonEligible),
    RankDeficientRows = sum(!scenario$FullColumnRank),
    CategoryMismatchRows = sum(!scenario$CategoryContractComparable),
    ExtremePersonRows = sum(persons$ExtremeClass != "nonextreme"),
    stringsAsFactors = FALSE
  )
  utils::write.csv(summary, file.path(work_dir, "audit_summary.csv"), row.names = FALSE)
  invisible(list(
    summary = summary, category_contract = contract, design_rank = design,
    person_rows = persons, person_summary = person_groups,
    comparison_eligibility = scenario
  ))
}

if (sys.nframe() == 0L) {
  cli <- mfrmr_divergence_parse_args(commandArgs(trailingOnly = TRUE))
  if (is.null(cli$facets_work_dir) || is.null(cli$work_dir)) {
    stop("Use --facets-work-dir=<completed paired pilot> --work-dir=<audit output>.")
  }
  result <- mfrmr_divergence_run(cli$facets_work_dir, cli$work_dir)
  print(result$summary)
}
