# 0.2.4 fixed-calibration post-maintenance G4 v6 confirmation worker.
#
# This wrapper reuses the already-reviewed 49-cell evaluator while replacing
# its fixture constructor, contract, and candidate binding with the frozen v6
# identities. The historical v5 worker and contract remain unchanged.

mfrmr_fc_g4v6w_contract <-
  "mfrmr_fixed_calibration_g4_post_maintenance_worker_v1"

mfrmr_fc_g4v6w_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
  invisible(TRUE)
}

mfrmr_fc_g4v6w_paths <- function(package_root) {
  validation <- file.path(package_root, "inst", "validation")
  paths <- list(
    BaseWorker = file.path(
      validation, "fixed-calibration-g4-confirmation-worker-0.2.4.R"
    ),
    Contract = file.path(
      validation,
      "fixed-calibration-g4-post-maintenance-v6-contract-0.2.4.R"
    ),
    Preflight = file.path(
      validation,
      "fixed-calibration-g4-candidate-binding-preflight-0.2.4.R"
    )
  )
  mfrmr_fc_g4v6w_assert(
    all(file.exists(unlist(paths, use.names = FALSE))),
    "A v6 worker dependency is absent."
  )
  lapply(paths, normalizePath, winslash = "/", mustWork = TRUE)
}

mfrmr_fc_g4v6w_base <- function(package_root) {
  paths <- mfrmr_fc_g4v6w_paths(package_root)
  base <- new.env(parent = globalenv())
  sys.source(paths$BaseWorker, envir = base)
  list(Environment = base, Paths = paths)
}

mfrmr_fc_g4v6w_cell_ids <- function(package_root = ".") {
  loaded <- mfrmr_fc_g4v6w_base(package_root)
  loaded$Environment$mfrmr_fc_g4w_cell_ids()
}

mfrmr_fc_g4v6w_install_fixture <- function(base) {
  fixture <- function(family, role, design) {
    family <- match.arg(family, c("RSM", "PCM"))
    row <- design[
      design$Family == family & design$EvidenceRole == role, , drop = FALSE
    ]
    base$mfrmr_fc_g4w_assert(
      nrow(row) == 1L, "Frozen v6 fixture identity is missing."
    )
    required <- c(
      "Modulus", "SourcePrefix", "ConfirmationPrefix", "SourceOffset",
      "ConfirmationOffset"
    )
    base$mfrmr_fc_g4w_assert(
      all(required %in% names(row)),
      "The v6 fixture generator identity is incomplete."
    )
    source <- base$mfrmr_fc_g4w_deterministic_data(
      row$SourcePersons, row$SourcePrefix, row$SourceOffset, row$Modulus
    )
    confirmation <- base$mfrmr_fc_g4w_deterministic_data(
      row$ConfirmationPersons, row$ConfirmationPrefix,
      row$ConfirmationOffset, row$Modulus
    )
    confirmation$Weight <- rep(
      c(0.5, 1, 1.5, 2), length.out = nrow(confirmation)
    )
    fit <- suppressMessages(suppressWarnings(mfrmr::fit_mfrm(
      source, person = "Person", facets = c("Rater", "Criterion"),
      score = "Score", method = "MML", model = family,
      step_facet = if (identical(family, "PCM")) "Criterion" else NULL,
      quad_points = row$FitQuadratureOrder, maxit = 100,
      mml_engine = "direct"
    )))
    base$mfrmr_fc_g4w_assert(
      mfrmr:::mfrm_inference_ready(fit),
      paste0(family, " ", role, " v6 source fit is not inference-ready.")
    )
    minute <- if (identical(family, "RSM")) "00" else "10"
    draft <- mfrmr:::mfrmr_extract_calibration_draft(
      fit, calibration_id = row$CalibrationId,
      source_fit_id = row$SourceFixtureId,
      created_at_utc = paste0("2026-08-26T06:", minute, ":00Z"),
      scoring_quad_points = row$ScoringQuadratureOrder
    )
    validated <- mfrmr:::mfrmr_validate_calibration_draft(
      draft,
      validated_at_utc = paste0("2026-08-26T06:", minute, ":01Z")
    )
    frozen <- mfrmr:::mfrmr_freeze_calibration(
      validated,
      frozen_at_utc = paste0("2026-08-26T06:", minute, ":02Z")
    )
    list(
      family = family, role = role, design = row, source = source,
      confirmation = confirmation, fit = fit, frozen = frozen
    )
  }
  assign("mfrmr_fc_g4w_fixture", fixture, envir = base)
  invisible(base)
}

mfrmr_fc_g4v6w_runtime <- function(contract_environment, package_root) {
  loaded <- mfrmr_fc_g4v6w_base(package_root)
  base <- mfrmr_fc_g4v6w_install_fixture(loaded$Environment)
  handlers <- base$mfrmr_fc_g4w_current_handlers(
    contract_environment, normalizePath(package_root, winslash = "/"),
    loaded$Paths$BaseWorker
  )
  list(Base = base, Paths = loaded$Paths, Handlers = handlers)
}

mfrmr_fc_g4v6w_handlers <- function(contract_environment,
                                     package_root = ".") {
  mfrmr_fc_g4v6w_runtime(contract_environment, package_root)$Handlers
}

