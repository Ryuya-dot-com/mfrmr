test_that("invalid numerical controls fail before coercion or fitting", {
  d <- load_mfrmr_data("example_core")
  for (q in list(0, -1, 3.9, NA_real_, c(31, 63))) {
    expect_error(fit_mfrm(d, control = list(quad_points = q)), "quad_points")
    expect_error(mfrm_batch_fit(list(d), quad_points = q), "quad_points")
  }
  for (s in list(-1, 0, Inf, c(1, 2)))
    expect_error(fit_mfrm(d, control = list(slope_prior_sd = s)), "slope_prior_sd")
})

test_that("interval arguments cannot silently change the requested calculation", {
  f <- fit_mfrm(load_mfrmr_data("example_core"), "Person", c("Rater", "Criterion"), "Score", method = "JML")
  for (level in list(-.5, 0, 1, 2, NA_real_, c(.9, .95)))
    expect_error(confint(f, level = level), "level")
  expect_error(confint(f, levle = .8), "Unused")
  expect_error(confint(f, parm = "steps", component = "facets"), "different components")
  expect_equal(confint(f, parm = "steps", component = "steps"), confint(f, component = "steps"))
  expect_error(mfrm_g_study(data.frame(), scores = "Y", score = "Z"), "must agree")
})

test_that("batch and workflow retain automatic covariance audit results", {
  d <- load_mfrmr_data("example_core")
  b <- suppressWarnings(mfrm_batch_fit(list(d), "Person", c("Rater", "Criterion"), "Score", mml_integration = "auto"))
  expect_true(all(c("standard_error", "covariance") %in% names(b[[1]]$quadrature_check$differences)))
  expect_true(b[[1]]$control$quad_points >= 63L)
  expect_true(isTRUE(b[[1]]$quadrature_check$stable))
  compact <- suppressWarnings(mfrm_batch_fit(d, "Person", c("Rater", "Criterion"), "Score",
    score_matrix = matrix(d$Score, ncol = 1), mml_integration = "auto", return_fits = FALSE))
  expect_identical(compact$InferenceReady, isTRUE(b[[1]]$readiness$ready))
  expect_identical(compact$QuadratureStatus, b[[1]]$quadrature_check$status)
  wf <- mfrm_workflow(d, "Person", c("Rater", "Criterion"), "Score")
  wf <- suppressWarnings(step_mfrm_measure(wf, mml_integration = "auto"))
  expect_equal(wf$fit$xi, b[[1]]$xi, tolerance = 1e-7)
  expect_equal(wf$fit$quadrature_check$differences, b[[1]]$quadrature_check$differences, tolerance = 1e-7)
})

test_that("adaptive MML chain-rule gradient, whexact, and penalized logLik obey exact contracts", {
  d <- load_mfrmr_data("example_core")
  f_ad <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
                   model = "GPCM", slope_facet = "Criterion", step_facet = "Criterion",
                   control = list(mml_integration = "adaptive", quad_points = 31L))
  expect_true(f_ad$converged)
  expect_lt(f_ad$max_abs_grad, 1e-8)

  # Penalized MML stores unpenalized marginal logLik separately from penalized objective
  f_lap <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", model = "RSM",
                    control = list(mml_integration = "fixed", quad_points = 21L,
                                   facet_shrinkage = "laplace", facet_prior_sd = 0.5))
  pen <- 0.5 * sum(f_lap$facets$Estimate^2) / (0.5^2)
  expect_equal(f_lap$loglik - (-f_lap$objective), pen, tolerance = 1e-9)

  # whexact = TRUE adds +q/3 Wilson-Hilferty correction; FALSE omits it
  f_wf <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", method = "JML", control = list(whexact = FALSE))
  f_wt <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", method = "JML", control = list(whexact = TRUE))
  expect_true(all(f_wt$facets$InfitZSTD > f_wf$facets$InfitZSTD))
})

test_that("profile confint honors component, reference levels, and 2-family GMFRM slopes", {
  d <- load_mfrmr_data("example_core")
  f_rsm <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", model = "RSM",
                    control = list(mml_integration = "fixed", quad_points = 15L))
  ci_st_w <- confint(f_rsm, component = "steps", se_type = "model")
  ci_st_p <- confint(f_rsm, component = "steps", se_type = "profile")
  expect_identical(dim(ci_st_p), dim(ci_st_w))
  expect_identical(rownames(ci_st_p), rownames(ci_st_w))
  expect_true(all(is.finite(ci_st_p)))
  expect_true(all(ci_st_p[, 1L] < f_rsm$steps$Estimate & f_rsm$steps$Estimate < ci_st_p[, 2L]))

  expect_error(confint(f_rsm, component = "person", se_type = "profile"), "not `'person'`")
  expect_error(confint(f_rsm, component = "population", se_type = "profile"), "not `'population'`")

  f_gp2 <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
                    model = "GPCM", slope_facet = c("Rater", "Criterion"), step_facet = "Common",
                    control = list(mml_integration = "fixed", quad_points = 15L))
  ci_sl2 <- confint(f_gp2, component = "slopes", parm = c("Rater:R04", "Criterion:Organization"), se_type = "profile")
  expect_identical(rownames(ci_sl2), c("Rater:R04", "Criterion:Organization"))
  expect_true(all(is.finite(ci_sl2)))
})

test_that("predict handles single unseen factor covariates and includes population regression SE", {
  d <- load_mfrmr_data("example_core")
  p_lv <- unique(d$Person)
  pdata_f <- data.frame(Person = p_lv, Group = rep(c("Ref", "Foc"), length.out = length(p_lv)), stringsAsFactors = FALSE)
  f_fac <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
                    population_formula = ~ Group, person_data = pdata_f,
                    control = list(mml_integration = "fixed", quad_points = 15L))
  nd1 <- data.frame(Person = "NEW_P1", Rater = d$Rater[1], Criterion = d$Criterion[1], stringsAsFactors = FALSE)
  pd1 <- rbind(pdata_f, data.frame(Person = "NEW_P1", Group = "Foc", stringsAsFactors = FALSE))
  pr1 <- predict(f_fac, newdata = nd1, person_data = pd1, type = "link", se.fit = TRUE)
  expect_true(is.finite(pr1$fit) && is.finite(pr1$se.fit))

  pdata_x <- data.frame(Person = p_lv, X = seq(-1, 1, length.out = length(p_lv)), stringsAsFactors = FALSE)
  f_num <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
                    population_formula = ~ X, person_data = pdata_x,
                    control = list(mml_integration = "fixed", quad_points = 15L))
  pd_x <- rbind(pdata_x, data.frame(Person = "NEW_P1", X = 2.0, stringsAsFactors = FALSE))
  pr_x <- predict(f_num, newdata = nd1, person_data = pd_x, type = "link", se.fit = TRUE)
  lay <- f_num$xi_layout
  g <- numeric(length(f_num$xi))
  g[match(c(paste0("Rater:", d$Rater[1]), paste0("Criterion:", d$Criterion[1])), lay$xi_names)] <- -1
  g[lay$n_xi + 1:2] <- c(1, 2.0)
  exact_se <- sqrt(drop(t(g) %*% f_num$xi_covariance_model %*% g))
  expect_equal(pr_x$se.fit, exact_se, tolerance = 1e-10)
})

test_that("empirical Bayes shrinkage, batch centering_scope, 4-facet D-study, DFF polarity, and agreement contracts hold", {
  d <- load_mfrmr_data("example_core")
  d_sub <- d[d$Person %in% unique(d$Person)[1:12], ]
  f_m0 <- fit_mfrm(d_sub, "Person", c("Rater", "Criterion"), "Score",
                   control = list(mml_integration = "fixed", quad_points = 15L))
  f_eb <- fit_mfrm(d_sub, "Person", c("Rater", "Criterion"), "Score",
                   control = list(mml_integration = "fixed", quad_points = 15L,
                                  facet_shrinkage = "empirical_bayes"))
  r1_rows <- which(f_eb$encoding$retained_data$Rater == f_eb$facets$Level[1])
  expect_equal(f_eb$facets$ExpAvg[1], mean(fitted(f_eb)[r1_rows]), tolerance = 1e-10)
  expect_equal(sum(f_eb$facets$Estimate[f_eb$facets$Facet == "Rater"]), 0.0, tolerance = 1e-10)
  expect_equal(diagnose_mfrm(f_eb)$reliability$ModelReliability,
               diagnose_mfrm(f_m0)$reliability$ModelReliability, tolerance = 1e-10)

  # fit_mfrm and mfrm_batch_fit agree on partial anchors
  anc <- data.frame(Facet = "Rater", Level = unique(d$Rater)[1], Anchor = 0.80)
  f_s <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", anchors = anc,
                  control = list(mml_integration = "fixed", quad_points = 15L))
  f_b <- mfrm_batch_fit(list(d), "Person", c("Rater", "Criterion"), "Score", anchors = anc,
                        mml_integration = "fixed", quad_points = 15L)[[1]]
  expect_equal(f_s$facets$Estimate, f_b$facets$Estimate, tolerance = 1e-8)

  # 4-facet mfrm_d_study(fit) is order-invariant and retains all 4 facets
  set.seed(7)
  d4 <- expand.grid(Person = paste0("P", 1:10), Rater = c("R1", "R2"),
                    Criterion = c("C1", "C2"), Occasion = c("O1", "O2"), Form = c("F1", "F2"),
                    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  d4$Score <- pmin(4L, pmax(1L, round(2.5 + ifelse(d4$Form == "F1", 0.6, -0.6) + rnorm(nrow(d4), 0, 0.7))))
  fit4_a <- fit_mfrm(d4, "Person", c("Rater", "Criterion", "Occasion", "Form"), "Score",
                     control = list(mml_integration = "fixed", quad_points = 11L))
  fit4_b <- fit_mfrm(d4, "Person", c("Form", "Rater", "Criterion", "Occasion"), "Score",
                     control = list(mml_integration = "fixed", quad_points = 11L))
  ds_a <- mfrm_d_study(fit4_a, data.frame(Rater = 1, Criterion = 1, Occasion = 1, Form = 1))
  ds_b <- mfrm_d_study(fit4_b, data.frame(Form = 1, Rater = 1, Criterion = 1, Occasion = 1))
  expect_equal(ds_a$Phi, ds_b$Phi, tolerance = 1e-10)

  # DFF & workflow polarity under positive_facets = "Rater"
  d_dff <- d
  p_lv <- unique(d$Person)
  grp <- setNames(rep(c("Ref", "Foc"), length.out = length(p_lv)), p_lv)
  d_dff$Group <- grp[d_dff$Person]
  hit <- d_dff$Rater == unique(d_dff$Rater)[1] & d_dff$Group == "Foc"
  d_dff$Score[hit] <- pmin(max(d_dff$Score), d_dff$Score[hit] + 1L)
  f_pos <- fit_mfrm(d_dff, "Person", c("Rater", "Criterion"), "Score",
                    spec = list(positive_facets = "Rater"),
                    control = list(mml_integration = "fixed", quad_points = 15L))
  c_mml <- analyze_dff(f_pos, "Rater", "Group", data = d_dff, focal = "Foc", method = "mml_lrt")$table$Contrast[1]
  c_mh  <- analyze_dff(f_pos, "Rater", "Group", data = d_dff, focal = "Foc", method = "mh")$table$Contrast[1]
  c_log <- analyze_dff(f_pos, "Rater", "Group", data = d_dff, focal = "Foc", method = "logistic")$table$Contrast[1]
  expect_identical(sign(c_mh), sign(c_mml))
  expect_identical(sign(c_log), sign(c_mml))

  # interrater_agreement: ICC uses multi-rater units and AdjacentAgreement uses ordered category index
  d_ia <- rbind(
    data.frame(Person = paste0("P", 1:8), Rater = "R1", Task = "T1", Score = rep(c(0, 2, 4, 2), 2)),
    data.frame(Person = paste0("P", 1:8), Rater = "R2", Task = "T1", Score = rep(c(2, 2, 4, 0), 2)),
    data.frame(Person = paste0("P", 9:20), Rater = "R1", Task = "T1", Score = rep(4, 12))
  )
  ia_all  <- interrater_agreement(d_ia, person = "Person", rater = "Rater", score = "Score", context_facets = "Task")
  ia_pair <- interrater_agreement(d_ia[d_ia$Person %in% paste0("P", 1:8), ],
                                  person = "Person", rater = "Rater", score = "Score", context_facets = "Task")
  expect_equal(ia_all$summary$Estimate[ia_all$summary$Metric == "AdjacentAgreement"], 1.0)
  expect_equal(ia_all$summary$Estimate[ia_all$summary$Metric == "ICC_2_1"],
               ia_pair$summary$Estimate[ia_pair$summary$Metric == "ICC_2_1"], tolerance = 1e-12)
})
test_that("conditional finite-MLE screening uses the attainable person totals", {
  d <- expand.grid(Person = paste0("p", 1:10), Rater = c("a", "b"))
  d$Score <- as.integer(d$Rater == "a")
  run <- function(data, ...) fit_mfrm(data, "Person", "Rater", "Score", method = "CML", ...)
  expect_warning(f <- run(d), "No finite structural CML estimate")
  expect_identical(f$boundary_audit$status, "no_finite_conditional_mle")
  expect_equal(f$boundary_audit$support_gap, 0, tolerance = 1e-10)
  expect_false(summary(f)$readiness$ready)
  expect_error(confint(f), "structural_likelihood_boundary")
  old <- f
  old$boundary_audit <- list(status = "not_applicable")
  expect_false(summary(old)$readiness$ready)

  d$Score[c(1, 11)] <- 1L - d$Score[c(1, 11)]
  ordinary <- run(d)
  expect_true(summary(ordinary)$readiness$ready)
  expect_equal(unname(coef(ordinary, "facets")[2] - coef(ordinary, "facets")[1]),
               log(9), tolerance = 1e-7)
  d$W <- rep(c(1, 3), each = 10)
  expect_error(run(d, weight = "W"), "unit observation weights")
  expect_error(mfrm_batch_fit(list(d), "Person", "Rater", "Score", method = "CML",
                              weight = "W"), "unit observation weights")
  expect_error(run(d, control = list(facet_shrinkage = "laplace")), "Laplace facet")

  # Enumerate every attainable pattern for two binary and two three-category
  # ratings with shifted supports, each with the same conditional total.
  patterns <- expand.grid(a = 0:1, b = 0:1, c = 0:2, d = 0:2)
  patterns <- patterns[rowSums(patterns) == 3L, ]
  pcm <- expand.grid(Person = seq_len(nrow(patterns)), Rater = c("a", "b"),
                     Criterion = c("low", "high"))
  pcm$Score <- as.numeric(as.matrix(patterns)) + rep(c(1, 1, 2, 2), each = nrow(patterns))
  support <- data.frame(Level = c("low", "high"), Min = c(1L, 2L), Max = c(2L, 4L))
  mix <- fit_mfrm(pcm, "Person", c("Rater", "Criterion"), "Score", "PCM", "CML",
                  step_facet = "Criterion", category_support = support)
  expect_true(summary(mix)$readiness$ready)
  expect_equal(as.numeric(logLik(mix)), -nrow(patterns) * log(nrow(patterns)), tolerance = 1e-9)
})

