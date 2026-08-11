# TAM/immer/mfrmr matched JML mode contract for mfrmr 0.2.3

Status: repository-only Draft.75 calibration contract, 2026-08-09.

## Source and runtime audit

The primary local external identities are TAM 4.3-25 and immer 1.5-13. The
runner records their installed versions and SHA-256 hashes of the exact loaded
`tam.jml` and `immer_jml` function formals/bodies. The interpretation was
checked against the local package help, the CRAN TAM `tam.jml` help and manual,
the CRAN immer 1.5-13 manual, and the official immer repository.

The source audit establishes the following noninterchangeable conventions:

- TAM `adj` adds/subtracts a score constant for zero/maximum Person scores;
  `bias = TRUE` subsequently multiplies free item-basis parameters by
  `(I - 1) / I`.
- immer `est_method = "jml"` still applies `eps` to extreme Person scores. It
  equals an original unadjusted JML estimating equation only when no Person is
  extreme.
- immer `est_method = "eps_adj"` changes Person and item sufficient statistics
  through its epsilon/fuzzy-score construction. It is not merely a finite
  display for extreme Persons and it does not apply the classical scale factor.
- immer `est_method = "jml_bc"` begins from the same extreme-score handling as
  `"jml"`, then multiplies item-basis parameters by
  `(Ibar - 1) / Ibar`, where `Ibar` is the mean observed item count per row in
  the loaded 1.5-13 source.

Consequently, `adj = 0`, epsilon adjustment, extreme-only epsilon handling,
and classical multiplicative bias correction remain separate method identity
fields. Package defaults are never used as unnamed comparison modes.

## Common model overlap

Draft.75 is restricted to unidimensional additive RSM and PCM response
surfaces. It excludes GPCM because immer's documented `immer_jml()` route is a
PCM/design-matrix estimator and neither TAM nor immer mode is automatically
the same aligned single-owner relative-slope GPCM implemented by mfrmr.

The same complete crossed Person x Rater x Criterion observations enter every
engine. Scores are mapped from mfrmr's declared 1--4 scale to the external
0--3 representation. TAM's documented multifacet preprocessing creates one
pseudoitem per Criterion x Rater cell and supplies the exact same response
matrix and design array to TAM and immer:

- RSM: `~ item + rater + step`;
- PCM: `~ item + rater + item:step`.

The preprocessing MML call is design construction only and cannot contribute
an MML estimate to this JML comparison.

## Common structural estimand

Raw basis coefficients are not compared directly because TAM and immer use
opposite category-intercept signs and their design matrices use corner
constraints, while mfrmr reports centered facet and step coordinates.

Every result is expanded to the cumulative category-difficulty surface

`P(Y_ir = k | theta) proportional to exp(k * theta - b_ir,k)`.

For mfrmr,

`b_ir,k = k * (beta_r + beta_i) + sum_(s <= k) tau_i,s`,

with a common step ladder for RSM and Criterion-specific fitted ladders for
PCM. TAM is normalized as `b = -AXsi`; immer returns `b` directly. The only
remaining invariance is a latent-location shift `delta`, which adds
`k * delta` to every category difficulty. Truth recovery and cross-engine
comparison remove only its least-squares projection:

`delta_hat = sum k * (b_hat - b_ref) / sum k^2`.

No scale, dispersion, or parameter-class-specific transformation is fitted.

## Frozen mode registry

| Mode | Exact identity | Original raw JML eligibility |
| --- | --- | --- |
| `MFRMR_RAW` | finite mfrmr JML optimizer trace | Only datasets without a free extreme Person; no finite-maximum claim is made |
| `MFRMR_PROFILE` | Draft.73/74 extended boundary profile | Never relabelled as a finite original-JML maximum |
| `TAM_RAW` | `adj=0, bias=FALSE` | Only datasets without extreme Persons |
| `TAM_ADJ` | `adj=.3, bias=FALSE` | Adjusted method identity |
| `TAM_BC` | `adj=0, bias=TRUE` | Raw basis plus classical factor; only computable/eligible without extremes |
| `TAM_BC_ADJ` | `adj=.3, bias=TRUE` | Combined adjustment and classical factor |
| `IMMER_JML` | `est_method="jml", eps=.3` | Original raw only when no Person is extreme |
| `IMMER_EPS` | `est_method="eps_adj", eps=.3` | Epsilon/fuzzy estimating equation, not raw |
| `IMMER_BC` | `est_method="jml_bc", eps=.3` | Extreme handling plus classical factor, not raw |

All modes set `OriginalMaximumClaimed = FALSE` in this calibration.

## Smoke and pilot design

The smoke tier contains paired RSM/PCM datasets with 64 Persons, 3 Raters,
3 Criteria, 9 responses per Person, four categories, and forced extreme
fractions 0 and 0.125. The fraction pair for a model uses the same base seed;
only the declared eight Persons are changed.

The authorization-guarded pilot declares 60 datasets: RSM/PCM, low/high
exposure, fractions 0/0.10/0.25, and five replicates. It remains calibration,
not confirmation.

## Software and semantic invariants

The smoke contract requires:

- mfrmr and TAM raw cumulative surfaces to agree after location alignment on
  no-extreme data;
- TAM raw and immer `jml` to agree on no-extreme data;
- TAM `adj=.3` and immer `jml, eps=.3` to agree on extreme data;
- TAM adjustment to be a no-op when no score is extreme;
- TAM and immer classical-bias modes to reproduce their documented factors;
- mfrmr profile to be a no-op without free extremes and verified otherwise;
- TAM `adj=0` raw/classical modes to fail closed rather than emit a finite
  result when forced extremes make their score equations nonfinite; and
- every mode, error, adjustment, bias factor, effective item count, runtime,
  and expanded recovery row to remain retained.

The cross-implementation `2e-5` and mfrmr/TAM `5e-5` limits are smoke
regression tolerances calibrated after inspecting these deterministic
microcases. They are not external-agreement or release thresholds.

## Prohibitions and remaining work

This contract compares structural response surfaces only. Person estimates,
WLEs, reported SEs, intervals, fit statistics, and information criteria are
not yet definition-matched. An external program is not ground truth.

The runner always returns `EvidenceReady = FALSE` and
`ReadinessEffect = "none_calibration_only"`. No single-cell RMSE may select a
correction. Missingness is especially important because TAM's factor uses the
pseudoitem column count whereas immer 1.5-13 uses mean observed exposure.
Expanded replication, unequal exposure, missingness, weights, sparse/weak
links, category imbalance, anchors, Person-state normalization, supported
uncertainty, and untouched confirmation seeds remain required.

## Official documentation anchors

- https://search.r-project.org/CRAN/refmans/TAM/html/tam.jml.html
- https://cran.r-project.org/web/packages/TAM/TAM.pdf
- https://cran.r-project.org/package=immer
- https://cran.r-project.org/web/packages/immer/immer.pdf
- https://github.com/alexanderrobitzsch/immer
