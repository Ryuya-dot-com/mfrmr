test_that("publication checks cover new files and consistent release metadata", {
  source_root <- normalizePath(test_path("..", ".."))
  script <- file.path(source_root, "scripts", "check-publication-boundary.R")
  skip_if_not(file.exists(script), "Repository-only publication check")
  skip_if(!nzchar(Sys.which("git")), "git is required")
  root <- withr::local_tempdir()
  withr::local_dir(root)
  expect_identical(system2("git", c("init", "--quiet")), 0L)
  dir.create("inst/validation", recursive = TRUE)
  file.copy(file.path(source_root, "inst/validation/public-release-baseline-0.2.4.csv"),
            "inst/validation/public-release-baseline-0.2.4.csv")
  baseline <- read.csv("inst/validation/public-release-baseline-0.2.4.csv")
  public_version <- baseline$Value[baseline$Field == "PublicVersion"]
  description <- c("Package: mfrmr", "Version: 0.2.4.9000",
    "Config/mfrmr/release-status: development",
    paste("Config/mfrmr/public-version:", public_version))
  writeLines(description, "DESCRIPTION")
  writeLines("version: 0.2.4.9000", "CITATION.cff")
  check <- function() capture.output(sys.source(script, new.env(parent = globalenv())))
  expect_match(check(), "checks passed")

  dir.create("R")
  writeLines("# See internal-roadmap-0.2.4.md", "R/new-api.R")
  expect_error(check(), "Private references")
  writeLines("# Simulation: 500 replications and 95% intervals.", "R/new-api.R")
  expect_match(check(), "checks passed")
  dir.create("inst/examples")
  writeLines("/Users/tohokusla/private/input.csv", "inst/examples/new.txt")
  expect_error(check(), "Private references")
  unlink("inst/examples/new.txt")
  writeLines('{"source": "/Users/tohokusla/private/script.py"}', "inst/validation/new.json")
  expect_error(check(), "Private references")
  writeLines('{"source": "inst/validation/script.py"}', "inst/validation/new.json")
  expect_match(check(), "checks passed")
  writeLines("See internal-roadmap-0.2.4.md for the next action.", "inst/validation/new.md")
  expect_error(check(), "Private references")
  writeLines("The archived protocol is identified by its recorded digest.", "inst/validation/new.md")
  expect_match(check(), "checks passed")
  writeLines('protocol <- "inst/validation/internal-roadmap-0.2.4.md"', "inst/validation/source.R")
  expect_match(check(), "checks passed")
  writeLines("Local instructions", "AGENTS.md")
  expect_error(check(), "Private maintainer files")
  writeLines("AGENTS.md", ".gitignore")
  expect_match(check(), "checks passed")
  expect_identical(system2("git", c("add", "-f", "AGENTS.md")), 0L)
  expect_error(check(), "Private maintainer files")
  expect_identical(system2("git", c("rm", "--cached", "--quiet", "AGENTS.md")), 0L)

  writeLines("version: 0.2.4", "CITATION.cff")
  expect_error(check(), "versions differ")
  writeLines(c("version: 0.2.4.9000", "version: 0.2.4.9000"), "CITATION.cff")
  expect_error(check(), "Duplicate")
  writeLines(c("version: 0.2.4.9000", "date-released: 2026-10-29"), "CITATION.cff")
  expect_error(check(), "must not declare a release date")
  writeLines("version: 0.2.4.9000", "CITATION.cff")
  writeLines(c(description, "Date: 2026-10-29"), "DESCRIPTION")
  expect_error(check(), "must not declare a release date")
  writeLines(sub(paste("public-version:", public_version),
                 "public-version: 0.0.0", description, fixed = TRUE),
             "DESCRIPTION")
  expect_error(check(), "baseline")
  writeLines(sub("release-status: development", "release-status: candidate", description),
             "DESCRIPTION")
  expect_error(check(), "matching.*dates")
  writeLines(c(sub("release-status: development", "release-status: candidate", description),
               "Date: 2026-10-29"), "DESCRIPTION")
  writeLines(c("version: 0.2.4.9000", "date-released: 2026-10-29"), "CITATION.cff")
  expect_match(check(), "checks passed")
})

test_that("CI verifies the checked source and log instead of historical approvals", {
  source_root <- normalizePath(test_path("..", ".."))
  workflow <- file.path(source_root, ".github/workflows/R-CMD-check-cell.yaml")
  skip_if_not(file.exists(workflow), "Repository-only workflow check")
  skip_if_not_installed("yaml")
  skip_if_not_installed("digest")
  steps <- yaml::read_yaml(workflow)$jobs$check$steps
  blocks <- vapply(steps, function(step) if (is.null(step$run)) "" else step$run, "")
  block <- blocks[grepl("receipt <- readRDS", blocks, fixed = TRUE)]
  expect_length(block, 1L)
  expect_false(any(grepl("mfrmr_fc_g4m_review|mfrmr_release_readiness_review", blocks)))
  code <- parse(text = block)
  root <- withr::local_tempdir()
  withr::local_dir(root)
  withr::local_envvar(GITHUB_SHA = paste(rep("a", 40), collapse = ""))
  out <- "validation-results/release-check"
  dir.create(file.path(out, "check/mfrmr.Rcheck"), recursive = TRUE)
  tarball <- file.path(out, "mfrmr_0.2.4.9000.tar.gz")
  log <- file.path(out, "check/mfrmr.Rcheck/00check.log")
  writeLines("Version: 0.2.4.9000", "DESCRIPTION")
  writeLines("source fixture", tarball)
  writeLines("Status: OK", log)
  receipt <- list(CheckComplete = TRUE, Errors = 0L, Warnings = 0L,
    CandidateGitCommit = Sys.getenv("GITHUB_SHA"), PackageVersion = "0.2.4.9000",
    SourceTarballSHA256 = digest::digest(file = tarball, algo = "sha256", serialize = FALSE),
    CheckLogSHA256 = digest::digest(file = log, algo = "sha256", serialize = FALSE))
  check <- function(value = receipt) {
    saveRDS(value, file.path(out, "release-check-receipt.rds"))
    capture.output(eval(code, new.env(parent = globalenv())))
  }
  expect_match(check(), "agree")
  for (change in list(list(CheckComplete = FALSE), list(Warnings = 1L),
                     list(Errors = 1L), list(CandidateGitCommit = "different"),
                     list(PackageVersion = "0.2.4"))) {
    expect_error(check(utils::modifyList(receipt, change)))
  }
  writeLines("changed source", tarball)
  expect_error(check())
  writeLines("source fixture", tarball)
  writeLines("changed log", log)
  expect_error(check())
  unlink(log)
  expect_error(check())
})
