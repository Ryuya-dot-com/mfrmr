#' Multivariate G-study for a complete crossed rating design
#'
#' Estimate observed-score variance-covariance components for fixed score
#' components measured on every Person-by-Rater-by-Task combination. Raters
#' and tasks are random, crossed conditions, shared across score components.
#' This is a balanced multivariate ANOVA estimator, not an MFRM fit.
#'
#' @param data A data frame with exactly one row per Person/Rater/Task cell.
#' @param scores Names of finite numeric score columns, in the desired order.
#'   A single column is allowed as the univariate special case. Scores are
#'   neither standardized nor converted from category labels.
#' @param person,rater,task Distinct columns identifying the three crossed
#'   factors. Each must have at least two observed levels. Labels may be
#'   character, factor, finite numeric, or logical; missing/blank labels fail.
#'
#' @details All cells and all selected scores must be observed. Duplicates,
#'   incomplete designs, missing scores, and nested/local facet identifiers
#'   are not supported. The same identifier must denote the same rater or task
#'   across all persons and scores. Equal level counts alone cannot establish
#'   that substantive identity or random sampling from the intended universe.
#'
#'   The seven components are `Person`, `Rater`, `Task`, `Person:Rater`,
#'   `Person:Task`, `Rater:Task`, and `Residual`. With one observation per cell,
#'   `Residual` combines the three-way interaction and within-cell error;
#'   they cannot be separated. Each component is a matrix whose diagonal
#'   contains variances and whose off-diagonal contains covariances between
#'   scores. ANOVA mean products replace the mean squares used for a single
#'   score. This method does not optimize a likelihood or impose a
#'   positive-semidefinite constraint on estimates.
#'
#'   Raw component estimates, including negative variances and indefinite
#'   matrices, are retained without clipping or nearest-PSD repair. The
#'   `component_diagnostics` assess eigenvalues after scaling by the observed
#'   score SDs, using a relative numerical tolerance. This is a numerical
#'   admissibility check, not a significance test or precision assessment.
#'   Rank-deficient components are reported. If any component is materially
#'   non-PSD, [mfrm_multivariate_d_study()] retains raw projected variances but
#'   withholds all coefficients and SEMs.
#'
#'   The model concerns numeric observed scores. Treating ordered categories
#'   as numeric does not estimate latent ordinal or MFRM reliability. The
#'   initial reference verification covers balanced continuous-score
#'   calculations; ordinal, sparse, and missing-data recovery and sampling
#'   intervals are not established by that verification. No missing values
#'   are imputed, and no variance-component uncertainty is propagated.
#'
#' @return An `mfrm_multivariate_gstudy` list with `components` (the seven
#'   named covariance matrices), `mean_products`, `degrees_of_freedom`,
#'   `component_diagnostics`, `score_scale` (observed SDs used only for matrix
#'   diagnostics), `design` (column identities, levels, counts, method, and
#'   score convention), and `data` (the selected input columns).
#' @references Brennan, R. L. (2001). *Generalizability theory*. Springer.
#'   Chapters 9--11.
#'   Brennan, R. L. (2001). *Manual for mGENOVA, Version 2.1*.
#'   Iowa Testing Programs Occasional Papers, No. 50. Pages 7--8 and 19--22.
#' @seealso [mfrm_multivariate_d_study()], [mfrm_generalizability()]
#' @examples
#' # Fictional continuous scores, with two correlated score components.
#' set.seed(2026)
#' ratings <- expand.grid(Person = 1:40, Rater = 1:8, Task = 1:6)
#' ratings$Content <- ratings$Organization <- 0
#' sources <- list("Person", "Rater", "Task", c("Person", "Rater"),
#'   c("Person", "Task"), c("Rater", "Task"), c("Person", "Rater", "Task"))
#' for (source in sources) {
#'   group <- interaction(ratings[source], drop = TRUE)
#'   effect <- matrix(rnorm(2 * nlevels(group)), ncol = 2)
#'   effect <- effect %*% matrix(c(1, 0, 0.4, 1), 2)
#'   ratings[c("Content", "Organization")] <-
#'     ratings[c("Content", "Organization")] + effect[as.integer(group), ]
#' }
#' g <- mfrm_multivariate_gstudy(ratings, c("Content", "Organization"))
#' g$components$Person
#' g$component_diagnostics
#' d <- mfrm_multivariate_d_study(g,
#'   design_grid = data.frame(Raters = c(2, 4), Tasks = c(3, 3)),
#'   weights = c(Content = 0.6, Organization = 0.4))
#' d$coefficients
#' # Difference-score dependability, when subtraction is meaningful on these scales.
#' difference <- mfrm_multivariate_d_study(g,
#'   weights = c(Content = 1, Organization = -1))
#' difference$coefficients
#' @export
mfrm_multivariate_gstudy <- function(data, scores, person = "Person",
                                     rater = "Rater", task = "Task") {
  valid_names <- function(x) is.character(x) && length(x) > 0L &&
    !anyNA(x) && all(nzchar(trimws(x))) && !anyDuplicated(x)
  if (!is.data.frame(data) || nrow(data) == 0L || !valid_names(names(data))) {
    stop("`data` must be a nonempty data frame with unique, nonblank column names.", call. = FALSE)
  }
  ids <- c(person, rater, task)
  if (any(lengths(list(person, rater, task)) != 1L) ||
      !all(vapply(list(person, rater, task), is.character, logical(1))) ||
      !valid_names(ids) || !valid_names(scores) || any(scores %in% ids) ||
      !all(c(ids, scores) %in% names(data))) {
    stop("Supply distinct person, rater, task, and score column names present in `data`.", call. = FALSE)
  }
  data <- as.data.frame(data[c(ids, scores)])
  groups <- lapply(data[ids], function(x) {
    if (!is.null(dim(x)) || !(is.factor(x) || (!is.object(x) &&
        (is.character(x) || is.logical(x) || (is.numeric(x) && !is.complex(x))))) ||
        anyNA(x) || (is.numeric(x) && any(!is.finite(x))) ||
        any(!nzchar(trimws(as.character(x))))) {
      stop("Factor identifiers must be finite, nonmissing, nonblank labels.", call. = FALSE)
    }
    factor(x)
  })
  counts <- setNames(vapply(groups, nlevels, integer(1)), c("Person", "Rater", "Task"))
  if (any(counts < 2L)) stop("Person, Rater, and Task each need at least two observed levels.", call. = FALSE)
  if (anyDuplicated(data[ids])) {
    stop("Duplicate Person/Rater/Task cells are not supported; do not average replicates silently.", call. = FALSE)
  }
  if (nrow(data) != prod(as.double(counts))) {
    stop("Supply a complete, balanced Person-by-Rater-by-Task design with common conditions across scores.", call. = FALSE)
  }
  if (!all(vapply(data[scores], function(x) is.numeric(x) && !is.object(x) &&
      !is.complex(x) && is.null(dim(x)) && all(is.finite(x)), logical(1)))) {
    stop("All selected scores must be finite numeric values; missing scores are not omitted or imputed.", call. = FALSE)
  }
  y <- as.matrix(data[scores])
  y <- sweep(y, 2L, colMeans(y), "-")
  if (any(!is.finite(y))) stop("Score centering overflowed; rescale the scores.", call. = FALSE)
  score_scale <- sqrt(colSums(y^2) / (nrow(y) - 1))
  if (any(!is.finite(score_scale)) || any(score_scale == 0 & colSums(abs(y)) > 0)) {
    stop("Score variation exceeds numeric range; rescale the scores.", call. = FALSE)
  }
  names(score_scale) <- scores
  # Orthogonal balanced-design projections, using group means rather than an
  # observation-by-observation projection matrix.
  subsets <- list(1L, 2L, 3L, c(1L, 2L), c(1L, 3L), c(2L, 3L), 1:3)
  sources <- c("Person", "Rater", "Task", "Person:Rater", "Person:Task", "Rater:Task", "Residual")
  effects <- mean_products <- setNames(vector("list", 7L), sources)
  df <- setNames(numeric(7L), sources)
  for (i in seq_along(subsets)) {
    subset <- subsets[[i]]
    group <- as.integer(interaction(groups[subset], drop = TRUE))
    effect <- (rowsum(y, group) / tabulate(group))[group, , drop = FALSE]
    for (j in seq_len(i - 1L)) {
      if (all(subsets[[j]] %in% subset)) effect <- effect - effects[[j]]
    }
    effects[[i]] <- effect
    df[i] <- prod(counts[subset] - 1)
    mean_products[[i]] <- crossprod(effect) / df[i]
  }
  m <- mean_products
  nr <- counts[["Rater"]]
  nt <- counts[["Task"]]
  components <- list(
    Person = (m$Person - m[["Person:Rater"]] - m[["Person:Task"]] + m$Residual) / (nr * nt),
    Rater = (m$Rater - m[["Person:Rater"]] - m[["Rater:Task"]] + m$Residual) / (counts[["Person"]] * nt),
    Task = (m$Task - m[["Person:Task"]] - m[["Rater:Task"]] + m$Residual) / (counts[["Person"]] * nr),
    `Person:Rater` = (m[["Person:Rater"]] - m$Residual) / nt,
    `Person:Task` = (m[["Person:Task"]] - m$Residual) / nr,
    `Rater:Task` = (m[["Rater:Task"]] - m$Residual) / counts[["Person"]],
    Residual = m$Residual
  )
  if (any(!is.finite(unlist(components)))) {
    stop("Covariance estimation exceeded numeric range; rescale the scores.", call. = FALSE)
  }
  diagnostics <- .mfrm_mvgt_diagnostics(components, score_scale)
  structure(list(components = components, mean_products = mean_products,
    degrees_of_freedom = data.frame(Source = sources, DF = unname(df)),
    component_diagnostics = diagnostics, score_scale = score_scale,
    design = list(person = person, rater = rater, task = task, scores = scores,
      counts = counts, levels = lapply(groups, levels), rows = nrow(data),
      method = "Balanced multivariate ANOVA", score_convention = "Means over common random raters and tasks",
      calculation_version = 1L), data = data), class = "mfrm_multivariate_gstudy")
}

