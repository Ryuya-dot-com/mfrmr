# Paired development diagnosis on all 50 retained N60 datasets, not new sampling.
# Rscript this-file prepare | run [FIRST LAST] | summarize
out <- "validation-results/gmfrm-profile-membership-20261010"
script <- "inst/validation/gmfrm-profile-membership-20261010.R"
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) >= 1L, args[1] %in% c("prepare", "run", "summarize"))
check <- function(h) stopifnot(length(h) > 0L, !anyNA(h),
  identical(unname(tools::md5sum(names(h))), unname(h)))
seal_path <- file.path(out, "manifest.rds")
source("inst/validation/mfrm-wide-map-output-summary-20261001.R")

if (args[1] == "prepare") {
  stopifnot(!file.exists(seal_path))
  sp <- "validation-results/mfrm-wide-map-d-historical-two-family-r50-20261006/complete-n60-summary/summary.rds"
  s <- readRDS(sp); check(s$binding$outputs)
  rp <- "validation-results/gmfrm-retained-source-reuse-20261010/summary.rds"
  reuse <- readRDS(rp); check(reuse$files)
  ip <- "validation-results/gmfrm-retained-source-reuse-20261010/independent-reference.rds"
  independent <- readRDS(ip); check(independent$inputs_and_source)
  files <- names(s$binding$outputs)
  files <- files[grepl("/d-outputs[.]rds$", files)]
  inputs <- c(sp, rp, ip, files)
  plan <- do.call(rbind, lapply(files, function(path) {
    x <- readRDS(path)$payload; z <- wide_output_records(x$plan, x$records)
    z <- z[z$Output == "interval" & z$Target == 'slopes:"Task":"t1"', ]
    stopifnot(nrow(z) == 1L)
    selected <- file.path(dirname(path), "selected.rds")
    sel <- readRDS(selected)$payload
    stage <- sel$intervals$slopes$stage
    fit_path <- file.path(dirname(path), paste0(sub(":.*$", "", stage), "-fit.rds"))
    if (!z$Available) {
      v <- Filter(function(v) v$job$N == 60L && v$job$Replicate == z$Replicate, reuse$results)
      stopifnot(length(v) == 1L, v[[1]]$admitted)
      v <- v[[1]]
      stopifnot(independent$rows$Passed[match(v$job$Job, independent$rows$Job)])
      fit_path <- v$job$LaterFit; stage <- v$job$LaterStage
      a <- v$intervals[v$intervals$Target == z$Target, ]
      for (k in c("Available", "Estimate", "SE", "Lower", "Upper")) z[[k]] <- a[[k]]
    }
    inputs <<- union(inputs, c(selected, fit_path))
    stopifnot(z$Available, abs(z$ReferenceValue + .2) < 1e-14)
    data.frame(Replicate = z$Replicate, FitPath = fit_path, Stage = stage,
      Truth = z$ReferenceValue, Estimate = z$Estimate, SE = z$SE,
      WaldLower = z$Lower, WaldUpper = z$Upper,
      WaldIncluded = z$Lower <= z$ReferenceValue && z$ReferenceValue <= z$Upper)
  }))
  plan <- plan[order(plan$Replicate), ]; rownames(plan) <- NULL
  stopifnot(identical(plan$Replicate, 1:50), sum(plan$WaldIncluded) == 41L)
  pkgload::load_all(quiet = TRUE, compile = FALSE)
  sources <- c(script, "inst/validation/gmfrm-adaptive-profile-reference-20261010.R",
    "inst/validation/mfrm-wide-map-output-summary-20261001.R",
    "tests/testthat/helper-gmfrm-information.R", list.files("R", full.names = TRUE),
    "src/mfrmr.so")
  stopifnot(unname(tools::md5sum(getLoadedDLLs()[["mfrmr"]][["path"]])) ==
    unname(tools::md5sum("src/mfrmr.so")))
  manifest <- list(plan = plan, inputs = tools::md5sum(inputs),
    sources = tools::md5sum(sources), session = sessionInfo(),
    threads = Sys.getenv(c("OPENBLAS_NUM_THREADS", "OMP_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")),
    protocol = paste("All 50 existing common-Person SD1 N60 datasets; Task t1 log-slope truth -0.2.",
      "Use the separately qualified saved-source procedure, never choose sources by truth.",
      "No new data or source fitting. Current source eligibility and absolute integration gates.",
      "Two starts at source target and truth; existing nuisance optimizer, 400 iterations per stage.",
      "Same fitted quadrature q and max(q+10,2q-1), no rescue or grid change.",
      "Independent continuous-integral/Louis checks at source and both truth solutions.",
      "Missing outcomes retained among all 50; no stopping by result or extra allocation.",
      "LR membership is not delivery of a connected confidence interval or independent coverage confirmation."))
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  saveRDS(manifest, seal_path)
  cat("Frozen 50 retained sources; 41/50 Wald inclusions; no new sampling.\n")
  quit(save = "no")
}

