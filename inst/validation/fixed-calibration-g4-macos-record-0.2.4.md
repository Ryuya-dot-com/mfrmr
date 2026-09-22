# Fixed-calibration G4 native macOS installed-payload record for mfrmr 0.2.4

Status: `macos_release_native_and_hosted_complete`, 2026-08-22.

- Native preflight: `macos-release-native-preflight`
- Prospective workflow cell: `macos-release` (passed in run `32534030853`)
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
- Numerical/operational denominator expectations: `121`
- Post-adjudication record/scope-integrity expectations: `129`
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

## Retained hosted attempts and clean run

GitHub Actions run `32530223829` at commit
`d307031a5a4fea79ebf8c810eba2c691169c067d` is retained as the first hosted
macOS attempt. R CMD check and repository release-readiness passed. The G4 step
then stopped before entering the test file because `pkgload::load_all()`
requested the non-project development helper `decor`; the four jobs dependent
on macOS were skipped. This is a workflow bootstrap failure, not numerical or
operational confirmation evidence. The replacement loader uses the package
already installed under `check/mfrmr.Rcheck`, and propagates that installed
library to the vanilla child process. It changes no production code, fixture,
identity, numerical rule, denominator, or decision threshold. The failed
attempt remains visible and a fresh hosted run was required.

Actions run `32531360127` at commit
`a23c009bb1106fb7fd676e7febcc9b90a6cb9a1b` then passed the hosted macOS cell
and all three Ubuntu cells. Its Windows release cell failed in the vanilla
child because equivalent installed-library paths used different Windows
separator/case representations. The correction canonicalizes the two paths
without changing production code, fixtures, confirmation identities,
numerical rules, the denominator, or thresholds. The failed Windows cell is
retained and cannot be pooled with a later result.

Fresh Actions run `32534030853` at commit
`f492fb9f0ee977777d03f0255de008af33860db5` passed the hosted macOS release
prerequisite in 10m24s (job `96931462336`), then passed Windows release and
Ubuntu devel/release/oldrel-1. Every cell passed R CMD check, repository
release-readiness, and all 121 G4 expectations with zero failures, errors,
warnings, or skips. No earlier result was pooled into that five-cell run.

## Scope and consequence

The native installed-payload preflight remains distinct from hosted evidence;
it was not used as a post-result substitute. Run `32534030853` independently
closes the prospectively required GitHub-hosted `macos-latest` cell and all
four downstream platform/R cells on the same commit. This closes CORE-06 and
G4 for the fixed-basis RSM/PCM core only. It does not authorize the public API,
prior robustness, population transport, or an optional lane.

- `MacOSReleaseNativePreflightComplete=TRUE`
- `MacOSReleaseWorkflowComplete=TRUE`
- `RemainingRequiredWorkflowCells=0`
- `HostedMacOSAttempt1Retained=TRUE`
- `HostedMacOSAttempt1DenominatorOpened=FALSE`
- `HostedWindowsPathHarnessAttemptRetained=TRUE`
- `HostedWorkflowRun=32534030853`
- `CORE06Complete=TRUE`
- `G4ExitComplete=TRUE`
- `PublicAPIAuthorized=FALSE`
- `OptionalLaneAuthorized=FALSE`
