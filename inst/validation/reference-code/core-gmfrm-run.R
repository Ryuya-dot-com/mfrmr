# Private data-to-result caller. Starts are explicit native-coordinate vectors;
# no initialization fit, automatic rescue or public dispatch is introduced.
mfrm_gmfrm_run <- function(data, max_score, starts,
                            slope_facets=c("Task","Rater"), person="Person", score="Score",
                            fixed=integer(), comparisons=list(), maxit=400L,
                            chart=c("rater_intercepts","common_scale")) {
  chart <- match.arg(chart)
  # Reuse the validated input/identification contract. The placeholder rule is
  # used only by this setup, never by the segmented fitting or reference path.
  problem <- mfrm_gmfrm_problem(data,max_score,gauss_hermite_normal(2L),slope_facets,person,score)
  common <- problem$common; specification <- problem$specification
  specification$quadrature <- NULL
  parameter_names <- names(problem$start); p <- length(parameter_names)
  if(!is.list(starts) || length(starts)<2L || length(names(starts))!=length(starts) ||
      anyNA(names(starts)) || any(!nzchar(names(starts))) || anyDuplicated(names(starts)))
    stop("Supply a named roster of at least two explicit native starts.")
  for(start in starts) if(!is.numeric(start) || is.complex(start) || length(start)!=p ||
      any(!is.finite(start)) || (!is.null(names(start)) && !identical(names(start),parameter_names)))
    stop("Native starts must be finite and match the declared parameter order.")
  # Foreign comparison evidence must not silently enter another data/model run.
  if(!is.list(comparisons) || any(vapply(comparisons,function(x)
      !identical(x$specification,specification),TRUE)))
    stop("Comparison evidence must contain the exact same data/model specification.")
  natural <- mfrm_gmfrm_natural_evaluator(common$idx,common$config,common$sizes,chart)
  native <- mfrm_gmfrm_segmented_evaluator(common$idx,common$config,common$sizes)
  natural_starts <- lapply(starts,function(p) natural$from_native(unname(p)))
  answer <- mfrm_gmfrm_procedure(natural_starts,native,natural,
    mfrm_gmfrm_reference(specification,chart),fixed,comparisons,maxit)
  answer$specification <- specification
  answer$native_starts <- starts
  answer$parameter_names <- parameter_names
  answer$integration <- list(prior="fixed N(0,1)",chart=chart,
    working="segmented Legendre 16/32",reference="independent Legendre 32/64 and Gauss-Kronrod; literal boundary integral")
  answer$evaluations <- list(native=native$diagnostics(),natural=natural$diagnostics())
  answer$admission <- list(public_fit=FALSE,intervals=FALSE,person_scoring=FALSE,
    detail="Private computation result; public model, target and scoring eligibility remain separate.")
  answer
}
