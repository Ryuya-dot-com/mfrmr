# mfrmr 0.2.4

## Changes

This update connects many-facet measurement, G/D-study planning and rater
feedback through shared tables, figures and reports. It adds Stan export for
single-family GPCM with its estimated normal population and supported fixed
anchors, optional MML starting-value reviews, and EM/hybrid estimation for
RSM/PCM interaction models. NEWS and the migration guide explain corrections
affecting saved analyses and replacements for retired plotting helpers.

## Checks

Windows Server 2022 x64, win-builder, 2026-10-27:

- [R 4.5.3 (oldrelease)](https://win-builder.r-project.org/k7x3sA0l96uQ/00check.log): 0 errors, 0 warnings, 0 notes;
  1,493 seconds check time (examples 195 seconds; tests 573 seconds).
- [R 4.6.1 (release)](https://win-builder.r-project.org/Am74Ro2r7Okx/00check.log): 0 errors, 0 warnings, 0 notes;
  1,540 seconds check time (examples 200 seconds; tests 530 seconds).

macOS arm64, R 4.6.1, 2026-10-27:
`R CMD check --as-cran --timings`: 0 errors, 0 warnings, 0 notes;
603 seconds elapsed (examples 63 seconds; tests 146 seconds).

After the macOS check, a reporting correction for facet labels containing commas
passed targeted installed-package tests. Both Windows checks include this
correction; the full macOS check was not repeated after it.

The submission archive was subsequently reduced to 7,587,204 bytes by lossless
data/image compression and stronger gzip compression. No files were removed.
Serialized data streams are byte-identical, and image pixels and rendering
metadata are unchanged. Executable code, help text and test programs are
unchanged. R's internal extraction, fresh installation and packaged-data tests
pass. The full checks above were not repeated for this storage-only change.

Long workflows have explicit `\dontrun{}` examples with execution instructions;
short examples and representative numerical tests remain active. The complete
test suite is available with `NOT_CRAN=true`.

## Reverse dependencies

No reverse dependencies were listed in the CRAN package index checked on
2026-10-26.
