test_that("curvature restart resolves a large-offset stationary point accurately", {
  h <- diag(c(900, 15000))
  fn <- function(p) 86000 + sum(p * (h %*% p)) / 2
  gr <- function(p) as.vector(h %*% p)
  start <- c(4e-7, -1e-7)
  proposal <- mfrm_optimizer_curvature_proposal(start, fn, gr)
  expect_identical(proposal$error, "")
  expect_lt(max(abs(gr(proposal$par))), 1e-10)
  expect_lte(fn(proposal$par), fn(start))
  expect_true(all(proposal$counts > 0))
  expect_equal(proposal$par, c(0, 0), tolerance = 1e-15)
})

test_that("curvature scaling changes search coordinates without changing the objective", {
  h <- matrix(c(5, 2, 2, -1), 2)
  fn <- function(p) drop(crossprod(p, h %*% p)) / 2
  gr <- function(p) drop(h %*% p)
  p <- c(.2, -.3)
  scale <- mfrm_optimizer_curvature_scale(p, fn, gr)
  expect_true(scale$negative)
  expect_identical(scale$error, "")
  expect_true(all(is.finite(scale$transform)))
  z <- c(.1, -.1)
  mapped <- p + drop(scale$transform %*% z)
  numerical <- vapply(seq_along(z), function(j) {
    up <- down <- z; up[j] <- up[j] + 1e-6; down[j] <- down[j] - 1e-6
    (fn(p + drop(scale$transform %*% up)) -
       fn(p + drop(scale$transform %*% down))) / 2e-6
  }, numeric(1))
  expect_equal(drop(crossprod(scale$transform, gr(mapped))), numerical, tolerance = 1e-8)
  expect_equal(drop(solve(scale$transform, mapped - p)), z)
  expect_gt(scale$counts[['gradient']], 0)
  for (case in list(list(fn=function(p) NA_real_, gr=function(p) rep(NA_real_,2)),
                   list(fn=function(p) 0, gr=function(p) c(0,0)))) {
    bad <- mfrm_optimizer_curvature_scale(p, case$fn, case$gr)
    expect_null(bad$transform)
    expect_true(nzchar(bad$error))
  }
  large <- mfrm_optimizer_curvature_scale(rep(0,65), function(p) stop("evaluated"), identity)
  expect_null(large$transform)
  expect_equal(unname(large$counts),c(0L,0L))
})

test_that("a small raw gradient cannot hide recoverable negative curvature", {
  fn <- function(p) (1e-6 * p[1]^2 - 1)^2 + p[2]^2
  gr <- function(p) c(4e-6 * p[1] * (1e-6 * p[1]^2 - 1), 2*p[2])
  testthat::local_mocked_bindings(
    make_param_cache = function(...) list(ensure = function(p) NULL),
    make_mfrm_direct_evaluator = function(...) list(value=fn, gradient=gr, diagnostics=function() list()),
    .package = "mfrmr")
  fit <- run_mfrm_direct_optimization(c(1,0), "MML", list(), list(model="GPCM"),
    list(), quad_points=3, maxit=400, reltol=1e-9, optimizer="BFGS")
  stages <- fit$optimizer_polish$Stages
  expect_lt(stages$TerminalGradientSupNorm[1],1e-4)
  expect_lt(stages$SmallestCurvature[1],0)
  expect_lt(fit$value,1e-10)
  expect_equal(abs(fit$par[1]),1000,tolerance=1e-5)
  expect_identical(fit$optimizer_diagnostics$ConvergenceSeverity,"pass")
  expect_identical(stages$StageLabel[stages$Selected],"curvature_rescale")
  expect_gte(stages$SmallestCurvature[stages$Selected],0)
  expect_lte(sum(stages$StageLabel=="curvature_rescale"),3)
  expect_equal(fit$optimizer_diagnostics$GradientEvaluations, sum(stages$GradientEvaluations))
})

