# Fixed-Person coverage study of the public two-stage common-plan delta route.
# Run from the package root. See the matching protocol; preflight is not confirmation.
fair_coverage_cells <- function() {
  x <- expand.grid(Model = c("RSM", "PCM"), N = c(20L, 60L, 240L),
    Design = c("dense_same", "sparse_overlap", "weak_overlap", "strong_overlap"), stringsAsFactors = FALSE)
  x$Cell <- seq_len(nrow(x)); x[, c("Cell", "Model", "N", "Design")]
}

fair_coverage_design <- function(cell) {
  n <- cell$N; nr <- if (cell$Design %in% c("weak_overlap", "strong_overlap")) 6L else 3L
  persons <- sprintf("P%03d", seq_len(n)); raters <- paste0("R", seq_len(nr))
  criteria <- paste0("C", 1:3)
  theta <- seq(-1.2, 1.2, length.out = n)
  focal <- c(n %/% 2L, n %/% 2L + 1L); theta[focal] <- c(-.5, .5)
  severity <- seq(-.45, .45, length.out = nr); difficulty <- c(-.35, 0, .35)
  steps <- if (cell$Model == "RSM") matrix(c(-.7, 0, .7), 3, 3, byrow = TRUE) else
    rbind(c(-.8, .1, .7), c(-.5, -.1, .6), c(-.9, .2, .7))
  pairs <- if (nr == 3L) rbind(c(1, 2), c(2, 3), c(3, 1)) else
    rbind(c(3, 4), c(1, 2), c(4, 5), c(2, 3), c(5, 6),
      c(1, 3), c(4, 6), c(1, 2), c(4, 5), c(2, 3))
  if (cell$Design == "strong_overlap") {
    # Degree-preserving rewiring in each five-Person block. Calibration/scoring
    # boundaries are multiples of five, so their Rater x Criterion counts agree
    # with weak_overlap, in addition to N, six Raters and six ratings per Person.
    pairs <- rbind(c(1, 4), c(2, 5), c(3, 6), c(2, 4), c(3, 5),
      c(1, 4), c(2, 6), c(3, 4), c(1, 5), c(2, 3))
  }
  data <- do.call(rbind, lapply(seq_len(n), function(i) {
    r <- if (cell$Design == "dense_same") seq_len(nr) else pairs[1L + (i - 1L) %% nrow(pairs), ]
    z <- expand.grid(Rater = raters[r], Criterion = criteria, stringsAsFactors = FALSE)
    data.frame(Person = persons[i], z, Score = 0L)
  }))
  probability <- function(person, rater, criterion) {
    eta <- theta[match(person, persons)] - severity[match(rater, raters)] - difficulty[match(criterion, criteria)]
    cumulative <- t(apply(steps[match(criterion, criteria), , drop = FALSE], 1, function(s) c(0, cumsum(s))))
    logits <- outer(eta, 0:3) - cumulative
    p <- exp(logits - apply(logits, 1, max)); p / rowSums(p)
  }
  probs <- probability(data$Person, data$Rater, data$Criterion)
  plan <- expand.grid(Rater = raters, Criterion = criteria, stringsAsFactors = FALSE)
  plan$Weight <- match(plan$Rater, raters) * c(1, 2, 1)[match(plan$Criterion, criteria)]
  truth <- vapply(persons[focal], function(p) weighted.mean(drop(probability(
    rep(p, nrow(plan)), plan$Rater, plan$Criterion) %*% (0:3)), plan$Weight), 0)
  ids <- match(data$Person, persons)
  maps <- if (cell$Design == "dense_same") list(calibration = seq_len(nrow(data)), scoring = seq_len(nrow(data))) else
    list(calibration = which(ids <= 3L * n / 4L), scoring = which(ids > n / 4L))
  # Explicit event indices, not a join by repeated labels or a regenerated score.
  stopifnot(setequal(unlist(maps), seq_len(nrow(data))), all(persons[focal] %in% data$Person[maps$scoring]))
  list(data = data, probabilities = probs, plan = plan, maps = maps, persons = persons[focal],
    truth = c(truth, difference = unname(truth[1] - truth[2])), theta = theta,
    severity = severity, difficulty = difficulty, steps = steps)
}

