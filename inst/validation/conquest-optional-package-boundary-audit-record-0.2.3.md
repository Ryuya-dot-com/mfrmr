# ConQuest optional package-boundary audit for mfrmr 0.2.3

Status: `conquest_optional_package_boundary_passed`, 2026-08-15.

- Specification: `0.2.3-conquest-optional-package-boundary-audit-v1`
- Contract: `mfrmr_conquest_optional_package_boundary_audit_v1`

## Boundary

ConQuest remains an optional external comparator. The installed package keeps
pure-R functions that prepare command text and data files, normalize explicitly
provided CSV tables, and review normalized inputs. It contains no ConQuest
executable, does not discover or launch one, and has no machine-specific
ConQuest path or declared ConQuest package dependency.

Repository-only external validation is a different surface. `.Rbuildignore`
excludes `inst/validation`, `validation-results`, and every
`tests/testthat/test-conquest-*.R` file from the source package. Ordinary tests
may exercise the pure-R handoff APIs, but cannot call a ConQuest executable.

## Static audit

- `PackageDependencyDeclared=FALSE`
- `RuntimeLaunchPrimitiveDetected=FALSE`
- `RuntimeMachinePathDetected=FALSE`
- `OrdinaryTestLaunchPrimitiveDetected=FALSE`
- `OrdinaryTestMachinePathDetected=FALSE`
- `SourceDistributionExternalBinaryDetected=FALSE`
- `ValidationTreeExcluded=TRUE`
- `ValidationResultsExcluded=TRUE`
- `ExternalConQuestTestsExcluded=TRUE`
- `PureRHandoffExportsPresent=TRUE`

## Source-package observation

A normal vignette-bearing source package was built in an isolated temporary
directory with `R CMD build --no-manual`. Its member list contained no
`inst/validation`, `validation-results`, `test-conquest-*`, machine path, or
ConQuest executable artifact. `R CMD check --no-manual mfrmr_0.2.3.tar.gz`
then completed with `Status: OK` without requiring ConQuest. Restricted-network
repository-index messages occurred during dependency discovery but did not
change the check status.

An earlier deliberately vignette-free diagnostic exposed a pre-existing test
boundary error: the installed-artifact test tried to read the intentionally
excluded vignette generator. The test now inspects that generator only when it
exists in a development checkout; installed/source-package tests continue to
validate the distributed semantic manifest and artifacts themselves. No
validation file was added back to the package.

## Current decision

- `ConQuestOptionalComparator=TRUE`
- `ConQuestRuntimeDependency=FALSE`
- `ConQuestOrdinaryTestDependency=FALSE`
- `ConQuestCRANCheckDependency=FALSE`
- `ExternalValidationAssetsDistributed=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
