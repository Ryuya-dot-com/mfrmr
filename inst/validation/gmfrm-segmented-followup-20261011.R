# Authorized numerical diagnosis, separate from the frozen candidate study.
# Rscript --vanilla this-file prepare | run KEY | curvature KEY | summarize
source("inst/validation/gmfrm-segmented-estimation-20261011.R")
fu_script <- "inst/validation/gmfrm-segmented-followup-20261011.R"
fu_out <- "validation-results/gmfrm-segmented-followup-20261011"
fu_setup <- function(job, manifest) {
  parent <- seg_parent(manifest$original$plan$Path[
    match(job$Parent, manifest$original$plan$Case)])
  score <- if (job$Draw != "observed") readRDS(file.path(seg_old, job$Parent,
    paste0(job$Draw, "-generation.rds")))$value$score else NULL
  setup <- est_context(parent, score); p <- parent$opt$par
  model <- seg_design(parent, p, score); C <- numeric(length(p)); C[model$nb + 1L] <- 1
  start <- if (job$Start == "retained") p else rep(0, length(p))
  map <- if (job$Kind == "null") est_fn("mfrm_gpcm_profile_constraint")(start, C, sum(C * p) + .5) else
    list(free = seq_along(p), basis = diag(length(p)), embed = identity)
  list(parent = parent, score = score, setup = setup, map = map, start = start)
}
fu_reference <- function(x, par, terminal) {
  ref <- seg_reference(seg_design(x$parent, par, x$score))
  g <- -drop(crossprod(x$map$basis, ref$score))
  check <- c(NLLDifference = abs(ref$nll - terminal$value),
    GradientDifference = max(abs(g - drop(crossprod(x$map$basis, terminal$gradient)))),
    ReferenceScore = max(abs(g)), ConstraintError = max(abs(x$map$embed(par[x$map$free]) - par)))
  list(reference = ref, check = check, passed = ref$qualified &&
    all(is.finite(check)) && all(check <= c(1e-5, 1e-6, 1e-4, 1e-8)))
}
fu_main <- function(args) {
  pkgload::load_all(quiet = TRUE, compile = FALSE)
  path <- file.path(fu_out, "manifest.rds")
  if (args[1] == "prepare") {
    stopifnot(!file.exists(path))
    original <- readRDS(file.path(est_out, "manifest.rds"))
    summary <- readRDS(file.path(est_out, "summary.rds"))
    seg_hash_check(original$inputs); seg_hash_check(summary$results)
    jobs <- summary$attempts[!summary$attempts$Passed, ]
    jobs$Action <- ifelse(is.na(jobs$Code), "reproduce", ifelse(jobs$Code == 1, "extend", "curvature"))
    sources <- unique(c(fu_script, est_script, seg_script, list.files("R", full.names = TRUE), "src/mfrmr.so"))
    dir.create(fu_out, recursive = TRUE, showWarnings = FALSE)
    manifest <- list(original = original, jobs = jobs,
      inputs = tools::md5sum(unique(c(file.path(est_out, c("manifest.rds", "summary.rds")),
        names(original$inputs), names(summary$results)))), sources = tools::md5sum(sources),
      session = sessionInfo(), threads = Sys.getenv(c("OPENBLAS_NUM_THREADS", "OMP_NUM_THREADS",
        "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")),
      policy = c("Seven original starts: BFGS maxit 2000, reltol 1e-12, fnscale N; compare original prefix.",
        "One exact maxit 400 replay with failure telemetry; no changed arithmetic.",
        "Three code-zero failures: score central differences h=1e-3,1e-4, then one SPD Newton correction.",
        "Preserve old score/integration/constraint/start criteria; no public adoption or inference qualification."))
    saveRDS(manifest, path)
    for (s in sources) {
      dest <- file.path(fu_out, "epoch-source", s); dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
      stopifnot(file.copy(s, dest, overwrite = FALSE))
    }
    print(jobs[, c("Key", "Action")], row.names = FALSE); return(invisible(NULL))
  }
  manifest <- readRDS(path); seg_hash_check(manifest$inputs)
  if (args[1] != "summarize") seg_hash_check(manifest$sources)
  seal <- tools::md5sum(path)
  if (args[1] == "summarize") {
    files <- list.files(fu_out, "^(run|curvature)-.*[.]rds$", full.names = TRUE)
    for (f in files) {
      a <- readRDS(f); stopifnot(identical(a$manifest, seal))
      cat(basename(f), "error:", a$error, "seconds:", a$seconds, "\n")
      print(a$value[c("code", "check", "prefix", "curvature", "failures")])
    }
    return(invisible(NULL))
  }
  stopifnot(length(args) == 2L, args[2] %in% manifest$jobs$Key,
    identical(R.version.string, manifest$session$R.version$version.string),
    identical(Sys.getenv(names(manifest$threads)), manifest$threads))
  job <- manifest$jobs[manifest$jobs$Key == args[2], ]; x <- fu_setup(job, manifest)
  dest <- file.path(fu_out, paste0(args[1], "-", job$Key, ".rds"))
  if (file.exists(dest)) { stopifnot(identical(readRDS(dest)$manifest, seal)); return(invisible(NULL)) }
  original <- readRDS(file.path(est_out, paste0("fit-", job$Key, ".rds")))$value
  ev <- x$setup$evaluator; map <- x$map
  failures <- list(); improvements <- list(); best <- Inf; best_par <- NULL; opt <- NULL
  raw_evaluate <- ev$evaluate
  evaluate <- function(par) tryCatch(raw_evaluate(par), error = function(e) {
    # Retain all refusals, even those caught by the boundary-safe objective.
    failures[[length(failures) + 1L]] <<- e
    stop(e)
  })
  ev$value <- function(par) evaluate(par)$value
  ev$gradient <- function(par) evaluate(par)$gradient
  safe <- est_fn("make_mfrm_boundary_safe_objective")(ev)
  fn <- function(z) {
    par <- map$embed(z); value <- safe$value(par)
    if (is.finite(value) && value < best && value < safe$penalty) {
      best <<- value; best_par <<- par; state <- evaluate(par)
      improvements[[length(improvements) + 1L]] <<- data.frame(Evaluation = ev$diagnostics()$Evaluations,
        NLL = value, Score = max(abs(crossprod(map$basis, state$gradient))),
        MaxAbsParameter = max(abs(par)),
        MaxSlope = max(est_fn("expand_params")(par, x$setup$sizes, x$setup$config)$slopes))
    }
    value
  }
  gr <- function(z) drop(crossprod(map$basis, safe$gradient(map$embed(z))))
  value <- NULL; error <- ""
  timing <- system.time(tryCatch({
    if (args[1] == "run") {
      stopifnot(job$Action %in% c("extend", "reproduce"))
      ev$value(map$embed(x$start[map$free]))
      opt <- stats::optim(x$start[map$free], fn, gr, method = "BFGS",
        control = list(maxit = if (job$Action == "extend") 2000L else 400L,
          reltol = 1e-12, fnscale = x$parent$config$n_person))
      par <- map$embed(opt$par); terminal <- evaluate(par)
      ref <- fu_reference(x, par, terminal)
      trace <- do.call(rbind, improvements)
      prefix <- if (!is.null(original)) all.equal(head(trace, nrow(original$improvements)),
        original$improvements, tolerance = 1e-12) else NA
      value <- list(parameters = par, terminal = terminal, code = opt$convergence,
        check = ref$check, reference = ref, prefix = prefix)
    } else {
      stopifnot(args[1] == "curvature", job$Action == "curvature")
      z <- original$parameters[map$free]; g <- gr(z)
      hess <- lapply(c(1e-3, 1e-4), function(h) {
        H <- vapply(seq_along(z), function(j) {
          d <- numeric(length(z)); d[j] <- h
          (gr(z + d) - gr(z - d)) / (2 * h)
        }, numeric(length(z)))
        list(raw = H, symmetric = (H + t(H)) / 2)
      })
      H <- hess[[2]]$symmetric; lambda <- eigen(H, symmetric = TRUE)$values
      stopifnot(min(lambda) > 0)
      step <- solve(H, g); proposed <- z - step
      terminal <- evaluate(map$embed(proposed)); before <- evaluate(map$embed(z))
      ref <- fu_reference(x, map$embed(proposed), terminal)
      curvature <- c(EigenMin = min(lambda), EigenMax = max(lambda), Condition = max(lambda) / min(lambda),
        HessianStepDifference = max(abs(hess[[1]]$symmetric - H)),
        HessianAsymmetry = max(abs(hess[[2]]$raw - t(hess[[2]]$raw))),
        PredictedDecrease = sum(g * step) / 2, ActualDecrease = before$value - terminal$value,
        RelativeStopThreshold = 1e-12 * abs(before$value),
        ParameterStep = max(abs(step)), OldScore = max(abs(g)),
        NewScore = max(abs(crossprod(map$basis, terminal$gradient))))
      value <- list(parameters = map$embed(proposed), terminal = terminal, check = ref$check,
        reference = ref, curvature = curvature, hessian = hess)
    }
  }, error = function(e) error <<- conditionMessage(e)))
  record <- list(manifest = seal, value = value, error = error, seconds = unname(timing["elapsed"]),
    optimizer = opt, best_parameters = best_par, improvements = do.call(rbind, improvements),
    failures = failures, evaluations = ev$diagnostics(),
    rejections = c(slope = safe$rejections(), quadrature = safe$adaptive_quadrature_rejections()))
  saveRDS(record, paste0(dest, ".tmp")); stopifnot(file.rename(paste0(dest, ".tmp"), dest))
  cat(job$Key, "error:", error, "seconds:", record$seconds, "\n")
  print(value[c("code", "check", "prefix", "curvature")])
  if (length(failures)) print(lapply(failures, function(e) list(message = conditionMessage(e),
    evaluation = e$evaluation, integration = e$integration)))
}
if (sys.nframe() == 0L) fu_main(commandArgs(trailingOnly = TRUE))