fair_coverage_one <- function(cell, replication, phase) {
  design <- fair_coverage_design(cell)
  seed_cell <- cell$Cell - if (cell$Design == "strong_overlap") 6L else 0L
  seed <- (if (phase == "preflight") 624800000L else 624900000L) + 10000L * seed_cell + replication
  set.seed(seed)
  p <- design$probabilities; u <- runif(nrow(p))
  design$data$Score <- pmin(rowSums(u > t(apply(p, 1, cumsum))), 3L)
  target <- c(design$persons, "difference")
  rows <- expand.grid(Target = target, Method = c("estimated_delta", "fixed_anchor_delta"), stringsAsFactors = FALSE)
  rows$Truth <- unname(design$truth[match(rows$Target, target)])
  rows$Estimate <- rows$SE <- rows$Lower <- rows$Upper <- NA_real_
  rows$Available <- FALSE; rows$Reason <- "not_attempted"
  warnings <- character(); fit_checks <- list(); stage <- "calibration"
  fits <- list(); started <- proc.time()[[3]]
  tryCatch(withCallingHandlers({
    args <- list(person = "Person", facets = c("Rater", "Criterion"), score = "Score",
      method = "JML", model = cell$Model, rating_min = 0, rating_max = 3,
      optimizer = "BFGS", maxit = 1000, reltol = 1e-12)
    if (cell$Model == "PCM") args$step_facet <- "Criterion"
    fit_part <- function(indices, anchors = NULL) {
      a <- args; a$data <- design$data[indices, ]; if (!is.null(anchors)) a$anchors <- anchors
      do.call(fit_mfrm, a)
    }
    fits$calibration <- fit_part(design$maps$calibration)
    # An unqualified calibration must not become an estimated fixed anchor.
    fit_checks$calibration <- mfrmr:::mfrm_fair_refit_check(fits$calibration, 1e-4)
    anchors <- data.frame(Facet = "Rater", Level = "R1", Anchor =
      subset(fits$calibration$facets$others, Facet == "Rater" & Level == "R1")$Estimate)
    stage <- "scoring"; fits$scoring <- fit_part(design$maps$scoring, anchors)
    fair <- fair_average_table(fits$scoring, reference_plan = design$plan)
    points <- fair$reference_scores$Estimate[match(design$persons, fair$reference_scores$Person)]
    rows$Estimate <- rep(c(points, points[1] - points[2]), 2L)
    # Fixed-anchor comparator can remain available when the union fit is not.
    calculate <- function(method, generator = NULL) {
      tryCatch({
        arguments <- list(object = fair, parm = design$persons, method = "delta")
        if (method == "estimated_delta") arguments <- c(arguments,
          list(anchor_source = fits$calibration, generating_fit = generator, response_map = design$maps)) else
          arguments$anchor_uncertainty <- "fixed"
        result <- do.call(confint, arguments)
        contrast <- matrix(c(1, -1), 1, dimnames = list("difference", design$persons))
        arguments$contrasts <- contrast
        difference <- do.call(confint, arguments)
        z <- rbind(as.data.frame(result), as.data.frame(difference))
        ii <- which(rows$Method == method)
        rows$Estimate[ii] <<- z$Estimate; rows$SE[ii] <<- z$SE
        rows$Lower[ii] <<- z$CI_Lower; rows$Upper[ii] <<- z$CI_Upper
        rows$Available[ii] <<- z$Available; rows$Reason[ii] <<- z$Reason
        list(scores = result, contrast = difference)
      }, error = function(e) {
        rows$Reason[rows$Method == method] <<- conditionMessage(e); NULL
      })
    }
    fixed <- calculate("fixed_anchor_delta")
    stage <- "union"
    fits$union <- if (identical(design$maps$calibration, seq_len(nrow(design$data)))) fits$calibration else
      fit_part(seq_len(nrow(design$data)))
    estimated <- calculate("estimated_delta", fits$union)
    fit_checks$fixed <- fixed; fit_checks$estimated <- estimated
  }, warning = function(w) {
    warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning")
  }), error = function(e) {
    ii <- rows$Reason == "not_attempted"
    rows$Reason[ii] <<- paste(stage, conditionMessage(e), sep = ": ")
  })
  rows$Covered <- ifelse(rows$Available, rows$Lower <= rows$Truth & rows$Truth <= rows$Upper, NA)
  rows$Cell <- cell$Cell; rows$Replication <- replication; rows$Seed <- seed
  boundary <- lapply(fits, function(f) {
    t <- f$facets$person$PrimaryEstimate
    if (is.null(t)) t <- f$facets$person$Estimate
    c(Persons = length(t), InfinitePersons = sum(is.infinite(t)), MissingPersons = sum(is.na(t)))
  })
  list(rows = rows, seconds = proc.time()[[3]] - started, warnings = unique(warnings),
    boundaries = boundary, checks = fit_checks,
    # Preflight retains the full input/fits for causal diagnosis and replay.
    design = if (phase == "preflight") design else NULL,
    fits = if (phase == "preflight") fits else NULL)
}

