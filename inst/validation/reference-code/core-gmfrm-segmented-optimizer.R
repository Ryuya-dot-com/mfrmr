# Internal continuation candidate. A qualified local point is not a statement
# about existence of a finite/global MLE or about confidence-interval coverage.
mfrm_gmfrm_segmented_continue <- function(start, evaluator, checkpoint = NULL) {
  safe <- make_mfrm_boundary_safe_objective(evaluator)
  state <- function(par) list(par = par + 0, value = evaluator$value(par),
    gradient = evaluator$gradient(par))
  selected <- state(start)
  stages <- list(); review <- NULL; status <- "stage_limit"
  for (stage in 0:3) {
    review <- mfrm_optimizer_curvature_scale(selected$par, evaluator$value, evaluator$gradient)
    review$par <- selected$par
    if (is.null(review$transform)) { status <- "curvature_unavailable"; break }
    scaled <- drop(crossprod(review$transform, selected$gradient))
    review$predicted_decrease <- sum(scaled^2) / 2
    review$resolved_positive <- review$smallest > review$scale * 1e-10
    if (max(abs(selected$gradient)) <= 1e-4 && review$resolved_positive &&
        review$predicted_decrease <= 1e-6) {
      status <- "stationary_local_candidate"; break
    }
    if (stage == 3L) break
    center <- selected$par; before <- selected
    native <- function(z) center + drop(review$transform %*% z)
    best <- selected
    fn <- function(z) {
      p <- native(z); v <- safe$value(p)
      if (is.finite(v) && v < safe$penalty && v < best$value) best <<- state(p)
      v
    }
    gr <- function(z) drop(crossprod(review$transform, safe$gradient(native(z))))
    error <- ""; opt <- NULL; polish <- NULL
    tryCatch({
      opt <- stats::optim(rep(0, length(center)), fn, gr, method = "BFGS",
        control = list(maxit = 400L, reltol = 1e-13))
      final <- state(native(opt$par))
      slack <- 64 * .Machine$double.eps * max(1, abs(best$value))
      if (final$value < best$value || (final$value <= best$value + slack &&
          max(abs(final$gradient)) < max(abs(best$gradient)))) best <- final
      if (opt$convergence == 0L && max(abs(best$gradient)) > 1e-4) {
        polish <- mfrm_optimizer_curvature_proposal(best$par, evaluator$value, evaluator$gradient)
        if (!is.null(polish$par)) best <- state(polish$par)
      }
    }, error = function(e) error <<- conditionMessage(e))
    selected <- best
    stages[[length(stages) + 1L]] <- list(before = before, selected = selected,
      curvature = review, optimizer = opt, polish = polish, error = error)
    if (!is.null(checkpoint)) checkpoint(stages)
    if (nzchar(error)) { status <- "numerical_refusal"; break }
    if (identical(before$par, selected$par)) { status <- "no_progress"; break }
  }
  list(selected = selected, stages = stages, curvature = review, status = status,
    rejections = c(slope = safe$rejections(), quadrature = safe$adaptive_quadrature_rejections()))
}
