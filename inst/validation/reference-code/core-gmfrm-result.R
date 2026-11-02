# Private result handoff. Retained search codes and segmented integration never
# masquerade as the public EM/adaptive fit contract. No fitting or Hessian work.
mfrm_gmfrm_result <- function(run) {
  s <- run$specification
  problem <- do.call(mfrm_gmfrm_problem, c(s, list(quadrature=gauss_hermite_normal(2L))))
  expected <- problem$specification; expected$quadrature <- NULL
  if (!identical(s,expected) || !identical(run$parameter_names,names(problem$start)) ||
      !identical(names(run$native_starts),names(run$attempts)) ||
      !run$integration$chart %in% c("rater_intercepts","common_scale") ||
      !identical(run$integration$working,"segmented Legendre 16/32"))
    stop("The saved run must retain its original specification, parameter order and integration provenance.")
  common <- problem$common
  natural <- mfrm_gmfrm_natural_evaluator(common$idx,common$config,common$sizes,run$integration$chart)
  candidates <- lapply(names(run$attempts),function(name) {
    a <- run$attempts[[name]]; stages <- a$stages
    mapped <- natural$from_native(unname(run$native_starts[[name]]))
    if (!isTRUE(all.equal(a$start,mapped,tolerance=1e-12)) ||
        !identical(a$start[run$fixed],run$fixed_values))
      stop("The saved attempt no longer matches its prescribed start.")
    if (is.null(stages$search$value)) return(NULL)
    if (!identical(stages$search$value$fixed,run$fixed) ||
        !isTRUE(all.equal(stages$search$value$initial$parameters,a$start,tolerance=1e-12)))
      stop("The saved search no longer matches the original constraint.")
    candidate <- mfrm_gmfrm_candidate(stages$search$value,natural,
      stages$finish$value,stages$chart$value,
      if (is.null(stages$finish)) NULL else stages$reference$value)
    if (!identical(candidate,a$candidate)) stop("The saved candidate no longer matches its stages.")
    candidate
  }); names(candidates) <- names(run$attempts)
  if (any(vapply(run$comparisons,function(x) !identical(x$specification,s),TRUE)))
    stop("Comparison evidence belongs to a different data/model specification.")
  selection <- if (all(vapply(candidates,Negate(is.null),TRUE)))
    mfrm_gmfrm_select_candidates(candidates,names(run$native_starts),run$reference_nll,run$comparisons) else NULL
  status <- if (is.null(selection)) "incomplete_start_execution" else selection$status
  if (!identical(selection,run$selection) || !identical(selection$candidate,run$candidate) ||
      !identical(status,run$status)) stop("The saved complete-start selection no longer matches its evidence.")
  cfg <- common$config
  cfg$estimability_audit <- audit_mfrm_estimability(common$prep,common$idx,cfg,common$sizes)
  cfg$category_support_audit <- audit_mfrm_category_support(common$prep,cfg,common$sizes)
  review <- build_mfrm_data_review(common$prep,estimability_audit=cfg$estimability_audit,
    category_support_audit=cfg$category_support_audit)
  components <- rbind(mfrmr_readiness_input_component(common$prep,review,cfg),
    mfrmr_readiness_estimability_component(cfg,common$prep),mfrmr_readiness_category_component(cfg),
    mfrmr_readiness_boundary_component(cfg))
  states <- setNames(components$State,components$Component)
  candidate <- run$candidate; reference <- NULL; tables <- NULL
  if (!is.null(candidate)) {
    # Fresh likelihood/score identity binds the saved local information to these
    # data and parameters; it does not recompute or improve the saved curvature.
    reference <- mfrm_gmfrm_procedure_reference(
      mfrm_gmfrm_reference(s,run$integration$chart)(candidate$selected$parameters,candidate$native_parameters),
      candidate$stages$finish,candidate$stages$chart,run$fixed_values,problem$n_person)
    if (!isTRUE(reference$passed)) stop("The selected point fails the current independent likelihood/score check.")
    params <- expand_params(candidate$native_parameters,common$sizes,cfg)
    tables <- list(locations=build_other_facet_table(cfg,common$prep,params),
      steps=build_step_table(cfg,common$prep,params),slopes=build_slope_table(cfg,common$prep,params))
  }
  scoring <- !is.null(candidate) && !length(run$fixed) &&
    identical(unname(states["input"]),"pass") && identical(unname(states["category"]),"adequate") &&
    states["estimability"] %in% c("identified","not_evaluated") &&
    states["boundary"] %in% c("finite","not_applicable","not_evaluated") &&
    !isTRUE(cfg$estimability_audit$nonlinear_local_estimability$local_first_order_rank_deficient)
  out <- structure(list(run=run,tables=tables,components=components,reference=reference,
    admission=list(public_fit=FALSE,structural_intervals=FALSE,conditional_person_scoring=isTRUE(scoring)),
    notes=c("Private local result; original search codes, finish checks and comparison witnesses remain in run.",
      "Local joint information does not qualify sampling coverage or a global optimum.",
      "Person EAP and posterior SD condition on the point calibration and fixed N(0,1) prior; calibration uncertainty is excluded.")),
    class=c("mfrm_gmfrm_result","list"))
  out$identity <- mfrm_checkpoint_fingerprint(out)
  out
}

