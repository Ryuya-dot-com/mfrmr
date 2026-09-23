# The ordinary reference deliberately shares the predictive target, not the
# plug-in diagnostics returned by diagnose_mfrm(). No fitting takes place.
mfrm_ordinary_response_input <- function(fit) {
  cfg <- fit$config; prep <- fit$prep
  if (!inherits(fit, "mfrm_fit") || inherits(fit, "mfrm_imported_fit") ||
      !identical(cfg$model, "RSM") || !identical(cfg$method, "MML")) stop(
    "Ordinary posterior predictive residuals require a native RSM MML fit.", call. = FALSE)
  if (!identical(as.character(fit$summary$NumericalState), "ready") ||
      !isTRUE(mfrm_convergence_state(fit)$code_converged) ||
      identical(fit$readiness$fit$FitReadiness, "blocked")) stop(
    "Resolve the ordinary fit's numerical and blocked source checks before response diagnostics.", call. = FALSE)
  columns <- prep$source_columns %||% cfg$source_columns
  facets <- columns$facets; anchors <- extract_anchor_tables(cfg)
  if (is.null(columns$person) || is.null(columns$score) ||
      length(cfg$facet_interactions) || nrow(as.data.frame(anchors$anchors)) ||
      nrow(as.data.frame(anchors$groups)) || length(cfg$dummy_facets) ||
      !identical(cfg$noncenter_facet, "Person") ||
      !identical(cfg$facet_shrinkage %||% "none", "none") ||
      length(cfg$facet_signs[facets]) != length(facets) ||
      anyNA(cfg$facet_signs[facets]) || any(cfg$facet_signs[facets] != -1) ||
      !is.data.frame(prep$data) || !all(is.finite(prep$data$Weight) & prep$data$Weight == 1)) stop(
    "Use unit weights, additive unanchored severity facets, Person as the noncentered facet, and no shrinkage or interactions.", call. = FALSE)
  pop <- fit$population %||% cfg$population_spec
  estimated <- isTRUE(pop$active)
  if (estimated && (!identical(pop$design_columns, "(Intercept)") ||
      !is.matrix(cfg$population_spec$design_matrix) || ncol(cfg$population_spec$design_matrix) != 1L ||
      anyNA(cfg$population_spec$design_matrix) || any(cfg$population_spec$design_matrix != 1))) stop(
    "Use an intercept-only normal population or the known N(0,1) default; latent regressions are not supported by this response-diagnostic route.", call. = FALSE)
  if (isTRUE((pop$response_rows_omitted %||% 0) > 0)) stop("Population-data omissions are not supported by this response-diagnostic route.", call. = FALSE)
  mu <- if (estimated) as.numeric(pop$coefficients) else 0
  variance <- if (estimated) pop$sigma2 else 1
  if (length(mu) != 1L || !is.finite(mu) || length(variance) != 1L ||
      !is.finite(variance) || variance < 0) stop("The fitted normal population is unavailable.", call. = FALSE)
  map <- prep$score_map
  if (!is.data.frame(map) || !all(c("OriginalScore", "InternalScore") %in% names(map))) stop("The saved fit lacks its category mapping.", call. = FALSE)
  map <- map[order(map$InternalScore), , drop = FALSE]; categories <- as.numeric(map$OriginalScore)
  if (length(categories) < 2L || any(!is.finite(categories)) || any(categories != floor(categories)) ||
      any(diff(categories) != 1) || any(diff(map$InternalScore) != 1) ||
      anyNA(prep$data$score_k) || !all(prep$data$score_k == match(prep$data$Score, map$InternalScore) - 1L)) stop(
    "Retain consecutive integer source categories and their adjacent-category mapping.", call. = FALSE)
  steps <- fit$steps$Estimate
  offset <- rep(0, nrow(prep$data))
  for (f in facets) {
    tab <- fit$facets$others[fit$facets$others$Facet == f, , drop = FALSE]
    if (anyDuplicated(tab$Level)) stop("Fixed-facet levels are duplicated.", call. = FALSE)
    at <- match(as.character(prep$data[[f]]), as.character(tab$Level))
    if ("ParameterStatus" %in% names(tab) && anyNA(match(tab$ParameterStatus[at], c("estimable", "fixed", "weak_information")))) stop("A fixed facet has unavailable parameter status.", call. = FALSE)
    offset <- offset + tab$Estimate[at]
  }
  if (length(steps) != length(categories) - 1L || any(!is.finite(steps)) || any(!is.finite(offset))) stop("Finite fixed-facet and step estimates are required.", call. = FALSE)
  data <- as.data.frame(prep$data[c("Person", facets, "Score")])
  names(data) <- c(columns$person, facets, columns$score)
  data[[columns$score]] <- categories[match(prep$data$Score, map$InternalScore)]
  data[setdiff(names(data), columns$score)] <- lapply(data[setdiff(names(data), columns$score)], as.character)
  rownames(data) <- NULL
  n <- prep$row_retention$Rows[match("input_selected_columns", prep$row_retention$Stage)]
  if (length(n) != 1L || !is.finite(n) || n < nrow(data)) stop("Original input-row accounting is unavailable.", call. = FALSE)
  omitted <- prep$omitted_data; positions <- prep$omitted_input_rows
  source <- data[rep(NA_integer_, n), , drop = FALSE]; rownames(source) <- NULL
  if (n > nrow(data)) {
    if (!is.data.frame(omitted) || nrow(omitted) != n - nrow(data) ||
        length(positions) != nrow(omitted) || anyNA(positions) || anyDuplicated(positions) ||
        any(positions != floor(positions) | positions < 1 | positions > n)) stop(
      "The older fit lacks omitted input-row identities; refit from the complete assigned-score roster.", call. = FALSE)
    if (anyNA(omitted[c("Person", facets)]) || any(!is.na(omitted$Score)) ||
        anyNA(omitted$Weight) || any(omitted$Weight != 1)) stop(
      "Only missing assigned scores are supported; omitted identifiers or excluded weights need a different data review.", call. = FALSE)
    missing_data <- omitted[c("Person", facets, "Score")]; names(missing_data) <- names(data)
    missing_data[setdiff(names(data), columns$score)] <- lapply(missing_data[setdiff(names(data), columns$score)], as.character)
    source[positions, ] <- missing_data
  } else positions <- integer()
  source[setdiff(seq_len(n), positions), ] <- data
  list(data = data, assigned_data = source, input_rows = n, omitted_rows = positions,
    columns = columns, score_levels = categories, y = prep$data$score_k,
    person = as.character(data[[columns$person]]), offset = offset, steps = steps,
    mean = mu, sd = sqrt(variance))
}