test_that("integer bounds, anchors and retained row alignment agree across APIs", {
  d <- load_mfrmr_data("example_core")
  facets <- c("Rater", "Criterion")
  run <- function(data, ...) fit_mfrm(data, "Person", facets, "Score", method = "JML", ...)
  expect_error(run(d, rating_min = 0.5, rating_max = 4.5), "integer rubric score")
  expect_error(mfrm_batch_fit(d, "Person", facets, "Score", score_matrix = cbind(d$Score),
                             rating_min = 0.5, rating_max = 4.5), "integer rubric score")
  anchors <- data.frame(Facet = "Rater", Level = c("R01", "Other panel"), Anchor = c(0.3, -0.1))
  f <- run(d, anchors = anchors)
  expect_equal(summary(f)$anchor_application$individual$Status, c("applied", "not_observed"))
  expect_equal(unname(coef(f, "facets")["Rater:R01"]), 0.3)
  expect_error(run(d, anchors = transform(anchors, Facet = "Raters")), "model facet")
  expect_error(run(d, anchors = rbind(anchors, transform(anchors[1L, ], Anchor = 1))),
               "Conflicting duplicate")
  expect_error(run(d, group_anchors = transform(anchors, Group = "anchored", GroupValue = 0.1)),
               "Partially observed")

  d$W <- 1
  d$W[c(2, 11)] <- 0
  f <- run(d, weight = "W")
  expect_identical(f$encoding$retained_rows, which(d$W > 0))
  wf <- mfrm_workflow(d, "Person", facets, "Score", fit = f)
  obs <- step_mfrm_diagnose(wf)$diagnostics$observations
  expect_identical(obs$.row_id, which(d$W > 0))
  expect_equal(obs$Expected, as.numeric(fitted(f)))
  expect_match(render_mfrm_report(wf), "2 input rows were omitted", fixed = TRUE)
})

test_that("G-Study labels and comparison keys remain opaque", {
  d <- load_mfrmr_data("example_core")
  names(d)[names(d) == "Rater"] <- "Rater:Panel"
  facets <- c("Rater:Panel", "Criterion")
  grid <- setNames(data.frame(r = 2L, c = 3L), facets)
  gt <- mfrm_g_study(d, "Score", "Person", facets = facets, method = "urgenova", d_study_grid = grid)
  metrics <- c("G", "Phi", "RelSEM", "AbsSEM")
  expect_equal(mfrm_d_study(gt)[metrics], summary(gt)$d_study[metrics])

  names(d)[names(d) == "Rater:Panel"] <- "Weight"
  f <- fit_mfrm(d, "Person", c("Weight", "Criterion"), "Score", method = "CML")
  g <- f
  g$encoding$facet_mat0[1L, 1L] <- (g$encoding$facet_mat0[1L, 1L] + 1L) %% length(unique(d$Weight))
  expect_false(mfrmr:::.mfrm_same_observations(f, g))
  expect_warning(result <- anova(f, g), "identical observations")
  expect_identical(result$comparison_basis$lrt_status, "ineligible")
})

test_that("agreement uses Gwet's unit weights and a fitted rubric's categories", {
  ratings <- data.frame(Person = c("A", "A", "B", "B", "B"),
    Rater = c("a", "b", "a", "b", "c"), Score = c(0, 0, 0, 1, 1))
  expect_equal(interrater_agreement(ratings, metric = "gwet_ac2")$summary$Estimate, 0.4)
  ratings <- rbind(ratings, data.frame(Person = "C", Rater = "a", Score = 1))
  expected <- 2 * (4 / 9) * (5 / 9)
  expect_equal(interrater_agreement(ratings, metric = "gwet_ac2")$summary$Estimate,
               (2 / 3 - expected) / (1 - expected))
  d <- expand.grid(Person = paste0("p", 1:8), Rater = c("r1", "r2"))
  d$Score <- rep(c(1L, 3L), each = 8L)
  d$Score[c(1:4, 9:12)] <- 4L - d$Score[c(1:4, 9:12)]
  f <- suppressWarnings(fit_mfrm(d, "Person", "Rater", "Score",
                                rating_min = 1L, rating_max = 3L))
  result <- interrater_agreement(f, metric = "exact")
  expect_equal(result$summary$Estimate, c(0, 0))
})

test_that("new predictions replay training transforms and keep matched rows", {
  d <- load_mfrmr_data("example_core")
  id <- unique(d$Person)
  pd <- data.frame(Person = id, X = seq_along(id))
  f <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
                population_formula = ~ scale(X), person_data = pd,
                control = list(mml_integration = "fixed", quad_points = 15L))
  nd <- data.frame(Person = c("new", "missing"), Rater = d$Rater[1L], Criterion = d$Criterion[1L])
  new <- data.frame(Person = "new", X = max(pd$X) + 1)
  once <- predict(f, nd[1L, ], person_data = new, se.fit = TRUE, type = "link")
  expect_true(all(is.finite(unlist(once))))
  expect_warning(both <- predict(f, nd, person_data = new, se.fit = TRUE, type = "link"),
                 "No population covariates")
  centered <- (new$X - mean(pd$X)) / sd(pd$X)
  names <- paste0(c("Rater:", "Criterion:"), c(as.character(nd$Rater[1]), as.character(nd$Criterion[1])))
  expected <- sum(f$population$coefficients * c(1, centered)) - sum(coef(f, "facets")[names])
  expect_equal(once$fit, expected)
  expect_equal(both$fit, c(once$fit, NA_real_))
  expect_equal(both$se.fit, c(once$se.fit, NA_real_))
  expect_identical(predict(unserialize(serialize(f, NULL)), nd[1L, ], person_data = new,
                           se.fit = TRUE, type = "link"), once)
})

test_that("automatic batch refinement retains shrinkage and its error basis", {
  d <- load_mfrmr_data("example_core")
  facets <- c("Rater", "Criterion")
  fit_unshrunk <- fit_mfrm(d, "Person", facets, "Score")
  fit <- fit_mfrm(d, "Person", facets, "Score",
                  control = list(facet_shrinkage = "empirical_bayes", facet_prior_sd = 0.5))
  batches <- mfrm_batch_fit(d, "Person", facets, "Score", score_matrix = cbind(d$Score, d$Score),
                          threads = 2L, facet_shrinkage = "empirical_bayes", facet_prior_sd = 0.5)
  batch <- batches[[1L]]
  expect_equal(coef(batches[[2L]]), coef(batch), tolerance = 1e-12)
  expect_identical(batch$shrinkage, "empirical_bayes")
  expect_equal(coef(batch), coef(fit), tolerance = 1e-9)
  expect_equal(coef(fit, type = "free"), coef(fit_unshrunk, type = "free"), tolerance = 1e-10)
  expect_equal(vcov(fit), vcov(fit_unshrunk), tolerance = 1e-10)
  expect_equal(confint(fit, component = "free"), confint(fit_unshrunk, component = "free"), tolerance = 1e-10)
  expect_equal(confint(fit, component = "free", se_type = "sandwich"),
               confint(fit_unshrunk, component = "free", se_type = "sandwich"), tolerance = 1e-10)
  expect_equal(confint(batch, component = "free"), confint(fit_unshrunk, component = "free"), tolerance = 1e-8)
  expect_equal(confint(fit, component = "free", parm = 1:2, se_type = "profile"),
               confint(fit_unshrunk, component = "free", parm = 1:2, se_type = "profile"), tolerance = 1e-7)
  expect_true(all(is.na(confint(batch, "facets"))))
  expect_true(all(is.na(confint(fit, "facets", se_type = "profile"))))
  expect_true(all(is.na(predict(batch, se.fit = TRUE)$se.fit)))
  expect_true(all(is.na(batch$facets$SandwichSE)))
  expect_true(all(is.finite(batch$facets$MLESandwichSE)))
  expect_true(all(is.na(plot(batch, type = "raters")$data$Low)))
  wf_eb <- step_mfrm_diagnose(mfrm_workflow(d, "Person", facets, "Score", fit = batch))
  expect_true(all(is.na(plot(wf_eb, type = "raters", draw = FALSE)$data$RealLow)))
  expect_true(all(is.na(detect_anchor_drift(list(A = batch, B = batch))$table$Flagged)))
  adaptive <- mfrmr:::.mfrm_run_quad_sequence(fit, adaptive = TRUE, limit = 63, initial = 15)
  expect_equal(adaptive$quadrature_check$initial_order, 15)
  expect_lte(adaptive$quadrature_check$selected_order, 63)
})

test_that("split DFF isolates synthetic levels, compares matched MML orders, and rejects nonunit CML weights", {
  d <- load_mfrmr_data("example_core")
  d$Group <- c("reference", "focal")[1L + match(d$Person, unique(d$Person)) %% 2L]
  dw <- d
  dw$W <- ifelse(seq_len(nrow(dw)) <= 59L, 7, 1)
  fit_w <- fit_mfrm(dw, "Person", c("Rater", "Criterion"), "Score", weight = "W",
                    control = list(quad_points = 15L, mml_integration = "fixed"))
  expect_error(analyze_dff(fit_w, "Rater", "Group", method = "cml_lrt"),
               "unit observation weights")
  dw_unit <- d
  dw_unit$W <- 1
  fit_u1 <- fit_mfrm(dw_unit, "Person", c("Rater", "Criterion"), "Score", weight = "W", method = "JML")
  fit_u0 <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", method = "JML")
  expect_equal(analyze_dff(fit_u1, "Rater", "Group", method = "cml_lrt")$table$Contrast,
               analyze_dff(fit_u0, "Rater", "Group", method = "cml_lrt")$table$Contrast,
               tolerance = 1e-10)

  run <- function(data) {
    fit <- fit_mfrm(data, "Person", c("Rater", "Criterion"), "Score",
                    control = list(quad_points = 31L, mml_integration = "fixed"))
    analyze_dff(fit, "Rater", "Group", method = "mml_lrt", threads = 2L)
  }
  baseline <- run(d)
  d$Rater <- as.character(d$Rater)
  d$Rater[d$Rater == "R02"] <- "R01__REF__"
  renamed <- run(d)
  expect_identical(renamed$quadrature_orders, c(31L, 63L))
  expect_equal(renamed$table$Contrast[renamed$table$Level == "R01"],
               baseline$table$Contrast[baseline$table$Level == "R01"], tolerance = 1e-7)
  expect_equal(renamed$table$pValue[renamed$table$Level == "R01"],
               baseline$table$pValue[baseline$table$Level == "R01"], tolerance = 1e-7)

  fit_auto <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score")
  dff_auto <- analyze_dff(fit_auto, "Rater", "Group", method = "mml_lrt", threads = 2L)
  expect_identical(dff_auto$quadrature_orders, fit_auto$quadrature_check$orders)
})

test_that("reports preserve literal labels across HTML and Markdown", {
  d <- load_mfrmr_data("example_core")
  f0 <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", method = "JML")
  wf0 <- step_mfrm_diagnose(mfrm_workflow(d, "Person", c("Rater", "Criterion"), "Score", fit = f0))
  expect_no_warning(plot(wf0, type = "raters", draw = FALSE))
  expect_false(grepl("&amp;", render_mfrm_report(wf0, format = "markdown"), fixed = TRUE))

  d_sym <- d
  d_sym$Rater <- as.character(d_sym$Rater)
  d_sym$Rater[d_sym$Rater == "R01"] <- "Panel **West** `A`"
  f_sym <- fit_mfrm(d_sym, "Person", c("Rater", "Criterion"), "Score", method = "JML")
  wf_sym <- step_mfrm_diagnose(mfrm_workflow(d_sym, "Person", c("Rater", "Criterion"), "Score", fit = f_sym))
  md_sym <- render_mfrm_report(wf_sym, format = "markdown")
  html_sym <- render_mfrm_report(wf_sym, format = "html")
  expect_match(md_sym, "### Rater `` Panel **West** `A` ``", fixed = TRUE)
  expect_match(html_sym, "<h3>Rater <code>Panel **West** `A`</code>", fixed = TRUE)
  expect_false(grepl("<strong>West</strong>", html_sym, fixed = TRUE))

  d$Rater <- as.character(d$Rater)
  d$Rater[d$Rater == "R01"] <- "<Panel & A>"
  f <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", method = "JML")
  wf <- step_mfrm_diagnose(mfrm_workflow(d, "Person", c("Rater", "Criterion"), "Score", fit = f))
  md <- render_mfrm_report(wf, rater = "<Panel & A>", format = "markdown")
  md_full <- render_mfrm_report(wf, format = "markdown")
  html <- render_mfrm_report(wf, rater = "<Panel & A>", format = "html")
  expect_match(md, "&lt;Panel &amp; A>", fixed = TRUE)
  expect_match(md_full, "### Rater `<Panel & A>`", fixed = TRUE)
  expect_match(html, "&lt;Panel &amp; A&gt;", fixed = TRUE)
  expect_match(format_mfrm_table(f, component = "facets"), "&lt;Panel &amp; A>", fixed = TRUE)

  old <- unserialize(serialize(wf, NULL))
  old$diagnostics$report_statistics$agreement_basis <- NULL
  old$diagnostics$report_statistics$agreement$summary$Estimate[] <- 999
  old$diagnostics$split_dff_audited <- NULL
  old$diagnostics$dff <- data.frame(Method = "MML_LRT", Contrast = 0.1,
    SE = 0.2, pValue = 0.02, pAdj = 0.04, Flagged = TRUE)
  expect_false(grepl("999.000", render_mfrm_report(old), fixed = TRUE))
  replay <- mfrmr:::.tidymfrm_refresh(old)$diagnostics$dff
  expect_equal(replay$Contrast, 0.1)
  expect_true(all(is.na(replay[c("SE", "pValue", "pAdj", "Flagged")])))
  expect_equal(replay$InferenceReason, "saved_split_refits_need_review")
})

test_that("factor weights, linked positive_facets, anchor readiness, and person-anchor guards hold", {
  d <- load_mfrmr_data("example_core")
  facets <- c("Rater", "Criterion")

  # 1. Factor / character weights are rejected everywhere instead of using level indices
  d_fw <- d
  d_fw$W <- factor(ifelse(seq_len(nrow(d)) <= 59L, "9", "1"))
  expect_error(fit_mfrm(d_fw, "Person", facets, "Score", weight = "W", method = "JML"),
               "plain numeric observation weights")
  expect_error(mfrm_batch_fit(list(d_fw), "Person", facets, "Score", weight = "W", method = "JML"),
               "plain numeric observation weights")
  d_fw2 <- d
  d_fw2$W <- factor(rep("2", nrow(d)))
  expect_error(fit_mfrm(d_fw2, "Person", facets, "Score", weight = "W", method = "CML"),
               "plain numeric observation weights")

  # 2. anchor_to_baseline inherits positive_facets from baseline_fit and rejects conflicts
  base_pos <- fit_mfrm(d, "Person", facets, "Score", method = "JML", positive_facets = "Rater")
  linked_auto <- anchor_to_baseline(d, base_pos, "Person", facets, "Score")
  linked_expl <- anchor_to_baseline(d, base_pos, "Person", facets, "Score", positive_facets = "Rater")
  expect_equal(as.numeric(fitted(linked_auto$fit)), as.numeric(fitted(base_pos)), tolerance = 1e-12)
  expect_equal(as.numeric(fitted(linked_expl$fit)), as.numeric(fitted(base_pos)), tolerance = 1e-12)
  expect_error(anchor_to_baseline(d, base_pos, "Person", facets, "Score", positive_facets = character(0)),
               "conflicts with the facet orientation")
  expect_error(anchor_to_baseline(d, base_pos, "Person", facets, "Score", positive_facets = "Criterion"),
               "conflicts with the facet orientation")

  # 7. make_anchor_table checks readiness by default; anchor_to_baseline rejects include_person = TRUE
  d_bnd <- data.frame(Person = rep(paste0("P", 1:8), 2L),
                      Rater = rep(c("R1", "R2"), each = 8L),
                      Score = rep(c(0L, 1L), each = 8L))
  f_bnd <- suppressWarnings(fit_mfrm(d_bnd, "Person", "Rater", "Score", method = "CML"))
  expect_error(make_anchor_table(f_bnd), "not inference-ready")
  expect_equal(nrow(make_anchor_table(f_bnd, readiness_policy = "review")), 2L)
  expect_error(anchor_to_baseline(d, base_pos, "Person", facets, "Score", include_person = TRUE),
               "include_person = TRUE")
})

