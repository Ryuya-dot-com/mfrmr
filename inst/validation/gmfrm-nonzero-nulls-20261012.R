# Observed-data prerequisite for inversion; no random generation or resampling.
# Run prepare, fit, replay with the four thread limits below set to 1.
args <- commandArgs(TRUE)
stopifnot(length(args) == 1L, args %in% c("prepare", "fit", "replay"))
action <- args[[1L]]
base <- "validation-results/gmfrm-regularized-feasibility-20261012"
directory <- file.path(base, "nonzero-nulls")
script <- "inst/validation/gmfrm-nonzero-nulls-20261012.R"
manifest <- file.path(directory, "manifest.rds")
threads <- c("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")
check_hash <- function(h) stopifnot(length(h) > 0L, !anyNA(h),
  identical(h, tools::md5sum(names(h))))
blocked <- function(...) stop("Random generation is outside this observed-data check.")
for (n in c("rnorm", "runif", "rbinom")) assignInNamespace(n, blocked, "stats")
m <- readRDS(file.path(base, "manifest.rds"))
check_hash(m$inputs); check_hash(m$source)
stopifnot(identical(m$R, R.version), identical(m$threads, Sys.getenv(threads)),
  identical(m$packages, vapply(names(m$packages), function(p) as.character(packageVersion(p)), "")))
library(mfrmr, lib.loc = file.path(base, "library"))
stopifnot(identical(normalizePath(find.package("mfrmr")), normalizePath(file.path(base, "library/mfrmr"))))
fn <- function(n) get(n, asNamespace("mfrmr"))
# Reuse the exact frozen definitions without executing their old top-level jobs.
definitions <- c("capture", "mapping", "setup", "coordinates", "evaluator", "finite_difference", "minimize")
loaded <- character()
for (e in parse(file.path(base, "source.R"))) {
  if (is.call(e) && identical(e[[1L]], as.name("<-")) && is.symbol(e[[2L]]) &&
      as.character(e[[2L]]) %in% definitions) {
    stopifnot(is.call(e[[3L]]), identical(e[[3L]][[1L]], as.name("function")))
    eval(e); loaded <- c(loaded, as.character(e[[2L]]))
  }
}
stopifnot(identical(sort(loaded), sort(definitions)))
ref <- new.env(parent = asNamespace("mfrmr"))
sys.source(file.path(base, "pattern-reference.R"), ref)
write_result <- function(x, file) {
  saveRDS(x, paste0(file, ".tmp"))
  stopifnot(file.rename(paste0(file, ".tmp"), file))
}
if (action == "prepare") {
  stopifnot(!file.exists(manifest))
  retained <- readRDS(file.path(base, "replay.rds")); check_hash(retained$outputs)
  patterns <- readRDS(file.path(base, "pattern-check.rds"))
  check_hash(patterns$inputs); check_hash(patterns$source)
  stopifnot(all(retained$summary$Qualified), all(patterns$summary$Qualified))
  dir.create(directory, recursive = TRUE)
  frozen <- file.path(directory, "source.R"); stopifnot(file.copy(script, frozen))
  checks <- list()
  for (case in names(m$cases)) {
    s <- setup(case); T <- s$T
    C <- as.numeric(rownames(T) == "location:Task:t1") - as.numeric(rownames(T) == "location:Task:t2")
    c <- drop(C %*% T)
    # The extracted evaluator must reproduce the saved zero-null fixed stage.
    zero <- readRDS(file.path(base, paste0(case, "-null.rds")))
    stage <- zero$attempts$zero$stages$fixed$value
    baseline <- evaluator(s$likelihood$fixed, T, coordinates(T, TRUE))$evaluate(stage$u)
    stopifnot(isTRUE(all.equal(baseline, stage$state, tolerance = 1e-12)))
    for (target in c(-1, 1)) {
      co <- coordinates(T, TRUE, target); u <- .25 * cos(seq_len(ncol(co$U)))
      ev <- evaluator(s$likelihood$fixed, T, co); at <- ev$evaluate(u)
      fd <- lapply(c(1e-5, 5e-6), function(h)
        finite_difference(function(v) ev$evaluate(v)$value, u, h))
      errors <- c(Constraint = abs(sum(C * at$par) - target),
        OrthogonalOrigin = max(abs(crossprod(co$U, co$origin))),
        Penalty = abs(sum(at$z^2) - sum(u^2) - target^2 / sum(c^2)),
        ConstantPenalty = abs(at$value - at$nll - m$controls$lambda *
          (sum(u^2) + target^2 / sum(c^2)) / 2),
        Gradient = max(abs(at$gradient - fd[[1L]])),
        GradientHalfStep = max(abs(at$gradient - fd[[2L]])))
      stopifnot(all(errors[1:4] < 1e-10), all(errors[5:6] < 1e-5))
      checks[[paste(case, target)]] <- errors
    }
  }
  jobs <- expand.grid(Case = names(m$cases), Target = c(-1, 1), stringsAsFactors = FALSE)
  jobs$File <- paste0(jobs$Case, ifelse(jobs$Target < 0, "-minus", "-plus"), ".rds")
  plan <- list(jobs = jobs, checks = do.call(rbind, checks),
    controls = m$controls[setdiff(names(m$controls), "null")],
    contrast = "location:Task:t1 - location:Task:t2",
    inputs = tools::md5sum(unique(c(file.path(base, c("manifest.rds", "replay.rds", "pattern-check.rds")),
      names(m$inputs), names(retained$outputs)))),
    source = c(tools::md5sum(c(frozen, file.path(base, "pattern-reference.R"))), m$source),
    R = R.version, threads = Sys.getenv(threads), session = sessionInfo(), definitions = definitions)
  write_result(plan, manifest)
  print(apply(plan$checks, 2L, max))
  cat("Prepared ten nonzero-null fits on five unchanged datasets; no free refits or random data.\n")
  quit(save = "no")
}
plan <- readRDS(manifest); check_hash(plan$inputs); check_hash(plan$source)
stopifnot(identical(plan$controls, m$controls[setdiff(names(m$controls), "null")]), identical(plan$R, R.version),
  identical(plan$threads, Sys.getenv(threads)),
  identical(unname(tools::md5sum(script)), unname(plan$source[1L])))
