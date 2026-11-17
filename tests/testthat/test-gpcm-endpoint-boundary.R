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

test_that("two-family endpoint paths respect step ownership and location constraints", {
  # The independent adjacent equation is kept local: a_r*a_t multiplies the
  # whole predictor. The tested path changes only the unused endpoint odds.
  probability <- function(theta, location, steps, slope) {
    u<-cbind(0,t(apply(slope*(theta-location-steps),1,cumsum)))
    u<-u-apply(u,1,max);exp(u)/rowSums(exp(u))
  }
  d<-expand.grid(Person=paste0('p',1:16),Task=paste0('t',1:3),
    Rater=paste0('r',1:3),Criterion=paste0('c',1:2))
  scores<-(as.integer(d$Person)+as.integer(d$Task)+as.integer(d$Rater)) %% 5L
  for(step in c('Task','Rater','Criterion')) for(noncenter in c('Task','Rater'))
    for(endpoint in c(0L,4L)) for(local in c(FALSE,TRUE)) {
      d$Score<-scores
      selected<-if(local) as.integer(d[[step]])==1L else rep(TRUE,nrow(d))
      d$Score[selected & d$Score==endpoint]<-if(endpoint==0L) 1L else 3L
      p<-mfrm_gmfrm_problem(d,4L,gauss_hermite_normal(7L),
        facets=c('Task','Rater','Criterion'),step_facet=step,noncenter_facet=noncenter)
      review<-mfrm_gmfrm_point_review(p$common$prep,p$common$config,list(par=p$start))
      expect_identical(review$overview$Status,'finite_maximum_absent')
      expect_length(review$boundary$Facet,0)
      expect_true(length(review$endpoint_reasons)>0L)
      # Full location shifts: compensating the owner's mean in the free facet
      # gives a net +/-t/4 only for the affected rows, regardless of centering.
      slope<-c(.8,1,1.25)[d$Task]*c(.7,1,1.4)[d$Rater]
      base<-matrix(rep(c(-1.2,-.4,.4,1.2),each=nrow(d)),nrow(d))
      delta<-matrix(0,nrow(d),4L)
      delta[selected,]<-matrix(rep(if(endpoint==4L) c(-1,-1,-1,3) else c(-3,1,1,1),
        each=sum(selected)),sum(selected))
      before<-probability(.3,0,base,slope)
      after<-probability(.3,ifelse(selected,if(endpoint==4L) 1 else -1,0),base+delta,slope)
      observed<-cbind(seq_len(nrow(d)),d$Score+1L)
      expect_true(all(after[observed][selected]>before[observed][selected]))
      expect_equal(after[!selected,,drop=FALSE],before[!selected,,drop=FALSE],tolerance=1e-14)
      expect_equal(rowSums(base+delta),rep(0,nrow(d)),tolerance=1e-14)
    }
})

