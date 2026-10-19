# Fixed-point chart qualification. No fitting, generation or inference adoption.
# Rscript --vanilla this-file prepare | run | summarize
source("inst/validation/gmfrm-segmented-estimation-20261011.R")
co_script <- "inst/validation/gmfrm-coordinates-20261011.R"
co_out <- "validation-results/gmfrm-coordinates-20261011"
co_main <- function(action) {
  stopifnot(length(action) == 1L, action %in% c("prepare", "run", "summarize"))
  path <- file.path(co_out, "manifest.rds")
  prior <- "validation-results/gmfrm-segmented-continuation-20261011"
  followup <- "validation-results/gmfrm-segmented-followup-20261011"
  if (action == "prepare") {
    stopifnot(!file.exists(path))
    es <- readRDS(file.path(est_out, "summary.rds"))
    fs <- readRDS(file.path(followup, "summary.rds"))
    cs <- readRDS(file.path(prior, "summary.rds"))
    cm <- readRDS(file.path(prior, "manifest.rds"))
    em <- readRDS(file.path(est_out, "manifest.rds"))
    seg_hash_check(cm$inputs)
    for (s in list(es, fs, cs)) seg_hash_check(s$results)
    points <- em$jobs
    points$Source <- "original"
    points$Source[points$Key %in% fs$curvature$Key] <- "curvature"
    points$Source[points$Key %in% cm$jobs$Key] <- "continuation"
    points$Path <- vapply(seq_len(nrow(points)), function(j) {
      key <- points$Key[j]
      switch(points$Source[j], original = file.path(est_out, paste0("fit-", key, ".rds")),
        curvature = file.path(followup, paste0("curvature-", key, ".rds")),
        continuation = file.path(prior, paste0("run-", key, ".rds")))
    }, "")
    points$ReferencePath <- ifelse(points$Source == "original",
      file.path(est_out, paste0("reference-", points$Key, ".rds")), points$Path)
    inputs <- unique(c(file.path(prior, c("manifest.rds", "summary.rds")),
      file.path(followup, c("manifest.rds", "summary.rds")),
      file.path(est_out, c("manifest.rds", "summary.rds")),
      names(cm$inputs), points$Path, points$ReferencePath))
    pkgload::load_all(quiet = TRUE, compile = FALSE)
    sources <- c(co_script, est_script, seg_script, list.files("R", full.names = TRUE),
      "tests/testthat/test-gmfrm-coordinates.R", "tests/testthat/test-gmfrm-segmented.R", "src/mfrmr.so")
    dir.create(co_out, recursive = TRUE, showWarnings = FALSE)
    m <- list(points = points, plan = em$plan, inputs = tools::md5sum(inputs),
      sources = tools::md5sum(sources), session = sessionInfo(), threads = cm$threads,
      policy = c("20 retained endpoints x 2 interior charts; fixed-point likelihood/gradient evaluations only, no fits, Hessians or responses.",
        "Preserve each native target C gamma; original null is first task log slope at parent + .5.",
        "Reference NLL difference <=1e-7, pulled-back full gradient difference <=1e-6, null error <=1e-8.",
        "Relative inverse-map error <=1e-12; propagated score rule <=1e-6 and tail <=1e-7.",
        "Preserve prior refusals and absent independent references; no stationarity or inference reclassification."))
    stopifnot(identical(Sys.getenv(names(m$threads)), m$threads))
    saveRDS(m, path)
    for (s in sources) {
      dest <- file.path(co_out, "epoch-source", s)
      dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
      stopifnot(file.copy(s, dest, overwrite = FALSE))
    }
    print(table(points$Source)); return(invisible(NULL))
  }
  m <- readRDS(path); seg_hash_check(m$inputs)
  seal <- tools::md5sum(path)
  charts <- c("rater_intercepts", "common_scale")
  files <- unlist(lapply(m$points$Key, function(key)
    file.path(co_out, paste0(key, "-", charts, ".rds"))))
  if (action == "summarize") {
    records <- lapply(files, readRDS)
    stopifnot(all(vapply(records, function(r) identical(r$manifest, seal), TRUE)))
    table <- do.call(rbind, lapply(records, function(r) data.frame(
      Key = r$key, Chart = r$chart, Status = r$status, Error = r$error,
      NLLDifference = unname(r$checks["NLLDifference"]),
      GradientDifference = unname(r$checks["GradientDifference"]),
      RoundTrip = unname(r$checks["RoundTrip"]), Constraint = unname(r$checks["Constraint"]),
      ScoreRule = unname(r$checks["ScoreRule"]), ScoreTail = unname(r$checks["ScoreTail"]))))
    write.csv(table, file.path(co_out, "points.csv"), row.names = FALSE)
    saveRDS(list(manifest = seal, results = tools::md5sum(files), points = table),
      file.path(co_out, "summary.rds"))
    print(table(table$Chart, table$Status)); print(subset(table, Status != "qualified"), row.names = FALSE)
    return(invisible(NULL))
  }
  seg_hash_check(m$sources)
  stopifnot(identical(Sys.getenv(names(m$threads)), m$threads))
  pkgload::load_all(quiet = TRUE, compile = FALSE)
  stopifnot(identical(sessionInfo(), m$session))
  for (j in seq_len(nrow(m$points))) {
    job <- m$points[j, ]; saved <- readRDS(job$Path)$value
    parent <- seg_parent(m$plan$Path[match(job$Parent, m$plan$Case)])
    score <- if (job$Draw != "observed") readRDS(file.path(seg_old, job$Parent,
      paste0(job$Draw, "-generation.rds")))$value$score else NULL
    x <- est_context(parent, score); par <- saved$parameters
    ref <- switch(job$Source,
      original = readRDS(job$ReferencePath)$value$reference,
      curvature = saved$reference$reference,
      continuation = if (!is.null(saved$reference)) tail(saved$reference$values, 1L)[[1L]] else NULL)
    for (chart in charts) {
      dest <- file.path(co_out, paste0(job$Key, "-", chart, ".rds"))
      if (file.exists(dest)) {
        stopifnot(identical(readRDS(dest)$manifest, seal)); next
      }
      record <- list(manifest = seal, key = job$Key, chart = chart, status = "refused", error = "",
        checks = setNames(rep(NA_real_, 6), c("NLLDifference", "GradientDifference", "RoundTrip",
          "Constraint", "ScoreRule", "ScoreTail")))
      tryCatch({
        map <- est_fn("mfrm_gmfrm_coordinates")(x$config, x$sizes, chart)
        z <- map$to_chart(par); decoded <- map$decode(z)
        C <- numeric(length(par)); C[build_param_slices(x$sizes)$log_slopes[1]] <- 1
        record$checks["RoundTrip"] <- max(abs(decoded$parameters - par) / pmax(1, abs(par)))
        record$checks["Constraint"] <- abs(map$target(z, C)$value -
          if (job$Kind == "null") sum(C * parent$opt$par) + .5 else sum(C * par))
        ev <- est_fn("mfrm_gmfrm_coordinate_evaluator")(x$evaluator, map)
        record$value <- ev$evaluate(z); record$coordinates <- z
        record$checks[c("ScoreRule", "ScoreTail")] <-
          record$value$integration[c("ScoreRuleDifference", "TailScoreBound")]
        if (is.null(ref)) {
          record$status <- "no_independent_reference"
        } else {
          record$checks["NLLDifference"] <- abs(record$value$value - ref$nll)
          record$checks["GradientDifference"] <- max(abs(record$value$gradient +
            drop(crossprod(decoded$jacobian, ref$score))))
          record$status <- if (all(is.finite(record$checks)) &&
            all(record$checks <= c(1e-7, 1e-6, 1e-12, 1e-8, 1e-6, 1e-7))) "qualified" else "disagreement"
        }
      }, error = function(e) {
        record$error <<- conditionMessage(e)
        record$failure <<- list(class = class(e), integration = e$integration,
          native_parameters = e$native_parameters, parameters = e$parameters)
      })
      saveRDS(record, paste0(dest, ".tmp")); stopifnot(file.rename(paste0(dest, ".tmp"), dest))
      cat(job$Key, chart, record$status, record$error, "\n"); flush.console()
    }
  }
}
if (sys.nframe() == 0L) co_main(commandArgs(trailingOnly = TRUE))
