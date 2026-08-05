# Repository-only equivalence and allocation pilot for the mfrmr 0.2.3 JML
# observed-contrast constructor. Timing and cumulative R allocation are
# diagnostic only and never enter fit, readiness, or release decisions.

mfrmr_contrast_pilot_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl(
    "jml-contrast-constructor-pilot-0\\.2\\.3\\.R$", files
  )]
  if (length(hit) > 0L) {
    return(dirname(normalizePath(
      hit[length(hit)], winslash = "/", mustWork = FALSE
    )))
  }
  candidates <- c(
    file.path(
      "inst", "validation", "jml-contrast-constructor-pilot-0.2.3.R"
    ),
    "jml-contrast-constructor-pilot-0.2.3.R"
  )
  path <- candidates[file.exists(candidates)][1L]
  if (is.na(path)) NA_character_ else {
    dirname(normalizePath(path, winslash = "/", mustWork = TRUE))
  }
})

mfrmr_contrast_pilot_hash_file <- function(path) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The contrast pilot requires digest.", call. = FALSE)
  }
  digest::digest(path, algo = "sha256", file = TRUE, serialize = FALSE)
}

mfrmr_contrast_pilot_hash_object <- function(object) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The contrast pilot requires digest.", call. = FALSE)
  }
  digest::digest(object, algo = "sha256", serialize = TRUE)
}

