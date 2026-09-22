## Submission

This is an update from mfrmr 0.2.3.1 to 0.2.4. The maintainer and license are
unchanged.

The release adds portable calibration and scoring for eligible one-scale RSM
and PCM MML fits under a fixed standard-normal scoring basis. Calibration
review, validation, freezing, persistence, and scoring are separate public
operations. Portable calibration for GPCM and JML is not supported in this
release; their documented fitted-model workflows remain available.

The release also strengthens fitted-model scoring, replay of interaction
models, and MML EM checkpoint compatibility and resumption checks.

## Test environments

The unchanged package payload was checked on:

- macOS with R-release;
- Windows with R-release;
- Ubuntu with R-devel;
- Ubuntu with R-release, including the full package test suite; and
- Ubuntu with R-oldrel-1.

All five jobs completed successfully. A local arm64 macOS source-package build
and `R CMD check --no-manual` completed with 0 errors, 0 warnings, and 0 notes.
Package tests, examples, complete vignette rebuilding, and fresh-process
installed-package scoring also passed.

The exact 0.2.4 source tarball will be rebuilt and checked after these
version-only changes. The results above are not represented as that final
source-tarball check or as authorization to submit.

The CRAN dependency index reported no reverse Depends, Imports, LinkingTo,
Suggests, or Enhances relationships for mfrmr 0.2.3.1, so there was no
reverse-dependent package suite to run.

External proprietary software is not required to install, check, or use the
package.
