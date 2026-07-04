# Simulation review for the 0.2.2 MH DIF helper.
#
# This script is intentionally not part of the CRAN-time test suite. It uses
# seeded simulated data to probe direction, false-positive behavior, matching
# sensitivity, sparse-cell correction, explicit dichotomization, and the legacy
# wrapper contract for `analyze_dif_mh()`.

.mfrmr_mh_sim_get_function <- function(name) {
  if (exists(name, mode = "function", inherits = TRUE)) {
    return(get(name, mode = "function", inherits = TRUE))
  }
  if (requireNamespace("mfrmr", quietly = TRUE)) {
    return(utils::getFromNamespace(name, "mfrmr"))
  }
  stop("`", name, "()` is not available. Load or install mfrmr first.",
       call. = FALSE)
}

.mfrmr_mh_sim_binary_data <- function(seed,
                                      n_person = 800L,
                                      n_item = 8L,
                                      dif_shift = 0,
                                      target = "I6",
                                      difficulty_span = 1.4) {
  set.seed(seed)
  persons <- sprintf("P%04d", seq_len(n_person))
  group <- rep(c("Reference", "Focal"), each = n_person / 2L)
  theta <- stats::rnorm(n_person)
  item_names <- paste0("I", seq_len(n_item))
  difficulty <- seq(-difficulty_span, difficulty_span, length.out = n_item)

  resp <- vapply(seq_along(item_names), function(j) {
    shift <- if (identical(item_names[j], target)) {
      ifelse(group == "Focal", dif_shift, 0)
    } else {
      0
    }
    stats::rbinom(
      n_person,
      size = 1L,
      prob = stats::plogis(theta - difficulty[j] - shift)
    )
  }, numeric(n_person))
  colnames(resp) <- item_names

  data.frame(
    Person = rep(persons, each = n_item),
    Item = rep(item_names, times = n_person),
    Score = as.vector(t(resp)),
    Group = rep(group, each = n_item),
    stringsAsFactors = FALSE
  )
}

.mfrmr_mh_sim_one_binary <- function(seed,
                                     dif_shift,
                                     scenario,
                                     expected_direction = NA_character_,
                                     matching = "restscore",
                                     zero_correction = 0.5,
                                     n_person = 800L,
                                     n_item = 8L,
                                     target = "I6",
                                     difficulty_span = 1.4) {
  analyze_dif_mh <- .mfrmr_mh_sim_get_function("analyze_dif_mh")
  dat <- .mfrmr_mh_sim_binary_data(
    seed = seed,
    n_person = n_person,
    n_item = n_item,
    dif_shift = dif_shift,
    target = target,
    difficulty_span = difficulty_span
  )
  mh <- analyze_dif_mh(
    dat,
    person = "Person",
    item = "Item",
    score = "Score",
    group = "Group",
    reference = "Reference",
    focal = "Focal",
    matching = matching,
    p_adjust = "holm",
    zero_correction = zero_correction
  )
  target_row <- mh$mh_table[mh$mh_table$Item == target, , drop = FALSE]
  anchor_rows <- mh$mh_table[mh$mh_table$Item != target, , drop = FALSE]
  target_positive <- identical(target_row$Classification[1], "Screen positive")
  anchor_positive <- anchor_rows$Classification == "Screen positive"
  data.frame(
    Scenario = scenario,
    Seed = seed,
    DifShift = dif_shift,
    Matching = matching,
    ZeroCorrection = zero_correction,
    TargetItem = target,
    AlphaMH = target_row$AlphaMH[1],
    MHDDelta = target_row$MHDDelta[1],
    MHChiSq = target_row$MHChiSq[1],
    PAdjusted = target_row$p_adjusted[1],
    Direction = target_row$Direction[1],
    ExpectedDirection = expected_direction,
    TargetScreenPositive = target_positive,
    DirectionCorrect = if (is.na(expected_direction)) {
      NA
    } else {
      identical(target_row$Direction[1], expected_direction)
    },
    AnchorAnyScreenPositive = any(anchor_positive, na.rm = TRUE),
    AnchorScreenPositiveRate = mean(anchor_positive, na.rm = TRUE),
    stringsAsFactors = FALSE
  )
}

