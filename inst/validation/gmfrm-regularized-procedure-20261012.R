# Private research procedure. Its driver supplies frozen fitting/reference helpers.
# No case ID, generating truth or observed/bootstrap flag enters the fit policy.
regularized_route <- function(summary) {
  if (isTRUE(summary$Qualified)) return("accept")
  reasons <- strsplit(summary$Reasons, ";", fixed = TRUE)[[1L]]
  eligible <- length(reasons) > 0L && all(reasons %in%
    c("NLLAgreement", "GradientAgreement", "Stationarity"))
  if (!eligible) return("unavailable")
  if (summary$NLLCheck > m$controls$value_tolerance ||
      summary$GradientCheck > m$controls$integration_gradient_tolerance) "segmented" else "adaptive121"
}

regularized_continue <- function(s, old, target, constrained, engine_name) {
  stopifnot(engine_name %in% c("segmented", "adaptive121"))
  co <- coordinates(s$T, constrained, target)
  engine <- if (engine_name == "segmented")
    fn("mfrm_gmfrm_segmented_evaluator")(s$problem$common$idx, s$problem$common$config, s$problem$common$sizes) else NULL
  likelihood <- if (is.null(engine)) s$likelihood$adaptive121 else engine$evaluate
  attempts <- candidates <- references <- list()
  for (name in names(old$candidates)) {
    u <- drop(crossprod(co$U, old$candidates[[name]]$value$z - co$origin))
    ev <- evaluator(likelihood, s$T, co)
    stage <- capture(function() {
      initial <- ev$evaluate(u)
      fit <- optim(u, function(v) ev$evaluate(v)$value / s$problem$n_person,
        function(v) ev$evaluate(v)$gradient / s$problem$n_person, method = "L-BFGS-B",
        control = list(maxit = m$controls$polish_maxit, factr = 0,
          pgtol = m$controls$gradient_tolerance / (10 * s$problem$n_person)))
      final <- ev$evaluate(fit$par)
      list(u = fit$par, state = final, initial = initial, optimizer = fit, counts = ev$counts())
    })
    if (is.null(stage$error)) u <- stage$value$u
    attempts[[name]] <- list(stages = list(continuation = stage), u = u)
    candidates[[name]] <- capture(function() ev$evaluate(u))
    references[[name]] <- review(s, co, candidates[[name]], target, constrained)
  }
  values <- vapply(candidates, function(x) if (is.null(x$error)) x$value$value else Inf, 0)
  selected <- names(which.min(values))
  fit <- list(attempts = attempts, candidates = candidates, selected = selected,
    reference = references[[selected]])
  result <- summarize(fit, references)
  list(fit = fit, references = references, summary = result$summary, endpoints = result$endpoints)
}

regularized_fit <- function(s, target, constrained) {
  first <- capture(function() fit_one(s, target, constrained, adaptive_only = FALSE))
  primary <- list(fit = first$value, summary = summarize_fit(first$value, first$error), execution = first)
  if (!is.null(first$error)) primary$summary$Reasons <- paste("Primary:", first$error)
  route <- regularized_route(primary$summary)
  continuation <- NULL; final <- primary
  if (route %in% c("segmented", "adaptive121")) {
    execution <- capture(function() regularized_continue(s, primary$fit, target, constrained, route))
    continuation <- if (is.null(execution$error)) execution$value else
      list(fit = NULL, summary = summarize_fit(NULL, execution$error))
    if (!is.null(execution$error)) continuation$summary$Reasons <- paste("Continuation:", execution$error)
    continuation$execution <- execution
    final <- continuation
  }
  # A failed continuation remains unavailable; it never returns to the router.
  list(primary = primary, route = route, continuation = continuation,
    fit = final$fit, summary = final$summary)
}

regularized_statistic <- function(free, null) {
  candidate <- 2 * (null$summary$Q - free$summary$Q)
  qualified <- isTRUE(free$summary$Qualified) && isTRUE(null$summary$Qualified) &&
    is.finite(candidate) && candidate >= -2 * m$controls$value_tolerance
  list(qualified = qualified, statistic = if (qualified) candidate else NA_real_,
    candidate_statistic = candidate)
}

regularized_pair <- function(case, data, target) {
  stopifnot(is.numeric(target), length(target) == 1L, is.finite(target))
  preparation <- capture(function() context(case, data))
  fits <- if (is.null(preparation$error))
    lapply(c(FALSE, TRUE), function(null) regularized_fit(preparation$value, target, null)) else
    rep(list(list(primary = NULL, continuation = NULL, fit = NULL, route = "unavailable",
      summary = summarize_fit(NULL, preparation$error))), 2L)
  names(fits) <- c("free", "null")
  c(list(setup = preparation[c("error", "warnings", "seconds")], fits = fits),
    regularized_statistic(fits$free, fits$null))
}

# Bounds for the declared computed statistic, not certified bounds on ideal optima.
regularized_rank <- function(observed, draws, alpha = .05) {
  stopifnot(is.numeric(observed), length(observed) == 1L,
    is.numeric(draws), length(draws) > 0L,
    length(alpha) == 1L, is.finite(alpha), alpha > 0, alpha < 1,
    is.na(observed) || is.finite(observed), all(is.na(draws) | is.finite(draws)))
  B <- length(draws)
  if (is.na(observed)) return(list(status = "observed_unavailable", B = B,
    exceed = 0L, unresolved = B, p_lower = 1 / (B + 1), p_upper = 1))
  a <- sum(draws >= observed, na.rm = TRUE); u <- sum(is.na(draws))
  lower <- (1 + a) / (B + 1); upper <- (1 + a + u) / (B + 1)
  list(status = if (upper <= alpha) "reject" else if (lower > alpha)
      "retain" else "unresolved", B = B, exceed = a, unresolved = u,
    p_lower = lower, p_upper = upper)
}
