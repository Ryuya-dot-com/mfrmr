# mfrmr 0.2.4

## Changes

This update connects many-facet measurement, G/D studies and rater feedback
to shared tables, figures and reports. It adds supported single-family GPCM
and fixed-anchor exports to Stan/brms. NEWS and the migration guide explain
retired plotting helpers and corrections affecting saved analyses.

## Checks

Windows Server 2022, R 4.5.3 (win-builder, R-oldrelease): the preceding
candidate completed with 0 errors, 0 warnings and 2 NOTEs. Tests, vignette
rebuilding and PDF/HTML manuals passed.
Installation took 240 seconds and checking took 3,669 seconds.

- Incoming URL checks: publisher links with verified DOIs now use those
  DOIs. Two references without a DOI listed in PubMed retain complete
  citations and PMIDs. The README roadmap link now uses its repository URL.
- Example timings: 21 examples took 10.4–37.1 seconds. Four affected examples
  now reuse packaged synthetic fits with regeneration code; their interval,
  curve and export calculations remain executable with unchanged settings.
  Their numerical outputs were checked against the preceding examples.

macOS arm64, R 4.6.1: the preceding candidate passed a full
`R CMD check --as-cran --timings` with 0 errors, 0 warnings and 2 NOTEs
(a 5.007-second example and macOS `xcrun_db` temporary-file detritus).
The revised R sources, help and rebuilt articles passed a scoped check with
0 errors, 0 warnings and the `xcrun_db` NOTE; affected tests and examples were
checked separately. This was not another full test run. Remote incoming and
system-clock checks were disabled locally after DNS failures.

Updated Windows/R-devel results are not yet available.

## Reverse dependencies

No reverse dependencies were listed in the CRAN package index checked on
2026-10-26.
