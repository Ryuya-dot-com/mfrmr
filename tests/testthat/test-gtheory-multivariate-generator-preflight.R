gtheory_multivariate_generator_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-incidence-preflight-0.2.4.R",
      "gtheory-multivariate-matched-backend-prototype-0.2.4.R",
      "gtheory-multivariate-k-oracle-prototype-0.2.4.R",
      "gtheory-multivariate-ademp-plan-prototype-0.2.4.R",
      "gtheory-multivariate-generator-preflight-0.2.4.R"
    )
  )
}

load_gtheory_multivariate_generator <- local({
  validation_environment <- NULL
  function() {
    paths <- gtheory_multivariate_generator_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal validation artifacts are excluded")
    skip_if_not_installed("digest")
    if (is.null(validation_environment)) {
      validation_environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = validation_environment)
    }
    validation_environment
  }
})

gtve_canonical_plan <- local({
  plan <- NULL
  function(env) {
    if (is.null(plan)) plan <<- env$mfrmr_gtvd_plan()
    plan
  }
})

gtve_canonical_manifest <- local({
  manifest <- NULL
  function(env) {
    if (is.null(manifest)) {
      plan <- gtve_canonical_plan(env)
      registry <- env$mfrmr_gtve_fixture_registry(plan)
      manifest <<- env$mfrmr_gtve_manifest(plan, registry)
    }
    manifest
  }
})

test_that("Draft.85c2 seals a fixture-only generator manifest", {
  env <- load_gtheory_multivariate_generator()
  manifest <- gtve_canonical_manifest(env)
  plan <- gtve_canonical_plan(env)

  expect_silent(env$mfrmr_gtve_assert_manifest(
    manifest, plan, manifest$FixtureRegistry
  ))
  expect_s3_class(manifest, "mfrmr_gtve_manifest")
  expect_identical(manifest$FixtureCount, 12L)
  expect_identical(manifest$StateRowCount, 48L)
  expect_true(manifest$GeneratorImplementationReady)
  expect_true(manifest$FixtureRNGStateHashReady)
  expect_true(manifest$CallerRNGRestorationReady)
  expect_true(manifest$PlanSeedIsolationReady)
  expect_false(manifest$PilotExecutionAuthorized)
  expect_false(manifest$ConfirmationExecutionAuthorized)
  expect_false(manifest$BackendQualificationReady)
  expect_false(manifest$RecoveryExecuted)
  expect_false(manifest$RecoveryEvidenceReady)
  expect_false(manifest$EstimationReady)
  expect_false(manifest$InferenceReady)
  expect_false(manifest$DecisionReady)
  expect_false(manifest$PublicSupportReady)
})

test_that("Draft.85c2 covers all recovery scenarios without plan seed reuse", {
  env <- load_gtheory_multivariate_generator()
  manifest <- gtve_canonical_manifest(env)
  plan <- gtve_canonical_plan(env)
  registry <- manifest$FixtureRegistry

  expect_identical(
    registry$ScenarioId,
    plan$ScenarioRegistry$ScenarioId[plan$ScenarioRegistry$RecoveryExecutable]
  )
  expect_identical(registry$FixtureSeed, 854000001:854000012)
  expect_false(any(registry$FixtureSeed %in%
                     plan$GenerationManifest$DataSeed))
  expect_false(any(registry$PlanSeedCollision))
  expect_false(any(registry$RecoveryDenominatorEligible))
  expect_true(all(
    registry$ExpectedRows ==
      plan$StructuralDesignPreflight$StructuralRows[match(
        registry$AssignmentId,
        plan$StructuralDesignPreflight$AssignmentId
      )]
  ))
  expect_identical(
    manifest$FixtureReplayRegistry$RowCount, registry$ExpectedRows
  )
  expect_identical(anyDuplicated(registry$FixtureId), 0L)
  expect_identical(anyDuplicated(registry$FixtureSeed), 0L)
})