mfrmr_contrast_pilot_registry <- function() {
  data.frame(
    CaseId = c(
      "CONTRAST-TWO-RATER-SHAPE", "CONTRAST-DENSE-SMALL",
      "CONTRAST-PCM-MEDIUM", "CONTRAST-CATEGORY-10",
      "CONTRAST-TARGET-SPARSE"
    ),
    Observations = c(192L, 100L, 1200L, 1200L, 5000L),
    Steps = c(5L, 4L, 4L, 9L, 5L),
    Parameters = c(35L, 30L, 150L, 250L, 600L),
    Density = c(0.12, 1, 0.03, 0.02, 0.005),
    ScorePattern = c(
      "lower_skew", "balanced", "balanced", "lower_skew", "balanced"
    ),
    PermuteObservations = c(TRUE, FALSE, TRUE, TRUE, TRUE),
    CallsPerTiming = c(10L, 15L, 3L, 2L, 1L),
    Seed = 255501:255505,
    EvidenceUse = "constructor_calibration_only",
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_contrast_pilot_build <- function(case) {
  set.seed(as.integer(case$Seed))
  design <- Matrix::rsparsematrix(
    nrow = as.integer(case$Observations * case$Steps),
    ncol = as.integer(case$Parameters),
    density = as.numeric(case$Density)
  )
  design <- methods::as(design, "dgCMatrix")
  categories <- 0:as.integer(case$Steps)
  score <- rep(categories, length.out = as.integer(case$Observations))
  if (identical(as.character(case$ScorePattern), "lower_skew")) {
    score[seq_len(floor(0.75 * length(score)))] <- 0L
  } else if (identical(as.character(case$ScorePattern), "upper_skew")) {
    score[seq_len(floor(0.75 * length(score)))] <- as.integer(case$Steps)
  }
  score <- sample(as.integer(score), length(score), replace = FALSE)

  if (isTRUE(case$PermuteObservations)) {
    permutation <- sample.int(as.integer(case$Observations))
    row_index <- unlist(lapply(seq_len(as.integer(case$Steps)), function(k) {
      (k - 1L) * as.integer(case$Observations) + permutation
    }), use.names = FALSE)
    design <- design[row_index, , drop = FALSE]
    score <- score[permutation]
  }
  list(design = design, score = score)
}

mfrmr_contrast_pilot_construct <- function(problem, case, implementation) {
  mfrmr:::mfrmr_jml_observed_contrast_design(
    adjacent_design = problem$design,
    score_k = problem$score,
    n_obs = as.integer(case$Observations),
    n_steps = as.integer(case$Steps),
    implementation = implementation
  )
}

mfrmr_contrast_pilot_memory <- function(fun) {
  path <- tempfile("mfrmr-contrast-rprofmem-", fileext = ".out")
  on.exit(unlink(path, force = TRUE), add = TRUE)
  active <- FALSE
  on.exit({
    if (active) utils::Rprofmem(NULL)
  }, add = TRUE)
  utils::Rprofmem(path)
  active <- TRUE
  value <- fun()
  utils::Rprofmem(NULL)
  active <- FALSE
  lines <- readLines(path, warn = FALSE)
  allocation <- suppressWarnings(as.numeric(sub(" .*", "", lines)))
  list(
    value = value,
    allocated_bytes = sum(allocation[is.finite(allocation)]),
    allocation_events = sum(is.finite(allocation))
  )
}

mfrmr_contrast_pilot_package_identity <- function() {
  root <- system.file(package = "mfrmr")
  if (!nzchar(root) || !dir.exists(root)) {
    stop("Cannot identify the installed mfrmr runtime.", call. = FALSE)
  }
  candidates <- c(
    file.path(root, "DESCRIPTION"),
    file.path(root, "NAMESPACE"),
    list.files(
      file.path(root, "R"), recursive = TRUE, full.names = TRUE,
      all.files = TRUE, no.. = TRUE
    ),
    list.files(
      file.path(root, "libs"), recursive = TRUE, full.names = TRUE,
      all.files = TRUE, no.. = TRUE
    )
  )
  files <- sort(unique(candidates[
    file.exists(candidates) & !dir.exists(candidates)
  ]))
  relative <- unname(substring(
    normalizePath(files, winslash = "/", mustWork = TRUE),
    nchar(normalizePath(root, winslash = "/", mustWork = TRUE)) + 2L
  ))
  manifest <- data.frame(
    File = relative,
    SHA256 = unname(vapply(
      files, mfrmr_contrast_pilot_hash_file, character(1)
    )),
    stringsAsFactors = FALSE
  )
  rownames(manifest) <- NULL
  list(
    root = normalizePath(root, winslash = "/", mustWork = TRUE),
    manifest = manifest,
    sha256 = mfrmr_contrast_pilot_hash_object(manifest)
  )
}

mfrmr_contrast_pilot_artifact_inventory <- function(directory) {
  files <- list.files(
    directory, recursive = TRUE, full.names = TRUE,
    all.files = TRUE, no.. = TRUE
  )
  files <- files[file.info(files)$isdir %in% FALSE]
  files <- files[basename(files) != "run-complete.rds"]
  relative <- substring(
    normalizePath(files, winslash = "/", mustWork = TRUE),
    nchar(normalizePath(directory, winslash = "/", mustWork = TRUE)) + 2L
  )
  order_index <- order(relative)
  inventory <- data.frame(
    File = relative[order_index],
    Bytes = as.numeric(file.info(files[order_index])$size),
    SHA256 = vapply(
      files[order_index], mfrmr_contrast_pilot_hash_file, character(1)
    ),
    stringsAsFactors = FALSE
  )
  rownames(inventory) <- NULL
  inventory
}

mfrmr_run_jml_contrast_constructor_pilot <- function(
    dry_run = TRUE, authorize = FALSE, repetitions = 7L,
    output_dir = NULL, progress = interactive()) {
  if (!requireNamespace("Matrix", quietly = TRUE) ||
      !requireNamespace("digest", quietly = TRUE)) {
    stop("The contrast pilot requires Matrix and digest.", call. = FALSE)
  }
  registry <- mfrmr_contrast_pilot_registry()
  runner_path <- file.path(
    mfrmr_contrast_pilot_source_dir,
    "jml-contrast-constructor-pilot-0.2.3.R"
  )
  package_identity <- mfrmr_contrast_pilot_package_identity()
  execution_identity <- list(
    schema = "mfrmr-jml-contrast-constructor-execution-v1",
    registry = registry,
    repetitions = as.integer(repetitions),
    runner_sha256 = mfrmr_contrast_pilot_hash_file(runner_path),
    installed_package_sha256 = package_identity$sha256,
    R = as.character(getRversion()),
    platform = R.version$platform
  )
  execution_identity$execution_sha256 <-
    mfrmr_contrast_pilot_hash_object(execution_identity)
  if (isTRUE(dry_run)) {
    return(list(
      registry = registry,
      execution_identity = execution_identity,
      confirmation_authorized = FALSE
    ))
  }
  if (!isTRUE(authorize)) {
    stop("Live contrast profiling requires `authorize = TRUE`.",
         call. = FALSE)
  }
  repetitions <- as.integer(repetitions)
  if (length(repetitions) != 1L || is.na(repetitions) || repetitions < 3L) {
    stop("`repetitions` must be one integer of at least three.", call. = FALSE)
  }
  if (is.null(output_dir) || length(output_dir) != 1L ||
      is.na(output_dir) || !nzchar(output_dir)) {
    stop("`output_dir` must be one non-empty path.", call. = FALSE)
  }
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = FALSE)
  if (file.exists(output_dir) || dir.exists(output_dir)) {
    stop("`output_dir` must not already exist.", call. = FALSE)
  }
  parent <- dirname(output_dir)
  if (!dir.exists(parent)) dir.create(parent, recursive = TRUE)
  staging <- paste0(
    output_dir, ".incomplete-", format(Sys.time(), "%Y%m%d%H%M%S"),
    "-", Sys.getpid()
  )
  dir.create(staging, recursive = TRUE)
  promoted <- FALSE
  on.exit({
    if (!promoted && dir.exists(staging)) {
      unlink(staging, recursive = TRUE, force = TRUE)
    }
  }, add = TRUE)

  timings <- list()
  memory <- list()
  output_identity <- list()
  timing_cursor <- memory_cursor <- identity_cursor <- 0L
  for (case_index in seq_len(nrow(registry))) {
    case <- registry[case_index, , drop = FALSE]
    if (isTRUE(progress)) message("[contrast] ", case$CaseId)
    problem <- mfrmr_contrast_pilot_build(case)
    preallocated <- mfrmr_contrast_pilot_construct(
      problem, case, "preallocated"
    )
    reference <- mfrmr_contrast_pilot_construct(problem, case, "reference")
    if (!identical(preallocated, reference)) {
      stop("Constructor identity failed for ", case$CaseId, call. = FALSE)
    }
    identity_cursor <- identity_cursor + 1L
    output_identity[[identity_cursor]] <- data.frame(
      CaseId = case$CaseId,
      Rows = nrow(preallocated), Columns = ncol(preallocated),
      Nonzeros = length(preallocated@x),
      OutputSHA256 = mfrmr_contrast_pilot_hash_object(preallocated),
      ExactIdentity = TRUE,
      stringsAsFactors = FALSE
    )

    for (replicate_id in seq_len(repetitions)) {
      order <- if (replicate_id %% 2L == 0L) {
        c("reference", "preallocated")
      } else {
        c("preallocated", "reference")
      }
      for (implementation in order) {
        gc()
        elapsed <- system.time({
          for (iteration in seq_len(as.integer(case$CallsPerTiming))) {
            value <- mfrmr_contrast_pilot_construct(
              problem, case, implementation
            )
          }
        })[["elapsed"]] / as.integer(case$CallsPerTiming)
        if (!identical(value, preallocated)) {
          stop(
            "Timed constructor identity failed for ", case$CaseId,
            " / ", implementation, call. = FALSE
          )
        }
        timing_cursor <- timing_cursor + 1L
        timings[[timing_cursor]] <- data.frame(
          CaseId = case$CaseId,
          Replicate = replicate_id,
          OrderPosition = match(implementation, order),
          Implementation = implementation,
          CallsPerTiming = as.integer(case$CallsPerTiming),
          ElapsedSecondsPerCall = as.numeric(elapsed),
          ExactIdentity = TRUE,
          Clock = "proc.time.elapsed",
          DecisionUse = "diagnostic_only",
          stringsAsFactors = FALSE
        )
      }
    }

    for (implementation in c("preallocated", "reference")) {
      gc()
      measured <- mfrmr_contrast_pilot_memory(function() {
        mfrmr_contrast_pilot_construct(problem, case, implementation)
      })
      if (!identical(measured$value, preallocated)) {
        stop(
          "Memory-profile identity failed for ", case$CaseId,
          " / ", implementation, call. = FALSE
        )
      }
      memory_cursor <- memory_cursor + 1L
      memory[[memory_cursor]] <- data.frame(
        CaseId = case$CaseId,
        Implementation = implementation,
        RAllocatedBytes = as.numeric(measured$allocated_bytes),
        RAllocationEvents = as.integer(measured$allocation_events),
        ResultObjectBytes = as.numeric(object.size(measured$value)),
        Nonzeros = length(measured$value@x),
        ExactIdentity = TRUE,
        MetricScope = "cumulative_R_allocations_not_peak_RSS",
        DecisionUse = "diagnostic_only",
        stringsAsFactors = FALSE
      )
    }
  }

  timings <- do.call(rbind, timings)
  memory <- do.call(rbind, memory)
  output_identity <- do.call(rbind, output_identity)
  rownames(timings) <- rownames(memory) <- rownames(output_identity) <- NULL
  summary_rows <- lapply(split(timings, timings$CaseId), function(x) {
    pre <- x$ElapsedSecondsPerCall[x$Implementation == "preallocated"]
    reference <- x$ElapsedSecondsPerCall[x$Implementation == "reference"]
    mem_pre <- memory$RAllocatedBytes[
      memory$CaseId == x$CaseId[1L] &
        memory$Implementation == "preallocated"
    ]
    mem_reference <- memory$RAllocatedBytes[
      memory$CaseId == x$CaseId[1L] &
        memory$Implementation == "reference"
    ]
    data.frame(
      CaseId = x$CaseId[1L],
      PreallocatedMedianSeconds = median(pre),
      ReferenceMedianSeconds = median(reference),
      TimingPercentChange = 100 * (median(pre) / median(reference) - 1),
      PreallocatedRAllocatedBytes = mem_pre,
      ReferenceRAllocatedBytes = mem_reference,
      RAllocationPercentChange = 100 * (mem_pre / mem_reference - 1),
      ExactIdentity = all(x$ExactIdentity),
      PerformanceRuleFrozen = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  summary <- do.call(rbind, summary_rows)
  rownames(summary) <- NULL
  completion_valid <-
    nrow(timings) == nrow(registry) * repetitions * 2L &&
    nrow(memory) == nrow(registry) * 2L &&
    nrow(output_identity) == nrow(registry) &&
    all(timings$ExactIdentity) && all(memory$ExactIdentity) &&
    all(output_identity$ExactIdentity) && all(summary$ExactIdentity) &&
    all(is.finite(timings$ElapsedSecondsPerCall)) &&
    all(timings$ElapsedSecondsPerCall >= 0) &&
    all(is.finite(memory$RAllocatedBytes)) &&
    all(memory$RAllocatedBytes >= 0)
  if (!isTRUE(completion_valid)) {
    stop("Contrast pilot completion contract failed.", call. = FALSE)
  }

  identity <- data.frame(
    Schema = "mfrmr-jml-contrast-constructor-identity-v1",
    ExecutionSHA256 = execution_identity$execution_sha256,
    InstalledPackageSHA256 = package_identity$sha256,
    RunnerSHA256 = execution_identity$runner_sha256,
    stringsAsFactors = FALSE
  )
  out <- list(
    registry = registry, timings = timings, memory = memory,
    output_identity = output_identity, summary = summary,
    identity = identity, package_manifest = package_identity$manifest,
    confirmation_authorized = FALSE, performance_rule_frozen = FALSE,
    session_info = utils::sessionInfo()
  )
  files <- list(
    "registry.csv" = registry,
    "timings.csv" = timings,
    "memory.csv" = memory,
    "output-identity.csv" = output_identity,
    "summary.csv" = summary,
    "execution-identity.csv" = identity,
    "package-manifest.csv" = package_identity$manifest
  )
  for (name in names(files)) {
    utils::write.csv(
      files[[name]], file.path(staging, name), row.names = FALSE, na = ""
    )
  }
  saveRDS(out, file.path(staging, "jml-contrast-constructor-pilot.rds"))
  saveRDS(utils::sessionInfo(), file.path(staging, "session-info.rds"))
  inventory <- mfrmr_contrast_pilot_artifact_inventory(staging)
  completion <- list(
    schema = "mfrmr-jml-contrast-constructor-completion-v1",
    execution_sha256 = execution_identity$execution_sha256,
    artifacts = inventory,
    artifact_inventory_sha256 =
      mfrmr_contrast_pilot_hash_object(inventory),
    completed_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    exact_identity = TRUE,
    performance_rule_frozen = FALSE,
    confirmation_authorized = FALSE
  )
  saveRDS(completion, file.path(staging, "run-complete.rds"))
  if (!file.rename(staging, output_dir)) {
    stop("Completed contrast evidence could not be promoted.", call. = FALSE)
  }
  promoted <- TRUE
  invisible(out)
}
