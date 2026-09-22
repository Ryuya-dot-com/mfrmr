# mfrmr 0.2.3 owner-specific GPCM identity-propagation P1q audit
#
# P1q performs no fitting.  It audits the sealed Draft.66 owner pilot as a
# historical execution, constructs a derived (non-mutating) identity envelope
# for its aggregate tables, and separates that historical fixed-standard-
# normal MML evidence from the current free-population default.

mfrmr_goip_p1q_specification <- "0.2.3-draft.1"
mfrmr_goip_p1q_contract <-
  "mfrmr_gpcm_owner_identity_propagation_p1q_v1"
mfrmr_goip_p1q_historical_execution_sha256 <-
  "f96895c9325e15390c5fd896a687a47cf786f6b4f71af94c3481753991e38037"
mfrmr_goip_p1q_historical_execution_contract_sha256 <-
  "54d52c6a05b3fe98c0d19b54a66df8c8a83b21785f63a2300495f415f7733879"
mfrmr_goip_p1q_historical_runner_sha256 <-
  "b71ee33aa39d07431f43505d70dc531f0abb9db2529ff9a433ea74b4b1dbfb16"

mfrmr_goip_p1q_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_goip_p1q_hash_object <- function(object) {
  mfrmr_goip_p1q_assert(
    requireNamespace("digest", quietly = TRUE),
    "P1q requires package `digest`."
  )
  digest::digest(object, algo = "sha256", serialize = TRUE)
}

mfrmr_goip_p1q_identity_fields <- function() {
  c(
    "SlopeOwner", "StepOwner", "SlopeComposition",
    "LatentDimensionCount", "Estimator", "AbilityScaleContract",
    "RatingMin", "RatingMax", "DeclaredCategorySupport",
    "RuntimeIdentity"
  )
}

mfrmr_goip_p1q_historical_fields <- function() {
  setdiff(
    mfrmr_goip_p1q_identity_fields(),
    c("RatingMin", "RatingMax", "DeclaredCategorySupport")
  )
}

