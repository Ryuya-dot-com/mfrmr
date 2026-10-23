# Independent equations in chart coordinates; no native parameter decoder,
# package response kernel, derivatives or quadrature is used here.
coordinate_literal_nll <- function(z, chart, spec) {
  d <- spec$data; owners <- spec$slope_facets; K <- spec$max_score
  ids <- lapply(d[c(spec$person, owners)], function(x) match(x, sort(unique(x))))
  ni <- max(ids[[2]]); nr <- max(ids[[3]]); nb <- ni - 1L + nr * K
  b <- c(z[seq_len(ni - 1L)], -sum(z[seq_len(ni - 1L)]))
  ai <- exp(c(z[nb + seq_len(ni - 1L)], -sum(z[nb + seq_len(ni - 1L)])))
  rlog <- tail(z, nr)
  if (chart == "rater_intercepts") {
    q <- matrix(z[ni - 1L + seq_len(nr * K)], nr, K, byrow = TRUE)
    a <- ai[ids[[2]]] * exp(rlog[ids[[3]]])
    intercept <- -ai[ids[[2]]] *
      (exp(rlog[ids[[3]]]) * b[ids[[2]]] + q[ids[[3]], , drop = FALSE])
  } else {
    rho <- exp(c(head(rlog, -1L), -sum(head(rlog, -1L))))
    a <- ai[ids[[2]]] * rho[ids[[3]]] * exp(tail(rlog, 1L))
    s <- z[ni - 1L + seq_len(nr)]
    tau <- matrix(z[ni - 1L + nr + seq_len(nr * (K - 1L))], nr, K - 1L, byrow = TRUE)
    tau <- cbind(tau, -rowSums(tau))
    intercept <- -ai[ids[[2]]] * rho[ids[[3]]] *
      (b[ids[[2]]] + s[ids[[3]]] + tau[ids[[3]], , drop = FALSE])
  }
  -sum(vapply(split(seq_len(nrow(d)), ids[[1]]), function(rows) {
    joint <- function(theta) {
      value <- dnorm(theta, log = TRUE)
      for (j in rows) {
        logits <- outer(theta, 0:K) * a[j] +
          matrix(c(0, cumsum(intercept[j, ])), length(theta), K + 1L, byrow = TRUE)
        high <- apply(logits, 1L, max)
        value <- value + logits[, d[[spec$score]][j] + 1L] - high -
          log(rowSums(exp(logits - high)))
      }
      exp(value)
    }
    ans <- integrate(joint, -Inf, Inf, rel.tol = 1e-11, abs.tol = 1e-14)
    stopifnot(ans$message == "OK", ans$value > 0)
    log(ans$value)
  }, 0))
}

