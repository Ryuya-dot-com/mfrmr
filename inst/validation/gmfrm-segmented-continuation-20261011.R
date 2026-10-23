# Reuse all eight saved endpoints; no new data or bootstrap allocation.
source("inst/validation/gmfrm-segmented-scaling-20261011.R")
source("inst/validation/gmfrm-local-coordinates-20261011.R")
ct_script <- "inst/validation/gmfrm-segmented-continuation-20261011.R"
ct_out <- "validation-results/gmfrm-segmented-continuation-20261011"
ct_reference <- function(x, par, terminal) {
  model <- seg_design(x$parent, par, x$score)
  people <- lapply(model$groups, function(rows) seg_person(model, rows))
  values <- lapply(c(32L, 64L), function(order) {
    rule <- seg_rule(order)
    per <- lapply(seq_along(people), function(j)
      local_integral(model, model$groups[[j]], people[[j]], rule))
    list(people = per, nll = -sum(vapply(per, `[[`, 0, "log_marginal")),
      score = Reduce(`+`, lapply(per, `[[`, "score")))
  })
  tails <- lapply(seq_along(people), function(j) {
    p <- people[[j]]; v <- values[[2]]$people[[j]]
    mass <- exp(v$log_marginal - p$peak)
    c(NLL = log1p(p$tail_mass / mass),
      (p$tail_score + abs(v$score) * p$tail_mass) / mass)
  })
  # Retain the original independent scalar normalizer check as well as
  # the repaired literal score. Its refusal remains a refusal.
  original <- seg_reference(model)
  ref <- values[[2]]; project <- function(g) drop(crossprod(x$map$basis, g))
  checks <- c(NLLDifference = abs(ref$nll - terminal$value),
    GradientDifference = max(abs(project(ref$score + terminal$gradient))),
    ReferenceScore = max(abs(project(ref$score))),
    NLLRuleDifference = abs(ref$nll - values[[1]]$nll),
    ScoreRuleDifference = max(abs(ref$score - values[[1]]$score)),
    ConstraintError = max(abs(x$map$embed(par[x$map$free]) - par)),
    NLLGKDifference = abs(ref$nll + sum(vapply(original$people, `[[`, 0, "gk_log_marginal"))),
    GKEstimatedRelativeError = unname(original$checks["GKEstimatedRelativeError"]),
    TailNLLBound = sum(vapply(tails, function(x) x[1], 0)),
    TailScoreBound = max(Reduce(`+`, lapply(tails, function(x) x[-1]))))
  list(values = values, checks = checks,
    passed = all(is.finite(checks)) && all(checks <= c(1e-5, 1e-6, 1e-4, 1e-7, 1e-6, 1e-8, 1e-7, 1e-8, 1e-8, 1e-7)))
}
ct_main <- function(args) {
  pkgload::load_all(quiet = TRUE, compile = FALSE)
  path <- file.path(ct_out, "manifest.rds")
  if (args[1] == "prepare") {
    stopifnot(!file.exists(path))
    previous <- readRDS(file.path(sc_out, "manifest.rds"))
    seg_hash_check(previous$inputs); seg_hash_check(previous$sources)
    geometry <- file.path(sc_out, paste0("geometry-", previous$jobs$Key, ".rds"))
    stopifnot(all(vapply(lapply(geometry, readRDS), function(x)
      !nzchar(x$error) && identical(x$manifest, tools::md5sum(file.path(sc_out, "manifest.rds"))), TRUE)))
    sources <- c(ct_script, sc_script, fu_script, est_script, seg_script,
      "inst/validation/gmfrm-local-coordinates-20261011.R",
      list.files("R", full.names = TRUE), "tests/testthat/test-gmfrm-segmented-optimizer.R", "src/mfrmr.so")
    m <- list(previous = previous, jobs = previous$jobs,
      inputs = tools::md5sum(unique(c(file.path(sc_out, "manifest.rds"), geometry, names(previous$inputs)))),
      sources = tools::md5sum(sources), session = sessionInfo(), threads = previous$threads,
      policy = c("All eight saved endpoints; at most three curvature-scaled BFGS stages, maxit 400, reltol 1e-13, total NLL.",
        "Same native score <=1e-4; also positive curvature ratio >1e-10 and Newton predicted decrease <=1e-6.",
        "One existing SPD Newton correction after code-zero score failure. No bounds, priors, likelihood or null changes.",
        "Preserve best valid point and stage checkpoints; numerical failure is a refusal, not convergence.",
        "Check each terminal using two finite-difference Hessians: both positive, eigenvalue ratio >1e-10, curvature-relative step discrepancy <=.01.",
        "Independent literal local-coordinate 32/64 integration, original scalar GK normalizer and tail criteria remain required.",
        "No automatic further iteration, new responses, bootstrap or public adoption. N60/N240 evidence remains in scope."))
    dir.create(ct_out, recursive = TRUE, showWarnings = FALSE); saveRDS(m, path)
    for (s in sources) {
      dest <- file.path(ct_out, "epoch-source", s); dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
      stopifnot(file.copy(s, dest, overwrite = FALSE))
    }
    return(invisible(NULL))
  }
  m <- readRDS(path); seg_hash_check(m$inputs)
  seal <- tools::md5sum(path)
  if (args[1] == "summarize") {
    files <- file.path(ct_out, paste0("run-", m$jobs$Key, ".rds"))
    records <- lapply(files, readRDS)
    stopifnot(all(vapply(records, function(x) identical(x$manifest, seal), TRUE)))
    rows <- lapply(seq_along(records), function(i) {
      r <- records[[i]]; v <- r$value; fit <- v$fit; g <- v$geometry$metrics
      before <- readRDS(file.path(sc_out, paste0("geometry-", m$jobs$Key[i], ".rds")))$value
      data.frame(Key = m$jobs$Key[i], Error = r$error, Status = if (is.null(fit)) "error" else fit$status,
        Stages = length(fit$stages), NLL = if (is.null(fit)) NA_real_ else fit$selected$value,
        Decrease = if (is.null(fit)) NA_real_ else before$terminal$value - fit$selected$value,
        Score = if (is.null(fit)) NA_real_ else max(abs(fit$selected$gradient)),
        MinSlope = if (is.null(v$slopes)) NA_real_ else min(v$slopes),
        MaxSlope = if (is.null(v$slopes)) NA_real_ else max(v$slopes),
        ParameterDrift = if (is.null(v$parameters)) NA_real_ else max(abs(v$parameters - before$parameters)),
        EigenMin = if (is.null(g)) NA_real_ else g["EigenMin"],
        HessianDifference = if (is.null(g)) NA_real_ else g["StepDifference"],
        GeometryPassed = isTRUE(v$geometry_passed),
        ReferencePassed = isTRUE(v$reference$passed),
        LocalCandidate = !nzchar(r$error) && identical(fit$status, "stationary_local_candidate") &&
          isTRUE(v$geometry_passed) && isTRUE(v$reference$passed),
        Seconds = r$seconds)
    })
    table <- do.call(rbind, rows); rownames(table) <- NULL
    write.csv(table, file.path(ct_out, "attempts.csv"), row.names = FALSE)
    saveRDS(list(manifest = seal, results = tools::md5sum(files), attempts = table), file.path(ct_out, "summary.rds"))
    print(table, row.names = FALSE); return(invisible(NULL))
  }
  seg_hash_check(m$sources)
  stopifnot(identical(R.version.string, m$session$R.version$version.string),
    identical(Sys.getenv(names(m$threads)), m$threads),
    args[1] == "run", length(args) == 2, args[2] %in% m$jobs$Key)
  job <- m$jobs[m$jobs$Key == args[2], ]; dest <- file.path(ct_out, paste0("run-", job$Key, ".rds"))
  if (file.exists(dest)) { stopifnot(identical(readRDS(dest)$manifest, seal)); return(invisible(NULL)) }
  checkpoint <- file.path(ct_out, paste0("stages-", job$Key, ".rds"))
  stopifnot(!file.exists(checkpoint))
  x <- fu_setup(job, m$previous$followup); ev <- x$setup$evaluator; map <- x$map
  start <- readRDS(file.path(sc_out, paste0("geometry-", job$Key, ".rds")))$value$parameters
  failures <- list()
  evaluate <- function(z) tryCatch(ev$evaluate(map$embed(z)), error = function(e) {
    failures[[length(failures) + 1L]] <<- list(message = conditionMessage(e),
      parameters = e$parameters, integration = e$integration, evaluation = e$evaluation)
    stop(e)
  })
  reduced <- list(value = function(z) evaluate(z)$value,
    gradient = function(z) drop(crossprod(map$basis, evaluate(z)$gradient)))
  value <- list(); error <- ""
  elapsed <- system.time(tryCatch({
    value$fit <- est_fn("mfrm_gmfrm_segmented_continue")(start[map$free], reduced,
      function(stages) {
        saveRDS(list(manifest = seal, stages = stages, failures = failures), paste0(checkpoint, ".tmp"))
        stopifnot(file.rename(paste0(checkpoint, ".tmp"), checkpoint))
        cat(job$Key, "stage", length(stages), "NLL", tail(stages, 1)[[1]]$selected$value,
          "score", max(abs(tail(stages, 1)[[1]]$selected$gradient)), "\n"); flush.console()
      })
    value$parameters <- map$embed(value$fit$selected$par)
    value$terminal <- ev$evaluate(value$parameters)
    value$slopes <- est_fn("expand_params")(value$parameters, x$setup$sizes, x$setup$config)$slopes
    value$geometry <- sc_geometry(value$fit$selected$par, reduced$gradient)
    geometry <- value$geometry; eig <- geometry$eigen
    transform <- sweep(eig$vectors, 2, sqrt(pmax(abs(eig$values), max(abs(eig$values)) * 1e-10)), "/")
    difference <- geometry$hessian[[1]]$symmetric - geometry$hessian[[2]]$symmetric
    value$curvature_relative_difference <- max(abs(eigen(crossprod(transform, difference %*% transform),
      symmetric = TRUE, only.values = TRUE)$values))
    value$geometry_passed <- min(eig$values) > max(abs(eig$values)) * 1e-10 &&
      min(eigen(geometry$hessian[[1]]$symmetric, symmetric = TRUE, only.values = TRUE)$values) > 0 &&
      value$curvature_relative_difference <= .01
    value$reference <- ct_reference(x, value$parameters, value$terminal)
  }, error = function(e) error <<- conditionMessage(e)))
  record <- list(manifest = seal, value = value, error = error,
    failures = failures, seconds = unname(elapsed["elapsed"]), evaluations = ev$diagnostics())
  saveRDS(record, paste0(dest, ".tmp")); stopifnot(file.rename(paste0(dest, ".tmp"), dest))
  cat(job$Key, "complete:", error, "seconds:", record$seconds, "\n")
  print(value$fit$status); print(value$reference$checks)
}
if (sys.nframe() == 0L) ct_main(commandArgs(trailingOnly = TRUE))
