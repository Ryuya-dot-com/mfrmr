# Run from the package root: Rscript --vanilla scripts/stage-package.R /tmp/path/mfrmr
# R CMD build copies the tree before applying .Rbuildignore. Prune research
# directories first, using the running R version's own exclusion rules.
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L || !file.exists('DESCRIPTION') || !file.exists('.Rbuildignore'))
  stop('Run from the package root and supply one new destination directory.')
root <- normalizePath('.')
destination <- path.expand(args[[1L]])
if (file.exists(destination)) stop('The destination already exists; choose a new directory.')
dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
destination <- file.path(normalizePath(dirname(destination)), basename(destination))
if (startsWith(destination, paste0(root, '/')) || identical(destination, root))
  stop('The destination must be outside the package source tree.')
excluded <- getFromNamespace('inRbuildignore', 'tools')
dir.create(destination)
files <- character()
walk <- function(relative = '', ancestors = character()) {
  directory <- normalizePath(file.path(root, relative), mustWork = TRUE)
  if (directory %in% ancestors) stop('Directory-link cycle at: ', relative)
  entries <- list.files(directory, all.files = TRUE, no.. = TRUE)
  paths <- if (nzchar(relative)) file.path(relative, entries) else entries
  paths <- paths[!excluded(paths, root)]
  for (path in paths) {
    src <- file.path(root, path)
    dst <- file.path(destination, path)
    if (dir.exists(src)) {
      dir.create(dst, recursive = TRUE)
      walk(path, c(ancestors, directory))
    } else {
      if (!file.exists(src) || !file.copy(src, dst, copy.mode = TRUE, copy.date = TRUE))
        stop('Cannot copy: ', path)
      files <<- c(files, path)
    }
  }
}
walk()
original <- tools::md5sum(file.path(root, files))
staged <- tools::md5sum(file.path(destination, files))
if (!identical(unname(original), unname(staged))) stop('Staged files differ from source.')
cat(length(files), 'source files copied with matching bytes into', destination, '\n')
# Generated Rd files already contain this documentation. Keep the editable
# roxygen source in the checkout and omit only its duplicated comments from
# the distribution. Blank lines preserve source line numbers. Ordinary code
# comments, including attribution and license notices, are retained.
removed <- 0
for (path in files[grepl('^R/.*[.]R$', files)]) {
  src <- file.path(root, path)
  dst <- file.path(destination, path)
  code <- parse(src, keep.source = TRUE)
  tokens <- utils::getParseData(code)
  documentation <- tokens$line1[tokens$token == 'COMMENT' &
    startsWith(tokens$text, "#'")]
  if (!length(documentation)) next
  lines <- readLines(src, warn = FALSE, encoding = 'UTF-8')
  documentation <- documentation[grepl("^[[:space:]]*#'", lines[documentation])]
  lines[documentation] <- ''
  if (!identical(parse(src, keep.source = FALSE),
                 parse(text = lines, keep.source = FALSE)))
    stop('Documentation removal changed R code: ', path)
  writeLines(lines, dst, useBytes = TRUE)
  removed <- removed + file.info(src)$size - file.info(dst)$size
}
cat(removed, 'duplicated documentation bytes omitted; parsed R code is identical.\n')
# R CMD build still applies its remaining standard exclusions and transformations.