test_that("interior charts preserve response likelihood, scores and native targets", {
  for (K in c(1L, 3L)) {
    d <- expand.grid(Candidate = paste0("p", 1:3), Item = c("i1", "i2"),
      Judge = c("j1", "j2", "j3"))
    d <- d[-1, ]; d$Rating <- rep(0:K, length.out = nrow(d))
    names(d)[2:3] <- c("Item name", "Judge name")
    problem <- mfrm_gmfrm_problem(d, K, gauss_hermite_normal(15L),
      c("Item name", "Judge name"), "Candidate", "Rating")
    x <- problem$common; par <- .2 * sin(seq_along(problem$start))
    native <- mfrm_gmfrm_segmented_evaluator(x$idx, x$config, x$sizes)
    original <- native$evaluate(par)
    for (chart in c("rater_intercepts", "common_scale")) {
      map <- mfrm_gmfrm_coordinates(x$config, x$sizes, chart)
      z <- map$to_chart(par); decoded <- map$decode(z)
      expect_equal(decoded$parameters, par, tolerance = 1e-14)
      h <- 1e-5
      J <- vapply(seq_along(z), function(j) {
        v <- replace(numeric(length(z)), j, h)
        (map$decode(z + v)$parameters - map$decode(z - v)$parameters) / (2*h)
      }, numeric(length(z)))
      expect_lt(max(abs(J - decoded$jacobian)), 1e-9)
      ev <- mfrm_gmfrm_coordinate_evaluator(native, map)
      result <- ev$evaluate(z)
      literal <- function(z) coordinate_literal_nll(z, chart, problem$specification)
      expect_lt(abs(result$value - literal(z)), 1e-9)
      expect_lt(abs(result$value - original$value), 1e-12)
      numerical <- vapply(seq_along(z), function(j) {
        v <- replace(numeric(length(z)), j, h)
        (literal(z + v) - literal(z - v)) / (2*h)
      }, 0)
      expect_lt(max(abs(result$gradient - numerical)), 1e-7)

      # Include a location contrast, first-family and second-family slope
      # nulls. In the common-scale chart a rater slope is not just log(rho).
      for (C in list(replace(numeric(length(z)), c(2L, 3L), c(1, -1)),
                     replace(numeric(length(z)), length(z) - 3L, 1),
                     replace(numeric(length(z)), length(z), 1))) {
        target <- map$target(z, C)
        expect_equal(target$value, sum(C * par), tolerance = 1e-14)
        expect_equal(target$gradient, drop(C %*% J), tolerance = 1e-9)
        null <- mfrm_gpcm_profile_constraint(par, C, .4)
        constrained <- null$embed(par[null$free])
        expect_equal(map$target(map$to_chart(constrained), C)$value, .4, tolerance = 1e-14)
      }
      # A new session needs only chart coordinates and configuration, no cache.
      path <- tempfile(fileext = ".rds"); on.exit(unlink(path), add = TRUE)
      saveRDS(list(z = z, config = x$config, sizes = x$sizes), path)
      restored <- readRDS(path)
      expect_equal(mfrm_gmfrm_coordinates(restored$config, restored$sizes, chart)$decode(restored$z), decoded)
      expect_error(map$decode(NULL), "finite real vector")
      expect_error(map$decode(replace(z, 1, NA)), "finite real vector")
      expect_error(map$decode(z + 1i), "finite real vector")
      bad <- replace(z, length(z), -1000)
      error <- tryCatch(ev$evaluate(bad), error = identity)
      expect_s3_class(error, "mfrmr_adaptive_quadrature_numeric_error")
      expect_identical(error$parameters, bad)
      expect_equal(ev$value(z), result$value, tolerance = 0)
    }
    cfg <- x$config; cfg$facet_specs[[1]]$anchors[1] <- 0
    expect_error(mfrm_gmfrm_coordinates(cfg, x$sizes), "unanchored")
  }
})

test_that("transformed integration errors cannot inherit a native pass", {
  d <- expand.grid(Person = c("p1", "p2", "p3"), Task = c("t1", "t2"), Rater = c("r1", "r2"))
  d$Score <- rep(0:2, length.out = nrow(d))
  x <- mfrm_gmfrm_problem(d, 2, gauss_hermite_normal(15L))$common
  map <- mfrm_gmfrm_coordinates(x$config, x$sizes, "rater_intercepts")
  z <- numeric(map$dimension); z[length(z)] <- log(1e-8)
  fake <- list(evaluate = function(par) list(value = 2, gradient = rep(0, length(par)),
    integration = c(NLLRuleDifference = 0, ScoreRuleDifference = 1e-10,
      TailNLLBound = 0, TailScoreBound = 1e-12),
    score_error = list(rule = rep(1e-10, length(par)), tail = rep(1e-12, length(par)))))
  ev <- mfrm_gmfrm_coordinate_evaluator(fake, map)
  err <- tryCatch(ev$evaluate(z), error = identity)
  expect_s3_class(err, "mfrmr_adaptive_quadrature_numeric_error")
  expect_gt(err$integration["ScoreRuleDifference"], 1e-6)
  expect_equal(err$native_parameters, map$decode(z)$parameters)
  expect_identical(err$parameters, z)
  z[length(z)] <- 0
  answer <- ev$evaluate(z)
  expect_equal(answer$value, 2)
  expect_equal(answer$score_error$rule, drop(crossprod(abs(map$decode(z)$jacobian),
    rep(1e-10, length(z)))))
  fake$evaluate <- function(par) list(value = 2, gradient = rep(0, length(par)))
  expect_error(mfrm_gmfrm_coordinate_evaluator(fake, map)$value(z), "componentwise")
})
