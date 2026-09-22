# mfrmr 0.2.3 repository-only ConQuest additive-MFRM design
#
# This helper seals a deterministic complete-crossing Person/Rater/Criterion
# RSM/PCM microcase without fitting mfrmr or launching ConQuest. Native design
# matrices and raw numeric tokens are mandatory inputs to a later review.

mfrmr_cq_additive_specification <- "0.2.3-wave-c-additive-design-v1"
mfrmr_cq_additive_contract <- "mfrmr_conquest_additive_mfrm_v1"
mfrmr_cq_additive_resolution_contract <-
  "mfrmr_conquest_numeric_resolution_v1"

mfrmr_cq_additive_reference_identities <- data.frame(
  Artifact = c("ConQuest_5_47_5.dmg", "conquestManual.pdf", "ConQuest"),
  SHA256 = c(
    "8526b086aa33ee4a7b30b3dc86399f1f287f2667ea86c0cf3016d673e4f6e329",
    "60bce1a39f5430fd304178356fb943721f9f72c0ddee70a9866c28c87017459f",
    "61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48"
  ),
  stringsAsFactors = FALSE
)

mfrmr_cq_additive_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_additive_hash_file <- function(path) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The additive ConQuest design requires the suggested `digest` package.",
         call. = FALSE)
  }
  unname(digest::digest(file = path, algo = "sha256", serialize = FALSE))
}

mfrmr_cq_additive_restore_seed <- function(had_seed, old_seed) {
  if (had_seed) {
    assign(".Random.seed", old_seed, envir = .GlobalEnv)
  } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
    rm(".Random.seed", envir = .GlobalEnv)
  }
  invisible(NULL)
}

