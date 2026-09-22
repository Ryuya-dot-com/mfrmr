# Native JML recession policy validation record for mfrmr 0.2.3

## Decision boundary

Draft.62 implements `bounded_single_10s`, the sole Draft.61 implementation
candidate, as internal contract `mfrmr-jml-recession-fit-policy-v1`. The
contract applies only to additive structural and joint JML recession audits:
each capacity and strictness stage receives one native ten-second attempt, an
unaccepted solve is not retried, and a positive target that requires both
stages has a maximum native allowance of 20 seconds.

This change does not alter the likelihood, optimizer, parameterization,
readiness derivation, fitted-object schema, or exported API. It does not change
the separately scoped nonlinear GPCM joint-pair audit, whose default remains
two seconds. Nonzero or malformed solver exits remain fail-closed and every
accepted direction must pass the existing original-scale certificate.

## Native implementation evidence

The guarded runner observes the installed production target-LP function but
does not replace its policy. It reconstructs the six exact Draft.59 complete,
balanced-sparse, and random-sparse RSM/GPCM routes and runs three fresh-process
repetitions per route. Every child has an independent finite parent deadline.

The authoritative final-source bundle is
`mfrmr/archive/artifacts/validation-bundles-0.2.3/jml-recession-native-policy-20260807-v4`.
It is bound to source tarball
SHA-256 `7ceb2848958f2f70084e987342eb3e58e6a38b2b41964ceb0d385ea276d92624`.
All 18 fits complete safely, no parent deadline fires, and all six route cells
are stable. The 51 native target calls all receive a ten-second input and use
66 solver attempts. Complete fit-result identity and call-outcome identity
match the selected Draft.61 candidate in 18/18 paired cells. An independent
verifier recomputes every recorded artifact hash and the completion-marker
inventory.

The first attempted comparison bundle is retained as
`mfrmr/archive/artifacts/validation-bundles-0.2.3/jml-recession-native-policy-20260807-v1-rejected`
without a completion marker.
It incorrectly compared Draft.61 wrapper transport inputs of two seconds with
the candidate's effective ten-second policy. The corrected comparison treats
the intercepted input as transport metadata and checks the frozen candidate
registry. A direct-install v2 run passed but is superseded by v3 because it was
not linked to an exact source tarball. The exact-tarball v3 run passed but is
superseded by v4 because the release-readiness test source changed while the
Draft.62 document contract was finalized. None of the superseded bundles is
used as final-source evidence.

## Required final-source checks

Retention of the production policy requires all of the following on one final
source identity:

1. the policy-contract and default-routing unit tests;
2. all affected structural, joint, GPCM, boundary, readiness, and shared-
   geometry tests;
3. an exact-inventory sharded full non-CRAN regression;
4. a package check of the same exact source tarball; and
5. a final native replay tied to that tarball if the test source changes after
   the pre-finalization bundle.

All five requirements pass for the final source. The affected zero-failure
surface includes 115 structural-recession, 125 joint-recession, 22 shared-
geometry, 977 contrast-preallocation, 64 nonlinear-GPCM joint-boundary, 89
GPCM slope-boundary, 53 Person-boundary, 297 estimability, and 599 release-
protocol expectations. The nonlinear GPCM tests verify the unchanged
separately scoped default; they are not evidence for extending ten seconds to
that audit.

The sharded full non-CRAN regression covers all 129 test files exactly once:
1,765 tests contain 13,233 expectations, of which 13,172 pass, 38 are expected
warning conditions, and 23 are optional-capability skips. There are zero
failures and zero errors. The 38 warnings reduce to three existing fail-closed
messages: 34 category-support review warnings, three review-only display
warnings, and one information-criteria suppression when a compared optimizer
requires review. No solver-policy or new Draft.62 warning occurs.

