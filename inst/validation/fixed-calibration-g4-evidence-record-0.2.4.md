# Fixed-calibration G4 local evidence record for mfrmr 0.2.4

Status: `G4_local_CORE05_complete_CORE06_platform_pending`, 2026-08-22.

- Specification: `0.2.4-fixed-calibration-g4-independent-operational-evidence-v1`
- Contract: `mfrmr_fixed_calibration_g4_evidence_v1`
- Contract frozen before confirmation: `TRUE`
- Complete local denominator opened: `TRUE`
- CORE-05 complete for the exact fixed-basis core: `TRUE`
- CORE-06 complete: `FALSE`
- G4 exit complete: `FALSE`
- Public API authorized: `FALSE`
- Optional lane authorized: `FALSE`
- Native installed macOS release preflight complete: `TRUE`
- macOS-first workflow dependency wired: `TRUE`
- GitHub-hosted macOS release workflow cell complete: `FALSE`
- Next required evidence: macOS release workflow first, then Windows release
  and Ubuntu devel/release/oldrel-1

## Prospective boundary

The contract was written before the confirmation results were opened. It fixed
two new calibration IDs, distinct source and confirmation IDs, a generator
that uses closed-form logits and a modular-997 sequence without R RNG, six
numerical rules, nineteen required adversarial cells, five OS/R cells, and
three resource scales. The confirmation Persons and response rows do not occur
in the source fits or in the earlier `example_core` G1/G3 fixtures.

The G4 result is deliberately split. The complete local independent and
adversarial denominator closes CORE-05 for the exact one-scale RSM/PCM MML,
fixed-N(0,1), point-calibration core. It does not close CORE-06 or G4 because
the current payload still lacks every prospectively frozen workflow result.
The separate native installed-payload macOS record closes a stronger local
preflight, but cannot be substituted post hoc for the GitHub-hosted macOS
workflow cell or stand in for the four Windows/Linux cells.

## Independent mathematics

The confirmation oracle reads only the artifact's declared full-precision
coordinates, signs, response map, nodes, and weights. It directly enumerates
all category logits and normalized probabilities, accumulates weighted
Person-level log likelihoods, and reconstructs the posterior EAP, SD, and grid
interval. It does not call production probability, scoring-materialization,
parameter-expansion, constraint, fitted-object prediction, or scoring helpers.

Across both disjoint fixtures, the maximum production-versus-oracle numerical
differences were:

| Family | Maximum EAP/SD/interval difference | Probability normalization error | Frozen ceiling |
| --- | ---: | ---: | ---: |
| RSM | `9.992007221626409e-16` | `0` | `5e-14` posterior; `2e-14` probability |
| PCM | `2.220446049250313e-15` | `0` | `5e-14` posterior; `2e-14` probability |

Separate explicit RSM and PCM step-Jacobian matrices matched every production
entry exactly and had independently computed ranks 2 and 6. The independent
rank calculation used base QR on the explicit matrices, not the production
rank audit.

## Adversarial and metamorphic denominator

All nineteen prescribed cells were retained. Eighteen had pass dispositions.
The prior-sensitivity cell had its prospectively specified `review` disposition,
not a robustness pass: independently replacing the N(0,1) node scale with
N(0,0.7) and N(0,1.5) produced a maximum EAP change of
`0.5697286825685279`, above the frozen `0.20` review trigger.

That result does not show that the declared N(0,1) score is calculated
incorrectly. It shows that prior robustness must not be claimed. Production
continues to refuse a coherently mutated prior with `SCORING_PRIOR_INVALID`,
and every score says `not_evaluated_fixed_basis`. The 0.2.4 core remains an
exact fixed-basis claim; prior-insensitive, population-transport, and
cut-score-validity claims remain false.