mfrmr_cq_additive_fixture <- function(seed = 20260846L) {
  seed <- suppressWarnings(as.integer(seed)[1])
  mfrmr_cq_additive_assert(
    is.finite(seed), "`seed` must be one finite integer."
  )
  persons <- sprintf("P%03d", seq_len(96L))
  raters <- paste0("R", seq_len(2L))
  criteria <- paste0("C", seq_len(2L))
  categories <- 0:3
  x <- rep(c(-1, 1), each = length(persons) / 2L)
  theta_u <- (((seq_along(persons) * 37L) %% 97L) + 0.5) / 97
  theta <- 0.15 + 0.60 * x + sqrt(0.45) * stats::qnorm(theta_u)
  rater_severity <- stats::setNames(c(-0.35, 0.35), raters)
  criterion_difficulty <- stats::setNames(
    c(-0.55, 0.55), criteria
  )
  criterion_steps <- rbind(
    C1 = c(-1.20, 0.00, 1.20),
    C2 = c(-0.80, -0.20, 1.00)
  )
  colnames(criterion_steps) <- paste0("Step", seq_len(3L))
  mfrmr_cq_additive_assert(
    abs(sum(rater_severity)) < 1e-15 &&
      abs(sum(criterion_difficulty)) < 1e-15 &&
      all(abs(rowSums(criterion_steps)) < 1e-15),
    "The generating facet and step coordinates must satisfy their sum-zero constraints."
  )

  long <- expand.grid(
    Criterion = criteria,
    Rater = raters,
    Person = persons,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  long$X <- x[match(long$Person, persons)]
  long$ThetaGenerator <- theta[match(long$Person, persons)]
  eta <- long$ThetaGenerator - rater_severity[long$Rater] -
    criterion_difficulty[long$Criterion]
  log_kernel <- t(vapply(seq_len(nrow(long)), function(index) {
    value <- categories * eta[index] - c(
      0, cumsum(criterion_steps[long$Criterion[index], ])
    )
    value - max(value)
  }, numeric(length(categories))))
  probability <- exp(log_kernel)
  probability <- probability / rowSums(probability)

  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (had_seed) get(".Random.seed", envir = .GlobalEnv) else NULL
  on.exit(mfrmr_cq_additive_restore_seed(had_seed, old_seed), add = TRUE)
  set.seed(seed)
  long$Score <- vapply(seq_len(nrow(long)), function(index) {
    sample.int(
      length(categories), size = 1L, prob = probability[index, ]
    ) - 1L
  }, integer(1L))

  coverage <- as.data.frame(
    table(
      Rater = factor(long$Rater, levels = raters),
      Criterion = factor(long$Criterion, levels = criteria),
      Score = factor(long$Score, levels = categories)
    ),
    stringsAsFactors = FALSE
  )
  response_names <- as.vector(outer(
    criteria, raters, function(criterion, rater) {
      paste0("Y_", criterion, "_", rater)
    }
  ))
  score_matrix <- matrix(
    long$Score,
    nrow = length(persons),
    ncol = length(response_names),
    byrow = TRUE,
    dimnames = list(persons, response_names)
  )
  wide <- data.frame(
    Person = persons,
    X = x,
    score_matrix,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  person_unique_categories <- vapply(
    split(long$Score, long$Person),
    function(value) length(unique(value)),
    integer(1L)
  )
  mfrmr_cq_additive_assert(
    nrow(long) == 384L && nrow(wide) == 96L &&
      identical(names(wide), c("Person", "X", response_names)) &&
      all(coverage$Freq > 0L) &&
      min(person_unique_categories) >= 2L,
    "The additive fixture does not satisfy its complete-crossing/category-support contract."
  )

  list(
    seed = seed,
    persons = persons,
    raters = raters,
    criteria = criteria,
    categories = categories,
    response_names = response_names,
    wide = wide,
    long = long,
    coverage = coverage,
    person_unique_categories = person_unique_categories,
    generating = list(
      population_intercept = 0.15,
      population_slope = 0.60,
      population_variance = 0.45,
      rater_severity = rater_severity,
      criterion_difficulty = criterion_difficulty,
      criterion_steps = criterion_steps,
      response_family = "PCM"
    )
  )
}

mfrmr_cq_additive_plan <- function() {
  data.frame(
    RunId = c("rsm_q031", "rsm_q061", "pcm_q031", "pcm_q061"),
    Model = c("RSM", "RSM", "PCM", "PCM"),
    Nodes = c(31L, 61L, 31L, 61L),
    ConQuestModel = c(
      "rater + criterion + step",
      "rater + criterion + step",
      "rater + criterion + criterion*step",
      "rater + criterion + criterion*step"
    ),
    MfrmrStepFacet = c("", "", "Criterion", "Criterion"),
    ExpectedNpar = c(7L, 7L, 9L, 9L),
    EvidenceRole = c(
      "complete_additive_microcase",
      "complete_additive_dense_sensitivity",
      "complete_additive_microcase",
      "complete_additive_dense_sensitivity"
    ),
    CandidateBound = FALSE,
    ExternalExecutionAuthorized = FALSE,
    ComparisonReady = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_additive_parameter_map <- function(model) {
  model <- toupper(as.character(model)[1])
  mfrmr_cq_additive_assert(
    model %in% c("RSM", "PCM"), "`model` must be RSM or PCM."
  )
  next_order <- 1L
  add_rows <- function(component, facet, level, export, constraint,
                       role, orientation = "direct_difficulty") {
    free <- constraint == "free"
    order <- rep(NA_integer_, length(level))
    if (any(free)) {
      order[free] <- seq.int(next_order, length.out = sum(free))
      next_order <<- next_order + sum(free)
    }
    data.frame(
      Model = model,
      FreeOrder = order,
      Component = component,
      Facet = facet,
      Level = level,
      ExportSource = export,
      ConstraintRole = constraint,
      MfrmrRole = role,
      Orientation = orientation,
      NativeDesignMatrixRequired = export == "parameter_export",
      ComparisonEligible = FALSE,
      stringsAsFactors = FALSE
    )
  }
  map <- rbind(
    add_rows(
      "Population", "Population", c("Intercept", "X"),
      "regression_export", rep("free", 2L),
      c("population_intercept", "population_slope"),
      orientation = "direct_population"
    ),
    add_rows(
      "Population", "Population", "Variance",
      "covariance_export", "free", "population_variance",
      orientation = "direct_variance"
    ),
    add_rows(
      "Facet", "Rater", paste0("R", 1:2),
      "parameter_export", c("free", "derived_sum_zero"),
      rep("rater_severity", 2L)
    ),
    add_rows(
      "Facet", "Criterion", paste0("C", 1:2),
      "parameter_export",
      c("free", "derived_sum_zero"),
      rep("criterion_difficulty", 2L)
    )
  )
  if (identical(model, "RSM")) {
    map <- rbind(map, add_rows(
      "Step", "Shared", paste0("Step", 1:3),
      "parameter_export", c("free", "free", "derived_sum_zero"),
      rep("shared_step", 3L),
      orientation = "direct_adjacent_step"
    ))
  } else {
    for (criterion in paste0("C", 1:2)) {
      map <- rbind(map, add_rows(
        "Step", "Criterion", paste0(criterion, ":Step", 1:3),
        "parameter_export", c("free", "free", "derived_sum_zero"),
        rep("criterion_specific_step", 3L),
        orientation = "direct_adjacent_step"
      ))
    }
  }
  rownames(map) <- NULL
  expected <- if (identical(model, "RSM")) 7L else 9L
  mfrmr_cq_additive_assert(
    identical(sort(stats::na.omit(map$FreeOrder)), seq_len(expected)),
    "The additive parameter map has the wrong free-coordinate dimension."
  )
  map
}

mfrmr_cq_additive_probability <- function(
    theta,
    rater_severity,
    criterion_difficulty,
    steps) {
  theta <- as.numeric(theta)
  rater_severity <- as.numeric(rater_severity)
  criterion_difficulty <- as.numeric(criterion_difficulty)
  steps <- as.numeric(steps)
  mfrmr_cq_additive_assert(
    length(theta) == length(rater_severity) &&
      length(theta) == length(criterion_difficulty) &&
      length(steps) == 3L && all(is.finite(c(
        theta, rater_severity, criterion_difficulty, steps
      ))),
    "The additive probability oracle received incompatible coordinates."
  )
  eta <- theta - rater_severity - criterion_difficulty
  kernel <- vapply(0:3, function(category) {
    category * eta - if (category == 0L) 0 else sum(steps[seq_len(category)])
  }, numeric(length(theta)))
  if (length(theta) == 1L) kernel <- matrix(kernel, nrow = 1L)
  kernel <- kernel - apply(kernel, 1L, max)
  probability <- exp(kernel)
  probability / rowSums(probability)
}

mfrmr_cq_additive_command <- function(prefix, model, nodes, response_names) {
  model <- toupper(as.character(model)[1])
  nodes <- suppressWarnings(as.integer(nodes)[1])
  response_names <- as.character(response_names)
  mfrmr_cq_additive_assert(
    model %in% c("RSM", "PCM") && is.finite(nodes) && nodes > 0L &&
      length(response_names) == 4L,
    "The additive command requires RSM/PCM, positive nodes, and 4 responses."
  )
  model_term <- if (identical(model, "RSM")) {
    "rater + criterion + step"
  } else {
    "rater + criterion + criterion*step"
  }
  label_lines <- c(
    paste0("labels ", 1:2, " C", 1:2, " ! criterion;"),
    paste0("labels ", 1:2, " R", 1:2, " ! rater;")
  )
  c(
    paste0("title mfrmr additive ", model, " microcase;"),
    paste0("export logfile >> ", prefix, "_conquest_internal.log;"),
    paste0(
      "datafile ", prefix,
      "_wide.csv ! filetype=csv, header=yes, columnlabels=no, pid=Person, ",
      "pidwidth=16, responses=", response_names[1], " to ",
      response_names[length(response_names)],
      ", facets=criterion(2) rater(2), keeps=X, keepswidth=32;"
    ),
    "codes 0,1,2,3;",
    label_lines,
    "regression X;",
    paste0("model ", model_term, ";"),
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

mfrmr_cq_additive_profile <- function(fixture) {
  long <- fixture$long
  rater_load <- table(long$Rater)
  criterion_load <- table(long$Criterion)
  score_count <- table(factor(long$Score, levels = fixture$categories))
  person_min <- tapply(long$Score, long$Person, function(value) all(value == 0L))
  person_max <- tapply(long$Score, long$Person, function(value) all(value == 3L))
  data.frame(
    Specification = mfrmr_cq_additive_specification,
    Persons = length(fixture$persons),
    Observations = nrow(long),
    ObservationsPerPersonMin = min(table(long$Person)),
    ObservationsPerPersonMax = max(table(long$Person)),
    Raters = length(fixture$raters),
    Criteria = length(fixture$criteria),
    Categories = length(fixture$categories),
    Assignment = "complete_person_by_rater_by_criterion",
    ObservedCellRate = 1,
    RaterLoadMin = min(rater_load),
    RaterLoadMax = max(rater_load),
    CriterionLoadMin = min(criterion_load),
    CriterionLoadMax = max(criterion_load),
    LowestCategoryRate = unname(score_count[1] / sum(score_count)),
    HighestCategoryRate = unname(score_count[4] / sum(score_count)),
    MinimumRaterCriterionCategoryCount = min(fixture$coverage$Freq),
    AllMinimumPersons = sum(person_min),
    AllMaximumPersons = sum(person_max),
    LocalDependenceGenerator = FALSE,
    AnchorRate = 0,
    MissingMechanism = "none",
    Connected = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_prepare_conquest_additive_design <- function(output_dir) {
  output_dir <- normalizePath(
    as.character(output_dir)[1], winslash = "/", mustWork = FALSE
  )
  mfrmr_cq_additive_assert(
    !is.na(output_dir) && nzchar(output_dir),
    "`output_dir` must be one non-empty path."
  )
  if (dir.exists(output_dir) &&
      length(list.files(output_dir, all.files = TRUE, no.. = TRUE)) > 0L) {
    stop(
      "The additive ConQuest design directory must be absent or empty.",
      call. = FALSE
    )
  }
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  mfrmr_cq_additive_assert(
    dir.exists(output_dir), "The additive design directory could not be created."
  )
  fixture <- mfrmr_cq_additive_fixture()
  plan <- mfrmr_cq_additive_plan()
  profile <- mfrmr_cq_additive_profile(fixture)
  profile_file <- file.path(output_dir, "additive_design_profile.csv")
  long_file <- file.path(output_dir, "additive_fixture_long.csv")
  rsm_map_file <- file.path(output_dir, "additive_rsm_parameter_map.csv")
  pcm_map_file <- file.path(output_dir, "additive_pcm_parameter_map.csv")
  utils::write.csv(profile, profile_file, row.names = FALSE, na = "")
  utils::write.csv(fixture$long, long_file, row.names = FALSE, na = "")
  utils::write.csv(
    mfrmr_cq_additive_parameter_map("RSM"),
    rsm_map_file, row.names = FALSE, na = ""
  )
  utils::write.csv(
    mfrmr_cq_additive_parameter_map("PCM"),
    pcm_map_file, row.names = FALSE, na = ""
  )

  rows <- vector("list", nrow(plan))
  for (index in seq_len(nrow(plan))) {
    row <- plan[index, , drop = FALSE]
    run_dir <- file.path(output_dir, row$RunId)
    dir.create(run_dir, recursive = TRUE, showWarnings = FALSE)
    prefix <- paste0("cq_additive_", row$RunId)
    wide_file <- file.path(run_dir, paste0(prefix, "_wide.csv"))
    command_file <- file.path(run_dir, paste0(prefix, ".cqc"))
    utils::write.csv(fixture$wide, wide_file, row.names = FALSE, na = "")
    writeLines(
      mfrmr_cq_additive_command(
        prefix, row$Model, row$Nodes, fixture$response_names
      ),
      command_file,
      useBytes = TRUE
    )
    rows[[index]] <- data.frame(
      Specification = mfrmr_cq_additive_specification,
      ContractVersion = mfrmr_cq_additive_contract,
      RunId = row$RunId,
      Model = row$Model,
      Nodes = row$Nodes,
      ConQuestModel = row$ConQuestModel,
      MfrmrStepFacet = row$MfrmrStepFacet,
      ExpectedNpar = row$ExpectedNpar,
      EvidenceRole = row$EvidenceRole,
      RunDirectory = row$RunId,
      Prefix = prefix,
      WideFile = file.path(row$RunId, basename(wide_file)),
      CommandFile = file.path(row$RunId, basename(command_file)),
      WideSHA256 = mfrmr_cq_additive_hash_file(wide_file),
      CommandSHA256 = mfrmr_cq_additive_hash_file(command_file),
      ProfileSHA256 = mfrmr_cq_additive_hash_file(profile_file),
      ParameterMapSHA256 = mfrmr_cq_additive_hash_file(
        if (row$Model == "RSM") rsm_map_file else pcm_map_file
      ),
      ResolutionContract = mfrmr_cq_additive_resolution_contract,
      RawTokenAuditRequired = TRUE,
      NativeDesignMatrixRequired = TRUE,
      MfrmrReferenceRequired = TRUE,
      CandidateBound = FALSE,
      ExternalExecutionAuthorized = FALSE,
      ComparisonReady = FALSE,
      stringsAsFactors = FALSE
    )
  }
  manifest <- do.call(rbind, rows)
  manifest_file <- file.path(
    output_dir, "conquest_additive_mfrm_manifest.csv"
  )
  utils::write.csv(manifest, manifest_file, row.names = FALSE, na = "")
  out <- list(
    specification = mfrmr_cq_additive_specification,
    contract_version = mfrmr_cq_additive_contract,
    status = "prepared_no_fit_external_execution_prohibited",
    output_dir = output_dir,
    manifest_file = manifest_file,
    plan = plan,
    manifest = manifest,
    profile = profile,
    reference_identities = mfrmr_cq_additive_reference_identities,
    candidate_bound = FALSE,
    external_execution_authorized = FALSE,
    comparison_ready = FALSE,
    notes = c(
      "No mfrmr fit or ConQuest process was opened.",
      "The native ConQuest A matrix must verify the prospective coordinate map.",
      "Raw numeric tokens must pass the separate resolution contract before conversion.",
      "The sparse/unequal-workload design remains a later, separate microcase."
    )
  )
  class(out) <- c("mfrmr_conquest_additive_design", class(out))
  out
}

mfrmr_validate_conquest_additive_design <- function(output_dir) {
  output_dir <- normalizePath(
    as.character(output_dir)[1], winslash = "/", mustWork = TRUE
  )
  manifest_file <- file.path(
    output_dir, "conquest_additive_mfrm_manifest.csv"
  )
  mfrmr_cq_additive_assert(
    file.exists(manifest_file), "The additive design manifest is missing."
  )
  manifest <- utils::read.csv(
    manifest_file, stringsAsFactors = FALSE, check.names = FALSE
  )
  plan <- mfrmr_cq_additive_plan()
  mfrmr_cq_additive_assert(
    identical(as.character(manifest$RunId), plan$RunId) &&
      identical(as.character(manifest$Model), plan$Model) &&
      identical(as.integer(manifest$Nodes), plan$Nodes) &&
      identical(as.integer(manifest$ExpectedNpar), plan$ExpectedNpar) &&
      all(!as.logical(manifest$CandidateBound)) &&
      all(!as.logical(manifest$ExternalExecutionAuthorized)) &&
      all(!as.logical(manifest$ComparisonReady)),
    "The additive manifest does not match its sealed no-fit plan."
  )
  profile_file <- file.path(output_dir, "additive_design_profile.csv")
  profile <- utils::read.csv(
    profile_file, stringsAsFactors = FALSE, check.names = FALSE
  )
  mfrmr_cq_additive_assert(
    nrow(profile) == 1L && profile$Persons == 96L &&
      profile$Observations == 384L && profile$Raters == 2L &&
      profile$Criteria == 2L && profile$Categories == 4L &&
      profile$ObservedCellRate == 1 && profile$Connected &&
      profile$MinimumRaterCriterionCategoryCount > 0L &&
      profile$AllMinimumPersons == 0L && profile$AllMaximumPersons == 0L,
    "The additive design profile does not satisfy the sealed complete-crossing contract."
  )
  wide_hashes <- character(nrow(manifest))
  for (index in seq_len(nrow(manifest))) {
    row <- manifest[index, , drop = FALSE]
    wide_file <- file.path(output_dir, row$WideFile)
    command_file <- file.path(output_dir, row$CommandFile)
    map_file <- file.path(
      output_dir,
      if (row$Model == "RSM") {
        "additive_rsm_parameter_map.csv"
      } else {
        "additive_pcm_parameter_map.csv"
      }
    )
    mfrmr_cq_additive_assert(
      all(file.exists(c(wide_file, command_file, map_file))) &&
        identical(mfrmr_cq_additive_hash_file(wide_file), row$WideSHA256) &&
        identical(mfrmr_cq_additive_hash_file(command_file), row$CommandSHA256) &&
        identical(mfrmr_cq_additive_hash_file(profile_file), row$ProfileSHA256) &&
        identical(mfrmr_cq_additive_hash_file(map_file), row$ParameterMapSHA256),
      paste0("The additive artifact identity failed for `", row$RunId, "`.")
    )
    command <- readLines(command_file, warn = FALSE)
    mfrmr_cq_additive_assert(
      any(grepl("facets=criterion(2) rater(2)", command, fixed = TRUE)) &&
        any(grepl(paste0("nodes=", row$Nodes, ","), command, fixed = TRUE)) &&
        any(grepl(paste0("model ", row$ConQuestModel, ";"),
                  command, fixed = TRUE)) &&
        any(grepl("export amatrix", command, fixed = TRUE)) &&
        !any(grepl("system2|ConQuestCMD|/Applications/ConQuest", command)),
      paste0("The additive command contract failed for `", row$RunId, "`.")
    )
    map <- utils::read.csv(
      map_file, stringsAsFactors = FALSE, check.names = FALSE
    )
    mfrmr_cq_additive_assert(
      identical(
        sort(stats::na.omit(as.integer(map$FreeOrder))),
        seq_len(as.integer(row$ExpectedNpar))
      ) && all(!as.logical(map$ComparisonEligible)),
      paste0("The additive parameter-map contract failed for `", row$RunId, "`.")
    )
    wide_hashes[index] <- mfrmr_cq_additive_hash_file(wide_file)
  }
  mfrmr_cq_additive_assert(
    length(unique(wide_hashes)) == 1L,
    "The additive RSM/PCM/node arms do not share one byte-identical input."
  )
  data.frame(
    Specification = mfrmr_cq_additive_specification,
    ContractVersion = mfrmr_cq_additive_contract,
    DesignReady = TRUE,
    MathematicalMapReady = TRUE,
    RawTokenContractReady = TRUE,
    NativeDesignMatrixObserved = FALSE,
    MfrmrReferenceFitObserved = FALSE,
    CandidateBound = FALSE,
    ExternalExecutionAuthorized = FALSE,
    ComparisonReady = FALSE,
    Decision = "no_go_design_only",
    Reason = paste(
      c(
        "candidate_unbound", "mfrmr_reference_not_fit",
        "native_design_matrix_not_observed", "external_execution_not_authorized"
      ),
      collapse = ";"
    ),
    stringsAsFactors = FALSE
  )
}
