conquest_contract_fixture <- local({
  cached <- NULL
  function() {
    if (is.null(cached)) {
      fit <- mfrmr:::resolve_conquest_overlap_input()$fit
      cached <<- list(fit = fit, bundle = build_conquest_overlap_bundle(fit))
    }
    cached
  }
})

test_that("ConQuest export rejects model changes absent from its command", {
  fit <- conquest_contract_fixture()$fit
  facet <- fit$config$facet_names[1]
  expect_no_error(build_conquest_overlap_bundle(fit))
  for (kind in c("anchor", "group", "uncentered", "dummy", "shrinkage", "step")) {
    bad <- fit
    if (kind == "anchor") bad$config$facet_specs[[facet]]$anchors[1] <- .7
    if (kind == "group") bad$config$facet_specs[[facet]]$groups[1:2] <- "G"
    if (kind == "uncentered") bad$config$facet_specs[[facet]]$centered <- FALSE
    if (kind == "dummy") bad$config$dummy_facets <- facet
    if (kind == "shrinkage") bad$config$facet_shrinkage <- "ridge"
    if (kind == "step") bad$config$step_specs[[1]]$target <- .5
    expect_error(build_conquest_overlap_bundle(bad), "ConQuest overlap requires", info = kind)
  }
  bad <- fit
  bad$config$facet_signs[[facet]] <- 1
  expect_error(build_conquest_overlap_bundle(bad), "difficulty-oriented")
  bad <- fit
  bad$population$design_columns <- "X"
  bad$population$coefficients <- bad$population$coefficients["X"]
  expect_error(build_conquest_overlap_bundle(bad), "requires an intercept")
  bad <- fit
  bad$config$n_cat <- 3L
  bad$config$rating_max <- 2L
  bad$prep$data$Score <- 2 * bad$prep$data$Score
  expect_error(build_conquest_overlap_bundle(bad), "requires binary responses")
  for (value in c(NA_real_, Inf, 2)) {
    bad <- fit
    bad$prep$data$Weight[1] <- value
    expect_error(build_conquest_overlap_bundle(bad), "unit weights")
  }
})

test_that("ConQuest partial comparisons use the same centering set", {
  bundle <- conquest_contract_fixture()$bundle
  # Independent three-item example; full-set center is zero.
  bundle$item_map <- data.frame(ResponseVar = c("I001", "I002", "I003"), OriginalLevel = c("a", "b", "c"))
  bundle$mfrmr_item_estimates <- data.frame(Level = c("a", "b", "c"),
    Estimate = c(-1, 0, 1), ResponseVar = bundle$item_map$ResponseVar, CenteredEstimate = c(-1, 0, 1))
  review <- function(est, ids = bundle$item_map$ResponseVar[seq_along(est)]) {
    review_conquest_overlap(bundle, bundle$mfrmr_population,
      data.frame(ItemID = ids, Estimate = est), bundle$mfrmr_case_eap)
  }
  full <- review(c(-1, 0, 1))
  expect_equal(full$overall$ItemCenteredMae, 0)
  partial <- review(c(-1, 0))
  expect_equal(partial$overall$ItemCenteredMae, 0)
  expect_equal(partial$overall$ItemCenteringRows, 2L)
  expect_equal(partial$overall$AttentionMissing, 1L)
  tab <- partial$item_comparison
  expect_equal(tab$MfrmrCentered[match(c("I001", "I002"), tab$ResponseVar)], c(-.5, .5))
  expect_equal(tab$CenteredEstimate[match(c("I001", "I002"), tab$ResponseVar)], c(-1, 0))
  expect_equal(review(c(4, 5))$overall$ItemCenteredMae, 0)
  expect_equal(review(c(-1, .4))$overall$ItemCenteredMae, .2)
  single <- review(-1)
  expect_equal(single$overall$ItemRowsCompared, 0L)
  expect_true(is.na(single$overall$ItemCenteredMae))
  expect_true("InsufficientItemsForCentering" %in% single$item_comparison$Status)
  none <- review(numeric())
  expect_true(is.na(none$overall$ItemCenteredMae))
  nonfinite <- review(c(-1, 0, Inf))
  expect_equal(nonfinite$overall$ItemCenteredMae, 0)
  expect_equal(nonfinite$overall$AttentionNonNumeric, 1L)
  norm <- normalize_conquest_overlap_tables(bundle$mfrmr_population,
    data.frame(ItemID = bundle$item_map$ResponseVar, Estimate = c(-1, 0, Inf)), bundle$mfrmr_case_eap)
  norm$conquest_item_estimates$EstimateNonNumeric <- FALSE
  expect_equal(review_conquest_overlap(bundle, norm)$overall$AttentionNonNumeric, 1L)
})

