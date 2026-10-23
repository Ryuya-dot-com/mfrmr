# Frozen reduced common-zero search. No response generation or public fitting.
# Rscript --vanilla this-file prepare | run | summarize | verify
source("inst/validation/gmfrm-zero-location-20261011.R")
zp_script <- "inst/validation/gmfrm-zero-profile-20261011.R"
zp_out <- "validation-results/gmfrm-zero-profile-20261011"
zp_literal_source <- file.path(zl_out, "complex-review.R")
zp_literal <- eval(Filter(function(e) is.call(e) && identical(e[[1]], as.name("<-")) &&
  identical(e[[2]], as.name("literal")), parse(zp_literal_source))[[1]][[3]])

zp_default_unchanged <- function() {
  old <- readLines(file.path(zl_out, "epoch-source/R/core-gmfrm-zero-location.R"))
  now <- readLines("R/core-gmfrm-zero-location.R")
  now <- sub("evaluate <- function(location_value, profile = FALSE)",
    "evaluate <- function(location_value)", now, fixed = TRUE)
  begin <- which(grepl("^    answer <- list", now)); end <- which(now == "    answer")
  stopifnot(length(begin) == 1L, length(end) == 1L)
  now <- c(now[seq_len(begin - 1L)], sub("answer <- ", "", now[begin], fixed = TRUE),
    now[seq.int(end + 1L, length(now))])
  stopifnot(identical(now, old)); TRUE
}

zp_table <- function(records) {
  out <- do.call(rbind, lapply(records, function(r) {
    a <- if (is.null(r$fit)) NULL else r$fit$selected$evaluation
    data.frame(Key = r$key, Status = r$status,
      NLL = if (is.null(a)) NA_real_ else a$value,
      OuterScore = if (is.null(a)) NA_real_ else max(abs(a$gradient)),
      LocationScore = if (is.null(a)) NA_real_ else max(abs(a$inner$evaluation$gradient)),
      Code = if (is.null(r$fit$optimizer)) NA_integer_ else r$fit$optimizer$convergence,
      Outward = r$outward, Independent = r$independent,
      InnerSolves = r$diagnostics$inner_solves, FailedPoints = r$diagnostics$failed_points,
      Seconds = r$seconds, Error = r$error)
  })); rownames(out) <- NULL; out
}

zp_review <- function(a, profile, natural, spec) {
  z <- a$parameters; at <- seq_len(length(z) - 1L)
  full <- natural$evaluate(z)
  gradients <- lapply(c(1e-20, 1e-24), function(h) vapply(at, function(j)
    Im(zp_literal(replace(as.complex(z), j, z[j] + 1i*h), spec))/h, 0))
  literal_value <- Re(zp_literal(as.complex(z), spec))
  outward <- nat_boundary_reference(z, "common_scale", spec, natural$natural)
  checks <- c(NLL = max(abs(c(full$value, literal_value, outward[1]) - a$value)),
    Gradient = max(abs(full$gradient[at] - gradients[[1]]), abs(full$gradient[at] - gradients[[2]]),
      abs(a$gradient - gradients[[1]][profile$free])),
    Outward = abs(full$gradient[natural$natural] - outward[2]))
  review <- list(checks = unname(checks), outward = unname(full$gradient[natural$natural]),
    complex_step_difference = max(abs(gradients[[1]] - gradients[[2]])),
    hessian_error = "", curvature_ok = FALSE)
  tryCatch({
    x <- z[profile$free]
    H <- lapply(c(1e-4, 5e-5), function(h) vapply(seq_along(x), function(j) {
      step <- replace(x*0, j, h*max(1, abs(x[j])))
      (profile$gradient(x + step) - profile$gradient(x - step))/(2*step[j])
    }, numeric(length(x))))
    symmetric <- lapply(H, function(x) (x + t(x))/2)
    spread <- norm(symmetric[[1]] - symmetric[[2]], "2")
    relative <- norm(a$hessian - (4*symmetric[[2]] - symmetric[[1]])/3, "2")/max(1, norm(a$hessian, "2"))
    eigenvalues <- eigen((a$hessian + t(a$hessian))/2, symmetric = TRUE, only.values = TRUE)$values
    tolerance <- max(1e-7*max(1, max(abs(eigenvalues))), 10*spread)
    review$curvature <- c(MinEigen = min(eigenvalues), MaxEigen = max(eigenvalues),
      RelativeDifference = relative, StepDifference = spread, NegativeResolution = tolerance)
    review$curvature_ok <- relative <= 1e-5 && min(eigenvalues) >= -tolerance
  }, error = function(e) review$hessian_error <<- conditionMessage(e))
  review
}

