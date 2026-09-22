maxit_contract_path <- function() {
  candidates <- c(
    file.path("inst", "validation", "maxit-ceiling-contract-0.2.3.R"),
    testthat::test_path(
      "..", "..", "inst", "validation",
      "maxit-ceiling-contract-0.2.3.R"
    )
  )
  candidates[file.exists(candidates)][1L]
}

load_maxit_contract <- function() {
  path <- maxit_contract_path()
  testthat::skip_if(is.na(path), "Repository maxit contract is unavailable.")
  env <- new.env(parent = globalenv())
  sys.source(path, envir = env)
  env
}

maxit_source_root <- function() {
  candidates <- c(
    normalizePath(".", mustWork = FALSE),
    normalizePath(testthat::test_path("..", ".."), mustWork = FALSE)
  )
  candidates <- candidates[
    file.exists(file.path(candidates, "DESCRIPTION")) &
      file.exists(file.path(candidates, "R", "api-estimation.R"))
  ]
  if (length(candidates) == 0L) NA_character_ else candidates[1L]
}

maxit_attempts <- function(maxit = c(400L, 800L),
                           fit = c("blocked", "ready"),
                           inference = c(FALSE, TRUE),
                           numerical = c("failed", "ready"),
                           convergence = c("iteration_limit", "converged"),
                           selected = c(FALSE, TRUE),
                           hash = rep(strrep("a", 64L), length(maxit))) {
  env <- load_maxit_contract()
  env$mfrmr_maxit_attempt_table(
    maxit = maxit,
    specification_hash = hash,
    fit_readiness = fit,
    inference_ready = inference,
    numerical_state = numerical,
    convergence_status = convergence,
    selected = selected
  )
}

test_that("the default maxit sequence and first-ready rule are fixed", {
  env <- load_maxit_contract()
  expect_identical(
    env$mfrmr_maxit_contract_id,
    "mfrmr-maxit-ceiling-0.2.3-v1"
  )
  expect_identical(env$mfrmr_maxit_default_sequence, c(400L, 800L, 1600L))

  review <- env$mfrmr_review_maxit_attempts(maxit_attempts())
  expect_true(review$summary$ContractPass)
  expect_true(review$summary$RegisteredPrefix)
  expect_true(review$summary$SpecificationFixed)
  expect_true(review$summary$ReadinessStateConsistent)
  expect_true(review$summary$SelectionMatchesFirstEligible)
  expect_identical(review$summary$FirstEligibleAttempt, 2L)
  expect_identical(review$summary$SelectedAttempt, 2L)
  expect_identical(review$summary$ReasonCodes, "")
  expect_false(review$summary$ConfirmationAuthorized)
  expect_identical(review$attempts$Eligible, c(FALSE, TRUE))
})

test_that("iteration limits and review-only runs are never eligible", {
  env <- load_maxit_contract()
  no_ready <- maxit_attempts(
    maxit = c(400L, 800L),
    fit = c("blocked", "review"),
    inference = c(FALSE, FALSE),
    numerical = c("failed", "review"),
    convergence = c("iteration_limit", "converged_gradient_review"),
    selected = c(FALSE, FALSE)
  )
  review <- env$mfrmr_review_maxit_attempts(no_ready)
  expect_true(review$summary$ContractPass)
  expect_true(is.na(review$summary$FirstEligibleAttempt))
  expect_true(all(!review$attempts$Eligible))

  selected_blocked <- no_ready
  selected_blocked$Selected[1] <- TRUE
  rejected <- env$mfrmr_review_maxit_attempts(selected_blocked)
  expect_false(rejected$summary$ContractPass)
  expect_match(
    rejected$summary$ReasonCodes,
    "selected_run_not_first_eligible",
    fixed = TRUE
  )
})

test_that("skips, changed specifications, and preferred later runs fail closed", {
  env <- load_maxit_contract()

  skipped <- maxit_attempts(maxit = c(400L, 1600L))
  skipped_review <- env$mfrmr_review_maxit_attempts(skipped)
  expect_false(skipped_review$summary$ContractPass)
  expect_match(
    skipped_review$summary$ReasonCodes,
    "unregistered_ceiling_sequence",
    fixed = TRUE
  )

  changed <- maxit_attempts(
    hash = c(strrep("a", 64L), strrep("b", 64L))
  )
  changed_review <- env$mfrmr_review_maxit_attempts(changed)
  expect_false(changed_review$summary$ContractPass)
  expect_match(
    changed_review$summary$ReasonCodes,
    "specification_changed",
    fixed = TRUE
  )

  preferred_later <- maxit_attempts(
    maxit = c(400L, 800L),
    fit = c("ready", "ready"),
    inference = c(TRUE, TRUE),
    numerical = c("ready", "ready"),
    convergence = c("converged", "converged"),
    selected = c(FALSE, TRUE)
  )
  preferred_review <- env$mfrmr_review_maxit_attempts(preferred_later)
  expect_false(preferred_review$summary$ContractPass)
  expect_identical(preferred_review$summary$FirstEligibleAttempt, 1L)
  expect_match(
    preferred_review$summary$ReasonCodes,
    "selected_run_not_first_eligible",
    fixed = TRUE
  )
})