test_that("ConQuest native CSV coordinates are validated before labeling", {
  bundle <- conquest_contract_fixture()$bundle
  directory <- withr::local_tempdir()
  items <- bundle$mfrmr_item_estimates
  coefficients <- bundle$mfrmr_population$Estimate[bundle$mfrmr_population$Parameter != "sigma2"]
  valid <- list(
    parameters = data.frame(P = seq_len(nrow(items) - 1L), Estimate = items$Estimate[-nrow(items)]),
    regression = data.frame(Dimension = 1L, Regressor = 1:2, Estimate = coefficients),
    covariance = data.frame(Dim1 = 1L, Dim2 = 1L, Covariance = .5),
    cases = data.frame(PID = bundle$mfrmr_case_eap$Person, EAP_1 = bundle$mfrmr_case_eap$Estimate))
  normalize <- function(tables = valid) {
    paths <- file.path(directory, paste0(names(tables), ".csv"))
    for (i in seq_along(paths)) utils::write.csv(tables[[i]], paths[i], row.names = FALSE)
    normalize_conquest_overlap_exports(bundle, paths[1], paths[2], paths[3], paths[4])
  }
  normalized <- normalize()
  expect_equal(normalized$conquest_item_estimates$Estimate, items$Estimate, tolerance = 1e-10)
  reordered <- valid
  reordered$parameters <- valid$parameters[nrow(valid$parameters):1, ]
  reordered$regression <- valid$regression[2:1, ]
  expect_equal(normalize(reordered)$conquest_population, normalized$conquest_population)
  for (indices in list(c(1, 1), c("bad", "id"), c(900, 100), c(1, 2.75), c(0, 1), c(1, NA), c(1, Inf))) {
    bad <- valid
    bad$regression$Regressor <- indices
    expect_error(normalize(bad), "regression_file")
  }
  for (value in c(1.75, 0, NA_real_, Inf)) {
    bad <- valid
    bad$parameters$P[1] <- value
    expect_error(normalize(bad), "parameter_file")
  }
  for (entry in list(c("regression", "Dimension"), c("covariance", "Dim1"), c("covariance", "Dim2"))) {
    bad <- valid
    bad[[entry[1]]][[entry[2]]][1] <- 2
    expect_error(normalize(bad), "dimension 1")
  }
  bad <- valid
  bad$covariance$Covariance <- -.5
  expect_error(normalize(bad), "nonnegative")
  bad$covariance$Covariance <- 0
  expect_equal(tail(normalize(bad)$conquest_population$Estimate, 1), 0)
})

test_that("ConQuest command and saved metadata declare independent scoring controls", {
  bundle <- conquest_contract_fixture()$bundle
  expect_true(startsWith(bundle$conquest_command, "reset;\nset "))
  for (command in c("lconstraints=items", "exit_on_error=yes", "p_nodes=2000", "seed=2", "codes 0,1;", "fit=no", "stderr=quick")) {
    expect_match(bundle$conquest_command, command, fixed = TRUE)
  }
  expect_identical(bundle$summary$ConQuestPosteriorNodes, 2000L)
  expect_identical(bundle$summary$ConQuestSeed, 2L)
  expect_equal(bundle$settings$Value[bundle$settings$Setting == "conquest_p_nodes"], "2000")
  path <- withr::local_tempfile(fileext = ".rds")
  saveRDS(bundle, path)
  expect_identical(readRDS(path)$conquest_command, bundle$conquest_command)
  expect_match(paste(summary(readRDS(path))$notes, collapse = " "), "p_nodes=2000", fixed = TRUE)
})

