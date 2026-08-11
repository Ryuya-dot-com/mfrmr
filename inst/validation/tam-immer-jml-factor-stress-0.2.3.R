# Draft.76 factor design with Draft.77 checkpointed TAM/immer/mfrmr JML pilot.

.mfrmr_tif_runtime_identity_cache <- NULL

mfrmr_tif_or <- function(value, replacement) {
  if (is.null(value) || length(value) == 0L) replacement else value
}

mfrmr_tif_require <- function() {
  target_env <- environment(mfrmr_tif_require)
  if (!exists("mfrmr_ti_fit_one", envir = target_env, inherits = TRUE)) {
    candidates <- c(
      file.path(
        "inst", "validation",
        "tam-immer-jml-mode-comparison-0.2.3.R"
      ),
      file.path(
        "..", "inst", "validation",
        "tam-immer-jml-mode-comparison-0.2.3.R"
      ),
      file.path(
        "..", "..", "inst", "validation",
        "tam-immer-jml-mode-comparison-0.2.3.R"
      ),
      file.path(
        "..", "..", "..", "inst", "validation",
        "tam-immer-jml-mode-comparison-0.2.3.R"
      )
    )
    path <- candidates[file.exists(candidates)][1L]
    if (is.na(path)) {
      stop("The Draft.75 TAM/immer mode runner is unavailable.",
           call. = FALSE)
    }
    sys.source(path, envir = target_env)
  }
  mfrmr_ti_require()
  invisible(TRUE)
}

