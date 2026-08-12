# Repository-only binding for the first prospective six-arm ConQuest candidate.
# It freezes source, command, input, and expected-empty-output identities. It
# never launches ConQuest and deliberately holds execution while the current
# polytomous mfrmr reference fits remain review rather than inference-ready.

mfrmr_cq_cb_specification <-
  "0.2.3-wave-c-conquest-six-arm-candidate-binding-v1"
mfrmr_cq_cb_contract <- "mfrmr_conquest_six_arm_candidate_binding_v1"
mfrmr_cq_cb_candidate_id <- "mfrmr-0.2.3-conquest-six-arm-001"
mfrmr_cq_cb_candidate_root <-
  "validation-results/conquest-six-arm-candidate-001-core"
mfrmr_cq_cb_source_commit <-
  "7a04fd4cde65d4be985aa2a908ab4d8e65fadba5"
mfrmr_cq_cb_source_tree_sha256 <-
  "bcb700d2757afab3aa1e2330210e36add4bc59cdc2f44e458762b445014a4f4b"
mfrmr_cq_cb_command_bundle_sha256 <-
  "be3127562ea8011b8076b8d1f3a0a5213ba5444803ee567fcbab0941c36874e4"
mfrmr_cq_cb_input_bundle_sha256 <-
  "a7d30cb32b08ccb3f50b89dfc21f14352241ff648743ba207c2c38fcbb905fa1"
mfrmr_cq_cb_expected_empty_outputs_sha256 <-
  "9850792b061b1d9d5dfdfe360e65e5c6b65fd6e35d70aa3dc0a81ae8f126ce43"
mfrmr_cq_cb_source_precision_artifact <-
  "inst/validation/conquest-reported-output-precision-contract-0.2.3.R"
mfrmr_cq_cb_source_precision_sha256 <-
  "e0e80ebd96c48634ddd39231959bb0c5cfcd6c036c39c4e5bf8224e19164fd53"
mfrmr_cq_cb_execution_hold_reason <-
  "polytomous_mfrmr_reference_inference_readiness_unresolved"

mfrmr_cq_cb_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_cb_require_contracts <- function() {
  target <- environment(mfrmr_cq_cb_require_contracts)
  required <- c(
    "mfrmr_cq_ptc_binding_template", "mfrmr_cq_ptf_build_tolerances",
    "mfrmr_cq_ptf_review"
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
      "binary/q031a", "binary/q061", "polytomous/rsm_q031a",
      "polytomous/rsm_q061", "polytomous/pcm_q031a",
      "polytomous/pcm_q061"
    ),
    Prefix = c(
      "cq_q031a", "cq_q061", "cq_rsm_q031a", "cq_rsm_q061",
      "cq_pcm_q031a", "cq_pcm_q061"
    ),
    CommandSHA256 = c(
      "61a7e9c9c4f8303deb4eff40027c245d66442eb63021a4109f5ec6c69c2bee6a",
      "f0a2d1d5f9c8d30114088da3e61c29b6380e02e769513cb951b08296d72c45ea",
      "8a28252f97b67adccadf950788375285a926d543de643addd14776e07b03bb1c",
      "1bf284d2555da1b454d8baa7a81c5af26ffff72e40dd7658d1cfb1c9a80cadfb",
      "4ae9c62724ff7481e1c7ed29f913ade09d68c3e7ed972a439aa6a7e66ad80232",
      "47646f249bff4b038d6a4ba63e95423b29f2b532181211e1dde3833623e4b6cb"
    ),
    InputSHA256 = c(
      rep(
        "bd61f489075f5db71774933faf951299ef54082ad95535f38a84b3a0795ef01e",
        2L
      ),
      rep(
        "875106ce5fc501c76229eda00aa37b4a0556d352233c2990347d263d59cce3ce",
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
  polytomous_suffix <- c(
    console_log = "_console.log",
    internal_log = "_conquest_internal.log",
    parameters = "_conquest_parameters.csv",
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
      polytomous_suffix
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
    nrow(out) == 46L && !anyDuplicated(out$RelativePath),
    "The ConQuest candidate must have 46 unique expected output paths."
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
  outputs <- mfrmr_cq_cb_output_registry()
  data.frame(
    Bundle = c("command", "input", "expected_empty_outputs"),
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
        mfrmr_cq_cb_canonical_text(outputs, c("ArmId", "OutputKind")),
        algo = "sha256", serialize = FALSE
      )
    ),
    ExpectedSHA256 = c(
      mfrmr_cq_cb_command_bundle_sha256,
      mfrmr_cq_cb_input_bundle_sha256,
      mfrmr_cq_cb_expected_empty_outputs_sha256
    ),
    stringsAsFactors = FALSE
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
  identical_binding <- identical(binding, canonical)
  list(
    binding = binding,
    canonical_binding = canonical,
    freeze = freeze,
    policy = policy,
    binding_identical = identical_binding,
    binding_ready = identical_binding && isTRUE(freeze$candidate_bound) &&
      isTRUE(policy$IdentityOK)
  )
}

mfrmr_cq_cb_file_sha256 <- function(path) {
  if (!file.exists(path)) return(NA_character_)
  unname(digest::digest(
    path, algo = "sha256", file = TRUE, serialize = FALSE
  ))
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
  list(
    candidate_root = root,
    arms = arms,
    outputs = outputs,
    all_commands_ready = all(arms$CommandIdentityOK %in% TRUE),
    all_inputs_ready = all(arms$InputIdentityOK %in% TRUE),
    all_outputs_absent = !any(outputs$ObservedPresent),
    local_bundle_verified = all(arms$CommandIdentityOK %in% TRUE) &&
      all(arms$InputIdentityOK %in% TRUE) && !any(outputs$ObservedPresent)
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
    freeze = freeze,
    bundle_hashes = hashes,
    local_audit = local,
    candidate_binding_ready = binding_ready,
    local_bundle_verified = local_verified,
    candidate_core_structurally_authorized = binding_ready && local_verified,
    candidate_execution_authorized = FALSE,
    execution_hold_reason = mfrmr_cq_cb_execution_hold_reason,
    polytomous_reference_fit_readiness = "review",
    polytomous_reference_inference_ready = FALSE,
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
