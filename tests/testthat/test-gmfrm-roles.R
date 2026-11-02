# A literal adjacent-category equation, independent of parameter expansion,
# response kernels, marginal likelihood helpers and Person-score derivatives.
gmfrm_roles_probability <- function(x, problem, data, theta) {
  spec <- problem$specification; levels <- problem$levels
  facets <- spec$facets; owners <- spec$slope_facets
  lookup <- function(f, prefix, centered) {
    lev <- levels[[f]]; free <- if (centered) lev[-length(lev)] else lev
    values <- x[paste0(prefix, ':', f, ':', free)]
    if (centered) values <- c(values, -sum(values))
    unname(values[match(as.character(data[[f]]), lev)])
  }
  location <- Reduce(`+`, lapply(facets, function(f)
    lookup(f, 'location', f != spec$noncenter_facet)))
  slope <- exp(Reduce(`+`, lapply(owners, function(f)
    lookup(f, 'log_slope', f == spec$slope_reference))))
  K <- spec$max_score
  steps <- t(vapply(levels[[spec$step_facet]], function(lev) {
    free <- if (K > 1L) x[paste0('step:', spec$step_facet, ':', lev, ':', seq_len(K-1L))] else numeric()
    c(free, -sum(free))
  }, numeric(K)))
  steps <- steps[match(as.character(data[[spec$step_facet]]),levels[[spec$step_facet]]),,drop=FALSE]
  logits <- matrix(0, nrow(data), K+1L)
  for (k in seq_len(K)) logits[,k+1L] <- logits[,k] + slope * (theta-location-steps[,k])
  logits <- logits - apply(logits,1,max)
  exp(logits)/rowSums(exp(logits))
}

gmfrm_roles_nll <- function(x, problem) {
  names(x) <- names(problem$start)
  spec <- problem$specification; d <- spec$data; q <- spec$quadrature
  take <- rep(seq_len(nrow(d)),length(q$nodes))
  probability <- gmfrm_roles_probability(x,problem,d[take,,drop=FALSE],rep(q$nodes,each=nrow(d)))
  observed <- matrix(log(probability[cbind(seq_along(take),d[[spec$score]][take]+1L)]),nrow(d))
  total <- rowsum(observed,as.character(d[[spec$person]]))
  logw <- sweep(total,2,log(q$weights),'+'); peak <- apply(logw,1,max)
  -sum(peak+log(rowSums(exp(logw-peak))))
}

gmfrm_roles_fixture <- local({
  cached <- NULL
  function() {
    if (!is.null(cached)) return(cached)
    withr::local_seed(6110127)
    d <- expand.grid(Person=paste0('p',1:160),Task=c('t1','t2'),Rater=c('r1','r2'),Criterion=c('c1','c2'))
    spec <- list(person='Person',facets=c('Task','Criterion','Rater'),score='Score',model='GPCM',method='MML',
      slope_facet=c('Task','Rater'),slope_reference='Task',step_facet='Criterion',noncenter_facet='Rater',
      gpcm_mml_identification='fixed_standard_normal')
    theta <- rnorm(160); t <- as.integer(d$Task); r <- as.integer(d$Rater); c <- as.integer(d$Criterion)
    eta <- theta[as.integer(d$Person)]-c(-.3,.3)[t]-c(-.2,.2)[r]-c(-.1,.1)[c]
    a <- c(.8,1.25)[t]*c(.9,1.2)[r]; steps <- matrix(c(-.4,-.7,.4,.7),2)
    prob <- t(vapply(seq_len(nrow(d)),function(i) {
      z <- c(0,cumsum(a[i]*(eta[i]-steps[c[i],]))); exp(z-max(z))/sum(exp(z-max(z)))
    },numeric(3)))
    d$Score <- rowSums(runif(nrow(d))>t(apply(prob,1,cumsum)))
    fit <- fit_mfrm(d,spec=spec,control=list(mml_engine='em',quad_points=41L,maxit=1000L,em_score_tol=1e-7))
    cached <<- list(fit=fit,data=d,spec=spec)
    cached
  }
})