test_that("multi-level nested G-Study, Henderson input validation, agreement unit, and IC comparability hold", {
  # 3. Multi-level nesting Rater : Task : Site is invariant to local vs site-prefixed Task IDs
  set.seed(103)
  grid_rts <- do.call(rbind, lapply(paste0("S", 1:3), function(s) {
    do.call(rbind, lapply(c("T1", "T2"), function(tk) {
      n_r <- if (tk == "T1") 1L else 2L
      data.frame(Site = s, TaskLocal = tk, TaskGlobal = paste(s, tk, sep = "_"),
                 Rater = paste(s, tk, seq_len(n_r), sep = "_"), stringsAsFactors = FALSE)
    }))
  }))
  d_nest <- do.call(rbind, lapply(paste0("P", 1:16), function(p) {
    out <- grid_rts
    out$Person <- p
    out
  }))
  p_eff <- stats::setNames(seq(-1.2, 1.2, length.out = 16L), paste0("P", 1:16))
  r_eff <- stats::setNames(rnorm(nrow(grid_rts), 0, 0.4), grid_rts$Rater)
  d_nest$Score <- round(pmin(5, pmax(1, 3 + p_eff[d_nest$Person] - r_eff[d_nest$Rater] + rnorm(nrow(d_nest), 0, 0.5))))
  gt_loc <- mfrm_g_study(d_nest, "Score", "Person", facets = c("Rater", "TaskLocal", "Site"),
                         nesting = c(Rater = "TaskLocal", TaskLocal = "Site"), method = "urgenova")
  gt_glb <- mfrm_g_study(d_nest, "Score", "Person", facets = c("Rater", "TaskGlobal", "Site"),
                         nesting = c(Rater = "TaskGlobal", TaskGlobal = "Site"), method = "urgenova")
  expect_equal(gt_loc$variance_components$Estimate, gt_glb$variance_components$Estimate, tolerance = 1e-12)
  expect_equal(unname(unlist(gt_loc$g_study_summary[c("Harmonic_Rater", "G", "Phi")])),
               unname(unlist(gt_glb$g_study_summary[c("Harmonic_Rater", "G", "Phi")])), tolerance = 1e-12)
  expect_lt(gt_loc$g_study_summary$Harmonic_Rater, 1.5)

  # 8. Henderson G-Study rejects Inf scores and cyclic nesting
  d_core <- load_mfrmr_data("example_core")
  d_inf <- d_core
  d_inf$Score[1L] <- Inf
  expect_error(mfrm_g_study(d_inf, "Score", "Person", facets = c("Rater", "Criterion"),
                            method = "urgenova", missing = "error"), "finite numeric")
  expect_error(mfrm_g_study(d_inf, "Score", "Person", facets = c("Rater", "Criterion"),
                            method = "urgenova", missing = "omit"), "finite numeric")
  expect_error(mfrm_g_study(d_core, "Score", "Person", facets = c("Rater", "Criterion"),
                            nesting = c(Rater = "Criterion", Criterion = "Rater"), method = "urgenova"),
               "cycle")

  # 4. interrater_agreement honors explicit unit on fitted mfrm_fit
  d_u <- d_core
  d_u$Unit <- paste(d_u$Person, d_u$Criterion, rep(1:2, length.out = nrow(d_u)), sep = ":")
  # Pair raters within 384 synthetic two-rater units
  d_u <- d_core[order(d_core$Person, d_core$Criterion, d_core$Rater), ]
  d_u$Unit <- rep(paste0("U", seq_len(nrow(d_u) / 2L)), each = 2L)
  f_u <- fit_mfrm(d_u, "Person", c("Rater", "Criterion"), "Score", method = "JML")
  ag_raw <- interrater_agreement(d_u, unit = "Unit")
  ag_fit <- interrater_agreement(f_u, unit = "Unit")
  expect_identical(ag_fit$summary$Units, ag_raw$summary$Units)
  expect_equal(ag_fit$summary$Estimate, ag_raw$summary$Estimate, tolerance = 1e-12)

  # 5. compare_mfrm withholds DeltaAIC/DeltaBIC and warns on incomparable likelihoods
  f_cml <- fit_mfrm(d_core, "Person", c("Rater", "Criterion"), "Score", method = "CML")
  f_mml <- fit_mfrm(d_core, "Person", c("Rater", "Criterion"), "Score", method = "MML",
                    control = list(quad_points = 15L, mml_integration = "fixed"))
  f_mml_sub <- fit_mfrm(d_core[-seq_len(10L), ], "Person", c("Rater", "Criterion"), "Score", method = "MML",
                        control = list(quad_points = 15L, mml_integration = "fixed"))
  f_pcm <- fit_mfrm(d_core, "Person", c("Rater", "Criterion"), "Score", model = "PCM", step_facet = "Criterion",
                    method = "MML", control = list(quad_points = 15L, mml_integration = "fixed"))
  expect_warning(cmp_cm <- compare_mfrm(f_cml, f_mml), "DeltaAIC/DeltaBIC")
  expect_true(all(is.finite(cmp_cm$table$AIC)) && all(is.na(cmp_cm$table$DeltaAIC)) && all(is.na(cmp_cm$table$DeltaBIC)))
  expect_warning(cmp_sub <- compare_mfrm(f_mml, f_mml_sub), "DeltaAIC/DeltaBIC")
  expect_true(all(is.na(cmp_sub$table$DeltaAIC)))
  expect_no_warning(cmp_ok <- compare_mfrm(f_mml, f_pcm))
  expect_true(all(is.finite(cmp_ok$table$DeltaAIC)))
})

test_that("interaction profile CIs, column-name isolation, fast CML audit, and scalar validations hold", {
  d <- load_mfrmr_data("example_core")

  # 6. Interaction profile CIs index by level positions even when levels contain ':'
  d_int <- d
  d_int$Rater <- c(R01 = "A", R02 = "A:B", R03 = "C", R04 = "D")[as.character(d$Rater)]
  d_int$Criterion <- c(Content = "B:C", Organization = "C", Language = "E", Delivery = "F")[as.character(d$Criterion)]
  d_pln <- d
  d_pln$Rater <- c(R01 = "L1", R02 = "L2", R03 = "L3", R04 = "L4")[as.character(d$Rater)]
  d_pln$Criterion <- c(Content = "M1", Organization = "M2", Language = "M3", Delivery = "M4")[as.character(d$Criterion)]
  f_col <- fit_mfrm(d_int, "Person", c("Rater", "Criterion"), "Score", method = "MML",
                    facet_interactions = list(c("Rater", "Criterion")),
                    control = list(quad_points = 15L, mml_integration = "fixed"))
  f_pln <- fit_mfrm(d_pln, "Person", c("Rater", "Criterion"), "Score", method = "MML",
                    facet_interactions = list(c("Rater", "Criterion")),
                    control = list(quad_points = 15L, mml_integration = "fixed"))
  idx_col <- c(which(f_col$interactions$LevelA == "A" & f_col$interactions$LevelB == "B:C"),
               which(f_col$interactions$LevelA == "A:B" & f_col$interactions$LevelB == "C"))
  idx_pln <- c(which(f_pln$interactions$LevelA == "L1" & f_pln$interactions$LevelB == "M1"),
               which(f_pln$interactions$LevelA == "L2" & f_pln$interactions$LevelB == "M2"))
  ci_col <- confint(f_col, component = "interactions", parm = idx_col, se_type = "profile")
  ci_pln <- confint(f_pln, component = "interactions", parm = idx_pln, se_type = "profile")
  expect_equal(unname(ci_col), unname(ci_pln), tolerance = 1e-7)
  expect_error(confint(f_col, component = "interactions", parm = "Rater:Criterion:A:B:C", se_type = "profile"),
               "Ambiguous parameter name")

  # 9. Input column names Expected, .mfrm_dff_row, and theta do not collide with internal columns
  d_exp <- d
  names(d_exp)[names(d_exp) == "Rater"] <- "Expected"
  f_exp <- fit_mfrm(d_exp, "Person", c("Expected", "Criterion"), "Score", method = "JML")
  dg_exp <- diagnose_mfrm(f_exp)
  expect_true(all(dg_exp$unexpected$Expected %in% unique(d$Rater)))
  wf_exp <- step_mfrm_diagnose(mfrm_workflow(d_exp, "Person", c("Expected", "Criterion"), "Score", fit = f_exp))
  expect_true(all(augment(wf_exp)$Expected %in% unique(d$Rater)))
  expect_match(render_mfrm_report(wf_exp, rater = "R01", format = "html"), "R01", fixed = TRUE)

  d_dff <- d
  d_dff$Group <- c("Ref", "Foc")[1L + match(d$Person, unique(d$Person)) %% 2L]
  d_dff2 <- d_dff
  names(d_dff2)[names(d_dff2) == "Group"] <- ".mfrm_dff_row"
  f_j <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", method = "JML")
  expect_equal(analyze_dff(f_j, "Rater", ".mfrm_dff_row", data = d_dff2, method = "raju_welch")$table$Contrast,
               analyze_dff(f_j, "Rater", "Group", data = d_dff, method = "raju_welch")$table$Contrast,
               tolerance = 1e-12)

  d_th <- d
  names(d_th)[names(d_th) == "Criterion"] <- "theta"
  f_th <- fit_mfrm(d_th, "Person", c("Rater", "theta"), "Score", method = "JML")
  plan_c <- expand.grid(Rater = unique(d$Rater), Criterion = unique(d$Criterion), stringsAsFactors = FALSE)
  plan_t <- expand.grid(Rater = unique(d$Rater), theta = unique(d$Criterion), stringsAsFactors = FALSE)
  expect_equal(fair_average_table(f_th, reference_plan = plan_t, fair_se = TRUE)$reference_scores$Estimate,
               fair_average_table(f_j, reference_plan = plan_c, fair_se = TRUE)$reference_scores$Estimate,
               tolerance = 1e-12)

  # 10. Fast CML boundary check across heterogeneous person rosters and shared-design batch
  set.seed(110)
  d_sp <- do.call(rbind, lapply(seq_len(40L), function(p) {
    cells <- expand.grid(Rater = paste0("R", 1:6), Criterion = paste0("C", 1:4), stringsAsFactors = FALSE)
    sub <- cells[sample(nrow(cells), 8L), ]
    sub$Person <- sprintf("P%03d", p)
    sub$Score <- sample(1:4, 8L, replace = TRUE)
    sub
  }))
  f_sp <- fit_mfrm(d_sp, "Person", c("Rater", "Criterion"), "Score", method = "CML")
  b_sp <- mfrm_batch_fit(d_sp, "Person", c("Rater", "Criterion"), "Score",
                         score_matrix = cbind(d_sp$Score, d_sp$Score), method = "CML", threads = 2L)
  expect_true(summary(f_sp)$readiness$ready)
  expect_equal(coef(b_sp[[1L]]), coef(f_sp), tolerance = 1e-10)
  expect_identical(summary(b_sp[[1L]])$readiness$ready, summary(f_sp)$readiness$ready)

  # 11. Scalar / workflow validations: bootstrap = 2.8, uscale = -2, and dropped weight column
  wf0 <- mfrm_workflow(d, "Person", c("Rater", "Criterion"), "Score")
  expect_error(step_mfrm_measure(wf0, method = "JML", bootstrap = 2.8), "bootstrap")
  expect_error(fair_average_table(f_j, uscale = -2), "uscale")
  expect_error(fair_average_table(f_j, uscale = 0), "uscale")
  d_w <- d
  d_w$W <- ifelse(seq_len(nrow(d)) <= 20L, 2, 1)
  f_w <- fit_mfrm(d_w, "Person", c("Rater", "Criterion"), "Score", weight = "W", method = "JML")
  expect_error(mfrm_workflow(d, "Person", c("Rater", "Criterion"), "Score", fit = f_w),
               "rating columns")
})

