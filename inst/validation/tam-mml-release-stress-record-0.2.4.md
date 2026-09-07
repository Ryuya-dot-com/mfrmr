# TAM MML release-stress record for mfrmr 0.2.4

Status: `bounded_tam_mml_release_stress_requires_review`, 2026-09-06.
The prospectively frozen 42-comparison denominator completed without an
execution error, but it did not pass the frozen numerical or q-sensitivity
rules. The 0.2.4 release blocker therefore remains open.

## Bound execution

| Field | Value |
| --- | --- |
| Contract | `mfrmr_tam_mml_release_stress_v1` |
| Source commit | `838fd024c5733d0b41da83af3541f13a10dae5e5` |
| mfrmr | `0.2.4.9000` |
| TAM | `4.3.25` |
| TAM primary functions | `tam.mml`, `tam.mml.mfr` |
| Dataset identities | 21 |
| q-specific matched comparisons | 42 |
| Fixed-standard-normal comparisons | 30 |
| Estimated intercept-only comparisons | 12 |
| Execution errors | 0 |
| mfrmr fits reporting `converged` | 42/42 |
| TAM fits below the 1,000-iteration ceiling | 42/42 |
| Pair rules passed | 12/42 |
| q31-to-q61 integration rules passed | 6/21 |
| Overall release-stress pass | `FALSE` |

The TAM fixed-basis route used a full four-category many-facet design matrix
generated from support-only data, followed by `tam.mml()` on the actual
Person-by-pseudo-item matrix. Four zero-weight support rows prevented TAM from
silently reducing the maximum category of a sparse pseudo-item. TAM reports
raw deviance on the total row-count normalization even for zero-weight support
rows, so the retained raw value and the exact real-Person scale factor are both
stored. Multiplying by that scale reproduces the real-Person objective; it does
not alter fitted coordinates or EAP values.

## Frozen-result disposition

| Population mode / profile | q31 pair pass | q61 pair pass | q31-to-q61 pass | Main observation |
| --- | ---: | ---: | ---: | --- |
| fixed / baseline, 30 responses per Person | 0/3 | 0/3 | 0/3 | q61 still differed by as much as 0.0396 deviance, 0.000880 surface, 0.00437 EAP, and 0.00716 posterior SD |
| fixed / MCAR 20%, about 24 responses per Person | 0/3 | 0/3 | 0/3 | q61 differences remained above the frozen bound |
| fixed / forced extremes, 30 responses per Person | 0/3 | 0/3 | 0/3 | q61 maximum deviance difference was 0.0502 and posterior-SD difference was 0.00927 |
| fixed / sparse Rater, 12 responses per Person | 0/3 | 3/3 | 0/3 | q61 matched; q31-to-q61 movement exceeded the stability bound |
| fixed / weak exposure, 6 responses per Person | 3/3 | 3/3 | 3/3 | both grids matched; mfrmr correctly retained a population-link warning/review state |
| estimated / baseline, 30 responses per Person | 0/3 | 0/3 | 0/3 | latent mean/variance and EAP remained grid-sensitive in mfrmr |
| estimated / weak exposure, 6 responses per Person | 0/3 | 3/3 | 3/3 | q61 matched; q31 pair differences were small but exceeded `1e-4` |

Warnings were retained for the twelve weak-exposure fits. They state that the
free-Person JML design is rank deficient and identification relies on the
common latent-population assumption. This is expected review evidence rather
than an execution failure, and the frozen contract did not require a zero-
warning denominator.

`population_formula = ~ 1` remained not inference-ready with
`design_rank_not_evaluated`; weak exposure additionally retained
`population_assumption_linked`. The numerical comparison does not justify
changing those readiness meanings or making estimated-population fits portable.

## Post-result mechanism probe

After the frozen denominator failed, only fixed-basis baseline replicate 1 was
re-evaluated at denser grids to distinguish a likelihood/coordinate mismatch
from finite-grid resolution. These rows are diagnostic and do not change the
42-comparison pass count.

| q | absolute deviance difference | maximum surface difference | maximum EAP difference | maximum posterior-SD difference |
| ---: | ---: | ---: | ---: | ---: |
| 91 | `0.0035309767` | `1.0646398e-5` | `0.00032252639` | `0.00062161511` |
| 121 | `0.00023138864` | `6.0843691e-6` | `2.4912174e-5` | `5.0900644e-5` |
| 181 | `4.2418742e-7` | `6.4907677e-7` | `1.4132491e-7` | `3.3819795e-7` |

At q181, the two engines agree far inside the frozen `1e-4` pair bounds. In
combination with the q31/q61 pattern by responses per Person, this points to
resolution of sharply concentrated Person-pattern integrals under the current
non-adaptive Gauss-Hermite rule, not a demonstrated difference in the RSM
likelihood or facet-coordinate map. That mechanism inference still requires a
same-dataset q121/q181 diagnostic across the retained profiles before a package
remedy is selected.

## Release consequence

- `ReleaseStressComplete=FALSE`
- `ReleaseBlockerOpen=TRUE`
- `PortableScopeBroadened=FALSE`
- `TAMParityEstablished=FALSE`
- `MultidimensionalEvidence=FALSE`
- `FreeSlopeMultifacetGPCMEvidence=FALSE`
- `ReleaseAuthorized=FALSE`

The next action is not to relax `1e-4`, raise the default quadrature order by an
arbitrary constant, or add a TAM compatibility mode. Reuse these 21 dataset
identities at q121/q181 to map whether the failure is fully integration-driven.
Then choose the smallest truthful 0.2.4 remedy: a fit-time sensitivity guard,
a bounded numerical improvement, or narrower portable-calibration eligibility.
Because RSM exposed a family-general integration issue, the contract's
conditional PCM stress lane is now required before release closure.

## Artifact identities

| Artifact | SHA-256 |
| --- | --- |
| `tam-mml-release-stress-0.2.4.R` | `1a19296db9c650183e37d1d9c448780397009909c4c643e502896380dc40f017` |
| `test-tam-mml-release-stress.R` | `a790340e628319d01d6108a0776f131b4ecb7bc3816429a63e3b818087b02a26` |
| `tam-mml-release-stress-runtime-0.2.4.csv` | `75cf015414ad807b6e7f968d77f6610c2b40192908e0e11140511cf5e7691a16` |
| `tam-mml-release-stress-plan-0.2.4.csv` | `0ecb2c4306f1d94aa0c8f2699969f91575f96a52bb2c93c90bac490784db0da0` |
| `tam-mml-release-stress-summary-0.2.4.csv` | `b67e4037b8561f200ea22f8fa90faff407398f5e80eb5cf0ddcfb732964400da` |
| `tam-mml-release-stress-surface-0.2.4.csv` | `04016e27ff2fff3e98728c14e21751a90f8bd67bc6849ab7fd470873669cd620` |
| `tam-mml-release-stress-score-0.2.4.csv` | `3262db56138bfcb54e44fe7c18724cc2ce408fa258d9cdfb79ee9ba1887f0dc0` |
| `tam-mml-release-stress-integration-0.2.4.csv` | `2a242f7b7353e9874507e118897192005f04c88757e7027772dbf6e281e85eac` |
