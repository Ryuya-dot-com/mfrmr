# Fixed-calibration G4 hosted run 32832244619 record

Status: `current_source_v5_complete_g4_closed_g6_public_unauthorized`,
2026-08-25.

## Bound candidate and hosted execution

- Commit: `bcf86197619e3eae4c7cdd5288b797549df47c99`
- Contract: `mfrmr_fixed_calibration_g4_current_source_evidence_v5`
- GitHub Actions run: `32832244619`
- macOS release prerequisite: `success`, 4m32s
- Windows release: `success`, 6m38s
- Ubuntu devel: `success`, 7m02s
- Ubuntu oldrel-1: `success`, 7m34s
- Ubuntu release full suite: `success`, 47m57s
- Five-receipt aggregation: `success`, 3m40s
- Production registry SHA-256:
  `ab36f6e5d8a7a61dd758208a809d2668ccd816a8e2a30bcf8708396d8624c2b7`
- Support registry SHA-256:
  `6cb6e592e48a89862061fb789935789082b0cb08df4b4f51cbce0ca22d095ca7`
- Hosted matrix receipt hash:
  `f4b0f18305612c11fbe45c41d9f4553317204d397b18083f195fc0a7efa9d6ca`

Every platform built and bound its own source tarball, checked that exact file,
loaded the package retained by the check, completed all 29 repository static
evidence tests, and ran the complete disjoint modular-1039/1049 v5 worker. Each
receipt retained 49 passes, zero failures, and three passing resource scales.
The Ubuntu release cell also completed the full `NOT_CRAN=true` package suite
that had exposed the v4 reference-benchmark integration failure.

Platform tarball and manifest hashes differ because each platform builds its
own physical artifact. That is expected and is not described as byte identity.
All five canonical production-boundary and support registries match. Each
downloaded receipt hash was independently recomputed successfully. A second
local aggregation reproduced the hosted platform registry exactly, and the
hosted matrix hash was independently valid.

## Retained platform receipts

| Cell | Tarball SHA-256 | Manifest hash | Receipt hash |
| --- | --- | --- | --- |
| macos-release | `a7c010e0b87ab9a78f205c43a30d3e8782604528cafe8dd03ff0f549732a2d2a` | `d2f6f3798581de7adb36c090d8d1e4f15fe0745f89e4684347b773b2286876b0` | `d0b734832b4cc25b5dd4f3f5e98c11d70be50b4b7636c26cad6b2f1803280f29` |
| windows-release | `65b41115e162ecb80c65274522aa023fc8223e487aa57a1e0083035b288f81db` | `207ca56a49457f04153844cfc764a9a11b5ace7fb79123ca1cda079e0f208632` | `6558922536c21c7e7651dc06ec817c257a0c7aaadb92d4969ef91101037b27e0` |
| ubuntu-devel | `bd9e4ed8267ec77eaf654808b6fdb83e35052d9751252f9047505a7530047ca6` | `ab0ae62d7051e43e593f9665af35c3ffff0e5c10e9a23fc777d33ba42c1baf4e` | `360350334bb8aecbf153bb54cf60b0f622e58fc66b4d9273b06037de33125cd3` |
| ubuntu-release | `405d9a24254c22954aeb857a08e50a8723c5591f13201aad0401da267a320c57` | `c797f6fddbd5b3f53c81631656d74af84501900fe5ac870b6413129efbab1835` | `4e9c635a04cbf095cf61ffae595fb59cbfe88cf744792d78bf65fe6027973016` |
| ubuntu-oldrel-1 | `dc0cea334c7e408c8987c6a910858207429c797d5ee8e2eee21e69212df75905` | `fb53063d004b1b781b7a1088ed5e16228a7992cf7a2a1ceba92cd83d857e8164` | `664fdec3af592a1553cef6f14a03d787451899a238540102637406c207053b90` |

## Decision boundary

The complete same-commit five-platform result closes CORE-05, CORE-06, and G4
for the declared one-scale fixed-N(0,1) RSM/PCM MML portable-calibration core
at the exact candidate commit above. No historical, v2, v3, or v4 passing cell
is pooled into this result. The material prior-sensitivity disposition remains
a review/non-robustness claim as frozen by the denominator.

This close does not authorize GPCM portable calibration, other optional lanes,
G6 release-candidate completion, or the public fixed-calibration API. Those
remain separate decisions. Node runtime deprecation annotations emitted by the
Actions platform are repository-maintenance signals, not numerical evidence or
G4 failures.

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
- `IndependentPlatformRegistryMatched=TRUE`
- `CORE05Complete=TRUE`
- `CORE06Complete=TRUE`
- `HostedPlatformMatrixComplete=TRUE`
- `G4ExitComplete=TRUE`
- `G6Authorized=FALSE`
- `PublicAPIAuthorized=FALSE`
- `NextGate=G6-release-candidate-hardening`
