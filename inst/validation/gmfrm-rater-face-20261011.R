# Existing individual-rater boundary points, not new fits or LR calibration.
# From package root: Rscript --vanilla this-file prepare | run | verify
source("inst/validation/gmfrm-natural-20261011.R")
rf_script <- "inst/validation/gmfrm-rater-face-20261011.R"
rf_out <- "validation-results/gmfrm-rater-face-20261011"
rf_literal_source <- "tests/testthat/test-gmfrm-natural.R"
rf_literal <- eval(parse(rf_literal_source)[[1]][[3]])

rf_bounds <- function(plan, cases, interior) {
  answer <- list()
  for (j in seq_len(nrow(cases))) {
    job <- cases[j, ]; parent <- seg_parent(plan$Path[match(job$Parent, plan$Case)])
    spec <- parent$gmfrm$specification; d <- spec$data
    stopifnot(identical(spec$slope_facets, c("Task", "Rater")), spec$max_score == 2,
      all(parent$prep$data$Weight == 1))
    if (job$Draw != "observed") d[[spec$score]] <- readRDS(file.path(seg_old,
      job$Parent, paste0(job$Draw, "-generation.rds")))$value$score
    for (r in sort(unique(d$Rater))) {
      zero <- d[d$Rater == r, ]; count <- table(zero$Task, zero[[spec$score]])
      positive <- count > 0; prob <- count/rowSums(count)
      zero_nll <- -sum(count[positive]*log(prob[positive]))
      roster <- pattern <- character()
      for (rows in split(seq_len(nrow(d)), d[[spec$person]])) {
        x <- d[rows, ]; x <- x[x$Rater != r, ]; x <- x[order(x$Task, x$Rater), ]
        roster <- c(roster, paste(paste(x$Task, x$Rater, sep = "/"), collapse = ";"))
        pattern <- c(pattern, paste(x[[spec$score]], collapse = ","))
      }
      rest_nll <- sum(vapply(split(pattern, roster), function(y) {
        n <- table(y); -sum(n*log(n/sum(n)))
      }, 0))
      for (kind in c("free", "null")) {
        previous <- subset(interior, Case == job$Case & Kind == kind)
        stopifnot(nrow(previous) == 1L)
        answer[[length(answer) + 1L]] <- data.frame(Case = job$Case, Kind = kind, Rater = r,
          ZeroNLL = zero_nll, RemainderNLL = rest_nll, LowerNLL = zero_nll + rest_nll,
          InteriorNLL = previous$InteriorNLL, Margin = zero_nll + rest_nll - previous$InteriorNLL)
      }
    }
  }
  do.call(rbind, answer)
}

rf_table <- function(records) do.call(rbind, lapply(records, function(r) data.frame(
  Start = r$start, Status = r$status, NLL = r$value$value, FreeScore = r$free_score,
  Outward = r$value$gradient[21], TargetError = r$target_error,
  MinEigen = r$curvature["MinEigen"], MaxEigen = r$curvature["MaxEigen"],
  HessianStepDifference = r$curvature["StepDifference"],
  GradientReferenceDifference = r$gradient_difference,
  DirectionalReferenceDifference = r$directional_difference, Seconds = r$seconds, Error = r$error)))

