# Load repository-only numerical reference implementations without modifying
# the installed package namespace. Use a package built from matching sources.
load_mfrmr_research_code <- function(source_dir = ".") {
  directory <- file.path(source_dir, "inst", "validation", "reference-code")
  files <- list.files(directory, pattern = "\\.R$", full.names = TRUE)
  if (!length(files)) stop("Repository reference code is unavailable: ", directory)
  reference <- new.env(parent = asNamespace("mfrmr"))
  for (path in sort(files)) sys.source(path, envir = reference, keep.source = FALSE)
  reference
}
