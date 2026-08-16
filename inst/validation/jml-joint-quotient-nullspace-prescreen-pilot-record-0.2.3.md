# JML joint quotient/nullspace prescreen pilot record for mfrmr 0.2.3

Status: repository-only draft.53 change-local evidence, 2026-08-05. This
implements an internal certificate-preserving fast path for the JML joint
additive recession audit. It changes no likelihood, optimizer, estimator,
public API, public roadmap, primary parameter value, readiness precedence, or
release criterion; authorizes no confirmation; and freezes no runtime claim.

## Problem isolated by Draft.52

The joint audit's global cone contains every free Person and additive
structural optimizer coordinate, but its selected targets contain structural
expanded parameters and only constraint-coupled extreme Persons unresolved by
the sufficient-score audit. In the fixed positive-cone PCM routes, the global
ray moved only ordinary free extreme Persons already typed
`unbounded_low/high`. That valid but already propagated ray activated 346
selected-target LP calls, all negative.

Simply deleting those Person coordinates is not equivalent. A free high or low
extreme Person can move in its one-sided boundary direction to compensate the
effect of a retained structural direction on that Person's observations.
Correct profiling must remove both the Person coordinate and that Person's
contrast rows.

Nor is a negative strict quotient cone enough. A retained direction can change
a selected target while leaving every quotient contrast exactly zero. An
independent excluded Person ray can then provide strict likelihood improvement
in the full cone. Draft.53 therefore composes a quotient strict-cone screen
with a selected-target nullspace screen.

## Proof contract

Let the full additive coordinates be partitioned into ordinary free extreme
Persons `u` and retained coordinates `r`. The production screen verifies each
excluded Person coordinate directly in the fitted contrast matrix:

- every response for that Person is at the same observed lower or upper
  boundary;
- the corresponding signed coordinate has a strictly positive margin for
  every one of that Person's observed-versus-alternative contrasts;
- the coordinate is zero on every other Person's contrast row; and
- no selected target expansion uses that coordinate.

These checks establish that a retained direction satisfying the quotient
constraints can be extended to the full cone by a sufficiently large signed
Person movement, while selected-target change depends only on `r`.

Let `Cq` be the quotient contrast matrix and `Tq` the selected-target expansion
on retained coordinates. If the maximum summed quotient margin is positive,
the existing target enumeration is retained. If it is negative, nonnegative
quotient margins imply `Cq r = 0`; the remaining question is whether any row of
`Tq` changes on `kernel(Cq)`.

Draft.53 uses one common column scaling for `Cq` and `rbind(Cq, Tq)`, then
compares sparse-QR ranks at `1e-12`, `1e-10`, and `1e-8`. Enumeration is skipped
only if:

1. the quotient cone call is evaluated and negative;
2. base and augmented ranks are stable across all three tolerances;
3. every augmented-minus-base rank increment is exactly zero; and
4. all mapping, boundary-ray, coordinate, nonzero, row, and target limits pass.

Rank increase, tolerance sensitivity, rank failure, solver failure, malformed
mapping, invalid Person ray, or execution-limit state retains the existing
target enumeration or its existing target-size failure. Thus the new screen
cannot turn an uncertain branch into a finite claim.

For compatibility, a full cone explained only by already typed Person
boundaries retains the legacy joint audit state `certified_recession`; selected
target statuses and reasons match the complete enumeration. The new
`relevance_screen` records that selected-target exclusion was certified. A
future state-vocabulary revision may separate `known_person_boundary_only`,
but it is not mixed into this performance correction.

## Adversarial controls

The change-local suite includes the following controls:

- a three-coordinate counterexample has an independently improving Person ray,
  a negative quotient strict cone, and a selected target that moves in the
  quotient nullspace; the full target LP certifies it and the rank screen forces
  fallback with rank increment one;
- a row-space target on the same quotient has rank increment zero and is safe;
- a nearly dependent `1e-9` target is tolerance-sensitive and cannot skip;
- a real RSM fit with one ordinary high-extreme Person matches a complete
  legacy re-audit, makes no target LP calls, and is row-order invariant;
