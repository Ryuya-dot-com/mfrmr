# mfrmr 0.2.3 ConQuest reported-point common-likelihood calibration
#
# This repository-only helper evaluates the exact decimal coordinates written
# by ConQuest on the independently implemented additive likelihood oracle. It
# is descriptive calibration for a future candidate. It does not choose a
# tolerance, relabel the reported coordinates as hidden optimizer values, or
# authorize a comparison, confirmation, or external execution.

mfrmr_cq_rplc_specification <-
  "0.2.3-wave-c-reported-point-likelihood-calibration-v1"
mfrmr_cq_rplc_contract <-
  "mfrmr_conquest_reported_point_likelihood_calibration_v1"

mfrmr_cq_rplc_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_rplc_require_helpers <- function() {
  required <- c(
    "mfrmr_cq_additive_assert", "mfrmr_cq_additive_fixture",
    "mfrmr_cq_additive_probability", "mfrmr_cq_additive_gh_normal",
    "mfrmr_cq_rop_validate_policy"
  )
  scope <- environment(mfrmr_cq_rplc_require_helpers)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = scope,
    mode = "function", inherits = TRUE
  )]
  mfrmr_cq_rplc_assert(
    length(missing) == 0L,
    paste0("Source the additive design, reference, and reported-output ",
           "contracts first; missing: ", paste(missing, collapse = ", "), ".")
  )
  invisible(TRUE)
}

mfrmr_cq_rplc_free_names <- function(model) {
  model <- toupper(as.character(model)[1L])
  mfrmr_cq_rplc_assert(model %in% c("RSM", "PCM"),
                       "`model` must be RSM or PCM.")
  c(
    "population_intercept", "population_slope", "log_population_variance",
    "R1", "C1",
    if (identical(model, "RSM")) {
      c("Step1", "Step2")
    } else {
      c("C1:Step1", "C1:Step2", "C2:Step1", "C2:Step2")
    }
  )
}

mfrmr_cq_rplc_free_vector <- function(rows, value_column, model) {
  value_column <- as.character(value_column)[1L]
  mfrmr_cq_rplc_assert(
    is.data.frame(rows) && value_column %in% names(rows),
    "The coordinate rows or requested value column are unavailable."
  )
  model <- toupper(as.character(model)[1L])
  direct_names <- sub(
    "^log_population_variance$", "population_variance",
    mfrmr_cq_rplc_free_names(model)
  )
  key <- as.character(rows$Coordinate)
  mfrmr_cq_rplc_assert(
    !anyDuplicated(key) && all(direct_names %in% key),
    "The reported-point coordinates are incomplete or duplicated."
  )
  value <- suppressWarnings(as.numeric(
    rows[[value_column]][match(direct_names, key)]
  ))
  names(value) <- mfrmr_cq_rplc_free_names(model)
  mfrmr_cq_rplc_assert(
    all(is.finite(value)) && value["log_population_variance"] > 0,
    "The reported-point free coordinates are nonfinite or have invalid variance."
  )
  value["log_population_variance"] <-
    log(value["log_population_variance"])
  value
}

mfrmr_cq_rplc_decode <- function(free, model, fixture) {
  model <- toupper(as.character(model)[1L])
  expected <- mfrmr_cq_rplc_free_names(model)
  supplied_names <- names(free)
  free <- suppressWarnings(as.numeric(free))
  names(free) <- if (is.null(supplied_names)) expected else supplied_names
  if (!identical(names(free), expected) && setequal(names(free), expected)) {
    free <- free[expected]
  }
  mfrmr_cq_rplc_assert(
    identical(names(free), expected) && all(is.finite(free)),
    "The likelihood free vector has the wrong identity or nonfinite values."
  )
  variance <- exp(free["log_population_variance"])
  mfrmr_cq_rplc_assert(is.finite(variance) && variance > 0,
                       "The decoded population variance is invalid.")
  rater <- stats::setNames(c(free["R1"], -free["R1"]), fixture$raters)
  criterion <- stats::setNames(c(free["C1"], -free["C1"]), fixture$criteria)
  if (identical(model, "RSM")) {
    one <- c(free["Step1"], free["Step2"],
             -free["Step1"] - free["Step2"])
    step <- rbind(C1 = one, C2 = one)
  } else {
    step <- rbind(
      C1 = c(free["C1:Step1"], free["C1:Step2"],
             -free["C1:Step1"] - free["C1:Step2"]),
      C2 = c(free["C2:Step1"], free["C2:Step2"],
             -free["C2:Step1"] - free["C2:Step2"])
    )
  }
  colnames(step) <- paste0("Step", 1:3)
  list(
    beta = stats::setNames(
      free[c("population_intercept", "population_slope")],
      c("Intercept", "X")
    ),
    variance = variance,
    rater = rater,
    criterion = criterion,
    steps = step
  )
}