zp_main <- function(action) {
  stopifnot(action %in% c("prepare", "run", "summarize", "verify"))
  path <- file.path(zp_out, "manifest.rds")
  if (action == "prepare") {
    stopifnot(!file.exists(path)); zp_default_unchanged()
    old <- readRDS(file.path(zl_out, "manifest.rds")); s <- readRDS(file.path(zl_out, "summary.rds"))
    seg_hash_check(old$inputs); seg_hash_check(s$results)
    seg_hash_check(old$sources[names(old$sources) != "R/core-gmfrm-zero-location.R"])
    archive <- tools::md5sum(file.path(zl_out, "epoch-source", names(old$sources)))
    names(archive) <- names(old$sources); stopifnot(identical(archive, old$sources))
    complex <- readRDS(file.path(zl_out, "complex-review.rds")); seg_hash_check(complex$script); seg_hash_check(complex$results)
    jobs <- subset(old$jobs, LocationStart == "saved")
    jobs$LocationPath <- file.path(zl_out, paste0("fit-", jobs$Key, ".rds"))
    jobs$Key <- sub("-saved$", "", jobs$Key)
    stopifnot(nrow(jobs) == 30L, !anyDuplicated(jobs$Key))
    pkgload::load_all(quiet = TRUE, compile = FALSE)
    sources <- unique(c(names(old$sources), zp_script, "R/core-gmfrm-zero-profile.R",
      "tests/testthat/test-gmfrm-zero-profile.R"))
    m <- list(jobs = jobs, plan = old$plan, sources = tools::md5sum(sources),
      inputs = tools::md5sum(unique(c(names(old$inputs), names(s$results), zp_literal_source,
        file.path(zl_out, c("manifest.rds", "summary.rds", "verification.rds", "complex-review.rds"))))),
      session = sessionInfo(), threads = old$threads,
      policy = c("30 profile continuations: saved inner endpoints for retained/neutral; actual chart-neutral reset for third start.",
        "Original Task-t1 null and v=0; private inner maxit80 and checks unchanged, warm qualified then zero.",
        "Analytic envelope/Schur derivatives; first-order inner-gradient correction<=1e-6, no exact error-bound claim.",
        "Existing L-BFGS-B maxit400 factr1 pgtol1e-8 lmm20 fnscaleN parscale max(1,abs(initial outer)).",
        "Terminal independent NLL<=1e-7; full nonvariance complex scores<=1e-6; outward<=1e-6; free outer score<=1e-4.",
        "Profile Hessian FD at 1e-4,5e-5 scaled steps; relative spectral error<=1e-5; resolved negative curvature excludes minimum.",
        "Original target error zero; preserve errors/code status; start NLL spread<=1e-5 and outward descent separate.",
        "No new responses, interior/individual boundary fitting, LR calibration, global certificate or public adoption."))
    stopifnot(identical(Sys.getenv(names(m$threads)), m$threads))
    dir.create(zp_out, recursive = TRUE, showWarnings = FALSE); saveRDS(m, path)
    for (s in sources) {
      dest <- file.path(zp_out, "epoch-source", s); dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
      stopifnot(file.copy(s, dest, overwrite = FALSE))
    }
    return(invisible(NULL))
  }
  m <- readRDS(path); seal <- tools::md5sum(path); seg_hash_check(m$inputs)
  files <- file.path(zp_out, paste0("fit-", m$jobs$Key, ".rds"))
  if (action %in% c("summarize", "verify")) {
    records <- lapply(files, readRDS); table <- zp_table(records)
    stopifnot(all(vapply(records, function(r) identical(r$manifest, seal), TRUE)))
    if (action == "verify") {
      seg_hash_check(m$sources); zp_default_unchanged()
      archive <- tools::md5sum(file.path(zp_out, "epoch-source", names(m$sources)))
      names(archive) <- names(m$sources); stopifnot(identical(archive, m$sources))
      s <- readRDS(file.path(zp_out, "summary.rds")); seg_hash_check(s$results)
      stopifnot(identical(s$manifest, seal), identical(s$attempts, table))
      for (r in records) if (r$status == "stationary_profile_candidate") stopifnot(
        r$independent, r$fixed_error == 0, r$fit$checks[1] <= 1e-4,
        r$review$curvature_ok, r$fit$optimizer$convergence == 0L,
        r$fit$selected$evaluation$inner$status == "stationary_convex_candidate")
      aggregates <- file.path(zp_out, c("summary.rds", "attempts.csv")); before <- tools::md5sum(aggregates)
      zp_main("summarize"); stopifnot(identical(before, tools::md5sum(aggregates)))
      saveRDS(list(manifest = seal, sources = m$sources, inputs = m$inputs, results = s$results,
        aggregates = before, default_location_arithmetic_unchanged = TRUE, session = sessionInfo()),
        file.path(zp_out, "verification.rds"))
      cat("Fresh replay, all bindings, archives and unchanged default location arithmetic passed.\n")
      return(invisible(NULL))
    }
    saveRDS(list(manifest = seal, results = tools::md5sum(files), attempts = table), file.path(zp_out, "summary.rds"))
    write.csv(table, file.path(zp_out, "attempts.csv"), row.names = FALSE)
    print(table, row.names = FALSE); return(invisible(NULL))
  }
  seg_hash_check(m$sources); stopifnot(identical(Sys.getenv(names(m$threads)), m$threads))
  pkgload::load_all(quiet = TRUE, compile = FALSE); stopifnot(identical(sessionInfo(), m$session))
  for (j in seq_len(nrow(m$jobs))) {
    if (file.exists(files[j])) { stopifnot(identical(readRDS(files[j])$manifest, seal)); next }
    job <- m$jobs[j, ]; previous <- readRDS(job$LocationPath)
    parent <- seg_parent(m$plan$Path[match(job$Parent, m$plan$Case)])
    score <- if (job$Draw != "observed") readRDS(file.path(seg_old, job$Parent,
      paste0(job$Draw, "-generation.rds")))$value$score else NULL
    x <- est_context(parent, score)
    idx <- est_fn("build_indices")(x$fit$prep, x$config$step_facet, x$config$slope_facet,
      x$config$interaction_specs, gpcm_spec = x$config$gpcm_spec)
    z <- previous$parameters; alpha <- build_param_slices(x$sizes)$log_slopes[1L]
    fixed <- if (job$Kind == "null") alpha else integer()
    if (job$Start == "chart_neutral") z[] <- 0
    if (length(fixed)) z[fixed] <- parent$opt$par[fixed] + .5
    profile <- est_fn("mfrm_gmfrm_zero_profile_evaluator")(z, idx, x$config, x$sizes, fixed)
    r <- list(manifest = seal, key = job$Key, status = "unresolved", error = "",
      independent = FALSE, outward = NA_real_, fixed_error = NA_real_)
    timing <- system.time(tryCatch({
      checkpoint <- paste0(files[j], ".search")
      if (file.exists(checkpoint)) {
        r <- readRDS(checkpoint); stopifnot(identical(r$manifest, seal), identical(r$key, job$Key))
      } else {
        r$fit <- est_fn("mfrm_gmfrm_natural_search")(profile$start, profile)
        r$error <- r$fit$error; r$diagnostics <- profile$diagnostics()
        saveRDS(r, paste0(checkpoint, ".tmp")); stopifnot(file.rename(paste0(checkpoint, ".tmp"), checkpoint))
      }
      a <- r$fit$selected$evaluation
      natural <- est_fn("mfrm_gmfrm_natural_evaluator")(idx, x$config, x$sizes, "common_scale")
      reviewer <- est_fn("mfrm_gmfrm_zero_profile_evaluator")(a$parameters, idx, x$config, x$sizes, fixed)
      r$review <- zp_review(a, reviewer, natural, x$fit$gmfrm$specification)
      r$independent <- all(r$review$checks <= c(1e-7, 1e-6, 1e-6))
      r$outward <- r$review$outward
      r$fixed_error <- max(abs(a$parameters[c(fixed, length(z))] - z[c(fixed, length(z))]))
      if (r$independent && r$fixed_error == 0 && r$fit$checks[1] <= 1e-4 &&
          r$review$curvature_ok && !is.null(r$fit$optimizer) && r$fit$optimizer$convergence == 0L && !nzchar(r$error))
        r$status <- "stationary_profile_candidate"
    }, error = function(e) r$error <<- conditionMessage(e)))
    if (is.null(r$diagnostics)) r$diagnostics <- profile$diagnostics()
    r$seconds <- unname(timing["elapsed"])
    saveRDS(r, paste0(files[j], ".tmp")); stopifnot(file.rename(paste0(files[j], ".tmp"), files[j]))
    cat(job$Key, r$status, r$seconds, r$error, "\n"); flush.console()
  }
}
if (sys.nframe() == 0L) {
  action <- commandArgs(trailingOnly = TRUE)
  if (identical(action, "verify")) {
    blocked <- function(...) stop("Read-only verification attempted numerical work.")
    for (name in c("optim", "optimHess", "nlminb", "integrate", "uniroot", "rnorm")) assignInNamespace(name, blocked, ns = "stats")
    assignInNamespace("load_all", blocked, ns = "pkgload")
  }
  zp_main(action)
}