mfrm_gmfrm_result_check <- function(result) {
  copy <- result; copy$identity <- NULL
  if (!inherits(result,"mfrm_gmfrm_result") ||
      !identical(result$identity,mfrm_checkpoint_fingerprint(copy)))
    stop("The private result changed after qualification; reconstruct it from the original run.")
  invisible(TRUE)
}

mfrm_gmfrm_result_targets <- function(result, contrasts) {
  mfrm_gmfrm_result_check(result)
  run <- result$run; candidate <- run$candidate; p <- length(run$parameter_names)
  if (is.null(candidate)) stop("There is no selected local candidate for native targets.")
  default <- missing(contrasts)
  if (default) contrasts <- diag(p)
  if (!is.matrix(contrasts) || !is.numeric(contrasts) || is.complex(contrasts) ||
      ncol(contrasts)!=p || !nrow(contrasts) || any(!is.finite(contrasts)) ||
      (!is.null(colnames(contrasts)) && !identical(colnames(contrasts),run$parameter_names)))
    stop("Supply a finite native contrast matrix in the saved parameter order.")
  common <- do.call(mfrm_gmfrm_common_setup,run$specification)
  natural <- mfrm_gmfrm_natural_evaluator(common$idx,common$config,common$sizes,run$integration$chart)
  targets <- lapply(seq_len(nrow(contrasts)),function(i)
    mfrm_gmfrm_candidate_target(candidate,natural,contrasts[i,]))
  labels <- rownames(contrasts) %||% if (default) run$parameter_names else as.character(seq_len(nrow(contrasts)))
  data.frame(Target=labels,Estimate=vapply(targets,`[[`,0,"value"),
    LocalVariance=vapply(targets,`[[`,0,"local_variance"),
    VarianceScope=vapply(targets,`[[`,"","variance_scope"),IntervalEligible=FALSE)
}

# Fixed-calibration EAP only. Scoring has its own declared adaptive 31/61 rule;
# this never changes the source result's segmented estimation provenance.
mfrm_gmfrm_result_persons <- function(result, data=result$run$specification$data) {
  mfrm_gmfrm_result_check(result)
  if (!isTRUE(result$admission$conditional_person_scoring))
    stop("The source is not eligible for conditional Person scoring.")
  s <- result$run$specification; required <- c(s$person,s$slope_facets,s$score)
  if (!is.data.frame(data) || !nrow(data) || anyDuplicated(names(data)) ||
      !all(required %in% names(data)) || anyNA(data[required]) ||
      !is.numeric(data[[s$score]]) || is.complex(data[[s$score]]) ||
      any(!data[[s$score]] %in% 0:s$max_score) || anyDuplicated(data[c(s$person,s$slope_facets)]))
    stop("Scoring requires observed, unique person-facet rows on the original category ladder.")
  common <- do.call(mfrm_gmfrm_common_setup,s); cfg <- common$config
  for (owner in s$slope_facets) if (any(!as.character(data[[owner]]) %in% common$prep$levels[[owner]]))
    stop("Scoring requires known facet levels.")
  # A scored batch can contain one Person or one observed category. Training
  # category-support requirements apply to the source, not to this batch.
  df <- as.data.frame(data[required]); names(df) <- c("Person",s$slope_facets,"Score")
  ids <- c("Person",s$slope_facets)
  if (any(vapply(df[ids],function(x) any(!nzchar(trimws(as.character(x)))),TRUE)))
    stop("Scoring identifiers must be nonempty.")
  df$Person <- factor(as.character(df$Person)); df$score_k <- df$Score; df$Weight <- 1
  prep <- list(data=df,facet_names=s$slope_facets,n_person=nlevels(df$Person),
    levels=c(list(Person=levels(df$Person)),common$prep$levels[s$slope_facets]))
  for (owner in s$slope_facets) {
    prep$levels[[owner]] <- common$prep$levels[[owner]]
    prep$data[[owner]] <- factor(prep$data[[owner]],levels=prep$levels[[owner]])
  }
  idx <- build_indices(prep,step_facet=s$slope_facets[2],slope_facet=NULL)
  params <- expand_params(result$run$candidate$native_parameters,common$sizes,cfg)
  params$slopes <- Reduce(`*`,lapply(s$slope_facets,function(owner)
    params$slope_components[[owner]]$Slope[idx$facets[[owner]]]))
  if (any(!is.finite(params$slopes) | params$slopes<=0)) stop("Invalid scoring slope products.")
  idx$slope_idx <- seq_along(idx$score_k); cfg$n_person <- prep$n_person
  cfg$estimation_control$mml_integration <- "adaptive"
  high <- compute_person_eap(idx,cfg,params,gauss_hermite_normal(61L))
  high$Person <- as.character(prep$levels$Person)
  review <- mfrmr_adaptive_quadrature_review(idx,cfg,params,gauss_hermite_normal(31L),
    prep$levels$Person,c(31L,61L))
  checks <- prediction_score_integration_review(high,review)
  scores <- data.frame(Person=checks$Person,Estimate=high$Estimate,PosteriorSD=high$SD,
    Eligible=checks$Passed,PriorMean=0,PriorSD=1)
  # Retain failed numerical comparisons for review; no usable score is fabricated.
  scores[!checks$Passed,c("Estimate","PosteriorSD")] <- NA_real_
  list(estimates=scores,integration=checks,quadrature_review=review,source_identity=result$identity,
    method="conditional EAP; adaptive Gauss-Hermite 31/61",notes=result$notes)
}
