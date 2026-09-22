# JML execution-phase profile pilot record for mfrmr 0.2.3

Status: repository-only draft.50 calibration evidence, 2026-08-05. This is a
one-replicate PCM computation profile under a fixed 60-iteration ceiling. It
freezes no runtime, optimizer, solver, recovery, capacity, or release rule;
authorizes no confirmation; and makes no JML, MML, FACETS, TAM, or immer
superiority claim.

## Question and instrumentation contract

Draft.49 showed that total `fit_mfrm()` time included preparation, rank,
boundary, and readiness work, so elapsed time per reported optimizer evaluation
could only be a proxy. Draft.50 asks which phase actually consumes that time.

The package now has an internal opt-in `mfrmr.phase_timing` option. Its 18-row
table is attached as `fit$config$phase_timing` only when the option is exactly
`TRUE`. The table uses `proc.time()[["elapsed"]]`; every row is labelled
`DecisionUse = "diagnostic_only"`; and the table is attached only after the
optimizer result, parameter tables, boundary audits, readiness record, and
summary have already been constructed. The option is absent from the public
fit API and ordinary fits retain no volatile timing field.

Two deterministic tests compare timed and untimed fits. After normalizing the
pre-existing optimizer-polish elapsed field, the estimates, optimizer result,
audits, readiness, summary, and configuration are identical. The fixed phase
profile also hashes the statistical result without elapsed fields.

Seven Draft.49 data cells and 19 routes were fixed before execution:

- P200, P400, R12, and C12-E04 each use JML-auto, JML-BFGS, and MML-auto;
- C12-E02 and C12-E12 use JML-auto and MML-auto; and
- forced-extreme P200 uses JML-auto, JML-BFGS, and MML-auto.

These retain Person/row growth, Rater topology, Criterion/step dimension,
fixed-dimension row exposure, forced extremes, paired MML controls, and the
explicit optimizer contrasts implicated by Draft.49. They do not estimate an
operating characteristic.

## Execution result

The authoritative v3 completed all 19 routes across seven data cells. All 19
successful fits contained the required 18 timing rows, paired routes retained
one data and truth hash per cell, and the forced-extreme JML controls produced
zero false-ready results. Ten routes were inference-ready. Total outer fit time
was 220.33 seconds and the longest route was 51.59 seconds.

Across the 12 JML routes, outer time was 212.68 seconds and instrumented
`mfrm_estimate()` time was 211.25 seconds. The phase totals were:

| Phase | Total seconds | Median route share | Interpretation |
| --- | ---: | ---: | --- |
| structural recession audit | 139.63 | 74.16% | Dominant Person-fixed structural target certification cost. |
| joint recession audit | 62.31 | 17.73% | Global cone screening plus target enumeration when a joint cone was certified. |
| optimizer | 3.70 | 1.86% | Objective/gradient optimization was not the primary elapsed-time bottleneck in this grid. |
| constrained estimability audit | 2.48 | 1.04% | Nontrivial but much smaller than recession certification. |
| all other measured JML phases | 3.13 | below 1% each | Preparation, design/configuration, category review, Person boundary, readiness, and table assembly. |

The structural and joint recession phases together consumed 201.94 seconds,
about 95.6% of instrumented JML time. By contrast, the seven MML routes spent
3.26 of 6.85 instrumented seconds in optimization and 2.33 seconds in pre-fit
audits. The JML and MML profiles therefore have different bottlenecks; a single
package-wide performance rule would be misleading.

## Recession workload diagnosis

Every JML structural audit ended `none_certified`, yet the current
Person-fixed algorithm sets `screen_global_cone = FALSE` and enumerates both
directions for every free expanded target. The recorded workload includes:

| Representative cell | Rows | Free structural targets | Target directions / certificate rows | LP variables | LP constraints | Structural time in a diagnostic rerun |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| P200 | 2,400 | 23 | 46 / 46 | 34 | 9,618 | 5.40 s |
| R12 | 2,400 | 32 | 64 / 64 | 52 | 9,627 | 7.82 s |
| C12-E12 | 7,200 | 63 | 126 / 126 | 98 | 28,850 | 46.73 s |

The authoritative v3 result ledger records these dimensions for every route;
the separate diagnostic rerun merely exposes representative phase values from
the same cells. The structural sparse constraint workloads range from 50,640
to 304,752 stored nonzeros in the selected JML routes.

The joint audit already performs a global-cone screen. When no cone was
certified, P200/P400/C12-E04/C12-E12 recorded one cone-certificate row and zero
target-certificate rows. R12, C12-E02, and forced-extreme P200 certified a
joint cone and then enumerated respectively 64, 126, and 46 target directions
per route. This explains why joint time is large only for some topologies or
extreme-score states.

The dominant Draft.49 computation diagnosis is therefore revised. The current
auto optimizer switch can change numerical readiness on the complete
nonextreme P200/P400 path, but it does not explain most elapsed time. Changing
the global optimizer threshold is a numerical-readiness experiment, not the
primary performance correction.

## Adversarial interpretation and next corrective slice

The next implementation hypothesis is a structural global-cone prescreen. If
the maximum total nonnegative observed-category contrast margin is zero within
the existing certificate tolerance, no target-specific structural recession
direction can exist, so target enumeration should be unnecessary. This is a
mathematical-equivalence proposal, not permission to skip the audit.

Before adoption it must:

