test_that("information conversion preserves selected series and separate units", {
  skip_if_not_installed("ggplot2", minimum_version = "3.4.0")
  theta <- c(-1, 0, 1)
  information <- c(4, 9, 4)
  sem <- 1 / sqrt(information)
  x <- structure(list(
    tif = data.frame(Theta = theta, Information = information, SE = sem),
    iif = data.frame(Theta = rep(theta, 2), Information = c(c(1, 4, 1), c(3, 5, 3)),
      Facet = "Rater", Level = rep(c("A", "B"), each = 3), Exposure = 1)
  ), class = "mfrm_information")
  for (type in c("tif", "se", "sem", "csem", "both", "iif")) {
    saved <- plot(x, type = type, draw = FALSE)
    expected <- switch(type, tif = information, both = c(information, sem),
      iif = x$iif$Information, sem)
    p <- as_ggplot(saved)
    expect_equal(p$data$Value, expected, info = type)
    built <- ggplot2::ggplot_build(p)
    expect_equal(sort(built$data[[1]]$y), sort(expected), info = type)
    expect_equal(length(unique(built$data[[1]]$PANEL)), if (type == "both") 2L else 1L)
    if (type == "both") expect_equal(length(built$layout$panel_scales_y), 2L)
    if (type == "iif") expect_identical(unique(p$data$Series), c("A", "B"))
    expect_identical(plot_data(p), plot_data(saved))
    expect_null(p$labels$title)
    expect_null(p$labels$subtitle)
    expect_null(p$labels$caption)
    expect_equal(nrow(plot_data(p)$information_long), 6L)
    if (type %in% c("tif", "sem")) {
      expect_match(p$labels$y, if (type == "tif") "information" else "SEM")
    }
    file <- tempfile(fileext = ".rds")
    on.exit(unlink(file), add = TRUE)
    saveRDS(saved, file)
    expect_identical(as_ggplot(readRDS(file))$data, p$data)
    expect_identical(as_ggplot(x, type = type)$data, p$data)
  }
})
