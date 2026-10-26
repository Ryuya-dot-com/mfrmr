# Unreleased 0.2.4 candidate — not for submission

## Current artifact

Candidate SHA256: `b720f2ee1c7fbf5344e722f73ab96a22ff866bf1359ff5d29498916e167b03be`.

This candidate contains the integrated measurement, assessment-planning and
reporting workflows, the ggplot2/Plotly gallery documentation, and a repaired
CASMA reference link. The gallery is website-only; Plotly and htmlwidgets are
website dependencies rather than package installation requirements.

## Local checks and source attribution

The preceding numerical check archive
`089c7fa309ed021cfabcc005aaec21af90397f67034acb285c1d5b8b0f9e4b55`
completed R 4.6.1 arm64 `--as-cran --timings` with zero errors/warnings and two
NOTEs. All 14,241 ordinary expectations passed, with three established CRAN
skips; examples, vignette rebuilding and PDF/HTML manuals passed.

One NOTE identified two code-usage issues. Spelling dotchart's `color` argument
in full and qualifying `graphics::plot.window` resolved those findings. The
repaired installation passed 808 expectations in eight affected files and the
same code-usage checks. The remaining NOTE concerns macOS `xcrun_db` residue.
Foreign-namespace test mocks were replaced with package-owned bindings.

Subsequent changes are documentation/metadata only. Runtime R expressions,
C++, data, tests and exports retain their qualified identity. The gallery
candidate installs; all 19 vignette index entries, updated help links, saved
plot reconstruction and long-table export have been checked. The present
citation repair retains all other archive bytes except the Packaged field.

The recorded check-only elapsed time was 553.596 seconds on the earlier
archive. This is not a new full check or timing certificate for the current
archive. Remote incoming and clock checks were disabled during that local run.

## Dependencies and URLs

The October 26 CRAN source index contains 25,559 packages and lists no reverse
Depends, Imports, LinkingTo, Suggests or Enhances for mfrmr. All 43 distinct
external package dependencies are available; seven further dependencies are
supplied by R. Declared minimum versions are satisfied in the checked local
environment and available package index. Non-CRAN consumers are outside this
reverse-dependency check.

URL review covered 532 occurrences / 247 distinct references, including 191
HTTP(S) URLs, with HTTP status exclusions disabled. Eighteen URLs were flagged:
one CASMA 404 was repaired and the replacement passed; eleven links point to
new repository/site content awaiting publication. Their local targets exist.
The remaining six findings are two PubMed browser checks (203), two access
refusals (403), and two connection timeouts. These are not a clean automated
URL result; no blanket URL exclusions were added.

## Still required before submission

Matching-source platform checks, remote incoming checks, hosted links and
browser interaction/layout verification remain open. The local source has not
been published or submitted to CRAN. Package installation and attributed
checks do not establish CRAN acceptance or current-source Windows qualification.
