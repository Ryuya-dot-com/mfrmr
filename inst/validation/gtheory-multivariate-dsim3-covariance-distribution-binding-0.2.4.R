# Internal D-SIM-3 covariance-regime and response-distribution binding.
#
# This second shared-substrate layer binds component covariance factors and
# response-kernel contracts to the exact semantic compiler identities. It
# performs no random draw, response generation, backend call, or fit.

mfrmr_gtds3b_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3_manifest",
    "mfrmr_gtds3_assert_manifest", "mfrmr_gtds3c_contract",
    "mfrmr_gtds3c_validate_contract", "mfrmr_gtds3c_manifest",
    "mfrmr_gtds3c_assert_manifest", "mfrmr_gtds3c_compile_profile",
    "mfrmr_gtds3c_assert_compilation"
  )
  target <- environment(mfrmr_gtds3b_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the D-SIM-3 semantic design-compiler chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3b_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3b_identity <- function() {
  list(
    ContractId =
      "MFRMR-GTHEORY-MV-DSIM3-COVARIANCE-DISTRIBUTION-BINDING-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-30",
    ParentCompilerContractId =
      "MFRMR-GTHEORY-MV-DSIM3-SEMANTIC-DESIGN-COMPILER-V1",
    ParentCompilerContractHash =
      "67cb6077c0b0fb083362c0b7bae498be6695e61a0f84d1636f992479ef79f666",
    ParentCompilerManifestHash =
      "dd69c9eb4f7b75641efb9f4b9bbfcee7818b8a645a7c70cdbc8f9b2551d74a3b",
    ParentCompilerRecord = paste0(
      "gtheory-multivariate-dsim3-semantic-design-compiler-record-",
      "0.2.4.md"
    )
  )
}

mfrmr_gtds3b_component_registry <- function() {
  data.frame(
    ComponentOrdinal = 1:4,
    ComponentId = c("Object", "Rater", "Object:Rater", "Residual"),
    UniverseRole = c(
      "object", "absolute_only", "relative_error", "relative_error"
    ),
    CrossStratumIdentitySource = c(
      "global_object_universe", "condition_identity",
      "object_by_condition_identity", "observation_event_identity"
    ),
    DuplicateResidualRepresentationAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3b_variance_registry <- function() {
  regimes <- c(
    "regular_interior", "near_zero_component", "dominant_component",
    "near_singular_covariance"
  )
  values <- rbind(
    c(1.00, 0.20, 0.35, 0.50),
    c(1.00, 0.000001, 0.35, 0.50),
    c(3.00, 0.10, 0.20, 0.30),
    c(1.00, 0.20, 0.35, 0.50)
  )
  output <- expand.grid(
    ComponentOrdinal = 1:4,
    VarianceRegime = regimes,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  output$ComponentId <- mfrmr_gtds3b_component_registry()$ComponentId[
    output$ComponentOrdinal
  ]
  output$MarginalVariance <- as.numeric(t(values))
  output$BoundaryRole <- ifelse(
    output$VarianceRegime == "near_zero_component" &
      output$ComponentId == "Rater", "near_zero_rater_variance",
    ifelse(
      output$VarianceRegime == "dominant_component" &
        output$ComponentId == "Object", "dominant_object_variance",
      ifelse(
        output$VarianceRegime == "near_singular_covariance" &
          output$ComponentId == "Object", "near_singular_object_block",
        "ordinary_positive_variance"
      )
    )
  )
  output[c(
    "VarianceRegime", "ComponentOrdinal", "ComponentId",
    "MarginalVariance", "BoundaryRole"
  )]
}

mfrmr_gtds3b_kernel_registry <- function() {
  data.frame(
    KernelOrdinal = 1:3,
    ResponseDistribution = c(
      "gaussian", "heavy_tailed", "ordinal_aggregate"
    ),
    KernelFamily = c(
      "standard_normal_identity", "standardized_student_t_df5",
      "five_level_thresholded_latent_score"
    ),
    LatentInnovation = c("normal", "student_t", "normal"),
    DegreesFreedom = c(NA_real_, 5, NA_real_),
    OutputSupport = c("real", "real", "integer_0_to_4"),
    IrtResponseModel = FALSE,
    StochasticDrawQualified = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3b_contract <- function() {
  mfrmr_gtds3b_require_primitives()
  identity <- mfrmr_gtds3b_identity()
  payload <- c(identity, list(
    ExpectedProfileCount = 21L,
    ExpectedComponentCount = 4L,
    ExpectedCovarianceBindingCount = 84L,
    ExpectedKernelBindingCount = 21L,
    BoundAxisIds = c(
      "variance_regime", "cross_stratum_covariance",
      "response_distribution"
    ),
    ComponentRegistry = mfrmr_gtds3b_component_registry(),
    VarianceRegistry = mfrmr_gtds3b_variance_registry(),
    KernelRegistry = mfrmr_gtds3b_kernel_registry(),
    MatrixTolerance = 1e-10,
    BoundaryTolerance = 1e-5,
    NearSingularEpsilon = 1e-6,
    ZeroCovarianceNearSingularVariance = 1e-8,
    PositiveCorrelation = 0.4,
    NegativeCorrelationTwoStrata = -0.3,
    NegativeCorrelationThreeStrata = -0.2,
    OverlapMatricesMustBePsd = TRUE,
    CovarianceMatricesMustBePsd = TRUE,
    PsdRepairAllowed = FALSE,
    DuplicateResidualRepresentationAllowed = FALSE,
    OrdinalAggregateIsIrtModel = FALSE,
    ScenarioSpecificPatchCount = 0L,
    BindingMayUseRng = FALSE,
    BindingMayGenerateResponses = FALSE,
    BindingMayCallBackend = FALSE,
    FullGeneratorAdapterQualified = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3b_hash(payload)
  )), class = c("mfrmr_gtds3b_contract", "list"))
}

mfrmr_gtds3b_validate_contract <- function(
    contract = mfrmr_gtds3b_contract(), compiler_manifest = NULL) {
  mfrmr_gtds3b_require_primitives()
  if (is.null(compiler_manifest)) {
    compiler_manifest <- mfrmr_gtds3c_manifest()
  }
  mfrmr_gtds3c_assert_manifest(compiler_manifest)
  canonical <- mfrmr_gtds3b_contract()
  valid <- inherits(contract, "mfrmr_gtds3b_contract") &&
    identical(contract, canonical) &&
    identical(
      contract$ParentCompilerContractHash,
      compiler_manifest$Contract$ContractHash
    ) && identical(
      contract$ParentCompilerManifestHash,
      compiler_manifest$ManifestHash
    ) && identical(contract$ExpectedProfileCount, 21L) &&
    identical(contract$ExpectedComponentCount, 4L) &&
    identical(contract$ExpectedCovarianceBindingCount, 84L) &&
    identical(contract$ExpectedKernelBindingCount, 21L) &&
    identical(length(contract$BoundAxisIds), 3L) &&
    identical(nrow(contract$ComponentRegistry), 4L) &&
    identical(nrow(contract$VarianceRegistry), 16L) &&
    identical(nrow(contract$KernelRegistry), 3L) &&
    isTRUE(contract$OverlapMatricesMustBePsd) &&
    isTRUE(contract$CovarianceMatricesMustBePsd) &&
    !isTRUE(contract$PsdRepairAllowed) &&
    !isTRUE(contract$DuplicateResidualRepresentationAllowed) &&
    !isTRUE(contract$OrdinalAggregateIsIrtModel) &&
    identical(contract$ScenarioSpecificPatchCount, 0L) &&
    !isTRUE(contract$BindingMayUseRng) &&
    !isTRUE(contract$BindingMayGenerateResponses) &&
    !isTRUE(contract$BindingMayCallBackend) &&
    !isTRUE(contract$FullGeneratorAdapterQualified) &&
    !isTRUE(contract$ExploratoryExecutionAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-3 covariance/distribution contract is invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3b_matrix_audit <- function(
    matrix, matrix_id, tolerance = 1e-10, boundary_tolerance = 1e-5) {
  if (!is.matrix(matrix) || !is.numeric(matrix) || nrow(matrix) == 0L ||
      nrow(matrix) != ncol(matrix) || is.null(rownames(matrix)) ||
      !identical(rownames(matrix), colnames(matrix)) ||
      anyNA(matrix) || any(!is.finite(matrix))) {
    stop("A finite square named matrix is required for `", matrix_id, "`.",
         call. = FALSE)
  }
  asymmetry <- max(abs(matrix - t(matrix)))
  if (asymmetry > tolerance) {
    stop("Matrix `", matrix_id, "` is asymmetric.", call. = FALSE)
  }
  symmetric <- (matrix + t(matrix)) / 2
  eigenvalues <- eigen(
    symmetric, symmetric = TRUE, only.values = TRUE
  )$values
  if (min(eigenvalues) < -tolerance) {
    stop("Matrix `", matrix_id, "` is indefinite; PSD repair is prohibited.",
         call. = FALSE)
  }
  scale <- max(1, max(abs(eigenvalues)))
  rank <- sum(eigenvalues > tolerance * scale)
  data.frame(
    MatrixId = matrix_id,
    Dimension = nrow(matrix),
    MinimumEigenvalue = min(eigenvalues),
    MaximumEigenvalue = max(eigenvalues),
    EffectiveRank = as.integer(rank),
    RankDeficient = rank < nrow(matrix),
    Boundary = min(eigenvalues) <= boundary_tolerance,
    MaximumAsymmetry = asymmetry,
    PositiveSemidefinite = TRUE,
    MatrixHash = mfrmr_gtds3b_hash(symmetric),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3b_identity_overlap <- function(
    compilation, identity_col, component_id) {
  assignments <- compilation$AssignmentRegistry
  strata <- compilation$StratumRegistry$Stratum
  if (!identity_col %in% names(assignments)) {
    stop("The compiled identity column is unavailable: ", identity_col, ".",
         call. = FALSE)
  }
  identities <- sort(unique(as.character(assignments[[identity_col]])),
                     method = "radix")
  weights <- matrix(
    0, nrow = length(strata), ncol = length(identities),
    dimnames = list(strata, identities)
  )
  for (index in seq_along(strata)) {
    present <- sort(unique(as.character(assignments[
      assignments$Stratum == strata[[index]], identity_col
    ])), method = "radix")
    weights[index, match(present, identities)] <- 1 / sqrt(length(present))
  }
  overlap <- weights %*% t(weights)
  dimnames(overlap) <- list(strata, strata)
  audit <- mfrmr_gtds3b_matrix_audit(
    overlap, paste0("Overlap/", component_id)
  )
  if (max(abs(diag(overlap) - 1)) > 1e-10 ||
      any(overlap < -1e-10) || any(overlap > 1 + 1e-10)) {
    stop("The identity-overlap matrix is not a normalized Gram matrix.",
         call. = FALSE)
  }
  list(
    ComponentId = component_id,
    IdentityColumn = identity_col,
    Matrix = overlap,
    WeightMatrixHash = mfrmr_gtds3b_hash(weights),
    Audit = audit
  )
}

mfrmr_gtds3b_component_overlap <- function(compilation, component_id) {
  strata <- compilation$StratumRegistry$Stratum
  if (identical(component_id, "Object")) {
    matrix <- matrix(
      1, nrow = length(strata), ncol = length(strata),
      dimnames = list(strata, strata)
    )
    return(list(
      ComponentId = component_id,
      IdentityColumn = "ObjectId",
      Matrix = matrix,
      WeightMatrixHash = NA_character_,
      Audit = mfrmr_gtds3b_matrix_audit(matrix, "Overlap/Object")
    ))
  }
  if (identical(component_id, "Object:Rater")) {
    compilation$AssignmentRegistry$ObjectConditionId <- paste(
      compilation$AssignmentRegistry$ObjectId,
      compilation$AssignmentRegistry$ConditionId, sep = "/"
    )
    return(mfrmr_gtds3b_identity_overlap(
      compilation, "ObjectConditionId", component_id
    ))
  }
  identity_col <- if (identical(component_id, "Rater")) {
    "ConditionId"
  } else if (identical(component_id, "Residual")) {
    "EventId"
  } else {
    stop("Unknown D-SIM-3 covariance component.", call. = FALSE)
  }
  mfrmr_gtds3b_identity_overlap(
    compilation, identity_col, component_id
  )
}

mfrmr_gtds3b_marginal_variances <- function(
    contract, profile, component_id, strata) {
  regime <- profile[["variance_regime"]]
  row <- contract$VarianceRegistry[
    contract$VarianceRegistry$VarianceRegime == regime &
      contract$VarianceRegistry$ComponentId == component_id,
    , drop = FALSE
  ]
  if (nrow(row) != 1L) {
    stop("The component variance regime is not uniquely registered.",
         call. = FALSE)
  }
  variances <- rep(row$MarginalVariance[[1L]], length(strata))
  if (regime == "near_singular_covariance" &&
      profile[["cross_stratum_covariance"]] == "zero" &&
      component_id == "Object" && length(strata) > 1L) {
    variances[[length(strata)]] <-
      contract$ZeroCovarianceNearSingularVariance
  }
  stats::setNames(variances, strata)
}

mfrmr_gtds3b_correlation <- function(
    contract, profile, component_id, overlap) {
  strata <- rownames(overlap)
  count <- length(strata)
  identity <- diag(count)
  dimnames(identity) <- list(strata, strata)
  covariance_level <- profile[["cross_stratum_covariance"]]
  if (count == 1L || covariance_level == "zero") return(identity)
  near <- profile[["variance_regime"]] == "near_singular_covariance" &&
    component_id == "Object"
  if (covariance_level == "positive_psd") {
    rho <- if (near) 1 - contract$NearSingularEpsilon else
      contract$PositiveCorrelation
    return((1 - rho) * identity + rho * overlap)
  }
  if (covariance_level != "negative_psd") {
    stop("The cross-stratum covariance level is not compiled.",
         call. = FALSE)
  }
  magnitude <- if (near) {
    if (count == 2L) 1 - contract$NearSingularEpsilon else
      1 / (count - 1L) - contract$NearSingularEpsilon
  } else if (count == 2L) {
    abs(contract$NegativeCorrelationTwoStrata)
  } else {
    abs(contract$NegativeCorrelationThreeStrata)
  }
  identity - magnitude * (overlap - identity)
}

mfrmr_gtds3b_covariance_factor <- function(
    contract, profile, component_id, overlap) {
  strata <- rownames(overlap)
  variances <- mfrmr_gtds3b_marginal_variances(
    contract, profile, component_id, strata
  )
  correlation <- mfrmr_gtds3b_correlation(
    contract, profile, component_id, overlap
  )
  correlation_audit <- mfrmr_gtds3b_matrix_audit(
    correlation, paste0("Correlation/", component_id),
    contract$MatrixTolerance, contract$BoundaryTolerance
  )
  scale <- diag(sqrt(variances), nrow = length(strata))
  dimnames(scale) <- list(strata, strata)
  covariance <- scale %*% correlation %*% scale
  dimnames(covariance) <- list(strata, strata)
  covariance_audit <- mfrmr_gtds3b_matrix_audit(
    covariance, paste0("Covariance/", component_id),
    contract$MatrixTolerance, contract$BoundaryTolerance
  )
  factor <- t(chol(covariance))
  factor <- signif(factor, 14L)
  rownames(factor) <- strata
  colnames(factor) <- paste0("Factor", seq_along(strata))
  reconstruction <- factor %*% t(factor)
  dimnames(reconstruction) <- list(strata, strata)
  maximum_error <- max(abs(reconstruction - covariance))
  if (maximum_error > contract$MatrixTolerance) {
    stop("The covariance factor does not reconstruct its matrix.",
         call. = FALSE)
  }
  list(
    ComponentId = component_id,
    MarginalVariances = variances,
    OverlapMatrix = overlap,
    CorrelationMatrix = correlation,
    CovarianceMatrix = covariance,
    FactorMatrix = factor,
    CorrelationAudit = correlation_audit,
    CovarianceAudit = covariance_audit,
    FactorReconstructionMaximumError = maximum_error,
    FactorHash = mfrmr_gtds3b_hash(factor)
  )
}

mfrmr_gtds3b_kernel <- function(response_distribution) {
  response_distribution <- as.character(response_distribution)
  if (length(response_distribution) != 1L ||
      is.na(response_distribution)) {
    stop("One response-distribution level is required.", call. = FALSE)
  }
  input <- c(-3, -1.5, -0.5, 0, 0.5, 1.5, 3)
  if (response_distribution == "gaussian") {
    payload <- list(
      ResponseDistribution = response_distribution,
      KernelFamily = "standard_normal_identity",
      LatentInnovation = "normal",
      Standardization = "mean_zero_variance_one",
      DegreesFreedom = NA_real_, Cutpoints = numeric(),
      ScoreValues = numeric(), ProbeInput = input, ProbeOutput = input,
      OutputSupport = "real", ExpectedMean = 0, ExpectedVariance = 1,
      MonotoneProbe = TRUE, SymmetricProbe = TRUE,
      IrtResponseModel = FALSE, StochasticDrawQualified = FALSE,
      ResponseGenerated = FALSE
    )
  } else if (response_distribution == "heavy_tailed") {
    degrees <- 5
    output <- stats::qt(stats::pnorm(input), df = degrees) *
      sqrt((degrees - 2) / degrees)
    payload <- list(
      ResponseDistribution = response_distribution,
      KernelFamily = "standardized_student_t_df5",
      LatentInnovation = "student_t",
      Standardization = "mean_zero_variance_one",
      DegreesFreedom = degrees, Cutpoints = numeric(),
      ScoreValues = numeric(), ProbeInput = input, ProbeOutput = output,
      OutputSupport = "real", ExpectedMean = 0, ExpectedVariance = 1,
      MonotoneProbe = all(diff(output) > 0),
      SymmetricProbe = max(abs(output + rev(output))) <= 1e-12,
      IrtResponseModel = FALSE, StochasticDrawQualified = FALSE,
      ResponseGenerated = FALSE
    )
  } else if (response_distribution == "ordinal_aggregate") {
    cutpoints <- c(-1.25, -0.35, 0.35, 1.25)
    scores <- 0:4
    output <- scores[findInterval(input, cutpoints) + 1L]
    payload <- list(
      ResponseDistribution = response_distribution,
      KernelFamily = "five_level_thresholded_latent_score",
      LatentInnovation = "normal",
      Standardization = "latent_mean_zero_variance_one",
      DegreesFreedom = NA_real_, Cutpoints = cutpoints,
      ScoreValues = scores, ProbeInput = input, ProbeOutput = output,
      OutputSupport = "integer_0_to_4", ExpectedMean = NA_real_,
      ExpectedVariance = NA_real_, MonotoneProbe = all(diff(output) >= 0),
      SymmetricProbe = identical(as.numeric(output + rev(output)),
                                 rep(4, length(output))),
      IrtResponseModel = FALSE, StochasticDrawQualified = FALSE,
      ResponseGenerated = FALSE
    )
  } else {
    stop("The response-distribution level is not compiled.", call. = FALSE)
  }
  structure(c(payload, list(
    KernelHash = mfrmr_gtds3b_hash(payload),
    KernelContractQualified = isTRUE(payload$MonotoneProbe) &&
      isTRUE(payload$SymmetricProbe),
    RngStreamOpened = FALSE
  )), class = c("mfrmr_gtds3b_kernel", "list"))
}

mfrmr_gtds3b_assert_kernel <- function(kernel) {
  if (!inherits(kernel, "mfrmr_gtds3b_kernel") ||
      is.null(kernel$ResponseDistribution)) {
    stop("A typed D-SIM-3 response-kernel binding is required.",
         call. = FALSE)
  }
  canonical <- mfrmr_gtds3b_kernel(kernel$ResponseDistribution)
  if (!identical(kernel, canonical) ||
      !isTRUE(kernel$KernelContractQualified) ||
      isTRUE(kernel$IrtResponseModel) ||
      isTRUE(kernel$StochasticDrawQualified) ||
      isTRUE(kernel$ResponseGenerated) || isTRUE(kernel$RngStreamOpened)) {
    stop("The D-SIM-3 response-kernel binding was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3b_regime_qualified <- function(
    contract, profile, component_bindings) {
  regime <- profile[["variance_regime"]]
  object <- component_bindings$Object
  rater <- component_bindings$Rater
  diagonals <- vapply(component_bindings, function(binding) {
    mean(diag(binding$CovarianceMatrix))
  }, numeric(1L))
  if (regime == "regular_interior") {
    return(all(vapply(component_bindings, function(binding) {
      !binding$CovarianceAudit$Boundary
    }, logical(1L))))
  }
  if (regime == "near_zero_component") {
    return(max(diag(rater$CovarianceMatrix)) <= contract$BoundaryTolerance)
  }
  if (regime == "dominant_component") {
    ordered <- sort(diagonals, decreasing = TRUE)
    return(names(which.max(diagonals)) == "Object" &&
             ordered[[1L]] / ordered[[2L]] >= 9)
  }
  isTRUE(object$CovarianceAudit$Boundary)
}

mfrmr_gtds3b_covariance_sign_qualified <- function(
    profile, component_bindings) {
  count <- nrow(component_bindings$Object$CovarianceMatrix)
  if (count == 1L) return(profile[["cross_stratum_covariance"]] == "zero")
  off_diagonal <- function(matrix) matrix[row(matrix) != col(matrix)]
  object_off <- off_diagonal(component_bindings$Object$CovarianceMatrix)
  all_off <- unlist(lapply(component_bindings, function(binding) {
    off_diagonal(binding$CovarianceMatrix)
  }), use.names = FALSE)
  level <- profile[["cross_stratum_covariance"]]
  if (level == "zero") return(all(abs(all_off) <= 1e-12))
  if (level == "positive_psd") {
    return(all(object_off > 0) && all(all_off >= -1e-12))
  }
  all(object_off < 0) && all(all_off <= 1e-12)
}

mfrmr_gtds3b_bind_profile <- function(
    scenario_id, contract = mfrmr_gtds3b_contract(),
    compiler_contract = mfrmr_gtds3c_contract(),
    coverage = mfrmr_gtds3_manifest(), validate = TRUE) {
  if (isTRUE(validate)) {
    compiler_manifest <- mfrmr_gtds3c_manifest()
    mfrmr_gtds3b_validate_contract(contract, compiler_manifest)
    mfrmr_gtds3c_validate_contract(compiler_contract)
    mfrmr_gtds3_assert_manifest(coverage)
  }
  compilation <- mfrmr_gtds3c_compile_profile(
    scenario_id, compiler_contract, coverage, validate = FALSE
  )
  profile <- unlist(compilation$Profile, use.names = TRUE)
  components <- contract$ComponentRegistry$ComponentId
  overlap_bindings <- stats::setNames(lapply(components, function(component) {
    mfrmr_gtds3b_component_overlap(compilation, component)
  }), components)
  component_bindings <- stats::setNames(lapply(components, function(component) {
    mfrmr_gtds3b_covariance_factor(
      contract, profile, component, overlap_bindings[[component]]$Matrix
    )
  }), components)
  kernel <- mfrmr_gtds3b_kernel(profile[["response_distribution"]])
  mfrmr_gtds3b_assert_kernel(kernel)
  covariance_audit <- do.call(rbind, lapply(component_bindings, function(x) {
    data.frame(
      ComponentId = x$ComponentId,
      x$CovarianceAudit[c(
        "MinimumEigenvalue", "MaximumEigenvalue", "EffectiveRank",
        "RankDeficient", "Boundary", "PositiveSemidefinite", "MatrixHash"
      )],
      FactorReconstructionMaximumError =
        x$FactorReconstructionMaximumError,
      FactorHash = x$FactorHash,
      stringsAsFactors = FALSE
    )
  }))
  row.names(covariance_audit) <- NULL
  regime_qualified <- mfrmr_gtds3b_regime_qualified(
    contract, profile, component_bindings
  )
  sign_qualified <- mfrmr_gtds3b_covariance_sign_qualified(
    profile, component_bindings
  )
  all_psd <- all(covariance_audit$PositiveSemidefinite)
  factors_qualified <- all(
    covariance_audit$FactorReconstructionMaximumError <=
      contract$MatrixTolerance
  )
  binding_qualified <- all(c(
    regime_qualified, sign_qualified, all_psd, factors_qualified,
    kernel$KernelContractQualified
  ))
  summary <- list(
    ScenarioId = scenario_id,
    CompilerCompilationHash = compilation$CompilationHash,
    StratumCount = compilation$Summary$StratumCount,
    VarianceRegime = profile[["variance_regime"]],
    CrossStratumCovariance = profile[["cross_stratum_covariance"]],
    ResponseDistribution = profile[["response_distribution"]],
    ComponentBindingCount = length(component_bindings),
    PositiveSemidefiniteComponentCount = sum(
      covariance_audit$PositiveSemidefinite
    ),
    FactorReconstructionQualifiedCount = sum(
      covariance_audit$FactorReconstructionMaximumError <=
        contract$MatrixTolerance
    ),
    RegimeQualified = regime_qualified,
    CrossStratumCovarianceSignQualified = sign_qualified,
    ResponseKernelQualified = kernel$KernelContractQualified,
    CovarianceDistributionBindingQualified = binding_qualified,
    FullGeneratorAdapterQualified = FALSE,
    GeneratorSemanticsQualified = FALSE,
    RngStreamOpened = FALSE, ResponseGenerated = FALSE,
    BackendCallMade = FALSE, FitExecuted = FALSE,
    CovarianceRegistryHash = mfrmr_gtds3b_hash(component_bindings),
    OverlapRegistryHash = mfrmr_gtds3b_hash(overlap_bindings),
    CovarianceAuditHash = mfrmr_gtds3b_hash(covariance_audit),
    KernelHash = kernel$KernelHash
  )
  payload <- list(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    ScenarioId = scenario_id,
    CompilerCompilationHash = compilation$CompilationHash,
    Profile = compilation$Profile,
    ComponentRegistry = contract$ComponentRegistry,
    OverlapBindings = overlap_bindings,
    ComponentBindings = component_bindings,
    CovarianceAudit = covariance_audit,
    ResponseKernel = kernel,
    Summary = summary
  )
  structure(c(payload, list(
    BindingHash = mfrmr_gtds3b_hash(payload)
  )), class = c("mfrmr_gtds3b_binding", "list"))
}

mfrmr_gtds3b_binding_fields <- function() {
  c(
    "ContractId", "ContractHash", "ScenarioId",
    "CompilerCompilationHash", "Profile", "ComponentRegistry",
    "OverlapBindings", "ComponentBindings", "CovarianceAudit",
    "ResponseKernel", "Summary"
  )
}

mfrmr_gtds3b_assert_binding <- function(
    binding, contract = mfrmr_gtds3b_contract(),
    compiler_contract = mfrmr_gtds3c_contract(),
    coverage = mfrmr_gtds3_manifest(), validate = TRUE,
    replay = TRUE) {
  fields <- mfrmr_gtds3b_binding_fields()
  if (!inherits(binding, "mfrmr_gtds3b_binding") ||
      !identical(names(binding), c(fields, "BindingHash"))) {
    stop("A typed D-SIM-3 covariance/distribution binding is required.",
         call. = FALSE)
  }
  if (isTRUE(validate)) {
    compiler_manifest <- mfrmr_gtds3c_manifest()
    mfrmr_gtds3b_validate_contract(contract, compiler_manifest)
    mfrmr_gtds3c_validate_contract(compiler_contract)
    mfrmr_gtds3_assert_manifest(coverage)
  }
  canonical_match <- !isTRUE(replay) || identical(
    binding,
    mfrmr_gtds3b_bind_profile(
      binding$ScenarioId, contract, compiler_contract, coverage,
      validate = FALSE
    )
  )
  summary <- binding$Summary
  valid <- canonical_match &&
    identical(binding$ContractId, contract$ContractId) &&
    identical(binding$ContractHash, contract$ContractHash) &&
    identical(binding$ComponentRegistry, contract$ComponentRegistry) &&
    identical(binding$BindingHash, mfrmr_gtds3b_hash(binding[fields])) &&
    identical(length(binding$ComponentBindings), 4L) &&
    identical(nrow(binding$CovarianceAudit), 4L) &&
    all(binding$CovarianceAudit$PositiveSemidefinite) &&
    all(binding$CovarianceAudit$FactorReconstructionMaximumError <=
          contract$MatrixTolerance) &&
    isTRUE(summary$RegimeQualified) &&
    isTRUE(summary$CrossStratumCovarianceSignQualified) &&
    isTRUE(summary$ResponseKernelQualified) &&
    isTRUE(summary$CovarianceDistributionBindingQualified) &&
    !isTRUE(summary$FullGeneratorAdapterQualified) &&
    !isTRUE(summary$GeneratorSemanticsQualified) &&
    !isTRUE(summary$RngStreamOpened) && !isTRUE(summary$ResponseGenerated) &&
    !isTRUE(summary$BackendCallMade) && !isTRUE(summary$FitExecuted)
  if (!valid) {
    stop("The D-SIM-3 covariance/distribution binding was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3b_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds3b_require_primitives", "mfrmr_gtds3b_hash",
    "mfrmr_gtds3b_identity", "mfrmr_gtds3b_component_registry",
    "mfrmr_gtds3b_variance_registry", "mfrmr_gtds3b_kernel_registry",
    "mfrmr_gtds3b_contract", "mfrmr_gtds3b_validate_contract",
    "mfrmr_gtds3b_matrix_audit", "mfrmr_gtds3b_identity_overlap",
    "mfrmr_gtds3b_component_overlap",
    "mfrmr_gtds3b_marginal_variances", "mfrmr_gtds3b_correlation",
    "mfrmr_gtds3b_covariance_factor", "mfrmr_gtds3b_kernel",
    "mfrmr_gtds3b_assert_kernel", "mfrmr_gtds3b_regime_qualified",
    "mfrmr_gtds3b_covariance_sign_qualified",
    "mfrmr_gtds3b_bind_profile", "mfrmr_gtds3b_binding_fields",
    "mfrmr_gtds3b_assert_binding", "mfrmr_gtds3b_implementation_identity",
    "mfrmr_gtds3b_manifest_fields", "mfrmr_gtds3b_manifest",
    "mfrmr_gtds3b_assert_manifest"
  )
  target <- environment(mfrmr_gtds3b_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds3b_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)), stringsAsFactors = FALSE
  )
}

mfrmr_gtds3b_manifest_fields <- function() {
  c(
    "Contract", "ParentCompilerManifestHash", "ProfileBindingRegistry",
    "ComponentBindingRegistry", "KernelBindingRegistry",
    "ImplementationIdentity", "Summary"
  )
}

mfrmr_gtds3b_manifest <- function(
    contract = mfrmr_gtds3b_contract(),
    compiler_contract = mfrmr_gtds3c_contract(),
    coverage = mfrmr_gtds3_manifest(), compiler_manifest = NULL) {
  if (is.null(compiler_manifest)) {
    compiler_manifest <- mfrmr_gtds3c_manifest(
      compiler_contract, coverage
    )
  }
  mfrmr_gtds3b_validate_contract(contract, compiler_manifest)
  mfrmr_gtds3c_validate_contract(compiler_contract)
  mfrmr_gtds3_assert_manifest(coverage)
  profile_rows <- list(); component_rows <- list(); kernel_rows <- list()
  component_cursor <- 0L
  for (index in seq_len(nrow(compiler_manifest$ProfileCompilationRegistry))) {
    scenario_id <- compiler_manifest$ProfileCompilationRegistry$ScenarioId[[index]]
    binding <- mfrmr_gtds3b_bind_profile(
      scenario_id, contract, compiler_contract, coverage, validate = FALSE
    )
    mfrmr_gtds3b_assert_binding(
      binding, contract, compiler_contract, coverage,
      validate = FALSE, replay = FALSE
    )
    summary <- binding$Summary
    profile_rows[[index]] <- data.frame(
      BindingOrdinal = index, ScenarioId = scenario_id,
      CompilerCompilationHash = summary$CompilerCompilationHash,
      VarianceRegime = summary$VarianceRegime,
      CrossStratumCovariance = summary$CrossStratumCovariance,
      ResponseDistribution = summary$ResponseDistribution,
      ComponentBindingCount = summary$ComponentBindingCount,
      PositiveSemidefiniteComponentCount =
        summary$PositiveSemidefiniteComponentCount,
      FactorReconstructionQualifiedCount =
        summary$FactorReconstructionQualifiedCount,
      RegimeQualified = summary$RegimeQualified,
      CrossStratumCovarianceSignQualified =
        summary$CrossStratumCovarianceSignQualified,
      ResponseKernelQualified = summary$ResponseKernelQualified,
      CovarianceDistributionBindingQualified =
        summary$CovarianceDistributionBindingQualified,
      FullGeneratorAdapterQualified = FALSE,
      GeneratorSemanticsQualified = FALSE,
      RngStreamOpened = FALSE, ResponseGenerated = FALSE,
      BackendCallMade = FALSE, FitExecuted = FALSE,
      BindingHash = binding$BindingHash,
      stringsAsFactors = FALSE
    )
    for (component in contract$ComponentRegistry$ComponentId) {
      component_cursor <- component_cursor + 1L
      component_binding <- binding$ComponentBindings[[component]]
      component_rows[[component_cursor]] <- data.frame(
        ComponentBindingOrdinal = component_cursor,
        ScenarioId = scenario_id, ComponentId = component,
        MinimumEigenvalue =
          component_binding$CovarianceAudit$MinimumEigenvalue,
        MaximumEigenvalue =
          component_binding$CovarianceAudit$MaximumEigenvalue,
        Boundary = component_binding$CovarianceAudit$Boundary,
        PositiveSemidefinite =
          component_binding$CovarianceAudit$PositiveSemidefinite,
        FactorReconstructionMaximumError =
          component_binding$FactorReconstructionMaximumError,
        OverlapMatrixHash = mfrmr_gtds3b_hash(
          component_binding$OverlapMatrix
        ),
        CovarianceMatrixHash =
          component_binding$CovarianceAudit$MatrixHash,
        FactorHash = component_binding$FactorHash,
        RngStreamOpened = FALSE, ResponseGenerated = FALSE,
        stringsAsFactors = FALSE
      )
    }
    kernel_rows[[index]] <- data.frame(
      KernelBindingOrdinal = index, ScenarioId = scenario_id,
      ResponseDistribution = binding$ResponseKernel$ResponseDistribution,
      KernelFamily = binding$ResponseKernel$KernelFamily,
      KernelContractQualified =
        binding$ResponseKernel$KernelContractQualified,
      IrtResponseModel = binding$ResponseKernel$IrtResponseModel,
      StochasticDrawQualified =
        binding$ResponseKernel$StochasticDrawQualified,
      RngStreamOpened = FALSE, ResponseGenerated = FALSE,
      KernelHash = binding$ResponseKernel$KernelHash,
      stringsAsFactors = FALSE
    )
  }
  profiles <- do.call(rbind, profile_rows)
  components <- do.call(rbind, component_rows)
  kernels <- do.call(rbind, kernel_rows)
  row.names(profiles) <- row.names(components) <- row.names(kernels) <- NULL
  implementation <- mfrmr_gtds3b_implementation_identity()
  summary <- list(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    ParentCompilerManifestHash = contract$ParentCompilerManifestHash,
    ProfileBindingCount = nrow(profiles),
    QualifiedProfileBindingCount =
      sum(profiles$CovarianceDistributionBindingQualified),
    ComponentBindingCount = nrow(components),
    PositiveSemidefiniteComponentBindingCount =
      sum(components$PositiveSemidefinite),
    FactorReconstructionQualifiedCount = sum(
      components$FactorReconstructionMaximumError <=
        contract$MatrixTolerance
    ),
    KernelBindingCount = nrow(kernels),
    QualifiedKernelBindingCount = sum(kernels$KernelContractQualified),
    OrdinalIrtModelCount = sum(kernels$IrtResponseModel),
    ScenarioSpecificPatchCount = contract$ScenarioSpecificPatchCount,
    CovarianceDistributionLayerQualified = all(
      profiles$CovarianceDistributionBindingQualified
    ),
    FullGeneratorAdapterQualified = FALSE,
    GeneratorSemanticsQualifiedProfileCount = 0L,
    RouteAdapterQualified = FALSE,
    TerminalReceiptAdapterQualified = FALSE,
    ResourceControllerQualified = FALSE,
    RngStreamOpened = FALSE, ResponseGenerated = FALSE,
    BackendCallMade = FALSE, FitExecuted = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE,
    FeatureMaturity = "specified",
    NextAction = paste(
      "implement and qualify one generic response-generation adapter over",
      "the compiled identities, covariance factors, and kernel contracts",
      "using nonreserved shadow identities before any 855 execution"
    )
  )
  payload <- list(
    Contract = contract,
    ParentCompilerManifestHash = contract$ParentCompilerManifestHash,
    ProfileBindingRegistry = profiles,
    ComponentBindingRegistry = components,
    KernelBindingRegistry = kernels,
    ImplementationIdentity = implementation,
    Summary = summary
  )
  structure(c(payload, list(
    ManifestHash = mfrmr_gtds3b_hash(payload)
  )), class = c("mfrmr_gtds3b_manifest", "list"))
}

mfrmr_gtds3b_assert_manifest <- function(manifest) {
  fields <- mfrmr_gtds3b_manifest_fields()
  if (!inherits(manifest, "mfrmr_gtds3b_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-3 covariance/distribution manifest is required.",
         call. = FALSE)
  }
  mfrmr_gtds3b_validate_contract(manifest$Contract)
  profiles <- manifest$ProfileBindingRegistry
  components <- manifest$ComponentBindingRegistry
  kernels <- manifest$KernelBindingRegistry
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds3b_hash(manifest[fields])
  ) && identical(
    manifest$ImplementationIdentity, mfrmr_gtds3b_implementation_identity()
  ) && identical(nrow(profiles), 21L) &&
    identical(profiles$ScenarioId, sprintf("D3-S%03d", 1:21)) &&
    identical(nrow(components), 84L) && identical(nrow(kernels), 21L) &&
    !anyDuplicated(profiles$BindingHash) &&
    all(profiles$RegimeQualified) &&
    all(profiles$CrossStratumCovarianceSignQualified) &&
    all(profiles$ResponseKernelQualified) &&
    all(profiles$CovarianceDistributionBindingQualified) &&
    all(!profiles$FullGeneratorAdapterQualified) &&
    all(!profiles$GeneratorSemanticsQualified) &&
    all(components$PositiveSemidefinite) &&
    all(components$FactorReconstructionMaximumError <=
          manifest$Contract$MatrixTolerance) &&
    all(kernels$KernelContractQualified) &&
    all(!kernels$IrtResponseModel) &&
    all(!kernels$StochasticDrawQualified) &&
    all(!profiles$RngStreamOpened) && all(!profiles$ResponseGenerated) &&
    all(!components$RngStreamOpened) && all(!components$ResponseGenerated) &&
    all(!kernels$RngStreamOpened) && all(!kernels$ResponseGenerated) &&
    identical(manifest$Summary$ProfileBindingCount, 21L) &&
    identical(manifest$Summary$QualifiedProfileBindingCount, 21L) &&
    identical(manifest$Summary$ComponentBindingCount, 84L) &&
    identical(
      manifest$Summary$PositiveSemidefiniteComponentBindingCount, 84L
    ) && identical(
      manifest$Summary$FactorReconstructionQualifiedCount, 84L
    ) && identical(manifest$Summary$KernelBindingCount, 21L) &&
    identical(manifest$Summary$QualifiedKernelBindingCount, 21L) &&
    identical(manifest$Summary$OrdinalIrtModelCount, 0L) &&
    identical(manifest$Summary$ScenarioSpecificPatchCount, 0L) &&
    isTRUE(manifest$Summary$CovarianceDistributionLayerQualified) &&
    !isTRUE(manifest$Summary$FullGeneratorAdapterQualified) &&
    identical(
      manifest$Summary$GeneratorSemanticsQualifiedProfileCount, 0L
    ) && !isTRUE(manifest$Summary$RouteAdapterQualified) &&
    !isTRUE(manifest$Summary$TerminalReceiptAdapterQualified) &&
    !isTRUE(manifest$Summary$ResourceControllerQualified) &&
    !isTRUE(manifest$Summary$RngStreamOpened) &&
    !isTRUE(manifest$Summary$ResponseGenerated) &&
    !isTRUE(manifest$Summary$BackendCallMade) &&
    !isTRUE(manifest$Summary$FitExecuted) &&
    !isTRUE(manifest$Summary$ExploratoryExecutionAllowed) &&
    !isTRUE(manifest$Summary$SimulationValidationReady) &&
    !isTRUE(manifest$Summary$PublicSupportReady) &&
    identical(manifest$Summary$FeatureMaturity, "specified")
  if (!valid) {
    stop("The D-SIM-3 covariance/distribution manifest was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}