mfrmr_tif_factor_registry <- function() {
  data.frame(
    Factor = c(
      "Persons", "ObservedResponsesPerPerson", "Raters", "Criteria",
      "Categories", "AssignmentDensity", "RaterWorkloadImbalance",
      "MinimumResponseRate", "MaximumResponseRate",
      "LowExtremePersonRate", "HighExtremePersonRate",
      "LocalDependence", "AnchorRate", "MissingMechanism"
    ),
    Role = c(
      "controlled", "derived", "controlled", "controlled", "controlled",
      "controlled", "controlled", "realized", "realized", "realized",
      "realized", "controlled_misspecification", "controlled_guarded",
      "controlled"
    ),
    Definition = c(
      "distinct Persons entering the generated design",
      "observed nonmissing ratings per Person; algebraically dependent on raters, criteria, assignment, and missingness",
      "declared Rater facet levels",
      "declared Criterion facet levels",
      "declared ordered response categories",
      "assigned Person-Rater pairs divided by the complete Person-Rater panel",
      "Gini coefficient and max/min workload ratio over observed Rater counts",
      "fraction of observed responses in the minimum category",
      "fraction of observed responses in the maximum category",
      "fraction of Persons whose observed sufficient score is all minimum",
      "fraction of Persons whose observed sufficient score is all maximum",
      "Gaussian-copula correlation within Person-Rater response clusters; marginal category probabilities are preserved",
      "fraction of Rater levels intended to be fixed to generating values",
      "none, MCAR, observed-Rater MAR, or outcome-dependent MNAR"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_tif_metric_registry <- function() {
  data.frame(
    Metric = c(
      "Bias", "RMSE", "SECoverage95", "SpearmanRankRecovery",
      "PairwiseOrderRecovery", "RecoverySeparation",
      "ReportedFacetSeparation", "FitReturnedRate", "FiniteSurfaceRate",
      "NumericalConvergenceRate", "IterationCeilingAvoidedRate",
      "EvidenceEligibleRate"
    ),
    Scope = c(
      "surface_and_facet", "surface_and_facet", "parameter_class",
      "facet", "facet", "facet", "facet", "fit", "fit", "fit", "fit",
      "fit"
    ),
    PrimaryEligibility = c(
      "finite truth-matched estimates",
      "finite truth-matched estimates",
      "definition-matched covariance transformed to the reported estimand",
      "at least three truth-matched facet levels",
      "at least two non-tied truth pairs",
      "at least two truth-matched facet levels and positive RMSE",
      "same separation formula, measure orientation, and SE basis",
      "all expected method rows including retained failures",
      "all expected method rows including retained failures",
      "engine-specific convergence rule retained by name; no pooled common rule",
      "engine-labelled stopping rule; never treated as a common convergence proof",
      "engine-specific numerical and estimand eligibility both satisfied"
    ),
    MisspecificationUse = c(
      "robustness_bias", "robustness_rmse", "descriptive_only",
      "robustness_rank", "robustness_rank", "descriptive_only",
      "descriptive_only", "primary", "primary", "primary", "primary",
      "primary"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_tif_reference_profile <- function() {
  data.frame(
    ProfileId = "REFERENCE",
    FactorBlock = "reference",
    Persons = 96L,
    Raters = 4L,
    Criteria = 4L,
    Categories = 4L,
    RatersPerPerson = 2L,
    WorkloadRatio = 1,
    ExtremeFraction = 0,
    LocalDependenceRho = 0,
    AnchorRate = 0,
    MissingMechanism = "none",
    MissingRate = 0,
    stringsAsFactors = FALSE
  )
}

mfrmr_tif_profile <- function(id, block, ..., reference = NULL) {
  if (is.null(reference)) reference <- mfrmr_tif_reference_profile()
  out <- reference
  out$ProfileId <- id
  out$FactorBlock <- block
  values <- list(...)
  for (name in names(values)) out[[name]] <- values[[name]]
  out
}

mfrmr_tif_smoke_profiles <- function() {
  ref <- mfrmr_tif_reference_profile()
  dplyr::bind_rows(
    ref,
    mfrmr_tif_profile(
      "SCALE_LOW", "size_exposure", Persons = 48L, Raters = 3L,
      Criteria = 2L, Categories = 3L, RatersPerPerson = 1L,
      reference = ref
    ),
    mfrmr_tif_profile(
      "SCALE_HIGH", "size_exposure", Persons = 200L, Raters = 8L,
      Criteria = 6L, Categories = 6L, RatersPerPerson = 4L,
      reference = ref
    ),
    mfrmr_tif_profile(
      "SPARSE_LOAD", "assignment_workload", Raters = 8L,
      RatersPerPerson = 2L, WorkloadRatio = 8, reference = ref
    ),
    mfrmr_tif_profile(
      "ENDPOINT_PERSON", "endpoint", ExtremeFraction = 0.20,
      reference = ref
    ),
    mfrmr_tif_profile(
      "LOCAL_DEP", "local_dependence", LocalDependenceRho = 0.35,
      reference = ref
    ),
    mfrmr_tif_profile(
      "MCAR", "missingness", MissingMechanism = "MCAR",
      MissingRate = 0.20, reference = ref
    ),
    mfrmr_tif_profile(
      "MAR_RATER", "missingness", MissingMechanism = "MAR_rater",
      MissingRate = 0.20, reference = ref
    ),
    mfrmr_tif_profile(
      "MNAR_SCORE", "missingness", MissingMechanism = "MNAR_score",
      MissingRate = 0.20, reference = ref
    ),
    mfrmr_tif_profile(
      "ANCHOR_25", "anchors", AnchorRate = 0.25, reference = ref
    ),
    mfrmr_tif_profile(
      "COMBINED_ADVERSE", "combined", Persons = 72L, Raters = 8L,
      Criteria = 6L, Categories = 5L, RatersPerPerson = 2L,
      WorkloadRatio = 8, ExtremeFraction = 0.15,
      LocalDependenceRho = 0.35, MissingMechanism = "MAR_rater",
      MissingRate = 0.20, reference = ref
    )
  )
}

mfrmr_tif_pilot_profiles <- function() {
  ref <- mfrmr_tif_reference_profile()
  dplyr::bind_rows(
    ref,
    mfrmr_tif_profile("PERSONS_LOW", "persons", Persons = 48L,
                      reference = ref),
    mfrmr_tif_profile("PERSONS_HIGH", "persons", Persons = 480L,
                      reference = ref),
    mfrmr_tif_profile("EXPOSURE_LOW", "exposure", RatersPerPerson = 1L,
                      reference = ref),
    mfrmr_tif_profile("EXPOSURE_HIGH", "exposure", RatersPerPerson = 4L,
                      reference = ref),
    mfrmr_tif_profile("RATERS_LOW", "raters", Raters = 2L,
                      RatersPerPerson = 1L, reference = ref),
    mfrmr_tif_profile("RATERS_HIGH", "raters", Raters = 8L,
                      RatersPerPerson = 4L, reference = ref),
    mfrmr_tif_profile("CRITERIA_LOW", "criteria", Criteria = 2L,
                      reference = ref),
    mfrmr_tif_profile("CRITERIA_HIGH", "criteria", Criteria = 8L,
                      reference = ref),
    mfrmr_tif_profile("CATEGORIES_LOW", "categories", Categories = 3L,
                      reference = ref),
    mfrmr_tif_profile("CATEGORIES_HIGH", "categories", Categories = 6L,
                      reference = ref),
    mfrmr_tif_profile("DENSITY_HIGH", "sparsity", Raters = 2L,
                      RatersPerPerson = 2L, reference = ref),
    mfrmr_tif_profile("DENSITY_LOW", "sparsity", Raters = 8L,
                      RatersPerPerson = 1L, reference = ref),
    mfrmr_tif_profile("LOAD_MODERATE", "workload", WorkloadRatio = 4,
                      reference = ref),
    mfrmr_tif_profile("LOAD_HIGH", "workload", WorkloadRatio = 12,
                      reference = ref),
    mfrmr_tif_profile("EXTREME_10", "endpoint", ExtremeFraction = 0.10,
                      reference = ref),
    mfrmr_tif_profile("EXTREME_25", "endpoint", ExtremeFraction = 0.25,
                      reference = ref),
    mfrmr_tif_profile("LD_20", "local_dependence",
                      LocalDependenceRho = 0.20, reference = ref),
    mfrmr_tif_profile("LD_50", "local_dependence",
                      LocalDependenceRho = 0.50, reference = ref),
    mfrmr_tif_profile("ANCHOR_25", "anchors", AnchorRate = 0.25,
                      reference = ref),
    mfrmr_tif_profile("ANCHOR_50", "anchors", AnchorRate = 0.50,
                      reference = ref),
    mfrmr_tif_profile("MCAR_15", "missingness",
                      MissingMechanism = "MCAR", MissingRate = 0.15,
                      reference = ref),
    mfrmr_tif_profile("MCAR_30", "missingness",
                      MissingMechanism = "MCAR", MissingRate = 0.30,
                      reference = ref),
    mfrmr_tif_profile("MAR_15", "missingness",
                      MissingMechanism = "MAR_rater", MissingRate = 0.15,
                      reference = ref),
    mfrmr_tif_profile("MAR_30", "missingness",
                      MissingMechanism = "MAR_rater", MissingRate = 0.30,
                      reference = ref),
    mfrmr_tif_profile("MNAR_15", "missingness",
                      MissingMechanism = "MNAR_score", MissingRate = 0.15,
                      reference = ref),
    mfrmr_tif_profile("MNAR_30", "missingness",
                      MissingMechanism = "MNAR_score", MissingRate = 0.30,
                      reference = ref),
    mfrmr_tif_profile(
      "SPARSE_LOAD_MAR", "targeted_interaction", Raters = 8L,
      RatersPerPerson = 2L, WorkloadRatio = 8,
      MissingMechanism = "MAR_rater", MissingRate = 0.20,
      reference = ref
    ),
    mfrmr_tif_profile(
      "LOWINFO_LD_EXTREME", "targeted_interaction", Persons = 72L,
      RatersPerPerson = 1L, Criteria = 3L, Categories = 5L,
      ExtremeFraction = 0.20, LocalDependenceRho = 0.35,
      reference = ref
    )
  )
}

mfrmr_tif_manifest <- function(tier = c("smoke", "pilot")) {
  tier <- match.arg(tier)
  profiles <- if (identical(tier, "smoke")) {
    mfrmr_tif_smoke_profiles()
  } else {
    mfrmr_tif_pilot_profiles()
  }
  reps <- if (identical(tier, "smoke")) 1L else 5L
  grid <- merge(
    profiles,
    expand.grid(
      Model = c("RSM", "PCM"), Replicate = seq_len(reps),
      stringsAsFactors = FALSE
    ),
    by = NULL
  )
  grid <- grid[order(grid$Model, grid$ProfileId, grid$Replicate), ]
  grid$DatasetRow <- seq_len(nrow(grid))
  grid$Tier <- tier
  grid$Seed <- 760000L + grid$DatasetRow * 101L
  grid$TargetResponsesPerPerson <-
    grid$RatersPerPerson * grid$Criteria * (1 - grid$MissingRate)
  grid$TargetAssignmentDensity <- grid$RatersPerPerson / grid$Raters
  grid$MfrmrMaxit <- if (tier == "smoke") 400L else 600L
  grid$TamMaxit <- if (tier == "smoke") 400L else 600L
  grid$ImmerMaxit <- 1000L
  grid$ForcedExtremeN <-
    2L * floor(grid$Persons * grid$ExtremeFraction / 2L)
  grid$FitEligible <- grid$AnchorRate == 0
  grid$FitIneligibilityReason <- ifelse(
    grid$FitEligible, "",
    "common_anchor_basis_not_yet_verified"
  )
  grid$ExpectedDatasetState <- ifelse(
    grid$AnchorRate > 0, "guarded_not_attempted",
    ifelse(
      grid$Raters > 1L & grid$RatersPerPerson == 1L,
      "structurally_unidentified",
      "attempted_modes"
    )
  )
  grid$DatasetId <- sprintf(
    "EXT-JML-FACTOR-%s-%s-R%02d",
    grid$Model, grid$ProfileId, grid$Replicate
  )
  grid$PairId <- sprintf(
    "EXT-JML-FACTOR-PAIR-%s-%s-R%02d",
    grid$Model, grid$ProfileId, grid$Replicate
  )
  grid$Information <- grid$FactorBlock
  grid$ExtremeFraction <- as.numeric(grid$ExtremeFraction)
  grid$FormulaIdentity <- ifelse(
    grid$Model == "RSM", "~ item + rater + step",
    "~ item + rater + item:step"
  )
  grid$ContractVersion <- "mfrmr-tam-immer-jml-factor-stress-v1"
  rownames(grid) <- NULL
  grid
}

mfrmr_tif_softmax <- function(logits) {
  value <- exp(logits - max(logits))
  value / sum(value)
}

mfrmr_tif_thresholds <- function(truth, criterion) {
  table <- as.data.frame(truth$step_table, stringsAsFactors = FALSE)
  table <- table[order(table$StepIndex), , drop = FALSE]
  if (any(table$StepFacet == criterion)) {
    table <- table[table$StepFacet == criterion, , drop = FALSE]
  } else {
    table <- table[table$StepFacet == "Common", , drop = FALSE]
  }
  as.numeric(table$Estimate)
}

mfrmr_tif_probability_matrix <- function(data, truth, categories) {
  theta <- as.numeric(truth$person[as.character(data$Person)])
  rater <- as.numeric(truth$facets$Rater[as.character(data$Rater)])
  criterion <-
    as.numeric(truth$facets$Criterion[as.character(data$Criterion)])
  eta <- theta - rater - criterion
  out <- matrix(NA_real_, nrow(data), categories)
  for (i in seq_len(nrow(data))) {
    steps <- mfrmr_tif_thresholds(truth, as.character(data$Criterion[i]))
    logits <- seq.int(0L, categories - 1L) * eta[i] -
      c(0, cumsum(steps))
    out[i, ] <- mfrmr_tif_softmax(logits)
  }
  out
}

mfrmr_tif_apply_local_dependence <- function(data, truth, rho, categories,
                                              seed) {
  if (!is.finite(rho) || rho <= 0) return(data)
  set.seed(as.integer(seed))
  probability <- mfrmr_tif_probability_matrix(data, truth, categories)
  cluster <- interaction(data$Person, data$Rater, drop = TRUE)
  shared <- stats::rnorm(nlevels(cluster))
  z <- sqrt(rho) * shared[as.integer(cluster)] +
    sqrt(1 - rho) * stats::rnorm(nrow(data))
  u <- stats::pnorm(z)
  data$Score <- vapply(seq_len(nrow(data)), function(i) {
    min(which(u[i] <= cumsum(probability[i, ])))
  }, integer(1))
  data
}

mfrmr_tif_assignment <- function(data, raters_per_person, workload_ratio,
                                 seed) {
  persons <- sort(unique(as.character(data$Person)))
  raters <- sort(unique(as.character(data$Rater)))
  if (raters_per_person >= length(raters) && workload_ratio <= 1) return(data)
  set.seed(as.integer(seed))
  probability <- if (workload_ratio <= 1) {
    rep(1, length(raters))
  } else {
    exp(seq(0, log(workload_ratio), length.out = length(raters)))
  }
  selected <- lapply(seq_along(persons), function(i) {
    if (workload_ratio <= 1) {
      raters[((i - 1L) + seq_len(raters_per_person) - 1L) %%
               length(raters) + 1L]
    } else {
      sample(raters, size = raters_per_person, replace = FALSE,
             prob = probability)
    }
  })
  names(selected) <- persons
  used <- unique(unlist(selected, use.names = FALSE))
  missing <- setdiff(raters, used)
  if (length(missing) > 0L) {
    for (j in seq_along(missing)) {
      person <- persons[((j - 1L) %% length(persons)) + 1L]
      candidate <- selected[[person]]
      if (!missing[j] %in% candidate) candidate[length(candidate)] <- missing[j]
      selected[[person]] <- unique(candidate)
    }
  }
  keep <- vapply(seq_len(nrow(data)), function(i) {
    as.character(data$Rater[i]) %in% selected[[as.character(data$Person[i])]]
  }, logical(1))
  data[keep, , drop = FALSE]
}

mfrmr_tif_force_extremes <- function(data, fraction, categories) {
  if (!is.finite(fraction) || fraction <= 0) return(data)
  persons <- sort(unique(as.character(data$Person)))
  n_each <- floor(length(persons) * fraction / 2L)
  if (n_each < 1L) return(data)
  high <- persons[seq_len(n_each)]
  low <- persons[seq.int(n_each + 1L, length.out = n_each)]
  data$Score[as.character(data$Person) %in% high] <- categories
  data$Score[as.character(data$Person) %in% low] <- 1L
  data
}

mfrmr_tif_logit_intercept <- function(x, target) {
  objective <- function(intercept) {
    mean(stats::plogis(intercept + x)) - target
  }
  stats::uniroot(objective, interval = c(-30, 30))$root
}

mfrmr_tif_apply_missingness <- function(data, mechanism, rate, seed) {
  if (identical(mechanism, "none") || !is.finite(rate) || rate <= 0) {
    return(data)
  }
  set.seed(as.integer(seed))
  mechanism <- match.arg(mechanism, c("MCAR", "MAR_rater", "MNAR_score"))
  x <- switch(
    mechanism,
    MCAR = rep(0, nrow(data)),
    MAR_rater = {
      index <- as.integer(factor(data$Rater))
      as.numeric(scale(index))
    },
    MNAR_score = {
      midpoint <- mean(range(data$Score, na.rm = TRUE))
      as.numeric(scale(abs(data$Score - midpoint)))
    }
  )
  x[!is.finite(x)] <- 0
  intercept <- mfrmr_tif_logit_intercept(x, rate)
  deleted <- stats::runif(nrow(data)) < stats::plogis(intercept + x)
  original <- data$Score
  data$Score[deleted] <- NA_integer_
  for (column in c("Person", "Rater", "Criterion")) {
    groups <- split(seq_len(nrow(data)), as.character(data[[column]]))
    for (index in groups) {
      if (all(is.na(data$Score[index]))) data$Score[index[1L]] <- original[index[1L]]
    }
  }
  data
}

mfrmr_tif_gini <- function(x) {
  x <- as.numeric(x)
  x <- x[is.finite(x) & x >= 0]
  if (length(x) == 0L || sum(x) == 0) return(NA_real_)
  sum(abs(outer(x, x, "-"))) / (2 * length(x) * sum(x))
}

mfrmr_tif_extreme_rates <- function(data, categories) {
  by_person <- split(data$Score, as.character(data$Person))
  state <- vapply(by_person, function(x) {
    x <- x[!is.na(x)]
    if (length(x) == 0L) return("missing")
    if (all(x == 1L)) return("low")
    if (all(x == categories)) return("high")
    "ordinary"
  }, character(1))
  c(
    LowExtremePersonRate = mean(state == "low"),
    HighExtremePersonRate = mean(state == "high")
  )
}

mfrmr_tif_design_audit <- function(data, row) {
  observed <- data[!is.na(data$Score), , drop = FALSE]
  workload <- table(factor(observed$Rater, levels = sort(unique(data$Rater))))
  per_person <- table(factor(observed$Person, levels = sort(unique(data$Person))))
  extreme <- mfrmr_tif_extreme_rates(data, as.integer(row$Categories))
  data.frame(
    DatasetId = as.character(row$DatasetId),
    ObservedRows = nrow(observed),
    MeanResponsesPerPerson = mean(as.numeric(per_person)),
    MinResponsesPerPerson = min(as.numeric(per_person)),
    MaxResponsesPerPerson = max(as.numeric(per_person)),
    AssignmentDensity = length(unique(paste(data$Person, data$Rater))) /
      (as.integer(row$Persons) * as.integer(row$Raters)),
    WorkloadGini = mfrmr_tif_gini(workload),
    WorkloadMaxMinRatio = if (min(workload) > 0) max(workload) / min(workload) else Inf,
    MinimumResponseRate = mean(observed$Score == 1L),
    MaximumResponseRate = mean(observed$Score == as.integer(row$Categories)),
    LowExtremePersonRate = extreme[["LowExtremePersonRate"]],
    HighExtremePersonRate = extreme[["HighExtremePersonRate"]],
    MissingRateRealized = mean(is.na(data$Score)),
    LocalDependenceRhoTarget = as.numeric(row$LocalDependenceRho),
    AnchorRateTarget = as.numeric(row$AnchorRate),
    stringsAsFactors = FALSE
  )
}

mfrmr_tif_anchor_table <- function(truth, rate) {
  raters <- names(truth$facets$Rater)
  n_anchor <- floor(length(raters) * rate)
  if (n_anchor < 1L) return(data.frame())
  selected <- raters[seq_len(n_anchor)]
  data.frame(
    Facet = "Rater", Level = selected,
    Estimate = as.numeric(truth$facets$Rater[selected]),
    stringsAsFactors = FALSE
  )
}

mfrmr_tif_generate <- function(row) {
  mfrmr_tif_require()
  data <- simulate_mfrm_data(
    n_person = as.integer(row$Persons),
    n_rater = as.integer(row$Raters),
    n_criterion = as.integer(row$Criteria),
    raters_per_person = as.integer(row$Raters),
    score_levels = as.integer(row$Categories),
    model = as.character(row$Model),
    step_facet = "Criterion",
    assignment = "crossed",
    seed = as.integer(row$Seed)
  )
  truth <- attr(data, "mfrm_truth")
  data <- mfrmr_tif_apply_local_dependence(
    data, truth, as.numeric(row$LocalDependenceRho),
    as.integer(row$Categories), as.integer(row$Seed) + 1L
  )
  data <- mfrmr_tif_assignment(
    data, as.integer(row$RatersPerPerson),
    as.numeric(row$WorkloadRatio), as.integer(row$Seed) + 2L
  )
  data <- mfrmr_tif_force_extremes(
    data, as.numeric(row$ExtremeFraction), as.integer(row$Categories)
  )
  data <- mfrmr_tif_apply_missingness(
    data, as.character(row$MissingMechanism), as.numeric(row$MissingRate),
    as.integer(row$Seed) + 3L
  )
  attr(data, "mfrm_truth") <- truth
  attr(data, "mfrmr_factor_audit") <- mfrmr_tif_design_audit(data, row)
  attr(data, "mfrmr_factor_anchors") <-
    mfrmr_tif_anchor_table(truth, as.numeric(row$AnchorRate))
  data
}

mfrmr_tif_facet_positions <- function(surface) {
  surface <- as.data.frame(surface, stringsAsFactors = FALSE)
  if (nrow(surface) == 0L) return(data.frame())
  maximum <- ave(surface$Category, surface$Item, FUN = max)
  cell <- surface[surface$Category == maximum, , drop = FALSE]
  cell$Position <- cell$Estimate / cell$Category
  rater <- stats::aggregate(Position ~ Rater, cell, mean)
  names(rater)[1L] <- "Level"
  rater$Facet <- "Rater"
  criterion <- stats::aggregate(Position ~ Criterion, cell, mean)
  names(criterion)[1L] <- "Level"
  criterion$Facet <- "Criterion"
  out <- rbind(rater, criterion)
  out$Position <- ave(out$Position, out$Facet, FUN = function(x) x - mean(x))
  out[, c("Facet", "Level", "Position")]
}

mfrmr_tif_pairwise_order <- function(truth, estimate) {
  if (length(truth) < 2L) return(NA_real_)
  pair <- utils::combn(seq_along(truth), 2L)
  truth_sign <- sign(truth[pair[1L, ]] - truth[pair[2L, ]])
  estimate_sign <- sign(estimate[pair[1L, ]] - estimate[pair[2L, ]])
  eligible <- truth_sign != 0
  if (!any(eligible)) return(NA_real_)
  mean(truth_sign[eligible] == estimate_sign[eligible])
}

mfrmr_tif_recovery_metrics <- function(output, row) {
  rows <- list()
  add <- function(mode, facet, metric, value, eligible, reason = "",
                  definition = "") {
    rows[[length(rows) + 1L]] <<- data.frame(
      DatasetId = as.character(row$DatasetId),
      Model = as.character(row$Model),
      ProfileId = as.character(row$ProfileId),
      FactorBlock = as.character(row$FactorBlock),
      ModeId = mode, Facet = facet, Metric = metric,
      Value = as.numeric(value), Eligible = isTRUE(eligible),
      IneligibilityReason = as.character(reason),
      Definition = as.character(definition),
      EvidenceReady = FALSE,
      stringsAsFactors = FALSE
    )
  }
  recovery <- as.data.frame(output$recovery, stringsAsFactors = FALSE)
  for (mode in unique(recovery$ModeId)) {
    value <- recovery[recovery$ModeId == mode, , drop = FALSE]
    add(mode, "CumulativeDifficultySurface", "Bias",
        mean(value$ErrorAligned), TRUE)
    add(mode, "CumulativeDifficultySurface", "RMSE",
        sqrt(mean(value$ErrorAligned^2)), TRUE)
    estimate_positions <- mfrmr_tif_facet_positions(output$surfaces[[mode]])
    truth_positions <- mfrmr_tif_facet_positions(output$truth_surface)
    joined <- merge(
      estimate_positions, truth_positions, by = c("Facet", "Level"),
      suffixes = c(".Estimate", ".Truth")
    )
    for (facet in c("Rater", "Criterion")) {
      part <- joined[joined$Facet == facet, , drop = FALSE]
      if (nrow(part) == 0L) next
      error <- part$Position.Estimate - part$Position.Truth
      add(mode, facet, "Bias", mean(error), TRUE)
      rmse <- sqrt(mean(error^2))
      add(mode, facet, "RMSE", rmse, TRUE)
      rank_ok <- nrow(part) >= 3L
      add(
        mode, facet, "SpearmanRankRecovery",
        if (rank_ok) stats::cor(
          part$Position.Estimate, part$Position.Truth,
          method = "spearman"
        ) else NA_real_, rank_ok,
        if (rank_ok) "" else "fewer_than_three_levels"
      )
      order_value <- mfrmr_tif_pairwise_order(
        part$Position.Truth, part$Position.Estimate
      )
      add(mode, facet, "PairwiseOrderRecovery", order_value,
          is.finite(order_value),
          if (is.finite(order_value)) "" else "no_nontied_truth_pairs")
      separation <- if (is.finite(rmse) && rmse > 0) {
        stats::sd(part$Position.Truth) / rmse
      } else {
        NA_real_
      }
      add(mode, facet, "RecoverySeparation", separation,
          is.finite(separation),
          if (is.finite(separation)) "" else "nonpositive_or_missing_rmse")
      add(mode, facet, "SECoverage95", NA_real_, FALSE,
          "common_surface_covariance_unavailable")
      add(mode, facet, "ReportedFacetSeparation", NA_real_, FALSE,
          "definition_matched_external_separation_unavailable")
    }
  }
  modes <- as.data.frame(output$modes, stringsAsFactors = FALSE)
  for (i in seq_len(nrow(modes))) {
    mode <- as.character(modes$ModeId[i])
    add(mode, "Fit", "FitReturnedRate", as.numeric(modes$FitReturned[i]), TRUE)
    add(mode, "Fit", "FiniteSurfaceRate", as.numeric(modes$FiniteSurface[i]), TRUE)
    ceiling <- switch(
      as.character(modes$Engine[i]),
      mfrmr = as.integer(row$MfrmrMaxit),
      TAM = as.integer(row$TamMaxit),
      immer = as.integer(row$ImmerMaxit)
    )
    avoided <- is.finite(modes$Iterations[i]) && modes$Iterations[i] < ceiling
    add(mode, "Fit", "IterationCeilingAvoidedRate",
        if (is.finite(modes$Iterations[i])) as.numeric(avoided) else NA_real_,
        is.finite(modes$Iterations[i]),
        if (is.finite(modes$Iterations[i])) "" else "iteration_count_unavailable",
        "iterations_strictly_below_engine_maxit")
    fit <- output$fits[[mode]]
    convergence <- if (!isTRUE(modes$FitReturned[i])) {
      FALSE
    } else if (identical(mode, "MFRMR_RAW")) {
      is.list(fit) && identical(as.integer(fit$opt$convergence), 0L)
    } else if (identical(mode, "MFRMR_PROFILE")) {
      is.list(fit) && isTRUE(fit$Complete)
    } else {
      is.finite(modes$Iterations[i]) && modes$Iterations[i] < ceiling
    }
    convergence_definition <- if (identical(mode, "MFRMR_RAW")) {
      "mfrmr_optimizer_convergence_code_zero"
    } else if (identical(mode, "MFRMR_PROFILE")) {
      "mfrmr_profile_complete"
    } else {
      "external_iteration_terminated_before_ceiling_proxy"
    }
    add(mode, "Fit", "NumericalConvergenceRate", as.numeric(convergence),
        TRUE, "", convergence_definition)
    eligible <- modes$FitReturned[i] && modes$FiniteSurface[i] &&
      (modes$OriginalRawEligible[i] ||
         !mode %in% c("MFRMR_RAW", "TAM_RAW", "IMMER_JML"))
    add(mode, "Fit", "EvidenceEligibleRate", as.numeric(eligible), TRUE)
  }
  dplyr::bind_rows(rows)
}

mfrmr_tif_checkpoint_schema <- function() {
  "mfrmr-tam-immer-jml-factor-checkpoint-v1"
}

mfrmr_tif_hash_object <- function(object) {
  digest::digest(object, algo = "sha256", serialize = TRUE)
}

mfrmr_tif_hash_file <- function(path) {
  unname(digest::digest(file = path, algo = "sha256", serialize = FALSE))
}

mfrmr_tif_runner_hash <- function() {
  target_env <- environment(mfrmr_tif_runner_hash)
  names <- c(
    "mfrmr_tif_manifest", "mfrmr_tif_generate", "mfrmr_ti_fit_one",
    "mfrmr_tif_recovery_metrics", "mfrmr_tif_run_cell",
    "mfrmr_tif_checkpoint", "mfrmr_tif_validate_checkpoint"
  )
  definitions <- lapply(names, function(name) {
    object <- get(name, envir = target_env, inherits = TRUE)
    list(name = name, formals = formals(object), body = body(object))
  })
  mfrmr_tif_hash_object(definitions)
}

mfrmr_tif_frozen_runtime_identity <- function() {
  target_env <- environment(mfrmr_tif_frozen_runtime_identity)
  cached <- get(
    ".mfrmr_tif_runtime_identity_cache", envir = target_env,
    inherits = FALSE
  )
  if (is.null(cached)) {
    cached <- mfrmr_ti_runtime_identity()
    assign(
      ".mfrmr_tif_runtime_identity_cache", cached,
      envir = target_env
    )
  }
  cached
}

mfrmr_tif_execution_identity <- function(tier, manifest) {
  mfrmr_tif_require()
  runtime <- mfrmr_tif_frozen_runtime_identity()
  identity <- list(
    Schema = mfrmr_tif_checkpoint_schema(),
    Tier = as.character(tier),
    ManifestSHA256 = mfrmr_tif_hash_object(manifest),
    RunnerSHA256 = mfrmr_tif_runner_hash(),
    RuntimeIdentity = runtime,
    RVersion = R.version.string,
    Platform = R.version$platform,
    RNGKind = RNGkind()
  )
  identity$ExecutionSHA256 <- mfrmr_tif_hash_object(identity)
  identity
}

mfrmr_tif_checkpoint_path <- function(checkpoint_dir, dataset_id) {
  if (length(dataset_id) != 1L || is.na(dataset_id) ||
      !grepl("^[A-Za-z0-9._-]+$", dataset_id)) {
    stop("Unsafe factor-stress checkpoint dataset identifier.",
         call. = FALSE)
  }
  file.path(checkpoint_dir, paste0(dataset_id, ".rds"))
}

mfrmr_tif_atomic_save_rds <- function(object, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  if (file.exists(path)) {
    stop("Refusing to replace existing factor-stress artifact: ", path,
         call. = FALSE)
  }
  temporary <- tempfile(
    pattern = paste0(".", basename(path), "-"),
    tmpdir = dirname(path), fileext = ".partial"
  )
  on.exit(unlink(temporary, force = TRUE), add = TRUE)
  saveRDS(object, temporary)
  verified <- tryCatch(readRDS(temporary), error = function(e) e)
  if (inherits(verified, "error") ||
      !identical(mfrmr_tif_hash_object(object),
                 mfrmr_tif_hash_object(verified))) {
    stop("Temporary factor-stress artifact verification failed.",
         call. = FALSE)
  }
  if (!file.rename(temporary, path)) {
    stop("Atomic factor-stress artifact rename failed: ", path,
         call. = FALSE)
  }
  invisible(path)
}

mfrmr_tif_run_cell <- function(row) {
  data <- tryCatch(mfrmr_tif_generate(row), error = function(e) e)
  if (inherits(data, "error")) {
    return(list(
      Dataset = data.frame(
        DatasetId = row$DatasetId, FitEligible = row$FitEligible,
        ExpectedDatasetState = row$ExpectedDatasetState,
        ObservedDatasetState = "generation_error",
        Generated = FALSE, FitAttempted = FALSE, RetainedModeRows = 0L,
        Error = conditionMessage(data), stringsAsFactors = FALSE
      ),
      Audit = data.frame(), Modes = data.frame(), Metrics = data.frame(),
      Output = NULL
    ))
  }
  audit <- attr(data, "mfrmr_factor_audit")
  if (!isTRUE(row$FitEligible)) {
    return(list(
      Dataset = data.frame(
        DatasetId = row$DatasetId, FitEligible = FALSE,
        ExpectedDatasetState = row$ExpectedDatasetState,
        ObservedDatasetState = "guarded_not_attempted",
        Generated = TRUE, FitAttempted = FALSE, RetainedModeRows = 0L,
        Error = row$FitIneligibilityReason, stringsAsFactors = FALSE
      ),
      Audit = audit, Modes = data.frame(), Metrics = data.frame(),
      Output = NULL
    ))
  }
  value <- tryCatch(mfrmr_ti_fit_one(row, data = data), error = function(e) e)
  if (inherits(value, "error")) {
    observed_state <- if (grepl(
      "structurally unidentified", conditionMessage(value), fixed = TRUE
    )) {
      "structurally_unidentified"
    } else {
      "attempted_failure"
    }
    return(list(
      Dataset = data.frame(
        DatasetId = row$DatasetId, FitEligible = TRUE,
        ExpectedDatasetState = row$ExpectedDatasetState,
        ObservedDatasetState = observed_state,
        Generated = TRUE, FitAttempted = TRUE, RetainedModeRows = 0L,
        Error = conditionMessage(value), stringsAsFactors = FALSE
      ),
      Audit = audit, Modes = data.frame(), Metrics = data.frame(),
      Output = NULL
    ))
  }
  value$modes$ProfileId <- row$ProfileId
  value$modes$FactorBlock <- row$FactorBlock
  list(
    Dataset = data.frame(
      DatasetId = row$DatasetId, FitEligible = TRUE,
      ExpectedDatasetState = row$ExpectedDatasetState,
      ObservedDatasetState = "attempted_modes",
      Generated = TRUE, FitAttempted = TRUE,
      RetainedModeRows = nrow(value$modes), Error = "",
      stringsAsFactors = FALSE
    ),
    Audit = audit,
    Modes = value$modes,
    Metrics = mfrmr_tif_recovery_metrics(value, row),
    Output = value
  )
}

mfrmr_tif_checkpoint <- function(row, result, identity) {
  structure(
    list(
      Schema = mfrmr_tif_checkpoint_schema(),
      ExecutionSHA256 = identity$ExecutionSHA256,
      DatasetId = as.character(row$DatasetId),
      ManifestRowSHA256 = mfrmr_tif_hash_object(row),
      ResultSHA256 = mfrmr_tif_hash_object(result),
      ManifestRow = row,
      Result = result,
      CompletedUTC = format(Sys.time(), tz = "UTC", usetz = TRUE)
    ),
    class = "mfrmr_tif_checkpoint"
  )
}

mfrmr_tif_validate_checkpoint <- function(checkpoint, row, identity) {
  fail <- function(message) {
    stop("Factor-stress checkpoint validation failed: ", message,
         call. = FALSE)
  }
  if (!inherits(checkpoint, "mfrmr_tif_checkpoint")) {
    fail("unexpected object class")
  }
  if (!identical(checkpoint$Schema, mfrmr_tif_checkpoint_schema())) {
    fail("schema mismatch")
  }
  if (!identical(as.character(checkpoint$ExecutionSHA256),
                 as.character(identity$ExecutionSHA256))) {
    fail("execution identity mismatch")
  }
  if (!identical(as.character(checkpoint$DatasetId),
                 as.character(row$DatasetId))) {
    fail("dataset identity mismatch")
  }
  if (!identical(as.character(checkpoint$ManifestRowSHA256),
                 mfrmr_tif_hash_object(row))) {
    fail("manifest row hash mismatch")
  }
  if (!identical(as.character(checkpoint$ResultSHA256),
                 mfrmr_tif_hash_object(checkpoint$Result))) {
    fail("result payload hash mismatch")
  }
  required <- c("Dataset", "Audit", "Modes", "Metrics", "Output")
  if (!is.list(checkpoint$Result) ||
      !all(required %in% names(checkpoint$Result))) {
    fail("result schema mismatch")
  }
  invisible(TRUE)
}

mfrmr_tif_read_checkpoint <- function(path, row, identity) {
  checkpoint <- tryCatch(readRDS(path), error = function(e) e)
  if (inherits(checkpoint, "error")) {
    stop("Factor-stress checkpoint validation failed: unreadable file ",
         basename(path), " (", conditionMessage(checkpoint), ")",
         call. = FALSE)
  }
  mfrmr_tif_validate_checkpoint(checkpoint, row, identity)
  checkpoint
}

mfrmr_tif_result_hash <- function(result) {
  ledger_identity <- result$CheckpointLedger[, c(
    "DatasetId", "CheckpointFile", "CheckpointSHA256"
  ), drop = FALSE]
  mfrmr_tif_hash_object(list(
    ContractVersion = result$ContractVersion,
    Tier = result$Tier,
    ExecutionIdentity = result$ExecutionIdentity,
    Manifest = result$Manifest,
    Datasets = result$Datasets,
    DesignAudit = result$DesignAudit,
    Modes = result$Modes,
    Metrics = result$Metrics,
    Summary = result$Summary,
    CheckpointLedger = ledger_identity,
    ContractPassed = result$ContractPassed,
    EvidenceReady = result$EvidenceReady
  ))
}

mfrmr_run_tam_immer_jml_factor_stress <- function(
    tier = c("smoke", "pilot"), dry_run = FALSE,
    authorize_pilot = FALSE, progress = interactive(),
    checkpoint_dir = NULL, resume = FALSE, interrupt_after_new = NULL) {
  tier <- match.arg(tier)
  manifest <- mfrmr_tif_manifest(tier)
  if (isTRUE(dry_run)) return(manifest)
  if (identical(tier, "pilot") && !isTRUE(authorize_pilot)) {
    stop(
      "The Draft.76 factor pilot requires `authorize_pilot = TRUE`; ",
      "use `dry_run = TRUE` to inspect its 290-dataset manifest.",
      call. = FALSE
    )
  }
  mfrmr_tif_require()
  if (isTRUE(resume) && is.null(checkpoint_dir)) {
    stop("`resume = TRUE` requires `checkpoint_dir`.", call. = FALSE)
  }
  if (!is.null(interrupt_after_new)) {
    if (is.null(checkpoint_dir) || length(interrupt_after_new) != 1L ||
        is.na(interrupt_after_new) || interrupt_after_new < 1 ||
        interrupt_after_new != as.integer(interrupt_after_new)) {
      stop(
        "`interrupt_after_new` requires a checkpoint directory and one positive integer.",
        call. = FALSE
      )
    }
    interrupt_after_new <- as.integer(interrupt_after_new)
  }
  identity <- mfrmr_tif_execution_identity(tier, manifest)
  checkpoint_paths <- rep(NA_character_, nrow(manifest))
  marker_path <- NA_character_
  if (!is.null(checkpoint_dir)) {
    dir.create(checkpoint_dir, recursive = TRUE, showWarnings = FALSE)
    checkpoint_paths <- vapply(
      manifest$DatasetId,
      function(id) mfrmr_tif_checkpoint_path(checkpoint_dir, id),
      character(1)
    )
    marker_path <- file.path(checkpoint_dir, "completion-marker.rds")
    found <- list.files(checkpoint_dir, pattern = "[.]rds$", full.names = TRUE)
    unexpected <- setdiff(
      basename(found), c(basename(checkpoint_paths), basename(marker_path))
    )
    if (length(unexpected) > 0L) {
      stop(
        "Unexpected factor-stress checkpoint artifact(s): ",
        paste(sort(unexpected), collapse = ", "), call. = FALSE
      )
    }
    existing_cells <- checkpoint_paths[file.exists(checkpoint_paths)]
    if ((length(existing_cells) > 0L || file.exists(marker_path)) &&
        !isTRUE(resume)) {
      stop(
        "Existing factor-stress artifacts require `resume = TRUE`; refusing to mix runs.",
        call. = FALSE
      )
    }
    if (file.exists(marker_path) &&
        !all(file.exists(checkpoint_paths))) {
      stop(
        "Completion marker exists without every declared cell checkpoint.",
        call. = FALSE
      )
    }
  }
  datasets <- vector("list", nrow(manifest))
  modes <- vector("list", nrow(manifest))
  metrics <- vector("list", nrow(manifest))
  audits <- vector("list", nrow(manifest))
  outputs <- vector("list", nrow(manifest))
  ledger <- vector("list", nrow(manifest))
  new_count <- 0L
  for (i in seq_len(nrow(manifest))) {
    row <- manifest[i, , drop = FALSE]
    if (isTRUE(progress)) {
      message("[", i, "/", nrow(manifest), "] ", row$DatasetId)
    }
    path <- checkpoint_paths[i]
    resumed <- !is.na(path) && file.exists(path)
    if (resumed) {
      checkpoint <- mfrmr_tif_read_checkpoint(path, row, identity)
      result <- checkpoint$Result
    } else {
      result <- mfrmr_tif_run_cell(row)
      if (!is.na(path)) {
        checkpoint <- mfrmr_tif_checkpoint(row, result, identity)
        mfrmr_tif_validate_checkpoint(checkpoint, row, identity)
        mfrmr_tif_atomic_save_rds(checkpoint, path)
      }
      new_count <- new_count + 1L
    }
    datasets[[i]] <- result$Dataset
    audits[i] <- list(result$Audit)
    modes[i] <- list(result$Modes)
    metrics[i] <- list(result$Metrics)
    outputs[i] <- list(result$Output)
    ledger[[i]] <- data.frame(
      DatasetId = as.character(row$DatasetId),
      Source = if (resumed) "resumed_checkpoint" else "executed",
      CheckpointFile = if (is.na(path)) NA_character_ else basename(path),
      CheckpointSHA256 = if (is.na(path)) NA_character_ else {
        mfrmr_tif_hash_file(path)
      },
      stringsAsFactors = FALSE
    )
    if (!resumed && !is.null(interrupt_after_new) &&
        new_count >= interrupt_after_new) {
      stop(
        "Intentional factor-stress interruption after ", new_count,
        " new dataset checkpoint(s).", call. = FALSE
      )
    }
  }
  datasets <- dplyr::bind_rows(datasets)
  modes <- dplyr::bind_rows(modes)
  metrics <- dplyr::bind_rows(metrics)
  audits <- dplyr::bind_rows(audits)
  ledger <- dplyr::bind_rows(ledger)
  summary <- if (nrow(metrics) == 0L) tibble::tibble() else metrics |>
    dplyr::group_by(
      .data$Model, .data$ProfileId, .data$FactorBlock,
      .data$ModeId, .data$Facet, .data$Metric
    ) |>
    dplyr::summarise(
      PlannedRows = dplyr::n(),
      EligibleRows = sum(.data$Eligible),
      Mean = if (!any(.data$Eligible) ||
                   all(is.na(.data$Value[.data$Eligible]))) {
        NA_real_
      } else {
        mean(.data$Value[.data$Eligible], na.rm = TRUE)
      },
      .groups = "drop"
    )
  result <- list(
    ContractVersion = "mfrmr-tam-immer-jml-factor-stress-v1",
    Tier = tier,
    RuntimeIdentity = identity$RuntimeIdentity,
    ExecutionIdentity = identity,
    FactorRegistry = mfrmr_tif_factor_registry(),
    MetricRegistry = mfrmr_tif_metric_registry(),
    Manifest = manifest,
    Datasets = datasets,
    DesignAudit = audits,
    Modes = modes,
    Metrics = metrics,
    Summary = summary,
    Outputs = outputs,
    CheckpointLedger = ledger,
    ResumedDatasets = sum(ledger$Source == "resumed_checkpoint"),
    ContractPassed = nrow(datasets) == nrow(manifest) &&
      all(datasets$Generated) &&
      all(datasets$ObservedDatasetState == datasets$ExpectedDatasetState) &&
      all(datasets$RetainedModeRows[
        datasets$ObservedDatasetState == "attempted_modes"
      ] == 9L),
    EvidenceReady = FALSE,
    ReadinessEffect = "none_calibration_only",
    Limitations = paste(
      "Factor-structured calibration only. Observations per Person are",
      "derived, local dependence is misspecification, anchor rows remain",
      "guarded, and common-surface SE coverage/facet separation are unavailable."
    )
  )
  if (!is.na(marker_path)) {
    ledger_identity <- ledger[, c(
      "DatasetId", "CheckpointFile", "CheckpointSHA256"
    ), drop = FALSE]
    marker <- structure(
      list(
        Schema = mfrmr_tif_checkpoint_schema(),
        ExecutionSHA256 = identity$ExecutionSHA256,
        ManifestSHA256 = identity$ManifestSHA256,
        CheckpointLedgerSHA256 = mfrmr_tif_hash_object(ledger_identity),
        ResultSHA256 = mfrmr_tif_result_hash(result),
        CompletedUTC = format(Sys.time(), tz = "UTC", usetz = TRUE)
      ),
      class = "mfrmr_tif_completion_marker"
    )
    if (file.exists(marker_path)) {
      existing_marker <- tryCatch(
        readRDS(marker_path), error = function(e) e
      )
      valid_marker <- !inherits(existing_marker, "error") &&
        inherits(existing_marker, "mfrmr_tif_completion_marker") &&
        identical(existing_marker$Schema, marker$Schema) &&
        identical(existing_marker$ExecutionSHA256,
                  marker$ExecutionSHA256) &&
        identical(existing_marker$ManifestSHA256, marker$ManifestSHA256) &&
        identical(existing_marker$CheckpointLedgerSHA256,
                  marker$CheckpointLedgerSHA256) &&
        identical(existing_marker$ResultSHA256, marker$ResultSHA256)
      if (!valid_marker) {
        stop("Factor-stress completion marker validation failed.",
             call. = FALSE)
      }
      marker <- existing_marker
    } else {
      mfrmr_tif_atomic_save_rds(marker, marker_path)
    }
    result$CompletionMarker <- marker
    result$CompletionMarkerSHA256 <- mfrmr_tif_hash_file(marker_path)
  } else {
    result$CompletionMarker <- NULL
    result$CompletionMarkerSHA256 <- NA_character_
  }
  result
}