The other cells cover sign-only mutation refusal, coherent sign/coordinate
metamorphism, external score reversal, unbound category-map mutation,
non-ASCII namespace recoding, row and Person-chunk order, C collation, UTF-8
RDS round trip, vanilla-process replay, and corrupt-coordinate load refusal.
The coherent mutations demonstrated why a human-readable calibration ID is
not sufficient by itself. Before confirmation was opened, the scorer was
therefore changed to return the artifact's complete stored semantic components
alongside the ID. This is exact semantic comparison material, not a
cryptographic authenticity or validity claim.

The first local confirmation attempt retained one harness incident in the PCM
rank cell: an invalid matrix subassignment stopped the independent expected-
matrix construction before any PCM comparison was produced. No production
code, identity, denominator, tolerance, or decision rule changed. Correcting
only that test-harness subassignment allowed the originally frozen cell to run;
the repeated complete denominator then passed with no failures, warnings, or
skips. Because no evaluated production code or rule changed after opening,
the contract does not require a new confirmation identity for this harness-only
repair.

## Fresh-process and resource observations

`Rscript --vanilla` loaded the source tree in a new process with no fit,
source-data object, RNG state, or parent-process globals. It loaded an RDS
artifact plus UTF-8 new-response RDS, set C collation, preserved both inputs,
and reproduced the parent PCM results within the frozen `1e-12` platform
ceiling.

The resource rules are regression ceilings, not performance promises or
capacity recommendations. Observations on R 4.6.1, arm64 macOS were:

| Scale | Rows | Artifact bytes | Elapsed seconds | Profiled allocation bytes | Serialized result bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| small | 120 | 12,577 | 0.007 | 107,128 | 40,908 |
| medium | 6,000 | 12,577 | 0.093 | 30,889,800 | 1,559,418 |
| operationally plausible | 30,000 | 12,577 | 0.568 | 673,864,136 | 7,757,418 |

Every observation is below its pre-opened size, time, profiled-allocation, and
serialized-result ceiling. These are one-machine observations. CORE-06 remains
open until the same repository-only test produces zero-failure, zero-warning,
zero-skip results in all five workflow cells.

## Verification and decision

`test-fixed-calibration-g4-evidence.R` passed 114 expectations in 11 tests with
zero failures, errors, warnings, or skips. The test file is excluded from the
source package and is now explicitly invoked by the shared
`.github/workflows/R-CMD-check-cell.yaml` called from
`.github/workflows/R-CMD-check.yaml`. The orchestrator makes macOS release a
prerequisite for the other four jobs. Merely editing that dependency is not CI
evidence. The subsequent isolated installed-payload macOS execution passed the
same 11 tests and 114 expectations with zero failures, errors, warnings, or
skips. GitHub-hosted macOS remains the first required unrun workflow cell; all
five prospectively frozen OS/R workflow cells remain pending.

After the semantic-components change, a source-tarball
`R CMD check --no-manual --ignore-vignettes` completed with `Status: OK` under
R 4.6.1 on arm64 macOS. The build still declares version 0.2.3 because release
metadata belongs to G6; this is an integration check of the current development
payload, not 0.2.4 release evidence. Tarball inspection found no `ROADMAP.md`,
`inst/validation`, or G0--G4 repository-only contract test. Network-restricted
repository-index messages did not alter the check status.

- `CORE05Complete=TRUE`
- `CORE06Complete=FALSE`
- `G4ExitComplete=FALSE`
- `MacOSReleaseNativePreflightComplete=TRUE`
- `MacOSFirstWorkflowWiringComplete=TRUE`
- `MacOSReleaseWorkflowComplete=FALSE`
- `RemainingRequiredWorkflowCells=5`
- `PriorRobustnessClaim=FALSE`
- `PublicAPIAuthorized=FALSE`
- `OptionalLaneAuthorized=FALSE`
- `NextGate=G4-macOS-release-workflow-first`

G5, including OPT-02 bounded GPCM MML, remains unopened. It cannot inherit the
fixed-basis RSM/PCM result and must not begin before G4 exit.
