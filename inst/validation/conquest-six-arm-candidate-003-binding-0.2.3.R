# Repository-only binding for candidate 003 after removing the ConQuest-
# rejected prose preamble from the two Binary command files. It reuses no
# candidate-002 output and never launches ConQuest.

mfrmr_cq_c3_specification <-
  "0.2.3-wave-c-conquest-six-arm-candidate-003-binding-v1"
mfrmr_cq_c3_contract <- "mfrmr_conquest_six_arm_candidate_003_binding_v1"
mfrmr_cq_c3_candidate_id <- "mfrmr-0.2.3-conquest-six-arm-003"
mfrmr_cq_c3_candidate_root <-
  "validation-results/conquest-six-arm-candidate-003-core"
mfrmr_cq_c3_source_commit <- "4f86fa187e010d3c9faff647c88abc38ddcf5b0f"
mfrmr_cq_c3_source_tree_sha256 <-
  "b1b692bd533cce481d87ed75917070691963ba2abf3caceb0c70ec59299d898f"
mfrmr_cq_c3_command_bundle_sha256 <-
  "dd273c52bf58edc2f9e96253bcdc2694a29d2cb59d2bc4b45759066c35bb2666"
mfrmr_cq_c3_input_bundle_sha256 <-
  "cd595bc5a914297ea57f13b1f1fc5d8e6d4d9baacd3f7cadcf380a62806fddcb"
mfrmr_cq_c3_model_dimension_bundle_sha256 <-
  "12dafad2ac6e622288717ec60062f1eeb42c159db253dd46757834335b9e40f5"
mfrmr_cq_c3_expected_empty_outputs_sha256 <-
  "161488319712d87f720ef6dce8b1a3b5ae1dd0c2e40eea3897189655870d6d8a"

