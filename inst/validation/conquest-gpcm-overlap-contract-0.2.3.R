# Repository-only ConQuest/mfrmr bounded-GPCM overlap contract.
#
# This file derives coordinates and conditional probabilities. It never
# launches ConQuest, reads local external output, sets a comparison tolerance,
# or promotes an external-equivalence claim.

mfrmr_cq_gpcm_contract_version <-
  "mfrmr_conquest_gpcm_item_latent_regression_overlap_v1"

mfrmr_cq_gpcm_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_gpcm_softmax <- function(log_kernel) {
  value <- as.numeric(log_kernel)
  value <- value - max(value)
  probability <- exp(value)
  probability / sum(probability)
}

mfrmr_cq_gpcm_transform <- function(beta0, beta, sigma2, slopes,
                                     item_locations, steps,
                                     tolerance = 1e-10) {
  beta_names <- names(beta)
  owner <- names(slopes)
  beta0 <- as.numeric(beta0)
  beta <- as.numeric(beta)
  sigma2 <- as.numeric(sigma2)
  slopes <- as.numeric(slopes)
  item_locations <- as.numeric(item_locations)
  steps <- as.matrix(steps)
  tolerance <- as.numeric(tolerance)

  mfrmr_cq_gpcm_assert(
    length(beta0) == 1L && is.finite(beta0),
    "beta0 must be one finite value."
  )
  mfrmr_cq_gpcm_assert(
    length(sigma2) == 1L && is.finite(sigma2) && sigma2 > 0,
    "sigma2 must be one positive finite value."
  )
  mfrmr_cq_gpcm_assert(
    length(tolerance) == 1L && is.finite(tolerance) && tolerance > 0,
    "tolerance must be one positive finite value."
  )
  mfrmr_cq_gpcm_assert(
    length(slopes) > 0L && all(is.finite(slopes)) && all(slopes > 0),
    "slopes must contain positive finite values."
  )
  mfrmr_cq_gpcm_assert(
    length(item_locations) == length(slopes) &&
      all(is.finite(item_locations)),
    "item_locations must contain one finite value per slope."
  )
  mfrmr_cq_gpcm_assert(
    nrow(steps) == length(slopes) && ncol(steps) > 0L &&
      all(is.finite(steps)),
    "steps must be a finite matrix with one row per slope."
  )
  mfrmr_cq_gpcm_assert(
    abs(mean(log(slopes))) <= tolerance,
    "mfrmr slopes must satisfy the geometric-mean-one contract."
  )
  mfrmr_cq_gpcm_assert(
    max(abs(rowSums(steps))) <= tolerance,
    "Each mfrmr step row must satisfy its sum-zero contract."
  )

  if (is.null(owner) || any(!nzchar(owner)) || anyDuplicated(owner)) {
    owner <- paste0("Owner", seq_along(slopes))
  }
  if (!is.null(beta_names) && length(beta_names) == length(beta)) {
    names(beta) <- beta_names
  }
  names(slopes) <- owner
  names(item_locations) <- owner
  rownames(steps) <- owner
  sigma <- sqrt(sigma2)

  list(
    ContractVersion = mfrmr_cq_gpcm_contract_version,
    Mfrmr = list(
      Beta0 = beta0,
      Beta = beta,
      Sigma2 = sigma2,
      Sigma = sigma,
      Slopes = slopes,
      ItemLocations = item_locations,
      Steps = steps
    ),
    ConQuest = list(
      LatentMeanIntercept = 0,
      Regression = beta / sigma,
      LatentVariance = 1,
      Tau = sigma * slopes,
      ItemLocations = slopes * (item_locations - beta0),
      Steps = steps * slopes
    ),
    Map = c(
      latent = "z=(theta-beta0)/sigma",
      regression = "beta_CQ=beta_mfrmr/sigma",
      score = "Tau_CQ=sigma*a_mfrmr",
      item = "delta_CQ=a_mfrmr*(delta_mfrmr-beta0)",
      step = "step_CQ=a_mfrmr*step_mfrmr"
    )
  )
}

