# mfrmr 0.2.3 external IC normalization pilot record

## Record state

| Field | Value |
| --- | --- |
| Evidence role | Pilot/unit development evidence |
| Initial arithmetic specification | `0.2.3-draft.5` |
| Current seed-identity extension | `0.2.3-draft.6` |
| Current ConQuest handoff extension | `0.2.3-draft.7` |
| Current strict-convergence extension | `0.2.3-draft.8` |
| Current binary node-ladder extension | `0.2.3-draft.9` |
| Current polytomous RSM/PCM extension | `0.2.3-draft.11` |
| Contract | `mfrmr_external_ic_v1` |
| ConQuest handoff contract | `mfrmr_conquest_ic_handoff_v1` |
| ConQuest ladder contract | `mfrmr_conquest_binary_ladder_v1` |
| ConQuest polytomous contract | `mfrmr_conquest_polytomous_rsm_pcm_ladder_v1` |
| Run date | 2026-07-28 |
| Source identity | Commit `10cf3e8e8ff07f3ce1021ae28310ffcbd99d058c` plus uncommitted working-tree changes |
| Runtime | R 4.6.1; TAM 4.3-25; ConQuest 5.47.5 Demonstration Version under Rosetta x86_64 |
| Confirmation authorized | No |
| Status | `review` |

This record tests arithmetic, provenance separation, the ConQuest objective
handoff, and fail-closed identity behavior. Its strict-control binary run,
same-platform repeat, and node ladder support a narrow mfrmr/ConQuest objective
and transformed-parameter match from q=31 through q=121. Its four-category
RSM/PCM node ladder and same-platform q=31 repeats additionally support a
likelihood and sum-zero constraint mapping over the q=31--121 core while
exposing low-node instability. These pilots do not establish a frozen
tolerance, independent-platform replication, integration stability, or
general mfrmr/TAM/ConQuest equivalence.

## Deterministic fixture audit

`external-ic-audit-0.2.3.R` retained all seven registered fixtures and returned
`status = "ok"`. The cases cover:

- complete MML arithmetic under the common Person basis;
- TAM native aBIC versus common Sclove SABIC;
- integration stability not checked;
- JML suppression;
- the `N_person <= 22` SABIC selection boundary;
- inconsistent deviance and log likelihood; and
- incomplete comparison identity.

The positive two-record fixture produced common deltas only after observation,
likelihood, constraint, integration-evaluation, integration-comparison,
convergence, and integration-stability fields were complete. Changing the
shared integration-comparison identity suppressed all deltas and weights.

## Live TAM adapter exercise

A deterministic 60-Person, four-item PCM development fit exercised the TAM
object adapter with default 21-node QMC and one latent dimension. The fit
stopped at iteration 36 of a 1000-iteration ceiling. The recorded arithmetic
was:

| Field | Value |
| --- | ---: |
| Deviance | 271.0522940930592 |
| Log likelihood | -135.5261470465296 |
| Free parameters | 9 |
| Persons | 60 |
| Native TAM AIC | 289.0522940930592 |
| Native TAM BIC | 307.9013951530580 |
| Native TAM aBIC | 278.9937967148454 |
| Common Sclove SABIC | 279.5940190853335 |

The adapter verified native AIC, BIC, and aBIC against their recorded formulas.
Native aBIC and common SABIC differ by approximately 0.60022 because TAM
4.3-25 uses `(n - 2) / 24`, whereas the common contract uses
`(n + 2) / 24`.

The same record was also generated with all comparison identities omitted and
the default convergence/integration states. Arithmetic remained available,
but `ComparisonReady = FALSE` with reasons
`comparison_identity_incomplete`, `convergence_unverified`, and
`integration_stability_not_checked`. This is the intended default.

Draft.6 extends the TAM integration-evaluation identity for stochastic
`QMC = FALSE` fits with the operative seed. Deterministic product/QMC records
remain identified by method and node count without pretending that a seed is
operative. Unit tests verify that a stochastic record contains
`qmc=false:nnodes=<n>:seed=<seed>` and remains non-comparable unless the full
identity, convergence, and integration-stability review is supplied.

## Live ConQuest matrixout handoff exercise

The existing synthetic overlap case was rerun with 60 Persons, six binary
items, one numeric latent-regression covariate, and 31-node Bock-Aitkin
quadrature. The working-tree mfrmr fit was inference-ready with terminal
gradient sup-norm `1.503183e-07`. ConQuest table 1 could not be written as CSV
in 5.47.5: the program
reported that CSV and SPSS formats were unavailable for the summary table.
Draft.7 therefore does not parse that free-form report. The generated command
instead sets `matrixout=mfrmrCQ` on `estimate` and writes
`mfrmrCQ_history` as a native CSV matrix. The end-to-end rerun used the
generated, explicit ConQuest controls `convergence=1e-8`,
`deviancechange=1e-10`, and `iterations=2000` rather than relying on the
program defaults.

