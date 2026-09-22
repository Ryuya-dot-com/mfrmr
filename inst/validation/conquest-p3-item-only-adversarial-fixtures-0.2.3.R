# Repository-only P3 item-only PCM/GPCM fixtures and mathematical oracles.
#
# The fixtures are disjoint from the opened GPCM microcase. This file rebuilds
# the conditional A/C maps, finite quadrature ladder, and continuous marginal
# target before successor output exists. It never launches ConQuest or fits
# mfrmr, and it freezes no cross-engine acceptance tolerance.

mfrmr_cq_p3_specification <-
  "0.2.3-conquest-p3-item-only-adversarial-fixtures-v1"
mfrmr_cq_p3_contract <-
  "mfrmr_conquest_p3_item_only_adversarial_fixtures_v1"
mfrmr_cq_p3_fixture_set_id <-
  "mfrmr-0.2.3-conquest-p3-item-only-disjoint-001"
mfrmr_cq_p3_execution_identity <-
  "mfrmr-0.2.3-conquest-p3-item-only-execution-001"

mfrmr_cq_p3_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p3_require_contracts <- function() {
  target <- environment(mfrmr_cq_p3_require_contracts)
  required <- c(
    "mfrmr_cq_ssr_registry", "mfrmr_cq_gpcm_transform",
    "mfrmr_cq_gpcm_probability_audit"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- c(
    exists("mfrmr_cq_ssr_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_ssr_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_successor_semantic_registry_v1"
      ),
    exists("mfrmr_cq_gpcm_contract_version", envir = target,
           inherits = TRUE) &&
      identical(
        get("mfrmr_cq_gpcm_contract_version", envir = target,
            inherits = TRUE),
        "mfrmr_conquest_gpcm_item_latent_regression_overlap_v1"
      )
  )
  mfrmr_cq_p3_assert(
    all(available) && all(identity),
    "Source the exact successor registry and item-only GPCM overlap contract."
  )
  invisible(TRUE)
}

mfrmr_cq_p3_truth <- function(family, covariate = FALSE) {
  family <- toupper(as.character(family)[1L])
  covariate <- isTRUE(covariate)
  mfrmr_cq_p3_assert(family %in% c("PCM", "GPCM"),
                     "`family` must be PCM or GPCM.")
  location <- c(I1 = -0.65, I2 = -0.15, I3 = 0.25, I4 = 0.55)
  steps <- rbind(
    I1 = c(S1 = -1.10, S2 = 0.20, S3 = 0.90),
    I2 = c(S1 = -0.80, S2 = -0.10, S3 = 0.90),
    I3 = c(S1 = -1.30, S2 = 0.40, S3 = 0.90),
    I4 = c(S1 = -0.90, S2 = 0.30, S3 = 0.60)
  )
  slope <- if (family == "PCM") {
    c(I1 = 1, I2 = 1, I3 = 1, I4 = 1)
  } else {
    c(I1 = 0.50, I2 = 0.80, I3 = 1.25, I4 = 2.00)
  }
  mfrmr_cq_p3_assert(
    abs(sum(location)) < 1e-15 &&
      max(abs(rowSums(steps))) < 1e-15 &&
      abs(mean(log(slope))) < 1e-15,
    "The P3 truth does not satisfy its location, step, or slope constraints."
  )
  list(
    PopulationIntercept = 0.20,
    PopulationSlope = if (covariate) 0.40 else 0,
    PopulationVariance = 0.81,
    ItemLocation = location,
    ItemSlope = slope,
    ItemSteps = steps
  )
}

mfrmr_cq_p3_complete_data <- function() {
  data <- expand.grid(
    PersonIndex = seq_len(96L),
    ItemIndex = seq_len(4L),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  data <- data[order(data$PersonIndex, data$ItemIndex), , drop = FALSE]
  rownames(data) <- NULL
  data$Person <- sprintf("P3P%03d", data$PersonIndex)
  data$Item <- paste0("I", data$ItemIndex)
  data$X <- ifelse(data$PersonIndex <= 48L, -1, 1)
  data$Response <- as.integer(
    (data$PersonIndex + 2L * data$ItemIndex) %% 4L
  )
  data[, c(
    "Person", "PersonIndex", "X", "Item", "ItemIndex", "Response"
  ), drop = FALSE]
}

mfrmr_cq_p3_fixture <- function(registry_row_id) {
  mfrmr_cq_p3_require_contracts()
  registry <- mfrmr_cq_ssr_registry()
  allowed <- c(
    "P3-PCM-UNIT-SLOPE-INTERCEPT",
    "P3-GPCM-NONUNIT-INTERCEPT",
    "P3-GPCM-NONUNIT-COVARIATE"
  )
  id <- as.character(registry_row_id)[1L]
  row <- registry[registry$RegistryRowId == id, , drop = FALSE]
  mfrmr_cq_p3_assert(
    id %in% allowed && nrow(row) == 1L && row$Priority == "P3" &&
      row$ExpectedDisposition == "prospective_numeric_comparison",
    "`registry_row_id` must identify one prospective P3 item-only row."
  )
  covariate <- identical(row$PopulationFormula, "~1+X")
  list(
    Specification = mfrmr_cq_p3_specification,
    ContractVersion = mfrmr_cq_p3_contract,
    FixtureSetId = mfrmr_cq_p3_fixture_set_id,
    ProspectiveExecutionIdentity = mfrmr_cq_p3_execution_identity,
    ArmIdentity = paste0(mfrmr_cq_p3_execution_identity, "::", id),
    RegistryRowId = id,
    Family = row$Family,
    PopulationFormula = row$PopulationFormula,
    IntegrationNodeLadder = row$IntegrationNodeLadder,
    ExpectedFreeDimension = row$ExpectedFreeDimension,
    Data = mfrmr_cq_p3_complete_data(),
    Truth = mfrmr_cq_p3_truth(row$Family, covariate),
    CandidateOutputsPresent = FALSE,
    ExternalExecutionAuthorized = FALSE,
    ComparisonPassed = FALSE,
    ScientificEquivalenceInferred = FALSE
  )
}

mfrmr_cq_p3_fixture_registry <- function() {
  id <- c(
    "P3-PCM-UNIT-SLOPE-INTERCEPT",
    "P3-GPCM-NONUNIT-INTERCEPT",
    "P3-GPCM-NONUNIT-COVARIATE"
  )
  out <- lapply(id, mfrmr_cq_p3_fixture)
  names(out) <- id
  out
}

mfrmr_cq_p3_fixture_audit <- function(fixture) {
  mfrmr_cq_p3_require_contracts()
  required <- c(
    "Specification", "ContractVersion", "FixtureSetId",
    "ProspectiveExecutionIdentity", "ArmIdentity", "RegistryRowId",
    "Family", "PopulationFormula", "IntegrationNodeLadder",
    "ExpectedFreeDimension", "Data", "Truth", "CandidateOutputsPresent",
    "ExternalExecutionAuthorized", "ComparisonPassed",
    "ScientificEquivalenceInferred"
  )
  mfrmr_cq_p3_assert(
    is.list(fixture) && all(required %in% names(fixture)),
    "The P3 fixture is missing a required semantic field."
  )
  registry <- mfrmr_cq_ssr_registry()
  row <- registry[
    registry$RegistryRowId == fixture$RegistryRowId, , drop = FALSE
  ]
  mfrmr_cq_p3_assert(
    nrow(row) == 1L && row$Priority == "P3" &&
      row$ExpectedDisposition == "prospective_numeric_comparison",
    "The P3 fixture does not bind one prospective P3 registry row."
  )
  covariate <- identical(row$PopulationFormula, "~1+X")
  expected_truth <- mfrmr_cq_p3_truth(row$Family, covariate)
  support <- table(
    factor(fixture$Data$Response, levels = 0:3), fixture$Data$Item
  )
  identity_ready <- identical(fixture$Specification, mfrmr_cq_p3_specification) &&
    identical(fixture$ContractVersion, mfrmr_cq_p3_contract) &&
    identical(fixture$FixtureSetId, mfrmr_cq_p3_fixture_set_id) &&
    identical(
      fixture$ProspectiveExecutionIdentity, mfrmr_cq_p3_execution_identity
    ) &&
    identical(
      fixture$ArmIdentity,
      paste0(mfrmr_cq_p3_execution_identity, "::", fixture$RegistryRowId)
    )
  signature_ready <- identical(fixture$Family, row$Family) &&
    identical(fixture$PopulationFormula, row$PopulationFormula) &&
    identical(fixture$IntegrationNodeLadder, row$IntegrationNodeLadder) &&
    identical(fixture$ExpectedFreeDimension, row$ExpectedFreeDimension)
  data_ready <- identical(fixture$Data, mfrmr_cq_p3_complete_data()) &&
    identical(dim(support), c(4L, 4L)) && all(support > 0L)
  truth_ready <- identical(fixture$Truth, expected_truth) &&
    abs(sum(fixture$Truth$ItemLocation)) < 1e-15 &&
    max(abs(rowSums(fixture$Truth$ItemSteps))) < 1e-15 &&
    all(fixture$Truth$ItemSlope > 0) &&
    if (fixture$Family == "PCM") {
      all(fixture$Truth$ItemSlope == 1)
    } else {
      abs(mean(log(fixture$Truth$ItemSlope))) < 1e-15 &&
        length(unique(fixture$Truth$ItemSlope)) > 1L
    }
  execution_closed <- identical(fixture$CandidateOutputsPresent, FALSE) &&
    identical(fixture$ExternalExecutionAuthorized, FALSE) &&
    identical(fixture$ComparisonPassed, FALSE) &&
    identical(fixture$ScientificEquivalenceInferred, FALSE)
  list(
    RegistryRowId = fixture$RegistryRowId,
    IdentityReady = identity_ready,
    SignatureReady = signature_ready,
    DataAndSupportReady = data_ready,
    TruthAndConstraintsReady = truth_ready,
    ExecutionClosed = execution_closed,
    Ready = identity_ready && signature_ready && data_ready && truth_ready &&
      execution_closed,
    Support = support
  )
}

mfrmr_cq_p3_contrast_basis <- function(levels, prefix) {
  levels <- as.integer(levels)[1L]
  mfrmr_cq_p3_assert(is.finite(levels) && levels >= 2L,
                     "A contrast basis requires at least two levels.")
  out <- rbind(diag(levels - 1L), rep(-1, levels - 1L))
  rownames(out) <- paste0(prefix, seq_len(levels))
  colnames(out) <- paste0(prefix, seq_len(levels - 1L))
  out
}

mfrmr_cq_p3_matrix_contract <- function(family, covariates = 0L) {
  family <- toupper(as.character(family)[1L])
  covariates <- as.integer(covariates)[1L]
  mfrmr_cq_p3_assert(
    family %in% c("PCM", "GPCM") && covariates %in% 0:1,
    "The P3 matrix contract requires PCM/GPCM and zero or one covariate."
  )
  rows <- expand.grid(
    ItemIndex = seq_len(4L), Category = 0:3,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  rows <- rows[order(rows$ItemIndex, rows$Category), , drop = FALSE]
  item_basis <- mfrmr_cq_p3_contrast_basis(4L, "I")
  step_basis <- mfrmr_cq_p3_contrast_basis(3L, "S")
  step <- matrix(0, nrow = nrow(rows), ncol = 8L)
  colnames(step) <- unlist(lapply(paste0("I", 1:4), function(item) {
    paste0(item, ":MappedStep:S", 1:2)
  }))
  for (index in seq_len(nrow(rows))) {
    category <- rows$Category[index]
    if (category > 0L) {
      columns <- (2L * rows$ItemIndex[index] - 1L):
        (2L * rows$ItemIndex[index])
      step[index, columns] <-
        -colSums(step_basis[seq_len(category), , drop = FALSE])
    }
  }
  if (family == "PCM") {
    location <- t(vapply(seq_len(nrow(rows)), function(index) {
      -rows$Category[index] * item_basis[rows$ItemIndex[index], ]
    }, numeric(3L)))
    colnames(location) <- paste0("ItemLocation:I", 1:3)
    a_matrix <- cbind(location, step)
    c_matrix <- matrix(rows$Category, ncol = 1L)
    colnames(c_matrix) <- "FixedUnitThetaScore"
    c_free <- 0L
    population_free <- 2L + covariates
    mfrmr_free <- population_free + 3L + 8L
    orientation <- "mfrmr_sumzero_item_location_and_step_coordinates"
  } else {
    offset <- matrix(0, nrow = nrow(rows), ncol = 4L)
    for (index in seq_len(nrow(rows))) {
      offset[index, rows$ItemIndex[index]] <- -rows$Category[index]
    }
    colnames(offset) <- paste0("MappedItemOffset:I", 1:4)
    a_matrix <- cbind(offset, step)
    c_matrix <- matrix(0, nrow = nrow(rows), ncol = 4L)
    for (index in seq_len(nrow(rows))) {
      c_matrix[index, rows$ItemIndex[index]] <- rows$Category[index]
    }
    colnames(c_matrix) <- paste0("MappedTau:I", 1:4)
    c_free <- 4L
    population_free <- covariates
    mfrmr_free <- 2L + covariates + 3L + 3L + 8L
    orientation <- "conquest_fixed_latent_scale_mapped_offset_step_and_tau"
  }
  row_key <- paste0("I", rows$ItemIndex, "::k", rows$Category)
  rownames(a_matrix) <- row_key
  rownames(c_matrix) <- row_key
  list(
    Family = family,
    Covariates = covariates,
    Orientation = orientation,
    RowKey = row_key,
    A = a_matrix,
    C = c_matrix,
    AFreeDimension = ncol(a_matrix),
    CFreeDimension = c_free,
    PopulationOrRegressionFreeDimension = population_free,
    MappedTotalFreeDimension = ncol(a_matrix) + c_free + population_free,
    IndependentlyDerivedMfrmrFreeDimension = mfrmr_free
  )
}

mfrmr_cq_p3_direct_probability <- function(fixture, theta, item) {
  truth <- fixture$Truth
  item <- as.character(item)[1L]
  theta <- as.numeric(theta)[1L]
  mfrmr_cq_p3_assert(
    item %in% names(truth$ItemSlope) && is.finite(theta),
    "The direct P3 probability oracle received an invalid coordinate."
  )
  category <- 0:3
  cumulative <- c(0, cumsum(truth$ItemSteps[item, ]))
  log_kernel <- truth$ItemSlope[item] *
    (category * (theta - truth$ItemLocation[item]) - cumulative)
  mfrmr_cq_gpcm_softmax(log_kernel)
}

mfrmr_cq_p3_mapped_parameters <- function(fixture) {
  truth <- fixture$Truth
  covariates <- as.integer(fixture$PopulationFormula == "~1+X")
  contract <- mfrmr_cq_p3_matrix_contract(fixture$Family, covariates)
  if (fixture$Family == "PCM") {
    a_parameter <- c(
      truth$ItemLocation[1:3],
      as.vector(t(truth$ItemSteps[, 1:2, drop = FALSE]))
    )
    c_parameter <- 1
    regression <- c(
      Intercept = truth$PopulationIntercept,
      if (covariates == 1L) X = truth$PopulationSlope,
      Variance = truth$PopulationVariance
    )
  } else {
    slope <- truth$ItemSlope
    a_parameter <- c(
      slope * (truth$ItemLocation - truth$PopulationIntercept),
      as.vector(t(slope * truth$ItemSteps[, 1:2, drop = FALSE]))
    )
    c_parameter <- sqrt(truth$PopulationVariance) * slope
    regression <- if (covariates == 1L) {
      c(X = truth$PopulationSlope / sqrt(truth$PopulationVariance))
    } else {
      numeric(0)
    }
  }
  names(a_parameter) <- colnames(contract$A)
  names(c_parameter) <- colnames(contract$C)
  list(A = a_parameter, C = c_parameter, Regression = regression)
}

mfrmr_cq_p3_matrix_probability <- function(fixture, theta, item) {
  covariates <- as.integer(fixture$PopulationFormula == "~1+X")
  contract <- mfrmr_cq_p3_matrix_contract(fixture$Family, covariates)
  parameter <- mfrmr_cq_p3_mapped_parameters(fixture)
  selected <- grepl(paste0("^", item, "::"), contract$RowKey)
  mfrmr_cq_p3_assert(sum(selected) == 4L,
                     "The mapped P3 item row key is incomplete.")
  if (fixture$Family == "PCM") {
    latent <- theta
  } else {
    latent <- (theta - fixture$Truth$PopulationIntercept) /
      sqrt(fixture$Truth$PopulationVariance)
  }
  log_kernel <- as.numeric(
    contract$A[selected, , drop = FALSE] %*% parameter$A
  ) + as.numeric(
    contract$C[selected, , drop = FALSE] %*% parameter$C
  ) * latent
  mfrmr_cq_gpcm_softmax(log_kernel)
}

mfrmr_cq_p3_probability_table <- function(
    fixture, theta, representation = c("direct", "mapped"),
    mapped_oracle = NULL) {
  representation <- match.arg(representation)
  item <- paste0("I", 1:4)
  if (representation == "direct") {
    out <- t(vapply(item, function(value) {
      mfrmr_cq_p3_direct_probability(fixture, theta, value)
    }, numeric(4L)))
  } else {
    if (is.null(mapped_oracle)) {
      covariates <- as.integer(fixture$PopulationFormula == "~1+X")
      mapped_oracle <- list(
        Contract = mfrmr_cq_p3_matrix_contract(fixture$Family, covariates),
        Parameter = mfrmr_cq_p3_mapped_parameters(fixture)
      )
    }
    contract <- mapped_oracle$Contract
    parameter <- mapped_oracle$Parameter
    latent <- if (fixture$Family == "PCM") {
      theta
    } else {
      (theta - fixture$Truth$PopulationIntercept) /
        sqrt(fixture$Truth$PopulationVariance)
    }
    log_kernel <- as.numeric(contract$A %*% parameter$A) +
      as.numeric(contract$C %*% parameter$C) * latent
    out <- t(vapply(split(log_kernel, rep(item, each = 4L)),
                    mfrmr_cq_gpcm_softmax, numeric(4L)))
  }
  rownames(out) <- item
  colnames(out) <- paste0("k", 0:3)
  out
}

mfrmr_cq_p3_probability_audit <- function() {
  fixtures <- mfrmr_cq_p3_fixture_registry()
  theta <- c(-2.50, -0.75, 0, 0.90, 2.70)
  rows <- list()
  position <- 1L
  for (fixture in fixtures) {
    for (value in theta) {
      for (item in paste0("I", 1:4)) {
        direct <- mfrmr_cq_p3_direct_probability(fixture, value, item)
        mapped <- mfrmr_cq_p3_matrix_probability(fixture, value, item)
        rows[[position]] <- data.frame(
          RegistryRowId = fixture$RegistryRowId,
          Theta = value,
          Item = item,
          Category = 0:3,
          DirectProbability = direct,
          MappedProbability = mapped,
          Difference = direct - mapped,
          stringsAsFactors = FALSE
        )
        position <- position + 1L
      }
    }
  }
  detail <- do.call(rbind, rows)
  rownames(detail) <- NULL
  list(
    Cases = nrow(detail),
    MaxAbsProbabilityDifference = max(abs(detail$Difference)),
    Detail = detail
  )
}

mfrmr_cq_p3_pcm_reduction_audit <- function() {
  pcm <- mfrmr_cq_p3_fixture("P3-PCM-UNIT-SLOPE-INTERCEPT")
  reduced <- pcm
  reduced$Family <- "GPCM"
  reduced$Truth$ItemSlope[] <- 1
  theta <- c(-2.50, -0.75, 0, 0.90, 2.70)
  difference <- unlist(lapply(theta, function(value) {
    unlist(lapply(paste0("I", 1:4), function(item) {
      mfrmr_cq_p3_direct_probability(pcm, value, item) -
        mfrmr_cq_p3_direct_probability(reduced, value, item)
    }))
  }))
  list(
    Cases = length(difference),
    MaxAbsProbabilityDifference = max(abs(difference))
  )
}

mfrmr_cq_p3_gh_normal <- function(nodes) {
  nodes <- as.integer(nodes)[1L]
  mfrmr_cq_p3_assert(is.finite(nodes) && nodes >= 1L,
                     "Gauss-Hermite nodes must be one positive integer.")
  if (nodes == 1L) return(list(nodes = 0, weights = 1))
  index <- seq_len(nodes - 1L)
  jacobi <- matrix(0, nrow = nodes, ncol = nodes)
  off_diagonal <- sqrt(index / 2)
  jacobi[cbind(index, index + 1L)] <- off_diagonal
  jacobi[cbind(index + 1L, index)] <- off_diagonal
  eig <- eigen(jacobi, symmetric = TRUE)
  order <- order(eig$values)
  list(
    nodes = sqrt(2) * eig$values[order],
    weights = eig$vectors[1L, order]^2
  )
}

mfrmr_cq_p3_person_probability <- function(
    fixture, person_data, residual, representation = c("direct", "mapped"),
    mapped_oracle = NULL) {
  representation <- match.arg(representation)
  truth <- fixture$Truth
  x <- unique(person_data$X)
  mfrmr_cq_p3_assert(length(x) == 1L, "Person X changed within P3 rows.")
  sigma <- sqrt(truth$PopulationVariance)
  theta <- truth$PopulationIntercept + truth$PopulationSlope * x +
    sigma * residual
  table <- mfrmr_cq_p3_probability_table(
    fixture, theta, representation, mapped_oracle
  )
  probability <- table[cbind(
    match(person_data$Item, rownames(table)),
    person_data$Response + 1L
  )]
  exp(sum(log(probability)))
}

mfrmr_cq_p3_finite_loglikelihood <- function(fixture, nodes) {
  quadrature <- mfrmr_cq_p3_gh_normal(nodes)
  by_person <- split(fixture$Data, fixture$Data$Person)
  covariates <- as.integer(fixture$PopulationFormula == "~1+X")
  mapped_oracle <- list(
    Contract = mfrmr_cq_p3_matrix_contract(fixture$Family, covariates),
    Parameter = mfrmr_cq_p3_mapped_parameters(fixture)
  )
  contribution <- lapply(by_person, function(person_data) {
    direct <- vapply(quadrature$nodes, function(residual) {
      mfrmr_cq_p3_person_probability(
        fixture, person_data, residual, "direct"
      )
    }, numeric(1L))
    mapped <- vapply(quadrature$nodes, function(residual) {
      mfrmr_cq_p3_person_probability(
        fixture, person_data, residual, "mapped", mapped_oracle
      )
    }, numeric(1L))
    c(
      Direct = sum(quadrature$weights * direct),
      Mapped = sum(quadrature$weights * mapped)
    )
  })
  contribution <- do.call(rbind, contribution)
  mfrmr_cq_p3_assert(
    all(is.finite(contribution)) && all(contribution > 0),
    "A P3 finite-ladder marginal contribution is nonfinite."
  )
  data.frame(
    RegistryRowId = fixture$RegistryRowId,
    Nodes = as.integer(nodes),
    DirectLogLikelihood = sum(log(contribution[, "Direct"])),
    MappedLogLikelihood = sum(log(contribution[, "Mapped"])),
    DirectMinusMapped = sum(log(contribution[, "Direct"])) -
      sum(log(contribution[, "Mapped"])),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p3_continuous_loglikelihood <- function(
    fixture, relative_tolerance = 1e-10) {
  by_person <- split(fixture$Data, fixture$Data$Person)
  covariates <- as.integer(fixture$PopulationFormula == "~1+X")
  mapped_oracle <- list(
    Contract = mfrmr_cq_p3_matrix_contract(fixture$Family, covariates),
    Parameter = mfrmr_cq_p3_mapped_parameters(fixture)
  )
  contribution <- lapply(by_person, function(person_data) {
    integrate_one <- function(representation) {
      integrand <- function(residual) vapply(residual, function(value) {
        mfrmr_cq_p3_person_probability(
          fixture, person_data, value, representation,
          if (representation == "mapped") mapped_oracle else NULL
        ) * stats::dnorm(value)
      }, numeric(1L))
      stats::integrate(
        integrand, lower = -Inf, upper = Inf,
        rel.tol = relative_tolerance, subdivisions = 250L,
        stop.on.error = TRUE
      )
    }
    direct <- integrate_one("direct")
    mapped <- integrate_one("mapped")
    c(
      Direct = direct$value,
      Mapped = mapped$value,
      ErrorEstimate = direct$abs.error + mapped$abs.error
    )
  })
  contribution <- do.call(rbind, contribution)
  mfrmr_cq_p3_assert(
    all(is.finite(contribution)) &&
      all(contribution[, c("Direct", "Mapped")] > 0),
    "A P3 continuous-target marginal contribution is nonfinite."
  )
  data.frame(
    RegistryRowId = fixture$RegistryRowId,
    Persons = nrow(contribution),
    DirectLogLikelihood = sum(log(contribution[, "Direct"])),
    MappedLogLikelihood = sum(log(contribution[, "Mapped"])),
    DirectMinusMapped = sum(log(contribution[, "Direct"])) -
      sum(log(contribution[, "Mapped"])),
    IntegrationAbsoluteErrorEstimate = sum(
      contribution[, "ErrorEstimate"]
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p3_likelihood_audit <- function(
    fixture, run_continuous = FALSE) {
  finite <- do.call(rbind, lapply(
    c(31L, 61L, 121L),
    function(nodes) mfrmr_cq_p3_finite_loglikelihood(fixture, nodes)
  ))
  continuous <- if (isTRUE(run_continuous)) {
    mfrmr_cq_p3_continuous_loglikelihood(fixture)
  } else {
    data.frame()
  }
  list(
    RegistryRowId = fixture$RegistryRowId,
    Finite = finite,
    Continuous = continuous,
    MaxAbsFiniteMapDifference = max(abs(finite$DirectMinusMapped)),
    Q61MinusQ31 = finite$DirectLogLikelihood[finite$Nodes == 61L] -
      finite$DirectLogLikelihood[finite$Nodes == 31L],
    Q121MinusQ61 = finite$DirectLogLikelihood[finite$Nodes == 121L] -
      finite$DirectLogLikelihood[finite$Nodes == 61L],
    ContinuousChecked = isTRUE(run_continuous),
    ExternalExecutionAuthorized = FALSE,
    ComparisonPassed = FALSE
  )
}

mfrmr_cq_p3_review <- function(run_continuous_oracles = FALSE) {
  fixtures <- mfrmr_cq_p3_fixture_registry()
  fixture_audits <- lapply(fixtures, mfrmr_cq_p3_fixture_audit)
  matrix <- list(
    PCM = mfrmr_cq_p3_matrix_contract("PCM", 0L),
    GPCMIntercept = mfrmr_cq_p3_matrix_contract("GPCM", 0L),
    GPCMCovariate = mfrmr_cq_p3_matrix_contract("GPCM", 1L)
  )
  probability <- mfrmr_cq_p3_probability_audit()
  reduction <- mfrmr_cq_p3_pcm_reduction_audit()
  likelihood <- lapply(
    fixtures, mfrmr_cq_p3_likelihood_audit,
    run_continuous = run_continuous_oracles
  )
  support <- lapply(fixture_audits, `[[`, "Support")
  support_ready <- all(vapply(support, function(count) {
    identical(dim(count), c(4L, 4L)) && all(count > 0L)
  }, logical(1L)))
  fixture_semantics_ready <- all(vapply(
    fixture_audits, `[[`, logical(1L), "Ready"
  ))
  dimensions_ready <-
    matrix$PCM$MappedTotalFreeDimension == 13L &&
    matrix$PCM$IndependentlyDerivedMfrmrFreeDimension == 13L &&
    matrix$GPCMIntercept$MappedTotalFreeDimension == 16L &&
    matrix$GPCMIntercept$IndependentlyDerivedMfrmrFreeDimension == 16L &&
    matrix$GPCMCovariate$MappedTotalFreeDimension == 17L &&
    matrix$GPCMCovariate$IndependentlyDerivedMfrmrFreeDimension == 17L
  finite_ready <- all(vapply(likelihood, function(result) {
    nrow(result$Finite) == 3L &&
      identical(result$Finite$Nodes, c(31L, 61L, 121L)) &&
      result$MaxAbsFiniteMapDifference < 1e-12
  }, logical(1L)))
  continuous_ready <- isTRUE(run_continuous_oracles) &&
    all(vapply(likelihood, function(result) {
      nrow(result$Continuous) == 1L &&
        result$Continuous$Persons == 96L &&
        is.finite(result$Continuous$DirectLogLikelihood) &&
        abs(result$Continuous$DirectMinusMapped) < 1e-10
    }, logical(1L)))
  fixture_ready <- length(fixtures) == 3L && fixture_semantics_ready &&
    !anyDuplicated(vapply(fixtures, `[[`, character(1L), "ArmIdentity")) &&
    support_ready && dimensions_ready &&
    probability$MaxAbsProbabilityDifference < 1e-14 &&
    reduction$MaxAbsProbabilityDifference < 1e-14 && finite_ready
  ready <- fixture_ready && continuous_ready
  list(
    specification = mfrmr_cq_p3_specification,
    contract_version = mfrmr_cq_p3_contract,
    fixture_set_id = mfrmr_cq_p3_fixture_set_id,
    prospective_execution_identity = mfrmr_cq_p3_execution_identity,
    status = if (ready) {
      "P3_item_only_fixtures_A_C_and_likelihood_oracles_ready_for_metric_freeze"
    } else if (fixture_ready && !isTRUE(run_continuous_oracles)) {
      "P3_item_only_fixture_and_finite_ladder_ready_continuous_oracles_not_run"
    } else {
      "P3_item_only_fixture_or_oracle_contract_failed"
    },
    fixtures = fixtures,
    fixture_audits = fixture_audits,
    matrix_contracts = matrix,
    support = support,
    probability_audit = probability,
    pcm_reduction_audit = reduction,
    likelihood_audits = likelihood,
    fixture_semantics_ready = fixture_semantics_ready,
    fixture_and_matrix_ready = fixture_ready,
    finite_integration_ladder_ready = finite_ready,
    continuous_oracle_ready = continuous_ready,
    metric_specific_rules_frozen = FALSE,
    independent_review_passed = FALSE,
    external_execution_authorized = FALSE,
    comparison_passed = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