.mfrmr_mh_sim_scenario_summary <- function(rows) {
  split_rows <- split(rows, rows$Scenario)
  out <- lapply(split_rows, function(x) {
    data.frame(
      Scenario = x$Scenario[1],
      DifShift = x$DifShift[1],
      Replications = nrow(x),
      TargetScreenPositiveRate = mean(x$TargetScreenPositive, na.rm = TRUE),
      DirectionAccuracy = if (all(is.na(x$DirectionCorrect))) {
        NA_real_
      } else {
        mean(x$DirectionCorrect, na.rm = TRUE)
      },
      MeanTargetMHDDelta = mean(x$MHDDelta, na.rm = TRUE),
      MedianAdjustedP = stats::median(x$PAdjusted, na.rm = TRUE),
      AnchorFamilyPositiveRate = mean(x$AnchorAnyScreenPositive, na.rm = TRUE),
      MeanAnchorPositiveRate = mean(x$AnchorScreenPositiveRate, na.rm = TRUE),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, out)
}

.mfrmr_mh_sim_matching_sensitivity <- function(seeds,
                                               dif_shift = 0.7,
                                               n_person = 800L,
                                               target = "I6") {
  rest <- do.call(rbind, lapply(seeds, function(seed) {
    .mfrmr_mh_sim_one_binary(
      seed = seed,
      dif_shift = dif_shift,
      scenario = "matching_restscore",
      expected_direction = "harder_for_focal",
      matching = "restscore",
      n_person = n_person,
      target = target
    )
  }))
  total <- do.call(rbind, lapply(seeds, function(seed) {
    .mfrmr_mh_sim_one_binary(
      seed = seed,
      dif_shift = dif_shift,
      scenario = "matching_total",
      expected_direction = "harder_for_focal",
      matching = "total",
      n_person = n_person,
      target = target
    )
  }))
  data.frame(
    Replications = length(seeds),
    DeltaCorrelation = stats::cor(rest$MHDDelta, total$MHDDelta),
    MeanAbsDeltaDifference = mean(abs(rest$MHDDelta - total$MHDDelta)),
    DirectionAgreement = mean(rest$Direction == total$Direction),
    ScreenPositiveAgreement = mean(rest$TargetScreenPositive ==
                                     total$TargetScreenPositive),
    RestscorePositiveRate = mean(rest$TargetScreenPositive),
    TotalPositiveRate = mean(total$TargetScreenPositive),
    stringsAsFactors = FALSE
  )
}

.mfrmr_mh_sim_sparse_correction <- function(seed = 91101L) {
  analyze_dif_mh <- .mfrmr_mh_sim_get_function("analyze_dif_mh")
  dat <- .mfrmr_mh_sim_binary_data(
    seed = seed,
    n_person = 96L,
    n_item = 8L,
    dif_shift = 0.8,
    target = "I6",
    difficulty_span = 3.0
  )
  no_cc <- analyze_dif_mh(
    dat, "Person", "Item", "Score", "Group",
    reference = "Reference",
    focal = "Focal",
    matching = "restscore",
    p_adjust = "holm",
    zero_correction = 0
  )
  cc <- analyze_dif_mh(
    dat, "Person", "Item", "Score", "Group",
    reference = "Reference",
    focal = "Focal",
    matching = "restscore",
    p_adjust = "holm",
    zero_correction = 0.5
  )
  merged <- merge(
    no_cc$mh_table[, c("Item", "AlphaMH", "MHDDelta", "MHChiSq", "p_value")],
    cc$mh_table[, c("Item", "AlphaMH", "MHDDelta", "MHChiSq", "p_value")],
    by = "Item",
    suffixes = c("_NoCorrection", "_HalfCorrection")
  )
  data.frame(
    Seed = seed,
    Items = nrow(merged),
    FiniteAlphaNoCorrection = sum(is.finite(merged$AlphaMH_NoCorrection)),
    FiniteAlphaHalfCorrection = sum(is.finite(merged$AlphaMH_HalfCorrection)),
    FiniteDeltaNoCorrection = sum(is.finite(merged$MHDDelta_NoCorrection)),
    FiniteDeltaHalfCorrection = sum(is.finite(merged$MHDDelta_HalfCorrection)),
    MaxChiSqDifference = max(abs(merged$MHChiSq_NoCorrection -
                                   merged$MHChiSq_HalfCorrection),
                             na.rm = TRUE),
    MaxPValueDifference = max(abs(merged$p_value_NoCorrection -
                                    merged$p_value_HalfCorrection),
                              na.rm = TRUE),
    stringsAsFactors = FALSE
  )
}

.mfrmr_mh_sim_polytomous_data <- function(seed = 8128L,
                                          n_person = 600L,
                                          n_item = 6L,
                                          dif_shift = 0.75,
                                          target = "I4") {
  set.seed(seed)
  persons <- sprintf("P%04d", seq_len(n_person))
  group <- rep(c("Reference", "Focal"), each = n_person / 2L)
  theta <- stats::rnorm(n_person)
  item_names <- paste0("I", seq_len(n_item))
  difficulty <- seq(-1.2, 1.2, length.out = n_item)
  thresholds <- c(-0.4, 0.7)
  score <- vapply(seq_along(item_names), function(j) {
    shift <- if (identical(item_names[j], target)) {
      ifelse(group == "Focal", dif_shift, 0)
    } else {
      0
    }
    latent <- theta - difficulty[j] - shift + stats::rlogis(n_person)
    as.integer(latent > thresholds[1]) + as.integer(latent > thresholds[2])
  }, integer(n_person))
  colnames(score) <- item_names
  data.frame(
    Person = rep(persons, each = n_item),
    Item = rep(item_names, times = n_person),
    Score = as.vector(t(score)),
    Group = rep(group, each = n_item),
    stringsAsFactors = FALSE
  )
}

.mfrmr_mh_sim_polytomous_check <- function(seed = 8128L) {
  analyze_dif_mh <- .mfrmr_mh_sim_get_function("analyze_dif_mh")
  dat <- .mfrmr_mh_sim_polytomous_data(seed = seed)
  no_threshold_error <- tryCatch(
    {
      analyze_dif_mh(dat, "Person", "Item", "Score", "Group")
      NA_character_
    },
    error = function(e) conditionMessage(e)
  )
  ge1 <- analyze_dif_mh(
    dat, "Person", "Item", "Score", "Group",
    reference = "Reference",
    focal = "Focal",
    matching = "restscore",
    dichotomize = 1
  )
  ge2 <- analyze_dif_mh(
    dat, "Person", "Item", "Score", "Group",
    reference = "Reference",
    focal = "Focal",
    matching = "restscore",
    dichotomize = 2
  )
  row1 <- ge1$mh_table[ge1$mh_table$Item == "I4", , drop = FALSE]
  row2 <- ge2$mh_table[ge2$mh_table$Item == "I4", , drop = FALSE]
  data.frame(
    Seed = seed,
    MissingThresholdErrors = is.character(no_threshold_error) &&
      grepl("exactly two numeric levels", no_threshold_error, fixed = TRUE),
    ThresholdGE1Direction = row1$Direction[1],
    ThresholdGE2Direction = row2$Direction[1],
    ThresholdGE1Delta = row1$MHDDelta[1],
    ThresholdGE2Delta = row2$MHDDelta[1],
    ThresholdGE1ScreenPositive = identical(row1$Classification[1],
                                           "Screen positive"),
    ThresholdGE2ScreenPositive = identical(row2$Classification[1],
                                           "Screen positive"),
    stringsAsFactors = FALSE
  )
}

.mfrmr_mh_sim_wrapper_check <- function(seed = 7777L) {
  analyze_dif_mh <- .mfrmr_mh_sim_get_function("analyze_dif_mh")
  analyze_dif_classical <- .mfrmr_mh_sim_get_function("analyze_dif_classical")
  dat <- .mfrmr_mh_sim_binary_data(seed = seed, dif_shift = 0.7)
  mh <- analyze_dif_mh(
    dat, "Person", "Item", "Score", "Group",
    reference = "Reference", focal = "Focal"
  )
  legacy <- analyze_dif_classical(
    dat, "Person", "Item", "Score", "Group",
    reference = "Reference", focal = "Focal"
  )
  data.frame(
    Seed = seed,
    PrimaryHasLegacyTable = "classical_table" %in% names(mh),
    PrimaryHasLegacyClass = inherits(mh, "mfrm_classical_dif"),
    WrapperHasLegacyTable = "classical_table" %in% names(legacy),
    WrapperHasLegacyClass = inherits(legacy, "mfrm_classical_dif"),
    TablesIdentical = isTRUE(all.equal(mh$mh_table, legacy$mh_table,
                                       check.attributes = FALSE)),
    LegacyAliasIdentical = isTRUE(all.equal(legacy$classical_table,
                                            legacy$mh_table,
                                            check.attributes = FALSE)),
    stringsAsFactors = FALSE
  )
}

mfrmr_review_mh_dif_simulation <- function(n_rep = 60L,
                                           n_person = 800L,
                                           seed = 73031L) {
  scenarios <- data.frame(
    Scenario = c(
      "null_no_dif",
      "focal_harder_small",
      "focal_harder_moderate",
      "focal_easier_moderate",
      "focal_harder_large"
    ),
    DifShift = c(0, 0.35, 0.7, -0.7, 1.05),
    ExpectedDirection = c(
      NA_character_,
      "harder_for_focal",
      "harder_for_focal",
      "easier_for_focal",
      "harder_for_focal"
    ),
    stringsAsFactors = FALSE
  )
  rows <- list()
  row_id <- 1L
  for (i in seq_len(nrow(scenarios))) {
    for (rep_id in seq_len(n_rep)) {
      rows[[row_id]] <- .mfrmr_mh_sim_one_binary(
        seed = seed + i * 10000L + rep_id,
        dif_shift = scenarios$DifShift[i],
        scenario = scenarios$Scenario[i],
        expected_direction = scenarios$ExpectedDirection[i],
        n_person = n_person
      )
      row_id <- row_id + 1L
    }
  }
  replicate_rows <- do.call(rbind, rows)
  scenario_summary <- .mfrmr_mh_sim_scenario_summary(replicate_rows)
  scenario_summary <- scenario_summary[match(scenarios$Scenario,
                                             scenario_summary$Scenario), ,
                                       drop = FALSE]

  harder <- scenario_summary[
    scenario_summary$Scenario %in% c(
      "null_no_dif", "focal_harder_small",
      "focal_harder_moderate", "focal_harder_large"
    ),
    ,
    drop = FALSE
  ]
  monotonic_summary <- data.frame(
    MeanDeltaNonIncreasing = all(diff(harder$MeanTargetMHDDelta) < 0),
    ScreenRateNonDecreasing = all(diff(harder$TargetScreenPositiveRate) >= 0),
    SmallBelowModerate = scenario_summary$TargetScreenPositiveRate[
      scenario_summary$Scenario == "focal_harder_small"
    ] < scenario_summary$TargetScreenPositiveRate[
      scenario_summary$Scenario == "focal_harder_moderate"
    ],
    ModerateBelowLarge = scenario_summary$TargetScreenPositiveRate[
      scenario_summary$Scenario == "focal_harder_moderate"
    ] <= scenario_summary$TargetScreenPositiveRate[
      scenario_summary$Scenario == "focal_harder_large"
    ],
    stringsAsFactors = FALSE
  )

  matching_seeds <- seed + 90000L + seq_len(min(40L, n_rep))
  matching_summary <- .mfrmr_mh_sim_matching_sensitivity(
    seeds = matching_seeds,
    n_person = n_person
  )
  sparse_summary <- .mfrmr_mh_sim_sparse_correction(seed = seed + 120000L)
  polytomous_summary <- .mfrmr_mh_sim_polytomous_check(seed = seed + 130000L)
  wrapper_summary <- .mfrmr_mh_sim_wrapper_check(seed = seed + 140000L)

  checks <- data.frame(
    Check = c(
      "null_target_false_positive_rate",
      "null_anchor_family_false_positive_rate",
      "moderate_harder_power",
      "moderate_harder_direction",
      "moderate_easier_power",
      "moderate_easier_direction",
      "effect_gradient",
      "matching_stability",
      "sparse_correction",
      "polytomous_requires_explicit_dichotomization",
      "wrapper_compatibility"
    ),
    Passed = c(
      scenario_summary$TargetScreenPositiveRate[
        scenario_summary$Scenario == "null_no_dif"
      ] <= 0.10,
      scenario_summary$AnchorFamilyPositiveRate[
        scenario_summary$Scenario == "null_no_dif"
      ] <= 0.15,
      scenario_summary$TargetScreenPositiveRate[
        scenario_summary$Scenario == "focal_harder_moderate"
      ] >= 0.70,
      scenario_summary$DirectionAccuracy[
        scenario_summary$Scenario == "focal_harder_moderate"
      ] >= 0.95,
      scenario_summary$TargetScreenPositiveRate[
        scenario_summary$Scenario == "focal_easier_moderate"
      ] >= 0.70,
      scenario_summary$DirectionAccuracy[
        scenario_summary$Scenario == "focal_easier_moderate"
      ] >= 0.95,
      all(unlist(monotonic_summary)),
      matching_summary$DeltaCorrelation[1] >= 0.90 &&
        matching_summary$DirectionAgreement[1] >= 0.95 &&
        matching_summary$ScreenPositiveAgreement[1] >= 0.80,
      sparse_summary$FiniteAlphaHalfCorrection[1] >=
        sparse_summary$FiniteAlphaNoCorrection[1] &&
        isTRUE(sparse_summary$MaxChiSqDifference[1] < 1e-12 ||
                 !is.finite(sparse_summary$MaxChiSqDifference[1])) &&
        isTRUE(sparse_summary$MaxPValueDifference[1] < 1e-12 ||
                 !is.finite(sparse_summary$MaxPValueDifference[1])),
      polytomous_summary$MissingThresholdErrors[1] &&
        identical(polytomous_summary$ThresholdGE1Direction[1],
                  "harder_for_focal") &&
        identical(polytomous_summary$ThresholdGE2Direction[1],
                  "harder_for_focal") &&
        polytomous_summary$ThresholdGE1Delta[1] < 0 &&
        polytomous_summary$ThresholdGE2Delta[1] < 0,
      !wrapper_summary$PrimaryHasLegacyTable[1] &&
        !wrapper_summary$PrimaryHasLegacyClass[1] &&
        wrapper_summary$WrapperHasLegacyTable[1] &&
        wrapper_summary$WrapperHasLegacyClass[1] &&
        wrapper_summary$TablesIdentical[1] &&
        wrapper_summary$LegacyAliasIdentical[1]
    ),
    stringsAsFactors = FALSE
  )
  checks$Status <- ifelse(checks$Passed, "ok", "concern")

  out <- list(
    status = if (all(checks$Passed)) "ok" else "concern",
    n_rep = n_rep,
    n_person = n_person,
    seed = seed,
    scenario_summary = scenario_summary,
    monotonic_summary = monotonic_summary,
    matching_summary = matching_summary,
    sparse_summary = sparse_summary,
    polytomous_summary = polytomous_summary,
    wrapper_summary = wrapper_summary,
    checks = checks,
    replicate_rows = replicate_rows
  )
  class(out) <- "mfrmr_mh_dif_simulation_review"
  out
}

print.mfrmr_mh_dif_simulation_review <- function(x, ...) {
  cat("mfrmr MH DIF simulation review\n")
  cat("Status:", x$status, "\n")
  cat("Replications per scenario:", x$n_rep,
      " | N/persons:", x$n_person,
      " | Seed:", x$seed, "\n\n")
  cat("Scenario summary:\n")
  print(x$scenario_summary, row.names = FALSE, digits = 3)
  cat("\nMonotonic effect checks:\n")
  print(x$monotonic_summary, row.names = FALSE)
  cat("\nMatching sensitivity:\n")
  print(x$matching_summary, row.names = FALSE, digits = 3)
  cat("\nSparse-cell correction:\n")
  print(x$sparse_summary, row.names = FALSE, digits = 3)
  cat("\nPolytomous explicit-dichotomization check:\n")
  print(x$polytomous_summary, row.names = FALSE, digits = 3)
  cat("\nWrapper compatibility:\n")
  print(x$wrapper_summary, row.names = FALSE)
  cat("\nDecision checks:\n")
  print(x$checks, row.names = FALSE)
  invisible(x)
}
