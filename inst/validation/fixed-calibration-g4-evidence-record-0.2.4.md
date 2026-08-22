# Fixed-calibration G4 evidence record for mfrmr 0.2.4

Status: `G4_CORE05_CORE06_complete`, 2026-08-22.

- Specification: `0.2.4-fixed-calibration-g4-independent-operational-evidence-v1`
- Contract: `mfrmr_fixed_calibration_g4_evidence_v1`
- Contract frozen before confirmation: `TRUE`
- Complete local denominator opened: `TRUE`
- CORE-05 complete for the exact fixed-basis core: `TRUE`
- CORE-06 complete: `TRUE`
- G4 exit complete: `TRUE`
- Public API authorized: `FALSE`
- Optional lane authorized: `FALSE`
- Native installed macOS release preflight complete: `TRUE`
- macOS-first workflow dependency wired: `TRUE`
- GitHub-hosted macOS release workflow cell complete: `TRUE`
- All five required hosted workflow cells complete: `TRUE`
- Next gate: G5 optional-lane qualification, including independent OPT-02
  bounded GPCM MML adjudication

## Prospective boundary

The contract was written before the confirmation results were opened. It fixed
two new calibration IDs, distinct source and confirmation IDs, a generator
that uses closed-form logits and a modular-997 sequence without R RNG, six
numerical rules, nineteen required adversarial cells, five OS/R cells, and
three resource scales. The confirmation Persons and response rows do not occur
in the source fits or in the earlier `example_core` G1/G3 fixtures.

The G4 result remains deliberately layered. The complete local independent and
adversarial denominator closes CORE-05 for the exact one-scale RSM/PCM MML,
fixed-N(0,1), point-calibration core. The separate native installed-payload
macOS record is a stronger local preflight, but was not substituted post hoc
for the GitHub-hosted macOS workflow cell or for the four Windows/Linux cells.
Fresh run `32534030853` supplied all five prospectively frozen hosted results
for the same commit and closes CORE-06 and G4 without pooling earlier cells.

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
serialized-result ceiling. These remain one-machine performance observations,
not general throughput promises. The same repository-only test subsequently
produced zero-failure, zero-error, zero-warning, zero-skip results in all five
prospectively required workflow cells.

## Verification and decision

`test-fixed-calibration-g4-evidence.R` passed 121 expectations in 11 tests with
zero failures, errors, warnings, or skips. The test file is excluded from the
source package and is now explicitly invoked by the shared
`.github/workflows/R-CMD-check-cell.yaml` called from
`.github/workflows/R-CMD-check.yaml`. The orchestrator makes macOS release a
prerequisite for the other four jobs. Wiring alone was not counted as CI
evidence. The isolated installed-payload macOS preflight and each hosted cell
passed the same 11 tests and 121 expectations with zero failures, errors,
warnings, or skips.

The first hosted macOS attempt is retained as Actions run `32530223829` at
commit `d307031a5a4fea79ebf8c810eba2c691169c067d`. Its R CMD check and repository
release-readiness steps passed, but the G4 step stopped before opening any test
cell because `pkgload::load_all()` requested the non-project development helper
`decor`. The four dependent jobs were skipped as designed. The correction
loads the already installed `check/mfrmr.Rcheck/mfrmr` payload and passes that
same installed-library requirement to the vanilla child. No production code,
fixture, identity, numerical rule, denominator, or decision threshold changed,
so this is a retained harness bootstrap failure rather than a failed numerical
confirmation. A new hosted run was required; the failed attempt is not pass
evidence.

The next hosted run, Actions run `32531360127` at commit
`a23c009bb1106fb7fd676e7febcc9b90a6cb9a1b`, passed macOS release and Ubuntu
devel, release, and oldrel-1. Windows release reached the G4 test file but its
vanilla child compared equivalent installed-library paths with different
Windows separator/case representations, returned status 1, and produced no
result RDS. That run is retained as a platform-harness path-identity failure;
it is not a numerical/core failure and is not pooled with a later Windows
result. The correction canonicalizes both paths with forward slashes and
case-folds them only on Windows. It changes no production code, fixture,
confirmation identity, numerical rule, denominator, or decision threshold.

Fresh Actions run `32534030853` at commit
`f492fb9f0ee977777d03f0255de008af33860db5` reran the complete matrix. Every
job passed R CMD check, repository release-readiness, and the G4 installed-
payload step:

| Required cell | Job ID | Duration | G4 result |
| --- | ---: | ---: | --- |
| macOS release prerequisite | `96931462336` | 10m24s | 121/121; pass |
| Windows release | `96933399945` | 18m33s | 121/121; pass |
| Ubuntu devel | `96933399841` | 15m34s | 121/121; pass |
| Ubuntu release | `96933399867` | 1h1m32s | 121/121; pass |
| Ubuntu oldrel-1 | `96933399798` | 14m50s | 121/121; pass |

This single fresh run supplies the complete five-cell denominator; no result
from either failed run was pooled into it. Actions annotations that older
action versions are being forced from Node.js 20 to Node.js 24 are non-
blocking workflow-maintenance signals and do not replace or negate any G4
cell. CORE-06 and G4 therefore close for the fixed-N(0,1) RSM/PCM core.

After adjudication, eight static assertions bind this record to the successful
run ID, commit SHA, required-cell count, retained Windows harness failure,
closed public/optional authorization, and the unopened G5 boundary. The
repository G4 file therefore now has 129 expectations in the same 11 tests.
Those assertions audit the record and scope boundary; they do not alter or
retroactively enlarge the 121-expectation numerical/operational denominator
that passed in each hosted cell above.

After the semantic-components change, a source-tarball
`R CMD check --no-manual --ignore-vignettes` completed with `Status: OK` under
R 4.6.1 on arm64 macOS. The build still declares version 0.2.3 because release
metadata belongs to G6; this is an integration check of the current development
payload, not 0.2.4 release evidence. Tarball inspection found no `ROADMAP.md`,
`inst/validation`, or G0--G4 repository-only contract test. Network-restricted
repository-index messages did not alter the check status.

- `CORE05Complete=TRUE`
- `CORE06Complete=TRUE`
- `G4ExitComplete=TRUE`
- `MacOSReleaseNativePreflightComplete=TRUE`
- `MacOSFirstWorkflowWiringComplete=TRUE`
- `MacOSReleaseWorkflowComplete=TRUE`
- `RemainingRequiredWorkflowCells=0`
- `HostedMacOSAttempt1Retained=TRUE`
- `HostedMacOSAttempt1DenominatorOpened=FALSE`
- `HostedWindowsPathHarnessAttemptRetained=TRUE`
- `HostedWorkflowRun=32534030853`
- `HostedWorkflowCommit=f492fb9f0ee977777d03f0255de008af33860db5`
- `HostedWorkflowRequiredCellsPassed=5`
- `PriorRobustnessClaim=FALSE`
- `PublicAPIAuthorized=FALSE`
- `OptionalLaneAuthorized=FALSE`
- `NextGate=G5-optional-lane-qualification`

G5, including OPT-02 bounded GPCM MML, is now the next unopened gate. It cannot
inherit the fixed-basis RSM/PCM result; its own contract, falsifiers, and
confirmation denominator must be frozen before its results are opened.