m <- readRDS(seal_path); check(m$inputs); check(m$sources)
seal <- tools::md5sum(seal_path)
if (args[1] == "run") {
  pkgload::load_all(quiet = TRUE, compile = FALSE)
  source("inst/validation/gmfrm-adaptive-profile-reference-20261010.R")
  fn <- function(n) get(n, asNamespace("mfrmr"))
  stopifnot(identical(R.version.string, m$session$R.version$version.string),
    identical(Sys.getenv(names(m$threads)), m$threads),
    unname(tools::md5sum(getLoadedDLLs()[["mfrmr"]][["path"]])) ==
      unname(m$sources["src/mfrmr.so"]))
  chosen <- if (length(args) == 3L) seq.int(as.integer(args[2]), as.integer(args[3])) else 1:50
  stopifnot(all(chosen %in% 1:50))
  for (i in chosen) {
    path <- file.path(out, sprintf("r%03d.rds", i))
    if (file.exists(path)) { stopifnot(identical(readRDS(path)$manifest, seal)); next }
    job <- m$plan[i, ]; fit <- readRDS(job$FitPath)$payload$value
    before <- serialize(fit, NULL); warnings <- character(); error <- ""; result <- list()
    elapsed <- system.time(withCallingHandlers(tryCatch({
      result$joint <- fn("mfrm_gpcm_product_inference")(fit)
      stopifnot(isTRUE(result$joint$check$eligible))
      config <- fit$config; p <- fit$opt$par
      sizes <- fn("build_param_sizes")(config)
      idx <- fn("build_indices")(fit$prep, config$step_facet, config$slope_facet,
        config$interaction_specs, gpcm_spec = config$gpcm_spec)
      q <- config$estimation_control$quad_points; high <- max(q + 10L, 2L*q - 1L)
      context <- function(order) {
        cfg <- config; cfg$estimation_control$quad_points <- order
        e <- fn("make_mfrm_direct_evaluator")("MML",
          fn("make_param_cache")(sizes, cfg, idx, is_mml = TRUE), idx, cfg, sizes,
          fn("gauss_hermite_normal")(order))
        e$optimization_scale <- length(fit$prep$levels$Person)
        e
      }
      low <- context(q); finer <- context(high); baseline <- low$value(p)
      stopifnot(fn("mfrmr_adaptive_integration")(config),
        abs(baseline - finer$value(p)) <= 1e-5,
        max(abs(low$gradient(p) - finer$gradient(p))) <= 1e-4)
      target <- fn("mfrm_gpcm_product_slope_targets")(p, config)$components
      at <- which(target$metadata$Owner == "Task" & target$metadata$Level == "t1")
      contrast <- unname(target$jacobian[at, ])
      expected <- numeric(length(p)); expected[length(p) - 7L] <- 1
      stopifnot(identical(contrast, expected), abs(sum(contrast * p) - job$Estimate) < 1e-8,
        abs(sqrt(drop(contrast %*% result$joint$covariance %*% contrast)) - job$SE) < 1e-6)
      evaluate <- function(t) {
        a <- lapply(list(retained = p, neutral = rep(0, length(p))), function(start)
          fn("mfrm_gpcm_profile_nuisance")(low, finer, start, contrast, t, 400L))
        checks <- do.call(rbind, lapply(a, `[[`, "check"))
        pass <- all(checks$Passed) && all(is.finite(checks$NLL)) &&
          diff(range(checks$NLL)) <= 1e-5 && min(checks$NLL) >= baseline - 1e-5
        list(value = t, attempts = a, checks = checks, passed = pass,
          LR = if (all(is.finite(checks$NLL))) 2*(min(checks$NLL) - baseline) else NA_real_)
      }
      result$baseline <- baseline; result$q <- q; result$high <- high
      result$center <- evaluate(sum(contrast * p))
      if (!result$center$passed) stop("Source-target two-start profile checks failed.")
      result$truth <- evaluate(job$Truth)
      if (!result$truth$passed) stop("Generating-target two-start profile checks failed.")
      ref0 <- gmfrm_profile_reference(fit, p, order = max(121L, high))
      stopifnot(abs(ref0$continuous_nll - baseline) <= 1e-5)
      null <- qr.Q(qr(matrix(contrast, ncol = 1)), complete = TRUE)[, -1, drop = FALSE]
      refs <- lapply(result$truth$attempts, function(a) {
        r <- gmfrm_profile_reference(fit, a$parameters, order = max(121L, high))
        H <- crossprod(null, r$information %*% null)
        c(ConstraintError = abs(sum(contrast * a$parameters) - job$Truth),
          NLLDifference = abs(r$continuous_nll - a$check$NLL),
          IntegrationDifference = abs(r$continuous_nll + sum(r$log_marginal)),
          LR = 2*(r$continuous_nll - ref0$continuous_nll),
          NuisanceScore = max(abs(crossprod(null, colSums(r$scores)))),
          MinimumNuisanceInformation = min(eigen(H, symmetric = TRUE, only.values = TRUE)$values))
      })
      result$reference <- do.call(rbind, refs)
      r <- result$reference; cutoff <- qchisq(.95, 1)
      stopifnot(all(r[, "ConstraintError"] <= 1e-8), all(r[, "NLLDifference"] <= 1e-5),
        all(r[, "IntegrationDifference"] <= 1e-6), all(r[, "NuisanceScore"] <= 1e-4),
        all(r[, "MinimumNuisanceInformation"] > 0),
        all(abs(r[, "LR"] - cutoff) > 1e-4),
        all((r[, "LR"] <= cutoff) == (result$truth$LR <= cutoff)))
      result$included <- result$truth$LR <= cutoff
    }, error = function(e) error <<- conditionMessage(e)),
      warning = function(w) { warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning") }))
    stopifnot(identical(before, serialize(fit, NULL)))
    saveRDS(list(job = job, manifest = seal, result = result, error = error,
      warnings = unique(warnings), seconds = unname(elapsed["elapsed"])), path)
    cat(i, if (nzchar(error)) error else paste("LR", signif(result$truth$LR, 6),
      "included", result$included), "seconds", elapsed["elapsed"], "\n"); flush.console()
  }
}
if (args[1] == "summarize") {
  paths <- file.path(out, sprintf("r%03d.rds", 1:50)); stopifnot(all(file.exists(paths)))
  rows <- do.call(rbind, lapply(paths, function(path) {
    x <- readRDS(path); stopifnot(identical(x$manifest, seal))
    data.frame(Replicate = x$job$Replicate, WaldIncluded = x$job$WaldIncluded,
      Available = !nzchar(x$error), LR = if (is.null(x$result$truth)) NA_real_ else x$result$truth$LR,
      Included = if (nzchar(x$error)) NA else x$result$included,
      Error = x$error, Seconds = x$seconds)
  }))
  print(with(rows, table(WaldIncluded, Included, useNA = "ifany")))
  print(rows[!rows$Available, ], row.names = FALSE)
  n <- sum(rows$Available); k <- sum(rows$Included, na.rm = TRUE)
  cat("Available", n, "/ 50; included", k, "/", n,
    "; all-50 inclusion bounds", k/50, (k+50-n)/50, "\n")
  saveRDS(list(rows = rows, manifest = seal, results = tools::md5sum(paths),
    scope = m$protocol), file.path(out, "summary.rds"))
  write.csv(rows, file.path(out, "summary.csv"), row.names = FALSE)
}
check(m$inputs); check(m$sources)
