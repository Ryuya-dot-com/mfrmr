native_profile_fixture <- local({
  saved<-NULL
  function(interval=FALSE) {
    if(is.null(saved)) {
      f<-readRDS(test_path('fixtures','native-location-rsm-zero-boundary.rds'))
      if(!inherits(f,'mfrm_fit'))f<-f$fit
      C<-matrix(c(1,-1),1,dimnames=list('criterion_difference',f$prep$levels$Criterion))
      saved<<-list(fit=f,C=C)
    }
    if(interval&&is.null(saved$ci))saved$ci<<-mfrm_facet_intervals(saved$fit,'Criterion',saved$C,method='profile')
    saved
  }
})

test_that('profile input rejects unsupported targets and methods before search', {
  x<-native_profile_fixture();f<-x$fit;C<-x$C
  local_mocked_bindings(mfrm_native_profile_search=function(...)stop('search reached'),.package='mfrmr')
  expect_warning(mfrm_facet_intervals(f,'Criterion',C,method='profile'),'search reached')
  expect_error(mfrm_facet_intervals(f,'Criterion',method='profile'),'explicit pairwise')
  expect_error(mfrm_facet_intervals(f,'Criterion',C*2,method='profile'),'explicit pairwise')
  multiple<-rbind(C,C);rownames(multiple)<-c('first','second')
  expect_error(mfrm_facet_intervals(f,'Criterion',multiple,method='profile'),'explicit pairwise')
  for(extra in list(list(scale='standardized'),list(adjust=TRUE),list(clusters=data.frame(Person='x',Cluster='a'))))
    expect_error(do.call(mfrm_facet_intervals,c(list(fit=f,facet='Criterion',contrasts=C,method='profile'),extra)),'unavailable')
  for(control in list(list(unknown=1),list(quad_points=2),list(quad_points=Inf),list(max_quad_points=3),list(quad_points=NA)))
    expect_error(mfrm_facet_intervals(f,'Criterion',C,method='profile',profile_control=control),'profile_control|quadrature')
  expect_error(mfrm_facet_intervals(f,'Criterion',C,profile_control=list(quad_points=81)),'only')
  for(level in list(0,1,NA,1i,matrix(.9),c(.9,.95)))
    expect_error(mfrm_facet_intervals(f,'Criterion',C,method='profile',level=level),'level')
  changed<-f;changed$steps$Estimate[1]<-changed$steps$Estimate[1]+.1
  expect_error(mfrm_facet_intervals(changed,'Criterion',C,method='profile'),'Saved steps')
  fixed<-f;fixed$config$population_spec$fixed_sd<-1
  expect_error(mfrm_facet_intervals(fixed,'Criterion',C,method='profile'),'estimated normal population')
})

test_that('closed variance profiles preserve the source fit and reporting meaning', {
  skip_on_cran()
  x<-native_profile_fixture(TRUE);ci<-x$ci;f<-x$fit
  expect_true(ci$table$CIEligible);expect_false(ci$table$CoverageQualified)
  expect_identical(ci$settings$integration,'adaptive')
  expect_identical(ci$settings$boundary_integration,'exact_zero_variance')
  expect_true(is.na(ci$table$SE));expect_true(all(is.na(vcov(ci))))
  expect_identical(ci$fit,f)
  expect_equal(ci$table$SourceEstimate,unname(drop(x$C%*%f$facets$others$Estimate[f$facets$others$Facet=='Criterion'])))
  expect_equal(ci$table$Estimate,ci$table$ProfileEstimate)
  expect_true(all(ci$profile$ResidualVariance>=0))
  expect_output(print(ci),'profile likelihood')
  expect_false(any(grepl('Pointwise normal',capture.output(print(ci)))))
  expect_equal(unname(confint(ci)),unname(as.matrix(ci$table[c('Lower','Upper')])))
  expect_error(confint(ci,level=.9),'saved level')
  p<-plot(ci,draw=FALSE)
  expect_match(plot_data(p,'subtitle'),'connected profile')
  expect_false(grepl('normal intervals',plot_data(p,'subtitle')))
  expect_null(p$labels$title)
  expect_true(all(ggplot2::ggplot_build(p)$data[[1]]$colour!='grey50'))
  res<-mfrm_results(f,intervals=list(contrast=ci),compute='never')
  report<-mfrm_report(res)
  expect_identical(report$tables$facet_contrast_intervals$SourceEstimate,ci$table$SourceEstimate)
  expect_identical(report$tables$facet_contrast_profile,ci$profile)
  expect_match(report$markdown,'Connected profile-likelihood intervals',fixed=TRUE)
  expect_match(report$markdown,'Source estimates remain separate from reoptimized centers',fixed=TRUE)
  expect_match(apa_table(ci)$note,'chi-square',fixed=TRUE)
  saved<-unserialize(serialize(list(ci=ci,res=res),NULL))
  expect_identical(summary(saved$ci),summary(ci))
  expect_identical(plot_data(plot(saved$ci,draw=FALSE)),plot_data(p))
  expect_identical(mfrm_report(saved$res)$tables,report$tables)
  changed<-f;changed$config$population_spec$formula<-~2
  changed$steps$Estimate[1]<-changed$steps$Estimate[1]+.1
  expect_error(mfrm_results(changed,intervals=ci),'must match')
})

