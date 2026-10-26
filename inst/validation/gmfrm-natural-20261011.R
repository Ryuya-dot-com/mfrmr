# Direct natural-coordinate fixed points; no fitting, generation or inference.
# Rscript --vanilla this-file prepare | run | summarize
source("inst/validation/gmfrm-coordinates-20261011.R")
nat_script <- "inst/validation/gmfrm-natural-20261011.R"
nat_out <- "validation-results/gmfrm-natural-20261011"

# Independent literal equations: return NLL and the selected boundary derivative.
# This does not call a package decoder, kernel, derivative or quadrature rule.
nat_boundary_reference <- function(z, chart, spec, component) {
  d <- spec$data; K <- spec$max_score
  ids <- lapply(d[c(spec$person, spec$slope_facets)], function(x) match(x, sort(unique(x))))
  ni <- max(ids[[2]]); nr <- max(ids[[3]]); nb <- ni - 1L + nr * K
  b <- c(z[seq_len(ni - 1L)], -sum(z[seq_len(ni - 1L)]))
  ai <- exp(c(z[nb + seq_len(ni - 1L)], -sum(z[nb + seq_len(ni - 1L)])))
  r <- tail(z, nr); ii <- ids[[2]]; rr <- ids[[3]]
  if (chart == "rater_intercepts") {
    q <- matrix(z[ni - 1L + seq_len(nr * K)], nr, K, byrow = TRUE)
    w <- ai[ii]; a <- w * r[rr]
    intercept <- -w * (r[rr] * b[ii] + q[rr, , drop = FALSE])
    selected <- component - (length(z) - nr)
  } else {
    stopifnot(tail(r, 1L) == 0)
    rho <- exp(c(head(r, -1L), -sum(head(r, -1L))))
    w <- ai[ii] * rho[rr]; a <- w * 0
    s <- z[ni - 1L + seq_len(nr)]
    tau <- matrix(z[ni - 1L + nr + seq_len(nr * (K - 1L))], nr, K - 1L, byrow = TRUE)
    tau <- cbind(tau, -rowSums(tau))
    intercept <- -w * (b[ii] + s[rr] + tau[rr, , drop = FALSE])
  }
  answers <- lapply(split(seq_len(nrow(d)), ids[[1]]), function(rows) {
    response <- function(theta) {
      loglik <- U <- A <- derivative <- numeric(length(theta))
      for (j in rows) {
        logits <- outer(theta, 0:K) * a[j] +
          matrix(c(0, cumsum(intercept[j, ])), length(theta), K + 1L, byrow = TRUE)
        high <- apply(logits, 1L, max); lp <- logits - high
        lp <- lp - log(rowSums(exp(lp))); prob <- exp(lp)
        mu <- drop(prob %*% (0:K)); residual <- d[[spec$score]][j] - mu
        loglik <- loglik + lp[, d[[spec$score]][j] + 1L]
        if (chart == "rater_intercepts") {
          if (rr[j] == selected) derivative <- derivative + w[j] * (theta - b[ii[j]]) * residual
        } else {
          U <- U + w[j] * residual
          A <- A + w[j]^2 * rowSums(prob * (matrix(0:K, length(theta), K + 1L, byrow = TRUE) - mu)^2)
        }
      }
      if (chart == "common_scale") derivative <- (U^2 - A) / 2
      list(loglik = loglik, score = derivative)
    }
    if (chart == "common_scale") {
      at <- response(0); return(c(NLL = -at$loglik, Gradient = -at$score))
    }
    offset <- response(0)$loglik
    integral <- function(score) integrate(function(theta) {
      x <- response(theta); exp(x$loglik - offset) * dnorm(theta) * if (score) x$score else 1
    }, -Inf, Inf, rel.tol = 1e-11, abs.tol = 1e-12, subdivisions = 1000L)
    mass <- integral(FALSE); derivative <- integral(TRUE)
    stopifnot(mass$message == "OK", derivative$message == "OK", mass$value > 0)
    c(NLL = -offset - log(mass$value), Gradient = -derivative$value / mass$value)
  })
  Reduce(`+`, answers)
}

