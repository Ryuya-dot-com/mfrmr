# B2 real-data problem-packet eligibility audit for mfrmr 0.2.4
#
# Repository-internal only. This script audits whether any packaged dataset can
# support the real-workflow GRM--adjacent-family sensitivity analysis permitted
# by Gate 0.5. It deliberately performs no model fit. Numeric ordinal codes do
# not establish cumulative-boundary semantics, and repeated ratings are not
# averaged, voted, selected, or converted into Rater-by-Criterion pseudo-items.

mfrmr_b2_data_contract <- function() {
  list(
    ContractId = "MFRMR-B2-REAL-DATA-INTAKE-V1",
    StageId = "B2",
    Status = "problem_discovery_only",
    LatentDimension = 1L,
    FacetInterpretation = paste(
      "Rater and Criterion are observed design roles; neither is a latent",
      "dimension merely because the model has multiple facets."
    ),
    PredictionTarget = "must_be_named_by_workflow_owner",
    RequiredPacketFields = c(
      "workflow_owner", "named_decision", "action_if_result_changes",
      "population_and_response_unit", "stable_item_identity",
      "category_labels_order_and_direction",
      "cumulative_boundary_interpretation", "rater_role",
      "repeated_rating_policy", "missingness_policy", "split_unit",
      "proper_metric", "practical_threshold", "current_workaround",
      "build_versus_mirt_integration_question", "deidentification_clearance"
    ),
    ForbiddenSilentTransforms = c(
      "mean_then_round_repeated_ratings",
      "majority_vote_repeated_ratings",
      "select_latest_or_first_rating",
      "treat_rater_by_criterion_as_item",
      "treat_observed_facets_as_latent_dimensions"
    ),
    EligibilityRule = paste(
      "A packet must be empirical and representative, contain observed",
      "responses, have owner-confirmed cumulative semantics, a named decision",
      "and action-linked metric, and a prespecified treatment of repeated",
      "ratings that preserves the intended facet estimand."
    ),
    Comparator = "external_GRM_versus_current_adjacent_family_route",
    PublicApiChange = FALSE
  )
}

mfrmr_b2_bundled_registry <- function() {
  objects <- c(
    "ej2021_combined_itercal",
    "ej2021_combined",
    "ej2021_study1_itercal",
    "ej2021_study1",
    "ej2021_study2_itercal",
    "ej2021_study2",
    "mfrmr_example_bias",
    "mfrmr_example_core",
    "mfrmr_example_operational_design",
    "mfrmr_example_operational"
  )
  current_examples <- startsWith(objects, "mfrmr_example_") &
    objects != "mfrmr_example_operational_design"
  design_only <- objects == "mfrmr_example_operational_design"
  combined <- grepl("^ej2021_combined", objects)
  data.frame(
    Object = objects,
    ProvenanceClass = ifelse(
      design_only,
      "synthetic_score_free_assignment_roster",
      ifelse(
        current_examples,
        "synthetic_documentation_example",
        "legacy_synthetic_shape_replication"
      )
    ),
    DocumentedGeometry = ifelse(
      design_only,
      "no_response_geometry",
      ifelse(
        current_examples,
        "adjacent_RSM_generator",
        "legacy_synthetic_DGP_unavailable"
      )
    ),
    EmpiricalRepresentativePacket = FALSE,
    CumulativeWorkflowConfirmed = FALSE,
    NamedDecisionAvailable = FALSE,
    ActionLinkedMetricFrozen = FALSE,
    RepeatedRatingHandlingFrozen = FALSE,
    CrossStudyLinkingRequired = combined,
    ScaleIdentityReviewed = !combined,
    stringsAsFactors = FALSE
  )
}

mfrmr_b2_sha256 <- function(path) {
  if (!requireNamespace("digest", quietly = TRUE)) return(NA_character_)
  tolower(digest::digest(file = path, algo = "sha256"))
}

mfrmr_b2_namespace <- function(data, fields) {
  if (!all(fields %in% names(data))) return(character())
  do.call(paste, c(unname(data[fields]), sep = "::"))
}