conquest_followup_exports <- function(bundle, directory) {
  items <- bundle$mfrmr_item_estimates
  tables <- list(
    parameters = data.frame(P = seq_len(nrow(items)-1L), Estimate = items$Estimate[-nrow(items)],
      Label = paste("item", tolower(items$ResponseVar[-nrow(items)]))),
    regression = data.frame(Dimension = 1L, Regressor = 1:2,
      Estimate = bundle$mfrmr_population$Estimate[bundle$mfrmr_population$Parameter != "sigma2"]),
    covariance = data.frame(Dim1 = 1L, Dim2 = 1L, Covariance = .5),
    cases = data.frame(PID = bundle$person_map$ConQuestPID %||% bundle$mfrmr_case_eap$Person,
      EAP_1 = bundle$mfrmr_case_eap$Estimate))
  paths <- file.path(directory, paste0(names(tables), ".csv"))
  for (i in seq_along(paths)) write.csv(tables[[i]], paths[i], row.names = FALSE)
  paths
}

test_that("ConQuest files preserve numeric-looking and literal NA identifiers", {
  b <- conquest_contract_fixture()$bundle
  b$person_map <- NULL # Legacy exports used original IDs directly.
  d <- withr::local_tempdir()
  for (ids in list(sprintf("%03d", 1:60), paste0("123456789012345", sprintf("%03d", 1:60)),
                   c("NA", sprintf("P%03d", 2:60)))) {
    b$mfrmr_case_eap$Person <- ids
    paths <- conquest_followup_exports(b, d)
    n <- do.call(normalize_conquest_overlap_exports, c(list(bundle = b), as.list(paths)))
    expect_identical(n$conquest_case_eap$Person, ids)
    r <- review_conquest_overlap(b, n, conquest_location_shift = 0)
    expect_equal(r$overall$CaseRowsCompared, 60L)
    expect_equal(r$overall$CaseMae, 0)
    expect_equal(r$overall$AttentionDuplicate, 0L)
  }
})

test_that("ConQuest aliases are reversible and avoid variable collisions", {
  b <- conquest_contract_fixture()$bundle
  ids <- c("NA", "001", "123456789012345678", " padded ",
    paste0(strrep("L", 32), sprintf("%03d", 5:60)))
  for (covariate in c("baseline.age", "I001", "to", "person")) {
    person <- data.frame(Person = ids, Value = b$person_data[[2]], check.names = FALSE)
    names(person)[2] <- covariate
    long <- b$response_long
    long$Person <- ids[match(long$Person, b$mfrmr_case_eap$Person)]
    parts <- mfrmr:::build_conquest_overlap_response_wide(long, ids,
      b$item_map$OriginalLevel, person)
    expect_false(anyDuplicated(names(parts$response_wide)) > 0L)
    expect_identical(names(parts$response_wide)[1:2], c("Person", "X"))
    expect_identical(parts$person_map$Person, ids)
    expect_true(all(nchar(parts$person_map$ConQuestPID) <= 32L))
    mapped <- b
    mapped$mfrmr_case_eap$Person <- ids
    mapped$person_map <- parts$person_map
    paths <- conquest_followup_exports(mapped, withr::local_tempdir())
    n <- do.call(normalize_conquest_overlap_exports, c(list(bundle = mapped), as.list(paths)))
    expect_identical(n$conquest_case_eap$Person, ids)
    expect_equal(review_conquest_overlap(mapped, n, conquest_location_shift = 0)$overall$CaseRowsCompared, 60L)
    write.csv(data.frame(PID = "unmapped", EAP_1 = 0), paths[4], row.names = FALSE)
    expect_error(do.call(normalize_conquest_overlap_exports, c(list(bundle = mapped), as.list(paths))), "person aliases")
  }
})

