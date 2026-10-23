# Independent literal response formula, posterior mode/curvature, integration,
# and Louis nuisance information for saved adaptive component profiles.
source("tests/testthat/helper-gmfrm-information.R")
gmfrm_profile_reference <- function(fit, par, order = 121L) {
  spec <- fit$gmfrm$specification
  d <- spec$data; owners <- spec$slope_facets; K <- spec$max_score
  levels <- lapply(d[c(spec$person, owners)], function(x) sort(unique(as.character(x))))
  ids <- Map(function(x, lev) match(as.character(x), lev), d[names(levels)], levels)
  ni <- length(levels[[owners[1]]]); nr <- length(levels[[owners[2]]])
  first <- rbind(diag(ni - 1L), rep(-1, ni - 1L))
  Z <- cbind(first[ids[[owners[1]]], , drop = FALSE],
             diag(nr)[ids[[owners[2]]], , drop = FALSE])
  ng <- ncol(Z); nb <- ng + nr * (K - 1L)
  stopifnot(length(par) == nb + ng,
    identical(levels[[owners[1]]], as.character(fit$config$facet_levels[[owners[1]]])),
    identical(levels[[owners[2]]], as.character(fit$config$facet_levels[[owners[2]]])))
  steps <- matrix(0, nr, K)
  if (K > 1L) {
    steps[, seq_len(K - 1L)] <- matrix(par[ng + seq_len(nr * (K - 1L))], nr, byrow = TRUE)
    steps[, K] <- -rowSums(steps)
  }
  cumulative <- t(apply(cbind(0, steps), 1L, cumsum))
  location <- drop(Z %*% par[seq_len(ng)])
  slope <- exp(drop(Z %*% par[nb + seq_len(ng)]))
  offset <- outer(location, 0:K) + cumulative[ids[[owners[2]]], , drop = FALSE]
  rule <- mfrmr:::gauss_hermite_normal(order)
  nodes <- log_weights <- matrix(NA_real_, length(levels[[spec$person]]), order)
  integral <- numeric(nrow(nodes))
  for (i in seq_len(nrow(nodes))) {
    rows <- which(ids[[spec$person]] == i)
    a <- slope[rows]; off <- offset[rows, , drop = FALSE]
    observed <- cbind(seq_along(rows), d[[spec$score]][rows] + 1L)
    kernel <- function(theta) {
      theta <- unname(theta)
      logits <- (matrix(theta * (0:K), length(rows), K + 1L, byrow = TRUE) - off) * a
      high <- apply(logits, 1L, max)
      lp <- logits - high - log(rowSums(exp(logits - high)))
      pr <- exp(lp); mean <- drop(pr %*% (0:K))
      variance <- drop(pr %*% (0:K)^2) - mean^2
      c(logjoint = sum(lp[observed]) + dnorm(theta, log = TRUE),
        score = sum(a * (d[[spec$score]][rows] - mean)) - theta,
        information = 1 + sum(a^2 * variance))
    }
    left <- -1; right <- 1
    while (kernel(left)["score"] < 0) left <- left * 2
    while (kernel(right)["score"] > 0) right <- right * 2
    mode <- uniroot(function(t) kernel(t)["score"], c(left, right), tol = 1e-12)$root
    at <- kernel(mode); scale <- 1 / sqrt(at["information"])
    nodes[i, ] <- mode + scale * rule$nodes
    log_weights[i, ] <- log(rule$weights) + dnorm(nodes[i, ], log = TRUE) -
      dnorm(rule$nodes, log = TRUE) + log(scale)
    # Continuous integration supplies a check independent of the GH rule.
    value <- integrate(function(z) vapply(z, function(t)
      exp(kernel(mode + scale * t)["logjoint"] - at["logjoint"]), 0),
      -Inf, Inf, rel.tol = 1e-10, abs.tol = 1e-10, subdivisions = 1000L)
    stopifnot(value$message == "OK", value$value > 0)
    integral[i] <- at["logjoint"] + log(scale) + log(value$value)
  }
  ref <- gmfrm_louis_reference(spec, par, nodes, log_weights)
  ref$continuous_nll <- -sum(integral)
  ref
}