The repository-only `mfrmr_external_ic_from_conquest()` adapter produced:

| Field | Value |
| --- | ---: |
| Final history rows / iteration | 132 / 132 |
| ConQuest deviance | 424.738979 |
| mfrmr deviance | 424.738979414154 |
| ConQuest minus mfrmr deviance | -0.000000414154 |
| Free parameters from history shape | 8 |
| Free parameters from native exports | 8 = 5 parameter + 2 regression + 1 covariance rows |
| Persons from exact bundle-to-case PID match | 60 |
| Common AIC | 440.738979000000 |
| Common Person-BIC | 457.493735497777 |
| Common Sclove SABIC | 432.331623437577 |
| Final history/export vector match | Yes |
| Unit-weight check | Passed |
| Largest mfrmr/ConQuest transformed-parameter absolute difference | 0.00000577 |
| Comparison ready | No (`integration_stability_review`; recorded identity labels are not yet substantively matched across engines) |

An earlier default-control diagnostic stopped at iteration 42 with deviance
`424.739512`. The explicit-control generated command moved the final deviance
by `-0.000533`. Relative to mfrmr deviance `424.738979414154`, the default-run
difference was approximately `5.33e-4`, whereas the strict-run difference was
`-4.14e-7`, within the six-decimal ConQuest CSV resolution. The largest
absolute difference across the eight audited, transformed coordinates was
`5.77e-6`. This removes the apparent additive likelihood-constant discrepancy
for this one binary pilot. It is retained as a reason to record ConQuest
stopping controls explicitly and to keep cross-engine IC comparison closed
until replication, integration review, and tolerance freeze are complete.

Manual section 4.9.2 defines the third estimate-history matrix column as
deviance. ConQuest 5.47.5 nevertheless labels that column `LogLikelihood` in
the matrixout CSV. Its positive value matches both the console deviance and
the human summary (`424.73898` after report rounding), whose native AIC and BIC
also match the recomputed common values after rounding. The adapter therefore
uses the documented column position, preserves the native header discrepancy
in audit metadata, and cross-checks all eight final coordinates before
accepting the arithmetic. The adapter rejects versions other than 5.47.5
until their matrixout schema and objective semantics receive a new audit.

The human summary records termination because the deviance convergence
criterion was reached. A `pass` convergence state requires an explicit
evidence ID; it cannot be inferred merely from a finite final history row. The
initial 31-node run does not by itself establish integration stability or
matched RSM/PCM constraints, so it remains pilot evidence rather than a release
comparison. No response, case, or identifier-bearing ConQuest output is
retained in this repository record.

## Strict binary node ladder and same-platform repeat

Draft.9 adds repository-only runner
`conquest-binary-ladder-pilot-0.2.3.R`. It prepares the controlled bundles and
reviews the outputs but deliberately never launches ConQuest. The pilot used
the same synthetic response file in every row (MD5
`4d31cf13ad8e40d94be4524adb36d853`), strict mfrmr controls
`maxit=2000, reltol=1e-12`, and the strict ConQuest controls recorded above.
The external program was run separately for q=7, 15, 31, 61, 91, and 121,
with a second fresh q=31 directory.

| Run | Nodes | Handoff | Final history objective | ConQuest minus mfrmr deviance | Maximum history/export difference |
| --- | ---: | --- | ---: | ---: | ---: |
| `q007` | 7 | Rejected | 423.616245 | — | 0.036778 |
| `q015` | 15 | Rejected | 424.735367 | — | 0.000087 |
| `q031a` | 31 | Arithmetic accepted | 424.738979 | -0.000000414154 | 0 |
| `q061` | 61 | Arithmetic accepted | 424.738979 | -0.000000414154 | 0 |
| `q091` | 91 | Arithmetic accepted | 424.738979 | -0.000000414155 | 0 |
| `q121` | 121 | Arithmetic accepted | 424.738979 | -0.000000414155 | 0 |
| `q031b` | 31 | Arithmetic accepted | 424.738979 | -0.000000414154 | 0 |

Across the four distinct q=31--121 core nodes, the ConQuest deviance range was
zero at its six-decimal export resolution, the mfrmr deviance range was below
`1e-12`, the maximum absolute cross-engine deviance difference was
`4.142e-7`, and the maximum transformed-parameter difference was `5.762e-6`.
All five native ConQuest CSV files from `q031a` and `q031b` were byte-identical.

