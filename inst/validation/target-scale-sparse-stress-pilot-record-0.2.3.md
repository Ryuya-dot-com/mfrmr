# Target-scale sparse stress pilot record for mfrmr 0.2.3

Status: repository-only draft.47 capacity-feasibility evidence, 2026-08-05.
This is a one-replicate-per-cell calibration run. It does not estimate
recovery, coverage, false-positive rates, power, or failure probabilities; it
freezes no threshold, authorizes no confirmation, and establishes no FACETS
capacity-parity claim.

## Decision

Stress execution should begin before the wider replicated pilot because
target-scale behavior can change the support envelope and the claim-
disposition profile. It must, however, answer bounded questions rather than
become an unbounded search for favorable scenarios.

Draft.47 therefore executes all six `target_sparse` cells that were already
declared executable in the draft.41 pairwise covering-grid pilot manifest.
Each cell has 400 generated Persons. Together they cover GPCM and PCM, JML and
MML, 2--12 Raters, sparse and disconnected assignment, rater-, Person-,
outcome-, and MCAR-related retention, category imbalance and a missing
boundary category, zero or unequal weights, Occasion-distinguished repeats,
interactions, bias/drift, local dependence, and residual PCA.

All six cells executed without an unexpected runner failure. There were zero
false-ready results. Only one cell reached `InferenceReady = TRUE`; it is a
deliberately difficult review/recovery cell and is now a priority target for
replicated recovery work, not evidence that its statistical behavior is
adequate.

## Fixed execution contract

The guarded runner is
`target-scale-sparse-stress-pilot-0.2.3.R`. Live execution requires
`authorize = TRUE`, requires a new output directory, uses a staging directory,
and refuses overwrite. The final bundle binds the selected manifest, loaded
package, runner components, capability inventory, controls, and artifacts by
SHA-256. A completion validator checks safe relative paths, file sizes, file
hashes, execution identity, and the prohibition on confirmation in a fresh R
session.

The fixed settings were:

| Setting | Value |
| --- | --- |
| R | 4.5.1, `x86_64-w64-mingw32` |
| mfrmr | exact checked 0.2.3 runtime |
| Selected cells | 6 |
| Generated Persons per cell | 400 |
| Executed replicates per cell | 1 |
| Replicates declared for a later pilot | 5 |
| Optimizer limit | 180 iterations |
| MML screening quadrature | 7 points |
| Residual PCA | requested where a fit object was returned |
| Evidence use | `capacity_feasibility_calibration_only` |
| Confirmation authorized | No |

The single execution does not satisfy the manifest's declared five-replicate
pilot. Keeping `ExecutedReplicates = 1` and `DeclaredPilotReplicates = 5`
separate prevents a capacity check from masquerading as Monte Carlo evidence.

## Results

| Cell | Retained structure | Result | Time (s) | R heap high-water proxy |
| --- | --- | --- | ---: | ---: |
| `GPCM-P-008` | 397 Persons, 12 Raters, 12 Criteria, 5,457 rows; minimum 38 shared Persons per Rater pair; category counts `888;823;976;49;956;904;861` | GPCM MML reached the iteration limit; `blocked`, not inference-ready; exploratory PCA returned | 58.25 | 77.43 MB Vcells |
| `GPCM-P-018` | 182 Persons, 3 Raters, 2 Criteria, 220 rows; 2 zero-common-Person Rater pairs | disconnected GPCM MML remained `blocked`; population-assumption link, weak category information, and iteration limit recorded | 2.23 | 77.43 MB Vcells |
| `GPCM-P-019` | 389 Persons, 6 Raters, 2 Criteria, 1,753 rows; binary maximum category fraction 0.934 | PCM JML completed as `ready_with_exclusions`; extreme low/high Persons prevent inference-ready promotion; exploratory PCA returned | 3.14 | 77.43 MB Vcells |
| `GPCM-P-024` | 400 Persons, 12 Raters, 4 Criteria, 7,999 rows; category counts `1294;6705`; 728 exact repeats but zero repeats after Occasion distinction | PCM MML was `ready` and inference-ready; this is the sole ready cell and requires replicated recovery/diagnostic challenge | 43.30 | 77.43 MB Vcells |
| `GPCM-P-031` | 350 Persons, 12 Raters, 4 Criteria, 1,051 rows; 36 zero-common-Person Rater pairs | PCM JML failed closed before optimization: constrained rank 374/376, affecting Person, Rater, and Criterion blocks | 2.03 | 93.51 MB Vcells |
| `GPCM-P-040` | 389 Persons, 2 Raters, 12 Criteria, 1,295 rows; zero shared Persons; seventh category absent | PCM MML failed closed before optimization: constrained rank 71/72, affecting Rater and Criterion blocks | 1.18 | 93.52 MB Vcells |

Total measured cell time was 109.73 seconds; the slowest cell was 58.25
seconds. The maximum recorded R `gc()` high-water proxies were 93.52 MB for
Vcells and 197.44 MB for Ncells. These are runtime-specific R heap proxies,
not operating-system peak resident memory and not capacity limits. Package
loading and diagnostic dependencies contribute to their baseline, so they
must not be compared as clean per-estimator allocations.