test_that("ConQuest numerical controls are independent of the native fit", {
  fit <- conquest_contract_fixture()$fit
  b <- build_conquest_overlap_bundle(fit, conquest_control = list(nodes = 61L, minnode = -8,
    maxnode = 9, p_nodes = 20000L, seed = 73L))
  expect_identical(b$summary$MfrmrQuadraturePoints, 7L)
  expect_identical(b$summary$ConQuestQuadratureNodes, 61L)
  expect_match(b$conquest_command, "nodes=61, minnode=-8, maxnode=9", fixed = TRUE)
  expect_match(b$conquest_command, "p_nodes=20000, seed=73", fixed = TRUE)
  expect_identical(b$mfrmr_population, conquest_contract_fixture()$bundle$mfrmr_population)
  expect_identical(b$mfrmr_case_eap, conquest_contract_fixture()$bundle$mfrmr_case_eap)
  for (control in list(list(nodes = 2), list(nodes = 3.5), list(nodes = NA_real_),
                       list(minnode = 6), list(p_nodes = 0), list(seed = Inf),
                       list(unknown = 1), list(nodes = 31, nodes = 61))) {
    expect_error(build_conquest_overlap_bundle(fit, conquest_control = control), "ConQuest|conquest_control")
  }
})

test_that("ConQuest report status and labels are checked without assuming precision", {
  b <- conquest_contract_fixture()$bundle
  d <- withr::local_tempdir(); paths <- conquest_followup_exports(b, d)
  normalize <- function(report = NULL) do.call(normalize_conquest_overlap_exports,
    c(list(bundle = b), as.list(paths), list(report_file = report)))
  unknown <- review_conquest_overlap(b, normalize())
  expect_identical(unknown$overall$ExternalEstimationStatus, "unknown")
  expect_true(is.na(unknown$overall$CaseMae))
  expect_equal(unknown$overall$CaseRawMae, 0)
  report <- file.path(d, "report.txt")
  lines <- c("Cases in MML/MCMC estimation: 60", "The item model: item", "The regression model: X",
    "Location constraint was: ITEMS", "The number of iterations: 132", "Final Deviance: 424.73898")
  writeLines(c(lines, "Iterations terminated because the deviance convergence criteria was reached"), report)
  r <- review_conquest_overlap(b, normalize(report))
  expect_identical(tail(summary(normalize(report))$normalization_scope$Status, 1), "criterion_met")
  expect_identical(r$overall$ExternalEstimationStatus, "criterion_met")
  expect_identical(r$overall$ExternalPrecisionStatus, "not_assessed")
  expect_identical(r$overall$LocationStatus, "reported_common_constraint")
  expect_equal(r$overall$CaseMae, 0)
  expect_true(r$overall$InterceptCompared)
  expect_error(review_conquest_overlap(b, normalize(report), conquest_location_shift = 2), "contradicts")
  writeLines(c(lines, "Iterations terminated because the maximum number of iterations was reached"), report)
  failed <- review_conquest_overlap(b, normalize(report))
  expect_identical(failed$overall$ExternalEstimationStatus, "iteration_limit")
  expect_true("external_estimation_not_converged" %in% failed$attention_items$Issue)
  writeLines(c(sub("estimation: 60", "estimation: 61", lines),
    "Iterations terminated because the parameter convergence criteria was reached"), report)
  expect_error(normalize(report), "does not match")
  p <- read.csv(paths[1]); p$Label <- rev(p$Label); write.csv(p, paths[1], row.names = FALSE)
  expect_error(normalize(), "labels do not match")
})

