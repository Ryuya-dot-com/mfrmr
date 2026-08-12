# Repository-only numerical-reference preflight for ConQuest candidate 003.
# Source the candidate-002 reference contract for its generic arm validators,
# then the candidate-003 binding. This file never launches ConQuest.

mfrmr_cq_c3rp_specification <-
  "0.2.3-wave-c-conquest-six-arm-candidate-003-reference-v1"
mfrmr_cq_c3rp_contract <-
  "mfrmr_conquest_six_arm_candidate_003_reference_v1"
mfrmr_cq_c3rp_candidate_id <- "mfrmr-0.2.3-conquest-six-arm-003"
mfrmr_cq_c3rp_reference_bundle_sha256 <-
  "0d23be47efce2965c8f4fa76c93d6aa569bc5aa313bce6550286ac2d9f7942a8"
mfrmr_cq_c3rp_source_bundle_sha256 <-
  "cd37c3b75517c7af6afb4834fd6ec26d3e6b254a0a966c9b425d15d74ad986c2"
mfrmr_cq_c3rp_provenance_bundle_sha256 <-
  "556c87bcfa8b70e46e4f89389edbe99a31e9dcd8cc7577e2e8e22bcbbb10d7c1"

mfrmr_cq_c3rp_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_c3rp_require_contracts <- function() {
  target <- environment(mfrmr_cq_c3rp_require_contracts)
  required <- c(
    "mfrmr_cq_c3_review", "mfrmr_cq_c3_source_status",
    "mfrmr_cq_crp_reference_registry", "mfrmr_cq_crp_binary_arm",
    "mfrmr_cq_crp_additive_arm", "mfrmr_cq_cb_canonical_text",
    "mfrmr_cq_cb_file_sha256"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity_ok <- exists(
    "mfrmr_cq_c3_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_c3_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_six_arm_candidate_003_binding_v1"
  ) && identical(
    get("mfrmr_cq_c3_candidate_id", envir = target, inherits = TRUE),
    mfrmr_cq_c3rp_candidate_id
  )
  mfrmr_cq_c3rp_assert(
    all(available) && identity_ok,
    paste0(
      "Source the candidate-002 generic reference validators and the ",
      "candidate-003 binding before this preflight."
    )
  )
  invisible(TRUE)
}

mfrmr_cq_c3rp_reference_registry <- function() {
  mfrmr_cq_c3rp_require_contracts()
  mfrmr_cq_crp_reference_registry()
}

mfrmr_cq_c3rp_source_registry <- function() {
  data.frame(
    Artifact = c(
      "inst/validation/conquest-binary-ladder-pilot-0.2.3.R",
      "inst/validation/conquest-additive-mfrm-design-0.2.3.R",
      paste0(
        "inst/validation/",
        "conquest-additive-mfrm-reference-preflight-0.2.3.R"
      )
    ),
    SHA256 = c(
      "1a135e9fa877775284f1657e55a41246876fe3f7fde337e545b9a3339489e9a0",
      "4698b9f7eb83896c1f97e8b6eb98326c00b028ca0517c2d954c5f1fce8633a21",
      "a91d41916eb151efac2270ae3d4da05e8f918597396b5436b2d354edec4a8f2a"
    ),
    SourceCommit = "4f86fa187e010d3c9faff647c88abc38ddcf5b0f",
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_c3rp_provenance_registry <- function() {
  data.frame(
    Artifact = c(
      "additive_source_manifest", "additive_reference_manifest",
      "additive_q_sensitivity"
    ),
    RelativePath = file.path(
      "additive", "mfrmr_reference",
      c(
        "source_manifest.csv", "reference_manifest.csv",
        "q31_q61_sensitivity.csv"
      )
    ),
    SHA256 = c(
      "230dc2427644c44ebeb41e09c77e73b64096f41350d0e2d5cd2bf76cb130ea52",
      "cb43a98319e29dcb70207c5cee188f2f91b0aa1170c28554985bd731dceda032",
      "43f8d24f28e0732d55c772677c5a4abacc610eeaebed813fbc3bcd5af73a595a"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_c3rp_bundle_hashes <- function() {
  mfrmr_cq_c3rp_require_contracts()
  mfrmr_cq_c3rp_assert(
    requireNamespace("digest", quietly = TRUE),
    "The candidate-003 reference preflight requires `digest`."
  )
  reference <- mfrmr_cq_c3rp_reference_registry()
  source <- mfrmr_cq_c3rp_source_registry()
  provenance <- mfrmr_cq_c3rp_provenance_registry()
  data.frame(
    Bundle = c(
      "reference_artifact", "reference_source", "reference_provenance"
    ),
    SHA256 = c(
      digest::digest(
        mfrmr_cq_cb_canonical_text(reference, c("ArmId", "ArtifactKind")),
        algo = "sha256", serialize = FALSE
      ),
      digest::digest(
        mfrmr_cq_cb_canonical_text(source, "Artifact"),
        algo = "sha256", serialize = FALSE
      ),
      digest::digest(
        mfrmr_cq_cb_canonical_text(provenance, "Artifact"),
        algo = "sha256", serialize = FALSE
      )
    ),
    ExpectedSHA256 = c(
      mfrmr_cq_c3rp_reference_bundle_sha256,
      mfrmr_cq_c3rp_source_bundle_sha256,
      mfrmr_cq_c3rp_provenance_bundle_sha256
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_c3rp_provenance_audit <- function(candidate_root, repo_root) {
  root <- normalizePath(candidate_root, winslash = "/", mustWork = TRUE)
  repo <- normalizePath(repo_root, winslash = "/", mustWork = TRUE)
  provenance <- mfrmr_cq_c3rp_provenance_registry()
  provenance$ObservedSHA256 <- vapply(
    file.path(root, provenance$RelativePath),
    mfrmr_cq_cb_file_sha256, character(1L)
  )
  provenance$IdentityOK <- provenance$ObservedSHA256 == provenance$SHA256

  reference_dir <- file.path(root, "additive", "mfrmr_reference")
  source_manifest <- utils::read.csv(
    file.path(reference_dir, "source_manifest.csv"),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  reference_manifest <- utils::read.csv(
    file.path(reference_dir, "reference_manifest.csv"),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  source_manifest$ObservedSHA256 <- vapply(
    file.path(repo, source_manifest$RelativePath),
    mfrmr_cq_cb_file_sha256, character(1L)
  )
  source_manifest$IdentityOK <-
    source_manifest$ObservedSHA256 == source_manifest$SHA256
  source_tree <- digest::digest(
    paste(
      source_manifest$RelativePath, source_manifest$SHA256,
      sep = "=", collapse = "\n"
    ),
    algo = "sha256", serialize = FALSE
  )
  manifest_ok <- nrow(reference_manifest) == 4L &&
    length(unique(reference_manifest$SourceTreeSHA256)) == 1L &&
    identical(
      unique(reference_manifest$SourceTreeSHA256),
      unique(source_manifest$SourceTreeSHA256)
    ) && identical(source_tree, unique(source_manifest$SourceTreeSHA256)) &&
    length(unique(reference_manifest$SourceManifestSHA256)) == 1L &&
    identical(
      unique(reference_manifest$SourceManifestSHA256),
      provenance$SHA256[provenance$Artifact == "additive_source_manifest"]
    ) && all(!as.logical(reference_manifest$CandidateBound)) &&
    all(!as.logical(reference_manifest$ExternalExecutionAuthorized)) &&
    all(!as.logical(reference_manifest$ComparisonReady))
  list(
    registry = provenance,
    source_manifest = source_manifest,
    reference_manifest = reference_manifest,
    all_provenance_files_match = all(provenance$IdentityOK %in% TRUE),
    all_manifested_sources_match = all(source_manifest$IdentityOK %in% TRUE),
    additive_manifest_consistent = manifest_ok,
    provenance_ready = all(provenance$IdentityOK %in% TRUE) &&
      all(source_manifest$IdentityOK %in% TRUE) && manifest_ok
  )
}

mfrmr_cq_c3rp_review <- function(candidate_root, repo_root = ".") {
  mfrmr_cq_c3rp_require_contracts()
  root <- normalizePath(candidate_root, winslash = "/", mustWork = TRUE)
  repo <- normalizePath(repo_root, winslash = "/", mustWork = TRUE)
  registry <- mfrmr_cq_c3rp_reference_registry()
  registry$ObservedSHA256 <- vapply(
    file.path(root, registry$RelativePath),
    mfrmr_cq_cb_file_sha256, character(1L)
  )
  registry$IdentityOK <- registry$ObservedSHA256 == registry$SHA256
  source_registry <- mfrmr_cq_c3rp_source_registry()
  source_registry$ObservedSHA256 <- vapply(
    file.path(repo, source_registry$Artifact),
    mfrmr_cq_cb_file_sha256, character(1L)
  )
  source_registry$IdentityOK <-
    source_registry$ObservedSHA256 == source_registry$SHA256
  bundle <- mfrmr_cq_c3rp_bundle_hashes()
  binding <- mfrmr_cq_c3_review(root)
  source <- mfrmr_cq_c3_source_status(repo)
  provenance <- mfrmr_cq_c3rp_provenance_audit(root, repo)
  arm_spec <- data.frame(
    ArmId = c(
      "binary_q031", "binary_q061", "rsm_q031", "rsm_q061",
      "pcm_q031", "pcm_q061"
    ),
    Family = c("Binary", "Binary", "RSM", "RSM", "PCM", "PCM"),
    Nodes = c(31L, 61L, 31L, 61L, 31L, 61L),
    Npar = c(8L, 8L, 7L, 7L, 9L, 9L),
    stringsAsFactors = FALSE
  )
  reference <- lapply(seq_len(nrow(arm_spec)), function(index) {
    arm <- arm_spec[index, , drop = FALSE]
    if (arm$Family == "Binary") {
      mfrmr_cq_crp_binary_arm(root, registry, arm$ArmId, arm$Nodes)
    } else {
      mfrmr_cq_crp_additive_arm(
        root, registry, arm$ArmId, arm$Family, arm$Nodes, arm$Npar
      )
    }
  })
  arm_summary <- do.call(rbind, lapply(reference, `[[`, "summary"))
  integration <- do.call(rbind, lapply(c("Binary", "RSM", "PCM"), function(family) {
    index <- which(arm_spec$Family == family)
    q31 <- reference[[index[arm_spec$Nodes[index] == 31L]]]$free
    q61 <- reference[[index[arm_spec$Nodes[index] == 61L]]]$free
    deviance <- arm_summary$Deviance[arm_summary$Family == family]
    coordinate_difference <- max(abs(q61 - q31))
    deviance_difference <- abs(diff(deviance))
    data.frame(
      Family = family,
      CoordinateMaxAbsDifference = coordinate_difference,
      CoordinateTolerance = 2e-6,
      CoordinatePass = coordinate_difference <= 2e-6,
      DevianceAbsDifference = deviance_difference,
      DevianceTolerance = 2e-6,
      DeviancePass = deviance_difference <= 2e-6,
      stringsAsFactors = FALSE
    )
  }))
  ready <- all(registry$IdentityOK %in% TRUE) &&
    all(source_registry$IdentityOK %in% TRUE) &&
    all(bundle$SHA256 == bundle$ExpectedSHA256) &&
    isTRUE(binding$candidate_core_structurally_authorized) &&
    !isTRUE(binding$candidate_execution_authorized) &&
    isTRUE(source$IdentityOK) && isTRUE(provenance$provenance_ready) &&
    all(arm_summary$NumericalReferenceReady) &&
    all(integration$CoordinatePass) && all(integration$DeviancePass)
  list(
    specification = mfrmr_cq_c3rp_specification,
    contract_version = mfrmr_cq_c3rp_contract,
    status = if (ready) {
      "candidate_003_numerical_reference_ready_execution_handoff_pending"
    } else {
      "candidate_003_numerical_reference_invalid"
    },
    candidate_id = mfrmr_cq_c3rp_candidate_id,
    artifact_registry = registry,
    source_registry = source_registry,
    bundle_hashes = bundle,
    candidate_binding = binding,
    source_status = source,
    provenance = provenance,
    arm_summary = arm_summary,
    integration = integration,
    numerical_reference_ready = ready,
    inference_ready = FALSE,
    numerical_reference_promotes_inference = FALSE,
    candidate_execution_authorized = FALSE,
    execution_hold_reason = "candidate_003_execution_handoff_not_frozen",
    comparison_authorized = FALSE,
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE,
    sparse_extension_authorized = FALSE,
    large_simulation_authorized = FALSE
  )
}
