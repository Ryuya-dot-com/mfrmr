# Internal estimation candidate, not a public fitting route or coverage study.
# Rscript --vanilla this-file prepare | check | run [Case] | summarize
source("inst/validation/gmfrm-segmented-reference-20261011.R")
est_script <- "inst/validation/gmfrm-segmented-estimation-20261011.R"
est_out <- "validation-results/gmfrm-segmented-estimation-20261011"
est_fn <- function(n) get(n, asNamespace("mfrmr"))
est_context <- function(fit, score = NULL) {
  if (!is.null(score)) {
    fit$prep$data$Score <- fit$prep$data$score_k <- score
    fit$gmfrm$specification$data[[fit$gmfrm$specification$score]] <- score
  }
  cfg <- fit$config
  idx <- est_fn("build_indices")(fit$prep, cfg$step_facet, cfg$slope_facet,
    cfg$interaction_specs, gpcm_spec = cfg$gpcm_spec)
  sizes <- est_fn("build_param_sizes")(cfg)
  list(fit = fit, evaluator = est_fn("mfrm_gmfrm_segmented_evaluator")(idx, cfg, sizes),
    sizes = sizes, config = cfg)
}

est_main <- function(args) {
  stopifnot(length(args) > 0L, args[1] %in% c("prepare", "check", "run", "summarize"))
  pkgload::load_all(quiet = TRUE, compile = FALSE)
  path <- file.path(est_out, "manifest.rds")
  ref_manifest <- file.path(seg_out, "manifest.rds")
  ref_summary <- file.path(seg_out, "summary.rds")
  reference <- readRDS(ref_manifest); reference_summary <- readRDS(ref_summary)
  seg_hash_check(reference$inputs); seg_hash_check(reference$sources)
  seg_hash_check(reference_summary$result_hashes)
  if (args[1] == "prepare") {
    stopifnot(!file.exists(path), all(reference_summary$points$Qualified))
    cases <- data.frame(Case = c("N20-observed", "N20-b09", "N20-b19", "N60-observed", "N240-observed"),
      Parent = c("N20", "N20", "N20", "N60", "N240"),
      Draw = c("observed", "b09", "b19", "observed", "observed"))
    jobs <- merge(cases, expand.grid(Kind = c("free", "null"),
      Start = c("retained", "neutral"), stringsAsFactors = FALSE), by = NULL, sort = FALSE)
    jobs$Key <- with(jobs, paste(Case, Kind, Start, sep = "-"))
    dir.create(est_out, recursive = TRUE, showWarnings = FALSE)
    manifest <- list(cases = cases, jobs = jobs, point_jobs = reference$jobs, plan = reference$plan,
      inputs = tools::md5sum(unique(c(ref_manifest, ref_summary, names(reference$inputs),
        names(reference_summary$result_hashes)))),
      sources = tools::md5sum(c(est_script, seg_script, list.files("R", full.names = TRUE),
        "tests/testthat/test-gmfrm-segmented.R", "src/mfrmr.so")),
      session = sessionInfo(), threads = Sys.getenv(c("OPENBLAS_NUM_THREADS", "OMP_NUM_THREADS",
        "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")),
      policy = c("20 attempts on five saved datasets; original parent and zero starts; free and original Task-t1 null.",
        "One BFGS stage, maxit 400, reltol 1e-12, fnscale N; typed numerical rejection; no rescue or slope caps.",
        "16/32 Legendre agreement 1e-7 NLL, 1e-6 score; tail bounds 1e-8 NLL, 1e-7 score.",
        "Terminal code 0, reference qualified, relevant score <=1e-4, NLL agreement <=1e-5, gradient agreement <=1e-6.",
        "Null constraint <=1e-8; two-start reference NLL spread <=1e-5. No Hessian/LR/interval qualification."))
    stopifnot(unname(tools::md5sum(getLoadedDLLs()[["mfrmr"]][["path"]])) == unname(manifest$sources["src/mfrmr.so"]))
    saveRDS(manifest, path)
    cat("Bound 88 checks and 20 attempts before evaluation; no new generation.\n")
    return(invisible(NULL))
  }
  m <- readRDS(path); seg_hash_check(m$inputs)
  # A saved-result summary verifies its phase bindings below, without running
  # the current evaluator. Numerical work still requires the exact epoch source.
  if (args[1] != "summarize") seg_hash_check(m$sources)
  stopifnot(identical(R.version.string, m$session$R.version$version.string),
    identical(Sys.getenv(names(m$threads)), m$threads))
  seal <- tools::md5sum(path)
  phase <- function(key, calculate, input = character()) {
    dest <- file.path(est_out, paste0(key, ".rds")); hashes <- tools::md5sum(input)
    if (file.exists(dest)) {
      x <- readRDS(dest); stopifnot(identical(x$manifest, seal), identical(x$inputs, hashes)); return(x)
    }
    error <- ""; warnings <- character(); value <- NULL
    elapsed <- system.time(withCallingHandlers(tryCatch(value <- calculate(),
      error = function(e) error <<- conditionMessage(e)), warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning") }))
    x <- list(manifest = seal, inputs = hashes, value = value, error = error,
      warnings = unique(warnings), seconds = unname(elapsed["elapsed"]))
    temp <- paste0(dest, ".tmp"); saveRDS(x, temp); stopifnot(file.rename(temp, dest))
    cat(key, if (nzchar(error)) error else "saved", x$seconds, "seconds\n"); flush.console()
    x
  }
  if (args[1] == "check") {
    checks <- lapply(seq_len(nrow(m$point_jobs)), function(i) {
      row <- m$point_jobs[i, ]; x <- seg_load(row, m$plan)
      phase(paste0("check-", row$Key), function() {
        ev <- est_context(x$fit, x$score)$evaluator
        result <- ev$evaluate(x$attempt$parameters)
        ref <- readRDS(file.path(seg_out, paste0(row$Key, ".rds")))$value
        error <- c(NLL = abs(result$value - ref$nll), Gradient = max(abs(result$gradient + ref$score)))
        list(passed = all(error <= c(1e-7, 1e-6)), error = error, integration = result$integration)
      })
    })
    stopifnot(all(vapply(checks, function(x) !nzchar(x$error) && isTRUE(x$value$passed), TRUE)))
    cat("All 88 native-coordinate checks passed.\n")
    return(invisible(NULL))
  }
  if (args[1] == "run") {
    check_files <- file.path(est_out, paste0("check-", m$point_jobs$Key, ".rds"))
    checks <- lapply(check_files, readRDS)
    stopifnot(all(vapply(checks, function(x) identical(x$manifest, seal) &&
      !nzchar(x$error) && isTRUE(x$value$passed), TRUE)))
    jobs <- m$jobs
    if (length(args) > 1L) {
      stopifnot(length(args) == 2L, args[2] %in% m$cases$Case)
      jobs <- jobs[jobs$Case == args[2], ]
    }
    for (i in seq_len(nrow(jobs))) {
      job <- jobs[i, ]; parent <- seg_parent(m$plan$Path[match(job$Parent, m$plan$Case)])
      score <- if (job$Draw != "observed") readRDS(file.path(seg_old, job$Parent,
        paste0(job$Draw, "-generation.rds")))$value$score else NULL
      p <- parent$opt$par; model <- seg_design(parent, p, score)
      C <- numeric(length(p)); C[model$nb + 1L] <- 1
      target <- sum(C * p) + .5
      fit_record <- phase(paste0("fit-", job$Key), function() {
        setup <- est_context(parent, score); ev <- setup$evaluator
        start <- if (job$Start == "retained") p else rep(0, length(p))
        map <- if (job$Kind == "null") est_fn("mfrm_gpcm_profile_constraint")(start, C, target) else
          list(free = seq_along(p), basis = diag(length(p)), embed = identity)
        safe <- est_fn("make_mfrm_boundary_safe_objective")(ev)
        ev$value(map$embed(start[map$free]))
        improvements <- list(); best <- Inf
        fn <- function(z) {
          par <- map$embed(z); value <- safe$value(par)
          if (is.finite(value) && value < best && value < safe$penalty) {
            best <<- value; state <- ev$evaluate(par)
            improvements[[length(improvements) + 1L]] <<- data.frame(
              Evaluation = ev$diagnostics()$Evaluations, NLL = value,
              Score = max(abs(crossprod(map$basis, state$gradient))),
              MaxAbsParameter = max(abs(par)),
              MaxSlope = max(est_fn("expand_params")(par, setup$sizes, setup$config)$slopes))
          }
          value
        }
        gr <- function(z) drop(crossprod(map$basis, safe$gradient(map$embed(z))))
        opt <- stats::optim(start[map$free], fn, gr, method = "BFGS",
          control = list(maxit = 400L, reltol = 1e-12, fnscale = parent$config$n_person))
        par <- map$embed(opt$par); terminal <- ev$evaluate(par)
        list(parameters = par, optimizer = opt, terminal = terminal,
          projected_gradient = drop(crossprod(map$basis, terminal$gradient)),
          max_slope = max(est_fn("expand_params")(par, setup$sizes, setup$config)$slopes),
          constraint_error = if (job$Kind == "null") abs(sum(C * par) - target) else 0,
          rejections = c(slope = safe$rejections(), quadrature = safe$adaptive_quadrature_rejections()),
          evaluations = ev$diagnostics(), improvements = do.call(rbind, improvements))
      }, check_files)
      phase(paste0("reference-", job$Key), function() {
        if (nzchar(fit_record$error)) stop(fit_record$error)
        a <- fit_record$value
        ref <- seg_reference(seg_design(parent, a$parameters, score))
        gradient <- -ref$score
        if (job$Kind == "null") gradient <- gradient[-(model$nb + 1L)]
        check <- c(NLLDifference = abs(ref$nll - a$terminal$value),
          GradientDifference = max(abs(gradient - a$projected_gradient)),
          ReferenceScore = max(abs(gradient)), ConstraintError = a$constraint_error)
        passed <- a$optimizer$convergence == 0L && ref$qualified &&
          all(is.finite(check)) && all(check <= c(1e-5, 1e-6, 1e-4, 1e-8))
        list(passed = passed, check = check, reference = ref)
      }, file.path(est_out, paste0("fit-", job$Key, ".rds")))
    }
    return(invisible(NULL))
  }
  rows <- lapply(seq_len(nrow(m$jobs)), function(i) {
    job <- m$jobs[i, ]; fp <- file.path(est_out, paste0("fit-", job$Key, ".rds"))
    rp <- file.path(est_out, paste0("reference-", job$Key, ".rds"))
    f <- readRDS(fp); r <- readRDS(rp); a <- f$value; v <- r$value
    stopifnot(identical(f$manifest, seal), identical(r$manifest, seal))
    seg_hash_check(f$inputs); seg_hash_check(r$inputs)
    data.frame(job, Passed = isTRUE(v$passed), FitError = f$error, ReferenceError = r$error,
      FitSeconds = f$seconds, ReferenceSeconds = r$seconds,
      Code = if (is.null(a)) NA_integer_ else a$optimizer$convergence,
      NLL = if (is.null(v)) NA_real_ else v$reference$nll,
      Score = if (is.null(v)) NA_real_ else v$check["ReferenceScore"],
      GradientDifference = if (is.null(v)) NA_real_ else v$check["GradientDifference"],
      NLLDifference = if (is.null(v)) NA_real_ else v$check["NLLDifference"],
      MaxSlope = if (is.null(a)) NA_real_ else a$max_slope,
      Evaluations = if (is.null(a)) NA_integer_ else a$evaluations$Evaluations)
  })
  attempts <- do.call(rbind, rows)
  pairs <- do.call(rbind, lapply(split(attempts, interaction(attempts$Case, attempts$Kind, drop = TRUE)), function(x)
    data.frame(Case = x$Case[1], Kind = x$Kind[1], Attempts = nrow(x),
      PointPasses = sum(x$Passed), StartSpread = diff(range(x$NLL)),
      Passed = nrow(x) == 2L && all(x$Passed) && all(is.finite(x$NLL)) && diff(range(x$NLL)) <= 1e-5)))
  write.csv(attempts, file.path(est_out, "attempts.csv"), row.names = FALSE)
  write.csv(pairs, file.path(est_out, "pairs.csv"), row.names = FALSE)
  saveRDS(list(attempts = attempts, pairs = pairs, inputs = m$inputs,
    results = tools::md5sum(list.files(est_out, pattern = "^(check|fit|reference)-.*[.]rds$", full.names = TRUE))),
    file.path(est_out, "summary.rds"))
  print(attempts, row.names = FALSE); print(pairs, row.names = FALSE)
}
if (sys.nframe() == 0L) est_main(commandArgs(trailingOnly = TRUE))
