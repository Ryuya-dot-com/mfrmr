interaction_em_fixture <- local({
  fits <- list()
  function(model = "RSM") {
    if (is.null(fits[[model]])) {
      d <- mfrmr:::sample_mfrm_data(seed = 42)
      d <- d[d$Person %in% unique(d$Person)[1:8], ]
      d <- d[-seq(3, nrow(d), by = 13), ]
      d$Weight <- rep(c(0, .5, 1, 2), length.out = nrow(d))
      fits[[model]] <<- suppressWarnings(fit_mfrm(d, "Person",
        c("Rater", "Task", "Criterion"), "Score", model = model,
        step_facet = if (model == "PCM") "Criterion" else NULL,
        weight = "Weight", positive_facets = "Task",
        anchors = data.frame(facet = "Rater", level = as.character(d$Rater[1]), anchor = .2),
        facet_interactions = c("Rater:Criterion", "Rater:Task"),
        min_obs_per_interaction = 0, quad_points = 9, maxit = 2))
    }
    fits[[model]]
  }
})

# Raw labels, category logits and Person grouping: no production probability,
# posterior or score kernel is used by this reference objective.
interaction_em_reference <- function(par, fit, quad) {
  cfg <- fit$config; d <- fit$prep$data
  p <- expand_params(par, build_param_sizes(cfg), cfg)
  # Literal category logits, evaluated for all observations together. The
  # reference still uses no production probability, posterior or score kernel.
  offset <- Reduce(`+`, lapply(cfg$facet_names, function(f)
    cfg$facet_signs[[f]] * p$facets[[f]][as.character(d[[f]])]))
  for (nm in names(p$interactions)) {
    facets <- strsplit(nm, ":", fixed = TRUE)[[1]]
    block <- p$interactions[[nm]]
    at <- cbind(match(as.character(d[[facets[1]]]), rownames(block)),
                match(as.character(d[[facets[2]]]), colnames(block)))
    offset <- offset + block[at]
  }
  steps <- if (cfg$model == "RSM") {
    matrix(rep(p$steps, each = nrow(d)), nrow(d))
  } else p$steps_mat[as.character(d$Criterion), , drop = FALSE]
  cumulative <- cbind(0, t(apply(steps, 1L, cumsum)))
  if (isTRUE(cfg$population_spec$active)) {
    mean <- drop(cfg$population_spec$design_matrix %*% p$population$coefficients)
    mean <- mean[match(as.character(d$Person), fit$prep$levels$Person)]
    eta <- outer(sqrt(p$population$sigma2) * quad$nodes, as.numeric(offset) + mean, `+`)
  } else eta <- outer(quad$nodes, as.numeric(offset), `+`)
  logits <- lapply(seq_len(ncol(cumulative)), function(k)
    sweep((k - 1L) * eta, 2L, cumulative[, k], `-`))
  maximum <- Reduce(pmax, logits)
  row_ll <- -maximum - log(Reduce(`+`, lapply(logits, function(x) exp(x - maximum))))
  categories <- d$Score - cfg$rating_min + 1L
  for (k in seq_along(logits)) {
    columns <- which(categories == k)
    row_ll[, columns] <- row_ll[, columns, drop = FALSE] + logits[[k]][, columns, drop = FALSE]
  }
  row_ll <- sweep(row_ll, 2L, d$Weight, `*`)
  person_ll <- rowsum(t(row_ll), as.character(d$Person), reorder = TRUE)
  logpost <- sweep(person_ll, 2L, log(quad$weights), `+`)
  maximum <- apply(logpost, 1L, max)
  weights <- exp(logpost - maximum)
  posterior <- weights / rowSums(weights)
  list(loglik = sum(maximum + log(rowSums(weights))), row_ll = t(row_ll),
    obs_posterior = posterior[match(as.character(d$Person), rownames(person_ll)), , drop = FALSE])
}