seal <- tools::md5sum(manifest)
if (action == "fit") {
  for (case in names(m$cases)) {
    pending <- subset(plan$jobs, Case == case)
    if (all(file.exists(file.path(directory, pending$File)))) next
    s <- setup(case)
    for (i in seq_len(nrow(pending))) {
      job <- pending[i, ]; file <- file.path(directory, job$File)
      if (file.exists(file)) { stopifnot(identical(readRDS(file)$manifest, seal)); next }
      co <- coordinates(s$T, TRUE, job$Target)
      starts <- list(zero = numeric(ncol(s$T)), cosine = .25 * cos(seq_len(ncol(s$T))))
      attempts <- list()
      for (name in names(starts)) {
        stages <- list(); u <- drop(crossprod(co$U, starts[[name]] - co$origin))
        for (method in c("fixed", "adaptive61", "adaptive121")) {
          ev <- evaluator(s$likelihood[[method]], s$T, co)
          stage <- capture(function() minimize(ev, u, s$problem$n_person))
          stages[[method]] <- stage
          if (!is.null(stage$error)) break
          u <- stage$value$u
          review <- capture(function() {
            other <- evaluator(s$likelihood$adaptive121, s$T, co)$evaluate(u)
            at <- stage$value$state
            list(state = other, value_difference = abs(at$value - other$value),
              gradient_difference = max(abs(at$full_gradient - other$full_gradient)))
          })
          stages[[paste0(method, "_review")]] <- review
          if (!is.null(review$error)) break
          r <- review$value
          if (r$value_difference <= m$controls$value_tolerance &&
              r$gradient_difference <= m$controls$integration_gradient_tolerance &&
              max(abs(r$state$gradient)) <= m$controls$gradient_tolerance) break
        }
        attempts[[name]] <- list(stages = stages, u = u)
        cat(case, job$Target, name, paste(names(stages), collapse = ","), "\n"); flush.console()
      }
      candidates <- lapply(attempts, function(a) capture(function()
        evaluator(s$likelihood$adaptive121, s$T, co)$evaluate(a$u)))
      values <- vapply(candidates, function(x) if (is.null(x$error)) x$value$value else Inf, 0)
      selected <- if (any(is.finite(values))) names(which.min(values)) else NA_character_
      reference <- if (!is.na(selected)) capture(function() {
        state <- candidates[[selected]]$value
        independent <- ref$mfrm_gmfrm_reference_integrate(ref$mfrm_gmfrm_reference_design(s$specification, state$par))
        full <- -drop(crossprod(s$T, independent$score)) + m$controls$lambda * state$z
        C <- as.numeric(rownames(s$T) == "location:Task:t1") - as.numeric(rownames(s$T) == "location:Task:t2")
        c <- drop(C %*% s$T)
        residual <- full - c * sum(c * full) / sum(c^2)
        list(reference = independent, state = state, gradient = drop(crossprod(co$U, full)),
          constraint_error = abs(sum(C * state$par) - job$Target),
          kkt_error = max(abs(residual - co$U %*% crossprod(co$U, full))),
          normal_gradient = sum(c * full) / sum(c^2),
          objective_error = abs(state$nll - independent$nll),
          gradient_error = max(abs(state$full_gradient - full)))
      }) else list(value = NULL, error = "No finite candidate", warnings = character(), seconds = 0)
      write_result(list(manifest = seal, case = case, target = job$Target, T = s$T,
        coordinate = co, attempts = attempts, candidates = candidates,
        selected = selected, reference = reference), file)
      cat("Saved", job$File, "reference error:", reference$error, "\n"); flush.console()
    }
  }
  quit(save = "no")
}