test_that("classification_table, WLE weights, predict ability checks, and facet/constraint validations hold", {
  utils::data("mfrmr_example_core", package = "mfrmr")
  d <- mfrmr_example_core

  # A1: classification_table() honors per-level category_support in RSM and keeps 0-based ExpectedSum
  cs_mix <- data.frame(
    Level = c("Content", "Organization", "Language", "Accuracy"),
    Min = c(1, 2, 1, 2),
    Max = c(2, 4, 4, 4),
    stringsAsFactors = FALSE
  )
  d_cs <- d
  is_c1 <- d_cs$Criterion == "Content"
  is_c2 <- d_cs$Criterion %in% c("Organization", "Accuracy")
  d_cs$Score[is_c1] <- ifelse(d_cs$Score[is_c1] <= 2, 1, 2)
  d_cs$Score[is_c2] <- pmax(2, d_cs$Score[is_c2])
  f_cs <- fit_mfrm(
    d_cs, "Person", c("Rater", "Criterion"), "Score",
    model = "RSM", step_facet = "Criterion", method = "MML",
    rating_min = 1, rating_max = 4, category_support = cs_mix,
    control = list(quad_points = 21L, mml_integration = "fixed")
  )
  plan_c2 <- data.frame(Rater = "R01", Criterion = "Organization", stringsAsFactors = FALSE)
  cls_c2 <- classification_table(f_cs, rating_plan = plan_c2, cut_scores = 0, score_cuts = 2, theta = 0)
  pr_c2 <- predict(f_cs, newdata = cbind(plan_c2, theta = 0), type = "probs")
  exp_c2 <- as.numeric(predict(f_cs, newdata = cbind(plan_c2, theta = 0), type = "response"))
  expect_equal(cls_c2$scores$Probability, as.numeric(pr_c2[1L, ]), tolerance = 1e-12)
  p_ge3 <- sum(pr_c2[1L, c("3", "4")])
  expect_gt(p_ge3, 0.2)
  expect_equal(cls_c2$probabilities$Probability[cls_c2$probabilities$Method == "lee_sum" & cls_c2$probabilities$Category == 2L],
               p_ge3, tolerance = 1e-12)
  expect_equal(cls_c2$table$ExpectedSum[1L], exp_c2 - f_cs$rating_min, tolerance = 1e-12)
  cls_def <- classification_table(f_cs, rating_plan = data.frame(Rater = "R01", Criterion = "Content"), cut_scores = 0, theta = 0)
  expect_identical(as.integer(cls_def$cuts$ScoreCut), 1L)

  # B4: Weighted WLE 3-way parity (stored WLE vs newdata with weights vs frequency-expanded newdata) across RSM and GPCM
  d_wt <- d
  d_wt$W <- ifelse(d_wt$Score == 4, 5, 1)
  d_exp_freq <- d_wt[rep(seq_len(nrow(d_wt)), d_wt$W), c("Person", "Rater", "Criterion", "Score")]
  rownames(d_exp_freq) <- NULL

  f_rsm_w <- fit_mfrm(d_wt, "Person", c("Rater", "Criterion"), "Score", weight = "W",
                      method = "MML", person_score = "WLE",
                      control = list(quad_points = 15L, mml_integration = "fixed"))
  w_rsm_nd <- predict(f_rsm_w, newdata = d_wt, type = "wle")
  w_rsm_ex <- predict(f_rsm_w, newdata = d_exp_freq, type = "wle")
  expect_equal(w_rsm_nd$Estimate, f_rsm_w$person$WLE, tolerance = 1e-13)
  expect_equal(w_rsm_ex$Estimate, f_rsm_w$person$WLE, tolerance = 1e-13)
  expect_equal(w_rsm_nd$SE, f_rsm_w$person$WLE_SE, tolerance = 1e-13)
  expect_equal(w_rsm_ex$SE, f_rsm_w$person$WLE_SE, tolerance = 1e-13)

  for (st in c("full_predictor", "ability_only")) {
    f_gp_w <- fit_mfrm(
      d_wt, "Person", c("Rater", "Criterion"), "Score", weight = "W",
      model = "GPCM", slope_facet = "Criterion", method = "MML", person_score = "WLE",
      spec = list(slope_type = st, gpcm_mml_identification = "fixed_standard_normal"),
      control = list(quad_points = 15L, mml_integration = "fixed")
    )
    w_gp_nd <- predict(f_gp_w, newdata = d_wt, type = "wle")
    w_gp_ex <- predict(f_gp_w, newdata = d_exp_freq, type = "wle")
    expect_equal(w_gp_nd$Estimate, f_gp_w$person$WLE, tolerance = 1e-13)
    expect_equal(w_gp_ex$Estimate, f_gp_w$person$WLE, tolerance = 1e-13)
    expect_equal(w_gp_nd$SE, f_gp_w$person$WLE_SE, tolerance = 1e-13)
    expect_equal(w_gp_ex$SE, f_gp_w$person$WLE_SE, tolerance = 1e-13)
  }

  # A6: predict() disambiguates Person = "Theta", rejects factor ability, and forbids recycling length 2 into 3
  d_pth <- d
  names(d_pth)[names(d_pth) == "Person"] <- "Theta"
  f_pth <- fit_mfrm(d_pth, "Theta", c("Rater", "Criterion"), "Score", method = "JML")
  f_std <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", method = "JML")
  expect_equal(as.numeric(predict(f_pth, newdata = d_pth[1:6, ], type = "response")),
               as.numeric(predict(f_std, newdata = d[1:6, ], type = "response")), tolerance = 1e-12)
  nd3 <- d[1:3, c("Rater", "Criterion")]
  expect_error(predict(f_std, newdata = transform(nd3, theta = factor(c("0", "1", "2")))), "plain numeric")
  expect_error(predict(f_std, newdata = nd3, theta = factor(c("0", "1", "2"))), "plain numeric")
  expect_error(predict(f_std, newdata = nd3, theta = c(-1, 1)), "length 1 or `nrow\\(newdata\\)`")

  # B5 & A10: Reject factor category_support / step_constraints and invalid/duplicate facet declarations
  cs_fac <- data.frame(
    Level = "Common",
    Min = factor("0", levels = c("0", "4")),
    Max = factor("4", levels = c("0", "4")),
    stringsAsFactors = FALSE
  )
  d_12 <- transform(d, Score = ifelse(Score <= 2, 1, 2))
  expect_error(fit_mfrm(d_12, "Person", c("Rater", "Criterion"), "Score",
                        rating_min = 0, rating_max = 4, category_support = cs_fac, method = "JML"),
               "category_support\\$Min")
  expect_error(fit_mfrm(d_12, "Person", c("Rater", "Criterion"), "Score",
                        category_support = cs_fac, method = "JML"),
               "category_support\\$Min")
  expect_error(mfrm_batch_fit(d_12, "Person", c("Rater", "Criterion"), "Score",
                              score_matrix = cbind(d_12$Score, d_12$Score),
                              category_support = cs_fac, method = "JML"),
               "category_support\\$Min")
  sc_fac <- data.frame(
    Level = "Common",
    From = factor("1", levels = c("1", "2")),
    To = factor("2", levels = c("1", "2")),
    Value = 0
  )
  expect_error(fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
                        step_constraints = sc_fac, method = "JML"),
               "step_constraints\\$From")
  expect_error(fit_mfrm(d, "Person", c("Rater", "Rater"), "Score", method = "JML"), "distinct")
  expect_error(fit_mfrm(d, "Person", c("Person", "Rater"), "Score", method = "JML"), "distinct")
  expect_error(fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", positive_facets = "Ratetr", method = "JML"),
               "positive_facets")
  expect_error(fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", dummy_facets = "Unknown", method = "JML"),
               "dummy_facets")
  expect_error(fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", noncenter_facet = "Unknown", method = "JML"),
               "noncenter_facet")
  expect_error(fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
                        dummy_facets = "Rater", noncenter_facet = "Rater", method = "JML"),
               "noncenter_facet")
  expect_error(fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
                        bias_facets = c("Rater", "Rater"), method = "JML"),
               "bias_facets")
  expect_error(mfrm_batch_fit(d, "Person", c("Rater", "Criterion"), "Score",
                              score_matrix = cbind(d$Score, d$Score),
                              bias_facets = c("Rater", "Rater"), method = "JML"),
               "bias_facets")
  expect_error(mfrm_batch_fit(d, "Person", c("Rater", "Criterion"), "Score",
                              score_matrix = cbind(d$Score, d$Score),
                              bias_facets = c("Rater", "MissingFacet"), method = "JML"),
               "bias_facets")
})

test_that("Henderson G-Study handles replicates, saved reload refresh, and untruncated delta CIs", {
  # B2: Balanced 12 persons x 3 raters x 4 replicates/cell -> observed divides Residual by 12, D-Study by 3
  set.seed(20261127)
  p_eff <- seq(-1.5, 1.5, length.out = 12L)
  r_eff <- c(-0.4, 0.0, 0.4)
  d_rep <- expand.grid(Rep = 1:4, Rater = paste0("R", 1:3), Person = sprintf("P%02d", 1:12),
                       stringsAsFactors = FALSE)
  pr_noise <- stats::rnorm(36L, sd = 0.35)
  names(pr_noise) <- as.vector(outer(paste0("R", 1:3), sprintf("P%02d", 1:12), paste, sep = ":"))
  d_rep$Score <- p_eff[match(d_rep$Person, sprintf("P%02d", 1:12))] +
    r_eff[match(d_rep$Rater, paste0("R", 1:3))] +
    pr_noise[paste(d_rep$Rater, d_rep$Person, sep = ":")] +
    stats::rnorm(nrow(d_rep), sd = 1.4)
  gt_rep <- mfrm_g_study(d_rep, scores = "Score", person = "Person", facets = "Rater", method = "urgenova")
  vc_r <- stats::setNames(gt_rep$variance_components$Estimate, gt_rep$variance_components$Component)
  expect_true("Residual" %in% names(vc_r))
  exp_abs_obs <- unname(vc_r["Rater"] / 3 + vc_r["Person:Rater"] / 3 + vc_r["Residual"] / 12)
  exp_phi_obs <- unname(vc_r["Person"] / (vc_r["Person"] + exp_abs_obs))
  expect_equal(gt_rep$g_study_summary$AbsErrorVar, exp_abs_obs, tolerance = 1e-12)
  expect_equal(gt_rep$g_study_summary$Phi, exp_phi_obs, tolerance = 1e-12)
  ds_r3 <- gt_rep$d_study[gt_rep$d_study$Rater == 3L, ]
  exp_abs_d3 <- unname(vc_r["Rater"] / 3 + vc_r["Person:Rater"] / 3 + vc_r["Residual"] / 3)
  expect_equal(ds_r3$AbsErrorVar, exp_abs_d3, tolerance = 1e-12)
  expect_gt(gt_rep$g_study_summary$Phi, ds_r3$Phi)

  # A2: Simulated pre-fix saved nested G-Study refreshes observed denominators & CIs, or marks unavailable if data stripped
  d_nest <- do.call(rbind, lapply(sprintf("P%02d", 1:12), function(p) {
    rbind(
      data.frame(Person = p, Site = "S1", Task = "T1", Rater = c("R1", "R2")),
      data.frame(Person = p, Site = "S1", Task = "T2", Rater = "R3"),
      data.frame(Person = p, Site = "S2", Task = "T1", Rater = "R4"),
      data.frame(Person = p, Site = "S2", Task = "T2", Rater = c("R5", "R6"))
    )
  }))
  set.seed(42)
  d_nest$Score <- match(d_nest$Person, sprintf("P%02d", 1:12)) * 0.35 + stats::rnorm(nrow(d_nest), sd = 0.6)
  gt_fresh <- mfrm_g_study(
    d_nest, scores = "Score", person = "Person",
    facets = c("Site", "Task", "Rater"),
    nesting = c(Task = "Site", Rater = "Task"),
    method = "urgenova"
  )
  gt_stale <- gt_fresh
  gt_stale[c("obs_scale_version", "obs_component_scales", "obs_component_denoms", "obs_n_total_per_person")] <- list(NULL)
  gt_stale$obs_n_per_facet["Rater"] <- 3.0
  gt_stale$g_study_summary$Harmonic_Rater <- 3.0
  gt_stale$g_study_summary$AbsErrorVar <- 0.05
  gt_stale$g_study_summary$RelErrorVar <- 0.04
  gt_stale$g_study_summary$Phi <- 0.95
  gt_stale$g_study_summary$G <- 0.96
  expect_equal(summary(gt_stale)$g_study_summary$Harmonic_Rater, gt_fresh$g_study_summary$Harmonic_Rater, tolerance = 1e-12)
  expect_equal(summary(gt_stale)$g_study_summary$Phi, gt_fresh$g_study_summary$Phi, tolerance = 1e-12)
  expect_equal(confint(gt_stale, component = "coefficients"), confint(gt_fresh, component = "coefficients"), tolerance = 1e-12)

  gt_nodata <- gt_stale
  gt_nodata["data"] <- list(NULL)
  s_nodata <- summary(gt_nodata)
  expect_true(is.na(s_nodata$g_study_summary$Phi))
  expect_true(is.na(s_nodata$g_study_summary$AbsErrorVar))
  ci_nodata <- confint(gt_nodata, component = "coefficients")
  expect_true(all(is.na(ci_nodata)))
  expect_identical(unname(attr(ci_nodata, "status")), rep("unavailable_observed_denominators", 2L))

  # B3: truncate_negative = FALSE aligns confint() delta-method gradient with negative variance components
  set.seed(77)
  d_neg <- expand.grid(Person = paste0("P", 1:12), Rater = paste0("R", 1:3), Task = paste0("T", 1:3),
                       stringsAsFactors = FALSE)
  p_true <- seq(-2, 2, length.out = 12L)[match(d_neg$Person, paste0("P", 1:12))]
  # Add slight negative within-person correlation across tasks to induce a negative Rater/Task or interaction component
  t_idx <- match(d_neg$Task, paste0("T", 1:3))
  d_neg$Score <- p_true + ifelse(t_idx == 1L, 0.25, -0.125) + stats::rnorm(nrow(d_neg), sd = 0.8)
  gt_ut <- mfrm_g_study(d_neg, scores = "Score", person = "Person", facets = c("Rater", "Task"),
                        method = "urgenova", truncate_negative = FALSE)
  # Ensure at least one negative non-person component with positive total error variance for exact numerical gradient test
  if (!any(gt_ut$variance_components$Estimate[-1L] < 0)) {
    gt_ut$variance_components$RawEstimate[2L] <- gt_ut$variance_components$Estimate[2L] <- -0.04
    gt_ut <- mfrmr:::.mfrm_refresh_gstudy(gt_ut)
  }
  expect_true(any(gt_ut$variance_components$Estimate[-1L] < 0))
  expect_gt(gt_ut$g_study_summary$AbsErrorVar, 0)
  scales_ut <- mfrmr:::.mfrm_henderson_obs_scales(gt_ut)
  v_est <- gt_ut$variance_components$Estimate
  logit_phi_fn <- function(v) {
    sp <- v[1L]
    sa <- sum(v[-1L] * scales_ut[-1L])
    log(sp / sa)
  }
  eps <- 1e-7
  num_grad <- vapply(seq_along(v_est), function(k) {
    vp <- v_est; vm <- v_est
    vp[k] <- vp[k] + eps; vm[k] <- vm[k] - eps
    (logit_phi_fn(vp) - logit_phi_fn(vm)) / (2 * eps)
  }, numeric(1))
  se_num <- sqrt(as.numeric(t(num_grad) %*% vcov(gt_ut) %*% num_grad))
  ci_num <- stats::plogis(logit_phi_fn(v_est) + c(-1, 1) * stats::qnorm(0.975) * se_num)
  ci_ut <- confint(gt_ut, parm = "Phi", component = "coefficients")
  expect_equal(as.numeric(ci_ut[1L, ]), ci_num, tolerance = 1e-7)
})

