# Literal response probabilities and base-R integration, independent of the
# package's parameter decoder, response kernel, derivatives and quadrature.
natural_literal_nll <- function(z, chart, spec) {
  d <- spec$data; K <- spec$max_score
  ids <- lapply(d[c(spec$person, spec$slope_facets)], function(x) match(x, sort(unique(x))))
  ni <- max(ids[[2]]); nr <- max(ids[[3]]); nb <- ni - 1L + nr * K
  b <- c(z[seq_len(ni - 1L)], -sum(z[seq_len(ni - 1L)]))
  ai <- exp(c(z[nb + seq_len(ni - 1L)], -sum(z[nb + seq_len(ni - 1L)])))
  r <- tail(z, nr)
  if (chart == "rater_intercepts") {
    q <- matrix(z[ni - 1L + seq_len(nr * K)], nr, K, byrow = TRUE)
    a <- ai[ids[[2]]] * r[ids[[3]]]
    intercept <- -ai[ids[[2]]] * (r[ids[[3]]] * b[ids[[2]]] + q[ids[[3]], , drop = FALSE])
  } else {
    rho <- exp(c(head(r, -1L), -sum(head(r, -1L))))
    a <- ai[ids[[2]]] * rho[ids[[3]]] * sqrt(tail(r, 1L))
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
        value <- value + logits[, d[[spec$score]][j] + 1L] - high - log(rowSums(exp(logits - high)))
      }
      exp(value)
    }
    ans <- integrate(joint, -Inf, Inf, rel.tol = 1e-11, abs.tol = 1e-14)
    stopifnot(ans$message == "OK", ans$value > 0)
    log(ans$value)
  }, 0))
}

natural_problem <- function(K = 2L) {
  d <- expand.grid(Candidate = paste0("p", 1:3), Item = c("i1", "i2"), Judge = paste0("j", 1:3))
  d <- d[-1, ]; d$Rating <- rep(0:K, length.out = nrow(d))
  names(d)[2:3] <- c("Item name", "Judge name")
  mfrm_gmfrm_problem(d, K, gauss_hermite_normal(15L),
    c("Item name", "Judge name"), "Candidate", "Rating")
}

test_that("natural charts preserve interior likelihood, score and native targets", {
  for (K in c(1L, 3L)) {
    problem <- natural_problem(K); x <- problem$common
    par <- .2 * sin(seq_along(problem$start))
    native <- mfrm_gmfrm_segmented_evaluator(x$idx, x$config, x$sizes)
    for (chart in c("rater_intercepts", "common_scale")) {
      ev <- mfrm_gmfrm_natural_evaluator(x$idx, x$config, x$sizes, chart)
      map <- mfrm_gmfrm_coordinates(x$config, x$sizes, chart)
      old <- mfrm_gmfrm_coordinate_evaluator(native, map)$evaluate(map$to_chart(par))
      z <- ev$from_native(par); result <- ev$evaluate(z)
      pulled <- result$gradient
      pulled[ev$natural] <- pulled[ev$natural] * z[ev$natural] * if (chart == "common_scale") 2 else 1
      expect_equal(result$value, old$value, tolerance = 1e-11)
      expect_equal(pulled, old$gradient, tolerance = 1e-9)
      expect_equal(result$value, natural_literal_nll(z, chart, problem$specification), tolerance = 1e-10)
      expect_identical(result$optimality, "not assessed")
      C <- sin(seq_along(z)); h <- 1e-5
      Jtarget <- vapply(seq_along(z), function(j) {
        step <- replace(numeric(length(z)), j, h)
        (ev$target(z + step, C)$value - ev$target(z - step, C)$value) / (2*h)
      }, 0)
      expect_equal(ev$target(z, C)$value, sum(C * par), tolerance = 1e-12)
      expect_equal(ev$target(z, C)$gradient, Jtarget, tolerance = 1e-8)
    }
  }
})

test_that("boundary scores agree with independent one-sided and central derivatives", {
  for (K in c(1L, 3L)) {
    problem <- natural_problem(K); x <- problem$common
    par <- .2 * sin(seq_along(problem$start))
    for (chart in c("rater_intercepts", "common_scale")) {
      ev <- mfrm_gmfrm_natural_evaluator(x$idx, x$config, x$sizes, chart)
      base <- ev$from_native(par)
      for (zeros in unique(list(ev$natural[1L], ev$natural))) {
        z <- replace(base, zeros, 0); result <- ev$evaluate(z)
        literal <- function(z) natural_literal_nll(z, chart, problem$specification)
        expect_equal(result$value, literal(z), tolerance = 1e-10)
        differences <- lapply(c(1e-4, 5e-5), function(h) {
          numerical <- vapply(seq_along(z), function(j) {
            step <- replace(numeric(length(z)), j, h)
            if (j %in% zeros) (-3*literal(z) + 4*literal(z + step) - literal(z + 2*step)) / (2*h)
            else (literal(z + step) - literal(z - step)) / (2*h)
          }, 0)
          numerical
        })
        coarse <- max(abs(differences[[1]] - result$gradient))
        fine <- max(abs(differences[[2]] - result$gradient))
        expect_lt(fine, 2e-6)
        if (coarse > 1e-6) expect_lt(fine, coarse / 2)
        expect_lt(max(abs((4*differences[[2]] - differences[[1]])/3 - result$gradient)), 1e-7)
        near <- replace(z, zeros, 1e-8)
        expect_equal(ev$value(near), result$value + sum(result$gradient[zeros]) * 1e-8, tolerance = 1e-10)
        expect_equal(ev$gradient(near), result$gradient, tolerance = 1e-6)
        expect_equal(result$boundary_coordinates, zeros)
        C <- numeric(length(z)); C[head(build_param_slices(x$sizes)$log_slopes, 1)] <- 1
        expect_equal(ev$target(z, C)$value, sum(C * par))
        C <- replace(C * 0, tail(ev$natural, 1), 1)
        if (tail(ev$natural, 1) %in% zeros) expect_error(ev$target(z, C), "not supported")
        if (length(zeros) == length(ev$natural)) {
          expect_match(result$ability_information, "posterior equals prior")
          expect_equal(unname(result$integration), rep(0, 4))
          # Nonzero intercepts still give nonuniform probabilities at zero slope.
          expect_gt(abs(result$value - nrow(problem$specification$data) * log(K + 1)), 1e-3)
        }
      }
    }
  }
})

