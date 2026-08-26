## Submission

This is an update from mfrmr 0.2.3.1 to 0.2.4. The maintainer and license are
unchanged.

The release adds a portable-calibration workflow with separate draft, review,
validation, freezing, persistence, and artifact-only scoring operations. Its
supported scope is deliberately limited to eligible one-scale RSM and PCM MML
fits under a fixed-standard-normal scoring basis. Portable-calibration routes
for GPCM and JML are unavailable in this release; their existing fitted-object
workflows remain available under the documented readiness conditions.

The release also strengthens fitted-object scoring, replay of interaction
models, and MML EM checkpoint identity and resumption checks.

## Test environments

Before the metadata-only candidate transition, the unchanged package payload
was checked on:

- macOS, R-release;
- Windows, R-release;
- Ubuntu, R-devel;
- Ubuntu, R-release, including the full package test suite; and
- Ubuntu, R-oldrel-1.

All five jobs completed successfully. A local arm64 macOS source-package
build and ordinary `R CMD check --no-manual` completed with 0 errors,
0 warnings, and 0 notes. Package tests, examples, complete vignette rebuilding,
and fresh-process installed-package scoring also passed.

The exact 0.2.4 candidate source tarball will be rebuilt and checked after this
metadata transition. These pre-candidate results are not represented as that
final candidate check or as authorization to submit.

The CRAN dependency index reported no reverse Depends, Imports, LinkingTo,
Suggests, or Enhances relationships for mfrmr 0.2.3.1, so there was no
reverse-dependent package suite to run.

External proprietary software is not required to install, check, or use the
package.