test_that("Draft.85c2 restores caller RNG and ignores ambient RNG kind", {
  env <- load_gtheory_multivariate_generator()
  plan <- gtve_canonical_plan(env)
  registry <- gtve_canonical_manifest(env)$FixtureRegistry
  old_kind <- RNGkind()
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (had_seed) get(".Random.seed", envir = .GlobalEnv) else NULL
  on.exit({
    do.call(RNGkind, as.list(old_kind))
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)

  do.call(RNGkind, as.list(c("Mersenne-Twister", "Inversion", "Rejection")))
  set.seed(850201L)
  first_kind <- RNGkind()
  first_state <- get(".Random.seed", envir = .GlobalEnv)
  first <- env$mfrmr_gtve_generate_fixture(
    "FX-C1-B3-SCALED", plan, registry
  )
  expect_identical(RNGkind(), first_kind)
  expect_identical(get(".Random.seed", envir = .GlobalEnv), first_state)

  do.call(RNGkind, as.list(c("Wichmann-Hill", "Inversion", "Rejection")))
  set.seed(850202L)
  second_kind <- RNGkind()
  second_state <- get(".Random.seed", envir = .GlobalEnv)
  second <- env$mfrmr_gtve_generate_fixture(
    "FX-C1-B3-SCALED", plan, registry
  )
  expect_identical(RNGkind(), second_kind)
  expect_identical(get(".Random.seed", envir = .GlobalEnv), second_state)
  starts <- env$mfrmr_gtve_component_starts(854000001L)
  expect_identical(
    names(starts), c("Object", "Rater", "Object:Rater", "Residual")
  )
  expect_identical(RNGkind(), second_kind)
  expect_identical(get(".Random.seed", envir = .GlobalEnv), second_state)
  expect_identical(first, second)
  expect_silent(env$mfrmr_gtve_assert_generation(first, plan, registry))
})

test_that("Draft.85c2 binds component substreams and exact draw counts", {
  env <- load_gtheory_multivariate_generator()
  manifest <- gtve_canonical_manifest(env)
  plan <- gtve_canonical_plan(env)
  states <- manifest$ComponentStateRegistry

  expect_identical(
    as.integer(table(states$ComponentId)), c(12L, 12L, 12L, 12L)
  )
  expect_identical(
    states$ComponentId[states$FixtureId == "FX-C1-I2-BAL"],
    c("Object", "Rater", "Object:Rater", "Residual")
  )
  for (fixture_index in seq_len(nrow(manifest$FixtureRegistry))) {
    fixture <- manifest$FixtureRegistry[fixture_index, , drop = FALSE]
    rows <- env$mfrmr_gtvd_assignment_rows(fixture$AssignmentId)
    state <- states[states$FixtureId == fixture$FixtureId, , drop = FALSE]
    starts <- env$mfrmr_gtve_component_starts(fixture$FixtureSeed)
    expect_identical(
      state$StartStateHash,
      unname(vapply(starts, env$mfrmr_gta_hash, character(1L)))
    )
    factors <- lapply(c("Object", "Rater", "Object:Rater"), function(component) {
      env$mfrmr_gtve_factor_matrix(
        plan, fixture$ReferenceId, component,
        plan$FixedMeanRegistry$Stratum[
          plan$FixedMeanRegistry$CoordinateLayoutId ==
            fixture$CoordinateLayoutId
        ]
      )
    })
    expected_draws <- c(
      length(unique(rows$Object)) * ncol(factors[[1L]]),
      length(unique(rows$Rater)) * ncol(factors[[2L]]),
      length(unique(rows$ObjectRater)) * ncol(factors[[3L]]),
      nrow(rows)
    )
    expect_identical(state$DrawCount, as.integer(expected_draws))
  }
  expect_true(all(nchar(states$StartStateHash) == 64L))
  expect_true(all(nchar(states$EndStateHash) == 64L))
  expect_false(anyNA(states))
})

test_that("Draft.85c2 uses stored low-rank factors without repair", {
  env <- load_gtheory_multivariate_generator()
  plan <- gtve_canonical_plan(env)
  strata2 <- c("A", "B")
  strata3 <- c("A", "B", "C")

  rank1 <- env$mfrmr_gtve_factor_matrix(
    plan, "REF-T2-RATER-RANK1", "Rater", strata2
  )
  rank2 <- env$mfrmr_gtve_factor_matrix(
    plan, "REF-T3-RATER-RANK2", "Rater", strata3
  )
  scaled <- env$mfrmr_gtve_factor_matrix(
    plan, "REF-T3-INTERACTION-SCALED", "Object:Rater", strata3
  )
  expect_identical(dim(rank1), c(2L, 1L))
  expect_identical(dim(rank2), c(3L, 2L))
  expect_identical(dim(scaled), c(3L, 3L))
  truth_rows <- plan$ReferenceCoordinateRegistry[
    plan$ReferenceCoordinateRegistry$ReferenceId ==
      "REF-T2-RATER-RANK1" &
      plan$ReferenceCoordinateRegistry$ComponentId == "Rater",
    , drop = FALSE
  ]
  truth_matrix <- matrix(
    0, 2L, 2L, dimnames = list(strata2, strata2)
  )
  for (index in seq_len(nrow(truth_rows))) {
    left <- match(truth_rows$LeftStratum[[index]], strata2)
    right <- match(truth_rows$RightStratum[[index]], strata2)
    truth_matrix[left, right] <- truth_rows$TruthValue[[index]]
    truth_matrix[right, left] <- truth_rows$TruthValue[[index]]
  }
  expect_equal(
    rank1 %*% t(rank1), truth_matrix, tolerance = 1e-12
  )
  expect_true(min(svd(scaled, nu = 0L, nv = 0L)$d) > 0)
})

test_that("Draft.85c2 candidate data excludes truth-side generator fields", {
  env <- load_gtheory_multivariate_generator()
  plan <- gtve_canonical_plan(env)
  registry <- gtve_canonical_manifest(env)$FixtureRegistry
  generation <- env$mfrmr_gtve_generate_fixture(
    "FX-C1-I3-ABSENT", plan, registry
  )

  expect_identical(
    names(generation$CandidateData),
    c(
      "RowId", "Stratum", "Object", "Rater", "ObjectRater", "Replicate",
      "Score"
    )
  )
  expect_false(any(c(
    "FixtureSeed", "ReferenceId", "FixedMean", "ObjectEffect",
    "RaterEffect", "ObjectRaterEffect", "ResidualEffect"
  ) %in% names(generation$CandidateData)))
  expect_true(all(is.finite(generation$CandidateData$Score)))
  expect_identical(
    generation$CandidateData$Score, generation$TruthAudit$Score
  )
  expect_identical(
    generation$CandidateData$RowId, generation$TruthAudit$RowId
  )
  component_map <- list(
    ObjectEffect = "Object", RaterEffect = "Rater",
    ObjectRaterEffect = "ObjectRater"
  )
  for (effect_column in names(component_map)) {
    component <- sub("Effect$", "", effect_column)
    if (identical(component, "ObjectRater")) component <- "Object:Rater"
    effect_rows <- generation$GeneratedEffectRegistry[
      generation$GeneratedEffectRegistry$ComponentId == component,
      , drop = FALSE
    ]
    effect_key <- paste(effect_rows$GroupId, effect_rows$Stratum, sep = "\036")
    row_key <- paste(
      generation$CandidateData[[component_map[[effect_column]]]],
      generation$CandidateData$Stratum, sep = "\036"
    )
    expect_identical(
      unname(effect_rows$Effect[match(row_key, effect_key)]),
      generation$TruthAudit[[effect_column]]
    )
  }
  expect_equal(
    generation$TruthAudit$Score,
    rowSums(generation$TruthAudit[c(
      "FixedMean", "ObjectEffect", "RaterEffect", "ObjectRaterEffect",
      "ResidualEffect"
    )]),
    tolerance = 0
  )
  expect_true(generation$FixtureOnly)
  expect_false(generation$RecoveryResponseGenerated)
  expect_false(generation$BackendExecutionOccurred)
})

test_that("Draft.85c2 rejects fixture, generation, and readiness mutation", {
  env <- load_gtheory_multivariate_generator()
  manifest <- gtve_canonical_manifest(env)
  plan <- gtve_canonical_plan(env)
  registry <- manifest$FixtureRegistry

  changed_registry <- manifest$FixtureRegistry
  changed_registry$FixtureSeed[[1L]] <- plan$GenerationManifest$DataSeed[[1L]]
  changed_registry$PlanSeedCollision[[1L]] <- TRUE
  expect_error(
    env$mfrmr_gtve_assert_fixture_registry(changed_registry, plan),
    "canonical nonreserved"
  )
  expect_error(
    env$mfrmr_gtve_generate_fixture(
      "FX-C1-N3-NO-AC", plan, registry
    ),
    "must identify one registered"
  )
  expect_error(
    env$mfrmr_gtve_generate_fixture("unknown", plan, registry),
    "must identify one registered"
  )

  generation <- env$mfrmr_gtve_generate_fixture(
    "FX-C1-I2-SPARSE", plan, registry
  )
  changed_generation <- generation
  changed_generation$CandidateData$Score[[1L]] <-
    changed_generation$CandidateData$Score[[1L]] + 1
  changed_generation$Identity$CandidateDataHash <-
    env$mfrmr_gta_hash(changed_generation$CandidateData)
  changed_generation$GenerationHash <-
    env$mfrmr_gta_hash(changed_generation$Identity)
  expect_error(
    env$mfrmr_gtve_assert_generation(
      changed_generation, plan, registry
    ), "altered"
  )

  changed_manifest <- manifest
  changed_manifest$PilotExecutionAuthorized <- TRUE
  expect_error(env$mfrmr_gtve_assert_manifest(
    changed_manifest, plan, registry
  ), "altered")
  changed_manifest <- manifest
  changed_manifest$ComponentStateRegistry$DrawCount[[1L]] <-
    changed_manifest$ComponentStateRegistry$DrawCount[[1L]] + 1L
  changed_manifest$ComponentStateRegistryHash <-
    env$mfrmr_gta_hash(changed_manifest$ComponentStateRegistry)
  changed_manifest$ManifestHash <- env$mfrmr_gta_hash(
    changed_manifest[env$mfrmr_gtve_manifest_payload_fields()]
  )
  expect_error(env$mfrmr_gtve_assert_manifest(
    changed_manifest, plan, registry
  ), "altered")
})

test_that("Draft.85c2 binds every local function and calls no backend", {
  env <- load_gtheory_multivariate_generator()
  manifest <- gtve_canonical_manifest(env)
  identity <- manifest$ImplementationIdentity
  actual <- sort(ls(envir = env, pattern = "^mfrmr_gtve_"))
  actual <- actual[vapply(actual, function(name) {
    is.function(get(name, envir = env, inherits = FALSE))
  }, logical(1L))]

  expect_identical(sort(identity$FunctionName), actual)
  expect_identical(anyDuplicated(identity$FunctionName), 0L)
  expect_identical(
    identity$FunctionHash,
    unname(vapply(identity$FunctionName, function(name) {
      env$mfrmr_gtve_function_hash(get(name, envir = env, inherits = FALSE))
    }, character(1L)))
  )
  source_text <- readLines(gtheory_multivariate_generator_paths()[[7L]],
                           warn = FALSE)
  executable <- source_text[!grepl("^#", trimws(source_text))]
  expect_false(any(grepl(
    "lmer\\(|glmmTMB\\(|ConQuest|system2\\(|system\\(", executable
  )))
})

test_that("Draft.85c2 does not promote c1 or recovery readiness", {
  env <- load_gtheory_multivariate_generator()
  manifest <- gtve_canonical_manifest(env)
  plan <- gtve_canonical_plan(env)

  expect_false(plan$GeneratorImplementationReady)
  expect_false(any(plan$SeedPartitionPolicy$FixtureRNGStateHashReady))
  expect_false(plan$PilotExecutionAuthorized)
  expect_false(plan$ConfirmationExecutionAuthorized)
  expect_false(plan$RecoveryExecuted)
  expect_false(plan$RecoveryEvidenceReady)
  expect_true(manifest$GeneratorImplementationReady)
  expect_true(manifest$FixtureRNGStateHashReady)
  expect_false(manifest$PilotExecutionAuthorized)
  expect_false(manifest$ConfirmationExecutionAuthorized)
  expect_false(manifest$RecoveryExecuted)
  expect_false(manifest$RecoveryEvidenceReady)
})

test_that("Draft.85c2 record hashes match replay and public surface is clean", {
  env <- load_gtheory_multivariate_generator()
  manifest <- gtve_canonical_manifest(env)
  record_path <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-multivariate-generator-preflight-record-0.2.4.md"
  )
  skip_if_not(file.exists(record_path), "Draft.85c2 record is not present")
  record <- readLines(record_path, warn = FALSE)
  tokens <- strsplit(trimws(record), "[[:space:]]+")
  hash_rows <- vapply(tokens, function(value) {
    length(value) == 2L && grepl("^[0-9a-f]{64}$", value[[2L]])
  }, logical(1L))
  recorded <- stats::setNames(
    vapply(tokens[hash_rows], `[[`, character(1L), 2L),
    vapply(tokens[hash_rows], `[[`, character(1L), 1L)
  )
  names <- c(
    "ManifestHash", "ManifestCoreHash", "FixtureRegistryHash",
    "FixtureReplayRegistryHash", "ComponentStateRegistryHash",
    "ImplementationIdentityHash"
  )
  expect_true(all(names %in% base::names(recorded)))
  expect_identical(
    unname(recorded[names]),
    unname(unlist(manifest[names], use.names = FALSE))
  )

  root <- testthat::test_path("..", "..")
  public_paths <- c(
    list.files(file.path(root, "R"), full.names = TRUE),
    list.files(file.path(root, "man"), full.names = TRUE),
    list.files(file.path(root, "vignettes"), full.names = TRUE),
    file.path(root, c(
      "NEWS.md", "ROADMAP.md", "README.md", "DESCRIPTION", "NAMESPACE",
      "CITATION.cff", "_pkgdown.yml"
    ))
  )
  public_paths <- public_paths[file.exists(public_paths)]
  public_paths <- public_paths[!file.info(public_paths)$isdir]
  leaked <- vapply(public_paths, function(path) {
    any(grepl(
      "Draft\\.85c2|mfrmr_gtve|gtheory_multivariate_generator_preflight",
      readLines(path, warn = FALSE)
    ))
  }, logical(1L))
  expect_false(any(leaked))
})
