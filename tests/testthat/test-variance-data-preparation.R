test_that("shared variance preparation preserves score labels and route-specific row order", {
  dat <- data.frame(Person = c("p2", "p1", "p1", NA, "p3", "p3"),
    Rater = factor(c("b", NA, "a", "b", "a", "a"), levels = c("b", "a", "unused")),
    Score = factor(c("1", "0", NA, "3", "0", "3"), levels = c("3", "1", "0")),
    Unselected = NA_real_, row.names = letters[1:6])
  saved <- serialize(dat, NULL)
  for (gstudy in c(FALSE, TRUE)) {
    needed <- if (gstudy) c("Person", "Rater", "Score") else c("Score", "Person", "Rater")
    source <- if (gstudy) "Stored fitted rows" else "Supplied data"
    x <- mfrmr:::mfrm_prepare_variance_data(dat, c("Person", "Rater"), "Score", needed,
      "omit", source, gstudy)
    expect_identical(rownames(x$data), c("a", "e", "f"))
    expect_identical(x$data$Score, c(1, 0, 3))
    expect_identical(levels(x$data$Rater), c("b", "a", "unused"))
    expect_identical(x$data_usage$counts, c(InputRows = 6L, UsedRows = 3L, ExcludedRows = 3L))
    expect_identical(x$data_usage$excluded_rows, stats::setNames(2:4, c("b", "c", "d")))
    expect_identical(x$data_usage$source, source)
    expected <- if (gstudy) data.frame(InputRow = c(4L, 2L, 3L), Column = c("Person", "Rater", "Score")) else
      data.frame(InputRow = c(3L, 4L, 2L), Column = c("Score", "Person", "Rater"))
    expect_identical(x$data_usage$missing_cells, expected)
    expect_error(mfrmr:::mfrm_prepare_variance_data(dat, c("Person", "Rater"), "Score", needed,
      "error", source, gstudy), "3 row.*missing")
  }
  expect_identical(serialize(dat, NULL), saved)
})