test_that('unresolved profiles remain missing and retain refusal records', {
  x<-native_profile_fixture()
  local_mocked_bindings(mfrm_native_profile_search=function(input,L,level,q)
    list(available=FALSE,reason='quadrature_unresolved',quad_points=q,
      failure=list(message='quadrature_unresolved',attempts=list(marker=123))),.package='mfrmr')
  expect_warning(ci<-mfrm_facet_intervals(x$fit,'Criterion',x$C,method='profile',
    profile_control=list(quad_points=3,max_quad_points=5)),'quadrature_unresolved')
  expect_equal(ci$checks$QuadPoints,c(3,5));expect_false(ci$table$CIEligible)
  expect_true(is.na(ci$table$Lower));expect_true(is.na(ci$table$ProfileEstimate))
  expect_equal(ci$table$Estimate,ci$table$SourceEstimate)
  expect_identical(ci$profile_attempts[[1]]$failure$attempts$marker,123)
  expect_equal(nrow(plot_data(plot(ci,draw=FALSE),'table')),1)

  normal<-suppressWarnings(mfrm_facet_intervals(x$fit,'Criterion',x$C))
  for(intervals in list(list(profile=ci),list(normal=normal),list(profile=ci,normal=normal))) {
    res<-mfrm_results(x$fit,intervals=intervals,include=c('fit','plots'),compute='never')
    report<-mfrm_report(res)
    section<-tail(strsplit(report$markdown,'## Fixed-facet uncertainty',fixed=TRUE)[[1]],1)
    expect_identical(grepl('Connected profile-likelihood intervals',section,fixed=TRUE),'profile'%in%names(intervals))
    expect_identical(grepl('pointwise normal approximation',section,fixed=TRUE),'normal'%in%names(intervals))
    if('profile'%in%names(intervals)) {
      expect_match(section,'when available; finite-sample and boundary coverage are not established',fixed=TRUE)
      expect_identical(report$tables$facet_profile_intervals$Estimate,ci$table$SourceEstimate)
      expect_true(all(is.na(report$tables$facet_profile_intervals$Lower)))
    }
  }
  # Export only the two interval figures from the mixed-method result.
  res$plot_map<-res$plot_map[startsWith(res$plot_map$Type,'facet_'),]
  out_dir<-tempfile('profile-report-');on.exit(unlink(out_dir,recursive=TRUE),add=TRUE)
  exported<-export_mfrm_results(res,out_dir,include='plots',acknowledge_sensitive=TRUE)
  expect_equal(nrow(exported$plot_errors),0L)
  figures<-exported$written_files[exported$written_files$Format=='png',]
  expect_equal(nrow(figures),2L)
  profile_note<-figures$Note[figures$Component=='plot_facet_profile']
  expect_match(profile_note,'connected profile-likelihood intervals',fixed=TRUE)
  expect_false(grepl('normal intervals',profile_note,fixed=TRUE))
  expect_match(figures$Note[figures$Component=='plot_facet_normal'],'pointwise normal intervals',fixed=TRUE)
})