if (sys.nframe() == 0L) {
  pkgload::load_all(quiet = TRUE, compile = FALSE)
  out <- "validation-results/gmfrm-adaptive-profile-20261010"
  jobs <- commandArgs(trailingOnly = TRUE)
  stopifnot(length(jobs) > 0L)
  for (job in jobs) {
    path <- file.path(out, paste0(job, ".rds")); x <- readRDS(path)
    stopifnot(identical(x$inputs, tools::md5sum(names(x$inputs))))
    fit <- readRDS(x$fit); ci <- x$ci
    if (is.null(ci)) {
      cat(job, "source refusal:", x$error, "\n")
      next
    }
    p <- fit$opt$par
    targets <- mfrmr:::mfrm_gpcm_product_slope_targets(p, fit$config)$components
    ix <- which(targets$metadata$Owner == names(x$target) & targets$metadata$Level == x$target)
    contrast <- targets$jacobian[ix, ]
    # Reconstruct the constraint independently, including the dependent slope.
    ng <- length(fit$config$facet_levels[[fit$config$slope_facet[1]]]) - 1L
    nr <- length(fit$config$facet_levels[[fit$config$slope_facet[2]]])
    nb <- length(p) - ng - nr; expected <- numeric(length(p))
    if (names(x$target) == fit$config$slope_facet[1]) {
      lev <- match(x$target, fit$config$facet_levels[[names(x$target)]])
      if (lev <= ng) expected[nb + lev] <- 1 else expected[nb + seq_len(ng)] <- -1
    } else expected[nb + ng + match(x$target, fit$config$facet_levels[[names(x$target)]])] <- 1
    stopifnot(identical(unname(contrast), expected))
    null <- qr.Q(qr(matrix(contrast, ncol = 1)), complete = TRUE)[, -1, drop = FALSE]
    baseline <- gmfrm_profile_reference(fit, p)
    pr <- attr(ci, "profile"); checks <- list(); refs <- list(baseline = baseline)
    stopifnot(abs(baseline$continuous_nll - pr$baseline) <= 1e-5)
    for (side in which(pr$endpoints$Status == "computed")) {
      bound <- pr$endpoints$Bound[side]
      at <- which.min(abs(pr$profile$LogSlope - log(bound)))
      key <- sprintf("%.17g", pr$profile$LogSlope[at])
      for (start in names(pr$attempts[[key]])) {
        attempt <- pr$attempts[[key]][[start]]
        ref <- gmfrm_profile_reference(fit, attempt$parameters)
        refs[[paste(side, start)]] <- ref
        info <- crossprod(null, ref$information %*% null)
        row <- data.frame(Side = pr$endpoints$Side[side], Start = start,
          ConstraintError = abs(sum(expected * attempt$parameters) - log(bound)),
          NLLDifference = abs(ref$continuous_nll - attempt$check$NLL),
          IntegrationDifference = abs(ref$continuous_nll + sum(ref$log_marginal)),
          LRResidual = abs(2 * (ref$continuous_nll - baseline$continuous_nll) - pr$cutoff),
          NuisanceScore = max(abs(crossprod(null, colSums(ref$scores)))),
          MinimumNuisanceInformation = min(eigen(info, symmetric = TRUE, only.values = TRUE)$values))
        checks[[length(checks) + 1L]] <- row
        print(cbind(Job = job, row), row.names = FALSE); flush.console()
      }
    }
    checks <- do.call(rbind, checks)
    saveRDS(list(checks = checks, reference = refs, input = tools::md5sum(path)),
      file.path(out, paste0(job, "-reference.rds")))
    if (!is.null(checks)) stopifnot(all(checks$ConstraintError <= 1e-8),
      all(checks$NLLDifference <= 1e-5), all(checks$IntegrationDifference <= 1e-6),
      all(checks$LRResidual <= 1e-4), all(checks$NuisanceScore <= 1e-4),
      all(checks$MinimumNuisanceInformation > 0))
  }
}
