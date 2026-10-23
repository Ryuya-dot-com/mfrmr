# Seven rejected-trial continuations, retaining every original outcome.
# Rscript --vanilla this-file prepare | run | summarize | verify
source("inst/validation/gmfrm-zero-profile-20261011.R")
zb_script <- "inst/validation/gmfrm-zero-backtrack-20261011.R"
zb_out <- "validation-results/gmfrm-zero-backtrack-20261011"
zb_main <- function(action) {
  stopifnot(action %in% c("prepare", "run", "summarize", "verify"))
  path <- file.path(zb_out, "manifest.rds")
  if (action == "prepare") {
    stopifnot(!file.exists(path))
    old <- readRDS(file.path(zp_out, "manifest.rds")); s <- readRDS(file.path(zp_out, "summary.rds"))
    seg_hash_check(old$sources); seg_hash_check(old$inputs); seg_hash_check(s$results)
    take <- which(s$attempts$OuterScore > 1e-4 & s$attempts$FailedPoints > 0 & !is.na(s$attempts$NLL))
    jobs <- old$jobs[take, ]; jobs$ProfilePath <- names(s$results)[take]
    stopifnot(nrow(jobs) == 7L, all(jobs$Kind == "free"))
    pkgload::load_all(quiet = TRUE, compile = FALSE)
    sources <- unique(c(names(old$sources), zb_script, "R/core-gmfrm-zero-profile-search.R",
      "tests/testthat/test-gmfrm-zero-profile-search.R"))
    m <- list(jobs = jobs, plan = old$plan, sources = tools::md5sum(sources),
      inputs = tools::md5sum(unique(c(names(old$inputs), names(s$results),
        file.path(zp_out, c("manifest.rds", "summary.rds", "verification.rds"))))),
      session = sessionInfo(), threads = old$threads,
      policy = c("Exactly seven original independently checked but nonstationary points following rejected trials.",
        "BFGS maxit400 reltol machine epsilon fnscaleN initial parscale max(1,abs(q)); typed trial failures return Inf.",
        "No fabricated gradient; initial and selected endpoints must evaluate directly; unexpected errors remain visible.",
        "Identical inner evaluator, target, terminal independent checks, curvature and stationarity criteria.",
        "Reuse 23 unaffected prior outcomes; no response generation, public optimizer change or interval qualification."))
    stopifnot(identical(Sys.getenv(names(m$threads)), m$threads))
    dir.create(zb_out, recursive = TRUE, showWarnings = FALSE); saveRDS(m, path)
    for (s in sources) {
      dest <- file.path(zb_out, "epoch-source", s); dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
      stopifnot(file.copy(s, dest, overwrite = FALSE))
    }
    return(invisible(NULL))
  }
  m <- readRDS(path); seal <- tools::md5sum(path); seg_hash_check(m$inputs)
  files <- file.path(zb_out, paste0("fit-", m$jobs$Key, ".rds"))
  if (action %in% c("summarize", "verify")) {
    records <- lapply(files, readRDS); table <- zp_table(records)
    stopifnot(all(vapply(records, function(r) identical(r$manifest, seal), TRUE)))
    if (action == "verify") {
      seg_hash_check(m$sources)
      archive <- tools::md5sum(file.path(zb_out, "epoch-source", names(m$sources)))
      names(archive) <- names(m$sources); stopifnot(identical(archive, m$sources))
      s <- readRDS(file.path(zb_out, "summary.rds")); seg_hash_check(s$results)
      stopifnot(identical(s$manifest, seal), identical(s$attempts, table))
      for (r in records) if (r$status == "stationary_profile_candidate") stopifnot(
        r$independent, r$fixed_error == 0, r$fit$checks[1] <= 1e-4,
        r$review$curvature_ok, r$fit$optimizer$convergence == 0L,
        r$fit$selected$evaluation$inner$status == "stationary_convex_candidate")
      files <- file.path(zb_out, c("summary.rds", "attempts.csv")); before <- tools::md5sum(files)
      zb_main("summarize"); stopifnot(identical(before, tools::md5sum(files)))
      saveRDS(list(manifest = seal, sources = m$sources, inputs = m$inputs,
        results = s$results, aggregates = before, session = sessionInfo()), file.path(zb_out, "verification.rds"))
      cat("Fresh read-only replay, source/input/result bindings and archives passed.\n")
      return(invisible(NULL))
    }
    saveRDS(list(manifest = seal, results = tools::md5sum(files), attempts = table), file.path(zb_out, "summary.rds"))
    write.csv(table, file.path(zb_out, "attempts.csv"), row.names = FALSE)
    print(table, row.names = FALSE); return(invisible(NULL))
  }
  seg_hash_check(m$sources); stopifnot(identical(Sys.getenv(names(m$threads)), m$threads))
  pkgload::load_all(quiet = TRUE, compile = FALSE); stopifnot(identical(sessionInfo(), m$session))
  for (j in seq_len(nrow(m$jobs))) {
    if (file.exists(files[j])) { stopifnot(identical(readRDS(files[j])$manifest, seal)); next }
    job <- m$jobs[j, ]; previous <- readRDS(job$ProfilePath)
    parent <- seg_parent(m$plan$Path[match(job$Parent, m$plan$Case)])
    score <- if (job$Draw != "observed") readRDS(file.path(seg_old, job$Parent,
      paste0(job$Draw, "-generation.rds")))$value$score else NULL
    x <- est_context(parent, score)
    idx <- est_fn("build_indices")(x$fit$prep, x$config$step_facet, x$config$slope_facet,
      x$config$interaction_specs, gpcm_spec = x$config$gpcm_spec)
    z <- previous$fit$selected$evaluation$parameters
    profile <- est_fn("mfrm_gmfrm_zero_profile_evaluator")(z, idx, x$config, x$sizes)
    r <- list(manifest = seal, key = job$Key, status = "unresolved", error = "",
      independent = FALSE, outward = NA_real_, fixed_error = NA_real_)
    timing <- system.time(tryCatch({
      checkpoint <- paste0(files[j], ".search")
      if (file.exists(checkpoint)) {
        r <- readRDS(checkpoint); stopifnot(identical(r$manifest, seal), identical(r$key, job$Key))
      } else {
        r$fit <- est_fn("mfrm_gmfrm_zero_profile_search")(profile)
        r$error <- r$fit$error; r$diagnostics <- profile$diagnostics()
        saveRDS(r, paste0(checkpoint, ".tmp")); stopifnot(file.rename(paste0(checkpoint, ".tmp"), checkpoint))
      }
      a <- r$fit$selected$evaluation
      natural <- est_fn("mfrm_gmfrm_natural_evaluator")(idx, x$config, x$sizes, "common_scale")
      reviewer <- est_fn("mfrm_gmfrm_zero_profile_evaluator")(a$parameters, idx, x$config, x$sizes)
      r$review <- zp_review(a, reviewer, natural, x$fit$gmfrm$specification)
      r$independent <- all(r$review$checks <= c(1e-7, 1e-6, 1e-6))
      r$outward <- r$review$outward; r$fixed_error <- abs(tail(a$parameters, 1L))
      r$nll_change <- a$value - previous$fit$selected$evaluation$value
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
  zb_main(action)
}