test_that("ConQuest covariates cannot overwrite native identifiers or estimates", {
  b <- conquest_contract_fixture()$bundle
  for (covariate in c("Estimate", "Person", "sigma2")) {
    person_data <- b$person_data
    names(person_data) <- c("Subject", covariate)
    fit <- fit_mfrm(b$response_long, "Person", "ItemLevel", "Score",
      rating_min = 0, rating_max = 1, method = "MML",
      population_formula = reformulate(covariate), person_data = person_data,
      person_id = "Subject", quad_points = 7, maxit = 40, attach_diagnostics = FALSE)
    mapped <- build_conquest_overlap_bundle(fit)
    expected <- predict_mfrm_units(fit, b$response_long, person = "Person",
      facets = "ItemLevel", score = "Score", person_data = person_data,
      person_id = "Subject", readiness_policy = "review", n_draws = 0)$estimates
    expect_identical(mapped$mfrmr_case_eap$Person, expected$Person)
    expect_identical(unname(mapped$mfrmr_case_eap$Estimate), unname(expected$Estimate))
    expect_identical(mapped$covariate_map$Covariate, covariate)
    expect_equal(anyDuplicated(mapped$mfrmr_population$Parameter), 0L)
    expect_identical(mapped$mfrmr_population$Estimate[match(mapped$covariate_map$PopulationParameter, mapped$mfrmr_population$Parameter)], unname(fit$population$coefficients[covariate]))
    expect_equal(anyDuplicated(names(mapped$person_data)), 0L)
    expect_equal(anyDuplicated(names(mapped$mfrmr_case_eap)), 0L)
    expect_identical(mapped$mfrmr_case_eap[[mapped$covariate_map$CaseVariable]], person_data[[covariate]])
    expect_identical(mapped$response_wide$X, person_data[[covariate]])
    expect_false(isTRUE(all.equal(mapped$mfrmr_case_eap$Estimate, person_data[[covariate]])))
  }
})

test_that("ConQuest review preserves raw differences and aligns only a known origin", {
  b <- conquest_contract_fixture()$bundle
  pop <- b$mfrmr_population; pop$Estimate[pop$Parameter == "(Intercept)"] <- pop$Estimate[pop$Parameter == "(Intercept)"]+2
  items <- data.frame(ItemID = b$item_map$ResponseVar, Estimate = b$mfrmr_item_estimates$Estimate+2)
  cases <- b$mfrmr_case_eap; cases$Estimate <- cases$Estimate+2
  unknown <- review_conquest_overlap(b, pop, items, cases)
  expect_true(is.na(unknown$overall$CaseMae))
  expect_equal(unknown$overall$CaseRawMae, 2)
  aligned <- review_conquest_overlap(b, pop, items, cases, conquest_location_shift = 2)
  expect_equal(aligned$overall$CaseMae, 0, tolerance = 1e-12)
  expect_equal(aligned$overall$InterceptAlignedDifference, 0, tolerance = 1e-12)
  expect_equal(aligned$case_comparison$Difference, rep(2, 60))
  # A true mean shift on a declared common origin must not be centered away.
  same <- review_conquest_overlap(b, pop, items, cases, conquest_location_shift = 0)
  expect_equal(same$overall$CaseMae, 2)
  expect_equal(same$overall$InterceptAlignedDifference, 2)
  extras <- review_conquest_overlap(b,
    rbind(pop[, c("Parameter", "Estimate")], data.frame(Parameter = "extra", Estimate = 0)),
    rbind(items, data.frame(ItemID = "extra", Estimate = 0)),
    rbind(cases[, c("Person", "Estimate")], data.frame(Person = "extra", Estimate = 0)), conquest_location_shift = 2)
  expect_equal(extras$overall$AttentionUnexpected, 3L)
  facility <- items; names(facility)[2] <- "Facility"
  expect_error(normalize_conquest_overlap_tables(pop, facility, cases), "conquest_item_estimate")
  expect_no_error(normalize_conquest_overlap_tables(pop, facility, cases, conquest_item_estimate = "Facility"))
})

