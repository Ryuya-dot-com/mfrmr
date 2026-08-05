# JML structural global-cone prescreen pilot record for mfrmr 0.2.3

Status: repository-only draft.51 calibration evidence, 2026-08-05. This is a
one-replicate PCM algorithm-equivalence and computation profile. It freezes no
runtime, solver, optimizer, recovery, capacity, or release criterion;
authorizes no confirmation; and makes no FACETS, TAM, immer, JML, or MML
superiority claim.

## Change-local question and proof boundary

Draft.50 found that the Person-fixed structural recession audit enumerated
46--126 target directions per selected JML route even though every route ended
`none_certified`. Draft.51 asks whether an empty common recession cone can be
certified once before target-specific optimization.

Let `C` be the observed-category contrast design and `d` an admissible
additive structural direction. The audit requires `C d >= 0` and at least one
strictly positive row before any target can be certified. Under the nonnegative
constraints, `sum(C d) <= 0` therefore implies `C d = 0` for every feasible
direction and excludes every target-specific recession certificate. If the
maximum sum is positive, the prescreen cannot classify any target and the
existing positive/negative target enumeration must run unchanged.

This implication uses the same constrained coordinates, contrast matrix,
box normalization, solver, objective tolerance, and post-solve certificate
tolerance as the existing audit. It is not valid for a different cone or for
GPCM nonlinear log-slope paths, and it does not assert global finiteness
outside the audited additive subspace.

## Implementation contract

The internal structural wrapper now requests `mfrmr-jml-global-cone-prescreen-v1`.
The returned audit records whether the prescreen was requested, evaluated,
positive or negative, whether enumeration was skipped, cone LP calls, target
directions evaluated, target LP calls, and total LP calls.

The cone capacity uses objective tolerance `1e-10`, while the post-solve
strict-row certificate retains `1e-7`. Reusing the ordinary target objective
tolerance (`1e-7`) would trigger its `10 * tolerance` early-negative rule and
could hide a valid target direction whose strict contrast margin lies between
`1e-7` and `1e-6`. A one-coordinate `5e-7` contrast is retained as an explicit
regression: the ordinary target certifies, the unsafe default cone call does
not, and the guarded cone call certifies. The global exclusion tolerance is
therefore strictly below the minimum strict margin required of a target
certificate.

The prescreen runs only after the existing retained-data, constrained mapping,
contrast construction, dependency, coordinate, nonzero, constraint, and
structural target-direction limits. Consequently it does not use a fast path
to bypass an existing unsupported-size state. A solver failure returns
`not_evaluated_solver`; it cannot become `none_certified`. A negative cone
sets the same target classifications and readiness state as complete legacy
enumeration, but stores the global cone certificate instead of redundant
negative target certificates. A positive cone retains the legacy enumeration.
MML remains `not_applicable_mml`.

## Unit and metamorphic controls

The structural audit suite now covers both branches and the relevant guards:

- the separated two-Rater and checkerboard-interaction fixtures certify a
  positive cone, retain target enumeration, and match unscreened target states;
- the response-constant-level negative fixture matches the complete unscreened
  target-status table while reducing target LP calls to zero;
- sparse/dense representations and reversed row order retain the same
  classifications and capacities;
- direct anchors, facet signs, retained positive weights, and missing rows
  continue to enter the exact constrained design;
- coordinate and target-direction size limits remain fail closed; and
- an injected cone-solver failure returns unevaluated target states rather
  than a false finite result; and
- the near-boundary `5e-7` counterexample prevents reuse of the looser target
  capacity cutoff for global exclusion.

The companion joint, Person-boundary, readiness-propagation, first-use, and
phase-timing suites also pass. The implementation changes neither the public
fit API nor ordinary timing behavior.

## Fixed 19-route result

The Draft.50 seven-cell/19-route manifest was rerun as authoritative v5 with
the same data cells, seeds, 60-iteration ceiling, seven quadrature points, and
`1e-9` relative tolerance. Each of the 12 JML fits was followed by an
unscreened structural re-audit of the same fitted object. The legacy audit was
timed separately and did not enter the v5 outer-fit or phase measurements.

All 19 fits succeeded, all timing contracts held, ten routes were
inference-ready, and forced-extreme false-ready count remained zero. All 12
JML screened/unscreened comparisons had identical structural state, complete
flag, and target-status hash. Across v3 and v5, all 19 routes retained the same
semantic-result hash, fit readiness, inference-ready flag, numerical state,
boundary state, optimizer method, structural state/completeness, and joint
state/completeness.

Every selected JML structural cone was negative. The old audits made 908
target LP calls; v5 made 12 cone LP calls and zero target LP calls, a 98.7%
reduction in recorded LP calls. The separately timed legacy re-audits consumed
139.56 seconds, consistent with the 139.63-second Draft.50 structural phase.

| Measurement | Draft.50 v3 | Draft.51 v5 | Change |
| --- | ---: | ---: | ---: |
| 12-route JML outer fit | 212.68 s | 86.57 s | -59.3% |
| structural recession phase | 139.63 s | 13.80 s | -90.1% |
| joint recession phase | 62.31 s | 61.80 s | timing noise |
| optimization phase | 3.70 s | 3.70 s | unchanged at displayed precision |
| all 19 outer fits | 220.33 s | 94.03 s | -57.3% |
| longest outer fit | 51.59 s | 12.32 s | -76.1% |
| seven-route MML outer fit | 7.65 s | 7.46 s | timing noise |