test_that("interaction M-step and marginal scores agree with independent weighted likelihoods", {
  for (model in c("RSM", "PCM")) {
    f <- interaction_em_fixture(model); cfg <- f$config
    sizes <- build_param_sizes(cfg)
    idx <- build_indices(f$prep, cfg$step_facet, cfg$slope_facet, cfg$interaction_specs)
    q <- gauss_hermite_normal(9)
    initial <- build_initial_param_vector(cfg, sizes)
    ref <- interaction_em_reference(initial, f, q)
    state <- build_mfrm_mml_em_state(initial, idx, cfg, sizes, q)
    expect_equal(unname(state$posterior_bundle$obs_posterior), unname(ref$obs_posterior), tolerance = 1e-12)
    evaluator <- make_mfrm_em_mstep_evaluator(make_param_cache(sizes, cfg, idx, is_mml = TRUE),
      idx, cfg, sizes, q, ref$obs_posterior)
    candidate <- initial + .1 * sin(seq_along(initial))
    reference_Q <- function(p) -sum(interaction_em_reference(p, f, q)$row_ll * ref$obs_posterior)
    expect_equal(evaluator$value(candidate), reference_Q(candidate), tolerance = 1e-11)
    finite_diff <- function(fn, p) vapply(seq_along(p), function(i) {
      up <- down <- p; up[i] <- up[i] + 1e-5; down[i] <- down[i] - 1e-5
      (fn(up) - fn(down)) / 2e-5
    }, numeric(1))
    expect_lt(max(abs(evaluator$gradient(candidate) - finite_diff(reference_Q, candidate))), 1e-6)
    expect_lt(max(abs(evaluator$gradient(initial) - finite_diff(
      function(p) -interaction_em_reference(p, f, q)$loglik, initial))), 1e-6)
    cfg$estimation_control$mml_engine_requested <- "hybrid"
    opt <- suppressWarnings(run_mfrm_optimization(initial, "MML", idx, cfg, sizes,
      9, 1000, 1e-10, optimizer = "L-BFGS-B"))
    expect_identical(opt$mml_engine$Used, "hybrid")
    expect_false(opt$mml_engine$Fallback)
    expect_lt(abs(opt$value + interaction_em_reference(opt$par, f, q)$loglik), 1e-8)
    expect_true(all(diff(opt$em_warm_start_trace) >= -1e-10))
    expect_equal(unname(expand_params(opt$par, sizes, cfg)$facets$Rater[1]), .2)
  }
})

test_that("failed EM ascent cannot overwrite a valid checkpoint", {
  d <- load_mfrmr_data("example_operational")
  file <- tempfile(fileext = ".rds")
  on.exit(unlink(file), add = TRUE)
  args <- list(data=d, person="Person", facets=c("Rater","Criterion"), score="Score",
    facet_interactions="Rater:Criterion", mml_engine="em", quad_points=9,
    reltol=1e-12, checkpoint=list(file=file,every_iter=1L), maxit=2)
  suppressWarnings(do.call(fit_mfrm, args))
  saved <- readRDS(file)
  args$maxit <- 3
  local_mocked_bindings(optim = function(par, fn, ...) list(par=par+100,
    value=fn(par), convergence=0L, counts=c('function'=1L,'gradient'=0L)), .package="mfrmr")
  expect_error(suppressMessages(do.call(fit_mfrm,args)), "auxiliary log-likelihood ascent check")
  expect_identical(readRDS(file), saved)
  original <- build_mfrm_mml_em_state
  state_calls <- 0L
  local_mocked_bindings(optim=function(par,fn,...) list(par=par,value=fn(par),
    convergence=0L,counts=c('function'=1L,'gradient'=0L)),
    build_mfrm_mml_em_state=function(...) {
      state <- original(...); state_calls <<- state_calls + 1L
      if (state_calls == 2L) state$marginal_loglik <- -Inf
      state
    }, .package="mfrmr")
  expect_error(suppressMessages(do.call(fit_mfrm,args)), "marginal log-likelihood ascent check")
  expect_identical(readRDS(file), saved)
  expect_error(mfrm_em_check_ascent(1, NaN, "marginal log-likelihood"), "ascent check")
  expect_error(mfrm_em_check_ascent(1, .99, "marginal log-likelihood"), "ascent check")
})

