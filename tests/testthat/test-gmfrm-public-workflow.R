gmfrm_public_args <- function() {
  d <- expand.grid(Person = paste0("p", 1:12), Task = c("same:1", "t2", "t3"),
    Rater = c("same:1", "r2"))
  d <- d[!(d$Task == "t3" & d$Rater == "r2"), ]
  d$Score <- rep(c(0, 2, 1, 1, 2, 0, 2, 1, 0, 1), length.out = nrow(d))
  names(d) <- c("Candidate", "観点 名", "Judge-ID", "Rating")
  list(data = d, person = "Candidate", facets = c("Judge-ID", "観点 名"),
    score = "Rating", model = "GPCM", method = "MML",
    slope_facet = c("観点 名", "Judge-ID"), step_facet = "Judge-ID",
    noncenter_facet = "Judge-ID", gpcm_mml_identification = "fixed_standard_normal",
    mml_engine = "em", quad_points = 7L, maxit = 1L)
}

test_that("public two-family dispatch preserves its explicit likelihood and replay", {
  args <- gmfrm_public_args()
  fit <- do.call(fit_mfrm, args)
  expect_s3_class(fit, "mfrm_fit")
  expect_identical(fit$config$slope_facet, args$slope_facet)
  expect_identical(fit$summary$MMLEngineRequested, "em")
  expect_identical(fit$summary$MMLEngineUsed, "em")
  expect_identical(fit$summary$ConvergenceBasis, "marginal_score_per_person")
  expect_false(fit$summary$Converged)
  expect_false(fit$summary$InferenceReady)
  expect_false(fit$summary$ICEligible)
  problem <- do.call(mfrm_gmfrm_problem, fit$gmfrm$specification)
  reference <- mfrm_gmfrm_em(problem, maxit = 1L)
  expect_identical(fit$opt$par, reference$par)
  expect_equal(fit$summary$LogLik, reference$logLik)
  expect_identical(summary(fit)$slope_overview$Slopes, c(3L, 2L))
  replay <- fit$config$replay_inputs
  replay$package_version <- NULL
  replay$data <- args$data
  replayed <- do.call(fit_mfrm, replay)
  expect_identical(replayed$opt$par, fit$opt$par)
  expect_identical(replayed$prep$score_map, fit$prep$score_map)
  expect_identical(replayed$summary, fit$summary)
})

test_that("two-family input never silently changes requested model options", {
  args <- gmfrm_public_args()
  bad <- function(name, value) { a <- args; a[name] <- list(value); do.call(fit_mfrm, a) }
  expect_error(bad("mml_engine", "direct"), "Two slope families require")
  expect_error(bad("method", "JML"), "method = 'MML'", fixed = TRUE)
  expect_error(bad("gpcm_mml_identification", "free_population"), "fixed_standard_normal")
  expect_error(bad("step_facet", "観点 名"), "second slope facet")
  expect_error(bad("noncenter_facet", "Person"), "second slope facet")
  expect_error(bad("slope_facet", c("観点 名", "Judge-ID", "Third")), "exactly two")
  for (option in c("anchors", "weight", "population_formula", "reltol", "checkpoint",
                   "attach_diagnostics", "missing_codes", "facet_shrinkage")) {
    value <- switch(option, reltol=1e-7, attach_diagnostics=TRUE,
      facet_shrinkage="laplace", population_formula=~1, "unsupported")
    expect_error(bad(option, value), "not supported by the two-family route")
  }
  expect_error(bad("optimizer", "L-BFGS-B"), "optimizer")
  expect_error(bad("em_score_tol", 0), "finite positive")
  expect_error(bad("rating_min", 1), "rating_min = 0")
  expect_error(bad("rating_min", NA), "rating_min = 0")
  expect_error(bad("rating_min", "zero"), "rating_min = 0")
  expect_error(bad("rating_max", c(1,2)), "positive integer")
  incomplete <- args$data; incomplete$Rating[1] <- NA
  expect_error(bad("data", incomplete), "observed finite numeric scores")
  collapsed <- args$data; collapsed$Rating[collapsed$Rating == 1] <- 2
  expect_error(bad("data", collapsed), "does not collapse score categories")
  preserved <- args; preserved$data <- collapsed
  preserved$category_policy <- "preserve"; preserved$rating_max <- 2
  # Preserve the declared gap and reject its unsupported contrast before fitting.
  expect_error(do.call(fit_mfrm, preserved), class="mfrmr_category_readiness_error")
  duplicate <- rbind(args$data, args$data[1,])
  expect_error(bad("data", duplicate), "Repeated person-facet")
  a <- args; a$slope_facet <- "Judge-ID"; a$em_score_tol <- 1e-6
  expect_error(do.call(fit_mfrm, a), "only to the two-family")
})

