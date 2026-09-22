# External MML algorithm and correlation audit for mfrmr 0.2.3

Status: deterministic audit complete, 2026-08-12. The audit reuses the bound
ConQuest candidate-003 and TAM calibration observations. It launches no new
external fit, freezes no new tolerance, and treats correlation as a descriptive
diagnostic rather than an equivalence or release rule.

Contract: `mfrmr_external_mml_algorithm_correlation_audit_v1`.

## What is and is not the same

The ConQuest 5.47.5 manual (PDF pages 254--257, 320--321) describes marginal
maximum likelihood, numerical integration, an EM iteration, Newton--Raphson
item-parameter updates, population updates, and separately configurable
parameter-change and deviance-change stopping rules. Candidate 003 explicitly
used `method=quadrature`, q=31/61, parameter convergence `1e-8`, deviance
change `1e-10`, and 2000 iterations.

The installed TAM 4.3-25 help documents numerical integration over supplied
theta nodes, inner M-steps, and EM controls. The matched calibration used
`tam.mml.mfr()` with `nodes=seq(-6,6,length.out=q)`, `snodes=0`, and an exact
location transformation from `constraint="cases"`. It is in the same broad
fixed-grid MML/EM family as this ConQuest route, but exact update, acceleration,
and stopping-rule identity is not documented and is not inferred.

Inspection of the installed namespace confirms the actual loop calls separate
probability/E-step work, population-regression and variance updates, inner
item-intercept M-steps, deviance evaluation, and optional acceleration. The
audit binds the formals/body hashes of `tam.mml.mfr`, `tam_mml_calc_prob`,
`tam_mml_mstep_regression`, `tam_mml_mstep_intercept`,
`tam_mml_mstep_xsi`, `tam_mml_compute_deviance`, and
`tam_acceleration_inits`; all seven match the registered TAM 4.3-25 identities.
This demonstrates the installed call path, not source-code identity with
ConQuest's proprietary implementation.

mfrmr evaluates the same full marginal-likelihood estimand in the matched
Binary/RSM/PCM core, but its default route uses transformed standard-normal
Gauss--Hermite quadrature and analytic-gradient L-BFGS-B, with bounded
gradient polishing and a BFGS fallback. Therefore default mfrmr is deliberately
not the same numerical algorithm as ConQuest. The optional mfrmr EM route is
currently restricted to additive RSM/PCM without an active population model;
it is not a ConQuest-compatibility implementation.

The installed immer 1.5-13 routes do not provide a matched ConQuest MML
algorithm. `immer_cml()` conditions on the Person score, `immer_ccml()` uses
pairwise composite conditional likelihood, and `immer_jml()` uses a joint
likelihood with explicitly distinct adjustment/correction modes. Structural
Rasch contrasts can be useful external references, but Person population
regression, variance, marginal deviance, and free-slope faceted GPCM cannot be
validated by relabelling those objectives as MML.

Consequently mfrmr must match the mathematical model, response support,
identification/coordinate map, likelihood, and integration target. It need not
copy the external optimizer. Independent solvers are useful evidence when they
arrive at the same stationary solution. A fixed-grid/EM compatibility route
would be a separate reproducibility feature, not grounds to replace the
current direct default.

## Pearson correlations on independent free coordinates

Deviance is excluded from every correlation, because its much larger scale
would make the coefficient trivially close to one. TAM sum-zero coordinates
derived from the free basis are also excluded. ConQuest values are limited to
the exact decimals retained in its native exports.

| Comparison | Model | q | free coordinates | Pearson r | RMSE | maximum absolute difference |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| ConQuest--mfrmr | Binary | 31 | 8 | 0.9999999999954391 | 2.1758544e-6 | 5.7617044e-6 |
| ConQuest--mfrmr | Binary | 61 | 8 | 0.9999999999954391 | 2.1758544e-6 | 5.7617044e-6 |
| ConQuest--mfrmr | RSM | 31 | 7 | 0.9999999999984525 | 1.3072000e-6 | 2.7338839e-6 |
| ConQuest--mfrmr | RSM | 61 | 7 | 0.9999999999984524 | 1.3072007e-6 | 2.7338851e-6 |
| ConQuest--mfrmr | PCM | 31 | 9 | 0.9999999999994219 | 1.2031799e-6 | 2.0965377e-6 |
| ConQuest--mfrmr | PCM | 61 | 9 | 0.9999999999994219 | 1.2031796e-6 | 2.0965211e-6 |
| TAM--mfrmr | RSM | 31 | 7 | 0.9999999999999992 | 3.7876354e-8 | 5.5576677e-8 |
| TAM--mfrmr | RSM | 61 | 7 | 0.9999999999999992 | 2.1230067e-8 | 3.4349019e-8 |
| TAM--mfrmr | PCM | 31 | 9 | 0.9999999999999992 | 4.8691080e-8 | 9.4491857e-8 |
| TAM--mfrmr | PCM | 61 | 9 | 0.9999999999999998 | 1.8325920e-8 | 4.0301613e-8 |
| ConQuest--TAM | RSM | 31 | 7 | 0.9999999999984727 | 1.2784229e-6 | 2.6783072e-6 |
| ConQuest--TAM | RSM | 61 | 7 | 0.9999999999984258 | 1.3027749e-6 | 2.7269266e-6 |
| ConQuest--TAM | PCM | 31 | 9 | 0.9999999999994541 | 1.1561019e-6 | 2.0214389e-6 |
| ConQuest--TAM | PCM | 61 | 9 | 0.9999999999994226 | 1.1880481e-6 | 2.0652237e-6 |