test_that('named two-family roles reproduce independent three- and five-facet likelihoods', {
  for (five in c(FALSE,TRUE)) {
    cells <- expand.grid(Task=c('t1','t2'),Rater=c('r1','r2'),Criterion=c('c1','c2'))
    if (five) cells <- merge(cells,expand.grid(Occasion=c('o1','o2'),Venue=c('v1','v2')))
    d <- merge(data.frame(Person=c('p1','p2','p3')),cells)
    d$Score <- rep(0:2,length.out=nrow(d)); facets <- names(cells)
    build <- function(reference='Task', noncenter='Rater') mfrm_gmfrm_problem(d,2L,gauss_hermite_normal(11L),
      facets=facets,step_facet='Criterion',noncenter_facet=noncenter,slope_reference=reference)
    p <- build(); x <- p$start + seq(-.15,.2,length.out=length(p$start))
    expect_equal(length(x),if (five) 11L else 9L)
    expect_equal(-p$marginal(x)$logLik,gmfrm_roles_nll(x,p),tolerance=1e-12)
    h <- 1e-5
    gradient <- vapply(seq_along(x),function(j) {
      plus <- minus <- x; plus[j]<-plus[j]+h; minus[j]<-minus[j]-h
      (gmfrm_roles_nll(plus,p)-gmfrm_roles_nll(minus,p))/(2*h)
    },0)
    expect_equal(p$marginal(x)$gradient*3,gradient,tolerance=1e-7)
    withr::with_options(list(mfrmr.use_cpp11_backend=FALSE), {
      pure <- build()
      expect_equal(pure$marginal(x)$gradient,p$marginal(x)$gradient,tolerance=1e-12)
      expect_equal(pure$marginal(x)$logLik,p$marginal(x)$logLik,tolerance=1e-12)
    })
    query <- cells; query$Theta <- seq(-1,1,length.out=nrow(cells))
    expect_equal(unname(p$response(x,query)$probabilities),gmfrm_roles_probability(x,p,query,query$Theta),tolerance=1e-12)
    # Reference changes preserve the two products; step and location roles stay fixed.
    other <- build('Rater'); y <- other$start
    y[!grepl('^log_slope:',names(y))] <- x[names(y)[!grepl('^log_slope:',names(y))]]
    values <- p$unpack(x)$slopes; center <- mean(log(values$Rater))
    for (f in c('Task','Rater')) {
      z <- log(values[[f]]) + if (f=='Task') center else -center
      keys <- paste0('log_slope:',f,':',names(z)); keep <- keys %in% names(y)
      y[keys[keep]] <- z[keep]
    }
    expect_equal(unname(other$response(y,query)$probabilities),unname(p$response(x,query)$probabilities),tolerance=1e-12)
    expect_equal(other$marginal(y)$logLik,p$marginal(x)$logLik,tolerance=1e-12)
    renamed <- c(Task='Task name',Rater='Judge',Criterion='Rubric criterion',
      Occasion='Sitting',Venue='Place')[facets]
    rd <- d; names(rd)[match(facets,names(rd))] <- renamed
    rp <- mfrm_gmfrm_problem(rd,2L,gauss_hermite_normal(11L),
      slope_facets=unname(renamed[c('Task','Rater')]),facets=unname(renamed),
      step_facet=renamed[['Criterion']],noncenter_facet=renamed[['Rater']],
      slope_reference=renamed[['Task']])
    rx <- x
    for (f in facets) names(rx) <- sub(paste0(':',f,':'),paste0(':',renamed[[f]],':'),names(rx),fixed=TRUE)
    rx <- rx[names(rp$start)]
    expect_equal(rp$marginal(rx)$logLik,p$marginal(x)$logLik,tolerance=1e-12)
    confounded <- d; confounded$Criterion <- confounded$Rater
    confounded <- confounded[!duplicated(confounded[c("Person",facets)]),]
    expect_error(mfrm_gmfrm_problem(confounded,2L,gauss_hermite_normal(7L),facets=facets,
      step_facet='Criterion',noncenter_facet='Rater'),'identify all additive')
  }
})

