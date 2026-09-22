# Dry-run-first ASP-G4C-P3 engine, artifact, and resource controllers.
#
# This layer adds q61/q121 adapters and a one-attempt execution controller. It
# contains no top-level execution and cannot finalize or promote a calibration
# run. Integrated authorization consumption, G4N application, metrics, and the
# retained execution reviewer remain absent until P4.

mfrmr_cq_ach_p3_specification <-
  "0.2.3-conquest-adversarial-simulation-calibration-harness-v1-p3"
mfrmr_cq_ach_sentinel_token_contract <- paste0(
  "mfrmr_conquest_adversarial_simulation_tranche_a_",
  "same_process_sentinel_token_v1"
)
mfrmr_cq_ach_attempt_permit_contract <- paste0(
  "mfrmr_conquest_adversarial_simulation_tranche_a_",
  "one_attempt_controller_permit_v1"
)

mfrmr_cq_ach_p3_require_contracts <- function() {
  target <- environment(mfrmr_cq_ach_p3_require_contracts)
  required <- c(
    "mfrmr_cq_ach_p2_review", "mfrmr_cq_ach_plan",
    "mfrmr_cq_ach_schema_registry", "mfrmr_cq_ach_registered_tranche_row",
    "mfrmr_cq_ataa_review", "mfrmr_cq_ataa_harness_capability_registry",
    "mfrmr_cq_acf_seed_registry", "mfrmr_cq_acf_resource_budget_registry",
    "mfrmr_cq_ameh_dataset_input", "mfrmr_cq_ameh_response_layout",
    "mfrmr_cq_ameh_conquest_suffix_registry", "mfrmr_cq_ameh_conquest_fit",
    "mfrmr_cq_ameh_fresh_sentinel", "mfrmr_cq_ameh_write_csv",
    "mfrmr_cq_ameh_retained_bytes"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- exists(
    "mfrmr_cq_ach_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_ach_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_adversarial_simulation_calibration_harness_v1"
  ) && exists(
    "mfrmr_cq_ameh_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_ameh_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_adversarial_simulation_engine_mechanics_harness_v1"
  )
  mfrmr_cq_ach_assert(
    all(available) && identity,
    "Source the complete G4C-P2 and retained G4H contracts before P3."
  )
  invisible(TRUE)
}

mfrmr_cq_ach_adapter_plan <- function(plan = mfrmr_cq_ach_plan()) {
  mfrmr_cq_ach_p3_require_contracts()
  out <- plan
  out$RunId <- NA_character_
  out$RunDirectory <- NA_character_
  out$Prefix <- NA_character_
  out$LongFile <- NA_character_
  out$PersonDataFile <- NA_character_
  out$WideFile <- NA_character_
  out$CommandFile <- NA_character_
  out$ConsoleFile <- NA_character_
  out$MfrmrFitFile <- NA_character_
  attempt <- which(out$AttemptCap == 1L)
  for (index in attempt) {
    slug <- tolower(gsub(
      "[^A-Za-z0-9]+", "_",
      paste(
        out$DatasetId[index], out$Engine[index], out$QuadratureId[index],
        out$RepresentationId[index]
      )
    ))
    run_id <- sprintf("%03d_%s", out$AttemptOrder[index], slug)
    prefix <- paste0("cq_asp_cal_", run_id)
    run_dir <- file.path("runs", run_id)
    out$RunId[index] <- run_id
    out$RunDirectory[index] <- run_dir
    out$Prefix[index] <- prefix
    if (out$Engine[index] == "mfrmr") {
      out$LongFile[index] <- file.path(
        run_dir, paste0(prefix, "_long.csv")
      )
      out$PersonDataFile[index] <- file.path(
        run_dir, paste0(prefix, "_person_data.csv")
      )
      out$MfrmrFitFile[index] <- file.path(
        run_dir, paste0(prefix, "_mfrmr_fit.rds")
      )
    } else {
      out$WideFile[index] <- file.path(
        run_dir, paste0(prefix, "_wide.csv")
      )
      out$CommandFile[index] <- file.path(run_dir, paste0(prefix, ".cqc"))
      out$ConsoleFile[index] <- file.path(
        run_dir, paste0(prefix, "_conquest_console.log")
      )
    }
  }
  out$ExpectedNativeOutputCount <- ifelse(
    out$Engine == "ConQuest" & out$AttemptCap == 1L, 8L,
    ifelse(out$Engine == "mfrmr" & out$AttemptCap == 1L, 6L, 0L)
  )
  out$PerFitTimeoutSeconds <- ifelse(out$AttemptCap == 1L, 600L, NA_integer_)
  out$FreshSentinelTokenRequired <- out$AttemptCap == 1L
  out$ExecutionAuthorizedByP3 <- FALSE
  mfrmr_cq_ach_assert(
    nrow(out) == 230L && sum(out$AttemptCap) == 190L &&
      sum(out$Engine == "mfrmr" & out$AttemptCap == 1L) == 100L &&
      sum(out$Engine == "ConQuest" & out$AttemptCap == 1L) == 90L &&
      sum(out$Nodes == 61L & out$AttemptCap == 1L) == 150L &&
      sum(out$Nodes == 121L & out$AttemptCap == 1L) == 40L &&
      !anyDuplicated(out$RunId[attempt]) &&
      !anyDuplicated(out$Prefix[attempt]) &&
      !any(out$ExecutionAuthorizedByP3),
    "The P3 adapter plan is not the frozen 230-row/190-attempt workload."
  )
  out
}

mfrmr_cq_ach_dataset_input <- function(
    tables, dataset_id, representation_id) {
  mfrmr_cq_ach_p3_require_contracts()
  mfrmr_cq_ameh_dataset_input(tables, dataset_id, representation_id)
}

mfrmr_cq_ach_conquest_command <- function(prefix, family, nodes) {
  family <- toupper(as.character(family)[1L])
  nodes <- as.integer(nodes)[1L]
  layout <- mfrmr_cq_ameh_response_layout()
  mfrmr_cq_ach_assert(
    family %in% c("RSM", "PCM") && nodes %in% c(61L, 121L) &&
      length(prefix) == 1L && !is.na(prefix) && nzchar(prefix),
    "A P3 ConQuest command requires RSM/PCM and exactly q61 or q121."
  )
  model <- if (family == "RSM") {
    "rater + criterion + step"
  } else {
    "rater + criterion + criterion*step"
  }
  c(
    paste0("title mfrmr ASP calibration ", family, " q", nodes, ";"),
    paste0("export logfile >> ", prefix, "_conquest_internal.log;"),
    paste0(
      "datafile ", prefix,
      "_wide.csv ! filetype=csv, header=yes, columnlabels=no, pid=Person, ",
      "pidwidth=16, responses=", layout$ResponseName[1L], " to ",
      layout$ResponseName[nrow(layout)],
      ", facets=criterion(3) rater(4), keeps=X, keepswidth=32;"
    ),
    "codes 0,1,2,3;",
    paste0("labels ", 1:3, " C", 1:3, " ! criterion;"),
    paste0("labels ", 1:4, " R", 1:4, " ! rater;"),
    "regression X;",
    paste0("model ", model, ";"),
    paste0(
      "estimate ! method=quadrature, nodes=", nodes,
      ", fit=no, stderr=quick, matrixout=mfrmrCQ, ",
      "convergence=0.00000001, deviancechange=0.0000000001, ",
      "iterations=2000;"
    ),
    paste0("export parameters ! filetype=csv >> ", prefix,
           "_conquest_parameters.csv;"),
    paste0("export amatrix ! filetype=csv >> ", prefix,
           "_conquest_amatrix.csv;"),
    paste0("export reg_coefficients ! filetype=csv >> ", prefix,
           "_conquest_reg_coefficients.csv;"),
    paste0("export covariance ! filetype=csv >> ", prefix,
           "_conquest_covariance.csv;"),
    paste0("show cases ! estimates=eap, filetype=csv, regressors=yes >> ",
           prefix, "_conquest_cases_eap.csv;"),
    paste0("write mfrmrCQ_history ! filetype=csv >> ", prefix,
           "_conquest_history.csv;"),
    paste0("show parameters ! tables=1:2:3:4, estimates=eap >> ", prefix,
           "_conquest_parameters_review.txt;"),
    "quit;"
  )
}

mfrmr_cq_ach_mfrmr_arguments <- function(long, person, arm) {
  mfrmr_cq_ach_assert(
    is.data.frame(long) && is.data.frame(person) &&
      is.data.frame(arm) && nrow(arm) == 1L &&
      arm$Family %in% c("RSM", "PCM") && arm$Nodes %in% c(61L, 121L) &&
      all(c(
        "Person", "X", "Rater", "Criterion", "Response"
      ) %in% names(long)) && all(c("Person", "X") %in% names(person)),
    "The P3 mfrmr adapter received an invalid typed input or plan row."
  )
  data <- long
  data$Score <- data$Response
  data$Response <- NULL
  args <- list(
    data = data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 0,
    rating_max = 3,
    method = "MML",
    model = arm$Family,
    population_formula = ~ X,
    person_data = person,
    quad_points = as.integer(arm$Nodes),
    maxit = 2000L,
    reltol = 1e-12,
    mml_engine = "direct"
  )
  if (arm$Family == "PCM") args$step_facet <- "Criterion"
  args
}

mfrmr_cq_ach_attempt_permit <- function(arm, root, sentinel_token) {
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  plan <- mfrmr_cq_ach_adapter_plan()
  registered <- plan[
    plan$AttemptCap == 1L & plan$AttemptOrder == arm$AttemptOrder,
    , drop = FALSE
  ]
  identity_fields <- c(
    "DatasetId", "Seed", "Family", "Engine", "Nodes", "RepresentationId",
    "ExpectedFreeDimension", "RunId", "RunDirectory", "Prefix", "LongFile",
    "PersonDataFile", "WideFile", "CommandFile", "ConsoleFile", "MfrmrFitFile"
  )
  mfrmr_cq_ach_assert(
    is.data.frame(arm) && nrow(arm) == 1L && arm$AttemptCap == 1L &&
      arm$Engine %in% c("mfrmr", "ConQuest") && arm$Nodes %in% c(61L, 121L) &&
      nrow(registered) == 1L && all(vapply(identity_fields, function(field) {
        mfrmr_cq_ach_scalar_equal(arm[[field]][1L], registered[[field]][1L])
      }, logical(1L))) &&
      identical(basename(root), mfrmr_cq_ataa_output_basename) &&
      mfrmr_cq_ach_validate_fresh_sentinel_token(
        sentinel_token, arm$DatasetId, arm$Seed, root
      ),
    "A one-attempt permit requires a registered arm and valid sentinel token."
  )
  permit <- new.env(parent = emptyenv())
  permit$PermitContract <- mfrmr_cq_ach_attempt_permit_contract
  permit$HarnessContract <- mfrmr_cq_ach_contract
  permit$ProcessId <- as.integer(Sys.getpid())
  permit$OutputDir <- root
  permit$AttemptOrder <- as.integer(arm$AttemptOrder)
  permit$DatasetId <- as.character(arm$DatasetId)
  permit$Seed <- as.integer(arm$Seed)
  permit$Engine <- as.character(arm$Engine)
  permit$Nodes <- as.integer(arm$Nodes)
  permit$Family <- as.character(arm$Family)
  permit$RepresentationId <- as.character(arm$RepresentationId)
  permit$ExpectedFreeDimension <- as.integer(arm$ExpectedFreeDimension)
  permit$RunId <- as.character(arm$RunId)
  permit$RunDirectory <- as.character(arm$RunDirectory)
  permit$Prefix <- as.character(arm$Prefix)
  permit$LongFile <- as.character(arm$LongFile)
  permit$PersonDataFile <- as.character(arm$PersonDataFile)
  permit$WideFile <- as.character(arm$WideFile)
  permit$CommandFile <- as.character(arm$CommandFile)
  permit$ConsoleFile <- as.character(arm$ConsoleFile)
  permit$MfrmrFitFile <- as.character(arm$MfrmrFitFile)
  permit$OneAttemptOnly <- TRUE
  permit$Consumed <- FALSE
  class(permit) <- "mfrmr_cq_ach_one_attempt_permit"
  permit
}

mfrmr_cq_ach_validate_attempt_permit <- function(permit, arm, root) {
  required <- c(
    "PermitContract", "HarnessContract", "ProcessId", "OutputDir",
    "AttemptOrder", "DatasetId", "Seed", "Engine", "Nodes",
    "Family", "RepresentationId", "ExpectedFreeDimension", "RunId",
    "RunDirectory", "Prefix", "LongFile", "PersonDataFile", "WideFile",
    "CommandFile", "ConsoleFile", "MfrmrFitFile", "OneAttemptOnly", "Consumed"
  )
  if (!is.environment(permit) ||
      !inherits(permit, "mfrmr_cq_ach_one_attempt_permit") ||
      !setequal(ls(permit, all.names = TRUE), required) ||
      !is.data.frame(arm) || nrow(arm) != 1L) return(FALSE)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  identical(permit$PermitContract, mfrmr_cq_ach_attempt_permit_contract) &&
    identical(permit$HarnessContract, mfrmr_cq_ach_contract) &&
    identical(permit$ProcessId, as.integer(Sys.getpid())) &&
    identical(permit$OutputDir, root) &&
    identical(permit$AttemptOrder, as.integer(arm$AttemptOrder)) &&
    identical(permit$DatasetId, as.character(arm$DatasetId)) &&
    identical(permit$Seed, as.integer(arm$Seed)) &&
    identical(permit$Engine, as.character(arm$Engine)) &&
    identical(permit$Nodes, as.integer(arm$Nodes)) &&
    identical(permit$Family, as.character(arm$Family)) &&
    identical(permit$RepresentationId, as.character(arm$RepresentationId)) &&
    identical(
      permit$ExpectedFreeDimension, as.integer(arm$ExpectedFreeDimension)
    ) &&
    identical(permit$RunId, as.character(arm$RunId)) &&
    identical(permit$RunDirectory, as.character(arm$RunDirectory)) &&
    identical(permit$Prefix, as.character(arm$Prefix)) &&
    identical(permit$LongFile, as.character(arm$LongFile)) &&
    identical(permit$PersonDataFile, as.character(arm$PersonDataFile)) &&
    identical(permit$WideFile, as.character(arm$WideFile)) &&
    identical(permit$CommandFile, as.character(arm$CommandFile)) &&
    identical(permit$ConsoleFile, as.character(arm$ConsoleFile)) &&
    identical(permit$MfrmrFitFile, as.character(arm$MfrmrFitFile)) &&
    isTRUE(permit$OneAttemptOnly) && !isTRUE(permit$Consumed)
}

mfrmr_cq_ach_mfrmr_fit <- function(
    root, arm, timeout = 600L, authorize = FALSE, permit = NULL,
    fit_function = NULL) {
  mfrmr_cq_ach_assert(
    identical(authorize, TRUE),
    "The P3 mfrmr adapter is execution-held."
  )
  mfrmr_cq_ach_assert(
    is.data.frame(arm) && nrow(arm) == 1L && arm$Engine == "mfrmr" &&
      arm$AttemptCap == 1L && arm$Nodes %in% c(61L, 121L) &&
      identical(as.integer(timeout), 600L),
    "The P3 mfrmr adapter requires one frozen q61/q121 attempt."
  )
  mfrmr_cq_ach_assert(
    mfrmr_cq_ach_validate_attempt_permit(permit, arm, root),
    "The P3 mfrmr adapter requires a controller-issued one-time attempt permit."
  )
  permit$Consumed <- TRUE
  run_dir <- file.path(root, arm$RunDirectory)
  failure_path <- file.path(
    run_dir, paste0(arm$Prefix, "_mfrmr_failure.txt")
  )
  start <- proc.time()[["elapsed"]]
  warnings <- character(0)
  long <- utils::read.csv(
    file.path(root, arm$LongFile), stringsAsFactors = FALSE,
    check.names = FALSE, na.strings = ""
  )
  person <- utils::read.csv(
    file.path(root, arm$PersonDataFile), stringsAsFactors = FALSE,
    check.names = FALSE, na.strings = ""
  )
  args <- mfrmr_cq_ach_mfrmr_arguments(long, person, arm)
  if (is.null(fit_function)) {
    fit_function <- getExportedValue("mfrmr", "fit_mfrm")
  }
  on.exit(
    setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE), add = TRUE
  )
  setTimeLimit(cpu = Inf, elapsed = as.numeric(timeout), transient = TRUE)
  fit <- tryCatch(
    withCallingHandlers(
      do.call(fit_function, args),
      warning = function(warning) {
        warnings <<- c(warnings, conditionMessage(warning))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(error) error
  )
  setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
  if (inherits(fit, "error")) {
    message <- conditionMessage(fit)
    timed_out <- grepl(
      "time limit|elapsed time", message, ignore.case = TRUE, perl = TRUE
    )
    writeLines(message, failure_path, useBytes = TRUE)
    return(list(
      elapsed_seconds = proc.time()[["elapsed"]] - start,
      terminal_code = if (timed_out) "fit_timeout" else "optimizer_error",
      secondary_code = if (timed_out) {
        "mfrmr_fit_timeout"
      } else {
        "mfrmr_fit_error"
      },
      parseable = FALSE, observed_dimension = NA_integer_,
      model_identity_match = FALSE, inference_ready = FALSE,
      exit_status = NA_integer_, terminal_marker = NA,
      registered_failure_count = 1L
    ))
  }
  result <- tryCatch({
    summary <- as.data.frame(fit$summary, stringsAsFactors = FALSE)
    population <- data.frame(
      Parameter = c(names(fit$population$coefficients), "sigma2"),
      Estimate = c(
        as.numeric(fit$population$coefficients),
        as.numeric(fit$population$sigma2)
      ),
      stringsAsFactors = FALSE
    )
    facets <- as.data.frame(fit$facets$others, stringsAsFactors = FALSE)
    steps <- as.data.frame(fit$steps, stringsAsFactors = FALSE)
    saveRDS(fit, file.path(root, arm$MfrmrFitFile), version = 3)
    mfrmr_cq_ameh_write_csv(
      summary, file.path(run_dir, paste0(arm$Prefix, "_mfrmr_summary.csv"))
    )
    mfrmr_cq_ameh_write_csv(
      population,
      file.path(run_dir, paste0(arm$Prefix, "_mfrmr_population.csv"))
    )
    mfrmr_cq_ameh_write_csv(
      facets, file.path(run_dir, paste0(arm$Prefix, "_mfrmr_facets.csv"))
    )
    mfrmr_cq_ameh_write_csv(
      steps, file.path(run_dir, paste0(arm$Prefix, "_mfrmr_steps.csv"))
    )
    writeLines(
      if (length(warnings) == 0L) "none" else unique(warnings),
      file.path(run_dir, paste0(arm$Prefix, "_mfrmr_warnings.txt")),
      useBytes = TRUE
    )
    observed_dimension <- if (
      nrow(summary) > 0L && "Npar" %in% names(summary)
    ) as.integer(summary$Npar[1L]) else NA_integer_
    identity <- identical(
      observed_dimension, as.integer(arm$ExpectedFreeDimension)
    )
    inference_ready <- nrow(summary) > 0L &&
      "InferenceReady" %in% names(summary) &&
      isTRUE(summary$InferenceReady[1L])
    fit_numeric <- c(
      if ("Deviance" %in% names(summary)) summary$Deviance[1L] else NA_real_,
      population$Estimate,
      if ("Estimate" %in% names(facets)) facets$Estimate else NA_real_,
      if ("Estimate" %in% names(steps)) steps$Estimate else NA_real_
    )
    finite <- length(fit_numeric) > 0L && all(is.finite(fit_numeric))
    terminal <- if (!identity) {
      "model_identity_mismatch"
    } else if (!finite) {
      "nonfinite_fit_output"
    } else if (!inference_ready) {
      "optimizer_nonconvergence_or_readiness_hold"
    } else {
      "complete_numeric_eligible"
    }
    list(
      terminal_code = terminal,
      secondary_code = if (terminal == "complete_numeric_eligible") {
        NA_character_
      } else {
        paste0("mfrmr_", terminal)
      },
      parseable = identity && finite,
      observed_dimension = observed_dimension,
      model_identity_match = identity,
      inference_ready = inference_ready,
      registered_failure_count = as.integer(
        terminal != "complete_numeric_eligible"
      )
    )
  }, error = function(error) {
    writeLines(conditionMessage(error), failure_path, useBytes = TRUE)
    list(
      terminal_code = "native_output_parse_failure",
      secondary_code = "mfrmr_result_serialization_or_parse_failure",
      parseable = FALSE, observed_dimension = NA_integer_,
      model_identity_match = FALSE, inference_ready = FALSE,
      registered_failure_count = 1L
    )
  })
  result$elapsed_seconds <- proc.time()[["elapsed"]] - start
  result$exit_status <- NA_integer_
  result$terminal_marker <- NA
  result
}

mfrmr_cq_ach_conquest_fit <- function(
    root, arm, executable_path, timeout = 600L, authorize = FALSE,
    permit = NULL) {
  mfrmr_cq_ach_assert(
    identical(authorize, TRUE),
    "The P3 ConQuest adapter is execution-held."
  )
  mfrmr_cq_ach_assert(
    is.data.frame(arm) && nrow(arm) == 1L && arm$Engine == "ConQuest" &&
      arm$AttemptCap == 1L && arm$Nodes %in% c(61L, 121L) &&
      identical(as.integer(timeout), 600L) && identical(
        normalizePath(executable_path, winslash = "/", mustWork = FALSE),
        normalizePath(
          mfrmr_cq_acf_conquest_path, winslash = "/", mustWork = FALSE
        )
      ) && file.exists(executable_path) &&
      file.access(executable_path, mode = 1L) == 0L,
    "The P3 ConQuest adapter requires one frozen q61/q121 attempt."
  )
  mfrmr_cq_ach_assert(
    mfrmr_cq_ach_validate_attempt_permit(permit, arm, root),
    paste(
      "The P3 ConQuest adapter requires a controller-issued one-time",
      "attempt permit."
    )
  )
  permit$Consumed <- TRUE
  mfrmr_cq_ameh_conquest_fit(root, arm, executable_path, timeout)
}

mfrmr_cq_ach_expected_artifact_registry <- function(
    plan = mfrmr_cq_ach_adapter_plan()) {
  attempt <- plan[plan$AttemptCap == 1L, , drop = FALSE]
  rows <- vector("list", nrow(attempt))
  for (index in seq_len(nrow(attempt))) {
    arm <- attempt[index, , drop = FALSE]
    if (arm$Engine == "mfrmr") {
      suffix <- c(
        "_mfrmr_fit.rds", "_mfrmr_summary.csv", "_mfrmr_population.csv",
        "_mfrmr_facets.csv", "_mfrmr_steps.csv", "_mfrmr_warnings.txt",
        "_mfrmr_failure.txt"
      )
      rows[[index]] <- data.frame(
        AttemptOrder = arm$AttemptOrder,
        Engine = arm$Engine,
        Nodes = arm$Nodes,
        ArtifactKind = c(
          "fit_rds", "summary", "population", "facets", "steps", "warnings",
          "failure_record"
        ),
        RelativePath = file.path(
          arm$RunDirectory, paste0(arm$Prefix, suffix)
        ),
        Requirement = c(rep("success", 6L), "failure"),
        stringsAsFactors = FALSE
      )
    } else {
      suffix <- mfrmr_cq_ameh_conquest_suffix_registry()
      rows[[index]] <- rbind(
        data.frame(
          AttemptOrder = arm$AttemptOrder,
          Engine = arm$Engine,
          Nodes = arm$Nodes,
          ArtifactKind = suffix$ArtifactKind,
          RelativePath = file.path(
            arm$RunDirectory, paste0(arm$Prefix, suffix$Suffix)
          ),
          Requirement = "success",
          stringsAsFactors = FALSE
        ),
        data.frame(
          AttemptOrder = arm$AttemptOrder,
          Engine = arm$Engine,
          Nodes = arm$Nodes,
          ArtifactKind = "console",
          RelativePath = arm$ConsoleFile,
          Requirement = "every_attempt",
          stringsAsFactors = FALSE
        )
      )
    }
  }
  out <- do.call(rbind, rows)
  out <- rbind(
    out,
    data.frame(
      AttemptOrder = NA_integer_, Engine = "ConQuest", Nodes = NA_integer_,
      ArtifactKind = "fresh_runtime_sentinel_console",
      RelativePath = "runtime_sentinel_console.log",
      Requirement = "before_generation_and_any_attempt",
      stringsAsFactors = FALSE
    )
  )
  rownames(out) <- NULL
  mfrmr_cq_ach_assert(
    nrow(out) == 1511L && !anyDuplicated(out$RelativePath) &&
      sum(out$Engine == "mfrmr") == 700L &&
      sum(out$Engine == "ConQuest") == 811L,
    "The P3 expected-artifact registry drifted."
  )
  out
}

mfrmr_cq_ach_allowed_path_registry <- function(
    plan = mfrmr_cq_ach_adapter_plan(),
    artifacts = mfrmr_cq_ach_expected_artifact_registry(plan)) {
  attempt <- plan[plan$AttemptCap == 1L, , drop = FALSE]
  input <- c(
    attempt$LongFile, attempt$PersonDataFile,
    attempt$WideFile, attempt$CommandFile
  )
  input <- input[!is.na(input)]
  root <- c(
    paste0(mfrmr_cq_ach_schema_registry()$TableId, ".csv"),
    "response_layout.csv", "expected_artifact_registry.csv",
    "authority_snapshot.csv", "numeric_observation_detail.csv",
    "runtime_sentinel.cqc"
  )
  out <- data.frame(
    RelativePath = sort(unique(c(root, input, artifacts$RelativePath))),
    stringsAsFactors = FALSE
  )
  out$PathRole <- ifelse(
    out$RelativePath %in% root, "root_control_or_ledger",
    ifelse(out$RelativePath %in% input, "registered_attempt_input",
           "registered_execution_artifact")
  )
  out$UnexpectedFilePermitted <- FALSE
  mfrmr_cq_ach_assert(
    nrow(out) == 1910L && !anyDuplicated(out$RelativePath) &&
      !any(out$UnexpectedFilePermitted),
    "The P3 allowed-path registry drifted."
  )
  out
}

mfrmr_cq_ach_artifact_inventory <- function(
    root = NULL,
    plan = mfrmr_cq_ach_adapter_plan(),
    registry = mfrmr_cq_ach_expected_artifact_registry(plan)) {
  present <- nonempty <- rep(FALSE, nrow(registry))
  observed <- unexpected <- character(0)
  allowed <- mfrmr_cq_ach_allowed_path_registry(plan, registry)
  if (!is.null(root)) {
    root <- normalizePath(root, winslash = "/", mustWork = TRUE)
    path <- file.path(root, registry$RelativePath)
    present <- file.exists(path)
    nonempty[present] <- file.info(path[present])$size > 0
    observed <- sort(list.files(
      root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
      include.dirs = FALSE
    ))
    unexpected <- setdiff(observed, allowed$RelativePath)
  }
  inventory <- registry
  inventory$Present <- present
  inventory$Nonempty <- nonempty
  inventory$ByteEqualityInspected <- FALSE
  inventory$NumericAgreementInspected <- FALSE
  list(
    registry = inventory,
    allowed_path_registry = allowed,
    observed_files = observed,
    unexpected_files = unexpected,
    output_boundary_inspected = !is.null(root),
    unexpected_file_guard_passed = if (is.null(root)) NA else
      length(unexpected) == 0L,
    byte_equality_inspected = FALSE,
    numeric_agreement_inspected = FALSE
  )
}

mfrmr_cq_ach_resource_state <- function() {
  budget <- mfrmr_cq_acf_resource_budget_registry()
  budget <- budget[budget$Stage == "calibration_tranche_A", , drop = FALSE]
  data.frame(
    FitAttempts = 0L,
    Q61FitAttempts = 0L,
    Q121FitAttempts = 0L,
    ElapsedSeconds = 0,
    RetainedBytes = 0,
    TotalFitAttemptCap = budget$TotalFitAttemptCap,
    Q61FitAttemptCap = budget$Q61FitAttemptCap,
    Q121FitAttemptCap = budget$SelectiveQ121FitAttemptCap,
    PerFitTimeoutSeconds = budget$PerFitTimeoutSeconds,
    WallTimeCapSeconds = budget$CumulativeWallTimeCapSeconds,
    StorageCapBytes = budget$RetainedStorageCapBytes,
    GlobalAbortTriggered = FALSE,
    GlobalAbortReason = NA_character_,
    AutomaticRetryPermitted = FALSE,
    NumericAgreementInspected = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ach_resource_controller <- function(
    state, arm = NULL, terminal_code = NA_character_) {
  required <- names(mfrmr_cq_ach_resource_state())
  observed_numeric <- as.numeric(unlist(state[1L, c(
    "FitAttempts", "Q61FitAttempts", "Q121FitAttempts",
    "ElapsedSeconds", "RetainedBytes"
  )], use.names = FALSE))
  mfrmr_cq_ach_assert(
    is.data.frame(state) && nrow(state) == 1L &&
      all(required %in% names(state)) &&
      identical(as.integer(state$TotalFitAttemptCap), 190L) &&
      identical(as.integer(state$Q61FitAttemptCap), 150L) &&
      identical(as.integer(state$Q121FitAttemptCap), 40L) &&
      identical(as.integer(state$PerFitTimeoutSeconds), 600L) &&
      identical(as.numeric(state$WallTimeCapSeconds), 28800) &&
      identical(as.numeric(state$StorageCapBytes), 2 * 1024^3) &&
      all(is.finite(observed_numeric)) && all(observed_numeric >= 0),
    "The P3 resource state is incomplete, nonfinite, or outside its freeze."
  )
  nodes <- if (is.null(arm)) NA_integer_ else as.integer(arm$Nodes[1L])
  if (!is.null(arm)) {
    mfrmr_cq_ach_assert(
      is.data.frame(arm) && nrow(arm) == 1L && arm$AttemptCap == 1L &&
        nodes %in% c(61L, 121L),
      "Resource admission requires one frozen q61/q121 attempt."
    )
  }
  reason <- character(0)
  if (state$FitAttempts >= state$TotalFitAttemptCap) {
    reason <- c(reason, "total_fit_attempt_cap_reached")
  }
  if (identical(nodes, 61L) &&
      state$Q61FitAttempts >= state$Q61FitAttemptCap) {
    reason <- c(reason, "q61_fit_attempt_cap_reached")
  }
  if (identical(nodes, 121L) &&
      state$Q121FitAttempts >= state$Q121FitAttemptCap) {
    reason <- c(reason, "q121_fit_attempt_cap_reached")
  }
  if (state$ElapsedSeconds >= state$WallTimeCapSeconds) {
    reason <- c(reason, "cumulative_wall_time_cap_reached")
  }
  if (state$RetainedBytes >= state$StorageCapBytes) {
    reason <- c(reason, "retained_storage_cap_reached")
  }
  global_abort <- length(reason) > 0L || isTRUE(state$GlobalAbortTriggered)
  ordinary_failure <- !is.na(terminal_code) && terminal_code %in% c(
    "optimizer_error", "fit_timeout", "native_output_parse_failure",
    "model_identity_mismatch", "nonfinite_fit_output",
    "optimizer_nonconvergence_or_readiness_hold",
    "registered_semantic_execution_failure"
  )
  data.frame(
    AttemptPermitted = !global_abort,
    StopLaterAttempts = global_abort,
    GlobalAbortTriggered = global_abort,
    GlobalAbortReason = if (length(reason) == 0L) {
      NA_character_
    } else {
      paste(unique(reason), collapse = ";")
    },
    OrdinaryFailureObserved = ordinary_failure,
    OrdinaryFailureMaySuppressPeer = FALSE,
    SingleFitTimeoutMaySuppressPeer = FALSE,
    AutomaticRetryPermitted = FALSE,
    NumericResultMayChangeOrder = FALSE,
    NumericAgreementInspected = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ach_execution_policy <- function() {
  data.frame(
    Event = c(
      "fresh_runtime_sentinel_failure",
      "ordinary_mfrmr_fit_or_parse_failure",
      "ordinary_ConQuest_fit_or_parse_failure",
      "single_fit_timeout",
      "global_wall_time_or_storage_or_attempt_cap",
      "existing_or_opened_output_boundary",
      "favorable_or_unfavorable_numeric_result"
    ),
    StopLaterAttempts = c(TRUE, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE),
    RetainAllScheduledRows = TRUE,
    AutomaticRetryPermitted = FALSE,
    PeerFailureMaySuppressAttempt = FALSE,
    NumericAgreementInspected = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ach_sentinel_token_from_assessment <- function(
    assessment, output_dir, executable_path, run_date) {
  run_date <- as.Date(run_date)[1L]
  mfrmr_cq_ach_assert(
    is.list(assessment) && isTRUE(assessment$exact_runtime_ready) &&
      is.data.frame(assessment$summary) && nrow(assessment$summary) == 1L &&
      identical(assessment$summary$RuntimeVersion, "5.47.5") &&
      identical(assessment$summary$RuntimeEdition, "Demonstration Version") &&
      identical(assessment$summary$ExpiryDate, as.Date("2026-09-01")) &&
      !is.na(run_date) && run_date >= as.Date("2026-08-16") &&
      run_date <= as.Date("2026-08-31") &&
      !isTRUE(assessment$summary$ModelEstimationAttempted) &&
      !isTRUE(assessment$summary$ScientificComparisonAuthorized),
    "A sentinel token requires an exact fresh data-free runtime assessment."
  )
  allocation <- mfrmr_cq_acf_seed_registry()
  allocation <- allocation[allocation$Tranche == "A", , drop = FALSE]
  token <- new.env(parent = emptyenv())
  token$TokenContract <- mfrmr_cq_ach_sentinel_token_contract
  token$HarnessContract <- mfrmr_cq_ach_contract
  token$ProcessId <- as.integer(Sys.getpid())
  token$OutputDir <- normalizePath(
    output_dir, winslash = "/", mustWork = FALSE
  )
  token$ExecutablePath <- normalizePath(
    executable_path, winslash = "/", mustWork = FALSE
  )
  token$RunDate <- run_date
  token$RuntimeVersion <- assessment$summary$RuntimeVersion
  token$RuntimeEdition <- assessment$summary$RuntimeEdition
  token$ExpiryDate <- assessment$summary$ExpiryDate
  token$AuthorizedPairKeys <- paste(
    allocation$DatasetId, allocation$Seed, sep = "::"
  )
  token$RuntimeReady <- TRUE
  token$ModelEstimationAttempted <- FALSE
  token$NumericAgreementInspected <- FALSE
  class(token) <- "mfrmr_cq_ach_same_process_sentinel_token"
  token
}

mfrmr_cq_ach_validate_fresh_sentinel_token <- function(
    token, dataset_id, seed, calibration_output_dir) {
  required <- c(
    "TokenContract", "HarnessContract", "ProcessId", "OutputDir",
    "ExecutablePath", "RunDate", "RuntimeVersion", "RuntimeEdition",
    "ExpiryDate", "AuthorizedPairKeys", "RuntimeReady",
    "ModelEstimationAttempted", "NumericAgreementInspected"
  )
  if (!is.environment(token) ||
      !inherits(token, "mfrmr_cq_ach_same_process_sentinel_token") ||
      !setequal(ls(token, all.names = TRUE), required)) return(FALSE)
  target <- normalizePath(
    calibration_output_dir, winslash = "/", mustWork = FALSE
  )
  key <- paste(as.character(dataset_id)[1L], as.integer(seed)[1L], sep = "::")
  identical(token$TokenContract, mfrmr_cq_ach_sentinel_token_contract) &&
    identical(token$HarnessContract, mfrmr_cq_ach_contract) &&
    identical(token$ProcessId, as.integer(Sys.getpid())) &&
    identical(token$OutputDir, target) &&
    identical(
      token$ExecutablePath,
      normalizePath(
        mfrmr_cq_acf_conquest_path, winslash = "/", mustWork = FALSE
      )
    ) &&
    identical(token$RuntimeVersion, "5.47.5") &&
    identical(token$RuntimeEdition, "Demonstration Version") &&
    identical(token$ExpiryDate, as.Date("2026-09-01")) &&
    token$RunDate >= as.Date("2026-08-16") &&
    token$RunDate <= as.Date("2026-08-31") &&
    token$RunDate <= token$ExpiryDate && key %in% token$AuthorizedPairKeys &&
    isTRUE(token$RuntimeReady) && !isTRUE(token$ModelEstimationAttempted) &&
    !isTRUE(token$NumericAgreementInspected)
}

mfrmr_cq_ach_fresh_sentinel <- function(
    staging_root, calibration_output_dir, executable_path, run_date,
    timeout = 30L, authorize = FALSE) {
  mfrmr_cq_ach_assert(
    identical(authorize, TRUE) && identical(as.integer(timeout), 30L),
    "The P3 fresh sentinel is execution-held or has a widened timeout."
  )
  staging_root <- normalizePath(
    staging_root, winslash = "/", mustWork = TRUE
  )
  target <- normalizePath(
    calibration_output_dir, winslash = "/", mustWork = FALSE
  )
  mfrmr_cq_ach_assert(
    identical(staging_root, paste0(target, ".incomplete")) &&
      !file.exists(target) &&
      identical(
        readLines(file.path(staging_root, "runtime_sentinel.cqc"), warn = FALSE),
        "quit;"
      ),
    paste(
      "The fresh sentinel requires the exact incomplete staging root,",
      "absent final target, and data-free quit command."
    )
  )
  assessment <- mfrmr_cq_ameh_fresh_sentinel(
    root = staging_root,
    executable_path = executable_path,
    run_date = run_date,
    timeout = timeout
  )
  mfrmr_cq_ach_sentinel_token_from_assessment(
    assessment, target, executable_path, run_date
  )
}

mfrmr_cq_ach_execute <- function(
    root, arm, resource_state, sentinel_token,
    executable_path = mfrmr_cq_acf_conquest_path,
    per_fit_timeout_seconds = 600L,
    authorize = FALSE) {
  mfrmr_cq_ach_assert(
    identical(authorize, TRUE),
    "The P3 one-attempt controller is execution-held."
  )
  plan <- mfrmr_cq_ach_adapter_plan()
  mfrmr_cq_ach_assert(
    is.data.frame(arm) && nrow(arm) == 1L && arm$AttemptCap == 1L &&
      arm$AttemptOrder %in% plan$AttemptOrder[plan$AttemptCap == 1L] &&
      identical(as.integer(per_fit_timeout_seconds), 600L),
    "The P3 controller requires one exact registered attempt."
  )
  registered <- plan[
    plan$AttemptOrder == arm$AttemptOrder & plan$AttemptCap == 1L,
    , drop = FALSE
  ]
  identity_fields <- c(
    "DatasetId", "Seed", "Family", "Engine", "Nodes", "RepresentationId",
    "ExpectedFreeDimension", "RunId", "RunDirectory", "Prefix", "LongFile",
    "PersonDataFile", "WideFile", "CommandFile", "ConsoleFile", "MfrmrFitFile"
  )
  mfrmr_cq_ach_assert(
    nrow(registered) == 1L && all(vapply(identity_fields, function(field) {
      mfrmr_cq_ach_scalar_equal(arm[[field]][1L], registered[[field]][1L])
    }, logical(1L))),
    "The P3 attempt differs from the frozen adapter plan."
  )
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  exact_executable <- normalizePath(
    executable_path, winslash = "/", mustWork = FALSE
  )
  mfrmr_cq_ach_assert(
    identical(basename(root), mfrmr_cq_ataa_output_basename) &&
      identical(exact_executable, sentinel_token$ExecutablePath) &&
      identical(
        exact_executable,
        normalizePath(
          mfrmr_cq_acf_conquest_path, winslash = "/", mustWork = FALSE
        )
      ) && file.exists(exact_executable) &&
      file.access(exact_executable, mode = 1L) == 0L &&
      mfrmr_cq_ach_validate_fresh_sentinel_token(
        sentinel_token, registered$DatasetId, registered$Seed, root
      ),
    "The output target or fresh same-process sentinel token is invalid."
  )
  admission <- mfrmr_cq_ach_resource_controller(
    resource_state, registered
  )
  if (!isTRUE(admission$AttemptPermitted)) {
    return(list(
      attempted = FALSE,
      terminal_code = "global_resource_abort_unattempted",
      secondary_code = admission$GlobalAbortReason,
      resource_state = resource_state,
      continuation = admission
    ))
  }
  result <- if (registered$Engine == "mfrmr") {
    permit <- mfrmr_cq_ach_attempt_permit(
      registered, root, sentinel_token
    )
    mfrmr_cq_ach_mfrmr_fit(
      root, registered, per_fit_timeout_seconds, authorize = TRUE,
      permit = permit
    )
  } else {
    permit <- mfrmr_cq_ach_attempt_permit(
      registered, root, sentinel_token
    )
    mfrmr_cq_ach_conquest_fit(
      root, registered, executable_path, per_fit_timeout_seconds,
      authorize = TRUE, permit = permit
    )
  }
  updated <- resource_state
  updated$FitAttempts <- updated$FitAttempts + 1L
  if (registered$Nodes == 61L) {
    updated$Q61FitAttempts <- updated$Q61FitAttempts + 1L
  } else {
    updated$Q121FitAttempts <- updated$Q121FitAttempts + 1L
  }
  updated$ElapsedSeconds <- updated$ElapsedSeconds + result$elapsed_seconds
  updated$RetainedBytes <- mfrmr_cq_ameh_retained_bytes(root)
  continuation <- mfrmr_cq_ach_resource_controller(
    updated, terminal_code = result$terminal_code
  )
  list(
    attempted = TRUE,
    result = result,
    resource_state = updated,
    continuation = continuation
  )
}

mfrmr_cq_ach_p3_review <- function(
    g4x_output_dir, calibration_output_dir,
    smoke_output_dir = file.path(
      dirname(g4x_output_dir), mfrmr_cq_ase_output_basename
    )) {
  mfrmr_cq_ach_p3_require_contracts()
  p2 <- mfrmr_cq_ach_p2_review(
    g4x_output_dir, calibration_output_dir, smoke_output_dir
  )
  g4a <- mfrmr_cq_ataa_review(g4x_output_dir, calibration_output_dir)
  plan <- mfrmr_cq_ach_adapter_plan()
  attempt <- plan[plan$AttemptCap == 1L, , drop = FALSE]
  commands <- lapply(seq_len(nrow(attempt)), function(index) {
    arm <- attempt[index, , drop = FALSE]
    if (arm$Engine == "ConQuest") {
      mfrmr_cq_ach_conquest_command(arm$Prefix, arm$Family, arm$Nodes)
    } else {
      character(0)
    }
  })
  artifacts <- mfrmr_cq_ach_artifact_inventory(plan = plan)
  resource <- mfrmr_cq_ach_resource_state()
  policy <- mfrmr_cq_ach_execution_policy()
  capability <- mfrmr_cq_ataa_harness_capability_registry()
  p3_available <- capability$CapabilityOrder %in% c(1:11, 13:14)
  complete <- identical(
    p2$status,
    paste0(
      "ASP_G4C_P2_generation_and_bridge_frozen_",
      "integrated_harness_incomplete"
    )
  ) && nrow(plan) == 230L && nrow(attempt) == 190L &&
    sum(attempt$Nodes == 61L) == 150L &&
    sum(attempt$Nodes == 121L) == 40L &&
    length(commands) == 190L &&
    sum(lengths(commands) > 0L) == 90L &&
    nrow(artifacts$registry) == 1511L &&
    nrow(artifacts$allowed_path_registry) == 1910L &&
    !isTRUE(artifacts$output_boundary_inspected) &&
    is.na(artifacts$unexpected_file_guard_passed) &&
    nrow(policy) == 7L && !any(policy$PeerFailureMaySuppressAttempt) &&
    !any(policy$AutomaticRetryPermitted) &&
    identical(as.integer(resource$TotalFitAttemptCap), 190L) &&
    all(capability$ProviderAvailable[p3_available]) &&
    identical(sum(p3_available), 13L) &&
    identical(sum(!p3_available), 5L) &&
    g4a$status %in% c(
      paste0(
        "ASP_G4A_scientific_value_retained_execution_hold_",
        "harness_freeze_required"
      ),
      "ASP_G4A_harness_ready_separate_live_authorization_required"
    )
  list(
    specification = mfrmr_cq_ach_p3_specification,
    contract_version = mfrmr_cq_ach_contract,
    status = if (complete) {
      paste0(
        "ASP_G4C_P3_engine_adapters_artifacts_resources_frozen_",
        "integrated_harness_incomplete"
      )
    } else {
      "ASP_G4C_P3_adapter_artifact_or_resource_hold"
    },
    p2_review = p2,
    g4a_review = g4a,
    adapter_plan = plan,
    expected_artifact_registry = artifacts$registry,
    allowed_path_registry = artifacts$allowed_path_registry,
    resource_state = resource,
    execution_policy = policy,
    upstream_and_harness_capabilities_available =
      sum(p3_available),
    harness_capabilities_still_missing = sum(!p3_available),
    q61_q121_mfrmr_adapter_implemented = TRUE,
    q61_q121_ConQuest_adapter_and_parser_implemented = TRUE,
    same_process_sentinel_controller_implemented = TRUE,
    artifact_inventory_and_unexpected_file_guard_implemented = TRUE,
    output_boundary_inspected = FALSE,
    resource_and_peer_continuation_controller_implemented = TRUE,
    tranche_A_responses_generated = FALSE,
    fit_attempts = 0L,
    ConQuest_execution_attempted = FALSE,
    response_generation_authorized = FALSE,
    execution_authorized = FALSE,
    numeric_agreement_inspected = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE,
    next_action = "ASP-G4C-P4-ELIGIBILITY-METRICS-FINALIZATION-REVIEW"
  )
}
