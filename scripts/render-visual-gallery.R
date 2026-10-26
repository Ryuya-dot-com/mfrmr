# Run from the package root with the matching mfrmr candidate installed.
# The article is the executable source for the README preview as well.
recipe <- tempfile(fileext = ".R")
knitr::purl("vignettes/articles/visual-gallery.Rmd", output = recipe,
  documentation = 0, quiet = TRUE)
gallery <- new.env(parent = globalenv())
tryCatch(sys.source(recipe, envir = gallery), finally = unlink(recipe))

figures <- list(gallery$rater_gg, gallery$plan_gg, gallery$curve_gg)
titles <- c("1  Understand rater differences", "2  Compare rating plans",
  "3  Explain score probabilities")
short_axes <- c("Rater severity (logits)", "Tasks per person", "Person location (logits)")
for (i in seq_along(figures)) {
  figures[[i]] <- figures[[i]] + ggplot2::labs(title = titles[i], x = short_axes[i]) +
    ggplot2::theme(text = ggplot2::element_text(size = 15),
      plot.title = ggplot2::element_text(size = 17, face = "bold", colour = "#152B46"),
      legend.text = ggplot2::element_text(size = 12),
      axis.title = ggplot2::element_text(size = 13),
      plot.margin = ggplot2::margin(12, 14, 12, 14))
}
figures[[2]] <- figures[[2]] + ggplot2::labs(y = "Dependability (Phi)") +
  ggplot2::guides(colour = ggplot2::guide_legend(nrow = 2),
    linetype = ggplot2::guide_legend(nrow = 2), shape = ggplot2::guide_legend(nrow = 2))
figures[[3]] <- figures[[3]] + ggplot2::labs(y = "Score probability")

dir.create("man/figures", showWarnings = FALSE)
grDevices::png("man/figures/visual-gallery.png", width = 2400, height = 900,
  res = 160, bg = "white")
tryCatch({
  grid::grid.newpage()
  grid::pushViewport(grid::viewport(layout = grid::grid.layout(1, 3)))
  for (i in seq_along(figures)) print(figures[[i]], newpage = FALSE,
    vp = grid::viewport(layout.pos.row = 1, layout.pos.col = i))
}, finally = grDevices::dev.off())
cat("Wrote man/figures/visual-gallery.png from the article's three ggplots.\n")