fair_coverage_summary <- function(records, expected) {
  rows <- do.call(rbind, lapply(records, `[[`, "rows"))
  keys <- unique(rows[c("Cell", "Replication")])
  keys <- keys[order(keys$Cell, keys$Replication), ]; rownames(keys) <- NULL
  if (!identical(keys, expected))
    stop("Incomplete, duplicate or unexpected replication identities; no performance summary.")
  if (anyDuplicated(rows[c("Cell", "Replication", "Target", "Method")])) stop("Duplicate target records.")
  if (any(table(interaction(rows$Cell, rows$Replication, drop = TRUE)) != 6L)) stop("Incomplete target/method rows.")
  answer <- lapply(split(rows, interaction(rows$Cell, rows$Method, rows$Target, drop = TRUE)), function(z) {
    available <- z$Available; n <- sum(available); covered <- sum(z$Covered, na.rm = TRUE)
    err <- z$Estimate - z$Truth; finite <- is.finite(err)
    ci <- if (n) binom.test(covered, n)$conf.int else c(NA_real_, NA_real_)
    a <- binom.test(n, nrow(z))$conf.int
    data.frame(Cell = z$Cell[1], Method = z$Method[1], Target = z$Target[1],
      Assigned = nrow(z), FinitePoints = sum(finite), Available = n, Covered = covered,
      Availability = n / nrow(z), AvailabilityLower = a[1], AvailabilityUpper = a[2],
      Coverage = if (n) covered / n else NA_real_, CoverageLower = ci[1], CoverageUpper = ci[2],
      CoverageMCSE = if (n) sqrt(covered / n * (1 - covered / n) / n) else NA_real_,
      AvailableAndCovered = covered / nrow(z),
      BiasAllFinite = if (any(finite)) mean(err[finite]) else NA_real_,
      BiasAllFiniteMCSE = if (sum(finite) > 1) sd(err[finite]) / sqrt(sum(finite)) else NA_real_,
      RMSEAllFinite = if (any(finite)) sqrt(mean(err[finite]^2)) else NA_real_,
      BiasAvailable = if (n) mean(err[available]) else NA_real_,
      BiasAvailableMCSE = if (n > 1) sd(err[available]) / sqrt(n) else NA_real_,
      RMSEAvailable = if (n) sqrt(mean(err[available]^2)) else NA_real_,
      EmpiricalSD = if (n > 1) sd(err[available]) else NA_real_,
      RMSSE = if (n) sqrt(mean(z$SE[available]^2)) else NA_real_,
      MeanWidth = if (n) mean(z$Upper[available] - z$Lower[available]) else NA_real_)
  })
  do.call(rbind, answer)
}

# A separate, fixed pilot epoch: these are new responses, not re-labelled
# ordinary/refit preflight results. The older entry points remain reproducible.
fair_penalized_allocation <- function() {
  cells <- subset(fair_coverage_cells(), Cell %in% 13:24)
  rows <- lapply(seq_len(nrow(cells)), function(i) data.frame(Cell = cells$Cell[i],
    Replication = seq_len(c(`20` = 20L, `60` = 6L, `240` = 3L)[as.character(cells$N[i])])) )
  x <- do.call(rbind, rows)
  # Finish complete weak/strong pairs, retaining all sample sizes early.
  x <- x[order(x$Replication, (x$Cell - 13L) %% 6L, x$Cell), ]
  rownames(x) <- NULL
  x
}

