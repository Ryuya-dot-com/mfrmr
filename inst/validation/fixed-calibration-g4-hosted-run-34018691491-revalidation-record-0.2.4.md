# Fixed-calibration G4 v6 current-payload revalidation record

Status: `current_payload_v6_regression_revalidation_complete_g4_closed_current_g6_review_required`,
2026-09-06.

## Scope

This record binds the post-change G4 regression revalidation to candidate tag
`g4-v6-candidate-71f3220` and exact commit
`71f32200a21bb349689b7e9d1d327726aeec785c`. The production change since the
previous G4 close included `R/api-export-bundles.R`, so the earlier executable-
boundary result was not silently carried forward.

The modular-1061/1063 fixtures, 49-cell denominator, resource ceilings, and
numerical rules were not changed after observing the earlier v6 result. Their
reuse here is deterministic regression revalidation of a changed package
payload, not a new independent statistical confirmation or additional model-
validity study. The first execution on this candidate passed; no failed result
was repaired and retried under the same candidate.

## Local exact-candidate evidence

The clean candidate produced source tarball SHA-256
`29bbc74c67fa5efaa30ce7973e4fdf04c962ccf901f3d64acebfe43cecbb1847`.
Its candidate manifest hash was
`fb4b584a1e220f9c6ec5e4eb56f56fb20c02638da06cb26900b8e060e2dd4317`;
the production registry hash was
`fa6db587b1d00feb4ea0b8766b59509942b27ee67bbc7cfb8ca658ce9f75f5da`
and the support registry hash was
`50aa50946a35de4294b84930452d3d85d89730f02d7755279990ee6eb22fda80`.
The exact tarball completed `R CMD check --no-manual` with `Status: OK`, and
the installed-package worker returned 49 passes, zero failures, and all three
passing resource scales. The confirmation output hash was
`43fee993cc0fb2e8658a7768001fa25c2ff63b08f1d799d5bd4ceab51b4674d7`;
the local cell receipt hash was
`d7f2115ababf9b79a02e48d23f2bfcf87baf3424a3357b9c426adca56df4363f`.

| Scale | Rows | Elapsed seconds | Profiled allocation bytes | Serialized result bytes |
| --- | ---: | ---: | ---: | ---: |
| small | 120 | 0.010 | 75,384 | 41,405 |
| medium | 6,000 | 0.245 | 31,332,408 | 1,559,915 |
| operational plausible | 30,000 | 1.422 | 676,258,744 | 7,757,915 |

These are regression observations against frozen ceilings, not public
performance claims.

Homebrew GCC 15.2.0 compiled both `src/cpp11.cpp` and
`src/mml_backend.cpp` with `-flto` and linked `mfrmr.so` with `-flto`. The
installed C++ backend passed all 37 pure-R-reference regression expectations.
An earlier successful install attempt was excluded from GCC evidence because
its audited build log showed Apple clang rather than GCC; no result from that
attempt was counted.

## Hosted evidence

Dedicated GitHub Actions run `34018691491` completed successfully. macOS
release ran first, followed by Windows release and Ubuntu devel, release, and
oldrel-1. The aggregation job also succeeded. Each platform independently
built and bound its source tarball, retained 49 passes, zero failures, and
three passing resource scales.

| Cell | Tarball SHA-256 | Manifest hash | Receipt hash |
| --- | --- | --- | --- |
| macos-release | `499399ce338bae4c6b742cc37b6a735cd4f30cc95c01816a743a3fba6a2d13cd` | `4e52fcdd75be9663b0f35bb1460f5e42c4f5a13b5ace8a5310d36c923fdf27ee` | `f1b638547e6e7bce3209696a217fab10dad86a020ddf4bf07a80c2455b43984f` |
| windows-release | `5e74f8e00457b28aa63e692aaf6fe24a20069bb4800b6ffbbe743446f81e5277` | `8954b32b2ff84c69e2340a82e9b55075be87afa5be6b6a24283e6fd26f6e5dbf` | `b10d03568e3099614ffb05ff7428f2d329139f7e448e91a1577bc396a3440ff0` |
| ubuntu-devel | `f5d5443b07287b5dece7f44044a78c8bcf491232645039e0dd2940c521671585` | `6ff555aa50d2ef7d63f1d93b62d3eda9249c333616776764c3a7de873c92278e` | `75e3ecc273ea39bcd94407730a94f32e9484359280ba9b5288b37946e00987d9` |
| ubuntu-release | `e0ca58b4af0ed9332b9a3bf0795b5ef436fe244ea50b75e445cec70a4154c3fc` | `0c4d80d360973a3b0ad5a9de789a51e758ce2b3f82391e9a8ee9a95ecba5caa8` | `8f512ac72b064821444442366ab35c36c5c7fb944dedb0af610647b9b012dd62` |
| ubuntu-oldrel-1 | `c6152392a619a5aad17e9b0785cb32bc424e12c792254963342535c6a8c4c71a` | `f6470609eafc5fb0f9680a0a8adfabe2cb49a66d97626840cbfdbf2208094ab4` | `1a40e0be7682f5e663cbbbc228aedb8486fae1bca667741fbb2735e7c170b5ee` |

Independent post-run recomputation validated all five receipt hashes, their
common candidate commit and portable production/support registries, and the
five-row matrix. The matrix receipt hash is
`ad518251f17e82d8dd90a0cba28bb32415ef1cd44ac5da8d10f61a15b2b124d7`.
Routine check-only run `34014929402` separately passed all five environments
on the same commit; it was not pooled into the G4 denominator.

## Decision boundary

The result restores CORE-05, CORE-06, and G4 for the exact current executable
payload and its declared one-scale fixed-N(0,1) RSM/PCM portable-calibration
boundary. It does not widen that boundary, authorize portable GPCM, or add
independent statistical evidence. G6 and human release review previously
completed for older payloads must be renewed for this current payload before a
new release-candidate transition.

- `CandidateBindingComplete=TRUE`
- `LocalExactTarballCheckComplete=TRUE`
- `LocalDenominatorCells=49`
- `LocalPassedCells=49`
- `LocalFailedCells=0`
- `LocalResourceScalesPassed=3`
- `LocalGCC15LTOCheckComplete=TRUE`
- `InstalledBackendRegressionExpectationsPassed=37`
- `RoutineCheckOnlyPlatformCellsPassed=5`
- `HostedRunId=34018691491`
- `HostedWorkflowConclusion=success`
- `HostedPlatformCells=5`
- `CompleteHostedPlatformCells=5`
- `EachPlatformDenominatorCells=49`
- `EachPlatformPassedCells=49`
- `EachPlatformFailedCells=0`
- `EachPlatformResourceScalesPassed=3`
- `AllReceiptHashesValid=TRUE`
- `PortableProductionIdentityMatched=TRUE`
- `PortableSupportIdentityMatched=TRUE`
- `HostedMatrixHashValid=TRUE`
- `FrozenV6RegressionIdentityReused=TRUE`
- `IndependentStatisticalConfirmationAdded=FALSE`
- `CORE05Complete=TRUE`
- `CORE06Complete=TRUE`
- `G4ExitComplete=TRUE`
- `CurrentPayloadG6ReviewComplete=FALSE`
- `CurrentPayloadHumanReleaseReviewComplete=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextGate=renew-current-payload-G6-and-human-release-review`