test_that("Markov drift homo SE, readiness/static flag screening, contrasts plot, and workflow handoffs hold", {
  utils::data("mfrmr_example_core", package = "mfrmr")
  d <- mfrmr_example_core
  d$Wave <- ifelse(match(d$Person, unique(d$Person)) %% 2L == 1L, "W1", "W2")
  # Add a few bridge persons rated in both waves
  d_br <- d[1:24, ]
  d_br$Wave <- ifelse(d_br$Wave == "W1", "W2", "W1")
  d_dr <- rbind(d, d_br)

  # B1: markov_homo LogSigmaSE matches numerical 2nd derivative of negative Laplace log-posterior
  dr_homo <- fit_mfrm_drift(
    d_dr, person = "Person", rater = "Rater", time = "Wave", score = "Score",
    facets = "Criterion", model = "RSM", drift_mode = "markov_homo",
    eb_method = "full_laplace", quad_points = 41L
  )
  expect_true(dr_homo$checks$NumericalReady)
  dat_p <- mfrmr:::.drift_prepare_input(d_dr, "Person", "Rater", "Wave", "Score", "Criterion", 1:4, "fail")
  lay_p <- mfrmr:::.drift_layout(dat_p, time_mode = "dynamic", step_mode = "shared")
  quad_p <- mfrmr:::.drift_quadrature_normal(n_quad = 41L, mean = 0, sd = 1)
  neg_lap_at <- function(s_scalar) {
    inn <- mfrmr:::.drift_solve_inner(
      xi_init = dr_homo$coefficients, dat = dat_p, quad = quad_p, layout = lay_p,
      D = 1, prior_mode = "markov", log_sigma_r = rep(s_scalar, dat_p$R),
      beta1_sd = 1, step_sd = 1, tol = 1e-11, maxit = 60L
    )
    hyper_lp <- -0.5 * ((s_scalar - (-2))^2) / (1^2) - log(1)
    -(inn$obj - 0.5 * inn$log_det_H + hyper_lp)
  }
  s_hat <- dr_homo$rater_drift_table$LogSigma[1L]
  h_step <- 1e-4
  d2_num <- (neg_lap_at(s_hat + h_step) - 2 * neg_lap_at(s_hat) + neg_lap_at(s_hat - h_step)) / (h_step^2)
  se_num <- 1 / sqrt(d2_num)
  # Exact Kass-Steffey Laplace curvature (with prior precision applied once, not R=4 times)
  # matches numerical Hessian closely (0.774 vs 0.776; old R-fold prior bug gave 0.463).
  expect_equal(dr_homo$rater_drift_table$LogSigmaSE[1L], se_num, tolerance = 5e-3)
  expect_gt(dr_homo$rater_drift_table$LogSigmaSE[1L], 0.70)
  expect_true(all(dr_homo$severity_table$TotalSE >= dr_homo$severity_table$ConditionalSE - 1e-12))

  # A9: plot.mfrm_drift(type = "contrasts") plots wave contrasts distinct from trajectory
  p_traj <- plot(dr_homo, type = "trajectory")
  p_cont <- plot(dr_homo, type = "contrasts")
  expect_s3_class(p_cont, "ggplot")
  expect_lt(nrow(p_cont$data), nrow(p_traj$data))
  expect_equal(p_cont$data$Estimate,
               dr_homo$severity_table$ChangeFromBaseline[dr_homo$severity_table$WaveIndex > 1L],
               tolerance = 1e-12)

  # A3: Static mode with drift_threshold = 0, flag_se_ratio = 0 never flags 0 change
  dr_stat <- fit_mfrm_drift(
    d_dr, person = "Person", rater = "Rater", time = "Wave", score = "Score",
    facets = "Criterion", model = "RSM", drift_mode = "static",
    drift_threshold = 0, flag_se_ratio = 0, quad_points = 41L
  )
  expect_true(dr_stat$checks$NumericalReady)
  expect_true(all(!dr_stat$severity_table$FlaggedDrift))
  expect_true(all(!dr_stat$rater_drift_table$Flagged))
  expect_identical(dr_stat$model_summary$FlaggedRaters, 0L)

  # A3: Non-ready drift object (and simulated legacy saved object) withholds flags as NA, not FALSE/0
  dr_bad <- dr_homo
  dr_bad$checks$NumericalReady <- FALSE
  dr_bad$severity_table$FlaggedDrift <- TRUE
  dr_bad$rater_drift_table$Flagged <- TRUE
  dr_bad$model_summary$FlaggedRaters <- 4L
  expect_true(all(is.na(as.data.frame(dr_bad, component = "severity")$FlaggedDrift)))
  expect_true(all(is.na(as.data.frame(dr_bad, component = "rater_drift")$Flagged)))
  expect_true(is.na(as.data.frame(dr_bad, component = "summary")$FlaggedRaters))
  expect_true(all(is.na(summary(dr_bad)$rater_drift$Flagged)))
  expect_match(paste(capture.output(print(dr_bad)), collapse = "\n"), "unavailable", fixed = TRUE)
  p_cont_bad <- plot(dr_bad, type = "contrasts")
  expect_match(paste(attr(p_cont_bad, "mfrm_notes"), collapse = " "), "withheld", fixed = TRUE)

  # A4: Workflow passes rating_min:rating_max to fit_mfrm_drift and avoids $drift partial match when withheld
  wf_span <- mfrm_workflow(d_dr, "Person", c("Rater", "Criterion"), "Score",
                           occasion = "Wave", rating_min = 0, rating_max = 5) |>
    step_mfrm_measure(model = "RSM", method = "JML")
  expect_identical(wf_span[["drift"]]$input$score_levels, 0:5)

  cs_sub <- data.frame(Level = "Common", Min = 1, Max = 4)
  wf_withheld <- mfrm_workflow(d_dr, "Person", c("Rater", "Criterion"), "Score",
                               occasion = "Wave", rating_min = 0, rating_max = 5) |>
    step_mfrm_measure(model = "RSM", method = "JML", category_support = cs_sub)
  expect_null(wf_withheld[["drift"]])
  expect_null(wf_withheld$drift)
  expect_null(summary(wf_withheld)$drift)
  expect_match(summary(wf_withheld)$drift_reason, "withheld", fixed = TRUE)

  # A7: Pre-fitted workflow retains post-hoc dff_group and occasion columns; diagnostic keys tolerate tibble & "method"
  f_base <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", method = "JML")
  d_aug <- d
  d_aug$Group <- ifelse(match(d_aug$Person, unique(d_aug$Person)) %% 2L == 0L, "Foc", "Ref")
  d_aug$Wave <- ifelse(seq_len(nrow(d_aug)) %% 2L == 0L, "T1", "T2")
  wf_pre <- mfrm_workflow(d_aug, "Person", c("Rater", "Criterion"), "Score",
                          occasion = "Wave", fit = f_base) |>
    step_mfrm_diagnose(dff_group = "Group", dff_method = "raju_welch")
  expect_equal(nrow(wf_pre$diagnostics$dff), 4L)
  expect_null(wf_pre$diagnostics$report_statistics$agreement_reason)
  expect_s3_class(wf_pre$diagnostics$report_statistics$agreement, "mfrm_agreement")

  dff_tib <- analyze_dff(f_base, "Rater", "Group", data = tibble::as_tibble(d_aug), method = "raju_welch")
  expect_equal(dff_tib$table$Contrast, wf_pre$diagnostics$dff$Contrast, tolerance = 1e-12)

  d_mth <- d_aug
  names(d_mth)[names(d_mth) == "Criterion"] <- "method"
  f_mth <- fit_mfrm(d_mth, "Person", c("Rater", "method"), "Score", method = "JML")
  dff_mth <- analyze_dff(f_mth, "Rater", "Group", data = tibble::as_tibble(d_mth), method = "raju_welch")
  expect_equal(dff_mth$table$Contrast, dff_tib$table$Contrast, tolerance = 1e-12)
})

test_that("interrater_agreement validates numeric scores/categories, scale-invariant weights, model support, and sparse indexing", {
  # A8 & B6: Factor rejection, out-of-range declared categories error, and span < 1 scale invariance
  d_bin <- data.frame(
    Person = rep(paste0("U", 1:6), each = 2L),
    Rater = rep(c("R1", "R2"), times = 6L),
    Score = c(0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0),
    stringsAsFactors = FALSE
  )
  expect_error(interrater_agreement(transform(d_bin, Score = factor(Score))), "plain numeric")
  expect_error(interrater_agreement(d_bin, categories = factor(c("0", "1"))), "categories")
  expect_error(interrater_agreement(rbind(d_bin, data.frame(Person = "U7", Rater = "R1", Score = 5)),
                                    categories = c(0, 1)), "outside declared `categories`")

  ag_01 <- interrater_agreement(d_bin, weights = "quadratic")
  ag_dec <- interrater_agreement(transform(d_bin, Score = Score * 0.1), weights = "quadratic")
  expect_equal(ag_dec$summary$Estimate, ag_01$summary$Estimate, tolerance = 1e-13)
  expect_equal(ag_dec$summary$Estimate[ag_dec$summary$Metric == "GwetAC2"], 1 / 3, tolerance = 1e-12)
  # Single observed category (Q = 1) does not divide by zero
  ag_q1 <- interrater_agreement(transform(d_bin, Score = 0.25), metric = "exact")
  expect_equal(ag_q1$summary$Estimate, c(1, 1), tolerance = 1e-12)

  # A5: model_expected = TRUE checks score column and structural support (without dropping extreme-theta underflow)
  utils::data("mfrmr_example_core", package = "mfrmr")
  d <- mfrmr_example_core
  cs_24 <- data.frame(
    Level = c("Content", "Organization", "Language", "Accuracy"),
    Min = c(1, 2, 1, 2),
    Max = c(2, 4, 4, 4),
    stringsAsFactors = FALSE
  )
  d_cs <- d
  d_cs$Score[d_cs$Criterion == "Content"] <- ifelse(d_cs$Score[d_cs$Criterion == "Content"] <= 2, 1, 2)
  d_cs$Score[d_cs$Criterion %in% c("Organization", "Accuracy")] <- pmax(2, d_cs$Score[d_cs$Criterion %in% c("Organization", "Accuracy")])
  f_cs <- fit_mfrm(d_cs, "Person", c("Rater", "Criterion"), "Score",
                   model = "RSM", step_facet = "Criterion", method = "MML",
                   rating_min = 1, rating_max = 4, category_support = cs_24,
                   control = list(quad_points = 15L, mml_integration = "fixed"))
  f_cs_extra <- f_cs
  f_cs_extra$encoding$retained_data$Other <- 2
  expect_error(interrater_agreement(f_cs_extra, score = "Other", model_expected = TRUE),
               "calibrated rating column")

  # Force extreme finite person ability theta = 900 on P01 (so probs underflows to (0, 0, 0, 1) on Organization 2..4)
  f_ext <- f_cs
  f_ext$person$Estimate[1L] <- 900
  ag_ext <- interrater_agreement(f_ext, model_expected = TRUE)
  expect_identical(ag_ext$model_expected$Status, "available")
  expect_equal(ag_ext$model_expected$Pairs, ag_ext$model_expected$ObservedPairs)

  # Tamper one retained score on Organization (2..4) to structurally unsupported 1 -> excluded from usable model pairs
  f_tamper <- f_cs
  idx_org <- which(f_tamper$encoding$retained_data$Criterion == "Organization")[1L]
  f_tamper$encoding$retained_data$Score[idx_org] <- 1
  ag_tamper <- interrater_agreement(f_tamper, model_expected = TRUE)
  expect_lt(ag_tamper$model_expected$Pairs, ag_tamper$model_expected$ObservedPairs)
  expect_identical(ag_tamper$model_expected$Status, "partially_available")

  # A-Scale: Hand-calculable mixed fixture (1-rater singleton, 2-rater unit, 3-rater unit, and N=1 co-rating pair)
  # Units:
  # U1 (singleton, 1 rater): R1=1
  # U2 (2 raters): R1=2, R2=2 -> 1 pair (R1,R2): exact=1, adj=1, W=1
  # U3 (2 raters): R1=1, R2=3 -> 1 pair (R1,R2): exact=0, adj=0, W=0 (on cats 1,2,3 quadratic: (2/2)^2=1 -> W=0)
  # U4 (3 raters): R1=2, R2=2, R3=3 -> 3 pairs: (R1,R2)=(2,2)[ex=1,adj=1,W=1], (R1,R3)=(2,3)[ex=0,adj=1,W=3/4], (R2,R3)=(2,3)[ex=0,adj=1,W=3/4]
  # Total pairs = 1 + 1 + 3 = 5; Exact = (1 + 0 + 1 + 0 + 0)/5 = 2/5 = 0.4; Adjacent = (1 + 0 + 1 + 1 + 1)/5 = 4/5 = 0.8
  # Pairwise table: (R1,R2) has N=3 (U2,U3,U4); (R1,R3) and (R2,R3) each have N=1 -> excluded from pairwise!
  # Gwet AC2 (quadratic on cats 1,2,3; W = [[1, 3/4, 0], [3/4, 1, 3/4], [0, 3/4, 1]], sum(W) = 6):
  #   within-unit agreement on multi-rater units U2, U3, U4:
  #     U2: 1; U3: 0; U4: (1 + 3/4 + 3/4)/3 = 5/6 -> po_ov = (1 + 0 + 5/6)/3 = 11/18
  #   pi_q across ALL 4 rated units (including singleton U1!):
  #     U1: (1, 0, 0); U2: (0, 1, 0); U3: (1/2, 0, 1/2); U4: (0, 2/3, 1/3)
  #     pi = (3/2, 5/3, 5/6) / 4 = (9/24, 10/24, 5/24)
  #     pe_gwet = (6 / (3 * 2)) * sum(pi * (1 - pi)) = (9*15 + 10*14 + 5*19) / 576 = 370 / 576
  #     AC2 = (11/18 - 370/576) / (1 - 370/576) = (352 - 370) / (576 - 370) = -18 / 206 = -9 / 103
  d_hand <- data.frame(
    Person = c("U1", "U2", "U2", "U3", "U3", "U4", "U4", "U4"),
    Rater = c("R1", "R1", "R2", "R1", "R2", "R1", "R2", "R3"),
    Score = c(1, 2, 2, 1, 3, 2, 2, 3),
    stringsAsFactors = FALSE
  )
  ag_hand <- interrater_agreement(d_hand, weights = "quadratic", metric = "all")
  s_hand <- stats::setNames(ag_hand$summary$Estimate, ag_hand$summary$Metric)
  expect_equal(unname(s_hand["ExactAgreement"]), 0.4, tolerance = 1e-15)
  expect_equal(unname(s_hand["AdjacentAgreement"]), 0.8, tolerance = 1e-15)
  expect_equal(unname(s_hand["GwetAC2"]), -9 / 103, tolerance = 1e-15)
  expect_identical(ag_hand$summary$Units[1L], 3L)
  expect_identical(ag_hand$summary$Raters[1L], 3L)
  expect_identical(nrow(ag_hand$pairwise), 1L)
  expect_identical(ag_hand$pairwise$N, 3L)
  ag_exact_only <- interrater_agreement(d_hand, weights = "quadratic", metric = "exact")
  expect_true("Kappa" %in% names(ag_exact_only$pairwise))
  expect_equal(ag_exact_only$pairwise, ag_hand$pairwise, tolerance = 1e-15)

  # Sparse 300-rater / 1,500-unit (3,000 ratings) scaling check
  u_big <- rep(sprintf("U%04d", 1:1500), each = 2L)
  r_big <- as.vector(vapply(1:1500, function(i) {
    r1 <- ((i - 1L) %% 300L) + 1L
    r2 <- (i %% 300L) + 1L
    sprintf("R%03d", c(r1, r2))
  }, character(2)))
  s_big <- rep(c(1, 2, 2, 2, 3, 4), length.out = 3000L)
  d_big <- data.frame(Person = u_big, Rater = r_big, Score = s_big, stringsAsFactors = FALSE)
  t_sp <- proc.time()[[3L]]
  ag_big <- interrater_agreement(d_big, metric = "exact")
  dt_sp <- proc.time()[[3L]] - t_sp
  expect_lt(dt_sp, 2.0)
  expect_identical(ag_big$summary$Units[1L], 1500L)
  expect_identical(ag_big$summary$Raters[1L], 300L)
})