# Independent finite-response bounds, including missing plan cells. This does
# not construct a fake fit or replace a missing fitted point with a success.
fair_penalized_bound <- function(design) {
  d <- design$data[design$maps$scoring, ]; plan <- design$plan
  w <- plan$Weight / sum(plan$Weight)
  weights <- matrix(0, nrow(d), 2L); missing <- numeric(2L)
  for (j in 1:2) for (cell in seq_len(nrow(plan))) {
    rows <- which(d$Person == design$persons[j] & d$Rater == plan$Rater[cell] &
      d$Criterion == plan$Criterion[cell])
    if (length(rows)) weights[rows, j] <- w[cell] / length(rows) else
      missing[j] <- missing[j] + w[cell]
  }
  L <- rbind(c(1, 0), c(0, 1), c(1, -1))
  U <- weights %*% t(L); observed <- drop(crossprod(U, d$Score))
  absent <- sweep(L, 2L, missing, `*`)
  radius <- 3 * sqrt(colSums(U^2) * log(2 / .05) / 2)
  lo <- pmax(3 * rowSums(pmin(L, 0)), observed + 3 * rowSums(pmin(absent, 0)) - radius)
  hi <- pmin(3 * rowSums(pmax(L, 0)), observed + 3 * rowSums(pmax(absent, 0)) + radius)
  data.frame(Lower = lo, Upper = hi,
    Informative = hi - lo < 3 * rowSums(abs(L)) * (1 - 1e-12))
}

fair_penalized_one <- function(cell, replication) {
  design <- fair_coverage_design(cell)
  paired_cell <- cell$Cell - if (cell$Design == "strong_overlap") 6L else 0L
  seed <- 625100000L + 10000L * paired_cell + replication
  set.seed(seed); p <- design$probabilities
  design$data$Score <- pmin(rowSums(runif(nrow(p)) > t(apply(p, 1L, cumsum))), 3L)
  target <- c(design$persons, "difference")
  methods <- c("ordinary_delta", "jeffreys_delta", "bounded_reference")
  rows <- expand.grid(Target = target, Method = methods, stringsAsFactors = FALSE)
  rows$Truth <- unname(design$truth[match(rows$Target, target)])
  rows$Estimate <- rows$SE <- rows$Lower <- rows$Upper <- NA_real_
  rows$Available <- FALSE; rows$Informative <- NA; rows$Reason <- "not_attempted"
  rows$Stage <- "calibration"
  b <- fair_penalized_bound(design); ii <- which(rows$Method == "bounded_reference")
  rows$Lower[ii] <- b$Lower; rows$Upper[ii] <- b$Upper
  rows$Available[ii] <- TRUE; rows$Informative[ii] <- b$Informative
  rows$Reason[ii] <- ifelse(b$Informative, "independent_response_bound", "full_target_support")
  rows$Stage[ii] <- "response_bound"
  fits <- checks <- intervals <- list(); warnings <- list(); timing <- list()
  started <- proc.time()[[3L]]
  for (penalty in c("none", "jeffreys")) {
    method <- if (penalty == "none") "ordinary_delta" else "jeffreys_delta"
    ii <- which(rows$Method == method); stage <- "calibration"
    fits[[method]] <- checks[[method]] <- list(); warnings[[method]] <- character()
    method_start <- proc.time()[[3L]]
    tryCatch(withCallingHandlers({
      args <- list(person = "Person", facets = c("Rater", "Criterion"), score = "Score",
        method = "JML", model = cell$Model, jml_penalty = penalty,
        rating_min = 0, rating_max = 3, category_policy = "preserve",
        optimizer = "BFGS", maxit = 1000, reltol = 1e-12)
      if (cell$Model == "PCM") args$step_facet <- "Criterion"
      fit_part <- function(which, anchors = NULL) do.call(fit_mfrm,
        c(list(data = design$data[which, ], anchors = anchors), args))
      cal <- fit_part(design$maps$calibration); fits[[method]]$calibration <- cal
      checks[[method]]$calibration <- mfrmr:::mfrm_fair_refit_check(cal, 1e-4)
      a <- data.frame(Facet = "Rater", Level = "R1", Anchor =
        subset(cal$facets$others, Facet == "Rater" & Level == "R1")$Estimate)
      stage <- "scoring"
      scored <- fit_part(design$maps$scoring, a); fits[[method]]$scoring <- scored
      fair <- fair_average_table(scored, reference_plan = design$plan)
      points <- fair$reference_scores$Estimate[match(design$persons, fair$reference_scores$Person)]
      rows$Estimate[ii] <- c(points, points[1] - points[2])
      L <- matrix(c(1, -1), 1, dimnames = list("difference", design$persons))
      # Check the independently defined bound against both public estimators.
      public_b <- confint(fair, parm = design$persons, method = "bounded")
      public_diff <- confint(fair, parm = design$persons, contrasts = L, method = "bounded")
      checks[[method]]$bounded_difference <- max(abs(c(public_b$CI_Lower, public_diff$CI_Lower) - b$Lower),
        abs(c(public_b$CI_Upper, public_diff$CI_Upper) - b$Upper))
      if (checks[[method]]$bounded_difference > 1e-12) stop("Independent/public response bounds disagree.")
      stage <- "union"
      union <- if (identical(design$maps$calibration, seq_len(nrow(design$data)))) cal else
        fit_part(seq_len(nrow(design$data)))
      fits[[method]]$union <- union
      stage <- "delta"
      ci <- confint(fair, parm = design$persons, method = "delta", anchor_source = cal,
        generating_fit = union, response_map = design$maps)
      intervals[[method]] <- ci
      checks[[method]]$sources <- attr(ci, "source_checks")
      V <- attr(ci, "covariance")
      diff_se <- if (all(ci$Available)) sqrt(drop(L %*% V %*% t(L))) else NA_real_
      rows$SE[ii] <- c(ci$SE, diff_se)
      rows$Lower[ii] <- c(ci$CI_Lower, rows$Estimate[ii[3]] - qnorm(.975) * diff_se)
      rows$Upper[ii] <- c(ci$CI_Upper, rows$Estimate[ii[3]] + qnorm(.975) * diff_se)
      rows$Available[ii] <- c(ci$Available, all(ci$Available) && is.finite(diff_se))
      rows$Reason[ii] <- c(ci$Reason, paste(unique(ci$Reason), collapse = ";"))
      rows$Stage[ii] <- "delta"
    }, warning = function(w) {
      warnings[[method]] <<- c(warnings[[method]], conditionMessage(w)); invokeRestart("muffleWarning")
    }), error = function(e) {
      rows$Reason[ii] <<- conditionMessage(e); rows$Stage[ii] <<- stage
    })
    timing[[method]] <- proc.time()[[3L]] - method_start
    if (!is.null(checks[[method]]$bounded_difference) &&
        checks[[method]]$bounded_difference > 1e-12)
      stop("Independent/public bound verification failed; stop this pilot epoch.")
  }
  rows$Covered <- ifelse(rows$Available, rows$Lower <= rows$Truth & rows$Truth <= rows$Upper, NA)
  rows$Cell <- cell$Cell; rows$Replication <- replication; rows$Seed <- seed
  list(rows = rows, seconds = proc.time()[[3L]] - started, method_seconds = timing,
    warnings = lapply(warnings, unique), checks = checks, intervals = intervals,
    design = design, fits = if (replication == 1L || any(!rows$Available)) fits else NULL)
}

