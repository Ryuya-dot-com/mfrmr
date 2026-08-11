# ConQuest 5.47.5 additive four-arm native record for 0.2.3

Status: four-arm native descriptive review complete; tolerance and candidate
missing, 2026-08-11. This is calibration/schema evidence, not a scientific
equivalence result or release-candidate confirmation.

## Scope and identities

The deterministic complete-crossing design contains 96 Persons, 2 Raters,
2 Criteria, four categories, four observations per Person, and 384 responses.
RSM and criterion-step PCM use byte-identical input SHA-256
`391687fd8eb4e9a857950fcf232014833b0259a6ac7b483c7b1f898fdf03cf91`.
The executable is `/Applications/ConQuest/ConQuest`, version 5.47.5
Demonstration Version, SHA-256
`61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48`.
The repaired source-bound reference tree is
`8ed5fb40efd5f6c98fbe0cdd99f5b40894d601d283a9ebb067f785da76c94dd6`.

The four corrected command hashes are:

| Arm | command SHA-256 |
| --- | --- |
| RSM q31 | `4b702d767116f139c27aca209b5b137bfc279e7a2c4eefcb728b8062d841517c` |
| RSM q61 | `a62aa3aa65bdaa73e489088206043f46efc11dec48a1c099e0504d2bdb0e1b06` |
| PCM q31 | `88de0c97e32032e92111fca64cc2e4c202080c661f4bfedbb1c35dd4b2b6956f` |
| PCM q61 | `e49bcc244cdd2edd8fcaebea800fd0369403ed986197ac2298717858f6df9538` |

## Native execution and descriptive comparison

| Arm | Iterations | native deviance token | mfrmr deviance | abs difference | maximum coordinate abs difference |
| --- | ---: | ---: | ---: | ---: | ---: |
| RSM q31 | 96 | 930.984396 | 930.984395777999 | 2.22e-7 | 2.73e-6 |
| RSM q61 | 96 | 930.984396 | 930.984395777996 | 2.22e-7 | 2.73e-6 |
| PCM q31 | 95 | 930.504780 | 930.504779568474 | 4.32e-7 | 2.10e-6 |
| PCM q61 | 95 | 930.504780 | 930.504779568471 | 4.32e-7 | 2.10e-6 |

Every arm ended by the deviance-change criterion and wrote parameter,
A-matrix, regression, covariance, case-EAP, history, and parameter-review
outputs, with a complete console transcript ending in `End of Program`. The
first RSM q31 run lacked only that outer transcript, so it was retained as
`rsm_q031_initial_no_console` and repeated from the same command/input. Its A
matrix, cases, covariance, history, parameters, and regression exports were
byte-identical to the initial run. For each model, q31 and q61 final coordinates
are identical at the digits retained in the CSV exports. This is an observation
about written tokens, not proof of equality before export.

The native A matrices exactly reconstruct the independently specified
sum-zero basis. Their GIN order is `C1/R1`, `C1/R2`, `C2/R1`, `C2/R2`.
RSM has four native location columns and total free dimension 7 after adding
two regression coefficients and one variance. PCM has six native location
columns and total free dimension 9. The PCM matrix activates its two free step
columns only for the corresponding Criterion; the third step in each block is
derived by sum-to-zero.

ConQuest's history CSV labels its positive objective column `LogLikelihood`,
while the console and internal log identify the same values as deviance. The
review therefore records the semantic correction
`LogLikelihood_column_contains_positive_deviance` and does not negate or halve
the value implicitly.

## Defects found and repaired by the native comparison

1. The command generator's comma-separated implicit-facet grammar was invalid
   for this build. It now uses `facets=criterion(2) rater(2)`.
2. Initial interpretation of GIN ordering from response labels was wrong. The
   exact native A matrix established the order stated above.
3. The mfrmr reference exporter classified PCM step rows by their `Facet`
   value before their `Component`; because PCM steps also have
   `Facet = Criterion`, their exported estimates were `NA`. The exporter now
   distinguishes `Component = Facet` from `Component = Step`, its validator
   requires every estimate to be finite, and a regression test fixes the four
   criterion-specific free-step values.

These were validation/handoff defects. The independently reconstructed mfrmr
probabilities and marginal likelihoods already passed; the native comparison
did not reveal a likelihood-kernel discrepancy in this microcase.

## Numeric-resolution boundary

All five numeric exports per arm pass lexical numeric validation and retain
their raw tokens. Their state remains
`raw_tokens_retained_rounding_unestablished`: neither the manual nor the
observed digits establish a CSV rounding rule. Consequently the displayed
differences above have no pass/fail threshold, and the q31/q61 token equality
does not authorize scientific equivalence.

The complete ignored evidence bundle is in
`validation-results/conquest-additive-native-20260811/` (75 files, about
1.2 MB). Its generated review files have these SHA-256 values:

| Review artifact | SHA-256 |
| --- | --- |
| `native_four_arm_summary.csv` | `38572740236c91fbce3d4bdabee085380a9e30eddddeb4a4bc62424cbaa1c95c` |
| `native_mfrmr_descriptive_differences.csv` | `db3249c9b161c66de057257075062b1e32ec55430f8a8cd348406892194a3e1c` |
| `native_file_manifest.csv` | `a524eceadc976d6c4a13ab1e142476685f740d87306ae9be305f14dc0f00081e` |
| `REVIEW.txt` | `67dc7b749ff3901a75ae428355401abcaeece110f1792817c1d9ac094bc4f57d` |

## Decision and next gate

The machine-readable decision is
`four_arm_native_outputs_ready_tolerance_and_candidate_missing`:

- runtime, schema, A-matrix, four-arm execution, and descriptive arithmetic
  are ready;
- `AcceptanceThresholdSpecified = FALSE`;
- `CandidateBound = FALSE`;
- `ComparisonReady = FALSE`;
- `ScientificEquivalenceInferred = FALSE`; and
- `ConfirmationAuthorized = FALSE`.

The next high-value step is not a large simulation. It is an independent
numeric-resolution/tolerance adjudication followed by a fresh candidate-bound
rerun of this small core. Only after that core passes should Wave C add one
connected sparse and workload-imbalanced microcase. GPCM and broad simulation
remain separate downstream claims.