mfrmr_cq_rplc_deviance_function <- function(model, nodes, fixture) {
  mfrmr_cq_rplc_require_helpers()
  model <- toupper(as.character(model)[1L])
  nodes <- suppressWarnings(as.integer(nodes)[1L])
  mfrmr_cq_rplc_assert(
    model %in% c("RSM", "PCM") && nodes %in% c(31L, 61L) &&
      is.list(fixture) && nrow(fixture$long) == 384L,
    "The common likelihood permits only the sealed RSM/PCM q31/q61 fixture."
  )
  quadrature <- mfrmr_cq_additive_gh_normal(nodes)
  long <- fixture$long
  person_index <- match(long$Person, fixture$persons)
  function(free) {
    coordinate <- mfrmr_cq_rplc_decode(free, model, fixture)
    mu <- coordinate$beta["Intercept"] +
      coordinate$beta["X"] * fixture$wide$X
    log_probability <- matrix(
      NA_real_, nrow = nrow(long), ncol = length(quadrature$nodes)
    )
    for (node_index in seq_along(quadrature$nodes)) {
      theta <- mu + sqrt(coordinate$variance) * quadrature$nodes[node_index]
      theta_observed <- theta[person_index]
      probability <- matrix(NA_real_, nrow = nrow(long), ncol = 4L)
      for (criterion_level in fixture$criteria) {
        selected <- which(long$Criterion == criterion_level)
        probability[selected, ] <- mfrmr_cq_additive_probability(
          theta = theta_observed[selected],
          rater_severity = coordinate$rater[long$Rater[selected]],
          criterion_difficulty = coordinate$criterion[
            long$Criterion[selected]
          ],
          steps = coordinate$steps[criterion_level, ]
        )
      }
      selected_probability <- probability[cbind(
        seq_len(nrow(long)), long$Score + 1L
      )]
      if (any(!is.finite(selected_probability) | selected_probability <= 0)) {
        return(Inf)
      }
      log_probability[, node_index] <- log(selected_probability)
    }
    person_log_probability <- rowsum(
      log_probability, person_index, reorder = FALSE
    )
    log_joint <- sweep(
      person_log_probability, 2L, log(quadrature$weights), "+"
    )
    row_maximum <- apply(log_joint, 1L, max)
    log_likelihood <- sum(
      row_maximum + log(rowSums(exp(log_joint - row_maximum)))
    )
    -2 * log_likelihood
  }
}

mfrmr_cq_rplc_derivatives <- function(fn, point) {
  if (!requireNamespace("numDeriv", quietly = TRUE)) {
    stop("The reported-point calibration requires `numDeriv`.", call. = FALSE)
  }
  gradient <- as.numeric(numDeriv::grad(
    fn, point, method = "Richardson"
  ))
  hessian <- as.matrix(numDeriv::hessian(
    fn, point, method = "Richardson"
  ))
  hessian <- (hessian + t(hessian)) / 2
  eigenvalue <- eigen(
    hessian, symmetric = TRUE, only.values = TRUE
  )$values
  positive_definite <- all(is.finite(eigenvalue)) && min(eigenvalue) > 0
  newton_decrement <- if (positive_definite && all(is.finite(gradient))) {
    root <- tryCatch(
      sqrt(max(0, drop(crossprod(gradient, solve(hessian, gradient))))),
      error = function(...) NA_real_
    )
    as.numeric(root)
  } else {
    NA_real_
  }
  list(
    gradient = gradient,
    hessian = hessian,
    gradient_sup_norm = max(abs(gradient)),
    minimum_eigenvalue = min(eigenvalue),
    maximum_eigenvalue = max(eigenvalue),
    condition_number = if (positive_definite) {
      max(eigenvalue) / min(eigenvalue)
    } else {
      Inf
    },
    positive_definite = positive_definite,
    newton_decrement = newton_decrement
  )
}