test_that("variance boundary score includes cross-response terms within Person", {
  problem <- natural_problem(1L); x <- problem$common
  idx <- x$idx; idx$score_k[] <- 0
  ev <- mfrm_gmfrm_natural_evaluator(idx, x$config, x$sizes, "common_scale")
  z <- numeric(length(problem$start)); result <- ev$evaluate(z)
  m <- lengths(split(idx$score_k, idx$person))
  expect_equal(result$value, sum(m) * log(2))
  expect_equal(unname(result$gradient[ev$natural]), -sum((m^2 - m) / 8))
  expect_lt(result$gradient[ev$natural], 0) # A feasible descent direction at this fixed point.
  expect_identical(result$optimality, "not assessed")
})

test_that("natural input and arithmetic refusals cannot return a stale cached value", {
  problem <- natural_problem(); x <- problem$common
  for (chart in c("rater_intercepts", "common_scale")) {
    ev <- mfrm_gmfrm_natural_evaluator(x$idx, x$config, x$sizes, chart)
    z <- ev$from_native(problem$start); good <- ev$evaluate(z)
    expect_identical(ev$evaluate(z), good)
    expect_error(ev$value(z + 1i), "finite real")
    expect_error(ev$value(replace(z, 1, NA)), "finite real")
    expect_error(ev$value(replace(z, ev$natural[1], -1)), "nonnegative")
    expect_error(ev$value(replace(z, build_param_slices(x$sizes)$log_slopes[1], 1000)), "slopes")
    expect_identical(ev$evaluate(z), good)
    bad <- problem$start; bad[tail(build_param_slices(x$sizes)$log_slopes, 3)] <- -1000
    expect_error(ev$from_native(bad), "positive interior")
    expect_equal(ev$lower[ev$natural], rep(0, length(ev$natural)))
  }
  # The product's low part survives cancellation against the rounded intercept.
  product <- mfrm_segmented_two_product(1 + 2^-27, 1 - 2^-27)
  expect_equal(product$hi, 1, tolerance = 0)
  expect_equal(product$lo, -2^-54, tolerance = 0)
  logits <- mfrm_segmented_affine_logits(1 + 2^-27, 0, c(0, -1), 1 - 2^-27)
  expect_equal(unname(logits[1, 2] - logits[1, 1]), -2^-54, tolerance = 0)
  expect_error(mfrm_segmented_two_product(1e300, 1e20), "arithmetic range")
})

test_that("variance-score identities agree across their overlap and select before integration", {
  for (K in c(1L, 3L)) {
    problem <- natural_problem(K); x <- problem$common
    evaluators <- lapply(c("auto", "heat", "prior"), function(form)
      mfrm_gmfrm_natural_evaluator(x$idx, x$config, x$sizes, "common_scale", form))
    z <- evaluators[[1]]$from_native(.2 * sin(seq_along(problem$start)))
    component <- evaluators[[1]]$natural
    for (v in c(.001, .05, .5, 10)) {
      z[component] <- v; ans <- lapply(evaluators, function(ev) ev$evaluate(z))
      expect_equal(ans[[1]]$value, ans[[2]]$value, tolerance = 0)
      expect_equal(ans[[1]]$value, ans[[3]]$value, tolerance = 0)
      expect_lt(max(abs(ans[[2]]$gradient - ans[[3]]$gradient)), 1e-8)
      h <- min(1e-5, v / 100)
      step <- replace(numeric(length(z)), component, h)
      literal <- function(z) natural_literal_nll(z, "common_scale", problem$specification)
      fd <- (literal(z + step) - literal(z - step)) / (2*h)
      expect_lt(abs(ans[[1]]$gradient[component] - fd), 2e-6)
      expect_equal(sum(ans[[1]]$variance_score), length(unique(x$idx$person)))
      expect_equal(ans[[2]]$variance_score["prior"], c(prior = 0L))
      expect_equal(ans[[3]]$variance_score["heat"], c(heat = 0L))
    }
    z[component] <- 0
    expect_identical(evaluators[[1]]$evaluate(z), evaluators[[2]]$evaluate(z))
    expect_error(evaluators[[3]]$evaluate(z), "strictly positive")
    z[component] <- 1e-12
    ans <- evaluators[[1]]$evaluate(z)
    expect_equal(ans$variance_score["prior"], c(prior = 0L))
    expect_equal(ans, evaluators[[2]]$evaluate(z), tolerance = 0)
    z[component] <- 10
    expect_equal(evaluators[[1]]$evaluate(z)$variance_score["heat"], c(heat = 0L))
  }
  expect_error(mfrm_gmfrm_natural_evaluator(x$idx, x$config, x$sizes,
    "rater_intercepts", "prior"), "only to the common-scale")
})