test_that("ConQuest extracted factors retain estimate labels in every table route", {
  b <- conquest_contract_fixture()$bundle
  pop <- b$mfrmr_population
  items <- data.frame(ItemID = b$item_map$ResponseVar,
    Estimate = b$mfrmr_item_estimates$Estimate)
  cases <- b$mfrmr_case_eap[, c("Person", "Estimate")]
  # Deliberately choose labels that differ from the factor's integer codes.
  pop$Estimate <- c(.25, -.5, .75)
  items$Estimate <- seq(-.75, .75, length.out = nrow(items))
  cases$Estimate <- seq(-1.25, 1.25, length.out = nrow(cases))
  expected <- review_conquest_overlap(b, pop, items, cases,
    conquest_location_shift = 0)
  estimates <- list(pop, items, cases)
  factors <- lapply(estimates, function(x) {
    x$Estimate <- factor(as.character(x$Estimate))
    x
  })
  direct <- do.call(review_conquest_overlap,
    c(list(bundle = b), factors, list(conquest_location_shift = 0)))
  normalized <- do.call(normalize_conquest_overlap_tables, factors)
  normalized_tables <- normalized[c("conquest_population", "conquest_item_estimates",
    "conquest_case_eap")]
  for (i in seq_along(estimates)) {
    expect_equal(normalized_tables[[i]]$Estimate, estimates[[i]]$Estimate,
      tolerance = 1e-12)
    expect_false(any(normalized_tables[[i]]$EstimateNonNumeric))
  }
  reviewed <- review_conquest_overlap(b, normalized, conquest_location_shift = 0)
  for (component in c("overall", "population_comparison", "item_comparison", "case_comparison")) {
    expect_equal(direct[[component]], expected[[component]], tolerance = 1e-12)
    expect_equal(reviewed[[component]], expected[[component]], tolerance = 1e-12)
  }
  malformed <- lapply(factors, function(x) {
    labels <- as.character(x$Estimate)
    labels[1] <- "not-a-number"
    x$Estimate <- factor(labels)
    x
  })
  invalid <- do.call(normalize_conquest_overlap_tables, malformed)
  expect_equal(unname(unlist(invalid$summary[c("PopulationNonNumeric",
    "ItemNonNumeric", "CaseNonNumeric")])), rep(1, 3))
  invalid_review <- do.call(review_conquest_overlap,
    c(list(bundle = b), malformed, list(conquest_location_shift = 0)))
  expect_equal(invalid_review$overall$AttentionNonNumeric, 3L)
  expect_equal(invalid_review$overall$AttentionMissing, 0L)
})

test_that("ConQuest CSV case errors retain their reason through normalization", {
  b <- conquest_contract_fixture()$bundle
  directory <- withr::local_tempdir()
  paths <- conquest_followup_exports(b, directory)
  cases <- read.csv(paths[4], colClasses = "character", na.strings = "")
  cases$EAP_1[1:5] <- c("not-a-number", "", "NaN", "Inf", "2.5e-1")
  write.csv(cases, paths[4], row.names = FALSE)
  normalized <- do.call(normalize_conquest_overlap_exports,
    c(list(bundle = b), as.list(paths)))
  expect_equal(normalized$summary$CaseNonNumeric, 3L)
  expect_identical(normalized$conquest_case_eap$EstimateNonNumeric[1:5],
    c(TRUE, FALSE, TRUE, TRUE, FALSE))
  expect_true(is.na(normalized$conquest_case_eap$Estimate[1]))
  expect_equal(normalized$conquest_case_eap$Estimate[5], .25)
  reviewed <- review_conquest_overlap(b, normalized, conquest_location_shift = 0)
  status <- reviewed$case_comparison$Status[
    match(b$mfrmr_case_eap$Person[1:5], reviewed$case_comparison$Person)]
  expect_identical(status, c("NonNumericInConQuest", "MissingInConQuest",
    "NonNumericInConQuest", "NonNumericInConQuest", "Compared"))
  expect_equal(reviewed$overall$AttentionNonNumeric, 3L)
  expect_equal(reviewed$overall$AttentionMissing, 1L)
  expect_equal(reviewed$overall$CaseRowsCompared, nrow(b$mfrmr_case_eap) - 4L)
})
