# Fixed-calibration post-maintenance G4 v6 hosted run 32877939836 record

Status: `post_maintenance_v6_complete_g4_closed_g6_public_unauthorized`,
2026-08-26.

## Bound candidate and execution boundary

- Candidate tag: `g4-v6-candidate-0aac546`
- Commit: `0aac54600062cdf5ad4a1aba699b48f1818888bc`
- Contract: `mfrmr_fixed_calibration_g4_post_maintenance_evidence_v6`
- Specification:
  `0.2.4-fixed-calibration-post-maintenance-boundary-evidence-v6`
- Dedicated GitHub Actions run: `32877939836`, `success`
- Independent routine check-only run: `32877893348`, `success`
- Production registry SHA-256:
  `7927724339fe6b450246b3738ae3688d94d2f81fd9391c6108e2e59f7f45eafb`
- Support registry SHA-256:
  `a83594d9393b1aedf09cc57ca5b798f406aa78bc81c8568ebe03c00f245d94cc`
- Hosted matrix receipt hash:
  `faf0b7493cbd73e1fd127d58bde46c94d8d038e53e5bcc735f6761133dad3ba3`

The candidate was activated only through its explicit candidate tag. The
dedicated workflow ran hosted macOS release first, then Windows release and
Ubuntu devel/release/oldrel-1 on the same commit. The Ubuntu release cell ran
the full package suite. The separate routine workflow also completed its five
check-only cells, with `G4EvidenceIssued=FALSE`; those results are supporting
package evidence and were not pooled into the G4 denominator.

## Local exact-candidate evidence

The clean candidate produced source tarball SHA-256
`e2d6d74d51c1ca541bd66c75c3d411f5bb1a52c034ab74c1288069ec30c25477`.
Its candidate manifest hash was
`526d54b705a7c4cab87efdab15314fdb741cbf72e9932ba9478b8bed07122383`;
the production and support registries matched the hosted values above. The
exact tarball completed `R CMD check --no-manual` with `Status: OK`, and the
check-installed v6 worker retained 49 passes, zero failures, and three passing
resource scales. The local confirmation artifact SHA-256 was
`0c5c72888b258c7370a3178b176ba4abf9e11adf63b2792ebf2d75164767f719`.

The 120-, 6,000-, and 30,000-row resource observations took 0.013, 0.310, and
1.698 seconds. Profiled allocation was 75,384, 31,332,408, and 676,258,744
bytes; serialized results were 41,399, 1,559,909, and 7,757,909 bytes. These
are frozen-gate regression observations, not public performance promises.

A second build used Homebrew GCC 15.2.0 for both `src/cpp11.cpp` and
`src/mml_backend.cpp`, with `-flto` at compile and link time. The package
installed successfully, and the installed C++ backend agreed with the pure-R
reference in all 37 regression expectations. This directly exercises the
compiled-header boundary introduced by the 0.2.3.1 maintenance integration.

## Retained hosted receipts

| Cell | Tarball SHA-256 | Manifest hash | Receipt hash |
| --- | --- | --- | --- |
| macos-release | `41c421ebc5ec4b4a956b866d8cc814d4a9fafee80bad365e37d84a159ed6b7c5` | `7dfce809f7d5929e6545b2df01f0837e9b1b306c127ae528237fa363cc33a715` | `de45ea2ee066b6470d871ab5aa8e8605d350d7b522bd7a451dc3e943cc129b78` |
| windows-release | `c7f30f508fe210f4a5234de551639a508e38fb56c611104aa85b8142ab3371e8` | `c140af843747e2655c3dce5e1e0282726e7c7bb45b7bd2c7fd0e18ca9595525b` | `f25740a753d3347b8fcfdadb56ee9b920ab1ea603af3dd179867f81d563db281` |
| ubuntu-devel | `5f1287f2056d696dc5e92af838285e565847d8e858700a83e1634f58482b21f5` | `beabba18a30ad978355477a11bc15059f7b45ce019bf9ad6bd5b96bee50eb7ad` | `ad5801b2494b4d48a8311381eef1054205ac83f1fca8da51f35edd7a00ca7735` |
| ubuntu-release | `986c0160c9fe7ea7a70d20fb4babd6f6caed4800ea9e8788e6b0f3df122b0e19` | `0f0bc38b890ac53f20e42ee94344bf5439d6dee2ae723d4c974b2a6a6fda5537` | `553e29f36751254f6c1ca1d453d82df345f8a8afb3bb63a4fa383c1d72724563` |
| ubuntu-oldrel-1 | `bfefe4e9c2e4a9431faf8bbc11db536e0b6f9d570f674b64d8f605914d219f69` | `454433d5fd87d64fcc6727480d221573104d1d8f579f6fc23b45401c17b350af` | `e0344d1183b5ee8d9cd6d4abea11c2e0a8eb8075767434d1fb27a63f20b45397` |

Every downloaded receipt hash was independently recomputed with the frozen
canonical UTF-8/text encoder. Each receipt bound the same commit and portable
production/support registries, retained all 49 denominator cells with 49
passes and zero failures, and passed all three resource scales. The downloaded
matrix hash was also independently recomputed, and its platform registry
matched the five receipts exactly. Platform tarball and manifest hashes may
differ because each platform builds its own physical source artifact; that is
not treated as a failure of portable semantic identity.

## Decision boundary

This complete, same-commit, disjoint modular-1061/1063 result closes CORE-05,
CORE-06, and G4 for the declared one-scale fixed-N(0,1) RSM/PCM MML portable-
calibration core at the exact candidate commit above. It includes both compiled
translation units in the production boundary and does not pool the historical
v5 result or any earlier v2--v4 passing cell. The explicit nine-node fixture
remains a non-authorizing historical control.

This close does not authorize portable GPCM calibration, any other optional
lane, G6 completion, the public fixed-calibration API, or a 0.2.4 release.
Repository-only records added after the run document the decision without
changing the evaluated production or support registries. G6 must perform its
own final public-surface and release-candidate review.

- `CandidateBindingComplete=TRUE`
- `LocalExactTarballCheckComplete=TRUE`
- `LocalGCC15LTOCheckComplete=TRUE`
- `RoutineCheckOnlyPlatformCellsPassed=5`
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