The rejected rows are part of the result. At q=7, ConQuest reported that an
earlier higher-likelihood solution would be retained, so the terminal history
vector did not describe the exported solution. At q=15, ConQuest reported
deviance-criterion termination without the higher-likelihood warning, but the
terminal history and exported vectors still differed by as much as `8.7e-5`.
The existing adapter rejected both before common IC arithmetic could be used.
This supports the current q<31 fail-closed boundary, but it is not a frozen
`EXT-CQ-TOL` or `IC-INTEGRATION-TOL` and does not make any row comparison-ready.

## Four-category RSM/PCM node ladder and same-platform repeats

Draft.10 introduced repository-only runner
`conquest-polytomous-rsm-pcm-pilot-0.2.3.R`; draft.11 extends it to matched
node ladders. It generated one deterministic PCM-mechanism fixture with 120
Persons, five items, four categories, one numeric latent-regression covariate,
and complete category 0--3 coverage for every item. The same wide CSV (MD5
`e50b7c9831243b5f13f979fed53271f0`) was used in all 14 runs: q=7, 15, 31, 61,
91, and 121 plus a fresh q=31 directory for each of RSM and PCM. ConQuest used
`model item + step` for RSM and `model item + item*step` for PCM, matching the
adjacent-category difficulty orientation documented in manual sections 2.3.2
and 4.7.43.

The reviewer did not parse the free-form summary to obtain the objective or
coordinates. It required a complete captured console for termination evidence,
the native matrixout history, parameter/regression/covariance exports, exact
case-PID matching, and the audited 5.47.5 parameter-label order. It then
reconstructed every constrained final item and step coordinate from the native
free vector and compared it with the mfrmr full-coordinate table.

| q=31--121 core field | RSM | PCM |
| --- | ---: | ---: |
| ConQuest model | `item + step` | `item + item*step` |
| Free parameters, both engines | 9 | 17 |
| ConQuest deviance at every core node | 1426.254015 | 1393.460210 |
| ConQuest deviance range | 0 | 0 |
| mfrmr deviance range | 0.000000059600 | 0.000000876370 |
| Maximum absolute ConQuest-minus-mfrmr deviance | 0.000000141830 | 0.000001248110 |
| Maximum free/full transformed-coordinate difference | 0.000001540362 | 0.000001674273 |
| Maximum reconstructed constraint residual | 0 | 0 |
| Five native q=31 CSV files byte-identical across repeats | Yes | Yes |
| Comparison ready | No | No |

The maximum cross-engine difference in the RSM-minus-PCM deviance drop over
the four core nodes was `1.10628e-6`. Every core run passed the native
history/export handoff, and each model's two q=31 runs had exactly identical
native output fingerprints and deviances.

The q<31 rows remain part of the result and show why arithmetic extraction is
not an integration pass:

| Run | Handoff | ConQuest minus mfrmr deviance | Maximum free-parameter difference | Maximum history/export difference |
| --- | --- | ---: | ---: | ---: |
| RSM q=7 | Arithmetic accepted | 4.437555345 | 0.380429242 | 0 |
| RSM q=15 | Arithmetic accepted | -0.227497536 | 0.009824753 | 0 |
| PCM q=7 | Rejected | — | — | 0.000001 |
| PCM q=15 | Arithmetic accepted | -0.116292171 | 0.008380097 | 0 |

PCM q=7 failed closed because its terminal history and native export vectors
differed by `1e-6`. The other three rows were structurally auditable, but
their objective and parameter drift is material relative to the core.
`accepted_arithmetic` therefore authorizes neither comparison nor selection.
The entire ladder remains `ComparisonReady = FALSE`; neither `EXT-CQ-TOL` nor
the integration criterion is frozen. Independent platform/version replication
and candidate-linked confirmation remain required. No generated response, PID,
covariate, case-EAP, or native ConQuest output is committed to the repository.

## Public import boundary

`import_tam_fit()` now rejects `tam.jml` and any `tam.mml` object with
`ndim > 1`. A supported unidimensional import keeps TAM version, dimension,
native criterion fields and formulas, and a conservative iteration-ceiling
status, but remains `ICEligible = FALSE` under the current mfrmr comparison
contract. Multidimensional evidence belongs to the separate repository runner.

## Unresolved before external evidence

1. Repeat the strict binary and polytomous cores on an independent
   platform/version and freeze the integration policy only after the
   cross-platform evidence has passed review.
2. Extend the draft.6 dimension-aware TAM runner beyond its first binary
   product-quadrature/deterministic-QMC matrix to stochastic repeats,
   replicated controls, and cross-platform review.
3. Match mfrmr and TAM one-dimensional likelihood constants and constraints
   before any cross-engine common panel is interpreted.
4. Run candidate-linked binary, RSM, and PCM external pilots and freeze the
   remaining tolerances before confirmation.