The first exact-tarball package check under the Dropbox work path completes
all code, tests, examples, and vignettes but records one filesystem WARNING
because installation could only copy after a final-directory rename failed.
The same tarball checked in the local temporary filesystem removes that
WARNING and completes with `Status: 1 NOTE`. The sole NOTE is the declared
offline/optional-dependency condition: `lme4`, `eRm`, `mirt`, and `TAM` were
unavailable for Rd cross-reference validation after the check host could not
reach CRAN or Bioconductor. `_R_CHECK_FORCE_SUGGESTS_=false` is recorded. This
is a completed scoped package check, not a dependency-complete, manual,
`--as-cran`, or `Status: OK` check.

## Evidence identity

| Artifact or identity | Value |
| --- | --- |
| Native runner SHA-256 | `8ebe8d0911eaf354731c46dae3c79d3f1ba8e6ea799f385587f4dd8330eb0759` |
| Production core source SHA-256 | `43b99e9de9154e4cefa8a921fa3fbf79f29edfccf1c70185bf6995ae8d0be526` |
| Structural policy-test source SHA-256 | `24635b98b0484d3986f832f98994b52f4b741ea2dd88a262b0432c0719ba3a53` |
| Release-protocol test source SHA-256 | `aa7d6d86adb0444d10cc9afcf75c1ea795425e69ec1a17f31181d4d3bda65a17` |
| Final source tarball SHA-256 | `7ceb2848958f2f70084e987342eb3e58e6a38b2b41964ceb0d385ea276d92624` |
| Final source tarball bytes | `2,172,549` |
| v4 native artifact inventory SHA-256 | `639cc78aac6cf7079157ee5e92716821d971745423f989ec7cf7be48ab59ceda` |
| v4 native execution SHA-256 | `693b6c922d19d0718d35798db9614d4cc5705daed541f5fd5b1fbd506cc5fe75` |
| v4 native installed-package SHA-256 | `04cd7f748dc304e000b1ae64eb13f451267155acfbc2abfa1a165641a0714430` |
| v4 native completion-marker file SHA-256 | `1d3ec22a005694abdf9aed4f1ea48ca43d0ce671df52a7e9571b33483cd48793` |
| Full-regression runner SHA-256 | `b549ae99bf5aa63ce8457a9ffbe5b092d030283c59287bb0d1a673af6baa5df3` |
| Full-regression test-inventory SHA-256 | `e212b4a5a215699800d5b16a68cca2f913d2a6deeb626670c3d8cdf9ce360c0e` |
| Full-regression artifact inventory SHA-256 | `32ce143c2192868e0c1313bd55d1245dc7e97893321abf0c1cc08dc545db717e` |
| Full-regression execution SHA-256 | `340cff757a3e893e1ccacb506bcfcf29034939f6b221401c0b783ac423957acf` |
| Full-regression installed-package SHA-256 | `e1c3ab419588f22d9fd33f9cfacf3fcfa7b9543e88d47799dab17c723103d594` |
| Full-regression completion-marker file SHA-256 | `0563c93da0744aacafa7bb19f730e2785ad899e162fc4c725994b33158b36f90` |
| Temporary-filesystem package-check log SHA-256 | `451eb0f1fcd6f1ced79900ef6869fe8f3784a909cce3af8428ffa1cea26c9064` |
| Dropbox-path attribution check-log SHA-256 | `df8bce776e6793e51d499ae317b73f6060f4cd4937620295abba7380aba5a13e` |

## Current consequence

The final-source checks pass, so the additive structural/joint JML recession
replay blocker is resolved and the versioned single-ten-second policy is
retained. This resolution is narrow: it freezes no general runtime or capacity
criterion, promotes no release-checklist row, and authorizes no confirmation
analysis. The validation and regression completion markers intentionally keep
their local `ReplayBlockerResolved` fields false because each bundle alone is
insufficient; this combined implementation record owns the cross-evidence
decision.

Nonlinear GPCM joint geometry, residual-PCA computability, broader sparse and
active-structure stress, ADEMP recovery/coverage, metric-specific external
comparison, Monte Carlo precision, and candidate freeze remain open.
