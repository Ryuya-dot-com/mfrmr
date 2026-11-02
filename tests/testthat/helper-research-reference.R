# Repository-only reference calculations retain their own lexical environment.
source(testthat::test_path("..", "..", "scripts", "load-research-code.R"), local = TRUE)
.mfrmr_research <- load_mfrmr_research_code(testthat::test_path("..", ".."))

local_research_bindings <- function(..., .package = "mfrmr", .env = parent.frame()) {
  bindings <- list(...)
  research <- intersect(names(bindings), ls(.mfrmr_research, all.names = TRUE))
  if (length(research)) {
    do.call(rlang::local_bindings, c(bindings[research],
      list(.env = .mfrmr_research, .frame = .env)))
  }
  retained <- setdiff(names(bindings), research)
  if (length(retained)) {
    do.call(testthat::local_mocked_bindings, c(bindings[retained],
      list(.package = .package, .env = .env)))
  }
  invisible(NULL)
}