.mfrm_mvgt_diagnostics <- function(components, score_scale) {
  scale <- score_scale
  scale[scale == 0] <- 1
  do.call(rbind, lapply(names(components), function(source) {
    standardized <- sweep(sweep(components[[source]], 1L, scale, "/"), 2L, scale, "/")
    values <- eigen(standardized, symmetric = TRUE, only.values = TRUE)$values
    tolerance <- sqrt(.Machine$double.eps) * max(1, abs(values))
    data.frame(Source = source, MinimumScaledEigenvalue = min(values),
      Tolerance = tolerance, PositiveSemidefinite = min(values) >= -tolerance,
      Rank = sum(values > tolerance), Dimension = length(values), row.names = NULL)
  }))
}

#' Project multivariate G-theory coefficients for common raters and tasks
#'
#' Use a balanced multivariate G-study to examine mean-score dependability
#' under specified numbers of random raters and tasks, and optional composite
#' weights. This reuses estimated covariance components without refitting.
#'
#' @param x A result from [mfrm_multivariate_gstudy()].
#' @param design_grid A nonempty data frame with positive integer `Raters` and
#'   `Tasks` columns, one planned design per row. `NULL` uses the G-study counts.
#'   Counts need not match or exceed the G-study counts. Conditions are fully
#'   crossed and shared across scores in every scenario.
#' @param weights Optional named, finite score weights, including every score
#'   exactly once, with at least one nonzero entry. Signed weights allow
#'   difference scores, for example `c(Content = 1, Organization = -1)`.
#'   Weights are used as supplied, without normalization. `NULL` reports score
#'   components only; otherwise an additional composite is reported for every
#'   scenario.
#'
#' @details For covariance component matrices `P`, `R`, `T`, `PR`, `PT`, `RT`,
#'   and `E`, universe-score covariance is `P`. Relative-error covariance is
#'   `PR/n_r + PT/n_t + E/(n_r*n_t)`. Absolute-error covariance adds
#'   `R/n_r + T/n_t + RT/(n_r*n_t)`. The G-study number of persons does not
#'   divide individual-score universe variance. Holding a count constant does
#'   not turn its random facet into a fixed facet.
#'
#'   Each score uses diagonal entries; a composite uses `w' Sigma w` for each
#'   of the three covariance matrices. Thus between-score covariance affects
#'   composite dependability. `G = UniverseVariance / (UniverseVariance +
#'   RelativeErrorVariance)` and `Phi` uses absolute error instead. SEMs are
#'   square roots of the corresponding error variances, in the units of the
#'   score or specified composite of mean scores. Multiplying all weights by
#'   a nonzero constant multiplies SEMs by its absolute value but leaves G/Phi
#'   unchanged. Weights express a substantive choice; this function neither
#'   chooses them nor identifies an optimal design. Interpret a difference
#'   only when subtraction is meaningful on the supplied score scales.
#'
#'   The same weights define the universe-score composite and its observed
#'   mean-score estimate (the equal WWTS/AWTS case in mGENOVA). Different
#'   target and estimation weights, profile reliability, and accuracy at a
#'   cut score are not provided. Unlike mGENOVA's default D-study procedure,
#'   negative variance estimates are not replaced with zero.
#'
#'   Raw covariance matrices and projected variances remain available. If any
#'   G-study component fails its PSD check, all G/Phi and SEM entries are `NA`.
#'   Otherwise, a row requires a positive universe variance and nonnegative
#'   error variances. Zero estimated universe variance is not perfect
#'   reliability. `Status` explains unavailable rows; inspect
#'   `component_diagnostics` before interpreting estimates. Passing the matrix
#'   checks does not establish precise estimation or model fit. Outputs are
#'   point projections conditional on the estimated components, without
#'   confidence intervals, missing-data correction, or MFRM latent inference.
#'
#' @return An `mfrm_multivariate_d_study` list containing `coefficients`
#'   (scenario, counts, score/composite identity, raw universe/relative/absolute
#'   variances, G/Phi, relative/absolute SEM, and status), `covariances` (three
#'   matrices per scenario), `design_grid`, `weights`, `component_diagnostics`,
#'   and `gstudy` (the source result). `summary()` returns `coefficients`.
#' @references Brennan, R. L. (2001). *Generalizability theory*. Springer.
#'   Chapters 9--11.
#'   Brennan, R. L. (2001). *Manual for mGENOVA, Version 2.1*.
#'   Iowa Testing Programs Occasional Papers, No. 50. Pages 16 and 20--22;
#'   Appendix F, pages 79--81.
#' @seealso [mfrm_multivariate_gstudy()], [mfrm_d_study()]
#' @examples
#' # See mfrm_multivariate_gstudy() for a complete data-to-D-study example.
#' @export
mfrm_multivariate_d_study <- function(x, design_grid = NULL, weights = NULL) {
  if (!inherits(x, "mfrm_multivariate_gstudy") ||
      !identical(x$design$calculation_version, 1L)) {
    stop("`x` must be a current mfrm_multivariate_gstudy result.", call. = FALSE)
  }
  scores <- x$design$scores
  sources <- c("Person", "Rater", "Task", "Person:Rater", "Person:Task", "Rater:Task", "Residual")
  if (!is.character(scores) || !length(scores) || anyNA(scores) || anyDuplicated(scores) ||
      !identical(names(x$components), sources) ||
      !is.numeric(x$score_scale) || !identical(names(x$score_scale), scores) ||
      any(!is.finite(x$score_scale)) || any(x$score_scale < 0) ||
      !all(vapply(x$components, function(a) is.matrix(a) && is.numeric(a) &&
        !is.complex(a) && identical(dim(a), rep(length(scores), 2L)) &&
        identical(dimnames(a), list(scores, scores)) && all(is.finite(a)) &&
        identical(a, t(a)), logical(1)))) {
    stop("The G-study covariance matrices or score identities are incomplete or altered; recreate the result.", call. = FALSE)
  }
  diagnostics <- .mfrm_mvgt_diagnostics(x$components, x$score_scale)
  if (is.null(design_grid)) {
    design_grid <- data.frame(Raters = unname(x$design$counts["Rater"]),
                              Tasks = unname(x$design$counts["Task"]))
  }
  if (!is.data.frame(design_grid) || !nrow(design_grid) ||
      !setequal(names(design_grid), c("Raters", "Tasks")) || ncol(design_grid) != 2L ||
      !all(vapply(design_grid, function(n) is.numeric(n) && !is.object(n) &&
        is.null(dim(n)) && !is.complex(n) && all(is.finite(n)) &&
        all(n >= 1 & n <= .Machine$integer.max & n == floor(n)), logical(1)))) {
    stop("`design_grid` must contain only positive integer Raters and Tasks columns, one scenario per row.", call. = FALSE)
  }
  design_grid <- as.data.frame(design_grid[c("Raters", "Tasks")])
  rownames(design_grid) <- NULL
  vectors <- diag(length(scores))
  colnames(vectors) <- scores
  kind <- rep("Score", length(scores))
  if (!is.null(weights)) {
    if (!is.numeric(weights) || is.object(weights) || is.complex(weights) ||
        !is.null(dim(weights)) || length(weights) != length(scores) ||
        is.null(names(weights)) || anyNA(names(weights)) || anyDuplicated(names(weights)) ||
        !setequal(names(weights), scores) || any(!is.finite(weights)) ||
        !any(weights != 0)) {
      stop("`weights` must name every score once with finite values and at least one nonzero value.", call. = FALSE)
    }
    weights <- weights[scores]
    vectors <- cbind(vectors, Composite = weights)
    kind <- c(kind, "Composite")
  }
  projection_scale <- apply(abs(vectors), 2L, max)
  if (any(!is.finite(projection_scale^2)) || any(projection_scale^2 == 0)) {
    stop("Composite variances exceed numeric range; rescale the weights.", call. = FALSE)
  }
  vectors <- sweep(vectors, 2L, projection_scale, "/")
  c <- x$components
  covariances <- vector("list", nrow(design_grid))
  tables <- vector("list", nrow(design_grid))
  for (i in seq_len(nrow(design_grid))) {
    nr <- design_grid$Raters[i]
    nt <- design_grid$Tasks[i]
    relative <- c[["Person:Rater"]] / nr + c[["Person:Task"]] / nt + c$Residual / (nr * nt)
    absolute <- relative + c$Rater / nr + c$Task / nt + c[["Rater:Task"]] / (nr * nt)
    covariances[[i]] <- list(Universe = c$Person, RelativeError = relative, AbsoluteError = absolute)
    unit_variances <- matrix(vapply(covariances[[i]],
      function(a) colSums(vectors * (a %*% vectors)), numeric(ncol(vectors))),
      nrow = ncol(vectors), ncol = 3L)
    variances <- unit_variances * projection_scale^2
    if (any(!is.finite(variances)) || any(variances == 0 & unit_variances != 0)) {
      stop("D-study projection exceeded numeric range; rescale scores or weights.", call. = FALSE)
    }
    u <- unit_variances[, 1L]
    r <- unit_variances[, 2L]
    a <- unit_variances[, 3L]
    status <- rep("Available", length(u))
    status[u <= 0] <- "Universe variance is not positive"
    status[r < 0 | a < 0] <- "Negative projected error variance"
    if (!all(diagnostics$PositiveSemidefinite)) status[] <- "Non-PSD component estimates"
    available <- status == "Available"
    g <- phi <- sem_r <- sem_a <- rep(NA_real_, length(u))
    # Scale each denominator before addition to avoid overflow.
    relative_scale <- pmax(u[available], r[available])
    absolute_scale <- pmax(u[available], a[available])
    g[available] <- (u[available] / relative_scale) /
      (u[available] / relative_scale + r[available] / relative_scale)
    phi[available] <- (u[available] / absolute_scale) /
      (u[available] / absolute_scale + a[available] / absolute_scale)
    sem_r[available] <- sqrt(r[available]) * projection_scale[available]
    sem_a[available] <- sqrt(a[available]) * projection_scale[available]
    tables[[i]] <- data.frame(Scenario = i, Raters = nr, Tasks = nt,
      Kind = kind, Score = colnames(vectors), UniverseVariance = variances[, 1L],
      RelativeErrorVariance = variances[, 2L], AbsoluteErrorVariance = variances[, 3L], G = g, Phi = phi,
      RelativeSEM = sem_r, AbsoluteSEM = sem_a, Status = status, row.names = NULL)
  }
  structure(list(coefficients = do.call(rbind, tables), covariances = covariances,
    design_grid = design_grid, weights = weights, component_diagnostics = diagnostics,
    gstudy = x), class = "mfrm_multivariate_d_study")
}

