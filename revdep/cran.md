# Reverse dependency check (mfrmr 0.2.0)

mfrmr has no reverse dependencies on CRAN. This was confirmed via
`revdepcheck::cran_revdeps("mfrmr")` returning an empty character vector.

The empty result is expected: mfrmr 0.1.6 was published in April 2026 and
has not yet been adopted as a dependency by any other CRAN package. Once
reverse dependencies appear, this directory will be populated by
`revdepcheck::revdep_check()` runs and the resulting reports will be
summarised here.
