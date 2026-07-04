# Bounded-GPCM score-side estimand and uncertainty design (0.2.2 program)

Status: design artifact for the `gpcm_score_side_contract()` validation
program. This document is the named definition required by the
`score_estimand`, `measure_to_score_metric`, `score_uncertainty`, and
`facets_score_uncertainty_contract` contract rows. It is a release-scope
record, not user documentation; help pages quote its conclusions, not its
derivations.

## 1. The Rasch-family score-side semantics this route does not borrow

The FACETS/Winsteps score file is a raw-score-to-measure conversion table.
The Winsteps `SCOREFILE=` page defines one row for "every possible score on
a test consisting of all the non-extreme items", with columns `SCORE`,
`MEASURE`, `S.E.` ("Standard error ... - model"), and `INFO`
("Statistical information in measure (=1/Logit S.E.^2)"); see
<https://www.winsteps.com/winman/scfile.htm>. The FACETS fixed-field score
files follow the layout documented at
<https://www.winsteps.com/facetman64/scorefileinvisible.htm> (see
`inst/references/FACETS_manual_mapping.md`). The score-to-measure ogive
behind those tables is the test characteristic curve
(<https://www.winsteps.com/winman/testcharacteristiccurve.htm>).

That table semantics is licensed by Rasch-family sufficiency. For `RSM` /
`PCM` (Andrich, 1978; Masters, 1982; Wright & Masters, 1982), the person
score equation is

```
d logL / d theta = sum_i (x_i - E[X_i | theta]),
```

so the unweighted raw score `sum_i x_i` is sufficient for `theta`: every
raw score maps to one measure with one model standard error, independent of
which categories produced the score.

## 2. Why the bijection fails under bounded GPCM

Under the generalized partial credit model (Muraki, 1992,
\doi{10.1177/014662169201600206}), the adjacent-category kernel carries a
slope `a_i`, and the person score equation becomes

```
d logL / d theta = sum_i a_i (x_i - E[X_i | theta]).
```

The sufficient statistic is the slope-weighted score `sum_i a_i x_i`, not
the raw score. Two response patterns with the same raw score but different
slope-weighted scores have different likelihoods and different maximum
likelihood measures. Consequently a raw-score-to-measure table in the
`SCOREFILE=` sense has no model-consistent definition under free
discrimination, and exporting one would silently re-impose Rasch-family
semantics on a non-Rasch model.

The bounded-GPCM score-side estimand is therefore **observation-level**,
not score-level. This is the substantive content of the estimand name
already recorded in the export: `fitted_bounded_gpcm_expected_score`.

## 3. Named estimand, column by column

Conditioning statement for every row: structural parameters `xi` (steps,
slopes, non-person facets) are fixed at their MML estimates, and the person
measure is fixed at the EAP estimate `theta_hat` (Bock & Mislevy, 1982,
\doi{10.1177/014662168200600405}). Score-side quantities are fitted-model
summaries at `(theta_hat, xi_hat)`; they are not posterior predictive
quantities and not operational scoring decisions.

| Column | Definition | Notes |
|---|---|---|
| `Observed` | observed category score `x` | data |
| `Expected` | `E[X given theta_hat, xi_hat]` | the named estimand; slope-aware kernel (Muraki, 1992) |
| `Var` | `Var(X given theta_hat, xi_hat)` | conditional score variance |
| `Residual` | `x - Expected` | |
| `StdResidual` | `Residual / sqrt(Var)` | |
| `ScoreSlope` | fitted discrimination `a` for the observation | **not** `dE/dtheta`; the name records the slope parameter (`core-likelihood.R`, `slope_obs`) |
| `ScoreInformation` | `a^2 * Var(X given theta)` | Muraki (1993, \doi{10.1177/014662169301700403}) information identity |
| `ObservedScoreDerivative` | `a * (x - Expected)` | observation score function (gradient contribution), not a derivative of `Expected` |
| `PrObserved` | model probability of the observed category | |

Derived identity used below: `dE[X]/dtheta = a * Var(X given theta)`, i.e.
`ScoreInformation / ScoreSlope`. This follows from the adjacent-category
exponential-family form and is the polytomous response-function derivative
behind Muraki's information function.

## 4. Uncertainty contract

Two routes ship, with distinct estimands; neither is FACETS-equivalent and
the status/method/detail columns must keep saying so.

### 4a. Native structural route (`ExpectedScoreSE`)

Delta method (Oehlert, 1992) for `Expected` as a function of the structural
parameters: finite-difference Jacobian of
`compute_expected_score_vector_from_par()` against the MML
observed-information covariance from
`compute_mml_parameter_covariance()` (Bock & Aitkin, 1981,
observed-information basis). EAP `theta_hat` is conditioned on, not
propagated — the same convention as the structural fair-average SEs
(`add_gpcm_fair_average_delta_se()`), and the reason person-side
uncertainty is reported separately as posterior SDs.

### 4b. Score-side companion route (`ScoreSideSE`) — corrected specification

The pre-0.2.2 working implementation (`mfrm_core.R`,
`add_gpcm_score_side_delta_se()`) computed
`eta_se = sqrt(sum of component ModelSE^2)` over the person and facet
measures and set `se = |ScoreSlope| * eta_se`, then formed confidence bounds
as `Expected +/- z * se`.

**Finding (2026-06-13): this mixed scales.** `|a| * eta_se` is the
delta-method SE of the slope-scaled linear predictor `a * eta`, not of
`Expected`. Applying it around `Expected` overstates the score-scale
uncertainty by the factor `1 / Var(X given theta)` (typically about 2x at
moderate `Var ~ 0.5`, more in the tails).

Implemented specification: the score-scale transform uses the response
function derivative,

```
ScoreSideSE = |dE/dtheta| * eta_se = ScoreSlope * Var * eta_se,
```

with `ScoreSideLogitSE = eta_se` retained unchanged for the
linear-predictor view. The independence approximation (component variances
summed without cross-component covariances) remains and remains documented
in `ScoreSideSE_Detail`; the corrected route is still review-level
screening uncertainty, status `supported_with_caveat`, and still not
FACETS-equivalent. Under unit slopes the corrected factor reduces to
`Var * eta_se`, which is the same expression the `RSM` / `PCM` route
implies, so the PCM reduction test extends to this column.

### 4c. FACETS-compatible review contract

`facets_output_contract_review()` may report bounded-GPCM score rows when
its GPCM mode reviews them against **this** column contract: schema
presence, estimand naming, status consistency (`available`, `caveated`,
`not_requested`, `unavailable`), and uncertainty-route labeling. It must
not map `ExpectedScoreSE` or `ScoreSideSE` onto the FACETS `S.E.` column
semantics (a per-raw-score model SE), because section 2 shows the
underlying table concept does not transfer. "FACETS-compatible" therefore
means: reviewable in the same contract framework with explicitly
non-borrowed uncertainty semantics — not numerically comparable SEs.

## 5. Identification and invariance requirements

Slopes are identified by the geometric-mean-one convention and steps by
sum-to-zero profiles (existing package conventions). The scorefile columns
must be invariant to the compensating rescaling
`(a * c, theta / c, delta / c)`: `Expected`, `Var`, `PrObserved`,
`StdResidual` exactly; `ScoreSlope`, `ScoreInformation`,
`ObservedScoreDerivative` transform as documented (factor `c`, `c^2`, `c`).
Existing fair-average invariance tests provide the template
(`test-gpcm-fair-average.R`).

## 6. Reduction requirements (unit slope)

With `a == 1` for all slope levels, every scorefile column must reduce to
the `PCM` route within numerical tolerance: `Expected`, `Var`, `Residual`,
`StdResidual`, `PrObserved`, `ScoreInformation` (= `Var`),
`ObservedScoreDerivative` (= `x - Expected`), `ExpectedScoreSE`, and the
corrected `ScoreSideSE` (= `Var * eta_se`).

## 7. Negative-test requirements

- `score_se_method = "none"` rows carry explicit `not_requested` status
  with `NA` SEs, never silently computed values.
- Non-MML fits and unavailable covariances carry `unavailable` status, not
  numbers.
- `facets_output_contract_review()` keeps raising
  `mfrmr_gpcm_scope_error` for bounded GPCM until the capability-matrix
  row moves; after it moves, unsupported sections must be flagged
  explicitly rather than omitted (contract `export_schema` exit
  criterion).

## 8. Exit-criteria mapping

Executable companion: `gpcm-score-side-simulation-0.2.2.R` checks the
independent adjacent-category identities used here and runs the Monte Carlo
score-side SE comparison. By default it writes generated CSVs under
`validation-results/`; only adequately replicated release-evidence runs
should be written back to `inst/validation`.

| Contract row | Satisfied by |
|---|---|
| `score_estimand` | sections 2-3 (named observation-level estimand; no raw-score table) |
| `measure_to_score_metric` | section 3 identity + section 5 invariance tests |
| `score_uncertainty` | section 4a-4b incl. the corrected score-scale factor |
| `facets_score_uncertainty_contract` | section 4c review semantics |
| `structural_fair_average_se` | unchanged dependency (4a shares its convention) |
| `pcm_reduction` | section 6 column-complete reduction tests |
| `export_schema` | section 3 table + section 7 status taxonomy |
| `runtime_guard` | section 7 final bullet |
| `release_wording` | sections 2 and 4c boundary language |

## References

- Andrich, D. (1978). A rating formulation for ordered response
  categories. *Psychometrika*, 43, 561-573.
- Masters, G. N. (1982). A Rasch model for partial credit scoring.
  *Psychometrika*, 47, 149-174.
- Wright, B. D., & Masters, G. N. (1982). *Rating scale analysis*. MESA
  Press.
- Muraki, E. (1992). A generalized partial credit model: Application of an
  EM algorithm. *Applied Psychological Measurement*, 16(2), 159-176.
- Muraki, E. (1993). Information functions of the generalized partial
  credit model. *Applied Psychological Measurement*, 17(4), 351-363.
- Bock, R. D., & Aitkin, M. (1981). Marginal maximum likelihood estimation
  of item parameters. *Psychometrika*, 46, 443-459.
- Bock, R. D., & Mislevy, R. J. (1982). Adaptive EAP estimation of ability
  in a microcomputer environment. *Applied Psychological Measurement*,
  6(4), 431-444.
- Oehlert, G. W. (1992). A note on the delta method. *The American
  Statistician*, 46(1), 27-29.
- Linacre, J. M. *Winsteps* manual: `SCOREFILE=`
  (<https://www.winsteps.com/winman/scfile.htm>); Test characteristic curve
  (<https://www.winsteps.com/winman/testcharacteristiccurve.htm>).
- Linacre, J. M. *Facets* manual: score file fixed-field columns
  (<https://www.winsteps.com/facetman64/scorefileinvisible.htm>).