test_that('three-facet public fits preserve roles, point curves, reports and refusal boundaries', {
  x <- gmfrm_roles_fixture(); f <- x$fit
  expect_true(f$summary$Converged); expect_false(f$summary$InferenceReady)
  expect_identical(f$config$facet_names,c('Task','Rater','Criterion'))
  expect_identical(f$config$step_facet,'Criterion')
  expect_identical(summary(f)$slope_overview$StepOwner,rep('Criterion',2))
  reverse <- x$spec; reverse$facets <- rev(reverse$facets); reverse$slope_facet <- rev(reverse$slope_facet)
  a <- fit_mfrm(x$data,spec=x$spec,control=list(mml_engine='em',quad_points=7L,maxit=1L))
  b <- fit_mfrm(x$data,spec=reverse,control=list(mml_engine='em',quad_points=7L,maxit=1L))
  expect_identical(a$opt$par,b$opt$par)
  query <- unique(x$data[c('Task','Rater','Criterion')]); query$Theta<-0
  curves <- mfrm_curve_intervals(f,query)
  expect_s3_class(plot(curves,draw=FALSE),'ggplot')
  result <- mfrm_results(f,intervals=curves,compute='never')
  expect_s3_class(mfrm_report(result),'mfrm_report')
  sheet <- mfrm_report(result,style='rater',facet='Rater',rater='r1')
  expect_s3_class(sheet,'mfrm_rater_feedback')
  expect_equal(nrow(sheet$tables$steps),0L)
  expect_match(sheet$notes[["steps"]],'another declared facet')
  expect_equal(sheet$tables$severity$Location,
    unname(f$facets$others$Estimate[f$facets$others$Facet=='Rater' & f$facets$others$Level=='r1']))
  locations <- result$tables$gpcm_fitted_locations
  expect_identical(locations$FittedLocation,unname(f$facets$others$Estimate))
  expect_identical(locations$Constraint,ifelse(locations$Facet=='Rater',
    'Uncentered; fixed N(0,1) ability','Sum to zero across levels'))
  restored <- unserialize(serialize(f,NULL))
  expect_identical(mfrm_results(restored,compute='never')$tables,mfrm_results(f,compute='never')$tables)
  broken <- f; broken$gmfrm$specification$step_facet <- 'Task'
  expect_error(mfrm_gmfrm_response_input(broken),'saved two-family')
  expect_error(fit_mfrm(x$data,spec=modifyList(x$spec,list(slope_reference='Criterion'))),'slope_reference')
  expect_error(fit_mfrm(x$data,spec=modifyList(x$spec,list(method='JML'))),'slope_reference|method')
  export_dir <- tempfile()
  on.exit(unlink(export_dir,recursive=TRUE),add=TRUE)
  exported <- export_mfrm_model(f,output_dir=export_dir,acknowledge_sensitive=TRUE)
  expect_identical(readRDS(exported$files[['model-data.rds']])$model_roles$step_facet,'Criterion')
  expect_error(export_mfrm_model(data=x$data,spec=x$spec,output_dir=tempfile()),'slope_reference')
})

test_that('extended Bayesian roles survive joint draws, contrasts and public reporting', {
  skip_on_cran()
  f <- gmfrm_roles_fixture()$fit
  dir <- tempfile()
  dir.create(dir)
  on.exit(unlink(dir, recursive=TRUE), add=TRUE)
  simulated <- build_synthetic_joint_bundle(f, dir)
  x <- read_mfrm_posterior(dir, draws='require')
  expect_identical(x$model_roles$step_facet, 'Criterion')
  expect_identical(x$source$SlopeReference, 'Task')
  expect_identical(x$source$UncenteredFacet, 'Rater')
  expect_true(all(x$parameters$facet[x$parameters$quantity=='step_offset']=='Criterion'))
  cx <- summary(x, contrasts=c('Criterion','steps'), level=.9)
  M <- mfrmr:::.mfrm_flatten_draws_array(x$draws$array)
  for (i in seq_len(nrow(cx$contrasts))) {
    w <- cx$contrast_draws$specs[[i]]$weights
    direct <- as.vector(M[,names(w),drop=FALSE] %*% w)
    expect_equal(as.numeric(cx$contrast_draws$array[,,i]), direct, tolerance=1e-12)
    expect_equal(cx$contrasts$mean[i], mean(direct), tolerance=1e-12)
    expect_equal(unname(c(cx$contrasts$lower[i],cx$contrasts$upper[i])),
      unname(quantile(direct,c(.05,.95))), tolerance=1e-12)
  }
  expect_s3_class(plot(cx,quantity='contrast',draw=FALSE),'ggplot')
  expect_s3_class(plot(x,quantity='step_offset',facet='Criterion',draw=FALSE),'ggplot')
  expect_s3_class(mfrm_report(cx),'mfrm_report')
  restored <- unserialize(serialize(cx,NULL))
  expect_identical(confint(restored,parm='contrasts'),confint(cx,parm='contrasts'))
  expect_identical(restored$model_roles,x$model_roles)
  expect_match(paste(x$notes,collapse=' '),'fresh independent priors changes')
  expect_error(predict(x,newdata=f$data),'two-family|Two-family|product')
  helpers <- mfrmr:::.mfrm_posterior_helpers()
  for (key in c('step_facet','slope_reference','noncenter_facet','slope_prior_reference')) {
    bad <- simulated$bundle
    bad$model_roles[[key]] <- 'Missing'
    expect_error(helpers$mfrm_parameter_map(bad),'model roles disagree')
  }
  bad <- f; bad$gmfrm$specification$step_facet <- 'Task'
  expect_error(export_mfrm_model(bad,tempfile(),acknowledge_sensitive=TRUE),'roles and location')
})