test_that('native profile design retains binary and multiple-category generalizations', {
  skip_on_cran()
  f<-readRDS(test_path('fixtures','native-location-pcm-regression.rds'))$fit
  d<-f$prep$data[c('Person','Rater','Criterion','Score')]
  people<-data.frame(Person=f$prep$levels$Person,X=seq_along(f$prep$levels$Person)/length(f$prep$levels$Person))
  cases<-list(f)
  for(binary in c(TRUE,FALSE)) {
    data<-d;if(binary)data$Score<-as.integer(data$Score>1)
    data$Occasion<-as.character(seq_len(nrow(data))%%5>2)
    # One iteration intentionally supplies coordinates, not a qualified fit.
    expect_warning(cases[[length(cases)+1L]]<-fit_mfrm(data,'Person',c('Rater','Criterion','Occasion'),'Score',
      model=if(binary)'RSM' else 'PCM',method='MML',step_facet=if(binary)NULL else 'Criterion',
      population_formula=~X+I(X^2),person_data=people,person_id='Person',maxit=1L),'iteration limit')
  }
  for(fit in cases) {
    input<-mfrm_native_profile_design(fit);z<-input$source;z[length(z)]<-.7
    fun<-mfrm_native_profile_likelihood(input,161L);actual<-fun(z,TRUE)
    cfg<-fit$config;cfg$estimation_control$mml_integration<-'fixed'
    sizes<-build_param_sizes(cfg);idx<-build_indices(fit$prep,cfg$step_facet)
    ref<-make_mfrm_direct_evaluator('MML',make_param_cache(sizes,cfg,idx,is_mml=TRUE),idx,cfg,sizes,gauss_hermite_normal(161L))
    native<-z;native[length(z)]<-log(tail(z,1));g<-ref$gradient(native);g[length(g)]<-g[length(g)]/tail(z,1)
    fixed<-mfrm_native_profile_likelihood(input,161L,adaptive=FALSE)(z,TRUE)
    expect_equal(actual,fixed,tolerance=1e-8)
    expect_equal(actual$value,ref$value(native),tolerance=1e-9)
    expect_equal(unname(actual$gradient),unname(g),tolerance=1e-8)
    H<-numDeriv::jacobian(function(u)fun(u)$gradient,z,
      method.args=list(eps=1e-3,d=1e-3,zero.tol=.1))
    expect_equal(unname(actual$hessian),unname(H),tolerance=1e-7)
    z[length(z)]<-0
    zero<-fun(z,TRUE)
    h<-1e-5;plus<-z;plus[length(z)]<-h;half<-z;half[length(z)]<-h/2
    derivative<-2*(fun(half)$gradient-zero$gradient)/(h/2)-(fun(plus)$gradient-zero$gradient)/h
    expect_equal(unname(zero$hessian[,ncol(zero$hessian)]),unname(derivative),tolerance=1e-6)
  }
})

test_that('profile curvature and high-order stationarity respect contrast coordinates', {
  z<-c(0,0,0,1);L<-c(1,-1,-1,0)
  low<-function(z,...)list(value=0,gradient=rep(0,4),hessian=diag(.4,4))
  high<-function(z,...)list(value=0,gradient=rep(0,4),hessian=diag(.4,4)+.05)
  a<-mfrm_native_profile_qualify(list(par=z),low,high,L,0)
  expect_equal(a$projected_hessian_error_bound,.6,tolerance=1e-12)
  expect_false(a$pass)
  high<-function(z,...)list(value=0,gradient=rep(6e-6,4),hessian=diag(.4,4))
  a<-mfrm_native_profile_qualify(list(par=z),low,high,L,0)
  expect_equal(a$high_kkt,1.2e-5);expect_false(a$pass)
})


test_that('adaptive profile likelihood agrees with continuous integration', {
  skip_on_cran()
  f<-readRDS(test_path('fixtures','native-location-pcm-regression.rds'))$fit
  input<-mfrm_native_profile_design(f);z<-input$source;z[length(z)]<-4
  eta<-do.call(cbind,lapply(input$D,function(D)drop(D%*%head(z,-1))))
  # Integrate each Person's likelihood independently, without GH nodes or weights.
  reference<--sum(vapply(split(seq_along(input$y),input$person),function(ix) {
    log_density<-function(t)vapply(t,function(tt) {
      logits<-eta[ix,,drop=FALSE]+matrix((0:input$K)*sqrt(tail(z,1))*tt,
        length(ix),input$K+1L,byrow=TRUE)
      top<-apply(logits,1,max)
      sum(logits[cbind(seq_along(ix),input$y[ix]+1L)]-top-
        log(rowSums(exp(logits-top))))+dnorm(tt,log=TRUE)
    },0.)
    top<--optimize(function(t)-log_density(t),c(-12,12),tol=1e-10)$objective
    ans<-integrate(function(t)exp(log_density(t)-top),-Inf,Inf,
      rel.tol=1e-10,abs.tol=1e-11,subdivisions=300L)
    expect_identical(ans$message,'OK')
    top+log(ans$value)
  },0.))
  expect_equal(mfrm_native_profile_likelihood(input,81L)(z)$value,reference,tolerance=1e-9)
})
