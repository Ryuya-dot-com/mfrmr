export_bundle_fixture <- local({
  old_opt <- options(lifecycle_verbosity = "quiet")
  on.exit(options(old_opt), add = TRUE)

  dat <- mfrmr:::sample_mfrm_data(seed = 123)
  fit <- suppressWarnings(fit_mfrm(
    dat,
    "Person",
    c("Rater", "Criterion"),
    "Score",
    method = "JML",
    maxit = 20
  ))
  diagnostics <- suppressWarnings(diagnose_mfrm(fit, residual_pca = "overall"))
  run <- suppressWarnings(run_mfrm_facets(
    dat,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "JML",
    maxit = 20
  ))
  bias_all <- suppressWarnings(estimate_all_bias(
    fit,
    diagnostics = diagnostics,
    max_iter = 2
  ))

  list(
    fit = fit,
    diagnostics = diagnostics,
    run = run,
    bias_all = bias_all
  )
})

test_that("build_mfrm_manifest captures reproducibility metadata", {
  manifest <- build_mfrm_manifest(
    fit = export_bundle_fixture$fit,
    diagnostics = export_bundle_fixture$diagnostics,
    bias_results = export_bundle_fixture$bias_all
  )

  expect_s3_class(manifest, "mfrm_manifest")
  expect_true(is.data.frame(manifest$summary))
  expect_true(is.data.frame(manifest$environment))
  expect_true(is.data.frame(manifest$available_outputs))
  expect_true(any(manifest$available_outputs$Component == "residual_pca"))
  expect_true(
    manifest$available_outputs$Available[manifest$available_outputs$Component == "bias_results"][1]
  )
  expect_equal(manifest$summary$Method[[1]], "JML")
  expect_equal(manifest$summary$MethodUsed[[1]], "JMLE")
  expect_equal(manifest$summary$Observations[[1]], nrow(export_bundle_fixture$fit$prep$data))
  expect_equal(manifest$summary$Persons[[1]], export_bundle_fixture$fit$config$n_person)
})

test_that("build_mfrm_manifest and replay script support FACETS-mode runs", {
  manifest <- build_mfrm_manifest(export_bundle_fixture$run)
  replay <- build_mfrm_replay_script(
    export_bundle_fixture$run,
    bias_results = export_bundle_fixture$bias_all,
    data_file = "analysis_data.csv"
  )

  expect_s3_class(manifest, "mfrm_manifest")
  expect_s3_class(replay, "mfrm_replay_script")
  expect_match(replay$script, "run_mfrm_facets\\(")
  expect_match(replay$script, "analysis_data\\.csv")
  expect_match(replay$script, "estimate_all_bias\\(")
})

test_that("build_mfrm_replay_script preserves keep_original and rating range", {
  dat <- mfrmr:::sample_mfrm_data(seed = 42) |>
    dplyr::filter(.data$Score %in% c(1, 3, 5))

  fit <- suppressWarnings(fit_mfrm(
    dat,
    "Person",
    c("Rater", "Task", "Criterion"),
    "Score",
    method = "JML",
    maxit = 25,
    keep_original = TRUE
  ))

  replay <- build_mfrm_replay_script(fit, data_file = "analysis_data.csv")

  expect_match(replay$script, "keep_original = TRUE", fixed = TRUE)
  expect_match(replay$script, "rating_min = 1", fixed = TRUE)
  expect_match(replay$script, "rating_max = 5", fixed = TRUE)
  expect_match(replay$script, "# Model: RSM | Method: JML | InternalMethod: JMLE", fixed = TRUE)
  expect_match(replay$script, 'method = "JML"', fixed = TRUE)
})

test_that("export_mfrm_bundle writes requested tables and html output", {
  out_dir <- file.path(tempdir(), "mfrmr-export-bundle-test")
  if (dir.exists(out_dir)) unlink(out_dir, recursive = TRUE, force = TRUE)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  expect_no_warning(
    bundle <- export_mfrm_bundle(
      fit = export_bundle_fixture$fit,
      diagnostics = export_bundle_fixture$diagnostics,
      bias_results = export_bundle_fixture$bias_all,
      output_dir = out_dir,
      prefix = "bundle_test",
      include = c("core_tables", "checklist", "dashboard", "apa", "anchors", "manifest", "visual_summaries", "script", "html"),
      overwrite = TRUE
    )
  )

  expect_s3_class(bundle, "mfrm_export_bundle")
  expect_true(is.data.frame(bundle$written_files))
  expect_true(any(bundle$written_files$Component == "bundle_html"))
  expect_true(any(grepl("bundle_test_manifest_summary.csv$", bundle$written_files$Path)))
  expect_true(any(grepl("bundle_test_checklist.csv$", bundle$written_files$Path)))
  expect_true(any(grepl("bundle_test_facet_dashboard_detail.csv$", bundle$written_files$Path)))
  expect_true(any(grepl("bundle_test_replay.R$", bundle$written_files$Path)))
  expect_true(any(grepl("bundle_test_visual_warning_counts.csv$", bundle$written_files$Path)))
  expect_true(file.exists(file.path(out_dir, "bundle_test_bundle.html")))
  expect_true(file.exists(file.path(out_dir, "bundle_test_manifest.txt")))
  expect_true(file.exists(file.path(out_dir, "bundle_test_replay.R")))
  expect_true(file.exists(file.path(out_dir, "bundle_test_visual_warning_map.txt")))
})