test_that('extended roles retain joint information, posterior scoring and portable identity', {
  skip_on_cran()
  skip_if_not_installed('numDeriv')
  x <- gmfrm_roles_fixture(); f <- x$fit
  p <- do.call(mfrm_gmfrm_problem,f$gmfrm$specification)
  check <- mfrm_gpcm_product_inference(f)
  expect_true(check$check$eligible)
  H <- numDeriv::hessian(function(z)gmfrm_roles_nll(z,p),f$opt$par,
    method.args=list(eps=.01,d=.01,zero.tol=1))
  expect_equal(unname(check$information$hessian),unname(H),tolerance=1e-5)
  expect_equal(unname(check$covariance),unname(solve(H)),tolerance=1e-5)
  ci <- suppressWarnings(confint(f,parm='slopes'))
  expect_true(all(is.finite(ci)))
  expect_warning(location_ci <- mfrm_facet_intervals(f,'Criterion'),
    'sampling coverage')
  expect_equal(nrow(location_ci$table),2L)
  expect_true(all(is.finite(as.matrix(location_ci$table[c("Lower","Upper")]))))
  expect_identical(location_ci$table$ScaleReference,rep('sum_to_zero_across_levels',2))
  expect_warning(rater_ci <- mfrm_facet_intervals(f,'Rater'),
    'sampling coverage')
  expect_identical(rater_ci$table$ScaleReference,rep('uncentered_on_fixed_N01',2))
  diagnostics <- mfrm_response_diagnostics(f)
  expect_s3_class(diagnostics,'mfrm_response_diagnostics')
  new <- x$data[x$data$Person %in% levels(x$data$Person)[1:3],]; new$Person<-paste0('new',new$Person)
  native <- predict_mfrm_units(f,new,scoring_quad_points=81L)
  draft <- extract_mfrm_calibration(f,scoring_quad_points=81L,calibration_id='three-facet-roles')
  expect_identical(draft$header$schema_version,7L)
  expect_equal(nrow(review_mfrm_calibration(draft)),0L)
  frozen <- update(object=update(object=draft,status='validated'),status='frozen')
  scored <- score_mfrm_calibration(frozen,new)
  fields <- c('Estimate','SD','Lower','Upper')
  expect_equal(scored$estimates[fields],native$estimates[match(scored$estimates$Person,native$estimates$Person),fields],tolerance=1e-10,ignore_attr=TRUE)
  expect_s3_class(summary(scored),'summary.mfrm_calibration_score')
  expect_s3_class(plot(scored,draw=FALSE),'ggplot')
  saved <- unserialize(serialize(frozen,NULL))
  expect_identical(score_mfrm_calibration(saved,new)$estimates,scored$estimates)
  wrong <- frozen; wrong$model$noncenter_facet <- 'Task'
  expect_gt(nrow(review_mfrm_calibration(wrong)),0L)
  wrong <- frozen; wrong$model$observed_contexts$Criterion[1]<-'unknown'
  expect_gt(nrow(review_mfrm_calibration(wrong)),0L)
  expect_error(score_mfrm_calibration(frozen,rbind(new,new[1,])),'Repeated|repeated|duplicate')
  expect_error(predict_mfrm_units(f,rbind(new,new[1,])),'Repeated')
})

test_that('a saved extended fit produces rater feedback in a fresh installed session', {
  skip_on_cran()
  skip_if_not_installed('callr')
  root <- normalizePath(find.package('mfrmr'))
  skip_if_not(file.exists(file.path(root,'Meta','package.rds')),
    'This regression requires a fresh installed package, not pkgload.')
  fit <- gmfrm_roles_fixture()$fit
  file <- tempfile(fileext='.rds'); on.exit(unlink(file),add=TRUE)
  saveRDS(fit,file)
  worker <- function(root,file) {
    library('mfrmr',lib.loc=dirname(root),character.only=TRUE)
    saved <- readRDS(file)
    mfrmr::mfrm_report(mfrmr::mfrm_results(saved,compute='never'),
      style='rater',facet='Rater',rater='r1')
  }
  environment(worker) <- baseenv()
  sheet <- callr::r(worker,list(root,file),libpath=.libPaths())
  expect_s3_class(sheet,'mfrm_rater_feedback')
  expect_equal(nrow(sheet$tables$steps),0L)
  expect_match(sheet$notes[["severity"]],'not centered')
})