mfrmr_cq_rplc_one_arm <- function(policy, run_id, model, nodes, fixture) {
  rows <- policy$rows[policy$rows$RunId == run_id, , drop = FALSE]
  mfrmr_cq_rplc_assert(nrow(rows) > 0L, "The requested policy arm is missing.")
  reported <- mfrmr_cq_rplc_free_vector(rows, "NativeValue", model)
  reference <- mfrmr_cq_rplc_free_vector(
    rows, "MfrmrReferenceValue", model
  )
  fn <- mfrmr_cq_rplc_deviance_function(model, nodes, fixture)
  reported_deviance <- fn(reported)
  reference_deviance <- fn(reference)
  reported_derivative <- mfrmr_cq_rplc_derivatives(fn, reported)
  reference_derivative <- mfrmr_cq_rplc_derivatives(fn, reference)
  delta <- reported - reference
  curvature_distance <- if (reference_derivative$positive_definite) {
    sqrt(max(0, drop(crossprod(
      delta, reference_derivative$hessian %*% delta
    ))))
  } else {
    NA_real_
  }
  native_deviance <- rows$NativeValue[match("deviance", rows$Coordinate)]
  stored_reference_deviance <- rows$MfrmrReferenceValue[
    match("deviance", rows$Coordinate)
  ]
  data.frame(
    RunId = run_id,
    Model = model,
    Nodes = as.integer(nodes),
    FreeDimension = length(reported),
    ExactReportedDevianceToken = as.numeric(native_deviance),
    CommonDevianceAtReportedPoint = reported_deviance,
    ReportedTokenCommonDevianceAbsDifference = abs(
      as.numeric(native_deviance) - reported_deviance
    ),
    StoredMfrmrReferenceDeviance = as.numeric(stored_reference_deviance),
    CommonDevianceAtMfrmrPoint = reference_deviance,
    MfrmrStoredCommonDevianceAbsDifference = abs(
      as.numeric(stored_reference_deviance) - reference_deviance
    ),
    ReportedMinusMfrmrCommonDeviance =
      reported_deviance - reference_deviance,
    ReportedGradientSupNorm = reported_derivative$gradient_sup_norm,
    MfrmrGradientSupNorm = reference_derivative$gradient_sup_norm,
    ReportedHessianMinimumEigenvalue =
      reported_derivative$minimum_eigenvalue,
    MfrmrHessianMinimumEigenvalue =
      reference_derivative$minimum_eigenvalue,
    ReportedHessianPositiveDefinite =
      reported_derivative$positive_definite,
    MfrmrHessianPositiveDefinite =
      reference_derivative$positive_definite,
    ReportedHessianConditionNumber = reported_derivative$condition_number,
    ReportedNewtonDecrement = reported_derivative$newton_decrement,
    ReferenceCurvatureDistance = curvature_distance,
    ToleranceFrozen = FALSE,
    CandidateBound = FALSE,
    ComparisonReady = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_rplc_integration_rows <- function(policy, fixture) {
  plan <- data.frame(
    Model = c("RSM", "PCM"),
    Q31RunId = c("rsm_q031", "pcm_q031"),
    Q61RunId = c("rsm_q061", "pcm_q061"),
    stringsAsFactors = FALSE
  )
  do.call(rbind, lapply(seq_len(nrow(plan)), function(index) {
    model <- plan$Model[index]
    q31 <- policy$rows[policy$rows$RunId == plan$Q31RunId[index], , drop = FALSE]
    q61 <- policy$rows[policy$rows$RunId == plan$Q61RunId[index], , drop = FALSE]
    common_coordinate <- setdiff(
      intersect(q31$Coordinate, q61$Coordinate), "deviance"
    )
    q31 <- q31[match(common_coordinate, q31$Coordinate), , drop = FALSE]
    q61 <- q61[match(common_coordinate, q61$Coordinate), , drop = FALSE]
    token_identical <- identical(
      as.character(q31$CanonicalExactDecimal),
      as.character(q61$CanonicalExactDecimal)
    )
    mfrmr_cq_rplc_assert(
      token_identical,
      paste0("The ", model, " q31/q61 exact reported coordinates differ.")
    )
    point <- mfrmr_cq_rplc_free_vector(q61, "NativeValue", model)
    q31_deviance <- mfrmr_cq_rplc_deviance_function(
      model, 31L, fixture
    )(point)
    q61_deviance <- mfrmr_cq_rplc_deviance_function(
      model, 61L, fixture
    )(point)
    data.frame(
      Model = model,
      CoordinateSourceRunId = plan$Q61RunId[index],
      ExactReportedCoordinatesIdentical = token_identical,
      Q31CommonDeviance = q31_deviance,
      Q61CommonDeviance = q61_deviance,
      SamePointIntegrationAbsDifference = abs(q61_deviance - q31_deviance),
      IntegrationToleranceFrozen = FALSE,
      CandidateBound = FALSE,
      ComparisonReady = FALSE,
      ScientificEquivalenceInferred = FALSE,
      stringsAsFactors = FALSE
    )
  }))
}

mfrmr_calibrate_conquest_reported_point_likelihood <- function(
    policy, output_dir, review) {
  mfrmr_cq_rplc_require_helpers()
  mfrmr_cq_rop_validate_policy(policy)
  output_dir <- normalizePath(
    as.character(output_dir)[1L], winslash = "/", mustWork = TRUE
  )
  mfrmr_cq_rplc_assert(
    inherits(review, "mfrmr_conquest_native_four_arm_review") &&
      isTRUE(review$four_arms_complete) &&
      isTRUE(review$cross_manifest_plan_identical) &&
      isTRUE(review$cross_manifest_wide_sha256_identical) &&
      isTRUE(review$native_design_matrices_exact) &&
      is.data.frame(review$descriptive_differences),
    "The common-likelihood calibration requires the source-bound four-arm review."
  )
  fixture <- mfrmr_cq_additive_fixture()
  plan <- data.frame(
    RunId = c("rsm_q031", "rsm_q061", "pcm_q031", "pcm_q061"),
    Model = c("RSM", "RSM", "PCM", "PCM"),
    Nodes = c(31L, 61L, 31L, 61L),
    stringsAsFactors = FALSE
  )
  input_identity <- vapply(plan$RunId, function(run_id) {
    wide_file <- file.path(
      output_dir, run_id, paste0("cq_additive_", run_id, "_wide.csv")
    )
    mfrmr_cq_rplc_assert(file.exists(wide_file),
                         "A retained additive wide input is missing.")
    observed <- utils::read.csv(
      wide_file, check.names = FALSE, stringsAsFactors = FALSE
    )
    identical(names(observed), names(fixture$wide)) &&
      identical(as.character(observed$Person),
                as.character(fixture$wide$Person)) &&
      isTRUE(all.equal(
        as.matrix(observed[, setdiff(names(observed), "Person"), drop = FALSE]),
        as.matrix(fixture$wide[, setdiff(names(fixture$wide), "Person"),
                               drop = FALSE]),
        tolerance = 0, check.attributes = FALSE
      ))
  }, logical(1L))
  mfrmr_cq_rplc_assert(
    all(input_identity),
    "The retained ConQuest inputs do not equal the deterministic fixture."
  )
  policy_key <- paste(policy$rows$RunId, policy$rows$Coordinate, sep = "\r")
  review_difference <- review$descriptive_differences
  review_key <- paste(
    review_difference$RunId, review_difference$Coordinate, sep = "\r"
  )
  review_difference <- review_difference[match(policy_key, review_key), ,
                                         drop = FALSE]
  mfrmr_cq_rplc_assert(
    !anyNA(match(policy_key, review_key)) &&
      identical(as.numeric(policy$rows$NativeValue),
                as.numeric(review_difference$NativeValue)) &&
      identical(as.numeric(policy$rows$MfrmrReferenceValue),
                as.numeric(review_difference$MfrmrReferenceValue)),
    "The precision policy is not bound to the reviewed numerical rows."
  )
  integration <- mfrmr_cq_rplc_integration_rows(policy, fixture)
  rownames(integration) <- NULL
  arms <- do.call(rbind, lapply(seq_len(nrow(plan)), function(index) {
    mfrmr_cq_rplc_one_arm(
      policy, plan$RunId[index], plan$Model[index], plan$Nodes[index], fixture
    )
  }))
  rownames(arms) <- NULL
  out <- list(
    specification = mfrmr_cq_rplc_specification,
    contract_version = mfrmr_cq_rplc_contract,
    status = "opened_calibration_common_likelihood_ready_tolerance_missing",
    source_precision_policy_id = as.character(policy$policy_id),
    source_bound_review_verified = TRUE,
    deterministic_input_identity_verified = all(input_identity),
    reported_output_scope = "exact_reported_decimal",
    hidden_solution_equivalence_eligible = FALSE,
    calibration_results_opened = TRUE,
    tolerance_may_be_informed_for_future_candidate = TRUE,
    calibration_may_pass_new_tolerance = FALSE,
    tolerance_frozen = FALSE,
    candidate_bound = FALSE,
    comparison_ready = FALSE,
    scientific_equivalence_inferred = FALSE,
    confirmation_authorized = FALSE,
    arms = arms,
    integration = integration
  )
  class(out) <- c(
    "mfrmr_conquest_reported_point_likelihood_calibration", class(out)
  )
  out
}
