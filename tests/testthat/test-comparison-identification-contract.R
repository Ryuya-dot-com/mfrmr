# Repository-only mathematical qualification; no public fitting API is added.
cid <- new.env(parent = asNamespace("mfrmr"))
sys.source(test_path("..", "..", "inst", "validation",
                     "comparison-identification-rsm-pcm.R"), cid)

test_that("RSM and PCM maps distinguish full, partial and unidentified targets", {
  for (model in c("RSM", "PCM")) {
    states <- list()
    for (design in c("full", "missing", "repaired", "separate", "bridge_A", "bridge_both", "neutral")) {
      x <- cid$cid_map(cid$cid_data(design), model)
      maps <- cid$cid_linear_maps(x)
      expect_equal(unname(as.matrix(x$design)), unname(maps$design), tolerance = 1e-14)
      audit <- cid$cid_target_audit(x$design, maps$targets)
      states[[design]] <- setNames(audit$table$State, audit$table$Target)
      if (states[[design]]["relative_DFF_R1"] == "target_unidentified") {
        w <- cid$cid_witness(x, maps, audit, "relative_DFF_R1")
        expect_lt(w$probability_difference, 1e-12)
        expect_equal(mfrm_loglik_jml(w$plus, x$idx, x$config, x$sizes),
                     mfrm_loglik_jml(w$minus, x$idx, x$config, x$sizes), tolerance = 1e-10)
      }
    }
    expect_true(all(states$full == "all_parameters_identified"))
    expect_identical(states$repaired, states$full)
    expect_identical(states$bridge_both, states$full)
    expect_identical(unname(states$missing["DFF_R1_minus_R2"]), "target_identified_only")
    expect_identical(unname(states$missing["relative_DFF_R1"]), "target_unidentified")
    for (design in c("separate", "bridge_A", "neutral")) {
      expect_identical(unname(states[[design]]["DFF_R1_minus_R2"]), "target_unidentified")
      expect_identical(unname(states[[design]]["matched_panel_A_R1_minus_R2"]), "target_identified_only")
    }
  }
})

test_that("equivalent coordinates, ordering and score orientation retain the declared target", {
  for (model in c("RSM", "PCM")) {
    d <- cid$cid_data("missing")
    x <- cid$cid_map(d, model)
    maps <- cid$cid_linear_maps(x)
    original <- cid$cid_target_audit(x$design, maps$targets)$table
    n <- ncol(x$design)
    change <- diag(seq_len(n) / n + .5); change[1, 2] <- .4
    changed <- cid$cid_target_audit(x$design %*% change, maps$targets %*% change)$table
    expect_identical(changed$State, original$State)
    d <- d[rev(seq_len(nrow(d))), ]
    for (f in c("Person", "Rater", "Criterion", "School")) {
      d[[f]] <- factor(d[[f]], levels = rev(sort(unique(d[[f]]))))
    }
    reordered <- cid$cid_map(d, model)
    rmaps <- cid$cid_linear_maps(reordered)
    result <- cid$cid_target_audit(reordered$design, rmaps$targets)$table
    expect_identical(result$State[match(original$Target, result$Target)], original$State)
    positive <- cid$cid_map(cid$cid_data("missing"), model, positive_facets = "Rater")
    pmaps <- cid$cid_linear_maps(positive)
    expect_equal(unname(as.matrix(positive$design)), unname(pmaps$design), tolerance = 1e-14)
    expect_identical(cid$cid_target_audit(positive$design, pmaps$targets)$table$State,
                     original$State)
  }
})

test_that("step ownership, empty observed categories and external anchors remain distinct", {
  d <- cid$cid_data("missing")
  for (owner in c("Criterion", "Rater", "School")) {
    x <- cid$cid_map(d, "PCM", step_facet = owner)
    maps <- cid$cid_linear_maps(x)
    expect_equal(unname(as.matrix(x$design)), unname(maps$design), tolerance = 1e-14)
    par <- seq_along(maps$zero) / 20 - .2
    logits <- cid$cid_logits(x, par)
    # The same performance/criterion cancels ability; Rater-owned steps must
    # enter a category-specific response comparison even at fixed ability.
    dprep <- x$prep$data
    rows <- match(c("R1", "R2"), as.character(dprep$Rater[
      dprep$Person == "P1" & dprep$Criterion == "C1"]))
    selected <- which(dprep$Person == "P1" & dprep$Criterion == "C1")[rows]
    expected <- logits[selected[1], ] - logits[selected[2], ]
    actual <- cid$cid_targets(x, par)[paste0("adjacent_A_R1_minus_R2_step", 1:2)]
    expect_equal(unname(actual), unname(expected), tolerance = 1e-14)
    absent <- d; absent$Score[absent$Score == 1L] <- 0L
    y <- cid$cid_map(absent, "PCM", step_facet = owner)
    expect_equal(as.matrix(y$design), as.matrix(x$design), tolerance = 0)
  }
  anchored <- cid$cid_map(d, anchors = data.frame(Facet="Rater", Level="R4", Anchor=.2))
  amap <- cid$cid_linear_maps(anchored)
  expect_gt(max(abs(cid$cid_logits(anchored, amap$zero))), 0)
  expect_equal(unname(as.matrix(anchored$design)), unname(amap$design), tolerance = 1e-14)
  expect_true(all(cid$cid_target_audit(anchored$design, amap$targets)$table$State ==
                    "all_parameters_identified"))
})