test_that("two-family endpoint fits and saved points cannot masquerade as finite maxima", {
  d<-expand.grid(Person=paste0('p',1:16),Task=paste0('t',1:3),Rater=paste0('r',1:3))
  d$Score<-(as.integer(d$Person)+as.integer(d$Task)+as.integer(d$Rater)) %% 4L
  f<-suppressWarnings(fit_mfrm(d,person='Person',facets=c('Task','Rater'),score='Score',
    model='GPCM',method='MML',slope_facet=c('Task','Rater'),step_facet='Rater',
    noncenter_facet='Rater',rating_min=0,rating_max=4,keep_original=TRUE,
    gpcm_mml_identification='fixed_standard_normal',mml_engine='em',
    mml_integration='auto',quad_points=15L,maxit=50L))
  expect_identical(f$summary$PointEstimateStatus,'finite_maximum_absent')
  expect_identical(f$summary$BoundaryState,'nonfinite_maximum')
  expect_true(all(is.na(f$slopes$PrimaryEstimate)))
  expect_identical(f$summary$MMLAccuracyStatus,'full_maximum_absent')
  expect_false(mfrm_gpcm_product_inference(f)$check$eligible)
  contexts<-data.frame(Theta=0,Task='t1',Rater='r1')
  expect_error(mfrm_curve_intervals(f,contexts),'no finite maximum')
  old<-f
  old$config$gpcm_point_estimation$overview$Status<-'finite_numerical_solution'
  old$config$gpcm_point_estimation$overview$PrimaryAvailable<-TRUE
  old$slopes$PrimaryEstimate<-old$slopes$Estimate
  old$slopes$ParameterStatus<-'finite_numerical_solution'
  old$readiness$parameters$PrimaryEstimate<-old$slopes$Estimate
  original<-serialize(old,NULL)
  expect_true(all(is.na(mfrmr_get_readiness_record(old)$parameters$PrimaryEstimate)))
  s<-summary(old,compute='never')
  expect_identical(s$point_estimation$Status,'finite_maximum_absent')
  res<-mfrm_results(old,include='fit',compute='never')
  expect_true(all(is.na(res$tables$gpcm_fitted_slopes$PrimaryEstimate)))
  expect_identical(res$fit$opt,old$opt)
  report<-mfrm_report(res)
  expect_identical(report$tables$point_estimation$Status,'finite_maximum_absent')
  sheet<-mfrm_report(res,style='rater',facet='Rater',rater='r1')
  expect_true(all(is.na(sheet$tables$severity$Location)))
  expect_true(all(is.na(sheet$tables$slope$ComponentSlope)))
  expect_true(all(is.na(sheet$tables$steps$Offset)))
  stale<-res;stale$fit<-old
  expect_error(mfrm_report(stale),'Rebuild mfrm_results')
  expect_identical(serialize(old,NULL),original)
})