fair_penalized_summary <- function(records, expected) {
  rows <- do.call(rbind, lapply(records, `[[`, "rows"))
  keys <- unique(rows[c("Cell", "Replication")])
  order_keys <- function(x) {x <- x[order(x$Cell, x$Replication), ]; rownames(x) <- NULL; x}
  if (!identical(order_keys(keys), order_keys(expected)) ||
      !setequal(unique(rows$Method), c("ordinary_delta", "jeffreys_delta", "bounded_reference")) ||
      anyDuplicated(rows[c("Cell", "Replication", "Method", "Target")]) ||
      any(table(interaction(rows$Cell, rows$Replication, drop = TRUE)) != 9L) ||
      any(table(interaction(rows$Cell, rows$Replication, rows$Method, drop = TRUE)) != 3L) ||
      anyNA(rows$Available) || any(!is.na(rows$Covered[!rows$Available])) ||
      anyNA(rows$Covered[rows$Available]) ||
      any(!is.finite(rows$Lower[rows$Available]) | !is.finite(rows$Upper[rows$Available])))
    stop("Incomplete, duplicate or unexpected pilot records.")
  interval <- function(k, n) if (n) unname(binom.test(k, n)$conf.int) else c(NA_real_, NA_real_)
  mcse <- function(x) if (length(x) > 1L) sd(x) / sqrt(length(x)) else NA_real_
  summaries <- lapply(split(rows, interaction(rows$Cell, rows$Method, rows$Target, drop = TRUE)), function(z) {
    n <- nrow(z); a <- z$Available; nc <- sum(z$Covered, na.rm = TRUE)
    error <- z$Estimate - z$Truth; finite <- is.finite(error)
    aci <- interval(sum(a), n); cci <- interval(nc, sum(a)); jci <- interval(nc, n)
    data.frame(Cell = z$Cell[1], Method = z$Method[1], Target = z$Target[1], Assigned = n,
      FinitePoints = if (z$Method[1] == "bounded_reference") NA_integer_ else sum(finite),
      Available = sum(a), Covered = nc, Availability = mean(a),
      AvailabilityLower = aci[1], AvailabilityUpper = aci[2],
      Coverage = if (any(a)) nc / sum(a) else NA_real_, CoverageLower = cci[1], CoverageUpper = cci[2],
      AvailableAndCovered = nc / n, DeliveryLower = jci[1], DeliveryUpper = jci[2],
      BiasAllFinite = if (any(finite)) mean(error[finite]) else NA_real_,
      BiasMCSE = mcse(error[finite]),
      RMSEAllFinite = if (any(finite)) sqrt(mean(error[finite]^2)) else NA_real_,
      BiasAvailable = if (any(a & finite)) mean(error[a & finite]) else NA_real_,
      EmpiricalSD = if (sum(a & finite) > 1) sd(error[a & finite]) else NA_real_,
      RMSSE = if (any(a) && all(is.finite(z$SE[a]))) sqrt(mean(z$SE[a]^2)) else NA_real_,
      MeanWidth = if (any(a)) mean(z$Upper[a] - z$Lower[a]) else NA_real_,
      Informative = if (all(is.na(z$Informative))) NA_integer_ else sum(z$Informative, na.rm = TRUE))
  })
  pairs <- lapply(split(rows[rows$Method != "bounded_reference", ],
    interaction(rows$Cell[rows$Method != "bounded_reference"], rows$Target[rows$Method != "bounded_reference"], drop = TRUE)), function(z) {
    o <- z[z$Method == "ordinary_delta", ]; j <- z[z$Method == "jeffreys_delta", ]
    j <- j[match(o$Replication, j$Replication), ]; stopifnot(identical(o$Replication, j$Replication))
    finite <- is.finite(o$Estimate) & is.finite(j$Estimate); available <- o$Available & j$Available
    error_difference <- j$Estimate[finite] - o$Estimate[finite]
    squared_difference <- (j$Estimate[finite] - j$Truth[finite])^2 - (o$Estimate[finite] - o$Truth[finite])^2
    coverage_difference <- as.integer(j$Covered[available]) - as.integer(o$Covered[available])
    data.frame(Cell = o$Cell[1], Target = o$Target[1], Assigned = nrow(o), BothFinite = sum(finite),
      BothAvailable = sum(available), MeanErrorDifference = if (any(finite)) mean(error_difference) else NA_real_,
      ErrorDifferenceMCSE = mcse(error_difference),
      MSEDifference = if (any(finite)) mean(squared_difference) else NA_real_,
      MSEDifferenceMCSE = mcse(squared_difference),
      CoverageDifference = if (any(available)) mean(coverage_difference) else NA_real_,
      CoverageDifferenceMCSE = mcse(coverage_difference))
  })
  list(summary = do.call(rbind, summaries), paired = do.call(rbind, pairs), rows = rows)
}