All 12 JML outer fits were faster in v5; per-route reductions ranged from
31.5% to 84.8%. These are one-run diagnostic measurements on one machine, not
a frozen performance envelope or an operating characteristic.

## Adversarial interpretation and next slice

Draft.51 removes the diagnosed redundant work without changing the selected
statistical decisions. It does not establish target-scale FACETS parity or
general JML maturity. In particular, all 12 target-profile cones were negative;
positive-cone preservation is supported by bounded unit fixtures, not a
target-scale runtime profile. The fixed profile is PCM-only. RSM and especially
bounded GPCM require their own model-specific stress evidence, and GPCM remains
incomplete for nonlinear and marginal boundary paths.

After the correction, the joint recession phase is the largest selected JML
component. Draft.52 should first expose joint cone and target LP work by route,
separating negative screens from R12, C12-E02, and forced-extreme positive-cone
enumeration. Only then should shared adjacent-design/contrast construction,
reusable LP models, warm starts, or alternative solvers be evaluated. Each
hypothesis must preserve positive certificates, negative controls, solver and
size failure states, sparse/dense and row-order invariance, and readiness.

The replicated 180--260-parameter RSM/PCM/GPCM optimizer-dispatch grid remains
a separate numerical-readiness study. This performance correction is not
evidence for changing the current optimizer threshold.

## Evidence integrity

The authoritative bundle is outside the package source tree at
`mfrmr/jml-phase-profile-20260805-v5`. It was written through an incomplete
staging directory and promoted only after route completion, timing, paired
data, false-ready, artifact, and all 12 structural-classification equivalence
checks passed.

| Field | SHA-256 |
| --- | --- |
| Selected 19-route phase manifest | `f84c2a6bdc0c0de11fdff0521a1cf81b76482cf6cdf41ce38118c590f85c1d87` |
| Loaded Draft.51 mfrmr runtime | `cbfc1adefe35d7c9bef42717c8c5650bae109fa43bd9ed8fcee10f81683a2758` |
| Phase runner | `151d27f3104b13b32f245236e3e64d136af71a84e0b183828845de54c5930b46` |
| Draft.49 support runner | `fd8e11b52d09815d19a714090b02bbf76373a4748128b078a1fdc7a30e2f8ba5` |
| Runner composite | `54835075efd0f2341c37b35c7f2f7efdb888d2f4bba3c64534e54f05cb8cf06e` |
| Instrumentation contract | `8880843b55b3fdff522197cc51181d3e2401174a325f17f2744f4bf02364ac2c` |
| Execution identity | `721aac67fea1f63b473aaf84a2194c38193d7f840566b150141d18033eb578ec` |
| Embedded artifact inventory | `e497cce5e252008e88762d3996cf14a23730fb66d93de8331dfe8d74aef0ef39` |
| Result CSV | `3e89491c5e02b1d05c21fd5c9f9fa6d9efc652d6d94fe63e01008a9974bef485` |
| Phase timing CSV | `418d31309fc04a923666169737e0e33fda69facf42d3b16b85574ca8ea8c05e9` |
| Phase summary CSV | `73a8cfd14d679995b7f096ccaa1038e0bcc13cc1940ef31edc4836761a167774` |
| Completion marker file | `aa298574d054452efe25eb98adf8207e190927250b22431d3c660d54c697e43a` |

The v3 bundle and Draft.50 record remain historical evidence tied to commit
`828281b` and their recorded identities. The first Draft.51 v4 bundle exposed
the expected route results but is superseded because adversarial review found
that its reused target-capacity cutoff was too loose for a global exclusion
claim. The guarded v5 runner records both tolerances and preserves every v4
statistical/readiness state. No prior bundle is rewritten.

## Verification boundary

All 127 package-aware `testthat` files were exercised. The exact package
tarball ran 126 included files; the repository-only release-readiness protocol
was run separately against the fixed installed Draft.51 runtime so its package-
content identity checks did not use a `pkgload` virtual namespace. Change-local
structural, joint, Person-boundary, readiness, first-use, and phase-timing
suites all pass. The sole expected first-use warning retains a category-support
review state.

The exact source artifact is
`mfrmr/.check-draft51-content-v2/mfrmr_0.2.3.tar.gz`, SHA-256
`bd72d5256d4f721ed735d08306bf6b8cba029108c913707b942095070d56a1df`.
It contains 491 entries, includes the corrected core and structural regression,
and excludes `inst/validation`, the public roadmap, validation runners/records,
and the repository-only release-readiness test.

`R CMD check --no-manual` of that exact tarball completed installation,
namespace/code/Rd/data checks, ordinary examples, all included tests, and
vignette rebuilding with `Status: OK`. The `00check.log` SHA-256 is
`d267352a743fed66d215e42bc57d88bc7f0ad7e948e6d74591a451f13b78e061`.
Unavailable Suggests were not forced for this local check.

This is not a complete `--as-cran` result and not a release candidate. Manual
generation, `--run-donttest`, dependency-present checking, external services,
and the later exact candidate identity remain M5 work. Public `ROADMAP.md`,
`NEWS.md`, model estimates, advertised claims, and confirmation authorization
remain unchanged.