test_that("unequal replicates, Residual facet names, saved homo drift refresh, WLE role aliases, and workflow/agreement consistency hold", {
  # 1. Unequal replicates (16 persons rated 8, 1, 1 times by the same 3 raters -> 0.8^2 + 0.1^2 + 0.1^2 = 0.66)
  set.seed(20261128)
  p_ids <- sprintf("P%02d", 1:16)
  p_eff <- stats::setNames(seq(-1.4, 1.4, length.out = 16L), p_ids)
  r_eff <- c(R1 = -0.6, R2 = 0.1, R3 = 0.5)
  d_unrep <- do.call(rbind, lapply(p_ids, function(p) {
    data.frame(
      Person = p,
      Rater = c(rep("R1", 8L), "R2", "R3"),
      stringsAsFactors = FALSE
    )
  }))
  pr_eff <- stats::rnorm(48L, sd = 0.45)
  names(pr_eff) <- as.vector(outer(p_ids, names(r_eff), paste, sep = ":"))
  d_unrep$Score <- p_eff[d_unrep$Person] + r_eff[d_unrep$Rater] +
    pr_eff[paste(d_unrep$Person, d_unrep$Rater, sep = ":")] +
    stats::rnorm(nrow(d_unrep), sd = 0.8)

  gt_unrep <- mfrm_g_study(d_unrep, scores = "Score", person = "Person", facets = "Rater", method = "urgenova")
  vc_u <- stats::setNames(gt_unrep$variance_components$Estimate, gt_unrep$variance_components$Component)
  w_rater <- 0.8^2 + 0.1^2 + 0.1^2
  exp_abs_u <- unname(w_rater * vc_u["Rater"] + w_rater * vc_u["Person:Rater"] + 0.1 * vc_u["Residual"])
  exp_rel_u <- unname(w_rater * vc_u["Person:Rater"] + 0.1 * vc_u["Residual"])
  expect_equal(gt_unrep$g_study_summary$AbsErrorVar, exp_abs_u, tolerance = 1e-12)
  expect_equal(gt_unrep$g_study_summary$RelErrorVar, exp_rel_u, tolerance = 1e-12)
  expect_equal(gt_unrep$g_study_summary$Phi, unname(vc_u["Person"] / (vc_u["Person"] + exp_abs_u)), tolerance = 1e-12)

  # Simulated pre-fix saved unequal-replicate G-Study refreshes to 0.66 multipliers on reload
  gt_unrep_old <- gt_unrep
  gt_unrep_old["obs_scale_version"] <- list(NULL)
  gt_unrep_old["obs_component_scales"] <- list(NULL)
  gt_unrep_old$obs_component_denoms <- c(Person = 1, Rater = 3, "Person:Rater" = 3, Residual = 10)
  gt_unrep_old$g_study_summary$Phi <- 0.99
  expect_equal(summary(gt_unrep_old)$g_study_summary$Phi, gt_unrep$g_study_summary$Phi, tolerance = 1e-12)
  expect_equal(confint(gt_unrep_old, component = "coefficients"),
               confint(gt_unrep, component = "coefficients"), tolerance = 1e-12)

  # 2. Facet named "Residual" does not change denominators or Phi (fresh or reloaded)
  set.seed(88)
  d_rname <- expand.grid(Person = sprintf("P%02d", 1:12), R = paste0("J", 1:3), Cond = c("C1", "C2"),
                         stringsAsFactors = FALSE)
  d_rname$Score <- match(d_rname$Person, sprintf("P%02d", 1:12)) * 0.25 +
    c(-0.5, 0.0, 0.5)[match(d_rname$R, paste0("J", 1:3))] +
    stats::rnorm(nrow(d_rname), sd = 0.7)
  d_rescol <- d_rname
  names(d_rescol)[names(d_rescol) == "R"] <- "Residual"
  gt_r <- mfrm_g_study(d_rname, scores = "Score", person = "Person", facets = c("R", "Cond"), method = "urgenova")
  gt_res <- mfrm_g_study(d_rescol, scores = "Score", person = "Person", facets = c("Residual", "Cond"), method = "urgenova")
  expect_false(gt_res$has_replicates)
  expect_equal(gt_res$variance_components$Estimate, gt_r$variance_components$Estimate, tolerance = 1e-12)
  expect_equal(gt_res$g_study_summary$Phi, gt_r$g_study_summary$Phi, tolerance = 1e-12)
  expect_equal(unname(confint(gt_res, component = "coefficients")),
               unname(confint(gt_r, component = "coefficients")), tolerance = 1e-12)
  gt_res_old <- gt_res
  gt_res_old["has_replicates"] <- list(NULL)
  gt_res_old["obs_scale_version"] <- list(NULL)
  expect_equal(summary(gt_res_old)$g_study_summary$Phi, gt_r$g_study_summary$Phi, tolerance = 1e-12)

  # Facet named "Residual" WITH replicates also matches facet named "R"
  d_rrep <- rbind(d_rname, transform(d_rname, Score = Score + 0.2))
  d_resrep <- d_rrep
  names(d_resrep)[names(d_resrep) == "R"] <- "Residual"
  gt_rrep <- mfrm_g_study(d_rrep, scores = "Score", person = "Person", facets = c("R", "Cond"), method = "urgenova")
  gt_resrep <- mfrm_g_study(d_resrep, scores = "Score", person = "Person", facets = c("Residual", "Cond"), method = "urgenova")
  expect_true(gt_resrep$has_replicates)
  expect_equal(gt_resrep$variance_components$Estimate, gt_rrep$variance_components$Estimate, tolerance = 1e-12)
  expect_equal(gt_resrep$g_study_summary$Phi, gt_rrep$g_study_summary$Phi, tolerance = 1e-12)

  # 3 & C1: Saved markov_homo RDS refreshes narrow SE/vcov/CIs; non-ready drift screens SEs across all extractors
  utils::data("mfrmr_example_core", package = "mfrmr")
  d <- mfrmr_example_core
  d$Wave <- ifelse(match(d$Person, unique(d$Person)) %% 2L == 1L, "W1", "W2")
  d_br <- d[1:24, ]
  d_br$Wave <- ifelse(d_br$Wave == "W1", "W2", "W1")
  d_dr <- rbind(d, d_br)
  dr_fresh <- fit_mfrm_drift(
    d_dr, person = "Person", rater = "Rater", time = "Wave", score = "Score",
    facets = "Criterion", model = "RSM", drift_mode = "markov_homo",
    eb_method = "full_laplace", quad_points = 41L
  )
  dr_legacy <- dr_fresh
  dr_legacy["hyper_se_version"] <- list(NULL)
  dr_legacy$vcov_hyper[] <- 0.46258^2
  dr_legacy$vcov_total <- dr_legacy$vcov_conditional
  dr_legacy$rater_drift_table$LogSigmaSE <- 0.46258
  dr_legacy$rater_drift_table$DriftSD_EAP <- exp(dr_legacy$rater_drift_table$LogSigma + 0.5 * 0.46258^2)
  dr_legacy$severity_table$TotalSE <- dr_legacy$severity_table$ConditionalSE
  dr_legacy$severity_table$ChangeSE <- dr_legacy$severity_table$ChangeConditionalSE
  dr_legacy$rater_drift_table$NetDriftSE <- 0.1

  expect_equal(confint(dr_legacy, parm = "drift_sd"), confint(dr_fresh, parm = "drift_sd"), tolerance = 1e-12)
  expect_equal(confint(dr_legacy, parm = "severity"), confint(dr_fresh, parm = "severity"), tolerance = 1e-12)
  expect_equal(confint(dr_legacy, parm = "contrasts"), confint(dr_fresh, parm = "contrasts"), tolerance = 1e-12)
  expect_equal(vcov(dr_legacy, se_type = "hyper"), vcov(dr_fresh, se_type = "hyper"), tolerance = 1e-12)
  expect_equal(vcov(dr_legacy, se_type = "total"), vcov(dr_fresh, se_type = "total"), tolerance = 1e-12)
  expect_equal(coef(dr_legacy, parm = "drift_sd"), coef(dr_fresh, parm = "drift_sd"), tolerance = 1e-12)
  expect_equal(summary(dr_legacy)$rater_drift$LogSigmaSE, dr_fresh$rater_drift_table$LogSigmaSE, tolerance = 1e-12)
  expect_equal(as.data.frame(dr_legacy, component = "severity")$TotalSE, dr_fresh$severity_table$TotalSE, tolerance = 1e-12)

  # Unrecoverable legacy markov_homo (missing vcov_conditional) withholds total SEs & intervals with note
  dr_unrec <- dr_legacy
  dr_unrec["vcov_conditional"] <- list(NULL)
  expect_true(all(is.na(confint(dr_unrec, parm = "drift_sd")$Lower)))
  expect_true(all(is.na(vcov(dr_unrec, se_type = "hyper"))))
  expect_match(paste(summary(dr_unrec)$notes, collapse = " "), "reconstructed", fixed = TRUE)

  # Non-ready drift screens SEs across as.data.frame(), summary(), vcov(), and confint()
  dr_nr <- dr_fresh
  dr_nr$checks$NumericalReady <- FALSE
  sev_nr <- as.data.frame(dr_nr, component = "severity")
  rd_nr <- summary(dr_nr)$rater_drift
  sp_nr <- as.data.frame(dr_nr, component = "steps")
  ft_nr <- as.data.frame(dr_nr, component = "facets")
  expect_true(all(is.na(sev_nr$TotalSE)) && all(is.na(sev_nr$ConditionalSE)) && all(is.na(sev_nr$ChangeSE)))
  expect_true(all(is.na(rd_nr$NetDriftSE)) && all(is.na(rd_nr$LogSigmaSE)))
  expect_true(all(is.na(sp_nr$TotalSE)) && all(is.na(sp_nr$ConditionalSE)))
  expect_true(all(is.na(ft_nr$TotalSE)) && all(is.na(ft_nr$ConditionalSE)))
  expect_true(all(is.na(vcov(dr_nr, se_type = "total"))))
  expect_true(all(is.na(vcov(dr_nr, se_type = "conditional"))))
  expect_true(all(is.na(vcov(dr_nr, se_type = "hyper"))))

  # 4. New-data WLE rejects missing person/score columns instead of falling back to a facet named "Person"/"Score"
  d_id <- d
  names(d_id)[names(d_id) == "Person"] <- "ID"
  names(d_id)[names(d_id) == "Rater"] <- "Person"
  names(d_id)[names(d_id) == "Score"] <- "Y"
  names(d_id)[names(d_id) == "Criterion"] <- "Score"
  f_id <- fit_mfrm(d_id, person = "ID", facets = c("Person", "Score"), score = "Y", method = "JML")
  expect_error(predict(f_id, newdata = d_id[, c("Person", "Score", "Y")], type = "wle"),
               "person \\('ID'\\)")
  expect_error(predict(f_id, newdata = d_id[, c("ID", "Person", "Score")], type = "wle"),
               "score \\('Y'\\)")
  wle_ok <- predict(f_id, newdata = d_id, type = "wle")
  expect_equal(nrow(wle_ok), 48L)

  # C2: Workflow withholds drift on ordinary PCM with non-rater step_facet, and records companion note for GMFRM
  wf_pcm_crit <- mfrm_workflow(d_dr, "Person", c("Rater", "Criterion"), "Score", occasion = "Wave") |>
    step_mfrm_measure(model = "PCM", step_facet = "Criterion", method = "JML")
  expect_null(wf_pcm_crit[["drift"]])
  expect_null(wf_pcm_crit$drift)
  expect_match(summary(wf_pcm_crit)$drift_reason, "Criterion", fixed = TRUE)

  wf_gm_crit <- mfrm_workflow(d_dr, "Person", c("Rater", "Criterion"), "Score", occasion = "Wave") |>
    step_mfrm_measure(model = "GMFRM", step_facet = "Criterion", slope_facet = "Criterion",
                      method = "MML", quad_points = 15L, mml_integration = "fixed")
  expect_s3_class(wf_gm_crit[["drift"]], "mfrm_drift")
  expect_match(summary(wf_gm_crit)$drift_reason, "Companion Markov drift audit", fixed = TRUE)

  # C3: Saved workflow with stale cached Wave agreement failure refreshes agreement on summary()/render_mfrm_report()
  f_core <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", method = "JML")
  d_wave <- transform(d, Wave = ifelse(seq_len(nrow(d)) %% 2L == 0L, "T1", "T2"))
  wf_stale <- mfrm_workflow(d_wave, "Person", c("Rater", "Criterion"), "Score",
                            occasion = "Wave", fit = f_core) |>
    step_mfrm_diagnose()
  wf_stale$diagnostics$report_statistics$agreement <- NULL
  wf_stale$diagnostics$report_statistics$agreement_reason <- "Missing column(s) in `data`: Wave."
  wf_stale$diagnostics$report_statistics$agreement_basis <- "equal_unit_gwet_declared_rubric"
  wf_stale[["drift"]] <- dr_legacy
  s_wf_stale <- summary(wf_stale)
  rt_refreshed <- s_wf_stale$report_tables
  expect_equal(nrow(rt_refreshed[["Expected agreement and model-based kappa"]]), 1L)
  expect_null(rt_refreshed[["Agreement availability"]])
  expect_equal(s_wf_stale$drift$TotalSE, dr_fresh$severity_table$TotalSE, tolerance = 1e-12)
  md_rep <- render_mfrm_report(wf_stale, format = "markdown")
  expect_false(grepl("Missing column", md_rep, fixed = TRUE))

  # C4: interrater_agreement(model_expected = TRUE) requires categories to match the calibrated rubric
  expect_error(interrater_agreement(f_core, categories = seq(1, 4, by = 0.5), model_expected = TRUE),
               "calibrated|calibration rubric")
  ag_match <- interrater_agreement(f_core, categories = 1:4, model_expected = TRUE)
  expect_equal(ag_match$summary$Estimate[ag_match$summary$Metric == "AdjacentAgreement"],
               ag_match$model_expected$ObservedWithinOne, tolerance = 1e-12)

  # Precision: classification_table() preserves tiny ExpectedSum on shifted rubrics {10^9, 10^9 + 1}
  d_bin0 <- transform(d, Score = ifelse(Score >= 3, 1, 0))
  f_b0 <- fit_mfrm(d_bin0, "Person", c("Rater", "Criterion"), "Score", method = "MML",
                   control = list(quad_points = 15L, mml_integration = "fixed"))
  f_b9 <- f_b0
  f_b9$rating_min <- 1000000000L
  f_b9$rating_max <- 1000000001L
  pl1 <- data.frame(Rater = "R01", Criterion = "Content", stringsAsFactors = FALSE)
  c_b0 <- classification_table(f_b0, rating_plan = pl1, cut_scores = 0, score_cuts = 1, theta = -20)
  c_b9 <- classification_table(f_b9, rating_plan = pl1, cut_scores = 0, score_cuts = 1, theta = -20)
  expect_gt(c_b9$table$ExpectedSum[1L], 1e-12)
  expect_equal(c_b9$table$ExpectedSum[1L], c_b0$table$ExpectedSum[1L], tolerance = 1e-15)
})