# Reconstruct decisions from retained states, without optimization or integration.
for (n in c("optim", "nlminb", "integrate")) assignInNamespace(n, blocked, "stats")
files <- file.path(directory, plan$jobs$File); stopifnot(all(file.exists(files)))
rows <- lapply(files, function(file) {
  x <- readRDS(file); stopifnot(identical(x$manifest, seal))
  free <- readRDS(file.path(base, paste0(x$case, "-free.rds")))$reference$value
  free_Q <- free$reference$nll + m$controls$lambda * sum(free$state$z^2) / 2
  r <- x$reference$value
  values <- vapply(x$candidates, function(a) if (is.null(a$error)) a$value$value else Inf, 0)
  zs <- lapply(x$candidates, function(a) if (is.null(a$error)) a$value$z else NA_real_)
  value_spread <- diff(range(values)); coordinate_spread <- max(abs(zs[[1L]] - zs[[2L]]))
  stages <- unlist(lapply(x$attempts, `[[`, "stages"), recursive = FALSE)
  records <- c(stages, x$candidates, list(x$reference))
  errors <- sum(vapply(records, function(v) !is.null(v$error), TRUE))
  warnings <- sum(vapply(records, function(v) length(v$warnings), 0L))
  q <- if (is.null(r)) NA_real_ else r$reference$nll + m$controls$lambda * sum(r$state$z^2) / 2
  good <- errors == 0L && !is.null(r) && isTRUE(r$reference$qualified) &&
    r$constraint_error < 1e-10 && r$kkt_error < 1e-10 &&
    r$objective_error <= m$controls$value_tolerance &&
    r$gradient_error <= m$controls$integration_gradient_tolerance &&
    max(abs(r$gradient)) <= m$controls$gradient_tolerance &&
    value_spread <= m$controls$start_value_tolerance &&
    coordinate_spread <= m$controls$start_coordinate_tolerance &&
    q >= free_Q - m$controls$value_tolerance
  data.frame(Case = x$case, Target = x$target, Qualified = isTRUE(good),
    Q = q, Statistic = 2 * (q - free_Q),
    MaxGradient = if (is.null(r)) NA_real_ else max(abs(r$gradient)),
    NLLCheck = if (is.null(r)) NA_real_ else r$objective_error,
    GradientCheck = if (is.null(r)) NA_real_ else r$gradient_error,
    ConstraintError = if (is.null(r)) NA_real_ else r$constraint_error,
    StartValueSpread = value_spread, StartCoordinateSpread = coordinate_spread,
    Errors = errors, Warnings = warnings,
    Seconds = sum(vapply(records, `[[`, 0, "seconds")))
})
table <- do.call(rbind, rows)
stopifnot(nrow(table) == 10L, all(table$Target %in% c(-1, 1)))
check_hash(plan$inputs); check_hash(plan$source)
write_result(list(manifest = seal, outputs = tools::md5sum(files), summary = table),
  file.path(directory, "replay.rds"))
print(table, digits = 6, row.names = FALSE)
cat("Retained all ten outcomes; no resampling, interval endpoints or coverage claims.\n")