test_that("unsuccessful negative-curvature restarts retain the point and warn", {
  fn <- function(p) 1 - 1e-6*p[1]^2 + p[2]^2
  gr <- function(p) c(-2e-6*p[1],2*p[2])
  testthat::local_mocked_bindings(
    make_param_cache = function(...) list(ensure = function(p) NULL),
    make_mfrm_direct_evaluator = function(...) list(value=fn, gradient=gr, diagnostics=function() list()),
    optim = function(par, fn, gr, ...) list(par=par, value=fn(par), convergence=0L,
      counts=c("function"=1L,"gradient"=1L)), .package = "mfrmr")
  run <- function(model="GPCM",method="MML",reltol=1e-9) {
    run_mfrm_direct_optimization(c(1,0),method,list(),list(model=model),list(),
      quad_points=3,maxit=20,reltol=reltol)
  }
  expect_warning(fit <- run(),"convergence review")
  expect_equal(fit$par,c(1,0))
  expect_identical(fit$optimizer_diagnostics$ConvergenceReason,"negative_curvature_review")
  expect_identical(fit$optimizer_diagnostics$ConvergenceSeverity,"review")
  expect_false(fit$optimizer_polish$Succeeded)
  expect_equal(sum(fit$optimizer_polish$Stages$StageLabel=="curvature_rescale"),1)
  for (other in list(run(model="RSM"),run(model="PCM"),run(method="JML"),run(reltol=1e-6))) {
    expect_identical(other$optimizer_diagnostics$ConvergenceSeverity,"pass")
    expect_false("curvature_rescale" %in% other$optimizer_polish$Stages$StageLabel)
  }
})

test_that("unsafe curvature proposals do not replace the retained point", {
  cases <- list(
    list(fn = function(p) -sum(p^2), gr = function(p) -2*p),
    list(fn = function(p) p[1]^2, gr = function(p) c(2*p[1],0)),
    list(fn = function(p) NA_real_, gr = function(p) p),
    list(fn = function(p) sum(p^2), gr = function(p) c(NA_real_,p[2])),
    list(fn = function(p) if (sum(p^2)<1) stop("outside valid domain") else sum(p^2),
         gr = function(p) 2*p),
    list(fn = function(p) -sum(p^2), gr = function(p) 2*p)
  )
  for (case in cases) {
    proposal <- mfrm_optimizer_curvature_proposal(c(1,1),case$fn,case$gr)
    expect_null(proposal$par)
    expect_true(nzchar(proposal$error))
  }
  too_large <- mfrm_optimizer_curvature_proposal(rep(1,65),function(p) stop("evaluated"),identity)
  expect_equal(unname(too_large$counts),c(0L,0L))
  expect_match(too_large$error,"1-64",fixed=TRUE)
})

test_that("a stalled optimizer restarts only from a safe curvature proposal", {
  run <- function(indefinite = FALSE, code = 0L, method = "MML") {
    h <- diag(c(900, if (indefinite) -15000 else 15000))
    fn <- function(p) 86000 + sum(p * (h %*% p))/2
    gr <- function(p) as.vector(h %*% p)
    testthat::local_mocked_bindings(
      make_param_cache = function(...) list(ensure = function(p) NULL),
      make_mfrm_direct_evaluator = function(...) list(value=fn, gradient=gr, diagnostics=function() list()),
      optim = function(par, fn, gr, ...) list(par=par, value=fn(par), convergence=code,
                                             counts=c("function"=1L,"gradient"=1L)),
      .package = "mfrmr"
    )
    run_mfrm_direct_optimization(c(4e-7,-1e-7), method, list(), list(model="RSM"),
      list(), quad_points=3, maxit=20, reltol=1e-9, suppress_convergence_warning=TRUE)
  }
  good <- run()
  expect_identical(good$optimizer_diagnostics$ConvergenceSeverity,"pass")
  expect_lt(good$optimizer_diagnostics$TerminalGradientSupNorm,1e-10)
  stages <- good$optimizer_polish$Stages
  expect_identical(stages$StageLabel[stages$Selected],"curvature_restart")
  expect_gt(tail(stages$GradientEvaluations,1),1L)
  expect_gt(tail(stages$MaxParameterChange,1),0)
  bad <- run(indefinite=TRUE)
  expect_identical(bad$optimizer_diagnostics$ConvergenceSeverity,"review")
  expect_true(nzchar(tail(bad$optimizer_polish$Stages$Error,1)))
  expect_false(tail(bad$optimizer_polish$Stages$Selected,1))
  for (x in list(run(code=1L),run(method="JML"))) {
    expect_false("curvature_restart" %in% x$optimizer_polish$Stages$StageLabel)
  }
})
