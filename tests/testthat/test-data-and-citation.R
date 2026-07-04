test_that("packaged data aliases and loaders are available", {
  aliases <- mfrmr::list_mfrmr_data()
  expect_true(is.character(aliases))
  expect_true(all(c("study1", "study2", "combined") %in% aliases))

  d <- mfrmr::load_mfrmr_data("study1")
  expect_s3_class(d, "data.frame")
  expect_true(all(c("Person", "Rater", "Criterion", "Score") %in% names(d)))
  expect_gt(nrow(d), 0)
})

test_that("packaged simulation data states its source boundary", {
  readme <- system.file("extdata", "README_sim_data.txt", package = "mfrmr")
  expect_true(nzchar(readme))
  expect_true(file.exists(readme))

  txt <- paste(readLines(readme, warn = FALSE), collapse = "\n")
  expect_true(grepl("Eckes & Jin (2021)", txt, fixed = TRUE))
  expect_true(grepl("does not include the original TestDaF operational response rows", txt, fixed = TRUE))
  expect_true(grepl("package-authored synthetic artifacts", txt, fixed = TRUE))
  expect_true(grepl("should not be cited as reproductions", txt, fixed = TRUE))
})

test_that("citation metadata is available", {
  cit <- utils::citation("mfrmr")
  expect_true(length(cit) >= 1)

  cit_file <- system.file("CITATION", package = "mfrmr")
  expect_true(nzchar(cit_file))
  expect_true(file.exists(cit_file))
})