test_that("public conditional curves match the product equation and retain unavailable intervals", {
  args <- gmfrm_public_args(); fit <- do.call(fit_mfrm, args)
  grid <- data.frame(Theta = rep(c(-1,0,1), 2))
  grid[[args$slope_facet[1]]] <- rep(c("same:1", "t3"), each=3)
  grid[[args$slope_facet[2]]] <- rep(c("same:1", "r2"), each=3)
  curves <- mfrm_curve_intervals(fit, grid)
  info <- mfrm_curve_intervals(fit, grid, type="information")
  problem <- do.call(mfrm_gmfrm_problem, fit$gmfrm$specification)
  pars <- problem$unpack(fit$opt$par)
  expected <- t(vapply(seq_len(nrow(grid)), function(j) {
    first <- grid[[args$slope_facet[1]]][j]; second <- grid[[args$slope_facet[2]]][j]
    slope <- pars$slopes[[1]][first] * pars$slopes[[2]][second]
    eta <- grid$Theta[j] - pars$locations[[1]][first] - pars$locations[[2]][second]
    z <- c(0, cumsum(slope * (eta - pars$steps[second,])))
    exp(z-max(z))/sum(exp(z-max(z)))
  }, numeric(3)))
  expect_equal(curves$table$Estimate, as.vector(t(expected)), tolerance=1e-12)
  variance <- rowSums(expected * (matrix(0:2,nrow(grid),3,byrow=TRUE) - drop(expected %*% (0:2)))^2)
  slopes <- pars$slopes[[1]][grid[[args$slope_facet[1]]]] * pars$slopes[[2]][grid[[args$slope_facet[2]]]]
  expect_equal(info$table$Estimate, unname(slopes^2 * variance), tolerance=1e-12)
  expect_identical(curves$contexts$ObservedContext, rep(c(TRUE,FALSE),each=3))
  expect_true(all(!curves$table$CIEligible))
  expect_true(all(is.na(curves$table$SE) & is.na(curves$table$Lower) & is.na(curves$table$Upper)))
  expect_true(curves$settings$point_only)
  expect_error(mfrm_curve_intervals(fit,grid,method="sandwich"), "do not yet support")
  expect_error(mfrm_curve_intervals(fit,grid,simultaneous="bonferroni"), "not supported")
  p <- plot(curves, draw=FALSE)
  expect_match(p$labels$subtitle, "intervals are unavailable")
  expect_false(grepl("95|Approximate", p$labels$subtitle))
  expect_null(plot(curves, draw=FALSE, title=NULL,subtitle=NULL,caption=NULL)$labels$title)
  expect_equal(plot_data(p, component="table")$Estimate, curves$table$Estimate)
  res <- mfrm_results(fit, include=c("fit","plots"), compute="never", intervals=list(curves=curves))
  expect_true(res$plot_map$Available[res$plot_map$Type == "gpcm_curves"])
  expect_false(any(res$plot_map$Available[res$plot_map$Type %in% c("wright","fit_pathway")]))
  expect_true(all(res$tables$gpcm_curves_curves$ConfidenceLevel == "Not available"))
  report <- mfrm_report(res)
  expect_s3_class(report, "mfrm_report")
  expect_match(report$markdown, "Calibration intervals are unavailable", fixed=TRUE)
  expect_false(grepl("## GPCM uncertainty", report$markdown, fixed=TRUE))
  expect_false(grepl("required_wright_map_missing|Rebuild.*diagnostics|diagnose_mfrm\\(", report$markdown))
  expect_s3_class(summary(report), "summary.mfrm_report")
  expect_identical(report$tables$slope_estimates, fit$slopes)
  expect_equal(report$tables$fitted_slopes$FittedSlope, fit$slopes$OptimizerEstimate)
  expect_identical(report$tables$model_settings$Value[4:5], fit$config$slope_facet)
  expect_s3_class(plot(res,type="gpcm_curves",draw=FALSE), "ggplot")
  file <- tempfile(fileext=".rds"); withr::defer(unlink(file))
  saveRDS(res,file)
  expect_identical(readRDS(file)$tables, res$tables)
  export_dir <- tempfile("gmfrm-export-"); withr::defer(unlink(export_dir,recursive=TRUE))
  exported <- export_mfrm_results(res, output_dir=export_dir, preset="starter",
    acknowledge_sensitive=TRUE, plot_width=1200, plot_height=900)
  expect_equal(nrow(exported$plot_errors), 0L)
  index <- readLines(file.path(export_dir,"index.html"),warn=FALSE)
  expect_true(any(grepl("Curve intervals",index,fixed=TRUE)))
  expect_false(any(grepl("required Wright|Required scale display",index)))
  expect_true(file.exists(file.path(export_dir,"mfrmr_results_plot_gpcm_curves.png")))
  expect_error(mfrm_results(fit), "Two-family results require")
})

test_that("unsupported two-family consumers give a specific scope error", {
  fit <- do.call(fit_mfrm, gmfrm_public_args())
  for (fun in list(diagnose_mfrm, plot, compute_information,
      predict_mfrm_units, extract_mfrm_calibration, mfrm_facet_intervals,
      plot_wright_unified, plot_threshold_ladder, bootstrap_mfrm_gpcm,
      extract_mfrm_sim_spec, make_anchor_table, apply_empirical_bayes_shrinkage,
      analyze_facet_equivalence, estimate_bias, estimate_all_bias,
      plot_rater_severity_profile, export_mfrm)) {
    expect_error(fun(fit), class="mfrmr_gpcm_scope_error")
  }
  expect_error(mfrm_response_diagnostics(fit), "EM convergence")
  expect_error(compare_mfrm(fit,fit), class="mfrmr_gpcm_scope_error")
  expect_error(plot_compare_mfrm(fit,fit), class="mfrmr_gpcm_scope_error")
  expect_error(plot_rater_trajectory(list(a=fit,b=fit)), class="mfrmr_gpcm_scope_error")
  expect_error(summary(fit,profile="facets"), "only the fit summary")
  expect_error(summary(fit,profile="reporting"), "only the fit summary")
  ci <- confint(fit)
  expect_true(all(is.na(ci)))
  expect_match(attr(ci,"diagnostics")$InferenceReview[1],"per-Person")
})