test_that("common-population and school-population maps answer different assumptions", {
  for (model in c("RSM", "PCM")) {
    fixed <- cid$cid_map(cid$cid_data("missing"), model, "MML")
    school <- cid$cid_map(cid$cid_data("missing"), model, "MML", population_formula = ~School)
    fmaps <- cid$cid_linear_maps(fixed); smaps <- cid$cid_linear_maps(school)
    expect_false("population_A_minus_B" %in% rownames(fmaps$targets))
    expect_true("population_A_minus_B" %in% rownames(smaps$targets))
    fa <- cid$cid_target_audit(fixed$design, fmaps$targets)
    sa <- cid$cid_target_audit(school$design, smaps$targets)
    expect_equal(fa$rank, fa$dimension)
    expect_equal(sa$rank, sa$dimension - 1L)
    for (target in c("relative_DFF_R1", "population_A_minus_B")) {
      w <- cid$cid_witness(school, smaps, sa, target)
      for (z in c(-3, -.5, 0, .7, 3)) {
        expect_equal(cid$cid_probabilities(cid$cid_logits(school, w$plus, z)),
                     cid$cid_probabilities(cid$cid_logits(school, w$minus, z)), tolerance = 1e-12)
      }
    }
  }
})

test_that("full null-space checks retain directions omitted from diagnostic displays", {
  design <- cbind(diag(3), matrix(0, 3, 10))
  targets <- rbind(observed = c(1, rep(0, 12)), missing_last = c(rep(0, 12), 1))
  colnames(targets) <- colnames(design) <- paste0("v", 1:13)
  audit <- cid$cid_target_audit(design, targets)
  expect_identical(audit$table$State, c("target_identified_only", "target_unidentified"))
  expect_equal(ncol(audit$null_basis), 10)
})

test_that("partial target qualification never bypasses the public full-fit guard", {
  for (model in c("RSM", "PCM")) {
    condition <- tryCatch(fit_mfrm(cid$cid_data("missing"), person = "Person",
      facets = c("Rater", "Criterion", "School"), score = "Score",
      rating_min = 0, rating_max = 2, model = model, method = "JML",
      step_facet = if (model == "PCM") "Criterion" else NULL,
      dummy_facets = "School", facet_interactions = "Rater:School",
      interaction_policy = "silent"), error = identity)
    expect_s3_class(condition, "mfrmr_estimability_error")
    expect_match(conditionMessage(condition), "Optimization was not run", fixed = TRUE)
    expect_equal(condition$estimability$design$nullity, 1L)
  }
})

test_that("public MML preparation produces the qualified response and population maps", {
  captured <- NULL
  local_mocked_bindings(audit_mfrm_estimability = function(prep, idx, config, sizes) {
    captured <<- list(prep = prep, idx = idx, config = config, sizes = sizes,
      adjacent = mfrmr_estimability_adjacent_design(prep, idx, config, sizes))
    stop("Captured before fitting", call. = FALSE)
  }, .package = "mfrmr")
  for (model in c("RSM", "PCM")) for (population in c("fixed", "school")) {
    d <- cid$cid_data("missing")
    formula <- if (population == "school") ~School else NULL
    expected <- cid$cid_map(d, model, "MML", population_formula = formula)
    expect_error(suppressWarnings(fit_mfrm(d, person = "Person",
      facets = c("Rater", "Criterion", "School"), score = "Score",
      rating_min = 0, rating_max = 2, model = model, method = "MML",
      step_facet = if (model == "PCM") "Criterion" else NULL,
      dummy_facets = "School", facet_interactions = "Rater:School",
      population_formula = formula, person_data = unique(d[c("Person", "School")]),
      interaction_policy = "silent")), "Captured before fitting", fixed = TRUE)
    expect_identical(captured$adjacent$design, expected$design)
    expect_identical(captured$adjacent$map, expected$map)
    expect_equal(cid$cid_logits(captured, rep(.1, sum(unlist(captured$sizes)))),
                 cid$cid_logits(expected, rep(.1, sum(unlist(expected$sizes)))))
  }
})
