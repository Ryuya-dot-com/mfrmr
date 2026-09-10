# Conditional linking-offset checks, not refits or simulated response studies.
pkgload::load_all('.', quiet = TRUE)
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else file.path(tempdir(), 'mfrmr-offset-sensitivity')
dir.create(out, recursive = TRUE, showWarnings = FALSE)
make_chain <- function(diffs, se = rep(NA_real_, length(diffs)), threshold = 0.5) {
  info <- mfrmr:::compute_equating_offset(diffs, se, se, threshold)
  structure(list(config = list(waves = c('A', 'B'), method = 'screened_common_element_alignment',
    drift_threshold = threshold, min_common_per_facet = 5L),
    links = data.frame(Link = 1L, FromID = 1L, ToID = 2L, From = 'A', To = 'B', Offset = info$offset),
    element_detail = data.frame(LinkID = rep(1L, length(diffs)), Facet = rep('Item', length(diffs)),
      Level = sprintf('I%d', seq_along(diffs)), Est_From = rep(0, length(diffs)), Est_To = diffs,
      SE_From = se, SE_To = se, Retained = info$retained, Flag = abs(info$residual) > threshold)
  ), class = c('mfrm_equating_chain', 'list'))
}
mixed <- make_chain(c(0, 0.4, 0.8, 2))
mixed$config$waves <- c('A', 'B', 'C')
mixed$links <- rbind(mixed$links, data.frame(Link = 2L, FromID = 2L, ToID = 3L,
  From = 'B', To = 'C', Offset = 0.25))
mixed$element_detail <- rbind(mixed$element_detail, data.frame(LinkID = 2L, Facet = 'Item',
  Level = 'I1', Est_From = 0, Est_To = 0.25, SE_From = NA_real_, SE_To = NA_real_, Retained = TRUE, Flag = FALSE))
fit <- readRDS('inst/validation/plot-models-0.2.4/fits.rds')[['PCM-interaction-MML']]
actual <- suppressWarnings(build_equating_chain(list(A = fit, B = fit), anchor_facets = 'Criterion'))
cases <- list(rescreen = make_chain(c(0, 0.4, 0.8, 2)), partial = mixed,
  unavailable = make_chain(0.5), weighted = make_chain(c(0, 1, 2), c(1, 2, NA_real_), Inf),
  empty = make_chain(numeric()), public_builder = actual)
drawings <- list()
for (case in names(cases)) for (preset in c('publication', 'monochrome')) for (notes in c(TRUE, FALSE)) {
  key <- paste(case, preset, if (notes) 'annotated' else 'clean', sep = '-')
  p <- plot(cases[[case]], type = 'offset_sensitivity', draw = FALSE, preset = preset,
    show_title = notes, show_notes = notes)
  for (device in c('png', 'pdf')) {
    path <- file.path(out, paste0(key, '.', device))
    if (device == 'png') png(path, width = 5, height = 4, units = 'in', res = 150)
    else pdf(path, width = 5, height = 4)
    warnings <- character()
    error <- tryCatch(withCallingHandlers({
      q <- plot(cases[[case]], type = 'offset_sensitivity', preset = preset,
        show_title = notes, show_notes = notes)
      stopifnot(identical(p, q))
      ''
    }, warning = function(w) {warnings <<- c(warnings, conditionMessage(w)); invokeRestart('muffleWarning')}),
      error = function(e) conditionMessage(e))
    dev.off()
    drawings[[length(drawings) + 1L]] <- data.frame(Case = case, Preset = preset, Notes = notes,
      Device = device, Error = error, Warnings = paste(unique(warnings), collapse = ' | '))
  }
  if (preset == 'publication' && notes) {
    for (table in names(p$data$data)) write.csv(p$data$data[[table]],
      file.path(out, paste0(case, '-', table, '.csv')), row.names = FALSE)
    write.csv(p$data$notes, file.path(out, paste0(case, '-notes.csv')), row.names = FALSE)
  }
}
drawings <- do.call(rbind, drawings)
write.csv(drawings, file.path(out, 'drawings.csv'), row.names = FALSE)
stopifnot(all(drawings$Error == ''))
files <- c('R/api-advanced.R', 'R/api-plotting-anchor-qc.R', 'R/api-plotting.R',
  'R/api-plotting-fit-family.R', 'tests/testthat/test-offset-sensitivity.R',
  'inst/validation/offset-sensitivity-0.2.4.R', 'inst/validation/plot-models-0.2.4/fits.rds')
write.csv(data.frame(File = files, MD5 = unname(tools::md5sum(files))), file.path(out, 'source-md5.csv'), row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(out, 'session-info.txt'))
print(drawings)
