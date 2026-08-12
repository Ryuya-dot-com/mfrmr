# Repository-only binding for the corrected prospective six-arm ConQuest
# candidate. It freezes source, command, input, model-dimension, and
# expected-empty-output identities. It never launches ConQuest. Candidate 001
# is explicitly invalid because its RSM/PCM arms were item-only and could not
# evaluate the rater/criterion estimands in the frozen 57-row tolerance table.

mfrmr_cq_cb_specification <-
  "0.2.3-wave-c-conquest-six-arm-candidate-binding-v2"
mfrmr_cq_cb_contract <- "mfrmr_conquest_six_arm_candidate_binding_v2"
mfrmr_cq_cb_candidate_id <- "mfrmr-0.2.3-conquest-six-arm-002"
mfrmr_cq_cb_candidate_root <-
  "validation-results/conquest-six-arm-candidate-002-core"
mfrmr_cq_cb_source_commit <-
  "8ee7958f7af08141df156b333fe1fc732e2b2bc6"
mfrmr_cq_cb_source_tree_sha256 <-
  "d435e745130fd4eaded7898b31504f1fced8af9e6ac12ff13f43a437dfb48bd9"
mfrmr_cq_cb_command_bundle_sha256 <-
  "bc0a3cce17f536306c09dc2883d30c1c2852cbff636a40bafe32fede36268fd7"
mfrmr_cq_cb_input_bundle_sha256 <-
  "cd595bc5a914297ea57f13b1f1fc5d8e6d4d9baacd3f7cadcf380a62806fddcb"
mfrmr_cq_cb_model_dimension_bundle_sha256 <-
  "12dafad2ac6e622288717ec60062f1eeb42c159db253dd46757834335b9e40f5"
mfrmr_cq_cb_expected_empty_outputs_sha256 <-
  "161488319712d87f720ef6dce8b1a3b5ae1dd0c2e40eea3897189655870d6d8a"
mfrmr_cq_cb_source_precision_artifact <-
  "inst/validation/conquest-reported-output-precision-contract-0.2.3.R"
mfrmr_cq_cb_source_precision_sha256 <-
  "e0e80ebd96c48634ddd39231959bb0c5cfcd6c036c39c4e5bf8224e19164fd53"
mfrmr_cq_cb_execution_hold_reason <-
  "corrected_many_facet_candidate_reference_and_execution_preflight_pending"
mfrmr_cq_cb_invalid_candidate_id <-
  "mfrmr-0.2.3-conquest-six-arm-001"
mfrmr_cq_cb_invalid_candidate_reason <-
  "rsm_pcm_item_only_model_dimension_mismatch"