nat_main <- function(action) {
  stopifnot(length(action) == 1L, action %in% c("prepare", "run", "summarize"))
  path <- file.path(nat_out, "manifest.rds")
  if (action == "prepare") {
    stopifnot(!file.exists(path))
    old <- readRDS(file.path(co_out, "manifest.rds")); summary <- readRDS(file.path(co_out, "summary.rds"))
    seg_hash_check(old$inputs); seg_hash_check(old$sources); seg_hash_check(summary$results)
    pkgload::load_all(quiet = TRUE, compile = FALSE)
    sources <- unique(c(nat_script, names(old$sources), "R/core-gmfrm-natural.R", "tests/testthat/test-gmfrm-natural.R"))
    m <- list(points = old$points, plan = old$plan,
      inputs = tools::md5sum(unique(c(file.path(co_out, c("manifest.rds", "summary.rds")),
        names(old$inputs), names(summary$results)))), sources = tools::md5sum(sources),
      session = sessionInfo(), threads = old$threads,
      policy = c("40 interior points plus four unoptimized boundary projections; no fits or new data.",
        "Interior compare independent reference NLL <=1e-7, full gradient in log-chart units <=1e-6, target error <=1e-8.",
        "Direct natural NLL rule <=1e-7, score rule <=1e-6, tail NLL <=1e-8, tail score <=1e-7.",
        "Boundary b09 free common variance zero and b19 null rater-5 slope zero, both starts.",
        "Independent boundary NLL <=1e-7, natural derivative <=1e-6; never count a projection as an optimum."))
    stopifnot(identical(Sys.getenv(names(m$threads)), m$threads))
    dir.create(nat_out, recursive = TRUE, showWarnings = FALSE); saveRDS(m, path)
    for (s in sources) {
      dest <- file.path(nat_out, "epoch-source", s); dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
      stopifnot(file.copy(s, dest, overwrite = FALSE))
    }
    return(invisible(NULL))
  }
  m <- readRDS(path); seg_hash_check(m$inputs); seal <- tools::md5sum(path)
  if (action == "summarize") {
    files <- list.files(nat_out, pattern = "^point-.*[.]rds$", full.names = TRUE)
    stopifnot(length(files) == 44L)
    records <- lapply(files, readRDS)
    stopifnot(all(vapply(records, function(r) identical(r$manifest, seal), TRUE)))
    table <- do.call(rbind, lapply(records, function(r) data.frame(Key = r$key, Chart = r$chart,
      Boundary = r$boundary, Status = r$status, Error = r$error,
      NLLDifference = unname(r$checks[1]), GradientDifference = unname(r$checks[2]),
      TargetError = unname(r$checks[3]), BoundaryDerivative = r$boundary_derivative,
      NLLChangeFromInterior = r$nll_change)))
    write.csv(table, file.path(nat_out, "points.csv"), row.names = FALSE)
    saveRDS(list(manifest = seal, results = tools::md5sum(files), points = table), file.path(nat_out, "summary.rds"))
    print(with(table, table(Boundary, Chart, Status)))
    print(subset(table, Boundary | Status != "qualified"), row.names = FALSE)
    return(invisible(NULL))
  }
  seg_hash_check(m$sources); stopifnot(identical(Sys.getenv(names(m$threads)), m$threads))
  pkgload::load_all(quiet = TRUE, compile = FALSE); stopifnot(identical(sessionInfo(), m$session))
  for (j in seq_len(nrow(m$points))) {
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
    for (chart in c("rater_intercepts", "common_scale")) {
      project <- (job$Draw == "b09" && job$Kind == "free" && chart == "common_scale") ||
        (job$Draw == "b19" && job$Kind == "null" && chart == "rater_intercepts")
      ev <- est_fn("mfrm_gmfrm_natural_evaluator")(idx, x$config, x$sizes, chart)
      for (boundary in if (project) c(FALSE, TRUE) else FALSE) {
        dest <- file.path(nat_out, paste0("point-", job$Key, "-", chart, if (boundary) "-boundary", ".rds"))
        if (file.exists(dest)) { stopifnot(identical(readRDS(dest)$manifest, seal)); next }
        r <- list(manifest = seal, key = job$Key, chart = chart, boundary = boundary, status = "refused",
          error = "", checks = c(NLL = NA_real_, Gradient = NA_real_, Target = NA_real_),
          boundary_derivative = NA_real_, nll_change = NA_real_)
        tryCatch({
          z <- ev$from_native(par)
          if (boundary) { selected <- if (chart == "common_scale") ev$natural else ev$natural[5]; z[selected] <- 0 }
          r$coordinates <- z; r$value <- ev$evaluate(z)
          C <- numeric(length(z)); C[build_param_slices(x$sizes)$log_slopes[1]] <- 1
          r$checks["Target"] <- abs(ev$target(z, C)$value -
            if (job$Kind == "null") sum(C * parent$opt$par) + .5 else sum(C * par))
          if (boundary) {
            r$reference <- nat_boundary_reference(z, chart, x$fit$gmfrm$specification, selected)
            r$checks[1:2] <- abs(c(r$value$value, r$value$gradient[selected]) - r$reference)
            r$boundary_derivative <- r$value$gradient[selected]
            previous <- readRDS(file.path(co_out, paste0(job$Key, "-", chart, ".rds")))
            r$nll_change <- r$value$value - previous$value$value
            r$status <- if (all(r$checks <= c(1e-7, 1e-6, 1e-8))) "qualified_projection" else "disagreement"
          } else if (is.null(ref)) r$status <- "no_independent_reference" else {
            map <- est_fn("mfrm_gmfrm_coordinates")(x$config, x$sizes, chart)
            J <- map$decode(map$to_chart(par))$jacobian
            pulled <- r$value$gradient
            pulled[ev$natural] <- pulled[ev$natural] * z[ev$natural] * if (chart == "common_scale") 2 else 1
            r$checks[1:2] <- c(abs(r$value$value - ref$nll), max(abs(pulled + drop(crossprod(J, ref$score)))))
            r$status <- if (all(r$checks <= c(1e-7, 1e-6, 1e-8))) "qualified" else "disagreement"
          }
        }, error = function(e) {
          r$error <<- conditionMessage(e)
          r$failure <<- list(class = class(e), integration = e$integration, parameters = e$parameters)
        })
        saveRDS(r, paste0(dest, ".tmp")); stopifnot(file.rename(paste0(dest, ".tmp"), dest))
        cat(job$Key, chart, boundary, r$status, r$error, "\n"); flush.console()
      }
    }
  }
}
if (sys.nframe() == 0L) nat_main(commandArgs(trailingOnly = TRUE))