mfrmr_fc_g4v6w_main <- function(arguments = commandArgs(trailingOnly = TRUE)) {
  if (length(arguments) != 5L || !identical(arguments[1L], "v6")) {
    stop(
      "Usage: Rscript --vanilla ",
      "fixed-calibration-g4-post-maintenance-v6-worker-0.2.4.R ",
      "v6 PACKAGE_ROOT TARBALL BINDING_RDS OUTPUT_RDS",
      call. = FALSE
    )
  }
  package_root <- normalizePath(
    arguments[2L], winslash = "/", mustWork = TRUE
  )
  tarball <- normalizePath(arguments[3L], winslash = "/", mustWork = TRUE)
  receipt_path <- normalizePath(
    arguments[4L], winslash = "/", mustWork = TRUE
  )
  output_file <- arguments[5L]
  if (file.exists(output_file)) {
    stop("The v6 confirmation output path must not already exist.",
         call. = FALSE)
  }
  paths <- mfrmr_fc_g4v6w_paths(package_root)
  contract <- new.env(parent = globalenv())
  preflight <- new.env(parent = globalenv())
  sys.source(paths$Contract, envir = contract)
  old_generation <- Sys.getenv(
    "MFRMR_G4_CONTRACT_GENERATION", unset = NA_character_
  )
  on.exit({
    if (is.na(old_generation)) {
      Sys.unsetenv("MFRMR_G4_CONTRACT_GENERATION")
    } else {
      Sys.setenv(MFRMR_G4_CONTRACT_GENERATION = old_generation)
    }
  }, add = TRUE)
  Sys.setenv(MFRMR_G4_CONTRACT_GENERATION = "v6")
  sys.source(paths$Preflight, envir = preflight)
  receipt <- readRDS(receipt_path)
  preflight$mfrmr_fc_g4b_require_bound_candidate(
    receipt, package_root, tarball
  )
  runtime <- mfrmr_fc_g4v6w_runtime(contract, package_root)
  base <- runtime$Base
  loaded <- base$mfrmr_fc_g4w_load_installed()
  base$mfrmr_fc_g4w_assert(
    identical(
      as.character(utils::packageVersion("mfrmr")),
      receipt$TarballObservation$PackageVersion
    ),
    "Installed package version differs from the v6 bound tarball."
  )
  denominator <- contract$mfrmr_fc_g4v6_denominator()
  base$mfrmr_fc_g4w_assert(
    identical(denominator$CellId, base$mfrmr_fc_g4w_cell_ids()),
    "The v6 worker does not implement the frozen denominator."
  )
  started <- format(Sys.time(), "%Y-%m-%dT%H:%M:%OS6Z", tz = "UTC")
  cells <- base$mfrmr_fc_g4w_evaluate(runtime$Handlers, denominator)
  default_fixture <- tryCatch(
    base$mfrmr_fc_g4w_fixture(
      "RSM", "current_default31_confirmation",
      contract$mfrmr_fc_g4v6_confirmation_design()
    ),
    error = identity
  )
  resources <- if (inherits(default_fixture, "error")) {
    budgets <- contract$mfrmr_fc_g4v6_resource_budgets()
    data.frame(
      Scale = budgets$Scale, Persons = budgets$Persons, Rows = budgets$Rows,
      ArtifactBytes = NA_real_, ElapsedSeconds = NA_real_,
      ProfiledAllocationBytes = NA_real_, SerializedResultBytes = NA_real_,
      Pass = FALSE, Detail = conditionMessage(default_fixture),
      stringsAsFactors = FALSE
    )
  } else {
    base$mfrmr_fc_g4w_resources(
      default_fixture$frozen, default_fixture$confirmation,
      contract$mfrmr_fc_g4v6_resource_budgets()
    )
  }
  complete <- identical(cells$CellId, denominator$CellId) &&
    nrow(cells) == 49L && all(cells$Pass) &&
    nrow(resources) == 3L && all(resources$Pass)
  result <- list(
    Contract = mfrmr_fc_g4v6w_contract,
    ProspectiveContract = receipt$ProspectiveContract,
    ProspectiveSpecification = receipt$ProspectiveSpecification,
    CandidateManifestHash = receipt$ManifestHash,
    CandidateGitCommit = receipt$ObservedGitIdentity$HeadCommit,
    CandidateTarballSHA256 = receipt$TarballObservation$TarballSHA256,
    CandidateTarballFileRegistrySHA256 =
      receipt$TarballObservation$FileRegistryHash,
    Binding = receipt$Binding, CandidateBindingComplete = TRUE,
    V6ExecutionOpened = TRUE, ConfirmationResultObserved = TRUE,
    StartedAtUTC = started,
    FinishedAtUTC = format(Sys.time(), "%Y-%m-%dT%H:%M:%OS6Z", tz = "UTC"),
    InstalledLibrary = loaded$InstalledLibrary,
    LoadedPackagePath = loaded$LoadedPackagePath,
    PackageVersion = as.character(utils::packageVersion("mfrmr")),
    R = R.version.string, Platform = R.version$platform,
    System = as.list(Sys.info()), Locale = Sys.getlocale(),
    Cells = cells, ResourceObservations = resources,
    DenominatorCells = as.integer(nrow(cells)),
    PassedCells = as.integer(sum(cells$Pass)),
    FailedCells = as.integer(sum(!cells$Pass)),
    ResourceScalesPassed = as.integer(sum(resources$Pass)),
    Complete = complete,
    CORE05Complete = complete, CORE06Complete = complete,
    G4LocalCandidateComplete = complete,
    HostedPlatformMatrixComplete = FALSE,
    G4ExitComplete = FALSE, G6Authorized = FALSE,
    PublicAPIAuthorized = FALSE
  )
  saveRDS(result, output_file, version = 3)
  cat(
    "G4 v6 confirmation: cells=", nrow(cells),
    "; passed=", sum(cells$Pass), "; failed=", sum(!cells$Pass),
    "; resources=", sum(resources$Pass), "/", nrow(resources), "\n",
    sep = ""
  )
  if (!complete) {
    stop("The retained G4 v6 denominator is incomplete.", call. = FALSE)
  }
  invisible(result)
}

if (sys.nframe() == 0L) mfrmr_fc_g4v6w_main()
