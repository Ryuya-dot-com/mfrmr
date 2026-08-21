# Fixed-calibration G4 native macOS installed-payload record for mfrmr 0.2.4

Status: `macos_release_native_installed_preflight_pass`, 2026-08-22.

- Native preflight: `macos-release-native-preflight`
- Prospective workflow cell: `macos-release` (still pending)
- Evidence scope: `native_macos_isolated_installed_source_tarball`
- Source tarball SHA-256:
  `2e0009293188d9f8c2d701395fe2f56fcf3e88244b73623dca4afb44a965def2`
- Declared package version in the development payload: `0.2.3`
- R: `R version 4.6.1 (2026-06-24)`, release status
- Platform: `aarch64-apple-darwin23`
- Kernel family/release: `Darwin 25.5.0`
- Session locale: `C.UTF-8/C.UTF-8/C.UTF-8/C/C.UTF-8/C.UTF-8`
- Allocation profiling available: `TRUE`
- G4 tests: `11`
- Expectations: `114`
- Failures/errors/warnings/skips: `0/0/0/0`

## Execution boundary

The current source tree was built with `R CMD build`, and the resulting
tarball was installed into a newly created isolated library. A separate
`Rscript --vanilla` process placed that library first, loaded `mfrmr` from the
installed package directory, and ran the complete repository-only G4 test
file. The nested fresh-process scoring worker inherited the isolated-library
requirement and proved that it also loaded the installed package rather than
calling `pkgload::load_all()` on the source tree.

The complete G4 numerical, adversarial, persistence, locale/encoding,
fresh-process, and small/medium/30,000-row resource denominator passed. The
material alternative-prior review result remains a deliberate non-robustness
finding; it was neither discarded nor converted into a pass claim.

## Scope and consequence

This closes the native installed-payload preflight. It is stronger than the
earlier source-tree run because both scoring processes used the built package
payload. It is not evidence for Windows, Linux, R-devel, or oldrel, and it is
not identical to the prospectively required GitHub-hosted `macos-latest`
workflow cell. Treating it as a substitute after seeing the result would
change the frozen acceptance rule. The macOS workflow cell therefore remains
the first priority, followed by Windows release and Ubuntu devel, release, and
oldrel-1.

- `MacOSReleaseNativePreflightComplete=TRUE`
- `MacOSReleaseWorkflowComplete=FALSE`
- `RemainingRequiredWorkflowCells=5`
- `CORE06Complete=FALSE`
- `G4ExitComplete=FALSE`
- `PublicAPIAuthorized=FALSE`
- `OptionalLaneAuthorized=FALSE`

No commit, push, or remote workflow execution is represented by this local
record.
