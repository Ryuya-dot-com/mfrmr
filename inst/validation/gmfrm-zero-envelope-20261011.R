# Saved-response arithmetic only: a global bound on the v=0 law and one
# explicit feasible limiting path. No optimization, integration or RNG.
# Run from package root: Rscript --vanilla this-file run | verify
# Between run and verify, run the matching Python high-precision reference.
ze_out <- "validation-results/gmfrm-zero-envelope-20261011"
ze_script <- "inst/validation/gmfrm-zero-envelope-20261011.R"
ze_reference <- "inst/validation/gmfrm-zero-envelope-reference-20261011.py"
ze_hash <- function(x) stopifnot(length(x) > 0, !anyNA(x), identical(x, tools::md5sum(names(x))))
ze_parent <- function(path) {
  x <- readRDS(path); if (inherits(x, "mfrm_fit")) x else x$payload$value
}
ze_likelihood <- function(step, count) {
  value <- 0
  for (i in seq_len(dim(count)[1])) for (r in seq_len(dim(count)[2])) {
    logits <- c(0, cumsum(step[i, r, ])); logits <- logits - max(logits)
    lp <- logits - log(sum(exp(logits))); keep <- count[i, r, ] > 0
    value <- value - sum(count[i, r, keep]*lp[keep])
  }
  value
}
ze_path <- function(z, count) {
  stopifnot(length(z) == 22L, z[22] == 0, identical(dim(count), c(3L, 6L, 3L)),
    all(count[3, c(3, 5, 6), 3] == 0), all(count[3, 1:2, ] > 0))
  b <- c(z[1:2], -sum(z[1:2])); a <- exp(c(z[15:16], -sum(z[15:16])))
  rho <- exp(c(z[17:21], -sum(z[17:21]))); w <- outer(a, rho)
  h <- cbind(z[3:8] + z[9:14], z[3:8] - z[9:14])
  base <- array(0, c(3, 6, 2))
  for (k in 1:2) base[, , k] <- -w*(b + rep(h[, k], each = 3))
  stopifnot(all(base[3, c(3, 5, 6), 2] < 0))
  # a1,a2 *= exp(-t); a3 *= exp(2t); rho[-4] *= exp(t);
  # rho4 *= exp(-5t). Both geometric means remain one. Keep B fixed.
  # For r!=4, k=1 (and k=2 for r1/r2), H=-B3+exp(-3t)*(B3+H0).
  # Other H stay fixed, except H4=-B3+exp(3t)*(B3+H40).
  # Recenter each H into S/T. The equivalent logits below avoid cancellation.
  values <- vapply(c(0, .5, 1, 2, 4, 8, Inf), function(t) {
    step <- base
    for (r in setdiff(1:6, 4)) for (k in 1:2) {
      if (k == 1L || r %in% 1:2)
        step[1:2, r, k] <- -w[1:2, r]*((b[1:2] - b[3]) + exp(-3*t)*(b[3] + h[r, k]))
      else step[3, r, k] <- exp(3*t)*base[3, r, k]
    }
    for (k in 1:2) step[1:2, 4, k] <- -w[1:2, 4]*(exp(-6*t)*(b[1:2] - b[3]) + exp(-3*t)*(b[3] + h[4, k]))
    ze_likelihood(step, count)
  }, 0)
  stopifnot(abs(values[1] - ze_likelihood(base, count)) < 1e-7)
  data.frame(Time = c(0, .5, 1, 2, 4, 8, Inf), NLL = values,
    DifferenceFromStart = values - values[1])
}

