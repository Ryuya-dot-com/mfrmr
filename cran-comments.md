## Test environments

- local macOS (aarch64-apple-darwin20), R 4.5.2
- GitHub Actions ubuntu-latest, R-release
- GitHub Actions ubuntu-latest, R-devel
- GitHub Actions ubuntu-latest, R-oldrel
- GitHub Actions macos-latest, R-release
- GitHub Actions windows-latest, R-release
- win-builder, R-release (R version 4.5.3 (2026-03-11 ucrt))
- win-builder, R-devel (R Under development (unstable) (2026-03-22 r89674 ucrt))

## R CMD check results

- local `R CMD check --as-cran --no-manual`: 0 errors | 0 warnings | 1 note
- GitHub Actions `R-CMD-check`: all matrix jobs passed
- current NOTE: `New submission`

## Downstream dependencies

This is a new package with no reverse dependencies.

## Notes

- This is a new submission.
- win-builder `R-release` returned `Status: 1 NOTE`; the NOTE is the standard
  new-submission NOTE with spell-check flags for proper names cited in
  `DESCRIPTION` (`Aitkin`, `Andrich`, `Linacre`, `Rasch`).
- win-builder `R-devel` returned `Status: 1 NOTE`; the NOTE is the standard
  new-submission NOTE with spell-check flags for proper names cited in
  `DESCRIPTION` (`Aitkin`, `Andrich`, `Linacre`, `Rasch`).