- setting the target/rank budget to zero falls back to the existing positive-
  cone target-limit state;
- a structural-separation quotient remains positive and retains target
  enumeration and its target certificates;
- the original group-constrained fixture, whose relevant direction requires
  Person and structural movement, remains positive and enumerated;
- Rater-by-Criterion interaction targets match complete legacy enumeration;
- bounded GPCM matches legacy conditional-additive target states while
  remaining globally incomplete for log-slope paths; and
- structural-only, negative-cone, sparse/dense, MML, readiness, release-
  readiness, and phase-timing suites retain their existing behavior.

The installed Draft.53 runtime passes the joint, structural, readiness,
release-readiness, and phase-timing change-local suites. The earlier `pkgload`
release-readiness attempt correctly failed only because an ephemeral namespace
has no hashable installed runtime files; the same tests pass against the
installed content-identified package.

## Fixed 19-route v8 result

Phase schema v8 uses the unchanged seven-cell/19-route manifest, fixed data and
seeds, 60-iteration ceiling, seven quadrature points, and `1e-9` relative
tolerance. It exposes the quotient work and directly readable three-tolerance
rank ladders. The completed v7 bundle had the same statistical results but is
superseded because it stored only a rank-ladder hash.

All 19 fits succeed, all timing and 12 JML work contracts pass, ten routes are
inference-ready, and false-ready count is zero. Relative to v6, every route has
the same semantic-result hash, fit readiness, inference-ready flag, numerical
state, boundary state, optimizer method, structural state/completeness and
target-status hash, and joint state/completeness and target-status hash.

The five former positive-enumeration routes profile 84 Person coordinates
across optimizer routes: one Person in each R12 route, two in C12-E02, and 40
in each forced-extreme route. The unique data-cell count is 43 Persons. Every
quotient cone is negative, and all three tolerances report:

| Data cell | Quotient contrast rank | Augmented rank | Rank increment |
| --- | ---: | ---: | ---: |
| R12 | 225 | 225 | 0 |
| C12-E02 | 247 | 247 | 0 |
| P200-X20 | 177 | 177 | 0 |

Auto and BFGS routes on the same retained data have the same ladders. All five
routes therefore skip selected-target enumeration. Seven already-negative
global cones retain their existing skip, so all 12 JML routes now make zero
joint target LP calls.

| Measurement | Draft.52 v6 | Draft.53 v8 | Change |
| --- | ---: | ---: | ---: |
| joint recession phase, 12 JML routes | 62.52 s | 18.82 s | -69.9% |
| JML outer fits | 87.10 s | 43.53 s | -50.0% |
| all 19 outer fits | 94.67 s | 50.91 s | -46.2% |
| structural recession phase | 13.67 s | 13.75 s | timing noise |
| optimization phase | 3.81 s | 3.91 s | timing noise |
| joint target LP calls | 346 | 0 | -100% |
| all joint LP calls | 363 | 22 | -94.0% |

The five corrected positive-route joint phases fall from 8.29--10.95 seconds
to 0.75--1.38 seconds. These are one-run PCM diagnostics on one machine, not a
capacity envelope, replicated operating characteristic, or release threshold.

## Critical limitations and next slice

The fixed profile is PCM-only. RSM, interaction, and bounded-GPCM coverage is
change-local and small; the GPCM result concerns only the fitted-slope additive
subspace and does not close joint nonlinear JML or marginal MML boundary work.
There is no general independent-solver parity, replicated runtime, isolated-
process memory, target-scale positive quotient, FACETS comparison, recovery,
or confirmation evidence.

