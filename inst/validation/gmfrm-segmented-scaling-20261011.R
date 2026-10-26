# Saved-endpoint geometry, followed only by a separately recorded search policy.
source("inst/validation/gmfrm-segmented-followup-20261011.R")
sc_script <- "inst/validation/gmfrm-segmented-scaling-20261011.R"
sc_out <- "validation-results/gmfrm-segmented-scaling-20261011"
sc_geometry <- function(z, gradient) {
  matrices <- lapply(c(1e-3, 1e-4), function(h) {
    raw <- vapply(seq_along(z), function(j) {
      d <- numeric(length(z)); d[j] <- h
      (gradient(z + d) - gradient(z - d)) / (2 * h)
    }, numeric(length(z)))
    list(raw = raw, symmetric = (raw + t(raw)) / 2)
  })
  H <- matrices[[2]]$symmetric
  e <- eigen(H, symmetric = TRUE); g <- gradient(z)
  list(hessian = matrices, eigen = e, gradient = g,
    metrics = c(Score = max(abs(g)), EigenMin = min(e$values), EigenMax = max(e$values),
      Condition = max(abs(e$values)) / min(abs(e$values)),
      StepDifference = max(abs(matrices[[1]]$symmetric - H)),
      Asymmetry = max(abs(matrices[[2]]$raw - t(matrices[[2]]$raw))),
      ScaledScore = max(abs(crossprod(e$vectors, g) /
        sqrt(pmax(abs(e$values), max(abs(e$values)) * 1e-10))))))
}
sc_main <- function(args) {
  pkgload::load_all(quiet = TRUE, compile = FALSE)
  path <- file.path(sc_out, "manifest.rds")
  if (args[1] == "prepare") {
    stopifnot(!file.exists(path))
    followup <- readRDS(file.path(fu_out, "manifest.rds"))
    seg_hash_check(followup$inputs)
    jobs <- followup$jobs[followup$jobs$Action != "curvature", ]
    inputs <- unique(c(file.path(fu_out, "manifest.rds"), names(followup$inputs),
      file.path(fu_out, paste0("run-", jobs$Key, ".rds"))))
    sources <- c(sc_script, fu_script, est_script, seg_script,
      list.files("R", full.names = TRUE), "src/mfrmr.so")
    dir.create(sc_out, recursive = TRUE, showWarnings = FALSE)
    manifest <- list(followup = followup, jobs = jobs, inputs = tools::md5sum(inputs),
      sources = tools::md5sum(sources), session = sessionInfo(),
      threads = Sys.getenv(c("OPENBLAS_NUM_THREADS", "OMP_NUM_THREADS", "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")),
      policy = "All eight unresolved N20 endpoints: repaired score; central Hessians h=1e-3,1e-4; no refits or new data in geometry phase.")
    saveRDS(manifest, path)
    for (s in sources) {
      dest <- file.path(sc_out, "epoch-source", s)
      dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
      stopifnot(file.copy(s, dest, overwrite = FALSE))
    }
    return(invisible(NULL))
  }
  m <- readRDS(path); seg_hash_check(m$inputs); seg_hash_check(m$sources)
  stopifnot(identical(R.version.string, m$session$R.version$version.string),
    identical(Sys.getenv(names(m$threads)), m$threads))
  if (args[1] == "geometry") {
    stopifnot(length(args) == 2, args[2] %in% m$jobs$Key)
    job <- m$jobs[m$jobs$Key == args[2], ]
    dest <- file.path(sc_out, paste0("geometry-", job$Key, ".rds"))
    seal <- tools::md5sum(path)
    if (file.exists(dest)) { stopifnot(identical(readRDS(dest)$manifest, seal)); return(invisible(NULL)) }
    old <- readRDS(file.path(fu_out, paste0("run-", job$Key, ".rds")))
    x <- fu_setup(job, m$followup); ev <- x$setup$evaluator; map <- x$map
    par <- if (!is.null(old$value)) old$value$parameters else map$embed(old$optimizer$par)
    value <- NULL; error <- ""
    time <- system.time(tryCatch({
      terminal <- ev$evaluate(par)
      geometry <- sc_geometry(par[map$free], function(z)
        drop(crossprod(map$basis, ev$gradient(map$embed(z)))))
      value <- list(parameters = par, terminal = terminal, geometry = geometry)
    }, error = function(e) error <<- conditionMessage(e)))
    record <- list(manifest = seal, value = value, error = error, seconds = unname(time["elapsed"]))
    saveRDS(record, paste0(dest, ".tmp")); stopifnot(file.rename(paste0(dest, ".tmp"), dest))
    cat(job$Key, "error:", error, "seconds:", record$seconds, "\n")
    print(value$geometry$metrics)
    return(invisible(NULL))
  }
  stop("Unknown phase.")
}
if (sys.nframe() == 0L) sc_main(commandArgs(trailingOnly = TRUE))