test_that("interaction EM checkpoint resumes the same constrained objective", {
  d <- load_mfrmr_data("example_operational")
  file <- tempfile(fileext = ".rds")
  on.exit(unlink(file), add = TRUE)
  args <- list(data=d, person="Person", facets=c("Rater","Criterion"), score="Score",
    facet_interactions="Rater:Criterion", model="PCM", step_facet="Criterion",
    mml_engine="em", quad_points=9, reltol=1e-12, maxit=2)
  full <- suppressWarnings(do.call(fit_mfrm,args))
  args$checkpoint <- list(file=file,every_iter=1L)
  suppressWarnings(do.call(fit_mfrm,args))
  args$maxit <- 4
  resumed <- suppressMessages(suppressWarnings(do.call(fit_mfrm,args)))
  args$checkpoint <- NULL
  continuous <- suppressWarnings(do.call(fit_mfrm,args))
  expect_equal(resumed$opt$par, continuous$opt$par, tolerance=1e-12)
  expect_equal(resumed$opt$ll_trace, continuous$opt$ll_trace, tolerance=1e-12)
  expect_true(all(diff(resumed$opt$ll_trace) >= -1e-10))
  expect_lt(resumed$opt$value, full$opt$value)
  args$checkpoint <- list(file=file,every_iter=1L)
  args$maxit <- 5
  args$facet_interactions <- NULL
  expect_error(do.call(fit_mfrm,args), "checkpoint identity does not match")
})

test_that("hybrid interactions preserve joint intervals and downstream reports", {
  # Extended local/CI regression; see CONTRIBUTING.md.
  skip_on_cran()
  d <- load_mfrmr_data("example_core")
  for (model in c("RSM", "PCM")) {
    args <- list(data=d, person="Person", facets=c("Rater","Criterion"), score="Score",
      model=model, step_facet=if(model=="PCM") "Criterion" else NULL,
      noncenter_facet="Criterion", facet_interactions="Rater:Criterion",
      quad_points=61, maxit=400, reltol=1e-11)
    direct <- suppressWarnings(do.call(fit_mfrm,args))
    args$mml_engine <- "hybrid"
    hybrid <- suppressWarnings(do.call(fit_mfrm,args))
    expect_identical(hybrid$summary$MMLEngineUsed, "hybrid")
    expect_lt(abs(direct$opt$value - hybrid$opt$value), 1e-7)
    ci <- suppressWarnings(mfrm_facet_intervals(hybrid, interaction="Rater:Criterion"))
    ref <- suppressWarnings(mfrm_facet_intervals(direct, interaction="Rater:Criterion"))
    expect_true(all(ci$table$CIEligible))
    expect_lt(max(abs(vcov(ci) - vcov(ref))), 1e-5)
    expect_lt(max(abs(ci$table$Estimate - ref$table$Estimate)), 1e-5)
    args$mml_engine <- "direct"; args$mml_integration <- "adaptive"
    adapted <- suppressWarnings(do.call(fit_mfrm,args))
    aci <- suppressWarnings(mfrm_facet_intervals(adapted,interaction="Rater:Criterion"))
    expect_true(all(aci$table$CIEligible))
    expect_equal(aci$table$Estimate,ref$table$Estimate,tolerance=1e-5)
    expect_equal(vcov(aci),vcov(ref),tolerance=1e-5)
    # Main effects retain the same full calibration uncertainty for each engine.
    main <- lapply(list(direct, hybrid, adapted), function(f)
      suppressWarnings(mfrm_facet_intervals(f, facet="Criterion")))
    expect_true(all(vapply(main,function(x)all(x$table$CIEligible),TRUE)))
    expect_equal(vcov(main[[1]]), vcov(main[[2]]), tolerance=1e-5)
    expect_lt(max(abs(vcov(main[[1]]) - vcov(main[[3]]))), 1e-5)
    expect_identical(main[[1]]$settings$location_reference,"uncentered_on_fixed_N01")
    expect_match(plot_data(plot(main[[1]],draw=FALSE))$subtitle,"Uncentered locations")
    expect_equal(unname(confint(ci)), unname(as.matrix(ci$table[,c("Lower","Upper")])) )
    expect_equal(confint(ci, parm=ci$table$Target[2:1]),
      confint(ci)[2:1,,drop=FALSE])
    expect_error(confint(ci, level=.8), "saved level")
    expect_error(confint(ci, parm="missing"), "Target names")
    unavailable <- ci
    unavailable$table$Lower[1] <- unavailable$table$Upper[1] <- NA_real_
    expect_true(all(is.na(confint(unavailable)[1,])))
    expect_identical(plot_data(plot(ci,draw=FALSE))$table, ci$table)
    restored <- unserialize(serialize(hybrid,NULL))
    expect_identical(restored$opt, hybrid$opt)
    out <- mfrm_results(restored, intervals=list(cells=ci),include="fit",compute="never")
    expect_identical(out$tables$facet_cells_interaction_cells, ci$interaction_cells)
    comparison <- suppressWarnings(compare_mfrm(direct,hybrid,labels=c("Direct","Hybrid")))
    expect_identical(as.character(comparison$comparison_basis$nesting_review$relation), "same_model")
  }
})

