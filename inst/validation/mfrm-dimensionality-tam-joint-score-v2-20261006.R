# Research-only prediction from a saved, fixed-normal TAM calibration.
# Joint probabilities integrate a Person's observed responses together.
# An order comparison/reference check is required before using these scores.
wide_dim_tam_joint_score_v2 <- function(value, response, order = 61L) {
  if (is.null(value$fit) || !identical(value$status, 'returned')) {
    return(list(status = 'fit_unavailable', fit_status = value$status,
                response = response, persons = NULL, summary = NULL))
  }
  fit <- value$fit
  d <- dim(fit$B)[3L]
  stopifnot(is.matrix(response), nrow(response) > 0L, ncol(response) == 18L,
    !is.null(rownames(response)), !anyDuplicated(rownames(response)),
    identical(colnames(response), dimnames(fit$A)[[1L]]),
    all(is.na(response) | response %in% 0:3),
    length(order) == 1L, order %in% c(61L, 121L, 241L),
    d %in% 1:2, identical(dim(fit$B)[1:2], c(18L, 4L)),
    all(is.finite(fit$xsi$xsi)), all(fit$beta == 0),
    identical(unname(fit$variance), diag(d)))
  gh <- mfrmr:::gauss_hermite_normal(order)
  if (d == 1L) {
    theta <- matrix(gh$nodes, ncol = 1L)
    log_weights <- log(gh$weights)
  } else {
    index <- expand.grid(a = seq_len(order), b = seq_len(order))
    theta <- cbind(gh$nodes[index$a], gh$nodes[index$b])
    log_weights <- log(gh$weights[index$a]) + log(gh$weights[index$b])
  }
  weight_maximum <- max(log_weights)
  log_weight_sum <- weight_maximum + log(sum(exp(log_weights - weight_maximum)))
  weight_sum <- exp(log_weight_sum)
  stopifnot(all(is.finite(theta)), all(is.finite(log_weights)),
            abs(expm1(log_weight_sum)) < 1e-12)
  # Product GH weights can underflow even when the univariate weights do not.
  # Keep them in log space; normalize only the constant's floating roundoff.
  log_weights <- log_weights - log_weight_sum
  intercept <- matrix(matrix(fit$A, ncol = nrow(fit$xsi)) %*% fit$xsi$xsi, 18L, 4L)
  joint <- matrix(0, nrow(response), nrow(theta))
  for (item in seq_len(18L)) {
    logits <- matrix(fit$B[item, , ], 4L, d) %*% t(theta) + intercept[item, ]
    logits <- sweep(logits, 2L, apply(logits, 2L, max), '-')
    log_probability <- sweep(logits, 2L, log(colSums(exp(logits))), '-')
    use <- which(!is.na(response[, item]))
    joint[use, ] <- joint[use, , drop = FALSE] +
      log_probability[response[use, item] + 1L, , drop = FALSE]
  }
  weighted <- sweep(joint, 2L, log_weights, '+')
  maximum <- apply(weighted, 1L, max)
  score <- maximum + log(rowSums(exp(weighted - maximum)))
  n_observed <- rowSums(!is.na(response))
  score[n_observed == 0L] <- 0
  stopifnot(all(is.finite(score)), all(score <= 1e-12))
  usable <- n_observed > 0L
  persons <- data.frame(Person = rownames(response), NObserved = n_observed,
    LogProbability = score, Included = usable, row.names = NULL)
  list(status = if (any(usable)) 'computed' else 'no_observed_responses',
    fit_status = value$status, response = response, persons = persons,
    summary = list(PlannedPersons = nrow(response), ScoredPersons = sum(usable),
      AllMissingPersons = sum(!usable), ObservedRatings = sum(n_observed),
      MeanPersonLogScore = if (any(usable)) mean(score[usable]) else NA_real_,
      JointLogScorePerRating = if (any(usable)) sum(score[usable]) / sum(n_observed) else NA_real_),
    order = order, effective_dimensions = d, weight_sum_before_normalization = weight_sum,
    scope = 'Fixed-calibration joint prediction. Numerical integration, fit qualification and any model-selection rule require separate checks.')
}

wide_dim_tam_joint_difference_v2 <- function(first, second) {
  stopifnot(identical(first$response, second$response))
  if (!identical(first$status, 'computed') || !identical(second$status, 'computed')) {
    return(list(status = 'score_unavailable', first_status = first$status,
                second_status = second$status))
  }
  a <- first$persons; b <- second$persons
  stopifnot(identical(a$Person, b$Person), identical(a$NObserved, b$NObserved),
            identical(a$Included, b$Included))
  use <- a$Included
  difference <- a$LogProbability[use] - b$LogProbability[use]
  list(status = 'computed', Persons = a$Person[use], ScoredPersons = sum(use),
    AllMissingPersons = sum(!use), Difference = difference,
    MeanPersonDifference = mean(difference),
    JointDifferencePerRating = sum(difference) / sum(a$NObserved))
}
