# TAM PCM MML conditional-stress record for mfrmr 0.2.4

Status: `high-grid PCM overlap passed; default-grid release remedy required`,
2026-09-06. The contract and runner were frozen at commit
`96ac023a94cb4af08330eef03396e29119932d39` before these results were viewed.

## Complete execution

| Field | Result |
| --- | ---: |
| Fixed-N(0,1) datasets | 15/15 |
| Matched q-specific comparisons | 60/60 |
| Execution errors | 0 |
| mfrmr converged fits | 60/60 |
| TAM fits below the 1,000-iteration ceiling | 60/60 |
| All-grid matched rules passed | 34/60 |
| Consecutive-grid stability rules passed | 24/45 |
| ConditionalStressComplete | `FALSE` |
| ReleaseAuthorized | `FALSE` |

Matched-pair results improved monotonically with grid density:

| Grid | Pair rules passed |
| --- | ---: |
| q31 | 3/15 |
| q61 | 6/15 |
| q121 | 10/15 |
| q181 | 15/15 |

At q181 the largest cross-engine differences over all 15 datasets were
`2.125175e-6` for deviance, `1.076843e-5` for the complete
cumulative-difficulty surface, `1.938350e-6` for EAP, and `8.696571e-7` for
posterior SD. These are all below the frozen `1e-4` engineering bound.

## Same-engine grid sensitivity

| Transition | Stable datasets | Profiles passing all three replications |
| --- | ---: | --- |
| q31 to q61 | 3/15 | `WEAK_EXPOSURE` |
| q61 to q121 | 6/15 | `SPARSE_RATER`, `WEAK_EXPOSURE` |
| q121 to q181 | 15/15 | all five profiles |

For q121 to q181, the maximum movements were:

| Metric | mfrmr | TAM |
| --- | ---: | ---: |
| deviance | `7.629892e-4` | `5.093170e-11` |
| cumulative-difficulty surface | `1.096775e-5` | `1.202372e-7` |
| EAP | `4.177120e-5` | `2.850421e-8` |
| posterior SD | `9.473137e-5` | `1.956114e-9` |

The fixed population mean and variance did not move. By contrast, maximum
mfrmr q31-to-q61 movements reached `1.047182` in deviance, `0.020210` in the
surface, `0.058318` in EAP, and `0.073108` in posterior SD. The corresponding
q61-to-q121 maxima were `0.054711`, `0.001971`, `0.005701`, and `0.009270`.

## Interpretation

PCM reproduces the RSM mechanism: six-response weak-exposure patterns are
already stable at q31, sparse twelve-response patterns require a denser grid,
and the 24--30-response patterns require still more integration resolution.
At an independently stable high grid, the fixed-basis PCM likelihood,
criterion-owned step surface, EAP, and posterior SD agree with TAM under the
frozen bounds.

This closes the question of whether the retained problem is caused by RSM
step sharing: it is not. It does not establish a universal q181 default, TAM
parity, or a user-facing scientific cutoff. The remaining 0.2.4 task is one
family-aware same-data quadrature-sensitivity route for RSM and PCM, with
continuous evidence exposed to users. Portable extraction must not silently
convert an unreviewed fit-time grid into a stable calibration claim; the exact
least-disruptive contract remains to be specified before production code is
changed.

## Artifact identities

| Artifact | SHA-256 |
| --- | --- |
| `tam-pcm-mml-conditional-stress-0.2.4.R` | `95b69640002d49c861e2b4ee9ef5e86dfedc98b81babce2dd780e14836f6ab25` |
| `tam-pcm-mml-conditional-stress-runtime-0.2.4.csv` | `5a1793d000793406e76a9bb425f0786ceaad59eb3b083849886d4aebc0d05ea1` |
| `tam-pcm-mml-conditional-stress-plan-0.2.4.csv` | `175c1636e8b1eaed0b2a760a74ba6adc224371ee455a689f6462419ff418588d` |
| `tam-pcm-mml-conditional-stress-summary-0.2.4.csv` | `4454d5c614a7279025153e1ecbc3de34c6680b3620f74082ac0267a2a00318b1` |
| `tam-pcm-mml-conditional-stress-surface-0.2.4.csv` | `4cb1d6490f6fcd62fef8c5c22e33aebf19ab582a500152b11c0b6f1f0a5f0aa6` |
| `tam-pcm-mml-conditional-stress-score-0.2.4.csv` | `2da979e045596e94d6f7a1f72d5c2a4782aea0c64a7fdca9f9728247bd772909` |
| `tam-pcm-mml-conditional-stress-integration-0.2.4.csv` | `2daac40ef7ea66e6865b07c06ec59c236cba94ea9f74f3576b2acdfd9ccf14e6` |