rf_main <- function(action) {
  stopifnot(action %in% c("prepare", "run", "verify"))
  manifest <- file.path(rf_out, "manifest.rds")
  if (action == "prepare") {
    stopifnot(!file.exists(manifest))
    old <- readRDS(file.path(nat_out, "manifest.rds")); s <- readRDS(file.path(nat_out, "summary.rds"))
    envelope <- readRDS("validation-results/gmfrm-zero-envelope-20261011/results.rds")
    seg_hash_check(old$inputs); seg_hash_check(s$results); seg_hash_check(envelope$inputs)
    archived <- tools::md5sum(file.path(nat_out, "epoch-source", names(old$sources)))
    names(archived) <- names(old$sources); stopifnot(identical(archived, old$sources))
    jobs <- data.frame(Start = c("retained", "neutral"))
    jobs$Path <- file.path(nat_out, paste0("point-N20-b19-null-", jobs$Start, "-rater_intercepts-boundary.rds"))
    cases <- unique(old$points[c("Case", "Parent", "Draw")])
    m <- list(jobs = jobs, cases = cases, plan = old$plan, interior = envelope$table,
      original_manifest = tools::md5sum(file.path(nat_out, "manifest.rds")),
      sources = tools::md5sum(unique(c(rf_script, rf_literal_source, names(old$sources),
        list.files("R", full.names = TRUE), "src/mfrmr.so"))),
      inputs = tools::md5sum(unique(c(names(old$inputs), names(s$results), names(envelope$inputs),
        "validation-results/gmfrm-zero-envelope-20261011/results.rds",
        file.path(nat_out, c("manifest.rds", "summary.rds", "verification.rds"))))),
      session = sessionInfo(), threads = Sys.getenv(c("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS",
        "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")),
      policy = c("60 saturated individual-zero screening comparisons, five datasets times six raters times free/null.",
        "Audit only two saved b19-null c5=0 points, original alpha15 fixed. No fit, RNG or new start.",
        "20 free scores <=1e-4; outward21>0; other c>0; target exact; old NLL/outward reference <=1e-7/1e-6.",
        "Natural-score Hessian steps 1e-4/5e-5 times max(1,abs(z)); relative spectral step discrepancy <=1e-5.",
        "Minimum eigenvalue >max(1e-7*max(1,max(abs(eigenvalues))),10*absolute spectral step discrepancy).",
        "Independent integrated-NLL score Richardson differences <=1e-6 at the same two step scales.",
        "Independent directional curvature at 1e-3/5e-4 along extreme eigenvectors and three sine vectors, relative <=1e-4.",
        "Keep failures and integration errors. Local-face/KKT evidence only; no global or interval qualification."))
    dir.create(rf_out, recursive = TRUE, showWarnings = FALSE)
    m$bounds <- rf_bounds(m$plan, m$cases, m$interior)
    saveRDS(m, manifest); write.csv(m$bounds, file.path(rf_out, "bounds.csv"), row.names = FALSE)
    for (path in c(rf_script, rf_literal_source)) {
      dest <- file.path(rf_out, "epoch-source", path); dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
      stopifnot(file.copy(path, dest, overwrite = FALSE))
    }
    cat("Bound 60 screenings and two existing-point audits; no optimization allocated.\n")
    return(invisible(NULL))
  }
  m <- readRDS(manifest); seal <- tools::md5sum(manifest)
  seg_hash_check(m$inputs); seg_hash_check(m$sources)
  files <- file.path(rf_out, paste0("point-", m$jobs$Start, ".rds"))
  if (action == "verify") {
    records <- lapply(files, readRDS); summary <- readRDS(file.path(rf_out, "summary.rds"))
    seg_hash_check(summary$results)
    stopifnot(identical(summary$table, rf_table(records)), identical(summary$manifest, seal),
      identical(m$bounds, rf_bounds(m$plan, m$cases, m$interior)),
      all(vapply(records, function(r) identical(r$manifest, seal), TRUE)))
    for (r in records) if (r$status == "local_face_candidate") stopifnot(
      r$free_score <= 1e-4, r$value$gradient[21] > 0, r$target_error == 0,
      all(r$reference_checks <= c(1e-7, 1e-6, 1e-12)), r$curvature_ok,
      r$gradient_difference <= 1e-6, r$directional_difference <= 1e-4)
    saveRDS(list(manifest = seal, sources = m$sources, inputs = m$inputs,
      results = summary$results, session = sessionInfo(),
      note = "Fresh replay; package loading, fitting, quadrature and RNG disabled."),
      file.path(rf_out, "verification.rds"))
    print(summary$table, row.names = FALSE)
    cat("Fresh numerical-work-disabled replay passed.\n"); return(invisible(NULL))
  }
  stopifnot(identical(Sys.getenv(names(m$threads)), m$threads))
  stopifnot(identical(sessionInfo(), m$session))
  parent <- seg_parent(m$plan$Path[m$plan$Case == "N20"])
  score <- readRDS(file.path(seg_old, "N20", "b19-generation.rds"))$value$score
  x <- est_context(parent, score); spec <- x$fit$gmfrm$specification
  idx <- est_fn("build_indices")(x$fit$prep, x$config$step_facet, x$config$slope_facet,
    x$config$interaction_specs, gpcm_spec = x$config$gpcm_spec)
  ev <- est_fn("mfrm_gmfrm_natural_evaluator")(idx, x$config, x$sizes, "rater_intercepts")
  for (j in seq_len(nrow(m$jobs))) {
    if (file.exists(files[j])) { stopifnot(identical(readRDS(files[j])$manifest, seal)); next }
    previous <- readRDS(m$jobs$Path[j]); stopifnot(identical(previous$manifest, m$original_manifest))
    z <- previous$coordinates; free <- setdiff(seq_along(z), c(15L, 21L))
    stopifnot(length(z) == 22, z[21] == 0, all(z[c(17:20,22)] > 0))
    r <- list(manifest = seal, start = m$jobs$Start[j], coordinates = z,
      status = "unresolved", error = "", value = list(value = NA_real_, gradient = rep(NA_real_,22)),
      free_score = NA_real_, target_error = NA_real_, curvature = rep(NA_real_,5),
      gradient_difference = NA_real_, directional_difference = NA_real_, curvature_ok = FALSE)
    names(r$curvature) <- c("MinEigen", "MaxEigen", "StepDifference", "RelativeStepDifference", "Resolution")
    timing <- system.time(tryCatch({
      r$value <- ev$evaluate(z); r$free_score <- max(abs(r$value$gradient[free]))
      r$target_error <- abs(z[15] - (parent$opt$par[15] + .5))
      r$reference_checks <- c(NLL = abs(r$value$value - previous$reference[1]),
        Outward = abs(r$value$gradient[21] - previous$reference[2]),
        SavedScore = max(abs(r$value$gradient - previous$value$gradient)))
      H <- lapply(c(1e-4, 5e-5), function(h) vapply(free, function(k) {
        step <- replace(z*0, k, h*max(1,abs(z[k])))
        (ev$gradient(z+step)[free] - ev$gradient(z-step)[free])/(2*step[k])
      }, numeric(length(free))))
      symmetric <- lapply(H, function(h) (h+t(h))/2)
      r$hessian <- (4*symmetric[[2]] - symmetric[[1]])/3
      eigen <- eigen(r$hessian, symmetric = TRUE); spread <- norm(symmetric[[1]]-symmetric[[2]],"2")
      r$curvature <- c(MinEigen = min(eigen$values), MaxEigen = max(eigen$values),
        StepDifference = spread, RelativeStepDifference = spread/max(1,norm(r$hessian,"2")),
        Resolution = max(1e-7*max(1,max(abs(eigen$values))),10*spread))
      r$curvature_ok <- r$curvature["RelativeStepDifference"] <= 1e-5 &&
        r$curvature["MinEigen"] > r$curvature["Resolution"]
      cat(r$start, "active curvature evaluated\n"); flush.console()
      nll <- function(par) rf_literal(par, "rater_intercepts", spec)
      central <- lapply(c(1e-4,5e-5), function(h) vapply(free, function(k) {
        step <- replace(z*0,k,h*max(1,abs(z[k]))); (nll(z+step)-nll(z-step))/(2*step[k])
      }, 0))
      r$independent_gradient <- (4*central[[2]] - central[[1]])/3
      r$gradient_difference <- max(abs(r$independent_gradient - r$value$gradient[free]))
      cat(r$start, "independent scores evaluated\n"); flush.console()
      directions <- cbind(eigen$vectors[,length(free)],eigen$vectors[,1],
        vapply(1:3,function(k) sin(seq_along(free)*k),numeric(length(free))))
      directions <- sweep(directions,2,sqrt(colSums(directions^2)),"/")
      at <- nll(z)
      d2 <- lapply(c(1e-3,5e-4),function(h) apply(directions,2,function(d) {
        step <- z*0; step[free] <- h*d; (nll(z+step)-2*at+nll(z-step))/h^2
      }))
      numerical <- (4*d2[[2]] - d2[[1]])/3
      analytic <- diag(crossprod(directions,r$hessian %*% directions))
      r$directional <- data.frame(Analytic=analytic,Independent=numerical,
        StepDifference=abs(d2[[1]]-d2[[2]]),RelativeDifference=abs(analytic-numerical)/pmax(1,abs(analytic)))
      r$directional_difference <- max(r$directional$RelativeDifference)
      if (r$free_score <= 1e-4 && r$value$gradient[21] > 0 && r$target_error == 0 &&
        all(r$reference_checks <= c(1e-7,1e-6,1e-12)) && r$curvature_ok &&
        r$gradient_difference <= 1e-6 && r$directional_difference <= 1e-4)
        r$status <- "local_face_candidate"
    },error=function(e) r$error <<- conditionMessage(e)))
    r$seconds <- unname(timing["elapsed"]); saveRDS(r,files[j])
    cat(r$start,r$status,r$seconds,r$error,"\n"); flush.console()
  }
  records <- lapply(files,readRDS); table <- rf_table(records)
  saveRDS(list(manifest=seal,results=tools::md5sum(files),table=table),file.path(rf_out,"summary.rds"))
  write.csv(table,file.path(rf_out,"points.csv"),row.names=FALSE); print(table,row.names=FALSE)
}
if (sys.nframe() == 0L) {
  action <- commandArgs(trailingOnly = TRUE)
  # Package loading initializes a fixed example fixture; block research RNG
  # after this existing initialization, before the audit or manifest is made.
  if (!identical(action,"verify")) pkgload::load_all(quiet = TRUE, compile = FALSE)
  blocked <- function(...) stop("Existing-point audit attempted forbidden numerical work.")
  for (name in c("optim", "optimHess", "nlminb", "rnorm")) assignInNamespace(name,blocked,ns="stats")
  if (identical(action,"verify")) {
    for (name in c("integrate","uniroot")) assignInNamespace(name,blocked,ns="stats")
    assignInNamespace("load_all",blocked,ns="pkgload")
  }
  rf_main(action)
}