test_that("global endpoint refits preserve targets, category labels and inference limits", {
  skip_on_cran()
  withr::local_seed(111035)
  d<-expand.grid(Person=paste0('P',1:24),Rater=paste0('R',1:3),Task=paste0('T',1:3))
  theta<-rnorm(24)
  eta<-theta[as.integer(d$Person)]-c(-.5,0,.5)[d$Rater]-c(-.3,0,.3)[d$Task]
  a<-c(.8,1,1.25)[d$Rater]
  prob<-t(vapply(seq_len(nrow(d)),function(i) {
    u<-c(0,cumsum(a[i]*(eta[i]-c(-1.2,-.4,.4,1.2))))
    exp(u-max(u))/sum(exp(u-max(u)))
  },numeric(5)))
  d$Score<-1L+rowSums(runif(nrow(d))>t(apply(prob,1,cumsum)))
  for(two in c(FALSE,TRUE)) {
    x<-d
    if(two) {x$Score[x$Score==5]<-4;x$Score<-x$Score-1L} else x$Score[x$Score==1]<-2
    fit<-withCallingHandlers(fit_mfrm(x,person='Person',facets=c('Rater','Task'),score='Score',
      model='GPCM',method='MML',slope_facet=if(two)c('Task','Rater') else 'Rater',step_facet='Rater',
      noncenter_facet=if(two)'Rater' else 'Person',rating_min=if(two)0 else 1,rating_max=if(two)4 else 5,
      keep_original=TRUE,category_policy='preserve',gpcm_mml_identification=if(two)'fixed_standard_normal' else 'free_population',
      mml_engine='direct',mml_integration='auto',quad_points=31L,maxit=1000L),warning=function(w) {
        if(grepl('Category support is retained',conditionMessage(w),fixed=TRUE)) invokeRestart('muffleWarning')
      })
    saved<-serialize(fit,NULL);reduced<-fit$point_limit$fit
    expect_identical(fit$summary$BoundaryState,'nonfinite_maximum')
    expect_identical(fit$summary$MMLAccuracyStatus,'full_maximum_absent')
    expect_identical(fit$point_limit$overview$Status,'partial_points_available')
    expect_equal(nrow(reduced$prep$data),nrow(x))
    expect_equal(fit$slopes$PrimaryEstimate,reduced$slopes$Estimate)
    expect_true(all(fit$slopes$ParameterStatus=='finite_likelihood_limit'))
    expect_true(all(is.na(fit$point_limit$step_targets$PrimaryEstimate)))
    expect_false(any(fit$slopes$CIEligible))
    if(!two) {
      expect_equal(fit$slopes$PrimaryPopulationSD,rep(sqrt(reduced$population$sigma2),3))
      expect_equal(fit$slopes$FixedLatentSDPrimaryEstimate,reduced$slopes$Estimate*sqrt(reduced$population$sigma2))
    }
    sx<-summary(fit,compute='never')
    expect_identical(sx$category_map,fit$point_limit$category_map)
    res<-mfrm_results(fit,include='fit',compute='never');report<-mfrm_report(res)
    expect_identical(res$tables$gpcm_category_map,fit$point_limit$category_map)
    expect_true(any(grepl('category_map',names(report$tables))))
    expect_true(all(res$tables$gpcm_limit_locations$Basis=='reduced_category_convention'))
    expect_false(mfrm_gpcm_slope_inference_check(reduced,list())$eligible)
    ci<-suppressWarnings(confint(reduced,parm='slopes'))
    expect_false(any(attr(ci,'diagnostics')$CIEligible))
    loc<-suppressWarnings(mfrm_facet_intervals(reduced,facet='Rater'))
    expect_false(any(loc$table$CIEligible))
    q<-data.frame(Theta=c(-1,0,1),Task='T1',Rater='R1')
    expect_error(mfrm_curve_intervals(fit,q),'no finite maximum')
    curves<-mfrm_curve_intervals(reduced,q)
    expect_identical(curves$settings$point_only,TRUE)
    expect_equal(sort(unique(curves$table$Category)),if(two)0:4 else 1:5)
    expect_equal(as.numeric(rowsum(curves$table$Estimate,curves$table$InputRow)),rep(1,3),tolerance=1e-13)
    excluded<-curves$table$CategoryBasis=='zero_probability_limit'
    expect_equal(curves$table$Estimate[excluded],rep(0,3))
    expect_false(any(curves$table$CIEligible))
    expect_s3_class(plot(curves,draw=FALSE),'ggplot')
    if(two) {
      sheet<-mfrm_report(res,style='rater',facet='Rater',rater='R1')
      expect_true(all(is.na(sheet$tables$severity$Location)))
      expect_true(all(is.na(sheet$tables$steps$Offset)))
      expect_equal(sheet$tables$slope$ComponentSlope,fit$slopes$PrimaryEstimate[fit$slopes$SlopeOwner=='Rater' & fit$slopes$SlopeFacet=='R1'])
    }
    wrong<-fit;wrong$point_limit$fit$prep$data$score_k[1]<-99L
    expect_error(summary(wrong),'does not match')
    wrong<-fit;wrong$point_limit$category_map$OriginalScore[1]<-99
    expect_error(mfrm_results(wrong,include='fit',compute='never'),'does not match')
    wrong<-fit;wrong$point_limit$targets$PrimaryEstimate[1]<-99
    expect_error(summary(wrong),'does not match')
    limited<-fit;limited$point_limit<-NULL;limited$prep$data$Weight[1]<-2
    limited<-mfrm_gpcm_endpoint_limit(limited)
    expect_identical(limited$point_limit$overview$Status,'not_evaluated')
    expect_true(all(is.na(limited$slopes$PrimaryEstimate)))
    failure<-function() {
      testthat::local_mocked_bindings(fit_mfrm=function(...) stop('Deliberate numerical failure'),.package='mfrmr')
      original<-fit;original$point_limit<-NULL
      mfrm_gpcm_endpoint_limit(original)
    }
    failed<-failure()
    expect_identical(failed$point_limit$overview$Status,'numerical_unresolved')
    expect_match(failed$point_limit$failure$message,'Deliberate numerical failure')
    expect_true(all(is.na(failed$slopes$PrimaryEstimate)))
    expect_identical(failed$opt,fit$opt)
    expect_identical(serialize(fit,NULL),saved)
  }
})