mfrmr_cq_cb_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_cb_require_contracts <- function() {
  target <- environment(mfrmr_cq_cb_require_contracts)
  required <- c(
    "mfrmr_cq_ptc_binding_template", "mfrmr_cq_ptf_build_tolerances",
    "mfrmr_cq_ptf_review", "mfrmr_cq_ptc_estimand_registry"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity_ok <- exists(
    "mfrmr_cq_ptf_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_ptf_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_prospective_tolerance_table_v1"
  )
  mfrmr_cq_cb_assert(
    all(available) && identity_ok,
    "Source the prospective ConQuest contract and tolerance freeze first."
  )
  invisible(TRUE)
}

mfrmr_cq_cb_arm_registry <- function() {
  data.frame(
    ArmId = c(
      "binary_q031", "binary_q061", "rsm_q031", "rsm_q061",
      "pcm_q031", "pcm_q061"
    ),
    Family = c("Binary", "Binary", "RSM", "RSM", "PCM", "PCM"),
    Nodes = c(31L, 61L, 31L, 61L, 31L, 61L),
    RunDirectory = c(
      "binary/q031a", "binary/q061", "additive/rsm_q031",
      "additive/rsm_q061", "additive/pcm_q031", "additive/pcm_q061"
    ),
    Prefix = c(
      "cq_q031a", "cq_q061", "cq_additive_rsm_q031",
      "cq_additive_rsm_q061", "cq_additive_pcm_q031",
      "cq_additive_pcm_q061"
    ),
    CommandSHA256 = c(
      "61a7e9c9c4f8303deb4eff40027c245d66442eb63021a4109f5ec6c69c2bee6a",
      "f0a2d1d5f9c8d30114088da3e61c29b6380e02e769513cb951b08296d72c45ea",
      "4b702d767116f139c27aca209b5b137bfc279e7a2c4eefcb728b8062d841517c",
      "a62aa3aa65bdaa73e489088206043f46efc11dec48a1c099e0504d2bdb0e1b06",
      "88de0c97e32032e92111fca64cc2e4c202080c661f4bfedbb1c35dd4b2b6956f",
      "e49bcc244cdd2edd8fcaebea800fd0369403ed986197ac2298717858f6df9538"
    ),
    InputSHA256 = c(
      rep(
        "bd61f489075f5db71774933faf951299ef54082ad95535f38a84b3a0795ef01e",
        2L
      ),
      rep(
        "391687fd8eb4e9a857950fcf232014833b0259a6ac7b483c7b1f898fdf03cf91",
        4L
      )
    ),
    stringsAsFactors = FALSE
  ) |>
    transform(
      CommandPath = file.path(RunDirectory, paste0(Prefix, ".cqc")),
      InputPath = file.path(RunDirectory, paste0(Prefix, "_wide.csv"))
    ) |>
    subset(select = c(
      ArmId, Family, Nodes, RunDirectory, Prefix, CommandPath, InputPath,
      CommandSHA256, InputSHA256
    ))
}

mfrmr_cq_cb_model_dimension_registry <- function() {
  data.frame(
    ArmId = c(
      "binary_q031", "binary_q061", "rsm_q031", "rsm_q061",
      "pcm_q031", "pcm_q061"
    ),
    Family = c("Binary", "Binary", "RSM", "RSM", "PCM", "PCM"),
    Nodes = c(31L, 61L, 31L, 61L, 31L, 61L),
    ModelStatement = c(
      "model item;", "model item;",
      "model rater + criterion + step;",
      "model rater + criterion + step;",
      "model rater + criterion + criterion*step;",
      "model rater + criterion + criterion*step;"
    ),
    FacetDeclaration = c(
      "", "", rep("facets=criterion(2) rater(2)", 4L)
    ),
    ItemDimension = c(TRUE, TRUE, rep(FALSE, 4L)),
    RaterDimension = c(FALSE, FALSE, rep(TRUE, 4L)),
    CriterionDimension = c(FALSE, FALSE, rep(TRUE, 4L)),
    StepStructure = c(
      "none", "none", "shared", "shared",
      "criterion_specific", "criterion_specific"
    ),
    ExpectedFreeDimension = c(8L, 8L, 7L, 7L, 9L, 9L),
    ExpectedInputColumns = c(8L, 8L, 6L, 6L, 6L, 6L),
    RequiredEstimandClasses = c(
      rep(paste(c(
        "item_difficulty", "objective", "population_intercept",
        "population_slope", "population_variance"
      ), collapse = ";"), 2L),
      rep(paste(c(
        "criterion_difficulty", "objective", "population_intercept",
        "population_slope", "population_variance", "rater_severity",
        "shared_step"
      ), collapse = ";"), 2L),
      rep(paste(c(
        "criterion_difficulty", "criterion_specific_step", "objective",
        "population_intercept", "population_slope", "population_variance",
        "rater_severity"
      ), collapse = ";"), 2L)
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_cb_invalid_candidate_registry <- function() {
  data.frame(
    CandidateId = mfrmr_cq_cb_invalid_candidate_id,
    FormerlyBoundAtCommit =
      "7a04fd4cde65d4be985aa2a908ab4d8e65fadba5",
    InvalidatedByCandidate = mfrmr_cq_cb_candidate_id,
    InvalidReason = mfrmr_cq_cb_invalid_candidate_reason,
    RSMObservedModel = "item + step",
    PCMObservedModel = "item + item*step",
    RaterDimensionPresent = FALSE,
    CriterionDimensionPresent = FALSE,
    FrozenToleranceEstimandsCovered = FALSE,
    CandidateBindingReady = FALSE,
    CandidateExecutionAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_cb_output_registry <- function() {
  arms <- mfrmr_cq_cb_arm_registry()
  binary_suffix <- c(
    console_log = "_run.log",
    parameters = "_conquest_parameters.csv",
    regression = "_conquest_reg_coefficients.csv",
    covariance = "_conquest_covariance.csv",
    cases = "_conquest_cases_eap.csv",
    history = "_conquest_history.csv",
    parameter_review = "_conquest_parameters_review.txt"
  )
  additive_suffix <- c(
    console_log = "_console.log",
    internal_log = "_conquest_internal.log",
    parameters = "_conquest_parameters.csv",
    amatrix = "_conquest_amatrix.csv",
    regression = "_conquest_reg_coefficients.csv",
    covariance = "_conquest_covariance.csv",
    cases = "_conquest_cases_eap.csv",
    history = "_conquest_history.csv",
    parameter_review = "_conquest_parameters_review.txt"
  )
  out <- do.call(rbind, lapply(seq_len(nrow(arms)), function(index) {
    suffix <- if (identical(arms$Family[index], "Binary")) {
      binary_suffix
    } else {
      additive_suffix
    }
    data.frame(
      ArmId = arms$ArmId[index],
      OutputKind = names(suffix),
      RelativePath = file.path(
        arms$RunDirectory[index], paste0(arms$Prefix[index], unname(suffix))
      ),
      ExpectedAbsentAtBinding = TRUE,
      stringsAsFactors = FALSE
    )
  }))
  out <- out[order(out$ArmId, out$OutputKind), , drop = FALSE]
  rownames(out) <- NULL
  mfrmr_cq_cb_assert(
    nrow(out) == 50L && !anyDuplicated(out$RelativePath),
    "The corrected ConQuest candidate must have 50 unique expected output paths."
  )
  out
}

mfrmr_cq_cb_canonical_text <- function(x, order_columns) {
  mfrmr_cq_cb_assert(
    is.data.frame(x) && all(order_columns %in% names(x)),
    "The ConQuest candidate registry is malformed."
  )
  order_args <- lapply(order_columns, function(column) x[[column]])
  x <- x[do.call(order, order_args), , drop = FALSE]
  rows <- apply(x, 1L, paste, collapse = "\t")
  paste(c(paste(names(x), collapse = "\t"), rows), collapse = "\n")
}

mfrmr_cq_cb_bundle_hashes <- function() {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The ConQuest candidate binding requires `digest`.", call. = FALSE)
  }
  arms <- mfrmr_cq_cb_arm_registry()
  commands <- arms[, c(
    "ArmId", "Family", "Nodes", "CommandPath", "CommandSHA256"
  )]
  inputs <- arms[, c(
    "ArmId", "Family", "Nodes", "InputPath", "InputSHA256"
  )]
  dimensions <- mfrmr_cq_cb_model_dimension_registry()
  outputs <- mfrmr_cq_cb_output_registry()
  data.frame(
    Bundle = c(
      "command", "input", "model_dimension", "expected_empty_outputs"
    ),
    SHA256 = c(
      digest::digest(
        mfrmr_cq_cb_canonical_text(commands, "ArmId"),
        algo = "sha256", serialize = FALSE
      ),
      digest::digest(
        mfrmr_cq_cb_canonical_text(inputs, "ArmId"),
        algo = "sha256", serialize = FALSE
      ),
      digest::digest(
        mfrmr_cq_cb_canonical_text(dimensions, "ArmId"),
        algo = "sha256", serialize = FALSE
      ),
      digest::digest(
        mfrmr_cq_cb_canonical_text(outputs, c("ArmId", "OutputKind")),
        algo = "sha256", serialize = FALSE
      )
    ),
    ExpectedSHA256 = c(
      mfrmr_cq_cb_command_bundle_sha256,
      mfrmr_cq_cb_input_bundle_sha256,
      mfrmr_cq_cb_model_dimension_bundle_sha256,
      mfrmr_cq_cb_expected_empty_outputs_sha256
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_cb_model_dimension_status <- function() {
  mfrmr_cq_cb_require_contracts()
  registry <- mfrmr_cq_cb_model_dimension_registry()
  tolerance <- mfrmr_cq_ptc_estimand_registry()
  expected <- vapply(seq_len(nrow(registry)), function(index) {
    classes <- unique(as.character(
      tolerance$EstimandClass[tolerance$Family == registry$Family[index]]
    ))
    paste(sort(classes), collapse = ";")
  }, character(1L))
  actual_hash <- digest::digest(
    mfrmr_cq_cb_canonical_text(registry, "ArmId"),
    algo = "sha256", serialize = FALSE
  )
  list(
    registry = registry,
    expected_estimand_classes = expected,
    estimand_coverage_ok = identical(
      as.character(registry$RequiredEstimandClasses), expected
    ),
    model_dimension_sha256 = actual_hash,
    expected_model_dimension_sha256 =
      mfrmr_cq_cb_model_dimension_bundle_sha256,
    hash_frozen = identical(
      actual_hash, mfrmr_cq_cb_model_dimension_bundle_sha256
    ),
    model_dimension_ready = identical(
      as.character(registry$RequiredEstimandClasses), expected
    ) && identical(actual_hash, mfrmr_cq_cb_model_dimension_bundle_sha256)
  )
}

mfrmr_cq_cb_binding <- function() {
  mfrmr_cq_cb_require_contracts()
  out <- mfrmr_cq_ptc_binding_template()
  out$CandidateId <- mfrmr_cq_cb_candidate_id
  out$SourceCommit <- mfrmr_cq_cb_source_commit
  out$SourceTreeSHA256 <- mfrmr_cq_cb_source_tree_sha256
  out$CommandBundleSHA256 <- mfrmr_cq_cb_command_bundle_sha256
  out$InputBundleSHA256 <- mfrmr_cq_cb_input_bundle_sha256
  out$ModelDimensionBundleSHA256 <-
    mfrmr_cq_cb_model_dimension_bundle_sha256
  out$ExpectedEmptyOutputsSHA256 <-
    mfrmr_cq_cb_expected_empty_outputs_sha256
  out$CandidateFamilies <- mfrmr_cq_ptc_candidate_families
  out$CandidateQuadratureNodes <- mfrmr_cq_ptc_candidate_nodes
  out$CandidateArmCount <- mfrmr_cq_ptc_candidate_arm_count
  out$NormalizerCoverageFamilies <- mfrmr_cq_ptc_candidate_families
  out$NormalizerCoverageRegistrySHA256 <-
    mfrmr_cq_ptc_normalizer_coverage_registry_sha256
  out$SourcePrecisionPolicyId <- mfrmr_cq_ptc_source_precision_policy_id
  out$SourcePrecisionScope <- mfrmr_cq_ptc_source_precision_scope
  out$SourcePrecisionCoverageFamilies <- mfrmr_cq_ptc_candidate_families
  out$SourcePrecisionCoverageRegistrySHA256 <-
    mfrmr_cq_ptc_source_precision_coverage_registry_sha256
  out$SourcePrecisionPolicySHA256 <- mfrmr_cq_cb_source_precision_sha256
  out$SourcePrecisionReady <- TRUE
  out$SourcePrecisionIndependentOfCandidateOutput <- TRUE
  out$HiddenSolutionEquivalenceEligible <- FALSE
  out$ToleranceTableSHA256 <- mfrmr_cq_ptf_expected_tolerance_sha256
  out$FrozenBeforeCandidateExecution <- TRUE
  out$CandidateOutputsPresentAtFreeze <- FALSE
  out$CandidateOutputsOpenedAtFreeze <- FALSE
  out$CalibrationCanPassNewRule <- FALSE
  out
}

mfrmr_cq_cb_validation_dir <- function() {
  source_file <- tryCatch(sys.frame(1L)$ofile, error = function(...) NULL)
  if (is.null(source_file) || !nzchar(source_file)) source_file <- ""
  roots <- c(
    getwd(), dirname(source_file), file.path(getwd(), ".."),
    file.path(getwd(), "..", ".."),
    file.path(getwd(), "..", "..", "..")
  )
  candidates <- unique(normalizePath(c(
    roots, file.path(roots, "inst", "validation")
  ), winslash = "/", mustWork = FALSE))
  hit <- candidates[file.exists(file.path(
    candidates, basename(mfrmr_cq_cb_source_precision_artifact)
  ))]
  mfrmr_cq_cb_assert(
    length(hit) >= 1L,
    "The bound ConQuest reported-output precision policy is unavailable."
  )
  hit[1L]
}

mfrmr_cq_cb_policy_status <- function() {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The ConQuest candidate policy audit requires `digest`.", call. = FALSE)
  }
  path <- file.path(
    mfrmr_cq_cb_validation_dir(),
    basename(mfrmr_cq_cb_source_precision_artifact)
  )
  actual <- unname(digest::digest(
    path, algo = "sha256", file = TRUE, serialize = FALSE
  ))
  data.frame(
    SourceArtifact = mfrmr_cq_cb_source_precision_artifact,
    ExpectedSHA256 = mfrmr_cq_cb_source_precision_sha256,
    ActualSHA256 = actual,
    IdentityOK = identical(actual, mfrmr_cq_cb_source_precision_sha256),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_cb_validate_binding <- function(binding) {
  mfrmr_cq_cb_require_contracts()
  canonical <- mfrmr_cq_cb_binding()
  freeze <- mfrmr_cq_ptf_review(binding)
  policy <- mfrmr_cq_cb_policy_status()
  dimension <- mfrmr_cq_cb_model_dimension_status()
  identical_binding <- identical(binding, canonical)
  list(
    binding = binding,
    canonical_binding = canonical,
    freeze = freeze,
    policy = policy,
    model_dimension = dimension,
    binding_identical = identical_binding,
    binding_ready = identical_binding && isTRUE(freeze$candidate_bound) &&
      isTRUE(policy$IdentityOK) && isTRUE(dimension$model_dimension_ready)
  )
}

mfrmr_cq_cb_file_sha256 <- function(path) {
  if (!file.exists(path)) return(NA_character_)
  unname(digest::digest(
    path, algo = "sha256", file = TRUE, serialize = FALSE
  ))
}

mfrmr_cq_cb_command_dimension_audit <- function(candidate_root) {
  root <- normalizePath(
    as.character(candidate_root)[1L], winslash = "/", mustWork = FALSE
  )
  arms <- mfrmr_cq_cb_arm_registry()
  dimensions <- mfrmr_cq_cb_model_dimension_registry()
  dimensions <- dimensions[match(arms$ArmId, dimensions$ArmId), , drop = FALSE]
  rows <- lapply(seq_len(nrow(arms)), function(index) {
    command_path <- file.path(root, arms$CommandPath[index])
    input_path <- file.path(root, arms$InputPath[index])
    command <- if (file.exists(command_path)) {
      trimws(readLines(command_path, warn = FALSE))
    } else {
      character(0)
    }
    model_lines <- command[grepl("^model[[:space:]]", command)]
    node_token <- paste0("nodes=", dimensions$Nodes[index], ",")
    facet_token <- dimensions$FacetDeclaration[index]
    input_columns <- if (file.exists(input_path)) {
      length(names(utils::read.csv(
        input_path, nrows = 0L, check.names = FALSE
      )))
    } else {
      NA_integer_
    }
    facet_ok <- if (nzchar(facet_token)) {
      any(grepl(facet_token, command, fixed = TRUE))
    } else {
      !any(grepl("facets=", command, fixed = TRUE))
    }
    data.frame(
      ArmId = arms$ArmId[index],
      ExpectedModelStatement = dimensions$ModelStatement[index],
      ObservedModelStatement = if (length(model_lines) == 1L) {
        model_lines
      } else {
        NA_character_
      },
      ModelStatementOK = length(model_lines) == 1L && identical(
        model_lines, dimensions$ModelStatement[index]
      ),
      NodeTokenOK = any(grepl(node_token, command, fixed = TRUE)),
      FacetDeclarationOK = facet_ok,
      ExpectedInputColumns = dimensions$ExpectedInputColumns[index],
      ObservedInputColumns = input_columns,
      InputSchemaOK = identical(
        as.integer(input_columns),
        as.integer(dimensions$ExpectedInputColumns[index])
      ),
      ModelDimensionOK = length(model_lines) == 1L && identical(
        model_lines, dimensions$ModelStatement[index]
      ) && any(grepl(node_token, command, fixed = TRUE)) && facet_ok &&
        identical(
          as.integer(input_columns),
          as.integer(dimensions$ExpectedInputColumns[index])
        ),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_cq_cb_invalid_candidate_review <- function(candidate_root = NULL) {
  registry <- mfrmr_cq_cb_invalid_candidate_registry()
  observed <- NULL
  if (!is.null(candidate_root)) {
    root <- normalizePath(
      as.character(candidate_root)[1L], winslash = "/", mustWork = FALSE
    )
    paths <- file.path(root, c(
      "polytomous/rsm_q031a/cq_rsm_q031a.cqc",
      "polytomous/rsm_q061/cq_rsm_q061.cqc",
      "polytomous/pcm_q031a/cq_pcm_q031a.cqc",
      "polytomous/pcm_q061/cq_pcm_q061.cqc"
    ))
    observed <- vapply(paths, function(path) {
      if (!file.exists(path)) return(NA_character_)
      command <- trimws(readLines(path, warn = FALSE))
      model <- command[grepl("^model[[:space:]]", command)]
      if (length(model) == 1L) model else NA_character_
    }, character(1L))
  }
  list(
    status = "invalid_model_dimension_contract",
    registry = registry,
    observed_model_statements = observed,
    candidate_binding_ready = FALSE,
    candidate_execution_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_cb_file_audit <- function(candidate_root) {
  mfrmr_cq_cb_assert(
    requireNamespace("digest", quietly = TRUE),
    "The ConQuest candidate file audit requires `digest`."
  )
  root <- normalizePath(
    as.character(candidate_root)[1L], winslash = "/", mustWork = FALSE
  )
  arms <- mfrmr_cq_cb_arm_registry()
  arms$ObservedCommandSHA256 <- vapply(
    file.path(root, arms$CommandPath), mfrmr_cq_cb_file_sha256, character(1L)
  )
  arms$ObservedInputSHA256 <- vapply(
    file.path(root, arms$InputPath), mfrmr_cq_cb_file_sha256, character(1L)
  )
  arms$CommandIdentityOK <- arms$ObservedCommandSHA256 == arms$CommandSHA256
  arms$InputIdentityOK <- arms$ObservedInputSHA256 == arms$InputSHA256
  outputs <- mfrmr_cq_cb_output_registry()
  outputs$ObservedPresent <- file.exists(file.path(root, outputs$RelativePath))
  dimensions <- mfrmr_cq_cb_command_dimension_audit(root)
  list(
    candidate_root = root,
    arms = arms,
    outputs = outputs,
    model_dimensions = dimensions,
    all_commands_ready = all(arms$CommandIdentityOK %in% TRUE),
    all_inputs_ready = all(arms$InputIdentityOK %in% TRUE),
    all_model_dimensions_ready = all(dimensions$ModelDimensionOK %in% TRUE),
    all_outputs_absent = !any(outputs$ObservedPresent),
    local_bundle_verified = all(arms$CommandIdentityOK %in% TRUE) &&
      all(arms$InputIdentityOK %in% TRUE) &&
      all(dimensions$ModelDimensionOK %in% TRUE) &&
      !any(outputs$ObservedPresent)
  )
}

mfrmr_cq_cb_source_status <- function(repo_root = ".") {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The ConQuest candidate source audit requires `digest`.", call. = FALSE)
  }
  root <- normalizePath(repo_root, winslash = "/", mustWork = FALSE)
  if (!dir.exists(file.path(root, ".git"))) {
    return(data.frame(
      Available = FALSE, ExpectedCommit = mfrmr_cq_cb_source_commit,
      ActualTreeSHA256 = NA_character_,
      ExpectedTreeSHA256 = mfrmr_cq_cb_source_tree_sha256,
      IdentityOK = FALSE, stringsAsFactors = FALSE
    ))
  }
  lines <- tryCatch(
    system2(
      "git", c(
        "-C", root, "ls-tree", "-r", "--full-tree",
        mfrmr_cq_cb_source_commit
      ), stdout = TRUE, stderr = FALSE
    ),
    error = function(...) character(0)
  )
  actual <- if (length(lines) > 0L) {
    digest::digest(
      paste(c(lines, ""), collapse = "\n"),
      algo = "sha256", serialize = FALSE
    )
  } else {
    NA_character_
  }
  data.frame(
    Available = length(lines) > 0L,
    ExpectedCommit = mfrmr_cq_cb_source_commit,
    ActualTreeSHA256 = actual,
    ExpectedTreeSHA256 = mfrmr_cq_cb_source_tree_sha256,
    IdentityOK = identical(actual, mfrmr_cq_cb_source_tree_sha256),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_cb_review <- function(
    candidate_root = NULL, binding = mfrmr_cq_cb_binding()) {
  mfrmr_cq_cb_require_contracts()
  hashes <- mfrmr_cq_cb_bundle_hashes()
  binding_status <- mfrmr_cq_cb_validate_binding(binding)
  freeze <- binding_status$freeze
  local <- if (is.null(candidate_root)) NULL else {
    mfrmr_cq_cb_file_audit(candidate_root)
  }
  binding_ready <- isTRUE(binding_status$binding_ready) &&
    all(hashes$SHA256 == hashes$ExpectedSHA256)
  local_verified <- !is.null(local) && isTRUE(local$local_bundle_verified)
  out <- list(
    specification = mfrmr_cq_cb_specification,
    contract_version = mfrmr_cq_cb_contract,
    status = if (!binding_ready) {
      "candidate_binding_invalid"
    } else if (is.null(local)) {
      "candidate_binding_frozen_external_bundle_not_locally_checked"
    } else if (!local_verified) {
      "candidate_bundle_identity_or_empty_output_check_failed"
    } else {
      "candidate_binding_and_local_bundle_verified_execution_held"
    },
    binding = binding,
    binding_status = binding_status,
    invalidated_candidate = mfrmr_cq_cb_invalid_candidate_review(),
    freeze = freeze,
    bundle_hashes = hashes,
    local_audit = local,
    candidate_binding_ready = binding_ready,
    local_bundle_verified = local_verified,
    candidate_core_structurally_authorized = binding_ready && local_verified,
    candidate_execution_authorized = FALSE,
    execution_hold_reason = mfrmr_cq_cb_execution_hold_reason,
    numerical_reference_state = "pending_corrected_candidate_preflight",
    inference_readiness_required_for_numerical_reference = FALSE,
    opened_calibration_reclassification_authorized = FALSE,
    hidden_solution_equivalence_eligible = FALSE,
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE,
    sparse_extension_authorized = FALSE,
    large_simulation_authorized = FALSE
  )
  class(out) <- c("mfrmr_conquest_candidate_binding_review", class(out))
  out
}