Aggregate descriptive values are:

| Comparison | rows | Pearson r | affine intercept | affine slope | RMSE | maximum absolute difference |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| ConQuest--mfrmr | 48 | 0.9999999999975755 | 3.6467766e-7 | 1.0000022833 | 1.6184473e-6 | 5.7617044e-6 |
| TAM--mfrmr | 32 | 0.9999999999999989 | 8.3440005e-9 | 1.0000000582 | 3.4258796e-8 | 9.4491857e-8 |
| ConQuest--TAM | 32 | 0.9999999999990429 | 2.5184204e-7 | 1.0000022581 | 1.2254257e-6 | 2.7269266e-6 |

These coefficients show practically coincident parameter vectors on this
benign complete-crossing fixture. They are not Person- or Rater-rank
correlations, and they do not evaluate DFF, fit classification, facet
separation, sparse allocation, or endpoint decisions. The maximum observed
deviance differences remain separately checked: approximately `4.32e-7` for
ConQuest--mfrmr and `2.23e-7` for TAM--mfrmr. Candidate-003 q31/q61 ConQuest
tokens are identical at reported precision; mfrmr q31/q61 coordinate changes
remain at or below `1.66e-11`, while TAM fixed-grid changes are at or below
`6.43e-8`.

The remaining differences are not labelled "floating point only". They also
contain documented integration-rule approximation and ConQuest export
rounding. At q61, TAM--mfrmr deviance differences fall to about `1e-12`, which
is consistent with convergence of the two integration approximations, but does
not prove bitwise algorithm identity.

## Log-domain and source-path stress

For 200 observations each contributing probability 0.01:

| Evaluation | Result |
| --- | ---: |
| `log(0.01^200)` | `-Inf` |
| `200 * log(0.01)` | `-921.0340371976182` |
| mfrmr Person log marginal | `-921.0340371976157` |
| mfrmr minus analytic sum | `2.5011104e-12` |

The finite difference is ordinary binary64 summation-order error, about
`2.7e-15` relative to the absolute log value. The mfrmr path first creates
category log probabilities with max-shifted log-sum-exp, sums log
probabilities by Person with `rowsum()`, then integrates nodes with another
max-shifted log-sum-exp. Its compiled RSM/PCM category kernels also subtract
the row maximum before exponentiation. A source scan finds no
`log(prod(...))` pattern in these likelihood sources. Thus the naïve
underflowing script is a negative control, not the code path used by mfrmr.

## Disposition

| Field | Value |
| --- | --- |
| `AuditComplete` | `TRUE` |
| `SameAlgorithmRequired` | `FALSE` |
| `SameObjectiveAndCoordinateMapRequired` | `TRUE` |
| `CorrelationIsAcceptanceRule` | `FALSE` |
| `NumericalDifferenceIsFloatingPointOnly` | `FALSE` |
| `IntegrationApproximationDifferencePresent` | `TRUE` |
| `DFFFitPersonRaterRankInvarianceEvaluated` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |
| `ReleaseAuthorized` | `FALSE` |

## Bound identities

| Artifact | SHA-256 |
| --- | --- |
| ConQuest executable | `61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48` |
| ConQuest manual | `60bce1a39f5430fd304178356fb943721f9f72c0ddee70a9866c28c87017459f` |
| `external-mml-algorithm-correlation-audit-0.2.3.R` | `6acfd5e657a2e76a3896a975654b1d1a8b1c7add58025cefd2642612e166fc94` |
| `test-external-mml-algorithm-correlation-audit.R` | `673eb34b9a7b211a4927e2fa2d21c33c85e2a96b8cda325762d5f1b501b30aad` |