interaction_population_fixture <- local({
  fits <- list()
  function(model='RSM') {
    if(is.null(fits[[model]])) {
      d<-load_mfrmr_data('example_core')
      people<-data.frame(Person=sort(unique(d$Person)),X=seq(-1,1,length.out=length(unique(d$Person))))
      # Vary occasion within each rater/criterion cell as well as within Person.
      if(model=='PCM')d$Occasion<-factor((match(d$Person,people$Person)+
        as.integer(factor(d$Rater))+as.integer(factor(d$Criterion)))%%2)
      fits[[model]]<<-suppressWarnings(fit_mfrm(d,'Person',
        c('Rater','Criterion',if(model=='PCM')'Occasion'),'Score',model=model,
        step_facet=if(model=='PCM')'Criterion' else NULL,
        spec=list(facet_interactions='Rater:Criterion',population_formula=if(model=='PCM')~X+I(X^2) else ~1,
          person_data=people),control=list(mml_engine='direct',mml_integration=if(model=='RSM')'fixed' else 'adaptive',
          quad_points=if(model=='RSM')121L else 61L,maxit=400L,reltol=1e-11)))
    }
    fits[[model]]
  }
})

test_that('joint main-effect contrasts retain dependent levels and equal-level meaning', {
  f <- interaction_population_fixture()
  levels <- f$config$facet_levels$Rater
  main <- suppressWarnings(mfrm_facet_intervals(f, facet='Rater'))
  expect_identical(main$settings$target, 'joint_main_effects')
  expect_identical(main$settings$interaction, 'Rater:Criterion')
  expect_true(all(main$table$CIEligible))
  expect_false(any(main$table$CoverageQualified))
  expect_equal(main$table$Estimate, unname(subset(f$facets$others, Facet=='Rater')$Estimate))
  expect_gt(tail(main$table$SE,1), 0)
  expect_equal(sum(main$table$Estimate), 0, tolerance=1e-12)
  C <- rbind(last_minus_first=c(-1,0,0,1), sum_fixed=rep(1,4))
  colnames(C) <- levels
  ci <- suppressWarnings(mfrm_facet_intervals(f, 'Rater', C[,4:1]))
  expect_identical(ci$contrasts, C)
  expect_equal(ci$table$Estimate, unname(drop(C %*% main$table$Estimate)), tolerance=1e-12)
  expect_equal(vcov(ci), C %*% vcov(main) %*% t(C), tolerance=1e-10)
  expect_identical(ci$table$Status, c('available','fixed'))
  expect_equal(ci$table$SE[2], 0)
  expect_true(all(is.na(ci$table[2,c('Lower','Upper')])))
  g <- f$interactions$effects
  shift <- vapply(f$config$facet_levels$Criterion, function(criterion) {
    z <- g[g$FacetB_Level==criterion,]
    z$Estimate[match(levels[4],z$FacetA_Level)] - z$Estimate[match(levels[1],z$FacetA_Level)]
  }, 0.)
  conditional <- ci$table$Estimate[1] - shift
  expect_equal(mean(conditional), ci$table$Estimate[1], tolerance=1e-12)
  expect_gt(diff(range(conditional)), .01)
  saved <- unserialize(serialize(ci,NULL))
  expect_identical(summary(saved), summary(ci))
  expect_identical(confint(saved), confint(ci))
  expect_identical(plot_data(plot(saved,draw=FALSE))$table, ci$table)
  out <- mfrm_results(f, intervals=list(main=saved), compute='never')
  expect_equal(mfrm_report(out)$tables$facet_main_intervals[names(ci$table)], ci$table)
  expect_match(paste(ci$cautions,collapse=' '),'equal-weight averages')
  changed <- f; changed$interactions$effects$Estimate[1] <- changed$interactions$effects$Estimate[1]+.1
  expect_error(mfrm_results(changed,intervals=ci), 'must match')
})