test_that("stored readiness flags cannot override an iteration limit", {
  env <- load_maxit_contract()
  inconsistent <- maxit_attempts(
    maxit = 400L,
    fit = "ready",
    inference = TRUE,
    numerical = "ready",
    convergence = "iteration_limit",
    selected = TRUE,
    hash = strrep("a", 64L)
  )
  review <- env$mfrmr_review_maxit_attempts(inconsistent)
  expect_false(review$summary$ContractPass)
  expect_false(review$summary$ReadinessStateConsistent)
  expect_match(
    review$summary$ReasonCodes,
    "readiness_state_inconsistent",
    fixed = TRUE
  )
})

test_that("selection and sequence schemas reject malformed registries", {
  env <- load_maxit_contract()
  expect_error(
    env$mfrmr_maxit_validate_sequence(c(400, 400)),
    "strictly increasing",
    fixed = TRUE
  )
  expect_error(
    env$mfrmr_maxit_validate_sequence(c(800, 400)),
    "strictly increasing",
    fixed = TRUE
  )
  malformed <- maxit_attempts()
  malformed$SpecificationHash[1] <- "not-a-hash"
  expect_error(
    env$mfrmr_review_maxit_attempts(malformed),
    "malformed identity or readiness fields",
    fixed = TRUE
  )
  multiple <- maxit_attempts(selected = c(TRUE, TRUE))
  multiple_review <- env$mfrmr_review_maxit_attempts(multiple)
  expect_false(multiple_review$summary$ContractPass)
  expect_false(multiple_review$summary$SelectionCountValid)
  expect_match(
    multiple_review$summary$ReasonCodes,
    "multiple_runs_selected",
    fixed = TRUE
  )
})

test_that("real current fits populate the registered attempt contract", {
  env <- load_maxit_contract()
  data <- load_mfrmr_data("example_core")
  fit_once <- function(maxit) {
    suppressWarnings(fit_mfrm(
      data,
      person = "Person",
      facets = c("Rater", "Criterion"),
      score = "Score",
      method = "JML",
      model = "RSM",
      optimizer = "auto",
      reltol = if (maxit == 1L) 1e-12 else 1e-9,
      maxit = maxit
    ))
  }
  fits <- list(fit_once(1L), fit_once(120L))
  attempts <- env$mfrmr_maxit_attempts_from_fits(
    fits,
    specification_hash = strrep("c", 64L),
    selected = c(FALSE, TRUE)
  )
  expect_identical(attempts$Maxit, c(1L, 120L))
  expect_identical(attempts$FitReadiness, c("blocked", "ready"))
  expect_identical(attempts$NumericalState, c("failed", "ready"))
  expect_identical(
    attempts$ConvergenceStatus,
    c("iteration_limit", "converged")
  )
  review <- env$mfrmr_review_maxit_attempts(
    attempts,
    declared_sequence = c(1L, 120L)
  )
  expect_true(review$summary$ContractPass)
  expect_identical(review$summary$FirstEligibleAttempt, 2L)
  expect_identical(review$summary$SelectedAttempt, 2L)
  expect_identical(review$summary$ReasonCodes, "")
  next_actions <- summary(fits[[1L]])$next_actions
  expect_true(any(grepl(
    "Do not interpret or select estimates from this iteration-limited fit.",
    next_actions,
    fixed = TRUE
  )))
  expect_true(any(grepl(
    "prespecified `maxit` sequence",
    next_actions,
    fixed = TRUE
  )))
})

test_that("public and release guidance state one prespecified ceiling policy", {
  root <- maxit_source_root()
  testthat::skip_if(is.na(root), "Source maxit guidance is unavailable.")
  paths <- file.path(root, c(
    "R/api-estimation.R",
    "README.md",
    "vignettes/mfrmr-workflow.Rmd",
    "vignettes/mfrmr-mml-and-marginal-fit.Rmd",
    "inst/validation/release-gate-spec-0.2.3.md"
  ))
  expect_true(all(file.exists(paths)))
  text <- paste(
    unlist(lapply(paths, readLines, warn = FALSE), use.names = FALSE),
    collapse = " "
  )
  text <- gsub("[[:space:]]+", " ", text)
  expect_match(text, "computational ceiling", fixed = TRUE)
  expect_match(text, "400, 800, then 1600", fixed = TRUE)
  expect_match(text, "same data, model, method", fixed = TRUE)
  expect_match(text, "The first run in that sequence", fixed = TRUE)
  expect_match(text, "Do not select", fixed = TRUE)
  expect_match(text, "cannot pass a blocker row through repeated ad hoc reruns", fixed = TRUE)
})
