# TAM MML core calibration record for mfrmr 0.2.3

Status: bounded calibration complete, 2026-08-12. This is a source- and
runtime-identified observation on the existing additive complete-crossing
fixture. It does not freeze `EXT-TAM-TOL`, bind a candidate, pass the
`tam_mml_core` release-spine row, or establish scientific equivalence.

## Runtime and model identity

| Field | Value |
| --- | --- |
| Contract | `mfrmr_tam_mml_core_calibration_v1` |
| TAM version | `4.3.25` |
| Primary function | `TAM::tam.mml.mfr` |
| Loaded-function SHA-256 | `93631641ee114fe0e46ae47b8a1c4788d394ec4e1ca74cfef2b5db4efdce07ca` |
| Local help topic checked | `TAM::tam.mml.mfr` |
| Families | RSM and criterion-step PCM |
| Estimator | MML, fixed unit slope |
| Facets | criterion (`item`) plus rater |
| Latent regression | intercept plus `X` |
| Constraint | TAM `cases`; transformed to the mfrmr sum-zero criterion coordinate |
| Integration | TAM `nodes=seq(-6,6,length.out=q)`, `snodes=0`, q=31/61 |
| Input SHA-256 | `4681a8d9663d89fff30edc1d4dbda78ec8cf4df8e62ba0fb959e40d9c35f6694` |

The installed help explicitly distinguishes the fixed-slope multifacet route
from `tam.mml.2pl()` GPCM slope estimation: `tam.mml.mfr()` does not estimate
facet-model slopes. This record therefore supplies no free-slope GPCM
evidence.

## Coordinate transformation

With TAM's `constraint="cases"`, the latent intercept is fixed to zero and the
common location is carried by the item xi parameters. If
\(\bar\xi_{item}\) is their mean, the matched mfrmr coordinate is

\[
  \beta_0^{mfrmr}=-\bar\xi_{item}^{TAM},\qquad
  d_i^{mfrmr}=\xi_i^{TAM}-\bar\xi_{item}^{TAM}.
\]

The latent-regression slope, variance, rater contrasts, and step contrasts are
then direct coordinates. The runner verifies zero-sum criterion and rater
contrasts after transformation. A raw label-by-label comparison without this
location transform would compare different identified coordinates.

## Observed calibration

All four fits returned finite results without warnings or messages. The mfrmr
side independently re-evaluated response probabilities and the marginal
log-likelihood and retained the complete all-pattern local-rank audit.

| Run | TAM iterations | TAM deviance | mfrmr deviance | TAM − mfrmr deviance | maximum transformed coordinate difference |
| --- | ---: | ---: | ---: | ---: | ---: |
| RSM q31 | 229 | 930.9843959423328 | 930.9843957779988 | 1.6433398e-7 | 5.5576677e-8 |
| RSM q61 | 228 | 930.9843957779955 | 930.9843957779965 | -1.0231815e-12 | 3.4349019e-8 |
| PCM q31 | 230 | 930.5047797909033 | 930.5047795684739 | 2.2242943e-7 | 9.8968670e-8 |
| PCM q61 | 230 | 930.5047795684706 | 930.5047795684713 | -7.9580786e-13 | 4.4845719e-8 |

The 46 coordinate rows comprise 20 RSM rows and 26 PCM rows across q31/q61.
The maximum mfrmr oracle log-likelihood difference is
`1.136868377216160e-13`; the maximum independently computed probability
difference is `1.776356839400250e-15`.

The largest absolute q61-minus-q31 changes are:

| Engine | RSM coordinates | PCM coordinates | RSM deviance | PCM deviance |
| --- | ---: | ---: | ---: | ---: |
| TAM | 4.8619377e-8 | 6.4264928e-8 | 1.6433728e-7 | 2.2243273e-7 |
| mfrmr | 1.6518453e-11 | 1.6602053e-11 | 2.2737368e-12 | 2.5011104e-12 |

These values are observations, not acceptance limits. The test's `1e-5`
bound is labelled only as a broad engineering regression guard for this
calibration and must not be renamed or reused as `EXT-TAM-TOL`.

## Disposition

| Field | Value |
| --- | --- |
| `CalibrationComplete` | `TRUE` |
| `ComparisonToleranceFrozen` | `FALSE` |
| `CandidateBound` | `FALSE` |
| `ComparisonPassed` | `FALSE` |
| `HiddenSolutionEquivalenceInferred` | `FALSE` |
| `InferenceReady` | `FALSE` |
| `DFFFitRankInvarianceEvaluated` | `FALSE` |
| `SparseExtensionAuthorized` | `FALSE` |
| `GPCMExtensionAuthorized` | `FALSE` |
| `LargeSimulationAuthorized` | `FALSE` |
| `ReleaseAuthorized` | `FALSE` |

The next TAM action is prospective, not another fit to these data: define the
TAM-specific estimand classes and numerical error budget, choose a disjoint
candidate fixture, and only then run the registered q31/q61 comparison. DFF,
fit, ranking, sparse allocation, extreme scores, and free-slope GPCM remain
separate designs.

## Source identities

| Artifact | SHA-256 |
| --- | --- |
| `tam-mml-core-calibration-0.2.3.R` | `f5c393060e65ebfc4a2dcdf5b7173d1726a28e404b2f30010fd5b71103333033` |
| `test-tam-mml-core-calibration.R` | `1429a64ea27c1b8c1bb2108ed19fc90537e556545495df84d3ac639de39650bd` |
| `conquest-additive-mfrm-design-0.2.3.R` | `4698b9f7eb83896c1f97e8b6eb98326c00b028ca0517c2d954c5f1fce8633a21` |
| `conquest-additive-mfrm-reference-preflight-0.2.3.R` | `a91d41916eb151efac2270ae3d4da05e8f918597396b5436b2d354edec4a8f2a` |
