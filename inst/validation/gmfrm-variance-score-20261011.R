# Re-evaluate only the changed positive common-variance score representation.
# Rscript --vanilla this-file prepare | run | summarize
source("inst/validation/gmfrm-natural-20261011.R")
vs_script <- "inst/validation/gmfrm-variance-score-20261011.R"
vs_out <- "validation-results/gmfrm-variance-score-20261011"
vs_main <- function(action) {
  stopifnot(action %in% c("prepare", "run", "summarize"))
  path <- file.path(vs_out, "manifest.rds")
  if (action == "prepare") {
    stopifnot(!file.exists(path))
    old <- readRDS(file.path(nat_out, "manifest.rds")); summary <- readRDS(file.path(nat_out, "summary.rds"))
    seg_hash_check(old$inputs); seg_hash_check(summary$results)
    archive <- tools::md5sum(file.path(nat_out, "epoch-source", names(old$sources)))
    names(archive) <- names(old$sources); stopifnot(identical(archive, old$sources))
    changed <- c("R/core-gmfrm-natural.R", "tests/testthat/test-gmfrm-natural.R")
    seg_hash_check(old$sources[!names(old$sources) %in% changed])
    pkgload::load_all(quiet = TRUE, compile = FALSE)
    sources <- unique(c(vs_script, names(old$sources)))
    m <- list(points = old$points, plan = old$plan,
      inputs = tools::md5sum(unique(c(file.path(nat_out, c("manifest.rds", "summary.rds", "verification.rds")),
        names(old$inputs), names(summary$results)))), sources = tools::md5sum(sources),
      session = sessionInfo(), threads = old$threads,
      policy = c("20 retained positive common-variance points; no fitting or data generation.",
        "Reuse 24 unaffected rater/boundary records under the verified prior source epoch.",
        "NLL reference <=1e-7, log-chart full-gradient reference <=1e-6, original target error <=1e-8.",
        "Full natural-gradient agreement with available saved heat result <=1e-6; preserve missing references.",
        "Prequadrature per-Person selection: prior when v>0 and heat envelope >1/v; no retry-to-pass.",
        "NLL/score rule thresholds 1e-7/1e-6, NLL/score tail bounds 1e-8/1e-7 unchanged."))
    stopifnot(identical(Sys.getenv(names(m$threads)), m$threads))
    dir.create(vs_out, recursive = TRUE, showWarnings = FALSE); saveRDS(m, path)
    for (s in sources) {
      dest <- file.path(vs_out, "epoch-source", s); dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
      stopifnot(file.copy(s, dest, overwrite = FALSE))
    }
    return(invisible(NULL))
  }
  m <- readRDS(path); seg_hash_check(m$inputs); seal <- tools::md5sum(path)
  files <- file.path(vs_out, paste0("point-", m$points$Key, ".rds"))
  if (action == "summarize") {
    records <- lapply(files, readRDS)
    stopifnot(all(vapply(records, function(r) identical(r$manifest, seal), TRUE)))
    table <- do.call(rbind, lapply(records, function(r) data.frame(Key = r$key, Status = r$status,
      Error = r$error, NLLDifference = r$checks[1], LogGradientDifference = r$checks[2],
      TargetError = r$checks[3], NaturalGradientDifference = r$checks[4],
      HeatPersons = if (is.null(r$value)) NA_integer_ else r$value$variance_score["heat"],
      PriorPersons = if (is.null(r$value)) NA_integer_ else r$value$variance_score["prior"])))
    rownames(table) <- NULL
    write.csv(table, file.path(vs_out, "points.csv"), row.names = FALSE)
    saveRDS(list(manifest = seal, results = tools::md5sum(files), points = table), file.path(vs_out, "summary.rds"))
    print(table, row.names = FALSE); return(invisible(NULL))
  }
  seg_hash_check(m$sources); stopifnot(identical(Sys.getenv(names(m$threads)), m$threads))
  pkgload::load_all(quiet = TRUE, compile = FALSE); stopifnot(identical(sessionInfo(), m$session))
  for (j in seq_len(nrow(m$points))) {
    if (file.exists(files[j])) { stopifnot(identical(readRDS(files[j])$manifest, seal)); next }
    job <- m$points[j, ]; saved <- readRDS(job$Path)$value
    parent <- seg_parent(m$plan$Path[match(job$Parent, m$plan$Case)])
    score <- if (job$Draw != "observed") readRDS(file.path(seg_old, job$Parent,
      paste0(job$Draw, "-generation.rds")))$value$score else NULL
    x <- est_context(parent, score); par <- saved$parameters
    idx <- est_fn("build_indices")(x$fit$prep, x$config$step_facet, x$config$slope_facet,
      x$config$interaction_specs, gpcm_spec = x$config$gpcm_spec)
    ref <- switch(job$Source, original = readRDS(job$ReferencePath)$value$reference,
      curvature = saved$reference$reference,
      continuation = if (!is.null(saved$reference)) tail(saved$reference$values, 1L)[[1L]] else NULL)
    previous <- readRDS(file.path(nat_out, paste0("point-", job$Key, "-common_scale.rds")))
    r <- list(manifest = seal, key = job$Key, status = "refused", error = "",
      checks = c(NLL = NA_real_, LogGradient = NA_real_, Target = NA_real_, NaturalGradient = NA_real_))
    tryCatch({
      ev <- est_fn("mfrm_gmfrm_natural_evaluator")(idx, x$config, x$sizes, "common_scale")
      z <- ev$from_native(par); r$coordinates <- z; r$value <- ev$evaluate(z)
      C <- numeric(length(z)); C[build_param_slices(x$sizes)$log_slopes[1]] <- 1
      r$checks["Target"] <- abs(ev$target(z, C)$value -
        if (job$Kind == "null") sum(C * parent$opt$par) + .5 else sum(C * par))
      if (!is.null(previous$value)) {
        r$checks["NaturalGradient"] <- max(abs(r$value$gradient - previous$value$gradient))
        r$unchanged_nll <- identical(r$value$value, previous$value$value)
        r$unchanged_other_scores <- identical(head(r$value$gradient, -1L), head(previous$value$gradient, -1L))
        stopifnot(r$unchanged_nll, r$unchanged_other_scores)
      }
      if (is.null(ref)) r$status <- "no_independent_reference" else {
        map <- est_fn("mfrm_gmfrm_coordinates")(x$config, x$sizes, "common_scale")
        J <- map$decode(map$to_chart(par))$jacobian
        pulled <- r$value$gradient; pulled[ev$natural] <- pulled[ev$natural] * z[ev$natural] * 2
        r$checks[1:2] <- c(abs(r$value$value - ref$nll), max(abs(pulled + drop(crossprod(J, ref$score)))))
        r$status <- if (all(is.finite(r$checks)) && all(r$checks <= c(1e-7, 1e-6, 1e-8, 1e-6)))
          "qualified" else "disagreement"
      }
    }, error = function(e) {
      r$error <<- conditionMessage(e)
      r$failure <<- list(class = class(e), integration = e$integration, score_error = e$score_error, parameters = e$parameters)
    })
    saveRDS(r, paste0(files[j], ".tmp")); stopifnot(file.rename(paste0(files[j], ".tmp"), files[j]))
    cat(job$Key, r$status, r$error, "\n"); flush.console()
  }
}
if (sys.nframe() == 0L) vs_main(commandArgs(trailingOnly = TRUE))