mfrmr_b2_load_object <- function(package_root, object) {
  path <- file.path(package_root, "data", paste0(object, ".rda"))
  if (!file.exists(path)) {
    stop("B2 registry object is missing: ", object, call. = FALSE)
  }
  environment <- new.env(parent = emptyenv())
  loaded <- load(path, envir = environment)
  if (!identical(loaded, object)) {
    stop(
      "B2 data file must contain only its registry object: ", object,
      call. = FALSE
    )
  }
  value <- get(object, envir = environment, inherits = FALSE)
  if (!is.data.frame(value)) {
    stop("B2 registry object is not a data.frame: ", object, call. = FALSE)
  }
  value
}

mfrmr_b2_blockers <- function(metadata, metrics) {
  blockers <- character()
  if (!metrics$HasScore) {
    blockers <- c(blockers, "no_observed_response")
  }
  if (!metadata$EmpiricalRepresentativePacket) {
    blockers <- c(blockers, "nonempirical_packet")
  }
  if (!metadata$CumulativeWorkflowConfirmed) {
    geometry_blocker <- if (metadata$DocumentedGeometry ==
                              "adjacent_RSM_generator") {
      "documented_adjacent_DGP_not_cumulative_workflow"
    } else if (metadata$DocumentedGeometry == "no_response_geometry") {
      "cumulative_semantics_not_applicable_without_response"
    } else {
      "cumulative_semantics_unconfirmed"
    }
    blockers <- c(blockers, geometry_blocker)
  }
  if (!metadata$NamedDecisionAvailable) {
    blockers <- c(blockers, "named_decision_missing")
  }
  if (!metadata$ActionLinkedMetricFrozen) {
    blockers <- c(blockers, "action_linked_metric_missing")
  }
  if (metrics$RepeatedPersonCriterionCells > 0L &&
      !metadata$RepeatedRatingHandlingFrozen) {
    blockers <- c(
      blockers,
      "repeated_ratings_no_prespecified_facet_handling"
    )
  }
  if (metadata$CrossStudyLinkingRequired &&
      !metadata$ScaleIdentityReviewed) {
    blockers <- c(blockers, "cross_study_linking_unreviewed")
  }
  blockers
}

mfrmr_b2_audit_one <- function(package_root, metadata) {
  data <- mfrmr_b2_load_object(package_root, metadata$Object)
  has_score <- "Score" %in% names(data)
  person_criterion <- mfrmr_b2_namespace(
    data, c("Study", "Person", "Criterion")
  )
  response_identity <- mfrmr_b2_namespace(
    data, c("Study", "Person", "Rater", "Criterion")
  )
  cell_counts <- if (length(person_criterion)) {
    table(person_criterion)
  } else {
    integer()
  }
  category_counts <- if (has_score) table(data$Score, useNA = "no") else integer()
  metrics <- list(
    HasScore = has_score,
    RepeatedPersonCriterionCells = as.integer(sum(cell_counts > 1L))
  )
  blockers <- mfrmr_b2_blockers(metadata, metrics)
  data.frame(
    object = metadata$Object,
    provenance_class = metadata$ProvenanceClass,
    documented_geometry = metadata$DocumentedGeometry,
    rows = nrow(data),
    has_score = has_score,
    study_persons = length(unique(mfrmr_b2_namespace(
      data, c("Study", "Person")
    ))),
    study_raters = length(unique(mfrmr_b2_namespace(
      data, c("Study", "Rater")
    ))),
    criteria = if ("Criterion" %in% names(data)) {
      length(unique(data$Criterion))
    } else {
      0L
    },
    observed_categories = if (has_score) {
      paste(sort(unique(data$Score)), collapse = "|")
    } else {
      NA_character_
    },
    minimum_category_count = if (length(category_counts)) {
      as.integer(min(category_counts))
    } else {
      NA_integer_
    },
    missing_scores = if (has_score) sum(is.na(data$Score)) else NA_integer_,
    person_criterion_cells = length(cell_counts),
    repeated_person_criterion_cells = metrics$RepeatedPersonCriterionCells,
    ratings_per_person_criterion_minimum = if (length(cell_counts)) {
      as.integer(min(cell_counts))
    } else {
      NA_integer_
    },
    ratings_per_person_criterion_maximum = if (length(cell_counts)) {
      as.integer(max(cell_counts))
    } else {
      NA_integer_
    },
    duplicate_response_identities = if (length(response_identity)) {
      sum(duplicated(response_identity))
    } else {
      NA_integer_
    },
    empirical_representative_packet =
      metadata$EmpiricalRepresentativePacket,
    cumulative_workflow_confirmed = metadata$CumulativeWorkflowConfirmed,
    named_decision_available = metadata$NamedDecisionAvailable,
    action_linked_metric_frozen = metadata$ActionLinkedMetricFrozen,
    repeated_rating_handling_frozen =
      metadata$RepeatedRatingHandlingFrozen,
    scale_identity_reviewed = metadata$ScaleIdentityReviewed,
    eligibility_status = if (length(blockers)) {
      "ineligible"
    } else {
      "eligible_for_external_sensitivity"
    },
    blocker_codes = paste(blockers, collapse = ";"),
    stringsAsFactors = FALSE
  )
}

