test_that("one-family MML identifies endpoint paths under both population scales", {
  d <- expand.grid(Person=paste0('P',1:16), Rater=paste0('R',1:3), Task=paste0('T',1:2))
  d$Score <- (as.integer(d$Person)+as.integer(d$Rater)+as.integer(d$Task)) %% 4L
  for (population in c('fixed_standard_normal','free_population')) {
    f <- suppressWarnings(fit_mfrm(d, person='Person', facets=c('Rater','Task'),
      score='Score', model='GPCM', method='MML', slope_facet='Rater', step_facet='Rater',
      rating_min=0, rating_max=4, keep_original=TRUE,
      noncenter_facet=if(population=='free_population') 'Person' else 'Rater',
      gpcm_mml_identification=population, mml_integration='fixed', quad_points=15L,maxit=50L))
    expect_identical(f$readiness$fit$BoundaryState,'nonfinite_maximum')
    expect_match(f$readiness$fit$ReasonCodes,'mml_unobserved_global_endpoint')
    expect_false(mfrm_gpcm_slope_inference_check(f,list())$eligible)
    expect_match(mfrm_gpcm_slope_inference_check(f,list())$review,'no finite maximum')
    ci <- suppressWarnings(confint(f,parm='slopes'))
    expect_false(any(attr(ci,'diagnostics')$CIEligible))
    expect_match(summary(f)$estimation_note,'no finite maximum')
    original <- serialize(f,NULL)
    f$readiness$fit$BoundaryState <- 'not_evaluated'
    expect_identical(mfrmr_get_readiness_record(f)$fit$BoundaryState,'nonfinite_maximum')
    expect_identical(f$opt,unserialize(original)$opt)
    # Fixing all steps removes this particular path; other boundary searches
    # may still be needed and are not certified by this negative control.
    cfg<-f$config
    for(j in seq_along(cfg$step_specs)) cfg$step_specs[[j]]$anchors[]<-0
    expect_length(mfrmr_mml_additive_boundary_evidence(cfg),0)
  }
})

test_that("two-family boundary values are not used for rater sheets or curves", {
  d<-expand.grid(Person=paste0('p',1:16),Task=paste0('t',1:3),Rater=paste0('r',1:3))
  d$Score<-(as.integer(d$Person)+as.integer(d$Task)+as.integer(d$Rater)) %% 4L
  f<-suppressWarnings(fit_mfrm(d,person='Person',facets=c('Task','Rater'),score='Score',
    model='GPCM',method='MML',slope_facet=c('Task','Rater'),step_facet='Rater',
    noncenter_facet='Rater',rating_min=0,rating_max=4,keep_original=TRUE,
    gpcm_mml_identification='fixed_standard_normal',mml_engine='em',
    quad_points=15L,maxit=50L))
  expect_identical(f$readiness$fit$BoundaryState,'nonfinite_maximum')
  res<-mfrm_results(f,include='fit',compute='never')
  expect_error(mfrm_report(res,style='rater',facet='Rater',rater='r1'),'no finite maximum')
  expect_error(mfrm_curve_intervals(f,data.frame(Theta=0,Task='t1',Rater='r1')),'no finite maximum')
})
