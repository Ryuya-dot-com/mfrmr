# A literal adjacent-category equation, independent of parameter expansion,
# response kernels, marginal likelihood helpers and Person-score derivatives.
gmfrm_roles_probability <- function(x, problem, data, theta) {
  spec <- problem$specification; levels <- problem$levels
  owners <- spec$slope_facets
  # Original two-facet specifications omit these default roles.
  facets <- spec$facets %||% owners
  noncenter <- spec$noncenter_facet %||% owners[2L]
  reference <- spec$slope_reference %||% owners[1L]
  step_owner <- spec$step_facet %||% owners[2L]
  lookup <- function(f, prefix, centered) {
    lev <- levels[[f]]; free <- if (centered) lev[-length(lev)] else lev
    values <- x[paste0(prefix, ':', f, ':', free)]
    if (centered) values <- c(values, -sum(values))
    unname(values[match(as.character(data[[f]]), lev)])
  }
  location <- Reduce(`+`, lapply(facets, function(f)
    lookup(f, 'location', f != noncenter)))
  slope <- exp(Reduce(`+`, lapply(owners, function(f)
    lookup(f, 'log_slope', f == reference))))
  K <- spec$max_score
  steps <- t(vapply(levels[[step_owner]], function(lev) {
    free <- if (K > 1L) x[paste0('step:', step_owner, ':', lev, ':', seq_len(K-1L))] else numeric()
    c(free, -sum(free))
  }, numeric(K)))
  steps <- steps[match(as.character(data[[step_owner]]),levels[[step_owner]]),,drop=FALSE]
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
  expect_identical(f$summary$PointEstimateStatus, 'finite_numerical_solution')
  expect_equal(f$slopes$PrimaryEstimate, f$slopes$Estimate)
  expect_true(all(!f$slopes$SEEligible & !f$slopes$CIEligible))
  expect_identical(summary(f)$point_estimation$IntegrationReview, 'not_evaluated')
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

test_that('two-family point status distinguishes nonexistence from numerical failure', {
  x <- gmfrm_roles_fixture(); f <- x$fit
  for (score in c(0L, 2L)) {
    d <- x$data; d$Score[d$Rater == 'r1'] <- score
    # A real short fit suffices: the boundary proof does not depend on convergence.
    b <- fit_mfrm(d, spec=x$spec, control=list(mml_engine='em',quad_points=7L,maxit=1L))
    expect_identical(b$summary$PointEstimateStatus, 'finite_maximum_absent')
    expect_identical(b$summary$BoundaryState, 'nonfinite_maximum')
    expect_true(all(is.na(b$slopes$PrimaryEstimate)))
    expect_true(all(b$slopes$BoundaryDirection == 'not_evaluated'))
    boundary <- b$config$gpcm_point_estimation$boundary
    expect_identical(boundary$Level, 'r1')
    expect_identical(boundary$LocationDirection, if (score==0L) '+Inf' else '-Inf')
    expect_equal(boundary$Ratings, sum(d$Rater=='r1'))
    p <- do.call(mfrm_gmfrm_problem,b$gmfrm$specification)
    v <- p$start; moved <- v
    moved['location:Rater:r1'] <- if (score==0L) 2 else -2
    # Independent response equation, not the classification helper.
    for (theta in c(-2,0,2)) {
      before <- gmfrm_roles_probability(v,p,d,rep(theta,nrow(d)))
      after <- gmfrm_roles_probability(moved,p,d,rep(theta,nrow(d)))
      ix <- cbind(which(d$Rater=='r1'),score+1L)
      expect_true(all(after[ix] > before[ix]))
      expect_equal(after[d$Rater!='r1',],before[d$Rater!='r1',],tolerance=0)
    }
    checks <- mfrm_gpcm_product_inference(b)$checks
    expect_identical(tail(checks$Check,1L),'Finite maximum')
    expect_false(tail(checks$Passed,1L))
    report <- mfrm_report(mfrm_results(b,compute='never'))
    expect_null(b$opt$value_basis)
    expect_false(mfrm_gpcm_boundary_guidance(b)$skipped)
    expect_identical(summary(b)$numerical_review$Status[1], b$opt$optimizer_diagnostics$ConvergenceSeverity)
    expect_false(report$first_screen$Status[report$first_screen$Area=='Numerical fit']=='not_run')
    expect_match(report$first_screen$MainIssue[2], 'optimizer values are traces')
    expect_identical(report$tables$point_boundary,boundary)
    expect_match(report$tables$point_estimation$Detail,'no finite maximum')
    # A finite optimizer trace is not a recipient-facing point estimate.
    result <- mfrm_results(b,compute='never')
    for (id in c('r1','r2')) {
      sheet <- mfrm_report(result,style='rater',facet='Rater',rater=id)
      expect_true(is.na(sheet$tables$severity$Location))
      expect_true(is.na(sheet$tables$slope$ComponentSlope))
      expect_identical(sheet$tables$exposure$Basis,'Original ratings')
      expect_equal(sheet$tables$exposure$RatingRows,sum(d$Rater==id))
      expect_match(sheet$review,'no finite maximum')
      expect_identical(sheet$tables$point_status$Status[2],
        if (id=='r1') 'Not identified in this likelihood limit' else 'Not evaluated')
    }
    old <- result; old$fit$point_limit <- NULL
    expect_identical(mfrm_report(old,style='rater',facet='Rater',rater='r1')$tables$point_status$Status[2],
      'Not evaluated')
    evidence <- summary(b)$inference_evidence
    row <- evidence$EvidenceArea == 'facet_location_boundary_screen'
    expect_identical(evidence$State[row],'nonfinite_maximum_certified')
    expect_match(evidence$Interpretation[row],'no finite maximum')
    centered <- fit_mfrm(d, spec=modifyList(x$spec,list(noncenter_facet='Criterion')),
      control=list(mml_engine='em',quad_points=7L,maxit=1L))
    expect_identical(centered$config$gpcm_point_estimation$boundary,boundary)
    expect_identical(centered$summary$PointEstimateStatus,b$summary$PointEstimateStatus)
    p <- do.call(mfrm_gmfrm_problem,centered$gmfrm$specification)
    v <- p$start; moved <- v; direction <- if(score==0L) 1 else -1
    moved['location:Rater:r1'] <- direction
    moved[grepl('^location:Criterion:',names(moved))] <- direction
    before <- gmfrm_roles_probability(v,p,d,rep(0,nrow(d)))
    after <- gmfrm_roles_probability(moved,p,d,rep(0,nrow(d)))
    ix <- cbind(which(d$Rater=='r1'),score+1L)
    expect_true(all(after[ix]>before[ix]))
    expect_equal(after[d$Rater!='r1',],before[d$Rater!='r1',],tolerance=1e-14)
  }
  # An extreme Person is not an extreme uncentered facet level.
  prep <- f$prep; prep$data$Score[prep$data$Person==prep$levels$Person[1]] <- 2L
  expect_equal(nrow(mfrm_gmfrm_point_review(prep,f$config,f$opt)$boundary),0L)
  broken <- f; broken$opt$convergence <- 1L
  held <- mfrm_gmfrm_apply_point_review(broken)
  expect_identical(held$summary$PointEstimateStatus,'numerical_unresolved')
  expect_true(all(is.na(held$slopes$PrimaryEstimate)))
  expect_identical(held$opt,broken$opt)
  expect_equal(held$slopes$OptimizerEstimate,f$slopes$OptimizerEstimate)
  expect_false(held$summary$InferenceReady)
})

test_that('automatic two-family accuracy qualifies local points separately from intervals', {
  skip_on_cran()
  x <- gmfrm_roles_fixture()
  f <- withr::with_options(list(mfrmr.max_information_bytes=1),
    fit_mfrm(x$data,spec=x$spec,control=list(mml_engine='direct',
      mml_integration='auto',quad_points=31L,maxit=600L,reltol=1e-9)))
  expect_identical(f$summary$PointEstimateStatus,'finite_numerical_solution')
  expect_identical(f$config$gpcm_point_estimation$overview$IntegrationReview,'passed')
  expect_identical(f$config$gpcm_point_estimation$overview$LocalMaximumReview,'not_evaluated')
  expect_equal(f$slopes$PrimaryEstimate,f$slopes$Estimate)
  expect_true(all(!f$slopes$SEEligible & !f$slopes$CIEligible))
  expect_false(f$summary$InferenceReady)
  expect_warning(ci <- confint(f,parm='slopes'), 'Experimental two-family intervals')
  expect_true(all(attr(ci,'diagnostics')$CIEligible))
  expect_equal(f$slopes$PrimaryEstimate,f$slopes$Estimate)
  saved <- unserialize(serialize(f,NULL))
  res <- mfrm_results(saved,compute='never',intervals=ci)
  expect_identical(res$tables$gpcm_point_estimation,f$config$gpcm_point_estimation$overview)
  expect_identical(mfrm_report(res)$tables$point_estimation,res$tables$gpcm_point_estimation)
})

test_that('extreme free-owner levels leave independently refitted limiting targets', {
  skip_on_cran()
  x <- gmfrm_roles_fixture()
  extra <- x$data[x$data$Rater=='r1',]; extra$Rater <- 'r3'; extra$Score <- 2L
  d <- rbind(transform(x$data,Rater=as.character(Rater)),extra)
  fits <- lapply(c('Rater','Criterion'),function(noncenter)
    fit_mfrm(d,spec=modifyList(x$spec,list(noncenter_facet=noncenter)),
      control=list(mml_engine='direct',mml_integration=if(noncenter=='Rater') 'adaptive' else 'auto',quad_points=31L,
        maxit=600L,reltol=1e-9)))
  for (f in fits) {
    expect_identical(f$summary$PointEstimateStatus,'finite_maximum_absent')
    expect_false(f$summary$InferenceReady)
    expect_identical(f$point_limit$overview$Status,'partial_points_available')
    expect_equal(summary(f)$point_estimation$AvailableSlopeComponents,4L)
    expect_equal(f$point_limit$overview$RemovedRows,nrow(extra))
    affected <- f$slopes$SlopeOwner=='Rater' & f$slopes$SlopeFacet=='r3'
    expect_identical(f$slopes$ParameterStatus[affected],'unidentified_likelihood_limit')
    expect_true(is.na(f$slopes$PrimaryEstimate[affected]))
    expect_true(all(f$slopes$ParameterStatus[!affected]=='finite_likelihood_limit'))
    reference <- x$fit$slopes
    ix <- mfrm_match_slope_table(f$slopes$SlopeOwner[!affected],f$slopes$SlopeFacet[!affected],reference)
    expect_equal(f$slopes$PrimaryEstimate[!affected],reference$Estimate[ix],tolerance=1e-4)
    expect_true(all(!f$slopes$CIEligible))
    expect_false(mfrm_gpcm_product_inference(f$point_limit$fit)$check$eligible)
    full_steps <- confint(f,parm='steps')
    expect_false(any(full_steps$table$CIEligible))
    expect_true(all(is.na(full_steps$table$Estimate)))
    expect_true(all(full_steps$table$Status=='finite_maximum_absent'))
    limit_steps <- confint(f$point_limit$fit,parm='steps')
    expect_false(any(limit_steps$table$CIEligible))
    expect_true(all(is.na(limit_steps$table$Lower)))
    expect_true(all(is.finite(limit_steps$table$Estimate)))
    result <- mfrm_results(unserialize(serialize(f,NULL)),compute='never')
    expect_identical(result$tables$gpcm_point_targets,f$point_limit$targets)
    report <- mfrm_report(result)
    expect_identical(report$tables$point_limit,f$point_limit$overview)
    expect_equal(result$tables$gpcm_limit_locations$Estimate,unname(f$point_limit$fit$facets$others$Estimate))
    # Saved full-model traces and limiting values have different sources.
    expect_identical(result$tables$gpcm_fitted_slopes$FittedSlope,f$slopes$OptimizerEstimate)
    expect_identical(result$tables$gpcm_fitted_slopes$PrimaryEstimate,f$slopes$PrimaryEstimate)
  }
  expect_equal(fits[[1]]$slopes$PrimaryEstimate,fits[[2]]$slopes$PrimaryEstimate,tolerance=1e-4)
})

test_that('extreme rater-owned steps disappear only from their own limiting likelihood', {
  d <- expand.grid(Person=paste0('p',1:6),Task=paste0('t',1:3),Rater=paste0('r',1:3))
  d$Score <- rep(0:3,length.out=nrow(d))
  for (score in c(0L,3L)) {
    d$Score[d$Rater=='r3'] <- score
    p <- mfrm_gmfrm_problem(d,3L,gauss_hermite_normal(11L),
      facets=c('Task','Rater'),step_facet='Rater',noncenter_facet='Rater',slope_reference='Task')
    reduced <- mfrm_gmfrm_problem(d[d$Rater!='r3',],3L,p$specification$quadrature,
      facets=c('Task','Rater'),step_facet='Rater',noncenter_facet='Rater',slope_reference='Task')
    x <- p$start; x['log_slope:Rater:r3'] <- log(.7)
    for (step in list(c(-.8,.4),c(2,-1))) {
      x[c('step:Rater:r3:1','step:Rater:r3:2')] <- step
      values <- vapply(c(5,20,80),function(t) {
        x['location:Rater:r3'] <- if (score==0L) t else -t
        gmfrm_roles_nll(x,p)
      },0)
      expect_true(all(diff(values)<0))
      expect_equal(tail(values,1),gmfrm_roles_nll(x[names(reduced$start)],reduced),tolerance=1e-10)
    }
  }
})

test_that('default step ownership supports partial points without optimizing the full boundary model', {
  skip_on_cran()
  withr::local_seed(6110301)
  d <- expand.grid(Person=paste0('p',1:120),Task=paste0('t',1:3),Rater=c('r1','r2'))
  theta <- rnorm(120)
  d$Score <- rbinom(nrow(d),3,plogis(theta[as.integer(d$Person)] -
    c(-.4,0,.4)[as.integer(d$Task)]-c(-.25,.25)[as.integer(d$Rater)]))
  d$Rater <- as.character(d$Rater)
  spec <- list(person='Person',score='Score',facets=c('Task','Rater'),model='GPCM',method='MML',
    slope_facet=c('Task','Rater'),rating_max=3L,category_policy='preserve',
    step_facet='Rater',noncenter_facet='Rater',
    gpcm_mml_identification='fixed_standard_normal')
  control <- list(mml_engine='direct',mml_integration='auto',quad_points=21L,maxit=600L,reltol=1e-9)
  reference <- fit_mfrm(d,spec=spec,control=control)
  cases <- data.frame(score=c(3L,0L,3L),noncenter=c('Rater','Task','Rater'),engine=c('direct','direct','em'))
  for (j in seq_len(nrow(cases))) {
    extra <- d[d$Rater=='r1',]; extra$Rater <- 'r3'; extra$Score <- cases$score[j]
    full <- rbind(d,extra)
    ctrl <- if (cases$engine[j]=='em') list(mml_engine='em',mml_integration='auto',
      quad_points=41L,maxit=1000L,em_score_tol=1e-7) else control
    f <- fit_mfrm(full,spec=modifyList(spec,list(noncenter_facet=cases$noncenter[j])),control=ctrl)
    expect_identical(f$opt$value_basis,'neutral_boundary_reference')
    expect_identical(f$config$estimation_control$optimizer_used,'not_run')
    expect_identical(f$readiness$fit$NumericalState,'not_run')
    expect_identical(f$summary$ConvergenceSeverity,'not_run')
    expect_true(is.na(f$summary$TerminalGradientSupNorm))
    expect_true(all(is.finite(f$opt$gradient)))
    expect_false(f$opt$convergence==0L)
    expect_identical(f$point_limit$overview$Status,'partial_points_available')
    expect_equal(f$point_limit$overview[c('RemovedRows','RetainedRows','RetainedPersons')],
      data.frame(RemovedRows=360L,RetainedRows=720L,RetainedPersons=120L))
    affected <- f$slopes$SlopeOwner=='Rater' & f$slopes$SlopeFacet=='r3'
    expect_true(is.na(f$slopes$PrimaryEstimate[affected]))
    expect_identical(f$slopes$ParameterStatus[affected],'unidentified_likelihood_limit')
    ix <- mfrm_match_slope_table(f$slopes$SlopeOwner[!affected],f$slopes$SlopeFacet[!affected],reference$slopes)
    expect_equal(f$slopes$PrimaryEstimate[!affected],reference$slopes$PrimaryEstimate[ix],tolerance=1e-4)
    targets <- f$point_limit$step_targets
    expect_true(all(is.na(targets$PrimaryEstimate[targets$StepFacet=='r3'])))
    expect_true(all(targets$ParameterStatus[targets$StepFacet=='r3']=='unidentified_likelihood_limit'))
    expect_equal(targets$PrimaryEstimate[targets$StepFacet!='r3'],unname(reference$steps$Estimate),tolerance=1e-4)
    expect_false(mfrm_gpcm_product_inference(f$point_limit$fit)$check$eligible)
    saved <- unserialize(serialize(f,NULL))
    before <- serialize(saved,NULL)
    sx <- summary(saved)
    expect_identical(sx$step_targets,targets)
    expect_identical(sx$decision$Interpretation,'Use only the recorded limiting estimates')
    expect_identical(sx$decision$FormalInference,'No')
    expect_identical(sx$numerical_review$Status[1],'not_run')
    expect_identical(tail(sx$numerical_review$Status,1),'partial_points_available')
    expect_false(any(grepl('did not converge|convergence failed',sx$key_warnings)))
    expect_true(any(grepl('mfrm_curve_intervals(fit$point_limit$fit',sx$next_actions,fixed=TRUE)))
    expect_false(any(grepl('mfrm_curve_intervals(fit,',sx$next_actions,fixed=TRUE)))
    expect_false(any(grepl('confint(fit',sx$next_actions,fixed=TRUE)))
    result <- mfrm_results(saved,compute='never')
    expect_identical(result$tables$gpcm_step_targets,targets)
    expect_true(all(result$tables$gpcm_fitted_steps$ValueBasis=='neutral_boundary_reference'))
    report <- mfrm_report(result)
    expect_identical(report$tables$step_targets,targets)
    expect_identical(report$decision,sx$decision)
    expect_identical(report$tables$first_screen,report$first_screen)
    expect_identical(report$tables$numerical_review,sx$numerical_review)
    expect_false(any(grepl('confint(fit',capture.output(print(sx)),fixed=TRUE)))
    expect_true(all(report$tables$fitted_slopes$Interval=='Unavailable: no finite full-model maximum'))
    expect_identical(report$first_screen$Status[report$first_screen$Area=='Numerical fit'],'not_run')
    expect_match(report$tables$model_settings$Value[report$tables$model_settings$Setting=='Numerically converged'],'Not run')
    expect_identical(serialize(saved,NULL),before)
    retained <- mfrm_report(result,style='rater',facet='Rater',rater='r1')
    reduced <- saved$point_limit$fit
    loc <- reduced$facets$others
    expect_equal(retained$tables$severity$Location,
      unname(loc$Estimate[loc$Facet=='Rater' & loc$Level=='r1']))
    expect_equal(retained$tables$slope$ComponentSlope,
      saved$point_limit$targets$PrimaryEstimate[saved$point_limit$targets$Facet=='Rater' &
        saved$point_limit$targets$Level=='r1'])
    expect_equal(retained$tables$steps$Offset,unname(reduced$steps$Estimate[reduced$steps$StepFacet=='r1']))
    expect_true(all(retained$tables$point_status$Status=='Limiting-likelihood estimate'))
    expect_match(retained$notes['severity'],'not centered')
    expect_match(retained$notes['severity'],'limiting analysis')
    extreme <- mfrm_report(result,style='rater',facet='Rater',rater='r3')
    expect_true(all(is.na(c(extreme$tables$severity$Location,
      extreme$tables$slope$ComponentSlope,extreme$tables$steps$Offset))))
    expect_true(all(extreme$tables$point_status$Status[-1]=='Not identified in this likelihood limit'))
    expect_equal(extreme$tables$categories$Ratings,if (cases$score[j]==3L) c(0,0,0,360) else c(360,0,0,0))
    task <- mfrm_report(result,style='rater',facet='Task',rater='t1')
    expect_equal(task$tables$exposure$RatingRows,c(360L,240L))
    expect_equal(task$tables$exposure$Persons,c(120L,120L))
    expect_equal(task$tables$exposure$ObservedCounterpartLevels,c(3L,2L))
    expect_identical(task$tables$exposure$Basis,c('Original ratings','Limiting analysis'))
    expect_equal(sum(task$tables$categories$Ratings),240L)
    expect_identical(serialize(saved,NULL),before)
    if (j==1L) {
      # Saved full-model attachments must not become limiting-fit evidence.
      attached <- result
      attached$gpcm_inference <- list(full=list(unused='full-model interval'))
      attached$response_diagnostics <- list(unused='full-model residuals')
      expect_identical(mfrm_report(attached,style='rater',facet='Rater',rater='r1')$tables,
        retained$tables)
      expect_error(mfrm_report(attached,style='rater',facet='Rater',rater='r1',interval='full'),
        'cannot be transferred')
      mismatch <- result
      mismatch$fit$point_limit$fit$prep$data$Score[1] <- (d$Score[1]+1L) %% 4L
      expect_error(mfrm_report(mismatch,style='rater',facet='Rater',rater='r1'),
        'does not match the retained')
      old <- result; old$fit$point_limit <- NULL
      old_sheet <- mfrm_report(old,style='rater',facet='Rater',rater='r1')
      expect_true(is.na(old_sheet$tables$slope$ComponentSlope))
      expect_identical(old_sheet$tables$point_status$Status[2],'Not evaluated')
      for (id in c('r1','r3')) {
        expected <- if (id=='r1') retained else extreme
        expect_identical(mfrm_report(result,'rater','tables','Rater',id),expected$tables)
        expect_identical(mfrm_report(result,'rater','markdown','Rater',id),expected$markdown)
        html <- mfrm_report(result,'rater','html','Rater',id)
        expect_match(html$html,'Estimate status',fixed=TRUE)
        expect_false(grepl('<h2>NA</h2>',html$html,fixed=TRUE))
        expect_identical(html$report$tables,expected$tables)
        unlink(html$path)
        expect_identical(unserialize(serialize(expected,NULL)),expected)
        expect_output(print(expected),'Estimate|estimate|identified')
      }
      # Reporting-state regression: emulate an older saved record, without
      # changing its boundary proof, actual limiting fit or numerical values.
      old <- saved
      old$opt$optimizer_diagnostics$ConvergenceSeverity <- 'fail'
      old$readiness$fit$NumericalState <- 'failed'
      old$readiness$components$State[old$readiness$components$Component=='numerical'] <- 'failed'
      old$summary$ConvergenceSeverity <- 'fail'
      old$summary$TerminalGradientSupNorm <- max(abs(old$opt$gradient))
      old_before <- serialize(old,NULL)
      expect_identical(summary(old)$decision,sx$decision)
      expect_identical(summary(old)$readiness$Status[2],'not_run')
      expect_true(is.na(summary(old)$overview$TerminalGradientSupNorm))
      expect_identical(mfrm_report(mfrm_results(old,compute='never'))$fit_readiness$NumericalState,'not_run')
      expect_identical(serialize(old,NULL),old_before)
      # These are synthetic reporting states, not new numerical experiments.
      for (state in c('numerical_unresolved','not_evaluated')) {
        unavailable <- saved
        unavailable$point_limit$fit <- NULL
        unavailable$point_limit$overview$Status <- state
        us <- summary(unavailable)
        expect_identical(tail(us$numerical_review$Status,1),state)
        expect_match(us$decision$Interpretation,'limiting estimates unavailable')
        expect_false(any(grepl('mfrm_curve_intervals(',us$next_actions,fixed=TRUE)))
        expect_identical(us$decision$FormalInference,'No')
      }
    }
    context <- data.frame(Task='t1',Rater='r1')
    expect_error(mfrm_curve_intervals(f,transform(context,Theta=0)),'not optimized')
    expect_error(mfrm_report(x = f, newdata = context, type = "category_curves"),'not optimized')
    expect_true(all(is.finite(mfrm_curve_intervals(f$point_limit$fit,
      transform(context,Theta=0))$table$Estimate)))
  }
  binary <- full; binary$Score <- as.integer(binary$Score>1L)
  b <- fit_mfrm(binary,spec=modifyList(spec,list(rating_max=1L)),control=control)
  expect_identical(b$point_limit$overview$Status,'partial_points_available')
  expect_true(all(b$point_limit$step_targets$PrimaryEstimate==0))
  expect_true(all(b$point_limit$step_targets$ParameterStatus=='fixed_by_constraint'))
  sheet <- mfrm_report(mfrm_results(b,compute='never'),style='rater',facet='Rater',rater='r3')
  expect_identical(sheet$tables$steps$Offset,0)
  expect_identical(sheet$tables$point_status$Status[3],'Fixed at zero by constraint')
  expect_true(is.na(sheet$tables$slope$ComponentSlope))
  # A non-extreme rater's missing internal category is not the same boundary.
  bad <- full; bad$Score[bad$Rater=='r1' & bad$Score==1L] <- 0L
  expect_error(fit_mfrm(bad,spec=spec,control=control),'unsupported internal-category')
  expect_error(fit_mfrm(full,spec=spec,control=modifyList(control,
    list(gpcm_mml_start=list(one=0,two=0)))),'native start')
})

test_that('extreme nonslope step levels preserve all slope targets and retained steps', {
  skip_on_cran()
  x <- gmfrm_roles_fixture()
  for (j in 1:3) {
    d <- x$data; d$Criterion <- as.character(d$Criterion)
    attr(d,'out.attrs') <- NULL # expand.grid metadata is not part of rating data.
    extra <- d[d$Criterion=='c1',]; extra$Criterion <- 'r1' # Same label as a retained rater.
    extra$Score <- if (j==2L) 0L else 2L
    full <- rbind(d,extra)
    sp <- modifyList(x$spec,list(rating_max=2L,category_policy='preserve',
      noncenter_facet=if (j==2L) 'Criterion' else 'Rater'))
    control <- if (j==3L) list(mml_engine='em',mml_integration='auto',quad_points=41L,
      maxit=1000L,em_score_tol=1e-7) else list(mml_engine='direct',mml_integration='auto',
        quad_points=21L,maxit=1000L,reltol=1e-9)
    f <- fit_mfrm(full,spec=sp,control=control)
    expect_identical(f$readiness$fit$NumericalState,'not_run')
    expect_identical(f$point_limit$overview$Status,'partial_points_available')
    expect_equal(f$point_limit$overview[c('RemovedRows','RetainedRows','RetainedPersons')],
      data.frame(RemovedRows=640L,RetainedRows=1280L,RetainedPersons=160L))
    expect_identical(f$gmfrm$specification$data,full)
    expect_true(all(f$slopes$ParameterStatus=='finite_likelihood_limit'))
    expect_equal(f$slopes$PrimaryEstimate,x$fit$slopes$Estimate,tolerance=1e-4)
    step <- f$point_limit$step_targets
    expect_true(all(step$ParameterStatus[step$StepFacet=='r1']=='unidentified_likelihood_limit'))
    expect_true(all(is.na(step$PrimaryEstimate[step$StepFacet=='r1'])))
    expect_equal(step$PrimaryEstimate[step$StepFacet!='r1'],unname(x$fit$steps$Estimate),tolerance=1e-4)
    reduced <- f$point_limit$fit
    expect_equal(reduced$facets$others$Estimate,x$fit$facets$others$Estimate,tolerance=1e-4)
    expect_false(mfrm_gpcm_product_inference(reduced)$check$eligible)
    sx <- summary(unserialize(serialize(f,NULL)))
    report <- mfrm_report(mfrm_results(f,compute='never'))
    expect_identical(report$tables$point_targets,sx$point_targets)
    expect_identical(report$tables$step_targets,sx$step_targets)
    context <- data.frame(Task='t1',Rater='r1',Criterion='c1',Theta=0)
    expect_true(all(is.finite(mfrm_curve_intervals(reduced,context)$table$Estimate)))
    expect_error(mfrm_curve_intervals(f,context),'not optimized')
    expect_error(mfrm_curve_intervals(reduced,transform(context,Criterion='r1')),'level|unknown|Unknown')
  }
  # Retain refusal of category gaps outside the removed extreme scope.
  bad <- full; bad$Score[bad$Criterion=='c1' & bad$Score==1L] <- 0L
  expect_error(fit_mfrm(bad,spec=sp,control=control),'unsupported internal-category')
  reference <- modifyList(sp,list(slope_facet=c('Criterion','Rater'),slope_reference='Criterion'))
  expect_error(fit_mfrm(full,spec=reference,control=control),'unsupported internal-category')
  multiple <- full; multiple$Score[multiple$Rater=='r1'] <- 2L
  expect_error(fit_mfrm(multiple,spec=sp,control=control),'unsupported internal-category')
  # A remaining singleton facet is a different identification problem.
  single <- full; single$Score[single$Criterion=='c2'] <- 2L
  f <- fit_mfrm(single,spec=sp,control=control)
  expect_identical(f$point_limit$overview$Status,'not_evaluated')
  expect_match(f$point_limit$overview$Detail,'fewer than two levels')
  expect_true(all(is.na(f$slopes$PrimaryEstimate)))
})

test_that('nonslope reduction preserves retained probabilities and the marginal likelihood limit', {
  for (five in c(FALSE,TRUE)) for (score in c(0L,2L)) for (noncenter in c('Rater','Criterion')) {
    cells <- expand.grid(Task=c('t1','t2'),Rater=c('r1','r2'),Criterion=c('c1','c2'))
    if (five) cells <- merge(cells,expand.grid(Occasion=c('o1','o2'),Venue=c('v1','v2')))
    d <- merge(data.frame(Person=c('p1','p2')),cells); d$Score <- rep(0:2,length.out=nrow(d))
    extra <- d[d$Criterion=='c1',]; extra$Criterion <- 'r1'; extra$Score <- score
    d$Criterion <- as.character(d$Criterion); full <- rbind(d,extra)
    facets <- names(cells)
    build <- function(data,nc) mfrm_gmfrm_problem(data,2L,gauss_hermite_normal(21L),
      facets=facets,step_facet='Criterion',noncenter_facet=nc)
    reduced <- build(d,'Rater'); entire <- build(full,noncenter)
    a <- reduced$start + seq(-.2,.25,length.out=length(reduced$start))
    # Independently embed the reduced coordinates in the full sum-zero bases.
    lift <- function(distance) {
      locations <- lapply(facets,function(facet) {
        lev <- reduced$levels[[facet]]
        v <- a[paste0('location:',facet,':',if (facet=='Rater') lev else head(lev,-1))]
        if (facet!='Rater') v <- c(v,-sum(v))
        setNames(unname(v),lev)
      });names(locations) <- facets
      locations$Criterion <- c(locations$Criterion,r1=if (score==2L) -distance else distance)
      shift <- 0
      for (facet in setdiff(facets,noncenter)) {
        m <- mean(locations[[facet]]); locations[[facet]] <- locations[[facet]]-m;shift <- shift+m
      }
      locations[[noncenter]] <- locations[[noncenter]]+shift
      b <- entire$start; shared <- intersect(names(a),names(b));b[shared] <- a[shared]
      b['step:Criterion:r1:1'] <- .7
      for (facet in facets) {
        keys <- paste0('location:',facet,':',names(locations[[facet]]));keep <- keys %in% names(b)
        b[keys[keep]] <- locations[[facet]][keep]
      }
      b
    }
    target <- gmfrm_roles_probability(a,reduced,d,rep(.4,nrow(d)))
    losses <- numeric()
    for (distance in c(0,10,80)) {
      b <- lift(distance)
      prob <- gmfrm_roles_probability(b,entire,full,rep(.4,nrow(full)))
      expect_equal(prob[seq_len(nrow(d)),],target,tolerance=1e-12)
      losses <- c(losses,gmfrm_roles_nll(b,entire)-gmfrm_roles_nll(a,reduced))
    }
    expect_true(all(diff(losses)<0))
    expect_lt(abs(tail(losses,1)),1e-10)
    expect_true(all(prob[nrow(d)+seq_len(nrow(extra)),score+1L]>1-1e-12))
  }
})

test_that('old two-family point tables remain explicitly unreviewed', {
  f <- readRDS(test_path('fixtures','gmfrm-explicit-start.rds'))$fit
  expect_null(f$config$gpcm_point_estimation)
  before <- f$slopes$PrimaryEstimate
  res <- mfrm_results(f,compute='never')
  expect_identical(res$tables$gpcm_point_estimation$Status,'legacy_not_reviewed')
  expect_identical(f$slopes$PrimaryEstimate,before)
  expect_identical(summary(f)$point_estimation$Status,'legacy_not_reviewed')
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

test_that('two-family step intervals preserve constrained targets and public workflows', {
  skip_on_cran()
  f <- gmfrm_roles_fixture()$fit
  ci <- suppressWarnings(confint(f, parm='steps', level=.90))
  expect_s3_class(ci,'mfrm_facet_intervals')
  expect_identical(ci$settings$target,'category_step_offsets')
  expect_identical(ci$table$StepOwner,rep('Criterion',4))
  expect_identical(ci$table$StepLevel,c('c1','c1','c2','c2'))
  expect_true(all(ci$table$CIEligible)); expect_false(any(ci$table$CoverageQualified))
  # Literal constraints independent of the production step-expansion builder.
  V <- suppressWarnings(vcov(f)); b <- coef(f)
  J <- matrix(0,4,length(b)); i <- which(startsWith(names(b),'steps['))
  J[,i] <- matrix(c(1,-1,0,0,0,0,1,-1),4,2)
  expected <- J%*%V%*%t(J); estimate <- drop(J%*%b)
  se <- sqrt(diag(expected)); margin <- qnorm(.95)*se
  expect_equal(unname(vcov(ci)),unname(expected),tolerance=1e-12)
  expect_equal(ci$table$Estimate,estimate,tolerance=1e-12)
  expect_equal(ci$table$SE,se,tolerance=1e-12)
  expect_equal(unname(confint(ci)),cbind(estimate-margin,estimate+margin),tolerance=1e-12)
  expect_equal(unname(drop(rowsum(ci$table$Estimate,ci$table$StepLevel))),c(0,0),tolerance=1e-12)
  expect_equal(ci$table$CIUse,rep('approximate_pointwise',4))
  expect_error(confint(ci,level=.95),"parm = 'steps'",fixed=TRUE)
  for (extra in list(list(method='profile'),list(method='sandwich'),list(scale='standardized'),
      list(contrasts=diag(4)),list(simultaneous='bonferroni'),list(adjust=TRUE)))
    expect_error(do.call(confint,c(list(object=f,parm='steps'),extra)),'accept only')
  altered <- f; altered$steps$Estimate[1] <- altered$steps$Estimate[1]+.1
  expect_error(confint(altered,parm='steps'),'Saved steps must match')
  altered <- f; altered$config$step_specs <- mfrmr_default_step_specs(f$config)
  altered$config$step_specs[[1]]$target <- 1
  expect_error(confint(altered,parm='steps'),'unanchored sum-zero')
  failed <- f;failed$summary$Converged <- FALSE
  unavailable <- confint(failed,parm='steps')
  expect_true(all(is.na(unavailable$table$Lower)))
  expect_false(any(unavailable$table$CIEligible))
  expect_equal(unavailable$table$Estimate,ci$table$Estimate)
  expect_true(all(grepl('EM must meet',unavailable$table$InferenceReview)))
  limited <- f;limited$config$gpcm_limit_source <- list(test=TRUE)
  refused <- confint(limited,parm='steps')
  expect_false(any(refused$table$CIEligible))
  expect_true(all(grepl('data-dependent boundary',refused$table$InferenceReview)))
  res <- mfrm_results(f,intervals=list(steps=ci),compute='never')
  report <- mfrm_report(res)
  expect_equal(report$tables$gpcm_steps_intervals$SE,ci$table$SE)
  expect_match(report$first_screen$MainIssue[3],'4 experimental step-offset')
  expect_match(report$first_screen$MainIssue[3],'No location intervals')
  expect_match(report$markdown,'Step values are offsets')
  expect_false(grepl('step intervals remain unavailable',report$markdown,fixed=TRUE))
  expect_s3_class(apa_table(ci),'apa_table')
  p <- plot(ci,draw=FALSE)
  expect_match(p$labels$x,'Step offset')
  expect_match(plot_data(p,'subtitle'),'within each owner level')
  expect_null(p$labels$title)
  saved <- unserialize(serialize(list(ci=ci,res=res),NULL))
  expect_identical(saved$ci$table,ci$table)
  expect_identical(mfrm_report(saved$res)$tables,report$tables)
  expect_identical(plot_data(plot(saved$ci,draw=FALSE)),plot_data(p))
  mismatched <- f;mismatched$opt$par[1]<-mismatched$opt$par[1]+.01
  expect_error(mfrm_results(mismatched,intervals=ci),'must match')
  for (change in c('step','limit','convergence')) {
    mismatched <- f
    if(change=='step')mismatched$steps$Estimate[1]<-mismatched$steps$Estimate[1]+.1
    if(change=='limit')mismatched$config$gpcm_limit_source<-list(test=TRUE)
    if(change=='convergence')mismatched$summary$Converged<-FALSE
    expect_error(mfrm_results(mismatched,intervals=ci),'must match')
  }
})

test_that('three-step covariance and binary fixed steps are distinguished', {
  skip_on_cran()
  x <- gmfrm_roles_fixture(); d <- x$data
  # A different supported ladder; no sampling-performance claim for this fixture.
  d$Score[d$Score==2L & seq_len(nrow(d))%%3L==0L] <- 3L
  f <- fit_mfrm(d,spec=modifyList(x$spec,list(rating_max=3L)),
    control=list(mml_engine='direct',mml_integration='auto',quad_points=31L,maxit=2000L))
  ci <- suppressWarnings(confint(f,parm='steps'))
  expect_true(all(ci$table$CIEligible))
  V <- suppressWarnings(vcov(f)); b <- coef(f)
  J <- matrix(0,6,length(b)); cols<-which(startsWith(names(b),'steps['))
  J[1:3,cols[1:2]] <- rbind(diag(2),c(-1,-1))
  J[4:6,cols[3:4]] <- rbind(diag(2),c(-1,-1))
  expected <- J%*%V%*%t(J)
  expect_equal(ci$table$SE,sqrt(diag(expected)),tolerance=1e-12)
  expect_equal(unname(vcov(ci)),unname(expected),tolerance=1e-12)
  expect_equal(expected[3,3],sum(V[cols[1:2],cols[1:2]]),tolerance=1e-12)
  expect_gt(abs(expected[3,3]-sum(diag(V)[cols[1:2]])),1e-6)
  d$Score <- as.integer(d$Score>1)
  binary <- fit_mfrm(d,spec=modifyList(x$spec,list(rating_max=1L)),
    control=list(mml_engine='em',quad_points=11L,maxit=1L))
  fixed <- suppressWarnings(confint(binary,parm='steps'))
  expect_identical(fixed$table$Status,rep('fixed',2))
  expect_equal(fixed$table$Estimate,c(0,0));expect_equal(fixed$table$SE,c(0,0))
  expect_false(any(fixed$table$CIEligible));expect_false(any(fixed$table$SEEligible))
  expect_true(all(is.na(fixed$table$Lower)));expect_true(all(is.na(fixed$table$Upper)))
  expect_true(all(grepl('not empirical precision',fixed$table$InferenceReview)))
  expect_equal(unname(vcov(fixed)),matrix(0,2,2))
})
