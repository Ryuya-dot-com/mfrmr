# Bounded fixed-discrimination study. No outer fitting or new responses.
# Rscript --vanilla this-file prepare | run | summarize | verify
source("inst/validation/gmfrm-zero-search-20261011.R")
zl_script <- "inst/validation/gmfrm-zero-location-20261011.R"
zl_out <- "validation-results/gmfrm-zero-location-20261011"

zl_table <- function(records) {
  out <- do.call(rbind, lapply(records, function(r) {
    f <- r$fit
    data.frame(Key = r$key, Status = r$status,
      Solver = if (is.null(f)) "unavailable" else f$status,
      SupportRank = if (is.null(f)) NA_integer_ else f$support$rank,
      NLL = if (is.null(f)) NA_real_ else f$evaluation$value,
      LocationScore = if (is.null(f)) NA_real_ else max(abs(f$evaluation$gradient)),
      OuterScore = r$outer_score, NLLChange = r$nll_change,
      Iterations = if (is.null(f)) NA_integer_ else f$iterations,
      Seconds = r$seconds, Error = r$error)
  })); rownames(out) <- NULL; out
}

zl_main <- function(action) {
  stopifnot(action %in% c("prepare", "run", "summarize", "verify"))
  path <- file.path(zl_out, "manifest.rds")
  if (action == "prepare") {
    stopifnot(!file.exists(path))
    old <- readRDS(file.path(zs_out, "manifest.rds")); s <- readRDS(file.path(zs_out, "summary.rds"))
    seg_hash_check(old$sources); seg_hash_check(old$inputs); seg_hash_check(s$results)
    jobs <- old$jobs[rep(seq_len(nrow(old$jobs)), each = 2L), ]
    jobs$Endpoint <- file.path(zs_out, paste0("fit-", jobs$Key, ".rds"))
    jobs$LocationStart <- rep(c("saved", "zero"), nrow(old$jobs))
    jobs$Key <- paste(jobs$Key, jobs$LocationStart, sep = "-")
    stopifnot(nrow(jobs) == 60L, !anyDuplicated(jobs$Key))
    pkgload::load_all(quiet = TRUE, compile = FALSE)
    sources <- unique(c(names(old$sources), zl_script, "R/core-gmfrm-zero-location.R",
      "tests/testthat/test-gmfrm-zero-location.R"))
    m <- list(jobs = jobs, plan = old$plan, session = sessionInfo(), threads = old$threads,
      sources = tools::md5sum(sources), inputs = tools::md5sum(unique(c(names(old$inputs),
        names(s$results), file.path(zs_out, c("manifest.rds", "summary.rds", "verification.rds"))))),
      policy = c("60 fixed-discrimination inner searches; 30 old endpoints, saved/zero locations.",
        "Sufficient full support-difference rank, maxit80, Cholesky, scaled Hessian rcond>=1e-12.",
        "Raw score<=1e-6, scaled score<=1e-8, decrement<=1e-12; max logit step10, Armijo1e-4, 50 halvings.",
        "Independent NLL<=1e-7, all nonvariance gradient<=1e-6, outward<=1e-6, relative Hessian<=1e-6.",
        "Independent two-step literal derivatives; exact nonlocation preservation; two-start NLL spread<=1e-5.",
        "No response generation, outer optimization, LR/inference qualification or public adoption."))
    stopifnot(identical(Sys.getenv(names(m$threads)), m$threads))
    dir.create(zl_out, recursive = TRUE, showWarnings = FALSE); saveRDS(m, path)
    for (s in sources) {
      dest <- file.path(zl_out, "epoch-source", s); dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
      stopifnot(file.copy(s, dest, overwrite = FALSE))
    }
    return(invisible(NULL))
  }
  m <- readRDS(path); seal <- tools::md5sum(path); seg_hash_check(m$inputs)
  files <- file.path(zl_out, paste0("fit-", m$jobs$Key, ".rds"))
  if (action %in% c("summarize", "verify")) {
    records <- lapply(files, readRDS)
    stopifnot(all(vapply(records, function(r) identical(r$manifest, seal), TRUE)))
    table <- zl_table(records)
    if (action == "verify") {
      seg_hash_check(m$sources)
      archive <- tools::md5sum(file.path(zl_out, "epoch-source", names(m$sources)))
      names(archive) <- names(m$sources); stopifnot(identical(archive, m$sources))
      s <- readRDS(file.path(zl_out, "summary.rds")); seg_hash_check(s$results)
      stopifnot(identical(s$manifest, seal), identical(s$attempts, table))
      for (r in records) if (r$status == "qualified_inner_candidate") stopifnot(
        r$fit$status == "stationary_convex_candidate", r$fit$support$finite_unique,
        r$fixed_error == 0, all(r$review$checks <= c(1e-7, 1e-6, 1e-6)),
        r$hessian_relative_error <= 1e-6)
      blocked <- function(...) stop("Read-only replay attempted numerical work.")
      for (name in c("optim", "optimHess", "nlminb", "integrate", "uniroot", "rnorm"))
        assignInNamespace(name, blocked, ns = "stats")
      assignInNamespace("load_all", blocked, ns = "pkgload")
      aggregates <- file.path(zl_out, c("summary.rds", "attempts.csv"))
      before <- tools::md5sum(aggregates); zl_main("summarize")
      stopifnot(identical(before, tools::md5sum(aggregates)))
      saveRDS(list(manifest = seal, sources = m$sources, inputs = m$inputs,
        results = s$results, aggregates = before, session = sessionInfo()), file.path(zl_out, "verification.rds"))
      cat("Source/input/archive/result bindings and byte-identical numerical-work-free replay passed.\n")
      return(invisible(NULL))
    }
    saveRDS(list(manifest = seal, results = tools::md5sum(files), attempts = table), file.path(zl_out, "summary.rds"))
    write.csv(table, file.path(zl_out, "attempts.csv"), row.names = FALSE)
    print(table, row.names = FALSE); return(invisible(NULL))
  }
  seg_hash_check(m$sources); stopifnot(identical(Sys.getenv(names(m$threads)), m$threads))
  pkgload::load_all(quiet = TRUE, compile = FALSE); stopifnot(identical(sessionInfo(), m$session))
  for (j in seq_len(nrow(m$jobs))) {
    if (file.exists(files[j])) { stopifnot(identical(readRDS(files[j])$manifest, seal)); next }
    job <- m$jobs[j, ]; previous <- readRDS(job$Endpoint)
    parent <- seg_parent(m$plan$Path[match(job$Parent, m$plan$Case)])
    score <- if (job$Draw != "observed") readRDS(file.path(seg_old, job$Parent,
      paste0(job$Draw, "-generation.rds")))$value$score else NULL
    x <- est_context(parent, score)
    idx <- est_fn("build_indices")(x$fit$prep, x$config$step_facet, x$config$slope_facet,
      x$config$interaction_specs, gpcm_spec = x$config$gpcm_spec)
    ev <- est_fn("mfrm_gmfrm_natural_evaluator")(idx, x$config, x$sizes, "common_scale")
    z <- previous$fit$selected$parameters
    r <- list(manifest = seal, key = job$Key, status = "unresolved", error = "",
      outer_score = NA_real_, nll_change = NA_real_)
    timing <- system.time(tryCatch({
      loc <- est_fn("mfrm_gmfrm_zero_location_problem")(z, idx, x$config, x$sizes)
      checkpoint <- paste0(files[j], ".search")
      if (file.exists(checkpoint)) {
        r <- readRDS(checkpoint); stopifnot(identical(r$manifest, seal), identical(r$key, job$Key))
      } else {
        r$fit <- est_fn("mfrm_gmfrm_zero_location_search")(loc,
          if (job$LocationStart == "zero") loc$start*0 else loc$start)
        saveRDS(r, paste0(checkpoint, ".tmp")); stopifnot(file.rename(paste0(checkpoint, ".tmp"), checkpoint))
      }
      r$parameters <- replace(z, loc$location, r$fit$parameters)
      a <- ev$evaluate(r$parameters); free <- setdiff(seq_along(z), ev$natural)
      r$review <- zs_review(list(selected = list(parameters = r$parameters, evaluation = a), free = free),
        ev, x$fit$gmfrm$specification)
      H <- lapply(c(1e-4, 5e-5), function(h) vapply(loc$location, function(k) {
        step <- replace(z*0, k, h*max(1, abs(r$parameters[k])))
        (ev$gradient(r$parameters + step)[loc$location] - ev$gradient(r$parameters - step)[loc$location])/(2*step[k])
      }, numeric(length(loc$location))))
      r$hessian_relative_error <- norm(r$fit$evaluation$hessian - (4*H[[2]] - H[[1]])/3, "2") /
        max(1, norm(r$fit$evaluation$hessian, "2"))
      r$location_engine_error <- max(abs(r$fit$evaluation$gradient - a$gradient[loc$location]))
      r$review$checks[1L] <- max(r$review$checks[1L], abs(r$fit$evaluation$value - a$value))
      r$review$checks[2L] <- max(r$review$checks[2L], r$location_engine_error)
      outer <- setdiff(free, c(loc$location, if (job$Kind == "null") build_param_slices(x$sizes)$log_slopes[1]))
      r$outer_score <- max(abs(a$gradient[outer])); r$outward <- a$gradient[ev$natural]
      r$fixed_error <- max(abs(r$parameters[-loc$location] - z[-loc$location]))
      r$nll_change <- r$fit$evaluation$value - previous$fit$selected$evaluation$value
      if (r$fit$status == "stationary_convex_candidate" && r$fixed_error == 0 &&
          all(r$review$checks <= c(1e-7, 1e-6, 1e-6)) && r$hessian_relative_error <= 1e-6)
        r$status <- "qualified_inner_candidate"
    }, error = function(e) r$error <<- conditionMessage(e)))
    r$seconds <- unname(timing["elapsed"])
    saveRDS(r, paste0(files[j], ".tmp")); stopifnot(file.rename(paste0(files[j], ".tmp"), files[j]))
    cat(job$Key, r$status, r$seconds, r$error, "\n"); flush.console()
  }
}
if (sys.nframe() == 0L) zl_main(commandArgs(trailingOnly = TRUE))