mfrm_ordinary_response_probabilities <- function(input, rows, order) {
  rule <- gauss_hermite_normal(order); theta <- input$mean + input$sd * rule$nodes
  indices <- which(input$person == input$person[rows[1L]])
  logp <- lapply(indices, function(i) {
    logw <- outer(theta - input$offset[i], 0:length(input$steps)) -
      matrix(c(0, cumsum(input$steps)), length(theta), length(input$steps) + 1L, byrow = TRUE)
    logw - mfrm_testlet_logsum_rows(logw)
  })
  logw <- log(rule$weights) + Reduce(`+`, lapply(seq_along(indices), function(j) logp[[j]][, input$y[indices[j]] + 1L]))
  posterior <- exp(logw - max(logw)); posterior <- posterior / sum(posterior)
  result <- t(vapply(rows, function(i) colSums(exp(logp[[match(i, indices)]]) * posterior), numeric(length(input$score_levels))))
  list(probabilities = result, normalization_error = rowSums(result) - 1)
}

mfrm_response_source <- function(fit) {
  if (mfrm_extended_fit(fit)) return(mfrm_extended_prediction_source(fit))
  list(class = class(fit), config = fit$config[setdiff(names(fit$config), "attached_diagnostics")],
    facets = fit$facets$others, steps = fit$steps, population = fit$population,
    readiness = fit$readiness, summary = fit$summary, convergence = fit$opt$convergence)
}

mfrm_validate_response_diagnostics <- function(fit, diagnostics) {
  input <- if (mfrm_extended_fit(fit)) fit$input else mfrm_ordinary_response_input(fit)
  if (!inherits(diagnostics, "mfrm_response_diagnostics") ||
      !identical(diagnostics$source, mfrm_response_source(fit)) ||
      !identical(diagnostics$source_data, input$assigned_data %||% input$data) ||
      !identical(diagnostics$source_observed, input$data)) stop(
    "Supply mfrm_response_diagnostics() output with matching calibration and the exact source roster.", call. = FALSE)
  invisible(TRUE)
}

mfrm_response_diagnostic_tables <- function(diagnostics) {
  p <- diagnostics$probabilities
  list(response_residuals = diagnostics$rows,
    response_measures = diagnostics$measures,
    response_probabilities = data.frame(
      InputRow = rep(diagnostics$rows$InputRow, ncol(p)),
      Score = rep(as.numeric(colnames(p)), each = nrow(p)), Probability = as.vector(p)),
    response_diagnostic_settings = mfrm_extended_settings_table(diagnostics$settings))
}