mfrmr_run_b2_data_eligibility_audit <- function(package_root = ".") {
  package_root <- normalizePath(
    package_root, winslash = "/", mustWork = TRUE
  )
  registry <- mfrmr_b2_bundled_registry()
  files <- sort(
    tools::file_path_sans_ext(basename(list.files(
      file.path(package_root, "data"), pattern = "[.]rda$", full.names = TRUE
    ))),
    method = "radix"
  )
  expected <- sort(registry$Object, method = "radix")
  if (!identical(files, expected) || anyDuplicated(registry$Object)) {
    stop(
      "B2 bundled-data registry must account for every .rda object exactly once.",
      call. = FALSE
    )
  }
  rows <- lapply(seq_len(nrow(registry)), function(index) {
    mfrmr_b2_audit_one(
      package_root, registry[index, , drop = FALSE]
    )
  })
  audit <- do.call(rbind, rows)
  rownames(audit) <- NULL
  eligible <- audit$eligibility_status == "eligible_for_external_sensitivity"
  disposition <- if (any(eligible)) {
    "eligible_packet_requires_owner_review_before_fit"
  } else {
    "no_eligible_bundled_problem_packet_external_intake_required"
  }
  structure(list(
    contract = mfrmr_b2_data_contract(),
    audit = audit,
    decision = data.frame(
      bundled_objects_expected = nrow(registry),
      bundled_objects_observed = nrow(audit),
      eligible_objects = sum(eligible),
      model_fits_executed = 0L,
      disposition = disposition,
      next_action = if (any(eligible)) {
        "obtain_owner_confirmation_before_external_sensitivity"
      } else {
        "request_one_owner_confirmed_deidentified_problem_packet"
      },
      portfolio_effect = "none_B2_remains_parked",
      public_api_change = FALSE,
      stringsAsFactors = FALSE
    )
  ), class = "mfrmr_b2_data_eligibility_audit")
}

mfrmr_write_b2_data_eligibility_receipt <- function(
    result,
    package_root = ".",
    script_path = file.path(
      package_root, "inst", "validation",
      "measurement-model-extension-b2-data-eligibility-0.2.4.R"
    ),
    output_path = file.path(
      package_root, "inst", "validation",
      "measurement-model-extension-b2-data-eligibility-0.2.4.csv"
    )) {
  if (!inherits(result, "mfrmr_b2_data_eligibility_audit")) {
    stop("`result` must be a B2 data-eligibility audit.", call. = FALSE)
  }
  receipt <- result$audit
  receipt$contract_id <- result$contract$ContractId
  receipt$audit_date <- "2026-08-28"
  receipt$script_sha256 <- mfrmr_b2_sha256(script_path)
  receipt$study_disposition <- result$decision$disposition
  receipt$model_fits_executed <- result$decision$model_fits_executed
  receipt$public_api_change <- result$decision$public_api_change
  utils::write.csv(receipt, output_path, row.names = FALSE, na = "")
  invisible(receipt)
}

if (sys.nframe() == 0L) {
  arguments <- commandArgs(trailingOnly = FALSE)
  file_argument <- grep("^--file=", arguments, value = TRUE)
  if (!length(file_argument)) {
    stop("Run this audit with Rscript so the package root can be resolved.",
         call. = FALSE)
  }
  script_path <- normalizePath(
    sub("^--file=", "", file_argument[1L]), winslash = "/", mustWork = TRUE
  )
  package_root <- normalizePath(
    file.path(dirname(script_path), "..", ".."),
    winslash = "/", mustWork = TRUE
  )
  result <- mfrmr_run_b2_data_eligibility_audit(package_root)
  mfrmr_write_b2_data_eligibility_receipt(
    result, package_root = package_root, script_path = script_path
  )
  print(result$decision)
}