fair_penalized_main <- function(mode, output_root) {
  out <- file.path(output_root, "consistent-estimator-pilot")
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  expected <- fair_penalized_allocation(); cells <- fair_coverage_cells()
  files <- c(list.files("R", pattern = "[.]R$", full.names = TRUE), "src/mfrmr.dll",
    "inst/validation/fair-reference-coverage-0.2.4.R", "inst/validation/fair-reference-coverage-protocol-0.2.4.md")
  identity <- list(md5 = tools::md5sum(files), R = R.version.string,
    Matrix = as.character(packageVersion("Matrix")), allocation = expected, cells = cells)
  manifest <- file.path(out, "manifest.rds")
  if (file.exists(manifest)) {
    if (!identical(readRDS(manifest), identity)) stop("Pilot source/environment changed; preserve this epoch.")
  } else {
    dir.create(file.path(out, "source-binding"), showWarnings = FALSE)
    stopifnot(all(file.copy(files, file.path(out, "source-binding", basename(files)))))
    saveRDS(identity, manifest)
  }
  records <- vector("list", nrow(expected))
  for (i in seq_len(nrow(expected))) {
    job <- expected[i, ]; file <- file.path(out, sprintf("cell-%02d-rep-%04d.rds", job$Cell, job$Replication))
    if (!file.exists(file)) {
      if (mode == "penalized-summary") stop("Missing assigned result: ", file)
      z <- fair_penalized_one(cells[job$Cell, ], job$Replication)
      saveRDS(z, file)
      cat(sprintf("pilot %d/%d cell=%02d rep=%02d available=%d/9 seconds=%.2f\n",
        i, nrow(expected), job$Cell, job$Replication, sum(z$rows$Available), z$seconds)); flush.console()
    }
    records[[i]] <- readRDS(file)
  }
  result <- fair_penalized_summary(records, expected)
  for (name in names(result)) write.csv(result[[name]], file.path(out, paste0(name, ".csv")), row.names = FALSE)
  saveRDS(list(result = result, expected = expected, session = sessionInfo(),
    seconds = vapply(records, `[[`, 0, "seconds")), file.path(out, "complete.rds"))
  cat("Fixed pilot complete. No automatic coverage or CIEligible qualification.\n")
}