ze_calculate <- function() {
  pp <- "validation-results/gmfrm-zero-profile-20261011"
  vp <- "validation-results/gmfrm-variance-score-20261011"
  bp <- "validation-results/gmfrm-zero-backtrack-20261011"
  m <- readRDS(file.path(pp, "manifest.rds")); v <- readRDS(file.path(vp, "summary.rds"))
  vm <- readRDS(file.path(vp, "manifest.rds")); bs <- readRDS(file.path(bp, "summary.rds"))
  ze_hash(m$inputs); ze_hash(v$results); ze_hash(bs$results)
  interior <- lapply(names(v$results), readRDS)
  stopifnot(all(vapply(interior, function(r) identical(r$manifest, v$manifest), TRUE)))
  cases <- unique(m$jobs[c("Case", "Parent", "Draw")]); tables <- counts <- paths <- parameters <- list()
  for (j in seq_len(nrow(cases))) {
    job <- cases[j, ]; parent <- ze_parent(m$plan$Path[match(job$Parent, m$plan$Case)])
    spec <- parent$gmfrm$specification; d <- spec$data
    stopifnot(identical(spec$slope_facets, c("Task", "Rater")), spec$max_score == 2,
      all(parent$prep$data$Weight == 1))
    if (job$Draw != "observed") d[[spec$score]] <- readRDS(file.path(
      "validation-results/gmfrm-null-bootstrap-20261010", job$Parent,
      paste0(job$Draw, "-generation.rds")))$value$score
    count <- table(factor(d$Task, levels = paste0("t", 1:3)),
      factor(d$Rater, levels = paste0("r", 1:6)), factor(d[[spec$score]], levels = 0:2))
    totals <- apply(count, c(1, 2), sum); keep <- count > 0
    lp <- log(sweep(count, c(1, 2), totals, "/"))
    lower <- -sum(count[keep]*lp[keep])
    # Check aggregation against the likelihood of the labelled raw responses.
    at <- cbind(match(d$Task, paste0("t", 1:3)), match(d$Rater, paste0("r", 1:6)), d[[spec$score]] + 1)
    stopifnot(abs(lower + sum(lp[at])) < 1e-9)
    cc <- as.data.frame(count); names(cc) <- c("Task", "Rater", "Category", "Count")
    counts[[job$Case]] <- cbind(Case = job$Case, cc)
    for (kind in c("free", "null")) {
      available <- Filter(function(r) r$status == "qualified" &&
        startsWith(r$key, paste0(job$Case, "-")) &&
        (kind == "free" || startsWith(r$key, paste0(job$Case, "-null-"))), interior)
      stopifnot(length(available) > 0L)
      candidate <- available[[which.min(vapply(available, function(r) r$value$value, 0))]]
      stopifnot(all(is.finite(candidate$coordinates)), tail(candidate$coordinates, 1) > 0,
        all(candidate$checks <= c(1e-7, 1e-6, 1e-8, 1e-6)))
      if (kind == "null") stopifnot(candidate$coordinates[15] == parent$opt$par[15] + .5)
      tables[[paste(job$Case, kind)]] <- data.frame(Case = job$Case, Kind = kind,
        SaturatedLowerNLL = lower, InteriorKey = candidate$key, InteriorNLL = candidate$value$value,
        Margin = lower - candidate$value$value,
        Excluded = lower - candidate$value$value > 1e-6)
    }
    if (job$Case == "N20-b09") for (start in c("retained", "neutral", "chart_neutral")) {
      key <- paste0("N20-b09-free-", start)
      record <- readRDS(file.path(bp, paste0("fit-", key, ".rds")))
      stopifnot(identical(record$manifest, bs$manifest))
      z <- record$fit$selected$evaluation$parameters
      path <- ze_path(z, unclass(count))
      stopifnot(abs(path$NLL[1] - record$fit$selected$evaluation$value) < 1e-7)
      paths[[start]] <- cbind(Start = start, path)
      parameters[[start]] <- data.frame(Start = start, Coordinate = seq_along(z),
        Value = sprintf("%.17g", z))
    }
  }
  list(table = do.call(rbind, tables), counts = do.call(rbind, counts),
    paths = do.call(rbind, paths), parameters = do.call(rbind, parameters),
    inputs = tools::md5sum(unique(c(file.path(pp, "manifest.rds"),
      file.path(vp, c("manifest.rds", "summary.rds", "verification.rds")),
      file.path(bp, c("manifest.rds", "summary.rds", "verification.rds")),
      names(m$inputs), names(v$results), names(bs$results)))),
    sources = tools::md5sum(c(ze_script, ze_reference)))
}

if (sys.nframe() == 0L) {
  action <- commandArgs(trailingOnly = TRUE); stopifnot(action %in% c("run", "verify"))
  # Fail loudly if this saved-arithmetic audit accidentally acquires numerical work.
  blocked <- function(...) stop("Saved-arithmetic audit attempted fitting, integration or generation.")
  for (name in c("optim", "optimHess", "nlminb", "integrate", "uniroot", "rnorm"))
    assignInNamespace(name, blocked, ns = "stats")
  assignInNamespace("load_all", blocked, ns = "pkgload")
  result <- ze_calculate(); dest <- file.path(ze_out, "results.rds")
  if (action == "run") {
    stopifnot(!file.exists(dest)); dir.create(ze_out, recursive = TRUE, showWarnings = FALSE)
    saveRDS(result, dest)
    for (name in c("table", "counts", "paths", "parameters"))
      write.csv(result[[name]], file.path(ze_out, paste0(name, ".csv")), row.names = FALSE)
  } else {
    saved <- readRDS(dest); ze_hash(saved$inputs); ze_hash(saved$sources)
    stopifnot(identical(saved, result))
    ref <- read.csv(file.path(ze_out, "reference.csv"))
    expected <- rbind(data.frame(Key = paste0("bound-", result$table$Case), NLL = result$table$SaturatedLowerNLL),
      data.frame(Key = paste0(result$paths$Start, "-", result$paths$Time), NLL = result$paths$NLL))
    expected <- unique(expected); at <- match(expected$Key, ref$Key)
    stopifnot(!anyNA(at), !anyDuplicated(ref$Key), nrow(ref) == nrow(expected))
    discrepancy <- max(abs(expected$NLL - ref$NLL[at]))
    stopifnot(discrepancy < 1e-7, all(ref$MaxConstraintError < 1e-80))
    saveRDS(list(results = tools::md5sum(dest), reference = tools::md5sum(file.path(ze_out, "reference.csv")),
      maximum_reference_difference = discrepancy, session = sessionInfo(),
      note = "Fresh saved-arithmetic replay; numerical work disabled. No optimality or coverage qualification."),
      file.path(ze_out, "verification.rds"))
    cat("Fresh replay and 100-digit reference passed; maximum NLL discrepancy", discrepancy, "\n")
  }
  print(result$table, row.names = FALSE, digits = 10)
  print(result$paths, row.names = FALSE, digits = 12)
}