mfrmr_cq_c3_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_c3_require_base <- function() {
  target <- environment(mfrmr_cq_c3_require_base)
  required <- c(
    "mfrmr_cq_cb_canonical_text", "mfrmr_cq_cb_output_registry",
    "mfrmr_cq_cb_model_dimension_registry",
    "mfrmr_cq_cb_command_dimension_audit", "mfrmr_cq_cb_file_sha256",
    "mfrmr_cq_cb_policy_status", "mfrmr_cq_ptc_binding_template",
    "mfrmr_cq_ptf_review"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  mfrmr_cq_c3_assert(
    all(available),
    "Source the prospective tolerance and candidate-002 base contracts first."
  )
  invisible(TRUE)
}

mfrmr_cq_c3_arm_registry <- function() {
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
      "9212b6bc128fdeb3117bc992d15afeeb88c37143bf76d996ecf7a007f9fb0a8d",
      "ab343e081469b40370a979a02662d80996ede8ae22ef46e6319a34da97850a7c",
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

mfrmr_cq_c3_bundle_hashes <- function() {
  mfrmr_cq_c3_require_base()
  mfrmr_cq_c3_assert(
    requireNamespace("digest", quietly = TRUE),
    "Candidate-003 binding requires `digest`."
  )
  arms <- mfrmr_cq_c3_arm_registry()
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
      mfrmr_cq_c3_command_bundle_sha256,
      mfrmr_cq_c3_input_bundle_sha256,
      mfrmr_cq_c3_model_dimension_bundle_sha256,
      mfrmr_cq_c3_expected_empty_outputs_sha256
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_c3_binding <- function() {
  mfrmr_cq_c3_require_base()
  out <- mfrmr_cq_ptc_binding_template()
  out$CandidateId <- mfrmr_cq_c3_candidate_id
  out$SourceCommit <- mfrmr_cq_c3_source_commit
  out$SourceTreeSHA256 <- mfrmr_cq_c3_source_tree_sha256
  out$CommandBundleSHA256 <- mfrmr_cq_c3_command_bundle_sha256
  out$InputBundleSHA256 <- mfrmr_cq_c3_input_bundle_sha256
  out$ModelDimensionBundleSHA256 <-
    mfrmr_cq_c3_model_dimension_bundle_sha256
  out$ExpectedEmptyOutputsSHA256 <-
    mfrmr_cq_c3_expected_empty_outputs_sha256
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

mfrmr_cq_c3_source_status <- function(repo_root = ".") {
  root <- normalizePath(repo_root, winslash = "/", mustWork = FALSE)
  if (!dir.exists(file.path(root, ".git"))) {
    return(data.frame(
      Available = FALSE, ExpectedCommit = mfrmr_cq_c3_source_commit,
      ActualTreeSHA256 = NA_character_,
      ExpectedTreeSHA256 = mfrmr_cq_c3_source_tree_sha256,
      IdentityOK = FALSE, stringsAsFactors = FALSE
    ))
  }
  lines <- tryCatch(
    system2(
      "git", c(
        "-C", root, "ls-tree", "-r", "--full-tree",
        mfrmr_cq_c3_source_commit
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
    ExpectedCommit = mfrmr_cq_c3_source_commit,
    ActualTreeSHA256 = actual,
    ExpectedTreeSHA256 = mfrmr_cq_c3_source_tree_sha256,
    IdentityOK = identical(actual, mfrmr_cq_c3_source_tree_sha256),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_c3_file_audit <- function(candidate_root) {
  mfrmr_cq_c3_require_base()
  root <- normalizePath(
    as.character(candidate_root)[1L], winslash = "/", mustWork = FALSE
  )
  arms <- mfrmr_cq_c3_arm_registry()
  arms$ObservedCommandSHA256 <- vapply(
    file.path(root, arms$CommandPath), mfrmr_cq_cb_file_sha256, character(1L)
  )
  arms$ObservedInputSHA256 <- vapply(
    file.path(root, arms$InputPath), mfrmr_cq_cb_file_sha256, character(1L)
  )
  arms$CommandIdentityOK <- arms$ObservedCommandSHA256 == arms$CommandSHA256
  arms$InputIdentityOK <- arms$ObservedInputSHA256 == arms$InputSHA256
  dimensions <- mfrmr_cq_cb_command_dimension_audit(root)
  outputs <- mfrmr_cq_cb_output_registry()
  outputs$ObservedPresent <- file.exists(file.path(root, outputs$RelativePath))
  command_only <- vapply(seq_len(nrow(arms)), function(index) {
    path <- file.path(root, arms$CommandPath[index])
    if (!file.exists(path)) return(FALSE)
    command <- trimws(readLines(path, warn = FALSE))
    valid_first <- if (arms$Family[index] == "Binary") {
      grepl("^datafile[[:space:]]", command[1L])
    } else {
      grepl("^title[[:space:]]", command[1L])
    }
    valid_first &&
      !any(grepl("/*", command, fixed = TRUE)) &&
      !any(grepl("*/", command, fixed = TRUE))
  }, logical(1L))
  list(
    candidate_root = root,
    arms = arms,
    dimensions = dimensions,
    outputs = outputs,
    command_only = command_only,
    all_commands_ready = all(arms$CommandIdentityOK %in% TRUE),
    all_inputs_ready = all(arms$InputIdentityOK %in% TRUE),
    all_model_dimensions_ready = all(dimensions$ModelDimensionOK %in% TRUE),
    all_commands_executable_input_only = all(command_only),
    all_outputs_absent = !any(outputs$ObservedPresent),
    local_bundle_verified = all(arms$CommandIdentityOK %in% TRUE) &&
      all(arms$InputIdentityOK %in% TRUE) &&
      all(dimensions$ModelDimensionOK %in% TRUE) && all(command_only) &&
      !any(outputs$ObservedPresent)
  )
}

mfrmr_cq_c3_review <- function(candidate_root = NULL) {
  mfrmr_cq_c3_require_base()
  binding <- mfrmr_cq_c3_binding()
  freeze <- mfrmr_cq_ptf_review(binding)
  policy <- mfrmr_cq_cb_policy_status()
  hashes <- mfrmr_cq_c3_bundle_hashes()
  local <- if (is.null(candidate_root)) NULL else {
    mfrmr_cq_c3_file_audit(candidate_root)
  }
  binding_ready <- identical(binding, mfrmr_cq_c3_binding()) &&
    isTRUE(freeze$candidate_bound) && isTRUE(policy$IdentityOK) &&
    all(hashes$SHA256 == hashes$ExpectedSHA256)
  local_ready <- !is.null(local) && isTRUE(local$local_bundle_verified)
  list(
    specification = mfrmr_cq_c3_specification,
    contract_version = mfrmr_cq_c3_contract,
    status = if (!binding_ready) {
      "candidate_003_binding_invalid"
    } else if (is.null(local)) {
      "candidate_003_binding_ready_local_bundle_unchecked"
    } else if (!local_ready) {
      "candidate_003_local_bundle_invalid_or_opened"
    } else {
      "candidate_003_binding_and_local_bundle_ready_execution_held"
    },
    candidate_id = mfrmr_cq_c3_candidate_id,
    binding = binding,
    freeze = freeze,
    policy = policy,
    bundle_hashes = hashes,
    local_audit = local,
    candidate_binding_ready = binding_ready,
    local_bundle_verified = local_ready,
    candidate_core_structurally_authorized = binding_ready && local_ready,
    numerical_reference_ready = FALSE,
    candidate_execution_authorized = FALSE,
    execution_hold_reason = "candidate_003_reference_preflight_pending",
    comparison_authorized = FALSE,
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE,
    sparse_extension_authorized = FALSE,
    large_simulation_authorized = FALSE
  )
}