test_that('joint cells retain estimated-population and regression uncertainty', {
  skip_on_cran()
  for(model in c('RSM','PCM')) {
    f<-interaction_population_fixture(model)
    ci<-suppressWarnings(mfrm_facet_intervals(f,interaction='Rater:Criterion'))
    expect_true(all(ci$table$CIEligible));expect_false(any(ci$table$CoverageQualified))
    expect_identical(ci$fit,f)
    expect_identical(ci$settings$population,if(model=='RSM')'estimated_intercept_normal' else 'conditional_normal_regression')
    expect_identical(ci$settings$integration,if(model=='RSM')'fixed' else 'adaptive')
    quad<-gauss_hermite_normal(241L)
    reference<-function(z)-interaction_em_reference(z,f,quad)$loglik
    expect_lt(abs(reference(f$opt$par)-f$opt$value),1e-7)
    # A mixed direction tests population/interaction cross-curvature independently.
    direction<-(-1)^seq_along(f$opt$par)*seq_along(f$opt$par);direction<-direction/sqrt(sum(direction^2))
    second<-function(h)(reference(f$opt$par+h*direction)-2*reference(f$opt$par)+reference(f$opt$par-h*direction))/h^2
    independent<-(4*second(5e-4)-second(1e-3))/3
    expect_equal(independent,drop(crossprod(direction,solve(ci$parameter_covariance,direction))),tolerance=1e-5)
    expect_true(all(ci$table$ScaleReference=='additive predictor shift; native ability units'))
    J<-ci$target_jacobian
    expect_equal(vcov(ci),J%*%ci$parameter_covariance%*%t(J),tolerance=1e-10,ignore_attr=TRUE)
    g<-matrix(ci$table$Estimate,4,4)
    expect_equal(c(rowSums(g),colSums(g)),rep(0,8),tolerance=1e-12)
    # Refinement in the source's integration rule is already checked by the API.
    expect_true(all(ci$checks$Passed))
    expect_true(ci$numerical_checks$BoundaryCandidatePassed)
    main <- suppressWarnings(mfrm_facet_intervals(f, facet='Rater'))
    expect_true(all(main$table$CIEligible))
    expect_equal(main$parameter_covariance, ci$parameter_covariance, tolerance=1e-10)
    expect_identical(main$settings$population, ci$settings$population)
    expect_true(main$numerical_checks$BoundaryCandidatePassed)
    if(model=='PCM') {
      other <- suppressWarnings(mfrm_facet_intervals(f, facet='Occasion'))
      expect_true(all(other$table$CIEligible))
      expect_identical(other$fit, f)
    }
    saved<-unserialize(serialize(ci,NULL))
    expect_identical(summary(saved),summary(ci))
    expect_identical(plot_data(plot(saved,draw=FALSE))$table,ci$table)
    result<-mfrm_results(f,intervals=list(cells=saved),compute='never')
    expect_equal(mfrm_report(result)$tables$facet_cells_intervals[names(ci$table)],ci$table)
    changed<-f;changed$population$sigma2<-changed$population$sigma2*1.1
    expect_error(mfrm_results(changed,intervals=ci),'must match')
  }
})