mfrmr_goip_p1q_surface_table <- function(bundle) {
  names <- c(
    "declared_manifest", "manifest", "results", "summary",
    "rate_summary", "numeric_summary", "execution_identity",
    "execution_policy", "checkpoint_ledger"
  )
  required <- mfrmr_goip_p1q_identity_fields()
  historical <- mfrmr_goip_p1q_historical_fields()
  rows <- lapply(names, function(name) {
    value <- bundle[[name]]
    columns <- if (is.data.frame(value)) names(value) else character(0)
    data.frame(
      Surface = name,
      Rows = if (is.data.frame(value)) nrow(value) else NA_integer_,
      HistoricalIdentityFieldsPresent = sum(historical %in% columns),
      HistoricalIdentityFieldsRequired = length(historical),
      MissingHistoricalIdentityFields = paste(
        setdiff(historical, columns), collapse = ";"
      ),
      ExactCategorySupportDirect = all(
        c("RatingMin", "RatingMax", "DeclaredCategorySupport") %in% columns
      ),
      FullDirectIdentity = all(required %in% columns),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_goip_p1q_cross_join <- function(left, right) {
  left <- as.data.frame(left, stringsAsFactors = FALSE)
  right <- as.data.frame(right, stringsAsFactors = FALSE)
  if (nrow(left) == 0L || nrow(right) == 0L) return(data.frame())
  left$.p1q_join <- 1L
  right$.p1q_join <- 1L
  out <- merge(left, right, by = ".p1q_join", sort = FALSE)
  out$.p1q_join <- NULL
  out
}

mfrmr_goip_p1q_identity_registry <- function(
    manifest, rating_min = 1L, rating_max = 4L) {
  mfrmr_goip_p1q_assert(
    is.data.frame(manifest) && nrow(manifest) > 0L,
    "P1q requires a non-empty declared manifest."
  )
  historical <- mfrmr_goip_p1q_historical_fields()
  mfrmr_goip_p1q_assert(
    all(historical %in% names(manifest)),
    "The historical manifest does not retain every owner identity field."
  )
  rating_min <- suppressWarnings(as.integer(rating_min)[1L])
  rating_max <- suppressWarnings(as.integer(rating_max)[1L])
  mfrmr_goip_p1q_assert(
    is.finite(rating_min) && is.finite(rating_max) &&
      rating_min == 1L && rating_max == 4L,
    "P1q accepts only the sealed Draft.66 declared category support 1:4."
  )
  registry <- unique(manifest[, historical, drop = FALSE])
  registry$RatingMin <- rating_min
  registry$RatingMax <- rating_max
  registry$DeclaredCategorySupport <- paste0(rating_min, ":", rating_max)
  registry$CategorySupportProvenance <- paste0(
    "sealed_execution_contract_sha256:",
    mfrmr_goip_p1q_historical_execution_contract_sha256
  )
  registry$HistoricalRuntimeBound <- TRUE
  registry <- registry[, c(
    mfrmr_goip_p1q_identity_fields(),
    "CategorySupportProvenance", "HistoricalRuntimeBound"
  ), drop = FALSE]
  registry <- registry[order(
    match(registry$SlopeOwner, c("Criterion", "Rater")),
    match(registry$Estimator, c("JML", "MML"))
  ), , drop = FALSE]
  rownames(registry) <- NULL
  mfrmr_goip_p1q_assert(
    nrow(registry) == 4L &&
      identical(sort(unique(registry$SlopeOwner)), c("Criterion", "Rater")) &&
      identical(sort(unique(registry$Estimator)), c("JML", "MML")) &&
      all(registry$SlopeOwner == registry$StepOwner) &&
      all(registry$SlopeComposition == "single_owner_relative_gm1") &&
      all(as.character(registry$LatentDimensionCount) == "1"),
    "The historical owner registry is not the declared four-stratum design."
  )
  registry
}

mfrmr_goip_p1q_add_support <- function(table, registry, by) {
  table <- as.data.frame(table, stringsAsFactors = FALSE)
  mfrmr_goip_p1q_assert(
    all(by %in% names(table)) && all(by %in% names(registry)),
    "P1q cannot bind an aggregate to its owner identity keys."
  )
  extra <- setdiff(names(registry), names(table))
  joined <- merge(
    table, registry[, c(by, extra), drop = FALSE],
    by = by, all.x = TRUE, sort = FALSE
  )
  mfrmr_goip_p1q_assert(
    nrow(joined) == nrow(table) &&
      all(mfrmr_goip_p1q_identity_fields() %in% names(joined)) &&
      all(complete.cases(joined[, mfrmr_goip_p1q_identity_fields(),
                                drop = FALSE])),
    "P1q aggregate identity binding was incomplete or non-unique."
  )
  joined
}

mfrmr_goip_p1q_build_envelope <- function(
    bundle, rating_min = 1L, rating_max = 4L) {
  required <- c(
    "declared_manifest", "manifest", "results", "summary",
    "rate_summary", "numeric_summary", "execution_identity",
    "execution_policy", "checkpoint_ledger"
  )
  mfrmr_goip_p1q_assert(
    is.list(bundle) && all(required %in% names(bundle)),
    "P1q requires the complete owner-pilot aggregate object."
  )
  manifest <- as.data.frame(bundle$declared_manifest,
                            stringsAsFactors = FALSE)
  execution_sha <- unique(as.character(
    bundle$execution_identity$ExecutionSHA256
  ))
  mfrmr_goip_p1q_assert(
    length(execution_sha) == 1L &&
      identical(execution_sha, mfrmr_goip_p1q_historical_execution_sha256),
    "P1q accepts only the sealed Draft.66 execution identity."
  )
  mfrmr_goip_p1q_assert(
    nrow(manifest) == 120L && nrow(bundle$results) == 120L &&
      identical(
        as.character(manifest$ScenarioId),
        as.character(bundle$results$ScenarioId)
      ),
    "P1q requires exact 120-row manifest/result coverage."
  )
  registry <- mfrmr_goip_p1q_identity_registry(
    manifest, rating_min = rating_min, rating_max = rating_max
  )
  registry_sha <- mfrmr_goip_p1q_hash_object(registry)

  result_rows <- mfrmr_goip_p1q_add_support(
    bundle$results, registry, by = c("SlopeOwner", "Estimator")
  )
  rate <- mfrmr_goip_p1q_add_support(
    bundle$rate_summary, registry, by = c("SlopeOwner", "Estimator")
  )
  numeric <- mfrmr_goip_p1q_add_support(
    bundle$numeric_summary, registry, by = c("SlopeOwner", "Estimator")
  )
  ledger_identity <- manifest[, c(
    "ScenarioId", "SlopeOwner", "Estimator"
  ), drop = FALSE]
  ledger <- merge(
    bundle$checkpoint_ledger, ledger_identity,
    by = "ScenarioId", all.x = TRUE, sort = FALSE
  )
  ledger <- mfrmr_goip_p1q_add_support(
    ledger, registry, by = c("SlopeOwner", "Estimator")
  )

  global_binding <- function(table) {
    table <- as.data.frame(table, stringsAsFactors = FALSE)
    overlap <- intersect(
      names(table), mfrmr_goip_p1q_identity_fields()
    )
    for (field in overlap) {
      observed <- unique(as.character(table[[field]]))
      expected <- unique(as.character(registry[[field]]))
      mfrmr_goip_p1q_assert(
        length(observed) == 1L && observed %in% expected,
        paste0("P1q global aggregate disagrees on ", field, ".")
      )
    }
    registry_add <- registry[, setdiff(names(registry), names(table)),
                             drop = FALSE]
    out <- mfrmr_goip_p1q_cross_join(table, registry_add)
    out$IdentityRegistrySHA256 <- registry_sha
    out$HistoricalExecutionSHA256 <- execution_sha
    out
  }
  surfaces <- list(
    results = result_rows,
    summary = global_binding(bundle$summary),
    rate_summary = rate,
    numeric_summary = numeric,
    execution_identity = global_binding(bundle$execution_identity),
    execution_policy = global_binding(bundle$execution_policy),
    checkpoint_ledger = ledger
  )
  complete <- vapply(surfaces, function(x) {
    is.data.frame(x) && nrow(x) > 0L &&
      all(mfrmr_goip_p1q_identity_fields() %in% names(x)) &&
      all(complete.cases(x[, mfrmr_goip_p1q_identity_fields(), drop = FALSE]))
  }, logical(1L))
  mfrmr_goip_p1q_assert(
    all(complete), "P1q derived-envelope propagation is incomplete."
  )
  structure(
    list(
      schema = "mfrmr-gpcm-owner-identity-envelope-p1q-v1",
      historical_execution_sha256 = execution_sha,
      historical_execution_contract_sha256 =
        mfrmr_goip_p1q_historical_execution_contract_sha256,
      source_bundle_sha256 = mfrmr_goip_p1q_hash_object(bundle),
      identity_registry = registry,
      identity_registry_sha256 = registry_sha,
      surfaces = surfaces,
      surface_complete = data.frame(
        Surface = names(complete),
        FullIdentityRetained = unname(complete),
        stringsAsFactors = FALSE
      ),
      frozen_bundle_modified = FALSE,
      substantive_evidence_added = FALSE
    ),
    class = "mfrmr_gpcm_owner_identity_envelope_p1q"
  )
}

mfrmr_goip_p1q_checkpoint_audit <- function(checkpoint_dir) {
  paths <- sort(list.files(
    checkpoint_dir, pattern = "[.]rds$", full.names = TRUE
  ))
  historical <- mfrmr_goip_p1q_historical_fields()
  rows <- lapply(paths, function(path) {
    object <- tryCatch(readRDS(path), error = function(error) error)
    valid <- !inherits(object, "error") && is.list(object)
    row_manifest <- if (valid && is.data.frame(object$row_manifest)) {
      value <- as.data.frame(object$row_manifest, stringsAsFactors = FALSE)
      rownames(value) <- NULL
      value
    } else data.frame()
    result <- if (valid && is.data.frame(object$result)) {
      as.data.frame(object$result, stringsAsFactors = FALSE)
    } else data.frame()
    manifest_fields <- if (nrow(row_manifest) == 1L) {
      names(row_manifest)
    } else character(0)
    result_fields <- if (nrow(result) == 1L) {
      names(result)
    } else character(0)
    scenario_valid <- valid && nrow(row_manifest) == 1L &&
      nrow(result) == 1L &&
      identical(
        as.character(object$scenario_id),
        as.character(row_manifest$ScenarioId)
      ) && identical(
        as.character(result$ScenarioId),
        as.character(row_manifest$ScenarioId)
      )
    identity_match <- scenario_valid && all(vapply(
      historical,
      function(field) identical(
        as.character(row_manifest[[field]]), as.character(result[[field]])
      ),
      logical(1L)
    ))
    data.frame(
      File = basename(path),
      Readable = valid,
      SchemaValid = valid && identical(
        object$schema, "mfrmr-gpcm-owner-checkpoint-v1"
      ),
      ExecutionIdentityValid = valid && identical(
        as.character(object$execution_sha256),
        mfrmr_goip_p1q_historical_execution_sha256
      ),
      RowManifestHashValid = valid && nrow(row_manifest) == 1L && identical(
        as.character(object$row_manifest_sha256),
        mfrmr_goip_p1q_hash_object(row_manifest)
      ),
      ResultHashValid = valid && nrow(result) == 1L && identical(
        as.character(object$result_sha256),
        mfrmr_goip_p1q_hash_object(result)
      ),
      ScenarioIdentityValid = scenario_valid,
      ManifestHistoricalIdentityComplete = all(
        historical %in% manifest_fields
      ),
      ResultHistoricalIdentityComplete = all(historical %in% result_fields),
      ResultIdentityMatchesManifest = identity_match,
      ExactCategorySupportDirect = all(
        c("RatingMin", "RatingMax", "DeclaredCategorySupport") %in%
          manifest_fields
      ) && all(
        c("RatingMin", "RatingMax", "DeclaredCategorySupport") %in%
          result_fields
      ),
      stringsAsFactors = FALSE
    )
  })
  if (length(rows) == 0L) return(data.frame())
  do.call(rbind, rows)
}

mfrmr_goip_p1q_source_audit <- function(owner_runner, api_estimation,
                                         replay_source) {
  read <- function(path) paste(readLines(path, warn = FALSE), collapse = "\n")
  between <- function(text, start, end) {
    begin <- regexpr(start, text, fixed = TRUE)[1L]
    mfrmr_goip_p1q_assert(begin > 0L, paste0("P1q source marker missing: ", start))
    tail <- substr(text, begin, nchar(text))
    finish <- regexpr(end, tail, fixed = TRUE)[1L]
    mfrmr_goip_p1q_assert(finish > 1L, paste0("P1q source marker missing: ", end))
    substr(tail, 1L, finish - 1L)
  }
  owner_text <- read(owner_runner)
  api_text <- read(api_estimation)
  replay_text <- read(replay_source)
  run_one <- between(
    owner_text, "mfrmr_gpcm_owner_run_one <- function",
    "mfrmr_gpcm_owner_rate_row <- function"
  )
  identity_block <- between(
    run_one, "identity_match <-", "prespecified_negative <-"
  )
  data.frame(
    HistoricalRunnerHashMatches = identical(
      digest::digest(
        owner_runner, algo = "sha256", file = TRUE, serialize = FALSE
      ),
      mfrmr_goip_p1q_historical_runner_sha256
    ),
    HistoricalRunnerExplicitlySetsMMLIdentification = grepl(
      "gpcm_mml_identification", run_one, fixed = TRUE
    ),
    HistoricalRunnerIdentityCheckIncludesAbilityScale = grepl(
      "AbilityScaleContract", identity_block, fixed = TRUE
    ),
    CurrentDefaultIsFreePopulation = grepl(
      "gpcm_mml_identification = c(\"free_population\", \"fixed_standard_normal\")",
      api_text, fixed = TRUE
    ),
    CurrentReplayEmitsMMLIdentification = grepl(
      "emit(\"gpcm_mml_identification\"", replay_text, fixed = TRUE
    ),
    CurrentReplayRetainsRatingBounds = all(vapply(
      c("add_optional(\"rating_min\"", "add_optional(\"rating_max\""),
      grepl, logical(1L), x = replay_text, fixed = TRUE
    )),
    stringsAsFactors = FALSE
  )
}

mfrmr_run_gpcm_owner_identity_propagation_p1q <- function(
    bundle, checkpoint_dir = NULL, owner_runner, api_estimation,
    replay_source = api_estimation) {
  direct <- mfrmr_goip_p1q_surface_table(bundle)
  source <- mfrmr_goip_p1q_source_audit(
    owner_runner, api_estimation, replay_source
  )
  mfrmr_goip_p1q_assert(
    isTRUE(source$HistoricalRunnerHashMatches),
    "P1q historical owner runner identity drifted."
  )
  envelope <- mfrmr_goip_p1q_build_envelope(bundle)
  checkpoints <- if (is.null(checkpoint_dir)) data.frame() else {
    mfrmr_goip_p1q_checkpoint_audit(checkpoint_dir)
  }
  historical_ability <- unique(as.character(
    bundle$declared_manifest$AbilityScaleContract[
      bundle$declared_manifest$Estimator == "MML"
    ]
  ))
  mfrmr_goip_p1q_assert(
    identical(historical_ability, "standard_normal_latent_distribution"),
    "P1q historical MML ability-scale contract drifted."
  )
  direct_complete <- all(direct$FullDirectIdentity)
  checkpoint_historical_complete <- nrow(checkpoints) == 0L || all(
    checkpoints$Readable & checkpoints$SchemaValid &
      checkpoints$ExecutionIdentityValid &
      checkpoints$RowManifestHashValid & checkpoints$ResultHashValid &
      checkpoints$ScenarioIdentityValid &
      checkpoints$ManifestHistoricalIdentityComplete &
      checkpoints$ResultHistoricalIdentityComplete &
      checkpoints$ResultIdentityMatchesManifest
  )
  structure(
    list(
      specification = mfrmr_goip_p1q_specification,
      contract = mfrmr_goip_p1q_contract,
      direct_surface_audit = direct,
      source_audit = source,
      checkpoint_audit = checkpoints,
      envelope = envelope,
      HistoricalExecutionSHA256 =
        mfrmr_goip_p1q_historical_execution_sha256,
      HistoricalPilotMMLAbilityScale = historical_ability,
      CurrentDefaultMMLAbilityScale = "free_population",
      HistoricalRowIdentityRetained = all(
        direct$HistoricalIdentityFieldsPresent[
          direct$Surface %in% c("declared_manifest", "manifest", "results")
        ] == length(mfrmr_goip_p1q_historical_fields())
      ),
      HistoricalCheckpointIdentityRetained = checkpoint_historical_complete,
      FrozenDirectPropagationComplete = direct_complete,
      DerivedEnvelopePropagationComplete = all(
        envelope$surface_complete$FullIdentityRetained
      ),
      HistoricalPilotRepresentsCurrentDefaultMML = FALSE,
      CurrentPublicReplayRetainsIdentification =
        isTRUE(source$CurrentReplayEmitsMMLIdentification) &&
        isTRUE(source$CurrentReplayRetainsRatingBounds),
      IdentityPropagationRequiresAdditionalSimulation = FALSE,
      CurrentDefaultOwnerEvidenceStillRequired = TRUE,
      OwnerEvidenceGatePass = FALSE,
      GPCMCorePromotionAuthorized = FALSE,
      BroadSimulationAuthorized = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_owner_identity_propagation_p1q"
  )
}