test_that("dual MML posterior/plug-in fit indices, fit_method controls, rater cards, and threshold sensitivity plots hold", {
  utils::data("mfrmr_example_operational", package = "mfrmr")
  d_op <- mfrmr_example_operational

  # 1. Fixed GH MML: C++ PostInfitMnSq/ZSTD & PostOutfitMnSq/ZSTD match independent R quadrature integration
  f_op <- fit_mfrm(d_op, "Person", c("Rater", "Criterion"), "Score",
                   model = "RSM", method = "MML", population_formula = ~ 1,
                   control = list(quad_points = 41L, mml_integration = "fixed"))
  expect_true(all(is.finite(f_op$facets$PostInfitMnSq)))
  expect_true(all(is.finite(f_op$facets$PostOutfitMnSq)))
  expect_true(all(is.finite(f_op$person$PostInfitMnSq)))
  # RealSE remains anchored to plug-in InfitMnSq
  expect_equal(f_op$facets$RealSE,
               f_op$facets$ModelSE * sqrt(pmax(1, f_op$facets$InfitMnSq)),
               tolerance = 1e-12)
  expect_equal(f_op$person$RealSE,
               f_op$person$ModelSE * sqrt(pmax(1, f_op$person$InfitMnSq)),
               tolerance = 1e-12)

  # Independent Golub-Welsch standard normal Gauss-Hermite verification on f_op (~1)
  enc <- f_op$encoding
  Q <- 41L
  J_gh <- matrix(0, nrow = Q, ncol = Q)
  J_gh[cbind(seq_len(Q - 1L), 2:Q)] <- J_gh[cbind(2:Q, seq_len(Q - 1L))] <- sqrt(seq_len(Q - 1L))
  ev_gh <- eigen(J_gh, symmetric = TRUE)
  ord_gh <- order(ev_gh$values)
  mu_hat <- unname(f_op$population$coefficients[1L])
  sig_hat <- f_op$population$sigma
  nodes <- mu_hat + sig_hat * ev_gh$values[ord_gh]
  log_w <- 2 * log(abs(ev_gh$vectors[1L, ord_gh]))
  P_n <- length(enc$person_levels)
  C_n <- enc$n_cat
  k_seq <- 0:(C_n - 1L)
  base_eta <- numeric(enc$n_obs)
  for (fi in seq_along(enc$base_facets)) {
    fnm <- enc$base_facets[fi]
    sub_f <- f_op$facets[f_op$facets$Facet == fnm, ]
    b_v <- sub_f$Estimate[match(enc$facet_levels[[fi]], sub_f$Level)]
    base_eta <- base_eta + enc$facet_signs[fi] * b_v[enc$facet_mat0[, fi] + 1L]
  }
  ll_p <- matrix(rep(log_w, each = P_n), nrow = P_n, ncol = Q)
  mu_iq <- v_iq <- m4_iq <- res2_iq <- matrix(0, nrow = enc$n_obs, ncol = Q)
  for (i in seq_len(enc$n_obs)) {
    sg <- enc$step_group0[i] + 1L
    lp <- outer(k_seq, nodes + base_eta[i]) - f_op$step_cumulative[sg, ]
    lp <- sweep(lp, 2L, apply(lp, 2L, max), "-")
    pr <- exp(lp); pr <- sweep(pr, 2L, colSums(pr), "/")
    y0 <- enc$score0[i]
    pid <- enc$person0[i] + 1L
    ll_p[pid, ] <- ll_p[pid, ] + log(pmax(pr[y0 + 1L, ], 1e-300))
    m_q <- drop(crossprod(k_seq, pr))
    v_q <- drop(crossprod(k_seq^2, pr)) - m_q^2
    m4_q <- colSums(pr * outer(k_seq, m_q, "-")^4)
    mu_iq[i, ] <- m_q; v_iq[i, ] <- v_q; m4_iq[i, ] <- m4_q
    res2_iq[i, ] <- (y0 - m_q)^2
  }
  ll_p <- ll_p - apply(ll_p, 1L, max)
  h_pq <- exp(ll_p); h_pq <- h_pq / rowSums(h_pq)
  h_obs <- h_pq[enc$person0 + 1L, , drop = FALSE]
  e_res2 <- rowSums(h_obs * res2_iq)
  e_var  <- rowSums(h_obs * v_iq)
  e_std2 <- rowSums(h_obs * (res2_iq / v_iq))
  e_f4in <- rowSums(h_obs * (m4_iq - v_iq^2))
  e_f4out <- rowSums(h_obs * (m4_iq / (v_iq^2) - 1))

  r_lvls <- enc$facet_levels[[1L]]
  r_ids <- enc$facet_mat0[, 1L] + 1L
  ref_post <- do.call(rbind, lapply(seq_along(r_lvls), function(r) {
    idx <- which(r_ids == r)
    inf <- sum(e_res2[idx]) / sum(e_var[idx])
    outf <- sum(e_std2[idx]) / length(idx)
    qi_in <- sqrt(sum(e_f4in[idx])) / sum(e_var[idx])
    qi_out <- sqrt(sum(e_f4out[idx])) / length(idx)
    zin <- pmax(-9, pmin(9, 3 * (inf^(1/3) - 1) / qi_in + qi_in / 3))
    zout <- pmax(-9, pmin(9, 3 * (outf^(1/3) - 1) / qi_out + qi_out / 3))
    data.frame(Infit = inf, InfitZ = zin, Outfit = outf, OutfitZ = zout)
  }))
  cpp_raters <- f_op$facets[f_op$facets$Facet == "Rater", ]
  expect_equal(cpp_raters$PostInfitMnSq, ref_post$Infit, tolerance = 1e-11)
  expect_equal(cpp_raters$PostInfitZSTD, ref_post$InfitZ, tolerance = 1e-10)
  expect_equal(cpp_raters$PostOutfitMnSq, ref_post$Outfit, tolerance = 1e-11)
  expect_equal(cpp_raters$PostOutfitZSTD, ref_post$OutfitZ, tolerance = 1e-10)

  # In sparse design (6 ratings/person), posterior mean Infit sits closer to 1.0 than EAP plug-in
  expect_gt(mean(cpp_raters$PostInfitMnSq), mean(cpp_raters$InfitMnSq) + 0.05)

  # 2. Non-MML estimators keep Post* columns as NA and reject fit_method = "posterior"
  f_jml <- fit_mfrm(d_op, "Person", c("Rater", "Criterion"), "Score", method = "JML")
  expect_true(all(is.na(f_jml$facets$PostInfitMnSq)))
  expect_true(all(is.na(f_jml$person$PostInfitMnSq)))
  expect_error(diagnose_mfrm(f_jml, fit_method = "posterior"), "MML")

  wf_jml <- mfrm_workflow(d_op, "Person", c("Rater", "Criterion"), "Score", fit = f_jml)
  expect_error(step_mfrm_diagnose(wf_jml, fit_method = "posterior"), "MML")
  wf_jml <- step_mfrm_diagnose(wf_jml)
  expect_identical(wf_jml$diagnostics$fit_method, "plugin")

  # 3. Workflow MML defaults to posterior fit_method, supports plugin override, and refreshes legacy labels
  d_low <- d_op
  # Compress R01 scores to central categories 2 & 3 to trigger Below Lower Fit Bound
  d_low$Score[d_low$Rater == "R01"] <- ifelse(d_low$Score[d_low$Rater == "R01"] <= 2L, 2L, 3L)
  wf_mml <- mfrm_workflow(d_low, "Person", c("Rater", "Criterion"), "Score") |>
    step_mfrm_measure(model = "RSM", method = "MML", quad_points = 31L, mml_integration = "fixed") |>
    step_mfrm_diagnose(mnsq_range = c(0.80, 1.20), zstd_limit = 0.0, cut_scores = c(2.2, 2.8))
  expect_identical(wf_mml$diagnostics$fit_method, "posterior")
  rt_post <- tidy(wf_mml, component = "raters")
  expect_true("Below Lower Fit Bound" %in% rt_post$flag)
  expect_false("Muted / Centrality" %in% rt_post$flag)
  expect_true(all(rt_post$fit_basis == "posterior"))
  expect_true(all(is.finite(rt_post$post_infit_mnsq)))

  # Legacy saved workflow with "Muted / Centrality" refreshes cleanly across summary, plot, and report
  wf_legacy <- wf_mml
  wf_legacy$diagnostics$fit_method <- NULL
  wf_legacy$diagnostics$raters$FitBasis <- NULL
  wf_legacy$diagnostics$raters$DiagnosticFlag[1L] <- "Muted / Centrality"
  wf_legacy$diagnostics$raters$RecommendedAction[1L] <- "Review potential central-tendency or halo restriction across criteria."
  s_leg <- summary(wf_legacy)
  expect_identical(s_leg$rater_diagnostics$DiagnosticFlag[1L], "Below Lower Fit Bound")
  expect_match(s_leg$rater_diagnostics$RecommendedAction[1L], "does not by itself establish central tendency")
  p_leg <- plot(wf_legacy, type = "raters", draw = FALSE)
  expect_false("Muted / Centrality" %in% as.character(p_leg$data$DiagnosticFlag))

  # Rater card includes both fit bases, fit rule note, and per-criterion category usage table
  card_md <- render_mfrm_report(wf_mml, rater = "R01", format = "markdown")
  expect_match(card_md, "PostInfit", fixed = TRUE)
  expect_match(card_md, "Category usage by criterion", fixed = TRUE)
  expect_match(card_md, "AllowedMin", fixed = TRUE)
  expect_match(card_md, "TAM::msq.itemfit basis", fixed = TRUE)

  # 4. Fit-threshold & cut-score sensitivity visualizations across palettes (including strict monochrome)
  for (pal in c("okabe_ito", "viridis", "monochrome")) {
    p_fs <- plot(wf_mml, type = "fit_sensitivity", palette = pal, draw = FALSE)
    expect_s3_class(p_fs, "ggplot")
    st_tbl <- attr(p_fs, "sensitivity_table")
    expect_true(is.data.frame(st_tbl) && nrow(st_tbl) > 0L)
    expect_setequal(unique(as.character(st_tbl$FitBasis)), c("Posterior (TAM)", "Plug-in"))

    p_cs <- plot(wf_mml, type = "cut_sensitivity", palette = pal, draw = FALSE)
    expect_s3_class(p_cs, "ggplot")
    ct_tbl <- attr(p_cs, "cut_table")
    expect_true(is.data.frame(ct_tbl) && all(c(2.2, 2.8) %in% round(ct_tbl$CutFairM, 6)))

    p_both <- plot(wf_mml, type = "raters", fit_method = "both",
                   reference_bands = list(c(0.50, 1.50)), palette = pal, draw = FALSE)
    expect_s3_class(p_both, "ggplot")
  }
  # Verify sensitivity_table arithmetic at d = 0.20 ([0.80, 1.20], zstd_limit = 0)
  p_fs0 <- plot(f_op, type = "fit_sensitivity", facet = "Rater", zstd_limit = 0, half_widths = c(0.20, 0.30, 0.50))
  st0 <- attr(p_fs0, "sensitivity_table")
  sub_p20 <- st0[st0$FitBasis == "Posterior (TAM)" & abs(st0$HalfWidth - 0.20) < 1e-9, ]
  expect_equal(sub_p20$FlaggedCount[sub_p20$RuleDirection == "Total Outside (MnSq only)"],
               sum(cpp_raters$PostInfitMnSq < 0.80 | cpp_raters$PostInfitMnSq > 1.20))

  # plot.mfrm_diagnostics also supports fit_sensitivity and reference_bands
  dg_op <- diagnose_mfrm(f_op)
  expect_s3_class(plot(dg_op, facet = "Rater", type = "fit_sensitivity"), "ggplot")
  expect_s3_class(plot(dg_op, facet = "Rater", reference_bands = c(0.50, 1.50), zstd_limit = 2.0), "ggplot")
})

test_that("Cell-factored MML matches independent Gauss-Hermite oracle and 3-step GMFRM nesting holds", {
  utils::data("mfrmr_example_core", package = "mfrmr")
  d <- mfrmr_example_core
  persons <- sort(unique(as.character(d$Person)))
  set.seed(20261128)
  p_cov <- data.frame(
    Person = persons,
    Group = rep(c("A", "B"), length.out = length(persons)),
    ContX = seq(-1, 1, length.out = length(persons)),
    stringsAsFactors = FALSE
  )

  # 1. Independent pure-R Golub-Welsch Gauss-Hermite marginal log-likelihood oracle
  Q_gh <- 31L
  J_gh <- matrix(0, Q_gh, Q_gh)
  sub_d <- sqrt(seq_len(Q_gh - 1L))
  J_gh[cbind(seq_len(Q_gh - 1L), seq_len(Q_gh - 1L) + 1L)] <- sub_d
  J_gh[cbind(seq_len(Q_gh - 1L) + 1L, seq_len(Q_gh - 1L))] <- sub_d
  eg_gh <- eigen(J_gh, symmetric = TRUE)
  ord_gh <- order(eg_gh$values)
  gh <- list(nodes = eg_gh$values[ord_gh], weights = eg_gh$vectors[1L, ord_gh]^2)
  eval_r_mml_ll <- function(fit) {
    enc <- fit$encoding
    P <- enc$n_person
    C <- enc$n_cat
    mu_p <- if (enc$pop_mode == 1L && ncol(enc$pop_X_mat) > 0L) {
      as.numeric(enc$pop_X_mat %*% fit$population$coefficients)
    } else {
      rep(0, P)
    }
    sig <- fit$population$sigma
    f_est <- lapply(seq_along(enc$base_facets), function(f) {
      sub <- fit$facets[fit$facets$Facet == enc$base_facets[f], ]
      sub$Estimate[match(enc$facet_levels[[f]], sub$Level)]
    })
    be <- numeric(enc$n_obs)
    for (f in seq_along(enc$base_facets)) {
      be <- be + enc$facet_signs[f] * f_est[[f]][enc$facet_mat0[, f] + 1L]
    }
    al <- if (!is.null(fit$slopes) && nrow(fit$slopes) > 0L) fit$alpha_obs else rep(1, enc$n_obs)
    sform <- enc$slope_formula %||% 0L
    sc_mat <- fit$step_cumulative
    ll <- 0
    for (p in seq_len(P)) {
      rows <- which(enc$person0 + 1L == p)
      th_q <- mu_p[p] + sig * gh$nodes
      lp_q <- log(gh$weights)
      for (i in rows) {
        sg <- enc$step_group0[i] + 1L
        ag <- enc$step_cat_min[sg]
        bg <- enc$step_cat_max[sg]
        y <- enc$score0[i]
        sc <- sc_mat[sg, ]
        for (q in seq_along(th_q)) {
          ks <- ag:bg
          u <- if (is.null(fit$slopes)) {
            (ks - ag) * (th_q[q] + be[i]) - sc[ks + 1L]
          } else if (sform == 1L) {
            (ks - ag) * (al[i] * th_q[q] + be[i]) - sc[ks + 1L]
          } else {
            al[i] * ((ks - ag) * (th_q[q] + be[i]) - sc[ks + 1L])
          }
          mx <- max(u)
          lz <- mx + log(sum(exp(u - mx)))
          lp_q[q] <- lp_q[q] + enc$weight[i] * (u[y - ag + 1L] - lz)
        }
      }
      mxp <- max(lp_q)
      ll <- ll + mxp + log(sum(exp(lp_q - mxp)))
    }
    ll
  }

  f_rsm <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
                    model = "RSM", method = "MML", population_formula = ~ 1,
                    quad_points = 31L, mml_integration = "fixed")
  f_grp <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
                    model = "PCM", step_facet = "Criterion", method = "MML",
                    population_formula = ~ Group, person_data = p_cov, person_id = "Person",
                    quad_points = 31L, mml_integration = "fixed")
  f_cnt <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
                    model = "PCM", step_facet = "Criterion", method = "MML",
                    population_formula = ~ ContX, person_data = p_cov, person_id = "Person",
                    quad_points = 31L, mml_integration = "fixed")
  f_gc  <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
                    model = "GPCM", step_facet = "Common", slope_facet = "Criterion", method = "MML",
                    population_formula = ~ 1, quad_points = 31L, mml_integration = "fixed")
  f_gp  <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
                    model = "GPCM", step_facet = "Criterion", slope_facet = "Criterion",
                    method = "MML", population_formula = ~ 1, quad_points = 31L, mml_integration = "fixed")

  for (ft in list(f_rsm, f_grp, f_cnt, f_gc, f_gp)) {
    expect_true(ft$converged)
    expect_lte(ft$max_abs_grad, 1e-8)
    expect_equal(ft$loglik, eval_r_mml_ll(ft), tolerance = 1e-11)
  }
  expect_lte(f_rsm$iterations, 45L)

  # 2. 3-model nested chain RSM -> GMFRM(common steps) -> GMFRM(criterion steps)
  cmp3 <- compare_mfrm(f_rsm, f_gc, f_gp, labels = c("RSM", "GMFRM_Common", "GMFRM_Crit"), nested = TRUE)
  expect_identical(cmp3$comparison_basis$nesting_review$relation, "nested")
  expect_identical(cmp3$comparison_basis$lrt_status, "computed")
  expect_identical(nrow(cmp3$lrt), 2L)
  expect_true(all(cmp3$lrt$df > 0L))
  expect_true(all(cmp3$lrt$ChiSq >= -1e-7))
})