test_that('expanded joint-cell route keeps unsupported and failed inference explicit', {
  skip_on_cran()
  f<-interaction_population_fixture()
  for(extra in list(list(method='profile'),list(method='sandwich'),list(scale='standardized'),list(clusters=data.frame())))
    expect_error(do.call(mfrm_facet_intervals,c(list(fit=f,interaction='Rater:Criterion'),extra)))
  changed<-f;changed$config$estimation_control$mml_engine_used<-'em'
  expect_error(mfrm_facet_intervals(changed,interaction='Rater:Criterion'),'require direct MML')
  changed<-f;changed$config$population_spec$fixed_sd<-1
  expect_error(mfrm_facet_intervals(changed,interaction='Rater:Criterion'),'estimated normal population')
  changed<-f;changed$config$interaction_specs$extra<-changed$config$interaction_specs[[1]]
  expect_error(mfrm_facet_intervals(changed,interaction='Rater:Criterion'),'one fitted two-facet')
  changed<-f;changed$interactions$effects$Estimate[1]<-changed$interactions$effects$Estimate[1]+.1
  expect_error(mfrm_facet_intervals(changed,interaction='Rater:Criterion'),'Saved interactions')
  local_mocked_bindings(compute_mml_parameter_covariance=function(...)list(status='unavailable',detail='test unavailable joint information'),.package='mfrmr')
  ci<-suppressWarnings(mfrm_facet_intervals(f,interaction='Rater:Criterion'))
  expect_true(all(is.finite(ci$table$Estimate)))
  expect_false(any(ci$table$CIEligible));expect_true(all(is.na(ci$table$Lower)))
  expect_true(any(grepl('unavailable joint information',ci$checks$Detail,fixed=TRUE)))
})

test_that('joint main-effect intervals retain scope and numerical refusal', {
  f <- interaction_population_fixture()
  for(extra in list(list(method='profile'),list(method='sandwich'),list(scale='standardized'),
                   list(clusters=data.frame()),list(adjust=TRUE)))
    expect_error(do.call(mfrm_facet_intervals,c(list(fit=f,facet='Rater'),extra)))
  changed <- f; changed$config$interaction_specs$extra <- changed$config$interaction_specs[[1]]
  expect_error(mfrm_facet_intervals(changed,'Rater'),'one fitted two-facet')
  changed <- f; changed$config$estimation_control$mml_engine_used <- 'em'
  expect_error(mfrm_facet_intervals(changed,'Rater'),'require direct MML')
  changed <- f; changed$config$population_spec$fixed_sd <- 1
  expect_error(mfrm_facet_intervals(changed,'Rater'),'estimated normal population')
  changed <- f; changed$interactions$effects$Estimate[1] <- changed$interactions$effects$Estimate[1]+.1
  expect_error(mfrm_facet_intervals(changed,'Rater'),'Saved interactions')
  # Population/profile APIs keep their own scope rather than silently widening.
  expect_error(mfrm_population_intervals(f),'no interactions')
  local_mocked_bindings(compute_mml_parameter_covariance=function(...)
    list(status='unavailable',detail='test unavailable joint information'),.package='mfrmr')
  ci <- suppressWarnings(mfrm_facet_intervals(f,'Rater'))
  expect_true(all(is.finite(ci$table$Estimate)))
  expect_false(any(ci$table$CIEligible))
  expect_identical(unique(ci$table$Status), 'numerical_review_failed')
  expect_true(all(is.na(ci$table[,c('SE','Lower','Upper','ModelSE')])) && all(is.na(vcov(ci))))
  expect_true(is.null(ci$parameter_covariance))
  expect_true(any(grepl('unavailable joint information',ci$checks$Detail,fixed=TRUE)))
  out <- mfrm_results(f, intervals=list(main=ci), compute='never')
  expect_equal(mfrm_report(out)$tables$facet_main_intervals[names(ci$table)],ci$table)
})
