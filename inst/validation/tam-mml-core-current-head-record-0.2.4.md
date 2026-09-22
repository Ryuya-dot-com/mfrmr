# TAM MML current-head regression record for mfrmr 0.2.4

Status: bounded current-head regression complete, 2026-09-06. This record
replays the frozen RSM/PCM benign-core comparison on the 0.2.4 development
namespace. It is an engineering continuity check, not an MML stress envelope,
a scientific equivalence decision, or release authorization.

## Runtime and reuse boundary

| Field | Value |
| --- | --- |
| Contract | `mfrmr_tam_mml_core_current_head_v1` |
| mfrmr source version | `0.2.4.9000` |
| TAM version | `4.3.25` |
| Primary TAM function | `TAM::tam.mml.mfr` |
| Models | RSM and criterion-step PCM |
| Estimator | MML, fixed unit slope |
| Facets | criterion (`item`) plus rater |
| Latent regression | intercept plus `X` |
| Identification | TAM `cases`, transformed to mfrmr sum-zero criterion coordinates |
| Integration | q=31 and q=61 |
| Reused numerical implementation | frozen 0.2.3 design, mfrmr oracle, coordinate map, and TAM runner |

The current-head bridge changes only the source-namespace identity check. It
temporarily replaces the historical `0.2.3` guard with an exact comparison
between the loaded namespace version and the source `DESCRIPTION`, restricted
to the `0.2.4` series. The historical sources and record remain unchanged.

## Observed regression

| Run | TAM deviance | mfrmr deviance | TAM − mfrmr deviance | maximum transformed coordinate difference |
| --- | ---: | ---: | ---: | ---: |
| RSM q31 | 930.9843959423328 | 930.9843957779988 | 1.643339828660828e-7 | 5.557667703826041e-8 |
| RSM q61 | 930.9843957779955 | 930.9843957779965 | -1.023181539494544e-12 | 3.434901861554263e-8 |
| PCM q31 | 930.5047797909033 | 930.5047795684739 | 2.224294348707190e-7 | 9.896866970393603e-8 |
| PCM q61 | 930.5047795684706 | 930.5047795684713 | -7.958078640513122e-13 | 4.484571936025361e-8 |

The maximum independent mfrmr oracle log-likelihood difference was
`1.136868e-13`; the maximum independent category-probability difference was
`1.776357e-15`. The focused test completed in 11 seconds.

These values reproduce the historical observation. The `1e-5` test bound is
only a broad engineering regression guard and is not a frozen scientific
tolerance.

## Stress disposition

| Question | Status |
| --- | --- |
| Current 0.2.4 source can replay the benign TAM comparison | `TRUE` |
| RSM/PCM q31/q61 integration sensitivity represented | `TRUE` |
| Weak information, sparse assignment, extreme scores, or missingness stressed against TAM MML | `FALSE` |
| EAP-to-EAP scoring compared | `FALSE` |
| Estimated-population intercept-only readiness calibrated | `FALSE` |
| Free-slope multifacet GPCM compared through `tam.mml.mfr` | `FALSE`; that TAM route does not estimate item slopes |
| Scientific equivalence or general TAM compatibility established | `FALSE` |
| Release authorization changed | `FALSE` |

The next bounded MML comparison remains MC-1: one matched 80 Person × 6 item ×
5 rater RSM design with parameter, deviance, variance, and EAP-to-EAP outputs
in one record. It remains post-0.2.4 work and should not be replaced by the
existing TAM/immer JML stress matrix.

## Source identities

| Artifact | SHA-256 |
| --- | --- |
| `tam-mml-core-current-head-0.2.4.R` | `5d72177aeb3e193107cea2a46656249649e80e3063d3958380c3247f6fbb3227` |
| `test-tam-mml-core-current-head.R` | `9a930a51ef980a9fd8d3c36b21fe5831de754acc1d92c9579dc9e3eed36239cf` |
| `tam-mml-core-calibration-0.2.3.R` | `f5c393060e65ebfc4a2dcdf5b7173d1726a28e404b2f30010fd5b71103333033` |
| `conquest-additive-mfrm-reference-preflight-0.2.3.R` | `a91d41916eb151efac2270ae3d4da05e8f918597396b5436b2d354edec4a8f2a` |
| `conquest-additive-mfrm-design-0.2.3.R` | `4698b9f7eb83896c1f97e8b6eb98326c00b028ca0517c2d954c5f1fce8633a21` |