After Draft.53, negative full-cone routes consume about 12.7 of 18.82 joint
seconds, while the five quotient/rank routes consume about 6.1 seconds. The
next performance slice should instrument adjacent-design construction,
expanded-target mapping, observed-contrast construction, sparse LP-base
assembly, solver time, and rank time separately. Structural and joint audits
currently reconstruct closely related geometry; exact reuse of one full
adjacent/contrast object is the leading hypothesis. It must first prove that
Person-fixed structural columns equal the corresponding subset of the joint
contrast under anchors, groups, interactions, steps, weights, missing rows,
and bounded GPCM slopes. Solver replacement or warm-start work follows only if
shared construction is not the dominant remainder. The separate replicated
optimizer-dispatch grid remains necessary for numerical readiness.

## Evidence integrity

The authoritative bundle is outside the package source tree at
`mfrmr/archive/artifacts/validation-bundles-0.2.3/jml-phase-profile-20260805-v8`.
It was promoted from an incomplete
staging directory only after all 19 route, paired-data, structural-equivalence,
false-ready, joint-work, quotient, nullspace-rank, and artifact contracts
passed. Its completion marker independently matches all 13 pre-marker
artifacts. v7 is retained as superseded observability evidence and is not used
for the Draft.53 claim.

| Field | SHA-256 |
| --- | --- |
| Selected 19-route manifest | `f84c2a6bdc0c0de11fdff0521a1cf81b76482cf6cdf41ce38118c590f85c1d87` |
| Installed Draft.53 runtime | `522e63c340f770e11cb320c9bc026bcdca2465fb9dc4ab85a040e61d39f1cba6` |
| Phase runner | `c47756487ab44941b3a4de9d0ea789383745cd62f86f27a4fec0eb9e05cd0fa6` |
| Draft.49 support runner | `fd8e11b52d09815d19a714090b02bbf76373a4748128b078a1fdc7a30e2f8ba5` |
| Runner composite | `339a9dd989e4cb5d023bb3b44b01dbd1c2d7ca2206b568615e18ad054954cc21` |
| Instrumentation contract | `8880843b55b3fdff522197cc51181d3e2401174a325f17f2744f4bf02364ac2c` |
| Execution identity | `6fb753eab141ad8a4a6a415579d5a29407df741f49683a67487e542ff849475e` |
| Artifact inventory | `70424f57dadebb36213c7d8595b949a01502bd0d7f6e624808b23fc81c40d6a8` |
| Result CSV | `2f9e33a580ae9319642d7b9718c543fc622122aa055f869b25c26536615ac127` |
| Phase timing CSV | `0a6de44ffb38db556cc313c328e8ff25f67ceb8ebef53ee1a59424536cb47beb` |
| Phase summary CSV | `3ce71735b153b14c2c81b96edcf051bef1c95dbc4b737cda9e41cad8f19459b7` |
| Run summary CSV | `2039eb0c2498a2cb6ec20ea2e2b0e6438250ee393e50973074f5f50ac20228f5` |
| Completion marker file | `43cd3c7bf4b9dc4df503a40a5608d250cbdfc25a7b20b55b18c7b8c70138b6b8` |

A clean exact local source package contains 491 tar entries and passes
`R CMD check --no-manual` with `Status: OK`. This check installs the tarball,
runs static and documentation checks, examples, the package test suite, and
vignette rebuilding. The tarball and check-log identities are stored outside
the package source in
`mfrmr/.check-draft53-standard-no-manual-v3/verification-receipt.txt` so that
recording the hash does not mutate the artifact whose identity it records. An
earlier 497-entry artifact, SHA-256
`86b18a8a58adc689a9316c63212d585a6ff7c85f4126e09448fd379a4e8f9b3f`,
is superseded and inadmissible because six hidden change-local `.tmp-*.R`
scripts had been built into it; its sole hidden-file NOTE is not treated as a
package result.

The runtime was installed with documentation-index generation excluded only to
avoid a Dropbox/Windows compressed-file staging failure; its package-content
identity is fixed above and it is not a candidate installation. Public
`ROADMAP.md` and `NEWS.md` remain unchanged. The exact-tarball standard check
is complete for this change-local source state; full-manual, `--as-cran`,
`--run-donttest`, dependency-present, external, candidate-linked, and
confirmation checks remain open.
