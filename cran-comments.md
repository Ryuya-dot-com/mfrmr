# mfrmr 0.2.4

## Resubmission

The examples and tests failed because recompressing the bundled model-data file
changed its checksum, while the posterior summary retained the original checksum.
The original model-data bytes have been restored. The reader's integrity checks
remain unchanged, and a regression test covers equal data with different file
encodings. No model estimates or posterior summaries were recalculated.

The DESCRIPTION term "generalizability" is intentional: it refers to
generalizability theory (G-theory).

## Checks

macOS arm64, R 4.6.1, 2026-10-28:
`R CMD check --as-cran --timings` on the corrected archive: 0 errors,
0 warnings, 0 notes; 514 seconds elapsed (examples 55 seconds; tests 134 seconds).
The affected examples and installed posterior-reader, reporting and plotting
tests pass. The corrected archive has not yet been checked on Windows or Debian;
the incoming failures reported above concern the previous archive.

## Overall checktime

The previous Windows incoming check reported 22 minutes, including 321 seconds
for static R-code analysis and 510 seconds for tests. Its examples stopped at
the checksum error, so their 104 seconds are not a complete example timing.
This checksum correction does not resolve or claim compliance with the
ten-minute criterion.

Long workflows use explicit `\dontrun{}` examples. Ordinary tests retain real
estimation and independent numerical checks across measurement, G/D studies
and rater feedback, with at most two workers. The broader test suite runs with
`NOT_CRAN=true`.

## Reverse dependencies

No strong reverse dependencies were identified by the incoming check.