#' @rdname mfrm_multivariate_gstudy
#' @param x,object A result from the corresponding G-study or D-study function.
#' @param ... Reserved for method compatibility.
#' @method print mfrm_multivariate_gstudy
#' @export
print.mfrm_multivariate_gstudy <- function(x, ...) {
  cat("Multivariate observed-score G-study\n")
  cat("Complete crossed design:", x$design$counts[["Person"]], "persons,",
      x$design$counts[["Rater"]], "raters,", x$design$counts[["Task"]], "tasks\n")
  cat("Balanced ANOVA; highest-order interaction and residual are combined.\n")
  print(x$component_diagnostics, row.names = FALSE)
  cat("Raw covariance components are retained. Sampling uncertainty is not estimated.\n")
  invisible(x)
}

#' @rdname mfrm_multivariate_gstudy
#' @method summary mfrm_multivariate_gstudy
#' @export
summary.mfrm_multivariate_gstudy <- function(object, ...) {
  object$component_diagnostics
}

#' @rdname mfrm_multivariate_d_study
#' @param object A result from [mfrm_multivariate_d_study()].
#' @param ... Reserved for method compatibility.
#' @method print mfrm_multivariate_d_study
#' @export
print.mfrm_multivariate_d_study <- function(x, ...) {
  cat("Multivariate observed-score D-study\n")
  cat("Means over common random raters and tasks; weights are used as supplied.\n")
  print(x$coefficients, row.names = FALSE)
  cat("Point projections conditional on estimated covariance components; no confidence intervals.\n")
  invisible(x)
}

#' @rdname mfrm_multivariate_d_study
#' @method summary mfrm_multivariate_d_study
#' @export
summary.mfrm_multivariate_d_study <- function(object, ...) {
  object$coefficients
}