test_that("Unobserved step-group categories block readiness and withhold unidentified steps unless constrained", {
  utils::data("mfrmr_example_core", package = "mfrmr")
  d <- mfrmr_example_core
  crits <- sort(unique(as.character(d$Criterion)))
  # Map to 1..3 scale and remove all category-1 observations on the first criterion only
  d$Score <- pmin(3L, d$Score)
  target_crit <- crits[1L]
  d$Score[d$Criterion == target_crit & d$Score == 1L] <- 2L

  for (m in c("JML", "MML", "CML", "JML_jeffreys")) {
    fm <- suppressWarnings(fit_mfrm(
      d, "Person", c("Rater", "Criterion"), "Score",
      model = "PCM", step_facet = "Criterion", method = m,
      population_formula = if (m == "MML") ~ 1 else NULL,
      rating_min = 1L, rating_max = 3L,
      control = if (m == "MML") list(quad_points = 31L, mml_integration = "fixed") else list(xtreme = 0.3, whexact = TRUE)
    ))
    rdy <- summary(fm)$readiness
    expect_false(rdy$ready)
    expect_true("unobserved_step_category" %in% rdy$reason_codes)
    if (m %in% c("JML", "MML", "CML")) {
      expect_true("structural_likelihood_boundary" %in% rdy$reason_codes)
    }
    st_tgt <- fm$steps[fm$steps$ScaleLevel == target_crit, ]
    st_oth <- fm$steps[fm$steps$ScaleLevel != target_crit, ]
    expect_true(all(!st_tgt$Identified))
    expect_true(all(is.na(st_tgt$Estimate) & is.na(st_tgt$ModelSE)))
    expect_true(all(st_oth$Identified & is.finite(st_oth$Estimate)))
    expect_error(confint(fm, component = "steps"), "unobserved_step_category")
    td_st <- tidy(fm, component = "steps")
    expect_true(all(is.na(td_st$estimate[td_st$scale == target_crit])))
    expect_true(all(is.na(td_st$conf.low) & is.na(td_st$conf.high)))
  }

  # Also verify pre-fix saved fit objects with stale boundary_audit and unscreened steps are caught
  f_pre <- suppressWarnings(fit_mfrm(
    d, "Person", c("Rater", "Criterion"), "Score",
    model = "PCM", step_facet = "Criterion", method = "JML",
    rating_min = 1L, rating_max = 3L
  ))
  f_pre$boundary_audit <- list(detected = FALSE, status = "not_applicable")
  f_pre$step_support_audit <- NULL
  f_pre$steps$Estimate[f_pre$steps$ScaleLevel == target_crit] <- c(-16.5, 16.5)
  f_pre$steps$ModelSE[f_pre$steps$ScaleLevel == target_crit] <- c(42000, 0.07)
  expect_false(summary(f_pre)$readiness$ready)
  expect_true(all(c("structural_likelihood_boundary", "unobserved_step_category") %in% summary(f_pre)$readiness$reason_codes))
  expect_true(all(is.na(summary(f_pre)$steps$Estimate[summary(f_pre)$steps$ScaleLevel == target_crit])))
  expect_true(all(is.na(coef(f_pre, "steps")[grepl(paste0("^", target_crit, ":"), names(coef(f_pre, "steps")))])))
  expect_error(confint(f_pre, component = "steps"), "not ready")

  status <- .mfrm_parameter_table(f_pre, "steps", "model", .95)
  expect_true(all(status$Status[status$Level == target_crit] == "Unidentified"))
  expect_true(all(is.na(status$Lower)))
  if (requireNamespace("plotly", quietly = TRUE)) {
    context <- d[match(target_crit, d$Criterion), c("Rater", "Criterion")]
    widget <- plot(f_pre, "category_curves", newdata = context, interactive = TRUE)
    expect_match(paste(attr(widget, "mfrm_notes"), collapse = " "), target_crit)
    expect_false(any(vapply(widget$x$data, function(tr) length(tr$y) > 0L, logical(1))))
  }
  for (obj in list(f_pre, fm)) {
    expect_true(all(is.na(as.data.frame(obj, component = "steps")$Estimate[obj$steps$ScaleLevel == target_crit])))
    wright <- plot(obj, type = "wright")
    points <- Filter(function(layer) inherits(layer$geom, "GeomPoint"), wright$layers)[[1]]$data
    expect_false(any(startsWith(points$Element, paste0(target_crit, ":Step_"))))
    for (type in c("steps", "category_curves")) {
      curves <- plot(obj, type = type)
      expect_setequal(unique(curves$data$ScaleGroup), setdiff(crits, target_crit))
      expect_true(all(vapply(curves$layers, function(layer)
        !is.data.frame(layer$data) || !target_crit %in% layer$data$ScaleGroup, logical(1))))
      expect_match(paste(attr(curves, "mfrm_notes"), collapse = " "), target_crit)
    }
  }

  # Identifying constraints rescue readiness and intervals:
  # (a) Explicit category_support [2, 3] on target_crit
  cs_ok <- data.frame(
    Level = crits,
    Min = ifelse(crits == target_crit, 2L, 1L),
    Max = rep(3L, length(crits)),
    stringsAsFactors = FALSE
  )
  f_cs <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
                   model = "PCM", step_facet = "Criterion", method = "JML",
                   rating_min = 1L, rating_max = 3L, category_support = cs_ok)
  expect_true(summary(f_cs)$readiness$ready)
  ci_cs <- confint(f_cs, component = "steps")
  expect_true(all(is.na(ci_cs[f_cs$steps$ScaleLevel == target_crit, ])))
  expect_true(all(is.finite(ci_cs[f_cs$steps$ScaleLevel != target_crit, ])))

  # (b) Shared step_constraints tying target_crit 1->2 to an observed criterion 1->2
  sc_ok <- data.frame(Level = crits[1:2], From = c(1L, 1L), To = c(2L, 2L), Group = c("sh1", "sh1"))
  f_sc <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
                   model = "PCM", step_facet = "Criterion", method = "JML",
                   rating_min = 1L, rating_max = 3L, step_constraints = sc_ok)
  expect_true(summary(f_sc)$readiness$ready)
  expect_true(all(is.finite(confint(f_sc, component = "steps"))))
})

test_that("fixed population and anchored items identify a finite RSM step with an empty endpoint", {
  d <- expand.grid(Person = seq_len(32), Item = c("A", "B"), stringsAsFactors = FALSE)
  d$Score <- c(rep(c(2, 2, 3, 3), 8), rep(c(2, 3, 2, 3), 8))
  fit <- fit_mfrm(d, "Person", "Item", "Score", model = "RSM", method = "MML",
                  rating_min = 1, rating_max = 3,
                  anchors = data.frame(Facet = "Item", Level = c("A", "B"), Anchor = 0),
                  control = list(quad_points = 61L, mml_integration = "fixed"))
  # Each of the four ordered response pairs occurs eight times.
  loglik <- function(step) {
    p <- function(theta, category) {
      w <- cbind(1, exp(theta - step), exp(2 * theta))
      w[, category] / rowSums(w)
    }
    pair <- function(a, b) log(stats::integrate(function(theta)
      stats::dnorm(theta) * p(theta, a) * p(theta, b), -10, 10, rel.tol = 1e-11)$value)
    8 * (pair(2, 2) + 2 * pair(2, 3) + pair(3, 3))
  }
  t <- stats::optimize(loglik, c(-8, 8), maximum = TRUE, tol = 1e-9)$maximum
  h <- 1e-4
  se <- h / sqrt(2 * loglik(t) - loglik(t + h) - loglik(t - h))
  expect_true(summary(fit)$readiness$ready)
  expect_equal(fit$steps$Estimate, c(t, -t), tolerance = 1e-6)
  expect_equal(fit$steps$ModelSE, rep(se, 2), tolerance = 1e-5)
  expect_true(all(is.finite(confint(fit, component = "steps"))))

  anchored <- .mfrm_parameter_table(fit, "facets", "model", .95)
  expect_equal(anchored$Status, rep("Fixed by constraint", 2))
  expect_true(all(anchored$Estimate == 0 & is.na(anchored$Lower)))

  # Previous 0.3.3 candidates masked both the saved table and covariance.
  legacy <- fit
  legacy$step_support_audit$version <- NULL
  legacy$step_support_audit$unidentified_step[] <- TRUE
  legacy$steps[, c("Estimate", "ModelSE", "SandwichSE")] <- NA_real_
  legacy$steps$Identified <- FALSE
  legacy$step_covariance_model[] <- legacy$step_covariance_sandwich[] <- NA_real_
  expect_equal(summary(legacy)$steps, fit$steps)
  for (kind in c("model", "sandwich")) {
    expect_equal(vcov(legacy, component = "steps", se_type = kind),
                 vcov(fit, component = "steps", se_type = kind))
  }
  expect_equal(confint(legacy, component = "steps"), confint(fit, component = "steps"))
  expect_equal(plot(legacy, type = "steps")$data, plot(fit, type = "steps")$data)

  # With the middle category absent, sending its probability to zero is
  # feasible even with all locations fixed.
  d$Score[d$Score == 2] <- 1
  boundary <- suppressWarnings(fit_mfrm(d, "Person", "Item", "Score", model = "RSM", method = "MML",
      rating_min = 1, rating_max = 3, anchors = data.frame(Facet = "Item", Level = c("A", "B"), Anchor = 0)))
  expect_false(summary(boundary)$readiness$ready)
  blank <- plot(boundary, type = "category_curves")
  expect_match(paste(attr(blank, "mfrm_notes"), collapse = " "), "Common")
  expect_length(blank$layers, 0L)
  expect_silent(ggplot2::ggplot_build(blank))
})

test_that("ordinary JML step Wald intervals use the constrained covariance on new and saved fits", {
  d <- load_mfrmr_data("example_core")
  d$Score <- pmin(3, d$Score)
  fit <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", model = "PCM", method = "JML")
  legacy <- fit
  legacy$step_support_audit <- NULL
  legacy$steps$ModelSE <- legacy$steps$TransitionSE
  legacy$steps$TransitionSE <- NULL
  for (obj in list(fit, legacy)) {
    st <- as.data.frame(obj, component = "steps")
    se <- unname(sqrt(diag(vcov(obj, component = "steps"))))
    ci <- confint(obj, component = "steps")
    expect_true(summary(obj)$readiness$ready)
    expect_equal(st$ModelSE, se)
    expect_equal(tidy(obj, component = "steps")$std.error, se)
    expect_equal(unname(ci[, 2L]), st$Estimate + qnorm(.975) * se)
    expect_equal(unname(ci[1L, ]), -rev(unname(ci[2L, ])))
    expect_equal(st$TransitionSE, fit$steps$TransitionSE)
    expect_gt(abs(st$TransitionSE[1] - se[1]), .01)
  }
})

test_that("Rater plot honors custom thresholds on diagnosed workflows and handles unavailable ZSTD consistently", {
  utils::data("mfrmr_example_core", package = "mfrmr")
  wf <- mfrm_workflow(mfrmr_example_core, "Person", c("Rater", "Criterion"), "Score") |>
    step_mfrm_measure(model = "RSM", method = "MML") |>
    step_mfrm_diagnose()

  p_custom <- plot(wf, type = "raters", mnsq_range = c(0.95, 1.05), zstd_limit = 0, draw = FALSE)
  wf_custom <- step_mfrm_diagnose(wf, mnsq_range = c(0.95, 1.05), zstd_limit = 0)
  expect_identical(
    as.character(p_custom$data$DiagnosticFlag[match(wf_custom$diagnostics$raters$Level, p_custom$data$Level)]),
    as.character(wf_custom$diagnostics$raters$DiagnosticFlag)
  )
  expect_identical(as.character(p_custom$data$DiagnosticFlag[p_custom$data$Level == "R01"]), "Misfit (Unpredictable)")
  expect_identical(as.character(p_custom$data$DiagnosticFlag[p_custom$data$Level == "R02"]), "Below Lower Fit Bound")

  p_pw_custom <- plot(wf, type = "pathway", facet = "Rater", mnsq_range = c(0.95, 1.05), zstd_limit = 0, draw = FALSE)
  expect_identical(as.character(p_pw_custom$data$FitBand[p_pw_custom$data$Level == "R01"]), "Misfit (Unpredictable)")
  expect_identical(as.character(p_pw_custom$data$FitBand[p_pw_custom$data$Level == "R02"]), "Below Lower Fit Bound")

  # Unavailable ZSTD (NA) with MnSq = 1.4 must never be reported as satisfying joint MnSq + ZSTD
  wf_na <- wf
  r1_row <- wf_na$fit$facets$Facet == "Rater" & wf_na$fit$facets$Level == "R01"
  wf_na$fit$facets$PostInfitMnSq[r1_row] <- 1.40
  wf_na$fit$facets$PostInfitZSTD[r1_row] <- NA_real_
  wf_na <- step_mfrm_diagnose(wf_na, mnsq_range = c(0.70, 1.30), zstd_limit = 2.0)

  expect_identical(wf_na$diagnostics$raters$DiagnosticFlag[wf_na$diagnostics$raters$Level == "R01"],
                   "Outside MnSq (ZSTD Unavailable)")
  p_na_rt <- plot(wf_na, type = "raters", draw = FALSE)
  expect_identical(as.character(p_na_rt$data$DiagnosticFlag[p_na_rt$data$Level == "R01"]),
                   "Outside MnSq (ZSTD Unavailable)")
  p_na_pw <- plot(wf_na, type = "pathway", facet = "Rater", zstd_limit = 2.0, draw = FALSE)
  expect_identical(as.character(p_na_pw$data$FitBand[p_na_pw$data$Level == "R01"]),
                   "Outside MnSq (ZSTD Unavailable)")
  card_na <- render_mfrm_report(wf_na, rater = "R01", format = "markdown")
  expect_match(card_na, "Outside MnSq (ZSTD Unavailable)", fixed = TRUE)
  expect_match(card_na, "ZSTD is unavailable", fixed = TRUE)

  p_na_fs <- plot(wf_na, type = "fit_sensitivity", half_widths = c(0.20, 0.30, 0.45), draw = FALSE)
  st_na <- attr(p_na_fs, "sensitivity_table")
  sub30 <- st_na[st_na$FitBasis == "Posterior (TAM)" & abs(st_na$HalfWidth - 0.30) < 1e-9, ]
  expect_true(is.na(sub30$FlaggedCount[sub30$RuleDirection == "Above Upper (MnSq + |ZSTD|)"]))
  expect_identical(sub30$UnresolvedZSTDCount[sub30$RuleDirection == "Above Upper (MnSq + |ZSTD|)"], 1L)
  expect_identical(sub30$FlaggedCount[sub30$RuleDirection == "Total Outside (MnSq only)"], 1L)
  sub45 <- st_na[st_na$FitBasis == "Posterior (TAM)" & abs(st_na$HalfWidth - 0.45) < 1e-9, ]
  expect_identical(sub45$FlaggedCount[sub45$RuleDirection == "Above Upper (MnSq + |ZSTD|)"], 0L)
})

test_that("missing active Infit is unavailable in rater cards, plots and workflow counts", {
  d <- load_mfrmr_data("example_core")
  wf <- mfrm_workflow(d, "Person", c("Rater", "Criterion"), "Score") |>
    step_mfrm_measure(model = "RSM", method = "MML")
  r <- wf$fit$facets$Facet == "Rater"
  for (basis in c("posterior", "plugin")) {
    w <- wf
    col <- if (basis == "posterior") "PostInfitMnSq" else "InfitMnSq"
    w$fit$facets[[col]][which(r)[1]] <- NA_real_
    w <- step_mfrm_diagnose(w, fit_method = basis)
    expect_identical(w$diagnostics$raters$DiagnosticFlag[1], "Infit MnSq unavailable")
    expect_equal(glance(w)$unavailable_raters, 1L)
    card <- render_mfrm_report(w, rater = "R01", format = "markdown")
    expect_match(card, "Infit MnSq unavailable")
    expect_false(grepl("Maintain current rubric calibration", card, fixed = TRUE))
    p <- plot(w, type = "raters", draw = FALSE)
    expect_false("R01" %in% p$data$Level)
    expect_match(paste(attr(p, "mfrm_notes"), collapse = " "), "R01")

    w$fit$facets[[col]][r] <- NA_real_
    w <- step_mfrm_diagnose(w, fit_method = basis)
    expect_true(is.na(glance(w)$flagged_raters))
    expect_equal(glance(w)$unavailable_raters, sum(r))
    p <- plot(w, type = "fit_sensitivity", fit_method = basis, draw = FALSE)
    counts <- attr(p, "sensitivity_table")
    expect_true(all(is.na(counts$FlaggedCount) & counts$TotalElements == 0L &
                      counts$UnavailableMnSqCount == sum(r)))
    expect_silent(ggplot2::ggplotGrob(p))
    rp <- plot(w, type = "raters", fit_method = basis, draw = FALSE)
    expect_equal(nrow(rp$data), 0L)
    expect_match(paste(attr(rp, "mfrm_notes"), collapse = " "), "R01")
    expect_silent(ggplot2::ggplotGrob(rp))
    cmp <- plot(w, type = "raters", fit_method = "both", draw = FALSE)
    expect_equal(as.character(unique(cmp$data$FitBasis)), if (basis == "posterior") "Plug-in" else "Posterior (TAM)")
    expect_silent(ggplot2::ggplotGrob(cmp))
  }
  w$fit$facets$PostInfitMnSq[r] <- NA_real_
  w <- step_mfrm_diagnose(w)
  both <- plot(w, type = "raters", fit_method = "both", draw = FALSE)
  expect_equal(nrow(both$data), 0L)
  expect_silent(ggplot2::ggplotGrob(both))
})