fair_coverage_main <- function(args) {
  mode <- if (length(args)) args[1] else "check"
  .libPaths(c("tmp/manual-crosscheck-20261023/rlib", .libPaths()))
  pkgload::load_all(".", helpers = FALSE, attach_testthat = FALSE, compile = FALSE)
  cells <- fair_coverage_cells()
  if (mode %in% c("penalized-pilot", "penalized-summary")) {
    output_root <- if (length(args) >= 2) args[2] else "tmp/native-compatibility-20261024/fair-coverage"
    return(fair_penalized_main(mode, output_root))
  }
  if (mode == "check") {
    for (i in seq_len(nrow(cells))) {
      d <- fair_coverage_design(cells[i, ])
      stopifnot(max(abs(rowSums(d$probabilities) - 1)) < 1e-14)
      eta <- d$theta[as.integer(sub("P", "", d$data$Person))] -
        d$severity[match(d$data$Rater, paste0("R", seq_along(d$severity)))] -
        d$difficulty[match(d$data$Criterion, paste0("C", 1:3))]
      cumulative <- t(apply(d$steps, 1, function(x) c(0, cumsum(x))))
      native <- mfrmr:::mfrm_jml_probability_bundle(eta, rep(0L, nrow(d$data)), "PCM",
        cumulative, criterion_idx = match(d$data$Criterion, paste0("C", 1:3)))$probs
      stopifnot(max(abs(native - d$probabilities)) < 1e-13)
    }
    for (i in which(cells$Design == "strong_overlap")) {
      strong <- fair_coverage_design(cells[i, ])
      weak <- fair_coverage_design(cells[i - 6L, ])
      stopifnot(identical(strong$theta, weak$theta), identical(strong$severity, weak$severity),
        identical(strong$steps, weak$steps), identical(strong$maps, weak$maps),
        identical(strong$truth, weak$truth), identical(strong$plan, weak$plan))
      for (rows in c(strong$maps, list(union=seq_len(nrow(strong$data))))) {
        stopifnot(identical(table(strong$data$Person[rows]), table(weak$data$Person[rows])),
          identical(table(strong$data$Rater[rows], strong$data$Criterion[rows]),
            table(weak$data$Rater[rows], weak$data$Criterion[rows])))
        gap <- function(d) {
          incidence <- table(d$Person, d$Rater) > 0
          W <- crossprod(incidence); diag(W) <- 0
          D <- diag(1 / sqrt(rowSums(W)))
          sort(eigen(diag(nrow(W)) - D %*% W %*% D, symmetric=TRUE, only.values=TRUE)$values)[2]
        }
        stopifnot(gap(strong$data[rows, ]) > gap(weak$data[rows, ]))
      }
    }
    fixture <- expand.grid(Target = c("A", "B", "difference"),
      Method = c("estimated_delta", "fixed_anchor_delta"), Replication = 1:2, stringsAsFactors = FALSE)
    fixture$Cell <- 1L; fixture$Truth <- fixture$Estimate <- 0
    fixture$Available <- fixture$Replication == 1L
    fixture$SE <- ifelse(fixture$Available, 1, NA_real_)
    fixture$Lower <- -fixture$SE; fixture$Upper <- fixture$SE
    fixture$Covered <- ifelse(fixture$Available, TRUE, NA)
    expected <- data.frame(Cell = 1L, Replication = 1:2)
    result <- fair_coverage_summary(list(list(rows = fixture)), expected)
    stopifnot(all(result$Assigned == 2), all(result$Available == 1),
      all(result$Coverage == 1), all(result$AvailableAndCovered == .5))
    rejected <- function(x) inherits(try(fair_coverage_summary(list(list(rows = x)), expected), silent = TRUE), "try-error")
    stopifnot(rejected(fixture[-1, ]), rejected(rbind(fixture, fixture[1, ])),
      rejected(fixture[fixture$Replication == 1, ]))
    fixture$Available <- FALSE; fixture$Covered <- NA
    missing <- fair_coverage_summary(list(list(rows = fixture)), expected)
    stopifnot(all(is.na(missing$Coverage)), all(missing$Available == 0))
    cat("All 24 generator/kernel and response-map checks, matched connectivity controls, failure denominators and missing-result guards passed.\n")
    return(invisible(cells))
  }
  if (!mode %in% c("preflight", "run", "summary")) stop("Choose check, preflight, run or summary.")
  phase <- if (mode == "preflight") "preflight" else "confirmation"
  output_root <- if (length(args) >= 3) args[3] else "tmp/native-compatibility-20261024/fair-coverage"
  out <- file.path(output_root, phase)
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  files <- c(list.files("R", pattern = "[.]R$", full.names = TRUE), "src/mfrmr.dll",
    "inst/validation/fair-reference-coverage-0.2.4.R", "inst/validation/fair-reference-coverage-protocol-0.2.4.md")
  identity <- list(md5 = tools::md5sum(files), R = R.version.string,
    Matrix = as.character(packageVersion("Matrix")), cells = cells,
    replications = if (phase == "preflight") 2L else 2000L)
  manifest <- file.path(out, "manifest.rds")
  if (file.exists(manifest)) {
    if (!identical(readRDS(manifest), identity)) stop("Source/environment/protocol changed; retain this epoch and create a separately reviewed one.")
  } else saveRDS(identity, manifest)
  selected <- if (length(args) >= 2) as.integer(strsplit(args[2], ",", fixed = TRUE)[[1]]) else cells$Cell
  if (anyNA(selected) || anyDuplicated(selected) || any(!selected %in% cells$Cell)) stop("Invalid cell IDs.")
  if (mode == "run" && length(args) < 2) stop("Select a priced complete comparison explicitly; no default broad confirmation launch.")
  expected <- expand.grid(Replication = seq_len(identity$replications), Cell = selected)
  expected <- expected[order(expected$Cell, expected$Replication), c("Cell", "Replication")]
  rownames(expected) <- NULL
  records <- vector("list", nrow(expected))
  for (i in seq_len(nrow(expected))) {
    job <- expected[i, ]; file <- file.path(out, sprintf("cell-%02d-rep-%04d.rds", job$Cell, job$Replication))
    if (!file.exists(file)) {
      if (mode == "summary") stop("Missing result: ", file)
      result <- fair_coverage_one(cells[job$Cell, ], job$Replication, phase)
      saveRDS(result, file)
      cat(sprintf("cell=%02d rep=%04d available=%d/6 seconds=%.2f\n", job$Cell, job$Replication,
        sum(result$rows$Available), result$seconds)); flush.console()
    }
    records[[i]] <- readRDS(file)
  }
  summary <- fair_coverage_summary(records, expected)
  write.csv(summary, file.path(out, "summary.csv"), row.names = FALSE)
  reasons <- do.call(rbind, lapply(records, function(x) x$rows[c("Cell", "Replication", "Method", "Target", "Available", "Reason")]))
  write.csv(reasons, file.path(out, "reasons.csv"), row.names = FALSE)
  saveRDS(list(summary = summary, expected = expected, seconds = vapply(records, `[[`, 0, "seconds"),
    session = sessionInfo(), phase = phase), file.path(out, "summary.rds"))
  cat("Complete selected allocation summarized; phase = ", phase, ". No automatic qualification.\n", sep = "")
}

if (sys.nframe() == 0L) fair_coverage_main(commandArgs(trailingOnly = TRUE))