mfrmr_cq_gpcm_probability_audit <- function(contract, theta) {
  mfrmr_cq_gpcm_assert(
    is.list(contract) && all(c("Mfrmr", "ConQuest") %in% names(contract)),
    "contract must be returned by mfrmr_cq_gpcm_transform()."
  )
  theta <- as.numeric(theta)
  mfrmr_cq_gpcm_assert(
    length(theta) > 0L && all(is.finite(theta)),
    "theta must contain finite values."
  )
  m <- contract$Mfrmr
  cq <- contract$ConQuest
  owner <- names(m$Slopes)
  categories <- 0:ncol(m$Steps)

  rows <- vector("list", length(owner) * length(theta))
  position <- 1L
  for (level in owner) {
    cumulative_m <- c(0, cumsum(m$Steps[level, ]))
    cumulative_cq <- c(0, cumsum(cq$Steps[level, ]))
    for (theta_value in theta) {
      z <- (theta_value - m$Beta0) / m$Sigma
      log_m <- m$Slopes[level] *
        (categories * (theta_value - m$ItemLocations[level]) - cumulative_m)
      log_cq <- categories * cq$Tau[level] * z -
        categories * cq$ItemLocations[level] - cumulative_cq
      p_m <- mfrmr_cq_gpcm_softmax(log_m)
      p_cq <- mfrmr_cq_gpcm_softmax(log_cq)
      rows[[position]] <- data.frame(
        Owner = level,
        Theta = theta_value,
        Category = categories,
        MfrmrProbability = p_m,
        ConQuestProbability = p_cq,
        Difference = p_m - p_cq,
        stringsAsFactors = FALSE
      )
      position <- position + 1L
    }
  }
  detail <- do.call(rbind, rows)
  rownames(detail) <- NULL
  list(
    ContractVersion = mfrmr_cq_gpcm_contract_version,
    MaxAbsProbabilityDifference = max(abs(detail$Difference)),
    TauGeometricMean = exp(mean(log(cq$Tau))),
    MfrmrSigma = m$Sigma,
    Detail = detail
  )
}

mfrmr_cq_gpcm_control <- function(prefix, first_response, last_response,
                                   nodes = 31L,
                                   estimator = "MML") {
  prefix <- trimws(as.character(prefix)[1L])
  first_response <- trimws(as.character(first_response)[1L])
  last_response <- trimws(as.character(last_response)[1L])
  nodes <- suppressWarnings(as.integer(nodes[1L]))
  estimator <- toupper(trimws(as.character(estimator)[1L]))
  mfrmr_cq_gpcm_assert(
    all(nzchar(c(prefix, first_response, last_response))),
    "prefix and response labels must be non-empty."
  )
  mfrmr_cq_gpcm_assert(
    length(nodes) == 1L && is.finite(nodes) && nodes > 0L,
    "nodes must be one positive integer."
  )
  mfrmr_cq_gpcm_assert(
    identical(estimator, "MML"),
    paste(
      "ConQuest 5.47.5 cannot estimate item scores under JML;",
      "this contract generates MML controls only."
    )
  )
  c(
    paste0("export logfile >> ", prefix, "_conquest_internal.log;"),
    paste0(
      "datafile ", prefix,
      "_wide.csv ! filetype=csv, columnlabels=yes, pid=Person, ",
      "pidwidth=32, responses=", first_response, " to ", last_response,
      ", keeps=X, keepswidth=32;"
    ),
    "codes 0,1,2,3;",
    "set lconstraints=cases, sconstraint=cases;",
    "regression X;",
    "model item + item*step!scoresfree;",
    paste0(
      "estimate ! method=quadrature, nodes=", nodes,
      ", fit=no, stderr=quick, matrixout=mfrmrCQ, ",
      "convergence=0.00000001, deviancechange=0.0000000001, ",
      "iterations=2000;"
    ),
    paste0("export parameters ! filetype=csv >> ", prefix,
           "_conquest_parameters.csv;"),
    paste0("export reg_coefficients ! filetype=csv >> ", prefix,
           "_conquest_reg_coefficients.csv;"),
    paste0("export covariance ! filetype=csv >> ", prefix,
           "_conquest_covariance.csv;"),
    paste0("export tau ! filetype=csv >> ", prefix,
           "_conquest_tau.csv;"),
    paste0("export itemscores ! filetype=csv >> ", prefix,
           "_conquest_itemscores.csv;"),
    paste0("export cmatrix ! filetype=csv >> ", prefix,
           "_conquest_cmatrix.csv;"),
    paste0("export amatrix ! filetype=csv >> ", prefix,
           "_conquest_amatrix.csv;"),
    paste0("write mfrmrCQ_history ! filetype=csv >> ", prefix,
           "_conquest_history.csv;"),
    "quit;"
  )
}