The GPCM mixed-adversity cell produced a log-slope RMSE trace of about 0.181,
but had no primary slope values and was numerically blocked. That trace is
therefore not a recovery result and cannot be used to select a tolerance. The
disconnected GPCM cell's much larger optimizer trace is likewise ineligible.

## Adversarial findings

1. Target scale is computationally feasible for these six bounded cells on
   this runtime, but free-slope GPCM MML under simultaneous sparse,
   missingness, support, weight, interaction, and bias challenges did not
   become numerically ready within the fixed controls. The next step is to
   isolate cause and improve the algorithm or support contract; widening a
   terminal-gradient or recovery tolerance would be invalid.
2. Binary connectivity is insufficient. The disconnected JML and two-Rater
   MML controls were stopped by exact constrained-rank checks, while another
   disconnected MML GPCM cell reached fitting but remained blocked under an
   explicit latent-population-assumption dependency. These are distinct
   failure modes and must remain distinct in the public support envelope.
3. Severe category imbalance does not imply automatic failure. The PCM JML
   cell was excluded by extreme Persons, while the 12-Rater PCM MML cell was
   numerically and inferentially ready despite 83.8% of observations in one
   category. Readiness therefore cannot substitute for replicated parameter
   recovery, interval coverage, bias, and diagnostic operating
   characteristics.
4. The two-Rater, zero-overlap, missing-boundary-category cell had zero false-
   ready behavior: it failed structurally before optimization. This is a
   useful negative control, not evidence that weak but nonzero bridges are
   calibrated.
5. Residual PCA is still exploratory. Four returned fits reached the PCA
   route, but the most complex GPCM cell emitted `psych` messages that the
   smoothed-correlation determinant and parts of the objective were undefined.
   The current stress result still labels the returned object
   `available_exploratory`. Before any diagnostic claim, the PCA contract must
   capture condition messages, record residual-matrix dimension/rank and
   smoothing state, and distinguish a computable descriptive decomposition
   from a valid inferential diagnostic.

## Evidence integrity

The authoritative bundle is outside the package source tree at
`mfrmr/archive/artifacts/validation-bundles-0.2.3/target-scale-stress-20260805-v3`.
The first execution is retained beside it as a
superseded evidence-integrity diagnostic because its completion marker did not
embed the hashed artifact inventory. The second embedded and verified the
inventory during the run, but its validator did not load hash support when
called directly in a fresh session. The third execution corrected that
independent-validation contract. Stable result fields are identical across
the second and third executions; only time and R heap high-water fields vary.

| Field | SHA-256 |
| --- | --- |
| Declared 70-cell covering-grid manifest | `0607c937bde20db544330180693ca6e9ae55c888d17748679ec9d99d1c180282` |
| Selected six-cell manifest | `7130af085cd3d8cf3a0101faf5bd69fedf3b88b9edfd421769e92d58075cf598` |
| Loaded mfrmr runtime package | `28d3bb9d2a30c519f0d092be2149a819ab4de2dd03c27fb157c09bf7bf4038f8` |
| Capability manifest | `e7448ae6361dc97e367049b89ae3bd68cfa38799dd53fddb2d6596a077e9bada` |
| Runner composite | `a4902f8dc2696907db8ecb5be92d2e3904c3e3317f97abdd8a07aa279ed627a6` |
| Target-scale runner file | `50ee40562080cc5b2561d7e93bd9ec0eb13c451a6d728b8d61071bd0b306e0c8` |
| Complete execution identity | `6d6dea58d3e64fc6f06754ed90d024efaa1d61896dccc822adfc35b2c52036ef` |
| Embedded artifact inventory | `a2ea26078b9bf04f7dcf52f4f7f5a8a4ac0cefd8d8a4477ad016b7b0f91fd633` |
| Result CSV | `be175b4f941b5a29c0d1d5bf4617a1bffb3f7399776e71616d6ac9410cfc388a` |
| Completion marker | `4a93e0108dfc13ed1290fc9a70625fc97f94935b5276074d1a43806fffae19ca` |

The public package remains the exact checked draft.43 payload:

- tarball SHA-256:
  `88EBD28817AD1924A9AE235F56301264D5EC47FD06A9416D6A4BA55C5C59DFA6`;
- `R CMD check --as-cran` log SHA-256:
  `B3956B95ABCB26BDE6D9CBD1A675ED9DE4C5365970B3F86FAEAA0B7FBDB8AA3D`;
- status: `OK`.

The runner, record, protocol tests, and internal roadmaps are excluded from the
source-package payload. No public API or package byte changed in draft.47.

## Consequence for the roadmap

This run closes only the first target-size construction/runtime feasibility
slice. It does not close target-size support bounds. The next sequence is:

1. add a balanced connected RSM/PCM/GPCM baseline at each target tier so
   adversity costs can be separated from scale costs;
2. add weak-bridge cells with prespecified common-Person counts between zero
   and the current strong linked design, especially for two Raters;
3. measure operating-system peak resident memory and record design/parameter
   dimensions before allocation;
4. run the five declared pilot replicates only after recovery estimands,
   denominators, MCSE goals, and diagnostic/PCA computability states are
   fixed; and
5. use those results to bound or defer claims. Do not expand confirmation or
   claim FACETS-scale capacity parity from this feasibility run.