1. expose a versioned prescreen state and retain fail-closed dependency,
   solver, size-limit, and malformed-design states;
2. match the current structural target classifications on all existing sparse/
   dense, row-order, finite-grid, anchored, interaction, and MML guards;
3. retain target enumeration when a structural cone exists and prove that the
   prescreen cannot hide a target-specific direction;
4. preserve the v3 semantic result, readiness, and boundary states on the 19
   frozen routes while materially reducing phase time on no-cone cells; and
5. record solver calls or equivalent work counters rather than inferring them
   from elapsed time.

Only after that change-local equivalence slice should shared design/contrast
construction, reusable LP models or warm starts, and alternative solvers be
considered. Disabling recession auditing on slow or optimizer-blocked fits is
rejected because boundary state is part of the fail-closed result. The
replicated 180--260-parameter cross-model optimizer-dispatch grid remains a
separate numerical-readiness task.

## Evidence integrity

The authoritative bundle is outside the package source tree at
`mfrmr/archive/artifacts/validation-bundles-0.2.3/jml-phase-profile-20260805-v3`.
Its runner refuses an existing output
directory, writes through an incomplete staging directory, and promotes the
bundle only after route, timing-contract, paired-data, false-ready, and
artifact checks pass.

v1 is retained as the coarse phase-discovery run. v2 splits the original
combined boundary phase into Person, structural, joint, GPCM slope, GPCM joint,
and application phases. v3 adds the recession workload dimensions and is the
authoritative record. All 19 semantic-result hashes, readiness states,
numerical states, and optimizer methods match between v1 and v2 and between v2
and v3. Timing differences are not statistical differences.

| Field | SHA-256 |
| --- | --- |
| Selected 19-route phase manifest | `f84c2a6bdc0c0de11fdff0521a1cf81b76482cf6cdf41ce38118c590f85c1d87` |
| Loaded instrumented mfrmr runtime | `bf50b77cee48e1d97228091c56324af55620ffe1ec86262f0c40fe8460fa56cf` |
| Phase runner | `2401e078608f63e0040ca1869fdeca2e045f41dc6e1bdcc991200ec0d1eec1e4` |
| Draft.49 runner | `fd8e11b52d09815d19a714090b02bbf76373a4748128b078a1fdc7a30e2f8ba5` |
| Runner composite | `9597c4ae2e5380b744b460cbda92c769d29c92063f037370c8c0460b78049cd6` |
| Instrumentation contract | `8880843b55b3fdff522197cc51181d3e2401174a325f17f2744f4bf02364ac2c` |
| Execution identity | `1827f40c3a1314363656123b755ab7a9edbacf6a6987d607d208e9d95b88ea95` |
| Embedded artifact inventory | `596e169e3d71e0869d5837605cd9d9819c7fcbbaf93791411cd84055a7c50671` |
| Result CSV | `4544117792cce08af26bc1bb4510eedf94b1647cf1fedd38527d4dd2b47148e7` |
| Phase timing CSV | `7c1de3ef93a2943eef2bfcf7f9170c5d6c3068c17c2de6204aca8421f67e5809` |
| Phase summary CSV | `c42956c3069e9c831b340a407c641fa991d305af9505f2b91f3ecec285521741` |
| Completion marker file | `ba54b77c307e5d8487b2098c58621355e5c59a9b41fbaa62e7b81a24a5a0c825` |

## Package verification boundary

All 127 `testthat` files were exercised in package-aware source batches after
the timing change. The repository-only runtime-identity tests and installed
vignette-artifact test were also rerun against an installed package rather than
the `pkgload` virtual namespace they deliberately cannot hash. All applicable
tests passed. Skips were limited to unavailable suggested packages; expected
review warnings were retained. One test was made compatible with the current
testthat/waldo scalar contract by removing a name attribute from a logical
expectation; the underlying anchor result was already correct.

The exact current local source artifact is
`mfrmr/.check-draft50-content-v2/mfrmr_0.2.3.tar.gz`, SHA-256
`741b14bcd1772c046c5eca74f33adf65a193fd11c5c7f9fae6a2e5236d2a330c`.
It contains 491 entries, includes the phase-timing regression, and excludes
`inst/validation`, the public roadmap, and every phase runner/record. A
standard `R CMD check --no-manual` of that exact tarball completed install,
static code/Rd/data checks, examples, tests, and vignette rebuilding with one
NOTE: cross-references to the unavailable suggested packages `lme4`, `eRm`,
`mirt`, and `TAM`. The check-log SHA-256 is
`3f40f383337b220bea7b036cc510a0faa6700233c1a33a4c6b29d77a506cfb38`.

This is not a complete `--as-cran` result and not a candidate. The first local
`--as-cran` attempt stopped before package checking because network access and
ten suggested packages were unavailable. A force-suggests-false attempt
passed through ordinary examples but exceeded the ten-minute tool bound during
`--run-donttest`. The standard check including manual generation passed tests
and vignette rebuilding but then failed because `pdflatex` is unavailable.
Those environmental and duration gaps remain explicit; they cannot be
relabeled as `Status: OK`.

The previously checked draft.43 tarball remains historical evidence and no
longer represents the current instrumented source tree. Public `ROADMAP.md`,
`NEWS.md`, the default fit contract, model estimates, and readiness rules are
unchanged by Draft.50. A complete dependency-present, manual-capable
`R CMD check --as-cran` of a future exact artifact is still required before
candidate identity can be discussed.
