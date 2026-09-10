# Run from the package root:
# Rscript inst/validation/plot-ux-0.2.4.R /tmp/mfrmr-plot-review
# Small drawing fixtures only; this does not run a recovery simulation.
pkgload::load_all(".", quiet = TRUE)
source("tests/testthat/helper-fixtures.R")
args <- commandArgs(trailingOnly = TRUE)
out_dir <- if (length(args)) args[1L] else file.path(tempdir(), "mfrmr-plot-review")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
fits <- list(RSM = make_toy_fit(maxit = 20), PCM = make_toy_fit(model = "PCM", maxit = 20))
draw_review <- function(expr) {
  withCallingHandlers(expr, warning = function(w) {
    if (grepl("^Review-only display:", conditionMessage(w))) invokeRestart("muffleWarning")
  })
}
render <- function(name, width, height, expr) {
  grDevices::png(file.path(out_dir, name), width = width, height = height,
                 units = "in", res = 150)
  on.exit(grDevices::dev.off(), add = TRUE)
  draw_review(force(expr))
}
for (model in names(fits)) {
  fit <- fits[[model]]
  for (size in list(c(7, 5), c(5, 4))) {
    render(sprintf("%s-%sx%s-%%02d.png", model, size[1], size[2]), size[1], size[2],
           plot(fit, type = "bundle", preset = "publication"))
  }
}
render("grid.png", 10, 10, {
  graphics::par(mfrow = c(2, 2))
  for (type in c("pathway", "person", "step", "fit_pathway")) {
    plot(fits$RSM, type = type, preset = "compact")
  }
})
render("apa.png", 12, 9, plot_apa_figure_one(fits$RSM, preset = "publication"))
render("wright-groups.png", 7, 5,
       plot(fits$RSM, type = "wright", preset = "publication",
            group = rep(c("A", "B"), length.out = nrow(fits$RSM$facets$person))))
source_files <- list.files("R", pattern = "[.]R$", full.names = TRUE)
write.csv(data.frame(File = source_files, MD5 = unname(tools::md5sum(source_files))),
          file.path(out_dir, "source-md5.csv"), row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(out_dir, "session-info.txt"))
cat("Figures written to", normalizePath(out_dir), "\n")
