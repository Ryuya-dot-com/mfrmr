# No-fit calibration-only design for the single finite-difference gap exposed
# by v4 retrospective calibration. This fixture can never serve as v4
# confirmation and execution is not authorized by this file.

mfrmr_gsv4b_contract_version <-
  "mfrmr_gpcm_score_v4_boundary_completion_design_v1"
mfrmr_gsv4b_scenario_id <- "NUM-GPCM-SCORE-V4-CAL-BND6-C"
mfrmr_gsv4b_fixture_sha256 <-
  "57ad036bb60bd0f2cff0d2666584f3cb6d51ccb7255f4993068803a3c15a2c89"
mfrmr_gsv4b_v4_rule_sha256 <-
  "c746bd02b435e851af0ff89fff6320c34e66a1aa9fe8c52d0b6447689dd5a126"
mfrmr_gsv4b_retrospective_sha256 <-
  "831fcd4683e46785291c832242867f1962b56ce3a142c09da78fcbc311d08025"
mfrmr_gsv4b_classes <- c(
  "owner_additive", "other_additive", "steps", "log_slopes"
)

mfrmr_gsv4b_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv4b_validation_dir <- function() {
  candidates <- c(file.path("inst", "validation"),
                  file.path("..", "inst", "validation"),
                  file.path("..", "..", "inst", "validation"), ".")
  candidates <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v4-rule-contract-0.2.3.R"
  ))]
  mfrmr_gsv4b_assert(length(candidates) > 0L,
                     "Cannot locate v4 boundary design sources.")
  normalizePath(candidates[1], winslash = "/", mustWork = TRUE)
}

mfrmr_gsv4b_hash_fixture <- function(data) {
  canonical <- paste(
    c(paste(names(data), collapse = "|"),
      apply(data, 1L, paste, collapse = "|")), collapse = "\n"
  )
  digest::digest(canonical, algo = "sha256", serialize = FALSE)
}

mfrmr_gsv4b_fixture <- function() {
  persons <- sprintf("B%03d", seq_len(31L))
  raters <- sprintf("W%02d", seq_len(3L))
  criteria <- sprintf("E%02d", seq_len(6L))
  data <- expand.grid(Person = persons, Rater = raters,
                      Criterion = criteria, stringsAsFactors = FALSE)
  pi <- match(data$Person, persons)
  ri <- match(data$Rater, raters)
  ci <- match(data$Criterion, criteria)
  data$Score <- as.integer(
    1L + (pi + 2L * ri + 3L * ci + (pi - 1L) %/% 4L - 1L) %% 4L
  )
  data <- data[order(data$Person, data$Rater, data$Criterion), , drop = FALSE]
  row.names(data) <- NULL
  support <- list(
    Rater = table(factor(data$Rater, levels = raters),
                  factor(data$Score, levels = 1:4)),
    Criterion = table(factor(data$Criterion, levels = criteria),
                      factor(data$Score, levels = 1:4))
  )
  key <- paste(data$Person, data$Rater, data$Criterion, sep = "::")
  hash <- mfrmr_gsv4b_hash_fixture(data)
  mfrmr_gsv4b_assert(
    nrow(data) == 558L && !anyDuplicated(key) &&
      all(vapply(support, function(x) all(x > 0), logical(1L))) &&
      identical(hash, mfrmr_gsv4b_fixture_sha256),
    "The sealed v4 boundary-completion fixture changed."
  )
  list(data = data, support = support, sha256 = hash,
       stochastic = FALSE, calibration_only = TRUE,
       confirmation_eligible = FALSE, fit_opened = FALSE)
}

mfrmr_gsv4b_manifest <- function() {
  data.frame(
    ContractVersion = mfrmr_gsv4b_contract_version,
    ScenarioId = mfrmr_gsv4b_scenario_id,
    FixtureSHA256 = mfrmr_gsv4b_fixture_sha256,
    NPersons = 31L, NRaters = 3L, NCriteria = 6L, NCategories = 4L,
    Rows = 558L, SlopeOwner = "Criterion", StepOwner = "Criterion",
    Point = "finite_slope_stress_forward",
    ExpectedEvidenceRows = 4L, ExpectedCoordinateRows = 24L,
    ExpectedPointRows = 1L, ExpectedJacobianRows = 30L,
    Estimator = "MML", Engine = "direct", QuadPoints = 31L,
    Maxit = 2000L, Reltol = 1e-12,
    CalibrationOnly = TRUE, ConfirmationEligible = FALSE,
    FitOpened = FALSE, ExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv4b_design_decision <- function() {
  validation_dir <- mfrmr_gsv4b_validation_dir()
  rule_path <- file.path(validation_dir, "gpcm-score-v4-rule-contract-0.2.3.R")
  retro_path <- file.path(
    validation_dir, "gpcm-score-v4-retrospective-calibration-0.2.3.R"
  )
  rule_hash <- digest::digest(file = rule_path, algo = "sha256", serialize = FALSE)
  retro_hash <- digest::digest(file = retro_path, algo = "sha256", serialize = FALSE)
  target <- environment(mfrmr_gsv4b_design_decision)
  sys.source(rule_path, envir = target)
  fixture <- mfrmr_gsv4b_fixture()
  intended <- seq(-3, 3, length.out = 6L)
  represented <- c(intended[-6L], -sum(intended[-6L]))
  classification <- mfrmr_gsv4_classify_log_slopes(
    represented, "finite_slope_stress_forward"
  )
  complete <- identical(rule_hash, mfrmr_gsv4b_v4_rule_sha256) &&
    identical(retro_hash, mfrmr_gsv4b_retrospective_sha256) &&
    identical(fixture$sha256, mfrmr_gsv4b_fixture_sha256) &&
    identical(classification$Region, "finite_slope_region") &&
    isTRUE(classification$AllowanceApplied) &&
    classification$RawExcess <= classification$Allowance
  mfrmr_gsv4b_assert(complete, "The v4 boundary-completion design is incomplete.")
  data.frame(
    ContractVersion = mfrmr_gsv4b_contract_version,
    Status = "boundary_completion_design_sealed_execution_not_authorized",
    ScenarioCount = 1L, ExpectedEvidenceRows = 4L,
    ExpectedCoordinateRows = 24L, ExpectedPointRows = 1L,
    ExpectedJacobianRows = 30L,
    RawBoundaryExcess = classification$RawExcess,
    ConstructionAllowance = classification$Allowance,
    CalibrationOnly = TRUE, ConfirmationEligible = FALSE,
    FitOpened = FALSE, ExecutionAuthorized = FALSE,
    GeneralNUMSCORETOLFrozen = FALSE, InferenceAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv4b_contract <- function() {
  list(contract_version = mfrmr_gsv4b_contract_version,
       manifest = mfrmr_gsv4b_manifest(),
       parameter_classes = mfrmr_gsv4b_classes,
       decision = mfrmr_gsv4b_design_decision(),
       authorization_must_be_embedded = TRUE,
       execution_authorized = FALSE,
       confirmation_authorized = FALSE)
}
